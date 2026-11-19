// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RhsLabApp());
}

class RhsLabApp extends StatelessWidget {
  const RhsLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | RHS Congruence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const RHSCongruenceLab(),
    );
  }
}

class RHSCongruenceLab extends StatefulWidget {
  const RHSCongruenceLab({super.key});

  @override
  State<RHSCongruenceLab> createState() => _RHSCongruenceLabState();
}

class _RHSCongruenceLabState extends State<RHSCongruenceLab> with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;

  // Lab State
  int _scenario = 1;
  int _step = 0;
  bool _showSuccessPopup = false;

  // Viewport State
  double _zoom = 1.0;
  double _panX = 0;
  double _panY = 0;
  double _baseZoom = 1.0;
  Offset _basePan = Offset.zero;

  // Simulation State
  String? _toolDragging;
  Offset _dragOffset = Offset.zero;

  double _triX = 60;
  double _triY = 80;
  bool _superimposed = false;
  double _rotation = 0;
  bool _isFlipped = false;
  bool _isShaking = false;
  int _glowStage = 0;
  bool _showMismatchStamp = false;

  Map<int, Offset> _partPos = {
    1: const Offset(40, 0),
    2: const Offset(240, 0),
    3: const Offset(40, 150),
    4: const Offset(240, 150)
  };
  int? _shakingPart;
  int? _redPart;

  Map<String, bool> _bridgeParts = {'beamV': false, 'conn': false, 'beamH': false};
  double _toolX = 0;
  double _toolY = 0;

  // Audio Engine
  final AudioPlayer _player = AudioPlayer();

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
    // Note: The automatic curtain raiser has been removed. 
    // It now requires manual interaction via the "Enter Lab" button.
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _player.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    String url;
    switch (type) {
      case 'enter':
        url = 'audio/class7/mixkit_2568.mp3';
        break;
      case 'pop':
        url = 'audio/class7/mixkit_268.mp3';
        break;
      case 'success':
        url = 'audio/class7/mixkit_2018.mp3';
        break;
      case 'error':
        url = 'audio/class7/mixkit_955.mp3';
        break;
      case 'snap':
      case 'weld':
        url = 'audio/class7/mixkit_2568.mp3';
        break;
      case 'tick':
        url = 'audio/class7/mixkit_2568.mp3'; // using generic tap
        break;
      default:
        return;
    }
    
    // Wrapped in try-catch to prevent TimeoutExceptions or Network errors from crashing the app
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
          _showCurtain = false;
        });
      }
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _toolDragging = null;
      _superimposed = false;
      _rotation = 0;
      _isFlipped = (id == 2);
      _isShaking = false;
      _glowStage = 0;
      _showMismatchStamp = false;

      _partPos = {
        1: const Offset(40, 0),
        2: const Offset(240, 0),
        3: const Offset(40, 150),
        4: const Offset(240, 150)
      };
      _shakingPart = null;
      _redPart = null;
      _bridgeParts = {'beamV': false, 'conn': false, 'beamH': false};

      _toolX = 0;
      _toolY = 0;

      if (id == 1 || id == 2 || id == 3) {
        _triX = (id == 2) ? 336 : 144;
        _triY = 80;
      }
      
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
    });
    _playSound('pop');
  }

  void _triggerShake() async {
    setState(() => _isShaking = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _isShaking = false);
  }

  void _triggerPartShake(int id) async {
    setState(() {
      _shakingPart = id;
      _redPart = id;
      _showMismatchStamp = true;
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _shakingPart = null;
        _redPart = null;
        _showMismatchStamp = false;
        // Reset positions
        _partPos[1] = const Offset(40, 0);
        _partPos[2] = const Offset(240, 0);
        _partPos[3] = const Offset(40, 150);
        _partPos[4] = const Offset(240, 150);
      });
    }
  }

  void _evaluateStepConditions() {
    bool advanced = false;
    if (_scenario == 1 && _step == 2 && _superimposed) advanced = true;
    else if (_scenario == 2) {
      if (_step == 0 && !_isFlipped) advanced = true;
      if (_step == 1 && _superimposed) advanced = true;
    } else if (_scenario == 3 && _step == 1 && _isShaking) advanced = true;
    else if (_scenario == 4 && _step == 1 && _superimposed) advanced = true;
    else if (_scenario == 5) {
      if (_step == 0 && _bridgeParts['beamV']!) advanced = true;
      if (_step == 1 && _bridgeParts['conn']!) advanced = true;
      if (_step == 2 && _bridgeParts['beamH']!) {
        advanced = true;
        _superimposed = true;
        _checkScenarioSuccess();
      }
    }

    if (advanced && _scenario != 5) {
      if (_scenario != 1) _playSound('success');
      setState(() => _step++);
    } else if (advanced && _scenario == 5 && _step < 2) {
      _playSound('success');
      setState(() => _step++);
    }
  }

  void _checkScenarioSuccess() async {
    int totalSteps = (_scenario == 2) ? 2 : 3;
    setState(() {
      _step = totalSteps;
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    _playSound('success');
    if (_scenario == 5) {
      setState(() {
        _showSuccessPopup = true;
      });
    }
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

    if (_scenario == 1 || _scenario == 2 || _scenario == 3) {
      if (_scenario == 2 && !_superimposed && _step == 0) {
        // Flip button Hit Test
        double tX = 60 + 360 + 30;
        double tY = 80 - (360 - 80) + 40;
        if (pt.dx > tX && pt.dx < tX + 60 && pt.dy > tY && pt.dy < tY + 60) {
          setState(() {
            _isFlipped = !_isFlipped;
          });
          _playSound('pop');
          _evaluateStepConditions();
          return;
        }
      }

      if (!_superimposed) {
        double sS_drag = (_scenario == 3) ? 15 : 12;
        double sH_drag = (_scenario == 3) ? 25 : 20;
        double baseH = sqrt(sH_drag * sH_drag - sS_drag * sS_drag);
        
        double cx = _triX + (_isFlipped ? -baseH * 12 / 2 : baseH * 12 / 2);
        double cy = _triY - (sS_drag * 12) / 2;
        
        if ((Offset(cx, cy) - pt).distance < 150) {
          _playSound('tick');
          setState(() {
            _toolDragging = 'tri_drag';
            _dragOffset = Offset(_triX - pt.dx, _triY - pt.dy);
          });
          return;
        }
      }
    } else if (_scenario == 4 && !_superimposed) {
      Map<int, Map<String, dynamic>> partsConfig = {
        1: {'side': 15.0, 'hyp': 25.0},
        2: {'side': 12.0, 'hyp': 20.0},
        3: {'side': 16.0, 'hyp': 20.0},
        4: {'side': 12.0, 'hyp': 20.0}
      };
      
      for (int id in [1, 2, 3, 4]) {
        Offset pos = _partPos[id]!;
        double baseH = sqrt(pow(partsConfig[id]!['hyp'], 2) - pow(partsConfig[id]!['side'], 2));
        double cx = pos.dx + (baseH * 8.5) / 2;
        double cy = pos.dy - (partsConfig[id]!['side'] * 8.5) / 2;
        
        if ((Offset(cx, cy) - pt).distance < 80) {
          _playSound('tick');
          setState(() {
            _toolDragging = 'tri_part_$id';
            _dragOffset = Offset(pos.dx - pt.dx, pos.dy - pt.dy);
            if (_step == 0) _step++;
          });
          return;
        }
      }
    } else if (_scenario == 5 && !_superimposed) {
      if (!_bridgeParts['beamV']! && _step == 0) {
        if ((Offset(-150, 230) - pt).distance < 60) {
          _playSound('tick');
          setState(() {
            _toolDragging = 'beamV';
            _toolX = -150;
            _toolY = 230;
            _dragOffset = Offset(-150 - pt.dx, 230 - pt.dy);
          });
          return;
        }
      }
      if (!_bridgeParts['conn']! && _step == 1) {
        if ((Offset(10, 230) - pt).distance < 50) {
          _playSound('tick');
          setState(() {
            _toolDragging = 'conn';
            _toolX = 10;
            _toolY = 230;
            _dragOffset = Offset(10 - pt.dx, 230 - pt.dy);
          });
          return;
        }
      }
      if (!_bridgeParts['beamH']! && _step == 2) {
        if ((Offset(150, 230) - pt).distance < 100) {
          _playSound('tick');
          setState(() {
            _toolDragging = 'beamH';
            _toolX = 150;
            _toolY = 230;
            _dragOffset = Offset(150 - pt.dx, 230 - pt.dy);
          });
          return;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_toolDragging != null) {
      Offset pt = _screenToWorld(details.localFocalPoint, size);
      
      setState(() {
        if (_toolDragging == 'tri_drag') {
          _triX = pt.dx + _dragOffset.dx;
          _triY = pt.dy + _dragOffset.dy;

          double targetX = (_scenario == 3) ? -230 : -236;
          double targetY = 80;
          double dist = (Offset(_triX, _triY) - Offset(targetX, targetY)).distance;
          
          if (dist < 60) _glowStage = 3;
          else if (dist < 150) _glowStage = 2;
          else if (dist < 300) _glowStage = 1;
          else _glowStage = 0;

          if (_scenario == 1) {
            if (_step == 0 && _glowStage >= 1) _step++;
            if (_step == 1 && _glowStage >= 3) _step++;
          } else if (_scenario == 3) {
            if (_step == 0 && _glowStage >= 1) _step++;
            if (_step == 1 && _glowStage >= 2) _step++;
          }
        } else if (_toolDragging!.startsWith('tri_part_')) {
          int id = int.parse(_toolDragging!.split('_')[2]);
          _partPos[id] = Offset(pt.dx + _dragOffset.dx, pt.dy + _dragOffset.dy);
        } else if (['beamV', 'conn', 'beamH'].contains(_toolDragging)) {
          _toolX = pt.dx + _dragOffset.dx;
          _toolY = pt.dy + _dragOffset.dy;
        }
      });
    } else {
      setState(() {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_toolDragging != null) {
      setState(() {
        if (_toolDragging == 'tri_drag') {
          double targetX = (_scenario == 3) ? -230 : -236;
          double targetY = 80;
          bool isAligned = (_rotation == 0) && (_isFlipped == false);

          if ((Offset(_triX, _triY) - Offset(targetX, targetY)).distance < 100) {
            if (isAligned && _scenario != 3) {
              _triX = targetX;
              _triY = targetY;
              _superimposed = true;
              _glowStage = 3;
              _playSound('snap');
              _checkScenarioSuccess();
            } else {
              _triggerShake();
              _playSound('error');
              _triX = (_scenario == 2) ? 336 : ((_scenario == 3) ? 120 : 144);
              _triY = 80;
              _glowStage = 0;
              if (_scenario == 3) {
                _showMismatchStamp = true;
                _checkScenarioSuccess();
                Future.delayed(const Duration(milliseconds: 2500), () {
                  if (mounted) setState(() => _showMismatchStamp = false);
                });
              }
            }
          } else {
            _playSound('snap');
            _triX = (_scenario == 2) ? 336 : ((_scenario == 3) ? 120 : 144);
            _triY = 80;
            _glowStage = 0;
          }
        } else if (_toolDragging!.startsWith('tri_part_')) {
          int id = int.parse(_toolDragging!.split('_')[2]);
          Offset targetPos = const Offset(-380 + 60, -120 + 220);

          if ((_partPos[id]! - targetPos).distance < 100) {
            if (id == 2) {
              _partPos[id] = targetPos;
              _superimposed = true;
              _playSound('snap');
              _checkScenarioSuccess();
            } else {
              _triggerPartShake(id);
              _playSound('error');
            }
          } else {
            _playSound('snap');
            _partPos[id] = {
              1: const Offset(40, 0),
              2: const Offset(240, 0),
              3: const Offset(40, 150),
              4: const Offset(240, 150)
            }[id]!;
          }
        } else if (_toolDragging == 'beamV') {
          if ((Offset(_toolX, _toolY) - const Offset(-200, 25)).distance < 100) {
            _bridgeParts['beamV'] = true;
            _playSound('snap');
            _evaluateStepConditions();
          } else {
            _playSound('error');
          }
        } else if (_toolDragging == 'conn') {
          if ((Offset(_toolX, _toolY) - const Offset(-190, 90)).distance < 80) {
            _bridgeParts['conn'] = true;
            _playSound('weld');
            _evaluateStepConditions();
          } else {
            _playSound('error');
          }
        } else if (_toolDragging == 'beamH') {
          if ((Offset(_toolX, _toolY) - const Offset(-100, 25)).distance < 120) {
            _bridgeParts['beamH'] = true;
            _superimposed = true;
            _playSound('snap');
            _checkScenarioSuccess();
          } else {
            _playSound('error');
          }
        }
        
        _toolDragging = null;
      });
    }
  }

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(5, 0),
          )
        ]
      ),
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Icon(Icons.architecture, color: Colors.indigoAccent),
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
                    )
                  ],
                ),
              ),
              // Language & Reset Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleLanguage,
                        icon: const Icon(Icons.language, size: 18),
                        label: Text(_lang.toUpperCase()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          side: BorderSide(color: border)
                        ),
                      )
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _handleReset,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(t('resetBtn')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.2),
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.5))
                        ),
                      )
                    )
                  ]
                )
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
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border)
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _scenario,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          items: [1, 2, 3, 4, 5].map((id) => DropdownMenuItem(
                            value: id,
                            child: Text(t('s${id}_title')),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) _loadScenario(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.my_location, color: Colors.pinkAccent, size: 18),
                              const SizedBox(width: 8),
                              Text(t('learnLbl'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(t('s${_scenario}_obj'), style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStepsList(textPrimary, textSecondary),
                  ],
                ),
              ),
              // Footer stretching entire width at the end of scroll
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF0F172A),
                child: const Center(
                  child: Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList(Color primary, Color secondary) {
    int totalSteps = (_scenario == 2) ? 2 : 3;
    List<Widget> stepWidgets = [];

    for (int i = 0; i < totalSteps; i++) {
      bool isPast = i < _step;
      bool isCurrent = i == _step;
      
      Color stepBg = isCurrent ? Colors.indigo.withOpacity(0.1) : (isPast ? Colors.green.withOpacity(0.05) : (Colors.white.withOpacity(0.02)));
      Color stepBorder = isCurrent ? Colors.indigoAccent : (isPast ? Colors.green.withOpacity(0.3) : Colors.transparent);
      
      stepWidgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: stepBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: stepBorder)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isPast 
                ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                : Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.indigoAccent : Colors.grey,
                      shape: BoxShape.circle
                    ),
                    alignment: Alignment.center,
                    child: Text('${i+1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${t('stepLabel')} ${i+1}", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    // Simulated rich text by parsing basic <b> tags
                    _buildRichText(t('s${_scenario}_step${i+1}_task'), primary),
                    if (isPast) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: _buildRichText(t('s${_scenario}_step${i+1}_out'), Colors.green.shade700)
                      )
                    ]
                  ],
                ),
              )
            ],
          ),
        )
      );
    }

    if (_step == totalSteps) {
      stepWidgets.add(
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(t('summaryTitle'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              _buildRichText(t('s${_scenario}_sum'), primary),
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
                        _scenario < 5 
                          ? t('infoNextScen')
                          : t('infoLabDone'),
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                      )
                    )
                  ]
                )
              )
            ],
          ),
        )
      );
    }

    return Column(children: stepWidgets);
  }

  Widget _buildRichText(String htmlLikeStr, Color defaultColor) {
    List<TextSpan> spans = [];
    List<String> parts = htmlLikeStr.split('<b>');
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].contains('</b>')) {
        var subParts = parts[i].split('</b>');
        spans.add(TextSpan(text: subParts[0], style: TextStyle(fontWeight: FontWeight.bold, color: defaultColor)));
        if (subParts.length > 1) {
          spans.add(TextSpan(text: subParts[1], style: TextStyle(color: defaultColor)));
        }
      } else {
        spans.add(TextSpan(text: parts[i], style: TextStyle(color: defaultColor)));
      }
    }
    return RichText(text: TextSpan(style: TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'), children: spans));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.3;
    if (sidebarWidth < 300) sidebarWidth = 300; // Minimum width

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // MAIN CANVAS AREA
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(behavior: HitTestBehavior.opaque, 
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: RhsLabPainter(
                          lang: _lang,
                          scenario: _scenario,
                          step: _step,
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          triX: _triX,
                          triY: _triY,
                          superimposed: _superimposed,
                          isFlipped: _isFlipped,
                          isShaking: _isShaking,
                          glowStage: _glowStage,
                          showMismatchStamp: _showMismatchStamp,
                          partPos: _partPos,
                          shakingPart: _shakingPart,
                          redPart: _redPart,
                          bridgeParts: _bridgeParts,
                          toolDragging: _toolDragging,
                          toolX: _toolX,
                          toolY: _toolY,
                          t: t
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),

            // HUD Text (Bottom Center)
            if (_step < ((_scenario == 2) ? 2 : 3))
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth + 40 : 40,
                right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(top: BorderSide(color: Colors.indigoAccent, width: 4))
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.indigoAccent),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              t('s${_scenario}_hud${_step + 1}'),
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ANIMATED SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0, bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            // MENU TOGGLE ICON (Always top left)
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
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
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
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 80, height: 80,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 20)]
                                    ),
                                    child: const Icon(Icons.flag, color: Colors.white, size: 40),
                                  ),
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
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                      backgroundColor: Colors.indigoAccent,
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Close Icon Top-Right
                            Positioned(
                              top: 16,
                              right: 16,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white54),
                                onPressed: () {
                                  _playSound('pop');
                                  setState(() {
                                    _showSuccessPopup = false;
                                  });
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

            // CURTAIN RAISER SHUTTER
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
                          width: 120, height: 120,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)],
                          ),
                          child: const Icon(Icons.architecture, size: 80, color: Colors.indigoAccent),
                        ),
                        Text(
                          t('appTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2)
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t('appSubtitle'),
                          style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.2)
                        ),
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
                            textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                          ),
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

