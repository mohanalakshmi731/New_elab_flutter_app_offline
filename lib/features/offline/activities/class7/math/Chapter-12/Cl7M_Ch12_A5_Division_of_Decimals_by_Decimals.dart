// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DivisionofDecimalsbyDecimalsApp());
}

class DivisionofDecimalsbyDecimalsApp extends StatelessWidget {
  const DivisionofDecimalsbyDecimalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Division of Decimals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const DivisionofDecimalsbyDecimals(),
    );
  }
}

// ==========================================
// MAIN WIDGET
// ==========================================
class DivisionofDecimalsbyDecimals extends StatefulWidget {
  const DivisionofDecimalsbyDecimals({super.key});

  @override
  State<DivisionofDecimalsbyDecimals> createState() => _DivisionofDecimalsbyDecimalsState();
}

class _DivisionofDecimalsbyDecimalsState extends State<DivisionofDecimalsbyDecimals> with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
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

  // Interaction State
  double _mouseX = 0;
  double _mouseY = 0;
  String? _activeDragType;

  // Domain State
  double _dividendOrig = 0;
  double _divisorOrig = 0;
  int _targetMult = 0;
  double _targetCount = 0;
  int _maxMath = 0;

  double _dividendCurrent = 0;
  double _divisorCurrent = 0;

  bool _leftPanHasBlock = false;
  bool _rightPanHasBlock = false;
  double _rightPanCount = 0;

  int? _rayMultiplier;
  bool _rayFired = false;
  double _rayAnim = 0;

  int _mathStep = 0;
  bool _isCompleted = false;

  // Temporary HUD
  String _hudMessage = '';
  bool _showHud = false;

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

  late AnimationController _ticker;

  final Map<int, Map<String, dynamic>> _scenarioData = {
    1: {'diviOrig': 4.5, 'divOrig': 1.5, 'targetMult': 10, 'maxMath': 0, 'targetCount': 3.0},
    2: {'diviOrig': 9.36, 'divOrig': 0.12, 'targetMult': 100, 'maxMath': 0, 'targetCount': 78.0},
    3: {'diviOrig': 4.68, 'divOrig': 1.3, 'targetMult': 10, 'maxMath': 2, 'targetCount': 3.6},
    4: {'diviOrig': 12.6, 'divOrig': 2.5, 'targetMult': 10, 'maxMath': 2, 'targetCount': 5.04},
    5: {'diviOrig': 5.728, 'divOrig': 1.52, 'targetMult': 100, 'maxMath': 3, 'targetCount': 3.76}
  };

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
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      if (type == 'enter') {
        await _fxPlayer.play(AssetSource(_shutterUrl), volume: 0.5);
      } else if (type == 'pop' || type == 'tick' || type == 'snap') {
        await _clickPlayer.play(AssetSource(_clickUrl), volume: 0.5);
      } else if (type == 'fire' || type == 'whir') {
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
      _lang = 'en';
      _showHud = false;
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

      var data = _scenarioData[id]!;
      _dividendOrig = data['diviOrig'];
      _divisorOrig = data['divOrig'];
      _targetMult = data['targetMult'];
      _targetCount = data['targetCount'];
      _maxMath = data['maxMath'];

      _dividendCurrent = _dividendOrig;
      _divisorCurrent = _divisorOrig;
      
      _leftPanHasBlock = false;
      _rightPanHasBlock = false;
      _rightPanCount = 0;

      _rayMultiplier = null;
      _rayFired = false;
      _rayAnim = 0;
      _mathStep = 0;
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    if (_rayAnim > 0) {
      setState(() {
        _rayAnim += 0.02;
        if (_rayAnim >= 1) {
          _rayAnim = 0;
          _dividendCurrent = (_dividendOrig * _rayMultiplier!).toDouble();
          _divisorCurrent = (_divisorOrig * _rayMultiplier!).toDouble();
          
          _dividendCurrent = double.parse(_dividendCurrent.toStringAsFixed(3));
          _divisorCurrent = double.parse(_divisorCurrent.toStringAsFixed(3));

          _playSound('pop');
          _checkStepAdvancement();
        }
      });
    }
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkStepAdvancement() {
    setState(() {
      if (_scenario == 1) {
        if (_step == 1 && _leftPanHasBlock) _advanceStep();
        if (_step == 2 && _rightPanHasBlock) _advanceStep();
        if (_step == 3 && _rayMultiplier == 10) _advanceStep();
        if (_step == 4 && _rayFired) _advanceStep();
        if (_step == 5 && _rightPanCount == _targetCount) _checkScenarioSuccess();
      } else if (_scenario == 2) {
        if (_step == 1 && _leftPanHasBlock && _rightPanHasBlock) _advanceStep();
        if (_step == 2 && _rayMultiplier == 100) _advanceStep();
        if (_step == 3 && _rayFired) _advanceStep();
        if (_step == 4 && _rightPanCount == _targetCount) _checkScenarioSuccess();
      } else if (_scenario == 3) {
        if (_step == 1 && _leftPanHasBlock && _rightPanHasBlock) _advanceStep();
        if (_step == 2 && _rayMultiplier == 10) _advanceStep();
        if (_step == 3 && _rayFired) _advanceStep();
        if (_step == 4 && _mathStep == _maxMath) _checkScenarioSuccess();
      } else if (_scenario == 4) {
        if (_step == 1 && _leftPanHasBlock && _rightPanHasBlock) _advanceStep();
        if (_step == 2 && _rayFired) _advanceStep();
        if (_step == 3 && _mathStep == _maxMath) _checkScenarioSuccess();
      } else if (_scenario == 5) {
        if (_step == 1 && _leftPanHasBlock && _rightPanHasBlock) _advanceStep();
        if (_step == 2 && _rayFired) _advanceStep();
        if (_step == 3 && _mathStep == _maxMath) _checkScenarioSuccess();
      }
    });
  }

  void _checkScenarioSuccess() {
    if (_isCompleted) return;
    setState(() {
      int totalSteps = (_scenario == 1) ? 5 : (_scenario == 2) ? 4 : (_scenario == 3) ? 4 : 3;
      _step = totalSteps + 1;
      _isCompleted = true;
      _completedScenarios.add(_scenario);
      _showSuccessPopup = true;
    });
    _playSound('success');
    _scrollToActiveStep();
  }

  void _checkUnsolvedAnswer() {
    if (!_leftPanHasBlock || !_rightPanHasBlock) {
      _playSound('error');
      _showTemporaryHUD(t('err_block'));
      return;
    }
    if (!_rayFired || _rayMultiplier != _targetMult) {
      _playSound('error');
      _showTemporaryHUD(t('err_ray'));
      return;
    }
    if (_mathStep < _maxMath) {
      _playSound('error');
      _showTemporaryHUD(t('err_math'));
      return;
    }
    _checkScenarioSuccess();
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
      if (mounted) {
        setState(() => _showHud = false);
      }
    });
  }

  // Viewport hit testing variables
  final double _matW = 1200;
  final double _matH = 700;
  final double _matX = -600;
  final double _matY = -350;

  Rect _getInvDiviHitbox() => Rect.fromLTWH(_matX + 60, _matY + 180, 100, 100);
  Rect _getInvDivHitbox() => Rect.fromLTWH(_matX + 60, _matY + 300, 100, 100);
  
  Rect _getLeftScaleHitbox() => Rect.fromLTWH(-280, _matY + 300, 160, 140);
  Rect _getRightScaleHitbox() => Rect.fromLTWH(120, _matY + 300, 160, 140);

  // Inflated hitboxes for easier tapping
  Rect _getRayBtn10Hitbox() => Rect.fromLTWH(_matX + 900, _matY + 200, 50, 40).inflate(10);
  Rect _getRayBtn100Hitbox() => Rect.fromLTWH(_matX + 960, _matY + 200, 50, 40).inflate(10);
  Rect _getRayBtn1000Hitbox() => Rect.fromLTWH(_matX + 1020, _matY + 200, 60, 40).inflate(10);
  Rect _getRayFireHitbox() => Rect.fromLTWH(_matX + 900, _matY + 150, 180, 40).inflate(10);

  Rect _getDispenserBtn1Hitbox() => Rect.fromLTWH(_matX + 900, _matY + 350, 60, 40).inflate(15);
  Rect _getDispenserBtn10Hitbox() => Rect.fromLTWH(_matX + 970, _matY + 350, 60, 40).inflate(15);

  Rect _getMathBtnHitbox() => Rect.fromLTWH(_matX + 925, _matY + 560, 180, 40).inflate(15);

  Offset _screenToWorld(Offset screenPos, Size size) {
    double cx = size.width / 2 + _panX;
    double cy = size.height / 2 + _panY;
    return Offset((screenPos.dx - cx) / _zoom, (screenPos.dy - cy) / _zoom);
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    if (_isCompleted || _rayAnim > 0) return;
    Offset pt = _screenToWorld(details.localPosition, size);

    // 1. Process Instant Clicks for Ray Buttons
    if (_getRayBtn10Hitbox().contains(pt)) {
      if (_targetMult < 10) { _playSound('error'); _showTemporaryHUD(t('err_hint_smaller')); return; }
      setState(() => _rayMultiplier = 10); _playSound('tick'); _checkStepAdvancement(); return;
    }
    if (_getRayBtn100Hitbox().contains(pt)) {
      if (_targetMult == 10) { _playSound('error'); _showTemporaryHUD(t('err_hint_smallest')); return; }
      if (_targetMult < 100) { _playSound('error'); _showTemporaryHUD(t('err_hint_smaller')); return; }
      setState(() => _rayMultiplier = 100); _playSound('tick'); _checkStepAdvancement(); return;
    }
    if (_getRayBtn1000Hitbox().contains(pt)) {
      if (_targetMult == 10 || _targetMult == 100) { _playSound('error'); _showTemporaryHUD(t('err_hint_smallest')); return; }
      setState(() => _rayMultiplier = 1000); _playSound('tick'); _checkStepAdvancement(); return;
    }
    
    // 2. Process Instant Clicks for FIRE
    if (_getRayFireHitbox().contains(pt) && _rayMultiplier != null && !_rayFired) {
      if (_rayMultiplier != _targetMult && _scenario < 4) { _playSound('error'); _showTemporaryHUD(t('err_ray')); return; }
      if (!_leftPanHasBlock || !_rightPanHasBlock) { _playSound('error'); _showTemporaryHUD(t('err_block')); return; }
      setState(() { _rayFired = true; _rayAnim = 0.01; }); _playSound('fire'); return;
    }

    // 3. Process Instant Clicks for Dispenser
    if (_scenario == 2 && _rayFired) {
      if (_getDispenserBtn1Hitbox().contains(pt)) {
        if (_rightPanCount < _targetCount) {
          setState(() => _rightPanCount = min(_rightPanCount + 1, _targetCount));
          _playSound('tick'); _checkStepAdvancement();
        } else { _playSound('error'); }
        return;
      }
      if (_getDispenserBtn10Hitbox().contains(pt)) {
        if (_rightPanCount < _targetCount) {
          setState(() => _rightPanCount = min(_rightPanCount + 10, _targetCount));
          _playSound('tick'); _checkStepAdvancement();
        } else { _playSound('error'); }
        return;
      }
    }

    // 4. Process Instant Clicks for Math Step
    if (_scenario >= 3 && _rayFired && _mathStep < _maxMath) {
      if (_getMathBtnHitbox().contains(pt)) {
        setState(() {
          _mathStep++;
          if (_mathStep == _maxMath) {
            _rightPanCount = _targetCount;
            _checkStepAdvancement();
          }
        });
        _playSound('snap');
        return;
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (!_isCompleted && _rayAnim == 0) {
      // Process Draggables ONLY (Clicks are handled above now)
      if (!_leftPanHasBlock && _getInvDiviHitbox().contains(pt)) {
        setState(() { _activeDragType = 'dividend'; _mouseX = pt.dx; _mouseY = pt.dy; });
        _playSound('tick'); return;
      }
      
      bool canDragDivisor = !_rightPanHasBlock || (_scenario == 1 && _rayFired);
      if (canDragDivisor && _getInvDivHitbox().contains(pt)) {
        setState(() { _activeDragType = 'divisor'; _mouseX = pt.dx; _mouseY = pt.dy; });
        _playSound('tick'); return;
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
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_activeDragType != null) {
      Offset pt = Offset(_mouseX, _mouseY);
      
      if (_activeDragType == 'dividend' && _getLeftScaleHitbox().contains(pt)) {
        setState(() => _leftPanHasBlock = true); _playSound('snap'); _checkStepAdvancement();
      } else if (_activeDragType == 'divisor' && _getRightScaleHitbox().contains(pt)) {
        setState(() { _rightPanHasBlock = true; _rightPanCount++; }); _playSound('snap'); _checkStepAdvancement();
      } else {
        _playSound('error');
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
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);

    int totalSteps = (_scenario == 1) ? 5 : (_scenario == 2) ? 4 : (_scenario == 3) ? 4 : 3;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(5, 0))],
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
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.calculate, color: Colors.indigoAccent),
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
                    decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
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
                    Color stepBg = isCurrent ? Colors.indigo.withOpacity(0.1) : (isPast ? Colors.green.withOpacity(0.05) : Colors.white.withOpacity(0.02));
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
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.withOpacity(0.2))),
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
                          scenario: _scenario,
                          step: _step,
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          mouseX: _mouseX,
                          mouseY: _mouseY,
                          activeDragType: _activeDragType,
                          dividendOrig: _dividendOrig,
                          divisorOrig: _divisorOrig,
                          dividendCurrent: _dividendCurrent,
                          divisorCurrent: _divisorCurrent,
                          leftPanHasBlock: _leftPanHasBlock,
                          rightPanHasBlock: _rightPanHasBlock,
                          rightPanCount: _rightPanCount,
                          rayMultiplier: _rayMultiplier,
                          rayFired: _rayFired,
                          rayAnim: _rayAnim,
                          mathStep: _mathStep,
                          maxMath: _maxMath,
                          isCompleted: _isCompleted,
                          targetCount: _targetCount,
                          t: t,
                          matW: _matW,
                          matH: _matH,
                          matX: _matX,
                          matY: _matY,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Temporary HUD / Step Instruction
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
                              child: Text(_showHud ? _hudMessage : hudText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Actions Bottom
            if ((_scenario == 4 || _scenario == 5) && !_isCompleted)
              Positioned(
                bottom: 120,
                left: _isSidebarOpen ? sidebarWidth + 40 : 40,
                right: 40,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _checkUnsolvedAnswer,
                    icon: const Icon(Icons.check_circle),
                    label: Text(t('checkAnswer')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // Final Success Popup
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: SingleChildScrollView(
                      controller: _popupScrollController,
                      child: Container(
                        width: 500,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.amber, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
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
                              _scenario < 5 ? t('guideNextScenario') : t('allScenariosComplete'),
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
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]),
                          child: const Icon(Icons.calculate, size: 80, color: Colors.indigoAccent),
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
class LabPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX, panY;
  final double mouseX, mouseY;
  final String? activeDragType;
  
  final double dividendOrig;
  final double divisorOrig;
  final double dividendCurrent;
  final double divisorCurrent;
  final bool leftPanHasBlock;
  final bool rightPanHasBlock;
  final double rightPanCount;
  final int? rayMultiplier;
  final bool rayFired;
  final double rayAnim;
  final int mathStep;
  final int maxMath;
  final bool isCompleted;
  final double targetCount;

  final Function(String) t;
  final double matW, matH, matX, matY;

  LabPainter({
    required this.scenario, required this.step, required this.zoom,
    required this.panX, required this.panY, required this.mouseX, required this.mouseY,
    required this.activeDragType, required this.dividendOrig, required this.divisorOrig,
    required this.dividendCurrent, required this.divisorCurrent,
    required this.leftPanHasBlock, required this.rightPanHasBlock, required this.rightPanCount,
    required this.rayMultiplier, required this.rayFired, required this.rayAnim,
    required this.mathStep, required this.maxMath, required this.isCompleted, required this.targetCount,
    required this.t, required this.matW, required this.matH, required this.matX, required this.matY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    _drawInventory(canvas);
    _drawEquivalenceScale(canvas);
    _drawRayGun(canvas);
    _drawDispenserAndMath(canvas);

    if (activeDragType != null) {
      canvas.saveLayer(Rect.fromLTWH(-5000, -5000, 10000, 10000), Paint()..color = Colors.white.withOpacity(0.9));
      double val = activeDragType == 'dividend' ? dividendCurrent : divisorCurrent;
      bool isDivi = activeDragType == 'dividend';
      double scaleMult = rayFired ? 1.2 : 1.0;
      _draw3DBlock(canvas, mouseX - 30, mouseY - 30, 60 * scaleMult, 60 * scaleMult, 15 * scaleMult, _fmt(val), isDivi, true);
      canvas.restore();
    }

    canvas.restore();
  }

  String _fmt(double v) => v == v.truncateToDouble() ? v.truncate().toString() : v.toString();

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

  void _draw3DBlock(Canvas canvas, double x, double y, double w, double h, double depth, String valText, bool isDividend, [bool isHover = false]) {
    canvas.save();
    if (isHover) {
      canvas.drawRect(Rect.fromLTWH(x - 5, y - 5 - depth, w + 10 + depth, h + 10 + depth), Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }
    
    Color colorFront = isDividend ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
    Color colorTop = isDividend ? const Color(0xFF60A5FA) : const Color(0xFF34D399);
    Color colorSide = isDividend ? const Color(0xFF2563EB) : const Color(0xFF059669);
    Color strokeColor = const Color(0xFF1E293B);

    canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = colorFront);
    
    Path top = Path()..moveTo(x, y)..lineTo(x + depth, y - depth)..lineTo(x + w + depth, y - depth)..lineTo(x + w, y)..close();
    canvas.drawPath(top, Paint()..color = colorTop);
    
    Path right = Path()..moveTo(x + w, y)..lineTo(x + w + depth, y - depth)..lineTo(x + w + depth, y + h - depth)..lineTo(x + w, y + h)..close();
    canvas.drawPath(right, Paint()..color = colorSide);

    Paint strokePaint = Paint()..color = strokeColor..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), strokePaint);
    canvas.drawPath(top, strokePaint);
    canvas.drawPath(right, strokePaint);
    
    double fontSize = h < 40 ? 14 : (valText.length > 3 ? 18 : 24);
    _drawTextOutline(canvas, valText, x + w / 2, y + h / 2 + 2, fontSize, Colors.white, Colors.transparent, 0);
    
    canvas.restore();
  }

  void _drawSpeechBubble(Canvas canvas, double x, double y, String textStr) {
    List<String> lines = textStr.split('\n');
    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    double maxW = 0;
    for (var line in lines) {
      tp.text = TextSpan(text: line, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
      tp.layout();
      if (tp.width > maxW) maxW = tp.width;
    }
    
    double w = maxW + 40;
    double h = (lines.length * 24.0) + 20;
    
    canvas.save();
    _drawRoundedRect(canvas, x - w/2, y - h - 15, w, h, 12, Colors.white, const Color(0xFF334155), 2);
    
    Path tail = Path()..moveTo(x - 10, y - 15)..lineTo(x, y)..lineTo(x + 10, y - 15)..close();
    canvas.drawPath(tail, Paint()..color = Colors.white);
    
    Paint borderPaint = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawLine(Offset(x - 10, y - 15), Offset(x, y), borderPaint);
    canvas.drawLine(Offset(x, y), Offset(x + 10, y - 15), borderPaint);
    
    for (int i = 0; i < lines.length; i++) {
      _drawTextOutline(canvas, lines[i], x, y - h + 15 + (i * 24), 16, const Color(0xFF1E293B), Colors.transparent, 0);
    }
    canvas.restore();
  }

  void _drawInventory(Canvas canvas) {
    _drawRoundedRect(canvas, matX + 40, matY + 120, 180, 320, 16, const Color(0xFF0F172A), const Color(0xFF475569), 3);
    _drawTextOutline(canvas, t('lbl_inventory'), matX + 130, matY + 145, 18, const Color(0xFF94A3B8), Colors.transparent, 0);
    
    double bw = 60, bh = 60, bd = 15;
    
    if (!leftPanHasBlock || activeDragType == 'dividend') {
      _draw3DBlock(canvas, matX + 80, matY + 200, bw, bh, bd, _fmt(dividendCurrent), true, activeDragType == 'dividend');
    }
    
    bool canDragDivisor = !rightPanHasBlock || (scenario == 1 && rayFired);
    if (canDragDivisor || activeDragType == 'divisor') {
      _draw3DBlock(canvas, matX + 80, matY + 320, bw, bh, bd, _fmt(divisorCurrent), false, activeDragType == 'divisor');
    }
  }

  void _drawEquivalenceScale(Canvas canvas) {
    double cx = 0; double cy = matY + 300;
    
    canvas.drawLine(Offset(matX, cy + 280), Offset(matX + matW, cy + 280), Paint()..color = const Color(0xFF8B5A2B)..strokeWidth = 8..strokeCap = StrokeCap.round);
    
    double leftVal = leftPanHasBlock ? dividendCurrent : 0;
    double rightVal = rightPanHasBlock ? (divisorCurrent * rightPanCount) : 0;
    
    double angle = 0;
    if (leftVal > 0 && rightVal == 0) angle = -0.15;
    else if (leftVal > 0 && rightVal > 0) {
      double ratio = rightVal / leftVal;
      if (ratio < 0.99) angle = -0.15 + (ratio * 0.1); 
      else if (ratio > 1.01) angle = 0.15;
      else angle = 0; 
    }
    if (activeDragType != null && activeDragType!.isNotEmpty) angle = -0.15; 
    
    _drawRoundedRect(canvas, cx - 80, cy + 250, 160, 30, 15, const Color(0xFF475569), const Color(0xFF334155), 3);
    _drawTextOutline(canvas, t('lbl_eq_scale'), cx, cy + 265, 16, const Color(0xFFCBD5E1), Colors.transparent, 0);
    
    _drawRoundedRect(canvas, cx - 20, cy, 40, 250, 8, const Color(0xFF94A3B8), const Color(0xFF475569), 3);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    
    _drawRoundedRect(canvas, -260, -10, 520, 20, 10, const Color(0xFF94A3B8), const Color(0xFF475569), 3);
    
    Paint fillLight = Paint()..color = const Color(0xFFF8FAFC);
    Paint strokeDark = Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(const Offset(-240, 0), 8, fillLight); canvas.drawCircle(const Offset(-240, 0), 8, strokeDark);
    canvas.drawCircle(const Offset(240, 0), 8, fillLight); canvas.drawCircle(const Offset(240, 0), 8, strokeDark);
    canvas.drawCircle(const Offset(0, 0), 16, fillLight); canvas.drawCircle(const Offset(0, 0), 16, strokeDark);

    canvas.restore();

    double leftPanY = cy + sin(angle) * -240 + 180;
    double rightPanY = cy + sin(angle) * 240 + 180;

    canvas.drawLine(Offset(cx + cos(angle)*-240, cy + sin(angle)*-240), Offset(cx - 200, leftPanY), Paint()..color=const Color(0xFF94A3B8)..strokeWidth=3);
    canvas.drawLine(Offset(cx + cos(angle)*240, cy + sin(angle)*240), Offset(cx + 200, rightPanY), Paint()..color=const Color(0xFF94A3B8)..strokeWidth=3);

    Paint panFill = Paint()..color = const Color(0xFFCBD5E1);
    Paint panStroke = Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 3;
    
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 200, leftPanY), width: 180, height: 40), panFill);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 200, leftPanY), width: 180, height: 40), panStroke);
    
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 200, rightPanY), width: 180, height: 40), panFill);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 200, rightPanY), width: 180, height: 40), panStroke);

    double bw = 60, bh = 60, bd = 15;
    double scaleMult = (rayFired || rayAnim > 0.5) ? 1.2 : 1.0;
    double drawW = bw * scaleMult, drawH = bh * scaleMult, drawD = bd * scaleMult;

    if (leftPanHasBlock && activeDragType != 'dividend') {
      _draw3DBlock(canvas, cx - 200 - drawW/2, leftPanY - drawH - 5, drawW, drawH, drawD, _fmt(dividendCurrent), true);
    }
    
    if (rightPanHasBlock && activeDragType != 'divisor') {
      int maxDraw = min(rightPanCount.floor(), 8); 
      double remainder = rightPanCount - rightPanCount.floor();

      for (int i = 0; i < maxDraw; i++) {
        double ox = cx + 200 - drawW/2;
        double oy = rightPanY - drawH - 5 - (i * (drawH * 0.7).floor()); 
        _draw3DBlock(canvas, ox, oy, drawW, drawH, drawD, _fmt(divisorCurrent), false);
      }

      if (remainder > 0.001 && maxDraw < 8) {
        double ox = cx + 200 - drawW/2;
        double fracH = drawH * remainder; 
        double oy = rightPanY - fracH - 5 - (maxDraw * (drawH * 0.7).floor());
        _draw3DBlock(canvas, ox, oy, drawW, max(15, fracH), drawD, remainder.toStringAsFixed(3).replaceFirst(RegExp(r'0*$'), '').replaceFirst(RegExp(r'\.$'), ''), false);
      }

      if (rightPanCount > 8) {
        _drawTextOutline(canvas, "x ${_fmt(rightPanCount)}", cx + 270, rightPanY - (maxDraw/2 * drawH * 0.7), 36, const Color(0xFF10B981), const Color(0xFF0F172A), 4);
      }
    }
    
    if (activeDragType == 'dividend') {
      _drawRoundedRect(canvas, -280, matY + 300, 160, 140, 16, const Color(0x333B82F6), const Color(0xFF3B82F6), 2);
    }
    if (activeDragType == 'divisor') {
      _drawRoundedRect(canvas, 120, matY + 300, 160, 140, 16, const Color(0x3310B981), const Color(0xFF10B981), 2);
    }

    if (scenario == 1 && step == 3 && !rayFired) {
      _drawSpeechBubble(canvas, cx + 200, rightPanY - 100, t('hint_scen1'));
    }

    if (isCompleted && rightPanCount == targetCount && angle.abs() < 0.01) {
      _drawRoundedRect(canvas, cx + 180, rightPanY - 300, 120, 60, 10, const Color(0xFF1E293B), const Color(0xFF475569), 3);
      _drawTextOutline(canvas, _fmt(targetCount), cx + 225, rightPanY - 270, 36, Colors.white, Colors.transparent, 0);
      _drawTextOutline(canvas, "✓", cx + 280, rightPanY - 265, 50, const Color(0xFF10B981), Colors.transparent, 0);
    }
  }

  void _drawRayGun(Canvas canvas) {
    double cx = matX + 900; double cy = matY + 50;
    
    _drawRoundedRect(canvas, cx - 20, cy + 130, 220, 130, 16, const Color(0xFF0F172A), const Color(0xFF475569), 3);
    _drawTextOutline(canvas, t('lbl_eq_ray'), cx + 90, cy + 145, 14, const Color(0xFF94A3B8), Colors.transparent, 0);
    
    canvas.save();
    canvas.translate(cx, cy);
    _drawRoundedRect(canvas, 160, 20, 40, 80, 10, const Color(0xFF3B82F6), const Color(0xFF1E3A8A), 3);
    _drawRoundedRect(canvas, 20, 0, 160, 50, 20, const Color(0xFFCBD5E1), const Color(0xFF475569), 3);
    _drawRoundedRect(canvas, 100, 5, 60, 40, 10, const Color(0xFF3B82F6), const Color(0xFF1E3A8A), 3);
    canvas.drawCircle(const Offset(130, 25), 12, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(130, 25), 12, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1);
    _drawRoundedRect(canvas, -10, 10, 40, 30, 8, const Color(0xFF64748B), const Color(0xFF475569), 3);
    canvas.restore();

    Color bg10 = rayMultiplier == 10 ? const Color(0xFF3B82F6) : const Color(0xFF1E293B);
    Color txt10 = rayMultiplier == 10 ? Colors.white : const Color(0xFFCBD5E1);
    _drawRoundedRect(canvas, matX + 900, matY + 200, 50, 40, 8, bg10, const Color(0xFF64748B), 2);
    _drawTextOutline(canvas, "10x", matX + 925, matY + 220, 16, txt10, Colors.transparent, 0);

    Color bg100 = rayMultiplier == 100 ? const Color(0xFF3B82F6) : const Color(0xFF1E293B);
    Color txt100 = rayMultiplier == 100 ? Colors.white : const Color(0xFFCBD5E1);
    _drawRoundedRect(canvas, matX + 960, matY + 200, 50, 40, 8, bg100, const Color(0xFF64748B), 2);
    _drawTextOutline(canvas, "100x", matX + 985, matY + 220, 16, txt100, Colors.transparent, 0);

    Color bg1000 = rayMultiplier == 1000 ? const Color(0xFF3B82F6) : const Color(0xFF1E293B);
    Color txt1000 = rayMultiplier == 1000 ? Colors.white : const Color(0xFFCBD5E1);
    _drawRoundedRect(canvas, matX + 1020, matY + 200, 60, 40, 8, bg1000, const Color(0xFF64748B), 2);
    _drawTextOutline(canvas, "1000x", matX + 1050, matY + 220, 16, txt1000, Colors.transparent, 0);

    Color bgFire = (rayMultiplier != null && !rayFired) ? const Color(0xFFF59E0B) : const Color(0xFF334155);
    if (rayAnim > 0) bgFire = Colors.white;
    _drawRoundedRect(canvas, matX + 900, matY + 150, 180, 40, 8, bgFire, const Color(0xFF475569), 2);
    _drawTextOutline(canvas, t('lbl_fire'), matX + 990, matY + 170, 16, Colors.white, Colors.transparent, 0);

    if (rayAnim > 0) {
      canvas.save();
      double alpha = sin(rayAnim * pi * 4).abs().clamp(0.0, 1.0);
      canvas.saveLayer(Rect.fromLTWH(-5000, -5000, 10000, 10000), Paint()..color = Colors.white.withOpacity(alpha));
      
      canvas.drawLine(Offset(cx - 10, cy + 25), Offset(0, matY + 300), Paint()..color = const Color(0xFF60A5FA)..strokeWidth = 8);
      canvas.drawLine(Offset(cx - 10, cy + 25), Offset(0, matY + 300), Paint()..color = Colors.white..strokeWidth = 4);
      
      canvas.drawCircle(Offset(0, matY + 300), 40, Paint()..color = const Color(0x80FFFFFF));
      
      canvas.restore();
      canvas.restore();
    }
  }

  void _drawDispenserAndMath(Canvas canvas) {
    double cx = matX + 850; double cy = matY + 180;
    
    if (scenario == 2 && rayFired) {
      _drawRoundedRect(canvas, cx, cy - 40, 330, 200, 16, const Color(0xFF1E293B), const Color(0xFF475569), 3);
      _drawTextOutline(canvas, t('lbl_dispenser'), cx + 165, cy - 15, 18, const Color(0xFF94A3B8), Colors.transparent, 0);
      
      _drawRoundedRect(canvas, cx + 105, cy + 20, 120, 40, 8, const Color(0xFF0F172A), const Color(0xFF475569), 2);
      _drawTextOutline(canvas, rightPanCount.toInt().toString().padLeft(2, '0'), cx + 165, cy + 40, 24, const Color(0xFF10B981), Colors.transparent, 0);

      _drawRoundedRect(canvas, matX + 900, matY + 350, 60, 40, 8, const Color(0xFF10B981), const Color(0xFF047857), 2);
      _drawTextOutline(canvas, "+1", matX + 930, matY + 370, 18, Colors.white, Colors.transparent, 0);
      
      _drawRoundedRect(canvas, matX + 970, matY + 350, 60, 40, 8, const Color(0xFF3B82F6), const Color(0xFF1D4ED8), 2);
      _drawTextOutline(canvas, "+10", matX + 1000, matY + 370, 18, Colors.white, Colors.transparent, 0);
    }
    
    if (scenario >= 3 && rayFired) {
      _drawRoundedRect(canvas, cx, cy - 40, 330, 450, 16, const Color(0xFF0F172A), const Color(0xFF475569), 3);
      _drawTextOutline(canvas, t('lbl_long_div'), cx + 165, cy - 15, 18, const Color(0xFF94A3B8), Colors.transparent, 0);
      
      Map<int, List<Map<String, dynamic>>> mathPaths = {
        1: [], 2: [],
        3: [
          { 'q': "       ", 'lines': ["13 ) 46.8"] },
          { 'q': "  3.   ", 'lines': ["13 ) 46.8", "   - 39  ", "   ----  ", "      7 8"] },
          { 'q': "  3.6  ", 'lines': ["13 ) 46.8", "   - 39  ", "   ----  ", "      7 8", "    - 7 8", "    -----", "        0"] }
        ],
        4: [
          { 'q': "        ", 'lines': ["25 ) 126.0"] },
          { 'q': "  5.    ", 'lines': ["25 ) 126.0", "   - 125  ", "   -----  ", "       1 0"] },
          { 'q': "  5.04  ", 'lines': ["25 ) 126.0", "   - 125  ", "   -----  ", "       1 00", "     - 1 00", "     ------", "          0"] }
        ],
        5: [
          { 'q': "         ", 'lines': ["152 ) 572.8"] },
          { 'q': "  3.     ", 'lines': ["152 ) 572.8", "    - 456  ", "    -------", "      116 8"] },
          { 'q': "  3.7    ", 'lines': ["152 ) 572.8", "    - 456  ", "    -------", "      116 8", "    - 106 4", "    -------", "       10 40"] },
          { 'q': "  3.76   ", 'lines': ["152 ) 572.8", "    - 456  ", "    -------", "      116 8", "    - 106 4", "    -------", "       10 40", "     - 10 40", "     -------", "           0"] }
        ]
      };

      var path = mathPaths[scenario];
      if (path != null && path.isNotEmpty) {
        var frame = path[min(mathStep, path.length - 1)];
        _drawTextOutline(canvas, frame['q'], cx + 40, cy + 40, 20, const Color(0xFF38BDF8), Colors.transparent, 0, align: TextAlign.left);
        canvas.drawLine(Offset(cx + 90, cy + 50), Offset(cx + 290, cy + 50), Paint()..color = Colors.white..strokeWidth = 2);
        
        List<String> lines = frame['lines'];
        for (int i = 0; i < lines.length; i++) {
          String line = lines[i];
          double ly = cy + 80 + i * 26;
          Color col = Colors.white;
          if (line.contains('-') && !line.contains(')')) col = const Color(0xFF94A3B8);
          else if (line.trim().startsWith('-')) col = const Color(0xFFF87171);
          
          TextPainter tp = TextPainter(text: TextSpan(text: line, style: TextStyle(color: col, fontSize: 20, fontFamily: 'monospace', fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr, textAlign: TextAlign.left);
          tp.layout();
          tp.paint(canvas, Offset(cx + 40, ly - tp.height / 2));
        }

        if (mathStep < maxMath) {
          _drawRoundedRect(canvas, matX + 925, matY + 560, 180, 40, 8, const Color(0xFF3B82F6), const Color(0xFF1D4ED8), 2);
          _drawTextOutline(canvas, t('lbl_next_step'), matX + 1015, matY + 580, 16, Colors.white, Colors.transparent, 0);
        } else if (mathStep == maxMath && !isCompleted) {
          _drawTextOutline(canvas, t('lbl_solved'), matX + 1015, matY + 580, 20, const Color(0xFF10B981), Colors.transparent, 0);
        }
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
    'shutterTitle': "The Equivalence Engine: Mastering Decimal Division", 'appTitle': "The Equivalence Engine", 'appSubtitle': "Class 7 • ANOTHER PEEK BEYOND THE POINT", 'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done",
    'lbl_objective': "Objective / Observation:", 'obsLbl': "Observation:", 'learnLbl': "Learning:", 'summaryTitle': "Goal Reached!", 'checkAnswer': "Check Answer",
    'hudNext': "Next Step", 'err_scale': "Balance the scale first!", 'err_ray': "Choose the correct magnification!", 'err_math': "Complete the math division!", 'err_block': "Place blocks in correct pans!",
    'finalSuccessTitle': "Activity Completed!", 'finalSuccessDesc': "You have successfully mastered Division by Decimals using Equivalence.",
    'reset': "Reset", 'close': "Close", 'guideNextScenario': "This scenario is completed! Please open the sidebar menu to select and try the next scenario.",
    
    'lbl_inventory': "INVENTORY", 'lbl_eq_scale': "Equivalence Scale", 'lbl_eq_ray': "EQUIVALENCE RAY", 'lbl_fire': "FIRE", 'lbl_dispenser': "DISPENSER", 'lbl_long_div': "LONG DIVISION", 'lbl_next_step': "NEXT STEP", 'lbl_solved': "SOLVED!",
    'err_hint_smaller': "Hint: Try a smaller magnification!",
    'err_hint_smallest': "Hint: Is that the smallest magnification needed to make it a whole number?",
    'hint_scen1': "The divisor 1.5 is a decimal.\nLet's make it a whole number!",

    's1_title': "1. The 10x Magnification (4.5 ÷ 1.5)",
    's1_obj': "To solve the decimal division problem <b>4.5 ÷ 1.5</b> by transforming it into an equivalent problem with a whole number divisor.",
    's1_hud1': "DRAG the '4.5' block to the left pan.",
    's1_hud2': "DRAG the '1.5' block to the right pan.",
    's1_hud3': "CLICK '10x' on the Equivalence Ray.",
    's1_hud4': "CLICK 'FIRE' to magnify both blocks.",
    's1_hud5': "DRAG more '15' blocks to the right pan to balance.",
    's1_step1_task': "<b>DRAG</b> the blue block labelled <b>4.5</b> from the inventory and <b>DROP</b> it onto the left pan of the Equivalence Scale.",
    's1_step1_obs': "The <b>4.5</b> block is placed on the left pan. The scale becomes unbalanced.",
    's1_step1_learn': "The left pan holds the <b>dividend</b> (the number being divided).",
    's1_step2_task': "<b>DRAG</b> the green block labelled <b>1.5</b> from the inventory and <b>DROP</b> it onto the right pan.",
    's1_step2_obs': "The right side of the scale rises, but it is not enough to perfectly balance the scale.",
    's1_step2_learn': "The right pan holds the <b>divisor</b> (the number we divide by). Notice it is a decimal. Let us make it a whole number!",
    's1_step3_task': "Since the divisor (1.5) has exactly one decimal place, <b>CLICK</b> the <b>'10x'</b> button on the Equivalence Ray's control panel.",
    's1_step3_obs': "The Equivalence Ray is activated and set to exactly <b>10x</b> magnification.",
    's1_step3_learn': "Multiplying 1.5 by 10 will shift the decimal point one place to the right, giving us the whole number 15.",
    's1_step4_task': "<b>CLICK</b> the <b>'FIRE'</b> button on the Ray. It will hit both pans simultaneously.",
    's1_step4_obs': "The 4.5 block morphs into a <b>45</b> block. The 1.5 block morphs into a <b>15</b> block. The balance of the scale does not move at all.",
    's1_step4_learn': "Multiplying both the dividend and the divisor by the same amount keeps their ratio perfectly equivalent. <b>4.5 ÷ 1.5</b> is exactly the same as <b>45 ÷ 15</b>.",
    's1_step5_task': "<b>DRAG</b> more <b>15</b> blocks from the inventory and <b>DROP</b> them onto the right pan until the scale is perfectly balanced.",
    's1_step5_obs': "The scale balances perfectly when there are a total of three <b>15</b> blocks on the right pan.",
    's1_step5_learn': "You balanced 45 with three 15s. This means 45 ÷ 15 = 3. Because we used the Equivalence Ray, we know that the original problem <b>4.5 ÷ 1.5</b> also equals <b>3</b>. You made the divisor a whole number to make it much easier to solve!",
    's1_final': "Because we used the Equivalence Ray, we know that the original problem 4.5 ÷ 1.5 also equals 3. You made the divisor a whole number to make it easier to solve!",

    's2_title': "2. The 100x Magnification (9.36 ÷ 0.12)",
    's2_obj': "To solve the decimal division problem <b>9.36 ÷ 0.12</b> by transforming it into an equivalent problem.",
    's2_hud1': "Place the '9.36' block on the left and '0.12' on the right.",
    's2_hud2': "Select '100x' on the Equivalence Ray.",
    's2_hud3': "CLICK 'FIRE' to magnify both sides.",
    's2_hud4': "Use Dispenser to add blocks until balanced.",
    's2_step1_task': "<b>DRAG</b> the blue block labelled <b>9.36</b> to the left pan and the green block labelled <b>0.12</b> to the right pan of the Equivalence Scale.", 
    's2_step1_obs': "The blocks are placed on the scale, which is deeply unbalanced.", 
    's2_step1_learn': "The left pan with 9.36 is much heavier and lower than the right pan with 0.12.",
    's2_step2_task': "The divisor is 0.12. It has exactly two decimal places. <b>CLICK</b> the <b>'100x'</b> button on the Equivalence Ray tool.", 
    's2_step2_obs': "The ray is activated and set to exactly <b>100x</b> magnification.", 
    's2_step2_learn': "We must multiply by 100 to shift the decimal two places, making 0.12 a perfect whole number.",
    's2_step3_task': "<b>CLICK</b> the <b>'FIRE'</b> button on the Equivalence Ray to apply the magnification to both sides simultaneously.", 
    's2_step3_obs': "The 9.36 block morphs into a <b>936</b> block. The 0.12 block morphs into a <b>12</b> block. The scale remains perfectly unbalanced in the same position.", 
    's2_step3_learn': "The problem is now <b>936 ÷ 12</b>. The scale's position remains exactly the same, showing they are equivalent.",
    's2_step4_task': "A block dispenser is now available. <b>CLICK</b> the <b>'+10'</b> and <b>'+1'</b> buttons on the dispenser to repeatedly add <b>12</b> blocks to the right pan until the scale balances.", 
    's2_step4_obs': "Each click adds a 12 block to the pan. The scale balances perfectly when the counter hits <b>78</b>.", 
    's2_step4_learn': "The scale balances when the counter on the dispenser shows 78. This means 936 ÷ 12 = 78.",
    's2_final': "Perfect! 936 ÷ 12 = 78. This means the equivalent problem, 9.36 ÷ 0.12, also equals 78. You solved it by multiplying both numbers by 100 to make the divisor a whole number.",

    's3_title': "3. The Mismatched Decimals (4.68 ÷ 1.3)",
    's3_obj': "To solve <b>4.68 ÷ 1.3</b>, where the number of decimal places in the dividend and divisor is different.",
    's3_hud1': "Place the blocks: 4.68 (left) and 1.3 (right).",
    's3_hud2': "Select the correct multiplier to make the divisor whole.",
    's3_hud3': "Apply the ray to the scale.",
    's3_hud4': "Solve the long division.",
    's3_step1_task': "<b>DRAG</b> the <b>4.68</b> block to the left pan and the <b>1.3</b> block to the right pan.", 
    's3_step1_obs': "The blocks are placed, and the scale is heavily unbalanced.", 
    's3_step1_learn': "The left pan with the dividend is lower.",
    's3_step2_task': "Look closely at the divisor: 1.3. How many decimal places does it have? To make it a whole number, which magnification level do you need? <b>CLICK</b> the correct button on the Equivalence Ray.", 
    's3_step2_obs': "The user clicks the <b>'10x'</b> button to activate it.", 
    's3_step2_learn': "The 10x button is the correct choice because 1.3 only requires shifting the decimal one place.",
    's3_step3_task': "<b>CLICK 'FIRE'</b> to apply the 10x ray to the entire scale.", 
    's3_step3_obs': "The 4.68 block morphs into <b>46.8</b>. The 1.3 block morphs into exactly <b>13</b>.", 
    's3_step3_learn': "The scale's physical position is unchanged. The new, much easier problem is <b>46.8 ÷ 13</b>.",
    's3_step4_task': "Now, find how many 13 blocks balance a 46.8 block. A calculator-like interface appears for the division 46.8 ÷ 13. <b>CLICK 'Next Step'</b> repeatedly to solve it completely.", 
    's3_step4_obs': "The long division is animated step-by-step. The key insight is that the division now has a whole number divisor. The final result <b>3.6</b> is displayed.", 
    's3_step4_learn': "The system automatically shows that <b>3.6</b> blocks perfectly balance the 46.8 block.",
    's3_final': "Excellent! 46.8 ÷ 13 = 3.6. So, 4.68 ÷ 1.3 is also 3.6. The key was to multiply by 10, just enough to make the divisor a whole number.",

    's4_title': "4. The Fuel Efficiency Challenge (12.6 ÷ 2.5)",
    's4_obj': "Solve the real-world decimal division problem <b>12.6 ÷ 2.5</b>. You are on your own, but visual hints are available.",
    's4_hud1': "Place 12.6 on the left, 2.5 on the right.",
    's4_hud2': "Select '10x' and FIRE the ray.",
    's4_hud3': "Solve 126 ÷ 25 using the Next Step button.",
    's4_step1_task': "The problem is 12.6 ÷ 2.5. <b>DRAG</b> and place the correct blocks onto the Equivalence Scale.", 
    's4_step1_obs': "The blocks are placed correctly on the left and right pans.", 
    's4_step1_learn': "Good start. Now focus purely on the divisor.",
    's4_step2_task': "Make the divisor a whole number. <b>CLICK</b> the correct magnification on the Equivalence Ray and <b>FIRE</b> it at the scale.", 
    's4_step2_obs': "The problem visually becomes <b>126 ÷ 25</b>.", 
    's4_step2_learn': "You correctly determined that multiplying by 10 perfectly makes the divisor a whole number.",
    's4_step3_task': "Now solve 126 ÷ 25. <b>CLICK 'Next Step'</b> on the provided division interface to easily find the answer.", 
    's4_step3_obs': "The long division seamlessly completes. The final answer is <b>5.04</b>.", 
    's4_step3_learn': "Great job completing the mathematical calculation.",
    's4_final': "Correct! 126 ÷ 25 = 5.04. Therefore, 12.6 ÷ 2.5 = 5.04.",

    's5_title': "5. The Advanced Recipe Challenge (5.728 ÷ 1.52)",
    's5_obj': "Solve the advanced decimal division problem <b>5.728 ÷ 1.52</b>.",
    's5_hud1': "Set up 5.728 ÷ 1.52 on the scale.",
    's5_hud2': "Select '100x' and FIRE the ray.",
    's5_hud3': "Solve 572.8 ÷ 152.",
    's5_step1_task': "Set up the exact problem 5.728 ÷ 1.52 on the Equivalence Scale by dragging the blocks.", 
    's5_step1_obs': "The scale is set up perfectly correctly.", 
    's5_step1_learn': "Identify the target divisor: 1.52.",
    's5_step2_task': "What magnification is needed to make the divisor (1.52) a whole number? <b>SELECT</b> it and <b>FIRE</b> the ray.", 
    's5_step2_obs': "The problem beautifully transforms into <b>572.8 ÷ 152</b>.", 
    's5_step2_learn': "Multiplying by 100 perfectly clears the two decimal places in the divisor.",
    's5_step3_task': "Solve the newly formed problem: 572.8 ÷ 152. <b>CLICK 'Next Step'</b> on the division interface to find the final quotient.", 
    's5_step3_obs': "The long division mechanically completes. The precise answer is <b>3.76</b>.", 
    's5_step3_learn': "Excellent mathematical work!",
    's5_final': "Perfect! 572.8 ÷ 152 = 3.76."
  },
  'hi': {
    'shutterTitle': "समतुल्यता इंजन: दशमलव विभाजन में महारत", 'appTitle': "समतुल्यता इंजन", 'appSubtitle': "कक्षा 7 • ANOTHER PEEK BEYOND THE POINT", 'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण",
    'lbl_objective': "उद्देश्य / अवलोकन:", 'obsLbl': "अवलोकन:", 'learnLbl': "सीख:", 'summaryTitle': "लक्ष्य प्राप्त हुआ!", 'checkAnswer': "उत्तर जांचें",
    'hudNext': "अगला कदम", 'err_scale': "पहले तराजू को संतुलित करें!", 'err_ray': "सही आवर्धन चुनें!", 'err_math': "गणित विभाजन पूरा करें!", 'err_block': "ब्लॉकों को सही पलड़ों में रखें!",
    'finalSuccessTitle': "गतिविधि पूरी हुई!", 'finalSuccessDesc': "आपने समतुल्यता का उपयोग करके दशमलव विभाजन में सफलतापूर्वक महारत हासिल कर ली है।",
    'reset': "रीसेट", 'close': "बंद करें", 'guideNextScenario': "यह परिदृश्य पूरा हो गया है! कृपया अगला परिदृश्य चुनने और आजमाने के लिए साइडबार मेनू खोलें।",
    
    'lbl_inventory': "इन्वेंटरी", 'lbl_eq_scale': "समतुल्य तराजू", 'lbl_eq_ray': "इक्विवेलेंस रे", 'lbl_fire': "FIRE", 'lbl_dispenser': "डिस्पेंसर", 'lbl_long_div': "दीर्घ विभाजन", 'lbl_next_step': "अगला कदम", 'lbl_solved': "हल हो गया!",
    'err_hint_smaller': "संकेत: छोटा आवर्धन आज़माएं!",
    'err_hint_smallest': "संकेत: क्या यह सबसे छोटा आवर्धन है जो इसे एक पूर्ण संख्या बनाने के लिए आवश्यक है?",
    'hint_scen1': "भाजक 1.5 एक दशमलव है।\nआइए इसे एक पूर्ण संख्या बनाएं!",

    's1_title': "1. 10x आवर्धन (4.5 ÷ 1.5)",
    's1_obj': "दशमलव विभाजन समस्या <b>4.5 ÷ 1.5</b> को पूर्ण संख्या वाले भाजक के साथ समतुल्य समस्या में बदलकर हल करना।",
    's1_hud1': "'4.5' ब्लॉक को बाएं पलड़े पर खींचें।",
    's1_hud2': "'1.5' ब्लॉक को दाएं पलड़े पर खींचें।",
    's1_hud3': "रे पर '10x' पर क्लिक करें।",
    's1_hud4': "दोनों ब्लॉकों को बड़ा करने के लिए 'FIRE' पर क्लिक करें।",
    's1_hud5': "संतुलित करने के लिए और '15' ब्लॉक खींचें।",
    's1_step1_task': "इन्वेंट्री से <b>4.5</b> लेबल वाले नीले ब्लॉक को <b>खींचें</b> और समतुल्यता तराजू के बाएं पलड़े पर <b>छोड़ दें</b>।",
    's1_step1_obs': "<b>4.5</b> ब्लॉक बाएं पलड़े पर है। तराजू असंतुलित हो जाता है।",
    's1_step1_learn': "बायां पलड़ा <b>भाज्य</b> (वह संख्या जिसे विभाजित किया जा रहा है) रखता है।",
    's1_step2_task': "इन्वेंट्री से <b>1.5</b> लेबल वाले हरे ब्लॉक को <b>खींचें</b> और उसे दाएं पलड़े पर <b>छोड़ दें</b>।",
    's1_step2_obs': "तराजू का दायां हिस्सा ऊपर उठता है, लेकिन तराजू को पूरी तरह से संतुलित करने के लिए पर्याप्त नहीं है।",
    's1_step2_learn': "दायां पलड़ा <b>भाजक</b> (जिस संख्या से हम विभाजित करते हैं) रखता है। ध्यान दें कि यह एक दशमलव है। आइए इसे पूर्ण संख्या बनाएं!",
    's1_step3_task': "चूंकि भाजक (1.5) में ठीक एक दशमलव स्थान है, इसलिए किरण के नियंत्रण कक्ष पर <b>'10x'</b> बटन पर <b>क्लिक करें</b>।",
    's1_step3_obs': "इक्विवेलेंस रे सक्रिय हो जाती है और ठीक <b>10x</b> आवर्धन पर सेट हो जाती है।",
    's1_step3_learn': "1.5 को 10 से गुणा करने पर दशमलव बिंदु एक स्थान दाईं ओर खिसक जाएगा, जिससे हमें पूर्ण संख्या 15 प्राप्त होगी।",
    's1_step4_task': "किरण पर <b>'FIRE'</b> बटन पर <b>क्लिक करें</b>। यह एक साथ दोनों पलड़ों से टकराएगी।",
    's1_step4_obs': "4.5 ब्लॉक <b>45</b> ब्लॉक में बदल जाता है। 1.5 ब्लॉक <b>15</b> ब्लॉक में बदल जाता है। तराजू का संतुलन बिल्कुल नहीं हिलता है।",
    's1_step4_learn': "भाज्य और भाजक दोनों को समान मात्रा से गुणा करने पर उनका अनुपात पूरी तरह से समतुल्य रहता है। <b>4.5 ÷ 1.5</b> बिल्कुल <b>45 ÷ 15</b> के समान है।",
    's1_step5_task': "इन्वेंट्री से अधिक <b>15</b> ब्लॉक <b>खींचें</b> और उन्हें दाएं पलड़े पर तब तक <b>छोड़ें</b> जब तक कि तराजू पूरी तरह से संतुलित न हो जाए।",
    's1_step5_obs': "तराजू तब पूरी तरह से संतुलित होता है जब दाएं पलड़े पर कुल तीन <b>15</b> ब्लॉक होते हैं।",
    's1_step5_learn': "आपने तीन 15 के साथ 45 को संतुलित किया। इसका मतलब है 45 ÷ 15 = 3। चूंकि हमने इक्विवेलेंस रे का उपयोग किया है, इसलिए हम जानते हैं कि मूल समस्या <b>4.5 ÷ 1.5</b> भी <b>3</b> के बराबर है। आपने हल करना बहुत आसान बनाने के लिए भाजक को एक पूर्ण संख्या बना दिया!",
    's1_final': "चूंकि हमने इक्विवेलेंस रे का उपयोग किया है, इसलिए हम जानते हैं कि मूल समस्या 4.5 ÷ 1.5 भी 3 के बराबर है। आपने हल करना आसान बनाने के लिए भाजक को एक पूर्ण संख्या बना दिया!",

    's2_title': "2. 100x आवर्धन (9.36 ÷ 0.12)",
    's2_obj': "दशमलव विभाजन समस्या <b>9.36 ÷ 0.12</b> को समतुल्य समस्या में बदलकर हल करना।",
    's2_hud1': "बाएं पर 9.36 और दाएं पर 0.12 रखें।",
    's2_hud2': "गुणक चुनें और FIRE करें।",
    's2_hud3': "रे को लागू करें।",
    's2_hud4': "संतुलित करने के लिए डिस्पेंसर का उपयोग करें।",
    's2_step1_task': "<b>9.36</b> लेबल वाले नीले ब्लॉक को बाएं पलड़े पर और <b>0.12</b> लेबल वाले हरे ब्लॉक को समतुल्यता तराजू के दाएं पलड़े पर <b>खींचें</b>।", 
    's2_step1_obs': "ब्लॉक तराजू पर रखे गए हैं, जो गहराई से असंतुलित है।", 
    's2_step1_learn': "9.36 वाला बायां पलड़ा 0.12 वाले दाएं पलड़े से बहुत भारी और नीचे है।",
    's2_step2_task': "भाजक 0.12 है। इसमें ठीक दो दशमलव स्थान हैं। इक्विवेलेंस रे टूल पर <b>'100x'</b> बटन पर <b>क्लिक करें</b>।", 
    's2_step2_obs': "किरण सक्रिय हो जाती है और ठीक <b>100x</b> आवर्धन पर सेट हो जाती है।", 
    's2_step2_learn': "हमें दशमलव को दो स्थान खिसकाने के लिए 100 से गुणा करना होगा, जिससे 0.12 एक पूर्ण पूर्ण संख्या बन जाए।",
    's2_step3_task': "दोनों पक्षों पर एक साथ आवर्धन लागू करने के लिए इक्विवेलेंस रे पर <b>'FIRE'</b> बटन पर <b>क्लिक करें</b>।", 
    's2_step3_obs': "9.36 ब्लॉक <b>936</b> ब्लॉक में बदल जाता है। 0.12 ब्लॉक <b>12</b> ब्लॉक में बदल जाता है। तराजू उसी स्थिति में पूरी तरह से असंतुलित रहता है।", 
    's2_step3_learn': "समस्या अब <b>936 ÷ 12</b> है। तराजू की स्थिति बिल्कुल समान रहती है, जो दर्शाती है कि वे समतुल्य हैं।",
    's2_step4_task': "एक ब्लॉक डिस्पेंसर अब उपलब्ध है। जब तक तराजू संतुलित न हो जाए, दाएं पलड़े में <b>12</b> ब्लॉक बार-बार जोड़ने के लिए डिस्पेंसर पर <b>'+10'</b> और <b>'+1'</b> बटन पर <b>क्लिक करें</b>।", 
    's2_step4_obs': "प्रत्येक क्लिक पलड़े में एक 12 ब्लॉक जोड़ता है। काउंटर <b>78</b> पर पहुंचने पर तराजू पूरी तरह से संतुलित हो जाता है।", 
    's2_step4_learn': "तराजू तब संतुलित होता है जब डिस्पेंसर पर काउंटर 78 दिखाता है। इसका मतलब है 936 ÷ 12 = 78।",
    's2_final': "बिल्कुल सही! 936 ÷ 12 = 78। इसका मतलब है कि समतुल्य समस्या, 9.36 ÷ 0.12, भी 78 के बराबर है। आपने भाजक को पूर्ण संख्या बनाने के लिए दोनों संख्याओं को 100 से गुणा करके इसे हल किया।",

    's3_title': "3. बेमेल दशमलव (4.68 ÷ 1.3)",
    's3_obj': "<b>4.68 ÷ 1.3</b> को हल करना, जहां भाज्य और भाजक में दशमलव स्थानों की संख्या भिन्न है।",
    's3_hud1': "ब्लॉक रखें: 4.68 (बाएं) और 1.3 (दाएं)।",
    's3_hud2': "भाजक को पूर्ण बनाने के लिए गुणक चुनें।",
    's3_hud3': "रे लागू करें।",
    's3_hud4': "गणित हल करें।",
    's3_step1_task': "<b>4.68</b> ब्लॉक को बाएं पलड़े पर और <b>1.3</b> ब्लॉक को दाएं पलड़े पर <b>खींचें</b>।", 
    's3_step1_obs': "ब्लॉक रखे गए हैं, और तराजू भारी असंतुलित है।", 
    's3_step1_learn': "भाज्य वाला बायां पलड़ा नीचे है।",
    's3_step2_task': "भाजक को करीब से देखें: 1.3। इसमें कितने दशमलव स्थान हैं? इसे एक पूर्ण संख्या बनाने के लिए, आपको किस आवर्धन स्तर की आवश्यकता है? इक्विवेलेंस रे पर सही बटन पर <b>क्लिक करें</b>।", 
    's3_step2_obs': "उपयोगकर्ता इसे सक्रिय करने के लिए <b>'10x'</b> बटन पर क्लिक करता है।", 
    's3_step2_learn': "10x बटन सही विकल्प है क्योंकि 1.3 को दशमलव को केवल एक स्थान खिसकाने की आवश्यकता है।",
    's3_step3_task': "संपूर्ण तराजू पर 10x किरण लागू करने के लिए <b>'FIRE' क्लिक करें</b>।", 
    's3_step3_obs': "4.68 ब्लॉक <b>46.8</b> में बदल जाता है। 1.3 ब्लॉक ठीक <b>13</b> में बदल जाता है।", 
    's3_step3_learn': "तराजू की भौतिक स्थिति अपरिवर्तित है। नई, बहुत आसान समस्या <b>46.8 ÷ 13</b> है।",
    's3_step4_task': "अब, ज्ञात करें कि कितने 13 ब्लॉक 46.8 ब्लॉक को संतुलित करते हैं। विभाजन 46.8 ÷ 13 के लिए एक कैलकुलेटर जैसा इंटरफ़ेस दिखाई देता है। इसे पूरी तरह से हल करने के लिए बार-बार <b>'अगला कदम' क्लिक करें</b>।", 
    's3_step4_obs': "दीर्घ विभाजन कदम-दर-कदम एनिमेटेड है। मुख्य अंतर्दृष्टि यह है कि विभाजन में अब पूर्ण संख्या भाजक है। अंतिम परिणाम <b>3.6</b> प्रदर्शित होता है।", 
    's3_step4_learn': "सिस्टम स्वचालित रूप से दिखाता है कि <b>3.6</b> ब्लॉक 46.8 ब्लॉक को पूरी तरह से संतुलित करते हैं।",
    's3_final': "बहुत बढ़िया! 46.8 ÷ 13 = 3.6। तो, 4.68 ÷ 1.3 भी 3.6 है। मुख्य बात यह थी कि 10 से गुणा किया जाए, जो भाजक को पूर्ण संख्या बनाने के लिए पर्याप्त है।",

    's4_title': "4. ईंधन दक्षता चुनौती (12.6 ÷ 2.5)",
    's4_obj': "वास्तविक दुनिया की दशमलव विभाजन समस्या <b>12.6 ÷ 2.5</b> को हल करें। आप अपने दम पर हैं, लेकिन दृश्य संकेत उपलब्ध हैं।",
    's4_hud1': "बाएं पर 12.6, दाएं पर 2.5 रखें।",
    's4_hud2': "'10x' चुनें और रे FIRE करें।",
    's4_hud3': "'अगला कदम' का उपयोग करके 126 ÷ 25 हल करें।",
    's4_step1_task': "समस्या 12.6 ÷ 2.5 है। सही ब्लॉकों को <b>खींचें</b> और समतुल्यता तराजू पर रखें।", 
    's4_step1_obs': "ब्लॉक सही ढंग से बाएं और दाएं पलड़ों पर रखे गए हैं।", 
    's4_step1_learn': "अच्छी शुरुआत। अब पूरी तरह से भाजक पर ध्यान दें।",
    's4_step2_task': "भाजक को एक पूर्ण संख्या बनाएं। इक्विवेलेंस रे पर सही आवर्धन <b>क्लिक करें</b> और इसे तराजू पर <b>FIRE</b> करें।", 
    's4_step2_obs': "समस्या नेत्रहीन रूप से <b>126 ÷ 25</b> बन जाती है।", 
    's4_step2_learn': "आपने सही ढंग से निर्धारित किया है कि 10 से गुणा करने पर भाजक पूरी तरह से एक पूर्ण संख्या बन जाता है।",
    's4_step3_task': "अब 126 ÷ 25 को हल करें। उत्तर आसानी से खोजने के लिए दिए गए विभाजन इंटरफ़ेस पर <b>'अगला कदम' क्लिक करें</b>।", 
    's4_step3_obs': "दीर्घ विभाजन निर्बाध रूप से पूरा होता है। अंतिम उत्तर <b>5.04</b> है।", 
    's4_step3_learn': "गणितीय गणना पूरी करने में बहुत बढ़िया काम किया।",
    's4_final': "सही! 126 ÷ 25 = 5.04। इसलिए, 12.6 ÷ 2.5 = 5.04।",

    's5_title': "5. उन्नत पकाने की विधि चुनौती (5.728 ÷ 1.52)",
    's5_obj': "उन्नत दशमलव विभाजन समस्या <b>5.728 ÷ 1.52</b> को हल करें।",
    's5_hud1': "तराजू पर 5.728 ÷ 1.52 सेट करें।",
    's5_hud2': "'100x' चुनें और रे FIRE करें।",
    's5_hud3': "572.8 ÷ 152 हल करें।",
    's5_step1_task': "ब्लॉकों को खींचकर समतुल्यता तराजू पर सटीक समस्या 5.728 ÷ 1.52 सेट करें।", 
    's5_step1_obs': "तराजू बिल्कुल सही ढंग से सेट है।", 
    's5_step1_learn': "लक्ष्य भाजक की पहचान करें: 1.52।",
    's5_step2_task': "भाजक (1.52) को पूर्ण संख्या बनाने के लिए किस आवर्धन की आवश्यकता है? इसे <b>चुनें</b> और किरण को <b>FIRE</b> करें।", 
    's5_step2_obs': "समस्या खूबसूरती से <b>572.8 ÷ 152</b> में बदल जाती है।", 
    's5_step2_learn': "100 से गुणा करने पर भाजक में दो दशमलव स्थान पूरी तरह से साफ़ हो जाते हैं।",
    's5_step3_task': "नई बनी समस्या को हल करें: 572.8 ÷ 152। अंतिम भागफल खोजने के लिए विभाजन इंटरफ़ेस पर <b>'अगला कदम' क्लिक करें</b>।", 
    's5_step3_obs': "दीर्घ विभाजन यांत्रिक रूप से पूरा होता है। सटीक उत्तर <b>3.76</b> है।", 
    's5_step3_learn': "उत्कृष्ट गणितीय कार्य!",
    's5_final': "बिल्कुल सही! 572.8 ÷ 152 = 3.76।"
  },
  };