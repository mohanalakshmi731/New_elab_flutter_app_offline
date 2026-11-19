// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PrinciplesofTilingandTileability(),
  ));
}

class PrinciplesofTilingandTileability extends StatefulWidget {
  const PrinciplesofTilingandTileability({Key? key}) : super(key: key);

  @override
  State<PrinciplesofTilingandTileability> createState() => _PrinciplesofTilingandTileabilityState();
}

class _PrinciplesofTilingandTileabilityState extends State<PrinciplesofTilingandTileability> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showShutter = true;
  String _currentLang = 'en';
  int _currentScenario = 0;
  int _currentStep = 0;
  bool _scenarioCompleted = false;
  
  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3'; 
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  // Canvas State
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;
  
  // Engine State Variables
  double _cellSize = 44.0;
  GridData _grid = GridData(0, 0, []);
  List<DominoTile> _tiles = [];
  ActiveTile? _activeTile;
  
  // Logic Timers & Animations
  double _animationTime = 0;
  double _gridCompleteFlash = 0;
  double _s1AnimProgress = 0;
  bool _s1MathShown = false;
  bool _s2CheckerboardActive = false;
  double _s2HoverTime = 0;
  bool _isAdvancing = false;

  // Dragging State
  bool _isDragging = false;
  Offset _floatingStepPos = const Offset(20, 100);

  // Animations
  late AnimationController _gameLoopController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _gameLoopController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _gameLoopController.addListener(_onGameTick);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScenario(_currentScenario);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _gameLoopController.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    super.dispose();
  }

  void _onGameTick() {
    setState(() {
      _animationTime += 0.016; 
      if (_gridCompleteFlash > 0) _gridCompleteFlash = math.max(0, _gridCompleteFlash - 0.02);
      
      for (var t in _tiles) {
        if (t.rotPhase < 1.0) t.rotPhase = math.min(1.0, t.rotPhase + 0.1);
      }

      if (_currentScenario == 1 && _currentStep >= 2) {
        _s1AnimProgress = math.min(1.0, _s1AnimProgress + 0.015);
      }
    });
  }

  void _fitToScreen() {
    if (!mounted || _grid.cols == 0) return;
    
    double minX = _grid.x - 120; 
    double maxX = _grid.x + _grid.cols * _cellSize + 40; 
    double minY = _grid.y - 40; 
    double maxY = _grid.y + _grid.rows * _cellSize + 80;
    
    minX = math.min(minX, -250.0);

    double paddingX = 120;
    double paddingY = 120;
    
    final size = MediaQuery.sizeOf(context);
    double sidebarW = _isSidebarOpen ? size.width * 0.38 : 0;
    double canvasW = size.width - sidebarW;
    double canvasH = size.height;

    double usableW = math.max(canvasW - paddingX, 100);
    double usableH = math.max(canvasH - paddingY, 100);
    
    double contentW = math.max(maxX - minX, 100);
    double contentH = math.max(maxY - minY, 100);

    double targetScale = math.min(usableW / contentW, usableH / contentH).clamp(0.1, 1.5);
    double centerX = (minX + maxX) / 2;
    double centerY = (minY + maxY) / 2;
    
    setState(() {
      _scale = targetScale;
      _panOffset = Offset(-centerX * targetScale, -centerY * targetScale);
    });
  }

  void _playSound(String type) {
    try {
      switch (type) {
        case 'click':
        case 'snap':
          _clickPlayer.play(AssetSource(_clickUrl));
          break;
        case 'success':
          _successPlayer.play(AssetSource(_successUrl));
          break;
        case 'error':
          _errorPlayer.play(AssetSource(_errorUrl));
          break;
        case 'pop':
          _fxPlayer.play(AssetSource(_alertUrl));
          break;
        case 'shutter':
          _shutterPlayer.play(AssetSource(_shutterUrl));
          break;
      }
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  void _cycleLanguage() {
    _playSound('click');
    setState(() {
      if (_currentLang == 'en') _currentLang = 'hi';
      else _currentLang = 'en';
    });
  }

  void _resetLab() {
    _playSound('pop');
    setState(() {
      _currentLang = 'en';
      _showShutter = true;
      _loadScenario(0);
    });
  }

  void _loadScenario(int index) {
    _currentScenario = index;
    _currentStep = 0;
    _scenarioCompleted = false;
    _isAdvancing = false;
    _tiles.clear();
    _activeTile = null;
    _gridCompleteFlash = 0;
    
    if (index == 0) {
      _grid = GridData(6, 4, []);
    } else if (index == 1) {
      _grid = GridData(7, 5, []);
      _s1AnimProgress = 0;
      _s1MathShown = false;
    } else if (index == 2) {
      _grid = GridData(8, 8, [const PointIndex(0,0), const PointIndex(7,7)]);
      _s2CheckerboardActive = false;
      _s2HoverTime = 0;
    }
    
    _fitToScreen();
  }

  Offset _getPalettePos(bool isVertical) {
    final size = MediaQuery.sizeOf(context);
    double sidebarW = _isSidebarOpen ? size.width * 0.38 : 0;
    double canvasW = size.width - sidebarW;
    double px = -canvasW/2 / _scale + 80;
    double py = isVertical ? 20 : -60;
    return Offset(px, py);
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_isAdvancing || _scenarioCompleted) return;
    if (_currentScenario == 1 && _currentStep > 0) return;
    if (_currentScenario == 2 && _currentStep > 0 && _currentStep < 2) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.focalPoint);
    final Offset worldPos = _screenToWorld(localPos);
    
    _isDragging = false;

    int clickedIdx = -1;
    for (int i = _tiles.length - 1; i >= 0; i--) {
      DominoTile t = _tiles[i];
      if (t.rotPhase < 1.0) continue; 
      
      Offset p = _grid.getPos(t.c, t.r, _cellSize);
      double tw = t.isVertical ? _cellSize : _cellSize * 2;
      double th = t.isVertical ? _cellSize * 2 : _cellSize;
      
      if (worldPos.dx >= p.dx && worldPos.dx <= p.dx + tw && worldPos.dy >= p.dy && worldPos.dy <= p.dy + th) {
        clickedIdx = i; break;
      }
    }

    if (clickedIdx != -1) {
      DominoTile t = _tiles[clickedIdx];
      _grid.cells[t.r][t.c] = 0;
      if (t.isVertical && t.r+1 < _grid.rows) _grid.cells[t.r+1][t.c] = 0;
      else if (!t.isVertical && t.c+1 < _grid.cols) _grid.cells[t.r][t.c+1] = 0;

      bool validRot = false;
      if (t.isVertical) {
        if (t.c + 1 < _grid.cols && _grid.cells[t.r][t.c+1] == 0 && _grid.cells[t.r][t.c] != -1 && _grid.cells[t.r][t.c+1] != -1) validRot = true;
      } else {
        if (t.r + 1 < _grid.rows && _grid.cells[t.r+1][t.c] == 0 && _grid.cells[t.r][t.c] != -1 && _grid.cells[t.r+1][t.c] != -1) validRot = true;
      }

      if (validRot) {
        setState(() {
          t.isVertical = !t.isVertical;
          t.rotPhase = 0;
          _grid.cells[t.r][t.c] = 1;
          if (t.isVertical) _grid.cells[t.r+1][t.c] = 1;
          else _grid.cells[t.r][t.c+1] = 1;
          _playSound('click');
        });
        if (_currentScenario == 0 && _currentStep == 1) {
          _isAdvancing = true; Timer(const Duration(milliseconds: 500), _advanceStep);
        }
      } else {
        setState(() {
          _tiles.removeAt(clickedIdx);
          _activeTile = ActiveTile(worldPos.dx, worldPos.dy, t.isVertical);
          _isDragging = true;
          _playSound('pop');
        });
      }
      _evaluateScenarioState();
      return;
    }

    Offset pH = _getPalettePos(false);
    Offset pV = _getPalettePos(true);
    bool inH = worldPos.dx >= pH.dx - _cellSize && worldPos.dx <= pH.dx + _cellSize && worldPos.dy >= pH.dy - _cellSize/2 && worldPos.dy <= pH.dy + _cellSize/2;
    bool inV = worldPos.dx >= pV.dx - _cellSize/2 && worldPos.dx <= pV.dx + _cellSize/2 && worldPos.dy >= pV.dy - _cellSize && worldPos.dy <= pV.dy + _cellSize;

    if (inH || inV) {
      setState(() {
        _activeTile = ActiveTile(worldPos.dx, worldPos.dy, inV);
        _isDragging = true;
        _playSound('click');
      });
      if (_currentScenario == 0 && _currentStep == 0) {
        _isAdvancing = true; Timer(const Duration(milliseconds: 500), _advanceStep);
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      setState(() { _scale = (_scale * details.scale).clamp(0.2, 3.0); _panOffset += details.focalPointDelta; });
      return;
    }
    
    if (_isDragging && _activeTile != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset localPos = box.globalToLocal(details.focalPoint);
      final Offset worldPos = _screenToWorld(localPos);
      
      setState(() {
        _activeTile!.x = worldPos.dx;
        _activeTile!.y = worldPos.dy;
        
        double centerOffset = _cellSize/2;
        double checkX = _activeTile!.x - (_activeTile!.isVertical ? 0 : centerOffset);
        double checkY = _activeTile!.y - (_activeTile!.isVertical ? centerOffset : 0);
        
        int c = ((checkX - _grid.x) / _cellSize).floor();
        int r = ((checkY - _grid.y) / _cellSize).floor();
        
        _activeTile!.hoveredC = null;
        _activeTile!.hoveredR = null;
        _activeTile!.hoverState = null;

        if (c >= -1 && c <= _grid.cols && r >= -1 && r <= _grid.rows) {
          String valid = 'invalid';
          if (c >= 0 && r >= 0 && r < _grid.rows && c < _grid.cols && _grid.cells[r][c] != -1) {
            if (_activeTile!.isVertical) {
              if (r + 1 < _grid.rows && _grid.cells[r+1][c] != -1 && _grid.cells[r][c] == 0 && _grid.cells[r+1][c] == 0) valid = 'valid';
            } else {
              if (c + 1 < _grid.cols && _grid.cells[r][c+1] != -1 && _grid.cells[r][c] == 0 && _grid.cells[r][c+1] == 0) valid = 'valid';
            }
          }
          
          if (valid != 'valid' && _currentScenario == 2 && _currentStep >= 2) {
            if (_activeTile!.isVertical && r + 1 < _grid.rows) valid = 'invalid_s2'; 
            else if (!_activeTile!.isVertical && c + 1 < _grid.cols) valid = 'invalid_s2';
          }
          
          _activeTile!.hoveredC = c;
          _activeTile!.hoveredR = r;
          _activeTile!.hoverState = valid;
        }

        if (_currentScenario == 2 && _currentStep == 2 && _activeTile!.hoverState != null) {
          _s2HoverTime += 0.02;
          if (_s2HoverTime > 2.0 && !_isAdvancing) {
            _playSound('success');
            _isAdvancing = true;
            Timer(const Duration(milliseconds: 500), _advanceStep);
          }
        }
      });
    } else {
      setState(() => _panOffset += details.focalPointDelta);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_isDragging && _activeTile != null) {
      setState(() {
        if (_activeTile!.hoverState == 'valid') {
          int c = _activeTile!.hoveredC!;
          int r = _activeTile!.hoveredR!;
          if (r >= 0 && c >= 0 && r < _grid.rows && c < _grid.cols) {
             _grid.cells[r][c] = 1;
             if (_activeTile!.isVertical && r+1 < _grid.rows) _grid.cells[r+1][c] = 1;
             else if (!_activeTile!.isVertical && c+1 < _grid.cols) _grid.cells[r][c+1] = 1;
             _tiles.add(DominoTile(c, r, _activeTile!.isVertical));
             _playSound('snap');
          }
        } else {
          _playSound('error');
        }
        _activeTile = null;
        _isDragging = false;
        _evaluateScenarioState();
      });
    }
  }

  Offset _screenToWorld(Offset screenPos) {
    final Size size = MediaQuery.of(context).size;
    final double sidebarW = _isSidebarOpen ? size.width * 0.38 : 0;
    final double canvasWidth = size.width - sidebarW;
    
    double cx = screenPos.dx - sidebarW - canvasWidth / 2 - _panOffset.dx;
    double cy = screenPos.dy - size.height / 2 - _panOffset.dy;
    return Offset(cx / _scale, cy / _scale);
  }

  void _evaluateScenarioState() {
    if (_isAdvancing || _scenarioCompleted) return;
    
    if (_currentScenario == 0) {
      if (_currentStep == 2) {
        if (_tiles.length == 12) {
          setState(() => _gridCompleteFlash = 1.0);
          _isAdvancing = true; Timer(const Duration(milliseconds: 1500), _advanceStep);
        }
      }
    } else if (_currentScenario == 1) {
      if (_currentStep == 0) {
        if (_tiles.length == 17) {
          _isAdvancing = true; Timer(const Duration(milliseconds: 1000), _advanceStep);
        }
      } else if (_currentStep == 2) {
        if (_s1MathShown) {
          _s1MathShown = false;
          _isAdvancing = true; Timer(const Duration(milliseconds: 4000), _advanceStep);
        }
      }
    } else if (_currentScenario == 2) {
      if (_currentStep == 0) {
        if (_tiles.length == 3) {
          _isAdvancing = true; Timer(const Duration(milliseconds: 1000), _advanceStep);
        }
      }
    }
  }

  void _advanceStep() {
    if (!mounted) return;
    final stepsList = _i18n[_currentLang]!['scenarios'][_currentScenario]['steps'] as List;
    setState(() {
      _isAdvancing = false;
      if (_currentStep < stepsList.length - 1) {
        _currentStep++;
        _playSound('success');
        
        if (_currentScenario == 0 && _currentStep == 3) Timer(const Duration(seconds: 2), _completeScenario);
        if (_currentScenario == 1 && _currentStep == 3) Timer(const Duration(seconds: 2), _completeScenario);
        if (_currentScenario == 2 && _currentStep == 3) Timer(const Duration(seconds: 2), _completeScenario);
      }
    });
  }

  void _completeScenario() {
    if (_scenarioCompleted || !mounted) return;
    setState(() {
      _scenarioCompleted = true;
      _playSound('success');
    });
  }

  void _actionWhy() {
    if (_currentScenario == 1 && _currentStep == 1) {
      _playSound('click');
      setState(() => _s1MathShown = true);
      _isAdvancing = true; Timer(const Duration(milliseconds: 500), _advanceStep);
    }
  }

  void _actionHint() {
    if (_currentScenario == 2 && _currentStep == 1) {
      _playSound('click');
      setState(() => _s2CheckerboardActive = true);
      _isAdvancing = true; Timer(const Duration(milliseconds: 500), _advanceStep);
    }
  }

  List<TextSpan> _parseBoldText(String text) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    for (var match in exp.allMatches(text)) {
      if (match.start > lastMatchEnd) spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: const TextStyle(fontWeight: FontWeight.normal)));
      spans.add(TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.bold)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) spans.add(TextSpan(text: text.substring(lastMatchEnd), style: const TextStyle(fontWeight: FontWeight.normal)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;
    final tr = _i18n[_currentLang]!;
    final scen = tr['scenarios'][_currentScenario];

    String hudMessage = _scenarioCompleted 
      ? (_currentLang == 'hi' ? "शाबाश! आपने यह निर्माण सफलतापूर्वक पूरा कर लिया है।" : _currentLang == 'te' ? "బాగా చేసారు! మీరు ఈ నిర్మాణాన్ని విజయవంతంగా పూర్తి చేసారు." : "Mission: Achieved! Great job.") 
      : scen['steps'][_currentStep]['hud'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // Center Responsive Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)])
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: ClipRect(
                        child: CustomPaint(
                          painter: TilingPainter(
                            currentScenario: _currentScenario,
                            currentStep: _currentStep,
                            scale: _scale,
                            panOffset: _panOffset,
                            cellSize: _cellSize,
                            grid: _grid,
                            tiles: _tiles,
                            activeTile: _activeTile,
                            animTime: _animationTime,
                            gridCompleteFlash: _gridCompleteFlash,
                            s1AnimProgress: _s1AnimProgress,
                            s2CheckerboardActive: _s2CheckerboardActive,
                            scenarioCompleted: _scenarioCompleted,
                            paletteH: _getPalettePos(false),
                            paletteV: _getPalettePos(true),
                            tCanvas: tr['canvas'],
                          ),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),

            // Canvas Action Buttons Overlay
            if (!_showShutter && !_scenarioCompleted)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isSidebarOpen ? sidebarWidth : 0, 
                right: 0, 
                bottom: 120,
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    children: [
                      if (_currentScenario == 1 && _currentStep == 1)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: _actionWhy,
                          icon: const Icon(Icons.help_outline), label: Text(tr['btnWhy'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      if (_currentScenario == 2 && _currentStep == 1)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: _actionHint,
                          icon: const Icon(Icons.grid_on), label: Text(tr['btnHint'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                    ],
                  ),
                ),
              ),

            // Scrollable HUD Message Overlay / Success Popup
            if (!_showShutter)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isSidebarOpen ? sidebarWidth : 0, 
                right: 0, 
                bottom: 20,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    constraints: const BoxConstraints(maxWidth: 600, maxHeight: 100),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                    ),
                    child: SingleChildScrollView(
                      child: _scenarioCompleted 
                         ? Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                 Icon(Icons.check_circle, color: Colors.green, size: 24), SizedBox(width: 8),
                                 Text("Success!", textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                               ]),
                               const SizedBox(height: 8),
                               Text(hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
                             ],
                           )
                         : Text(hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),

            // Left Sidebar (Scrollable, strictly 38% width, Dark Theme)
            AnimatedPositioned(
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Dark Theme Sidebar
                  border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(5,0))]
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 60), // Spacing for floating top buttons
                    // Header section
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.grid_view, color: Colors.tealAccent, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tr['title'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr['subtitle'],
                            style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(color: Color(0xFF0F172A), border: Border(bottom: BorderSide(color: Colors.white12))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _cycleLanguage,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 32, padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.language, color: Colors.white, size: 16), const SizedBox(width: 8), Text(_currentLang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))]),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _resetLab, icon: const Icon(Icons.refresh, size: 14), label: const Text("Reset", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 32)),
                          )
                        ],
                      ),
                    ),
                    
                    // Scenario Dropdown section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr['selectScenario'].toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.0)
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            isExpanded: true, dropdownColor: const Color(0xFF1E293B), value: _currentScenario,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: List.generate(3, (index) {
                              return DropdownMenuItem(
                                value: index,
                                child: Text(tr['scenarios'][index]['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) {
                                _playSound('click');
                                setState(() => _loadScenario(val));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Mission Objective
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10), padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.withOpacity(0.3))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(tr['missionObj'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                          const SizedBox(height: 4),
                          Text(scen['objective'], style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4)),
                        ]
                      )
                    ),
                    
                    // Steps List
                    ...(scen['steps'] as List).asMap().entries.map((entry) {
                      int idx = entry.key;
                      var step = entry.value;
                      bool isCurrent = idx == _currentStep && !_scenarioCompleted;
                      bool isPast = idx < _currentStep || _scenarioCompleted;
                      
                      if (!isCurrent && !isPast) return const SizedBox.shrink();

                      return Opacity(
                        opacity: isCurrent ? 1.0 : 0.5,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20), padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: isCurrent ? Colors.tealAccent : Colors.white12, width: isCurrent ? 2 : 1),
                            borderRadius: BorderRadius.circular(8), color: isCurrent ? Colors.teal.withOpacity(0.1) : const Color(0xFF0F172A)
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2, right: 8), 
                                child: Icon(isCurrent ? Icons.adjust : Icons.check_circle, color: isCurrent ? Colors.tealAccent : Colors.green, size: 16)
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 13, color: isCurrent ? Colors.white : Colors.white54, height: 1.4),
                                    children: _parseBoldText(step['text'])
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),
                    
                    // Footer
                    Container(
                      padding: const EdgeInsets.all(12), color: Colors.black.withOpacity(0.2), width: double.infinity, 
                      child: const Text("© ZeroScienceLab - Fall in love with math and Science", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54))
                    )
                  ],
                ),
              ),
            ),

            // Top-Left Back Button 
            // Positioned(
            //   top: 16,
            //   left: 16,
            //   child: IconButton(
            //     icon: const Icon(Icons.arrow_back),
            //     color: Colors.white,
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //     style: IconButton.styleFrom(
            //       backgroundColor: Colors.black.withOpacity(0.3),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         side: BorderSide(color: Colors.white.withOpacity(0.1)),
            //       ),
            //       shadowColor: Colors.black26,
            //       elevation: 4
            //     ),
            //   ),
            // ),

            // Top-Left Menu Button (Next to back button)
            Positioned(
              top: 16,
              left: 14,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.tealAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound('click');
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                  Future.delayed(const Duration(milliseconds: 300), _fitToScreen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.teal.withOpacity(0.5)),
                  ),
                  shadowColor: Colors.black26,
                  elevation: 4
                ),
              ),
            ),

            // Floating Active Step (when sidebar closed)
            if (!_isSidebarOpen && !_showShutter && !_scenarioCompleted)
              Positioned(
                left: _floatingStepPos.dx,
                top: _floatingStepPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _floatingStepPos = Offset(
                        (_floatingStepPos.dx + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 280),
                        (_floatingStepPos.dy + details.delta.dy).clamp(0, MediaQuery.of(context).size.height - 100)
                      );
                    });
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.tealAccent),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("STEP ${_currentStep + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                            const Icon(Icons.drag_indicator, color: Colors.white54, size: 16)
                          ],
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                            children: _parseBoldText(tr['scenarios'][_currentScenario]['steps'][_currentStep]['text'])
                          )
                        ),
                      ],
                    ),
                  ),
                )
              ),

            // Shutter Screen
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              top: _showShutter ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.grid_on, color: Colors.tealAccent, size: 80),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          tr['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr['subtitle'],
                        style: const TextStyle(color: Colors.teal, fontSize: 18),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          _playSound('shutter'); 
                          setState(() => _showShutter = false);
                        },
                        icon: const Icon(Icons.play_circle, size: 28),
                        label: Text(
                          tr['enterLab'],
                          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Exact HTML Localization Implementation
  final Map<String, Map<String, dynamic>> _i18n = {
    'en': {
      'title': "Principles of Tiling and Tileability",
      'subtitle': "Class 7 • CONSTRUCTIONS AND TILINGS",
      'selectScenario': "Select Scenario",
      'missionObj': "Mission Objective",
      'btnWhy': "Why?",
      'btnHint': "Apply Checkerboard",
      'enterLab': "Enter Virtual Lab",
      'canvas': {
         'sqRemaining': (int n) => "$n Square${n!=1?'s':''} Remaining",
         'areaGrid': "Area of Grid = 5 x 7 = 35 squares",
         'areaTile': "Area of Tile = 2 squares",
         'whiteSq': "White Squares: 30",
         'blackSq': "Black Squares: 32",
         'tiles': "TILES",
         'covers1W1B': "Covers 1 White, 1 Black",
         'covers2W': "Covers 2 White",
         'covers2B': "Covers 2 Black",
      },
      'scenarios': [
        {
          'title': "1. The Perfect Fit: Tiling a Simple Grid",
          'objective': "To understand the basic rules of tiling by successfully covering a rectangular grid with domino tiles.",
          'steps': [
            {'text': "A 4x6 grid is presented on the screen. A palette on the side contains an infinite supply of 2x1 rectangular tiles. **DRAG** a tile from the palette and **DROP** it onto the grid.", 'hud': "Drag a domino from the palette to the grid."},
            {'text': "**CLICK** on a placed tile to rotate it by 90 degrees, changing its orientation from vertical to horizontal.", 'hud': "Click a placed tile on the grid to rotate it."},
            {'text': "Continue to **DRAG**, **DROP**, and **ROTATE** tiles until the entire 4x6 grid is covered. Tiles cannot be placed on top of each other or outside the grid boundaries.", 'hud': "Fill the grid completely with dominoes."},
            {'text': "Observe the final arrangement.", 'hud': "Perfect! 12 dominoes cover 24 squares exactly."}
          ]
        },
        {
          'title': "2. The Leftover Square: The Area Argument",
          'objective': "To discover that tiling is impossible if the area of the region is not a multiple of the area of the tile.",
          'steps': [
            {'text': "A 5x7 grid is presented. **DRAG** and **DROP** the 2x1 tiles from the palette to try and cover this new grid.", 'hud': "Try to fill this new 5x7 grid with dominoes."},
            {'text': "Click the **Why?** button to analyze your result.", 'hud': "Click 'Why?' to understand what happened."},
            {'text': "Mathematical Analysis.", 'hud': "Calculating total area division..."},
            {'text': "Read the summary.", 'hud': "Area mismatch makes tiling impossible!"}
          ]
        },
        {
          'title': "3. The Impossible Chessboard: The Coloring Argument",
          'objective': "To learn how coloring a grid can prove tiling is impossible, even when the area argument doesn't apply.",
          'steps': [
            {'text': "An 8x8 grid with two opposite corner squares removed is shown. The area is 62 squares. **DRAG** 2x1 tiles to try and tile this region.", 'hud': "Try to tile this modified 8x8 grid."},
            {'text': "**CLICK** the **Apply Checkerboard** button.", 'hud': "Click the button to reveal a hidden pattern."},
            {'text': "**DRAG** a 2x1 tile and move it over the colored grid without dropping it. Observe the squares it covers.", 'hud': "Hover a tile over the board and observe the colors."},
            {'text': "Read the final explanation.", 'hud': "Color imbalance makes tiling impossible!"}
          ]
        }
      ]
    },
    'hi': {
      'title': "टाइलिंग के सिद्धांत और संभाव्यता",
      'subtitle': "कक्षा 7 • संरचनाएं और टिलिंग",
      'selectScenario': "परिदृश्य चुनें",
      'missionObj': "मिशन का उद्देश्य",
      'btnWhy': "क्यों?",
      'btnHint': "चेकरबोर्ड लागू करें",
      'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'canvas': {
         'sqRemaining': (int n) => "$n वर्ग शेष",
         'areaGrid': "ग्रिड का क्षेत्रफल = 5 x 7 = 35 वर्ग",
         'areaTile': "टाइल का क्षेत्रफल = 2 वर्ग",
         'whiteSq': "सफेद वर्ग: 30",
         'blackSq': "काले वर्ग: 32",
         'tiles': "टाइल्स",
         'covers1W1B': "1 सफेद, 1 काला कवर करता है",
         'covers2W': "2 सफेद कवर करता है",
         'covers2B': "2 काले कवर करता है",
      },
      'scenarios': [
        {
          'title': "1. परफेक्ट फिट: एक साधारण ग्रिड की टाइलिंग",
          'objective': "आयताकार ग्रिड को डोमिनो टाइल्स से सफलतापूर्वक कवर करके टाइलिंग के बुनियादी नियमों को समझना।",
          'steps': [
            {'text': "स्क्रीन पर 4x6 का ग्रिड है। पैलेट से एक 2x1 टाइल को ग्रिड पर **खींचें (DRAG)** और **छोड़ें (DROP)**।", 'hud': "पैलेट से डोमिनो को ग्रिड पर खींचें।"},
            {'text': "रखे गए टाइल को 90 डिग्री घुमाने के लिए उस पर **क्लिक** करें।", 'hud': "घुमाने के लिए ग्रिड पर रखे गए टाइल पर क्लिक करें।"},
            {'text': "पूरे 4x6 ग्रिड को कवर करने तक टाइल्स को खींचना, छोड़ना और घुमाना जारी रखें।", 'hud': "ग्रिड को पूरी तरह से डोमिनोज़ से भरें।"},
            {'text': "अंतिम व्यवस्था का निरीक्षण करें।", 'hud': "उत्तम! 12 डोमिनोज़ 24 वर्गों को पूरी तरह से कवर करते हैं।"}
          ]
        },
        {
          'title': "2. बचा हुआ वर्ग: क्षेत्रफल का तर्क",
          'objective': "यह खोजना कि यदि क्षेत्र का क्षेत्रफल टाइल के क्षेत्रफल का गुणज नहीं है तो टाइलिंग असंभव है।",
          'steps': [
            {'text': "एक 5x7 ग्रिड प्रस्तुत किया गया है। इस नए ग्रिड को कवर करने का प्रयास करने के लिए टाइल्स को खींचें और छोड़ें।", 'hud': "इस नए 5x7 ग्रिड को डोमिनोज़ से भरने का प्रयास करें।"},
            {'text': "अपने परिणाम का विश्लेषण करने के लिए **क्यों?** बटन पर क्लिक करें।", 'hud': "क्या हुआ, यह समझने के लिए 'क्यों?' पर क्लिक करें।"},
            {'text': "गणितीय विश्लेषण।", 'hud': "कुल क्षेत्रफल विभाजन की गणना..."},
            {'text': "सारांश पढ़ें।", 'hud': "क्षेत्रफल बेमेल होने के कारण टाइलिंग असंभव है!"}
          ]
        },
        {
          'title': "3. असंभव शतरंज बिसात: रंग भरने का तर्क",
          'objective': "यह सीखना कि ग्रिड को रंगने से यह कैसे साबित हो सकता है कि टाइलिंग असंभव है।",
          'steps': [
            {'text': "दो विपरीत कोनों को हटाकर एक 8x8 ग्रिड दिखाया गया है। टाइल करने का प्रयास करने के लिए 2x1 टाइलें खींचें।", 'hud': "इस संशोधित 8x8 ग्रिड को टाइल करने का प्रयास करें।"},
            {'text': "**चेकरबोर्ड लागू करें** बटन पर क्लिक करें।", 'hud': "छिपा हुआ पैटर्न देखने के लिए बटन पर क्लिक करें।"},
            {'text': "एक 2x1 टाइल को रंगीन ग्रिड के ऊपर ले जाएँ (बिना छोड़े)। इसके द्वारा कवर किए जाने वाले वर्गों का निरीक्षण करें।", 'hud': "बोर्ड के ऊपर एक टाइल घुमाएं और रंगों का निरीक्षण करें।"},
            {'text': "अंतिम स्पष्टीकरण पढ़ें।", 'hud': "रंग असंतुलन के कारण टाइलिंग असंभव है!"}
          ]
        }
      ]
    }
  };
}

