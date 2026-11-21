// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Pictograph Power',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'sans-serif',
      ),
      home: const Cl6M_Ch4_A2_PictographPowerBuildingDataStorieswithPictures(),
    ),
  );
}

class Cl6M_Ch4_A2_PictographPowerBuildingDataStorieswithPictures
    extends StatefulWidget {
  const Cl6M_Ch4_A2_PictographPowerBuildingDataStorieswithPictures({super.key});

  @override
  State<Cl6M_Ch4_A2_PictographPowerBuildingDataStorieswithPictures>
  createState() =>
      _Cl6M_Ch4_A2_PictographPowerBuildingDataStorieswithPicturesState();
}

class _Cl6M_Ch4_A2_PictographPowerBuildingDataStorieswithPicturesState
    extends State<Cl6M_Ch4_A2_PictographPowerBuildingDataStorieswithPictures>
    with TickerProviderStateMixin {
  // === UI & SYSTEM STATE ===
  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';
  bool _showSuccessPopup = false;

  // === AUDIO ===
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // === ANIMATION LOOP ===
  late AnimationController _gameLoopController;

  // === CAMERA & INTERACTION ===
  final GlobalKey _canvasKey = GlobalKey();
  double _zoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;

  double _startZoom = 1.0;

  // === LAB DATA STATE ===
  int _scenario = 1;
  int _step = 0;

  String? _dragItem;
  double _dragX = 0;
  double _dragY = 0;

  // Scenario 1 Data Limits (Fixed: updated cycle count from 3 to 2)
  final Map<String, int> _s1Data = {
    "private": 4,
    "public": 5,
    "school": 8,
    "cycle": 2, // Changed from 3 to 2 as requested
    "walk": 6,
  };
  Map<String, int> _s1Graph = {
    "private": 0,
    "public": 0,
    "school": 0,
    "cycle": 0,
    "walk": 0,
  };

  // Scenario 2
  final Map<String, int> _s2Data = {
    "jalebi": 6,
    "gulab": 9,
    "barfi": 3,
    "rasgulla": 7,
  };
  Map<String, double> _s2Graph = {
    "jalebi": 0,
    "gulab": 0,
    "barfi": 0,
    "rasgulla": 0,
  };
  bool _s2HalfUnlocked = false;

  // Scenario 3
  final Map<String, double> _s3Data = {
    "chaman": 2.5,
    "rani": 3,
    "rukh": 1,
    "jasmeet": 4.5,
    "jetha": 2.5,
    "poonam": 7,
  };
  int _s3RaniCount = 0;
  bool _s3TrophyWinner = false;
  bool _s3WsJasmeet = false;
  bool _s3WsChaman = false;
  bool _s3DiffClicked = false;

  // Scenario 4
  final Map<String, int> _s4Data = {
    "hockey": 8,
    "kabaddi": 6,
    "satoliya": 5,
    "khokho": 9,
  };
  Map<String, int> _s4Tally = {
    "hockey": 0,
    "kabaddi": 0,
    "satoliya": 0,
    "khokho": 0,
  };
  Map<String, double> _s4Graph = {
    "hockey": 0,
    "kabaddi": 0,
    "satoliya": 0,
    "khokho": 0,
  };
  int? _s4Key;

  // Scenario 5
  final Map<String, double> _s5Data = {
    "y2006": 1400,
    "y2010": 1700,
    "y2014": 2200,
    "y2018": 3000,
    "y2022": 3700,
  };
  Map<String, double> _s5Graph1 = {
    "y2006": 1500,
    "y2010": 1500,
    "y2014": 2000,
    "y2018": 3000,
    "y2022": 3500,
  };
  Map<String, double> _s5Graph2 = {
    "y2006": 0,
    "y2010": 0,
    "y2014": 0,
    "y2018": 0,
    "y2022": 0,
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..repeat();

    // Fit screen initially
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitScreen());
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // === AUDIO METHODS ===
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

  void _fitScreen() {
    if (!mounted || _canvasKey.currentContext == null) return;
    final size = _canvasKey.currentContext!.size;
    if (size != null) {
      setState(() {
        _zoom = max(0.4, min(2.0, min(size.width / 1200, size.height / 800)));
        _panX = 0;
        _panY = 0;
      });
    }
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _dragItem = null;
      _showSuccessPopup = false;

      if (id == 1) {
        _s1Graph = {
          "private": 0,
          "public": 0,
          "school": 0,
          "cycle": 0,
          "walk": 0,
        };
      }
      if (id == 2) {
        _s2Graph = {"jalebi": 0, "gulab": 0, "barfi": 0, "rasgulla": 0};
        _s2HalfUnlocked = false;
      }
      if (id == 3) {
        _s3RaniCount = 0;
        _s3TrophyWinner = false;
        _s3WsJasmeet = false;
        _s3WsChaman = false;
        _s3DiffClicked = false;
      }
      if (id == 4) {
        _s4Tally = {"hockey": 0, "kabaddi": 0, "satoliya": 0, "khokho": 0};
        _s4Graph = {"hockey": 0, "kabaddi": 0, "satoliya": 0, "khokho": 0};
        _s4Key = null;
      }
      if (id == 5) {
        _s5Graph1 = {
          "y2006": 1500,
          "y2010": 1500,
          "y2014": 2000,
          "y2018": 3000,
          "y2022": 3500,
        };
        _s5Graph2 = {
          "y2006": 0,
          "y2010": 0,
          "y2014": 0,
          "y2018": 0,
          "y2022": 0,
        };
      }

      _fitScreen();
      playClick();
    });
  }

  void _advanceStep() {
    setState(() => _step++);
  }

  void _checkScenarioSuccess() {
    int maxSteps = _scenario == 2
        ? 5
        : (_scenario == 4 ? 3 : (_scenario == 5 ? 2 : 4));

    if (_showSuccessPopup) return; // Prevent double firing

    setState(() => _step = maxSteps);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showSuccessPopup = true);
        playPageOpen();
      }
    });
  }

  String t(String key) => i18n[_lang]?[key] ?? key;

  // === GESTURE HANDLING ===
  Offset _screenToWorld(Offset localPos) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final size = _canvasKey.currentContext!.size!;
    double worldX = (localPos.dx - size.width / 2 - _panX) / _zoom;
    double worldY = (localPos.dy - size.height / 2 - _panY) / _zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  // Handle instant tap/down interactions independently from Scale Gestures to fix slop delays
  void _onPointerDown(PointerDownEvent event) {
    if (_dragItem != null) return; // Ignore if already dragging

    Offset pt = _screenToWorld(event.localPosition);
    bool itemHit = false;

    if (_scenario == 1) {
      if (_step < 3) {
        if (_hitTestBox(-100, 190, 300, 100, pt)) {
          _dragItem = 's1_person';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          itemHit = true;
        }
      } else if (_step == 3) {
        if (_hitTestBox(-150, -10, 450, 50, pt)) {
          // Hitbox for School Bus row
          _advanceStep();
          playPageOpen();
          _checkScenarioSuccess();
          itemHit = true;
        } else if (_hitTestBox(-150, -100, 450, 250, pt)) {
          // Negative feedback if clicked on a wrong row
          playError();
          itemHit = true;
        }
      }
    } else if (_scenario == 2) {
      if (_step < 5) {
        if (_hitTestBox(-130, 160, 50, 60, pt)) {
          _dragItem = 's2_candy_1';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          itemHit = true;
        }
        if (_s2HalfUnlocked && _hitTestBox(-60, 160, 50, 60, pt)) {
          _dragItem = 's2_candy_0.5';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          itemHit = true;
        }
      }
    } else if (_scenario == 3) {
      if (_step == 0) {
        if (_hitTestBox(-350, -110, 500, 50, pt)) {
          // Rani's kites row
          if (_s3RaniCount < 3) {
            _s3RaniCount++;
            playClick();
            if (_s3RaniCount == 3) {
              _advanceStep();
              playPageOpen();
            }
          }
          itemHit = true;
        } else if (_hitTestBox(-350, -135, 500, 300, pt)) {
          // Clicked a different row in the graph
          playError();
          itemHit = true;
        }
      }
      if (_step == 1 &&
          _hitTestBox(
            200,
            -150,
            100,
            100,
            pt,
          ) && // Fixed Trophy Pick-up Hitbox X alignment
          !_s3TrophyWinner) {
        _dragItem = 'trophy';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        itemHit = true;
      }
      if (_step == 2) {
        if (_hitTestBox(-350, -200 + 65 + 3 * 50 - 25, 500, 50, pt)) {
          _dragItem = 'row_jasmeet';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          itemHit = true;
        }
        if (_hitTestBox(-350, -200 + 65 + 0 * 50 - 25, 500, 50, pt)) {
          _dragItem = 'row_chaman';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          itemHit = true;
        }
      }
      if (_step == 3) {
        if (_hitTestBox(-180, 190, 150, 70, pt)) {
          // Broadened perfectly matched hitbox for workspace difference
          _s3DiffClicked = true;
          _advanceStep();
          playPageOpen();
          _checkScenarioSuccess();
          itemHit = true;
        } else if (_hitTestBox(-350, 170, 500, 120, pt)) {
          // Clicked somewhere in workspace but missed the extra kites
          playError();
          itemHit = true;
        }
      }
    } else if (_scenario == 4) {
      if (_step == 0) {
        List<String> keys = ['hockey', 'kabaddi', 'satoliya', 'khokho'];
        for (int i = 0; i < keys.length; i++) {
          if (_s4Tally[keys[i]] == 0 &&
              _hitTestBox(-550, -100 + i * 40, 120, 30, pt)) {
            _dragItem = 's4grp_${keys[i]}';
            _dragX = pt.dx;
            _dragY = pt.dy;
            playClick();
            itemHit = true;
          }
        }
      }
      if (_step == 1) {
        if (_hitTestBox(20, -30, 120, 50, pt)) {
          playError();
          itemHit = true;
        }
        if (_hitTestBox(160, -30, 120, 50, pt)) {
          _s4Key = 2;
          _advanceStep();
          playPageOpen();
          itemHit = true;
        }
      }
      if (_step == 2) {
        if (_hitTestBox(20, 120, 50, 60, pt)) {
          _dragItem = 's4icon_1';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          itemHit = true;
        }
        if (_hitTestBox(90, 120, 50, 60, pt)) {
          _dragItem = 's4icon_0.5';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          itemHit = true;
        }

        // Scenario 4 Check Button Logic
        if (_hitTestBox(250, 130, 100, 40, pt)) {
          bool correct =
              (_s4Graph['hockey'] == 4.0 &&
              _s4Graph['kabaddi'] == 3.0 &&
              _s4Graph['satoliya'] == 2.5 &&
              _s4Graph['khokho'] == 4.5);
          if (correct) {
            _advanceStep();
            playPageOpen();
            _checkScenarioSuccess(); // Instant success popup flow without double delays
          } else {
            playError();
          }
          itemHit = true;
        }

        // Remove icon logic (Guarded to prevent check button click conflict)
        if (!itemHit) {
          List<String> keys = ['hockey', 'kabaddi', 'satoliya', 'khokho'];
          for (int i = 0; i < keys.length; i++) {
            double cy = -200 + 65 + i * 45;
            if (_hitTestBox(130, cy - 20, 220, 40, pt) &&
                (_s4Graph[keys[i]]! > 0)) {
              double removeVal = (_s4Graph[keys[i]]! % 1 != 0) ? 0.5 : 1.0;
              _s4Graph[keys[i]] = _s4Graph[keys[i]]! - removeVal;
              _dragItem = 's4icon_$removeVal';
              _dragX = pt.dx;
              _dragY = pt.dy;
              playClick();
              itemHit = true;
            }
          }
        }
      }
    } else if (_scenario == 5) {
      double bx = -150, supplyY = -200 + 300 + 40;
      if (_hitTestBox(bx + 20, supplyY + 20, 50, 60, pt)) {
        _dragItem = _step == 0 ? 's5icon_500' : 's5icon_1000';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        itemHit = true;
      }
      if (_hitTestBox(bx + 90, supplyY + 20, 50, 60, pt)) {
        _dragItem = _step == 0 ? 's5icon_400' : 's5icon_700';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        itemHit = true;
      }
      if (_hitTestBox(bx + 160, supplyY + 20, 50, 60, pt)) {
        _dragItem = _step == 0 ? 's5icon_200' : 's5icon_400';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        itemHit = true;
      }
      if (_step == 1 && _hitTestBox(bx + 230, supplyY + 20, 50, 60, pt)) {
        _dragItem = 's5icon_200';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        itemHit = true;
      }

      // Scenario 5 Check Button Logic
      if (_hitTestBox(bx + 350, supplyY + 30, 100, 40, pt)) {
        Map<String, double> g = _step == 0 ? _s5Graph1 : _s5Graph2;
        bool correct =
            (g['y2006'] == 1400.0 &&
            g['y2010'] == 1700.0 &&
            g['y2014'] == 2200.0 &&
            g['y2018'] == 3000.0 &&
            g['y2022'] == 3700.0);
        if (correct) {
          _advanceStep();
          playPageOpen();
          if (_step == 2) {
            _checkScenarioSuccess(); // Called immediately instead of 1s delay
          }
        } else {
          playError();
        }
        itemHit = true;
      }

      if (!itemHit) {
        List<String> keys = ['y2006', 'y2010', 'y2014', 'y2018', 'y2022'];
        for (int i = 0; i < keys.length; i++) {
          double cy = -200 + 65 + i * 50;
          Map<String, double> g = _step == 0 ? _s5Graph1 : _s5Graph2;
          if (_hitTestBox(0, cy - 25, 350, 50, pt) && g[keys[i]]! > 0) {
            double scaleVal = _step == 0 ? 500.0 : 1000.0;
            double removeVal = (g[keys[i]]! % scaleVal != 0)
                ? (g[keys[i]]! % scaleVal)
                : scaleVal;
            g[keys[i]] = g[keys[i]]! - removeVal;
            _dragItem = 's5icon_$removeVal';
            _dragX = pt.dx;
            _dragY = pt.dy;
            playClick();
            itemHit = true;
          }
        }
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _startZoom =
        _zoom; // Only tracking zoom state here; all interactions moved to _onPointerDown to bypass touch slop delay
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_dragItem != null) {
      Offset pt = _screenToWorld(details.localFocalPoint);
      setState(() {
        _dragX = pt.dx;
        _dragY = pt.dy;
      });
    } else {
      setState(() {
        _zoom = max(0.4, min(2.0, _startZoom * details.scale));
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_dragItem == null) return;
    Offset pt = Offset(_dragX, _dragY);
    bool dropped = false;

    if (_dragItem == 's1_person') {
      List<String> keys = ['private', 'public', 'school', 'cycle', 'walk'];
      for (int i = 0; i < keys.length; i++) {
        double cy = -150 + 65 + i * 50;
        // Increased matching hitbox width to 450 to align with wider graph box
        if (_hitTestBox(-150, cy - 25, 450, 50, pt)) {
          int target = _s1Data[keys[i]]!;
          if (_s1Graph[keys[i]]! < target) {
            _s1Graph[keys[i]] = _s1Graph[keys[i]]! + 1;
            dropped = true;
            playClick();
            if (_step == 0 && keys[i] == 'private') _advanceStep();
            if (_step == 1 &&
                keys[i] == 'private' &&
                _s1Graph[keys[i]] == target) {
              _advanceStep();
            }
          }
        }
      }
      if (!dropped) playError();
      if (_step == 2 && _s1Data.keys.every((k) => _s1Graph[k] == _s1Data[k])) {
        _advanceStep();
      }
    } else if (_dragItem!.startsWith('s2_candy')) {
      double val = double.parse(_dragItem!.split('_')[2]);
      List<String> keys = ['jalebi', 'gulab', 'barfi', 'rasgulla'];
      for (int i = 0; i < keys.length; i++) {
        double cy = -150 + 65 + i * 50;
        if (_hitTestBox(-200, cy - 25, 400, 50, pt)) {
          if (_s2Graph[keys[i]]! + (val * 2) <= _s2Data[keys[i]]!) {
            _s2Graph[keys[i]] = _s2Graph[keys[i]]! + (val * 2);
            dropped = true;
            playClick();
            if (_step == 0 && keys[i] == 'jalebi') _advanceStep();
            if (_step == 1 && keys[i] == 'jalebi' && _s2Graph[keys[i]] == 6) {
              _advanceStep();
            }
            if (_step == 3 && keys[i] == 'gulab' && _s2Graph[keys[i]] == 9) {
              _advanceStep();
            }
          } else {
            if (keys[i] == 'gulab' &&
                _step == 2 &&
                _s2Graph[keys[i]] == 8 &&
                val == 1.0) {
              _s2HalfUnlocked = true;
              _advanceStep();
              playError();
              dropped = true;
            } else {
              playError();
              dropped = true;
            }
          }
        }
      }
      if (!dropped && !_s2HalfUnlocked) playError();
      if (_step == 4 && _s2Data.keys.every((k) => _s2Graph[k] == _s2Data[k])) {
        _advanceStep();
        playPageOpen();
        _checkScenarioSuccess();
      }
    } else if (_dragItem == 'trophy') {
      if (_hitTestBox(-350, -200 + 65 + 5 * 50 - 25, 500, 50, pt)) {
        _s3TrophyWinner = true;
        playClick();
        _advanceStep();
      } else {
        playError();
      }
    } else if (_dragItem == 'row_jasmeet') {
      if (_hitTestBox(-350, -200 + 350 + 20, 500, 120, pt)) {
        _s3WsJasmeet = true;
        playClick();
      } else {
        playError();
      }
    } else if (_dragItem == 'row_chaman') {
      if (_hitTestBox(-350, -200 + 350 + 20, 500, 120, pt)) {
        _s3WsChaman = true;
        playClick();
      } else {
        playError();
      }
    } else if (_dragItem!.startsWith('s4grp_')) {
      String k = _dragItem!.split('_')[1];
      if (_hitTestBox(-350, -200, 250, 250, pt)) {
        _s4Tally[k] = _s4Data[k]!;
        playClick();
        if (_s4Data.keys.every((key) => _s4Tally[key]! > 0)) {
          _advanceStep();
          playPageOpen();
        }
      } else {
        playError();
      }
    } else if (_dragItem!.startsWith('s4icon_')) {
      double val = double.parse(_dragItem!.split('_')[1]);
      List<String> keys = ['hockey', 'kabaddi', 'satoliya', 'khokho'];
      for (int i = 0; i < keys.length; i++) {
        double cy = -200 + 65 + i * 45;
        if (_hitTestBox(0, cy - 20, 350, 45, pt)) {
          _s4Graph[keys[i]] = _s4Graph[keys[i]]! + val;
          dropped = true;
          playClick();
        }
      }
      if (!dropped) {
        for (int i = 0; i < keys.length; i++) {
          double cy = -200 + 65 + i * 45;
          if ((pt.dy - cy).abs() < 25 && pt.dx < 0) {
            _s4Graph[keys[i]] = max(0, _s4Graph[keys[i]]! - val);
            playClick();
            dropped = true;
          }
        }
      }
      if (!dropped) playClick();
    } else if (_dragItem!.startsWith('s5icon_')) {
      double val = double.parse(_dragItem!.split('_')[1]);
      List<String> keys = ['y2006', 'y2010', 'y2014', 'y2018', 'y2022'];
      for (int i = 0; i < keys.length; i++) {
        double cy = -200 + 65 + i * 50;
        if (_hitTestBox(-150, cy - 25, 500, 50, pt)) {
          Map<String, double> g = _step == 0 ? _s5Graph1 : _s5Graph2;
          g[keys[i]] = g[keys[i]]! + val;
          dropped = true;
          playClick();
        }
      }
      if (!dropped) {
        for (int i = 0; i < keys.length; i++) {
          double cy = -200 + 65 + i * 50;
          if ((pt.dy - cy).abs() < 25 && pt.dx < -150) {
            Map<String, double> g = _step == 0 ? _s5Graph1 : _s5Graph2;
            g[keys[i]] = max(0, g[keys[i]]! - val);
            playClick();
            dropped = true;
          }
        }
      }
      if (!dropped) playClick();
    }

    if (_scenario == 3 && _step == 2 && _s3WsJasmeet && _s3WsChaman) {
      _advanceStep();
    }

    setState(() => _dragItem = null);
  }

  // === WIDGET BUILD ===
  @override
  Widget build(BuildContext context) {
    if (_showCurtain) return _buildCurtain();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: _buildCanvasArea(),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: _buildSidebar(),
            ),

            // SIDEBAR RESIZER HANDLE
            if (_isSidebarOpen)
              Positioned(
                left: _sidebarWidth - 10,
                top: 0,
                bottom: 0,
                width: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _sidebarWidth += details.delta.dx;
                      if (_sidebarWidth < 350) _sidebarWidth = 350;
                      double maxW = MediaQuery.of(context).size.width * 0.6;
                      if (_sidebarWidth > maxW) _sidebarWidth = maxW;
                    });
                    _fitScreen();
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.white12, width: 1),
                        ),
                      ),
                      child: Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // MENU BUTTON (Fixed Top Left)
            Positioned(
              left: 16,
              top: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                    playClick();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      _isSidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // SUCCESS POPUP
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 500,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _scenario == 5
                                ? t('finalDesc')
                                : 'Scenario completed successfully!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: Icon(
                              _scenario < 5
                                  ? Icons.arrow_forward
                                  : Icons.refresh,
                              color: Colors.white,
                            ),
                            label: Text(
                              _scenario < 5 ? t('nextScenario') : 'Restart',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              setState(() => _showSuccessPopup = false);
                              if (_scenario < 5) {
                                _loadScenario(_scenario + 1);
                              } else {
                                playClick();
                                setState(() => _showCurtain = true);
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () => _loadScenario(1),
                                );
                              }
                            },
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

  Widget _buildCurtain() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bar_chart,
                size: 100,
                color: Colors.indigoAccent,
              ),
              const SizedBox(height: 24),
              Text(
                t('shutterTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('appSubtitle'),
                style: const TextStyle(fontSize: 20, color: Colors.white54),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
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
                  setState(() => _showCurtain = false);
                  _loadScenario(1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    String currentHud = "";
    int maxSteps = _scenario == 2
        ? 5
        : (_scenario == 4 ? 3 : (_scenario == 5 ? 2 : 4));
    if (_step < maxSteps) {
      currentHud = t('s${_scenario}_hud${_step + 1}');
    }

    return Stack(
      children: [
        // Canvas Drawing
        Listener(
          onPointerDown:
              _onPointerDown, // Raw pointer interaction to avoid Gesture Tap delays
          child: GestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: Container(
              color: const Color(0xFF0F172A),
              child: AnimatedBuilder(
                animation: _gameLoopController,
                builder: (context, child) {
                  return CustomPaint(
                    key: _canvasKey,
                    painter: PictographPainter(
                      zoom: _zoom,
                      panX: _panX,
                      panY: _panY,
                      lang: _lang,
                      scenario: _scenario,
                      step: _step,
                      dragItem: _dragItem,
                      dragX: _dragX,
                      dragY: _dragY,
                      s1Graph: _s1Graph,
                      s2Graph: _s2Graph,
                      s2HalfUnlocked: _s2HalfUnlocked,
                      s3RaniCount: _s3RaniCount,
                      s3TrophyWinner: _s3TrophyWinner,
                      s3WsJasmeet: _s3WsJasmeet,
                      s3WsChaman: _s3WsChaman,
                      s3DiffClicked: _s3DiffClicked,
                      s3Data: _s3Data,
                      s4Tally: _s4Tally,
                      s4Graph: _s4Graph,
                      s4Key: _s4Key,
                      s4Data: _s4Data,
                      s5Data: _s5Data,
                      s5Graph1: _s5Graph1,
                      s5Graph2: _s5Graph2,
                      t: t,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
        ),

        // HUD Overlay
        if (currentHud.isNotEmpty)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    top: BorderSide(color: Colors.indigoAccent, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.indigoAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        currentHud,
                        style: const TextStyle(
                          fontSize: 18,
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
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF0F172A),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        66,
                        16,
                        16,
                      ), // Padding for menu button
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.bar_chart,
                                      color: Colors.indigoAccent,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t('appTitle'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            t('appSubtitle'),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.language,
                                    color: Colors.indigoAccent,
                                    size: 18,
                                  ),
                                  InkWell(
                                    onTap: () => setState(
                                      () => _lang = _lang == 'en' ? 'hi' : 'en',
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Text(
                                        _lang.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigoAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Row(
                                  children: [
                                    const Icon(
                                      Icons.refresh,
                                      color: Colors.redAccent,
                                    ),
                                    Text(
                                      t('resetBtn'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: _handleReset,
                                tooltip: t('resetBtn'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Content Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('selectScenario'),
                              style: const TextStyle(
                                fontSize: 10,
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
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  items: List.generate(
                                    5,
                                    (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text(
                                        t('s${i + 1}_title'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
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
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.track_changes,
                                        color: Colors.pinkAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('learnLbl'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellowAccent,
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
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildStepsList(),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: const Color(0xFF0F172A),
                      alignment: Alignment.center,
                      child: const Text(
                        '© ZeroScienceLab - Fall in love with math and Science',
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepsList() {
    int maxSteps = _scenario == 2
        ? 5
        : (_scenario == 4 ? 3 : (_scenario == 5 ? 2 : 4));
    List<Widget> steps = [];

    for (int i = 0; i < maxSteps; i++) {
      bool isCompleted = i < _step;
      bool isActive = i == _step;

      Color bgColor = isActive
          ? Colors.indigo.withOpacity(0.2)
          : (isCompleted
                ? Colors.green.withOpacity(0.1)
                : Colors.white.withOpacity(0.05));
      Color borderColor = isActive
          ? Colors.indigoAccent
          : (isCompleted ? Colors.green : Colors.transparent);

      steps.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                  : Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.indigo : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t("stepLabel")} ${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Action: ${t('s${_scenario}_step${i + 1}_task')}",
                      style: TextStyle(
                        color: isActive ? Colors.indigoAccent : Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Observation: ${t('s${_scenario}_step${i + 1}_out')}",
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
        ),
      );
    }
    return Column(children: steps);
  }

  void _handleReset() {
    playError();
    setState(() => _showCurtain = true);
    Future.delayed(const Duration(milliseconds: 500), () => _loadScenario(1));
  }
}

// === CUSTOM PAINTER FOR CANVAS ===

class PictographPainter extends CustomPainter {
  final double zoom;
  final double panX;
  final double panY;
  final String lang;
  final int scenario;
  final int step;

  final String? dragItem;
  final double dragX;
  final double dragY;

  final Map<String, int> s1Graph;
  final Map<String, double> s2Graph;
  final bool s2HalfUnlocked;

  final int s3RaniCount;
  final bool s3TrophyWinner;
  final bool s3WsJasmeet;
  final bool s3WsChaman;
  final bool s3DiffClicked;
  final Map<String, double> s3Data;

  final Map<String, int> s4Tally;
  final Map<String, double> s4Graph;
  final int? s4Key;
  final Map<String, int> s4Data;

  final Map<String, double> s5Data;
  final Map<String, double> s5Graph1;
  final Map<String, double> s5Graph2;

  final String Function(String) t;

  PictographPainter({
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.lang,
    required this.scenario,
    required this.step,
    required this.dragItem,
    required this.dragX,
    required this.dragY,
    required this.s1Graph,
    required this.s2Graph,
    required this.s2HalfUnlocked,
    required this.s3RaniCount,
    required this.s3TrophyWinner,
    required this.s3WsJasmeet,
    required this.s3WsChaman,
    required this.s3DiffClicked,
    required this.s3Data,
    required this.s4Tally,
    required this.s4Graph,
    required this.s4Key,
    required this.s4Data,
    required this.s5Data,
    required this.s5Graph1,
    required this.s5Graph2,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _renderScenario1(canvas);
    } else if (scenario == 2) {
      _renderScenario2(canvas);
    } else if (scenario == 3) {
      _renderScenario3(canvas);
    } else if (scenario == 4) {
      _renderScenario4(canvas);
    } else if (scenario == 5) {
      _renderScenario5(canvas);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PictographPainter oldDelegate) => true; // Continuously animated

  // --- Drawing Primitives ---

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke, [
    double strokeWidth = 2,
  ]) {
    final rect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (stroke != Colors.transparent && strokeWidth > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color, [
    double width = 2,
  ]) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTextWithOutline(
    Canvas canvas,
    String text,
    Offset pos, {
    double fontSize = 14,
    Color color = Colors.white,
    Color outline = Colors.transparent,
    double outlineWidth = 0,
  }) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
      fontFamily: 'sans-serif',
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    final offset = Offset(
      pos.dx - textPainter.width / 2,
      pos.dy - textPainter.height / 2,
    );

    if (outlineWidth > 0 && outline != Colors.transparent) {
      final outlineStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = outlineWidth
          ..color = outline
          ..strokeJoin = StrokeJoin.round,
      );
      final outlinePainter = TextPainter(
        text: TextSpan(text: text, style: outlineStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      outlinePainter.layout();
      outlinePainter.paint(canvas, offset);
    }
    textPainter.paint(canvas, offset);
  }

  // --- Entity Drawers ---

  void _drawPerson(Canvas canvas, Offset pos, double scale, double fraction) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);

    if (fraction < 1.0) {
      canvas.clipRect(Rect.fromLTWH(-20, -20, 40 * fraction, 40));
    }

    final Paint outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint fillBody = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;
    final Paint fillEye = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    // Legs
    canvas.drawLine(const Offset(-4, 8), const Offset(-6, 20), outline);
    canvas.drawLine(const Offset(4, 8), const Offset(6, 20), outline);
    // Arms
    canvas.drawLine(const Offset(-7, -2), const Offset(-12, 6), outline);
    canvas.drawLine(const Offset(7, -2), const Offset(12, 6), outline);
    // Body
    final bodyRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-8, -5, 16, 16),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRRect, fillBody);
    canvas.drawRRect(bodyRRect, outline);
    // Head
    canvas.drawCircle(const Offset(0, -14), 7, fillBody);
    canvas.drawCircle(const Offset(0, -14), 7, outline);
    // Eyes
    canvas.drawCircle(const Offset(-2.5, -15), 1.5, fillEye);
    canvas.drawCircle(const Offset(2.5, -15), 1.5, fillEye);

    canvas.restore();
  }

  void _drawCandy(Canvas canvas, Offset pos, double scale, double fraction) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    if (fraction < 1.0) {
      canvas.clipRect(Rect.fromLTWH(-30, -20, 60 * fraction, 40));
    }

    final outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = const Color(0xFFEC4899)
      ..style = PaintingStyle.fill;

    // Left wrapper
    final pathL = Path()
      ..moveTo(-12, 0)
      ..lineTo(-24, -10)
      ..lineTo(-22, -2)
      ..lineTo(-26, 0)
      ..lineTo(-22, 2)
      ..lineTo(-24, 10)
      ..close();
    canvas.drawPath(pathL, fill);
    canvas.drawPath(pathL, outline);

    // Right wrapper
    if (fraction == 1.0) {
      final pathR = Path()
        ..moveTo(12, 0)
        ..lineTo(24, -10)
        ..lineTo(22, -2)
        ..lineTo(26, 0)
        ..lineTo(22, 2)
        ..lineTo(24, 10)
        ..close();
      canvas.drawPath(pathR, fill);
      canvas.drawPath(pathR, outline);
    }

    // Center
    final center = Rect.fromCenter(
      center: const Offset(0, 0),
      width: 28,
      height: 20,
    );
    canvas.drawOval(center, fill);
    canvas.drawOval(center, outline);

    // Highlight
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(-4, -4), width: 12, height: 6),
      -0.3,
      pi,
      false,
      Paint()
        ..color = Colors.white60
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (fraction < 1.0) {
      canvas.drawLine(
        const Offset(0, -10),
        const Offset(0, 10),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2,
      );
    }

    canvas.restore();
  }

  void _drawKite(Canvas canvas, Offset pos, double scale, double fraction) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    if (fraction < 1.0) {
      canvas.clipRect(Rect.fromLTWH(-30, -30, 60 * fraction, 80));
    }

    final outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    // Left side
    final pathL = Path()
      ..moveTo(0, -22)
      ..lineTo(0, 22)
      ..lineTo(-16, 0)
      ..close();
    canvas.drawPath(
      pathL,
      Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(pathL, outline);

    // Right side
    final pathR = Path()
      ..moveTo(0, -22)
      ..lineTo(0, 22)
      ..lineTo(16, 0)
      ..close();
    canvas.drawPath(
      pathR,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(pathR, outline);

    // Tail
    final tail = Path()
      ..moveTo(0, 22)
      ..quadraticBezierTo(8, 30, -5, 38)
      ..quadraticBezierTo(5, 45, 0, 50);
    canvas.drawPath(tail, outline);

    // Ribbon
    final ribbon = Path()
      ..moveTo(-5, 38)
      ..lineTo(-12, 35)
      ..lineTo(-8, 42)
      ..close();
    canvas.drawPath(
      ribbon,
      Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(ribbon, outline);

    // Cross spine
    canvas.drawLine(const Offset(-16, 0), const Offset(16, 0), outline);

    canvas.restore();
  }

  void _drawTrophy(Canvas canvas, Offset pos, double scale) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);

    final fill = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    // Base
    canvas.drawRect(const Rect.fromLTWH(-10, 15, 20, 6), fill);
    canvas.drawRect(const Rect.fromLTWH(-10, 15, 20, 6), outline);
    canvas.drawRect(const Rect.fromLTWH(-6, 8, 12, 7), fill);
    canvas.drawRect(const Rect.fromLTWH(-6, 8, 12, 7), outline);

    // Handles
    canvas.drawArc(
      const Rect.fromLTWH(-18, -10, 12, 12),
      pi / 2,
      pi,
      false,
      outline,
    );
    canvas.drawArc(
      const Rect.fromLTWH(6, -10, 12, 12),
      -pi / 2,
      pi,
      false,
      outline,
    );

    // Cup
    final cup = Path()
      ..moveTo(-16, -18)
      ..lineTo(16, -18)
      ..lineTo(12, -2)
      ..quadraticBezierTo(0, 12, -12, -2)
      ..close();
    canvas.drawPath(cup, fill);
    canvas.drawPath(cup, outline);

    // Rim
    final rim = Rect.fromCenter(
      center: const Offset(0, -18),
      width: 32,
      height: 6,
    );
    canvas.drawOval(
      rim,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(rim, outline);

    canvas.restore();
  }

  void _drawSportsIcon(
    Canvas canvas,
    Offset pos,
    String type,
    double scale,
    double fraction,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    if (fraction < 1.0) {
      canvas.clipRect(Rect.fromLTWH(-30, -30, 60 * fraction, 60));
    }

    final outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    if (type == 'hockey') {
      final fill = Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.fill;
      final stick = Path()
        ..moveTo(-8, -20)
        ..lineTo(-2, -20)
        ..lineTo(4, 10)
        ..quadraticBezierTo(15, 22, 18, 14)
        ..lineTo(12, 10)
        ..quadraticBezierTo(8, 15, -2, 10)
        ..close();
      canvas.drawPath(stick, fill);
      canvas.drawPath(stick, outline);
      canvas.drawLine(
        const Offset(-6, -10),
        const Offset(0, -8),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5,
      );
      canvas.drawLine(
        const Offset(-4.5, -2),
        const Offset(1.5, 0),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5,
      );
      canvas.drawCircle(
        const Offset(-10, 16),
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(const Offset(-10, 16), 5, outline);
    } else if (type == 'kabaddi') {
      final fill = Paint()
        ..color = const Color(0xFFFCA5A5)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 4), width: 16, height: 24),
        fill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 4), width: 16, height: 24),
        outline,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-6, -12), width: 6, height: 8),
        fill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-6, -12), width: 6, height: 8),
        outline,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-1, -14), width: 5, height: 7),
        fill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-1, -14), width: 5, height: 7),
        outline,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(4, -13), width: 4, height: 6),
        fill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(4, -13), width: 4, height: 6),
        outline,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(8, -10), width: 3, height: 5),
        fill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(8, -10), width: 3, height: 5),
        outline,
      );
    } else if (type == 'satoliya') {
      List<Color> colors = [
        const Color(0xFF94A3B8),
        const Color(0xFFCBD5E1),
        const Color(0xFF64748B),
        const Color(0xFF94A3B8),
        const Color(0xFFCBD5E1),
        const Color(0xFF64748B),
        const Color(0xFF94A3B8),
      ];
      for (int i = 0; i < 7; i++) {
        double w = 22 - i * 2.5;
        double h = 6;
        _drawRoundedRect(
          canvas,
          -w / 2,
          14 - i * 5.5,
          w,
          h,
          3,
          colors[i],
          const Color(0xFF0F172A),
          2,
        );
      }
    } else {
      // Circle / Generic / Khokho
      final fill = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(-14, 6)
        ..lineTo(-8, -4)
        ..lineTo(2, -4)
        ..quadraticBezierTo(12, -4, 16, 8)
        ..lineTo(16, 14)
        ..lineTo(-14, 14)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, outline);
      _drawRoundedRect(
        canvas,
        -16,
        14,
        34,
        6,
        3,
        Colors.white,
        const Color(0xFF0F172A),
        2.5,
      );
      canvas.drawLine(
        const Offset(-4, 0),
        const Offset(4, 12),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5,
      );
      canvas.drawLine(
        const Offset(2, -2),
        const Offset(10, 12),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5,
      );
    }

    canvas.restore();
  }

  void _drawTigerFace(
    Canvas canvas,
    Offset pos,
    double scale,
    double fraction,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    if (fraction < 1.0) {
      canvas.clipRect(Rect.fromLTWH(-24, -24, 48 * fraction, 48));
    }

    final outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final fillOrange = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    final fillWhite = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;
    final fillRed = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final fillDark = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    // Ears
    canvas.drawCircle(const Offset(-14, -12), 6, fillOrange);
    canvas.drawCircle(const Offset(-14, -12), 6, outline);
    canvas.drawCircle(const Offset(14, -12), 6, fillOrange);
    canvas.drawCircle(const Offset(14, -12), 6, outline);
    canvas.drawCircle(const Offset(-14, -12), 3, fillWhite);
    canvas.drawCircle(const Offset(14, -12), 3, fillWhite);

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: 40, height: 36),
      fillOrange,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: 40, height: 36),
      outline,
    );

    // Muzzle
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 8), width: 20, height: 14),
      fillWhite,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 8), width: 20, height: 14),
      outline,
    );

    // Nose
    final nose = Path()
      ..moveTo(0, 7)
      ..lineTo(-3, 3)
      ..lineTo(3, 3)
      ..close();
    canvas.drawPath(nose, fillRed);
    canvas.drawPath(nose, outline);

    // Eyes
    canvas.drawCircle(const Offset(-7, -4), 2, fillDark);
    canvas.drawCircle(const Offset(7, -4), 2, fillDark);

    // Stripes
    canvas.drawLine(const Offset(-20, -2), const Offset(-12, 0), outline);
    canvas.drawLine(const Offset(20, -2), const Offset(12, 0), outline);
    canvas.drawLine(const Offset(-18, -8), const Offset(-10, -5), outline);
    canvas.drawLine(const Offset(18, -8), const Offset(10, -5), outline);
    canvas.drawLine(const Offset(0, -18), const Offset(0, -10), outline);
    canvas.drawLine(const Offset(-4, -17), const Offset(-3, -11), outline);
    canvas.drawLine(const Offset(4, -17), const Offset(3, -11), outline);

    // Whiskers
    final thinOutline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-10, 8), const Offset(-18, 6), thinOutline);
    canvas.drawLine(const Offset(-10, 10), const Offset(-18, 12), thinOutline);
    canvas.drawLine(const Offset(10, 8), const Offset(18, 6), thinOutline);
    canvas.drawLine(const Offset(10, 10), const Offset(18, 12), thinOutline);

    canvas.restore();
  }

  void _drawPaw(Canvas canvas, Offset pos, double scale, double fraction) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    if (fraction < 1.0) {
      canvas.clipRect(Rect.fromLTWH(-24, -24, 48 * fraction, 48));
    }

    final fill = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final pad = Path()
      ..moveTo(0, 12)
      ..quadraticBezierTo(-18, 8, -12, -4)
      ..quadraticBezierTo(-6, -10, 0, -2)
      ..quadraticBezierTo(6, -10, 12, -4)
      ..quadraticBezierTo(18, 8, 0, 12);
    canvas.drawPath(pad, fill);
    canvas.drawPath(pad, outline);

    // Toes (Straight ovals for clean scaling)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-14, -10), width: 9, height: 13),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-14, -10), width: 9, height: 13),
      outline,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, -16), width: 9, height: 13),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, -16), width: 9, height: 13),
      outline,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(5, -16), width: 9, height: 13),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(5, -16), width: 9, height: 13),
      outline,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(14, -10), width: 9, height: 13),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(14, -10), width: 9, height: 13),
      outline,
    );

    canvas.restore();
  }

  // --- Base UI Renderers ---

  void _renderGraphBase(
    Canvas canvas,
    String title,
    List<String> keys,
    List<String> labels,
    Map<String, dynamic> counts,
    double scale,
    Function iconFn,
    double bx,
    double by,
    double bw,
    double bh, {
    String? targetLabel,
  }) {
    _drawRoundedRect(
      canvas,
      bx,
      by,
      bw,
      bh,
      8,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      3,
    );

    _drawLine(
      canvas,
      bx + 120,
      by,
      bx + 120,
      by + bh,
      const Color(0xFF0F172A),
      2,
    );
    _drawLine(
      canvas,
      bx,
      by + 40,
      bx + bw,
      by + 40,
      const Color(0xFF0F172A),
      2,
    );

    _drawTextWithOutline(canvas, title, Offset(bx + 60, by + 20), fontSize: 16);
    _drawTextWithOutline(
      canvas,
      "Number",
      Offset(bx + 120 + (bw - 120) / 2, by + 20),
      fontSize: 16,
    );

    // Optimized: Custom spacing for different scenarios to prevent any visual overflows
    double iconSpacing = 40.0;
    if (scenario == 1) {
      iconSpacing = 30.0; // tighter spacing to fit 8 students perfectly
    } else if (scenario == 4) {
      iconSpacing = 35.0;
    } else if (scenario == 5) {
      iconSpacing = 35.0;
    }

    for (int i = 0; i < keys.length; i++) {
      double cy = by + 65 + i * 50;

      if (targetLabel == keys[i]) {
        canvas.drawRect(
          Rect.fromLTWH(bx, cy - 25, bw, 50),
          Paint()..color = const Color(0x336366F1),
        );
      }

      _drawTextWithOutline(
        canvas,
        labels[i],
        Offset(bx + 60, cy),
        fontSize: 14,
      );
      _drawLine(canvas, bx, cy + 25, bx + bw, cy + 25, Colors.white10, 1);

      dynamic countVal = counts[keys[i]] ?? 0;
      double val = countVal is int ? countVal.toDouble() : (countVal as double);
      double icons = val / scale;
      int fullIcons = icons.floor();
      double frac = icons - fullIcons;

      for (int j = 0; j < fullIcons; j++) {
        iconFn(canvas, Offset(bx + 150 + j * iconSpacing, cy), 1.2, 1.0);
      }
      if (frac > 0) {
        iconFn(
          canvas,
          Offset(bx + 150 + fullIcons * iconSpacing, cy),
          1.2,
          frac,
        );
      }
    }
  }

  void _renderSupplyBox(
    Canvas canvas,
    String title,
    double sx,
    double sy,
    List<Map<String, dynamic>> items,
  ) {
    _drawRoundedRect(
      canvas,
      sx,
      sy,
      300,
      100,
      8,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );
    _drawTextWithOutline(
      canvas,
      title,
      Offset(sx + 150, sy - 15),
      fontSize: 14,
    );

    for (int i = 0; i < items.length; i++) {
      _drawRoundedRect(
        canvas,
        sx + 20 + i * 70,
        sy + 20,
        50,
        60,
        4,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        2,
      );
      items[i]['fn'](
        canvas,
        Offset(sx + 45 + i * 70, sy + 45),
        1.5,
        items[i]['frac'],
      );
      _drawTextWithOutline(
        canvas,
        items[i]['val'],
        Offset(sx + 45 + i * 70, sy + 95),
        fontSize: 12,
      );
    }
  }

  // --- Scenario Renderers ---

  void _renderScenario1(Canvas canvas) {
    double bx = -150,
        by = -150,
        bw = 450,
        bh = 300; // Widened graph bw to 450 to accommodate 8 bus students
    List<String> keys = ['private', 'public', 'school', 'cycle', 'walk'];
    List<String> labels = [
      t('lbl_private'),
      t('lbl_public'),
      t('lbl_school'),
      t('lbl_cycle'),
      t('lbl_walk'),
    ];

    _renderGraphBase(
      canvas,
      t('lbl_students'),
      keys,
      labels,
      s1Graph,
      1,
      _drawPerson,
      bx,
      by,
      bw,
      bh,
      targetLabel: step >= 3
          ? 'school'
          : null, // Properly highlights row in correct step
    );

    if (step < 3) {
      _renderSupplyBox(canvas, "Drag Icon to Graph", bx + 50, by + bh + 40, [
        {'fn': _drawPerson, 'frac': 1.0, 'val': "1"},
      ]);
    }

    _drawRoundedRect(
      canvas,
      bx + bw + 40,
      by,
      160,
      60,
      8,
      const Color(0xFF3730A3),
      const Color(0xFF0F172A),
      3,
    );
    _drawTextWithOutline(
      canvas,
      "Key",
      Offset(bx + bw + 120, by + 15),
      fontSize: 14,
    );
    _drawPerson(canvas, Offset(bx + bw + 80, by + 40), 1.2, 1.0);
    _drawTextWithOutline(
      canvas,
      "= 1 Student",
      Offset(bx + bw + 130, by + 40),
      fontSize: 14,
    );

    if (dragItem == 's1_person') {
      _drawPerson(canvas, Offset(dragX, dragY), 1.5, 1.0);
    }
  }

  void _renderScenario2(Canvas canvas) {
    double bx = -200, by = -150, bw = 400, bh = 250;
    List<String> keys = ['jalebi', 'gulab', 'barfi', 'rasgulla'];
    List<String> labels = [
      t('lbl_jalebi'),
      t('lbl_gulab'),
      t('lbl_barfi'),
      t('lbl_rasgulla'),
    ];

    _renderGraphBase(
      canvas,
      t('lbl_sweets'),
      keys,
      labels,
      s2Graph,
      2,
      _drawCandy,
      bx,
      by,
      bw,
      bh,
    );

    List<Map<String, dynamic>> supplyItems = [
      {'fn': _drawCandy, 'frac': 1.0, 'val': "2"},
    ];
    if (s2HalfUnlocked || step >= 3) {
      supplyItems.add({'fn': _drawCandy, 'frac': 0.5, 'val': "1"});
    }
    if (step < 5) {
      _renderSupplyBox(
        canvas,
        "Drag Icon to Graph",
        bx + 50,
        by + bh + 40,
        supplyItems,
      );
    }

    _drawRoundedRect(
      canvas,
      bx + bw + 40,
      by,
      160,
      60,
      8,
      const Color(0xFF831843),
      const Color(0xFF0F172A),
      3,
    );
    _drawTextWithOutline(
      canvas,
      "Key",
      Offset(bx + bw + 120, by + 15),
      fontSize: 14,
    );
    _drawCandy(canvas, Offset(bx + bw + 80, by + 40), 1.2, 1.0);
    _drawTextWithOutline(
      canvas,
      "= 2 Students",
      Offset(bx + bw + 140, by + 40),
      fontSize: 14,
    );

    for (int i = 0; i < keys.length; i++) {
      double cy = by + 65 + i * 50;
      bool isFull =
          s2Graph[keys[i]] == [6.0, 9.0, 3.0, 7.0][i]; // mapping s2_data
      _drawTextWithOutline(
        canvas,
        "${s2Graph[keys[i]]!.toInt()}/${[6, 9, 3, 7][i]}",
        Offset(bx + bw + 20, cy),
        fontSize: 14,
        color: isFull ? Colors.greenAccent : Colors.amberAccent,
      );
    }

    if (dragItem == 's2_candy_1') {
      _drawCandy(canvas, Offset(dragX, dragY), 1.5, 1.0);
    }
    if (dragItem == 's2_candy_0.5') {
      _drawCandy(canvas, Offset(dragX, dragY), 1.5, 0.5);
    }
  }

  void _renderScenario3(Canvas canvas) {
    double bx = -350, by = -200, bw = 500, bh = 350;
    List<String> keys = [
      'chaman',
      'rani',
      'rukh',
      'jasmeet',
      'jetha',
      'poonam',
    ];
    List<String> labels = [
      t('lbl_chaman'),
      t('lbl_rani'),
      t('lbl_rukh'),
      t('lbl_jasmeet'),
      t('lbl_jetha'),
      t('lbl_poonam'),
    ];

    _renderGraphBase(
      canvas,
      t('lbl_shopkeepers'),
      keys,
      labels,
      s3Data,
      1,
      _drawKite,
      bx,
      by,
      bw,
      bh,
    );

    if (step == 1 && dragItem != 'trophy' && !s3TrophyWinner) {
      _drawTrophy(canvas, Offset(bx + bw + 100, by + 100), 2);
      _drawTextWithOutline(
        canvas,
        "Drag to Winner",
        Offset(bx + bw + 100, by + 150),
        fontSize: 14,
      );
    }
    if (s3TrophyWinner) {
      _drawTrophy(canvas, Offset(bx - 30, by + 65 + 5 * 50), 1.5);
    }

    _drawRoundedRect(
      canvas,
      bx + bw + 40,
      by,
      160,
      60,
      8,
      const Color(0xFF78350F),
      const Color(0xFF0F172A),
      3,
    );
    _drawTextWithOutline(
      canvas,
      "Key",
      Offset(bx + bw + 120, by + 15),
      fontSize: 14,
    );
    _drawKite(canvas, Offset(bx + bw + 80, by + 40), 1.2, 1.0);
    _drawTextWithOutline(
      canvas,
      "= 100 Kites",
      Offset(bx + bw + 140, by + 40),
      fontSize: 14,
    );

    if (step == 0) {
      _drawTextWithOutline(
        canvas,
        "Rani's Kites: ${s3RaniCount * 100}",
        Offset(bx + bw + 100, by + 200),
        fontSize: 18,
        color: Colors.greenAccent,
      );
    }

    if (step >= 2) {
      double wx = bx, wy = by + bh + 20, ww = 500, wh = 120;
      _drawRoundedRect(
        canvas,
        wx,
        wy,
        ww,
        wh,
        8,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        2,
      );
      _drawTextWithOutline(
        canvas,
        "Workspace",
        Offset(wx + 60, wy + 20),
        fontSize: 14,
      );

      if (step == 2 && (!s3WsJasmeet || !s3WsChaman)) {
        _drawTextWithOutline(
          canvas,
          "Drag Jasmeet & Chaman rows here",
          Offset(wx + ww / 2, wy + wh / 2),
          fontSize: 16,
          color: Colors.white54,
        );
      }

      if (s3WsJasmeet) {
        _drawTextWithOutline(
          canvas,
          "Jasmeet",
          Offset(wx + 50, wy + 55),
          fontSize: 12,
        );
        for (int i = 0; i < 4; i++) {
          _drawKite(canvas, Offset(wx + 120 + i * 40, wy + 55), 1.2, 1.0);
        }
        _drawKite(canvas, Offset(wx + 120 + 4 * 40, wy + 55), 1.2, 0.5);
        if (s3DiffClicked) {
          _drawRoundedRect(
            canvas,
            wx +
                120 +
                2 * 40 -
                10, // Highlight dynamically adjusted to span only the extra 2 kites
            wy + 35,
            110,
            40,
            4,
            Colors.transparent,
            Colors.yellowAccent,
            3,
          );
          _drawTextWithOutline(
            canvas,
            "Diff: 200",
            Offset(wx + 120 + 3 * 40, wy + 20),
            fontSize: 14,
            color: Colors.amber,
          );
        }
      }
      if (s3WsChaman) {
        _drawTextWithOutline(
          canvas,
          "Chaman",
          Offset(wx + 50, wy + 95),
          fontSize: 12,
        );
        for (int i = 0; i < 2; i++) {
          _drawKite(canvas, Offset(wx + 120 + i * 40, wy + 95), 1.2, 1.0);
        }
        _drawKite(canvas, Offset(wx + 120 + 2 * 40, wy + 95), 1.2, 0.5);
      }
    }

    if (dragItem == 'trophy') _drawTrophy(canvas, Offset(dragX, dragY), 2);
    if (dragItem == 'row_jasmeet') {
      _drawRoundedRect(
        canvas,
        dragX - 40,
        dragY - 15,
        180,
        30,
        4,
        const Color(0x806366F1),
        const Color(0xFF0F172A),
        2,
      );
    }
    if (dragItem == 'row_chaman') {
      _drawRoundedRect(
        canvas,
        dragX - 40,
        dragY - 15,
        100,
        30,
        4,
        const Color(0x806366F1),
        const Color(0xFF0F172A),
        2,
      );
    }
  }

  void _renderScenario4(Canvas canvas) {
    List<String> keys = ['hockey', 'kabaddi', 'satoliya', 'khokho'];
    List<String> labels = [
      t('lbl_hockey'),
      t('lbl_kabaddi'),
      t('lbl_satoliya'),
      t('lbl_khokho'),
    ];

    double tx = -350, ty = -200, tw = 250, th = 250;
    _drawRoundedRect(
      canvas,
      tx,
      ty,
      tw,
      th,
      8,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      3,
    );
    _drawTextWithOutline(
      canvas,
      "Tally Table",
      Offset(tx + tw / 2, ty + 20),
      fontSize: 16,
    );
    for (int i = 0; i < keys.length; i++) {
      double cy = ty + 65 + i * 45;
      _drawTextWithOutline(
        canvas,
        labels[i],
        Offset(tx + 50, cy),
        fontSize: 14,
      );
      _drawTextWithOutline(
        canvas,
        "${s4Tally[keys[i]]}",
        Offset(tx + tw - 30, cy),
        fontSize: 16,
        color: Colors.blueAccent,
      );
    }

    if (step == 0) {
      double rx = -550, ry = -100;
      _drawTextWithOutline(
        canvas,
        "Drag Groups",
        Offset(rx + 60, ry - 30),
        fontSize: 14,
      );
      for (int i = 0; i < keys.length; i++) {
        if (s4Tally[keys[i]] == 0) {
          _drawRoundedRect(
            canvas,
            rx,
            ry + i * 40,
            120,
            30,
            4,
            const Color(0xFFE2E8F0),
            const Color(0xFF0F172A),
            2,
          );
          _drawTextWithOutline(
            canvas,
            "${labels[i]} Group",
            Offset(rx + 60, ry + 15 + i * 40),
            fontSize: 12,
            color: const Color(0xFF0F172A),
          );
        }
      }
    }

    if (step == 1) {
      _drawRoundedRect(
        canvas,
        0,
        -100,
        300,
        150,
        8,
        const Color(0xFFFEF08A),
        const Color(0xFF0F172A),
        4,
      );
      _drawTextWithOutline(
        canvas,
        "Select Best Key",
        const Offset(150, -70),
        fontSize: 18,
        color: const Color(0xFF0F172A),
      );

      _drawRoundedRect(
        canvas,
        20,
        -30,
        120,
        50,
        4,
        Colors.white,
        const Color(0xFF0F172A),
        3,
      );
      _drawTextWithOutline(
        canvas,
        "1 = 1 Student",
        const Offset(80, -5),
        fontSize: 14,
        color: const Color(0xFF0F172A),
      );

      _drawRoundedRect(
        canvas,
        160,
        -30,
        120,
        50,
        4,
        Colors.white,
        const Color(0xFF0F172A),
        3,
      );
      _drawTextWithOutline(
        canvas,
        "1 = 2 Students",
        const Offset(220, -5),
        fontSize: 14,
        color: const Color(0xFF0F172A),
      );
    }

    if (step >= 2) {
      double bx = 0, by = -200, bw = 350, bh = 250;
      _drawRoundedRect(
        canvas,
        bx,
        by,
        bw,
        bh,
        8,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        3,
      );
      _drawTextWithOutline(
        canvas,
        "Pictograph",
        Offset(bx + bw / 2, by + 20),
        fontSize: 16,
      );

      for (int i = 0; i < keys.length; i++) {
        double cy = by + 65 + i * 45;
        _drawTextWithOutline(
          canvas,
          labels[i],
          Offset(bx + 60, cy),
          fontSize: 14,
        );
        _drawLine(canvas, bx, cy + 20, bx + bw, cy + 20, Colors.white10, 1);

        double val = s4Graph[keys[i]] ?? 0;
        int fullIcons = val.floor();
        double frac = val - fullIcons;

        for (int j = 0; j < fullIcons; j++) {
          _drawSportsIcon(
            canvas,
            Offset(bx + 130 + j * 35, cy),
            keys[i],
            1.0,
            1.0,
          );
        }
        if (frac > 0) {
          _drawSportsIcon(
            canvas,
            Offset(bx + 130 + fullIcons * 35, cy),
            keys[i],
            1.0,
            0.5,
          );
        }
      }

      _drawTextWithOutline(
        canvas,
        "Key: 1 Icon = 2 Students",
        Offset(bx + bw / 2, by + bh + 20),
        fontSize: 14,
      );

      if (step == 2) {
        _renderSupplyBox(canvas, "Drag icons (Val = 2)", bx, by + bh + 50, [
          {
            'fn': (Canvas c, Offset p, double s, double f) =>
                _drawSportsIcon(c, p, 'circle', s, f),
            'frac': 1.0,
            'val': "2",
          },
          {
            'fn': (Canvas c, Offset p, double s, double f) =>
                _drawSportsIcon(c, p, 'circle', s, f),
            'frac': 0.5,
            'val': "1",
          },
        ]);

        _drawRoundedRect(
          canvas,
          bx + bw - 100,
          by + bh + 80,
          100,
          40,
          8,
          const Color(0xFF22C55E),
          const Color(0xFF0F172A),
          3,
        );
        _drawTextWithOutline(
          canvas,
          "Check",
          Offset(bx + bw - 50, by + bh + 100),
          fontSize: 16,
        );
      }
    }

    if (dragItem != null && dragItem!.startsWith('s4grp_')) {
      _drawRoundedRect(
        canvas,
        dragX - 60,
        dragY - 15,
        120,
        30,
        4,
        const Color(0xFFE2E8F0),
        const Color(0xFF0F172A),
        2,
      );
    }
    if (dragItem == 's4icon_1') {
      _drawSportsIcon(canvas, Offset(dragX, dragY), 'circle', 1, 1);
    }
    if (dragItem == 's4icon_0.5') {
      _drawSportsIcon(canvas, Offset(dragX, dragY), 'circle', 1, 0.5);
    }
  }

  void _renderScenario5(Canvas canvas) {
    List<String> keys = ['y2006', 'y2010', 'y2014', 'y2018', 'y2022'];
    List<String> labels = ['2006', '2010', '2014', '2018', '2022'];

    double tx = -400, ty = -200, tw = 180, th = 300;
    _drawRoundedRect(
      canvas,
      tx,
      ty,
      tw,
      th,
      8,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      3,
    );
    _drawTextWithOutline(
      canvas,
      "Tigers",
      Offset(tx + tw / 2, ty + 20),
      fontSize: 16,
    );
    for (int i = 0; i < keys.length; i++) {
      double cy = ty + 65 + i * 50;
      _drawTextWithOutline(
        canvas,
        labels[i],
        Offset(tx + 50, cy),
        fontSize: 14,
      );
      _drawTextWithOutline(
        canvas,
        "${s5Data[keys[i]]}",
        Offset(tx + tw - 40, cy),
        fontSize: 16,
        color: Colors.blueAccent,
      );
    }

    double bx = -150, by = -200, bw = 500, bh = 300;
    Map<String, double> currentGraph = step == 0 ? s5Graph1 : s5Graph2;
    double scaleVal = step == 0 ? 500 : 1000;
    Function iconFn = step == 0 ? _drawTigerFace : _drawPaw;

    _renderGraphBase(
      canvas,
      "Pictograph (Key: ${scaleVal.toInt()})",
      keys,
      labels,
      currentGraph,
      scaleVal,
      iconFn,
      bx,
      by,
      bw,
      bh,
    );

    double supplyY = by + bh + 40;
    if (step == 0) {
      _renderSupplyBox(canvas, "Drag to Add/Remove", bx, supplyY, [
        {'fn': iconFn, 'frac': 1.0, 'val': "500"},
        {'fn': iconFn, 'frac': 0.8, 'val': "400"},
        {'fn': iconFn, 'frac': 0.4, 'val': "200"},
      ]);
    } else {
      _renderSupplyBox(canvas, "Build New Graph", bx, supplyY, [
        {'fn': iconFn, 'frac': 1.0, 'val': "1000"},
        {'fn': iconFn, 'frac': 0.7, 'val': "700"},
        {'fn': iconFn, 'frac': 0.4, 'val': "400"},
        {'fn': iconFn, 'frac': 0.2, 'val': "200"},
      ]);
    }

    _drawRoundedRect(
      canvas,
      bx + 350,
      supplyY + 30,
      100,
      40,
      8,
      const Color(0xFF22C55E),
      const Color(0xFF0F172A),
      3,
    );
    _drawTextWithOutline(
      canvas,
      "Check",
      Offset(bx + 400, supplyY + 50),
      fontSize: 16,
    );

    if (dragItem != null && dragItem!.startsWith('s5icon_')) {
      double val = double.parse(dragItem!.split('_')[1]);
      double frac = val / scaleVal;
      iconFn(canvas, Offset(dragX, dragY), 1.2, frac);
    }
  }
}

