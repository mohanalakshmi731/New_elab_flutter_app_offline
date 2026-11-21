// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const Cl6M_Ch1_A3_Visualizing_Number_Sequences());
  });
}

class Cl6M_Ch1_A3_Visualizing_Number_Sequences extends StatefulWidget {
  const Cl6M_Ch1_A3_Visualizing_Number_Sequences({super.key});

  @override
  State<Cl6M_Ch1_A3_Visualizing_Number_Sequences> createState() =>
      _Cl6M_Ch1_A3_Visualizing_Number_SequencesState();
}

class _Cl6M_Ch1_A3_Visualizing_Number_SequencesState
    extends State<Cl6M_Ch1_A3_Visualizing_Number_Sequences> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Dot Architect',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFEAB308),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

// --- Localization ---
class AppLocalizations {
  static final Map<String, Map<String, dynamic>> _localizedValues = {
    'en': {
      'title': 'The Dot Architect: Visualizing Number Sequences',
      'subtitle': 'Class 6 • PATTERNS IN MATHEMATICS',
      'enterLab': 'Enter Virtual Lab',
      'selectScenario': 'Select Scenario',
      'missionObj': 'Mission Objective',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'hudDefault': 'Select a scenario to begin.',
      'nextScenario': 'Next Scenario',
      'scenarioComplete': 'Scenario Complete',
      'patternDiscovered': 'Pattern Discovered!',
      'btnNextStep': 'NEXT STEP',
      'dispenser': 'DISPENSER',
      'progress': 'Dots placed: ',
      'scenarios': [
        {
          'title': "1. The Perfect Square",
          'objective':
              "Understand why numbers like 1, 4, 9, and 16 are called 'square numbers' by physically arranging dots into square shapes.",
          'steps': [
            {
              'text':
                  "1 is the first square number. It's a 1x1 square. Click 'NEXT STEP'.",
              'hud': "Click 'NEXT STEP' to begin.",
            },
            {
              'text':
                  "Drag dots from the dispenser onto the four glowing spots to form a 2x2 grid.",
              'hud': "Drag dots to fill the 2x2 outline.",
            },
            {
              'text':
                  "A larger 3x3 grid outline appears. Drag dots to fill this new grid.",
              'hud': "Drag dots to expand into a 3x3 square.",
            },
            {
              'text': "Drag and drop dots to complete the 4x4 grid.",
              'hud': "Complete the 4x4 square (16 dots).",
            },
            {
              'text': "Sequence Complete! 1, 4, 9, 16... are Square Numbers.",
              'hud': "Sequence Complete! 1, 4, 9, 16...",
            },
          ],
        },
        {
          'title': "2. Building Up Triangles",
          'objective':
              "Visualize the sequence of triangular numbers (1, 3, 6, 10) and understand their 'growing row' pattern.",
          'steps': [
            {
              'text': "1 is the first triangular number. Click 'NEXT STEP'.",
              'hud': "Click 'NEXT STEP' to begin.",
            },
            {
              'text':
                  "Drag the row of two dots from the dispenser to fill the outline.",
              'hud': "Drag the 2-dot row from the Dispenser.",
            },
            {
              'text':
                  "Drag the three dots from the dispenser to complete the shape.",
              'hud': "Drag the 3-dot row to continue the triangle.",
            },
            {
              'text': "Drag the four dots to complete the shape.",
              'hud': "Drag the 4-dot row to finish.",
            },
            {
              'text':
                  "Sequence Complete! 1, 3, 6, 10... are Triangular Numbers.",
              'hud': "Sequence Complete! 1, 3, 6, 10...",
            },
          ],
        },
        {
          'title': "3. Odd Numbers Make a Square!",
          'objective':
              "Visually discover the relationship between the sequence of odd numbers and the sequence of square numbers.",
          'steps': [
            {
              'text':
                  "A purple dot represents the first odd number, 1. Click 'NEXT STEP'.",
              'hud': "Click 'NEXT STEP' to begin.",
            },
            {
              'text':
                  "Drag the 3 green dots L-shape to fit around the purple dot.",
              'hud': "Snap the 3-dot L-shape around the dot.",
            },
            {
              'text':
                  "Drag the 5 blue dots L-shape to fit around the 2x2 square.",
              'hud': "Snap the 5-dot L-shape around the square.",
            },
            {
              'text':
                  "Drag the 7 yellow dots L-shape to fit around the 3x3 square.",
              'hud': "Snap the 7-dot L-shape to finish.",
            },
            {
              'text': "Sequence Complete! Odd numbers build squares.",
              'hud': "Sequence Complete! Odd numbers build squares.",
            },
          ],
        },
        {
          'title': "4. Triangle Puzzle (Unsolved)",
          'objective':
              "Discover the relationship between triangular numbers and square numbers by combining two consecutive triangular shapes.",
          'steps': [
            {
              'text':
                  "Combine the 3rd (6) and 4th (10) triangles. Click 'NEXT STEP'.",
              'hud': "Click 'NEXT STEP' to begin.",
            },
            {
              'text': "Drag shapes to the grid. Click the shape to turn it.",
              'hud': "Drag shapes. Click to turn.",
            },
            {
              'text': "Puzzle Solved! Two consecutive triangles make a square.",
              'hud': "Puzzle Solved! Two triangles make a square.",
            },
          ],
        },
        {
          'title': "5. The Growing Hexagon (Unsolved)",
          'objective':
              "Identify the growth pattern of hexagonal numbers and construct the next number in the sequence.",
          'steps': [
            {
              'text':
                  "Study the pattern (1, 7, 19). Can you build the 4th? Click 'NEXT STEP'.",
              'hud': "Click 'NEXT STEP' to start.",
            },
            {
              'text':
                  "Drag dots from the dispenser to fill the 18 outer glowing spots.",
              'hud': "Build the 4th Hexagon ring.",
            },
            {
              'text': "Sequence Complete! The 4th Hexagon is 37.",
              'hud': "Sequence Complete! 4th Hexagon is 37.",
            },
          ],
        },
      ],
    },
    'hi': {
      'title': 'द डॉट आर्किटेक्ट: संख्या अनुक्रमों की कल्पना',
      'subtitle': 'कक्षा 6 • गणित में पैटर्न',
      'enterLab': 'वर्चुअल लैब में प्रवेश करें',
      'selectScenario': 'परिदृश्य चुनें',
      'missionObj': 'मिशन का उद्देश्य',
      'footer': '© ZeroScienceLab - Fall in love with math and Science',
      'hudDefault': 'शुरू करने के लिए एक परिदृश्य चुनें।',
      'nextScenario': 'अगला परिदृश्य',
      'scenarioComplete': 'परिदृश्य पूर्ण',
      'patternDiscovered': 'पैटर्न खोजा गया!',
      'btnNextStep': 'अगला कदम',
      'dispenser': 'डिस्पेंसर',
      'progress': 'रखे गए बिंदु: ',
      'scenarios': [
        {
          'title': "1. पूर्ण वर्ग",
          'objective':
              "समझें कि 1, 4, 9 और 16 को 'वर्ग संख्याएँ' क्यों कहा जाता है।",
          'steps': [
            {
              'text': "1 पहली वर्ग संख्या है। 'अगला कदम' पर क्लिक करें।",
              'hud': "शुरू करने के लिए 'अगला कदम' पर क्लिक करें।",
            },
            {
              'text':
                  "2x2 ग्रिड बनाने के लिए बिंदुओं को चमकते स्थानों पर खींचें।",
              'hud': "2x2 रूपरेखा को भरने के लिए बिंदुओं को खींचें।",
            },
            {
              'text': "3x3 ग्रिड को भरने के लिए बिंदुओं को खींचें।",
              'hud': "3x3 वर्ग में विस्तारित करने के लिए खींचें।",
            },
            {
              'text': "4x4 ग्रिड को पूरा करने के लिए खींचें।",
              'hud': "4x4 वर्ग को पूरा करने के लिए खींचें।",
            },
            {
              'text': "अनुक्रम पूर्ण! 1, 4, 9, 16... वर्ग संख्याएँ हैं।",
              'hud': "अनुक्रम पूर्ण! 1, 4, 9, 16...",
            },
          ],
        },
        {
          'title': "2. त्रिकोण का निर्माण",
          'objective':
              "त्रिकोणीय संख्याओं (1, 3, 6, 10) के अनुक्रम की कल्पना करें।",
          'steps': [
            {
              'text': "1 पहली त्रिकोणीय संख्या है। 'अगला कदम' पर क्लिक करें।",
              'hud': "शुरू करने के लिए 'अगला कदम' पर क्लिक करें।",
            },
            {
              'text': "रूपरेखा को भरने के लिए 2 बिंदुओं को खींचें।",
              'hud': "डिस्पेंसर से 2-बिंदु पंक्ति खींचें।",
            },
            {
              'text': "आकार को पूरा करने के लिए 3 बिंदुओं को खींचें।",
              'hud': "3-बिंदु पंक्ति खींचें।",
            },
            {
              'text': "आकार को पूरा करने के लिए 4 बिंदुओं को खींचें।",
              'hud': "4-बिंदु पंक्ति खींचें।",
            },
            {
              'text': "अनुक्रम पूर्ण! 1, 3, 6, 10... त्रिकोणीय संख्याएँ हैं।",
              'hud': "अनुक्रम पूर्ण! 1, 3, 6, 10...",
            },
          ],
        },
        {
          'title': "3. विषम संख्याएँ वर्ग बनाती हैं!",
          'objective': "विषम संख्याओं और वर्ग संख्याओं के बीच संबंध खोजें।",
          'steps': [
            {
              'text':
                  "एक बैंगनी बिंदु पहली विषम संख्या, 1 है। 'अगला कदम' क्लिक करें।",
              'hud': "शुरू करने के लिए 'अगला कदम' पर क्लिक करें।",
            },
            {
              'text': "3 हरे बिंदुओं को बैंगनी बिंदु के चारों ओर फिट करें।",
              'hud': "हरे 3-बिंदु को चारों ओर स्नैप करें।",
            },
            {
              'text': "5 नीले बिंदुओं को 2x2 वर्ग के चारों ओर फिट करें।",
              'hud': "नीले 5-बिंदु को वर्ग के चारों ओर स्नैप करें।",
            },
            {
              'text': "7 पीले बिंदुओं को 3x3 वर्ग के चारों ओर फिट करें।",
              'hud': "पीले 7-बिंदु को 4x4 वर्ग पूरा करने के लिए स्नैप करें।",
            },
            {
              'text': "अनुक्रम पूर्ण! विषम संख्याएँ वर्ग बनाती हैं।",
              'hud': "अनुक्रम पूर्ण! विषम संख्याएँ वर्ग बनाती हैं।",
            },
          ],
        },
        {
          'title': "4. त्रिकोण पहेली (अनसुलझा)",
          'objective': "दो लगातार त्रिकोणीय आकृतियों को मिलाकर वर्ग बनाएँ।",
          'steps': [
            {
              'text':
                  "3रे (6) और 4थे (10) त्रिकोणों को जोड़ें। 'अगला कदम' क्लिक करें।",
              'hud': "शुरू करने के लिए 'अगला कदम' पर क्लिक करें।",
            },
            {
              'text':
                  "आकृतियों को ग्रिड पर खींचें। घुमाने के लिए आकृति पर क्लिक करें।",
              'hud': "आकृतियों को खींचें। घुमाने के लिए क्लिक करें।",
            },
            {
              'text': "पहेली हल हो गई! दो त्रिकोण एक वर्ग बनाते हैं।",
              'hud': "पहेली हल हो गई! दो त्रिकोण एक वर्ग बनाते हैं।",
            },
          ],
        },
        {
          'title': "5. बढ़ता हुआ षट्भुज (अनसुलझा)",
          'objective': "षट्कोणीय संख्याओं के पैटर्न को पहचानें।",
          'steps': [
            {
              'text':
                  "पैटर्न (1, 7, 19) का अध्ययन करें। 4था बनाएँ। 'अगला कदम' क्लिक करें।",
              'hud': "शुरू करने के लिए 'अगला कदम' पर क्लिक करें।",
            },
            {
              'text':
                  "18 बाहरी चमकते स्थानों को भरने के लिए बिंदुओं को खींचें।",
              'hud': "4थी षट्भुज अंगूठी बनाने के लिए बिंदुओं को खींचें।",
            },
            {
              'text': "अनुक्रम पूर्ण! 4था षट्भुज 37 है।",
              'hud': "अनुक्रम पूर्ण! 4था षट्भुज 37 है।",
            },
          ],
        },
      ],
    },
  };

