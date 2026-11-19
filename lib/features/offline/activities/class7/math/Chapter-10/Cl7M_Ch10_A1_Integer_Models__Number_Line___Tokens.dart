// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IntegerModelsApp());
}

class IntegerModelsApp extends StatelessWidget {
  const IntegerModelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Integer Models',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const IntegerModelsLab(),
    );
  }
}

class IntegerModelsLab extends StatefulWidget {
  const IntegerModelsLab({super.key});

  @override
  State<IntegerModelsLab> createState() => _IntegerModelsLabState();
}

class _IntegerModelsLabState extends State<IntegerModelsLab> with TickerProviderStateMixin {
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
  double _panY = 20;
  double _baseZoom = 1.0;
  Offset _basePan = Offset.zero;

  // Simulation State
  bool _toolDragging = false;
  String? _toolType;
  Offset _dragOffset = Offset.zero;
  double _mouseX = 0;
  double _mouseY = 0;

  // Scenario 1: Carrom Coin
  double _s1CoinTarget = 0;
  double _s1CoinPos = 0;
  bool _s1Arrow4 = false;
  bool _s1Arrow7 = false;

  // Scenario 2: Token Trader
  int _s2MatPos = 0;
  int _s2MatNeg = 0;
  int _s2ZeroPairs = 0;
  int _s2RemovedPos = 0;

  // Scenario 3: Token Factory
  double _s3State = 0; // 0: init, 0.5: infusing, 1: infused, 2: arm anim, 3: done
  double _s3InfuseProgress = 0;
  double _s3ArmExt = 0;
  int _s3GroupsRem = 0;

  // Scenario 4: Elevator
  double _s4ElevatorPos = 15;
  double _s4ElevatorTarget = 15;
  int _s4ErrorMsg = 0;

