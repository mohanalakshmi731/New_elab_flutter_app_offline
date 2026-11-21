// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Cl6M_Ch1_A4_DiscoveringRelationshipsAmongNumberSequences());
}

// --- Audio Manager ---
class AudioManager {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  // General click/tap sound
  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  // Play a sound when a new page opens or step advances (Swoosh/Chime)
  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  // Play the Dropdown sound
  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  // Play an error sound (Soft thud - used when drag fails and snaps back)
  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  // Play when opening the main lab
  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

class Cl6M_Ch1_A4_DiscoveringRelationshipsAmongNumberSequences
    extends StatefulWidget {
  const Cl6M_Ch1_A4_DiscoveringRelationshipsAmongNumberSequences({super.key});

  @override
  State<Cl6M_Ch1_A4_DiscoveringRelationshipsAmongNumberSequences>
  createState() =>
      _Cl6M_Ch1_A4_DiscoveringRelationshipsAmongNumberSequencesState();
}

class _Cl6M_Ch1_A4_DiscoveringRelationshipsAmongNumberSequencesState
    extends State<Cl6M_Ch1_A4_DiscoveringRelationshipsAmongNumberSequences> {
  String locale = 'en';

  void toggleLanguage() {
    AudioManager.playClick();
    setState(() {
      locale = locale == 'en' ? 'hi' : 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Pattern Builders',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFEAB308),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans'),
          bodyLarge: TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      home: VirtualLabScreen(locale: locale, onToggleLanguage: toggleLanguage),
    );
  }
}

class VirtualLabScreen extends StatefulWidget {
  final String locale;
  final VoidCallback onToggleLanguage;

  const VirtualLabScreen({
    super.key,
    required this.locale,
    required this.onToggleLanguage,
  });

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen>
    with TickerProviderStateMixin {
  bool _isCurtainOpen = true;
  bool _isSidebarOpen = true;

  int _currentScenario = 0;
  int _currentStep = 0;

  // Canvas Camera State
  double _cameraX = 0;
  double _cameraY = 0;
  double _cameraScale = 1.0;

  // Canvas Engine State
  final List<Entity> _entities = [];
  String? _globalSequence;
  String? _ruleDisplay;

  // Drag State
  Entity? _draggedEntity;
  Offset _dragOffset = Offset.zero;
  Offset _dragStartPos = Offset.zero;
  bool _isPanning = false;
  Offset _lastPanFocal = Offset.zero;
  double _lastPanScale = 1.0;

  // Animation controllers
  late AnimationController _pulseController;
  int _machineSum = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _pulseController.dispose();
    super.dispose();
  }

