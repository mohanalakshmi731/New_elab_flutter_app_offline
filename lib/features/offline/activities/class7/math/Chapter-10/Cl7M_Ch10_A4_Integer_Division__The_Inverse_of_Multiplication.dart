// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    title: 'ZSL Virtual Lab | The Token Factory',
    debugShowCheckedModeBanner: false,
    home: IntegerDivisionTheInverseofMultiplication(),
  ));
}

class IntegerDivisionTheInverseofMultiplication extends StatefulWidget {
  const IntegerDivisionTheInverseofMultiplication({super.key});

  @override
  State<IntegerDivisionTheInverseofMultiplication> createState() => _IntegerDivisionTheInverseofMultiplicationState();
}

class _IntegerDivisionTheInverseofMultiplicationState extends State<IntegerDivisionTheInverseofMultiplication> with TickerProviderStateMixin {
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
  double _panY = 30;
  double _baseZoom = 1.0;
  Offset _basePan = Offset.zero;
  Offset _baseFocalPoint = Offset.zero;

  // Floating Step State
  Offset _floatingStepPos = const Offset(20, 80);

  // Interaction State
  bool _isDragging = false;
  String? _dragColor; // 'positive' or 'negative'
  double _dragX = 0;
  double _dragY = 0;

  // Simulation State
  bool _animating = false;
  int _animPhase = 0;
  double _animProgress = 0.0;
  
  String _tokenType = 'positive';
  int _totalTokens = 12;
  int _hopperTokens = 12;
  int _numBins = 4;
  List<int> _binTokens = [0, 0, 0, 0];
  
  bool _armHasToken = false;
  int _targetBinIndex = 0;
  
  int _removalsDone = 0;
  int _totalRemovals = 5;

  int _movedTokens = 0;

  // Animation Controllers
  late AnimationController _ticker;

