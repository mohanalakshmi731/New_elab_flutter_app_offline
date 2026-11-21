// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/gestures.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Creating Bar Graphs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Plus Jakarta Sans',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const Cl6M_Ch4_A4_CreatingBarGraphs(),
    ),
  );
}

// --- STATE CLASSES ---

class GameState {
  int scenario = 1;
  int step = 0;
  double zoom = 1.0;
  Offset pan = Offset.zero;
  bool isPanMode = false;
  bool isLocked = false;

  String? activeDragEntityString;
  int? activeDragEntityInt;
  Offset dragPos = Offset.zero;

  int? activeInputSlot;
  double errorAnim = 0.0;
  bool animating = false;

  // Scenario 1
  final Map<String, int> s1Data = {
    'cricket': 6,
    'hockey': 8,
    'kabaddi': 5,
    'football': 7,
    'satoliya': 4,
  };
  List<String?> s1Placed = List.filled(5, null);
  List<int> s1Blocks = List.filled(5, 0);

  // Scenario 2
  final Map<String, int> s2Data = {
    'jalebi': 6,
    'gulab': 9,
    'gujiya': 13,
    'barfi': 3,
    'rasgulla': 7,
  };
  List<String?> s2Placed = List.filled(5, null);
  List<int> s2Blocks = List.filled(5, 0);

  // Scenario 3
  final List<int> s3Data = [80, 50, 60, 100, 30, 0, 90, 40];
  List<int> s3Blocks = List.filled(8, 0);
  int s3Scale = 1;
  bool s3Warning = false;

  // Scenario 4
  final Map<String, int> s4Data = {
    'vidisha': 24,
    'jabalpur': 20,
    'seoni': 16,
    'indore': 28,
    'sagar': 16,
  };
  List<String?> s4Placed = List.filled(5, null);
  List<int> s4Blocks = List.filled(5, 0);
  int s4Scale = 1;
  bool s4Checked = false;

  // Scenario 5
  int s5Phase = 0;
  List<int> s5Students = List.filled(15, 0);
  Map<String, int> s5Tally = {'dog': 0, 'cat': 0, 'fish': 0, 'bird': 0};
  final Map<String, int> s5TallyTarget = {
    'dog': 5,
    'cat': 4,
    'fish': 3,
    'bird': 3,
  };
  List<FloatingIcon> s5FloatingIcons = [];
  List<String?> s5Placed = List.filled(4, null);
  List<int> s5Blocks = List.filled(4, 0);

  bool get isDragging =>
      activeDragEntityString != null || activeDragEntityInt != null;

  void reset() {
    activeDragEntityString = null;
    activeDragEntityInt = null;
    activeInputSlot = null;
    animating = false;
    errorAnim = 0;

    if (scenario == 1) {
      s1Placed = List.filled(5, null);
      s1Blocks = List.filled(5, 0);
    }
    if (scenario == 2) {
      s2Placed = List.filled(5, null);
      s2Blocks = List.filled(5, 0);
    }
    if (scenario == 3) {
      s3Scale = 1;
      s3Blocks = List.filled(8, 0);
      s3Warning = false;
    }
    if (scenario == 4) {
      s4Scale = 1;
      s4Placed = List.filled(5, null);
      s4Blocks = List.filled(5, 0);
      s4Checked = false;
    }
    if (scenario == 5) {
      s5Phase = 0;
      s5Students = List.filled(15, 0);
      s5FloatingIcons.clear();
      s5Tally = {'dog': 0, 'cat': 0, 'fish': 0, 'bird': 0};
      s5Placed = List.filled(4, null);
      s5Blocks = List.filled(4, 0);
    }
  }
}

class FloatingIcon {
  final int id;
  final String type;
  double x;
  double y;
  bool collected;
  FloatingIcon(this.id, this.type, this.x, this.y, this.collected);
}

// --- MAIN SCREEN ---