  // Helper method replacing 'firstOrNull' to prevent crashes on older Dart versions
  Entity? _getEntitySafe(bool Function(Entity) test) {
    try {
      return _entities.firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  void _enterLab() {
    AudioManager.curtainScreen();
    setState(() {
      _isCurtainOpen = false;
    });
    _loadScenario(0);
  }

  void _resetLab() {
    AudioManager.playClick();
    setState(() {
      _isCurtainOpen = true;
      _isSidebarOpen = true;
      _currentScenario = 0;
      _currentStep = 0;
      _entities.clear();
      _cameraX = 0;
      _cameraY = 0;
      _cameraScale = 1.0;
    });
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      _entities.clear();
      _globalSequence = null;
      _ruleDisplay = null;
      _machineSum = 0;
      _cameraScale = 1.0;
      _cameraX = _isSidebarOpen ? MediaQuery.of(context).size.width * 0.15 : 0;
      _cameraY = 50;

      double dGap = 40;
      double dR = 15;

      if (index == 0) {
        // Odd Gnomon
        _globalSequence = "1";
        _ruleDisplay = widget.locale == 'en'
            ? "Sum of odds = Square"
            : "विषम योग = वर्ग";
        _entities.add(
          Entity(
            type: 'dot',
            x: -dGap / 2,
            y: -dGap / 2,
            radius: dR,
            color: const Color(0xFFA855F7),
            z: 1,
          ),
        );
        _entities.add(
          Entity(
            type: 'gnomon',
            x: 0,
            y: 130,
            z: 5,
            isDraggable: true,
            targetX: -dGap / 2,
            targetY: -dGap / 2,
            dots: [
              DotOffset(dGap, 0, dR, const Color(0xFF22C55E)),
              DotOffset(dGap, dGap, dR, const Color(0xFF22C55E)),
              DotOffset(0, dGap, dR, const Color(0xFF22C55E)),
            ],
          ),
        );
      } else if (index == 1) {
        // Triangular Twins
        _globalSequence = "3 + 6 = ?";
        double dY = math.sqrt(3) * dGap / 2;
        List<DotOffset> t3 = [
          DotOffset(0, 0, dR, const Color(0xFF3B82F6)),
          DotOffset(-dGap / 2, dY, dR, const Color(0xFF3B82F6)),
          DotOffset(dGap / 2, dY, dR, const Color(0xFF3B82F6)),
        ];
        List<DotOffset> t6 = t3
            .map((d) => DotOffset(d.dx, d.dy, d.r, const Color(0xFFEF4444)))
            .toList();
        t6.addAll([
          DotOffset(-dGap, 2 * dY, dR, const Color(0xFFEF4444)),
          DotOffset(0, 2 * dY, dR, const Color(0xFFEF4444)),
          DotOffset(dGap, 2 * dY, dR, const Color(0xFFEF4444)),
        ]);

        _entities.add(
          Entity(
            type: 'triangle_group',
            dots: t3,
            x: -150,
            y: 0,
            z: 5,
            canRotate: true,
            isDraggable: true,
            targetX: 1.5 * dGap,
            targetY: dY,
            targetAngle: math.pi,
          ),
        );
        _entities.add(
          Entity(
            type: 'triangle_group',
            dots: t6,
            x: 0,
            y: 0,
            z: 1,
            canRotate: false,
          ),
        );
      } else if (index == 2) {
        // Counting Mountain
        _globalSequence = "1 + 2 + 3 + 2 + 1 = ?";
        double gap = 45;
        double r = 20;
        double tY = -20;
        List<Offset> ghosts = [
          Offset(0, tY - gap),
          Offset(0, tY),
          Offset(0, tY + gap),
          Offset(-gap, tY - gap / 2),
          Offset(-gap, tY + gap / 2),
          Offset(gap, tY - gap / 2),
          Offset(gap, tY + gap / 2),
          Offset(-gap * 2, tY),
          Offset(gap * 2, tY),
        ];
        for (var pt in ghosts) {
          _entities.add(
            Entity(
              type: 'ghost_dot',
              x: pt.dx,
              y: pt.dy,
              radius: r,
              shape: 'square',
            ),
          );
        }
        _entities.add(
          Entity(
            type: 'diamond_group',
            x: 0,
            y: 150,
            z: 5,
            isDraggable: true,
            targetX: 0,
            targetY: tY,
            dots: [
              DotOffset(0, -gap, r, const Color(0xFFA855F7), 'square'),
              DotOffset(0, 0, r, const Color(0xFFA855F7), 'square'),
              DotOffset(0, gap, r, const Color(0xFFA855F7), 'square'),
            ],
          ),
        );
        _entities.add(
          Entity(
            type: 'diamond_group',
            x: -80,
            y: 150,
            z: 5,
            isDraggable: false,
            targetX: -gap,
            targetY: tY,
            dots: [
              DotOffset(0, -gap / 2, r, const Color(0xFF3B82F6), 'square'),
              DotOffset(0, gap / 2, r, const Color(0xFF3B82F6), 'square'),
            ],
          ),
        );
        _entities.add(
          Entity(
            type: 'diamond_group',
            x: 80,
            y: 150,
            z: 5,
            isDraggable: false,
            targetX: gap,
            targetY: tY,
            dots: [
              DotOffset(0, -gap / 2, r, const Color(0xFF3B82F6), 'square'),
              DotOffset(0, gap / 2, r, const Color(0xFF3B82F6), 'square'),
            ],
          ),
        );
        _entities.add(
          Entity(
            type: 'diamond_group',
            x: -160,
            y: 150,
            z: 5,
            isDraggable: false,
            targetX: -gap * 2,
            targetY: tY,
            dots: [DotOffset(0, 0, r, const Color(0xFF22C55E), 'square')],
          ),
        );
        _entities.add(
          Entity(
            type: 'diamond_group',
            x: 160,
            y: 150,
            z: 5,
            isDraggable: false,
            targetX: gap * 2,
            targetY: tY,
            dots: [DotOffset(0, 0, r, const Color(0xFF22C55E), 'square')],
          ),
        );
      } else if (index == 3) {
        // Hexagon Stack
        _ruleDisplay = widget.locale == 'en'
            ? "Shape: Hexagon (1 sphere)"
            : "आकार: षट्भुज (1 गोला)";
        _entities.add(
          Entity(
            type: 'iso_sphere',
            ix: 0,
            iy: 0,
            iz: 0,
            targetIx: 0,
            targetIy: 0,
            targetIz: 0,
            color: const Color(0xFFEAB308),
          ),
        );
        List<IsoOffset> hex7pts = _getHexRingOffsetsIso(0)
          ..addAll(_getHexRingOffsetsIso(1));
        for (var pt in hex7pts) {
          pt.iz = 0.5;
        }
        _entities.add(
          Entity(
            type: 'iso_sphere_group',
            offsets: hex7pts,
            x: 0,
            y: 150,
            z: 5,
            color: const Color(0xFF3B82F6),
            isDraggable: true,
            targetX: 0,
            targetY: -10,
          ),
        );
      } else if (index == 4) {
        // Power Machine
        String sumLabel = widget.locale == 'en' ? "SUM: " : "योग: ";
        _globalSequence = "${sumLabel}0";
        _entities.add(
          Entity(
            type: 'machine_zone',
            x: -100,
            y: 60,
            label: widget.locale == 'en' ? 'SUMMER' : 'योग (SUM)',
            isDropZone: true,
          ),
        );
        _entities.add(
          Entity(
            type: 'machine_zone',
            x: 100,
            y: 60,
            label: widget.locale == 'en' ? 'NEXT POWER 2' : 'अगली घात 2',
            isDropZone: false,
          ),
        );
        _entities.add(
          Entity(
            type: 'block_bar',
            val: 1,
            color: const Color(0xFF3B82F6),
            x: -100,
            y: 330,
            isDraggable: true,
            targetX: -100,
            targetY: 60,
          ),
        );
        _entities.add(
          Entity(
            type: 'block_bar',
            val: 2,
            color: const Color(0xFF22C55E),
            x: 0,
            y: 330,
            isDraggable: false,
            targetX: -100,
            targetY: 60,
          ),
        );
        _entities.add(
          Entity(
            type: 'block_bar',
            val: 4,
            color: const Color(0xFFEAB308),
            x: 100,
            y: 330,
            isDraggable: false,
            targetX: -100,
            targetY: 60,
          ),
        );
        _entities.add(
          Entity(
            type: 'block_bar',
            val: 0,
            id: 'sum_result',
            x: -100,
            y: 60,
            isResult: false,
            color: const Color(0xFF3B82F6),
          ),
        );
        _entities.add(
          Entity(
            type: 'block_bar',
            val: 0,
            id: 'double_result',
            x: 100,
            y: 60,
            isResult: true,
          ),
        );
      }
    });
  }

