// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IntegerFactoryApp());
}

class IntegerFactoryApp extends StatelessWidget {
  const IntegerFactoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | The Integer Factory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const CommutativeAssociativeandDistributiveProperties(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class Tray {
  String id;
  double x, y, startX, startY;
  int val;
  String label;
  bool isDraggable, isDragging, isBlackBox;
  String? attachedTo;

  Tray(
    this.id,
    this.x,
    this.y,
    this.val, {
    this.label = '',
    this.isDraggable = true,
    this.isBlackBox = false,
  })  : startX = x,
        startY = y,
        isDragging = false;
}

class Machine {
  String id;
  double x, y;
  int? targetDial, dial;
  bool isDialClickable;
  String orientation;
  Color color;
  String labelKey;
  bool hasSideSlot;
  Tray? inputTray;
  bool isProcessing, outDone, inputZoneActive, dialZoneActive;
  int processTimer;

  Machine(
    this.id,
    this.x,
    this.y, {
    this.targetDial,
    this.isDialClickable = false,
    this.orientation = 'h',
    this.color = const Color(0xFFCBD5E1),
    this.labelKey = '',
    this.hasSideSlot = false,
  })  : isProcessing = false,
        outDone = false,
        inputZoneActive = false,
        dialZoneActive = false,
        processTimer = 0;
}

class Funnel {
  String id;
  double x, y;
  List<Tray> inputTrays;
  bool hasCombineBtn, combineActive, isCombineReady, isProcessing, outDone, inputZoneActive;
  int processTimer;
  String labelKey;

  Funnel(
    this.id,
    this.x,
    this.y, {
    this.hasCombineBtn = false,
    this.labelKey = '',
  })  : inputTrays = [],
        combineActive = false,
        isCombineReady = false,
        isProcessing = false,
        outDone = false,
        inputZoneActive = false,
        processTimer = 0;
}

class BalancerScale {
  double x, y, angle;
  int leftWeight, rightWeight;
  bool leftZoneActive, rightZoneActive, isBalanced;
  Offset leftPanPos, rightPanPos;

  BalancerScale(this.x, this.y)
      : angle = 0,
        leftWeight = 0,
        rightWeight = 0,
        leftZoneActive = false,
        rightZoneActive = false,
        isBalanced = false,
        leftPanPos = Offset.zero,
        rightPanPos = Offset.zero;
}

// ==========================================
// MAIN WIDGET
// ==========================================
class CommutativeAssociativeandDistributiveProperties extends StatefulWidget {
  const CommutativeAssociativeandDistributiveProperties({super.key});

  @override
  State<CommutativeAssociativeandDistributiveProperties> createState() => _CommutativeAssociativeandDistributivePropertiesState();
}

class _CommutativeAssociativeandDistributivePropertiesState extends State<CommutativeAssociativeandDistributiveProperties> with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;

  // Lab State
  int _scenario = 1;
  int _step = 0;
  bool _showSuccessPopup = false;
  final ScrollController _sidebarScrollController = ScrollController();

  // Viewport State
  double _zoom = 1.0;
  double _panX = 0;
  double _panY = 0;
  double _baseZoom = 1.0;
  Offset _basePan = Offset.zero;

  // Simulation State
  final List<Tray> _trays = [];
  final List<Machine> _machines = [];
  final List<Funnel> _funnels = [];
  BalancerScale? _scale;

  bool _toolDragging = false;
  Tray? _activeTray;
  Offset _dragOffset = Offset.zero;
  double _mouseX = 0;
  double _mouseY = 0;

  // Dedicated audio players initialized with ReleaseMode.stop
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  late AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _playSound('enter');
    _loadScenario(1);

    // Main Game Loop
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))..addListener(_tick)..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sidebarScrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      if (type == 'enter') {
        await _fxPlayer.play(AssetSource(_shutterUrl), volume: 0.5);
      } else if (type == 'pop' || type == 'tick' || type == 'snap' || type == 'weld') {
        await _clickPlayer.play(AssetSource(_clickUrl), volume: 0.5);
      } else if (type == 'success') {
        await _successPlayer.play(AssetSource(_successUrl), volume: 0.5);
      } else if (type == 'error') {
        await _errorPlayer.play(AssetSource(_errorUrl), volume: 0.5);
      }
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }

  String t(String key) {
    return _translations[_lang]?[key] ?? _translations['en']![key] ?? key;
  }

  void _toggleLanguage() {
    _playSound('pop');
    setState(() {
      if (_lang == 'en') _lang = 'hi'; else _lang = 'en';
    });
  }

  void _handleReset() {
    _playSound('error');
    setState(() => _showCurtain = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _lang = 'en';
          _loadScenario(1);
        });
      }
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _toolDragging = false;
      _activeTray = null;

      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
      _baseZoom = 1.0;
      _basePan = Offset.zero;

      _trays.clear();
      _machines.clear();
      _funnels.clear();
      _scale = null;
      _showSuccessPopup = false;

      if (_scenario == 1) {
        _machines.add(Machine('machA', -100, -150, targetDial: 2, isDialClickable: true, labelKey: 'lbl_machA'));
        _machines.add(Machine('machB', -100, 100, targetDial: -3, isDialClickable: true, labelKey: 'lbl_machB'));
        _trays.add(Tray('tray1', -400, -150, -3));
        _trays.add(Tray('tray2', -400, 100, 2));
        _scale = BalancerScale(250, -25);
      } else if (_scenario == 2) {
        _machines.add(Machine('machA1', -250, -150, targetDial: -2, isDialClickable: true, orientation: 'v', color: const Color(0xFFFCA5A5), labelKey: 'lbl_mach1'));
        _machines.add(Machine('machA2', -250, 100, targetDial: 2, isDialClickable: true, orientation: 'v', color: const Color(0xFFF87171), labelKey: 'lbl_mach2'));
        _machines.add(Machine('machB1', -50, -150, targetDial: 2, isDialClickable: true, orientation: 'v', color: const Color(0xFF86EFAC), labelKey: 'lbl_mach3'));
        _machines.add(Machine('machB2', -50, 100, targetDial: 3, isDialClickable: false, orientation: 'v', color: const Color(0xFF4ADE80), labelKey: 'lbl_mach4', hasSideSlot: true));
        _trays.add(Tray('tray1', -250, -300, 3));
        _trays.add(Tray('tray2', -50, -300, -2));
        _trays.add(Tray('tray3', 100, 70, 3));
        _scale = BalancerScale(250, -25);
      } else if (_scenario == 3) {
        _funnels.add(Funnel('funA', -150, -200, labelKey: 'lbl_combinerA'));
        _machines.add(Machine('machA', 150, -180, targetDial: 2, isDialClickable: true, labelKey: 'lbl_machA'));
        _machines.add(Machine('machB1', -150, 20, targetDial: 2, isDialClickable: true, labelKey: 'lbl_mach1'));
        _machines.add(Machine('machB2', -150, 160, targetDial: 2, isDialClickable: true, labelKey: 'lbl_mach2'));
        _funnels.add(Funnel('funB', 150, 90, hasCombineBtn: true, labelKey: 'lbl_finalCombiner'));
        _trays.add(Tray('tray1', -400, -250, 3));
        _trays.add(Tray('tray2', -400, -150, -1));
        _trays.add(Tray('tray3', -400, 20, 3));
        _trays.add(Tray('tray4', -400, 160, -1));
        _scale = BalancerScale(380, -40);
      } else if (_scenario == 4) {
        _trays.add(Tray('tA_in', -380, -230, -3));
        _trays.add(Tray('tA_dial1', -280, -230, 3));
        _trays.add(Tray('tA_dial2', -180, -230, -2));
        _trays.add(Tray('tB_in', -380, -150, -2));
        _trays.add(Tray('tB_dial1', -280, -150, -2));
        _trays.add(Tray('tB_dial2', -180, -150, 2));
        _machines.add(Machine('machA1', -250, 20, orientation: 'v', labelKey: 'lbl_mach1'));
        _machines.add(Machine('machA2', -250, 260, orientation: 'v', labelKey: 'lbl_mach2'));
        _machines.add(Machine('machB1', 0, 20, orientation: 'v', labelKey: 'lbl_mach1'));
        _machines.add(Machine('machB2', 0, 260, orientation: 'v', labelKey: 'lbl_mach2'));
        _scale = BalancerScale(300, 100);
      } else if (_scenario == 5) {
        _trays.add(Tray('tray_left_final', -180, 20, -6, label: '(-3) × (4 + (-2))', isDraggable: false, isBlackBox: true)..attachedTo = 'scale_left');
        _machines.add(Machine('machB1', 50, -100, labelKey: 'lbl_mult1'));
        _machines.add(Machine('machB2', 50, 100, labelKey: 'lbl_mult2'));
        _funnels.add(Funnel('funB', 220, 0, hasCombineBtn: true));
        _trays.add(Tray('t1', -100, -100, 4));
        _trays.add(Tray('t2', -20, -30, -3));
        _trays.add(Tray('t3', -100, 100, -2));
        _trays.add(Tray('t4', -20, 170, -3));
        _scale = BalancerScale(-200, 0)..leftWeight = -6;
      }
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    setState(() {
      // Scale physics
      if (_scale != null) {
        double targetAngle = (_scale!.rightWeight - _scale!.leftWeight) * 0.05;
        _scale!.angle += (targetAngle - _scale!.angle) * 0.1;
        _scale!.isBalanced = (_scale!.leftWeight == _scale!.rightWeight && _scale!.leftWeight != 0);
      }

      // Tray Attachments logic update
      for (var t in _trays) {
        if (!t.isDragging && t.attachedTo != null) {
          if (t.attachedTo == 'scale_left' && _scale != null) {
            t.x = _scale!.leftPanPos.dx;
            t.y = _scale!.leftPanPos.dy;
          } else if (t.attachedTo == 'scale_right' && _scale != null) {
            t.x = _scale!.rightPanPos.dx;
            t.y = _scale!.rightPanPos.dy;
          } else if (t.attachedTo!.endsWith('_in')) {
            String baseId = t.attachedTo!.replaceAll('_in', '');
            var f = _funnels.where((f) => f.id == baseId).firstOrNull;
            if (f != null) {
              int idx = f.inputTrays.indexOf(t);
              t.x = f.x - 40 + idx * 80;
              t.y = f.y - 70;
            } else {
              var m = _machines.where((m) => m.id == baseId).firstOrNull;
              if (m != null) {
                if (m.orientation == 'v') {
                  t.x = m.x;
                  t.y = m.y - 120;
                } else {
                  t.x = m.x - 120;
                  t.y = m.y;
                }
              }
            }
          } else if (t.attachedTo!.endsWith('_dial')) {
            String baseId = t.attachedTo!.replaceAll('_dial', '');
            var m = _machines.where((m) => m.id == baseId).firstOrNull;
            if (m != null) {
              if (m.hasSideSlot) {
                t.x = m.x + 110;
                t.y = m.y;
              } else if (m.orientation == 'v') {
                t.x = m.x;
                t.y = m.y + 40;
              } else {
                t.x = m.x;
                t.y = m.y + 40;
              }
            }
          }
        }
      }

      // Process Machines
      for (var m in _machines) {
        if (!m.isProcessing && !m.outDone && m.inputTray != null && m.dial != null) {
          m.isProcessing = true;
          m.processTimer = 0;
          _playSound('tick');
        }
        if (m.isProcessing) {
          m.processTimer++;
          if (m.processTimer > 12) {
            m.isProcessing = false;
            m.outDone = true;
            _playSound('pop');
            int outVal = m.inputTray!.val * m.dial!;
            double outX = m.orientation == 'v' ? m.x : m.x + 150;
            double outY = m.orientation == 'v' ? m.y + 120 : m.y;
            Tray newT = Tray('${m.id}_out', outX, outY, outVal);
            _trays.add(newT);

            // Auto Feed
            if (m.id == 'machA1' && _scenario == 2) {
              var n = _machines.firstWhere((x) => x.id == 'machA2');
              n.inputTray = newT;
              newT.attachedTo = 'machA2_in';
            }
            if (m.id == 'machB1' && _scenario == 2) {
              var n = _machines.firstWhere((x) => x.id == 'machB2');
              n.inputTray = newT;
              newT.attachedTo = 'machB2_in';
            }
            if (m.id == 'machA1' && _scenario == 4) {
              var n = _machines.firstWhere((x) => x.id == 'machA2');
              n.inputTray = newT;
              newT.attachedTo = 'machA2_in';
            }
            if (m.id == 'machB1' && _scenario == 4) {
              var n = _machines.firstWhere((x) => x.id == 'machB2');
              n.inputTray = newT;
              newT.attachedTo = 'machB2_in';
            }

            if (m.id == 'machA' && _scenario == 3) {
              newT.x = m.x + 100;
              newT.y = m.y;
            }
            if ((m.id == 'machB1' || m.id == 'machB2') && (_scenario == 3 || _scenario == 5)) {
              var f = _funnels.firstWhere((x) => x.id == 'funB');
              f.inputTrays.add(newT);
              newT.attachedTo = 'funB_in';
            }
            _evaluateStepConditions();
          }
        }
      }

      // Process Funnels
      for (var f in _funnels) {
        if (!f.isProcessing && !f.outDone) {
          if (f.id == 'funA' && f.inputTrays.length == 2) {
            f.isProcessing = true;
            f.processTimer = 0;
            _playSound('weld');
          }
          if (f.id == 'funB' && f.inputTrays.length == 2) {
            f.isCombineReady = true;
            if (f.combineActive) {
              f.combineActive = false;
              f.isProcessing = true;
              f.processTimer = 0;
              _playSound('weld');
            }
          }
        }
        if (f.isProcessing) {
          f.processTimer++;
          if (f.processTimer > 10) {
            f.isProcessing = false;
            f.outDone = true;
            _playSound('pop');
            int sum = f.inputTrays[0].val + f.inputTrays[1].val;
            for (var t in f.inputTrays) {
              t.attachedTo = 'hidden';
            }
            Tray newT = Tray('${f.id}_out', f.x, f.y + 70, sum);
            _trays.add(newT);
            if (_scenario == 3 && f.id == 'funA') {
              var m = _machines.firstWhere((x) => x.id == 'machA');
              m.inputTray = newT;
              newT.attachedTo = 'machA_in';
            }
            if (_scenario == 5 && f.id == 'funB') {
              _scale!.rightWeight = newT.val;
              newT.attachedTo = 'scale_right';
            }
            _evaluateStepConditions();
          }
        }
      }
    });
  }

  void _evaluateStepConditions() {
    int totalSteps = (_scenario == 1) ? 5 : (_scenario == 2) ? 5 : (_scenario == 3) ? 6 : (_scenario == 4) ? 3 : 3;
    if (_step >= totalSteps) return;

    bool stepComplete = false;
    
    // Updated step conditions logic for smooth scenario progression
    if (_scenario == 1) {
      var mA = _machines.firstWhere((m) => m.id == 'machA');
      var mB = _machines.firstWhere((m) => m.id == 'machB');
      if (_step == 0 && mA.outDone) stepComplete = true; 
      if (_step == 1 && mA.outDone) stepComplete = true; // Covers initial dial set
      if (_step == 2 && mB.outDone) stepComplete = true; // Wait for tray input and output 
      if (_step == 3 && mB.outDone) stepComplete = true;
      if (_step == 4 && _scale!.leftWeight == -6 && _scale!.rightWeight == -6) stepComplete = true;
    } else if (_scenario == 2) {
      var mA1 = _machines.firstWhere((m) => m.id == 'machA1');
      var mA2 = _machines.firstWhere((m) => m.id == 'machA2');
      var mB1 = _machines.firstWhere((m) => m.id == 'machB1');
      var mB2 = _machines.firstWhere((m) => m.id == 'machB2');
      if (_step == 0 && mA1.outDone) stepComplete = true;
      if (_step == 1 && mA2.outDone) stepComplete = true;
      if (_step == 2 && mB1.outDone) stepComplete = true;
      if (_step == 3 && mB2.outDone) stepComplete = true;
      if (_step == 4 && _scale!.leftWeight == -12 && _scale!.rightWeight == -12) stepComplete = true;
    } else if (_scenario == 3) {
      var fA = _funnels.firstWhere((f) => f.id == 'funA');
      var mA = _machines.firstWhere((m) => m.id == 'machA');
      var mB1 = _machines.firstWhere((m) => m.id == 'machB1');
      var mB2 = _machines.firstWhere((m) => m.id == 'machB2');
      var fB = _funnels.firstWhere((f) => f.id == 'funB');
      if (_step == 0 && fA.outDone) stepComplete = true;
      if (_step == 1 && mA.outDone) stepComplete = true;
      if (_step == 2 && mB1.outDone) stepComplete = true;
      if (_step == 3 && mB2.outDone) stepComplete = true;
      if (_step == 4 && fB.outDone) stepComplete = true;
      if (_step == 5 && _scale!.leftWeight == 4 && _scale!.rightWeight == 4) stepComplete = true;
    } else if (_scenario == 4) {
      var mA2 = _machines.firstWhere((m) => m.id == 'machA2');
      var mB2 = _machines.firstWhere((m) => m.id == 'machB2');
      if (_step == 0 && mA2.outDone && _trays.any((t) => t.id == 'machA2_out' && t.val == -18)) stepComplete = true;
      if (_step == 1 && mB2.outDone && _trays.any((t) => t.id == 'machB2_out' && t.val == -18)) stepComplete = true;
      if (_step == 2 && _scale!.leftWeight == -18 && _scale!.rightWeight == -18) stepComplete = true;
    } else if (_scenario == 5) {
      var mB1 = _machines.firstWhere((m) => m.id == 'machB1');
      var mB2 = _machines.firstWhere((m) => m.id == 'machB2');
      if (_step == 0) stepComplete = true; // Auto advance observation step
      if (_step == 1 && mB1.outDone && mB2.outDone) stepComplete = true;
      if (_step == 2 && _scale!.rightWeight == -6) stepComplete = true;
    }

    if (stepComplete) {
      _advanceStep();
      if (_step >= totalSteps) _checkScenarioSuccess();
    }
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
    _evaluateStepConditions();
  }

  void _checkScenarioSuccess() {
    _playSound('success');
    _scrollToActiveStep();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showSuccessPopup = true);
    });
  }

  void _scrollToActiveStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sidebarScrollController.hasClients) {
        _sidebarScrollController.animateTo(
          _sidebarScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Offset _screenToWorld(Offset screenPos, Size size) {
    double cx = size.width / 2 + _panX;
    double cy = size.height / 2 + _panY;
    return Offset((screenPos.dx - cx) / _zoom, (screenPos.dy - cy) / _zoom);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    Offset pt = _screenToWorld(details.localPosition, size);
    bool uiClicked = false;

    for (var ent in _machines) {
      if (ent.isDialClickable && !ent.outDone && !ent.isProcessing) {
        Rect hBox = ent.orientation == 'v' ? Rect.fromLTWH(ent.x - 45, ent.y + 20, 90, 60) : Rect.fromLTWH(ent.x - 45, ent.y + 10, 90, 60);
        if (hBox.contains(pt) && ent.inputTray != null) {
          setState(() => ent.dial = ent.targetDial);
          _playSound('tick');
          uiClicked = true;
          _evaluateStepConditions();
        }
      }
    }
    for (var ent in _funnels) {
      if (ent.hasCombineBtn && ent.isCombineReady && !ent.outDone) {
        if (_hitTestBox(ent.x - 80, ent.y + 10, 80, 30, pt)) {
          setState(() => ent.combineActive = true);
          _playSound('tick');
          uiClicked = true;
          _evaluateStepConditions();
        }
      }
    }
    if (uiClicked) return;
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    for (var tray in _trays.reversed) {
      if (tray.isDraggable && tray.attachedTo != 'hidden' && _hitTestBox(tray.x - 40, tray.y - 25, 80, 50, pt)) {
        setState(() {
          _activeTray = tray;
          tray.isDragging = true;
          _dragOffset = Offset(tray.x - pt.dx, tray.y - pt.dy);
          _toolDragging = true;
          if (tray.attachedTo != null) {
            if (tray.attachedTo == 'scale_left') _scale!.leftWeight = 0;
            if (tray.attachedTo == 'scale_right') _scale!.rightWeight = 0;
            tray.attachedTo = null;
          }
        });
        _playSound('snap');
        return;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      _mouseX = pt.dx;
      _mouseY = pt.dy;
      if (_toolDragging && _activeTray != null) {
        _activeTray!.x = _mouseX + _dragOffset.dx;
        _activeTray!.y = _mouseY + _dragOffset.dy;

        // Hover zones
        if (_scale != null) {
          _scale!.leftZoneActive = _hitTestBox(_scale!.x - 180, _scale!.y - 20, 100, 100, pt);
          _scale!.rightZoneActive = _hitTestBox(_scale!.x + 80, _scale!.y - 20, 100, 100, pt);
        }
        for (var m in _machines) {
          m.inputZoneActive = false;
          m.dialZoneActive = false;
          if (!m.outDone) {
            if (m.orientation == 'v') {
              if (m.inputTray == null && _hitTestBox(m.x - 40, m.y - 150, 80, 80, pt)) m.inputZoneActive = true;
              if (m.hasSideSlot && _hitTestBox(m.x + 70, m.y - 30, 80, 60, pt)) m.dialZoneActive = true;
              if (!m.isDialClickable && !m.hasSideSlot && _hitTestBox(m.x - 40, m.y + 20, 80, 60, pt)) m.dialZoneActive = true;
            } else {
              if (m.inputTray == null && _hitTestBox(m.x - 140, m.y - 40, 80, 80, pt)) m.inputZoneActive = true;
              if (!m.isDialClickable && _hitTestBox(m.x - 40, m.y + 15, 80, 50, pt)) m.dialZoneActive = true;
            }
          }
        }
        for (var f in _funnels) {
          f.inputZoneActive = (!f.outDone && f.inputTrays.length < 2 && _hitTestBox(f.x - 80, f.y - 90, 160, 80, pt));
        }
      } else {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.35, 1.5);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_toolDragging && _activeTray != null) {
      setState(() {
        _activeTray!.isDragging = false;
        bool snapped = false;

        if (_scale != null && _scale!.leftZoneActive) {
          _activeTray!.attachedTo = 'scale_left';
          _scale!.leftWeight = _activeTray!.val;
          snapped = true;
        } else if (_scale != null && _scale!.rightZoneActive) {
          _activeTray!.attachedTo = 'scale_right';
          _scale!.rightWeight = _activeTray!.val;
          snapped = true;
        } else {
          for (var m in _machines) {
            if (m.inputZoneActive) {
              _activeTray!.attachedTo = '${m.id}_in';
              m.inputTray = _activeTray;
              snapped = true;
              break;
            }
            if (m.dialZoneActive) {
              _activeTray!.attachedTo = '${m.id}_dial';
              m.dial = _activeTray!.val;
              snapped = true;
              break;
            }
          }
          if (!snapped) {
            for (var f in _funnels) {
              if (f.inputZoneActive) {
                _activeTray!.attachedTo = '${f.id}_in';
                f.inputTrays.add(_activeTray!);
                snapped = true;
                break;
              }
            }
          }
        }

        if (snapped) {
          _playSound('pop');
          _evaluateStepConditions();
        } else {
          _activeTray!.x = _activeTray!.startX;
          _activeTray!.y = _activeTray!.startY;
          _playSound('error');
        }

        if (_scale != null) {
          _scale!.leftZoneActive = false;
          _scale!.rightZoneActive = false;
        }
        for (var m in _machines) {
          m.inputZoneActive = false;
          m.dialZoneActive = false;
        }
        for (var f in _funnels) {
          f.inputZoneActive = false;
        }

        _toolDragging = false;
        _activeTray = null;
      });
    }
  }

  // Robust HTML text parser to strip unwanted tags and support Bold mapping
  Widget _buildRichText(String text, Color defaultColor) {
    String cleanStr = text.replaceAll(RegExp(r'<br\s*\/?>'), '\n').replaceAll('`', '');
    List<TextSpan> spans = [];
    List<String> bParts = cleanStr.split('<b>');

    for (int i = 0; i < bParts.length; i++) {
      if (bParts[i].contains('</b>')) {
        var subParts = bParts[i].split('</b>');
        spans.add(TextSpan(text: subParts[0], style: TextStyle(fontWeight: FontWeight.bold, color: defaultColor)));
        if (subParts.length > 1 && subParts[1].isNotEmpty) {
          spans.add(TextSpan(text: subParts[1], style: TextStyle(color: defaultColor)));
        }
      } else {
        if (bParts[i].isNotEmpty) {
          spans.add(TextSpan(text: bParts[i], style: TextStyle(color: defaultColor)));
        }
      }
    }
    return RichText(text: TextSpan(style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans', height: 1.4), children: spans));
  }

  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);

    int totalSteps = (_scenario == 1) ? 5 : (_scenario == 2) ? 5 : (_scenario == 3) ? 6 : (_scenario == 4) ? 3 : 3;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(5, 0))],
      ),
      // Utilizing SingleChildScrollView to make the whole sidebar scrollable entirely from top to bottom
      child: SingleChildScrollView(
        controller: _sidebarScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.precision_manufacturing, color: Colors.indigoAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('appTitle'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(t('appSubtitle'), style: TextStyle(color: textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleLanguage,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, side: BorderSide(color: border), padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.language, size: 16),
                          const SizedBox(width: 6),
                          Flexible(child: Text(_lang.toUpperCase(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleReset,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.2), foregroundColor: Colors.redAccent, side: BorderSide(color: Colors.redAccent.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, size: 16),
                          const SizedBox(width: 6),
                          Flexible(child: Text(t('resetBtn'), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Divider(color: border),
            // Scenario Selector
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('selectScenario'), style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _scenario,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        items: [1, 2, 3, 4, 5].map((id) => DropdownMenuItem(value: id, child: Text(t('s${id}_title')))).toList(),
                        onChanged: (val) {
                          if (val != null) _loadScenario(val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Objective
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.my_location, color: Colors.pinkAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(t('learnLbl'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(t('s${_scenario}_obj'), style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Steps
                  ...List.generate(totalSteps, (i) {
                    bool isPast = i < _step;
                    bool isCurrent = i == _step;
                    Color stepBg = isCurrent ? Colors.indigo.withOpacity(0.1) : (isPast ? Colors.green.withOpacity(0.05) : (Colors.white.withOpacity(0.02)));
                    Color stepBorder = isCurrent ? Colors.indigoAccent : (isPast ? Colors.green.withOpacity(0.3) : Colors.transparent);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: stepBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: stepBorder)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isPast
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                              : Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(color: isCurrent ? Colors.indigoAccent : Colors.grey, shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${t('stepLabel')} ${i + 1}", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                _buildRichText(t('s${_scenario}_step${i + 1}_task'), textPrimary),
                                if (isPast) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: _buildRichText(t('s${_scenario}_step${i + 1}_out'), Colors.green.shade700),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Summary
                  if (_step == totalSteps)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(t('summaryTitle'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildRichText(t('s${_scenario}_sum'), textPrimary),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Footer stretching entire width of sidebar directly without any outer wrappers at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 24),
              color: const Color(0xFF0F172A),
              child: const Center(
                child: Text("© ZeroScienceLab - Fall in love with math and Science", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38; // 38% width as requested
    if (sidebarWidth < 300) sidebarWidth = 300;

    int totalSteps = (_scenario == 1) ? 5 : (_scenario == 2) ? 5 : (_scenario == 3) ? 6 : (_scenario == 4) ? 3 : 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light background for the canvas like the original
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // MAIN CANVAS
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(behavior: HitTestBehavior.opaque, 
                      onTapDown: (d) => _handleTapDown(d, constraints.biggest),
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: IntegerFactoryPainter(
                          scenario: _scenario,
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          trays: _trays,
                          machines: _machines,
                          funnels: _funnels,
                          scale: _scale,
                          t: t,
                          screenSize: constraints.biggest,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // HUD Overlays
            if (_step < totalSteps)
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth + 40 : 40,
                right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(top: BorderSide(color: Colors.indigoAccent, width: 4)),
                        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.indigoAccent.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.info_outline, color: Colors.indigoAccent),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(t('s${_scenario}_hud${_step + 1}'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            // MENU TOGGLE TOP LEFT
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound('tick');
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
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

            // SUCCESS POPUP
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        width: 450,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24)),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 20)]),
                                  child: const Icon(Icons.flag, color: Colors.white, size: 40),
                                ),
                                const SizedBox(height: 24),
                                Text(t('summaryTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                _buildRichText(t('s${_scenario}_sum'), Colors.white),
                                if (_scenario < 5) ...[
                                  const SizedBox(height: 24),
                                  Text(t('infoNextScen'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                                ],
                                if (_scenario == 5) ...[
                                  const SizedBox(height: 24),
                                  Text(t('finalDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                                ],
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _playSound('pop');
                                    setState(() => _showSuccessPopup = false);
                                  },
                                  icon: const Icon(Icons.close),
                                  label: Text(t('closeBtn')),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    backgroundColor: Colors.indigoAccent,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white54),
                                onPressed: () {
                                  _playSound('pop');
                                  setState(() => _showSuccessPopup = false);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // CURTAIN
            AnimatedSlide(
              offset: _showCurtain ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]),
                          child: const Icon(Icons.precision_manufacturing, size: 80, color: Colors.indigoAccent),
                        ),
                        Text(t('appTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 16),
                        Text(t('appSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () {
                            _playSound('pop');
                            setState(() => _showCurtain = false);
                          },
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(t('enterLab')),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shadowColor: Colors.indigoAccent.withOpacity(0.5),
                            textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
}

// ==========================================
// CUSTOM PAINTER
// ==========================================
class IntegerFactoryPainter extends CustomPainter {
  final int scenario;
  final double zoom;
  final double panX, panY;
  final List<Tray> trays;
  final List<Machine> machines;
  final List<Funnel> funnels;
  final BalancerScale? scale;
  final Function(String) t;
  final Size screenSize;

  IntegerFactoryPainter({
    required this.scenario,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.trays,
    required this.machines,
    required this.funnels,
    required this.scale,
    required this.t,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Background conveyors based on scenario
    if (scenario == 1) {
      _drawTextOutline(canvas, t('lbl_lineA_val'), -400, -220, 24, const Color(0xFF1E293B), Colors.transparent, 0, align: TextAlign.left);
      _drawTextOutline(canvas, t('lbl_lineB_val'), -400, 30, 24, const Color(0xFF1E293B), Colors.transparent, 0, align: TextAlign.left);
      _drawConveyor(canvas, -200, -100, 480, 'h');
      _drawConveyor(canvas, -200, 150, 480, 'h');
    } else if (scenario == 2) {
      _drawTextOutline(canvas, t('lbl_lineA'), -250, -350, 24, const Color(0xFF1E293B), Colors.transparent, 0);
      _drawTextOutline(canvas, t('lbl_lineB'), -50, -350, 24, const Color(0xFF1E293B), Colors.transparent, 0);
      _drawConveyor(canvas, -250, -20, 560, 'v');
      _drawConveyor(canvas, -50, -20, 560, 'v');
    } else if (scenario == 3) {
      _drawConveyor(canvas, -200, -110, 400, 'h');
      _drawConveyor(canvas, 150, -110, 200, 'h');
      _drawConveyor(canvas, -200, 20, 300, 'h');
      _drawConveyor(canvas, -200, 160, 300, 'h');
    } else if (scenario == 4) {
      _drawRoundedRect(canvas, -490, -280, 360, 180, 10, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 4);
      _drawRoundedRect(canvas, -480, -270, 340, 30, 0, const Color(0xFF94A3B8), const Color(0xFF0F172A), 4);
      _drawTextOutline(canvas, t('lbl_sandbox'), -310, -255, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('lbl_lineA'), -250, -60, 20, const Color(0xFF1E293B), Colors.transparent, 0);
      _drawTextOutline(canvas, t('lbl_lineB'), 0, -60, 20, const Color(0xFF1E293B), Colors.transparent, 0);
      _drawConveyor(canvas, -250, 150, 450, 'v');
      _drawConveyor(canvas, 0, 150, 450, 'v');
    } else if (scenario == 5) {
      _drawConveyor(canvas, -150, -20, 560, 'v');
      _drawConveyor(canvas, 100, -100, 400, 'h');
      _drawConveyor(canvas, 100, 100, 400, 'h');
    }

    if (scale != null) _drawScale(canvas, scale!);
    for (var f in funnels) _drawFunnel(canvas, f);
    for (var m in machines) _drawMachine(canvas, m);

    // Draw active tray on top
    List<Tray> sortedTrays = List.from(trays)..sort((a, b) => (a.isDragging == b.isDragging) ? 0 : (a.isDragging ? 1 : -1));
    for (var t in sortedTrays) {
      if (t.attachedTo != 'hidden') _drawTray(canvas, t);
    }

    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double strokeW = 1.0]) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && strokeW > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
  }

  void _drawTextOutline(Canvas canvas, String text, double x, double y, double fontSize, Color fill, Color outline, double outlineW, {TextAlign align = TextAlign.center}) {
    TextPainter tpStroke = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = outlineW
            ..color = outline
            ..strokeJoin = StrokeJoin.round,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tpStroke.layout();
    double dx = align == TextAlign.center ? x - tpStroke.width / 2 : x;
    double dy = y - tpStroke.height / 2;
    if (outlineW > 0) tpStroke.paint(canvas, Offset(dx, dy));

    TextPainter tpFill = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tpFill.layout();
    tpFill.paint(canvas, Offset(dx, dy));
  }

  void _drawConveyor(Canvas canvas, double x, double y, double length, String orient) {
    canvas.save();
    canvas.translate(x, y);
    Color beltColor = const Color(0xFFCBD5E1);
    Color strokeCol = const Color(0xFF0F172A);
    Color rollerCol = const Color(0xFF94A3B8);

    if (orient == 'h') {
      _drawRoundedRect(canvas, -length / 2, -12, length, 24, 12, beltColor, strokeCol, 4);
      for (double i = -length / 2 + 20; i < length / 2 - 10; i += 30) {
        canvas.drawCircle(Offset(i, 0), 6, Paint()..color = rollerCol);
        canvas.drawCircle(Offset(i, 0), 6, Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 1);
      }
    } else {
      _drawRoundedRect(canvas, -12, -length / 2, 24, length, 12, beltColor, strokeCol, 4);
      for (double i = -length / 2 + 20; i < length / 2 - 10; i += 30) {
        canvas.drawCircle(Offset(0, i), 6, Paint()..color = rollerCol);
        canvas.drawCircle(Offset(0, i), 6, Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 1);
      }
    }
    canvas.restore();
  }

  void _drawToken(Canvas canvas, double cx, double cy, int val, [double scale = 1.0]) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale, scale);
    bool isPos = val > 0;
    Color fill = isPos ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    Color highlight = isPos ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);
    Color stroke = const Color(0xFF0F172A);

    canvas.drawCircle(Offset.zero, 12, Paint()..color = fill);
    canvas.drawCircle(Offset.zero, 12, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(Offset.zero, 6, Paint()..color = highlight);
    canvas.restore();
  }

  void _drawTray(Canvas canvas, Tray tray) {
    canvas.save();
    canvas.translate(tray.x, tray.y);

    if (tray.isBlackBox) {
      _drawRoundedRect(canvas, -70, -40, 140, 80, 10, const Color(0xFF1E293B), const Color(0xFF0F172A), 4);
      _drawRoundedRect(canvas, -60, -30, 120, 20, 4, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 2);
      _drawTextOutline(canvas, tray.label, 0, -20, 12, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawRoundedRect(canvas, -35, 0, 70, 30, 4, const Color(0xFF0F172A), const Color(0xFF0F172A), 2);
      for (int i = 0; i < 6; i++) {
        _drawToken(canvas, -20 + (i % 3) * 20, 8 + (i ~/ 3) * 15, -1, 0.6);
      }
    } else {
      _drawRoundedRect(canvas, -40, -25, 80, 50, 6, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 3);
      _drawRoundedRect(canvas, -35, -20, 70, 40, 4, const Color(0xCCFFFFFF), const Color(0xFF0F172A), 2);

      if (tray.val != 0) {
        int absVal = tray.val.abs();
        int cols = absVal > 15 ? 6 : (absVal > 9 ? 5 : (absVal > 4 ? 4 : (absVal > 3 ? 3 : absVal)));
        int rows = (absVal / cols).ceil();
        double scaleFactor = absVal > 15 ? 0.45 : (absVal > 9 ? 0.55 : 0.8);
        double spacing = 24 * scaleFactor;
        double startX = -((cols - 1) * spacing) / 2;
        double startY = -((rows - 1) * spacing) / 2;
        for (int i = 0; i < absVal; i++) {
          _drawToken(canvas, startX + (i % cols) * spacing, startY + (i ~/ cols) * spacing, tray.val, scaleFactor);
        }
      }
    }

    if (tray.isDragging) {
      _drawRoundedRect(canvas, -44, -29, 88, 58, 8, Colors.transparent, const Color(0xFF6366F1), 4);
    }
    canvas.restore();
  }

  void _drawMachine(Canvas canvas, Machine mach) {
    canvas.save();
    canvas.translate(mach.x, mach.y);
    Color strokeCol = const Color(0xFF0F172A);

    if (mach.orientation == 'v') {
      _drawRoundedRect(canvas, -70, -80, 140, 160, 8, mach.color, strokeCol, 4);

      _drawRoundedRect(canvas, -40, -160, 80, 80, 0, const Color(0x99FFFFFF), strokeCol, 4);
      if (mach.inputZoneActive) _drawRoundedRect(canvas, -40, -160, 80, 80, 0, const Color(0x99FACC15), Colors.transparent, 0);
      if (mach.isProcessing && mach.dial != null && mach.dial! < 0) _drawRoundedRect(canvas, -40, -160, 80, 80, 0, const Color(0xCCFF4500), Colors.transparent, 0);

      _drawRoundedRect(canvas, -40, 80, 80, 80, 0, const Color(0x99FFFFFF), strokeCol, 4);

      if (mach.hasSideSlot) {
        _drawRoundedRect(canvas, 70, -30, 80, 60, 0, const Color(0x99FFFFFF), strokeCol, 4);
        if (mach.dialZoneActive) _drawRoundedRect(canvas, 70, -30, 80, 60, 0, const Color(0x99FACC15), Colors.transparent, 0);
      }

      if (mach.labelKey.isNotEmpty) {
        List<String> lines = t(mach.labelKey).split('\n');
        _drawTextOutline(canvas, lines[0], 0, -60, 16, strokeCol, Colors.transparent, 0);
        if (lines.length > 1) _drawTextOutline(canvas, lines[1], 0, -42, 16, strokeCol, Colors.transparent, 0);
      }

      _drawRoundedRect(canvas, -40, -20, 80, 45, 6, strokeCol, strokeCol, 3);
      String inVal = mach.inputTray != null ? (mach.inputTray!.val > 0 ? '+' : '') + mach.inputTray!.val.toString() : '?';
      Color inCol = mach.inputTray != null && mach.inputTray!.val < 0 ? const Color(0xFFEF4444) : const Color(0xFF4ADE80);
      _drawTextOutline(canvas, inVal, 0, 3, 26, inCol, Colors.transparent, 0);

      _drawRoundedRect(canvas, -35, 35, 70, 35, 6, const Color(0xFFF8FAFC), strokeCol, 3);
      String dText = mach.dial != null ? "x ${mach.dial}" : 'x ?';
      _drawTextOutline(canvas, dText, 0, 52, 18, strokeCol, Colors.transparent, 0);

      if (mach.dialZoneActive && !mach.hasSideSlot) {
        _drawRoundedRect(canvas, -40, 30, 80, 45, 8, const Color(0x80FACC15), Colors.transparent, 0);
      }
    } else {
      _drawRoundedRect(canvas, -60, -70, 120, 140, 8, mach.color, strokeCol, 4);

      if (mach.labelKey.isNotEmpty) {
        List<String> lines = t(mach.labelKey).split('\n');
        _drawTextOutline(canvas, lines[0], 0, -55, 13, strokeCol, Colors.transparent, 0);
        if (lines.length > 1) _drawTextOutline(canvas, lines[1], 0, -42, 13, strokeCol, Colors.transparent, 0);
      }

      _drawRoundedRect(canvas, -140, -40, 80, 80, 0, const Color(0x99FFFFFF), strokeCol, 4);
      if (mach.inputZoneActive) _drawRoundedRect(canvas, -140, -40, 80, 80, 0, const Color(0x99FACC15), Colors.transparent, 0);
      if (mach.isProcessing && mach.dial != null && mach.dial! < 0) _drawRoundedRect(canvas, -140, -40, 80, 80, 0, const Color(0xCCFF4500), Colors.transparent, 0);

      _drawRoundedRect(canvas, 60, -40, 80, 80, 0, const Color(0x99FFFFFF), strokeCol, 4);

      _drawRoundedRect(canvas, -35, -25, 70, 35, 5, strokeCol, strokeCol, 3);
      String inVal = mach.inputTray != null ? (mach.inputTray!.val > 0 ? '+' : '') + mach.inputTray!.val.toString() : '?';
      Color inCol = mach.inputTray != null && mach.inputTray!.val < 0 ? const Color(0xFFEF4444) : const Color(0xFF4ADE80);
      _drawTextOutline(canvas, inVal, 0, -7, 22, inCol, Colors.transparent, 0);

      _drawRoundedRect(canvas, -40, 15, 80, 45, 6, const Color(0xFFF8FAFC), strokeCol, 3);
      String dText = mach.dial != null ? "x ${mach.dial}" : 'x ?';
      _drawTextOutline(canvas, dText, 15, 37, 16, strokeCol, Colors.transparent, 0);

      canvas.drawCircle(const Offset(-20, 37), 12, Paint()..color = const Color(0xFF64748B));
      canvas.drawCircle(const Offset(-20, 37), 12, Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 1);
      double dAngle = mach.dial != null ? (mach.dial! * pi / 4) : -pi / 2;
      canvas.drawLine(const Offset(-20, 37), Offset(-20 + 8 * cos(dAngle), 37 + 8 * sin(dAngle)), Paint()..color = strokeCol..strokeWidth = 2);

      if (mach.dialZoneActive) {
        _drawRoundedRect(canvas, -45, 10, 90, 55, 8, const Color(0x80FACC15), Colors.transparent, 0);
      }
    }
    canvas.restore();
  }

  void _drawFunnel(Canvas canvas, Funnel fun) {
    canvas.save();
    canvas.translate(fun.x, fun.y);
    Color strokeCol = const Color(0xFF0F172A);

    if (fun.labelKey.isNotEmpty) {
      List<String> lines = t(fun.labelKey).split('\n');
      _drawTextOutline(canvas, lines[0], 0, -95, 18, strokeCol, Colors.transparent, 0);
      if (lines.length > 1) _drawTextOutline(canvas, lines[1], 0, -75, 18, strokeCol, Colors.transparent, 0);
    }

    if (fun.inputZoneActive) {
      _drawRoundedRect(canvas, -75, -60, 150, 50, 10, const Color(0x80FACC15), Colors.transparent, 0);
    }

    Path path = Path()
      ..moveTo(-70, -40)
      ..lineTo(70, -40)
      ..lineTo(20, 20)
      ..lineTo(20, 70)
      ..lineTo(-20, 70)
      ..lineTo(-20, 20)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xCCF8FAFC));
    canvas.drawPath(path, Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 4..strokeJoin = StrokeJoin.round);

    canvas.drawOval(Rect.fromCenter(center: const Offset(0, -40), width: 140, height: 20), Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 4);

    if (fun.hasCombineBtn) {
      Color btnColor = fun.isCombineReady ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8);
      _drawRoundedRect(canvas, -90, 10, 80, 35, 10, btnColor, strokeCol, 4);
      _drawTextOutline(canvas, t('lbl_combineBtn'), -50, 28, 14, strokeCol, Colors.transparent, 0);
      if (fun.combineActive) {
        _drawRoundedRect(canvas, -90, 10, 80, 35, 10, Colors.transparent, const Color(0xFFFACC15), 4);
      }
    }

    if (fun.isProcessing) {
      _drawTextOutline(canvas, t('lbl_zap'), 0, -10, 28, const Color(0xFFFACC15), Colors.transparent, 0);
    }
    canvas.restore();
  }

  void _drawScale(Canvas canvas, BalancerScale s) {
    canvas.save();
    canvas.translate(s.x, s.y);
    Color strokeCol = const Color(0xFF0F172A);

    _drawRoundedRect(canvas, -60, 100, 120, 30, 15, const Color(0xFFB45309), strokeCol, 4);
    _drawRoundedRect(canvas, -10, -50, 20, 150, 5, const Color(0xFFD97706), strokeCol, 4);

    canvas.save();
    canvas.translate(0, -40);
    canvas.rotate(s.angle);

    _drawRoundedRect(canvas, -140, -10, 280, 20, 10, const Color(0xFFFCD34D), strokeCol, 4);
    canvas.drawCircle(Offset.zero, 14, Paint()..color = const Color(0xFFFEF08A));
    canvas.drawCircle(Offset.zero, 14, Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.restore();

    if (s.leftZoneActive) _drawRoundedRect(canvas, -180, -20, 100, 100, 8, const Color(0x80FACC15), Colors.transparent, 0);
    if (s.rightZoneActive) _drawRoundedRect(canvas, 80, -20, 100, 100, 8, const Color(0x80FACC15), Colors.transparent, 0);

    double Lpx = -130 * cos(s.angle);
    double Lpy = -40 - 130 * sin(s.angle);
    canvas.save();
    canvas.translate(Lpx, Lpy);
    canvas.drawLine(const Offset(-40, 100), Offset.zero, Paint()..color = strokeCol..strokeWidth = 3);
    canvas.drawLine(const Offset(40, 100), Offset.zero, Paint()..color = strokeCol..strokeWidth = 3);
    Path pLeft = Path()..moveTo(-50, 100)..lineTo(50, 100)..lineTo(30, 120)..lineTo(-30, 120)..close();
    canvas.drawPath(pLeft, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawPath(pLeft, Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 4);
    s.leftPanPos = Offset(s.x + Lpx, s.y + Lpy + 85);
    canvas.restore();

    double Rpx = 130 * cos(s.angle);
    double Rpy = -40 + 130 * sin(s.angle);
    canvas.save();
    canvas.translate(Rpx, Rpy);
    canvas.drawLine(const Offset(-40, 100), Offset.zero, Paint()..color = strokeCol..strokeWidth = 3);
    canvas.drawLine(const Offset(40, 100), Offset.zero, Paint()..color = strokeCol..strokeWidth = 3);
    Path pRight = Path()..moveTo(-50, 100)..lineTo(50, 100)..lineTo(30, 120)..lineTo(-30, 120)..close();
    canvas.drawPath(pRight, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawPath(pRight, Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 4);
    s.rightPanPos = Offset(s.x + Rpx, s.y + Rpy + 85);
    canvas.restore();

    if (s.isBalanced) {
      _drawRoundedRect(canvas, -120, 140, 240, 40, 8, const Color(0xFF22C55E), const Color(0xFF166534), 4);
      _drawTextOutline(canvas, t('lbl_proofSuccess'), 0, 160, 18, Colors.white, Colors.transparent, 0);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IntegerFactoryPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA (EN, HI, TE)
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'appTitle': "The Integer Factory",
    'appSubtitle': "Class 7 • PROPERTIES OF MULTIPLICATION",
    'enterLab': "Enter Factory",
    'settings': "Settings",
    'theme': "Theme",
    'darkMode': "Switch to Dark Mode",
    'lightMode': "Switch to Light Mode",
    'boardFontSize': "Text Size",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'proceedBtn': "Proceed",
    'combineBtn': "Combine",
    'learnLbl': "What We Learn:",
    'closeBtn': "Close",
    'summaryTitle': "Discovery Made!",
    'resetBtn': "Reset",
    'finishLab': "Finish",
    'nextScenario': "Next Scenario",
    'infoNextScen': "Please select the next scenario from the dropdown above.",
    'labCompleted': "Lab Completed!",
    'finalDesc': "You have successfully mastered the Properties of Multiplication! You discovered how Commutative, Associative, and Distributive rules work.",
    'lbl_lineA': "Line A",
    'lbl_lineB': "Line B",
    'lbl_lineA_val': "Line A (-3)",
    'lbl_lineB_val': "Line B (+2)",
    'lbl_machA': "Machine A",
    'lbl_machB': "Machine B",
    'lbl_mach1': "Machine 1",
    'lbl_mach2': "Machine 2",
    'lbl_mach3': "Machine 3",
    'lbl_mach4': "Machine 4",
    'lbl_mult1': "Multiplier 1",
    'lbl_mult2': "Multiplier 2",
    'lbl_combinerA': "LINE A\nCOMBINER",
    'lbl_combinerB': "LINE B\nCOMBINER",
    'lbl_finalCombiner': "FINAL\nCOMBINER",
    'lbl_sandbox': "SUPPLY SANDBOX",
    'lbl_proofSuccess': "Proof Successful!",
    'lbl_combineBtn': "COMBINE",
    'lbl_zap': "💥 ZAP!",
    'lbl_click': "CLICK",
    'lbl_multX2': "MULTIPLE: x2",
    's1_title': "1. The Order Switch (Commutative)",
    's1_obj': "To visually prove that the order of multiplication does not change the outcome (`a × b = b × a`). We will test `2 × (-3) = (-3) × 2`.",
    's1_hud1': "DRAG the -3 tray to Line A's machine input.",
    's1_step1_task': "<b>Task Instructions:</b> On the left assembly line (Line A), see the tray of Red Tokens. DRAG the tray containing 3 Red Tokens (representing -3) to the input chute of the Multiplier Machine.",
    's1_step1_out': "<b>Expected Outcome:</b> The tray locks into the input chute. The machine's display shows '-3'.",
    's1_hud2': "CLICK the physical dial on Machine A to 'x 2'.",
    's1_step2_task': "<b>Task Instructions:</b> CLICK the dial on the Line A Multiplier Machine to set the multiplier to 'x 2'.",
    's1_step2_out': "<b>Expected Outcome:</b> The dial clicks into the 'x 2' position. The machine activates, and 2 groups of 3 Red Tokens are produced and collected in the output tray. The output tray now holds 6 Red Tokens.",
    's1_hud3': "DRAG the +2 tray to Line B's machine input.",
    's1_step3_task': "<b>Task Instructions:</b> Now, look at the right assembly line (Line B). DRAG the tray containing 2 Green Tokens (representing +2) to the input chute of its Multiplier Machine.",
    's1_step3_out': "<b>Expected Outcome:</b> The tray locks into the input chute. The machine's display shows '+2'.",
    's1_hud4': "CLICK the physical dial on Machine B to 'x -3'.",
    's1_step4_task': "<b>Task Instructions:</b> CLICK the dial on the Line B Multiplier Machine to set the multiplier to 'x -3'.",
    's1_step4_out': "<b>Expected Outcome:</b> The dial clicks to 'x -3'. The machine activates. Because the multiplier is negative, it inverts the color of the input tokens (Green becomes Red) and produces 3 groups. The output tray collects 6 Red Tokens.",
    's1_hud5': "DRAG both output trays to the Balance Scale.",
    's1_step5_task': "<b>Task Instructions:</b> DRAG the output tray from Line A to the left pan of the 'Balance Scale of Equality'. Then, DRAG the output tray from Line B to the right pan of the scale.",
    's1_step5_out': "<b>Expected Outcome:</b> The scale balances perfectly and glows green, visually confirming that the 6 Red Tokens on the left are equal to the 6 Red Tokens on the right.",
    's1_sum': "<b>Summary:</b><br/>You have just shown that `2 × (-3)` results in -6, and `(-3) × 2` also results in -6. The order in which you multiply integers does not matter. This is the Commutative Property.",
    's2_title': "2. The Grouping Game (Associative)",
    's2_obj': "To visually prove that how you group numbers in a multiplication chain does not change the outcome `(a × b) × c = a × (b × c)`. We will test `(3 × -2) × 2 = 3 × (-2 × 2)`.",
    's2_hud1': "Line A: Drag +3 to Mach 1, click dial to 'x -2'.",
    's2_step1_task': "<b>Task Instructions:</b> On Line A (left), focus on the first machine. DRAG the tray of 3 Green Tokens (+3) to its input and CLICK the dial to 'x -2'.",
    's2_step1_out': "<b>Expected Outcome:</b> The first machine activates, inverts the color, and produces 2 groups of 3 Red Tokens. Its output tray, containing 6 Red Tokens (-6), automatically moves along the conveyor belt to the second machine.",
    's2_hud2': "Line A: Click Mach 2 dial to 'x 2'.",
    's2_step2_task': "<b>Task Instructions:</b> The tray with 6 Red Tokens is now the input for the second machine on Line A. CLICK the dial on this second machine to 'x 2'.",
    's2_step2_out': "<b>Expected Outcome:</b> The second machine activates and duplicates its input. It produces 2 groups of 6 Red Tokens. The final output tray for Line A collects 12 Red Tokens (-12).",
    's2_hud3': "Line B: Drag -2 to Mach 1, click dial to 'x 2'.",
    's2_step3_task': "<b>Task Instructions:</b> Now, on Line B (right), focus on its first machine. DRAG the tray of 2 Red Tokens (-2) to its input and CLICK the dial to 'x 2'.",
    's2_step3_out': "<b>Expected Outcome:</b> The first machine on Line B produces 2 groups of 2 Red Tokens. Its output tray, containing 4 Red Tokens (-4), moves to the second machine.",
    's2_hud4': "Line B: Drag +3 to Mach 2's Multiplier Slot.",
    's2_step4_task': "<b>Task Instructions:</b> The tray with 4 Red Tokens is the input for the second machine on Line B. DRAG the tray of 3 Green Tokens (+3) to the *second* input chute of this machine to set the multiplier.",
    's2_step4_out': "<b>Expected Outcome:</b> The machine's dial automatically sets to 'x 3'. It activates and produces 3 groups of 4 Red Tokens. The final output tray for Line B collects 12 Red Tokens (-12).",
    's2_hud5': "DRAG both final output trays to the Scale.",
    's2_step5_task': "<b>Task Instructions:</b> DRAG the final output tray from Line A to the left pan of the Balance Scale. DRAG the final output tray from Line B to the right pan.",
    's2_step5_out': "<b>Expected Outcome:</b> The scale balances perfectly and glows green, showing that the result of `(3 × -2) × 2` is identical to `3 × (-2 × 2)`.",
    's2_sum': "<b>Summary:</b><br/>You have shown that changing the grouping of multiplication doesn't change the final answer. This is the Associative Property. It lets you choose which pair to multiply first.",
    's3_title': "3. The Distribution Dept (Distributive)",
    's3_obj': "To visually prove that `a × (b + c) = (a × b) + (a × c)`. We will test `2 × (3 + (-1)) = (2 × 3) + (2 × (-1))`.",
    's3_hud1': "Line A: Drag +3 and -1 to Combiner Funnel.",
    's3_step1_task': "<b>Task Instructions:</b> On Line A (left), DRAG the tray of 3 Green Tokens (+3) and the tray of 1 Red Token (-1) into the large 'Combiner Funnel'.",
    's3_step1_out': "<b>Expected Outcome:</b> The tokens mix inside the funnel. One Green and one Red token pair up, flash, and disappear (a zero pair). The funnel outputs a tray with the remaining 2 Green Tokens (+2). This tray automatically moves to the Multiplier Machine.",
    's3_hud2': "Line A: Click Machine dial to 'x 2'.",
    's3_step2_task': "<b>Task Instructions:</b> The tray with 2 Green Tokens is now at the Multiplier Machine. CLICK the dial to set it to 'x 2'.",
    's3_step2_out': "<b>Expected Outcome:</b> The machine activates and produces 2 groups of 2 Green Tokens. The final output tray for Line A collects 4 Green Tokens (+4).",
    's3_hud3': "Line B: Drag +3 to Top Machine, click dial to 'x 2'.",
    's3_step3_task': "<b>Task Instructions:</b> On Line B (right), there are two parallel Multiplier Machines. For the top one, DRAG the tray of 3 Green Tokens (+3) to its input and CLICK the dial to 'x 2'.",
    's3_step3_out': "<b>Expected Outcome:</b> The top machine produces an output tray with 6 Green Tokens (+6). This tray moves towards a final Combiner Funnel.",
    's3_hud4': "Line B: Drag -1 to Bottom Machine, click dial to 'x 2'.",
    's3_step4_task': "<b>Task Instructions:</b> For the bottom machine on Line B, DRAG the tray of 1 Red Token (-1) to its input and CLICK the dial to 'x 2'.",
    's3_step4_out': "<b>Expected Outcome:</b> The bottom machine produces an output tray with 2 Red Tokens (-2). This tray also moves towards the final Combiner Funnel.",
    's3_hud5': "Line B: Click the 'Combine' button.",
    's3_step5_task': "<b>Task Instructions:</b> Both output trays from Line B (one with +6, one with -2) are now at the final Combiner Funnel. CLICK the 'Combine' button.",
    's3_step5_out': "<b>Expected Outcome:</b> The contents of both trays are poured into the funnel. Two zero pairs are formed and disappear. The funnel outputs a final tray containing 4 Green Tokens (+4).",
    's3_hud6': "DRAG both final output trays to the Scale.",
    's3_step6_task': "<b>Task Instructions:</b> DRAG the final output tray from Line A to the left pan of the Balance Scale and the final output tray from Line B to the right pan.",
    's3_step6_out': "<b>Expected Outcome:</b> The scale balances perfectly and glows green.",
    's3_sum': "<b>Summary:</b><br/>You have shown that multiplying after adding `2 × (3 + (-1))` gives the same result as multiplying each part first and then adding the results `(2 × 3) + (2 × (-1))`. This is the Distributive Property.",
    's4_title': "4. Factory Assembly Challenge",
    's4_obj': "Use the provided components to build two different assembly lines that produce the same output, demonstrating the Associative Property. The target output is -18.",
    's4_hud1': "Build (-3 x 3) x 2 on Line A.",
    's4_step1_task': "<b>Task Instructions:</b> You have a workspace with two empty assembly lines (A and B) and a supply of components: two Multiplier Machines for each line, and trays of tokens for -3, +3, and -2. Your goal is to make both lines produce -18 tokens. DRAG and CONNECT the machines and token trays on Line A to calculate `(-3 × 3) × 2`.",
    's4_step1_out': "<b>Expected Outcome:</b> The user correctly assembles the first machine to take -3 as input with a 'x 3' multiplier, and its output (-9) feeds into the second machine with a 'x 2' multiplier. The final output tray shows 18 Red Tokens (-18).",
    's4_hud2': "Build -3 x (3 x 2) on Line B.",
    's4_step2_task': "<b>Task Instructions:</b> Now, using the same components on Line B, DRAG and CONNECT them in a different order to show the Associative Property and also produce -18: `-3 × (3 × 2)`.",
    's4_step2_out': "<b>Expected Outcome:</b> The user correctly builds Line B as `-3 × (3 × 2)` to also get -18. Success is achieved when the final output trays on both lines contain 18 Red Tokens.",
    's4_hud3': "DRAG both final output trays to the Scale.",
    's4_step3_task': "<b>Task Instructions:</b> You've done it! DRAG both final output trays to the Balance Scale to confirm your solution.",
    's4_step3_out': "<b>Expected Outcome:</b> The scale balances, confirming that both `(-3 × 3) × 2` and `-3 × (3 × 2)` equal -18.",
    's4_sum': "<b>Summary:</b><br/>You used your knowledge of the Associative Property to solve a puzzle. You found two different ways to group the same multiplication problem to get the same result.",
    's5_title': "5. The Balancer Puzzle",
    's5_obj': "An expression is built on the left side of the Balance Scale. Use the available components to build the equivalent 'distributed' expression on the right side to balance the scale.",
    's5_hud1': "Observe the left side. Right side goal: (-3 x 4) + (-3 x -2).",
    's5_step1_task': "<b>Task Instructions:</b> Look at the left pan of the Balance Scale. A pre-built factory line has already placed its result there: the output of `-3 × (4 + (-2))`. The scale is unbalanced. Your task is to build a new factory line on the right side that balances it.",
    's5_step1_out': "<b>Expected Outcome:</b> The user observes the left side. They can click on it to see the calculation: `4 + (-2)` becomes `+2`, and `-3 × (+2)` becomes `-6`. The left pan contains 6 Red Tokens.",
    's5_hud2': "Set Machine 1 to -3 x 4, and Machine 2 to -3 x -2.",
    's5_step2_task': "<b>Task Instructions:</b> You have the following components for the right side: two Multiplier Machines, one Combiner Funnel, and token trays for -3, +4, and -2. Using the Distributive Property, build an expression equivalent to `-3 × (4 + (-2))`. DRAG the components onto the right-side assembly line.",
    's5_step2_out': "<b>Expected Outcome:</b> The user correctly builds the distributed form. They set up one Multiplier for `-3 × 4` (producing -12) and a second Multiplier for `-3 × (-2)` (producing +6).",
    's5_hud3': "Click 'Combine' to merge outputs into the scale.",
    's5_step3_task': "<b>Task Instructions:</b> Now, CONNECT the outputs of your two Multiplier Machines to the final Combiner Funnel. Once the final result is produced, it will automatically be placed on the right pan of the Balance Scale.",
    's5_step3_out': "<b>Expected Outcome:</b> The Combiner Funnel takes the -12 (12 Red) and +6 (6 Green) tokens, cancels the zero pairs, and outputs a final tray of -6 (6 Red). This tray moves to the scale, which then balances perfectly with a green glow.",
    's5_sum': "<b>Summary:</b><br/>Fantastic! You used the Distributive Property to break a complex problem, `-3 × (4 + (-2))`, into two simpler problems, `(-3 × 4) + (-3 × (-2))`, and proved they are equal.",
  },
  'hi': {
    'appTitle': "द इंटीजर फैक्ट्री",
    'appSubtitle': "कक्षा 7 • गुणा के गुण",
    'enterLab': "फैक्ट्री में प्रवेश करें",
    'settings': "सेटिंग्स",
    'theme': "थीम",
    'darkMode': "डार्क मोड",
    'lightMode': "लाइट मोड",
    'boardFontSize': "टेक्स्ट आकार",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'proceedBtn': "आगे बढ़ें",
    'combineBtn': "मिलाएं",
    'learnLbl': "हम क्या सीखते हैं:",
    'closeBtn': "बंद करें",
    'summaryTitle': "खोज!",
    'resetBtn': "रीसेट",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'infoNextScen': "कृपया ऊपर दिए गए ड्रॉपडाउन से अगला परिदृश्य चुनें।",
    'labCompleted': "लैब पूरी हुई!",
    'finalDesc': "आपने गुणा के गुणों में महारत हासिल कर ली है! आपने खोजा कि क्रमविनिमेय, साहचर्य और वितरण के नियम कैसे काम करते हैं।",
    'lbl_lineA': "लाइन A",
    'lbl_lineB': "लाइन B",
    'lbl_lineA_val': "लाइन A (-3)",
    'lbl_lineB_val': "लाइन B (+2)",
    'lbl_machA': "मशीन A",
    'lbl_machB': "मशीन B",
    'lbl_mach1': "मशीन 1",
    'lbl_mach2': "मशीन 2",
    'lbl_mach3': "मशीन 3",
    'lbl_mach4': "मशीन 4",
    'lbl_mult1': "मल्टीप्लायर 1",
    'lbl_mult2': "मल्टीप्लायर 2",
    'lbl_combinerA': "लाइन A\nकॉम्बिनर",
    'lbl_combinerB': "लाइन B\nकॉम्बिनर",
    'lbl_finalCombiner': "अंतिम\nकॉम्बिनर",
    'lbl_sandbox': "सप्लाई सैंडबॉक्स",
    'lbl_proofSuccess': "प्रमाण सफल!",
    'lbl_combineBtn': "मिलाएं",
    'lbl_zap': "💥 ZAP!",
    'lbl_click': "CLICK",
    'lbl_multX2': "MULTIPLE: x2",
    's1_title': "1. क्रम बदलना (क्रमविनिमेय)",
    's1_obj': "यह साबित करने के लिए कि गुणा का क्रम परिणाम नहीं बदलता है (`a × b = b × a`)। हम परीक्षण करेंगे `2 × (-3) = (-3) × 2`.",
    's1_hud1': "-3 ट्रे को लाइन A मशीन के इनपुट में खींचें।",
    's1_step1_task': "<b>कार्य निर्देश:</b> बाईं असेंबली लाइन (लाइन ए) पर, लाल टोकन की ट्रे को देखें। 3 लाल टोकन (जो -3 का प्रतिनिधित्व करते हैं) वाली ट्रे को गुणक मशीन के इनपुट में खींचें।",
    's1_step1_out': "<b>अपेक्षित परिणाम:</b> ट्रे इनपुट में लॉक हो जाती है। मशीन का डिस्प्ले '-3' दिखाता है।",
    's1_hud2': "मशीन A के डायल को 'x 2' पर क्लिक करें।",
    's1_step2_task': "<b>कार्य निर्देश:</b> मशीन ए के डायल को 'x 2' पर सेट करने के लिए क्लिक करें।",
    's1_step2_out': "<b>अपेक्षित परिणाम:</b> डायल 'x 2' स्थिति में क्लिक हो जाता है। मशीन चालू हो जाती है, और 3 लाल टोकन के 2 समूह बन जाते हैं और आउटपुट ट्रे में आ जाते हैं। आउटपुट ट्रे में अब 6 लाल टोकन हैं।",
    's1_hud3': "+2 ट्रे को लाइन B मशीन के इनपुट में खींचें।",
    's1_step3_task': "<b>कार्य निर्देश:</b> अब, दाईं असेंबली लाइन (लाइन बी) देखें। 2 हरे टोकन (जो +2 का प्रतिनिधित्व करते हैं) वाली ट्रे को गुणक मशीन के इनपुट में खींचें।",
    's1_step3_out': "<b>अपेक्षित परिणाम:</b> ट्रे इनपुट में लॉक हो जाती है। मशीन का डिस्प्ले '+2' दिखाता है।",
    's1_hud4': "मशीन B के डायल को 'x -3' पर क्लिक करें।",
    's1_step4_task': "<b>कार्य निर्देश:</b> मशीन बी के डायल को 'x -3' पर सेट करने के लिए क्लिक करें।",
    's1_step4_out': "<b>अपेक्षित परिणाम:</b> डायल 'x -3' स्थिति में क्लिक हो जाता है। मशीन चालू हो जाती है। क्योंकि गुणक ऋणात्मक है, यह टोकन के रंग को उल्टा कर देता है (हरा लाल हो जाता है) और 3 समूह बनाता है। आउटपुट ट्रे में 6 लाल टोकन आ जाते हैं।",
    's1_hud5': "दोनों आउटपुट ट्रे को तराजू पर खींचें।",
    's1_step5_task': "<b>कार्य निर्देश:</b> दोनों आउटपुट ट्रे को 'समानता के तराजू' (Balance Scale) पर खींचें। लाइन ए की ट्रे को बाएं पलड़े पर और लाइन बी की ट्रे को दाएं पलड़े पर रखें।",
    's1_step5_out': "<b>अपेक्षित परिणाम:</b> तराजू पूरी तरह से संतुलित हो जाता है और हरा चमकता है, यह प्रमाणित करते हुए कि बाएं और दाएं दोनों ओर 6 लाल टोकन हैं।",
    's1_sum': "<b>सारांश:</b><br/>आपने देखा कि `2 × (-3)` का परिणाम -6 है, और `(-3) × 2` का परिणाम भी -6 है। आप जिस क्रम में गुणा करते हैं, उससे कोई फर्क नहीं पड़ता। यह क्रमविनिमेय का नियम है।",
    's2_title': "2. समूह बनाने का खेल (साहचर्य)",
    's2_obj': "यह साबित करने के लिए कि आप गुणा को कैसे भी समूहित करते हैं, परिणाम नहीं बदलता है `(a × b) × c = a × (b × c)`। हम परीक्षण करेंगे `(3 × -2) × 2 = 3 × (-2 × 2)`.",
    's2_hud1': "लाइन A: +3 खींचें, डायल को 'x -2' पर क्लिक करें।",
    's2_step1_task': "<b>कार्य निर्देश:</b> लाइन ए (बाईं ओर) पर, पहली मशीन पर ध्यान दें। 3 हरे टोकन (+3) की ट्रे को इसके इनपुट में खींचें और डायल को 'x -2' पर क्लिक करें।",
    's2_step1_out': "<b>अपेक्षित परिणाम:</b> पहली मशीन रंग को उल्टा कर देती है और 3 लाल टोकन के 2 समूह बनाती है। इसकी आउटपुट ट्रे (जिसमें 6 लाल टोकन हैं) अपने आप दूसरी मशीन की ओर बढ़ जाती है।",
    's2_hud2': "लाइन A: दूसरी मशीन डायल 'x 2' क्लिक करें।",
    's2_step2_task': "<b>कार्य निर्देश:</b> अब 6 लाल टोकन वाली ट्रे लाइन ए की दूसरी मशीन का इनपुट है। इस दूसरी मशीन के डायल को 'x 2' पर क्लिक करें।",
    's2_step2_out': "<b>अपेक्षित परिणाम:</b> दूसरी मशीन 6 लाल टोकन के 2 समूह बनाती है। लाइन ए की अंतिम आउटपुट ट्रे में 12 लाल टोकन (-12) आ जाते हैं।",
    's2_hud3': "लाइन B: -2 खींचें, डायल 'x 2' क्लिक करें।",
    's2_step3_task': "<b>कार्य निर्देश:</b> अब, लाइन बी (दाईं ओर) पर, पहली मशीन पर ध्यान दें। 2 लाल टोकन (-2) की ट्रे को इसके इनपुट में खींचें और डायल को 'x 2' पर क्लिक करें।",
    's2_step3_out': "<b>अपेक्षित परिणाम:</b> लाइन बी की पहली मशीन 2 लाल टोकन के 2 समूह बनाती है। इसकी आउटपुट ट्रे (जिसमें 4 लाल टोकन हैं) दूसरी मशीन की ओर बढ़ जाती है।",
    's2_hud4': "लाइन B: दूसरी मशीन के स्लॉट में +3 खींचें।",
    's2_step4_task': "<b>कार्य निर्देश:</b> 4 लाल टोकन वाली ट्रे अब लाइन बी की दूसरी मशीन का इनपुट है। गुणक सेट करने के लिए 3 हरे टोकन (+3) की ट्रे को इस मशीन के साइड स्लॉट में खींचें।",
    's2_step4_out': "<b>अपेक्षित परिणाम:</b> मशीन का डायल अपने आप 'x 3' पर सेट हो जाता है। मशीन 4 लाल टोकन के 3 समूह बनाती है। लाइन बी की अंतिम आउटपुट ट्रे में 12 लाल टोकन (-12) आ जाते हैं।",
    's2_hud5': "दोनों आउटपुट ट्रे को तराजू पर खींचें।",
    's2_step5_task': "<b>कार्य निर्देश:</b> दोनों अंतिम आउटपुट ट्रे को 'समानता के तराजू' पर खींचें। लाइन ए की ट्रे को बाएं पलड़े पर और लाइन बी की ट्रे को दाएं पलड़े पर रखें।",
    's2_step5_out': "<b>अपेक्षित परिणाम:</b> तराजू पूरी तरह से संतुलित हो जाता है और हरा चमकता है, यह प्रमाणित करते हुए कि `(3 × -2) × 2` का परिणाम `3 × (-2 × 2)` के समान है।",
    's2_sum': "<b>सारांश:</b><br/>आपने दिखाया है कि गुणा के समूहीकरण (ग्रुपिंग) को बदलने से अंतिम उत्तर नहीं बदलता है। यह साहचर्य का नियम है।",
    's3_title': "3. वितरण विभाग (वितरण)",
    's3_obj': "यह साबित करने के लिए कि `a × (b + c) = (a × b) + (a × c)`। हम परीक्षण करेंगे `2 × (3 + (-1)) = (2 × 3) + (2 × (-1))`.",
    's3_hud1': "लाइन A: कीप में +3 और -1 खींचें।",
    's3_step1_task': "<b>कार्य निर्देश:</b> लाइन ए (बाईं ओर) पर, 3 हरे टोकन (+3) की ट्रे और 1 लाल टोकन (-1) की ट्रे को 'कॉम्बिनर फ़नल' (कीप) में खींचें।",
    's3_step1_out': "<b>अपेक्षित परिणाम:</b> टोकन फ़नल के अंदर मिल जाते हैं। शून्य जोड़े (zero pairs) गायब हो जाते हैं। फ़नल शेष 2 हरे टोकन (+2) के साथ एक ट्रे आउटपुट करता है। यह ट्रे अपने आप मशीन की ओर बढ़ जाती है।",
    's3_hud2': "लाइन A: मशीन डायल को 'x 2' पर क्लिक करें।",
    's3_step2_task': "<b>कार्य निर्देश:</b> 2 हरे टोकन वाली ट्रे अब मल्टीप्लायर मशीन पर है। डायल को 'x 2' पर सेट करने के लिए क्लिक करें।",
    's3_step2_out': "<b>अपेक्षित परिणाम:</b> मशीन 2 हरे टोकन के 2 समूह बनाती है। लाइन ए की अंतिम आउटपुट ट्रे में 4 हरे टोकन (+4) आ जाते हैं।",
    's3_hud3': "लाइन B: शीर्ष मशीन में +3 खींचें, 'x 2' क्लिक करें।",
    's3_step3_task': "<b>कार्य निर्देश:</b> लाइन बी (दाईं ओर) पर, दो मल्टीप्लायर मशीनें हैं। शीर्ष (ऊपर की) मशीन के इनपुट में 3 हरे टोकन (+3) की ट्रे खींचें और डायल को 'x 2' पर क्लिक करें।",
    's3_step3_out': "<b>अपेक्षित परिणाम:</b> शीर्ष मशीन 6 हरे टोकन (+6) के साथ एक ट्रे आउटपुट करती है। यह ट्रे कॉम्बिनर फ़नल की ओर बढ़ती है।",
    's3_hud4': "लाइन B: निचली मशीन में -1 खींचें, 'x 2' क्लिक करें।",
    's3_step4_task': "<b>कार्य निर्देश:</b> लाइन बी पर निचली मशीन के लिए, 1 लाल टोकन (-1) की ट्रे को इसके इनपुट में खींचें और डायल को 'x 2' पर क्लिक करें।",
    's3_step4_out': "<b>अपेक्षित परिणाम:</b> निचली मशीन 2 लाल टोकन (-2) के साथ एक ट्रे आउटपुट करती है। यह ट्रे भी कॉम्बिनर फ़नल की ओर बढ़ती है।",
    's3_hud5': "लाइन B: 'मिलाएं' बटन पर क्लिक करें।",
    's3_step5_task': "<b>कार्य निर्देश:</b> लाइन बी की दोनों आउटपुट ट्रे अब अंतिम कॉम्बिनर फ़नल पर हैं। 'Combine' (मिलाएं) बटन पर क्लिक करें।",
    's3_step5_out': "<b>अपेक्षित परिणाम:</b> दोनों ट्रे के टोकन फ़नल में डाले जाते हैं। शून्य जोड़े गायब हो जाते हैं। फ़नल 4 हरे टोकन (+4) वाली अंतिम ट्रे आउटपुट करता है।",
    's3_hud6': "दोनों आउटपुट को तराजू पर खींचें।",
    's3_step6_task': "<b>कार्य निर्देश:</b> दोनों अंतिम आउटपुट ट्रे को तराजू पर खींचें। लाइन ए की ट्रे को बाएं पलड़े पर और लाइन बी की ट्रे को दाएं पलड़े पर रखें।",
    's3_step6_out': "<b>अपेक्षित परिणाम:</b> तराजू पूरी तरह से संतुलित हो जाता है और हरा चमकता है।",
    's3_sum': "<b>सारांश:</b><br/>आपने दिखाया है कि जोड़ने के बाद गुणा करने का परिणाम `2 × (3 + (-1))` प्रत्येक भाग को पहले गुणा करके परिणामों को जोड़ने `(2 × 3) + (2 × (-1))` के समान होता है। यह वितरण का नियम है।",
    's4_title': "4. असेंबली चुनौती",
    's4_obj': "समान आउटपुट उत्पन्न करने वाली दो अलग-अलग लाइनें बनाकर साहचर्य नियम का प्रदर्शन करें। लक्ष्य आउटपुट -18 है।",
    's4_hud1': "लाइन A पर (-3 x 3) x 2 बनाएं।",
    's4_step1_task': "<b>कार्य निर्देश:</b> आपके पास खाली मशीनें और टोकन हैं। लाइन ए पर, मशीन 1 के इनपुट में -3 की ट्रे और डायल में +3 की ट्रे खींचें। फिर मशीन 2 के डायल में +2 की ट्रे खींचें। लक्ष्य `(-3 × 3) × 2` की गणना करना है।",
    's4_step1_out': "<b>अपेक्षित परिणाम:</b> मशीनें काम करती हैं और 18 लाल टोकन (-18) की एक अंतिम आउटपुट ट्रे दिखाती हैं।",
    's4_hud2': "लाइन B पर -3 x (3 x 2) बनाएं।",
    's4_step2_task': "<b>कार्य निर्देश:</b> अब, लाइन बी पर, घटकों को एक अलग क्रम में जोड़ें: `-3 × (3 × 2)`। मशीन 1 के इनपुट में +3 की ट्रे और डायल में +2 की ट्रे खींचें। फिर मशीन 2 के डायल में -3 की ट्रे खींचें।",
    's4_step2_out': "<b>अपेक्षित परिणाम:</b> सफलता तब मिलती है जब दोनों लाइनों पर अंतिम आउटपुट ट्रे में 18 लाल टोकन होते हैं।",
    's4_hud3': "दोनों आउटपुट को तराजू पर खींचें।",
    's4_step3_task': "<b>कार्य निर्देश:</b> आपने कर दिखाया! अपनी अंतिम आउटपुट ट्रे को बैलेंस स्केल पर खींचकर अपने उत्तर की पुष्टि करें।",
    's4_step3_out': "<b>अपेक्षित परिणाम:</b> तराजू संतुलित होता है, यह पुष्टि करता है कि दोनों तरीके -18 के बराबर हैं।",
    's4_sum': "<b>सारांश:</b><br/>आपने एक पहेली को हल करने के लिए साहचर्य संपत्ति (Associative Property) के अपने ज्ञान का उपयोग किया। आपने एक ही उत्तर प्राप्त करने के लिए गुणा को अलग-अलग तरीके से समूहित किया।",
    's5_title': "5. बैलेंसर पहेली",
    's5_obj': "तराजू को संतुलित करने के लिए उपलब्ध घटकों का उपयोग करके दाईं ओर समतुल्य 'वितरित' (distributed) समीकरण बनाएं।",
    's5_hud1': "बाईं ओर -6 है। दाईं ओर वितरण बनाएं।",
    's5_step1_task': "<b>कार्य निर्देश:</b> बैलेंस स्केल के बाएं पलड़े को देखें। एक फ़ैक्टरी लाइन ने पहले ही अपना परिणाम वहां रख दिया है: `-3 × (4 + (-2))` का आउटपुट। तराजू असंतुलित है। आपका काम दाईं ओर एक नई लाइन बनाना है जो इसे संतुलित करे।",
    's5_step1_out': "<b>अपेक्षित परिणाम:</b> बाएं पलड़े में 6 लाल टोकन (-6) हैं।",
    's5_hud2': "मशीन 1 को -3 x 4, और मशीन 2 को -3 x -2 पर सेट करें।",
    's5_step2_task': "<b>कार्य निर्देश:</b> वितरण संपत्ति (Distributive Property) का उपयोग करते हुए, दाईं ओर के लिए मशीनें सेट करें। शीर्ष मशीन के इनपुट में +4 और डायल में -3 खींचें। निचली मशीन के इनपुट में -2 और डायल में -3 खींचें।",
    's5_step2_out': "<b>अपेक्षित परिणाम:</b> मशीनें -12 (12 लाल टोकन) और +6 (6 हरे टोकन) आउटपुट करती हैं।",
    's5_hud3': "मिलाने के लिए 'Combine' पर क्लिक करें।",
    's5_step3_task': "<b>कार्य निर्देश:</b> दोनों आउटपुट अंतिम फ़नल में हैं। फ़नल के 'Combine' बटन पर क्लिक करें।",
    's5_step3_out': "<b>अपेक्षित परिणाम:</b> फ़नल शून्य जोड़े को रद्द करता है और -6 (6 लाल टोकन) की एक अंतिम ट्रे निकालता है। यह ट्रे तराजू पर जाती है, जो पूरी तरह से संतुलित हो जाता है!",
    's5_sum': "<b>सारांश:</b><br/>शानदार! आपने एक जटिल समस्या `-3 × (4 + (-2))` को दो सरल समस्याओं `(-3 × 4) + (-3 × (-2))` में तोड़ने के लिए वितरण नियम का उपयोग किया, और साबित किया कि वे समान हैं।",
  },
};
