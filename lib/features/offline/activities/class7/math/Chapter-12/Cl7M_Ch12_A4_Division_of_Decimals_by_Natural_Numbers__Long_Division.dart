// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DivisionofDecimalsbyNaturalNumbersLongDivisionApp());
}

class DivisionofDecimalsbyNaturalNumbersLongDivisionApp extends StatelessWidget {
  const DivisionofDecimalsbyNaturalNumbersLongDivisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Division of Decimals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const DivisionofDecimalsbyNaturalNumbersLongDivision(),
    );
  }
}

// ==========================================
// MAIN WIDGET
// ==========================================
class DivisionofDecimalsbyNaturalNumbersLongDivision extends StatefulWidget {
  const DivisionofDecimalsbyNaturalNumbersLongDivision({super.key});

  @override
  State<DivisionofDecimalsbyNaturalNumbersLongDivision> createState() =>
      _DivisionofDecimalsbyNaturalNumbersLongDivisionState();
}

class _DivisionofDecimalsbyNaturalNumbersLongDivisionState
    extends State<DivisionofDecimalsbyNaturalNumbersLongDivision>
    with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  final bool _isDark = true; // Hardcoded to dark mode as requested
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
  Offset _basePan = Offset.zero;

  // Interaction State
  double _mouseX = 0;
  double _mouseY = 0;
  String? _activeDragType;
  Offset _dragOffset = Offset.zero;

  // Temporary HUD
  String _hudMessage = '';
  bool _showHud = false;

  // Domain State
  final List<String> _types = ['tens', 'ones', 'tenths', 'hundredths', 'thousandths'];
  Map<String, int> _pool = {'tens': 0, 'ones': 0, 'tenths': 0, 'hundredths': 0, 'thousandths': 0};
  List<Map<String, int>> _containers = [];
  int _numContainers = 2;
  bool _isCompleted = false;

  double _machineAnim = 0;
  String? _machineProcessingType;
  int _machineProcessingAmount = 0;
  int _mathStateIdx = 0;

  // Audio players
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';
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

    _loadScenario(1);

    // Main Game Loop
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
      } else if (type == 'whir') {
        await _fxPlayer.play(AssetSource(_whirUrl), volume: 0.4);
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
      _lang = 'en'; // Reset language to default
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

      _pool = {'tens': 0, 'ones': 0, 'tenths': 0, 'hundredths': 0, 'thousandths': 0};
      _containers = [];
      _machineAnim = 0;
      _machineProcessingType = null;
      _machineProcessingAmount = 0;
      _mathStateIdx = 0;

      if (id == 1) { _numContainers = 2; _pool['ones'] = 5; }
      if (id == 2) { _numContainers = 3; _pool['ones'] = 9; _pool['tenths'] = 6; }
      if (id == 3) { _numContainers = 4; _pool['ones'] = 9; _pool['tenths'] = 5; }
      if (id == 4) { _numContainers = 4; _pool['tens'] = 1; _pool['ones'] = 3; _pool['tenths'] = 2; }
      if (id == 5) { _numContainers = 8; _pool['ones'] = 1; _pool['tenths'] = 2; _pool['hundredths'] = 8; }

      for (int i = 0; i < _numContainers; i++) {
        _containers.add({'tens': 0, 'ones': 0, 'tenths': 0, 'hundredths': 0, 'thousandths': 0});
      }
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    if (_machineAnim > 0) {
      setState(() {
        _machineAnim += 0.02;
        if (_machineAnim >= 1) {
          int tIdx = _types.indexOf(_machineProcessingType!);
          if (tIdx < _types.length - 1) {
            _pool[_types[tIdx + 1]] = (_pool[_types[tIdx + 1]] ?? 0) + (10 * _machineProcessingAmount);
            _playSound('pop');
          }
          _machineAnim = 0;
          _machineProcessingType = null;
          _machineProcessingAmount = 0;
          _mathStateIdx++;
          _checkStepAdvancement();
        }
      });
    }
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    setState(() {
      int totalSteps = (_scenario == 1) ? 3 : (_scenario == 2) ? 2 : (_scenario == 3) ? 6 : 1;
      _step = totalSteps + 1;
      _isCompleted = true;
      _completedScenarios.add(_scenario);
      _showSuccessPopup = true;
    });
    _playSound('success');
    _scrollToActiveStep();
  }

  void _checkUnsolvedAnswer() {
    bool poolEmpty = _types.every((t) => _pool[t] == 0);
    bool allEqual = true;
    if (_containers.isNotEmpty) {
      var first = _containers[0];
      for (var c in _containers) {
        for (var t in _types) {
          if (c[t] != first[t]) allEqual = false;
        }
      }
    }

    if (poolEmpty && allEqual) {
      _checkScenarioSuccess();
    } else {
      _playSound('error');
      _showTemporaryHUD(t('err_check'));
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
  final double _matW = 900;
  final double _matH = 600;
  final double _matX = -450;
  final double _matY = -250;

  Rect _getMachineHitbox() => Rect.fromLTWH(_matX + 250, _matY + 50, 160, 250);
  Rect _getContainersHitbox() => Rect.fromLTWH(_matX + 450, _matY + 50, 420, 480);
  Map<String, Rect> _getPoolHitboxes() {
    Map<String, Rect> boxes = {};
    for (int i = 0; i < _types.length; i++) {
      boxes[_types[i]] = Rect.fromLTWH(_matX + 20, _matY + 70 + i * 90, 200, 80);
    }
    return boxes;
  }

  Offset _screenToWorld(Offset screenPos, Size size) {
    double cx = size.width / 2 + _panX;
    double cy = size.height / 2 + _panY;
    return Offset((screenPos.dx - cx) / _zoom, (screenPos.dy - cy) / _zoom);
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (!_isCompleted && _machineAnim == 0) {
      var hitboxes = _getPoolHitboxes();
      for (String type in _types) {
        if (_pool[type]! > 0 && hitboxes[type]!.contains(pt)) {
          setState(() {
            _activeDragType = type;
            _dragOffset = Offset(hitboxes[type]!.center.dx - pt.dx, hitboxes[type]!.center.dy - pt.dy);
            _mouseX = pt.dx;
            _mouseY = pt.dy;
          });
          _playSound('tick');
          return;
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
          _zoom = (_baseZoom * details.scale).clamp(0.15, 2.0);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_activeDragType != null) {
      Offset pt = Offset(_mouseX, _mouseY);
      Rect mbox = _getMachineHitbox();
      Rect cbox = _getContainersHitbox();

      if (mbox.contains(pt)) {
        _handleRegroup(_activeDragType!);
      } else if (cbox.contains(pt)) {
        _handleDistribute(_activeDragType!);
      } else {
        _playSound('error');
      }

      setState(() {
        _activeDragType = null;
      });
    }
  }

  void _handleRegroup(String type) {
    if (type == 'thousandths') {
      _playSound('error');
      _showTemporaryHUD(t('err_regroup'));
      return;
    }
    int amount = _pool[type] ?? 0;
    if (amount < 1) return;

    if (_scenario == 1 && _step != 2) { _playSound('error'); return; }
    if (_scenario == 2) { _playSound('error'); return; }
    if (_scenario == 3 && _step != 2 && _step != 4 && _step != 6) { _playSound('error'); return; }

    setState(() {
      _pool[type] = 0;
      _machineProcessingType = type;
      _machineProcessingAmount = amount;
      _machineAnim = 0.01;
    });
    _playSound('whir');
  }

  void _handleDistribute(String type) {
    int amount = _pool[type] ?? 0;
    int toDistribute = (amount ~/ _numContainers) * _numContainers;

    if (toDistribute == 0) {
      _playSound('error');
      _showTemporaryHUD(t('err_dist'));
      return;
    }

    if (_scenario == 1 && ((_step == 1 && type != 'ones') || (_step == 3 && type != 'tenths'))) { _playSound('error'); return; }
    if (_scenario == 2 && ((_step == 1 && type != 'ones') || (_step == 2 && type != 'tenths'))) { _playSound('error'); return; }
    if (_scenario == 3 && ((_step == 1 && type != 'ones') || (_step == 3 && type != 'tenths') || (_step == 5 && type != 'hundredths') || (_step == 6 && type != 'thousandths'))) { _playSound('error'); return; }

    setState(() {
      _pool[type] = (_pool[type] ?? 0) - toDistribute;
      int perContainer = toDistribute ~/ _numContainers;
      for (int i = 0; i < _numContainers; i++) {
        _containers[i][type] = (_containers[i][type] ?? 0) + perContainer;
      }
      _mathStateIdx++;
    });
    _playSound('snap');
    _checkStepAdvancement();
  }

  void _checkStepAdvancement() {
    setState(() {
      if (_scenario == 1) {
        if (_step == 1 && _pool['ones'] == 1) _advanceStep();
        if (_step == 2 && _pool['tenths'] == 10) _advanceStep();
        if (_step == 3 && _pool['tenths'] == 0) _checkScenarioSuccess();
      } else if (_scenario == 2) {
        if (_step == 1 && _pool['ones'] == 0) _advanceStep();
        if (_step == 2 && _pool['tenths'] == 0) _checkScenarioSuccess();
      } else if (_scenario == 3) {
        if (_step == 1 && _pool['ones'] == 1) _advanceStep();
        if (_step == 2 && _pool['tenths'] == 15) _advanceStep();
        if (_step == 3 && _pool['tenths'] == 3) _advanceStep();
        if (_step == 4 && _pool['hundredths'] == 30) _advanceStep();
        if (_step == 5 && _pool['hundredths'] == 2) _advanceStep();
        if (_step == 6 && _pool['thousandths'] == 0) _checkScenarioSuccess();
      }
    });
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

    int totalSteps = (_scenario == 1) ? 3 : (_scenario == 2) ? 2 : (_scenario == 3) ? 6 : 1;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(5, 0))],
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
                        Text(t('s${_scenario}_obj'), style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
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
            
            // Footer (now part of scrolling view)
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
    bool hasHudTranslation = hudText != 's${_scenario}_hud$_step';

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
                          dragOffset: _dragOffset,
                          pool: _pool,
                          containers: _containers,
                          numContainers: _numContainers,
                          machineAnim: _machineAnim,
                          mathStateIdx: _mathStateIdx,
                          isDark: _isDark,
                          t: t,
                          matW: _matW,
                          matH: _matH,
                          matX: _matX,
                          matY: _matY,
                          types: _types,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Persistent Canvas HUD / Step Instruction
            if (!_isCompleted && (hasHudTranslation || _showHud))
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
  final Offset dragOffset;
  final Map<String, int> pool;
  final List<Map<String, int>> containers;
  final int numContainers;
  final double machineAnim;
  final int mathStateIdx;
  final bool isDark;
  final Function(String) t;
  final double matW, matH, matX, matY;
  final List<String> types;

  LabPainter({
    required this.scenario, required this.step, required this.zoom,
    required this.panX, required this.panY, required this.mouseX, required this.mouseY,
    required this.activeDragType, required this.dragOffset, required this.pool,
    required this.containers, required this.numContainers, required this.machineAnim,
    required this.mathStateIdx, required this.isDark, required this.t,
    required this.matW, required this.matH, required this.matX, required this.matY, required this.types,
  });

  Color get outLineCol => Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    _drawPool(canvas);
    _drawMachine(canvas);
    _drawContainersArea(canvas);
    _drawMathBoard(canvas);

    if (activeDragType != null && machineAnim == 0) {
      canvas.saveLayer(Rect.fromLTWH(-5000, -5000, 10000, 10000), Paint()..color = Colors.white.withOpacity(0.8));
      _drawBlockIcon(canvas, activeDragType!, mouseX + dragOffset.dx, mouseY + dragOffset.dy, 1.2);
      canvas.restore();
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

  void _draw3DCube(Canvas canvas, double x, double y, double w, double h, double d, Color colorTop, Color colorFront, Color colorRight) {
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = colorFront);
    Path top = Path()..moveTo(x, y)..lineTo(x + d, y - d)..lineTo(x + w + d, y - d)..lineTo(x + w, y)..close();
    canvas.drawPath(top, Paint()..color = colorTop);
    Path right = Path()..moveTo(x + w, y)..lineTo(x + w + d, y - d)..lineTo(x + w + d, y + h - d)..lineTo(x + w, y + h)..close();
    canvas.drawPath(right, Paint()..color = colorRight);
    
    Paint stroke = Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), stroke);
    canvas.drawPath(top, stroke);
    canvas.drawPath(right, stroke);
  }

  void _drawBlockIcon(Canvas canvas, String type, double x, double y, [double size = 1.0]) {
    canvas.save(); canvas.translate(x, y); canvas.scale(size, size);
    if (type == 'tens') _draw3DCube(canvas, -20, -40, 40, 80, 15, const Color(0xFF60A5FA), const Color(0xFF3B82F6), const Color(0xFF2563EB));
    else if (type == 'ones') _draw3DCube(canvas, -20, -20, 40, 40, 15, const Color(0xFF34D399), const Color(0xFF10B981), const Color(0xFF059669));
    else if (type == 'tenths') _draw3DCube(canvas, -20, -5, 40, 10, 15, const Color(0xFFFCD34D), const Color(0xFFF59E0B), const Color(0xFFD97706));
    else if (type == 'hundredths') _draw3DCube(canvas, -5, -20, 10, 40, 10, const Color(0xFFA78BFA), const Color(0xFF8B5CF6), const Color(0xFF6D28D9));
    else if (type == 'thousandths') _draw3DCube(canvas, -5, -5, 10, 10, 5, const Color(0xFFF472B6), const Color(0xFFEC4899), const Color(0xFFDB2777));
    canvas.restore();
  }

  void _drawPool(Canvas canvas) {
    _drawRoundedRect(canvas, matX, matY + 20, 240, 500, 16, const Color(0x990F172A), const Color(0xFF334155), 4);
    _drawTextOutline(canvas, "BLOCK POOL", matX + 120, matY + 45, 16, const Color(0xFF94A3B8), Colors.transparent, 0);

    for (int i = 0; i < types.length; i++) {
      String type = types[i];
      double boxX = matX + 20, boxY = matY + 70 + i * 90;
      int count = pool[type] ?? 0;
      bool isHover = activeDragType == type;

      if (count > 0 || isHover) {
        Color fill = isHover ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.2);
        Color stroke = isHover ? Colors.white : const Color(0xFF475569);
        _drawRoundedRect(canvas, boxX, boxY, 200, 80, 8, fill, stroke, 2);

        Map<String, Color> colors = {'tens': const Color(0xFF60A5FA), 'ones': const Color(0xFF34D399), 'tenths': const Color(0xFFFCD34D), 'hundredths': const Color(0xFFA78BFA), 'thousandths': const Color(0xFFF472B6)};
        _drawTextOutline(canvas, type.toUpperCase(), boxX + 50, boxY + 20, 12, colors[type]!, Colors.transparent, 0);
        _drawTextOutline(canvas, count.toString(), boxX + 30, boxY + 50, 28, Colors.white, Colors.transparent, 0);

        for (int j = 0; j < min(count, 5); j++) {
          _drawBlockIcon(canvas, type, boxX + 90 + j * 15, boxY + 55, 0.5);
        }
        if (count > 5) _drawTextOutline(canvas, "+", boxX + 180, boxY + 45, 20, const Color(0xFF94A3B8), Colors.transparent, 0);
      }
    }
  }

  void _drawMachine(Canvas canvas) {
    double mx = matX + 250, my = matY + 50;
    
    if (activeDragType != null && activeDragType != 'thousandths') {
      canvas.drawRect(Rect.fromLTWH(mx, my, 160, 250), Paint()..color = const Color(0xFF60A5FA).withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    }

    Path hopper = Path()..moveTo(mx, my)..lineTo(mx + 160, my)..lineTo(mx + 110, my + 60)..lineTo(mx + 50, my + 60)..close();
    canvas.drawPath(hopper, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawPath(hopper, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 4);

    _drawRoundedRect(canvas, mx + 20, my + 60, 120, 180, 16, const Color(0xFF34D399), const Color(0xFF059669), 6);
    _drawRoundedRect(canvas, mx + 40, my + 90, 80, 40, 6, const Color(0xFF0F172A), const Color(0xFF334155), 4);

    Path chute = Path()..moveTo(mx + 40, my + 240)..lineTo(mx - 20, my + 280)..lineTo(mx + 20, my + 300)..lineTo(mx + 80, my + 240)..close();
    canvas.drawPath(chute, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawPath(chute, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2);

    if (machineAnim > 0) {
      double rot = machineAnim * pi * 4;
      canvas.save(); canvas.translate(mx + 60, my + 180); canvas.rotate(rot); _drawTextOutline(canvas, "⚙️", 0, 0, 24, Colors.white, Colors.transparent, 0); canvas.restore();
      canvas.save(); canvas.translate(mx + 100, my + 200); canvas.rotate(-rot); _drawTextOutline(canvas, "⚙️", 0, 0, 20, Colors.white, Colors.transparent, 0); canvas.restore();
      _drawTextOutline(canvas, "⚙️", mx + 80, my + 110, 24, Colors.white, Colors.transparent, 0);
    } else {
      _drawTextOutline(canvas, "REGROUP", mx + 80, my + 110, 12, const Color(0xFF059669), Colors.transparent, 0);
      canvas.save(); canvas.translate(mx + 60, my + 180); _drawTextOutline(canvas, "⚙️", 0, 0, 24, Colors.white, Colors.transparent, 0); canvas.restore();
      canvas.save(); canvas.translate(mx + 100, my + 200); _drawTextOutline(canvas, "⚙️", 0, 0, 20, Colors.white, Colors.transparent, 0); canvas.restore();
    }
  }

  void _drawContainersArea(Canvas canvas) {
    double cx = matX + 450, cy = matY + 50, cw = 420, ch = 480;
    
    if (activeDragType != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx, cy, cw, ch), const Radius.circular(16)), Paint()..color = const Color(0xFF4ADE80).withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
      _drawRoundedRect(canvas, cx, cy, cw, ch, 16, const Color(0x660F172A), const Color(0xFF4ADE80), 4);
    } else {
      _drawRoundedRect(canvas, cx, cy, cw, ch, 16, const Color(0x660F172A), const Color(0xFF334155), 2);
    }

    _drawTextOutline(canvas, "CONTAINERS ($numContainers)", cx + cw / 2, cy + 25, 16, const Color(0xFF94A3B8), Colors.transparent, 0);

    int cols = numContainers > 4 ? 4 : numContainers;
    int rows = (numContainers / cols).ceil();
    double boxW = (cw - 40) / cols;
    double boxH = (ch - 60) / rows;

    for (int i = 0; i < numContainers; i++) {
      int r = i ~/ cols;
      int c = i % cols;
      double px = cx + 20 + c * boxW;
      double py = cy + 50 + r * boxH;

      _drawRoundedRect(canvas, px + 10, py + 10, boxW - 20, boxH - 20, 8, const Color(0x1AE0F2FE), const Color(0xFF64748B), 2);

      if (i < containers.length) {
        var cont = containers[i];
        double bx = px + 25, by = py + 40;
        int drawCount = 0;
        for (String type in types) {
          int cCount = cont[type] ?? 0;
          for (int j = 0; j < cCount; j++) {
            _drawBlockIcon(canvas, type, bx + (drawCount % 4) * 18, by + (drawCount ~/ 4) * 18 + 10, 0.35);
            drawCount++;
          }
        }
      }
    }
  }

  void _drawMathBoard(Canvas canvas) {
    double x = matX + 880, y = matY + 50;
    _drawRoundedRect(canvas, x, y, 260, 480, 12, const Color(0xFF0F172A), const Color(0xFF475569), 4);
    _drawTextOutline(canvas, "LONG DIVISION", x + 130, y + 25, 16, const Color(0xFF94A3B8), Colors.transparent, 0);

    Map<int, List<Map<String, dynamic>>> mathPaths = {
      1: [
        {'q': "     ", 'lines': ["2 ) 5  "]},
        {'q': "  2  ", 'lines': ["2 ) 5  ", "  - 4  ", "  ---  ", "    1  "]},
        {'q': "  2. ", 'lines': ["2 ) 5.0", "  - 4  ", "  ---  ", "    1 0"]},
        {'q': "  2.5", 'lines': ["2 ) 5.0", "  - 4  ", "  ---  ", "    1 0", "  - 1 0", "  ---  ", "      0"]}
      ],
      2: [
        {'q': "       ", 'lines': ["3 ) 9.6"]},
        {'q': "  3.   ", 'lines': ["3 ) 9.6", "  - 9  ", "  ---  ", "    0 6"]},
        {'q': "  3.2  ", 'lines': ["3 ) 9.6", "  - 9  ", "  ---  ", "    0 6", "  -   6", "  ---  ", "      0"]}
      ],
      3: [
        {'q': "       ", 'lines': ["4 ) 9.5  "]},
        {'q': "  2    ", 'lines': ["4 ) 9.5  ", "  - 8  ", "  ---  ", "    1  "]},
        {'q': "  2.   ", 'lines': ["4 ) 9.5  ", "  - 8  ", "  ---  ", "    1 5"]},
        {'q': "  2.3  ", 'lines': ["4 ) 9.5  ", "  - 8  ", "  ---  ", "    1 5", "  - 1 2", "  ---  ", "      3"]},
        {'q': "  2.3  ", 'lines': ["4 ) 9.50 ", "  - 8  ", "  ---  ", "    1 5", "  - 1 2", "  ---  ", "      3 0"]},
        {'q': "  2.37 ", 'lines': ["4 ) 9.50 ", "  - 8  ", "  ---  ", "    1 5", "  - 1 2", "  ---  ", "      3 0", "  - 2 8", "  ---  ", "        2"]},
        {'q': "  2.37 ", 'lines': ["4 ) 9.500", "  - 8  ", "  ---  ", "    1 5", "  - 1 2", "  ---  ", "      3 0", "  - 2 8", "  ---  ", "        2 0"]},
        {'q': "  2.375", 'lines': ["4 ) 9.500", "  - 8  ", "  ---  ", "    1 5", "  - 1 2", "  ---  ", "      3 0", "  - 2 8", "  ---  ", "        2 0", "  - 2 0", "  ---  ", "          0"]}
      ],
      4: [
        {'q': "        ", 'lines': ["4 ) 13.2"]},
        {'q': "        ", 'lines': ["4 ) 13.2"]},
        {'q': "    3.  ", 'lines': ["4 ) 13.2", "  - 12  ", "  ----  ", "     1 2"]},
        {'q': "    3.  ", 'lines': ["4 ) 13.2", "  - 12  ", "  ----  ", "     1 2"]},
        {'q': "    3.3 ", 'lines': ["4 ) 13.2", "  - 12  ", "  ----  ", "     1 2", "   - 1 2", "   ---- ", "       0"]}
      ],
      5: [
        {'q': "        ", 'lines': ["8 ) 1.28"]},
        {'q': "  0.    ", 'lines': ["8 ) 1.28", "  - 0   ", "  ---   ", "    1 2 "]},
        {'q': "  0.1   ", 'lines': ["8 ) 1.28", "  - 0   ", "  ---   ", "    1 2 ", "  -   8 ", "  ----- ", "      4 "]},
        {'q': "  0.1   ", 'lines': ["8 ) 1.28", "  - 0   ", "  ---   ", "    1 2 ", "  -   8 ", "  ----- ", "      4 8"]},
        {'q': "  0.16  ", 'lines': ["8 ) 1.28", "  - 0   ", "  ---   ", "    1 2 ", "  -   8 ", "  ----- ", "      4 8", "    - 4 8", "    -----", "        0"]}
      ]
    };

    var path = mathPaths[scenario];
    if (path == null) return;
    var frame = path[min(mathStateIdx, path.length - 1)];

    _drawTextOutline(canvas, frame['q'], x + 30, y + 80, 24, const Color(0xFF38BDF8), Colors.transparent, 0, align: TextAlign.left);
    canvas.drawLine(Offset(x + 60, y + 105), Offset(x + 240, y + 105), Paint()..color = Colors.white..strokeWidth = 2);

    List<String> lines = frame['lines'];
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      double ly = y + 140 + i * 30;
      Color col = Colors.white;
      if (line.contains('-') && !line.contains(')')) col = const Color(0xFF94A3B8);
      else if (line.trim().startsWith('-')) col = const Color(0xFFF87171);
      
      TextPainter tp = TextPainter(text: TextSpan(text: line, style: TextStyle(color: col, fontSize: 24, fontFamily: 'monospace', fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr, textAlign: TextAlign.left);
      tp.layout();
      tp.paint(canvas, Offset(x + 30, ly - tp.height / 2));
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
    'shutterTitle': "The Regrouping Machine: Visualizing Decimal Division", 'appTitle': "The Regrouping Machine", 'appSubtitle': "Class 7 • ANOTHER PEEK BEYOND THE POINT", 'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done",
    'actTitle': "Action:", 'obsLbl': "Observation:", 'learnLbl': "Learning:", 'summaryTitle': "Goal Reached!", 'checkAnswer': "Check Answer",
    'hudNext': "Next Step", 'err_dist': "Not enough to distribute equally. Try regrouping!", 'err_regroup': "Cannot regroup this block any further.", 'err_check': "Containers are not equally divided or blocks remain in the pool.",
    'finalSuccessTitle': "Activity Completed!", 'finalSuccessDesc': "You have successfully mastered Decimal Division using Regrouping.", 
    'reset': 'Reset', 'close': 'Close', 'guideNextScenario': 'Scenario completed! Select the next scenario from the sidebar.', 'allScenariosComplete': 'All scenarios completed! Great job.',

    's1_title': "1. Sharing Whole Cakes (5 ÷ 2)", 's1_obj': "Understand how a remainder in whole number division leads to a decimal quotient by regrouping 'Ones' into 'Tenths'.",
    's1_hud1': "DRAG the 'One' blocks pile to the distribution containers area.", 's1_step1_task': "You have 5 'One' blocks (cakes) and 2 containers (plates). DRAG the 'One' blocks one by one and DROP them equally into the 2 containers.", 's1_step1_obs': "2 'One' blocks are placed in each container, and 1 'One' block remains undistributed.", 's1_step1_learn': "We divide the whole numbers first.",
    's1_hud2': "DRAG the leftover 'One' block to the Regrouping Machine.", 's1_step2_task': "The remaining 'One' block cannot be shared equally. DRAG the leftover 'One' block to the 'Regrouping Machine'.", 's1_step2_obs': "The machine animates, consuming the cube-shaped 'One' block. A decimal point visually appears next to the quotient 2, making it 2.. A zero appears next to the remainder 1, making it 10.", 's1_step2_learn': "A remainder of 1 One is equal to 10 Tenths. This is the core of decimal division.",
    's1_hud3': "DRAG the 10 'Tenths' flats to the containers.", 's1_step3_task': "The machine has produced 10 'Tenths' flats (slices). DRAG these 'Tenths' flats and DROP them equally into the 2 containers.", 's1_step3_obs': "5 'Tenths' flats are placed in each of the 2 containers. There are no blocks left over.", 's1_step3_learn': "The decimal parts are distributed, giving an exact decimal quotient.",
    's1_final': "5 divided by 2 is 2.5. Each container has 2 whole blocks and 5 tenths, which is 2.5. You have successfully regrouped the leftover whole to find the decimal part!",

    's2_title': "2. Pre-Sliced Cake (9.6 ÷ 3)", 's2_obj': "To divide a decimal number by a whole number where regrouping is not immediately required.",
    's2_hud1': "DRAG the 'One' blocks pile to the 3 containers.", 's2_step1_task': "First, DRAG and DROP the 'One' blocks equally into the 3 containers.", 's2_step1_obs': "3 'One' blocks are placed in each container. No 'One' blocks remain.", 's2_step1_learn': "The whole part (9) divides evenly by 3.",
    's2_hud2': "DRAG the 'Tenths' flats pile to the 3 containers.", 's2_step2_task': "Now, DRAG and DROP the 6 'Tenths' flats equally into the 3 containers.", 's2_step2_obs': "2 'Tenths' flats are placed in each container. No 'Tenths' flats remain.", 's2_step2_learn': "The decimal part (.6) divides evenly by 3.",
    's2_final': "9.6 divided by 3 is 3.2. You shared the whole parts first, then the decimal parts. Great job!",

    's3_title': "3. The Multi-Step Bakery Division (9.5 ÷ 4)", 
    's3_obj': "To solve a complex division problem (9.5 ÷ 4) that requires multiple regrouping steps, from 'Ones' to 'Tenths' and 'Tenths' to 'Hundredths'.",
    's3_hud1': "DRAG the 'One' blocks pile to the 4 containers.", 
    's3_step1_task': "You have 9 'One' blocks and 5 'Tenths' flats (9.5) to share among 4 containers. DRAG and DROP the 'One' blocks equally into the 4 containers.", 
    's3_step1_obs': "2 'One' blocks are placed in each container, and 1 'One' block remains.", 
    's3_step1_learn': "The long division shows 4)9.5 with quotient 2 and remainder 1.",
    's3_hud2': "DRAG the leftover 'One' block to the Regrouping Machine.", 
    's3_step2_task': "The leftover 'One' block cannot be shared. DRAG it to the 'Regrouping Machine'.", 
    's3_step2_obs': "The machine converts the 'One' block into 10 'Tenths' flats. They join the existing 5 to make a total of 15 'Tenths' flats in the workspace.", 
    's3_step2_learn': "The decimal point is carried up to the quotient, and 5 is brought down to make 15 tenths.",
    's3_hud3': "DRAG the 'Tenths' flats pile to the 4 containers.", 
    's3_step3_task': "You now have 15 'Tenths' flats. DRAG and DROP them equally into the 4 containers.", 
    's3_step3_obs': "3 'Tenths' flats are placed in each container, and 3 'Tenths' flats remain.", 
    's3_step3_learn': "The quotient updates to 2.3, leaving a remainder of 3 tenths.",
    's3_hud4': "DRAG the leftover 'Tenths' to the Regrouping Machine.", 
    's3_step4_task': "The 3 leftover 'Tenths' flats cannot be shared. DRAG them to the 'Regrouping Machine'.", 
    's3_step4_obs': "The machine converts the 3 'Tenths' flats into 30 'Hundredths' cubes.", 
    's3_step4_learn': "A 0 is added to the remainder 3 in the long division, making it 30 hundredths.",
    's3_hud5': "DRAG the 'Hundredths' cubes pile to the 4 containers.", 
    's3_step5_task': "You have 30 'Hundredths' cubes. DRAG and DROP them equally into the 4 containers.", 
    's3_step5_obs': "7 'Hundredths' cubes are placed in each container, and 2 'Hundredths' cubes remain.", 
    's3_step5_learn': "The quotient updates to 2.37, leaving a remainder of 2 hundredths.",
    's3_hud6': "Regroup the last 2 'Hundredths', then distribute the 'Thousandths'.", 
    's3_step6_task': "This is the last step! DRAG the final 2 'Hundredths' cubes to the 'Regrouping Machine'. Then, distribute the resulting 'Thousandths' blocks.", 
    's3_step6_obs': "The 2 'Hundredths' cubes become 20 'Thousandths' blocks. 5 'Thousandths' blocks are placed in each of the 4 containers. None remain.", 
    's3_step6_learn': "The long division completes with a remainder of 0. The final quotient is 2.375.",
    's3_final': "9.5 ÷ 4 = 2.375. Each container now holds 2 'Ones', 3 'Tenths', 7 'Hundredths', and 5 'Thousandths'. Mission Accomplished!",

    's4_title': "4. Unsolved Challenge (13.2 ÷ 4)", 's4_obj': "Apply the regrouping skill to solve 13.2 ÷ 4 without explicit step-by-step instructions.",
    's4_hud1': "Divide the blocks equally among the 4 containers. Use the Regrouping Machine.", 's4_step1_task': "Divide the blocks for 13.2 equally among the 4 containers. Use the 'Regrouping Machine' whenever needed. CLICK 'Check Answer' when done.", 's4_step1_obs': "The workspace is open for you to manipulate.", 's4_step1_learn': "You must deduce when to regroup based on what cannot be divided evenly.",
    's4_final': "Correct! 13.2 ÷ 4 = 3.3. You successfully regrouped the Ten and the leftover One.",

    's5_title': "5. Unsolved Challenge (1.28 ÷ 8)", 's5_obj': "Solve a division problem (1.28 ÷ 8) requiring regrouping from the very beginning.",
    's5_hud1': "Divide the blocks equally among the 8 containers. Use the Regrouping Machine.", 's5_step1_task': "Divide blocks for 1.28 equally among the 8 containers. Use the 'Regrouping Machine' as needed. CLICK 'Check Answer' when finished.", 's5_step1_obs': "The quotient starts with '0.' because the first block ('One') cannot be distributed without regrouping.", 's5_step1_learn': "Sometimes you must immediately regroup into smaller decimal fractions.",
    's5_final': "Perfect! 1.28 ÷ 8 = 0.16. You correctly regrouped to create enough hundredths to share."
  },
  'hi': {
    'shutterTitle': "दशमलव विभाजन", 'appTitle': "दशमलव विभाजन", 'appSubtitle': "कक्षा 7 • रिग्रुपिंग मशीन", 'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण",
    'actTitle': "कार्य:", 'obsLbl': "अवलोकन:", 'learnLbl': "सीख:", 'summaryTitle': "लक्ष्य प्राप्त हुआ!", 'checkAnswer': "उत्तर जांचें",
    'hudNext': "अगला कदम", 'err_dist': "समान रूप से बांटने के लिए पर्याप्त नहीं है। रिग्रुपिंग का प्रयास करें!", 'err_regroup': "इस ब्लॉक को और छोटा नहीं किया जा सकता।", 'err_check': "कंटेनर समान रूप से विभाजित नहीं हैं या पूल में ब्लॉक शेष हैं।",
    'finalSuccessTitle': "गतिविधि पूरी हुई!", 'finalSuccessDesc': "आपने रिग्रुपिंग के साथ दशमलव विभाजन को सफलतापूर्वक सीख लिया है।",
    'reset': "रीसेट", 'close': "बंद करें", 'guideNextScenario': "परिदृश्य पूरा हुआ! साइडबार से अगला परिदृश्य चुनें।", 'allScenariosComplete': "सभी परिदृश्य पूरे हुए! बहुत बढ़िया।",

    's1_title': "1. पूरे केक बांटना (5 ÷ 2)", 's1_obj': "समझें कि रिग्रुपिंग द्वारा कैसे एक शेषफल दशमलव भागफल की ओर ले जाता है।",
    's1_hud1': "'वन' (इकाई) ब्लॉक के ढेर को कंटेनर क्षेत्र में खींचें।", 's1_step1_task': "'वन' ब्लॉक के ढेर को खींचें और उन्हें 2 कंटेनरों में समान रूप से छोड़ें।", 's1_step1_obs': "प्रत्येक कंटेनर में 2 'वन' ब्लॉक रखे गए हैं, और 1 'वन' ब्लॉक पूल में शेष है।", 's1_step1_learn': "हम पहले पूर्ण संख्याओं को विभाजित करते हैं।",
    's1_hud2': "बचे हुए 'वन' ब्लॉक को रिग्रुपिंग मशीन में खींचें।", 's1_step2_task': "बचे हुए 'वन' ब्लॉक को समान रूप से साझा नहीं किया जा सकता है। इसे 'रिग्रुपिंग मशीन' में खींचें।", 's1_step2_obs': "मशीन 'वन' ब्लॉक को 10 'टेंथ्स' (दसवें) में बदल देती है।", 's1_step2_learn': "1 इकाई 10 दसवें के बराबर है। यह दशमलव विभाजन का मूल है।",
    's1_hud3': "10 'टेंथ्स' को कंटेनरों में खींचें।", 's1_step3_task': "'टेंथ्स' को खींचें और उन्हें 2 कंटेनरों में समान रूप से छोड़ें।", 's1_step3_obs': "प्रत्येक कंटेनर में 5 'टेंथ्स' रखे गए हैं। कुछ भी शेष नहीं है।", 's1_step3_learn': "दशमलव भागों को वितरित किया जाता है, जिससे एक सटीक दशमलव भागफल मिलता है।",
    's1_final': "5 को 2 से विभाजित करने पर 2.5 प्राप्त होता है। आपने बचे हुए भाग को सफलतापूर्वक रिग्रुप किया!",

    's2_title': "2. कटा हुआ केक (9.6 ÷ 3)", 's2_obj': "एक दशमलव संख्या को पूर्ण संख्या से विभाजित करना जहां तुरंत रिग्रुपिंग की आवश्यकता नहीं होती है।",
    's2_hud1': "'वन' ब्लॉक को 3 कंटेनरों में खींचें।", 's2_step1_task': "सबसे पहले, 'वन' ब्लॉक को खींचें और 3 कंटेनरों में समान रूप से छोड़ें।", 's2_step1_obs': "प्रत्येक कंटेनर में 3 'वन' ब्लॉक रखे गए हैं। कोई भी 'वन' ब्लॉक शेष नहीं है।", 's2_step1_learn': "पूर्ण भाग (9) 3 से समान रूप से विभाजित होता है।",
    's2_hud2': "'टेंथ्स' को 3 कंटेनरों में खींचें।", 's2_step2_task': "अब, 6 'टेंथ्स' को खींचें और 3 कंटेनरों में समान रूप से छोड़ें।", 's2_step2_obs': "प्रत्येक कंटेनर में 2 'टेंथ्स' रखे गए हैं। कोई 'टेंथ्स' शेष नहीं है।", 's2_step2_learn': "दशमलव भाग (.6) 3 से समान रूप से विभाजित होता है।",
    's2_final': "9.6 को 3 से विभाजित करने पर 3.2 प्राप्त होता है। बहुत बढ़िया!",

    's3_title': "3. बेकरी विभाजन (9.5 ÷ 4)", 's3_obj': "एक जटिल समस्या (9.5 ÷ 4) को हल करना जिसमें कई रिग्रुपिंग चरणों की आवश्यकता होती है।",
    's3_hud1': "'वन' ब्लॉक को 4 कंटेनरों में खींचें।", 's3_step1_task': "'वन' ब्लॉक को खींचें और 4 कंटेनरों में समान रूप से छोड़ें।", 's3_step1_obs': "प्रत्येक कंटेनर में 2 'वन' ब्लॉक रखे गए हैं, और 1 'वन' ब्लॉक शेष है।", 's3_step1_learn': "हम जितना कर सकते हैं वितरित करते हैं, एक शेषफल छोड़ते हैं।",
    's3_hud2': "बचे हुए 'वन' ब्लॉक को रिग्रुपिंग मशीन में खींचें।", 's3_step2_task': "बचे हुए 'वन' ब्लॉक को साझा नहीं किया जा सकता। इसे 'रिग्रुपिंग मशीन' में खींचें।", 's3_step2_obs': "मशीन 'वन' ब्लॉक को 10 'टेंथ्स' में बदल देती है। वे कुल 15 बनाने के लिए मौजूदा 5 में शामिल हो जाते हैं।", 's3_step2_learn': "1 इकाई = 10 दसवें। हम इसे उन दसवें हिस्से में जोड़ते हैं जो हमारे पास पहले से थे।",
    's3_hud3': "'टेंथ्स' को 4 कंटेनरों में खींचें।", 's3_step3_task': "अब आपके पास 15 'टेंथ्स' हैं। उन्हें 4 कंटेनरों में समान रूप से छोड़ें।", 's3_step3_obs': "प्रत्येक कंटेनर में 3 'टेंथ्स' रखे गए हैं, और 3 शेष हैं।", 's3_step3_learn': "हम अगले स्थान मान को वितरित करना जारी रखते हैं।",
    's3_hud4': "बचे हुए 'टेंथ्स' को रिग्रुपिंग मशीन में खींचें।", 's3_step4_task': "3 बचे हुए 'टेंथ्स' को 'रिग्रुपिंग मशीन' में खींचें।", 's3_step4_obs': "मशीन 3 'टेंथ्स' को 30 'हंड्रेडथ्स' (सौवें) में बदल देती है।", 's3_step4_learn': "3 दसवें = 30 सौवें। हम शेष को अगले छोटे स्थान मान में ले जाते हैं।",
    's3_hud5': "'हंड्रेडथ्स' को 4 कंटेनरों में खींचें।", 's3_step5_task': "आपके पास 30 'हंड्रेडथ्स' हैं। उन्हें 4 कंटेनरों में समान रूप से छोड़ें।", 's3_step5_obs': "प्रत्येक कंटेनर में 7 'हंड्रेडथ्स' रखे गए हैं, और 2 शेष हैं।", 's3_step5_learn': "सौवें हिस्से का वितरण।",
    's3_hud6': "अंतिम 2 'हंड्रेडथ्स' को रिग्रुप करें, फिर वितरित करें।", 's3_step6_task': "अंतिम 2 'हंड्रेडथ्स' को मशीन में खींचें। फिर, परिणामी 'थाउजेंडथ्स' (हजारवें) को वितरित करें।", 's3_step6_obs': "2 'हंड्रेडथ्स', 20 'थाउजेंडथ्स' बन जाते हैं। 5 'थाउजेंडथ्स' 4 कंटेनरों में से प्रत्येक में जाते हैं। कोई शेष नहीं।", 's3_step6_learn': "विभाजन तब पूरा होता है जब कोई शेष नहीं बचता है।",
    's3_final': "9.5 ÷ 4 = 2.375. आपने सफलतापूर्वक कई दशमलव स्थानों पर शेषफल को ट्रैक किया!",

    's4_title': "4. अनसुलझी चुनौती (13.2 ÷ 4)", 's4_obj': "सीखे गए कौशल को 13.2 ÷ 4 हल करने के लिए लागू करें।",
    's4_hud1': "ब्लॉकों को 4 कंटेनरों में समान रूप से विभाजित करें। मशीन का उपयोग करें।", 's4_step1_task': "13.2 के लिए ब्लॉकों को 4 कंटेनरों में समान रूप से विभाजित करें। आवश्यकतानुसार 'रिग्रुपिंग मशीन' का उपयोग करें। हो जाने पर 'उत्तर जांचें' पर क्लिक करें।", 's4_step1_obs': "कार्यक्षेत्र आपके हेरफेर के लिए खुला है।", 's4_step1_learn': "आपको यह अनुमान लगाना होगा कि कब रिग्रुप करना है।",
    's4_final': "सही! 13.2 ÷ 4 = 3.3. आपने दहाई और बची हुई इकाई को सफलतापूर्वक रिग्रुप किया।",

    's5_title': "5. अनसुलझी चुनौती (1.28 ÷ 8)", 's5_obj': "शुरुआत से ही रिग्रुपिंग की आवश्यकता वाली समस्या (1.28 ÷ 8) को हल करें।",
    's5_hud1': "ब्लॉकों को 8 कंटेनरों में समान रूप से विभाजित करें। मशीन का उपयोग करें।", 's5_step1_task': "1.28 के लिए ब्लॉकों को 8 कंटेनरों में समान रूप से विभाजित करें। मशीन का उपयोग करें। हो जाने पर 'उत्तर जांचें' पर क्लिक करें।", 's5_step1_obs': "भागफल '0.' से शुरू होता है क्योंकि पहले ब्लॉक को रिग्रुपिंग के बिना वितरित नहीं किया जा सकता है।", 's5_step1_learn': "कभी-कभी आपको तुरंत छोटे दशमलव अंशों में रिग्रुप करना होता है।",
    's5_final': "बिल्कुल सही! 1.28 ÷ 8 = 0.16. आपने साझा करने के लिए पर्याप्त सौवें हिस्से बनाने के लिए सही ढंग से रिग्रुप किया।"
  },
  };