class RhsLabPainter extends CustomPainter {
  final bool isDark = true;
  final String lang;
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;
  
  final double triX, triY;
  final bool superimposed, isFlipped, isShaking, showMismatchStamp;
  final int glowStage;
  
  final Map<int, Offset> partPos;
  final int? shakingPart, redPart;
  
  final Map<String, bool> bridgeParts;
  final String? toolDragging;
  final double toolX, toolY;
  
  final Function(String) t;

  RhsLabPainter({
    required this.lang, required this.scenario, required this.step,
    required this.zoom, required this.panX, required this.panY,
    required this.triX, required this.triY, required this.superimposed, required this.isFlipped,
    required this.isShaking, required this.glowStage, required this.showMismatchStamp,
    required this.partPos, required this.shakingPart, required this.redPart,
    required this.bridgeParts, required this.toolDragging, required this.toolX, required this.toolY,
    required this.t
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Draw Grid
    Paint gridPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFBAE6FD)
      ..strokeWidth = 1.0;
    
    for (double i = -3000; i < 3000; i += 40) {
      canvas.drawLine(Offset(i, -3000), Offset(i, 3000), gridPaint);
      canvas.drawLine(Offset(-3000, i), Offset(3000, i), gridPaint);
    }

    if (scenario == 1 || scenario == 2 || scenario == 3) {
      _drawBasicScenario(canvas);
    } else if (scenario == 4) {
      _drawBlueprintScenario(canvas);
    } else if (scenario == 5) {
      _drawBridgeScenario(canvas);
    }

    canvas.restore();
  }

