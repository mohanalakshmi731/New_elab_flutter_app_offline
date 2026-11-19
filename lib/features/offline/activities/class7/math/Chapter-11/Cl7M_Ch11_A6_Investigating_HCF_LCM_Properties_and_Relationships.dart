// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InvestigatingHCFLCMPropertiesandRelationshipsApp());
}

class InvestigatingHCFLCMPropertiesandRelationshipsApp extends StatelessWidget {
  const InvestigatingHCFLCMPropertiesandRelationshipsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Factors & Multiples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      home: const InvestigatingHCFLCMPropertiesandRelationships(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class BlockEntity {
  String id;
  double x, y, startX, startY;
  int val;
  bool hidden;
  bool isDragging;

  BlockEntity(this.id, this.val, this.x, this.y)
      : startX = x,
        startY = y,
        hidden = false,
        isDragging = false;
}

// ==========================================
// MAIN WIDGET
// ==========================================
class InvestigatingHCFLCMPropertiesandRelationships extends StatefulWidget {
  const InvestigatingHCFLCMPropertiesandRelationships({super.key});

  @override
  State<InvestigatingHCFLCMPropertiesandRelationships> createState() =>
      _InvestigatingHCFLCMPropertiesandRelationshipsState();
}

class _InvestigatingHCFLCMPropertiesandRelationshipsState
    extends State<InvestigatingHCFLCMPropertiesandRelationships>
    with TickerProviderStateMixin {
  // Application State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;

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
  String? _activeDragId;
  Offset _dragOffset = Offset.zero;
  String? _activeSlider;

  // Scenario 1 State
  int? _s1ActiveTile;
  bool _s1Dropped = false;
  bool _s1LargestHover = false;

  // Scenario 2 State
  bool _s2Running = false;
  double _s2RotA = 0;
  double _s2RotB = 0;
  int _s2CountA = 0;
  int _s2CountB = 0;
  bool _s2ShowMultiples = false;
  List<Map<String, double>> _s2Stars = [];

  // Scenario 3 State
  List<BlockEntity> _s3Blocks = [];
  List<BlockEntity> _s3OutBlocks = [];
  int _s3M1Val = 0;
  bool _s3M1Ready = false;
  int _s3AnalyzerVal = 0;
  bool _s3AnalyzerReady = false;
  int _s3M2Val = 0;
  bool _s3M2Ready = false;

  // Scenario 4 State
  double _s4BreakerSize = 4.0;
  bool _s4IsBroken = false;
  bool _s4AnsCorrect = false;

  // Scenario 5 State
  bool _s5Playing = false;
  double _s5Time = 0.0;
  int _s5InputVal = 0;

  // Audio players
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

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
    
    // Init Stars
    for (int i = 0; i < 120; i++) {
      _s2Stars.add({
        'x': -1000 + Random().nextDouble() * 2000,
        'y': -1000 + Random().nextDouble() * 2000,
        'r': Random().nextDouble() * 2.5,
        'a': Random().nextDouble()
      });
    }

    _loadScenario(1);

    // Main Game Loop
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
      } else if (type == 'pop' || type == 'tick' || type == 'snap' || type == 'weld') {
        await _clickPlayer.play(AssetSource(_clickUrl), volume: 0.5);
      } else if (type == 'success') {
        await _successPlayer.play(AssetSource(_successUrl), volume: 0.5);
      } else if (type == 'error') {
        await _errorPlayer.play(AssetSource(_errorUrl), volume: 0.5);
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
      _activeDragId = null;
      _activeSlider = null;

      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
      _baseZoom = 1.0;
      _basePan = Offset.zero;
      _showSuccessPopup = false;

      // Reset S1
      _s1ActiveTile = null;
      _s1Dropped = false;
      _s1LargestHover = false;
      
      // Reset S2
      _s2Running = false;
      _s2RotA = 0;
      _s2RotB = 0;
      _s2CountA = 0;
      _s2CountB = 0;
      _s2ShowMultiples = false;

      // Reset S3
      _s3M1Val = 0; _s3M1Ready = false;
      _s3AnalyzerVal = 0; _s3AnalyzerReady = false;
      _s3M2Val = 0; _s3M2Ready = false;
      _s3Blocks = [
        BlockEntity('b6', 6, -320, -150),
        BlockEntity('b8', 8, -240, -150)
      ];
      _s3OutBlocks = [];

      // Reset S4
      _s4BreakerSize = 4.0;
      _s4IsBroken = false;
      _s4AnsCorrect = false;

      // Reset S5
      _s5Playing = false;
      _s5Time = 0.0;
      _s5InputVal = 0;
    });
    _playSound('pop');
    _scrollToActiveStep();
  }

  void _tick() {
    setState(() {
      // S2 Gear Animation
      if (_scenario == 2 && _s2Running) {
        _s2RotA += 0.05;
        _s2RotB -= 0.05 * (6 / 8);
        _s2CountA = ((_s2RotA.abs() / (2 * pi)) * 6).floor();
        _s2CountB = ((_s2RotB.abs() / (2 * pi)) * 8).floor();

        if (_s2CountA >= 24) {
          _s2Running = false;
          _s2RotA = (24 / 6) * 2 * pi;
          _s2RotB = -(24 / 8) * 2 * pi;
          _s2CountA = 24;
          _s2CountB = 24;
          _playSound('success');
          if (_step == 1) _advanceStep();
        }
      }

      // S5 Timeline Animation
      if (_scenario == 5 && _s5Playing) {
        _s5Time += 0.1;
        if (_s5Time >= 40) {
          _s5Time = 40;
          _s5Playing = false;
        }
      }
    });
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _checkScenarioSuccess() {
    setState(() {
      int totalSteps = (_scenario == 1) ? 4 : (_scenario == 2) ? 3 : (_scenario == 3) ? 4 : (_scenario == 4) ? 3 : 3;
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
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    Offset pt = _screenToWorld(details.localPosition, size);

    if (_scenario == 1) {
      double tx = 60, ty = -180, tw = 80;
      // Reset Button - Large generous hitbox
      if (_s1Dropped && _step < 3) {
        if (_hitTestBox(tx + tw, ty - 10, 120, 60, pt)) {
          setState(() {
            _s1ActiveTile = null;
            _s1Dropped = false;
          });
          _playSound('pop');
          return;
        }
      }
      // Largest tile button
      if (_step == 3) {
        double px = tx + tw + 20, py = ty + 40;
        if (_hitTestBox(px + 20, py + 100, 200, 80, pt)) {
          _advanceStep();
          _checkScenarioSuccess();
          return;
        }
      }
    } else if (_scenario == 2) {
      double ax = -120;
      double bx = ax + 80 + 106.66 + 8;
      // Run btn
      if (_step == 0 && _hitTestBox(ax + (bx - ax) / 2 - 80, -50 + 130, 160, 90, pt)) {
        setState(() => _s2Running = true);
        _playSound('tick');
        _advanceStep();
        return;
      }
      // Show Multiples btn
      if (_step == 2 && _hitTestBox(ax + (bx - ax) / 2 - 110, -50 + 130, 220, 90, pt)) {
        setState(() => _s2ShowMultiples = true);
        _playSound('success');
        _advanceStep();
        _checkScenarioSuccess();
        return;
      }
    } else if (_scenario == 4) {
      double slX = -150, slY = -180;
      // Break button
      if (_hitTestBox(-80, slY + 10, 160, 85, pt)) {
        setState(() => _s4IsBroken = true);
        _playSound('snap');
        if (_step == 0 && _s4BreakerSize == 4) {
          _advanceStep();
        } else if (_step == 1 && _s4BreakerSize == 6) {
          _advanceStep();
        } else if (_s4BreakerSize != 6) {
          _playSound('error');
        }
        return;
      }
    } else if (_scenario == 5) {
      if (_step <= 1 && _hitTestBox(-80, 270, 160, 90, pt)) {
        setState(() => _s5Playing = !_s5Playing);
        _playSound('tick');
        if (_step == 0) _advanceStep();
        return;
      }
      if (_step == 2) {
        double bx = 200, by = 280;
        // Increase time area
        if (_hitTestBox(bx - 150, by, 180, 80, pt)) {
          setState(() {
            _s5InputVal = (_s5InputVal + 3) % 42;
          });
          _playSound('tick');
          return;
        }
        // Submit
        if (_hitTestBox(bx + 10, by, 120, 80, pt)) {
          if (_s5InputVal == 36) {
            _advanceStep();
            _checkScenarioSuccess();
          } else {
            _playSound('error');
          }
          return;
        }
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    _basePan = Offset(_panX, _panY);
    Offset pt = _screenToWorld(details.localFocalPoint, size);

    if (_scenario == 1) {
      double tx = 60, ty = -180, tw = 80;
      List<int> tiles = [1, 2, 3, 4, 6];
      for (int i = 0; i < tiles.length; i++) {
        int tSize = tiles[i];
        double by = ty + 80 + i * 55;
        double bx = tx + tw / 2;
        if (_hitTestBox(bx - 50, by - 50, 100, 100, pt)) { // Very generous hitboxes
          if ((_step == 0 && tSize == 3) || (_step == 1 && tSize == 4) || (_step == 2 && tSize == 2)) {
            _activeDragId = 's1_$tSize';
            _dragOffset = Offset(bx - pt.dx, by - pt.dy);
            _playSound('tick');
            return;
          } else {
            _playSound('error');
          }
        }
      }
    } else if (_scenario == 3) {
      for (var b in _s3Blocks) {
        if (!b.hidden && _hitTestBox(b.x - 50, b.y - 50, 100, 100, pt)) {
          _activeDragId = b.id;
          _dragOffset = Offset(b.x - pt.dx, b.y - pt.dy);
          b.isDragging = true;
          _playSound('tick');
          return;
        }
      }
      for (var b in _s3OutBlocks) {
        if (!b.hidden && _hitTestBox(b.x - 50, b.y - 50, 100, 100, pt)) {
          _activeDragId = b.id;
          _dragOffset = Offset(b.x - pt.dx, b.y - pt.dy);
          b.isDragging = true;
          _playSound('tick');
          return;
        }
      }
    } else if (_scenario == 4) {
      double slX = -150, slY = -180, slW = 300;
      double handleX = slX + ((_s4BreakerSize - 1) / 17) * slW;
      
      if (_step == 2 && _hitTestBox(handleX - 50, slY - 50, 100, 100, pt) && _s4BreakerSize == 6) {
        _activeDragId = 's4_ans';
        _dragOffset = Offset(handleX - pt.dx, slY - pt.dy);
        _playSound('tick');
        return;
      } else if (_hitTestBox(slX - 80, slY - 80, slW + 160, 190, pt)) {
        _activeSlider = 's4';
        return;
      }
    } else if (_scenario == 5) {
      double tlX = -450, tlY = 130, tlW = 900, tlH = 140;
      if (_hitTestBox(tlX - 20, tlY - 20, tlW + 40, tlH + 40, pt)) {
        _activeSlider = 's5';
        return;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _screenToWorld(details.localFocalPoint, size);
    setState(() {
      _mouseX = pt.dx;
      _mouseY = pt.dy;

      if (_scenario == 1 && _step == 3) {
        double tx = 60, ty = -180, tw = 80;
        double px = tx + tw + 20, py = ty + 40;
        _s1LargestHover = _hitTestBox(px + 20, py + 100, 200, 80, pt);
      }

      if (_activeSlider != null) {
        if (_activeSlider == 's4') {
          double slX = -150, slW = 300;
          double relX = pt.dx - slX;
          double rawVal = (relX / slW) * 17 + 1;
          _s4BreakerSize = max(1.0, min(18.0, rawVal.roundToDouble()));
          _s4IsBroken = false;
        } else if (_activeSlider == 's5') {
          double tlX = -450, tlW = 900;
          double pxPerSec = (tlW - 100) / 40;
          double startX = tlX + 80;
          double relX = pt.dx - startX;
          _s5Time = max(0.0, min(40.0, relX / pxPerSec));
          if (_step == 1 && (_s5Time - 36).abs() < 0.5) {
            _s5Time = 36;
            _s5Playing = false;
            _advanceStep();
            _playSound('success');
            _activeSlider = null;
          }
        }
        return;
      }

      if (_activeDragId != null) {
        if (_scenario == 3) {
          BlockEntity? b;
          try { b = _s3Blocks.firstWhere((e) => e.id == _activeDragId); } catch (_) {}
          try { b ??= _s3OutBlocks.firstWhere((e) => e.id == _activeDragId); } catch (_) {}
          if (b != null) {
            b.x = _mouseX + _dragOffset.dx;
            b.y = _mouseY + _dragOffset.dy;
          }
        }
      } else {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.4, 2.0);
        }
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_activeSlider != null) {
      setState(() => _activeSlider = null);
      return;
    }

    if (_activeDragId != null) {
      Offset pt = Offset(_mouseX, _mouseY);
      setState(() {
        if (_activeDragId!.startsWith('s1_')) {
          int tSize = int.parse(_activeDragId!.split('_')[1]);
          double gx = -260, gy = -180, gw = 12 * 22, gh = 16 * 22;
          if (_hitTestBox(gx - 40, gy - 40, gw + 80, gh + 80, pt)) {
            _s1ActiveTile = tSize;
            _s1Dropped = true;
            _playSound('snap');

            if (tSize == 3 && _step == 0) {
              Future.delayed(const Duration(milliseconds: 800), () {
                _advanceStep();
                _playSound('error');
              });
            } else if (tSize == 4 && _step == 1) {
              Future.delayed(const Duration(milliseconds: 800), () {
                _advanceStep();
                _playSound('success');
              });
            } else if (tSize == 2 && _step == 2) {
              Future.delayed(const Duration(milliseconds: 800), () {
                _advanceStep();
                _playSound('success');
              });
            }
          } else {
            _playSound('error');
          }
        } else if (_scenario == 3) {
          String id = _activeDragId!;
          String? targetBox;
          if (_hitTestBox(-340, -40, 240, 240, pt)) targetBox = 'M1';
          else if (_hitTestBox(-50, -200, 200, 180, pt)) targetBox = 'Analyzer';
          else if (_hitTestBox(130, -40, 240, 240, pt)) targetBox = 'M2';

          BlockEntity? b;
          try { b = _s3Blocks.firstWhere((e) => e.id == id); } catch (_) {}
          try { b ??= _s3OutBlocks.firstWhere((e) => e.id == id); } catch (_) {}

          if (targetBox != null && b != null) {
            if (targetBox == 'M1' && _step == 0 && (id == 'b6' || id == 'b8')) {
              b.hidden = true;
              _s3M1Val += b.val;
              _playSound('snap');
              if (_s3M1Val == 14) {
                _s3M1Ready = true;
                _playSound('success');
                _advanceStep();
                Future.delayed(const Duration(milliseconds: 1000), () {
                  setState(() {
                    for (var bk in _s3Blocks) {
                      bk.hidden = false;
                      bk.x = bk.startX;
                      bk.y = bk.startY;
                    }
                  });
                  _playSound('pop');
                });
              }
            } else if (targetBox == 'Analyzer' && _step == 1 && (id == 'b6' || id == 'b8')) {
              b.hidden = true;
              _s3AnalyzerVal += b.val;
              _playSound('snap');
              if (_s3AnalyzerVal == 14) {
                _s3AnalyzerReady = true;
                _playSound('success');
                _advanceStep();
                Future.delayed(const Duration(milliseconds: 800), () {
                  setState(() {
                    _s3OutBlocks = [
                      BlockEntity('b2', 2, 140, -140),
                      BlockEntity('b24', 24, 140, -85)
                    ];
                  });
                  _playSound('pop');
                });
              }
            } else if (targetBox == 'M2' && _step == 2 && (id == 'b2' || id == 'b24')) {
              b.hidden = true;
              _s3M2Val += b.val;
              _playSound('snap');
              if (_s3M2Val == 26) {
                _s3M2Ready = true;
                _playSound('success');
                _advanceStep();
                _checkScenarioSuccess();
              }
            } else {
              b.x = b.startX; b.y = b.startY;
              _playSound('error');
            }
          } else if (b != null) {
            b.x = b.startX; b.y = b.startY;
            _playSound('error');
          }
        } else if (_activeDragId == 's4_ans') {
          if (_hitTestBox(180, -220, 280, 230, pt)) {
            setState(() => _s4AnsCorrect = true);
            _playSound('success');
            _advanceStep();
            _checkScenarioSuccess();
          } else {
            _playSound('error');
          }
        }
        
        for (var b in _s3Blocks) b.isDragging = false;
        for (var b in _s3OutBlocks) b.isDragging = false;
        _activeDragId = null;
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
    return RichText(text: TextSpan(style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans', height: 1.4), children: spans));
  }

  Widget _buildSidebar(double width) {
    Color bg = const Color(0xFF1E293B).withOpacity(0.95);
    Color textPrimary = Colors.white;
    Color textSecondary = const Color(0xFF94A3B8);
    Color border = Colors.white.withOpacity(0.1);

    int totalSteps = (_scenario == 1) ? 4 : (_scenario == 2) ? 3 : (_scenario == 3) ? 4 : (_scenario == 4) ? 3 : 3;

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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.grid_on, color: Colors.indigoAccent),
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
                  if (_step >= totalSteps)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(t('scenCompleteTitle'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildRichText(t('scenComplete'), textPrimary),
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

    int totalSteps = (_scenario == 1) ? 4 : (_scenario == 2) ? 3 : (_scenario == 3) ? 4 : (_scenario == 4) ? 3 : 3;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                     behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _handleTapDown(d, constraints.biggest),
                      onScaleStart: (d) => _handleScaleStart(d, constraints.biggest),
                      onScaleUpdate: (d) => _handleScaleUpdate(d, constraints.biggest),
                      onScaleEnd: (d) => _handleScaleEnd(d, constraints.biggest),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: LabPainter(
                          scenario: _scenario,
                          step: _step,
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          mouseX: _mouseX,
                          mouseY: _mouseY,
                          activeDragId: _activeDragId,
                          dragOffset: _dragOffset,
                          s1ActiveTile: _s1ActiveTile,
                          s1Dropped: _s1Dropped,
                          s1LargestHover: _s1LargestHover,
                          s2RotA: _s2RotA,
                          s2RotB: _s2RotB,
                          s2CountA: _s2CountA,
                          s2CountB: _s2CountB,
                          s2ShowMultiples: _s2ShowMultiples,
                          s2Stars: _s2Stars,
                          s3Blocks: _s3Blocks,
                          s3OutBlocks: _s3OutBlocks,
                          s3M1Ready: _s3M1Ready,
                          s3M1Val: _s3M1Val,
                          s3AnalyzerReady: _s3AnalyzerReady,
                          s3M2Ready: _s3M2Ready,
                          s3M2Val: _s3M2Val,
                          s4BreakerSize: _s4BreakerSize,
                          s4IsBroken: _s4IsBroken,
                          s4AnsCorrect: _s4AnsCorrect,
                          s5Time: _s5Time,
                          s5InputVal: _s5InputVal,
                          s5Playing: _s5Playing,
                          t: t,
                          screenSize: constraints.biggest,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            if (_step < totalSteps)
              Positioned(
                bottom: 40,
                left: _isSidebarOpen ? sidebarWidth + 40 : 40,
                right: 40,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(top: BorderSide(color: Colors.indigoAccent, width: 4)),
                        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.indigoAccent.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.info_outline, color: Colors.indigoAccent),
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

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

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

            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: SingleChildScrollView(
                      controller: _popupScrollController,
                      child: Container(
                        width: 450,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.green, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.flag, color: Colors.white, size: 40),
                                ),
                                const SizedBox(height: 24),
                                Text(t('summaryTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                _buildRichText(t('finalDesc'), Colors.white70),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _playSound('pop');
                                    setState(() => _showSuccessPopup = false);
                                  },
                                  icon: const Icon(Icons.check),
                                  label: Text(t('finishLab')),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    backgroundColor: Colors.indigoAccent,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
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
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.6), blurRadius: 20)]),
                          child: const Icon(Icons.grid_on, size: 80, color: Colors.indigoAccent),
                        ),
                        Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2)),
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
class LabPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX, panY;
  final double mouseX, mouseY;
  final String? activeDragId;
  final Offset dragOffset;
  final Function(String) t;
  final Size screenSize;

  // S1
  final int? s1ActiveTile;
  final bool s1Dropped;
  final bool s1LargestHover;
  
  // S2
  final double s2RotA;
  final double s2RotB;
  final int s2CountA;
  final int s2CountB;
  final bool s2ShowMultiples;
  final List<Map<String, double>> s2Stars;

  // S3
  final List<BlockEntity> s3Blocks;
  final List<BlockEntity> s3OutBlocks;
  final bool s3M1Ready;
  final int s3M1Val;
  final bool s3AnalyzerReady;
  final bool s3M2Ready;
  final int s3M2Val;

  // S4
  final double s4BreakerSize;
  final bool s4IsBroken;
  final bool s4AnsCorrect;

  // S5
  final double s5Time;
  final int s5InputVal;
  final bool s5Playing;

  LabPainter({
    required this.scenario, required this.step, required this.zoom,
    required this.panX, required this.panY, required this.mouseX, required this.mouseY,
    required this.activeDragId, required this.dragOffset, required this.t, required this.screenSize,
    required this.s1ActiveTile, required this.s1Dropped, required this.s1LargestHover,
    required this.s2RotA, required this.s2RotB, required this.s2CountA, required this.s2CountB, required this.s2ShowMultiples, required this.s2Stars,
    required this.s3Blocks, required this.s3OutBlocks, required this.s3M1Ready, required this.s3M1Val, required this.s3AnalyzerReady, required this.s3M2Ready, required this.s3M2Val,
    required this.s4BreakerSize, required this.s4IsBroken, required this.s4AnsCorrect,
    required this.s5Time, required this.s5InputVal, required this.s5Playing,
  });

  final Color outLineCol = const Color(0xFF0F172A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) _drawS1(canvas);
    else if (scenario == 2) _drawS2(canvas);
    else if (scenario == 3) _drawS3(canvas);
    else if (scenario == 4) _drawS4(canvas);
    else if (scenario == 5) _drawS5(canvas);

    canvas.restore();
  }

  void _drawS1(Canvas canvas) {
    double u = 22; double gx = -260, gy = -180, gw = 12*u, gh = 16*u;
    
    // Floor
    _drawRoundedRect(canvas, gx, gy, gw, gh, 4, const Color(0xFF1E293B), const Color(0xFF92400E), 4);
    for (int i = 1; i < 12; i++) _drawLine(canvas, gx + i * u, gy, gx + i * u, gy + gh, Colors.white10, 1);
    for (int i = 1; i < 16; i++) _drawLine(canvas, gx, gy + i * u, gx + gw, gy + i * u, Colors.white10, 1);

    _drawText(canvas, t('s1_wall12'), gx + gw / 2, gy + gh + 15, 16, Colors.white);
    canvas.save(); canvas.translate(gx - 15, gy + gh / 2); canvas.rotate(-pi / 2);
    _drawText(canvas, t('s1_wall16'), 0, 0, 16, Colors.white);
    canvas.restore();

    _drawLine(canvas, gx, gy + gh + 15, gx + gw / 2 - 15, gy + gh + 15, Colors.white, 2);
    _drawLine(canvas, gx + gw / 2 + 15, gy + gh + 15, gx + gw, gy + gh + 15, Colors.white, 2);
    _drawLine(canvas, gx - 15, gy, gx - 15, gy + gh / 2 - 15, Colors.white, 2);
    _drawLine(canvas, gx - 15, gy + gh / 2 + 15, gx - 15, gy + gh, Colors.white, 2);

    // Toolbox
    double tx = 60, ty = -180, tw = 80, th = 352;
    _drawRoundedRect(canvas, tx, ty, tw, th, 8, const Color(0xFF1E293B), const Color(0xFFCBD5E1), 3);
    _drawText(canvas, t('s1_toolbox'), tx + tw / 2, ty + 20, 12, const Color(0xFF64748B));
    _drawText(canvas, t('s1_sq_tiles'), tx + tw / 2, ty + 35, 10, const Color(0xFF64748B));

    Map<int, Color> tCol = {1: const Color(0xFFFCA5A5), 2: const Color(0xFFFDBA74), 3: const Color(0xFF93C5FD), 4: const Color(0xFF86EFAC), 6: const Color(0xFFD8B4FE)};
    List<int> tiles = [1, 2, 3, 4, 6];
    
    for (int i = 0; i < tiles.length; i++) {
      int ts = tiles[i];
      double by = ty + 80 + i * 55;
      double bx = tx + tw / 2;
      double dSize = 30;
      
      bool highlight = !s1Dropped && ((step == 0 && ts == 3) || (step == 1 && ts == 4) || (step == 2 && ts == 2));
      if (highlight) {
        canvas.drawRect(Rect.fromCenter(center: Offset(bx, by), width: dSize+10, height: dSize+10), Paint()..color = tCol[ts]!.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      }
      if (activeDragId != 's1_$ts') {
        _drawRoundedRect(canvas, bx - dSize/2, by - dSize/2, dSize, dSize, 4, tCol[ts]!, outLineCol, 2);
        _drawText(canvas, '${ts}x$ts', bx, by, 12, outLineCol);
      }
    }

    if (s1Dropped && s1ActiveTile != null) {
      int tSize = s1ActiveTile!;
      double tu = tSize * u;
      int fitX = 12 ~/ tSize;
      int fitY = 16 ~/ tSize;
      bool ok = (12 % tSize == 0 && 16 % tSize == 0);

      if (ok) {
        for (int i = 0; i < fitX; i++) {
          for (int j = 0; j < fitY; j++) {
            _drawRoundedRect(canvas, gx + i * tu + 1, gy + j * tu + 1, tu - 2, tu - 2, 2, tCol[tSize]!, const Color(0xFF166534), 2);
            _drawText(canvas, '${tSize}x$tSize', gx + i * tu + tu / 2, gy + j * tu + tu / 2, 14, const Color(0xFF064E3B));
          }
        }
        _drawText(canvas, tSize == 4 ? t('s1_auto_perf') : t('s1_auto_also'), gx + gw / 2, gy + gh + 40, 16, const Color(0xFF22C55E));
      } else {
        for (int i = 0; i < fitX; i++) {
          for (int j = 0; j < fitY; j++) {
            _drawRoundedRect(canvas, gx + i * tu + 1, gy + j * tu + 1, tu - 2, tu - 2, 2, tCol[tSize]!, const Color(0xFF1E3A8A), 2);
            _drawText(canvas, '${tSize}x$tSize', gx + i * tu + tu / 2, gy + j * tu + tu / 2, 14, const Color(0xFF1E3A8A));
          }
        }
        int remY = 16 % tSize;
        if (remY > 0) {
          canvas.drawRect(Rect.fromLTWH(gx, gy + fitY * tu, gw, remY * u), Paint()..color = const Color(0xCCEF4444));
          _drawText(canvas, t('lbl_gap'), gx + gw / 2, gy + fitY * tu + (remY * u) / 2, 16, const Color(0xFF7F1D1D));
        }
      }

      if (step < 3) {
        _drawRoundedRect(canvas, tx + tw + 20, ty, 80, 30, 15, const Color(0xFF3B82F6), const Color(0xFF1E3A8A), 2);
        _drawText(canvas, t('lbl_reset'), tx + tw + 60, ty + 15, 12, Colors.white);
      }
    }

    if (step >= 3) {
      double px = tx + tw + 20, py = ty + 40, pw = 240;
      if (step == 3) {
        _drawRoundedRect(canvas, px, py, pw, 180, 8, const Color(0xFFF8FAFC), const Color(0xFFCBD5E1), 3);
        _drawText(canvas, t('s1_fit_sizes'), px + pw / 2, py + 25, 14, outLineCol);
        
        List<int> fitTiles = [1, 2, 4];
        for (int i = 0; i < fitTiles.length; i++) {
          int ts = fitTiles[i];
          double bx = px + 50 + i * 70, by = py + 80, bSize = 35;
          _drawRoundedRect(canvas, bx - bSize / 2, by - bSize / 2, bSize, bSize, 4, tCol[ts]!, outLineCol, 2);
          _drawText(canvas, '${ts}x$ts', bx, by, 14, outLineCol);
        }

        if (s1LargestHover) {
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px + 40, py + 120, 160, 40), const Radius.circular(8)), Paint()..color = const Color(0xFF3B82F6).withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
        }
        _drawRoundedRect(canvas, px + 40, py + 120, 160, 40, 8, const Color(0xFF60A5FA), const Color(0xFF1E3A8A), 3);
        _drawText(canvas, t('s1_btn_largest'), px + pw / 2, py + 140, 14, outLineCol);
      } else if (step == 4) {
        _drawRoundedRect(canvas, px, py, pw, 220, 8, const Color(0xFFBAE6FD), const Color(0xFF38BDF8), 4);
        _drawText(canvas, t('lbl_success'), px + pw / 2, py + 30, 24, outLineCol);
        _drawText(canvas, t('s1_learn_hcf'), px + pw / 2, py + 55, 14, outLineCol);
        _drawText(canvas, t('s1_hcf_text1'), px + pw / 2, py + 90, 12, outLineCol);
        _drawText(canvas, t('s1_hcf_text2'), px + pw / 2, py + 145, 12, outLineCol);
        _drawText(canvas, t('s1_hcf_eq'), px + pw / 2, py + 195, 16, outLineCol);
      }
    }

    if (activeDragId != null && activeDragId!.startsWith('s1_')) {
      int tSize = int.parse(activeDragId!.split('_')[1]);
      double dSize = 40;
      double dx = mouseX + dragOffset.dx;
      double dy = mouseY + dragOffset.dy;
      _drawRoundedRect(canvas, dx - dSize / 2, dy - dSize / 2, dSize, dSize, 4, tCol[tSize]!, outLineCol, 2);
      _drawText(canvas, '${tSize}x$tSize', dx, dy, 14, outLineCol);
    }
  }

  void _drawS2(Canvas canvas) {
    // Stars
    for (var s in s2Stars) {
      canvas.drawCircle(Offset(s['x']!, s['y']!), s['r']!, Paint()..color = Colors.white.withOpacity(0.3 + 0.7 * (sin(DateTime.now().millisecondsSinceEpoch * 0.001 + s['a']! * 10).abs())));
    }

    double rA = 80, rB = 106.66;
    double ax = -120, ay = -50;
    double bx = ax + rA + rB + 8, by = -50;

    Color cntColor = (step >= 2 && s2CountA == 24) ? const Color(0xFFFACC15) : const Color(0xFF60A5FA);
    if (step >= 2 && s2CountA == 24) {
      canvas.drawRect(Rect.fromLTWH(ax-50, ay-160, 100, 40), Paint()..color = const Color(0xFFFACC15).withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }
    _drawText(canvas, '${t('s2_gearA')}: $s2CountA', ax, ay - 140, 20, cntColor);
    _drawText(canvas, '${t('s2_gearB')}: $s2CountB', bx, by - 140, 20, cntColor);

    _drawCosmicGear(canvas, ax, ay, rA, 6, s2RotA, const Color(0xFF94A3B8));
    _drawCosmicGear(canvas, bx, by, rB, 8, s2RotB - pi / 8, const Color(0xFF64748B));

    if (step >= 2) {
      _drawText(canvas, t('s2_aligned'), ax + (bx - ax) / 2, ay - 180, 24, const Color(0xFFFACC15));
    }

    if (step == 0) {
      _drawRoundedRect(canvas, ax + (bx - ax) / 2 - 60, ay + 150, 120, 50, 25, const Color(0xFFE0F2FE), const Color(0xFF38BDF8), 4);
      _drawText(canvas, t('s2_run'), ax + (bx - ax) / 2, ay + 175, 18, outLineCol);
    } else if (step == 2 && !s2ShowMultiples) {
      _drawRoundedRect(canvas, ax + (bx - ax) / 2 - 90, ay + 150, 180, 50, 25, const Color(0xFFE0F2FE), const Color(0xFF38BDF8), 4);
      _drawText(canvas, t('s2_show_mult'), ax + (bx - ax) / 2, ay + 175, 16, outLineCol);
    }

    if (s2ShowMultiples) {
      double tx = -320, ty = 140, tw = 700;
      _drawLine(canvas, tx, ty, tx + tw, ty, const Color(0xFF38BDF8), 4);
      _drawLine(canvas, tx, ty + 60, tx + tw, ty + 60, const Color(0xFFFACC15), 4);
      _drawText(canvas, "A\n(Top)", tx - 30, ty, 14, const Color(0xFF38BDF8), align: TextAlign.right);
      _drawText(canvas, "B\n(Bottom)", tx - 30, ty + 60, 14, const Color(0xFFFACC15), align: TextAlign.right);

      double scale = tw / 40;
      for (int i = 1; i <= 40; i++) {
        double px = tx + i * scale;
        if (i % 6 == 0 && i <= 36) {
          _drawLine(canvas, px, ty - 10, px, ty + 10, const Color(0xFF38BDF8), 3);
          _drawText(canvas, '$i', px, ty + 25, 14, Colors.white);
        }
        if (i % 8 == 0 && i <= 40) {
          _drawLine(canvas, px, ty + 50, px, ty + 70, const Color(0xFFFACC15), 3);
          _drawText(canvas, '$i', px, ty + 85, 14, Colors.white);
        }
      }

      double hx = tx + 24 * scale;
      _drawLine(canvas, hx, ty - 20, hx, ty + 80, const Color(0xFFFACC15), 4, dashed: true);
      _drawText(canvas, t('s2_lcm_msg'), 0, ty + 130, 16, Colors.white);
      _drawText(canvas, t('s2_lcm_eq'), 0, ty + 155, 18, Colors.white);
    }
  }

  void _drawS3(Canvas canvas) {
    // Factory Background Pipes
    Paint pPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 15..strokeCap = StrokeCap.square..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(Path()..moveTo(-450, 100)..lineTo(-300, 100)..lineTo(-300, 20), pPaint);
    canvas.drawPath(Path()..moveTo(-40, 100)..lineTo(100, 100)..lineTo(100, -60), pPaint);
    canvas.drawPath(Path()..moveTo(350, -100)..lineTo(450, -100)..lineTo(450, 100)..lineTo(350, 100), pPaint);

    // Wood Shelf
    _drawRoundedRect(canvas, -380, -120, 200, 15, 0, const Color(0xFFB45309), outLineCol, 3);
    _drawRoundedRect(canvas, -360, -105, 10, 20, 0, const Color(0xFF92400E), outLineCol, 2);
    _drawRoundedRect(canvas, -210, -105, 10, 20, 0, const Color(0xFF92400E), outLineCol, 2);

    _drawProductMachine(canvas, -220, 100, s3M1Ready, "48", 8, 6);
    _drawAnalyzer(canvas, 40, -100, s3AnalyzerReady);
    _drawProductMachine(canvas, 250, 100, s3M2Ready, "48", 24, 2);

    for (var b in s3Blocks) {
      if (!b.hidden && activeDragId != b.id) _draw3DBlock(canvas, b.x, b.y, 45, b.val);
    }
    for (var b in s3OutBlocks) {
      if (!b.hidden && activeDragId != b.id) _draw3DBlock(canvas, b.x, b.y, 40, b.val);
    }

    if (activeDragId != null && activeDragId!.startsWith('b')) {
      BlockEntity? b;
      try { b = s3Blocks.firstWhere((e) => e.id == activeDragId); } catch (_) {}
      try { b ??= s3OutBlocks.firstWhere((e) => e.id == activeDragId); } catch (_) {}
      if (b != null) {
        _draw3DBlock(canvas, mouseX + dragOffset.dx, mouseY + dragOffset.dy, 50, b.val);
      }
    }

    if (step == 3) {
      _drawRoundedRect(canvas, -150, -50, 360, 150, 10, outLineCol, const Color(0xFF38BDF8), 4);
      _drawTextOutline(canvas, t('s3_obs'), 30, -25, 16, const Color(0xFF4ADE80), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s3_obs1'), 30, 0, 14, const Color(0xFFF8FAFC), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s3_obs2'), 30, 20, 14, const Color(0xFFF8FAFC), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s3_obs3'), 30, 45, 16, const Color(0xFFFACC15), Colors.transparent, 0);
      _drawTextOutline(canvas, t('s3_obs4'), 30, 75, 14, const Color(0xFF38BDF8), Colors.transparent, 0);

      _drawArrow(canvas, -120, 10, -150, 10, const Color(0xFF4ADE80), 5);
      _drawArrow(canvas, 180, 10, 210, 10, const Color(0xFF4ADE80), 5);
    }
  }

  void _drawS4(Canvas canvas) {
    double slX = -150, slY = -180, slW = 300;
    _drawRoundedRect(canvas, slX - 60, slY - 60, slW + 120, 150, 12, const Color(0xFFFEF08A), outLineCol, 4);
    _drawTextOutline(canvas, t('lbl_s4_breaker_size'), slX, slY - 30, 18, outLineCol, Colors.white, 3, align: TextAlign.left);
    
    _drawLine(canvas, slX, slY, slX + slW, slY, const Color(0xFFCBD5E1), 10);
    double handleX = slX + ((s4BreakerSize - 1) / 17) * slW;
    
    List<int> testSizes = [2, 3, 5, 6];
    for (int ts in testSizes) {
      double tx = slX + ((ts - 1) / 17) * slW;
      _drawRoundedRect(canvas, tx - 10, slY - 45, 20, 10, 2, const Color(0xFF78350F), const Color(0xFF451A03), 2);
      _drawTextOutline(canvas, '$ts', tx, slY - 25, 12, outLineCol, Colors.white, 2);
    }

    if (step >= 2 && s4BreakerSize == 6) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(handleX - 25, slY - 25, 50, 50), const Radius.circular(25)), Paint()..color = const Color(0xFF22C55E).withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }
    
    _drawRoundedRect(canvas, handleX - 15, slY - 15, 30, 30, 15, const Color(0xFF3B82F6), outLineCol, 3);
    _drawTextOutline(canvas, '${s4BreakerSize.toInt()}', handleX, slY, 14, Colors.white, Colors.transparent, 0);

    Color btnColor = (step == 0 && s4BreakerSize == 4) || (step == 1 && s4BreakerSize == 6) ? const Color(0xFF22C55E) : const Color(0xFFEA580C);
    _drawRoundedRect(canvas, -60, slY + 30, 120, 45, 8, btnColor, outLineCol, 3);
    _drawTextOutline(canvas, t('lbl_s4_break'), 0, slY + 52, 18, Colors.white, Colors.transparent, 0);

    _drawChocolateGrid(canvas, -260, 40, 3, 6, s4BreakerSize.toInt(), s4IsBroken);
    _drawChocolateGrid(canvas, -40, 40, 4, 6, s4BreakerSize.toInt(), s4IsBroken);

    if (step >= 2) {
      double ansX = 220, ansY = -180;
      _drawRoundedRect(canvas, ansX, ansY, 200, 150, 12, const Color(0xFFF8FAFC), outLineCol, 4);
      _drawTextOutline(canvas, t('lbl_s4_finalans'), ansX + 100, ansY + 30, 16, outLineCol, Colors.transparent, 0);
      
      Color ansBoxColor = (step == 3) ? const Color(0xFFDCFCE7) : Colors.white;
      _drawRoundedRect(canvas, ansX + 40, ansY + 60, 120, 60, 8, ansBoxColor, outLineCol, 3);
      
      if (step == 3) {
        _drawTextOutline(canvas, "6", ansX + 100, ansY + 90, 32, outLineCol, Colors.transparent, 0);
        _drawSpeechBubble(canvas, t('lbl_s4_correct'), ansX - 150, ansY + 180, 360, 130, 'top', 250, const Color(0xFFDCFCE7), const Color(0xFF166534), outLineCol, 3);
      } else {
        _drawTextOutline(canvas, "Drop Here", ansX + 100, ansY + 90, 14, const Color(0xFF94A3B8), Colors.transparent, 0);
      }
    }

    if (activeDragId == 's4_ans') {
      double dx = mouseX + dragOffset.dx;
      double dy = mouseY + dragOffset.dy;
      _drawRoundedRect(canvas, dx - 25, dy - 25, 50, 50, 25, const Color(0xFF3B82F6), outLineCol, 3);
      _drawTextOutline(canvas, '${s4BreakerSize.toInt()}', dx, dy, 24, Colors.white, Colors.transparent, 0);
    }
  }

  void _drawS5(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(-2000, 40, 4000, 500), Paint()..color = const Color(0xFF0F766E));
    for (var s in s2Stars) {
      canvas.drawCircle(Offset(s['x']!, s['y']!), s['r']!, Paint()..color = Colors.white.withOpacity(0.3));
    }

    bool tA = s5Time.floor() % 9 == 0 || s5Time == 0;
    bool tB = s5Time.floor() % 12 == 0 || s5Time == 0;

    _drawLh(canvas, -150, 40, 1.5, tA, const Color(0xFF38BDF8), 'A');
    _drawLh(canvas, 150, 40, 1.5, tB, const Color(0xFFC084FC), 'B');

    double tlX = -450, tlY = 130, tlW = 900, tlH = 140;
    _drawRoundedRect(canvas, tlX, tlY, tlW, tlH, 10, const Color(0xFF1E293B), outLineCol, 4);

    double pxPerSec = (tlW - 100) / 40;
    double startX = tlX + 80;

    _drawLine(canvas, startX, tlY + 40, startX + 40 * pxPerSec, tlY + 40, const Color(0xFF38BDF8), 4);
    _drawLine(canvas, startX, tlY + 100, startX + 40 * pxPerSec, tlY + 100, const Color(0xFFC084FC), 4);
    _drawRoundedRect(canvas, tlX + 20, tlY + 25, 30, 30, 15, const Color(0xFF38BDF8), outLineCol, 3);
    _drawTextOutline(canvas, "A", tlX + 35, tlY + 40, 16, Colors.white, Colors.transparent, 0);
    _drawRoundedRect(canvas, tlX + 20, tlY + 85, 30, 30, 15, const Color(0xFFC084FC), outLineCol, 3);
    _drawTextOutline(canvas, "B", tlX + 35, tlY + 100, 16, Colors.white, Colors.transparent, 0);

    for (int i = 0; i <= 40; i += 3) {
      _drawLine(canvas, startX + i * pxPerSec, tlY + 70, startX + i * pxPerSec, tlY + 70, const Color(0xFF94A3B8), 2);
      _drawTextOutline(canvas, '$i', startX + i * pxPerSec, tlY + 70, 12, const Color(0xFFCBD5E1), Colors.transparent, 0);
    }

    for (int i = 0; i <= s5Time.floor(); i += 9) {
      _drawRoundedRect(canvas, startX + i * pxPerSec - 5, tlY + 20, 10, 20, 3, const Color(0xFF38BDF8), outLineCol, 2);
    }
    for (int i = 0; i <= s5Time.floor(); i += 12) {
      _drawRoundedRect(canvas, startX + i * pxPerSec - 5, tlY + 80, 10, 20, 3, const Color(0xFFC084FC), outLineCol, 2);
    }

    double headX = startX + s5Time * pxPerSec;
    canvas.drawLine(Offset(headX, tlY + 10), Offset(headX, tlY + 130), Paint()..color = const Color(0xFFFACC15).withOpacity(0.5)..strokeWidth = 10..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    _drawLine(canvas, headX, tlY + 10, headX, tlY + 130, const Color(0xFFFACC15), 3);
    _drawRoundedRect(canvas, headX - 15, tlY + 115, 30, 20, 4, const Color(0xFFFACC15), outLineCol, 2);
    _drawTextOutline(canvas, '${s5Time.floor()}', headX, tlY + 125, 12, const Color(0xFF0F172A), Colors.transparent, 0);

    if (step <= 1) {
      Color btnColor = s5Playing ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
      _drawRoundedRect(canvas, -60, tlY + 160, 120, 50, 8, btnColor, outLineCol, 3);
      _drawTextOutline(canvas, s5Playing ? "PAUSE" : "PLAY", 0, tlY + 185, 18, Colors.white, Colors.transparent, 0);
    }

    if (step >= 2) {
      double bx = 200, by = 280;
      _drawRoundedRect(canvas, bx - 150, by - 40, 300, 120, 8, const Color(0xFFF8FAFC), outLineCol, 4);
      _drawTextOutline(canvas, "TIME OF NEXT SIMULTANEOUS\nFLASH (SECONDS):", bx, by - 15, 12, const Color(0xFF0F172A), Colors.transparent, 0);
      
      _drawRoundedRect(canvas, bx - 130, by + 20, 140, 40, 4, Colors.white, outLineCol, 2);
      _drawTextOutline(canvas, '$s5InputVal', bx - 60, by + 40, 24, const Color(0xFF0F172A), Colors.transparent, 0);
      
      _drawRoundedRect(canvas, bx + 20, by + 20, 100, 40, 4, const Color(0xFF38BDF8), outLineCol, 3);
      _drawTextOutline(canvas, "SUBMIT", bx + 70, by + 40, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    }

    if (step == 3) {
      _drawSpeechBubble(canvas, "LCM(9,12) = 36", 120, -180, 150, 40, 'bottom', 75, const Color(0xFFDCFCE7), const Color(0xFF166534), outLineCol, 3);
    }
  }

  // --- Helpers ---
  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double strokeW = 1.0]) {
    RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && strokeW > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double fontSize, Color fill, {TextAlign align = TextAlign.center}) {
    _drawTextOutline(canvas, text, x, y, fontSize, fill, Colors.transparent, 0, align: align);
  }

  void _drawTextOutline(Canvas canvas, String text, double x, double y, double fontSize, Color fill, Color outline, double outlineW, {TextAlign align = TextAlign.center}) {
    List<String> lines = text.split('\n');
    double lineHeight = fontSize * 1.2;
    double startY = y - ((lines.length - 1) * lineHeight) / 2;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (outlineW > 0) {
        TextPainter tpStroke = TextPainter(
          text: TextSpan(text: line, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans', foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = outlineW..color = outline..strokeJoin = StrokeJoin.round)),
          textDirection: TextDirection.ltr, textAlign: align,
        );
        tpStroke.layout();
        tpStroke.paint(canvas, Offset(align == TextAlign.center ? x - tpStroke.width / 2 : x, startY + i * lineHeight - tpStroke.height / 2));
      }
      TextPainter tpFill = TextPainter(
        text: TextSpan(text: line, style: TextStyle(color: fill, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans')),
        textDirection: TextDirection.ltr, textAlign: align,
      );
      tpFill.layout();
      tpFill.paint(canvas, Offset(align == TextAlign.center ? x - tpFill.width / 2 : x, startY + i * lineHeight - tpFill.height / 2));
    }
  }

  void _drawLine(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width, {bool dashed = false}) {
    Paint p = Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round;
    if (dashed) {
      double dashWidth = 8, dashSpace = 8, startX = x1, startY = y1;
      double length = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
      double dx = (x2 - x1) / length, dy = (y2 - y1) / length;
      for (double i = 0; i < length; i += dashWidth + dashSpace) {
        canvas.drawLine(Offset(startX, startY), Offset(startX + dx * dashWidth, startY + dy * dashWidth), p);
        startX += dx * (dashWidth + dashSpace);
        startY += dy * (dashWidth + dashSpace);
      }
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    }
  }

  void _drawArrow(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width, [double headSize = 15]) {
    _drawLine(canvas, x1, y1, x2, y2, color, width);
    double angle = atan2(y2 - y1, x2 - x1);
    Path p = Path()
      ..moveTo(x2, y2)
      ..lineTo(x2 - headSize * cos(angle - pi / 6), y2 - headSize * sin(angle - pi / 6))
      ..lineTo(x2 - headSize * cos(angle + pi / 6), y2 - headSize * sin(angle + pi / 6))
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  void _drawSpeechBubble(Canvas canvas, String text, double x, double y, double w, double h, String pointDir, double pointOffset, Color bg, Color textCol, Color border, double borderW) {
    _drawRoundedRect(canvas, x, y, w, h, 10, bg, border, borderW);
    Path p = Path();
    if (pointDir == 'top') {
      p.moveTo(x + pointOffset, y + 3); p.lineTo(x + pointOffset + 10, y - 20); p.lineTo(x + pointOffset + 20, y + 3);
    } else if (pointDir == 'bottom') {
      p.moveTo(x + pointOffset, y + h - 3); p.lineTo(x + pointOffset + 10, y + h + 20); p.lineTo(x + pointOffset + 20, y + h - 3);
    }
    canvas.drawPath(p, Paint()..color = bg);
    if (borderW > 0) {
      Paint pStroke = Paint()..color = border..style = PaintingStyle.stroke..strokeWidth = borderW;
      if (pointDir == 'top') {
        canvas.drawLine(Offset(x + pointOffset, y + 3), Offset(x + pointOffset + 10, y - 20), pStroke);
        canvas.drawLine(Offset(x + pointOffset + 10, y - 20), Offset(x + pointOffset + 20, y + 3), pStroke);
      } else if (pointDir == 'bottom') {
        canvas.drawLine(Offset(x + pointOffset, y + h - 3), Offset(x + pointOffset + 10, y + h + 20), pStroke);
        canvas.drawLine(Offset(x + pointOffset + 10, y + h + 20), Offset(x + pointOffset + 20, y + h - 3), pStroke);
      }
    }
    _drawTextOutline(canvas, text, x + w / 2, y + h / 2, 16, textCol, Colors.transparent, 0);
  }

  void _drawCosmicGear(Canvas canvas, double x, double y, double radius, int teethCount, double angle, Color baseColor) {
    canvas.save(); canvas.translate(x, y); canvas.rotate(angle);
    
    Paint shadowPaint = Paint()..color = Colors.white.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset.zero, radius, shadowPaint);

    double teethDepth = radius * 0.2;
    double stepSize = pi * 2 / teethCount;
    Path gearPath = Path();
    for (int i = 0; i < teethCount; i++) {
      double a1 = i * stepSize - stepSize / 4;
      double a2 = i * stepSize + stepSize / 4;
      double a3 = i * stepSize + stepSize / 2;
      if (i == 0) gearPath.moveTo((radius + teethDepth) * cos(a1), (radius + teethDepth) * sin(a1));
      else gearPath.lineTo((radius + teethDepth) * cos(a1), (radius + teethDepth) * sin(a1));
      gearPath.lineTo((radius + teethDepth) * cos(a2), (radius + teethDepth) * sin(a2));
      gearPath.lineTo(radius * cos(a3), radius * sin(a3));
    }
    gearPath.close();
    canvas.drawPath(gearPath, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(gearPath, Paint()..color = baseColor..style = PaintingStyle.stroke..strokeWidth = 4);

    Path redTooth = Path();
    double ra1 = -stepSize / 4, ra2 = stepSize / 4, ra3 = stepSize / 2, ra0 = -stepSize / 2;
    redTooth.moveTo(radius * cos(ra0), radius * sin(ra0));
    redTooth.lineTo((radius + teethDepth) * cos(ra1), (radius + teethDepth) * sin(ra1));
    redTooth.lineTo((radius + teethDepth) * cos(ra2), (radius + teethDepth) * sin(ra2));
    redTooth.lineTo(radius * cos(ra3), radius * sin(ra3));
    redTooth.lineTo(radius * cos(ra0), radius * sin(ra0));
    canvas.drawPath(redTooth, Paint()..color = const Color(0xCCEF4444));
    canvas.drawPath(redTooth, Paint()..color = const Color(0xFFFCA5A5)..style = PaintingStyle.stroke..strokeWidth = 2);

    canvas.drawCircle(Offset.zero, radius * 0.5, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset.zero, radius * 0.5, Paint()..color = outLineCol..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(Offset.zero, radius * 0.25, Paint()..color = const Color(0xFF334155));

    for (int i = 0; i < teethCount; i++) {
      double ha = i * stepSize;
      canvas.drawCircle(Offset((radius * 0.7) * cos(ha), (radius * 0.7) * sin(ha)), radius * 0.1, Paint()..color = const Color(0xFF0F172A));
    }
    canvas.restore();
  }

  void _draw3DBlock(Canvas canvas, double x, double y, double size, int val) {
    List<Color> colors;
    if (val == 6) colors = [const Color(0xFF93C5FD), const Color(0xFF2563EB), const Color(0xFFDBEAFE)];
    else if (val == 8) colors = [const Color(0xFFFDBA74), const Color(0xFFEA580C), const Color(0xFFFFEDD5)];
    else if (val == 2) colors = [const Color(0xFFFCA5A5), const Color(0xFFDC2626), const Color(0xFFFEE2E2)];
    else if (val == 24) colors = [const Color(0xFF86EFAC), const Color(0xFF16A34A), const Color(0xFFDCFCE7)];
    else colors = [const Color(0xFFCBD5E1), const Color(0xFF475569), const Color(0xFFF8FAFC)];

    _drawRoundedRect(canvas, x - size / 2, y - size / 2, size, size, 3, colors[0], outLineCol, 2);
    
    double d = size * 0.35;
    Path top = Path()..moveTo(x - size / 2, y - size / 2)..lineTo(x - size / 2 + d, y - size / 2 - d)..lineTo(x + size / 2 + d, y - size / 2 - d)..lineTo(x + size / 2, y - size / 2)..close();
    canvas.drawPath(top, Paint()..color = colors[2]);
    canvas.drawPath(top, Paint()..color = outLineCol..style = PaintingStyle.stroke..strokeWidth = 2);

    Path side = Path()..moveTo(x + size / 2, y - size / 2)..lineTo(x + size / 2 + d, y - size / 2 - d)..lineTo(x + size / 2 + d, y + size / 2 - d)..lineTo(x + size / 2, y + size / 2)..close();
    canvas.drawPath(side, Paint()..color = colors[1]);
    canvas.drawPath(side, Paint()..color = outLineCol..style = PaintingStyle.stroke..strokeWidth = 2);

    _drawTextOutline(canvas, '$val', x, y, 22, outLineCol, Colors.transparent, 0);
  }

  void _drawProductMachine(Canvas canvas, double x, double y, bool isReady, String targetVal, int gridCols, int gridRows) {
    _drawRoundedRect(canvas, x - 100, y - 100, 200, 200, 10, const Color(0xFFCBD5E1), outLineCol, 4);
    _drawRoundedRect(canvas, x - 80, y - 80, 160, 60, 5, const Color(0xFF1E293B), outLineCol, 3);
    
    String dispVal = isReady ? targetVal : "0";
    Color color = isReady ? const Color(0xFF4ADE80) : const Color(0xFF475569);
    if (isReady) {
      _drawTextOutline(canvas, dispVal, x, y - 50, 44, color, const Color(0xFF4ADE80).withOpacity(0.5), 15);
    }
    _drawTextOutline(canvas, dispVal, x, y - 50, 44, color, Colors.transparent, 0);

    _drawRoundedRect(canvas, x - 80, y, 160, 70, 2, const Color(0xFF475569), outLineCol, 3);
    if (isReady) {
      double cellW = 160 / gridCols;
      double cellH = 70 / gridRows;
      for (int r = 0; r < gridRows; r++) {
        for (int c = 0; c < gridCols; c++) {
          Color cellCol = (r + c) % 2 == 0 ? const Color(0xFFFACC15) : const Color(0xFFEAB308);
          if (gridRows == 2 && gridCols == 24) cellCol = (r + c) % 2 == 0 ? const Color(0xFFF87171) : const Color(0xFFEF4444);
          canvas.drawRect(Rect.fromLTWH(x - 80 + c * cellW, y + r * cellH, cellW, cellH), Paint()..color = cellCol);
          canvas.drawRect(Rect.fromLTWH(x - 80 + c * cellW, y + r * cellH, cellW, cellH), Paint()..color = Colors.black38..style = PaintingStyle.stroke..strokeWidth = 1);
        }
      }
    }
    
    _drawRoundedRect(canvas, x - 60, y + 80, 120, 25, 4, const Color(0xFFF8FAFC), outLineCol, 2);
    _drawTextOutline(canvas, t('s3_prod_area'), x, y + 92, 12, outLineCol, Colors.transparent, 0);
    canvas.drawCircle(Offset(x - 85, y + 90), 5, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(Offset(x + 85, y + 90), 5, Paint()..color = const Color(0xFF22C55E));
  }

  void _drawAnalyzer(Canvas canvas, double x, double y, bool isReady) {
    _drawRoundedRect(canvas, x - 80, y - 60, 160, 120, 10, const Color(0xFF94A3B8), outLineCol, 4);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 60), width: 70, height: 20), Paint()..color = const Color(0xFF1E293B));
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 60), width: 70, height: 20), Paint()..color = outLineCol..style = PaintingStyle.stroke..strokeWidth = 2);
    
    _drawRoundedRect(canvas, x - 60, y - 35, 120, 30, 4, const Color(0xFF1E293B), outLineCol, 2);
    _drawTextOutline(canvas, t('s3_analyzer'), x, y - 20, 10, const Color(0xFF4ADE80), Colors.transparent, 0);

    _drawRoundedRect(canvas, x - 60, y + 10, 120, 35, 4, const Color(0xFF1E293B), outLineCol, 2);
    Path hb = Path();
    if (isReady || Random().nextDouble() > 0.5) {
      hb.moveTo(x - 50, y + 27); hb.lineTo(x - 30, y + 27); hb.lineTo(x - 20, y + 15); hb.lineTo(x, y + 40); hb.lineTo(x + 10, y + 27); hb.lineTo(x + 50, y + 27);
    } else {
      hb.moveTo(x - 50, y + 27); hb.lineTo(x + 50, y + 27);
    }
    canvas.drawPath(hb, Paint()..color = const Color(0xFF22C55E)..style = PaintingStyle.stroke..strokeWidth = 2..strokeJoin = StrokeJoin.miter);

    canvas.drawCircle(Offset(x - 65, y - 5), 8, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(Offset(x - 40, y - 5), 8, Paint()..color = const Color(0xFFFACC15));

    _drawRoundedRect(canvas, x + 80, y - 40, 70, 15, 2, const Color(0xFF64748B), outLineCol, 2);
    _drawTextOutline(canvas, t('s3_hcf_out'), x + 115, y - 32, 10, outLineCol, Colors.transparent, 0);
    _drawRoundedRect(canvas, x + 80, y + 15, 70, 15, 2, const Color(0xFF64748B), outLineCol, 2);
    _drawTextOutline(canvas, t('s3_lcm_out'), x + 115, y + 22, 10, outLineCol, Colors.transparent, 0);
  }

  void _drawChocolateGrid(Canvas canvas, double x, double y, int cols, int rows, int breakerSize, bool isBroken) {
    double u = 24;
    int total = cols * rows;
    int fullGroups = total ~/ breakerSize;
    int rem = total % breakerSize;

    for (int i = 0; i < total; i++) {
      int r = i ~/ cols;
      int c = i % cols;
      int group = i ~/ breakerSize;
      double px = x + c * u;
      double py = y + r * u;
      bool isWaste = group >= fullGroups;

      _drawRoundedRect(canvas, px, py, u, u, 2, const Color(0xFF78350F), outLineCol, 2);
      _drawRoundedRect(canvas, px + 2, py + 2, u - 4, u - 4, 1, const Color(0xFF92400E), Colors.transparent, 0);

      if (isBroken) {
        if (isWaste) canvas.drawRect(Rect.fromLTWH(px, py, u, u), Paint()..color = const Color(0x66EF4444));
        else if (rem == 0) canvas.drawRect(Rect.fromLTWH(px, py, u, u), Paint()..color = const Color(0x3322C55E));
      }
    }

    if (isBroken) {
      for (int i = 0; i < total; i++) {
        int r = i ~/ cols;
        int c = i % cols;
        double px = x + c * u;
        double py = y + r * u;
        int group = i ~/ breakerSize;
        bool isWaste = group >= fullGroups;
        Color sc = isWaste ? const Color(0xFFEF4444) : (rem == 0 ? const Color(0xFF22C55E) : const Color(0xFFFACC15));
        
        if (r == 0 || (i - cols) ~/ breakerSize != group) _drawLine(canvas, px, py, px + u, py, sc, 3);
        if (r == rows - 1 || (i + cols) ~/ breakerSize != group) _drawLine(canvas, px, py + u, px + u, py + u, sc, 3);
        if (c == 0 || (i - 1) ~/ breakerSize != group) _drawLine(canvas, px, py, px, py + u, sc, 3);
        if (c == cols - 1 || (i + 1) ~/ breakerSize != group) _drawLine(canvas, px + u, py, px + u, py + u, sc, 3);
      }
    }

    double h = rows * u, w = cols * u;
    if (isBroken && rem > 0) _drawTextOutline(canvas, t('lbl_s4_leftover'), x + w + 45, y + h - 12, 14, const Color(0xFFEF4444), outLineCol, 3);
    _drawTextOutline(canvas, '$total ${t('lbl_s4_units')}', x + w / 2, y + h + 20, 16, outLineCol, Colors.white, 3);

    if (isBroken) {
      double boxY = y + h + 35;
      _drawRoundedRect(canvas, x, boxY, max(w, 230), 35, 6, outLineCol, const Color(0xFF334155), 3);
      Color wColor = rem == 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
      _drawTextOutline(canvas, t('lbl_s4_waste'), x + 80, boxY + 17, 12, const Color(0xFFF8FAFC), Colors.transparent, 0);
      _drawTextOutline(canvas, '$rem ${t('lbl_s4_units').toUpperCase()}', x + 180, boxY + 17, 14, wColor, Colors.transparent, 0);
      if (rem == 0) _drawTextOutline(canvas, t('lbl_s4_nowaste'), x + 290, boxY + 17, 18, const Color(0xFF22C55E), outLineCol, 4);
    }
  }

  void _drawLh(Canvas canvas, double x, double y, double scale, bool isOn, Color color, String label) {
    canvas.save(); canvas.translate(x, y); canvas.scale(scale, scale);

    if (isOn) {
      Path ray = Path()..moveTo(-100, -200)..lineTo(100, -200)..lineTo(0, -100)..close();
      canvas.drawPath(ray, Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50));
      canvas.drawPath(ray, Paint()..color = color);
    }

    _drawRoundedRect(canvas, -20, -100, 40, 100, 0, const Color(0xFFF8FAFC), outLineCol, 2);
    _drawRoundedRect(canvas, -20, -80, 40, 20, 0, const Color(0xFFEF4444), outLineCol, 2);
    _drawRoundedRect(canvas, -20, -40, 40, 20, 0, const Color(0xFFEF4444), outLineCol, 2);
    
    Path top = Path()..moveTo(-25, -100)..lineTo(25, -100)..lineTo(0, -130)..close();
    canvas.drawPath(top, Paint()..color = const Color(0xFF334155));
    canvas.drawPath(top, Paint()..color = outLineCol..style = PaintingStyle.stroke..strokeWidth = 2);

    if (isOn) canvas.drawCircle(const Offset(0, -110), 15, Paint()..color = color);

    _drawRoundedRect(canvas, 30, -50, 30, 30, 15, color, outLineCol, 3);
    _drawTextOutline(canvas, label, 45, -35, 16, Colors.white, Colors.transparent, 0);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}

// ==========================================
// TRANSLATIONS DATA (EN, HI, TE)
// ==========================================
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "The Common Ground Lab: Investigating HCF-LCM Properties and Relationships",
    'appTitle': "The Common Ground Lab",
    'appSubtitle': "Class 7 • FINDING COMMON GROUND",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Observation:",
    'closeBtn': "Close",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'finalDesc': "You have successfully explored the properties and relationships of HCF and LCM!",
    'scenCompleteTitle': "Scenario Completed!",
    'scenComplete': "This scenario is completed. Please select another scenario from the dropdown above.",
    'lbl_reset': "RESET",
    'lbl_gap': "GAP",
    'lbl_success': "SUCCESS!",
    's1_wall12': "12",
    's1_wall16': "16",
    's1_toolbox': "TOOLBOX:",
    's1_sq_tiles': "SQUARE TILES",
    's1_auto_perf': "AUTO-TILING: PERFECT FIT!",
    's1_auto_also': "AUTO-TILING: ALSO FITS!",
    's1_entire_floor': " Entire floor tiled.",
    's1_side12': "12-UNIT SIDE",
    's1_side16': "16-UNIT SIDE",
    's1_fit_sizes': "FITTING TILE SIZES:",
    's1_btn_largest': "4x4 TILE (LARGEST)",
    's1_learn_hcf': "LEARNING OUTCOME: HCF",
    's1_hcf_text1': "The common factors of 12 and 16\nare the tile sizes that fit perfectly:\n(1, 2, 4).",
    's1_hcf_text2': "The HIGHEST Common Factor (HCF)\nis 4, which is the largest square\ntile that works.",
    's1_hcf_eq': "HCF(12, 16) = 4.",
    's2_gearA': "Gear A (6 teeth)",
    's2_gearB': "Gear B (8 teeth)",
    's2_run': "RUN",
    's2_show_mult': "Show Multiples",
    's2_aligned': "ALIGNED!",
    's2_mult6': "Multiples of 6",
    's2_mult8': "Multiples of 8",
    's2_lcm_msg': "The LOWEST Common Multiple (LCM) is the first point where the cycles align.",
    's2_lcm_eq': "LCM(6, 8) = 24.",
    's3_prod_area': "PRODUCT AREA",
    's3_analyzer': "HCF/LCM\nANALYZER",
    's3_drop_in': "Drop In",
    's3_hcf_out': "HCF OUTPUT",
    's3_lcm_out': "LCM OUTPUT",
    's3_obs': "Observation:",
    's3_obs1': "(Product of Numbers) = 6 × 8 = 48",
    's3_obs2': "(Product of HCF & LCM) = 2 × 24 = 48",
    's3_obs3': "They are equal!",
    's3_obs4': "This shows that for any two\nnumbers a and b,\na × b = HCF(a,b) × LCM(a,b).",
    'lbl_s4_breaker_size': "Breaker Size",
    'lbl_s4_break': "BREAK",
    'lbl_s4_units': "Units",
    'lbl_s4_leftover': "LEFTOVER",
    'lbl_s4_waste': "WASTE COUNTER:",
    'lbl_s4_nowaste': "NO WASTE",
    'lbl_s4_finalans': "FINAL ANSWER",
    'lbl_s4_correct': "CORRECT!\nThe largest identical square piece\nthat breaks both bars perfectly is their\nHIGHEST COMMON FACTOR.\nHCF(18, 24) = 6.",
    's1_title': "1. The Perfect Fit Tiling Challenge",
    's1_obj': "To visually discover that the HCF of two numbers is the side length of the largest square tile that can perfectly cover a rectangular area defined by those numbers.",
    's1_step1_task': "DRAG the 3x3 tile from the toolbox and DROP it onto the floor.",
    's1_step1_out': "The 3x3 tile is placed on the floor, but a red 'GAP' indicator appears along the 16-unit side, showing it won't fit perfectly.",
    's1_step2_task': "The 3x3 tile didn't work. CLICK the 'RESET' button. Now, DRAG the 4x4 tile and DROP it onto the floor.",
    's1_step2_out': "The 4x4 tile is placed, and automatically tiles the entire floor, turning green.",
    's1_step3_task': "The 4x4 tile worked perfectly. Now, CLICK 'RESET' and try the 2x2 tile to see if it also fits.",
    's1_step3_out': "The 2x2 tile also tiles the floor perfectly, turning green.",
    's1_step4_task': "We found two tiles that fit: 2x2 and 4x4. CLICK on the '4x4 TILE (LARGEST)' button to select the answer.",
    's1_step4_out': "Success! The HIGHEST Common Factor (HCF) is 4, which is the largest tile that works. HCF(12, 16) = 4.",
    's1_hud1': "Drag the 3x3 tile to the floor.",
    's1_hud2': "Click Reset, then try the 4x4 tile.",
    's1_hud3': "Click Reset, then try the 2x2 tile.",
    's1_hud4': "Click the 4x4 TILE (LARGEST) button.",
    's2_title': "2. The Cosmic Gear Alignment",
    's2_obj': "Understand that the LCM of two numbers represents the first point in time or distance where two different cycles align again.",
    's2_step1_task': "CLICK the 'RUN' button to start rotating the 6-tooth and 8-tooth gears.",
    's2_step1_out': "The gears begin to rotate. The counters track the number of teeth passed.",
    's2_step2_task': "Observe the simulation. It will automatically stop when the red teeth align at the top again.",
    's2_step2_out': "The gears stop precisely when the red teeth meet at the top again. The counters freeze at 24.",
    's2_step3_task': "CLICK the 'Show Multiples' button to see this visually on a timeline.",
    's2_step3_out': "The LOWEST Common Multiple (LCM) is the first point where the cycles align. LCM(6, 8) = 24.",
    's2_hud1': "Click RUN to rotate gears.",
    's2_hud2': "Wait for alignment.",
    's2_hud3': "Click Show Multiples.",
    's3_title': "3. The HCF-LCM Product Factory",
    's3_obj': "To visually verify the property that for any two numbers 'a' and 'b', HCF(a, b) × LCM(a, b) = a × b.",
    's3_step1_task': "We will test the numbers 6 and 8. First, let's find their product. DRAG the number block '6' and the number block '8' from the shelf and DROP them onto the 'Product Area' machine.",
    's3_step1_out': "The machine creates a rectangular grid of 6x8 blocks and displays the total count: 48.",
    's3_step2_task': "Now, let's find the HCF and LCM. DRAG the number blocks '6' and '8' and DROP them into the 'HCF/LCM Analyzer' machine.",
    's3_step2_out': "The machine processes the numbers and outputs two new blocks: a '2' block in the HCF output tray and a '24' block in the LCM output tray.",
    's3_step3_task': "We have found HCF=2 and LCM=24. Now, let's find their product. DRAG the '2' block (HCF) and the '24' block (LCM) from the output trays and DROP them onto the second 'Product Area' machine.",
    's3_step3_out': "The second machine creates a rectangular grid of 2x24 blocks and displays the total count: 48.",
    's3_step4_task': "Compare the results from both Product Areas.",
    's3_step4_out': "Observation: (Product of Numbers) = 6 × 8 = 48. (Product of HCF & LCM) = 2 × 24 = 48. They are equal! This shows that for any two numbers a and b, a × b = HCF(a,b) × LCM(a,b).",
    's3_hud1': "Drag block 6 and 8 to Product Area 1.",
    's3_hud2': "Drag block 6 and 8 to the Analyzer.",
    's3_hud3': "Drag HCF and LCM to Product Area 2.",
    's3_hud4': "Observe the relationship.",
    's4_title': "4. The Chocolate Breaker Challenge",
    's4_obj': "Apply the concept of HCF to find the largest possible identical square piece that can be cut from two different bars without waste.",
    's4_step1_task': "Set the 'Breaker Size' slider to 4, then CLICK 'BREAK' to test it on the 18 and 24-unit bars.",
    's4_step1_out': "A size of 4 works perfectly for the 24-unit bar, but leaves a 2-unit waste for the 18-unit bar.",
    's4_step2_task': "Use the slider and BREAK button to find the LARGEST size that results in a 'Waste' of 0 for BOTH bars.",
    's4_step2_out': "Testing shows sizes 1, 2, 3, and 6 leave zero waste. 6 is the largest.",
    's4_step3_task': "DRAG the number '6' from the slider display into the final answer box.",
    's4_step3_out': "Correct! The largest square piece that can break both bars perfectly is their Highest Common Factor. HCF(18, 24) = 6.",
    's4_hud1': "Slide to size 4 and click BREAK.",
    's4_hud2': "Find largest size with 0 waste for both.",
    's4_hud3': "Drag the correct size to the answer box.",
    's5_title': "5. The Lighthouse Sync Challenge",
    's5_obj': "Apply the concept of LCM to determine when two periodically occurring events will happen simultaneously.",
    's5_step1_task': "Lighthouse A flashes every 9s, B flashes every 12s. CLICK 'PLAY' to watch the simulation.",
    's5_step1_out': "Light pulses appear on the timelines every 9s and 12s respectively.",
    's5_step2_task': "Find the FIRST point on the timeline where pulses align perfectly. PAUSE and DRAG the cursor to inspect.",
    's5_step2_out': "The pulses align for the first time at the 36-second mark.",
    's5_step3_task': "Click the up/down arrows to enter the time of the next simultaneous flash, then click SUBMIT.",
    's5_step3_out': "Perfect Timing! The first time the flashes sync up again is at their Lowest Common Multiple. LCM(9, 12) = 36 seconds.",
    's5_hud1': "Click PLAY to start timelines.",
    's5_hud2': "Find where pulses align on the timeline.",
    's5_hud3': "Enter the time in seconds and SUBMIT."
  },
  'hi': {
    'shutterTitle': "द कॉमन ग्राउंड लैब: HCF-LCM गुण और संबंध की जाँच",
    'appTitle': "द कॉमन ग्राउंड लैब",
    'appSubtitle': "कक्षा 7 • सामान्य आधार खोजना",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "अवलोकन:",
    'closeBtn': "बंद करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "लैब समाप्त करें",
    'finalDesc': "आपने HCF और LCM के गुणों और संबंधों का सफलतापूर्वक पता लगाया है!",
    'scenCompleteTitle': "परिदृश्य पूरा हुआ!",
    'scenComplete': "यह परिदृश्य पूरा हो गया है। कृपया ऊपर दिए गए ड्रॉपडाउन से एक और परिदृश्य चुनें।",
    'lbl_reset': "रीसेट",
    'lbl_gap': "अंतर",
    'lbl_success': "सफलता!",
    's1_wall12': "12",
    's1_wall16': "16",
    's1_toolbox': "टूलबॉक्स:",
    's1_sq_tiles': "चौकोर टाइलें",
    's1_auto_perf': "ऑटो-टाइलिंग: एकदम सही फिट!",
    's1_auto_also': "ऑटो-टाइलिंग: यह भी फिट है!",
    's1_entire_floor': " पूरा फर्श टाइल किया गया।",
    's1_side12': "12-इकाई पक्ष",
    's1_side16': "16-इकाई पक्ष",
    's1_fit_sizes': "फिटिंग टाइल आकार:",
    's1_btn_largest': "4x4 टाइल (सबसे बड़ी)",
    's1_learn_hcf': "सीखने का परिणाम: HCF",
    's1_hcf_text1': "12 और 16 के सामान्य गुणनखंड\nवे टाइल आकार हैं जो पूरी तरह से फिट होते हैं:\n(1, 2, 4)।",
    's1_hcf_text2': "उच्चतम सामान्य गुणनखंड (HCF)\n4 है, जो काम करने वाली\nसबसे बड़ी चौकोर टाइल है।",
    's1_hcf_eq': "HCF(12, 16) = 4.",
    's2_gearA': "गियर A (6 दांत)",
    's2_gearB': "गियर B (8 दांत)",
    's2_run': "चलाएं",
    's2_show_mult': "गुणज दिखाएं",
    's2_aligned': "संरेखित!",
    's2_mult6': "6 के गुणज",
    's2_mult8': "8 के गुणज",
    's2_lcm_msg': "सबसे छोटा सामान्य गुणज (LCM) वह पहला बिंदु है जहां चक्र संरेखित होते हैं।",
    's2_lcm_eq': "LCM(6, 8) = 24.",
    's3_prod_area': "उत्पाद क्षेत्र",
    's3_analyzer': "HCF/LCM\nविश्लेषक",
    's3_drop_in': "अंदर डालें",
    's3_hcf_out': "HCF आउटपुट",
    's3_lcm_out': "LCM आउटपुट",
    's3_obs': "अवलोकन:",
    's3_obs1': "(संख्याओं का गुणनफल) = 6 × 8 = 48",
    's3_obs2': "(HCF और LCM का गुणनफल) = 2 × 24 = 48",
    's3_obs3': "ये दोनों बराबर हैं!",
    's3_obs4': "यह दर्शाता है कि किन्हीं दो\nसंख्याओं a और b के लिए,\na × b = HCF(a,b) × LCM(a,b) होता है।",
    'lbl_s4_breaker_size': "ब्रेकर आकार",
    'lbl_s4_break': "तोड़ें",
    'lbl_s4_units': "इकाइयां",
    'lbl_s4_leftover': "बचा हुआ",
    'lbl_s4_waste': "कचरा काउंटर:",
    'lbl_s4_nowaste': "कोई कचरा नहीं",
    'lbl_s4_finalans': "अंतिम उत्तर",
    'lbl_s4_correct': "सही!\nसबसे बड़ा एकसमान चौकोर टुकड़ा जो दोनों\nबार को पूरी तरह से तोड़ता है, उनका\nउच्चतम सामान्य गुणनखंड है।\nHCF(18, 24) = 6.",
    's1_title': "1. द परफेक्ट फिट टाइलिंग चैलेंज",
    's1_obj': "दृश्य रूप से यह खोजने के लिए कि दो संख्याओं का HCF सबसे बड़ी चौकोर टाइल की भुजा की लंबाई है जो उन संख्याओं द्वारा परिभाषित एक आयताकार क्षेत्र को पूरी तरह से कवर कर सकती है।",
    's1_step1_task': "टूलबॉक्स से 3x3 टाइल को DRAG (खींचें) करें और इसे फर्श पर DROP (छोड़ें) करें।",
    's1_step1_out': "3x3 टाइल को फर्श पर रखा गया है, लेकिन 16-इकाई वाली भुजा के साथ एक लाल 'GAP' (अंतर) संकेतक दिखाई देता है, जो दर्शाता है कि यह पूरी तरह से फिट नहीं होगा।",
    's1_step2_task': "3x3 टाइल काम नहीं आई। 'RESET' बटन पर CLICK (क्लिक) करें। अब, 4x4 टाइल को DRAG करें और फर्श पर DROP करें।",
    's1_step2_out': "4x4 टाइल रखी गई है, और यह स्वचालित रूप से पूरे फर्श को कवर कर लेती है, जिससे यह हरा हो जाता है।",
    's1_step3_task': "4x4 टाइल पूरी तरह से काम कर गई। अब, 'RESET' पर क्लिक करें और 2x2 टाइल का प्रयास करें यह देखने के लिए कि क्या यह भी फिट होती है।",
    's1_step3_out': "2x2 टाइल भी फर्श को पूरी तरह से कवर करती है, जिससे यह हरा हो जाता है।",
    's1_step4_task': "हमें दो टाइलें मिलीं जो फिट होती हैं: 2x2 और 4x4। उत्तर का चयन करने के लिए '4x4 TILE (सबसे बड़ी)' बटन पर क्लिक करें।",
    's1_step4_out': "सफलता! उच्चतम सामान्य गुणनखंड (HCF) 4 है, जो काम करने वाली सबसे बड़ी टाइल है। HCF(12, 16) = 4.",
    's1_hud1': "3x3 टाइल को फर्श पर खींचें।",
    's1_hud2': "रीसेट पर क्लिक करें, फिर 4x4 टाइल आज़माएं।",
    's1_hud3': "रीसेट पर क्लिक करें, फिर 2x2 टाइल आज़माएं।",
    's1_hud4': "4x4 TILE (सबसे बड़ी) बटन पर क्लिक करें।",
    's2_title': "2. द कॉस्मिक गियर अलाइनमेंट",
    's2_obj': "यह समझें कि दो संख्याओं का LCM समय या दूरी में वह पहला बिंदु दर्शाता है जहाँ दो अलग-अलग चक्र फिर से संरेखित होते हैं।",
    's2_step1_task': "6-दांत और 8-दांत वाले गियर्स को घुमाना शुरू करने के लिए 'RUN' बटन पर CLICK करें।",
    's2_step1_out': "गियर घुमना शुरू कर देते हैं। काउंटर गुजरने वाले दांतों की संख्या को ट्रैक करते हैं।",
    's2_step2_task': "सिमुलेशन को देखें। यह स्वचालित रूप से रुक जाएगा जब लाल दांत शीर्ष पर फिर से एक साथ आ जाएंगे।",
    's2_step2_out': "गियर्स ठीक उसी समय रुक जाते हैं जब लाल दांत शीर्ष पर फिर से मिलते हैं। काउंटर 24 पर रुक जाते हैं।",
    's2_step3_task': "इसे एक टाइमलाइन पर दृश्य रूप से देखने के लिए 'Show Multiples' बटन पर CLICK करें।",
    's2_step3_out': "सबसे छोटा सामान्य गुणज (LCM) वह पहला बिंदु है जहां चक्र संरेखित होते हैं। LCM(6, 8) = 24.",
    's2_hud1': "गियर्स को घुमाने के लिए RUN पर क्लिक करें।",
    's2_hud2': "संरेखण की प्रतीक्षा करें।",
    's2_hud3': "Show Multiples पर क्लिक करें।",
    's3_title': "3. द HCF-LCM प्रोडक्ट फैक्टरी",
    's3_obj': "इस गुण को दृश्य रूप से सत्यापित करने के लिए कि किन्हीं दो संख्याओं 'a' और 'b' के लिए, HCF(a, b) × LCM(a, b) = a × b होता है।",
    's3_step1_task': "हम संख्याओं 6 और 8 का परीक्षण करेंगे। सबसे पहले, आइए उनका गुणनफल ज्ञात करें। संख्या ब्लॉक '6' और संख्या ब्लॉक '8' को शेल्फ से DRAG करें और उन्हें 'Product Area' मशीन पर DROP करें।",
    's3_step1_out': "मशीन 6x8 ब्लॉक्स का एक आयताकार ग्रिड बनाती है और कुल गिनती प्रदर्शित करती है: 48।",
    's3_step2_task': "अब, आइए HCF और LCM ज्ञात करें। संख्या ब्लॉक '6' और '8' को DRAG करें और उन्हें 'HCF/LCM Analyzer' मशीन में DROP करें।",
    's3_step2_out': "मशीन संख्याओं को प्रोसेस करती है और दो नए ब्लॉक आउटपुट करती है: HCF आउटपुट ट्रे में एक '2' ब्लॉक और LCM आउटपुट ट्रे में एक '24' ब्लॉक।",
    's3_step3_task': "हमने HCF=2 और LCM=24 पाया है। अब, आइए उनका गुणनफल ज्ञात करें। आउटपुट ट्रे से '2' ब्लॉक (HCF) और '24' ब्लॉक (LCM) को DRAG करें और उन्हें दूसरी 'Product Area' मशीन पर DROP करें।",
    's3_step3_out': "दूसरी मशीन 2x24 ब्लॉक्स का एक आयताकार ग्रिड बनाती है और कुल गिनती प्रदर्शित करती है: 48।",
    's3_step4_task': "दोनों उत्पाद क्षेत्रों (Product Areas) से परिणामों की तुलना करें।",
    's3_step4_out': "अवलोकन: (संख्याओं का गुणनफल) = 6 × 8 = 48. (HCF और LCM का गुणनफल) = 2 × 24 = 48. ये दोनों बराबर हैं! यह दर्शाता है कि किन्हीं दो संख्याओं a और b के लिए, a × b = HCF(a,b) × LCM(a,b) होता है।",
    's3_hud1': "ब्लॉक 6 और 8 को Product Area 1 में खींचें।",
    's3_hud2': "ब्लॉक 6 और 8 को Analyzer में खींचें।",
    's3_hud3': "HCF और LCM को Product Area 2 में खींचें।",
    's3_hud4': "संबंध का निरीक्षण करें।",
    's4_title': "4. द चॉकलेट ब्रेकर चैलेंज",
    's4_obj': "HCF की अवधारणा को लागू करके सबसे बड़ा एकसमान चौकोर टुकड़ा ज्ञात करें जिसे बिना कचरा (waste) छोड़े दो अलग-अलग बारों से काटा जा सकता है।",
    's4_step1_task': "'Breaker Size' स्लाइडर को 4 पर सेट करें, फिर 18 और 24-इकाई वाले बार पर इसका परीक्षण करने के लिए 'BREAK' पर CLICK करें।",
    's4_step1_out': "4 का आकार 24-इकाई वाले बार के लिए पूरी तरह से काम करता है, लेकिन 18-इकाई वाले बार के लिए 2-इकाई का कचरा छोड़ देता है।",
    's4_step2_task': "स्लाइडर और BREAK बटन का उपयोग करके वह सबसे बड़ा (LARGEST) आकार ज्ञात करें जो दोनों बारों के लिए 0 'कचरा' उत्पन्न करता हो।",
    's4_step2_out': "परीक्षण से पता चलता है कि आकार 1, 2, 3 और 6 कोई कचरा नहीं छोड़ते हैं। 6 सबसे बड़ा है।",
    's4_step3_task': "स्लाइडर डिस्प्ले से संख्या '6' को अंतिम उत्तर बॉक्स (final answer box) में DRAG करें।",
    's4_step3_out': "सही! सबसे बड़ा चौकोर टुकड़ा जो दोनों बार को पूरी तरह से तोड़ सकता है, वह उनका उच्चतम सामान्य गुणनखंड है। HCF(18, 24) = 6.",
    's4_hud1': "आकार 4 पर स्लाइड करें और BREAK पर क्लिक करें।",
    's4_hud2': "दोनों के लिए 0 कचरा वाला सबसे बड़ा आकार ज्ञात करें।",
    's4_hud3': "सही आकार को उत्तर बॉक्स में खींचें।",
    's5_title': "5. द लाइटहाउस सिंक चैलेंज",
    's5_obj': "यह निर्धारित करने के लिए LCM की अवधारणा को लागू करें कि दो आवधिक रूप से होने वाली घटनाएँ एक साथ कब घटित होंगी।",
    's5_step1_task': "लाइटहाउस A हर 9 सेकंड में चमकता है, और B हर 12 सेकंड में चमकता है। सिमुलेशन देखने के लिए 'PLAY' पर CLICK करें।",
    's5_step1_out': "प्रकाश दालें (pulses) टाइमलाइन पर क्रमशः हर 9 और 12 सेकंड में दिखाई देती हैं।",
    's5_step2_task': "टाइमलाइन पर वह पहला बिंदु ज्ञात करें जहाँ दालें पूरी तरह से संरेखित (align) होती हैं। निरीक्षण करने के लिए PAUSE करें और कर्सर को DRAG करें।",
    's5_step2_out': "प्रकाश दालें पहली बार 36-सेकंड के निशान पर पूरी तरह से संरेखित होती हैं।",
    's5_step3_task': "अगली एक साथ चमकने (flash) का समय दर्ज करने के लिए ऊपर/नीचे तीरों पर क्लिक करें, फिर 'SUBMIT' पर क्लिक करें।",
    's5_step3_out': "बिल्कुल सही! पहली बार चमकें फिर से एक साथ सिंक होती हैं उनके सबसे छोटे सामान्य गुणज पर। LCM(9, 12) = 36 सेकंड।",
    's5_hud1': "टाइमलाइन शुरू करने के लिए PLAY पर क्लिक करें।",
    's5_hud2': "पता करें कि टाइमलाइन पर दालें कहाँ संरेखित होती हैं।",
    's5_hud3': "समय को सेकंड में दर्ज करें और SUBMIT करें।"
  }
};