  static Map<String, dynamic> get(String lang) {
    return _localizedValues[lang] ?? _localizedValues['en']!;
  }
}

// --- Audio Manager ---
class AudioManager {
  static final AudioPlayer _player = AudioPlayer();
  static const String clickSound = 'audio/class6/math/click.mp3';
  static const String snapSound = 'audio/class6/math/click.mp3';
  static const String errorSound = 'audio/class6/math/mixkit_2570.mp3';
  static const String successSound = 'audio/class6/math/success.mp3';
  static const String enterSound = 'audio/class6/math/success.mp3';

  static void play(String type) async {
    try {
      String url = clickSound;
      if (type == 'snap') url = snapSound;
      if (type == 'error') url = errorSound;
      if (type == 'success') url = successSound;
      if (type == 'enter') url = enterSound;

      await _player.stop();
      await _player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }
}

// --- Canvas Entities ---
abstract class CanvasEntity {
  double x;
  double y;
  bool isDraggable;
  bool isHidden;
  bool isNearTarget;

  CanvasEntity({
    required this.x,
    required this.y,
    this.isDraggable = false,
    this.isHidden = false,
    this.isNearTarget = false,
  });

  void draw(Canvas canvas, Size size);
  bool hitTest(Offset localPosition);
}

class DotEntity extends CanvasEntity {
  final double radius;
  Color color;
  final String label;

