// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// Ensure you add `audioplayers: ^5.2.1` to your pubspec.yaml

class MeasuresofCentralTendencyMedianandOutliers extends StatefulWidget {
  const MeasuresofCentralTendencyMedianandOutliers({Key? key}) : super(key: key);

  @override
  State<MeasuresofCentralTendencyMedianandOutliers> createState() =>
      _MeasuresofCentralTendencyMedianandOutliersState();
}

class _MeasuresofCentralTendencyMedianandOutliersState
    extends State<MeasuresofCentralTendencyMedianandOutliers>
    with TickerProviderStateMixin {
  bool _showShutter = true;
  bool _isSidebarOpen = false;
  String _currentLanguage = 'en'; // 'en', 'hi', 'te'
  int _currentScenario = 1;
  int _step = 0;

  // Viewport/Canvas state
  double _zoom = 1.0;
  double _baseZoom = 1.0;
  Offset _panOffset = Offset.zero;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation for the machine
  late AnimationController _machineAnimController;
  late AnimationController _pulseController;

  // Simulation State
  SimState sim = SimState();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _machineAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          sim.animProgress = _machineAnimController.value;
        });
        if (_machineAnimController.isCompleted &&
            _currentScenario == 2 &&
            _step == 2) {
          _advanceStepFromAnimation();
          
          // Auto advance from "Observe" step after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _currentScenario == 2 && _step == 3) {
              _advanceStep();
            }
          });
        }
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

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
    _audioPlayer.dispose();
    _machineAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      String url = '';
      switch (type) {
        case 'click':
          url = 'audio/class7/mixkit_2568.mp3';
          break;
        case 'success':
          url = 'audio/class7/mixkit_2018.mp3';
          break;
        case 'error':
          url = 'audio/class7/mixkit_2570.mp3';
          break;
        case 'snap':
          url = 'audio/class7/mixkit_392.mp3';
          break;
        case 'heavy':
          url = 'audio/class7/mixkit_2574.mp3';
          break;
        case 'whir':
          url = 'audio/class7/mixkit_2723.mp3';
          break;
      }
      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      // Ignore audio errors gracefully
    }
  }

  void _toggleLanguage() {
    _playSound('click');
    setState(() {
      if (_currentLanguage == 'en') {
        _currentLanguage = 'hi';
      } else {
        _currentLanguage = 'en';
      }
      _updateHUDForStep();
    });
  }

  void _resetSimulation() {
    _playSound('click');
    setState(() {
      _showShutter = true;
      _currentLanguage = 'en';
      _currentScenario = 1;
      _loadScenario(1);
    });
  }

  void _startActivity() {
    _playSound('success');
    setState(() {
      _showShutter = false;
      _isSidebarOpen = true;
      _updateHUDForStep();
    });
  }

  void _updateHUDForStep() {
    if (sim.isCompleted) {
      sim.hudMessage = _currentScenario < 5 ? t('hud_scenario_complete') : t('finalSuccessDesc');
    } else {
      sim.hudMessage = t('s${_currentScenario}_step${_step}_task');
    }
  }

  void _advanceStepFromAnimation() {
    double v1 = sim.machine!.slot1!.val;
    double v2 = sim.machine!.slot2!.val;
    double avg = (v1 + v2) / 2;

    sim.sources.removeWhere((s) => s == sim.machine!.slot1 || s == sim.machine!.slot2);
    sim.sources.add(SimItem(
      id: 99,
      val: avg,
      type: 'child',
      x: sim.machine!.x,
      y: sim.machine!.y + 160,
      currentY: sim.machine!.y + 160 - 17,
      isAverage: true,
      inMachine: false,
    ));
    _advanceStep();
  }

  void _advanceStep() {
    _playSound('success');
    setState(() {
      _step++;
      _checkCompletion();
      _updateHUDForStep();
    });
  }

  void _checkCompletion() {
    int maxSteps = _getMaxSteps(_currentScenario);
    if (_step >= maxSteps) {
      sim.isCompleted = true;
      if (_currentScenario == 5) {
        _showSuccessPopup();
      }
    }
  }

  int _getMaxSteps(int scenario) {
    if (scenario == 1) return 2;
    if (scenario == 2) return 4; // 0: arrange, 1: click, 2: drag to machine, 3: view
    if (scenario == 3) return 6;
    if (scenario == 4) return 3;
    if (scenario == 5) return 3;
    return 2;
  }

  void _loadScenario(int scenarioId) {
    setState(() {
      _currentScenario = scenarioId;
      _step = 0;
      sim = SimState();
      _machineAnimController.reset();

      List<double> values = [];
      String type = 'child';

      if (scenarioId == 1) {
        values = [130, 150, 110, 140, 120];
      } else if (scenarioId == 2) {
        values = [120, 160, 110, 130, 150, 140];
      } else if (scenarioId == 3) {
        values = [160, 165, 175, 155, 110];
        type = 'family';
      } else if (scenarioId == 4) {
        values = [120, 130, 140, 160, 170, 5280];
        type = 'coin';
      } else if (scenarioId == 5) {
        values = [15.0, 15.2, 15.5, 15.8, 16.1, 16.5, 45.0];
        type = 'time';
      }

      for (int i = 0; i < values.length; i++) {
        sim.sources.add(SimItem(id: i, val: values[i], type: type));
      }

      if (scenarioId == 1 || scenarioId == 2) {
        double pSpacing = 85;
        double pStartX = -((values.length - 1) * pSpacing) / 2;
        for (int i = 0; i < values.length; i++) {
          sim.podiums.add(SimPodium(id: i, x: pStartX + (i * pSpacing), y: 150));
        }
        double spread = scenarioId == 2 ? 110 : 125;
        double cStartX = -((values.length - 1) * spread) / 2;
        for (int i = 0; i < sim.sources.length; i++) {
          sim.sources[i].x = cStartX + i * spread;
          sim.sources[i].y = 280 - 17;
          sim.sources[i].startX = sim.sources[i].x;
          sim.sources[i].startY = sim.sources[i].y;
          sim.sources[i].currentY = sim.sources[i].y;
        }
        if (scenarioId == 2) {
          sim.machine = SimMachine(x: 0, y: -280);
        }
      } else if (scenarioId == 3) {
        double pSpacing = 75;
        double pStartX = 110;
        for (int i = 0; i < values.length; i++) {
          sim.podiums.add(SimPodium(id: i, x: pStartX + (i * pSpacing), y: 150));
        }
        for (int i = 0; i < sim.sources.length; i++) {
          sim.sources[i].x = -150 + i * 110;
          if (i > 2) sim.sources[i].x = -100 + (i - 3) * 130;
          sim.sources[i].y = 280 - 17;
          sim.sources[i].startX = sim.sources[i].x;
          sim.sources[i].startY = sim.sources[i].y;
          sim.sources[i].currentY = sim.sources[i].y;
          sim.sources[i].blockX = sim.sources[i].x + 40;
          sim.sources[i].blockY = sim.sources[i].y + 17;
          sim.sources[i].blockStartX = sim.sources[i].blockX;
          sim.sources[i].blockStartY = sim.sources[i].blockY;
        }
        sim.scale = SimScale(x: -260, y: 50, pointerVal: 100, min: 100, max: 250);
      } else if (scenarioId == 4) {
        double pSpacing = 70;
        double pStartX = 100;
        for (int i = 0; i < values.length; i++) {
          sim.podiums.add(SimPodium(id: i, x: pStartX + (i * pSpacing), y: 150));
        }
        for (int i = 0; i < sim.sources.length; i++) {
          if (i < 5) {
            sim.sources[i].x = -450 + i * 85;
            sim.sources[i].y = 260 - 17;
          } else {
            sim.sources[i].x = 240;
            sim.sources[i].y = -80;
          }
          sim.sources[i].startX = sim.sources[i].x;
          sim.sources[i].startY = sim.sources[i].y;
          sim.sources[i].currentY = sim.sources[i].y;
          sim.sources[i].blockX = sim.sources[i].x;
          sim.sources[i].blockY = sim.sources[i].y + 40;
          if (i == 5) {
            sim.sources[i].blockX = 240;
            sim.sources[i].blockY = -75;
          }
          sim.sources[i].blockStartX = sim.sources[i].blockX;
          sim.sources[i].blockStartY = sim.sources[i].blockY;
        }
        sim.scale = SimScale(x: -280, y: 50, pointerVal: 100, min: 100, max: 1200);
      } else if (scenarioId == 5) {
        double pSpacing = 65;
        double pStartX = 40;
        for (int i = 0; i < values.length; i++) {
          sim.podiums.add(SimPodium(id: i, x: pStartX + (i * pSpacing), y: 150));
        }
        for (int i = 0; i < sim.sources.length; i++) {
          sim.sources[i].x = -350 + i * 110;
          sim.sources[i].y = 280 - 17;
          sim.sources[i].startX = sim.sources[i].x;
          sim.sources[i].startY = sim.sources[i].y;
          sim.sources[i].currentY = sim.sources[i].y;
          sim.sources[i].blockX = sim.sources[i].x;
          sim.sources[i].blockY = sim.sources[i].y - 70;
          sim.sources[i].blockStartX = sim.sources[i].blockX;
          sim.sources[i].blockStartY = sim.sources[i].blockY;
        }
        sim.scale = SimScale(x: -280, y: 50, pointerVal: 10, min: 10, max: 50);
      }

      _panOffset = Offset.zero;
      _zoom = 1.0;
      _updateHUDForStep();
    });
  }

  void _showSuccessPopup() {
    _playSound('success');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.all(24),
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
                  const SizedBox(height: 10),
                  Text(
                    t('finalSuccessTitle'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          content: Text(
            t('finalSuccessDesc'),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _resetSimulation();
              },
              icon: const Icon(Icons.refresh),
              label: Text(t('finalRestartBtn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            )
          ],
        );
      },
    );
  }

  // ---- Hit Testing & Drag Logic ----
  SimItem? _draggedItem;
  String _dragType = ''; 
  double _dragOffsetX = 0.0;
  double _dragOffsetY = 0.0;

  Offset _getWorldPosition(Offset local) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset center = Offset(box.size.width / 2, box.size.height / 2);
    return (local - center - _panOffset) / _zoom;
  }

  bool _hitTestRectCenter(double x, double y, double w, double h, Offset pt, {double tol = 50.0}) {
    return pt.dx >= x - w / 2 - tol && pt.dx <= x + w / 2 + tol && pt.dy >= y - h / 2 - tol && pt.dy <= y + h / 2 + tol;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _zoom;
    if (sim.isCompleted || sim.animProgress > 0) return;
    Offset pt = _getWorldPosition(details.localFocalPoint);

    // 1. Check Outlier Remove S5 Step 2
    if (_currentScenario == 5 && _step == 2 && !sim.outlierRemoved) {
      try {
        SimItem slowRunner = sim.sources.firstWhere((s) => s.val == 45.0 && s.type != 'label');
        if (_hitTestRectCenter(slowRunner.x, slowRunner.y - 60, 120, 200, pt) ||
            _hitTestRectCenter(slowRunner.blockX, slowRunner.blockY, 120, 100, pt)) {
          _playSound('click');
          setState(() {
            sim.outlierRemoved = true;
            sim.sources.remove(slowRunner);
            sim.scale!.items.remove(slowRunner.id);
            if (slowRunner.inPodium != null) {
              sim.podiums[slowRunner.inPodium!].item = null;
            }

            double sum = sim.sources.where((s) => s.type == 'time').fold(0.0, (a, b) => a + b.val);
            sim.scale!.trueMean = sum / 6;
            sim.scale!.pointerVal = sim.scale!.trueMean;

            List<SimItem> remainingTimes = sim.sources.where((s) => s.type == 'time').toList()..sort((a, b) => a.val.compareTo(b.val));
            for (var p in sim.podiums) p.item = null;
            for (int i = 0; i < remainingTimes.length; i++) {
              sim.podiums[i].item = remainingTimes[i];
              remainingTimes[i].inPodium = i;
              double stepH = 40 + (i * 20);
              remainingTimes[i].blockX = sim.podiums[i].x;
              remainingTimes[i].blockY = sim.podiums[i].y - stepH;
            }

            try {
              SimItem meanLbl = sim.sources.firstWhere((s) => s.id == 'lbl_mean');
              meanLbl.labelStr = "Mean: ${(sum / 6).toStringAsFixed(1)}s";
            } catch (_) {}
            try {
              SimItem medLbl = sim.sources.firstWhere((s) => s.id == 'lbl_med');
              medLbl.labelStr = "Median: 15.7s";
            } catch (_) {}

            _advanceStep(); 
          });
          return;
        }
      } catch (_) {}
    }

    // 2. Drag Labels in S5 Step 1
    if (_currentScenario == 5 && _step == 1) {
      for (var s in sim.sources) {
        if (s.type == 'label' && _hitTestRectCenter(s.x, s.y, 130, 40, pt)) {
          _draggedItem = s;
          _dragType = 'label';
          _dragOffsetX = s.x - pt.dx;
          _dragOffsetY = s.y - pt.dy;
          _playSound('click');
          return;
        }
      }
    }

    // 3. Check Scale Pointer
    if (sim.scale != null) {
      int reqStep = _currentScenario == 3 ? (sim.outlierAdded ? 5 : 1) : -1;
      if (_step == reqStep) {
        double range = sim.scale!.max - sim.scale!.min;
        double beamLen = _currentScenario >= 3 ? 180 : 360;
        double ptrX = sim.scale!.x + (sim.scale!.pointerVal - sim.scale!.min) * (beamLen / range);
        if (_hitTestRectCenter(ptrX, sim.scale!.y + 45, 60, 60, pt)) {
          _draggedItem = SimItem(id: -1, val: 0, type: 'pointer')..x = pt.dx..y = pt.dy;
          _dragType = 'pointer';
          _dragOffsetX = 0.0;
          _dragOffsetY = 0.0;
          return;
        }
      }
    }

    // 4. Drag off scale pan
    if (sim.scale != null && sim.scale!.items.isNotEmpty) {
      bool canDragOff = false;
      if (_currentScenario == 3 && (_step == 0 || _step == 4 || _step == 5)) canDragOff = true;
      if (_currentScenario == 4 && (_step == 0 || _step == 1)) canDragOff = true;
      if (_currentScenario == 5 && _step == 0) canDragOff = true;

      if (canDragOff) {
        double panX = _currentScenario >= 4 ? -110 : -100;
        if (_hitTestRectCenter(sim.scale!.x + panX, sim.scale!.y + 60, 160, 120, pt)) {
          int topId = sim.scale!.items.removeLast();
          SimItem src = sim.sources.firstWhere((s) => s.id == topId);
          src.inScale = false;
          src.blockInScale = false;
          _draggedItem = src;
          _dragType = (_currentScenario >= 3) ? 'block' : 'item';
          
          if (_dragType == 'block') {
             _dragOffsetX = src.blockX - pt.dx;
             _dragOffsetY = src.blockY - pt.dy;
          } else {
             _dragOffsetX = src.x - pt.dx;
             _dragOffsetY = src.currentY - pt.dy;
          }
          
          _playSound('click');
          return;
        }
      }
    }

    // 5. Drag sources (Blocks or Items)
    bool canDragItems = false;
    if (_currentScenario == 1 && _step == 0) canDragItems = true;
    if (_currentScenario == 2 && (_step == 0 || _step == 2)) canDragItems = true;
    if (_currentScenario == 3 && (_step == 0 || _step == 2 || _step == 4 || _step == 5)) canDragItems = true;
    if (_currentScenario == 4 && (_step == 0 || _step == 1)) canDragItems = true;
    if (_currentScenario == 5 && _step == 0) canDragItems = true;

    if (canDragItems) {
      for (int i = sim.sources.length - 1; i >= 0; i--) {
        SimItem src = sim.sources[i];
        if (src.type == 'label') continue;
        if (_currentScenario == 2 && _step == 2 && (src.inPodium != 2 && src.inPodium != 3)) continue;

        if (!src.blockInScale) {
          bool canDragBlock = false;
          if (_currentScenario == 3 && (_step == 0 || _step == 4 || _step == 5)) canDragBlock = true;
          if (_currentScenario == 4 && (_step == 0 || _step == 1)) canDragBlock = true;
          if (_currentScenario == 5 && _step == 0) canDragBlock = true;

          if (canDragBlock) {
            double hitH = 120, hitW = 100, hitY = src.blockY - 60;
            if (_currentScenario == 3 && src.isOutlier) { hitH = 180; hitY = src.blockY - 90; }
            if (_currentScenario == 4 && src.val > 1000) { hitH = 180; hitY = src.blockY - 90; }
            if (_currentScenario == 5) { hitH = 60; hitW = 80; hitY = src.blockY; }

            if (_hitTestRectCenter(src.blockX, hitY, hitW, hitH + 40, pt)) {
              _draggedItem = src;
              _dragType = 'block';
              _dragOffsetX = src.blockX - pt.dx;
              _dragOffsetY = src.blockY - pt.dy;
              if (_currentScenario >= 4 && src.inPodium != null) {
                sim.podiums[src.inPodium!].item = null;
                src.inPodium = null;
              }
              _playSound('click');
              return;
            }
          }
        }

        bool allowPersonDrag = (_currentScenario != 3) || (_currentScenario == 3 && (_step == 2 || _step == 5));
        if (_currentScenario >= 4) allowPersonDrag = false;
        bool isDraggableFromPodium = false;
        if (_currentScenario == 2 && _step == 2 && (src.inPodium == 2 || src.inPodium == 3)) isDraggableFromPodium = true;
        if (_currentScenario == 3 && _step == 5 && src.inPodium != null) isDraggableFromPodium = true;

        double hitH = 160;
        double actualY = src.inPodium != null ? src.currentY : src.y;

        if (allowPersonDrag &&
            (src.inPodium == null || src.inScale || isDraggableFromPodium) &&
            _hitTestRectCenter(src.x, actualY - hitH / 2 + 10, 100, hitH + 20, pt)) {
          _draggedItem = src;
          _dragType = 'item';
          _dragOffsetX = src.x - pt.dx;
          _dragOffsetY = actualY - pt.dy;
          if (src.inPodium != null) {
            sim.podiums[src.inPodium!].item = null;
            src.inPodium = null;
          }
          if (src.inMachine && sim.machine != null) {
             if (sim.machine!.slot1 == src) sim.machine!.slot1 = null;
             if (sim.machine!.slot2 == src) sim.machine!.slot2 = null;
             src.inMachine = false;
          }
          _playSound('click');
          return;
        }
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_draggedItem != null) {
      Offset pt = _getWorldPosition(details.localFocalPoint);
      setState(() {
        if (_dragType == 'item' || _dragType == 'label') {
          _draggedItem!.x = pt.dx + _dragOffsetX;
          _draggedItem!.y = pt.dy + _dragOffsetY;
          _draggedItem!.currentY = pt.dy + _dragOffsetY;
        } else if (_dragType == 'block') {
          _draggedItem!.blockX = pt.dx + _dragOffsetX;
          _draggedItem!.blockY = pt.dy + _dragOffsetY;
        } else if (_dragType == 'pointer') {
          double minV = sim.scale!.min;
          double maxV = sim.scale!.max;
          double range = maxV - minV;
          double beamLen = _currentScenario >= 3 ? 180 : 360;
          double val = minV + (pt.dx - sim.scale!.x) / (beamLen / range);
          sim.scale!.pointerVal = max(minV, min(maxV, val));
        }
      });
    } else {
      setState(() {
        if (details.pointerCount > 1) {
          _zoom = (_baseZoom * details.scale).clamp(0.2, 3.0);
        }
        _panOffset += details.focalPointDelta;
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggedItem == null) return;
    Offset pt = Offset(_draggedItem!.x, _draggedItem!.y);
    if (_dragType == 'block') {
      pt = Offset(_draggedItem!.blockX, _draggedItem!.blockY);
    }

    setState(() {
      if (_dragType == 'pointer') {
        double sum = sim.scale!.items.fold(0, (acc, id) {
          try { return acc + sim.sources.firstWhere((x) => x.id == id).val; } catch (_) { return acc; }
        });
        int count = sim.scale!.items.length;
        if (count > 0) {
          sim.scale!.trueMean = sum / count;
          double tolerance = _currentScenario == 4 ? 35 : 4;
          if (_currentScenario == 5) tolerance = 0.5;

          if ((sim.scale!.pointerVal - sim.scale!.trueMean).abs() < tolerance) {
            sim.scale!.pointerVal = sim.scale!.trueMean;
            _playSound('success');

            if (_currentScenario == 3 && _step == 1) _advanceStep();
            if (_currentScenario == 3 && _step == 5) {
              sim.s3MeanFound = true;
              _checkS3Complete();
            }
            if (_currentScenario == 4 && _step == 1 && count == 6) {
              sim.s4MeanFound = true;
              _checkS4ToolsReady();
            }
            if (_currentScenario == 5 && _step == 0 && count == 7) {
              sim.s5MeanFound = true;
              _checkS5ToolsReady();
            }
          } else {
            _playSound('error');
          }
        }
      } else if (_dragType == 'label') {
        if (_hitTestRectCenter(300, -140, 160, 90, pt)) {
          if (_draggedItem!.isMedian) {
            _draggedItem!.x = 300;
            _draggedItem!.y = -140;
            _draggedItem!.currentY = -140;
            _playSound('success');
            _advanceStep(); 
          } else {
            _playSound('error');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('err_choice'))));
            _draggedItem!.x = _draggedItem!.startX;
            _draggedItem!.y = _draggedItem!.startY;
            _draggedItem!.currentY = _draggedItem!.startY;
          }
        } else {
          _draggedItem!.x = _draggedItem!.startX;
          _draggedItem!.y = _draggedItem!.startY;
          _draggedItem!.currentY = _draggedItem!.startY;
          _playSound('click');
        }
      } else {
        bool snapped = false;

        if (_currentScenario == 2 && _step == 2 && sim.machine != null) {
          if (_hitTestRectCenter(sim.machine!.x, sim.machine!.y, 300, 240, pt)) {
            if (sim.machine!.slot1 == null) {
              sim.machine!.slot1 = _draggedItem;
              snapped = true;
            } else if (sim.machine!.slot2 == null) {
              sim.machine!.slot2 = _draggedItem;
              snapped = true;
            }
            if (snapped) {
              _draggedItem!.inMachine = true;
              _draggedItem!.x = sim.machine!.x + (sim.machine!.slot2 == _draggedItem ? 40 : -40);
              _draggedItem!.y = sim.machine!.y + 10;
              _draggedItem!.currentY = _draggedItem!.y;
              _playSound('snap');
              if (sim.machine!.slot1 != null && sim.machine!.slot2 != null) {
                _playSound('whir');
                _machineAnimController.forward(from: 0.0);
              }
            }
          }
        }

        // Expanded drop area to ensure smooth block dropping
        if (sim.scale != null && _hitTestRectCenter(sim.scale!.x - 100, sim.scale!.y + 60, 240, 240, pt) && _dragType == 'block') {
          if (_currentScenario == 3 && (_step == 0 || _step == 4 || _step == 5)) {
            _draggedItem!.blockInScale = true;
            if (!sim.scale!.items.contains(_draggedItem!.id)) sim.scale!.items.add(_draggedItem!.id);
            snapped = true;
            _playSound(_draggedItem!.isOutlier ? 'heavy' : 'snap');
            if (_step == 0 && sim.scale!.items.length == 5) _advanceStep();
            if (_step == 4 && _draggedItem!.isOutlier) _advanceStep();
          } else if (_currentScenario == 4 && (_step == 0 || _step == 1)) {
            _draggedItem!.blockInScale = true;
            _draggedItem!.inScale = true;
            if (!sim.scale!.items.contains(_draggedItem!.id)) sim.scale!.items.add(_draggedItem!.id);
            snapped = true;
            _playSound('snap');
            _checkS4InitialStep();
            _checkS4ToolsReady();
          } else if (_currentScenario == 5 && _step == 0) {
            _draggedItem!.blockInScale = true;
            _draggedItem!.inScale = true;
            if (!sim.scale!.items.contains(_draggedItem!.id)) sim.scale!.items.add(_draggedItem!.id);
            snapped = true;
            _playSound('snap');
            _checkS5ToolsReady();
          }
        }

        bool canSnapToPodium = (_currentScenario == 1 || _currentScenario == 2 || (_currentScenario == 3 && _dragType == 'item') || (_currentScenario == 4 && _dragType == 'block') || (_currentScenario == 5 && _dragType == 'block'));
        if (!snapped && !_draggedItem!.inMachine && canSnapToPodium) {
          for (int i = 0; i < sim.podiums.length; i++) {
            SimPodium p = sim.podiums[i];
            if (p.item == null && _hitTestRectCenter(p.x, p.y - 40, 160, 260, pt)) {
              List<double> sortedVals = sim.sources.where((s) => s.type != 'label' && !s.isAverage).map((s) => s.val).toList()..sort();
              if (_draggedItem!.val == sortedVals[i]) {
                p.item = _draggedItem;
                _draggedItem!.inPodium = i;
                double stepH = 40 + (i * (_currentScenario == 3 ? 15 : 20));
                _draggedItem!.stepH = stepH;

                if (_currentScenario >= 4) {
                  _draggedItem!.blockX = p.x;
                  _draggedItem!.blockY = p.y - stepH;
                  if (_currentScenario == 4) _checkS4InitialStep();
                } else {
                  _draggedItem!.x = p.x;
                  _draggedItem!.y = p.y;
                  _draggedItem!.currentY = p.y - stepH - 17;
                }
                snapped = true;
                _playSound('success');
              } else {
                _playSound('error');
              }
              break;
            }
          }
        }

        if (!snapped) {
          if (_currentScenario >= 4) {
            _draggedItem!.blockX = _draggedItem!.blockStartX;
            _draggedItem!.blockY = _draggedItem!.blockStartY;
          } else {
            _draggedItem!.x = _draggedItem!.startX;
            _draggedItem!.y = _draggedItem!.startY;
            _draggedItem!.currentY = _draggedItem!.startY;
          }
          _playSound('click');
        }

        bool allPodiumsFull = sim.podiums.every((p) => p.item != null);
        if (allPodiumsFull) {
          bool sorted = true;
          for (int i = 0; i < sim.podiums.length - 1; i++) {
            if (sim.podiums[i].item!.val > sim.podiums[i + 1].item!.val) {
              sorted = false;
              break;
            }
          }
          if (sorted) {
            if (_currentScenario == 1 && _step == 0) _advanceStep();
            if (_currentScenario == 2 && _step == 0) _advanceStep();
            if (_currentScenario == 3 && _step == 2) _advanceStep();
            if (_currentScenario == 3 && _step == 5) _checkS3Complete();
            if (_currentScenario == 4 && _step == 1) {
              sim.s4MedianFound = true;
              _checkS4ToolsReady();
            }
            if (_currentScenario == 5 && _step == 0) {
              sim.s5MedianFound = true;
              _checkS5ToolsReady();
            }
          }
        }
      }

      _draggedItem = null;
      _dragType = '';
    });
  }

  void _checkS3Complete() {
    if (_currentScenario != 3) return;
    bool allPodiumsFull = sim.podiums.every((p) => p.item != null);
    if (sim.s3MeanFound && allPodiumsFull && _step == 5) {
      _advanceStep();
    }
  }

  void _checkS4InitialStep() {
    if (_currentScenario != 4 || _step != 0) return;
    bool scaleHasItems = sim.scale!.items.length == 6;
    bool podiumsFull = sim.podiums.every((p) => p.item != null);
    if (scaleHasItems && podiumsFull) {
      _advanceStep();
      _checkS4ToolsReady();
    }
  }

  void _checkS4ToolsReady() {
    if (_currentScenario != 4) return;
    if (sim.s4MeanFound && sim.s4MedianFound && _step == 1) {
      _advanceStep();
    }
  }

  void _checkS5ToolsReady() {
    if (_currentScenario != 5) return;
    if (sim.s5MeanFound && sim.s5MedianFound && _step == 0) {
      _advanceStep();
      _spawnLabelsS5();
    }
  }

  void _spawnLabelsS5() {
    if (!sim.labelsSpawned) {
      setState(() {
        sim.labelsSpawned = true;
        double meanVal = sim.sources.where((s) => s.type == 'time').map((e) => e.val).fold(0.0, (a, b) => a + b) / 7;
        sim.sources.add(SimItem(id: 'lbl_mean', val: 0, type: 'label', isMedian: false)
          ..labelStr = "Mean: ${meanVal.toStringAsFixed(1)}s"
          ..x = 150..y = -100..currentY = -100..startX = 150..startY = -100);
        sim.sources.add(SimItem(id: 'lbl_med', val: 0, type: 'label', isMedian: true)
          ..labelStr = "Median: 15.8s"
          ..x = 150..y = -40..currentY = -40..startX = 150..startY = -40);
      });
    }
  }

  void _updateSimPerFrame() {
    if (sim.scale != null && (_currentScenario == 4 || _currentScenario == 5)) {
      double sum = sim.scale!.items.fold(0, (acc, id) {
        try { return acc + sim.sources.firstWhere((x) => x.id == id).val; } catch (_) { return acc; }
      });
      int count = sim.scale!.items.length;
      double targetVal = count > 0 ? sum / count : sim.scale!.min;

      if (_currentScenario == 5 && _step >= 1 && sim.s5MeanFound) {
        targetVal = sim.outlierRemoved ? 15.7 : 19.9;
      } else if (_currentScenario == 4 && _step >= 1 && sim.s4MeanFound) {
        targetVal = 1000;
      }

      if ((sim.scale!.pointerVal - targetVal).abs() > 0.1) {
        sim.scale!.pointerVal += (targetVal - sim.scale!.pointerVal) * 0.15;
      } else {
        sim.scale!.pointerVal = targetVal;
      }

      if (_currentScenario == 4 && count == 6 && !sim.s4MeanFound) {
        sim.s4MeanFound = true;
        if (_step >= 1) _checkS4ToolsReady();
      }
      if (_currentScenario == 5 && count == 7 && _step == 0 && !sim.s5MeanFound) {
        sim.s5MeanFound = true;
        _checkS5ToolsReady();
      }
    }
  }

  // --- Translations ---
  String t(String key) {
    Map<String, String> currentMap = _currentLanguage == 'hi' ? _hi : _en;
    return currentMap[key] ?? _en[key] ?? key;
  }

  final Map<String, String> _en = {
    'shutterTitle': 'Measures of Central Tendency:\nThe Unshakeable Median',
    'appSubtitle': 'Class 7 • CONNECTING THE DOTS...',
    'enterLab': 'Enter Lab',
    'targetOutput': 'Target Output',
    's1_title': '1. Height Line-Up (Odd)',
    's2_title': '2. Height Line-Up (Even)',
    's3_title': '3. Scale of Averages',
    's4_title': '4. CEO\'s Salary',
    's5_title': '5. Race Time Report',
    'btnFindMedian': 'Find Median',
    'btnSpawnOutlier': 'Add Outlier',
    'btnMean': 'Mean',
    'btnMedian': 'Median',
    'lblChoicePrompt': 'Which is the better representative typical value?',
    'err_choice': 'Are you sure? Try again.',
    'finalSuccessTitle': 'Activity Completed!',
    'finalSuccessDesc': 'You have mastered Medians and Outliers!',
    'finalRestartBtn': 'Restart Activity',
    'board_title': 'THE UNSHAKEABLE MEDIAN',
    'board_desc1': 'Median is the physical Middle Value of ordered data.',
    'board_desc2': 'Formula (Odd): Middle | (Even): Avg of Middle 2',
    'label_balance_scale': 'BALANCE SCALE',
    'label_lineup_platform': 'LINE-UP PLATFORM',
    'label_median_height': 'MEDIAN HEIGHT',
    'label_mean_equals': 'Mean = ',
    'label_median_equals': 'Median = ',
    'label_averaging_machine': 'AVERAGING MACHINE',
    'label_mean_salary': 'Mean Salary: \$1,000,000',
    'label_median_salary': 'Median Salary: \$150,000',
    's3_card_title': 'IMPACT OF OUTLIER',
    's3_card_without': 'WITHOUT OUTLIER',
    's3_card_heights_1': 'Heights: 110, 155, 160, 165, 175 cm',
    's3_card_mean_1': 'Mean = 153 cm',
    's3_card_median_1': 'Median = 160 cm',
    's3_card_with': 'WITH BASKETBALL OUTLIER',
    's3_card_heights_2': 'Heights: 155, 160, 165, 175, 220 cm',
    's3_card_mean_2': 'Mean = 175 cm (+22cm! 🚀)',
    's3_card_median_2': 'Median = 165 cm (+5cm! ⚖️)',
    's3_card_learn': 'Outliers pull the Mean drastically but barely move the Median!',
    'hud_scenario_complete': 'Scenario Completed! Select the next one from the sidebar.',
    
    // Scenario Objectives
    's1_obj': 'To understand the median as the physical middle value in an ordered set of data.',
    's2_obj': 'To learn how to calculate the median for an even-numbered data set.',
    's3_obj': 'To visually demonstrate how an outlier drastically affects the mean but not the median.',
    's4_obj': 'To apply understanding of mean, median, and outliers to find a typical company salary.',
    's5_obj': 'To identify an outlier and justify the use of the median.',

    // Detailed Steps (Task, Obs, Learn)
    's1_step0_task': 'Arrange the 5 children on the podiums from shortest to tallest.',
    's1_step0_obs': 'The children are ordered in ascending height.',
    's1_step0_learn': 'Data must be sorted before finding the median.',
    's1_step1_task': 'Click the "Find Median" button.',
    's1_step1_obs': 'The child in the exact middle is highlighted.',
    's1_step1_learn': 'The median splits the group perfectly in half.',
    
    's2_step0_task': 'Arrange the 6 children on the podiums from shortest to tallest.',
    's2_step0_obs': 'The children are ordered.',
    's2_step0_learn': 'Sorting is always step one.',
    's2_step1_task': 'Click the "Find Median" button.',
    's2_step1_obs': 'Two children in the middle are highlighted.',
    's2_step1_learn': 'Even sets have two middle values.',
    's2_step2_task': 'Drag the two middle children into the Averaging Machine.',
    's2_step2_obs': 'The machine calculates their average.',
    's2_step2_learn': 'For even sets, the median is the average of the two middle values.',
    's2_step3_task': 'Observe the calculated Median.',
    's2_step3_obs': 'A new value represents the middle.',
    's2_step3_learn': 'The physical middle is exactly between the two central points.',

    's3_step0_task': 'Drag the 5 height blocks to the scale.',
    's3_step0_obs': 'The scale tips heavily.',
    's3_step0_learn': 'The scale represents the total sum of heights.',
    's3_step1_task': 'Slide the pointer until the scale balances.',
    's3_step1_obs': 'The scale balances at the Mean height (153 cm).',
    's3_step1_learn': 'The mean is the physical balance point of the data.',
    's3_step2_task': 'Arrange the 5 people on the podiums.',
    's3_step2_obs': 'The middle person is highlighted as the Median.',
    's3_step2_learn': 'We now have both the Mean and Median.',
    's3_step3_task': 'Click "Add Outlier".',
    's3_step3_obs': 'A massive outlier has appeared.',
    's3_step3_learn': 'Outliers are values that stand far apart from the rest.',
    's3_step4_task': 'Drag the massive block onto the left scale pan.',
    's3_step4_obs': 'The scale slams to the ground under the extreme weight!',
    's3_step4_learn': 'An outlier severely unbalances the average.',
    's3_step5_task': 'Rebalance the scale to find new Mean and arrange people to find Median.',
    's3_step5_obs': 'The Mean shifted drastically! The Median barely moved.',
    's3_step5_learn': 'The median is "unshakeable" against outliers.',

    's4_step0_task': 'Drag all 6 coin stacks to the scale and the podiums.',
    's4_step0_obs': 'Coins are loaded onto the measurement platforms.',
    's4_step0_learn': 'We are ready to begin analyzing company incomes.',
    's4_step1_task': 'Calculate both Mean and Median values.',
    's4_step1_obs': 'The Mean is heavily skewed by the CEO, while Median stays at \$150k.',
    's4_step1_learn': 'CEO\'s salary acts as an extreme outlier pulling the Mean up.',
    's4_step2_task': 'Which value honestly represents a typical salary? Click to choose.',
    's4_step2_obs': 'Median Salary selected.',
    's4_step2_learn': 'Median is the robust choice when income is highly skewed.',

    's5_step0_task': 'Calculate Mean and Median for the race times by dragging elements.',
    's5_step0_obs': 'The stumbling runner pulls the Mean way up.',
    's5_step0_learn': 'One bad race time acts as an outlier.',
    's5_step1_task': 'Drag the Median label to the Official Report box.',
    's5_step1_obs': 'Median chosen.',
    's5_step1_learn': 'Median ignores the single stumbled race.',
    's5_step2_task': 'Remove the 45.0s outlier from the data by clicking on it.',
    's5_step2_obs': 'The Mean drops drastically to match the Median.',
    's5_step2_learn': 'Without outliers, Mean and Median are very close.',
  };

  final Map<String, String> _hi = {
    'shutterTitle': 'केंद्रीय प्रवृत्ति के उपाय:\nअडिग माध्यिका (Median)',
    'appSubtitle': 'कक्षा 7 • बिंदुओं को जोड़ना...',
    'enterLab': 'लैब में प्रवेश करें',
    'targetOutput': 'लक्षित आउटपुट',
    's1_title': '1. ऊंचाई लाइन-अप (विषम)',
    's2_title': '2. ऊंचाई लाइन-अप (सम)',
    's3_title': '3. औसत का पैमाना',
    's4_title': '4. सीईओ का वेतन',
    's5_title': '5. दौड़ समय रिपोर्ट',
    'btnFindMedian': 'माध्यिका खोजें',
    'btnSpawnOutlier': 'आउटलायर जोड़ें',
    'btnMean': 'माध्य (Mean)',
    'btnMedian': 'माध्यिका (Median)',
    'lblChoicePrompt': 'कौन सा मूल्य बेहतर प्रतिनिधि विशिष्ट वेतन है?',
    'err_choice': 'क्या आपको यकीन है? फिर से प्रयास करें।',
    'finalSuccessTitle': 'गतिविधि पूरी हुई!',
    'finalSuccessDesc': 'आपने माध्यिका और आउटलायर्स सीख लिया है!',
    'finalRestartBtn': 'गतिविधि पुनरारंभ करें',
    'board_title': 'अडिग माध्यिका (MEDIAN)',
    'board_desc1': 'माध्यिका क्रमित डेटा का मध्य मान है।',
    'board_desc2': 'सूत्र (विषम): मध्य | (सम): मध्य 2 का औसत',
    'label_balance_scale': 'संतुलन पैमाना',
    'label_lineup_platform': 'लाइन-अप प्लेटफॉर्म',
    'label_median_height': 'माध्यिका ऊंचाई',
    'label_mean_equals': 'माध्य = ',
    'label_median_equals': 'माध्यिका = ',
    'label_averaging_machine': 'औसत मशीन',
    'label_mean_salary': 'माध्य वेतन: \$1,000,000',
    'label_median_salary': 'माध्यिका वेतन: \$150,000',
    's3_card_title': 'आउटलायर का प्रभाव',
    's3_card_without': 'आउटलायर के बिना',
    's3_card_heights_1': 'ऊंचाई: 110, 155, 160, 165, 175 सेमी',
    's3_card_mean_1': 'माध्य = 153 सेमी',
    's3_card_median_1': 'माध्यिका = 160 सेमी',
    's3_card_with': 'बास्केटबॉल आउटलायर के साथ',
    's3_card_heights_2': 'ऊंचाई: 155, 160, 165, 175, 220 सेमी',
    's3_card_mean_2': 'माध्य = 175 सेमी (+22 सेमी! 🚀)',
    's3_card_median_2': 'माध्यिका = 165 सेमी (+5 सेमी! ⚖️)',
    's3_card_learn': 'आउटलायर्स माध्य को प्रभावित करते हैं लेकिन माध्यिका बमुश्किल हिलती है!',
    'hud_scenario_complete': 'परिदृश्य पूरा हुआ! साइडबार से अगला चुनें।',

    's1_obj': 'क्रमित डेटा सेट में माध्यिका को भौतिक मध्य मान के रूप में समझना।',
    's2_obj': 'सम-संख्या वाले डेटा सेट के लिए माध्यिका की गणना करना सीखना।',
    's3_obj': 'यह प्रदर्शित करना कि एक आउटलायर माध्य को कैसे प्रभावित करता है लेकिन माध्यिका को नहीं।',
    's4_obj': 'डेटा में अत्यधिक आउटलायर की उपस्थिति में विशिष्ट वेतन का निर्धारण करना।',
    's5_obj': 'एक आउटलायर की पहचान करने और माध्यिका के उपयोग को सही ठहराने के लिए।',

    's1_step0_task': '5 बच्चों को पोडियम पर छोटे से बड़े क्रम में व्यवस्थित करें।',
    's1_step0_obs': 'बच्चों को आरोही ऊंचाई में व्यवस्थित किया गया है।',
    's1_step0_learn': 'माध्यिका खोजने से पहले डेटा को सॉर्ट किया जाना चाहिए।',
    's1_step1_task': '"माध्यिका खोजें" बटन पर क्लिक करें।',
    's1_step1_obs': 'ठीक बीच में खड़ा बच्चा हाइलाइट किया गया है।',
    's1_step1_learn': 'माध्यिका समूह को पूरी तरह से दो हिस्सों में विभाजित करती है।',

    's2_step0_task': '6 बच्चों को पोडियम पर व्यवस्थित करें।',
    's2_step0_obs': 'बच्चों को क्रमित किया गया है।',
    's2_step0_learn': 'सॉर्टिंग हमेशा पहला कदम होता है।',
    's2_step1_task': '"माध्यिका खोजें" बटन पर क्लिक करें।',
    's2_step1_obs': 'बीच के दो बच्चों को हाइलाइट किया गया है।',
    's2_step1_learn': 'सम सेट में दो मध्य मान होते हैं।',
    's2_step2_task': 'दो मध्य बच्चों को औसत मशीन में खींचें।',
    's2_step2_obs': 'मशीन उनके औसत की गणना करती है।',
    's2_step2_learn': 'सम सेट के लिए, माध्यिका दो मध्य मानों का औसत होती है।',
    's2_step3_task': 'गणित माध्यिका का अवलोकन करें।',
    's2_step3_obs': 'एक नया मूल्य मध्य का प्रतिनिधित्व करता है।',
    's2_step3_learn': 'भौतिक मध्य दो केंद्रीय बिंदुओं के ठीक बीच में होता है।',

    's3_step0_task': '5 ऊंचाई ब्लॉकों को पैमाने पर खींचें।',
    's3_step0_obs': 'पैमाना भारी रूप से झुक जाता है।',
    's3_step0_learn': 'पैमाना ऊंचाइयों के कुल योग को दर्शाता है।',
    's3_step1_task': 'संतुलन खोजने के लिए सूचक को खिसकाएं।',
    's3_step1_obs': 'पैमाना माध्य ऊंचाई (153 सेमी) पर संतुलित होता है।',
    's3_step1_learn': 'माध्य डेटा का भौतिक संतुलन बिंदु होता है।',
    's3_step2_task': '5 लोगों को पोडियम पर व्यवस्थित करें।',
    's3_step2_obs': 'मध्य व्यक्ति को माध्यिका के रूप में हाइलाइट किया गया है।',
    's3_step2_learn': 'अब हमारे पास माध्य और माध्यिका दोनों हैं।',
    's3_step3_task': '"आउटलायर जोड़ें" पर क्लिक करें।',
    's3_step3_obs': 'एक विशाल आउटलायर दिखाई दिया है।',
    's3_step3_learn': 'आउटलायर वे मान हैं जो बाकी हिस्सों से बहुत अलग हैं।',
    's3_step4_task': 'विशाल ब्लॉक पैमाने पर खींचें।',
    's3_step4_obs': 'विशाल वजन के कारण पैमाना जमीन पर गिर जाता है!',
    's3_step4_learn': 'एक आउटलायर औसत को गंभीर रूप से असंतुलित कर देता है।',
    's3_step5_task': 'पैमाने को संतुलित करें और लोगों को व्यवस्थित करें।',
    's3_step5_obs': 'माध्य भारी रूप से बढ़कर 175 सेमी! माध्यिका केवल 165 सेमी तक हिली।',
    's3_step5_learn': 'आउटलायर्स के सामने माध्यिका पूरी तरह से "अडिग" है।',

    's4_step0_task': 'सिक्कों को पैमाने और पोडियम पर खींचें।',
    's4_step0_obs': 'सैलरी स्टैक्स प्लेटफॉर्म पर लोड हो गए हैं।',
    's4_step0_learn': 'हम कंपनी की आय का विश्लेषण करने के लिए तैयार हैं।',
    's4_step1_task': 'माध्य और माध्यिका खोजें।',
    's4_step1_obs': 'माध्य सीईओ द्वारा बहुत विषम है, जबकि माध्यिका \$150k पर स्थिर है।',
    's4_step2_task': 'बेहतर विशिष्ट मूल्य चुनें (स्क्रीन पर बटन)।',
    's4_step2_obs': 'माध्यिका वेतन चुना गया।',
    's4_step2_learn': 'माध्यिका एक मजबूत और सही विकल्प है।',

    's5_step0_task': 'रेस समय के लिए माध्य और माध्यिका खोजें।',
    's5_step0_obs': 'ठोकर खाने वाला धावक माध्य को बहुत ऊपर खींचता है।',
    's5_step0_learn': 'एक खराब रेस समय आउटलायर का काम करता है।',
    's5_step1_task': 'माध्यिका लेबल को आधिकारिक रिपोर्ट में खींचें।',
    's5_step1_obs': 'माध्यिका चुनी गई।',
    's5_step1_learn': 'माध्यिका एकल खराब दौड़ को नजरअंदाज करती है।',
    's5_step2_task': 'हटाने के लिए आउटलायर (45.0s) पर क्लिक करें।',
    's5_step2_obs': 'माध्य का स्तर बहुत गिर जाता है।',
    's5_step2_learn': 'बिना आउटलायर के माध्य और माध्यिका बहुत करीब होते हैं।',
  };



  Widget _buildLangToggle() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleLanguage,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                _currentLanguage.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateSimPerFrame();
    });

    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.35; 

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), 
      body: Stack(
        children: [
          // Main Canvas Area
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: CustomPaint(
                painter: CanvasPainter(
                  sim: sim,
                  zoom: _zoom,
                  panOffset: _panOffset,
                  themeDark: true,
                  lang: _currentLanguage,
                  scenario: _currentScenario,
                  step: _step,
                  draggedItem: _draggedItem,
                  t: t,
                ),
              ),
            ),
          ),

          // Mini HUD overlay
          if (sim.hudMessage.isNotEmpty)
            Positioned(
              top: 20, left: _isSidebarOpen ? sidebarWidth : 60, right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purpleAccent.withOpacity(0.5), width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                      ),
                      child: Text(
                        sim.hudMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Canvas Action Buttons
          Positioned(
            bottom: 30, left: _isSidebarOpen ? sidebarWidth : 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentScenario == 1 && _step == 1)
                  _buildCanvasActionButton(t('btnFindMedian'), Colors.purpleAccent, () {
                    _playSound('whir');
                    _advanceStep();
                  }),
                if (_currentScenario == 2 && _step == 1)
                  _buildCanvasActionButton(t('btnFindMedian'), Colors.purpleAccent, () {
                    _playSound('whir');
                    _advanceStep();
                  }),
                if (_currentScenario == 3 && _step == 3)
                  _buildCanvasActionButton(t('btnSpawnOutlier'), Colors.redAccent, () {
                    _playSound('heavy');
                    setState(() {
                      sim.outlierAdded = true;
                      sim.s3MeanFound = false; // Reset finding mean to require user to rebalance pointer in step 5.
                      
                      SimItem? childSrc;
                      try { childSrc = sim.sources.firstWhere((s) => s.val == 110); } catch (_) {}
                      if (childSrc != null && childSrc.inPodium != null) {
                        sim.podiums[childSrc.inPodium!].item = null;
                      }
                      sim.sources.removeWhere((s) => s.val == 110);

                      sim.sources.add(SimItem(
                        id: 99, val: 220, type: 'family', isOutlier: true,
                        x: 30, y: 280 - 17, currentY: 280 - 17,
                        blockX: 70, blockY: 280,
                        startX: 30, startY: 280 - 17,
                        blockStartX: 70, blockStartY: 280,
                      ));

                      sim.scale!.items.removeWhere((id) {
                        try { return sim.sources.firstWhere((s) => s.id == id).val == 110; } catch (_) { return false; }
                      });

                      for (var s in sim.sources) {
                        if (s.inPodium != null) {
                          sim.podiums[s.inPodium!].item = null;
                          s.inPodium = null;
                          s.x = s.startX;
                          s.currentY = s.startY;
                        }
                      }
                      _advanceStep();
                    });
                  }),
                if (_currentScenario == 4 && _step == 2 && !sim.isCompleted)
                  ...[
                    _buildCanvasActionButton(t('btnMean'), Colors.grey.shade700, () {
                      _playSound('error');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('err_choice'))));
                    }),
                    const SizedBox(width: 20),
                    _buildCanvasActionButton(t('btnMedian'), Colors.purpleAccent, () {
                      _playSound('success');
                      _advanceStep();
                    }),
                  ]
              ],
            ),
          ),

          // Animated Sidebar - Entirely Scrollable (SafeArea removed for full edge-to-edge)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? 0 : -sidebarWidth,
            top: 0,
            bottom: 0,
            width: sidebarWidth,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.98),
                border: const Border(right: BorderSide(color: Colors.white12)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Header ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(60.0, 32.0, 16.0, 16.0), // Added top padding to compensate for no SafeArea
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('shutterTitle').replaceAll('\n', ' '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),

                    // --- Content Body ---
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Controls Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLangToggle(),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                                onPressed: _resetSimulation,
                                tooltip: 'Reset',
                              )
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Scenario Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _currentScenario,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0F172A),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                items: [1, 2, 3, 4, 5].map((id) {
                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text(t('s${id}_title')),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _playSound('click');
                                    _loadScenario(val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Objective Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple.withOpacity(0.3)),
                            ),
                            child: Text(
                              t('s${_currentScenario}_obj'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Dynamic Steps List
                          ..._buildStepsList(),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // --- Footer ---
                    const Divider(color: Colors.white12, height: 1),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      color: const Color(0xFF0F172A),
                      child: const Center(
                        child: Text(
                          "© ZeroScienceLab - Fall in love with math and Science",
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Left Menu Button
          if (!_showShutter)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound('click');
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
            ),

          // Shutter Screen Overlay
          if (_showShutter)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                ),
                child: Stack(
                  children: [
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (_pulseController.value * 0.1),
                                    child: Container(
                                      width: 120, height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.purpleAccent.withOpacity(0.8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.purpleAccent.withOpacity(0.5), 
                                            blurRadius: 20 * _pulseController.value, 
                                            spreadRadius: 5 * _pulseController.value
                                          )
                                        ]
                                      ),
                                      child: const Center(child: Icon(Icons.extension, size: 60, color: Colors.white)),
                                    ),
                                  );
                                }
                              ),
                              const SizedBox(height: 40),
                              Text(
                                t('shutterTitle'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, height: 1.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('appSubtitle'),
                                style: const TextStyle(color: Colors.purpleAccent, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 60),
                              ElevatedButton.icon(
                                onPressed: _startActivity,
                                icon: const Icon(Icons.play_circle_fill, size: 30),
                                label: Text(t('enterLab')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  elevation: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
        ],
      ),
    );
  }

  Widget _buildCanvasActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  List<Widget> _buildStepsList() {
    int maxSteps = _getMaxSteps(_currentScenario);
    List<Widget> list = [];

    for (int i = 0; i < maxSteps; i++) {
      bool isCompleted = i < _step;
      bool isActive = i == _step;
      bool isFinalCompleted = (i == _step - 1) && (_step == maxSteps);

      Color bgColor = const Color(0xFF1E293B);
      Color borderColor = Colors.white12;
      Widget icon = Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
        child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
      );

      if (isActive) {
        bgColor = Colors.purple.withOpacity(0.2);
        borderColor = Colors.purpleAccent.withOpacity(0.5);
        icon = Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle),
          child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        );
      } else if (isFinalCompleted) {
        bgColor = Colors.green.withOpacity(0.15);
        borderColor = Colors.greenAccent.withOpacity(0.4);
        icon = const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28);
      } else if (isCompleted) {
        bgColor = const Color(0xFF0F172A).withOpacity(0.5);
        borderColor = Colors.white10;
        icon = const Icon(Icons.check_circle, color: Colors.purpleAccent, size: 28);
      }

      list.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: isActive ? [BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)] : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "STEP ${i + 1}",
                      style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: (isActive || isCompleted) ? Colors.white : Colors.white54, fontSize: 14, height: 1.4),
                        children: [
                          const TextSpan(text: "Action: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: t('s${_currentScenario}_step${i}_task')),
                        ],
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isFinalCompleted ? Colors.green.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isFinalCompleted ? Colors.green.withOpacity(0.2) : Colors.purple.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                                children: [
                                  const TextSpan(text: "Observation: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: t('s${_currentScenario}_step${i}_obs')),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 16),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                                children: [
                                  const TextSpan(text: "Learning: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: t('s${_currentScenario}_step${i}_learn')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        )
      );
    }
    return list;
  }
}

