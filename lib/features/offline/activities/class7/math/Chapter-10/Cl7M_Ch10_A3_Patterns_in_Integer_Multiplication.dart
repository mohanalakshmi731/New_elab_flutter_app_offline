// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PatternsinIntegerMultiplicationApp());
}

class PatternsinIntegerMultiplicationApp extends StatelessWidget {
  const PatternsinIntegerMultiplicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | The Thermo-Pattern Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const PatternsinIntegerMultiplication(),
    );
  }
}

class PatternsinIntegerMultiplication extends StatefulWidget {
  const PatternsinIntegerMultiplication({super.key});

  @override
  State<PatternsinIntegerMultiplication> createState() =>
      _PatternsinIntegerMultiplicationState();
}

class _PatternsinIntegerMultiplicationState
    extends State<PatternsinIntegerMultiplication>
    with TickerProviderStateMixin {
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
  double _zoom = 0.9;
  double _panX = 0;
  double _panY = -20;
  double _baseZoom = 1.0;
  Offset _basePan = Offset.zero;
  Offset _baseFocalPoint = Offset.zero;

  // Floating Step State
  Offset _floatingStepPos = const Offset(20, 100);

  // Interaction State
  bool _toolDragging = false;
  String? _toolType;
  double _mouseX = 0;
  double _mouseY = 0;

  // Simulation State
  int _sliderVal = 4;
  int _dialVal = 3;
  double _tempCurrent = 0;
  List<Map<String, String>> _log = [];
  int? _predictionVal;

  // S4 State
  int _s4TargetTemp = 20;
  int _s4ErrorTimer = 0;

  // S5 State
  String? _s5Slot1;
  String? _s5Slot2;
  String? _s5DraggingToken;
  List<String> _s5RulesFound = [];
  bool _s5Shaking = false;
  double? _s3AnimTokenY;
  double? _s3ResultDropY;

  // Animation Controllers
  late AnimationController _ticker;
  bool _animating = false;
  double _animProgress = 0;
  int _animRepsTotal = 0;
  int _animRepsRemaining = 0;
  String _animType = 'none';
  bool _isUndo = false;
  double _startRepTemp = 0;
  double _endRepTemp = 0;

  int _machineErrorTimer = 0;
  String _machineErrorText = "";

  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  final TextEditingController _predictController = TextEditingController();

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

    _ticker = AnimationController(vsync: this, duration: const Duration(milliseconds: 30))
      ..addListener(_tick)
      ..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sidebarScrollController.dispose();
    _predictController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _tick() {
    setState(() {
      if (_machineErrorTimer > 0) _machineErrorTimer--;
      if (_s4ErrorTimer > 0) _s4ErrorTimer--;

      if (_animating) {
        _animProgress += 0.04;
        if (_animProgress <= 1.0) {
          _tempCurrent = _startRepTemp + (_endRepTemp - _startRepTemp) * _animProgress;
        } else {
          _tempCurrent = _endRepTemp;
          _animRepsRemaining--;
          if (_animRepsRemaining > 0) {
            _animProgress = 0;
            _startRepTemp = _tempCurrent;
            int targetChange = (_sliderVal == 0) ? 0 : _dialVal;
            if (_sliderVal < 0) targetChange = -_dialVal;
            _endRepTemp = _startRepTemp + targetChange;
            _playSound('tick');
          } else {
            _animating = false;
            _handleAnimationComplete();
          }
        }
      }

      if (_scenario == 5) {
        if (_s3AnimTokenY != null) {
          _s3AnimTokenY = _s3AnimTokenY! + 2.5;
          if (_s3AnimTokenY! >= -30) {
            _s3AnimTokenY = null;
            _s5Shaking = true;
            _playSound('weld');
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() {
                  _s5Shaking = false;
                  _playSound('success');
                  String res = (_s5Slot1 == _s5Slot2) ? '+' : '-';
                  String ruleStr = "($_s5Slot1) × ($_s5Slot2) = ($res)";
                  if (!_s5RulesFound.contains(ruleStr)) _s5RulesFound.add(ruleStr);

                  _s3ResultDropY = 140;
                });
              }
            });
          }
        }
        if (_s3ResultDropY != null) {
          _s3ResultDropY = _s3ResultDropY! + 5;
          if (_s3ResultDropY! > 250) {
            _s3ResultDropY = null;
            _s5Slot1 = null;
            _s5Slot2 = null;
            if (_s5RulesFound.length == 4) _checkScenarioSuccess();
          }
        }
      }
    });
  }

  void _playSound(String type) async {
    try {
      if (type == 'enter') {
        await _shutterPlayer.play(AssetSource('audio/class7/mixkit_2574.mp3'));
      } else if (type == 'error') {
        await _errorPlayer.play(AssetSource('audio/class7/mixkit_955.mp3'));
      } else if (type == 'success') {
        await _successPlayer.play(AssetSource('audio/class7/mixkit_2018.mp3'));
      } else if (type == 'pop' || type == 'tick' || type == 'snap') {
        await _clickPlayer.play(AssetSource('audio/class7/mixkit_2568.mp3'));
      } else if (type == 'weld') {
        await _fxPlayer.play(AssetSource('audio/class7/mixkit_2869.mp3'));
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
      _toolType = null;
      _zoom = 0.9;
      _panX = 0;
      _panY = -40;

      // Reset Simulations
      _animating = false;
      _log.clear();
      _predictionVal = null;
      _predictController.clear();
      _machineErrorTimer = 0;

      if (_scenario == 1) {
        _sliderVal = 4; _dialVal = 3; _tempCurrent = 0;
      } else if (_scenario == 2) {
        _sliderVal = 0; _dialVal = 3; _tempCurrent = 0;
        _log = [
          {'eq': '4 × 3 = 12', 'diff': ''},
          {'eq': '3 × 3 = 9', 'diff': '-3'},
          {'eq': '2 × 3 = 6', 'diff': '-3'},
          {'eq': '1 × 3 = 3', 'diff': '-3'},
          {'eq': '0 × 3 = 0', 'diff': '-3'}
        ];
      } else if (_scenario == 3) {
        _sliderVal = 3; _dialVal = -3; _tempCurrent = 0;
      } else if (_scenario == 4) {
        _sliderVal = 0; _dialVal = -4; _tempCurrent = 0; _s4TargetTemp = 20; _s4ErrorTimer = 0;
      } else if (_scenario == 5) {
        _s5Slot1 = null; _s5Slot2 = null; _s5RulesFound.clear(); _s5Shaking = false;
      }
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    int totalSteps = (_scenario == 4) ? 2 : ((_scenario == 5) ? 3 : 4);
    setState(() => _step = totalSteps);
    _playSound('success');
    _scrollToActiveStep();
    if (_scenario == 5) {
      setState(() => _showSuccessPopup = true);
    }
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

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    _baseFocalPoint = details.localFocalPoint;
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (_scenario >= 1 && _scenario <= 3) {
      double sY = -_sliderVal * 35 + 20;
      if (Rect.fromLTWH(-260 - 40, sY - 40, 80, 80).contains(pt)) {
        setState(() { _toolDragging = true; _toolType = 'slider'; });
        _playSound('tick'); return;
      }
      if (_scenario == 3 && _step == 0) {
        if (Rect.fromLTWH(10 - 40, 20 - 40, 80, 80).contains(pt)) {
          setState(() { _toolDragging = true; _toolType = 'dial'; });
          _playSound('tick'); return;
        }
      }
    } else if (_scenario == 4) {
      double thumbX = _sliderVal * 30;
      if (Rect.fromLTWH(thumbX - 30, 60 - 30, 60, 60).contains(pt)) {
        setState(() { _toolDragging = true; _toolType = 'slider'; });
        _playSound('tick'); return;
      }
    } else if (_scenario == 5) {
      const posTokX = -60.0; const posTokY = 160.0;
      const negTokX = 60.0; const negTokY = 160.0;

      if ((pt - const Offset(posTokX, posTokY)).distance < 40) {
        setState(() { _toolDragging = true; _toolType = 'token'; _s5DraggingToken = 'pos'; });
        _playSound('tick'); return;
      }
      if ((pt - const Offset(negTokX, negTokY)).distance < 40) {
        setState(() { _toolDragging = true; _toolType = 'token'; _s5DraggingToken = 'neg'; });
        _playSound('tick'); return;
      }

      if (Rect.fromLTWH(-100, -40, 60, 60).contains(pt) && _s5Slot1 != null) {
        setState(() => _s5Slot1 = null); _playSound('pop');
      }
      if (Rect.fromLTWH(40, -40, 60, 60).contains(pt) && _s5Slot2 != null) {
        setState(() => _s5Slot2 = null); _playSound('pop');
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      _mouseX = pt.dx;
      _mouseY = pt.dy;
      if (!_toolDragging) {
        _zoom = (_baseZoom * details.scale).clamp(0.3, 2.0);
        _panX = _basePan.dx + (details.localFocalPoint.dx - _baseFocalPoint.dx);
        _panY = _basePan.dy + (details.localFocalPoint.dy - _baseFocalPoint.dy);
      } else {
        if (_toolType == 'slider') {
          if (_scenario == 4) {
            int rawVal = (pt.dx / 30).round();
            int boundedVal = rawVal.clamp(-5, 5);
            if (_sliderVal != boundedVal && !_animating) {
              _sliderVal = boundedVal; _playSound('tick');
            }
          } else {
            int rawVal = (-(pt.dy - 20) / 35).round();
            int boundedVal = rawVal.clamp(-5, 5);
            if (_scenario == 1 && _step < 3) boundedVal = max(0, boundedVal);
            if (_scenario == 2 && boundedVal > 0) boundedVal = 0;
            if (_scenario == 3 && _step < 2) boundedVal = max(0, boundedVal);

            if (_sliderVal != boundedVal && !_animating) {
              _sliderVal = boundedVal; _playSound('tick');
              if (_scenario == 2 && _step == 0 && boundedVal == -1) _advanceStep();
            }
          }
        } else if (_toolType == 'dial') {
          int rawVal = ((pt.dx - 10) / 10).round();
          int boundedVal = rawVal.clamp(-5, 5);
          if (_dialVal != boundedVal && !_animating) {
            _dialVal = boundedVal; _playSound('tick');
          }
        }
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_toolDragging) {
      setState(() {
        if (_toolType == 'slider' || _toolType == 'dial') {
          _playSound('snap');
          if (_sliderVal == 0 && _scenario < 4) _tempCurrent = 0;
        } else if (_toolType == 'token' && _s5DraggingToken != null) {
          Offset pt = Offset(_mouseX, _mouseY);
          bool dropped = false;
          if (Rect.fromLTWH(-100, -40, 60, 60).contains(pt)) {
            _s5Slot1 = _s5DraggingToken == 'pos' ? '+' : '-'; dropped = true;
          } else if (Rect.fromLTWH(40, -40, 60, 60).contains(pt)) {
            _s5Slot2 = _s5DraggingToken == 'pos' ? '+' : '-'; dropped = true;
          }

          if (dropped) {
            _playSound('snap');
            if (_step == 0) _advanceStep();
          } else {
            _playSound('error');
          }
          _s5DraggingToken = null;
        }
        _toolDragging = false; _toolType = null;
      });
    }
  }

  void _runMachine() {
    if (_animating) return;

    if (_scenario == 3 && _step == 0 && (_dialVal != -3 || _sliderVal != 3)) {
      _playSound('error');
      setState(() { _machineErrorText = t('errorDial'); _machineErrorTimer = 120; });
      return;
    }
    if (_scenario == 2 && _step == 1 && _predictionVal != -3) {
      _playSound('error'); return;
    }
    if (_scenario == 3 && _step == 2 && _predictionVal != 3) {
      _playSound('error'); return;
    }

    setState(() {
      _animating = true; _animProgress = 0; _animRepsTotal = _sliderVal.abs();
      _animRepsRemaining = _animRepsTotal; _tempCurrent = 0;

      int targetChange = (_sliderVal == 0) ? 0 : _dialVal;
      if (_sliderVal < 0) targetChange = -_dialVal;

      if (targetChange > 0) _animType = 'flame';
      else if (targetChange < 0) _animType = 'snowflake';
      else { _animType = 'none'; _animRepsRemaining = 1; _animRepsTotal = 1; }

      _isUndo = _sliderVal < 0; _startRepTemp = _tempCurrent;
      _endRepTemp = _startRepTemp + targetChange;
    });

    _playSound('weld');
  }

  void _handleAnimationComplete() {
    _playSound('success');
    setState(() {
      String diffStr = '';
      if (_log.isNotEmpty) {
        double lastRes = double.parse(_log.last['eq']!.split('=')[1]);
        double diff = _tempCurrent - lastRes;
        diffStr = (diff > 0 ? '+' : '') + diff.toInt().toString();
      }

      String eqStr = "$_sliderVal × ${_dialVal < 0 ? '($_dialVal)' : _dialVal} = ${_tempCurrent.toInt()}";
      if (!_log.any((l) => l['eq'] == eqStr)) _log.add({'eq': eqStr, 'diff': diffStr});

      if (_scenario == 1) {
        if (_step == 0 && _sliderVal == 4) _advanceStep();
        else if (_step == 1 && _sliderVal == 3) _advanceStep();
        else if (_step == 2 && _sliderVal == 0) { _advanceStep(); Future.delayed(const Duration(seconds: 3), _checkScenarioSuccess); }
      } else if (_scenario == 2) {
        if (_step == 1 && _sliderVal == -1) _advanceStep();
        else if (_step == 2 && _sliderVal == -3) { _advanceStep(); Future.delayed(const Duration(seconds: 3), _checkScenarioSuccess); }
      } else if (_scenario == 3) {
        if (_step == 0 && _sliderVal == 3) _advanceStep();
        else if (_step == 1 && _sliderVal == 0) _advanceStep();
        else if (_step == 2 && _sliderVal == -1) _advanceStep();
        else if (_step == 3 && _sliderVal == -2) _checkScenarioSuccess();
      } else if (_scenario == 4) {
        if (_step == 0 && _sliderVal == -5) {
          _advanceStep();
          _s4TargetTemp = -15; _dialVal = 5; _tempCurrent = 0; _sliderVal = 0; _log.clear();
        } else if (_step == 1 && _sliderVal == -3) {
          _checkScenarioSuccess();
        } else {
           _s4ErrorTimer = 120; _playSound('error');
        }
      }
    });
  }

  void _predictSign() {
    if (_s5Shaking || _s5Slot1 == null || _s5Slot2 == null) return;
    setState(() { _s3AnimTokenY = -80; });
    _playSound('tick');
  }

  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);

    int totalSteps = (_scenario == 4) ? 2 : ((_scenario == 5) ? 3 : 4);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(5, 0))]
      ),
      child: SingleChildScrollView(
        controller: _sidebarScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(70, 20, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.ac_unit, color: Colors.indigoAccent),
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
                  )
                ],
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: _toggleLanguage,
                  icon: const Icon(Icons.language, size: 16),
                  label: Text(_lang.toUpperCase()),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, side: BorderSide(color: border)),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  onPressed: _handleReset,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(t('resetBtn')),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.2), foregroundColor: Colors.redAccent, side: BorderSide(color: Colors.redAccent.withOpacity(0.5))),
                ))
              ])
            ),
            const SizedBox(height: 15),
            Divider(color: border),
            // Scenario Selector
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('selectScenario').toUpperCase(), style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _scenario, isExpanded: true, dropdownColor: const Color(0xFF1E293B),
                        style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        items: [1, 2, 3, 4, 5].map((id) => DropdownMenuItem(value: id, child: Text(t('s${id}_title')))).toList(),
                        onChanged: (val) { if (val != null) _loadScenario(val); },
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
                        Row(children: [
                          const Icon(Icons.my_location, color: Colors.pinkAccent, size: 18), const SizedBox(width: 8),
                          Text(t('learnLbl'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold))
                        ]),
                        const SizedBox(height: 8),
                        Text(t('s${_scenario}_obj'), style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // S4 Target Output in Sidebar
                  if (_scenario == 4) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF047857).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10b981))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t('targetTemp'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                          Text('${_s4TargetTemp > 0 ? '+' : ''}$_s4TargetTemp°C', style: const TextStyle(color: Color(0xFF10b981), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Steps
                  ...List.generate(totalSteps, (i) {
                    bool isPast = i < _step; bool isCurrent = i == _step;
                    Color stepBg = isCurrent ? Colors.indigo.withOpacity(0.1) : (isPast ? Colors.green.withOpacity(0.05) : (Colors.white.withOpacity(0.02)));
                    Color stepBorder = isCurrent ? Colors.indigoAccent : (isPast ? Colors.green.withOpacity(0.3) : Colors.transparent);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: stepBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: stepBorder)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isPast ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                                 : Container(width: 24, height: 24, decoration: BoxDecoration(color: isCurrent ? Colors.indigoAccent : Colors.grey, shape: BoxShape.circle), alignment: Alignment.center, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
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
                                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: _buildRichText(t('s${_scenario}_step${i + 1}_out'), Colors.green.shade700))
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                  
                  if (_step == totalSteps) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [const Icon(Icons.stars, color: Colors.green), const SizedBox(width: 8), Text(t('summaryTitle'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14))]),
                          const SizedBox(height: 8),
                          _buildRichText(t('s${_scenario}_sum'), textPrimary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orangeAccent.withOpacity(0.5))),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_forward_ios, color: Colors.orangeAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t('tryNextScenario'), style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold))),
                        ]
                      )
                    )
                  ]
                ],
              ),
            ),
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF0F172A),
              child: Text(t('footer'), style: const TextStyle(color: Colors.white30, fontSize: 10), textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRichText(String htmlLikeStr, Color defaultColor) {
    List<TextSpan> spans = [];
    List<String> parts = htmlLikeStr.split('<b>');
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].contains('</b>')) {
        var subParts = parts[i].split('</b>');
        spans.add(TextSpan(text: subParts[0], style: TextStyle(fontWeight: FontWeight.bold, color: defaultColor)));
        if (subParts.length > 1) spans.add(TextSpan(text: subParts[1], style: TextStyle(color: defaultColor)));
      } else {
        spans.add(TextSpan(text: parts[i], style: TextStyle(color: defaultColor)));
      }
    }
    return RichText(text: TextSpan(style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'), children: spans));
  }

  Widget _buildOverlayButton(String label, double worldX, double worldY, Color color, VoidCallback onTap, BoxConstraints constraints, {IconData? icon, bool disabled = false}) {
    double screenX = constraints.maxWidth / 2 + _panX + worldX * _zoom;
    double screenY = constraints.maxHeight / 2 + _panY + worldY * _zoom;

    return Positioned(
      left: screenX - 110,
      top: screenY - 25,
      child: Transform.scale(
        scale: _zoom.clamp(0.8, 1.2),
        child: ElevatedButton.icon(
          onPressed: disabled ? null : () { _playSound('pop'); onTap(); },
          icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 10,
            shadowColor: color.withOpacity(0.6),
            side: BorderSide(color: Colors.white.withOpacity(0.5), width: 2)
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionInput(double worldX, double worldY, BoxConstraints constraints) {
    double screenX = constraints.maxWidth / 2 + _panX + worldX * _zoom;
    double screenY = constraints.maxHeight / 2 + _panY + worldY * _zoom;

    return Positioned(
      left: screenX - 125,
      top: screenY - 40,
      child: Transform.scale(
        scale: _zoom.clamp(0.8, 1.2),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t('predictionLabel'), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10)),
              const SizedBox(height: 4),
              TextField(
                controller: _predictController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true, fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                ),
                onChanged: (v) { setState(() { _predictionVal = int.tryParse(v); }); },
              ),
            ],
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;
    if (sidebarWidth < 300) sidebarWidth = 300;

    int maxSteps = (_scenario == 4) ? 2 : ((_scenario == 5) ? 3 : 4);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
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
                      onTap: () { SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); },
                      onScaleStart: (d) =>
                          _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) =>
                          _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) =>
                          _handleScaleEnd(d, constraints.biggest),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size.infinite,
                            painter: ThermoPainter(
                              lang: _lang,
                              scenario: _scenario,
                              step: _step,
                              zoom: _zoom,
                              panX: _panX,
                              panY: _panY,
                              toolDragging: _toolDragging,
                              toolType: _toolType,
                              mouseX: _mouseX,
                              mouseY: _mouseY,
                              sliderVal: _sliderVal,
                              dialVal: _dialVal,
                              tempCurrent: _tempCurrent,
                              targetTemp: _s4TargetTemp,
                              animProgress: _animProgress,
                              animType: _animType,
                              isUndo: _isUndo,
                              isAnimating: _animating,
                              s5Slot1: _s5Slot1,
                              s5Slot2: _s5Slot2,
                              s5DraggingToken: _s5DraggingToken,
                              s3AnimTokenY: _s3AnimTokenY,
                              s3ResultDropY: _s3ResultDropY,
                              s5RulesFound: _s5RulesFound,
                              s5Shaking: _s5Shaking,
                              log: _log,
                              t: t,
                              screenSize: constraints.biggest,
                              s4ErrorTimer: _s4ErrorTimer,
                            ),
                          ),
                          
                          // Overlay Actions mapped directly to canvas world coordinates
                          if (_scenario <= 3 && _step < maxSteps)
                             _buildOverlayButton(t('runMachine'), -60, 370, const Color(0xFF6366f1), _runMachine, constraints, icon: Icons.play_arrow, disabled: _animating),
                             
                          if (_scenario == 4 && _step < maxSteps)
                             _buildOverlayButton(t('runMachine'), 250, 220, const Color(0xFF10b981), _runMachine, constraints, icon: Icons.play_arrow, disabled: _animating),

                          if (_scenario == 5 && _step < maxSteps)
                             _buildOverlayButton(t('predictSign'), 0, -220, Colors.amber, _predictSign, constraints, icon: Icons.science, disabled: (_animating || _s5Slot1 == null || _s5Slot2 == null)),

                          if ((_scenario == 2 && _step == 1) || (_scenario == 3 && _step == 2))
                             _buildPredictionInput(260, 150, constraints),

                          if (_step == maxSteps && _scenario < 5)
                             _buildOverlayButton(t('nextScenario'), 0, 340, Colors.blueAccent, () {
                               _loadScenario(_scenario + 1);
                             }, constraints, icon: Icons.arrow_forward),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Active Step Floating Window (when Sidebar is closed)
            if (!_isSidebarOpen && _step < maxSteps)
              Positioned(
                left: _floatingStepPos.dx,
                top: _floatingStepPos.dy,
                child: GestureDetector(behavior: HitTestBehavior.opaque, 
                  onPanUpdate: (details) {
                    setState(() {
                      _floatingStepPos += details.delta;
                    });
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.indigoAccent, size: 20),
                            const SizedBox(width: 8),
                            Text("${t('stepLabel')} ${_step + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRichText(t('s${_scenario}_step${_step + 1}_task'), Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

            // HUD Overlays
            if (_step < maxSteps && _isSidebarOpen)
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth + 40 : 40,
                right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: const Border(
                              top: BorderSide(
                                  color: Colors.indigoAccent, width: 4))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.indigoAccent),
                          const SizedBox(width: 12),
                          Flexible(
                              child: Text(t('s${_scenario}_hud${_step + 1}'),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center))
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

            // MENU TOGGLE ONLY
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
                        side: BorderSide(
                            color: Colors.orange.withOpacity(0.8)))),
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
                        decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(24)),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.greenAccent,
                                              blurRadius: 20)
                                        ]),
                                    child: const Icon(Icons.flag,
                                        color: Colors.white, size: 40)),
                                const SizedBox(height: 24),
                                Text(t('labCompleted'),
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(height: 16),
                                Text(t('finalDesc'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white70)),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                    onPressed: () {
                                      _playSound('pop');
                                      setState(() {
                                        _showSuccessPopup = false;
                                        _handleReset();
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: Text(t('resetBtn')),
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 16),
                                        backgroundColor: Colors.indigoAccent,
                                        foregroundColor: Colors.white,
                                        textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)))
                              ],
                            ),
                            Positioned(
                                top: -10,
                                right: -10,
                                child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white54),
                                    onPressed: () {
                                      _playSound('pop');
                                      setState(
                                          () => _showSuccessPopup = false);
                                    }))
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
                color: const Color(0xFF020617),
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
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.indigoAccent
                                            .withOpacity(0.6),
                                        blurRadius: 20)
                                  ]),
                              child: const Icon(Icons.ac_unit,
                                  size: 80, color: Colors.white)),
                          Text(t('appTitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2)),
                          const SizedBox(height: 16),
                          Text(t('appSubtitle'),
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2)),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                              onPressed: () {
                                _playSound('enter');
                                setState(() => _showCurtain = false);
                              },
                              icon: const Icon(Icons.play_circle_fill,
                                  size: 28),
                              label: Text(t('enterLab')),
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 20),
                                  backgroundColor: Colors.indigoAccent,
                                  foregroundColor: Colors.white,
                                  elevation: 10,
                                  shadowColor: Colors.indigoAccent
                                      .withOpacity(0.5),
                                  textStyle: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)))
                        ]),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ThermoPainter extends CustomPainter {
  final String lang;
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;
  final bool toolDragging;
  final String? toolType;
  final double mouseX;
  final double mouseY;

  final int sliderVal;
  final int dialVal;
  final double tempCurrent;
  final int targetTemp;
  final double animProgress;
  final String animType;
  final bool isUndo;
  final bool isAnimating;
  final String? s5Slot1;
  final String? s5Slot2;
  final String? s5DraggingToken;
  final double? s3AnimTokenY;
  final double? s3ResultDropY;
  final List<String> s5RulesFound;
  final bool s5Shaking;
  final List<Map<String, String>> log;

  final Function(String) t;
  final Size screenSize;
  final int s4ErrorTimer;

  ThermoPainter({
    required this.lang,
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.toolDragging,
    required this.toolType,
    required this.mouseX,
    required this.mouseY,
    required this.sliderVal,
    required this.dialVal,
    required this.tempCurrent,
    required this.targetTemp,
    required this.animProgress,
    required this.animType,
    required this.isUndo,
    required this.isAnimating,
    this.s5Slot1,
    this.s5Slot2,
    this.s5DraggingToken,
    this.s3AnimTokenY,
    this.s3ResultDropY,
    required this.s5RulesFound,
    required this.s5Shaking,
    required this.log,
    required this.t,
    required this.screenSize,
    required this.s4ErrorTimer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario <= 3) {
      _drawSliderPanel(canvas, const Offset(-260, 0), sliderVal);
      _drawMachinePanel(canvas, const Offset(-60, 0));
      _drawThermometerInside(canvas, const Offset(-130, -20), tempCurrent, null);
      bool isDialLocked = scenario < 3;
      _drawDialInside(canvas, const Offset(10, 20), dialVal, isDialLocked);
      _drawClipboard(canvas, const Offset(260, 0), log);

      if (isAnimating) {
        if (animType == 'flame') _drawFlame(canvas, const Offset(-130, 205), animProgress);
        if (animType == 'snowflake') _drawSnowflake(canvas, const Offset(-130, 205), animProgress, isUndo);
      }
    } else if (scenario == 4) {
      _drawS4Machine(canvas, size);
      if (isAnimating) {
        if (animType == 'flame') _drawFlame(canvas, const Offset(-250, 225), animProgress);
        if (animType == 'snowflake') _drawSnowflake(canvas, const Offset(-250, 225), animProgress, isUndo);
      }
    } else if (scenario == 5) {
      _drawSignMachine(canvas, const Offset(0, 0));
    }

    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, Rect rect, double radius, Color fill, [Color? stroke, double strokeW = 2]) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != null) {
      canvas.drawRRect(rrect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, {Color color = Colors.white, double size = 14, bool bold = false, TextAlign align = TextAlign.center, String family = 'Plus Jakarta Sans'}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontFamily: family)),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tp.layout();
    Offset drawPos = pos;
    if (align == TextAlign.center) drawPos = Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2);
    else if (align == TextAlign.right) drawPos = Offset(pos.dx - tp.width, pos.dy - tp.height / 2);
    else drawPos = Offset(pos.dx, pos.dy - tp.height / 2);
    tp.paint(canvas, drawPos);
  }

  void _drawSliderPanel(Canvas canvas, Offset center, int value) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    _drawRoundedRect(canvas, const Rect.fromLTWH(-50, -250, 100, 500), 16, const Color(0xFF1e293b), const Color(0xFF334155), 4);
    _drawRoundedRect(canvas, const Rect.fromLTWH(-40, -240, 80, 45), 8, const Color(0xFFf8fafc), const Color(0xFF475569), 2);
    _drawText(canvas, t('numTimes1'), const Offset(0, -225), color: const Color(0xFF0f172a), size: 12, bold: true);
    _drawText(canvas, t('numTimes2'), const Offset(0, -210), color: const Color(0xFF0f172a), size: 12, bold: true);

    Paint linePaint = Paint()..color = const Color(0xFF475569)..strokeWidth = 8..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-10, -170), const Offset(-10, 210), linePaint);

    for (int i = -5; i <= 5; i++) {
      double y = -i * 35.0 + 20.0;
      canvas.drawLine(Offset(-20, y), Offset(-5, y), Paint()..color = const Color(0xFF334155)..strokeWidth = 2);
      if (i >= -4 && i <= 4) {
        _drawText(canvas, "${i > 0 ? '+' : ''}$i", Offset(-25, y), color: const Color(0xFFf8fafc), align: TextAlign.right, size: 14, bold: true);
      }
    }

    double thumbY = -value * 35.0 + 20.0;
    canvas.drawCircle(Offset(-10, thumbY), 20, Paint()..color = const Color(0xFF3b82f6));
    canvas.drawCircle(Offset(-10, thumbY), 20, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3);

    canvas.restore();
  }

  void _drawMachinePanel(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    _drawRoundedRect(canvas, const Rect.fromLTWH(-160, -250, 320, 540), 16, const Color(0xFF1e293b), const Color(0xFF334155), 6);
    canvas.drawRRect(
        RRect.fromRectAndCorners(const Rect.fromLTWH(-160, -250, 320, 40), topLeft: const Radius.circular(16), topRight: const Radius.circular(16)),
        Paint()..color = const Color(0xFF6366f1));
    _drawText(canvas, t('machineTitle'), const Offset(0, -230), color: const Color(0xFFf8fafc), size: 16, bold: true);

    canvas.restore();
  }

  void _drawThermometerInside(Canvas canvas, Offset center, double currentT, int? targetT, {bool isGhost = false}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    double tubeH = 260;
    double tubeW = 20;
    double bulbR = 20;

    _drawRoundedRect(canvas, Rect.fromLTWH(-50, -tubeH / 2 - 30, 100, tubeH + 90), 20, const Color(0xFF0f172a), const Color(0xFF334155), 4);

    for (int t = -15; t <= 20; t += 5) {
      double ty = -t * 6.0;
      canvas.drawLine(Offset(-tubeW / 2, ty), Offset(-tubeW / 2 - 8, ty), Paint()..color = const Color(0xFFf8fafc)..strokeWidth = 2);
      if (t != 0) _drawText(canvas, "$t", Offset(-tubeW / 2 - 12, ty), color: const Color(0xFFf8fafc), size: 11, bold: true, align: TextAlign.right);
    }
    _drawText(canvas, "0", Offset(tubeW / 2 + 8, 0), color: const Color(0xFFf8fafc), size: 11, bold: true, align: TextAlign.left);
    canvas.drawLine(Offset(tubeW / 2, 0), Offset(tubeW / 2 + 12, 0), Paint()..color = const Color(0xFF38bdf8)..strokeWidth = 3);

    _drawRoundedRect(canvas, Rect.fromLTWH(-tubeW / 2, -tubeH / 2, tubeW, tubeH), tubeW / 2, const Color(0xFF1e293b), const Color(0xFF475569), 2);

    double bulbCenterY = tubeH / 2 + bulbR - 5;
    canvas.drawCircle(Offset(0, bulbCenterY), bulbR, Paint()..color = const Color(0xFF1e293b));
    canvas.drawCircle(Offset(0, bulbCenterY), bulbR, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawRect(Rect.fromLTWH(-tubeW / 2 + 1, tubeH / 2 - 2, tubeW - 2, 6), Paint()..color = const Color(0xFF1e293b));

    Color mercColor = currentT > 0 ? const Color(0xFFef4444) : (currentT < 0 ? const Color(0xFF3b82f6) : const Color(0xFF8b5cf6));
    if (isGhost) mercColor = Colors.white.withOpacity(0.5);

    double mercY = -currentT * 6.0;
    double mercH = (tubeH / 2) - mercY;

    canvas.drawCircle(Offset(0, bulbCenterY), bulbR - 4, Paint()..color = mercColor);
    _drawRoundedRect(canvas, Rect.fromLTWH(-tubeW / 2 + 4, mercY, tubeW - 8, mercH + 2), 4, mercColor);

    if (targetT != null) {
      double targetY = -targetT * 6.0;
      Paint dashPaint = Paint()..color = const Color(0xFF10b981)..strokeWidth = 4;
      canvas.drawLine(Offset(-tubeW / 2 - 30, targetY), Offset(tubeW / 2 + 30, targetY), dashPaint);
      _drawText(canvas, t('targetLbl'), Offset(tubeW / 2 + 35, targetY), color: const Color(0xFF10b981), size: 12, bold: true, align: TextAlign.left);
    }

    canvas.restore();
  }

  void _drawDialInside(Canvas canvas, Offset center, int value, bool isLocked) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    _drawRoundedRect(canvas, const Rect.fromLTWH(-75, -60, 150, 120), 12, const Color(0xFF0f172a), const Color(0xFF475569), 2);
    _drawText(canvas, t('tempChange1'), const Offset(0, -45), color: const Color(0xFFf8fafc), size: 12, bold: true);
    _drawText(canvas, t('tempChange2'), const Offset(0, -30), color: const Color(0xFFf8fafc), size: 12, bold: true);

    canvas.drawCircle(const Offset(-20, 15), 30, Paint()..color = const Color(0xFF1e293b));
    canvas.drawCircle(const Offset(-20, 15), 30, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 3);

    if (isLocked) _drawText(canvas, "🔒", const Offset(-20, 20), size: 16);

    for (int i = 0; i < 10; i++) {
      double angle = pi * 0.8 + (i / 9) * pi * 1.4;
      canvas.drawLine(
          Offset(-20 + cos(angle) * 20, 15 + sin(angle) * 20),
          Offset(-20 + cos(angle) * 35, 15 + sin(angle) * 35),
          Paint()..color = const Color(0xFF334155)..strokeWidth = 2);
    }

    double mappedAngle = pi * 0.8 + ((value + 5) / 10) * pi * 1.4;
    canvas.drawLine(const Offset(-20, 15), Offset(-20 + cos(mappedAngle) * 24, 15 + sin(mappedAngle) * 24), Paint()..color = const Color(0xFFef4444)..strokeWidth = 4..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(-20, 15), 6, Paint()..color = const Color(0xFF0f172a));

    _drawText(canvas, "${value > 0 ? '+' : ''}$value", const Offset(15, 15), color: const Color(0xFFf8fafc), size: 24, bold: true, align: TextAlign.left);

    canvas.restore();
  }

  void _drawClipboard(Canvas canvas, Offset center, List<Map<String, String>> logs) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    _drawRoundedRect(canvas, const Rect.fromLTWH(-130, -250, 260, 540), 16, const Color(0xFF1e293b), const Color(0xFF475569), 4);
    _drawRoundedRect(canvas, const Rect.fromLTWH(-120, -210, 240, 490), 8, const Color(0xFFcbd5e1), Colors.transparent, 0);

    canvas.drawRRect(
        RRect.fromRectAndCorners(const Rect.fromLTWH(-130, -250, 260, 40), topLeft: const Radius.circular(16), topRight: const Radius.circular(16)),
        Paint()..color = const Color(0xFF818cf8));
    _drawText(canvas, t('patternLog'), const Offset(0, -230), size: 16, bold: true);

    double yStart = -150;
    for (int i = 0; i < logs.length; i++) {
      double y = yStart + i * 45;
      _drawRoundedRect(canvas, Rect.fromLTWH(-110, y - 18, 220, 36), 6, const Color(0xFF0f172a), const Color(0xFF334155), 2);
      _drawText(canvas, logs[i]['eq']!, Offset(-95, y), color: const Color(0xFFf8fafc), size: 16, bold: true, align: TextAlign.left, family: 'monospace');

      if (logs[i]['diff']!.isNotEmpty) {
        bool isNeg = logs[i]['diff']!.contains('-');
        Color bg = isNeg ? const Color(0xFFef4444) : const Color(0xFF22c55e);
        _drawRoundedRect(canvas, Rect.fromLTWH(50, y - 14, 50, 28), 4, bg, Colors.transparent, 0);
        _drawText(canvas, logs[i]['diff']!, Offset(75, y), size: 14, bold: true);
      }
    }

    canvas.restore();
  }

  void _drawS4Machine(Canvas canvas, Size size) {
    Offset center = const Offset(0, -50);
    canvas.save();
    canvas.translate(center.dx, center.dy);

    _drawRoundedRect(canvas, const Rect.fromLTWH(-380, -220, 760, 440), 20, const Color(0xFFc2410c), const Color(0xFF78350f), 8);
    canvas.drawRRect(
        RRect.fromRectAndCorners(const Rect.fromLTWH(-380, -220, 760, 40), topLeft: const Radius.circular(20), topRight: const Radius.circular(20)),
        Paint()..color = const Color(0xFFea580c));
    _drawText(canvas, t('s4_mission'), const Offset(0, -200), size: 18, bold: true);

    _drawThermometerInside(canvas, const Offset(-250, 20), tempCurrent, targetTemp);
    if (!isAnimating && sliderVal != 0) {
      _drawThermometerInside(canvas, const Offset(-150, 20), (sliderVal * dialVal).toDouble(), null, isGhost: true);
    }

    _drawDialInside(canvas, const Offset(0, -80), dialVal, true);

    // Horizontal Slider
    canvas.save();
    canvas.translate(0, 100);
    _drawRoundedRect(canvas, const Rect.fromLTWH(-180, -35, 360, 70), 12, const Color(0xFF1e293b), const Color(0xFF334155), 4);
    _drawText(canvas, "${t('numTimes1')} ${t('numTimes2')}", const Offset(0, -20), color: const Color(0xFFf8fafc), size: 14, bold: true);
    canvas.drawLine(const Offset(-150, 10), const Offset(150, 10), Paint()..color = const Color(0xFF475569)..strokeWidth = 8..strokeCap = StrokeCap.round);
    for (int i = -5; i <= 5; i++) {
      double x = i * 30.0;
      canvas.drawLine(Offset(x, 0), Offset(x, 20), Paint()..color = const Color(0xFF334155)..strokeWidth = 2);
      if (i != 0) _drawText(canvas, "${i > 0 ? '+' : ''}$i", Offset(x, 35), size: 12, bold: true, color: const Color(0xFF94a3b8), family: 'monospace');
    }
    double thumbX = sliderVal * 30.0;
    _drawRoundedRect(canvas, Rect.fromLTWH(thumbX - 15, -5, 30, 30), 8, const Color(0xFF3b82f6), const Color(0xFF1d4ed8), 2);
    canvas.drawLine(Offset(thumbX, 0), Offset(thumbX, 20), Paint()..color = Colors.white..strokeWidth = 3);
    canvas.restore();

    // Equation Box
    canvas.save();
    canvas.translate(250, -20);
    _drawRoundedRect(canvas, const Rect.fromLTWH(-120, -50, 240, 100), 12, const Color(0xFF0f172a), const Color(0xFF334155), 4);
    _drawRoundedRect(canvas, const Rect.fromLTWH(-110, -10, 220, 50), 8, const Color(0xFF1e293b), Colors.transparent, 0);
    _drawText(canvas, t('realTimeEq'), const Offset(0, -30), color: const Color(0xFFf8fafc), size: 14, bold: true);
    int res = sliderVal * dialVal;
    bool match = res == targetTemp;
    String eqText = "${sliderVal < 0 ? '($sliderVal)' : sliderVal} × ${dialVal < 0 ? '($dialVal)' : dialVal} = ${res > 0 ? '+' : ''}$res";
    if (sliderVal == 0) eqText = "${t('sliderLbl')} × ${dialVal < 0 ? '($dialVal)' : dialVal} = [?]";

    Color resColor = match ? const Color(0xFF10b981) : const Color(0xFF38bdf8);
    _drawText(canvas, eqText, const Offset(0, 15), size: 22, bold: true, color: resColor, family: 'monospace');

    if (match && sliderVal != 0) {
      _drawText(canvas, t('matched'), const Offset(0, 60), size: 16, bold: true, color: const Color(0xFF10b981));
    }
    
    // Error Indicator rendering correctly below equation if triggered
    if (s4ErrorTimer > 0) {
       _drawText(canvas, t('tryAgain'), const Offset(0, 80), size: 16, bold: true, color: const Color(0xFFef4444));
    }
    
    canvas.restore();

    canvas.restore();
  }

  void _drawSignMachine(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    double shakeX = s5Shaking ? (Random().nextDouble() - 0.5) * 8 : 0;
    double shakeY = s5Shaking ? (Random().nextDouble() - 0.5) * 8 : 0;

    canvas.save();
    canvas.translate(shakeX, shakeY);

    Path topP = Path()..moveTo(-140, -100)..lineTo(140, -100)..lineTo(180, -140)..lineTo(-100, -140)..close();
    canvas.drawPath(topP, Paint()..color = const Color(0xFF818cf8));
    canvas.drawPath(topP, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);

    Path rightP = Path()..moveTo(140, -100)..lineTo(180, -140)..lineTo(180, 40)..lineTo(140, 80)..close();
    canvas.drawPath(rightP, Paint()..color = const Color(0xFF3730a3));
    canvas.drawPath(rightP, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);

    _drawRoundedRect(canvas, const Rect.fromLTWH(-140, -100, 280, 180), 0, const Color(0xFF4f46e5), const Color(0xFF1e1b4b), 3);

    Path chuteP = Path()..moveTo(-40, 80)..lineTo(40, 80)..lineTo(60, 120)..lineTo(-20, 120)..close();
    canvas.drawPath(chuteP, Paint()..color = const Color(0xFF3730a3));
    canvas.drawPath(chuteP, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawOval(const Rect.fromLTWH(-16, 110, 72, 20), Paint()..color = const Color(0xFF0f172a));

    _drawText(canvas, t('s5SignNum1_1'), const Offset(-70, -75), size: 14, bold: true);
    _drawText(canvas, t('s5SignNum1_2'), const Offset(-70, -60), size: 14, bold: true);
    _drawText(canvas, t('s5SignNum2_1'), const Offset(70, -75), size: 14, bold: true);
    _drawText(canvas, t('s5SignNum2_2'), const Offset(70, -60), size: 14, bold: true);

    _drawRoundedRect(canvas, const Rect.fromLTWH(-100, -40, 60, 60), 8, const Color(0xFF0f172a), const Color(0xFF1e293b), 4);
    _drawRoundedRect(canvas, const Rect.fromLTWH(40, -40, 60, 60), 8, const Color(0xFF0f172a), const Color(0xFF1e293b), 4);

    if (s5Slot1 != null && s3AnimTokenY == null) _drawSignToken(canvas, const Offset(-70, -10), s5Slot1!, 1.2);
    if (s5Slot2 != null && s3AnimTokenY == null) _drawSignToken(canvas, const Offset(70, -10), s5Slot2!, 1.2);

    if (s3AnimTokenY != null) {
      if (s5Slot1 != null) _drawSignToken(canvas, Offset(-70, s3AnimTokenY!), s5Slot1!, 1.2);
      if (s5Slot2 != null) _drawSignToken(canvas, Offset(70, s3AnimTokenY!), s5Slot2!, 1.2);
    }

    if (s5Shaking && Random().nextDouble() > 0.5) {
      _drawText(canvas, t('processing'), const Offset(0, 50), color: const Color(0xFFfde047), size: 14, bold: true, family: 'monospace');
    }
    canvas.restore();

    if (s3ResultDropY != null) {
      String resSign = (s5Slot1 == s5Slot2) ? '+' : '-';
      _drawSignToken(canvas, Offset(20, s3ResultDropY!), resSign, 1.8, true);
    }

    _drawText(canvas, t('dragInst1'), const Offset(0, 220), color: const Color(0xFFf8fafc), size: 16, bold: true);
    _drawText(canvas, t('dragInst2'), const Offset(0, 240), color: const Color(0xFFf8fafc), size: 16, bold: true);

    if (s5DraggingToken != 'pos') _drawSignToken(canvas, const Offset(-60, 160), '+', 1.8);
    if (s5DraggingToken != 'neg') _drawSignToken(canvas, const Offset(60, 160), '-', 1.8);

    if (toolDragging && toolType == 'token' && s5DraggingToken != null) {
      _drawSignToken(canvas, Offset(mouseX, mouseY), s5DraggingToken == 'pos' ? '+' : '-', 1.8, true);
    }

    double logX = 260;
    _drawRoundedRect(canvas, Rect.fromLTWH(logX - 110, -100, 220, 250), 12, const Color(0xFF1e293b), const Color(0xFF475569), 4);
    canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(logX - 110, -100, 220, 40), topLeft: const Radius.circular(12), topRight: const Radius.circular(12)),
        Paint()..color = const Color(0xFF38bdf8));
    _drawText(canvas, t('s5_rLog'), Offset(logX, -80), size: 16, bold: true);

    for (int i = 0; i < s5RulesFound.length; i++) {
      _drawText(canvas, s5RulesFound[i], Offset(logX, -30 + i * 35.0), color: const Color(0xFFf8fafc), size: 20, bold: true, family: 'monospace');
    }

    if (s5RulesFound.length == 4) {
      _drawText(canvas, t('s5_allFound'), Offset(logX, 120), color: const Color(0xFF10b981), size: 16, bold: true);
    }

    canvas.restore();
  }

  void _drawSignToken(Canvas canvas, Offset center, String sign, double scale, [bool glowing = false]) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale, scale);

    if (glowing) {
      canvas.drawCircle(Offset.zero, 10, Paint()..color = const Color(0xFF6366f1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }
    canvas.drawCircle(Offset.zero, 10, Paint()..color = const Color(0xFF6366f1));

    if (sign == '+') {
      canvas.drawRect(const Rect.fromLTWH(-5, -1, 10, 2), Paint()..color = Colors.white);
      canvas.drawRect(const Rect.fromLTWH(-1, -5, 2, 10), Paint()..color = Colors.white);
    } else if (sign == '-') {
      canvas.drawRect(const Rect.fromLTWH(-5, -1, 10, 2), Paint()..color = Colors.white);
    }
    canvas.restore();
  }

  void _drawFlame(Canvas canvas, Offset center, double progress) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    double scale = 0.5 + sin(progress * pi) * 0.8;
    canvas.scale(scale, scale);

    Path p1 = Path()
      ..moveTo(0, 10)
      ..quadraticBezierTo(20, 10, 15, -15)
      ..quadraticBezierTo(5, -10, 0, -30)
      ..quadraticBezierTo(-5, -10, -15, -15)
      ..quadraticBezierTo(-20, 10, 0, 10);
    canvas.drawPath(p1, Paint()..color = Colors.orange);

    canvas.scale(0.6, 0.6);
    canvas.drawPath(p1, Paint()..color = Colors.yellow);

    canvas.restore();
  }

  void _drawSnowflake(Canvas canvas, Offset center, double progress, bool isUndo) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    double rot = progress * pi;

    if (isUndo) {
      canvas.save();
      canvas.rotate(-progress * pi * 2);
      canvas.drawArc(const Rect.fromLTWH(-35, -35, 70, 70), 0, pi * 1.5, false, Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 4);
      Path arrow = Path()..moveTo(35, -10)..lineTo(47, -10)..lineTo(35, -25)..lineTo(23, -10)..close();
      canvas.drawPath(arrow, Paint()..color = Colors.yellow);
      canvas.restore();
    }

    canvas.rotate(rot);
    double scale = 0.5 + sin(progress * pi) * 0.8;
    canvas.scale(scale, scale);
    Paint snowP = Paint()..color = Colors.lightBlueAccent..strokeWidth = 4..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      canvas.rotate(pi / 3);
      canvas.drawLine(const Offset(0, 0), const Offset(0, 25), snowP);
      canvas.drawLine(const Offset(0, 15), const Offset(-8, 25), snowP);
      canvas.drawLine(const Offset(0, 15), const Offset(8, 25), snowP);
    }
    canvas.drawCircle(const Offset(0, 0), 4, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ThermoPainter oldDelegate) => true;
}