  // Scenario 5: Token Equation
  int _s5MatPos = 0;
  int _s5MatNeg = 0;

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
      if (_scenario == 1) {
        _s1CoinPos += (_s1CoinTarget - _s1CoinPos) * 0.1;
      } else if (_scenario == 3) {
        if (_s3State == 0.5) {
          _s3InfuseProgress += 0.05;
          if (_s3InfuseProgress >= 1.0) {
            _s3State = 1;
            _playSound('pop');
            _advanceStep();
          }
        } else if (_s3State == 2) {
          _s3ArmExt += 0.04;
          if (_s3ArmExt >= 2.0) {
            _s3ArmExt = 0;
            _s3GroupsRem++;
            _playSound('pop');
            if (_s3GroupsRem >= 4) {
              _s3State = 3;
              _playSound('success');
              _advanceStep();
            } else {
              _playSound('weld');
            }
          }
        }
      } else if (_scenario == 4) {
        _s4ElevatorPos += (_s4ElevatorTarget - _s4ElevatorPos) * 0.05;
        if (_s4ErrorMsg > 0) _s4ErrorMsg--;
      }
    });
  }

  void _playSound(String type) async {
    String url;
    switch (type) {
      case 'enter': url = 'audio/class7/mixkit_2568.mp3'; break;
      case 'pop': url = 'audio/class7/mixkit_268.mp3'; break;
      case 'success': url = 'audio/class7/mixkit_2018.mp3'; break;
      case 'error': url = 'audio/class7/mixkit_955.mp3'; break;
      case 'snap': case 'weld': url = 'audio/class7/mixkit_2568.mp3'; break;
      case 'tick': url = 'audio/class7/mixkit_2568.mp3'; break;
      default: return;
    }
    try {
      await _player.play(AssetSource(url), volume: 0.5);
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
      _zoom = 1.0;
      _panX = 0;
      _panY = 20;

      // Reset Simulation States
      _s1CoinTarget = 0; _s1CoinPos = 0; _s1Arrow4 = false; _s1Arrow7 = false;
      _s2MatPos = 0; _s2MatNeg = 0; _s2ZeroPairs = 0; _s2RemovedPos = 0;
      _s3State = 0; _s3InfuseProgress = 0; _s3ArmExt = 0; _s3GroupsRem = 0;
      _s4ElevatorPos = 15; _s4ElevatorTarget = 15; _s4ErrorMsg = 0;
      _s5MatPos = 0; _s5MatNeg = 0;
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _evaluateStepConditions() {
    if (_scenario == 5 && _step == 0) {
      if (_s5MatPos == 2 && _s5MatNeg == 8) {
        // Success condition met - UI button will appear
      }
    }
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    int totalSteps = (_scenario == 2) ? 4 : (_scenario == 4 || _scenario == 5 ? 1 : 3);
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

    if (_scenario == 1 && _step == 2) {
      if ((pt - const Offset(-3 * 32, 30)).distance < 80) {
        _playSound('success'); _checkScenarioSuccess();
      }
    } else if (_scenario == 2 && _step == 1) {
      if ((pt - const Offset(-380, -100)).distance < 120) {
        setState(() { _s2ZeroPairs++; });
        _playSound('pop');
        if (_s2ZeroPairs >= 11) _advanceStep();
      }
    } else if (_scenario == 5 && _step == 0) {
      // Expanded hitboxes for easier tapping
      if (Rect.fromLTWH(-450, -280, 220, 240).contains(pt)) { setState(() => _s5MatPos++); _playSound('pop'); _evaluateStepConditions(); }
      else if (Rect.fromLTWH(-450, -20, 220, 240).contains(pt)) { setState(() => _s5MatNeg++); _playSound('pop'); _evaluateStepConditions(); }
      else if (Rect.fromLTWH(-220, -260, 520, 160).contains(pt) && _s5MatPos > 0) { setState(() => _s5MatPos--); _playSound('pop'); _evaluateStepConditions(); }
      else if (Rect.fromLTWH(-220, -100, 520, 180).contains(pt) && _s5MatNeg > 0) { setState(() => _s5MatNeg--); _playSound('pop'); _evaluateStepConditions(); }
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (_scenario == 1) {
      if (_step == 0 && !_s1Arrow4 && (pt - const Offset(-70, 200)).distance < 100) {
        setState(() { _toolDragging = true; _toolType = 'arr4'; _dragOffset = const Offset(-70, 200) - pt; });
        _playSound('tick'); return;
      }
      if (_step == 1 && !_s1Arrow7 && (pt - const Offset(70, 200)).distance < 100) {
        setState(() { _toolDragging = true; _toolType = 'arr7'; _dragOffset = const Offset(70, 200) - pt; });
        _playSound('tick'); return;
      }
    } else if (_scenario == 2) {
      if (_step == 0 && (pt - const Offset(-320, 60)).distance < 120) {
        setState(() { _toolDragging = true; _toolType = 'stack7'; _dragOffset = const Offset(-320, 60) - pt; });
        _playSound('tick'); return;
      }
      if (_step == 2 && (pt - const Offset(50, 50)).distance < 300) {
        setState(() { _toolDragging = true; _toolType = 'stack18'; _dragOffset = const Offset(50, 50) - pt; });
        _playSound('tick'); return;
      }
    } else if (_scenario == 4) {
      if (_step == 0) {
        double boxX = -120, boxY = 80;
        List<double> arrows = [-45, -120, -135, 45, 135, 120];
        List<Offset> targets = [
          Offset(boxX + 50, boxY + 70), Offset(boxX + 130, boxY + 70), Offset(boxX + 210, boxY + 70),
          Offset(boxX + 50, boxY + 140), Offset(boxX + 130, boxY + 140), Offset(boxX + 210, boxY + 140)
        ];
        for (int i = 0; i < 6; i++) {
          if ((pt - targets[i]).distance < 50) {
            setState(() { _toolDragging = true; _toolType = 'arr_${arrows[i]}'; _dragOffset = targets[i] - pt; });
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
      if (!_toolDragging) {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.3, 2.0);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_toolDragging) {
      setState(() {
        if (_toolType == 'arr4') {
          if ((Offset(_mouseX + _dragOffset.dx, _mouseY + _dragOffset.dy) - Offset.zero).distance < 150) {
            _s1Arrow4 = true; _s1CoinTarget = 4; _playSound('snap'); _advanceStep();
          } else { _playSound('error'); }
        } else if (_toolType == 'arr7') {
          if ((Offset(_mouseX + _dragOffset.dx, _mouseY + _dragOffset.dy) - const Offset(4 * 32, 0)).distance < 150) {
            _s1Arrow7 = true; _s1CoinTarget = -3; _playSound('snap'); _advanceStep();
          } else { _playSound('error'); }
        } else if (_toolType == 'stack7') {
          if ((Offset(_mouseX + _dragOffset.dx, _mouseY + _dragOffset.dy) - const Offset(0, 50)).distance < 300) {
            _s2MatPos = 7; _playSound('snap'); _advanceStep();
          } else { _playSound('error'); }
        } else if (_toolType == 'stack18') {
          if ((Offset(_mouseX + _dragOffset.dx, _mouseY + _dragOffset.dy) - const Offset(380, 60)).distance < 200) {
            _s2MatPos -= 18; _s2RemovedPos += 18; _playSound('snap'); _advanceStep();
          } else { _playSound('error'); }
        } else if (_toolType != null && _toolType!.startsWith('arr_')) {
          double val = double.parse(_toolType!.split('_')[1]);
          if ((Offset(_mouseX, _mouseY) - Offset(0, -_s4ElevatorPos * 2.2)).distance < 200) {
            if (val == -135) {
              _playSound('snap');
              _s4ElevatorTarget = _s4ElevatorPos + val;
              _advanceStep();
              Future.delayed(const Duration(seconds: 2), () => _checkScenarioSuccess());
            } else {
              _s4ErrorMsg = 120;
              _playSound('error');
            }
          } else { _playSound('error'); }
        }
        _toolDragging = false;
        _toolType = null;
      });
    }
  }

  void _s3Infuse() {
    _playSound('weld');
    setState(() => _s3State = 0.5);
  }

  void _s3ActivateArm() {
    _playSound('weld');
    setState(() => _s3State = 2);
  }

  // --- UI Overlays (Mapping world coordinates to screen coords for Flutter Buttons) ---
  Widget _buildOverlayButton(String label, double worldX, double worldY, Color color, VoidCallback onTap, {IconData? icon}) {
    // Transform world to screen based on current pan and zoom
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    double screenX = sw / 2 + _panX + worldX * _zoom;
    double screenY = sh / 2 + _panY + worldY * _zoom;

    return Positioned(
      left: screenX - 100, // Approximate centering
      top: screenY - 25,
      child: Transform.scale(
        scale: _zoom.clamp(0.8, 1.2),
        child: ElevatedButton.icon(
          onPressed: () { _playSound('pop'); onTap(); },
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

  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);

    int totalSteps = (_scenario == 2) ? 4 : (_scenario == 4 || _scenario == 5 ? 1 : 3);

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
                        Row(children: [const Icon(Icons.my_location, color: Colors.pinkAccent, size: 18), const SizedBox(width: 8), Text(t('learnLbl'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold))]),
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
                  // Conclusion / Info box replacing removed buttons
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
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3))
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _scenario < 5 ? t('infoNextScen') : t('infoLabDone'),
                                    style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                                  )
                                )
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
                            painter: IntegerModelsPainter(
                              lang: _lang, scenario: _scenario, step: _step,
                              zoom: _zoom, panX: _panX, panY: _panY,
                              toolDragging: _toolDragging, toolType: _toolType, dragOffset: _dragOffset, mouseX: _mouseX, mouseY: _mouseY,
                              s1CoinPos: _s1CoinPos, s1Arrow4: _s1Arrow4, s1Arrow7: _s1Arrow7,
                              s2MatPos: _s2MatPos, s2MatNeg: _s2MatNeg, s2ZeroPairs: _s2ZeroPairs, s2RemovedPos: _s2RemovedPos,
                              s3State: _s3State, s3InfuseProgress: _s3InfuseProgress, s3ArmExt: _s3ArmExt, s3GroupsRem: _s3GroupsRem,
                              s4ElevatorPos: _s4ElevatorPos, s4ElevatorTarget: _s4ElevatorTarget, s4ErrorMsg: _s4ErrorMsg,
                              s5MatPos: _s5MatPos, s5MatNeg: _s5MatNeg,
                              t: t, screenSize: constraints.biggest
                            ),
                          ),
                          // Custom Action Buttons Overlay
                          if (_scenario == 2 && _step == 3 && _s2RemovedPos >= 18)
                            _buildOverlayButton(t('confirmBtn'), 0, 160, const Color(0xFF10B981), _checkScenarioSuccess, icon: Icons.check),
                          if (_scenario == 3 && _step == 0 && _s3State == 0)
                            _buildOverlayButton(t('infuseBtn'), 0, -20, Colors.indigo, _s3Infuse, icon: Icons.add_circle),
                          if (_scenario == 3 && _step == 1 && _s3State == 1)
                            _buildOverlayButton(t('activateBtn'), 0, -20, Colors.amber, _s3ActivateArm, icon: Icons.precision_manufacturing),
                          if (_scenario == 3 && _step == 2 && _s3State == 3)
                            _buildOverlayButton(t('finalizeBtn'), 0, 160, const Color(0xFF10B981), _checkScenarioSuccess, icon: Icons.check),
                          if (_scenario == 5 && _s5MatPos == 2 && _s5MatNeg == 8)
                            _buildOverlayButton(t('challengeComplete'), 160, 140, const Color(0xFF10B981), _checkScenarioSuccess, icon: Icons.stars),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),

            // HUD Overlays
            if (_step < ((_scenario == 2) ? 4 : (_scenario == 4 || _scenario == 5 ? 1 : 3)))
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
                        Container(width: 120, height: 120, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]), child: const Icon(Icons.calculate, size: 80, color: Colors.indigoAccent)),
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

class IntegerModelsPainter extends CustomPainter {
  final String lang; final int scenario; final int step;
  final double zoom; final double panX; final double panY;
  final bool toolDragging; final String? toolType; final Offset dragOffset; final double mouseX; final double mouseY;
  
  // Scenarios State
  final double s1CoinPos; final bool s1Arrow4; final bool s1Arrow7;
  final int s2MatPos; final int s2MatNeg; final int s2ZeroPairs; final int s2RemovedPos;
  final double s3State; final double s3InfuseProgress; final double s3ArmExt; final int s3GroupsRem;
  final double s4ElevatorPos; final double s4ElevatorTarget; final int s4ErrorMsg;
  final int s5MatPos; final int s5MatNeg;

  final Function(String) t;
  final Size screenSize;

  IntegerModelsPainter({
    required this.lang, required this.scenario, required this.step,
    required this.zoom, required this.panX, required this.panY,
    required this.toolDragging, required this.toolType, required this.dragOffset, required this.mouseX, required this.mouseY,
    required this.s1CoinPos, required this.s1Arrow4, required this.s1Arrow7,
    required this.s2MatPos, required this.s2MatNeg, required this.s2ZeroPairs, required this.s2RemovedPos,
    required this.s3State, required this.s3InfuseProgress, required this.s3ArmExt, required this.s3GroupsRem,
    required this.s4ElevatorPos, required this.s4ElevatorTarget, required this.s4ErrorMsg,
    required this.s5MatPos, required this.s5MatNeg,
    required this.t, required this.screenSize
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario != 4 && scenario != 5) {
      Paint gridPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1.0;
      for (double i = -3000; i < 3000; i += 40) {
        canvas.drawLine(Offset(i, -3000), Offset(i, 3000), gridPaint);
        canvas.drawLine(Offset(-3000, i), Offset(3000, i), gridPaint);
      }
    }

    if (scenario == 1) _drawScenario1(canvas);
    else if (scenario == 2) _drawScenario2(canvas);
    else if (scenario == 3) _drawScenario3(canvas);
    else if (scenario == 4) _drawScenario4(canvas);
    else if (scenario == 5) _drawScenario5(canvas);

    canvas.restore();
  }

  // --- Drawing Helpers ---
  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double strokeW = 1.0, bool dashed=false]) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) { canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill); }
    if (stroke != Colors.transparent && !dashed) { canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW); }
    if (stroke != Colors.transparent && dashed) { _drawDashedRRect(canvas, rect, stroke, strokeW); }
  }

  void _drawDashedRRect(Canvas canvas, RRect rect, Color color, double width) {
    Path path = Path()..addRRect(rect);
    Paint p = Paint()..color = color..strokeWidth = width..style = PaintingStyle.stroke;
    for (var metric in path.computeMetrics()) {
      double distance = 0; bool draw = true;
      while (distance < metric.length) {
        final length = 8.0;
        if (draw) canvas.drawPath(metric.extractPath(distance, distance + length), p);
        distance += length; draw = !draw;
      }
    }
  }

  void _drawTextOutline(Canvas canvas, String text, double x, double y, double fontSize, Color fill, Color outline, [double outlineW=3.5]) {
    TextPainter tpStroke = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans', foreground: Paint()..style=PaintingStyle.stroke..strokeWidth=outlineW..color=outline..strokeJoin=StrokeJoin.round)),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center
    );
    tpStroke.layout(); tpStroke.paint(canvas, Offset(x - tpStroke.width/2, y - tpStroke.height/2));
    TextPainter tpFill = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center
    );
    tpFill.layout(); tpFill.paint(canvas, Offset(x - tpFill.width/2, y - tpFill.height/2));
  }

  void _drawToken(Canvas canvas, double cx, double cy, bool isPos, [bool isHover = false]) {
    canvas.save(); canvas.translate(cx, cy);
    if(isHover) canvas.scale(1.1, 1.1);
    Color fill = isPos ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    Color stroke = const Color(0xFF0F172A);
    Color shadow = isPos ? const Color(0xFF166534) : const Color(0xFF991B1B);
    
    canvas.drawCircle(const Offset(0, 4), 18, Paint()..color=shadow..style=PaintingStyle.fill);
    canvas.drawCircle(const Offset(0, 4), 18, Paint()..color=stroke..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawCircle(const Offset(0, 0), 18, Paint()..color=fill..style=PaintingStyle.fill);
    canvas.drawCircle(const Offset(0, 0), 18, Paint()..color=stroke..style=PaintingStyle.stroke..strokeWidth=1);
    canvas.drawCircle(const Offset(0, 0), 12, Paint()..color=shadow..style=PaintingStyle.stroke..strokeWidth=1.5);
    
    _drawTextOutline(canvas, isPos?'+':'-', 0, 0, 24, stroke, Colors.transparent, 0);
    canvas.restore();
  }

  void _drawToolArrow(Canvas canvas, double val, double cx, double cy, [bool isHover=false]) {
    bool isPos = val > 0;
    double unitScale = 32;
    double len = val.abs() * unitScale;
    Color color = isPos ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    Color strokeCol = const Color(0xFF0F172A);
    Color shadowCol = isPos ? const Color(0xFF166534) : const Color(0xFF991B1B);

    if (scenario == 4) { // Vertical/Diagonal compact arrows
      double w = 16, h = 45;
      canvas.save(); canvas.translate(cx, cy);
      if(isHover) canvas.scale(1.1, 1.1);
      canvas.save();
      if(val == -45) canvas.rotate(pi/6);
      if(val == 135) canvas.rotate(pi/8);
      if(val == -135) canvas.rotate(-pi/12);

      Path path = Path();
      if (isPos) {
        path.moveTo(-w/2, h/2); path.lineTo(-w/2, -h/2+14); path.lineTo(-w-2, -h/2+14); path.lineTo(0, -h/2); path.lineTo(w+2, -h/2+14); path.lineTo(w/2, -h/2+14); path.lineTo(w/2, h/2);
      } else {
        path.moveTo(-w/2, -h/2); path.lineTo(-w/2, h/2-14); path.lineTo(-w-2, h/2-14); path.lineTo(0, h/2); path.lineTo(w+2, h/2-14); path.lineTo(w/2, h/2-14); path.lineTo(w/2, -h/2);
      }
      path.close();
      
      canvas.save(); canvas.translate(2, 2); canvas.drawPath(path, Paint()..color=shadowCol..style=PaintingStyle.fill); canvas.drawPath(path, Paint()..color=strokeCol..style=PaintingStyle.stroke..strokeWidth=2.5); canvas.restore();
      canvas.drawPath(path, Paint()..color=color..style=PaintingStyle.fill); canvas.drawPath(path, Paint()..color=strokeCol..style=PaintingStyle.stroke..strokeWidth=2.5);
      canvas.restore(); // rotation
      
      _drawTextOutline(canvas, "${isPos?'+':''}${val.toInt()}", 0, 0, 14, Colors.white, strokeCol, 4);
      canvas.restore();
      return;
    }

    // Normal S1 arrows
    canvas.save(); canvas.translate(cx, cy);
    if(isHover) canvas.scale(1.05, 1.05);
    double w = len, h = 24, headW = 20, headL = 20;
    Path path = Path();
    if(isPos) {
      path.moveTo(0, -h/2); path.lineTo(w - headL, -h/2); path.lineTo(w - headL, -h/2 - headW/2); path.lineTo(w, 0); path.lineTo(w - headL, h/2 + headW/2); path.lineTo(w - headL, h/2); path.lineTo(0, h/2);
    } else {
      path.moveTo(0, -h/2); path.lineTo(-w + headL, -h/2); path.lineTo(-w + headL, -h/2 - headW/2); path.lineTo(-w, 0); path.lineTo(-w + headL, h/2 + headW/2); path.lineTo(-w + headL, h/2); path.lineTo(0, h/2);
    }
    path.close();

    canvas.save(); canvas.translate(0, 6); canvas.drawPath(path, Paint()..color=shadowCol..style=PaintingStyle.fill); canvas.drawPath(path, Paint()..color=strokeCol..style=PaintingStyle.stroke..strokeWidth=2.5); canvas.restore();
    canvas.drawPath(path, Paint()..color=color..style=PaintingStyle.fill); canvas.drawPath(path, Paint()..color=strokeCol..style=PaintingStyle.stroke..strokeWidth=2.5);
    
    double textX = isPos ? w/2 - 5 : -w/2 + 5;
    _drawTextOutline(canvas, "${isPos?'+':''}${val.toInt()}", textX, 0, 20, const Color(0xFF0F172A), Colors.transparent, 0);
    canvas.restore();
  }

  void _drawCarromCoin(Canvas canvas, double cx, double cy) {
    canvas.save(); canvas.translate(cx, cy);
    canvas.drawCircle(const Offset(0, 4), 24, Paint()..color=Colors.black54..maskFilter=const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawCircle(Offset.zero, 24, Paint()..color=const Color(0xFFFDE047));
    canvas.drawCircle(Offset.zero, 24, Paint()..color=const Color(0xFFCA8A04)..style=PaintingStyle.stroke..strokeWidth=3);
    canvas.drawCircle(Offset.zero, 16, Paint()..color=const Color(0xFFD97706)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawCircle(Offset.zero, 8, Paint()..color=const Color(0xFFEF4444));
    canvas.restore();
  }

  void _drawElevator(Canvas canvas, double cx, double cy, bool glowing) {
    canvas.save(); canvas.translate(cx, cy);
    if(glowing) _drawRoundedRect(canvas, -45, -45, 90, 90, 8, const Color(0x664ADE80), Colors.transparent);
    
    canvas.drawLine(const Offset(0,-200), const Offset(0,-40), Paint()..color=const Color(0xFF475569)..strokeWidth=6);
    _drawRoundedRect(canvas, -40, -40, 80, 80, 8, const Color(0xFFCBD5E1), const Color(0xFF0F172A), 4);
    canvas.drawLine(const Offset(0,-35), const Offset(0,35), Paint()..color=const Color(0xFF0F172A)..strokeWidth=2);
    _drawRoundedRect(canvas, -30, -30, 25, 60, 2, const Color(0xFF94A3B8), const Color(0xFF0F172A), 2);
    _drawRoundedRect(canvas, 5, -30, 25, 60, 2, const Color(0xFF94A3B8), const Color(0xFF0F172A), 2);
    _drawRoundedRect(canvas, -25, -25, 15, 30, 2, const Color(0xFF7DD3FC), Colors.transparent);
    _drawRoundedRect(canvas, 10, -25, 15, 30, 2, const Color(0xFF7DD3FC), Colors.transparent);
    _drawRoundedRect(canvas, -20, -50, 40, 10, 4, const Color(0xFF4ADE80), const Color(0xFF166534), 2);
    canvas.restore();
  }

  void _drawGear(Canvas canvas, double cx, double cy, double r, int teeth, Color color) {
    canvas.save(); canvas.translate(cx, cy);
    Path p = Path();
    for(int i=0; i<teeth*2; i++) {
      double angle = (i * pi) / teeth;
      double radius = (i % 2 == 0) ? r : r + 10;
      if(i==0) p.moveTo(cos(angle)*radius, sin(angle)*radius);
      else p.lineTo(cos(angle)*radius, sin(angle)*radius);
    }
    p.close(); canvas.drawPath(p, Paint()..color=color);
    canvas.drawCircle(Offset.zero, r/2, Paint()..color=const Color(0xFF1E293B));
    canvas.restore();
  }

  // --- Scenario Painters ---
  void _drawScenario1(Canvas canvas) {
    _drawRoundedRect(canvas, -460, -260, 920, 560, 24, const Color(0xFF334155), const Color(0xFF0F172A), 16);
    _drawRoundedRect(canvas, -440, -240, 880, 520, 12, const Color(0xFFD97706), const Color(0xFF92400E), 4);
    
    Paint decoLine = Paint()..color=Colors.white38..strokeWidth=4..style=PaintingStyle.stroke;
    canvas.drawCircle(Offset.zero, 120, decoLine);
    for(var o in [const Offset(-350,-150), const Offset(350,-150), const Offset(-350,150), const Offset(350,150)]) { canvas.drawCircle(o, 40, decoLine); }
    canvas.drawLine(const Offset(-400,-200), const Offset(-320,-120), decoLine);
    canvas.drawLine(const Offset(400,-200), const Offset(320,-120), decoLine);
    canvas.drawLine(const Offset(-400,200), const Offset(-320,120), decoLine);
    canvas.drawLine(const Offset(400,200), const Offset(320,120), decoLine);

    canvas.save(); canvas.translate(0, 40);
    canvas.drawLine(const Offset(-350,0), const Offset(350,0), Paint()..color=Colors.white..strokeWidth=4);
    for(int i=-10; i<=10; i++) {
      double lx = i * 32.0;
      canvas.drawLine(Offset(lx, -10), Offset(lx, 10), Paint()..color=Colors.white..strokeWidth=3);
      Color fColor = Colors.white;
      if (step == 2 && i == -3) {
        canvas.drawCircle(Offset(lx, 0), 30, Paint()..color=const Color(0xFFFEF08A)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 10));
        fColor = const Color(0xFFF59E0B);
      }
      _drawTextOutline(canvas, i.toString(), lx, 30, 18, fColor, const Color(0xFF0F172A), 4);
    }

    if (s1Arrow4) _drawToolArrow(canvas, 4, 0, -30);
    if (s1Arrow7) _drawToolArrow(canvas, -7, 4*32, -60);
    _drawCarromCoin(canvas, s1CoinPos * 32, 0);
    canvas.restore();

    _drawRoundedRect(canvas, -250, -230, 500, 90, 12, const Color(0xFF94A3B8), const Color(0xFF0F172A), 8);
    _drawRoundedRect(canvas, -240, -220, 480, 70, 8, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 4);
    
    double eqY = -180;
    _drawTextOutline(canvas, "(", -130, eqY, 42, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawTextOutline(canvas, "+4", -80, eqY, 42, const Color(0xFF16A34A), Colors.transparent, 0);
    _drawTextOutline(canvas, ") + (", -10, eqY, 42, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawTextOutline(canvas, "-7", 60, eqY, 42, const Color(0xFFDC2626), Colors.transparent, 0);
    _drawTextOutline(canvas, ") = ${step>=3?"-3":"?"}", 140, eqY, 42, const Color(0xFF0F172A), Colors.transparent, 0);

    double tbW = 280, tbH = 100, tbX = -tbW/2, tbY = 140;
    _drawRoundedRect(canvas, tbX, tbY, tbW, tbH, 16, const Color(0xFFD97706), const Color(0xFF0F172A), 6);
    _drawRoundedRect(canvas, tbX+10, tbY+10, tbW-20, tbH-20, 12, const Color(0xFF78350F), const Color(0xFF0F172A), 4);
    _drawTextOutline(canvas, t('toolbox'), 0, tbY+25, 16, Colors.white, Colors.transparent, 0);

    if (step == 0 && !s1Arrow4) {
      if(toolType == 'arr4') _drawToolArrow(canvas, 4, mouseX + dragOffset.dx, mouseY + dragOffset.dy, true);
      else _drawToolArrow(canvas, 4, tbX + 70, tbY + 60);
    }
    if (step == 1 && !s1Arrow7) {
      if(toolType == 'arr7') _drawToolArrow(canvas, -7, mouseX + dragOffset.dx, mouseY + dragOffset.dy, true);
      else { canvas.save(); canvas.translate(tbX+210, tbY+60); canvas.scale(0.8); _drawToolArrow(canvas, -7, 0, 0); canvas.restore(); }
    }

    if (step >= 3) {
      double bubbleX = -96, bubbleY = -30;
      _drawRoundedRect(canvas, bubbleX - 170, bubbleY - 120, 340, 120, 16, const Color(0xFFFFEDD5), const Color(0xFF0F172A), 4);
      Path tail = Path()..moveTo(bubbleX-15, bubbleY)..lineTo(bubbleX, bubbleY+40)..lineTo(bubbleX+15, bubbleY)..close();
      canvas.drawPath(tail, Paint()..color=const Color(0xFFFFEDD5)); canvas.drawPath(tail, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=4);
      canvas.drawLine(Offset(bubbleX-13, bubbleY), Offset(bubbleX+13, bubbleY), Paint()..color=const Color(0xFFFFEDD5)..strokeWidth=6);
      
      _drawTextOutline(canvas, t('s1_eq_title'), bubbleX, bubbleY - 90, 20, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s1_eq_L1'), bubbleX, bubbleY - 55, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s1_eq_L2'), bubbleX, bubbleY - 35, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s1_eq_L3'), bubbleX, bubbleY - 10, 15, const Color(0xFF0F172A), Colors.transparent, 0);
    }
  }

  void _drawScenario2(Canvas canvas) {
    double deskW = 900, deskH = 600;
    _drawRoundedRect(canvas, -deskW/2, -deskH/2, deskW, deskH, 0, const Color(0xFFB45309), const Color(0xFF78350F), 8);
    canvas.drawLine(const Offset(-450, 250), const Offset(450, 250), Paint()..color=const Color(0xFF92400E)..strokeWidth=10);

    double mX = -200, mY = -100, matW = 500, matH = 300;
    RRect matRRect = RRect.fromRectAndRadius(Rect.fromLTWH(mX, mY, matW, matH), const Radius.circular(16));
    canvas.drawRRect(matRRect.shift(const Offset(0, 10)), Paint()..color=Colors.black45..maskFilter=const MaskFilter.blur(BlurStyle.normal, 15));
    canvas.drawRRect(matRRect, Paint()..color=const Color(0xFF94A3B8));
    _drawRoundedRect(canvas, mX+10, mY+10, matW-20, matH-20, 12, const Color(0xFFCBD5E1), const Color(0xFF94A3B8), 2);

    double eqY = -180;
    _drawTextOutline(canvas, "(+7) - (+18)${step>=3?' = -11':''}", 0, eqY, 42, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 6);

    int totalPos = s2MatPos + s2ZeroPairs;
    int totalNeg = s2MatNeg + s2ZeroPairs;
    int val = totalPos - totalNeg;
    _drawRoundedRect(canvas, -60, mY-60, 120, 40, 8, const Color(0xFF334155), const Color(0xFF0F172A), 4);
    _drawTextOutline(canvas, "${t('netValue')}${val>0?'+':''}$val", 0, mY-40, 18, Colors.white, Colors.transparent, 0);

    void drawBin(double bx, double by, Color color, Color stroke, String label) {
      canvas.save(); canvas.translate(bx, by);
      _drawRoundedRect(canvas, -60, -90, 120, 180, 8, color, stroke, 4);
      for(int t=0; t<6; t++) _drawToken(canvas, (t%2==0?-15:15), -40+t*20.0, color==const Color(0xFF4ADE80));
      _drawRoundedRect(canvas, -65, -10, 130, 110, 8, stroke, const Color(0xFF0F172A), 4);
      List<String> words = label.split('\n');
      for(int i=0; i<words.length; i++) _drawTextOutline(canvas, words[i], 0, 30+i*20.0, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      canvas.restore();
    }

    drawBin(-380, 60, const Color(0xFF4ADE80), const Color(0xFF166534), t('posTokenBin'));
    if (step >= 2) {
      _drawRoundedRect(canvas, 320, -30, 120, 180, 8, const Color(0xFF94A3B8), const Color(0xFF334155), 4);
      List<String> words = t('removalZone').split('\n');
      for(int i=0; i<words.length; i++) _drawTextOutline(canvas, words[i], 380, 60+i*20.0, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      if(step == 2) _drawRoundedRect(canvas, 320, -30, 120, 180, 8, const Color(0x33EF4444), Colors.transparent);
    } else {
      drawBin(380, 60, const Color(0xFFF87171), const Color(0xFF991B1B), t('negTokenBin'));
    }

    if (step == 1) {
      canvas.save(); canvas.translate(-380, -100);
      _drawRoundedRect(canvas, -60, -70, 120, 140, 16, const Color(0xFFCBD5E1), const Color(0xFF334155), 6);
      _drawRoundedRect(canvas, -40, -50, 80, 35, 8, const Color(0xFFF8FAFC), const Color(0xFF94A3B8), 2);
      canvas.drawCircle(const Offset(-15,-35), 5, Paint()..color=const Color(0xFF0F172A)); canvas.drawCircle(const Offset(15,-35), 5, Paint()..color=const Color(0xFF0F172A));
      canvas.drawLine(const Offset(0,-70), const Offset(0,-100), Paint()..color=const Color(0xFF334155)..strokeWidth=6);
      _drawToken(canvas, -15, -110, true); _drawToken(canvas, 15, -110, false);
      _drawRoundedRect(canvas, -40, 0, 80, 50, 8, const Color(0xFFFEF08A), const Color(0xFFCA8A04), 4);
      List<String> zg = t('zeroPairGen').split('\n');
      _drawTextOutline(canvas, zg.length>0?zg[0]:'', 0, 20, 10, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, zg.length>1?zg[1]:'', 0, 35, 10, const Color(0xFF0F172A), Colors.transparent, 0);
      canvas.restore();
      
      _drawRoundedRect(canvas, 50, -220, 200, 60, 8, Colors.transparent, const Color(0xFFF59E0B), 4, true);
      _drawTextOutline(canvas, "+7 + 0 = +7", 150, -190, 32, const Color(0xFFFDE047), const Color(0xFFB45309), 4);
    }

    for(int i=0; i<totalPos; i++) _drawToken(canvas, mX + 50 + (i%5)*45, mY + 50 + (i~/5)*45, true);
    for(int i=0; i<totalNeg; i++) _drawToken(canvas, mX + 280 + (i%4)*45, mY + 50 + (i~/4)*45, false);

    if (toolType == 'stack7') {
      canvas.save(); canvas.translate(mouseX + dragOffset.dx, mouseY + dragOffset.dy);
      _drawToken(canvas, 0, 0, true); _drawToken(canvas, 5, 5, true); _drawToken(canvas, 10, 10, true);
      _drawTextOutline(canvas, "x7", 40, 20, 20, Colors.white, Colors.transparent, 0);
      canvas.restore();
    }
    if (toolType == 'stack18') {
      canvas.save(); canvas.translate(mouseX + dragOffset.dx, mouseY + dragOffset.dy);
      _drawToken(canvas, 0, 0, true); _drawToken(canvas, 5, 5, true); _drawToken(canvas, 10, 10, true);
      _drawTextOutline(canvas, "x18", 40, 20, 20, Colors.white, Colors.transparent, 0);
      canvas.restore();
    }

    if (step >= 3) {
      _drawRoundedRect(canvas, mX-20, mY-20, matW+40, matH+40, 20, const Color(0x1A38BDF8), const Color(0xFF38BDF8), 4);
      double bubbleX = 420, bubbleY = -50;
      _drawRoundedRect(canvas, bubbleX - 170, bubbleY - 90, 340, 140, 16, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 4);
      double bY = bubbleY - 50;
      for(String key in ['s2_bubble_L1', 's2_bubble_L2', 's2_bubble_L3', 's2_bubble_L4', 's2_bubble_L5']) {
        String txt = t(key); if(txt != key) { _drawTextOutline(canvas, txt, bubbleX, bY, 14, const Color(0xFF0F172A), Colors.transparent, 0); bY+=20; }
      }
    }
  }

  void _drawScenario3(Canvas canvas) {
    canvas.drawPaint(Paint()..color=const Color(0xFF1E293B));
    Paint pipePaint = Paint()..color=const Color(0xFF334155)..strokeWidth=24..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round..style=PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(-350,300)..lineTo(-350,-50)..lineTo(-450,-50), pipePaint);
    canvas.drawPath(Path()..moveTo(350,300)..lineTo(350,150)..lineTo(450,150), pipePaint);
    
    _drawGear(canvas, -400, 200, 40, 8, const Color(0xFF334155));
    _drawGear(canvas, -350, 250, 30, 6, const Color(0xFF475569));
    _drawGear(canvas, 400, -100, 50, 10, const Color(0xFF334155));

    double monW = 420, monH = 220, mX = -210, mY = -180;
    _drawRoundedRect(canvas, mX, mY, monW, monH, 16, const Color(0xFF0F172A), const Color(0xFF38BDF8), 6);
    
    double matW = 400, matH = 200, matX = -200, matY = 70;
    _drawRoundedRect(canvas, matX, matY, matW, matH, 12, const Color(0xFF334155), const Color(0xFF475569), 6);
    _drawRoundedRect(canvas, matX+10, matY+10, matW-20, matH-20, 8, const Color(0xFFCBD5E1), Colors.transparent);

    List<Offset> groups = [const Offset(-80, 110), const Offset(80, 110), const Offset(-80, 190), const Offset(80, 190)];

    if (s3State == 0) {
      _drawTextOutline(canvas, "(-4) × (+2)", 0, mY+60, 46, const Color(0xFFF8FAFC), Colors.transparent, 0);
    } else if (s3State == 1 || s3State == 2 || s3State == 0.5) {
      _drawRoundedRect(canvas, -40, mY+10, 80, 30, 6, const Color(0xFF1E293B), const Color(0xFF38BDF8), 2);
      _drawTextOutline(canvas, "0", 0, mY+25, 18, const Color(0xFF38BDF8), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s3_screen1'), 0, mY+70, 22, const Color(0xFFFDE047), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s3_screen2'), 0, mY+100, 22, const Color(0xFFFDE047), Colors.transparent, 0);
    } else if (s3State == 3) {
      _drawRoundedRect(canvas, -40, mY+10, 80, 30, 6, const Color(0xFF1E293B), const Color(0xFFF87171), 2);
      _drawTextOutline(canvas, "-8", 0, mY+25, 18, const Color(0xFFF87171), Colors.transparent, 0);
      _drawTextOutline(canvas, "(-4) × (+2) = -8", 0, mY+70, 40, const Color(0xFFF87171), Colors.transparent, 0);
      _drawRoundedRect(canvas, mX+20, mY+110, monW-40, 95, 8, const Color(0xFF1E293B), Colors.transparent);
      double bY = mY + 130;
      for(String key in ['s3_bubble_L1', 's3_bubble_L2', 's3_bubble_L3', 's3_bubble_L4', 's3_bubble_L5']) {
        String txt = t(key); if(txt!=key) { _drawTextOutline(canvas, txt, 0, bY, 13, const Color(0xFFF8FAFC), Colors.transparent, 0); bY+=16; }
      }
    }

    for(int i=0; i<4; i++) {
      double gx = groups[i].dx, gy = groups[i].dy;
      if (s3State == 0.5) {
        double p = s3InfuseProgress; double startY = -180; double dropY = startY + p * (gy - startY);
        canvas.drawLine(Offset(gx-20, startY), Offset(gx-20, dropY), Paint()..color=const Color(0x664ADE80)..strokeWidth=12);
        canvas.drawLine(Offset(gx+20, startY), Offset(gx+20, dropY), Paint()..color=const Color(0x66F87171)..strokeWidth=12);
        _drawToken(canvas, gx-20, dropY-20, true); _drawToken(canvas, gx+20, dropY-20, true);
        _drawToken(canvas, gx-20, dropY+20, false); _drawToken(canvas, gx+20, dropY+20, false);
      } else if (s3State >= 1) {
        _drawToken(canvas, gx-20, gy+20, false); _drawToken(canvas, gx+20, gy+20, false);
        if (s3State == 1) { _drawToken(canvas, gx-20, gy-20, true); _drawToken(canvas, gx+20, gy-20, true); }
        else if (s3State == 2) {
          if (i > s3GroupsRem) { _drawToken(canvas, gx-20, gy-20, true); _drawToken(canvas, gx+20, gy-20, true); }
          else if (i == s3GroupsRem && s3ArmExt < 1.0) {
            RRect glowRRect = RRect.fromRectAndRadius(Rect.fromLTWH(gx-45, gy-45, 90, 50), const Radius.circular(10));
            canvas.drawRRect(glowRRect, Paint()..color=const Color(0xFFFEF08A)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 10));
            canvas.drawRRect(glowRRect, Paint()..color=const Color(0x4DFDE047));
            _drawRoundedRect(canvas, gx-45, gy-45, 90, 50, 10, Colors.transparent, const Color(0xFFEAB308), 3);
            _drawToken(canvas, gx-20, gy-20, true); _drawToken(canvas, gx+20, gy-20, true);
          }
        }
      }
    }

    if (s3State == 2 && s3GroupsRem < 4) {
      Offset target = groups[s3GroupsRem];
      double tVal = s3ArmExt; bool isLeft = s3GroupsRem % 2 == 0;
      double armOriginX = isLeft ? -350 : 350; double armOriginY = 150;
      double progress = tVal < 1.0 ? tVal : (2.0 - tVal);
      double clawX = armOriginX + progress * (target.dx - armOriginX);
      double clawY = armOriginY + progress * (target.dy - 20 - armOriginY);
      
      canvas.save();
      canvas.drawLine(Offset(armOriginX, armOriginY), Offset(clawX, clawY), Paint()..color=const Color(0xFF64748B)..strokeWidth=18);
      canvas.translate(clawX, clawY);
      _drawRoundedRect(canvas, -15, -20, 30, 20, 4, const Color(0xFF94A3B8), const Color(0xFF334155), 2);
      Paint pincer = Paint()..color=const Color(0xFF334155)..strokeWidth=6..strokeCap=StrokeCap.round;
      canvas.drawLine(const Offset(-10,0), const Offset(-25,20), pincer);
      canvas.drawLine(const Offset(10,0), const Offset(25,20), pincer);
      if (tVal >= 1.0) { _drawToken(canvas, -15, 25, true); _drawToken(canvas, 15, 25, true); }
      canvas.restore();
    }
  }

  void _drawScenario4(Canvas canvas) {
    canvas.drawPaint(Paint()..color=const Color(0xFF5C3A21));
    Path bgDirt = Path()..moveTo(-screenSize.width, -50)..lineTo(screenSize.width, -100)..lineTo(screenSize.width, screenSize.height)..lineTo(-screenSize.width, screenSize.height)..close();
    canvas.drawPath(bgDirt, Paint()..color=const Color(0xFF3E2413));

    double nlX = -300;
    canvas.drawLine(Offset(nlX, -300), Offset(nlX, 350), Paint()..color=Colors.white..strokeWidth=4);
    for(int i=-150; i<=50; i+=10) {
      double ly = -i * 2.2;
      canvas.drawLine(Offset(nlX-10, ly), Offset(nlX+10, ly), Paint()..color=Colors.white..strokeWidth=3);
      if (i%50==0 || i==15 || i==-120) {
        Color fColor = (i == s4ElevatorTarget) ? const Color(0xFF4ADE80) : Colors.white;
        _drawTextOutline(canvas, "${i>0?'+':''}${i}m", nlX-45, ly, 18, fColor, Colors.black, 4);
        canvas.drawLine(Offset(nlX+10, ly), Offset(0, ly), Paint()..color=Colors.white38..strokeWidth=2);
      }
    }

    canvas.drawRect(const Rect.fromLTWH(-45, -300, 90, 650), Paint()..color=Colors.black54);
    bool isSuccess = step == 1 && (s4ElevatorPos - (-120)).abs() < 0.5;
    _drawElevator(canvas, 0, -s4ElevatorPos * 2.2, isSuccess);

    if (s4ErrorMsg > 0) {
      _drawRoundedRect(canvas, -80, -s4ElevatorPos * 2.2 - 90, 160, 40, 8, const Color(0xE6EF4444), const Color(0xFF991B1B), 2);
      _drawTextOutline(canvas, t('tryAgain'), 0, -s4ElevatorPos * 2.2 - 70, 18, Colors.white, Colors.transparent, 0);
    }

    if (isSuccess) {
      RRect successRRect = RRect.fromRectAndRadius(Rect.fromLTWH(-120, 120*2.2-120, 240, 50), const Radius.circular(10));
      canvas.drawRRect(successRRect, Paint()..color=const Color(0xFF4ADE80)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 20));
      canvas.drawRRect(successRRect, Paint()..color=Colors.white);
      _drawRoundedRect(canvas, -120, 120*2.2-120, 240, 50, 10, Colors.transparent, const Color(0xFF22C55E), 4);
      _drawTextOutline(canvas, t('missionSuccess'), 0, 120*2.2-95, 22, const Color(0xFF16A34A), Colors.transparent, 0);
      canvas.save(); canvas.translate(0, 120*2.2-50); _drawToolArrow(canvas, -135, 0, 0); canvas.restore();
    }

    if (step == 0) {
      double tbX = 140, tbY = -120;
      _drawRoundedRect(canvas, tbX-110, tbY-60, 220, 120, 40, Colors.white, const Color(0xFF333333), 4);
      canvas.drawCircle(Offset(tbX-70, tbY+70), 15, Paint()..color=Colors.white); canvas.drawCircle(Offset(tbX-70, tbY+70), 15, Paint()..color=const Color(0xFF333333)..style=PaintingStyle.stroke..strokeWidth=2);
      canvas.drawCircle(Offset(tbX-90, tbY+100), 8, Paint()..color=Colors.white); canvas.drawCircle(Offset(tbX-90, tbY+100), 8, Paint()..color=const Color(0xFF333333)..style=PaintingStyle.stroke..strokeWidth=2);
      _drawTextOutline(canvas, t('s4_calc_1'), tbX, tbY-25, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s4_calc_2'), tbX, tbY-5, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s4_calc_3'), tbX, tbY+15, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawRoundedRect(canvas, tbX-20, tbY+60, 180, 80, 40, Colors.white, const Color(0xFF333333), 3);
      _drawTextOutline(canvas, t('s4_calc_4'), tbX+70, tbY+90, 15, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s4_calc_5'), tbX+70, tbY+115, 15, const Color(0xFF0F172A), Colors.transparent, 0);

      double boxX = -120, boxY = 80;
      RRect toolRRect = RRect.fromRectAndRadius(Rect.fromLTWH(boxX, boxY, 340, 180), const Radius.circular(12));
      canvas.drawRRect(toolRRect, Paint()..color=const Color(0xFFF59E0B)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 30));
      canvas.drawRRect(toolRRect, Paint()..color=const Color(0xFFF8FAFC));
      _drawRoundedRect(canvas, boxX, boxY, 340, 180, 12, Colors.transparent, const Color(0xFF3B82F6), 6);
      canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromLTWH(boxX, boxY, 340, 30), topLeft: const Radius.circular(12), topRight: const Radius.circular(12)), Paint()..color=const Color(0xFF3B82F6));
      _drawTextOutline(canvas, t('toolbox'), boxX+40, boxY+15, 16, Colors.white, Colors.transparent, 0);

      List<double> arrs = [-45, -120, -135, 45, 135, 120];
      List<Offset> poss = [Offset(boxX+50, boxY+70), Offset(boxX+130, boxY+70), Offset(boxX+210, boxY+70), Offset(boxX+50, boxY+140), Offset(boxX+130, boxY+140), Offset(boxX+210, boxY+140)];
      for(int i=0; i<6; i++) {
        _drawRoundedRect(canvas, poss[i].dx-30, poss[i].dy-30, 60, 60, 6, arrs[i]<0?const Color(0xFFFEE2E2):const Color(0xFFDCFCE7), arrs[i]<0?const Color(0xFFFCA5A5):const Color(0xFF86EFAC), 2);
        if(toolType == 'arr_${arrs[i]}') _drawToolArrow(canvas, arrs[i], mouseX + dragOffset.dx, mouseY + dragOffset.dy, true);
        else _drawToolArrow(canvas, arrs[i], poss[i].dx, poss[i].dy);
      }
    }
  }

  void _drawScenario5(Canvas canvas) {
    canvas.drawPaint(Paint()..color=const Color(0xFFE2E8F0));
    _drawRoundedRect(canvas, -420, -250, 840, 440, 16, Colors.transparent, const Color(0xFF94A3B8), 4);

    void drawControlBin(double bx, double by, bool isPos) {
      canvas.save(); canvas.translate(bx, by);
      Color color = isPos ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
      Color stroke = isPos ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
      _drawRoundedRect(canvas, 0, 0, 150, 180, 8, color, stroke, 4);
      for(int i=0; i<12; i++) _drawToken(canvas, 35 + (i%3)*40, 35 + (i~/3)*35, isPos);
      canvas.drawRRect(RRect.fromRectAndCorners(const Rect.fromLTWH(0, 150, 150, 30), bottomLeft: const Radius.circular(8), bottomRight: const Radius.circular(8)), Paint()..color=stroke);
      _drawTextOutline(canvas, t('infinite'), 75, 165, 14, Colors.white, Colors.transparent, 0);
      canvas.restore();
    }
    
    drawControlBin(-380, -230, true);
    drawControlBin(-380, -20, false);

    double mX = -200, mY = -230, matW = 440, matH = 240;
    _drawRoundedRect(canvas, mX, mY, matW, matH, 8, const Color(0xFF94A3B8), const Color(0xFF334155), 4);

    void drawCounter(double cx, double cy, String label, int val, Color color) {
      canvas.save(); canvas.translate(cx, cy);
      _drawTextOutline(canvas, label, 50, -10, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawRoundedRect(canvas, 0, 0, 180, 60, 8, const Color(0xFF111827), const Color(0xFF475569), 4);
      for(int i=0; i<4; i++) _drawRoundedRect(canvas, 10+i*30, 10, 25, 40, 2, const Color(0xFF334155), Colors.transparent);
      _drawTextOutline(canvas, val.toString(), 150, 30, 36, color, Colors.transparent, 0);
      canvas.restore();
    }

    int val = s5MatPos - s5MatNeg; int count = s5MatPos + s5MatNeg;
    drawCounter(-200, 50, t('currVal'), val, val == -6 ? const Color(0xFF4ADE80) : const Color(0xFFF8FAFC));
    drawCounter(10, 50, t('totTokens'), count, count == 10 ? const Color(0xFF4ADE80) : const Color(0xFFF8FAFC));

    _drawRoundedRect(canvas, 260, -230, 140, 200, 8, const Color(0xFFF8FAFC), const Color(0xFF334155), 4);
    _drawTextOutline(canvas, t('s5_target'), 330, -200, 14, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawTextOutline(canvas, t('s5_tot_tok'), 330, -180, 14, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawTextOutline(canvas, t('s5_inst_1'), 330, -140, 12, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawTextOutline(canvas, t('s5_inst_2'), 330, -120, 12, const Color(0xFF0F172A), Colors.transparent, 0);

    if (step == 1) _drawTextOutline(canvas, t('s5_eq'), 330, -80, 14, const Color(0xFF16A34A), Colors.transparent, 0);

    for(int i=0; i<s5MatPos; i++) _drawToken(canvas, mX+50+(i%9)*45, mY+60+(i~/9)*50, true);
    for(int i=0; i<s5MatNeg; i++) _drawToken(canvas, mX+50+(i%9)*45, mY+160+(i~/9)*50, false);
  }

  @override
  bool shouldRepaint(covariant IntegerModelsPainter oldDelegate) => true;
}

const Map<String, Map<String, String>> _translations = {
  'en': {
    'appTitle': "Integer Models: Number Line & Tokens", 'appSubtitle': "Class 7 • OPERATIONS WITH INTEGERS", 'enterLab': "Enter Lab",
    'settings': "Settings", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'boardFontSize': "Text Size", 
    'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done", 
    'learnLbl': "What We Learn:", 'closeBtn': "Close", 'summaryTitle': "Discovery Made!",
    'resetBtn': "Reset", 'finishLab': "Finish Lab", 'nextScenario': "Next Scenario",
    'labCompleted': "Lab Completed!", 'finalDesc': "You have successfully mastered integer operations! By using the number line and the token models, you have built a strong visual understanding of positive and negative numbers.",
    
    'toolbox': "Toolbox", 'workspaceMat': "Workspace Mat", 'netValue': "Value: ", 'tokens': "Tokens: ",
    'posTokenBin': "Positive\nToken\nBin", 'negTokenBin': "Negative\nToken\nBin", 'removalZone': "Removal\nZone", 'zeroPairGen': "Zero Pair\nGenerator",
    'confirmBtn': "Confirm", 'infuseBtn': "INFUSE ZERO PAIRS", 'activateBtn': "ACTIVATE ARM", 'finalizeBtn': "Finalize",
    
    'tryAgain': "Try Again!", 'missionSuccess': "MISSION SUCCESS!", 's4_calc_1': "Calculate total descent:", 's4_calc_2': "Elevator moves at -3m/min", 
    's4_calc_3': "for 45 minutes.", 's4_calc_4': "45 min × (-3 m/min)", 's4_calc_5': "= -135m", 'infinite': "Infinite", 'currVal': "Current Value:", 
    'totTokens': "Total Tokens:", 's5_target': "Target Value: -6", 's5_tot_tok': "Total Tokens: 10", 's5_inst_1': "Use the bins to", 
    's5_inst_2': "create the target!", 's5_eq': "(+2) + (-8) = -6", 'challengeComplete': "CHALLENGE COMPLETE!",
    'infoNextScen': "Scenario completed! Please select the next scenario from the dropdown above.", 'infoLabDone': "Lab Completed! You have mastered Integer operations.",

    's1_title': "1. The Carrom Coin Journey", 's1_obj': "To understand and visualize the addition of a positive and a negative integer on a number line.",
    's1_hud1': "Problem: (+4) + (-7). DRAG the green '+4' arrow to the coin.", 's1_step1_task': "<b>Action:</b> The scene shows a carrom coin at position 0 on a large horizontal number line. The problem `(+4) + (-7)` is displayed. DRAG the green arrow labeled '+4' from the toolbox and DROP it onto the carrom coin at 0.", 's1_step1_out': "<b>Observation:</b> The carrom coin slides from 0 to +4.",
    's1_hud2': "Now, DRAG the red '-7' arrow to the coin at 4.", 's1_step2_task': "<b>Action:</b> Now, DRAG the red arrow labeled '-7' from the toolbox and DROP it onto the carrom coin's current position at 4.", 's1_step2_out': "<b>Observation:</b> The carrom coin slides from 4 leftwards to -3.",
    's1_hud3': "CLICK the glowing number '-3' on the number line.", 's1_step3_task': "<b>Action:</b> CLICK the glowing number '-3' on the number line to confirm the final position.", 's1_step3_out': "<b>Learning:</b> Adding a positive number is a move right, adding a negative is a move left. Final sum is -3.",
    's1_sum': "<b>Journey Complete!</b> (+4) + (-7) = -3.",
    's1_eq_title': "Final Position: -3", 's1_eq_L1': "Adding a positive is a move to the right (+4).", 's1_eq_L2': "Adding a negative is a move to the left (-7).", 's1_eq_L3': "The final position is the sum.",

    's2_title': "2. The Token Trader", 's2_obj': "To visualize subtraction of integers using the token model, specifically requiring the use of zero pairs.",
    's2_hud1': "Problem: (+7) - (+18). DRAG the 'Stack of 7 Positives' to the mat.", 's2_step1_task': "<b>Action:</b> The problem `(+7) - (+18)` is displayed. Your workspace is an empty mat. DRAG the 'Stack of 7' representing '+7', from the 'Positive Token Bin' and DROP them onto the mat.", 's2_step1_out': "<b>Observation:</b> 7 green tokens are now on the mat. The counter displays '+7'.",
    's2_hud2': "CLICK the Zero Pair Generator 11 times.", 's2_step2_task': "<b>Action:</b> The mission is to remove 18 positive (green) tokens, but you only have 7. A 'Zero Pair Generator' machine is highlighted. CLICK the generator's button 11 times to add enough zero pairs.", 's2_step2_out': "<b>Observation:</b> You now have 18 positive and 11 negative tokens. The total value is still +7.",
    's2_hud3': "DRAG the 'Stack of 18 Positives' from the mat to the Removal Zone.", 's2_step3_task': "<b>Action:</b> Now you have enough green tokens. DRAG the 'Stack of 18' green tokens from the mat and DROP them into the 'Removal Zone'.", 's2_step3_out': "<b>Observation:</b> 18 green tokens are removed, leaving 11 red tokens.",
    's2_hud4': "CLICK 'Confirm' to finalize the operation.", 's2_step4_task': "<b>Action:</b> The 11 red tokens on the mat represent the answer. CLICK the 'Confirm' button.", 's2_step4_out': "<b>Learning:</b> Subtraction is taking away. We use zero pairs when we don't have enough to take away.",
    's2_sum': "<b>Trade Complete!</b> (+7) - (+18) = -11.",
    's2_bubble_L1': "By using zero pairs to add 11 pairs,", 's2_bubble_L2': "we were able to take away 18 green tokens.", 's2_bubble_L3': "The remaining 11 red tokens show the result.", 's2_bubble_L4': "", 's2_bubble_L5': "",

    's3_title': "3. The Token Factory", 's3_obj': "To model integer multiplication as repeated addition or removal of groups.",
    's3_hud1': "Problem: (-4) × (+2). CLICK 'Infuse Zero Pairs'.", 's3_step1_task': "<b>Action:</b> The problem `(-4) × (+2)` is displayed. This means 'remove 4 groups of 2 positive tokens'. The mat is empty. You cannot remove tokens that aren't there. CLICK the 'Infuse Zero Pairs' button to prepare the mat.", 's3_step1_out': "<b>Observation:</b> The system automatically adds 4 groups of 2 zero pairs (8 green and 8 red tokens) to the mat.",
    's3_hud2': "CLICK 'Activate Arm' to remove 4 groups of +2.", 's3_step2_task': "<b>Action:</b> Now that the mat is prepared, a robotic arm is ready. The instruction 'remove 4 groups of 2 positive tokens' is highlighted. CLICK the 'Activate Arm' button to execute the operation.", 's3_step2_out': "<b>Observation:</b> The robotic arm removes the 8 green tokens.",
    's3_hud3': "CLICK 'Finalize' to check the result.", 's3_step3_task': "<b>Action:</b> The 8 red tokens remaining on the mat are the result. CLICK the 'Finalize' button to see the summary.", 's3_step3_out': "<b>Learning:</b> Removing groups of positive tokens leaves behind negative tokens.",
    's3_sum': "<b>Factory Operation Complete!</b> (-4) × (+2) = -8.",
    's3_screen1': "remove 4 groups of", 's3_screen2': "2 positive tokens",
    's3_bubble_L1': "Summary: A negative multiplier like -4", 's3_bubble_L2': "means to REMOVE groups. To remove 4", 's3_bubble_L3': "groups of +2, we first added zero pairs,", 's3_bubble_L4': "then removed the 4 groups of +2,", 's3_bubble_L5': "leaving -8 as the final answer.",

    's4_title': "4. The Elevator Challenge", 's4_obj': "Use the number line model to solve a multi-step word problem.",
    's4_hud1': "Elevator is at +15. Descend at 3 m/min for 45 min. DRAG correct arrow.", 's4_step1_task': "<b>Action:</b> An elevator starts at 15m above ground (+15). It moves down at a rate of 3 meters per minute for 45 minutes. DRAG the correct movement arrow from the toolbox to the elevator to send it to its final destination in one move.", 's4_step1_out': "<b>Observation:</b> The elevator travels to -120.",
    's4_sum': "<b>Elevator Arrived!</b> (+15) + (-135) = -120.",
    's4_movement': "Toolbox",

    's5_title': "5. The Token Equation", 's5_obj': "To create a target integer value using a combination of positive and negative tokens.",
    's5_hud1': "Target: Value -6 using exactly 10 tokens. Click Bins to Add, click Mat to Remove.", 's5_step1_task': "<b>Action:</b> The target value is '-6'. The mat is empty. Your challenge is to represent '-6' on the mat using exactly 10 tokens in total. CLICK the green (+) and red (-) bins to add tokens. CLICK tokens on the mat to remove them.", 's5_step1_out': "<b>Observation:</b> The user balances tokens to reach 2 positive and 8 negative.",
    's5_sum': "<b>Equation Balanced!</b> (+2) + (-8) = -6 with 10 tokens total."
  },
  'hi': {
    'appTitle': "पूर्णांक मॉडल: संख्या रेखा और टोकन", 'appSubtitle': "कक्षा 7 • पूर्णांक संचालन", 'enterLab': "लैब में प्रवेश करें",
    'settings': "सेटिंग्स", 'theme': "थीम", 'darkMode': "डार्क मोड", 'lightMode': "लाइट मोड", 'boardFontSize': "टेक्स्ट आकार", 
    'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण", 
    'learnLbl': "हम क्या सीखते हैं:", 'closeBtn': "बंद करें", 'summaryTitle': "खोज की गई!",
    'resetBtn': "रीसेट करें", 'finishLab': "लैब समाप्त करें", 'nextScenario': "अगला परिदृश्य",
    'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने पूर्णांक संचालन में सफलतापूर्वक महारत हासिल कर ली है! संख्या रेखा और टोकन मॉडल का उपयोग करके, आपने धनात्मक और ऋणात्मक संख्याओं की एक मजबूत दृश्य समझ बनाई है।",
    
    'toolbox': "टूलबॉक्स", 'workspaceMat': "वर्कस्पेस मैट", 'netValue': "मूल्य: ", 'tokens': "टोकन: ",
    'posTokenBin': "धनात्मक\nटोकन\nबिन", 'negTokenBin': "ऋणात्मक\nटोकन\nबिन", 'removalZone': "रिमूवल\nज़ोन", 'zeroPairGen': "शून्य जोड़ी\nजेनरेटर",
    'confirmBtn': "पुष्टि करें", 'infuseBtn': "शून्य जोड़े डालें", 'activateBtn': "रोबोटिक आर्म सक्रिय करें", 'finalizeBtn': "अंतिम रूप दें",

    'tryAgain': "पुनः प्रयास करें!", 'missionSuccess': "मिशन सफल!", 's4_calc_1': "कुल वंश की गणना करें:", 's4_calc_2': "एलीवेटर -3m/min की गति से चलता है", 
    's4_calc_3': "45 मिनट के लिए।", 's4_calc_4': "45 min × (-3 m/min)", 's4_calc_5': "= -135m", 'infinite': "अनंत", 'currVal': "वर्तमान मूल्य:", 
    'totTokens': "कुल टोकन:", 's5_target': "लक्ष्य मान: -6", 's5_tot_tok': "कुल टोकन: 10", 's5_inst_1': "लक्ष्य बनाने के लिए", 
    's5_inst_2': "डिब्बे का प्रयोग करें!", 's5_eq': "(+2) + (-8) = -6", 'challengeComplete': "चुनौती पूर्ण!",
    'infoNextScen': "परिदृश्य पूरा हुआ! कृपया ऊपर दिए गए ड्रॉपडाउन से अगला परिदृश्य चुनें।", 'infoLabDone': "लैब पूर्ण! आपने पूर्णांक संचालन में महारत हासिल कर ली है।",

    's1_title': "1. कैरम कॉइन यात्रा", 's1_obj': "संख्या रेखा पर एक धनात्मक और एक ऋणात्मक पूर्णांक के योग को समझना और कल्पना करना।",
    's1_hud1': "समस्या: (+4) + (-7)। हरे '+4' तीर को सिक्के पर खींचें।", 's1_step1_task': "<b>क्रिया:</b> दृश्य एक बड़ी क्षैतिज संख्या रेखा पर स्थिति 0 पर एक कैरम सिक्का दिखाता है। समस्या `(+4) + (-7)` प्रदर्शित की गई है। टूलबॉक्स से '+4' लेबल वाले हरे तीर को खींचें और इसे 0 पर कैरम सिक्के पर छोड़ें।", 's1_step1_out': "<b>अवलोकन:</b> कैरम सिक्का 0 से +4 तक खिसकता है।",
    's1_hud2': "अब, लाल '-7' तीर को 4 पर सिक्के पर खींचें।", 's1_step2_task': "<b>क्रिया:</b> अब, टूलबॉक्स से '-7' लेबल वाले लाल तीर को खींचें और इसे 4 पर कैरम सिक्के की वर्तमान स्थिति पर छोड़ें।", 's1_step2_out': "<b>अवलोकन:</b> कैरम सिक्का 4 से बाईं ओर -3 तक खिसकता है।",
    's1_hud3': "संख्या रेखा पर चमकते हुए '-3' पर क्लिक करें।", 's1_step3_task': "<b>क्रिया:</b> अंतिम स्थिति की पुष्टि करने के लिए संख्या रेखा पर चमकते हुए '-3' पर क्लिक करें।", 's1_step3_out': "<b>सीख:</b> धनात्मक संख्या जोड़ना दाईं ओर जाना है, ऋणात्मक जोड़ना बाईं ओर जाना है। अंतिम योग -3 है।",
    's1_sum': "<b>यात्रा पूर्ण!</b> (+4) + (-7) = -3.",
    's1_eq_title': "अंतिम स्थिति: -3", 's1_eq_L1': "धनात्मक जोड़ना दाईं ओर जाना है (+4)।", 's1_eq_L2': "ऋणात्मक जोड़ना बाईं ओर जाना है (-7)।", 's1_eq_L3': "अंतिम स्थिति योग है।",

    's2_title': "2. टोकन ट्रेडर", 's2_obj': "टोकन मॉडल का उपयोग करके पूर्णांकों के घटाव की कल्पना करना, विशेष रूप से शून्य जोड़े के उपयोग की आवश्यकता होती है।",
    's2_hud1': "समस्या: (+7) - (+18)। '7 धनात्मक स्टैक' को मैट पर खींचें।", 's2_step1_task': "<b>क्रिया:</b> समस्या `(+7) - (+18)` प्रदर्शित की गई है। आपका कार्यक्षेत्र एक खाली मैट है। 'धनात्मक टोकन बिन' से '+7' का प्रतिनिधित्व करने वाले '7 के स्टैक' को खींचें और उन्हें मैट पर छोड़ दें।", 's2_step1_out': "<b>अवलोकन:</b> 7 हरे टोकन अब मैट पर हैं। काउंटर '+7' प्रदर्शित करता है।",
    's2_hud2': "शून्य जोड़ी जेनरेटर पर 11 बार क्लिक करें।", 's2_step2_task': "<b>क्रिया:</b> मिशन 18 धनात्मक (हरे) टोकन निकालना है, लेकिन आपके पास केवल 7 हैं। एक 'शून्य जोड़ी जेनरेटर' मशीन हाइलाइट की गई है। पर्याप्त शून्य जोड़े जोड़ने के लिए जेनरेटर के बटन पर 11 बार क्लिक करें।", 's2_step2_out': "<b>अवलोकन:</b> अब आपके पास 18 धनात्मक और 11 ऋणात्मक टोकन हैं। कुल मूल्य अभी भी +7 है।",
    's2_hud3': "मैट से '18 धनात्मक स्टैक' को रिमूवल ज़ोन में खींचें।", 's2_step3_task': "<b>क्रिया:</b> अब आपके पास पर्याप्त हरे टोकन हैं। मैट से 18 हरे टोकन के 'स्टैक' को खींचें और उन्हें 'रिमूवल ज़ोन' में छोड़ दें।", 's2_step3_out': "<b>अवलोकन:</b> 18 हरे टोकन हटा दिए जाते हैं, जिससे 11 लाल टोकन बच जाते हैं।",
    's2_hud4': "पुष्टि करने के लिए 'Confirm' पर क्लिक करें।", 's2_step4_task': "<b>क्रिया:</b> मैट पर 11 लाल टोकन उत्तर का प्रतिनिधित्व करते हैं। 'Confirm' बटन पर क्लिक करें।", 's2_step4_out': "<b>सीख:</b> घटाना दूर ले जाना है। जब हमारे पास निकालने के लिए पर्याप्त नहीं होता है तो हम शून्य जोड़े का उपयोग करते हैं।",
    's2_sum': "<b>व्यापार पूर्ण!</b> (+7) - (+18) = -11.",
    's2_bubble_L1': "11 जोड़े जोड़ने के लिए शून्य जोड़े का उपयोग करके,", 's2_bubble_L2': "हम 18 हरे टोकन निकाल पाए।", 's2_bubble_L3': "बचे हुए 11 लाल टोकन परिणाम दिखाते हैं।", 's2_bubble_L4': "", 's2_bubble_L5': "",

    's3_title': "3. टोकन फैक्ट्री", 's3_obj': "समूहों के बार-बार जोड़ने या हटाने के रूप में पूर्णांक गुणा का मॉडल तैयार करना।",
    's3_hud1': "समस्या: (-4) × (+2)। 'शून्य जोड़े डालें' (Infuse Zero Pairs) पर क्लिक करें।", 's3_step1_task': "<b>क्रिया:</b> समस्या `(-4) × (+2)` प्रदर्शित की गई है। इसका मतलब है '2 धनात्मक टोकन के 4 समूहों को हटा दें'। मैट खाली है। आप उन टोकनों को नहीं हटा सकते जो वहां नहीं हैं। मैट तैयार करने के लिए 'शून्य जोड़े डालें' बटन पर क्लिक करें।", 's3_step1_out': "<b>अवलोकन:</b> सिस्टम स्वचालित रूप से मैट में 2 शून्य जोड़े के 4 समूह (कुल 8 हरे और 8 लाल टोकन) जोड़ता है।",
    's3_hud2': "+2 के 4 समूहों को हटाने के लिए 'रोबोटिक आर्म सक्रिय करें' पर क्लिक करें।", 's3_step2_task': "<b>क्रिया:</b> अब जब मैट तैयार है, एक रोबोटिक आर्म तैयार है। निर्देश '2 धनात्मक टोकन के 4 समूहों को हटा दें' हाइलाइट किया गया है। ऑपरेशन निष्पादित करने के लिए 'Activate Arm' बटन पर क्लिक करें।", 's3_step2_out': "<b>अवलोकन:</b> रोबोटिक आर्म 8 हरे टोकन हटा देता है।",
    's3_hud3:': "परिणाम जांचने के लिए 'अंतिम रूप दें' (Finalize) पर क्लिक करें।", 's3_step3_task': "<b>क्रिया:</b> मैट पर बचे 8 लाल टोकन परिणाम हैं। सारांश देखने के लिए 'Finalize' बटन पर क्लिक करें।", 's3_step3_out': "<b>सीख:</b> धनात्मक टोकन के समूहों को हटाने से पीछे ऋणात्मक टोकन रह जाते हैं।",
    's3_sum': "<b>फैक्ट्री संचालन पूर्ण!</b> (-4) × (+2) = -8.",
    's3_screen1': "2 धनात्मक टोकन के", 's3_screen2': "4 समूहों को हटाएं",
    's3_bubble_L1': "सारांश: -4 जैसे ऋणात्मक गुणक का अर्थ", 's3_bubble_L2': "है समूहों को हटाना। +2 के 4 समूहों को", 's3_bubble_L3': "हटाने के लिए, हमने पहले शून्य जोड़े जोड़े,", 's3_bubble_L4': "फिर +2 के 4 समूहों को हटा दिया,", 's3_bubble_L5': "जिससे -8 बचा।",

    's4_title': "4. एलीवेटर चुनौती", 's4_obj': "बहु-चरणीय शब्द समस्या को हल करने के लिए संख्या रेखा मॉडल का उपयोग करें।",
    's4_hud1': "एलीवेटर +15 पर है। 45 मिनट के लिए 3 m/min की दर से नीचे उतरें। सही तीर खींचें।", 's4_step1_task': "<b>क्रिया:</b> एक लिफ्ट जमीन से 15m ऊपर (+15) शुरू होती है। इसे 45 मिनट के लिए 3 मीटर प्रति मिनट की दर से नीचे जाना है। टूलबॉक्स से सही मूवमेंट तीर को लिफ्ट तक खींचें ताकि इसे एक चाल में अपने अंतिम गंतव्य पर भेजा जा सके।", 's4_step1_out': "<b>अवलोकन:</b> लिफ्ट -120 तक जाती है।",
    's4_sum': "<b>एलीवेटर पहुँच गया!</b> (+15) + (-135) = -120.",
    's4_movement': "टूलबॉक्स",

    's5_title': "5. टोकन समीकरण", 's5_obj': "धनात्मक और ऋणात्मक टोकन के संयोजन का उपयोग करके एक लक्ष्य पूर्णांक मान बनाना।",
    's5_hud1': "लक्ष्य: ठीक 10 टोकन का उपयोग करके मान -6। जोड़ने के लिए डिब्बे पर क्लिक करें, हटाने के लिए मैट पर क्लिक करें।", 's5_step1_task': "<b>क्रिया:</b> लक्ष्य मान '-6' है। मैट खाली है। आपकी चुनौती मैट पर '-6' का प्रतिनिधित्व करना है जिसमें कुल 10 टोकन हों। टोकन जोड़ने के लिए हरे (+) और लाल (-) डिब्बे पर क्लिक करें। उन्हें हटाने के लिए मैट पर टोकन पर क्लिक करें।", 's5_step1_out': "<b>अवलोकन:</b> उपयोगकर्ता 2 धनात्मक और 8 ऋणात्मक तक पहुंचने के लिए टोकन को संतुलित करता है।",
    's5_sum': "<b>समीकरण संतुलित!</b> कुल 10 टोकन के साथ (+2) + (-8) = -6."
  }
};