// --- Data Models ---
class SimItem {
  dynamic id;
  double val;
  String type;

  double x = 0;
  double y = 0;
  double currentY = 0;
  double stepH = 0;

  int? inPodium;
  bool inScale = false;
  bool inMachine = false;
  bool blockInScale = false;

  double startX = 0;
  double startY = 0;
  double blockX = 0;
  double blockY = 0;
  double blockStartX = 0;
  double blockStartY = 0;

  bool isOutlier = false;
  bool isAverage = false;
  bool isMedian = false;
  String labelStr = "";

  SimItem({
    required this.id,
    required this.val,
    required this.type,
    this.isOutlier = false,
    this.isAverage = false,
    this.isMedian = false,
    this.x = 0,
    this.y = 0,
    this.currentY = 0,
    this.blockX = 0,
    this.blockY = 0,
    this.startX = 0,
    this.startY = 0,
    this.blockStartX = 0,
    this.blockStartY = 0,
    this.inMachine = false,
  });
}

class SimPodium {
  int id;
  double x;
  double y;
  SimItem? item;
  SimPodium({required this.id, required this.x, required this.y, this.item});
}

class SimScale {
  double x;
  double y;
  List<dynamic> items = [];
  double pointerVal;
  double trueMean;
  double min;
  double max;

