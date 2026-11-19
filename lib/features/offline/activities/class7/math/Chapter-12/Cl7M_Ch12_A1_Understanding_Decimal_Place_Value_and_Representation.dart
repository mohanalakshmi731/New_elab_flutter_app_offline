// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UnderstandingDecimalPlaceValueandRepresentationApp());
}

class UnderstandingDecimalPlaceValueandRepresentationApp extends StatelessWidget {
  const UnderstandingDecimalPlaceValueandRepresentationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | The Decimal Architect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const UnderstandingDecimalPlaceValueandRepresentation(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class DecBlock {
  String id;
  String type; // 'ones', 'tenths', 'hundredths', 'slicer'
  double x, y, targetX, targetY;
  bool isDragging;

  DecBlock(this.id, this.type, this.x, this.y)
      : targetX = x,
        targetY = y,
        isDragging = false;
}

// ==========================================
// MAIN WIDGET
// ==========================================
class UnderstandingDecimalPlaceValueandRepresentation extends StatefulWidget {
  const UnderstandingDecimalPlaceValueandRepresentation({super.key});

  @override
  State<UnderstandingDecimalPlaceValueandRepresentation> createState() =>
      _UnderstandingDecimalPlaceValueandRepresentationState();
}

class _UnderstandingDecimalPlaceValueandRepresentationState
    extends State<UnderstandingDecimalPlaceValueandRepresentation>
    with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  String _theme = 'dark';

  // Lab State
  int _scenario = 1;
  int _step = 0;
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
  DecBlock? _activeDragItem;
  Offset _dragOffset = Offset.zero;
  bool _isDraggingCanvas = false;
  Offset? _calcPos;

  // Simulation State
  List<DecBlock> _onesBlocks = [];
  List<DecBlock> _tenthsBlocks = [];
  List<DecBlock> _hundBlocks = [];
  List<DecBlock> _floatingBlocks = []; // Temporary blocks (e.g., S2 slicer outputs)
  
  bool _slicerActive = false;
  Offset _slicerPos = Offset.zero;
  
  String _keypadInput = '';
  
  bool _isRegrouping = false;
  int _regroupPhase = 0; // 0: None, 1: Gather, 2: Morph and Move
  
  List<bool>? _incorrectColumns; // Track highlighted error columns in S4

  // Audio players
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';
  static const String _morphUrl = 'audio/class7/mixkit_2573.mp3';

  late AnimationController _ticker;

  final double MAT_X = -200;
  final double MAT_Y = -150;
  final double MAT_W = 600;
  final double MAT_H = 380;
  final double PAL_X = -380;
  final double PAL_Y = -100;
  final double BASE_BLOCK_SIZE = 120;
  final double TENTHS_W = 12;
  final double TENTHS_H = 120;
  final double HUND_SIZE = 12;

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

    // Main Game Loop (Physics and Smoothing)
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
      } else if (type == 'success') {
        await _successPlayer.play(AssetSource(_successUrl), volume: 0.5);
      } else if (type == 'error') {
        await _errorPlayer.play(AssetSource(_errorUrl), volume: 0.5);
      } else if (type == 'morph') {
        await _fxPlayer.play(AssetSource(_morphUrl), volume: 0.4);
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
    setState(() => _showCurtain = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _lang = 'en';
          _theme = 'dark';
          _completedScenarios.clear();
          _loadScenario(1);
        });
      }
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _activeDragItem = null;
      
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
      _baseZoom = 1.0;
      _basePan = Offset.zero;
      _showSuccessPopup = false;
      _incorrectColumns = null;
      _calcPos = null;

      _onesBlocks.clear();
      _tenthsBlocks.clear();
      _hundBlocks.clear();
      _floatingBlocks.clear();

      _slicerActive = false;
      _keypadInput = '';
      _isRegrouping = false;
      _regroupPhase = 0;

      if (_scenario == 2) {
        _onesBlocks.add(DecBlock('o1', 'ones', MAT_X + (MAT_W/3)/2 - BASE_BLOCK_SIZE/2, MAT_Y + 120));
      } else if (_scenario == 3) {
        _tenthsBlocks.add(DecBlock('t1', 'tenths', MAT_X + MAT_W/3 + 60, MAT_Y + 120));
        for (int i = 0; i < 5; i++) {
          _hundBlocks.add(DecBlock('h$i', 'hundredths', MAT_X + (MAT_W/3)*2 + 60 + (i % 5) * 20, MAT_Y + 280));
        }
      } else if (_scenario == 5) {
        for (int i = 0; i < 3; i++) {
          _tenthsBlocks.add(DecBlock('t$i', 'tenths', MAT_X + MAT_W/3 + 60 + i * 20, MAT_Y + 120));
        }
        for (int i = 0; i < 7; i++) {
          _hundBlocks.add(DecBlock('h$i', 'hundredths', MAT_X + (MAT_W/3)*2 + 60 + (i % 5) * 20, MAT_Y + 280 + (i ~/ 5) * 20));
        }
      }
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    setState(() {
      double colW = MAT_W / 3;

      // Update Target Positions for Ones
      for (int i = 0; i < _onesBlocks.length; i++) {
        var b = _onesBlocks[i];
        if (!b.isDragging) {
          b.targetX = MAT_X + colW / 2 - BASE_BLOCK_SIZE / 2 + (i * 10);
          b.targetY = MAT_Y + 120 + (i * 10);
          b.x += (b.targetX - b.x) * 0.2;
          b.y += (b.targetY - b.y) * 0.2;
        }
      }

      // Update Target Positions for Tenths
      for (int i = 0; i < _tenthsBlocks.length; i++) {
        var b = _tenthsBlocks[i];
        if (!b.isDragging) {
          if (_scenario == 3 && _isRegrouping && _regroupPhase == 2 && b.id == 'newTenth') {
            b.targetX = MAT_X + colW + 60 + 20; // Special landing spot for regrouped tenth
            b.targetY = MAT_Y + 120;
          } else {
            double totalW = _tenthsBlocks.length * 16;
            b.targetX = MAT_X + colW + colW / 2 - totalW / 2 + i * 16;
            b.targetY = MAT_Y + 120;
          }
          b.x += (b.targetX - b.x) * 0.2;
          b.y += (b.targetY - b.y) * 0.2;
        }
      }

      // Update Target Positions for Hundredths
      for (int i = 0; i < _hundBlocks.length; i++) {
        var b = _hundBlocks[i];
        if (!b.isDragging) {
          if (_scenario == 3 && _isRegrouping && _regroupPhase == 1) {
            b.targetX = MAT_X + colW * 2 + colW / 2 - HUND_SIZE / 2;
            b.targetY = MAT_Y + 120 + i * 12;
            b.x += (b.targetX - b.x) * 0.15;
            b.y += (b.targetY - b.y) * 0.15;
          } else {
            b.targetX = MAT_X + 2 * colW + 40 + (i % 5) * 16;
            b.targetY = MAT_Y + 280 + (i ~/ 5) * 16;
            b.x += (b.targetX - b.x) * 0.2;
            b.y += (b.targetY - b.y) * 0.2;
          }
        }
      }

      // Floating Blocks (Slicer output)
      for (var b in _floatingBlocks) {
        if (!b.isDragging) {
          b.x += (b.targetX - b.x) * 0.1;
          b.y += (b.targetY - b.y) * 0.1;
        }
      }

      // Slicer Animation
      if (_slicerActive && _onesBlocks.isNotEmpty) {
        var targetOne = _onesBlocks.first;
        _slicerPos += Offset(
          (targetOne.x + BASE_BLOCK_SIZE / 2 - _slicerPos.dx) * 0.1,
          (targetOne.y + BASE_BLOCK_SIZE / 2 - _slicerPos.dy) * 0.1,
        );

        if ((_slicerPos.dx - (targetOne.x + BASE_BLOCK_SIZE / 2)).abs() < 5 &&
            (_slicerPos.dy - (targetOne.y + BASE_BLOCK_SIZE / 2)).abs() < 5) {
          _playSound('morph');
          _onesBlocks.removeAt(0);
          _slicerActive = false;

          for (int i = 0; i < 10; i++) {
            _floatingBlocks.add(DecBlock('f$i', 'tenths', targetOne.x + i * 12, targetOne.y)
              ..targetX = -100 + i * 20
              ..targetY = MAT_Y + MAT_H + 50);
          }
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) _advanceStep();
          });
        }
      }

      // Regroup Trigger Logic
      if (_scenario == 3 && _step == 0 && !_isRegrouping && _hundBlocks.length >= 10) {
        _isRegrouping = true;
        _regroupPhase = 1;
        _playSound('morph');

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _regroupPhase = 2;
              _hundBlocks.clear();
              _tenthsBlocks.add(DecBlock('newTenth', 'tenths', MAT_X + colW * 2 + colW / 2 - HUND_SIZE / 2, MAT_Y + 120));
            });

            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() {
                  _isRegrouping = false;
                  _regroupPhase = 0;
                  for (var t in _tenthsBlocks) { t.id = 't_regrouped'; } // clear special id
                  _advanceStep();
                });
              }
            });
          }
        });
      }
    });
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
    _evaluateScenarioCompletion();
  }

  void _checkScenarioSuccess() {
    setState(() {
      int totalSteps = _getScenarioStepsCount();
      _step = totalSteps; // Force advance to maximum steps to trigger completion banner
      _completedScenarios.add(_scenario);
    });
    
    _playSound('success');
    _scrollToActiveStep();

    if (_completedScenarios.length == 5) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _showSuccessPopup = true);
      });
    }
  }

  int _getScenarioStepsCount() {
    switch (_scenario) {
      case 1: return 3;
      case 2: return 2;
      case 3: return 2;
      case 4: return 2;
      case 5: return 2;
      default: return 0;
    }
  }

  void _evaluateScenarioCompletion() {
    int totalSteps = _getScenarioStepsCount();
    if (_step >= totalSteps && !_completedScenarios.contains(_scenario)) {
      _checkScenarioSuccess();
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

  bool _hitTestRect(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    bool touchedBlock = false;

    if (!_completedScenarios.contains(_scenario) && !_isRegrouping) {
      int s = _scenario;
      int step = _step;

      // Pick up Slicer from Palette (S2)
      if (s == 2 && step == 0 && !_slicerActive && _hitTestRect(PAL_X, PAL_Y + 200, 100, 60, pt)) {
        setState(() {
          _activeDragItem = DecBlock('slicer_drag', 'slicer', pt.dx, pt.dy)..isDragging = true;
        });
        _playSound('tick');
        touchedBlock = true;
      }

      // Pick up from Mat (S4 only)
      if (!touchedBlock && s == 4 && step == 0) {
        void checkList(List<DecBlock> list, String type) {
          if (touchedBlock) return;
          for (int i = list.length - 1; i >= 0; i--) {
            var b = list[i];
            double w = type == 'ones' ? BASE_BLOCK_SIZE : type == 'tenths' ? TENTHS_W : HUND_SIZE;
            double h = type == 'ones' ? BASE_BLOCK_SIZE : type == 'tenths' ? TENTHS_H : HUND_SIZE;
            if (_hitTestRect(b.x - 10, b.y - 10, w + 20, h + 20, pt)) {
              setState(() {
                _activeDragItem = DecBlock('drag_$type', type, pt.dx - w / 2, pt.dy - h / 2)..isDragging = true;
                list.removeAt(i);
              });
              _playSound('tick');
              touchedBlock = true;
              break;
            }
          }
        }
        checkList(_hundBlocks, 'hundredths');
        checkList(_tenthsBlocks, 'tenths');
        checkList(_onesBlocks, 'ones');
      }

      // Pick up from Palette (S1, S2, S3, S4)
      if (!touchedBlock && s != 5) {
        if (_hitTestRect(PAL_X - 20, PAL_Y + 20, 140, 115, pt)) {
          setState(() => _activeDragItem = DecBlock('drag_o', 'ones', pt.dx - BASE_BLOCK_SIZE / 2, pt.dy - BASE_BLOCK_SIZE / 2)..isDragging = true);
          _playSound('tick'); touchedBlock = true;
        } else if (_hitTestRect(PAL_X - 20, PAL_Y + 135, 140, 100, pt)) {
          setState(() => _activeDragItem = DecBlock('drag_t', 'tenths', pt.dx - TENTHS_W / 2, pt.dy - TENTHS_H / 2)..isDragging = true);
          _playSound('tick'); touchedBlock = true;
        } else if (_hitTestRect(PAL_X - 20, PAL_Y + 240, 140, 85, pt)) {
          setState(() => _activeDragItem = DecBlock('drag_h', 'hundredths', pt.dx - HUND_SIZE / 2, pt.dy - HUND_SIZE / 2)..isDragging = true);
          _playSound('tick'); touchedBlock = true;
        }
      }

      // Pick up floating Tenths (S2 Step 1)
      if (!touchedBlock && s == 2 && step == 1) {
        for (int i = 0; i < _floatingBlocks.length; i++) {
          var b = _floatingBlocks[i];
          if (_hitTestRect(b.x - 10, b.y - 10, TENTHS_W + 20, TENTHS_H + 20, pt)) {
            setState(() {
              _activeDragItem = DecBlock('drag_t', 'tenths', pt.dx - TENTHS_W / 2, pt.dy - TENTHS_H / 2)..isDragging = true;
              _floatingBlocks.removeAt(i);
            });
            _playSound('tick'); touchedBlock = true;
            break;
          }
        }
      }
    }

    // If no block was touched, initiate canvas drag
    if (!touchedBlock) {
      _isDraggingCanvas = true;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      _mouseX = pt.dx;
      _mouseY = pt.dy;

      if (_activeDragItem != null) {
        if (_activeDragItem!.type == 'slicer') {
          _activeDragItem!.x = pt.dx;
          _activeDragItem!.y = pt.dy;
        } else {
          double w = _activeDragItem!.type == 'ones' ? BASE_BLOCK_SIZE : _activeDragItem!.type == 'tenths' ? TENTHS_W : HUND_SIZE;
          double h = _activeDragItem!.type == 'ones' ? BASE_BLOCK_SIZE : _activeDragItem!.type == 'tenths' ? TENTHS_H : HUND_SIZE;
          _activeDragItem!.x = pt.dx - w / 2;
          _activeDragItem!.y = pt.dy - h / 2;
        }
      } else if (_isDraggingCanvas) {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.3, 1.5);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    _isDraggingCanvas = false;

    if (_activeDragItem != null) {
      Offset pt = Offset(_mouseX, _mouseY);
      setState(() {
        var item = _activeDragItem!;
        int s = _scenario;
        int step = _step;
        bool snapped = false;

        if (item.type == 'slicer') {
          if (_hitTestRect(MAT_X, MAT_Y, MAT_W / 3, MAT_H, pt)) {
            _slicerActive = true;
            _slicerPos = Offset(item.x, item.y);
            snapped = true;
            _playSound('snap');
          } else {
            _playSound('pop');
          }
        } else {
          double w = item.type == 'ones' ? BASE_BLOCK_SIZE : item.type == 'tenths' ? TENTHS_W : HUND_SIZE;
          double h = item.type == 'ones' ? BASE_BLOCK_SIZE : item.type == 'tenths' ? TENTHS_H : HUND_SIZE;
          double cx = item.x + w / 2;
          double cy = item.y + h / 2;

          int dropCol = -1;
          if (cx >= MAT_X && cx < MAT_X + MAT_W / 3) dropCol = 0;
          else if (cx >= MAT_X + MAT_W / 3 && cx < MAT_X + 2 * MAT_W / 3) dropCol = 1;
          else if (cx >= MAT_X + 2 * MAT_W / 3 && cx <= MAT_X + MAT_W) dropCol = 2;

          int expectedCol = item.type == 'ones' ? 0 : item.type == 'tenths' ? 1 : 2;

          if (cy >= MAT_Y && cy <= MAT_Y + MAT_H && dropCol != -1) {
            bool isValid = false;
            
            if (s == 1) {
              if (step == 0) {
                if (item.type == 'ones' && _onesBlocks.isEmpty) isValid = true;
              } else if (step == 1) {
                if (item.type == 'tenths' && _tenthsBlocks.length < 2) isValid = true;
              } else if (step == 2) {
                if (item.type == 'hundredths' && _hundBlocks.length < 3) isValid = true;
              }
            } else if (s == 2) {
              if (step == 1) {
                if (item.type == 'tenths' && _tenthsBlocks.length < 4) isValid = true;
              }
            } else if (s == 3) {
              if (step == 0) {
                if (item.type == 'hundredths' && _hundBlocks.length < 10 && !_isRegrouping) isValid = true;
              } else if (step == 1) {
                if (item.type == 'hundredths' && _hundBlocks.length < 3) isValid = true;
              }
            } else if (s == 4) {
              isValid = true;
            }

            if (isValid) {
              if (dropCol == expectedCol) {
                if (item.type == 'ones') _onesBlocks.add(item);
                else if (item.type == 'tenths') _tenthsBlocks.add(item);
                else if (item.type == 'hundredths') _hundBlocks.add(item);
                
                snapped = true;
                _playSound('snap');

                // Step Progression checks
                if (s == 1 && step == 0 && _onesBlocks.length == 1) _advanceStep();
                if (s == 1 && step == 1 && _tenthsBlocks.length == 2) _advanceStep();
                if (s == 1 && step == 2 && _hundBlocks.length == 3) _checkScenarioSuccess();
                if (s == 2 && step == 1 && _tenthsBlocks.length == 4) _checkScenarioSuccess();
                if (s == 3 && step == 1 && _hundBlocks.length == 3) _checkScenarioSuccess();

              } else {
                _playSound('error');
              }
            } else {
              _playSound('error');
            }
          } else {
            _playSound('pop');
          }
        }

        // Return floating block to pool if not snapped
        if (!snapped && s == 2 && step == 1 && item.type == 'tenths') {
          _floatingBlocks.add(DecBlock('f_ret', 'tenths', item.x, item.y)
            ..targetX = -100 + _floatingBlocks.length * 20
            ..targetY = MAT_Y + MAT_H + 50);
        }

        _activeDragItem = null;
      });
    }
  }

  void _keypadInputAdd(String val) {
    _playSound('tick');
    if (_keypadInput.length < 5) {
      setState(() => _keypadInput += val);
    }
  }

  void _keypadDelete() {
    _playSound('tick');
    if (_keypadInput.isNotEmpty) {
      setState(() => _keypadInput = _keypadInput.substring(0, _keypadInput.length - 1));
    }
  }

  void _checkScenario5() {
    if (_keypadInput == '0.37') {
      _playSound('success');
      _checkScenarioSuccess();
    } else {
      _playSound('error');
    }
  }

  void _checkScenario4() {
    setState(() {
      int o = _onesBlocks.length;
      int t = _tenthsBlocks.length;
      int h = _hundBlocks.length;
      
      _incorrectColumns = [o != 2, t != 0, h != 5];
      
      if (o == 2 && t == 0 && h == 5) {
        _incorrectColumns = null;
        _advanceStep();
        _checkScenarioSuccess();
      } else {
        _playSound('error');
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) setState(() => _incorrectColumns = null);
        });
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
    return RichText(text: TextSpan(style: const TextStyle(fontSize: 13, fontFamily: 'Plus Jakarta Sans', height: 1.4), children: spans));
  }

  Widget _buildSidebar(double width) {
    bool isLight = _theme == 'light';
    Color bg = isLight ? const Color(0xFFF8FAFC).withOpacity(0.95) : const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = isLight ? const Color(0xFF0F172A) : Colors.white;
    Color textSecondary = isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    Color border = isLight ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1);

    int totalSteps = _getScenarioStepsCount();

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
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.grid_view, color: Colors.indigoAccent),
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
                      style: ElevatedButton.styleFrom(backgroundColor: isLight ? Colors.white : const Color(0xFF0F172A), foregroundColor: textPrimary, side: BorderSide(color: border), padding: const EdgeInsets.symmetric(vertical: 12)),
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent, side: BorderSide(color: Colors.redAccent.withOpacity(0.3)), padding: const EdgeInsets.symmetric(vertical: 12)),
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
                    decoration: BoxDecoration(color: isLight ? Colors.white : const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _scenario,
                        isExpanded: true,
                        dropdownColor: isLight ? Colors.white : const Color(0xFF1E293B),
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
                    decoration: BoxDecoration(color: (isLight ? Colors.white : const Color(0xFF0F172A)).withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('s${_scenario}_obj'), style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(totalSteps, (i) {
                    bool isPast = i < _step;
                    bool isCurrent = i == _step;
                    Color stepBg = isCurrent ? Colors.indigo.withOpacity(0.1) : (isPast ? Colors.green.withOpacity(0.05) : (textPrimary.withOpacity(0.02)));
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
                                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${t('stepLabel')} ${i + 1}", style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                _buildRichText(t('s${_scenario}_step${i + 1}_task'), isCurrent ? Colors.indigoAccent : textPrimary),
                                if (isPast) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: _buildRichText(t('s${_scenario}_step${i + 1}_out'), Colors.green),
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
              color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
              child: const Center(
                child: Text("© ZeroScienceLab - Fall in love with math and Science", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadBtn(String val, bool isLight) {
    return GestureDetector(
      onTap: () => _keypadInputAdd(val),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: isLight ? [Colors.white, const Color(0xFFF1F5F9)] : [const Color(0xFF1E293B), const Color(0xFF0F172A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isLight ? Colors.black12 : Colors.white10),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
        ),
        alignment: Alignment.center,
        child: Text(val, style: TextStyle(color: isLight ? Colors.black87 : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sidebarWidth = screenWidth * 0.30; // Requested 30% width
    if (sidebarWidth < 300) sidebarWidth = 300;

    int totalSteps = _getScenarioStepsCount();
    bool isLight = _theme == 'light';

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
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
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: DecimalArchitectPainter(
                          scenario: _scenario,
                          step: _step,
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          isLight: isLight,
                          onesBlocks: _onesBlocks,
                          tenthsBlocks: _tenthsBlocks,
                          hundBlocks: _hundBlocks,
                          floatingBlocks: _floatingBlocks,
                          slicerActive: _slicerActive,
                          slicerPos: _slicerPos,
                          isRegrouping: _isRegrouping,
                          regroupPhase: _regroupPhase,
                          incorrectColumns: _incorrectColumns,
                          isCompleted: _completedScenarios.contains(_scenario),
                          activeDragItem: _activeDragItem,
                          t: t,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // S5 Draggable Keypad Overlay
            if (_scenario == 5 && !_completedScenarios.contains(_scenario))
              Positioned(
                left: _calcPos?.dx ?? (screenWidth - 260),
                top: _calcPos?.dy ?? (screenHeight - 360),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      double newX = (_calcPos?.dx ?? (screenWidth - 260)) + details.delta.dx;
                      double newY = (_calcPos?.dy ?? (screenHeight - 360)) + details.delta.dy;
                      _calcPos = Offset(newX.clamp(0.0, screenWidth - 240), newY.clamp(0.0, screenHeight - 100));
                    });
                  },
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white.withOpacity(0.95) : const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)),
                        ),
                        Container(
                          width: double.infinity, height: 40,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                          child: Text(_keypadInput.isEmpty ? "0.00" : _keypadInput, style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        ),
                        GridView.count(
                          crossAxisCount: 3, shrinkWrap: true, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 1.6, physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildKeypadBtn('1', isLight), _buildKeypadBtn('2', isLight), _buildKeypadBtn('3', isLight),
                            _buildKeypadBtn('4', isLight), _buildKeypadBtn('5', isLight), _buildKeypadBtn('6', isLight),
                            _buildKeypadBtn('7', isLight), _buildKeypadBtn('8', isLight), _buildKeypadBtn('9', isLight),
                            _buildKeypadBtn('.', isLight), _buildKeypadBtn('0', isLight),
                            GestureDetector(
                              onTap: _keypadDelete,
                              child: Container(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: isLight ? [Colors.white, const Color(0xFFF1F5F9)] : [const Color(0xFF1E293B), const Color(0xFF0F172A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(8), border: Border.all(color: isLight ? Colors.black12 : Colors.white10), boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)]),
                                alignment: Alignment.center,
                                child: const Icon(Icons.backspace, color: Colors.redAccent, size: 20),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _checkScenario5,
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: Text(t('submitBtn').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            // S4 Check Button
            if (_scenario == 4 && !_completedScenarios.contains(_scenario))
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth + (screenWidth - sidebarWidth)/2 - 120 : screenWidth/2 - 120,
                child: ElevatedButton.icon(
                  onPressed: _checkScenario4,
                  icon: const Icon(Icons.check_circle, size: 24),
                  label: Text(t('checkBtn')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10, shadowColor: Colors.greenAccent
                  ),
                ),
              ),

            // Centralized HUD Overlay
            if (_step < totalSteps && _scenario != 4 && _scenario != 5)
              Positioned(
                bottom: 40, left: _isSidebarOpen ? sidebarWidth + 40 : 40, right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.95), borderRadius: BorderRadius.circular(20), border: const Border(top: BorderSide(color: Colors.indigoAccent, width: 4)), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.indigoAccent.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.info_outline, color: Colors.indigoAccent)),
                          const SizedBox(width: 12),
                          Flexible(child: Text(t('s${_scenario}_hud${_step + 1}'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Scenario Complete Banner
            if (_completedScenarios.contains(_scenario) && _scenario < 5)
              Positioned(
                bottom: 40, left: _isSidebarOpen ? sidebarWidth + 40 : 40, right: 40,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B).withOpacity(0.95), borderRadius: BorderRadius.circular(24), border: const Border(top: BorderSide(color: Colors.green, width: 4)), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 48),
                        const SizedBox(height: 16),
                        Text(t('s${_scenario}_final'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4)),
                        const SizedBox(height: 16),
                        Text(t('selectNextMsg'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
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
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            // MENU ICON
            Positioned(
              top: 16, left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent, iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact(); _playSound('tick');
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.8)))),
              ),
            ),

            // SUCCESS POPUP (All Scenarios Complete)
            if (_showSuccessPopup && _completedScenarios.length == 5)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: SingleChildScrollView(
                      controller: _popupScrollController,
                      child: Container(
                        width: 450, padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.green, width: 2), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)]),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(radius: 40, backgroundColor: Colors.green, child: Icon(Icons.flag, color: Colors.white, size: 40)),
                                const SizedBox(height: 24),
                                Text(t('summaryTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                _buildRichText(t('s5_final'), Colors.white70),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () { _playSound('pop'); setState(() => _showSuccessPopup = false); },
                                  icon: const Icon(Icons.check), label: Text(t('finishLab')),
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
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
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              child: Container(
                width: double.infinity, height: double.infinity,
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120, height: 120, margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]),
                          child: const Icon(Icons.view_in_ar, size: 80, color: Colors.indigoAccent),
                        ),
                        Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 16),
                        Text(t('appSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () { _playSound('pop'); setState(() => _showCurtain = false); },
                          icon: const Icon(Icons.play_circle_fill, size: 28), label: Text(t('enterLab')),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, elevation: 10, shadowColor: Colors.indigoAccent.withOpacity(0.5), textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
class DecimalArchitectPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX, panY;
  final bool isLight;
  final List<DecBlock> onesBlocks;
  final List<DecBlock> tenthsBlocks;
  final List<DecBlock> hundBlocks;
  final List<DecBlock> floatingBlocks;
  final bool slicerActive;
  final Offset slicerPos;
  final bool isRegrouping;
  final int regroupPhase;
  final List<bool>? incorrectColumns;
  final bool isCompleted;
  final DecBlock? activeDragItem;
  final Function(String) t;

  DecimalArchitectPainter({
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.isLight,
    required this.onesBlocks,
    required this.tenthsBlocks,
    required this.hundBlocks,
    required this.floatingBlocks,
    required this.slicerActive,
    required this.slicerPos,
    required this.isRegrouping,
    required this.regroupPhase,
    required this.incorrectColumns,
    required this.isCompleted,
    required this.activeDragItem,
    required this.t,
  });

  final double MAT_X = -200;
  final double MAT_Y = -150;
  final double MAT_W = 600;
  final double MAT_H = 380;
  final double PAL_X = -380;
  final double PAL_Y = -100;
  final double BASE_BLOCK_SIZE = 120;
  final double TENTHS_W = 12;
  final double TENTHS_H = 120;
  final double HUND_SIZE = 12;
  final Color OUTLINE_COLOR = const Color(0xFF0F172A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Environment
    _drawEnvironment(canvas);

    // Blocks on Mat
    for (var b in onesBlocks) { _drawGridBlock(canvas, b.x, b.y, 'ones', Colors.blue[500]!, OUTLINE_COLOR, b.isDragging); }
    for (var b in tenthsBlocks) { _drawGridBlock(canvas, b.x, b.y, 'tenths', Colors.blue[500]!, OUTLINE_COLOR, b.isDragging || (isRegrouping && regroupPhase == 2 && b.id == 'newTenth')); }
    for (var b in hundBlocks) { _drawGridBlock(canvas, b.x, b.y, 'hundredths', Colors.blue[500]!, OUTLINE_COLOR, b.isDragging || (isRegrouping && regroupPhase == 1)); }
    for (var b in floatingBlocks) { _drawGridBlock(canvas, b.x, b.y, b.type, Colors.blue[500]!, OUTLINE_COLOR, false); }

    // Slicer
    if (slicerActive) _drawSlicerIcon(canvas, slicerPos.dx, slicerPos.dy);

    // Active Drag
    if (activeDragItem != null) {
      if (activeDragItem!.type == 'slicer') _drawSlicerIcon(canvas, activeDragItem!.x, activeDragItem!.y);
      else _drawGridBlock(canvas, activeDragItem!.x, activeDragItem!.y, activeDragItem!.type, Colors.blue[500]!, OUTLINE_COLOR, true);
    }

    canvas.restore();
  }

  void _drawEnvironment(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(-2000, -1500, 4000, 3000), Paint()..color = const Color(0xFF38BDF8));

    // Palette
    _drawRoundedRect(canvas, PAL_X, PAL_Y, 100, 280, 10, const Color(0xFFCBD5E1), const Color(0xFF64748B), 3);
    _drawTextOutline(canvas, "Palette", PAL_X + 50, PAL_Y + 20, 14, OUTLINE_COLOR, Colors.transparent, 0);

    canvas.save(); canvas.translate(PAL_X + 10, PAL_Y + 40); canvas.scale(0.66, 0.66);
    _drawGridBlock(canvas, 0, 0, 'ones', Colors.blue[500]!, OUTLINE_COLOR, false); canvas.restore();

    canvas.save(); canvas.translate(PAL_X + 20, PAL_Y + 140); canvas.scale(0.8, 0.8);
    _drawGridBlock(canvas, 0, 0, 'tenths', Colors.blue[500]!, OUTLINE_COLOR, false);
    _drawGridBlock(canvas, 15, 0, 'tenths', Colors.blue[500]!, OUTLINE_COLOR, false);
    _drawGridBlock(canvas, 30, 0, 'tenths', Colors.blue[500]!, OUTLINE_COLOR, false);
    canvas.restore();

    canvas.save(); canvas.translate(PAL_X + 30, PAL_Y + 250);
    _drawGridBlock(canvas, 0, 0, 'hundredths', Colors.blue[500]!, OUTLINE_COLOR, false);
    _drawGridBlock(canvas, 20, 0, 'hundredths', Colors.blue[500]!, OUTLINE_COLOR, false);
    _drawGridBlock(canvas, 0, 20, 'hundredths', Colors.blue[500]!, OUTLINE_COLOR, false);
    canvas.restore();

    if (scenario == 2 && !slicerActive && step == 0) _drawSlicerIcon(canvas, PAL_X + 50, PAL_Y + 220);

    // Mat
    _drawRoundedRect(canvas, MAT_X, MAT_Y, MAT_W, MAT_H, 12, const Color(0xFFF8FAFC), const Color(0xFF94A3B8), 4);
    _drawTextOutline(canvas, "Place Value Mat", MAT_X + MAT_W / 2, MAT_Y + 25, 20, OUTLINE_COLOR, Colors.transparent, 0);

    double colW = MAT_W / 3;

    // Hover Highlight Logic
    int activeColIndex = -1;
    String? expectedType;
    if (scenario == 1 && !isCompleted) { activeColIndex = step; expectedType = step == 0 ? 'ones' : step == 1 ? 'tenths' : 'hundredths'; }
    else if (scenario == 2 && step == 1 && !isCompleted) { activeColIndex = 1; expectedType = 'tenths'; }
    else if (scenario == 3 && !isCompleted) { activeColIndex = 2; expectedType = 'hundredths'; }

    if (activeColIndex != -1) {
      bool isHovering = false;
      if (activeDragItem != null) {
        double w = activeDragItem!.type == 'ones' ? BASE_BLOCK_SIZE : activeDragItem!.type == 'tenths' ? TENTHS_W : HUND_SIZE;
        double h = activeDragItem!.type == 'ones' ? BASE_BLOCK_SIZE : activeDragItem!.type == 'tenths' ? TENTHS_H : HUND_SIZE;
        double cx = activeDragItem!.x + w / 2;
        double cy = activeDragItem!.y + h / 2;
        
        int dropCol = -1;
        if (cx >= MAT_X && cx < MAT_X + colW) dropCol = 0;
        else if (cx >= MAT_X + colW && cx < MAT_X + 2 * colW) dropCol = 1;
        else if (cx >= MAT_X + 2 * colW && cx <= MAT_X + MAT_W) dropCol = 2;

        if (dropCol == activeColIndex && cy >= MAT_Y && cy <= MAT_Y + MAT_H && activeDragItem!.type == expectedType) isHovering = true;
      }

      if (isHovering) {
        canvas.drawRect(Rect.fromLTWH(MAT_X + activeColIndex * colW + 10, MAT_Y + 50, colW - 20, MAT_H - 60), Paint()..color = const Color(0x66FDE047)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25));
      } else {
        canvas.drawRect(Rect.fromLTWH(MAT_X + activeColIndex * colW + 10, MAT_Y + 50, colW - 20, MAT_H - 60), Paint()..color = Colors.black12);
      }
    }

    // Incorrect Columns (S4)
    if (scenario == 4 && incorrectColumns != null) {
      Paint errP = Paint()..color = const Color(0x40EF4444);
      if (incorrectColumns![0]) canvas.drawRect(Rect.fromLTWH(MAT_X + 10, MAT_Y + 50, colW - 20, MAT_H - 60), errP);
      if (incorrectColumns![1]) canvas.drawRect(Rect.fromLTWH(MAT_X + colW + 10, MAT_Y + 50, colW - 20, MAT_H - 60), errP);
      if (incorrectColumns![2]) canvas.drawRect(Rect.fromLTWH(MAT_X + 2 * colW + 10, MAT_Y + 50, colW - 20, MAT_H - 60), errP);
    }

    // Regroup Highlight (S3)
    if (scenario == 3 && isRegrouping) {
      canvas.drawRect(Rect.fromLTWH(MAT_X + 2 * colW + 10, MAT_Y + 50, colW - 20, MAT_H - 60), Paint()..color = const Color(0x26FACC15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
      if (regroupPhase == 2) canvas.drawRect(Rect.fromLTWH(MAT_X + colW + 10, MAT_Y + 50, colW - 20, MAT_H - 60), Paint()..color = const Color(0x4DFACC15));
    }

    // Lines & Headers
    _drawTextOutline(canvas, t('colOnes'), MAT_X + colW / 2, MAT_Y + 60, 22, const Color(0xFF0284C7), Colors.transparent, 0);
    _drawTextOutline(canvas, t('colTenths'), MAT_X + colW + colW / 2, MAT_Y + 60, 22, const Color(0xFF0284C7), Colors.transparent, 0);
    _drawTextOutline(canvas, t('colHund'), MAT_X + 2 * colW + colW / 2, MAT_Y + 60, 22, const Color(0xFF0284C7), Colors.transparent, 0);

    Paint lineP = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2;
    canvas.drawLine(Offset(MAT_X + 20, MAT_Y + 40), Offset(MAT_X + MAT_W - 20, MAT_Y + 40), lineP);
    canvas.drawLine(Offset(MAT_X + 20, MAT_Y + 80), Offset(MAT_X + MAT_W - 20, MAT_Y + 80), lineP);
    canvas.drawLine(Offset(MAT_X + colW, MAT_Y + 40), Offset(MAT_X + colW, MAT_Y + MAT_H - 20), lineP);
    canvas.drawLine(Offset(MAT_X + 2 * colW, MAT_Y + 40), Offset(MAT_X + 2 * colW, MAT_Y + MAT_H - 20), lineP);

    // Digital Display
    if (scenario != 5) {
      double dispW = scenario == 4 ? 240 : 160;
      double dispH = 60;
      double dispY = MAT_Y - dispH / 2;
      String dispStr = scenario == 4 ? "Build: 2.05" : "";

      if (scenario != 4) {
        double val = (onesBlocks.length * 1) + (tenthsBlocks.length * 0.1) + (hundBlocks.length * 0.01);
        dispStr = val.toStringAsFixed(2);
        if (scenario == 3 && isRegrouping && regroupPhase == 1) dispStr = "0.19"; // simulate intermediate state roughly
      }

      _drawRoundedRect(canvas, MAT_X + MAT_W / 2 - dispW / 2, dispY, dispW, dispH, 8, Colors.black, const Color(0xFF334155), 4);
      Color textC = scenario == 4 || (scenario == 3 && isCompleted) ? const Color(0xFFFACC15) : Colors.white;
      if (scenario == 3 && isCompleted) {
        canvas.drawRect(Rect.fromLTWH(MAT_X + MAT_W / 2 - dispW / 2, dispY, dispW, dispH), Paint()..color = const Color(0x33FACC15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
      }
      _drawTextOutline(canvas, dispStr, MAT_X + MAT_W / 2, dispY + dispH / 2, 36, textC, Colors.transparent, 0, fontFam: 'monospace');
    }

    // Counters S4
    if (scenario == 4 && !isCompleted) {
      double py = MAT_Y + MAT_H + 20;
      Paint bp = Paint()..color = OUTLINE_COLOR;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(MAT_X + colW / 2, py + 12), width: 40, height: 24), const Radius.circular(12)), bp);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(MAT_X + colW + colW / 2, py + 12), width: 40, height: 24), const Radius.circular(12)), bp);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(MAT_X + 2 * colW + colW / 2, py + 12), width: 40, height: 24), const Radius.circular(12)), bp);
      _drawTextOutline(canvas, "${onesBlocks.length}", MAT_X + colW / 2, py + 12, 14, Colors.white, Colors.transparent, 0);
      _drawTextOutline(canvas, "${tenthsBlocks.length}", MAT_X + colW + colW / 2, py + 12, 14, Colors.white, Colors.transparent, 0);
      _drawTextOutline(canvas, "${hundBlocks.length}", MAT_X + 2 * colW + colW / 2, py + 12, 14, Colors.white, Colors.transparent, 0);
    }
  }

  void _drawGridBlock(Canvas canvas, double x, double y, String type, Color color, Color strokeColor, bool highlight) {
    canvas.save(); canvas.translate(x, y);

    if (highlight) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, type == 'ones' ? BASE_BLOCK_SIZE : type == 'tenths' ? TENTHS_W : HUND_SIZE, type == 'ones' ? BASE_BLOCK_SIZE : type == 'tenths' ? TENTHS_H : HUND_SIZE),
        Paint()..color = const Color(0x99FDE047)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      );
    }

    Paint fp = Paint()..color = color;
    Paint sp = Paint()..color = strokeColor..style = PaintingStyle.stroke..strokeWidth = 1;
    Paint gridSp = Paint()..color = Colors.black45..style = PaintingStyle.stroke..strokeWidth = 1;

    if (type == 'ones') {
      canvas.drawRect(Rect.fromLTWH(0, 0, BASE_BLOCK_SIZE, BASE_BLOCK_SIZE), fp);
      canvas.drawRect(Rect.fromLTWH(0, 0, BASE_BLOCK_SIZE, BASE_BLOCK_SIZE), sp);
      for (int i = 1; i < 10; i++) {
        canvas.drawLine(Offset(i * 12, 0), Offset(i * 12, BASE_BLOCK_SIZE), gridSp);
        canvas.drawLine(Offset(0, i * 12), Offset(BASE_BLOCK_SIZE, i * 12), gridSp);
      }
    } else if (type == 'tenths') {
      canvas.drawRect(Rect.fromLTWH(0, 0, TENTHS_W, TENTHS_H), fp);
      canvas.drawRect(Rect.fromLTWH(0, 0, TENTHS_W, TENTHS_H), sp);
      for (int i = 1; i < 10; i++) canvas.drawLine(Offset(0, i * 12), Offset(TENTHS_W, i * 12), gridSp);
    } else if (type == 'hundredths') {
      canvas.drawRect(Rect.fromLTWH(0, 0, HUND_SIZE, HUND_SIZE), fp);
      canvas.drawRect(Rect.fromLTWH(0, 0, HUND_SIZE, HUND_SIZE), sp);
    }
    canvas.restore();
  }

  void _drawSlicerIcon(Canvas canvas, double x, double y) {
    canvas.save(); canvas.translate(x, y);
    Path p = Path()
      ..moveTo(-15, -20)..lineTo(15, -20)..lineTo(20, 20)..lineTo(-20, 20)..close();
    canvas.drawPath(p, Paint()..color = Colors.redAccent);
    canvas.drawPath(p, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    _drawTextOutline(canvas, "✂️", 0, 0, 20, Colors.white, Colors.transparent, 0);
    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double strokeW = 1.0]) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && strokeW > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
  }

  void _drawTextOutline(Canvas canvas, String text, double x, double y, double fontSize, Color fill, Color outline, double outlineW, {TextAlign align = TextAlign.center, String fontFam = 'Plus Jakarta Sans'}) {
    TextPainter tpFill = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: fontFam)),
      textDirection: TextDirection.ltr, textAlign: align,
    );
    tpFill.layout();
    double dx = align == TextAlign.center ? x - tpFill.width / 2 : x;
    double dy = y - tpFill.height / 2;
    tpFill.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant DecimalArchitectPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA (EN, HI, TE)
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "The Decimal Architect: Building Numbers Block by Block",
    'appTitle': "The Decimal Architect", 
    'appSubtitle': "Class 7 • ANOTHER PEEK BEYOND THE POINT",
    'enterLab': "Enter Simulation",
    'settings': "Settings",
    'theme': "Theme",
    'darkMode': "Switch to Dark Mode",
    'lightMode': "Switch to Light Mode",
    'boardFontSize': "Text Size",
    'selectScenario': "Select Scenario",
    'selectNextMsg': "Please select another scenario from the dropdown above.",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Learning:",
    'closeBtn': "Close",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'checkBtn': "Check Architecture",
    'submitBtn': "Submit",
    'colOnes': "Ones",
    'colTenths': "Tenths",
    'colHund': "Hundredths",
    's1_title': "1. Building Your First Decimal",
    's1_obj': "To understand the physical representation of each decimal place value by constructing the number 1.23.",
    's1_hud1': "Drag one 'Ones Block' to the 'Ones' column.",
    's1_step1_task': "DRAG one 'Ones Block' (large flat square) from the palette and DROP it into the 'Ones' column.",
    's1_step1_out': "The Ones Block snaps into place. The display updates to 1.00.",
    's1_hud2': "Drag two 'Tenths Blocks' to the 'Tenths' column.",
    's1_step2_task': "DRAG two 'Tenths Blocks' (long rods) into the 'Tenths' column.",
    's1_step2_out': "The rods snap into place. The display updates sequentially to 1.20.",
    's1_hud3': "Drag three 'Hundredths Blocks' to the 'Hundredths' column.",
    's1_step3_task': "DRAG three 'Hundredths Blocks' (small cubes) into the 'Hundredths' column.",
    's1_step3_out': "The cubes snap into place. The display reads 1.23.",
    's1_final': "You have built the number 1.23! It is made of 1 One, 2 Tenths, and 3 Hundredths. Notice how each block is 10 times smaller than the one to its left.",
    's2_title': "2. The Magic Slicer",
    's2_obj': "To visually convert the fraction 4/10 into its decimal equivalent, 0.4.",
    's2_hud1': "Drag the 'Slicer Tool' onto the 'Ones Block'.",
    's2_step1_task': "DRAG the Slicer Tool and DROP it onto the Ones Block on the mat.",
    's2_step1_out': "The Slicer cuts the Ones Block into 10 equal 'Tenths' rods. This shows a 'One' is 10 'Tenths'.",
    's2_hud2': "Drag four 'Tenths' rods into the 'Tenths' column.",
    's2_step2_task': "Represent the fraction 4/10. DRAG four of the 'Tenths' rods into the 'Tenths' column.",
    's2_step2_out': "The display updates to 0.40. The remaining 6 rods stay behind.",
    's2_final': "Excellent! 4 parts out of 10 is the fraction 4/10. As a decimal, we write this as 0.4.",
    's3_title': "3. The Great Exchange: Regrouping",
    's3_obj': "To understand regrouping by adding 0.08 to 0.15 and witnessing 10 hundredths become 1 tenth.",
    's3_hud1': "Add 8 'Hundredths' cubes to the existing 5.",
    's3_step1_task': "Add 0.08. DRAG 8 'Hundredths' cubes into the 'Hundredths' column.",
    's3_step1_out': "As you reach 10 hundredths, they bundle together and morph into a single 'Tenths' rod which moves to the Tenths column.",
    's3_hud2': "Add the remaining 3 'Hundredths' cubes.",
    's3_step2_task': "CONTINUE adding the remaining 3 'Hundredths' cubes to the column.",
    's3_step2_out': "The final 3 cubes are placed. The display updates to 0.23.",
    's3_final': "You've mastered regrouping! When you have 10 in any column, they become 1 in the next larger column. 0.15 + 0.08 = 0.23.",
    's4_title': "4. The Architect's Challenge",
    's4_obj': "Given the decimal number 2.05, construct its physical representation without step-by-step guidance.",
    's4_hud1': "Build the number 2.05 using blocks. Click Check when done.",
    's4_step1_task': "DRAG and DROP the correct number of blocks into each column to match the target number: 2.05.",
    's4_step1_out': "You correctly placed 2 Ones Blocks, 0 Tenths rods, and 5 Hundredths cubes.",
    's4_hud2': "Click 'Check Architecture'.",
    's4_step2_task': "CLICK the 'Check Architecture' button below to verify.",
    's4_step2_out': "Perfectly built! The zero in the Tenths place is an important placeholder.",
    's4_final': "You correctly showed that 2.05 has 2 Ones, 0 Tenths, and 5 Hundredths.",
    's5_title': "5. The Inspector's Puzzle",
    's5_obj': "Given a physical representation of blocks on the mat, identify and enter the correct decimal number.",
    's5_hud1:': "Enter the decimal number for the blocks using the keypad.",
    's5_step1_task': "Look at the blocks: 0 Ones, 3 Tenths, and 7 Hundredths. ENTER the decimal number on the keypad.",
    's5_step1_out': "You correctly deduced the number.",
    's5_hud2': "Click Submit.",
    's5_step2_task': "CLICK 'Submit' to lock in your answer.",
    's5_step2_out': "The number 0.37 perfectly matches the 3 Tenths and 7 Hundredths blocks.",
    's5_final': "Job well done, Inspector! You can now read decimal representations and turn them back into numbers.",
  },
  'hi': {
    'shutterTitle': "दशमलव आर्किटेक्ट: ब्लॉक दर ब्लॉक संख्याएं बनाना",
    'appTitle': "दशमलव आर्किटेक्ट", 
    'appSubtitle': "कक्षा 7 • दशमलव के पार एक और नज़र",
    'enterLab': "सिमुलेशन दर्ज करें",
    'settings': "सेटिंग्स",
    'theme': "थीम",
    'darkMode': "डार्क मोड",
    'lightMode': "लाइट मोड",
    'boardFontSize': "टेक्स्ट आकार",
    'selectScenario': "परिदृश्य चुनें",
    'selectNextMsg': "कृपया ऊपर दिए गए ड्रॉपडाउन से एक और परिदृश्य चुनें।",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "सीख:",
    'closeBtn': "बंद करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'checkBtn': "आर्किटेक्चर जांचें",
    'submitBtn': "सबमिट करें",
    'colOnes': "इकाई",
    'colTenths': "दशवांश",
    'colHund': "शतांश",
    's1_title': "1. अपना पहला दशमलव बनाना",
    's1_obj': "संख्या 1.23 का निर्माण करके प्रत्येक दशमलव स्थान मान के भौतिक प्रतिनिधित्व को समझना।",
    's1_hud1': "एक 'इकाई ब्लॉक' को 'इकाई' कॉलम में खींचें।",
    's1_step1_task': "पैलेट से एक 'इकाई ब्लॉक' (Ones Block) को खींचें और इसे 'इकाई' कॉलम में छोड़ें।",
    's1_step1_out': "इकाई ब्लॉक अपनी जगह पर स्नैप हो जाता है। डिस्प्ले 1.00 हो जाता है।",
    's1_hud2': "दो 'दशवांश ब्लॉक' को 'दशवांश' कॉलम में खींचें।",
    's1_step2_task': "पैलेट से दो 'दशवांश ब्लॉक' (Tenths Blocks) को 'दशवांश' कॉलम में खींचें।",
    's1_step2_out': "छड़ें अपनी जगह पर आ जाती हैं। डिस्प्ले 1.20 में अपडेट हो जाता है।",
    's1_hud3': "तीन 'शतांश ब्लॉक' को 'शतांश' कॉलम में खींचें।",
    's1_step3_task': "तीन 'शतांश ब्लॉक' (Hundredths Blocks) को 'शतांश' कॉलम में खींचें।",
    's1_step3_out': "क्यूब्स अपनी जगह पर आ जाते हैं। डिस्प्ले 1.23 पढ़ता है।",
    's1_final': "आपने 1.23 संख्या बना ली है! यह 1 इकाई, 2 दशवांश और 3 शतांश से बना है। ध्यान दें कि प्रत्येक ब्लॉक अपने बाईं ओर वाले ब्लॉक से 10 गुना छोटा कैसे है।",
    's2_title': "2. मैजिक स्लाइसर",
    's2_obj': "भिन्न 4/10 को इसके दशमलव समतुल्य 0.4 में दृष्टिगत रूप से परिवर्तित करना।",
    's2_hud1': "'स्लाइसर टूल' को 'इकाई ब्लॉक' पर खींचें।",
    's2_step1_task': "स्लाइसर टूल को खींचें और इसे मैट पर इकाई ब्लॉक पर छोड़ दें।",
    's2_step1_out': "स्लाइसर इकाई ब्लॉक को 10 समान 'दशवांश' छड़ों में काटता है।",
    's2_hud2:': "चार 'दशवांश' छड़ों को 'दशवांश' कॉलम में खींचें।",
    's2_step2_task': "भिन्न 4/10 का प्रतिनिधित्व करें। चार 'दशवांश' छड़ों को 'दशवांश' कॉलम में खींचें।",
    's2_step2_out': "डिस्प्ले 0.40 में अपडेट हो जाता है। शेष 6 छड़ें पीछे रह जाती हैं।",
    's2_final': "उत्कृष्ट! 10 में से 4 भाग भिन्न 4/10 है। दशमलव के रूप में, हम इसे 0.4 लिखते हैं।",
    's3_title': "3. महान विनिमय: पुनर्समूहन",
    's3_obj': "0.15 में 0.08 जोड़कर पुनर्समूहन को समझना और 10 शतांश को 1 दशवांश बनते देखना।",
    's3_hud1': "मौजूदा 5 में 8 'शतांश' क्यूब्स जोड़ें।",
    's3_step1_task': "0.08 जोड़ें। 8 'शतांश' क्यूब्स को 'शतांश' कॉलम में खींचें।",
    's3_step1_out': "जैसे ही आप 10 शतांश तक पहुँचते हैं, वे एक साथ बंडल हो जाते हैं और एक एकल 'दशवांश' छड़ में बदल जाते हैं जो दशवांश कॉलम में चली जाती है।",
    's3_hud2': "शेष 3 'शतांश' क्यूब्स जोड़ें।",
    's3_step2_task': "कॉलम में शेष 3 'शतांश' क्यूब्स जोड़ना जारी रखें।",
    's3_step2_out': "अंतिम 3 क्यूब्स रखे गए हैं। डिस्प्ले 0.23 में अपडेट हो जाता है।",
    's3_final': "आपने पुनर्समूहन में महारत हासिल कर ली है! 0.15 + 0.08 = 0.23।",
    's4_title': "4. आर्किटेक्ट की चुनौती",
    's4_obj': "दशमलव संख्या 2.05 को बिना मार्गदर्शन के बनाना।",
    's4_hud1': "ब्लॉकों का उपयोग करके संख्या 2.05 बनाएं। पूर्ण होने पर जांचें (Check) पर क्लिक करें।",
    's4_step1_task': "लक्ष्य संख्या 2.05 से मेल खाने के लिए प्रत्येक कॉलम में ब्लॉकों की सही संख्या खींचें और छोड़ें।",
    's4_step1_out': "आपने 2 इकाई ब्लॉक, 0 दशवांश छड़ें, और 5 शतांश क्यूब्स सही ढंग से रखे।",
    's4_hud2': "'आर्किटेक्चर जांचें' पर क्लिक करें।",
    's4_step2_task': "सत्यापित करने के लिए नीचे 'आर्किटेक्चर जांचें' बटन पर क्लिक करें।",
    's4_step2_out': "पूरी तरह से बनाया गया! दशवांश स्थान में शून्य एक महत्वपूर्ण प्लेसहोल्डर है।",
    's4_final': "आपने सही ढंग से दिखाया कि 2.05 में 2 इकाई, 0 दशवांश और 5 शतांश हैं।",
    's5_title': "5. इंस्पेक्टर की पहेली",
    's5_obj': "मैट पर ब्लॉकों के भौतिक प्रतिनिधित्व को देखते हुए, सही दशमलव संख्या की पहचान करें और दर्ज करें।",
    's5_hud1': "कीपैड का उपयोग करके ब्लॉकों के लिए दशमलव संख्या दर्ज करें।",
    's5_step1_task': "ब्लॉकों को देखें: 0 इकाई, 3 दशवांश, और 7 शतांश। कीपैड पर दशमलव संख्या दर्ज करें।",
    's5_step1_out': "आपने सही संख्या का अनुमान लगाया।",
    's5_hud2': "सबमिट पर क्लिक करें।",
    's5_step2_task': "अपना उत्तर लॉक करने के लिए 'सबमिट करें' पर क्लिक करें।",
    's5_step2_out': "संख्या 0.37 पूरी तरह से 3 दशवांश और 7 शतांश ब्लॉकों से मेल खाती है।",
    's5_final': "बहुत बढ़िया, इंस्पेक्टर! अब आप दशमलव प्रतिनिधित्व पढ़ सकते हैं।",
  },
  };