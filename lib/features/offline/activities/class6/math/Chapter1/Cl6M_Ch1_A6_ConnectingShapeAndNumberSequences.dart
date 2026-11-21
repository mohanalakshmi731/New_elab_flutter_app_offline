// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'The Shape of Numbers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch1_A6_ConnectingShapeAndNumberSequences(),
    ),
  );
}

// --- स्थानीयकरण (Localization) ---
class I18n {
  static const Map<String, Map<String, dynamic>> data = {
    'en': {
      'title': 'The Shape of Numbers',
      'subtitle': 'Class 6 • PATTERNS IN MATHEMATICS',
      'enterLab': 'Enter Virtual Lab',
      'missionObj': 'Mission Objective',
      'settings': 'Settings',
      'language': 'EN',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'hudDefault': 'Select a scenario to begin.',
      'btnHint': 'USE HINT',
      'btnCheck': 'CHECK MY WORK',
      'btnSubmit': 'SUBMIT',
      'scenarioComplete': 'Scenario Complete',
      'nextScenario': 'Next Scenario',
      'convertUnits': 'Convert Units',
      'validateModel': 'Validate Model',
      'scenarios': [
        {
          'title': '1. Building with Triangles',
          'objective': 'Visually construct the sequence of triangular numbers.',
          'steps': [
            {'text': 'Drag a dot from the palette to start.'},
            {'text': 'Build the 2nd row (2 dots).'},
            {'text': 'Build the 3rd row (3 dots).'},
            {'text': 'Build the 4th row (4 dots).'},
            {
              'text':
                  'Pattern Discovered: Triangular Numbers! (1, 3, 6, 10...)',
            },
          ],
        },
        {
          'title': '2. Triangle Fusion',
          'objective': 'Add consecutive triangular numbers to create squares.',
          'steps': [
            {'text': 'Tap to rotate the 3-dot triangle.'},
            {'text': 'Observe how the two triangular shapes merge.'},
            {'text': 'Now tap to rotate the 6-dot triangle.'},
            {'text': 'Pattern Discovered: Two Triangles make a Square!'},
          ],
        },
        {
          'title': '3. Peeling the Square',
          'objective': 'Understand why odd numbers sum to a square.',
          'steps': [
            {'text': 'Tap the outermost layer (9 dots) and drag it away.'},
            {'text': 'Peel off the layer of 7 dots.'},
            {'text': 'Peel off the layer of 5 dots.'},
            {'text': 'Peel off the remaining layers (3, 1).'},
            {'text': 'Pattern Discovered: Odd Sums = Square Numbers!'},
          ],
        },
        {
          'title': '4. The Graph Connecter',
          'objective': 'Connect vertices to find the Complete Graph sequence.',
          'steps': [
            {'text': 'Draw a line connecting the 2 vertices.'},
            {'text': 'Draw lines between all 3 vertices.'},
            {'text': 'Draw lines connecting all 4 vertices.'},
            {'text': 'Predict! How many lines for 5 vertices? Enter below.'},
            {'text': 'Pattern Discovered: Connections = Triangular numbers!'},
          ],
        },
        {
          'title': '5. The Hexagon Builder',
          'objective': 'Construct the next hexagonal shape.',
          'steps': [
            {
              'text':
                  'Drag dots to build the 4th Hexagon around the 19-dot shape.',
            },
            {'text': 'Fill the remaining glowing spots.'},
            {'text': 'Click "CHECK MY WORK" to verify.'},
            {
              'text':
                  'Pattern Discovered: Hexagonal Numbers! (1, 7, 19, 37...)',
            },
          ],
        },
      ],
    },
    'hi': {
      'title': 'संख्याओं का आकार',
      'subtitle': 'कक्षा 6 • गणित में पैटर्न',
      'enterLab': 'वर्चुअल लैब में प्रवेश करें',
      'missionObj': 'मिशन का उद्देश्य',
      'settings': 'सेटिंग्स',
      'language': 'HI',
      'footer': '© ZeroScienceLab - विज्ञान और गणित से प्यार करें',
      'hudDefault': 'शुरू करने के लिए एक परिदृश्य चुनें।',
      'btnHint': 'संकेत उपयोग करें',
      'btnCheck': 'मेरा काम जांचें',
      'btnSubmit': 'जमा करें',
      'scenarioComplete': 'परिदृश्य पूर्ण',
      'nextScenario': 'अगला परिदृश्य',
      'convertUnits': 'इकाइयों को बदलें',
      'validateModel': 'मॉडल को मान्य करें',
      'scenarios': [
        {
          'title': '1. त्रिकोणों के साथ निर्माण',
          'objective': 'त्रिकोणीय संख्याओं का क्रम बनाना।',
          'steps': [
            {'text': 'शुरू करने के लिए पैलेट से एक बिंदु खींचें।'},
            {'text': 'दूसरी पंक्ति (2 बिंदु) बनाएँ।'},
            {'text': 'तीसरी पंक्ति (3 बिंदु) बनाएँ।'},
            {'text': 'चौथी पंक्ति (4 बिंदु) बनाएँ।'},
            {'text': 'पैटर्न खोजा गया: त्रिकोणीय संख्याएँ! (1, 3, 6, 10...)'},
          ],
        },
        {
          'title': '2. त्रिकोण संलयन',
          'objective': 'दो त्रिकोणीय संख्याओं को जोड़कर वर्ग बनाना।',
          'steps': [
            {'text': '3-बिंदु त्रिकोण को घुमाने के लिए टैप करें।'},
            {
              'text':
                  'ध्यान दें कि दोनों त्रिकोण मिलकर कैसे एक वर्ग बनाते हैं।',
            },
            {'text': 'अब 6-बिंदु त्रिकोण को घुमाने के लिए टैप करें।'},
            {'text': 'पैटर्न खोजा गया: दो त्रिकोण एक वर्ग बनाते हैं!'},
          ],
        },
        {
          'title': '3. वर्ग को छीलना',
          'objective': 'समझें कि विषम संख्याओं का योग वर्ग क्यों होता है।',
          'steps': [
            {'text': 'सबसे बाहरी परत (9 बिंदु) पर टैप करें और दूर खींचें।'},
            {'text': '7 बिंदुओं की परत को छील लें।'},
            {'text': '5 बिंदुओं की परत को छील लें।'},
            {'text': 'शेष परतों (3, 1) को छील लें।'},
            {'text': 'पैटर्न खोजा गया: विषम योग = वर्ग संख्याएँ!'},
          ],
        },
        {
          'title': '4. ग्राफ कनेक्टर',
          'objective': 'पूर्ण ग्राफ अनुक्रम खोजने के लिए कोने कनेक्ट करें।',
          'steps': [
            {'text': '2 कोने जोड़ने वाली रेखा खींचें।'},
            {'text': 'सभी 3 कोणों के बीच रेखाएँ खींचें।'},
            {'text': 'सभी 4 कोणों को जोड़ने वाली रेखाएँ खींचें।'},
            {
              'text':
                  'भविष्यवाणी करें! 5 कोने के लिए कितनी रेखाएँ? नीचे दर्ज करें।',
            },
            {'text': 'पैटर्न खोजा गया: कनेक्शन = त्रिकोणीय संख्याएँ!'},
          ],
        },
        {
          'title': '5. हेक्सागन बिल्डर',
          'objective': 'अगला हेक्सागोनल आकार बनाएँ।',
          'steps': [
            {
              'text':
                  '19-बिंदु आकार के चारों ओर 4था हेक्सागन बनाने के लिए खींचें।',
            },
            {'text': 'शेष चमकते स्थानों को भरें।'},
            {'text': 'सत्यापित करने के लिए "मेरा काम जांचें" पर क्लिक करें।'},
            {'text': 'पैटर्न खोजा गया: हेक्सागोनल संख्याएँ! (1, 7, 19, 37...)'},
          ],
        },
      ],
    },
  };
}

