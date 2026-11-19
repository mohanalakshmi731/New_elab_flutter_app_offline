// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class CalculatingtheLCM extends StatefulWidget {
  const CalculatingtheLCM({Key? key}) : super(key: key);

  @override
  _CalculatingtheLCMState createState() => _CalculatingtheLCMState();
}

class AxleData {
  final double x;
  final double y;
  final int expectedN;
  final int dir;

  AxleData({
    required this.x,
    required this.y,
    required this.expectedN,
    required this.dir,
  });
}

class GearData {
  final int n;
  final Color color;
  double x;
  double y;
  final double offsetAngle;
  final String? name;
  bool mounted = false;
  AxleData? axle;

  double get r => (45.0 * n) / (2 * pi);

  GearData({
    required this.n,
    required this.color,
    required this.x,
    required this.y,
    this.offsetAngle = 0.0,
    this.name,
  });
}

class _CalculatingtheLCMState extends State<CalculatingtheLCM> with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  String _currentLang = 'en';
  final List<String> _langs = ['en', 'hi'];
  int _scenario = 1;
  int _step = 0;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;
  String _hudMessage = "";
  
  Set<int> _completedScenarios = {};

  // Auto-scrolling state
  final ScrollController _sidebarScrollCtrl = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(10, (index) => GlobalKey());

  // Floating Positions for Panels
  double _floatingStepX = 16.0;
  double _floatingStepY = 80.0;
  double _successDx = 0.0;
  double _successDy = 0.0;
  
  // LCM Popup Panel State
  bool _lcmPanelVisible = false;
  int _lcmSubStep = 1;
  double _lcmDx = 0.0;
  double _lcmDy = 0.0;

  // Zoom and Pan State
  double _zoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;
  double _baseZoom = 1.0;
  bool _isDraggingObject = false;

  // Simulation State
  List<GearData> _gears = [];
  List<AxleData> _axles = [];
  double _teethPassed = 0;
  double _lastDragAngle = 0;
  Offset _crankCenter = Offset.zero;
  bool _isCorrect = false;
  int? _autoStopTarget;
  String? _activeCanvasUI;
  GearData? _activeGear;

  // Audio Engine setup
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  late AnimationController _renderController;
  int _timeTicks = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _renderController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _renderController.addListener(() {
      setState(() {
        _timeTicks += 16;
      });
    });

    _playSound('shutter');
  }

  @override
  void dispose() {
    _renderController.dispose();
    _sidebarScrollCtrl.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      switch (type) {
        case 'tick':
        case 'snap':
        case 'crank':
          await _clickPlayer.play(AssetSource(_clickUrl));
          break;
        case 'success':
          await _successPlayer.play(AssetSource(_successUrl));
          break;
        case 'error':
          await _errorPlayer.play(AssetSource(_errorUrl));
          break;
        case 'pop':
        case 'weld':
          await _fxPlayer.play(AssetSource(_alertUrl));
          break;
        case 'shutter':
          await _fxPlayer.play(AssetSource(_shutterUrl));
          break;
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _enterLab() {
    _playSound('shutter');
    setState(() {
      _showCurtain = false;
      _loadScenario(1);
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
      _lcmDx = 0.0;
      _lcmDy = 0.0;
      
      _gears = [];
      _axles = [];
      _teethPassed = 0;
      _isCorrect = false;
      _lcmPanelVisible = false;
      _showSuccessPopup = false;
      _activeCanvasUI = null;
      _activeGear = null;

      double axY = -50.0;
      Map<int, Map<String, dynamic>> config = {
        1: {'sizes': [4, 6], 'colors': [const Color(0xFF0EA5E9), const Color(0xFF22C55E)], 'target': 12, 'names': [null, null]},
        2: {'sizes': [7, 10], 'colors': [const Color(0xFFFACC15), const Color(0xFFA855F7)], 'target': 70, 'names': [null, null]},
        3: {'sizes': [6, 8], 'colors': [const Color(0xFFEF4444), const Color(0xFF0EA5E9)], 'target': 24, 'names': ['ANSHU', 'GUNA']},
        4: {'sizes': [14, 30], 'colors': [const Color(0xFF0EA5E9), const Color(0xFFA855F7)], 'target': 210, 'names': [null, null]},
        5: {'sizes': [3, 5, 7], 'colors': [const Color(0xFFF97316), const Color(0xFF0EA5E9), const Color(0xFF22C55E)], 'target': 105, 'names': [null, null, null]}
      };

      var c = config[_scenario]!;
      _autoStopTarget = (_scenario <= 3) ? c['target'] : null;

      List<int> sizes = c['sizes'];
      List<Color> colors = c['colors'];
      List<String?> names = c['names'];

      double totalW = 0;
      List<double> radii = sizes.map((n) => (45.0 * n) / (2 * pi)).toList();
      for (double r in radii) totalW += r * 2;

      double currentX = -(totalW / 2) + radii[0];
      int nGears = sizes.length;

      for (int i = 0; i < nGears; i++) {
        double offset = (i % 2 != 0) ? (pi - pi / sizes[i]) : 0;
        int dir = ((nGears - 1 - i) % 2 == 0) ? 1 : -1;

        _axles.add(AxleData(x: currentX, y: axY, expectedN: sizes[i], dir: dir));

        double spawnX = currentX;
        double spawnY = axY + 180 + (radii[i] / 2);
        
        _gears.add(GearData(
          n: sizes[i], color: colors[i], x: spawnX, y: spawnY, offsetAngle: offset, name: names[i]
        ));

        if (i < nGears - 1) {
          currentX += radii[i] + radii[i + 1];
        }
      }

      _updateHud();
    });
    _scrollToActiveStep();
  }

  void _handleReset() {
    _playSound('pop');
    _loadScenario(1); // Ensures everything internally defaults to scenario 1
    setState(() {
      _showCurtain = true;
      _currentLang = 'en'; // Resets language
      _completedScenarios.clear();
      _showSuccessPopup = false;
      _lcmPanelVisible = false;
      _successDx = 0.0;
      _successDy = 0.0;
      _lcmDx = 0.0;
      _lcmDy = 0.0;
    });
  }

  String t(String key) {
    return Translations.data[_currentLang]?[key] ?? Translations.data['en']?[key] ?? key;
  }

  void _updateHud() {
    int totalSteps = _getTotalSteps(_scenario);
    if (_step < totalSteps) {
      _hudMessage = t('s${_scenario}_hud${_step + 1}');
    } else {
      _hudMessage = t('scenarioCompleteMsg');
    }
  }

  void _showTemporaryHud(String text) {
    setState(() {
      _hudMessage = text;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _updateHud());
    });
  }

  int _getTotalSteps(int scenarioId) {
    switch (scenarioId) {
      case 1: return 4;
      case 2: return 3;
      case 3: return 3;
      case 4: return 3;
      case 5: return 3;
      default: return 0;
    }
  }

  void _scrollToActiveStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      int targetStep = _step;
      if (targetStep >= _getTotalSteps(_scenario)) {
        targetStep = _getTotalSteps(_scenario) - 1; // Stick to last step if completed
      }
      
      if (targetStep >= 0 && targetStep < _stepKeys.length && _stepKeys[targetStep].currentContext != null) {
        Scrollable.ensureVisible(
          _stepKeys[targetStep].currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      }
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
      _updateHud();
      if (_step == _getTotalSteps(_scenario)) {
        _completedScenarios.add(_scenario);
        // Only show success popup if all 5 are completely done AND the LCM panel is not currently blocking the screen
        if (_completedScenarios.length == 5 && !_lcmPanelVisible) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && !_lcmPanelVisible) {
              setState(() {
                _showSuccessPopup = true;
              });
              _playSound('success');
            }
          });
        }
      }
    });
    _scrollToActiveStep();
  }

  void _closeLcmPanel() {
    _playSound('tick');
    setState(() {
      _lcmPanelVisible = false;
      
      if (_scenario == 3 && _lcmSubStep == 1) {
        // Just hide the panel, wait for the user to click "Continue" in Step 3
      } else {
        // If the panel closing signifies the end of a scenario step, advance
        if (_step < _getTotalSteps(_scenario)) {
          _advanceStep();
        } else if (_completedScenarios.length == 5) {
          // If already completed and this was the final scenario
          _showSuccessPopup = true;
          _playSound('success');
        }
      }
    });
  }

  void _checkScenarioAnswer() {
    int target = (_scenario == 4) ? 210 : 105;

    if ((_teethPassed - target).abs() < 8.0) {
      setState(() {
        _teethPassed = target.toDouble();
        _isCorrect = true;
        _lcmPanelVisible = true;
      });
      AudioEnginePlay('success');
      _advanceStep();
    } else {
      AudioEnginePlay('error');
      _showTemporaryHud(t('keepTrying'));
    }
  }

  void _continueScenario3() {
    _playSound('tick');
    setState(() {
      _autoStopTarget = 48;
      _lcmPanelVisible = false;
    });
  }

  void AudioEnginePlay(String type) => _playSound(type);

  // Gestures
  Offset _getCanvasCoord(Offset localPos, Size size) {
    return Offset(
      (localPos.dx - size.width / 2 - _panX) / _zoom,
      (localPos.dy - size.height / 2 - _panY) / _zoom,
    );
  }

  bool _hitTestCircle(double cx, double cy, double r, Offset pt) {
    return sqrt(pow(pt.dx - cx, 2) + pow(pt.dy - cy, 2)) < r;
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    Offset pt = _getCanvasCoord(details.localFocalPoint, size);
    _baseZoom = _zoom;
    _isDraggingObject = false;

    // Crank Hit Test
    bool allMounted = _gears.every((g) => g.mounted);
    if (allMounted && _step > 0 && _step < _getTotalSteps(_scenario)) {
      var crankAxle = _axles.last;
      double cx = crankAxle.x;
      double cy = crankAxle.y;
      
      double crankRot = crankAxle.dir * (_teethPassed / crankAxle.expectedN) * 2 * pi;
      double handleX = cx + cos(crankRot) * 85;
      double handleY = cy + sin(crankRot) * 85;
      
      if (_hitTestCircle(handleX, handleY, 40, pt)) {
        setState(() {
          _activeCanvasUI = 'crank';
          _lastDragAngle = atan2(pt.dy - cy, pt.dx - cx);
          _crankCenter = Offset(cx, cy);
          _isDraggingObject = true;
        });
        return;
      }
    }

    // Gear Hit Test
    if (_step == 0) {
      for (var g in _gears) {
        if (!g.mounted && _hitTestCircle(g.x, g.y, g.r + 20, pt)) {
          setState(() {
            _activeCanvasUI = 'gear';
            _activeGear = g;
            _isDraggingObject = true;
          });
          _playSound('tick');
          return;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _getCanvasCoord(details.localFocalPoint, size);

    setState(() {
      if (_isDraggingObject) {
        if (_activeCanvasUI == 'gear' && _activeGear != null) {
          _activeGear!.x = pt.dx;
          _activeGear!.y = pt.dy;
        } else if (_activeCanvasUI == 'crank') {
          double angle = atan2(pt.dy - _crankCenter.dy, pt.dx - _crankCenter.dx);
          double delta = angle - _lastDragAngle;
          
          if (delta > pi) delta -= 2 * pi;
          if (delta < -pi) delta += 2 * pi;
          
          if (delta.abs() > 0.01) {
            var crankAxle = _axles.last;
            _teethPassed += (delta / (2 * pi)) * crankAxle.expectedN;
            _teethPassed = max(0, _teethPassed);

            if (_teethPassed.floor() > (_teethPassed - (delta.abs() / (2 * pi)) * crankAxle.expectedN).floor()) {
              _playSound('crank');
            }

            // Auto Advance Step Triggers
            if (_scenario == 1 && _step == 1 && _teethPassed >= 4) _advanceStep();
            if (_scenario == 2 && _step == 1 && _teethPassed >= 5) _advanceStep();
            if (_scenario == 4 && _step == 1 && _teethPassed >= 15) _advanceStep();
            if (_scenario == 5 && _step == 1 && _teethPassed >= 10) _advanceStep();

            // Auto Stop Logic S1-S3
            if (_autoStopTarget != null && _teethPassed >= _autoStopTarget!) {
              _teethPassed = _autoStopTarget!.toDouble();
              _activeCanvasUI = null; // force drop
              _isDraggingObject = false;
              _playSound('success');
              
              if (_scenario == 1 && _step == 2) {
                _advanceStep();
                _lcmPanelVisible = true;
                _lcmSubStep = 1;
              } else if (_scenario == 2 && _step == 2) {
                _advanceStep();
                _lcmPanelVisible = true;
                _lcmSubStep = 1;
              } else if (_scenario == 3 && _step == 1) { // 24 Alignment
                _advanceStep(); 
                _lcmPanelVisible = true;
                _lcmSubStep = 1;
              } else if (_scenario == 3 && _step == 2 && _autoStopTarget == 48) { // 48 Alignment
                _advanceStep();
                _lcmPanelVisible = true;
                _lcmSubStep = 2;
              }
            }

            _lastDragAngle = angle;
          }
        }
      } else {
        // Panning the canvas
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
        _zoom = (_baseZoom * details.scale).clamp(0.3, 4.0);
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    setState(() {
      _isDraggingObject = false;
      
      if (_activeCanvasUI == 'gear' && _activeGear != null) {
        var g = _activeGear!;
        bool mounted = false;
        
        for (var ax in _axles) {
          if (ax.expectedN == g.n && _hitTestCircle(ax.x, ax.y, 60, Offset(g.x, g.y))) {
            g.x = ax.x;
            g.y = ax.y;
            g.mounted = true;
            g.axle = ax;
            mounted = true;
            _playSound('snap');
            break;
          }
        }
        
        if (!mounted) _playSound('pop');

        if (_gears.every((g) => g.mounted)) {
          Future.delayed(const Duration(milliseconds: 500), _advanceStep);
        }

        _activeGear = null;
      }

      _activeCanvasUI = null;
    });
  }

  // --- UI Builders ---
  Widget _buildSidebar() {
    double sidebarWidth = MediaQuery.of(context).size.width * 0.38;
    int totalSteps = _getTotalSteps(_scenario);
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: _isSidebarOpen ? 0 : -sidebarWidth,
      top: 0,
      bottom: 0,
      width: sidebarWidth,
      child: GestureDetector(
       behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey[900]?.withOpacity(0.95),
            border: const Border(right: BorderSide(color: Colors.white24, width: 1)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(5, 0))],
          ),
          child: SingleChildScrollView(
            controller: _sidebarScrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 70), // Top spacing for buttons
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('appTitle'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(t('appSubtitle'), style: const TextStyle(color: Colors.indigoAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                
                // Lang & Reset
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _playSound('tick');
                            setState(() {
                              _currentLang = _langs[(_langs.indexOf(_currentLang) + 1) % _langs.length];
                              _updateHud();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.8), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigoAccent)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.language, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(_currentLang.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _handleReset,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh, color: Colors.redAccent, size: 18),
                                const SizedBox(width: 8),
                                Text(t('resetBtnUI'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scenario Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('selectScenario'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _scenario,
                            isExpanded: true,
                            dropdownColor: Colors.blueGrey[800],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            onChanged: (val) {
                              if (val != null) {
                                _playSound('tick');
                                _loadScenario(val);
                              }
                            },
                            items: [
                              DropdownMenuItem(value: 1, child: Text(t('s1_title'))),
                              DropdownMenuItem(value: 2, child: Text(t('s2_title'))),
                              DropdownMenuItem(value: 3, child: Text(t('s3_title'))),
                              DropdownMenuItem(value: 4, child: Text(t('s4_title'))),
                              DropdownMenuItem(value: 5, child: Text(t('s5_title'))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Objective Panel
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.blueGrey[800]?.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.track_changes, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(t('learnLbl'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(t('s${_scenario}_obj'), style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Steps List
                      ...List.generate(totalSteps, (i) {
                        bool isCompleted = i < _step;
                        bool isCurrent = i == _step;
                        
                        Color bgColor = isCompleted ? Colors.green.withOpacity(0.1) : (isCurrent ? Colors.indigo.withOpacity(0.1) : Colors.white10);
                        Color borderColor = isCompleted ? Colors.green.withOpacity(0.3) : (isCurrent ? Colors.indigoAccent : Colors.transparent);
                        Color iconColor = isCompleted ? Colors.green : (isCurrent ? Colors.indigoAccent : Colors.white38);
                        
                        return Container(
                          key: _stepKeys[i],
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? Colors.transparent : iconColor.withOpacity(0.2)),
                                child: isCompleted 
                                  ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                                  : Center(child: Text('${i+1}', style: TextStyle(color: iconColor, fontWeight: FontWeight.bold))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("STEP ${i+1}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.2)),
                                    const SizedBox(height: 6),
                                    RichText(text: TextSpan(children: [
                                      TextSpan(text: "Action: ", style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? Colors.indigoAccent : Colors.white70)),
                                      TextSpan(text: t('s${_scenario}_step${i+1}_task'), style: const TextStyle(color: Colors.white70)),
                                    ])),
                                    if (isCompleted) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.withOpacity(0.2))),
                                        child: RichText(text: TextSpan(children: [
                                          const TextSpan(text: "Observation: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                                          TextSpan(text: t('s${_scenario}_step${i+1}_out'), style: const TextStyle(color: Colors.white70)),
                                        ])),
                                      )
                                    ]
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
                  alignment: Alignment.center,
                  child: const Text("© ZeroScienceLab - Fall in love with math and Science", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingStepPanel() {
    int i = _step;
    if (i >= _getTotalSteps(_scenario) || _showCurtain || _showSuccessPopup || _isSidebarOpen) {
      return const SizedBox.shrink();
    }

    String taskTxt = t('s${_scenario}_step${i+1}_task');

    return Positioned(
      left: _floatingStepX,
      top: _floatingStepY,
      child: GestureDetector(
       behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          setState(() {
            _floatingStepX += d.delta.dx;
            _floatingStepY += d.delta.dy;
          });
        },
        child: Material(
          color: Colors.transparent,
          elevation: 12,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900]?.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigoAccent, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                 Row(
                   children: [
                     const Icon(Icons.drag_indicator, color: Colors.white54, size: 18),
                     const SizedBox(width: 8),
                     Text("STEP ${i+1}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                   ]
                 ),
                 const SizedBox(height: 12),
                 Text(taskTxt, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
              ]
            )
          )
        )
      )
    );
  }

  Widget _buildLcmResultPanel() {
    if (!_lcmPanelVisible) return const SizedBox.shrink();

    String titleKey = 's${_scenario}_res_title';
    String descKey = 's${_scenario}_res_desc';
    
    if (_scenario == 3) {
      titleKey = _lcmSubStep == 1 ? 's3_res_title1' : 's3_res_title2';
      descKey = _lcmSubStep == 1 ? 's3_res_desc1' : 's3_res_desc2';
    }

    return Positioned(
      top: 24,
      right: 24, 
      child: Transform.translate(
        offset: Offset(_lcmDx, _lcmDy),
        child: GestureDetector(
         behavior: HitTestBehavior.opaque,
          onPanUpdate: (d) {
            setState(() {
              _lcmDx += d.delta.dx;
              _lcmDy += d.delta.dy;
            });
          },
          child: Material(
            color: Colors.transparent,
            elevation: 20,
            child: Container(
              width: 320, // STRICTLY Compact Size
              decoration: BoxDecoration(
                color: Colors.blueGrey[900]?.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigoAccent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade600,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t(titleKey), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Icon(Icons.drag_indicator, color: Colors.white70, size: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blueGrey.shade800, borderRadius: BorderRadius.circular(12)),
                          child: _buildLcmLists(),
                        ),
                        const SizedBox(height: 16),
                        Text(t(descKey).replaceAll(RegExp(r'<[^>]*>'), ''), style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _closeLcmPanel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(t('gotItBtn'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLcmLists() {
    List<Widget> rows = [];
    TextStyle baseStyle = const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.6);
    
    Widget parseHtmlToText(String raw, Color mainColor) {
      List<TextSpan> spans = [];
      var parts = raw.split(RegExp(r"(<span[^>]*>|<\/span>)"));
      bool isHighlight = false;
      for (var p in parts) {
        if (p.trim().isEmpty) continue;
        if (raw.contains("<span") && p == parts[1]) isHighlight = true;
        
        if (isHighlight) {
          spans.add(TextSpan(text: p, style: baseStyle.copyWith(color: Colors.black, backgroundColor: Colors.amber, fontWeight: FontWeight.bold)));
          isHighlight = false;
        } else {
          spans.add(TextSpan(text: p, style: baseStyle.copyWith(color: mainColor, fontWeight: FontWeight.bold)));
        }
      }
      return RichText(text: TextSpan(children: spans), textAlign: TextAlign.center);
    }

    if (_scenario == 1) {
      rows.add(parseHtmlToText(t('s1_list1'), Colors.lightBlue));
      rows.add(parseHtmlToText(t('s1_list2'), Colors.greenAccent));
    } else if (_scenario == 2) {
      rows.add(parseHtmlToText(t('s2_list1'), Colors.amber));
      rows.add(parseHtmlToText(t('s2_list2'), Colors.purpleAccent));
    } else if (_scenario == 3) {
      if (_lcmSubStep == 1) {
        rows.add(parseHtmlToText(t('s3_list1_1'), Colors.redAccent));
        rows.add(parseHtmlToText(t('s3_list2_1'), Colors.lightBlue));
      } else {
        rows.add(parseHtmlToText(t('s3_list1_2'), Colors.redAccent));
        rows.add(parseHtmlToText(t('s3_list2_2'), Colors.lightBlue));
      }
    } else if (_scenario == 4) {
      rows.add(parseHtmlToText(t('s4_list1'), Colors.lightBlue));
      rows.add(parseHtmlToText(t('s4_list2'), Colors.purpleAccent));
    } else if (_scenario == 5) {
      rows.add(parseHtmlToText(t('s5_list1'), Colors.orangeAccent));
      rows.add(parseHtmlToText(t('s5_list2'), Colors.lightBlue));
      rows.add(parseHtmlToText(t('s5_list3'), Colors.greenAccent));
    }

    return Column(children: rows);
  }

  Widget _buildCanvasBottomUI() {
    Widget? content;

    if ((_scenario == 4 || _scenario == 5) && _step >= 1 && _step < _getTotalSteps(_scenario) && !_isCorrect) {
      content = ElevatedButton.icon(
        onPressed: _checkScenarioAnswer,
        icon: const Icon(Icons.check_circle),
        label: Text(_scenario == 5 ? t('revealAnswer') : t('checkAnswer')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (_scenario == 3 && _step == 2 && !_lcmPanelVisible && _autoStopTarget != 48) {
      content = ElevatedButton.icon(
        onPressed: _continueScenario3,
        icon: const Icon(Icons.arrow_right_alt),
        label: Text(t('continueBtn')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return Positioned(
      bottom: 80, // Above HUD
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: content ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildHudOverlay() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: _hudMessage.isNotEmpty && !_showCurtain && !_showSuccessPopup ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.indigoAccent.withOpacity(0.5), width: 2),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: Colors.indigoAccent, size: 24),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      _hudMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopup() {
    if (!_showSuccessPopup) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Transform.translate(
            offset: Offset(_successDx, _successDy),
            child: GestureDetector(
             behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => setState(() {
                _successDx += d.delta.dx;
                _successDy += d.delta.dy;
              }),
              child: Material(
                color: Colors.transparent,
                elevation: 24,
                child: Container(
                  width: 280, // Compact Drag Popup width
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.indigoAccent, width: 2),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.greenAccent.withOpacity(0.2),
                                boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 20)]
                              ),
                              child: const Icon(Icons.flag, color: Colors.greenAccent, size: 48)
                            ),
                            const SizedBox(height: 16),
                            Text(t('summaryTitle'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(t('finalDesc'), style: const TextStyle(color: Colors.greenAccent, fontSize: 14), textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                _playSound('pop');
                                setState(() => _showSuccessPopup = false);
                                _handleReset();
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(t('finishLab')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                          onPressed: () {
                            _playSound('tick');
                            setState(() => _showSuccessPopup = false);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Visibility(
      visible: _showCurtain,
      child: Container(
        color: const Color(0xFF0F172A),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigoAccent.withOpacity(0.1),
                  boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.2), blurRadius: 40)],
                ),
                child: const Icon(Icons.settings, color: Colors.indigoAccent, size: 80),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  t('shutterTitle'),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(t('appSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0), textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _enterLab,
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: Text(t('enterLab'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                  shadowColor: Colors.indigoAccent.withOpacity(0.5),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = MediaQuery.of(context).size.width * 0.38;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return GestureDetector(
                       behavior: HitTestBehavior.opaque,
                        onScaleStart: (d) => _handleScaleStart(d, canvasSize),
                        onScaleUpdate: (d) => _handleScaleUpdate(d, canvasSize),
                        onScaleEnd: (d) => _handleScaleEnd(d, canvasSize),
                        child: CustomPaint(
                          painter: LCMLabPainter(
                            scenario: _scenario,
                            zoom: _zoom,
                            panX: _panX,
                            panY: _panY,
                            ticks: _timeTicks,
                            gears: _gears,
                            axles: _axles,
                            teethPassed: _teethPassed,
                            step: _step,
                            isCorrect: _isCorrect,
                            lang: _currentLang,
                            t: t,
                            autoStopTarget: _autoStopTarget,
                          ),
                        ),
                      );
                    },
                  ),

                  // Floating UI on Canvas
                  _buildCanvasBottomUI(),
                  _buildHudOverlay(),
                  
                  // LCM Popup Panel (Restricted to canvas area width)
                  _buildLcmResultPanel(),
                ]
              )
            ),

            // Sidebar
            _buildSidebar(),

            // Top Left Icons (Menu)
            Positioned(
              top: 16,
              left: 16,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                    color: Colors.orangeAccent,
                    iconSize: 28,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _playSound('pop');
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
                ],
              )
            ),

            // Overlays Conditionally Rendered
            _buildSuccessPopup(),
            _buildCurtain(),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Custom Painter for LCM Gears
// ----------------------------------------------------------------------------
class LCMLabPainter extends CustomPainter {
  final int scenario;
  final double zoom;
  final double panX;
  final double panY;
  final int ticks;
  final List<GearData> gears;
  final List<AxleData> axles;
  final double teethPassed;
  final int step;
  final bool isCorrect;
  final String lang;
  final Function(String) t;
  final int? autoStopTarget;

  LCMLabPainter({
    required this.scenario, required this.zoom, required this.panX, required this.panY, required this.ticks,
    required this.gears, required this.axles, required this.teethPassed, required this.step,
    required this.isCorrect, required this.lang, required this.t, this.autoStopTarget
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom);

    _drawWorkbench(canvas);

    // Draw Gears
    for (var g in gears) {
      _drawGear(canvas, g);
    }

    // Draw Crank on rightmost gear if all are mounted
    bool allMounted = gears.every((g) => g.mounted);
    if (allMounted && step > 0) {
      _drawCrank(canvas, axles.last);
    }

    // Connection Line "DING!" for alignments (S1-S3)
    if (scenario <= 3 && step >= 2 && autoStopTarget != null) {
      if ((teethPassed - autoStopTarget!).abs() < 0.1) {
        var g1 = gears[0];
        var g2 = gears[1];
        double c1x = g1.x; double c1y = g1.y - g1.r - 47;
        double c2x = g2.x; double c2y = g2.y - g2.r - 47;

        canvas.save();
        final path = Path()..moveTo(c1x + 25, c1y)..lineTo(c2x - 25, c2y);
        canvas.drawPath(path, Paint()..color = Colors.amber..strokeWidth = 4..style = PaintingStyle.stroke);
        canvas.drawPath(path, Paint()..color = Colors.amber.withOpacity(0.5)..strokeWidth = 10..style = PaintingStyle.stroke); // glow
        
        _drawText(canvas, t('ding'), c2x + 75, c2y, 32, Colors.amber, Colors.brown, italic: true);
        canvas.restore();
      }
    }

    // S4 Correct Manual Visuals
    if (scenario == 4 && isCorrect) {
      var g1 = gears[0]; var g2 = gears[1];
      double c1x = g1.x; double c1y = g1.y - g1.r - 47;
      double c2x = g2.x; double c2y = g2.y - g2.r - 47;
      double midX = (c1x + c2x) / 2; double midY = c1y - 10;
      
      _drawText(canvas, '✔️ CORRECT!', midX, midY, 24, const Color(0xFF10B981), Colors.transparent);
      final path = Path()..moveTo(c1x + 35, c1y - 18)..lineTo(c2x - 35, c2y - 18);
      canvas.drawPath(path, Paint()..color = const Color(0xFF10B981)..strokeWidth = 4..style = PaintingStyle.stroke);
      _drawText(canvas, t('ding'), c2x + 75, c2y, 32, Colors.amber, Colors.brown, italic: true);
    }

    // S5 Correct Manual Visuals (Triple)
    if (scenario == 5 && isCorrect) {
      var g1 = gears[0]; var g2 = gears[1]; var g3 = gears[2];
      double c1x = g1.x; double c1y = g1.y - g1.r - 47;
      double c2x = g2.x; double c2y = g2.y - g2.r - 47;
      double c3x = g3.x; double c3y = g3.y - g3.r - 47;
      
      _drawText(canvas, 'SUCCESS!', c2x, c2y - 35, 28, Colors.amber, Colors.transparent);
      final path = Path()..moveTo(c1x + 25, c1y - 18)..lineTo(c3x - 25, c3y - 18);
      canvas.drawPath(path, Paint()..color = Colors.amber..strokeWidth = 5..style = PaintingStyle.stroke);
    }

    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, double sw) {
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && sw > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = sw);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double fontSize, Color fillStyle, Color strokeStyle, {bool italic = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text, 
        style: TextStyle(
          color: fillStyle, 
          fontSize: fontSize, 
          fontWeight: FontWeight.bold,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        )
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();

    if (strokeStyle != Colors.transparent) {
      final tpStroke = TextPainter(
        text: TextSpan(
          text: text, 
          style: TextStyle(
            foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 3.5..color = strokeStyle,
            fontSize: fontSize, 
            fontWeight: FontWeight.bold,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          )
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tpStroke.layout();
      tpStroke.paint(canvas, Offset(x - tpStroke.width / 2, y - tpStroke.height / 2));
    }

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawWorkbench(Canvas canvas) {
    // Wooden table
    _drawRoundedRect(canvas, -500, -200, 1000, 400, 10, const Color(0xFFB45309), const Color(0xFF78350F), 4); // Top
    
    // Objective Plaque
    String objText = "";
    if (scenario == 1) objText = t('s1_mission');
    if (scenario == 2) objText = t('s2_mission');
    if (scenario == 3) objText = t('s3_mission');
    if (scenario == 4) objText = t('s4_mission');
    if (scenario == 5) objText = t('s5_mission');

    if (objText.isNotEmpty) {
      _drawRoundedRect(canvas, -200, 140, 400, 45, 4, const Color(0xFFE2E8F0), const Color(0xFF94A3B8), 2);
      _drawText(canvas, t('mission_objective'), 0, 155, 12, const Color(0xFF475569), Colors.transparent);
      _drawText(canvas, objText, 0, 172, 14, const Color(0xFF0F172A), Colors.transparent);
      
      // Screws
      canvas.drawCircle(const Offset(-185, 162), 3, Paint()..color = const Color(0xFF64748B));
      canvas.drawCircle(const Offset(185, 162), 3, Paint()..color = const Color(0xFF64748B));
    }

    // Legs
    _drawRoundedRect(canvas, -450, 240, 30, 150, 5, const Color(0xFF451A03), const Color(0xFF451A03), 3);
    _drawRoundedRect(canvas, 420, 240, 30, 150, 5, const Color(0xFF451A03), const Color(0xFF451A03), 3);

    // Axles
    for (var ax in axles) {
      // Base
      canvas.drawOval(Rect.fromCenter(center: Offset(ax.x, ax.y), width: 50, height: 20), Paint()..color = const Color(0xFF94A3B8));
      canvas.drawOval(Rect.fromCenter(center: Offset(ax.x, ax.y), width: 50, height: 20), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth=2);
      // Rod
      canvas.drawRect(Rect.fromLTWH(ax.x - 8, ax.y - 120, 16, 120), Paint()..color = const Color(0xFF94A3B8));
      canvas.drawRect(Rect.fromLTWH(ax.x - 8, ax.y - 120, 16, 120), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth=2);
      // Top
      canvas.drawOval(Rect.fromCenter(center: Offset(ax.x, ax.y - 120), width: 16, height: 8), Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawOval(Rect.fromCenter(center: Offset(ax.x, ax.y - 120), width: 16, height: 8), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth=2);
    }
  }

  void _drawGear(Canvas canvas, GearData g) {
    canvas.save();
    canvas.translate(g.x, g.y);
    
    double rotation = g.offsetAngle;
    if (g.mounted && g.axle != null) {
      rotation += g.axle!.dir * (teethPassed / g.n) * 2 * pi;
    }

    // Draw Unmounted Labels First (so they don't rotate)
    if (!g.mounted) {
      _drawText(canvas, "${g.n} ${t('teeth')}", 0, g.r + 25, 16, const Color(0xFFCBD5E1), Colors.transparent);
      if (g.name != null) {
        _drawText(canvas, "(${t(g.name!.toLowerCase())})", 0, g.r + 45, 14, const Color(0xFF94A3B8), Colors.transparent);
      }
    }

    // Draw Mounted Multiples Text
    if (g.mounted && scenario <= 3) {
      int currentMultiple = ((teethPassed + 0.1) / g.n).floor() * g.n;
      
      String labelKey = "";
      if (scenario == 1) labelKey = (g.n == 4) ? 's1_gear1_lbl' : 's1_gear2_lbl';
      if (scenario == 2) labelKey = (g.n == 7) ? 's2_gear1_lbl' : 's2_gear2_lbl';
      if (scenario == 3) labelKey = (g.n == 6) ? 's3_gear1_lbl' : 's3_gear2_lbl';
      
      List<String> lines = t(labelKey).split('\n');

      if (currentMultiple == 0 && step == 1) {
        if(lines.isNotEmpty) _drawText(canvas, lines[0], 0, -g.r - 55, 10, const Color(0xFFCBD5E1), Colors.transparent);
        if(lines.length > 1) _drawText(canvas, lines[1], 0, -g.r - 43, 10, const Color(0xFFCBD5E1), Colors.transparent);
        _drawRoundedRect(canvas, -15, -g.r - 65, 30, 35, 6, const Color(0xFF334155), const Color(0xFF94A3B8), 2);
        _drawText(canvas, '0', 0, -g.r - 47, 18, Colors.white, Colors.transparent);
      }

      if (step > 0 && currentMultiple > 0) {
        bool topIsTarget = false;
        if (scenario <= 3 && autoStopTarget != null) {
          if (currentMultiple == autoStopTarget && (teethPassed - autoStopTarget!).abs() < 0.1) {
            topIsTarget = true;
          }
        }
        
        if(lines.isNotEmpty) _drawText(canvas, lines[0], -45, -g.r - 55, 10, const Color(0xFFCBD5E1), Colors.transparent);
        if(lines.length > 1) _drawText(canvas, lines[1], -45, -g.r - 43, 10, const Color(0xFFCBD5E1), Colors.transparent);

        Color boxColor = topIsTarget ? Colors.amber : const Color(0xFF1E293B);
        _drawRoundedRect(canvas, -20, -g.r - 65, 40, 35, 6, boxColor, g.color, 3);
        _drawText(canvas, currentMultiple.toString(), 0, -g.r - 47, 20, Colors.white, Colors.transparent);

        int count = (currentMultiple / g.n).floor();
        int rotDir = g.axle!.dir;
        
        for (int i = 1; i <= count; i++) {
          int val = i * g.n;
          if (val == currentMultiple) continue; 
          
          int stepNum = (count - i + 1); 
          double angle = -pi/2 + (rotDir * stepNum * 0.40); 
          double arcR = g.r + 45;
          double tx = cos(angle) * arcR;
          double ty = sin(angle) * arcR;
          
          _drawText(canvas, val.toString(), tx, ty, 18, g.color, const Color(0xFF0F172A));
        }
      }
    } else if (g.mounted && scenario >= 4) {
      if (step > 0) {
        int currentMultiple = ((teethPassed + 0.1) / g.n).floor() * g.n;
        _drawText(canvas, t('counter'), 0, -g.r - 75, 10, const Color(0xFFCBD5E1), Colors.transparent);
        Color boxColor = isCorrect ? const Color(0xFF10B981) : const Color(0xFF1E293B);
        _drawRoundedRect(canvas, -25, -g.r - 65, 50, 35, 6, boxColor, g.color, 3);
        _drawText(canvas, currentMultiple.toString(), 0, -g.r - 47, 20, Colors.white, Colors.transparent);
      }
    }

    // Now Rotate for Gear Body
    canvas.rotate(rotation);

    // Gear Body
    double innerR = g.r - 14;
    double outerR = g.r + 8;
    
    final path = Path();
    for (int i = 0; i < g.n; i++) {
      double aCenter = i * 2 * pi / g.n;
      double w = pi / g.n * 0.45;
      
      if (i == 0) {
        path.moveTo(cos(aCenter - w*1.5)*innerR, sin(aCenter - w*1.5)*innerR);
      } else {
        path.lineTo(cos(aCenter - w*1.5)*innerR, sin(aCenter - w*1.5)*innerR);
      }
      path.lineTo(cos(aCenter - w)*outerR, sin(aCenter - w)*outerR);
      path.lineTo(cos(aCenter + w)*outerR, sin(aCenter + w)*outerR);
      path.lineTo(cos(aCenter + w*1.5)*innerR, sin(aCenter + w*1.5)*innerR);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = g.color..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 3);
    
    // Bevels
    canvas.drawCircle(Offset.zero, innerR, Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(Offset.zero, innerR - 3, Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1);

    // Inner rim
    canvas.drawCircle(Offset.zero, 25, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset.zero, 25, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 4);
    
    // Axle hole
    canvas.drawCircle(Offset.zero, 12, Paint()..color = const Color(0xFF020617)..style = PaintingStyle.fill);

    // Red Marker (Tooth 0) - Reverse rotation to draw it upwards relative to the gear's 0 angle
    canvas.rotate(-pi/2 - g.offsetAngle);
    final marker = Path()
      ..moveTo(innerR + 2, -5)
      ..lineTo(outerR + 4, 0)
      ..lineTo(innerR + 2, 5)
      ..close();
    canvas.drawPath(marker, Paint()..color = const Color(0xFFEF4444));
    canvas.drawPath(marker, Paint()..color = const Color(0xFF991B1B)..style = PaintingStyle.stroke..strokeWidth = 2);

    canvas.restore();
  }

  void _drawCrank(Canvas canvas, AxleData axle) {
    canvas.save();
    canvas.translate(axle.x, axle.y);
    
    double crankRot = axle.dir * (teethPassed / axle.expectedN) * 2 * pi;
    canvas.rotate(crankRot);

    // Crank Arm
    _drawRoundedRect(canvas, -15, -12, 100, 24, 12, const Color(0xFF64748B), const Color(0xFF0F172A), 3);
    
    // Center Pivot
    canvas.drawCircle(Offset.zero, 14, Paint()..color = const Color(0xFF475569));
    canvas.drawCircle(Offset.zero, 14, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    // Handle
    canvas.drawCircle(const Offset(85, 0), 18, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(const Offset(85, 0), 18, Paint()..color = const Color(0xFF020617)..style = PaintingStyle.stroke..strokeWidth = 3);
    
    // Grip rings
    canvas.drawCircle(const Offset(85, 0), 10, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 2);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LCMLabPainter oldDelegate) => true;
}

// ----------------------------------------------------------------------------
// Translations
// ----------------------------------------------------------------------------
class Translations {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'shutterTitle': "The Gear Aligner: A Visual Journey to the Lowest Common Multiple (LCM)",
      'appTitle': "The Gear Aligner: A Visual Journey to the LCM", 
      'appSubtitle': "Class 7 • FINDING COMMON GROUND", 'enterLab': "Enter Simulation",
      'settings': "Settings", 'theme': "Theme", 'darkMode': "Switch to Dark Mode", 'lightMode': "Switch to Light Mode", 'boardFontSize': "Text Size", 
      'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done", 'gotItBtn': "Got It!",
      'learnLbl': "Observations:", 'closeBtn': "Close", 'summaryTitle': "Goal Reached!",
      'resetBtnUI': "Reset", 'finishLab': "Finish Lab", 'nextScenario': "Next Scenario",
      'labCompleted': "Lab Completed!", 'finalDesc': "You have successfully explored the Lowest Common Multiple (LCM) visually!",
      'checkAnswer': "Check Answer", 'revealAnswer': "Reveal Answer", 'continueBtn': "Continue",
      'keepTrying': "Keep turning the crank to find the alignment point.",
      'teeth': "TEETH", 'anshu': "ANSHU", 'guna': "GUNA", 'counter': "COUNTER",

      's1_gear1_lbl': "BLUE GEAR\nMULTIPLES", 's1_gear2_lbl': "GREEN GEAR\nMULTIPLES",
      's2_gear1_lbl': "YELLOW GEAR\nMULTIPLES", 's2_gear2_lbl': "PURPLE GEAR\nMULTIPLES",
      's3_gear1_lbl': "RED GEAR\nMULTIPLES", 's3_gear2_lbl': "BLUE GEAR\nMULTIPLES",
      'mission_objective': "MISSION OBJECTIVE:", 'ding': "DING!",
      's1_mission': "Understand Common Multiples", 's2_mission': "Find the LCM of 7 and 10", 's3_mission': "Shortest Toran they can both make.",
      's4_mission': "To independently find the LCM of 14 and 30 by operating the gear system.",
      's5_mission': "Extend LCM to three numbers: 3, 5, and 7",

      's1_res_title': "The Result (LCM)",
      's1_res_desc': "The gears first align at 12! This is the Lowest Common Multiple (LCM) of 4 and 6.",
      's1_list1': "Blue (4): 4, 8, <span class='bg-amber-400'>12</span>, 16...",
      's1_list2': "Green (6): 6, <span class='bg-amber-400'>12</span>, 18...",
      
      's2_res_title': "The Result (LCM)",
      's2_res_desc': "Alignment at 70! The LCM of 7 and 10 is 70. Kabamai will get her free gajak in 70 days.",
      's2_list1': "Yellow (7): 7, 14, 21, ..., 63, <span class='bg-amber-400'>70</span>, 77...",
      's2_list2': "Purple (10): 10, 20, 30, ..., 60, <span class='bg-amber-400'>70</span>, 80...",

      's3_res_title1': "First Alignment!",
      's3_res_desc1': "First alignment at 24! This is the LCM. The shortest toran they can both make is 24 cm long.",
      's3_list1_1': "Red (6): 6, 12, 18, <span class='bg-amber-400'>24</span>...",
      's3_list2_1': "Blue (8): 8, 16, <span class='bg-amber-400'>24</span>...",
      
      's3_res_title2': "Second Alignment!",
      's3_res_desc2': "Another alignment at 48! This is a Common Multiple, but not the Lowest one. The LCM is 24.",
      's3_list1_2': "Red (6): ..., 24, ..., 42, <span class='bg-slate-300'>48</span>...",
      's3_list2_2': "Blue (8): ..., 24, ..., 40, <span class='bg-slate-300'>48</span>...",

      's4_res_title': "LCM FOUND",
      's4_res_desc': "Excellent! The first number for which 'idli-vada' is called out is 210. The LCM of 14 and 30 is 210.",
      's4_list1': "Multiples of 14: 14, 28, ..., 196, <span class='bg-amber-400'>210</span>...",
      's4_list2': "Multiples of 30: 30, 60, ..., 180, <span class='bg-amber-400'>210</span>...",

      's5_res_title': "LCM CONFIRMED",
      's5_res_desc': "Amazing! The LCM of 3, 5, and 7 is 105. The cowherd had 105 cows.",
      's5_list1': "Multiples of 3: 3, 6, ..., <span class='bg-amber-400'>105</span>",
      's5_list2': "Multiples of 5: 5, 10, ..., <span class='bg-amber-400'>105</span>",
      's5_list3': "Multiples of 7: 7, 14, ..., <span class='bg-amber-400'>105</span>",

      's1_title': "1. The Two-Gear Tune-Up", 's1_obj': "To understand the concept of common multiples by finding the first alignment point of two simple gears.",
      's1_step1_task': "A workbench appears with two gears: a blue gear with 4 teeth and a green gear with 6 teeth. DRAG the blue gear onto the left axle and the green gear onto the right axle.", 's1_step1_out': "Both gears are mounted on the axles, ready to be turned. A red mark is visible on the top tooth of each gear.",
      's1_step2_task': "CLICK and HOLD the crank handle on the green gear. DRAG it clockwise to rotate the gears.", 's1_step2_out': "As the crank turns, the gears rotate. The 'Blue Gear Multiples' counter increments every time a blue tooth passes the top point.",
      's1_step3_task': "Continue rotating the crank until the red marks on both gears align at the top for the first time.", 's1_step3_out': "The simulation automatically stops and flashes when the red marks align perfectly. Both counters display 12.",
      's1_step4_task': "The system highlights the lists of multiples generated.", 's1_step4_out': "The number 12 is highlighted as the Lowest Common Multiple.",
      's1_hud1': "Drag both gears onto the empty axles.", 's1_hud2': "Drag the crank clockwise to spin.", 's1_hud3': "Keep cranking until the red marks meet at the top.", 's1_hud4': "Review the Lowest Common Multiple (LCM).",

      's2_title': "2. The Sweet Shop Cycle", 's2_obj': "Find the LCM of 7 and 10 to solve the sweet shop problem.",
      's2_step1_task': "You are presented with a 7-tooth (yellow) gear and a 10-tooth (purple) gear. DRAG both gears onto their respective axles.", 's2_step1_out': "The 7-tooth and 10-tooth gears are meshed. Counters for each gear appear.",
      's2_step2_task': "CLICK and DRAG the crank handle clockwise.", 's2_step2_out': "The gears rotate, and the counters for 7 and 10 begin to list their multiples.",
      's2_step3_task': "Keep rotating until the red marks align at the top.", 's2_step3_out': "Alignment at 70! The LCM of 7 and 10 is 70.",
      's2_hud1': "Mount the 7 and 10 tooth gears.", 's2_hud2': "Spin the crank.", 's2_hud3': "Find the first alignment point.",

      's3_title': "3. The Toran Challenge", 's3_obj': "Find the LCM for 6 and 8, showing it is the first alignment, not just any multiple.",
      's3_step1_task': "DRAG the 6-tooth (red) gear and 8-tooth (blue) gear onto the axles.", 's3_step1_out': "Gears are mounted and ready.",
      's3_step2_task': "ROTATE the crank handle. The system will auto-stop at the first alignment point.", 's3_step2_out': "First alignment at 24! The LCM is 24.",
      's3_step3_task': "CLICK the 'Continue' button and crank to the NEXT alignment.", 's3_step3_out': "Aligned at 48. This is a common multiple, but 24 is the LOWEST common multiple.",
      's3_hud1': "Mount the 6 and 8 tooth gears.", 's3_hud2': "Crank until they auto-stop.", 's3_hud3': "Click continue and find the next alignment point.",

      's4_title': "4. The Idli-Vada Game", 's4_obj': "To independently find the LCM of 14 and 30 by operating the gear system.",
      's4_step1_task': "A 14-tooth gear and a 30-tooth gear are on the workbench. DRAG them to the axles to begin.", 's4_step1_out': "The gears are meshed, marked, and ready to turn. Counters for 14 and 30 are visible.",
      's4_step2_task': "ROTATE the crank handle. Watch the red marks carefully and stop turning when they align at the top.", 's4_step2_out': "The user manually stops rotating the crank when the marks align.",
      's4_step3_task': "Once you find the correct alignment, CLICK the 'Check Answer' button.", 's4_step3_out': "The system confirms the LCM.",
      's4_hud1': "Mount the 14 and 30 tooth gears.", 's4_hud2': "Crank carefully. Stop when marks perfectly align.", 's4_hud3': "Check your answer.",

      's5_title': "5. The Triple-Gate Challenge", 's5_obj': "Extend the concept of LCM to three numbers: 3, 5, and 7.",
      's5_step1_task': "DRAG the 3, 5, and 7-tooth gears onto the three axles.", 's5_step1_out': "All three gears are meshed.",
      's5_step2_task': "ROTATE the crank to find the first point where ALL THREE red marks align at the top.", 's5_step2_out': "You aligned all three gears.",
      's5_step3_task': "CLICK 'Reveal Answer' when aligned.", 's5_step3_out': "Amazing! The LCM of 3, 5, and 7 is 105.",
      's5_hud1': "Mount all three gears.", 's5_hud2': "Crank until all THREE marks point straight up.", 's5_hud3': "Reveal the final answer."
    },
    'hi': {
      'shutterTitle': "गियर अलाइनर: लघुत्तम समापवर्त्य (LCM)",
      'appTitle': "गियर अलाइनर: लघुत्तम समापवर्त्य", 
      'appSubtitle': "कक्षा 7 • FINDING COMMON GROUND", 'enterLab': "सिमुलेशन दर्ज करें",
      'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण", 'gotItBtn': "समझ गया!",
      'learnLbl': "अवलोकन:", 'closeBtn': "बंद करें", 'summaryTitle': "लक्ष्य प्राप्त हुआ!",
      'resetBtnUI': "रीसेट", 'finishLab': "समाप्त करें", 'nextScenario': "अगला परिदृश्य",
      'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने दृश्य रूप से लघुत्तम समापवर्त्य (LCM) का सफलतापूर्वक पता लगाया है!",
      'checkAnswer': "उत्तर जांचें", 'revealAnswer': "उत्तर दिखाएं", 'continueBtn': "जारी रखें",
      'keepTrying': "संरेखण बिंदु खोजने के लिए क्रैंक घुमाते रहें।",
      'teeth': "दांत", 'anshu': "अंशु", 'guna': "गुना", 'counter': "काउंटर",

      's1_gear1_lbl': "नीला गियर\nगुणज", 's1_gear2_lbl': "हरा गियर\nगुणज",
      's2_gear1_lbl': "पीला गियर\nगुणज", 's2_gear2_lbl': "बैंगनी गियर\nगुणज",
      's3_gear1_lbl': "लाल गियर\nगुणज", 's3_gear2_lbl': "नीला गियर\nगुणज",
      'mission_objective': "मिशन का उद्देश्य:", 'ding': "डिंग!",
      's1_mission': "सामान्य गुणजों को समझें", 's2_mission': "7 और 10 का LCM खोजें", 's3_mission': "सबसे छोटा तोरण खोजें",
      's4_mission': "स्वतंत्र रूप से 14 और 30 का LCM खोजें।",
      's5_mission': "तीन संख्याओं (3, 5, 7) के लिए LCM का विस्तार करें",

      's1_res_title': "परिणाम (LCM)", 's1_res_desc': "गियर 12 पर मिलते हैं! यह 4 और 6 का LCM है।",
      's1_list1': "नीला (4): 4, 8, <span class='bg-amber-400'>12</span>, 16...",
      's1_list2': "हरा (6): 6, <span class='bg-amber-400'>12</span>, 18...",
      
      's2_res_title': "परिणाम (LCM)", 's2_res_desc': "70 पर संरेखण! LCM 70 है। कबामाई को 70 दिनों में गजक मिलेगी।",
      's2_list1': "पीला (7): 7, 14, 21, ..., <span class='bg-amber-400'>70</span>...",
      's2_list2': "बैंगनी (10): 10, 20, 30, ..., <span class='bg-amber-400'>70</span>...",

      's3_res_title1': "पहला संरेखण!", 's3_res_desc1': "24 पर पहला संरेखण! यह LCM है।",
      's3_list1_1': "लाल (6): 6, 12, 18, <span class='bg-amber-400'>24</span>...",
      's3_list2_1': "नीला (8): 8, 16, <span class='bg-amber-400'>24</span>...",
      
      's3_res_title2': "दूसरा संरेखण!", 's3_res_desc2': "48 पर संरेखित। यह सामान्य गुणज है, लेकिन LCM 24 है।",
      's3_list1_2': "लाल (6): ..., 24, ..., 42, <span class='bg-slate-300'>48</span>...",
      's3_list2_2': "नीला (8): ..., 24, ..., 40, <span class='bg-slate-300'>48</span>...",

      's4_res_title': "LCM मिला",
      's4_res_desc': "उत्कृष्ट! पहली संख्या जिसके लिए 'इडली-वड़ा' पुकारा जाता है, 210 है। 14 और 30 का LCM 210 है।",
      's4_list1': "14 के गुणज: 14, 28, ..., 196, <span class='bg-amber-400'>210</span>...",
      's4_list2': "30 के गुणज: 30, 60, ..., 180, <span class='bg-amber-400'>210</span>...",

      's5_res_title': "LCM की पुष्टि",
      's5_res_desc': "अद्भुत! 3, 5, और 7 का LCM 105 है। चरवाहे के पास 105 गायें थीं।",
      's5_list1': "3 के गुणज: 3, 6, ..., <span class='bg-amber-400'>105</span>",
      's5_list2': "5 के गुणज: 5, 10, ..., <span class='bg-amber-400'>105</span>",
      's5_list3': "7 के गुणज: 7, 14, ..., <span class='bg-amber-400'>105</span>",

      's1_title': "1. दो-गियर ट्यून-अप", 's1_obj': "दो गियर के पहले संरेखण बिंदु को खोजकर सामान्य गुणजों को समझें।",
      's1_step1_task': "4-दांत और 6-दांत वाले गियर को धुरी पर खींचें।", 's1_step1_out': "गियर लगे हैं। लाल निशान शीर्ष पर हैं।",
      's1_step2_task': "क्रैंक हैंडल को घुमाएं।", 's1_step2_out': "काउंटर पूर्ण घुमावों को ट्रैक करते हैं।",
      's1_step3_task': "तब तक घुमाएं जब तक कि दोनों लाल निशान शीर्ष पर न आ जाएं।", 's1_step3_out': "गियर 12 पर मिलते हैं!",
      's1_step4_task': "सिस्टम अब उत्पन्न गुणकों की सूची को उजागर करेगा।", 's1_step4_out': "12 LCM है।",
      's1_hud1': "दोनों गियर धुरी पर खींचें।", 's1_hud2': "घुमाने के लिए क्रैंक को खींचें।", 's1_hud3': "तब तक घुमाएं जब तक निशान न मिलें।", 's1_hud4': "LCM की समीक्षा करें।",

      's2_title': "2. स्वीट शॉप साइकिल", 's2_obj': "मिठाई की दुकान की समस्या को हल करने के लिए 7 और 10 का LCM खोजें।",
      's2_step1_task': "7 और 10-दांत वाले गियर को धुरी पर खींचें।", 's2_step1_out': "गियर लगे हैं।",
      's2_step2_task': "गियर घुमाने के लिए क्रैंक को खींचें।", 's2_step2_out': "काउंटर गुणज दिखाते हैं।",
      's2_step3_task': "लाल निशान संरेखित होने तक घुमाते रहें।", 's2_step3_out': "70 पर संरेखण! LCM 70 है।",
      's2_hud1': "7 और 10 दांत वाले गियर लगाएं।", 's2_hud2': "क्रैंक घुमाएं।", 's2_hud3': "पहला संरेखण बिंदु खोजें।",

      's3_title': "3. तोरण चुनौती", 's3_obj': "6 और 8 के लिए LCM खोजें।",
      's3_step1_task': "6 और 8-दांत वाले गियर को धुरी पर खींचें।", 's3_step1_out': "गियर लगे हैं।",
      's3_step2_task': "क्रैंक घुमाएं। यह पहले संरेखण पर रुकेगा।", 's3_step2_out': "24 पर पहला संरेखण! LCM 24 है।",
      's3_step3_task': "'जारी रखें' पर क्लिक करें और अगले संरेखण तक घुमाएं।", 's3_step3_out': "48 पर संरेखित। 24 सबसे छोटा है।",
      's3_hud1': "6 और 8 दांत वाले गियर लगाएं।", 's3_hud2': "रुकने तक क्रैंक करें।", 's3_hud3': "अगला संरेखण बिंदु खोजें।",

      's4_title': "4. इडली-वड़ा गेम", 's4_obj': "स्वतंत्र रूप से 14 और 30 का LCM खोजें।",
      's4_step1_task': "14-दांत और 30-दांत वाले गियर को धुरी पर खींचें।", 's4_step1_out': "गियर तैयार हैं। 14 और 30 के काउंटर दिखाई दे रहे हैं।",
      's4_step2_task': "क्रैंक को मैन्युअल रूप से घुमाएं। लाल निशान शीर्ष पर संरेखित होने पर रुकें।", 's4_step2_out': "उपयोगकर्ता संरेखण पर रुक जाता है। काउंटर 210 दिखाना चाहिए।",
      's4_step3_task': "संरेखण खोजने के बाद, 'उत्तर जांचें' बटन पर क्लिक करें।", 's4_step3_out': "सिस्टम LCM की पुष्टि करता है।",
      's4_hud1': "14 और 30 दांत वाले गियर लगाएं।", 's4_hud2': "ध्यान से घुमाएं और रुकें।", 's4_hud3': "अपना उत्तर जांचें।",

      's5_title': "5. ट्रिपल-गेट चुनौती", 's5_obj': "तीन संख्याओं (3, 5, 7) के लिए LCM खोजें।",
      's5_step1_task': "3, 5, और 7-दांत वाले गियर को तीन धुरियों पर खींचें।", 's5_step1_out': "तीनों गियर लगे हैं।",
      's5_step2_task': "तब तक घुमाएं जब तक तीनों लाल निशान शीर्ष पर न आ जाएं।", 's5_step2_out': "आपने तीनों को संरेखित किया।",
      's5_step3_task': "'उत्तर दिखाएं' पर क्लिक करें।", 's5_step3_out': "अद्भुत! 3, 5, और 7 का LCM 105 है।",
      's5_hud1': "तीनों गियर लगाएं।", 's5_hud2': "तीनों निशान सीधे ऊपर होने तक घुमाएं।", 's5_hud3': "अंतिम उत्तर दिखाएं।"
    }
  };
}