// Logical Classes
class PointIndex {
  final int r, c;
  const PointIndex(this.r, this.c);
}

class GridData {
  int cols, rows;
  List<List<int>> cells;
  double x = 0;
  double y = 0;

  GridData(this.cols, this.rows, List<PointIndex> missing) : cells = [] {
    cells = List.generate(rows, (r) => List.generate(cols, (c) => 0));
    for (var m in missing) {
      if (m.r >= 0 && m.r < rows && m.c >= 0 && m.c < cols) {
        cells[m.r][m.c] = -1;
      }
    }
    x = -(cols * 44.0) / 2;
    y = -(rows * 44.0) / 2 + 20;
  }
  
  Offset getPos(int c, int r, double size) {
    return Offset(x + c * size, y + r * size);
  }
}

class DominoTile {
  int c, r;
  bool isVertical;
  double rotPhase;
  DominoTile(this.c, this.r, this.isVertical, [this.rotPhase = 1.0]);
}

class ActiveTile {
  double x, y;
  bool isVertical;
  int? hoveredC, hoveredR;
  String? hoverState; // 'valid', 'invalid', 'invalid_s2'
  ActiveTile(this.x, this.y, this.isVertical);
}

// Native Canvas Rendering
class TilingPainter extends CustomPainter {
  final int currentScenario;
  final int currentStep;
  final double scale;
  final Offset panOffset;
  final double cellSize;
  final GridData grid;
  final List<DominoTile> tiles;
  final ActiveTile? activeTile;
  final double animTime;
  final double gridCompleteFlash;
  final double s1AnimProgress;
  final bool s2CheckerboardActive;
  final bool scenarioCompleted;
  final Offset paletteH;
  final Offset paletteV;
  final Map<String, dynamic> tCanvas;

