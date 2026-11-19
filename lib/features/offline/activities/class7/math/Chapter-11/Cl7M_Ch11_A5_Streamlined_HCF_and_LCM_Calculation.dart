// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class StreamlinedHCFandLCMCalculation extends StatefulWidget {
  const StreamlinedHCFandLCMCalculation({Key? key}) : super(key: key);

  @override
  _StreamlinedHCFandLCMCalculationState createState() => _StreamlinedHCFandLCMCalculationState();
}

class NumberData {
  final int initVal;
  int curVal;
  double displayVal;
  final Color color;
  double x, y, initX, initY, targetX, targetY;
  bool mounted;
  double? fallX, fallY, fallTargetX, fallTargetY;

  NumberData({
    required this.initVal,
    required this.curVal,
    required this.displayVal,
    required this.color,
    required this.x,
    required this.y,
    required this.initX,
    required this.initY,
    this.targetX = 0,
    this.targetY = 0,
    this.mounted = false,
  });
}

class GearData {
  final int val;
  final String tray;
  double x, y, initX, initY, r;
  bool isGlowing, isHovered;

  GearData({
    required this.val,
    required this.tray,
    required this.x,
    required this.y,
    required this.initX,
    required this.initY,
    this.r = 18.0,
    this.isGlowing = false,
    this.isHovered = false,
  });
}

class _StreamlinedHCFandLCMCalculationState extends State<StreamlinedHCFandLCMCalculation> with TickerProviderStateMixin {
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
  double _successDx = 0.0;
  double _successDy = 0.0;
  
  // LCM Popup Panel State
  bool _lcmPanelVisible = false;
  double _lcmDx = 0.0;
  double _lcmDy = 0.0;

  // Zoom and Pan State
  double _zoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;
  double _baseZoom = 1.0;
  bool _isDraggingObject = false;
  bool _isLocked = false;

  // Simulation State
  List<NumberData> _numbers = [];
  List<GearData> _gears = [];
  List<int> _extractedHCF = [];
  List<int> _extractedLCM = [];
  List<int> _leftovers = [];
  bool _isFinalized = false;
  bool _isCalculatingLCM = false;
  String _machineMode = 'HCF';
  
  dynamic _activeDragItem; // {type: 'number'|'gear', obj: dynamic}
  int _showBuzz = 0;
  bool _showWordProblem = false;

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
      _updateAnimations();
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

  void _updateAnimations() {
    if (!mounted) return;
    bool needsRepaint = false;

    // Smoothly animate display values and falling coordinates
    for (var n in _numbers) {
      if (n.displayVal > n.curVal) {
        n.displayVal -= (n.displayVal - n.curVal) * 0.1;
        if ((n.displayVal - n.curVal).abs() < 0.1) n.displayVal = n.curVal.toDouble();
        needsRepaint = true;
      }
      if (_isFinalized && (n.curVal > 1 || _scenario == 3)) {
        if (n.fallTargetX != null && n.fallTargetY != null && n.fallX != null && n.fallY != null) {
          n.fallX = n.fallX! + (n.fallTargetX! - n.fallX!) * 0.1;
          n.fallY = n.fallY! + (n.fallTargetY! - n.fallY!) * 0.1;
          needsRepaint = true;
        }
      }
    }

    if (_showBuzz > 0) {
      _showBuzz--;
      needsRepaint = true;
    }

    if (needsRepaint) setState(() {});
  }

  void _playSound(String type) async {
    try {
      switch (type) {
        case 'tick':
        case 'snap':
          await _clickPlayer.play(AssetSource(_clickUrl));
          break;
        case 'success':
          await _successPlayer.play(AssetSource(_successUrl));
          break;
        case 'error':
          await _errorPlayer.play(AssetSource(_errorUrl));
          break;
        case 'pop':
        case 'machine':
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
      
      _numbers = [];
      _gears = [];
      _extractedHCF = [];
      _extractedLCM = [];
      _leftovers = [];
      _isFinalized = false;
      _isCalculatingLCM = false;
      _machineMode = 'HCF';
      _showBuzz = 0;
      _activeDragItem = null;
      _lcmPanelVisible = false;
      _showSuccessPopup = false;
      
      _showWordProblem = (_scenario == 4);

      Map<int, Map<String, dynamic>> conf = {
        1: { 'nums': [84, 180], 'colors': [const Color(0xFF4ADE80), const Color(0xFFF97316)], 'gears': [2, 3, 5, 7], 'compGears': <int>[] },
        2: { 'nums': [42, 75, 24], 'colors': [const Color(0xFF4ADE80), const Color(0xFFF97316), const Color(0xFF3B82F6)], 'gears': [2, 3, 5, 7], 'compGears': <int>[] },
        3: { 'nums': [300, 150], 'colors': [const Color(0xFF4ADE80), const Color(0xFFF97316)], 'gears': [2, 3, 5, 7], 'compGears': [10, 25, 50] },
        4: { 'nums': [90, 132], 'colors': [const Color(0xFF4ADE80), const Color(0xFFF97316)], 'gears': [2, 3, 5, 7], 'compGears': [6] },
        5: { 'nums': [240, 378, 300], 'colors': [const Color(0xFF4ADE80), const Color(0xFFF97316), const Color(0xFF3B82F6)], 'gears': [2, 3, 5, 7], 'compGears': <int>[] }
      };

      var c = conf[_scenario]!;
      List<int> nums = List<int>.from(c['nums']);
      List<Color> colors = List<Color>.from(c['colors']);
      List<int> gears = List<int>.from(c['gears']);
      List<int> compGears = List<int>.from(c['compGears']);

      double cx = 150, cy = -20, w = 380 + (nums.length == 3 ? 100 : 0.0), h = 340;
      double tableY = cy + h/2 - 20;
      double trayW = 280;
      double trayX = cx - w/2 - trayW/2 - 50;
      double tray1Y = tableY - 150;
      double tray2Y = tableY - 50;
      double tray3Y = tableY + 50;

      for (int i = 0; i < nums.length; i++) {
        double startX = trayX - (nums.length * 65)/2 + 32.5;
        _numbers.add(NumberData(
          initVal: nums[i], curVal: nums[i], displayVal: nums[i].toDouble(), color: colors[i],
          x: startX + i * 65, y: tray1Y + 50, initX: startX + i * 65, initY: tray1Y + 50,
        ));
      }

      for (int i = 0; i < gears.length; i++) {
        double startX = trayX - (gears.length * 45)/2 + 22.5;
        _gears.add(GearData(
          val: gears[i], tray: 'prime', x: startX + i * 45, y: tray2Y + 50, initX: startX + i * 45, initY: tray2Y + 50,
        ));
      }

      if (compGears.isNotEmpty) {
        for (int i = 0; i < compGears.length; i++) {
          double startX = trayX - (compGears.length * 45)/2 + 22.5;
          _gears.add(GearData(
            val: compGears[i], tray: 'comp', x: startX + i * 45, y: tray3Y + 50, initX: startX + i * 45, initY: tray3Y + 50,
          ));
        }
      }

      _applyStepHighlights();
      _updateHud();
    });
    _scrollToActiveStep();
  }

