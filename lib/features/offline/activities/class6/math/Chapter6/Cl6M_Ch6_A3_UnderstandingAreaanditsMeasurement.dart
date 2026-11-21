// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch6_A3_UnderstandingAreaanditsMeasurement(),
    ),
  );
}

// --- Data Models & Simulation State ---

class SimPoint {
  int x, y;
  SimPoint(this.x, this.y);
  @override
  bool operator ==(Object other) =>
      other is SimPoint && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
}

class SimRect {
  int x, y, w, h;
  SimRect(this.x, this.y, this.w, this.h);
}

class SimLog {
  String name;
  int p;
  SimLog(this.name, this.p);
}

class SimState {
  bool animating = false;
  double animProgress = 0.0;
  String? activeDragEntity;
  double dragX = 0, dragY = 0;
  double dragStartX = 0, dragStartY = 0;

  // S1
  List<SimPoint> s1Tiles = [];

  // S2
  bool s2RowFilled = false;
  bool s2ColFilled = false;
  bool s2Calculated = false;

  // S3
  bool s3CutConfirmed = false;
  bool s3Tile1 = false;
  bool s3Tile2 = false;
  bool s3Add1 = false;
  bool s3Add2 = false;
  bool s3MachineHover = false;

  // S4
  SimRect? s4Veg;
  SimRect? s4Flo;
  String? s4Resizing;
  bool s4Overlap = false;
  bool s4Completed = false;

  // S5
  List<SimPoint> s5Blocks = [];
  int s5Painted = 0;
  bool s5RectValid = false;
  bool s5IsPainting = false;
  bool s5IsErasing = false;
  bool s5Measured = false;
  bool s5Measuring = false;
  List<SimLog> s5Logs = [];

  // Prevents canvas panning when an interaction is actively occurring.
  bool get isInteracting =>
      activeDragEntity != null ||
      s4Resizing != null ||
      s5IsPainting ||
      s5IsErasing;

  void resetScenario(int sc) {
    animating = false;
    animProgress = 0;
    activeDragEntity = null;
    if (sc == 1) {
      s1Tiles.clear();
    }
    if (sc == 2) {
      s2RowFilled = false;
      s2ColFilled = false;
      s2Calculated = false;
    }
    if (sc == 3) {
      s3CutConfirmed = false;
      s3Tile1 = false;
      s3Tile2 = false;
      s3Add1 = false;
      s3Add2 = false;
    }
    if (sc == 4) {
      s4Veg = null;
      s4Flo = null;
      s4Resizing = null;
      s4Overlap = false;
      s4Completed = false;
    }
    if (sc == 5) {
      s5Blocks.clear();
      s5Painted = 0;
      s5RectValid = false;
      s5Logs.clear();
      s5Measured = false;
      s5Measuring = false;
      s5IsPainting = false;
      s5IsErasing = false;
    }
  }
}

// --- Main Screen ---

class Cl6M_Ch6_A3_UnderstandingAreaanditsMeasurement extends StatefulWidget {
  const Cl6M_Ch6_A3_UnderstandingAreaanditsMeasurement({super.key});

  @override
  State<Cl6M_Ch6_A3_UnderstandingAreaanditsMeasurement> createState() =>
      _Cl6M_Ch6_A3_UnderstandingAreaanditsMeasurementState();
}