  SimScale({
    required this.x,
    required this.y,
    this.pointerVal = 0,
    this.trueMean = 0,
    this.min = 0,
    this.max = 300,
  });
}

class SimMachine {
  double x;
  double y;
  SimItem? slot1;
  SimItem? slot2;
  SimMachine({required this.x, required this.y});
}

class SimState {
  List<SimItem> sources = [];
  List<SimPodium> podiums = [];
  SimMachine? machine;
  SimScale? scale;

  bool isCompleted = false;
  bool outlierAdded = false;
  bool outlierRemoved = false;
  bool s3MeanFound = false;
  bool s4MeanFound = false;
  bool s4MedianFound = false;
  bool s5MeanFound = false;
  bool s5MedianFound = false;
  bool labelsSpawned = false;
  double animProgress = 0.0;
  String hudMessage = "";
}

// --- Custom Painter ---
class CanvasPainter extends CustomPainter {
  final SimState sim;
  final double zoom;
  final Offset panOffset;
  final bool themeDark;
  final String lang;
  final int scenario;
  final int step;
  final SimItem? draggedItem;
  final String Function(String) t;

  CanvasPainter({
    required this.sim,
    required this.zoom,
    required this.panOffset,
    required this.themeDark,
    required this.lang,
    required this.scenario,
    required this.step,
    required this.draggedItem,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panOffset.dx, size.height / 2 + panOffset.dy);
    canvas.scale(zoom, zoom);

    if (scenario == 1 || scenario == 2 || scenario == 3) {
      _drawClassroomBg(canvas);
    } else if (scenario == 4) {
      _drawOfficeBg(canvas);
      _drawCEODeskAndChair(canvas);
    } else if (scenario == 5) {
      _drawTrackBg(canvas);
    }

    List<int> medianIndices = [];
    if (scenario == 1) medianIndices = [2];
    if (scenario == 2) medianIndices = [2, 3];
    if (scenario == 3) medianIndices = [2];
    if (scenario == 4) medianIndices = [2, 3];
    if (scenario == 5) medianIndices = [3];

    if (scenario == 2 && step >= 2 && sim.machine != null) {
      sim.machine!.x = (sim.podiums[2].x + sim.podiums[3].x) / 2;
      sim.machine!.y = sim.podiums[2].y - 250;
      _drawMachineBack(canvas, sim.machine!);
    }

    if (scenario != 5 && !(scenario == 3 && step == 5)) {
      for (int i = 0; i < sim.podiums.length; i++) {
        var p = sim.podiums[i];
        bool highlight = (step >= 1 && medianIndices.contains(i) && scenario < 4) ||
            (step >= 2 && medianIndices.contains(i) && scenario >= 4) ||
            (scenario == 4 && step == 1 && medianIndices.contains(i));
        _drawSteppedPodium(canvas, p.x, p.y, i, highlight, scenario == 3);
      }
    } else if (scenario == 5) {
      for (int i = 0; i < sim.podiums.length; i++) {
        var p = sim.podiums[i];
        bool highlight = (step >= 1 && medianIndices.contains(i));
        _drawSteppedPodium(canvas, p.x, p.y, i, highlight, false);
      }
    }

    if (scenario == 3 && step != 5 && sim.scale != null) {
      _drawSteelyardBalanceS3(canvas, sim.scale!);
    } else if (sim.scale != null && scenario >= 4) {
      _drawBalanceScale(canvas, sim.scale!);
    }

    if (scenario == 3 && step == 5) {
      _drawS3SummaryChalkboard(canvas);
    }

    if (scenario == 5 && step >= 1) {
      _drawRoundedRect(canvas, 300, -150, 180, 120, 8, const Color(0xFFF8FAFC), const Color(0xFF94A3B8), 3);
      _drawTextCenter(canvas, "OFFICIAL REPORT", 300, -190, 16, const Color(0xFF0F172A), true);
      _drawRoundedRect(canvas, 300, -140, 160, 90, 4, const Color(0xFFE2E8F0), const Color(0xFFCBD5E1), 2);
      if (step >= 2) {
        _drawTextCenter(canvas, "GOOD CHOICE!", 300, -180, 12, Colors.green, true);
      }
    }

    if (!(scenario == 3 && step == 5)) {
      for (var src in sim.sources) {
        if (src.type == 'label') continue;
        bool isDragging = draggedItem?.id == src.id;

        if (src.inPodium == null && !src.inScale && !src.inMachine) {
          if (src.type == 'coin') {
            _drawCoinStack(canvas, src.blockX, src.blockY, src.val, isDragging);
            _drawFamilyMember(canvas, src.x, src.currentY, src.val, src.isOutlier, src.isAverage, false);
          } else if (src.type == 'time') {
            _drawDigitalClock(canvas, src.blockX, src.blockY, src.val, isDragging, src.val == 45.0);
            _drawFamilyMember(canvas, src.x, src.currentY, src.val, src.isOutlier, src.isAverage, false);
          } else {
            _drawFamilyMember(canvas, src.x, src.currentY, src.val, src.isOutlier, src.isAverage, isDragging);
          }
        } else if (src.type == 'coin' && src.inScale) {
          if (src.val == 5280) _drawCoinStack(canvas, src.blockX, src.blockY, src.val, false);
          _drawFamilyMember(canvas, src.startX, src.startY, src.val, src.isOutlier, src.isAverage, false);
        } else if (src.type == 'time' && src.inScale) {
          _drawFamilyMember(canvas, src.startX, src.startY, src.val, src.isOutlier, src.isAverage, false);
        }

        if (scenario == 3 && src.blockInScale && src.inPodium == null) {
          _drawFamilyMember(canvas, src.startX, src.startY, src.val, src.isOutlier, false, false);
        }

        if (scenario == 3 && !src.blockInScale && !isDragging) {
          Color blockColor = _getBlockColor(src.val);
          double h = src.isOutlier ? 170 : (src.val / 150) * 85;
          _drawRoundedRect(canvas, src.blockX, src.blockY - h / 2, 34, h, 4, blockColor, const Color(0xFF0F172A), 1.5);
          _drawTextCenter(canvas, src.val.toStringAsFixed(0), src.blockX, src.blockY - h / 2, 11, Colors.white, true);
        }
      }
    }

    if (!(scenario == 3 && step == 5)) {
      for (var p in sim.podiums) {
        if (p.item != null) {
          bool isDragging = draggedItem?.id == p.item!.id;
          if (p.item!.type == 'coin') {
            _drawCoinStack(canvas, p.x, p.item!.blockY, p.item!.val, isDragging);
          } else if (p.item!.type == 'time') {
            _drawDigitalClock(canvas, p.x, p.item!.blockY, p.item!.val, isDragging, p.item!.val == 45.0);
            _drawFamilyMember(canvas, p.item!.startX, p.item!.startY, p.item!.val, p.item!.isOutlier, false, false);
          } else {
            _drawFamilyMember(canvas, p.x, p.item!.currentY, p.item!.val, p.item!.isOutlier, p.item!.isAverage, isDragging);
          }
        }
      }
    }

    if (sim.machine != null) {
      if (sim.machine!.slot1 != null) {
        _drawFamilyMember(canvas, sim.machine!.slot1!.x, sim.machine!.slot1!.y, sim.machine!.slot1!.val, false, false, false);
      }
      if (sim.machine!.slot2 != null) {
        _drawFamilyMember(canvas, sim.machine!.slot2!.x, sim.machine!.slot2!.y, sim.machine!.slot2!.val, false, false, false);
      }
    }

    if (scenario == 2 && step >= 2 && sim.machine != null) {
      _drawMachineFront(canvas, sim.machine!, sim.animProgress);
    }

    if (scenario == 1 && step >= 1) {
      double mx = sim.podiums[2].x;
      double my = sim.podiums[2].y;
      _drawRoundedRect(canvas, mx, my + 25, 130, 26, 13, Colors.white, const Color(0xFF0F172A), 2);
      _drawTextCenter(canvas, t('label_median_height'), mx, my + 25, 11, const Color(0xFF0F172A), true);
    }
    if (scenario == 2 && step >= 3) {
      try {
        var avgChild = sim.sources.firstWhere((s) => s.isAverage);
        if (sim.animProgress == 0) {
          _drawRoundedRect(canvas, avgChild.x, avgChild.y + 35, 130, 26, 13, Colors.white, const Color(0xFF0F172A), 2);
          _drawTextCenter(canvas, t('label_median_height'), avgChild.x, avgChild.y + 35, 11, const Color(0xFF0F172A), true);
        }
      } catch (_) {}
    }

    if (draggedItem != null) {
      if (draggedItem!.type == 'label') {
        // Just let it draw below
      } else if (draggedItem!.type == 'block' || scenario >= 4) {
        if (scenario == 4) {
          _drawCoinStack(canvas, draggedItem!.blockX, draggedItem!.blockY, draggedItem!.val, true);
        } else if (scenario == 5) {
          _drawDigitalClock(canvas, draggedItem!.blockX, draggedItem!.blockY, draggedItem!.val, true, draggedItem!.val == 45.0);
        } else {
          canvas.save();
          canvas.translate(draggedItem!.blockX, draggedItem!.blockY);
          canvas.scale(1.15, 1.15);
          Color blockColor = _getBlockColor(draggedItem!.val);
          double h = draggedItem!.isOutlier ? 170 : (draggedItem!.val / 150) * 85;
          _drawRoundedRect(canvas, 0, -h / 2, 34, h, 4, blockColor, const Color(0xFF0F172A), 1.5);
          _drawTextCenter(canvas, draggedItem!.val.toStringAsFixed(0), 0, -h / 2, 11, Colors.white, true);
          canvas.restore();
        }
      } else if (draggedItem!.type == 'item') {
        _drawFamilyMember(canvas, draggedItem!.x, draggedItem!.y, draggedItem!.val, draggedItem!.isOutlier, false, true);
      }
    }

    for (var s in sim.sources) {
      if (s.type == 'label') {
        bool isDrag = draggedItem?.id == s.id;
        double x = isDrag ? s.x : s.x;
        double y = isDrag ? s.y : s.currentY;
        canvas.save();
        if (isDrag) {
          canvas.translate(x, y);
          canvas.scale(1.15, 1.15);
          x = 0;
          y = 0;
        }
        _drawRoundedRect(canvas, x, y, 130, 40, 8, Colors.blueAccent, const Color(0xFF1E3A8A), 2);
        _drawTextCenter(canvas, s.labelStr, x, y, 14, Colors.white, true);
        canvas.restore();
      }
    }

    if (scenario == 3 && step != 5) {
      _drawTextCenter(canvas, t('label_lineup_platform'), 260, -90, 18, Colors.white, true);
      if (sim.scale != null && sim.scale!.items.isNotEmpty && step >= 1) {
        String unit = lang == 'en' ? ' cm' : ' సెం.మీ';
        if (lang == 'hi') unit = ' सेमी';
        _drawTextCenter(canvas, "${t('label_mean_equals')}${sim.scale!.pointerVal.round()}$unit", sim.scale!.x, sim.scale!.y - 120, 18, Colors.redAccent, true);
      }
      bool allFull = sim.podiums.every((p) => p.item != null);
      if (allFull && step >= 2 && sim.podiums[2].item != null) {
        _drawRoundedRect(canvas, 260, -130, 130, 26, 13, Colors.white, const Color(0xFF0F172A), 2);
        _drawTextCenter(canvas, t('label_median_height'), 260, -130, 11, const Color(0xFF0F172A), true);
      }
    }

    if (scenario == 4) {
      if (sim.s4MeanFound) {
        _drawTextCenter(canvas, t('label_mean_salary'), sim.scale!.x, sim.scale!.y - 100, 18, Colors.redAccent, true);
      }
      if (sim.s4MedianFound) {
        _drawTextCenter(canvas, t('label_median_salary'), 280, -100, 18, Colors.greenAccent, true);
      }
    }

    if (scenario == 5) {
      _drawTextCenter(canvas, t('label_lineup_platform'), 265, -90, 18, Colors.white, true);
      if (sim.s5MeanFound || step >= 1) {
        String mVal = sim.outlierRemoved ? "15.7" : "19.9";
        String unit = lang == 'en' ? 's' : ' సె';
        if (lang == 'hi') unit = ' से';
        _drawTextCenter(canvas, "${t('label_mean_equals')}$mVal$unit", sim.scale!.x, sim.scale!.y - 100, 18, Colors.redAccent, true);
      }
      if (sim.s5MedianFound || step >= 1) {
        String mVal = sim.outlierRemoved ? "15.7" : "15.8";
        String unit = lang == 'en' ? 's' : ' సె';
        if (lang == 'hi') unit = ' से';
        _drawTextCenter(canvas, "${t('label_median_equals')}$mVal$unit", 265, -130, 18, Colors.greenAccent, true);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, double strokeW) {
    Rect rect = Rect.fromCenter(center: Offset(x, y), width: w, height: h);
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));
    if (fill != Colors.transparent) {
      canvas.drawRRect(rrect, Paint()..color = fill..style = PaintingStyle.fill);
    }
    if (stroke != Colors.transparent && strokeW > 0) {
      canvas.drawRRect(rrect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = strokeW);
    }
  }