  DotEntity({
    required super.x,
    required super.y,
    this.radius = 20,
    this.color = Colors.white,
    this.label = '',
    super.isDraggable,
  });

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(x, y), radius, paint);

    final shinePaint = Paint()..color = Colors.white.withOpacity(0.4);
    canvas.drawCircle(
      Offset(x - radius * 0.3, y - radius * 0.3),
      radius * 0.3,
      shinePaint,
    );
  }

  @override
  bool hitTest(Offset pt) {
    return (Offset(x, y) - pt).distance <= radius * 2.0;
  }
}

class GhostDotEntity extends CanvasEntity {
  final double radius;
  bool filled;
  Color color;

  GhostDotEntity({
    required super.x,
    required super.y,
    this.radius = 20,
    this.filled = false,
    this.color = Colors.transparent,
  });

  @override
  void draw(Canvas canvas, Size size) {
    if (filled) {
      final paint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), radius, paint);
      final shinePaint = Paint()..color = Colors.white.withOpacity(0.4);
      canvas.drawCircle(
        Offset(x - radius * 0.3, y - radius * 0.3),
        radius * 0.3,
        shinePaint,
      );
    } else {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool hitTest(Offset pt) => false;
}

class SourceDotEntity extends DotEntity {
  final double originX;
  final double originY;