// --- डेटा मॉडल (Data Models) ---
abstract class Entity {
  double x;
  double y;
  bool isHidden = false;
  bool isDraggable = false;
  int z = 0;

  Entity({
    required this.x,
    required this.y,
    this.z = 0,
    this.isDraggable = false,
  });
}

class Dot extends Entity {
  double radius;
  Color color;
  TargetDot? target;
  bool isNearTarget = false;

  Dot({
    required super.x,
    required super.y,
    required this.radius,
    required this.color,
    super.z,
    super.isDraggable,
  });
}

class PaletteDot extends Entity {
  double radius;
  Color color;
  PaletteDot({
    required super.x,
    required super.y,
    required this.radius,
    required this.color,
    super.z,
  }) : super(isDraggable: true);
}

class TargetDot extends Entity {
  double radius;
  bool isFilled = false;
  TargetDot({
    required super.x,
    required super.y,
    required this.radius,
    super.z,
  });
}

class SubDot {
  double dx, dy, r;
  Color color;
  bool isSquare;
  SubDot({
    required this.dx,
    required this.dy,
    required this.r,
    required this.color,
    this.isSquare = false,
  });
}

class ShapeGroup extends Entity {
  List<SubDot> dots;
  double angle;
  bool canRotate;
  Offset? targetOffset;
  double? targetAngle;
  bool isNearTarget = false;

  ShapeGroup({
    required super.x,
    required super.y,
    required this.dots,
    this.angle = 0,
    this.canRotate = false,
    super.z,
    super.isDraggable,
    this.targetOffset,
    this.targetAngle,
  });
}

class GnomonLayer extends Entity {
  List<SubDot> dots;
  int id;
  bool isHighlightable;
  bool isHighlighted = false;
  bool isPeeled = false;
  bool isNearTarget = false;
  Offset targetOffset;
  String countLabel;
  double startX, startY;

  GnomonLayer({
    required super.x,
    required super.y,
    required this.dots,
    required this.id,
    required this.isHighlightable,
    required this.targetOffset,
    required this.countLabel,
    super.z,
  }) : startX = x,
       startY = y;
}

class GraphNode extends Entity {
  double radius;
  Color color;
  GraphNode({
    required super.x,
    required super.y,
    required this.radius,
    required this.color,
    super.z,
  });
}

class GraphLine {
  GraphNode n1;
  GraphNode n2;
  GraphLine(this.n1, this.n2);
}

class TextEntity extends Entity {
  String text;
  bool large;
  TextEntity({
    required super.x,
    required super.y,
    required this.text,
    this.large = false,
    super.z,
  });
}

// --- मुख्य विजेट (Main Widget) ---
class Cl6M_Ch1_A6_ConnectingShapeAndNumberSequences extends StatefulWidget {
  const Cl6M_Ch1_A6_ConnectingShapeAndNumberSequences({super.key});

  @override
  State<Cl6M_Ch1_A6_ConnectingShapeAndNumberSequences> createState() =>
      _Cl6M_Ch1_A6_ConnectingShapeAndNumberSequencesState();
}

