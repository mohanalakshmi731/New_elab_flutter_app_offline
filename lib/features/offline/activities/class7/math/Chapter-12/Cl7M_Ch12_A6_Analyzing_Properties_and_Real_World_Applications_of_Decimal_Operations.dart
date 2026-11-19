// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnalyzingPropertiesandRealWorldApplicationsofDecimalOperationsApp());
}

class AnalyzingPropertiesandRealWorldApplicationsofDecimalOperationsApp extends StatelessWidget {
  const AnalyzingPropertiesandRealWorldApplicationsofDecimalOperationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | The Decimalverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const AnalyzingPropertiesandRealWorldApplicationsofDecimalOperations(),
    );
  }
}

// ==========================================
// MAIN WIDGET
// ==========================================
class AnalyzingPropertiesandRealWorldApplicationsofDecimalOperations extends StatefulWidget {
  const AnalyzingPropertiesandRealWorldApplicationsofDecimalOperations({super.key});

  @override
  State<AnalyzingPropertiesandRealWorldApplicationsofDecimalOperations> createState() =>
      _AnalyzingPropertiesandRealWorldApplicationsofDecimalOperationsState();
}

class _AnalyzingPropertiesandRealWorldApplicationsofDecimalOperationsState
    extends State<AnalyzingPropertiesandRealWorldApplicationsofDecimalOperations>
    with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  final bool _isDark = true;
  bool _isSidebarOpen = true;
  bool _showCurtain = true;

  // Lab State
  int _scenario = 1;
  int _step = 1;
  bool _showSuccessPopup = false;
  final Set<int> _completedScenarios = {};
  final ScrollController _sidebarScrollController = ScrollController();
  final ScrollController _popupScrollController = ScrollController();

  // Viewport State
  double _zoom = 1.0;
  double _panX = 0;
  double _panY = 0;
  double _baseZoom = 1.0;

  // Matrix Bounds
  final double _matW = 1200;
  final double _matH = 700;
  final double _matX = -600;
  final double _matY = -350;

  // Interaction State
  double _mouseX = 0;
  double _mouseY = 0;
  String? _activeDragType;

  // Temporary HUD
  String _hudMessage = '';
  bool _showHud = false;

  // -- Scenario Specific State --
  // Scenario 1
  int _pens = 0;
  bool _coinsGrouped = false;
  double _groupAnim = 0;
  
  // Scenario 2
  double _len = 13.0;
  double _wid = 5.0;
  Map<String, bool> _areasClicked = {'main': false, 'right': false, 'bottom': false, 'corner': false};
  
  // Scenario 3
  int _cuts = 1;
  bool _isCut = false;
  double _cutAnim = 0;
  double _magX = 480;
  double _magY = -50;
  double _decAnim = 0;
  bool _readyToAdvanceScen3 = false;
  
  // Scenario 4
  double _tankLevel = 126;
  bool _canFilled = false;
  double _scootersFilled = 0;
  bool _isFastForwarding = false;
  double _beakerLevel = 0;
  String _userAnswer = "";
  bool _isPouring = false;
  bool _poured = false;
  double _pourAnim = 0;
  
  // Scenario 5
  String? _scaleItem;
  double _scaleAnim = 0;
  double? _chikkiPrice;
  double? _chipsPrice;
  String? _podiumItem;
  List<Map<String, dynamic>> _confetti = [];

  bool _isCompleted = false;
  bool _successUIDelayPassed = false;

  final TextEditingController _textController = TextEditingController();

  // Audio players
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';
  static const String _fireUrl = 'audio/class7/mixkit_1666.mp3';
  static const String _whirUrl = 'audio/class7/mixkit_3104.mp3';

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

    _textController.addListener(() {
      _userAnswer = _textController.text;
    });

    _loadScenario(1);

    _ticker = AnimationController(vsync: this, duration: const Duration(milliseconds: 30))..addListener(_tick)..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sidebarScrollController.dispose();
    _popupScrollController.dispose();
    _textController.dispose();
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
      } else if (type == 'pop' || type == 'tick' || type == 'snap') {
        await _clickPlayer.play(AssetSource(_clickUrl), volume: 0.5);
      } else if (type == 'whir') {
        await _fxPlayer.play(AssetSource(_whirUrl), volume: 0.4);
      } else if (type == 'fire') {
        await _fxPlayer.play(AssetSource(_fireUrl), volume: 0.4);
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
      if (_lang == 'en') _lang = 'hi';
      else _lang = 'en';
    });
  }

  void _handleReset() {
    _playSound('error');
    setState(() {
      _showCurtain = true;
      _showSuccessPopup = false;
      _showHud = false;
      _lang = 'en';
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _completedScenarios.clear();
          _loadScenario(1);
          _zoom = 1.0;
          _panX = 0;
          _panY = 0;
        });
      }
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 1;
      _activeDragType = null;
      _showSuccessPopup = false;
      _isCompleted = false;
      _successUIDelayPassed = false;
      
      _pens = 0; _coinsGrouped = false; _groupAnim = 0;
      _len = 13.0; _wid = 5.0; _areasClicked = {'main': false, 'right': false, 'bottom': false, 'corner': false};
      _cuts = 1; _isCut = false; _cutAnim = 0; _magX = 480; _magY = -50; _decAnim = 0; _readyToAdvanceScen3 = false;
      _tankLevel = 126; _canFilled = false; _scootersFilled = 0; _isFastForwarding = false; _beakerLevel = 0; _userAnswer = ""; _isPouring = false; _poured = false; _pourAnim = 0;
      _scaleItem = null; _scaleAnim = 0; _chikkiPrice = null; _chipsPrice = null; _podiumItem = null; _confetti = [];
      _textController.text = "";
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    bool rebuild = false;
    
    // Scenario 1 Group Coins
    if (_groupAnim > 0 && !_coinsGrouped) {
      _groupAnim += 0.015;
      if (_groupAnim >= 1) {
        _groupAnim = 0;
        _coinsGrouped = true;
        _playSound('success');
        _checkStepAdvancement();
      }
      rebuild = true;
    }

    // Scenario 3 Cut
    if (_cutAnim > 0 && !_isCut) {
      _cutAnim += 0.03;
      if (_cutAnim >= 1) {
        _cutAnim = 0;
        _isCut = true;
        _checkStepAdvancement();
      }
      rebuild = true;
    }

    // Scenario 3 Dec Anim
    if (_scenario == 3 && _step == 4 && _decAnim < 1.2) {
      _decAnim += 0.01;
      if (_decAnim >= 1.0 && !_successUIDelayPassed) {
        _successUIDelayPassed = true; // Flag to delay success
        Future.delayed(const Duration(milliseconds: 2000), () {
          if(mounted) _checkScenarioSuccess();
        });
      }
      rebuild = true;
    }

    // Scenario 4 Fast Forward
    if (_isFastForwarding) {
      _scootersFilled += 0.5;
      _tankLevel = max(1.0, 126 - (_scootersFilled * 2.5));
      if (_scootersFilled >= 50) {
        _isFastForwarding = false;
        _scootersFilled = 50;
        _tankLevel = 1.0;
        _checkStepAdvancement();
      }
      rebuild = true;
    }

    // Scenario 4 Pour Anim
    if (_isPouring) {
      _pourAnim += 0.02;
      if (_pourAnim >= 1) {
        _isPouring = false;
        _poured = true;
        _beakerLevel = 0.4;
        _tankLevel = 0;
        _playSound('success');
      }
      rebuild = true;
    }

    // Scenario 5 Scale Anim
    if (_scaleAnim > 0) {
      _scaleAnim += 0.02;
      if (_scaleAnim >= 1) {
        _scaleAnim = 0;
        if (_scaleItem == 'chikki') _chikkiPrice = 0.335;
        if (_scaleItem == 'chips') _chipsPrice = 0.302;
        _playSound('snap');
        _checkStepAdvancement();
      }
      rebuild = true;
    }

    // Scenario 5 Confetti
    if (_isCompleted && _confetti.isNotEmpty) {
      for (var c in _confetti) {
        c['x'] += c['vx'];
        c['y'] += c['vy'];
        c['vy'] += 0.2; // gravity
        c['rot'] += c['rotSpeed'];
      }
      rebuild = true;
    }

    if (rebuild) setState(() {});
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
    
    // Auto-advance logic for read-only steps
    if (_scenario == 1 && _step == 4) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _step == 4) _checkScenarioSuccess();
      });
    }
  }

  void _checkStepAdvancement() {
    setState(() {
      if (_scenario == 1) {
        if (_step == 1 && _pens == 1) _advanceStep();
        if (_step == 2 && _pens == 5) _advanceStep();
        if (_step == 3 && _coinsGrouped) _advanceStep();
      } else if (_scenario == 2) {
        if (_step == 1 && _wid == 5.7 && _len == 13.3) _advanceStep();
        if (_step == 2 && _areasClicked['main']!) _advanceStep();
        if (_step == 3 && _areasClicked['right']! && _areasClicked['bottom']! && _areasClicked['corner']!) {
          _advanceStep();
          Future.delayed(const Duration(milliseconds: 3000), () => _checkScenarioSuccess());
        }
      } else if (_scenario == 3) {
        if (_step == 1 && _cuts == 10) _advanceStep();
        if (_step == 2 && _isCut) _advanceStep();
        // step 3->4 is handled by magnifier drop
      } else if (_scenario == 4) {
        if (_step == 1 && _canFilled) _advanceStep();
        if (_step == 2 && _scootersFilled == 1) _advanceStep();
        if (_step == 3 && _scootersFilled >= 50) _advanceStep();
      } else if (_scenario == 5) {
        if (_step == 1 && _chikkiPrice != null) _advanceStep();
        if (_step == 2 && _chipsPrice != null) _advanceStep();
      }
    });
  }

  void _checkScenarioSuccess() {
    if (_isCompleted) return;
    setState(() {
      int totalSteps = (_scenario == 1) ? 4 : (_scenario == 2) ? 4 : (_scenario == 3) ? 4 : (_scenario == 4) ? 4 : 3;
      _step = totalSteps + 1;
      _isCompleted = true;
      _completedScenarios.add(_scenario);
      _successUIDelayPassed = true;
      _showSuccessPopup = true;
    });
    _playSound('success');
    _scrollToActiveStep();
  }

  void _simAction(String action, [dynamic val]) {
    _playSound('tick');
    setState(() {
      if (action == 'group_coins') {
        _groupAnim = 0.01;
        _playSound('whir');
      } else if (action == 'change_wid') {
        _wid = double.parse(val.toString());
        _checkStepAdvancement();
      } else if (action == 'change_len') {
        _len = double.parse(val.toString());
        _checkStepAdvancement();
      } else if (action == 'change_cuts') {
        _cuts = int.parse(val.toString());
        _checkStepAdvancement();
      } else if (action == 'cut_ribbon') {
        _cutAnim = 0.01;
        _playSound('fire');
      } else if (action == 'fast_forward') {
        _isFastForwarding = true;
        _playSound('whir');
      } else if (action == 'submit_s4') {
        if (!_poured) {
          _playSound('error');
          _showTemporaryHUD(t('err_action'));
          return;
        }
        if (double.tryParse(_userAnswer) == 50.4) {
          _playSound('success');
          _checkScenarioSuccess();
        } else {
          _playSound('error');
          _showTemporaryHUD(t('err_input'));
        }
      }
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

  void _showTemporaryHUD(String msg) {
    setState(() {
      _hudMessage = msg;
      _showHud = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHud = false);
    });
  }

  Offset _screenToWorld(Offset screenPos, Size size) {
    double cx = size.width / 2 + _panX;
    double cy = size.height / 2 + _panY;
    return Offset((screenPos.dx - cx) / _zoom, (screenPos.dy - cy) / _zoom);
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    if (_isCompleted) return;
    Offset pt = _screenToWorld(details.localPosition, size);

    if (_scenario == 2 && _step >= 2) {
      double cx = -450, cy = -150, scale = 50, wl = 13, ww = 5, dl = _len - 13, dw = _wid - 5;
      List<Map<String, dynamic>> areas = [
        {'k': 'main', 'r': Rect.fromLTWH(cx, cy, wl * scale, ww * scale)},
        {'k': 'right', 'r': Rect.fromLTWH(cx + wl * scale, cy, dl * scale, ww * scale)},
        {'k': 'bottom', 'r': Rect.fromLTWH(cx, cy + ww * scale, wl * scale, dw * scale)},
        {'k': 'corner', 'r': Rect.fromLTWH(cx + wl * scale, cy + ww * scale, dl * scale, dw * scale)}
      ];
      for (var a in areas) {
        if (a['r'].contains(pt)) {
          if (_areasClicked[a['k']] == false) {
            setState(() { _areasClicked[a['k']] = true; });
            _playSound('tick');
            _checkStepAdvancement();
          }
          return;
        }
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (!_isCompleted) {
      if (_scenario == 1 && _step <= 2) {
        if (Rect.fromLTWH(-220, -50, 40, 100).contains(pt)) {
          setState(() { _activeDragType = 'pen'; _mouseX = pt.dx; _mouseY = pt.dy; });
          _playSound('tick'); return;
        }
      }
      if (_scenario == 3 && _step == 3) {
        if ((Offset(_magX, _magY) - pt).distance < 80) {
          setState(() { _activeDragType = 'magnifier'; _mouseX = pt.dx; _mouseY = pt.dy; });
          _playSound('tick'); return;
        }
      }
      if (_scenario == 4) {
        if (_step <= 2) {
          double canX = _activeDragType == 'can' ? _mouseX - 45 : -140;
          double canY = _activeDragType == 'can' ? _mouseY - 55 : 120;
          if (Rect.fromLTWH(canX - 20, canY - 20, 150, 150).contains(pt)) {
            setState(() { _activeDragType = 'can'; _mouseX = pt.dx; _mouseY = pt.dy; });
            _playSound('tick'); return;
          }
        }
        if (_step == 4 && !_isPouring && !_poured) {
          double tx = -450, ty = -50;
          if (Rect.fromLTWH(tx, ty, 300, 300).contains(pt)) {
            setState(() { _activeDragType = 'tank'; _mouseX = pt.dx; _mouseY = pt.dy; });
            _playSound('tick'); return;
          }
        }
      }
      if (_scenario == 5) {
        if (_scaleAnim == 0 && _podiumItem == null) {
          double chkX = _activeDragType == 'chikki' ? _mouseX - 55 : (_scaleItem == 'chikki' ? -55 : -500);
          double chkY = _activeDragType == 'chikki' ? _mouseY - 75 : (_scaleItem == 'chikki' ? -20 : -70);
          if (Rect.fromLTWH(chkX - 20, chkY - 20, 150, 190).contains(pt)) {
            setState(() { _activeDragType = 'chikki'; _mouseX = pt.dx; _mouseY = pt.dy; });
            _playSound('tick'); return;
          }

          double chpX = _activeDragType == 'chips' ? _mouseX - 55 : (_scaleItem == 'chips' ? -55 : (_step >= 3 ? -350 : 400));
          double chpY = _activeDragType == 'chips' ? _mouseY - 75 : (_scaleItem == 'chips' ? -20 : -70);
          if (Rect.fromLTWH(chpX - 20, chpY - 20, 150, 190).contains(pt)) {
            setState(() { _activeDragType = 'chips'; _mouseX = pt.dx; _mouseY = pt.dy; });
            _playSound('tick'); return;
          }
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      _mouseX = pt.dx;
      _mouseY = pt.dy;

      if (_activeDragType == null) {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.15, 1.5);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      } else if (_activeDragType == 'magnifier') {
        _magX = pt.dx;
        _magY = pt.dy;
        if (_scenario == 3 && _step == 3 && _isCut && _magY > -130 && _magY < 30 && _magX > -400 && _magX < 400) {
          _readyToAdvanceScen3 = true;
        } else {
          _readyToAdvanceScen3 = false;
        }
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_activeDragType != null) {
      Offset pt = Offset(_mouseX, _mouseY);

      if (_activeDragType == 'pen') {
        if (Rect.fromLTWH(-350, 150, 240, 120).contains(pt)) {
          setState(() { _pens++; }); _playSound('snap'); _checkStepAdvancement();
        } else { _playSound('error'); }
      }
      if (_activeDragType == 'magnifier') {
        if (_scenario == 3 && _step == 3 && _readyToAdvanceScen3) {
          _playSound('success'); _advanceStep(); _readyToAdvanceScen3 = false;
        }
      }
      if (_activeDragType == 'can') {
        if (_step == 1 && Rect.fromLTWH(-500, -100, 400, 400).contains(pt)) {
          setState(() { _canFilled = true; }); _playSound('snap'); _checkStepAdvancement();
        } else if (_step == 2 && Rect.fromLTWH(0, -250, 250, 250).contains(pt)) {
          setState(() { _canFilled = false; _scootersFilled = 1; _tankLevel -= 2.5; }); _playSound('snap'); _checkStepAdvancement();
        } else { _playSound('error'); }
      }
      if (_activeDragType == 'tank') {
        if (_step == 4 && Rect.fromLTWH(0, 0, 300, 300).contains(pt)) {
          setState(() { _isPouring = true; }); _playSound('snap');
        } else { _playSound('error'); }
      }
      if (_activeDragType == 'chikki' || _activeDragType == 'chips') {
        String type = _activeDragType!;
        if (Rect.fromLTWH(-300, 0, 600, 300).contains(pt)) {
          setState(() { _scaleItem = type; _scaleAnim = 0.01; }); _playSound('whir');
        } else if (_step == 3 && Rect.fromLTWH(100, -100, 500, 500).contains(pt)) {
          if (type == 'chips') {
            setState(() {
              _podiumItem = type;
              for (int i = 0; i < 150; i++) {
                _confetti.add({
                  'x': 300 + Random().nextDouble() * 120,
                  'y': 50,
                  'vx': (Random().nextDouble() - 0.5) * 20,
                  'vy': -Random().nextDouble() * 20 - 5,
                  'color': [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink][Random().nextInt(6)],
                  'size': Random().nextDouble() * 12 + 6,
                  'rot': Random().nextDouble() * pi,
                  'rotSpeed': (Random().nextDouble() - 0.5) * 0.4
                });
              }
            });
            _playSound('success');
            _checkScenarioSuccess();
          } else {
            _playSound('error'); _showTemporaryHUD("Try Again! Find the cheapest per gram.");
          }
        } else {
          _playSound('error');
        }
      }

      setState(() => _activeDragType = null);
    }
  }

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
    return RichText(text: TextSpan(style: const TextStyle(fontSize: 13, fontFamily: 'Plus Jakarta Sans', height: 1.5), children: spans));
  }

  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withAlpha(240);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withAlpha(25);

    int totalSteps = (_scenario == 1) ? 4 : (_scenario == 2) ? 4 : (_scenario == 3) ? 4 : (_scenario == 4) ? 4 : 3;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(5, 0))],
      ),
      child: SingleChildScrollView(
        controller: _sidebarScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header inside sidebar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.indigo.withAlpha(51), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.public, color: Colors.indigoAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('appTitle'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(t('appSubtitle'), style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleLanguage,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: textPrimary, side: BorderSide(color: border), padding: const EdgeInsets.symmetric(vertical: 12)),
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
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.redAccent, side: BorderSide(color: border), padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, size: 16),
                          const SizedBox(width: 6),
                          Flexible(child: Text(t('reset'), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Divider(color: border),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('selectScenario'), style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0x800F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.track_changes, color: Colors.pinkAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(t('lbl_objective'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRichText(t('s${_scenario}_obj'), textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(totalSteps, (i) {
                    int actualStep = i + 1;
                    bool isPast = actualStep < _step;
                    bool isCurrent = actualStep == _step;
                    Color stepBg = isCurrent ? Colors.indigo.withAlpha(25) : (isPast ? Colors.green.withAlpha(12) : Colors.white.withAlpha(5));
                    Color stepBorder = isCurrent ? Colors.indigoAccent : (isPast ? Colors.green.withAlpha(76) : Colors.transparent);

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
                                  child: Text('$actualStep', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${t('stepLabel')} $actualStep", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                _buildRichText(t('s${_scenario}_step${actualStep}_task'), textPrimary),
                                if (isPast) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: const Color(0x1A4CAF50), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0x334CAF50))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t('obsLbl'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade600, fontSize: 12)),
                                        const SizedBox(height: 4),
                                        _buildRichText(t('s${_scenario}_step${actualStep}_obs'), Colors.green.shade700),
                                        const SizedBox(height: 8),
                                        const Divider(color: Colors.green, height: 1),
                                        const SizedBox(height: 8),
                                        Text(t('learnLbl'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade600, fontSize: 12)),
                                        const SizedBox(height: 4),
                                        _buildRichText(t('s${_scenario}_step${actualStep}_learn'), Colors.green.shade700),
                                      ],
                                    ),
                                  ),
                                ]
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
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              color: const Color(0xFF0F172A),
              child: const Text(
                "© ZeroScienceLab - Fall in love with math and Science",
                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dynamic Overlay Controls Widget ---
  Widget _buildControlsOverlay(double sidebarWidth) {
    List<Widget> children = [];
    
    if (_scenario == 1 && _step == 3 && !_coinsGrouped) {
      children.add(
        ElevatedButton(
          onPressed: () => _simAction('group_coins'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade300, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black, width: 2))),
          child: Text(t('lbl_group_coins_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
        )
      );
    }
    
    if (_scenario == 2 && _step == 1) {
      children.add(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xD90F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${t('lbl_width')}: ${_wid.toStringAsFixed(1)}m", style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: _wid, min: 5, max: 6,
                      onChanged: (v) {
                        double rounded = (v * 10).roundToDouble() / 10;
                        _simAction('change_wid', rounded);
                      },
                      activeColor: Colors.indigoAccent
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${t('lbl_length')}: ${_len.toStringAsFixed(1)}m", style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: _len, min: 13, max: 14,
                      onChanged: (v) {
                        double rounded = (v * 10).roundToDouble() / 10;
                        _simAction('change_len', rounded);
                      },
                      activeColor: Colors.indigoAccent
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      );
    }

    if (_scenario == 3) {
      if (_step == 1) {
        children.add(
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xD90F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${t('lbl_pieces')}: $_cuts", style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: Slider(
                    value: _cuts.toDouble(), min: 1, max: 10, divisions: 9,
                    onChanged: (v) {
                      _simAction('change_cuts', v.round());
                    },
                    activeColor: Colors.indigoAccent
                  ),
                ),
              ],
            ),
          )
        );
      } else if (_step == 2 && !_isCut) {
        children.add(
          ElevatedButton(
            onPressed: () => _simAction('cut_ribbon'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text(t('lbl_cut_ribbon'), style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        );
      }
    }

    if (_scenario == 4) {
      if (_step == 3 && !_isFastForwarding && _scootersFilled == 1) {
        children.add(
          ElevatedButton.icon(
            onPressed: () => _simAction('fast_forward'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.cyanAccent, width: 2))),
            icon: const Icon(Icons.fast_forward),
            label: Text(t('lbl_fast_forward'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          )
        );
      } else if (_step == 4) {
        children.add(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey, width: 4)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _textController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    decoration: InputDecoration(hintText: "0.0", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.all(8)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _simAction('submit_s4'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                ),
                if (_isCompleted)
                  const Padding(padding: EdgeInsets.only(left: 12), child: Icon(Icons.check, color: Colors.green, size: 40)),
              ],
            ),
          )
        );
      }
    }

    if (children.isEmpty) return const SizedBox.shrink();
    
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.12,
      left: _isSidebarOpen ? sidebarWidth : 0,
      right: 0,
      child: Center(
        child: Column(
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300;

    String hudText = t('s${_scenario}_hud$_step');

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // Canvas
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTapDown: (d) => _handleTapDown(d, constraints.biggest),
                    onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                    onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                    onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: LabPainter(
                          scenario: _scenario, step: _step, zoom: _zoom, panX: _panX, panY: _panY, mouseX: _mouseX, mouseY: _mouseY,
                          activeDragType: _activeDragType, isDark: _isDark,
                          pens: _pens, coinsGrouped: _coinsGrouped, groupAnim: _groupAnim,
                          len: _len, wid: _wid, areasClicked: _areasClicked,
                          cuts: _cuts, isCut: _isCut, cutAnim: _cutAnim, magX: _magX, magY: _magY, decAnim: _decAnim,
                          tankLevel: _tankLevel, canFilled: _canFilled, scootersFilled: _scootersFilled, isFastForwarding: _isFastForwarding, beakerLevel: _beakerLevel, isPouring: _isPouring, poured: _poured, pourAnim: _pourAnim,
                          scaleItem: _scaleItem, scaleAnim: _scaleAnim, chikkiPrice: _chikkiPrice, chipsPrice: _chipsPrice, podiumItem: _podiumItem, confetti: _confetti,
                          isCompleted: _isCompleted, matW: _matW, matH: _matH, matX: _matX, matY: _matY,
                          t: t,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Controls Overlay
            _buildControlsOverlay(sidebarWidth),

            // Persistent Canvas HUD / Step Instruction
            if (!_isCompleted && (hudText != 's${_scenario}_hud$_step' || _showHud))
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth + 40 : 40,
                right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showHud || hudText != 's${_scenario}_hud$_step' ? 1.0 : 0.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xD90F172A),
                          borderRadius: BorderRadius.circular(20),
                          border: const Border(top: BorderSide(color: Colors.indigoAccent, width: 4)),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0x33536DFE), shape: BoxShape.circle),
                              child: const Icon(Icons.info_outline, color: Colors.indigoAccent),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(_showHud ? _hudMessage : hudText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            // Menu Toggle Icon
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
                  backgroundColor: const Color(0xCC000000), // Hex for opacity 0.8
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xCCFF9800)), // Hex for orange opacity 0.8
                  ),
                ),
              ),
            ),

            // Final Success Popup
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: const Color(0xCC000000), // Hex for 0.8 opacity
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        width: 500,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.amber, width: 2),
                          boxShadow: const [BoxShadow(color: Color(0x8A000000), blurRadius: 20)], // 0.54 alpha
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.amber,
                              child: Icon(Icons.emoji_events, color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 24),
                            Text(t('finalSuccessTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 16),
                            _buildRichText(t('s${_scenario}_final'), Colors.white70),
                            const SizedBox(height: 24),
                            Text(
                              t('guideNextScenario'),
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                _playSound('pop');
                                setState(() => _showSuccessPopup = false);
                              },
                              icon: const Icon(Icons.close),
                              label: Text(t('close')),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                backgroundColor: Colors.indigoAccent,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Curtain Raiser
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
                          decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x99536DFE), blurRadius: 20)]), // Indigo 0.6 opacity
                          child: const Icon(Icons.public, size: 80, color: Colors.indigoAccent),
                        ),
                        Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 16),
                        Text(t('appSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
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
                            shadowColor: const Color(0x80536DFE), // Indigo 0.5 opacity
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
class LabPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX, panY;
  final double mouseX, mouseY;
  final String? activeDragType;
  final bool isDark;
  
  final int pens;
  final bool coinsGrouped;
  final double groupAnim;
  
  final double len;
  final double wid;
  final Map<String, bool> areasClicked;
  
  final int cuts;
  final bool isCut;
  final double cutAnim;
  final double magX;
  final double magY;
  final double decAnim;
  
  final double tankLevel;
  final bool canFilled;
  final double scootersFilled;
  final bool isFastForwarding;
  final double beakerLevel;
  final bool isPouring;
  final bool poured;
  final double pourAnim;
  
  final String? scaleItem;
  final double scaleAnim;
  final double? chikkiPrice;
  final double? chipsPrice;
  final String? podiumItem;
  final List<Map<String, dynamic>> confetti;

  final bool isCompleted;
  final double matW, matH, matX, matY;

  final Function(String) t;

  LabPainter({
    required this.scenario, required this.step, required this.zoom, required this.panX, required this.panY, required this.mouseX, required this.mouseY, required this.activeDragType, required this.isDark,
    required this.pens, required this.coinsGrouped, required this.groupAnim,
    required this.len, required this.wid, required this.areasClicked,
    required this.cuts, required this.isCut, required this.cutAnim, required this.magX, required this.magY, required this.decAnim,
    required this.tankLevel, required this.canFilled, required this.scootersFilled, required this.isFastForwarding, required this.beakerLevel, required this.isPouring, required this.poured, required this.pourAnim,
    required this.scaleItem, required this.scaleAnim, required this.chikkiPrice, required this.chipsPrice, required this.podiumItem, required this.confetti,
    required this.isCompleted, required this.matW, required this.matH, required this.matX, required this.matY,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) _drawScen1(canvas);
    if (scenario == 2) _drawScen2(canvas);
    if (scenario == 3) _drawScen3(canvas);
    if (scenario == 4) _drawScen4(canvas);
    if (scenario == 5) _drawScen5(canvas);

    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double strokeW = 1.0]) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && strokeW > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
  }

  void _drawTextOutline(Canvas canvas, String text, double x, double y, double fontSize, Color fill, Color outline, double outlineW, {TextAlign align = TextAlign.center}) {
    TextPainter tpStroke = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans', foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = outlineW..color = outline..strokeJoin = StrokeJoin.round)),
      textDirection: TextDirection.ltr, textAlign: align,
    );
    if (outlineW > 0) {
      tpStroke.layout();
      tpStroke.paint(canvas, Offset(align == TextAlign.center ? x - tpStroke.width / 2 : x, y - tpStroke.height / 2));
    }
    TextPainter tpFill = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
      textDirection: TextDirection.ltr, textAlign: align,
    );
    tpFill.layout();
    tpFill.paint(canvas, Offset(align == TextAlign.center ? x - tpFill.width / 2 : x, y - tpFill.height / 2));
  }

  void _drawSpeechBubble(Canvas canvas, double x, double y, List<String> textLines) {
    canvas.save();
    double maxW = 0;
    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    for (var line in textLines) {
      tp.text = TextSpan(text: line, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
      tp.layout();
      if (tp.width > maxW) maxW = tp.width;
    }
    double w = maxW + 40;
    double h = (textLines.length * 24.0) + 20;
    
    _drawRoundedRect(canvas, x - w/2, y - h - 15, w, h, 12, const Color(0xFFFEF3C7), Colors.black, 2);
    
    Path tail = Path()..moveTo(x - 10, y - 15)..lineTo(x, y)..lineTo(x + 10, y - 15)..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFFFEF3C7));
    
    Paint borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawLine(Offset(x - 10, y - 15), Offset(x, y), borderPaint);
    canvas.drawLine(Offset(x, y), Offset(x + 10, y - 15), borderPaint);
    
    for (int i = 0; i < textLines.length; i++) {
      _drawTextOutline(canvas, textLines[i], x, y - h + 15 + (i * 24), 16, Colors.black, Colors.transparent, 0);
    }
    canvas.restore();
  }

  void _drawLine(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width) {
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), Paint()..color = color..strokeWidth = width);
  }

  void _drawPenIcon(Canvas canvas, double x, double y, double scale, [bool rotated = false]) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    if (rotated) canvas.rotate(pi / 6);
    
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -40, 10, 70), const Radius.circular(3)), Paint()..color = const Color(0xFF1E3A8A));
    
    Path tip = Path()..moveTo(-5, 30)..lineTo(5, 30)..lineTo(0, 45)..close();
    canvas.drawPath(tip, Paint()..color = const Color(0xFF94A3B8));
    
    Path ink = Path()..moveTo(-1, 35)..lineTo(1, 35)..lineTo(0, 45)..close();
    canvas.drawPath(ink, Paint()..color = const Color(0xFF0F172A));
    
    canvas.drawRect(const Rect.fromLTWH(-8, -30, 3, 20), Paint()..color = const Color(0xFF64748B));
    canvas.drawRect(const Rect.fromLTWH(-5, -45, 10, 5), Paint()..color = const Color(0xFF64748B));
    
    canvas.restore();
  }

  void _drawBasketIcon(Canvas canvas, double x, double y, double w, double h, bool isHover) {
    canvas.save();
    Color fill = isHover ? const Color(0xFFF97316) : const Color(0xFFEA580C);
    Paint stroke = Paint()..color = const Color(0xFF7C2D12)..style = PaintingStyle.stroke..strokeWidth = 3;
    
    _drawLine(canvas, x + 20, y, x + w - 20, y, const Color(0xFF7C2D12), 3);
    
    Path basket = Path()..moveTo(x, y)..lineTo(x + 30, y + h)..lineTo(x + w - 30, y + h)..lineTo(x + w, y)..close();
    canvas.drawPath(basket, Paint()..color = fill);
    canvas.drawPath(basket, stroke);
    
    Paint pattern = Paint()..color = const Color(0xFF9A3412);
    for (int i = 1; i < 7; i++) {
      double pxTop = x + i * (w / 7);
      double pxBot = x + 30 + i * ((w - 60) / 7);
      Path slit = Path()..moveTo(pxTop - 5, y + 10)..lineTo(pxBot - 3, y + h - 10)..lineTo(pxBot + 3, y + h - 10)..lineTo(pxTop + 5, y + 10)..close();
      canvas.drawPath(slit, pattern);
    }
    
    _drawLine(canvas, x - 5, y, x + w + 5, y, const Color(0xFF9A3412), 8);
    canvas.restore();
  }

  void _drawRegister(Canvas canvas, double x, double y, String totalStr) {
    canvas.save();
    Path reg = Path()..moveTo(x, y + 50)..lineTo(x + 30, y - 20)..lineTo(x + 170, y - 20)..lineTo(x + 200, y + 50)..lineTo(x + 200, y + 150)..lineTo(x, y + 150)..close();
    canvas.drawPath(reg, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawPath(reg, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 3);
    
    canvas.drawRect(Rect.fromLTWH(x + 40, y - 10, 120, 40), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(Rect.fromLTWH(x + 40, y - 10, 120, 40), Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 4);
    _drawTextOutline(canvas, "Total: ₹$totalStr", x + 100, y + 10, 14, const Color(0xFF4ADE80), Colors.transparent, 0);
    
    Path base = Path()..moveTo(x - 30, y - 50)..lineTo(x + 10, y - 50)..lineTo(x + 10, y + 20)..lineTo(x - 30, y + 20)..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFFF8FAFC));
    _drawLine(canvas, x - 30, y + 20, x + 10, y + 20, const Color(0xFFCBD5E1), 2);
    
    List<Color> colors = [const Color(0xFFEF4444), const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B)];
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 4; c++) {
        canvas.drawRect(Rect.fromLTWH(x + 40 + c * 30, y + 60 + r * 25, 20, 15), Paint()..color = colors[c % 4]);
        canvas.drawRect(Rect.fromLTWH(x + 40 + c * 30, y + 60 + r * 25, 20, 15), Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1);
      }
    }
    canvas.restore();
  }

  void _drawCoin(Canvas canvas, double x, double y, String type, String label, [double scale = 1.0]) {
    canvas.save(); canvas.translate(x, y); canvas.scale(scale, scale);
    canvas.drawCircle(Offset.zero, 18, Paint()..color = type == 'gold' ? const Color(0xFFFCD34D) : const Color(0xFFE2E8F0));
    canvas.drawCircle(Offset.zero, 18, Paint()..color = type == 'gold' ? const Color(0xFFB45309) : const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(Offset.zero, 14, Paint()..color = type == 'gold' ? const Color(0xFFB45309) : const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 2);
    _drawTextOutline(canvas, label, 0, 2, 12, const Color(0xFF1E293B), Colors.transparent, 0);
    canvas.restore();
  }

  void _drawScen1(Canvas canvas) {
    Color tColTable = const Color(0xFF452B17);
    canvas.drawRect(const Rect.fromLTWH(-5000, 200, 10000, 5000), Paint()..color = tColTable);
    _drawLine(canvas, -5000, 200, 5000, 200, const Color(0xFF2D1C0F), 12);

    canvas.drawRect(const Rect.fromLTWH(-5000, 50, 4850, 20), Paint()..color = const Color(0xFF8B5A2B));
    canvas.drawRect(const Rect.fromLTWH(-400, -20, 50, 70), Paint()..color = const Color(0xFFEF4444));
    canvas.drawRect(const Rect.fromLTWH(-330, 0, 40, 50), Paint()..color = const Color(0xFF3B82F6));
    
    double shelfPenX = -200;
    double shelfPenY = 0;
    
    if (activeDragType != 'pen' || step > 2 || pens >= 5) {
      _drawPenIcon(canvas, shelfPenX, shelfPenY, 1.5);
      if (step <= 2) {
        canvas.drawRect(Rect.fromLTWH(shelfPenX - 35, shelfPenY - 55, 70, 110), Paint()..color = const Color(0xFFFDE047)..style = PaintingStyle.stroke..strokeWidth = 4);
      }
      _drawRoundedRect(canvas, shelfPenX - 30, shelfPenY + 30, 80, 30, 4, Colors.white, Colors.black, 2);
      _drawTextOutline(canvas, t('lbl_price_tag'), shelfPenX + 10, shelfPenY + 45, 16, Colors.black, Colors.transparent, 0);
    }

    if (step == 2 && pens >= 1 && pens < 5) {
      _drawSpeechBubble(canvas, 150, 50, [t('s1_b1'), t('s1_b2')]);
    }

    double basketX = -350, basketY = 150, basketW = 240, basketH = 120;
    bool isHover = activeDragType == 'pen' && Rect.fromLTWH(basketX, basketY, basketW, basketH).contains(Offset(mouseX, mouseY));
    
    for (int i = 0; i < pens; i++) {
      _drawPenIcon(canvas, basketX + 40 + i * 40, basketY + 20, 1.2, true);
    }
    
    _drawBasketIcon(canvas, basketX, basketY, basketW, basketH, isHover);
    _drawTextOutline(canvas, t('lbl_basket'), basketX + basketW / 2, basketY + basketH + 30, 16, const Color(0xFFCBD5E1), Colors.transparent, 0);

    double regX = 300, regY = 50;
    _drawRegister(canvas, regX, regY, (pens * 9.5).toStringAsFixed(2));
    _drawTextOutline(canvas, t('lbl_cash_register'), regX + 100, regY - 30, 16, const Color(0xFFCBD5E1), Colors.transparent, 0);

    double coinX9 = 50, coinX50 = 150, coinBaseY = 250;

    if (groupAnim > 0) {
      double p = groupAnim;
      double ease = 1 - pow(1 - p, 3).toDouble();
      
      canvas.saveLayer(Rect.fromLTWH(-5000, -5000, 10000, 10000), Paint()..color = Color.fromRGBO(255, 255, 255, sin(p * pi)));
      canvas.drawCircle(Offset(coinX50, coinBaseY - 20), 60, Paint()..color = const Color(0xFFFEF08A));
      canvas.drawCircle(Offset(coinX9, coinBaseY - 20), 60, Paint()..color = const Color(0xFFFEF08A));
      canvas.restore();

      for (int i = 0; i < pens; i++) {
        double startY = coinBaseY - i * 12;
        double currentY = startY + (coinBaseY - startY) * ease;
        _drawCoin(canvas, coinX9, currentY, 'gold', t('lbl_rs') + '9');
        _drawCoin(canvas, coinX50, currentY, 'silver', t('lbl_50p'));
      }

      canvas.saveLayer(Rect.fromLTWH(-5000, -5000, 10000, 10000), Paint()..color = Color.fromRGBO(255, 255, 255, ease));
      _drawRoundedRect(canvas, coinX9 - 25, coinBaseY + 20, 50, 24, 4, Colors.white, Colors.black, 2);
      _drawTextOutline(canvas, t('lbl_45'), coinX9, coinBaseY + 32, 14, Colors.black, Colors.transparent, 0);
      _drawRoundedRect(canvas, coinX50 - 30, coinBaseY + 20, 60, 24, 4, Colors.white, Colors.black, 2);
      _drawTextOutline(canvas, t('lbl_2_50'), coinX50, coinBaseY + 32, 14, Colors.black, Colors.transparent, 0);
      canvas.restore();
      
    } else if (coinsGrouped) {
      _drawCoin(canvas, coinX9, coinBaseY, 'gold', t('lbl_rs') + '9');
      _drawCoin(canvas, coinX50, coinBaseY, 'silver', t('lbl_50p'));
      _drawRoundedRect(canvas, coinX9 - 25, coinBaseY + 20, 50, 24, 4, Colors.white, Colors.black, 2);
      _drawTextOutline(canvas, t('lbl_45'), coinX9, coinBaseY + 32, 14, Colors.black, Colors.transparent, 0);
      _drawRoundedRect(canvas, coinX50 - 30, coinBaseY + 20, 60, 24, 4, Colors.white, Colors.black, 2);
      _drawTextOutline(canvas, t('lbl_2_50'), coinX50, coinBaseY + 32, 14, Colors.black, Colors.transparent, 0);
    } else {
      for (int i = 0; i < pens; i++) {
        _drawCoin(canvas, coinX9, coinBaseY - i * 12, 'gold', t('lbl_rs') + '9');
        _drawCoin(canvas, coinX50, coinBaseY - i * 12, 'silver', t('lbl_50p'));
      }
    }

    if (activeDragType == 'pen') {
      _drawPenIcon(canvas, mouseX, mouseY, 1.5);
    }
    
    if (step >= 4) {
      canvas.drawRect(Rect.fromLTWH(basketX - 10, basketY - 20, basketW + 20, basketH + 40), Paint()..color = const Color(0xFFEAB308)..style = PaintingStyle.stroke..strokeWidth = 4);
      canvas.drawRect(Rect.fromLTWH(regX + 10, regY - 50, 180, 70), Paint()..color = const Color(0xFFEAB308)..style = PaintingStyle.stroke..strokeWidth = 4);
      
      _drawSpeechBubble(canvas, basketX + basketW / 2 + 100, basketY - 30, [t('s1_s1'), t('s1_s2'), t('s1_s3')]);
    }
  }

  void _drawScen2(Canvas canvas) {
    double cx = -450, cy = -150;
    double scale = 50; 
    double wl = 13, dl = len - 13; 
    double ww = 5, dw = wid - 5;   

    List<Map<String, dynamic>> areas = [
      {'k': 'main', 'x': cx, 'y': cy, 'w': wl*scale, 'h': ww*scale, 'area': wl*ww, 'c': const Color(0xFF3B82F6)},
      {'k': 'right', 'x': cx + wl*scale, 'y': cy, 'w': dl*scale, 'h': ww*scale, 'area': dl*ww, 'c': const Color(0xFF10B981)},
      {'k': 'bottom', 'x': cx, 'y': cy + ww*scale, 'w': wl*scale, 'h': dw*scale, 'area': wl*dw, 'c': const Color(0xFFF59E0B)},
      {'k': 'corner', 'x': cx + wl*scale, 'y': cy + ww*scale, 'w': dl*scale, 'h': dw*scale, 'area': dl*dw, 'c': const Color(0xFFEC4899)}
    ];

    double totalArea = 0;
    for (var a in areas) {
      bool isHover = Rect.fromLTWH(a['x'], a['y'], a['w'], a['h']).contains(Offset(mouseX, mouseY));
      bool isClicked = areasClicked[a['k']] == true;
      
      double alpha = 1.0;
      if (!isClicked && !isHover) alpha = 0.4;
      else if (isHover && !isClicked) alpha = 0.7;
      
      canvas.drawRect(Rect.fromLTWH(a['x'], a['y'], a['w'], a['h']), Paint()..color = (a['c'] as Color).withAlpha((alpha * 255).toInt()));
      canvas.drawRect(Rect.fromLTWH(a['x'], a['y'], a['w'], a['h']), Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);

      if (isClicked) {
        totalArea += a['area'];
        String label = "";
        if (a['k'] == 'main') label = "13 x 5 = 65";
        else if (a['k'] == 'right') label = "13 x ${dl.toStringAsFixed(1)} = ${(13*dl).toStringAsFixed(1)}";
        else if (a['k'] == 'bottom') label = "5 x ${dw.toStringAsFixed(1)} = ${(5*dw).toStringAsFixed(1)}";
        else if (a['k'] == 'corner') label = "${dl.toStringAsFixed(1)} x ${dw.toStringAsFixed(1)} = ${(dl*dw).toStringAsFixed(2)}";
        
        double fontSize = a['k'] == 'main' ? 24 : (a['k'] == 'corner' ? 12 : 16);
        _drawTextOutline(canvas, label, a['x'] + a['w']/2, a['y'] + a['h']/2, fontSize, Colors.white, Colors.black, 2);
      }
    }

    _drawTextOutline(canvas, "${wid.toStringAsFixed(1)}m", cx - 40, cy + (wid*scale)/2, 20, const Color(0xFFCBD5E1), Colors.transparent, 0);
    _drawTextOutline(canvas, "${len.toStringAsFixed(1)}m", cx + (len*scale)/2, cy - 20, 20, const Color(0xFFCBD5E1), Colors.transparent, 0);

    double calX = 350, calY = -150;
    _drawRoundedRect(canvas, calX, calY, 250, 300, 16, const Color(0xFF1E293B), const Color(0xFF94A3B8), 4);
    _drawTextOutline(canvas, t('lbl_area_calc'), calX + 125, calY + 30, 16, const Color(0xFFCBD5E1), Colors.transparent, 0);
    _drawRoundedRect(canvas, calX + 25, calY + 80, 200, 60, 8, const Color(0xFF0F172A), const Color(0xFF475569), 2);
    _drawTextOutline(canvas, "${totalArea.toStringAsFixed(2)} ${t('lbl_sqm')}", calX + 125, calY + 110, 24, const Color(0xFF10B981), Colors.transparent, 0);

    if (step >= 4) {
      double sy = 180;
      _drawRoundedRect(canvas, -250, sy, 500, 120, 16, const Color(0xFF1E293B), const Color(0xFF94A3B8), 4);
      _drawTextOutline(canvas, "5.7 × 13.3 = 75.81", 0, sy + 40, 36, const Color(0xFFCBD5E1), Colors.transparent, 0);
      _drawTextOutline(canvas, "57 × 133 = 7581", 0, sy + 80, 18, const Color(0xFF94A3B8), Colors.transparent, 0);
    }
  }

  void _drawMagnifier(Canvas canvas, double x, double y) {
    canvas.save(); canvas.translate(x, y);
    canvas.drawCircle(Offset.zero, 50, Paint()..color = const Color(0x4DFFFFFF));
    canvas.drawCircle(Offset.zero, 50, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 10);
    _drawLine(canvas, 35, 35, 80, 80, const Color(0xFF475569), 16); 
    canvas.restore();
  }

  void _drawScen3(Canvas canvas) {
    double cx = -400, cy = -50;
    double rw = 800, rh = 40; 
    
    canvas.drawRect(const Rect.fromLTWH(-5000, 0, 10000, 5000), Paint()..color = const Color(0xFF452B17));
    _drawLine(canvas, -5000, 0, 5000, 0, const Color(0xFF2D1C0F), 12);
    
    _drawRoundedRect(canvas, cx, cy - 60, rw, 40, 4, const Color(0xFFFCD34D), const Color(0xFFB45309), 2);
    _drawTextOutline(canvas, t('lbl_ruler'), cx + rw/2, cy - 80, 14, const Color(0xFFCBD5E1), Colors.transparent, 0);
    for(int i = 0; i <= 10; i++) {
      double tickX = cx + (i/10) * rw;
      _drawLine(canvas, tickX, cy - 20, tickX, cy - 40, Colors.black, 2);
      if(i < 10) {
        for(int j = 1; j < 10; j++) _drawLine(canvas, tickX + (j/10) * (rw/10), cy - 20, tickX + (j/10) * (rw/10), cy - 30, Colors.black, 1);
      }
    }

    if (cutAnim > 0) {
      canvas.drawRect(Rect.fromLTWH(cx, cy, rw, rh), Paint()..color = const Color(0xFFEC4899));
      _drawLine(canvas, cx + cutAnim * rw, cy - 10, cx + cutAnim * rw, cy + rh + 10, const Color(0xFF60A5FA), 4); 
    } else if (isCut) {
      double segW = rw / cuts;
      for(int i = 0; i < cuts; i++) {
        canvas.drawRect(Rect.fromLTWH(cx + i * segW + 2, cy, segW - 4, rh), Paint()..color = const Color(0xFFEC4899));
        canvas.drawRect(Rect.fromLTWH(cx + i * segW + 2, cy, segW - 4, rh), Paint()..color = const Color(0xFFBE185D)..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    } else {
      canvas.drawRect(Rect.fromLTWH(cx, cy, rw, rh), Paint()..color = const Color(0xFFEC4899));
      canvas.drawRect(Rect.fromLTWH(cx, cy, rw, rh), Paint()..color = const Color(0xFFBE185D)..style = PaintingStyle.stroke..strokeWidth = 2);
      if(cuts > 1) {
        for(int i = 1; i < cuts; i++) _drawLine(canvas, cx + i * (rw / cuts), cy, cx + i * (rw / cuts), cy + rh, const Color(0x80FFFFFF), 2);
      }
    }
    _drawTextOutline(canvas, t('lbl_ribbon'), cx + rw/2, cy + rh + 20, 16, const Color(0xFFEC4899), Colors.transparent, 0);

    if (step >= 3) {
      double mx = activeDragType == 'magnifier' ? mouseX : magX;
      double my = activeDragType == 'magnifier' ? mouseY : magY;
      
      bool isZooming = isCut && activeDragType == 'magnifier' && my > cy - 80 && my < cy + rh + 80 && mx > cx && mx < cx + rw;
      
      if (isZooming) {
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(mx, my), radius: 120)));
        canvas.drawCircle(Offset(mx, my), 120, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(mx, my), 120, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 12);
        
        String val = (3.9 / cuts).toStringAsFixed(2);
        _drawTextOutline(canvas, "${val}m", mx, my - 20, 36, const Color(0xFF0F172A), Colors.transparent, 0);
        canvas.restore();
      } else {
        _drawMagnifier(canvas, mx, my);
      }
    }

    if (step >= 4) {
      double sx = -200; double sy = 100;
      _drawRoundedRect(canvas, sx, sy, 400, 120, 16, const Color(0xFF1E293B), const Color(0xFF94A3B8), 4);
      
      double p = min(1.0, decAnim);
      
      _drawTextOutline(canvas, "3", sx + 100, sy + 60, 36, const Color(0xFFCBD5E1), Colors.transparent, 0, align: TextAlign.left);
      _drawTextOutline(canvas, "9 ÷ 10 =", sx + 140, sy + 60, 36, const Color(0xFFCBD5E1), Colors.transparent, 0, align: TextAlign.left);
      
      double decX = sx + 120 - (p * 40);
      _drawTextOutline(canvas, ".", decX, sy + 60, 36, const Color(0xFFEF4444), Colors.transparent, 0, align: TextAlign.left);
      
      if (p > 0.5) _drawTextOutline(canvas, "0", sx + 60, sy + 60, 36, const Color(0xFFCBD5E1), Colors.transparent, 0, align: TextAlign.left);
    }
  }

  void _drawScooterIcon(Canvas canvas, double x, double y, bool isFilled, Color color) {
    canvas.save(); canvas.translate(x, y);
    Color baseColor = isFilled ? color : const Color(0xFF64748B); 
    Color tireColor = const Color(0xFF1E293B);
    
    canvas.drawCircle(const Offset(15, 35), 12, Paint()..color = tireColor);
    canvas.drawCircle(const Offset(15, 35), 6, Paint()..color = const Color(0xFF94A3B8));
    
    canvas.drawCircle(const Offset(60, 35), 12, Paint()..color = tireColor);
    canvas.drawCircle(const Offset(60, 35), 6, Paint()..color = const Color(0xFF94A3B8));

    Path body = Path()..moveTo(10, 15)..lineTo(35, 15)..lineTo(45, 30)..lineTo(55, 30)..lineTo(65, 5)..lineTo(55, 5)..lineTo(45, 20)..lineTo(30, 20)..lineTo(20, 30)..lineTo(5, 30)..close(); 
    canvas.drawPath(body, Paint()..color = baseColor);
    canvas.drawPath(body, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);

    canvas.drawCircle(const Offset(65, 5), 5, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(const Offset(65, 5), 5, Paint()..color = const Color(0xFFFDE047)..style = PaintingStyle.stroke..strokeWidth = 1);
    
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(5, 10, 30, 8), const Radius.circular(4)), Paint()..color = const Color(0xFF0F172A));
    _drawLine(canvas, 60, 8, 50, -5, const Color(0xFF0F172A), 4);
    
    if (isFilled && isFastForwarding) {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 70, 40), Paint()..color = const Color(0x80FFFFFF));
    }
    canvas.restore();
  }

  void _drawBeaker(Canvas canvas, double x, double y, double w, double h, double fillLevel) {
    canvas.save();
    Path beaker = Path()..moveTo(x + 10, y - 40)..lineTo(x + w - 10, y - 40)..lineTo(x + w/2 + 10, y - 10)..lineTo(x + w/2 + 10, y + 20)..lineTo(x + w/2 - 10, y + 20)..lineTo(x + w/2 - 10, y - 10)..close();
    canvas.drawPath(beaker, Paint()..color = const Color(0xCCCBD5E1)); // 0.8 alpha
    canvas.drawPath(beaker, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 3);
    
    if (fillLevel > 0) {
      double liquidH = fillLevel * (h - 20);
      canvas.drawRect(Rect.fromLTWH(x + 5, y + h - liquidH - 5, w - 10, liquidH), Paint()..color = const Color(0xCCFACC15)); // 0.8 alpha
    }
    
    Path outline = Path()..moveTo(x - 5, y)..lineTo(x + w + 5, y)..moveTo(x, y)..lineTo(x, y + h - 15)..quadraticBezierTo(x, y + h, x + 15, y + h)..lineTo(x + w - 15, y + h)..quadraticBezierTo(x + w, y + h, x + w, y + h - 15)..lineTo(x + w, y);
    canvas.drawPath(outline, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawPath(outline, Paint()..color = const Color(0x66F8FAFC)); // 0.4 alpha
    
    List<Map<String, dynamic>> marks = [{'lvl': 0.4, 'lbl': '0.4'}, {'lvl': 0.6, 'lbl': '0.6'}, {'lvl': 0.8, 'lbl': '0.8'}, {'lvl': 1.0, 'lbl': '2.5L'}];
    for (int i = 1; i <= 10; i++) {
      double my = y + h - 5 - (i / 10) * (h - 20);
      double mw = (i % 2 == 0) ? 25 : 12;
      _drawLine(canvas, x + 20, my, x + 20 + mw, my, const Color(0xFF0F172A), 2);
    }
    for (var m in marks) {
      double my = y + h - 5 - (m['lvl'] * (h - 20));
      _drawTextOutline(canvas, m['lbl'], x + w - 15, my + 6, 16, const Color(0xFF0F172A), Colors.transparent, 0, align: TextAlign.right);
    }
    canvas.restore();
  }

  void _drawScen4(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(-5000, -5000, 10000, 5000 + 150), Paint()..color = const Color(0xFF475569)); 
    canvas.drawRect(Rect.fromLTWH(-5000, 150, 10000, 5000), Paint()..color = const Color(0xFF334155)); 
    _drawLine(canvas, -5000, 150, 5000, 150, const Color(0xFF1E293B), 8);

    for (int i = -5; i < 5; i++) {
      double wx = i * 250.0; double wy = -50.0;
      canvas.drawCircle(Offset(wx, wy), 15, Paint()..color = const Color(0x4D334155));
      canvas.drawRect(Rect.fromLTWH(wx - 8, wy + 10, 16, 50), Paint()..color = const Color(0x4D334155));
      canvas.drawCircle(Offset(wx, wy + 65), 12, Paint()..color = const Color(0x4D334155));
    }

    double cx = 150, cy = 100;
    if (step <= 3) {
      _drawRoundedRect(canvas, cx, cy, 320, 90, 12, const Color(0xFF1E293B), const Color(0xFF0F172A), 6);
      _drawTextOutline(canvas, "Scooters", cx + 90, cy + 35, 22, Colors.white, Colors.transparent, 0);
      _drawTextOutline(canvas, "Filled:", cx + 90, cy + 60, 22, Colors.white, Colors.transparent, 0);
      _drawRoundedRect(canvas, cx + 180, cy + 15, 120, 60, 6, const Color(0xFF0F172A), const Color(0xFF334155), 3);
      _drawTextOutline(canvas, scootersFilled.floor().toString(), cx + 240, cy + 48, 48, Colors.white, Colors.transparent, 0);
    }

    double scoX = 30, scoY = -180;
    List<Color> colors = [const Color(0xFF3B82F6), const Color(0xFFEF4444), const Color(0xFF10B981), const Color(0xFFF59E0B)]; 
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 4; c++) {
        double sx = scoX + c * 120.0; double sy = scoY + r * 100.0; int idx = r * 4 + c;
        double fillThreshold = idx * (50 / 8); 
        bool isFilledLoc = scootersFilled > fillThreshold;
        if (step == 2 && scootersFilled == 1 && idx == 0) isFilledLoc = true; 
        if (scootersFilled == 0) isFilledLoc = false;
        
        if (step == 2 && idx == 0 && activeDragType == 'can') {
           canvas.drawCircle(Offset(sx + 35, sy + 20), 50, Paint()..color = const Color(0xFFFDE047)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
        }
        _drawScooterIcon(canvas, sx, sy, isFilledLoc, colors[idx % 4]);
      }
    }

    double tx = -450, ty = -50;
    canvas.save();
    double tankFillH = (tankLevel / 126) * 180;
    if (tankFillH > 0) {
      _drawRoundedRect(canvas, tx + 15, ty + 200 - tankFillH, 210, tankFillH, 15, const Color(0xE6FACC15), Colors.transparent, 0);
      _drawLine(canvas, tx + 15, ty + 200 - tankFillH, tx + 225, ty + 200 - tankFillH, const Color(0xFFFDE047), 4);
    }
    
    _drawRoundedRect(canvas, tx, ty, 240, 220, 24, const Color(0x4DF1F5F9), const Color(0xFFCBD5E1), 6);
    _drawLine(canvas, tx + 20, ty + 20, tx + 20, ty + 200, const Color(0xFF94A3B8), 2);
    
    _drawRoundedRect(canvas, tx + 70, ty - 25, 100, 25, 4, const Color(0xFF1E293B), Colors.black, 3);
    _drawRoundedRect(canvas, tx + 80, ty - 35, 80, 10, 2, const Color(0xFF334155), Colors.black, 2);
    
    _drawTextOutline(canvas, "126 L", tx + 120, ty + 110, 44, Colors.black, Colors.white, 4);
    canvas.restore();

    if (isPouring) {
      canvas.save();
      double pX = tx + 120; double pY = ty + 110; 
      canvas.translate(pX, pY);
      canvas.rotate(pourAnim * pi / 6);
      canvas.translate(-pX, -pY);
      
      _drawRoundedRect(canvas, tx, ty - 100, 240, 220, 24, const Color(0x4DF1F5F9), const Color(0xFFCBD5E1), 6);
      _drawRoundedRect(canvas, tx + 70, ty - 125, 100, 25, 4, const Color(0xFF1E293B), Colors.black, 3);
      
      double startX = tx + 240, startY = ty - 50, endX = 140, endY = 10;
      Path stream = Path()..moveTo(startX, startY)..quadraticBezierTo(startX + 100, startY, endX, endY);
      canvas.drawPath(stream, Paint()..color = const Color(0xE6FACC15)..style = PaintingStyle.stroke..strokeWidth = 15);
      canvas.restore();
    }

    if (step <= 2) {
      double canX = activeDragType == 'can' ? mouseX - 45 : -140;
      double canY = activeDragType == 'can' ? mouseY - 55 : 120;
      
      if (step == 1 && activeDragType != 'can') {
        canvas.save();
        Path arrow = Path()..moveTo(canX, canY + 40)..quadraticBezierTo(tx + 280, ty + 100, tx + 260, ty + 150);
        canvas.drawPath(arrow, Paint()..color = const Color(0xFFFDE047)..style = PaintingStyle.stroke..strokeWidth = 8);
        canvas.translate(tx + 260, ty + 150); canvas.rotate(pi / 4);
        Path head = Path()..moveTo(0, 0)..lineTo(-20, -10)..lineTo(-20, 10)..close();
        canvas.drawPath(head, Paint()..color = const Color(0xFFFDE047));
        canvas.restore();
      }

      canvas.save();
      if (step == 2 && activeDragType == 'can' && Rect.fromLTWH(0, -250, 250, 250).contains(Offset(mouseX, mouseY))) {
        canvas.translate(canX + 45, canY + 55); canvas.rotate(-pi / 4); canvas.translate(-(canX + 45), -(canY + 55));
        Path stream = Path()..moveTo(canX, canY + 20)..quadraticBezierTo(canX - 50, canY + 80, 60, -120);
        canvas.drawPath(stream, Paint()..color = const Color(0xE6FACC15)..style = PaintingStyle.stroke..strokeWidth = 8);
      }

      _drawRoundedRect(canvas, canX, canY, 90, 110, 12, const Color(0xFFCBD5E1), const Color(0xFF475569), 5);
      _drawRoundedRect(canvas, canX + 20, canY - 25, 50, 30, 8, Colors.transparent, const Color(0xFF475569), 5);
      _drawRoundedRect(canvas, canX - 10, canY + 15, 15, 20, 3, const Color(0xFF1E293B), Colors.black, 2); 
      _drawRoundedRect(canvas, canX + 15, canY + 45, 60, 40, 6, const Color(0xFFF8FAFC), const Color(0xFF94A3B8), 2);
      _drawTextOutline(canvas, "2.5L", canX + 45, canY + 65, 18, const Color(0xFF0F172A), Colors.transparent, 0);
      canvas.restore();
    }

    if (step >= 4) {
      double bx = 90, by = 60, bw = 120, bh = 180;
      if (poured) {
        double cox = bx - 140, coy = by + bh - (0.4 * (bh - 20)) - 30;
        _drawRoundedRect(canvas, cox, coy, 90, 60, 8, const Color(0xFFFEF08A), const Color(0xFFCA8A04), 3);
        Path tail = Path()..moveTo(cox + 90, coy + 30)..lineTo(cox + 110, coy + 30)..lineTo(cox + 90, coy + 40)..close();
        canvas.drawPath(tail, Paint()..color = const Color(0xFFFEF08A)); canvas.drawPath(tail, Paint()..color = const Color(0xFFCA8A04)..style = PaintingStyle.stroke..strokeWidth = 3);
        
        _drawTextOutline(canvas, "0.4", cox + 45, coy + 22, 20, Colors.black, Colors.transparent, 0);
        _drawTextOutline(canvas, "tenths", cox + 45, coy + 38, 12, Colors.black, Colors.transparent, 0);
        _drawTextOutline(canvas, "of a can", cox + 45, coy + 50, 12, Colors.black, Colors.transparent, 0);
      }
      _drawBeaker(canvas, bx, by, bw, bh, beakerLevel / 1.0);
    }
  }

  void _drawPacket(Canvas canvas, double x, double y, String type) {
    canvas.save();
    canvas.translate(x, y);
    
    if (type == 'chikki') {
      _drawRoundedRect(canvas, 0, 0, 110, 150, 6, const Color(0xFFFCD34D), const Color(0xFFB45309), 4);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 110, 15), Paint()..color = const Color(0xFFFBBF24));
      for (int i = 0; i < 110; i += 10) _drawLine(canvas, i.toDouble(), 0, i.toDouble(), 15, const Color(0xFFB45309), 1);
      canvas.drawRect(const Rect.fromLTWH(10, 25, 90, 45), Paint()..color = const Color(0xFFEF4444));
      _drawTextOutline(canvas, 'PEANUT', 55, 38, 14, Colors.white, Colors.transparent, 0);
      _drawTextOutline(canvas, 'CHIKKI', 55, 55, 18, Colors.white, Colors.transparent, 0);
      _drawRoundedRect(canvas, 85, 20, 10, 10, 0, Colors.white, const Color(0xFF16A34A), 1);
      canvas.drawCircle(const Offset(90, 25), 3, Paint()..color = const Color(0xFF16A34A));

      canvas.drawRect(const Rect.fromLTWH(25, 80, 60, 40), Paint()..color = const Color(0xFFD97706));
      for (int i = 25; i <= 85; i += 10) _drawLine(canvas, i.toDouble(), 80, i.toDouble(), 120, const Color(0xFF92400E), 1);
      for (int i = 80; i <= 120; i += 10) _drawLine(canvas, 25, i.toDouble(), 85, i.toDouble(), const Color(0xFF92400E), 1);

      _drawTextOutline(canvas, '210g', 25, 140, 12, const Color(0xFFB45309), Colors.transparent, 0);
      _drawRoundedRect(canvas, 10, 160, 90, 40, 8, Colors.white, const Color(0xFF94A3B8), 2);
      _drawTextOutline(canvas, '210g', 55, 172, 14, const Color(0xFF475569), Colors.transparent, 0);
      _drawTextOutline(canvas, '₹70.50', 55, 188, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    } else {
      _drawRoundedRect(canvas, 0, 0, 110, 150, 6, const Color(0xFF22C55E), const Color(0xFF14532D), 4);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 110, 15), Paint()..color = const Color(0xFF16A34A));
      for (int i = 0; i < 110; i += 10) _drawLine(canvas, i.toDouble(), 0, i.toDouble(), 15, const Color(0xFF14532D), 1);
      canvas.drawOval(Rect.fromCenter(center: const Offset(55, 45), width: 90, height: 50), Paint()..color = const Color(0xFFFEF08A));
      _drawTextOutline(canvas, 'POTATO', 55, 38, 14, const Color(0xFFB45309), Colors.transparent, 0);
      _drawTextOutline(canvas, 'CHIPS', 55, 55, 18, const Color(0xFFB45309), Colors.transparent, 0);
      _drawRoundedRect(canvas, 85, 20, 10, 10, 0, Colors.white, const Color(0xFF16A34A), 1);
      canvas.drawCircle(const Offset(90, 25), 3, Paint()..color = const Color(0xFF16A34A));

      canvas.save(); canvas.translate(45, 100); canvas.rotate(pi / 6); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 40, height: 30), Paint()..color = const Color(0xFFFDE047)); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 40, height: 30), Paint()..color = const Color(0xFFCA8A04)..style = PaintingStyle.stroke..strokeWidth = 2); canvas.restore();
      canvas.save(); canvas.translate(65, 110); canvas.rotate(-pi / 4); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 36, height: 24), Paint()..color = const Color(0xFFFDE047)); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 36, height: 24), Paint()..color = const Color(0xFFCA8A04)..style = PaintingStyle.stroke..strokeWidth = 2); canvas.restore();
      canvas.save(); canvas.translate(55, 120); canvas.rotate(pi / 8); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 44, height: 28), Paint()..color = const Color(0xFFFDE047)); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 44, height: 28), Paint()..color = const Color(0xFFCA8A04)..style = PaintingStyle.stroke..strokeWidth = 2); canvas.restore();

      _drawTextOutline(canvas, '110g', 25, 140, 12, const Color(0xFF14532D), Colors.transparent, 0);
      _drawRoundedRect(canvas, 10, 160, 90, 40, 8, Colors.white, const Color(0xFF94A3B8), 2);
      _drawTextOutline(canvas, '110g', 55, 172, 14, const Color(0xFF475569), Colors.transparent, 0);
      _drawTextOutline(canvas, '₹33.25', 55, 188, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    }
    canvas.restore();
  }

  void _drawScaleMachine(Canvas canvas, double x, double y, String displayValue, bool isCalculating) {
    canvas.save();
    canvas.drawRect(Rect.fromLTWH(x - 15, y - 180, 30, 180), Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRect(Rect.fromLTWH(x - 15, y - 180, 30, 180), Paint()..color = Colors.black..style = PaintingStyle.stroke);
    
    _drawRoundedRect(canvas, x - 70, y - 240, 140, 70, 10, const Color(0xFF475569), const Color(0xFF1E293B), 4);
    canvas.drawRect(Rect.fromLTWH(x - 60, y - 230, 120, 50), Paint()..color = const Color(0xFF0F172A));
    if (isCalculating) _drawTextOutline(canvas, t('lbl_calc'), x, y - 205, 16, Colors.white, Colors.transparent, 0);
    
    _drawRoundedRect(canvas, x - 130, y - 20, 260, 20, 5, const Color(0xFFF1F5F9), const Color(0xFF94A3B8), 3);
    Path base = Path()..moveTo(x - 120, y)..lineTo(x + 120, y)..lineTo(x + 100, y + 10)..lineTo(x - 100, y + 10)..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFFCBD5E1));
    
    _drawRoundedRect(canvas, x - 140, y + 10, 280, 90, 16, const Color(0xFF94A3B8), const Color(0xFF475569), 4);
    canvas.drawRect(Rect.fromLTWH(x - 110, y + 100, 20, 10), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(Rect.fromLTWH(x + 90, y + 100, 20, 10), Paint()..color = const Color(0xFF1E293B));
    
    _drawRoundedRect(canvas, x - 120, y + 30, 160, 50, 6, const Color(0xFF0F172A), const Color(0xFF1E293B), 3);
    _drawTextOutline(canvas, displayValue, x - 40, y + 55, 22, const Color(0xFF4ADE80), Colors.transparent, 0);
    if (displayValue != "₹0.000" && !isCalculating) _drawTextOutline(canvas, "per gram", x - 40, y + 75, 12, const Color(0xFF4ADE80), Colors.transparent, 0);
    
    _drawRoundedRect(canvas, x + 50, y + 25, 70, 60, 4, const Color(0xFFCBD5E1), const Color(0xFF64748B), 2);
    List<Color> btnColors = [const Color(0xFFEF4444), const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFF8B5A2B), const Color(0xFF94A3B8)];
    for(int r = 0; r < 3; r++) {
        for(int c = 0; c < 2; c++) {
            canvas.drawRect(Rect.fromLTWH(x + 55 + c * 30, y + 30 + r * 18, 22, 12), Paint()..color = btnColors[r * 2 + c]);
            canvas.drawRect(Rect.fromLTWH(x + 55 + c * 30, y + 30 + r * 18, 22, 12), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke);
        }
    }
    canvas.restore();
  }

  void _drawPodium(Canvas canvas, double x, double y) {
    canvas.save(); canvas.translate(x, y);
    canvas.drawRect(const Rect.fromLTWH(-120, 60, 100, 110), Paint()..color = const Color(0xFF6366F1)); 
    canvas.drawRect(const Rect.fromLTWH(-120, 60, 100, 110), Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.stroke..strokeWidth = 4);
    _drawTextOutline(canvas, "2", -70, 120, 56, const Color(0xFFF8FAFC), Colors.transparent, 0);
    
    canvas.drawRect(const Rect.fromLTWH(100, 90, 100, 80), Paint()..color = const Color(0xFF6366F1)); 
    canvas.drawRect(const Rect.fromLTWH(100, 90, 100, 80), Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.stroke..strokeWidth = 4);
    _drawTextOutline(canvas, "3", 150, 135, 56, const Color(0xFFF8FAFC), Colors.transparent, 0);

    canvas.drawRect(const Rect.fromLTWH(-20, 0, 120, 170), Paint()..color = const Color(0xFF6366F1)); 
    canvas.drawRect(const Rect.fromLTWH(-20, 0, 120, 170), Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.stroke..strokeWidth = 4);
    _drawTextOutline(canvas, "1", 40, 60, 72, const Color(0xFFF8FAFC), Colors.transparent, 0);
    
    _drawRoundedRect(canvas, -5, 90, 90, 50, 4, const Color(0xFFF8FAFC), const Color(0xFF6366F1), 3);
    _drawTextOutline(canvas, "Best Value", 40, 105, 14, const Color(0xFF6366F1), Colors.transparent, 0);
    _drawTextOutline(canvas, "Award", 40, 125, 14, const Color(0xFF6366F1), Colors.transparent, 0);
    canvas.restore();
  }

  void _drawScen5(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(matX, matY, matW, matH), Paint()..color = const Color(0xFF334155));
    canvas.drawRect(Rect.fromLTWH(matX, matY + 100, matW, 20), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(Rect.fromLTWH(matX, matY + 300, matW, 20), Paint()..color = const Color(0xFF1E293B));
    
    List<Color> topC = [const Color(0xFF991B1B), const Color(0xFF1E40AF), const Color(0xFF065F46), const Color(0xFF9A3412), const Color(0xFF78350F)];
    List<Color> botC = [const Color(0xFF831843), const Color(0xFF5B21B6), const Color(0xFF0F766E), const Color(0xFFA16207), const Color(0xFF334155)];
    for (int i = 0; i < 8; i++) {
      canvas.drawRect(Rect.fromLTWH(matX + 50 + i * 160.0, matY + 20, 60, 80), Paint()..color = topC[i % 5]);
      canvas.drawRect(Rect.fromLTWH(matX + 20 + i * 180.0, matY + 200, 70, 100), Paint()..color = botC[i % 5]);
    }
    
    double scaleX = 0, scaleY = matY + 500;
    bool isCalc = scaleAnim > 0;
    String dispText = isCalc ? "" : (scaleItem == 'chikki' ? "₹0.335" : (scaleItem == 'chips' ? "₹0.302" : "₹0.000"));
    _drawScaleMachine(canvas, scaleX, scaleY, dispText, isCalc);

    if (scaleItem != null && scaleAnim == 0) {
      canvas.save();
      double startX = scaleX, startY = scaleY + 120;
      
      Paint arrowP = Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 6;
      canvas.drawPath(Path()..moveTo(startX, startY)..quadraticBezierTo(startX - 150, startY + 50, startX - 250, startY + 150), arrowP);
      canvas.drawPath(Path()..moveTo(startX, startY)..quadraticBezierTo(startX - 50, startY + 50, startX - 100, startY + 150), arrowP);
      canvas.drawLine(Offset(startX, startY), Offset(startX, startY + 150), arrowP);
      canvas.drawPath(Path()..moveTo(startX, startY)..quadraticBezierTo(startX + 50, startY + 50, startX + 100, startY + 150), arrowP);
      canvas.drawPath(Path()..moveTo(startX, startY)..quadraticBezierTo(startX + 150, startY + 50, startX + 250, startY + 150), arrowP);
      
      String calcText = scaleItem == 'chikki' ? "Visualizing: 70.5 / 210 = 0.335" : "Visualizing: 33.25 / 110 = 0.302";
      _drawRoundedRect(canvas, startX + 80, startY + 20, 280, 40, 20, Colors.white, const Color(0xFF0F172A), 2);
      _drawTextOutline(canvas, calcText, startX + 220, startY + 40, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      
      Color pileColor = scaleItem == 'chikki' ? const Color(0xFFD97706) : const Color(0xFFFDE047);
      Color pileBorder = scaleItem == 'chikki' ? const Color(0xFF92400E) : const Color(0xFFCA8A04);
      List<double> pileX = [startX - 250, startX - 100, startX, startX + 100, startX + 250];
      
      for (double px in pileX) {
        Path tri = Path()..moveTo(px, startY + 130)..lineTo(px - 30, startY + 170)..lineTo(px + 30, startY + 170)..close();
        canvas.drawPath(tri, Paint()..color = pileColor); canvas.drawPath(tri, Paint()..color = pileBorder..style = PaintingStyle.stroke..strokeWidth = 2);
        canvas.drawCircle(Offset(px, startY + 150), 15, Paint()..color = pileColor); canvas.drawCircle(Offset(px, startY + 150), 15, Paint()..color = pileBorder..style = PaintingStyle.stroke..strokeWidth = 2);
      }
      
      String valRupees = scaleItem == 'chikki' ? "70.5 rupees" : "33.25 rupees";
      String valUnits = scaleItem == 'chikki' ? "210 tiny piles" : "110 tiny piles";
      _drawRoundedRect(canvas, startX - 300, startY + 190, 150, 30, 8, const Color(0xFFCBD5E1), Colors.transparent, 0);
      _drawTextOutline(canvas, valRupees, startX - 225, startY + 205, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawRoundedRect(canvas, startX + 150, startY + 190, 150, 30, 8, const Color(0xFFCBD5E1), Colors.transparent, 0);
      _drawTextOutline(canvas, valUnits, startX + 225, startY + 205, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      canvas.restore();
    }

    double podX = 300, podY = 150;
    if (step >= 3) {
      _drawPodium(canvas, podX, podY);
    }

    double chkX = activeDragType == 'chikki' ? mouseX - 55 : (podiumItem == 'chikki' ? 245 : (scaleItem == 'chikki' ? -55 : matX + 100));
    double chkY = activeDragType == 'chikki' ? mouseY - 75 : (podiumItem == 'chikki' ? 0 : (scaleItem == 'chikki' ? matY + 330 : matY + 280));
    
    double chpX = activeDragType == 'chips' ? mouseX - 55 : (podiumItem == 'chips' ? 245 : (scaleItem == 'chips' ? -55 : (step >= 3 ? matX + 250 : matX + 1000)));
    double chpY = activeDragType == 'chips' ? mouseY - 75 : (podiumItem == 'chips' ? 0 : (scaleItem == 'chips' ? matY + 330 : matY + 280));

    if (step == 1 && activeDragType != 'chikki') {
      canvas.drawPath(Path()..moveTo(chkX + 130, chkY + 75)..quadraticBezierTo(scaleX, scaleY - 200, scaleX, scaleY - 100), Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 8);
      canvas.save(); canvas.translate(scaleX, scaleY - 100); canvas.rotate(pi/2); canvas.drawPath(Path()..moveTo(0,0)..lineTo(-20,-15)..lineTo(-20,15)..close(), Paint()..color = const Color(0xFF38BDF8)); canvas.restore();
    }
    if (step == 2 && activeDragType != 'chips') {
      canvas.drawPath(Path()..moveTo(chpX - 30, chpY + 75)..quadraticBezierTo(scaleX, scaleY - 200, scaleX, scaleY - 100), Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 8);
      canvas.save(); canvas.translate(scaleX, scaleY - 100); canvas.rotate(pi/2); canvas.drawPath(Path()..moveTo(0,0)..lineTo(-20,-15)..lineTo(-20,15)..close(), Paint()..color = const Color(0xFF38BDF8)); canvas.restore();
    }

    _drawPacket(canvas, chkX, chkY, 'chikki');
    _drawPacket(canvas, chpX, chpY, 'chips');
    
    if (isCompleted && confetti.isNotEmpty) {
      for (var c in confetti) {
        canvas.save(); canvas.translate(c['x'], c['y']); canvas.rotate(c['rot']);
        canvas.drawRect(Rect.fromLTWH(-c['size']/2, -c['size']/2, c['size'], c['size']), Paint()..color = c['color']);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA (EN, HI, TE)
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "The Decimalverse: A Hands-On Exploration", 'appTitle': "The Decimalverse", 'appSubtitle': "Class 7 • ANALYZING PROPERTIES AND REAL WORLD APPLICATIONS", 'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done",
    'lbl_objective': "Objective / Observation:", 'obsLbl': "Observation:", 'learnLbl': "Learning:", 'summaryTitle': "Goal Reached!", 'checkAnswer': "Check Answer",
    'hudNext': "Next Step", 
    'err_input': "Incorrect value. Please try again.", 'err_action': "Perform the correct action.", 'err_area': "Select all areas first.",
    'finalSuccessTitle': "Activity Completed!", 'finalSuccessDesc': "You have successfully analyzed properties of decimal operations.",
    'reset': "Reset", 'close': "Close", 'guideNextScenario': "This scenario is completed! Please open the sidebar menu to select and try the next scenario.",
    
    'lbl_rs': "₹", 'lbl_total': "Total: ₹", 'lbl_basket': "BASKET", 'lbl_counter': "COUNTER", 'lbl_cash_register': "CASH REGISTER",
    'lbl_group_coins_btn': "Group Coins 👆", 'lbl_price_tag': "₹9.50", 'lbl_45': "₹45", 'lbl_2_50': "₹2.50", 'lbl_50p': "50p",
    's1_b1': "The mission updates:", 's1_b2': "\"Arshad needs to buy 5 pens.\"",
    's1_s1': "5 pens at ₹9.50 each costs ₹47.50.", 's1_s2': "We saw this by adding 9.5 five times,", 's1_s3': "which is the same as 9.5 × 5.",
    
    'lbl_width': "Width (m)", 'lbl_length': "Length (m)", 'lbl_area_calc': "Total Area Calculator", 'lbl_sqm': "sq m",
    'lbl_ribbon': "RIBBON (3.9m)", 'lbl_pieces': "Pieces: ", 'lbl_ruler': "RULER (m)", 'lbl_cut_ribbon': "CUT",
    'lbl_tank': "MAIN TANK", 'lbl_fuel_can': "2.5L CAN", 'lbl_scooters': "SCOOTERS", 'lbl_filled': "Filled: ", 'lbl_beaker': "BEAKER (Tenths)", 'lbl_fast_forward': "FAST FORWARD",
    'lbl_chikki': "CHIKKI", 'lbl_chips': "CHIPS", 'lbl_scale': "PRICE/GRAM SCALE", 'lbl_podium': "BEST VALUE", 'lbl_calc': "Calculating...",

    's1_title': "1. The Stationery Store Purchase", 's1_obj': "To visually understand multiplication of a decimal by a whole number through repeated addition.",
    's1_hud1': "DRAG 1 pen into the shopping basket.", 's1_step1_task': "The scene shows a pen on a shelf with a price tag of ₹9.50. DRAG 1 pen into the shopping basket.", 's1_step1_obs': "A 9-rupee coin and a 50-paisa coin appear on the counter. Display shows ₹9.50.", 's1_step1_learn': "One item costs ₹9.50.",
    's1_hud2': "DRAG 4 more pens into the shopping basket.", 's1_step2_task': "Arshad needs to buy 5 pens. DRAG 4 more pens into the shopping basket, one by one.", 's1_step2_obs': "Coins stack up. Digital display shows ₹47.50.", 's1_step2_learn': "Repeated addition adds 9.50 each time.",
    's1_hud3': "CLICK the 'Group Coins' button.", 's1_step3_task': "CLICK the 'Group Coins' button at the top to organize the money.", 's1_step3_obs': "The 10 50-paisa coins merge into ₹5. The ₹9 coins group into ₹45.", 's1_step3_learn': "Ten 0.50s equal 5 wholes.",
    's1_hud4': "Review the final calculation.", 's1_step4_task': "The system highlights the final result.", 's1_step4_obs': "The summary shows 5 pens cost ₹47.50.", 's1_step4_learn': "9.5 added five times is the same as 9.5 × 5 = 47.50.",
    's1_final': "5 pens at ₹9.50 each costs ₹47.50. We saw this by adding 9.5 five times, which is the same as 9.5 × 5.",

    's2_title': "2. The Garden Area Planner", 's2_obj': "To visualize the multiplication of two decimals using an area model.",
    's2_hud1': "DRAG the sliders to Width: 5.7m and Length: 13.3m.", 's2_step1_task': "DRAG the 'Width' slider to 5.7m and the 'Length' slider to 13.3m.", 's2_step1_obs': "A grid appears over the garden plot, divided into four distinct sections.", 's2_step1_learn': "We split 13.3 into 13 + 0.3, and 5.7 into 5 + 0.7.",
    's2_hud2': "CLICK on the largest rectangle section.", 's2_step2_task': "CLICK on the largest rectangle section (the 13m x 5m area).", 's2_step2_obs': "The section glows. 13 x 5 = 65 is added to the calculator.", 's2_step2_learn': "The whole number part of the area is 65 sq m.",
    's2_hud3': "CLICK on the remaining three sections.", 's2_step3_task': "CLICK on the remaining three sections of the grid one by one.", 's2_step3_obs': "The areas 9.1, 1.5, and 0.21 are added. Total sum is 75.81.", 's2_step3_learn': "Adding the partial products gives the total area.",
    's2_hud4': "Review the connection to the algorithm.", 's2_step4_task': "Observe how the visual relates to the multiplication algorithm.", 's2_step4_obs': "Total area is 75.81 sq m.", 's2_step4_learn': "57 × 133 = 7581. With 2 decimal places total, it becomes 75.81.",
    's2_final': "The total area is 75.81 sq m. This is the same as 5.7 × 13.3. Notice that 57 × 133 = 7581. Place the decimal 2 places from right.",

    's3_title': "3. The Ribbon Cutting Craft", 's3_obj': "To understand division of a decimal by a whole number as equal sharing.",
    's3_hud1': "DRAG the 'Pieces' slider to 10.", 's3_step1_task': "A 3.9m long ribbon is shown. DRAG the 'Pieces' slider to 10.", 's3_step1_obs': "Faint laser lines appear, dividing the ribbon into 10 segments.", 's3_step1_learn': "We are setting up to divide 3.9 by 10.",
    's3_hud2': "CLICK the 'CUT' button.", 's3_step2_task': "CLICK the 'CUT' button to divide the ribbon.", 's3_step2_obs': "A laser cuts the ribbon into 10 smaller pieces.", 's3_step2_learn': "The continuous 3.9m length is now 10 equal parts.",
    's3_hud3': "DRAG the magnifying glass over a small piece.", 's3_step3_task': "DRAG the magnifying glass tool over any one of the small ribbon pieces.", 's3_step3_obs': "The view zooms in, showing the length is 0.39m.", 's3_step3_learn': "Each piece represents 3.9 ÷ 10.",
    's3_hud4': "Review the division rule.", 's3_step4_task': "Observe the summary of dividing by 10.", 's3_step4_obs': "3.9 ÷ 10 = 0.39.", 's3_step4_learn': "Dividing by 10 moves the decimal point one place left.",
    's3_final': "Dividing a 3.9m ribbon into 10 equal pieces gives pieces that are 0.39m long. Notice the decimal point moved one place left!",

    's4_title': "4. Fueling the Fleet", 's4_obj': "To solve a division problem with a decimal divisor by applying the concept of repeated measurement.",
    's4_hud1': "DRAG the 2.5-liter can to the large tank.", 's4_step1_task': "You have a large fuel tank containing 126 liters of petrol. Your mission is to find out how many scooters you can fill if each scooter's tank holds 2.5 liters. DRAG the 2.5-liter can to the large tank to fill it.", 's4_step1_obs': "The can fills with fuel. A counter appears showing \"Scooters Filled: 0\".", 's4_step1_learn': "We measure out 2.5L from the 126L total.",
    's4_hud2': "DRAG the full 2.5-liter can to the first scooter.", 's4_step2_task': "DRAG the full 2.5-liter can and DROP it onto the first scooter icon.", 's4_step2_obs': "The can empties into the scooter, which lights up in color. The fuel level in the large tank drops slightly. The counter updates to \"Scooters Filled: 1\". The can automatically returns to the large tank to be refilled.", 's4_step2_learn': "One scooter takes 2.5L.",
    's4_hud3': "CLICK \"FAST FORWARD\" to automatically fill scooters.", 's4_step3_task': "A \"FAST FORWARD\" button appears. CLICK it to automatically fill the rest of the scooters.", 's4_step3_obs': "The simulation rapidly repeats the fill-and-pour process. The counter quickly increases. The animation stops when the main tank has less than 2.5 liters left. The counter will show \"Scooters Filled: 50\". A small amount of fuel is visibly left in the main tank.", 's4_step3_learn': "50 scooters use 125L (50 * 2.5). 1L remains.",
    's4_hud4': "POUR remaining fuel into the beaker. Enter final answer.", 's4_step4_task': "A measurement beaker appears next to the remaining fuel. The beaker is marked in tenths of a 2.5L can. POUR the remaining fuel into the beaker. Enter the total number of scooters filled (including the partial one) into the final answer box.", 's4_step4_obs': "The remaining fuel fills the beaker up to the \"0.4\" mark. The user must input \"50.4\" into the answer box.", 's4_step4_learn': "The remaining 1L is 0.4 of a 2.5L can. 126 ÷ 2.5 = 50.4.",
    's4_final': "Final Answer: 50.4 Scooters. The remaining 1L of fuel fills 0.4 of a 2.5L can.",

    's5_title': "5. Supermarket Showdown", 's5_obj': "To use decimal division and comparison to determine the best value for money.",
    's5_hud1': "DRAG the Chikki packet onto the Scale.", 's5_step1_task': "Find which is cheaper per gram. DRAG the chikki packet onto the Scale.", 's5_step1_obs': "The scale calculates ₹70.5 ÷ 210g = ₹0.335 per gram.", 's5_step1_learn': "Division finds the unit price.",
    's5_hud2': "DRAG the Chips packet onto the Scale.", 's5_step2_task': "Now, DRAG the potato chips packet onto the Scale.", 's5_step2_obs': "The scale calculates ₹33.25 ÷ 110g = ₹0.302 per gram.", 's5_step2_learn': "We now have both unit prices to compare.",
    's5_hud3': "DRAG the cheaper item to the Podium.", 's5_step3_task': "Compare the unit prices. DRAG the cheaper item onto the winner's spot on the podium.", 's5_step3_obs': "Chips (0.302) is less than Chikki (0.335).", 's5_step3_learn': "Comparing decimals place by place.",
    's5_final': "Correct! The chips are a better value at ₹0.302 per gram compared to ₹0.335."
  },
  'hi': {
    'shutterTitle': "डेसीमलवर्स: एक अन्वेषण", 'appTitle': "डेसीमलवर्स", 'appSubtitle': "कक्षा 7 • गुण और वास्तविक दुनिया अनुप्रयोग", 'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण",
    'lbl_objective': "उद्देश्य / अवलोकन:", 'obsLbl': "अवलोकन:", 'learnLbl': "सीख:", 'summaryTitle': "लक्ष्य प्राप्त हुआ!", 'checkAnswer': "उत्तर जांचें",
    'hudNext': "अगला कदम", 'err_input': "गलत मान। पुनः प्रयास करें।", 'err_action': "सही कार्रवाई करें।", 'err_area': "पहले सभी क्षेत्रों का चयन करें।",
    'finalSuccessTitle': "गतिविधि पूरी हुई!", 'finalSuccessDesc': "आपने दशमलव संचालन के गुणों का सफलतापूर्वक विश्लेषण किया है।",
    'reset': "रीसेट", 'close': "बंद करें", 'guideNextScenario': "यह परिदृश्य पूरा हो गया है! कृपया अगला परिदृश्य चुनने और आजमाने के लिए साइडबार मेनू खोलें।",
    
    'lbl_rs': "₹", 'lbl_total': "कुल: ₹", 'lbl_basket': "टोकरी", 'lbl_counter': "काउंटर", 'lbl_cash_register': "कैश रजिस्टर",
    'lbl_group_coins_btn': "सिक्के मिलाएं 👆", 'lbl_price_tag': "₹9.50", 'lbl_45': "₹45", 'lbl_2_50': "₹2.50", 'lbl_50p': "50p",
    's1_b1': "मिशन अपडेट:", 's1_b2': "\"अरशद को 5 पेन खरीदने हैं।\"",
    's1_s1': "5 पेन की कीमत ₹47.50 है।", 's1_s2': "हमने 9.5 को 5 बार जोड़कर यह देखा,", 's1_s3': "जो 9.5 × 5 के समान है।",

    'lbl_width': "चौड़ाई (m)", 'lbl_length': "लंबाई (m)", 'lbl_area_calc': "कुल क्षेत्र कैलकुलेटर", 'lbl_sqm': "वर्ग मीटर",
    'lbl_ribbon': "रिबन (3.9m)", 'lbl_pieces': "टुकड़े: ", 'lbl_ruler': "स्केल (m)", 'lbl_cut_ribbon': "काटें",
    'lbl_tank': "मुख्य टैंक", 'lbl_fuel_can': "2.5L कैन", 'lbl_scooters': "स्कूटर", 'lbl_filled': "भरे हुए: ", 'lbl_beaker': "बीकर", 'lbl_fast_forward': "फास्ट फॉरवर्ड",
    'lbl_chikki': "चिक्की", 'lbl_chips': "चिप्स", 'lbl_scale': "मूल्य/ग्राम स्केल", 'lbl_podium': "सर्वोत्तम मूल्य", 'lbl_calc': "गणना हो रही है...",

    's1_title': "1. स्टेशनरी की दुकान की खरीदारी", 's1_obj': "बार-बार जोड़ने के माध्यम से दशमलव के गुणन को समझना।",
    's1_hud1': "1 पेन को शॉपिंग बास्केट में खींचें।", 's1_step1_task': "दृश्य में एक शेल्फ पर ₹9.50 के मूल्य टैग के साथ एक पेन दिखाया गया है। 1 पेन को शॉपिंग बास्केट में खींचें।", 's1_step1_obs': "काउंटर पर एक 9 रुपये का सिक्का और एक 50 पैसे का सिक्का दिखाई देता है। डिस्प्ले ₹9.50 दिखाता है।", 's1_step1_learn': "एक वस्तु की कीमत ₹9.50 है।",
    's1_hud2': "4 और पेन शॉपिंग बास्केट में खींचें।", 's1_step2_task': "अरशद को 5 पेन खरीदने हैं। 4 और पेन को शॉपिंग बास्केट में एक-एक करके खींचें।", 's1_step2_obs': "सिक्के ढेर हो जाते हैं। डिजिटल डिस्प्ले ₹47.50 दिखाता है।", 's1_step2_learn': "बार-बार जोड़ने पर हर बार 9.50 जुड़ता है।",
    's1_hud3': "'सिक्के मिलाएं' बटन पर क्लिक करें।", 's1_step3_task': "पैसे को व्यवस्थित करने के लिए शीर्ष पर 'सिक्के मिलाएं' बटन पर क्लिक करें।", 's1_step3_obs': "10 50-पैसे के सिक्के ₹5 में मिल जाते हैं। ₹9 के सिक्के ₹45 में मिल जाते हैं।", 's1_step3_learn': "दस 0.50 मिलकर 5 पूर्ण बनते हैं।",
    's1_hud4': "अंतिम गणना की समीक्षा करें।", 's1_step4_task': "सिस्टम अंतिम परिणाम को हाइलाइट करता है।", 's1_step4_obs': "सारांश दिखाता है कि 5 पेन की कीमत ₹47.50 है।", 's1_step4_learn': "9.5 को पांच बार जोड़ना 9.5 × 5 = 47.50 के समान है।",
    's1_final': "₹9.50 के हिसाब से 5 पेन की कीमत ₹47.50 है। हमने इसे 9.5 को पांच बार जोड़कर देखा, जो कि 9.5 × 5 के समान है।",

    's2_title': "2. गार्डन एरिया प्लानर", 's2_obj': "क्षेत्र मॉडल का उपयोग करके दो दशमलवों के गुणन की कल्पना करना।",
    's2_hud1': "स्लाइडर्स को चौड़ाई: 5.7m और लंबाई: 13.3m पर खींचें।", 's2_step1_task': "'चौड़ाई' स्लाइडर को 5.7m और 'लंबाई' स्लाइडर को 13.3m पर खींचें।", 's2_step1_obs': "गार्डन प्लॉट के ऊपर एक ग्रिड दिखाई देता है, जिसे चार अलग-अलग वर्गों में विभाजित किया गया है।", 's2_step1_learn': "हम 13.3 को 13 + 0.3 और 5.7 को 5 + 0.7 में विभाजित करते हैं।",
    's2_hud2': "सबसे बड़े आयत भाग पर क्लिक करें।", 's2_step2_task': "सबसे बड़े आयत अनुभाग (13m x 5m क्षेत्र) पर क्लिक करें।", 's2_step2_obs': "अनुभाग चमकता है। 13 x 5 = 65 कैलकुलेटर में जोड़ा जाता है।", 's2_step2_learn': "क्षेत्र का पूर्ण संख्या भाग 65 वर्ग मीटर है।",
    's2_hud3': "शेष तीन वर्गों पर क्लिक करें।", 's2_step3_task': "ग्रिड के शेष तीन वर्गों पर एक-एक करके क्लिक करें।", 's2_step3_obs': "क्षेत्र 9.1, 1.5, और 0.21 जोड़े गए हैं। कुल योग 75.81 है।", 's2_step3_learn': "आंशिक उत्पादों को जोड़ने पर कुल क्षेत्रफल मिलता है।",
    's2_hud4': "एल्गोरिथ्म से संबंध की समीक्षा करें।", 's2_step4_task': "देखें कि दृश्य गुणन एल्गोरिथ्म से कैसे संबंधित है।", 's2_step4_obs': "कुल क्षेत्रफल 75.81 वर्ग मीटर है।", 's2_step4_learn': "57 × 133 = 7581। कुल 2 दशमलव स्थानों के साथ, यह 75.81 हो जाता है।",
    's2_final': "कुल क्षेत्रफल 75.81 वर्ग मीटर है। यह 5.7 × 13.3 के समान है। ध्यान दें कि 57 × 133 = 7581। दशमलव को दाईं ओर से 2 स्थानों पर रखें।",

    's3_title': "3. रिबन काटना", 's3_obj': "समान साझेदारी के रूप में पूर्ण संख्या से दशमलव के विभाजन को समझना।",
    's3_hud1': "'टुकड़े' स्लाइडर को 10 पर खींचें।", 's3_step1_task': "3.9m लंबा रिबन दिखाया गया है। 'टुकड़े' स्लाइडर को 10 पर खींचें।", 's3_step1_obs': "हल्की लेज़र लाइनें दिखाई देती हैं, जो रिबन को 10 खंडों में विभाजित करती हैं।", 's3_step1_learn': "हम 3.9 को 10 से विभाजित करने की तैयारी कर रहे हैं।",
    's3_hud2': "'काटें' बटन पर क्लिक करें।", 's3_step2_task': "रिबन को विभाजित करने के लिए 'काटें' बटन पर क्लिक करें।", 's3_step2_obs': "एक लेज़र रिबन को 10 छोटे टुकड़ों में काटता है।", 's3_step2_learn': "लगातार 3.9m लंबाई अब 10 समान भाग है।",
    's3_hud3': "एक छोटे टुकड़े पर मैग्निफाइंग ग्लास खींचें।", 's3_step3_task': "मैग्निफाइंग ग्लास टूल को रिबन के किसी भी छोटे टुकड़े पर खींचें।", 's3_step3_obs': "दृश्य ज़ूम इन करता है, जो 0.39m की लंबाई दिखाता है।", 's3_step3_learn': "प्रत्येक टुकड़ा 3.9 ÷ 10 का प्रतिनिधित्व करता है।",
    's3_hud4': "विभाजन नियम की समीक्षा करें।", 's3_step4_task': "10 से विभाजित करने का सारांश देखें।", 's3_step4_obs': "3.9 ÷ 10 = 0.39.", 's3_step4_learn': "10 से भाग देने पर दशमलव बिंदु एक स्थान बाईं ओर खिसक जाता है।",
    's3_final': "3.9m रिबन को 10 समान टुकड़ों में विभाजित करने से 0.39m लंबे टुकड़े मिलते हैं। ध्यान दें कि दशमलव बिंदु एक स्थान बाईं ओर चला गया है!",

    's4_title': "4. फ्लीट को ईंधन देना", 's4_obj': "बार-बार मापन की अवधारणा को लागू करके दशमलव भाजक के साथ विभाजन समस्या को हल करना।",
    's4_hud1': "2.5-लीटर कैन को बड़े टैंक पर खींचें।", 's4_step1_task': "आपके पास 126 लीटर पेट्रोल वाला एक बड़ा ईंधन टैंक है। आपका मिशन यह पता लगाना है कि यदि प्रत्येक स्कूटर के टैंक में 2.5 लीटर है तो आप कितने स्कूटर भर सकते हैं। 2.5-लीटर कैन को भरने के लिए बड़े टैंक पर खींचें।", 's4_step1_obs': "कैन ईंधन से भर जाता है। एक काउंटर दिखाई देता है जिसमें \"भरे हुए स्कूटर: 0\" दिखाई देता है।", 's4_step1_learn': "हम 126L कुल में से 2.5L मापते हैं।",
    's4_hud2': "भरे हुए 2.5-लीटर कैन को पहले स्कूटर पर खींचें।", 's4_step2_task': "भरे हुए 2.5-लीटर कैन को खींचें और पहले स्कूटर आइकन पर छोड़ें।", 's4_step2_obs': "कैन स्कूटर में खाली हो जाता है, जो रंग में रोशनी करता है। बड़े टैंक में ईंधन का स्तर थोड़ा कम हो जाता है। काउंटर \"भरे हुए स्कूटर: 1\" में अपडेट होता है। कैन बड़े टैंक में वापस आ जाता है।", 's4_step2_learn': "एक स्कूटर 2.5L लेता है।",
    's4_hud3': "स्कूटर स्वचालित रूप से भरने के लिए \"FAST FORWARD\" पर क्लिक करें।", 's4_step3_task': "एक \"FAST FORWARD\" बटन दिखाई देता है। बाकी स्कूटरों को स्वचालित रूप से भरने के लिए इसे क्लिक करें।", 's4_step3_obs': "सिमुलेशन तेजी से भरता है। काउंटर 50 तक पहुँचता है। एनीमेशन तब रुक जाता है जब मुख्य टैंक में 2.5 लीटर से कम बचता है। टैंक में 1L बचा है।", 's4_step3_learn': "50 स्कूटर 125L का उपयोग करते हैं (50 * 2.5)। 1L रहता है।",
    's4_hud4': "बचे हुए ईंधन को बीकर में डालें। अंतिम उत्तर दर्ज करें।", 's4_step4_task': "बचे हुए ईंधन के बगल में एक माप बीकर दिखाई देता है। बीकर को 2.5L कैन के दसवें हिस्से में चिह्नित किया गया है। बचे हुए ईंधन को बीकर में डालें। बॉक्स में भरे हुए स्कूटरों की कुल संख्या दर्ज करें।", 's4_step4_obs': "बचा हुआ ईंधन बीकर को \"0.4\" निशान तक भरता है। उपयोगकर्ता को बॉक्स में \"50.4\" इनपुट करना होगा।", 's4_step4_learn': "शेष 1L 2.5L कैन का 0.4 है। 126 ÷ 2.5 = 50.4।",
    's4_final': "अंतिम उत्तर: 50.4 स्कूटर। शेष 1L ईंधन 2.5L कैन का 0.4 भरता है।",

    's5_title': "5. सुपरमार्केट शोडाउन", 's5_obj': "पैसे के लिए सर्वोत्तम मूल्य निर्धारित करने के लिए दशमलव विभाजन का उपयोग करना।",
    's5_hud1': "चिक्की पैकेट को स्केल पर खींचें।", 's5_step1_task': "पता लगाएं कि प्रति ग्राम कौन सा सस्ता है। चिक्की पैकेट को स्केल पर खींचें।", 's5_step1_obs': "स्केल ₹70.5 ÷ 210g = ₹0.335 प्रति ग्राम की गणना करता है।", 's5_step1_learn': "विभाजन इकाई मूल्य ज्ञात करता है।",
    's5_hud2': "चिप्स पैकेट को स्केल पर खींचें।", 's5_step2_task': "अब, आलू चिप्स पैकेट को स्केल पर खींचें।", 's5_step2_obs': "स्केल ₹33.25 ÷ 110g = ₹0.302 प्रति ग्राम की गणना करता है।", 's5_step2_learn': "अब हमारे पास तुलना करने के लिए दोनों इकाई मूल्य हैं।",
    's5_hud3': "सस्ते आइटम को पोडियम पर खींचें।", 's5_step3_task': "इकाई कीमतों की तुलना करें। सस्ते आइटम को विजेता के पोडियम पर खींचें।", 's5_step3_obs': "चिप्स (0.302) चिक्की (0.335) से कम है।", 's5_step3_learn': "दशमलव की स्थान-दर-स्थान तुलना करना।",
    's5_final': "सही! चिप्स ₹0.335 की तुलना में ₹0.302 प्रति ग्राम पर बेहतर मूल्य है।"
  },
  };