  TilingPainter({
    required this.currentScenario,
    required this.currentStep,
    required this.scale,
    required this.panOffset,
    required this.cellSize,
    required this.grid,
    required this.tiles,
    required this.activeTile,
    required this.animTime,
    required this.gridCompleteFlash,
    required this.s1AnimProgress,
    required this.s2CheckerboardActive,
    required this.scenarioCompleted,
    required this.paletteH,
    required this.paletteV,
    required this.tCanvas,
  });

  void drawDomino(Canvas canvas, double x, double y, bool isVertical, String state, double rotAngle) {
    double w = isVertical ? cellSize : cellSize * 2;
    double h = isVertical ? cellSize * 2 : cellSize;
    
    canvas.save();
    if (rotAngle != 0) {
      canvas.translate(x + cellSize/2, y + cellSize/2);
      canvas.rotate(rotAngle);
      canvas.translate(-(x + cellSize/2), -(y + cellSize/2));
    }
    
    canvas.translate(x, y);
    
    Color mainCol = const Color(0xFF0EA5E9); 
    Color strokeCol = const Color(0xFF0284C7);
    
    if (state == 'invalid' || state == 'invalid_s2') {
      mainCol = const Color(0xFFF87171); 
      strokeCol = const Color(0xFFB91C1C);
    }
    
    if (state == 'valid') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,0,w,h), const Radius.circular(8)), Paint()..color = Colors.green.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    } else if (state == 'invalid' || state == 'invalid_s2') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,0,w,h), const Radius.circular(8)), Paint()..color = Colors.red.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    } else if (state == 'hover') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 10, w, h), const Radius.circular(8)), Paint()..color = Colors.black38..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 4, w, h), const Radius.circular(8)), Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }

    Rect bodyRect = Rect.fromLTWH(2, 2, w-4, h-4);
    
    Paint p = Paint()..color = mainCol;
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), p);
    
    Paint gradP = Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.3), Colors.black.withOpacity(0.1)]).createShader(bodyRect);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), gradP);

    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 2);

    Paint sep = Paint()..color = Colors.white30..strokeWidth = 2;
    if (isVertical) {
      canvas.drawLine(Offset(6, cellSize), Offset(w-6, cellSize), sep);
    } else {
      canvas.drawLine(Offset(cellSize, 6), Offset(cellSize, h-6), sep);
    }
    canvas.restore();
  }

  void drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    double headlen = 10;
    double dx = to.dx - from.dx;
    double dy = to.dy - from.dy;
    double angle = math.atan2(dy, dx);
    
    Paint lineP = Paint()..color = color..strokeWidth = 3;
    canvas.drawLine(from, to, lineP);
    
    Path head = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - headlen * math.cos(angle - math.pi / 6), to.dy - headlen * math.sin(angle - math.pi / 6))
      ..lineTo(to.dx - headlen * math.cos(angle + math.pi / 6), to.dy - headlen * math.sin(angle + math.pi / 6))
      ..close();
    canvas.drawPath(head, Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panOffset.dx, size.height / 2 + panOffset.dy);
    canvas.scale(scale, scale);

    Paint gridPaint = Paint()..color = Colors.indigoAccent.withOpacity(0.05)..strokeWidth = 1;
    for (double i = -2000; i <= 2000; i += 40) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    if (grid.cols > 0) {
      Paint gridBorder = Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 2;
      Offset? emptyCellPos;

      for (int r=0; r<grid.rows; r++) {
        for (int c=0; c<grid.cols; c++) {
          if (grid.cells[r][c] == -1) continue;
          
          Offset p = grid.getPos(c, r, cellSize);
          if (grid.cells[r][c] == 0) emptyCellPos = p;
          
          Paint cellFill = Paint()..color = Colors.black.withOpacity(0.5);
          
          if (currentScenario == 2 && s2CheckerboardActive) {
            cellFill.color = (r+c)%2 == 0 ? const Color(0xFFF8FAFC) : const Color(0xFF334155);
          } else {
            cellFill.color = const Color(0xFF0F172A).withOpacity(0.5);
          }
          
          canvas.drawRect(Rect.fromLTWH(p.dx, p.dy, cellSize, cellSize), cellFill);
          canvas.drawRect(Rect.fromLTWH(p.dx, p.dy, cellSize, cellSize), gridBorder);
        }
      }

      if (gridCompleteFlash > 0) {
        canvas.drawRect(
          Rect.fromLTWH(grid.x, grid.y, grid.cols * cellSize, grid.rows * cellSize), 
          Paint()..color = Colors.green.withOpacity(gridCompleteFlash * 0.4)
        );
      }

      if (currentScenario == 1 && tiles.length == 17 && emptyCellPos != null) {
        canvas.drawRect(
          Rect.fromLTWH(emptyCellPos.dx, emptyCellPos.dy, cellSize, cellSize),
          Paint()..color = Colors.yellow.withOpacity(0.4 + math.sin(animTime*5)*0.3)
        );
      }
    }

    for (var t in tiles) {
      Offset p = grid.getPos(t.c, t.r, cellSize);
      double rotAngle = 0;
      if (t.rotPhase < 1.0) {
        double ease = 1 - math.pow(1 - t.rotPhase, 3).toDouble();
        rotAngle = t.isVertical ? (-math.pi / 2) * (1 - ease) : (math.pi / 2) * (1 - ease);
      }
      drawDomino(canvas, p.dx, p.dy, t.isVertical, 'normal', rotAngle);
    }

    if (currentScenario == 1) {
      int remaining = 35 - tiles.length * 2;
      TextPainter tp = TextPainter(
        text: TextSpan(text: tCanvas['sqRemaining'](remaining), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(grid.x + (grid.cols*cellSize)/2 - tp.width/2, grid.y - 30));

      if (currentStep >= 2) {
        double ease = 1 - math.pow(1 - s1AnimProgress, 3).toDouble();
        if (ease > 0) {
          double mathCX = grid.x + (grid.cols*cellSize)/2;
          double mathCY = grid.y + (grid.rows*cellSize)/2;
          
          canvas.save();
          canvas.translate(mathCX, mathCY);
          canvas.scale(ease, ease);
          
          Rect mathRect = Rect.fromLTWH(-160, -80, 320, 160);
          canvas.drawRRect(RRect.fromRectAndRadius(mathRect, const Radius.circular(16)), Paint()..color = const Color(0xFF0F172A).withOpacity(0.95));
          canvas.drawRRect(RRect.fromRectAndRadius(mathRect, const Radius.circular(16)), Paint()..color = Colors.teal..style = PaintingStyle.stroke..strokeWidth = 3);
          
          TextPainter text1 = TextPainter(text: TextSpan(text: tCanvas['areaGrid'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
          TextPainter text2 = TextPainter(text: TextSpan(text: tCanvas['areaTile'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
          TextPainter mathTxt1 = TextPainter(text: const TextSpan(text: "35 ÷ 2 = 17", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
          TextPainter mathTxt2 = TextPainter(text: const TextSpan(text: ".5", style: TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
          
          text1.paint(canvas, Offset(-text1.width/2, -40));
          text2.paint(canvas, Offset(-text2.width/2, -10));
          mathTxt1.paint(canvas, Offset(-mathTxt1.width/2 - 10, 30));
          mathTxt2.paint(canvas, Offset(mathTxt1.width/2 - 10, 30));
          canvas.restore();

          if (ease > 0.9 && currentStep == 2) {
            Offset? emptyCell;
            for (int r=0; r<grid.rows; r++) {
              for (int c=0; c<grid.cols; c++) {
                if (grid.cells[r][c] == 0) emptyCell = grid.getPos(c, r, cellSize);
              }
            }
            if (emptyCell != null) {
              drawArrow(canvas, Offset(mathCX + 60, mathCY + 45), Offset(emptyCell.dx + cellSize/2, emptyCell.dy + cellSize/2), Colors.redAccent);
            }
          }
        }
      }
    }

    if (currentScenario == 2 && s2CheckerboardActive) {
       TextPainter t1 = TextPainter(text: TextSpan(text: tCanvas['whiteSq'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
       TextPainter t2 = TextPainter(text: TextSpan(text: tCanvas['blackSq'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
       t1.paint(canvas, Offset(grid.x + 80 - t1.width/2, grid.y - 30));
       t2.paint(canvas, Offset(grid.x + grid.cols*cellSize - 80 - t2.width/2, grid.y - 30));
    }

    if (grid.cols > 0 && !scenarioCompleted && !(currentScenario == 1 && tiles.length == 17)) {
      canvas.save();
      Rect paletteRect = Rect.fromLTWH(paletteH.dx - cellSize - 20, paletteV.dy - cellSize - 40, cellSize*2 + 40, cellSize*3 + 80);
      canvas.drawRRect(RRect.fromRectAndRadius(paletteRect, const Radius.circular(12)), Paint()..color = Colors.white.withOpacity(0.05));
      canvas.drawRRect(RRect.fromRectAndRadius(paletteRect, const Radius.circular(12)), Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 2);
      
      TextPainter tp = TextPainter(text: TextSpan(text: tCanvas['tiles'], style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(paletteH.dx - tp.width/2, paletteV.dy - cellSize - 25));

      if (activeTile == null || activeTile!.isVertical) {
        drawDomino(canvas, paletteH.dx - cellSize, paletteH.dy - cellSize/2, false, 'normal', 0);
      }
      if (activeTile == null || !activeTile!.isVertical) {
        drawDomino(canvas, paletteV.dx - cellSize/2, paletteV.dy - cellSize, true, 'normal', 0);
      }
      canvas.restore();
    }

    if (activeTile != null) {
      double w = activeTile!.isVertical ? cellSize : cellSize * 2;
      double h = activeTile!.isVertical ? cellSize * 2 : cellSize;
      
      if (activeTile!.hoverState != null) {
        double pX = activeTile!.x - w/2;
        double pY = activeTile!.y - h/2;
        
        if (activeTile!.hoveredC != null && activeTile!.hoveredR != null && activeTile!.hoveredC! >= 0 && activeTile!.hoveredR! >= 0) {
          Offset cellPos = grid.getPos(activeTile!.hoveredC!, activeTile!.hoveredR!, cellSize);
          pX = cellPos.dx; pY = cellPos.dy;
        }

        drawDomino(canvas, pX, pY, activeTile!.isVertical, activeTile!.hoverState!, 0);

        if (currentScenario == 2 && currentStep >= 2 && activeTile!.hoveredC! >= 0 && activeTile!.hoveredR! >= 0) {
          int c1 = activeTile!.hoveredC!; int r1 = activeTile!.hoveredR!;
          int c2 = activeTile!.isVertical ? c1 : c1 + 1;
          int r2 = activeTile!.isVertical ? r1 + 1 : r1;
          
          if (r1 < grid.rows && c1 < grid.cols && r2 < grid.rows && c2 < grid.cols) {
            String col1 = (r1+c1)%2 == 0 ? 'W' : 'B';
            String col2 = (r2+c2)%2 == 0 ? 'W' : 'B';
            String info = tCanvas['covers1W1B'];
            if (col1 == 'W' && col2 == 'W') info = tCanvas['covers2W'];
            else if (col1 == 'B' && col2 == 'B') info = tCanvas['covers2B'];
            
            TextPainter infoTxt = TextPainter(text: TextSpan(text: info, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
            infoTxt.paint(canvas, Offset(pX + w/2 - infoTxt.width/2, pY - 20));
            
            Paint hLight = Paint()..style = PaintingStyle.stroke..strokeWidth = 3;
            hLight.color = Colors.redAccent;
            canvas.drawRect(Rect.fromLTWH(grid.getPos(c1, r1, cellSize).dx, grid.getPos(c1, r1, cellSize).dy, cellSize, cellSize), hLight);
            hLight.color = Colors.lightBlueAccent;
            canvas.drawRect(Rect.fromLTWH(grid.getPos(c2, r2, cellSize).dx, grid.getPos(c2, r2, cellSize).dy, cellSize, cellSize), hLight);
          }
        }
      } else {
        drawDomino(canvas, activeTile!.x - w/2, activeTile!.y - h/2, activeTile!.isVertical, 'hover', 0);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TilingPainter oldDelegate) => true;
}