  void _drawTextCenter(Canvas canvas, String text, double x, double y, double fontSize, Color color, bool bold) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  Color _getBlockColor(double val) {
    if (val == 110) return const Color(0xFFEC4899);
    if (val == 120) return const Color(0xFF3B82F6);
    if (val == 130) return const Color(0xFFEAB308);
    if (val == 140) return const Color(0xFFEC4899);
    if (val == 150) return const Color(0xFF3B82F6);
    if (val == 155) return const Color(0xFFA855F7);
    if (val == 160) return const Color(0xFF22C55E);
    if (val == 165) return const Color(0xFFEF4444);
    if (val == 175) return const Color(0xFFEAB308);
    if (val == 220) return const Color(0xFFF97316);
    return const Color(0xFF64748B);
  }

  void _drawClassroomBg(Canvas canvas) {
    Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      ).createShader(const Rect.fromLTRB(-1000, -500, 1000, 500));
    canvas.drawRect(const Rect.fromLTRB(-1000, -500, 1000, 500), paint);

    canvas.drawRect(const Rect.fromLTRB(-1000, 180, 1000, 195), Paint()..color = const Color(0xFF334155));

    paint.shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF1E1B4B), Color(0xFF0F0E26)],
    ).createShader(const Rect.fromLTRB(-1000, 195, 1000, 500));
    canvas.drawRect(const Rect.fromLTRB(-1000, 195, 1000, 500), paint);

    Paint linePaint = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.stroke..strokeWidth = 2;
    for (double i = -800; i <= 800; i += 150) {
      canvas.drawLine(Offset(i, 195), Offset(i * 1.3, 500), linePaint);
    }

    _drawRoundedRect(canvas, 0, -180, 650, 180, 10, const Color(0xFF022C22), const Color(0xFF475569), 8);
    _drawTextCenter(canvas, t('board_title'), 0, -220, 18, const Color(0xFFCBD5E1), true);
    _drawTextCenter(canvas, t('board_desc1'), 0, -180, 14, const Color(0xFFCBD5E1), false);
    _drawTextCenter(canvas, t('board_desc2'), 0, -140, 12, const Color(0xFFCBD5E1), false);

    canvas.drawRect(const Rect.fromLTWH(-450, -300, 120, 200), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(const Rect.fromLTWH(-450, -300, 120, 200), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 4);
    Path doorLines = Path()..moveTo(-390, -300)..lineTo(-390, -100)..moveTo(-450, -200)..lineTo(-330, -200);
    canvas.drawPath(doorLines, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 4);
  }

  void _drawOfficeBg(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-1000, -500, 1000, 500),
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF090D16), Color(0xFF131B2E)]).createShader(const Rect.fromLTRB(-1000, -500, 1000, 500)),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-1000, 180, 1000, 500),
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF311005), Color(0xFF120401)]).createShader(const Rect.fromLTRB(-1000, 180, 1000, 500)),
    );
    canvas.drawRect(const Rect.fromLTRB(-1000, 170, 1000, 180), Paint()..color = const Color(0xFF1E293B));

    double winX = 180, winY = -240, winW = 340, winH = 220;
    canvas.drawRect(Rect.fromLTWH(winX, winY, winW, winH), Paint()..color = const Color(0xFF111827));
    canvas.drawRect(Rect.fromLTWH(winX + 40, winY + 80, 60, 140), Paint()..color = const Color(0xFF1F2937));
    canvas.drawRect(Rect.fromLTWH(winX + 130, winY + 40, 80, 180), Paint()..color = const Color(0xFF1F2937));
    canvas.drawRect(Rect.fromLTWH(winX + 240, winY + 110, 50, 110), Paint()..color = const Color(0xFF1F2937));

    canvas.drawRect(Rect.fromLTWH(winX, winY, winW, winH), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 6);
    Path windowBars = Path()..moveTo(winX + winW / 2, winY)..lineTo(winX + winW / 2, winY + winH)..moveTo(winX, winY + winH / 2)..lineTo(winX + winW, winY + winH / 2);
    canvas.drawPath(windowBars, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 6);

    _drawRoundedRect(canvas, -280, 210, 180, 32, 6, const Color(0xFF475569), const Color(0xFFCBD5E1), 2);
    _drawTextCenter(canvas, t('label_balance_scale'), -280, 210, 12, Colors.white, true);

    _drawRoundedRect(canvas, 280, 210, 180, 32, 6, const Color(0xFF475569), const Color(0xFFCBD5E1), 2);
    _drawTextCenter(canvas, t('label_lineup_platform'), 280, 210, 12, Colors.white, true);
  }

  void _drawTrackBg(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-1000, -500, 1000, 500),
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF020617), Color(0xFF0F172A)]).createShader(const Rect.fromLTRB(-1000, -500, 1000, 500)),
    );
    canvas.drawRect(const Rect.fromLTRB(-1000, 100, 1000, 180), Paint()..color = const Color(0xFF064E3B));
    canvas.drawRect(
      const Rect.fromLTRB(-1000, 180, 1000, 500),
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7F1D1D), Color(0xFF450A0A)]).createShader(const Rect.fromLTRB(-1000, 180, 1000, 500)),
    );

    Paint lineP = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4;
    for (double y = 180; y <= 500; y += 65) {
      canvas.drawLine(Offset(-1000, y), Offset(1000, y), lineP);
    }
  }

  void _drawSteppedPodium(Canvas canvas, double x, double y, int index, bool highlight, bool isS3) {
    canvas.save();
    canvas.translate(x, y);
    double h = isS3 ? 40 + (index * 15) : 40 + (index * 20);
    double w = isS3 ? 66 : 72;

    Color topC = highlight ? const Color(0xFFFDE047) : const Color(0xFF334155);
    Color sideC = highlight ? const Color(0xFFEAB308) : const Color(0xFF1E293B);
    Color frontC = highlight ? const Color(0xFFFEF08A) : const Color(0xFF475569);
    Paint stroke = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 1.5;

    Path topPath = Path()..moveTo(-w / 2, -h)..lineTo(w / 2, -h)..lineTo(w / 2 + 8, -h - 8)..lineTo(-w / 2 + 8, -h - 8)..close();
    canvas.drawPath(topPath, Paint()..color = topC);
    canvas.drawPath(topPath, stroke);

    Path sidePath = Path()..moveTo(w / 2, -h)..lineTo(w / 2 + 8, -h - 8)..lineTo(w / 2 + 8, -8)..lineTo(w / 2, 0)..close();
    canvas.drawPath(sidePath, Paint()..color = sideC);
    canvas.drawPath(sidePath, stroke);

    Rect front = Rect.fromLTRB(-w / 2, -h, w / 2, 0);
    canvas.drawRect(front, Paint()..color = frontC);
    canvas.drawRect(front, stroke);

    _drawTextCenter(canvas, (index + 1).toString(), 0, -h / 2, 18, highlight ? const Color(0xFFCA8A04) : const Color(0xFF94A3B8), true);
    canvas.restore();
  }

  void _drawFamilyMember(Canvas canvas, double x, double y, double val, bool isOutlier, bool isAverage, bool isDragging) {
    canvas.save();
    canvas.translate(x, y);

    if (isDragging) {
      canvas.scale(1.15, 1.15);
    }

    double h = (val / 150) * 105;
    if (isOutlier) h = 185;
    if (val > 1000) h = 110;
    if (scenario == 5) h = 105;

    Color shirt = const Color(0xFFEC4899);
    Color pants = const Color(0xFF1E293B);
    Color skin = const Color(0xFFFCD34D);
    Color hair = const Color(0xFF451A03);
    bool hasGlasses = false;

    if (scenario <= 2) {
      if (val == 110) { shirt = const Color(0xFFEC4899); pants = const Color(0xFF9D174D); skin = const Color(0xFFFFEDD5); hair = const Color(0xFF78350F); }
      else if (val == 120) { shirt = const Color(0xFF3B82F6); pants = const Color(0xFF0F172A); skin = const Color(0xFFFEF08A); hair = const Color(0xFF1E293B); }
      else if (val == 130) { shirt = const Color(0xFFEAB308); pants = const Color(0xFF7C2D12); skin = const Color(0xFFFFEDD5); hair = const Color(0xFFB45309); }
      else if (val == 140) { shirt = const Color(0xFFEF4444); pants = const Color(0xFF450A0A); skin = const Color(0xFFFED7AA); hair = const Color(0xFF000000); }
      else if (val == 150) { shirt = const Color(0xFFA855F7); pants = const Color(0xFF4C1D95); skin = const Color(0xFFF3E8FF); hair = const Color(0xFF1C1917); }
      else if (val == 160) { shirt = const Color(0xFF22C55E); pants = const Color(0xFF064E3B); skin = const Color(0xFFFED7AA); hair = const Color(0xFF451A03); }
    } else if (scenario == 3) {
      if (val == 110) { shirt = const Color(0xFFEC4899); pants = const Color(0xFF9D174D); skin = const Color(0xFFFFEDD5); hair = const Color(0xFF78350F); }
      else if (val == 155) { shirt = const Color(0xFFA855F7); pants = const Color(0xFF4C1D95); skin = const Color(0xFFF3E8FF); hair = const Color(0xFF1C1917); }
      else if (val == 160) { shirt = const Color(0xFF22C55E); pants = const Color(0xFF064E3B); skin = const Color(0xFFFED7AA); hair = const Color(0xFF451A03); }
      else if (val == 165) { shirt = const Color(0xFF3B82F6); pants = const Color(0xFF0F172A); skin = const Color(0xFFFBCFE8); hair = const Color(0xFF000000); }
      else if (val == 175) { shirt = const Color(0xFFEAB308); pants = const Color(0xFF7C2D12); skin = const Color(0xFFFEF08A); hair = const Color(0xFF1E293B); hasGlasses = true; }
    } else if (scenario == 4) {
      if (val == 120) { shirt = const Color(0xFF0EA5E9); pants = const Color(0xFF1E293B); skin = const Color(0xFFFED7AA); hair = const Color(0xFF451A03); }
      else if (val == 130) { shirt = const Color(0xFF10B981); pants = const Color(0xFF0F172A); skin = const Color(0xFFFFEDD5); hair = const Color(0xFF78350F); }
      else if (val == 140) { shirt = const Color(0xFFEC4899); pants = const Color(0xFF475569); skin = const Color(0xFFFEF08A); hair = const Color(0xFF1E293B); }
      else if (val == 160) { shirt = const Color(0xFFF59E0B); pants = const Color(0xFF1E293B); skin = const Color(0xFFFFEDD5); hair = const Color(0xFF000000); }
      else if (val == 170) { shirt = const Color(0xFFA855F7); pants = const Color(0xFF334155); skin = const Color(0xFFFED7AA); hair = const Color(0xFFB45309); }
    } else if (scenario == 5) {
      shirt = const Color(0xFFEF4444); pants = const Color(0xFF1E293B); skin = const Color(0xFFFED7AA); hair = const Color(0xFF451A03);
      if (val == 14.0) shirt = const Color(0xFF3B82F6);
      if (val == 15.0) shirt = const Color(0xFF0EA5E9);
      if (val == 15.2) shirt = const Color(0xFFEAB308);
      if (val == 15.5) shirt = const Color(0xFF10B981);
      if (val == 15.8) shirt = const Color(0xFFF59E0B);
      if (val == 16.1) shirt = const Color(0xFFEC4899);
      if (val == 16.5) shirt = const Color(0xFFA855F7);
      if (val == 45.0) { shirt = const Color(0xFFEF4444); }
    }

    if (isOutlier) { shirt = const Color(0xFFF97316); pants = const Color(0xFFEA580C); skin = const Color(0xFF92400E); hair = const Color(0xFF0F172A); }
    if (val > 1000) { shirt = const Color(0xFF1E3A8A); pants = const Color(0xFF0F172A); skin = const Color(0xFFFFEDD5); hair = const Color(0xFF451A03); hasGlasses = true; }
    if (isAverage) { shirt = const Color(0xFF8B5CF6); pants = const Color(0xFF4C1D95); skin = const Color(0xFFFED7AA); hair = const Color(0xFF451A03); }

    Paint skinP = Paint()..color = skin;
    Paint pantsP = Paint()..color = pants;

    // Legs
    canvas.drawRect(const Rect.fromLTWH(-5, 0, 3, 15), skinP);
    canvas.drawRect(const Rect.fromLTWH(2, 0, 3, 15), skinP);
    
    // Pants
    canvas.drawRect(const Rect.fromLTWH(-7, -20, 5, 23), pantsP);
    canvas.drawRect(const Rect.fromLTWH(2, -20, 5, 23), pantsP);

    // Shoes
    Paint shoesP = Paint()..color = const Color(0xFF0F172A);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-5, 14), width: 12, height: 6), shoesP);
    canvas.drawOval(Rect.fromCenter(center: const Offset(4, 14), width: 12, height: 6), shoesP);

    Paint shirtP = Paint()..color = shirt;
    
    // Dress or Shirt
    if (val == 110 || val == 155 || val == 160) {
      Path dress = Path()
        ..moveTo(-10, -h / 2)
        ..lineTo(10, -h / 2)
        ..lineTo(15, -15)
        ..lineTo(-15, -15)
        ..close();
      canvas.drawPath(dress, shirtP);
    } else {
      _drawRoundedRect(canvas, 0, -h / 2 + 5, 18, max(18.0, (h / 2) - 10), 6, shirt, Colors.transparent, 0);
    }

    if (isOutlier) {
      _drawTextCenter(canvas, "23", 0, -h / 2 + 12, 11, Colors.white, true);
    }

    // Arms
    _drawRoundedRect(canvas, -14, -h / 2 + 5, 4, 22, 2, skin, Colors.transparent, 0);
    _drawRoundedRect(canvas, 10, -h / 2 + 5, 4, 22, 2, skin, Colors.transparent, 0);
    
    // Sleeves
    _drawRoundedRect(canvas, -15, -h / 2 + 2, 6, 10, 2, shirt, Colors.transparent, 0);
    _drawRoundedRect(canvas, 9, -h / 2 + 2, 6, 10, 2, shirt, Colors.transparent, 0);

    double headY = -h / 2 - 12;
    double headR = 13;

    Paint hairP = Paint()..color = hair;

    // Back Hair (for dresses)
    if (val == 110 || val == 155 || val == 160) {
      canvas.drawCircle(Offset(0, headY), headR + 1, hairP);
      canvas.drawRect(Rect.fromLTWH(-headR - 1, headY, (headR + 1) * 2, 14), hairP);
    }

    // Face Base
    canvas.drawCircle(Offset(0, headY), headR, skinP);

    // Simple Clean Top Hairline (replaces the intersecting front-hair and messy beard)
    canvas.drawArc(Rect.fromCircle(center: Offset(0, headY - 2), radius: headR + 1), pi, pi, false, hairP);

    // Eyes
    Paint eyesP = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-4, headY + 1), 2, eyesP);
    canvas.drawCircle(Offset(4, headY + 1), 2, eyesP);

    // Mouth
    Paint mouthP = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawArc(Rect.fromCircle(center: Offset(0, headY + 5), radius: 3), 0, pi, false, mouthP);

    if (hasGlasses) {
      Paint glassesP = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 1.5;
      canvas.drawCircle(Offset(-4, headY + 1), 4, glassesP);
      canvas.drawCircle(Offset(4, headY + 1), 4, glassesP);
    }

    if (scenario <= 3) {
      _drawRoundedRect(canvas, 0, 20, 52, 18, 4, Colors.white, const Color(0xFF475569), 1.5);
      String unit = lang == 'en' ? ' cm' : ' సెం.మీ';
      if (lang == 'hi') unit = ' सेमी';
      _drawTextCenter(canvas, "${val.round()}$unit", 0, 20, 10, const Color(0xFF1E293B), true);
    }

    canvas.restore();
  }

  void _drawCEODeskAndChair(Canvas canvas) {
    canvas.save();
    canvas.translate(240, -10);
    _drawRoundedRect(canvas, 0, -110, 65, 80, 10, const Color(0xFF0F172A), const Color(0xFF334155), 2);
    _drawFamilyMember(canvas, 0, -35, 1500, false, false, false);
    double tableW = 190, tableH = 65;
    Rect tRect = Rect.fromCenter(center: const Offset(0, 0), width: tableW, height: tableH);
    Paint tPaint = Paint()
      ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7C2D12), Color(0xFF450A0A)]).createShader(tRect);
    canvas.drawRRect(RRect.fromRectAndRadius(tRect, const Radius.circular(8)), tPaint);
    canvas.restore();
  }

  void _drawCoinStack(Canvas canvas, double x, double y, double val, bool isDragging) {
    canvas.save();
    canvas.translate(x, y);
    if (isDragging) canvas.scale(1.15, 1.15);

    int maxCoins = val > 1000 ? 25 : (val / 15).ceil();
    for (int i = 0; i < maxCoins; i++) {
      double cy = -i * 5.5;
      canvas.drawOval(Rect.fromCenter(center: Offset(0, cy), width: 44, height: 12), Paint()..color = const Color(0xFFFEF08A));
      canvas.drawOval(Rect.fromCenter(center: Offset(0, cy), width: 44, height: 12), Paint()..color = const Color(0xFFCA8A04)..style = PaintingStyle.stroke..strokeWidth = 1);
    }
    _drawRoundedRect(canvas, 0, 16, 50, 18, 4, const Color(0xFF1E293B), const Color(0xFFFDE047), 1.5);
    String label = val > 1000 ? "\$5.28M" : (lang == 'en' ? "\$${val.toInt()}k" : "\$${val.toInt()} వేలు");
    if (lang == 'hi') label = val > 1000 ? "\$5.28M" : "\$${val.toInt()} हजार";
    _drawTextCenter(canvas, label, 0, 16, 10, const Color(0xFFFDE047), true);
    canvas.restore();
  }

  void _drawDigitalClock(Canvas canvas, double x, double y, double val, bool isDragging, bool isOutlier) {
    canvas.save();
    canvas.translate(x, y);
    if (isDragging) canvas.scale(1.15, 1.15);
    _drawRoundedRect(canvas, 0, 0, 56, 32, 6, const Color(0xFF1E293B), isOutlier ? const Color(0xFFEF4444) : const Color(0xFF475569), 2);
    _drawRoundedRect(canvas, 0, 0, 48, 24, 4, const Color(0xFF020617), Colors.transparent, 0);
    String unit = lang == 'en' ? 's' : ' సె';
    if (lang == 'hi') unit = ' से';
    _drawTextCenter(canvas, "${val.toStringAsFixed(1)}$unit", 0, 1, 14, isOutlier ? const Color(0xFFEF4444) : const Color(0xFF22C55E), true);
    canvas.restore();
  }

  void _drawSteelyardBalanceS3(Canvas canvas, SimScale scaleObj) {
    canvas.save();
    canvas.translate(scaleObj.x, scaleObj.y);

    Path base = Path()..moveTo(-35, 180)..lineTo(35, 180)..lineTo(10, 0)..lineTo(-10, 0)..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFF1E293B));

    double sum = scaleObj.items.fold(0, (acc, id) {
      try { return acc + sim.sources.firstWhere((x) => x.id == id).val; } catch (_) { return acc; }
    });
    int count = scaleObj.items.length;
    double tMean = count > 0 ? sum / count : 100;
    double tilt = max(-0.45, min(0.45, (tMean - scaleObj.pointerVal) * 0.022));
    if (scaleObj.items.any((id) { try { return sim.sources.firstWhere((s) => s.id == id).val == 220; } catch (_) { return false; } }) && step == 4) {
      tilt = 0.45;
    }

    canvas.rotate(tilt);
    _drawRoundedRect(canvas, 35, -1, 310, 18, 0, const Color(0xFF64748B), const Color(0xFF1E293B), 3);

    // Left Pan
    canvas.save();
    canvas.translate(-100, 0);
    canvas.rotate(-tilt);
    canvas.drawLine(const Offset(-45, 60), const Offset(0, 0), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 3);
    canvas.drawLine(const Offset(45, 60), const Offset(0, 0), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 3);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 65), width: 130, height: 28), Paint()..color = const Color(0xFF94A3B8));

    for (int i = 0; i < scaleObj.items.length; i++) {
      try {
        var src = sim.sources.firstWhere((s) => s.id == scaleObj.items[i]);
        List<double> offsets = [-20, 0, 20, -10, 10];
        double ox = offsets[i % 5];
        double h = src.val == 220 ? 120 : (src.val / 150) * 85;
        canvas.save();
        canvas.translate(ox, 65 - h / 2);
        _drawRoundedRect(canvas, 0, 0, 28, h, 4, _getBlockColor(src.val), const Color(0xFF0F172A), 1.5);
        _drawTextCenter(canvas, src.val.toStringAsFixed(0), 0, 0, 10, Colors.white, true);
        canvas.restore();
      } catch (_) {}
    }
    canvas.restore();

    double range = scaleObj.max - scaleObj.min;
    for (double v = scaleObj.min; v <= scaleObj.max; v += 10) {
      double px = (v - scaleObj.min) * (180 / range);
      canvas.drawRect(Rect.fromLTWH(px, -10, 2, v % 50 == 0 ? 14 : 7), Paint()..color = const Color(0xFF1E293B));
      if (v % 50 == 0) _drawTextCenter(canvas, v.toStringAsFixed(0), px, -22, 11, Colors.white, true);
    }

    double ptrX = (scaleObj.pointerVal - scaleObj.min) * (180 / range);
    Path ptr = Path()..moveTo(ptrX - 12, 28)..lineTo(ptrX + 12, 28)..lineTo(ptrX, 8)..close();
    canvas.drawPath(ptr, Paint()..color = const Color(0xFFEF4444));
    _drawRoundedRect(canvas, ptrX, 42, 42, 24, 4, Colors.white, const Color(0xFFEF4444), 2.5);
    _drawTextCenter(canvas, scaleObj.pointerVal.round().toString(), ptrX, 42, 11, const Color(0xFFEF4444), true);

    canvas.restore();
  }

  void _drawBalanceScale(Canvas canvas, SimScale scaleObj) {
    canvas.save();
    canvas.translate(scaleObj.x, scaleObj.y);

    Path base = Path()..moveTo(-35, 180)..lineTo(35, 180)..lineTo(12, 0)..lineTo(-12, 0)..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFF1E293B));

    double sum = scaleObj.items.fold(0, (acc, id) {
      try { return acc + sim.sources.firstWhere((x) => x.id == id).val; } catch (_) { return acc; }
    });
    int count = scaleObj.items.length;
    double tMean = count > 0 ? sum / count : scaleObj.min;
    double tilt = max(-0.45, min(0.45, (tMean - scaleObj.pointerVal) * 0.0035));
    if (scenario == 5 && scaleObj.items.any((id) { try { return sim.sources.firstWhere((s) => s.id == id).val == 45.0; } catch (_) { return false; } }) && step == 0) {
      tilt = 0.45;
    }

    canvas.rotate(tilt);
    _drawRoundedRect(canvas, 25, -1, 310, 18, 0, const Color(0xFF64748B), const Color(0xFF1E293B), 3);

    canvas.save();
    canvas.translate(-110, 0);
    canvas.rotate(-tilt);
    canvas.drawLine(const Offset(-45, 60), const Offset(0, 0), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 3);
    canvas.drawLine(const Offset(45, 60), const Offset(0, 0), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 3);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 65), width: 130, height: 28), Paint()..color = const Color(0xFF94A3B8));

    for (int i = 0; i < scaleObj.items.length; i++) {
      try {
        var src = sim.sources.firstWhere((s) => s.id == scaleObj.items[i]);
        List<double> offsets = [-22, 0, 22, -11, 11, 0, -5];
        double ox = offsets[i % 7];
        canvas.save();
        canvas.translate(ox, 65);
        if (src.type == 'coin') _drawCoinStack(canvas, 0, 0, src.val, false);
        else if (src.type == 'time') _drawDigitalClock(canvas, 0, -10, src.val, false, src.val == 45.0);
        canvas.restore();
      } catch (_) {}
    }
    canvas.restore();

    double range = scaleObj.max - scaleObj.min;
    double smallStep = range > 100 ? (range / 25) : 2;
    double bigStep = range > 100 ? (range / 5) : 10;
    if (scenario == 5) { bigStep = 10; smallStep = 2; }

    for (double v = scaleObj.min; v <= scaleObj.max; v += smallStep) {
      double px = (v - scaleObj.min) * (180 / range);
      bool isMajor = (v % bigStep == 0) || (v == scaleObj.min);
      canvas.drawRect(Rect.fromLTWH(px, -10, 2, isMajor ? 14 : 7), Paint()..color = const Color(0xFF1E293B));
      if (isMajor) {
        String lbl = v > 1000 ? "1.0M" : v.toStringAsFixed(0);
        _drawTextCenter(canvas, lbl, px, -22, 11, Colors.white, true);
      }
    }

    double ptrX = (scaleObj.pointerVal - scaleObj.min) * (180 / range);
    Path ptr = Path()..moveTo(ptrX - 12, 28)..lineTo(ptrX + 12, 28)..lineTo(ptrX, 8)..close();
    canvas.drawPath(ptr, Paint()..color = const Color(0xFFEF4444));
    _drawRoundedRect(canvas, ptrX, 42, 42, 24, 4, Colors.white, const Color(0xFFEF4444), 2.5);
    String pLbl = scaleObj.pointerVal > 1000 ? "\$1M" : (scenario == 5 ? scaleObj.pointerVal.toStringAsFixed(1) : scaleObj.pointerVal.round().toString());
    _drawTextCenter(canvas, pLbl, ptrX, 42, 11, const Color(0xFFEF4444), true);

    canvas.restore();
  }

  void _drawMachineBack(Canvas canvas, SimMachine m) {
    canvas.save();
    canvas.translate(m.x, m.y);
    _drawRoundedRect(canvas, 0, 0, 280, 180, 20, const Color(0xFFCBD5E1), const Color(0xFF475569), 4);
    _drawRoundedRect(canvas, 0, 10, 240, 140, 10, const Color(0xFF0F172A), const Color(0xFF334155), 3);
    canvas.restore();
  }

  void _drawMachineFront(Canvas canvas, SimMachine m, double animProgress) {
    canvas.save();
    canvas.translate(m.x, m.y);
    _drawRoundedRect(canvas, 0, -65, 220, 35, 8, const Color(0xFF334155), const Color(0xFF1E293B), 2);
    _drawTextCenter(canvas, t('label_averaging_machine'), 0, -65, 16, Colors.white, true);

    if (sim.animProgress > 0) {
      double alpha = sin(animProgress * pi) * 0.5;
      _drawRoundedRect(canvas, 0, 10, 240, 140, 10, Color.fromRGBO(253, 224, 71, alpha), Colors.transparent, 0);

      canvas.save();
      canvas.translate(0, 10);
      canvas.rotate(animProgress * pi * 4);
      Paint p = Paint()..color = const Color(0xFFCBD5E1);
      for (int i = 0; i < 8; i++) {
        canvas.rotate(pi / 4);
        canvas.drawRect(const Rect.fromLTWH(15, -6, 15, 12), p);
      }
      canvas.drawCircle(Offset.zero, 20, p);
      canvas.restore();

      if (animProgress > 0.5) {
        double p2 = (animProgress - 0.5) * 2;
        double dropY = 10 + (p2 * 150);
        canvas.save();
        canvas.clipRect(const Rect.fromLTWH(-70, 80, 140, 200));
        _drawFamilyMember(canvas, 0, dropY, 135, false, true, false);
        canvas.restore();
      }
    }
    canvas.restore();
  }

  void _drawS3SummaryChalkboard(Canvas canvas) {
    _drawRoundedRect(canvas, 0, 0, 720, 380, 16, const Color(0xFF022C22), const Color(0xFF475569), 10);
    _drawTextCenter(canvas, t('s3_card_title'), 0, -150, 22, const Color(0xFFFDE047), true);

    canvas.save();
    canvas.translate(-180, 20);
    _drawRoundedRect(canvas, 0, 0, 300, 220, 12, const Color(0x4D1E293B), const Color(0xFF475569), 2);
    _drawTextCenter(canvas, t('s3_card_without'), 0, -80, 16, Colors.redAccent, true);
    _drawTextCenter(canvas, t('s3_card_heights_1'), 0, -40, 13, Colors.white, false);
    _drawTextCenter(canvas, t('s3_card_mean_1'), 0, 10, 15, Colors.white, true);
    _drawTextCenter(canvas, t('s3_card_median_1'), 0, 50, 15, Colors.greenAccent, true);
    canvas.restore();

    canvas.save();
    canvas.translate(180, 20);
    _drawRoundedRect(canvas, 0, 0, 300, 220, 12, const Color(0x4D1E293B), const Color(0xFF475569), 2);
    _drawTextCenter(canvas, t('s3_card_with'), 0, -80, 16, Colors.orangeAccent, true);
    _drawTextCenter(canvas, t('s3_card_heights_2'), 0, -40, 13, Colors.white, false);
    _drawTextCenter(canvas, t('s3_card_mean_2'), 0, 10, 15, Colors.redAccent, true);
    _drawTextCenter(canvas, t('s3_card_median_2'), 0, 50, 15, Colors.greenAccent, true);
    canvas.restore();

    _drawTextCenter(canvas, t('s3_card_learn'), 0, 150, 14, Colors.white, false);
  }
}