  SourceDotEntity({
    required super.x,
    required super.y,
    required this.originX,
    required this.originY,
    super.radius,
    required super.color,
  }) : super(isDraggable: true);
}

class SubDot {
  final double dx;
  final double dy;
  final double r;
  final Color color;
  SubDot({
    required this.dx,
    required this.dy,
    required this.r,
    required this.color,
  });
}

class GroupEntity extends CanvasEntity {
  final List<SubDot> dots;
  Offset? target;
  double angle;
  double targetAngle;
  bool canRotate;

  GroupEntity({
    required super.x,
    required super.y,
    required this.dots,
    this.target,
    this.angle = 0,
    this.targetAngle = 0,
    this.canRotate = false,
    super.isDraggable = true,
  });

  @override
  void draw(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    if (isNearTarget) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      for (var d in dots) {
        canvas.drawCircle(Offset(d.dx, d.dy), d.r + 5, glowPaint);
      }
    }

    for (var d in dots) {
      final paint = Paint()..color = d.color;
      canvas.drawCircle(Offset(d.dx, d.dy), d.r, paint);
      final shinePaint = Paint()..color = Colors.white.withOpacity(0.4);
      canvas.drawCircle(
        Offset(d.dx - d.r * 0.3, d.dy - d.r * 0.3),
        d.r * 0.3,
        shinePaint,
      );
    }

    canvas.restore();

    // Draw Target Hint if near
    if (isNearTarget && target != null) {
      canvas.save();
      canvas.translate(target!.dx, target!.dy);
      canvas.rotate(targetAngle);
      final hintPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (var d in dots) {
        canvas.drawCircle(Offset(d.dx, d.dy), d.r, hintPaint);
        canvas.drawCircle(Offset(d.dx, d.dy), d.r, borderPaint);
      }
      canvas.restore();
    }
  }

  @override
  bool hitTest(Offset pt) {
    double cosA = cos(-angle);
    double sinA = sin(-angle);
    double lx = pt.dx - x;
    double ly = pt.dy - y;
    double rx = lx * cosA - ly * sinA;
    double ry = lx * sinA + ly * cosA;

    for (var d in dots) {
      if ((Offset(rx, ry) - Offset(d.dx, d.dy)).distance <= d.r * 2.5) {
        return true;
      }
    }
    return false;
  }
}