  // Audio Players caching setup
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _scanPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

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
    _ticker = AnimationController(vsync: this, duration: const Duration(milliseconds: 20))
      ..addListener(_tick)
      ..repeat();
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
    super.dispose();
  }

  void _tick() {
    if (!_animating) return;

    setState(() {
      if (_scenario == 1 || _scenario == 2) {
        if (_animPhase == 0) {
          _animProgress += 0.04;
          if (_animProgress >= 1.0) {
            _armHasToken = false;
            _binTokens[_targetBinIndex]++;
            _playSound('pop');
            _animPhase = 1;
            _animProgress = 0;
          }
        } else if (_animPhase == 1) {
          _animProgress += 0.05;
          if (_animProgress >= 1.0) {
            _movedTokens++;
            if (_movedTokens >= _totalTokens) {
              _animating = false;
              _armHasToken = false;
              _advanceStep();
              _startScanPhase();
            } else {
              _startNextMove();
            }
          }
        } else if (_animPhase == 99) { // Scanning Phase
          _animProgress += 0.02;
          if (_animProgress >= 1.0) {
            _animating = false;
            _animPhase = 0;
            _advanceStep();
            _checkScenarioSuccess();
          }
        }
      } else if (_scenario == 3) {
        if (_animPhase == 0) {
          _animProgress += 0.05;
          if (_animProgress >= 1.0) {
            _armHasToken = true;
            _playSound('pop');
            _animPhase = 1;
            _animProgress = 0;
          }
        } else if (_animPhase == 1) {
          _animProgress += 0.03;
          if (_animProgress >= 1.0) {
            _armHasToken = false;
            _removalsDone++;
            _playSound('weld');
            _animPhase = 2;
            _animProgress = 0;
          }
        } else if (_animPhase == 2) {
          _animProgress += 0.06;
          if (_animProgress >= 1.0) {
            if (_removalsDone >= _totalRemovals) {
              _animating = false;
              _advanceStep();
              _checkScenarioSuccess();
            } else {
              _startNextRemoval();
            }
          }
        }
      }
    });
  }

  void _startNextMove() {
    _targetBinIndex = _movedTokens % _numBins;
    _animPhase = 0;
    _animProgress = 0;
    _armHasToken = true;
    _hopperTokens--;
    _playSound('snap');
  }

  void _startScanPhase() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _animating = true;
          _animPhase = 99;
          _animProgress = 0;
          _playSound('scan');
        });
      }
    });
  }

  void _startNextRemoval() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _animPhase = 0;
          _animProgress = 0;
          _playSound('snap');
        });
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
      } else if (type == 'scan') {
        await _scanPlayer.play(AssetSource('audio/class7/mixkit_2869.mp3'), volume: 0.3); // Reusing weld sound for scan
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
      _zoom = 0.9;
      _panX = 0;
      _panY = 30;

      _animating = false;
      _animPhase = 0;
      _animProgress = 0;
      _armHasToken = false;
      _isDragging = false;
      _dragColor = null;

      if (_scenario == 1) {
        _tokenType = 'positive'; _totalTokens = 12; _hopperTokens = 12; _numBins = 4; _binTokens = [0,0,0,0]; _movedTokens = 0;
      } else if (_scenario == 2) {
        _tokenType = 'negative'; _totalTokens = 8; _hopperTokens = 8; _numBins = 2; _binTokens = [0,0]; _movedTokens = 0;
      } else if (_scenario == 3) {
        _removalsDone = 0; _totalRemovals = 5;
      } else if (_scenario == 4) {
        _removalsDone = 0; _totalRemovals = 3;
      } else if (_scenario == 5) {
        _removalsDone = 0; _totalRemovals = 6;
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
    int maxSteps = (_scenario == 3) ? 4 : 3;
    setState(() => _step = maxSteps);
    _playSound('success');
    _scrollToActiveStep();
    if (_scenario == 5) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccessPopup = true);
      });
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

    if ((_scenario == 4 || _scenario == 5) && _step > 0 && _step < 3 && !_isDragging) {
      double bankX = -200; double bankY = 110;
      String requiredDragColor = _scenario == 4 ? 'negative' : 'positive';

      // Expanded hitbox for easier token grabbing in the bank
      if (pt.dx > bankX - 160 && pt.dx < bankX + 160 && pt.dy > bankY - 200 && pt.dy < bankY + 40) {
        setState(() {
          _isDragging = true;
          _dragColor = requiredDragColor;
          _dragX = pt.dx;
          _dragY = pt.dy;
        });
        _playSound('snap');
        return;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      if (_isDragging) {
        _dragX = pt.dx;
        _dragY = pt.dy;
      } else {
        _zoom = (_baseZoom * details.scale).clamp(0.3, 2.0);
        _panX = _basePan.dx + (details.localFocalPoint.dx - _baseFocalPoint.dx);
        _panY = _basePan.dy + (details.localFocalPoint.dy - _baseFocalPoint.dy);
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_isDragging) {
      setState(() {
        double chuteX = -360; double chuteY = 100;
        String requiredDragColor = _scenario == 4 ? 'negative' : 'positive';

        // Expanded hitbox for easier dropping into the disposal chute
        if (_dragX > chuteX - 120 && _dragX < chuteX + 120 && _dragY > chuteY - 120 && _dragY < chuteY + 180) {
          if (_dragColor == requiredDragColor) {
            _playSound('pop');
            _removalsDone++;
            if (_removalsDone == 1) _advanceStep(); // Step 2 complete
            if (_removalsDone >= _totalRemovals) {
              _advanceStep(); // Final Step
              _checkScenarioSuccess();
            }
          } else {
            _playSound('error');
          }
        } else {
          _playSound('error'); // Snapped back
        }
        _isDragging = false;
        _dragColor = null;
      });
    }
  }

  void _runMachine() {
    if (_animating) return;

    setState(() {
      if ((_scenario == 1 || _scenario == 2) && _step == 1) {
        _animating = true;
        _startNextMove();
      } else if (_scenario == 3 && _step == 1) {
        _animating = true;
        _removalsDone = 0;
        if (_removalsDone == 0) _advanceStep();
        _startNextRemoval();
      }
    });
  }

  int _getMaxStepsForScenario(int scenarioId) {
     return (scenarioId == 3) ? 4 : 3;
  }

  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);

    int maxSteps = _getMaxStepsForScenario(_scenario);

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
            Padding(
              padding: const EdgeInsets.fromLTRB(70, 20, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.precision_manufacturing, color: Colors.indigoAccent),
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

                  ...List.generate(maxSteps, (i) {
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
                  
                  if (_step == maxSteps) ...[
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
                    if (_scenario < 5)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orangeAccent.withOpacity(0.5))),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(t('tryNextScenario'), style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold))),
                          ]
                        )
                      )
                  ]
                ],
              ),
            ),
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

  Widget _buildOverlayButton(String label, double worldX, double worldY, Color color, VoidCallback onTap, BoxConstraints constraints, {IconData? icon, bool disabled = false, Color textColor = Colors.white}) {
    double screenX = constraints.maxWidth / 2 + _panX + worldX * _zoom;
    double screenY = constraints.maxHeight / 2 + _panY + worldY * _zoom;

    return Positioned(
      left: screenX - 110,
      top: screenY - 25,
      child: Transform.scale(
        scale: _zoom.clamp(0.8, 1.2),
        child: ElevatedButton.icon(
          onPressed: disabled ? null : () { _playSound('pop'); onTap(); },
          icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 10,
            shadowColor: color.withOpacity(0.6),
            side: const BorderSide(color: Color(0xFF0F172A), width: 3)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;
    if (sidebarWidth < 300) sidebarWidth = 300;

    int maxSteps = _getMaxStepsForScenario(_scenario);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // CANVAS AREA
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(behavior: HitTestBehavior.opaque, 
                      onTap: () { SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); },
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size.infinite,
                            painter: TokenFactoryPainter(
                              lang: _lang, scenario: _scenario, step: _step, zoom: _zoom, panX: _panX, panY: _panY,
                              animating: _animating, animPhase: _animPhase, animProgress: _animProgress,
                              tokenType: _tokenType, hopperTokens: _hopperTokens, numBins: _numBins, binTokens: _binTokens,
                              armHasToken: _armHasToken, targetBinIndex: _targetBinIndex, removalsDone: _removalsDone, totalRemovals: _totalRemovals,
                              isDragging: _isDragging, dragColor: _dragColor, dragX: _dragX, dragY: _dragY,
                              t: t, screenSize: constraints.biggest,
                            ),
                          ),
                          
                          if ((_scenario == 1 || _scenario == 2 || _scenario == 3) && _step == 1 && !_animating)
                             _buildOverlayButton(t('lbl_start'), _scenario == 3 ? 310 : 335, -20, const Color(0xFF4ADE80), _runMachine, constraints, textColor: const Color(0xFF0F172A)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // FLOATING ACTIVE STEP (Visible when Sidebar is Closed)
            if (!_isSidebarOpen && _step < maxSteps)
              Positioned(
                left: _floatingStepPos.dx,
                top: _floatingStepPos.dy,
                child: GestureDetector(behavior: HitTestBehavior.opaque, 
                  onPanUpdate: (details) {
                    setState(() { _floatingStepPos += details.delta; });
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(12),
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
                            const Icon(Icons.drag_indicator, color: Colors.white54, size: 20),
                            const SizedBox(width: 4),
                            const Icon(Icons.info_outline, color: Colors.indigoAccent, size: 18),
                            const SizedBox(width: 8),
                            Text("${t('stepLabel')} ${_step + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildRichText(t('s${_scenario}_step${_step + 1}_task'), Colors.white),
                        if (_step == 0) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _advanceStep,
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(t('proceedBtn')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 10,
                              ),
                            ),
                          )
                        ]
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20), border: const Border(top: BorderSide(color: Colors.indigoAccent, width: 4))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.indigoAccent),
                          const SizedBox(width: 12),
                          Flexible(child: Text(t('s${_scenario}_hud${_step + 1}'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center))
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // GLOBAL PROCEED BUTTON
            if (_step == 0 && _isSidebarOpen)
              Positioned(
                bottom: 40,
                right: 40,
                child: ElevatedButton.icon(
                  onPressed: _advanceStep,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(t('proceedBtn')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                )
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

            // MENU ICON ONLY (No Back Button)
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.8)))),
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
                                Container(width: 80, height: 80, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 20)]), child: const Icon(Icons.flag, color: Colors.white, size: 40)),
                                const SizedBox(height: 24),
                                Text(t('labCompleted'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                Text(t('finalDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70)),
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
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
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
                          Container(width: 120, height: 120, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]), child: const Icon(Icons.precision_manufacturing, size: 80, color: Colors.white)),
                          Text(t('appTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2)),
                          const SizedBox(height: 16),
                          Text(t('appSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                              onPressed: () {
                                _playSound('enter');
                                setState(() => _showCurtain = false);
                              },
                              icon: const Icon(Icons.play_circle_fill, size: 28),
                              label: Text(t('enterLab')),
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, elevation: 10, shadowColor: Colors.indigoAccent.withOpacity(0.5), textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
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

class TokenFactoryPainter extends CustomPainter {
  final String lang;
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;
  
  final bool animating;
  final int animPhase;
  final double animProgress;
  
  final String tokenType;
  final int hopperTokens;
  final int numBins;
  final List<int> binTokens;
  final bool armHasToken;
  final int targetBinIndex;
  
  final int removalsDone;
  final int totalRemovals;

  final bool isDragging;
  final String? dragColor;
  final double dragX;
  final double dragY;

  final Function(String) t;
  final Size screenSize;

  TokenFactoryPainter({
    required this.lang, required this.scenario, required this.step,
    required this.zoom, required this.panX, required this.panY,
    required this.animating, required this.animPhase, required this.animProgress,
    required this.tokenType, required this.hopperTokens, required this.numBins, required this.binTokens,
    required this.armHasToken, required this.targetBinIndex,
    required this.removalsDone, required this.totalRemovals,
    required this.isDragging, required this.dragColor, required this.dragX, required this.dragY,
    required this.t, required this.screenSize,
  });

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, double strokeW) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && strokeW > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
  }

  void _drawTextOutline(Canvas canvas, String text, double x, double y, double fontSize, Color fill, Color outline, double outlineW, [TextAlign align = TextAlign.center, String family = 'Plus Jakarta Sans']) {
    if (outlineW > 0) {
      TextPainter tpStroke = TextPainter(
        text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: family, foreground: Paint()..style=PaintingStyle.stroke..strokeWidth=outlineW..color=outline..strokeJoin=StrokeJoin.round)),
        textDirection: TextDirection.ltr, textAlign: align
      );
      tpStroke.layout();
      double dx = align == TextAlign.center ? x - tpStroke.width/2 : x;
      tpStroke.paint(canvas, Offset(dx, y - tpStroke.height/2));
    }
    TextPainter tpFill = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: family)),
      textDirection: TextDirection.ltr, textAlign: align
    );
    tpFill.layout();
    double dx = align == TextAlign.center ? x - tpFill.width/2 : x;
    tpFill.paint(canvas, Offset(dx, y - tpFill.height/2));
  }

  void _drawGear(Canvas canvas, double x, double y, double radius, int teeth, Color color, double rotation) {
    canvas.save(); canvas.translate(x, y); canvas.rotate(rotation);
    Path p = Path();
    double innerRadius = radius * 0.7; double holeRadius = radius * 0.3;
    for(int i=0; i<teeth; i++) {
        double a = i * pi * 2 / teeth; double a1 = a + 0.05; double a2 = a + pi*2/teeth*0.4;
        double a3 = a2 + 0.05; double a4 = a + pi*2/teeth;
        if(i==0) p.moveTo(cos(a1)*radius, sin(a1)*radius); else p.lineTo(cos(a1)*radius, sin(a1)*radius);
        p.lineTo(cos(a2)*radius, sin(a2)*radius); p.lineTo(cos(a3)*innerRadius, sin(a3)*innerRadius); p.lineTo(cos(a4)*innerRadius, sin(a4)*innerRadius);
    }
    p.close(); canvas.drawPath(p, Paint()..color = color..style = PaintingStyle.fill); 
    canvas.drawPath(p, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawCircle(Offset.zero, holeRadius, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawCircle(Offset.zero, holeRadius, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.restore();
  }

  void _drawToken(Canvas canvas, double cx, double cy, String type) {
    canvas.save(); canvas.translate(cx, cy);
    Color fill = type == 'positive' ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    canvas.drawCircle(Offset.zero, 12, Paint()..color = fill);
    canvas.drawCircle(Offset.zero, 12, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.restore();
  }

  void _drawZeroPair(Canvas canvas, double cx, double cy) {
    _drawToken(canvas, cx - 6, cy, 'positive');
    _drawToken(canvas, cx + 6, cy, 'negative');
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    canvas.drawRect(Rect.fromLTWH(-screenSize.width*2, -screenSize.height*2, screenSize.width*4, screenSize.height*4), Paint()..color=const Color(0xFFE2E8F0));

    double time = DateTime.now().millisecondsSinceEpoch.toDouble();
    _drawGear(canvas, -400, -150, 70, 8, const Color(0xFFCBD5E1), time * 0.0005);
    _drawGear(canvas, 420, -50, 90, 10, const Color(0xFFCBD5E1), -time * 0.0003);
    _drawGear(canvas, 380, 200, 60, 6, const Color(0xFFCBD5E1), time * 0.0006);

    const Color outlineCol = Color(0xFF0F172A);
    const double outlineW = 4.0;
    const Color glassFill = Color(0x80E0F2FE); // Alpha 0.5

    if (scenario == 1 || scenario == 2) {
      // Screen
      _drawRoundedRect(canvas, -210, -260, 420, 110, 12, const Color(0xFFCBD5E1), outlineCol, outlineW);
      _drawRoundedRect(canvas, -195, -245, 390, 80, 6, Colors.white, outlineCol, outlineW);  
      
      String eqStr = scenario == 1 ? "4 × ? = 12" : "2 × ? = -8";
      if (step >= 2) eqStr = scenario == 1 ? "4 × (+3) = 12" : "2 × (-4) = -8";
      _drawTextOutline(canvas, eqStr, 0, -205, 44, const Color(0xFF0F172A), Colors.transparent, 0, TextAlign.center, 'monospace');

      double bY = 20;
      canvas.drawLine(Offset(-190, bY), Offset(190, bY), Paint()..color = outlineCol..strokeWidth = 3);
      canvas.drawLine(Offset(-190, bY), Offset(-190, bY+15), Paint()..color = outlineCol..strokeWidth = 3);
      canvas.drawLine(Offset(190, bY), Offset(190, bY+15), Paint()..color = outlineCol..strokeWidth = 3);
      _drawTextOutline(canvas, t('lbl_divisor_bins'), 0, bY - 12, 16, const Color(0xFF1E293B), Colors.transparent, 0);

      // Conveyor
      double cY = 150;
      _drawRoundedRect(canvas, -300, cY, 600, 45, 6, const Color(0xFF94A3B8), outlineCol, outlineW);
      for(double i=-280; i<=280; i+=45) {
        canvas.drawCircle(Offset(i, cY+22), 9, Paint()..color = const Color(0xFFCBD5E1));
        canvas.drawCircle(Offset(i, cY+22), 9, Paint()..color = outlineCol..style=PaintingStyle.stroke..strokeWidth = outlineW);
      }
      _drawRoundedRect(canvas, -300, cY+45, 600, 40, 0, const Color(0xFF64748B), outlineCol, outlineW);

      // Bins
      List<double> binX = numBins == 4 ? [-210, -70, 70, 210] : [-100, 100];
      String scannedResTxt = scenario == 1 ? "+3" : "-4";
      
      for(int i=0; i<numBins; i++) {
        bool scanning = (animPhase == 99 && animating && i == numBins - 1);
        String? result = (step >= 3 && i == numBins - 1) ? scannedResTxt : null;
        
        canvas.save(); canvas.translate(binX[i], cY - 45);
        List<List<double>> binPos = [[-12, 18], [12, 18], [0, 0], [-12, -18]];
        for(int j=0; j<binTokens[i]; j++) { if(j < binPos.length) _drawToken(canvas, binPos[j][0], binPos[j][1], tokenType); }
        
        Path binPath = Path()..moveTo(-35, -40)..lineTo(35, -40)..lineTo(26, 40)..lineTo(-26, 40)..close();
        canvas.drawPath(binPath, Paint()..color=glassFill);
        canvas.drawPath(binPath, Paint()..color=outlineCol..style=PaintingStyle.stroke..strokeWidth=outlineW..strokeJoin=StrokeJoin.round);
        canvas.drawOval(Rect.fromCenter(center: const Offset(0, -40), width: 70, height: 12), Paint()..color=outlineCol..style=PaintingStyle.stroke..strokeWidth=outlineW);
        
        if (scanning) { 
          double scanY = -35 + animProgress * 70; 
          canvas.drawLine(Offset(-50, scanY), Offset(50, scanY), Paint()..color = const Color(0xFFEF4444)..strokeWidth = 5); 
        }
        
        if (result != null) {
          _drawRoundedRect(canvas, 40, -15, 75, 50, 6, const Color(0xFF1E293B), outlineCol, outlineW);
          Color txtColor = result.contains("+") ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
          _drawTextOutline(canvas, result, 77, 2, 24, txtColor, Colors.transparent, 0, TextAlign.center, 'monospace');
          _drawTextOutline(canvas, "${t('lbl_count')}: ${result.replaceAll(RegExp(r'[+-]'), '')}", 77, 22, 10, txtColor, Colors.transparent, 0);
        }
        canvas.restore();
      }

      // Control Panel
      _drawRoundedRect(canvas, 280, -90, 110, 140, 8, const Color(0xFFCBD5E1), outlineCol, outlineW);
      if (step == 1 && !animating) { _drawRoundedRect(canvas, 295, -40, 80, 40, 8, const Color(0xFF166534), Colors.transparent, 0); }

      // Hopper
      canvas.save(); canvas.translate(-320, -30);
      List<List<double>> tokenPos = [ [0, 45], [0, 25], [-12, 5], [12, 5], [-20, -15], [0, -15], [20, -15], [-25, -35], [-5, -35], [15, -35], [-15, -55], [5, -55] ];
      for(int i=0; i<hopperTokens; i++) { if(i < tokenPos.length) _drawToken(canvas, tokenPos[i][0], tokenPos[i][1], tokenType); }
      
      Path hopperPath = Path()..moveTo(-45, -95)..lineTo(45, -95)..lineTo(45, -10)..lineTo(15, 25)..lineTo(15, 60)..lineTo(-15, 60)..lineTo(-15, 25)..lineTo(-45, -10)..close();
      canvas.drawPath(hopperPath, Paint()..color=glassFill);
      canvas.drawPath(hopperPath, Paint()..color=outlineCol..style=PaintingStyle.stroke..strokeWidth=outlineW..strokeJoin=StrokeJoin.round);
      Path topArc = Path()..moveTo(-45, -95)..quadraticBezierTo(0, -105, 45, -95)..quadraticBezierTo(0, -85, -45, -95);
      canvas.drawPath(topArc, Paint()..color=outlineCol..style=PaintingStyle.stroke..strokeWidth=outlineW);
      canvas.restore();

      // Robotic Arm
      double hX = -320; double hY = 40; 
      double armTargetX = hX; double armTargetY = hY; 
      if (animating && animPhase < 99) {
          double bX = binX[targetBinIndex]; double bY = 55; 
          if (animPhase == 0) { armTargetX = hX + animProgress * (bX - hX); armTargetY = hY + animProgress * (bY - hY) - sin(animProgress * pi) * 60; }
          else if (animPhase == 1) { armTargetX = bX + animProgress * (hX - bX); armTargetY = bY + animProgress * (hY - bY) - sin(animProgress * pi) * 60; }
      }

      _drawRoundedRect(canvas, -370, -180, 100, 24, 6, const Color(0xCCFFFFFF), Colors.transparent, 0);
      _drawTextOutline(canvas, t('lbl_dividend'), -320, -168, 16, const Color(0xFF1E293B), Colors.transparent, 0);

      double pipeX = armTargetX - 90; 
      _drawRoundedRect(canvas, pipeX - 12, -400, 24, 400 + armTargetY - 45, 0, const Color(0xFF94A3B8), outlineCol, outlineW); 
      _drawRoundedRect(canvas, pipeX, armTargetY - 45, armTargetX - pipeX, 20, 0, const Color(0xFFCBD5E1), outlineCol, outlineW); 
      _drawRoundedRect(canvas, armTargetX - 25, armTargetY - 35, 50, 25, 6, const Color(0xFFCBD5E1), outlineCol, outlineW); 
      
      Path clawPath = Path();
      if(armHasToken) {
          clawPath.moveTo(armTargetX - 18, armTargetY - 10); clawPath.lineTo(armTargetX - 22, armTargetY + 15); clawPath.lineTo(armTargetX - 8, armTargetY + 25);
          clawPath.moveTo(armTargetX + 18, armTargetY - 10); clawPath.lineTo(armTargetX + 22, armTargetY + 15); clawPath.lineTo(armTargetX + 8, armTargetY + 25);
      } else {
          clawPath.moveTo(armTargetX - 18, armTargetY - 10); clawPath.lineTo(armTargetX - 30, armTargetY + 15); clawPath.lineTo(armTargetX - 18, armTargetY + 25);
          clawPath.moveTo(armTargetX + 18, armTargetY - 10); clawPath.lineTo(armTargetX + 30, armTargetY + 15); clawPath.lineTo(armTargetX + 18, armTargetY + 25);
      }
      canvas.drawPath(clawPath, Paint()..color=outlineCol..style=PaintingStyle.stroke..strokeWidth=outlineW..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
      
      if (armHasToken) { _drawToken(canvas, armTargetX, armTargetY + 18, tokenType); }

      if (step >= 3 && !animating) {
        _drawRoundedRect(canvas, 150, 200, 360, 65, 12, Colors.white, outlineCol, outlineW);
        String endText = scenario == 1 ? "12 ÷ 4 = +3" : "(-8) ÷ 2 = -4";
        Color endColor = scenario == 1 ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
        _drawTextOutline(canvas, t('lbl_therefore'), 330, 220, 16, const Color(0xFF1E293B), Colors.transparent, 0);
        _drawTextOutline(canvas, endText, 330, 245, 24, endColor, Colors.transparent, 0, TextAlign.center, 'monospace');
      }

    } else if (scenario >= 3 && scenario <= 5) {
      _drawRoundedRect(canvas, -210, -260, 420, 110, 12, const Color(0xFFCBD5E1), outlineCol, outlineW);
      _drawRoundedRect(canvas, -195, -245, 390, 80, 6, Colors.white, outlineCol, outlineW);
      
      String eqStr = "";
      String finalEqStr = "";
      if (scenario == 3) { eqStr = "(-5) × ? = -10"; finalEqStr = "(-5) × (+2) = -10"; }
      if (scenario == 4) { eqStr = "(-3) × ? = 15"; finalEqStr = "(-3) × (-5) = 15"; }
      if (scenario == 5) { eqStr = "(-6) × ? = -18"; finalEqStr = "(-6) × (+3) = -18"; }

      int configSteps = (scenario == 3) ? 4 : 3;
      if (step >= configSteps || removalsDone >= totalRemovals) {
          eqStr = finalEqStr;
      }
      _drawTextOutline(canvas, eqStr, 0, -205, 40, const Color(0xFF0F172A), Colors.transparent, 0, TextAlign.center, 'monospace');

      double bankX = -200; double bankY = 110;
      _drawRoundedRect(canvas, bankX - 140, bankY - 180, 280, 190, 10, glassFill, outlineCol, outlineW);
      _drawRoundedRect(canvas, bankX - 80, bankY - 204, 160, 24, 6, const Color(0xCCFFFFFF), Colors.transparent, 0);
      _drawTextOutline(canvas, t('lbl_zero_pair_bank'), bankX, bankY - 192, 16, const Color(0xFF1E293B), Colors.transparent, 0);
      
      int tokensPerRemoval = scenario == 3 ? 2 : (scenario == 4 ? 5 : 3);
      int activeRemoval = (scenario == 3 && animating && animPhase > 0) ? 1 : 0;
      int previewTokens = isDragging ? tokensPerRemoval : 0;
      int pairsToDraw = max(0, 30 - (removalsDone * tokensPerRemoval) - (activeRemoval * tokensPerRemoval) - previewTokens);

      double startX = bankX - 105;
      double startY = bankY - 30;
      for(int i=0; i<pairsToDraw; i++) {
          double px = startX + (i % 6) * 42;
          double py = startY - (i ~/ 6) * 32;
          _drawZeroPair(canvas, px, py);
      }

      if ((scenario == 4 || scenario == 5) && step > 0 && step < configSteps) {
          String dragLbl = scenario == 4 ? "${t('lbl_drag_red')} →" : "${t('lbl_drag_green')} →";
          Color dragColorC = scenario == 4 ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
          _drawTextOutline(canvas, dragLbl, bankX, bankY - 150, 18, dragColorC, Colors.transparent, 0);
          
          double pulseAlpha = 0.2 + 0.15 * sin(time * 0.005);
          _drawRoundedRect(canvas, bankX - 130, bankY - 170, 260, 170, 8, dragColorC.withOpacity(pulseAlpha), Colors.transparent, 0);
      }

      double chuteX = -360; double chuteY = 100;
      Path chutePath = Path()..moveTo(chuteX - 40, chuteY - 30)..lineTo(chuteX + 40, chuteY - 30)..lineTo(chuteX + 20, chuteY + 80)..lineTo(chuteX - 20, chuteY + 80)..close();
      canvas.drawPath(chutePath, Paint()..color = const Color(0xFF64748B));
      canvas.drawPath(chutePath, Paint()..color = outlineCol..style = PaintingStyle.stroke..strokeWidth = outlineW);
      _drawRoundedRect(canvas, chuteX - 45, chuteY - 45, 90, 15, 4, const Color(0xFF94A3B8), outlineCol, outlineW);
      _drawTextOutline(canvas, t('lbl_disposal'), chuteX, chuteY - 65, 14, const Color(0xFF1E293B), Colors.transparent, 0);
      _drawRoundedRect(canvas, chuteX - 50, chuteY + 80, 100, 30, 4, const Color(0xFF94A3B8), outlineCol, outlineW);
      
      double targetX = 140; double targetY = 100;
      _drawRoundedRect(canvas, targetX - 120, targetY - 25, 240, 95, 8, glassFill, outlineCol, outlineW);
      _drawTextOutline(canvas, t('lbl_target'), targetX, targetY - 40, 16, const Color(0xFF1E293B), Colors.transparent, 0);
      
      String tarVal = scenario == 3 ? "-10" : (scenario == 4 ? "+15" : "-18");
      _drawRoundedRect(canvas, targetX + 130, targetY + 10, 60, 45, 6, const Color(0xFF1E293B), outlineCol, outlineW);
      _drawTextOutline(canvas, tarVal, targetX + 160, targetY + 32, 24, const Color(0xFF64748B), Colors.transparent, 0, TextAlign.center, 'monospace');

      _drawRoundedRect(canvas, -380, 150, 760, 40, 0, const Color(0xFF64748B), outlineCol, outlineW);

      int targetTokensCount = (removalsDone * tokensPerRemoval) + (activeRemoval * tokensPerRemoval) + previewTokens;
      String tType = (scenario == 3 || scenario == 5) ? 'negative' : 'positive';
      double startTx = targetX - 95;
      double startTy = targetY + 50;
      
      for (int i = 0; i < targetTokensCount; i++) {
          double tx = startTx + (i % 7) * 32;
          double ty = startTy - (i ~/ 7) * 28;
          if (isDragging && i >= removalsDone * tokensPerRemoval) {
              canvas.saveLayer(null, Paint()..color = const Color(0x80FFFFFF));
          }
          _drawToken(canvas, tx, ty, tType);
          if (isDragging && i >= removalsDone * tokensPerRemoval) {
              canvas.restore();
          }
      }

      double panelX = 330; double panelY = -30;
      _drawRoundedRect(canvas, panelX - 55, panelY - 70, 110, 120, 8, const Color(0xFFCBD5E1), outlineCol, outlineW);
      _drawRoundedRect(canvas, panelX - 45, panelY - 50, 90, 35, 4, const Color(0xFF1E293B), outlineCol, outlineW);
      _drawTextOutline(canvas, "${t('lbl_removals')}:", panelX, panelY - 40, 10, const Color(0xFF94A3B8), Colors.transparent, 0);
      _drawTextOutline(canvas, "$removalsDone/$totalRemovals", panelX, panelY - 25, 16, const Color(0xFF22C55E), Colors.transparent, 0, TextAlign.center, 'monospace');
      if (scenario == 3 && step == 1 && !animating) {
          _drawRoundedRect(canvas, panelX - 40, panelY, 80, 40, 8, const Color(0xFF166534), Colors.transparent, 0); 
      }

      if (scenario == 3) {
          double restX = bankX; double restY = -120;
          double grabY = bankY - 30;
          double armTargetX = restX; double armTargetY = restY;

          if (animating) {
              if (animPhase == 0) {
                  armTargetX = restX; armTargetY = restY + animProgress * (grabY - restY);
              } else if (animPhase == 1) {
                  armTargetX = bankX + animProgress * (chuteX - bankX);
                  armTargetY = grabY + animProgress * (chuteY - 60 - grabY) - sin(animProgress * pi) * 100;
              } else if (animPhase == 2) {
                  armTargetX = chuteX + animProgress * (restX - chuteX);
                  armTargetY = (chuteY - 60) + animProgress * (restY - (chuteY - 60)) - sin(animProgress * pi) * 100;
              }
          }

          double pipeX = armTargetX - 90;
          _drawRoundedRect(canvas, pipeX - 12, -400, 24, 400 + armTargetY - 45, 0, const Color(0xFF94A3B8), outlineCol, outlineW); 
          _drawRoundedRect(canvas, pipeX, armTargetY - 45, armTargetX - pipeX, 20, 0, const Color(0xFFCBD5E1), outlineCol, outlineW); 
          _drawRoundedRect(canvas, armTargetX - 25, armTargetY - 35, 50, 25, 6, const Color(0xFFCBD5E1), outlineCol, outlineW); 
          
          Path clawPath = Path();
          if(armHasToken) { 
              clawPath.moveTo(armTargetX - 18, armTargetY - 10); clawPath.lineTo(armTargetX - 28, armTargetY + 15); clawPath.lineTo(armTargetX - 14, armTargetY + 30);
              clawPath.moveTo(armTargetX + 18, armTargetY - 10); clawPath.lineTo(armTargetX + 28, armTargetY + 15); clawPath.lineTo(armTargetX + 14, armTargetY + 30);
          } else {
              clawPath.moveTo(armTargetX - 18, armTargetY - 10); clawPath.lineTo(armTargetX - 35, armTargetY + 15); clawPath.lineTo(armTargetX - 22, armTargetY + 30);
              clawPath.moveTo(armTargetX + 18, armTargetY - 10); clawPath.lineTo(armTargetX + 35, armTargetY + 15); clawPath.lineTo(armTargetX + 22, armTargetY + 30);
          }
          canvas.drawPath(clawPath, Paint()..color = outlineCol..style = PaintingStyle.stroke..strokeWidth = outlineW..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
          
          if (armHasToken) {
              _drawToken(canvas, armTargetX - 8, armTargetY + 22, 'positive');
              _drawToken(canvas, armTargetX + 8, armTargetY + 22, 'positive');
          }
      }

      if ((scenario == 4 || scenario == 5) && isDragging) {
          int c = scenario == 4 ? 5 : 3;
          for(int i=0; i<c; i++) {
              _drawToken(canvas, dragX + (i - c~/2)*20, dragY, dragColor ?? 'positive');
          }
      }

      if (step >= configSteps && !animating && removalsDone >= totalRemovals && !isDragging) {
          _drawRoundedRect(canvas, -170, 220, 340, 65, 12, Colors.white, outlineCol, outlineW);
          Color endColor = (scenario == 3 || scenario == 5) ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
          _drawTextOutline(canvas, t('lbl_therefore'), 0, 240, 16, const Color(0xFF1E293B), Colors.transparent, 0);
          _drawTextOutline(canvas, finalEqStr, 0, 265, 24, endColor, Colors.transparent, 0, TextAlign.center, 'monospace');
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TokenFactoryPainter oldDelegate) => true;
}

const Map<String, Map<String, String>> _translations = {
  'en': {
    'appTitle': "The Token Factory", 'appSubtitle': "Class 7 • OPERATIONS WITH INTEGERS", 'enterLab': "Enter Lab",
    'settings': "Settings", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'boardFontSize': "Text Size", 
    'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done", 'proceedBtn': "Proceed",
    'learnLbl': "What We Learn:", 'closeBtn': "Close", 'summaryTitle': "Discovery Made!",
    'resetBtn': "Reset", 'finishLab': "Finish Lab", 'tryNextScenario': "Scenario completed! Please select the next scenario from the dropdown above.",
    'labCompleted': "Lab Completed!", 'finalDesc': "You have successfully mastered integer division! You discovered that division is simply working multiplication backward using token groups and removals.",
    'lbl_dividend': "DIVIDEND", 'lbl_divisor_bins': "DIVISOR BINS", 'lbl_zero_pair_bank': "ZERO-PAIR BANK", 'lbl_target': "TARGET", 'lbl_disposal': "DISPOSAL", 'lbl_removals': "REMOVALS", 'lbl_count': "COUNT", 'lbl_therefore': "Therefore,", 'lbl_start': "START", 'lbl_drag_red': "DRAG RED", 'lbl_drag_green': "DRAG GREEN",
    
    's1_title': "1. The Distribution Line", 's1_obj': "To solve 12 ÷ 4 = ? by framing it as 4 × ? = 12. Distributing 12 positive tokens into 4 bins.",
    's1_hud1': "Observe the factory setup. Click 'Proceed' to continue.", 
    's1_step1_task': "<b>Action:</b> Observe the factory setup. You will see a large hopper labeled \"Dividend\" containing 12 green tokens and 4 empty bins below it on a conveyor belt, labeled \"Divisor Bins\". The central screen shows the problem: `4 × ? = 12`.", 
    's1_step1_out': "<b>Observation:</b> The setup represents dividing +12 into 4 equal groups.",
    's1_hud2': "Click 'START' on the machine to distribute tokens.", 
    's1_step2_task': "<b>Action:</b> CLICK the green \"START\" button on the control panel. The machine will automatically start distributing the tokens.", 
    's1_step2_out': "<b>Observation:</b> The robotic arm perfectly distributes the 12 tokens into the 4 bins.",
    's1_hud3': "Observe the scanner counting the tokens.", 
    's1_step3_task': "<b>Action:</b> Observe the result. A scanner will move across one of the bins, count the tokens inside, and display the result on the screen.", 
    's1_step3_out': "<b>Learning:</b> The scanner finds +3 in each bin. Therefore, 12 ÷ 4 = +3.",
    's1_sum': "<b>Production Complete!</b> (+12) ÷ (+4) = +3.",
    
    's2_title': "2. The Negative Sorting Challenge", 's2_obj': "To solve (-8) ÷ 2 = ? by framing it as 2 × ? = -8. Distributing 8 negative tokens into 2 bins.",
    's2_hud1': "Observe the new setup with red tokens. Click 'Proceed'.",
    's2_step1_task': "<b>Action:</b> Observe the new factory setup. The \"Dividend\" hopper now contains 8 red tokens. There are 2 \"Divisor Bins\" on the conveyor belt. The central screen shows `2 × ? = -8`.",
    's2_step1_out': "<b>Observation:</b> We are dividing -8 into 2 equal groups.",
    's2_hud2': "Click 'START' to distribute.",
    's2_step2_task': "<b>Action:</b> CLICK the \"START\" button. The machine will distribute the red tokens into the two bins.",
    's2_step2_out': "<b>Observation:</b> The machine evenly distributes the 8 red tokens, placing 4 in each of the 2 bins.",
    's2_hud3': "Observe the scanner.",
    's2_step3_task': "<b>Action:</b> Observe the scanner as it counts the tokens in one bin to reveal the answer.",
    's2_step3_out': "<b>Learning:</b> The scanner finds -4. Therefore, (-8) ÷ 2 = -4.",
    's2_sum': "<b>Production Complete!</b> (-8) ÷ (+2) = -4.",

    's3_title': "3. The Zero-Pair Extractor", 's3_obj': "To solve (-10) ÷ (-5) = ? by framing it as (-5) × ? = -10. Removing 5 groups of negative tokens.",
    's3_hud1': "Observe the Zero-Pair Bank. Click 'Proceed'.",
    's3_step1_task': "<b>Action:</b> Observe the setup. The 'Zero-Pair Bank' is filled with green/red pairs (value = 0). The target is -10. Control reads `5 Removals`. Screen asks `(-5) × ? = -10`.",
    's3_step1_out': "<b>Observation:</b> We need to achieve -10 by removing tokens 5 times.",
    's3_hud2': "Click 'START' to begin removals.",
    's3_step2_task': "<b>Action:</b> CLICK 'START'. The machine will begin extraction. A robotic claw descends.",
    's3_step2_out': "<b>Observation:</b> The machine begins the extraction process automatically.",
    's3_hud3': "Watch the tokens carefully.",
    's3_step3_task': "<b>Action:</b> Watch carefully. The claw grabs 2 GREEN tokens and moves them to Disposal. The red partners go to the Target.",
    's3_step3_out': "<b>Observation:</b> Removing positive tokens leaves negative tokens behind.",
    's3_hud4': "Wait for the process to complete.",
    's3_step4_task': "<b>Action:</b> The machine repeats this 5 times. Observe the final target result.",
    's3_step4_out': "<b>Learning:</b> After 5 removals of +2, we get -10. Therefore, (-10) ÷ (-5) = +2.",
    's3_sum': "<b>Extraction Complete!</b> (-10) ÷ (-5) = +2.",

    's4_title': "4. Your Turn to Extract", 's4_obj': "Solve 15 ÷ (-3) = ? by figuring out what to remove 3 times to be left with +15.",
    's4_hud1': "It's your turn. Target is +15. Click 'Proceed'.",
    's4_step1_task': "<b>Action:</b> The factory is reset. The \"Zero-Pair Bank\" is full. Target is \"+15\". Removals: 3. Screen asks `(-3) × ? = 15`. You will operate the claw.",
    's4_step1_out': "<b>Observation:</b> We need to remove 3 groups of tokens to leave +15 behind.",
    's4_hud2': "Drag a bundle of RED tokens to Disposal.",
    's4_step2_task': "<b>Action:</b> To leave green tokens behind, you must remove red tokens. DRAG RED tokens from the Bank to the DISPOSAL chute.",
    's4_step2_out': "<b>Observation:</b> Removing 5 red tokens correctly leaves 5 green tokens in the Target.",
    's4_hud3': "Repeat this process 2 more times.",
    's4_step3_task': "<b>Action:</b> DRAG RED tokens two more times to reach the target of +15.",
    's4_step3_out': "<b>Learning:</b> You removed 5 NEGATIVE tokens 3 times. Therefore, 15 ÷ (-3) = -5.",
    's4_sum': "<b>Extraction Complete!</b> 15 ÷ (-3) = -5.",

    's5_title': "5. The Final Challenge", 's5_obj': "Solve (-18) ÷ (-6) = ? by figuring out what to remove 6 times to be left with -18.",
    's5_hud1': "Final Challenge! Target is -18. Click 'Proceed'.",
    's5_step1_task': "<b>Action:</b> The factory is ready. The \"Zero-Pair Bank\" is full. Target is \"-18\". Removals: 6. Screen asks `(-6) × ? = -18`.",
    's5_step1_out': "<b>Observation:</b> We need to leave negative tokens behind, so we must remove positive tokens.",
    's5_hud2': "Drag GREEN tokens to Disposal.",
    's5_step2_task': "<b>Action:</b> DRAG the correct number of GREEN tokens from the Bank to the DISPOSAL chute.",
    's5_step2_out': "<b>Observation:</b> Removing 3 green tokens correctly leaves 3 red tokens in the Target.",
    's5_hud3': "Repeat until target is reached.",
    's5_step3_task': "<b>Action:</b> Continue dragging GREEN tokens until you reach the target of -18.",
    's5_step3_out': "<b>Learning:</b> You removed 3 POSITIVE tokens 6 times. Therefore, (-18) ÷ (-6) = +3.",
    's5_sum': "<b>Challenge Complete!</b> (-18) ÷ (-6) = +3.",
    'footer': "ZEROSCIENCELAB - Fall in Love with Math and Science"
  },
  'hi': {
    'appTitle': "टोकन फैक्टरी", 'appSubtitle': "कक्षा 7 • पूर्णांक संचालन", 'enterLab': "प्रवेश करें",
    'settings': "सेटिंग्स", 'theme': "थीम", 'darkMode': "डार्क मोड", 'lightMode': "लाइट मोड", 'boardFontSize': "टेक्स्ट आकार",
    'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण", 'proceedBtn': "आगे बढ़ें",
    'learnLbl': "हम क्या सीखते हैं:", 'closeBtn': "बंद करें", 'summaryTitle': "खोज!",
    'resetBtn': "रीसेट", 'finishLab': "समाप्त करें", 'tryNextScenario': "परिदृश्य पूरा हुआ! कृपया ऊपर दिए गए ड्रॉपडाउन से अगला परिदृश्य चुनें।",
    'labCompleted': "लैब पूरी हुई!", 'finalDesc': "आपने पूर्णांक विभाजन में महारत हासिल कर ली है! विभाजन गुणा का उल्टा है।",
    'lbl_dividend': "भाज्य", 'lbl_divisor_bins': "भाजक डिब्बे", 'lbl_zero_pair_bank': "शून्य-जोड़ी बैंक", 'lbl_target': "लक्ष्य", 'lbl_disposal': "निपटान", 'lbl_removals': "निकासी", 'lbl_count': "गिनती", 'lbl_therefore': "इसलिए,", 'lbl_start': "प्रारंभ", 'lbl_drag_red': "लाल खींचें", 'lbl_drag_green': "हरा खींचें",
    
    's1_title': "1. वितरण लाइन", 's1_obj': "12 ÷ 4 = ? को 4 × ? = 12 के रूप में हल करना। 12 टोकन को 4 डिब्बों में बांटना।",
    's1_hud1': "फैक्टरी देखें। 'आगे बढ़ें' पर क्लिक करें।",
    's1_step1_task': "<b>कार्रवाई:</b> 12 हरे टोकन और 4 खाली डिब्बे देखें। स्क्रीन: `4 × ? = 12`.",
    's1_step1_out': "<b>अवलोकन:</b> हम +12 को 4 समान समूहों में विभाजित कर रहे हैं।",
    's1_hud2': "'प्रारंभ' पर क्लिक करें।",
    's1_step2_task': "<b>कार्रवाई:</b> \"प्रारंभ\" पर क्लिक करें। मशीन टोकन वितरित करेगी।",
    's1_step2_out': "<b>अवलोकन:</b> रोबोट 12 टोकन को 4 डिब्बों में बांटता है।",
    's1_hud3': "स्कैनर देखें।",
    's1_step3_task': "<b>कार्रवाई:</b> स्कैनर को डिब्बे में टोकन गिनते हुए देखें।",
    's1_step3_out': "<b>सीख:</b> स्कैनर को +3 मिलता है। इसलिए, 12 ÷ 4 = +3.",
    's1_sum': "<b>उत्पादन पूर्ण!</b> (+12) ÷ (+4) = +3.",
    
    's2_title': "2. नकारात्मक छंटाई", 's2_obj': "(-8) ÷ 2 = ? को 2 × ? = -8 के रूप में हल करना। 8 लाल टोकन को 2 डिब्बों में बांटना।",
    's2_hud1': "नया सेटअप देखें। 'आगे बढ़ें' पर क्लिक करें।",
    's2_step1_task': "<b>कार्रवाई:</b> 8 लाल टोकन और 2 खाली डिब्बे देखें। स्क्रीन: `2 × ? = -8`.",
    's2_step1_out': "<b>अवलोकन:</b> हम -8 को 2 समूहों में विभाजित कर रहे हैं।",
    's2_hud2': "'प्रारंभ' पर क्लिक करें।",
    's2_step2_task': "<b>कार्रवाई:</b> \"प्रारंभ\" पर क्लिक करें। मशीन लाल टोकन वितरित करेगी।",
    's2_step2_out': "<b>अवलोकन:</b> मशीन 2 डिब्बों में प्रत्येक में 4 टोकन रखती है।",
    's2_hud3': "स्कैनर देखें।",
    's2_step3_task': "<b>कार्रवाई:</b> स्कैनर को परिणाम गिनते हुए देखें।",
    's2_step3_out': "<b>सीख:</b> स्कैनर को -4 मिलता है। इसलिए, (-8) ÷ 2 = -4.",
    's2_sum': "<b>उत्पादन पूर्ण!</b> (-8) ÷ (+2) = -4.",

    's3_title': "3. शून्य-जोड़ी निष्कर्षक", 's3_obj': "(-10) ÷ (-5) = ? को (-5) × ? = -10 के रूप में हल करना। 5 बार नकारात्मक टोकन निकालना।",
    's3_hud1': "शून्य-जोड़ी बैंक देखें। 'आगे बढ़ें' पर क्लिक करें।",
    's3_step1_task': "<b>कार्रवाई:</b> सेटअप देखें। 'शून्य-जोड़ी बैंक' हरे/लाल जोड़े (मूल्य=0) से भरा है। लक्ष्य -10 है। स्क्रीन `(-5) × ? = -10` पूछती है।",
    's3_step1_out': "<b>अवलोकन:</b> हमें 5 बार टोकन हटाकर -10 प्राप्त करना है।",
    's3_hud2': "'प्रारंभ' पर क्लिक करें।",
    's3_step2_task': "<b>कार्रवाई:</b> 'प्रारंभ' पर क्लिक करें। मशीन निष्कर्षण शुरू करेगी। पंजा नीचे आता है।",
    's3_step2_out': "<b>अवलोकन:</b> मशीन स्वचालित रूप से प्रक्रिया शुरू करती है।",
    's3_hud3': "टोकन को ध्यान से देखें।",
    's3_step3_task': "<b>कार्रवाई:</b> पंजा 2 हरे टोकन पकड़ता है और उन्हें कचरे में डालता है। लाल जोड़े लक्ष्य पर जाते हैं।",
    's3_step3_out': "<b>अवलोकन:</b> सकारात्मक टोकन हटाने से नकारात्मक टोकन पीछे छूट जाते हैं।",
    's3_hud4': "प्रक्रिया पूरी होने की प्रतीक्षा करें।",
    's3_step4_task': "<b>कार्रवाई:</b> मशीन इसे 5 बार दोहराती है। अंतिम परिणाम देखें।",
    's3_step4_out': "<b>सीख:</b> +2 के 5 निष्कासन के बाद, हमें -10 मिलता है। इसलिए, (-10) ÷ (-5) = +2.",
    's3_sum': "<b>प्रक्रिया पूर्ण!</b> (-10) ÷ (-5) = +2.",

    's4_title': "4. आपकी बारी (निकालें)", 's4_obj': "15 ÷ (-3) = ? को हल करने के लिए पता लगाएं कि 3 बार क्या निकालना है।",
    's4_hud1': "यह आपकी बारी है। लक्ष्य +15 है। 'आगे बढ़ें' पर क्लिक करें।",
    's4_step1_task': "<b>कार्रवाई:</b> बैंक भरा है। लक्ष्य +15 है। निकासी: 3। आपको काम करना है।",
    's4_step1_out': "<b>अवलोकन:</b> हमें +15 छोड़ने के लिए 3 समूह निकालने होंगे।",
    's4_hud2': "लाल टोकन को निपटान में खींचें।",
    's4_step2_task': "<b>कार्रवाई:</b> बैंक से लाल टोकन को निपटान में खींचें।",
    's4_step2_out': "<b>अवलोकन:</b> लाल टोकन हटाने से हरे टोकन बच जाते हैं।",
    's4_hud3': "इसे 2 बार और करें।",
    's4_step3_task': "<b>कार्रवाई:</b> लक्ष्य तक पहुंचने के लिए लाल टोकन को फिर से खींचें।",
    's4_step3_out': "<b>सीख:</b> आपने 3 बार नकारात्मक टोकन निकाले। इसलिए, 15 ÷ (-3) = -5.",
    's4_sum': "<b>प्रक्रिया पूर्ण!</b> 15 ÷ (-3) = -5.",

    's5_title': "5. अंतिम चुनौती", 's5_obj': "(-18) ÷ (-6) = ? को हल करने के लिए 6 बार सकारात्मक टोकन निकालें।",
    's5_hud1': "लक्ष्य -18 है। 'आगे बढ़ें' पर क्लिक करें।",
    's5_step1_task': "<b>कार्रवाई:</b> बैंक भरा है। लक्ष्य -18 है। निकासी: 6। आपको काम करना है।",
    's5_step1_out': "<b>अवलोकन:</b> हमें -18 छोड़ने के लिए 6 समूह निकालने होंगे।",
    's5_hud2': "हरे टोकन को निपटान में खींचें।",
    's5_step2_task': "<b>कार्रवाई:</b> बैंक से हरे टोकन को निपटान में खींचें।",
    's5_step2_out': "<b>अवलोकन:</b> हरे टोकन हटाने से लाल टोकन बच जाते हैं।",
    's5_hud3': "लक्ष्य तक पहुंचें।",
    's5_step3_task': "<b>कार्रवाई:</b> लक्ष्य तक पहुंचने के लिए हरे टोकन को फिर से खींचें।",
    's5_step3_out': "<b>सीख:</b> आपने 6 बार सकारात्मक टोकन निकाले। इसलिए, (-18) ÷ (-6) = +3.",
    's5_sum': "<b>प्रक्रिया पूर्ण!</b> (-18) ÷ (-6) = +3."
  }
};