class Cl6M_Ch4_A4_CreatingBarGraphs extends StatefulWidget {
  const Cl6M_Ch4_A4_CreatingBarGraphs({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch4_A4_CreatingBarGraphs> createState() =>
      _Cl6M_Ch4_A4_CreatingBarGraphsState();
}

class _Cl6M_Ch4_A4_CreatingBarGraphsState
    extends State<Cl6M_Ch4_A4_CreatingBarGraphs>
    with SingleTickerProviderStateMixin {
  final GameState gs = GameState();
  final GlobalKey _canvasKey = GlobalKey();

  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';

  late Ticker _ticker;
  double _timeElapsed = 0.0;

  double _initialZoom = 1.0;
  bool _isPanningCanvas = false;
  bool _interactionHandled = false;

  final TextEditingController _freqController = TextEditingController();
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  bool _showSuccessPopup = false;
  String _popupMsg = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      setState(() {
        _timeElapsed = elapsed.inMilliseconds / 1000.0;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _freqController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      if (type == 'tick' || type == 'snap') {
        await _clickPlayer.stop();
        await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
      } else if (type == 'success') {
        await _pagePlayer.stop();
        await _pagePlayer.play(
          AssetSource('audio/class6/science/page_open.mp3'),
        );
      } else if (type == 'error') {
        await _clickPlayer.stop();
        await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
      } else if (type == 'pop') {
        await _dropdownPlayer.stop();
        await _dropdownPlayer.play(
          AssetSource('audio/class6/science/dropdown.mp3'),
        );
      } else if (type == 'curtain') {
        await _pagePlayer.stop();
        await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Map<String, String> get t => i18n[_lang] ?? i18n['en']!;

  // --- SCENARIO LOGIC ---

  int _getTotalSteps(int scenId) {
    if (scenId == 1) return 5;
    if (scenId == 2) return 4;
    if (scenId == 3) return 5;
    if (scenId == 4) return 4;
    if (scenId == 5) return 5;
    return 0;
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      gs.scenario = id;
      gs.step = 0;
      _showSuccessPopup = false;
      gs.reset();
    });
    _playSound('pop');
    _fitScreen();
  }

  void _advanceStep() {
    setState(() {
      gs.step++;
    });
  }

  void _checkScenarioSuccess() {
    setState(() {
      gs.step = _getTotalSteps(gs.scenario);
      _showSuccessPopup = true;
      _popupMsg = t['finalDesc']!;
    });
    _playSound('success');
  }

  void _nextScenario() {
    if (gs.scenario < 5) {
      _loadScenario(gs.scenario + 1);
    }
  }

  // --- GESTURE & HIT TESTING ---

  void _fitScreen() {
    setState(() {
      gs.zoom = 0.8;
      gs.pan = Offset.zero;
    });
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  Offset _screenToWorld(Offset screenPos) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    return Offset(
      (screenPos.dx - box.size.width / 2 - gs.pan.dx) / gs.zoom,
      (screenPos.dy - box.size.height / 2 - gs.pan.dy) / gs.zoom,
    );
  }

  Offset _worldToScreen(double worldX, double worldY) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    return Offset(
      box.size.width / 2 + gs.pan.dx + worldX * gs.zoom,
      box.size.height / 2 + gs.pan.dy + worldY * gs.zoom,
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    if (gs.isLocked || _showSuccessPopup) return;

    if (gs.activeInputSlot != null && !gs.isDragging) {
      setState(() {
        gs.activeInputSlot = null;
        FocusScope.of(context).unfocus();
      });
    }

    Offset worldPt = _screenToWorld(event.localPosition);
    _interactionHandled = false;

    if (!gs.isPanMode) {
      // SCENARIO 1
      if (gs.scenario == 1) {
        List<String> keys = gs.s1Data.keys.toList();
        for (int i = 0; i < keys.length; i++) {
          if (_hitTestBox(-400, -100 + i * 50.0, 220, 50, worldPt) &&
              !gs.s1Placed.contains(keys[i])) {
            setState(() {
              gs.activeDragEntityString = keys[i];
              gs.dragPos = worldPt;
            });
            _playSound('tick');
            _interactionHandled = true;
            return;
          }
        }
        double gX = -100, gY = 150, slotW = 400 / 5;
        for (int i = 0; i < 5; i++) {
          if (gs.s1Placed[i] != null &&
              gs.s1Blocks[i] < gs.s1Data[gs.s1Placed[i]]!) {
            double btnY = gY - (gs.s1Blocks[i] + 1) * 25 - 30;
            if (_hitTestBox(
              gX + i * slotW + 10,
              btnY,
              slotW - 20,
              30,
              worldPt,
            )) {
              setState(() {
                gs.s1Blocks[i]++;
                _playSound('snap');
                if (gs.step == 1 && i == 0 && gs.s1Blocks[i] == 6) {
                  _advanceStep();
                }
                if (gs.step == 3 && i == 1 && gs.s1Blocks[i] == 8) {
                  _advanceStep();
                  gs.animating = true;
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    if (!mounted) return;
                    setState(() {
                      gs.s1Placed = gs.s1Data.keys.toList();
                      gs.s1Blocks = [6, 8, 5, 7, 4];
                      gs.animating = false;
                    });
                    _playSound('success');
                    Future.delayed(
                      const Duration(milliseconds: 1000),
                      _checkScenarioSuccess,
                    );
                  });
                }
              });
              _interactionHandled = true;
              return;
            }
          }
        }
      }
      // SCENARIO 2
      else if (gs.scenario == 2) {
        List<String> keys = gs.s2Data.keys.toList();
        for (int i = 0; i < keys.length; i++) {
          if (_hitTestBox(-400, -100 + i * 50.0, 220, 50, worldPt) &&
              !gs.s2Placed.contains(keys[i])) {
            setState(() {
              gs.activeDragEntityString = keys[i];
              gs.dragPos = worldPt;
            });
            _playSound('tick');
            _interactionHandled = true;
            return;
          }
        }
        double gX = -100, gY = 150, slotW = 400 / 5;
        for (int i = 0; i < 5; i++) {
          if (gs.s2Placed[i] != null && gs.s2Blocks[i] == 0) {
            if (_hitTestBox(
              gX + i * slotW + 10,
              gY - 40,
              slotW - 20,
              30,
              worldPt,
            )) {
              _triggerInputBox(i);
              _interactionHandled = true;
              return;
            }
          }
        }
      }
      // SCENARIO 3
      else if (gs.scenario == 3) {
        double gX = -100, gY = 150, slotW = 500 / 8;
        for (int i = 0; i < 8; i++) {
          if (gs.s3Blocks[i] == 0) {
            if (_hitTestBox(
              gX + i * slotW + 5,
              gY - 40,
              slotW - 10,
              30,
              worldPt,
            )) {
              _triggerInputBox(i);
              _interactionHandled = true;
              return;
            }
          }
        }
        if (gs.step >= 1) {
          if (_hitTestBox(-80, -200, 80, 30, worldPt)) {
            setState(() {
              gs.s3Scale = 1;
              gs.s3Blocks.fillRange(0, 8, 0);
              gs.s3Warning = false;
            });
            _playSound('tick');
            _interactionHandled = true;
            return;
          }
          if (_hitTestBox(10, -200, 80, 30, worldPt)) {
            setState(() {
              gs.s3Scale = 10;
              gs.s3Blocks.fillRange(0, 8, 0);
              gs.s3Warning = false;
            });
            _playSound('tick');
            if (gs.step == 1) _advanceStep();
            _interactionHandled = true;
            return;
          }
        }
      }
      // SCENARIO 4
      else if (gs.scenario == 4) {
        List<String> keys = gs.s4Data.keys.toList();
        for (int i = 0; i < keys.length; i++) {
          if (_hitTestBox(-400, -100 + i * 50.0, 220, 50, worldPt) &&
              !gs.s4Placed.contains(keys[i])) {
            setState(() {
              gs.activeDragEntityString = keys[i];
              gs.dragPos = worldPt;
            });
            _playSound('tick');
            _interactionHandled = true;
            return;
          }
        }
        List<int> scales = [1, 2, 4, 5];
        for (int i = 0; i < scales.length; i++) {
          if (_hitTestBox(-80 + i * 50.0, -200, 40, 30, worldPt)) {
            setState(() {
              gs.s4Scale = scales[i];
              gs.s4Blocks.fillRange(0, 5, 0);
            });
            _playSound('tick');
            if (gs.step == 0 && scales[i] == 4) _advanceStep();
            _interactionHandled = true;
            return;
          }
        }
        double gX = -100, gY = 150, slotW = 400 / 5;
        for (int i = 0; i < 5; i++) {
          if (gs.s4Placed[i] != null && gs.s4Blocks[i] == 0) {
            if (_hitTestBox(
              gX + i * slotW + 10,
              gY - 40,
              slotW - 20,
              30,
              worldPt,
            )) {
              _triggerInputBox(i);
              _interactionHandled = true;
              return;
            }
          }
        }
        if (gs.s4Placed.where((e) => e != null).length == 5 &&
            !gs.s4Blocks.contains(0) &&
            _hitTestBox(320, 110, 160, 50, worldPt)) {
          setState(() {
            gs.s4Checked = true;
          });
          _playSound('success');
          _advanceStep();
          Future.delayed(
            const Duration(milliseconds: 1500),
            _checkScenarioSuccess,
          );
          _interactionHandled = true;
          return;
        }
      }
      // SCENARIO 5
      else if (gs.scenario == 5) {
        if (gs.s5Phase == 0) {
          if (_hitTestBox(-150, -80, 300, 50, worldPt)) {
            setState(() {
              gs.s5Phase = 1;
            });
            _playSound('tick');
            _advanceStep();
            _interactionHandled = true;
            return;
          }
        } else if (gs.s5Phase == 1) {
          double startX = -200, startY = -100;
          bool allClicked = true;
          bool hitAvatar = false;
          for (int r = 0; r < 3; r++) {
            for (int c = 0; c < 5; c++) {
              int idx = r * 5 + c;
              double ax = startX + c * 100;
              double ay = startY + r * 100;
              if (_hitTestBox(ax - 30, ay - 30, 60, 60, worldPt) &&
                  gs.s5Students[idx] == 0) {
                setState(() {
                  gs.s5Students[idx] = 1;
                });
                _playSound('pop');
                hitAvatar = true;
              }
              if (gs.s5Students[idx] == 0) allClicked = false;
            }
          }
          if (allClicked && gs.step == 1) {
            _advanceStep();
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (!mounted) return;
              setState(() {
                gs.s5Phase = 2;
                List<String> assignments = [
                  'dog',
                  'dog',
                  'dog',
                  'dog',
                  'dog',
                  'cat',
                  'cat',
                  'cat',
                  'cat',
                  'fish',
                  'fish',
                  'fish',
                  'bird',
                  'bird',
                  'bird',
                ];
                final rnd = Random();
                for (int i = 0; i < assignments.length; i++) {
                  gs.s5FloatingIcons.add(
                    FloatingIcon(
                      i,
                      assignments[i],
                      -50 + rnd.nextDouble() * 350,
                      -50 + rnd.nextDouble() * 250,
                      false,
                    ),
                  );
                }
              });
            });
          }
          if (hitAvatar) {
            _interactionHandled = true;
            return;
          }
        } else if (gs.s5Phase == 2) {
          for (int i = gs.s5FloatingIcons.length - 1; i >= 0; i--) {
            var ic = gs.s5FloatingIcons[i];
            if (!ic.collected &&
                _hitTestBox(ic.x - 30, ic.y - 30, 60, 60, worldPt)) {
              setState(() {
                gs.activeDragEntityInt = ic.id;
                gs.dragPos = worldPt;
              });
              _playSound('tick');
              _interactionHandled = true;
              return;
            }
          }
        } else if (gs.s5Phase == 3) {
          List<String> keys = ['dog', 'cat', 'fish', 'bird'];
          for (int i = 0; i < keys.length; i++) {
            if (_hitTestBox(-400, -150 + i * 50.0, 220, 50, worldPt) &&
                !gs.s5Placed.contains(keys[i])) {
              setState(() {
                gs.activeDragEntityString = keys[i];
                gs.dragPos = worldPt;
              });
              _playSound('tick');
              _interactionHandled = true;
              return;
            }
          }
          double gX = -100, gY = 150, slotW = 400 / 4;
          for (int i = 0; i < 4; i++) {
            if (gs.s5Placed[i] != null && gs.s5Blocks[i] == 0) {
              if (_hitTestBox(
                gX + i * slotW + 10,
                gY - 40,
                slotW - 20,
                30,
                worldPt,
              )) {
                _triggerInputBox(i);
                _interactionHandled = true;
                return;
              }
            }
          }
          if (gs.s5Placed.where((e) => e != null).length == 4 &&
              !gs.s5Blocks.contains(0) &&
              _hitTestBox(320, 110, 160, 40, worldPt)) {
            _playSound('success');
            _advanceStep();
            Future.delayed(
              const Duration(milliseconds: 1000),
              _checkScenarioSuccess,
            );
            _interactionHandled = true;
            return;
          }
        }
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (gs.isLocked || _showSuccessPopup) return;
    _initialZoom = gs.zoom;
    _isPanningCanvas = !_interactionHandled;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (gs.isLocked || _showSuccessPopup) return;

    if (gs.isDragging) {
      setState(() {
        gs.dragPos = _screenToWorld(details.localFocalPoint);
      });
      return;
    }

    if (_isPanningCanvas) {
      setState(() {
        gs.zoom = (_initialZoom * details.scale).clamp(0.2, 3.0);
        // Correct panning logic: cleanly accumulate the pan deltas frame by frame
        gs.pan += details.focalPointDelta;
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (gs.isLocked || _showSuccessPopup) return;

    if (gs.isDragging) {
      Offset worldPt = gs.dragPos;

      if (gs.scenario == 1) {
        double gX = -100, gY = 150, slotW = 400 / 5;
        bool dropped = false;
        for (int i = 0; i < 5; i++) {
          if (gs.s1Placed[i] == null &&
              _hitTestBox(gX + i * slotW, gY, slotW, 50, worldPt)) {
            setState(() {
              gs.s1Placed[i] = gs.activeDragEntityString;
            });
            _playSound('snap');
            dropped = true;
            if (gs.step == 0 &&
                i == 0 &&
                gs.activeDragEntityString == 'cricket') {
              _advanceStep();
            }
            if (gs.step == 2 &&
                i == 1 &&
                gs.activeDragEntityString == 'hockey') {
              _advanceStep();
            }
            break;
          }
        }
        if (!dropped) _playSound('error');
      } else if (gs.scenario == 2) {
        double gX = -100, gY = 150, slotW = 400 / 5;
        bool dropped = false;
        for (int i = 0; i < 5; i++) {
          if (gs.s2Placed[i] == null &&
              _hitTestBox(gX + i * slotW, gY, slotW, 50, worldPt)) {
            setState(() {
              gs.s2Placed[i] = gs.activeDragEntityString;
            });
            _playSound('snap');
            dropped = true;
            if (gs.step == 0 &&
                i == 0 &&
                gs.activeDragEntityString == 'jalebi') {
              _advanceStep();
            }
            break;
          }
        }
        if (!dropped) _playSound('error');
      } else if (gs.scenario == 4) {
        double gX = -100, gY = 150, slotW = 400 / 5;
        bool dropped = false;
        for (int i = 0; i < 5; i++) {
          if (gs.s4Placed[i] == null &&
              _hitTestBox(gX + i * slotW, gY, slotW, 50, worldPt)) {
            setState(() {
              gs.s4Placed[i] = gs.activeDragEntityString;
            });
            _playSound('snap');
            dropped = true;
            if (gs.step == 1 &&
                i == 0 &&
                gs.activeDragEntityString == 'vidisha') {
              _advanceStep();
            }
            break;
          }
        }
        if (!dropped) _playSound('error');
      } else if (gs.scenario == 5) {
        if (gs.s5Phase == 2) {
          var ic = gs.s5FloatingIcons.firstWhere(
            (x) => x.id == gs.activeDragEntityInt,
          );
          double tx = -400, ty = -200;
          List<String> keys = ['dog', 'cat', 'fish', 'bird'];
          bool dropped = false;
          for (int i = 0; i < 4; i++) {
            if (_hitTestBox(tx, ty + 50 + i * 50.0, 220, 50, worldPt)) {
              if (ic.type == keys[i]) {
                setState(() {
                  gs.s5Tally[ic.type] = gs.s5Tally[ic.type]! + 1;
                  ic.collected = true;
                });
                _playSound('snap');
                dropped = true;
                bool allCollected = true;
                for (var k in keys) {
                  if (gs.s5Tally[k]! < gs.s5TallyTarget[k]!) {
                    allCollected = false;
                  }
                }
                if (allCollected && gs.step == 2) {
                  setState(() {
                    gs.s5Phase = 3;
                  });
                  _advanceStep();
                }
              } else {
                _playSound('error');
              }
              break;
            }
          }
          if (!dropped && !ic.collected) _playSound('error');
        } else if (gs.s5Phase == 3) {
          double gX = -100, gY = 150, slotW = 400 / 4;
          bool dropped = false;
          for (int i = 0; i < 4; i++) {
            if (gs.s5Placed[i] == null &&
                _hitTestBox(gX + i * slotW, gY, slotW, 50, worldPt)) {
              setState(() {
                gs.s5Placed[i] = gs.activeDragEntityString;
              });
              _playSound('snap');
              dropped = true;
              break;
            }
          }
          if (!dropped) _playSound('error');
        }
      }

      setState(() {
        gs.activeDragEntityString = null;
        gs.activeDragEntityInt = null;
      });
    }

    _isPanningCanvas = false;
  }

  void _triggerInputBox(int slotIdx) {
    setState(() {
      gs.activeInputSlot = slotIdx;
      _freqController.text = '';
      gs.isLocked = true;
    });
    _playSound('tick');
  }

  void _submitFrequency() {
    if (gs.activeInputSlot == null) return;
    int val = int.tryParse(_freqController.text) ?? -1;
    if (val < 0) return;

    int slot = gs.activeInputSlot!;

    setState(() {
      gs.activeInputSlot = null;
      gs.isLocked = false;
      FocusScope.of(context).unfocus();
    });

    if (gs.scenario == 2) {
      setState(() {
        gs.s2Blocks[slot] = val;
      });
      _playSound('snap');
      if (gs.step == 1 && slot == 0 && val == 6) _advanceStep();
      if (gs.step == 2 && slot == 1 && val == 9) _advanceStep();
      if (gs.step == 3 && !gs.s2Blocks.contains(0)) {
        _advanceStep();
        Future.delayed(
          const Duration(milliseconds: 1000),
          _checkScenarioSuccess,
        );
      }
    } else if (gs.scenario == 3) {
      if (gs.s3Scale == 1 && val > 20) {
        setState(() {
          gs.animating = true;
        });
        _playSound('pop');
        // Simple manual animation
        Future.delayed(const Duration(milliseconds: 50), () {
          setState(() {
            gs.errorAnim = 1000;
            gs.s3Warning = true;
            gs.animating = false;
          });
          _playSound('error');
          if (gs.step == 0) _advanceStep();
        });
      } else {
        setState(() {
          gs.s3Blocks[slot] = val ~/ gs.s3Scale;
        });
        _playSound('snap');
        if (gs.step == 2 && slot == 0) _advanceStep();
        if (gs.step == 3 && slot == 1) {
          _advanceStep();
          setState(() {
            gs.animating = true;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (!mounted) return;
            setState(() {
              for (int i = 2; i < 8; i++) {
                gs.s3Blocks[i] = gs.s3Data[i] ~/ gs.s3Scale;
              }
              gs.animating = false;
            });
            _playSound('success');
            Future.delayed(
              const Duration(milliseconds: 1000),
              _checkScenarioSuccess,
            );
          });
        }
      }
    } else if (gs.scenario == 4) {
      setState(() {
        gs.s4Blocks[slot] = val ~/ gs.s4Scale;
      });
      _playSound('snap');
      if (gs.step == 1 && slot == 0) _advanceStep();
      if (gs.step == 2 && !gs.s4Blocks.contains(0)) _advanceStep();
    } else if (gs.scenario == 5) {
      setState(() {
        gs.s5Blocks[slot] = val;
      });
      _playSound('snap');
    }
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    String currentHudText = _getHudText();

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
              left: _sidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    if (gs.isLocked || _showSuccessPopup) return;
                    setState(() {
                      double zoomDelta = pointerSignal.scrollDelta.dy > 0
                          ? -0.1
                          : 0.1;
                      gs.zoom = (gs.zoom + zoomDelta).clamp(0.2, 3.0);
                    });
                  }
                },
                onPointerDown: _onPointerDown,
                child: GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  child: CustomPaint(
                    key: _canvasKey,
                    painter: LabPainter(gs, _lang, _timeElapsed),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ),

            // INPUT OVERLAY
            if (gs.activeInputSlot != null)
              Positioned(
                left: _getInputOverlayX(),
                top: _getInputOverlayY(),
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t['lbl_freq'] ?? "Enter Frequency",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: _freqController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                onSubmitted: (_) => _submitFrequency(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _submitFrequency,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // HUD
            if (currentHudText.isNotEmpty &&
                !_showSuccessPopup &&
                !_showCurtain)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: (_sidebarOpen ? _sidebarWidth : 0) + 20,
                right: 20,
                bottom: 20,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xE60F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        top: BorderSide(color: Color(0xFF6366F1), width: 4),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
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
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            currentHudText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    // Entire Sidebar Content (Header + Steps)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sidebar Header
                            Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                top: 66,
                                right: 16,
                                bottom: 16,
                              ),
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
                                        Icons.bar_chart,
                                        color: Color(0xFF6366F1),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t['appTitle']!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.visible,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              t['appSubtitle']!,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white70,
                                              ),
                                              overflow: TextOverflow.visible,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.language,
                                            size: 16,
                                          ),
                                          label: Text(
                                            _lang.toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF0F172A,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _lang = _lang == 'en'
                                                  ? 'hi'
                                                  : 'en';
                                            });
                                            _playSound('pop');
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 16,
                                          ),
                                          label: Text(
                                            t['resetBtn'] ?? 'Reset',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF0F172A,
                                            ),
                                            foregroundColor: Colors.redAccent,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () => _loadScenario(1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Sidebar Content (Scenario Selection & Steps)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['selectScenario']!,
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
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: gs.scenario,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items: [1, 2, 3, 4, 5]
                                            .map(
                                              (id) => DropdownMenuItem(
                                                value: id,
                                                child: Text(t['s${id}_title']!),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) _loadScenario(v);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
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
                                              Icons.track_changes,
                                              color: Colors.pinkAccent,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              t['learnLbl']!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.yellowAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          t['s${gs.scenario}_obj']!,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ..._buildSteps(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F172A),
                        border: Border(top: BorderSide(color: Colors.white12)),
                      ),
                      child: const Text(
                        "© ZeroScienceLab - Fall in love with math and Science",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CANVAS ADJUSTER (Resizer)
            if (_sidebarOpen)
              Positioned(
                left: _sidebarWidth - 10,
                top: 0,
                bottom: 0,
                width: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      setState(() {
                        _sidebarWidth = (_sidebarWidth + details.delta.dx)
                            .clamp(
                              300.0,
                              MediaQuery.of(context).size.width * 0.6,
                            );
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
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
              ),

            // MENU BUTTON
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF0F172A),
                child: Icon(
                  _sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _sidebarOpen = !_sidebarOpen;
                  });
                  _playSound('tick');
                },
              ),
            ),

            // SUCCESS POPUP
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      width: 500,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x6610B981),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t['summaryTitle']!,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _popupMsg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gs.scenario < 5
                                    ? const Color(0xFF6366F1)
                                    : const Color(0xFFF59E0B),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: Icon(
                                gs.scenario < 5
                                    ? Icons.arrow_forward
                                    : Icons.check,
                                color: Colors.white,
                              ),
                              label: Text(
                                gs.scenario < 5
                                    ? t['nextScenario']!
                                    : t['finishLab']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                if (gs.scenario < 5) {
                                  _nextScenario();
                                } else {
                                  setState(() {
                                    _showSuccessPopup = false;
                                    _showCurtain = true;
                                  });
                                  _playSound('pop');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // CURTAIN RAISER
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          size: 100,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t['shutterTitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t['appSubtitle']!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 40),
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
                            color: Colors.white,
                            size: 28,
                          ),
                          label: Text(
                            t['enterLab']!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _showCurtain = false;
                            });
                            _loadScenario(1);
                          },
                        ),
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

  double _getInputOverlayX() {
    if (gs.activeInputSlot == null) return 0;
    double worldX = 0;
    if (gs.scenario == 2) worldX = -100 + gs.activeInputSlot! * (400 / 5) + 40;
    if (gs.scenario == 3) worldX = -100 + gs.activeInputSlot! * (500 / 8) + 30;
    if (gs.scenario == 4) worldX = -100 + gs.activeInputSlot! * (400 / 5) + 40;
    if (gs.scenario == 5) worldX = -100 + gs.activeInputSlot! * (400 / 4) + 50;
    return _worldToScreen(worldX, 0).dx;
  }

  double _getInputOverlayY() {
    return _worldToScreen(0, 150 - 60).dy;
  }

  String _getHudText() {
    if (gs.step < _getTotalSteps(gs.scenario)) {
      return t['s${gs.scenario}_hud${gs.step + 1}'] ?? '';
    }
    return '';
  }

  List<Widget> _buildSteps() {
    int total = _getTotalSteps(gs.scenario);
    List<Widget> steps = [];
    for (int i = 0; i < total; i++) {
      bool isCompleted = i < gs.step;
      bool isActive = i == gs.step;

      Color bgColor = isActive
          ? const Color(0x1A6366F1)
          : isCompleted
          ? const Color(0x1A10B981)
          : const Color(0x0DFFFFFF);
      Color borderColor = isActive
          ? const Color(0xFF6366F1)
          : isCompleted
          ? const Color(0x4D10B981)
          : Colors.transparent;

      String taskHtml = t['s${gs.scenario}_step${i + 1}_task'] ?? '';
      String outHtml = t['s${gs.scenario}_step${i + 1}_out'] ?? '';

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
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 24,
                )
              else if (isActive)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${t['stepLabel']} ${i + 1}",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      taskHtml,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (isCompleted && outHtml.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x3310B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          outHtml,
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 12,
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
    return steps;
  }
}

