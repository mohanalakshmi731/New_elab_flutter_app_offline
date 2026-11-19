// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TokenMachineApp());
}

class TokenMachineApp extends StatelessWidget {
  const TokenMachineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Token Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const TokenModelforIntegerMultiplication(),
    );
  }
}

class Token {
  final bool isPos;
  final double id;
  Token({required this.isPos, required this.id});
}

class SimState {
  int? mult;
  int? mand;
  String animState = 'idle'; // 'idle', 'adding', 'removing', 'done'
  int cyclesDone = 0;
  double frame = 0;
  List<Token> matTokens = [];

  int s5Phase = 1;
  int? targetMul;
  int? targetCand;
}

class TokenModelforIntegerMultiplication extends StatefulWidget {
  const TokenModelforIntegerMultiplication({super.key});

  @override
  State<TokenModelforIntegerMultiplication> createState() => _TokenModelforIntegerMultiplicationState();
}

class _TokenModelforIntegerMultiplicationState extends State<TokenModelforIntegerMultiplication> with TickerProviderStateMixin {
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
  double _zoom = 0.8;
  double _panX = -40;
  double _panY = -30;
  double _baseZoom = 0.8;
  Offset _basePan = Offset.zero;

  // Simulation State
  SimState sim = SimState();
  bool _toolDragging = false;
  int? _toolType;
  Offset _dragOffset = Offset.zero;
  double _mouseX = 0;
  double _mouseY = 0;

  // Audio Engine
  final AudioPlayer _player = AudioPlayer();
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