const Map<String, Map<String, String>> _translations = {
  'en': {
    'appTitle': "The Thermo-Pattern Machine", 'appSubtitle': "Class 7 • OPERATIONS WITH INTEGERS", 'enterLab': "Enter Lab",
    'settings': "Settings", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'boardFontSize': "Text Size", 
    'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done", 
    'learnLbl': "What We Learn:", 'closeBtn': "Close", 'summaryTitle': "Discovery Made!",
    'resetBtn': "Reset Lab", 'finishLab': "Finish Lab", 'nextScenario': "Next Scenario",
    'labCompleted': "Lab Completed!", 'finalDesc': "You have successfully mastered integer multiplication! You discovered the patterns that explain why positive × negative is negative, and negative × negative is positive.",
    'runMachine': "RUN MACHINE", 'predictSign': "PREDICT SIGN", 'patternLog': "Pattern Log", 'targetTemp': "Target Temp:",
    'predictionLabel': "Enter Prediction (-1 x Dial Value):", 'footer': "© ZeroScienceLab - Fall in love with math and Science", 'errorDial': "Set Dial to -3 and Slider to +3!", 'tryAgain': "Try Again!",
    'rulesFound': "RULES FOUND", 'posToken': "Positive", 'negToken': "Negative",
    'numTimes1': "Number of", 'numTimes2': "Times", 'tempChange1': "Temperature", 'tempChange2': "Change per Turn",
    's5SignNum1_1': "Sign of", 's5SignNum1_2': "Number 1", 's5SignNum2_1': "Sign of", 's5SignNum2_2': "Number 2", 's5_rLog': "Rule Log", 's5_allFound': "ALL RULES FOUND!",
    'dragInst1': "DRAG a Positive Token (+) and a Negative Token (-)", 'dragInst2': "into the correct slots.",
    'tryNextScenario': "Scenario completed! Please try the next scenario.",
    
    // Canvas Text Additions
    'machineTitle': "THERMO-PATTERN MACHINE",
    'targetLbl': "TARGET",
    's4_mission': "Thermo-Pattern Machine - Mission: Find the Missing Multiplier",
    'realTimeEq': "Real-time Equation",
    'matched': "MATCHED!",
    'processing': "PROCESSING...",
    'sliderLbl': "[Slider]",

    's1_title': "1. The Downward Trend", 's1_obj': "To observe the pattern in the product as the multiplier decreases towards zero.",
    's1_hud1': "Slider is at +4. Click 'RUN MACHINE'.", 's1_step1_task': "<b>Action:</b> The Thermo-Pattern Machine is set with 'Change per Turn' at +3°C and 'Number of Times' at +4. CLICK the 'RUN MACHINE' button.", 's1_step1_out': "<b>Observation:</b> The machine adds +3°C four times. The thermometer rises to +12°C. Equation recorded.",
    's1_hud2': "Drag slider to +3 and click 'RUN MACHINE'.", 's1_step2_task': "<b>Action:</b> DRAG the 'Number of Times' slider down by one notch to +3. CLICK the 'RUN MACHINE' button.", 's1_step2_out': "<b>Observation:</b> The thermometer rises to +9°C. The Pattern Log shows a difference of -3.",
    's1_hud3': "Drag slider down to 0, clicking 'RUN MACHINE' at each step.", 's1_step3_task': "<b>Action:</b> Continue to DRAG the 'Number of Times' slider down one notch at a time (to +2, +1, and 0), clicking 'RUN MACHINE' after each change.", 's1_step3_out': "<b>Observation:</b> The Pattern Log populates. As the multiplier decreases by 1, the result decreases by 3.",
    's1_hud4': "Observe the completed Pattern Log.", 's1_step4_task': "<b>Action:</b> OBSERVE the completed Pattern Log.", 's1_step4_out': "<b>Learning:</b> Each time the 'Number of Times' decreases by 1, the Final Temperature decreases by the 'Change per Turn' amount.",
    's1_sum': "<b>Pattern Discovered!</b> Decreasing the multiplier by 1 decreases the product steadily.",

    's2_title': "2. Into the Negative Zone", 's2_obj': "To use the established pattern to predict and understand the result of multiplying a negative integer by a positive integer.",
    's2_hud1': "Drag slider to -1.", 's2_step1_task': "<b>Action:</b> The machine starts at 0 × 3 = 0. DRAG the slider down one notch into the negative zone, to -1.", 's2_step1_out': "<b>Observation:</b> The machine asks for a prediction. If the pattern of '-3' continues, what will 0 - 3 be?",
    's2_hud2': "Enter your prediction in the box, then click 'RUN MACHINE'.", 's2_step2_task': "<b>Action:</b> Type your prediction for '-1 × 3' in the box in the pattern log, then CLICK 'RUN MACHINE'.", 's2_step2_out': "<b>Observation:</b> A 'Snowflake' animation plays. A negative multiplier means we 'UNDO' the temperature change. Undoing an increase causes a drop to -3°C.",
    's2_hud3': "Continue dragging down to -3, clicking 'RUN MACHINE' each time.", 's2_step3_task': "<b>Action:</b> Continue to DRAG the slider down to -2 and then -3, clicking 'RUN MACHINE' each time.", 's2_step3_out': "<b>Observation:</b> The thermometer drops to -6°C, then -9°C. The pattern continues flawlessly.",
    's2_hud4': "Observe the full pattern.", 's2_step4_task': "<b>Action:</b> OBSERVE the full pattern.", 's2_step4_out': "<b>Learning:</b> Negative × Positive = Negative. It's a logical extension of the pattern!",
    's2_sum': "<b>Zone Mastered!</b> Undoing a temperature increase leads to a lower temperature.",

    's3_title': "3. The Big Flip", 's3_obj': "To observe the pattern that leads to the rule: Negative × Negative = Positive.",
    's3_hud1': "Drag Dial to -3, set Slider to +3. Click 'RUN MACHINE'.", 's3_step1_task': "<b>Action:</b> The machine is reset. DRAG the 'Temperature Change per Turn' dial to a negative value, -3°C. Set the 'Number of Times' slider to +3. CLICK 'RUN MACHINE'.", 's3_step1_out': "<b>Observation:</b> The machine animates subtracting 3°C three times. The thermometer drops to -9°C. The equation '3 × (-3) = -9' appears in the Pattern Log.",
    's3_hud2': "Drag slider down to 0, clicking 'RUN MACHINE' at each step.", 's3_step2_task': "<b>Action:</b> DRAG the 'Number of Times' slider down one notch at a time (from +3 to 0), clicking 'RUN MACHINE' after each change. OBSERVE the pattern in the results.", 's3_step2_out': "<b>Observation:</b> This time, as the multiplier decreases by 1, the product INCREASES by 3 (+3 difference).",
    's3_hud3': "Drag slider to -1. Predict the outcome, then 'RUN MACHINE'.", 's3_step3_task': "<b>Action:</b> Now, DRAG the slider into the negative zone, to -1. Based on the new pattern, predict the result and then CLICK 'RUN MACHINE' to verify.", 's3_step3_out': "<b>Observation:</b> The machine shows 'undoing a decrease of 3°C'. Visually, a snowflake animation is played and then rewound, causing the temperature to INCREASE by 3. The thermometer rises to +3°C.",
    's3_hud4': "Drag the slider to -2 and 'RUN MACHINE'.", 's3_step4_task': "<b>Action:</b> DRAG the slider to -2 and CLICK 'RUN MACHINE'.", 's3_step4_out': "<b>Learning:</b> The pattern holds! Undoing a temperature decrease causes an increase. This is why a negative times a negative is a positive!",
    's3_sum': "<b>The Big Flip Complete!</b> Negative × Negative = Positive.",

    's4_title': "4. The Predictor Challenge", 's4_obj': "To apply the observed patterns to find a missing multiplier.",
    's4_hud1': "Target: +20. Change is -4. Find the multiplier using the slider and 'RUN MACHINE'.", 's4_step1_task': "<b>Action:</b> The 'Change per Turn' dial is locked at -4°C. The target final temperature is shown as +20°C on the thermometer. The 'Number of Times' slider is unlocked. DRAG the slider to the correct value to make the final temperature match the target.", 's4_step1_out': "<b>Observation:</b> You need to undo a decrease (-4) 5 times (-5) to reach +20. The correct multiplier is -5.",
    's4_hud2': "Target: -15. Change is +5. Find the multiplier using the slider and 'RUN MACHINE'.", 's4_step2_task': "<b>Action:</b> A new challenge. 'Temperature Change per Turn' is locked at +5°C. The target temperature is -15°C. DRAG the slider to the correct value and CLICK 'RUN MACHINE'.", 's4_step2_out': "<b>Observation:</b> You need to undo an increase (+5) 3 times (-3) to reach -15. The correct multiplier is -3.",
    's4_sum': "<b>Challenge Conquered!</b> You used the rules to predict unknown values.",

    's5_title': "5. The Sign Machine", 's5_obj': "To generalize the rules of integer multiplication by focusing only on the signs.",
    's5_hud1': "Drag one token into each slot.", 's5_step1_task': "<b>Action:</b> A new Sign Machine is ready. DRAG a token (Positive or Negative) into each of the two input slots.", 's5_step1_out': "<b>Observation:</b> Tokens are loaded in the machine.",
    's5_hud2': "Click 'PREDICT SIGN'.", 's5_step2_task': "<b>Action:</b> CLICK the 'PREDICT SIGN' button.", 's5_step2_out': "<b>Observation:</b> The machine processes the signs and outputs the result in the Rule Log.",
    's5_hud3': "Test all 4 combinations to complete the log.", 's5_step3_task': "<b>Action:</b> Experiment with all four possible combinations of signs (+ +, + -, - +, - -). DRAG tokens and CLICK 'PREDICT SIGN' until the Rule Log is complete.", 's5_step3_out': "<b>Learning:</b> The four universal rules for multiplying integers are revealed.",
    's5_sum': "<b>Rules Generalized!</b> You have mastered the signs of integer multiplication."
  },
  'hi': {
    'appTitle': "थर्मो-पैटर्न मशीन", 'appSubtitle': "कक्षा 7 • पूर्णांकों के साथ संचालन", 'enterLab': "लैब में प्रवेश करें",
    'settings': "सेटिंग्स", 'theme': "थीम", 'darkMode': "डार्क मोड", 'lightMode': "लाइट मोड", 'boardFontSize': "टेक्स्ट आकार", 
    'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण", 
    'learnLbl': "हम क्या सीखते हैं:", 'closeBtn': "बंद करें", 'summaryTitle': "खोज की गई!",
    'resetBtn': "लैब रीसेट करें", 'finishLab': "लैब समाप्त करें", 'nextScenario': "अगला परिदृश्य",
    'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने पूर्णांक गुणा में सफलतापूर्वक महारत हासिल कर ली है! आपने उन पैटर्नों की खोज की है जो बताते हैं कि क्यों धनात्मक × ऋणात्मक ऋणात्मक होता है, और ऋणात्मक × ऋणात्मक धनात्मक होता है।",
    'runMachine': "मशीन चलाएं", 'predictSign': "चिह्न की भविष्यवाणी करें", 'patternLog': "पैटर्न लॉग", 'targetTemp': "लक्ष्य तापमान:",
    'predictionLabel': "भविष्यवाणी दर्ज करें (-1 x डायल):", 'footer': "© ZeroScienceLab - गणित और विज्ञान से प्यार करें", 'errorDial': "डायल को -3 और स्लाइडर को +3 पर सेट करें!", 'tryAgain': "पुनः प्रयास करें!",
    'rulesFound': "नियम मिले", 'posToken': "धनात्मक", 'negToken': "ऋणात्मक",
    'numTimes1': "कितनी", 'numTimes2': "बार", 'tempChange1': "प्रति टर्न", 'tempChange2': "बदलाव",
    's5SignNum1_1': "संख्या 1", 's5SignNum1_2': "का चिह्न", 's5SignNum2_1': "संख्या 2", 's5SignNum2_2': "का चिह्न", 's5_rLog': "रूल लॉग", 's5_allFound': "सभी नियम मिल गए!",
    'dragInst1': "एक धनात्मक (+) और एक ऋणात्मक (-) टोकन को", 'dragInst2': "सही स्लॉट में खींचें।",
    'tryNextScenario': "परिदृश्य पूरा हुआ! कृपया अगला परिदृश्य आज़माएं।",
    
    // Canvas Text Additions
    'machineTitle': "थर्मो-पैटर्न मशीन",
    'targetLbl': "लक्ष्य",
    's4_mission': "थर्मो-पैटर्न मशीन - मिशन: गुम गुणक खोजें",
    'realTimeEq': "रीयल-टाइम समीकरण",
    'matched': "मिलान हो गया!",
    'processing': "प्रोसेसिंग...",
    'sliderLbl': "[स्लाइडर]",

    's1_title': "1. नीचे की ओर रुझान", 's1_obj': "गुणक शून्य की ओर घटने पर गुणनफल में पैटर्न का निरीक्षण करना।",
    's1_hud1': "स्लाइडर +4 पर है। 'मशीन चलाएं' पर क्लिक करें।", 's1_step1_task': "<b>क्रिया:</b> थर्मो-पैटर्न मशीन 'प्रति टर्न परिवर्तन' +3°C और 'कितनी बार' +4 के साथ सेट है। 'मशीन चलाएं' बटन पर क्लिक करें।", 's1_step1_out': "<b>अवलोकन:</b> मशीन चार बार +3°C जोड़ती है। थर्मामीटर +12°C तक बढ़ जाता है। समीकरण दर्ज किया गया।",
    's1_hud2': "स्लाइडर को +3 पर खींचें और 'मशीन चलाएं' पर क्लिक करें।", 's1_step2_task': "<b>क्रिया:</b> 'कितनी बार' स्लाइडर को एक पायदान नीचे +3 तक खींचें। 'मशीन चलाएं' बटन पर क्लिक करें।", 's1_step2_out': "<b>अवलोकन:</b> थर्मामीटर +9°C तक बढ़ जाता है। पैटर्न लॉग -3 का अंतर दिखाता है।",
    's1_hud3': "स्लाइडर को 0 तक नीचे खींचें, प्रत्येक चरण पर 'मशीन चलाएं' पर क्लिक करें।", 's1_step3_task': "<b>क्रिया:</b> प्रत्येक परिवर्तन के बाद 'मशीन चलाएं' पर क्लिक करते हुए, स्लाइडर को एक-एक पायदान नीचे (+2, +1, और 0 तक) खींचना जारी रखें।", 's1_step3_out': "<b>अवलोकन:</b> पैटर्न लॉग भरता है। जैसे-जैसे गुणक 1 कम होता है, परिणाम 3 कम हो जाता है।",
    's1_hud4': "पूर्ण पैटर्न लॉग का निरीक्षण करें।", 's1_step4_task': "<b>क्रिया:</b> पूर्ण पैटर्न लॉग का निरीक्षण करें।", 's1_step4_out': "<b>सीख:</b> हर बार जब 'कितनी बार' 1 कम हो जाता है, तो अंतिम तापमान 'प्रति टर्न परिवर्तन' राशि से कम हो जाता है।",
    's1_sum': "<b>पैटर्न खोजा गया!</b> गुणक को 1 कम करने से गुणनफल लगातार कम होता है।",

    's2_title': "2. नकारात्मक क्षेत्र में", 's2_obj': "नकारात्मक पूर्णांक को धनात्मक से गुणा करने के परिणाम की भविष्यवाणी करने और समझने के लिए स्थापित पैटर्न का उपयोग करना।",
    's2_hud1': "स्लाइडर को -1 पर खींचें।", 's2_step1_task': "<b>क्रिया:</b> मशीन 0 × 3 = 0 पर शुरू होती है। स्लाइडर को नकारात्मक क्षेत्र में एक पायदान नीचे -1 तक खींचें।", 's2_step1_out': "<b>अवलोकन:</b> मशीन भविष्यवाणी के लिए पूछती है। यदि '-3' का पैटर्न जारी रहता है, तो 0 - 3 क्या होगा?",
    's2_hud2': "बॉक्स में अपनी भविष्यवाणी दर्ज करें, फिर 'मशीन चलाएं' पर क्लिक करें।", 's2_step2_task': "<b>क्रिया:</b> पैटर्न लॉग में बॉक्स में '-1 × 3' के लिए अपनी भविष्यवाणी टाइप करें, फिर 'मशीन चलाएं' पर क्लिक करें।", 's2_step2_out': "<b>अवलोकन:</b> एक 'स्नोफ्लेक' एनीमेशन चलता है। ऋणात्मक गुणक का अर्थ है कि हम तापमान परिवर्तन को 'अंडू' करते हैं। वृद्धि को पूर्ववत करने से तापमान -3°C तक गिर जाता है।",
    's2_hud3': "-3 तक नीचे खींचना जारी रखें, हर बार 'मशीन चलाएं' पर क्लिक करें।", 's2_step3_task': "<b>क्रिया:</b> हर बार 'मशीन चलाएं' पर क्लिक करते हुए स्लाइडर को -2 और फिर -3 तक नीचे खींचना जारी रखें।", 's2_step3_out': "<b>अवलोकन:</b> थर्मामीटर -6°C, फिर -9°C तक गिर जाता है। पैटर्न त्रुटिहीन रूप से जारी है।",
    's2_hud4': "पूर्ण पैटर्न का निरीक्षण करें।", 's2_step4_task': "<b>क्रिया:</b> पूर्ण पैटर्न का निरीक्षण करें।", 's2_step4_out': "<b>सीख:</b> ऋणात्मक × धनात्मक = ऋणात्मक। यह पैटर्न का तार्किक विस्तार है!",
    's2_sum': "<b>क्षेत्र में महारत!</b> तापमान वृद्धि को पूर्ववत करने से तापमान कम होता है।",

    's3_title': "3. द बिग फ्लिप", 's3_obj': "उस पैटर्न का निरीक्षण करना जो इस नियम की ओर ले जाता है: नकारात्मक × नकारात्मक = सकारात्मक।",
    's3_hud1': "डायल को -3 पर खींचें, स्लाइडर को +3 पर सेट करें। 'मशीन चलाएं' पर क्लिक करें।", 's3_step1_task': "<b>क्रिया:</b> मशीन रीसेट हो गई है। 'प्रति टर्न परिवर्तन' डायल को -3°C के नकारात्मक मान पर खींचें। 'कितनी बार' स्लाइडर को +3 पर सेट करें। 'मशीन चलाएं' पर क्लिक करें।", 's3_step1_out': "<b>अवलोकन:</b> मशीन तीन बार 3°C घटाती है। थर्मामीटर -9°C तक गिर जाता है। समीकरण '3 × (-3) = -9' पैटर्न लॉग में दिखाई देता है।",
    's3_hud2': "स्लाइडर को 0 तक नीचे खींचें, प्रत्येक चरण पर 'मशीन चलाएं' पर क्लिक करें।", 's3_step2_task': "<b>क्रिया:</b> प्रत्येक परिवर्तन के बाद 'मशीन चलाएं' पर क्लिक करते हुए, स्लाइडर को एक-एक पायदान नीचे (+3 से 0 तक) खींचें। परिणामों में पैटर्न का निरीक्षण करें।", 's3_step2_out': "<b>अवलोकन:</b> इस बार, जैसे-जैसे गुणक 1 से कम होता है, गुणनफल 3 (+3 अंतर) से बढ़ता है।",
    's3_hud3': "स्लाइडर को -1 पर खींचें। भविष्यवाणी करें, फिर 'मशीन चलाएं'।", 's3_step3_task': "<b>क्रिया:</b> अब, स्लाइडर को नकारात्मक क्षेत्र में -1 तक खींचें। नए +3 पैटर्न के आधार पर परिणाम की भविष्यवाणी करें और सत्यापित करने के लिए 'मशीन चलाएं' पर क्लिक करें।", 's3_step3_out': "<b>अवलोकन:</b> मशीन '3°C की कमी को पूर्ववत करना' दिखाती है। दृश्य रूप से, एक स्नोफ्लेक एनीमेशन चलाया जाता है और फिर रिवाइंड किया जाता है, जिससे तापमान 3 तक बढ़ जाता है। थर्मामीटर +3°C तक बढ़ जाता है।",
    's3_hud4': "स्लाइडर को -2 पर खींचें और 'मशीन चलाएं' दबाएं।", 's3_step4_task': "<b>क्रिया:</b> स्लाइडर को -2 पर खींचें और 'मशीन चलाएं' पर क्लिक करें।", 's3_step4_out': "<b>सीख:</b> पैटर्न कायम है! तापमान में कमी को पूर्ववत करने से वृद्धि होती है। यही कारण है कि एक ऋणात्मक गुणा एक ऋणात्मक सकारात्मक है!",
    's3_sum': "<b>बिग फ्लिप पूरा हुआ!</b> ऋणात्मक × ऋणात्मक = धनात्मक।",

    's4_title': "4. प्रेडिक्टर चुनौती", 's4_obj': "गुम गुणक खोजने के लिए देखे गए पैटर्नों को लागू करना।",
    's4_hud1': "लक्ष्य: +20। परिवर्तन -4 है। स्लाइडर और 'मशीन चलाएं' का उपयोग करके गुणक खोजें।", 's4_step1_task': "<b>क्रिया:</b> 'प्रति टर्न परिवर्तन' डायल -4°C पर लॉक है। लक्ष्य अंतिम तापमान थर्मामीटर पर +20°C के रूप में दिखाया गया है। 'कितनी बार' स्लाइडर अनलॉक है। अंतिम तापमान लक्ष्य से मेल खाने के लिए स्लाइडर को सही मान पर खींचें।", 's4_step1_out': "<b>अवलोकन:</b> +20 तक पहुंचने के लिए आपको कमी (-4) को 5 बार (-5) पूर्ववत करना होगा। सही गुणक -5 है।",
    's4_hud2': "लक्ष्य: -15। परिवर्तन +5 है। स्लाइडर और 'मशीन चलाएं' का उपयोग करके गुणक खोजें।", 's4_step2_task': "<b>क्रिया:</b> एक नई चुनौती। 'प्रति टर्न परिवर्तन' +5°C पर लॉक है। लक्ष्य -15°C है। स्लाइडर को सही मान पर खींचें और 'मशीन चलाएं' पर क्लिक करें।", 's4_step2_out': "<b>अवलोकन:</b> -15 तक पहुंचने के लिए आपको वृद्धि (+5) को 3 बार (-3) पूर्ववत करना होगा। सही गुणक -3 है।",
    's4_sum': "<b>चुनौती जीती!</b> आपने अज्ञात मूल्यों की भविष्यवाणी करने के लिए नियमों का उपयोग किया।",

    's5_title': "5. साइन मशीन", 's5_obj': "केवल चिह्नों पर ध्यान केंद्रित करके पूर्णांक गुणा के नियमों को सामान्य बनाना।",
    's5_hud1': "प्रत्येक स्लॉट में एक टोकन खींचें।", 's5_step1_task': "<b>क्रिया:</b> एक नई साइन मशीन तैयार है। दो इनपुट स्लॉट में से प्रत्येक में एक टोकन (धनात्मक या ऋणात्मक) खींचें।", 's5_step1_out': "<b>अवलोकन:</b> मशीन में टोकन लोड किए गए हैं।",
    's5_hud2': "'PREDICT SIGN' पर क्लिक करें।", 's5_step2_task': "<b>क्रिया:</b> 'PREDICT SIGN' बटन पर क्लिक करें।", 's5_step2_out': "<b>अवलोकन:</b> मशीन चिह्नों को संसाधित करती है और रूल लॉग में परिणाम आउटपुट करती है।",
    's5_hud3': "लॉग को पूरा करने के लिए सभी 4 संयोजनों का परीक्षण करें।", 's5_step3_task': "<b>क्रिया:</b> रूल लॉग पूरा होने तक चिह्नों (+ +, + -, - +, - -) के सभी चार संभावित संयोजनों के साथ प्रयोग करें।", 's5_step3_out': "<b>सीख:</b> पूर्णांकों को गुणा करने के चार सार्वभौमिक नियम सामने आए हैं।",
    's5_sum': "<b>नियम सामान्यीकृत!</b> आपने पूर्णांक गुणा के चिह्नों में महारत हासिल कर ली है।"
  }
};
