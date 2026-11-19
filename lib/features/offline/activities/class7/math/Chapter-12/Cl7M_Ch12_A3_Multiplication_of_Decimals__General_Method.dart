// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultiplicationofDecimalsGeneralMethodApp());
}

class MultiplicationofDecimalsGeneralMethodApp extends StatelessWidget {
  const MultiplicationofDecimalsGeneralMethodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Multiplication of Decimals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const MultiplicationofDecimalsGeneralMethod(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class FactorItem {
  String valStr;
  String whole;
  String frac;
  double x, y, startX, startY, targetX, targetY;
  bool inFunnel;
  int tokensMade;
  Color colorWhole;
  Color colorFrac;

  FactorItem({
    required this.valStr,
    required this.whole,
    required this.frac,
    required this.x,
    required this.y,
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.colorWhole,
    required this.colorFrac,
  })  : inFunnel = false,
        tokensMade = 0;
}

class TokenItem {
  double x, y, targetY;
  bool counted;
  TokenItem({required this.x, required this.y, required this.targetY, this.counted = false});
}

// ==========================================
// MAIN WIDGET
// ==========================================
class MultiplicationofDecimalsGeneralMethod extends StatefulWidget {
  const MultiplicationofDecimalsGeneralMethod({super.key});

  @override
  State<MultiplicationofDecimalsGeneralMethod> createState() => _GameState();
}

class _GameState extends State<MultiplicationofDecimalsGeneralMethod> with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  String _theme = 'dark';

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
  Offset _basePan = Offset.zero;

  // Interaction State
  double _mouseX = 0;
  double _mouseY = 0;
  FactorItem? _activeDragItem;
  bool _isDraggingCanvas = false;
  bool _isDraggingDecimal = false;
  Offset? _decimalDragPt;
  int _hoverInsertIndex = 0;
  Offset? _obsPos;

  // Simulation State
  List<FactorItem> _factors = [];
  List<TokenItem> _tokens = [];
  
  String _phase = 'idle'; // idle, auto_slice, auto_multiply, auto_insert, wait_user_insert
  int _productVal = 0;
  String _productText = "";
  int _decimalPos = 0;
  int _targetDecimalPos = 0;
  int _tokensInTray = 0;
  double _animProgress = 0;
  double _beltOffset = 0;
  int? _burstTime;
  
  // HUD
  String _transientHudMessage = '';
  Timer? _hudTimer;

  // Audio players
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _alertPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';
  static const String _whirUrl = 'audio/class7/mixkit_2570.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';

  late AnimationController _ticker;

  // Layout Constants
  double MAT_W = 750;
  final double MAT_H = 500;
  double MAT_X = -250;
  final double MAT_Y = -150;
  
  // Machine Hitboxes
  Rect _sliceBtnHit = Rect.zero;
  Rect _multBtnHit = Rect.zero;
  Rect _insBtnHit = Rect.zero;

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

    _ticker = AnimationController(vsync: this, duration: const Duration(milliseconds: 30))..addListener(_tick)..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _hudTimer?.cancel();
    _sidebarScrollController.dispose();
    _popupScrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _alertPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      if (type == 'enter') {
        await _fxPlayer.play(AssetSource(_shutterUrl), volume: 0.5);
      } else if (type == 'pop' || type == 'tick' || type == 'snap') {
        await _clickPlayer.play(AssetSource(_clickUrl), volume: 0.5);
      } else if (type == 'success') {
        await _successPlayer.play(AssetSource(_successUrl), volume: 0.5);
      } else if (type == 'error') {
        await _errorPlayer.play(AssetSource(_errorUrl), volume: 0.5);
      } else if (type == 'alert') {
        await _alertPlayer.play(AssetSource(_alertUrl), volume: 0.5);
      } else if (type == 'whir') {
        await _fxPlayer.play(AssetSource(_whirUrl), volume: 0.6);
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
    setState(() => _showCurtain = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _lang = 'en';
          _theme = 'dark';
          _completedScenarios.clear();
          _loadScenario(1);
        });
      }
    });
  }

  void _showTempHUD(String msg) {
    _playSound('alert');
    setState(() => _transientHudMessage = msg);
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _transientHudMessage = '');
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 1;
      _activeDragItem = null;
      _isDraggingDecimal = false;
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
      _obsPos = null;
      _showSuccessPopup = false;
      _transientHudMessage = '';
      _burstTime = null;

      _phase = 'idle';
      _factors.clear();
      _tokens.clear();
      _tokensInTray = 0;
      _animProgress = 0;
      _hoverInsertIndex = 0;
      _decimalPos = 0;
      _beltOffset = 0;

      _sliceBtnHit = Rect.fromCircle(center: Offset(MAT_X + 80, MAT_Y + 130), radius: 50);
      _multBtnHit = Rect.fromCircle(center: Offset(MAT_X + 660, MAT_Y + 130), radius: 45);
      _insBtnHit = Rect.fromCircle(center: Offset(MAT_X + 660, MAT_Y + 230), radius: 40);

      FactorItem createFactor(String v, double sX, double sY, int funnelIdx, Color cWhole, Color cFrac) {
        List<String> parts = v.split('.');
        return FactorItem(
          valStr: v,
          whole: parts[0],
          frac: parts.length > 1 ? parts[1] : "",
          x: sX, y: sY, startX: sX, startY: sY,
          targetX: MAT_X + (funnelIdx == 1 ? 250 : 450), targetY: MAT_Y + 10,
          colorWhole: cWhole, colorFrac: cFrac,
        );
      }

      String f1, f2; int prod;
      if (id == 1) { 
          f1 = "9.5"; f2 = "5"; prod = 475;
          _factors.add(createFactor(f1, MAT_X - 250, MAT_Y + 90, 1, const Color(0xFF38BDF8), const Color(0xFFF472B6))); 
          _factors.add(createFactor(f2, MAT_X - 100, MAT_Y + 90, 2, const Color(0xFFF87171), const Color(0xFFF87171))); 
      } else if (id == 2) { 
          f1 = "12.5"; f2 = "7.5"; prod = 9375;
          _factors.add(createFactor(f1, MAT_X - 250, MAT_Y + 90, 1, const Color(0xFF34D399), const Color(0xFFFBBF24))); 
          _factors.add(createFactor(f2, MAT_X - 100, MAT_Y + 90, 2, const Color(0xFF818CF8), const Color(0xFFF472B6))); 
      } else if (id == 3) { 
          f1 = "5.96"; f2 = "24.8"; prod = 147808;
          _factors.add(createFactor(f1, MAT_X - 250, MAT_Y + 90, 1, const Color(0xFFA78BFA), const Color(0xFF22D3EE))); 
          _factors.add(createFactor(f2, MAT_X - 100, MAT_Y + 90, 2, const Color(0xFFFB923C), const Color(0xFF34D399))); 
      } else if (id == 4) { 
          f1 = "1.64"; f2 = "6"; prod = 984;
          _factors.add(createFactor(f1, MAT_X - 250, MAT_Y + 90, 1, const Color(0xFF38BDF8), const Color(0xFFF472B6)));
          _factors.add(createFactor(f2, MAT_X - 100, MAT_Y + 90, 2, const Color(0xFFF87171), const Color(0xFFF87171)));
      } else { 
          f1 = "0.432"; f2 = "0.23"; prod = 9936;
          _factors.add(createFactor(f1, MAT_X - 250, MAT_Y + 90, 1, const Color(0xFF34D399), const Color(0xFFFBBF24)));
          _factors.add(createFactor(f2, MAT_X - 100, MAT_Y + 90, 2, const Color(0xFF818CF8), const Color(0xFFF472B6)));
      }

      int totDec = 0;
      for (var f in _factors) { totDec += f.frac.length; }
      
      _productVal = prod;
      _productText = prod.toString();
      _targetDecimalPos = totDec;

    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    setState(() {
      if (_phase == 'auto_slice') {
        _animProgress += 0.015;
        if (_animProgress > 0.4 && _tokens.isEmpty) {
          for (var f in _factors) {
            if (f.frac.isNotEmpty && f.tokensMade == 0) {
              f.tokensMade = f.frac.length;
              for (int t = 0; t < f.frac.length; t++) {
                _tokens.add(TokenItem(x: f.x + 40 + t * 15, y: f.y, targetY: MAT_Y + 335));
              }
            }
          }
          if (_tokens.isNotEmpty) _playSound('tick');
        }

        bool allTokensFallen = true;
        if (_animProgress > 0.4) {
          for (var tok in _tokens) {
            if (tok.y < tok.targetY) {
              tok.y += 12;
              tok.x += (MAT_X + 530 + _tokensInTray * 30 - tok.x) * 0.05;
              allTokensFallen = false;
            } else if (!tok.counted) {
              tok.counted = true;
              _tokensInTray++;
              _playSound('snap');
            }
          }
        } else {
          allTokensFallen = false;
        }

        if (_animProgress >= 1 && allTokensFallen) {
          _tokens.clear();
          _phase = 'idle';
          _advanceStep();
        }
      } 
      else if (_phase == 'auto_multiply') {
        _animProgress += 0.012;
        if (_animProgress > 0.4) {
          for (var f in _factors) { f.y += 15; }
        }
        if (_animProgress >= 1) {
          _phase = 'idle';
          _advanceStep();
        }
      } 
      else if (_phase == 'auto_insert') {
        _animProgress += 0.015;
        double stepSize = 1 / (_targetDecimalPos > 0 ? _targetDecimalPos : 1);
        int currentStep = (_animProgress / stepSize).floor();
        
        if (currentStep > _decimalPos && _decimalPos < _targetDecimalPos) {
          _decimalPos++;
          _tokensInTray = max(0, _tokensInTray - 1);
          _playSound('tick');
        }
        
        if (_animProgress >= 1) {
          _decimalPos = _targetDecimalPos;
          _phase = 'idle';
          _checkScenarioSuccess();
        }
      } 
      else if (_phase == 'wait_user_insert' && _isDraggingDecimal) {
        if (_decimalDragPt != null) {
          double charW = 30;
          double startX = MAT_X + 560 - (_productText.length * charW) / 2;
          double distFromRight = (startX + _productText.length * charW) - _decimalDragPt!.dx;
          int idx = (distFromRight / charW).round();
          _hoverInsertIndex = max(0, idx);
        }
      } 
      else if (_phase == 'idle' && _activeDragItem == null && !_isDraggingDecimal) {
        _beltOffset -= 3; 
        if (_step == 1) {
          for (var f in _factors) {
            if (!f.inFunnel && (f.x != f.startX || f.y != f.startY)) {
              f.x += (f.startX - f.x) * 0.2;
              f.y += (f.startY - f.y) * 0.2;
            }
          }
        }
      }
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
      if (_step == 4 && (_scenario == 4 || _scenario == 5)) {
        _phase = 'wait_user_insert';
      }
    });
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    setState(() {
      _step = 5;
      _completedScenarios.add(_scenario);
    });
    _playSound('success');
    _scrollToActiveStep();

    if (_completedScenarios.length == 5) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _showSuccessPopup = true);
      });
    }
  }

  int _getScenarioStepsCount() {
    return 4; // All scenarios have 4 steps + final
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

  bool _hitTestRect(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  bool _hitTestCircle(Offset center, double r, Offset pt) {
    return (pt - center).distance <= r;
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    Offset pt = _screenToWorld(details.localPosition, size);
    if (_completedScenarios.contains(_scenario)) return;

    if (_step == 2 && _phase == 'idle' && _hitTestCircle(_sliceBtnHit.center, _sliceBtnHit.width/2, pt)) {
      _playSound('whir');
      setState(() { _phase = 'auto_slice'; _animProgress = 0; });
    }
    else if (_step == 3 && _phase == 'idle' && _hitTestCircle(_multBtnHit.center, _multBtnHit.width/2, pt)) {
      _playSound('whir');
      setState(() { _phase = 'auto_multiply'; _animProgress = 0; });
    }
    else if (_scenario <= 3 && _step == 4 && _phase == 'idle' && _hitTestCircle(_insBtnHit.center, _insBtnHit.width/2, pt)) {
      _playSound('tick');
      setState(() { _phase = 'auto_insert'; _animProgress = 0; });
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (_completedScenarios.contains(_scenario)) return;

    bool touchedItem = false;

    // Fast Check for buttons
    if (_step == 2 && _phase == 'idle' && _hitTestCircle(_sliceBtnHit.center, _sliceBtnHit.width/2, pt)) {
      _playSound('whir');
      setState(() { _phase = 'auto_slice'; _animProgress = 0; });
      return;
    }
    else if (_step == 3 && _phase == 'idle' && _hitTestCircle(_multBtnHit.center, _multBtnHit.width/2, pt)) {
      _playSound('whir');
      setState(() { _phase = 'auto_multiply'; _animProgress = 0; });
      return;
    }
    else if (_scenario <= 3 && _step == 4 && _phase == 'idle' && _hitTestCircle(_insBtnHit.center, _insBtnHit.width/2, pt)) {
      _playSound('tick');
      setState(() { _phase = 'auto_insert'; _animProgress = 0; });
      return;
    }

    // Drag Factors
    if (_step == 1) {
      for (int i = _factors.length - 1; i >= 0; i--) {
        var f = _factors[i];
        if (!f.inFunnel && _hitTestRect(f.x - 60, f.y - 30, 120, 60, pt)) {
          setState(() { _activeDragItem = f; });
          _playSound('tick');
          touchedItem = true;
          break;
        }
      }
    }

    // Drag Decimal Point
    if (!touchedItem && (_scenario == 4 || _scenario == 5) && _step == 4 && _phase == 'wait_user_insert') {
      if (_hitTestRect(MAT_X + 430, MAT_Y + 230, 260, 110, pt)) {
        setState(() {
          _isDraggingDecimal = true;
          _decimalDragPt = pt;
        });
        _playSound('tick');
        touchedItem = true;
      }
    }

    if (!touchedItem) {
      _isDraggingCanvas = true;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      _mouseX = pt.dx;
      _mouseY = pt.dy;

      if (_activeDragItem != null) {
        _activeDragItem!.x = pt.dx;
        _activeDragItem!.y = pt.dy;
      } else if (_isDraggingDecimal) {
        _decimalDragPt = pt;
      } else if (_isDraggingCanvas) {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.3, 2.0);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    _isDraggingCanvas = false;

    if (_activeDragItem != null) {
      setState(() {
        var item = _activeDragItem!;
        Offset f1 = Offset(MAT_X + 250, MAT_Y - 10);
        Offset f2 = Offset(MAT_X + 450, MAT_Y - 10);
        bool dropped = false;

        if (_hitTestCircle(f1, 80, Offset(item.x, item.y))) {
          item.x = item.targetX; item.y = item.targetY; item.inFunnel = true; dropped = true;
        } else if (_hitTestCircle(f2, 80, Offset(item.x, item.y))) {
          item.x = item.targetX; item.y = item.targetY; item.inFunnel = true; dropped = true;
        }

        if (dropped) {
          _playSound('snap');
          if (_factors.every((f) => f.inFunnel)) _advanceStep();
        } else {
          _playSound('pop');
        }
        _activeDragItem = null;
      });
    }

    if (_isDraggingDecimal) {
      setState(() {
        if (_hoverInsertIndex == _targetDecimalPos) {
          _playSound('success');
          _decimalPos = _hoverInsertIndex;
          _phase = 'idle';
          _checkScenarioSuccess();
        } else {
          _playSound('error');
          _showTempHUD(t('err_wrong_dec'));
          _hoverInsertIndex = 0;
          _decimalDragPt = null;
        }
        _isDraggingDecimal = false;
      });
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
    return RichText(text: TextSpan(style: const TextStyle(fontSize: 13, fontFamily: 'Plus Jakarta Sans', height: 1.4), children: spans));
  }

  Widget _buildSidebar(double width) {
    bool isLight = _theme == 'light';
    Color bg = isLight ? const Color(0xFFF8FAFC).withOpacity(0.95) : const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = isLight ? const Color(0xFF0F172A) : Colors.white;
    Color textSecondary = isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    Color border = isLight ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1);

    int totalSteps = _getScenarioStepsCount();

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(5, 0))],
      ),
      child: SingleChildScrollView(
        controller: _sidebarScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 20, 16, 15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('appTitle'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(t('appSubtitle'), style: TextStyle(color: Colors.indigoAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: border, height: 1),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language & Reset
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleLanguage,
                          icon: const Icon(Icons.language, size: 16),
                          label: Text(_lang.toUpperCase()),
                          style: ElevatedButton.styleFrom(backgroundColor: isLight ? Colors.white : const Color(0xFF0F172A), foregroundColor: textPrimary, side: BorderSide(color: border), padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleReset,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text(t('resetBtn')),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent, side: BorderSide(color: Colors.redAccent.withOpacity(0.3)), padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Scenario Dropdown
                  Text(t('selectScenario').toUpperCase(), style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: isLight ? Colors.white : const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _scenario,
                        isExpanded: true,
                        dropdownColor: isLight ? Colors.white : const Color(0xFF1E293B),
                        style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        items: [1, 2, 3, 4, 5].map((id) => DropdownMenuItem(value: id, child: Text(t('s${id}_title')))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            _playSound('pop');
                            _loadScenario(val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Objective
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: (isLight ? Colors.white : const Color(0xFF0F172A)).withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Text(t('s${_scenario}_obj'), style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Steps
                  ...List.generate(totalSteps, (i) {
                    int actualStep = i + 1;
                    bool isPast = actualStep < _step;
                    bool isCurrent = actualStep == _step;
                    
                    if (actualStep <= _step && _step == 5) isPast = true;

                    Color stepBg = isCurrent ? Colors.indigo.withOpacity(0.1) : (isPast ? Colors.green.withOpacity(0.05) : (textPrimary.withOpacity(0.02)));
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
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(color: isCurrent ? Colors.indigoAccent : Colors.grey, shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: Text('$actualStep', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${t('stepLabel')} $actualStep", style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                _buildRichText("<b>${t('actTitle')}</b> ${t('s${_scenario}_step${actualStep}_task')}", isCurrent ? Colors.indigoAccent : textPrimary),
                                if (isPast) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildRichText("<b>${t('obsLbl')}</b> ${t('s${_scenario}_step${actualStep}_obs')}", Colors.green),
                                        const SizedBox(height: 4),
                                        Container(height: 1, width: double.infinity, color: Colors.green.withOpacity(0.2)),
                                        const SizedBox(height: 4),
                                        _buildRichText("<b>${t('learnLbl')}</b> ${t('s${_scenario}_step${actualStep}_learn')}", Colors.green),
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
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
              child: const Text('© ZEROSCIENCELAB | Fall in Love with Math and Science', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;
    if (sidebarWidth < 300) sidebarWidth = 300;
    bool isLight = _theme == 'light';
    
    String hudTextRaw = _transientHudMessage.isNotEmpty ? _transientHudMessage : t('s${_scenario}_hud$_step');
    bool showHud = hudTextRaw.isNotEmpty && hudTextRaw != 's${_scenario}_hud$_step' && !_completedScenarios.contains(_scenario);

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // CANVAS
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      onTapDown: (d) => _handleTapDown(d, constraints.biggest),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: DecimalMultiplicationPainter(
                          scenario: _scenario, step: _step, phase: _phase,
                          zoom: _zoom, panX: _panX, panY: _panY, isLight: isLight,
                          factors: _factors, tokens: _tokens,
                          productVal: _productVal, productText: _productText,
                          decimalPos: _decimalPos, targetDecimalPos: _targetDecimalPos,
                          tokensInTray: _tokensInTray, animProgress: _animProgress,
                          beltOffset: _beltOffset,
                          activeDragItem: _activeDragItem, isDraggingDecimal: _isDraggingDecimal,
                          decimalDragPt: _decimalDragPt, hoverInsertIndex: _hoverInsertIndex,
                          sliceBtnHit: _sliceBtnHit, multBtnHit: _multBtnHit, insBtnHit: _insBtnHit,
                          matW: MAT_W, matH: MAT_H, matX: MAT_X, matY: MAT_Y,
                          t: t,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // HUD OVERLAY (Mini Messages)
            if (showHud)
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth + 40 : 40,
                right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _transientHudMessage.isNotEmpty ? Colors.redAccent.withOpacity(0.95) : const Color(0xFF0F172A).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(30),
                          border: Border(top: BorderSide(color: _transientHudMessage.isNotEmpty ? Colors.red : Colors.indigoAccent, width: 4)),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: (_transientHudMessage.isNotEmpty ? Colors.white : Colors.indigoAccent).withOpacity(0.2), shape: BoxShape.circle),
                              child: Icon(_transientHudMessage.isNotEmpty ? Icons.error_outline : Icons.info_outline, color: _transientHudMessage.isNotEmpty ? Colors.white : Colors.indigoAccent),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                hudTextRaw,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

            // SCENARIO COMPLETE BANNER (Draggable)
            if (_completedScenarios.contains(_scenario) && _completedScenarios.length < 5)
              Positioned(
                left: _obsPos?.dx ?? (_isSidebarOpen ? sidebarWidth + (screenWidth - sidebarWidth) / 2 - 200 : screenWidth / 2 - 200),
                top: _obsPos?.dy ?? (MediaQuery.of(context).size.height - 180),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      double currentX = _obsPos?.dx ?? (_isSidebarOpen ? sidebarWidth + (screenWidth - sidebarWidth) / 2 - 200 : screenWidth / 2 - 200);
                      double currentY = _obsPos?.dy ?? (MediaQuery.of(context).size.height - 180);
                      _obsPos = Offset(currentX + details.delta.dx, currentY + details.delta.dy);
                    });
                  },
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 8))]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(2)),
                        ),
                        const Icon(Icons.check_circle, color: Colors.green, size: 36),
                        const SizedBox(height: 12),
                        Text(t('s${_scenario}_final'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            _playSound('pop');
                            _loadScenario(_scenario == 5 ? 1 : _scenario + 1);
                          },
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: Text(t('nextScenario')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0, bottom: 0, width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            // MENU ICON
            Positioned(
              top: 16, left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent, iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact(); _playSound('tick');
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.8)))),
              ),
            ),

            // SUCCESS POPUP
            if (_showSuccessPopup && _completedScenarios.length == 5)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: SingleChildScrollView(
                      controller: _popupScrollController,
                      child: Container(
                        width: 450, padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.green, width: 2), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)]),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(radius: 40, backgroundColor: Colors.green, child: Icon(Icons.flag, color: Colors.white, size: 40)),
                                const SizedBox(height: 24),
                                Text(t('summaryTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                _buildRichText(t('finalSuccessDesc'), Colors.white70),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () { _playSound('pop'); setState(() => _showSuccessPopup = false); _handleReset(); },
                                  icon: const Icon(Icons.refresh), label: Text(t('finalRestartBtn')),
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                ),
                              ],
                            ),
                            Positioned(
                              top: -16,
                              right: -16,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70),
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
                width: double.infinity, height: double.infinity,
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120, height: 120, margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]),
                          child: const Icon(Icons.settings_suggest, size: 80, color: Colors.indigoAccent),
                        ),
                        Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 16),
                        Text(t('appSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () { _playSound('pop'); setState(() => _showCurtain = false); },
                          icon: const Icon(Icons.play_circle_fill, size: 28), label: Text(t('enterLab')),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, elevation: 10, shadowColor: Colors.indigoAccent.withOpacity(0.5), textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
class DecimalMultiplicationPainter extends CustomPainter {
  final int scenario;
  final int step;
  final String phase;
  final double zoom;
  final double panX, panY;
  final bool isLight;
  final List<FactorItem> factors;
  final List<TokenItem> tokens;
  final int productVal;
  final String productText;
  final int decimalPos;
  final int targetDecimalPos;
  final int tokensInTray;
  final double animProgress;
  final double beltOffset;
  final FactorItem? activeDragItem;
  final bool isDraggingDecimal;
  final Offset? decimalDragPt;
  final int hoverInsertIndex;
  final Rect sliceBtnHit, multBtnHit, insBtnHit;
  final double matW, matH, matX, matY;
  final Function(String) t;

  DecimalMultiplicationPainter({
    required this.scenario, required this.step, required this.phase,
    required this.zoom, required this.panX, required this.panY, required this.isLight,
    required this.factors, required this.tokens,
    required this.productVal, required this.productText, required this.decimalPos, required this.targetDecimalPos,
    required this.tokensInTray, required this.animProgress, required this.beltOffset,
    required this.activeDragItem, required this.isDraggingDecimal, required this.decimalDragPt, required this.hoverInsertIndex,
    required this.sliceBtnHit, required this.multBtnHit, required this.insBtnHit,
    required this.matW, required this.matH, required this.matX, required this.matY,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Background (Matched dark teal)
    canvas.drawRect(Rect.fromLTWH(-2000, -1500, 4000, 3000), Paint()..color = isLight ? const Color(0xFFE0F2FE) : const Color(0xFF264653));

    // Conveyor Belt
    canvas.drawRect(Rect.fromLTWH(matX - 450, matY + 120, 500, 25), Paint()..color = const Color(0xFF475569));
    canvas.drawRect(Rect.fromLTWH(matX - 450, matY + 145, 500, 10), Paint()..color = const Color(0xFF334155));
    // Wheels
    for (int i = 0; i < 8; i++) {
      double wx = matX - 400 + (i * 60);
      double wy = matY + 155;
      canvas.drawCircle(Offset(wx, wy), 14, Paint()..color = const Color(0xFF94A3B8));
      canvas.drawCircle(Offset(wx, wy), 14, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 3);
      
      canvas.save();
      canvas.translate(wx, wy);
      canvas.rotate(beltOffset * 0.1);
      canvas.drawRect(const Rect.fromLTWH(-3, -10, 6, 20), Paint()..color = const Color(0xFF1E293B));
      canvas.drawRect(const Rect.fromLTWH(-10, -3, 20, 6), Paint()..color = const Color(0xFF1E293B));
      canvas.restore();
    }

    // Machine Base
    _drawRoundedRect(canvas, matX, matY, matW, matH, 30, const Color(0xFFB45309), const Color(0xFF451A03), 6);
    _drawRoundedRect(canvas, matX + 15, matY + 15, matW - 30, matH - 30, 20, const Color(0xFFD97706), const Color(0xFFFCD34D), 2);
    
    // Rivets
    Paint rivetP = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawCircle(Offset(matX + 30, matY + 30), 5, rivetP);
    canvas.drawCircle(Offset(matX + matW - 30, matY + 30), 5, rivetP);
    canvas.drawCircle(Offset(matX + 30, matY + matH - 30), 5, rivetP);
    canvas.drawCircle(Offset(matX + matW - 30, matY + matH - 30), 5, rivetP);

    // Plate Title
    _drawRoundedRect(canvas, matX + matW - 220, matY + matH - 120, 180, 80, 10, const Color(0xFFFCD34D), const Color(0xFFB45309), 4);
    _drawText(canvas, "DECIMAL", matX + matW - 130, matY + matH - 95, 22, const Color(0xFF451A03));
    _drawText(canvas, "SLICER", matX + matW - 130, matY + matH - 65, 22, const Color(0xFF451A03));

    // Input Funnels
    Paint funnelBg = Paint()..color = const Color(0xFF94A3B8);
    Paint funnelStroke = Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 4;
    if (step == 1) funnelStroke = Paint()..color = Colors.amber..style = PaintingStyle.stroke..strokeWidth = 5..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
    
    canvas.drawRect(Rect.fromLTWH(matX + 250 - 30, matY - 40, 60, 60), funnelBg);
    canvas.drawRect(Rect.fromLTWH(matX + 250 - 30, matY - 40, 60, 60), funnelStroke);
    canvas.drawRect(Rect.fromLTWH(matX + 450 - 30, matY - 40, 60, 60), funnelBg);
    canvas.drawRect(Rect.fromLTWH(matX + 450 - 30, matY - 40, 60, 60), funnelStroke);

    Paint glassP = Paint()..color = Colors.white.withOpacity(0.4);
    Paint glassSp = Paint()..color = Colors.white.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 2;
    
    Path f1 = Path()..moveTo(matX + 250 - 80, matY - 120)..lineTo(matX + 250 + 80, matY - 120)..lineTo(matX + 250 + 30, matY - 40)..lineTo(matX + 250 - 30, matY - 40)..close();
    canvas.drawPath(f1, glassP); canvas.drawPath(f1, glassSp);
    Path f2 = Path()..moveTo(matX + 450 - 80, matY - 120)..lineTo(matX + 450 + 80, matY - 120)..lineTo(matX + 450 + 30, matY - 40)..lineTo(matX + 450 - 30, matY - 40)..close();
    canvas.drawPath(f2, glassP); canvas.drawPath(f2, glassSp);

    // Slicing Area Window
    Color windowColor = const Color(0xCC0F172A);
    _drawRoundedRect(canvas, matX + 160, matY + 40, 420, 160, 16, windowColor, const Color(0xFF94A3B8), 6);
    double sGearRot = (phase == 'auto_slice' || phase == 'auto_multiply') ? animProgress * pi * 4 : 0;
    _drawGear(canvas, matX + 250, matY + 120, 45, 10, const Color(0xFFF97316), const Color(0xFFC2410C), sGearRot);
    _drawGear(canvas, matX + 330, matY + 160, 35, 8, const Color(0xFFDB2777), const Color(0xFF9D174D), -sGearRot);

    // Tubes
    Paint tubeP = Paint()..color = Colors.white.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 36..strokeCap = StrokeCap.round;
    Path t1 = Path()..moveTo(matX + 250, matY + 180)..quadraticBezierTo(matX + 150, matY + 250, matX + 150, matY + 300);
    canvas.drawPath(t1, tubeP);
    Path t2 = Path()..moveTo(matX + 450, matY + 180)..quadraticBezierTo(matX + 280, matY + 250, matX + 280, matY + 300);
    canvas.drawPath(t2, tubeP);

    // Multiplier Chamber Window
    _drawRoundedRect(canvas, matX + 60, matY + 220, 300, 240, 60, windowColor, const Color(0xFF94A3B8), 6);
    double mGearRot = phase == 'auto_multiply' ? animProgress * pi * 4 : 0;
    _drawGear(canvas, matX + 150, matY + 340, 60, 12, const Color(0xFFEF4444), const Color(0xFF991B1B), mGearRot);
    _drawGear(canvas, matX + 260, matY + 300, 45, 9, const Color(0xFF8B5CF6), const Color(0xFF4C1D95), -mGearRot);
    _drawGear(canvas, matX + 220, matY + 400, 35, 8, const Color(0xFFF59E0B), const Color(0xFFB45309), -mGearRot + 0.5);
    _drawRoundedRect(canvas, matX + 125, matY + 440, 170, 60, 8, Colors.black, const Color(0xFF334155), 4);

    // Decimal Token Pipe & Tray
    Path dPipe = Path()..moveTo(matX + 550, matY + 180)..quadraticBezierTo(matX + 620, matY + 220, matX + 620, matY + 280);
    canvas.drawPath(dPipe, Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 4);
    
    _drawRoundedRect(canvas, matX + 500, matY + 300, 200, 70, 6, const Color(0x66E0F2FE), const Color(0xFF93C5FD), 4);
    _drawRoundedRect(canvas, matX + 610, matY + 350, 70, 30, 4, Colors.black, const Color(0xFF334155), 3);
    _drawText(canvas, tokensInTray.toString(), matX + 645, matY + 365, 24, const Color(0xFF38BDF8), isMono: true);

    // Re-inserter Chamber
    _drawRoundedRect(canvas, matX + 380, matY + 230, 330, 110, 16, const Color(0xFFD97706), const Color(0xFF92400E), 6);
    _drawRoundedRect(canvas, matX + 430, matY + 250, 260, 70, 10, Colors.black, const Color(0xFF334155), 6);

    // Machine Buttons
    void drawMachineButton(Rect r, String label, bool isActive) {
      Color bg = isActive ? const Color(0xFF3B82F6) : const Color(0xFF64748B);
      if (isActive) {
        canvas.drawCircle(r.center, r.width/2, Paint()..color = Colors.blueAccent..maskFilter = const MaskFilter.blur(BlurStyle.solid, 25));
      }
      canvas.drawCircle(r.center, r.width/2, Paint()..color = bg);
      canvas.drawCircle(r.center, r.width/2, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 4);
      _drawText(canvas, label, r.center.dx, r.center.dy, 16, Colors.white);
    }

    drawMachineButton(sliceBtnHit, t('sliceLbl'), step == 2 && phase == 'idle');
    drawMachineButton(multBtnHit, t('multLbl'), step == 3 && phase == 'idle');
    if (scenario <= 3) {
      drawMachineButton(insBtnHit, t('insertLbl'), step == 4 && phase == 'idle');
    }

    // Tokens in tray
    for (int i = 0; i < tokensInTray; i++) {
      _drawGear(canvas, matX + 530 + (i * 30), matY + 335, 20, 8, const Color(0xFFFACC15), const Color(0xFFB45309), 0);
      _drawText(canvas, "1", matX + 530 + (i * 30), matY + 335, 16, Colors.white);
    }

    // Dynamic Texts
    if (step >= 4 || phase == 'auto_multiply') {
      if (phase != 'auto_multiply' || animProgress > 0.8) {
        _drawText(canvas, productVal.toString(), matX + 210, matY + 470, 44, const Color(0xFF38BDF8), isMono: true);
      }
    }

    // Re-inserter display
    if (step >= 4 || phase == 'auto_multiply') {
      String displayStr = productText;
      int rDecPos = decimalPos;

      if (rDecPos >= displayStr.length) {
        displayStr = displayStr.padLeft(rDecPos + 1, '0');
      }

      String outStr = "";
      if (rDecPos == 0) outStr = displayStr;
      else {
        int insertIdx = displayStr.length - rDecPos;
        outStr = displayStr.substring(0, insertIdx) + '.' + displayStr.substring(insertIdx);
      }

      if (phase == 'wait_user_insert' || phase == 'auto_insert') {
        String renderStr = productText;
        int tempDecPos = phase == 'wait_user_insert' ? hoverInsertIndex : decimalPos;
        if (tempDecPos >= renderStr.length) renderStr = renderStr.padLeft(tempDecPos + 1, '0');

        canvas.save();
        double charW = 30;
        double startX = matX + 560 - (renderStr.length * charW) / 2;
        double baseY = matY + 285;

        for (int i = 0; i < renderStr.length; i++) {
          Color c = (renderStr[i] == '0' && i < renderStr.length - productText.length) ? const Color(0x6638BDF8) : const Color(0xFF38BDF8);
          _drawText(canvas, renderStr[i], startX + i * charW + charW / 2, baseY, 48, c, isMono: true);
        }

        double decX = startX + (renderStr.length - tempDecPos) * charW;

        if (phase == 'wait_user_insert') {
          Offset pt = decimalDragPt ?? Offset(decX, baseY);
          _drawText(canvas, ".", decX, baseY, 48, const Color(0x4D38BDF8), isMono: true);

          // Draggable point
          canvas.drawCircle(Offset(pt.dx, pt.dy + 12), 18, Paint()..color = const Color(0xFFFACC15));
          canvas.drawCircle(Offset(pt.dx, pt.dy + 12), 18, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3);
          _drawText(canvas, ".", pt.dx, pt.dy + 4, 44, Colors.black, isMono: true);

          if (!isDraggingDecimal) {
            canvas.drawCircle(Offset(pt.dx, pt.dy + 12), 18, Paint()..color = Colors.amber..style = PaintingStyle.stroke..strokeWidth = 4..maskFilter = const MaskFilter.blur(BlurStyle.solid, 15));
          }
        } else if (phase == 'auto_insert') {
          _drawText(canvas, ".", decX, baseY, 48, const Color(0xFF38BDF8), isMono: true);
        }
        canvas.restore();

        // Lever animation
        if (phase == 'auto_insert') {
          double leverRot = animProgress * 0.6;
          canvas.save();
          canvas.translate(matX + 390, matY + 285);
          canvas.rotate(-leverRot);
          canvas.drawRect(const Rect.fromLTWH(0, -10, 90, 20), Paint()..color = const Color(0xFF94A3B8));
          canvas.drawRect(const Rect.fromLTWH(0, -10, 90, 20), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);
          Path p = Path()..moveTo(90, -20)..lineTo(120, 0)..lineTo(90, 20)..close();
          canvas.drawPath(p, Paint()..color = const Color(0xFF38BDF8));
          canvas.drawPath(p, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);
          canvas.restore();
          canvas.drawCircle(Offset(matX + 390, matY + 285), 18, Paint()..color = const Color(0xFF64748B));
        }

      } else {
        if (phase != 'auto_multiply') {
          _drawText(canvas, outStr, matX + 560, matY + 285, 48, const Color(0xFF38BDF8), isMono: true);
        }
        // Static lever
        canvas.save();
        canvas.translate(matX + 390, matY + 285);
        canvas.drawRect(const Rect.fromLTWH(0, -10, 90, 20), Paint()..color = const Color(0xFF94A3B8));
        canvas.drawRect(const Rect.fromLTWH(0, -10, 90, 20), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);
        Path p = Path()..moveTo(90, -20)..lineTo(120, 0)..lineTo(90, 20)..close();
        canvas.drawPath(p, Paint()..color = const Color(0xFF38BDF8));
        canvas.drawPath(p, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);
        canvas.restore();
        canvas.drawCircle(Offset(matX + 390, matY + 285), 18, Paint()..color = const Color(0xFF64748B));
      }
    }

    // Draw Factors
    if (phase != 'auto_multiply' || animProgress < 0.5) {
      for (var f in factors) {
        if (activeDragItem != f) _drawFactor(canvas, f);
      }
    }

    // Draw Tokens
    for (var tok in tokens) {
      _drawGear(canvas, tok.x, tok.y, 22, 8, const Color(0xFFFACC15), const Color(0xFFB45309), animProgress * 15);
      _drawText(canvas, "1", tok.x, tok.y, 18, Colors.white);
    }

    // Active drag
    if (activeDragItem != null) {
      _drawFactor(canvas, activeDragItem!);
    }

    canvas.restore();
  }

  void _drawFactor(Canvas canvas, FactorItem f) {
    canvas.save();
    canvas.translate(f.x, f.y);
    bool sliceActive = (phase == 'auto_slice' && animProgress > 0.4) || step >= 3;

    TextPainter tpWhole = TextPainter(text: TextSpan(text: f.whole, style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')), textDirection: TextDirection.ltr)..layout();
    TextPainter tpFrac = TextPainter(text: TextSpan(text: ".${f.frac}", style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')), textDirection: TextDirection.ltr)..layout();
    
    double wholeW = tpWhole.width;
    double fracW = f.frac.isNotEmpty ? tpFrac.width : 0;
    double totalW = wholeW + fracW;
    double startX = -totalW / 2;

    if (!sliceActive || f.frac.isEmpty) {
      _drawText(canvas, f.whole, startX + wholeW/2, 0, 54, f.colorWhole, outlineColor: const Color(0xFF1E3A8A));
      if (f.frac.isNotEmpty) {
        _drawText(canvas, ".${f.frac}", startX + wholeW + fracW/2, 0, 54, f.colorFrac, outlineColor: const Color(0xFF1E3A8A));
      }
    } else {
      _drawText(canvas, f.whole, 0, 0, 54, f.colorWhole, outlineColor: const Color(0xFF1E3A8A));
    }
    canvas.restore();

    if (phase == 'auto_slice' && f.frac.isNotEmpty && animProgress < 0.4) {
      canvas.save();
      canvas.drawLine(Offset(f.x + startX + wholeW + 5, f.y - 70), Offset(f.x + startX + wholeW + 5, f.y + 70), Paint()..color = const Color(0xFF4ADE80)..strokeWidth = 6..maskFilter = const MaskFilter.blur(BlurStyle.solid, 20));
      canvas.drawLine(Offset(f.x + startX + wholeW + 5, f.y - 70), Offset(f.x + startX + wholeW + 5, f.y + 70), Paint()..color = const Color(0xFF4ADE80)..strokeWidth = 6);
      canvas.restore();
    }
  }

  void _drawGear(Canvas canvas, double x, double y, double radius, int teeth, Color fill, Color stroke, double angle) {
    canvas.save(); canvas.translate(x, y); canvas.rotate(angle);
    
    Path p = Path();
    double innerRad = radius * 0.75;
    for (int i = 0; i < teeth; i++) {
      double a1 = (i * pi * 2) / teeth;
      double a2 = a1 + (pi * 2) / teeth * 0.4;
      double a3 = a1 + (pi * 2) / teeth * 0.6;
      double a4 = a1 + (pi * 2) / teeth;
      if (i == 0) p.moveTo(cos(a1) * innerRad, sin(a1) * innerRad);
      p.lineTo(cos(a1) * radius, sin(a1) * radius);
      p.lineTo(cos(a2) * radius, sin(a2) * radius);
      p.lineTo(cos(a3) * innerRad, sin(a3) * innerRad);
      p.lineTo(cos(a4) * innerRad, sin(a4) * innerRad);
    }
    p.close();
    canvas.drawPath(p, Paint()..color = fill);
    canvas.drawPath(p, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(Offset.zero, innerRad, Paint()..color = fill);
    canvas.drawCircle(Offset.zero, radius * 0.4, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(Offset.zero, radius * 0.4, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 3);
    
    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double strokeW = 1.0]) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && strokeW > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double fontSize, Color color, {TextAlign align = TextAlign.center, bool isMono = false, Color? outlineColor}) {
    TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: isMono ? 'monospace' : 'Plus Jakarta Sans')),
      textDirection: TextDirection.ltr, textAlign: align,
    );
    tp.layout();
    double dx = align == TextAlign.center ? x - tp.width / 2 : (align == TextAlign.right ? x - tp.width : x);
    double dy = y - tp.height / 2;

    if (outlineColor != null) {
      TextPainter tpOut = TextPainter(
        text: TextSpan(text: text, style: TextStyle(foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = outlineColor, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: isMono ? 'monospace' : 'Plus Jakarta Sans')),
        textDirection: TextDirection.ltr, textAlign: align,
      );
      tpOut.layout();
      tpOut.paint(canvas, Offset(dx, dy));
    }

    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant DecimalMultiplicationPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA (EN, HI, TE)
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "Multiplication of Decimals", 'appTitle': "Multiplication of Decimals", 'appSubtitle': "Class 7 • ANOTHER PEEK BEYOND THE POINT", 'enterLab': "Enter Simulation",
    'settings': "Settings", 'boardFontSize': "Text Size", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done",
    'actTitle': "Action:", 'obsLbl': "Observation:", 'learnLbl': "Learning:", 'summaryTitle': "Goal Reached!", 'nextScenario': "Next Scenario",
    'machTitle': "DECIMAL SLICER", 'opLbl': "DECIMAL PLACES", 'sliceLbl': "SLICE", 'multLbl': "MULTIPLY", 'insertLbl': "INSERT", 'palLbl': "Palette", 'clickLbl': "CLICK!", 'hudNext': "Next Step",
    'finalSuccessTitle': "Activity Completed!", 'finalSuccessDesc': "You have successfully mastered the Decimal Slicer Method.", 'finalRestartBtn': "Restart Activity",

    's1_title': "1. The First Slice (9.5 x 5)", 's1_obj': "To understand how to multiply a decimal number by a whole number by observing the 'Decimal Slicer' machine in action.",
    's1_hud1': "Drag 9.5 and 5 from the conveyor belt into the glowing funnels.", 's1_step1_task': "DRAG the numbers 9.5 and 5 from the conveyor belt into the machine's input slots.", 's1_step1_obs': "The numbers are correctly positioned in the machine's input area.", 's1_step1_learn': "We start by analyzing the inputs and their decimal parts.",
    's1_hud2': "Click SLICE to scan the numbers.", 's1_step2_task': "CLICK the SLICE button on the machine to scan the numbers.", 's1_step2_obs': "A laser scans 9.5 and visually separates the decimal part. It falls as 1 token into the counter.", 's1_step2_learn': "Removing the decimal converts 9.5 to the whole number 95. We save 1 decimal shift for later.",
    's1_hud3': "Click MULTIPLY to multiply the whole numbers.", 's1_step3_task': "CLICK the MULTIPLY button to compute the product of the whole numbers.", 's1_step3_obs': "95 × 5 = 475. The gears turn and display the base product.", 's1_step3_learn': "We perform standard whole-number multiplication first.",
    's1_hud4': "Click INSERT to place the decimal point.", 's1_step4_task': "CLICK the INSERT button to watch the token physically push the decimal point into the final answer.", 's1_step4_obs': "The token pushes the decimal point 1 place left, changing 475 into 47.5.", 's1_step4_learn': "The product gets the same number of decimal places as the sum of the factors' decimal places.",
    's1_final': "9.5 (1 decimal place) × 5 (0 decimal places) = 47.5 (1 decimal place). The total number of decimal places in the factors equals the number of decimal places in the product!",

    's2_title': "2. Double Slice (12.5 x 7.5)", 's2_obj': "To understand how to multiply two decimal numbers by summing the decimal places from both numbers.",
    's2_hud1': "Drag 12.5 and 7.5 into the funnels.", 's2_step1_task': "DRAG the factors 12.5 and 7.5 from the conveyor belt into the input funnels.", 's2_step1_obs': "Both factors contain a decimal point and one decimal place each.", 's2_step1_learn': "We need to account for decimal places from all numbers involved.",
    's2_hud2': "Click SLICE to slice the decimals.", 's2_step2_task': "CLICK SLICE to separate and count the decimals from both numbers.", 's2_step2_obs': "The machine separates '.5' from both numbers. 2 tokens fall into the counter.", 's2_step2_learn': "We add the decimal places together to find the total shifts needed later.",
    's2_hud3': "Click MULTIPLY to calculate.", 's2_step3_task': "CLICK MULTIPLY to calculate the product of the whole numbers.", 's2_step3_obs': "125 × 75 = 9375.", 's2_step3_learn': "Again, we calculate as if no decimals were present.",
    's2_hud4': "Click INSERT to place the decimal.", 's2_step4_task': "CLICK INSERT to apply the total decimal places to the product.", 's2_step4_obs': "The 2 tokens push the decimal 2 places left, making 93.75.", 's2_step4_learn': "We restore the total 2 decimal places to the final product.",
    's2_final': "12.5 (1 decimal place) + 7.5 (1 decimal place) = 93.75 (2 total decimal places).",

    's3_title': "3. The Combo Slice (5.96 x 24.8)", 's3_obj': "To solidify the understanding that decimal places are summed, even when factors have different amounts.",
    's3_hud1': "Drag 5.96 and 24.8 into the funnels.", 's3_step1_task': "DRAG 5.96 and 24.8 from the conveyor belt into the funnels.", 's3_step1_obs': "The first factor has 2 decimal places, the second has 1.", 's3_step1_learn': "Decimal places can differ; we must count them all.",
    's3_hud2': "Click SLICE to count total places.", 's3_step2_task': "CLICK SLICE to sum the decimal places from all factors.", 's3_step2_obs': "2 tokens from 5.96 + 1 token from 24.8 = 3 total tokens collected.", 's3_step2_learn': "The final answer will need exactly 3 decimal places.",
    's3_hud3': "Click MULTIPLY.", 's3_step3_task': "CLICK MULTIPLY to perform base multiplication.", 's3_step3_obs': "596 × 248 = 147808.", 's3_step3_learn': "Large whole number multiplication creates our base digits.",
    's3_hud4': "Click INSERT to position the decimal.", 's3_step4_task': "CLICK INSERT to position the decimal point in the final product.", 's3_step4_obs': "The 3 tokens shift the decimal 3 places left to give 147.808.", 's3_step4_learn': "The rule holds true regardless of the size of the numbers.",
    's3_final': "5.96 (2 places) × 24.8 (1 place) = 147.808 (3 total places).",

    's4_title': "4. You're the Operator! (1.64 x 6)", 's4_obj': "To apply the learned process to multiply a decimal by a whole number by directly interacting with the machine.",
    's4_hud1': "DRAG 1.64 and 6 into the funnels.", 's4_step1_task': "DRAG the numbers 1.64 and 6 from the conveyor belt into the two input funnels of the machine.", 's4_step1_obs': "The factors are ready. 1.64 has decimals, 6 does not.", 's4_step1_learn': "We manually load the values into the mathematical engine.",
    's4_hud2': "CLICK SLICE button.", 's4_step2_task': "CLICK the large, glowing 'SLICE' button on the machine's control panel.", 's4_step2_obs': "There are 2 decimal places extracted from 1.64. The counter shows 2.", 's4_step2_learn': "We have 'banked' 2 decimal shifts for the final step.",
    's4_hud3': "CLICK MULTIPLY.", 's4_step3_task': "CLICK the 'MULTIPLY' button, which is now glowing.", 's4_step3_obs': "164 × 6 = 984.", 's4_step3_learn': "The raw digits of our answer are 9, 8, and 4.",
    's4_hud4': "DRAG the decimal point to its correct position.", 's4_step4_task': "The product 984 is shown. DRAG the decimal point to its correct position in the number.", 's4_step4_obs': "Shifting 2 places left in 984 results in 9.84.", 's4_step4_learn': "The banked decimal places are applied to finalize the math.",
    's4_final': "Excellent! 1.64 (2 places) × 6 (0 places) gives a product with 2 decimal places: 9.84.",

    's5_title': "5. The Expert Challenge (0.432 x 0.23)", 's5_obj': "To apply the process to a complex problem requiring the addition of a leading zero.",
    's5_hud1': "DRAG 0.432 and 0.23 into the funnels.", 's5_step1_task': "DRAG the factors 0.432 and 0.23 from the conveyor belt into the funnels.", 's5_step1_obs': "Both numbers are small decimals.", 's5_step1_learn': "Multiplying two numbers less than 1 yields an even smaller number.",
    's5_hud2': "CLICK SLICE.", 's5_step2_task': "CLICK SLICE to sum the decimal places.", 's5_step2_obs': "3 places + 2 places = 5 total decimal places.", 's5_step2_learn': "The final answer will need a significant shift of 5 places.",
    's5_hud3': "CLICK MULTIPLY.", 's5_step3_task': "CLICK MULTIPLY.", 's5_step3_obs': "432 × 23 = 9936.", 's5_step3_learn': "The raw base digits are 9936.",
    's5_hud4': "DRAG the decimal 5 places left (adds zero!).", 's5_step4_task': "DRAG the decimal point leftwards, padding with zeros if necessary.", 's5_step4_obs': "We need 5 shifts but 9936 only has 4 digits. We add a leading zero to get 0.09936.", 's5_step4_learn': "When the shift exceeds the number of digits, zeros are added to hold the place values.",
    's5_final': "Perfect! 0.432 (3) + 0.23 (2) = 5 total places. Since 9936 only has 4 digits, we add a leading zero: 0.09936.",
    
    'err_wrong_dec': "Incorrect position! Check the Decimal Places counter."
  },
  'hi': {
    'shutterTitle': "दशमलव गुणा", 'appTitle': "दशमलव गुणा", 'appSubtitle': "कक्षा 7 • बिंदु के पार एक और नज़र", 'enterLab': "सिमुलेशन दर्ज करें",
    'settings': "सेटिंग्स", 'boardFontSize': "टेक्स्ट आकार", 'theme': "थीम", 'darkMode': "डार्क मोड", 'lightMode': "लाइट मोड", 'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण",
    'actTitle': "कार्य:", 'obsLbl': "अवलोकन:", 'learnLbl': "सीख:", 'summaryTitle': "लक्ष्य प्राप्त हुआ!", 'nextScenario': "अगला परिदृश्य",
    'machTitle': "दशमलव स्लाइसर", 'opLbl': "दशमलव स्थान", 'sliceLbl': "स्लाइस", 'multLbl': "गुणा करें", 'insertLbl': "डालें", 'palLbl': "पैलेट", 'clickLbl': "क्लिक!", 'hudNext': "अगला कदम",
    'finalSuccessTitle': "गतिविधि पूरी हुई!", 'finalSuccessDesc': "आपने दशमलव स्लाइसर विधि को सफलतापूर्वक सीख लिया है।", 'finalRestartBtn': "गतिविधि पुनरारंभ करें",

    's1_title': "1. पहला स्लाइस (9.5 x 5)", 's1_obj': "'दशमलव स्लाइसर' मशीन को देखकर समझें कि दशमलव को पूर्ण संख्या से कैसे गुणा किया जाता है।",
    's1_hud1': "कन्वेयर बेल्ट से 9.5 और 5 को चमकते फ़नल में खींचें।", 's1_step1_task': "कन्वेयर बेल्ट से संख्या 9.5 और 5 को मशीन के इनपुट स्लॉट में खींचें।", 's1_step1_obs': "संख्याएं मशीन के इनपुट क्षेत्र में सही ढंग से स्थित हैं। 9.5 में एक दशमलव स्थान है, जबकि 5 एक पूर्ण संख्या है।", 's1_step1_learn': "हम इनपुट और उनके दशमलव भागों का विश्लेषण करके शुरुआत करते हैं।",
    's1_hud2': "मशीन को स्कैन करने के लिए 'स्लाइस' पर क्लिक करें।", 's1_step2_task': "संख्याओं को स्कैन करने के लिए मशीन पर 'स्लाइस' बटन पर क्लिक करें।", 's1_step2_obs': "एक लेज़र 9.5 को स्कैन करता है और दशमलव भाग को अलग करता है। यह काउंटर में 1 टोकन के रूप में गिरता है।", 's1_step2_learn': "दशमलव हटाने से 9.5 पूर्ण संख्या 95 में बदल जाता है। हम बाद के लिए 1 दशमलव शिफ्ट बचाते हैं।",
    's1_hud3': "पूर्ण संख्याओं को गुणा करने के लिए 'गुणा करें' पर क्लिक करें।", 's1_step3_task': "पूर्ण संख्याओं के गुणनफल की गणना करने के लिए 'गुणा करें' बटन पर क्लिक करें।", 's1_step3_obs': "95 × 5 = 475. गियर घूमते हैं और मूल उत्पाद प्रदर्शित करते हैं।", 's1_step3_learn': "हम पहले मानक पूर्ण-संख्या गुणा करते हैं।",
    's1_hud4': "दशमलव बिंदु डालने के लिए 'डालें' पर क्लिक करें।", 's1_step4_task': "टोकन को अंतिम उत्तर में भौतिक रूप से दशमलव बिंदु धकेलते हुए देखने के लिए 'डालें' पर क्लिक करें।", 's1_step4_obs': "टोकन दशमलव बिंदु को 1 स्थान बाईं ओर धकेलता है, जिससे 475, 47.5 में बदल जाता है।", 's1_step4_learn': "उत्पाद में कारकों के दशमलव स्थानों के योग के बराबर दशमलव स्थान होते हैं।",
    's1_final': "9.5 (1 दशमलव स्थान) × 5 (0 दशमलव स्थान) = 47.5 (1 दशमलव स्थान)।",

    's2_title': "2. डबल स्लाइस (12.5 x 7.5)", 's2_obj': "दोनों संख्याओं के दशमलव स्थानों को जोड़कर दो दशमलव संख्याओं का गुणा समझना।",
    's2_hud1': "कन्वेयर बेल्ट से 12.5 और 7.5 को फ़नल में खींचें।", 's2_step1_task': "कन्वेयर बेल्ट से कारकों 12.5 और 7.5 को इनपुट फ़नल में खींचें।", 's2_step1_obs': "दोनों कारकों में दशमलव बिंदु और एक-एक दशमलव स्थान है।", 's2_step1_learn': "हमें शामिल सभी संख्याओं के दशमलव स्थानों का हिसाब रखना होगा।",
    's2_hud2': "दशमलव को अलग करने के लिए 'स्लाइस' पर क्लिक करें।", 's2_step2_task': "दोनों संख्याओं से दशमलव को अलग करने और गिनने के लिए 'स्लाइस' पर क्लिक करें।", 's2_step2_obs': "मशीन दोनों संख्याओं से '.5' अलग करती है। काउंटर में 2 टोकन गिरते हैं।", 's2_step2_learn': "हम बाद में आवश्यक कुल बदलाव खोजने के लिए दशमलव स्थानों को जोड़ते हैं।",
    's2_hud3': "गणना करने के लिए 'गुणा करें' पर क्लिक करें।", 's2_step3_task': "पूर्ण संख्याओं के उत्पाद की गणना करने के लिए 'गुणा करें' पर क्लिक करें।", 's2_step3_obs': "125 × 75 = 9375.", 's2_step3_learn': "फिर से, हम गणना करते हैं जैसे कि कोई दशमलव मौजूद नहीं था।",
    's2_hud4': "दशमलव डालने के लिए 'डालें' पर क्लिक करें।", 's2_step4_task': "उत्पाद में कुल दशमलव स्थान लागू करने के लिए 'डालें' पर क्लिक करें।", 's2_step4_obs': "2 टोकन दशमलव को 2 स्थान बाईं ओर धकेलते हैं, जिससे 93.75 बनता है।", 's2_step4_learn': "हम अंतिम उत्पाद में कुल 2 दशमलव स्थानों को पुनर्स्थापित करते हैं।",
    's2_final': "12.5 (1 स्थान) + 7.5 (1 स्थान) = 93.75 (2 कुल स्थान)।",

    's3_title': "3. कॉम्बो स्लाइस (5.96 x 24.8)", 's3_obj': "यह समझना कि दशमलव स्थानों को हमेशा जोड़ा जाता है।",
    's3_hud1': "कन्वेयर बेल्ट से 5.96 और 24.8 को फ़नल में खींचें।", 's3_step1_task': "कन्वेयर बेल्ट से 5.96 और 24.8 को फ़नल में खींचें।", 's3_step1_obs': "पहले कारक में 2 दशमलव स्थान हैं, दूसरे में 1 है।", 's3_step1_learn': "दशमलव स्थान भिन्न हो सकते हैं; हमें उन सभी को गिनना होगा।",
    's3_hud2': "कुल स्थान गिनने के लिए 'स्लाइस' पर क्लिक करें।", 's3_step2_task': "सभी कारकों से दशमलव स्थानों का योग करने के लिए 'स्लाइस' पर क्लिक करें।", 's3_step2_obs': "5.96 से 2 टोकन + 24.8 से 1 टोकन = 3 कुल टोकन एकत्र किए गए।", 's3_step2_learn': "अंतिम उत्तर में ठीक 3 दशमलव स्थानों की आवश्यकता होगी।",
    's3_hud3': "'गुणा करें' पर क्लिक करें।", 's3_step3_task': "आधार गुणा करने के लिए 'गुणा करें' पर क्लिक करें।", 's3_step3_obs': "596 × 248 = 147808.", 's3_step3_learn': "बड़ी पूर्ण संख्या गुणा हमारे आधार अंक बनाती है।",
    's3_hud4': "दशमलव को स्थिति में लाने के लिए 'डालें' पर क्लिक करें।", 's3_step4_task': "अंतिम उत्पाद में दशमलव बिंदु को रखने के लिए 'डालें' पर क्लिक करें।", 's3_step4_obs': "3 टोकन 147.808 देने के लिए दशमलव को 3 स्थान बाईं ओर शिफ्ट करते हैं।", 's3_step4_learn': "संख्याओं के आकार की परवाह किए बिना नियम सही रहता है।",
    's3_final': "5.96 (2) × 24.8 (1) = 147.808 (3 कुल स्थान)।",

    's4_title': "4. आप ऑपरेटर हैं! (1.64 x 6)", 's4_obj': "सीखी गई प्रक्रिया को स्वयं लागू करना।",
    's4_hud1': "कन्वेयर बेल्ट से 1.64 और 6 को कीप में खींचें।", 's4_step1_task': "कन्वेयर बेल्ट से 1.64 और 6 को मशीन के दो इनपुट फ़नल में खींचें।", 's4_step1_obs': "कारक तैयार हैं। 1.64 में दशमलव हैं, 6 में नहीं।", 's4_step1_learn': "हम मानों को मैन्युअल रूप से गणितीय इंजन में लोड करते हैं।",
    's4_hud2': "'SLICE' बटन पर क्लिक करें।", 's4_step2_task': "मशीन के कंट्रोल पैनल पर बड़े, चमकते हुए 'SLICE' बटन पर क्लिक करें।", 's4_step2_obs': "1.64 से निकाले गए कुल 2 दशमलव स्थान हैं। काउंटर 2 दिखाता है।", 's4_step2_learn': "हमने अंतिम चरण के लिए 2 दशमलव बदलाव 'बैंक' किए हैं।",
    's4_hud3': "'गुणा करें' बटन पर क्लिक करें।", 's4_step3_task': "'MULTIPLY' बटन पर क्लिक करें, जो अब चमक रहा है।", 's4_step3_obs': "164 × 6 = 984.", 's4_step3_learn': "हमारे उत्तर के कच्चे अंक 9, 8 और 4 हैं।",
    's4_hud4': "दशमलव को उसकी सही स्थिति में खींचें।", 's4_step4_task': "उत्पाद 984 को दिखाया गया है। दशमलव बिंदु को उसके सही स्थान पर खींचें।", 's4_step4_obs': "984 में 2 स्थान बाईं ओर खिसकने पर 9.84 प्राप्त होता है।", 's4_step4_learn': "गणित को अंतिम रूप देने के लिए बैंक किए गए दशमलव स्थान लागू किए जाते हैं।",
    's4_final': "बहुत बढ़िया! 1.64 (2) × 6 (0) का उत्पाद 2 दशमलव स्थानों के साथ 9.84 है।",

    's5_title': "5. विशेषज्ञ चुनौती (0.432 x 0.23)", 's5_obj': "अग्रणी शून्य जोड़ने की आवश्यकता वाली जटिल समस्या को हल करना।",
    's5_hud1': "कन्वेयर बेल्ट से 0.432 और 0.23 को कीप में खींचें।", 's5_step1_task': "कन्वेयर बेल्ट से 0.432 और 0.23 को फ़नल में खींचें।", 's5_step1_obs': "दोनों संख्याएं छोटे दशमलव हैं।", 's5_step1_learn': "1 से कम दो संख्याओं को गुणा करने पर और भी छोटी संख्या प्राप्त होती है।",
    's5_hud2': "SLICE बटन पर क्लिक करें।", 's5_step2_task': "दशमलव स्थानों का योग करने के लिए 'स्लाइस' पर क्लिक करें।", 's5_step2_obs': "3 स्थान + 2 स्थान = 5 कुल दशमलव स्थान।", 's5_step2_learn': "अंतिम उत्तर में 5 स्थानों के महत्वपूर्ण बदलाव की आवश्यकता होगी।",
    's5_hud3': "MULTIPLY बटन पर क्लिक करें।", 's5_step3_task': "MULTIPLY पर क्लिक करें।", 's5_step3_obs': "432 × 23 = 9936.", 's5_step3_learn': "कच्चे आधार अंक 9936 हैं।",
    's5_hud4': "दशमलव को 5 स्थान बाईं ओर खींचें।", 's5_step4_task': "दशमलव बिंदु को बाईं ओर खींचें, यदि आवश्यक हो तो शून्य के साथ पैडिंग करें।", 's5_step4_obs': "हमें 5 शिफ्ट की आवश्यकता है लेकिन 9936 में केवल 4 अंक हैं। हम 0.09936 प्राप्त करने के लिए एक अग्रणी शून्य जोड़ते हैं।", 's5_step4_learn': "जब बदलाव अंकों की संख्या से अधिक हो जाता है, तो स्थानीय मानों को बनाए रखने के लिए शून्य जोड़े जाते हैं।",
    's5_final': "बिल्कुल सही! कुल 5 स्थान। 9936 में शून्य जोड़कर 0.09936 प्राप्त हुआ।",
    
    'err_wrong_dec': "गलत स्थान! दशमलव स्थान काउंटर की जाँच करें।"
  },
  };