  void _drawBasicScenario(Canvas canvas) {
    double sS_target = (scenario == 3) ? 20 : 12;
    double sH_target = (scenario == 3) ? 25 : 20;
    double sS_drag = (scenario == 3) ? 15 : 12;
    double sH_drag = (scenario == 3) ? 25 : 20;

    double targetTx = (scenario == 3) ? -230 : -236;
    double targetTy = 80;

    // Background Boxes
    _drawRoundedRect(canvas, -320, targetTy - 280, 360, 360, 12, isDark ? const Color(0xAA1E293B) : const Color(0x143B82F6), isDark ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1));
    _drawText(canvas, scenario == 3 ? "Triangle C" : "Triangle A", -140, targetTy - 250, isDark ? Colors.blueAccent : Colors.blue.shade800, 16, true);
    
    int tgGlow = superimposed ? 3 : glowStage;
    _drawRightTriangle(canvas, Offset(targetTx, targetTy), sS_target, sH_target, false, 12.0, 'target', tgGlow);

    if (!superimposed) {
      _drawRoundedRect(canvas, 60, targetTy - 280, 360, 360, 12, isDark ? const Color(0xAA1E293B) : const Color(0x1410B981), isDark ? const Color(0xFF10B981) : const Color(0xFFCBD5E1));
      _drawText(canvas, scenario == 3 ? "Triangle D" : "Triangle B", 240, targetTy - 250, isDark ? Colors.greenAccent : Colors.green.shade800, 16, true);
    }

    double drawX = superimposed ? targetTx : triX;
    double drawY = superimposed ? targetTy : triY;
    if (isShaking) {
      drawX += (Random().nextDouble() - 0.5) * 20;
      drawY += (Random().nextDouble() - 0.5) * 20;
    }

    String activeStyle = superimposed ? 'success' : (isShaking ? 'error' : 'draggable');
    _drawRightTriangle(canvas, Offset(drawX, drawY), sS_drag, sH_drag, isFlipped, 12.0, activeStyle, tgGlow);

    if (scenario == 2 && !superimposed && step == 0) {
      _drawFlipButton(canvas, 60 + 360 + 30, targetTy - 280 + 40);
    }

    if (superimposed && scenario != 3) {
      canvas.save();
      canvas.translate(targetTx + 60, targetTy - 60);
      canvas.rotate(-0.1);
      _drawOutlineText(canvas, t('congruentLbl'), 0, 0, Colors.green, isDark ? Colors.black : Colors.white, 36);
      canvas.restore();
    }

