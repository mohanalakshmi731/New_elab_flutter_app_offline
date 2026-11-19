// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultiplyingandDividingDecimalsbyPowersof10App());
}

class MultiplyingandDividingDecimalsbyPowersof10App extends StatelessWidget {
  const MultiplyingandDividingDecimalsbyPowersof10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | The Decimal Shifter Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const MultiplyingandDividingDecimalsbyPowersof10(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class MachineCol {
  final int id;
  final double val;
  final String labelKey;
  final Color color;
  MachineCol(this.id, this.val, this.labelKey, this.color);
}

final List<MachineCol> MASTER_COLUMNS = [
  MachineCol(0, 10000, 'col_10k', Colors.purpleAccent),
  MachineCol(1, 1000, 'col_1k', Colors.pinkAccent),
  MachineCol(2, 100, 'col_100', Colors.redAccent),
  MachineCol(3, 10, 'col_10', Colors.amberAccent),
  MachineCol(4, 1, 'col_1', Colors.greenAccent),
  MachineCol(5, 0.1, 'col_01', Colors.blueAccent),
  MachineCol(6, 0.01, 'col_001', Colors.cyanAccent),
  MachineCol(7, 0.001, 'col_0001', Colors.indigoAccent),
];

class BlockItem {
  String id;
  String digit;
  int? colIndex;
  double x, y, targetX, targetY;
  bool isDragging;
  bool isLeadingZero;

  BlockItem(this.id, this.digit, this.x, this.y, {this.colIndex, this.isLeadingZero = false})
      : targetX = x,
        targetY = y,
        isDragging = false;
}

class GearItem {
  String id;
  String type;
  double x, y, targetX, targetY;
  bool isDragging;
  bool inSlot;

  GearItem(this.id, this.type, this.x, this.y)
      : targetX = x,
        targetY = y,
        isDragging = false,
        inSlot = false;
}

// ==========================================
// MAIN WIDGET
// ==========================================
class MultiplyingandDividingDecimalsbyPowersof10 extends StatefulWidget {
  const MultiplyingandDividingDecimalsbyPowersof10({super.key});

  @override
  State<MultiplyingandDividingDecimalsbyPowersof10> createState() => _GameState();
}

class _GameState extends State<MultiplyingandDividingDecimalsbyPowersof10> with TickerProviderStateMixin {
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
  Object? _activeDragItem; 
  bool _isDraggingCanvas = false;
  Offset? _obsPos;

  // Simulation State
  List<MachineCol> _activeCols = [];
  List<BlockItem> _blocks = [];
  List<GearItem> _gears = [];
  GearItem? _activeGear;
  
  bool _isAnimating = false;
  double _animProgress = 0;
  double _gearAngle = 0;
  String? _targetValueDisplay;
  int? _burstTime;
  
  // HUD
  String _transientHudMessage = '';
  Timer? _hudTimer;

  // Audio players
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _alertPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';
  static const String _whirUrl = 'audio/class7/mixkit_2570.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';

  late AnimationController _ticker;

  // Layout Constants
  double MAT_W = 500;
  final double MAT_H = 340;
  double MAT_X = -300;
  final double MAT_Y = -120;
  final double COL_W = 100;
  double GEAR_SLOT_X = 0;
  double GEAR_SLOT_Y = 0;
  final double PAL_X = -380;
  final double PAL_Y = -120;
  
  // Machine Activate Button Hitbox
  Rect _activateBtnRect = Rect.zero;

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
    _hudTimer?.cancel();
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
    _alertPlayer.dispose();
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
      } else if (type == 'alert') {
        await _alertPlayer.play(AssetSource(_alertUrl), volume: 0.5);
      } else if (type == 'whir') {
        await _fxPlayer.play(AssetSource(_whirUrl), volume: 0.6);
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

  void _showTempHUD(String msg) {
    _playSound('alert');
    setState(() {
      _transientHudMessage = msg;
    });
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _transientHudMessage = '';
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
      _obsPos = null;
      _showSuccessPopup = false;
      _blocks.clear();
      _gears.clear();
      _activeGear = null;
      _targetValueDisplay = null;
      _isAnimating = false;
      _animProgress = 0;
      _gearAngle = 0;
      _burstTime = null;
      _transientHudMessage = '';

      if (id == 1 || id == 2 || id == 5) {
        _activeCols = MASTER_COLUMNS.sublist(2, 7); // Hundreds to Hundredths
      } else if (id == 3) {
        _activeCols = MASTER_COLUMNS.sublist(0, 7); // Ten Thousands to Hundredths
      } else if (id == 4) {
        _activeCols = MASTER_COLUMNS.sublist(3, 8); // Tens to Thousandths
      }

      MAT_W = _activeCols.length * COL_W;
      MAT_X = -(MAT_W / 2) - 50;
      GEAR_SLOT_X = MAT_X + MAT_W + 70;
      GEAR_SLOT_Y = MAT_Y + 120;
      _activateBtnRect = Rect.fromLTWH(MAT_X - 100, MAT_Y + MAT_H - 110, 80, 80);

      // Populate Palette
      if (id == 1) {
        _blocks.add(BlockItem('b_5', '5', PAL_X + 20, PAL_Y + 100));
        _blocks.add(BlockItem('b_7', '7', PAL_X + 20, PAL_Y + 180));
        _gears.add(GearItem('g_x10', 'x10', PAL_X + 25, PAL_Y + 280));
      } else if (id == 2) {
        _blocks.add(BlockItem('b_2', '2', PAL_X + 20, PAL_Y + 100));
        _blocks.add(BlockItem('b_4', '4', PAL_X + 20, PAL_Y + 180));
        _gears.add(GearItem('g_d100', '÷100', PAL_X + 25, PAL_Y + 280));
      } else if (id == 3) {
        _blocks.add(BlockItem('b_2', '2', PAL_X + 20, PAL_Y + 30));
        _blocks.add(BlockItem('b_4', '4', PAL_X + 20, PAL_Y + 100));
        _blocks.add(BlockItem('b_6', '6', PAL_X + 20, PAL_Y + 170));
        _blocks.add(BlockItem('b_7', '7', PAL_X + 20, PAL_Y + 240));
        _gears.add(GearItem('g_x1000', 'x1000', PAL_X + 25, PAL_Y + 330));
      } else if (id == 4) {
        _blocks.add(BlockItem('b_1', '1', _getColX(3) + COL_W/2 - 25, MAT_Y + MAT_H/2 - 30, colIndex: 3));
        _blocks.add(BlockItem('b_2', '2', _getColX(4) + COL_W/2 - 25, MAT_Y + MAT_H/2 - 30, colIndex: 4));
        _gears.add(GearItem('g_d10', '÷10', PAL_X + 25, PAL_Y + 100));
        _gears.add(GearItem('g_d100', '÷100', PAL_X + 25, PAL_Y + 200));
        _gears.add(GearItem('g_d1000', '÷1000', PAL_X + 25, PAL_Y + 300));
        _targetValueDisplay = "0.012";
      } else if (id == 5) {
        _blocks.add(BlockItem('b_0', '0', _getColX(4) + COL_W/2 - 25, MAT_Y + MAT_H/2 - 30, colIndex: 4, isLeadingZero: true));
        _blocks.add(BlockItem('b_9', '9', _getColX(5) + COL_W/2 - 25, MAT_Y + MAT_H/2 - 30, colIndex: 5));
        _blocks.add(BlockItem('b_2', '2', _getColX(6) + COL_W/2 - 25, MAT_Y + MAT_H/2 - 30, colIndex: 6));
        _gears.add(GearItem('g_x10', 'x10', PAL_X + 25, PAL_Y + 100));
        _gears.add(GearItem('g_x100', 'x100', PAL_X + 25, PAL_Y + 200));
        _gears.add(GearItem('g_d10', '÷10', PAL_X + 25, PAL_Y + 300));
        _targetValueDisplay = "920";
      }
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  double _getColX(int id) {
    if (_activeCols.isEmpty) return MAT_X;
    int firstId = _activeCols.first.id;
    int relativeIdx = id - firstId;
    return MAT_X + relativeIdx * COL_W;
  }

  int _getShiftForGear(String type) {
    if (type == 'x10') return -1;
    if (type == 'x100') return -2;
    if (type == 'x1000') return -3;
    if (type == '÷10') return 1;
    if (type == '÷100') return 2;
    if (type == '÷1000') return 3;
    return 0;
  }

  void _tick() {
    setState(() {
      // Update Block Positions - Decoupled to fix animation lock!
      for (var b in _blocks) {
        if (!b.isDragging) {
          if (!_isAnimating) {
            // Normal pull towards target slots when not animating
            if (b.colIndex != null) {
              b.targetX = _getColX(b.colIndex!) + COL_W / 2 - 25;
              b.targetY = MAT_Y + MAT_H / 2 - 30;
            }
            b.x += (b.targetX - b.x) * 0.2;
            b.y += (b.targetY - b.y) * 0.2;
          } else {
            // IF animating, only blocks still in the palette get pulled down
            if (b.colIndex == null) {
              b.x += (b.targetX - b.x) * 0.2;
              b.y += (b.targetY - b.y) * 0.2;
            }
          }
        }
      }

      // Update Gear Positions
      for (var g in _gears) {
        if (!g.isDragging && !g.inSlot) {
          g.x += (g.targetX - g.x) * 0.2;
          g.y += (g.targetY - g.y) * 0.2;
        }
      }

      // Smooth Animation Logic
      if (_isAnimating && _activeGear != null) {
        _animProgress += 0.02; // Smooth animation speed
        int shift = _getShiftForGear(_activeGear!.type);
        _gearAngle += 0.05 * shift.sign;

        bool allDone = true;
        for (var b in _blocks) {
          if (b.colIndex != null) {
            int targetCol = b.colIndex! + shift;
            double destX = _getColX(targetCol) + COL_W / 2 - 25;
            double dx = destX - b.x;
            if (dx.abs() > 2.0) {
              b.x += dx * 0.15; // Damped movement towards destination
              allDone = false;
            } else {
              b.x = destX;
            }
          }
        }

        if (_animProgress >= 1.0 && allDone) {
          _isAnimating = false;
          _handlePostAnimation();
        }
      }
    });
  }

  void _handlePostAnimation() {
    if (_activeGear == null) return;
    int shift = _getShiftForGear(_activeGear!.type);
    
    // Update Logical Columns only when animation is done
    for (var b in _blocks) {
      if (b.colIndex != null) {
        b.colIndex = b.colIndex! + shift;
      }
    }

    var activeBlocks = _blocks.where((b) => b.colIndex != null).toList();
    if (activeBlocks.isNotEmpty) {
      int currentMin = activeBlocks.map((b) => b.colIndex!).reduce(min);
      int currentMax = activeBlocks.map((b) => b.colIndex!).reduce(max);

      // robust gap filling (fill gaps between decimals and ones)
      int fillStart = min(4, currentMin);
      int fillEnd = max(4, currentMax);
      for (int i = fillStart; i <= fillEnd; i++) {
        if (!_blocks.any((b) => b.colIndex == i)) {
          _spawnZeroAt(i);
        }
      }

      // Clean leading zeros
      for (var b in _blocks) {
        if (b.digit == '0' && b.colIndex != null) {
          if (b.colIndex! < 4) { // Only numbers to left of Ones can be leading zeros
            bool hasSmallerNonZero = _blocks.any((ob) => ob.colIndex != null && ob.colIndex! < b.colIndex! && ob.digit != '0' && !ob.isLeadingZero);
            b.isLeadingZero = !hasSmallerNonZero;
          } else {
            b.isLeadingZero = false; // Decimals and Ones are never leading zeros
          }
        }
      }
    }

    int currentStep = _step;

    if (_scenario == 5 && currentStep == 1) {
      _activeGear!.inSlot = false;
      _activeGear!.x = _activeGear!.targetX;
      _activeGear!.y = _activeGear!.targetY;
      _activeGear = null;
      _advanceStep();
    } else if (_scenario == 1 && currentStep == 2) {
      _checkScenarioSuccess();
    } else if (_scenario == 2 && currentStep == 2) {
      _checkScenarioSuccess();
    } else if (_scenario == 3 && currentStep == 2) {
      _checkScenarioSuccess();
    } else if (_scenario == 4 && currentStep == 1) {
      if (_calculateMachineValue() == "0.012") _checkScenarioSuccess();
      else { _playSound('error'); _showTempHUD(t('err_wrong_gear')); Future.delayed(const Duration(seconds: 2), () => _loadScenario(4)); }
    } else if (_scenario == 5 && currentStep == 3) {
      if (_calculateMachineValue() == "920") _checkScenarioSuccess();
      else { _playSound('error'); _showTempHUD(t('err_wrong_gear')); Future.delayed(const Duration(seconds: 2), () => _loadScenario(5)); }
    }
  }

  void _spawnZeroAt(int colIdx) {
    _playSound('pop');
    _blocks.add(BlockItem(
      'z_${DateTime.now().millisecondsSinceEpoch}', '0', 
      _getColX(colIdx) + COL_W/2 - 25, MAT_Y - 100, 
      colIndex: colIdx
    ));
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    setState(() {
      _step = _getScenarioStepsCount(); 
      _completedScenarios.add(_scenario);
    });
    _playSound('success');
    _scrollToActiveStep();
    if (_scenario == 5) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _showSuccessPopup = true);
      });
    }
  }

  int _getScenarioStepsCount() {
    switch (_scenario) {
      case 1: return 3;
      case 2: return 3;
      case 3: return 3;
      case 4: return 2;
      case 5: return 3;
      default: return 0;
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

  String _calculateMachineValue() {
    double val = 0;
    for (var b in _blocks) {
      if (b.colIndex != null && !b.isLeadingZero) {
        var colIdx = MASTER_COLUMNS.indexWhere((c) => c.id == b.colIndex);
        if (colIdx != -1) {
          val += int.parse(b.digit) * MASTER_COLUMNS[colIdx].val;
        }
      }
    }
    var active = _blocks.where((b) => b.colIndex != null).toList();
    if (active.isEmpty) return "";
    int maxCol = active.map((b) => b.colIndex!).reduce(max);
    if (maxCol == 5) return val.toStringAsFixed(1);
    if (maxCol == 6) return val.toStringAsFixed(2);
    if (maxCol >= 7) return val.toStringAsFixed(3);
    return val.toInt().toString();
  }

  Offset _screenToWorld(Offset screenPos, Size size) {
    double cx = size.width / 2 + _panX;
    double cy = size.height / 2 + _panY;
    return Offset((screenPos.dx - cx) / _zoom, (screenPos.dy - cy) / _zoom);
  }

  bool _hitTestRect(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    Offset pt = _screenToWorld(details.localPosition, size);

    if (_completedScenarios.contains(_scenario) || _isAnimating) return;

    // Fast check for Activate Button on Taps (prevents swallowed clicks)
    if (_hitTestRect(_activateBtnRect.left, _activateBtnRect.top, _activateBtnRect.width, _activateBtnRect.height, pt)) {
      if ((_scenario == 1 && _step == 2) || (_scenario == 2 && _step == 2) || (_scenario == 3 && _step == 2) || (_scenario == 4 && _step == 1) || (_scenario == 5 && (_step == 1 || _step == 3))) {
        if (_activeGear != null) {
          _playSound('whir');
          setState(() {
            _isAnimating = true;
            _animProgress = 0;
          });
        } else {
          _showTempHUD(t('err_wrong_gear'));
        }
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (_completedScenarios.contains(_scenario) || _isAnimating) return;

    bool touchedItem = false;

    // Verify button touches again just in case onTapDown missed
    if (_hitTestRect(_activateBtnRect.left, _activateBtnRect.top, _activateBtnRect.width, _activateBtnRect.height, pt)) {
      if ((_scenario == 1 && _step == 2) || (_scenario == 2 && _step == 2) || (_scenario == 3 && _step == 2) || (_scenario == 4 && _step == 1) || (_scenario == 5 && (_step == 1 || _step == 3))) {
        if (_activeGear != null) {
          _playSound('whir');
          setState(() {
            _isAnimating = true;
            _animProgress = 0;
          });
          return;
        }
      }
    }

    // Check Blocks
    if ((_scenario == 1 || _scenario == 2 || _scenario == 3) && _step == 0) {
      for (int i = _blocks.length - 1; i >= 0; i--) {
        var b = _blocks[i];
        if (b.colIndex == null && _hitTestRect(b.x, b.y, 50, 60, pt)) {
          setState(() {
            b.isDragging = true;
            _activeDragItem = b;
          });
          _playSound('tick');
          touchedItem = true;
          break;
        }
      }
    }

    // Check Gears
    if (!touchedItem && ((_scenario == 1 && _step == 1) || (_scenario == 2 && _step == 1) || (_scenario == 3 && _step == 1) || (_scenario == 4 && _step == 0) || (_scenario == 5 && (_step == 0 || _step == 2)))) {
      for (int i = _gears.length - 1; i >= 0; i--) {
        var g = _gears[i];
        if (!g.inSlot && _hitTestRect(g.x - 40, g.y - 40, 80, 80, pt)) {
          setState(() {
            g.isDragging = true;
            _activeDragItem = g;
          });
          _playSound('tick');
          touchedItem = true;
          break;
        }
      }
    }

    if (!touchedItem) {
      _isDraggingCanvas = true;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      _mouseX = pt.dx;
      _mouseY = pt.dy;

      if (_activeDragItem != null) {
        if (_activeDragItem is BlockItem) {
          (_activeDragItem as BlockItem).x = pt.dx - 25;
          (_activeDragItem as BlockItem).y = pt.dy - 30;
        } else if (_activeDragItem is GearItem) {
          (_activeDragItem as GearItem).x = pt.dx;
          (_activeDragItem as GearItem).y = pt.dy;
        }
      } else if (_isDraggingCanvas) {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.3, 2.0);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    _isDraggingCanvas = false;

    if (_activeDragItem != null) {
      setState(() {
        if (_activeDragItem is BlockItem) {
          var b = _activeDragItem as BlockItem;
          b.isDragging = false;
          double cx = b.x + 25;
          double cy = b.y + 30;

          int dropColId = -1;
          for (var c in _activeCols) {
            double colX = _getColX(c.id);
            if (cx >= colX && cx < colX + COL_W) dropColId = c.id;
          }

          if (dropColId != -1 && cy >= MAT_Y && cy <= MAT_Y + MAT_H) {
            bool isValid = false;
            if (_scenario == 1) {
              if (b.digit == '5' && dropColId == 4) isValid = true;
              else if (b.digit == '7' && dropColId == 5) isValid = true;
            } else if (_scenario == 2) {
              if (b.digit == '2' && dropColId == 3) isValid = true;
              else if (b.digit == '4' && dropColId == 4) isValid = true;
            } else if (_scenario == 3) {
              if (b.digit == '2' && dropColId == 3) isValid = true;
              else if (b.digit == '4' && dropColId == 4) isValid = true;
              else if (b.digit == '6' && dropColId == 5) isValid = true;
              else if (b.digit == '7' && dropColId == 6) isValid = true;
            }

            if (isValid) {
              b.colIndex = dropColId;
              _playSound('snap');
              if ((_scenario == 1 || _scenario == 2 || _scenario == 3) && _step == 0) {
                if (_blocks.every((bk) => bk.colIndex != null)) _advanceStep();
              }
            } else {
              _playSound('error');
              _showTempHUD(t('err_wrong_block'));
            }
          } else {
            _playSound('pop');
          }
        } else if (_activeDragItem is GearItem) {
          var g = _activeDragItem as GearItem;
          g.isDragging = false;

          if (_hitTestRect(GEAR_SLOT_X - 60, GEAR_SLOT_Y - 60, 120, 120, Offset(g.x, g.y))) {
            bool isValid = false;
            if (_scenario == 1 && _step == 1 && g.type == 'x10') isValid = true;
            if (_scenario == 2 && _step == 1 && g.type == '÷100') isValid = true;
            if (_scenario == 3 && _step == 1 && g.type == 'x1000') isValid = true;
            if (_scenario == 4 && _step == 0 && g.type.startsWith('÷')) isValid = true;
            if (_scenario == 5 && (_step == 0 || _step == 2)) isValid = true;

            if (isValid) {
              if (_activeGear != null) _activeGear!.inSlot = false;
              g.inSlot = true;
              g.x = GEAR_SLOT_X;
              g.y = GEAR_SLOT_Y;
              _activeGear = g;
              _burstTime = DateTime.now().millisecondsSinceEpoch;
              _playSound('snap');

              if ((_scenario <= 3) && _step == 1) _advanceStep();
              if (_scenario == 4 && _step == 0) _advanceStep();
              if (_scenario == 5 && (_step == 0 || _step == 2)) _advanceStep();
            } else {
              _playSound('error');
              _showTempHUD(t('err_wrong_gear'));
            }
          } else {
            _playSound('pop');
          }
        }
        _activeDragItem = null;
      });
    }
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 20, 16, 15),
              child: Row(
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back),
                  //   color: Colors.white,
                  //   onPressed: () {
                  //     Navigator.of(context).pop();
                  //   },
                  //   style: IconButton.styleFrom(
                  //     backgroundColor: Colors.black.withOpacity(0.1),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('appTitle'), style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(t('appSubtitle'), style: TextStyle(color: Colors.indigoAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: border, height: 1),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language & Reset
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleLanguage,
                          icon: const Icon(Icons.language, size: 16),
                          label: Text(_lang.toUpperCase()),
                          style: ElevatedButton.styleFrom(backgroundColor: isLight ? Colors.white : const Color(0xFF0F172A), foregroundColor: textPrimary, side: BorderSide(color: border), padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleReset,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text(t('resetBtn')),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent, side: BorderSide(color: Colors.redAccent.withOpacity(0.3)), padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Scenario Dropdown
                  Text(t('selectScenario').toUpperCase(), style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                          if (val != null) {
                            _playSound('pop');
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
                    decoration: BoxDecoration(color: (isLight ? Colors.white : const Color(0xFF0F172A)).withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Text(t('s${_scenario}_obj'), style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Steps
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
            
            // Footer 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
              child: Text(t('footer'), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;
    if (sidebarWidth < 300) sidebarWidth = 300;
    bool isLight = _theme == 'light';
    
    String hudTextRaw = _transientHudMessage.isNotEmpty ? _transientHudMessage : t('s${_scenario}_hud${_step + 1}');
    bool showHud = hudTextRaw.isNotEmpty && hudTextRaw != 's${_scenario}_hud${_step + 1}' && !_completedScenarios.contains(_scenario);

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // CANVAS
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      onTapDown: (d) => _handleTapDown(d, constraints.biggest),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: DecimalShifterPainter(
                          scenario: _scenario, step: _step,
                          zoom: _zoom, panX: _panX, panY: _panY,
                          isLight: isLight,
                          activeCols: _activeCols,
                          blocks: _blocks,
                          gears: _gears,
                          activeGear: _activeGear,
                          isAnimating: _isAnimating,
                          animProgress: _animProgress,
                          gearAngle: _gearAngle,
                          targetValueDisplay: _targetValueDisplay,
                          activeDragItem: _activeDragItem,
                          machineVal: _calculateMachineValue(),
                          btnRect: _activateBtnRect,
                          t: t,
                          colW: COL_W, matX: MAT_X, matY: MAT_Y, matW: MAT_W, matH: MAT_H,
                          palX: PAL_X, palY: PAL_Y, gearSlotX: GEAR_SLOT_X, gearSlotY: GEAR_SLOT_Y,
                          burstTime: _burstTime,
                          isCompleted: _completedScenarios.contains(_scenario),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // HUD OVERLAY (Mini Messages)
            if (showHud)
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth + 40 : 40,
                right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _transientHudMessage.isNotEmpty ? Colors.redAccent.withOpacity(0.95) : const Color(0xFF0F172A).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(30),
                          border: Border(top: BorderSide(color: _transientHudMessage.isNotEmpty ? Colors.red : Colors.indigoAccent, width: 4)),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: (_transientHudMessage.isNotEmpty ? Colors.white : Colors.indigoAccent).withOpacity(0.2), shape: BoxShape.circle),
                              child: Icon(_transientHudMessage.isNotEmpty ? Icons.error_outline : Icons.info_outline, color: _transientHudMessage.isNotEmpty ? Colors.white : Colors.indigoAccent),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                hudTextRaw,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // SCENARIO COMPLETE BANNER (Draggable)
            if (_completedScenarios.contains(_scenario) && _scenario < 5 && !_showSuccessPopup)
              Positioned(
                left: _obsPos?.dx ?? (_isSidebarOpen ? sidebarWidth + (screenWidth - sidebarWidth) / 2 - 200 : screenWidth / 2 - 200),
                top: _obsPos?.dy ?? (MediaQuery.of(context).size.height - 180),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      double currentX = _obsPos?.dx ?? (_isSidebarOpen ? sidebarWidth + (screenWidth - sidebarWidth) / 2 - 200 : screenWidth / 2 - 200);
                      double currentY = _obsPos?.dy ?? (MediaQuery.of(context).size.height - 180);
                      _obsPos = Offset(currentX + details.delta.dx, currentY + details.delta.dy);
                    });
                  },
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 8))]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(2)),
                        ),
                        const Icon(Icons.check_circle, color: Colors.green, size: 36),
                        const SizedBox(height: 12),
                        Text(t('s${_scenario}_final'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
                        const SizedBox(height: 12),
                        Text(t('selectNextMsg'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
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
                color: Colors.orangeAccent, iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact(); _playSound('tick');
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
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
                                const CircleAvatar(radius: 40, backgroundColor: Colors.green, child: Icon(Icons.emoji_events, color: Colors.white, size: 40)),
                                const SizedBox(height: 24),
                                Text(t('successTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                _buildRichText(t('successDesc'), Colors.white70),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () { _playSound('pop'); setState(() => _showSuccessPopup = false); },
                                  icon: const Icon(Icons.check), label: Text(t('doneBtn')),
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                ),
                              ],
                            ),
                            Positioned(
                              top: -16,
                              right: -16,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white70),
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
                          child: const Icon(Icons.settings_suggest, size: 80, color: Colors.indigoAccent),
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
class DecimalShifterPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX, panY;
  final bool isLight;
  final List<MachineCol> activeCols;
  final List<BlockItem> blocks;
  final List<GearItem> gears;
  final GearItem? activeGear;
  final bool isAnimating;
  final double animProgress;
  final double gearAngle;
  final String? targetValueDisplay;
  final Object? activeDragItem;
  final String machineVal;
  final Rect btnRect;
  final Function(String) t;
  final double colW, matX, matY, matW, matH, palX, palY, gearSlotX, gearSlotY;
  final int? burstTime;
  final bool isCompleted;

  DecimalShifterPainter({
    required this.scenario, required this.step, required this.zoom, required this.panX, required this.panY,
    required this.isLight, required this.activeCols, required this.blocks, required this.gears, required this.activeGear,
    required this.isAnimating, required this.animProgress, required this.gearAngle, required this.targetValueDisplay,
    required this.activeDragItem, required this.machineVal, required this.btnRect, required this.t,
    required this.colW, required this.matX, required this.matY, required this.matW, required this.matH,
    required this.palX, required this.palY, required this.gearSlotX, required this.gearSlotY,
    required this.burstTime, required this.isCompleted,
  });

  int _getShiftForGear(String type) {
    if (type == 'x10') return -1;
    if (type == 'x100') return -2;
    if (type == 'x1000') return -3;
    if (type == '÷10') return 1;
    if (type == '÷100') return 2;
    if (type == '÷1000') return 3;
    return 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Background
    canvas.drawRect(Rect.fromLTWH(-2000, -1500, 4000, 3000), Paint()..color = isLight ? const Color(0xFFE2E8F0) : const Color(0xFF264653));

    // Machine Base
    _drawRoundedRect(canvas, matX - 140, matY - 90, matW + 300, matH + 130, 16, const Color(0xFF64748B), Colors.transparent);
    _drawRoundedRect(canvas, matX - 130, matY - 80, matW + 280, matH + 110, 16, const Color(0xFF94A3B8), const Color(0xFF0F172A), 3);
    _drawText(canvas, t('machTitle'), matX - 100, matY - 45, 22, const Color(0xFF1E293B), align: TextAlign.left);

    // Inner Panel
    _drawRoundedRect(canvas, matX - 10, matY - 10, matW + 20, matH - 10, 12, const Color(0xFF1E293B), const Color(0xFF0F172A), 3);

    // Columns
    for (int i = 0; i < activeCols.length; i++) {
      double x = matX + i * colW;
      var c = activeCols[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + 10, matY + 40, colW - 20, matH - 80), const Radius.circular(12)),
        Paint()..color = c.color..style = PaintingStyle.stroke..strokeWidth = 4..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5)
      );
      _drawText(canvas, t(c.labelKey), x + colW / 2, matY + 20, 12, Colors.white);
      canvas.drawOval(Rect.fromCenter(center: Offset(x + colW / 2, matY + matH - 45), width: 50, height: 12), Paint()..color = c.color);
    }

    // Decimal Point
    int onesIdx = activeCols.indexWhere((c) => c.id == 4);
    if (onesIdx != -1 && onesIdx < activeCols.length - 1) {
      canvas.drawRect(Rect.fromLTWH(matX + (onesIdx + 1) * colW - 3, matY - 10, 6, matH - 10), Paint()..color = Colors.redAccent);
    }

    // Display
    String displayStr = machineVal.isEmpty ? "0.00" : machineVal;
    if (scenario == 1 && step == 0 && machineVal.isEmpty) displayStr = "5.7";
    if (scenario == 4 && step == 0 && machineVal.isEmpty) displayStr = "12";
    if (scenario == 5 && step == 0 && machineVal.isEmpty) displayStr = "0.92";

    _drawRoundedRect(canvas, matX + matW - 20, matY - 75, 140, 50, 8, const Color(0xFF1E293B), const Color(0xFF0F172A), 3);
    _drawText(canvas, displayStr, matX + matW + 105, matY - 50, 36, Colors.greenAccent, align: TextAlign.right, isMono: true);

    // Gear Slot
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(gearSlotX - 45, gearSlotY - 45, 90, 110), const Radius.circular(8)), Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 3..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(gearSlotX - 45, gearSlotY - 45, 90, 110), const Radius.circular(8)), Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill);
    _drawText(canvas, t('opLbl'), gearSlotX, gearSlotY - 60, 14, const Color(0xFF1E293B));
    if (activeGear == null) _drawText(canvas, "SLOT", gearSlotX, gearSlotY + 10, 16, const Color(0xFF64748B));

    // Activate Button
    Color btnColor = isAnimating ? Colors.green : Colors.greenAccent;
    double btnOffset = isAnimating ? 4 : 0;
    canvas.drawCircle(Offset(btnRect.center.dx, btnRect.center.dy), 40, Paint()..color = Colors.green[900]!);
    canvas.drawCircle(Offset(btnRect.center.dx, btnRect.center.dy + btnOffset - 5), 40, Paint()..color = btnColor);
    canvas.drawCircle(Offset(btnRect.center.dx, btnRect.center.dy + btnOffset - 5), 40, Paint()..color = Colors.green[800]!..style = PaintingStyle.stroke..strokeWidth = 4);
    _drawText(canvas, t('actLbl'), btnRect.center.dx, btnRect.center.dy + btnOffset - 5, 14, Colors.green[900]!);

    // Target Display
    if (targetValueDisplay != null) {
      _drawRoundedRect(canvas, gearSlotX - 55, matY - 40 - 35, 110, 65, 8, const Color(0xFF1E293B), const Color(0xFF0F172A), 3);
      _drawText(canvas, "TARGET", gearSlotX, matY - 40 - 20, 12, const Color(0xFF94A3B8));
      _drawText(canvas, targetValueDisplay!, gearSlotX, matY - 40 + 10, 24, Colors.amberAccent, isMono: true);
    }

    // Palette Area
    if (step == 0 || scenario == 4 || scenario == 5) {
      _drawRoundedRect(canvas, matX - 270, matY - 20, 110, 340, 10, const Color(0xFF64748B), const Color(0xFF0F172A), 2);
      _drawText(canvas, "PALETTE", matX - 215, matY, 12, const Color(0xFF1E293B));
    }

    // Robot arms if animating
    if (isAnimating && activeGear != null) {
      int shift = _getShiftForGear(activeGear!.type);
      for (var b in blocks) {
        if (b.colIndex != null) {
          double dir = shift.sign.toDouble();
          double armX = dir < 0 ? b.x + 50 : b.x - 5;
          double armY = b.y + 30;
          canvas.save();
          Paint armP = Paint()..color = const Color(0xFF94A3B8);
          Paint armSp = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 2;
          
          if (dir < 0) {
            canvas.drawCircle(Offset(armX + 40, armY), 8, armP); canvas.drawCircle(Offset(armX + 40, armY), 8, armSp);
            canvas.drawRect(Rect.fromLTWH(armX, armY - 4, 40, 8), armP); canvas.drawRect(Rect.fromLTWH(armX, armY - 4, 40, 8), armSp);
          } else {
            canvas.drawCircle(Offset(armX - 40, armY), 8, armP); canvas.drawCircle(Offset(armX - 40, armY), 8, armSp);
            canvas.drawRect(Rect.fromLTWH(armX - 40, armY - 4, 40, 8), armP); canvas.drawRect(Rect.fromLTWH(armX - 40, armY - 4, 40, 8), armSp);
          }
          canvas.restore();
        }
      }
    }

    // Burst Animation for Operator Gear snap
    if (burstTime != null && DateTime.now().millisecondsSinceEpoch - burstTime! < 1000) {
      double p = (DateTime.now().millisecondsSinceEpoch - burstTime!) / 1000.0;
      canvas.save();
      canvas.translate(gearSlotX, gearSlotY);
      Paint burstP = Paint()..color = Colors.yellowAccent.withOpacity(1.0 - p)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        double angle = (i * pi) / 4 + (p * 0.5);
        canvas.drawLine(
          Offset(cos(angle) * 50, sin(angle) * 50),
          Offset(cos(angle) * (65 + p * 20), sin(angle) * (65 + p * 20)),
          burstP,
        );
      }
      _drawText(canvas, t('clickLbl'), 50, -50 - p * 20, 24, Colors.yellowAccent.withOpacity(1.0 - p));
      canvas.restore();
    }

    // Gears
    for (var g in gears) {
      if (activeDragItem != g && !g.inSlot) _drawGear(canvas, g.x, g.y, g.type, 0);
    }
    if (activeGear != null) _drawGear(canvas, activeGear!.x, activeGear!.y, activeGear!.type, gearAngle);

    // Blocks
    for (var b in blocks) {
      if (activeDragItem != b) {
        double shiftDir = (isAnimating && b.colIndex != null && activeGear != null) ? _getShiftForGear(activeGear!.type).toDouble() : 0;
        _drawBlock(canvas, b.x, b.y, b.digit, b.isLeadingZero, shiftDir);
      }
    }

    // Active Drag Item
    if (activeDragItem != null) {
      if (activeDragItem is BlockItem) {
        var b = activeDragItem as BlockItem;
        _drawBlock(canvas, b.x, b.y, b.digit, b.isLeadingZero, 0);
      } else if (activeDragItem is GearItem) {
        var g = activeDragItem as GearItem;
        _drawGear(canvas, g.x, g.y, g.type, 0);
      }
    }

    // Scenario 1 Completion Speech Bubble
    if (scenario == 1 && isCompleted) {
      canvas.save();
      canvas.translate(matX + matW + 110, matY + matH - 40);
      
      Paint bubbleFill = Paint()..color = Colors.white;
      Paint bubbleStroke = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
        
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, -60, 240, 110), const Radius.circular(10)), bubbleFill);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, -60, 240, 110), const Radius.circular(10)), bubbleStroke);
      
      Path tail = Path()..moveTo(0, 0)..lineTo(-25, 20)..lineTo(0, 20)..close();
      canvas.drawPath(tail, bubbleFill);
      canvas.drawPath(tail, bubbleStroke);
      
      _drawText(canvas, t('s1_bubble1'), 120, -35, 14, const Color(0xFF0F172A));
      _drawText(canvas, t('s1_bubble2'), 120, -10, 14, const Color(0xFF0F172A));
      _drawText(canvas, t('s1_bubble3'), 120, 15, 14, const Color(0xFF0F172A));
      _drawText(canvas, t('s1_bubble4'), 120, 40, 14, const Color(0xFF0F172A));
      
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawBlock(Canvas canvas, double x, double y, String digit, bool isZero, double shiftDir) {
    canvas.save();
    
    if (shiftDir != 0) {
      double dir = shiftDir.sign;
      Paint trailP = Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 3;
      Path p = Path();
      p.moveTo(x + 25, y + 10); p.lineTo(x + 25 - dir * 40, y + 10);
      p.moveTo(x + 25, y + 30); p.lineTo(x + 25 - dir * 60, y + 30);
      p.moveTo(x + 25, y + 50); p.lineTo(x + 25 - dir * 40, y + 50);
      canvas.drawPath(p, trailP);
    }

    Color color = isZero ? Colors.white54 : Colors.white;
    _drawRoundedRect(canvas, x + 4, y + 4, 50, 60, 6, const Color(0xFF64748B), Colors.transparent);
    _drawRoundedRect(canvas, x, y, 50, 60, 6, color, const Color(0xFF0F172A), 2);
    _drawText(canvas, digit, x + 25, y + 30, 36, const Color(0xFF0F172A));

    canvas.restore();
  }

  void _drawGear(Canvas canvas, double x, double y, String label, double angle) {
    canvas.save(); canvas.translate(x, y); canvas.rotate(angle);
    
    Color color = Colors.indigoAccent;
    Path p = Path();
    int teeth = 8;
    double radius = 40;
    double innerRad = radius * 0.75;
    
    for (int i = 0; i < teeth; i++) {
      double a1 = (i * pi * 2) / teeth;
      double a2 = a1 + (pi * 2) / teeth * 0.4;
      double a3 = a1 + (pi * 2) / teeth * 0.6;
      double a4 = a1 + (pi * 2) / teeth;
      
      if (i == 0) p.moveTo(cos(a1) * innerRad, sin(a1) * innerRad);
      p.lineTo(cos(a1) * radius, sin(a1) * radius);
      p.lineTo(cos(a2) * radius, sin(a2) * radius);
      p.lineTo(cos(a3) * innerRad, sin(a3) * innerRad);
      p.lineTo(cos(a4) * innerRad, sin(a4) * innerRad);
    }
    p.close();
    canvas.drawPath(p, Paint()..color = color);
    canvas.drawCircle(Offset.zero, innerRad, Paint()..color = color);
    canvas.drawCircle(Offset.zero, radius * 0.6, Paint()..color = Colors.white);
    
    canvas.rotate(-angle);
    _drawText(canvas, label, 0, 0, 22, color);
    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double strokeW = 1.0]) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && strokeW > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double fontSize, Color color, {TextAlign align = TextAlign.center, bool isMono = false}) {
    TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: isMono ? 'monospace' : 'Plus Jakarta Sans')),
      textDirection: TextDirection.ltr, textAlign: align,
    );
    tp.layout();
    double dx = align == TextAlign.center ? x - tp.width / 2 : (align == TextAlign.right ? x - tp.width : x);
    double dy = y - tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant DecimalShifterPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "The Decimal Shifter Machine",
    'appTitle': "The Decimal Shifter Machine",
    'appSubtitle': "Class 7 • ANOTHER PEEK BEYOND THE POINT",
    'enterLab': "Enter Simulation",
    'resetBtn': "Reset",
    'doneBtn': "Done",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'selectNextMsg': "Please select another scenario from the dropdown above.",
    'footer': "© ZeroScienceLab - Fall in love with math and Science",
    'successTitle': "Activity Completed!",
    'successDesc': "You have successfully mastered multiplying and dividing decimals by powers of 10.",
    'machTitle': "DECIMAL SHIFTER",
    'opLbl': "Operator",
    'actLbl': "ACTIVATE",
    'col_10k': "Ten Thousands",
    'col_1k': "Thousands",
    'col_100': "Hundreds",
    'col_10': "Tens",
    'col_1': "Ones",
    'col_01': "Tenths",
    'col_001': "Hundredths",
    'col_0001': "Thousandths",
    'clickLbl': "CLICK!",
    
    // Bubble Texts
    's1_bubble1': "Multiplying 5.7 by 10",
    's1_bubble2': "shifted the digits one",
    's1_bubble3': "place to the left.",
    's1_bubble4': "The result is 57.",
    
    // Error Logs HUD
    'err_wrong_block': "Place the block in the correct column based on its place value.",
    'err_wrong_gear': "Incorrect Gear. Try looking at how many places the digits need to move.",

    // Scenario 1
    's1_title': "1. The Up-Shift: Multiplying by 10",
    's1_obj': "To visually understand that multiplying a decimal by 10 shifts each of its digits one place to the left, increasing its value.",
    's1_step1_task': "The number 5.7 is displayed. DRAG the '5' digit block and DROP it into the 'Ones' column. DRAG the '7' digit block and DROP it into the 'Tenths' column.",
    's1_step1_out': "<b>Observation:</b> The decimal 5.7 is placed on the machine.<br/><b>Learning:</b> Each digit has a specific place value.",
    's1_step2_task': "A set of 'Operator Gears' is available. DRAG the 'x10' gear and ATTACH it to the gear slot on the side of the machine.",
    's1_step2_out': "<b>Observation:</b> The 'x10' operator gear is attached.<br/><b>Learning:</b> Multiplying by 10 means the value increases 10 times.",
    's1_step3_task': "CLICK the large green 'ACTIVATE' button on the machine.",
    's1_step3_out': "<b>Observation:</b> The digits shifted exactly one place to the left.<br/><b>Learning:</b> Multiplying by 10 increases the value, shifting 5.7 to 57.",
    's1_final': "Multiplying 5.7 by 10 shifted the digits one place to the left. The result is 57.",
    's1_hud1': "DRAG '5' to Ones and '7' to Tenths.",
    's1_hud2': "DRAG the 'x10' gear and ATTACH it.",
    's1_hud3': "CLICK 'ACTIVATE'.",

    // Scenario 2
    's2_title': "2. The Down-Shift: Dividing by 100",
    's2_obj': "To visually understand that dividing a number by 100 shifts its digits two places to the right, requiring placeholder zeros if necessary.",
    's2_step1_task': "DRAG the '2' digit block into the 'Tens' column and the '4' digit block into the 'Ones' column.",
    's2_step1_out': "<b>Observation:</b> The whole number 24 is placed on the machine.<br/><b>Learning:</b> 24 consists of 2 Tens and 4 Ones.",
    's2_step2_task': "DRAG the '÷100' gear and ATTACH it to the gear slot.",
    's2_step2_out': "<b>Observation:</b> The '÷100' operator gear is attached.<br/><b>Learning:</b> Dividing by 100 will decrease the value to one-hundredth.",
    's2_step3_task': "CLICK the 'ACTIVATE' button.",
    's2_step3_out': "<b>Observation:</b> The digits shifted two places to the right. A placeholder '0' appeared.<br/><b>Learning:</b> Dividing by 100 shifts digits 2 places right, resulting in 0.24.",
    's2_final': "Dividing 24 by 100 shifted the digits two places to the right. A '0' was added in the Ones place. The result is 0.24.",
    's2_hud1': "Drag '2' to Tens and '4' to Ones.",
    's2_hud2': "Drag the '÷100' gear and attach it.",
    's2_hud3': "Click ACTIVATE.",

    // Scenario 3
    's3_title': "3. The Big Leap: Multiplying and Adding Zeros",
    's3_obj': "To understand that when digits shift past the decimal point during multiplication, placeholder zeros may be needed.",
    's3_step1_task': "DRAG and DROP digit blocks '2', '4', '6', and '7' into 'Tens', 'Ones', 'Tenths', and 'Hundredths'.",
    's3_step1_out': "<b>Observation:</b> The number 24.67 is placed on the machine.<br/><b>Learning:</b> The digits span from Tens down to Hundredths.",
    's3_step2_task': "DRAG the 'x1000' gear and ATTACH it to the gear slot.",
    's3_step2_out': "<b>Observation:</b> The 'x1000' operator gear is attached.<br/><b>Learning:</b> Multiplying by 1000 will drastically increase the value.",
    's3_step3_task': "CLICK the 'ACTIVATE' button.",
    's3_step3_out': "<b>Observation:</b> The digits shifted three places left, crossing the decimal point.<br/><b>Learning:</b> Required an extra '0' to maintain magnitude, making it 24670.",
    's3_final': "Multiplying 24.67 by 1000 shifted the digits three places to the left. A '0' was added to hold the Ones place. The result is 24670.",
    's3_hud1': "Drag 2, 4, 6, 7 to build 24.67.",
    's3_hud2': "Drag the 'x1000' gear and attach it.",
    's3_hud3': "Click ACTIVATE.",

    // Scenario 4
    's4_title': "4. Challenge: The Precision Drop",
    's4_obj': "Given a starting number (12) and a target result (0.012), select the correct division operator.",
    's4_step1_task': "The machine shows '12'. The target is '0.012'. DRAG the correct division gear from the panel and ATTACH it.",
    's4_step1_out': "<b>Observation:</b> Start number is 12, Target is 0.012.<br/><b>Learning:</b> The value moved 3 places to the right, meaning division by 1000.",
    's4_step2_task': "CLICK the 'ACTIVATE' button to test if your gear achieves the target.",
    's4_step2_out': "<b>Observation:</b> The ÷1000 gear shifted the digits correctly.<br/><b>Learning:</b> Dividing by 1000 shifts the digits three places to the right.",
    's4_final': "Correct! Dividing by 1000 shifts the digits three places to the right.",
    's4_hud1': "Target: 0.012. Drag the correct gear to achieve this.",
    's4_hud2': "Click ACTIVATE to test your gear.",

    // Scenario 5
    's5_title': "5. Challenge: The Two-Step Transformation",
    's5_obj': "To achieve a target result (920) from (0.92) by applying two consecutive operations.",
    's5_step1_task': "DRAG your first chosen gear and ATTACH it. Then CLICK 'ACTIVATE'.",
    's5_step1_out': "<b>Observation:</b> Start number is 0.92, Target is 920.<br/><b>Learning:</b> The first step increased the number.",
    's5_step2_task': "DRAG your second chosen gear and ATTACH it.",
    's5_step2_out': "<b>Observation:</b> Second gear attached to reach the target.<br/><b>Learning:</b> Two consecutive operations combine their effects.",
    's5_step3_task': "CLICK 'ACTIVATE' again.",
    's5_step3_out': "<b>Observation:</b> The digits shifted a total of three places left.<br/><b>Learning:</b> Using two steps is mathematically identical to a single x1000 operation.",
    's5_final': "Excellent! You used two steps to reach the target. This is the same as multiplying by 1000!",
    's5_hud1': "Target: 920. Drag your FIRST operation gear.",
    's5_hud2': "Click ACTIVATE.",
    's5_hud3': "Drag SECOND operation gear.",
    's5_hud4': "Click ACTIVATE.",
  },
  'hi': {
    'shutterTitle': "दशमलव शिफ्टर मशीन",
    'appTitle': "दशमलव शिफ्टर मशीन",
    'appSubtitle': "कक्षा 7 • दशमलव के पार एक और नज़र",
    'enterLab': "सिमुलेशन दर्ज करें",
    'resetBtn': "रीसेट",
    'doneBtn': "पूर्ण",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'selectNextMsg': "कृपया ऊपर दिए गए ड्रॉपडाउन से एक और परिदृश्य चुनें।",
    'footer': "© ZeroScienceLab - Fall in love with math and Science",
    'successTitle': "गतिविधि पूरी हुई!",
    'successDesc': "आपने 10 की घातों से दशमलवों को गुणा और भाग करना सफलतापूर्वक सीख लिया है।",
    'machTitle': "दशमलव शिफ्टर",
    'opLbl': "ऑपरेटर",
    'actLbl': "सक्रिय करें",
    'col_10k': "दस हज़ार",
    'col_1k': "हज़ार",
    'col_100': "सैकड़ा",
    'col_10': "दहाई",
    'col_1': "इकाई",
    'col_01': "दशवांश",
    'col_001': "शतांश",
    'col_0001': "सहस्रांश",
    'clickLbl': "क्लिक!",
    
    's1_bubble1': "5.7 को 10 से गुणा",
    's1_bubble2': "करने पर अंक एक",
    's1_bubble3': "स्थान बाईं ओर खिसक गए।",
    's1_bubble4': "परिणाम 57 है।",

    'err_wrong_block': "ब्लॉक को उसके स्थानीय मान के आधार पर सही कॉलम में रखें।",
    'err_wrong_gear': "गलत गियर। जांचें कि अंकों को कितने स्थान आगे बढ़ना है।",

    's1_title': "1. 10 से गुणा करना",
    's1_obj': "यह समझना कि किसी दशमलव को 10 से गुणा करने पर उसके अंक बाईं ओर कैसे शिफ्ट होते हैं।",
    's1_step1_task': "संख्या 5.7 प्रदर्शित है। '5' को 'इकाई' और '7' को 'दशवांश' में खींचें।",
    's1_step1_out': "<b>अवलोकन:</b> दशमलव 5.7 मशीन पर रखा गया है।<br/><b>सीख:</b> प्रत्येक अंक का विशिष्ट स्थानीय मान है।",
    's1_step2_task': "'x10' गियर खींचें और इसे मशीन से जोड़ें।",
    's1_step2_out': "<b>अवलोकन:</b> 'x10' गियर जुड़ा हुआ है।<br/><b>सीख:</b> 10 से गुणा करने का अर्थ है मान 10 गुना बढ़ेगा।",
    's1_step3_task': "'सक्रिय करें' बटन पर क्लिक करें।",
    's1_step3_out': "<b>अवलोकन:</b> अंक ठीक एक स्थान बाईं ओर खिसक गए।<br/><b>सीख:</b> 10 से गुणा करने पर मान बढ़ता है, 5.7 से 57 हो जाता है।",
    's1_final': "5.7 को 10 से गुणा करने पर अंक एक स्थान बाईं ओर खिसक गए। परिणाम 57 है।",
    's1_hud1': "'5' को इकाई में और '7' को दशवांश में खींचें।",
    's1_hud2': "'x10' गियर खींचें और इसे मशीन से जोड़ें।",
    's1_hud3': "'सक्रिय करें' बटन पर क्लिक करें।",

    's2_title': "2. 100 से भाग देना",
    's2_obj': "यह समझना कि 100 से भाग देने पर अंक दो स्थान दाईं ओर शिफ्ट होते हैं।",
    's2_step1_task': "'2' को 'दहाई' और '4' को 'इकाई' कॉलम में खींचें।",
    's2_step1_out': "<b>अवलोकन:</b> 24 मशीन पर रखा गया है।<br/><b>सीख:</b> 24 में 2 दहाई और 4 इकाई हैं।",
    's2_step2_task': "गियर स्लॉट में '÷100' गियर खींचें और लगाएँ।",
    's2_step2_out': "<b>अवलोकन:</b> '÷100' गियर जुड़ा हुआ है।<br/><b>सीख:</b> 100 से भाग देने पर मान घटेगा।",
    's2_step3_task': "'सक्रिय करें' बटन पर क्लिक करें।",
    's2_step3_out': "<b>अवलोकन:</b> अंक दाईं ओर खिसक गए। एक '0' दिखाई दिया।<br/><b>सीख:</b> 100 से भाग देने पर अंक 2 स्थान दाईं ओर खिसकते हैं।",
    's2_final': "24 को 100 से भाग देने पर अंक दो स्थान दाईं ओर खिसक गए। परिणाम 0.24 है।",
    's2_hud1': "'2' को दहाई और '4' को इकाई में खींचें।",
    's2_hud2': "'÷100' गियर खींचें और इसे जोड़ें।",
    's2_hud3': "सक्रिय करें पर क्लिक करें।",

    's3_title': "3. गुणा और शून्य जोड़ना",
    's3_obj': "यह समझना कि गुणा करते समय दशमलव बिंदु से आगे जाने पर शून्य की आवश्यकता क्यों होती है।",
    's3_step1_task': "'2', '4', '6', और '7' ब्लॉकों को उनके सही कॉलम में खींचें।",
    's3_step1_out': "<b>अवलोकन:</b> 24.67 को मशीन पर रखा गया है।<br/><b>सीख:</b> अंक दहाई से शतांश तक फैले हैं।",
    's3_step2_task': "गियर स्लॉट में 'x1000' गियर खींचें और लगाएँ।",
    's3_step2_out': "<b>अवलोकन:</b> 'x1000' गियर जुड़ा हुआ है।<br/><b>सीख:</b> 1000 से गुणा करने पर मान में भारी वृद्धि होगी।",
    's3_step3_task': "'सक्रिय करें' बटन पर क्लिक करें।",
    's3_step3_out': "<b>अवलोकन:</b> अंक दशमलव बिंदु को पार करते हुए बाईं ओर खिसक गए।<br/><b>सीख:</b> इकाई कॉलम में '0' की आवश्यकता थी।",
    's3_final': "24.67 को 1000 से गुणा करने पर अंक तीन स्थान बाईं ओर खिसक गए। परिणाम 24670 है।",
    's3_hud1': "24.67 बनाने के लिए 2, 4, 6, 7 को खींचें।",
    's3_hud2': "'x1000' गियर खींचें और लगाएँ।",
    's3_hud3': "सक्रिय करें पर क्लिक करें।",

    's4_title': "4. चुनौती: सटीक भाग",
    's4_obj': "प्रारंभिक संख्या (12) और लक्ष्य (0.012) को देखकर सही गियर चुनें।",
    's4_step1_task': "मशीन 12 दिखाती है। लक्ष्य 0.012 है। सही भाग गियर खींचें और लगाएँ।",
    's4_step1_out': "<b>अवलोकन:</b> प्रारंभिक संख्या 12 है, लक्ष्य 0.012 है।<br/><b>सीख:</b> यह 3 स्थान दाईं ओर खिसका, यानी 1000 से भाग।",
    's4_step2_task': "अपने गियर का परीक्षण करने के लिए 'सक्रिय करें' पर क्लिक करें।",
    's4_step2_out': "<b>अवलोकन:</b> गियर ने अंकों को सही ढंग से शिफ्ट कर दिया।<br/><b>सीख:</b> 1000 से भाग देने पर अंक दाईं ओर खिसकते हैं।",
    's4_final': "सही! 1000 से भाग देने पर अंक 3 स्थान दाईं ओर खिसकते हैं।",
    's4_hud1': "लक्ष्य: 0.012. सही गियर खींचें।",
    's4_hud2': "सक्रिय करें पर क्लिक करें।",

    's5_title': "5. चुनौती: दो-चरणीय परिवर्तन",
    's5_obj': "दो लगातार ऑपरेशनों का उपयोग करके 0.92 से 920 तक पहुँचना।",
    's5_step1_task': "अपना पहला गियर खींचें और लगाएँ। फिर 'सक्रिय करें' क्लिक करें।",
    's5_step1_out': "<b>अवलोकन:</b> प्रारंभिक संख्या 0.92, लक्ष्य 920।<br/><b>सीख:</b> पहले चरण ने संख्या में वृद्धि की।",
    's5_step2_task': "अपना दूसरा गियर खींचें और लगाएँ।",
    's5_step2_out': "<b>अवलोकन:</b> दूसरा गियर लगाया गया।<br/><b>सीख:</b> दो लगातार ऑपरेशन उनके प्रभावों को मिलाते हैं।",
    's5_step3_task': "फिर से 'सक्रिय करें' क्लिक करें।",
    's5_step3_out': "<b>अवलोकन:</b> अंक कुल मिलाकर तीन स्थान बाईं ओर खिसक गए।<br/><b>सीख:</b> दो चरणों का उपयोग एकल x1000 के समान है।",
    's5_final': "बहुत बढ़िया! आपने लक्ष्य तक पहुंचने के लिए दो चरणों का उपयोग किया। यह 1000 से गुणा करने के समान है!",
    's5_hud1': "लक्ष्य: 920. अपना पहला गियर खींचें।",
    's5_hud2': "सक्रिय करें पर क्लिक करें।",
    's5_hud3': "अपना दूसरा गियर खींचें।",
    's5_hud4': "सक्रिय करें पर क्लिक करें।",
  },
  };