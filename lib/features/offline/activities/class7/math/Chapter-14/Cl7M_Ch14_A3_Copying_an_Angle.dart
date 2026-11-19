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
    home: CopyinganAngle(),
  ));
}

class CopyinganAngle extends StatefulWidget {
  const CopyinganAngle({Key? key}) : super(key: key);

  @override
  State<CopyinganAngle> createState() => _CopyinganAngleState();
}

class _CopyinganAngleState extends State<CopyinganAngle> with SingleTickerProviderStateMixin {
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

  // Network Audio Sources for guaranteed playback on Android
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

  // Exact HTML Logic State Variables
  int _currentStep = 0;
  int _scen1Step = 0;
  int _scen3Step = 0;
  int _scen4Step = 0;
  int _scen5Step = 0;
  bool _cen1Done = false, _cen2Done = false, _cen3Done = false;
  
  bool _scenarioCompleted = false;
  bool _bridgeStabilized = false;
  bool _arcJustDrawn = false;
  double _savedRadius1 = 0;
  double _savedRadius2 = 0;
  double _savedRadius3 = 0;

  String _hudMessage = '';
  Color _hudColor = Colors.white; 
  Timer? _hintTimer;

  // Mini HUD Toast
  String _toastMessage = '';
  double _toastOpacity = 0.0;
  Timer? _toastTimer;

  late AnimationController _pulseController;
  Offset _floatingStepPos = const Offset(20, 80);

