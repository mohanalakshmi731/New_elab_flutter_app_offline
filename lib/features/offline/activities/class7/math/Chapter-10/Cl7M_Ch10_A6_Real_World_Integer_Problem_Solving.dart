// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RealWorldIntegersApp());
}

class RealWorldIntegersApp extends StatelessWidget {
  const RealWorldIntegersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Real-World Integers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const RealWorldIntegerProblemSolving(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class SliderObj {
  double x, y, w;
  int val, max;
  String type;
  bool isDragging;

  SliderObj({
    required this.x,
    required this.y,
    required this.w,
    required this.val,
    required this.max,
    required this.type,
    this.isDragging = false,
  });
}

// ==========================================
// MAIN WIDGET
// ==========================================
class RealWorldIntegerProblemSolving extends StatefulWidget {
  const RealWorldIntegerProblemSolving({super.key});

  @override
  State<RealWorldIntegerProblemSolving> createState() => _RealWorldIntegerProblemSolvingState();
}

class _RealWorldIntegerProblemSolvingState extends State<RealWorldIntegerProblemSolving> with TickerProviderStateMixin {
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

  // Simulation State
  double _elevatorVal = 0;
  int _score = 0;
  int _ticks = 0;
  int _crosses = 0;
  int _balance = 0;
  double _temp = 8;
  int _hours = 0;

  bool _animating = false;
  double _animProgress = 0;
  int _animFrame = 0;
  String _animType = '';

  SliderObj? _activeSlider;
  String? _activeDragEntity;
  double _dragX = 0;
  double _dragY = 0;

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
      if (_lang == 'en') _lang = 'hi'; else _lang = 'en';
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
      _step = 0;
      _activeDragEntity = null;
      _activeSlider = null;
      _animating = false;
      _animProgress = 0;
      _showSuccessPopup = false;
      
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;

      if (_scenario == 1) _elevatorVal = 0;
      if (_scenario == 2) { _score = 0; _ticks = 0; _crosses = 0; }
      if (_scenario == 3) { _balance = 0; }
      if (_scenario == 4) { _balance = 0; }
      if (_scenario == 5) { _temp = 8; _hours = 0; }
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    if (!_animating) return;
    setState(() {
      _animFrame++;
      if (_scenario == 1 && _step == 2) {
        _animProgress += 0.01;
        _elevatorVal = 15 - (_animProgress * 135);
        if (_animProgress >= 1.0) {
          _elevatorVal = -120;
          _animating = false;
          _playSound('success');
          _advanceStep(); // Moves to step 3
        }
      } else if (_scenario == 2 && _animType == 'tickStack') {
        if (_animFrame % 2 == 0) {
          _ticks++; _score += 5;
          if (_ticks >= 30) {
            _animating = false; _animType = '';
            _advanceStep();
          }
        }
      } else if (_scenario == 2 && _animType == 'crossStack') {
        if (_animFrame % 2 == 0) {
          _crosses++; _score -= 2;
          if (_crosses >= 20) {
            _animating = false; _animType = '';
            _advanceStep();
          }
        }
      } else if (_scenario == 4 && _step == 0) {
        if (_animFrame % 2 == 0) {
          _balance -= 1000;
          if (_balance <= -32000) {
            _balance = -32000;
            _animating = false;
            _advanceStep();
          }
        }
      } else if (_scenario == 5 && _step == 1) {
        if (_animFrame % 2 == 0) {
          _temp -= 0.5;
          double finalTarget = 8.0 - ((_hours + 1) * 5.0);
          if (_temp <= finalTarget) {
            _temp = finalTarget;
            _hours++;
            _animating = false;
            if (_hours >= 4) {
              _playSound('success');
              _advanceStep();
            }
          }
        }
      }
    });
  }

  void _triggerAction() {
    if (_animating) return;
    setState(() {
      if (_scenario == 1 && _step == 1) {
        _animating = true; _animProgress = 0;
        _playSound('tick');
        _advanceStep(); // Advances to observing step (2)
      } else if (_scenario == 4 && _step == 0) {
        _animating = true; _animFrame = 0;
        _playSound('error');
      } else if (_scenario == 5 && _step == 1) {
        _animating = true; _animFrame = 0;
        _playSound('tick');
      }
    });
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    int maxSteps = (_scenario == 1) ? 4 : (_scenario == 2 || _scenario == 3 || _scenario == 4 || _scenario == 5) ? 3 : 3;
    setState(() => _step = maxSteps);
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

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  // Handle exact interactive clicks directly inside tap down
  void _handleTapDown(TapDownDetails details, Size size) {
    Offset pt = _screenToWorld(details.localPosition, size);

    // Scenario Triggers
    if (_scenario == 1 && _step == 1 && !_animating) {
      if (_hitTestBox(220, -30, 140, 140, pt)) { _triggerAction(); return; }
    } else if (_scenario == 4 && _step == 0 && !_animating) {
      if (_hitTestBox(-390, -120, 220, 90, pt)) { _triggerAction(); return; }
    } else if (_scenario == 5 && _step == 1 && !_animating) {
      if (_hitTestBox(100, -70, 230, 120, pt)) { _triggerAction(); return; }
    }

    // Done Buttons Handling
    if (_scenario == 1 && _step == 3 && !_animating) {
      if (_hitTestBox(-220, 380, 160, 50, pt)) { _playSound('pop'); _checkScenarioSuccess(); return; }
    } else if (_scenario == 2 && _step == 2 && !_animating) {
      if (_hitTestBox(150, 290, 160, 50, pt)) { _playSound('pop'); _checkScenarioSuccess(); return; }
    } else if (_scenario == 3 && _step == 2 && !_animating) {
      if (_hitTestBox(-80, 240, 160, 50, pt)) { _playSound('pop'); _checkScenarioSuccess(); return; }
    } else if (_scenario == 4 && _step == 2 && !_animating) {
      if (_hitTestBox(100, 10, 160, 50, pt)) { _playSound('pop'); _checkScenarioSuccess(); return; }
    } else if (_scenario == 5 && _step == 2 && !_animating) {
      if (_hitTestBox(230, 230, 160, 50, pt)) { _playSound('pop'); _checkScenarioSuccess(); return; }
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    _dragX = pt.dx;
    _dragY = pt.dy;

    if (_activeSlider != null) {
      var s = _activeSlider!;
      double hx = s.x + (s.val / s.max) * s.w;
      if (_hitTestBox(hx - 30, s.y - 30, 60, 80, pt)) {
        setState(() => s.isDragging = true); return;
      }
      if (_hitTestBox(s.x, s.y - 20, s.w, 60, pt)) {
        setState(() {
          s.isDragging = true;
          double relX = pt.dx - s.x;
          double rawVal = (relX / s.w) * s.max;
          s.val = (rawVal / 100).round() * 100;
          s.val = s.val.clamp(0, s.max);
        });
        return;
      }
    }

    if (_scenario == 1 && _step == 0) {
      double cabY = -_elevatorVal * 2.5;
      if (_hitTestBox(-290, cabY - 50, 80, 100, pt)) {
        setState(() => _activeDragEntity = 'elevator'); _playSound('snap'); return;
      }
    } else if (_scenario == 2) {
      if (_step == 0 && _hitTestBox(-400, -20, 100, 100, pt)) {
        setState(() => _activeDragEntity = 'tickStack'); _playSound('snap'); return;
      }
      if (_step == 1 && _hitTestBox(-200, -20, 100, 100, pt)) {
        setState(() => _activeDragEntity = 'crossStack'); _playSound('snap'); return;
      }
    } else if (_scenario == 3) {
      if (_step == 0 && _activeSlider == null && _hitTestBox(-470, -150, 180, 180, pt)) {
        setState(() => _activeDragEntity = 'whiteBag'); _playSound('snap'); return;
      }
      if (_step == 1 && _activeSlider == null && _hitTestBox(260, -150, 180, 180, pt)) {
        setState(() => _activeDragEntity = 'greyBag'); _playSound('snap'); return;
      }
    } else if (_scenario == 4) {
      if (_step == 1 && _activeSlider == null && _hitTestBox(-380, 50, 160, 130, pt)) {
        setState(() => _activeDragEntity = 'whiteBag'); _playSound('snap'); return;
      }
    } else if (_scenario == 5 && _step == 0) {
      double mY = -_temp * 8;
      if (_hitTestBox(-350, mY - 30, 100, 80, pt)) {
        setState(() => _activeDragEntity = 'thermoCap'); _playSound('snap'); return;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      if (_activeSlider != null && _activeSlider!.isDragging) {
        var s = _activeSlider!;
        double relX = pt.dx - s.x;
        double rawVal = (relX / s.w) * s.max;
        s.val = (rawVal / 100).round() * 100;
        s.val = s.val.clamp(0, s.max);

        if (_scenario == 3) {
          if (s.type == 'white') _balance = s.val * 8;
          if (s.type == 'grey') _balance = 24000 + (s.val * -5);
        } else if (_scenario == 4) {
          _balance = -32000 + (s.val * 8);
        }
        return;
      }

      if (_activeDragEntity != null) {
        if (_activeDragEntity == 'elevator') {
          _elevatorVal = (-pt.dy / 2.5 / 5).round() * 5.0;
          _elevatorVal = _elevatorVal.clamp(-130.0, 20.0);
        } else if (_activeDragEntity == 'thermoCap') {
          _temp = (-pt.dy / 8).roundToDouble();
          _temp = _temp.clamp(-20.0, 20.0);
        } else {
          _dragX = pt.dx; _dragY = pt.dy;
        }
        return;
      }

      // Pan & Zoom
      if (details.scale != 1.0) {
        _zoom = (_baseZoom * details.scale).clamp(0.35, 1.5);
      }
      _panX += details.focalPointDelta.dx / _zoom;
      _panY += details.focalPointDelta.dy / _zoom;
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    Offset pt = Offset(_dragX, _dragY);
    if (_activeSlider != null && _activeSlider!.isDragging) {
      setState(() {
        _activeSlider!.isDragging = false;
        if (_activeSlider!.val == _activeSlider!.max) {
          _playSound('success');
          _activeSlider = null;
          _advanceStep();
        } else {
          _playSound('tick');
        }
      });
      return;
    }

    if (_activeDragEntity != null) {
      setState(() {
        if (_activeDragEntity == 'elevator') {
          if (_elevatorVal == 15) { _playSound('success'); _advanceStep(); } else { _playSound('tick'); }
        } else if (_activeDragEntity == 'thermoCap') {
          if (_temp == 8) { _playSound('success'); _advanceStep(); } else { _playSound('tick'); }
        } else if (_activeDragEntity == 'tickStack' || _activeDragEntity == 'crossStack') {
          if (_hitTestBox(0, -50, 450, 250, pt)) {
            _playSound('success');
            _animating = true; _animFrame = 0; _animType = _activeDragEntity!;
          } else { _playSound('error'); }
        } else if (_activeDragEntity == 'whiteBag' || _activeDragEntity == 'greyBag') {
          if (_hitTestBox(-150, -100, 350, 200, pt)) {
            _playSound('success');
            if (_scenario == 3) {
              _activeSlider = SliderObj(
                x: _activeDragEntity == 'whiteBag' ? -450 : 250, y: 150, w: 250,
                val: 0, max: _activeDragEntity == 'whiteBag' ? 3000 : 5000,
                type: _activeDragEntity == 'whiteBag' ? 'white' : 'grey'
              );
            } else if (_scenario == 4) {
              _activeSlider = SliderObj(x: -150, y: 100, w: 300, val: 0, max: 4000, type: 'white');
            }
          } else { _playSound('error'); }
        }
        _activeDragEntity = null;
      });
    }
  }

  // --- HTML Parsing for Rich Text ---
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

  // --- Sidebar Build ---
  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);

    int totalSteps = (_scenario == 1) ? 4 : (_scenario == 2 || _scenario == 3 || _scenario == 4 || _scenario == 5) ? 3 : 3;

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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.calculate, color: Colors.indigoAccent),
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
                                  width: 24, height: 24,
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

    int totalSteps = (_scenario == 1) ? 4 : (_scenario == 2 || _scenario == 3 || _scenario == 4 || _scenario == 5) ? 3 : 3;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
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
                        painter: RealWorldIntegersPainter(
                          scenario: _scenario, step: _step, zoom: _zoom, panX: _panX, panY: _panY,
                          elevatorVal: _elevatorVal, score: _score, ticks: _ticks, crosses: _crosses,
                          balance: _balance, temp: _temp, hours: _hours, animating: _animating, animProgress: _animProgress,
                          activeSlider: _activeSlider, activeDragEntity: _activeDragEntity, dragX: _dragX, dragY: _dragY,
                          t: t, screenSize: constraints.biggest,
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(top: BorderSide(color: Colors.amber, width: 4)),
                        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.info_outline, color: Colors.amber),
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
                                  width: 80, height: 80,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_scenario < 5)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _playSound('pop');
                                          setState(() => _showSuccessPopup = false);
                                          _loadScenario(_scenario + 1);
                                        },
                                        icon: const Icon(Icons.arrow_forward),
                                        label: Text(t('nextScenario')),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          backgroundColor: Colors.indigoAccent,
                                          foregroundColor: Colors.white,
                                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    if (_scenario == 5)
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
                                          backgroundColor: Colors.green,
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
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]),
                          child: const Icon(Icons.public, size: 80, color: Colors.indigoAccent),
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
class RealWorldIntegersPainter extends CustomPainter {
  final int scenario, step;
  final double zoom, panX, panY;
  