    // Main Game Loop for animations
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
    _player.dispose();
    super.dispose();
  }

  void _tick() {
    setState(() {
      if (sim.animState == 'adding' || sim.animState == 'removing') {
        double framesPerCycle = sim.animState == 'removing' ? 100 : 60;
        sim.frame++;
        
        if (sim.frame > framesPerCycle) {
          sim.frame = 0;
          sim.cyclesDone++;
          
          if (sim.animState == 'adding') {
            for (int i = 0; i < sim.mand!.abs(); i++) {
              sim.matTokens.add(Token(isPos: sim.mand! > 0, id: Random().nextDouble()));
            }
          } else if (sim.animState == 'removing') {
            for (int i = 0; i < sim.mand!.abs(); i++) {
              sim.matTokens.add(Token(isPos: sim.mand! < 0, id: Random().nextDouble()));
            }
          }

          if (sim.cyclesDone >= sim.mult!.abs()) {
            sim.animState = 'done';
            _playSound('success');
            if (_scenario != 5) _advanceStep();
            if (_scenario == 5 && sim.s5Phase == 2 && _step == 1) _advanceStep();
          } else {
            _playSound('pop');
          }
        }
      }
    });
  }

  void _playSound(String type) async {
    String url;
    switch (type) {
      case 'enter': url = 'audio/class7/mixkit_2568.mp3'; break;
      case 'pop': url = 'audio/class7/mixkit_1124.mp3'; break;
      case 'success': url = 'audio/class7/mixkit_2015.mp3'; break;
      case 'error': url = 'audio/class7/mixkit_946.mp3'; break;
      case 'snap': case 'tick': url = 'audio/class7/mixkit_1120.mp3'; break;
      case 'weld': url = 'audio/class7/mixkit_2574.mp3'; break;
      default: return;
    }
    try { await _player.play(AssetSource(url), volume: 0.5); } catch (e) { debugPrint("Audio Error: $e"); }
  }

  String t(String key) => _translations[_lang]?[key] ?? _translations['en']![key] ?? key;

  void _toggleLanguage() {
    _playSound('pop');
    setState(() {
      if (_lang == 'en') _lang = 'hi'; else _lang = 'en';
    });
  }

  void _handleReset() {
    _playSound('pop');
    setState(() => _showCurtain = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() { _lang = 'en'; _loadScenario(1); });
      }
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _toolDragging = false;
      _toolType = null;
      _zoom = 0.8;
      _panX = -40;
      _panY = -30;
      _showSuccessPopup = false;

      sim = SimState();
      if (_scenario == 1) { sim.targetMul = 4; sim.targetCand = 2; }
      if (_scenario == 2) { sim.targetMul = 4; sim.targetCand = -2; }
      if (_scenario == 3) { sim.targetMul = -4; sim.targetCand = 2; }
      if (_scenario == 4) { sim.targetMul = -4; sim.targetCand = -2; }
      if (_scenario == 5) { sim.targetMul = 3; sim.targetCand = -5; }
    });
    _scrollToActiveStep();
  }

  void _machineReset() {
    setState(() {
      sim.mult = null;
      sim.mand = null;
      sim.animState = 'idle';
      sim.cyclesDone = 0;
      sim.frame = 0;
      sim.matTokens.clear();
      
      if (_scenario == 5 && _step == 1 && sim.s5Phase == 1) {
        sim.s5Phase = 2;
        sim.targetMul = -5;
        sim.targetCand = 3;
      }
    });
    _playSound('error');
    _scrollToActiveStep();
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    int totalSteps = (_scenario == 4 || _scenario == 5) ? 3 : 4;
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

  void _handleTapDown(TapDownDetails details, Size size) {
    Offset pt = _screenToWorld(details.localPosition, size);

    // Explicit Reset Button HitTest on Machine
    if (Rect.fromLTWH(240, -230, 80, 26).contains(pt)) {
      _machineReset();
      return;
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (sim.animState == 'done' || sim.animState == 'adding' || sim.animState == 'removing') return;

    List<int> availableTiles = [];
    if(_scenario == 1) availableTiles = [4, 2];
    else if(_scenario == 2) availableTiles = [4, -2];
    else if(_scenario == 3) availableTiles = [-4, 2];
    else if(_scenario == 4) availableTiles = [-4, -2];
    else if(_scenario == 5) availableTiles = [3, -5];

    double rackX = -480; double rackY = -150;
    for (int i=0; i<availableTiles.length; i++) {
      double tx = rackX + 40;
      double ty = rackY + 80 + i * 60;
      int val = availableTiles[i];
      
      if (sim.mult != val && sim.mand != val) {
        if ((pt - Offset(tx, ty)).distance < 40) {
          setState(() {
            _toolDragging = true;
            _toolType = val;
            _dragOffset = Offset(tx, ty) - pt;
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
      if (!_toolDragging) {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.4, 2.0);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_toolDragging && _toolType != null) {
      setState(() {
        Offset dropPt = Offset(_mouseX + _dragOffset.dx, _mouseY + _dragOffset.dy);
        double sMulX = -120; double sCandX = 120; double sY = -120;
        
        if ((dropPt - Offset(sMulX, sY)).distance < 60 && sim.mult == null) {
          sim.mult = _toolType; _playSound('snap'); _evaluateStepConditions();
        } else if ((dropPt - Offset(sCandX, sY)).distance < 60 && sim.mand == null) {
          sim.mand = _toolType; _playSound('snap'); _evaluateStepConditions();
        } else {
          _playSound('error');
        }

        if (_scenario == 4 && _step == 0 && sim.mult == -4 && sim.mand == -2) _advanceStep();
        
        _toolDragging = false;
        _toolType = null;
      });
    }
  }

  void _evaluateStepConditions() {
    if (_scenario == 1) {
      if (_step == 0 && sim.mult == 4) _advanceStep();
      if (_step == 1 && sim.mand == 2) _advanceStep();
    } else if (_scenario == 2) {
      if (_step == 0 && sim.mult == 4) _advanceStep();
      if (_step == 1 && sim.mand == -2) _advanceStep();
    } else if (_scenario == 3) {
      if (_step == 0 && sim.mult == -4) _advanceStep();
      if (_step == 1 && sim.mand == 2) _advanceStep();
    } else if (_scenario == 4) {
      if (_step == 0 && sim.mult == -4 && sim.mand == -2) _advanceStep();
    }
  }

  void _activateMachine() {
    if (sim.mult == null || sim.mand == null || sim.animState != 'idle') return;
    
    if (_scenario == 5) {
      if (sim.s5Phase == 1 && (sim.mult != 3 || sim.mand != -5)) { _playSound('error'); return; }
      if (sim.s5Phase == 2 && (sim.mult != -5 || sim.mand != 3)) { _playSound('error'); return; }
    } else {
      if (sim.mult != sim.targetMul || sim.mand != sim.targetCand) { _playSound('error'); return; }
    }

    setState(() {
      sim.animState = sim.mult! > 0 ? 'adding' : 'removing';
      sim.cyclesDone = 0;
      sim.frame = 0;
    });
    _playSound('weld');
    if (_scenario == 5 && sim.s5Phase == 1 && _step == 0) _advanceStep(); 
  }

  Widget _buildOverlayButton(String label, double worldX, double worldY, Color color, VoidCallback onTap, {IconData? icon}) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    double screenX = sw / 2 + _panX + worldX * _zoom;
    double screenY = sh / 2 + _panY + worldY * _zoom;

    return Positioned(
      left: screenX - 100, 
      top: screenY - 25,
      child: Transform.scale(
        scale: _zoom.clamp(0.8, 1.2),
        child: ElevatedButton.icon(
          onPressed: () { _playSound('pop'); onTap(); },
          icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 10, shadowColor: color.withOpacity(0.6),
            side: BorderSide(color: Colors.white.withOpacity(0.5), width: 2)
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);

    int totalSteps = (_scenario == 4 || _scenario == 5) ? 3 : 4;

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.settings_input_component, color: Colors.indigoAccent),
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleLanguage,
                      icon: const Icon(Icons.language, size: 16),
                      label: Text(_lang.toUpperCase()),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, side: BorderSide(color: border)),
                    )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleReset,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(t('resetBtn')),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.2), foregroundColor: Colors.redAccent, side: BorderSide(color: Colors.redAccent.withOpacity(0.5))),
                    )
                  )
                ]
              )
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
                          if (val != null) {
                            _playSound('tick');
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
                    decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.my_location, color: Colors.pinkAccent, size: 18), const SizedBox(width: 8), Text(t('learnLbl'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 8),
                        Text(t('s${_scenario}_obj'), style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Steps Rendering
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
                          isPast ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                                 : Container(width: 24, height: 24, decoration: BoxDecoration(color: isCurrent ? Colors.indigoAccent : Colors.grey, shape: BoxShape.circle), alignment: Alignment.center, child: Text('${i+1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${t('stepLabel')} ${i+1}", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                _buildRichText(t('s${_scenario}_step${i+1}_task'), textPrimary),
                                if (isPast) ...[
                                  const SizedBox(height: 8),
                                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: _buildRichText(t('s${_scenario}_step${i+1}_out'), Colors.green.shade700))
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                  // Final Summary / Discovery Model Box
                  if (_step == totalSteps)
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
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(child: Text(_scenario < 5 ? t('infoNextScen') : t('infoLabDone'), style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold)))
                              ]
                            )
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
            // Footer stretching entire width of sidebar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF0F172A),
              child: const Center(
                child: Text("© ZeroScienceLab - Fall in love with math and Science", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.3;
    if (sidebarWidth < 300) sidebarWidth = 300;
    int totalSteps = (_scenario == 4 || _scenario == 5) ? 3 : 4;

    bool showActivate = false;
    bool showFinalize = false;

    if (_scenario == 1 || _scenario == 2 || _scenario == 3) {
      if (_step == 2 && sim.mult != null && sim.mand != null && sim.animState == 'idle') showActivate = true;
      if (_step == 3 && sim.animState == 'done') showFinalize = true;
    } else if (_scenario == 4) {
      if (_step == 1 && sim.mult != null && sim.mand != null && sim.animState == 'idle') showActivate = true;
      if (_step == 2 && sim.animState == 'done') showFinalize = true;
    } else if (_scenario == 5) {
      if (sim.s5Phase == 1 && _step == 0 && sim.mult == 3 && sim.mand == -5 && sim.animState == 'idle') showActivate = true;
      if (sim.s5Phase == 2 && _step == 1 && sim.mult == -5 && sim.mand == 3 && sim.animState == 'idle') showActivate = true;
      if (sim.s5Phase == 2 && _step == 2 && sim.animState == 'done') showFinalize = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); },
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
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size.infinite,
                            painter: MachinePainter(
                              sim: sim, panX: _panX, panY: _panY, zoom: _zoom,
                              toolDragging: _toolDragging, toolType: _toolType, dragOffset: _dragOffset, mouseX: _mouseX, mouseY: _mouseY,
                              scenario: _scenario, step: _step, t: t, screenSize: constraints.biggest
                            ),
                          ),
                          // Dynamic UI Button Overlays
                          if (showActivate)
                            _buildOverlayButton(t('activateBtn'), 0, 10, Colors.amber, _activateMachine, icon: Icons.power_settings_new),
                          if (showFinalize)
                            _buildOverlayButton(t('finalizeBtn'), 0, 270, const Color(0xFF10B981), _checkScenarioSuccess, icon: Icons.check),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),

            // HUD Overlays
            if (_step < totalSteps)
              Positioned(
                bottom: 40, left: _isSidebarOpen ? sidebarWidth + 40 : 40, right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20), border: const Border(top: BorderSide(color: Colors.indigoAccent, width: 4))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.indigoAccent), const SizedBox(width: 12),
                          Flexible(child: Text(t('s${_scenario}_hud${_step + 1}'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center))
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth, top: 0, bottom: 0, width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            // MENU TOGGLE
            Positioned(
              top: 16, left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu), color: Colors.orangeAccent, iconSize: 28,
                onPressed: () { HapticFeedback.lightImpact(); _playSound('tick'); setState(() => _isSidebarOpen = !_isSidebarOpen); },
                style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.8)))),
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
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24)),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 80, height: 80, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 20)]), child: const Icon(Icons.flag, color: Colors.white, size: 40)),
                                const SizedBox(height: 24),
                                Text(t('labCompleted'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                Text(t('finalDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () { _playSound('pop'); setState(() { _showSuccessPopup = false; _handleReset(); }); },
                                  icon: const Icon(Icons.refresh), label: Text(t('resetBtn')),
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                                )
                              ],
                            ),
                            Positioned(top: -10, right: -10, child: IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () { _playSound('pop'); setState(() => _showSuccessPopup = false); }))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // CURTAIN
            AnimatedSlide(
              offset: _showCurtain ? Offset.zero : const Offset(0, -1), duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutCubic,
              child: Container(
                width: double.infinity, height: double.infinity, color: const Color(0xFF020617), padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 120, height: 120, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]), child: const Icon(Icons.settings_input_component, size: 80, color: Colors.indigoAccent)),
                        Text(t('appTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 16),
                        Text(t('appSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () { _playSound('pop'); setState(() => _showCurtain = false); },
                          icon: const Icon(Icons.play_circle_fill, size: 28), label: Text(t('enterLab')),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, elevation: 10, shadowColor: Colors.indigoAccent.withOpacity(0.5), textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
                        )
                      ]
                    ),
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class MachinePainter extends CustomPainter {
  final SimState sim;
  final double panX;
  final double panY;
  final double zoom;
  final bool toolDragging;
  final int? toolType;
  final Offset dragOffset;
  final double mouseX;
  final double mouseY;
  final int scenario;
  final int step;
  final Function(String) t;
  final Size screenSize;

  MachinePainter({
    required this.sim, required this.panX, required this.panY, required this.zoom,
    required this.toolDragging, required this.toolType, required this.dragOffset, required this.mouseX, required this.mouseY,
    required this.scenario, required this.step, required this.t, required this.screenSize
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Factory Environment Background Grid
    Paint gridPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1;
    for (double i = -3000; i < 3000; i += 40) {
      canvas.drawLine(Offset(i, -3000), Offset(i, 3000), gridPaint);
      canvas.drawLine(Offset(-3000, i), Offset(3000, i), gridPaint);
    }

    _drawMachineBase(canvas);
    _drawCounters(canvas);
    _drawSlotsArea(canvas);
    _drawWorkspaceMat(canvas);
    _drawArmAnimation(canvas);
    _drawToolbox(canvas);

    if (sim.animState == 'done') {
      _drawFinalSummary(canvas);
      _drawDiscoveryBubble(canvas);
    }

    canvas.restore();
  }

  void _drawMachineBase(Canvas canvas) {
    _drawRoundedRect(canvas, -360, -260, 720, 240, 16, fill: const Color(0xff334155), stroke: const Color(0xff475569), strokeW: 4);
    _drawRoundedRect(canvas, -340, -240, 680, 200, 12, fill: const Color(0xff1e293b), stroke: const Color(0xff0f172a), strokeW: 2);
    
    // Explicit Reset button on machine
    _drawRoundedRect(canvas, 240, -230, 80, 26, 4, fill: const Color(0xff7f1d1d), stroke: const Color(0xffef4444), strokeW: 2);
    _drawText(canvas, "RESET", const Offset(280, -217), 12, const Color(0xfffca5a5), weight: FontWeight.bold);
  }

  void _drawCounters(Canvas canvas) {
    _drawRoundedRect(canvas, -330, -230, 160, 50, 6, fill: const Color(0xff0f172a), stroke: Colors.blueAccent, strokeW: 2);
    int pos = sim.matTokens.where((t) => t.isPos).length;
    int neg = sim.matTokens.where((t) => !t.isPos).length;
    int total = pos - neg;
    _drawText(canvas, "${t('emptyWs')}: $total", const Offset(-250, -205), 16, Colors.lightBlueAccent, weight: FontWeight.bold);

    _drawRoundedRect(canvas, -80, -230, 160, 30, 6, fill: const Color(0xff0f172a), stroke: Colors.blueAccent, strokeW: 2);
    int dCyc = sim.cyclesDone;
    if ((sim.animState == 'adding' || sim.animState == 'removing') && sim.frame > (sim.animState == 'removing'? 50:30)) dCyc++;
    int totalCyc = sim.mult?.abs() ?? 0;
    _drawText(canvas, "${t('cycles')} $dCyc / $totalCyc", const Offset(0, -215), 14, Colors.lightBlueAccent, weight: FontWeight.bold);
  }

  void _drawSlotsArea(Canvas canvas) {
    double sMulX = -120; double sCandX = 120; double sY = -120;
    Color tColor = Colors.white;
    Color slotBg = const Color(0xff1e293b);
    Color multCol = const Color(0xff64748b);
    
    if (sim.mult != null) multCol = sim.mult! > 0 ? Colors.green : Colors.red;

    _drawRoundedRect(canvas, sMulX - 40, sY - 40, 80, 80, 12, fill: slotBg, stroke: multCol, strokeW: 4);
    _drawText(canvas, "Multiplier", Offset(sMulX, sY - 55), 12, tColor, weight: FontWeight.bold);
    
    if (sim.mult != null) {
      _drawNumberTile(canvas, sMulX, sY, sim.mult!);
      _drawRoundedRect(canvas, sMulX - 40, sY + 45, 80, 25, 4, fill: multCol);
      _drawText(canvas, sim.mult! > 0 ? "ACTION: ADD" : "ACTION: REMOVE", Offset(sMulX, sY + 58), 10, Colors.white, weight: FontWeight.bold);
    }

    _drawText(canvas, "×", Offset(0, sY), 36, tColor, weight: FontWeight.bold);

    _drawRoundedRect(canvas, sCandX - 40, sY - 40, 80, 80, 12, fill: slotBg, stroke: Colors.blueAccent, strokeW: 4);
    _drawText(canvas, "Multiplicand", Offset(sCandX, sY - 55), 12, tColor, weight: FontWeight.bold);
    
    if (sim.mand != null) {
      _drawNumberTile(canvas, sCandX, sY, sim.mand!);
      _drawRoundedRect(canvas, sCandX + 50, sY - 40, 60, 100, 8, fill: const Color(0xff334155));
      _drawText(canvas, "Preview", Offset(sCandX + 80, sY - 45), 10, Colors.white70, weight: FontWeight.bold);
      
      int cnt = sim.mand!.abs();
      for (int i = 0; i < cnt; i++) {
        _drawToken(canvas, sCandX + 80, sY - 10 + i * 20, sim.mand! > 0, scale: 0.5);
      }
    }
  }

  void _drawWorkspaceMat(Canvas canvas) {
    double matW = 500; double matH = 200; double matX = -250; double matY = 40;
    
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(matX, matY+10, matW, matH), const Radius.circular(16)), Paint()..color=Colors.black38..maskFilter=const MaskFilter.blur(BlurStyle.normal, 10));
    _drawRoundedRect(canvas, matX, matY, matW, matH, 16, fill: const Color(0xff475569), stroke: const Color(0xff334155), strokeW: 4);
    _drawRoundedRect(canvas, matX+10, matY+10, matW-20, matH-20, 12, fill: const Color(0xffcbd5e1));

    int pos = sim.matTokens.where((t) => t.isPos).length;
    int neg = sim.matTokens.where((t) => !t.isPos).length;
    int total = pos - neg;
    _drawRoundedRect(canvas, matX + matW/2 - 60, matY - 40, 120, 36, 8, fill: const Color(0xff0f172a), stroke: Colors.blueAccent, strokeW: 2);
    String vStr = total > 0 ? "+$total" : total.toString();
    _drawText(canvas, vStr, Offset(matX + matW/2, matY - 22), 24, Colors.lightBlueAccent, weight: FontWeight.bold);

    int pIdx = 0, nIdx = 0;
    for (var t in sim.matTokens) {
      double c = (t.isPos ? pIdx : nIdx) % 10.0;
      double r = ((t.isPos ? pIdx : nIdx) / 10).floorToDouble();
      double px = matX + 45 + c * 45;
      double py = (t.isPos ? matY + 45 : matY + 130) + r * 45;
      _drawToken(canvas, px, py, t.isPos);
      if (t.isPos) pIdx++; else nIdx++;
    }
  }

  void _drawArmAnimation(Canvas canvas) {
    Color armGlow = const Color(0xff475569);
    if (sim.mult != null) {
      if (sim.mult! > 0) armGlow = Colors.greenAccent;
      if (sim.mult! < 0) armGlow = Colors.redAccent;
    }

    double matY = 40;
    double framesPerCycle = sim.animState == 'removing' ? 100 : 60;

    if (sim.animState == 'idle' || sim.animState == 'done') {
      canvas.save();
      canvas.translate(0, matY - 40);
      _drawLine(canvas, 0, -60, 0, 0, const Color(0xff94a3b8), 12);
      _drawRoundedRect(canvas, -25, -10, 50, 20, 4, fill: armGlow, stroke: const Color(0xff0f172a), strokeW: 2);
      canvas.restore();
    } else {
      double prog = sim.frame / framesPerCycle;
      double targetX = 0; double targetY = matY + 100;
      double armX = 250; double armY = -120;
      
      canvas.save();
      _drawLine(canvas, -400, -20, 400, -20, const Color(0xff64748b), 16);
      
      double cX = targetX; double cY = targetY;

      if (sim.animState == 'adding') {
        if(prog < 0.3) { cX = armX + (prog/0.3)*(targetX-armX); cY = armY + (prog/0.3)*(targetY-armY); }
        else if(prog > 0.7) { cX = targetX + ((prog-0.7)/0.3)*(armX-targetX); cY = targetY + ((prog-0.7)/0.3)*(armY-targetY); }

        canvas.translate(cX, cY - 60);
        _drawLine(canvas, 0, -200, 0, 0, const Color(0xff94a3b8), 12);
        _drawRoundedRect(canvas, -20, -10, 40, 20, 4, fill: armGlow, stroke: const Color(0xff334155), strokeW: 2);
        
        int pCount = sim.mand!.abs();
        if (prog < 0.5) {
          for(int i=0; i<pCount; i++) _drawToken(canvas, (i%2==0?-15:15), 15 + i*10.0, sim.mand! > 0);
        } else {
          for(int i=0; i<pCount; i++) {
            double dropY = 15 + i*10 + (prog-0.5)*200;
            _drawToken(canvas, (i%2==0?-15:15), dropY, sim.mand! > 0);
          }
        }
      } else if (sim.animState == 'removing') {
        cX = targetX;
        if(prog < 0.2) cY = armY + (prog/0.2)*(targetY-armY);
        else if(prog > 0.8) cY = targetY + ((prog-0.8)/0.2)*(armX-targetX);

        canvas.translate(cX, cY - 60);
        _drawLine(canvas, 0, -200, 0, 0, const Color(0xff94a3b8), 12);
        _drawRoundedRect(canvas, -25, -10, 50, 30, 4, fill: armGlow, stroke: const Color(0xff991b1b), strokeW: 2);
        
        int pCount = sim.mand!.abs();
        if (prog < 0.3) {
          for(int i=0; i<pCount; i++) {
            double dropY = 30 + (prog/0.3)*100;
            _drawToken(canvas, -20, dropY + i*20, true);
            _drawToken(canvas, 20, dropY + i*20, false);
          }
        } else if (prog > 0.4 && prog < 0.7) {
          double vacProg = (prog-0.4)/0.3;
          for(int i=0; i<pCount; i++) {
            double vacY = 130 - vacProg*100;
            _drawToken(canvas, 0, vacY + i*20, sim.mand! > 0);
          }
        } else if (prog >= 0.3 && prog <= 0.4) {
          for(int i=0; i<pCount; i++) {
            _drawToken(canvas, -20, 130 + i*20.0, true);
            _drawToken(canvas, 20, 130 + i*20.0, false);
          }
        } else if (prog >= 0.7) {
          for(int i=0; i<pCount; i++) {
            _drawToken(canvas, 0, 20 + i*20.0, sim.mand! > 0);
          }
        }

        if (prog >= 0.4) {
          bool leftBehind = !(sim.mand! > 0);
          for(int i=0; i<pCount; i++) {
            _drawToken(canvas, leftBehind ? -20 : 20, 130 + i*20.0, leftBehind);
          }
        }
      }
      canvas.restore();
    }
  }

  void _drawToolbox(Canvas canvas) {
    double rackX = -480; double rackY = -150;
    _drawRoundedRect(canvas, rackX, rackY, 80, 400, 12, fill: const Color(0xff1e293b), stroke: const Color(0xff334155), strokeW: 4);
    _drawText(canvas, "TOOLBOX", Offset(rackX + 40, rackY + 30), 12, Colors.white, weight: FontWeight.bold);

    // Only show necessary tools based on the current scenario context
    List<int> availableTiles = [];
    if(scenario == 1) availableTiles = [4, 2];
    else if(scenario == 2) availableTiles = [4, -2];
    else if(scenario == 3) availableTiles = [-4, 2];
    else if(scenario == 4) availableTiles = [-4, -2];
    else if(scenario == 5) availableTiles = [3, -5];

    for (int i=0; i<availableTiles.length; i++) {
      int val = availableTiles[i];
      double ty = rackY + 80 + i * 60;
      double tx = rackX + 40;

      if (sim.mult == val || sim.mand == val) {
        canvas.saveLayer(Rect.fromLTWH(tx-30, ty-30, 60, 60), Paint()..color = Colors.white.withOpacity(0.3));
        _drawNumberTile(canvas, tx, ty, val);
        canvas.restore();
      } else {
        if (toolDragging && toolType == val) {
          _drawNumberTile(canvas, mouseX + dragOffset.dx, mouseY + dragOffset.dy, val, hover: true);
        } else {
          _drawNumberTile(canvas, tx, ty, val);
        }
      }
    }
  }

  void _drawFinalSummary(Canvas canvas) {
    _drawRoundedRect(canvas, -320, -230, 640, 120, 12, fill: const Color(0xf20f172a), stroke: Colors.blueAccent, strokeW: 4);
    int finalVal = sim.mult! * sim.mand!;
    String m1 = sim.mult! < 0 ? "(${sim.mult})" : "${sim.mult}";
    String m2 = sim.mand! < 0 ? "(${sim.mand})" : "${sim.mand}";
    String eq = "$m1 × $m2 = ${finalVal > 0 ? '+' : ''}$finalVal";
    _drawText(canvas, eq, const Offset(0, -170), 36, Colors.white, weight: FontWeight.bold);
  }

  void _drawDiscoveryBubble(Canvas canvas) {
    int totalSteps = (scenario == 4 || scenario == 5) ? 3 : 4;
    if (step >= totalSteps - 1 || (scenario == 5 && step == 2)) {
      _drawRoundedRect(canvas, 260, 40, 440, 200, 16, fill: const Color(0xff1e293b), stroke: Colors.blueAccent, strokeW: 4);
      double bY = 75;
      for (String keyExt in ['L1', 'L2', 'L3', 'L4', 'L5']) {
        String key = 's${scenario}_bubble_$keyExt';
        String txt = t(key);
        if(txt != key && txt.isNotEmpty) {
          _drawText(canvas, txt, Offset(480, bY), 16, Colors.white, weight: FontWeight.bold);
          bY += 26;
        }
      }
    }
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, {Color? fill, Color? stroke, double strokeW = 1}) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != null) canvas.drawRRect(rrect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
  }

  void _drawLine(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width) {
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round);
  }

  void _drawText(Canvas canvas, String text, Offset center, double fontSize, Color color, {FontWeight weight = FontWeight.normal}) {
    final textSpan = TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight, fontFamily: 'Plus Jakarta Sans'));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawToken(Canvas canvas, double cx, double cy, bool isPos, {double scale = 1}) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale, scale);
    
    Color fill = isPos ? const Color(0xff4ade80) : const Color(0xfff87171);
    Color stroke = const Color(0xff0f172a);
    Color shadow = isPos ? const Color(0xff166534) : const Color(0xff991b1b);

    canvas.drawCircle(const Offset(0, 4), 18, Paint()..color = shadow);
    canvas.drawCircle(const Offset(0, 0), 18, Paint()..color = fill);
    canvas.drawCircle(const Offset(0, 0), 18, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(const Offset(0, 0), 12, Paint()..color = shadow..style = PaintingStyle.stroke..strokeWidth = 1.5);
    
    _drawText(canvas, isPos ? "+" : "-", const Offset(0, 0), 24, stroke, weight: FontWeight.bold);
    
    canvas.restore();
  }

  void _drawNumberTile(Canvas canvas, double cx, double cy, int val, {bool hover = false}) {
    canvas.save();
    canvas.translate(cx, cy);
    if (hover) canvas.scale(1.1, 1.1);

    bool isPos = val > 0;
    Color fill = isPos ? const Color(0xffdcfce7) : const Color(0xfffee2e2);
    Color stroke = isPos ? const Color(0xff22c55e) : const Color(0xffef4444);

    _drawRoundedRect(canvas, -25, -20, 50, 48, 6, fill: stroke, stroke: const Color(0xff0f172a), strokeW: 2);
    _drawRoundedRect(canvas, -25, -25, 50, 48, 6, fill: fill, stroke: const Color(0xff0f172a), strokeW: 2);
    
    _drawText(canvas, val.toString(), const Offset(0, -1), 22, const Color(0xff0f172a), weight: FontWeight.bold);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MachinePainter oldDelegate) => true;
}