  List<IsoOffset> _getHexRingOffsetsIso(int radius) {
    if (radius == 0) return [IsoOffset(0, 0)];
    List<IsoOffset> pts = [];
    double ix = radius.toDouble(), iy = 0;
    List<Offset> dirs = const [
      Offset(0, 1),
      Offset(-1, 1),
      Offset(-1, 0),
      Offset(0, -1),
      Offset(1, -1),
      Offset(1, 0),
    ];
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < radius; j++) {
        pts.add(IsoOffset(ix, iy));
        ix += dirs[i].dx;
        iy += dirs[i].dy;
      }
    }
    return pts;
  }

  Offset _screenToWorld(Offset screenPos) {
    final Size size = MediaQuery.of(context).size;
    final double x = (screenPos.dx - size.width / 2 - _cameraX) / _cameraScale;
    final double y = (screenPos.dy - size.height / 2 - _cameraY) / _cameraScale;
    return Offset(x, y);
  }

  void _handleTapUp(TapUpDetails details) {
    Offset worldPos = _screenToWorld(details.localPosition);

    for (int i = _entities.length - 1; i >= 0; i--) {
      Entity ent = _entities[i];
      if (!ent.isDraggable || ent.isHidden) continue;

      if (ent.canRotate) {
        double minX = double.infinity,
            maxX = -double.infinity,
            minY = double.infinity,
            maxY = -double.infinity;
        for (var d in ent.dots!) {
          if (d.dx < minX) minX = d.dx;
          if (d.dx > maxX) maxX = d.dx;
          if (d.dy < minY) minY = d.dy;
          if (d.dy > maxY) maxY = d.dy;
        }

        // Generous tap hitbox around the shape to trigger rotation
        if (worldPos.dx >= ent.x + minX - 60 &&
            worldPos.dx <= ent.x + maxX + 60 &&
            worldPos.dy >= ent.y + minY - 60 &&
            worldPos.dy <= ent.y + maxY + 60) {
          AudioManager.playClick();
          setState(() {
            ent.angle += math.pi;
            // Undo any accidental drag movement and cancel drag state safely
            if (_draggedEntity == ent) {
              ent.x = _dragStartPos.dx + _dragOffset.dx;
              ent.y = _dragStartPos.dy + _dragOffset.dy;
              _draggedEntity = null;
            }
          });
          _evaluateScenarioState();
          return;
        }
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    Offset worldPos = _screenToWorld(details.focalPoint);
    _dragStartPos = worldPos;

    for (int i = _entities.length - 1; i >= 0; i--) {
      Entity ent = _entities[i];
      if (!ent.isDraggable || ent.isHidden) continue;

      bool hit = false;
      if (ent.type == 'gnomon' ||
          ent.type == 'triangle_group' ||
          ent.type == 'diamond_group') {
        double minX = double.infinity,
            maxX = -double.infinity,
            minY = double.infinity,
            maxY = -double.infinity;
        for (var d in ent.dots!) {
          if (d.dx < minX) minX = d.dx;
          if (d.dx > maxX) maxX = d.dx;
          if (d.dy < minY) minY = d.dy;
          if (d.dy > maxY) maxY = d.dy;
        }

        // Expanded hitbox for grabbing shapes easily
        if (worldPos.dx >= ent.x + minX - 60 &&
            worldPos.dx <= ent.x + maxX + 60 &&
            worldPos.dy >= ent.y + minY - 60 &&
            worldPos.dy <= ent.y + maxY + 60) {
          hit = true;
        }
      } else if (ent.type == 'iso_sphere_group') {
        if ((worldPos - Offset(ent.x, ent.y)).distance <= 100) hit = true;
      } else if (ent.type == 'block_bar') {
        double h = ent.val * 40;
        if (worldPos.dx >= ent.x - 30 &&
            worldPos.dx <= ent.x + 30 &&
            worldPos.dy >= ent.y - h - 10 &&
            worldPos.dy <= ent.y + 10) {
          hit = true;
        }
      }

      if (hit) {
        AudioManager.playClick();
        setState(() {
          _draggedEntity = ent;
          _dragOffset = Offset(ent.x - worldPos.dx, ent.y - worldPos.dy);
        });
        return;
      }
    }

    // Start pan
    _isPanning = true;
    _lastPanFocal = details.focalPoint;
    _lastPanScale = 1.0;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_draggedEntity != null) {
      Offset worldPos = _screenToWorld(details.focalPoint);
      setState(() {
        _draggedEntity!.x = worldPos.dx + _dragOffset.dx;
        _draggedEntity!.y = worldPos.dy + _dragOffset.dy;

        Entity ent = _draggedEntity!;
        ent.isNearTarget = false;

        if (ent.targetX != null) {
          double dist =
              (Offset(ent.x, ent.y) - Offset(ent.targetX!, ent.targetY!))
                  .distance;
          if (ent.type == 'triangle_group') {
            double currentAngle = ent.angle % (math.pi * 2);
            if (currentAngle < 0) currentAngle += math.pi * 2;
            double targetAngle = (ent.targetAngle ?? 0) % (math.pi * 2);
            double angleDiff = (currentAngle - targetAngle).abs();
            bool isRotatedCorrectly =
                angleDiff < 0.1 || (angleDiff - math.pi * 2).abs() < 0.1;
            ent.isNearTarget = dist < 80 && isRotatedCorrectly;
          } else {
            ent.isNearTarget = dist < 80;
          }
        }
      });
    } else if (_isPanning) {
      setState(() {
        _cameraX += details.focalPoint.dx - _lastPanFocal.dx;
        _cameraY += details.focalPoint.dy - _lastPanFocal.dy;

        double newScale = _cameraScale * (details.scale / _lastPanScale);
        _cameraScale = newScale.clamp(0.2, 3.0);

        _lastPanFocal = details.focalPoint;
        _lastPanScale = details.scale;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_draggedEntity != null) {
      Entity ent = _draggedEntity!;

      if (ent.isNearTarget) {
        AudioManager.playClick();
        setState(() {
          ent.x = ent.targetX!;
          ent.y = ent.targetY!;
          if (ent.targetAngle != null) ent.angle = ent.targetAngle!;
          ent.isDraggable = false;
          ent.isNearTarget = false;
        });

        if (ent.type == 'block_bar') {
          _evaluateMachineState(ent);
        } else {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _evaluateScenarioState();
          });
        }
      } else {
        AudioManager.playError();
        setState(() {
          ent.x = _dragStartPos.dx + _dragOffset.dx;
          ent.y = _dragStartPos.dy + _dragOffset.dy;
        });
      }

      setState(() {
        _draggedEntity = null;
      });
    }
    _isPanning = false;
  }

  void _evaluateMachineState(Entity bar) {
    setState(() {
      _machineSum += bar.val.toInt();
      bar.isHidden = true;

      Entity? resSum = _getEntitySafe((e) => e.id == 'sum_result');
      Entity? resDouble = _getEntitySafe((e) => e.id == 'double_result');

      if (resSum != null) resSum.val = _machineSum.toDouble();
      int nextPow = 1;
      while (nextPow <= _machineSum) {
        nextPow *= 2;
      }
      if (_machineSum == 0) nextPow = 0;
      if (resDouble != null) resDouble.val = nextPow.toDouble();

      String sumLabel = widget.locale == 'en' ? "SUM: " : "योग: ";
      _globalSequence = "$sumLabel$_machineSum";
    });

    // For scenario 4 (index 4) final step, give the user a brief moment to see the result before showing the popup
    int delayMs = (_currentScenario == 4 && _machineSum == 7) ? 1000 : 500;

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _advanceStep();
    });
  }

  void _evaluateScenarioState() {
    Map<String, dynamic> loc = i18n[widget.locale] ?? i18n['en']!;
    List<dynamic> steps = loc['scenarios']?[_currentScenario]?['steps'] ?? [];
    if (steps.isEmpty || _currentStep >= steps.length - 1) return;

    if (_currentScenario == 0 || _currentScenario == 2) {
      if (!_entities.any(
        (g) =>
            (g.type == 'gnomon' || g.type == 'diamond_group') &&
            g.isDraggable &&
            !g.isHidden,
      )) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _advanceStep();
        });
      }
    } else if (_currentScenario == 1) {
      double normalize(double a) {
        double ang = a % (math.pi * 2);
        if (ang < 0) ang += math.pi * 2;
        return ang;
      }

      if (_currentStep == 0) {
        var t3 = _getEntitySafe((e) => e.dots?.length == 3 && e.canRotate);
        if (t3 != null && (normalize(t3.angle) - math.pi).abs() < 0.1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              var t3Check = _getEntitySafe(
                (e) => e.dots?.length == 3 && e.canRotate,
              );
              if (t3Check != null &&
                  (normalize(t3Check.angle) - math.pi).abs() < 0.1) {
                _advanceStep();
              }
            }
          });
        }
      } else if (_currentStep == 1) {
        var t3 = _getEntitySafe((e) => e.dots?.length == 3 && e.canRotate);
        if (t3 != null && !t3.isDraggable) {
          setState(() {
            _globalSequence = "3 + 6 = 9 (Square!)";
          });
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) _advanceStep();
          });
        }
      } else if (_currentStep == 2) {
        var t6 = _getEntitySafe((e) => e.dots?.length == 6 && e.canRotate);
        if (t6 != null && (normalize(t6.angle) - math.pi).abs() < 0.1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              var t6Check = _getEntitySafe(
                (e) => e.dots?.length == 6 && e.canRotate,
              );
              if (t6Check != null &&
                  (normalize(t6Check.angle) - math.pi).abs() < 0.1) {
                _advanceStep();
              }
            }
          });
        }
      } else if (_currentStep == 3) {
        var t6 = _getEntitySafe((e) => e.dots?.length == 6 && e.canRotate);
        if (t6 != null && !t6.isDraggable) {
          setState(() {
            _globalSequence = "6 + 10 = 16 (Square!)";
          });
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) _advanceStep();
          });
        }
      }
    } else if (_currentScenario == 3) {
      if (!_entities.any(
            (g) => g.type == 'iso_sphere_group' && g.isDraggable && !g.isHidden,
          ) &&
          _currentStep < 2) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _advanceStep();
        });
      }
    }
  }

  void _advanceStep() {
    Map<String, dynamic> loc = i18n[widget.locale] ?? i18n['en']!;
    List<dynamic> steps = loc['scenarios']?[_currentScenario]?['steps'] ?? [];
    if (steps.isEmpty || _currentStep >= steps.length - 1) return;

    AudioManager.playPageOpen();

    setState(() {
      _currentStep++;

      double dGap = 40;
      double dR = 15;
      bool isFinalStep = _currentStep == steps.length - 1;

      if (_currentScenario == 0) {
        if (_currentStep == 1) {
          _globalSequence = "1 + 3 = 4";
        } else if (_currentStep == 2) {
          _globalSequence = "1 + 3 + 5 = 9";
        } else if (_currentStep == 3) {
          _globalSequence = "1 + 3 + 5 + 7 = 16";
        }

        if (!isFinalStep) {
          int s = _currentStep + 2;
          Color color = _currentStep == 1
              ? const Color(0xFF3B82F6)
              : const Color(0xFFEAB308);
          List<DotOffset> dots = [];
          for (int i = 0; i < s; i++) {
            dots.add(DotOffset(i * dGap, (s - 1) * dGap, dR, color));
          }
          for (int i = 0; i < s - 1; i++) {
            dots.add(DotOffset((s - 1) * dGap, i * dGap, dR, color));
          }
          _entities.add(
            Entity(
              type: 'gnomon',
              dots: dots,
              x: 0,
              y: 130,
              z: 5,
              isDraggable: true,
              targetX: -dGap / 2,
              targetY: -dGap / 2,
            ),
          );
        }
      } else if (_currentScenario == 1) {
        double dY = math.sqrt(3) * dGap / 2;
        if (_currentStep == 2 && !isFinalStep) {
          _globalSequence = "6 + 10 = ?";
          List<DotOffset> t6 = [
            DotOffset(0, 0, dR),
            DotOffset(-dGap / 2, dY, dR),
            DotOffset(dGap / 2, dY, dR),
            DotOffset(-dGap, 2 * dY, dR),
            DotOffset(0, 2 * dY, dR),
            DotOffset(dGap, 2 * dY, dR),
          ];
          for (var d in t6) {
            d.color = const Color(0xFFEF4444);
          }
          List<DotOffset> t10 = t6
              .map((d) => DotOffset(d.dx, d.dy, d.r, const Color(0xFFEAB308)))
              .toList();
          t10.addAll([
            DotOffset(-dGap * 1.5, 3 * dY, dR, const Color(0xFFEAB308)),
            DotOffset(-dGap / 2, 3 * dY, dR, const Color(0xFFEAB308)),
            DotOffset(dGap / 2, 3 * dY, dR, const Color(0xFFEAB308)),
            DotOffset(dGap * 1.5, 3 * dY, dR, const Color(0xFFEAB308)),
          ]);

          _entities.removeWhere((e) => e.type == 'triangle_group');
          _entities.add(
            Entity(
              type: 'triangle_group',
              dots: t6,
              x: -150,
              y: 0,
              z: 5,
              canRotate: true,
              isDraggable: true,
              targetX: 2 * dGap,
              targetY: 2 * dY,
              targetAngle: math.pi,
            ),
          );
          _entities.add(
            Entity(
              type: 'triangle_group',
              dots: t10,
              x: 0,
              y: 0,
              z: 1,
              canRotate: false,
            ),
          );
        }
      } else if (_currentScenario == 2) {
        if (_currentStep == 1) {
          _entities
              .where((e) => e.type == 'diamond_group' && e.dots?.length == 2)
              .forEach((e) => e.isDraggable = true);
        } else if (_currentStep == 2) {
          _entities
              .where((e) => e.type == 'diamond_group' && e.dots?.length == 1)
              .forEach((e) => e.isDraggable = true);
        } else if (_currentStep == 3) {
          _globalSequence = "1 + 2 + 3 + 2 + 1 = 9 (Square!)";
        }
      } else if (_currentScenario == 3) {
        if (_currentStep == 1 && !isFinalStep) {
          _ruleDisplay = widget.locale == 'en'
              ? "Shape: Irregular (8 spheres)"
              : "आकार: अनियमित (8 गोले)";
          _entities.removeWhere((e) => e.type == 'iso_sphere_group');
          List<IsoOffset> hex7pts = _getHexRingOffsetsIso(0)
            ..addAll(_getHexRingOffsetsIso(1));
          for (var pt in hex7pts) {
            _entities.add(
              Entity(
                type: 'iso_sphere',
                ix: pt.ix,
                iy: pt.iy,
                iz: 1,
                targetIx: pt.ix,
                targetIy: pt.iy,
                targetIz: 1,
                color: const Color(0xFF3B82F6),
              ),
            );
          }
          List<IsoOffset> hex19pts = _getHexRingOffsetsIso(0)
            ..addAll(_getHexRingOffsetsIso(1))
            ..addAll(_getHexRingOffsetsIso(2));
          for (var pt in hex19pts) {
            pt.iz = 1.0;
          }
          _entities.add(
            Entity(
              type: 'iso_sphere_group',
              offsets: hex19pts,
              x: 0,
              y: 200,
              z: 5,
              color: const Color(0xFFEF4444),
              isDraggable: true,
              targetX: 0,
              targetY: -20,
            ),
          );
        } else if (_currentStep == 2 && !isFinalStep) {
          _ruleDisplay = widget.locale == 'en'
              ? "Shape: Irregular (27 spheres)"
              : "आकार: अनियमित (27 गोले)";
          _entities.removeWhere((e) => e.type == 'iso_sphere_group');
          List<IsoOffset> hex19pts = _getHexRingOffsetsIso(0)
            ..addAll(_getHexRingOffsetsIso(1))
            ..addAll(_getHexRingOffsetsIso(2));
          for (var pt in hex19pts) {
            _entities.add(
              Entity(
                type: 'iso_sphere',
                ix: pt.ix,
                iy: pt.iy,
                iz: 2,
                targetIx: pt.ix,
                targetIy: pt.iy,
                targetIz: 2,
                color: const Color(0xFFEF4444),
              ),
            );
          }
          // Auto-trigger the hint animation after a short delay so the user doesn't have to click a button
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) _triggerHexHint();
          });
        }
      } else if (_currentScenario == 4) {
        if (_currentStep == 1) {
          var bar = _getEntitySafe((e) => e.val == 2 && !e.isDraggable);
          if (bar != null) bar.isDraggable = true;
        }
        if (_currentStep == 2) {
          var bar = _getEntitySafe((e) => e.val == 4 && !e.isDraggable);
          if (bar != null) bar.isDraggable = true;
        }
      }
    });
  }

  void _triggerHexHint() {
    setState(() {
      _ruleDisplay = widget.locale == 'en'
          ? "Shape: CUBE! (3x3x3)"
          : "आकार: घन! (3x3x3)";
      int i = 0;
      var spheres = _entities.where((e) => e.type == 'iso_sphere').toList();
      for (int z = 0; z <= 2; z++) {
        for (int y = -1; y <= 1; y++) {
          for (int x = -1; x <= 1; x++) {
            if (i < spheres.length) {
              spheres[i].targetIx = x.toDouble();
              spheres[i].targetIy = y.toDouble();
              spheres[i].targetIz = z.toDouble();
            }
            i++;
          }
        }
      }
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _advanceStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- Defensive lookup to prevent _TypeError casts entirely ---
    final Map<String, dynamic> loc = i18n[widget.locale] ?? i18n['en']!;
    final List<dynamic> scenarios = loc['scenarios'] ?? [];

    // Safely extract scenario strings
    final Map<String, dynamic> currentScenarioData =
        scenarios.isNotEmpty && _currentScenario < scenarios.length
        ? scenarios[_currentScenario]
        : {'title': '', 'objective': '', 'steps': []};

    final List<dynamic> steps = currentScenarioData['steps'] ?? [];
    final bool isComplete =
        steps.isNotEmpty && _currentStep >= steps.length - 1;

    // Safely extract step strings
    final String currentStepText =
        (steps.isNotEmpty && _currentStep >= 0 && _currentStep < steps.length)
        ? (steps[_currentStep]['text']?.toString() ?? '')
        : '';

    // Safely extract top-level strings
    final String titleText = loc['title']?.toString() ?? '';
    final String subtitleText = loc['subtitle']?.toString() ?? '';
    final String missionObjText = loc['missionObj']?.toString() ?? '';
    final String selectScenarioText = loc['selectScenario']?.toString() ?? '';
    final String enterLabText = loc['enterLab']?.toString() ?? '';
    final String nextScenarioText = loc['nextScenario']?.toString() ?? '';
    final String scenarioCompleteText =
        loc['scenarioComplete']?.toString() ?? '';
    final String objectiveText =
        currentScenarioData['objective']?.toString() ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Interactive Canvas Layer
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: GestureDetector(
                  onTapUp: _handleTapUp,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: CustomPaint(
                    painter: CanvasEnginePainter(
                      entities: _entities,
                      cameraX: _cameraX,
                      cameraY: _cameraY,
                      cameraScale: _cameraScale,
                      draggedEntity: _draggedEntity,
                      globalSequence: _globalSequence,
                      ruleDisplay: _ruleDisplay,
                      repaint: _pulseController,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Floating Mission Card (Visible if sidebar collapsed)
            if (!_isSidebarOpen && !_isCurtainOpen)
              Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width * 0.15,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentStepText.replaceAll('**', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Sidebar (Now fully scrollable)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen
                  ? 0
                  : -MediaQuery.of(context).size.width * 0.35,
              width: MediaQuery.of(context).size.width * 0.35,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.95),
                  border: Border(
                    right: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sidebar Header (Padding for menu icon)
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 66,
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 2.0),
                                          child: Icon(
                                            Icons.extension,
                                            color: Color(0xFFEAB308),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            titleText,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subtitleText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            widget.onToggleLanguage();
                                          },
                                          icon: const Icon(
                                            Icons.language,
                                            size: 16,
                                          ),
                                          label: Text(
                                            widget.locale == 'en' ? "EN" : "HI",
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withOpacity(0.1),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 0,
                                            ),
                                            minimumSize: const Size(0, 36),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          onPressed: _resetLab,
                                          icon: Row(
                                            children: [
                                              const Icon(
                                                Icons.refresh,
                                                size: 18,
                                              ),
                                              Text(
                                                widget.locale == 'en'
                                                    ? "Reset"
                                                    : "रीसेट",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          color: Colors.redAccent,
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.redAccent
                                                .withOpacity(0.2),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Dropdown
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectScenarioText.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          dropdownColor: const Color(
                                            0xFF1E293B,
                                          ),
                                          value: _currentScenario,
                                          items: List.generate(
                                            scenarios.length,
                                            (index) {
                                              return DropdownMenuItem(
                                                value: index,
                                                child: Text(
                                                  scenarios[index]['title']
                                                          ?.toString() ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          onChanged: (val) {
                                            if (val != null) {
                                              AudioManager.playDropdown();
                                              _loadScenario(val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Instructions
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        missionObjText,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigoAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        objectiveText,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      ...List.generate(steps.length, (index) {
                                        if (index > _currentStep ||
                                            index >= steps.length - 1) {
                                          return const SizedBox();
                                        }
                                        bool isCurrent = index == _currentStep;
                                        String stepTxt =
                                            steps[index]['text']?.toString() ??
                                            '';

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.05,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isCurrent
                                                  ? Colors.indigoAccent
                                                        .withOpacity(0.5)
                                                  : Colors.white.withOpacity(
                                                      0.1,
                                                    ),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                isCurrent
                                                    ? Icons.gps_fixed
                                                    : Icons.check_circle,
                                                color: isCurrent
                                                    ? Colors.indigoAccent
                                                    : Colors.green,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  stepTxt.replaceAll('**', ''),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isCurrent
                                                        ? Colors.white
                                                        : Colors.white
                                                              .withOpacity(0.5),
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),

                              // Footer
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "© ZeroScienceLab - Fall in love with math and Science",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ),
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

            // 4. Menu Icon (Fixed top-left)
            if (!_isCurtainOpen)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.orangeAccent,
                  iconSize: 28,
                  onPressed: () {
                    AudioManager.playClick();
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                      if (_isSidebarOpen) {
                        _cameraX += MediaQuery.of(context).size.width * 0.15;
                      } else {
                        _cameraX -= MediaQuery.of(context).size.width * 0.15;
                      }
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

            // 5. Completion Modal
            if (isComplete && !_isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(32),
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.locale == 'en'
                                  ? "Pattern Discovered!"
                                  : "पैटर्न खोजा गया!",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentStepText.replaceAll('**', ''),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                AudioManager.playClick();
                                if (_currentScenario < scenarios.length - 1) {
                                  _loadScenario(_currentScenario + 1);
                                } else {
                                  _resetLab();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentScenario < scenarios.length - 1
                                        ? nextScenarioText
                                        : scenarioCompleteText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentScenario < scenarios.length - 1
                                        ? Icons.arrow_forward
                                        : Icons.check_circle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 6. Curtain Screen
            if (_isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.all_inclusive,
                            size: 64,
                            color: Color(0xFFEAB308),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              titleText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitleText,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 48),
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.withOpacity(
                                        0.5 * _pulseController.value,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _enterLab,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigoAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    enterLabText,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
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
}

// --- Canvas Engine Rendering ---
class CanvasEnginePainter extends CustomPainter {
  final List<Entity> entities;
  final double cameraX;
  final double cameraY;
  final double cameraScale;
  final Entity? draggedEntity;
  final String? globalSequence;
  final String? ruleDisplay;
  final Listenable? repaint;

  CanvasEnginePainter({
    required this.entities,
    required this.cameraX,
    required this.cameraY,
    required this.cameraScale,
    this.draggedEntity,
    this.globalSequence,
    this.ruleDisplay,
    this.repaint,
  }) : super(repaint: repaint);

  Offset isoToScreen(double ix, double iy, double iz) {
    const double isoW = 30;
    const double isoH = 30;
    return Offset((ix - iy) * isoW, (ix + iy) * (isoH / 2) - iz * isoH);
  }

  void drawShape(
    Canvas canvas,
    Offset pos,
    double r,
    Color color,
    String shape, [
    bool ghost = false,
  ]) {
    final Paint fill = Paint()
      ..color = ghost ? Colors.transparent : color
      ..style = PaintingStyle.fill;
    final Paint stroke = Paint()
      ..color = ghost
          ? Colors.white.withOpacity(0.3)
          : Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (ghost) {
      stroke.color = Colors.white.withOpacity(0.4);
    }

    if (shape == 'square') {
      Rect rect = Rect.fromCenter(center: pos, width: r * 2, height: r * 2);
      if (!ghost) canvas.drawRect(rect, fill);
      canvas.drawRect(rect, stroke);
      if (!ghost && color != Colors.transparent) {
        canvas.drawRect(
          Rect.fromLTWH(pos.dx - r + 3, pos.dy - r + 3, r * 2 - 6, r),
          Paint()..color = Colors.white.withOpacity(0.2),
        );
      }
    } else {
      if (!ghost) canvas.drawCircle(pos, r, fill);
      canvas.drawCircle(pos, r, stroke);
      if (!ghost && color != Colors.transparent) {
        canvas.drawCircle(
          Offset(pos.dx - r * 0.3, pos.dy - r * 0.3),
          r * 0.3,
          Paint()..color = Colors.white.withOpacity(0.4),
        );
      }
    }
  }

  void draw3DSphere(Canvas canvas, Offset pos, double r, Color color) {
    final Rect rect = Rect.fromCircle(center: pos, radius: r);
    final Gradient grad = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.8,
      colors: [Colors.white, color, _darken(color, 0.2)],
      stops: const [0.0, 0.3, 1.0],
    );
    final Paint paint = Paint()..shader = grad.createShader(rect);
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    ); // shadow
    canvas.drawCircle(pos, r, paint);
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + cameraX, size.height / 2 + cameraY);
    canvas.scale(cameraScale, cameraScale);

    // Draw grid background
    final Paint gridLine = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += 40) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridLine);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridLine);
    }

    // Sort entities by Z
    List<Entity> sorted = List.from(entities);
    sorted.sort((a, b) {
      if (a == draggedEntity) return 1;
      if (b == draggedEntity) return -1;
      if (a.type == 'iso_sphere' && b.type == 'iso_sphere') {
        double zA = (a.ix! + a.iy!) - (a.iz! * 2);
        double zB = (b.ix! + b.iy!) - (b.iz! * 2);
        return zA.compareTo(zB);
      }
      return a.z.compareTo(b.z);
    });

    for (var ent in sorted) {
      if (ent.isHidden) continue;
      canvas.save();

      // Draw target highlight if near
      if (ent.isNearTarget && ent.targetX != null) {
        canvas.save();
        canvas.translate(ent.targetX!, ent.targetY!);
        if (ent.type == 'iso_sphere_group') {
          canvas.drawCircle(
            Offset.zero,
            60,
            Paint()..color = Colors.white.withOpacity(0.1),
          );
        } else if (ent.type == 'block_bar') {
          canvas.drawRect(
            Rect.fromLTWH(-20, -ent.val * 40, 40, ent.val * 40),
            Paint()..color = Colors.white.withOpacity(0.2),
          );
        } else if (ent.dots != null) {
          if (ent.targetAngle != null) canvas.rotate(ent.targetAngle!);
          final Paint highlight = Paint()
            ..color = Colors.white.withOpacity(0.2);
          for (var d in ent.dots!) {
            if (d.shape == 'square') {
              canvas.drawRect(
                Rect.fromCenter(
                  center: Offset(d.dx, d.dy),
                  width: d.r * 2,
                  height: d.r * 2,
                ),
                highlight,
              );
            } else {
              canvas.drawCircle(Offset(d.dx, d.dy), d.r, highlight);
            }
          }
        }
        canvas.restore();
      }

      if (ent.type == 'dot') {
        drawShape(
          canvas,
          Offset(ent.x, ent.y),
          ent.radius,
          ent.color,
          'circle',
        );
      } else if (ent.type == 'ghost_dot') {
        drawShape(
          canvas,
          Offset(ent.x, ent.y),
          ent.radius,
          Colors.transparent,
          ent.shape ?? 'circle',
          true,
        );
      } else if (ent.type == 'gnomon' ||
          ent.type == 'triangle_group' ||
          ent.type == 'diamond_group') {
        canvas.translate(ent.x, ent.y);

        canvas.rotate(ent.angle);
        for (var d in ent.dots!) {
          drawShape(
            canvas,
            Offset(d.dx, d.dy),
            d.r,
            d.color ?? ent.color,
            d.shape ?? 'circle',
          );
        }
      } else if (ent.type == 'iso_sphere') {
        // Simple lerp animation
        ent.ix = ent.ix! + (ent.targetIx! - ent.ix!) * 0.1;
        ent.iy = ent.iy! + (ent.targetIy! - ent.iy!) * 0.1;
        ent.iz = ent.iz! + (ent.targetIz! - ent.iz!) * 0.1;

        Offset sp = isoToScreen(ent.ix!, ent.iy!, ent.iz!);
        draw3DSphere(
          canvas,
          Offset(ent.x + sp.dx, ent.y + sp.dy),
          14,
          ent.color,
        );
      } else if (ent.type == 'iso_sphere_group') {
        canvas.translate(ent.x, ent.y);
        for (var pt in ent.offsets!) {
          Offset sp = isoToScreen(pt.ix, pt.iy, pt.iz ?? 0);
          draw3DSphere(canvas, sp, 14, ent.color);
        }
      } else if (ent.type == 'machine_zone') {
        canvas.translate(ent.x, ent.y);
        Paint zonePaint = Paint()
          ..color = ent.isDropZone
              ? Colors.indigoAccent.withOpacity(0.1)
              : Colors.white.withOpacity(0.02)
          ..style = PaintingStyle.fill;
        Paint zoneBorder = Paint()
          ..color = ent.isDropZone
              ? Colors.indigoAccent.withOpacity(0.8)
              : Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        Rect zoneRect = Rect.fromLTWH(-25, -320, 50, 320);
        canvas.drawRRect(
          RRect.fromRectAndRadius(zoneRect, const Radius.circular(6)),
          zonePaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(zoneRect, const Radius.circular(6)),
          zoneBorder,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-35, 0, 70, 8),
            const Radius.circular(4),
          ),
          Paint()..color = const Color(0xFF334155),
        );

        TextPainter tp = TextPainter(
          text: TextSpan(
            text: ent.label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();
        tp.paint(canvas, Offset(-tp.width / 2, 15));
      } else if (ent.type == 'block_bar') {
        canvas.translate(ent.x, ent.y);
        double w = 40, h = 40;
        Color c = ent.isResult ? const Color(0xFF22C55E) : ent.color;
        for (int i = 0; i < ent.val; i++) {
          Rect r = Rect.fromLTWH(-w / 2, -i * h - h, w, h);
          canvas.drawRect(r, Paint()..color = c);
          canvas.drawRect(
            r,
            Paint()
              ..color = Colors.black.withOpacity(0.5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
        if (ent.val > 0) {
          TextPainter tp = TextPainter(
            text: TextSpan(
              text: ent.val.toInt().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();
          tp.paint(
            canvas,
            Offset(-tp.width / 2, -(ent.val * h) / 2 - tp.height / 2),
          );
        }
      }

      canvas.restore();
    }

    // Global Texts
    if (globalSequence != null) {
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: globalSequence!,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -220));
    }

    if (ruleDisplay != null) {
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: ruleDisplay!,
          style: const TextStyle(
            color: Color(0xFF38BDF8),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -180));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CanvasEnginePainter oldDelegate) => true;
}

// --- Data Models ---
class DotOffset {
  final double dx, dy, r;
  Color? color;
  final String? shape;
  DotOffset(this.dx, this.dy, this.r, [this.color, this.shape]);
}

class IsoOffset {
  final double ix, iy;
  double? iz;
  IsoOffset(this.ix, this.iy, [this.iz]);
}

class Entity {
  String type;
  double x, y;
  int z;
  double? targetX, targetY;
  bool isDraggable;
  bool isNearTarget = false;
  bool isHidden = false;

  List<DotOffset>? dots;
  double radius;
  Color color;
  double angle;
  double? targetAngle;
  bool canRotate;

  String? shape;
  double val;
  bool isResult;
  String id;
  String label;
  bool isDropZone;

  double? ix, iy, iz;
  double? targetIx, targetIy, targetIz;
  List<IsoOffset>? offsets;

  Entity({
    required this.type,
    this.x = 0,
    this.y = 0,
    this.z = 0,
    this.targetX,
    this.targetY,
    this.isDraggable = false,
    this.dots,
    this.radius = 20,
    this.color = Colors.white,
    this.angle = 0,
    this.targetAngle,
    this.canRotate = false,
    this.shape,
    this.val = 0,
    this.isResult = false,
    this.id = '',
    this.label = '',
    this.isDropZone = false,
    this.ix,
    this.iy,
    this.iz,
    this.targetIx,
    this.targetIy,
    this.targetIz,
    this.offsets,
  });
}

// --- Localization Dictionary ---
final Map<String, Map<String, dynamic>> i18n = {
  'en': {
    'title':
        "The Pattern Builders: Discovering Relationships Among Number Sequences",
    'subtitle': "Class 6 • PATTERNS IN MATHEMATICS",
    'enterLab': "Enter Virtual Lab",
    'selectScenario': "Select Scenario",
    'missionObj': "Mission Objective",
    'hudDefault': "Select a scenario to begin.",
    'nextScenario': "Next Scenario",
    'scenarioComplete': "Scenario Complete",
    'scenarios': [
      {
        'title': "1. The Odd Gnomon Puzzle",
        'objective':
            "To visually discover and confirm that the sum of consecutive odd numbers starting from 1 always results in a square number.",
        'steps': [
          {
            'text':
                "A single purple dot (1) is on the workspace. DRAG the 3-dot gnomon from the bottom and SNAP it onto the 1-dot block.",
          },
          {
            'text':
                "A larger L-shaped gnomon made of 5 blue dots appears. DRAG the 5-dot gnomon and SNAP it onto the 2x2 square.",
          },
          {
            'text':
                "A 7-dot gnomon (yellow) appears. DRAG it and SNAP it onto the 3x3 square.",
          },
          {
            'text':
                "You've discovered a beautiful pattern! Adding consecutive odd numbers (1, 3, 5, 7...) builds perfect squares. The sum of the first 'N' odd numbers is always N-squared.",
          },
        ],
      },
      {
        'title': "2. The Triangular Twins",
        'objective':
            "To visually discover that adding two consecutive triangular numbers results in a square number.",
        'steps': [
          {
            'text':
                "On the workspace is a 3-dot triangle (blue) and a 6-dot triangle (red). TAP the 3-dot triangle to ROTATE it upside down.",
          },
          {
            'text':
                "DRAG the inverted 3-dot triangle and SNAP it onto the 6-dot triangle.",
          },
          {
            'text':
                "Now try the next pair! TAP the 6-dot triangle to ROTATE it upside down.",
          },
          {
            'text':
                "DRAG the inverted 6-dot triangle and SNAP it onto the larger 10-dot triangle.",
          },
          {
            'text':
                "Amazing! Two consecutive triangular numbers always combine to form a perfect square.",
          },
        ],
      },
      {
        'title': "3. The Counting Mountain",
        'objective':
            "To understand why adding counting numbers up to a peak and back down (e.g., 1+2+3+2+1) creates a square number.",
        'steps': [
          {
            'text':
                "Below are pieces of a flat mountain. DRAG the tall strip of 3 blocks onto the glowing center slot.",
          },
          {
            'text':
                "DRAG the two 2-block strips and SNAP them onto the glowing left and right slots.",
          },
          {
            'text':
                "DRAG the two single blocks and SNAP them into the remaining outer slots.",
          },
          {
            'text':
                "Look closely! You've built a square (rotated like a diamond). Adding numbers up and down (1+2+3+2+1) makes a perfect square (9)! ",
          },
        ],
      },
      {
        'title': "4. The Hexagonal Stack (Unsolved)",
        'objective':
            "To explore the 3D relationship that emerges when you add consecutive hexagonal numbers.",
        'steps': [
          {
            'text':
                "On the workspace is a single dot (Hex 1). DRAG the layer of 7 dots and STACK it on top of the single dot.",
          },
          {
            'text':
                "A new hexagonal layer of 19 dots appears. DRAG this layer and STACK it onto your current structure.",
          },
          {
            'text':
                "The shape is an irregular stack of dots! Watch how these 27 dots rearrange mathematically.",
          },
          {
            'text':
                "The pieces magically re-formed into a flat Cube pattern! Adding consecutive hexagonal numbers always creates a perfect Cube.",
          },
        ],
      },
      {
        'title': "5. The Power of Two Machine (Unsolved)",
        'objective':
            "To discover the relationship between the sum of powers of 2 and the next power of 2.",
        'steps': [
          {'text': "DRAG the 1-block into the 'SUMMER' drop zone on the left."},
          {'text': "DRAG the 2-block into the 'SUMMER' zone."},
          {'text': "DRAG the 4-block into the 'SUMMER' zone."},
          {
            'text':
                "The SUM bar is always exactly ONE block shorter than the NEXT Power of 2! (1+2+4 = 7, which is one less than 8).",
          },
        ],
      },
    ],
  },
  'hi': {
    'title': "पैटर्न निर्माता: संख्या अनुक्रमों के बीच संबंध खोजना",
    'subtitle': "कक्षा 6 • गणित में पैटर्न",
    'enterLab': "वर्चुअल लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'missionObj': "मिशन का उद्देश्य",
    'hudDefault': "शुरू करने के लिए एक परिदृश्य चुनें।",
    'nextScenario': "अगला परिदृश्य",
    'scenarioComplete': "परिदृश्य पूर्ण",
    'scenarios': [
      {
        'title': "1. विषम ग्नोमोन पहेली",
        'objective':
            "यह देखना और पुष्टि करना कि 1 से शुरू होने वाली लगातार विषम संख्याओं का योग हमेशा एक वर्ग संख्या होता है।",
        'steps': [
          {
            'text':
                "कार्यक्षेत्र पर एक बैंगनी बिंदु (1) है। 3-बिंदु वाले ग्नोमोन को नीचे से खींचें और 1-बिंदु ब्लॉक पर स्नैप करें।",
          },
          {
            'text':
                "5 नीले बिंदुओं का बड़ा L-आकार का ग्नोमोन दिखाई देता है। 5-बिंदु ग्नोमोन को खींचें और 2x2 वर्ग पर स्नैप करें।",
          },
          {
            'text':
                "7-बिंदु ग्नोमोन (पीला) दिखाई देता है। इसे खींचें और 3x3 वर्ग पर स्नैप करें।",
          },
          {
            'text':
                "आपने एक सुंदर पैटर्न खोज लिया है! लगातार विषम संख्याओं को जोड़ने से पूर्ण वर्ग बनते हैं। पहले 'N' विषम संख्याओं का योग हमेशा N-वर्ग होता है।",
          },
        ],
      },
      {
        'title': "2. त्रिकोणीय जुड़वाँ",
        'objective':
            "दृष्टिगत रूप से खोजना कि दो लगातार त्रिकोणीय संख्याओं को जोड़ने पर एक वर्ग संख्या प्राप्त होती है।",
        'steps': [
          {
            'text':
                "कार्यक्षेत्र पर एक 3-बिंदु त्रिकोण (नीला) और एक 6-बिंदु त्रिकोण (लाल) है। 3-बिंदु त्रिकोण को उल्टा घुमाने के लिए उस पर टैप करें।",
          },
          {
            'text':
                "उल्टे 3-बिंदु त्रिकोण को खींचें और उसे 6-बिंदु त्रिकोण पर स्नैप करें।",
          },
          {
            'text':
                "अब अगली जोड़ी आज़माएं! 6-बिंदु त्रिकोण को उल्टा घुमाने के लिए उस पर टैप करें।",
          },
          {
            'text':
                "उल्टे 6-बिंदु त्रिकोण को खींचें और उसे बड़े 10-बिंदु त्रिकोण पर स्नैप करें।",
          },
          {
            'text':
                "अद्भुत! दो लगातार त्रिकोणीय संख्याएँ हमेशा एक पूर्ण वर्ग बनाने के लिए संयोजित होती हैं।",
          },
        ],
      },
      {
        'title': "3. गिनती का पहाड़",
        'objective':
            "यह समझना कि एक चोटी तक गिनती की संख्याओं को जोड़ना और वापस नीचे आना (जैसे 1+2+3+2+1) एक वर्ग संख्या बनाता है।",
        'steps': [
          {
            'text':
                "नीचे एक सपाट पहाड़ के टुकड़े हैं। 3 ब्लॉकों की लंबी पट्टी को चमकते हुए केंद्र स्लॉट पर खींचें।",
          },
          {
            'text':
                "2 ब्लॉकों की दो पट्टियों को खींचें और उन्हें चमकते हुए बाएँ और दाएँ स्लॉट पर स्नैप करें।",
          },
          {
            'text':
                "दो एकल ब्लॉकों को खींचें और उन्हें शेष बाहरी स्लॉट में स्नैप करें।",
          },
          {
            'text':
                "ध्यान से देखें! आपने एक वर्ग बनाया है (हीरे की तरह घुमाया हुआ)। ऊपर और नीचे संख्याएँ जोड़ने (1+2+3+2+1) से एक पूर्ण वर्ग (9) बनता है!",
          },
        ],
      },
      {
        'title': "4. षट्भुज ढेर (अनसुलझा)",
        'objective':
            "लगातार षट्कोणीय संख्याओं को जोड़ने पर उभरने वाले 3D संबंध का पता लगाना।",
        'steps': [
          {
            'text':
                "कार्यक्षेत्र पर एक बिंदु (Hex 1) है। 7 बिंदुओं की परत को खींचें और उसे एकल बिंदु के ऊपर रखें।",
          },
          {
            'text':
                "19 बिंदुओं की एक नई परत दिखाई देती है। इस परत को खींचें और अपनी वर्तमान संरचना पर रखें।",
          },
          {
            'text':
                "आकार एक अनियमित ढेर है! ध्यान से देखें कि ये 27 बिंदु गणितीय रूप से कैसे पुनर्व्यवस्थित होते हैं।",
          },
          {
            'text':
                "बिंदु जादुई रूप से एक घन पैटर्न में बदल गए! लगातार षट्कोणीय संख्याओं को जोड़ने से हमेशा एक पूर्ण घन बनता है।",
          },
        ],
      },
      {
        'title': "5. दो की घात मशीन (अनसुलझा)",
        'objective': "2 की घातों के योग और 2 की अगली घात के बीच संबंध खोजना।",
        'steps': [
          {'text': "बाईं ओर 'SUMMER' ड्रॉप ज़ोन में 1-ब्लॉक खींचें।"},
          {'text': "2-ब्लॉक को 'SUMMER' ज़ोन में खींचें।"},
          {'text': "4-ब्लॉक को 'SUMMER' ज़ोन में खींचें।"},
          {
            'text':
                "SUM बार हमेशा 2 की अगली घात से ठीक एक ब्लॉक छोटा होता है! (1+2+4 = 7, जो 8 से एक कम है)।",
          },
        ],
      },
    ],
  },
};