  @override
  void initState() {
    super.initState();
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
      _showShutter = true;
      _currentLang = 'en'; // Resets language
      _loadScenario(0);
    });
  }

  void _loadScenario(int index) {
    _currentScenario = index;
    _currentStep = 0;
    _scen1Step = 0; _scen3Step = 0; _scen4Step = 0; _scen5Step = 0;
    _cen1Done = false; _cen2Done = false; _cen3Done = false;
    
    _scenarioCompleted = false;
    _bridgeStabilized = false;
    _arcJustDrawn = false;
    _activeTool = null;
    _compass = null;
    _ruler = null;
    _points.clear();
    _lines.clear();
    _arcs.clear();
    _hudColor = Colors.white;

    if (index == 0) {
      _points.add(GeoPoint(id: 'A', x: -250, y: 80, label: 'A', color: Colors.indigoAccent));
      _lines.add(GeoLine(id: 'src_arm1', p1: const Offset(-250, 80), p2: const Offset(-50, 80), width: 4)); 
      _lines.add(GeoLine(id: 'src_arm2', p1: const Offset(-250, 80), p2: const Offset(-120, -50), width: 4));
      _points.add(GeoPoint(id: 'X', x: 50, y: 80, label: 'X', color: Colors.indigoAccent));
      _lines.add(GeoLine(id: 'tgt_arm', p1: const Offset(50, 80), p2: const Offset(350, 80), width: 4));
    } else if (index == 1) {
      _points.add(GeoPoint(id: 'X', x: 0, y: -50, label: 'X', color: Colors.amber));
      _lines.add(GeoLine(id: 'tgt_arm', p1: const Offset(0, -50), p2: const Offset(-200, -50), width: 4));
      _points.add(GeoPoint(id: 'A', x: 220, y: 0, label: 'A', color: Colors.amber));
      _lines.add(GeoLine(id: 'src_arm1', p1: const Offset(220, 0), p2: const Offset(20, 0), width: 4));
      _lines.add(GeoLine(id: 'src_arm2', p1: const Offset(220, 0), p2: const Offset(320, 100), width: 4));
    } else if (index == 2) {
      _points.add(GeoPoint(id: 'O', x: 0, y: 0, label: 'O', color: Colors.amber));
      _points.add(GeoPoint(id: 'A', x: 120, y: 0, label: 'A', color: Colors.lightBlue));
      _points.add(GeoPoint(id: 'B', x: 120 * math.cos(-math.pi/4), y: 120 * math.sin(-math.pi/4), label: 'B', color: Colors.lightBlue));
      _lines.add(GeoLine(id: 'src_arm1', p1: const Offset(0, 0), p2: const Offset(200, 0), width: 3)); 
      _lines.add(GeoLine(id: 'src_arm2', p1: const Offset(0, 0), p2: Offset(200 * math.cos(-math.pi/4), 200 * math.sin(-math.pi/4)), width: 3));
    } else if (index == 3) {
      _lines.add(GeoLine(id: 'm', p1: const Offset(-400, 120), p2: const Offset(400, 120), width: 3));
      _lines.add(GeoLine(id: 'l', p1: const Offset(-250, 270), p2: const Offset(200, -180), width: 3));
      _points.add(GeoPoint(id: 'V', x: -100, y: 120, label: 'V', color: Colors.amber));
      _points.add(GeoPoint(id: 'P', x: 50, y: -30, label: 'P', color: Colors.amber));
    } else if (index == 4) {
      _points.add(GeoPoint(id: 'A', x: -150, y: 100, label: 'A', color: Colors.amber));
      _points.add(GeoPoint(id: 'D', x: 150, y: 100, label: 'D', color: Colors.amber));
      _points.add(GeoPoint(id: 'B', x: -150 + 150*math.cos(-math.pi/3), y: 100 + 150*math.sin(-math.pi/3), label: 'B', color: Colors.lightBlue));
      _lines.add(GeoLine(id: 'base', p1: const Offset(-300, 100), p2: const Offset(300, 100), width: 4));
      _lines.add(GeoLine(id: 'arm1', p1: const Offset(-150, 100), p2: const Offset(-25, -116), width: 4));
    }
    
    // Fit canvas dynamically
    _scale = 1.0; _panOffset = Offset.zero;
    _updateHUD();
  }

  void _updateHUD() {
    if (_scenarioCompleted) {
      _hudMessage = _currentLang == 'hi' ? "शाबाश! आपने यह निर्माण सफलतापूर्वक पूरा कर लिया है।" : "Success! Construction Complete!";
      return;
    }
    
    final stepsList = _i18n[_currentLang]!['scenarios'][_currentScenario]['steps'] as List;
    if (_currentStep >= stepsList.length) return;

    String msg = stepsList[_currentStep]['hud'];
    if (_currentScenario == 1 && _currentStep == 0) msg = _i18n[_currentLang]!['scenarios'][1]['hud_hints']?[_scen1Step] ?? msg;
    if (_currentScenario == 2 && _currentStep == 0) msg = _i18n[_currentLang]!['scenarios'][2]['hud_hints']?[_scen3Step] ?? msg;
    if (_currentScenario == 3 && _currentStep == 0) msg = _i18n[_currentLang]!['scenarios'][3]['hud_hints']?[_scen4Step] ?? msg;
    if (_currentScenario == 4 && _currentStep == 0) msg = _i18n[_currentLang]!['scenarios'][4]['hud_hints']?[_scen5Step] ?? msg;
    
    if (_currentScenario == 4 && _currentStep == 1) {
      int doneCount = (_cen1Done?1:0) + (_cen2Done?1:0) + (_cen3Done?1:0);
      if (doneCount == 0) msg = _currentLang == 'hi' ? "चमकते केंद्र पर प्रकार को स्नैप करें और चाप खींचें।" : "Snap compass to any glowing center, stretch pencil to A or D, and draw an arc.";
      if (doneCount == 1) msg = _currentLang == 'hi' ? "बहुत बढ़िया! दूसरे केंद्र पर स्नैप करें और चाप खींचें।" : "Great! Now snap to another center and draw the second arc.";
      if (doneCount == 2) msg = _currentLang == 'hi' ? "अंतिम केंद्र पर स्नैप करें और शीर्ष चाप खींचें।" : "One left! Snap to the final center and draw the top arc.";
    }
    
    _hudMessage = msg;
  }

  void _selectTool(String tool) {
    _playSound('click');
    setState(() {
      _activeTool = tool;
      if (tool == 'compass') {
        _compass ??= CompassTool(x: 0, y: -100, radius: 80, angle: math.pi / 4, isLocked: true); // Start locked by default
        _ruler = null;
      } else if (tool == 'ruler') {
        _ruler ??= RulerTool(x1: -50, y1: -100, x2: 50, y2: -100);
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
           _evaluateScenarioState(); // Evaluates if measurement completed properly
        } else {
           _showToast("Compass Unlocked. Drag pencil to measure.");
        }
      });
    }
  }

  // --- HTML Mathematical Equivalents ---
  List<Offset> _intersectLineSegmentCircle(Offset p1, Offset p2, Offset cpt, double r) {
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double a = dx * dx + dy * dy;
    double b = 2 * (dx * (p1.dx - cpt.dx) + dy * (p1.dy - cpt.dy));
    double c = math.pow(p1.dx - cpt.dx, 2).toDouble() + math.pow(p1.dy - cpt.dy, 2).toDouble() - r * r;
    double det = b * b - 4 * a * c;
    if (a <= 0.000001 || det < 0) return [];
    
    double t1 = (-b + math.sqrt(det)) / (2 * a);
    double t2 = (-b - math.sqrt(det)) / (2 * a);
    List<Offset> pts = [];
    if (t1 >= 0 && t1 <= 1) pts.add(Offset(p1.dx + t1 * dx, p1.dy + t1 * dy));
    if (t2 >= 0 && t2 <= 1 && t2 != t1) pts.add(Offset(p1.dx + t2 * dx, p1.dy + t2 * dy));
    return pts;
  }

  List<Offset> _intersectCircleCircle(Offset c1, double r1, Offset c2, double r2) {
    double dx = c2.dx - c1.dx;
    double dy = c2.dy - c1.dy;
    double d = math.sqrt(dx * dx + dy * dy);
    if (d > r1 + r2 || d < (r1 - r2).abs() || d == 0) return [];
    double a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
    double h = math.sqrt(math.max(0, r1 * r1 - a * a));
    double px = c1.dx + a * (dx / d);
    double py = c1.dy + a * (dy / d);
    return [
      Offset(px + h * (dy / d), py - h * (dx / d)),
      Offset(px - h * (dy / d), py + h * (dx / d))
    ];
  }

  // --- Interaction Handlers ---
  void _onScaleStart(ScaleStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.focalPoint);
    final Offset worldPos = _screenToWorld(localPos);

    _draggedEntity = null;
    _dragPart = '';

    if (_compass != null) {
      if ((worldPos - Offset(_compass!.x, _compass!.y)).distance < 30) {
        _draggedEntity = _compass; _dragPart = 'pivot'; _dragStartPos = worldPos; return;
      }
      
      Offset pencilPos = Offset(_compass!.x + _compass!.radius * math.cos(_compass!.angle), _compass!.y + _compass!.radius * math.sin(_compass!.angle));
      if ((worldPos - pencilPos).distance < 40) {
        _draggedEntity = _compass; 
        _dragPart = 'pencil'; 
        _prevAngle = _compass!.angle;
        
        // Only generate a visible temporary drawing arc if the compass is LOCKED
        if (_compass!.isLocked) {
           _tempArc = GeoArc(x: _compass!.x, y: _compass!.y, radius: _compass!.radius, startAngle: _compass!.angle, sweepAngle: 0);
        } else {
           _tempArc = null; 
        }
        return;
      }
    }

    if (_ruler != null) {
      if ((worldPos - Offset(_ruler!.x1, _ruler!.y1)).distance < 30) { _draggedEntity = _ruler; _dragPart = 'p1'; return; }
      if ((worldPos - Offset(_ruler!.x2, _ruler!.y2)).distance < 30) { _draggedEntity = _ruler; _dragPart = 'p2'; return; }
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
        } else if (_dragPart == 'pencil') {
          if (_compass!.isLocked) {
             // Drawing Arc Mode - Rotates without changing radius
             double newAngle = math.atan2(worldPos.dy - _compass!.y, worldPos.dx - _compass!.x);
             _compass!.angle = newAngle;
             if (_tempArc != null) {
                double delta = newAngle - _prevAngle;
                while (delta > math.pi) delta -= 2 * math.pi;
                while (delta < -math.pi) delta += 2 * math.pi;
                if (_tempArc!.sweepAngle.abs() + delta.abs() < math.pi * 2.5) {
                    _tempArc!.sweepAngle += delta;
                }
             }
             _prevAngle = newAngle;
          } else {
             // Measuring Mode - Smoothly stretches radius
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
            if ((Offset(_compass!.x, _compass!.y) - Offset(p.x, p.y)).distance < 25) {
              _compass!.x = p.x; _compass!.y = p.y; snapped = true; break;
            }
          }
          if (snapped) _playSound('snap'); else _playSound('error');
          _evaluateScenarioState();
        } else if (_dragPart == 'pencil') {
          if (_compass!.isLocked && _tempArc != null) {
            // Arc Drawn Evaluation
            if (_tempArc!.sweepAngle.abs() > 0.05) { 
              _tempArc!.color = Colors.lightBlueAccent;
              _arcs.add(_tempArc!);
              _playSound('draw');
              _arcJustDrawn = true;
              _validateArcDrawing(); 
            } else {
              _playSound('error');
              _showHint("Sweep a larger arc to intersect the lines.");
            }
            _tempArc = null;
          } else if (!_compass!.isLocked) {
            // Evaluates after Measuring/Stretching (Unlocked)
            Offset pencilPos = Offset(_compass!.x + _compass!.radius * math.cos(_compass!.angle), _compass!.y + _compass!.radius * math.sin(_compass!.angle));
            for (var p in _points) {
               if ((pencilPos - p.toOffset()).distance < 25 && (p.x - _compass!.x).abs() > 2) {
                  _compass!.radius = (p.toOffset() - Offset(_compass!.x, _compass!.y)).distance;
                  _compass!.angle = math.atan2(p.y - _compass!.y, p.x - _compass!.x);
                  _showToast("Aligned to ${p.label}. Remember to LOCK radius.");
                  snapped = true;
                  break;
               }
            }
            if (snapped) _playSound('snap');
          }
        }
      } else if (_draggedEntity is RulerTool) {
        for (var p in _points) {
          if (_dragPart == 'p1' || _dragPart == 'body') {
            if ((Offset(_ruler!.x1, _ruler!.y1) - Offset(p.x, p.y)).distance < 30) { _ruler!.x1 = p.x; _ruler!.y1 = p.y; snapped = true; }
          }
          if (_dragPart == 'p2' || _dragPart == 'body') {
            if ((Offset(_ruler!.x2, _ruler!.y2) - Offset(p.x, p.y)).distance < 30) { _ruler!.x2 = p.x; _ruler!.y2 = p.y; snapped = true; }
          }
        }
        if (snapped) { _playSound('snap'); _evaluateScenarioState(); }
      }
      _draggedEntity = null;
    });
  }

  // --- Dynamic Universal Point Validation Engine ---
  void _addPointIfNew(String id, Offset pt, Color c) {
    if (!_points.any((p) => p.id == id)) {
       String label = id == 'Y' ? (_currentScenario == 3 ? 'D' : _currentScenario == 4 ? 'H' : 'Y') : id;
       _points.add(GeoPoint(id: id, x: pt.dx, y: pt.dy, label: label, color: c));
       _showToast("Point $label marked!");
       _playSound('success');
    }
  }

  void _validateArcDrawing() {
    if (_compass == null) return;
    Offset cPt = Offset(_compass!.x, _compass!.y);
    double r = _compass!.radius;
    bool foundSomething = false;

    // Detect Intersection with Lines
    if (_currentScenario == 0) {
       if (_currentStep == 1 && (cPt - _points.firstWhere((p)=>p.id=='A').toOffset()).distance < 10) {
          var i1 = _intersectLineSegmentCircle(const Offset(-250,80), const Offset(-50,80), cPt, r);
          var i2 = _intersectLineSegmentCircle(const Offset(-250,80), const Offset(-120,-50), cPt, r);
          if (i1.isNotEmpty && i2.isNotEmpty) {
             _addPointIfNew('C', i1[0], Colors.indigoAccent);
             _addPointIfNew('B', i2[0], Colors.indigoAccent);
             foundSomething = true;
          } else { _showHint("Ensure your arc crosses BOTH arms."); }
       } else if (_currentStep == 3 && (cPt - _points.firstWhere((p)=>p.id=='X').toOffset()).distance < 10) {
          var i1 = _intersectLineSegmentCircle(const Offset(50,80), const Offset(350,80), cPt, r);
          if (i1.isNotEmpty) { _addPointIfNew('Z', i1[0], Colors.indigoAccent); foundSomething = true; }
       }
    } else if (_currentScenario == 1) {
       if (_scen1Step == 1 && (cPt - _points.firstWhere((p)=>p.id=='A').toOffset()).distance < 10) {
          var i1 = _intersectLineSegmentCircle(const Offset(220,0), const Offset(20,0), cPt, r);
          var i2 = _intersectLineSegmentCircle(const Offset(220,0), const Offset(320,100), cPt, r);
          if (i1.isNotEmpty && i2.isNotEmpty) {
             _addPointIfNew('C', i1[0], Colors.lightBlueAccent);
             _addPointIfNew('B', i2[0], Colors.lightBlueAccent);
             foundSomething = true;
          }
       } else if (_scen1Step == 3 && (cPt - _points.firstWhere((p)=>p.id=='X').toOffset()).distance < 10) {
          var i1 = _intersectLineSegmentCircle(const Offset(0,-50), const Offset(-200,-50), cPt, r);
          if (i1.isNotEmpty) { _addPointIfNew('Z', i1[0], Colors.lightBlueAccent); foundSomething = true; }
       }
    } else if (_currentScenario == 2) {
       if (_scen3Step == 3 && (cPt - _points.firstWhere((p)=>p.id=='B').toOffset()).distance < 10) {
          var ints = _intersectCircleCircle(const Offset(0,0), 120, cPt, r);
          Offset? ptC = ints.where((p) => (p - _points.firstWhere((p)=>p.id=='A').toOffset()).distance > 20).firstOrNull;
          if (ptC != null) { _addPointIfNew('C', ptC, Colors.lightBlueAccent); foundSomething = true; }
       }
    } else if (_currentScenario == 3) {
       if (_scen4Step == 1 && (cPt - _points.firstWhere((p)=>p.id=='V').toOffset()).distance < 10) {
          var i1 = _intersectLineSegmentCircle(const Offset(-250,270), const Offset(200,-180), cPt, r); // l
          var i2 = _intersectLineSegmentCircle(const Offset(-400,120), const Offset(400,120), cPt, r); // m
          if (i1.isNotEmpty && i2.isNotEmpty) {
             Offset? pA = i1.where((p)=>p.dy < 120).firstOrNull;
             Offset? pB = i2.where((p)=>p.dx > -100).firstOrNull;
             if (pA != null) _addPointIfNew('A', pA, Colors.lightBlueAccent);
             if (pB != null) _addPointIfNew('B', pB, Colors.lightBlueAccent);
             foundSomething = true;
          }
       } else if (_scen4Step == 3 && (cPt - _points.firstWhere((p)=>p.id=='P').toOffset()).distance < 10) {
          var i1 = _intersectLineSegmentCircle(const Offset(-250,270), const Offset(200,-180), cPt, r); // l
          Offset? pC = i1.where((p)=>p.dy < -30).firstOrNull;
          if (pC != null) { _addPointIfNew('C', pC, Colors.lightBlueAccent); foundSomething = true; }
       }
    } else if (_currentScenario == 4) {
       if (_scen5Step == 1 && (cPt - _points.firstWhere((p)=>p.id=='A').toOffset()).distance < 10) {
          var i1 = _intersectLineSegmentCircle(const Offset(-150,100), const Offset(-25,-116), cPt, r);
          var i2 = _intersectLineSegmentCircle(const Offset(-300,100), const Offset(300,100), cPt, r);
          if (i1.isNotEmpty && i2.isNotEmpty) {
             Offset pE = i1[0];
             Offset? pF = i2.where((p)=>p.dx > -150).firstOrNull;
             if (pF != null) {
               _addPointIfNew('E', pE, Colors.lightBlueAccent);
               _addPointIfNew('F', pF, Colors.lightBlueAccent);
               foundSomething = true;
             }
          }
       } else if (_scen5Step == 3 && (cPt - _points.firstWhere((p)=>p.id=='D').toOffset()).distance < 10) {
          var i1 = _intersectLineSegmentCircle(const Offset(-300,100), const Offset(300,100), cPt, r);
          Offset? pG = i1.where((p)=>p.dx < 150).firstOrNull;
          if (pG != null) { _addPointIfNew('G', pG, Colors.lightBlueAccent); foundSomething = true; }
       } else if (_currentStep == 1) { // 3 Arcs step
          Offset c1 = const Offset(-75, 100); Offset c2 = const Offset(75, 100); Offset c3 = const Offset(0, -30);
          if (r > 65 && r < 85) {
             if (!_cen1Done && (cPt - c1).distance < 20) { _cen1Done = true; _playSound('success'); foundSomething = true; }
             else if (!_cen2Done && (cPt - c2).distance < 20) { _cen2Done = true; _playSound('success'); foundSomething = true; }
             else if (!_cen3Done && (cPt - c3).distance < 20) { _cen3Done = true; _playSound('success'); foundSomething = true; }
             else { _arcs.removeLast(); _playSound('error'); _showHint("Snap exactly to a glowing center."); return; }
             _updateHUD();
             if (_cen1Done && _cen2Done && _cen3Done) {
                _scenarioCompleted = true; _playSound('success'); _updateHUD();
             }
          } else {
             _arcs.removeLast(); _playSound('error'); _showHint("Radius incorrect. Stretch pencil to point A or D."); _compass!.isLocked = false;
          }
       }
    }

    // Check Circle-Circle intersections globally for the final Y/D/H points
    if (_arcs.length > 1) {
       for (int i=0; i<_arcs.length-1; i++) {
          var a = _arcs[i];
          var ints = _intersectCircleCircle(Offset(a.x, a.y), a.radius, cPt, r);
          for (var pt in ints) {
             if (_currentScenario == 0 && _currentStep == 6) {
                Offset? yPt = ints.where((p) => p.dy < _points.firstWhere((p)=>p.id=='X').y).firstOrNull;
                if (yPt != null) { _addPointIfNew('Y', yPt, Colors.green); foundSomething = true; }
             } else if (_currentScenario == 1 && _scen1Step == 6) {
                Offset? yPt = ints.where((p) => p.dy > _points.firstWhere((p)=>p.id=='X').y).firstOrNull;
                if (yPt != null) { _addPointIfNew('Y', yPt, Colors.green); foundSomething = true; }
             } else if (_currentScenario == 3 && _scen4Step == 6) {
                Offset? yPt = ints.where((p) => p.dx > _points.firstWhere((p)=>p.id=='P').x).firstOrNull;
                if (yPt != null) { _addPointIfNew('Y', yPt, Colors.green); foundSomething = true; }
             } else if (_currentScenario == 4 && _scen5Step == 6) {
                Offset? yPt = ints.where((p) => p.dy < _points.firstWhere((p)=>p.id=='D').y).firstOrNull;
                if (yPt != null) { _addPointIfNew('Y', yPt, Colors.green); foundSomething = true; }
             }
          }
       }
    }

    if (!foundSomething && _currentStep != 1 && _currentScenario != 4) {
       _arcs.removeLast(); _playSound('error'); _showHint("Arc missed the target completely.");
    } else {
       _evaluateScenarioState();
    }
  }

  void _evaluateScenarioState() {
    if (_scenarioCompleted || _compass == null && _ruler == null) return;

    bool hasB = _points.any((p) => p.id == 'B');
    bool hasC = _points.any((p) => p.id == 'C');
    bool hasZ = _points.any((p) => p.id == 'Z');
    bool hasY = _points.any((p) => p.id == 'Y');

    if (_currentScenario == 0) {
       if (_currentStep == 0 && _compass != null && (_compass!.x - _points.firstWhere((p)=>p.id=='A').x).abs() < 10) { _advanceStep(); }
       else if (_currentStep == 1 && hasB && hasC) { _savedRadius1 = _compass!.radius; _compass!.isLocked = true; _advanceStep(); }
       else if (_currentStep == 2 && _compass != null && (_compass!.x - _points.firstWhere((p)=>p.id=='X').x).abs() < 10) { _advanceStep(); }
       else if (_currentStep == 3 && hasZ) { _compass!.isLocked = false; _advanceStep(); }
       else if (_currentStep == 4 && _compass!.isLocked) {
          GeoPoint b = _points.firstWhere((p) => p.id == 'B'); GeoPoint c = _points.firstWhere((p) => p.id == 'C');
          double tRad = (b.toOffset() - c.toOffset()).distance;
          if ((_compass!.radius - tRad).abs() < 10 && ((_compass!.x - b.x).abs() < 15 || (_compass!.x - c.x).abs() < 15)) {
             _savedRadius2 = _compass!.radius; _advanceStep();
          }
       } else if (_currentStep == 5 && _compass!.isLocked && (_compass!.x - _points.firstWhere((p)=>p.id=='Z').x).abs() < 10) { _advanceStep(); }
       else if (_currentStep == 6 && hasY) { _selectTool('ruler'); _advanceStep(); }
    } else if (_currentScenario == 1) {
       if (_scen1Step == 0 && _compass != null && (_compass!.x - _points.firstWhere((p)=>p.id=='A').x).abs() < 10) { _scen1Step = 1; _playSound('snap'); _updateHUD(); }
       else if (_scen1Step == 1 && hasB && hasC) { _scen1Step = 2; _playSound('success'); _updateHUD(); }
       else if (_scen1Step == 2 && _compass != null && (_compass!.x - _points.firstWhere((p)=>p.id=='X').x).abs() < 10) { _scen1Step = 3; _playSound('snap'); _updateHUD(); }
       else if (_scen1Step == 3 && hasZ) { _compass!.isLocked = false; _scen1Step = 4; _playSound('success'); _updateHUD(); }
       else if (_scen1Step == 4 && _compass!.isLocked) {
          GeoPoint b = _points.firstWhere((p) => p.id == 'B'); GeoPoint c = _points.firstWhere((p) => p.id == 'C');
          double tRad = (b.toOffset() - c.toOffset()).distance;
          if ((_compass!.radius - tRad).abs() < 10 && ((_compass!.x - b.x).abs() < 15 || (_compass!.x - c.x).abs() < 15)) {
             _savedRadius2 = _compass!.radius; _scen1Step = 5; _playSound('success'); _updateHUD();
          }
       } else if (_scen1Step == 5 && _compass!.isLocked && (_compass!.x - _points.firstWhere((p)=>p.id=='Z').x).abs() < 10) { _scen1Step = 6; _playSound('snap'); _updateHUD(); }
       else if (_scen1Step == 6 && hasY) { _selectTool('ruler'); _advanceStep(); }
    } else if (_currentScenario == 2) {
       if (_scen3Step == 0 && _compass != null && (_compass!.x - _points.firstWhere((p)=>p.id=='A').x).abs() < 10) { _scen3Step = 1; _playSound('snap'); _updateHUD(); }
       else if (_scen3Step == 1 && _compass!.isLocked) {
          GeoPoint b = _points.firstWhere((p) => p.id == 'B');
          Offset pen = Offset(_compass!.x + _compass!.radius*math.cos(_compass!.angle), _compass!.y + _compass!.radius*math.sin(_compass!.angle));
          if ((pen - b.toOffset()).distance < 15) { _savedRadius3 = _compass!.radius; _scen3Step = 2; _playSound('success'); _updateHUD(); }
       } else if (_scen3Step == 2 && _compass != null && (_compass!.x - _points.firstWhere((p)=>p.id=='B').x).abs() < 10) { _scen3Step = 3; _playSound('snap'); _updateHUD(); }
       else if (_scen3Step == 3 && hasC) { _selectTool('ruler'); _scen3Step = 4; _playSound('success'); _updateHUD(); }
       else if (_scen3Step == 4) {
          GeoPoint c = _points.firstWhere((p) => p.id == 'C');
          if(_ruler != null && ((math.sqrt(math.pow(_ruler!.x1-0,2)+math.pow(_ruler!.y1-0,2))<30 && math.sqrt(math.pow(_ruler!.x2-c.x,2)+math.pow(_ruler!.y2-c.y,2))<30) || (math.sqrt(math.pow(_ruler!.x2-0,2)+math.pow(_ruler!.y2-0,2))<30 && math.sqrt(math.pow(_ruler!.x1-c.x,2)+math.pow(_ruler!.y1-c.y,2))<30))) {
             _scen3Step = 5; _playSound('success'); setState((){}); _updateHUD();
          }
       }
    } else if (_currentScenario == 3) {
       if (_scen4Step == 0 && _compass != null && (_compass!.x - _points.firstWhere((p)=>p.id=='V').x).abs() < 10) { _scen4Step = 1; _playSound('snap'); _updateHUD(); }
       else if (_scen4Step == 1 && hasB) { _scen4Step = 2; _playSound('success'); _updateHUD(); }
       else if (_scen4Step == 2 && _compass != null && _compass!.isLocked && (_compass!.x - _points.firstWhere((p)=>p.id=='P').x).abs() < 10) { _scen4Step = 3; _playSound('snap'); _updateHUD(); }
       else if (_scen4Step == 3 && hasC) { _compass!.isLocked = false; _scen4Step = 4; _playSound('success'); _updateHUD(); }
       else if (_scen4Step == 4 && _compass!.isLocked) {
          GeoPoint aNode = _points.firstWhere((p) => p.id == 'A'); GeoPoint bNode = _points.firstWhere((p) => p.id == 'B');
          double tRad = (aNode.toOffset() - bNode.toOffset()).distance;
          if ((_compass!.radius - tRad).abs() < 10 && ((_compass!.x - aNode.x).abs() < 15 || (_compass!.x - bNode.x).abs() < 15)) {
             _savedRadius2 = _compass!.radius; _scen4Step = 5; _playSound('success'); _updateHUD();
          }
       } else if (_scen4Step == 5 && _compass!.isLocked && (_compass!.x - _points.firstWhere((p)=>p.id=='C').x).abs() < 10) { _scen4Step = 6; _playSound('snap'); _updateHUD(); }
       else if (_scen4Step == 6 && hasY) { _selectTool('ruler'); _scen4Step = 7; _playSound('success'); _updateHUD(); }
       else if (_scen4Step == 7) {
          GeoPoint d = _points.firstWhere((p) => p.id == 'Y'); GeoPoint pNode = _points.firstWhere((p) => p.id == 'P');
          if(_ruler != null && ((math.sqrt(math.pow(_ruler!.x1-pNode.x,2)+math.pow(_ruler!.y1-pNode.y,2))<30 && math.sqrt(math.pow(_ruler!.x2-d.x,2)+math.pow(_ruler!.y2-d.y,2))<30) || (math.sqrt(math.pow(_ruler!.x2-pNode.x,2)+math.pow(_ruler!.y2-pNode.y,2))<30 && math.sqrt(math.pow(_ruler!.x1-d.x,2)+math.pow(_ruler!.y1-d.y,2))<30))) {
             _scen4Step = 8; _playSound('success'); setState((){}); _updateHUD();
          }
       }
    } else if (_currentScenario == 4) {
       if (_scen5Step == 0 && _compass != null && (_compass!.x - _points.firstWhere((p)=>p.id=='A').x).abs() < 10) { _scen5Step = 1; _playSound('snap'); _updateHUD(); }
       else if (_scen5Step == 1 && _points.any((p)=>p.id=='F')) { _scen5Step = 2; _playSound('success'); _updateHUD(); }
       else if (_scen5Step == 2 && _compass != null && _compass!.isLocked && (_compass!.x - _points.firstWhere((p)=>p.id=='D').x).abs() < 10) { _scen5Step = 3; _playSound('snap'); _updateHUD(); }
       else if (_scen5Step == 3 && _points.any((p)=>p.id=='G')) { _compass!.isLocked = false; _scen5Step = 4; _playSound('success'); _updateHUD(); }
       else if (_scen5Step == 4 && _compass!.isLocked) {
          GeoPoint eNode = _points.firstWhere((p) => p.id == 'E'); GeoPoint fNode = _points.firstWhere((p) => p.id == 'F');
          double tRad = (eNode.toOffset() - fNode.toOffset()).distance;
          if ((_compass!.radius - tRad).abs() < 10 && ((_compass!.x - eNode.x).abs() < 15 || (_compass!.x - fNode.x).abs() < 15)) {
             _savedRadius2 = _compass!.radius; _scen5Step = 5; _playSound('success'); _updateHUD();
          }
       } else if (_scen5Step == 5 && _compass!.isLocked && (_compass!.x - _points.firstWhere((p)=>p.id=='G').x).abs() < 10) { _scen5Step = 6; _playSound('snap'); _updateHUD(); }
       else if (_scen5Step == 6 && hasY) { _selectTool('ruler'); _scen5Step = 7; _playSound('success'); _updateHUD(); }
       else if (_scen5Step == 7) {
          GeoPoint d = _points.firstWhere((p) => p.id == 'D'); GeoPoint hNode = _points.firstWhere((p) => p.id == 'Y');
          if(_ruler != null && ((math.sqrt(math.pow(_ruler!.x1-d.x,2)+math.pow(_ruler!.y1-d.y,2))<30 && math.sqrt(math.pow(_ruler!.x2-hNode.x,2)+math.pow(_ruler!.y2-hNode.y,2))<30) || (math.sqrt(math.pow(_ruler!.x2-d.x,2)+math.pow(_ruler!.y2-d.y,2))<30 && math.sqrt(math.pow(_ruler!.x1-hNode.x,2)+math.pow(_ruler!.y1-hNode.y,2))<30))) {
             _scen5Step = 8; _playSound('success'); setState((){}); _updateHUD();
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
      setState(() {
        _updateHUD();
      });
    }
  }

  void _drawLineAction() {
    if (_ruler == null) return;
    
    _playSound('draw');
    setState(() {
      double dx = _ruler!.x2 - _ruler!.x1;
      double dy = _ruler!.y2 - _ruler!.y1;
      _lines.add(GeoLine(id: 'drawn', p1: Offset(_ruler!.x1 - dx*0.2, _ruler!.y1 - dy*0.2), p2: Offset(_ruler!.x2 + dx*0.2, _ruler!.y2 + dy*0.2), color: Colors.green, width: 4));
      _ruler = null;

      if (_currentScenario == 0 || _currentScenario == 3) {
        _scenarioCompleted = true; _playSound('success'); _updateHUD();
      } else if (_currentScenario == 1) {
        _advanceStep();
      } else if (_currentScenario == 2) {
        _advanceStep();
      } else if (_currentScenario == 4) {
        _points.add(GeoPoint(id: 'Cen1', x: -75, y: 100, label: '', color: Colors.amber)..glow = true);
        _points.add(GeoPoint(id: 'Cen2', x: 75, y: 100, label: '', color: Colors.amber)..glow = true);
        _points.add(GeoPoint(id: 'Cen3', x: 0, y: -30, label: '', color: Colors.amber)..glow = true);
        if (_compass != null) _compass!.isLocked = false;
        _advanceStep();
      }
    });
  }

  void _placeBeamAction() {
    _playSound('pop');
    setState(() {
      _bridgeStabilized = true;
      _scenarioCompleted = true;
      _lines.add(GeoLine(id: 'beam', p1: const Offset(0, -50), p2: const Offset(-100, 50), color: Colors.grey, width: 8));
      _playSound('success');
      _updateHUD();
    });
  }

  void _repeatAction() {
    _playSound('pop');
    setState(() {
      for (int i=2; i<=8; i++) {
        double ang = i * (-math.pi/4);
        _lines.add(GeoLine(id: 'blade_$i', p1: const Offset(0,0), p2: Offset(120*math.cos(ang), 120*math.sin(ang)), color: Colors.lightBlue));
      }
      _scenarioCompleted = true;
      _playSound('success');
      _updateHUD();
    });
  }

  Offset _screenToWorld(Offset screenPos) {
    final Size size = MediaQuery.of(context).size;
    final double sidebarW = _isSidebarOpen ? size.width * 0.38 : 0;
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
    double sidebarWidth = screenWidth * 0.38;

    bool showDrawLineBtn = ((_currentScenario == 0 && _currentStep == 7) || 
                            (_currentScenario == 1 && _currentStep == 1) ||
                            (_currentScenario == 2 && _scen3Step == 5 && _ruler != null) ||
                            (_currentScenario == 3 && _scen4Step == 8 && _ruler != null) ||
                            (_currentScenario == 4 && _scen5Step == 8 && _ruler != null)) && !_scenarioCompleted;
                            
    bool showPlaceBeamBtn = _currentScenario == 1 && _currentStep == 2 && !_bridgeStabilized && !_scenarioCompleted;
    bool showRepeatBtn = _currentScenario == 2 && _currentStep == 1 && !_scenarioCompleted;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // Canvas Area
            Positioned(
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
                            scale: _scale,
                            panOffset: _panOffset,
                            points: _points,
                            lines: _lines,
                            arcs: _arcs,
                            tempArc: _tempArc,
                            compass: _compass,
                            ruler: _ruler,
                            scenario: _currentScenario,
                            bridgeStabilized: _bridgeStabilized,
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
                          if (_currentScenario < 4 || (_currentScenario == 4 && _currentStep == 0 && _scen5Step < 7) || (_currentScenario == 4 && _currentStep == 1))
                            _buildToolBtn(Icons.architecture, 'compass', _activeTool == 'compass'),
                          if (_currentScenario == 0 && _currentStep == 7 || _currentScenario == 1 && _currentStep == 1 || _currentScenario == 2 && _scen3Step >= 4 || _currentScenario == 3 && _scen4Step >= 7 || _currentScenario == 4 && _scen5Step >= 7 && _currentStep == 0)
                            const SizedBox(height: 8),
                          if (_currentScenario == 0 && _currentStep == 7 || _currentScenario == 1 && _currentStep == 1 || _currentScenario == 2 && _scen3Step >= 4 || _currentScenario == 3 && _scen4Step >= 7 || _currentScenario == 4 && _scen5Step >= 7 && _currentStep == 0)
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
                bottom: 80,
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    children: [
                      if (showDrawLineBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: () { HapticFeedback.lightImpact(); _drawLineAction(); },
                          icon: const Icon(Icons.straighten), label: Text(_i18n[_currentLang]!['btnDrawLine'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      if (showPlaceBeamBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: () { HapticFeedback.lightImpact(); _placeBeamAction(); },
                          icon: const Icon(Icons.build), label: Text(_i18n[_currentLang]!['btnPlaceBeam'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      if (showRepeatBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: () { HapticFeedback.lightImpact(); _repeatAction(); },
                          icon: const Icon(Icons.repeat), label: const Text("REPEAT ACTION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                    ],
                  ),
                ),
              ),

            // HUD Message Overlay
            if (!_showShutter)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isSidebarOpen ? sidebarWidth : 0, 
                right: 0, 
                bottom: 20,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                    ),
                    child: _scenarioCompleted 
                       ? Row(mainAxisSize: MainAxisSize.min, children: [
                           const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8),
                           Flexible(child: Text(_hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold))),
                         ])
                       : Text(_hudMessage, textAlign: TextAlign.center, style: TextStyle(color: _hudColor == Colors.white ? Colors.black87 : _hudColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

            // Sidebar (Fully Scrollable)
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
                      padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
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
                            items: List.generate(5, (index) {
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
                    
                    // Footer
                    Container(
                      padding: const EdgeInsets.all(12), color: Colors.black26, width: double.infinity, 
                      child: Text(_i18n[_currentLang]!['footer'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))
                    )
                  ],
                ),
              ),
            ),

            // Top-Left Fixed Action Row (Menu icon only)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.white,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound('click');
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // Localization Data
  final Map<String, Map<String, dynamic>> _i18n = {
    'en': {
      'title': "The Angle Cloner: Mastering Angle Replication",
      'subtitle': "Class 7 • CONSTRUCTIONS AND TILINGS",
      'selectScenario': "Select Scenario",
      'missionObj': "Mission Objective",
      'hudDefault': "Select a scenario to begin.",
      'btnDrawLine': "DRAW LINE",
      'btnPlaceBeam': "PLACE BEAM",
      'enterLab': "Enter Virtual Lab",
      'footer': "© ZEROSCIENCELAB | Fall in Love with Math and Science",
      'scenarios': [
        {
          'title': "1. The Blueprint Match",
          'objective': "Learn the fundamental steps of copying an acute angle by following a guided blueprint.",
          'steps': [
            {'text': "A source angle, ∠A, is shown on the left. On the right is a target line. **DRAG** the compass point and snap it onto vertex A of the source angle.", 'hud': "Drag compass and snap it to vertex A."},
            {'text': "**DRAG** the pencil end of the compass to draw an arc that intersects both arms of ∠A. Use the padlock to lock/unlock radius. Name intersection points B and C.", 'hud': "Drag pencil end to draw an arc crossing both arms."},
            {'text': "Now, let's replicate this on the target line. **DRAG** the compass (locked radius) and snap its point onto vertex X on the target line.", 'hud': "Drag compass pivot to target vertex X."},
            {'text': "**DRAG** the pencil end to draw an arc of the same size. Name the intersection point Z.", 'hud': "Drag pencil end to draw a matching arc from X."},
            {'text': "Time to measure the angle's \"opening\". **UNLOCK** the compass, **DRAG** point to B, and **ADJUST** radius to snap exactly to C.", 'hud': "Unlock radius, snap pivot to B, adjust radius to C."},
            {'text': "**LOCK** the compass radius again. **DRAG** the compass and snap its point onto point Z on the new arc.", 'hud': "Lock radius. Drag compass and snap pivot to Z."},
            {'text': "**DRAG** the pencil end to draw an arc that intersects the first arc. This is point Y.", 'hud': "Draw a small arc crossing the previous one."},
            {'text': "The final step! Click the Ruler tool. **DRAG** it to connect points X and Y. Click the **DRAW LINE** button.", 'hud': "Use Ruler to connect X and Y, then DRAW LINE."}
          ]
        },
        {
          'title': "2. The Truss Bridge",
          'objective': "Apply the angle copying skill to replicate an obtuse angle needed to complete a symmetrical bridge truss.",
          'steps': [
            {'text': "A bridge design is shown with one side complete. The other side is missing a diagonal beam. The obtuse angle for the beam is shown. USE the Compass to copy the obtuse angle from the 'Source Angle' to the 'Target Vertex' on the bridge.", 'hud': "Copy the blueprint angle to the target vertex on the bridge."},
            {'text': "**Align the Ruler and Draw Line:** Use the Ruler tool from the toolbox. Snap it onto points X and Y, then click the green **DRAW LINE** button.", 'hud': "Select the Ruler tool and connect points X and Y."},
            {'text': "**Place the Beam:** Finally, click the amber **PLACE BEAM** button to drop the steel truss into place and stabilize the bridge!", 'hud': "Click PLACE BEAM to complete the bridge truss."}
          ],
          'hud_hints': [
            "Drag compass and snap it to vertex A.",
            "Drag pencil end to draw an arc crossing both arms.",
            "Drag compass pivot to target vertex X.",
            "Drag pencil end to draw a matching arc from X.",
            "Unlock radius, snap pivot to B, adjust radius to C.",
            "Lock radius. Drag compass and snap pivot to Z.",
            "Drag pencil end to draw a small arc to find point Y."
          ]
        },
        {
          'title': "3. The Fan Pattern",
          'objective': "Create a repeating radial pattern by copying a source angle multiple times around a central point.",
          'steps': [
            {'text': "Your mission is to create a full 8-bladed fan. COPY the given angle AOB, using the end of the previous blade (B) as the start of your next one to find C.", 'hud': "Copy the angle to build the fan."},
            {'text': "CLICK the **REPEAT ACTION** button to automatically complete the rest of the fan.", 'hud': "Finally, click 'REPEAT ACTION' to auto-construct!"}
          ],
          'hud_hints': [
            "Measure the blade width: Select the Compass, snap the sharp pivot point to A.",
            "Unlock radius, stretch the pencil end and snap onto B.",
            "Lock radius. Transfer the measurement: snap pivot onto B.",
            "Find the next point: Draw a small arc upwards until it intersects the guide circle. Point C.",
            "Draw the line: Select the Ruler. Align its two blue ends between the center point O and your new point C.",
            "Finish the blade: A green 'DRAW LINE' button will appear. Click it to complete the second blade."
          ]
        },
        {
          'title': "4. The Parallel Path",
          'objective': "Use your knowledge of angle copying to construct a line parallel to a given line, passing through a specific point.",
          'steps': [
            {'text': "You are given line 'm', point 'P', and transversal 'l' that passes through P and intersects 'm' at V. To create a parallel line through P, you must create an equal corresponding angle. USE the tools to copy the angle formed by the intersection of 'm' and 'l' to the point P.", 'hud': "Construct a corresponding angle at P."}
          ],
          'hud_hints': [
            "Challenge Step: Drag compass and snap pivot to vertex V.",
            "Draw a reference arc that intersects both lines.",
            "Transfer Radius: Drag compass and snap to point P.",
            "Use locked radius to draw the same arc from point P.",
            "Measure chord: Unlock radius, snap compass pivot to point A, stretch pencil to point B.",
            "Copy chord: Lock radius, drag compass to intersection C on line l.",
            "Draw a small arc to intersect your previous arc. This is point D.",
            "Select Ruler and align it between P and point D.",
            "Click 'DRAW LINE' to verify your parallel line!"
          ]
        },
        {
          'title': "5. The Archway Design",
          'objective': "Complete a symmetrical Trefoil Arch by copying the angle of the support lines.",
          'steps': [
            {'text': "To ensure the arch is symmetrical, the right support line must be at the same angle as the left. COPY the angle ∠BAD to vertex D to create the support line for the right side.", 'hud': "Copy ∠BAD to point D using your tools."},
            {'text': "Once the support line is correct, the arch centers will appear. USE the compass to draw the three decorative arcs.", 'hud': "Snap compass to the glowing centers to draw the Trefoil Arch."}
          ],
          'hud_hints': [
            "Challenge: Copy ∠BAD to D. Start by snapping Compass to A.",
            "Draw a reference arc across both arms of ∠A to get points E and F.",
            "Drag compass (locked radius) and snap to point D.",
            "Draw the same arc from D to get point G.",
            "Measure chord: Unlock radius, snap compass pivot to E and stretch pencil to F.",
            "Lock radius. Drag compass and snap pivot to G.",
            "Draw a small arc to intersect your previous arc (creates Point H).",
            "Select Ruler and align it between D and H.",
            "Click 'DRAW LINE' to build the right support!",
            "Right support built! Snap compass to any glowing center.",
            "Stretch pencil to point A, B, C, or D to measure arch radius.",
            "Draw an arc to form a section of the trefoil.",
            "Snap compass to another glowing center.",
            "Draw another arc for the trefoil shape.",
            "Snap compass to the final glowing center.",
            "Draw the final top arc to complete the design!"
          ]
        }
      ]
    },
    'hi': {
      'title': "कोण क्लोनर: कोण प्रतिकृति में महारत",
      'subtitle': "कक्षा 7 • संरचनाएं और टिलिंग",
      'selectScenario': "परिदृश्य चुनें",
      'missionObj': "मिशन का उद्देश्य",
      'hudDefault': "शुरू करने के लिए एक परिदृश्य चुनें।",
      'btnDrawLine': "रेखा खींचें",
      'btnPlaceBeam': "बीम रखें",
      'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'footer': "© ZEROSCIENCELAB | Fall in Love with Math and Science",
      'scenarios': [
        {
          'title': "1. ब्लूप्रिंट मैच",
          'objective': "निर्देशित ब्लूप्रिंट का पालन करके एक न्यून कोण की प्रतिलिपि बनाने के मूलभूत चरण सीखें।",
          'steps': [
            {'text': "बाईं ओर एक स्रोत कोण, ∠A दिखाया गया है। प्रकार के बिंदु को **खींचें** और उसे शीर्ष A पर रखें।", 'hud': "प्रकार को खींचें और शीर्ष A पर रखें।"},
            {'text': "दोनों भुजाओं को काटने वाला चाप खींचने के लिए प्रकार के पेंसिल सिरे को **खींचें**। त्रिज्या को लॉक/अनलॉक करने के लिए पैडलॉक का उपयोग करें।", 'hud': "दोनों भुजाओं को काटने के लिए पेंसिल सिरे को खींचें।"},
            {'text': "अब, इसे लक्ष्य रेखा पर दोहराते हैं। प्रकार को **खींचें** (लॉक त्रिज्या) और इसके बिंदु को शीर्ष X पर रखें।", 'hud': "प्रकार को लक्ष्य शीर्ष X पर खींचें।"},
            {'text': "उसी आकार का चाप खींचने के लिए पेंसिल सिरे को **खींचें**।", 'hud': "X से चाप खींचने के लिए पेंसिल सिरे को खींचें।"},
            {'text': "त्रिज्या को **अनलॉक** करें, बिंदु को B पर **खींचें**, और त्रिज्या को C तक **समायोजित** करें।", 'hud': "त्रिज्या को अनलॉक करें, B पर रखें, C तक समायोजित करें।"},
            {'text': "प्रकार त्रिज्या को फिर से **लॉक** करें। प्रकार को **खींचें** और Z पर रखें।", 'hud': "त्रिज्या लॉक करें। प्रकार को Z पर रखें।"},
            {'text': "पहले चाप को काटने वाला चाप खींचने के लिए पेंसिल सिरे को **खींचें**। यह Y है।", 'hud': "पहले चाप को काटने वाला चाप खींचें।"},
            {'text': "अंतिम चरण! रूलर टूल चुनें। इसे X और Y को जोड़ने के लिए **खींचें**। फिर **रेखा खींचें** पर क्लिक करें।", 'hud': "X और Y को जोड़ने के लिए रूलर का उपयोग करें, फिर 'रेखा खींचें'।" }
          ]
        },
        {
          'title': "2. ट्रस ब्रिज",
          'objective': "सममित पुल ट्रस को पूरा करने के लिए आवश्यक अधिक कोण की प्रतिलिपि बनाने के लिए कोण प्रतिकृति कौशल लागू करें।",
          'steps': [
            {'text': "एक पुल डिजाइन में एक विकर्ण बीम गायब है। आवश्यक अधिक कोण ब्लूप्रिंट पर दिखाया गया है। 'स्रोत कोण' से पुल पर 'लक्ष्य शीर्ष' तक कोण की प्रतिलिपि बनाने के लिए प्रकार और रूलर का उपयोग करें।", 'hud': "ब्लूप्रिंट कोण को पुल पर लक्ष्य शीर्ष पर कॉपी करें।"},
            {'text': "**रूलर को संरेखित करें और रेखा खींचें:** रूलर टूल का उपयोग करें। इसे X और Y पर स्नैप करें, फिर **रेखा खींचें** पर क्लिक करें।", 'hud': "रूलर टूल चुनें और बिंदु X और Y को जोड़ें।"},
            {'text': "**बीम रखें:** अंत में, पुल को स्थिर करने के लिए **बीम रखें** बटन पर क्लिक करें!", 'hud': "पुल ट्रस को पूरा करने के लिए 'बीम रखें' पर क्लिक करें।"}
          ],
          'hud_hints': [
            "प्रकार को खींचें और शीर्ष A पर रखें।",
            "दोनों भुजाओं को काटने के लिए पेंसिल सिरे को खींचें।",
            "त्रिज्या बदले बिना प्रकार को लक्ष्य शीर्ष X पर खींचें।",
            "X से चाप खींचने के लिए पेंसिल सिरे को खींचें।",
            "त्रिज्या को अनलॉक करें, B पर रखें, C तक समायोजित करें।",
            "त्रिज्या लॉक करें। प्रकार को Z पर रखें।",
            "बिंदु Y खोजने के लिए एक छोटा चाप खींचें।"
          ]
        },
        {
          'title': "3. फैन पैटर्न",
          'objective': "केंद्रीय बिंदु के चारों ओर कई बार स्रोत कोण की प्रतिलिपि बनाकर एक दोहराने वाला रेडियल पैटर्न बनाएं।",
          'steps': [
            {'text': "आपका मिशन एक पूर्ण 8-ब्लेड वाला पंखा बनाना है। दिए गए कोण AOB की प्रतिलिपि बनाएँ, अपने अगले ब्लेड (C) को खोजने के लिए पिछले ब्लेड (B) के अंत का उपयोग करें।", 'hud': "प्रकार चुनें, नुकीले बिंदु को A पर रखें।"},
            {'text': "पंखे को स्वचालित रूप से पूरा करने के लिए **कार्रवाई दोहराएं** बटन पर क्लिक करें।", 'hud': "पंखे को पूरा करने के लिए 'कार्रवाई दोहराएं' पर क्लिक करें।"}
          ],
          'hud_hints': [
            "ब्लेड की चौड़ाई मापें: प्रकार चुनें, नुकीले बिंदु को A पर रखें...",
            "त्रिज्या को अनलॉक करें और पेंसिल के सिरे को B पर स्नैप करें।",
            "त्रिज्या लॉक करें। प्रकार को B पर रखें।",
            "अगला बिंदु खोजें: गाइड सर्कल को काटते हुए एक छोटा चाप ऊपर की ओर खींचें। यह बिंदु C है।",
            "रेखा खींचें: रूलर चुनें और इसे केंद्र बिंदु O और अपने नए बिंदु C के बीच संरेखित करें।",
            "दूसरा ब्लेड पूरा करने के लिए हरे 'रेखा खींचें' बटन पर क्लिक करें।"
          ]
        },
        {
          'title': "4. समानांतर पथ",
          'objective': "किसी विशिष्ट बिंदु से गुजरने वाली दी गई रेखा के समानांतर एक रेखा बनाने के लिए कोण प्रतिकृति के अपने ज्ञान का उपयोग करें।",
          'steps': [
            {'text': "आपको रेखा 'm', बिंदु 'P' और तिर्यक रेखा 'l' दी गई है। P से होकर एक समानांतर रेखा बनाने के लिए, आपको एक समान संगत कोण बनाना চরম करें।", 'hud': "समानांतर रेखा बनाने के लिए P पर एक संगत कोण बनाएँ।"}
          ],
          'hud_hints': [
            "चरण 1: प्रकार को खींचें और बिंदु V पर रखें।",
            "एक संदर्भ चाप खींचें जो दोनों रेखाओं को काटता हो।",
            "चरण 2: प्रकार को (लॉक त्रिज्या) बिंदु P पर ले जाएँ।",
            "बिंदु P से समान चाप खींचने के लिए लॉक त्रिज्या का उपयोग करें।",
            "चरण 4: त्रिज्या अनलॉक करें, बिंदु A पर स्नैप करें, पेंसिल को B पर स्नैप करें।",
            "चरण 5: त्रिज्या लॉक करें, प्रकार को C पर ले जाएँ।",
            "पिछले चाप को काटने के लिए एक छोटा चाप खींचें। यह बिंदु D है।",
            "चरण 6: चुनौती पूरी हुई। रूलर को P और D के बीच संरेखित करें।",
            "समानांतर रेखा को पूरा करने के लिए 'रेखा खींचें' पर क्लिक करें!"
          ]
        },
        {
          'title': "5. मेहराब डिजाइन",
          'objective': "समर्थन रेखाओं के कोण की प्रतिलिपि बनाकर एक सममित ट्रेफ़ोइल मेहराब को पूरा करें।",
          'steps': [
            {'text': "यह सुनिश्चित करने के लिए कि मेहराब सममित है, दाहिनी समर्थन रेखा बायीं रेखा के समान कोण पर होनी चाहिए। दाईं ओर के लिए समर्थन रेखा बनाने के लिए कोण ∠BAD को शीर्ष D पर कॉपी करें।", 'hud': "अपने उपकरणों का उपयोग करके ∠BAD को बिंदु D पर कॉपी करें।"},
            {'text': "एक बार समर्थन रेखा सही होने पर, मेहराब केंद्र दिखाई देंगे। तीन सजावटी चाप खींचने के लिए प्रकार का उपयोग करें।", 'hud': "ट्रेफ़ोइल मेहराब खींचने के लिए चमकते केंद्रों पर प्रकार को रखें।"}
          ],
          'hud_hints': [
            "चुनौती: ∠BAD को D पर कॉपी करें। प्रकार को A पर स्नैप करके प्रारंभ करें।",
            "बिंदु E और F प्राप्त करने के लिए ∠A की दोनों भुजाओं पर एक संदर्भ चाप खींचें।",
            "प्रकार (लॉक त्रिज्या) को खींचें और बिंदु D पर स्नैप करें।",
            "बिंदु G प्राप्त करने के लिए D से समान चाप खींचें।",
            "जीवा मापें: त्रिज्या अनलॉक करें, बिंदु को E पर रखें और पेंसिल को F तक खींचें।",
            "त्रिज्या लॉक करें। प्रकार को बिंदु G पर स्नैप करें।",
            "पिछले चाप को काटने के लिए एक छोटा चाप खींचें (बिंदु H)।",
            "रूलर का चयन करें और इसे D और H के बीच संरेखित करें।",
            "दायां समर्थन बनाने के लिए 'रेखा खींचें' पर क्लिक करें!",
            "दायां समर्थन बन गया! प्रकार को किसी भी चमकते केंद्र पर स्नैप करें।",
            "मेहराब त्रिज्या मापने के लिए पेंसिल को A, B, C, या D बिंदु तक खींचें।",
            "ट्रेफ़ोइल का एक भाग बनाने के लिए एक चाप खींचें।",
            "प्रकार को दूसरे चमकते केंद्र पर स्नैप करें।",
            "ट्रेफ़ोइल आकार के लिए एक और चाप खींचें।",
            "प्रकार को अंतिम चमकते केंद्र पर स्नैप करें।",
            "डिजाइन को पूरा करने के लिए अंतिम शीर्ष चाप खींचें!"
          ]
        }
      ]
    }
  };
}

// Geometry Classes
class GeoPoint {
  String id; double x; double y; String label; Color color; bool glow;
  GeoPoint({required this.id, required this.x, required this.y, this.label = '', this.color = Colors.blue, this.glow = false});
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

// Canvas Painter
class CanvasPainter extends CustomPainter {
  final double scale;
  final Offset panOffset;
  final List<GeoPoint> points;
  final List<GeoLine> lines;
  final List<GeoArc> arcs;
  final GeoArc? tempArc;
  final CompassTool? compass;
  final RulerTool? ruler;
  final int scenario;
  final bool bridgeStabilized;
  final double pulseValue;
  final bool scenarioCompleted;

  CanvasPainter({
    required this.scale,
    required this.panOffset,
    required this.points,
    required this.lines,
    required this.arcs,
    this.tempArc,
    this.compass,
    this.ruler,
    required this.scenario,
    required this.bridgeStabilized,
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

    if (scenario == 1) {
      Paint bridgePaint = Paint()..color = Colors.grey[700]!..strokeWidth = 8..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
      Paint bridgeBlue = Paint()..color = bridgeStabilized ? Colors.green : Colors.indigo..strokeWidth = 6..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
      
      canvas.drawRect(const Rect.fromLTWH(-320, 50, 40, 20), bridgePaint);
      canvas.drawRect(const Rect.fromLTWH(80, 50, 40, 20), bridgePaint);
      
      canvas.drawLine(const Offset(-300, 50), const Offset(100, 50), bridgeBlue);
      canvas.drawLine(const Offset(-200, -50), const Offset(0, -50), bridgeBlue);
      
      Path zigZag = Path()..moveTo(-300, 50)..lineTo(-200, -50)..lineTo(-100, 50)..lineTo(0, -50);
      canvas.drawPath(zigZag, Paint()..style=PaintingStyle.stroke..color=bridgeBlue.color..strokeWidth=6..strokeJoin=StrokeJoin.round);
      
      canvas.drawLine(const Offset(-200, -50), const Offset(-200, 50), bridgeBlue);
      canvas.drawLine(const Offset(-100, -50), const Offset(-100, 50), bridgeBlue);
      canvas.drawLine(const Offset(0, -50), const Offset(0, 50), bridgeBlue);
      
      if (!bridgeStabilized) {
        Paint dashPaint = Paint()..color = Colors.grey..strokeWidth = 4..style = PaintingStyle.stroke;
        double dx = 100, dy = 100;
        double dist = math.sqrt(dx*dx + dy*dy);
        for(double i=0; i<dist; i+=16) {
          canvas.drawLine(Offset(0 + i*(dx/dist), -50 + i*(dy/dist)), Offset(0 + math.min(i+8, dist)*(dx/dist), -50 + math.min(i+8, dist)*(dy/dist)), dashPaint);
        }
      }
    }

    // Draw Lines
    for (var l in lines) {
      if (l.width > 0) { // Skip hidden validation lines
         canvas.drawLine(l.p1, l.p2, Paint()..color = l.color..strokeWidth = l.width..strokeCap = StrokeCap.round);
      }
    }

    // Draw Arcs
    for (var a in arcs) {
      Paint arcPaint = Paint()..color = a.color..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawArc(Rect.fromCircle(center: Offset(a.x, a.y), radius: a.radius), a.startAngle, a.sweepAngle, false, arcPaint);
      Paint fillPaint = Paint()..color = a.color.withOpacity(0.1)..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: Offset(a.x, a.y), radius: a.radius), a.startAngle, a.sweepAngle, true, fillPaint);
    }

    // Draw Temp Arc
    if (tempArc != null) {
      Paint arcPaint = Paint()..color = tempArc!.color.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawArc(Rect.fromCircle(center: Offset(tempArc!.x, tempArc!.y), radius: tempArc!.radius), tempArc!.startAngle, tempArc!.sweepAngle, false, arcPaint);
      Paint fillPaint = Paint()..color = tempArc!.color.withOpacity(0.1)..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: Offset(tempArc!.x, tempArc!.y), radius: tempArc!.radius), tempArc!.startAngle, tempArc!.sweepAngle, true, fillPaint);
    }

    // --- HIGHLIGHTS FOR COMPLETED SCENARIOS ---
    if (scenarioCompleted) {
      if (scenario == 2) { // Fan Pattern
        Paint fanGlow = Paint()
            ..color = Colors.lightBlueAccent.withOpacity(0.5 * pulseValue)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        for (int i=0; i<=8; i++) {
           double ang = i * (-math.pi/4);
           canvas.drawLine(const Offset(0,0), Offset(120*math.cos(ang), 120*math.sin(ang)), fanGlow);
        }
      } else if (scenario == 3) { // Parallel Path
        Paint parallelGlow = Paint()
            ..color = Colors.greenAccent.withOpacity(0.4 + (0.2 * pulseValue))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawLine(const Offset(-400, 120), const Offset(400, 120), parallelGlow);
        var drawnLine = lines.where((l) => l.id == 'drawn').firstOrNull;
        if (drawnLine != null) {
            canvas.drawLine(drawnLine.p1, drawnLine.p2, parallelGlow);
        }
      } else if (scenario == 4) { // Archway
        Paint archGlow = Paint()
            ..color = Colors.amberAccent.withOpacity(0.4 + (0.2 * pulseValue))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
            
        var drawnLine = lines.where((l) => l.id == 'drawn').firstOrNull;
        if (drawnLine != null) canvas.drawLine(drawnLine.p1, drawnLine.p2, archGlow);
        canvas.drawLine(const Offset(-150, 100), const Offset(-25, -116), archGlow);
        
        for (var a in arcs) {
           canvas.drawArc(Rect.fromCircle(center: Offset(a.x, a.y), radius: a.radius), a.startAngle, a.sweepAngle, false, archGlow);
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
        tp.paint(canvas, Offset(p.x - tp.width/2, p.y - 25));
      }
    }

    // Draw Ruler
    if (ruler != null) {
      canvas.save();
      double dx = ruler!.x2 - ruler!.x1;
      double dy = ruler!.y2 - ruler!.y1;
      double dist = math.sqrt(dx*dx + dy*dy);
      double angle = math.atan2(dy, dx);
      canvas.translate(ruler!.x1, ruler!.y1);
      canvas.rotate(angle);
      
      Paint rulerPaint = Paint()..color = Colors.indigoAccent.withOpacity(0.3)..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, -20, dist, 40), const Radius.circular(6)), rulerPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, -20, dist, 40), const Radius.circular(6)), Paint()..color=Colors.indigoAccent..style=PaintingStyle.stroke..strokeWidth=2);
      
      Paint tickPaint = Paint()..color = Colors.white;
      for(double i=10; i<dist-10; i+=10) {
        canvas.drawRect(Rect.fromLTWH(i, -20, 2, i%50==0 ? 15 : 8), tickPaint);
      }
      
      canvas.drawCircle(const Offset(0, 0), 10, Paint()..color=Colors.indigo);
      canvas.drawCircle(Offset(dist, 0), 10, Paint()..color=Colors.indigo);
      canvas.drawCircle(const Offset(0, 0), 4, Paint()..color=Colors.white);
      canvas.drawCircle(Offset(dist, 0), 4, Paint()..color=Colors.white);
      canvas.restore();
    }

    // Draw Compass
    if (compass != null) {
      canvas.save();
      canvas.translate(compass!.x, compass!.y);
      canvas.rotate(compass!.angle);
      
      double r = math.max(10.0, compass!.radius);
      double L = math.max(140.0, r * 1.2 + 20);
      double hx = r / 2;
      double hy = -math.sqrt(L * L - hx * hx);

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

      if (compass!.isLocked) {
        Paint lockedPaint = Paint()..color = Colors.green.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2;
        canvas.drawCircle(Offset(compass!.x, compass!.y), compass!.radius, lockedPaint);
      } else {
        // Unlocked / Measurement line visual indicator
        Paint measurePaint = Paint()..color = Colors.redAccent.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 2;
        canvas.drawCircle(Offset(compass!.x, compass!.y), compass!.radius, measurePaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}