  void _handleReset() {
    _playSound('pop');
    _loadScenario(1); 
    setState(() {
      _showCurtain = true;
      _currentLang = 'en'; 
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
      _hudMessage = t('labCompleted');
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
      case 1: return 5;
      case 2: return 4;
      case 3: return 4;
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
        targetStep = _getTotalSteps(_scenario) - 1; 
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
      _applyStepHighlights();
      _updateHud();
      if (_step >= _getTotalSteps(_scenario)) {
        _completedScenarios.add(_scenario);
        if (_completedScenarios.length == 5 && !_lcmPanelVisible) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && !_lcmPanelVisible) {
              setState(() => _showSuccessPopup = true);
              _playSound('success');
            }
          });
        }
      }
    });
    _scrollToActiveStep();
  }

  void _applyStepHighlights() {
    for (var g in _gears) { g.isGlowing = false; }
    
    if (_numbers.every((n) => n.mounted)) {
      int s = _scenario;
      if (s == 1 && _step == 1) _gears.firstWhere((g)=>g.val==2).isGlowing = true;
      if (s == 1 && _step == 2) _gears.firstWhere((g)=>g.val==2).isGlowing = true;
      if (s == 1 && _step == 3) _gears.firstWhere((g)=>g.val==3).isGlowing = true;
      
      if (s == 2 && _step == 1) _gears.firstWhere((g)=>g.val==3).isGlowing = true;
      
      if (s == 3 && _step == 1) _gears.firstWhere((g)=>g.val==50).isGlowing = true;
      if (s == 3 && _step == 2) _gears.firstWhere((g)=>g.val==3).isGlowing = true;
    }
  }

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
  
  bool _hasNoCommonFactor(List<int> arr) {
    if (arr.isEmpty) return true;
    int res = arr[0];
    for (int i = 1; i < arr.length; i++) res = _gcd(res, arr[i]);
    return res == 1;
  }

  String _getMachineActionText() {
    if (!_numbers.every((n) => n.mounted) || _isFinalized) return "";
    
    int s = _scenario;
    if (s == 1 && _step == 4) return t('checkAnswer'); // Finalize
    if (s == 2 && _step == 3) return _isCalculatingLCM ? "" : (_machineMode == 'LCM' ? t('checkAnswer') : t('revealAnswer')); 
    if (s == 3 && _step == 3) return t('checkAnswer'); 
    if (s == 4 && _step == 2) return t('checkAnswer'); 
    if (s == 5 && _step == 2) return _isCalculatingLCM ? "" : (_machineMode == 'LCM' ? t('checkAnswer') : t('revealAnswer')); 
    return "";
  }

  void _triggerMachineAction() {
    _playSound('tick');
    String actionBtnText = _getMachineActionText();
    
    if (actionBtnText == t('checkAnswer')) { // FINALIZE
      setState(() {
        _isFinalized = true;
        
        double cx = 150, cy = -20;
        double w = 380 + (_numbers.length == 3 ? 100 : 0);
        double h = 340;
        double tableY = cy + h/2 - 20;
        double binX = cx;
        double binW = w - 60;
        double binStartY = tableY + 90; 
        double binStartX = binX - binW/2 + 50;
        
        double currentX = binStartX + _extractedLCM.length * 40;
        double currentY = binStartY;

        for (var n in _numbers) {
          if (n.curVal > 1 || _scenario == 3) {
            _leftovers.add(n.curVal);
            n.fallTargetX = currentX;
            n.fallTargetY = currentY;
            n.fallX = n.targetX; 
            n.fallY = n.targetY + 140;
            
            if (currentX > binX + binW/2 - 60) {
              currentX = binStartX;
              currentY += 45;
            } else {
              currentX += 50;
            }
          }
        }
      });

      _playSound('machine');
      
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _lcmPanelVisible = true;
            _advanceStep();
          });
        }
      });

    } else if (actionBtnText == t('revealAnswer')) { // CALCULATE LCM
      setState(() {
        _machineMode = 'LCM';
        _autoCalculateLCM();
      });
    }
  }

  void _autoCalculateLCM() async {
    if (_isCalculatingLCM) return;
    setState(() => _isCalculatingLCM = true);
    
    while(true) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      
      int? foundFactor;
      int maxNum = _numbers.map((n) => n.curVal).reduce(max);
      
      for (int f = 2; f <= maxNum; f++) {
        int count = 0;
        for (var n in _numbers) {
          if (n.curVal % f == 0) count++;
        }
        if (count >= 2) {
          foundFactor = f; break;
        }
      }
      
      if (foundFactor == null) {
        setState(() {
          _isCalculatingLCM = false;
        });
        return;
      }

      int factor = foundFactor;
      
      setState(() {
        _playSound('machine');
        bool actualDivide = false;
        for (var n in _numbers) {
          if (n.curVal % factor == 0) {
            n.curVal = n.curVal ~/ factor;
            actualDivide = true;
          }
        }
        if (actualDivide && factor > 1) {
          _extractedLCM.add(factor);
        }
      });
    }
  }

  void _closeLcmPanel() {
    _playSound('tick');
    setState(() {
      _lcmPanelVisible = false;
      if (_completedScenarios.length == 5) {
        _showSuccessPopup = true;
        _playSound('success');
      }
    });
  }

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
  
  bool _hitTestRect(double rx, double ry, double w, double h, Offset pt) {
    return pt.dx >= rx && pt.dx <= rx + w && pt.dy >= ry && pt.dy <= ry + h;
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    Offset pt = _getCanvasCoord(details.localFocalPoint, size);
    _baseZoom = _zoom;
    _activeDragItem = null;

    if (_isFinalized || _isLocked) return;

    if (_step == 0) {
      for (var n in _numbers) {
        if (!n.mounted && _hitTestRect(n.x - 25, n.y - 25, 50, 50, pt)) {
          setState(() {
            _activeDragItem = {'type': 'number', 'obj': n};
          });
          _playSound('tick');
          return;
        }
      }
    }

    if (_numbers.every((n) => n.mounted)) {
      int s = _scenario;
      if (s == 2 && _step == 2) {
        var g2 = _gears.firstWhere((g) => g.val == 2);
        if (_hitTestCircle(g2.x, g2.y, g2.r, pt)) {
          _playSound('error');
          setState(() { _showBuzz = 120; });
          _showTemporaryHud(t('s2_step3_tooltip'));
          _advanceStep();
          return;
        }
      } else if (s == 2 && _step >= 3) {
        return;
      } else {
        for (var g in _gears) {
          if (_hitTestCircle(g.x, g.y, g.r, pt)) {
            setState(() {
              _activeDragItem = {'type': 'gear', 'obj': g};
            });
            _playSound('tick');
            return;
          }
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _getCanvasCoord(details.localFocalPoint, size);

    setState(() {
      for (var g in _gears) {
        g.isHovered = _hitTestCircle(g.x, g.y, g.r, pt) && _activeDragItem == null;
      }

      if (_activeDragItem != null) {
        _activeDragItem['obj'].x = pt.dx;
        _activeDragItem['obj'].y = pt.dy;
      } else if (!_isLocked) {
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
        _zoom = (_baseZoom * details.scale).clamp(0.3, 2.0);
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_activeDragItem == null) return;
    
    setState(() {
      if (_activeDragItem['type'] == 'number') {
        NumberData n = _activeDragItem['obj'];
        bool mounted = false;
        
        if (sqrt(pow(n.targetX - n.x, 2) + pow(n.targetY - n.y, 2)) < 80) {
          n.x = n.targetX;
          n.y = n.targetY;
          n.mounted = true;
          mounted = true;
          _playSound('snap');
        }
        
        if (!mounted) {
          n.x = n.initX;
          n.y = n.initY;
          _playSound('pop');
        }
        
        if (_numbers.every((x) => x.mounted)) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if(mounted) {
              _advanceStep();
              _applyStepHighlights();
            }
          });
        }
      } else if (_activeDragItem['type'] == 'gear') {
        GearData g = _activeDragItem['obj'];
        double cx = 150, cy = -20;
        double w = 380 + (_numbers.length == 3 ? 100 : 0);
        double slotX = cx + w/2 + 50;
        double slotY = cy;
        bool processed = false;
        
        if (sqrt(pow(slotX - g.x, 2) + pow(slotY - g.y, 2)) < 80) {
          int s = _scenario;
          Map<int, Map<int, int>> expectedGear = {
            1: {1: 2, 2: 2, 3: 3},
            2: {1: 3},
            3: {1: 50, 2: 3}
          };
          
          bool isExpected = false;
          if (s <= 3) {
            if (expectedGear[s] != null && expectedGear[s]![_step] == g.val) isExpected = true;
          } else {
            isExpected = _numbers.every((n) => n.curVal % g.val == 0);
          }

          if (isExpected) {
            _playSound('machine');
            for (var n in _numbers) { n.curVal = n.curVal ~/ g.val; }
            _extractedHCF.add(g.val);
            processed = true;
            
            if (s <= 3) {
              _advanceStep();
              _applyStepHighlights();
            } else {
              if (_hasNoCommonFactor(_numbers.map((n)=>n.curVal).toList())) {
                _showTemporaryHud(t('noMoreCommonFactors'));
                if (s == 4 && _step == 1) _advanceStep();
                if (s == 5 && _step == 1) _advanceStep();
              }
            }
          } else {
            _playSound('error');
            _showBuzz = 120;
            _showTemporaryHud(t('notCommonFactor'));
          }
        }
        
        g.x = g.initX;
        g.y = g.initY;
        if (!processed && sqrt(pow(slotX - g.x, 2) + pow(slotY - g.y, 2)) >= 80) _playSound('pop');
      }
      
      _activeDragItem = null;
    });
  }

  // --- UI Builders ---
  Widget _buildSidebar() {
    double sidebarWidth = MediaQuery.of(context).size.width * 0.30;
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

  Widget _buildLcmResultPanel() {
    if (!_lcmPanelVisible) return const SizedBox.shrink();

    String hcfStr = _extractedHCF.join(' × ');
    int hcfVal = _extractedHCF.isEmpty ? 1 : _extractedHCF.reduce((a, b) => a * b);
    
    List<int> lcmArr = [..._extractedHCF, ..._extractedLCM, ..._leftovers];
    int lcmVal = lcmArr.isEmpty ? 1 : lcmArr.reduce((a, b) => a * b);
    
    List<String> lcmStrParts = [];
    if (_extractedHCF.isNotEmpty) lcmStrParts.add('($hcfStr)');
    if (_extractedLCM.isNotEmpty) lcmStrParts.add(_extractedLCM.join(' × '));
    if (_leftovers.isNotEmpty) lcmStrParts.add(_leftovers.join(' × '));
    String lcmStr = lcmStrParts.join(' × ');
    
    String msg = t('res_msg_s$_scenario');

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
              width: 320, 
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
                        Text(t('lcm_res_title') == 'lcm_res_title' ? "The Result" : t('lcm_res_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                          decoration: BoxDecoration(color: Colors.blueGrey.shade800, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueGrey.shade700)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(8)),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    children: [
                                      TextSpan(text: t('lcm_res_hcf'), style: const TextStyle(color: Colors.lightBlueAccent)),
                                      TextSpan(text: " = ${hcfStr.isEmpty ? '1' : hcfStr} = "),
                                      WidgetSpan(child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)), child: Text("$hcfVal", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                                    ]
                                  )
                                )
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: [
                                    Text("${t('lcm_res_lcm')} = ${t('lcm_res_hcf')} × Leftovers", style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 10)),
                                    const SizedBox(height: 4),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                        children: [
                                          TextSpan(text: t('lcm_res_lcm'), style: const TextStyle(color: Colors.lightBlueAccent)),
                                          TextSpan(text: " = $lcmStr = "),
                                          WidgetSpan(child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(4)), child: Text("$lcmVal", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                                        ]
                                      )
                                    )
                                  ]
                                )
                              )
                            ]
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(msg.replaceAll(RegExp(r'<[^>]*>'), ''), style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
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

  Widget _buildS4Modal() {
    if (!_showWordProblem) return const SizedBox.shrink();
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900]?.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
                child: const Icon(Icons.content_cut, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(t('s4_modal_title'), style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(t('s4_modal_desc').replaceAll(RegExp(r'<[^>]*>'), ''), style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _playSound('tick');
                  setState(() => _showWordProblem = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(t('s4_modal_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasBottomUI() {
    String btnTxt = _getMachineActionText();
    if (btnTxt.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 80, 
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _triggerMachineAction,
          icon: const Icon(Icons.check_circle),
          label: Text(btnTxt),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )
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
                  width: 280, 
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
                child: const Icon(Icons.calculate, color: Colors.indigoAccent, size: 80),
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
    double sidebarWidth = MediaQuery.of(context).size.width * 0.30; // 30% Width Request

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
                          painter: FactorLabPainter(
                            scenario: _scenario,
                            step: _step,
                            zoom: _zoom,
                            panX: _panX,
                            panY: _panY,
                            numbers: _numbers,
                            gears: _gears,
                            extractedHCF: _extractedHCF,
                            extractedLCM: _extractedLCM,
                            leftovers: _leftovers,
                            isFinalized: _isFinalized,
                            machineMode: _machineMode,
                            showBuzz: _showBuzz,
                            activeDragItem: _activeDragItem,
                            lang: _currentLang,
                            t: t,
                            totalSteps: _getTotalSteps(_scenario),
                          ),
                        ),
                      );
                    },
                  ),

                  // Floating UI on Canvas
                  _buildCanvasBottomUI(),
                  _buildS4Modal(),
                  _buildHudOverlay(),
                  
                  // LCM Popup Panel
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
// Custom Painter for Factor Machine
// ----------------------------------------------------------------------------
class FactorLabPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;
  final List<NumberData> numbers;
  final List<GearData> gears;
  final List<int> extractedHCF;
  final List<int> extractedLCM;
  final List<int> leftovers;
  final bool isFinalized;
  final String machineMode;
  final int showBuzz;
  final dynamic activeDragItem;
  final String lang;
  final Function(String) t;
  final int totalSteps;

  FactorLabPainter({
    required this.scenario, required this.step, required this.zoom, required this.panX, required this.panY,
    required this.numbers, required this.gears, required this.extractedHCF, required this.extractedLCM, required this.leftovers,
    required this.isFinalized, required this.machineMode, required this.showBuzz, required this.activeDragItem,
    required this.lang, required this.t, required this.totalSteps
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom);

    _drawMachine(canvas);

    for (var n in numbers) {
      if (!n.mounted) _drawNumberBlock(canvas, n);
    }

    if (numbers.isNotEmpty && numbers.every((n) => n.mounted)) {
      for (var g in gears) {
        if (activeDragItem == null || activeDragItem['obj'] != g) {
          _drawGear(canvas, g);
        }
      }
    }

    if (activeDragItem != null) {
      if (activeDragItem['type'] == 'number') _drawNumberBlock(canvas, activeDragItem['obj']);
      if (activeDragItem['type'] == 'gear') _drawGear(canvas, activeDragItem['obj']);
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

  void _drawTable(Canvas canvas, double cy, double h) {
    double tableY = cy + h / 2 - 20;
    double canvasW = 3000; // Arbitrary wide table
    
    canvas.drawRect(Rect.fromLTWH(-canvasW/2, tableY, canvasW, 1000), Paint()..color = const Color(0xFF854D0E));
    canvas.drawRect(Rect.fromLTWH(-canvasW/2, tableY, canvasW, 15), Paint()..color = const Color(0xFF713F12));
    
    canvas.drawOval(Rect.fromCenter(center: Offset(0, tableY + 10), width: 400, height: 60), Paint()..color = Colors.black.withOpacity(0.15));
  }

  void _drawRoboticClaw(Canvas canvas, double cx, double cy, bool isOpen, bool slotRed, bool isHighlighting) {
    canvas.save();
    canvas.translate(cx, cy);

    if (isHighlighting) {
      canvas.drawCircle(Offset.zero, 45, Paint()..color = const Color(0xFF6366F1).withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }
    
    _drawRoundedRect(canvas, -25, -20, 25, 40, 4, const Color(0xFF334155), const Color(0xFF1E293B), 2);
    
    canvas.drawLine(const Offset(-10, 0), const Offset(20, -25), Paint()..color = const Color(0xFF475569)..strokeWidth = 14..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    canvas.drawLine(const Offset(20, -25), const Offset(50, -5), Paint()..color = const Color(0xFF475569)..strokeWidth = 14..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    canvas.drawCircle(const Offset(-10, 0), 5, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(const Offset(20, -25), 6, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawCircle(const Offset(50, -5), 6, Paint()..color = const Color(0xFFCBD5E1));
    
    Color pincerColor = slotRed ? const Color(0xFFEF4444) : const Color(0xFF94A3B8);
    double spread = isOpen ? 15 : 2;

    var pPaint = Paint()..color = pincerColor..strokeWidth = 8..style = PaintingStyle.stroke;
    
    var pathTop = Path()..moveTo(50, -5)..lineTo(65, -15 - spread)..lineTo(85, -10 - spread)..lineTo(80, -5 - spread);
    canvas.drawPath(pathTop, pPaint);

    var pathBot = Path()..moveTo(50, -5)..lineTo(65, 5 + spread)..lineTo(85, 0 + spread)..lineTo(80, -5 + spread);
    canvas.drawPath(pathBot, pPaint);

    canvas.restore();
  }

  void _drawMachine(Canvas canvas) {
    double cx = 150, cy = -20; 
    double w = 380 + (numbers.length == 3 ? 100.0 : 0.0);
    double h = 340;

    _drawTable(canvas, cy, h);

    double tableY = cy + h/2 - 20;

    canvas.drawLine(Offset(cx + w/2, cy + 10), Offset(cx + w/2 + 100, cy + 10), Paint()..color = const Color(0xFF334155)..strokeWidth = 20);

    _drawRoundedRect(canvas, cx - w/2, cy - h/2, w, h, 20, const Color(0xFF334155), const Color(0xFF1E293B), 4);
    _drawRoundedRect(canvas, cx - w/2 + 20, cy - h/2 + 70, w - 40, h - 110, 10, const Color(0xFF0F172A), const Color(0xFF1E293B), 2);
    
    _drawText(canvas, "FACTOR EXTRACTOR", cx, cy - h/2 + 35, 24, const Color(0xFF94A3B8), Colors.transparent);

    double colW = 50;
    double spacing = w / (numbers.length + 1);
    int maxInit = numbers.isEmpty ? 1 : numbers.map((n)=>n.initVal).reduce(max);

    for (int i = 0; i < numbers.length; i++) {
      var n = numbers[i];
      double px = cx - w/2 + spacing * (i + 1);
      double py = cy - h/2 + 90; 
      
      var fTop = Path()..moveTo(px - 35, py - 30)..lineTo(px + 35, py - 30)..lineTo(px + 25, py)..lineTo(px - 25, py)..close();
      canvas.drawPath(fTop, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.fill);
      canvas.drawPath(fTop, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 2);
      
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py - 30), width: 70, height: 20), Paint()..color = const Color(0xFF64748B));
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py - 30), width: 70, height: 20), Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py - 30), width: 50, height: 10), Paint()..color = const Color(0xFF0F172A));

      n.targetX = px; n.targetY = py - 50;

      _drawRoundedRect(canvas, px - colW/2, py, colW, 140, 4, Colors.white.withOpacity(0.05), const Color(0xFF334155), 2);

      if (n.mounted) {
        double maxFillH = 136;
        double fillH = maxFillH * (n.displayVal / maxInit);
        
        if (isFinalized && (n.curVal > 1 || scenario == 3)) fillH = 0; 
        
        if (fillH > 0) {
          canvas.drawRect(Rect.fromLTWH(px - colW/2 + 2, py + 140 - fillH - 2, colW - 4, fillH), Paint()..color = n.color);
          canvas.drawOval(Rect.fromCenter(center: Offset(px, py + 140 - fillH - 2), width: colW - 4, height: 8), Paint()..color = Colors.white.withOpacity(0.3));
        }
        
        _drawRoundedRect(canvas, px - 25, py + 155, 50, 25, 4, const Color(0xFF0F172A), const Color(0xFF475569), 2);
        _drawText(canvas, n.displayVal.round().toString(), px, py + 167, 16, const Color(0xFF38BDF8), Colors.transparent);

        if (isFinalized && (n.curVal > 1 || scenario == 3)) { 
          if (n.fallY != null && n.fallX != null) {
            canvas.save();
            canvas.translate(n.fallX!, n.fallY!);
            canvas.scale(0.8, 0.8);
            _drawRoundedRect(canvas, -25, -25, 50, 50, 6, n.color, const Color(0xFF0F172A), 3);
            _drawText(canvas, n.displayVal.round().toString(), 0, 0, 20, Colors.white, const Color(0xFF0F172A));
            canvas.restore();
          }
        } else if (fillH > 0) {
          _drawText(canvas, n.displayVal.round().toString(), px, py + 160 - fillH + 20, 18, const Color(0xFF0F172A), Colors.transparent);
        }
      }

      canvas.drawRect(Rect.fromLTWH(px - colW/2 + 5, py + 2, 10, 136), Paint()..color = Colors.white.withOpacity(0.4));
    }

    double slotX = cx + w/2 + 50;
    double slotY = cy;
    
    bool slotIsRed = showBuzz > 0;
    bool armIsOpen = activeDragItem == null || activeDragItem['type'] != 'gear';
    bool anyGearGlowing = gears.any((g) => g.isGlowing);
    
    _drawRoboticClaw(canvas, cx + w/2, cy - 20, armIsOpen, slotIsRed, anyGearGlowing);

    double hcfW = 240; 
    double hcfX = cx + w/2 + 60;
    double hcfY = cy - 10;
    
    _drawRoundedRect(canvas, hcfX, hcfY, hcfW, 80, 8, const Color(0xFF0F172A), const Color(0xFF334155), 4);
    _drawRoundedRect(canvas, hcfX + 10, hcfY + 25, hcfW - 20, 45, 4, const Color(0xFF020617), const Color(0xFF475569), 2);
    
    _drawText(canvas, t('hcfTitle'), hcfX + hcfW/2, hcfY + 12, 12, const Color(0xFF94A3B8), Colors.transparent);
    
    if (extractedHCF.isNotEmpty) {
      String hcfText = extractedHCF.join(' × ');
      if (isFinalized || (scenario <= 3 && step >= totalSteps) || machineMode == 'LCM') {
        int val = extractedHCF.reduce((a,b)=>a*b);
        hcfText += " = $val";
      }
      _drawText(canvas, hcfText, hcfX + hcfW/2, hcfY + 47, 18, const Color(0xFF4ADE80), Colors.transparent);
    }

    double binW = w - 60;
    double binX = cx;
    double binY = tableY + 30; 
    double binH = 130; 
    
    var binPath = Path()..moveTo(binX - binW/2, binY)..lineTo(binX + binW/2, binY)..lineTo(binX + binW/2 - 10, binY + binH)..lineTo(binX - binW/2 + 10, binY + binH)..close();
    canvas.drawPath(binPath, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill);
    canvas.drawPath(binPath, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 4);
    
    _drawText(canvas, t('lcmTitle'), binX, binY + binH - 15, 14, const Color(0xFF64748B), Colors.transparent);

    if (isFinalized || machineMode == 'LCM') {
      double startX = binX - binW/2 + 50;
      double currentX = startX;
      double gearY = binY + 45;
      
      for (var val in extractedLCM) {
        if (currentX > binX + binW/2 - 50) {
          currentX = startX;
          gearY += 40;
        }
        _drawMiniGear(canvas, currentX, gearY, val, const Color(0xFF3B82F6));
        currentX += 45;
      }
    }

    double trayW = 280;
    double trayX = cx - w/2 - trayW/2 - 50;
    
    void drawTrayBox(double tx, double ty, double tw, double th, String label) {
      _drawRoundedRect(canvas, tx - tw/2, ty, tw, th, 4, const Color(0xFF334155), const Color(0xFF1E293B), 2);
      _drawRoundedRect(canvas, tx - tw/2 + 10, ty + 25, tw - 20, th - 35, 2, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawText(canvas, label, tx, ty + 12, 12, const Color(0xFF94A3B8), Colors.transparent);
    }

    double tray1Y = tableY - 150;
    double tray2Y = tableY - 50;
    double tray3Y = tableY + 50;
    
    drawTrayBox(trayX, tray1Y, trayW, 85, t('inventoryTray'));
    drawTrayBox(trayX, tray2Y, trayW, 85, t('gearTray'));

    if (scenario == 3 || scenario == 4) {
      drawTrayBox(trayX, tray3Y, trayW, 85, t('compTray'));
    }

    if (showBuzz > 0) {
      _drawText(canvas, "BUZZ!", slotX + 30, slotY - 40, 28, const Color(0xFFEF4444), const Color(0xFF7F1D1D));
    }
  }

  void _drawMiniGear(Canvas canvas, double x, double y, int val, Color color) {
    canvas.save();
    canvas.translate(x, y);
    
    double r = 18;
    var path = Path();
    for(int i=0; i<8; i++) {
        double a = i * pi/4;
        if(i==0) path.moveTo(cos(a - 0.2)*r*.8, sin(a - 0.2)*r*.8);
        else path.lineTo(cos(a - 0.2)*r*.8, sin(a - 0.2)*r*.8);
        path.lineTo(cos(a - 0.1)*r, sin(a - 0.1)*r);
        path.lineTo(cos(a + 0.1)*r, sin(a + 0.1)*r);
        path.lineTo(cos(a + 0.2)*r*.8, sin(a + 0.2)*r*.8);
    }
    path.close();
    
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    canvas.drawCircle(Offset.zero, r*0.45, Paint()..color = Colors.white);
    canvas.drawCircle(Offset.zero, r*0.45, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    _drawText(canvas, val.toString(), 0, 0, 14, const Color(0xFF0F172A), Colors.transparent);
    canvas.restore();
  }

  void _drawNumberBlock(Canvas canvas, NumberData block) {
    if (block.mounted) return;
    canvas.save();
    canvas.translate(block.x, block.y);
    _drawRoundedRect(canvas, -25, -25, 50, 50, 8, block.color, const Color(0xFF0F172A), 3);
    canvas.drawRRect(RRect.fromRectAndCorners(const Rect.fromLTWH(-22, -22, 44, 22), topLeft: const Radius.circular(4), topRight: const Radius.circular(4)), Paint()..color = Colors.white.withOpacity(0.2));
    _drawText(canvas, block.initVal.toString(), 0, 0, 20, Colors.white, const Color(0xFF0F172A));
    canvas.restore();
  }

  void _drawGear(Canvas canvas, GearData gear) {
    canvas.save();
    canvas.translate(gear.x, gear.y);
    
    if (gear.isGlowing) {
      canvas.drawCircle(Offset.zero, gear.r + 10, Paint()..color = const Color(0xFF6366F1).withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }

    Color gColor = gear.tray == 'comp' ? const Color(0xFFFACC15) : const Color(0xFF3B82F6);
    if(gear.isHovered) gColor = const Color(0xFF818CF8);

    var path = Path();
    for(int i=0; i<8; i++) {
        double a = i * pi/4;
        if(i==0) path.moveTo(cos(a - 0.2)*gear.r*.8, sin(a - 0.2)*gear.r*.8);
        else path.lineTo(cos(a - 0.2)*gear.r*.8, sin(a - 0.2)*gear.r*.8);
        path.lineTo(cos(a - 0.1)*gear.r, sin(a - 0.1)*gear.r);
        path.lineTo(cos(a + 0.1)*gear.r, sin(a + 0.1)*gear.r);
        path.lineTo(cos(a + 0.2)*gear.r*.8, sin(a + 0.2)*gear.r*.8);
    }
    path.close();
    
    canvas.drawPath(path, Paint()..color = gColor..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    canvas.drawCircle(Offset.zero, gear.r*0.4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset.zero, gear.r*0.4, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    _drawText(canvas, gear.val.toString(), 0, 0, 16, const Color(0xFF0F172A), Colors.transparent);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FactorLabPainter oldDelegate) => true;
}

// ----------------------------------------------------------------------------
// Translations
// ----------------------------------------------------------------------------
class Translations {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'shutterTitle': "Streamlined HCF and LCM Calculation",
      'appTitle': "Streamlined HCF and LCM Calculation", 
      'appSubtitle': "Class 7 • FINDING COMMON GROUND", 'enterLab': "Enter Simulation",
      'settings': "Settings", 'boardFontSize': "Text Size", 'themeLbl': "Theme",
      'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'doneBtn': "Done", 'gotItBtn': "Got It!",
      'learnLbl': "Observations:", 'closeBtn': "Close", 'summaryTitle': "Goal Reached!",
      'resetBtnUI': "Reset", 'finishLab': "Finish Lab", 'nextScenario': "Next Scenario",
      'labCompleted': "Lab Completed!", 'finalDesc': "You have successfully mastered the streamlined division method!",
      'checkAnswer': "Finalize", 'revealAnswer': "Calculate LCM", 'continueBtn': "Continue",
      'keepTrying': "That factor doesn't divide all remaining numbers.",
      'notCommonFactor': "This is not a common factor for all numbers.",
      'noMoreCommonFactors': "No more common factors. Proceed to calculate.",
      'hcfTitle': "HCF COLLECTOR", 'lcmTitle': "LCM LEFTOVERS", 'gearTray': "DIVISOR GEARS", 'inventoryTray': "NUMBER BLOCKS", 'compTray': "COMPOSITE GEARS",
      'lcm_res_hcf': "HCF", 'lcm_res_lcm': "LCM", 'extracted': "Extracted: ", 'left': "Left: ",
      's2_step3_tooltip': "2 is a factor of 14 and 8, but not 25. It is not a common factor for all three numbers.",
      
      'res_msg_s1': "This scenario visually demonstrates that the HCF is the product of all common factors extracted (2x2x3). The LCM is the product of the HCF and the remaining non-common factors (12 x 7 x 15).",
      'res_msg_s2': "This scenario clarifies that for HCF, a factor must be common to ALL numbers. For LCM, we continue breaking down until all numbers are 1.",
      'res_msg_s3': "This scenario proves that using larger, easily identifiable common factors is a valid and faster strategy, directly reflecting the textbook's example.",
      'res_msg_s4': "The HCF is 6. So, the longest piece you can cut is 6cm. The LCM is 1980. This is the shortest length you could create by laying out strips of either 90cm or 132cm.",
      'res_msg_s5': "Amazing! The HCF of 240, 378, and 300 is 6. The LCM is 37800.",

      's4_modal_title': "Ribbon Cutting Challenge",
      's4_modal_desc': "You have two ribbons, <span class=\"font-bold text-indigo-500\">90cm</span> and <span class=\"font-bold text-indigo-500\">132cm</span>. What is the longest possible length you can cut both ribbons into, with no waste?",
      's4_modal_btn': "Let's Solve It!",

      's1_title': "1. The Prime Factor Path", 's1_obj': "To find the HCF and LCM of 84 and 180 using the step-by-step common prime factor division method.",
      's1_step1_task': "DRAG the 'Number Block 84' and 'Number Block 180' from the inventory tray and DROP them into the two input funnels at the top of the 'Factor Extractor Machine'.", 's1_step1_out': "Two vertical, transparent columns appear inside the machine, visually representing the numbers 84 and 180.",
      's1_step2_task': "The 'Divisor Gear 2' is glowing. DRAG the 'Divisor Gear 2' and DROP it onto the gear slot on the side of the machine.", 's1_step2_out': "The machine processes the numbers. The 'Divisor Gear 2' is cloned and moves into the 'HCF Collector' area. The number columns for 84 and 180 animate, shrinking down to 42 and 90 respectively.",
      's1_step3_task': "The 'Divisor Gear 2' is glowing again. DRAG it to the gear slot.", 's1_step3_out': "A second 'Divisor Gear 2' moves into the 'HCF Collector'. The columns for 42 and 90 shrink down to 21 and 45.",
      's1_step4_task': "The 'Divisor Gear 3' is now glowing. DRAG it to the gear slot.", 's1_step4_out': "A 'Divisor Gear 3' moves into the 'HCF Collector'. The columns for 21 and 45 shrink down to 7 and 15. The gear slot now glows red, indicating no more common factors can be extracted.",
      's1_step5_task': "CLICK the 'Finalize' button on the machine's console.", 's1_step5_out': "The remaining numbers, 7 and 15, drop down from their columns into the 'LCM Leftovers' bin. The final HCF and LCM are calculated and displayed.",
      's1_hud1': "Drag Number Block 84 and 180 to the funnels.", 's1_hud2': "Drag glowing Divisor Gear 2 to the slot.", 's1_hud3': "Drag Divisor Gear 2 to the slot again.", 's1_hud4': "Drag Divisor Gear 3 to the slot.", 's1_hud5': "Click the Finalize button below.",

      's2_title': "2. Three's a Crowd", 's2_obj': "To find the HCF and LCM of three numbers (42, 75, 24) and understand that a factor must be common to all numbers to be part of the HCF.",
      's2_step1_task': "DRAG the 'Number Blocks' for 42, 75, and 24 into the three input funnels of the machine.", 's2_step1_out': "Three columns representing 42, 75, and 24 appear in the machine. The 'Divisor Gears' tray activates.",
      's2_step2_task': "The 'Divisor Gear 3' is glowing. DRAG it to the gear slot.", 's2_step2_out': "The gear is accepted. A '3' moves to the 'HCF Collector'. The number columns shrink to 14, 25, and 8.",
      's2_step3_task': "Observe the 'Divisor Gears' tray. CLICK on the 'Divisor Gear 2'.", 's2_step3_out': "The gear is rejected by the machine. The gear slot flashes red and a buzz sound is heard. The gear returns to the tray.",
      's2_step4_task': "CLICK the 'Calculate LCM' button. The machine will now process factors common to any two numbers, and then the remaining ones.", 's2_step4_out': "The machine automatically continues the division process for the LCM calculation, showing the full breakdown. These factors go into the 'LCM Leftovers' bin.",
      's2_hud1': "Drag Number Blocks 42, 75, and 24 to the funnels.", 's2_hud2': "Drag glowing Divisor Gear 3 to the slot.", 's2_hud3': "Click on Divisor Gear 2.", 's2_hud4': "Click the Calculate LCM button.",

      's3_title': "3. Guna's Faster Way", 's3_obj': "To find the HCF and LCM of 300 and 150 by extracting a larger, composite common factor, demonstrating a more efficient path.",
      's3_step1_task': "DRAG 'Number Block 300' and 'Number Block 150' into the machine's funnels.", 's3_step1_out': "Columns for 300 and 150 appear. A new tray of 'Composite Divisor Gears' (10, 25, 50, etc.) appears alongside the prime gears.",
      's3_step2_task': "DRAG the glowing 'Composite Divisor Gear 50' to the gear slot.", 's3_step2_out': "The machine accepts the gear. A '50' gear moves to the 'HCF Collector'. The columns for 300 and 150 shrink dramatically to 6 and 3.",
      's3_step3_task': "The 'Divisor Gear 3' is now glowing. DRAG it to the gear slot.", 's3_step3_out': "A '3' gear moves to the 'HCF Collector'. The columns shrink to 2 and 1. The gear slot turns red.",
      's3_step4_task': "CLICK the 'Finalize' button.", 's3_step4_out': "The remaining numbers, 2 and 1, drop into the 'LCM Leftovers' bin. The final HCF and LCM are displayed.",
      's3_hud1': "Drag Number Blocks 300 and 150 to the funnels.", 's3_hud2': "Drag glowing Composite Divisor Gear 50 to the slot.", 's3_hud3': "Drag Divisor Gear 3 to the slot.", 's3_hud4': "Click the Finalize button.",

      's4_title': "4. Ribbon Cutting Challenge", 's4_obj': "Given two numbers, 90 and 132, find the HCF and LCM by selecting the correct common factors from an assortment of gears.",
      's4_step1_task': "DRAG the 'Number Blocks' 90 and 132 into the machine.", 's4_step1_out': "The columns for 90 and 132 appear. The full tray of prime and composite 'Divisor Gears' is available, but none are glowing.",
      's4_step2_task': "Find a common factor for 90 and 132. DRAG the corresponding 'Divisor Gear' to the gear slot.", 's4_step2_out': "The user correctly identifies a common factor and drags it. The machine processes it, updates the columns, and moves the factor to the HCF collector. Repeat until the remaining numbers are co-prime.",
      's4_step3_task': "Once no more common factors can be found, CLICK the 'Finalize' button.", 's4_step3_out': "The machine calculates and displays the final HCF and LCM based on the user's extracted factors and the leftovers.",
      's4_hud1': "Drag Number Blocks 90 and 132 to the funnels.", 's4_hud2': "Find and drag a common factor gear to the slot.", 's4_hud3': "Click Finalize when remaining numbers are co-prime.",

      's5_title': "5. The Triple Gear Challenge", 's5_obj': "Find the HCF and LCM for a challenging set of three numbers: 240, 378, and 300.",
      's5_step1_task': "DRAG the 'Number Blocks' for 240, 378, and 300 into the machine.", 's5_step1_out': "Three columns appear, representing the numbers. The full tray of 'Divisor Gears' is available.",
      's5_step2_task': "Systematically extract all common factors from the three numbers by dragging the correct 'Divisor Gears' to the slot. Remember, the factor must divide all three numbers to be part of the HCF.", 's5_step2_out': "The user must identify and extract the common factors (e.g., 2, then 3). The machine will update the columns with each correct step (e.g., after 2 -> 120, 189, 150; after 3 -> 40, 63, 50).",
      's5_step3_task': "CLICK the 'Calculate LCM' button to have the machine complete the process, then CLICK 'Finalize'.", 's5_step3_out': "The machine calculates the final HCF from the user's input and then automatically completes the LCM calculation, displaying both results.",
      's5_hud1': "Drag Number Blocks 240, 378, and 300 to the funnels.", 's5_hud2': "Systematically extract common factors.", 's5_hud3': "Click Calculate LCM, then Finalize."
    },
    'hi': {
      'shutterTitle': "सुव्यवस्थित HCF और LCM गणना",
      'appTitle': "सुव्यवस्थित HCF और LCM गणना", 
      'appSubtitle': "कक्षा 7 • सामान्य आधार खोजना", 'enterLab': "सिमुलेशन दर्ज करें",
      'settings': "सेटिंग्स", 'boardFontSize': "टेक्स्ट आकार", 'themeLbl': "थीम",
      'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'doneBtn': "पूर्ण", 'gotItBtn': "समझ गया!",
      'learnLbl': "अवलोकन:", 'closeBtn': "बंद करें", 'summaryTitle': "लक्ष्य प्राप्त हुआ!",
      'resetBtnUI': "रीसेट", 'finishLab': "समाप्त करें", 'nextScenario': "अगला परिदृश्य",
      'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने सुव्यवस्थित विभाजन विधि में सफलतापूर्वक महारत हासिल कर ली है!",
      'checkAnswer': "अंतिम रूप दें", 'revealAnswer': "LCM की गणना करें", 'continueBtn': "जारी रखें",
      'keepTrying': "यह कारक सभी शेष संख्याओं को विभाजित नहीं करता है।",
      'notCommonFactor': "यह सभी संख्याओं के लिए एक सामान्य कारक नहीं है।",
      'noMoreCommonFactors': "कोई और सामान्य कारक नहीं। गणना करने के लिए आगे बढ़ें।",
      'hcfTitle': "HCF कलेक्टर", 'lcmTitle': "LCM बचे हुए", 'gearTray': "विभाजक गियर्स", 'inventoryTray': "नंबर ब्लॉक्स", 'compTray': "समग्र गियर्स",
      'lcm_res_hcf': "HCF", 'lcm_res_lcm': "LCM", 'extracted': "निकाला गया: ", 'left': "बचा हुआ: ",
      's2_step3_tooltip': "2, 14 और 8 का एक कारक है, लेकिन 25 का नहीं। यह सभी तीनों संख्याओं के लिए एक सामान्य कारक नहीं है।",

      'res_msg_s1': "यह परिदृश्य दृष्टिगत रूप से प्रदर्शित करता है कि HCF निकाले गए सभी सामान्य कारकों (2x2x3) का गुणनफल है। LCM, HCF और शेष गैर-सामान्य कारकों (12 x 7 x 15) का गुणनफल है।",
      'res_msg_s2': "यह परिदृश्य स्पष्ट करता है कि HCF के लिए, एक कारक को सभी संख्याओं में सामान्य होना चाहिए। LCM के लिए, हम तब तक तोड़ना जारी रखते हैं जब तक कि सभी संख्याएं 1 न हो जाएं।",
      'res_msg_s3': "यह परिदृश्य साबित करता है कि बड़े, आसानी से पहचाने जाने वाले सामान्य कारकों का उपयोग करना एक वैध और तेज रणनीति है, जो सीधे पाठ्यपुस्तक के उदाहरण को दर्शाता है।",
      'res_msg_s4': "HCF 6 है। इसलिए, आप जो सबसे लंबा टुकड़ा काट सकते हैं वह 6cm है। LCM 1980 है। यह वह सबसे छोटी लंबाई है जिसे आप 90cm या 132cm की स्ट्रिप्स बिछाकर बना सकते हैं।",
      'res_msg_s5': "अद्भुत! 240, 378 और 300 का HCF 6 है। LCM 37800 है।",

      's4_modal_title': "रिबन काटने की चुनौती",
      's4_modal_desc': "आपके पास दो रिबन हैं, <span class=\"font-bold text-indigo-500\">90cm</span> और <span class=\"font-bold text-indigo-500\">132cm</span>। बिना बर्बादी के दोनों रिबन को आप कितनी अधिकतम समान लंबाई में काट सकते हैं?",
      's4_modal_btn': "आइए इसे हल करें!",

      's1_title': "1. अभाज्य गुणनखंड पथ", 's1_obj': "चरण-दर-चरण सामान्य अभाज्य गुणनखंड विभाजन विधि का उपयोग करके 84 और 180 का HCF और LCM ज्ञात करना।",
      's1_step1_task': "इन्वेंट्री ट्रे से 'नंबर ब्लॉक 84' और 'नंबर ब्लॉक 180' को खींचें और उन्हें 'फैक्टर एक्सट्रैक्टर मशीन' के शीर्ष पर दो इनपुट फ़नल में छोड़ें।", 's1_step1_out': "मशीन के अंदर दो पारदर्शी कॉलम दिखाई देते हैं, जो 84 और 180 संख्याओं का दृश्य प्रतिनिधित्व करते हैं।",
      's1_step2_task': "'डिविजर गियर 2' चमक रहा है। 'डिविजर गियर 2' को खींचें और इसे मशीन के किनारे गियर स्लॉट पर छोड़ दें।", 's1_step2_out': "मशीन संख्याओं को संसाधित करती है। 'डिविजर गियर 2' की नकल बनाई जाती है और 'HCF कलेक्टर' क्षेत्र में ले जाया जाता है। 84 और 180 के लिए नंबर कॉलम 42 और 90 तक सिकुड़ जाते हैं।",
      's1_step3_task': "'डिविजर गियर 2' फिर से चमक रहा है। इसे गियर स्लॉट में खींचें।", 's1_step3_out': "एक दूसरा 'डिविजर गियर 2' 'HCF कलेक्टर' में चला जाता है। 42 और 90 के कॉलम 21 और 45 तक सिकुड़ जाते हैं।",
      's1_step4_task': "'डिविजर गियर 3' अब चमक रहा है। इसे गियर स्लॉट में खींचें।", 's1_step4_out': "एक 'डिविजर गियर 3' 'HCF कलेक्टर' में जाता है। 21 और 45 के कॉलम 7 और 15 तक सिकुड़ जाते हैं। गियर स्लॉट अब लाल चमकता है।",
      's1_step5_task': "मशीन के कंसोल पर 'अंतिम रूप दें' बटन पर क्लिक करें।", 's1_step5_out': "शेष संख्याएं, 7 और 15, अपने कॉलम से नीचे 'LCM बचे हुए' बिन में गिर जाती हैं। अंतिम HCF और LCM की गणना और प्रदर्शित किया जाता है।",
      's1_hud1': "नंबर ब्लॉक 84 और 180 को फ़नल में खींचें।", 's1_hud2': "चमकते डिविजर गियर 2 को स्लॉट में खींचें।", 's1_hud3': "डिविजर गियर 2 को फिर से स्लॉट में खींचें।", 's1_hud4': "डिविजर गियर 3 को स्लॉट में खींचें।", 's1_hud5': "नीचे 'अंतिम रूप दें' बटन पर क्लिक करें।",

      's2_title': "2. तीन की भीड़", 's2_obj': "तीन संख्याओं (42, 75, 24) का HCF और LCM ज्ञात करना और यह समझना कि HCF का हिस्सा बनने के लिए एक कारक सभी संख्याओं में सामान्य होना चाहिए।",
      's2_step1_task': "मशीन के तीन इनपुट फ़नल में 42, 75 और 24 के लिए 'नंबर ब्लॉक्स' को खींचें।", 's2_step1_out': "मशीन में 42, 75 और 24 का प्रतिनिधित्व करने वाले तीन कॉलम दिखाई देते हैं। 'डिविजर गियर्स' ट्रे सक्रिय हो जाती है।",
      's2_step2_task': "चमकते 'डिविजर गियर 3' को गियर स्लॉट में खींचें।", 's2_step2_out': "गियर स्वीकार कर लिया गया है। एक '3' 'HCF कलेक्टर' में जाता है। नंबर कॉलम 14, 25, और 8 तक सिकुड़ जाते हैं।",
      's2_step3_task': "'डिविजर गियर्स' ट्रे का निरीक्षण करें। 'डिविजर गियर 2' पर क्लिक करें।", 's2_step3_out': "मशीन द्वारा गियर को अस्वीकार कर दिया गया है। गियर स्लॉट लाल रंग में चमकता है और एक भनभनाहट की आवाज सुनाई देती है।",
      's2_step4_task': "'LCM की गणना करें' बटन पर क्लिक करें।", 's2_step4_out': "मशीन LCM गणना के लिए विभाजन प्रक्रिया को स्वचालित रूप से जारी रखती है।",
      's2_hud1': "नंबर ब्लॉक्स 42, 75, और 24 को फ़नल में खींचें।", 's2_hud2': "चमकते डिविजर गियर 3 को स्लॉट में खींचें।", 's2_hud3': "डिविजर गियर 2 पर क्लिक करें।", 's2_hud4': "'LCM की गणना करें' बटन पर क्लिक करें।",

      's3_title': "3. गुना का तेज़ तरीका", 's3_obj': "एक बड़े, समग्र (composite) सामान्य कारक को निकालकर 300 और 150 के HCF और LCM को खोजना, जो एक अधिक कुशल मार्ग को दर्शाता है।",
      's3_step1_task': "मशीन के फ़नल में 'नंबर ब्लॉक 300' और 'नंबर ब्लॉक 150' खींचें।", 's3_step1_out': "300 और 150 के लिए कॉलम दिखाई देते हैं। समग्र गियर्स की एक नई ट्रे दिखाई देती है।",
      's3_step2_task': "चमकते 'समग्र डिविजर गियर 50' को गियर स्लॉट में खींचें।", 's3_step2_out': "मशीन गियर स्वीकार करती है। एक '50' गियर 'HCF कलेक्टर' में जाता है।",
      's3_step3_task': "'डिविजर गियर 3' अब चमक रहा है। इसे गियर स्लॉट में खींचें।", 's3_step3_out': "एक '3' गियर 'HCF कलेक्टर' में जाता है। गियर स्लॉट लाल हो जाता है।",
      's3_step4_task': "'अंतिम रूप दें' बटन पर क्लिक करें।", 's3_step4_out': "शेष संख्याएं, 2 और 1, 'LCM बचे हुए' बिन में गिर जाती हैं। अंतिम HCF और LCM प्रदर्शित होते हैं।",
      's3_hud1': "नंबर ब्लॉक्स 300 और 150 को फ़नल में खींचें।", 's3_hud2': "चमकते समग्र डिविजर गियर 50 को स्लॉट में खींचें।", 's3_hud3': "डिविजर गियर 3 को स्लॉट में खींचें।", 's3_hud4': "'अंतिम रूप दें' बटन पर क्लिक करें।",

      's4_title': "4. रिबन काटने की चुनौती (अनसुलझी)", 's4_obj': "दिए गए दो संख्याओं, 90 और 132 के लिए, गियर्स के वर्गीकरण से सही सामान्य कारकों का चयन करके HCF और LCM खोजें।",
      's4_step1_task': "'नंबर ब्लॉक्स' 90 और 132 को मशीन में खींचें।", 's4_step1_out': "90 और 132 के लिए कॉलम दिखाई देते हैं।",
      's4_step2_task': "90 और 132 के लिए एक सामान्य कारक खोजें। संबंधित 'डिविजर गियर' को गियर स्लॉट में खींचें।", 's4_step2_out': "मशीन इसे संसाधित करती है, कॉलम अपडेट करती है, और कारक को HCF कलेक्टर में ले जाती है।",
      's4_step3_task': "जब कोई और सामान्य कारक नहीं मिल सकता है, तो 'अंतिम रूप दें' बटन पर क्लिक करें।", 's4_step3_out': "मशीन अंतिम HCF और LCM की गणना और प्रदर्शन करती है।",
      's4_hud1': "नंबर ब्लॉक्स 90 और 132 को फ़नल में खींचें।", 's4_hud2': "एक सामान्य कारक गियर खोजें और उसे स्लॉट में खींचें।", 's4_hud3': "शेष संख्याएं सह-अभाज्य होने पर 'अंतिम रूप दें' पर क्लिक करें।",

      's5_title': "5. ट्रिपल गियर चुनौती (अनसुलझी)", 's5_obj': "तीन संख्याओं के चुनौतीपूर्ण सेट के लिए HCF और LCM खोजें: 240, 378, और 300।",
      's5_step1_task': "240, 378, और 300 के लिए 'नंबर ब्लॉक्स' को मशीन में खींचें।", 's5_step1_out': "तीन कॉलम दिखाई देते हैं।",
      's5_step2_task': "स्लॉट में सही 'डिविजर गियर्स' को खींचकर तीनों संख्याओं से सभी सामान्य कारकों को व्यवस्थित रूप से निकालें।", 's5_step2_out': "मशीन प्रत्येक सही कदम के साथ कॉलम को अपडेट करेगी।",
      's5_step3_task': "मशीन को प्रक्रिया पूरी करने देने के लिए 'LCM की गणना करें' बटन पर क्लिक करें, फिर 'अंतिम रूप दें' पर क्लिक करें।", 's5_step3_out': "मशीन दोनों परिणाम प्रदर्शित करती है।",
      's5_hud1': "नंबर ब्लॉक्स 240, 378, और 300 को फ़नल में खींचें।", 's5_hud2': "व्यवस्थित रूप से सामान्य कारकों को निकालें।", 's5_hud3': "'LCM की गणना करें' पर क्लिक करें, फिर 'अंतिम रूप दें'।"
    }
  };
}