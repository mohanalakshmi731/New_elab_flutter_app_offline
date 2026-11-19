// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Requires audioplayers: ^5.2.1 in pubspec.yaml

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // bg-main
        primaryColor: const Color(0xFFEAB308), // zsl-yellow
        fontFamily: 'Plus Jakarta Sans', // Fallback to standard if not loaded
      ),
      home: const ApplyingDistributiveProperty(),
    );
  }
}

// --- MODELS & STATE ---

class GameItem {
  String id;
  String type; // apple, orange, blue_chair, red_chair, multiplier
  double x;
  double y;
  double homeX;
  double homeY;
  double width;
  double height;
  bool isDraggable;
  bool isVisible;
  String status;
  int row;
  int col;

  GameItem({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.homeX,
    required this.homeY,
    required this.width,
    required this.height,
    this.isDraggable = true,
    this.isVisible = true,
    this.status = 'home',
    this.row = 0,
    this.col = 0,
  });
}

class DropZone {
  String id;
  double x;
  double y;
  double width;
  double height;
  String type;

  DropZone({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
  });

  bool contains(double px, double py) {
    return px >= x && px <= x + width && py >= y && py <= y + height;
  }
}

// --- MAIN SCREEN ---

class ApplyingDistributiveProperty extends StatefulWidget {
  const ApplyingDistributiveProperty({super.key});

  @override
  State<ApplyingDistributiveProperty> createState() =>
      _ApplyingDistributivePropertyState();
}