class _Cl6M_Ch1_A6_ConnectingShapeAndNumberSequencesState
    extends State<Cl6M_Ch1_A6_ConnectingShapeAndNumberSequences>
    with TickerProviderStateMixin {
  // ऑडियो (Audio)
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  // ध्वनियाँ (Sounds)
  final String sfxClick = 'audio/class6/math/click.mp3';
  final String sfxSnap = 'audio/class6/math/click.mp3';
  final String sfxSuccess = 'audio/class6/math/success.mp3';
  final String sfxError = 'audio/class6/math/error.mp3';
  final String sfxIntro = 'audio/class6/math/mixkit_1434.mp3';

  // स्थिति (State)
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _isShutterOpen = false;
  int _currentScenario = 0;
  int _currentStep = 0;

  // इंजन की स्थिति (Engine State)
  List<Entity> _entities = [];
  List<GraphLine> _graphLines = [];
  String _globalSequence = '';

  double _cameraX = 0;
  double _cameraY = 0;
  double _cameraScale = 1.0;
  double _baseScale = 1.0;

  Entity? _draggedEntity;
  Offset _dragOffset = Offset.zero;
  Offset _dragStartPos = Offset.zero;
  double _draggedDist = 0;

  // रेखा खींचने की स्थिति (Draw Line State)
  bool _isDrawingLine = false;
  GraphNode? _lineStartNode;
  Offset _lineEndPos = Offset.zero;

  // एनिमेशन (Animations)
  late AnimationController _shutterCtrl;
  late Animation<double> _shutterAnim;

  final TextEditingController _predController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _shutterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shutterAnim = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _shutterCtrl, curve: Curves.easeInOutCubic),
    );

    _bgmPlayer.setReleaseMode(ReleaseMode.loop);

    _loadScenario(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _audioPlayer.dispose();
    _bgmPlayer.dispose();
    _shutterCtrl.dispose();
    _predController.dispose();
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer
          .play(AssetSource(url))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }

  void _enterLab() {
    _playSound(sfxIntro);
    _shutterCtrl.forward().then((_) {
      setState(() {
        _isShutterOpen = true;
      });
    });
  }

  void _resetLab() {
    _playSound(sfxClick);
    setState(() {
      _isShutterOpen = false;
    });
    _shutterCtrl.reverse().then((_) {
      _loadScenario(0);
    });
  }

  void _toggleLanguage() {
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      _entities.clear();
      _graphLines.clear();
      _globalSequence = '';
      _cameraX = 0;
      _cameraY = 0;
      _cameraScale = 1.0;
      _baseScale = 1.0;

      double dGap = 40;
      double dR = 15;

      if (index == 0) {
        _globalSequence = "Count: 1";
        _entities.add(
          Dot(
            x: 0,
            y: 0,
            radius: dR,
            color: Colors.amber,
            z: 2,
            isDraggable: false,
          ),
        );
        _entities.add(
          PaletteDot(
            x: 0,
            y: 150,
            radius: 20,
            color: Colors.indigoAccent,
            z: 10,
          ),
        );
      } else if (index == 1) {
        _globalSequence = "3 + 6 = ?";
        double dY = math.sqrt(3) * dGap / 2;
        List<SubDot> t3 = [
          SubDot(dx: 0, dy: 0, r: dR, color: Colors.blue),
          SubDot(dx: -dGap / 2, dy: dY, r: dR, color: Colors.blue),
          SubDot(dx: dGap / 2, dy: dY, r: dR, color: Colors.blue),
        ];
        List<SubDot> t6 = t3
            .map((d) => SubDot(dx: d.dx, dy: d.dy, r: d.r, color: Colors.red))
            .toList();
        t6.addAll([
          SubDot(dx: -dGap, dy: 2 * dY, r: dR, color: Colors.red),
          SubDot(dx: 0, dy: 2 * dY, r: dR, color: Colors.red),
          SubDot(dx: dGap, dy: 2 * dY, r: dR, color: Colors.red),
        ]);

        _entities.add(
          ShapeGroup(
            x: -120,
            y: 0,
            dots: t3,
            z: 5,
            canRotate: true,
            isDraggable: true,
            targetOffset: Offset(1.5 * dGap, dY),
            targetAngle: math.pi,
          ),
        );
        _entities.add(ShapeGroup(x: 0, y: 0, dots: t6, z: 1));
      } else if (index == 2) {
        _globalSequence = "25";
        List<Color> colors = [
          Colors.purple,
          Colors.blue,
          Colors.green,
          Colors.amber,
          Colors.red,
        ];
        for (int layer = 4; layer >= 0; layer--) {
          List<SubDot> dots = [];
          int size = layer + 1;
          for (int i = 0; i < size; i++) {
            dots.add(
              SubDot(
                dx: i * dGap,
                dy: (size - 1) * dGap,
                r: dR,
                color: colors[layer],
                isSquare: true,
              ),
            );
          }
          for (int i = 0; i < size - 1; i++) {
            dots.add(
              SubDot(
                dx: (size - 1) * dGap,
                dy: i * dGap,
                r: dR,
                color: colors[layer],
                isSquare: true,
              ),
            );
          }
          _entities.add(
            GnomonLayer(
              x: -100,
              y: -60,
              dots: dots,
              id: layer,
              isHighlightable: layer == 4,
              targetOffset: Offset(200.0 - layer * 40, -200.0 + layer * 60),
              countLabel: '${(layer + 1) * 2 - 1}',
              z: 5 - layer,
            ),
          );
        }
      } else if (index == 3) {
        _globalSequence = "Lines: 0";
        _entities.add(GraphNode(x: -80, y: 0, radius: dR, color: Colors.amber));
        _entities.add(GraphNode(x: 80, y: 0, radius: dR, color: Colors.amber));
      } else if (index == 4) {
        _globalSequence = "Total Dots: 19";
        _entities.add(
          ShapeGroup(
            x: 0,
            y: -20,
            dots:
                _getHexRingDots(0, dR) +
                _getHexRingDots(1, dR) +
                _getHexRingDots(2, dR),
          ),
        );
        List<SubDot> targets = _getHexRingDots(3, dR);
        for (var t in targets) {
          _entities.add(TargetDot(x: t.dx, y: t.dy - 20, radius: dR));
        }
        _entities.add(
          PaletteDot(x: -200, y: 100, radius: 20, color: Colors.amber),
        );
      }
    });
  }

  List<SubDot> _getHexRingDots(int radius, double rSize) {
    if (radius == 0)
      return [SubDot(dx: 0, dy: 0, r: rSize, color: Colors.blue)];
    double gap = rSize * 2.2;
    List<SubDot> pts = [];
    int q = radius;
    int rAx = 0;
    List<List<int>> dirs = [
      [-1, 1],
      [-1, 0],
      [0, -1],
      [1, -1],
      [1, 0],
      [0, 1],
    ];
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < radius; j++) {
        pts.add(
          SubDot(
            dx: gap * (q + rAx / 2),
            dy: gap * (rAx * math.sqrt(3) / 2),
            r: rSize,
            color: Colors.blue,
          ),
        );
        q += dirs[i][0];
        rAx += dirs[i][1];
      }
    }
    return pts;
  }

  // --- सहायक विधियाँ (Helper Methods) ---
  double _normalizeAngle(double angle) {
    double a = angle % (2 * math.pi);
    if (a < 0) a += 2 * math.pi;
    return a;
  }

  void _evaluateState() {
    Map<String, dynamic> tr = I18n.data[_lang]!;
    List steps = tr['scenarios'][_currentScenario]['steps'];
    bool isFinal = _currentStep == steps.length - 1;
    if (isFinal) return;

    if (_currentScenario == 0) {
      if (_currentStep == 0) {
        if (_entities.whereType<Dot>().where((e) => !e.isDraggable).length >=
            2) {
          _advanceStep();
        }
      } else {
        var targets = _entities.whereType<TargetDot>();
        if (targets.isNotEmpty && targets.every((t) => t.isFilled)) {
          setState(() {
            _globalSequence =
                "Count: ${((_currentStep + 1) * (_currentStep + 2)) ~/ 2}";
          });
          _advanceStep();
        }
      }
    } else if (_currentScenario == 1) {
      var t3 = _entities.whereType<ShapeGroup>().firstWhere(
        (e) => e.dots.length == 3,
        orElse: () => ShapeGroup(x: 0, y: 0, dots: []),
      );
      var t6 = _entities.whereType<ShapeGroup>().firstWhere(
        (e) => e.dots.length == 6 && e.canRotate,
        orElse: () => ShapeGroup(x: 0, y: 0, dots: []),
      );

      // चरण 0 या 1: नीला त्रिकोण (t3)
      if ((_currentStep == 0 || _currentStep == 1) && t3.dots.isNotEmpty) {
        if (!t3.isDraggable) {
          if (_currentStep == 0) _currentStep = 1;
          setState(() {
            _globalSequence = "3 + 6 = 9 (Square!)";
          });
          _advanceStep();
        } else if ((_normalizeAngle(t3.angle) - math.pi).abs() < 0.1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && (_currentStep == 0 || _currentStep == 1)) {
              var t3Check = _entities.whereType<ShapeGroup>().firstWhere(
                (e) => e.dots.length == 3,
                orElse: () => ShapeGroup(x: 0, y: 0, dots: []),
              );
              if (t3Check.isDraggable &&
                  (_normalizeAngle(t3Check.angle) - math.pi).abs() < 0.1) {
                setState(() {
                  t3Check.x = t3Check.targetOffset!.dx;
                  t3Check.y = t3Check.targetOffset!.dy;
                  t3Check.isDraggable = false;
                  _globalSequence = "3 + 6 = 9 (Square!)";
                });
                _playSound(sfxSnap);
                if (_currentStep == 0) _currentStep = 1;
                _advanceStep();
              }
            }
          });
        }
      }

      // चरण 2: लाल त्रिकोण (t6)
      if (_currentStep == 2 && t6.dots.isNotEmpty) {
        if (!t6.isDraggable) {
          setState(() {
            _globalSequence = "6 + 10 = 16 (Square!)";
          });
          _advanceStep();
        } else if ((_normalizeAngle(t6.angle) - math.pi).abs() < 0.1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _currentStep == 2) {
              var t6Check = _entities.whereType<ShapeGroup>().firstWhere(
                (e) => e.dots.length == 6 && e.canRotate,
                orElse: () => ShapeGroup(x: 0, y: 0, dots: []),
              );
              if (t6Check.isDraggable &&
                  (_normalizeAngle(t6Check.angle) - math.pi).abs() < 0.1) {
                setState(() {
                  t6Check.x = t6Check.targetOffset!.dx;
                  t6Check.y = t6Check.targetOffset!.dy;
                  t6Check.isDraggable = false;
                  _globalSequence = "6 + 10 = 16 (Square!)";
                });
                _playSound(sfxSnap);
                _advanceStep();
              }
            }
          });
        }
      }
    } else if (_currentScenario == 2) {
      var layers = _entities.whereType<GnomonLayer>().toList();
      int peeled = layers.where((l) => l.isPeeled).length;

      int remain = 4 - peeled;
      if (remain >= 0) {
        try {
          var nextL = layers.firstWhere((l) => l.id == remain);
          nextL.isHighlightable = true;
        } catch (_) {}
      }

      if (peeled < 5) {
        setState(() {
          _globalSequence = "${(remain + 1) * (remain + 1)}";
        });
      }

      if (peeled == 1 && _currentStep == 0) {
        _advanceStep();
      } else if (peeled == 2 && _currentStep == 1) {
        _advanceStep();
      } else if (peeled == 3 && _currentStep == 2) {
        _advanceStep();
      } else if (peeled == 5 && _currentStep == 3) {
        setState(() {
          _globalSequence = "1 + 3 + 5 + 7 + 9 = 25";
        });
        _advanceStep();
      }
    } else if (_currentScenario == 3) {
      setState(() {
        _globalSequence = "Lines: ${_graphLines.length}";
      });
      List<int> exp = [1, 3, 6, 0, 10];
      if (_currentStep < 3 && _graphLines.length == exp[_currentStep]) {
        _advanceStep();
      }
    } else if (_currentScenario == 4) {
      int filled = _entities
          .whereType<TargetDot>()
          .where((e) => e.isFilled)
          .length;
      setState(() {
        _globalSequence = "Total Dots: ${19 + filled}";
      });
      if (_currentStep == 0 && filled > 0)
        _advanceStep();
      else if (_currentStep == 1 && filled == 18)
        _advanceStep();
    }
  }

  void _advanceStep() {
    _playSound(sfxSuccess);
    setState(() {
      _currentStep++;
      if (_currentScenario == 0) {
        double dGap = 40;
        double dR = 15;
        if (_currentStep == 1) {
          _entities.removeWhere((e) => e is! PaletteDot);
          _entities.add(
            Dot(
              x: 0,
              y: 0,
              radius: dR,
              color: Colors.amber,
              z: 2,
              isDraggable: false,
            ),
          );
        } else if (_currentStep == 4) {
          _globalSequence = "Triangles: 1, 3, 6, 10...";
        }
        int row = _currentStep + 1;
        _entities.removeWhere((e) => e is TargetDot);
        if (row <= 4) {
          double startX = -((row - 1) * dGap) / 2;
          double rowY = (row - 1) * (math.sqrt(3) * dGap / 2);
          for (int i = 0; i < row; i++) {
            _entities.add(
              TargetDot(x: startX + i * dGap, y: rowY, radius: dR, z: 2),
            );
          }
        }
      } else if (_currentScenario == 1) {
        if (_currentStep == 2) {
          _globalSequence = "6 + 10 = ?";
          double dGap = 40, dR = 15, dY = math.sqrt(3) * dGap / 2;
          List<SubDot> t6 = [
            SubDot(dx: 0, dy: 0, r: dR, color: Colors.red),
            SubDot(dx: -dGap / 2, dy: dY, r: dR, color: Colors.red),
            SubDot(dx: dGap / 2, dy: dY, r: dR, color: Colors.red),
            SubDot(dx: -dGap, dy: 2 * dY, r: dR, color: Colors.red),
            SubDot(dx: 0, dy: 2 * dY, r: dR, color: Colors.red),
            SubDot(dx: dGap, dy: 2 * dY, r: dR, color: Colors.red),
          ];
          List<SubDot> t10 = t6
              .map(
                (d) => SubDot(dx: d.dx, dy: d.dy, r: d.r, color: Colors.amber),
              )
              .toList();
          t10.addAll([
            SubDot(dx: -dGap * 1.5, dy: 3 * dY, r: dR, color: Colors.amber),
            SubDot(dx: -dGap / 2, dy: 3 * dY, r: dR, color: Colors.amber),
            SubDot(dx: dGap / 2, dy: 3 * dY, r: dR, color: Colors.amber),
            SubDot(dx: dGap * 1.5, dy: 3 * dY, r: dR, color: Colors.amber),
          ]);
          _entities.clear();
          _entities.add(
            ShapeGroup(
              x: -150,
              y: 0,
              dots: t6,
              z: 5,
              canRotate: true,
              isDraggable: true,
              targetOffset: Offset(2 * dGap, 2 * dY),
              targetAngle: math.pi,
            ),
          );
          _entities.add(ShapeGroup(x: 0, y: 0, dots: t10, z: 1));
        }
      } else if (_currentScenario == 3) {
        _graphLines.clear();
        _entities.clear();
        double r = 80;
        if (_currentStep == 1) {
          for (int i = 0; i < 3; i++)
            _entities.add(
              GraphNode(
                x: r * math.cos(i * math.pi * 2 / 3 - math.pi / 2),
                y: r * math.sin(i * math.pi * 2 / 3 - math.pi / 2),
                radius: 15,
                color: Colors.amber,
              ),
            );
        } else if (_currentStep == 2) {
          for (int i = 0; i < 4; i++)
            _entities.add(
              GraphNode(
                x: r * 1.2 * math.cos(i * math.pi * 2 / 4 - math.pi / 4),
                y: r * 1.2 * math.sin(i * math.pi * 2 / 4 - math.pi / 4),
                radius: 15,
                color: Colors.amber,
              ),
            );
        } else if (_currentStep == 4) {
          for (int i = 0; i < 5; i++)
            _entities.add(
              GraphNode(
                x: 120 * math.cos(i * math.pi * 2 / 5 - math.pi / 2),
                y: 120 * math.sin(i * math.pi * 2 / 5 - math.pi / 2),
                radius: 15,
                color: Colors.amber,
              ),
            );
        }
      } else if (_currentScenario == 4) {
        if (_currentStep == 3) {
          _globalSequence = "Sequence: 1, 7, 19, 37! (+6, +12, +18)";
        }
      }
    });
  }

  void _checkGraphPred() {
    if (_predController.text == '10') {
      _advanceStep();
      _predController.clear();
    } else {
      _playSound(sfxError);
    }
  }

  void _checkHexagon() {
    var targets = _entities.whereType<TargetDot>();
    if (targets.isNotEmpty && targets.every((t) => t.isFilled)) {
      _playSound(sfxSuccess);
      if (_currentStep < 3) {
        _currentStep = 2;
        _advanceStep();
      }
    } else {
      _playSound(sfxError);
    }
  }

  // --- इंटरैक्शन लॉजिक (Interaction Logic) ---
  Offset _screenToWorld(Offset screenPos, Size size) {
    return Offset(
      (screenPos.dx - size.width / 2 - _cameraX) / _cameraScale,
      (screenPos.dy - size.height / 2 - _cameraY) / _cameraScale,
    );
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    if (_isShutterOpen == false) return;

    _baseScale = _cameraScale;

    Offset worldPos = _screenToWorld(details.localFocalPoint, size);

    if (_currentScenario == 3 && _currentStep < 4) {
      try {
        var node = _entities.whereType<GraphNode>().firstWhere(
          (e) => (Offset(e.x, e.y) - worldPos).distance < 30,
        );
        _playSound(sfxClick);
        setState(() {
          _isDrawingLine = true;
          _lineStartNode = node;
          _lineEndPos = worldPos;
        });
        return;
      } catch (_) {}
    }

    for (int i = _entities.length - 1; i >= 0; i--) {
      var ent = _entities[i];
      if (ent.isHidden) continue;
      bool hit = false;

      if (ent is PaletteDot) {
        if ((Offset(ent.x, ent.y) - worldPos).distance < ent.radius + 10)
          hit = true;
      } else if (ent is Dot && ent.isDraggable) {
        if ((Offset(ent.x, ent.y) - worldPos).distance < ent.radius + 15)
          hit = true;
      } else if (ent is ShapeGroup && ent.isDraggable) {
        if ((Offset(ent.x, ent.y) - worldPos).distance < 60) {
          hit = true;
        } else {
          for (var d in ent.dots) {
            double rotatedX =
                d.dx * math.cos(ent.angle) - d.dy * math.sin(ent.angle);
            double rotatedY =
                d.dx * math.sin(ent.angle) + d.dy * math.cos(ent.angle);
            Offset dotPos = Offset(ent.x + rotatedX, ent.y + rotatedY);
            if ((dotPos - worldPos).distance < d.r + 20) {
              hit = true;
              break;
            }
          }
        }
      } else if (ent is GnomonLayer && _currentScenario == 2) {
        if (ent.isHighlightable && !ent.isDraggable) {
          for (var d in ent.dots) {
            Offset dotPos = Offset(ent.x + d.dx, ent.y + d.dy);
            if ((dotPos - worldPos).distance < d.r + 20) {
              setState(() {
                ent.isHighlighted = true;
                ent.isDraggable = true;
              });
              _playSound(sfxClick);
              return;
            }
          }
        } else if (ent.isDraggable) {
          for (var d in ent.dots) {
            Offset dotPos = Offset(ent.x + d.dx, ent.y + d.dy);
            if ((dotPos - worldPos).distance < d.r + 20) {
              hit = true;
              break;
            }
          }
        }
      }

      if (hit) {
        _playSound(sfxClick);
        setState(() {
          Entity activeEnt = ent;
          if (ent is PaletteDot) {
            activeEnt = Dot(
              x: ent.x,
              y: ent.y,
              radius: 15,
              color: Colors.indigoAccent,
              isDraggable: true,
              z: 20,
            );
            _entities.add(activeEnt);
          }
          _draggedEntity = activeEnt;
          _dragStartPos = Offset(activeEnt.x, activeEnt.y);
          _dragOffset = Offset(
            activeEnt.x - worldPos.dx,
            activeEnt.y - worldPos.dy,
          );
          _draggedDist = 0;
        });
        return;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (details.pointerCount > 1) {
      setState(() {
        _cameraScale = (_baseScale * details.scale).clamp(0.2, 3.0);
        _cameraX += details.focalPointDelta.dx;
        _cameraY += details.focalPointDelta.dy;
      });
      return;
    }

    Offset worldPos = _screenToWorld(details.localFocalPoint, size);

    if (_isDrawingLine) {
      setState(() {
        _lineEndPos = worldPos;
      });
    } else if (_draggedEntity != null) {
      setState(() {
        _draggedDist += details.focalPointDelta.distance;
        _draggedEntity!.x = worldPos.dx + _dragOffset.dx;
        _draggedEntity!.y = worldPos.dy + _dragOffset.dy;

        if (_draggedEntity is Dot) {
          var dot = _draggedEntity as Dot;
          try {
            dot.target = _entities.whereType<TargetDot>().firstWhere(
              (t) =>
                  !t.isFilled &&
                  (Offset(dot.x, dot.y) - Offset(t.x, t.y)).distance < 40,
            );
            dot.isNearTarget = true;
          } catch (_) {
            dot.target = null;
            dot.isNearTarget = false;
          }
        } else if (_draggedEntity is ShapeGroup) {
          var sg = _draggedEntity as ShapeGroup;
          if (sg.targetOffset != null) {
            double angDiff =
                (sg.angle - (sg.targetAngle ?? 0)).abs() % (math.pi * 2);
            bool angMatch =
                angDiff < 0.2 || (angDiff - math.pi * 2).abs() < 0.2;
            sg.isNearTarget =
                (Offset(sg.x, sg.y) - sg.targetOffset!).distance < 60 &&
                angMatch;
          }
        } else if (_draggedEntity is GnomonLayer) {
          var gl = _draggedEntity as GnomonLayer;
          gl.isNearTarget =
              (Offset(gl.x, gl.y) - gl.targetOffset).distance < 120;
        }
      });
    } else {
      setState(() {
        _cameraX += details.focalPointDelta.dx;
        _cameraY += details.focalPointDelta.dy;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    if (_isDrawingLine) {
      try {
        var endNode = _entities.whereType<GraphNode>().firstWhere(
          (e) =>
              (Offset(e.x, e.y) - _lineEndPos).distance < 30 &&
              e != _lineStartNode,
        );
        bool exists = _graphLines.any(
          (l) =>
              (l.n1 == _lineStartNode && l.n2 == endNode) ||
              (l.n2 == _lineStartNode && l.n1 == endNode),
        );
        if (!exists) {
          setState(() {
            _graphLines.add(GraphLine(_lineStartNode!, endNode));
            _playSound(sfxSnap);
          });
          _evaluateState();
        } else {
          _playSound(sfxError);
        }
      } catch (_) {
        _playSound(sfxError);
      }
      setState(() {
        _isDrawingLine = false;
        _lineStartNode = null;
      });
    } else if (_draggedEntity != null) {
      var ent = _draggedEntity!;
      if (_draggedDist < 20 && ent is ShapeGroup && ent.canRotate) {
        setState(() {
          ent.angle += math.pi / 3;
          ent.x = _dragStartPos.dx;
          ent.y = _dragStartPos.dy;
        });
        _playSound(sfxClick);
        _evaluateState();
      } else if (ent is Dot) {
        if (ent.isNearTarget && ent.target != null) {
          setState(() {
            ent.x = ent.target!.x;
            ent.y = ent.target!.y;
            ent.target!.isFilled = true;
            ent.isDraggable = false;
          });
          _playSound(sfxSnap);
          _evaluateState();
        } else {
          if (_currentScenario == 0 && _currentStep == 0) {
            setState(() => ent.isDraggable = false);
            _playSound(sfxClick);
            _evaluateState();
          } else {
            setState(() => _entities.remove(ent));
            _playSound(sfxError);
          }
        }
      } else if (ent is ShapeGroup && ent.isNearTarget) {
        setState(() {
          ent.x = ent.targetOffset!.dx;
          ent.y = ent.targetOffset!.dy;
          ent.angle = ent.targetAngle ?? 0;
          ent.isDraggable = false;
        });
        _playSound(sfxSnap);
        _evaluateState();
      } else if (ent is GnomonLayer && ent.isNearTarget) {
        setState(() {
          ent.x = ent.targetOffset.dx;
          ent.y = ent.targetOffset.dy;
          ent.isDraggable = false;
          ent.isPeeled = true;
          ent.isHighlightable = false;
          ent.isHighlighted = false;
        });
        _playSound(sfxSnap);
        _evaluateState();
      } else {
        setState(() {
          ent.x = _dragStartPos.dx;
          ent.y = _dragStartPos.dy;
        });

        if (_draggedDist >= 20 && _currentScenario == 1 && _currentStep == 0) {
          _advanceStep();
        } else {
          _playSound(sfxError);
        }
      }
      setState(() {
        _draggedEntity = null;
      });
    }
  }

  // --- यूआई बिल्डर्स (UI Builders) ---
  Widget _buildSidebar() {
    Map<String, dynamic> tr = I18n.data[_lang]!;
    List steps = tr['scenarios'][_currentScenario]['steps'];

    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // हेडर (Header)
            Padding(
              padding: const EdgeInsets.only(
                top: 60,
                left: 16,
                right: 16,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.category, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr['subtitle'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // भाषा और रीसेट रो (Language and Reset Row)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _playSound(sfxClick);
                            _toggleLanguage();
                          },
                          icon: const Icon(
                            Icons.language,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: Text(
                            tr['language'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _resetLab,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        label: const Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          side: const BorderSide(color: Colors.white24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),

            // परिदृश्य चयनकर्ता (Scenario Selector)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _currentScenario,
                    dropdownColor: const Color(0xFF1E293B),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    items: List.generate(tr['scenarios'].length, (i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text(tr['scenarios'][i]['title']),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) _loadScenario(val);
                    },
                  ),
                ),
              ),
            ),

            // चरण (Steps)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: steps.length,
              itemBuilder: (context, i) {
                bool isCurrent = i == _currentStep;
                bool isPast = i < _currentStep;
                if (i > _currentStep && i != steps.length - 1)
                  return const SizedBox.shrink();

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isCurrent || isPast ? 1.0 : 0.4,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.indigo.withOpacity(0.3)
                          : Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? Colors.indigoAccent : Colors.white12,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isPast ? Icons.check_circle : Icons.gps_fixed,
                          color: isPast
                              ? Colors.green
                              : (isCurrent ? Colors.indigoAccent : Colors.grey),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            steps[i]['text'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isCurrent ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // फूटर (Footer)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              color: Colors.black26,
              child: Text(
                tr['footer'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    Map<String, dynamic> tr = I18n.data[_lang]!;
    String stepText =
        tr['scenarios'][_currentScenario]['steps'][_currentStep]['text'];

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: !_isSidebarOpen ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: _isSidebarOpen,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr['missionObj'],
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stepText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // कैनवस साइज पैरामीटर के साथ यूआई (UI with Canvas Size parameter)
  Widget _buildOverlayUI(Size canvasSize) {
    Map<String, dynamic> tr = I18n.data[_lang]!;
    List<Widget> children = [];

    // वैश्विक अनुक्रम पाठ (Global Sequence Text)
    if (_globalSequence.isNotEmpty) {
      children.add(
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              _globalSequence,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black, blurRadius: 10)],
              ),
            ),
          ),
        ),
      );
    }

    // चरण 3 (ग्राफ) इनपुट (Step 3 Graph Input)
    if (_currentScenario == 3 && _currentStep == 3) {
      children.add(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr['scenarios'][3]['steps'][3]['text'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _predController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        _playSound(sfxClick);
                        _checkGraphPred();
                      },
                      child: Text(
                        tr['btnSubmit'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // चरण 4 (षट्भुज) चेक बटन (Step 4 Hexagon Check Button)
    if (_currentScenario == 4 && _currentStep == 2) {
      children.add(
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              onPressed: () {
                _playSound(sfxClick);
                _checkHexagon();
              },
              icon: const Icon(Icons.check_circle),
              label: Text(
                tr['btnCheck'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    // फ्लोटिंग बटन के लिए स्क्रीन निर्देशांक (Screen coordinates relative to canvas)
    for (var ent in _entities.whereType<ShapeGroup>()) {
      if (ent.canRotate && ent.isDraggable && !ent.isHidden) {
        double screenX =
            (ent.x * _cameraScale) + canvasSize.width / 2 + _cameraX;
        double screenY =
            (ent.y * _cameraScale) + canvasSize.height / 2 + _cameraY;

        children.add(
          Positioned(
            left: screenX + 20,
            top: screenY - 70,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _playSound(sfxClick);
                  setState(() {
                    ent.angle += math.pi / 3;
                  });
                  _evaluateState();
                },
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.rotate_right,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: children);
  }

  Widget _buildCompletionDialog() {
    Map<String, dynamic> tr = I18n.data[_lang]!;
    List steps = tr['scenarios'][_currentScenario]['steps'];

    if (_currentStep != steps.length - 1) return const SizedBox.shrink();

    bool hasNext = _currentScenario < tr['scenarios'].length - 1;

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text(
                  _lang == 'hi' ? 'पैटर्न खोजा गया!' : 'Pattern Discovered!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  steps[_currentStep]['text'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    _playSound(sfxClick);
                    if (hasNext) {
                      _loadScenario(_currentScenario + 1);
                    } else {
                      _loadScenario(0);
                    }
                  },
                  icon: Icon(
                    hasNext ? Icons.arrow_forward : Icons.refresh,
                    color: Colors.white,
                  ),
                  label: Text(
                    hasNext
                        ? tr['nextScenario']
                        : (_lang == 'hi'
                              ? 'लैब पुनः आरंभ करें'
                              : 'Restart Lab'),
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
    );
  }

  Widget _buildShutter() {
    Map<String, dynamic> tr = I18n.data[_lang]!;
    return AnimatedBuilder(
      animation: _shutterAnim,
      builder: (context, child) {
        if (_shutterAnim.value <= -0.99) return const SizedBox.shrink();
        return Transform.translate(
          offset: Offset(
            0,
            MediaQuery.of(context).size.height * _shutterAnim.value,
          ),
          child: Container(
            color: const Color(0xFF020617),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tr['title'],
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigoAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  tr['subtitle'],
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
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
                  onPressed: _enterLab,
                  child: Text(
                    tr['enterLab'],
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // पृष्ठभूमि ग्रिड (Background Grid)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // इंटरैक्टिव कैनवस और UI (Interactive Canvas & UI Area)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? screenWidth * 0.35 : 0,
              right: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // नए उपलब्ध क्षेत्र के आधार पर साइज
                  Size canvasSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return Stack(
                    children: [
                      // कैनवस (Canvas)
                      Positioned.fill(
                        child: GestureDetector(
                          onScaleStart: (d) => _handleScaleStart(d, canvasSize),
                          onScaleUpdate: (d) =>
                              _handleScaleUpdate(d, canvasSize),
                          onScaleEnd: (d) => _handleScaleEnd(d, canvasSize),
                          child: CustomPaint(
                            painter: LabPainter(
                              entities: _entities,
                              graphLines: _graphLines,
                              cameraX: _cameraX,
                              cameraY: _cameraY,
                              cameraScale: _cameraScale,
                              drawStateActive: _isDrawingLine,
                              drawStart: _lineStartNode != null
                                  ? Offset(_lineStartNode!.x, _lineStartNode!.y)
                                  : Offset.zero,
                              drawEnd: _lineEndPos,
                            ),
                            child: Container(),
                          ),
                        ),
                      ),

                      // कैनवस UI लेयर (Canvas UI Layer)
                      Positioned.fill(child: _buildOverlayUI(canvasSize)),

                      // फ्लोटिंग मिशन कार्ड (Floating Mission Card) - अब कैनवस के भीतर
                      _buildFloatingMissionCard(),
                    ],
                  );
                },
              ),
            ),

            // साइडबार (Sidebar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -screenWidth * 0.35,
              child: _buildSidebar(),
            ),

            // मेनू आइकन (Menu Icon - शीर्ष बाएँ पर स्थिर)
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _playSound(sfxClick);
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.8)),
                    ),
                    child: Icon(
                      _isSidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.orangeAccent,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            // पूर्णता डायलॉग (Completion Dialog)
            _buildCompletionDialog(),

            // शटर ओवरले (Shutter Overlay)
            _buildShutter(),
          ],
        ),
      ),
    );
  }
}

// --- पेंटर (Painter) ---
class LabPainter extends CustomPainter {
  final List<Entity> entities;
  final List<GraphLine> graphLines;
  final double cameraX;
  final double cameraY;
  final double cameraScale;
  final bool drawStateActive;
  final Offset drawStart;
  final Offset drawEnd;

  LabPainter({
    required this.entities,
    required this.graphLines,
    required this.cameraX,
    required this.cameraY,
    required this.cameraScale,
    required this.drawStateActive,
    required this.drawStart,
    required this.drawEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + cameraX, size.height / 2 + cameraY);
    canvas.scale(cameraScale);

    Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += 40) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    Paint linePaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var l in graphLines) {
      canvas.drawLine(
        Offset(l.n1.x, l.n1.y),
        Offset(l.n2.x, l.n2.y),
        linePaint,
      );
    }

    if (drawStateActive) {
      Paint dashPaint = Paint()
        ..color = Colors.lightBlueAccent.withOpacity(0.5)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      double d = (drawEnd - drawStart).distance;
      double dashLength = 10;
      double spaceLength = 10;
      int dashes = (d / (dashLength + spaceLength)).floor();
      Offset dir = (drawEnd - drawStart) / d;
      for (int i = 0; i < dashes; i++) {
        Offset p1 = drawStart + dir * (i * (dashLength + spaceLength));
        Offset p2 = p1 + dir * dashLength;
        canvas.drawLine(p1, p2, dashPaint);
      }
    }

    var sortedEntities = List<Entity>.from(entities)
      ..sort((a, b) => a.z.compareTo(b.z));

    for (var ent in sortedEntities) {
      if (ent.isHidden) continue;
      canvas.save();
      canvas.translate(ent.x, ent.y);

      if (ent is TargetDot) {
        if (!ent.isFilled) {
          Paint p = Paint()
            ..color = Colors.white24
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          for (double i = 0; i < math.pi * 2; i += 0.4) {
            canvas.drawArc(
              Rect.fromCircle(center: Offset.zero, radius: ent.radius),
              i,
              0.2,
              false,
              p,
            );
          }
        }
      } else if (ent is Dot) {
        _draw3DSphere(canvas, Offset.zero, ent.radius, ent.color);
      } else if (ent is PaletteDot) {
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(0, 40), width: 60, height: 20),
          Paint()..color = Colors.white12,
        );
        _draw3DSphere(canvas, Offset.zero, ent.radius, ent.color);
      } else if (ent is GraphNode) {
        canvas.drawCircle(
          Offset.zero,
          ent.radius + 4,
          Paint()..color = Colors.white,
        );
        _draw3DSphere(canvas, Offset.zero, ent.radius, ent.color);
      } else if (ent is ShapeGroup) {
        canvas.rotate(ent.angle);
        for (var d in ent.dots) {
          if (d.isSquare) {
            _drawSquare(canvas, Offset(d.dx, d.dy), d.r, d.color);
          } else {
            _draw3DSphere(canvas, Offset(d.dx, d.dy), d.r, d.color);
          }
        }
      } else if (ent is GnomonLayer) {
        if (ent.isHighlighted) {
          Paint glow = Paint()
            ..color = Colors.amber.withOpacity(0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
          for (var d in ent.dots)
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset(d.dx, d.dy),
                width: d.r * 2.5,
                height: d.r * 2.5,
              ),
              glow,
            );
        } else if (ent.isHighlightable && !ent.isDraggable) {
          Paint glow = Paint()
            ..color = Colors.white30
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
          for (var d in ent.dots)
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset(d.dx, d.dy),
                width: d.r * 2.2,
                height: d.r * 2.2,
              ),
              glow,
            );
        }
        for (var d in ent.dots) {
          _drawSquare(canvas, Offset(d.dx, d.dy), d.r, d.color);
        }
        if (ent.isPeeled) {
          TextPainter tp = TextPainter(
            text: TextSpan(
              text: ent.countLabel,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          tp.paint(
            canvas,
            Offset(
              ((ent.dots.length / 2) * 40) / 2 - tp.width / 2,
              (ent.dots.length / 2) * 40 + 20,
            ),
          );
        }
      }
      canvas.restore();
    }

    canvas.restore();
  }

  void _draw3DSphere(
    Canvas canvas,
    Offset center,
    double radius,
    Color baseColor,
  ) {
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.8,
      colors: [Colors.white, baseColor, _darken(baseColor, 0.4)],
      stops: const [0.0, 0.4, 1.0],
    );
    Paint p = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(
      center + const Offset(0, 2),
      radius,
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(center, radius, p);
  }

  void _drawSquare(Canvas canvas, Offset center, double r, Color color) {
    Rect rect = Rect.fromCenter(
      center: center,
      width: r * 2 - 2,
      height: r * 2 - 2,
    );
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTRB(rect.left + 2, rect.top + 2, rect.right - 2, rect.top + r),
      Paint()..color = Colors.white24,
    );
  }

  Color _darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