// --- Main Application State ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';

  int _currentScenario = 0;
  int _currentStep = 0;

  // Canvas State
  List<CanvasEntity> entities = [];
  String? globalSequence;
  Offset cameraPos = Offset.zero;
  double cameraScale = 1.0;
  double _baseScale = 1.0;

  // Drag State
  CanvasEntity? draggedEntity;
  Offset dragStartOffset = Offset.zero;
  Offset entityStartPos = Offset.zero;
  Offset _dragStartLocalFocalPoint = Offset.zero;
  bool hasDraggedSignificantly = false;

  final double dGap = 50.0;
  final double dR = 20.0;

  late AnimationController _curtainController;

  // Smooth Rotation State
  late AnimationController _rotateController;
  GroupEntity? _rotatingEntity;
  double _rotateStartAngle = 0.0;
  double _rotateTargetAngle = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _curtainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotateController.addListener(() {
      if (mounted && _rotatingEntity != null) {
        setState(() {
          _rotatingEntity!.angle =
              _rotateStartAngle +
              (_rotateTargetAngle - _rotateStartAngle) *
                  Curves.easeInOut.transform(_rotateController.value);
        });
      }
    });
    _rotateController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          mounted &&
          _rotatingEntity != null) {
        _rotatingEntity!.angle = _rotateTargetAngle % (2 * pi);
        _checkSnapAfterRotation(_rotatingEntity!);
        _rotatingEntity = null;
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _curtainController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _enterLab() {
    AudioManager.play('enter');
    _curtainController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isCurtainOpen = true;
        });
        _loadScenario(0);
      }
    });
  }

  void _resetLab() {
    AudioManager.play('click');
    _rotateController.stop();
    _rotatingEntity = null;
    setState(() {
      _isCurtainOpen = false;
      _currentScenario = 0;
      _currentStep = 0;
      entities.clear();
      _curtainController.reverse();
    });
  }

  void _toggleLang() {
    AudioManager.play('click');
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  void _toggleSidebar() {
    AudioManager.play('click');
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    Future.delayed(const Duration(milliseconds: 300), _fitToScreen);
  }

  void _loadScenario(int index) {
    _rotateController.stop();
    _rotatingEntity = null;

    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      entities.clear();
      globalSequence = null;

      if (index == 0) {
        entities.add(
          DotEntity(
            x: -dGap / 2,
            y: -dGap / 2,
            radius: dR,
            color: const Color(0xFF6366F1),
          ),
        );
      } else if (index == 1) {
        entities.add(
          DotEntity(x: 0, y: -50, radius: dR, color: const Color(0xFF22C55E)),
        );
      } else if (index == 2) {
        entities.add(
          DotEntity(
            x: -dGap / 2,
            y: -dGap / 2,
            radius: dR,
            color: const Color(0xFFA855F7),
          ),
        );
      } else if (index == 3) {
        globalSequence = "6 + 10 = ?";
        for (int r = 0; r < 4; r++) {
          for (int c = 0; c < 4; c++) {
            entities.add(
              GhostDotEntity(
                x: c * dGap - dGap * 1.5,
                y: r * dGap - dGap * 1.5,
                radius: dR,
              ),
            );
          }
        }
      } else if (index == 4) {
        globalSequence = "1, 7, 19...";
        var pts = _getHexRingOffsets(0, dGap)
          ..addAll(_getHexRingOffsets(1, dGap))
          ..addAll(_getHexRingOffsets(2, dGap));
        for (var pt in pts) {
          entities.add(
            DotEntity(
              x: pt.dx,
              y: pt.dy,
              radius: dR,
              color: const Color(0xFFEAB308),
            ),
          );
        }
      }
    });
    _fitToScreen();
  }

  List<Offset> _getHexRingOffsets(int radius, double size) {
    if (radius == 0) return [const Offset(0, 0)];
    List<Offset> pts = [];
    int q = 0, r = -radius;
    List<List<int>> dirs = [
      [1, 0, -1],
      [0, 1, -1],
      [-1, 1, 0],
      [-1, 0, 1],
      [0, -1, 1],
      [1, -1, 0],
    ];
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < radius; j++) {
        double x = size * sqrt(3) * (q + r / 2);
        double y = size * 3 / 2 * r;
        pts.add(Offset(x, y));
        q += dirs[i][0];
        r += dirs[i][1];
      }
    }
    return pts;
  }

  void _advanceStep() {
    AudioManager.play('success');
    setState(() {
      _currentStep++;
      var tr = AppLocalizations.get(_lang);
      var scen = tr['scenarios'][_currentScenario];
      bool isFinalStep = _currentStep == (scen['steps'] as List).length - 1;

      if (_currentScenario == 0) {
        globalSequence = _currentStep == 1
            ? "1, 4"
            : _currentStep == 2
            ? "1, 4, 9"
            : "1, 4, 9, 16";
        if (!isFinalStep) {
          Color c = _currentStep == 1
              ? Colors.red
              : _currentStep == 2
              ? Colors.amber
              : Colors.green;
          int s = _currentStep + 1;
          for (int i = 0; i < s; i++) {
            entities.add(
              GhostDotEntity(
                x: i * dGap - dGap / 2,
                y: (s - 1) * dGap - dGap / 2,
                radius: dR,
              ),
            );
          }
          for (int i = 0; i < s - 1; i++) {
            entities.add(
              GhostDotEntity(
                x: (s - 1) * dGap - dGap / 2,
                y: i * dGap - dGap / 2,
                radius: dR,
              ),
            );
          }
          entities.removeWhere((e) => e is SourceDotEntity);
          entities.add(
            SourceDotEntity(
              x: 0,
              y: 250,
              originX: 0,
              originY: 250,
              radius: dR,
              color: c,
            ),
          );
        } else {
          entities.removeWhere((e) => e is SourceDotEntity);
        }
      } else if (_currentScenario == 1) {
        double dY = sqrt(3) * dGap / 2;
        globalSequence = _currentStep == 1
            ? "1, 3"
            : _currentStep == 2
            ? "1, 3, 6"
            : "1, 3, 6, 10";
        if (!isFinalStep) {
          int rowSize = _currentStep + 1;
          Color c = _currentStep == 1
              ? Colors.blue
              : _currentStep == 2
              ? Colors.red
              : Colors.amber;
          double yLevel = -50 + dY * _currentStep;
          List<SubDot> dots = [];
          for (int i = 0; i < rowSize; i++) {
            double xOff = (i - (rowSize - 1) / 2) * dGap;
            dots.add(SubDot(dx: xOff, dy: 0, r: dR, color: c));
          }
          entities.add(
            GroupEntity(x: 0, y: 250, dots: dots, target: Offset(0, yLevel)),
          );
        }
      } else if (_currentScenario == 2) {
        globalSequence = _currentStep == 1
            ? "1, 4"
            : _currentStep == 2
            ? "1, 4, 9"
            : "1, 4, 9, 16";
        if (!isFinalStep) {
          int s = _currentStep + 1;
          Color c = _currentStep == 1
              ? Colors.green
              : _currentStep == 2
              ? Colors.blue
              : Colors.amber;
          List<SubDot> dots = [];
          for (int i = 0; i < s; i++) {
            dots.add(SubDot(dx: i * dGap, dy: (s - 1) * dGap, r: dR, color: c));
          }
          for (int i = 0; i < s - 1; i++) {
            dots.add(SubDot(dx: (s - 1) * dGap, dy: i * dGap, r: dR, color: c));
          }
          entities.add(
            GroupEntity(
              x: 0,
              y: 250,
              dots: dots,
              target: Offset(-dGap / 2, -dGap / 2),
            ),
          );
        }
      } else if (_currentScenario == 3) {
        if (_currentStep == 1 && !isFinalStep) {
          List<SubDot> t10 = [], t6 = [];
          for (int r = 0; r < 4; r++) {
            for (int c = 0; c <= r; c++) {
              t10.add(
                SubDot(dx: c * dGap, dy: r * dGap, r: dR, color: Colors.blue),
              );
            }
          }
          for (int r = 0; r < 3; r++) {
            for (int c = 0; c <= r; c++) {
              t6.add(
                SubDot(dx: c * dGap, dy: r * dGap, r: dR, color: Colors.red),
              );
            }
          }
          entities.add(
            GroupEntity(
              x: -200,
              y: 150,
              dots: t10,
              target: Offset(-dGap * 1.5, -dGap * 1.5),
              targetAngle: 0,
              canRotate: true,
            ),
          );
          entities.add(
            GroupEntity(
              x: 200,
              y: 150,
              dots: t6,
              target: Offset(dGap * 1.5, dGap * 0.5),
              targetAngle: pi,
              canRotate: true,
            ),
          );
        }
      } else if (_currentScenario == 4) {
        if (_currentStep == 1 && !isFinalStep) {
          var ring3 = _getHexRingOffsets(3, dGap);
          for (var pt in ring3) {
            entities.add(GhostDotEntity(x: pt.dx, y: pt.dy, radius: dR));
          }
          entities.add(
            SourceDotEntity(
              x: 0,
              y: 250,
              originX: 0,
              originY: 250,
              radius: dR,
              color: Colors.red,
            ),
          );
        } else if (_currentStep == 2) {
          globalSequence = "1, 7, 19, 37...";
          entities.removeWhere((e) => e is SourceDotEntity);
        }
      }
    });
  }

  void _checkGameState() {
    if (_currentScenario == 0 || _currentScenario == 4) {
      var ghosts = entities.whereType<GhostDotEntity>().toList();
      if (ghosts.isNotEmpty && ghosts.every((g) => g.filled)) {
        Future.delayed(const Duration(milliseconds: 500), _advanceStep);
      }
    } else {
      var draggables = entities
          .whereType<GroupEntity>()
          .where((g) => g.isDraggable)
          .toList();
      if (draggables.isEmpty && _currentStep > 0) {
        if (_currentScenario == 3) globalSequence = "6 + 10 = 16";
        Future.delayed(const Duration(milliseconds: 500), _advanceStep);
      }
    }
  }

  void _checkSnapAfterRotation(GroupEntity ent) {
    if (ent.target != null) {
      double dist = (Offset(ent.x, ent.y) - ent.target!).distance;
      double angleDiff = (ent.angle - ent.targetAngle).abs();
      if (dist < 60 && (angleDiff < 0.2 || (angleDiff - 2 * pi).abs() < 0.2)) {
        setState(() {
          ent.x = ent.target!.dx;
          ent.y = ent.target!.dy;
          ent.angle = ent.targetAngle;
          ent.isDraggable = false;
          ent.isNearTarget = false;
        });
        AudioManager.play('snap');
        _checkGameState();
      }
    }
  }

  // --- Canvas Interaction ---
  void _fitToScreen() {
    setState(() {
      cameraPos = Offset.zero;
      cameraScale = 1.0;
    });
  }

  Offset _screenToWorld(Offset screenPos, Size size) {
    double cx = size.width / 2 + cameraPos.dx;
    double cy = size.height / 2 + cameraPos.dy;
    return Offset(
      (screenPos.dx - cx) / cameraScale,
      (screenPos.dy - cy) / cameraScale,
    );
  }

  // EXPLICIT TAP HANDLER added here to intercept tap gestures correctly before drag logic interferes
  void _onTapUp(TapUpDetails details, Size size) {
    Offset worldPos = _screenToWorld(details.localPosition, size);

    for (int i = entities.length - 1; i >= 0; i--) {
      var ent = entities[i];
      if (!ent.isDraggable || ent.isHidden) continue;

      if (ent is GroupEntity && ent.canRotate) {
        // Just click anywhere on the shape to trigger the smooth rotation!
        if (ent.hitTest(worldPos)) {
          if (_rotateController.isAnimating) return;
          AudioManager.play('click');

          draggedEntity =
              null; // Instantly prevent dragging logic from triggering

          _rotatingEntity = ent;
          _rotateStartAngle = ent.angle;
          _rotateTargetAngle = _rotateStartAngle + pi / 2;
          _rotateController.forward(from: 0.0);
          return;
        }
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details, Size size) {
    _baseScale = cameraScale;
    Offset worldPos = _screenToWorld(details.localFocalPoint, size);
    hasDraggedSignificantly = false;
    _dragStartLocalFocalPoint = details.localFocalPoint;

    for (int i = entities.length - 1; i >= 0; i--) {
      var ent = entities[i];
      if (!ent.isDraggable || ent.isHidden) continue;

      if (ent.hitTest(worldPos)) {
        draggedEntity = ent;
        entityStartPos = Offset(ent.x, ent.y);
        dragStartOffset = Offset(ent.x - worldPos.dx, ent.y - worldPos.dy);
        setState(() {});
        return;
      }
    }
    draggedEntity = null;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (draggedEntity != null) {
      if ((details.localFocalPoint - _dragStartLocalFocalPoint).distance >
          10.0) {
        hasDraggedSignificantly = true;
      }

      if (hasDraggedSignificantly) {
        Offset worldPos = _screenToWorld(details.localFocalPoint, size);
        setState(() {
          draggedEntity!.x = worldPos.dx + dragStartOffset.dx;
          draggedEntity!.y = worldPos.dy + dragStartOffset.dy;
          draggedEntity!.isNearTarget = false;

          if (draggedEntity is GroupEntity) {
            var ge = draggedEntity as GroupEntity;
            if (ge.target != null) {
              double dist = (Offset(ge.x, ge.y) - ge.target!).distance;
              double angleDiff = (ge.angle % (2 * pi) - ge.targetAngle).abs();
              if (dist < 60 &&
                  (angleDiff < 0.2 || (angleDiff - 2 * pi).abs() < 0.2)) {
                ge.isNearTarget = true;
              }
            }
          } else if (draggedEntity is SourceDotEntity) {
            var ghosts = entities.whereType<GhostDotEntity>().where(
              (g) => !g.filled,
            );
            for (var g in ghosts) {
              if ((Offset(draggedEntity!.x, draggedEntity!.y) -
                          Offset(g.x, g.y))
                      .distance <
                  40) {
                draggedEntity!.isNearTarget = true;
                break;
              }
            }
          }
        });
      }
    } else {
      setState(() {
        cameraPos += details.focalPointDelta;
        cameraScale = (_baseScale * details.scale).clamp(0.2, 3.0);
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (draggedEntity != null) {
      bool snapped = false;

      if (draggedEntity is SourceDotEntity) {
        var se = draggedEntity as SourceDotEntity;
        var ghosts = entities.whereType<GhostDotEntity>().where(
          (g) => !g.filled,
        );
        for (var g in ghosts) {
          if ((Offset(se.x, se.y) - Offset(g.x, g.y)).distance < 40) {
            g.filled = true;
            g.color = se.color;
            snapped = true;
            AudioManager.play('snap');
            break;
          }
        }
        se.x = se.originX;
        se.y = se.originY;
        se.isNearTarget = false;
      } else if (draggedEntity is GroupEntity) {
        var ge = draggedEntity as GroupEntity;
        if (ge.target != null) {
          double dist = (Offset(ge.x, ge.y) - ge.target!).distance;
          double angleDiff = (ge.angle % (2 * pi) - ge.targetAngle).abs();
          if (dist < 60 &&
              (angleDiff < 0.2 || (angleDiff - 2 * pi).abs() < 0.2)) {
            ge.x = ge.target!.dx;
            ge.y = ge.target!.dy;
            ge.angle = ge.targetAngle;
            ge.isDraggable = false;
            ge.isNearTarget = false;
            snapped = true;
            AudioManager.play('snap');
          }
        }
      }

      if (!snapped) {
        if (hasDraggedSignificantly) AudioManager.play('error');
        if (draggedEntity is SourceDotEntity) {
          draggedEntity!.x = entityStartPos.dx;
          draggedEntity!.y = entityStartPos.dy;
        }
      } else {
        _checkGameState();
      }

      setState(() {
        draggedEntity = null;
      });
    }
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    var tr = AppLocalizations.get(_lang);
    double screenW = MediaQuery.of(context).size.width;
    // Constrain sidebar width between limits
    if (_sidebarWidth < 250) _sidebarWidth = 250;
    if (_sidebarWidth > screenW * 0.6) _sidebarWidth = screenW * 0.6;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // 1. Canvas Layer
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    // onTapUp explicitly assigned here to intercept taps properly over dragging
                    onTapUp: (d) => _onTapUp(d, constraints.biggest),
                    onScaleStart: (d) => _onScaleStart(d, constraints.biggest),
                    onScaleUpdate: (d) =>
                        _onScaleUpdate(d, constraints.biggest),
                    onScaleEnd: _onScaleEnd,
                    child: CustomPaint(
                      painter: CanvasPainter(
                        entities: entities,
                        cameraPos: cameraPos,
                        cameraScale: cameraScale,
                        globalSequence: globalSequence,
                      ),
                      size: Size.infinite,
                    ),
                  );
                },
              ),
            ),

            // 2. HUD & Floating Mission Card (Visible if sidebar collapsed)
            if (!_isSidebarOpen)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getCurrentHudText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_currentStep == 0) ...[
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            label: Text(
                              tr['btnNextStep'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            onPressed: _advanceStep,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              width: _sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
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
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sidebar Header Area
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 60,
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tr['subtitle'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _toggleLang,
                                      icon: const Icon(
                                        Icons.language,
                                        size: 16,
                                      ),
                                      label: Text(_lang.toUpperCase()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white12,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        minimumSize: Size.zero,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: _resetLab,
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.redAccent
                                            .withOpacity(0.3),
                                        padding: const EdgeInsets.all(8),
                                        minimumSize: Size.zero,
                                      ),
                                      tooltip: 'Reset Lab',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  value: _currentScenario,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black26,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  dropdownColor: const Color(0xFF1E293B),
                                  items: List.generate(
                                    (tr['scenarios'] as List).length,
                                    (index) {
                                      return DropdownMenuItem(
                                        value: index,
                                        child: Text(
                                          tr['scenarios'][index]['title'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    },
                                  ),
                                  onChanged: (val) {
                                    AudioManager.play('click');
                                    if (val != null) _loadScenario(val);
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Steps & Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr['missionObj'],
                                  style: const TextStyle(
                                    color: Colors.indigoAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tr['scenarios'][_currentScenario]['objective'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const Divider(
                                  height: 30,
                                  color: Colors.white24,
                                ),
                                ..._buildStepsList(),

                                if (_currentStep == 0) ...[
                                  const SizedBox(height: 20),
                                  Center(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        tr['btnNextStep'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: _advanceStep,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tr['footer'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54,
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
              ),
            ),

            // 3.5 Resizer Handle
            if (_isSidebarOpen)
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
                        double screenW = MediaQuery.of(context).size.width;
                        _sidebarWidth += details.delta.dx;
                        if (_sidebarWidth < 250) _sidebarWidth = 250;
                        if (_sidebarWidth > screenW * 0.6) {
                          _sidebarWidth = screenW * 0.6;
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

            // 4. Menu Icon (Fixed top left)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: _toggleSidebar,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // 5. Success Popup Overlay
            if (_isScenarioComplete())
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 20),
                          ],
                        ),
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tr['patternDiscovered'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getCurrentStepText(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: Icon(
                                _currentScenario < 4
                                    ? Icons.arrow_forward
                                    : Icons.refresh,
                                color: Colors.white,
                              ),
                              label: Text(
                                _currentScenario < 4
                                    ? tr['nextScenario']
                                    : 'Reset',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                AudioManager.play('click');
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

            // 6. Curtain Screen
            if (!_isCurtainOpen)
              AnimatedBuilder(
                animation: _curtainController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -MediaQuery.of(context).size.height *
                          _curtainController.value,
                    ),
                    child: Container(
                      color: const Color(0xFF020617),
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.grain,
                                size: 80,
                                color: Colors.indigoAccent,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                tr['title'],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.indigoAccent,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tr['subtitle'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: _enterLab,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
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

  bool _isScenarioComplete() {
    var tr = AppLocalizations.get(_lang);
    var scen = tr['scenarios'][_currentScenario];
    return _currentStep == (scen['steps'] as List).length - 1;
  }

  String _getCurrentStepText() {
    var tr = AppLocalizations.get(_lang);
    var steps = tr['scenarios'][_currentScenario]['steps'] as List;
    return steps[_currentStep]['text'];
  }

  String _getCurrentHudText() {
    var tr = AppLocalizations.get(_lang);
    var steps = tr['scenarios'][_currentScenario]['steps'] as List;
    return steps[_currentStep]['hud'];
  }

  List<Widget> _buildStepsList() {
    var tr = AppLocalizations.get(_lang);
    var steps = tr['scenarios'][_currentScenario]['steps'] as List;
    List<Widget> list = [];

    for (int i = 0; i <= _currentStep; i++) {
      if (i == steps.length - 1) continue;
      bool isCurrent = i == _currentStep;
      list.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrent
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: isCurrent ? Colors.indigo : Colors.white12,
            ),
            borderRadius: BorderRadius.circular(12),
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
                  steps[i]['text'],
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white54,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return list;
  }
}

// --- Custom Canvas Painter ---
class CanvasPainter extends CustomPainter {
  final List<CanvasEntity> entities;
  final Offset cameraPos;
  final double cameraScale;
  final String? globalSequence;

  CanvasPainter({
    required this.entities,
    required this.cameraPos,
    required this.cameraScale,
    this.globalSequence,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    canvas.save();
    canvas.translate(
      size.width / 2 + cameraPos.dx,
      size.height / 2 + cameraPos.dy,
    );
    canvas.scale(cameraScale);

    if (entities.any((e) => e is SourceDotEntity)) {
      final paint = Paint()..color = Colors.white.withOpacity(0.05);
      canvas.drawRRect(
        RRect.fromLTRBR(-150, 200, 150, 300, const Radius.circular(15)),
        paint,
      );
    }

    var sorted = List<CanvasEntity>.from(entities);
    sorted.sort((a, b) {
      int scoreA = a is GhostDotEntity ? 0 : (a.isDraggable ? 2 : 1);
      int scoreB = b is GhostDotEntity ? 0 : (b.isDraggable ? 2 : 1);
      return scoreA.compareTo(scoreB);
    });

    for (var ent in sorted) {
      if (!ent.isHidden) {
        ent.draw(canvas, size);
      }
    }

    if (globalSequence != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: globalSequence,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -260));
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    double step = 40.0 * cameraScale;
    if (step < 10) return;

    double startX = (cameraPos.dx + size.width / 2) % step;
    double startY = (cameraPos.dy + size.height / 2) % step;

    for (double x = startX; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = startY; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}
