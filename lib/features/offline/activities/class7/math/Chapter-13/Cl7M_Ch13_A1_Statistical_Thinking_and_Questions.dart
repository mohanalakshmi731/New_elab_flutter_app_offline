// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StatisticalThinkingandQuestionsApp());
}

class StatisticalThinkingandQuestionsApp extends StatelessWidget {
  const StatisticalThinkingandQuestionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Statistical Thinking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const StatisticalThinkingandQuestions(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class OutputItem {
  String type;
  String text;
  double x, y;
  double targetX;
  double scale;

  OutputItem({
    required this.type,
    required this.text,
    required this.x,
    required this.y,
    required this.targetX,
    this.scale = 0.0,
  });
}

// ==========================================
// MAIN WIDGET
// ==========================================
class StatisticalThinkingandQuestions extends StatefulWidget {
  const StatisticalThinkingandQuestions({super.key});

  @override
  State<StatisticalThinkingandQuestions> createState() => _StatisticalThinkingandQuestionsState();
}

class _StatisticalThinkingandQuestionsState extends State<StatisticalThinkingandQuestions> with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;

  // Lab State
  int _scenario = 1;
  int _step = 1; // 1-based indexing for steps
  bool _showSuccessPopup = false;
  final ScrollController _sidebarScrollController = ScrollController();

  // Viewport State
  double _zoom = 1.0;
  double _panX = 0;
  double _panY = 0;
  double _baseZoom = 1.0;
  double _dragX = 0;
  double _dragY = 0;

  // Temporary HUD
  String _hudMessage = '';
  bool _showHud = false;

  // Simulation Entities
  double _machX = -250, _machY = -40, _machW = 220, _machH = 280;
  String _machineState = 'idle'; // idle, processing, done
  
  double _bin1X = 50, _bin1Y = 150, _binW = 160, _binH = 120;
  double _bin2X = 320, _bin2Y = 150;
  int _bin1ErrorTime = 0, _bin2ErrorTime = 0;

  double _cardX = -350, _cardY = 220;
  double _cardTargetX = -350, _cardTargetY = 220;
  double _cardHomeX = -350, _cardHomeY = 220;
  bool _isCardDragging = false;
  
  double _conveyorW = 0;
  List<OutputItem> _outputItems = [];
  double _animProgress = 0;
  
  // Context Animations
  double _robotWave = 0;
  double _robotScanAlpha = 0;
  int? _mapActiveNode;

  // Audio Engine
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Audio Sources
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';
  static const String _whirUrl = 'audio/class7/mixkit_3104.mp3';
  static const String _zapUrl = 'audio/class7/mixkit_1666.mp3';

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

    // Main Game Loop for animations (30 FPS approx)
    _ticker = AnimationController(vsync: this, duration: const Duration(milliseconds: 30))..addListener(_tick)..repeat();
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
      } else if (type == 'pop' || type == 'tick' || type == 'snap') {
        await _clickPlayer.play(AssetSource(_clickUrl), volume: 0.5);
      } else if (type == 'success') {
        await _successPlayer.play(AssetSource(_successUrl), volume: 0.5);
      } else if (type == 'error') {
        await _errorPlayer.play(AssetSource(_errorUrl), volume: 0.5);
      } else if (type == 'whir') {
        await _fxPlayer.play(AssetSource(_whirUrl), volume: 0.4);
      } else if (type == 'zap') {
        await _fxPlayer.play(AssetSource(_zapUrl), volume: 0.3);
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
      
      _machineState = 'idle';
      _animProgress = 0;
      _outputItems.clear();
      _conveyorW = 0;
      _robotScanAlpha = 0;
      _mapActiveNode = null;
      
      _cardHomeX = -350; _cardHomeY = 220;
      _cardX = _cardHomeX; _cardY = _cardHomeY;
      _cardTargetX = _cardHomeX; _cardTargetY = _cardHomeY;
      _isCardDragging = false;
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    bool rebuild = false;
    
    // Card easing
    if ((_cardX - _cardTargetX).abs() > 0.5 || (_cardY - _cardTargetY).abs() > 0.5) {
      _cardX += (_cardTargetX - _cardX) * 0.2;
      _cardY += (_cardTargetY - _cardY) * 0.2;
      rebuild = true;
    }

    // Machine processing
    if (_machineState == 'processing') {
      _animProgress += 0.005; // approx 6 seconds per full sequence
      double p = _animProgress;

      if (p < 0.2) _conveyorW = (p / 0.2) * 450;
      else _conveyorW = 450;

      double startX = _machX + _machW;
      int s = _scenario;

      if (s == 1) {
        if (p > 0.25 && _outputItems.isEmpty) _spawnOutput('dog_🐕', '2', startX + 30);
        if (p > 0.40 && _outputItems.length == 1) _spawnOutput('dog_🐩', '5', startX + 110);
        if (p > 0.55 && _outputItems.length == 2) _spawnOutput('dog_🦮', '9', startX + 190);
        if (p > 0.70 && _outputItems.length == 3) _spawnOutput('dog_🐶', '4', startX + 270);
      } else if (s == 2) {
        _robotWave = sin(p * 20) * 0.4;
        if (p > 0.2 && p < 0.6) _robotScanAlpha = 0.5; else _robotScanAlpha = 0;
        if (p > 0.6 && _outputItems.isEmpty) _spawnOutput('block', t('sparky'), startX + 100);
      } else if (s == 3) {
        if (p > 0.2 && p < 0.3) { _mapActiveNode = 0; if (p < 0.205) _playSound('zap'); }
        else if (p > 0.35 && p < 0.45) { _mapActiveNode = 1; if (p < 0.355) _playSound('zap'); }
        else if (p > 0.5 && p < 0.6) { _mapActiveNode = 2; if (p < 0.505) _playSound('zap'); }
        else { _mapActiveNode = null; }

        if (p > 0.3 && _outputItems.isEmpty) _spawnOutput('tennis_tag', '₹25', startX + 30);
        if (p > 0.45 && _outputItems.length == 1) _spawnOutput('tennis_tag', '₹30', startX + 110);
        if (p > 0.6 && _outputItems.length == 2) _spawnOutput('tennis_tag', '₹28', startX + 190);
        if (p > 0.75 && _outputItems.length == 3) _spawnOutput('tennis_tag', '₹35', startX + 270);
      } else if (s == 4) {
        if (p > 0.60 && _outputItems.isEmpty) _spawnOutput('emoji', '👍', startX + 30);
        if (p > 0.70 && _outputItems.length == 1) _spawnOutput('emoji', '👎', startX + 110);
        if (p > 0.80 && _outputItems.length == 2) _spawnOutput('emoji', '👍', startX + 190);
        if (p > 0.90 && _outputItems.length == 3) _spawnOutput('emoji', '👍', startX + 270);
      } else if (s == 5) {
        if (p > 0.7 && _outputItems.isEmpty) _spawnOutput('block', t('neil_armstrong'), startX + 150);
      }

      if (p >= 1.0) {
        _machineState = 'done';
        _robotScanAlpha = 0;
        _robotWave = 0;
        
        _cardHomeX = _machX + 100;
        _cardHomeY = _machY + 240; 
        _cardTargetX = _cardHomeX;
        _cardTargetY = _cardHomeY;
        
        _advanceStep(); // Go to observe output step (Step 2)
        
        // Wait 3 seconds then advance to bin sorting step (Step 3)
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _machineState == 'done') _advanceStep();
        });
      }
      rebuild = true;
    }

    // Output items easing
    if (_outputItems.isNotEmpty) {
      for (var item in _outputItems) {
        if ((item.x - item.targetX).abs() > 0.5) {
          item.x += (item.targetX - item.x) * 0.1;
          double dx = item.x - (_machX + _machW);
          item.y = 120 - 20 + (dx * 0.1); // Conveyor Y is roughly 120
          rebuild = true;
        }
        if (item.scale < 1.0) {
          item.scale += (1.0 - item.scale) * 0.1;
          rebuild = true;
        }
      }
    }

    if (rebuild) setState(() {});
  }

  void _spawnOutput(String type, String text, double targetX) {
    if (type != 'tennis_tag') _playSound('pop');
    _outputItems.add(OutputItem(
      type: type,
      text: text,
      x: _machX + _machW - 40,
      y: 120 - 15,
      targetX: targetX,
    ));
  }

  void _startMachineAnimation() {
    setState(() {
      _machineState = 'processing';
      _animProgress = 0;
      _outputItems.clear();
      _conveyorW = 0;
      _robotScanAlpha = 0;
      _mapActiveNode = null;
    });
    _playSound('whir');
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

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    setState(() => _step = 4);
    _playSound('success');
    _scrollToActiveStep();
    Future.delayed(const Duration(milliseconds: 600), () {
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

  bool _hitTestRect(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    _dragX = pt.dx;
    _dragY = pt.dy;

    if (_step != 4 && _machineState != 'processing') {
      if (_hitTestRect(_cardX - 110, _cardY - 30, 220, 60, pt)) {
        setState(() { _isCardDragging = true; });
        _playSound('tick');
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      if (_isCardDragging) {
        _cardTargetX = pt.dx;
        _cardTargetY = pt.dy;
        return;
      }

      // Pan & Zoom
      if (details.scale != 1.0) {
        _zoom = (_baseZoom * details.scale).clamp(0.2, 1.5);
      }
      _panX += details.focalPointDelta.dx / _zoom;
      _panY += details.focalPointDelta.dy / _zoom;
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_isCardDragging) {
      setState(() {
        _isCardDragging = false;
        Offset pt = Offset(_cardTargetX, _cardTargetY);

        if (_step == 1) { // Drop into machine slot
          double slotX = _machX + 30; double slotY = _machY + 120;
          if (_hitTestRect(slotX - 20, slotY - 20, 180, 60, pt)) {
            _cardTargetX = slotX + 70; _cardTargetY = slotY + 10;
            _playSound('snap');
            _startMachineAnimation();
            return;
          }
        } else if (_step == 3) { // Drop into bins
          bool bin1Hit = _hitTestRect(_bin1X, _bin1Y, _binW, _binH, pt);
          bool bin2Hit = _hitTestRect(_bin2X, _bin2Y, _binW, _binH, pt);

          if (bin1Hit || bin2Hit) {
            bool isStat = (_scenario == 1 || _scenario == 3 || _scenario == 4);
            bool hitCorrectBin = (isStat && bin1Hit) || (!isStat && bin2Hit);

            if (hitCorrectBin) {
              _cardTargetX = (bin1Hit ? _bin1X : _bin2X) + _binW / 2;
              _cardTargetY = (bin1Hit ? _bin1Y : _bin2Y) + 20;
              _playSound('snap');
              _checkScenarioSuccess();
              return;
            } else {
              _playSound('error');
              if (bin1Hit) _bin1ErrorTime = DateTime.now().millisecondsSinceEpoch;
              if (bin2Hit) _bin2ErrorTime = DateTime.now().millisecondsSinceEpoch;

              if (_scenario == 4) _showTemporaryHUD(t('hint_s4'));
              else if (_scenario == 5) _showTemporaryHUD(t('hint_s5'));
              else _showTemporaryHUD("Incorrect Bin! Try again.");
            }
          }
        }

        // Return home if not snapped
        _playSound('pop');
        _cardTargetX = _cardHomeX;
        _cardTargetY = _cardHomeY;
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
        spans.add(TextSpan(text: bParts[i], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade400)));
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

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(-5, 0))],
      ),
      child: SingleChildScrollView(
        controller: _sidebarScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.teal.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.bar_chart, color: Colors.tealAccent),
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
                  ...List.generate(3, (i) {
                    int actualStep = i + 1;
                    bool isPast = actualStep < _step;
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
            // MAIN CANVAS
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: StatLabPainter(
                          scenario: _scenario, step: _step, zoom: _zoom, panX: _panX, panY: _panY,
                          machineState: _machineState, animProgress: _animProgress, conveyorW: _conveyorW,
                          outputItems: _outputItems, robotWave: _robotWave, robotScanAlpha: _robotScanAlpha,
                          mapActiveNode: _mapActiveNode, bin1ErrorTime: _bin1ErrorTime, bin2ErrorTime: _bin2ErrorTime,
                          cardX: _cardX, cardY: _cardY, cardTargetX: _cardTargetX, cardTargetY: _cardTargetY, isCardDragging: _isCardDragging, cardText: t('s${_scenario}_q'),
                          bin1X: _bin1X, bin1Y: _bin1Y, bin2X: _bin2X, bin2Y: _bin2Y, binW: _binW, binH: _binH, machX: _machX, machY: _machY, machW: _machW, machH: _machH,
                          t: t,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // HUD Overlays
            if (_step <= 3 && (hudText != 's${_scenario}_hud$_step' || _showHud))
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

            // MENU TOGGLE TOP LEFT (Fixed)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.tealAccent,
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
                    side: BorderSide(color: Colors.teal.withOpacity(0.8)),
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
                                  Text(t('guideNextScenario'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                                if (_scenario == 5)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _playSound('pop');
                                          setState(() => _showSuccessPopup = false);
                                          _handleReset();
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: Text(t('resetBtn')),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          backgroundColor: Colors.indigoAccent,
                                          foregroundColor: Colors.white,
                                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Positioned(
                              top: -10, right: -10,
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
                          width: 120, height: 120,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.tealAccent.withOpacity(0.6), blurRadius: 20)]),
                          child: const Icon(Icons.bar_chart, size: 60, color: Colors.white),
                        ),
                        Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 16),
                        Text(t('appSubtitle'), style: const TextStyle(color: Colors.tealAccent, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
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
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shadowColor: Colors.tealAccent.withOpacity(0.5),
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
class StatLabPainter extends CustomPainter {
  final int scenario, step;
  final double zoom, panX, panY;
  
  final String machineState;
  final double animProgress;
  final double conveyorW;
  final List<OutputItem> outputItems;
  final double robotWave;
  final double robotScanAlpha;
  final int? mapActiveNode;
  final int bin1ErrorTime, bin2ErrorTime;
  
  final double cardX, cardY, cardTargetX, cardTargetY;
  final bool isCardDragging;
  final String cardText;

  final double bin1X, bin1Y, bin2X, bin2Y, binW, binH, machX, machY, machW, machH;

  final Function(String) t;

  StatLabPainter({
    required this.scenario, required this.step, required this.zoom, required this.panX, required this.panY,
    required this.machineState, required this.animProgress, required this.conveyorW,
    required this.outputItems, required this.robotWave, required this.robotScanAlpha,
    required this.mapActiveNode, required this.bin1ErrorTime, required this.bin2ErrorTime,
    required this.cardX, required this.cardY, required this.cardTargetX, required this.cardTargetY, required this.isCardDragging, required this.cardText,
    required this.bin1X, required this.bin1Y, required this.bin2X, required this.bin2Y, required this.binW, required this.binH, required this.machX, required this.machY, required this.machW, required this.machH,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Draw Environment
    _drawEnvironment(canvas);
    
    // Draw Bins
    _drawBin(canvas, bin1X, bin1Y, 'stat');
    _drawBin(canvas, bin2X, bin2Y, 'nonstat');

    // Draw Machine
    _drawMachine(canvas);

    // Draw Context Objects (Robot, Map, etc)
    if (scenario == 2) {
      _drawRobot(canvas, machX + 320, machY + 180, robotWave);
      if (robotScanAlpha > 0) {
        Path scan = Path()..moveTo(machX + machW, machY + 80)..lineTo(machX + 280, machY + 100)..lineTo(machX + 280, machY + 260)..close();
        canvas.drawPath(scan, Paint()..color = const Color(0xFF38BDF8).withOpacity(robotScanAlpha));
      }
    } else if (scenario == 3) {
      _drawIndiaMap(canvas, machX + 280, machY + 50);
    } else if (scenario == 4) {
      _drawClassroom(canvas);
    }

    // Draw Conveyor
    if (conveyorW > 0) {
      _drawConveyor(canvas);
    }

    // Draw Output Items
    for (var item in outputItems) {
      _drawOutputItem(canvas, item);
    }

    // Draw Card
    _drawCard(canvas);

    canvas.restore();
  }

  void _drawEnvironment(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-2000, -2000, 4000, 2050), Paint()..color = const Color(0xFF064E3B));
    
    Path floor = Path()..moveTo(-2000, 50)..lineTo(2000, 50)..lineTo(2000, 1000)..lineTo(-2000, 1000)..close();
    canvas.drawPath(floor, Paint()..color = const Color(0xFF1E293B));
    
    canvas.drawRect(const Rect.fromLTWH(-2000, 50, 4000, 20), Paint()..color = const Color(0xFF0F172A));
    
    Paint linePaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 4;
    for (double i = -1500; i < 2000; i += 300) {
      canvas.drawLine(Offset(i, 70), Offset(i - 100, 1000), linePaint);
    }
  }

  void _draw25DBox(Canvas canvas, double x, double y, double w, double h, double d, Color frontCol, Color sideCol, Color topCol) {
    Path top = Path()..moveTo(x, y)..lineTo(x + w, y)..lineTo(x + w - d, y - d)..lineTo(x - d, y - d)..close();
    canvas.drawPath(top, Paint()..color = topCol);
    
    Path side = Path()..moveTo(x, y)..lineTo(x - d, y - d)..lineTo(x - d, y + h - d)..lineTo(x, y + h)..close();
    canvas.drawPath(side, Paint()..color = sideCol);
    
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = frontCol);
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

  void _drawBin(Canvas canvas, double x, double y, String type) {
    bool isStat = type == 'stat';
    bool isCorrectBinForScenario = (scenario == 1 || scenario == 3 || scenario == 4) ? isStat : !isStat;
    bool isHighlighted = step == 3 && ((scenario <= 3 && isCorrectBinForScenario) || scenario > 3);
    
    Color frontCol = isStat ? const Color(0xFF0284C7) : const Color(0xFF475569);
    Color sideCol  = isStat ? const Color(0xFF0369A1) : const Color(0xFF334155);
    Color topCol   = isStat ? const Color(0xFF075985) : const Color(0xFF1E293B);
    Color glowCol  = isStat ? const Color(0xFF4ADE80) : const Color(0xFFF43F5E);

    bool hasError = (DateTime.now().millisecondsSinceEpoch - (isStat ? bin1ErrorTime : bin2ErrorTime)) < 800;
    if (hasError) {
      glowCol = const Color(0xFFEF4444);
      isHighlighted = true;
      frontCol = const Color(0xFFEF4444);
    }

    if (isHighlighted) {
      for (int i = 0; i < 3; i++) {
        canvas.drawRect(Rect.fromLTWH(x - 5*i, y - 5*i, binW + 10*i, binH + 10*i), Paint()..color = glowCol.withOpacity(0.2 - i*0.05)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
      }
      frontCol = glowCol;
    } else {
      canvas.drawRect(Rect.fromLTWH(x+10, y+15, binW, binH), Paint()..color = Colors.black45..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }

    _draw25DBox(canvas, x, y, binW, binH, 30, frontCol, sideCol, topCol);
    
    Path slot = Path()..moveTo(x + 10, y + 10)..lineTo(x + binW - 10, y + 10)..lineTo(x + binW - 30, y - 20)..lineTo(x - 10, y - 20)..close();
    canvas.drawPath(slot, Paint()..color = const Color(0xFF0F172A));
    
    String labelText = t(isStat ? 'binStat' : 'binNonStat');
    _drawTextOutline(canvas, labelText, x + binW / 2, y + binH / 2 + 10, 15, Colors.white, Colors.transparent, 0);
    
    if (isHighlighted && !hasError && isCorrectBinForScenario && isCardDragging) {
      _drawTextOutline(canvas, '⬇️', x + binW / 2, y - 40, 30, glowCol, Colors.transparent, 0);
    }
  }

  void _drawMachine(Canvas canvas) {
    Color mFront = const Color(0xFF0284C7);
    Color mSide = const Color(0xFF0369A1);
    Color mTop = const Color(0xFF075985);
    
    canvas.drawRect(Rect.fromLTWH(machX+15, machY+20, machW, machH), Paint()..color = Colors.black54..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    _draw25DBox(canvas, machX, machY, machW, machH, 40, mFront, mSide, mTop);

    canvas.drawRect(Rect.fromLTWH(machX + 20, machY + 20, machW - 40, machH - 40), Paint()..color = const Color(0xFFD97706));
    
    Color screenCol = machineState == 'processing' ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(machX + 40, machY + 40, machW - 80, 80), Paint()..color = screenCol);
    
    _drawTextOutline(canvas, t('machineLbl'), machX + machW / 2, machY + 60, 14, Colors.white, Colors.transparent, 0);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(machX + 40, machY + 40, machW - 80, 80));
    if (machineState == 'processing') {
      double p = animProgress;
      if (scenario == 1 || scenario == 4) {
        double scanY = (machY + 40) + ((p * 2) % 1) * 80;
        canvas.drawRect(Rect.fromLTWH(machX + 40, scanY, machW - 80, 10), Paint()..color = const Color(0x6638BDF8));
      } else if (scenario == 5) {
        if (p < 0.5) {
          double rocketY = machY + 100 - (p / 0.5) * 80;
          _drawTextOutline(canvas, '🌌', machX + machW / 2, machY + 80, 50, Colors.white, Colors.transparent, 0);
          _drawTextOutline(canvas, '🚀', machX + machW / 2, rocketY, 30, Colors.white, Colors.transparent, 0);
        } else {
          _drawTextOutline(canvas, '🌑', machX + machW / 2 - 20, machY + 80, 40, Colors.white, Colors.transparent, 0);
          _drawTextOutline(canvas, '👨‍🚀', machX + machW / 2 + 10, machY + 85, 30, Colors.white, Colors.transparent, 0);
          _drawTextOutline(canvas, '🚩', machX + machW / 2 + 25, machY + 85, 25, Colors.white, Colors.transparent, 0);
        }
      }
    }
    canvas.restore();

    canvas.drawRect(Rect.fromLTWH(machX + 30, machY + 140, 140, 20), Paint()..color = const Color(0xFF0F172A));
    if (step == 1 && !isCardDragging && cardX == -350) {
      _drawTextOutline(canvas, "▼ ${t('slotLbl')} ▼", machX + machW / 2, machY + 130, 12, const Color(0xFF4ADE80), Colors.transparent, 0);
    }

    canvas.drawRect(Rect.fromLTWH(machX + 50, machY + 230, 120, 15), Paint()..color = Colors.black);

    double leftCenterX = machX - 20; double leftCenterY = machY + 60;
    _drawTextOutline(canvas, '⚙️', leftCenterX, leftCenterY, 30, Colors.white, Colors.transparent, 0);
    _drawTextOutline(canvas, '⚙️', leftCenterX - 5, leftCenterY + 40, 20, Colors.white, Colors.transparent, 0);
    _drawTextOutline(canvas, '⚙️', leftCenterX + 5, leftCenterY + 80, 35, Colors.white, Colors.transparent, 0);
  }

  void _drawRobot(Canvas canvas, double x, double y, double wave) {
    canvas.save(); canvas.translate(x, y);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-15, 45), width: 20, height: 10), Paint()..color = const Color(0xFFF59E0B));
    canvas.drawOval(Rect.fromCenter(center: const Offset(15, 45), width: 20, height: 10), Paint()..color = const Color(0xFFF59E0B));
    canvas.drawRect(const Rect.fromLTWH(-18, 30, 6, 15), Paint()..color = const Color(0xFF94A3B8));
    canvas.drawRect(const Rect.fromLTWH(12, 30, 6, 15), Paint()..color = const Color(0xFF94A3B8));
    
    RRect body = RRect.fromRectAndRadius(const Rect.fromLTWH(-20, -10, 40, 40), const Radius.circular(10));
    canvas.drawRRect(body, Paint()..color = const Color(0xFFF8FAFC)); canvas.drawRRect(body, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawRect(const Rect.fromLTWH(-10, 0, 20, 20), Paint()..color = const Color(0xFF0EA5E9));
    canvas.drawRect(const Rect.fromLTWH(-5, -20, 10, 10), Paint()..color = const Color(0xFF94A3B8));
    
    RRect head = RRect.fromRectAndRadius(const Rect.fromLTWH(-25, -52.5, 50, 35), const Radius.circular(10));
    canvas.drawRRect(head, Paint()..color = const Color(0xFFF8FAFC)); canvas.drawRRect(head, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-20, -45, 40, 20), const Radius.circular(6)), Paint()..color = const Color(0xFF0F172A));
    
    canvas.drawCircle(const Offset(-8, -38), 4, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(const Offset(8, -38), 4, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawArc(const Rect.fromLTWH(-6, -35, 12, 12), 0, pi, false, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    canvas.drawRect(const Rect.fromLTWH(-2, -58, 4, 8), Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(const Offset(0, -60), 4, Paint()..color = const Color(0xFFF59E0B));
    
    canvas.drawCircle(const Offset(-25, 5), 6, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawRect(const Rect.fromLTWH(-35, 2, 10, 20), Paint()..color = const Color(0xFF94A3B8));

    canvas.save(); canvas.translate(25, 5); canvas.rotate(wave);
    canvas.drawCircle(const Offset(0, 0), 6, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawRect(const Rect.fromLTWH(0, -5, 20, 10), Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(const Offset(20, 0), 6, Paint()..color = const Color(0xFFF8FAFC));
    canvas.restore();
    
    canvas.restore();
  }

  void _drawIndiaMap(Canvas canvas, double x, double y) {
    canvas.save(); canvas.translate(x, y);
    Path mapPath = Path()
      ..moveTo(-20, -80)..lineTo(20, -70)..lineTo(50, -30)..lineTo(80, -20)
      ..lineTo(60, 10)..lineTo(40, 20)..lineTo(20, 80)..lineTo(0, 120)
      ..lineTo(-30, 80)..lineTo(-50, 20)..lineTo(-70, -10)..lineTo(-40, -40)..close();
      
    canvas.drawPath(mapPath, Paint()..color = const Color(0x9938BDF8)..style = PaintingStyle.stroke..strokeWidth = 3..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3));

    List<Map<String, dynamic>> nodes = [
      {'nx': -10.0, 'ny': -40.0, 'lbl': t('delhi')},
      {'nx': -40.0, 'ny': 30.0, 'lbl': t('mumbai')},
      {'nx': 10.0, 'ny': 80.0, 'lbl': t('chennai')}
    ];

    for (int i = 0; i < nodes.length; i++) {
      var n = nodes[i];
      canvas.drawCircle(Offset(n['nx'], n['ny']), 5, Paint()..color = (mapActiveNode == i) ? const Color(0xFFF59E0B) : const Color(0xFFF8FAFC));
      _drawTextOutline(canvas, n['lbl'], n['nx'] + 10, n['ny'], 12, Colors.white, Colors.transparent, 0, align: TextAlign.left);
    }

    if (mapActiveNode != null) {
      double machExitX = -120; double machExitY = 30;
      var tNode = nodes[mapActiveNode!];
      
      Path zap = Path()..moveTo(machExitX, machExitY);
      zap.lineTo(machExitX + (tNode['nx'] - machExitX)*0.3, machExitY + (tNode['ny'] - machExitY)*0.3 + (Random().nextDouble()*20-10));
      zap.lineTo(machExitX + (tNode['nx'] - machExitX)*0.6, machExitY + (tNode['ny'] - machExitY)*0.6 + (Random().nextDouble()*20-10));
      zap.lineTo(tNode['nx'], tNode['ny']);
      canvas.drawPath(zap, Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    canvas.restore();
  }

  void _drawClassroom(Canvas canvas) {
    double p = animProgress;
    canvas.drawOval(Rect.fromCenter(center: Offset(machX + 250, machY + 150), width: 120, height: 30), Paint()..color = const Color(0xFF0284C7));
    Path holo = Path()..moveTo(machX + 220, machY + 150)..lineTo(machX + 280, machY + 150)..lineTo(machX + 400, machY - 50)..lineTo(machX + 100, machY - 50)..close();
    canvas.drawPath(holo, Paint()..color = const Color(0x3338BDF8));

    if (p > 0.2 || machineState == 'done') {
      for (int i = 0; i < 10; i++) {
        double sx = machX + 150 + (i % 5) * 40;
        double sy = machY - 20 + (i ~/ 5) * 40;
        _drawTextOutline(canvas, '🧑‍🎓', sx, sy, 30, Colors.white, Colors.transparent, 0);
        if (p > 0.4 && p < 0.6 && machineState == 'processing') {
          _drawTextOutline(canvas, '❓', sx, sy - 25, 20, Colors.white, Colors.transparent, 0);
        } else if (p >= 0.6 || machineState == 'done') {
          String resp = (i % 3 == 0) ? '👎' : '👍';
          _drawTextOutline(canvas, resp, sx, sy - 25, 20, Colors.white, Colors.transparent, 0);
        }
      }
    }
  }

  void _drawConveyor(Canvas canvas) {
    canvas.save();
    double cY = 120;
    canvas.drawRect(Rect.fromLTWH(machX + machW + 5, cY + 5, conveyorW, 30), Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    
    Path belt = Path()..moveTo(machX + machW, cY)..lineTo(machX + machW + conveyorW, cY + conveyorW * 0.1)..lineTo(machX + machW + conveyorW, cY + conveyorW * 0.1 + 30)..lineTo(machX + machW, cY + 30)..close();
    canvas.drawPath(belt, Paint()..color = const Color(0xFF334155));
    
    canvas.drawLine(Offset(machX + machW, cY + 15), Offset(machX + machW + conveyorW, cY + conveyorW * 0.1 + 15), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 4);
    canvas.restore();
  }

  void _drawOutputItem(Canvas canvas, OutputItem item) {
    canvas.save();
    canvas.translate(item.x, item.y);
    canvas.scale(item.scale, item.scale);
    
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 30), width: 40, height: 16), Paint()..color = Colors.black45);

    if (item.type == 'tennis_tag') {
      Path tag = Path()..moveTo(-30, -15)..lineTo(15, -15)..lineTo(35, 0)..lineTo(15, 15)..lineTo(-30, 15)..close();
      canvas.drawPath(tag, Paint()..color = const Color(0xFFE2E8F0)); canvas.drawPath(tag, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawCircle(const Offset(20, 0), 4, Paint()..color = const Color(0xFF0F172A));
      _drawTextOutline(canvas, item.text, -5, 0, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, '🎾', -12, -25, 20, Colors.white, Colors.transparent, 0);
    } else if (item.type.startsWith('dog_')) {
      String dogEmoji = item.type.split('_')[1];
      _drawTextOutline(canvas, dogEmoji, 0, -5, 45, Colors.white, Colors.transparent, 0);
      Path hex = Path();
      for (int i = 0; i < 6; i++) {
        double a = (i * pi) / 3; double r = 16;
        if (i == 0) hex.moveTo(cos(a) * r + 15, sin(a) * r + 20); else hex.lineTo(cos(a) * r + 15, sin(a) * r + 20);
      }
      hex.close();
      canvas.drawPath(hex, Paint()..color = Colors.white); canvas.drawPath(hex, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2);
      _drawTextOutline(canvas, item.text, 15, 20, 12, const Color(0xFF0F172A), Colors.transparent, 0);
    } else if (item.type == 'block') {
      double w = max(80.0, item.text.length * 8.0 + 20.0);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w/2, -20, w, 40), const Radius.circular(8)), Paint()..color = const Color(0xFFF8FAFC));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w/2, -20, w, 40), const Radius.circular(8)), Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2);
      _drawTextOutline(canvas, item.text, 0, 0, 14, const Color(0xFF0F172A), Colors.transparent, 0);
    } else if (item.type == 'emoji') {
      _drawTextOutline(canvas, item.text, 0, 0, 40, Colors.white, Colors.transparent, 0);
    }
    
    canvas.restore();
  }

  void _drawCard(Canvas canvas) {
    canvas.save();
    
    if (isCardDragging) {
      canvas.translate(cardTargetX, cardTargetY);
      canvas.scale(1.05, 1.05);
      canvas.drawRect(const Rect.fromLTWH(-110, -30, 220, 60).shift(const Offset(10, 15)), Paint()..color = Colors.black54..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    } else {
      canvas.translate(cardX, cardY);
      canvas.drawRect(const Rect.fromLTWH(-110, -30, 220, 60).shift(const Offset(5, 5)), Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }

    if (!(machineState == 'processing' && step == 1 && !isCardDragging)) {
      RRect cardRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-110, -30, 220, 60), const Radius.circular(6));
      canvas.drawRRect(cardRect, Paint()..color = const Color(0xFFF8FAFC));
      canvas.drawRRect(cardRect, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2);

      List<String> words = cardText.split(' ');
      List<String> lines = [];
      String currentLine = '';
      for (String word in words) {
        String testLine = currentLine + word + ' ';
        TextPainter tp = TextPainter(text: TextSpan(text: testLine, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')), textDirection: TextDirection.ltr)..layout();
        if (tp.width > 200 && currentLine.isNotEmpty) {
          lines.add(currentLine); currentLine = word + ' ';
        } else {
          currentLine = testLine;
        }
      }
      lines.add(currentLine);

      double startY = -(lines.length - 1) * 8.0;
      for (int i = 0; i < lines.length; i++) {
        _drawTextOutline(canvas, lines[i].trim(), 0, startY + (i * 18), 14, const Color(0xFF0F172A), Colors.transparent, 0);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StatLabPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA (EN, HI, TE)
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "Statistical Thinking: The Power of Variability", 'appSubtitle': "Class 7 • CONNECTING THE DOTS...", 'enterLab': "Enter Lab",
    'settings': "Settings", 'boardFontSize': "Text Size", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done",
    'actTitle': "Action:", 'obsLbl': "Observation:", 'learnLbl': "Learning:", 'nextScenario': "Next Scenario",
    
    'binStat': "Statistical Question", 'binNonStat': "Non-Statistical Question", 
    'machineLbl': "Data Collector", 'slotLbl': "CARD SLOT", 'trayLbl': "OUTPUT TRAY",
    'sparky': "Sparky", 'delhi': "Delhi", 'mumbai': "Mumbai", 'chennai': "Chennai", 'neil_armstrong': "Neil Armstrong",
    'hint_s4': "Hint: Look at the data. Did everyone give the same answer, or were there different answers?",
    'hint_s5': "Hint: Is this a question where the answer changes depending on who you ask, or is there only one correct answer in the history books?",
    'finalSuccessTitle': "Activity Completed!", 'finalSuccessDesc': "You have successfully mastered identifying statistical questions.", 'finalRestartBtn': "Restart Activity",
    'guideNextScenario': "This scenario is completed! Please open the sidebar menu to select and try the next scenario.",

    's1_title': "1. The Dogs on Our Street (Solved)", 's1_obj': "To understand that a question requiring data collection with varying results is a statistical question.",
    's1_q': "How old are the dogs that live on this street?",
    's1_hud1': "DRAG the question card and DROP it into the Data Collector's slot.", 
    's1_step1_task': "DRAG the question card 'How old are the dogs that live on this street?' and DROP it into the slot on the Data Collector machine.", 
    's1_step1_obs': "The machine accepts the card, whirs, and glows.", 's1_step1_learn': "We are asking the machine to find the answer.",
    's1_hud2': "OBSERVE the Data Collector's output tray.", 
    's1_step2_task': "OBSERVE the Data Collector's output.", 
    's1_step2_obs': "The machine dispenses multiple dog icons, each with a different age (2, 5, 9, 4).", 's1_step2_learn': "There are many dogs, and their ages vary. We got a collection of different data points.",
    's1_hud3': "DRAG the returned card to the glowing 'Statistical' bin.", 
    's1_step3_task': "The 'Statistical Question' bin is highlighted with a green glow. DRAG the original question card from the machine's 'return' slot and DROP it into the glowing 'Statistical Question' bin.", 
    's1_step3_obs': "The card was sorted correctly into the Statistical bin.", 's1_step3_learn': "Because the answer varied and required collecting multiple data points, it is a statistical question.",
    's1_final': "Correct! This is a <strong class='text-teal-400'>Statistical Question</strong>. To answer it, you had to collect data from many different dogs, and their ages <strong class='text-teal-400'>varied</strong>. Statistics helps us understand data that has variability!",

    's2_title': "2. A Robot's Identity (Solved)", 's2_obj': "To understand that a question with a single, factual answer is not a statistical question.",
    's2_q': "What is the name of the lab assistant robot?",
    's2_hud1': "DRAG the question card to the Data Collector.", 
    's2_step1_task': "DRAG the question card 'What is the name of the lab assistant robot?' and DROP it into the machine.", 
    's2_step1_obs': "The machine scans the nearby robot.", 's2_step1_learn': "The machine is looking for a specific fact.",
    's2_hud2': "OBSERVE the output tray.", 
    's2_step2_task': "OBSERVE the Data Collector's output.", 
    's2_step2_obs': "The machine dispensed a single data block: 'Sparky'.", 's2_step2_learn': "There is only one robot, and it has only one name.",
    's2_hud3': "DRAG the card to the glowing 'Non-Statistical' bin.", 
    's2_step3_task': "The 'Non-Statistical Question' bin is highlighted. DRAG the card and DROP it into the glowing bin.", 
    's2_step3_obs': "The card was sorted correctly.", 's2_step3_learn': "Because there is only one factual answer and no variability, it is non-statistical.",
    's2_final': "Correct! This is a <strong class='text-teal-400'>Non-Statistical Question</strong>. It has only <strong class='text-teal-400'>one correct answer</strong>. There is no variability in the data to collect or study.",

    's3_title': "3. The Price of a Tennis Ball (Solved)", 's3_obj': "To identify a statistical question even when it seems to ask about a single item.",
    's3_q': "What is the price of a tennis ball in India?",
    's3_hud1': "DRAG the question card to the Data Collector.", 
    's3_step1_task': "DRAG the question card 'What is the price of a tennis ball in India?' and DROP it into the machine.", 
    's3_step1_obs': "The machine displays a holographic map.", 's3_step1_learn': "Prices can be different in different places.",
    's3_hud2': "OBSERVE the map and the output tray.", 
    's3_step2_task': "OBSERVE the Data Collector's output as it scans different locations.", 
    's3_step2_obs': "The machine zapped different cities and dispensed multiple price tags with different values.", 's3_step2_learn': "Even though we asked about 'a' tennis ball, the price varies.",
    's3_hud3': "DRAG the card to the highlighted bin.", 
    's3_step3_task': "DRAG the original question card and DROP it into the glowing 'Statistical Question' bin.", 
    's3_step3_obs': "The card was sorted correctly.", 's3_step3_learn': "To find a typical price, you must collect data because prices vary.",
    's3_final': "You got it! This is a <strong class='text-teal-400'>Statistical Question</strong>. Even though it asks about 'a' tennis ball, the price <strong class='text-teal-400'>varies</strong> by shop, brand, and city. To find a 'typical' price, you need to collect data!",

    's4_title': "4. Pizza Preferences (Challenge)", 's4_obj': "To independently classify a question about preferences as statistical.",
    's4_q': "What fraction of students in this class like pizza?",
    's4_hud1': "DRAG the question card to the Data Collector.", 
    's4_step1_task': "DRAG the question card 'What fraction of students in this class like pizza?' to the machine.", 
    's4_step1_obs': "The machine projects a hologram of a classroom.", 's4_step1_learn': "It must ask multiple people to find a fraction.",
    's4_hud2': "OBSERVE the students' responses.", 
    's4_step2_task': "OBSERVE the data collection process and the results.", 
    's4_step2_obs': "The machine dispensed a mix of 'Yes' (👍) and 'No' (👎) icons.", 's4_step2_learn': "People have different preferences, so the data varies.",
    's4_hud3': "Challenge: DRAG the card to the CORRECT bin.", 
    's4_step3_task': "Now, you decide. DRAG the question card to the bin you think is correct: 'Statistical' or 'Non-Statistical'.", 
    's4_step3_obs': "The card was sorted into the Statistical bin.", 's4_step3_learn': "Because responses vary among students, this is a statistical question.",
    's4_final': "Excellent! You successfully identified that preferences vary, making this a <strong class='text-teal-400'>Statistical Question</strong>.",

    's5_title': "5. A Fact from History (Challenge)", 's5_obj': "To independently classify a question with a single historical answer as non-statistical.",
    's5_q': "Who was the first person to walk on the moon?",
    's5_hud1': "DRAG the question card to the Data Collector.", 
    's5_step1_task': "DRAG the question card 'Who was the first person to walk on the moon?' to the machine.", 
    's5_step1_obs': "The machine looks up historical records via animation.", 's5_step1_learn': "Historical events have fixed outcomes.",
    's5_hud2': "OBSERVE the historical output.", 
    's5_step2_task': "OBSERVE the Data Collector's output.", 
    's5_step2_obs': "The machine dispensed a single name: 'Neil Armstrong'.", 's5_step2_learn': "There can only be one 'first' person.",
    's5_hud3': "Challenge: DRAG the card to the CORRECT bin.", 
    's5_step3_task': "It's your turn. DRAG the question card to the bin you believe is correct.", 
    's5_step3_obs': "The card was sorted into the Non-Statistical bin.", 's5_step3_learn': "Historical facts do not vary; there is only one correct answer.",
    's5_final': "Perfect! Historical facts have a single answer with no variability, so this is <strong class='text-teal-400'>Non-Statistical</strong>."
  },
  'hi': {
    'shutterTitle': "सांख्यिकीय सोच: परिवर्तनशीलता की शक्ति", 'appSubtitle': "कक्षा 7 • बिंदुओं को जोड़ना...", 'enterLab': "लैब में प्रवेश करें",
    'settings': "सेटिंग्स", 'boardFontSize': "टेक्स्ट आकार", 'theme': "थीम", 'darkMode': "डार्क मोड", 'lightMode': "लाइट मोड", 'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण",
    'actTitle': "कार्य:", 'obsLbl': "अवलोकन:", 'learnLbl': "सीख:", 'nextScenario': "अगला परिदृश्य",
    'binStat': "सांख्यिकीय प्रश्न", 'binNonStat': "गैर-सांख्यिकीय प्रश्न", 'machineLbl': "डेटा कलेक्टर", 'slotLbl': "कार्ड स्लॉट", 'trayLbl': "आउटपुट ट्रे",
    'sparky': "स्पार्की", 'delhi': "दिल्ली", 'mumbai': "मुंबई", 'chennai': "चेन्नई", 'neil_armstrong': "नील आर्मस्ट्रांग",
    'hint_s4': "संकेत: डेटा देखें। क्या सभी ने एक ही उत्तर दिया, या अलग-अलग उत्तर थे?",
    'hint_s5': "संकेत: क्या यह ऐसा प्रश्न है जिसका उत्तर पूछने वाले व्यक्ति पर निर्भर करता है, या इतिहास में केवल एक ही सही उत्तर है?",
    'finalSuccessTitle': "गतिविधि पूरी हुई!", 'finalSuccessDesc': "आपने सांख्यिकीय प्रश्नों की पहचान करना सफलतापूर्वक सीख लिया है।", 'finalRestartBtn': "गतिविधि पुनरारंभ करें",
    'guideNextScenario': "यह परिदृश्य पूरा हो गया है! कृपया अगला परिदृश्य चुनने और आजमाने के लिए साइडबार मेनू खोलें।",
    
    's1_title': "1. हमारी गली के कुत्ते (हल)", 's1_obj': "यह समझना कि जिस प्रश्न के लिए भिन्न परिणामों वाले डेटा संग्रह की आवश्यकता होती है, वह एक सांख्यिकीय प्रश्न है।", 's1_q': "इस गली के कुत्ते कितने साल के हैं?", 's1_hud1': "प्रश्न कार्ड को खींचकर मशीन के स्लॉट में डालें।", 's1_step1_task': "प्रश्न कार्ड 'इस गली के कुत्ते कितने साल के हैं?' को खींचें और मशीन में डालें।", 's1_step1_obs': "मशीन ने कार्ड स्वीकार किया।", 's1_step1_learn': "हम मशीन से उत्तर खोजने के लिए कह रहे हैं।", 's1_hud2': "मशीन का आउटपुट देखें।", 's1_step2_task': "डेटा कलेक्टर का आउटपुट देखें।", 's1_step2_obs': "मशीन ने अलग-अलग उम्र वाले कई कुत्ते आइकन दिए।", 's1_step2_learn': "कई कुत्ते हैं, और उनकी उम्र अलग-अलग है।", 's1_hud3': "कार्ड को सही 'सांख्यिकीय' बिन में डालें।", 's1_step3_task': "कार्ड को चमकते हुए 'सांख्यिकीय प्रश्न' बिन में खींचें।", 's1_step3_obs': "कार्ड सही ढंग से छांटा गया।", 's1_step3_learn': "क्योंकि उत्तर भिन्न था, यह एक सांख्यिकीय प्रश्न है।", 's1_final': "सही! यह एक सांख्यिकीय प्रश्न है क्योंकि उम्र में परिवर्तनशीलता थी।",
    's2_title': "2. एक रोबोट की पहचान (हल)", 's2_obj': "यह समझना कि एकल तथ्यात्मक उत्तर वाला प्रश्न सांख्यिकीय नहीं है।", 's2_q': "लैब रोबोट का नाम क्या है?", 's2_hud1': "कार्ड को मशीन में खींचें।", 's2_step1_task': "प्रश्न कार्ड मशीन में खींचें।", 's2_step1_obs': "मशीन रोबोट को स्कैन करती है।", 's2_step1_learn': "मशीन एक विशिष्ट तथ्य की तलाश में है।", 's2_hud2': "आउटपुट देखें।", 's2_step2_task': "आउटपुट ट्रे देखें।", 's2_step2_obs': "मशीन ने केवल एक नाम दिया: 'स्पार्की'।", 's2_step2_learn': "केवल एक ही रोबोट है।", 's2_hud3': "कार्ड को 'गैर-सांख्यिकीय' बिन में डालें।", 's2_step3_task': "कार्ड को 'गैर-सांख्यिकीय' बिन में खींचें।", 's2_step3_obs': "कार्ड सही ढंग से छांटा गया।", 's2_step3_learn': "कोई परिवर्तनशीलता नहीं है, इसलिए यह गैर-सांख्यिकीय है।", 's2_final': "सही! यह एक गैर-सांख्यिकीय प्रश्न है।",
    's3_title': "3. टेनिस बॉल की कीमत (हल)", 's3_obj': "एकल वस्तु के बारे में पूछने पर भी सांख्यिकीय प्रश्न की पहचान करना।", 's3_q': "भारत में टेनिस बॉल की कीमत क्या है?", 's3_hud1': "कार्ड को मशीन में खींचें।", 's3_step1_task': "प्रश्न कार्ड मशीन में खींचें।", 's3_step1_obs': "मशीन मानचित्र पर स्थानों का विश्लेषण करती है।", 's3_step1_learn': "कीमतें अलग-अलग हो सकती हैं।", 's3_hud2': "आउटपुट देखें।", 's3_step2_task': "विभिन्न स्थानों को स्कैन करते समय आउटपुट देखें।", 's3_step2_obs': "मशीन ने अलग-अलग कीमत टैग दिए।", 's3_step2_learn': "टेनिस बॉल की कीमत अलग-अलग होती है।", 's3_hud3': "कार्ड को सही बिन में डालें।", 's3_step3_task': "कार्ड को सांख्यिकीय बिन में डालें।", 's3_step3_obs': "कार्ड सही ढंग से छांटा गया।", 's3_step3_learn': "सामान्य कीमत खोजने के लिए, आपको डेटा एकत्र करना होगा।", 's3_final': "बिल्कुल सही! कीमत अलग-अलग होती है, इसलिए आपको डेटा एकत्र करना होगा।",
    's4_title': "4. पिज़्ज़ा पसंद (चुनौती)", 's4_obj': "पसंद के बारे में प्रश्न को सांख्यिकीय के रूप में वर्गीकृत करना।", 's4_q': "कितने छात्रों को पिज़्ज़ा पसंद है?", 's4_hud1': "कार्ड को मशीन में खींचें।", 's4_step1_task': "प्रश्न कार्ड मशीन में खींचें।", 's4_step1_obs': "मशीन कक्षा का सर्वेक्षण करती है।", 's4_step1_learn': "अंश खोजने के लिए कई लोगों से पूछना चाहिए।", 's4_hud2': "प्रतिक्रियाएं देखें।", 's4_step2_task': "डेटा संग्रह प्रक्रिया देखें।", 's4_step2_obs': "मशीन ने 'हां' और 'नहीं' आइकन दिए।", 's4_step2_learn': "लोगों की पसंद अलग-अलग होती है।", 's4_hud3': "चुनौती: कार्ड को सही बिन में डालें।", 's4_step3_task': "अब, आप तय करें। सही बिन में कार्ड खींचें।", 's4_step3_obs': "कार्ड सांख्यिकीय बिन में छांटा गया।", 's4_step3_learn': "प्रतिक्रियाएं भिन्न होती हैं, इसलिए यह सांख्यिकीय है।", 's4_final': "बहुत बढ़िया! आपने सफलतापूर्वक पहचाना कि पसंद भिन्न होती है।",
    's5_title': "5. इतिहास का एक तथ्य (चुनौती)", 's5_obj': "ऐतिहासिक उत्तर वाले प्रश्न को गैर-सांख्यिकीय के रूप में वर्गीकृत करना।", 's5_q': "चांद पर पहला व्यक्ति कौन था?", 's5_hud1': "कार्ड को मशीन में खींचें।", 's5_step1_task': "प्रश्न कार्ड मशीन में खींचें।", 's5_step1_obs': "मशीन ऐतिहासिक रिकॉर्ड देखती है।", 's5_step1_learn': "ऐतिहासिक घटनाओं के निश्चित परिणाम होते हैं।", 's5_hud2': "आउटपुट देखें।", 's5_step2_task': "आउटपुट देखें।", 's5_step2_obs': "मशीन ने एक नाम दिया: 'नील आर्मस्ट्रांग'।", 's5_step2_learn': "केवल एक ही 'पहला' व्यक्ति हो सकता है।", 's5_hud3': "चुनौती: कार्ड को सही बिन में डालें।", 's5_step3_task': "आपकी बारी। सही बिन में कार्ड खींचें।", 's5_step3_obs': "कार्ड गैर-सांख्यिकीय बिन में छांटा गया।", 's5_step3_learn': "ऐतिहासिक तथ्य भिन्न नहीं होते हैं।", 's5_final': "बिल्कुल सही! ऐतिहासिक तथ्यों में कोई परिवर्तनशीलता नहीं होती है।"
  }
};