// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: use_super_parameters, camel_case_types, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Identifying Basic Geometric Elements - ZSL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const Cl6M_Ch2_A1_IdentifyingBasicGeometricElements(),
    ),
  );
}

// Data Models
class GeoEntity {
  String id;
  String type;
  double x, y;
  double radius;
  Color color;
  bool glow;
  bool isInteractable;
  bool isDraggable;
  bool isHidden;
  bool isInfinite;
  double angle;
  String label;
  VoidCallback? onClick;

  GeoEntity({
    required this.id,
    required this.type,
    this.x = 0,
    this.y = 0,
    this.radius = 15,
    this.color = Colors.yellow,
    this.glow = false,
    this.isInteractable = false,
    this.isDraggable = false,
    this.isHidden = false,
    this.isInfinite = false,
    this.angle = 0,
    this.label = '',
    this.onClick,
  });
}

class GeoLine {
  GeoEntity n1;
  GeoEntity n2;
  String type;
  bool glow;

  GeoLine(this.n1, this.n2, this.type, {this.glow = false});
}

class Particle {
  double x, y, vx, vy, life;
  Color color;
  Particle(this.x, this.y, this.vx, this.vy, this.color) : life = 1.0;
}

// Main Widget
class Cl6M_Ch2_A1_IdentifyingBasicGeometricElements extends StatefulWidget {
  const Cl6M_Ch2_A1_IdentifyingBasicGeometricElements({Key? key})
    : super(key: key);

  @override
  State<Cl6M_Ch2_A1_IdentifyingBasicGeometricElements> createState() =>
      _Cl6M_Ch2_A1_IdentifyingBasicGeometricElementsState();
}

