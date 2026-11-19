// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SolvingRealWorldProblemswithFractionOperations());
}

class SolvingRealWorldProblemswithFractionOperations extends StatefulWidget {
  const SolvingRealWorldProblemswithFractionOperations({super.key});

  @override
  State<SolvingRealWorldProblemswithFractionOperations> createState() =>
      _SolvingRealWorldProblemswithFractionOperationsState();
}

class _SolvingRealWorldProblemswithFractionOperationsState
    extends State<SolvingRealWorldProblemswithFractionOperations>
    with TickerProviderStateMixin {
  // App-level States
  String _currentLang = 'en';

  // Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // View States
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;
  bool _showInputOverlay = false;

  final TextEditingController _bakerInputController = TextEditingController();

  // Canvas Viewport States
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  double _lastScale = 1.0;

  // Draggable HUD State (When sidebar is closed)
  Offset _draggableHudOffset = const Offset(20, 80);

  // Mini HUD Message State
  String _hudMessage = '';
  Timer? _hudTimer;

  // Lab States
  int _scenario = 1;
  int _step = 0;

  // Tool / Interaction States
  bool _toolDragging = false;
  double _toolX = 0, _toolY = 0;
  double _toolOrigX = 0, _toolOrigY = 0;

  // S1 States
  final List<bool> _milkDays = List.filled(7, false);
  double _jugLevel = 0;
  bool _animatingPour = false;
  double _glassesPourRot = 0;

  // S2 States
  double _tankLevel = 0;
  double _timerAngle = 0;
  double _timerTarget = 1;
  bool _timerIsRunning = false;

  // S3 States
  double _laceLength = 8;
  int _cutsMade = 0;
  bool _measuringTape = false;
  bool _cutterPlaced = false;

  // S4 States
  final List<String> _landState = List.filled(72, 'grass');
  final List<int> _selectedCells = [];

  // S5 States
  double _flourBagWeight = 5.0;
  int _moldsFilled = 0;
  bool _scoopFull = false;

  Timer? _animTimer;

  // Translation Helper
  String t(String key) {
    return _translations[_currentLang]?[key] ??
        _translations['en']![key] ??
        key;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _loadScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _animTimer?.cancel();
    _hudTimer?.cancel();
    _audioPlayer.dispose();
    _bakerInputController.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'enter':
        url =
            'audio/class7/mixkit_2003.mp3';
        break;
      case 'tick':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
      case 'snap':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
      case 'success':
        url =
            'audio/class7/mixkit_2000.mp3';
        break;
      case 'error':
        url =
            'audio/class7/mixkit_2942.mp3';
        break;
      case 'pour':
      case 'engine':
        url =
            'audio/class7/mixkit_1500.mp3';
        break;
      case 'cut':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
    }
    if (url.isNotEmpty) {
      await _audioPlayer.play(AssetSource(url), volume: 0.5);
    }
  }

  void _cycleLanguage() {
    setState(() {
      if (_currentLang == 'en') {
        _currentLang = 'hi';
      } else if (_currentLang == 'hi') {
        _currentLang = 'te';
      } else {
        _currentLang = 'en';
      }
    });
    _playSound('tick');
  }

  void _resetLab() {
    _playSound('enter');
    setState(() {
      _currentLang = 'en';
      _showCurtain = true;
      _showSuccessPopup = false;
      _loadScenario(1);
    });
  }

  void _showMiniHud(String message) {
    setState(() {
      _hudMessage = message;
    });
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _hudMessage = '');
    });
  }

  void _loadScenario(int scenId) {
    setState(() {
      _scenario = scenId;
      _step = 0;
      _toolDragging = false;
      _cutterPlaced = false;

      // Restore original tool coordinates to place them naturally on the canvas
      if (_scenario == 1) {
        _milkDays.fillRange(0, 7, false);
        _jugLevel = 0;
        _animatingPour = false;
        _glassesPourRot = 0;
        _toolOrigX = 200;
        _toolOrigY = -50;
      } else if (_scenario == 2) {
        _tankLevel = 0;
        _timerAngle = 0;
        _timerTarget = 1;
        _timerIsRunning = false;
      } else if (_scenario == 3) {
        _laceLength = 8;
        _cutsMade = 0;
        _measuringTape = false;
        _toolOrigX = -100;
        _toolOrigY = -150;
      } else if (_scenario == 4) {
        _landState.fillRange(0, 72, 'grass');
        _selectedCells.clear();
        _toolOrigX = -100;
        _toolOrigY = 220;
      } else if (_scenario == 5) {
        _flourBagWeight = 5.0;
        _moldsFilled = 0;
        _scoopFull = false;
        _toolOrigX = -70;
        _toolOrigY = 0;
      }
      _toolX = _toolOrigX;
      _toolY = _toolOrigY;

      _showInputOverlay = false;
      _scale = 1.0;
      _offset = Offset.zero;
      _hudMessage = '';
    });
    _playSound('tick');
  }

  void _advanceStep() {
    int oldStep = _step;
    setState(() {
      _step++;
    });
    _playSound('tick');
    _showMiniHud(t('s${_scenario}_step${oldStep + 1}_out'));
  }

  void _triggerUniversalAction() {
    _playSound('snap');
    if (_scenario == 1) {
      setState(() {
        _animatingPour = true;
        _glassesPourRot = 0;
      });
      _animTimer?.cancel();
      _animTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
        if (!mounted) return;
        setState(() {
          _glassesPourRot += 0.05;
          if (_glassesPourRot >= math.pi / 2) {
            // Allow full tilt for pouring
            _glassesPourRot = math.pi / 2;
            _playSound('pour');
            _jugLevel += 0.05;
            if (_jugLevel >= 3.5) {
              _jugLevel = 3.5;
              _animatingPour = false;
              timer.cancel();
              _advanceStep();
            }
          }
        });
      });
    } else if (_scenario == 2) {
      setState(() {
        _timerIsRunning = true;
      });
      double targetAngle = _timerTarget * math.pi * 2;
      double targetLvl = (_step == 0) ? 0.7 : (7 / 30);
      _animTimer?.cancel();
      _animTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!mounted) return;
        setState(() {
          _timerAngle += 0.05;
          _tankLevel += 0.01;
          if (_timerAngle >= targetAngle) {
            _timerAngle = targetAngle;
            _tankLevel = targetLvl;
            timer.cancel();
            if (_step == 0) {
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (!mounted) return;
                setState(() {
                  _timerAngle = 0;
                  _tankLevel = 0;
                  _timerIsRunning = false;
                  _advanceStep();
                });
              });
            } else {
              _timerIsRunning = false;
              _advanceStep();
            }
          }
        });
      });
    } else if (_scenario == 3) {
      if (_cutterPlaced) {
        setState(() {
          _laceLength -= 0.25;
          _cutsMade++;
          _cutterPlaced = false;
          _toolX = _toolOrigX;
          _toolY = _toolOrigY;
        });
        _playSound('cut');
        if (_step == 1) {
          _advanceStep();
        }
        if (_laceLength <= 0 && _step == 2) {
          _advanceStep();
        }
      } else if (_step == 2) {
        _animTimer?.cancel();
        _animTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (!mounted) return;
          setState(() {
            _laceLength -= 0.25;
            _cutsMade++;
            _playSound('cut');
            if (_laceLength <= 0) {
              _laceLength = 0;
              timer.cancel();
              _advanceStep();
            }
          });
        });
      }
    } else if (_scenario == 4) {
      bool correct =
          _selectedCells.length == 20 &&
          _selectedCells.every((idx) => (idx % 12) >= 7 && (idx ~/ 12) >= 2);
      if (correct) {
        _advanceStep();
      } else {
        _playSound('error');
        _showMiniHud("Incorrect selection. Please refer to the instructions.");
      }
    } else if (_scenario == 5) {
      if (_step == 2) {
        _animTimer?.cancel();
        _animTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (!mounted) return;
          setState(() {
            _moldsFilled++;
            _flourBagWeight -= (1 / 6);
            if (_flourBagWeight < 0.01) _flourBagWeight = 0;
            _playSound('tick');
            if (_moldsFilled >= 30) {
              _moldsFilled = 30;
              _flourBagWeight = 0;
              timer.cancel();
              _advanceStep();
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() => _showInputOverlay = true);
              });
            }
          });
        });
      }
    }
  }

  void _checkBakerInput() {
    int? val = int.tryParse(_bakerInputController.text);
    if (val == 30) {
      setState(() {
        _showInputOverlay = false;
      });
      _playSound('success');
      _advanceStep();
    } else {
      _playSound('error');
      _showMiniHud("That's not correct. Try to divide 5 by 1/6.");
    }
  }

  bool _hitTestTool(
    double wX,
    double wY,
    double tX,
    double tY, {
    double radius = 70,
  }) {
    return math.sqrt(math.pow(wX - tX, 2) + math.pow(wY - tY, 2)) < radius;
  }

  // Handle distinct taps for buttons (S2) and grid clicks (S4)
  void _handleTapUp(TapUpDetails details) {
    Size size = MediaQuery.of(context).size;
    double canvasWidth = _isSidebarOpen ? size.width * 0.60 : size.width;
    Offset center = Offset(canvasWidth / 2, size.height / 2);
    Offset worldPt = (details.localPosition - center - _offset) / _scale;

    double wX = worldPt.dx;
    double wY = worldPt.dy;

    if (_scenario == 2) {
      double btnLeft = 180 - 60, btnTop = -40 + 120 + 40;
      Rect startBtn = Rect.fromLTWH(btnLeft - 20, btnTop - 20, 160, 90);
      if ((_step == 0 || _step == 2) &&
          !_timerIsRunning &&
          startBtn.contains(Offset(wX, wY))) {
        _triggerUniversalAction();
      }
    } else if (_scenario == 4 && _step == 3) {
      int c = ((wX + 300) / 50).floor();
      int r = ((wY + 150) / 50).floor();
      if (r >= 0 &&
          r < 6 &&
          c >= 0 &&
          c < 12 &&
          _landState[r * 12 + c] == 'grass') {
        int idx = r * 12 + c;
        setState(() {
          if (_selectedCells.contains(idx)) {
            _selectedCells.remove(idx);
          } else {
            _selectedCells.add(idx);
          }
        });
        _playSound('tick');
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    _lastScale = _scale;

    Size size = MediaQuery.of(context).size;
    double canvasWidth = _isSidebarOpen ? size.width * 0.60 : size.width;
    Offset center = Offset(canvasWidth / 2, size.height / 2);
    Offset worldPt = (details.localFocalPoint - center - _offset) / _scale;

    double wX = worldPt.dx;
    double wY = worldPt.dy;

    bool hit = false;

    if (_scenario == 1 && _step < 2) {
      if (_hitTestTool(wX, wY, _toolX, _toolY, radius: 80)) hit = true;
    } else if (_scenario == 2) {
      if (_step == 1 && !_timerIsRunning) {
        double cX = 180, cY = -40, cR = 120;
        double handleAng = -math.pi / 2 + (_timerTarget * math.pi * 2);
        double handleX = cX + math.cos(handleAng) * (cR + 15);
        double handleY = cY + math.sin(handleAng) * (cR + 15);
        if (_hitTestTool(wX, wY, handleX, handleY, radius: 80)) hit = true;
      }
    } else if (_scenario == 3) {
      if (_step == 0 && _hitTestTool(wX, wY, _toolX, _toolY, radius: 80)) {
        hit = true;
      }
      if (_step > 0 &&
          _step < 3 &&
          !_cutterPlaced &&
          _hitTestTool(wX, wY, _toolX, _toolY, radius: 80)) {
        hit = true;
      }
    } else if (_scenario == 4) {
      if (_step < 3 && _hitTestTool(wX, wY, _toolX, _toolY, radius: 80)) {
        hit = true;
      }
    } else if (_scenario == 5 && _step < 3) {
      if (_hitTestTool(wX, wY, _toolX, _toolY, radius: 80)) hit = true;
    }

    if (hit) {
      setState(() {
        _toolDragging = true;
      });
      _playSound('tick');
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_toolDragging) {
      Size size = MediaQuery.of(context).size;
      double canvasWidth = _isSidebarOpen ? size.width * 0.60 : size.width;
      Offset center = Offset(canvasWidth / 2, size.height / 2);
      Offset worldPt = (details.localFocalPoint - center - _offset) / _scale;

      setState(() {
        if (_scenario == 2 && _step == 1) {
          double cX = 180, cY = -40;
          double dx = worldPt.dx - cX;
          double dy = worldPt.dy - cY;
          double ang = math.atan2(dy, dx);
          double rawVal = (ang + math.pi / 2) / (math.pi * 2);
          if (rawVal < 0) rawVal += 1;
          if ((rawVal - 0.33).abs() < 0.15) {
            _timerTarget = 0.33;
          } else if ((rawVal - 1).abs() < 0.2) {
            _timerTarget = 1;
          } else {
            _timerTarget = rawVal;
          }
        } else {
          _toolX = worldPt.dx;
          _toolY = worldPt.dy;
        }
      });
    } else {
      setState(() {
        _scale = (_lastScale * details.scale).clamp(0.3, 3.0);
        _offset += details.localFocalPoint - _lastFocalPoint;
        _lastFocalPoint = details.localFocalPoint;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (!_toolDragging) return;
    setState(() {
      _toolDragging = false;

      if (_scenario == 1 && _toolY > -200 && _toolY < -40) {
        int col = ((_toolX + 360) / 105).floor();
        if (col >= 0 && col < 7 && !_milkDays[col]) {
          _milkDays[col] = true;
          _playSound('snap');
          int filled = _milkDays.where((d) => d).length;
          if (filled == 1 && _step == 0) _advanceStep();
          if (filled == 7 && _step == 1) _advanceStep();
        }
      }

      if (_scenario == 2 && (_timerTarget - 0.33).abs() < 0.01) {
        _playSound('snap');
        _advanceStep();
      }

      if (_scenario == 3) {
        if (_step == 0) {
          if (_toolX > -350 && _toolX < 100 && _toolY > -100 && _toolY < 100) {
            _measuringTape = true;
            _playSound('snap');
            _advanceStep();
          }
        } else if (_step == 1 || _step == 2) {
          double cutX = -350 + _laceLength * 50;
          if ((_toolX - cutX).abs() < 120 && _toolY > -100 && _toolY < 150) {
            _cutterPlaced = true;
            _toolX = cutX;
            _toolY = 30;
            _playSound('snap');
            return; // keep placed
          }
        }
      }

      if (_scenario == 4) {
        if (_step == 0 && _toolX < -50) {
          for (int r = 0; r < 6; r++) {
            _landState[r * 12 + 0] = 'road';
            _landState[r * 12 + 1] = 'road';
          }
          _playSound('engine');
          _advanceStep();
        } else if (_step == 1 && _toolX > -150 && _toolX < 150) {
          for (int r = 0; r < 6; r++) {
            for (int c = 2; c < 7; c++) {
              _landState[r * 12 + c] = 'krishna';
            }
          }
          _playSound('snap');
          _advanceStep();
        } else if (_step == 2 && _toolX > 50) {
          for (int r = 0; r < 2; r++) {
            for (int c = 7; c < 12; c++) {
              _landState[r * 12 + c] = 'bora';
            }
          }
          _playSound('snap');
          _advanceStep();
        }
      }

      if (_scenario == 5) {
        if (!_scoopFull && _toolX < -100 && _toolY > -150 && _toolY < 100) {
          _scoopFull = true;
          _playSound('snap');
        } else if (_scoopFull &&
            _toolX > -50 &&
            _toolX < 380 &&
            _toolY > -150 &&
            _toolY < 160) {
          _scoopFull = false;
          _moldsFilled++;
          _flourBagWeight -= (1 / 6);
          if (_flourBagWeight < 0.01) _flourBagWeight = 0;
          _playSound('snap');
          if (_step == 0) _advanceStep();
          if (_step == 1 && _moldsFilled >= 2) _advanceStep();
        }
      }

      // Reset Tool Position if it didn't snap
      if (!_cutterPlaced) {
        _toolX = _toolOrigX;
        _toolY = _toolOrigY;
      }
    });
  }

  int _getStepCount() {
    if (_scenario >= 1 && _scenario <= 5) return 4;
    return 3;
  }

  void _updateDraggableOffset(Offset delta, Size screenSize) {
    setState(() {
      _draggableHudOffset += delta;
      _draggableHudOffset = Offset(
        _draggableHudOffset.dx.clamp(0.0, screenSize.width - 280.0),
        _draggableHudOffset.dy.clamp(0.0, screenSize.height - 150.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pre-calculate texts safely
    final String selectScenarioText = t('selectScenario').toUpperCase();
    final String currentLangText = _currentLang.toUpperCase();
    final String summaryTitleText = t('summaryTitle');
    final String summaryBodyText = t(
      's${_scenario}_sum',
    ).replaceAll('<b>', '').replaceAll('</b>', '');
    final String resetBtnText = t('resetBtn');
    final String appTitleText = t('appTitle');
    final String appSubtitleText = t('appSubtitle');
    final String learnLblText = t('learnLbl');
    final String stepLabelText = t('stepLabel');
    final String nextScenarioText = t('nextScenario');
    final String finishLabText = t('finishLab');
    final String enterLabText = t('enterLab');
    final String labCompletedText = t('labCompleted');
    final String finalDescText = t('finalDesc');
    final String howManyLoavesText = t('howManyLoaves');
    final String submitBtnText = t('submitBtn');

    bool showActionButton = false;
    String actionBtnText = '';

    if (_scenario == 1 && _step == 2 && !_animatingPour && _jugLevel == 0) {
      showActionButton = true;
      actionBtnText = t('combineBtn');
    } else if (_scenario == 3 && _cutterPlaced) {
      showActionButton = true;
      actionBtnText = t('cutBtn');
    } else if (_scenario == 3 &&
        _step == 2 &&
        _laceLength > 0 &&
        !_cutterPlaced) {
      showActionButton = true;
      actionBtnText = t('autoCutBtn');
    } else if (_scenario == 4 &&
        _step == 3 &&
        _selectedCells.length == 20 &&
        _selectedCells.every((idx) => (idx % 12) >= 7 && (idx ~/ 12) >= 2)) {
      showActionButton = true;
      actionBtnText = t('checkBtn');
    } else if (_scenario == 5 && _step == 2 && _moldsFilled < 30) {
      showActionButton = true;
      actionBtnText = t('autoFillBtn');
    }

    bool isScenarioComplete =
        _step >= _getStepCount() - 1 &&
            _scenario != 4 &&
            _scenario != 5 &&
            _step >= 3 ||
        (_step >= _getStepCount() && (_scenario == 4 || _scenario == 5));

    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.40; // Sidebar 40% width as requested

    return MaterialApp(
      title: 'Fraction Factory Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // 1. Fully Zoomable/Panable Custom Canvas Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xFF0F172A),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: _handleTapUp,
                      onScaleStart: _handleScaleStart,
                      onScaleUpdate: _handleScaleUpdate,
                      onScaleEnd: _handleScaleEnd,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: LabCanvasPainter(
                          lang: _currentLang,
                          translate: t,
                          scenario: _scenario,
                          step: _step,
                          toolDragging: _toolDragging,
                          toolX: _toolX,
                          toolY: _toolY,
                          milkDays: _milkDays,
                          jugLevel: _jugLevel,
                          animatingPour: _animatingPour,
                          glassesPourRot: _glassesPourRot,
                          tankLevel: _tankLevel,
                          timerAngle: _timerAngle,
                          timerTarget: _timerTarget,
                          timerIsRunning: _timerIsRunning,
                          laceLength: _laceLength,
                          cutsMade: _cutsMade,
                          measuringTape: _measuringTape,
                          cutterPlaced: _cutterPlaced,
                          landState: _landState,
                          selectedCells: _selectedCells,
                          flourBagWeight: _flourBagWeight,
                          moldsFilled: _moldsFilled,
                          scoopFull: _scoopFull,
                          scale: _scale,
                          offset: _offset,
                        ),
                      ),
                    ),
                  ),

                  // HUD Controls (Zoom/Pan Tools) on Canvas
                  // Positioned(
                  //   left: 80, // Space for menu icon when closed
                  //   top: 16,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: const Color(0x80000000),
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(color: const Color(0x3DFFFFFF)),
                  //     ),
                  //     padding: const EdgeInsets.all(8),
                  //     child: Column(
                  //       children: [
                  //         IconButton(icon: const Icon(Icons.zoom_in), color: Colors.white, tooltip: 'Zoom In', onPressed: _zoomIn),
                  //         IconButton(icon: const Icon(Icons.zoom_out), color: Colors.white, tooltip: 'Zoom Out', onPressed: _zoomOut),
                  //         IconButton(icon: const Icon(Icons.fit_screen), color: Colors.white, tooltip: 'Fit Screen', onPressed: _fitScreen),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // Canvas Action Button (Bottom Center of Canvas)
                  if (showActionButton)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: Text(
                            actionBtnText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _triggerUniversalAction,
                        ),
                      ),
                    ),

                  // Mini HUD Message (Top Center of Canvas)
                  if (_hudMessage.isNotEmpty)
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _hudMessage.isNotEmpty ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _hudMessage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Next / Finish Buttons (Bottom Right of Canvas)
                  if (isScenarioComplete)
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _scenario < 5 ? Colors.green : Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          elevation: 8,
                        ),
                        icon: Icon(
                          _scenario < 5 ? Icons.arrow_forward : Icons.flag,
                        ),
                        label: Text(
                          _scenario < 5 ? nextScenarioText : finishLabText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          if (_scenario < 5) {
                            _loadScenario(_scenario + 1);
                          } else {
                            setState(() => _showSuccessPopup = true);
                          }
                        },
                      ),
                    ),

                  // Draggable Active Step HUD (Visible only when Sidebar is closed)
                  if (!_isSidebarOpen && !isScenarioComplete)
                    Positioned(
                      left: _draggableHudOffset.dx,
                      top: _draggableHudOffset.dy,
                      child: GestureDetector(
                        onPanUpdate:
                            (details) => _updateDraggableOffset(
                              details.delta,
                              MediaQuery.of(context).size,
                            ),
                        child: Container(
                          width: 280,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xE61E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.indigo.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.drag_indicator,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$stepLabelText ${_step + 1}',
                                    style: const TextStyle(
                                      color: Colors.indigoAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t('s${_scenario}_step${_step + 1}_task'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Dynamic Input Overlay (Scenario 5)
            if (_showInputOverlay)
              Positioned.fill(
                child: Container(
                  color: const Color(0x8A000000),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 20),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            howManyLoavesText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _bakerInputController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _checkBakerInput,
                            child: Text(
                              submitBtnText,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Sidebar (Scrollable top to bottom)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xF20F172A),
                  border: Border(right: BorderSide(color: Color(0x3DFFFFFF))),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 80,
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Subtitle
                      Text(
                        appTitleText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appSubtitleText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Language and Reset Buttons neatly wrapped
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(Icons.language, size: 18),
                            label: Text(
                              currentLangText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _cycleLanguage,
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(
                              resetBtnText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _resetLab,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      Text(
                        selectScenarioText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _scenario,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            onChanged: (val) {
                              if (val != null) _loadScenario(val);
                            },
                            items:
                                [1, 2, 3, 4, 5]
                                    .map(
                                      (i) => DropdownMenuItem(
                                        value: i,
                                        child: Text(t('s${i}_title')),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0x33607D8B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    learnLblText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t('s${_scenario}_obj'),
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Steps List
                      ...List.generate(_getStepCount(), (i) {
                        bool isActive = _step == i;
                        bool isPast = _step > i;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? const Color(0x1A3F51B5)
                                    : (isPast
                                        ? const Color(0x0D4CAF50)
                                        : Colors.white10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isActive
                                      ? Colors.indigo
                                      : (isPast
                                          ? const Color(0x4D4CAF50)
                                          : Colors.transparent),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        isActive
                                            ? Colors.indigo
                                            : (isPast
                                                ? Colors.green
                                                : Colors.grey),
                                    child:
                                        isPast
                                            ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                            : Text(
                                              '${i + 1}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$stepLabelText ${i + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isActive
                                              ? Colors.indigo
                                              : (isPast
                                                  ? Colors.green
                                                  : Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t('s${_scenario}_step${i + 1}_task'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // Summary Block
                      if (isScenarioComplete)
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x1A4CAF50),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    summaryTitleText,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                summaryBodyText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      // Footer
                      const SizedBox(height: 32),
                      const Divider(height: 1),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "© ZeroScienceLab - Fall in love with math and Science",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Toggle Sidebar Menu Icon
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 32,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound('tick');
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xCC000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xCCFF9800)),
                  ),
                ),
              ),
            ),

            // Curtain Raiser Overlay
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 48,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.factory,
                                  size: 100,
                                  color: Colors.indigo,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  appTitleText,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  appSubtitleText,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.play_circle_fill,
                                    size: 28,
                                  ),
                                  label: Text(
                                    enterLabText,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    _playSound('enter');
                                    setState(() => _showCurtain = false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Success Popup
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 500,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.flag,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  labCompletedText,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  finalDescText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    resetBtnText,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  onPressed: _resetLab,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 30,
                              ),
                              onPressed:
                                  () =>
                                      setState(() => _showSuccessPopup = false),
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

// Custom Painter for Lab Scenes that applies the dynamic transform internally
class LabCanvasPainter extends CustomPainter {
  final String lang;
  final Function(String) translate;
  final int scenario;
  final int step;
  final bool toolDragging;
  final double toolX, toolY;

  // Viewport transforms
  final double scale;
  final Offset offset;

  // States
  final List<bool> milkDays;
  final double jugLevel;
  final bool animatingPour;
  final double glassesPourRot;
  final double tankLevel;
  final double timerAngle;
  final double timerTarget;
  final bool timerIsRunning;
  final double laceLength;
  final int cutsMade;
  final bool measuringTape;
  final bool cutterPlaced;
  final List<String> landState;
  final List<int> selectedCells;
  final double flourBagWeight;
  final int moldsFilled;
  final bool scoopFull;

  LabCanvasPainter({
    required this.lang,
    required this.translate,
    required this.scenario,
    required this.step,
    required this.toolDragging,
    required this.toolX,
    required this.toolY,
    required this.milkDays,
    required this.jugLevel,
    required this.animatingPour,
    required this.glassesPourRot,
    required this.tankLevel,
    required this.timerAngle,
    required this.timerTarget,
    required this.timerIsRunning,
    required this.laceLength,
    required this.cutsMade,
    required this.measuringTape,
    required this.cutterPlaced,
    required this.landState,
    required this.selectedCells,
    required this.flourBagWeight,
    required this.moldsFilled,
    required this.scoopFull,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Move to center, apply offset and scale exactly as interactive viewport would.
    canvas.translate(size.width / 2 + offset.dx, size.height / 2 + offset.dy);
    canvas.scale(scale);

    if (scenario == 1) {
      _drawScene1(canvas);
    } else if (scenario == 2) {
      _drawScene2(canvas);
    } else if (scenario == 3) {
      _drawScene3(canvas);
    } else if (scenario == 4) {
      _drawScene4(canvas);
    } else if (scenario == 5) {
      _drawScene5(canvas);
    }

    canvas.restore();
  }

  void _drawScene1(Canvas canvas) {
    // Table
    canvas.drawRect(
      const Rect.fromLTWH(-2000, 50, 4000, 1000),
      Paint()..color = const Color(0xFF451A03),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-2000, 50, 4000, 20),
      Paint()..color = const Color(0xFF290F02),
    );

    // Calendar Mat
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-380, -200, 760, 160),
      10,
      const Color(0xFF1E293B),
      strokeColor: const Color(0xFF64748B),
      strokeWidth: 2,
    );
    _drawText(
      canvas,
      translate('s1_cal_title'),
      -360,
      -165,
      fontSize: 24,
      isBold: true,
      color: Colors.white,
      align: TextAlign.left,
    );

    double jX = -30, jY = 180, jW = 140, jH = 160;

    List<String> days = [
      translate('mon'),
      translate('tue'),
      translate('wed'),
      translate('thu'),
      translate('fri'),
      translate('sat'),
      translate('sun'),
    ];
    for (int i = 0; i < 7; i++) {
      double x = -310 + i * 105;
      if (i > 0) {
        canvas.drawLine(
          Offset(x - 52.5, -150),
          Offset(x - 52.5, -40),
          Paint()
            ..color = const Color(0xFF334155)
            ..strokeWidth = 2,
        );
      }

      _drawText(
        canvas,
        days[i],
        x,
        -135,
        fontSize: 12,
        isBold: true,
        color: const Color(0xFFCBD5E1),
      );

      double y = -60; // base of glass

      // If animating pour, rotate the glasses and draw stream directly into jug
      if (milkDays[i] && animatingPour) {
        canvas.save();
        // Calculate progress from rotation (0 to 1)
        double progress = (glassesPourRot / (math.pi / 2.5)).clamp(0.0, 1.0);

        // Define semicircular path above the jug for the glasses to follow
        double angle = math.pi + (i / 6) * math.pi;
        double targetX = jX + math.cos(angle) * 180;
        double targetY = (jY - jH - 30) + math.sin(angle) * 100;

        double currentX = x + (targetX - x) * progress;
        double currentY = y + (targetY - y) * progress;

        int dir = (targetX < jX) ? 1 : -1;
        if (i == 3) dir = 1;

        canvas.translate(currentX, currentY);
        canvas.rotate(glassesPourRot * dir);

        // Draw tilted glass with reducing fill
        _drawGlass(canvas, 0, 0, 0.5 * (1.0 - progress));

        // Draw Milk Stream straight down if it's pouring
        if (progress > 0.3 && progress < 0.95) {
          canvas.rotate(-glassesPourRot * dir); // un-rotate stream
          double streamStartX = dir == 1 ? 15 : -15;
          double streamLength = (jY - (jugLevel / 4) * 140) - currentY;
          canvas.drawPath(
            Path()
              ..moveTo(streamStartX, 10)
              ..lineTo(jX - currentX + (i - 3) * 5, streamLength),
            Paint()
              ..color = const Color(0xCCFFFFFF)
              ..strokeWidth = 6
              ..style = PaintingStyle.stroke,
          );
        }

        canvas.restore();
      } else {
        // Draw normal glass
        _drawGlass(canvas, x, y, milkDays[i] ? 0.5 : 0.0);
      }
    }

    // Jug Handle
    Path handlePath =
        Path()
          ..moveTo(jX + 60, jY - 130)
          ..quadraticBezierTo(jX + 120, jY - 130, jX + 110, jY - 40)
          ..lineTo(jX + 60, jY - 40);
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = const Color(0xB3FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Liquid in Jug
    if (jugLevel > 0) {
      double fillH = (jugLevel / 4) * 140;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(jX, jY - fillH),
          width: jW - 4,
          height: 26,
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(jX - jW / 2 + 2, jY - fillH, jW - 4, fillH),
        Paint()..color = Colors.white,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(jX, jY), width: jW - 4, height: 26),
        Paint()..color = Colors.white,
      );
    }

    // Jug Body
    Path jugPath =
        Path()
          ..moveTo(jX - jW / 2, jY - jH)
          ..lineTo(jX - jW / 2, jY)
          ..arcTo(
            Rect.fromCenter(center: Offset(jX, jY), width: jW, height: 30),
            math.pi,
            -math.pi,
            false,
          )
          ..lineTo(jX + jW / 2, jY - jH)
          ..arcTo(
            Rect.fromCenter(center: Offset(jX, jY - jH), width: jW, height: 30),
            0,
            math.pi,
            false,
          );
    canvas.drawPath(
      jugPath,
      Paint()
        ..color = const Color(0x4DFFFFFF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      jugPath,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Jug scale markings
    for (int i = 1; i <= 4; i++) {
      double markY = jY - (i / 4) * 140;
      canvas.drawLine(
        Offset(jX - jW / 2, markY),
        Offset(jX - jW / 2 + 15, markY),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2,
      );
    }

    // Flat 2D Milk Carton Tool
    if (step < 2) {
      canvas.save();
      canvas.translate(toolX, toolY);
      if (toolDragging) canvas.scale(1.2);

      canvas.drawRect(
        const Rect.fromLTWH(-25, -40, 50, 80),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        const Rect.fromLTWH(-25, -40, 50, 80),
        Paint()
          ..color = const Color(0xFF334155)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      Path sideP =
          Path()
            ..moveTo(25, -40)
            ..lineTo(45, -55)
            ..lineTo(45, 25)
            ..lineTo(25, 40)
            ..close();
      canvas.drawPath(sideP, Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawPath(
        sideP,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      Path top1 =
          Path()
            ..moveTo(-25, -40)
            ..lineTo(-5, -60)
            ..lineTo(25, -40)
            ..close();
      Path top2 =
          Path()
            ..moveTo(-5, -60)
            ..lineTo(15, -75)
            ..lineTo(45, -55)
            ..lineTo(25, -40)
            ..close();
      canvas.drawPath(top1, Paint()..color = Colors.white);
      canvas.drawPath(
        top1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawPath(top2, Paint()..color = Colors.white);
      canvas.drawPath(
        top2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      _drawText(
        canvas,
        translate('milk'),
        0,
        15,
        fontSize: 16,
        isBold: true,
        color: const Color(0xFF3B82F6),
      );

      canvas.restore();
    }
  }

  void _drawGlass(Canvas canvas, double x, double y, double fillLevel) {
    // Back rim
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y - 40), width: 32, height: 10),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF475569)
        ..strokeWidth = 2,
    );

    if (fillLevel > 0) {
      double fillH = 40 * fillLevel; // Max height is 40
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y - fillH), width: 29, height: 9),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(x - 14.5, y - fillH, 29, fillH),
        Paint()..color = Colors.white,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 29, height: 9),
        Paint()..color = Colors.white,
      );
    }

    // Front body
    Path glassPath =
        Path()
          ..moveTo(x - 16, y - 40)
          ..lineTo(x - 14, y)
          ..arcTo(
            Rect.fromCenter(center: Offset(x, y), width: 28, height: 10),
            math.pi,
            -math.pi,
            false,
          )
          ..lineTo(x + 16, y - 40)
          ..arcTo(
            Rect.fromCenter(center: Offset(x, y - 40), width: 32, height: 10),
            0,
            math.pi,
            false,
          );
    canvas.drawPath(
      glassPath,
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      glassPath,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawScene2(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-2000, 150, 4000, 1000),
      Paint()..color = const Color(0xFF1E293B),
    );

    double tX = -280, tY = 150, tW = 260, tH = 280;

    // Tank Back
    canvas.drawRect(
      Rect.fromLTWH(tX, tY - tH, tW, tH),
      Paint()..color = const Color(0xFF64748B),
    );

    double innerX = tX + 40,
        innerY = tY - tH + 40,
        innerW = tW - 100,
        innerH = tH - 80;

    // Water
    if (tankLevel > 0) {
      double fillH = tankLevel * innerH;
      canvas.drawRect(
        Rect.fromLTWH(innerX, innerY + innerH - fillH, innerW, fillH),
        Paint()..color = const Color(0xFF38BDF8),
      );
    }

    // Outer Body Path
    Path bodyP =
        Path()
          ..addRect(Rect.fromLTWH(tX, tY - tH, tW, tH))
          ..addRect(Rect.fromLTWH(innerX, innerY, innerW, innerH))
          ..fillType = PathFillType.evenOdd;
    canvas.drawPath(bodyP, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRect(
      Rect.fromLTWH(tX, tY - tH, tW, tH),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF334155),
    );

    // Gauge
    double gX = innerX + innerW - 40, gY = innerY, gW = 40, gH = innerH;
    canvas.drawRect(
      Rect.fromLTWH(gX, gY, gW, gH),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(gX, gY, gW, gH),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (int i = 0; i <= 10; i++) {
      double y = gY + gH - (i / 10) * gH;
      canvas.drawLine(
        Offset(gX, y),
        Offset(gX + 15, y),
        Paint()..strokeWidth = 2,
      );
      if (i > 0 && i < 10) {
        _drawText(
          canvas,
          '$i',
          gX + 28,
          y - 6,
          fontSize: 12,
          color: Colors.black,
        );
      }
    }

    // Sign Plate
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(tX - 140, tY - tH + 50, 120, 100),
      5,
      const Color(0xFFFEF08A),
      strokeColor: const Color(0xFF854D0E),
    );
    _drawText(
      canvas,
      translate('tapFills'),
      tX - 80,
      tY - tH + 70,
      fontSize: 14,
      color: Colors.black,
      isBold: true,
    );
    _drawText(
      canvas,
      '7/10',
      tX - 80,
      tY - tH + 105,
      fontSize: 32,
      color: Colors.black,
      isBold: true,
    );

    // Stopwatch
    double cX = 180, cY = -40, cR = 120;
    canvas.drawCircle(
      Offset(cX, cY),
      cR + 25,
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawCircle(
      Offset(cX, cY),
      cR + 25,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF334155),
    );
    canvas.drawCircle(Offset(cX, cY), cR, Paint()..color = Colors.white);

    // Highlight sector
    if (step >= 1) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cX, cY), radius: cR),
        -math.pi / 2,
        timerTarget * math.pi * 2,
        true,
        Paint()..color = const Color(0x66FF9800),
      );
    }
    // Sweep
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cX, cY), radius: cR),
      -math.pi / 2,
      timerAngle,
      true,
      Paint()..color = const Color(0x8029B6F6),
    );

    // Hand
    canvas.drawLine(
      Offset(cX, cY),
      Offset(
        cX + math.cos(-math.pi / 2 + timerAngle) * cR,
        cY + math.sin(-math.pi / 2 + timerAngle) * cR,
      ),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cX, cY), 10, Paint()..color = Colors.black);

    // Ticks
    for (int i = 0; i < 60; i++) {
      double ang = -math.pi / 2 + (i / 60) * math.pi * 2;
      double tLen = (i % 5 == 0) ? 15 : 8;
      canvas.drawLine(
        Offset(
          cX + math.cos(ang) * (cR - tLen),
          cY + math.sin(ang) * (cR - tLen),
        ),
        Offset(cX + math.cos(ang) * cR, cY + math.sin(ang) * cR),
        Paint()
          ..color = Colors.black
          ..strokeWidth = (i % 5 == 0) ? 3 : 1,
      );
    }

    // Slider Handle
    if (step == 1 && !timerIsRunning) {
      double hAng = -math.pi / 2 + (timerTarget * math.pi * 2);
      double hX = cX + math.cos(hAng) * (cR + 15);
      double hY = cY + math.sin(hAng) * (cR + 15);
      if (toolDragging) {
        canvas.drawCircle(
          Offset(hX, hY),
          30,
          Paint()..color = const Color(0x80FFEB3B),
        );
      }
      canvas.drawCircle(Offset(hX, hY), 18, Paint()..color = Colors.orange);
      canvas.drawCircle(
        Offset(hX, hY),
        18,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white
          ..strokeWidth = 3,
      );
    }

    // Start Button
    if ((step == 0 || step == 2) && !timerIsRunning) {
      double btnLeft = 180 - 60, btnTop = -40 + 120 + 40;
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(btnLeft - 20, btnTop - 20, 160, 90),
        45,
        const Color(0xFF4CAF50),
        strokeColor: Colors.white,
        strokeWidth: 3,
      );
      _drawText(
        canvas,
        translate('startTimer'),
        btnLeft + 60,
        btnTop + 15,
        fontSize: 24,
        color: Colors.white,
        isBold: true,
      );
    }
  }

  void _drawScene3(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-2000, 50, 4000, 1000),
      Paint()..color = const Color(0xFFDCA574),
    );

    double lX = -350, lY = -50, lH = 80;
    double lW = laceLength * 50;

    // Digital Counter
    double dcX = -100, dcY = -150;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(dcX, dcY, 200, 60),
      10,
      const Color(0xFFE2E8F0),
      strokeColor: const Color(0xFF94A3B8),
    );
    _drawText(
      canvas,
      '${translate('bagsDecorated')}: $cutsMade',
      dcX + 100,
      dcY + 37 - 10,
      color: Colors.black,
      isBold: true,
      fontSize: 18,
    );

    // Lace
    if (laceLength > 0) {
      canvas.drawRect(
        Rect.fromLTWH(lX, lY, lW, lH),
        Paint()..color = Colors.white,
      );
      for (int i = 0; i < lW; i += 20) {
        canvas.drawCircle(
          Offset(lX + i + 10, lY),
          8,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(lX + i + 10, lY + lH),
          8,
          Paint()..color = Colors.white,
        );
      }
    }

    // Ruler
    if (measuringTape) {
      canvas.drawRect(
        Rect.fromLTWH(lX, lY + lH + 20, 8 * 50, 30),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(lX, lY + lH + 20, 8 * 50, 30),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      for (int i = 0; i <= 8; i++) {
        canvas.drawRect(
          Rect.fromLTWH(lX + i * 50 - 1, lY + lH + 20, 3, 15),
          Paint()..color = Colors.black,
        );
        _drawText(
          canvas,
          '$i',
          lX + i * 50,
          lY + lH + 45,
          color: Colors.black,
          fontSize: 14,
        );
      }
    }

    // Bags grid
    double bX = -300, bY = 200;
    for (int i = 0; i < cutsMade; i++) {
      int r = i ~/ 12, c = i % 12;
      _drawFlatBag(canvas, bX + c * 60, bY + r * 60, 1.0);
    }

    // Single target bag template if cutter placed
    if (cutterPlaced) {
      _drawFlatBag(canvas, -200, -100, 1.2);
    }

    // Tools
    if (step == 0) {
      // Ruler Tool (Digital Caliper)
      canvas.save();
      canvas.translate(toolX, toolY);
      if (toolDragging) canvas.scale(1.2);

      canvas.drawRect(
        const Rect.fromLTWH(-80, -10, 160, 20),
        Paint()..color = const Color(0xFFCBD5E1),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-80, -10, 160, 20),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      Path jaw1 =
          Path()
            ..moveTo(-80, -10)
            ..lineTo(-80, 50)
            ..lineTo(-70, 50)
            ..lineTo(-65, -10)
            ..close();
      canvas.drawPath(jaw1, Paint()..color = const Color(0xFFCBD5E1));
      canvas.drawPath(
        jaw1,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      Path jaw2 =
          Path()
            ..moveTo(60, -10)
            ..lineTo(60, 50)
            ..lineTo(70, 50)
            ..lineTo(75, -10)
            ..close();
      canvas.drawPath(jaw2, Paint()..color = const Color(0xFFCBD5E1));
      canvas.drawPath(
        jaw2,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-20, -25, 70, 40),
        5,
        const Color(0xFF1E293B),
        strokeColor: Colors.black,
      );
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-10, -20, 50, 20),
        2,
        const Color(0xFFA3E635),
        strokeColor: const Color(0xFF0F172A),
      );
      _drawText(
        canvas,
        "MEASURE",
        15,
        -10,
        color: Colors.black,
        fontSize: 10,
        isBold: true,
      );

      canvas.restore();
    } else if (step == 1 || step == 2) {
      // Cutter Tool (Rotary)
      canvas.save();
      canvas.translate(toolX, toolY);
      if (toolDragging) canvas.scale(1.2);

      canvas.rotate(math.pi / 6);
      canvas.drawCircle(
        const Offset(0, 15),
        25,
        Paint()..color = const Color(0xFFCBD5E1),
      );
      canvas.drawCircle(
        const Offset(0, 15),
        25,
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      Path handle =
          Path()
            ..moveTo(-10, 0)
            ..quadraticBezierTo(-15, -40, -5, -80)
            ..lineTo(15, -80)
            ..quadraticBezierTo(25, -40, 10, 0);
      canvas.drawPath(handle, Paint()..color = const Color(0xFF334155));
      canvas.drawPath(
        handle,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        Offset.zero,
        12,
        Paint()..color = const Color(0xFFFACC15),
      );
      canvas.drawCircle(
        Offset.zero,
        12,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset.zero,
        4,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      canvas.rotate(-math.pi / 6);

      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-40, -90, 80, 25),
        5,
        const Color(0xFFBAE6FD),
        strokeColor: const Color(0xFF38BDF8),
      );
      _drawText(
        canvas,
        "1/4m Cutter",
        0,
        -75,
        color: const Color(0xFF0F172A),
        fontSize: 12,
        isBold: true,
      );

      canvas.restore();
    }
  }

  void _drawFlatBag(Canvas canvas, double bx, double by, double scale) {
    canvas.save();
    canvas.translate(bx, by);
    canvas.scale(scale);
    canvas.drawArc(
      const Rect.fromLTWH(-10, -25, 20, 20),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.brown[400]!
        ..strokeWidth = 4,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-16, -15, 32, 35),
      Paint()..color = const Color(0xFFFDF4E3),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-16, -15, 32, 35),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.brown[400]!
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-16, -10, 32, 6),
      Paint()..color = Colors.pink[400]!,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-16, 10, 32, 6),
      Paint()..color = Colors.pink[400]!,
    );
    canvas.restore();
  }

  void _drawScene4(Canvas canvas) {
    double cellSize = 50;
    double gW = 12 * cellSize, gH = 6 * cellSize;
    double gX = -300, gY = -150;

    // Base Grid
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(gX - 10, gY - 10, gW + 20, gH + 20),
      10,
      const Color(0xFF1E293B),
    );

    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 12; c++) {
        String type = landState[r * 12 + c];
        Color fill = const Color(0xFF7CB342); // grass
        if (type == 'road') fill = const Color(0xFF737373);
        if (type == 'krishna') fill = const Color(0xFFC5E1A5);
        if (type == 'bora') fill = const Color(0xFF90CAF9);

        canvas.drawRect(
          Rect.fromLTWH(
            gX + c * cellSize,
            gY + r * cellSize,
            cellSize,
            cellSize,
          ),
          Paint()..color = fill,
        );
      }
    }

    // Selection
    if (selectedCells.isNotEmpty) {
      for (var idx in selectedCells) {
        int c = idx % 12, r = idx ~/ 12;
        canvas.drawRect(
          Rect.fromLTWH(
            gX + c * cellSize,
            gY + r * cellSize,
            cellSize,
            cellSize,
          ),
          Paint()..color = const Color(0x80FFC107),
        );
      }
      bool correct =
          selectedCells.length == 20 &&
          selectedCells.every((idx) => (idx % 12) >= 7 && (idx ~/ 12) >= 2);
      if (correct) {
        canvas.drawRect(
          Rect.fromLTWH(
            gX + 7 * cellSize,
            gY + 2 * cellSize,
            5 * cellSize,
            4 * cellSize,
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.orange
            ..strokeWidth = 6,
        );
      }
    }

    // Grid lines
    Paint lineP =
        Paint()
          ..color = Colors.black38
          ..strokeWidth = 2;
    for (int i = 0; i <= 12; i++) {
      canvas.drawLine(
        Offset(gX + i * cellSize, gY),
        Offset(gX + i * cellSize, gY + gH),
        lineP,
      );
    }
    for (int j = 0; j <= 6; j++) {
      canvas.drawLine(
        Offset(gX, gY + j * cellSize),
        Offset(gX + gW, gY + j * cellSize),
        lineP,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(gX, gY, gW, gH),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.black,
    );

    // Decorate HTML-like Visuals
    if (step >= 1) {
      // Road dotted line
      Paint dashP =
          Paint()
            ..color = Colors.white
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke;
      for (double dy = gY + 10; dy < gY + gH - 10; dy += 30) {
        canvas.drawLine(
          Offset(gX + 50, dy),
          Offset(gX + 50, math.min(dy + 15, gY + gH - 10)),
          dashP,
        );
      }
      _drawText(
        canvas,
        "Road (1/6)",
        gX + 50,
        gY + gH - 60,
        color: Colors.white,
        isBold: true,
      );
    }
    if (step >= 2) {
      // Krishna House
      double hX = gX + 225, hY = gY + 100;
      Paint dashP =
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
      for (double dy = gY; dy < gY + gH; dy += 10) {
        canvas.drawLine(
          Offset(gX + 350, dy),
          Offset(gX + 350, math.min(dy + 5, gY + gH)),
          dashP,
        );
      }
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(hX - 25, hY - 15, 50, 40),
        2,
        const Color(0xFFFEF08A),
        strokeColor: Colors.black,
      );
      canvas.drawRect(
        Rect.fromLTWH(hX + 5, hY + 5, 15, 15),
        Paint()..color = const Color(0xFF60A5FA),
      );
      canvas.drawRect(
        Rect.fromLTWH(hX + 5, hY + 5, 15, 15),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      Path roof =
          Path()
            ..moveTo(hX - 35, hY - 15)
            ..lineTo(hX + 35, hY - 15)
            ..lineTo(hX, hY - 45)
            ..close();
      canvas.drawPath(roof, Paint()..color = const Color(0xFFEF4444));
      canvas.drawPath(
        roof,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        "1/2 of Remaining",
        hX,
        hY + 60,
        color: Colors.white,
        isBold: true,
      );
    }
    if (step >= 3) {
      // Bora Barn
      double bX = gX + 475, bY = gY + 40;
      Paint dashP =
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
      for (double dx = gX + 350; dx < gX + gW; dx += 10) {
        canvas.drawLine(
          Offset(dx, gY + 100),
          Offset(math.min(dx + 5, gX + gW), gY + 100),
          dashP,
        );
      }
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(bX - 25, bY - 15, 50, 40),
        2,
        const Color(0xFFD97706),
        strokeColor: Colors.black,
      );
      canvas.drawLine(
        Offset(bX - 25, bY - 15),
        Offset(bX + 25, bY + 25),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      canvas.drawLine(
        Offset(bX + 25, bY - 15),
        Offset(bX - 25, bY + 25),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      Path roof =
          Path()
            ..moveTo(bX - 35, bY - 15)
            ..lineTo(bX + 35, bY - 15)
            ..lineTo(bX, bY - 45)
            ..close();
      canvas.drawPath(roof, Paint()..color = const Color(0xFFB91C1C));
      canvas.drawPath(
        roof,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
    }

    // Tools Drawing
    canvas.save();
    canvas.translate(toolX, toolY);
    if (toolDragging) canvas.scale(1.3);

    if (step == 0) {
      // Tractor HTML Match
      canvas.drawRect(
        const Rect.fromLTWH(-25, -15, 35, 25),
        Paint()..color = const Color(0xFF3B82F6),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-15, -30, 20, 15),
        Paint()..color = const Color(0xFF3B82F6),
      );
      canvas.drawRect(
        const Rect.fromLTWH(10, -5, 15, 10),
        Paint()..color = const Color(0xFF64748B),
      );
      Path blade =
          Path()
            ..moveTo(25, -15)
            ..lineTo(35, -15)
            ..lineTo(35, 10)
            ..lineTo(25, 10)
            ..close();
      canvas.drawPath(blade, Paint()..color = const Color(0xFF94A3B8));
      canvas.drawCircle(
        const Offset(-10, 10),
        12,
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawCircle(
        const Offset(-10, 10),
        12,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        const Offset(15, 10),
        8,
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawCircle(
        const Offset(15, 10),
        8,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
    } else if (step == 1) {
      // Vertical Fence
      canvas.drawRect(
        const Rect.fromLTWH(-5, -25, 10, 50),
        Paint()..color = Colors.brown,
      );
      canvas.drawRect(
        const Rect.fromLTWH(-25, -5, 50, 10),
        Paint()..color = Colors.brown,
      );
    } else if (step == 2) {
      // Horizontal Fence
      canvas.drawRect(
        const Rect.fromLTWH(-25, -5, 50, 10),
        Paint()..color = Colors.brown,
      );
      canvas.drawRect(
        const Rect.fromLTWH(-5, -25, 10, 50),
        Paint()..color = Colors.brown,
      );
    }
    canvas.restore();
  }

  void _drawScene5(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-2000, 50, 4000, 1000),
      Paint()..color = const Color(0xFF3D2E20),
    );

    double bgX = -300, bgY = -50;

    // Flour bag details matching HTML
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(bgX, bgY - 90, 130, 220),
      8,
      Colors.white,
      strokeColor: const Color(0xFF1E293B),
    );
    Path leftPanel =
        Path()
          ..moveTo(bgX + 10, bgY - 85)
          ..lineTo(bgX - 15, bgY - 70)
          ..lineTo(bgX - 15, bgY + 120)
          ..lineTo(bgX + 10, bgY + 130)
          ..close();
    canvas.drawPath(leftPanel, Paint()..color = const Color(0xFF3B82F6));
    canvas.drawPath(
      leftPanel,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );

    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(bgX - 5, bgY - 105, 140, 35),
      5,
      const Color(0xFFF8FAFC),
      strokeColor: Colors.black,
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(bgX - 5, bgY - 105, 140, 8),
      3,
      const Color(0xFF3B82F6),
      strokeColor: Colors.black,
    );

    // Face
    canvas.drawCircle(Offset(bgX + 45, bgY), 5, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(bgX + 85, bgY), 5, Paint()..color = Colors.black);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(bgX + 65, bgY + 5), radius: 8),
      0,
      math.pi,
      false,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bgX + 30, bgY + 5), width: 16, height: 8),
      Paint()..color = const Color(0xFFFCA5A5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bgX + 100, bgY + 5), width: 16, height: 8),
      Paint()..color = const Color(0xFFFCA5A5),
    );

    _drawText(
      canvas,
      translate('flour'),
      bgX + 65,
      bgY - 40 - 12,
      fontSize: 24,
      isBold: true,
      color: const Color(0xFF0F172A),
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(bgX + 20, bgY + 50, 90, 45),
      5,
      const Color(0xFF1E3A8A),
    );
    _drawText(
      canvas,
      '${flourBagWeight.toStringAsFixed(2)} kg',
      bgX + 65,
      bgY + 70 - 10,
      fontSize: 20,
      isBold: true,
      color: Colors.lightBlueAccent,
    );

    // Tray
    double trX = -50, trY = -120;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(trX, trY, 360, 260),
      10,
      const Color(0xFF475569),
      strokeColor: const Color(0xFF1E293B),
    );

    for (int i = 0; i < 30; i++) {
      int r = i ~/ 6, c = i % 6;
      double mX = trX + 15 + c * 55, mY = trY + 15 + r * 48;
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(mX, mY, 45, 38),
        5,
        const Color(0xFF1E293B),
      );
      if (i < moldsFilled) {
        _drawRoundedRect(
          canvas,
          Rect.fromLTWH(mX + 5, mY + 5, 35, 28),
          10,
          const Color(0xFFFDE047),
          strokeColor: const Color(0xFFEAB308),
        );
      }
    }

    if (step < 3) {
      canvas.save();
      canvas.translate(toolX, toolY);
      if (toolDragging) canvas.scale(1.2);

      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(15, -45, 12, 45),
        6,
        const Color(0xFFCBD5E1),
        strokeColor: Colors.black,
      );
      Path bowl =
          Path()
            ..moveTo(-35, -15)
            ..lineTo(20, -15)
            ..quadraticBezierTo(30, 10, 15, 25)
            ..lineTo(-25, 25)
            ..quadraticBezierTo(-45, 10, -35, -15)
            ..close();
      canvas.drawPath(bowl, Paint()..color = const Color(0xFF94A3B8));
      canvas.drawPath(
        bowl,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-5, -15), width: 60, height: 20),
        Paint()..color = const Color(0xFFCBD5E1),
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-5, -15), width: 60, height: 20),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );

      if (scoopFull) {
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(-5, -15), width: 50, height: 12),
          Paint()..color = const Color(0xFFFDE047),
        );
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(-5, -15), radius: 20),
          math.pi,
          math.pi,
          true,
          Paint()..color = const Color(0xFFFDE047),
        );
      }

      canvas.restore();
    }
  }

  void _drawRoundedRect(
    Canvas canvas,
    Rect rect,
    double radius,
    Color fill, {
    Color? strokeColor,
    double strokeWidth = 2,
  }) {
    RRect r = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(r, Paint()..color = fill);
    if (strokeColor != null) {
      canvas.drawRRect(
        r,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 14,
    Color color = Colors.black,
    bool isBold = false,
    TextAlign align = TextAlign.center,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tp.layout();
    if (align == TextAlign.center) {
      tp.paint(canvas, Offset(x - tp.width / 2, y));
    } else {
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant LabCanvasPainter oldDelegate) => true;
}

const Map<String, Map<String, String>> _translations = {
  'en': {
    'appTitle': "The Fraction Factory: Building Real-World Solutions",
    'appSubtitle': "Class 7 • WORKING WITH FRACTIONS",
    'enterLab': "Enter Lab",
    'settings': "Settings",
    'theme': "Theme",
    'darkMode': "Switch to Dark Mode",
    'lightMode': "Switch to Light Mode",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "What We Learn:",
    'checkAns': "Check Answer",
    'closeBtn': "Close",
    'summaryTitle': "Equation Observed",
    'resetBtn': "Reset",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'labCompleted': "Lab Completed!",
    'finalDesc':
        "You have successfully modeled real-world problems using fractions! You learned how to find fractions of amounts, divide resources, and visually map operations to practical situations.",
    'taskInst': "Task Instructions:",
    'expOut': "Expected Outcome:",
    'submitBtn': "Submit",
    'checkBtn': "Check Selected Area",
    'combineBtn': "Combine Milk",
    'startTimer': "START",
    'cutBtn': "Cut 1/4m",
    'autoCutBtn': "Auto-Cut Rest",
    'autoFillBtn': "Auto-Fill Rest",
    'milk': "MILK",
    'mon': "Monday",
    'tue': "Tuesday",
    'wed': "Wednesday",
    'thu': "Thursday",
    'fri': "Friday",
    'sat': "Saturday",
    'sun': "Sunday",
    's1_cal_title': "Tenzin's Weekly Milk Supply",
    'tapFills': "TAP FILLS",
    'inOneHour': "in 1 HOUR",
    'howManyLoaves': "How many full loaves?",
    's1_title': "1. Tenzin's Weekly Milk Supply",
    's1_obj':
        "To visually calculate the total amount of milk Tenzin drinks in one week by multiplying a whole number (days) by a fraction (glass of milk).",
    's1_step1_task':
        "On the table, you see a weekly calendar and a carton of milk. DRAG the milk carton and DROP it onto the 'Monday' slot on the calendar.",
    's1_step1_out':
        "A single glass, visually filled exactly to the 1/2 mark, appears next to the Monday slot.",
    's1_step2_task':
        "Repeat the process for the other 6 days of the week. DRAG the milk carton and DROP it onto the remaining days.",
    's1_step2_out':
        "A 1/2-full glass of milk appears next to each day of the week. There are now a total of 7 half-full glasses.",
    's1_step3_task':
        "A large, empty measuring jug appears on the table. CLICK the 'Combine Milk' button.",
    's1_step3_out':
        "The 7 half-full glasses animate, pouring their contents into the large measuring jug. The milk level stops at the 3 1/2 mark.",
    's1_step4_task':
        "Observe the final result in the measuring jug. An equation appears on the screen.",
    's1_step4_out':
        "The equation 7 days × 1/2 glass/day = 7/2 glasses = 3 1/2 glasses is displayed clearly.",
    's1_sum': "7 days × 1/2 glass/day = 7/2 = 3 1/2 glasses",
    's2_title': "2. The Leaky Water Tank",
    's2_obj':
        "To understand the multiplication of two fractions by calculating how much of a tank gets filled in a fraction of an hour.",
    's2_step1_task':
        "A large water tank is in front of you. A sign says, 'TAP FILLS 7/10 in 1 HOUR.' CLICK the 'START' button.",
    's2_step1_out':
        "Water fills the tank. The water level rises and stops exactly at the 7th mark on the 10-segment gauge.",
    's2_step2_task':
        "Now, find out how much the tank fills in just 1/3 of an hour. DRAG the hand on the timer from '0' to the '1/3 HR' mark.",
    's2_step2_out':
        "The timer dial visually changes, with the '1/3 hour' segment highlighted in orange.",
    's2_step3_task': "CLICK the 'START' button again.",
    's2_step3_out':
        "The tap turns on, the timer runs and stops at 1/3. The 10 segments subdivide into 3 smaller segments each. Water fills 7 of these.",
    's2_step4_task':
        "Observe the result. The equation explaining the operation appears.",
    's2_step4_out':
        "The equation 1/3 hour × 7/10 tank/hour = (1×7)/(3×10) = 7/30 of the tank is displayed.",
    's2_sum': "1/3 hour × 7/10 tank/hour = (1×7)/(3×10) = 7/30 of the tank",
    's3_title': "3. Maria's Decorative Lace",
    's3_obj':
        "To solve a division problem by finding out how many fractional pieces can be cut from a whole.",
    's3_step1_task':
        "You have an 8-meter roll of lace. The template says 'Requires 1/4 meter of lace'. DRAG the 'Measure' tool to the lace.",
    's3_step1_out':
        "A measuring tape interface appears along the 8-meter lace.",
    's3_step2_task':
        "A special '1/4 Meter Cutter' tool is available. DRAG the cutter to the start of the lace. CLICK the 'Cut' button.",
    's3_step2_out':
        "The cutter makes a clean slice. The 1/4 meter piece attaches itself to a bag template.",
    's3_step3_task':
        "Continue to DRAG the cutter until the entire 8-meter roll of lace is used up or click Auto-Cut.",
    's3_step3_out':
        "You repeatedly cut pieces. Each goes to a new bag. You make exactly 32 cuts.",
    's3_step4_task':
        "Count the number of bags you decorated. The final equation appears.",
    's3_step4_out':
        "The equation 8 meters ÷ 1/4 meter/bag = 8 × 4/1 = 32 bags is displayed.",
    's3_sum': "8 meters ÷ 1/4 meter/bag = 8 × 4/1 = 32 bags",
    's4_title': "4. Sharing Somu's Land",
    's4_obj':
        "To solve a multi-step fraction problem involving finding a fraction of a remaining part.",
    's4_step1_task':
        "Somu's rectangular plot of land is divided into 6 equal columns. A road needs 1/6 of the land. DRAG the Tractor tool onto the land.",
    's4_step1_out':
        "The tractor clears the first column (1/6), replacing it with a road. 5/6 remains.",
    's4_step2_task':
        "Somu gives half (1/2) of the *remaining* land to Krishna. DRAG the Vertical Fence to divide the remaining 5 columns into two equal parts.",
    's4_step2_out':
        "The fence snaps to halfway. A house colors the left share green.",
    's4_step3_task':
        "Somu gives one-third (1/3) of the *still remaining* land to Bora. DRAG the Horizontal Fence to partition the last remaining piece.",
    's4_step3_out':
        "The fence partitions the right area. The barn colors the top third blue.",
    's4_step4_task':
        "What fraction of the original land did Somu keep? CLICK on the grid squares that represent Somu's final share. Then check your answer.",
    's4_step4_out': "The system verifies Somu's share is selected correctly.",
    's4_sum':
        "Remaining: 5/6 - (1/2 × 5/6) - (1/3 × 1/2 × 5/6) = 10/36 = 5/18 of original land.",
    's5_title': "5. The Village Baker",
    's5_obj':
        "To use the concept of division to determine how many items can be produced from a given amount of resource.",
    's5_step1_task':
        "You are a baker with a 5 kg bag of flour. Each loaf requires 1/6 kg. DRAG the '1/6 kg Scoop' to the flour bag.",
    's5_step1_out':
        "The scoop fills with flour. The bag's weight indicator decreases slightly.",
    's5_step2_task':
        "DRAG the full scoop and DROP it onto an empty bread loaf mold on the baking tray.",
    's5_step2_out': "Flour pours into the mold. The scoop becomes empty.",
    's5_step3_task':
        "Continue scooping flour and filling the bread molds until the 5 kg bag is completely empty.",
    's5_step3_out':
        "The digital readout decreases until 0.00 kg. Molds are filled.",
    's5_step4_task':
        "A question appears: 'How many full loaves of bread were you able to make?' TYPE your answer into the input box.",
    's5_step4_out':
        "System checks the answer. Equation 5 kg ÷ 1/6 kg/loaf = 30 loaves appears.",
    's5_sum': "5 ÷ 1/6 = 5 × 6/1 = 30",
  },
  'hi': {
    'appTitle': "फ्रैक्शन फैक्ट्री: वास्तविक दुनिया के समाधान बनाना",
    'appSubtitle': "कक्षा 7 • भिन्नों के साथ काम करना",
    'enterLab': "लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "कदम",
    'learnLbl': "हम क्या सीखते हैं:",
    'summaryTitle': "देखा गया समीकरण",
    'resetBtn': "रीसेट",
    'finishLab': "लैब समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'labCompleted': "लैब पूरी हुई!",
    'finalDesc':
        "आपने भिन्नों का उपयोग करके वास्तविक दुनिया की समस्याओं को सफलतापूर्वक हल किया है! आपने मात्राओं के भिन्न खोजना, संसाधनों को विभाजित करना और व्यावहारिक स्थितियों में संचालन को मैप करना सीखा।",
    'taskInst': "कार्य निर्देश:",
    'expOut': "अपेक्षित परिणाम:",
    'submitBtn': "जमा करें",
    'checkBtn': "चयनित क्षेत्र की जांच करें",
    'combineBtn': "दूध मिलाएं",
    'startTimer': "शुरू करें",
    'cutBtn': "1/4m काटें",
    'autoCutBtn': "बाकी स्वतः काटें",
    'autoFillBtn': "बाकी स्वतः भरें",
    'milk': "दूध",
    'mon': "सोम",
    'tue': "मंगल",
    'wed': "बुध",
    'thu': "गुरु",
    'fri': "शुक्र",
    'sat': "शनि",
    'sun': "रवि",
    's1_cal_title': "तेंजिन की साप्ताहिक दूध आपूर्ति",
    'tapFills': "नल भरता है",
    'inOneHour': "1 घंटे में",
    'howManyLoaves': "कितनी पूरी ब्रेड बनी?",
    's1_title': "1. तेंजिन की साप्ताहिक दूध आपूर्ति",
    's1_obj':
        "एक पूर्ण संख्या को एक भिन्न से गुणा करके एक सप्ताह में तेंजिन द्वारा पीए जाने वाले दूध की कुल मात्रा की गणना करना।",
    's1_step1_task':
        "मेज पर, आप एक साप्ताहिक कैलेंडर और दूध का एक कार्टन देखते हैं। दूध के कार्टन को खींचें और इसे 'सोमवार' पर छोड़ दें।",
    's1_step1_out':
        "एक गिलास, जो ठीक 1/2 निशान तक भरा हुआ है, सोमवार के स्लॉट के बगल में दिखाई देता है।",
    's1_step2_task':
        "सप्ताह के अन्य 6 दिनों के लिए भी यही प्रक्रिया दोहराएं। दूध के कार्टन को खींचें और बाकी दिनों पर छोड़ दें।",
    's1_step2_out':
        "सप्ताह के प्रत्येक दिन के बगल में दूध का 1/2 भरा हुआ गिलास दिखाई देता है।",
    's1_step3_task':
        "मेज पर एक बड़ा, खाली मापने वाला जग दिखाई देता है। 'दूध मिलाएं' बटन पर क्लिक करें।",
    's1_step3_out':
        "7 आधे भरे हुए गिलास एनिमेट होते हैं, और अपना दूध जग में डालते हैं। स्तर 3 1/2 पर रुक जाता है।",
    's1_step4_task': "अंतिम परिणाम देखें। स्क्रीन पर एक समीकरण दिखाई देता है।",
    's1_step4_out':
        "समीकरण 7 दिन × 1/2 गिलास/दिन = 7/2 गिलास = 3 1/2 गिलास प्रदर्शित होता है।",
    's1_sum': "7 दिन × 1/2 गिलास/दिन = 7/2 = 3 1/2 गिलास",
    's2_title': "2. रिसने वाली पानी की टंकी",
    's2_obj':
        "एक घंटे के एक अंश में टंकी कितनी भर जाती है, इसकी गणना करके दो भिन्नों के गुणन को समझना।",
    's2_step1_task':
        "आपके सामने एक पानी की टंकी है। 'START' बटन पर क्लिक करें।",
    's2_step1_out':
        "पानी टंकी को भरता है। जल स्तर 10-खंड गेज पर 7वें निशान पर रुक जाता है।",
    's2_step2_task':
        "पता करें कि टंकी केवल 1/3 घंटे में कितनी भरती है। टाइमर सुई को '1/3 HR' के निशान पर खींचें।",
    's2_step2_out':
        "टाइमर डायल बदल जाता है, जिसमें '1/3 घंटे' का खंड नारंगी रंग में हाइलाइट होता है।",
    's2_step3_task': "फिर से 'START' बटन पर क्लिक करें।",
    's2_step3_out':
        "नल चालू हो जाता है। 10 खंड 3 छोटे खंडों में विभाजित हो जाते हैं। पानी इनमें से 7 को भरता है।",
    's2_step4_task': "परिणाम का निरीक्षण करें। समीकरण दिखाई देता है।",
    's2_step4_out':
        "समीकरण 1/3 घंटा × 7/10 टंकी/घंटा = (1×7)/(3×10) = टंकी का 7/30 प्रदर्शित होता है।",
    's2_sum': "1/3 घंटा × 7/10 टंकी/घंटा = (1×7)/(3×10) = टंकी का 7/30",
    's3_title': "3. मारिया की सजावटी लेस",
    's3_obj':
        "एक पूर्ण से कितने भिन्नात्मक टुकड़े काटे जा सकते हैं, यह पता लगाकर विभाजन की समस्या को हल करना।",
    's3_step1_task': "8 मीटर लेस है। 'माप' (Measure) उपकरण को लेस पर खींचें।",
    's3_step1_out':
        "8 मीटर की लेस के साथ एक मापने वाला टेप इंटरफ़ेस दिखाई देता है।",
    's3_step2_task':
        "'1/4 मीटर कटर' उपकरण को लेस की शुरुआत में खींचें। 'Cut' बटन पर क्लिक करें।",
    's3_step2_out': "कटर 1/4 मीटर का टुकड़ा काटता है।",
    's3_step3_task':
        "लेस का उपयोग करने के लिए 'Auto-Cut Rest' पर क्लिक करें या कटर को खींचें।",
    's3_step3_out': "आप बार-बार टुकड़े काटते हैं। आप ठीक 32 कट लगाते हैं।",
    's3_step4_task': "बैग गिनें और समीकरण देखें।",
    's3_step4_out':
        "समीकरण 8 मीटर ÷ 1/4 मीटर/बैग = 8 × 4/1 = 32 बैग प्रदर्शित होता है।",
    's3_sum': "8 मीटर ÷ 1/4 मीटर/बैग = 8 × 4/1 = 32 बैग",
    's4_title': "4. सोमू की भूमि का बँटवारा",
    's4_obj':
        "शेष भाग का भिन्न ज्ञात करने से संबंधित एक बहु-चरणीय भिन्न समस्या को हल करना।",
    's4_step1_task':
        "सड़क के लिए 1/6 साफ़ करने हेतु 'ट्रैक्टर' टूल को भूमि पर खींचें।",
    's4_step1_out': "ट्रैक्टर पहले स्तंभ को साफ़ करता है। 5/6 बचता है।",
    's4_step2_task': "शेष भूमि को आधा करने हेतु 'लंबवत बाड़' खींचें।",
    's4_step2_out':
        "बाड़ आधे रास्ते पर सेट हो जाती है। एक घर बाएं हिस्से को हरा रंग देता है।",
    's4_step3_task':
        "शेष भूमि को एक तिहाई में विभाजित करने के लिए 'क्षैतिज बाड़' खींचें।",
    's4_step3_out':
        "बाड़ सही क्षेत्र को विभाजित करती है। खलिहान शीर्ष तिहाई को नीला रंग देता है।",
    's4_step4_task':
        "उन ग्रिड वर्गों पर क्लिक करें जो सोमू के अंतिम हिस्से का प्रतिनिधित्व करते हैं।",
    's4_step4_out':
        "सिस्टम सत्यापित करता है कि सोमू का हिस्सा सही ढंग से चुना गया है।",
    's4_sum': "शेष: 5/6 - (1/2 × 5/6) - (1/3 × 1/2 × 5/6) = 10/36 = 5/18",
    's5_title': "5. गाँव का बेकर",
    's5_obj': "विभाजन की अवधारणा का उपयोग करना।",
    's5_step1_task': "'1/6 किलो स्कूप' को आटे की थैली पर खींचें।",
    's5_step1_out': "स्कूप आटे से भर जाता है। थैली का वजन थोड़ा कम हो जाता है।",
    's5_step2_task':
        "भरे हुए स्कूप को खींचें और बेकिंग ट्रे पर एक खाली मोल्ड पर छोड़ दें।",
    's5_step2_out': "स्कूप से आटा मोल्ड में डाला जाता है।",
    's5_step3_task': "थैली खाली होने तक आटा निकालना और मोल्ड भरना जारी रखें।",
    's5_step3_out': "डिजिटल रीडआउट 0.00 किलो तक घट जाता है।",
    's5_step4_task': "कितनी पूरी ब्रेड बनी? उत्तर लिखें और जमा करें।",
    's5_step4_out': "समीकरण 5 किलो ÷ 1/6 किलो/ब्रेड = 30 ब्रेड दिखाई देता है।",
    's5_sum': "5 ÷ 1/6 = 5 × 6/1 = 30",
  },
  'te': {
    'appTitle': "ఫ్రాక్షన్ ఫ్యాక్టరీ: వాస్తవ ప్రపంచ పరిష్కారాలను నిర్మించడం",
    'appSubtitle': "క్లాస్ 7 • భిన్నాలతో పని చేయడం",
    'enterLab': "ల్యాబ్‌లోకి ప్రవేశించండి",
    'selectScenario': "సన్నివేశాన్ని ఎంచుకోండి",
    'stepLabel': "దశ",
    'learnLbl': "మనం ఏమి నేర్చుకుంటాము:",
    'summaryTitle': "సమీకరణం గమనించబడింది",
    'resetBtn': "రీసెట్",
    'finishLab': "ల్యాబ్ ముగించండి",
    'nextScenario': "తదుపరి దృశ్యం",
    'labCompleted': "ల్యాబ్ పూర్తయింది!",
    'finalDesc':
        "భిన్నాలను ఉపయోగించి వాస్తవ ప్రపంచ సమస్యలను మీరు విజయవంతంగా నమూనా చేసారు! మొత్తాల భిన్నాలను ఎలా కనుగొనాలో మరియు వనరులను ఎలా విభజించాలో మీరు నేర్చుకున్నారు.",
    'taskInst': "విధి సూచనలు:",
    'expOut': "ఆశించిన ఫలితం:",
    'submitBtn': "సమర్పించండి",
    'checkBtn': "ఎంచుకున్న ప్రాంతాన్ని తనిఖీ చేయండి",
    'combineBtn': "పాలను కలపండి",
    'startTimer': "ప్రారంభించండి",
    'cutBtn': "1/4m కట్",
    'autoCutBtn': "మిగిలినవి ఆటో-కట్",
    'autoFillBtn': "మిగిలినవి ఆటో-ఫిల్",
    'milk': "పాలు",
    'mon': "సోమవారం",
    'tue': "మంగళవారం",
    'wed': "బుధవారం",
    'thu': "గురువారం",
    'fri': "శుక్రవారం",
    'sat': "శనివారం",
    'sun': "ఆదివారం",
    's1_cal_title': "టెన్జిన్ వారపు పాల సరఫరా",
    'tapFills': "ట్యాప్ నింపుతుంది",
    'inOneHour': "1 గంటలో",
    'howManyLoaves': "ఎన్ని పూర్తి బ్రెడ్‌లు తయారయ్యాయి?",
    's1_title': "1. టెన్జిన్ వారపు పాల సరఫరా",
    's1_obj':
        "పూర్ణ సంఖ్యను భిన్నంతో గుణించడం ద్వారా టెన్జిన్ ఒక వారంలో త్రాగే మొత్తం పాలను దృశ్యమానంగా లెక్కించడం.",
    's1_step1_task':
        "టేబుల్ మీద, మీరు వారంవారీ క్యాలెండర్ మరియు పాల డబ్బాను చూస్తారు. పాల డబ్బాను లాగి, క్యాలెండర్‌లోని 'సోమవారం' స్లాట్‌పై వదలండి.",
    's1_step1_out':
        "సరిగ్గా 1/2 మార్కుకు నిండిన ఒకే గ్లాసు, సోమవారం స్లాట్ పక్కన కనిపిస్తుంది.",
    's1_step2_task':
        "వారంలోని మిగిలిన 6 రోజులకు ఈ ప్రక్రియను పునరావృతం చేయండి. పాల డబ్బాను లాగి మిగిలిన రోజుల స్లాట్‌లపై వదలండి.",
    's1_step2_out':
        "వారంలోని ప్రతి రోజు పక్కన 1/2-నిండిన పాల గ్లాసు కనిపిస్తుంది.",
    's1_step3_task':
        "టేబుల్‌పై ఒక పెద్ద, ఖాళీ కొలిచే జగ్ కనిపిస్తుంది. 'పాలను కలపండి' బటన్‌ను క్లిక్ చేయండి.",
    's1_step3_out':
        "7 సగం నిండిన గ్లాసులు యానిమేట్ చేయబడి, వాటి పాలను పెద్ద జగ్గులో పోస్తాయి. పాల స్థాయి 3 1/2 మార్కు వద్ద ఆగిపోతుంది.",
    's1_step4_task':
        "కొలిచే జగ్గులో తుది ఫలితాన్ని గమనించండి. తెరపై ఒక సమీకరణం కనిపిస్తుంది.",
    's1_step4_out':
        "సమీకరణం 7 రోజులు × 1/2 గ్లాస్/రోజు = 7/2 గ్లాసులు = 3 1/2 గ్లాసులు స్పష్టంగా ప్రదర్శించబడుతుంది.",
    's1_sum': "7 రోజులు × 1/2 గ్లాస్/రోజు = 7/2 = 3 1/2 గ్లాసులు",
    's2_title': "2. లీకవుతున్న నీటి ట్యాంక్",
    's2_obj':
        "గంటలో కొంత భాగంలో ట్యాంక్ ఎంత నిండుతుందో లెక్కించడం ద్వారా రెండు భిన్నాల గుణకారాన్ని అర్థం చేసుకోవడం.",
    's2_step1_task':
        "మీ ముందు ఒక పెద్ద నీటి ట్యాంక్ ఉంది. 'START' బటన్‌ను క్లిక్ చేయండి.",
    's2_step1_out':
        "నీరు ట్యాంకును నింపుతుంది. నీటి స్థాయి పెరిగి 10-విభాగాల గేజ్‌లో సరిగ్గా 7వ మార్కు వద్ద ఆగిపోతుంది.",
    's2_step2_task':
        "కేవలం 1/3 గంటలో ట్యాంక్ ఎంత నిండుతుందో కనుక్కోండి. టైమర్‌పై ముల్లును '1/3 HR' మార్కుకు లాగండి.",
    's2_step2_out':
        "టైమర్ డయల్ దృశ్యమానంగా మారుతుంది, '1/3 గంట' విభాగం నారింజ రంగులో హైలైట్ చేయబడుతుంది.",
    's2_step3_task': "మళ్ళీ 'START' బటన్‌ను క్లిక్ చేయండి.",
    's2_step3_out':
        "ట్యాప్ ఆన్ అవుతుంది. 10 విభాగాలు ఒక్కొక్కటి 3 చిన్న విభాగాలుగా ఉపవిభజన చేయబడతాయి. నీరు వీటిలో 7 నింపుతుంది.",
    's2_step4_task':
        "ఫలితాన్ని గమనించండి. ఆపరేషన్‌ను వివరించే సమీకరణం కనిపిస్తుంది.",
    's2_step4_out':
        "సమీకరణం 1/3 గంట × 7/10 ట్యాంక్/గంట = (1×7)/(3×10) = ట్యాంక్‌లో 7/30 ప్రదర్శించబడుతుంది.",
    's2_sum': "1/3 గంట × 7/10 ట్యాంక్/గంట = (1×7)/(3×10) = ట్యాంక్‌లో 7/30",
    's3_title': "3. మరియా డెకరేటివ్ లేస్",
    's3_obj':
        "ఒక మొత్తం నుండి ఎన్ని భిన్నమైన ముక్కలను కత్తిరించవచ్చో కనుగొనడం ద్వారా భాగహార సమస్యను పరిష్కరించడం.",
    's3_step1_task':
        "మీ వద్ద 8-మీటర్ల లేస్ రోల్ ఉంది. 'కొలత' (Measure) సాధనాన్ని లేస్ మీదకు లాగండి.",
    's3_step1_out':
        "8-మీటర్ల లేస్‌తో పాటు కొలిచే టేప్ ఇంటర్‌ఫేస్ కనిపిస్తుంది.",
    's3_step2_task':
        "'1/4 మీటర్ కట్టర్' సాధనాన్ని లేస్ ప్రారంభానికి లాగండి. 'కట్' బటన్‌ను క్లిక్ చేయండి.",
    's3_step2_out': "కట్టర్ 1/4 మీటర్ ముక్కను కత్తిరిస్తుంది.",
    's3_step3_task':
        "లేస్ ఉపయోగించడానికి 'ఆటో-కట్ రెస్ట్' క్లిక్ చేయండి లేదా కట్టర్‌ను లాగండి.",
    's3_step3_out':
        "మీరు పదేపదే ముక్కలను కత్తిరిస్తారు. మీరు సరిగ్గా 32 కట్‌లు చేస్తారు.",
    's3_step4_task': "బ్యాగ్‌లను లెక్కించండి మరియు సమీకరణాన్ని గమనించండి.",
    's3_step4_out':
        "సమీకరణం 8 మీటర్లు ÷ 1/4 మీటర్/బ్యాగ్ = 8 × 4/1 = 32 బ్యాగ్‌లు ప్రదర్శించబడుతుంది.",
    's3_sum': "8 మీటర్లు ÷ 1/4 మీటర్/బ్యాగ్ = 8 × 4/1 = 32 బ్యాగ్‌లు",
    's4_title': "4. సోము భూమి భాగస్వామ్యం",
    's4_obj':
        "మిగిలిన భాగంలో భిన్నాన్ని కనుగొనడం ఉన్న బహుళ-దశల భిన్న సమస్యను పరిష్కరించడం.",
    's4_step1_task':
        "రహదారి కోసం 1/6 క్లియర్ చేయడానికి ట్రాక్టర్ సాధనాన్ని ఎడమవైపుకు లాగండి.",
    's4_step1_out':
        "ట్రాక్టర్ మొదటి నిలువు వరుసను క్లియర్ చేస్తుంది. 5/6 మిగిలి ఉంది.",
    's4_step2_task':
        "మిగిలిన భూమిని సగానికి విభజించడానికి నిలువు కంచెను లాగండి.",
    's4_step2_out':
        "కంచె సగం దూరంలో స్నాప్ అవుతుంది. ఇల్లు ఎడమ భాగానికి ఆకుపచ్చ రంగు వేస్తుంది.",
    's4_step3_task':
        "ఇంకా మిగిలి ఉన్న భూమిలో మూడింట ఒక వంతు విభజించడానికి 'క్షితిజ సమాంతర కంచె'ను లాగండి.",
    's4_step3_out':
        "కంచె కుడి ప్రాంతాన్ని విభజిస్తుంది. బార్న్ ఎగువ మూడింట ఒక వంతుకు నీలం రంగు వేస్తుంది.",
    's4_step4_task':
        "సోము తుది వాటాను సూచించే గ్రిడ్ చతురస్రాలపై క్లిక్ చేయండి.",
    's4_step4_out':
        "సోము వాటా సరిగ్గా ఎంపిక చేయబడిందని సిస్టమ్ నిర్ధారిస్తుంది.",
    's4_sum': "మిగిలినవి: 5/6 - (1/2 × 5/6) - (1/3 × 1/2 × 5/6) = 10/36 = 5/18",
    's5_title': "5. విలేజ్ బేకర్",
    's5_obj':
        "ఇచ్చిన వనరు నుండి ఎన్ని వస్తువులను ఉత్పత్తి చేయవచ్చో నిర్ణయించడానికి భాగహారం భావనను ఉపయోగించడం.",
    's5_step1_task': "నింపడానికి '1/6 కిలోల స్కూప్'ను పిండి బ్యాగ్‌పై లాగండి.",
    's5_step1_out':
        "స్కూప్ పిండితో నిండుతుంది. బ్యాగ్ బరువు సూచిక కొద్దిగా తగ్గుతుంది.",
    's5_step2_task':
        "నిండుగా ఉన్న స్కూప్‌ను లాగి, బేకింగ్ ట్రేలోని ఖాళీ బ్రెడ్ మౌల్డ్‌పై వదలండి.",
    's5_step2_out': "స్కూప్ నుండి పిండి మౌల్డ్‌లో పోయబడుతుంది.",
    's5_step3_task':
        "బ్యాగ్ ఖాళీ అయ్యే వరకు పిండి తీయడం మరియు నింపడం కొనసాగించండి.",
    's5_step3_out': "డిజిటల్ రీడౌట్ 0.00 కిలోలకు తగ్గుతుంది.",
    's5_step4_task':
        "మీరు ఎన్ని పూర్తి బ్రెడ్‌లు తయారు చేసారు? సమాధానం టైప్ చేసి సమర్పించండి.",
    's5_step4_out':
        "సమీకరణం 5 కిలోలు ÷ 1/6 కిలోలు/బ్రెడ్ = 30 బ్రెడ్‌లు కనిపిస్తుంది.",
    's5_sum': "5 ÷ 1/6 = 5 × 6/1 = 30",
  },
};
