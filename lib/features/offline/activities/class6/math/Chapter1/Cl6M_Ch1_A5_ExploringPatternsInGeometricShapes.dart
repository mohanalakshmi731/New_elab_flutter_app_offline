// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Exploring Patterns in Geometric Shapes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigoAccent,
          secondary: Colors.amber,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: const Cl6M_Ch1_A5_ExploringPatternsInGeometricShapes(),
    ),
  );
}

class Cl6M_Ch1_A5_ExploringPatternsInGeometricShapes extends StatefulWidget {
  const Cl6M_Ch1_A5_ExploringPatternsInGeometricShapes({Key? key})
    : super(key: key);

  @override
  State<Cl6M_Ch1_A5_ExploringPatternsInGeometricShapes> createState() =>
      _Cl6M_Ch1_A5_ExploringPatternsInGeometricShapesState();
}

class _Cl6M_Ch1_A5_ExploringPatternsInGeometricShapesState
    extends State<Cl6M_Ch1_A5_ExploringPatternsInGeometricShapes>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';
  int _currentScenario = 0;
  int _currentStep = 0;

  // Canvas State
  Offset _cameraOffset = Offset.zero;
  double _cameraScale = 1.0;
  Offset _dragOffset = Offset.zero;

  double _baseScale = 1.0; // Added base scale tracking for smooth zooming

  List<Entity> _entities = [];
  List<LineEntity> _lines = [];
  Entity? _draggedEntity;
  Entity? _dotDragStart;
  Offset? _tempLineEnd;

  String? _globalSequence;
  int _kochCounter = 0;
  bool _isAdvancing = false;
  bool _showCompletionModal = false;

  // Animations
  late AnimationController _shutterController;
  late Animation<double> _shutterAnimation;
  bool _showShutter = true;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String _sndTick = 'audio/class6/math/click.mp3';
  final String _sndSnap = 'audio/class6/math/success.mp3';
  final String _sndError = 'audio/class6/math/mixkit_2954.mp3';
  final String _sndEnter = 'audio/class6/math/success.mp3';

  // Input states for scenarios
  final TextEditingController _predController = TextEditingController();
  bool _showPredDialog = false;
  bool _showRuleDialog = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shutterAnimation = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _shutterController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _shutterController.dispose();
    _audioPlayer.dispose();
    _predController.dispose();
    super.dispose();
  }

  void _playSound(String url) {
    _audioPlayer.play(AssetSource(url));
  }

  void _enterLab() {
    _playSound(_sndEnter);
    _shutterController.forward().then((_) {
      setState(() {
        _showShutter = false;
        _loadScenario(0);
      });
    });
  }

  void _toggleLanguage() {
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
    _playSound(_sndTick);
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      _cameraOffset = Offset.zero;
      _cameraScale = 1.0;
      _entities.clear();
      _lines.clear();
      _globalSequence = null;
      _kochCounter = 0;
      _isAdvancing = false;
      _showCompletionModal = false;
      _showPredDialog = false;
      _showRuleDialog = false;

      _setupScenarioEntities();
    });
  }

  void _setupScenarioEntities() {
    if (_currentScenario == 0) {
      _globalSequence = "3";
      _entities.add(
        PolygonEntity(
          sides: 3,
          radius: 100,
          color: Colors.indigoAccent,
          x: 0,
          y: 0,
        ),
      );
    } else if (_currentScenario == 1) {
      _globalSequence = "0";
      _entities.add(
        DotEntity(id: 0, radius: 15, color: Colors.blue, x: -50, y: 0),
      );
      _entities.add(
        DotEntity(id: 1, radius: 15, color: Colors.blue, x: 50, y: 0),
      );
    } else if (_currentScenario == 2) {
      _globalSequence = "0";
      double s = 40;
      _entities.add(GhostDotEntity(radius: s / 2, x: 0, y: 0));
      _entities.add(
        BlockEntity(
          size: s,
          color: Colors.blue,
          x: 0,
          y: 150,
          isDraggable: true,
          target: const Offset(0, 0),
        ),
      );
    } else if (_currentScenario == 3) {
      _globalSequence = "1";
      _entities.add(
        TriangleGridEntity(
          size: 1,
          x: 0,
          y: -50 - math.sqrt(3) * 40 / 2,
          color: Colors.amber,
        ),
      );
      _spawnS4Draggables(2);
    } else if (_currentScenario == 4) {
      _kochCounter = 3;
      _globalSequence = "3";
      double s = 150;
      Offset p1 = Offset(0, -s);
      Offset p2 = Offset(s * math.cos(math.pi / 6), s * math.sin(math.pi / 6));
      Offset p3 = Offset(-s * math.cos(math.pi / 6), s * math.sin(math.pi / 6));
      _entities.add(
        KochLineEntity(x1: p1.dx, y1: p1.dy, x2: p2.dx, y2: p2.dy, gen: 1),
      );
      _entities.add(
        KochLineEntity(x1: p2.dx, y1: p2.dy, x2: p3.dx, y2: p3.dy, gen: 1),
      );
      _entities.add(
        KochLineEntity(x1: p3.dx, y1: p3.dy, x2: p1.dx, y2: p1.dy, gen: 1),
      );
    }
  }

  void _spawnS4Draggables(int targetSize) {
    double dGap = 40;
    double h = math.sqrt(3) * dGap / 2;
    double targetY = -50 + (targetSize - 2) * h;

    _entities.add(GhostTriangleGridEntity(size: targetSize, x: 0, y: -50 - h));

    int wrong1 = targetSize == 2 ? 5 : targetSize - 1;
    int wrong2 = targetSize == 4 ? 7 : targetSize + 1;
    List<int> sizes = [targetSize, wrong1, wrong2];
    sizes.shuffle();

    for (int i = 0; i < sizes.length; i++) {
      _entities.add(
        TriangleGridEntity(
          size: sizes[i],
          x: -180.0 + i * 180.0,
          y: 160,
          color: Colors.blue,
          isDraggable: true,
          target: sizes[i] == targetSize ? Offset(0, targetY) : null,
        ),
      );
    }
  }

  void _advanceStep() {
    _playSound(_sndSnap);

    setState(() {
      int maxSteps =
          _i18n[_lang]!['scenarios'][_currentScenario]['steps'].length;
      bool isFinalStep = _currentStep == maxSteps - 2;

      if (_currentStep < maxSteps - 1) {
        _currentStep++;

        if (_currentScenario == 0) {
          PolygonEntity poly =
              _entities.firstWhere((e) => e is PolygonEntity) as PolygonEntity;
          poly.sides++;
          _globalSequence = "${poly.sides}";
          if (isFinalStep) _globalSequence = "3, 4, 5, 6, 7...";
        } else if (_currentScenario == 1) {
          if (_currentStep == 1) {
            _globalSequence = "1, 3";
            _entities.add(
              DotEntity(id: 2, radius: 15, color: Colors.blue, x: 0, y: -80),
            );
          } else if (_currentStep == 2) {
            _globalSequence = "1, 3, 6";
            _entities.add(
              DotEntity(id: 3, radius: 15, color: Colors.blue, x: 0, y: 80),
            );
          } else if (isFinalStep) {
            _globalSequence = "1, 3, 6...";
          }
        } else if (_currentScenario == 2) {
          double s = 40;
          if (_currentStep == 1) {
            _globalSequence = "1, 4";
            _entities.removeWhere(
              (e) => e is GhostDotEntity || e is BlockEntity,
            );
            _entities.addAll([
              GhostDotEntity(radius: s / 2, x: s, y: 0),
              GhostDotEntity(radius: s / 2, x: 0, y: s),
              GhostDotEntity(radius: s / 2, x: s, y: s),
            ]);
            for (int i = 0; i < 3; i++)
              _entities.add(
                BlockEntity(
                  size: s,
                  color: Colors.green,
                  x: -80.0 + i * 80,
                  y: 150,
                  isDraggable: true,
                ),
              );
          } else if (_currentStep == 2) {
            _globalSequence = "1, 4, 9";
            _entities.removeWhere(
              (e) => e is GhostDotEntity || e is BlockEntity,
            );
            _entities.addAll([
              GhostDotEntity(radius: s / 2, x: s * 2, y: 0),
              GhostDotEntity(radius: s / 2, x: s * 2, y: s),
              GhostDotEntity(radius: s / 2, x: s * 2, y: s * 2),
              GhostDotEntity(radius: s / 2, x: s, y: s * 2),
              GhostDotEntity(radius: s / 2, x: 0, y: s * 2),
            ]);
            for (int i = 0; i < 5; i++)
              _entities.add(
                BlockEntity(
                  size: s,
                  color: Colors.redAccent,
                  x: -120.0 + i * 60,
                  y: 150,
                  isDraggable: true,
                ),
              );
          } else if (isFinalStep) {
            _globalSequence = "1, 4, 9...";
          }
        } else if (_currentScenario == 3) {
          if (_currentStep == 1) {
            _globalSequence = "1, 4";
            _entities.removeWhere(
              (e) =>
                  e is GhostTriangleGridEntity ||
                  (e is TriangleGridEntity && !e.isDraggable),
            );
            _spawnS4Draggables(3);
          } else if (_currentStep == 2) {
            _globalSequence = "1, 4, 9";
            _entities.removeWhere(
              (e) =>
                  e is GhostTriangleGridEntity ||
                  (e is TriangleGridEntity && !e.isDraggable),
            );
            _spawnS4Draggables(4);
          } else if (_currentStep == 3) {
            _globalSequence = "1, 4, 9, 16";
            _entities.removeWhere(
              (e) =>
                  e is GhostTriangleGridEntity ||
                  (e is TriangleGridEntity && !e.isDraggable),
            );
          } else if (isFinalStep) {
            _globalSequence = "1, 4, 9, 16...";
          }
        } else if (_currentScenario == 4) {
          if (_currentStep == 1) {
            _globalSequence = "3, 12";
            _showPredDialog = true;
          } else if (_currentStep == 2) {
            _globalSequence = "12";
          } else if (_currentStep == 3) {
            _globalSequence = "3, 12, 48";
            _showRuleDialog = true;
          } else if (isFinalStep) {
            _globalSequence = "3, 12, 48...";
          }
        }

        if (isFinalStep) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) setState(() => _showCompletionModal = true);
          });
        }
      }
    });
  }

  void _evaluateScenarioState() {
    if (_isAdvancing) return;

    if (_currentScenario == 1) {
      int targetLines = _currentStep == 0
          ? 1
          : _currentStep == 1
          ? 3
          : 6;
      if (_lines.length >= targetLines && _currentStep == 2) {
        _isAdvancing = true;
        Future.delayed(const Duration(milliseconds: 200), () {
          _isAdvancing = false;
          _advanceStep();
        });
      }
    } else if (_currentScenario == 2) {
      var ghosts = _entities.whereType<GhostDotEntity>().toList();
      if (ghosts.isNotEmpty && ghosts.every((g) => g.filled)) {
        _isAdvancing = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          _isAdvancing = false;
          _advanceStep();
        });
      }
    } else if (_currentScenario == 4) {
      if (_currentStep == 0 && _kochCounter == 12) {
        _isAdvancing = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          _isAdvancing = false;
          _advanceStep();
        });
      } else if (_currentStep == 2 && _kochCounter == 48) {
        _isAdvancing = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          _isAdvancing = false;
          _advanceStep();
        });
      }
    }
  }

  // --- Touch & Gesture Handlers ---
  Offset _screenToWorld(Offset screenPos, Size size) {
    double dx =
        (screenPos.dx - size.width / 2 - _cameraOffset.dx) / _cameraScale;
    double dy =
        (screenPos.dy - size.height / 2 - _cameraOffset.dy) / _cameraScale;
    return Offset(dx, dy);
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseScale = _cameraScale; // Capture base scale on gesture start
    Offset worldPos = _screenToWorld(details.localFocalPoint, size);

    // Koch Snowflake clicking
    if (_currentScenario == 4 && (_currentStep == 0 || _currentStep == 2)) {
      int targetGen = _currentStep == 0 ? 1 : 2;
      for (int i = 0; i < _entities.length; i++) {
        var e = _entities[i];
        if (e is KochLineEntity && !e.isHidden && e.gen == targetGen) {
          double dist = _pointToLineDistance(
            worldPos,
            Offset(e.x1, e.y1),
            Offset(e.x2, e.y2),
          );
          if (dist < 40 / _cameraScale) {
            _playSound(_sndSnap);
            setState(() {
              e.isHidden = true;
              double dx = e.x2 - e.x1;
              double dy = e.y2 - e.y1;
              Offset p1 = Offset(e.x1 + dx / 3, e.y1 + dy / 3);
              Offset p2 = Offset(e.x1 + 2 * dx / 3, e.y1 + 2 * dy / 3);

              double nx = dy, ny = -dx;
              double len = math.sqrt(nx * nx + ny * ny);
              double h =
                  (math.sqrt(dx * dx + dy * dy) / 3) * (math.sqrt(3) / 2);
              Offset mid = Offset(
                (p1.dx + p2.dx) / 2 + (nx / len) * h,
                (p1.dy + p2.dy) / 2 + (ny / len) * h,
              );

              _entities.add(
                KochLineEntity(
                  x1: e.x1,
                  y1: e.y1,
                  x2: p1.dx,
                  y2: p1.dy,
                  gen: targetGen + 1,
                ),
              );
              _entities.add(
                KochLineEntity(
                  x1: p1.dx,
                  y1: p1.dy,
                  x2: mid.dx,
                  y2: mid.dy,
                  gen: targetGen + 1,
                ),
              );
              _entities.add(
                KochLineEntity(
                  x1: mid.dx,
                  y1: mid.dy,
                  x2: p2.dx,
                  y2: p2.dy,
                  gen: targetGen + 1,
                ),
              );
              _entities.add(
                KochLineEntity(
                  x1: p2.dx,
                  y1: p2.dy,
                  x2: e.x2,
                  y2: e.y2,
                  gen: targetGen + 1,
                ),
              );

              _kochCounter += 3;
              if (_currentStep == 0 && _kochCounter >= 12) _kochCounter = 12;
              if (_currentStep == 2 && _kochCounter >= 48) _kochCounter = 48;
              _globalSequence = _kochCounter.toString();
              _evaluateScenarioState();
            });
            return;
          }
        }
      }
    }

    // Connect Dots
    if (_currentScenario == 1) {
      for (var e in _entities) {
        if (e is DotEntity &&
            (Offset(e.x, e.y) - worldPos).distance < e.radius * 2) {
          _playSound(_sndTick);
          _dotDragStart = e;
          _tempLineEnd = worldPos;
          return;
        }
      }
    }

    // Draggable Entities
    for (int i = _entities.length - 1; i >= 0; i--) {
      var e = _entities[i];
      if (e.isDraggable) {
        bool hit = false;
        if (e is BlockEntity && (Offset(e.x, e.y) - worldPos).distance < e.size)
          hit = true;
        if (e is TriangleGridEntity &&
            (Offset(e.x, e.y) - worldPos).distance < e.size * 40)
          hit = true;

        if (hit) {
          _playSound(_sndTick);
          setState(() {
            _draggedEntity = e;
            _dragOffset = Offset(e.x, e.y) - worldPos;
            _entities.removeAt(i);
            _entities.add(e); // bring to front
          });
          return;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_draggedEntity != null) {
      Offset worldPos = _screenToWorld(details.localFocalPoint, size);
      setState(() {
        _draggedEntity!.x = worldPos.dx + _dragOffset.dx;
        _draggedEntity!.y = worldPos.dy + _dragOffset.dy;

        if (_currentScenario == 2 && _draggedEntity is BlockEntity) {
          double gridSize = 40;
          double gx = (_draggedEntity!.x / gridSize).round() * gridSize;
          double gy = (_draggedEntity!.y / gridSize).round() * gridSize;
          _draggedEntity!.snapX = gx;
          _draggedEntity!.snapY = gy;
        }
      });
    } else if (_dotDragStart != null) {
      setState(() {
        _tempLineEnd = _screenToWorld(details.localFocalPoint, size);
      });
    } else {
      // Pan / Zoom Camera
      setState(() {
        _cameraOffset += details.focalPointDelta;
        if (details.scale != 1.0) {
          _cameraScale = (_baseScale * details.scale).clamp(
            0.2,
            5.0,
          ); // Apply scale to base scale
        }
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_draggedEntity != null) {
      setState(() {
        bool snapped = false;
        if (_currentScenario == 2 && _draggedEntity is BlockEntity) {
          var ghosts = _entities
              .whereType<GhostDotEntity>()
              .where((g) => !g.filled)
              .toList();
          for (var g in ghosts) {
            if ((Offset(
                          _draggedEntity!.snapX ?? _draggedEntity!.x,
                          _draggedEntity!.snapY ?? _draggedEntity!.y,
                        ) -
                        Offset(g.x, g.y))
                    .distance <
                20) {
              _draggedEntity!.x = g.x;
              _draggedEntity!.y = g.y;
              _draggedEntity!.isDraggable = false;
              g.filled = true;
              snapped = true;
              _playSound(_sndSnap);
              _evaluateScenarioState();
              break;
            }
          }
        } else if (_draggedEntity!.target != null) {
          if ((Offset(_draggedEntity!.x, _draggedEntity!.y) -
                      _draggedEntity!.target!)
                  .distance <
              80) {
            _draggedEntity!.x = _draggedEntity!.target!.dx;
            _draggedEntity!.y = _draggedEntity!.target!.dy;
            _draggedEntity!.isDraggable = false;
            snapped = true;
            _playSound(_sndSnap);
            if (_currentScenario == 3) {
              _entities.removeWhere(
                (e) => e is TriangleGridEntity && e.isDraggable,
              );
              if (!_isAdvancing) {
                _isAdvancing = true;
                Future.delayed(const Duration(milliseconds: 500), () {
                  _isAdvancing = false;
                  _advanceStep();
                });
              }
            }
          }
        }

        if (!snapped) {
          _playSound(_sndError);
        }
        _draggedEntity = null;
      });
    } else if (_dotDragStart != null && _tempLineEnd != null) {
      DotEntity? targetDot;
      for (var e in _entities) {
        if (e is DotEntity &&
            e != _dotDragStart &&
            (Offset(e.x, e.y) - _tempLineEnd!).distance < e.radius * 3) {
          targetDot = e;
          break;
        }
      }

      if (targetDot != null) {
        bool exists = _lines.any(
          (l) =>
              (l.from == (_dotDragStart as DotEntity).id &&
                  l.to == targetDot!.id) ||
              (l.from == targetDot!.id &&
                  l.to == (_dotDragStart as DotEntity).id),
        );
        if (!exists) {
          setState(() {
            _lines.add(
              LineEntity(
                from: (_dotDragStart as DotEntity).id,
                to: targetDot!.id,
                x1: _dotDragStart!.x,
                y1: _dotDragStart!.y,
                x2: targetDot.x,
                y2: targetDot.y,
              ),
            );
          });
          _playSound(_sndSnap);
          _evaluateScenarioState();
        } else {
          _playSound(_sndError);
        }
      } else {
        _playSound(_sndError);
      }
      setState(() {
        _dotDragStart = null;
        _tempLineEnd = null;
      });
    }
  }

  double _pointToLineDistance(Offset p, Offset v, Offset w) {
    double l2 = (v.dx - w.dx) * (v.dx - w.dx) + (v.dy - w.dy) * (v.dy - w.dy);
    if (l2 == 0) return (p - v).distance;
    double t =
        ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    t = math.max(0, math.min(1, t));
    Offset proj = Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return (p - proj).distance;
  }

  // --- UI Builders ---
  Widget _buildSidebar() {
    Map<String, dynamic> tr = _i18n[_lang]!;
    List<dynamic> scenarios = tr['scenarios'];
    var currentScen = scenarios[_currentScenario];
    List<dynamic> steps = currentScen['steps'];

    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: const Border(right: BorderSide(color: Colors.white12)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 15,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tr['subtitle'],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _toggleLanguage,
                                  icon: const Icon(
                                    Icons.language,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _lang == 'en' ? 'हिन्दी' : 'English',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white12,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    minimumSize: const Size(0, 32),
                                    elevation: 0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Row(
                                    children: [
                                      const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      Text(
                                        tr['btnReset'] ?? 'Reset',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    _playSound(_sndTick);
                                    _loadScenario(_currentScenario);
                                  },
                                  tooltip: tr['btnReset'] ?? 'Reset',
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white12,
                                    padding: const EdgeInsets.all(6),
                                    minimumSize: const Size(0, 32),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),

                // Dropdown
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<int>(
                    value: _currentScenario,
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: InputDecoration(
                      labelText: tr['selectScenario'],
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: List.generate(scenarios.length, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text(
                          scenarios[index]['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) _loadScenario(val);
                    },
                  ),
                ),

                // Steps (Now part of the main scrollable column)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr['missionObj'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigoAccent,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentScen['objective'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...List.generate(steps.length - 1, (index) {
                        if (index > _currentStep)
                          return const SizedBox.shrink();
                        bool isCurrent = index == _currentStep;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent
                                  ? Colors.indigo.withOpacity(0.5)
                                  : Colors.white12,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isCurrent ? Icons.adjust : Icons.check_circle,
                                color: isCurrent
                                    ? Colors.indigoAccent
                                    : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  steps[index]['text'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isCurrent
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Custom Action Buttons for specific scenarios in sidebar
                if (_currentScenario == 1 && _currentStep < 3)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed:
                          _lines.length >=
                              (_currentStep == 0
                                  ? 1
                                  : _currentStep == 1
                                  ? 3
                                  : 6)
                          ? _advanceStep
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        tr['btnNextStage'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const Spacer(), // Ensures the footer stays at the very bottom
                // Footer
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: const BoxDecoration(
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
        ],
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    Map<String, dynamic> tr = _i18n[_lang]!;
    var currentScen = tr['scenarios'][_currentScenario];
    List<dynamic> steps = currentScen['steps'];

    Widget? actionBtn;
    if (_currentScenario == 1 && _currentStep < 3) {
      actionBtn = ElevatedButton(
        onPressed:
            _lines.length >=
                (_currentStep == 0
                    ? 1
                    : _currentStep == 1
                    ? 3
                    : 6)
            ? _advanceStep
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 36),
        ),
        child: Text(
          tr['btnNextStage'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      );
    }

    return Positioned(
      top: 64,
      left: 16,
      width: 280,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr['missionObj'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              steps[_currentStep < steps.length - 1
                  ? _currentStep
                  : steps.length - 2]['text'],
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            if (actionBtn != null) ...[const SizedBox(height: 12), actionBtn],
          ],
        ),
      ),
    );
  }

  Widget _buildModals() {
    Map<String, dynamic> tr = _i18n[_lang]!;

    return Stack(
      children: [
        // Prediction Dialog
        if (_showPredDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigoAccent),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Predict the Next Number!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr['predQuestion'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _predController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_predController.text == '48') {
                          setState(() {
                            _showPredDialog = false;
                            _predController.clear();
                          });
                          _playSound(_sndSnap);
                          _advanceStep();
                        } else {
                          _playSound(_sndError);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(tr['btnConfirm']),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Rule Selection (Koch)
        if (_showRuleDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Select Rule:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...['+ 4', 'x 4', 'x 2']
                        .map(
                          (rule) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (rule == 'x 4') {
                                  setState(() => _showRuleDialog = false);
                                  _playSound(_sndSnap);
                                  _advanceStep();
                                } else {
                                  _playSound(_sndError);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(
                                rule,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ),

        // Completion Modal
        if (_showCompletionModal)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Container(
                width: 400,
                height: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Pattern Discovered!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr['scenarios'][_currentScenario]['steps'].last['text'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_currentScenario < 4) {
                            _loadScenario(_currentScenario + 1);
                          } else {
                            _loadScenario(0);
                          }
                        },
                        icon: Icon(
                          _currentScenario < 4
                              ? Icons.arrow_forward
                              : Icons.refresh,
                          color: Colors.white,
                        ),
                        label: Text(
                          _currentScenario < 4
                              ? tr['nextScenario']
                              : "Restart Lab",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Constrain sidebar width between limits
    if (_sidebarWidth < 250) _sidebarWidth = 250;
    if (_sidebarWidth > screenWidth * 0.6) _sidebarWidth = screenWidth * 0.6;

    // Dynamic calculation of the visible canvas to prevent touch offsets
    double canvasWidth = _isSidebarOpen
        ? screenWidth - _sidebarWidth
        : screenWidth;
    Size canvasSize = Size(canvasWidth, MediaQuery.of(context).size.height);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // 1. Main Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Stack(
                children: [
                  // Grid Background & Painter
                  GestureDetector(
                    onScaleStart: (d) => _handleScaleStart(d, canvasSize),
                    onScaleUpdate: (d) => _handleScaleUpdate(d, canvasSize),
                    onScaleEnd: _handleScaleEnd,
                    child: CustomPaint(
                      painter: _CanvasPainter(
                        entities: _entities,
                        lines: _lines,
                        cameraOffset: _cameraOffset,
                        cameraScale: _cameraScale,
                        draggedEntity: _draggedEntity,
                        dotDragStart: _dotDragStart,
                        tempLineEnd: _tempLineEnd,
                        globalSequence: _globalSequence,
                      ),
                      size: Size.infinite,
                    ),
                  ),

                  // Scenario specific inline UI overlaid on canvas
                  if (_currentScenario == 0 && _currentStep < 3)
                    Align(
                      alignment: const Alignment(0, 0.6),
                      child: FloatingActionButton(
                        onPressed: _advanceStep,
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.add, size: 32),
                      ),
                    ),

                  if (_currentScenario == 3 && _currentStep == 3)
                    Align(
                      alignment: const Alignment(0, -0.6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOptionBtn(_i18n[_lang]!['optSquare'], true),
                          const SizedBox(width: 8),
                          _buildOptionBtn(_i18n[_lang]!['optTri'], false),
                          const SizedBox(width: 8),
                          _buildOptionBtn(_i18n[_lang]!['optCube'], false),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Floating Mission Card
            if (!_isSidebarOpen && !_showShutter) _buildFloatingMissionCard(),

            // 2. Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: _buildSidebar(),
            ),

            // 2.5 Resizer Handle
            if (_isSidebarOpen && !_showShutter)
              Positioned(
                left: _sidebarWidth - 5,
                top: 0,
                bottom: 0,
                width: 10,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      setState(() {
                        _sidebarWidth += details.delta.dx;
                        if (_sidebarWidth < 250) _sidebarWidth = 250;
                        if (_sidebarWidth > screenWidth * 0.6) {
                          _sidebarWidth = screenWidth * 0.6;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Menu Toggle Button
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.amberAccent,
                  iconSize: 28,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _playSound(_sndTick);
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.amber.withOpacity(0.8)),
                    ),
                  ),
                ),
              ),

            // 4. Modals (Predict, Rule, Completion)
            _buildModals(),

            // 5. Intro Shutter
            if (_showShutter)
              AnimatedBuilder(
                animation: _shutterAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      _shutterAnimation.value *
                          MediaQuery.of(context).size.height,
                    ),
                    child: Container(
                      color: const Color(0xFF020617),
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _i18n[_lang]!['title'],
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigoAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _i18n[_lang]!['subtitle'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton(
                            onPressed: _enterLab,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              _i18n[_lang]!['enterLab'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBtn(String text, bool isCorrect) {
    return ElevatedButton(
      onPressed: () {
        if (isCorrect) {
          _playSound(_sndSnap);
          _advanceStep();
        } else {
          _playSound(_sndError);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

// --- Canvas Painter ---
class _CanvasPainter extends CustomPainter {
  final List<Entity> entities;
  final List<LineEntity> lines;
  final Offset cameraOffset;
  final double cameraScale;
  final Entity? draggedEntity;
  final Entity? dotDragStart;
  final Offset? tempLineEnd;
  final String? globalSequence;

  _CanvasPainter({
    required this.entities,
    required this.lines,
    required this.cameraOffset,
    required this.cameraScale,
    this.draggedEntity,
    this.dotDragStart,
    this.tempLineEnd,
    this.globalSequence,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Deep Dark Theme Background Gradient
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Draw Static Global Grid for the dark theme feel
    Paint globalGridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double gridSpacing = 40.0;
    for (double i = 0; i <= size.width; i += gridSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), globalGridPaint);
    }
    for (double i = 0; i <= size.height; i += gridSpacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), globalGridPaint);
    }

    canvas.save();
    canvas.translate(
      size.width / 2 + cameraOffset.dx,
      size.height / 2 + cameraOffset.dy,
    );
    canvas.scale(cameraScale, cameraScale);

    // Draw localized thick grid background for block building snapping
    if (entities.any((e) => e is BlockEntity || e is GhostDotEntity)) {
      Paint localGridPaint = Paint()
        ..color = Colors.white10
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      double gs = 40;
      double gw = 10 * gs;
      for (double i = -gw / 2; i <= gw / 2; i += gs) {
        canvas.drawLine(Offset(i, -gw / 2), Offset(i, gw / 2), localGridPaint);
        canvas.drawLine(Offset(-gw / 2, i), Offset(gw / 2, i), localGridPaint);
      }
    }

    // Draw connecting lines
    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4 / cameraScale
      ..style = PaintingStyle.stroke;
    for (var l in lines) {
      canvas.drawLine(Offset(l.x1, l.y1), Offset(l.x2, l.y2), linePaint);
    }
    if (dotDragStart != null && tempLineEnd != null) {
      Paint tempPaint = Paint()
        ..color = Colors.indigoAccent
        ..strokeWidth = 4 / cameraScale
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(dotDragStart!.x, dotDragStart!.y),
        tempLineEnd!,
        tempPaint,
      );
    }

    // Sort entities to draw dragged one last (on top)
    List<Entity> sortedEntities = List.from(entities);
    sortedEntities.sort(
      (a, b) => a == draggedEntity
          ? 1
          : b == draggedEntity
          ? -1
          : 0,
    );

    for (var e in sortedEntities) {
      if (e.isHidden) continue;

      canvas.save();
      canvas.translate(e.x, e.y);

      if (e is PolygonEntity) {
        Paint pFill = Paint()
          ..color = e.color
          ..style = PaintingStyle.fill;
        Paint pStroke = Paint()
          ..color = Colors.indigo
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        Path path = Path();
        for (int i = 0; i < e.sides; i++) {
          double ang = (math.pi * 2 * i) / e.sides - math.pi / 2;
          double px = e.radius * math.cos(ang);
          double py = e.radius * math.sin(ang);
          if (i == 0)
            path.moveTo(px, py);
          else
            path.lineTo(px, py);
        }
        path.close();
        canvas.drawPath(path, pFill);
        canvas.drawPath(path, pStroke);

        Paint dotPaint = Paint()..color = Colors.white;
        for (int i = 0; i < e.sides; i++) {
          double ang = (math.pi * 2 * i) / e.sides - math.pi / 2;
          canvas.drawCircle(
            Offset(e.radius * math.cos(ang), e.radius * math.sin(ang)),
            6,
            dotPaint,
          );
        }
      } else if (e is DotEntity) {
        canvas.drawCircle(Offset.zero, e.radius, Paint()..color = e.color);
        canvas.drawCircle(
          Offset(-e.radius * 0.3, -e.radius * 0.3),
          e.radius * 0.3,
          Paint()..color = Colors.white30,
        );
      } else if (e is GhostDotEntity) {
        if (!e.filled) {
          canvas.drawCircle(
            Offset.zero,
            e.radius,
            Paint()
              ..color = Colors.white24
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        } else {
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: e.radius * 2,
              height: e.radius * 2,
            ),
            Paint()..color = Colors.green,
          );
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: e.radius * 2,
              height: e.radius * 2,
            ),
            Paint()
              ..color = Colors.black38
              ..style = PaintingStyle.stroke,
          );
        }
      } else if (e is BlockEntity) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: e.size, height: e.size),
          Paint()..color = e.color,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: e.size, height: e.size),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else if (e is GhostTriangleGridEntity) {
        double side = 40;
        double h = side * math.sqrt(3) / 2;
        for (int r = 0; r < e.size; r++) {
          _drawTriangleRow(canvas, 0, r * h, r + 1, side, Colors.white12, true);
        }
      } else if (e is TriangleGridEntity) {
        _drawTriangleRow(canvas, 0, 0, e.size, 40, e.color, false);
      } else if (e is KochLineEntity) {
        canvas.translate(
          -e.x,
          -e.y,
        ); // Reset translate for lines defined by 2 points
        canvas.drawLine(
          Offset(e.x1, e.y1),
          Offset(e.x2, e.y2),
          Paint()
            ..color = Colors.lightBlueAccent
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
      }

      canvas.restore();
    }

    if (globalSequence != null) {
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: globalSequence,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -220));
    }

    canvas.restore();
  }

  void _drawEqTriangle(
    Canvas canvas,
    double x,
    double y,
    double side,
    Color color,
    bool isUp,
    bool isGhost,
  ) {
    double h = side * math.sqrt(3) / 2;
    Path path = Path();
    if (isUp) {
      path.moveTo(x, y - h / 2);
      path.lineTo(x + side / 2, y + h / 2);
      path.lineTo(x - side / 2, y + h / 2);
    } else {
      path.moveTo(x, y + h / 2);
      path.lineTo(x + side / 2, y - h / 2);
      path.lineTo(x - side / 2, y - h / 2);
    }
    path.close();

    if (isGhost) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawTriangleRow(
    Canvas canvas,
    double x,
    double y,
    int rowSize,
    double side,
    Color color,
    bool isGhost,
  ) {
    canvas.save();
    canvas.translate(x, y);
    int numUp = rowSize;
    int numDown = rowSize - 1;
    double startX = -(rowSize - 1) * side / 2;

    for (int i = 0; i < numUp; i++) {
      _drawEqTriangle(canvas, startX + i * side, 0, side, color, true, isGhost);
    }
    for (int i = 0; i < numDown; i++) {
      _drawEqTriangle(
        canvas,
        startX + side / 2 + i * side,
        0,
        side,
        color,
        false,
        isGhost,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}

// --- Data Models ---
abstract class Entity {
  double x, y;
  bool isDraggable;
  bool isHidden;
  Offset? target;
  double? snapX;
  double? snapY;
  Entity({
    required this.x,
    required this.y,
    this.isDraggable = false,
    this.isHidden = false,
    this.target,
  });
}

class PolygonEntity extends Entity {
  int sides;
  double radius;
  Color color;
  PolygonEntity({
    required this.sides,
    required this.radius,
    required this.color,
    required double x,
    required double y,
  }) : super(x: x, y: y);
}

class DotEntity extends Entity {
  int id;
  double radius;
  Color color;
  DotEntity({
    required this.id,
    required this.radius,
    required this.color,
    required double x,
    required double y,
  }) : super(x: x, y: y);
}

class GhostDotEntity extends Entity {
  double radius;
  bool filled;
  GhostDotEntity({
    required this.radius,
    this.filled = false,
    required double x,
    required double y,
  }) : super(x: x, y: y);
}

class BlockEntity extends Entity {
  double size;
  Color color;
  BlockEntity({
    required this.size,
    required this.color,
    required double x,
    required double y,
    bool isDraggable = false,
    Offset? target,
  }) : super(x: x, y: y, isDraggable: isDraggable, target: target);
}

class TriangleGridEntity extends Entity {
  int size;
  Color color;
  TriangleGridEntity({
    required this.size,
    required this.color,
    required double x,
    required double y,
    bool isDraggable = false,
    Offset? target,
  }) : super(x: x, y: y, isDraggable: isDraggable, target: target);
}

class GhostTriangleGridEntity extends Entity {
  int size;
  GhostTriangleGridEntity({
    required this.size,
    required double x,
    required double y,
  }) : super(x: x, y: y);
}

class KochLineEntity extends Entity {
  double x1, y1, x2, y2;
  int gen;
  KochLineEntity({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.gen,
  }) : super(x: x1, y: y1);
}

class LineEntity {
  int from, to;
  double x1, y1, x2, y2;
  LineEntity({
    required this.from,
    required this.to,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });
}

// --- Localization Dictionary ---
final Map<String, Map<String, dynamic>> _i18n = {
  'en': {
    'title': "Exploring Patterns in Geometric Shapes",
    'subtitle': "Class 6 • PATTERNS IN MATHEMATICS",
    'enterLab': "Enter Virtual Lab",
    'selectScenario': "Select Scenario",
    'missionObj': "Mission Objective",
    'btnNextStage': "Next Stage",
    'btnConfirm': "Confirm Prediction",
    'btnReset': "Reset",
    'nextScenario': "Next Scenario",
    'optSquare': "Square Numbers",
    'optTri': "Triangular Numbers",
    'optCube': "Cube Numbers",
    'predQuestion':
        "The number of segments was multiplied by 4.\nWhat will 12 x 4 be?",
    'scenarios': [
      {
        'title': "1. The Polygon Parade",
        'objective':
            "To build a sequence of regular polygons and discover the simple counting pattern formed by their sides.",
        'steps': [
          {
            'text':
                "The scene shows a triangle on a platform. CLICK the '+' button.",
          },
          {
            'text':
                "The platform now shows the square, and the counter shows '4'. CLICK the '+' button again.",
          },
          {'text': "Continue to CLICK the '+' button two more times."},
          {
            'text':
                "Pattern Complete! 3, 4, 5, 6, 7... This is the sequence of COUNTING NUMBERS.",
          },
        ],
      },
      {
        'title': "2. Connect the Dots",
        'objective':
            "To construct a sequence of 'complete graphs' and discover the pattern of triangular numbers by counting lines.",
        'steps': [
          {
            'text':
                "The scene shows 2 dots. DRAG from one dot to the other to draw a line.",
          },
          {
            'text':
                "CLICK 'Next Stage'. The canvas now shows 3 dots. CONNECT every dot to every other dot.",
          },
          {
            'text':
                "CLICK 'Next Stage'. The canvas now shows 4 dots. CONNECT every dot to every other dot.",
          },
          {
            'text':
                "Look at the sequence: 1, 3, 6. This is the sequence of TRIANGULAR NUMBERS!",
          },
        ],
      },
      {
        'title': "3. Building with Blocks",
        'objective':
            "To build a sequence of larger squares from unit squares and visually confirm 'square numbers'.",
        'steps': [
          {
            'text':
                "DRAG and DROP one Square Block onto the glowing spot to make a 1x1 square.",
          },
          {
            'text':
                "Add more blocks to turn your 1x1 square into a 2x2 square. Follow the outline.",
          },
          {
            'text':
                "Expand the 2x2 square into a 3x3 square following the new outline.",
          },
          {
            'text':
                "The sequence is: 1, 4, 9. This is the sequence of SQUARE NUMBERS!",
          },
        ],
      },
      {
        'title': "4. Triangle Towers",
        'objective':
            "To build stacked triangles and determine the hidden number sequence based on total small triangles.",
        'steps': [
          {
            'text':
                "Mission: Build the next shape (size 2) in the sequence on the Pattern Stage.",
          },
          {
            'text':
                "Once you have built the second shape, place the next shape (size 3) on the stage.",
          },
          {
            'text':
                "Now build the fourth shape (size 4) in the sequence and place it on the stage.",
          },
          {
            'text':
                "The sequence you found is 1, 4, 9, 16. What is the pattern? CLICK the correct sequence name.",
          },
          {
            'text':
                "Correct! The numbers 1, 4, 9, 16 form the sequence of Square Numbers.",
          },
        ],
      },
      {
        'title': "5. The Snowflake Fractal",
        'objective':
            "To create a Koch Snowflake and predict the multiplicative pattern in its number of line segments.",
        'steps': [
          {
            'text':
                "CLICK the exact middle of each of the 3 line segments to split them.",
          },
          {
            'text':
                "The counter shows '12'. What will the new total be if you split all 12 new segments? Type answer.",
          },
          {'text': "Now, tap the middle of all 12 of the outer line segments."},
          {
            'text':
                "The sequence is: 3, 12, 48. What is the rule? Select it from the dialog.",
          },
          {
            'text':
                "Excellent! The rule is to Multiply by 4. Each iteration has 4 times as many segments.",
          },
        ],
      },
    ],
  },
  'hi': {
    'title': "ज्यामितीय आकृतियों में पैटर्न की खोज",
    'subtitle': "कक्षा 6 • गणित में पैटर्न",
    'enterLab': "वर्चुअल लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'missionObj': "मिशन का उद्देश्य",
    'btnNextStage': "अगला चरण",
    'btnConfirm': "पुष्टि करें",
    'btnReset': "रीसेट",
    'nextScenario': "अगला परिदृश्य",
    'optSquare': "वर्ग संख्याएँ",
    'optTri': "त्रिकोणीय संख्याएँ",
    'optCube': "घन संख्याएँ",
    'predQuestion':
        "खंडों की संख्या को 4 से गुणा किया गया था।\n12 x 4 क्या होगा?",
    'scenarios': [
      {
        'title': "1. बहुभुज परेड",
        'objective':
            "नियमित बहुभुजों का एक क्रम बनाना और उनके किनारों द्वारा निर्मित सरल गिनती पैटर्न की खोज करना।",
        'steps': [
          {'text': "मंच पर एक त्रिकोण है। '+' बटन पर क्लिक करें।"},
          {
            'text':
                "मंच अब वर्ग दिखाता है, और काउंटर '4' दिखाता है। फिर से '+' बटन पर क्लिक करें।",
          },
          {'text': "दो बार और '+' बटन पर क्लिक करना जारी रखें।"},
          {
            'text':
                "पैटर्न पूर्ण! 3, 4, 5, 6, 7... यह गिनती संख्याओं का क्रम है।",
          },
        ],
      },
      {
        'title': "2. डॉट्स कनेक्ट करें",
        'objective':
            "कनेक्टिंग लाइनों की गिनती करके 'पूर्ण ग्राफ़' का एक क्रम बनाना और त्रिकोणीय संख्याओं की खोज करना।",
        'steps': [
          {'text': "2 बिंदु हैं। एक रेखा खींचने के लिए एक से दूसरे तक खींचें।"},
          {
            'text':
                "अगला चरण पर क्लिक करें। अब 3 बिंदु हैं। प्रत्येक को एक दूसरे से जोड़ें।",
          },
          {
            'text':
                "अगला चरण पर क्लिक करें। अब 4 बिंदु हैं। प्रत्येक को एक दूसरे से जोड़ें।",
          },
          {'text': "क्रम देखें: 1, 3, 6। यह त्रिकोणीय संख्याओं का क्रम है!"},
        ],
      },
      {
        'title': "3. ब्लॉक के साथ निर्माण",
        'objective':
            "इकाई वर्गों से बड़े वर्गों का एक क्रम बनाना और 'वर्ग संख्याओं' की पुष्टि करना।",
        'steps': [
          {'text': "1x1 वर्ग बनाने के लिए एक ब्लॉक को चमकते स्थान पर खींचें।"},
          {
            'text':
                "अपने 1x1 वर्ग को 2x2 वर्ग में बदलने के लिए और ब्लॉक जोड़ें।",
          },
          {
            'text':
                "नई रूपरेखा का पालन करते हुए 2x2 वर्ग को 3x3 वर्ग में विस्तृत करें।",
          },
          {'text': "क्रम है: 1, 4, 9। यह वर्ग संख्याओं का क्रम है!"},
        ],
      },
      {
        'title': "4. त्रिकोण टावर",
        'objective':
            "स्टैक्ड त्रिकोणों का क्रम बनाना और छिपे हुए संख्या क्रम को निर्धारित करना।",
        'steps': [
          {'text': "पैटर्न स्टेज पर अगला आकार (आकार 2) बनाएं।"},
          {'text': "दूसरे आकार के बाद, अगले आकार (आकार 3) को मंच पर रखें।"},
          {
            'text':
                "अब अनुक्रम में चौथा आकार (आकार 4) बनाएं और इसे मंच पर रखें।",
          },
          {
            'text':
                "क्रम 1, 4, 9, 16 है। पैटर्न क्या है? सही अनुक्रम नाम पर क्लिक करें।",
          },
          {
            'text':
                "सही! संख्याएँ 1, 4, 9, 16 वर्ग संख्याओं का अनुक्रम बनाती हैं।",
          },
        ],
      },
      {
        'title': "5. स्नोफ्लेक फ्रैक्टल",
        'objective':
            "कोच स्नोफ्लेक बनाना और इसके रेखा खंडों की संख्या में गुणक पैटर्न की भविष्यवाणी करना।",
        'steps': [
          {'text': "3 रेखा खंडों में से प्रत्येक के ठीक मध्य पर क्लिक करें।"},
          {
            'text':
                "यदि आप सभी 12 नए खंडों को विभाजित करते हैं तो नया योग क्या होगा? उत्तर टाइप करें।",
          },
          {'text': "अब, सभी 12 बाहरी रेखा खंडों के मध्य पर क्लिक करें।"},
          {'text': "क्रम है: 3, 12, 48। नियम क्या है? इसे चुनें।"},
          {'text': "उत्कृष्ट! नियम 4 से गुणा करना है।"},
        ],
      },
    ],
  },
};