// --- CUSTOM PAINTER ---

class LabPainter extends CustomPainter {
  final GameState gs;
  final String lang;
  final double timeElapsed;
  late Canvas canvas;

  LabPainter(this.gs, this.lang, this.timeElapsed);

  Map<String, String> get t => i18n[lang] ?? i18n['en']!;

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas c, Size size) {
    canvas = c;
    canvas.save();
    canvas.translate(size.width / 2 + gs.pan.dx, size.height / 2 + gs.pan.dy);
    canvas.scale(gs.zoom);

    if (gs.scenario == 1) {
      _renderScenario1();
    } else if (gs.scenario == 2) {
      _renderScenario2();
    } else if (gs.scenario == 3) {
      _renderScenario3();
    } else if (gs.scenario == 4) {
      _renderScenario4();
    } else if (gs.scenario == 5) {
      _renderScenario5();
    }
    canvas.restore();
  }

  void _renderScenario1() {
    _drawTable(
      -400,
      -150,
      "Favourite Game",
      gs.s1Data,
      gs.s1Placed,
      gs.activeDragEntityString,
    );
    double gX = -100, gY = 150, gW = 400, gH = 250;
    double stepH = _drawGraphAxes(
      gX,
      gY,
      gW,
      gH,
      10,
      1,
      t['lbl_axis_y']!,
      t['lbl_axis_x']!,
    );
    double slotW = gW / 5;

    for (int i = 0; i < 5; i++) {
      double slotX = gX + i * slotW;

      if (gs.step == 0 && i == 0 && !gs.s1Placed.contains('cricket')) {
        _drawRoundedRect(
          Rect.fromLTWH(slotX + 10, gY + 5, slotW - 20, 30),
          4,
          Colors.transparent,
          stroke: Colors.amber,
          strokeWidth: 3,
          dashed: true,
        );
      } else if (gs.step == 2 && i == 1 && !gs.s1Placed.contains('hockey')) {
        _drawRoundedRect(
          Rect.fromLTWH(slotX + 10, gY + 5, slotW - 20, 30),
          4,
          Colors.transparent,
          stroke: Colors.amber,
          strokeWidth: 3,
          dashed: true,
        );
      } else if (gs.s1Placed[i] == null) {
        _drawRoundedRect(
          Rect.fromLTWH(slotX + 10, gY + 5, slotW - 20, 30),
          4,
          Colors.white10,
          stroke: Colors.white24,
          dashed: true,
        );
      }

      if (gs.s1Placed[i] != null) {
        String k = gs.s1Placed[i]!;
        _drawText(
          k[0].toUpperCase() + k.substring(1),
          Offset(slotX + slotW / 2, gY + 20),
          size: 14,
          bold: true,
        );

        int blocks = gs.s1Blocks[i];
        for (int b = 0; b < blocks; b++) {
          double by = gY - (b + 1) * stepH;
          _drawRoundedRect(
            Rect.fromLTWH(slotX + 15, by, slotW - 30, stepH),
            2,
            Colors.blue,
            stroke: Colors.black,
            strokeWidth: 2,
          );
        }

        if (blocks < gs.s1Data[k]! && !gs.animating) {
          if ((gs.step == 1 && i == 0) || (gs.step == 3 && i == 1)) {
            _drawRoundedRect(
              Rect.fromLTWH(
                slotX + 15,
                gY - (blocks + 1) * stepH - 30,
                slotW - 30,
                25,
              ),
              4,
              Colors.green,
              stroke: Colors.black,
              strokeWidth: 2,
            );
            _drawText(
              "+ Block",
              Offset(slotX + slotW / 2, gY - (blocks + 1) * stepH - 17),
              size: 12,
              bold: true,
            );
          }
        }
      }
    }

    if (gs.activeDragEntityString != null) {
      _drawIcon(gs.activeDragEntityString!, gs.dragPos, 60, Colors.pinkAccent);
    }
  }

  void _renderScenario2() {
    _drawTable(
      -400,
      -150,
      "Favourite Sweet",
      gs.s2Data,
      gs.s2Placed,
      gs.activeDragEntityString,
    );
    double gX = -100, gY = 150, gW = 400, gH = 250;
    double stepH = _drawGraphAxes(
      gX,
      gY,
      gW,
      gH,
      15,
      1,
      t['lbl_axis_y']!,
      t['lbl_axis_x']!,
    );
    double slotW = gW / 5;

    for (int i = 0; i < 5; i++) {
      double slotX = gX + i * slotW;

      if (gs.s2Placed[i] == null) {
        bool activeDrop =
            (gs.step == 0 && i == 0) ||
            (gs.step == 2 && i == 1) ||
            (gs.step == 3 && i > 1);
        if (activeDrop && !gs.s2Placed.contains('jalebi') && i == 0) {
          _drawRoundedRect(
            Rect.fromLTWH(slotX + 10, gY + 5, slotW - 20, 30),
            4,
            Colors.transparent,
            stroke: Colors.amber,
            strokeWidth: 3,
            dashed: true,
          );
        } else {
          _drawRoundedRect(
            Rect.fromLTWH(slotX + 10, gY + 5, slotW - 20, 30),
            4,
            Colors.white10,
            stroke: Colors.white24,
            dashed: true,
          );
        }
      }

      if (gs.s2Placed[i] != null) {
        String k = gs.s2Placed[i]!;
        _drawText(
          k[0].toUpperCase() + k.substring(1),
          Offset(slotX + slotW / 2, gY + 20),
          size: 14,
          bold: true,
        );

        int blocks = gs.s2Blocks[i];
        if (blocks > 0) {
          double barH = blocks * stepH;
          _drawRoundedRect(
            Rect.fromLTWH(slotX + 15, gY - barH, slotW - 30, barH),
            4,
            Colors.orange,
            stroke: Colors.black,
            strokeWidth: 2,
          );
          for (int b = 1; b < blocks; b++) {
            _drawLine(
              Offset(slotX + 15, gY - b * stepH),
              Offset(slotX + slotW - 15, gY - b * stepH),
              Colors.black26,
              1,
            );
          }
        }

        if (blocks == 0 && !gs.animating) {
          bool activeInput =
              (gs.step == 1 && i == 0) ||
              (gs.step == 2 && i == 1) ||
              (gs.step == 3 && i > 1);
          if (activeInput) {
            _drawRoundedRect(
              Rect.fromLTWH(slotX + 10, gY - 40, slotW - 20, 30),
              4,
              Colors.white70,
              stroke: Colors.black,
              strokeWidth: 2,
            );
            _drawText(
              "Type...",
              Offset(slotX + slotW / 2, gY - 25),
              size: 12,
              color: Colors.black54,
              italic: true,
            );
          }
        }
      }
    }

    if (gs.activeDragEntityString != null) {
      _drawIcon(gs.activeDragEntityString!, gs.dragPos, 60, Colors.pinkAccent);
    }
  }

  void _renderScenario3() {
    double tx = -400, ty = -150;
    _drawRoundedRect(
      Rect.fromLTWH(tx, ty, 220, 420),
      8,
      const Color(0xFF1E293B),
      stroke: Colors.black,
      strokeWidth: 3,
    );
    _drawRoundedRect(
      Rect.fromLTWH(tx, ty, 220, 50),
      8,
      Colors.green,
      stroke: Colors.black,
      strokeWidth: 3,
    );
    _drawText(
      "Smriti's Scores",
      Offset(tx + 110, ty + 25),
      size: 18,
      bold: true,
    );

    for (int i = 0; i < gs.s3Data.length; i++) {
      double rowY = ty + 50 + i * 45;
      _drawLine(Offset(tx, rowY), Offset(tx + 220, rowY), Colors.white12, 1);
      _drawText(
        "Match ${i + 1}",
        Offset(tx + 10, rowY + 22),
        size: 16,
        align: TextAlign.left,
      );
      _drawText(
        "${gs.s3Data[i]}",
        Offset(tx + 210, rowY + 22),
        size: 18,
        bold: true,
        align: TextAlign.right,
      );
    }

    double sx = -150, sy = -200;
    _drawText("Scale:", Offset(sx + 30, sy + 15), size: 20, bold: true);
    Color sColor1 = gs.s3Scale == 1 ? Colors.blue : Colors.blueGrey;
    Color sColor10 = gs.s3Scale == 10 ? Colors.blue : Colors.blueGrey;

    _drawRoundedRect(
      Rect.fromLTWH(sx + 70, sy, 80, 30),
      4,
      sColor1,
      stroke: Colors.black,
      strokeWidth: 2,
    );
    _drawText(
      "1=1",
      Offset(sx + 110, sy + 15),
      size: 16,
      bold: true,
      color: gs.s3Scale == 1 ? Colors.white : Colors.black87,
    );

    if (gs.step >= 1) {
      if (gs.step == 1 && gs.s3Scale == 1) {
        _drawRoundedRect(
          Rect.fromLTWH(sx + 160, sy, 80, 30),
          4,
          Colors.transparent,
          stroke: Colors.amber,
          strokeWidth: 3,
          dashed: true,
        );
      }
      _drawRoundedRect(
        Rect.fromLTWH(sx + 160, sy, 80, 30),
        4,
        sColor10,
        stroke: Colors.black,
        strokeWidth: 2,
      );
      _drawText(
        "1=10",
        Offset(sx + 200, sy + 15),
        size: 16,
        bold: true,
        color: gs.s3Scale == 10 ? Colors.white : Colors.black87,
      );
    }

    double gX = -100, gY = 150, gW = 500, gH = 250;
    double maxVal = gs.s3Scale == 1 ? 20 : 100;
    double stepH = _drawGraphAxes(
      gX,
      gY,
      gW,
      gH,
      maxVal,
      gs.s3Scale.toDouble(),
      "Runs",
      "Matches",
    );
    double slotW = gW / 8;

    for (int i = 0; i < 8; i++) {
      double slotX = gX + i * slotW;
      _drawText("M${i + 1}", Offset(slotX + slotW / 2, gY + 25), size: 14);

      int blocks = gs.s3Blocks[i];
      if (blocks > 0) {
        double barH = blocks * (stepH / (gs.s3Scale == 1 ? 2 : 1));
        if (gs.s3Scale == 1 && gs.step == 0 && i == 0) barH = gs.errorAnim;

        _drawRoundedRect(
          Rect.fromLTWH(slotX + 5, gY - barH, slotW - 10, barH),
          4,
          Colors.green,
          stroke: Colors.black,
          strokeWidth: 2,
        );
        for (int b = 1; b < blocks; b++) {
          _drawLine(
            Offset(slotX + 5, gY - b * stepH),
            Offset(slotX + slotW - 5, gY - b * stepH),
            Colors.black26,
            1,
          );
        }

        if (gs.step >= 2 && i < 2 && !gs.animating && blocks > 0) {
          _drawText(
            "${gs.s3Data[i]} = $blocks blk",
            Offset(slotX + slotW / 2, gY - barH - 15),
            size: 10,
            bold: true,
          );
        }
      }

      if (blocks == 0 && !gs.animating) {
        bool activeInput =
            (gs.step == 0 && i == 0) ||
            (gs.step == 2 && i == 0) ||
            (gs.step == 3 && i == 1);
        if (activeInput) {
          _drawRoundedRect(
            Rect.fromLTWH(slotX + 5, gY - 40, slotW - 10, 30),
            4,
            Colors.white70,
            stroke: Colors.black,
            strokeWidth: 2,
          );
          _drawText(
            "Type",
            Offset(slotX + slotW / 2, gY - 25),
            size: 12,
            color: Colors.black54,
            italic: true,
          );
        }
      }
    }

    if (gs.s3Warning) {
      _drawRoundedRect(
        Rect.fromLTWH(-100, -100, 300, 80),
        8,
        Colors.red[50]!,
        stroke: Colors.red,
        strokeWidth: 4,
      );
      _drawText(
        "Whoa! That bar is too tall!\nTry a different scale.",
        Offset(50, -60),
        size: 16,
        bold: true,
        color: Colors.red[900]!,
      );
    }
  }

  void _renderScenario4() {
    _drawTable(
      -400,
      -150,
      "Tickets Sold",
      gs.s4Data,
      gs.s4Placed,
      gs.activeDragEntityString,
    );

    double sx = -150, sy = -200;
    _drawText("Scale:", Offset(sx + 30, sy + 15), size: 20, bold: true);
    List<int> scales = [1, 2, 4, 5];
    for (int i = 0; i < scales.length; i++) {
      Color sColor = gs.s4Scale == scales[i] ? Colors.blue : Colors.blueGrey;
      _drawRoundedRect(
        Rect.fromLTWH(sx + 70 + i * 50.0, sy, 40, 30),
        4,
        sColor,
        stroke: Colors.black,
        strokeWidth: 2,
      );
      _drawText(
        "${scales[i]}",
        Offset(sx + 90 + i * 50.0, sy + 15),
        size: 16,
        bold: true,
        color: gs.s4Scale == scales[i] ? Colors.white : Colors.black87,
      );
    }

    double gX = -100, gY = 150, gW = 400, gH = 250;
    double maxVal = gs.s4Scale * 10.0;
    double stepH = _drawGraphAxes(
      gX,
      gY,
      gW,
      gH,
      maxVal,
      gs.s4Scale.toDouble(),
      "Tickets",
      "City",
    );
    double slotW = gW / 5;

    for (int i = 0; i < 5; i++) {
      double slotX = gX + i * slotW;

      if (gs.s4Placed[i] == null) {
        _drawRoundedRect(
          Rect.fromLTWH(slotX + 10, gY + 5, slotW - 20, 30),
          4,
          Colors.white10,
          stroke: Colors.white24,
          dashed: true,
        );
      } else {
        String k = gs.s4Placed[i]!;
        _drawText(
          k[0].toUpperCase() + k.substring(1),
          Offset(slotX + slotW / 2, gY + 20),
          size: 14,
          bold: true,
        );

        int blocks = gs.s4Blocks[i];
        if (blocks > 0) {
          double barH = blocks * stepH;
          _drawRoundedRect(
            Rect.fromLTWH(slotX + 15, gY - barH, slotW - 30, barH),
            4,
            Colors.purpleAccent,
            stroke: Colors.black,
            strokeWidth: 2,
          );

          if (gs.s4Checked) {
            double correctBlocks = gs.s4Data[k]! / gs.s4Scale;
            if ((blocks - correctBlocks).abs() < 0.1 && gs.s4Scale == 4) {
              _drawIcon(
                'check',
                Offset(slotX + slotW / 2, gY - barH - 15),
                24,
                Colors.green,
              );
            } else {
              _drawIcon(
                'cross',
                Offset(slotX + slotW / 2, gY - barH - 15),
                24,
                Colors.red,
              );
              _drawLine(
                Offset(slotX + 5, gY - correctBlocks * stepH),
                Offset(slotX + slotW - 5, gY - correctBlocks * stepH),
                Colors.green,
                3,
                dashed: true,
              );
            }
          }
        } else if (!gs.animating) {
          _drawRoundedRect(
            Rect.fromLTWH(slotX + 10, gY - 40, slotW - 20, 30),
            4,
            Colors.white70,
            stroke: Colors.black,
            strokeWidth: 2,
          );
          _drawText(
            "Type",
            Offset(slotX + slotW / 2, gY - 25),
            size: 12,
            color: Colors.black54,
            italic: true,
          );
        }
      }
    }

    if (gs.s4Placed.where((e) => e != null).length == 5 &&
        !gs.s4Blocks.contains(0) &&
        gs.step == 3) {
      _drawRoundedRect(
        Rect.fromLTWH(gX + gW + 20, gY - 40, 160, 50),
        8,
        Colors.green,
        stroke: Colors.black,
        strokeWidth: 3,
      );
      _drawText(
        "Check Work",
        Offset(gX + gW + 100, gY - 15),
        size: 18,
        bold: true,
      );
    }

    if (gs.activeDragEntityString != null) {
      _drawText(
        gs.activeDragEntityString!.toUpperCase(),
        gs.dragPos,
        size: 20,
        bold: true,
        color: Colors.pinkAccent,
      );
    }
  }

  void _renderScenario5() {
    if (gs.s5Phase == 0) {
      _drawText(
        "Choose a Survey Question",
        const Offset(0, -150),
        size: 24,
        bold: true,
      );
      List<String> qs = [
        'Favourite Pet?',
        'Favourite Colour?',
        'Favourite Subject?',
      ];
      for (int i = 0; i < qs.length; i++) {
        Color btnColor = (i == 0) ? Colors.blue : Colors.blueGrey;
        _drawRoundedRect(
          Rect.fromLTWH(-150, -80 + i * 70.0, 300, 50),
          10,
          btnColor,
          stroke: Colors.black,
          strokeWidth: 3,
        );
        _drawText(qs[i], Offset(0, -55 + i * 70.0), size: 16, bold: true);
        if (gs.step == 0 && i == 0) {
          _drawRoundedRect(
            Rect.fromLTWH(-150, -80, 300, 50),
            10,
            Colors.transparent,
            stroke: Colors.amber,
            strokeWidth: 3,
            dashed: true,
          );
        }
      }
    } else if (gs.s5Phase == 1) {
      _drawText(
        "Question: Favourite Pet?",
        const Offset(0, -200),
        size: 20,
        bold: true,
      );
      double startX = -200, startY = -100;
      List<String> assignments = [
        'dog',
        'dog',
        'dog',
        'dog',
        'dog',
        'cat',
        'cat',
        'cat',
        'cat',
        'fish',
        'fish',
        'fish',
        'bird',
        'bird',
        'bird',
      ];

      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 5; c++) {
          int idx = r * 5 + c;
          double ax = startX + c * 100;
          double ay = startY + r * 100;

          _drawIcon('avatar', Offset(ax, ay), 50, Colors.transparent);

          if (gs.s5Students[idx] == 1) {
            _drawRoundedRect(
              Rect.fromLTWH(ax + 10, ay - 60, 40, 40),
              8,
              Colors.white,
              stroke: Colors.black,
              strokeWidth: 2,
            );
            _drawLine(
              Offset(ax + 20, ay - 20),
              Offset(ax + 15, ay - 10),
              Colors.black,
              2,
            );
            _drawLine(
              Offset(ax + 30, ay - 20),
              Offset(ax + 15, ay - 10),
              Colors.black,
              2,
            );
            Color icColor = assignments[idx] == 'cat'
                ? Colors.orange
                : Colors.black87;
            _drawIcon(assignments[idx], Offset(ax + 30, ay - 40), 24, icColor);
          } else {
            _drawText(
              "?",
              Offset(ax, ay - 35),
              size: 24,
              bold: true,
              color: Colors.white54,
            );
          }
        }
      }
    } else if (gs.s5Phase == 2 || gs.s5Phase == 3) {
      double tx = -400, ty = -200;
      _drawRoundedRect(
        Rect.fromLTWH(tx, ty, 220, 260),
        8,
        const Color(0xFF1E293B),
        stroke: Colors.black,
        strokeWidth: 3,
      );
      _drawRoundedRect(
        Rect.fromLTWH(tx, ty, 220, 50),
        8,
        Colors.indigo,
        stroke: Colors.black,
        strokeWidth: 3,
      );
      _drawText("Tally Table", Offset(tx + 110, ty + 25), size: 18, bold: true);

      List<String> keys = ['dog', 'cat', 'fish', 'bird'];
      for (int i = 0; i < keys.length; i++) {
        String k = keys[i];
        double rowY = ty + 50 + i * 50.0;
        _drawLine(Offset(tx, rowY), Offset(tx + 220, rowY), Colors.white12, 1);

        Color icColor = k == 'cat' ? Colors.orange : Colors.black87;
        _drawRoundedRect(
          Rect.fromLTWH(tx + 10, rowY + 5, 40, 40),
          20,
          Colors.white,
          stroke: Colors.transparent,
        );
        _drawIcon(k, Offset(tx + 30, rowY + 25), 24, icColor);

        int count = gs.s5Tally[k]!;
        for (int t = 0; t < count; t++) {
          if (t == 4) {
            _drawLine(
              Offset(tx + 65, rowY + 40),
              Offset(tx + 100, rowY + 10),
              Colors.white,
              3,
            );
          } else if (t < 4) {
            _drawLine(
              Offset(tx + 70 + t * 8.0, rowY + 10),
              Offset(tx + 70 + t * 8.0, rowY + 40),
              Colors.white,
              3,
            );
          }
        }
        if (count > 0) {
          _drawText(
            "$count",
            Offset(tx + 200, rowY + 25),
            size: 20,
            bold: true,
            align: TextAlign.right,
          );
        }
      }

      if (gs.s5Phase == 2) {
        for (var ic in gs.s5FloatingIcons) {
          if (!ic.collected) {
            Color icColor = ic.type == 'cat' ? Colors.orange : Colors.black87;
            _drawRoundedRect(
              Rect.fromLTWH(ic.x - 22, ic.y - 22, 44, 44),
              22,
              Colors.white,
              stroke: Colors.blueGrey,
              strokeWidth: 2,
            );
            _drawIcon(ic.type, Offset(ic.x, ic.y), 24, icColor);
          }
        }
        if (gs.activeDragEntityInt != null) {
          var activeIc = gs.s5FloatingIcons.firstWhere(
            (ic) => ic.id == gs.activeDragEntityInt,
            orElse: () => FloatingIcon(-1, '', 0, 0, true),
          );
          if (activeIc.id != -1) {
            Color icColor = activeIc.type == 'cat'
                ? Colors.orange
                : Colors.black87;
            _drawRoundedRect(
              Rect.fromLTWH(gs.dragPos.dx - 22, gs.dragPos.dy - 22, 44, 44),
              22,
              Colors.white,
              stroke: Colors.blueGrey,
              strokeWidth: 2,
            );
            _drawIcon(activeIc.type, gs.dragPos, 24, icColor);
          }
        }
      } else if (gs.s5Phase == 3) {
        double gX = -100, gY = 150, gW = 400, gH = 250;
        double stepH = _drawGraphAxes(
          gX,
          gY,
          gW,
          gH,
          5,
          1,
          t['lbl_axis_y']!,
          t['lbl_axis_x']!,
        );
        double slotW = gW / 4;

        for (int i = 0; i < 4; i++) {
          double slotX = gX + i * slotW;

          if (gs.s5Placed[i] == null) {
            _drawRoundedRect(
              Rect.fromLTWH(slotX + 10, gY + 5, slotW - 20, 30),
              4,
              Colors.white10,
              stroke: Colors.white24,
              dashed: true,
            );
          } else {
            String k = gs.s5Placed[i]!;
            _drawText(
              k[0].toUpperCase() + k.substring(1),
              Offset(slotX + slotW / 2, gY + 20),
              size: 12,
              bold: true,
            );

            int blocks = gs.s5Blocks[i];
            if (blocks > 0) {
              double barH = blocks * stepH;
              _drawRoundedRect(
                Rect.fromLTWH(slotX + 15, gY - barH, slotW - 30, barH),
                4,
                Colors.pinkAccent,
                stroke: Colors.black,
                strokeWidth: 2,
              );
              for (int b = 1; b < blocks; b++) {
                _drawLine(
                  Offset(slotX + 15, gY - b * stepH),
                  Offset(slotX + slotW - 15, gY - b * stepH),
                  Colors.black26,
                  1,
                );
              }
            } else if (!gs.animating) {
              _drawRoundedRect(
                Rect.fromLTWH(slotX + 10, gY - 40, slotW - 20, 30),
                4,
                Colors.white70,
                stroke: Colors.black,
                strokeWidth: 2,
              );
              _drawText(
                "Type",
                Offset(slotX + slotW / 2, gY - 25),
                size: 12,
                color: Colors.black54,
                italic: true,
              );
            }
          }
        }

        if (gs.s5Placed.where((e) => e != null).length == 4 &&
            !gs.s5Blocks.contains(0) &&
            gs.step == 4) {
          _drawRoundedRect(
            Rect.fromLTWH(gX + gW + 20, gY - 40, 160, 40),
            8,
            Colors.green,
            stroke: Colors.black,
            strokeWidth: 3,
          );
          _drawText(
            "Present Findings",
            Offset(gX + gW + 100, gY - 20),
            size: 14,
            bold: true,
          );
        }

        if (gs.activeDragEntityString != null) {
          Color icColor = gs.activeDragEntityString == 'cat'
              ? Colors.orange
              : Colors.black87;
          _drawRoundedRect(
            Rect.fromLTWH(gs.dragPos.dx - 22, gs.dragPos.dy - 22, 44, 44),
            22,
            Colors.white,
            stroke: Colors.blueGrey,
            strokeWidth: 2,
          );
          _drawIcon(gs.activeDragEntityString!, gs.dragPos, 24, icColor);
        }
      }
    }
  }

  // --- HELPER DRAW FUNCTIONS ---

  void _drawTable(
    double x,
    double y,
    String title,
    Map<String, int> dataObj,
    List<String?> placedKeys,
    String? draggingId,
  ) {
    List<String> keys = dataObj.keys.toList();
    double h = keys.length * 50 + 60.0;
    _drawRoundedRect(
      Rect.fromLTWH(x, y, 220, h),
      8,
      const Color(0xFF1E293B),
      stroke: Colors.black,
      strokeWidth: 3,
    );
    _drawRoundedRect(
      Rect.fromLTWH(x, y, 220, 50),
      8,
      const Color(0xFF6366F1),
      stroke: Colors.black,
      strokeWidth: 3,
    );
    _drawText(title, Offset(x + 110, y + 25), size: 18, bold: true);

    for (int i = 0; i < keys.length; i++) {
      String k = keys[i];
      double rowY = y + 50 + i * 50.0;
      _drawLine(Offset(x, rowY), Offset(x + 220, rowY), Colors.white12, 1);

      bool isPlaced = placedKeys.contains(k) || draggingId == k;
      int alpha = isPlaced ? 80 : 255;

      if (title == "Tickets Sold") {
        _drawText(
          k[0].toUpperCase() + k.substring(1),
          Offset(x + 10, rowY + 25),
          size: 18,
          color: Colors.white.withAlpha(alpha),
          align: TextAlign.left,
        );
      } else {
        Color iconColor = k == 'cat' ? Colors.orange : Colors.black87;
        _drawRoundedRect(
          Rect.fromLTWH(x + 10, rowY + 5, 40, 40),
          20,
          Colors.white.withAlpha(alpha),
        );
        _drawIcon(k, Offset(x + 30, rowY + 25), 24, iconColor.withAlpha(alpha));
        _drawText(
          k[0].toUpperCase() + k.substring(1),
          Offset(x + 60, rowY + 25),
          size: 16,
          color: Colors.white.withAlpha(alpha),
          align: TextAlign.left,
        );
      }
      _drawText(
        "${dataObj[k]}",
        Offset(x + 200, rowY + 25),
        size: 20,
        bold: true,
        color: Colors.white.withAlpha(alpha),
        align: TextAlign.right,
      );
    }
  }

  double _drawGraphAxes(
    double x,
    double y,
    double w,
    double h,
    double maxVal,
    double scale,
    String yLabel,
    String xLabel,
  ) {
    _drawLine(Offset(x, y), Offset(x, y - h), Colors.white, 3);
    _drawLine(Offset(x, y), Offset(x + w, y), Colors.white, 3);

    _drawText(yLabel, Offset(x - 50, y - h / 2), size: 16, bold: true);
    _drawText(xLabel, Offset(x + w / 2, y + 50), size: 16, bold: true);

    int steps = (maxVal / scale).round();
    double stepH = h / steps;

    for (int i = 0; i <= steps; i++) {
      double currentY = y - i * stepH;
      _drawLine(Offset(x - 5, currentY), Offset(x, currentY), Colors.white, 2);
      if (i > 0) {
        _drawLine(
          Offset(x, currentY),
          Offset(x + w, currentY),
          Colors.white12,
          1,
        );
      }
      _drawText(
        "${(i * scale).toInt()}",
        Offset(x - 15, currentY),
        size: 14,
        align: TextAlign.right,
      );
    }
    return stepH;
  }

  void _drawRoundedRect(
    Rect rect,
    double radius,
    Color fill, {
    Color? stroke,
    double strokeWidth = 1,
    bool dashed = false,
  }) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );

    if (stroke != null) {
      final p = Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      if (dashed) {
        // Simple dash implementation for box
        Path path = Path()..addRRect(rrect);
        canvas.drawPath(_dashPath(path, 8, 8), p);
      } else {
        canvas.drawRRect(rrect, p);
      }
    }
  }

  Path _dashPath(Path source, double dashLength, double dashSpace) {
    Path dest = Path();
    for (PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        double len = draw ? dashLength : dashSpace;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  void _drawLine(
    Offset p1,
    Offset p2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    final p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    if (dashed) {
      Path path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy);
      canvas.drawPath(_dashPath(path, 8, 8), p);
    } else {
      canvas.drawLine(p1, p2, p);
    }
  }

  void _drawText(
    String text,
    Offset pos, {
    double size = 16,
    Color color = Colors.white,
    bool bold = false,
    bool italic = false,
    TextAlign align = TextAlign.center,
  }) {
    final span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        fontFamily: 'Plus Jakarta Sans',
      ),
      text: text,
    );
    final tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    double dx = pos.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;

    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  void _drawIcon(String type, Offset pos, double size, Color color) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(size / 24.0);
    canvas.translate(-12, -12);

    final Paint pFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Paint pStroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawPoly(List<Offset> pts, Color fColor, [Color? sColor]) {
      Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = fColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = sColor ?? Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      );
    }

    if (type == 'check') {
      Path path = Path()
        ..moveTo(6, 12)
        ..lineTo(10, 16)
        ..lineTo(18, 8);
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    } else if (type == 'cross') {
      canvas.drawLine(
        const Offset(8, 8),
        const Offset(16, 16),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        const Offset(16, 8),
        const Offset(8, 16),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    } else if (type == 'cricket') {
      canvas.drawRect(
        const Rect.fromLTWH(8, 2, 2, 20),
        Paint()..color = Colors.amber,
      );
      canvas.drawRect(const Rect.fromLTWH(8, 2, 2, 20), pStroke);
      canvas.drawRect(
        const Rect.fromLTWH(11, 2, 2, 20),
        Paint()..color = Colors.amber,
      );
      canvas.drawRect(const Rect.fromLTWH(11, 2, 2, 20), pStroke);
      canvas.drawRect(
        const Rect.fromLTWH(14, 2, 2, 20),
        Paint()..color = Colors.amber,
      );
      canvas.drawRect(const Rect.fromLTWH(14, 2, 2, 20), pStroke);
      canvas.drawCircle(const Offset(4, 10), 3, Paint()..color = Colors.red);
      canvas.drawCircle(const Offset(4, 10), 3, pStroke);
      canvas.save();
      canvas.translate(12, 12);
      canvas.rotate(-pi / 4);
      canvas.translate(-12, -12);
      canvas.drawRect(
        const Rect.fromLTWH(10, 8, 4, 14),
        Paint()..color = Colors.orange,
      );
      canvas.drawRect(const Rect.fromLTWH(10, 8, 4, 14), pStroke);
      canvas.restore();
    } else if (type == 'hockey') {
      drawPoly(const [
        Offset(12, 2),
        Offset(6, 18),
        Offset(2, 18),
        Offset(2, 21),
        Offset(8, 21),
        Offset(15, 2),
      ], Colors.orange);
      drawPoly(const [
        Offset(12, 2),
        Offset(18, 18),
        Offset(22, 18),
        Offset(22, 21),
        Offset(16, 21),
        Offset(9, 2),
      ], Colors.orange);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(9, 21, 6, 3),
          const Radius.circular(1.5),
        ),
        Paint()..color = Colors.indigoAccent,
      );
    } else if (type == 'kabaddi') {
      drawPoly(const [
        Offset(7, 4),
        Offset(9, 8),
        Offset(7, 10),
        Offset(5, 8),
      ], Colors.grey.shade300);
      drawPoly(const [
        Offset(13, 8),
        Offset(17, 7),
        Offset(19, 10),
        Offset(15, 11),
      ], Colors.grey.shade300);
      canvas.drawCircle(
        const Offset(6, 4),
        1.5,
        Paint()..color = Colors.grey.shade300,
      );
      canvas.drawCircle(
        const Offset(20, 6),
        1.5,
        Paint()..color = Colors.grey.shade300,
      );
      canvas.drawLine(const Offset(12, 2), const Offset(6, 22), pStroke);
    } else if (type == 'football') {
      canvas.drawCircle(const Offset(12, 12), 8, Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(12, 12), 8, pStroke);
      drawPoly(const [
        Offset(12, 7),
        Offset(15, 10),
        Offset(13, 15),
        Offset(9, 14),
        Offset(8, 10),
      ], Colors.black87);
    } else if (type == 'satoliya') {
      for (int i = 0; i < 7; i++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(12, 20 - i * 2.5),
            width: 16 - i * 1.6,
            height: 4,
          ),
          pStroke,
        );
      }
    } else if (type == 'jalebi') {
      canvas.drawCircle(
        const Offset(12, 12),
        6,
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        const Offset(12, 12),
        3,
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    } else if (type == 'gulab') {
      canvas.drawCircle(const Offset(12, 12), 7, Paint()..color = Colors.brown);
      canvas.drawCircle(
        const Offset(10, 10),
        1.5,
        Paint()..color = Colors.white54,
      );
    } else if (type == 'gujiya') {
      canvas.drawArc(
        const Rect.fromLTWH(4, 6, 16, 16),
        pi,
        pi,
        false,
        Paint()
          ..color = Colors.orangeAccent
          ..style = PaintingStyle.fill,
      );
      canvas.drawArc(const Rect.fromLTWH(4, 6, 16, 16), pi, pi, true, pStroke);
    } else if (type == 'barfi') {
      drawPoly(const [
        Offset(12, 4),
        Offset(20, 12),
        Offset(12, 20),
        Offset(4, 12),
      ], Colors.white);
    } else if (type == 'rasgulla') {
      canvas.drawCircle(const Offset(12, 12), 6, Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(12, 12), 7, pStroke..color = Colors.grey);
    } else if (type == 'avatar') {
      canvas.drawCircle(
        const Offset(12, 10),
        5,
        Paint()..color = Colors.orange.shade200,
      );
      canvas.drawCircle(const Offset(12, 10), 5, pStroke);
      Path hood = Path()
        ..moveTo(4, 24)
        ..quadraticBezierTo(4, 14, 12, 14)
        ..quadraticBezierTo(20, 14, 20, 24)
        ..close();
      canvas.drawPath(hood, Paint()..color = Colors.blue.shade200);
      canvas.drawPath(hood, pStroke);
      canvas.drawCircle(const Offset(10, 9), 0.8, pFill..color = Colors.black);
      canvas.drawCircle(const Offset(14, 9), 0.8, pFill);
    } else if (type == 'dog') {
      canvas.drawCircle(const Offset(12, 12), 6, Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(12, 12), 6, pStroke);
      drawPoly(const [
        Offset(7, 7),
        Offset(4, 16),
        Offset(7, 12),
      ], Colors.white);
      drawPoly(const [
        Offset(17, 7),
        Offset(20, 16),
        Offset(17, 12),
      ], Colors.white);
      canvas.drawCircle(const Offset(12, 13), 1.5, pFill..color = Colors.black);
    } else if (type == 'cat') {
      canvas.drawCircle(
        const Offset(12, 14),
        6,
        Paint()..color = Colors.orange,
      );
      canvas.drawCircle(const Offset(12, 14), 6, pStroke);
      drawPoly(const [
        Offset(7, 10),
        Offset(6, 4),
        Offset(11, 8),
      ], Colors.orange);
      drawPoly(const [
        Offset(17, 10),
        Offset(18, 4),
        Offset(13, 8),
      ], Colors.orange);
    } else if (type == 'fish') {
      Path f = Path()
        ..moveTo(6, 12)
        ..quadraticBezierTo(10, 4, 20, 12)
        ..quadraticBezierTo(10, 20, 6, 12)
        ..close();
      canvas.drawPath(f, Paint()..color = Colors.cyanAccent);
      canvas.drawPath(f, pStroke);
      drawPoly(const [
        Offset(6, 12),
        Offset(2, 8),
        Offset(2, 16),
      ], Colors.cyanAccent);
    } else if (type == 'bird') {
      canvas.drawCircle(
        const Offset(12, 12),
        5,
        Paint()..color = Colors.yellow,
      );
      canvas.drawCircle(const Offset(12, 12), 5, pStroke);
      drawPoly(const [
        Offset(16, 10),
        Offset(22, 12),
        Offset(16, 14),
      ], Colors.orange);
    } else {
      _drawText(
        type.substring(0, min(3, type.length)),
        const Offset(12, 12),
        size: 10,
        color: color,
      );
    }

    canvas.restore();
  }
}