// === DICTIONARY MAP FOR i18n ===
const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': "Pictograph Power: Building Data Stories with Pictures",
    'appTitle': "Pictograph Power",
    'appSubtitle': "Class 6 • DATA HANDLING",
    'enterLab': "Enter Simulation",
    'settings': "Settings",
    'theme': "Theme",
    'darkMode': "Switch to Dark Mode",
    'lightMode': "Switch to Light Mode",
    'boardFontSize': "Text Size",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Observations:",
    'closeBtn': "Close",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'labCompleted': "Lab Completed!",
    'finalDesc':
        "You have successfully learned to create and interpret pictographs!",

    'lbl_students': "Students",
    'lbl_sweets': "Sweets",
    'lbl_shopkeepers': "Shopkeepers",
    'lbl_kites': "Kites",
    'lbl_games': "Games",
    'lbl_years': "Years",
    'lbl_tigers': "Tigers",
    'lbl_private': "Private Car",
    'lbl_public': "Public Bus",
    'lbl_school': "School Bus",
    'lbl_cycle': "Cycle",
    'lbl_walk': "Walking",
    'lbl_jalebi': "Jalebi",
    'lbl_gulab': "G. Jamun",
    'lbl_barfi': "Barfi",
    'lbl_rasgulla': "Rasgulla",
    'lbl_chaman': "Chaman",
    'lbl_rani': "Rani",
    'lbl_rukh': "Rukhsana",
    'lbl_jasmeet': "Jasmeet",
    'lbl_jetha': "Jetha",
    'lbl_poonam': "Poonam",
    'lbl_hockey': "Hockey",
    'lbl_kabaddi': "Kabaddi",
    'lbl_satoliya': "Satoliya",
    'lbl_khokho': "Kho-Kho",

    's1_title': "1. The School Run",
    's1_obj':
        "Understand the basic structure of a pictograph where one symbol represents one unit of data.",
    's1_step1_task': "DRAG a student icon into the 'Private Car' row.",
    's1_step1_out':
        "The counter updates to 1. Each symbol represents one student.",
    's1_step2_task': "Fill the 'Private Car' row with 4 students.",
    's1_step2_out': "The row is complete and locked.",
    's1_step3_task': "Complete all other rows according to the table.",
    's1_step3_out': "All modes of transport are now visually represented.",
    's1_step4_task': "CLICK the label of the row that has the most students.",
    's1_step4_out':
        "School bus is the longest row, making it easy to see it's the most popular!",
    's1_hud1': "Drag 1 student to the Private Car row.",
    's1_hud2': "Drag 3 more to complete Private Car.",
    's1_hud3': "Complete all rows using the table.",
    's1_hud4': "Click the text label of the most popular transport.",

    's2_title': "2. The Sweet Shop",
    's2_obj':
        "Learn how to use a scale where one symbol represents multiple units.",
    's2_step1_task':
        "DRAG a candy icon into the 'Jalebi' row. Observe the scale (1 Candy = 2 Students).",
    's2_step1_out': "One icon adds 2 to the count. This saves space!",
    's2_step2_task': "Fill 'Jalebi' to represent 6 students (3 icons).",
    's2_step2_out': "3 icons x 2 = 6 students.",
    's2_step3_task':
        "Try to represent 9 students for 'G. Jamun' using only full candies.",
    's2_step3_out':
        "You can't! 4 candies = 8. A 5th would make 10. A half-candy is unlocked.",
    's2_step4_task': "DRAG the half-candy to complete 'G. Jamun'.",
    's2_step4_out': "4.5 candies x 2 = 9 students.",
    's2_step5_task': "Complete 'Barfi' (3) and 'Rasgulla' (7).",
    's2_step5_out':
        "Great work! You successfully used full and half symbols based on a 1:2 scale.",
    's2_hud1': "Drag a candy to Jalebi.",
    's2_hud2': "Complete Jalebi to 6.",
    's2_hud3': "Try to add candies for G. Jamun (9).",
    's2_hud4': "Use the new half-candy to reach 9.",
    's2_hud5': "Complete Barfi and Rasgulla using half-candies.",

    's3_title': "3. Counting Kites",
    's3_obj': "Interpret a completed pictograph with a larger scale.",
    's3_step1_task':
        "How many kites did Rani purchase? CLICK her kite symbols to calculate.",
    's3_step1_out': "3 symbols x 100 = 300 kites.",
    's3_step2_task':
        "Who purchased the maximum kites? DRAG the trophy to their name.",
    's3_step2_out': "Poonam Ben has the longest row (700 kites).",
    's3_step3_task':
        "DRAG Jasmeet's and Chaman's rows into the workspace to compare.",
    's3_step3_out': "Lining them up makes comparison easy.",
    's3_step4_task':
        "CLICK the extra symbols Jasmeet has compared to Chaman in the workspace.",
    's3_step4_out': "Jasmeet has 2 extra symbols. 2 x 100 = 200 more kites.",
    's3_hud1': "Click Rani's kites to count.",
    's3_hud2': "Drag the trophy to the highest seller.",
    's3_hud3': "Drag Jasmeet and Chaman's rows to the bottom.",
    's3_hud4': "Click the difference in the workspace.",

    's4_title': "4. Class Favourites",
    's4_obj': "Create a pictograph from raw data, choosing an efficient key.",
    's4_step1_task':
        "DRAG the 4 student groups to tally their favourite games.",
    's4_step1_out': "The raw data is now organized into a frequency table.",
    's4_step2_task': "CLICK to select the best Key: 1:1 or 1:2.",
    's4_step2_out':
        "1 symbol = 2 students is more efficient for larger numbers.",
    's4_step3_task':
        "Build the pictograph by dragging sports icons. (Click 'Check' when done).",
    's4_step3_out':
        "You correctly converted tallies into a pictograph using a 1:2 scale.",
    's4_hud1': "Drag student groups to tally table.",
    's4_hud2': "Select the most efficient key.",
    's4_hud3': "Build the graph. Click 'Check' when ready.",

    's5_title': "5. Tiger Tracking",
    's5_obj': "Identify mistakes and recreate a pictograph with a new scale.",
    's5_step1_task':
        "The graph is wrong! DRAG correct Tiger Faces (Key: 500) to fix it. Click Check.",
    's5_step1_out': "You corrected the errors using full and partial symbols.",
    's5_step2_task':
        "Now, rebuild using Paw Prints (Key: 1000) for a simpler graph.",
    's5_step2_out': "A larger key uses fewer symbols to show the same data.",
    's5_hud1': "Fix the graph using Tiger Faces (Key: 500).",
    's5_hud2': "Rebuild using Paw Prints (Key: 1000).",
  },
  'hi': {
    'shutterTitle': "पिक्टोग्राफ पावर: चित्रों के साथ डेटा",
    'appTitle': "पिक्टोग्राफ पावर",
    'appSubtitle': "कक्षा 6 • डेटा हैंडलिंग",
    'enterLab': "सिमुलेशन दर्ज करें",
    'settings': "सेटिंग्स",
    'theme': "थीम",
    'darkMode': "डार्क मोड",
    'lightMode': "लाइट मोड",
    'boardFontSize': "टेक्स्ट आकार",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "अवलोकन:",
    'closeBtn': "बंद करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट",
    'finishLab': "समाप्त",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc': "आपने पिक्टोग्राफ बनाना और समझना सफलतापूर्वक सीख लिया है!",

    'lbl_students': "छात्र",
    'lbl_sweets': "मिठाई",
    'lbl_shopkeepers': "दुकानदार",
    'lbl_kites': "पतंग",
    'lbl_games': "खेल",
    'lbl_years': "वर्ष",
    'lbl_tigers': "बाघ",
    'lbl_private': "निजी कार",
    'lbl_public': "सार्वजनिक बस",
    'lbl_school': "स्कूल बस",
    'lbl_cycle': "साइकिल",
    'lbl_walk': "पैदल",
    'lbl_jalebi': "जलेबी",
    'lbl_gulab': "गुलाब जामुन",
    'lbl_barfi': "बर्फी",
    'lbl_rasgulla': "रसगुल्ला",
    'lbl_chaman': "चमन",
    'lbl_rani': "रानी",
    'lbl_rukh': "रुक्साना",
    'lbl_jasmeet': "जसमीत",
    'lbl_jetha': "जेठा",
    'lbl_poonam': "पूनम",
    'lbl_hockey': "हॉकी",
    'lbl_kabaddi': "कबड्डी",
    'lbl_satoliya': "सतोलिया",
    'lbl_khokho': "खो-खो",

    's1_title': "1. स्कूल रन",
    's1_obj':
        "पिक्टोग्राफ की बुनियादी संरचना को समझें जहाँ एक प्रतीक एक इकाई को दर्शाता है।",
    's1_step1_task': "एक छात्र आइकन को 'निजी कार' पंक्ति में खींचें।",
    's1_step1_out': "काउंटर 1 हो गया।",
    's1_step2_task': "4 छात्रों के साथ पंक्ति भरें।",
    's1_step2_out': "पंक्ति पूरी हो गई।",
    's1_step3_task': "तालिका के अनुसार अन्य सभी पंक्तियों को पूरा करें।",
    's1_step3_out': "सभी तरीके अब दृष्टिगत रूप से प्रस्तुत किए गए हैं।",
    's1_step4_task': "सबसे अधिक छात्रों वाली पंक्ति के लेबल पर क्लिक करें।",
    's1_step4_out': "स्कूल बस सबसे लोकप्रिय है!",
    's1_hud1': "1 छात्र को निजी कार पंक्ति में खींचें।",
    's1_hud2': "निजी कार को पूरा करने के लिए 3 और खींचें।",
    's1_hud3': "तालिका का उपयोग करके सभी पंक्तियों को पूरा करें।",
    's1_hud4': "सबसे लोकप्रिय परिवहन के टेक्स्ट लेबल पर क्लिक करें।",

    's2_title': "2. मिठाई की दुकान",
    's2_obj':
        "जानें कि ऐसे पैमाने का उपयोग कैसे करें जहां एक प्रतीक कई इकाइयों का प्रतिनिधित्व करता है।",
    's2_step1_task': "जलेबी की पंक्ति में एक कैंडी खींचें। (1 कैंडी = 2 छात्र)",
    's2_step1_out': "एक चिह्न 2 छात्रों को दर्शाता है।",
    's2_step2_task': "6 छात्रों का प्रतिनिधित्व करने के लिए 'जलेबी' भरें।",
    's2_step2_out': "3 कैंडी x 2 = 6 छात्र।",
    's2_step3_task':
        "पूर्ण कैंडी का उपयोग करके 9 छात्रों का प्रतिनिधित्व करने का प्रयास करें।",
    's2_step3_out': "आप नहीं कर सकते! आधी कैंडी खुल गई है।",
    's2_step4_task': "गुलाब जामुन को पूरा करने के लिए आधी कैंडी को खींचें।",
    's2_step4_out': "4.5 कैंडी x 2 = 9 छात्र।",
    's2_step5_task': "बर्फी और रसगुल्ला को पूरा करें।",
    's2_step5_out': "बहुत बढ़िया! आपने 1:2 पैमाने का सफलतापूर्वक उपयोग किया।",
    's2_hud1': "जलेबी की पंक्ति में एक कैंडी खींचें।",
    's2_hud2': "जलेबी को 6 तक पूरा करें।",
    's2_hud3': "गुलाब जामुन (9) के लिए कैंडी जोड़ने का प्रयास करें।",
    's2_hud4': "9 तक पहुँचने के लिए आधी कैंडी का उपयोग करें।",
    's2_hud5': "आधी कैंडी का उपयोग करके बर्फी और रसगुल्ला पूरा करें।",

    's3_title': "3. पतंगों की गिनती",
    's3_obj': "बड़े पैमाने वाले तैयार पिक्टोग्राफ को समझें।",
    's3_step1_task':
        "रानी ने कितनी पतंगें खरीदीं? गिनने के लिए पतंगों पर क्लिक करें।",
    's3_step1_out': "3 पतंग x 100 = 300 पतंगें।",
    's3_step2_task':
        "किसने सबसे ज्यादा पतंगें खरीदीं? ट्रॉफी को उनके नाम पर खींचें।",
    's3_step2_out': "पूनम बेन के पास सबसे लंबी पंक्ति है।",
    's3_step3_task':
        "तुलना करने के लिए जसमीत और चमन की पंक्तियों को कार्यक्षेत्र में खींचें।",
    's3_step3_out': "साथ रखने से तुलना करना आसान हो जाता है।",
    's3_step4_task':
        "चमन की तुलना में जसमीत के पास जो अतिरिक्त पतंगें हैं, उन पर क्लिक करें।",
    's3_step4_out': "जसमीत के पास 2 अतिरिक्त चिह्न हैं। (200 पतंगें)",
    's3_hud1': "गिनने के लिए रानी की पतंगों पर क्लिक करें।",
    's3_hud2': "विजेता को ट्रॉफी दें।",
    's3_hud3': "जसमीत और चमन की पंक्तियों को नीचे खींचें।",
    's3_hud4': "कार्यक्षेत्र में अंतर पर क्लिक करें।",

    's4_title': "4. क्लास फेवरेट",
    's4_obj': "कच्चे डेटा से पिक्टोग्राफ बनाएं और कुंजी चुनें।",
    's4_step1_task':
        "पसंदीदा खेलों की गिनती करने के लिए 4 छात्र समूहों को खींचें।",
    's4_step1_out': "कच्चा डेटा अब एक तालिका में व्यवस्थित हो गया है।",
    's4_step2_task':
        "सर्वश्रेष्ठ कुंजी का चयन करने के लिए क्लिक करें: 1:1 या 1:2।",
    's4_step2_out': "1 प्रतीक = 2 छात्र बड़े डेटा के लिए अधिक कुशल है।",
    's4_step3_task':
        "खेल के आइकन खींचकर पिक्टोग्राफ बनाएं। (तैयार होने पर 'चेक' करें)।",
    's4_step3_out': "आपने 1:2 के पैमाने का उपयोग करके पिक्टोग्राफ बनाया।",
    's4_hud1': "छात्र समूहों को तालिका में खींचें।",
    's4_hud2': "सबसे कुशल कुंजी का चयन करें।",
    's4_hud3': "ग्राफ़ बनाएँ और 'चेक' पर क्लिक करें।",

    's5_title': "5. बाघों की ट्रैकिंग",
    's5_obj':
        "गलतियों को पहचानें और नए पैमाने के साथ पिक्टोग्राफ को फिर से बनाएं।",
    's5_step1_task':
        "ग्राफ गलत है! इसे ठीक करने के लिए सही बाघ के चेहरे (कुंजी: 500) खींचें।",
    's5_step1_out': "आपने प्रतीकों का उपयोग करके त्रुटियों को ठीक कर लिया।",
    's5_step2_task':
        "अब, एक सरल ग्राफ के लिए पंजे (कुंजी: 1000) का उपयोग करके फिर से बनाएं।",
    's5_step2_out': "एक बड़ी कुंजी समान डेटा को कम प्रतीकों के साथ दिखाता है।",
    's5_hud1': "बाघ के चेहरे (500) का उपयोग करके ग्राफ को ठीक करें।",
    's5_hud2': "पंजे (1000) का उपयोग करके फिर से बनाएँ।",
  },
};