class _ApplyingDistributivePropertyState
    extends State<ApplyingDistributiveProperty>
    with TickerProviderStateMixin {
  // Config
  bool _isLabEntered = false; // Controls Curtain Screen
  bool _isSidebarOpen = true;
  int _scenario = 1;
  int _step = 0;
  String _currentLang = 'en';
  final List<String> _languages = ['en', 'hi'];
  bool _taskCompleted = false;

  // Canvas Viewport
  final TransformationController _transformController =
      TransformationController();
  final double _canvasWidth = 1600;
  final double _canvasHeight = 900;

  // Interaction State
  String? _draggingId;
  Offset? _dragOffset;

  // Game Objects
  final List<GameItem> _items = [];
  final List<DropZone> _zones = [];

  // Scenario 1 Machine State
  int _dialValue = 1;
  bool _showMachineOverlay = false;
  String _machineText = "";

  // Audio
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Toast
  String? _toastMessage;
  bool _toastIsError = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initScenario();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _transformController.dispose();
    super.dispose();
  }

  // --- AUDIO LOGIC ---
  void _playSound(String url) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play failed: $e");
    }
  }

  void _playEnterSound() => _playSound(
    'audio/class7/mixkit_2568.mp3',
  );
  void _playClickSound() => _playSound(
    'audio/class7/mixkit_2568.mp3',
  );
  void _playSnapSound() => _playSound(
    'audio/class7/mixkit_2570.mp3',
  );
  void _playSuccessSound() => _playSound(
    'audio/class7/mixkit_2018.mp3',
  );
  void _playErrorSound() => _playSound(
    'audio/class7/mixkit_955.mp3',
  );
  void _playProcessSound() => _playSound(
    'audio/class7/mixkit_2018.mp3',
  );

  void _showToast(String message, {bool isError = false}) {
    setState(() {
      _toastMessage = message;
      _toastIsError = isError;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _toastMessage == message) {
        setState(() => _toastMessage = null);
      }
    });
  }

  void _toggleLanguage() {
    _playClickSound();
    setState(() {
      int currentIndex = _languages.indexOf(_currentLang);
      _currentLang = _languages[(currentIndex + 1) % _languages.length];
    });
  }

  void _resetLab() {
    _playClickSound();
    _scenario = 1;
    _step = 0;
    _currentLang = 'en';
    _isLabEntered = false;
    _isSidebarOpen = true;
    _toastMessage = null;
    _toastIsError = false;
    _initScenario();
  }

  void _enterLab() {
    _playEnterSound();
    setState(() {
      _isLabEntered = true;
    });
  }

  // --- GAME LOGIC ---

  void _initScenario() {
    _items.clear();
    _zones.clear();
    _machineText = "";
    _showMachineOverlay = false;
    _dialValue = 1;
    _taskCompleted = false;
    _transformController.value = Matrix4.identity(); // Reset zoom

    if (_scenario == 1) {
      _initScenario1();
    } else {
      _initScenario2();
    }
    setState(() {});
  }

  void _initScenario1() {
    if (_step == 1) {
      _zones.add(
        DropZone(
          id: 'tray',
          x: 600,
          y: 350,
          width: 400,
          height: 200,
          type: 'tray',
        ),
      );
      for (int i = 0; i < 3; i++) {
        _items.add(
          GameItem(
            id: 'a_$i',
            type: 'apple',
            x: 150 + i * 60,
            y: 200,
            homeX: 150 + i * 60,
            homeY: 200,
            width: 50,
            height: 50,
          ),
        );
      }
      for (int i = 0; i < 4; i++) {
        _items.add(
          GameItem(
            id: 'o_$i',
            type: 'orange',
            x: 150 + i * 60,
            y: 500,
            homeX: 150 + i * 60,
            homeY: 500,
            width: 50,
            height: 50,
          ),
        );
      }
    } else if (_step == 2) {
      _showMachineOverlay = true;
      _machineText = "(3 + 4)";
      _dialValue = 1;
      for (int i = 0; i < 3; i++) {
        _items.add(
          GameItem(
            id: 'a_$i',
            type: 'apple',
            x: 650 + i * 60,
            y: 380,
            homeX: 650 + i * 60,
            homeY: 380,
            width: 50,
            height: 50,
            isDraggable: false,
            status: 'tray',
          ),
        );
      }
      for (int i = 0; i < 4; i++) {
        _items.add(
          GameItem(
            id: 'o_$i',
            type: 'orange',
            x: 620 + i * 60,
            y: 460,
            homeX: 620 + i * 60,
            homeY: 460,
            width: 50,
            height: 50,
            isDraggable: false,
            status: 'tray',
          ),
        );
      }
    } else if (_step == 3) {
      _zones.add(
        DropZone(
          id: 'top_belt',
          x: 500,
          y: 200,
          width: 600,
          height: 150,
          type: 'top_belt',
        ),
      );
      for (int i = 0; i < 3; i++) {
        _items.add(
          GameItem(
            id: 'a_$i',
            type: 'apple',
            x: 150 + i * 60,
            y: 250,
            homeX: 150 + i * 60,
            homeY: 250,
            width: 50,
            height: 50,
          ),
        );
      }
      _showMachineOverlay = true;
      _machineText = "Apple Packer";
    } else if (_step == 4) {
      _zones.add(
        DropZone(
          id: 'bottom_belt',
          x: 500,
          y: 500,
          width: 600,
          height: 150,
          type: 'bottom_belt',
        ),
      );
      for (int i = 0; i < 3; i++) {
        _items.add(
          GameItem(
            id: 'a_$i',
            type: 'apple',
            x: 550 + i * 80,
            y: 250,
            homeX: 550 + i * 80,
            homeY: 250,
            width: 50,
            height: 50,
            isDraggable: false,
          ),
        );
        _items.add(
          GameItem(
            id: 'a_dup_$i',
            type: 'apple',
            x: 550 + i * 80 + 300,
            y: 250,
            homeX: 550 + i * 80 + 300,
            homeY: 250,
            width: 50,
            height: 50,
            isDraggable: false,
          ),
        );
      }
      for (int i = 0; i < 4; i++) {
        _items.add(
          GameItem(
            id: 'o_$i',
            type: 'orange',
            x: 150 + i * 60,
            y: 550,
            homeX: 150 + i * 60,
            homeY: 550,
            width: 50,
            height: 50,
          ),
        );
      }
      _showMachineOverlay = true;
      _machineText = "(2 × 3)";
    } else if (_step == 5) {
      _showMachineOverlay = true;
      _machineText = "(2 × 3) + (2 × 4)";
      for (int i = 0; i < 3; i++) {
        _items.add(
          GameItem(
            id: 'a_$i',
            type: 'apple',
            x: 550 + i * 80,
            y: 250,
            homeX: 550 + i * 80,
            homeY: 250,
            width: 50,
            height: 50,
            isDraggable: false,
          ),
        );
        _items.add(
          GameItem(
            id: 'a_dup_$i',
            type: 'apple',
            x: 550 + i * 80 + 300,
            y: 250,
            homeX: 550 + i * 80 + 300,
            homeY: 250,
            width: 50,
            height: 50,
            isDraggable: false,
          ),
        );
      }
      for (int i = 0; i < 4; i++) {
        _items.add(
          GameItem(
            id: 'o_$i',
            type: 'orange',
            x: 550 + i * 80,
            y: 550,
            homeX: 550 + i * 80,
            homeY: 550,
            width: 50,
            height: 50,
            isDraggable: false,
          ),
        );
        _items.add(
          GameItem(
            id: 'o_dup_$i',
            type: 'orange',
            x: 550 + i * 80 + 300,
            y: 550,
            homeX: 550 + i * 80 + 300,
            homeY: 550,
            width: 50,
            height: 50,
            isDraggable: false,
          ),
        );
      }
    }
  }

  void _initScenario2() {
    double startX = 200;

    if (_step == 0) {
      _zones.add(
        DropZone(
          id: 'stage_blue',
          x: 700,
          y: 200,
          width: 100,
          height: 250,
          type: 'stage',
        ),
      );
      _zones.add(
        DropZone(
          id: 'stage_red',
          x: 700,
          y: 500,
          width: 100,
          height: 200,
          type: 'stage',
        ),
      );
      _items.add(
        GameItem(
          id: 'blue_block',
          type: 'blue_chair_stack',
          x: startX,
          y: 200,
          homeX: startX,
          homeY: 200,
          width: 60,
          height: 240,
        ),
      );
      _items.add(
        GameItem(
          id: 'red_block',
          type: 'red_chair_stack',
          x: startX,
          y: 500,
          homeX: startX,
          homeY: 500,
          width: 60,
          height: 180,
        ),
      );
    } else if (_step == 1) {
      _showMachineOverlay = true;
      _machineText = "(4 + 3)";
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 5; c++) {
          _items.add(
            GameItem(
              id: 'bc_${r}_$c',
              type: 'blue_chair',
              x: 700 + c * 60,
              y: 200 + r * 60,
              homeX: 700 + c * 60,
              homeY: 200 + r * 60,
              width: 50,
              height: 50,
              isVisible: c == 0,
              isDraggable: false,
            ),
          );
        }
      }
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 5; c++) {
          _items.add(
            GameItem(
              id: 'rc_${r}_$c',
              type: 'red_chair',
              x: 700 + c * 60,
              y: 460 + r * 60,
              homeX: 700 + c * 60,
              homeY: 460 + r * 60,
              width: 50,
              height: 50,
              isVisible: c == 0,
              isDraggable: false,
            ),
          );
        }
      }
      _items.add(
        GameItem(
          id: 'multiplier',
          type: 'multiplier',
          x: 1200,
          y: 150,
          homeX: 1200,
          homeY: 150,
          width: 40,
          height: 600,
        ),
      );
    } else if (_step == 2) {
      _zones.add(
        DropZone(
          id: 'stage_sep',
          x: 700,
          y: 200,
          width: 100,
          height: 250,
          type: 'stage',
        ),
      );
      _items.add(
        GameItem(
          id: 'blue_block',
          type: 'blue_chair_stack',
          x: startX,
          y: 200,
          homeX: startX,
          homeY: 200,
          width: 60,
          height: 240,
        ),
      );
    } else if (_step == 3) {
      _showMachineOverlay = true;
      _machineText = "4 Rows";
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 5; c++) {
          _items.add(
            GameItem(
              id: 'bc_${r}_$c',
              type: 'blue_chair',
              x: 700 + c * 60,
              y: 200 + r * 60,
              homeX: 700 + c * 60,
              homeY: 200 + r * 60,
              width: 50,
              height: 50,
              isVisible: c == 0,
              isDraggable: false,
            ),
          );
        }
      }
      _items.add(
        GameItem(
          id: 'multiplier',
          type: 'multiplier',
          x: 1200,
          y: 180,
          homeX: 1200,
          homeY: 180,
          width: 40,
          height: 300,
        ),
      );
    } else if (_step == 4) {
      _showMachineOverlay = true;
      _machineText = "(4 × 5)";
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 5; c++) {
          _items.add(
            GameItem(
              id: 'bc_${r}_$c',
              type: 'blue_chair',
              x: 700 + c * 60,
              y: 200 + r * 60,
              homeX: 700 + c * 60,
              homeY: 200 + r * 60,
              width: 50,
              height: 50,
              isVisible: true,
              isDraggable: false,
            ),
          );
        }
      }
      _zones.add(
        DropZone(
          id: 'stage_red',
          x: 700,
          y: 460,
          width: 100,
          height: 200,
          type: 'stage',
        ),
      );
      _items.add(
        GameItem(
          id: 'red_block',
          type: 'red_chair_stack',
          x: startX,
          y: 500,
          homeX: startX,
          homeY: 500,
          width: 60,
          height: 180,
        ),
      );
    } else if (_step == 5) {
      _showMachineOverlay = true;
      _machineText = "(4 × 5) + 3";
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 5; c++) {
          _items.add(
            GameItem(
              id: 'bc_${r}_$c',
              type: 'blue_chair',
              x: 700 + c * 60,
              y: 200 + r * 60,
              homeX: 700 + c * 60,
              homeY: 200 + r * 60,
              width: 50,
              height: 50,
              isVisible: true,
              isDraggable: false,
            ),
          );
        }
      }
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 5; c++) {
          _items.add(
            GameItem(
              id: 'rc_${r}_$c',
              type: 'red_chair',
              x: 700 + c * 60,
              y: 460 + r * 60,
              homeX: 700 + c * 60,
              homeY: 460 + r * 60,
              width: 50,
              height: 50,
              isVisible: c == 0,
              isDraggable: false,
            ),
          );
        }
      }
      _items.add(
        GameItem(
          id: 'multiplier',
          type: 'multiplier',
          x: 1200,
          y: 440,
          homeX: 1200,
          homeY: 440,
          width: 40,
          height: 250,
        ),
      );
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_taskCompleted || !_isLabEntered) return;

    final scenePoint = _transformController.toScene(event.localPosition);

    for (var item in _items.reversed) {
      if (item.isDraggable && item.isVisible) {
        if (scenePoint.dx >= item.x &&
            scenePoint.dx <= item.x + item.width &&
            scenePoint.dy >= item.y &&
            scenePoint.dy <= item.y + item.height) {
          setState(() {
            _draggingId = item.id;
            _dragOffset = Offset(
              scenePoint.dx - item.x,
              scenePoint.dy - item.y,
            );
          });
          _playClickSound();
          break;
        }
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_draggingId == null || !_isLabEntered) return;

    final scenePoint = _transformController.toScene(event.localPosition);

    setState(() {
      var item = _items.firstWhere((i) => i.id == _draggingId);
      item.x = scenePoint.dx - _dragOffset!.dx;
      item.y = scenePoint.dy - _dragOffset!.dy;

      if (item.type == 'multiplier') {
        bool allVisible = true;
        for (var target in _items) {
          if (target.type == 'blue_chair' || target.type == 'red_chair') {
            if (!target.isVisible) {
              if (item.x < target.x + target.width) {
                target.isVisible = true;
                _playProcessSound();
              } else {
                allVisible = false;
              }
            }
          }
        }
        if (allVisible &&
            (_scenario == 2) &&
            (_step == 1 || _step == 3 || _step == 5)) {
          _completeTask();
        }
      }
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    _handleInteractionEnd();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _handleInteractionEnd();
  }

  void _handleInteractionEnd() {
    if (_draggingId == null) return;

    var item = _items.firstWhere((i) => i.id == _draggingId);
    bool snapped = false;

    for (var zone in _zones) {
      if (zone.contains(item.x + item.width / 2, item.y + item.height / 2)) {
        snapped = _handleDrop(item, zone);
        break;
      }
    }

    if (item.type == 'multiplier') {
      if (item.x < 800) {
        snapped = true;
        _completeTask();
      }
    }

    setState(() {
      if (!snapped && item.type != 'multiplier') {
        item.x = item.homeX;
        item.y = item.homeY;
        _playErrorSound();
      } else if (snapped) {
        _playSnapSound();
      }
      _draggingId = null;
    });
  }

  bool _handleDrop(GameItem item, DropZone zone) {
    if (_scenario == 1) {
      if (_step == 1 &&
          zone.type == 'tray' &&
          (item.type == 'apple' || item.type == 'orange')) {
        item.status = 'tray';
        item.x = item.type == 'apple'
            ? zone.x + 50 + Random().nextInt(100)
            : zone.x + 200 + Random().nextInt(100);
        item.y = zone.y + 50 + Random().nextInt(50);
        _checkStepCompletion();
        return true;
      }
      if (_step == 3 && zone.type == 'top_belt' && item.type == 'apple') {
        item.status = 'top_belt';
        int count = _items.where((i) => i.status == 'top_belt').length;
        item.x = zone.x + count * 60;
        item.y = zone.y + 50;
        _checkStepCompletion();
        return true;
      }
      if (_step == 4 && zone.type == 'bottom_belt' && item.type == 'orange') {
        item.status = 'bottom_belt';
        int count = _items.where((i) => i.status == 'bottom_belt').length;
        item.x = zone.x + count * 60;
        item.y = zone.y + 50;
        _checkStepCompletion();
        return true;
      }
    } else if (_scenario == 2) {
      if (zone.type == 'stage' &&
          (item.type == 'blue_chair_stack' || item.type == 'red_chair_stack')) {
        item.x = zone.x;
        item.y = zone.y;
        item.status = 'stage';
        _checkStepCompletion();
        return true;
      }
    }
    return false;
  }

  void _checkStepCompletion() {
    if (_scenario == 1) {
      if (_step == 1) {
        int trayApples = _items
            .where((i) => i.type == 'apple' && i.status == 'tray')
            .length;
        int trayOranges = _items
            .where((i) => i.type == 'orange' && i.status == 'tray')
            .length;
        if (trayApples == 3 && trayOranges == 4) _completeTask();
      } else if (_step == 3) {
        if (_items
                .where((i) => i.type == 'apple' && i.status == 'top_belt')
                .length ==
            3) {
          _completeTask();
        }
      } else if (_step == 4) {
        if (_items
                .where((i) => i.type == 'orange' && i.status == 'bottom_belt')
                .length ==
            4) {
          _completeTask();
        }
      }
    } else if (_scenario == 2) {
      if (_step == 0) {
        if (_items.where((i) => i.status == 'stage').length == 2) {
          _completeTask();
        }
      } else if (_step == 2) {
        if (_items.where((i) => i.status == 'stage').length == 1) {
          _completeTask();
        }
      } else if (_step == 4) {
        if (_items.where((i) => i.status == 'stage').length == 1) {
          _completeTask();
        }
      }
    }
  }

  void _completeTask() {
    if (_taskCompleted) return;
    setState(() {
      _taskCompleted = true;
    });
    _playSuccessSound();
    _showToast(_getString('toastTaskVal'));
  }

  void _nextStep() {
    if (_step < _getScenarioData().length - 1) {
      setState(() {
        _step++;
        _initScenario();
      });
    }
  }

  void _handleMachineAction(String action) {
    _playClickSound();
    if (_scenario == 1) {
      if (_step == 2) {
        if (action == 'up') {
          setState(() {
            _dialValue = 2;
            _showToast(_getString('toastDialSet'));
          });
        } else if (action == 'down') {
          setState(() {
            _dialValue = 1;
          });
        } else if (action == 'pack') {
          if (_dialValue == 2) {
            _playProcessSound();
            setState(() {
              _machineText = "2 × (3 + 4)";
            });
            for (int i = 0; i < 3; i++) {
              _items.add(
                GameItem(
                  id: 'a_dup_$i',
                  type: 'apple',
                  x: 650 + i * 60 + 200,
                  y: 380,
                  homeX: 650 + i * 60 + 200,
                  homeY: 380,
                  width: 50,
                  height: 50,
                  isDraggable: false,
                ),
              );
            }
            for (int i = 0; i < 4; i++) {
              _items.add(
                GameItem(
                  id: 'o_dup_$i',
                  type: 'orange',
                  x: 620 + i * 60 + 200,
                  y: 460,
                  homeX: 620 + i * 60 + 200,
                  homeY: 460,
                  width: 50,
                  height: 50,
                  isDraggable: false,
                ),
              );
            }
            _completeTask();
          } else {
            _showToast(_getString('toastSetDial'), isError: true);
            _playErrorSound();
          }
        }
      } else if (_step == 3 && action == 'multiply' && _taskCompleted) {
        _playProcessSound();
        setState(() {
          _machineText = "(2 × 3)";
          for (var item
              in _items
                  .where((i) => i.type == 'apple' && i.status == 'top_belt')
                  .toList()) {
            _items.add(
              GameItem(
                id: '${item.id}_dup',
                type: 'apple',
                x: item.x + 300,
                y: item.y,
                homeX: item.x + 300,
                homeY: item.y,
                width: 50,
                height: 50,
                isDraggable: false,
              ),
            );
          }
        });
      } else if (_step == 4 && action == 'multiply' && _taskCompleted) {
        _playProcessSound();
        setState(() {
          _machineText = "(2 × 4)";
          for (var item
              in _items
                  .where((i) => i.type == 'orange' && i.status == 'bottom_belt')
                  .toList()) {
            _items.add(
              GameItem(
                id: '${item.id}_dup',
                type: 'orange',
                x: item.x + 300,
                y: item.y,
                homeX: item.x + 300,
                homeY: item.y,
                width: 50,
                height: 50,
                isDraggable: false,
              ),
            );
          }
        });
      } else if (_step == 5 && action == 'combine') {
        _playProcessSound();
        setState(() {
          _machineText = "(2 × 3) + (2 × 4) = 6 Apples + 8 Oranges";
          int appleCount = 0;
          int orangeCount = 0;
          for (var item in _items) {
            if (item.type == 'apple') {
              item.x = 750 + (appleCount % 3) * 60.0;
              item.y = 350 + (appleCount ~/ 3) * 60.0;
              appleCount++;
            }
            if (item.type == 'orange') {
              item.x = 950 + (orangeCount % 4) * 60.0;
              item.y = 350 + (orangeCount ~/ 4) * 60.0;
              orangeCount++;
            }
          }
        });
        _completeTask();
      }
    }
  }

  // --- UI BUILDERS ---

  double _getSidebarWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.35;
    if (sidebarWidth < 350) sidebarWidth = 350;
    if (sidebarWidth > screenWidth * 0.9) sidebarWidth = screenWidth * 0.9;
    return sidebarWidth;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildCanvas(),
            _buildMachineOverlay(),
            _buildMissionFloatingCard(),
            _buildSidebar(),
            _buildTopMenuButton(), // Put on top of sidebar
            _buildToast(),
            if (_getScenarioData()[_step]['isEnd'] == true)
              _buildSummaryModal(),
            _buildCurtainScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    final double canvasLeftInset = (_isLabEntered && _isSidebarOpen)
        ? _getSidebarWidth(context)
        : 0;
    const double infiniteExtent = 60000;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      left: canvasLeftInset,
      right: 0,
      child: ClipRect(
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: InteractiveViewer(
            transformationController: _transformController,
            constrained: false,
            // Very large boundary + background layer creates an "infinite" canvas feel.
            boundaryMargin: const EdgeInsets.all(infiniteExtent),
            minScale: 0.2,
            maxScale: 4.0,
            panEnabled: _draggingId == null,
            scaleEnabled: _draggingId == null,
            trackpadScrollCausesScale: true,
            child: Container(
              width: _canvasWidth,
              height: _canvasHeight,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  radius: 1.5,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -infiniteExtent,
                    left: -infiniteExtent,
                    child: SizedBox(
                      width: infiniteExtent * 2,
                      height: infiniteExtent * 2,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            radius: 1.5,
                          ),
                        ),
                        child: CustomPaint(painter: GridPainter()),
                      ),
                    ),
                  ),
                  for (var zone in _zones)
                    Positioned(
                      left: zone.x,
                      top: zone.y,
                      width: zone.width,
                      height: zone.height,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            zone.type.toUpperCase().replaceAll('_', ' '),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_scenario == 1 && _step == 1)
                    Positioned(
                      left: 100,
                      top: 150,
                      width: 250,
                      height: 150,
                      child: _buildBin(Colors.indigoAccent, "Apples Bin"),
                    ),
                  if (_scenario == 1 && _step == 1)
                    Positioned(
                      left: 100,
                      top: 450,
                      width: 250,
                      height: 150,
                      child: _buildBin(Colors.orangeAccent, "Oranges Bin"),
                    ),
                  for (var item in _items)
                    AnimatedPositioned(
                      duration: _draggingId == item.id
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuad,
                      left: item.x,
                      top: item.y,
                      width: item.width,
                      height: item.height,
                      child: Visibility(
                        visible: item.isVisible,
                        child: _buildItemWidget(item),
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

  Widget _buildItemWidget(GameItem item) {
    if (item.type == 'apple') {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: const Icon(Icons.eco, color: Colors.green, size: 20),
      );
    } else if (item.type == 'orange') {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: const Icon(Icons.eco, color: Colors.green, size: 20),
      );
    } else if (item.type == 'blue_chair' || item.type == 'blue_chair_stack') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[800]!, width: 2),
        ),
        child: const Icon(Icons.chair, color: Colors.white70),
      );
    } else if (item.type == 'red_chair' || item.type == 'red_chair_stack') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[800]!, width: 2),
        ),
        child: const Icon(Icons.chair, color: Colors.white70),
      );
    } else if (item.type == 'multiplier') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.yellowAccent.withOpacity(0.3),
          border: Border.all(color: Colors.yellowAccent, width: 4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.yellowAccent, blurRadius: 20),
          ],
        ),
        child: const Center(
          child: Text(
            "x5\nSwipe",
            style: TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildBin(Color color, String label) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 4),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildMachineOverlay() {
    if (!_showMachineOverlay) return const SizedBox();

    return Positioned(
      bottom: 20,
      left: (_isLabEntered && _isSidebarOpen) ? _getSidebarWidth(context) : 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E293B), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEAB308)),
                ),
                child: Text(
                  _machineText,
                  style: const TextStyle(
                    color: Color(0xFFEAB308),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 24),

              if (_scenario == 1 && _step == 2) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_drop_up,
                        color: Colors.white,
                      ),
                      onPressed: () => _handleMachineAction('up'),
                    ),
                    Text(
                      _dialValue.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      onPressed: () => _handleMachineAction('down'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _handleMachineAction('pack'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "PACK",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],

              if (_scenario == 1 && (_step == 3 || _step == 4)) ...[
                ElevatedButton(
                  onPressed: _taskCompleted
                      ? null
                      : () => _handleMachineAction('multiply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "x2",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],

              if (_scenario == 1 && _step == 5) ...[
                ElevatedButton(
                  onPressed: _taskCompleted
                      ? null
                      : () => _handleMachineAction('combine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    "COMBINE",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopMenuButton() {
    return Positioned(
      top: 16,
      left: 16, // Fixed top left, overlays sidebar
      child: IconButton(
        icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
        color: Colors.orangeAccent,
        iconSize: 28,
        onPressed: () {
          HapticFeedback.lightImpact();
          _playClickSound();
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
    );
  }

  Widget _buildMissionFloatingCard() {
    return AnimatedOpacity(
      opacity: !_isSidebarOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: _isSidebarOpen,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 66, left: 8),
            child: Container(
              width: 280,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getString('missionObj').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFEAB308),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getScenarioData()[_step]['instruction'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_getScenarioData()[_step]['autoComplete'] == true ||
                      _taskCompleted) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getString('continueBtn'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final double sidebarWidth = _getSidebarWidth(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      left: _isSidebarOpen ? 0 : -sidebarWidth, // Sidebar is now on the left
      width: sidebarWidth,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          border: Border(right: BorderSide(color: Color(0xFF1E293B))),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15)],
        ),
        // Make complete sidebar scrollable with CustomScrollView keeping footer at bottom
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  // --- Header Component ---
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      66,
                      16,
                      16,
                    ), // Padding to account for the menu button on top left
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF1E293B)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.calculate_outlined,
                              color: Color(0xFFEAB308),
                              size: 40,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getString('headerTitle'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getString('headerSubtitle').toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: _toggleLanguage,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _currentLang.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _resetLab,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Text(
                          _getString('selectScenario').toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020617),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _scenario,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF0F172A),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF94A3B8),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    _getString('scenarios', '1', 'name'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(
                                    _getString('scenarios', '2', 'name'),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _scenario = val;
                                    _step = 0;
                                    _initScenario();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Body Component ---
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.book,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getString('theoryHeader'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getScenarioData()[_step]['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getScenarioData()[_step]['theory']
                                    .replaceAll('<br>', '\n')
                                    .replaceAll('<b>', '')
                                    .replaceAll('</b>', ''),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                              if (_getScenarioData()[_step]['math'] != "") ...[
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    _getScenarioData()[_step]['math'],
                                    style: const TextStyle(
                                      color: Color(0xFFEAB308),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.format_list_numbered,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getString('stepsHeader'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        for (int i = 1; i < _getScenarioData().length; i++)
                          if (_getScenarioData()[i]['isEnd'] != true)
                            _buildStepCard(i),

                        const SizedBox(height: 24),

                        if (_getScenarioData()[_step]['autoComplete'] == true ||
                            _taskCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                _getScenarioData()[_step]['isEnd'] == true
                                    ? _getString('validateBtn')
                                    : (_step == 0
                                          ? _getString('startInv')
                                          : _getString('continueBtn')),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Spacer(), // Pushes footer to the absolute bottom if content is short
                  // --- Footer Component ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                    ),
                    child: const Center(
                      child: Text(
                        "© ZeroScienceLab - Fall in love with math and Science",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(int index) {
    bool isActive = index == _step;
    bool isPast = index < _step;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEAB308) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.transparent : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_getString('stepPrefix')} $index",
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              decoration: isPast ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getScenarioData()[index]['instruction'],
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              decoration: isPast ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToast() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: _toastMessage != null ? 40 : -100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _toastIsError ? Colors.redAccent : Colors.green,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _toastMessage ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryModal() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1E293B)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFFEAB308),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _getString('summaryTitle'),
                style: const TextStyle(
                  color: Color(0xFFEAB308),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getString(
                  _scenario == 1 ? 's1_summaryText' : 's2_summaryText',
                ).replaceAll('<br>', '\n'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Text(
                  _scenario == 1
                      ? "2 × (3 + 4) = (2 × 3) + (2 × 4)"
                      : "(4 + 3) × 5 = (4 × 5) + (3 × 5)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _resetLab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Restart Lab",
                  style: TextStyle(
                    color: Color(0xFF020617),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurtainScreen() {
    return AnimatedPositioned(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutCubic,
      top: _isLabEntered ? -MediaQuery.of(context).size.height : 0,
      bottom: _isLabEntered ? MediaQuery.of(context).size.height : 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xFF020617),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calculate_outlined,
                  color: Color(0xFFEAB308),
                  size: 80,
                ),
                const SizedBox(height: 14),
                Text(
                  _getString('appTitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _getString('appSubtitle'),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _enterLab,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 10,
                    shadowColor: const Color(0xFFEAB308).withOpacity(0.5),
                  ),
                  child: Text(
                    _getString('enterLab'),
                    style: const TextStyle(
                      color: Color(0xFF020617),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DATA HELPERS ---

  List<dynamic> _getScenarioData() {
    if (_scenario == 1) return _scen1Data[_currentLang] ?? _scen1Data['en'];
    return _scen2Data[_currentLang] ?? _scen2Data['en'];
  }

  String _getString(String key, [String? sub1, String? sub2]) {
    var langData = _i18n[_currentLang]!;
    if (sub1 != null && sub2 != null) {
      return langData[key][sub1][sub2] as String;
    }
    return langData[key] as String? ?? key;
  }

  final Map<String, dynamic> _i18n = {
    'en': {
      'appTitle':
          "The Great Distribution Machine: Applying the Distributive Property",
      'appSubtitle': "Class 7 • ARITHMETIC EXPRESSIONS",
      'enterLab': "Enter Lab",
      'headerTitle':
          "The Great Distribution Machine: Applying the Distributive Property",
      'headerSubtitle': "Class 7 • ARITHMETIC EXPRESSIONS",
      'missionObj': "Mission Objective",
      'initLab': "Initialize Lab to begin...",
      'startInv': "Start Investigation",
      'continueBtn': "Continue",
      'validateBtn': "Validate Model",
      'summaryTitle': "Summary",
      'theoryHeader': "Theory",
      'stepsHeader': "Procedural Steps",
      'stepPrefix': "STEP",
      'selectScenario': "Select Scenario",
      'toastTaskVal': "Task Validated!",
      'toastSetDial': "Set the dial to 2 first!",
      'toastDialSet': "Dial set to 2!",
      's1_summaryText':
          "Packing a combo of (3 apples + 4 oranges) twice gives the same total fruit as packing 2 sets of 3 apples and 2 sets of 4 oranges.<br><br>Therefore:",
      's2_summaryText':
          "Creating a 7-row block and multiplying by 5 columns gives the exact same seating plan as creating a 4x5 block and a 3x5 block and combining them.<br><br>Therefore:",
      'scenarios': {
        '1': {'name': "1. The Super-Duper Lunchbox Packer"},
        '2': {'name': "2. Auditorium Seating Arrangement"},
      },
    },
    'hi': {
      'appTitle': "महान वितरण मशीन: वितरण गुण का अनुप्रयोग",
      'appSubtitle': "कक्षा 7 • अंकगणितीय व्यंजक",
      'enterLab': "लैब में प्रवेश करें",
      'headerTitle': "महान वितरण मशीन: वितरण गुण का अनुप्रयोग",
      'headerSubtitle': "कक्षा 7 • अंकगणितीय व्यंजक",
      'missionObj': "मिशन का उद्देश्य",
      'initLab': "शुरू करने के लिए लैब इनिशियलाइज़ करें...",
      'startInv': "जांच शुरू करें",
      'continueBtn': "जारी रखें",
      'validateBtn': "मॉडल मान्य करें",
      'summaryTitle': "सारांश",
      'theoryHeader': "सिद्धांत",
      'stepsHeader': "प्रक्रियात्मक चरण",
      'stepPrefix': "चरण",
      'selectScenario': "परिदृश्य चुनें",
      'toastTaskVal': "कार्य मान्य!",
      'toastSetDial': "पहले डायल को 2 पर सेट करें!",
      'toastDialSet': "डायल 2 पर सेट है!",
      's1_summaryText':
          "(3 सेब + 4 संतरे) के कॉम्बो को दो बार पैक करने से कुल फल उतना ही होता है जितना 3 सेब के 2 सेट और 4 संतरे के 2 सेट पैक करने से होता है।<br><br>इसलिए:",
      's2_summaryText':
          "7-पंक्ति ब्लॉक बनाना और 5 कॉलम से गुणा करना 4x5 और 3x5 ब्लॉक बनाकर उन्हें मिलाने के बिल्कुल समान बैठने की योजना देता है।<br><br>इसलिए:",
      'scenarios': {
        '1': {'name': "1. सुपर-डूपर लंचबॉक्स पैकर"},
        '2': {'name': "2. ऑडिटोरियम बैठने की व्यवस्था"},
      },
    },
    'te': {
      'appTitle': "గొప్ప పంపిణీ యంత్రం: పంపిణీ ధర్మాన్ని వర్తింపజేయడం",
      'appSubtitle': "తరగతి 7 • అంకగణిత వ్యక్తీకరణలు",
      'enterLab': "ల్యాబ్‌లోకి ప్రవేశించండి",
      'headerTitle': "గొప్ప పంపిణీ యంత్రం: పంపిణీ ధర్మాన్ని వర్తింపజేయడం",
      'headerSubtitle': "తరగతి 7 • అంకగణిత వ్యక్తీకరణలు",
      'missionObj': "మిషన్ లక్ష్యం",
      'initLab': "ప్రారంభించడానికి ల్యాబ్‌ని ఇనిషియలైజ్ చేయండి...",
      'startInv': "దర్యాప్తు ప్రారంభించండి",
      'continueBtn': "కొనసాగించండి",
      'validateBtn': "మోడల్‌ను ధృవీకరించండి",
      'summaryTitle': "సారాంశం",
      'theoryHeader': "సిద్ధాంతం",
      'stepsHeader': "విధానపరమైన దశలు",
      'stepPrefix': "దశ",
      'selectScenario': "సన్నివేశాన్ని ఎంచుకోండి",
      'toastTaskVal': "టాస్క్ ధృవీకరించబడింది!",
      'toastSetDial': "ముందుగా డయల్‌ను 2కి సెట్ చేయండి!",
      'toastDialSet': "డయల్ 2కి సెట్ చేయబడింది!",
      's1_summaryText':
          "(3 ఆపిల్స్ + 4 నారింజలు) కాంబోను రెండుసార్లు ప్యాక్ చేయడం వలన 3 ఆపిల్స్ మరియు 4 నారింజల 2 సెట్‌లను ప్యాక్ చేసినంత సమానమైన మొత్తం పండ్లను ఇస్తుంది.<br><br>కాబట్టి:",
      's2_summaryText':
          "7-వరుసల బ్లాక్‌ను సృష్టించడం మరియు 5 నిలువు వరుసల ద్వారా గుణించడం ద్వారా 4x5 మరియు 3x5 బ్లాక్‌లను సృష్టించి వాటిని కలిపినప్పుడు వచ్చే సీటింగ్ ప్లాన్ సమానంగా ఉంటుంది.<br><br>కాబట్టి:",
      'scenarios': {
        '1': {'name': "1. సూపర్-డూపర్ లంచ్‌బాక్స్ ప్యాకర్"},
        '2': {'name': "2. ఆడిటోరియం సీటింగ్ అమరిక"},
      },
    },
  };

  final Map<String, dynamic> _scen1Data = {
    'en': [
      {
        'title': "Concept Introduction",
        'theory':
            "The Distributive Property lets us break down complicated math into easier pieces.<br><br>Imagine multiplying a number by a group of items inside parentheses:<br>a × (b + c) = (a × b) + (a × c)",
        'math': "a × (b + c) = (a × b) + (a × c)",
        'instruction': "Read the theory, then click 'Start Investigation'.",
        'autoComplete': true,
      },
      {
        'title': "Step 1: Prepare Single Combo Tray",
        'theory':
            "Let's try the first method: <b>Group first, then multiply.</b><br>We have apples and oranges. 3 apples and 4 oranges are placed together.",
        'math': "(3 + 4)",
        'instruction':
            "DRAG 3 apples and 4 oranges onto the metal packing tray.",
        'autoComplete': false,
      },
      {
        'title': "Step 2: Multiply & Pack",
        'theory': "The Combo Packer multiplies by 2. It doubles the contents.",
        'math': "2 × (3 + 4)",
        'instruction':
            "Click the DIAL to set it to '2', then click the PACK button.",
        'autoComplete': false,
      },
      {
        'title': "Step 3: Prepare Apple Bulk",
        'theory':
            "Isolating the fruit types. A group of 3 apples is multiplied by 2.",
        'math': "(2 × 3)",
        'instruction':
            "Drag 3 apples to the Top Belt, then click the 'x2' button.",
        'autoComplete': false,
      },
      {
        'title': "Step 4: Prepare Orange Bulk",
        'theory': "A group of 4 oranges is multiplied by 2.",
        'math': "(2 × 4)",
        'instruction':
            "Drag 4 oranges to the Bottom Belt, then click the 'x2' button.",
        'autoComplete': false,
      },
      {
        'title': "Step 5: Combine & Result",
        'theory': "The Bulk Packer merges the two groups.",
        'math': "(2 × 3) + (2 × 4)",
        'instruction':
            "Click the big COMBINE button on the Bulk Packer machine.",
        'autoComplete': false,
      },
      {
        'title': "Conclusion",
        'theory':
            "Method 1: 6 apples, 8 oranges.<br>Method 2: 6 apples, 8 oranges.",
        'math': "2 × (3 + 4) = (2 × 3) + (2 × 4)",
        'instruction': "Review the final summary.",
        'autoComplete': true,
        'isEnd': true,
      },
    ],
    'hi': [
      {
        'title': "अवधारणा परिचय",
        'theory':
            "वितरण गुण (Distributive Property) हमें जटिल गणित को आसान टुकड़ों में तोड़ने की सुविधा देता है।<br><br>कल्पना करें कि कोष्ठक के अंदर वस्तुओं के समूह को एक संख्या से गुणा करना है:<br>a × (b + c) = (a × b) + (a × c)",
        'math': "a × (b + c) = (a × b) + (a × c)",
        'instruction': "सिद्धांत पढ़ें, फिर 'जांच शुरू करें' पर क्लिक करें।",
        'autoComplete': true,
      },
      {
        'title': "चरण 1: सिंगल कॉम्बो ट्रे तैयार करें",
        'theory':
            "पहला तरीका आज़माएं: <b>पहले समूह बनाएं, फिर गुणा करें।</b><br>हमारे पास सेब और संतरे हैं। 3 सेब और 4 संतरे एक साथ रखे गए हैं।",
        'math': "(3 + 4)",
        'instruction': "धातु की पैकिंग ट्रे पर 3 सेब और 4 संतरे खींचें (DRAG)।",
        'autoComplete': false,
      },
      {
        'title': "चरण 2: गुणा और पैक",
        'theory':
            '"कॉम्बो पैकर" 2 से गुणा करने के लिए सेट है। यह सामग्री को दोगुना कर देता है।',
        'math': "2 × (3 + 4)",
        'instruction':
            "डायल को '2' पर सेट करने के लिए क्लिक करें, फिर पैक बटन पर क्लिक करें।",
        'autoComplete': false,
      },
      {
        'title': "चरण 3: थोक सेब तैयार करें",
        'theory':
            "फलों के प्रकारों को अलग कर रहे हैं। 3 सेबों के समूह को 2 से गुणा किया जाता है।",
        'math': "(2 × 3)",
        'instruction':
            "3 सेबों को टॉप बेल्ट पर खींचें, फिर 'x2' बटन पर क्लिक करें।",
        'autoComplete': false,
      },
      {
        'title': "चरण 4: थोक संतरे तैयार करें",
        'theory': "इसी तरह, 4 संतरों के समूह को 2 से गुणा किया जाता है।",
        'math': "(2 × 4)",
        'instruction':
            "4 संतरों को बॉटम बेल्ट पर खींचें, फिर 'x2' बटन पर क्लिक करें।",
        'autoComplete': false,
      },
      {
        'title': "चरण 5: मिलाएं और परिणाम",
        'theory': '"बल्क पैकर" दो समूहों को मिलाता है।',
        'math': "(2 × 3) + (2 × 4)",
        'instruction':
            "बल्क पैकर मशीन पर बड़े मिलाएं (COMBINE) बटन पर क्लिक करें।",
        'autoComplete': false,
      },
      {
        'title': "निष्कर्ष",
        'theory': "विधि 1: 6 सेब, 8 संतरे।<br>विधि 2: 6 सेब, 8 संतरे।",
        'math': "2 × (3 + 4) = (2 × 3) + (2 × 4)",
        'instruction': "अंतिम सारांश की समीक्षा करें।",
        'autoComplete': true,
        'isEnd': true,
      },
    ],
    'te': [
      {
        'title': "భావన పరిచయం",
        'theory':
            "పంపిణీ ధర్మం (Distributive Property) క్లిష్టమైన గణితాన్ని సులభమైన భాగాలుగా విభజించడానికి అనుమతిస్తుంది.<br><br>కుండలీకరణాల లోపల ఉన్న వస్తువుల సమూహం ద్వారా సంఖ్యను గుణించడాన్ని ఊహించండి:<br>a × (b + c) = (a × b) + (a × c)",
        'math': "a × (b + c) = (a × b) + (a × c)",
        'instruction':
            "సిద్ధాంతాన్ని చదవండి, ఆపై 'దర్యాప్తు ప్రారంభించండి' క్లిక్ చేయండి.",
        'autoComplete': true,
      },
      {
        'title': "దశ 1: సింగిల్ కాంబో ట్రేను సిద్ధం చేయండి",
        'theory':
            "మొదటి పద్ధతిని ప్రయత్నిద్దాం: <b>ముందుగా సమూహం చేయండి, తరువాత గుణించండి.</b><br>మన వద్ద ఆపిల్స్ మరియు నారింజలు ఉన్నాయి. 3 ఆపిల్‌లు మరియు 4 నారింజలు కలిపి ఉంచబడ్డాయి.",
        'math': "(3 + 4)",
        'instruction':
            "మెటల్ ప్యాకింగ్ ట్రే పైకి 3 ఆపిల్స్ మరియు 4 నారింజలను లాగండి (DRAG).",
        'autoComplete': false,
      },
      {
        'title': "దశ 2: గుణకారం & ప్యాక్",
        'theory':
            '"కాంబో ప్యాకర్" 2తో గుణించడానికి సెట్ చేయబడింది. ఇది కంటెంట్‌లను రెట్టింపు చేస్తుంది.',
        'math': "2 × (3 + 4)",
        'instruction':
            "డయల్‌ని '2'కి సెట్ చేయడానికి దానిపై క్లిక్ చేసి, ఆపై ప్యాక్ బటన్‌ను క్లిక్ చేయండి.",
        'autoComplete': false,
      },
      {
        'title': "దశ 3: ఆపిల్ బల్క్ సిద్ధం చేయండి",
        'theory':
            "పండ్ల రకాలను వేరు చేస్తుంది. 3 ఆపిల్‌ల సమూహం 2తో గుణించబడుతుంది.",
        'math': "(2 × 3)",
        'instruction':
            "పై బెల్ట్‌పైకి 3 ఆపిల్‌లను లాగండి, ఆపై 'x2' బటన్‌ను క్లిక్ చేయండి.",
        'autoComplete': false,
      },
      {
        'title': "దశ 4: ఆరెంజ్ బల్క్ సిద్ధం చేయండి",
        'theory': "అదేవిధంగా, 4 నారింజల సమూహాన్ని 2తో గుణించడం జరుగుతుంది.",
        'math': "(2 × 4)",
        'instruction':
            "దిగువ బెల్ట్‌కి 4 నారింజలను లాగండి, ఆపై 'x2' బటన్‌ను క్లిక్ చేయండి.",
        'autoComplete': false,
      },
      {
        'title': "దశ 5: కలపండి & ఫలితం",
        'theory': '"బల్క్ ప్యాకర్" రెండు సమూహాలను విలీనం చేస్తుంది.',
        'math': "(2 × 3) + (2 × 4)",
        'instruction':
            "బల్క్ ప్యాకర్ మెషీన్‌లోని పెద్ద COMBINE బటన్‌ను క్లిక్ చేయండి.",
        'autoComplete': false,
      },
      {
        'title': "ముగింపు",
        'theory':
            "విధానం 1: 6 ఆపిల్స్, 8 నారింజలు.<br>విధానం 2: 6 ఆపిల్స్, 8 నారింజలు.",
        'math': "2 × (3 + 4) = (2 × 3) + (2 × 4)",
        'instruction': "తుది సారాంశాన్ని సమీక్షించండి.",
        'autoComplete': true,
        'isEnd': true,
      },
    ],
  };

  final Map<String, dynamic> _scen2Data = {
    'en': [
      {
        'title': "Auditorium Seating Setup",
        'theory':
            "Let's physically demonstrate that (4 + 3) × 5 is the same as (4 × 5) + (3 × 5) by arranging chairs.",
        'math': "",
        'instruction': "Read the theory, then click 'Start Investigation'.",
        'autoComplete': true,
      },
      {
        'title': "Step 1: Place Chair Rows",
        'theory':
            "Group the chairs before multiplying. 4 rows of blue and 3 rows of red.",
        'math': "(4 + 3)",
        'instruction':
            "DRAG the blue chair rows to the stage, then DRAG the red chair rows below it.",
        'autoComplete': false,
      },
      {
        'title': "Step 2: Multiply Rows",
        'theory': "Expand this combined block to have 5 columns.",
        'math': "(4 + 3) × 5",
        'instruction': "DRAG the 'Column Multiplier' tool across the chairs.",
        'autoComplete': false,
      },
      {
        'title': "Step 3: Separate Groups (Blue)",
        'theory': "Second method: multiply the groups separately.",
        'math': "(4 × 5)",
        'instruction': "DRAG the stack of blue rows back out.",
        'autoComplete': false,
      },
      {
        'title': "Step 4: Multiply Blue Rows",
        'theory': "Expand the blue rows to 5 columns.",
        'math': "(4 × 5)",
        'instruction': "DRAG the Multiplier tool onto the blue chairs.",
        'autoComplete': false,
      },
      {
        'title': "Step 5: Add Red Rows & Multiply",
        'theory': "Add the red rows and expand them.",
        'math': "(4 × 5) + (3 × 5)",
        'instruction':
            "DRAG the red rows below the blue chairs, then DRAG the Multiplier tool onto them.",
        'autoComplete': false,
      },
      {
        'title': "Conclusion",
        'theory': "Look at the results! Exact same 7x5 arrangement.",
        'math': "(4 + 3) × 5 = (4 × 5) + (3 × 5)",
        'instruction': "Review the final summary.",
        'autoComplete': true,
        'isEnd': true,
      },
    ],
    'hi': [
      {
        'title': "ऑडिटोरियम बैठने की व्यवस्था",
        'theory':
            "आइए भौतिक रूप से प्रदर्शित करें कि कुर्सियों की व्यवस्था करके (4 + 3) × 5, (4 × 5) + (3 × 5) के समान है।",
        'math': "",
        'instruction': "सिद्धांत पढ़ें, फिर 'जांच शुरू करें' पर क्लिक करें।",
        'autoComplete': true,
      },
      {
        'title': "चरण 1: कुर्सी की पंक्तियाँ रखें",
        'theory':
            "गुणा करने से पहले कुर्सियों को समूहित करते हैं। 4 नीली पंक्तियां और 3 लाल पंक्तियां।",
        'math': "(4 + 3)",
        'instruction':
            "नीली कुर्सी की पंक्तियों को मंच (stage) पर खींचें, फिर लाल कुर्सियों को उसके नीचे खींचें।",
        'autoComplete': false,
      },
      {
        'title': "चरण 2: पंक्तियों को गुणा करें",
        'theory': "अब, आइए इस संयुक्त ब्लॉक को 5 कॉलम तक विस्तारित करें।",
        'math': "(4 + 3) × 5",
        'instruction': "कॉलम गुणक (Multiplier) उपकरण को कुर्सियों पर खींचें।",
        'autoComplete': false,
      },
      {
        'title': "चरण 3: समूहों को अलग करें (नीला)",
        'theory': "अब दूसरा तरीका आजमाते हैं: समूहों को अलग-अलग गुणा करें।",
        'math': "(4 × 5)",
        'instruction': "नीली पंक्तियों के ढेर को बाहर खींचें।",
        'autoComplete': false,
      },
      {
        'title': "चरण 4: नीली पंक्तियों को गुणा करें",
        'theory': "नीली पंक्तियों को 5 कॉलम तक विस्तारित करें।",
        'math': "(4 × 5)",
        'instruction':
            "मल्टीप्लायर (Multiplier) टूल को नीली कुर्सियों पर खींचें।",
        'autoComplete': false,
      },
      {
        'title': "चरण 5: लाल पंक्तियाँ जोड़ें और गुणा करें",
        'theory':
            "अब लाल पंक्तियों को जोड़ें और उन्हें 5 कॉलम तक विस्तारित करें।",
        'math': "(4 × 5) + (3 × 5)",
        'instruction':
            "नीली कुर्सियों के नीचे लाल पंक्तियों को खींचें, फिर उन पर गुणक उपकरण खींचें।",
        'autoComplete': false,
      },
      {
        'title': "निष्कर्ष",
        'theory': "परिणाम देखो! बिल्कुल समान 7x5 बैठने की व्यवस्था।",
        'math': "(4 + 3) × 5 = (4 × 5) + (3 × 5)",
        'instruction': "अंतिम सारांश की समीक्षा करें।",
        'autoComplete': true,
        'isEnd': true,
      },
    ],
  };
}

// Custom Grid Painter for Background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.5)
      ..strokeWidth = 1.0;

    const double step = 50;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
