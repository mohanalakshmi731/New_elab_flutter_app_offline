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
    home: ConstructingRegularHexagonsand60Angles(),
  ));
}

class ConstructingRegularHexagonsand60Angles extends StatefulWidget {
  const ConstructingRegularHexagonsand60Angles({Key? key}) : super(key: key);

  @override
  State<ConstructingRegularHexagonsand60Angles> createState() => _ConstructingRegularHexagonsand60AnglesState();
}

class _ConstructingRegularHexagonsand60AnglesState extends State<ConstructingRegularHexagonsand60Angles> with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showShutter = true;
  String _currentLang = 'en';
  int _currentScenario = 0;
  
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3'; 
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _panOffset = Offset.zero;
  Size _canvasSize = Size.zero;
  
  String? _activeTool;
  List<GeoPoint> _points = [];
  List<GeoLine> _lines = [];
  List<GeoArc> _arcs = [];
  CompassTool? _compass;
  
  dynamic _draggedEntity;
  String _dragPart = '';
  Offset? _dragStartPos;
  Offset _initialEntityPos = Offset.zero;
  
  bool _isDrawingCircle = false;
  Offset _circleCenter = Offset.zero;
  double _drawingRadius = 0;

  int _currentStep = 0;
  bool _scenarioCompleted = false;

  String _hudMessage = '';
  Color _hudColor = Colors.white; 
  Timer? _hintTimer;

  String _toastMessage = '';
  double _toastOpacity = 0.0;
  Timer? _toastTimer;

  late AnimationController _pulseController;
  late AnimationController _arcAnimController;
  late AnimationController _centerAnimController;
  GeoArc? _animatingArc;
  
  Offset _floatingStepPos = const Offset(20, 80);

  // Scenario 0 State
  Offset _s0_A = const Offset(-100, 50);
  Offset _s0_X = const Offset(100, 50);
  Offset _s0_C = Offset.zero;
  bool _s0_stickPlaced = false;
  bool _s0_compassSpawned = false;
  bool _s0_arc1Drawn = false;
  bool _s0_arc2Drawn = false;
  bool _s0_triangleComplete = false;
  bool _s0_lineAC = false;
  bool _s0_lineXC = false;
  GeoPoint? _s0_selectedPointForLine;
  Offset _s0_stickPos = const Offset(-200, -150);

  // Scenario 1 State
  double _s1_R = 120; // Side length of hexagon and equilateral triangles
  int _s1_placed = 0;
  double _s1_animProgress = 0;
  List<Map<String, dynamic>> _s1_slots = [];
  Offset _s1_activeTriPos = const Offset(-270, 150);
  double _s1_activeTriRot = 0;

  // Scenario 2 State
  Offset _s2_O = const Offset(0, 0);
  double _s2_circleR = 150;
  bool _s2_circleDrawn = false;
  bool _s2_A_placed = false;
  bool _s2_measuredOA = false;
  double _s2_A_angle = 0;
  List<GeoPoint> _s2_pts = [];
  GeoPoint? _s2_selectedPointForLine;
  bool _s2_hexComplete = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    
    _arcAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _arcAnimController.addListener(() {
      setState(() {});
    });

    _centerAnimController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _centerAnimController.addListener(() {
      setState(() {});
    });

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
    _arcAnimController.dispose();
    _centerAnimController.dispose();
    super.dispose();
  }

  void _fitToScreen() {
    if (!mounted) return;
    double minX = -400, maxX = 400, minY = -300, maxY = 300;

    if (_currentScenario == 0) { minX = -200; maxX = 200; minY = -200; maxY = 200; }
    else if (_currentScenario == 1) { minX = -380; maxX = 250; minY = -250; maxY = 250; }
    else if (_currentScenario == 2) { minX = -250; maxX = 250; minY = -200; maxY = 200; }

    double paddingX = 120;
    double paddingY = 120;
    double contentW = math.max(maxX - minX, 100);
    double contentH = math.max(maxY - minY, 100);
    
    final size = MediaQuery.sizeOf(context);
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
    _animatingArc = null;
    _points.clear();
    _lines.clear();
    _arcs.clear();
    _hudColor = Colors.white;

    if (index == 0) {
      _s0_A = const Offset(-100, 50); _s0_X = const Offset(100, 50); _s0_C = Offset(0, 50 - 200 * math.sin(math.pi/3));
      _s0_stickPlaced = false; _s0_compassSpawned = false; _s0_arc1Drawn = false; _s0_arc2Drawn = false; _s0_triangleComplete = false;
      _s0_lineAC = false; _s0_lineXC = false; _s0_selectedPointForLine = null;
      _s0_stickPos = const Offset(-200, -150);
    } else if (index == 1) {
      _s1_placed = 0; _s1_animProgress = 0; _s1_slots.clear();
      double centroidDist = _s1_R * math.sqrt(3) / 3;
      for(int i=0; i<6; i++) {
        double theta = i * math.pi/3 + math.pi/6;
        _s1_slots.add({ 
           'cx': centroidDist * math.cos(theta), 
           'cy': centroidDist * math.sin(theta), 
           'ang': theta + 3 * math.pi / 2, 
           'filled': false 
        });
      }
      _s1_activeTriPos = const Offset(-270, 150);
      _s1_activeTriRot = 0;
      _centerAnimController.reset();
    } else if (index == 2) {
      _s2_O = const Offset(0, 0); _s2_circleR = 150; _s2_circleDrawn = false; _s2_A_placed = false; _s2_measuredOA = false;
      _s2_pts.clear(); _s2_selectedPointForLine = null; _s2_hexComplete = false;
      _points.add(GeoPoint(id: 'O', x: 0, y: 0, label: 'O', color: Colors.amber, glow: true, offsetY: 25));
    }
    
    _fitToScreen();
    _updateHUD();
  }

  void _updateHUD() {
    if (_scenarioCompleted) {
      _hudMessage = _currentLang == 'hi' ? "शाबाश! आपने यह निर्माण सफलतापूर्वक पूरा कर लिया है।" : "Mission: Achieved! Great job completing this construction.";
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
        _compass ??= CompassTool(x: -150, y: -150, radius: 100, angle: 0, isLocked: false);
      } else if (tool == 'circle') {
        _compass = null;
      } else if (tool == 'ruler') {
        _compass = null;
      }
    });
  }

  // Translates GestureDetector's local position to Canvas World position precisely
  Offset _getCanvasPos(Offset localPos) {
    if (_canvasSize == Size.zero) return Offset.zero;
    double cx = localPos.dx - _canvasSize.width / 2 - _panOffset.dx;
    double cy = localPos.dy - _canvasSize.height / 2 - _panOffset.dy;
    return Offset(cx / _scale, cy / _scale);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _scale;
    
    if (details.pointerCount >= 2) {
      _draggedEntity = null;
      _dragPart = '';
      return;
    }

    final Offset worldPos = _getCanvasPos(details.localFocalPoint);

    _draggedEntity = null; _dragPart = '';

    if (_currentScenario == 0) {
      if (_currentStep == 1) {
        if (!_s0_compassSpawned && (worldPos - _s0_A).distance < 60) {
           setState(() {
             _s0_compassSpawned = true;
             _compass = CompassTool(x: _s0_A.dx, y: _s0_A.dy, radius: 100, angle: -math.pi/3, isLocked: false);
             for (var p in _points) if(p.id=='A') p.glow = false;
             for (var p in _points) if(p.id=='X') p.glow = true;
           });
           _playSound('pop'); return;
        }
      }
      if (_activeTool == 'ruler' && _currentStep == 4) {
        GeoPoint? clickedPoint;
        for (var pt in _points) {
           if ((worldPos - Offset(pt.x, pt.y)).distance < 50) { clickedPoint = pt; break; }
        }
        if (clickedPoint != null) {
          setState(() {
            if (_s0_selectedPointForLine == null) {
              _s0_selectedPointForLine = clickedPoint; _playSound('tick');
            } else {
              if (_s0_selectedPointForLine != clickedPoint) {
                String pair = ([_s0_selectedPointForLine!.id, clickedPoint!.id]..sort()).join('');
                if (pair == 'AC' && !_s0_lineAC) {
                  _s0_lineAC = true; _lines.add(GeoLine(id: 'AC', p1: _s0_A, p2: _s0_C, width: 4)); _playSound('draw');
                } else if (pair == 'CX' && !_s0_lineXC) {
                  _s0_lineXC = true; _lines.add(GeoLine(id: 'CX', p1: _s0_X, p2: _s0_C, width: 4)); _playSound('draw');
                } else { _playSound('error'); }
                _s0_selectedPointForLine = null;
                if (_s0_lineAC && _s0_lineXC) {
                  _playSound('success'); _s0_triangleComplete = true; _compass = null; _activeTool = null;
                  _scenarioCompleted = true;
                  _updateHUD();
                }
              } else { _s0_selectedPointForLine = null; }
            }
          });
          return;
        }
      }
    } else if (_currentScenario == 2) {
      if (_activeTool == 'circle' && !_s2_circleDrawn) {
        Offset centerPt = worldPos;
        for (var pt in _points) { if ((worldPos - Offset(pt.x, pt.y)).distance < 60) { centerPt = Offset(pt.x, pt.y); break; } }
        setState(() { _isDrawingCircle = true; _circleCenter = centerPt; _drawingRadius = 0; });
        _playSound('tick'); return;
      }
      if (_currentStep == 1) {
        double dist = (worldPos - _s2_O).distance;
        if ((dist - _s2_circleR).abs() < 60) {
          setState(() {
            _s2_A_angle = math.atan2(worldPos.dy - _s2_O.dy, worldPos.dx - _s2_O.dx);
            Offset ptA = Offset(_s2_O.dx + _s2_circleR * math.cos(_s2_A_angle), _s2_O.dy + _s2_circleR * math.sin(_s2_A_angle));
            _s2_pts.add(GeoPoint(id: 'A', x: ptA.dx, y: ptA.dy, label: 'A', color: Colors.amber, glow: true));
            _points.add(_s2_pts.last);
            _s2_A_placed = true;
          });
          _playSound('snap'); _advanceStep(); return;
        } else { _playSound('error'); _showHint("Click exactly on the glowing edge of the circle!"); return; }
      }
      if (_activeTool == 'ruler' && _currentStep == 5) {
        GeoPoint? clickedPoint;
        for (var pt in _points) { if (pt.id != 'O' && (worldPos - Offset(pt.x, pt.y)).distance < 60) { clickedPoint = pt; break; } }
        if (clickedPoint != null) {
          setState(() {
            if (_s2_selectedPointForLine == null) {
              _s2_selectedPointForLine = clickedPoint; _playSound('tick');
            } else {
              if (_s2_selectedPointForLine != clickedPoint) {
                String pair = ([_s2_selectedPointForLine!.id, clickedPoint!.id]..sort()).join('');
                List<String> hexPairs = ['AB', 'BC', 'CD', 'DE', 'EF', 'AF'];
                bool lineExists = _lines.any((l) => ([l.p1Id, l.p2Id]..sort()).join('') == pair);
                
                if (hexPairs.contains(pair) && !lineExists) {
                  _lines.add(GeoLine(id: pair, p1: Offset(_s2_selectedPointForLine!.x, _s2_selectedPointForLine!.y), p2: Offset(clickedPoint!.x, clickedPoint!.y), width: 4, p1Id: _s2_selectedPointForLine!.id, p2Id: clickedPoint!.id));
                  _playSound('draw');
                  if (_lines.length == 6) {
                     _playSound('success'); _s2_hexComplete = true; _compass = null; _activeTool = null;
                     _scenarioCompleted = true; _updateHUD();
                  }
                } else { _playSound('error'); }
                _s2_selectedPointForLine = null;
              } else { _s2_selectedPointForLine = null; }
            }
          });
          return;
        }
      }
    }

    if (_currentScenario == 0 && _currentStep == 0 && !_s0_stickPlaced) {
      if (worldPos.dx >= _s0_stickPos.dx - 100 && worldPos.dx <= _s0_stickPos.dx + 100 && (worldPos.dy - _s0_stickPos.dy).abs() < 50) {
        _draggedEntity = 'stick'; _dragStartPos = worldPos; _initialEntityPos = _s0_stickPos; _playSound('tick'); return;
      }
    }
    
    if (_currentScenario == 1) {
      if ((worldPos - _s1_activeTriPos).distance < _s1_R * 0.8) {
        _draggedEntity = 'triangle'; _dragStartPos = worldPos; _initialEntityPos = _s1_activeTriPos; _playSound('tick'); return;
      }
    }

    if (_compass != null && !_compass!.isHidden) {
      Offset cPt = Offset(_compass!.x, _compass!.y);
      Offset pencilPt = Offset(_compass!.x + _compass!.radius * math.cos(_compass!.angle), _compass!.y + _compass!.radius * math.sin(_compass!.angle));
      Offset handlePt = Offset(_compass!.x + (_compass!.radius/2) * math.cos(_compass!.angle), _compass!.y + (_compass!.radius/2) * math.sin(_compass!.angle));
      
      if ((worldPos - cPt).distance < 60) { _draggedEntity = 'compass'; _dragPart = 'pivot'; _dragStartPos = worldPos; _playSound('tick'); return; }
      else if ((worldPos - pencilPt).distance < 60) { 
        if ((_currentScenario == 0 && _currentStep > 1) || (_currentScenario == 2 && _currentStep > 2)) {
           _playSound('error'); _showHint("Radius is locked! Do not change the compass width."); return;
        }
        _draggedEntity = 'compass'; _dragPart = 'pencil_tip'; _dragStartPos = worldPos; _playSound('tick'); return; 
      }
      else if ((worldPos - handlePt).distance < 60) { 
        if ((_currentScenario == 0 && _currentStep > 1) || (_currentScenario == 2 && _currentStep > 2)) {
           _playSound('error'); _showHint("Radius is locked! Do not change the compass width."); return;
        }
        _draggedEntity = 'compass'; _dragPart = 'pencil_resize'; _dragStartPos = worldPos; _playSound('tick'); return; 
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      setState(() { 
        _scale = (_baseScale * details.scale).clamp(0.1, 5.0); 
        _panOffset += details.focalPointDelta; 
      });
      return;
    }
    
    if (_draggedEntity == null && !_isDrawingCircle) {
      setState(() {
        _panOffset += details.focalPointDelta;
      });
      return;
    }

    final Offset worldPos = _getCanvasPos(details.localFocalPoint);

    setState(() {
      if (_isDrawingCircle) {
        _drawingRadius = (worldPos - _circleCenter).distance;
        return;
      }

      if (_draggedEntity == 'stick') {
        _s0_stickPos = _initialEntityPos + (worldPos - _dragStartPos!);
      } else if (_draggedEntity == 'triangle') {
        _s1_activeTriPos = _initialEntityPos + (worldPos - _dragStartPos!);
        bool snapped = false;
        for (var slot in _s1_slots) {
          if (!slot['filled'] && (_s1_activeTriPos - Offset(slot['cx'], slot['cy'])).distance < 60) {
            _s1_activeTriPos = Offset(slot['cx'], slot['cy']); _s1_activeTriRot = slot['ang']; snapped = true; break;
          }
        }
        if (!snapped) _s1_activeTriRot = 0;
      } else if (_draggedEntity == 'compass' && _compass != null) {
        if (_dragPart == 'pivot') {
          _compass!.x = worldPos.dx; _compass!.y = worldPos.dy;
        } else if (_dragPart == 'pencil_resize' || (_currentScenario == 0 && _currentStep == 1 && _dragPart == 'pencil_tip') || (_currentScenario == 2 && _currentStep == 2 && _dragPart == 'pencil_tip' && !_s2_measuredOA)) {
          _compass!.radius = math.max(20.0, (worldPos - Offset(_compass!.x, _compass!.y)).distance);
          _compass!.angle = math.atan2(worldPos.dy - _compass!.y, worldPos.dx - _compass!.x);
        } else if (_dragPart == 'pencil_tip') {
          _compass!.angle = math.atan2(worldPos.dy - _compass!.y, worldPos.dx - _compass!.x);
        }
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      if (_isDrawingCircle) {
        if (_drawingRadius > 30) {
          _playSound('draw');
          _arcs.add(GeoArc(x: _circleCenter.dx, y: _circleCenter.dy, radius: _drawingRadius, startAngle: 0, sweepAngle: math.pi*2, color: Colors.lightBlue));
          if (_currentScenario == 2 && _currentStep == 0) {
            _s2_circleR = _drawingRadius; _s2_circleDrawn = true; 
            for (var p in _points) if(p.id=='O') p.glow = false;
            _advanceStep();
          }
        } else { _playSound('error'); _showHint("Draw a larger circle!"); }
        _isDrawingCircle = false; return;
      }

      if (_draggedEntity == 'stick') {
        if ((_s0_stickPos - const Offset(0, 50)).distance < 80) {
          _playSound('snap'); _s0_stickPlaced = true;
          _points.add(GeoPoint(id: 'A', x: _s0_A.dx, y: _s0_A.dy, label: 'A', color: Colors.amber, glow: true, offsetY: 25));
          _points.add(GeoPoint(id: 'X', x: _s0_X.dx, y: _s0_X.dy, label: 'X', color: Colors.amber, glow: false, offsetY: 25));
          _lines.add(GeoLine(id: 'AX', p1: _s0_A, p2: _s0_X, width: 4));
          _advanceStep();
        } else { _playSound('error'); _s0_stickPos = const Offset(-200, -150); }
      } else if (_draggedEntity == 'triangle') {
        int snappedIdx = -1;
        for (int i=0; i<6; i++) {
          if (!_s1_slots[i]['filled'] && (_s1_activeTriPos - Offset(_s1_slots[i]['cx'], _s1_slots[i]['cy'])).distance < 60) { snappedIdx = i; break; }
        }
        if (snappedIdx != -1) {
          _playSound('snap');
          _s1_activeTriPos = Offset(_s1_slots[snappedIdx]['cx'], _s1_slots[snappedIdx]['cy']);
          _s1_activeTriRot = _s1_slots[snappedIdx]['ang'];
          _s1_slots[snappedIdx]['filled'] = true;
          _s1_placed++;
          
          if (_s1_placed < 6) { _s1_activeTriPos = const Offset(-270, 150); _s1_activeTriRot = 0; }
          
          if (_currentStep == 0 && _s1_placed == 1) { _advanceStep(); }
          else if (_currentStep == 1 && _s1_placed == 6) { 
             _scenarioCompleted = true; 
             _advanceStep(); 
             _startCenterAnimation();
          }
        } else { _playSound('error'); _s1_activeTriPos = const Offset(-270, 150); _s1_activeTriRot = 0; }
      } else if (_draggedEntity == 'compass' && _compass != null) {
        if (_dragPart == 'pivot') {
          bool snapped = false;
          if (_currentScenario == 0) {
            if (_currentStep == 2 && (Offset(_compass!.x, _compass!.y) - _s0_A).distance < 60) {
                 _compass!.x = _s0_A.dx; _compass!.y = _s0_A.dy; snapped = true;
            } else if (_currentStep == 3 && (Offset(_compass!.x, _compass!.y) - _s0_X).distance < 60) {
                 _compass!.x = _s0_X.dx; _compass!.y = _s0_X.dy; snapped = true;
            }
          } else if (_currentScenario == 2) {
            if (_currentStep == 2) {
              Offset ptA = Offset(_s2_pts[0].x, _s2_pts[0].y);
              if (!_s2_measuredOA) {
                 if ((Offset(_compass!.x, _compass!.y) - _s2_O).distance < 60) {
                     _compass!.x = _s2_O.dx; _compass!.y = _s2_O.dy; snapped = true;
                 }
              } else {
                 if ((Offset(_compass!.x, _compass!.y) - ptA).distance < 60) {
                     _compass!.x = ptA.dx; _compass!.y = ptA.dy; snapped = true;
                     for (var p in _points) if(p.id=='A') p.glow = false;
                     _showHint("Now click DRAW ARC to mark point B!");
                     _advanceStep();
                 }
              }
            } else if (_currentStep == 3 || _currentStep == 4) {
              int lastPtIdx = _s2_pts.length - 1;
              if (lastPtIdx >= 0) {
                 GeoPoint lastPt = _s2_pts[lastPtIdx];
                 if ((Offset(_compass!.x, _compass!.y) - Offset(lastPt.x, lastPt.y)).distance < 60) {
                    _compass!.x = lastPt.x; _compass!.y = lastPt.y; snapped = true;
                    for (var p in _points) if(p.id==lastPt.id) p.glow = false;
                 }
              }
            }
          }
          if (snapped) _playSound('snap');
        } else if (_dragPart == 'pencil_resize' || _dragPart == 'pencil_tip') {
          if (_currentScenario == 0 && _currentStep == 1) {
            Offset pencilTip = Offset(_compass!.x + _compass!.radius * math.cos(_compass!.angle), _compass!.y + _compass!.radius * math.sin(_compass!.angle));
            if ((pencilTip - _s0_X).distance < 60 || (_compass!.radius - 200).abs() < 15) {
              _playSound('snap'); _compass!.radius = 200; _compass!.angle = 0;
              for (var p in _points) if(p.id=='X') p.glow = false;
              _advanceStep();
            }
          } else if (_currentScenario == 2 && _currentStep == 2) {
            Offset ptA = Offset(_s2_pts[0].x, _s2_pts[0].y);
            bool pivotAtO = (Offset(_compass!.x, _compass!.y) - _s2_O).distance < 40;
            Offset pencilTip = Offset(_compass!.x + _compass!.radius * math.cos(_compass!.angle), _compass!.y + _compass!.radius * math.sin(_compass!.angle));
            
            if (pivotAtO && ((pencilTip - ptA).distance < 60 || (_compass!.radius - _s2_circleR).abs() < 20)) {
               _playSound('snap'); _compass!.radius = _s2_circleR; _compass!.angle = _s2_A_angle;
               if (!_s2_measuredOA) {
                  _s2_measuredOA = true;
                  _showHint("Radius set! Now DRAG the compass needle to point A.");
                  for (var p in _points) if(p.id=='A') p.glow = true;
               }
            }
          }
        }
      }
      _draggedEntity = null;
    });
  }

  void _startArcAnimation(GeoArc arc, VoidCallback onComplete) {
    setState(() {
      _animatingArc = arc;
    });
    _playSound('draw');
    _arcAnimController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _arcs.add(_animatingArc!);
        _animatingArc = null;
        onComplete();
      });
    });
  }

  void _startCenterAnimation() {
    _playSound('success');
    _centerAnimController.forward(from: 0.0);
  }

  void _drawArcAction() {
    if (_compass == null || _animatingArc != null) return;
    
    if (_currentScenario == 0) {
      if (_currentStep == 2) {
        if ((Offset(_compass!.x, _compass!.y) - _s0_A).distance > 40) { _playSound('error'); _showHint("Snap compass to point A!"); return; }
        setState(() { _compass!.radius = 200; _compass!.angle = -math.pi/3; });
        _startArcAnimation(GeoArc(x: _s0_A.dx, y: _s0_A.dy, radius: 200, startAngle: -math.pi/3 - 0.4, sweepAngle: 0.8, color: Colors.lightBlue), () {
          _s0_arc1Drawn = true; 
          for (var p in _points) if(p.id=='A') p.glow = false;
          for (var p in _points) if(p.id=='X') p.glow = true;
          _advanceStep();
        });
      } else if (_currentStep == 3) {
        if ((Offset(_compass!.x, _compass!.y) - _s0_X).distance > 40) { _playSound('error'); _showHint("Snap compass to point X!"); return; }
        setState(() { _compass!.radius = 200; _compass!.angle = -2*math.pi/3; });
        _startArcAnimation(GeoArc(x: _s0_X.dx, y: _s0_X.dy, radius: 200, startAngle: -2*math.pi/3 - 0.4, sweepAngle: 0.8, color: Colors.lightBlue), () {
          _points.add(GeoPoint(id: 'C', x: _s0_C.dx, y: _s0_C.dy, label: 'C', color: Colors.amber, glow: true, offsetY: -25));
          _s0_arc2Drawn = true; 
          for (var p in _points) if(p.id=='X') p.glow = false;
          _compass!.isHidden = true;
          _advanceStep();
        });
      }
    } else if (_currentScenario == 2) {
      if (_currentStep == 3 || _currentStep == 4) {
        int lastPtIdx = _s2_pts.length - 1;
        GeoPoint lastPt = _s2_pts[lastPtIdx];
        List<String> labels = ['A', 'B', 'C', 'D', 'E', 'F'];
        if ((Offset(_compass!.x, _compass!.y) - Offset(lastPt.x, lastPt.y)).distance > 40) { _playSound('error'); _showHint("Snap compass pivot to point ${labels[lastPtIdx]}!"); return; }
        
        double nextAngle = _s2_A_angle + (lastPtIdx + 1) * math.pi/3;
        Offset expectedPt = Offset(_s2_O.dx + _s2_circleR * math.cos(nextAngle), _s2_O.dy + _s2_circleR * math.sin(nextAngle));
        
        // Calculate the exact angle to draw the arc from the current pivot point, cutting the circle at expectedPt.
        double drawAngle = math.atan2(expectedPt.dy - lastPt.y, expectedPt.dx - lastPt.x);
        
        // Slightly wider sweep angle (1.2 radians) to ensure it visibly intersects the circle boundary on both sides
        _startArcAnimation(GeoArc(x: lastPt.x, y: lastPt.y, radius: _s2_circleR, startAngle: drawAngle - 0.6, sweepAngle: 1.2, color: Colors.lightBlue), () {
          String nextLabel = labels[lastPtIdx + 1];
          GeoPoint newPt = GeoPoint(id: nextLabel, x: expectedPt.dx, y: expectedPt.dy, label: nextLabel, color: Colors.amber, glow: true);
          _s2_pts.add(newPt); _points.add(newPt);
          
          for (var p in _points) p.glow = false;
          _points.firstWhere((p)=>p.id==nextLabel).glow = true;
          
          if (_s2_pts.length == 6) { 
             _compass!.isHidden = true; 
             for (var p in _points) if(p.id=='F') p.glow = false;
             _advanceStep(); 
          }
          else if (_s2_pts.length == 2) { 
             _advanceStep(); 
             _showHint("Great! Now move compass needle to $nextLabel and draw next arc.");
          }
          else { 
             _showHint("Great! Now move compass needle to $nextLabel and draw next arc."); 
          }
        });
      }
    }
  }

  void _advanceStep() {
    final stepsList = _i18n[_currentLang]!['scenarios'][_currentScenario]['steps'] as List;
    if (_currentStep < stepsList.length - 1) {
      _playSound('success');
      setState(() {
        _currentStep++;
        if (_currentScenario == 0 && _currentStep == 4) { _selectTool('ruler'); }
        else if (_currentScenario == 2 && _currentStep == 2) { _selectTool('compass'); }
        else if (_currentScenario == 2 && _currentStep == 5) { _selectTool('ruler'); }
        _updateHUD();
      });
    } else {
      _playSound('success');
      setState(() {
        _scenarioCompleted = true;
        _updateHUD();
      });
    }
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
    double sidebarWidth = screenWidth * 0.3;

    bool showDrawArc = false;
    if (_compass != null && !_compass!.isHidden && _animatingArc == null) {
      if (_currentScenario == 0 && (_currentStep == 2 || _currentStep == 3)) showDrawArc = true;
      if (_currentScenario == 2 && (_currentStep == 3 || _currentStep == 4)) showDrawArc = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Center Canvas Area
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
                    _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
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
                            compass: _compass,
                            pulseValue: _pulseController.value,
                            scenarioCompleted: _scenarioCompleted,
                            s0_stickPlaced: _s0_stickPlaced,
                            s0_stickPos: _s0_stickPos,
                            s0_triangleComplete: _s0_triangleComplete,
                            s0_A: _s0_A, s0_X: _s0_X, s0_C: _s0_C,
                            s0_selectedPointForLine: _s0_selectedPointForLine,
                            s1_R: _s1_R, s1_slots: _s1_slots, s1_activeTriPos: _s1_activeTriPos, s1_activeTriRot: _s1_activeTriRot, s1_placed: _s1_placed, s1_animProgress: _s1_animProgress,
                            s2_O: _s2_O, s2_circleR: _s2_circleR, s2_circleDrawn: _s2_circleDrawn, s2_A_placed: _s2_A_placed, s2_hexComplete: _s2_hexComplete, s2_selectedPointForLine: _s2_selectedPointForLine,
                            isDrawingCircle: _isDrawingCircle, circleCenter: _circleCenter, drawingRadius: _drawingRadius,
                            animatingArc: _animatingArc, arcAnimValue: _arcAnimController.value, centerAnimValue: _centerAnimController.value
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
                    if (_currentScenario == 0 && _currentStep == 4)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.indigoAccent.withOpacity(0.5))),
                        child: _buildToolBtn(Icons.straighten, 'ruler', _activeTool == 'ruler'),
                      ),
                    if (_currentScenario == 2)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.indigoAccent.withOpacity(0.5))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_currentStep == 0) _buildToolBtn(Icons.circle_outlined, 'circle', _activeTool == 'circle'),
                            if (_currentStep >= 2 && _currentStep <= 4) _buildToolBtn(Icons.architecture, 'compass', _activeTool == 'compass'),
                            if (_currentStep == 5) _buildToolBtn(Icons.straighten, 'ruler', _activeTool == 'ruler'),
                          ],
                        ),
                      ),
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

            // Action Buttons
            if (!_showShutter && !_scenarioCompleted && showDrawArc)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isSidebarOpen ? sidebarWidth : 0, 
                right: 0, 
                bottom: 100,
                child: Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                    onPressed: () { HapticFeedback.lightImpact(); _drawArcAction(); },
                    icon: const Icon(Icons.mode_edit), label: Text(_i18n[_currentLang]!['btnDrawArc'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                         ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                             const Icon(Icons.check_circle, color: Colors.green, size: 24), const SizedBox(width: 8),
                             Expanded(child: Text(_hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold))),
                           ])
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
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 74, 20, 20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_i18n[_currentLang]!['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigoAccent, height: 1.2)),
                          const SizedBox(height: 6),
                          Text(_i18n[_currentLang]!['subtitle'], style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    
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
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_i18n[_currentLang]!['selectScenario'].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
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
                              if (val != null) { _playSound('click'); setState(() => _loadScenario(val)); }
                            },
                          ),
                        ],
                      ),
                    ),
                    
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
                    
                    ...(_i18n[_currentLang]!['scenarios'][_currentScenario]['steps'] as List).asMap().entries.map((entry) {
                      int idx = entry.key; var step = entry.value;
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
                              Padding(padding: const EdgeInsets.only(top: 2, right: 8), child: Icon(isCurrent ? Icons.adjust : Icons.check_circle, color: isCurrent ? Colors.indigoAccent : Colors.green, size: 16)),
                              Expanded(child: RichText(text: TextSpan(style: TextStyle(fontSize: 13, color: isCurrent ? Colors.white : Colors.white70, height: 1.4), children: _parseBoldText(step['text'])))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),
                    Container(padding: const EdgeInsets.all(12), color: Colors.black26, width: double.infinity, child: const Text("© ZeroScienceLab - Fall in love with math and Science", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)))
                  ],
                ),
              ),
            ),

            Positioned(
              top: 16, left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent, iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact(); _playSound('click');
                  setState(() { _isSidebarOpen = !_isSidebarOpen; });
                },
                style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.8)))),
              ),
            ),

            if (!_isSidebarOpen && !_showShutter && !_scenarioCompleted)
              Positioned(
                left: _floatingStepPos.dx, top: _floatingStepPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) { setState(() { _floatingStepPos = Offset((_floatingStepPos.dx + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 280), (_floatingStepPos.dy + details.delta.dy).clamp(0, MediaQuery.of(context).size.height - 150)); }); },
                  child: Container(
                    width: 280, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B).withOpacity(0.95), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.indigoAccent), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("STEP ${_currentStep + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigoAccent)), const Icon(Icons.drag_indicator, color: Colors.white54, size: 16)]),
                        const SizedBox(height: 8),
                        RichText(text: TextSpan(style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4), children: _parseBoldText(_i18n[_currentLang]!['scenarios'][_currentScenario]['steps'][_currentStep]['text']))),
                      ],
                    ),
                  ),
                )
              ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic,
              top: _showShutter ? 0 : -MediaQuery.of(context).size.height, left: 0, right: 0, height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hexagon_outlined, color: Colors.indigoAccent, size: 80),
                      const SizedBox(height: 20),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(_i18n[_currentLang]!['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 16),
                      Text(_i18n[_currentLang]!['subtitle'], style: const TextStyle(color: Colors.indigo, fontSize: 18)),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        onPressed: () { _playSound('shutter'); setState(() => _showShutter = false); },
                        icon: const Icon(Icons.play_circle, size: 28), label: Text(_i18n[_currentLang]!['enterLab'], style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
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
        decoration: BoxDecoration(color: isActive ? Colors.indigo : Colors.white10, shape: BoxShape.circle, boxShadow: isActive ? [const BoxShadow(color: Colors.indigoAccent, blurRadius: 10)] : []),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  final Map<String, Map<String, dynamic>> _i18n = {
    'en': {
      'title': "The Hexagon Architect: Mastering 60° Angles", 'subtitle': "Class 7 • CONSTRUCTIONS AND TILINGS",
      'selectScenario': "Select Scenario", 'missionObj': "Mission Objective", 'btnDrawArc': "DRAW ARC", 'enterLab': "Enter Virtual Lab",
      'scenarios': [
        { 'title': "1. The Magic Triangle", 'objective': "To intuitively understand that a 60° angle is created when three sides of a triangle are equal.",
          'steps': [
            { 'text': "DRAG the blue glowing endpoint of the horizontal stick to the workspace (above Center).", 'hud': "Drag the stick into the workspace." },
            { 'text': "CLICK on Point A. A virtual compass will appear. DRAG the compass pencil to Point X to set its radius.", 'hud': "Click A, then drag pencil to X to set radius." },
            { 'text': "With the compass needle on A, CLICK Draw Arc to draw an arc above the stick.", 'hud': "Click DRAW ARC to draw an arc from A." },
            { 'text': "Now, DRAG the compass needle and place it on Point X. CLICK Draw Arc to draw another arc that intersects.", 'hud': "Move needle to X, Click DRAW ARC." },
            { 'text': "Select the Ruler tool. CLICK on points to connect A to C, then X to C.", 'hud': "Select Ruler. Click points to connect A to C, and X to C." },
            { 'text': "Watch the magic happen! (Equilateral Triangle = Three 60° Angles!)", 'hud': "Equilateral Triangle = Three 60° Angles!" }
          ]
        },
        { 'title': "2. Building a Honeycomb Cell", 'objective': "To understand that a regular hexagon is composed of six equilateral triangles, and the angles around its center sum to 360°.",
          'steps': [
            { 'text': "A hexagonal outline is on the screen. **DRAG** the glowing equilateral triangle into a slot.", 'hud': "Drag the glowing triangle into the hexagon outline." },
            { 'text': "**DRAG** the remaining 5 triangles to completely fill the hexagonal outline.", 'hud': "Drag 5 more triangles to fill the hexagon." },
            { 'text': "Observe the center point where all the triangles meet. 6 x 60° = 360°.", 'hud': "Watch the center angles combine!" }
          ]
        },
        { 'title': "3. The Architect's Blueprint", 'objective': "To follow a guided, step-by-step process to construct a regular hexagon using a virtual compass and ruler.",
          'steps': [
            { 'text': "Select the **Circle** tool. Click and drag on the canvas to draw a large circle from center 'O'.", 'hud': "Select Circle Tool and drag to draw a circle." },
            { 'text': "CLICK anywhere on the circle's glowing edge to place your starting point, A.", 'hud': "Click the circle edge to place point A." },
            { 'text': "Select **Compass**. DRAG needle to O, and pencil to A. Then, DRAG needle to A.", 'hud': "Measure OA with compass, then move needle to A." },
            { 'text': "Click DRAW ARC to make a small arc cutting the circle to mark point B.", 'hud': "Click DRAW ARC to find point B." },
            { 'text': "Move compass needle to B and DRAW ARC for point C. Continue around the circle to mark C, D, E, F.", 'hud': "Move compass to new points and draw arcs." },
            { 'text': "Select **Ruler** and click the points in order (A to B, B to C...) to draw the hexagon.", 'hud': "Click points A-B-C-D-E-F-A to finish hexagon." }
          ]
        }
      ]
    },
    'hi': {
      'title': "हेक्सागन आर्किटेक्ट: 60° कोणों में महारत", 'subtitle': "कक्षा 7 • संरचनाएं और टिलिंग",
      'selectScenario': "परिदृश्य चुनें", 'missionObj': "मिशन का उद्देश्य", 'btnDrawArc': "चाप बनाएं", 'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'scenarios': [
        { 'title': "1. जादुई त्रिभुज", 'objective': "यह समझने के लिए कि जब त्रिभुज की तीनों भुजाएँ बराबर होती हैं तो 60° का कोण बनता है।",
          'steps': [
            { 'text': "क्षैतिज छड़ी के नीले सिरे को कार्यक्षेत्र में **खींचें**।", 'hud': "छड़ी को कार्यक्षेत्र में खींचें।" },
            { 'text': "बिंदु A पर **क्लिक** करें। कंपास दिखाई देगा। त्रिज्या सेट करने के लिए पेंसिल को X तक **खींचें**।", 'hud': "A पर क्लिक करें, त्रिज्या सेट करने के लिए पेंसिल को X तक खींचें।" },
            { 'text': "सुई A पर रखकर, चाप बनाने के लिए 'चाप बनाएं' पर क्लिक करें।", 'hud': "A से चाप खींचने के लिए 'चाप बनाएं' पर क्लिक करें।" },
            { 'text': "सुई को X पर ले जाएं। प्रतिच्छेदी चाप खींचने के लिए 'चाप बनाएं' पर क्लिक करें।", 'hud': "सुई को X पर ले जाएं, 'चाप बनाएं' पर क्लिक करें।" },
            { 'text': "रूलर चुनें। A को C से और X को C से जोड़ने के लिए बिंदुओं पर क्लिक करें।", 'hud': "रूलर चुनें। A-C और X-C कनेक्ट करें।" },
            { 'text': "जादू देखें! समबाहु त्रिभुज = तीन 60° कोण!", 'hud': "समबाहु त्रिभुज = तीन 60° कोण!" }
          ]
        },
        { 'title': "2. मधुकोश सेल बनाना", 'objective': "एक समषट्भुज छह समबाहु त्रिभुजों से बना होता है, और केंद्र के कोणों का योग 360° होता है।",
          'steps': [
            { 'text': "चमकते हुए समबाहु त्रिभुज को षट्भुज के स्लॉट में **खींचें**।", 'hud': "चमकते त्रिभुज को रूपरेखा में खींचें।" },
            { 'text': "षट्भुज को भरने के लिए शेष 5 त्रिभुजों को **खींचें**।", 'hud': "षट्भुज को भरने के लिए 5 और त्रिभुज खींचें।" },
            { 'text': "केंद्र बिंदु का निरीक्षण करें। 6 x 60° = 360°।", 'hud': "केंद्र के कोणों को मिलते हुए देखें!" }
          ]
        },
        { 'title': "3. आर्किटेक्ट का खाका", 'objective': "वर्चुअल कंपास और रूलर का उपयोग करके समषट्भुज बनाने की प्रक्रिया।",
          'steps': [
            { 'text': "**वृत्त** टूल चुनें। बड़ा वृत्त बनाने के लिए कैनवास पर खींचें।", 'hud': "वृत्त टूल चुनें और खींचें।" },
            { 'text': "बिंदु A रखने के लिए वृत्त के चमकते किनारे पर क्लिक करें।", 'hud': "बिंदु A रखने के लिए वृत्त के किनारे पर क्लिक करें।" },
            { 'text': "**कंपास** चुनें। सुई को O पर और पेंसिल को A पर **खींचें**। फिर सुई को A पर ले जाएं।", 'hud': "त्रिज्या OA सेट करें। कंपास को A पर स्नैप करें।" },
            { 'text': "बिंदु B खोजने के लिए 'चाप बनाएं' पर क्लिक करें।", 'hud': "बिंदु B खोजने के लिए चाप बनाएं।" },
            { 'text': "कंपास को B पर ले जाएं और C के लिए चाप बनाएं। D, E, F के लिए भी ऐसा ही करें।", 'hud': "नए बिंदुओं पर कंपास ले जाएं और चाप बनाएं।" },
            { 'text': "**रूलर** चुनें और षट्भुज बनाने के लिए बिंदुओं को जोड़ें।", 'hud': "षट्भुज को पूरा करने के लिए बिंदुओं पर क्लिक करें।" }
          ]
        }
      ]
    }
  };
}

class GeoPoint {
  String id; double x; double y; String label; Color color; bool glow; double offsetX; double offsetY;
  GeoPoint({required this.id, required this.x, required this.y, this.label = '', this.color = Colors.blue, this.glow = false, this.offsetX = 0, this.offsetY = -25});
}
class GeoLine {
  String id; Offset p1; Offset p2; Color color; double width; String? p1Id; String? p2Id;
  GeoLine({required this.id, required this.p1, required this.p2, this.color = Colors.white70, this.width = 3, this.p1Id, this.p2Id});
}
class GeoArc {
  double x; double y; double radius; double startAngle; double sweepAngle; Color color;
  GeoArc({required this.x, required this.y, required this.radius, required this.startAngle, required this.sweepAngle, this.color = Colors.blue});
}
class CompassTool {
  double x; double y; double radius; double angle; bool isLocked; bool isHidden;
  CompassTool({required this.x, required this.y, required this.radius, required this.angle, this.isLocked = false, this.isHidden = false});
}

class CanvasPainter extends CustomPainter {
  final int currentScenario;
  final int currentStep;
  final double scale;
  final Offset panOffset;
  final List<GeoPoint> points;
  final List<GeoLine> lines;
  final List<GeoArc> arcs;
  final CompassTool? compass;
  final double pulseValue;
  final bool scenarioCompleted;

  // Scenario 0 State
  final bool s0_stickPlaced;
  final Offset s0_stickPos;
  final bool s0_triangleComplete;
  final Offset s0_A, s0_X, s0_C;
  final GeoPoint? s0_selectedPointForLine;

  // Scenario 1 State
  final double s1_R;
  final List<Map<String, dynamic>> s1_slots;
  final Offset s1_activeTriPos;
  final double s1_activeTriRot;
  final int s1_placed;
  final double s1_animProgress;

  // Scenario 2 State
  final Offset s2_O;
  final double s2_circleR;
  final bool s2_circleDrawn;
  final bool s2_A_placed;
  final bool s2_hexComplete;
  final GeoPoint? s2_selectedPointForLine;
  final bool isDrawingCircle;
  final Offset circleCenter;
  final double drawingRadius;
  
  // Animation specific variables
  final GeoArc? animatingArc;
  final double arcAnimValue;
  final double centerAnimValue;

  CanvasPainter({
    required this.currentScenario, required this.currentStep, required this.scale, required this.panOffset,
    required this.points, required this.lines, required this.arcs, this.compass, required this.pulseValue, required this.scenarioCompleted,
    required this.s0_stickPlaced, required this.s0_stickPos, required this.s0_triangleComplete, required this.s0_A, required this.s0_X, required this.s0_C, required this.s0_selectedPointForLine,
    required this.s1_R, required this.s1_slots, required this.s1_activeTriPos, required this.s1_activeTriRot, required this.s1_placed, required this.s1_animProgress,
    required this.s2_O, required this.s2_circleR, required this.s2_circleDrawn, required this.s2_A_placed, required this.s2_hexComplete, required this.s2_selectedPointForLine, required this.isDrawingCircle, required this.circleCenter, required this.drawingRadius,
    required this.animatingArc, required this.arcAnimValue, required this.centerAnimValue
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panOffset.dx, size.height / 2 + panOffset.dy);
    canvas.scale(scale, scale);

    Paint gridPaint = Paint()..color = Colors.indigoAccent.withOpacity(0.05)..strokeWidth = 1;
    for (double i = -1000; i <= 1000; i += 40) {
      canvas.drawLine(Offset(i, -1000), Offset(i, 1000), gridPaint);
      canvas.drawLine(Offset(-1000, i), Offset(1000, i), gridPaint);
    }

    if (currentScenario == 0) {
      if (currentStep == 0 && !s0_stickPlaced) {
         Paint stickGuide = Paint()..color=Colors.white24..style=PaintingStyle.stroke..strokeWidth=4;
         _drawDashedLine(canvas, s0_A, s0_X, stickGuide, 10, 10);
      }
      if (!s0_stickPlaced) {
         _drawStick(canvas, s0_stickPos);
      }
      if (s0_triangleComplete) {
         Path triPath = Path()..moveTo(s0_A.dx, s0_A.dy)..lineTo(s0_X.dx, s0_X.dy)..lineTo(s0_C.dx, s0_C.dy)..close();
         canvas.drawPath(triPath, Paint()..color = Colors.green.withOpacity(0.2)..style=PaintingStyle.fill);
      }
      if (s0_selectedPointForLine != null) {
         canvas.drawCircle(Offset(s0_selectedPointForLine!.x, s0_selectedPointForLine!.y), 15, Paint()..color = Colors.green..style=PaintingStyle.stroke..strokeWidth=3);
      }
    } else if (currentScenario == 1) {
      // Draw Hexagon Slots Outline
      double hexRadius = s1_R; 
      Path hexPath = Path();
      for (int i=0; i<6; i++) {
        double px = hexRadius * math.cos(i * math.pi/3);
        double py = hexRadius * math.sin(i * math.pi/3);
        if (i==0) hexPath.moveTo(px, py); else hexPath.lineTo(px, py);
      }
      hexPath.close();
      canvas.drawPath(hexPath, Paint()..color=Colors.white24..style=PaintingStyle.stroke..strokeWidth=4);
      for (int i=0; i<6; i++) {
        double px = hexRadius * math.cos(i * math.pi/3);
        double py = hexRadius * math.sin(i * math.pi/3);
        _drawDashedLine(canvas, const Offset(0,0), Offset(px,py), Paint()..color=Colors.white24..style=PaintingStyle.stroke..strokeWidth=2, 5, 5);
      }

      // Placed triangles
      for (var slot in s1_slots) {
        if (slot['filled']) {
           _drawEquilateralTriangle(canvas, Offset(slot['cx'], slot['cy']), s1_R * math.sqrt(3)/3, slot['ang'], false);
        }
      }
      // Active triangle
      if (s1_placed < 6) {
         _drawEquilateralTriangle(canvas, s1_activeTriPos, s1_R * math.sqrt(3)/3, s1_activeTriRot, true);
      }
      
      // 360 degree combined angles animation
      if (s1_placed == 6 && scenarioCompleted) {
         if (centerAnimValue > 0) {
            canvas.drawArc(
              Rect.fromCircle(center: Offset.zero, radius: 50 * centerAnimValue),
              0,
              math.pi * 2 * centerAnimValue,
              true,
              Paint()..color = Colors.amberAccent.withOpacity(0.6 * centerAnimValue)..style = PaintingStyle.fill
            );
            if (centerAnimValue == 1.0) {
               TextPainter tp = TextPainter(text: const TextSpan(text: "6 x 60° = 360°", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
               canvas.drawRRect(
                  RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: tp.width + 24, height: tp.height + 12), const Radius.circular(16)), 
                  Paint()..color = Colors.white
               );
               tp.paint(canvas, Offset(-tp.width/2, -tp.height/2));
            }
         }
      }
    } else if (currentScenario == 2) {
      if (isDrawingCircle) {
         _drawDashedCircle(canvas, circleCenter, drawingRadius, Paint()..color=Colors.lightBlue.withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth=2);
      }
      if (s2_circleDrawn) {
         Paint cPaint = Paint()..color=Colors.lightBlue..style=PaintingStyle.stroke..strokeWidth=2;
         if (currentStep == 1 && !s2_A_placed) cPaint.color = Colors.lightBlueAccent;
         canvas.drawCircle(s2_O, s2_circleR, cPaint);
      }
      if (s2_selectedPointForLine != null) {
         canvas.drawCircle(Offset(s2_selectedPointForLine!.x, s2_selectedPointForLine!.y), 15, Paint()..color = Colors.green..style=PaintingStyle.stroke..strokeWidth=3);
      }
      if (s2_hexComplete) {
         Path hexPath = Path();
         for (int i=0; i<6; i++) {
           if (i==0) hexPath.moveTo(points[i+1].x, points[i+1].y); else hexPath.lineTo(points[i+1].x, points[i+1].y); // Skip O which is index 0
         }
         hexPath.close();
         canvas.drawPath(hexPath, Paint()..color=Colors.green.withOpacity(0.2 + 0.2*pulseValue)..style=PaintingStyle.fill);
      }
    }

    // Draw Static Arcs
    for (var a in arcs) {
      Paint arcPaint = Paint()..color = a.color..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawArc(Rect.fromCircle(center: Offset(a.x, a.y), radius: a.radius), a.startAngle, a.sweepAngle, false, arcPaint);
    }
    
    // Draw Animating Arc
    if (animatingArc != null) {
      Paint arcPaint = Paint()..color = animatingArc!.color..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(animatingArc!.x, animatingArc!.y), radius: animatingArc!.radius), 
        animatingArc!.startAngle, 
        animatingArc!.sweepAngle * arcAnimValue, 
        false, 
        arcPaint
      );
    }

    // Draw Lines
    for (var l in lines) {
      canvas.drawLine(l.p1, l.p2, Paint()..color = l.color..strokeWidth = l.width..strokeCap = StrokeCap.round);
    }

    // Draw Points
    for (var p in points) {
      if (p.glow) {
        canvas.drawCircle(Offset(p.x, p.y), 15 + pulseValue*5, Paint()..color = p.color.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      }
      canvas.drawCircle(Offset(p.x, p.y), 6, Paint()..color = p.color);
      canvas.drawCircle(Offset(p.x, p.y), 6, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      
      if (p.label.isNotEmpty) {
        TextPainter tp = TextPainter(text: TextSpan(text: p.label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(p.x + p.offsetX - tp.width/2, p.y + p.offsetY));
      }
    }

    // Draw Compass
    if (compass != null && !compass!.isHidden) {
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
    }

    canvas.restore();
  }

  void _drawStick(Canvas canvas, Offset pos) {
    canvas.save(); canvas.translate(pos.dx, pos.dy);
    canvas.drawLine(const Offset(-100, 0), const Offset(100, 0), Paint()..color=Colors.lightBlue..strokeWidth=6..strokeCap=StrokeCap.round);
    canvas.drawCircle(const Offset(-100, 0), 8, Paint()..color=Colors.white);
    canvas.drawCircle(const Offset(100, 0), 8, Paint()..color=Colors.white);
    canvas.drawCircle(const Offset(-100, 0), 8 + pulseValue*5, Paint()..color=Colors.lightBlueAccent.withOpacity(0.5));
    canvas.restore();
  }

  void _drawEquilateralTriangle(Canvas canvas, Offset pos, double r, double rot, bool glow) {
    canvas.save(); canvas.translate(pos.dx, pos.dy); canvas.rotate(rot);
    Path p = Path()..moveTo(r * math.cos(-math.pi/2), r * math.sin(-math.pi/2))..lineTo(r * math.cos(math.pi/6), r * math.sin(math.pi/6))..lineTo(r * math.cos(5*math.pi/6), r * math.sin(5*math.pi/6))..close();
    canvas.drawPath(p, Paint()..color=Colors.amber.withOpacity(0.8)..style=PaintingStyle.fill);
    canvas.drawPath(p, Paint()..color=Colors.orange..style=PaintingStyle.stroke..strokeWidth=3);
    if (glow) {
       canvas.drawCircle(Offset(r * math.cos(-math.pi/2), r * math.sin(-math.pi/2)), 6 + pulseValue*5, Paint()..color=Colors.amberAccent.withOpacity(0.6));
    }
    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, double dashWidth, double dashSpace) {
    double dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    double len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    double nx = dx / len, ny = dy / len;
    double curLen = 0;
    while (curLen < len) {
      double endX = p1.dx + nx * math.min(curLen + dashWidth, len);
      double endY = p1.dy + ny * math.min(curLen + dashWidth, len);
      canvas.drawLine(Offset(p1.dx + nx*curLen, p1.dy + ny*curLen), Offset(endX, endY), paint);
      curLen += dashWidth + dashSpace;
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    double circum = 2 * math.pi * radius;
    int dashes = (circum / 15).floor();
    for (int i=0; i<dashes; i++) {
      if (i%2 == 0) {
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), (i * 2*math.pi) / dashes, (2*math.pi) / dashes, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}