class _Cl6M_Ch6_A3_UnderstandingAreaanditsMeasurementState
    extends State<Cl6M_Ch6_A3_UnderstandingAreaanditsMeasurement>
    with SingleTickerProviderStateMixin {
  late AnimationController _gameLoop;
  final GlobalKey _canvasKey = GlobalKey();

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // UI State
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  bool _isDraggingSidebar = false;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;
  String _lang = 'en';

  // Game State
  int _scenario = 1;
  int _step = 0;
  double _panX = 0, _panY = 0, _zoom = 1.0, _baseZoom = 1.0;
  final SimState _sim = SimState();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..addListener(_updateLoop);
    _gameLoop.forward();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoop.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  // --- Network Audio Sources (Child Friendly) ---

  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  // --- Core Game Logic ---

  void _updateLoop() {
    setState(() {}); // Trigger CustomPainter rebuild
  }

  void _toggleLanguage() {
    playClick();
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  void _toggleSidebar() {
    playClick();
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _fitScreen() {
    setState(() {
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
    });
  }

  void _loadScenario(int sc) {
    setState(() {
      _scenario = sc;
      _step = 0;
      _sim.resetScenario(sc);
      _showSuccessPopup = false;
    });
    _fitScreen();
  }

  void _resetLab() {
    playClick();
    setState(() {
      _showCurtain = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _loadScenario(1);
      setState(() {
        _showCurtain = false;
      });
    });
  }

  void _advanceStep() {
    playPageOpen(); // Child-friendly success reward for completing a step
    setState(() {
      _step++;
    });
  }

  void _checkScenarioSuccess() {
    final conf = _getScenarioConfig(_scenario);
    if (_step >= conf['steps'].length && !_showSuccessPopup) {
      playPageOpen();
      setState(() {
        _showSuccessPopup = true;
      });
    }
  }

  // --- Pointer Interactions (Mapped to Canvas World) ---

  Offset _getCanvasPoint(Offset globalPosition) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset local = box.globalToLocal(globalPosition);
    final double cx = box.size.width / 2;
    final double cy = box.size.height / 2;
    final double worldX = (local.dx - cx - _panX) / _zoom;
    final double worldY = (local.dy - cy - _panY) / _zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  bool _rectsOverlap(SimRect r1, SimRect r2) {
    return !(r2.x >= r1.x + r1.w ||
        r2.x + r2.w <= r1.x ||
        r2.y >= r1.y + r1.h ||
        r2.y + r2.h <= r1.y);
  }

  void _handlePointerDown(PointerDownEvent e) {
    final pt = _getCanvasPoint(e.position);

    if (_scenario == 1) {
      if (_hitTestBox(-100, 80, 80, 80, pt)) {
        playClick();
        _sim.activeDragEntity = 's1_tile';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
      if (_step == 2 && _hitTestBox(120, 130, 120, 60, pt)) {
        playClick();
        _triggerAction('s1_check');
        return;
      }
    } else if (_scenario == 2) {
      if (_step == 0 && _hitTestBox(-290, -180, 60, 60, pt)) {
        playClick();
        _sim.activeDragEntity = 's2_row';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
      if (_step == 1 && _hitTestBox(-290, -100, 60, 60, pt)) {
        playClick();
        _sim.activeDragEntity = 's2_col';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
      if (_step == 2 && _hitTestBox(-70, 105, 140, 50, pt)) {
        playClick();
        _triggerAction('s2_calc');
        return;
      }
    } else if (_scenario == 3) {
      if (_step == 0 &&
          !_sim.s3CutConfirmed &&
          _hitTestBox(-210, -190, 40, 320, pt)) {
        playClick();
        _sim.activeDragEntity = 's3_laser';
        _sim.dragX = pt.dx;
        return;
      }
      if (_sim.s3CutConfirmed &&
          !_sim.s3Tile1 &&
          _hitTestBox(-120, -95, 80, 30, pt)) {
        playClick();
        _triggerAction('s3_tile1');
        return;
      }
      if (_step >= 2 &&
          _sim.s3CutConfirmed &&
          !_sim.s3Tile2 &&
          _hitTestBox(55, 45, 80, 30, pt)) {
        playClick();
        _triggerAction('s3_tile2');
        return;
      }
      if (_sim.s3Tile1 &&
          _step >= 3 &&
          !_sim.s3Add1 &&
          _hitTestBox(-140, -110, 120, 60, pt)) {
        playClick();
        _sim.activeDragEntity = 's3_num1';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
      if (_sim.s3Tile2 &&
          _step >= 3 &&
          !_sim.s3Add2 &&
          _hitTestBox(35, 35, 120, 60, pt)) {
        playClick();
        _sim.activeDragEntity = 's3_num2';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
    } else if (_scenario == 4) {
      double u = 40, gx = -150, gy = -160;
      if (_sim.s4Veg == null && _hitTestBox(gx - 120, gy, 100, 40, pt)) {
        playClick();
        _sim.activeDragEntity = 's4_veg_new';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
      if (_sim.s4Flo == null &&
          _step >= 1 &&
          _hitTestBox(gx - 120, gy + 60, 100, 40, pt)) {
        playClick();
        _sim.activeDragEntity = 's4_flo_new';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
      if (_sim.s4Veg != null &&
          _hitTestBox(
            gx + _sim.s4Veg!.x * u + _sim.s4Veg!.w * u - 16,
            gy + _sim.s4Veg!.y * u + _sim.s4Veg!.h * u - 16,
            32,
            32,
            pt,
          )) {
        playClick();
        _sim.s4Resizing = 'veg';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
      if (_sim.s4Flo != null &&
          _hitTestBox(
            gx + _sim.s4Flo!.x * u + _sim.s4Flo!.w * u - 16,
            gy + _sim.s4Flo!.y * u + _sim.s4Flo!.h * u - 16,
            32,
            32,
            pt,
          )) {
        playClick();
        _sim.s4Resizing = 'flo';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        return;
      }
      if (_sim.s4Veg != null &&
          _hitTestBox(
            gx + _sim.s4Veg!.x * u,
            gy + _sim.s4Veg!.y * u,
            _sim.s4Veg!.w * u,
            _sim.s4Veg!.h * u,
            pt,
          )) {
        playClick();
        _sim.activeDragEntity = 's4_veg_move';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        _sim.dragStartX = pt.dx - (gx + _sim.s4Veg!.x * u);
        _sim.dragStartY = pt.dy - (gy + _sim.s4Veg!.y * u);
        return;
      }
      if (_sim.s4Flo != null &&
          _hitTestBox(
            gx + _sim.s4Flo!.x * u,
            gy + _sim.s4Flo!.y * u,
            _sim.s4Flo!.w * u,
            _sim.s4Flo!.h * u,
            pt,
          )) {
        playClick();
        _sim.activeDragEntity = 's4_flo_move';
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        _sim.dragStartX = pt.dx - (gx + _sim.s4Flo!.x * u);
        _sim.dragStartY = pt.dy - (gy + _sim.s4Flo!.y * u);
        return;
      }
    } else if (_scenario == 5) {
      double u = 30, gx = -200, gy = -200;
      if (_hitTestBox(gx - 140, gy + 100, 120, 60, pt) &&
          _sim.s5RectValid &&
          !_sim.s5Measured) {
        playClick();
        _triggerAction('s5_measure');
        return;
      }
      if (_hitTestBox(gx - 140, gy + 180, 120, 40, pt) && _step >= 2) {
        playClick();
        _triggerAction('s5_reset');
        return;
      }
      if (_hitTestBox(gx, gy, 20 * u, 12 * u, pt) && !_sim.s5RectValid) {
        playClick();
        int cx = ((pt.dx - gx) / u).floor();
        int cy = ((pt.dy - gy) / u).floor();
        if (cx >= 0 && cx < 20 && cy >= 0 && cy < 12) {
          int existingIdx = _sim.s5Blocks.indexWhere(
            (b) => b.x == cx && b.y == cy,
          );
          if (existingIdx != -1) {
            _sim.s5IsErasing = true;
            _sim.s5Blocks.removeAt(existingIdx);
            _sim.s5Painted--;
            _checkS5Valid();
          } else if (_sim.s5Painted < 18) {
            _sim.s5IsPainting = true;
            _sim.s5Blocks.add(SimPoint(cx, cy));
            _sim.s5Painted++;
            _checkS5Valid();
          }
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent e) {
    final pt = _getCanvasPoint(e.position);

    if (_sim.activeDragEntity != null) {
      if (_sim.activeDragEntity == 's3_laser') {
        double targetX = -10;
        _sim.dragX = (pt.dx - targetX).abs() < 50 ? targetX : pt.dx;
      } else if (_sim.activeDragEntity == 's3_num1' ||
          _sim.activeDragEntity == 's3_num2') {
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
        _sim.s3MachineHover = _hitTestBox(180, -60, 200, 200, pt);
      } else if (_sim.activeDragEntity!.endsWith('_move')) {
        double u = 40, gx = -150, gy = -160;
        SimRect target = _sim.activeDragEntity == 's4_veg_move'
            ? _sim.s4Veg!
            : _sim.s4Flo!;
        int newX = ((pt.dx - _sim.dragStartX - gx) / u).round();
        int newY = ((pt.dy - _sim.dragStartY - gy) / u).round();
        target.x = max(0, min(10 - target.w, newX));
        target.y = max(0, min(8 - target.h, newY));
        if (_sim.s4Veg != null && _sim.s4Flo != null) {
          _sim.s4Overlap = _rectsOverlap(_sim.s4Veg!, _sim.s4Flo!);
        }
      } else {
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
      }
      return;
    }

    if (_sim.s4Resizing != null) {
      double u = 40, gx = -150, gy = -160;
      SimRect target = _sim.s4Resizing == 'veg' ? _sim.s4Veg! : _sim.s4Flo!;
      int newW = max(1, ((pt.dx - (gx + target.x * u)) / u).round());
      int newH = max(1, ((pt.dy - (gy + target.y * u)) / u).round());
      target.w = min(10 - target.x, newW);
      target.h = min(8 - target.y, newH);
      if (_sim.s4Veg != null && _sim.s4Flo != null) {
        _sim.s4Overlap = _rectsOverlap(_sim.s4Veg!, _sim.s4Flo!);
      }
      _checkS4();
      return;
    }

    if (_sim.s5IsErasing && !_sim.s5RectValid) {
      double u = 30, gx = -200, gy = -200;
      int cx = ((pt.dx - gx) / u).floor();
      int cy = ((pt.dy - gy) / u).floor();
      if (cx >= 0 && cx < 20 && cy >= 0 && cy < 12) {
        int existingIdx = _sim.s5Blocks.indexWhere(
          (b) => b.x == cx && b.y == cy,
        );
        if (existingIdx != -1) {
          _sim.s5Blocks.removeAt(existingIdx);
          _sim.s5Painted--;
          _checkS5Valid();
        }
      }
    } else if (_sim.s5IsPainting && _sim.s5Painted < 18 && !_sim.s5RectValid) {
      double u = 30, gx = -200, gy = -200;
      int cx = ((pt.dx - gx) / u).floor();
      int cy = ((pt.dy - gy) / u).floor();
      if (cx >= 0 && cx < 20 && cy >= 0 && cy < 12) {
        if (!_sim.s5Blocks.any((b) => b.x == cx && b.y == cy)) {
          _sim.s5Blocks.add(SimPoint(cx, cy));
          _sim.s5Painted++;
          _checkS5Valid();
        }
      }
    }
  }

  void _handlePointerUp(PointerUpEvent e) {
    final pt = _getCanvasPoint(e.position);

    if (_sim.s4Resizing != null) {
      _sim.s4Resizing = null;
      if (_sim.s4Overlap) {
        playError();
      } else {
        playClick();
      }
      _checkS4();
      return;
    }
    if (_sim.s5IsPainting || _sim.s5IsErasing) {
      _sim.s5IsPainting = false;
      _sim.s5IsErasing = false;
      playClick();
      return;
    }

    if (_sim.activeDragEntity != null) {
      if (_sim.activeDragEntity == 's1_tile') {
        double u = 40, gx = -100, gy = -120;
        if (_hitTestBox(gx, gy, 5 * u, 4 * u, pt)) {
          int tx = ((pt.dx - gx) / u).floor();
          int ty = ((pt.dy - gy) / u).floor();
          if (!_sim.s1Tiles.any((t) => t.x == tx && t.y == ty)) {
            playClick();
            _sim.s1Tiles.add(SimPoint(tx, ty));
            _checkS1();
          } else {
            playError();
          }
        }
      } else if (_sim.activeDragEntity == 's2_row') {
        if ((pt.dy - (-180)).abs() < 35 &&
            _hitTestBox(-210, -200, 420, 200, pt)) {
          playClick();
          _sim.s2RowFilled = true;
          _checkS2();
        }
      } else if (_sim.activeDragEntity == 's2_col') {
        if ((pt.dx - (-210)).abs() < 35 &&
            _hitTestBox(-250, -180, 200, 245, pt)) {
          playClick();
          _sim.s2ColFilled = true;
          _checkS2();
        }
      } else if (_sim.activeDragEntity == 's3_laser') {
        if (_sim.dragX == -10) {
          playClick();
          _sim.s3CutConfirmed = true;
          _advanceStep();
        }
      } else if (_sim.activeDragEntity == 's3_num1') {
        if (_hitTestBox(180, -60, 200, 200, pt)) {
          playClick();
          _sim.s3Add1 = true;
          _checkS3();
        }
      } else if (_sim.activeDragEntity == 's3_num2') {
        if (_hitTestBox(180, -60, 200, 200, pt)) {
          playClick();
          _sim.s3Add2 = true;
          _checkS3();
        }
      } else if (_sim.activeDragEntity == 's4_veg_new') {
        double u = 40, gx = -150, gy = -160;
        if (_hitTestBox(gx, gy, 10 * u, 8 * u, pt)) {
          int tx = ((pt.dx - gx) / u).floor();
          int ty = ((pt.dy - gy) / u).floor();
          _sim.s4Veg = SimRect(min(tx, 9), min(ty, 7), 1, 1);
          playClick();
          _checkS4();
        }
      } else if (_sim.activeDragEntity == 's4_flo_new') {
        double u = 40, gx = -150, gy = -160;
        if (_hitTestBox(gx, gy, 10 * u, 8 * u, pt)) {
          int tx = ((pt.dx - gx) / u).floor();
          int ty = ((pt.dy - gy) / u).floor();
          _sim.s4Flo = SimRect(min(tx, 9), min(ty, 7), 1, 1);
          if (_sim.s4Veg != null) {
            _sim.s4Overlap = _rectsOverlap(_sim.s4Veg!, _sim.s4Flo!);
          }
          if (_sim.s4Overlap) {
            playError();
          } else {
            playClick();
          }
          _checkS4();
        }
      } else if (_sim.activeDragEntity!.endsWith('_move')) {
        if (_sim.s4Overlap) {
          playError();
        } else {
          playClick();
        }
        _checkS4();
      }

      _sim.activeDragEntity = null;
      _sim.s3MachineHover = false;
    }
  }

  // --- Logic Checks ---

  void _checkS1() {
    if (_sim.s1Tiles.length == 1 && _step == 0) {
      _advanceStep();
    }
    if (_sim.s1Tiles.length == 20 && _step == 1) {
      _advanceStep();
    }
  }

  void _checkS2() {
    if (_sim.s2RowFilled && _step == 0) {
      _advanceStep();
    }
    if (_sim.s2ColFilled && _step == 1) {
      _advanceStep();
    }
  }

  void _checkS3() {
    if (_sim.s3Tile1 && _step == 1) {
      _advanceStep();
    }
    if (_sim.s3Tile2 && _step == 2) {
      _advanceStep();
    }
    if (_sim.s3Add1 && _sim.s3Add2 && _step == 3) {
      _advanceStep(); // Crucial fix: update step before triggering completion
      Future.delayed(const Duration(milliseconds: 1500), _checkScenarioSuccess);
    }
  }

  void _checkS4() {
    if (_sim.s4Veg != null &&
        _sim.s4Veg!.w * _sim.s4Veg!.h == 24 &&
        _step == 0) {
      _advanceStep();
    }
    if (_sim.s4Flo != null &&
        _sim.s4Flo!.w * _sim.s4Flo!.h == 15 &&
        _sim.s4Veg!.w * _sim.s4Veg!.h == 24 &&
        !_sim.s4Overlap &&
        _step == 1) {
      _sim.s4Completed = true;
      _advanceStep(); // Crucial fix: update step before triggering completion
      Future.delayed(const Duration(milliseconds: 1000), _checkScenarioSuccess);
    }
  }

  void _checkS5Valid() {
    if (_sim.s5Blocks.length != 18) {
      _sim.s5RectValid = false;
      return;
    }
    int minX = _sim.s5Blocks.map((b) => b.x).reduce(min);
    int maxX = _sim.s5Blocks.map((b) => b.x).reduce(max);
    int minY = _sim.s5Blocks.map((b) => b.y).reduce(min);
    int maxY = _sim.s5Blocks.map((b) => b.y).reduce(max);
    _sim.s5RectValid = ((maxX - minX + 1) * (maxY - minY + 1) == 18);
    if (_sim.s5RectValid && _step == 0) {
      _advanceStep();
    }
  }

  void _triggerAction(String action) async {
    if (action == 's1_check') {
      _advanceStep();
      Future.delayed(const Duration(milliseconds: 1500), _checkScenarioSuccess);
    } else if (action == 's2_calc') {
      _sim.animating = true;
      _sim.animProgress = 0;
      for (int i = 0; i < 50; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        setState(() {
          _sim.animProgress = i / 50;
        });
      }
      _sim.animating = false;
      _sim.s2Calculated = true;
      _advanceStep();
      Future.delayed(const Duration(milliseconds: 1500), _checkScenarioSuccess);
    } else if (action == 's3_tile1') {
      _sim.s3Tile1 = true;
      _checkS3();
    } else if (action == 's3_tile2') {
      _sim.s3Tile2 = true;
      _checkS3();
    } else if (action == 's5_measure') {
      _sim.animating = true;
      _sim.s5Measuring = true;
      _sim.animProgress = 0;
      for (int i = 0; i < 50; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        setState(() {
          _sim.animProgress = i / 50;
        });
      }
      _sim.animating = false;
      _sim.s5Measured = true;
      int minX = _sim.s5Blocks.map((b) => b.x).reduce(min);
      int maxX = _sim.s5Blocks.map((b) => b.x).reduce(max);
      int minY = _sim.s5Blocks.map((b) => b.y).reduce(min);
      int maxY = _sim.s5Blocks.map((b) => b.y).reduce(max);
      int w = maxX - minX + 1;
      int h = maxY - minY + 1;
      String name = w > h ? '${w}x$h' : '${h}x$w';
      if (!_sim.s5Logs.any((l) => l.name == name)) {
        setState(() {
          _sim.s5Logs.add(SimLog(name, 2 * (w + h)));
        });
      }
      if (_step == 1) _advanceStep();
      if (_sim.s5Logs.length >= 3) {
        _advanceStep();
        Future.delayed(
          const Duration(milliseconds: 1500),
          _checkScenarioSuccess,
        );
      }
    } else if (action == 's5_reset') {
      setState(() {
        _sim.s5Blocks.clear();
        _sim.s5Painted = 0;
        _sim.s5RectValid = false;
        _sim.s5Measured = false;
        _sim.s5Measuring = false;
      });
    }
  }

  // --- Layout Helpers ---

  String t(String key) => i18n[_lang]?[key] ?? i18n['en']?[key] ?? key;

  Map<String, dynamic> _getScenarioConfig(int sc) {
    int numSteps = sc == 1
        ? 3
        : sc == 2
        ? 3
        : sc == 3
        ? 4
        : sc == 4
        ? 2
        : 3;
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'hud': t('s${sc}_hud$i'),
        'task': t('s${sc}_step${i}_task'),
        'outcome': t('s${sc}_step${i}_out'),
      });
    }
    return {
      'title': t('s${sc}_title'),
      'objective': t('s${sc}_obj'),
      'steps': steps,
    };
  }

  @override
  Widget build(BuildContext context) {
    final conf = _getScenarioConfig(_scenario);
    final List steps = conf['steps'];
    final bool isFinished = _step >= steps.length;
    final String currentHud = isFinished ? "" : steps[_step]['hud'];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Canvas Layer
            AnimatedPositioned(
              duration: _isDraggingSidebar
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onScaleStart: (details) {
                  if (!_sim.isInteracting) {
                    // Disable pan start if interacting
                    _baseZoom = _zoom;
                  }
                },
                onScaleUpdate: (details) {
                  if (!_sim.isInteracting) {
                    // Disable panning while dragging/painting
                    setState(() {
                      _panX += details.focalPointDelta.dx;
                      _panY += details.focalPointDelta.dy;
                      _zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
                    });
                  }
                },
                child: Listener(
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUp,
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: ClipRect(
                      child: CustomPaint(
                        key: _canvasKey,
                        painter: LabPainter(
                          state: _sim,
                          scenario: _scenario,
                          step: _step,
                          panX: _panX,
                          panY: _panY,
                          zoom: _zoom,
                          t: t,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Sidebar Layer
            AnimatedPositioned(
              duration: _isDraggingSidebar
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  border: const Border(
                    right: BorderSide(color: Colors.white24, width: 2),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 20),
                  ],
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              64,
                              16,
                              16,
                            ), // Padding for menu button
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.square_foot,
                                      color: Color(0xFF6366F1),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        t('appTitle'),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Text(
                                    t('appSubtitle'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white12,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.language,
                                          size: 18,
                                        ),
                                        label: Text(
                                          _lang == 'en' ? 'EN / HI' : 'HI / EN',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: _toggleLanguage,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white12,
                                          foregroundColor: Colors.redAccent,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.refresh,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Reset',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: _resetLab,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Scrollable Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('selectScenario').toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: _scenario,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        items: List.generate(5, (index) {
                                          int s = index + 1;
                                          return DropdownMenuItem(
                                            value: s,
                                            child: Text(t('s${s}_title')),
                                          );
                                        }),
                                        onChanged: (val) {
                                          if (val != null) {
                                            playDropdown();
                                            _loadScenario(val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0F172A,
                                      ).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.flag,
                                              color: Colors.pinkAccent,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              t('learnLbl'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          conf['objective'],
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Steps
                                  for (int i = 0; i < steps.length; i++)
                                    _buildStepCard(i, steps[i]),
                                ],
                              ),
                            ),
                          ),
                          // Footer
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: const Color(0xFF0F172A),
                            alignment: Alignment.center,
                            child: const Text(
                              '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Sidebar Resizer Handle
            AnimatedPositioned(
              duration: _isDraggingSidebar
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth - 10 : -20,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) {
                  setState(() {
                    _isDraggingSidebar = true;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _sidebarWidth = max(
                      300.0,
                      min(
                        _sidebarWidth + details.delta.dx,
                        MediaQuery.of(context).size.width * 0.6,
                      ),
                    );
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDraggingSidebar = false;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    color: Colors.transparent, // Invisible wide handle
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top-Left Menu Button (Always visible)
            Positioned(
              left: 8,
              top: 8,
              child: SafeArea(
                child: FloatingActionButton(
                  heroTag: 'menuBtn',
                  mini: true,
                  backgroundColor: const Color(0xFF6366F1),
                  onPressed: _toggleSidebar,
                  child: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // HUD
            if (currentHud.isNotEmpty)
              AnimatedPositioned(
                duration: _isDraggingSidebar
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? _sidebarWidth : 0,
                right: 0,
                bottom: 40,
                child: Center(
                  child: IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(
                          top: BorderSide(color: Color(0xFF6366F1), width: 4),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF818CF8),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              currentHud,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      width: 400,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.emoji_events,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('finalDesc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: Icon(
                              _scenario < 5 ? Icons.arrow_forward : Icons.flag,
                              color: Colors.white,
                            ),
                            label: Text(
                              _scenario < 5
                                  ? t('nextScenario')
                                  : t('finishLab'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              playClick();
                              if (_scenario < 5) {
                                _loadScenario(_scenario + 1);
                              } else {
                                _resetLab();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Curtain Screen
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.square_foot,
                        size: 80,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t('shutterTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        icon: const Icon(
                          Icons.play_circle_fill,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: Text(
                          t('enterLab'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          curtainScreen();
                          setState(() {
                            _showCurtain = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(int index, Map<String, String> stepData) {
    bool isCompleted = index < _step;
    bool isActive = index == _step;

    Color bg = isActive
        ? const Color(0xFF6366F1).withOpacity(0.2)
        : isCompleted
        ? Colors.green.withOpacity(0.1)
        : Colors.white.withOpacity(0.05);
    Color border = isActive
        ? const Color(0xFF6366F1)
        : isCompleted
        ? Colors.green.withOpacity(0.5)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: isActive ? 2 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isCompleted
                ? Colors.green
                : isActive
                ? const Color(0xFF6366F1)
                : Colors.white24,
            child: isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP ${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stepData['task']!,
                  style: TextStyle(
                    color: isActive || isCompleted
                        ? Colors.white
                        : Colors.white54,
                    fontSize: 14,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      stepData['outcome']!,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Canvas Painter ---

class LabPainter extends CustomPainter {
  final SimState state;
  final int scenario;
  final int step;
  final double panX, panY, zoom;
  final Function(String) t;

  static const Color outlineColor = Color(0xFF0F172A);

  LabPainter({
    required this.state,
    required this.scenario,
    required this.step,
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _renderS1(canvas);
    } else if (scenario == 2) {
      _renderS2(canvas);
    } else if (scenario == 3) {
      _renderS3(canvas);
    } else if (scenario == 4) {
      _renderS4(canvas);
    } else if (scenario == 5) {
      _renderS5(canvas);
    }
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double lineW,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (stroke != Colors.transparent && lineW > 0) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineW,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    } else {
      double dashWidth = 8, dashSpace = 8, startX = x1, startY = y1;
      final double dx = x2 - x1, dy = y2 - y1;
      final double distance = sqrt(dx * dx + dy * dy);
      final double dirX = dx / distance, dirY = dy / distance;
      double drawn = 0;
      while (drawn < distance) {
        canvas.drawLine(
          Offset(startX, startY),
          Offset(startX + dirX * dashWidth, startY + dirY * dashWidth),
          paint,
        );
        startX += dirX * (dashWidth + dashSpace);
        startY += dirY * (dashWidth + dashSpace);
        drawn += dashWidth + dashSpace;
      }
    }
  }

  void _drawTextOutline(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color fill, [
    TextAlign align = TextAlign.center,
  ]) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: fill,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..textAlign = align;
    tp.layout();
    double dx = align == TextAlign.center ? x - tp.width / 2 : x;
    tp.paint(canvas, Offset(dx, y - tp.height / 2));
  }

  void _drawIcon(Canvas canvas, String type, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    final paintFill = Paint()..color = const Color(0xFF6366F1);
    final paintWhite = Paint()..color = Colors.white;
    if (type == 'tile') {
      canvas.drawRect(const Rect.fromLTWH(-10, -10, 20, 20), paintFill);
      canvas.drawRect(const Rect.fromLTWH(-7, -7, 14, 14), paintWhite);
    } else if (type == 'rowTiler') {
      canvas.drawRect(const Rect.fromLTWH(-11, -2, 4, 4), paintFill);
      canvas.drawRect(const Rect.fromLTWH(-6, -2, 4, 4), paintFill);
      canvas.drawRect(const Rect.fromLTWH(-1, -2, 4, 4), paintFill);
      canvas.drawRect(const Rect.fromLTWH(4, -2, 4, 4), paintFill);
    } else if (type == 'colCounter') {
      canvas.drawRect(const Rect.fromLTWH(-2, -11, 4, 4), paintFill);
      canvas.drawRect(const Rect.fromLTWH(-2, -6, 4, 4), paintFill);
      canvas.drawRect(const Rect.fromLTWH(-2, -1, 4, 4), paintFill);
      canvas.drawRect(const Rect.fromLTWH(-2, 4, 4, 4), paintFill);
    } else if (type == 'laser') {
      final path = Path()
        ..moveTo(-1, -10)
        ..lineTo(1, -10)
        ..lineTo(1, 10)
        ..lineTo(-1, 10)
        ..close();
      canvas.drawPath(path, Paint()..color = Colors.redAccent);
      canvas.drawCircle(Offset.zero, 3, Paint()..color = Colors.redAccent);
    }
    canvas.restore();
  }

  void _renderGrid(
    Canvas canvas,
    double gx,
    double gy,
    int cols,
    int rows,
    double u,
  ) {
    _drawRoundedRect(
      canvas,
      gx,
      gy,
      cols * u,
      rows * u,
      0,
      const Color(0xFF334155),
      outlineColor,
      3,
    );
    final gridPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1;
    for (int i = 1; i < cols; i++) {
      canvas.drawLine(
        Offset(gx + i * u, gy),
        Offset(gx + i * u, gy + rows * u),
        gridPaint,
      );
    }
    for (int i = 1; i < rows; i++) {
      canvas.drawLine(
        Offset(gx, gy + i * u),
        Offset(gx + cols * u, gy + i * u),
        gridPaint,
      );
    }
  }

  void _renderS1(Canvas canvas) {
    double u = 40, gx = -100, gy = -120, gh = 4 * u;
    _renderGrid(canvas, gx, gy, 5, 4, u);

    for (var tile in state.s1Tiles) {
      _drawRoundedRect(
        canvas,
        gx + tile.x * u,
        gy + tile.y * u,
        u,
        u,
        0,
        const Color(0xFF6366F1),
        outlineColor,
        2,
      );
      _drawRoundedRect(
        canvas,
        gx + tile.x * u + 4,
        gy + tile.y * u + 4,
        u - 8,
        u - 8,
        0,
        Colors.white24,
        Colors.transparent,
        0,
      );
    }

    _drawRoundedRect(
      canvas,
      gx,
      gy + gh + 40,
      80,
      80,
      8,
      const Color(0xFF1E293B),
      Colors.white38,
      2,
    );
    _drawIcon(canvas, 'tile', gx + 40, gy + gh + 70);
    _drawTextOutline(
      canvas,
      t('lbl_drag'),
      gx + 40,
      gy + gh + 100,
      12,
      Colors.white70,
    );

    _drawRoundedRect(
      canvas,
      gx + 100,
      gy + gh + 50,
      100,
      60,
      8,
      const Color(0xFF1E293B),
      Colors.white38,
      2,
    );
    _drawTextOutline(
      canvas,
      t('lbl_s1_tilesused'),
      gx + 150,
      gy + gh + 70,
      12,
      Colors.white70,
    );
    _drawTextOutline(
      canvas,
      '${state.s1Tiles.length}',
      gx + 150,
      gy + gh + 90,
      24,
      const Color(0xFF6366F1),
    );

    if (state.activeDragEntity == 's1_tile') {
      _drawRoundedRect(
        canvas,
        state.dragX - u / 2,
        state.dragY - u / 2,
        u,
        u,
        0,
        const Color(0xFF6366F1).withOpacity(0.8),
        outlineColor,
        2,
      );
    }

    if (step == 2) {
      _drawRoundedRect(
        canvas,
        gx + 220,
        gy + gh + 50,
        120,
        60,
        8,
        Colors.green,
        outlineColor,
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_check'),
        gx + 280,
        gy + gh + 80,
        18,
        Colors.white,
      );
    }

    if (step == 3) {
      _drawRoundedRect(
        canvas,
        gx - 60,
        gy + gh + 140,
        320,
        80,
        8,
        const Color(0xFF064E3B),
        Colors.greenAccent,
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s1_msg'),
        gx + 100,
        gy + gh + 180,
        14,
        Colors.greenAccent,
      );
    }
  }

  void _renderS2(Canvas canvas) {
    double u = 35, gx = -210, gy = -180, gw = 12 * u, gh = 7 * u;
    _renderGrid(canvas, gx, gy, 12, 7, u);

    if (step == 0 && state.activeDragEntity != 's2_row') {
      _drawRoundedRect(
        canvas,
        gx - 80,
        gy,
        60,
        60,
        8,
        const Color(0xFF1E293B),
        Colors.white38,
        2,
      );
      _drawIcon(canvas, 'rowTiler', gx - 50, gy + 30);
    }
    if (step == 1 && state.activeDragEntity != 's2_col') {
      _drawRoundedRect(
        canvas,
        gx - 80,
        gy + 80,
        60,
        60,
        8,
        const Color(0xFF1E293B),
        Colors.white38,
        2,
      );
      _drawIcon(canvas, 'colCounter', gx - 50, gy + 110);
    }

    int rowsToRender = state.s2Calculated ? 7 : (state.s2RowFilled ? 1 : 0);
    if (state.animating && state.s2Calculated) {
      rowsToRender = 1 + (state.animProgress * 6).floor();
    }

    for (int r = 0; r < rowsToRender; r++) {
      for (int c = 0; c < 12; c++) {
        _drawRoundedRect(
          canvas,
          gx + c * u,
          gy + r * u,
          u,
          u,
          0,
          Colors.blueAccent,
          outlineColor,
          1,
        );
      }
    }

    if (state.s2ColFilled && !state.s2Calculated) {
      _drawRoundedRect(
        canvas,
        gx,
        gy,
        u,
        gh,
        0,
        Colors.yellow.withOpacity(0.5),
        Colors.yellow,
        3,
      );
    }

    if (state.s2RowFilled) {
      _drawTextOutline(
        canvas,
        t('lbl_s2_lenmsg'),
        gx + gw / 2,
        gy - 25,
        14,
        Colors.white,
      );
    }
    if (state.s2ColFilled) {
      _drawTextOutline(
        canvas,
        t('lbl_s2_widmsg'),
        gx - 50,
        gy + gh / 2,
        14,
        Colors.white,
      );
    }

    if (step == 2 && !state.s2Calculated) {
      _drawRoundedRect(
        canvas,
        gx + gw / 2 - 70,
        gy + gh + 40,
        140,
        50,
        8,
        const Color(0xFF8B5CF6),
        outlineColor,
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s2_calcBtn'),
        gx + gw / 2,
        gy + gh + 65,
        16,
        Colors.white,
      );
    }

    if (step == 3 && !state.animating) {
      _drawRoundedRect(
        canvas,
        gx +
            gw / 2 -
            200, // Fixed: Widened background to support multiline text
        gy + gh + 30,
        400, // Fixed: Widened background
        80,
        8,
        Colors.yellow[700]!,
        outlineColor,
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s2_formula'),
        gx + gw / 2,
        gy + gh + 70,
        13, // Fixed: Font size slightly lowered to ensure no wrap clipping
        Colors.black87,
      );
    }

    if (state.activeDragEntity == 's2_row') {
      _drawRoundedRect(
        canvas,
        state.dragX - 2 * u,
        state.dragY - u / 2,
        4 * u,
        u,
        0,
        Colors.blueAccent.withOpacity(0.8),
        outlineColor,
        2,
      );
    }
    if (state.activeDragEntity == 's2_col') {
      _drawRoundedRect(
        canvas,
        state.dragX - u / 2,
        state.dragY - 2 * u,
        u,
        4 * u,
        0,
        Colors.yellow.withOpacity(0.8),
        outlineColor,
        2,
      );
    }
  }

  void _renderS3(Canvas canvas) {
    double u = 35, gx = -150, gy = -150;

    // L-Shape base
    final path = Path()
      ..moveTo(gx, gy)
      ..lineTo(gx + 4 * u, gy)
      ..lineTo(gx + 4 * u, gy + 4 * u)
      ..lineTo(gx + 10 * u, gy + 4 * u)
      ..lineTo(gx + 10 * u, gy + 8 * u)
      ..lineTo(gx, gy + 8 * u)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final gridP = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1;
    for (int x = 1; x < 10; x++) {
      if (x < 4) {
        canvas.drawLine(
          Offset(gx + x * u, gy),
          Offset(gx + x * u, gy + 8 * u),
          gridP,
        );
      } else {
        canvas.drawLine(
          Offset(gx + x * u, gy + 4 * u),
          Offset(gx + x * u, gy + 8 * u),
          gridP,
        );
      }
    }
    for (int y = 1; y < 8; y++) {
      if (y < 4) {
        canvas.drawLine(
          Offset(gx, gy + y * u),
          Offset(gx + 4 * u, gy + y * u),
          gridP,
        );
      } else {
        canvas.drawLine(
          Offset(gx, gy + y * u),
          Offset(gx + 10 * u, gy + y * u),
          gridP,
        );
      }
    }

    if (state.s3CutConfirmed) {
      _drawLine(
        canvas,
        gx + 4 * u,
        gy,
        gx + 4 * u,
        gy + 8 * u,
        Colors.redAccent,
        4,
        dashed: true,
      );
    }

    if (state.s3Tile1) {
      _drawRoundedRect(
        canvas,
        gx,
        gy,
        4 * u,
        8 * u,
        0,
        const Color(0xFF6366F1).withOpacity(0.5),
        outlineColor,
        3,
      );
    }
    if (state.s3Tile2) {
      _drawRoundedRect(
        canvas,
        gx + 4 * u,
        gy + 4 * u,
        6 * u,
        4 * u,
        0,
        Colors.green.withOpacity(0.5),
        outlineColor,
        3,
      );
    }

    if (state.s3CutConfirmed && !state.s3Tile1) {
      _drawRoundedRect(
        canvas,
        gx + 2 * u - 40,
        gy + 2 * u - 15,
        80,
        30,
        4,
        Colors.white,
        outlineColor,
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s3_autotile'),
        gx + 2 * u,
        gy + 2 * u,
        12,
        outlineColor,
      );
    }
    if (state.s3Tile1 && !state.s3Add1 && state.activeDragEntity != 's3_num1') {
      _drawRoundedRect(
        canvas,
        gx + 2 * u - 50,
        gy + 2 * u - 15,
        100,
        30,
        4,
        Colors.yellow[300]!,
        outlineColor,
        2,
      );
      _drawTextOutline(canvas, "32", gx + 2 * u, gy + 2 * u, 18, outlineColor);
    }
    if (step >= 2 && state.s3CutConfirmed && !state.s3Tile2) {
      _drawRoundedRect(
        canvas,
        gx + 7 * u - 40,
        gy + 6 * u - 15,
        80,
        30,
        4,
        Colors.white,
        outlineColor,
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s3_autotile'),
        gx + 7 * u,
        gy + 6 * u,
        12,
        outlineColor,
      );
    }
    if (state.s3Tile2 && !state.s3Add2 && state.activeDragEntity != 's3_num2') {
      _drawRoundedRect(
        canvas,
        gx + 7 * u - 50,
        gy + 6 * u - 15,
        100,
        30,
        4,
        Colors.yellow[300]!,
        outlineColor,
        2,
      );
      _drawTextOutline(canvas, "24", gx + 7 * u, gy + 6 * u, 18, outlineColor);
    }

    if (!state.s3CutConfirmed) {
      double lx = state.activeDragEntity == 's3_laser' ? state.dragX : gx - 60;
      _drawLine(
        canvas,
        lx,
        gy - 40,
        lx,
        gy + 8 * u + 40,
        Colors.redAccent,
        2,
        dashed: true,
      );
      _drawRoundedRect(
        canvas,
        lx - 20,
        gy - 60,
        40,
        40,
        4,
        Colors.white,
        outlineColor,
        2,
      );
      _drawIcon(canvas, 'laser', lx, gy - 40);
    }

    if (state.activeDragEntity == 's3_num1') {
      _drawRoundedRect(
        canvas,
        state.dragX - 25,
        state.dragY - 15,
        50,
        30,
        4,
        Colors.yellow[300]!,
        outlineColor,
        2,
      );
      _drawTextOutline(
        canvas,
        "32",
        state.dragX,
        state.dragY,
        18,
        outlineColor,
      );
    }
    if (state.activeDragEntity == 's3_num2') {
      _drawRoundedRect(
        canvas,
        state.dragX - 25,
        state.dragY - 15,
        50,
        30,
        4,
        Colors.yellow[300]!,
        outlineColor,
        2,
      );
      _drawTextOutline(
        canvas,
        "24",
        state.dragX,
        state.dragY,
        18,
        outlineColor,
      );
    }

    if (step == 3) {
      double mx = 200, my = -50;
      _drawRoundedRect(
        canvas,
        mx,
        my,
        160,
        180,
        10,
        const Color(0xFF94A3B8),
        outlineColor,
        4,
      );
      _drawRoundedRect(
        canvas,
        mx + 10,
        my + 10,
        140,
        30,
        4,
        const Color(0xFF475569),
        Colors.transparent,
        0,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s3_mach'),
        mx + 80,
        my + 25,
        12,
        Colors.white,
      );

      Color slotColor = state.s3MachineHover
          ? Colors.green[200]!
          : Colors.white;
      _drawRoundedRect(
        canvas,
        mx + 20,
        my + 60,
        50,
        40,
        4,
        state.s3Add1 ? Colors.yellow[300]! : slotColor,
        outlineColor,
        2,
      );
      if (state.s3Add1) {
        _drawTextOutline(canvas, "32", mx + 45, my + 80, 18, outlineColor);
      }

      _drawTextOutline(canvas, "+", mx + 80, my + 80, 24, outlineColor);

      _drawRoundedRect(
        canvas,
        mx + 90,
        my + 60,
        50,
        40,
        4,
        state.s3Add2 ? Colors.yellow[300]! : slotColor,
        outlineColor,
        2,
      );
      if (state.s3Add2) {
        _drawTextOutline(canvas, "24", mx + 115, my + 80, 18, outlineColor);
      }

      if (state.s3Add1 && state.s3Add2) {
        _drawRoundedRect(
          canvas,
          mx + 20,
          my + 120,
          120,
          40,
          4,
          Colors.green,
          outlineColor,
          2,
        );
        _drawTextOutline(
          canvas,
          t('lbl_s3_total').split(':').last.trim(),
          mx + 80,
          my + 140,
          14,
          Colors.white,
        );
      }
    }
  }

  void _renderS4(Canvas canvas) {
    double u = 40, gh = 8 * u, gx = -150, gy = -160;
    _renderGrid(canvas, gx, gy, 10, 8, u);

    if (state.s4Veg == null) {
      _drawRoundedRect(
        canvas,
        gx - 120,
        gy,
        100,
        40,
        8,
        Colors.green,
        outlineColor,
        2,
      );
      _drawTextOutline(
        canvas,
        "+ ${t('lbl_s4_veg')}",
        gx - 70,
        gy + 20,
        12,
        Colors.white,
      );
    }
    if (state.s4Flo == null && step >= 1) {
      _drawRoundedRect(
        canvas,
        gx - 120,
        gy + 60,
        100,
        40,
        8,
        Colors.pink,
        outlineColor,
        2,
      );
      _drawTextOutline(
        canvas,
        "+ ${t('lbl_s4_flo')}",
        gx - 70,
        gy + 80,
        12,
        Colors.white,
      );
    }

    void renderRect(SimRect rect, Color color, String label, bool isErr) {
      double rx = gx + rect.x * u,
          ry = gy + rect.y * u,
          rw = rect.w * u,
          rh = rect.h * u;
      _drawRoundedRect(
        canvas,
        rx,
        ry,
        rw,
        rh,
        0,
        isErr ? Colors.red.withOpacity(0.5) : color,
        isErr ? Colors.redAccent : outlineColor,
        3,
      );
      _drawTextOutline(
        canvas,
        "${rect.w}x${rect.h}=${rect.w * rect.h} ${t('lbl_s4_sqm')}",
        rx + rw / 2,
        ry + rh / 2,
        14,
        Colors.white,
      );
      _drawRoundedRect(
        canvas,
        rx + rw - 8,
        ry + rh - 8,
        16,
        16,
        4,
        Colors.white,
        outlineColor,
        2,
      );
    }

    if (state.s4Veg != null) {
      renderRect(
        state.s4Veg!,
        Colors.green.withOpacity(0.8),
        t('lbl_s4_veg'),
        false,
      );
    }
    if (state.s4Flo != null) {
      renderRect(
        state.s4Flo!,
        Colors.pink.withOpacity(0.8),
        t('lbl_s4_flo'),
        state.s4Overlap,
      );
    }

    if (state.s4Overlap) {
      _drawRoundedRect(
        canvas,
        0,
        gy + gh + 20,
        200,
        40,
        8,
        const Color(0xFF450a0a),
        Colors.redAccent,
        2,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s4_err'),
        100,
        gy + gh + 40,
        14,
        Colors.redAccent,
      );
    }

    if (state.activeDragEntity == 's4_veg_new') {
      _drawRoundedRect(
        canvas,
        state.dragX - u / 2,
        state.dragY - u / 2,
        u,
        u,
        0,
        Colors.green.withOpacity(0.5),
        outlineColor,
        2,
      );
    }
    if (state.activeDragEntity == 's4_flo_new') {
      _drawRoundedRect(
        canvas,
        state.dragX - u / 2,
        state.dragY - u / 2,
        u,
        u,
        0,
        Colors.pink.withOpacity(0.5),
        outlineColor,
        2,
      );
    }
  }

  void _renderS5(Canvas canvas) {
    double u = 30, gw = 20 * u, gh = 12 * u, gx = -200, gy = -200;
    _renderGrid(canvas, gx, gy, 20, 12, u);

    _drawRoundedRect(
      canvas,
      gx - 140,
      gy,
      120,
      80,
      8,
      const Color(0xFF1E293B),
      Colors.white38,
      3,
    );
    _drawTextOutline(
      canvas,
      t('lbl_s5_pal'),
      gx - 80,
      gy + 25,
      12,
      Colors.white70,
    );
    _drawTextOutline(
      canvas,
      "${18 - state.s5Painted}/18",
      gx - 80,
      gy + 55,
      24,
      const Color(0xFF6366F1),
    );

    for (var b in state.s5Blocks) {
      _drawRoundedRect(
        canvas,
        gx + b.x * u,
        gy + b.y * u,
        u,
        u,
        0,
        const Color(0xFF6366F1),
        outlineColor,
        2,
      );
    }

    if (state.s5RectValid) {
      int minX = state.s5Blocks.map((b) => b.x).reduce(min);
      int maxX = state.s5Blocks.map((b) => b.x).reduce(max);
      int minY = state.s5Blocks.map((b) => b.y).reduce(min);
      int maxY = state.s5Blocks.map((b) => b.y).reduce(max);
      _drawRoundedRect(
        canvas,
        gx + minX * u,
        gy + minY * u,
        (maxX - minX + 1) * u,
        (maxY - minY + 1) * u,
        0,
        Colors.transparent,
        Colors.green,
        4,
      );
    }

    if (state.animating && state.s5Measuring && state.s5RectValid) {
      int minX = state.s5Blocks.map((b) => b.x).reduce(min);
      int maxX = state.s5Blocks.map((b) => b.x).reduce(max);
      int minY = state.s5Blocks.map((b) => b.y).reduce(min);
      int maxY = state.s5Blocks.map((b) => b.y).reduce(max);
      double rw = (maxX - minX + 1) * u,
          rh = (maxY - minY + 1) * u,
          rx = gx + minX * u,
          ry = gy + minY * u;
      double totalLen = 2 * (rw + rh);
      double drawLen = totalLen * state.animProgress;

      final p = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(rx, ry);
      if (drawLen <= rw) {
        path.lineTo(rx + drawLen, ry);
      } else if (drawLen <= rw + rh) {
        path.lineTo(rx + rw, ry);
        path.lineTo(rx + rw, ry + (drawLen - rw));
      } else if (drawLen <= 2 * rw + rh) {
        path.lineTo(rx + rw, ry);
        path.lineTo(rx + rw, ry + rh);
        path.lineTo(rx + rw - (drawLen - rw - rh), ry + rh);
      } else {
        path.lineTo(rx + rw, ry);
        path.lineTo(rx + rw, ry + rh);
        path.lineTo(rx, ry + rh);
        path.lineTo(rx, ry + rh - (drawLen - 2 * rw - rh));
      }
      canvas.drawPath(path, p);
    }

    if (step >= 1 && state.s5RectValid && !state.s5Measured) {
      _drawRoundedRect(
        canvas,
        gx - 140,
        gy + 100,
        120,
        60,
        8,
        Colors.green,
        outlineColor,
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s5_meas'),
        gx - 80,
        gy + 130,
        14,
        Colors.white,
      );
    }
    if (step >= 2) {
      _drawRoundedRect(
        canvas,
        gx - 140,
        gy + 180,
        120,
        40,
        8,
        Colors.redAccent,
        outlineColor,
        3,
      );
      _drawTextOutline(canvas, "RESET", gx - 80, gy + 200, 16, Colors.white);
    }

    if (state.s5Logs.isNotEmpty) {
      double tx = gx + gw + 40, ty = gy;
      _drawRoundedRect(
        canvas,
        tx,
        ty,
        200,
        200,
        8,
        const Color(0xFF1E293B),
        Colors.white38,
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s5_t_rect'),
        tx + 50,
        ty + 20,
        12,
        Colors.white,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s5_t_per'),
        tx + 150,
        ty + 20,
        12,
        Colors.white,
      );
      _drawLine(canvas, tx, ty + 35, tx + 200, ty + 35, outlineColor, 2);

      for (int i = 0; i < state.s5Logs.length; i++) {
        double y = ty + 60 + i * 40;
        if (step == 3 && (state.s5Logs[i].p == 38 || state.s5Logs[i].p == 18)) {
          _drawRoundedRect(
            canvas,
            tx + 5,
            y - 15,
            190,
            30,
            4,
            state.s5Logs[i].p == 38
                ? Colors.redAccent.withOpacity(0.5)
                : Colors.green.withOpacity(0.5),
            Colors.transparent,
            0,
          );
        }
        _drawTextOutline(
          canvas,
          state.s5Logs[i].name,
          tx + 50,
          y,
          14,
          Colors.white,
        );
        _drawTextOutline(
          canvas,
          "${state.s5Logs[i].p}",
          tx + 150,
          y,
          16,
          Colors.white,
        );
      }
    }

    if (step == 3) {
      _drawRoundedRect(
        canvas,
        gx,
        gy + gh + 20,
        gw,
        80,
        8,
        const Color(0xFF064E3B),
        Colors.greenAccent,
        3,
      );
      _drawTextOutline(
        canvas,
        t('lbl_s5_msg'),
        gx + gw / 2,
        gy + gh + 60,
        14,
        Colors.greenAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}

// --- Locales ---

const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': "Understanding Area and its Measurement",
    'appTitle': "Understanding Area",
    'appSubtitle': "Class 6 • GEOMETRY",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Observation:",
    'summaryTitle': "Goal Reached!",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc': "You have successfully explored the concept of Area!",

    'lbl_drag': "DRAG",
    'lbl_check': "CHECK",
    'lbl_s1_tilesused': "Tiles Used: ",
    'lbl_s1_msg':
        "You used 20 tiles to cover the floor.\nThe AREA of this floor is 20 square units!",

    'lbl_s2_lenmsg': "1 row = 12 tiles.\nThis is the LENGTH.",
    'lbl_s2_widmsg': "7 rows are needed.\nThis is the WIDTH.",
    'lbl_s2_formula':
        "Instead of counting 84 tiles one by one, we multiply LENGTH by WIDTH.\nThe AREA is 12 x 7 = 84 square units.",
    'lbl_s2_calcBtn': "Calculate",

    'lbl_s3_autotile': "Auto-Tile",
    'lbl_s3_mach': "Addition Machine",
    'lbl_s3_total': "Total Area: 56 sq units",

    'lbl_s4_veg': "Veggie Plot",
    'lbl_s4_flo': "Flower Bed",
    'lbl_s4_sqm': "sq m",
    'lbl_s4_err': "Plots cannot overlap!",

    'lbl_s5_pal': "Blocks Remaining",
    'lbl_s5_meas': "Measure\nPerimeter",
    'lbl_s5_t_rect': "Rectangle",
    'lbl_s5_t_per': "Perimeter",
    'lbl_s5_msg':
        "All shapes have the SAME AREA (18 sq units), but DIFFERENT PERIMETERS.\nThe long, skinny shape has the largest perimeter.",

    's1_title': "1. The Tiling Challenge",
    's1_obj':
        "To understand that area is the total number of unit squares needed to cover a surface.",
    's1_step1_task':
        "DRAG the blue square tiles from the tile palette and DROP them onto the floor.",
    's1_step1_out': "A tile is placed on the floor grid.",
    's1_step2_task':
        "Continue to DRAG and DROP tiles until the entire floor is covered.",
    's1_step2_out': "The 5x4 floor is completely covered with 20 tiles.",
    's1_step3_task': "CLICK the 'Check' button.",
    's1_step3_out':
        "The total area is confirmed as 20 square units. Area is the 'space inside'.",
    's1_hud1': "Drag a tile to the floor.",
    's1_hud2': "Fill the entire floor.",
    's1_hud3': "Click Check.",

    's2_title': "2. The Formula Shortcut",
    's2_obj':
        "To discover that multiplying length by width is a shortcut to find area.",
    's2_step1_task':
        "DRAG the 'Row Tiler' tool and DROP it on the top row of the floor.",
    's2_step1_out': "1 row = 12 tiles (Length).",
    's2_step2_task':
        "DRAG the 'Column Counter' tool and DROP it on the first column.",
    's2_step2_out': "7 rows are needed (Width).",
    's2_step3_task': "CLICK the 'Calculate' button.",
    's2_step3_out': "Area = Length x Width = 12 x 7 = 84 sq units.",
    's2_hud1': "Drag the Row Tiler to the top row.",
    's2_hud2': "Drag the Column Counter to the left column.",
    's2_hud3': "Click Calculate.",

    's3_title': "3. The Composite Shape Puzzle",
    's3_obj':
        "To find the area of complex shapes by splitting them into simple rectangles.",
    's3_step1_task':
        "DRAG the vertical 'Laser Cutter' to split the shape into two rectangles. CLICK to cut.",
    's3_step1_out': "The shape is divided into two distinct rectangles.",
    's3_step2_task': "CLICK 'Auto-Tile' on the first rectangle.",
    's3_step2_out': "First area found.",
    's3_step3_task': "CLICK 'Auto-Tile' on the second rectangle.",
    's3_step3_out': "Second area found.",
    's3_step4_task': "DRAG both area numbers into the 'Addition Machine'.",
    's3_step4_out': "Total Area = Sum of individual areas.",
    's3_hud1': "Drag Laser Cutter to x=4 and click.",
    's3_hud2': "Click Auto-Tile on Left part.",
    's3_hud3': "Click Auto-Tile on Right part.",
    's3_hud4': "Drag numbers to Addition Machine.",

    's4_title': "4. The Garden Planner",
    's4_obj': "To apply the concept of area to design a layout.",
    's4_step1_task':
        "DRAG the 'Veggie Plot' tool. RESIZE it using corners to exactly 24 sq m.",
    's4_step1_out': "Veggie plot of 24 sq m created.",
    's4_step2_task':
        "DRAG the 'Flower Bed' tool. RESIZE to exactly 15 sq m without overlapping.",
    's4_step2_out': "Both plots successfully placed with correct areas.",
    's4_hud1': "Drag Veggie Plot and resize to 24 sq m.",
    's4_hud2': "Drag Flower Bed, resize to 15 sq m, don't overlap.",

    's5_title': "5. Area & Perimeter Mystery",
    's5_obj':
        "To discover that figures with the same area can have different perimeters.",
    's5_step1_task':
        "PAINT blocks on grid to form a solid rectangle using ALL 18 blocks.",
    's5_step1_out': "A rectangle of area 18 is built.",
    's5_step2_task': "CLICK the 'Measure Perimeter' tool.",
    's5_step2_out': "Perimeter is calculated and logged.",
    's5_step3_task':
        "CLICK 'Reset' on grid and build the OTHER rectangles (3x6, 2x9, 1x18) and measure.",
    's5_step3_out': "Same area can have different perimeters!",
    's5_hud1': "Drag to paint 18 blocks into a rectangle.",
    's5_hud2': "Click Measure Perimeter.",
    's5_hud3':
        "Reset, build different rectangles (3x6, 2x9, 1x18) and measure.",
  },
  'hi': {
    'shutterTitle': "क्षेत्रफल और उसके मापन को समझना",
    'appTitle': "क्षेत्रफल को समझना",
    'appSubtitle': "कक्षा 6 • ज्यामिति",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "अवलोकन:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc': "आपने क्षेत्रफल की अवधारणा का सफलतापूर्वक पता लगाया है!",

    'lbl_drag': "खींचें",
    'lbl_check': "चेक करें",
    'lbl_s1_tilesused': "प्रयुक्त टाइलें: ",
    'lbl_s1_msg':
        "आपने फर्श को ढकने के लिए 20 टाइलों का उपयोग किया।\nइस फर्श का क्षेत्रफल 20 वर्ग इकाई है!",
    'lbl_s2_lenmsg': "1 पंक्ति = 12 टाइलें।\nयह लंबाई है।",
    'lbl_s2_widmsg': "7 पंक्तियों की आवश्यकता है।\nयह चौड़ाई है।",
    'lbl_s2_formula':
        "84 टाइलों को एक-एक करके गिनने के बजाय, हम लंबाई को चौड़ाई से गुणा करते हैं।\nक्षेत्रफल 12 x 7 = 84 वर्ग इकाई है।",
    'lbl_s2_calcBtn': "गणना करें",
    'lbl_s3_autotile': "ऑटो-टाइल",
    'lbl_s3_mach': "जोड़ मशीन",
    'lbl_s3_total': "कुल क्षेत्रफल: 56 वर्ग इकाई",
    'lbl_s4_veg': "सब्जी का खेत",
    'lbl_s4_flo': "फूलो की क्यारी",
    'lbl_s4_sqm': "वर्ग मीटर",
    'lbl_s4_err': "प्लॉट ओवरलैप नहीं हो सकते!",
    'lbl_s5_pal': "शेष ब्लॉक",
    'lbl_s5_meas': "परिमाप\nमापें",
    'lbl_s5_t_rect': "आयत",
    'lbl_s5_t_per': "परिमाप",
    'lbl_s5_msg':
        "सभी आकृतियों का क्षेत्रफल समान (18 वर्ग इकाई) है, लेकिन परिमाप अलग-अलग है।\nलंबी, पतली आकृति का परिमाप सबसे बड़ा होता है।",

    's1_title': "1. टाइलिंग चुनौती",
    's1_obj':
        "यह समझना कि क्षेत्रफल किसी सतह को ढकने के लिए आवश्यक इकाई वर्गों की कुल संख्या है।",
    's1_step1_task': "नीले चौकोर टाइल्स को पैलेट से फर्श पर खींचें।",
    's1_step1_out': "फर्श ग्रिड पर एक टाइल रखी गई है।",
    's1_step2_task': "पूरे फर्श के ढक जाने तक टाइल्स खींचना जारी रखें।",
    's1_step2_out': "5x4 फर्श 20 टाइलों से पूरी तरह ढका हुआ है।",
    's1_step3_task': "'चेक करें' बटन पर क्लिक करें।",
    's1_step3_out':
        "कुल क्षेत्रफल 20 वर्ग इकाई है। क्षेत्रफल 'अंदर की जगह' है।",
    's1_hud1': "एक टाइल को फर्श पर खींचें।",
    's1_hud2': "पूरे फर्श को भरें।",
    's1_hud3': "चेक पर क्लिक करें।",

    's2_title': "2. फॉर्मूला शॉर्टकट",
    's2_obj':
        "यह खोजना कि लंबाई और चौड़ाई को गुणा करना क्षेत्रफल ज्ञात करने का शॉर्टकट है।",
    's2_step1_task': "'रो टाइलर' टूल को फर्श की सबसे ऊपरी पंक्ति पर खींचें।",
    's2_step1_out': "1 पंक्ति = 12 टाइलें (लंबाई)।",
    's2_step2_task': "'कॉलम काउंटर' टूल को पहले कॉलम पर खींचें।",
    's2_step2_out': "7 पंक्तियों की आवश्यकता है (चौड़ाई)।",
    's2_step3_task': "'गणना करें' बटन पर क्लिक करें।",
    's2_step3_out': "क्षेत्रफल = लंबाई x चौड़ाई = 12 x 7 = 84 वर्ग इकाई।",
    's2_hud1': "रो टाइलर को शीर्ष पंक्ति पर खींचें।",
    's2_hud2': "कॉलम काउंटर को बाएँ कॉलम पर खींचें।",
    's2_hud3': "गणना पर क्लिक करें।",

    's3_title': "3. मिश्रित आकार पहेली",
    's3_obj':
        "जटिल आकृतियों को सरल आयतों में विभाजित करके उनका क्षेत्रफल ज्ञात करना।",
    's3_step1_task':
        "आकार को दो आयतों में विभाजित करने के लिए ऊर्ध्वाधर 'लेजर कटर' खींचें। काटने के लिए क्लिक करें।",
    's3_step1_out': "आकार दो आयतों में विभाजित हो गया है।",
    's3_step2_task': "पहले आयत पर 'ऑटो-टाइल' क्लिक करें।",
    's3_step2_out': "पहला क्षेत्रफल मिल गया।",
    's3_step3_task': "दूसरे आयत पर 'ऑटो-टाइल' क्लिक करें।",
    's3_step3_out': "दूसरा क्षेत्रफल मिल गया।",
    's3_step4_task': "दोनों क्षेत्रफल संख्याओं को 'जोड़ मशीन' में खींचें।",
    's3_step4_out': "कुल क्षेत्रफल = व्यक्तिगत क्षेत्रफलों का योग।",
    's3_hud1': "लेजर कटर को x=4 पर खींचें और क्लिक करें।",
    's3_hud2': "बाएँ भाग पर ऑटो-टाइल क्लिक करें।",
    's3_hud3': "दाएँ भाग पर ऑटो-टाइल क्लिक करें।",
    's3_hud4': "संख्याओं को जोड़ मशीन में खींचें।",

    's4_title': "4. गार्डन प्लानर",
    's4_obj': "लेआउट डिजाइन करने के लिए क्षेत्रफल की अवधारणा लागू करना।",
    's4_step1_task':
        "'सब्जी का खेत' टूल खींचें। इसे कोनों से 24 वर्ग मीटर तक आकार दें।",
    's4_step1_out': "24 वर्ग मीटर का सब्जी का खेत बन गया।",
    's4_step2_task':
        "'फूलो की क्यारी' टूल खींचें। बिना ओवरलैप किए 15 वर्ग मीटर तक आकार दें।",
    's4_step2_out': "दोनों प्लॉट सही क्षेत्रफल के साथ रखे गए।",
    's4_hud1': "सब्जी का खेत खींचें और 24 वर्ग मीटर करें।",
    's4_hud2': "फूलो की क्यारी खींचें, 15 वर्ग मीटर करें, ओवरलैप न करें।",

    's5_title': "5. क्षेत्रफल और परिमाप रहस्य",
    's5_obj':
        "यह खोजना कि समान क्षेत्रफल वाली आकृतियों का परिमाप अलग-अलग हो सकता है।",
    's5_step1_task':
        "सभी 18 ब्लॉकों का उपयोग करके एक ठोस आयत बनाने के लिए ग्रिड पर पेंट करें।",
    's5_step1_out': "18 क्षेत्रफल का एक आयत बनाया गया है।",
    's5_step2_task': "'परिमाप मापें' टूल पर क्लिक करें।",
    's5_step2_out': "परिमाप की गणना की गई।",
    's5_step3_task':
        "ग्रिड पर 'रीसेट' क्लिक करें और अन्य आयत (3x6, 2x9, 1x18) बनाएं और मापें।",
    's5_step3_out': "समान क्षेत्रफल में अलग-अलग परिमाप हो सकते हैं!",
    's5_hud1': "18 ब्लॉकों को आयत में पेंट करने के लिए खींचें।",
    's5_hud2': "परिमाप मापें पर क्लिक करें।",
    's5_hud3': "रीसेट करें, अलग आयत बनाएं और मापें।",
  },
};