    if (scenario == 3 && showMismatchStamp) {
      canvas.save();
      canvas.translate(targetTx + 60, targetTy - 60);
      canvas.rotate(-0.1);
      _drawOutlineText(canvas, t('mismatchLbl'), 0, 0, Colors.redAccent, isDark ? Colors.black : Colors.white, 36);
      canvas.restore();
    }
  }

  void _drawBlueprintScenario(Canvas canvas) {
    // Blueprint Box
    _drawRoundedRect(canvas, -380, -120, 260, 260, 12, isDark ? const Color(0xFF1E293B) : Colors.white, Colors.blue, 2);
    _drawText(canvas, t('lblBlueprint'), -250, -90, Colors.blueAccent, 16, true);
    
    Offset targetPos = const Offset(-380 + 60, -120 + 220);
    _drawRightTriangle(canvas, targetPos, 12, 20, false, 8.5, 'target', superimposed ? 3 : 0);

    if (!superimposed) {
      _drawRoundedRect(canvas, -20, -120, 440, 300, 12, isDark ? const Color(0xCC1E293B) : const Color(0xDDF8FAFC), isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), 1);
      _drawText(canvas, "Parts Bin", 200, -90, isDark ? Colors.white : Colors.black, 16, true);
    }

    Map<int, Map<String, dynamic>> config = {
      1: {'side': 15.0, 'hyp': 25.0, 'flip': false},
      2: {'side': 12.0, 'hyp': 20.0, 'flip': false},
      3: {'side': 16.0, 'hyp': 20.0, 'flip': false},
      4: {'side': 12.0, 'hyp': 20.0, 'flip': true}
    };

    for (int id in [1, 2, 3, 4]) {
      if (superimposed && id != 2) continue;
      
      Offset pos = partPos[id]!;
      if (shakingPart == id) {
        pos = Offset(pos.dx + (Random().nextDouble() - 0.5) * 10, pos.dy + (Random().nextDouble() - 0.5) * 10);
      }

      String style = 'solid';
      if (id == 2 && superimposed) {
        style = 'success';
        pos = targetPos;
      } else if (redPart == id) {
        style = 'error';
      } else if (toolDragging == 'tri_part_$id') {
        style = 'draggable';
      }

      _drawRightTriangle(canvas, pos, config[id]!['side'], config[id]!['hyp'], config[id]!['flip'], 8.5, style, (id == 2 && superimposed) ? 3 : 0);
      
      if (!superimposed) {
        double baseH = sqrt(pow(config[id]!['hyp'], 2) - pow(config[id]!['side'], 2));
        _drawText(canvas, "Part $id", pos.dx + (baseH * 8.5) / 2, pos.dy + 20, Colors.grey, 12, true);
      }
    }

    if (showMismatchStamp) {
      canvas.save();
      canvas.translate(-250, 10);
      canvas.rotate(-0.1);
      _drawOutlineText(canvas, t('mismatchLbl'), 0, 0, Colors.redAccent, isDark ? Colors.black : Colors.white, 28);
      canvas.restore();
    }

    if (superimposed) {
      canvas.save();
      canvas.translate(-250, 10);
      _drawOutlineText(canvas, t('lblBpMatch'), 0, 0, Colors.greenAccent, isDark ? Colors.black : Colors.white, 26);
      canvas.restore();
    }
  }

  void _drawBridgeScenario(Canvas canvas) {
    Color bridgeLineColor = isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8);
    
    // Bridge Base drawing
    Paint p = Paint()..color = bridgeLineColor..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    
    // Deck
    p.strokeWidth = 18; canvas.drawLine(const Offset(-600, 100), const Offset(600, 100), p);
    p.strokeWidth = 8; p.color = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
    canvas.drawLine(const Offset(-600, 120), const Offset(600, 120), p);
    p.color = bridgeLineColor;

    // Tower
    p.strokeWidth = 26; canvas.drawLine(const Offset(-200, 100), const Offset(-200, -250), p);
    p.strokeWidth = 16; canvas.drawLine(const Offset(-230, 100), const Offset(-230, -250), p);
    
    p.strokeWidth = 6;
    for(double y = -200; y < 100; y += 50) {
      canvas.drawLine(Offset(-230, y), Offset(-200, y + 30), p);
      canvas.drawLine(Offset(-200, y), Offset(-230, y + 30), p);
      p.strokeWidth = 8; canvas.drawLine(Offset(-230, y), Offset(-200, y), p); p.strokeWidth = 6;
    }

    // Suspension cables
    p.strokeWidth = 10;
    Path c1 = Path()..moveTo(-200, -200)..quadraticBezierTo(50, 0, 500, 100); canvas.drawPath(c1, p);
    Path c2 = Path()..moveTo(-200, -200)..quadraticBezierTo(-450, 0, -600, 100); canvas.drawPath(c2, p);
    
    p.strokeWidth = 4;
    for (double sx = -100; sx < 500; sx += 60) {
      double sy = 0 + pow((sx - 50)/400, 2) * 100;
      if (sy < 100) canvas.drawLine(Offset(sx, sy), Offset(sx, 100), p);
    }

    // Existing solid Trusses
    p.strokeWidth = 12;
    canvas.drawLine(const Offset(-200, 100), const Offset(0, -50), p);
    p.strokeWidth = 16; canvas.drawLine(const Offset(0, 100), const Offset(0, -50), p);
    p.strokeWidth = 12; canvas.drawLine(const Offset(0, -50), const Offset(200, 100), p);
    p.strokeWidth = 16; canvas.drawLine(const Offset(0, 100), const Offset(200, 100), p);
    canvas.drawLine(const Offset(-200, -50), const Offset(0, -50), p);

    // Target Area Glow
    Paint glowBg = Paint()..color = Colors.blueAccent.withOpacity(0.1)..style = PaintingStyle.fill;
    Path gapPath = Path()..moveTo(-200, -50)..lineTo(-200, 100)..lineTo(0, 100)..close();
    canvas.drawPath(gapPath, glowBg);

    // Missing parts outlines
    if (!bridgeParts['beamV']!) {
      _drawDashedLine(canvas, const Offset(-200, -50), const Offset(-200, 100), Colors.redAccent, 4);
      _drawOutlineText(canvas, 'S', -220, 25, Colors.redAccent, isDark ? Colors.black : Colors.white, 24);
    }
    if (!bridgeParts['beamH']!) {
      _drawDashedLine(canvas, const Offset(-200, -50), const Offset(0, 100), Colors.redAccent, 4);
      _drawOutlineText(canvas, 'H', -80, 0, Colors.redAccent, isDark ? Colors.black : Colors.white, 24);
    }
    if (!bridgeParts['conn']!) {
      Paint redLine = Paint()..color = Colors.redAccent..strokeWidth = 2..style = PaintingStyle.stroke;
      Path p90 = Path()..moveTo(-200, 75)..lineTo(-175, 75)..lineTo(-175, 100);
      canvas.drawPath(p90, redLine);
      _drawOutlineText(canvas, '90°', -180, 60, Colors.redAccent, isDark ? Colors.black : Colors.white, 16);
    }

    // Toolbox
    _drawRoundedRect(canvas, -250, 160, 500, 140, 12, isDark ? const Color(0xFF1E293B) : Colors.white, Colors.blue, 2);
    _drawText(canvas, t('lblTools'), -230, 190, isDark ? Colors.white : Colors.black, 16, true);
    canvas.drawLine(const Offset(-230, 205), const Offset(230, 205), Paint()..color=Colors.grey..strokeWidth=1);

    // Render Parts
    if (!bridgeParts['beamV']! && toolDragging != 'beamV') {
      _drawVBeam(canvas, const Offset(-150, 230), false);
      _drawText(canvas, "Vertical Beam (S)", -150, 280, Colors.grey, 12, true);
    }
    if (!bridgeParts['conn']! && toolDragging != 'conn') {
      _drawConn(canvas, const Offset(10, 230), false);
      _drawText(canvas, "90° Connector", 10, 280, Colors.grey, 12, true);
    }
    if (!bridgeParts['beamH']! && toolDragging != 'beamH') {
      _drawHBeam(canvas, const Offset(150, 230), false);
      _drawText(canvas, "Hypotenuse Beam (H)", 150, 280, Colors.grey, 12, true);
    }

    bool isAllGreen = superimposed;

    if (toolDragging == 'beamV') _drawVBeam(canvas, Offset(toolX, toolY), true);
    else if (bridgeParts['beamV']!) {
      _drawVBeam(canvas, const Offset(-200, 25), true);
      _drawOutlineText(canvas, 'S', -220, 25, isAllGreen ? Colors.green : Colors.orange, isDark ? Colors.black : Colors.white, 24);
    }

    if (toolDragging == 'conn') _drawConn(canvas, Offset(toolX, toolY), true);
    else if (bridgeParts['conn']!) {
      _drawConn(canvas, const Offset(-190, 90), true);
      _drawOutlineText(canvas, '90°', -170, 70, isAllGreen ? Colors.green : Colors.purpleAccent, isDark ? Colors.black : Colors.white, 16);
    }

    if (toolDragging == 'beamH') _drawHBeam(canvas, Offset(toolX, toolY), true);
    else if (bridgeParts['beamH']!) {
      _drawHBeam(canvas, const Offset(-100, 25), true);
      _drawOutlineText(canvas, 'H', -80, 0, isAllGreen ? Colors.green : Colors.blue, isDark ? Colors.black : Colors.white, 24);
    }

    if (isAllGreen) {
      canvas.drawPath(gapPath, Paint()..color = Colors.green.withOpacity(0.25)..style = PaintingStyle.fill);
      canvas.save();
      canvas.translate(-100, -80);
      canvas.rotate(-0.1);
      _drawOutlineText(canvas, "BRIDGE STABLE!", 0, 0, Colors.greenAccent, isDark ? Colors.black : Colors.white, 36);
      canvas.restore();
    }
  }

  void _drawFlipButton(Canvas canvas, double x, double y) {
    _drawRoundedRect(canvas, x, y, 60, 60, 8, isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9), Colors.indigoAccent);
    _drawText(canvas, t('btnFlip'), x + 30, y - 15, isDark ? Colors.white : Colors.black, 12, true);
    
    canvas.save();
    canvas.translate(x + 30, y + 30);
    
    Paint p1 = Paint()..color = Colors.indigo..style = PaintingStyle.fill;
    Path t1 = Path()..moveTo(-15, 10)..lineTo(-3, 0)..lineTo(-15, -10)..close();
    canvas.drawPath(t1, p1);
    canvas.drawPath(t1, Paint()..color = Colors.indigoAccent..style=PaintingStyle.stroke..strokeWidth=1.5);

    Paint p2 = Paint()..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)..style = PaintingStyle.fill;
    Path t2 = Path()..moveTo(15, 10)..lineTo(3, 0)..lineTo(15, -10)..close();
    canvas.drawPath(t2, p2);
    canvas.drawPath(t2, Paint()..color = isDark ? Colors.white : Colors.black..style=PaintingStyle.stroke..strokeWidth=1.5);

    _drawDashedLine(canvas, const Offset(0, -15), const Offset(0, 15), Colors.orange, 2);
    canvas.restore();
  }

  void _drawVBeam(Canvas canvas, Offset pos, bool isGlow) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    if(isGlow) { /* Implement shadow/glow if needed by using MaskFilter */ }
    _drawRoundedRect(canvas, -10, -75, 20, 150, 4, isGlow ? Colors.orange.shade300 : Colors.orange, Colors.brown, 2);
    Paint p = Paint()..color = Colors.brown..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-4, -70), const Offset(-4, 70), p);
    canvas.drawLine(const Offset(4, -70), const Offset(4, 70), p);
    canvas.restore();
  }

  void _drawConn(Canvas canvas, Offset pos, bool isGlow) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    Paint p1 = Paint()..color = isGlow ? Colors.purple.shade200 : Colors.purple..strokeWidth = 20..strokeJoin = StrokeJoin.miter..style = PaintingStyle.stroke;
    Path path1 = Path()..moveTo(-10, -35)..lineTo(-10, 10)..lineTo(35, 10);
    canvas.drawPath(path1, p1);
    
    Paint p2 = Paint()..color = Colors.purple.shade800..strokeWidth = 2..strokeJoin = StrokeJoin.miter..style = PaintingStyle.stroke;
    Path path2 = Path()..moveTo(-14, -35)..lineTo(-14, 14)..lineTo(35, 14);
    canvas.drawPath(path2, p2);

    Paint p3 = Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B)..style=PaintingStyle.fill;
    canvas.drawCircle(const Offset(-10, -20), 3, p3);
    canvas.drawCircle(const Offset(20, 10), 3, p3);
    canvas.restore();
  }

  void _drawHBeam(Canvas canvas, Offset pos, bool isGlow) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(atan2(150, 200));
    _drawRoundedRect(canvas, -125, -10, 250, 20, 4, isGlow ? Colors.blue.shade200 : Colors.blue, Colors.blue.shade900, 2);
    Paint p = Paint()..color = Colors.blue.shade900..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-120, -4), const Offset(120, -4), p);
    canvas.drawLine(const Offset(-120, 4), const Offset(120, 4), p);
    canvas.restore();
  }

  void _drawRightTriangle(Canvas canvas, Offset center, double sideV, double hyp, bool isFlipped, double scale, String style, int glowState) {
    double baseH = sqrt(hyp * hyp - sideV * sideV);
    double w = baseH * scale;
    double h = sideV * scale;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (isFlipped) canvas.scale(-1, 1);

    Path path = Path()..moveTo(0, 0)..lineTo(0, -h)..lineTo(w, 0)..close();

    Paint fill = Paint()..style = PaintingStyle.fill;
    Paint stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 4;

    if (style == 'target') {
      fill.color = Colors.blue.withOpacity(isDark ? 0.15 : 0.1);
      stroke.color = Colors.blue;
      _drawDashedPath(canvas, path, stroke);
      canvas.drawPath(path, fill);
    } else if (style == 'active') {
      fill.color = Colors.green.withOpacity(isDark ? 0.3 : 0.2);
      stroke.color = Colors.green;
      canvas.drawPath(path, fill); canvas.drawPath(path, stroke);
    } else if (style == 'success') {
      fill.color = Colors.green.withOpacity(isDark ? 0.4 : 0.3);
      stroke.color = isDark ? Colors.green : Colors.green.shade700;
      stroke.strokeWidth = 6;
      canvas.drawPath(path, fill); canvas.drawPath(path, stroke);
    } else if (style == 'error') {
      fill.color = Colors.red.withOpacity(isDark ? 0.4 : 0.2);
      stroke.color = Colors.red;
      stroke.strokeWidth = 6;
      canvas.drawPath(path, fill); canvas.drawPath(path, stroke);
    } else if (style == 'solid') {
      fill.color = Colors.blueGrey.withOpacity(isDark ? 0.4 : 0.2);
      stroke.color = isDark ? Colors.blueGrey.shade400 : Colors.blueGrey;
      canvas.drawPath(path, fill); canvas.drawPath(path, stroke);
    } else if (style == 'draggable') {
      fill.color = Colors.green.withOpacity(isDark ? 0.25 : 0.15);
      stroke.color = Colors.green;
      canvas.drawPath(path, fill); canvas.drawPath(path, stroke);
    }

    // Glows
    if (glowState >= 1) { // Right Angle
      canvas.drawLine(const Offset(0, -20), const Offset(20, -20), Paint()..color=Colors.purpleAccent..strokeWidth=4);
      canvas.drawLine(const Offset(20, -20), const Offset(20, 0), Paint()..color=Colors.purpleAccent..strokeWidth=4);
      _drawOutlineText(canvas, 'R', 25, -25, Colors.purpleAccent, isDark ? Colors.black : Colors.white, 18);
    } else {
      canvas.drawLine(const Offset(0, -15), const Offset(15, -15), Paint()..color=isDark ? Colors.white : Colors.black..strokeWidth=2);
      canvas.drawLine(const Offset(15, -15), const Offset(15, 0), Paint()..color=isDark ? Colors.white : Colors.black..strokeWidth=2);
    }

    if (glowState >= 2) { // Hypotenuse
      canvas.drawLine(Offset(0, -h), Offset(w, 0), Paint()..color=Colors.blueAccent..strokeWidth=6);
      _drawOutlineText(canvas, 'H', w/2 + 20, -h/2 - 20, Colors.blueAccent, isDark ? Colors.black : Colors.white, 18);
    }

    if (glowState >= 3) { // Side
      Color sColor = (scenario == 3 && showMismatchStamp) ? Colors.redAccent : Colors.greenAccent;
      canvas.drawLine(const Offset(0, 0), Offset(0, -h), Paint()..color=sColor..strokeWidth=6);
      _drawOutlineText(canvas, 'S', -20, -h/2, sColor, isDark ? Colors.black : Colors.white, 18);
    }

    canvas.restore();

    bool showLabels = (style != 'target' && style != 'success' && glowState == 0) || (scenario == 4 && style == 'target');
    if (showLabels) {
      String hypLbl = "$hyp ${scenario >= 4 ? t('lblUnitsM') : t('lblUnits')}";
      String sideLbl = "$sideV ${scenario >= 4 ? t('lblUnitsM') : t('lblUnits')}";
      
      double lblHyX = isFlipped ? center.dx - w/2 - 15 : center.dx + w/2 + 15;
      double lblHyY = center.dy - h/2 - 15;
      double lblSiX = isFlipped ? center.dx + 20 : center.dx - 20;
      double lblSiY = center.dy - h/2;

      _drawOutlineText(canvas, hypLbl, lblHyX, lblHyY, isDark ? Colors.white : Colors.black, isDark ? Colors.black : Colors.white, 14);
      _drawOutlineText(canvas, sideLbl, lblSiX, lblSiY, isDark ? Colors.white : Colors.black, isDark ? Colors.black : Colors.white, 14);
    }
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double strokeW = 1.0]) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent) {
      canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, Color color, double fontSize, bool center) {
    TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(center ? x - tp.width / 2 : x, center ? y - tp.height / 2 : y));
  }

  void _drawOutlineText(Canvas canvas, String text, double x, double y, Color fill, Color outline, double fontSize) {
    TextPainter tpStroke = TextPainter(
      text: TextSpan(
        text: text, 
        style: TextStyle(
          fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans',
          foreground: Paint()..style=PaintingStyle.stroke..strokeWidth=3.5..color=outline..strokeJoin=StrokeJoin.round
        )
      ),
      textDirection: TextDirection.ltr,
    );
    tpStroke.layout();
    tpStroke.paint(canvas, Offset(x - tpStroke.width/2, y - tpStroke.height/2));

    TextPainter tpFill = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
      textDirection: TextDirection.ltr,
    );
    tpFill.layout();
    tpFill.paint(canvas, Offset(x - tpFill.width/2, y - tpFill.height/2));
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Color color, double width) {
    Paint p = Paint()..color = color..strokeWidth = width..style = PaintingStyle.stroke;
    double dashWidth = 8, dashSpace = 8;
    double distance = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    double currentDistance = 0;
    while (currentDistance < distance) {
      canvas.drawLine(
        Offset(p1.dx + dx * currentDistance, p1.dy + dy * currentDistance),
        Offset(p1.dx + dx * min(currentDistance + dashWidth, distance), p1.dy + dy * min(currentDistance + dashWidth, distance)),
        p
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    // Basic implementation for a triangle dashed path. Proper robust implementation requires PathMetrics
    for (var metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final length = 8.0;
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, distance + length), paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RhsLabPainter oldDelegate) => true;
}

// Global Static Translation Map ported identically from HTML
const Map<String, Map<String, String>> _translations = {
  'en': {
      'appTitle': "RHS Congruence: The Structural Engineer's Test", 'appSubtitle': "Class 7 • GEOMETRIC TWINS", 'enterLab': "Enter Lab",
      'settings': "Settings", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'boardFontSize': "Text Size", 
      'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done", 
      'learnLbl': "What We Learn:", 'closeBtn': "Close", 'summaryTitle': "Discovery Made!",
      'resetBtn': "Reset", 'finishLab': "Finish Lab", 'nextScenario': "Next Scenario",
      'labCompleted': "Lab Completed!", 'finalDesc': "You have mastered RHS Congruence! By ensuring the Right Angle, Hypotenuse, and Side are equal, you proved that these structural components are identical twins.",
      'taskInst': "Action:", 'expOut': "Observation/Learning:", 'congruentLbl': "CONGRUENT (RHS)!", 'mismatchLbl': "NOT CONGRUENT", 'lblBpMatch': "BLUEPRINT MATCHED!",
      'lblTools': "Toolbox", 'btnFlip': "FLIP TOOL", 'btnSum': "Summary",
      'lblConstZone': "Construction Area", 'lblBlueprint': "Master Blueprint", 'lblTargetMeas': "Measurements",
      'lblUnits': "cm", 'lblUnitsM': "m",
      'infoNextScen': "Scenario completed! Please select the next scenario from the dropdown above.",
      'infoLabDone': "Lab Completed! You have mastered RHS Congruence.",

      's1_title': "1. The Perfect Match", 's1_obj': "To understand the fundamental principle of RHS congruence by superimposing two identical right-angled triangles.",
      's1_hud1': "Observe Triangle A and Triangle B.", 's1_step1_task': "<b>Action:</b> On the screen are two triangles, Triangle A and Triangle B. CLICK and DRAG Triangle B directly on top of Triangle A.", 's1_step1_out': "<b>Observation:</b> The user successfully drags Triangle B and places it over Triangle A.",
      's1_hud2': "Continue moving Triangle B closer to align it perfectly with Triangle A.", 's1_step2_task': "<b>Action:</b> Continue moving Triangle B closer to align it perfectly with Triangle A.", 's1_step2_out': "<b>Observation:</b> The right angle, hypotenuse, and sides glow to show they align.",
      's1_hud3': "RELEASE to see if they are a perfect fit.", 's1_step3_task': "<b>Action:</b> RELEASE to see if they are a perfect fit.", 's1_step3_out': "<b>Learning:</b> They match! The Right angle, Hypotenuse, and a Side were the same. This is RHS Congruence.", 's1_sum': "<b>RHS Verified!</b> The triangles match perfectly because their Right angle, Hypotenuse, and Side are equal.",

      's2_title': "2. The Flip and Fit", 's2_obj': "To understand that congruence is independent of orientation by first flipping a triangle before superimposing it.",
      's2_hud1': "Triangle B is a mirror image of Triangle A.", 's2_step1_task': "<b>Action:</b> Triangle B is a mirror image of Triangle A. It won't fit as it is. CLICK the 'FLIP TOOL' from the toolbox to re-orient Triangle B.", 's2_step1_out': "<b>Observation:</b> Triangle B flips horizontally.",
      's2_hud2': "DRAG Triangle B on top of Triangle A.", 's2_step2_task': "<b>Action:</b> Now that Triangle B is oriented correctly, DRAG it on top of Triangle A to check if they are congruent.", 's2_step2_out': "<b>Learning:</b> Orientation doesn't change the shape! After flipping, the R, H, and S matched perfectly.", 's2_sum': "<b>Orientation is independent.</b> A flipped right-angled triangle still follows RHS congruence if the dimensions match.",

      's3_title': "3. The Close Call", 's3_obj': "To learn that all three conditions (R, H, and S) must be met by attempting to match two non-congruent triangles.",
      's3_hud1': "DRAG Triangle D on top of Triangle C.", 's3_step1_task': "<b>Action:</b> DRAG Triangle D on top of Triangle C to see if they are congruent.", 's3_step1_out': "<b>Observation:</b> The Right angles align.",
      's3_hud2': "Continue to align the triangles.", 's3_step2_task': "<b>Action:</b> Continue to align the triangles.", 's3_step2_out': "<b>Observation:</b> The Hypotenuses align, but the vertical Sides are different lengths.",
      's3_hud3': "RELEASE.", 's3_step3_task': "<b>Action:</b> RELEASE.", 's3_step3_out': "<b>Learning:</b> Close, but not a match! The Right angle and Hypotenuse were the same, but the Side was different. All three parts must match.", 's3_sum': "<b>RHS Requires All 3 Parts.</b> If the Side (S) is different, even with the same Hypotenuse (H) and Right Angle (R), they are not congruent.",

      's4_title': "4. The Bracket Blueprint", 's4_obj': "To apply the RHS rule to identify the correct congruent triangle from a set of options.",
      's4_hud1': "Find the one bracket that is an exact match for the Blueprint.", 's4_step1_task': "<b>Action:</b> On the left is a Blueprint. On the right is a Parts Bin. DRAG brackets from the bin to the Blueprint to test them.", 's4_step1_out': "<b>Observation:</b> The user tests the brackets against the blueprint.",
      's4_hud2': "Test each bracket until you find the perfect fit.", 's4_step2_task': "<b>Action:</b> Test each bracket until you find the one that fits the Blueprint perfectly.", 's4_step2_out': "<b>Observation:</b> Incorrect brackets are repelled. The correct bracket fits perfectly.",
      's4_hud3': "The correct bracket has been found.", 's4_step3_task': "<b>Action:</b> The correct bracket has been successfully snapped into the blueprint.", 's4_step3_out': "<b>Learning:</b> Excellent work! You used the RHS rule to find the only bracket with the correct R, H, and S.", 's4_sum': "<b>Blueprint Matched!</b> You successfully identified the congruent bracket using the RHS specifications.",

      's5_title': "5. The Bridge Truss Challenge", 's5_obj': "To construct a congruent triangle using the RHS components to complete a structure.",
      's5_hud1': "DRAG the 'Vertical Beam' (Side) into position.", 's5_step1_task': "<b>Action:</b> A bridge is missing a triangular support truss. First, DRAG the 'Vertical Beam' (Side) into the highlighted position.", 's5_step1_out': "<b>Observation:</b> The vertical beam snaps into the correct position.",
      's5_hud2': "DRAG the '90° Connector' (Right Angle) to the bottom of the beam.", 's5_step2_task': "<b>Action:</b> Now, DRAG the '90° Connector' (Right Angle) to the bottom of the Vertical Beam.", 's5_step2_out': "<b>Observation:</b> The 90° connector attaches properly.",
      's5_hud3': "DRAG the 'Hypotenuse Beam' to connect the gap.", 's5_step3_task': "<b>Action:</b> Finally, DRAG the 'Hypotenuse Beam' to connect the top of the Vertical Beam to the other side of the gap.", 's5_step3_out': "<b>Learning:</b> Perfect construction! By using the correct Side, Right Angle, and Hypotenuse, you built a congruent truss.", 's5_sum': "<b>Bridge Stable!</b> You utilized RHS congruence to manufacture a perfect structural replacement."
  },
  'hi': {
      'appTitle': "RHS सर्वांगसमता: स्ट्रक्चरल इंजीनियर का परीक्षण", 'appSubtitle': "कक्षा 7 • ज्यामितीय जुड़वाँ", 'enterLab': "लैब में प्रवेश करें",
      'settings': "सेटिंग्स", 'theme': "थीम", 'darkMode': "डार्क मोड", 'lightMode': "लाइट मोड", 'boardFontSize': "टेक्स्ट आकार", 
      'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण", 
      'learnLbl': "हम क्या सीखते हैं:", 'closeBtn': "बंद करें", 'summaryTitle': "खोज की गई!",
      'resetBtn': "रीसेट करें", 'finishLab': "लैब समाप्त करें", 'nextScenario': "अगला परिदृश्य",
      'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने RHS सर्वांगसमता में महारत हासिल कर ली है! समकोण, कर्ण और भुजा को समान सुनिश्चित करके, आपने साबित कर दिया कि ये संरचनात्मक घटक समान जुड़वां हैं।",
      'taskInst': "क्रिया:", 'expOut': "अवलोकन/सीख:", 'congruentLbl': "सर्वांगसम (RHS)!", 'mismatchLbl': "बेमेल", 'lblBpMatch': "ब्लूप्रिंट मेल खा गया!",
      'lblTools': "टूलबॉक्स", 'btnFlip': "फ्लिप टूल", 'btnSum': "सारांश",
      'lblConstZone': "निर्माण क्षेत्र", 'lblBlueprint': "मास्टर ब्लूप्रिंट", 'lblTargetMeas': "मापन",
      'lblUnits': "cm", 'lblUnitsM': "m",
      'infoNextScen': "परिदृश्य पूरा हुआ! कृपया ऊपर दिए गए ड्रॉपडाउन से अगला परिदृश्य चुनें।",
      'infoLabDone': "लैब पूर्ण! आपने RHS सर्वांगसमता में महारत हासिल कर ली है।",

      's1_title': "1. एकदम सही मेल", 's1_obj': "प्रत्यक्ष सुपरइम्पोजिशन द्वारा दो समान समकोण त्रिभुजों को रखकर RHS सर्वांगसमता के मूल सिद्धांत को समझना।",
      's1_hud1': "त्रिभुज A और त्रिभुज B का निरीक्षण करें।", 's1_step1_task': "<b>क्रिया:</b> स्क्रीन पर दो त्रिभुज, त्रिभुज A और त्रिभुज B हैं। त्रिभुज B पर क्लिक करें और उसे सीधे त्रिभुज A के ऊपर खींचें।", 's1_step1_out': "<b>अवलोकन:</b> उपयोगकर्ता सफलतापूर्वक त्रिभुज B को खींचता और उसे त्रिभुज A के ऊपर रखता है।",
      's1_hud2': "संरेखित करने के लिए करीब ले जाना जारी रखें।", 's1_step2_task': "<b>क्रिया:</b> त्रिभुज B को त्रिभुज A के साथ पूरी तरह से संरेखित करने के लिए और करीब ले जाना जारी रखें।", 's1_step2_out': "<b>अवलोकन:</b> समकोण, कर्ण और भुजाएं यह दिखाने के लिए चमकती हैं कि वे संरेखित हैं।",
      's1_hud3': "यह देखने के लिए छोड़ दें कि क्या वे पूरी तरह से फिट हैं।", 's1_step3_task': "<b>क्रिया:</b> यह देखने के लिए छोड़ दें कि क्या वे पूरी तरह से फिट हैं।", 's1_step3_out': "<b>सीख:</b> वे मेल खाते हैं! समकोण, कर्ण और एक भुजा समान थे। यह RHS सर्वांगसमता है।", 's1_sum': "<b>RHS सत्यापित!</b> त्रिभुज पूरी तरह से मेल खाते हैं क्योंकि उनके समकोण, कर्ण और भुजा समान हैं।",

      's2_title': "2. घुमाएं और फिट करें", 's2_obj': "यह समझने के लिए कि सर्वांगसमता ओरिएंटेशन से स्वतंत्र है, पहले एक त्रिभुज को फ्लिप करके फिर उसे सुपरइम्पोज़ करना।",
      's2_hud1': "त्रिभुज B त्रिभुज A की दर्पण छवि है।", 's2_step1_task': "<b>क्रिया:</b> त्रिभुज B त्रिभुज A की दर्पण छवि है। त्रिभुज B को फिर से उन्मुख करने के लिए टूलबॉक्स से 'फ्लिप टूल' पर क्लिक करें।", 's2_step1_out': "<b>अवलोकन:</b> त्रिभुज B क्षैतिज रूप से पलट जाता है।",
      's2_hud2': "त्रिभुज B को त्रिभुज A के ऊपर खींचें।", 's2_step2_task': "<b>क्रिया:</b> अब जब त्रिभुज B सही ढंग से उन्मुख है, तो इसे त्रिभुज A के ऊपर खींचें।", 's2_step2_out': "<b>सीख:</b> ओरिएंटेशन आकार नहीं बदलता है! पलटने के बाद, R, H और S पूरी तरह से मेल खाते हैं।", 's2_sum': "<b>ओरिएंटेशन स्वतंत्र है।</b> एक पलटा हुआ समकोण त्रिभुज अभी भी RHS सर्वांगसमता का पालन करता है यदि आयाम मेल खाते हैं।",

      's3_title': "3. करीबी मामला", 's3_obj': "यह जानने के लिए कि दो गैर-सर्वांगसम त्रिभुजों का मिलान करने का प्रयास करके सभी तीन शर्तों (R, H और S) को पूरा किया जाना चाहिए।",
      's3_hud1': "त्रिभुज D को त्रिभुज C के ऊपर खींचें।", 's3_step1_task': "<b>क्रिया:</b> यह देखने के लिए त्रिभुज D को त्रिभुज C के ऊपर खींचें कि क्या वे सर्वांगसम हैं।", 's3_step1_out': "<b>अवलोकन:</b> समकोण संरेखित होते हैं।",
      's3_hud2': "त्रिभुजों को संरेखित करना जारी रखें।", 's3_step2_task': "<b>क्रिया:</b> त्रिभुजों को संरेखित करना जारी रखें।", 's3_step2_out': "<b>अवलोकन:</b> कर्ण संरेखित होते हैं, लेकिन ऊर्ध्वाधर भुजाएं अलग-अलग लंबाई की होती हैं।",
      's3_hud3': "छोड़ें।", 's3_step3_task': "<b>क्रिया:</b> छोड़ें।", 's3_step3_out': "<b>सीख:</b> करीब है, लेकिन मेल नहीं! समकोण और कर्ण समान थे, लेकिन भुजा अलग थी।", 's3_sum': "<b>RHS के लिए सभी 3 भागों की आवश्यकता होती है।</b> यदि भुजा (S) अलग है, तो वे सर्वांगसम नहीं हैं।",

      's4_title': "4. ब्रैकेट ब्लूप्रिंट", 's4_obj': "विकल्पों के सेट से सही सर्वांगसम त्रिभुज की पहचान करने के लिए RHS नियम लागू करना।",
      's4_hud1': "वह ब्रैकेट खोजें जो ब्लूप्रिंट के लिए एकदम सही मेल है।", 's4_step1_task': "<b>क्रिया:</b> ब्रैकेट को ब्लूप्रिंट पर खींचें और टेस्ट करें।", 's4_step1_out': "<b>अवलोकन:</b> उपयोगकर्ता ब्लूप्रिंट के खिलाफ ब्रैकेट का परीक्षण करता है।",
      's4_hud2': "प्रत्येक ब्रैकेट का परीक्षण करें।", 's4_step2_task': "<b>क्रिया:</b> प्रत्येक ब्रैकेट का परीक्षण करें जब तक कि आपको सही न मिल जाए।", 's4_step2_out': "<b>अवलोकन:</b> गलत ब्रैकेट वापस उछल जाते हैं। सही ब्रैकेट फिट बैठता है।",
      's4_hud3': "सही ब्रैकेट मिल गया है।", 's4_step3_task': "<b>क्रिया:</b> सही ब्रैकेट स्नैप हो गया है।", 's4_step3_out': "<b>सीख:</b> बहुत बढ़िया काम! आपने सही समकोण, कर्ण और भुजा खोजने के लिए RHS नियम का उपयोग किया।", 's4_sum': "<b>ब्लूप्रिंट मेल खा गया!</b> आपने RHS विनिर्देशों का उपयोग करके सर्वांगसम ब्रैकेट की सफलतापूर्वक पहचान की।",

      's5_title': "5. ब्रिज ट्रस चैलेंज", 's5_obj': "संरचना को पूरा करने के लिए RHS घटकों का उपयोग करके एक सर्वांगसम त्रिभुज का निर्माण करना।",
      's5_hud1': "'वर्टिकल बीम' (भुजा) को खींचें।", 's5_step1_task': "<b>क्रिया:</b> सबसे पहले, पुल पर हाइलाइट की गई स्थिति में 'वर्टिकल बीम' को खींचें।", 's5_step1_out': "<b>अवलोकन:</b> ऊर्ध्वाधर बीम सही स्थिति में स्नैप हो जाती है।",
      's5_hud2': "'90° कनेक्टर' (समकोण) को खींचें।", 's5_step2_task': "<b>क्रिया:</b> अब, वर्टिकल बीम के निचले भाग में '90° कनेक्टर' को खींचें।", 's5_step2_out': "<b>अवलोकन:</b> 90° कनेक्टर ठीक से जुड़ जाता है।",
      's5_hud3': "'हाइपोटेन्यूज़ बीम' को खींचें।", 's5_step3_task': "<b>क्रिया:</b> अंत में, अंतराल के दूसरी तरफ जोड़ने के लिए 'हाइपोटेन्यूज़ बीम' को खींचें।", 's5_step3_out': "<b>सीख:</b> एकदम सही निर्माण! आपने एक सर्वांगसम ट्रस बनाया जो बिल्कुल फिट बैठता है।", 's5_sum': "<b>पुल स्थिर!</b> आपने एक उत्तम संरचनात्मक प्रतिस्थापन के निर्माण के लिए RHS सर्वांगसमता का उपयोग किया।"
  }
};