  final double elevatorVal;
  final int score, ticks, crosses, balance, hours;
  final double temp;
  final bool animating;
  final double animProgress;

  final SliderObj? activeSlider;
  final String? activeDragEntity;
  final double dragX, dragY;

  final Function(String) t;
  final Size screenSize;

  RealWorldIntegersPainter({
    required this.scenario, required this.step, required this.zoom, required this.panX, required this.panY,
    required this.elevatorVal, required this.score, required this.ticks, required this.crosses,
    required this.balance, required this.temp, required this.hours, required this.animating, required this.animProgress,
    required this.activeSlider, required this.activeDragEntity, required this.dragX, required this.dragY,
    required this.t, required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) _renderScenario1(canvas);
    else if (scenario == 2) _renderScenario2(canvas);
    else if (scenario == 3) _renderScenario3(canvas);
    else if (scenario == 4) _renderScenario4(canvas);
    else if (scenario == 5) _renderScenario5(canvas);

    // Render active drag icons
    if (activeDragEntity == 'tickStack') _drawTile(canvas, dragX, dragY, 'tick', 1.0);
    if (activeDragEntity == 'crossStack') _drawTile(canvas, dragX, dragY, 'cross', 1.0);
    if (activeDragEntity == 'whiteBag') _drawCementBag(canvas, dragX, dragY, 'white');
    if (activeDragEntity == 'greyBag') _drawCementBag(canvas, dragX, dragY, 'grey');
    if (activeDragEntity == 'elevator') _drawElevatorCab(canvas, dragX, dragY);
    if (activeDragEntity == 'thermoCap') _drawThermoCap(canvas, dragX, dragY);

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
    tpStroke.layout();
    
    TextPainter tpFill = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
      textDirection: TextDirection.ltr, textAlign: align,
    );
    tpFill.layout();

    List<String> lines = text.split('\n');
    double startY = y - ((lines.length - 1) * fontSize * 1.2) / 2;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      TextPainter stroke = TextPainter(text: TextSpan(text: line, style: tpStroke.text!.style), textDirection: TextDirection.ltr, textAlign: align)..layout();
      TextPainter fill = TextPainter(text: TextSpan(text: line, style: tpFill.text!.style), textDirection: TextDirection.ltr, textAlign: align)..layout();
      
      double dx = align == TextAlign.center ? x - stroke.width / 2 : (align == TextAlign.right ? x - stroke.width : x);
      double dy = startY + i * fontSize * 1.2 - stroke.height / 2;
      
