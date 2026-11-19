// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArithmeticMeanApp());
}

class ArithmeticMeanApp extends StatelessWidget {
  const ArithmeticMeanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Arithmetic Mean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const MeasuresofCentralTendencyArithmeticMean(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class SimItem {
  int id;
  double val;
  double targetVal;
  double x, y;

  SimItem({
    required this.id,
    required this.val,
    required this.targetVal,
    required this.x,
    required this.y,
  });
}

class DraggableItem {
  int srcId;
  double val;
  double x, y;

  DraggableItem({
    required this.srcId,
    required this.val,
    required this.x,
    required this.y,
  });
}

// ==========================================
// MAIN WIDGET
// ==========================================
class MeasuresofCentralTendencyArithmeticMean extends StatefulWidget {
  const MeasuresofCentralTendencyArithmeticMean({super.key});

  @override
  State<MeasuresofCentralTendencyArithmeticMean> createState() => _MeasuresofCentralTendencyArithmeticMeanState();
}

class _MeasuresofCentralTendencyArithmeticMeanState extends State<MeasuresofCentralTendencyArithmeticMean> with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;

  // Lab State
  int _scenario = 1;
  int _step = 1; // 1-based indexing for steps
  bool _showSuccessPopup = false;
  final ScrollController _sidebarScrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  // Viewport State
  double _zoom = 1.0;
  double _panX = 0;
  double _panY = 0;
  double _baseZoom = 1.0;

  // Simulation Entities
  List<SimItem> _sources = [];
  SimItem _target = SimItem(id: -1, val: 0, targetVal: 0, x: 0, y: 0);
  List<DraggableItem> _draggables = [];
  
  bool _isAnimating = false;
  double _animProgress = 0;
  
  Rect? _btnActionRect; // Canvas button bounds for "Share Equally"
  Rect? _btnCombineRect; // Canvas button for S5 combine

  String _hudMessage = '';
  bool _showHud = false;

  // Audio Engine
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Audio Sources
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_2954.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';
  static const String _snapUrl = 'audio/class7/mixkit_392.mp3';
  static const String _whirUrl = 'audio/class7/mixkit_3104.mp3';

  late AnimationController _ticker;

  final Map<int, List<double>> _scenarioData = {
    1: [3, 8, 10, 5, 4],
    2: [2, 7, 9, 4, 3],
    3: [6, 2, 9, 5, 4, 6, 3, 5],
    4: [17, 18, 17, 16, 19, 17, 18],
    5: [1555, 1670, 1750, 2013, 2040, 2126],
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
    _inputController.dispose();
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
      } else if (type == 'pop' || type == 'tick') {
        await _clickPlayer.play(AssetSource(_clickUrl), volume: 0.5);
      } else if (type == 'snap') {
        await _clickPlayer.play(AssetSource(_snapUrl), volume: 0.6);
      } else if (type == 'success') {
        await _successPlayer.play(AssetSource(_successUrl), volume: 0.6);
      } else if (type == 'error') {
        await _errorPlayer.play(AssetSource(_errorUrl), volume: 0.5);
      } else if (type == 'whir') {
        await _fxPlayer.play(AssetSource(_whirUrl), volume: 0.4);
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
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
    Future.delayed(const Duration(milliseconds: 800), () {
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
      _step = 1;
      _showSuccessPopup = false;
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
      
      _isAnimating = false;
      _animProgress = 0;
      _draggables.clear();
      _sources.clear();
      _inputController.clear();
      _showHud = false;

      List<double> values = _scenarioData[_scenario]!;
      double spacing = 120;
      double startX = -((values.length - 1) * spacing) / 2;

      if (_scenario == 2) {
        startX = -320; spacing = 110;
        for (int i = 0; i < values.length; i++) _sources.add(SimItem(id: i, val: values[i], targetVal: values[i], x: startX + (i * spacing), y: 0));
        _target = SimItem(id: -1, val: 0, targetVal: 0, x: 260, y: 100);
      } else if (_scenario == 3) {
        startX = -320; spacing = 70;
        for (int i = 0; i < values.length; i++) _sources.add(SimItem(id: i, val: values[i], targetVal: values[i], x: startX + (i * spacing), y: 70));
        _target = SimItem(id: -1, val: 0, targetVal: 0, x: 340, y: 80);
      } else if (_scenario == 4) {
        startX = -350; spacing = 80;
        for (int i = 0; i < values.length; i++) _sources.add(SimItem(id: i, val: values[i], targetVal: values[i], x: startX + (i * spacing), y: 180));
        _target = SimItem(id: -1, val: 0, targetVal: 0, x: 320, y: 120);
      } else if (_scenario == 5) {
        for (int i = 0; i < values.length; i++) _sources.add(SimItem(id: i, val: values[i], targetVal: values[i], x: startX + (i * spacing), y: 0));
        _target = SimItem(id: -1, val: 0, targetVal: 0, x: 0, y: 0);
      } else { // Scenario 1
        for (int i = 0; i < values.length; i++) _sources.add(SimItem(id: i, val: values[i], targetVal: values[i], x: startX + (i * spacing), y: -100));
        _target = SimItem(id: -1, val: 0, targetVal: 0, x: 0, y: 150);
      }
      
      _updateActionRects();
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _updateActionRects() {
    _btnActionRect = null;
    _btnCombineRect = null;

    if (_scenario == 5) {
      if (_step == 1 && !_isAnimating) {
        _btnCombineRect = const Rect.fromLTWH(-110, 220, 220, 60);
      } else if (_step == 2 && !_isAnimating) {
        _btnActionRect = const Rect.fromLTWH(-140, -30, 280, 60);
      }
    } else {
      if (_step == 2 && !_isAnimating) {
        double btnW = 200; double btnH = 50;
        double btnX = _target.x - btnW/2; 
        double btnY = _target.y + (_scenario==1 ? 60 : (_scenario==2 ? 110 : (_scenario==3 ? 100 : 160)));
        if (_scenario==1) { btnY = _target.y + 20; btnW = 160; btnX = _target.x - btnW/2; }
        if (_scenario==4) { btnY = _target.y + 20; btnW = 120; btnH = 45; btnX = _target.x - btnW/2; }
        _btnActionRect = Rect.fromLTWH(btnX, btnY, btnW, btnH);
      }
    }
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

  void _tick() {
    bool rebuild = false;

    if (_isAnimating) {
      _animProgress += 0.008; // approx 2.5 seconds
      if (_animProgress >= 1.0) {
        _isAnimating = false;
        _animProgress = 0;
        
        double total = _scenario == 5 ? _sources.fold(0.0, (sum, s) => sum + s.val) : _target.val;
        double mean = total / _sources.length;
        
        for (var s in _sources) { s.val = mean; }
        _target.val = 0;
        
        if (_scenario != 5) {
          _advanceStep(); // Step 2 -> 3
        }
        
        if (_scenario <= 3) {
          _checkScenarioSuccess();
        }
        _updateActionRects();
      }
      rebuild = true;
    }

    if (rebuild) setState(() {});
  }

  void _advanceStep() {
    setState(() => _step++);
    _updateActionRects();
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    int targetStep = (_scenario >= 4) ? 4 : 3;
    setState(() => _step = targetStep);
    _playSound('success');
    _scrollToActiveStep();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSuccessPopup = true);
    });
  }

  void _checkInputAnswer() {
    int correctMean = _scenario == 4 ? 18 : 1859;
    int? userVal = int.tryParse(_inputController.text);
    
    if (userVal == correctMean) {
      _checkScenarioSuccess();
    } else {
      _playSound('error');
      _showTemporaryHUD(_scenario == 5 ? t('err_chart_read') : t('err_num'));
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

  bool _hitTestRect(Rect? rect, Offset pt) {
    if (rect == null) return false;
    return rect.contains(pt);
  }

  void _triggerActionBtn() {
    _playSound('whir');
    setState(() {
      _isAnimating = true;
      _animProgress = 0;
      if (_scenario == 5) _advanceStep();
      double total = _scenario == 5 ? _sources.fold(0.0, (sum, s) => sum + s.val) : _target.val;
      double mean = total / _sources.length;
      for (var s in _sources) s.targetVal = mean;
      _updateActionRects();
    });
  }

  void _triggerCombineBtn() {
    _playSound('whir');
    setState(() {
      _isAnimating = true;
      _animProgress = 0;
      _advanceStep();
      _updateActionRects();
    });
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    Offset pt = _screenToWorld(details.localPosition, size);
    if (_isAnimating || _step > 3) return;

    if (_btnActionRect != null && _hitTestRect(_btnActionRect, pt)) {
      _triggerActionBtn();
    } else if (_btnCombineRect != null && _hitTestRect(_btnCombineRect, pt)) {
      _triggerCombineBtn();
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (_isAnimating || _step > 3) return; 

    // Draggable Sources
    if (_step == 1 && _scenario != 5) {
      for (int i = 0; i < _sources.length; i++) {
        var src = _sources[i];
        Rect hitRect;
        
        // Custom hit boxes tailored to each scenario's shape and drawing origin
        if (_scenario == 1) { 
          hitRect = Rect.fromCenter(center: Offset(src.x, src.y), width: 120, height: 120);
        } else if (_scenario == 2) {
          hitRect = Rect.fromCenter(center: Offset(src.x, src.y), width: 120, height: 120);
        } else if (_scenario == 3) {
          hitRect = Rect.fromCenter(center: Offset(src.x, src.y - 100), width: 100, height: 200);
        } else {
          hitRect = Rect.fromCenter(center: Offset(src.x, src.y - 140), width: 100, height: 280);
        }
        
        if (src.val > 0 && hitRect.contains(pt)) {
          _playSound('tick');
          setState(() {
            _draggables.add(DraggableItem(srcId: i, val: src.val, x: pt.dx, y: pt.dy));
            src.val = 0;
          });
          return;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      if (_draggables.isNotEmpty) {
        _draggables.last.x = pt.dx;
        _draggables.last.y = pt.dy;
        return;
      }

      // Pan & Zoom
      if (details.scale != 1.0) {
        _zoom = (_baseZoom * details.scale).clamp(0.2, 2.0);
      }
      _panX += details.focalPointDelta.dx / _zoom;
      _panY += details.focalPointDelta.dy / _zoom;
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_draggables.isNotEmpty) {
      setState(() {
        var item = _draggables.removeLast();
        // Generous target hit box for easy dropping
        Rect targetRect = Rect.fromCenter(center: Offset(_target.x, _target.y), width: 300, height: 300);
        
        if (targetRect.contains(Offset(item.x, item.y))) {
          _playSound('snap');
          _target.val += item.val;
          
          if (_sources.every((s) => s.val == 0)) {
            _advanceStep(); // Step 1 -> 2
          }
        } else {
          _playSound('pop');
          _sources[item.srcId].val = item.val;
        }
      });
    }
  }

  // --- HTML Parsing for Rich Text ---
  Widget _buildRichText(String text, Color defaultColor) {
    String cleanStr = text.replaceAll(RegExp(r'<br\s*\/?>'), '\n').replaceAll('`', '');
    List<TextSpan> spans = [];
    List<String> bParts = cleanStr.split(RegExp(r'<strong[^>]*>|</strong>|<b>|</b>'));

    for (int i = 0; i < bParts.length; i++) {
      if (i % 2 != 0) {
        spans.add(TextSpan(text: bParts[i], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent)));
      } else {
        if (bParts[i].isNotEmpty) {
          spans.add(TextSpan(text: bParts[i], style: TextStyle(color: defaultColor)));
        }
      }
    }
    return RichText(text: TextSpan(style: const TextStyle(fontSize: 13, fontFamily: 'Plus Jakarta Sans', height: 1.5), children: spans));
  }

  // --- Sidebar Build ---
  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);
    
    int maxSteps = (_scenario >= 4) ? 3 : 2;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(-5, 0))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _sidebarScrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 70, 20, 15),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.balance, color: Colors.tealAccent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t('shutterTitle'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(t('appSubtitle'), style: TextStyle(color: textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons (Language & Reset)
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
                    
                    // Main Content Section
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.my_location, color: Colors.tealAccent, size: 18),
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
                          ...List.generate(maxSteps, (i) {
                            int actualStep = i + 1;
                            bool isPast = actualStep < _step || (actualStep == _step && _step > maxSteps);
                            bool isCurrent = actualStep == _step;
                            Color stepBg = isCurrent ? Colors.teal.withOpacity(0.1) : (isPast ? Colors.green.withOpacity(0.05) : (Colors.white.withOpacity(0.02)));
                            Color stepBorder = isCurrent ? Colors.tealAccent : (isPast ? Colors.green.withOpacity(0.3) : Colors.transparent);

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
                                          decoration: BoxDecoration(color: isCurrent ? Colors.tealAccent : Colors.grey, shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Text('$actualStep', style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${t('stepLabel')} $actualStep", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        _buildRichText("${t('actTitle')} ${t('s${_scenario}_step${actualStep}_task')}", textPrimary),
                                        if (isPast) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.withOpacity(0.3))),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(t('obsLbl'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade400, fontSize: 12)),
                                                const SizedBox(height: 4),
                                                _buildRichText(t('s${_scenario}_step${actualStep}_obs'), Colors.teal.shade200),
                                                const SizedBox(height: 8),
                                                const Divider(color: Colors.teal, height: 1),
                                                const SizedBox(height: 8),
                                                Text(t('learnLbl'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade400, fontSize: 12)),
                                                const SizedBox(height: 4),
                                                _buildRichText(t('s${_scenario}_step${actualStep}_learn'), Colors.teal.shade200),
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
                    
                    // Spacer fills any remaining height if content is short
                    const Spacer(),
                    
                    // Footer Section
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
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300;
    
    int maxSteps = (_scenario >= 4) ? 3 : 2;
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
            // MAIN CANVAS
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _handleTapDown(d, constraints.biggest),
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: ArithmeticMeanPainter(
                          scenario: _scenario, step: _step, zoom: _zoom, panX: _panX, panY: _panY,
                          sources: _sources, target: _target, draggables: _draggables,
                          animProgress: _animProgress, isAnimating: _isAnimating,
                          btnActionRect: _btnActionRect, btnCombineRect: _btnCombineRect,
                          t: t,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // HUD Overlays
            if (_step <= maxSteps && (hudText != 's${_scenario}_hud$_step' || _showHud))
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          border: const Border(top: BorderSide(color: Colors.teal, width: 4)),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.teal.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.info_outline, color: Colors.tealAccent),
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

            // Input Modal for Scenarios 4 and 5
            if ((_scenario == 4 || _scenario == 5) && _step == 3 && !_showSuccessPopup)
              Positioned(
                bottom: 120, left: _isSidebarOpen ? sidebarWidth : 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                      border: Border.all(color: Colors.tealAccent.withOpacity(0.5), width: 2)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t('lblInputPrompt'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _inputController, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              filled: true, fillColor: const Color(0xFF0F172A), contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _checkInputAnswer,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                          child: Text(t('btnSubmit'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
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
                color: Colors.tealAccent, iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact(); _playSound('tick');
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.withOpacity(0.8))),
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
                        width: 450, padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.teal, width: 2)),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80, height: 80,
                                  decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.amberAccent, blurRadius: 20)]),
                                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                                ),
                                const SizedBox(height: 24),
                                Text(t('finalSuccessTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                _buildRichText(t('s${_scenario}_final'), Colors.white),
                                const SizedBox(height: 32),
                                if (_scenario < 5)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(t('scenarioCompleted'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent), textAlign: TextAlign.center),
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _playSound('pop'); setState(() => _showSuccessPopup = false);
                                        },
                                        icon: const Icon(Icons.check), label: Text(t('doneBtn')),
                                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), backgroundColor: Colors.teal, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                if (_scenario == 5)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _playSound('pop'); setState(() => _showSuccessPopup = false);
                                          _handleReset();
                                        },
                                        icon: const Icon(Icons.refresh), label: Text(t('finalRestartBtn')),
                                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                              ],
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
              duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutCubic,
              child: Container(
                width: double.infinity, height: double.infinity, color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120, height: 120, margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.tealAccent.withOpacity(0.6), blurRadius: 20)]),
                          child: const Icon(Icons.balance, size: 60, color: Colors.white),
                        ),
                        Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 16),
                        Text(t('appSubtitle'), style: const TextStyle(color: Colors.tealAccent, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () {
                            _playSound('pop'); setState(() => _showCurtain = false);
                          },
                          icon: const Icon(Icons.play_circle_fill, size: 28), label: Text(t('enterLab')),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), backgroundColor: Colors.teal, foregroundColor: Colors.white, elevation: 10, shadowColor: Colors.tealAccent.withOpacity(0.5), textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
class ArithmeticMeanPainter extends CustomPainter {
  final int scenario, step;
  final double zoom, panX, panY;
  
  final List<SimItem> sources;
  final SimItem target;
  final List<DraggableItem> draggables;
  
  final double animProgress;
  final bool isAnimating;

  final Rect? btnActionRect;
  final Rect? btnCombineRect;
  
  final Function(String) t;

  ArithmeticMeanPainter({
    required this.scenario, required this.step, required this.zoom, required this.panX, required this.panY,
    required this.sources, required this.target, required this.draggables,
    required this.animProgress, required this.isAnimating,
    required this.btnActionRect, required this.btnCombineRect,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    _drawBackground(canvas);

    if (scenario != 5) {
      if (scenario == 4) _drawTarget(canvas, target, scenario);
      
      for (var src in sources) {
        _drawSource(canvas, src, scenario, animProgress);
      }
      
      if (scenario != 4) _drawTarget(canvas, target, scenario);

      for (var d in draggables) {
        canvas.save();
        canvas.translate(d.x, d.y);
        for(int i=0; i<d.val; i++) {
           if (scenario == 1) _drawGuava(canvas, (i%3 - 1)*15.0, -12 - (i~/3)*12.0);
           else if (scenario == 2) _drawHibiscus(canvas, (i%3 - 1)*20.0, -30 - (i~/3)*20.0);
           else if (scenario == 3) _drawTennisBall(canvas, 0, -10 - i*18.0);
           else if (scenario == 4) _drawBlueBlock(canvas, 0, -i*14.0);
        }
        canvas.restore();
      }

      // Draw Action Button
      if (btnActionRect != null) {
        String btnText = t('btnShare');
        if (scenario == 2) btnText = t('btnFindAvg');
        if (scenario == 3) btnText = t('btnMeanBtn');
        
        Color bg = (scenario == 1 || scenario == 2 || scenario == 4) ? Colors.green : Colors.amber;
        Color border = (scenario == 1 || scenario == 2 || scenario == 4) ? Colors.green[800]! : Colors.amber[800]!;
        
        canvas.drawRRect(RRect.fromRectAndRadius(btnActionRect!, const Radius.circular(10)), Paint()..color = border..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10));
        canvas.drawRRect(RRect.fromRectAndRadius(btnActionRect!, const Radius.circular(10)), Paint()..color = bg);
        canvas.drawRRect(RRect.fromRectAndRadius(btnActionRect!, const Radius.circular(10)), Paint()..color = border..style=PaintingStyle.stroke..strokeWidth=3);
        
        _drawTextOutline(canvas, btnText, btnActionRect!.center.dx, btnActionRect!.center.dy, 16, Colors.white, Colors.transparent, 0);
      }

    } else {
      _drawBarChart(canvas);
    }

    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    Paint bgPaint = Paint();
    if (scenario == 1) {
      bgPaint.color = const Color(0xFF0F172A);
      canvas.drawRect(const Rect.fromLTRB(-2000, -2000, 2000, 2000), bgPaint);
      bgPaint.color = const Color(0xFF064E3B);
      canvas.drawOval(const Rect.fromLTRB(-1500, -100, 1500, 700), bgPaint);
      
      Paint tableTop = Paint()..color = const Color(0xFF451A03);
      canvas.drawRect(const Rect.fromLTRB(-320, -50, 320, -30), tableTop);
      canvas.drawRect(const Rect.fromLTRB(-300, -30, -280, 120), tableTop);
      canvas.drawRect(const Rect.fromLTRB(280, -30, 300, 120), tableTop);
    } else if (scenario == 2) {
      bgPaint.color = const Color(0xFF14532D);
      canvas.drawRect(const Rect.fromLTRB(-2000, -2000, 2000, 2000), bgPaint);
      
      Paint tableTop = Paint()..color = const Color(0xFFD97706);
      canvas.drawRect(const Rect.fromLTRB(-400, 40, 400, 65), tableTop);
      Paint tableLeg = Paint()..color = const Color(0xFFB45309);
      canvas.drawRect(const Rect.fromLTRB(-380, 65, -360, 145), tableLeg);
      canvas.drawRect(const Rect.fromLTRB(100, 65, 120, 145), tableLeg);
    } else if (scenario == 3) {
      bgPaint.color = const Color(0xFF020617);
      canvas.drawRect(const Rect.fromLTRB(-2000, -2000, 2000, 2000), bgPaint);
      bgPaint.color = const Color(0xFF14532D);
      canvas.drawRect(const Rect.fromLTRB(-2000, 100, 2000, 1100), bgPaint);
      Paint baseBoard = Paint()..color = const Color(0xFFD97706);
      canvas.drawRect(const Rect.fromLTRB(-400, 90, 200, 130), baseBoard);
    } else if (scenario == 4) {
      bgPaint.color = const Color(0xFF020617);
      canvas.drawRect(const Rect.fromLTRB(-2000, -2000, 2000, 2000), bgPaint);
      bgPaint.color = const Color(0xFF064E3B);
      canvas.drawRect(const Rect.fromLTRB(-2000, -50, 2000, 350), bgPaint);
      Paint trackBoundary = Paint()..color = const Color(0xFF2563EB);
      canvas.drawRect(const Rect.fromLTRB(-440, 0, 220, 300), trackBoundary);
      Paint trackMain = Paint()..color = const Color(0xFFB91C1C);
      canvas.drawRect(const Rect.fromLTRB(-390, 20, 170, 280), trackMain);
      Paint linePaint = Paint()..color = Colors.white..strokeWidth = 3;
      for (int i = 0; i <= 7; i++) {
        double lx = -390.0 + i * 80;
        canvas.drawLine(Offset(lx, 20), Offset(lx, 280), linePaint);
      }
    } else if (scenario == 5) {
      bgPaint.color = const Color(0xFF0F172A);
      canvas.drawRect(const Rect.fromLTRB(-2000, -2000, 2000, 2000), bgPaint);
    }
  }

  void _drawSource(Canvas canvas, SimItem s, int type, double p) {
    canvas.save();
    canvas.translate(s.x, s.y);
    double val = s.val;
    
    if (type == 1) {
      canvas.drawOval(const Rect.fromLTRB(-40, 10, 40, 30), Paint()..color = const Color(0xFFD97706));
      canvas.drawOval(const Rect.fromLTRB(-40, 10, 40, 30), Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2);
      Path body = Path()..moveTo(-40, 20)..lineTo(-45, -10)..lineTo(45, -10)..lineTo(40, 20)..close();
      canvas.drawPath(body, Paint()..color = const Color(0xFFD97706));
      canvas.drawPath(body, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawOval(const Rect.fromLTRB(-45, -22, 45, 2), Paint()..color = const Color(0xFFF59E0B));
      canvas.drawOval(const Rect.fromLTRB(-45, -22, 45, 2), Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawCircle(const Offset(0, 5), 14, Paint()..color=Colors.white);
      _drawTextOutline(canvas, isAnimating ? s.targetVal.round().toString() : val.round().toString(), 0, 5, 14, Colors.black, Colors.transparent, 0);
    } else if (type == 2) {
      Path pot = Path()..moveTo(-35, -20)..lineTo(35, -20)..lineTo(25, 40)..lineTo(-25, 40)..close();
      canvas.drawPath(pot, Paint()..color = const Color(0xFFB45309));
      canvas.drawPath(pot, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawRRect(RRect.fromLTRBR(-40, -35, 40, -20, const Radius.circular(4)), Paint()..color = const Color(0xFF9A3412));
      canvas.drawRRect(RRect.fromLTRBR(-30, 40, 30, 60, const Radius.circular(4)), Paint()..color = Colors.white);
      _drawTextOutline(canvas, "Day ${s.id+1}", 0, 50, 12, Colors.black, Colors.transparent, 0);
    } else if (type == 3) {
      canvas.drawRRect(RRect.fromLTRBR(-20, -170, 20, 10, const Radius.circular(4)), Paint()..color = Colors.white10);
      canvas.drawRRect(RRect.fromLTRBR(-25, 10, 25, 25, const Radius.circular(2)), Paint()..color = const Color(0xFFD97706));
      canvas.drawCircle(const Offset(0, 30), 12, Paint()..color=const Color(0xFF0F172A));
      _drawTextOutline(canvas, "${s.id+1}", 0, 30, 12, Colors.white, Colors.transparent, 0);
      if (val > 0 && step < 3) {
        _drawTextOutline(canvas, val.round().toString(), 0, -180, 14, Colors.white, Colors.transparent, 0);
      }
    } else if (type == 4) {
      double swY = -260;
      canvas.drawCircle(Offset(0, swY), 26, Paint()..color=const Color(0xFF64748B));
      canvas.drawCircle(Offset(0, swY), 26, Paint()..color=const Color(0xFF334155)..style=PaintingStyle.stroke..strokeWidth=4);
      canvas.drawCircle(Offset(0, swY), 20, Paint()..color=Colors.white);
      double displayVal = isAnimating ? s.targetVal : val;
      _drawTextOutline(canvas, displayVal.round().toString(), 0, swY - 2, 18, Colors.black, Colors.transparent, 0);
      _drawTextOutline(canvas, "sec", 0, swY + 12, 10, Colors.grey, Colors.transparent, 0);
      if (!isAnimating && step >= 2) {
        double topY = -(displayVal * 14) - 15;
        _drawTextOutline(canvas, displayVal.round().toString(), 0, topY, 16, Colors.white, Colors.transparent, 0);
      }
    }

    if (!isAnimating) {
      for(int i=0; i<val; i++) {
        if(type==1) _drawGuava(canvas, (i%3 - 1)*15.0, -12 - (i~/3)*12.0);
        else if(type==2) _drawHibiscus(canvas, (i%3 - 1)*20.0, -30 - (i~/3)*20.0);
        else if(type==3) _drawTennisBall(canvas, 0, -10 - i*18.0);
        else if(type==4) _drawBlueBlock(canvas, 0, -i*14.0);
      }
    } else {
      int targetTotal = s.targetVal.round();
      for(int i=0; i<targetTotal; i++) {
        double endX = 0, endY = 0;
        if(type==1) { endX = (i%3 - 1)*15.0; endY = -12 - (i~/3)*12.0; }
        else if(type==2) { endX = (i%3 - 1)*20.0; endY = -30 - (i~/3)*20.0; }
        else if(type==3) { endX = 0; endY = -10 - i*18.0; }
        else if(type==4) { endX = 0; endY = -i*14.0; }

        double startX = target.x - s.x;
        double startY = target.y - s.y;
        if (type == 4) {
            startX += sin(i * 12.3) * 45;
            startY += 40 + cos(i * 3.4) * 40;
        }

        double ease = 1 - pow(1 - p, 3).toDouble();
        double currX = startX + (endX - startX)*ease;
        double currY = startY + (endY - startY)*ease - sin(ease * pi) * 100;

        if(type==1) _drawGuava(canvas, currX, currY);
        else if(type==2) _drawHibiscus(canvas, currX, currY);
        else if(type==3) _drawTennisBall(canvas, currX, currY);
        else if(type==4) _drawBlueBlock(canvas, currX, currY);
      }
    }
    
    canvas.restore();
  }

  void _drawTarget(Canvas canvas, SimItem tData, int type) {
    canvas.save();
    canvas.translate(tData.x, tData.y);

    if (type == 1) { 
      canvas.drawRect(const Rect.fromLTRB(-110, -70, 110, 70), Paint()..color = const Color(0xFF8B4513));
      canvas.drawRect(const Rect.fromLTRB(-110, -70, 110, 70), Paint()..color = const Color(0xFF3E1F05)..style=PaintingStyle.stroke..strokeWidth=4);
      canvas.drawLine(const Offset(-110, -20), const Offset(110, -20), Paint()..color=const Color(0xFF3E1F05)..strokeWidth=2);
      canvas.drawLine(const Offset(-110, 20), const Offset(110, 20), Paint()..color=const Color(0xFF3E1F05)..strokeWidth=2);
      canvas.drawRect(const Rect.fromLTRB(-100, -80, 100, -50), Paint()..color = const Color(0xFF3E1F05));
      
      int count = isAnimating ? 0 : tData.val.round();
      for(int i=0; i<count; i++) {
          int row = i ~/ 8; int col = i % 8;
          _drawGuava(canvas, (col - 3.5)*20, -60 - row*15.0);
      }
      canvas.drawRect(const Rect.fromLTRB(-90, -10, 90, 55), Paint()..color = Colors.black54);
      _drawTextOutline(canvas, "COMMUNAL CRATE", 0, 5, 13, Colors.white, Colors.transparent, 0);
      _drawTextOutline(canvas, "TOTAL: ${tData.val.round()}", 0, 30, 24, Colors.white, Colors.transparent, 0);

    } else if (type == 2) { 
      Path body = Path()..moveTo(-90, -40)..lineTo(90, -40)..lineTo(70, 60)..lineTo(-70, 60)..close();
      canvas.drawPath(body, Paint()..color = const Color(0xFFD97706));
      canvas.drawPath(body, Paint()..color=const Color(0xFF78350F)..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawOval(const Rect.fromLTRB(-90, -60, 90, -20), Paint()..color = const Color(0xFFB45309));
      
      int count = isAnimating ? 0 : tData.val.round();
      for(int i=0; i<count; i++) {
          double r = sqrt(i) * 12; double theta = i * 2.4;
          _drawHibiscus(canvas, cos(theta) * r, -30 + sin(theta) * (r * 0.4));
      }
      canvas.drawOval(const Rect.fromLTRB(-90, -60, 90, -20), Paint()..color=const Color(0xFF78350F)..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawRRect(RRect.fromLTRBR(-60, 65, 60, 95, const Radius.circular(6)), Paint()..color=Colors.white);
      _drawTextOutline(canvas, "Total: ${tData.val.round()}", 0, 80, 16, Colors.black, Colors.transparent, 0);

    } else if (type == 3) { 
      Path bag = Path()..moveTo(-80, 0)..quadraticBezierTo(0, 150, 80, 0)..lineTo(50, -50)..lineTo(-50, -50)..close();
      canvas.drawPath(bag, Paint()..color = const Color(0xFF9A3412));
      canvas.drawPath(bag, Paint()..color=const Color(0xFF451A03)..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawOval(const Rect.fromLTRB(-50, -65, 50, -35), Paint()..color=const Color(0xFF451A03));
      
      int count = isAnimating ? 0 : tData.val.round();
      for(int i=0; i<count; i++) {
          double r = sqrt(i) * 10; double theta = i * 2.4;
          double iy = -50 + sin(theta) * (r * 0.5);
          if (iy > -50 && iy < 40) _drawTennisBall(canvas, cos(theta) * r, iy);
      }
      canvas.drawOval(const Rect.fromLTRB(-55, -50, 55, -30), Paint()..color=const Color(0xFFFDE047)..style=PaintingStyle.stroke..strokeWidth=4);
      _drawTextOutline(canvas, "BALL BAG", 0, 0, 20, Colors.black, Colors.transparent, 0);
      canvas.drawRRect(RRect.fromLTRBR(-60, 15, 60, 45, const Radius.circular(6)), Paint()..color=const Color(0xFF451A03));
      _drawTextOutline(canvas, "TOTAL: ${tData.val.round()}", 0, 30, 16, Colors.white, Colors.transparent, 0);

    } else if (type == 4) { 
      Path bin = Path()..moveTo(-75, -50)..lineTo(75, -50)..lineTo(55, 90)..lineTo(-55, 90)..close();
      canvas.drawPath(bin, Paint()..color = const Color(0xFFFACC15));
      canvas.drawPath(bin, Paint()..color=const Color(0xFFCA8A04)..style=PaintingStyle.stroke..strokeWidth=4);
      canvas.drawOval(const Rect.fromLTRB(-80, -65, 80, -35), Paint()..color=const Color(0xFFEAB308));
      
      int count = isAnimating ? 0 : tData.val.round();
      for(int i=0; i<count; i++) {
          double px = sin(i * 12.3) * 45; double py = cos(i * 3.4) * 40;
          _drawBlueBlock(canvas, px, 40 + py);
      }
      canvas.drawOval(const Rect.fromLTRB(-80, -65, 80, -35), Paint()..color=const Color(0xFFCA8A04)..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawRRect(RRect.fromLTRBR(-55, 8, 55, 53, const Radius.circular(8)), Paint()..color=const Color(0xFF334155));
      _drawTextOutline(canvas, "Total:", 0, 18, 12, Colors.white70, Colors.transparent, 0);
      _drawTextOutline(canvas, "${tData.val.round()}", 0, 36, 22, Colors.white, Colors.transparent, 0);
    }

    canvas.restore();
  }

  void _drawBarChart(Canvas canvas) {
    double spacing = 120;
    List<double> values = sources.map((s) => s.val).toList();
    double startX = -((values.length - 1) * spacing) / 2;
    List<Color> colors = const [Color(0xFFF43F5E), Color(0xFFF97316), Color(0xFFEAB308), Color(0xFF22C55E), Color(0xFF06B6D4), Color(0xFF8B5CF6)];
    
    double total = values.fold(0, (a,b)=>a+b);
    double mean = total / values.length;

    canvas.drawLine(const Offset(-400, 150), const Offset(400, 150), Paint()..color=Colors.white30..strokeWidth=3);

    if (step == 1) {
      if (isAnimating) {
        double targetX = 0;
        if (animProgress < 0.5) {
          double pp = animProgress * 2;
          for (int i=0; i<values.length; i++) {
            double initX = startX + (i*spacing);
            double currX = initX + (targetX - initX)*pp;
            double h = (values[i] / 2500) * 200;
            canvas.drawRRect(RRect.fromLTRBR(currX-30, 150-h, currX+30, 150, const Radius.circular(4)), Paint()..color=colors[i]);
          }
        } else {
          double pp = (animProgress - 0.5) * 2;
          double hTotal = 250;
          double hCurr = ((total/6) / 2500 * 200) + (hTotal - ((total/6) / 2500 * 200)) * pp;
          canvas.drawRRect(RRect.fromLTRBR(targetX-40, 150-hCurr, targetX+40, 150, const Radius.circular(4)), Paint()..color=const Color(0xFF06B6D4));
        }
      } else {
        for (int i=0; i<values.length; i++) {
          double x = startX + (i*spacing);
          double h = (values[i] / 2500) * 200;
          canvas.drawRRect(RRect.fromLTRBR(x-30, 150-h, x+30, 150, const Radius.circular(4)), Paint()..color=colors[i]);
          _drawTextOutline(canvas, values[i].round().toString(), x, 150-h-15, 14, Colors.white, Colors.transparent, 0);
          _drawTextOutline(canvas, (2018+i).toString(), x, 175, 12, Colors.white54, Colors.transparent, 0);
        }
        
        // Combine Button
        if (btnCombineRect != null) {
          canvas.drawRRect(RRect.fromRectAndRadius(btnCombineRect!, const Radius.circular(15)), Paint()..color = const Color(0xFF8B5CF6));
          canvas.drawRRect(RRect.fromRectAndRadius(btnCombineRect!, const Radius.circular(15)), Paint()..color = const Color(0xFF6D28D9)..style=PaintingStyle.stroke..strokeWidth=3);
          _drawTextOutline(canvas, "∑", btnCombineRect!.center.dx - 80, btnCombineRect!.center.dy, 24, Colors.white, Colors.transparent, 0);
          _drawTextOutline(canvas, t('btnCombine'), btnCombineRect!.center.dx + 15, btnCombineRect!.center.dy, 16, Colors.white, Colors.transparent, 0);
        }
      }
    } else if (step == 2) {
      if (isAnimating) {
         double targetX = 0;
         if (animProgress < 0.5) {
            double pp = animProgress * 2;
            double hTotal = 250;
            double hTarget = (mean / 2500) * 200;
            double hCurr = hTotal - (hTotal - hTarget) * pp;
            canvas.drawRRect(RRect.fromLTRBR(targetX-40, 150-hCurr, targetX+40, 150, const Radius.circular(4)), Paint()..color=const Color(0xFF06B6D4));
         } else {
            double pp = (animProgress - 0.5) * 2;
            double hTarget = (mean / 2500) * 200;
            for (int i=0; i<values.length; i++) {
               double finalX = startX + (i*spacing);
               double currX = targetX + (finalX - targetX)*pp;
               canvas.drawRRect(RRect.fromLTRBR(currX-30, 150-hTarget, currX+30, 150, const Radius.circular(4)), Paint()..color=colors[i]);
            }
         }
      } else {
         double h = 250; double targetX = 0;
         canvas.drawRRect(RRect.fromLTRBR(targetX-40, 150-h, targetX+40, 150, const Radius.circular(4)), Paint()..color=const Color(0xFF06B6D4));
         _drawTextOutline(canvas, "Total Enrolment: ${total.round()}", targetX, 150-h-20, 20, Colors.cyanAccent, Colors.transparent, 0);
         
         // Mean Button
         if (btnActionRect != null) {
            canvas.drawRRect(RRect.fromRectAndRadius(btnActionRect!, const Radius.circular(15)), Paint()..color = const Color(0xFF10B981));
            canvas.drawRRect(RRect.fromRectAndRadius(btnActionRect!, const Radius.circular(15)), Paint()..color = const Color(0xFF047857)..style=PaintingStyle.stroke..strokeWidth=3);
            _drawTextOutline(canvas, "⚖️ " + t('btnMean'), btnActionRect!.center.dx, btnActionRect!.center.dy, 18, Colors.white, Colors.transparent, 0);
         }
      }
    } else if (step >= 3) {
      for (int i=0; i<values.length; i++) {
          double x = startX + (i*spacing);
          double h = (mean / 2500) * 200; 
          canvas.drawRRect(RRect.fromLTRBR(x-30, 150-h, x+30, 150, const Radius.circular(4)), Paint()..color=colors[i]);
          _drawTextOutline(canvas, "=", x, 150-h/2, 24, Colors.white, Colors.transparent, 0);
          _drawTextOutline(canvas, mean.round().toString(), x, 150-h-15, 16, Colors.white, Colors.transparent, 0);
          _drawTextOutline(canvas, (2018+i).toString(), x, 175, 12, Colors.white54, Colors.transparent, 0);
      }
      
      double h = (mean / 2500) * 200; 
      canvas.drawLine(Offset(-400, 150-h), Offset(400, 150-h), Paint()..color=Colors.pinkAccent..strokeWidth=2);
      _drawTextOutline(canvas, "MEAN", -430, 150-h, 14, Colors.pinkAccent, Colors.transparent, 0);
    }
  }

  void _drawGuava(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawOval(const Rect.fromLTRB(-11, -11, 11, 11), Paint()..color=const Color(0xFF84CC16));
    canvas.drawOval(const Rect.fromLTRB(-11, -11, 11, 11), Paint()..color=const Color(0xFF4D7C0F)..style=PaintingStyle.stroke..strokeWidth=1.5);
    canvas.drawOval(const Rect.fromLTRB(-8, -6, 0, -2), Paint()..color=Colors.white30);
    canvas.drawLine(const Offset(0, -11), const Offset(2, -15), Paint()..color=const Color(0xFF3F6212)..strokeWidth=2);
    canvas.restore();
  }

  void _drawHibiscus(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    Paint petal = Paint()..color=const Color(0xFFF43F5E);
    Paint petalOutline = Paint()..color=const Color(0xFFBE123C)..style=PaintingStyle.stroke..strokeWidth=1;
    for (int i=0; i<5; i++) {
      canvas.rotate((pi * 2) / 5);
      Path p = Path()..moveTo(0, 0)..quadraticBezierTo(15, -5, 0, -25)..quadraticBezierTo(-15, -5, 0, 0)..close();
      canvas.drawPath(p, petal); canvas.drawPath(p, petalOutline);
    }
    canvas.drawLine(const Offset(0,0), const Offset(-10,-10), Paint()..color=const Color(0xFFFACC15)..strokeWidth=2);
    canvas.drawCircle(const Offset(-10, -10), 3, Paint()..color=const Color(0xFFEAB308));
    canvas.drawCircle(const Offset(0, 0), 4, Paint()..color=const Color(0xFFFBBF24));
    canvas.restore();
  }

  void _drawTennisBall(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawCircle(const Offset(0,0), 10, Paint()..color=const Color(0xFFA3E635));
    canvas.drawCircle(const Offset(0,0), 10, Paint()..color=const Color(0xFF4D7C0F)..style=PaintingStyle.stroke..strokeWidth=1);
    Paint wLine = Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=1.5;
    canvas.drawArc(const Rect.fromLTRB(-14, -6, -2, 6), -pi/2.5, pi*2/2.5, false, wLine);
    canvas.drawArc(const Rect.fromLTRB(2, -6, 14, 6), pi - pi/2.5, pi*2/2.5, false, wLine);
    canvas.restore();
  }

  void _drawBlueBlock(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    double w = 30, h = 15, d = 10;
    double bx = -15, by = -7;
    Path top = Path()..moveTo(bx, by)..lineTo(bx+w, by)..lineTo(bx+w-d, by-d)..lineTo(bx-d, by-d)..close();
    canvas.drawPath(top, Paint()..color=const Color(0xFF60A5FA));
    Path side = Path()..moveTo(bx, by)..lineTo(bx-d, by-d)..lineTo(bx-d, by+h-d)..lineTo(bx, by+h)..close();
    canvas.drawPath(side, Paint()..color=const Color(0xFF2563EB));
    canvas.drawRect(Rect.fromLTWH(bx, by, w, h), Paint()..color=const Color(0xFF3B82F6));
    canvas.restore();
  }

  void _drawTextOutline(Canvas canvas, String text, double x, double y, double fontSize, Color fill, Color outline, double outlineW) {
    TextPainter tpFill = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center,
    );
    tpFill.layout();
    tpFill.paint(canvas, Offset(x - tpFill.width / 2, y - tpFill.height / 2));
  }

  @override
  bool shouldRepaint(covariant ArithmeticMeanPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA (EN, HI)
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "Arithmetic Mean: The Fair-Share Principle",
    'appSubtitle': "Class 7 • CONNECTING THE DOTS...",
    'enterLab': "Enter Lab",
    'settings': "Settings",
    'boardFontSize': "Text Size",
    'theme': "Theme",
    'darkMode': "Switch to Dark Mode",
    'lightMode': "Switch to Light Mode",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'actTitle': "Action:",
    'obsLbl': "Observation:",
    'learnLbl': "Learning:",
    'nextScenario': "Next Scenario",
    'btnShare': "Share Equally",
    'btnCombine': "Combine All Years",
    'btnMean': "Find the Mean Enrolment",
    'btnFindAvg': "Find Daily Average",
    'btnMeanBtn': "Level Out The Stacks",
    'lblTotal': "Total:",
    'lblInputPrompt': "Enter Mean:",
    'btnSubmit': "Check",
    'finalSuccessTitle': "Activity Completed!",
    'finalSuccessDesc': "You have successfully mastered the concept of Arithmetic Mean.",
    'scenarioCompleted': "This scenario is completed.",
    'finalRestartBtn': "Restart Activity",
    'resetBtn': "Reset",

    's1_title': "1. The Great Guava Share-out",
    's1_obj': "To understand the concept of mean by physically pooling and redistributing guavas equally among a group of friends.",
    's1_hud1': "DRAG the guavas from each basket into the central wooden crate.",
    's1_step1_task': "DRAG all the guavas from each of the 5 baskets and DROP them into the central wooden crate.",
    's1_step1_obs': "All guavas are pooled into the crate.",
    's1_step1_learn': "The first step of calculating the mean is finding the total sum.",
    's1_hud2': "CLICK the glowing 'SHARE EQUALLY' button on the crate.",
    's1_step2_task': "CLICK the glowing 'SHARE EQUALLY' button that appears on the crate.",
    's1_step2_obs': "The guavas are distributed equally among the 5 baskets.",
    's1_step2_learn': "The second step is dividing the sum equally by the number of places.",
    's1_final': "The Mean (Average) is 6 Guavas per Person! \nFormula: (3+8+10+5+4) ÷ 5 = 30 ÷ 5 = 6",

    's2_title': "2. Vaishnavi's Blooming Garden",
    's2_obj': "To calculate the average number of flowers blooming per day by applying the 'pool and redistribute' method.",
    's2_hud1': "DRAG the hibiscus flowers into the Garden Basket.",
    's2_step1_task': "DRAG all the hibiscus flowers from the 5 pots and DROP them into the Garden Basket.",
    's2_step1_obs': "All flowers are collected in the basket.",
    's2_step1_learn': "We pool the values to find the total sum.",
    's2_hud2': "CLICK the 'Find Daily Average' button.",
    's2_step2_task': "CLICK the 'Find Daily Average' button on the basket.",
    's2_step2_obs': "Flowers fly from the basket to each pot equally.",
    's2_step2_learn': "Dividing the total sum equally gives us the mean.",
    's2_final': "On average, 5 hibiscus flowers bloomed per day. \n(2+7+9+4+3) / 5 = 25 / 5 = 5",

    's3_title': "3. Shreyas's Batting Practice",
    's3_obj': "To find the average number of ball bounces across multiple attempts using a physical stacking metaphor.",
    's3_hud1': "DRAG the tennis ball stacks into the Ball Bag.",
    's3_step1_task': "DRAG all the tennis balls from the 8 stacks and DROP them into the Ball Bag.",
    's3_step1_obs': "All balls are pooled in the bag.",
    's3_step1_learn': "Combining all variations gives a total sum.",
    's3_hud2': "CLICK the 'LEVEL OUT THE STACKS' button.",
    's3_step2_task': "CLICK the 'LEVEL OUT THE STACKS' button on the Ball Bag.",
    's3_step2_obs': "The balls are levelled out into 8 equal stacks.",
    's3_step2_learn': "Levelling out creates identical stacks, representing the mean.",
    's3_final': "MEAN BOUNCES = 5 \n40 (Total Balls) / 8 (Attempts) = 5 (Average)",

    's4_title': "4. Nikhil's 100m Dash",
    's4_obj': "To calculate the mean of a dataset by performing the 'pool and redistribute' steps and inputting the final answer.",
    's4_hud1:': "DRAG the second-blocks into the Total Time container.",
    's4_step1_task': "DRAG all the second-blocks from the 7 stacks and DROP them into the yellow 'Total Time' container.",
    's4_step1_obs': "Blocks are summed up in the container.",
    's4_step1_learn': "First, sum all the values.",
    's4_hud2': "CLICK the 'Share Equally' button.",
    's4_step2_task': "CLICK the 'Share Equally' button to find the average time.",
    's4_step2_obs': "The blocks are redistributed equally.",
    's4_step2_learn': "Second, divide the sum by the number of data points.",
    's4_hud3': "TYPE the mean value and SUBMIT.",
    's4_step3_task': "Count the blocks in one equal stack. TYPE your answer and CLICK Check.",
    's4_step3_obs': "You found the correct mean.",
    's4_step3_learn': "The fair-share value represents the central tendency.",
    's4_final': "You found the mean!\nBy pooling the total time (126 seconds) and dividing it across the 7 races, you calculated Nikhil's average running time to be 18 seconds.",
    'err_num': "Incorrect. Try counting the blocks in one stack again.",
    'err_chart_read': "Incorrect. Check the value displayed on the mean bars.",

    's5_title': "5. Charting School Growth",
    's5_obj': "To find the mean of a large dataset by manipulating a bar chart, abstracting the concept for bigger numbers.",
    's5_hud1': "CLICK the 'Combine All Years' button.",
    's5_step1_task': "CLICK the 'Combine All Years' button to find the total enrolment over the entire period.",
    's5_step1_obs': "The bars merge into one tall bar representing the total.",
    's5_step1_learn': "Summing large data graphically creates a single total representation.",
    's5_hud2': "CLICK the 'Find the Mean Enrolment' button.",
    's5_step2_task': "CLICK the 'Find the Mean Enrolment' button to level out the data.",
    's5_step2_obs': "The total bar shrinks and splits horizontally into equal bars.",
    's5_step2_learn': "Redistributing the total equally gives the mean value.",
    's5_hud3': "TYPE the mean value and SUBMIT.",
    's5_step3_task': "The value of the mean is displayed on each bar. TYPE this value into the input box and CLICK Check.",
    's5_step3_obs': "You correctly identified the mean.",
    's5_step3_learn': "The mean is a representative value for the entire dataset.",
    's5_final': "For large numbers, we can't move individual items. But the idea is the same! We combined the total (11,154) and shared it equally over the 6 years to find the mean enrolment of 1859 students per year."
  },
  'hi': {
    'shutterTitle': "अंकगणितीय माध्य: समान हिस्सेदारी का सिद्धांत",
    'appSubtitle': "कक्षा 7 • बिंदुओं को जोड़ना...",
    'enterLab': "लैब में प्रवेश करें",
    'settings': "सेटिंग्स",
    'boardFontSize': "टेक्स्ट आकार",
    'theme': "थीम",
    'darkMode': "डार्क मोड",
    'lightMode': "लाइट मोड",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'actTitle': "कार्य:",
    'obsLbl': "अवलोकन:",
    'learnLbl': "सीख:",
    'nextScenario': "अगला परिदृश्य",
    'btnShare': "बराबर बांटें",
    'btnCombine': "सभी वर्षों को मिलाएं",
    'btnMean': "माध्य नामांकन खोजें",
    'btnFindAvg': "दैनिक औसत खोजें",
    'btnMeanBtn': "ढेर बराबर करें",
    'lblTotal': "कुल:",
    'lblInputPrompt': "माध्य दर्ज करें:",
    'btnSubmit': "जांचें",
    'finalSuccessTitle': "गतिविधि पूरी हुई!",
    'finalSuccessDesc': "आपने अंकगणितीय माध्य की अवधारणा को सफलतापूर्वक सीख लिया है।",
    'scenarioCompleted': "यह परिदृश्य पूरा हो गया है।",
    'finalRestartBtn': "गतिविधि पुनरारंभ करें",
    'resetBtn': "रीसेट",

    's1_title': "1. अमरूद का महान बँटवारा",
    's1_obj': "भौतिक रूप से अमरूदों को इकट्ठा करके और दोस्तों के बीच समान रूप से बांटकर माध्य की अवधारणा को समझना।",
    's1_hud1': "प्रत्येक टोकरी से अमरूदों को खींचकर बीच के लकड़ी के बक्से में डालें।",
    's1_step1_task': "5 टोकरियों से सभी अमरूदों को खींचें (DRAG) और उन्हें बीच के लकड़ी के बक्से में छोड़ें (DROP)।",
    's1_step1_obs': "सभी अमरूद बक्से में इकट्ठे हो गए हैं।",
    's1_step1_learn': "माध्य की गणना करने का पहला कदम कुल योग खोजना है।",
    's1_hud2': "बक्से पर चमकते 'बराबर बांटें' बटन पर क्लिक करें।",
    's1_step2_task': "बक्से पर दिखाई देने वाले 'बराबर बांटें' बटन पर क्लिक करें।",
    's1_step2_obs': "अमरूद 5 टोकरियों में समान रूप से वितरित हो गए।",
    's1_step2_learn': "दूसरा कदम कुल योग को स्थानों की संख्या से समान रूप से विभाजित करना है।",
    's1_final': "माध्य (औसत) प्रति व्यक्ति 6 अमरूद है! \nसूत्र: (3+8+10+5+4) ÷ 5 = 30 ÷ 5 = 6",

    's2_title': "2. वैष्णवी का खिलता हुआ बगीचा",
    's2_obj': "फूलों को 'इकट्ठा करने और फिर से बांटने' की विधि से प्रतिदिन औसतन खिलने वाले फूलों की संख्या की गणना करना।",
    's2_hud1': "गुड़हल के फूलों को बगीचे की टोकरी में खींचें।",
    's2_step1_task': "5 गमलों से सभी गुड़हल के फूलों को खींचें और उन्हें बगीचे की टोकरी में छोड़ें।",
    's2_step1_obs': "सभी फूल टोकरी में एकत्र हो गए हैं।",
    's2_step1_learn': "हम कुल योग खोजने के लिए मूल्यों को इकट्ठा करते हैं।",
    's2_hud2': "'दैनिक औसत खोजें' बटन पर क्लिक करें।",
    's2_step2_task': "टोकरी पर 'दैनिक औसत खोजें' बटन पर क्लिक करें।",
    's2_step2_obs': "फूल टोकरी से प्रत्येक गमले में समान रूप से उड़ते हैं।",
    's2_step2_learn': "कुल योग को समान रूप से विभाजित करने पर हमें माध्य प्राप्त होता है।",
    's2_final': "औसतन, प्रतिदिन 5 गुड़हल के फूल खिले। \n(2+7+9+4+3) / 5 = 25 / 5 = 5",

    's3_title': "3. श्रेयस का बैटिंग अभ्यास",
    's3_obj': "ढेर लगाने के रूपक का उपयोग करके कई प्रयासों में गेंद के उछाल की औसत संख्या खोजना।",
    's3_hud1': "टेनिस बॉल के ढेरों को बॉल बैग में खींचें।",
    's3_step1_task': "8 ढेरों से सभी टेनिस गेंदों को खींचें और उन्हें बॉल बैग में छोड़ें।",
    's3_step1_obs': "सभी गेंदें बैग में इकट्ठी हो गई हैं।",
    's3_step1_learn': "सभी विविधताओं को मिलाने से कुल योग प्राप्त होता है।",
    's3_hud2': "'ढेर बराबर करें' बटन पर क्लिक करें।",
    's3_step2_task': "बॉल बैग पर 'ढेर बराबर करें' बटन पर क्लिक करें।",
    's3_step2_obs': "गेंदें 8 समान ढेरों में बराबर हो गई हैं।",
    's3_step2_learn': "ढेर को बराबर करने से समान ढेर बनते हैं, जो माध्य का प्रतिनिधित्व करते हैं।",
    's3_final': "माध्य उछाल = 5 \n40 (कुल गेंदें) / 8 (प्रयास) = 5 (औसत)",

    's4_title': "4. निखिल की 100m दौड़",
    's4_obj': "डेटासेट को इकट्ठा करके और बांटकर माध्य की गणना करना और अंतिम उत्तर दर्ज करना।",
    's4_hud1': "सेकंड-ब्लॉक को कुल समय कंटेनर में खींचें।",
    's4_step1_task': "7 स्टैक से सभी सेकंड-ब्लॉक को खींचें और उन्हें पीले 'कुल समय' कंटेनर में छोड़ें।",
    's4_step1_obs': "कंटेनर में ब्लॉक जुड़ गए हैं।",
    's4_step1_learn': "सबसे पहले, सभी मूल्यों का योग करें।",
    's4_hud2': "'बराबर बांटें' बटन पर क्लिक करें।",
    's4_step2_task': "औसत समय खोजने के लिए 'बराबर बांटें' बटन पर क्लिक करें।",
    's4_step2_obs': "ब्लॉक समान रूप से पुनर्वितरित हो गए हैं।",
    's4_step2_learn': "दूसरा, योग को डेटा बिंदुओं की संख्या से विभाजित करें।",
    's4_hud3': "माध्य मान टाइप करें और जांचें।",
    's4_step3_task': "एक समान स्टैक में ब्लॉक गिनें। अपना उत्तर टाइप करें और जांचें पर क्लिक करें।",
    's4_step3_obs': "आपने सही माध्य खोज लिया।",
    's4_step3_learn': "समान-हिस्सा मान केंद्रीय प्रवृत्ति का प्रतिनिधित्व करता है।",
    's4_final': "आपने माध्य खोज लिया!\nकुल समय (126s) को पूल करके और इसे 7 दौड़ों में विभाजित करके, निखिल का औसत दौड़ने का समय 18s है।",
    'err_num': "गलत। एक स्टैक में ब्लॉकों को फिर से गिनने का प्रयास करें।",
    'err_chart_read': "गलत। माध्य बार पर प्रदर्शित मान की जाँच करें।",

    's5_title': "5. स्कूल के विकास का चार्ट",
    's5_obj': "बार चार्ट में हेरफेर करके एक बड़े डेटासेट का माध्य खोजना।",
    's5_hud1': "'सभी वर्षों को मिलाएं' बटन पर क्लिक करें।",
    's5_step1_task': "पूरी अवधि में कुल नामांकन खोजने के लिए 'सभी वर्षों को मिलाएं' बटन पर क्लिक करें।",
    's5_step1_obs': "बार कुल का प्रतिनिधित्व करने वाले एक लंबे बार में विलीन हो जाते हैं।",
    's5_step1_learn': "बड़े डेटा को रेखांकन द्वारा जोड़ने से एक एकल कुल प्रतिनिधित्व बनता है।",
    's5_hud2': "'माध्य नामांकन खोजें' बटन पर क्लिक करें।",
    's5_step2_task': "डेटा को समतल करने के लिए 'माध्य नामांकन खोजें' बटन पर क्लिक करें।",
    's5_step2_obs': "कुल बार सिकुड़ जाता है और क्षैतिज रूप से समान बार में विभाजित हो जाता है।",
    's5_step2_learn': "कुल को समान रूप से पुनर्वितरित करने से माध्य मान प्राप्त होता है।",
    's5_hud3': "माध्य मान टाइप करें और जांचें।",
    's5_step3_task': "माध्य का मान प्रत्येक बार पर प्रदर्शित होता है। इसे इनपुट बॉक्स में टाइप करें और जांचें पर क्लिक करें।",
    's5_step3_obs': "आपने माध्य को सही ढंग से पहचाना।",
    's5_step3_learn': "माध्य पूरे डेटासेट के लिए एक प्रतिनिधि मूल्य है।",
    's5_final': "बड़ी संख्याओं के लिए, हम अलग-अलग वस्तुओं को नहीं ले जा सकते। लेकिन विचार वही है! हमने कुल (11,154) को मिलाया और 1859 छात्रों का औसत नामांकन खोजने के लिए इसे 6 वर्षों में समान रूप से साझा किया।"
  }
};