class _Cl6M_Ch2_A1_IdentifyingBasicGeometricElementsState
    extends State<Cl6M_Ch2_A1_IdentifyingBasicGeometricElements>
    with TickerProviderStateMixin {
  // App State
  bool _isSidebarOpen = true;
  String _currentLang = 'en';
  int _currentScenario = 0;
  int _currentStep = 0;
  bool _shutterOpen = true;
  bool _showCompletion = false;

  // Engine State
  List<GeoEntity> entities = [];
  List<GeoLine> lines = [];
  List<Particle> particles = [];
  String? activeTool;

  // Camera & Interaction
  double cameraX = 0;
  double cameraY = 0;
  double cameraScale = 1.0;
  double _baseScale = 1.0; // Stored to make pinch-zoom perfectly smooth
  bool isDrawing = false;
  Offset drawEndWorld = Offset.zero;
  GeoEntity? drawStartNode;
  GeoEntity? draggedEntity;
  Offset dragOffset = Offset.zero;
  double startAngle = 0.0;
  double draggedDist = 0.0;
  Offset dragStartPos = Offset.zero;

  late AnimationController _tickController;
  late AnimationController _cameraController;
  Animation<double>? _camXAnim;
  Animation<double>? _camYAnim;
  Animation<double>? _camScaleAnim;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final GlobalKey _canvasKey =
      GlobalKey(); // Added key to precisely map local touches

  // Translations
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'title': 'Identifying Basic Geometric Elements',
      'subtitle': 'Class 6 • LINES AND ANGLES',
      'enterLab': 'Enter Virtual Lab',
      'selectScenario': 'Select Scenario',
      'missionObj': 'Mission Objective',
      'nextScenario': 'Next Scenario',
      'scenarioComplete': 'Scenario Complete',
      'btnPowerOn': 'POWER ON',
      'btnStretcher': 'STRETCHER TOOL',
      'btnStardust': 'STARDUST CONNECTOR',
      'btnStartPlanning': 'START PLANNING',
      'btnRoad': 'Road',
      'btnHighway': 'Highway',
      'btnOneWay': 'One-Way',
      'hudDefault': 'Select a scenario to begin.',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'wrongTool': 'Wrong Tool!',
      'reset': 'Reset',
      'scenarios': [
        {
          'title': '1. The Firefly Connection',
          'objective':
              'To understand and differentiate a point and a line segment.',
          'steps': [
            'The screen is dark. A single, glowing firefly appears. TAP on the firefly.',
            'A second firefly appears. DRAG the "Thread of Light" tool from the first to the second.',
            'Try to DRAG either end of the line segment beyond the fireflies.',
            'A Point is a single location. A Line Segment is the shortest path between two points.',
          ],
          'hud': [
            'Tap on the glowing firefly.',
            'Connect the fireflies.',
            'Try pulling the ends.',
            'Pattern Discovered!',
          ],
        },
        {
          'title': '2. The Infinite Laser',
          'objective':
              'To understand the concept of a line by extending a line segment infinitely.',
          'steps': [
            'The two fireflies connected by the Line Segment are shown. TAP the "Stretcher Tool".',
            'The endpoints are glowing. DRAG point P to the left.',
            'Now, DRAG point Q to the right.',
            'When you extend a line segment forever in both directions, you get a Line.',
          ],
          'hud': [
            'Tap Stretcher Tool.',
            'Drag P left.',
            'Drag Q right.',
            'Concept Discovered: Line!',
          ],
        },
        {
          'title': '3. The Lighthouse Beam',
          'objective': 'To understand the concept of a ray.',
          'steps': [
            'A lighthouse is shown at Point O. TAP "POWER ON".',
            'A ship appears at Point S. DRAG the lighthouse top to aim the beam at the ship.',
            'A Ray starts at one point and goes on forever in one direction.',
          ],
          'hud': [
            'Tap POWER ON.',
            'Aim beam at ship.',
            'Concept Discovered: Ray!',
          ],
        },
        {
          'title': '4. Stargazer\'s Challenge',
          'objective':
              'To apply the concept of points and line segments to build a constellation.',
          'steps': [
            'Observe the stars and the "House" outline. TAP Stardust Connector to begin.',
            'DRAG between the correct stars to draw line segments and complete the constellation.',
            'Constellation complete! You connected points to form shapes.',
          ],
          'hud': [
            'Select Stardust tool.',
            'Connect stars to match outline.',
            'Challenge Complete!',
          ],
        },
        {
          'title': '5. City Planner\'s Blueprint',
          'objective': 'Apply knowledge of line segments, lines, and rays.',
          'steps': [
            'Observe City A, City B, and School S. TAP "START PLANNING".',
            'Task 1: Build a local "Road" (Line Segment) connecting City A to City B.',
            'Task 2: Build "Highway" (Line) passing through City A and City B infinitely.',
            'Task 3: Build a "One-Way" (Ray) starting at School S passing through City B.',
            'Blueprint Complete! You designed the infrastructure.',
          ],
          'hud': [
            'Tap START PLANNING.',
            'Select Road, connect A to B.',
            'Select Highway, connect A to B.',
            'Select One-Way, start S drag to B.',
            'City Planning Complete!',
          ],
        },
      ],
    },
    'hi': {
      'title': 'बुनियादी ज्यामितीय तत्वों की पहचान',
      'subtitle': 'कक्षा 6 • रेखाएँ और कोण',
      'enterLab': 'वर्चुअल लैब में प्रवेश करें',
      'selectScenario': 'परिदृश्य चुनें',
      'missionObj': 'मिशन का उद्देश्य',
      'nextScenario': 'अगला परिदृश्य',
      'scenarioComplete': 'परिदृश्य पूर्ण',
      'btnPowerOn': 'चालू करें',
      'btnStretcher': 'स्ट्रेचर टूल',
      'btnStardust': 'स्टारडस्ट कनेक्टर',
      'btnStartPlanning': 'योजना शुरू करें',
      'btnRoad': 'सड़क',
      'btnHighway': 'राजमार्ग',
      'btnOneWay': 'एकतरफा',
      'hudDefault': 'शुरू करने के लिए एक परिदृश्य चुनें।',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'wrongTool': 'गलत टूल!',
      'reset': 'रीसेट',
      'scenarios': [
        {
          'title': '1. जुगनू कनेक्शन',
          'objective': 'एक बिंदु और एक रेखाखंड को समझना।',
          'steps': [
            'एक चमकता हुआ जुगनू दिखाई देता है। जुगनू पर टैप करें।',
            'दूसरा जुगनू दिखाई देता है। प्रकाश का धागा टूल को पहले से दूसरे तक खींचें।',
            'रेखाखंड के किसी भी छोर को खींचने का प्रयास करें।',
            'एक बिंदु एक स्थान है। दो बिंदुओं के बीच का सबसे छोटा रास्ता रेखाखंड है।',
          ],
          'hud': [
            'चमकते हुए जुगनू पर टैप करें।',
            'जुगनुओं को जोड़ें।',
            'सिरों को खींचने का प्रयास करें।',
            'पैटर्न खोजा गया!',
          ],
        },
        {
          'title': '2. अनंत लेजर',
          'objective': 'रेखा की अवधारणा को समझना।',
          'steps': [
            'स्ट्रेचर टूल पर टैप करें।',
            'बिंदु P को बाईं ओर खींचें।',
            'बिंदु Q को दाईं ओर खींचें।',
            'रेखाखंड को উভয় दिशाओं में हमेशा के लिए बढ़ाने पर रेखा मिलती है।',
          ],
          'hud': [
            'स्ट्रेचर टूल पर टैप करें।',
            'P को बाईं ओर खींचें।',
            'Q को दाईं ओर खींचें।',
            'रेखा अनंत है!',
          ],
        },
        {
          'title': '3. लाइटहाउस बीम',
          'objective': 'किरण (Ray) की अवधारणा को समझना।',
          'steps': [
            'चालू करें बटन पर टैप करें।',
            'बीम को जहाज पर लक्षित करने के लिए लाइटहाउस को खींचें।',
            'किरण एक बिंदु से शुरू होती है और एक दिशा में हमेशा के लिए जाती है।',
          ],
          'hud': [
            'चालू करें टैप करें।',
            'जहाज पर बीम का लक्ष्य रखें।',
            'किरण का एक अंत बिंदु होता है!',
          ],
        },
        {
          'title': '4. स्टारगेज़र की चुनौती',
          'objective': 'नक्षत्र बनाने के लिए बिंदुओं और रेखाखंडों का उपयोग।',
          'steps': [
            'शुरू करने के लिए स्टारडस्ट कनेक्टर पर टैप करें।',
            'रूपरेखा से मेल खाने के लिए तारों को जोड़ें (खींचें)।',
            'नक्षत्र पूर्ण!',
          ],
          'hud': ['टूल चुनें।', 'तारों को जोड़ें।', 'चुनौती पूर्ण!'],
        },
        {
          'title': '5. सिटी प्लानर',
          'objective': 'शहर नियोजन की समस्या को हल करना।',
          'steps': [
            'योजना शुरू करें पर टैप करें।',
            'सड़क (रेखाखंड) बनाएं जो A को B से जोड़े।',
            'राजमार्ग (रेखा) बनाएं जो A और B से होकर जाए।',
            'एकतरफा (किरण) बनाएं जो S से शुरू होकर B से गुजरे।',
            'ब्लूप्रिंट पूर्ण!',
          ],
          'hud': [
            'योजना शुरू करें टैप करें।',
            'सड़क चुनें, A से B को जोड़ें।',
            'राजमार्ग चुनें, A से B को जोड़ें।',
            'एकतरफा चुनें, S से B तक खींचें।',
            'योजना पूर्ण!',
          ],
        },
      ],
    },
  };

  String tr(String key) {
    final value = i18n[_currentLang]?[key];
    return value is String ? value : key;
  }

  List<dynamic> trList(String key) => i18n[_currentLang]![key] as List<dynamic>;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _tickController.addListener(() {
      _updateParticles();
      setState(() {});
    });

    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cameraController.addListener(() {
      setState(() {
        if (_camXAnim != null) cameraX = _camXAnim!.value;
        if (_camYAnim != null) cameraY = _camYAnim!.value;
        if (_camScaleAnim != null) cameraScale = _camScaleAnim!.value;
      });
    });

    // Start with Shutter overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScenario(0);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _tickController.dispose();
    _cameraController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'tick':
        url = 'audio/class6/math/click.mp3';
        break;
      case 'snap':
      case 'success':
        url = 'audio/class6/math/success.mp3';
        break;
      case 'error':
        url = 'audio/class6/math/mixkit_2954.mp3';
        break;
      case 'pop':
        url = 'audio/class6/math/mixkit_2688.mp3';
        break;
      case 'enter':
        url = 'audio/class6/math/mixkit_270.mp3';
        break;
    }
    if (url.isNotEmpty) {
      try {
        await _audioPlayer.play(AssetSource(url));
      } catch (_) {}
    }
  }

  void _createParticles(double x, double y, Color color) {
    for (int i = 0; i < 15; i++) {
      particles.add(
        Particle(
          x,
          y,
          (math.Random().nextDouble() - 0.5) * 10,
          (math.Random().nextDouble() - 0.5) * 10 - 5,
          color,
        ),
      );
    }
  }

  void _updateParticles() {
    for (int i = particles.length - 1; i >= 0; i--) {
      var p = particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.5;
      p.life -= 0.03;
      if (p.life <= 0) {
        particles.removeAt(i);
      }
    }
  }

  void _animateCamera(double targetX, double targetY, double targetScale) {
    _camXAnim = Tween<double>(begin: cameraX, end: targetX).animate(
      CurvedAnimation(parent: _cameraController, curve: Curves.easeInOut),
    );
    _camYAnim = Tween<double>(begin: cameraY, end: targetY).animate(
      CurvedAnimation(parent: _cameraController, curve: Curves.easeInOut),
    );
    _camScaleAnim = Tween<double>(begin: cameraScale, end: targetScale).animate(
      CurvedAnimation(parent: _cameraController, curve: Curves.easeInOut),
    );
    _cameraController.forward(from: 0);
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      _showCompletion = false;
      activeTool = null;
      entities.clear();
      lines.clear();
    });

    if (index == 0) {
      entities.add(
        GeoEntity(
          id: 'F1',
          type: 'point',
          x: -100,
          y: 0,
          glow: true,
          isInteractable: true,
          onClick: () {
            _playSound('tick');
            _advanceStep();
          },
        ),
      );
    } else if (index == 1) {
      entities.add(GeoEntity(id: 'P', type: 'endpoint', x: -100, y: 0));
      entities.add(GeoEntity(id: 'Q', type: 'endpoint', x: 100, y: 0));
      lines.add(GeoLine(entities[0], entities[1], 'segment'));
    } else if (index == 2) {
      entities.add(
        GeoEntity(id: 'H', type: 'handle', x: -100, y: 50, angle: -math.pi / 2),
      );
      entities.add(GeoEntity(id: 'Ship', type: 'ship', x: 200, y: -50));
    } else if (index == 3) {
      List<Offset> pts = [
        const Offset(0, -100),
        const Offset(-100, 0),
        const Offset(100, 0),
        const Offset(-100, 100),
        const Offset(100, 100),
      ];
      List<String> ids = ['T', 'TL', 'TR', 'BL', 'BR'];
      for (int i = 0; i < pts.length; i++) {
        entities.add(
          GeoEntity(
            id: ids[i],
            type: 'node',
            x: pts[i].dx,
            y: pts[i].dy,
            glow: true,
            color: Colors.yellow,
            isInteractable: true,
          ),
        );
      }
    } else if (index == 4) {
      entities.add(
        GeoEntity(
          id: 'A',
          type: 'node',
          label: 'City A',
          x: -180,
          y: -50,
          color: Colors.blue,
          isInteractable: true,
        ),
      );
      entities.add(
        GeoEntity(
          id: 'B',
          type: 'node',
          label: 'City B',
          x: 180,
          y: 50,
          color: Colors.blue,
          isInteractable: true,
        ),
      );
      entities.add(
        GeoEntity(
          id: 'S',
          type: 'node',
          label: 'School S',
          x: -50,
          y: 180,
          color: Colors.green,
          isInteractable: true,
        ),
      );
    }

    _fitToScreen();
  }

  void _advanceStep() {
    var scen = trList('scenarios')[_currentScenario];
    if (_currentStep < (scen['steps'] as List).length - 1) {
      setState(() {
        _currentStep++;
        _playSound('success');

        if (_currentScenario == 0) {
          if (_currentStep == 1) {
            entities[0].label = 'Point P';
            entities[0].isInteractable = false;
            entities.add(
              GeoEntity(
                id: 'F2',
                type: 'point',
                x: 100,
                y: 0,
                glow: true,
                label: 'Point Q',
              ),
            );
            activeTool = 'thread';
          } else if (_currentStep == 2) {
            activeTool = null;
            entities[0].isHidden = true;
            entities[1].isHidden = true;
            entities.add(
              GeoEntity(
                id: 'P',
                type: 'endpoint',
                x: entities[0].x,
                y: entities[0].y,
                isDraggable: true,
              ),
            );
            entities.add(
              GeoEntity(
                id: 'Q',
                type: 'endpoint',
                x: entities[1].x,
                y: entities[1].y,
                isDraggable: true,
              ),
            );
            lines.add(
              GeoLine(
                entities.firstWhere((e) => e.id == 'P'),
                entities.firstWhere((e) => e.id == 'Q'),
                'segment',
              ),
            );
          }
        } else if (_currentScenario == 4) {
          // Note: Deliberately skipped scenario 3 here so activeTool ('stardust') isn't destroyed instantly
          activeTool = null;
        }
      });
    } else {
      _triggerCompletion();
    }
  }

  void _triggerCompletion() {
    _playSound('success');
    setState(() {
      var scen = trList('scenarios')[_currentScenario];
      // Move exactly to the conclusion step if we aren't there already
      if (_currentStep < (scen['steps'] as List).length - 1) {
        _currentStep++;
      }
      _showCompletion = true;
    });
  }

  void _evaluateState() {
    if (_showCompletion) return;

    var scen = trList('scenarios')[_currentScenario];
    bool isLast = _currentStep == (scen['steps'] as List).length - 1;
    if (isLast) return;

    if (_currentScenario == 0) {
      if (_currentStep == 1 && lines.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 800), _advanceStep);
      } else if (_currentStep == 2 && draggedEntity != null) {
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => _triggerCompletion(),
        );
      }
    } else if (_currentScenario == 1) {
      if (_currentStep == 1 &&
          entities.firstWhere((e) => e.id == 'P').isInfinite) {
        Future.delayed(const Duration(milliseconds: 800), _advanceStep);
      } else if (_currentStep == 2 &&
          entities.firstWhere((e) => e.id == 'Q').isInfinite) {
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => _triggerCompletion(),
        );
      }
    } else if (_currentScenario == 2) {
      if (_currentStep == 1) {
        var h = entities.firstWhere((e) => e.id == 'H');
        if (!h.isDraggable && h.angle != -math.pi / 2) {
          // locked
          Future.delayed(
            const Duration(milliseconds: 1000),
            () => _triggerCompletion(),
          );
        }
      }
    } else if (_currentScenario == 3) {
      if (_currentStep == 1 && lines.length == 6) {
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => _triggerCompletion(),
        );
      }
    } else if (_currentScenario == 4) {
      if (_currentStep == 1 && lines.any((l) => l.type == 'segment')) {
        Future.delayed(const Duration(milliseconds: 800), _advanceStep);
      } else if (_currentStep == 2 && lines.any((l) => l.type == 'line')) {
        Future.delayed(const Duration(milliseconds: 800), _advanceStep);
      } else if (_currentStep == 3 && lines.any((l) => l.type == 'ray')) {
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => _triggerCompletion(),
        );
      }
    }
  }

  Offset _screenToWorld(Offset localPos) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    // Map local focal point (from the canvas gesture detector) to world coordinates
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Size size = box.size;
    double cx = size.width / 2;
    double cy = size.height / 2;
    return Offset(
      (localPos.dx - cx - cameraX) / cameraScale,
      (localPos.dy - cy - cameraY) / cameraScale,
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _cameraController.stop(); // Stop any active zooming/panning animations
    _baseScale =
        cameraScale; // Store base scale for perfectly smooth pinch-zoom mapping

    Offset worldPos = _screenToWorld(details.localFocalPoint);

    // Check interaction for drawing tools
    if ((_currentScenario == 0 &&
            _currentStep == 1 &&
            activeTool == 'thread') ||
        (_currentScenario == 3 &&
            _currentStep == 1 &&
            activeTool == 'stardust') ||
        (_currentScenario == 4 && _currentStep > 0 && activeTool != null)) {
      try {
        var node = entities.firstWhere(
          (e) =>
              (e.type == 'point' || e.type == 'node') &&
              !e.isHidden &&
              (Offset(e.x, e.y) - worldPos).distance < 60,
        ); // Increased hit radius for easier mobile clicking
        _playSound('tick');
        setState(() {
          isDrawing = true;
          drawStartNode = node;
          drawEndWorld = worldPos;
        });
        return;
      } catch (_) {}
    }

    // Check entities clicking/dragging
    for (int i = entities.length - 1; i >= 0; i--) {
      var ent = entities[i];
      if (ent.isHidden) continue;

      bool hit = false;
      if (ent.type == 'point' && ent.isInteractable) {
        if ((Offset(ent.x, ent.y) - worldPos).distance < 60) hit = true;
      } else if (ent.type == 'endpoint' && ent.isDraggable) {
        if ((Offset(ent.x, ent.y) - worldPos).distance < 70) hit = true;
      } else if (ent.type == 'handle' && ent.isDraggable) {
        if (worldPos.dx >= ent.x - 60 &&
            worldPos.dx <= ent.x + 60 &&
            worldPos.dy >= ent.y - 60 &&
            worldPos.dy <= ent.y + 120) {
          hit = true;
        }
      }

      if (hit) {
        if (ent.onClick != null) {
          ent.onClick!();
          return;
        }
        if (ent.isDraggable) {
          _playSound('tick');
          setState(() {
            draggedEntity = ent;
            dragOffset = Offset(ent.x, ent.y) - worldPos;
            startAngle = math.atan2(worldPos.dy - ent.y, worldPos.dx - ent.x);
            dragStartPos = Offset(ent.x, ent.y);
            draggedDist = 0;
          });
          return;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (isDrawing) {
      setState(() {
        drawEndWorld = _screenToWorld(details.localFocalPoint);
      });
    } else if (draggedEntity != null) {
      Offset worldPos = _screenToWorld(details.localFocalPoint);
      var ent = draggedEntity!;

      draggedDist += (worldPos + dragOffset - Offset(ent.x, ent.y)).distance;

      setState(() {
        if (ent.type == 'endpoint') {
          ent.x = worldPos.dx + dragOffset.dx;
          if (ent.id == 'P' && ent.x > -100) ent.x = -100;
          if (ent.id == 'Q' && ent.x < 100) ent.x = 100;

          if (ent.id == 'P' && ent.x < -200 && !ent.isInfinite) {
            ent.isInfinite = true;
            _playSound('snap');
            _evaluateState();
          }
          if (ent.id == 'Q' && ent.x > 200 && !ent.isInfinite) {
            ent.isInfinite = true;
            _playSound('snap');
            _evaluateState();
          }
        } else if (ent.type == 'handle' && _currentScenario == 2) {
          double currentPointerAngle = math.atan2(
            worldPos.dy - ent.y,
            worldPos.dx - ent.x,
          );
          double angleDiff = currentPointerAngle - startAngle;

          while (angleDiff > math.pi) {
            angleDiff -= math.pi * 2;
          }
          while (angleDiff < -math.pi) {
            angleDiff += math.pi * 2;
          }

          ent.angle += angleDiff;
          startAngle = currentPointerAngle;

          var ship = entities.firstWhere((e) => e.id == 'Ship');
          double shipAngle = math.atan2(ship.y - ent.y, ship.x - ent.x);

          double diff =
              (ent.angle % (math.pi * 2)) - (shipAngle % (math.pi * 2));
          diff = diff.abs();
          if (diff > math.pi) diff = math.pi * 2 - diff;

          if (diff < 0.15) {
            ent.angle = shipAngle;
            ent.isDraggable = false; // lock
            _playSound('success');
            _createParticles(ship.x, ship.y, Colors.yellow);
            _evaluateState();
          }
        }
      });
    } else {
      // Smooth Panning & Pinch-Zooming
      setState(() {
        cameraX += details.focalPointDelta.dx;
        cameraY += details.focalPointDelta.dy;
        if (details.scale != 1.0) {
          cameraScale = (_baseScale * details.scale).clamp(0.2, 3.0);
        }
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (isDrawing) {
      try {
        var endNode = entities.firstWhere(
          (e) =>
              (e.type == 'point' || e.type == 'node') &&
              !e.isHidden &&
              (Offset(e.x, e.y) - drawEndWorld).distance < 60,
        );

        if (endNode != drawStartNode) {
          if (_currentScenario == 0 && _currentStep == 1) {
            if (endNode.id == 'F2' || drawStartNode!.id == 'F2') {
              lines.add(GeoLine(drawStartNode!, endNode, 'segment'));
              _playSound('snap');
              _createParticles(endNode.x, endNode.y, Colors.yellow);
              _evaluateState();
            } else {
              _playSound('error');
            }
          } else if (_currentScenario == 3) {
            bool exists = lines.any(
              (l) =>
                  (l.n1 == drawStartNode && l.n2 == endNode) ||
                  (l.n2 == drawStartNode && l.n1 == endNode),
            );
            if (!exists) {
              if (_checkConstellationLine(drawStartNode!, endNode)) {
                lines.add(
                  GeoLine(drawStartNode!, endNode, 'segment', glow: true),
                );
                _playSound('snap');
                _createParticles(
                  drawEndWorld.dx,
                  drawEndWorld.dy,
                  Colors.yellow,
                );
                _evaluateState();
              } else {
                _playSound('error');
              }
            }
          } else if (_currentScenario == 4 && activeTool != null) {
            bool correctTool = false;
            bool correctPath = false;

            if (_currentStep == 1) {
              correctTool = activeTool == 'road';
              correctPath =
                  ((drawStartNode!.id == 'A' && endNode.id == 'B') ||
                  (drawStartNode!.id == 'B' && endNode.id == 'A'));
            } else if (_currentStep == 2) {
              correctTool = activeTool == 'highway';
              correctPath =
                  ((drawStartNode!.id == 'A' && endNode.id == 'B') ||
                  (drawStartNode!.id == 'B' && endNode.id == 'A'));
            } else if (_currentStep == 3) {
              correctTool = activeTool == 'oneway';
              correctPath = (drawStartNode!.id == 'S' && endNode.id == 'B');
            }

            if (correctTool && correctPath) {
              String type = activeTool == 'road'
                  ? 'segment'
                  : activeTool == 'highway'
                  ? 'line'
                  : 'ray';
              lines.add(GeoLine(drawStartNode!, endNode, type));
              _playSound('snap');
              _evaluateState();
            } else {
              _playSound('error');
            }
          }
        } else {
          _playSound('error');
        }
      } catch (_) {
        if (drawStartNode != null) _playSound('error');
      }

      setState(() {
        isDrawing = false;
        drawStartNode = null;
      });
    } else if (draggedEntity != null) {
      var ent = draggedEntity!;
      if (ent.type == 'endpoint' && !ent.isInfinite) {
        setState(() {
          ent.x = dragStartPos.dx;
          ent.y = dragStartPos.dy;
        });
        if (draggedDist > 20) {
          _playSound('error');
          if (_currentScenario == 0 && _currentStep == 2) {
            _evaluateState();
          }
        }
      }
      setState(() {
        draggedEntity = null;
      });
    }
  }

  bool _checkConstellationLine(GeoEntity n1, GeoEntity n2) {
    List<List<String>> pairs = [
      ['T', 'TL'],
      ['T', 'TR'],
      ['TL', 'TR'],
      ['TL', 'BL'],
      ['TR', 'BR'],
      ['BL', 'BR'],
    ];
    return pairs.any(
      (p) =>
          (p[0] == n1.id && p[1] == n2.id) || (p[0] == n2.id && p[1] == n1.id),
    );
  }

  void _fitToScreen() {
    _animateCamera(0, 0, 1.0);
  }

  void _resetLab() {
    setState(() {
      _currentScenario = 0;
      _currentStep = 0;
      _showCompletion = false;
      _shutterOpen = true;
    });
  }

  Widget _buildToolBtn(
    String label,
    IconData icon,
    VoidCallback onTap, [
    bool isActive = false,
  ]) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.indigo.withOpacity(0.4) : Colors.white10,
            border: Border.all(
              color: isActive ? Colors.indigoAccent : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.white70,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicTools() {
    if (_currentScenario == 1 && _currentStep == 0) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.settings_ethernet),
        label: Text(tr('btnStretcher')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          _playSound('pop');
          setState(() {
            for (var e in entities) {
              if (e.type == 'endpoint') e.isDraggable = true;
            }
            _advanceStep();
          });
        },
      );
    }
    if (_currentScenario == 2 && _currentStep == 0) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.power_settings_new),
        label: Text(tr('btnPowerOn')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          _playSound('pop');
          setState(() {
            var h = entities.firstWhere((e) => e.type == 'handle');
            h.isDraggable = true;
            _advanceStep();
          });
        },
      );
    }
    if (_currentScenario == 3 && _currentStep == 0) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.auto_awesome),
        label: Text(tr('btnStardust')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        onPressed: () {
          _playSound('pop');
          setState(() {
            activeTool = 'stardust';
            _advanceStep();
          });
        },
      );
    }
    if (_currentScenario == 4) {
      if (_currentStep == 0) {
        return ElevatedButton.icon(
          icon: const Icon(Icons.map),
          label: Text(tr('btnStartPlanning')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            _playSound('pop');
            _advanceStep();
          },
        );
      }
      if (_currentStep > 0 && _currentStep < 4) {
        return Row(
          children: [
            _buildToolBtn(tr('btnRoad'), Icons.remove, () {
              _playSound('tick');
              setState(() => activeTool = 'road');
            }, activeTool == 'road'),
            _buildToolBtn(tr('btnHighway'), Icons.swap_horiz, () {
              _playSound('tick');
              setState(() => activeTool = 'highway');
            }, activeTool == 'highway'),
            _buildToolBtn(tr('btnOneWay'), Icons.arrow_right_alt, () {
              _playSound('tick');
              setState(() => activeTool = 'oneway');
            }, activeTool == 'oneway'),
          ],
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildMissionContent() {
    var scen = trList('scenarios')[_currentScenario];
    List<dynamic> steps = scen['steps'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('missionObj'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigoAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          scen['objective'],
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 16),
        ...List.generate(steps.length, (index) {
          if (index > _currentStep) return const SizedBox.shrink();

          bool isCurrent = index == _currentStep;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent
                    ? Colors.indigoAccent.withOpacity(0.5)
                    : Colors.white24,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCurrent ? Icons.adjust : Icons.check_circle,
                  color: isCurrent ? Colors.indigoAccent : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.3;
    if (sidebarWidth < 300) sidebarWidth = 300;

    var scen = trList('scenarios')[_currentScenario];
    List<dynamic> hudMsgs = scen['hud'];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Layer (Adjusts based on sidebar expand/collapse)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                key: _canvasKey,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                child: CustomPaint(
                  painter: LabPainter(
                    scenario: _currentScenario,
                    entities: entities,
                    lines: lines,
                    particles: particles,
                    cameraX: cameraX,
                    cameraY: cameraY,
                    cameraScale: cameraScale,
                    isDrawing: isDrawing,
                    drawStart: drawStartNode != null
                        ? Offset(drawStartNode!.x, drawStartNode!.y)
                        : Offset.zero,
                    drawEnd: drawEndWorld,
                    tick: _tickController.value * 10 * math.pi,
                  ),
                  child: Container(),
                ),
              ),
            ),

            // Bottom HUD (Dynamically adjustable & visible)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              bottom: 24,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    hudMsgs[_currentStep],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Floating Mission Card (When Sidebar Closed)
            if (!_isSidebarOpen)
              Positioned(
                top: 64,
                left: 12,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('missionObj'),
                        style: const TextStyle(
                          color: Colors.indigoAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scen['steps'][_currentStep],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDynamicTools(),
                    ],
                  ),
                ),
              ),

            // Animated Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                color: const Color(0xFF1E293B).withOpacity(0.95),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 66, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.category,
                                        color: Colors.yellow,
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tr('title'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            tr('subtitle'),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _playSound('tick');
                                        setState(() {
                                          _currentLang = _currentLang == 'en'
                                              ? 'hi'
                                              : 'en';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              color: Colors.white70,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _currentLang.toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: () {
                                        _playSound('tick');
                                        _resetLab();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.refresh,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            Text(
                                              tr('reset'),
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Colors.white24),

                          // Scenario Selector
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: DropdownButtonFormField<int>(
                              onTap: () {
                                _playSound('enter');
                              },
                              dropdownColor: const Color(0xFF1E293B),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                labelText: tr('selectScenario'),
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              value: _currentScenario,
                              items: List.generate(trList('scenarios').length, (
                                idx,
                              ) {
                                return DropdownMenuItem(
                                  value: idx,
                                  child: Text(
                                    trList('scenarios')[idx]['title'],
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) {
                                  _playSound('tick');
                                  _loadScenario(val);
                                }
                              },
                            ),
                          ),

                          // Mission Content (Scrollable due to parent SingleChildScrollView)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildMissionContent(),
                                const SizedBox(height: 20),
                                _buildDynamicTools(),
                              ],
                            ),
                          ),

                          const Spacer(),
                          // Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.white24),
                              ),
                            ),
                            child: Text(
                              tr('footer'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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

            // Menu Button (Top Left - Z-Index Front)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                  _fitToScreen(); // Re-fit smoothly when expanding or collapsing
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

            // Completion Modal
            if (_showCompletion)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        width: 400,
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 20),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Success!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              scen['steps'][_currentStep],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: Icon(
                                _currentScenario < 4
                                    ? Icons.arrow_forward
                                    : Icons.refresh,
                              ),
                              label: Text(
                                _currentScenario < 4
                                    ? tr('nextScenario')
                                    : 'Reset Lab',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                _playSound('tick');
                                if (_currentScenario < 4) {
                                  _loadScenario(_currentScenario + 1);
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
              ),

            // Intro Shutter Overlay
            if (_shutterOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category,
                          size: 64,
                          color: Colors.yellow,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          tr('title'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('subtitle'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            _playSound('enter');
                            setState(() {
                              _shutterOpen = false;
                            });
                            _loadScenario(0);
                          },
                          child: Text(
                            tr('enterLab'),
                            style: const TextStyle(
                              fontSize: 20,
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
        ),
      ),
    );
  }
}

class LabPainter extends CustomPainter {
  final int scenario;
  final List<GeoEntity> entities;
  final List<GeoLine> lines;
  final List<Particle> particles;
  final double cameraX;
  final double cameraY;
  final double cameraScale;
  final bool isDrawing;
  final Offset drawStart;
  final Offset drawEnd;
  final double tick;

  LabPainter({
    required this.scenario,
    required this.entities,
    required this.lines,
    required this.particles,
    required this.cameraX,
    required this.cameraY,
    required this.cameraScale,
    required this.isDrawing,
    required this.drawStart,
    required this.drawEnd,
    required this.tick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;

    // Draw Background Grid
    Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    if (scenario == 4) {
      canvas.drawColor(const Color(0xFF082F49), BlendMode.src);
      gridPaint.color = Colors.lightBlueAccent.withOpacity(0.2);
    } else {
      // Explicit Dark theme drawing for the background
      canvas.drawColor(const Color(0xFF0F172A), BlendMode.src);
    }

    double gridStep = 40 * cameraScale;
    if (scenario == 4) gridStep = 50 * cameraScale;

    double offsetX = (cx + cameraX) % gridStep;
    double offsetY = (cy + cameraY) % gridStep;

    for (double x = offsetX; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = offsetY; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.save();
    canvas.translate(cx + cameraX, cy + cameraY);
    canvas.scale(cameraScale);

    // Scenario Specific Backgrounds
    if (scenario == 2) {
      Paint seaPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawCircle(Offset.zero, 1000, seaPaint);
      Paint islandPaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(-100, 150),
          width: 180,
          height: 50,
        ),
        islandPaint,
      );
    } else if (scenario == 3) {
      // House Outline
      Paint dashPaint = Paint()
        ..color = Colors.white24
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      List<Offset> pts = [
        const Offset(0, -100),
        const Offset(-100, 0),
        const Offset(100, 0),
        const Offset(-100, 100),
        const Offset(100, 100),
      ];
      List<List<int>> pairs = [
        [0, 1],
        [0, 2],
        [1, 2],
        [1, 3],
        [2, 4],
        [3, 4],
      ];
      for (var p in pairs) {
        _drawDashedLine(canvas, pts[p[0]], pts[p[1]], dashPaint);
      }
    }

    // Lighthouse Beam (Scenario 2)
    var handleOpt = entities.where((e) => e.type == 'handle');
    if (handleOpt.isNotEmpty && handleOpt.first.isDraggable) {
      // Powered on
      var h = handleOpt.first;
      canvas.save();
      canvas.translate(h.x, h.y);
      canvas.rotate(h.angle);

      Path beam = Path()
        ..moveTo(0, -20)
        ..lineTo(1000, -150)
        ..lineTo(1000, 150)
        ..lineTo(0, 20)
        ..close();

      Paint beamPaint = Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(800, 0), [
          Colors.yellow.withOpacity(0.8),
          Colors.yellow.withOpacity(0.0),
        ]);
      canvas.drawPath(beam, beamPaint);

      Paint centerLine = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 4;
      canvas.drawLine(Offset.zero, const Offset(1000, 0), centerLine);
      _drawArrowHead(canvas, const Offset(400, 0), 0, Colors.yellow);
      canvas.restore();
    }

    // Draw Static Lines
    for (var l in lines) {
      canvas.save();
      double dx = l.n2.x - l.n1.x;
      double dy = l.n2.y - l.n1.y;
      double angle = math.atan2(dy, dx);
      double dist = math.sqrt(dx * dx + dy * dy);

      canvas.translate(l.n1.x, l.n1.y);
      canvas.rotate(angle);

      if (scenario == 4) {
        if (l.type == 'segment') {
          Paint road = Paint()
            ..color = Colors.yellow[700]!
            ..strokeWidth = 12
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(Offset.zero, Offset(dist, 0), road);
          Paint dash = Paint()
            ..color = Colors.white
            ..strokeWidth = 2;
          _drawDashedLine(
            canvas,
            Offset.zero,
            Offset(dist, 0),
            dash,
            dashLength: 10,
            dashSpace: 10,
          );
        } else if (l.type == 'line') {
          Paint hw = Paint()
            ..color = Colors.blueGrey
            ..strokeWidth = 16;
          canvas.drawLine(const Offset(-2000, 0), Offset(dist + 2000, 0), hw);
          Paint solid = Paint()
            ..color = Colors.white
            ..strokeWidth = 2;
          canvas.drawLine(
            const Offset(-2000, -2),
            Offset(dist + 2000, -2),
            solid,
          );
          canvas.drawLine(
            const Offset(-2000, 2),
            Offset(dist + 2000, 2),
            solid,
          );
          _drawArrowHead(
            canvas,
            const Offset(-150, 0),
            math.pi,
            Colors.blueGrey,
          );
          _drawArrowHead(canvas, Offset(dist + 150, 0), 0, Colors.blueGrey);
        } else if (l.type == 'ray') {
          Paint ray = Paint()
            ..color = Colors.red
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(Offset.zero, Offset(dist + 2000, 0), ray);
          _drawArrowHead(canvas, Offset(dist / 2 + 20, 0), 0, Colors.red);
        }
      } else {
        Paint linePaint = Paint()
          ..color = l.glow ? Colors.white : Colors.yellow[200]!
          ..strokeWidth = l.glow ? 4 : 6
          ..strokeCap = StrokeCap.round;

        if (l.type == 'segment') {
          canvas.drawLine(Offset.zero, Offset(dist, 0), linePaint);
        } else if (l.type == 'ray') {
          canvas.drawLine(Offset.zero, Offset(dist + 2000, 0), linePaint);
          _drawArrowHead(canvas, Offset(dist / 2 + 20, 0), 0, linePaint.color);
        } else if (l.type == 'line') {
          canvas.drawLine(
            const Offset(-2000, 0),
            Offset(dist + 2000, 0),
            linePaint,
          );
          _drawArrowHead(
            canvas,
            const Offset(-100, 0),
            math.pi,
            linePaint.color,
          );
          _drawArrowHead(canvas, Offset(dist + 100, 0), 0, linePaint.color);
        }
      }
      canvas.restore();
    }

    // Scenario 1 Infinite Dragging Extension Visuals
    if (scenario == 1 &&
        entities.where((e) => e.type == 'endpoint').length >= 2) {
      var p = entities.firstWhere((e) => e.id == 'P');
      var q = entities.firstWhere((e) => e.id == 'Q');

      canvas.save();
      Paint infLine = Paint()
        ..color = Colors.yellow[200]!
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      double px1 = p.isInfinite ? -2000 : p.x;
      double px2 = q.isInfinite ? 2000 : q.x;
      canvas.drawLine(Offset(px1, 0), Offset(px2, 0), infLine);

      if (p.isInfinite) {
        _drawArrowHead(canvas, Offset(p.x - 40, 0), math.pi, infLine.color);
      }
      if (q.isInfinite) {
        _drawArrowHead(canvas, Offset(q.x + 40, 0), 0, infLine.color);
      }
      canvas.restore();
    }

    // Draw Active Drawing Line
    if (isDrawing) {
      Paint drawLine = Paint()
        ..color = (scenario == 4)
            ? Colors.white54
            : Colors.yellow.withOpacity(0.5)
        ..strokeWidth = 4;
      _drawDashedLine(canvas, drawStart, drawEnd, drawLine);
    }

    // Draw Entities
    for (var ent in entities) {
      if (ent.isHidden) continue;
      canvas.save();
      canvas.translate(ent.x, ent.y);

      if (ent.type == 'point' || ent.type == 'node' || ent.type == 'endpoint') {
        if (!ent.isInfinite) {
          if (scenario == 4) {
            Paint base = Paint()..color = const Color(0xFF0F172A);
            canvas.drawCircle(Offset.zero, 24, base);
            Paint border = Paint()
              ..color = ent.color
              ..strokeWidth = 3
              ..style = PaintingStyle.stroke;
            canvas.drawCircle(Offset.zero, 24, border);

            // Icon
            Paint fill = Paint()
              ..color = ent.color
              ..style = PaintingStyle.fill;
            if (ent.id == 'S') {
              Path p = Path()
                ..moveTo(0, -12)
                ..lineTo(14, 2)
                ..lineTo(10, 2)
                ..lineTo(10, 12)
                ..lineTo(-10, 12)
                ..lineTo(-10, 2)
                ..lineTo(-14, 2)
                ..close();
              canvas.drawPath(p, fill);
            } else {
              canvas.drawRect(const Rect.fromLTWH(-10, -8, 8, 20), fill);
              canvas.drawRect(const Rect.fromLTWH(2, -14, 8, 26), fill);
            }

            _drawText(canvas, ent.label, const Offset(0, 30), Colors.white, 16);
          } else if (scenario == 3) {
            _drawStar(canvas, Offset.zero, 5, 12, 5, Colors.yellow[200]!);
          } else {
            if (ent.glow) {
              Paint shadow = Paint()
                ..color = ent.color.withOpacity(0.5)
                ..maskFilter = MaskFilter.blur(
                  BlurStyle.normal,
                  10 + 5 * math.sin(tick),
                );
              canvas.drawCircle(Offset.zero, ent.radius, shadow);
            }
            Paint pFill = Paint()..color = ent.color;
            canvas.drawCircle(Offset.zero, ent.radius, pFill);
            Paint pInner = Paint()..color = Colors.white54;
            canvas.drawCircle(const Offset(-3, -3), ent.radius * 0.3, pInner);

            if (ent.label.isNotEmpty && scenario != 4) {
              _drawText(
                canvas,
                ent.label,
                const Offset(0, 25),
                Colors.white,
                20,
              );
            } else if (ent.type == 'endpoint') {
              _drawText(
                canvas,
                "Point ${ent.id}",
                const Offset(0, 25),
                Colors.white,
                20,
              );
            }
          }
        }
      } else if (ent.type == 'handle') {
        Paint baseP = Paint()..color = Colors.blueGrey;
        Path base = Path()
          ..moveTo(-30, 100)
          ..lineTo(-15, 0)
          ..lineTo(15, 0)
          ..lineTo(30, 100)
          ..close();
        canvas.drawPath(base, baseP);

        Paint redStrip = Paint()..color = Colors.redAccent;
        Path strip = Path()
          ..moveTo(-25, 70)
          ..lineTo(-20, 30)
          ..lineTo(20, 30)
          ..lineTo(25, 70)
          ..close();
        canvas.drawPath(strip, redStrip);

        canvas.save();
        canvas.rotate(ent.angle);
        Paint head = Paint()..color = const Color(0xFF1E293B);
        canvas.drawRect(const Rect.fromLTWH(-20, -20, 40, 40), head);
        Paint bulb = Paint()..color = Colors.yellow;
        if (ent.isDraggable) {
          bulb.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        }
        canvas.drawCircle(Offset.zero, 12, bulb);
        canvas.restore();

        _drawText(canvas, "Point O", const Offset(0, 110), Colors.white, 20);
      } else if (ent.type == 'ship') {
        Paint body = Paint()..color = Colors.blueGrey[400]!;
        Path sPath = Path()
          ..moveTo(-40, -10)
          ..lineTo(40, -10)
          ..lineTo(25, 20)
          ..lineTo(-25, 20)
          ..close();
        canvas.drawPath(sPath, body);

        Paint sail = Paint()..color = Colors.blueGrey[200]!;
        Path sSail = Path()
          ..moveTo(0, -10)
          ..lineTo(0, -60)
          ..lineTo(30, -10)
          ..close();
        canvas.drawPath(sSail, sail);

        _drawText(canvas, "Point S", const Offset(0, 30), Colors.white, 20);
      }

      canvas.restore();
    }

    // Draw Particles
    for (var p in particles) {
      Paint partPaint = Paint()
        ..color = p.color.withOpacity(p.life.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), 4, partPaint);
    }

    canvas.restore();
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashLength = 5,
    double dashSpace = 5,
  }) {
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double dist = math.sqrt(dx * dx + dy * dy);
    double angle = math.atan2(dy, dx);

    canvas.save();
    canvas.translate(p1.dx, p1.dy);
    canvas.rotate(angle);

    double drawn = 0;
    while (drawn < dist) {
      canvas.drawLine(
        Offset(drawn, 0),
        Offset(math.min(drawn + dashLength, dist), 0),
        paint,
      );
      drawn += dashLength + dashSpace;
    }
    canvas.restore();
  }

  void _drawArrowHead(Canvas canvas, Offset pos, double angle, Color color) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(-25, -15)
      ..lineTo(-20, 0)
      ..lineTo(-25, 15)
      ..close();
    canvas.drawPath(path, p);
    canvas.restore();
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    int spikes,
    double outerRadius,
    double innerRadius,
    Color color,
  ) {
    Path path = Path();
    double rot = math.pi / 2 * 3;
    double x = center.dx;
    double y = center.dy - outerRadius;
    double step = math.pi / spikes;

    path.moveTo(x, y);
    for (int i = 0; i < spikes; i++) {
      x = center.dx + math.cos(rot) * outerRadius;
      y = center.dy + math.sin(rot) * outerRadius;
      path.lineTo(x, y);
      rot += step;

      x = center.dx + math.cos(rot) * innerRadius;
      y = center.dy + math.sin(rot) * innerRadius;
      path.lineTo(x, y);
      rot += step;
    }
    path.lineTo(center.dx, center.dy - outerRadius);
    path.close();

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    Color color,
    double fontSize,
  ) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