// --- LOCALIZATION ---

const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': "Creating Bar Graphs: From Data to Display",
    'appTitle': "Creating Bar Graphs",
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
        "You have successfully learned to build, scale, and interpret Bar Graphs from raw data!",

    'lbl_drag': "DRAG",
    'lbl_freq': "Frequency",
    'lbl_scale': "Scale:",
    'lbl_axis_y': "Number",
    'lbl_axis_x': "Categories",
    'lbl_success': "SUCCESS!",
    'lbl_failure': "FAILURE",
    'lbl_check_work': "Check My Work",
    'lbl_present': "Present Findings",

    's1_title': "1. The Class's Favourite Game",
    's1_obj':
        "Convert a frequency table of favourite games into a bar graph with a 1-to-1 scale.",
    's1_step1_task':
        "DRAG the 'Cricket' icon from the table and DROP it onto the 'Data Input' slot.",
    's1_step1_out': "The 'Cricket' label appears on the horizontal axis.",
    's1_step2_task':
        "CLICK the 'Add Block' button 6 times to build the bar for Cricket.",
    's1_step2_out':
        "A bar made of 6 stacked blocks rises above the 'Cricket' label.",
    's1_step3_task':
        "DRAG the 'Hockey' icon from the table and DROP it onto the next 'Data Input' slot.",
    's1_step3_out': "The 'Hockey' label appears on the horizontal axis.",
    's1_step4_task':
        "CLICK the 'Add Block' button 8 times to build the bar for Hockey.",
    's1_step4_out': "A bar of 8 blocks is created.",
    's1_step5_task': "Observe the system auto-completing the graph.",
    's1_step5_out':
        "Great! The height of each bar shows the number of students.",
    's1_hud1': "Drag Cricket icon to the empty slot on the graph.",
    's1_hud2': "Click Add Block 6 times.",
    's1_hud3': "Drag Hockey icon to the next slot.",
    's1_hud4': "Click Add Block 8 times.",
    's1_hud5': "Watch the graph complete itself.",

    's2_title': "2. Shri Nilesh's Sweet Shop",
    's2_obj':
        "Build a bar graph using text input for faster block stacking on a 1-to-1 scale.",
    's2_step1_task':
        "DRAG the 'Jalebi' icon and DROP it onto the first 'Data Input' slot.",
    's2_step1_out': "The 'Jalebi' label appears.",
    's2_step2_task':
        "TYPE the number '6' into the 'Frequency Input' box and press Enter.",
    's2_step2_out': "A bar of 6 blocks instantly animates and stacks up.",
    's2_step3_task':
        "DRAG the 'Gulab Jamun' icon. TYPE '9' into the input box.",
    's2_step3_out': "A bar of 9 blocks is created.",
    's2_step4_task':
        "Complete the remaining sweets: Gujiya (13), Barfi (3), Rasgulla (7).",
    's2_step4_out': "Well done! Gujiya is the top choice!",
    's2_hud1': "Drag Jalebi icon to the first slot.",
    's2_hud2': "Type 6 and submit.",
    's2_hud3': "Drag Gulab Jamun and type 9.",
    's2_hud4': "Complete the rest of the sweets.",

    's3_title': "3. Smriti's Super Scores",
    's3_obj':
        "Understand the need for a scale when dealing with large numbers and build a scaled bar graph.",
    's3_step1_task': "TYPE the score for Match 1 ('80') into the input box.",
    's3_step1_out': "Whoa! That bar is too tall! A scale of 1 won't work.",
    's3_step2_task':
        "CLICK on the 'Scale Selector' tool. CHOOSE the scale '1 unit = 10 runs'.",
    's3_step2_out': "The vertical axis labels update to 10, 20, 30... 100.",
    's3_step3_task':
        "TYPE the score for Match 1 ('80') again with the new scale.",
    's3_step3_out': "A bar of 8 blocks stacks up (80 runs = 8 blocks).",
    's3_step4_task': "TYPE the score for Match 2 ('50').",
    's3_step4_out': "A bar of 5 blocks stacks up.",
    's3_step5_task': "Observe the system complete the graph for all 8 matches.",
    's3_step5_out': "Perfect! A scale helps fit large numbers.",
    's3_hud1': "Click the slot and type 80.",
    's3_hud2': "Select '1 unit = 10' scale.",
    's3_hud3': "Click the first slot and type 80 again.",
    's3_hud4': "Click the second slot and type 50.",
    's3_hud5': "Watch the graph complete.",

    's4_title': "4. Bhopal Railway Tickets",
    's4_obj':
        "Independently analyze data, choose a scale, and construct a bar graph.",
    's4_step1_task':
        "Examine the numbers (24, 20, 16, 28, 16) and CHOOSE the best scale.",
    's4_step1_out': "Scale of 4 is selected. The y-axis updates.",
    's4_step2_task':
        "DRAG 'Vidisha' to the first slot. TYPE '24' into the input box.",
    's4_step2_out': "A bar of 6 blocks (24/4) is created.",
    's4_step3_task':
        "Complete the graph for Jabalpur (20), Seoni (16), Indore (28), Sagar (16).",
    's4_step3_out': "The graph is populated with all cities.",
    's4_step4_task': "CLICK the 'Check My Work' button.",
    's4_step4_out': "Excellent work! You chose a good scale.",
    's4_hud1': "Choose the best scale.",
    's4_hud2': "Drag Vidisha and type 24.",
    's4_hud3': "Complete all remaining cities.",
    's4_hud4': "Click Check My Work.",

    's5_title': "5. My Classroom Survey",
    's5_obj': "Collect data, organize into a tally table, and build a graph.",
    's5_step1_task': "CHOOSE a survey question on the 'Question Board'.",
    's5_step1_out': "You selected 'Favourite Pet?'.",
    's5_step2_task': "CLICK on each of the 15 students to ask your question.",
    's5_step2_out': "Data collected! Speech bubbles show choices.",
    's5_step3_task':
        "DRAG the collected pet icons into the correct rows in the 'Tally Table'.",
    's5_step3_out': "Table organized: Dog(5), Cat(4), Fish(3), Bird(3).",
    's5_step4_task': "Use the table to build the bar graph.",
    's5_step4_out': "Graph constructed based on your data.",
    's5_step5_task': "CLICK the 'Present Findings' button.",
    's5_step5_out': "Fantastic! You've acted like a real researcher.",
    's5_hud1': "Click 'Favourite Pet' to start.",
    's5_hud2': "Click all 15 students.",
    's5_hud3': "Drag all floating icons into the matching table row.",
    's5_hud4': "Drag categories to X-axis and type their frequencies.",
    's5_hud5': "Click Present Findings.",
  },
  'hi': {
    'shutterTitle': "बार ग्राफ बनाना: डेटा से प्रदर्शन तक",
    'appTitle': "बार ग्राफ बनाना",
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
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'labCompleted': "लैब पूर्ण!",
    'finalDesc': "आपने बार ग्राफ़ बनाना सफलतापूर्वक सीख लिया है!",

    'lbl_drag': "खींचें",
    'lbl_freq': "आवृत्ति",
    'lbl_scale': "स्केल:",
    'lbl_axis_y': "संख्या",
    'lbl_axis_x': "श्रेणियाँ",
    'lbl_success': "सफलता!",
    'lbl_failure': "विफलता",
    'lbl_check_work': "मेरा काम जांचें",
    'lbl_present': "परिणाम प्रस्तुत करें",

    's1_title': "1. कक्षा का पसंदीदा खेल",
    's1_obj':
        "खेलों की आवृत्ति तालिका को 1-से-1 स्केल के साथ बार ग्राफ़ में बदलें।",
    's1_step1_task':
        "तालिका से 'क्रिकेट' आइकन खींचें और इसे 'डेटा इनपुट' स्लॉट पर छोड़ दें।",
    's1_step1_out': "क्षैतिज अक्ष पर 'क्रिकेट' लेबल दिखाई देता है।",
    's1_step2_task':
        "'क्रिकेट' के लिए बार बनाने के लिए 'ब्लॉक जोड़ें' बटन पर 6 बार क्लिक करें।",
    's1_step2_out':
        "6 स्टैक्ड ब्लॉकों से बना एक बार 'क्रिकेट' लेबल के ऊपर उठता है।",
    's1_step3_task':
        "तालिका से 'हॉकी' आइकन खींचें और इसे अगले 'डेटा इनपुट' स्लॉट पर छोड़ दें।",
    's1_step3_out': "'हॉकी' लेबल क्षैतिज अक्ष पर दिखाई देता है।",
    's1_step4_task':
        "'हॉकी' के लिए बार बनाने के लिए 'ब्लॉक जोड़ें' बटन पर 8 बार क्लिक करें।",
    's1_step4_out': "8 ब्लॉक्स का बार बनाया गया है।",
    's1_step5_task': "सिस्टम को ग्राफ़ स्वतः पूर्ण करते हुए देखें।",
    's1_step5_out': "बहुत बढ़िया! हॉकी सबसे लोकप्रिय है!",
    's1_hud1': "क्रिकेट आइकन को ग्राफ पर खाली स्लॉट पर खींचें।",
    's1_hud2': "ऐड ब्लॉक पर 6 बार क्लिक करें।",
    's1_hud3': "हॉकी आइकन को अगले स्लॉट पर खींचें।",
    's1_hud4': "ऐड ब्लॉक पर 8 बार क्लिक करें।",
    's1_hud5': "ग्राफ को स्वतः पूरा होते हुए देखें।",

    's2_title': "2. श्री नीलेश की मिठाई की दुकान",
    's2_obj': "तेजी से ग्राफ बनाने के लिए टेक्स्ट इनपुट का उपयोग करें।",
    's2_step1_task': "'जलेबी' आइकन को पहले स्लॉट पर खींचें।",
    's2_step1_out': "'जलेबी' लेबल दिखाई देता है।",
    's2_step2_task': "इनपुट बॉक्स में '6' टाइप करें और एंटर दबाएं।",
    's2_step2_out': "6 ब्लॉक्स का एक बार तुरंत एनिमेट होता है।",
    's2_step3_task':
        "'गुलाब जामुन' आइकन खींचें। इनपुट बॉक्स में '9' टाइप करें।",
    's2_step3_out': "9 ब्लॉक्स का बार बनता है।",
    's2_step4_task':
        "बाकी मिठाइयों को पूरा करें: गुझिया (13), बर्फी (3), रसगुल्ला (7)।",
    's2_step4_out': "शाबाश! गुझिया सबसे पसंदीदा है!",
    's2_hud1': "जलेबी आइकन को पहले स्लॉट पर खींचें।",
    's2_hud2': "6 टाइप करें और सबमिट करें।",
    's2_hud3': "गुलाब जामुन खींचें और 9 टाइप करें।",
    's2_hud4': "बाकी मिठाइयों को पूरा करें।",

    's3_title': "3. स्मृति के सुपर स्कोर्स",
    's3_obj': "बड़ी संख्याओं से निपटने के लिए स्केल की आवश्यकता को समझें।",
    's3_step1_task': "मैच 1 का स्कोर ('80') इनपुट बॉक्स में टाइप करें।",
    's3_step1_out': "वह बार बहुत लंबा है! स्केल बदलना होगा।",
    's3_step2_task':
        "'स्केल चयनकर्ता' टूल पर क्लिक करें। '1 यूनिट = 10 रन' स्केल चुनें।",
    's3_step2_out': "Y-अक्ष लेबल अपडेट हो गए हैं।",
    's3_step3_task': "नए स्केल के साथ फिर से '80' टाइप करें।",
    's3_step3_out': "8 ब्लॉक्स का बार बनता है।",
    's3_step4_task': "मैच 2 का स्कोर ('50') टाइप करें।",
    's3_step4_out': "5 ब्लॉक्स का बार बनता है।",
    's3_step5_task': "सिस्टम को ग्राफ पूरा करते हुए देखें।",
    's3_step5_out':
        "बिल्कुल सही! स्केल बड़ी संख्याओं को फिट करने में मदद करता है।",
    's3_hud1': "स्लॉट पर क्लिक करें और 80 टाइप करें।",
    's3_hud2': "'1 यूनिट = 10' स्केल चुनें।",
    's3_hud3': "पहले स्लॉट पर क्लिक करें और फिर से 80 टाइप करें।",
    's3_hud4': "दूसरे स्लॉट पर क्लिक करें और 50 टाइप करें।",
    's3_hud5': "ग्राफ को पूरा होते हुए देखें।",

    's4_title': "4. भोपाल रेलवे टिकट",
    's4_obj':
        "स्वतंत्र रूप से डेटा का विश्लेषण करें, स्केल चुनें और ग्राफ बनाएं।",
    's4_step1_task':
        "संख्याओं (24, 20, 16, 28, 16) की जांच करें और सबसे अच्छा स्केल चुनें।",
    's4_step1_out': "स्केल 4 चुना गया।",
    's4_step2_task':
        "'विदिशा' को पहले स्लॉट पर खींचें। इनपुट बॉक्स में '24' टाइप करें।",
    's4_step2_out': "6 ब्लॉक्स का बार बनता है।",
    's4_step3_task': "बाकी शहरों के लिए ग्राफ पूरा करें।",
    's4_step3_out': "ग्राफ सभी शहरों से भर गया है।",
    's4_step4_task': "'मेरा काम जांचें' बटन पर क्लिक करें।",
    's4_step4_out': "उत्कृष्ट कार्य! आपने ग्राफ पूरी तरह से बनाया।",
    's4_hud1': "सबसे अच्छा स्केल चुनें।",
    's4_hud2': "विदिशा खींचें और 24 टाइप करें।",
    's4_hud3': "सभी शेष शहरों को पूरा करें।",
    's4_hud4': "मेरा काम जांचें पर क्लिक करें।",

    's5_title': "5. मेरा कक्षा सर्वेक्षण",
    's5_obj': "डेटा एकत्र करें, तालिका में व्यवस्थित करें, और ग्राफ बनाएं।",
    's5_step1_task': "सर्वेक्षण प्रश्न चुनें।",
    's5_step1_out': "आपने 'पसंदीदा पालतू जानवर' चुना है।",
    's5_step2_task': "प्रश्न पूछने के लिए सभी 15 छात्रों पर क्लिक करें।",
    's5_step2_out': "डेटा एकत्र किया गया!",
    's5_step3_task': "आइकन को 'टैली टेबल' में खींचें।",
    's5_step3_out': "तालिका व्यवस्थित की गई।",
    's5_step4_task': "तालिका का उपयोग करके बार ग्राफ बनाएं।",
    's5_step4_out': "ग्राफ बनाया गया।",
    's5_step5_task': "'परिणाम प्रस्तुत करें' बटन पर क्लिक करें।",
    's5_step5_out': "शानदार! आपने एक वास्तविक शोधकर्ता की तरह काम किया है।",
    's5_hud1': "शुरू करने के लिए 'पसंदीदा पालतू जानवर' पर क्लिक करें।",
    's5_hud2': "उत्तर पाने के लिए सभी 15 छात्रों पर क्लिक करें।",
    's5_hud3': "सभी आइकनों को मेल खाती तालिका पंक्ति में खींचें।",
    's5_hud4':
        "ग्राफ बनाने के लिए श्रेणियों को खींचें और आवृत्तियों को टाइप करें।",
    's5_hud5': "परिणाम प्रस्तुत करें पर क्लिक करें।",
  },
};