      if (outlineW > 0) stroke.paint(canvas, Offset(dx, dy));
      fill.paint(canvas, Offset(dx, dy));
    }
  }

  void _drawArrow(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width, double headSize) {
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), Paint()..color = color..strokeWidth = width..strokeCap=StrokeCap.round);
    double angle = atan2(y2 - y1, x2 - x1);
    Path path = Path()
      ..moveTo(x2, y2)
      ..lineTo(x2 - headSize * cos(angle - pi / 6), y2 - headSize * sin(angle - pi / 6))
      ..lineTo(x2 - headSize * cos(angle + pi / 6), y2 - headSize * sin(angle + pi / 6))
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawSpeechBubble(Canvas canvas, String text, double x, double y, double w, double h, String pointDir, double pointOffset, Color bg, Color textCol, Color border, double borderW) {
    _drawRoundedRect(canvas, x, y, w, h, 10, bg, border, borderW);
    Path p = Path();
    if (pointDir == 'left') { p.moveTo(x+3, y+pointOffset); p.lineTo(x-20, y+pointOffset+10); p.lineTo(x+3, y+pointOffset+20); }
    else if (pointDir == 'bottom') { p.moveTo(x+pointOffset, y+h-3); p.lineTo(x+pointOffset+10, y+h+20); p.lineTo(x+pointOffset+20, y+h-3); }
    else if (pointDir == 'right') { p.moveTo(x+w-3, y+pointOffset); p.lineTo(x+w+20, y+pointOffset+10); p.lineTo(x+w-3, y+pointOffset+20); }
    else if (pointDir == 'top') { p.moveTo(x+pointOffset, y+3); p.lineTo(x+pointOffset+10, y-20); p.lineTo(x+pointOffset+20, y+3); }
    canvas.drawPath(p, Paint()..color = bg);
    if(borderW > 0) {
      canvas.drawPath(p, Paint()..color = border..style=PaintingStyle.stroke..strokeWidth=borderW);
    }
    _drawTextOutline(canvas, text, x + w/2, y + h/2, 16, textCol, Colors.transparent, 0);
  }

  void _drawTile(Canvas canvas, double x, double y, String type, double scale) {
    canvas.save(); canvas.translate(x, y); canvas.scale(scale, scale);
    _drawRoundedRect(canvas, -15, -11, 30, 30, 6, const Color(0xFFCBD5E1), Colors.transparent, 0);
    _drawRoundedRect(canvas, -15, -15, 30, 30, 6, const Color(0xFFF8FAFC), type=='tick'?const Color(0xFF22C55E):const Color(0xFFEF4444), 3);
    if (type == 'tick') {
      canvas.drawPath(Path()..moveTo(-6, 0)..lineTo(-2, 4)..lineTo(6, -6), Paint()..color=const Color(0xFF22C55E)..strokeWidth=3..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
    } else {
      canvas.drawPath(Path()..moveTo(-5, -5)..lineTo(5, 5)..moveTo(5, -5)..lineTo(-5, 5), Paint()..color=const Color(0xFFEF4444)..strokeWidth=3..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    }
    canvas.restore();
  }

  void _drawCementBag(Canvas canvas, double cx, double cy, String type) {
    canvas.save(); canvas.translate(cx, cy);
    Color fill = type == 'white' ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8);
    _drawRoundedRect(canvas, -35, -20, 70, 40, 6, fill, const Color(0xFF0F172A), 3);
    if (type == 'white') {
      _drawTextOutline(canvas, t('lbl_white_short'), 0, -5, 12, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, "+₹8", 0, 8, 14, const Color(0xFF16A34A), Colors.transparent, 0);
    } else {
      _drawTextOutline(canvas, t('lbl_grey_short'), 0, -5, 12, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, "-₹5", 0, 8, 14, const Color(0xFFDC2626), Colors.transparent, 0);
    }
    canvas.restore();
  }

  void _drawMiniBag(Canvas canvas, double x, double y, String type) {
    Color fill = type == 'white' ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8);
    _drawRoundedRect(canvas, x-15, y-10, 30, 20, 3, fill, const Color(0xFF0F172A), 2);
  }

  void _drawTruck(Canvas canvas, double x, double y) {
    canvas.save(); canvas.translate(x, y);
    _drawRoundedRect(canvas, -180, -120, 320, 130, 5, const Color(0xFFE2E8F0), const Color(0xFF0F172A), 4);
    _drawRoundedRect(canvas, -180, 10, 320, 20, 0, const Color(0xFF334155), const Color(0xFF0F172A), 4);
    canvas.drawRRect(RRect.fromRectAndCorners(const Rect.fromLTWH(150, -70, 90, 100), topLeft: const Radius.circular(10), topRight: const Radius.circular(30), bottomRight: const Radius.circular(10)), Paint()..color=const Color(0xFFF59E0B));
    canvas.drawRRect(RRect.fromRectAndCorners(const Rect.fromLTWH(150, -70, 90, 100), topLeft: const Radius.circular(10), topRight: const Radius.circular(30), bottomRight: const Radius.circular(10)), Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=4);
    canvas.drawRRect(RRect.fromRectAndCorners(const Rect.fromLTWH(160, -60, 45, 45), topLeft: const Radius.circular(5), topRight: const Radius.circular(15), bottomRight: const Radius.circular(5), bottomLeft: const Radius.circular(5)), Paint()..color=const Color(0xFFBAE6FD));
    canvas.drawRRect(RRect.fromRectAndCorners(const Rect.fromLTWH(160, -60, 45, 45), topLeft: const Radius.circular(5), topRight: const Radius.circular(15), bottomRight: const Radius.circular(5), bottomLeft: const Radius.circular(5)), Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=3);
    
    for (double wx in [-120, -50, 180]) {
      canvas.drawCircle(Offset(wx, 30), 25, Paint()..color=const Color(0xFF1E293B));
      canvas.drawCircle(Offset(wx, 30), 25, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawCircle(Offset(wx, 30), 12, Paint()..color=const Color(0xFF94A3B8));
      canvas.drawCircle(Offset(wx, 30), 12, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=3);
    }
    canvas.restore();
  }

  void _drawTruckBags(Canvas canvas, double truckX, double truckY, int greyCount, int whiteCount, bool greyLocked) {
    canvas.save(); canvas.translate(truckX, truckY);
    int bIndex = 0;
    for(int i=0; i<greyCount; i++) {
      int col = bIndex % 8; int row = bIndex ~/ 8;
      double bx = -150 + col * 38.0; double by = -15 - row * 22.0;
      _drawMiniBag(canvas, bx, by, 'grey');
      if (greyLocked) _drawTextOutline(canvas, "🔒", bx, by, 12, Colors.white, Colors.transparent, 0);
      bIndex++;
    }
    for(int i=0; i<whiteCount; i++) {
      int col = bIndex % 8; int row = bIndex ~/ 8;
      double bx = -150 + col * 38.0; double by = -15 - row * 22.0;
      _drawMiniBag(canvas, bx, by, 'white');
      _drawTextOutline(canvas, "+₹8", bx, by, 10, const Color(0xFF16A34A), Colors.transparent, 0);
      bIndex++;
    }
    canvas.restore();
  }

  void _drawElevatorCab(Canvas canvas, double cx, double cy) {
    canvas.save(); canvas.translate(cx, cy);
    _drawRoundedRect(canvas, -40, -50, 80, 100, 4, const Color(0xFFFBBF24), const Color(0xFF0F172A), 3);
    _drawRoundedRect(canvas, -40, -50, 80, 15, 0, const Color(0xFF94A3B8), const Color(0xFF0F172A), 3);
    _drawRoundedRect(canvas, -40, 35, 80, 15, 0, const Color(0xFF94A3B8), const Color(0xFF0F172A), 3);
    _drawRoundedRect(canvas, -20, -58, 40, 8, 2, const Color(0xFF64748B), const Color(0xFF0F172A), 3);
    _drawRoundedRect(canvas, -25, -25, 20, 50, 2, const Color(0xFF38BDF8), const Color(0xFF0F172A), 3);
    _drawRoundedRect(canvas, 5, -25, 20, 50, 2, const Color(0xFF38BDF8), const Color(0xFF0F172A), 3);
    _drawRoundedRect(canvas, 30, 0, 6, 12, 2, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 2);
    canvas.restore();
  }

  void _drawThermoCap(Canvas canvas, double cx, double cy) {
    canvas.save(); canvas.translate(cx, cy);
    _drawRoundedRect(canvas, -35, -10, 70, 20, 10, Colors.transparent, const Color(0xFF6366F1), 4);
    canvas.restore();
  }

  // ---- SCENARIOS ----
  void _renderScenario1(Canvas canvas) {
    double scaleY = 2.5; double shaftX = -250;
    canvas.drawRect(const Rect.fromLTWH(-2000, -1500, 4000, 3000), Paint()..color=const Color(0xFF4A3F35));
    Paint p = Paint()..color=const Color(0xFF3E2723)..strokeWidth=15..strokeCap=StrokeCap.square;
    for(double by = -800; by <= 800; by += 100) canvas.drawLine(Offset(-2000, by), Offset(50, by), p);
    for(double bx = -1500; bx <= -50; bx += 150) canvas.drawLine(Offset(bx, -1500), Offset(bx, 1500), p);
    canvas.drawRect(const Rect.fromLTWH(100, -1500, 2000, 3000), Paint()..color=const Color(0xFF1E293B));

    double nlX = shaftX - 60;
    canvas.drawLine(Offset(nlX, -300), Offset(nlX, 400), Paint()..color=const Color(0xFF06B6D4)..strokeWidth=4);
    canvas.drawLine(Offset(nlX, 0), const Offset(-50, 0), Paint()..color=const Color(0xFF06B6D4)..strokeWidth=2);
    _drawTextOutline(canvas, "0", nlX - 10, 0, 16, const Color(0xFFF8FAFC), Colors.transparent, 0, align: TextAlign.right);
    _drawTextOutline(canvas, t('lbl_s1_ground'), nlX - 30, -5, 12, const Color(0xFFFACC15), Colors.transparent, 0, align: TextAlign.right);

    for (int m = 20; m >= -130; m -= 5) {
      double y = -m * scaleY;
      if (y >= -350 && y <= 400) {
        bool isMajor = (m % 20 == 0) || m == 15;
        double w = isMajor ? 15 : 8;
        canvas.drawLine(Offset(nlX, y), Offset(nlX + w, y), Paint()..color=const Color(0xFF06B6D4)..strokeWidth=3);
        if (isMajor && m != 0) {
          _drawTextOutline(canvas, m > 0 ? '+$m m' : '${m}m', nlX - 15, y, 14, const Color(0xFFF8FAFC), Colors.transparent, 0, align: TextAlign.right);
        }
      }
    }

    double cabY = -elevatorVal * scaleY;
    canvas.drawLine(Offset(shaftX, cabY - 50), Offset(shaftX, -2000), Paint()..color=const Color(0xFF94A3B8)..strokeWidth=4);
    if (activeDragEntity != 'elevator') _drawElevatorCab(canvas, shaftX, cabY);

    if (step == 0 && (elevatorVal - 15).abs() > 0.1) {
      _drawRoundedRect(canvas, shaftX - 45, cabY - 55, 90, 110, 10, Colors.transparent, const Color(0xFFFACC15), 4);
    } else if (step == 1 && !animating) {
      Paint wp = Paint()..color=Colors.white..strokeWidth=3..strokeCap=StrokeCap.round;
      canvas.drawLine(Offset(shaftX - 55, cabY - 20), Offset(shaftX - 65, cabY - 40), wp);
      canvas.drawLine(Offset(shaftX - 55, cabY + 20), Offset(shaftX - 65, cabY + 40), wp);
      canvas.drawLine(Offset(shaftX + 55, cabY - 20), Offset(shaftX + 65, cabY - 40), wp);
      canvas.drawLine(Offset(shaftX + 55, cabY + 20), Offset(shaftX + 65, cabY + 40), wp);
    }

    if (step == 0) {
      _drawSpeechBubble(canvas, "${t('lbl_s1_startPos')} +15m", shaftX + 60, -15 * scaleY - 20, 200, 40, 'left', 10, const Color(0xFFE0F2FE), const Color(0xFF0F172A), const Color(0xFF0F172A), 3);
    }

    double arrowX = -100;
    if (step >= 2 && cabY > -15 * scaleY) {
      _drawArrow(canvas, arrowX, -15 * scaleY, arrowX, cabY, const Color(0xFFFACC15), 4, 15);
      _drawTextOutline(canvas, "135 m", arrowX - 25, ((-15 * scaleY) + cabY) / 2, 16, const Color(0xFFFACC15), Colors.transparent, 0);
    }

    if (step >= 2) {
      _drawRoundedRect(canvas, arrowX + 20, -180, 260, 60, 10, const Color(0xFF0F172A), const Color(0xFFFACC15), 3);
      _drawTextOutline(canvas, t('lbl_s1_eq1'), arrowX + 150, -150, 14, const Color(0xFF38BDF8), Colors.transparent, 0);
    }

    // Control Panel
    canvas.save(); canvas.translate(220, -30);
    _drawRoundedRect(canvas, 0, -100, 220, 250, 10, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 4);
    _drawRoundedRect(canvas, 10, -80, 200, 30, 15, const Color(0xFF1E293B), const Color(0xFF0F172A), 3);
    _drawTextOutline(canvas, t('lbl_s1_rate'), 110, -65, 14, const Color(0xFF38BDF8), Colors.transparent, 0);
    _drawRoundedRect(canvas, 60, -40, 100, 45, 8, const Color(0xFF0F172A), const Color(0xFF475569), 3);
    String timeStr = "00:00";
    if (step >= 2) {
      int mins = (animProgress * 45).floor(); if (step > 2) mins = 45;
      timeStr = mins.toString().padLeft(2, '0') + ":00";
    }
    _drawTextOutline(canvas, timeStr, 110, -17, 28, const Color(0xFF38BDF8), Colors.transparent, 0);
    canvas.drawCircle(const Offset(180, -17), 6, Paint()..color=const Color(0xFFEF4444)); canvas.drawCircle(const Offset(180, -17), 6, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawLine(const Offset(0, 15), const Offset(220, 15), Paint()..color=const Color(0xFF94A3B8)..strokeWidth=3);

    bool btnDown = (step == 1 && animating); double bY = btnDown ? 75 : 70;
    _drawRoundedRect(canvas, 30, 30, 80, 80, 40, const Color(0xFF94A3B8), const Color(0xFF0F172A), 3);
    _drawRoundedRect(canvas, 35, 40, 70, 70, 35, const Color(0xFF7F1D1D), const Color(0xFF0F172A), 2);
    _drawRoundedRect(canvas, 35, bY - 30, 70, 70, 35, const Color(0xFFEF4444), const Color(0xFF0F172A), 2);
    _drawTextOutline(canvas, t('lbl_s1_start'), 70, bY + 5, 11, Colors.white, Colors.transparent, 0);
    if (step == 1 && !animating) {
      _drawRoundedRect(canvas, 35, 35, 70, 70, 35, Colors.transparent, const Color(0xFFFACC15), 4);
    }
    _drawRoundedRect(canvas, 130, 35, 60, 30, 4, const Color(0xFF64748B), const Color(0xFF0F172A), 2);
    canvas.drawCircle(const Offset(160, 50), 4, Paint()..color=const Color(0xFFFACC15)); canvas.drawLine(const Offset(160, 50), const Offset(175, 45), Paint()..color=const Color(0xFFFACC15)..strokeWidth=2);
    canvas.drawCircle(const Offset(160, 90), 10, Paint()..color=const Color(0xFFF59E0B)); canvas.drawCircle(const Offset(160, 90), 10, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.restore();

    if (step >= 3) {
      canvas.drawLine(Offset(shaftX, 300), const Offset(-20, 300), Paint()..color=const Color(0xFFFACC15)..strokeWidth=4);
      _drawRoundedRect(canvas, -80, 240, 420, 70, 10, const Color(0xFF164E63), const Color(0xFF38BDF8), 3);
      _drawTextOutline(canvas, t('lbl_s1_eq2'), 130, 275, 16, const Color(0xFFFACC15), Colors.transparent, 0);
      _drawSpeechBubble(canvas, t('lbl_s1_solved'), -240, 170, 120, 50, 'bottom', 60, Colors.white, const Color(0xFF0F172A), const Color(0xFF0F172A), 3);
      
      // Add Done Button for Scenario 1
      _drawRoundedRect(canvas, -220, 380, 160, 50, 25, const Color(0xFF16A34A), const Color(0xFF0F172A), 4);
      _drawTextOutline(canvas, t('doneBtn'), -140, 405, 20, Colors.white, Colors.transparent, 0);
    }
  }

  void _renderScenario2(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-2000, -1500, 4000, 1400), Paint()..color=const Color(0xFF334155));
    canvas.drawRect(const Rect.fromLTWH(-2000, -100, 4000, 1500), Paint()..color=const Color(0xFF78350F));
    canvas.drawLine(const Offset(-2000, -100), const Offset(2000, -100), Paint()..color=const Color(0xFF451A03)..strokeWidth=10);

    _drawRoundedRect(canvas, 100, -350, 400, 200, 10, const Color(0xFF166534), const Color(0xFF78350F), 8);
    _drawRoundedRect(canvas, 110, -340, 380, 180, 4, const Color(0x1AFFFFFF), Colors.transparent, 0);
    canvas.drawLine(const Offset(200, -170), const Offset(250, -170), Paint()..color=const Color(0xFFF8FAFC)..strokeWidth=6);

    canvas.drawPath(Path()..moveTo(-450, -100)..lineTo(-350, -100)..lineTo(-370, -20)..lineTo(-430, -20)..close(), Paint()..color=const Color(0xFFB45309));
    canvas.drawPath(Path()..moveTo(-450, -100)..lineTo(-350, -100)..lineTo(-370, -20)..lineTo(-430, -20)..close(), Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawCircle(const Offset(-400, -130), 40, Paint()..color=const Color(0xFF22C55E)); canvas.drawCircle(const Offset(-400, -130), 40, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawCircle(const Offset(-440, -100), 30, Paint()..color=const Color(0xFF22C55E)); canvas.drawCircle(const Offset(-440, -100), 30, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawCircle(const Offset(-360, -100), 30, Paint()..color=const Color(0xFF22C55E)); canvas.drawCircle(const Offset(-360, -100), 30, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2);

    _drawRoundedRect(canvas, -150, -280, 220, 120, 15, const Color(0xFF3B82F6), const Color(0xFF1E3A8A), 8);
    _drawRoundedRect(canvas, -135, -265, 190, 90, 8, const Color(0xFFF8FAFC), const Color(0xFF94A3B8), 4);
    _drawTextOutline(canvas, score.toString(), -40, -220, 72, const Color(0xFF0F172A), Colors.transparent, 0);

    _drawRoundedRect(canvas, 0, -50, 450, 250, 10, const Color(0xFFF8FAFC), const Color(0xFF94A3B8), 4);
    canvas.drawLine(const Offset(200, -40), const Offset(200, 190), Paint()..color=const Color(0xFFCBD5E1)..strokeWidth=4);

    _drawRoundedRect(canvas, 20, -70, 120, 30, 15, const Color(0xFFE2E8F0), const Color(0xFF94A3B8), 2);
    _drawTextOutline(canvas, t('lbl_s2_30x'), 80, -55, 14, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawRoundedRect(canvas, 260, -70, 120, 30, 15, const Color(0xFFE2E8F0), const Color(0xFF94A3B8), 2);
    _drawTextOutline(canvas, t('lbl_s2_20x'), 320, -55, 14, const Color(0xFF0F172A), Colors.transparent, 0);

    _drawTextOutline(canvas, t('lbl_s2_correct'), -300, 120, 16, const Color(0xFFF8FAFC), Colors.transparent, 0);
    for(int i=0; i<5; i++) _drawTile(canvas, -350, 50 - i*10.0, 'tick', 1.0);
    if (step == 0 && activeDragEntity != 'tickStack') _drawRoundedRect(canvas, -370, -10, 50, 80, 8, Colors.transparent, const Color(0xFF6366F1), 4);

    _drawTextOutline(canvas, t('lbl_s2_wrong'), -150, 120, 16, const Color(0xFFF8FAFC), Colors.transparent, 0);
    for(int i=0; i<5; i++) _drawTile(canvas, -150, 50 - i*10.0, 'cross', 1.0);
    if (step == 1 && activeDragEntity != 'crossStack') _drawRoundedRect(canvas, -170, -10, 50, 80, 8, Colors.transparent, const Color(0xFF6366F1), 4);

    for(int i=0; i<ticks; i++) _drawTile(canvas, 25 + (i%5)*35.0, -20 + (i~/5)*35.0, 'tick', 0.8);
    for(int i=0; i<crosses; i++) _drawTile(canvas, 225 + (i%5)*35.0, -20 + (i~/5)*35.0, 'cross', 0.8);

    if (step >= 2) {
      _drawRoundedRect(canvas, 20, 220, 420, 50, 10, Colors.white, const Color(0xFF0F172A), 4);
      _drawTextOutline(canvas, t('lbl_s2_eq'), 230, 245, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      
      // Add Done Button for Scenario 2
      _drawRoundedRect(canvas, 150, 290, 160, 50, 25, const Color(0xFF16A34A), const Color(0xFF0F172A), 4);
      _drawTextOutline(canvas, t('doneBtn'), 230, 315, 20, Colors.white, Colors.transparent, 0);
    }
  }

  void _renderScenario3(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-2000, 50, 4000, 1500), Paint()..color=const Color(0xFFE2E8F0));
    canvas.drawRect(const Rect.fromLTWH(-2000, -1500, 4000, 1550), Paint()..color=const Color(0xFFF1F5F9));
    canvas.drawLine(const Offset(-2000, 50), const Offset(2000, 50), Paint()..color=const Color(0xFF94A3B8)..strokeWidth=4);
    for(int i=0; i<4; i++) {
      double sx = -600 + i * 400.0;
      _drawRoundedRect(canvas, sx, -250, 180, 300, 0, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 4);
      canvas.drawLine(Offset(sx, -150), Offset(sx+180, -150), Paint()..color=const Color(0xFF0F172A)..strokeWidth=4);
      canvas.drawLine(Offset(sx, -50), Offset(sx+180, -50), Paint()..color=const Color(0xFF0F172A)..strokeWidth=4);
      _drawRoundedRect(canvas, sx+20, -240, 60, 80, 4, const Color(0xFFD97706), const Color(0xFF0F172A), 3);
      _drawRoundedRect(canvas, sx+90, -140, 70, 80, 4, const Color(0xFFB45309), const Color(0xFF0F172A), 3);
    }

    double truckX = 0; double truckY = 50;
    _drawTruck(canvas, truckX, truckY);

    double whitePx = -380; double whitePy = 30;
    double greyPx = 350; double greyPy = 30;

    _drawRoundedRect(canvas, -120, -250, 240, 90, 10, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 4);
    _drawTextOutline(canvas, t('lbl_s3_bank'), 0, -220, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawRoundedRect(canvas, -100, -205, 200, 35, 6, const Color(0xFF1E293B), const Color(0xFF0F172A), 3);
    Color balColor = balance < 0 ? const Color(0xFFEF4444) : const Color(0xFF4ADE80);
    _drawTextOutline(canvas, balance < 0 ? "-₹${balance.abs()}" : "₹$balance", 0, -187, 24, balColor, Colors.transparent, 0);

    int wCount = 0; int gCount = 0;
    if (step == 0 && activeSlider != null) { wCount = ((activeSlider!.val / 3000) * 24).floor(); }
    else if (step >= 1) { wCount = 24; if (step == 1 && activeSlider != null) { gCount = ((activeSlider!.val / 5000) * 32).floor(); } else if (step >= 2) { gCount = 32; } }
    _drawTruckBags(canvas, truckX, truckY, gCount, wCount, false);

    if (step == 0) {
      _drawRoundedRect(canvas, whitePx - 80, whitePy, 160, 20, 4, const Color(0xFFB45309), const Color(0xFF0F172A), 3);
      for(int r=0; r<4; r++) { for(int c=0; c<2; c++) { _drawCementBag(canvas, whitePx - 40 + c*80, whitePy - 20 - r*30, 'white'); } }
      if (activeSlider == null && activeDragEntity != 'whiteBag') {
        _drawRoundedRect(canvas, whitePx - 90, whitePy - 150, 180, 180, 8, Colors.transparent, const Color(0xFF6366F1), 4);
        _drawTextOutline(canvas, t('lbl_drag'), whitePx, whitePy - 170, 16, const Color(0xFF38BDF8), Colors.transparent, 0);
      } else if (activeSlider != null) {
        var sdr = activeSlider!;
        _drawRoundedRect(canvas, sdr.x, sdr.y, sdr.w, 20, 10, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 4);
        double fillW = (sdr.val / sdr.max) * sdr.w;
        _drawRoundedRect(canvas, sdr.x, sdr.y, fillW, 20, 10, const Color(0xFF4ADE80), const Color(0xFF0F172A), 4);
        double hx = sdr.x + fillW;
        _drawRoundedRect(canvas, hx - 15, sdr.y - 15, 30, 50, 8, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 4);
        _drawTextOutline(canvas, "${sdr.val} ${t('lbl_s3_bags')}", hx, sdr.y - 25, 16, const Color(0xFF0F172A), Colors.transparent, 0);
        _drawSpeechBubble(canvas, "${t('lbl_calc')}\n${sdr.val} × (+₹8) = ₹${sdr.val*8}", 180, -100, 260, 60, 'left', 30, const Color(0xFFF8FAFC), const Color(0xFF0F172A), const Color(0xFF0F172A), 3);
      }
    } else if (step == 1) {
      _drawRoundedRect(canvas, greyPx - 80, greyPy, 160, 20, 4, const Color(0xFFB45309), const Color(0xFF0F172A), 3);
      for(int r=0; r<4; r++) { for(int c=0; c<2; c++) { _drawCementBag(canvas, greyPx - 40 + c*80, greyPy - 20 - r*30, 'grey'); } }
      if (activeSlider == null && activeDragEntity != 'greyBag') {
        _drawRoundedRect(canvas, greyPx - 90, greyPy - 150, 180, 180, 8, Colors.transparent, const Color(0xFF6366F1), 4);
        _drawTextOutline(canvas, t('lbl_drag'), greyPx, greyPy - 170, 16, const Color(0xFF38BDF8), Colors.transparent, 0);
      } else if (activeSlider != null) {
        var sdr = activeSlider!;
        _drawRoundedRect(canvas, sdr.x, sdr.y, sdr.w, 20, 10, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 4);
        double fillW = (sdr.val / sdr.max) * sdr.w;
        _drawRoundedRect(canvas, sdr.x, sdr.y, fillW, 20, 10, const Color(0xFFEF4444), const Color(0xFF0F172A), 4);
        double hx = sdr.x + fillW;
        _drawRoundedRect(canvas, hx - 15, sdr.y - 15, 30, 50, 8, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 4);
        _drawTextOutline(canvas, "${sdr.val} ${t('lbl_s3_bags')}", hx, sdr.y - 25, 16, const Color(0xFF0F172A), Colors.transparent, 0);
        _drawSpeechBubble(canvas, "${t('lbl_calc')}\n${sdr.val} × (-₹5) = -₹${sdr.val*5}", 180, -100, 260, 60, 'left', 30, const Color(0xFFF8FAFC), const Color(0xFF0F172A), const Color(0xFF0F172A), 3);
      }
    } else if (step >= 2) {
      _drawRoundedRect(canvas, -350, 150, 700, 70, 10, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 4);
      String sumText = t('s3_sum').replaceAll('<br/>', '').replaceAll('`', '');
      _drawTextOutline(canvas, "SUMMARY EQUATION: $sumText", 0, 185, 16, const Color(0xFF0F172A), Colors.transparent, 0);

      // Add Done Button for Scenario 3
      _drawRoundedRect(canvas, -80, 240, 160, 50, 25, const Color(0xFF16A34A), const Color(0xFF0F172A), 4);
      _drawTextOutline(canvas, t('doneBtn'), 0, 265, 20, Colors.white, Colors.transparent, 0);
    }
  }

  void _renderScenario4(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-2000, -1500, 4000, 1550), Paint()..color=const Color(0xFFBAE6FD));
    canvas.drawRect(const Rect.fromLTWH(-2000, 50, 4000, 1500), Paint()..color=const Color(0xFFE2E8F0));
    canvas.drawLine(const Offset(-2000, 50), const Offset(2000, 50), Paint()..color=const Color(0xFF94A3B8)..strokeWidth=4);
    
    canvas.drawPath(Path()..moveTo(-600, 50)..lineTo(-600, -300)..lineTo(-200, -450)..lineTo(300, -300)..lineTo(300, 50)..close(), Paint()..color=const Color(0xFFF8FAFC));
    canvas.drawPath(Path()..moveTo(-600, 50)..lineTo(-600, -300)..lineTo(-200, -450)..lineTo(300, -300)..lineTo(300, 50)..close(), Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=4);
    canvas.drawPath(Path()..moveTo(-640, -300)..lineTo(-200, -470)..lineTo(340, -300)..lineTo(-640, -300)..close(), Paint()..color=const Color(0xFF64748B));
    canvas.drawPath(Path()..moveTo(-640, -300)..lineTo(-200, -470)..lineTo(340, -300)..lineTo(-640, -300)..close(), Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=4);
    _drawRoundedRect(canvas, -250, -100, 160, 150, 0, const Color(0xFF334155), const Color(0xFF0F172A), 4);
    for(double y=-80; y<50; y+=20) canvas.drawLine(Offset(-250, y), Offset(-90, y), Paint()..color=const Color(0xFF475569)..strokeWidth=2);
    _drawRoundedRect(canvas, 400, -400, 40, 450, 0, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 4);
    canvas.drawRect(const Rect.fromLTWH(400, -400, 40, 60), Paint()..color=const Color(0xFFEF4444));
    canvas.drawRect(const Rect.fromLTWH(400, -300, 40, 60), Paint()..color=const Color(0xFFEF4444));

    double truckX = 80; double truckY = 50; 
    _drawTruck(canvas, truckX, truckY);
    int wBags = 0;
    if (step >= 1 && activeSlider != null) { wBags = ((activeSlider!.val / 4000) * 24).floor(); }
    else if (step >= 2) { wBags = 24; }
    _drawTruckBags(canvas, truckX, truckY, 32, wBags, step >= 1);

    double panelX = -280; double panelY = -50;
    _drawRoundedRect(canvas, panelX - 120, panelY - 80, 240, 140, 10, const Color(0xFFE2E8F0), const Color(0xFF0F172A), 4);
    Color btnColor = (step == 0 && !animating) ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5);
    _drawRoundedRect(canvas, panelX - 90, panelY - 50, 180, 50, 8, btnColor, const Color(0xFF7F1D1D), 4);
    _drawTextOutline(canvas, t('lbl_s4_loss'), panelX, panelY - 25, 16, Colors.white, Colors.transparent, 0);
    
    if (step == 0 && !animating) {
      _drawRoundedRect(canvas, panelX - 95, panelY - 55, 190, 60, 12, Colors.transparent, const Color(0xFFFACC15), 4);
    }

    if (step >= 1) {
      _drawRoundedRect(canvas, panelX - 120, panelY + 10, 240, 60, 8, const Color(0xFFFEF08A), const Color(0xFF0F172A), 3);
      _drawTextOutline(canvas, t('lbl_s4_already'), panelX, panelY + 30, 11, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('lbl_s4_eq1'), panelX, panelY + 50, 14, const Color(0xFF0F172A), Colors.transparent, 0);
    }

    _drawRoundedRect(canvas, -100, 180, 200, 80, 8, const Color(0xFFE2E8F0), const Color(0xFF0F172A), 4);
    _drawTextOutline(canvas, t('lbl_s3_bank'), 0, 200, 18, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawRoundedRect(canvas, -80, 215, 160, 35, 4, const Color(0xFF1E293B), const Color(0xFF0F172A), 3);
    Color balColor = balance < 0 ? const Color(0xFFEF4444) : (balance == 0 ? const Color(0xFF4ADE80) : const Color(0xFFF8FAFC));
    _drawTextOutline(canvas, balance < 0 ? "-₹${balance.abs()}" : "₹$balance", 0, 235, 22, balColor, Colors.transparent, 0);

    if (step >= 1) {
      double whitePx = -300; double whitePy = 150;
      _drawRoundedRect(canvas, whitePx - 60, whitePy, 120, 15, 4, const Color(0xFFB45309), const Color(0xFF0F172A), 3);
      for(int r=0; r<3; r++) { for(int c=0; c<2; c++) { _drawCementBag(canvas, whitePx - 30 + c*60, whitePy - 10 - r*30, 'white'); } }
      
      if (step == 1 && activeSlider == null && activeDragEntity != 'whiteBag') {
        _drawRoundedRect(canvas, whitePx - 80, whitePy - 100, 160, 130, 8, Colors.transparent, const Color(0xFF6366F1), 4);
        _drawTextOutline(canvas, t('lbl_drag'), whitePx, whitePy - 120, 16, const Color(0xFF38BDF8), Colors.transparent, 0);
      }

      double counterX = 300; double counterY = 180;
      _drawRoundedRect(canvas, counterX - 80, counterY, 160, 80, 8, const Color(0xFFE2E8F0), const Color(0xFF0F172A), 4);
      _drawTextOutline(canvas, t('lbl_s4_counter'), counterX, counterY + 20, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawRoundedRect(canvas, counterX - 70, counterY + 35, 140, 35, 4, const Color(0xFF1E293B), const Color(0xFF0F172A), 3);
      int bagCount = activeSlider != null ? activeSlider!.val : (step >= 2 ? 4000 : 0);
      _drawTextOutline(canvas, bagCount.toString(), counterX, counterY + 55, 22, const Color(0xFF38BDF8), Colors.transparent, 0);
      
      if (step == 1 && activeSlider != null) {
        var sdr = activeSlider!;
        _drawRoundedRect(canvas, sdr.x, sdr.y, sdr.w, 20, 10, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 4);
        double fillW = (sdr.val / sdr.max) * sdr.w;
        _drawRoundedRect(canvas, sdr.x, sdr.y, fillW, 20, 10, const Color(0xFF4ADE80), const Color(0xFF0F172A), 4);
        double hx = sdr.x + fillW;
        _drawRoundedRect(canvas, hx - 15, sdr.y - 15, 30, 50, 8, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 4);
        _drawTextOutline(canvas, sdr.val.toString(), hx, sdr.y - 25, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      }
    }

    if (step >= 2) {
      _drawRoundedRect(canvas, 0, -220, 360, 100, 10, const Color(0xFFDCFCE7), const Color(0xFF166534), 5);
      _drawTextOutline(canvas, t('lbl_s4_achieved'), 180, -180, 24, const Color(0xFF166534), Colors.transparent, 0);
      
      canvas.drawPath(Path()..moveTo(90, -135)..lineTo(75, -110)..lineTo(110, -120)..close(), Paint()..color=const Color(0xFFF59E0B));
      canvas.drawPath(Path()..moveTo(90, -135)..lineTo(75, -110)..lineTo(110, -120)..close(), Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawPath(Path()..moveTo(270, -135)..lineTo(285, -110)..lineTo(250, -120)..close(), Paint()..color=const Color(0xFFF59E0B));
      canvas.drawPath(Path()..moveTo(270, -135)..lineTo(285, -110)..lineTo(250, -120)..close(), Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=3);
      
      _drawRoundedRect(canvas, 100, -150, 160, 40, 20, const Color(0xFFFBBF24), const Color(0xFF0F172A), 4);
      _drawTextOutline(canvas, t('lbl_s4_success'), 180, -130, 18, Colors.white, Colors.transparent, 0);
      
      _drawRoundedRect(canvas, 100, -90, 260, 80, 8, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 3);
      _drawTextOutline(canvas, t('lbl_s4_result'), 230, -60, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('lbl_s4_eq2'), 230, -40, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('lbl_s4_eq3'), 230, -20, 16, const Color(0xFF0F172A), Colors.transparent, 0);

      // Add Done Button for Scenario 4
      _drawRoundedRect(canvas, 100, 10, 160, 50, 25, const Color(0xFF16A34A), const Color(0xFF0F172A), 4);
      _drawTextOutline(canvas, t('doneBtn'), 180, 35, 20, Colors.white, Colors.transparent, 0);
    }
  }

  void _renderScenario5(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-2000, -1500, 4000, 3000), Paint()..color=const Color(0xFFBAE6FD));
    canvas.drawCircle(const Offset(-500, -300), 80, Paint()..color=const Color(0xFFFEF08A));
    for(int i=0; i<12; i++) {
      double angle = (i * pi) / 6;
      canvas.drawLine(Offset(-500 + cos(angle)*100, -300 + sin(angle)*100), Offset(-500 + cos(angle)*130, -300 + sin(angle)*130), Paint()..color=const Color(0xFFFDE047)..strokeWidth=8);
    }
    canvas.drawPath(Path()..moveTo(-800, 300)..lineTo(-300, -200)..lineTo(100, 300)..close(), Paint()..color=const Color(0xFF94A3B8));
    canvas.drawPath(Path()..moveTo(-200, 300)..lineTo(300, -100)..lineTo(800, 300)..close(), Paint()..color=const Color(0xFFCBD5E1));
    canvas.drawPath(Path()..moveTo(-300, -200)..lineTo(-380, -120)..lineTo(-320, -100)..lineTo(-280, -130)..lineTo(-230, -100)..lineTo(-220, -120)..close(), Paint()..color=const Color(0xFFF8FAFC));
    canvas.drawPath(Path()..moveTo(300, -100)..lineTo(250, -50)..lineTo(300, -30)..lineTo(330, -60)..lineTo(360, -40)..close(), Paint()..color=const Color(0xFFF8FAFC));
    canvas.drawRect(const Rect.fromLTWH(-2000, 200, 4000, 1000), Paint()..color=const Color(0xFFBBF7D0));
    
    void drawTree(double x, double y) {
      canvas.drawPath(Path()..moveTo(x,y-60)..lineTo(x-30,y)..lineTo(x+30,y)..close(), Paint()..color=const Color(0xFF166534));
      canvas.drawPath(Path()..moveTo(x,y-100)..lineTo(x-25,y-40)..lineTo(x+25,y-40)..close(), Paint()..color=const Color(0xFF166534));
    }
    drawTree(-500, 250); drawTree(-400, 280); drawTree(500, 220); drawTree(600, 260);

    double thX = -300; double thY = 0;
    _drawRoundedRect(canvas, thX - 45, thY - 220, 90, 450, 45, const Color(0xB3FFFFFF), const Color(0xFF0F172A), 5);
    canvas.drawCircle(Offset(thX, thY + 180), 60, Paint()..color=const Color(0xB3FFFFFF));
    canvas.drawCircle(Offset(thX, thY + 180), 60, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=5);
    canvas.drawCircle(Offset(thX, thY + 180), 45, Paint()..color=const Color(0xFFEF4444));
    
    double tempY = -temp * 8; 
    _drawRoundedRect(canvas, thX - 20, thY + tempY, 40, 180 - tempY, 20, const Color(0xFFEF4444), Colors.transparent, 0);
    
    for(int tVal = -20; tVal <= 20; tVal += 5) {
      double ty = thY - (tVal * 8);
      canvas.drawLine(Offset(thX + 45, ty), Offset(thX + 65, ty), Paint()..color=const Color(0xFF0F172A)..strokeWidth=4);
      _drawTextOutline(canvas, "$tVal°C", thX + 100, ty, 18, const Color(0xFF0F172A), const Color(0xFFF8FAFC), 4);
    }
    
    _drawRoundedRect(canvas, thX + 160, thY - temp*8 - 35, 120, 70, 10, const Color(0xFF0F172A), const Color(0xFF0F172A), 4);
    _drawTextOutline(canvas, "${temp.toInt()}°C", thX + 220, thY - temp*8, 32, const Color(0xFF4ADE80), Colors.transparent, 0);

    if (step == 0 && !animating && activeDragEntity != 'thermoCap') {
      _drawRoundedRect(canvas, thX - 40, thY + tempY - 10, 80, 20, 10, Colors.transparent, const Color(0xFF6366F1), 4);
      _drawTextOutline(canvas, t('lbl_drag'), thX - 80, thY + tempY, 16, const Color(0xFF38BDF8), Colors.transparent, 0);
    }

    if (step >= 1) {
      double panelX = 150; double panelY = -50;
      
      _drawRoundedRect(canvas, panelX + 180, panelY, 140, 80, 10, const Color(0xFF0F172A), const Color(0xFF0F172A), 5);
      _drawTextOutline(canvas, "$hours ${t('lbl_s5_hr')}", panelX + 250, panelY + 40, 36, const Color(0xFF38BDF8), Colors.transparent, 0);
      
      if (step == 1) {
        Color btnColor = animating ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
        _drawRoundedRect(canvas, panelX - 30, panelY, 190, 80, 10, btnColor, const Color(0xFF0F172A), 5);
        _drawTextOutline(canvas, t('lbl_s5_next'), panelX + 65, panelY + 40, 22, const Color(0xFFF8FAFC), Colors.transparent, 0);
        if (!animating) _drawRoundedRect(canvas, panelX - 35, panelY - 5, 200, 90, 14, Colors.transparent, const Color(0xFFFACC15), 4);
      }

      if (step >= 2) {
        _drawRoundedRect(canvas, panelX - 50, panelY + 120, 420, 140, 10, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 5);
        _drawTextOutline(canvas, t('lbl_s5_final_temp'), panelX + 160, panelY + 155, 22, const Color(0xFF0F172A), Colors.transparent, 0);
        _drawTextOutline(canvas, t('lbl_s5_eq1'), panelX + 160, panelY + 195, 18, const Color(0xFF0F172A), Colors.transparent, 0);
        _drawTextOutline(canvas, t('lbl_s5_eq2'), panelX + 160, panelY + 230, 18, const Color(0xFF0F172A), Colors.transparent, 0);

        // Add Done Button for Scenario 5
        _drawRoundedRect(canvas, panelX + 80, panelY + 280, 160, 50, 25, const Color(0xFF16A34A), const Color(0xFF0F172A), 4);
        _drawTextOutline(canvas, t('doneBtn'), panelX + 160, panelY + 305, 20, Colors.white, Colors.transparent, 0);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RealWorldIntegersPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA (EN, HI, TE)
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'appTitle': "Real-World Integer Problem Solving", 'appSubtitle': "Class 7 • OPERATIONS WITH INTEGERS", 'enterLab': "Enter Simulation",
    'settings': "Settings", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'boardFontSize': "Text Size", 
    'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done",
    'learnLbl': "Observations:", 'closeBtn': "Close", 'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset", 'finishLab': "Finish Lab", 'nextScenario': "Next Scenario",
    'labCompleted': "Lab Completed!", 'finalDesc': "You have successfully modeled real-world problems using integer operations!",
    
    'lbl_s1_startPos': "Starting Position:", 'lbl_s1_rate': "Descent Rate: -3 m/min", 'lbl_s1_start': "START\nDESCENT",
    'lbl_s1_eq1': "45 minutes × (-3 m/minute)\n= -135 meters", 'lbl_s1_eq2': "Final Position = Starting Position + Distance\n(-120m) = (+15m) + (-135m)",
    'lbl_s1_solved': "Challenge\nSolved!", 'lbl_s1_ground': "Ground Level",
    'lbl_s2_score': "EXAM SCORE", 'lbl_s2_correct': "Correct Answer: +5\n30 × (+5) = 150", 'lbl_s2_wrong': "Wrong Answer: -2\n20 × (-2) = -40",
    'lbl_s2_30x': "30x Multiplier", 'lbl_s2_20x': "20x Multiplier", 'lbl_s2_eq': "Total Score = (30 × 5) + (20 × -2) = 110",
    'lbl_s3_inv': "INVENTORY", 'lbl_s3_white': "White (+₹8)", 'lbl_s3_grey': "Grey (-₹5)",
    'lbl_s3_bank': "BANK BALANCE", 'lbl_s3_truck': "SALES TRUCK", 'lbl_s3_bags': "Bags",
    'lbl_s4_loss': "CALCULATE LOSS", 'lbl_s5_time': "TIME ELAPSED", 'lbl_s5_hr': "HR", 'lbl_s5_next': "NEXT HOUR",
    
    'lbl_drag': "DRAG", 'lbl_calc': "CALCULATION:", 'lbl_s4_already': "Already sold 6,400 grey cement bags:",
    'lbl_s4_eq1': "6,400 x (-5) = -32,000", 'lbl_s4_counter': "Bag Counter 🔒", 'lbl_s4_achieved': "BREAK-EVEN ACHIEVED!",
    'lbl_s4_success': "SUCCESS", 'lbl_s4_result': "Result revealed:", 'lbl_s4_eq2': "(-32000) + (? x 8) = 0",
    'lbl_s4_eq3': "-> ? = 4,000 bags", 'lbl_s5_final_temp': "FINAL TEMPERATURE: -12°C", 'lbl_white_short': "WHITE",
    'lbl_grey_short': "GREY", 'lbl_s5_eq1': "8 + (-5) + (-5) + (-5) + (-5) = -12", 'lbl_s5_eq2': "8 + (4 × -5) = 8 - 20 = -12",
    'infoNextScen': "Please select the next scenario from the dropdown above.",

    's1_title': "1. The Mining Elevator's Descent", 's1_obj': "To calculate the final position of an elevator that starts above ground and descends for a specific duration.",
    's1_step1_task': "The elevator starts 15m above the ground. DRAG the elevator cab from its default position to the '+15m' mark on the vertical number line representing the mine shaft.",
    's1_step1_out': "The elevator cab is positioned at the '+15' mark on the number line.",
    's1_step2_task': "The elevator descends at a rate of 3 meters per minute. The journey lasts for 45 minutes. CLICK the 'Start Descent' button on the control panel.",
    's1_step2_out': "The elevator begins its animated descent.",
    's1_step3_task': "Observe the elevator's movement. A display shows the total distance to be travelled: 45 minutes × (-3 m/minute) = -135 meters.",
    's1_step3_out': "The elevator animates moving down the shaft from +15m. It passes 0m and continues downwards.",
    's1_step4_task': "The elevator comes to a stop. Observe its final position on the number line.",
    's1_step4_out': "The elevator stops at the -120m mark.",
    's1_sum': "<b>Final Position = Starting Position + Distance</b><br/>(-120) = (+15) + (-135)",
    's1_hud1': "Drag the elevator to the +15m mark.", 's1_hud2': "Click 'Start Descent' on the control panel.", 's1_hud3': "Observe the elevator descending.", 's1_hud4': "Note the final calculated position.",

    's2_title': "2. Mala's Exam Score", 's2_obj': "To calculate a student's total marks in an exam with positive marking for correct answers and negative marking for wrong answers.",
    's2_step1_task': "The scoring rule is +5 for a correct answer and -2 for a wrong answer. Mala had 30 correct answers. DRAG the 'Correct Answer' stack to the '30x' multiplier area.",
    's2_step1_out': "30 icons representing correct answers appear, and the score updates to 30 × 5 = 150.",
    's2_step2_task': "Mala also had 20 wrong answers. DRAG the 'Wrong Answer' stack to the '20x' multiplier area.",
    's2_step2_out': "20 icons representing wrong answers appear, and the score updates from 150 by -40.",
    's2_step3_task': "Observe the final score on the counter.",
    's2_step3_out': "The final score displayed is 110.",
    's2_sum': "<b>Total Score = (30 × 5) + (20 × -2)</b><br/>= 150 - 40 = 110",
    's2_hud1': "Drag the Correct Answer stack to 30x.", 's2_hud2': "Drag the Wrong Answer stack to 20x.", 's2_hud3': "Observe the final tallied score.",

    's3_title': "3. Profit & Loss", 's3_obj': "To calculate a company's net profit or loss after selling two types of products.",
    's3_step1_task': "The company earns ₹8 profit per bag of white cement. DRAG the 'White Cement Bag' onto the sales truck. Use the slider to set the quantity to 3,000.",
    's3_step1_out': "The company's bank balance increases to ₹24,000.",
    's3_step2_task': "Now, account for the loss of ₹5 per bag of grey cement. DRAG the 'Grey Cement Bag' onto the sales truck and set the quantity to 5,000.",
    's3_step2_out': "The company's bank balance decreases by ₹25,000.",
    's3_step3_task': "Observe the final bank balance to determine the company's net result.",
    's3_step3_out': "The final balance is -₹1,000, indicating a loss.",
    's3_sum': "<b>Net = (3000 × 8) + (5000 × -5)</b><br/>= 24000 - 25000 = -1000",
    's3_hud1': "Drag white bag to truck, then use slider to add 3,000 bags.", 's3_hud2': "Drag grey bag to truck, then use slider to add 5,000 bags.", 's3_hud3': "Note the final bank balance calculation.",

    's4_title': "4. The Break-Even Challenge", 's4_obj': "To find the number of white cement bags the company must sell to offset the loss from selling a fixed number of grey cement bags.",
    's4_step1_task': "The company has already sold 6,400 bags of grey cement. CLICK the 'Calculate Loss' button to see the starting financial position.",
    's4_step1_out': "The bank balance updates to show a loss of ₹32,000.",
    's4_step2_task': "Your mission is to reach a balance of ₹0 (break-even). DRAG a white cement bag to the truck, then use the slider to add bags until the bank balance reaches exactly ₹0.",
    's4_step2_out': "The user successfully adds white cement bags until the balance is ₹0.",
    's4_step3_task': "Once the balance is ₹0, check the counter to see how many bags of white cement were needed.",
    's4_step3_out': "The counter shows that 4,000 bags of white cement were required.",
    's4_sum': "Since <b>(-32000) + (? × 8) = 0</b>,<br/>? = 32000 ÷ 8 = 4000 bags.",
    's4_hud1': "Click the 'Calculate Loss' button.", 's4_hud2': "Drag white bag to truck, use slider until balance is ₹0.", 's4_hud3': "Observe the total bags needed to break-even.",

    's5_title': "5. Mountain Climate Challenge", 's5_obj': "To determine the final temperature on a mountain after a series of hourly drops.",
    's5_step1_task': "The temperature on the mountain is currently 8°C. DRAG the mercury level on the giant thermometer to set the starting temperature to 8°C.",
    's5_step1_out': "The thermometer is set to 8°C.",
    's5_step2_task': "The forecast predicts the temperature will drop by 5°C every hour for the next 4 hours. CLICK the 'Next Hour' button 4 times to simulate the change.",
    's5_step2_out': "The user clicks the button four times, and the temperature drops accordingly with each click.",
    's5_step3_task': "Read the final temperature from the thermometer after 4 hours have passed.",
    's5_step3_out': "The user identifies the final temperature as -12°C.",
    's5_sum': "<b>8 + (4 × -5) = 8 - 20 = -12°C.</b>",
    's5_hud1': "Drag thermometer level to 8°C.", 's5_hud2': "Click 'Next Hour' 4 times.", 's5_hud3': "Note the final mountain temperature."
  },
  'hi': {
    'appTitle': "वास्तविक दुनिया की समस्याएं", 'appSubtitle': "कक्षा 7 • पूर्णांकों के साथ संचालन", 'enterLab': "सिमुलेशन दर्ज करें",
    'settings': "सेटिंग्स", 'theme': "थीम", 'darkMode': "डार्क मोड", 'lightMode': "लाइट मोड", 'boardFontSize': "टेक्स्ट आकार", 
    'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण",
    'learnLbl': "अवलोकन:", 'closeBtn': "बंद करें", 'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट", 'finishLab': "समाप्त करें", 'nextScenario': "अगला परिदृश्य",
    'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने पूर्णांक संचालन का उपयोग करके वास्तविक दुनिया की समस्याओं को सफलतापूर्वक तैयार किया है!",
    
    'lbl_s1_startPos': "प्रारंभिक स्थिति:", 'lbl_s1_rate': "उतरने की दर: -3 m/min", 'lbl_s1_start': "उतरना\nशुरू करें",
    'lbl_s1_eq1': "45 मिनट × (-3 m/मिनट)\n= -135 मीटर", 'lbl_s1_eq2': "अंतिम स्थिति = प्रारंभिक स्थिति + दूरी\n(-120m) = (+15m) + (-135m)",
    'lbl_s1_solved': "चुनौती हल\nहो गई!", 'lbl_s1_ground': "जमीनी स्तर",
    'lbl_s2_score': "परीक्षा स्कोर", 'lbl_s2_correct': "सही उत्तर: +5\n30 × (+5) = 150", 'lbl_s2_wrong': "गलत उत्तर: -2\n20 × (-2) = -40",
    'lbl_s2_30x': "30x गुणक", 'lbl_s2_20x': "20x गुणक", 'lbl_s2_eq': "कुल स्कोर = (30 × 5) + (20 × -2) = 110",
    'lbl_s3_inv': "माल सूची", 'lbl_s3_white': "सफेद (+₹8)", 'lbl_s3_grey': "ग्रे (-₹5)",
    'lbl_s3_bank': "बैंक बैलेंस", 'lbl_s3_truck': "बिक्री ट्रक", 'lbl_s3_bags': "बैग",
    'lbl_s4_loss': "नुकसान की गणना करें", 'lbl_s5_time': "बीता हुआ समय", 'lbl_s5_hr': "घंटा", 'lbl_s5_next': "अगला घंटा",
    
    'lbl_drag': "खींचें", 'lbl_calc': "गणना:", 'lbl_s4_already': "पहले ही 6,400 ग्रे सीमेंट बैग बेचे जा चुके हैं:",
    'lbl_s4_eq1': "6,400 x (-5) = -32,000", 'lbl_s4_counter': "बैग काउंटर 🔒", 'lbl_s4_achieved': "ब्रेक-ईवन प्राप्त हुआ!",
    'lbl_s4_success': "सफलता", 'lbl_s4_result': "परिणाम:", 'lbl_s4_eq2': "(-32000) + (? x 8) = 0",
    'lbl_s4_eq3': "-> ? = 4,000 बैग", 'lbl_s5_final_temp': "अंतिम तापमान: -12°C", 'lbl_white_short': "सफेद",
    'lbl_grey_short': "ग्रे", 'lbl_s5_eq1': "8 + (-5) + (-5) + (-5) + (-5) = -12", 'lbl_s5_eq2': "8 + (4 × -5) = 8 - 20 = -12",
    'infoNextScen': "कृपया ऊपर दिए गए ड्रॉपडाउन से अगला परिदृश्य चुनें।",

    's1_title': "1. खनन लिफ्ट का उतरना", 's1_obj': "एक लिफ्ट की अंतिम स्थिति की गणना करना जो जमीन से ऊपर शुरू होती है और नीचे उतरती है।",
    's1_step1_task': "लिफ्ट जमीन से 15 मीटर ऊपर शुरू होती है। लिफ्ट कैब को '+15m' निशान पर खींचें।",
    's1_step1_out': "लिफ्ट +15 पर स्थित है।",
    's1_step2_task': "लिफ्ट 3 मीटर/मिनट की दर से उतरती है। नियंत्रण कक्ष पर बटन पर क्लिक करें।",
    's1_step2_out': "लिफ्ट नीचे उतरना शुरू करती है।",
    's1_step3_task': "लिफ्ट की गति का निरीक्षण करें।",
    's1_step3_out': "लिफ्ट नीचे की ओर एनिमेट होती है।",
    's1_step4_task': "लिफ्ट रुक जाती है। इसकी अंतिम स्थिति का निरीक्षण करें।",
    's1_step4_out': "लिफ्ट -120m के निशान पर रुकती है।",
    's1_sum': "<b>अंतिम स्थिति = प्रारंभिक स्थिति + दूरी</b><br/>(-120) = (+15) + (-135)",
    's1_hud1': "लिफ्ट को +15m पर खींचें।", 's1_hud2': "'उतरना शुरू करें' पर क्लिक करें।", 's1_hud3': "उतरने का निरीक्षण करें।", 's1_hud4': "अंतिम स्थिति नोट करें।",

    's2_title': "2. माला का परीक्षा स्कोर", 's2_obj': "सही उत्तरों के लिए सकारात्मक अंकन और गलत उत्तरों के लिए नकारात्मक अंकन के साथ एक छात्र के कुल अंकों की गणना करना।",
    's2_step1_task': "सही उत्तर के लिए +5 और गलत उत्तर के लिए -2 है। माला के 30 सही उत्तर थे। सही उत्तर आइकन को 30x स्लॉट में खींचें।",
    's2_step1_out': "स्कोर 150 पर अपडेट होता है।",
    's2_step2_task': "माला के 20 गलत उत्तर भी थे। गलत उत्तर आइकन को 20x स्लॉट में खींचें।",
    's2_step2_out': "स्कोर 150 से -40 (20 x -2) तक अपडेट होता है।",
    's2_step3_task': "काउंटर पर अंतिम स्कोर का निरीक्षण करें।",
    's2_step3_out': "अंतिम स्कोर 110 है।",
    's2_sum': "<b>कुल स्कोर = (30 × 5) + (20 × -2)</b><br/>= 150 - 40 = 110",
    's2_hud1': "सही उत्तर खींचें (30)।", 's2_hud2': "गलत उत्तर खींचें (20)।", 's2_hud3': "अंतिम स्कोर नोट करें।",

    's3_title': "3. लाभ और हानि", 's3_obj': "दो प्रकार के उत्पादों को बेचने के बाद कंपनी के शुद्ध लाभ या हानि की गणना करना।",
    's3_step1_task': "कंपनी सफेद सीमेंट के प्रति बैग ₹8 का लाभ कमाती है और 3,000 बैग बेचती है। सफेद बैग को ट्रक पर खींचें और स्लाइडर से 3,000 सेट करें।",
    's3_step1_out': "कंपनी का बैंक बैलेंस ₹24,000 हो जाता है।",
    's3_step2_task': "अब, बेचे गए 5,000 ग्रे सीमेंट बैग का हिसाब दें। ग्रे बैग को ट्रक पर खींचें और स्लाइडर से 5,000 सेट करें।",
    's3_step2_out': "बैंक बैलेंस में ₹25,000 की कमी होती है।",
    's3_step3_task': "कंपनी का शुद्ध परिणाम निर्धारित करने के लिए अंतिम बैंक बैलेंस का निरीक्षण करें।",
    's3_step3_out': "अंतिम शेष राशि -₹1,000 है, जो नुकसान का संकेत देती है।",
    's3_sum': "<b>शुद्ध = (3000 × 8) + (5000 × -5)</b><br/>= 24000 - 25000 = -1000",
    's3_hud1': "सफेद बैग को ट्रक पर खींचें, 3,000 बैग जोड़ें।", 's3_hud2': "ग्रे बैग को ट्रक पर खींचें, 5,000 बैग जोड़ें।", 's3_hud3': "अंतिम शेष नोट करें।",

    's4_title': "4. ब्रेक-ईवन चुनौती", 's4_obj': "कंपनी को शून्य नुकसान के लिए कितने सफेद सीमेंट बैग बेचने होंगे, यह पता लगाना।",
    's4_step1_task': "कंपनी ने ग्रे सीमेंट के 6,400 बैग बेचे हैं। वित्तीय स्थिति देखने के लिए बटन पर क्लिक करें।",
    's4_step1_out': "बैंक बैलेंस ₹32,000 का नुकसान दिखाता है।",
    's4_step2_task': "आपका मिशन ₹0 के बैलेंस तक पहुंचना है। सफेद सीमेंट बैग को ट्रक पर खींचें, फिर स्लाइडर का उपयोग करके तब तक बैग जोड़ें जब तक बैलेंस ₹0 न हो जाए।",
    's4_step2_out': "उपयोगकर्ता सफलतापूर्वक बैग जोड़ता है जब तक कि बैलेंस ₹0 न हो जाए।",
    's4_step3_task': "एक बार बैलेंस ₹0 हो जाने पर, काउंटर की जाँच करें।",
    's4_step3_out': "काउंटर दिखाता है कि 4,000 बैग की आवश्यकता थी।",
    's4_sum': "चूंकि <b>(-32000) + (? × 8) = 0</b>,<br/>? = 32000 ÷ 8 = 4000 बैग।",
    's4_hud1': "शुरुआती नुकसान की गणना करें।", 's4_hud2': "सफेद बैग को ट्रक पर खींचें, ₹0 बैलेंस तक स्लाइडर का उपयोग करें।", 's4_hud3': "ब्रेक-ईवन के लिए आवश्यक बैग नोट करें।",

    's5_title': "5. पर्वतीय जलवायु चुनौती", 's5_obj': "घंटे की बूंदों की श्रृंखला के बाद पहाड़ पर अंतिम तापमान का निर्धारण करना।",
    's5_step1_task': "पहाड़ पर तापमान 8°C है। पारा के स्तर को 8°C पर खींचें।",
    's5_step1_out': "थर्मामीटर 8°C पर सेट है।",
    's5_step2_task': "पूर्वानुमान है कि अगले 4 घंटों के लिए हर घंटे तापमान में 5°C की गिरावट आएगी। 'अगला घंटा' बटन पर 4 बार क्लिक करें।",
    's5_step2_out': "तापमान तदनुसार गिरता है।",
    's5_step3_task': "4 घंटे बीत जाने के बाद अंतिम तापमान पढ़ें।",
    's5_step3_out': "अंतिम तापमान -12°C है।",
    's5_sum': "<b>8 + (4 × -5) = 8 - 20 = -12°C.</b>",
    's5_hud1': "थर्मामीटर को 8°C पर सेट करें।", 's5_hud2': "'अगला घंटा' 4 बार क्लिक करें।", 's5_hud3': "अंतिम तापमान नोट करें।"
  }
};