const Map<String, Map<String, String>> _translations = {
  'en': {
    'appTitle': "The Token Machine: Integer Multiplication", 'appSubtitle': "Class 7 • OPERATIONS WITH INTEGERS", 'enterLab': "Enter Lab",
    'settings': "Settings", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'boardFontSize': "Text Size", 
    'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done", 
    'learnLbl': "What We Learn:", 'closeBtn': "Close", 'summaryTitle': "Discovery Made!",
    'resetBtn': "Reset Lab", 'finishLab': "Finish Lab", 'nextScenario': "Next Scenario",
    'labCompleted': "Lab Completed!", 'finalDesc': "You have successfully modeled integer multiplication! You visualized how repeated addition and removal of groups correctly prove the rules of positive and negative multiplication.",
    
    'infoNextScen': "Scenario completed! Please select the next scenario from the dropdown above.", 
    'infoLabDone': "Lab Completed! You have mastered Integer Multiplication.",

    'toolbox': "Number Tiles", 'workspaceMat': "Workspace Mat", 'netValue': "Value:", 'tokens': "Tokens:",
    'multiplier': "Multiplier\n(How many times)", 'multiplicand': "Multiplicand\n(What to act on)",
    'activateBtn': "ACTIVATE", 'finalizeBtn': "Finalize", 'resetBtnApp': "RESET MACHINE", 'actionAdd': "ACTION: ADD", 'actionRem': "ACTION: REMOVE",
    'emptyWs': "Workspace Value", 'previewPanel': "Preview\nPanel", 'machineCounter': "Machine Counter", 'digiCount': "Digital\nCounter",
    'cycles': "CYCLES:", 'target': "Target:", 'reset': "RESET", 'summary': "Summary",
    
    's1_title': "1. The Giver (Pos × Pos)", 's1_obj': "To understand that a positive multiplier means 'adding' groups of positive tokens. We will solve 4 × 2.",
    's1_hud1': "Solve 4 × 2. DRAG the number tile '4' to the Multiplier slot.", 's1_step1_task': "<b>Action:</b> The workspace is empty (value 0). Look at the 'Token Machine'. The first input slot is the 'Multiplier' (How many times to act). The second is the 'Multiplicand' (What to act on). DRAG the number tile '4' to the Multiplier slot.", 's1_step1_out': "<b>Observation:</b> The number '4' locks into the Multiplier slot. The machine's action arm glows green, indicating an 'ADD' operation.",
    's1_hud2': "DRAG the number tile '2' to the Multiplicand slot.", 's1_step2_task': "<b>Action:</b> DRAG the number tile '2' to the Multiplicand slot. This tells the machine we are interested in groups of 2 positive tokens.", 's1_step2_out': "<b>Observation:</b> The number '2' locks into the Multiplicand slot. A preview appears showing two green tokens.",
    's1_hud3': "CLICK the 'ACTIVATE' button.", 's1_step3_task': "<b>Action:</b> CLICK the large 'ACTIVATE' button on the machine.", 's1_step3_out': "<b>Observation:</b> The machine's arm picks up a group of 2 green tokens and drops them into the workspace. A counter on the machine flashes '1'. The arm repeats this three more times. The counter increments to '4'. The workspace now contains 8 green tokens.",
    's1_hud4': "Observe the final result.", 's1_step4_task': "<b>Action:</b> Observe the final result. The counter on the workspace shows the total value. Click 'Finalize'.", 's1_step4_out': "<b>Learning:</b> A large digital display shows '+8'. 4 × 2 = 8.",
    's1_sum': "<b>Operation Complete!</b> 4 × 2 = 8.",

    's2_title': "2. The Debt Collector (Pos × Neg)", 's2_obj': "To understand that a positive multiplier can also mean 'adding' groups of negative tokens. We will solve 4 × (-2).",
    's2_hud1': "Solve 4 × (-2). CLICK 'RESET' and DRAG '4' to Multiplier.", 's2_step1_task': "<b>Action:</b> CLICK the 'RESET' button to clear the workspace. DRAG the number tile '4' to the Multiplier slot.", 's2_step1_out': "<b>Observation:</b> The workspace is empty. The number '4' is in the Multiplier slot, and the machine's arm glows green ('ADD' operation).",
    's2_hud2': "DRAG the number tile '-2' to the Multiplicand slot.", 's2_step2_task': "<b>Action:</b> DRAG the number tile '-2' to the Multiplicand slot. This tells the machine to work with groups of 2 negative tokens.", 's2_step2_out': "<b>Observation:</b> The number '-2' locks into the Multiplicand slot. A preview appears showing two red tokens.",
    's2_hud3': "CLICK the 'ACTIVATE' button.", 's2_step3_task': "<b>Action:</b> CLICK the 'ACTIVATE' button.", 's2_step3_out': "<b>Observation:</b> The machine adds 4 groups of 2 negative tokens to the workspace. This action repeats 4 times. The workspace now contains 8 red tokens.",
    's2_hud4': "Observe the final result.", 's2_step4_task': "<b>Action:</b> Observe the final result on the workspace counter. Click 'Finalize'.", 's2_step4_out': "<b>Learning:</b> The workspace counter displays '-8'. 4 × (-2) = -8.",
    's2_sum': "<b>Operation Complete!</b> 4 × (-2) = -8.",

    's3_title': "3. The Repo Man (Neg × Pos)", 's3_obj': "To understand that a negative multiplier means 'removing' groups and to see how 'zero pairs' are used.",
    's3_hud1': "Solve (-4) × 2. DRAG the number tile '-4' to the Multiplier slot.", 's3_step1_task': "<b>Action:</b> The workspace is empty. DRAG the number tile '-4' to the Multiplier slot.", 's3_step1_out': "<b>Observation:</b> The number '-4' locks into the Multiplier slot. The machine's action arm now glows red, indicating a 'REMOVE' operation.",
    's3_hud2': "DRAG the number tile '2' to the Multiplicand slot.", 's3_step2_task': "<b>Action:</b> DRAG the number tile '2' to the Multiplicand slot. The machine is now set to 'remove 4 groups of 2 positives'.", 's3_step2_out': "<b>Observation:</b> The number '2' locks into the slot, showing a preview of two green tokens.",
    's3_hud3': "CLICK 'ACTIVATE'. Observe the use of zero pairs.", 's3_step3_task': "<b>Action:</b> CLICK the 'ACTIVATE' button. Observe carefully what happens when the machine tries to remove tokens from an empty workspace.", 's3_step3_out': "<b>Observation:</b> The machine attempts to remove 2 green tokens, finds none, automatically adds 2 zero pairs, and then vacuums up the 2 green tokens. This repeats 4 times.",
    's3_hud4': "Observe the final result.", 's3_step4_task': "<b>Action:</b> Observe the final result. Click 'Finalize'.", 's3_step4_out': "<b>Learning:</b> Removing 4 groups of +2 leaves 8 negative tokens.",
    's3_sum': "<b>Operation Complete!</b> (-4) × 2 = -8. A negative multiplier REMOVES groups. Zero pairs are used when the mat is empty.",

    's4_title': "4. The Debt Forgiver (Neg × Neg)", 's4_obj': "Apply the 'removal' rule to solve (-4) × (-2) yourself.",
    's4_hud1': "CLICK 'RESET'. Set up the Token Machine to solve (-4) × (-2).", 's4_step1_task': "<b>Action:</b> CLICK 'RESET' on the machine. Set up the Token Machine to solve the problem `(-4) × (-2)`. DRAG the correct number tiles to the Multiplier and Multiplicand slots.", 's4_step1_out': "<b>Observation:</b> The user correctly places '-4' and '-2'. The machine arm glows red.",
    's4_hud2': "Predict, then CLICK 'ACTIVATE'.", 's4_step2_task': "<b>Action:</b> Before you activate, predict what will happen. The machine needs to REMOVE 4 groups of 2 RED tokens. What will be left? CLICK the 'ACTIVATE' button to check.", 's4_step2_out': "<b>Observation:</b> The machine drops zero pairs, then vacuums up the 2 red tokens. This repeats 4 times, leaving 8 green tokens.",
    's4_hud3': "What is the final value?", 's4_step3_task': "<b>Action:</b> What is the final value in the workspace? Click 'Finalize'.", 's4_step3_out': "<b>Learning:</b> Removing negative tokens (debts) leaves a positive value.",
    's4_sum': "<b>Correct!</b> Removing a debt is like gaining money. (-4) × (-2) = 8.",

    's5_title': "5. The Switcheroo", 's5_obj': "To discover that multiplication of integers is commutative by solving two different problems.",
    's5_hud1': "First, set up and solve the problem 3 × (-5).", 's5_step1_task': "<b>Action:</b> First, set up and solve the problem `3 × (-5)`. DRAG the tiles, CLICK 'ACTIVATE', and note the result.", 's5_step1_out': "<b>Observation:</b> The user sets the multiplier to '3' (green arm) and multiplicand to '-5'. The machine adds 3 groups of 5 red tokens. The final result is -15.",
    's5_hud2': "CLICK 'RESET'. Now, set up and solve (-5) × 3.", 's5_step2_task': "<b>Action:</b> CLICK 'RESET' on the machine. Now, set up and solve the reverse problem: `(-5) × 3`. DRAG the tiles, CLICK 'ACTIVATE', and note the result.", 's5_step2_out': "<b>Observation:</b> The user sets the multiplier to '-5' (red arm) and multiplicand to '3'. The machine removes 5 groups of 3 green tokens using zero pairs. The final result is -15.",
    's5_hud3': "Compare the results. Click Finalize.", 's5_step3_task': "<b>Action:</b> Compare the results from Step 1 and Step 2. What do you notice? Click 'Finalize'.", 's5_step3_out': "<b>Learning:</b> Both `3 × (-5)` and `(-5) × 3` equal -15.",
    's5_sum': "<b>The result is the same!</b> The order in which you multiply integers does not change the answer. This is the Commutative Property.",
    
    's1_bubble_L1': "Summary: A positive multiplier", 's1_bubble_L2': "means ADDING groups.", 's1_bubble_L3': "We added 4 groups of +2.", 's1_bubble_L4': "Result: +8", 's1_bubble_L5': "",
    's2_bubble_L1': "Summary: A positive multiplier", 's2_bubble_L2': "means ADDING groups.", 's2_bubble_L3': "We added 4 groups of -2.", 's2_bubble_L4': "Result: -8", 's2_bubble_L5': "",
    's3_bubble_L1': "Summary: A negative multiplier", 's3_bubble_L2': "means to REMOVE groups.", 's3_bubble_L3': "We removed 4 groups of +2 by adding", 's3_bubble_L4': "zero pairs first.", 's3_bubble_L5': "Result: -8",
    's4_bubble_L1': "Summary: A negative multiplier", 's4_bubble_L2': "means to REMOVE groups.", 's4_bubble_L3': "We removed 4 groups of -2 by adding", 's4_bubble_L4': "zero pairs first.", 's4_bubble_L5': "Result: +8",
    's5_bubble_L1': "3 × (-5) = -15", 's5_bubble_L2': "(-5) × 3 = -15", 's5_bubble_L3': "Order does not matter!", 's5_bubble_L4': "(Commutative Property)", 's5_bubble_L5': ""
  },
  'hi': {
    'appTitle': "टोकन मशीन: पूर्णांक गुणा की कल्पना", 'appSubtitle': "कक्षा 7 • पूर्णांक संचालन", 'enterLab': "लैब में प्रवेश करें",
    'settings': "सेटिंग्स", 'theme': "थीम", 'darkMode': "डार्क मोड", 'lightMode': "लाइट मोड", 'boardFontSize': "टेक्स्ट आकार", 
    'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण", 
    'learnLbl': "हम क्या सीखते हैं:", 'closeBtn': "बंद करें", 'summaryTitle': "खोज की गई!",
    'resetBtn': "लैब रीसेट करें", 'finishLab': "लैब समाप्त करें", 'nextScenario': "अगला परिदृश्य",
    'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने पूर्णांक गुणा को सफलतापूर्वक मॉडल किया है! आपने कल्पना की है कि कैसे एक धनात्मक गुणक समूहों को जोड़ता है, और एक ऋणात्मक गुणक शून्य जोड़े का उपयोग करके समूहों को हटाता है।",
    
    'infoNextScen': "परिदृश्य पूरा हुआ! कृपया ऊपर दिए गए ड्रॉपडाउन से अगला परिदृश्य चुनें।",
    'infoLabDone': "लैब पूर्ण! आपने पूर्णांक गुणा में महारत हासिल कर ली है।",

    'toolbox': "संख्या टाइलें", 'workspaceMat': "कार्यक्षेत्र", 'netValue': "मूल्य:", 'tokens': "टोकन:",
    'activateBtn': "सक्रिय करें", 'finalizeBtn': "अंतिम रूप दें", 'resetBtnApp': "मशीन रीसेट करें", 'actionAdd': "क्रिया: जोड़ें", 'actionRem': "क्रिया: हटाएं",
    'multiplier': "गुणक\n(कितनी बार)", 'multiplicand': "गुण्य\n(किस पर कार्य करना है)",
    'emptyWs': "कार्यक्षेत्र का मान", 'previewPanel': "पूर्वावलोकन\nपैनल", 'machineCounter': "मशीन काउंटर", 'digiCount': "डिजिटल\nकाउंटर",
    'cycles': "चक्र:", 'target': "लक्ष्य:", 'reset': "रीसेट", 'summary': "सारांश",

    's1_title': "1. देने वाला (धनात्मक × धनात्मक)", 's1_obj': "यह समझने के लिए कि धनात्मक गुणक का अर्थ है धनात्मक टोकन के समूहों को 'जोड़ना'। हम 4 × 2 हल करेंगे।",
    's1_hud1': "4 × 2 हल करें। गुणक स्लॉट में संख्या टाइल '4' खींचें।", 's1_step1_task': "<b>क्रिया:</b> कार्यक्षेत्र खाली है (मान 0)। 'टोकन मशीन' को देखें। पहला इनपुट स्लॉट 'गुणक' (Multiplier) है। दूसरा 'गुण्य' (Multiplicand) है। गुणक स्लॉट में संख्या टाइल '4' खींचें।", 's1_step1_out': "<b>अवलोकन:</b> संख्या '4' गुणक स्लॉट में लॉक हो जाती है। मशीन का एक्शन आर्म हरे रंग में चमकता है, जो 'जोड़ें' (ADD) ऑपरेशन का संकेत देता है।",
    's1_hud2': "गुण्य स्लॉट में संख्या टाइल '2' खींचें।", 's1_step2_task': "<b>क्रिया:</b> गुण्य स्लॉट में संख्या टाइल '2' खींचें। यह मशीन को बताता है कि हम 2 धनात्मक टोकन के समूहों में रुचि रखते हैं।", 's1_step2_out': "<b>अवलोकन:</b> संख्या '2' गुण्य स्लॉट में लॉक हो जाती है। एक पूर्वावलोकन दो हरे टोकन दिखाता है।",
    's1_hud3': "'सक्रिय करें' बटन पर क्लिक करें।", 's1_step3_task': "<b>क्रिया:</b> मशीन पर बड़े 'सक्रिय करें' (ACTIVATE) बटन पर क्लिक करें।", 's1_step3_out': "<b>अवलोकन:</b> मशीन का आर्म 2 हरे टोकन का एक समूह उठाता है और उन्हें वर्कस्पेस में गिरा देता है। मशीन पर एक काउंटर '1' चमकता है। आर्म इसे तीन बार और दोहराता है। काउंटर '4' तक बढ़ जाता है। वर्कस्पेस में अब 8 हरे टोकन हैं।",
    's1_hud4': "अंतिम परिणाम देखें।", 's1_step4_task': "<b>क्रिया:</b> अंतिम परिणाम देखें। वर्कस्पेस पर काउंटर कुल मूल्य दिखाता है। 'अंतिम रूप दें' (Finalize) पर क्लिक करें।", 's1_step4_out': "<b>सीख:</b> एक बड़ा डिजिटल डिस्प्ले '+8' दिखाता है। 4 × 2 = 8.",
    's1_sum': "<b>ऑपरेशन पूर्ण!</b> 4 × 2 = 8.",

    's2_title': "2. ऋण संग्राहक (धनात्मक × ऋणात्मक)", 's2_obj': "यह समझने के लिए कि धनात्मक गुणक का अर्थ ऋणात्मक टोकन के समूहों को 'जोड़ना' भी हो सकता है। हम 4 × (-2) हल करेंगे।",
    's2_hud1': "4 × (-2) हल करें। 'RESET' क्लिक करें और '4' खींचें।", 's2_step1_task': "<b>क्रिया:</b> वर्कस्पेस को साफ़ करने के लिए 'RESET' बटन पर क्लिक करें। गुणक स्लॉट में संख्या टाइल '4' खींचें।", 's2_step1_out': "<b>अवलोकन:</b> वर्कस्पेस खाली है। संख्या '4' गुणक स्लॉट में है, और मशीन का आर्म हरे रंग में चमकता है ('ADD' ऑपरेशन)।",
    's2_hud2': "गुण्य स्लॉट में संख्या टाइल '-2' खींचें।", 's2_step2_task': "<b>क्रिया:</b> गुण्य स्लॉट में संख्या टाइल '-2' खींचें। यह मशीन को 2 ऋणात्मक टोकन के समूहों के साथ काम करने के लिए कहता है।", 's2_step2_out': "<b>अवलोकन:</b> संख्या '-2' गुण्य स्लॉट में लॉक हो जाती है। एक पूर्वावलोकन दो लाल टोकन दिखाता है।",
    's2_hud3': "'सक्रिय करें' बटन पर क्लिक करें।", 's2_step3_task': "<b>क्रिया:</b> 'सक्रिय करें' (ACTIVATE) बटन पर क्लिक करें।", 's2_step3_out': "<b>अवलोकन:</b> मशीन वर्कस्पेस में 2 ऋणात्मक टोकन के 4 समूह जोड़ती है। यह क्रिया 4 बार दोहराई जाती है। वर्कस्पेस में अब 8 लाल टोकन हैं।",
    's2_hud4': "अंतिम परिणाम देखें।", 's2_step4_task': "<b>क्रिया:</b> वर्कस्पेस काउंटर पर अंतिम परिणाम देखें। 'अंतिम रूप दें' (Finalize) पर क्लिक करें।", 's2_step4_out': "<b>सीख:</b> वर्कस्पेस काउंटर '-8' प्रदर्शित करता है। 4 × (-2) = -8.",
    's2_sum': "<b>ऑपरेशन पूर्ण!</b> 4 × (-2) = -8.",

    's3_title': "3. रिपो मैन (ऋणात्मक × धनात्मक)", 's3_obj': "यह समझने के लिए कि ऋणात्मक गुणक का अर्थ है समूहों को 'हटाना' और यह देखने के लिए कि 'शून्य जोड़े' का उपयोग कैसे किया जाता है।",
    's3_hud1': "(-4) × 2 हल करें। गुणक स्लॉट में संख्या टाइल '-4' खींचें।", 's3_step1_task': "<b>क्रिया:</b> वर्कस्पेस खाली है। गुणक स्लॉट में संख्या टाइल '-4' खींचें।", 's3_step1_out': "<b>अवलोकन:</b> संख्या '-4' गुणक स्लॉट में लॉक हो जाती है। मशीन का एक्शन आर्म अब लाल रंग में चमकता है, जो 'हटाएं' (REMOVE) ऑपरेशन का संकेत देता है।",
    's3_hud2': "गुण्य स्लॉट में संख्या टाइल '2' खींचें।", 's3_step2_task': "<b>क्रिया:</b> गुण्य स्लॉट में संख्या टाइल '2' खींचें। मशीन अब '2 धनात्मक के 4 समूहों को हटाने' के लिए सेट है।", 's3_step2_out': "<b>अवलोकन:</b> संख्या '2' स्लॉट में लॉक हो जाती है, जो दो हरे टोकन का पूर्वावलोकन दिखाती है।",
    's3_hud3': "'सक्रिय करें' क्लिक करें। शून्य जोड़े के उपयोग का निरीक्षण करें।", 's3_step3_task': "<b>क्रिया:</b> 'सक्रिय करें' बटन पर क्लिक करें। ध्यान से देखें कि क्या होता है जब मशीन खाली वर्कस्पेस से टोकन निकालने का प्रयास करती है।", 's3_step3_out': "<b>अवलोकन:</b> मशीन 2 हरे टोकन निकालने का प्रयास करती है, उसे कोई नहीं मिलता है, स्वचालित रूप से 2 शून्य जोड़े जोड़ती है, और फिर 2 हरे टोकन को चूस (vacuum) लेती है। यह 4 बार दोहराया जाता है।",
    's3_hud4': "अंतिम परिणाम देखें।", 's3_step4_task': "<b>क्रिया:</b> अंतिम परिणाम देखें। 'अंतिम रूप दें' पर क्लिक करें।", 's3_step4_out': "<b>सीख:</b> +2 के 4 समूहों को हटाने पर 8 ऋणात्मक टोकन बचते हैं।",
    's3_sum': "<b>ऑपरेशन पूर्ण!</b> (-4) × 2 = -8.",

    's4_title': "4. ऋण क्षमा करने वाला (ऋणात्मक × ऋणात्मक)", 's4_obj': "(-4) × (-2) को स्वयं हल करने के लिए 'हटाने' के नियम को लागू करें।",
    's4_hud1': "(-4) × (-2) को हल करने के लिए मशीन सेट करें।", 's4_step1_task': "<b>क्रिया:</b> `(-4) × (-2)` समस्या को हल करने के लिए टोकन मशीन सेट करें। गुणक और गुण्य स्लॉट में सही संख्या टाइलें खींचें।", 's4_step1_out': "<b>अवलोकन:</b> उपयोगकर्ता सही ढंग से '-4' और '-2' रखता है। मशीन का आर्म लाल रंग में चमकता है।",
    's4_hud2': "भविष्यवाणी करें, फिर 'सक्रिय करें' पर क्लिक करें।", 's4_step2_task': "<b>क्रिया:</b> सक्रिय करने से पहले, भविष्यवाणी करें कि क्या होगा। मशीन को 2 लाल टोकन के 4 समूहों को हटाना है। क्या बचेगा? जांचने के लिए 'सक्रिय करें' बटन पर क्लिक करें।", 's4_step2_out': "<b>अवलोकन:</b> मशीन शून्य जोड़े गिराती है, फिर 2 लाल टोकन चूस लेती है। यह 4 बार दोहराया जाता है, जिससे 8 हरे टोकन बचते हैं।",
    's4_hud3': "अंतिम मान क्या है?", 's4_step3_task': "<b>क्रिया:</b> वर्कस्पेस में अंतिम मान क्या है? 'अंतिम रूप दें' पर क्लिक करें।", 's4_step3_out': "<b>सीख:</b> ऋणात्मक टोकन (कर्ज) हटाने पर एक धनात्मक मान बचता है।",
    's4_sum': "<b>ऑपरेशन पूर्ण!</b> सही! कर्ज हटाना पैसे प्राप्त करने के समान है। (-4) × (-2) = 8.",

    's5_title': "5. स्विचरो (क्रमविनिमेय)", 's5_obj': "यह खोजना कि पूर्णांकों का गुणा क्रमविनिमेय (commutative) है, दो अलग-अलग समस्याओं को हल करके।",
    's5_hud1': "3 × (-5) हल करें। टाइलें खींचें और ACTIVATE पर क्लिक करें।", 's5_step1_task': "<b>क्रिया:</b> पहले, समस्या `3 × (-5)` सेट करें और हल करें। टाइलों को खींचें, 'सक्रिय करें' पर क्लिक करें, और परिणाम नोट करें।", 's5_step1_out': "<b>अवलोकन:</b> मशीन 5 लाल टोकन के 3 समूह जोड़ती है। अंतिम परिणाम -15 है।",
    's5_hud2': "RESET क्लिक करें। फिर (-5) × 3 हल करें। ACTIVATE क्लिक करें।", 's5_step2_task': "<b>क्रिया:</b> मशीन पर 'RESET' क्लिक करें। अब, उल्टी समस्या सेट करें और हल करें: `(-5) × 3`। टाइलों को खींचें, 'ACTIVATE' पर क्लिक करें, और परिणाम नोट करें।", 's5_step2_out': "<b>अवलोकन:</b> मशीन शून्य जोड़े का उपयोग करके 3 हरे टोकन के 5 समूहों को हटा देती है। अंतिम परिणाम भी -15 है।",
    's5_hud3': "परिणामों की तुलना करें।", 's5_step3_task': "<b>क्रिया:</b> चरण 1 और चरण 2 के परिणामों की तुलना करें। आप क्या देखते हैं? 'अंतिम रूप दें' पर क्लिक करें।", 's5_step3_out': "<b>सीख:</b> दोनों ऑपरेशन -15 के बराबर हैं।",
    's5_sum': "<b>खोज की गई!</b> परिणाम समान है! 3 × (-5) = (-5) × 3 = -15। क्रम से उत्तर नहीं बदलता है। यह क्रमविनिमेय गुण है।",
    
    's1_bubble_L1': "सारांश: एक धनात्मक गुणक का अर्थ", 's1_bubble_L2': "है समूहों को जोड़ना।", 's1_bubble_L3': "हमने +2 के 4 समूहों को जोड़ा।", 's1_bubble_L4': "परिणाम: +8", 's1_bubble_L5': "",
    's2_bubble_L1': "सारांश: एक धनात्मक गुणक का अर्थ", 's2_bubble_L2': "है समूहों को जोड़ना।", 's2_bubble_L3': "हमने -2 के 4 समूहों को जोड़ा।", 's2_bubble_L4': "परिणाम: -8", 's2_bubble_L5': "",
    's3_bubble_L1': "सारांश: -4 जैसे ऋणात्मक गुणक का", 's3_bubble_L2': "अर्थ है समूहों को हटाना।", 's3_bubble_L3': "+2 के 4 समूहों को हटाने के लिए,", 's3_bubble_L4': "हमने पहले शून्य जोड़े जोड़े।", 's3_bubble_L5': "परिणाम: -8",
    's4_bubble_L1': "सारांश: -4 जैसे ऋणात्मक गुणक का", 's4_bubble_L2': "अर्थ है समूहों को हटाना।", 's4_bubble_L3': "-2 के 4 समूहों को हटाने के लिए,", 's4_bubble_L4': "हमने पहले शून्य जोड़े जोड़े।", 's4_bubble_L5': "परिणाम: +8",
    's5_bubble_L1': "3 × (-5) = -15", 's5_bubble_L2': "(-5) × 3 = -15", 's5_bubble_L3': "क्रम मायने नहीं रखता!", 's5_bubble_L4': "(क्रमविनिमेय गुण)", 's5_bubble_L5': ""
  }
};
