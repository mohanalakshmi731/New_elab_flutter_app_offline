// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Symmetry Sorter',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: zslDark,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'sans-serif'),
      ),
      home: const Cl6M_Ch9_A6_ClassifyingFiguresbyCombinedSymmetries(),
    ),
  );
}

// --- GLOBAL THEME & CONSTANTS ---
const Color zslDark = Color(0xFF0F172A);
const Color zslSidebar = Color(0xFF1E293B);
const Color zslLight = Color(0xFFF8FAFC);
const Color zslIndigo = Color(0xFF6366F1);
const Color zslEmerald = Color(0xFF10B981);
const Color zslRose = Color(0xFFF43F5E);
const Color zslAmber = Color(0xFFF59E0B);

// --- LOCALIZATION (i18n) ---
class I18n {
  static const Map<String, Map<String, String>> dict = {
    'en': {
      'shutterTitle': 'Symmetry Sorter: The Shape Classification Lab',
      'appTitle': 'Symmetry Sorter',
      'appSubtitle': 'Class 6 • SYMMETRY',
      'enterLab': 'Enter Simulation',
      'settings': 'Settings',
      'selectScenario': 'Select Scenario',
      'stepLabel': 'STEP',
      'learnLbl': 'Objective:',
      'summaryTitle': 'Goal Reached!',
      'resetBtn': 'Reset Lab',
      'finishLab': 'Finish Lab',
      'nextScenario': 'Next Scenario',
      'lbl_line_sym': 'Line Symmetry',
      'lbl_rot_sym': 'Rotational Symmetry',
      'lbl_horiz_sym': 'Horizontal Symmetry',
      'lbl_mat_line': 'Line Symmetry Only',
      'lbl_mat_rot': 'Rotational Symmetry Only',
      'lbl_mat_both': 'Both',
      'lbl_mat_none': 'None',
      'lbl_tools': 'Symmetry Toolkit',
      'lbl_results': 'Results',
      'lbl_fold_tool': 'Fold Tool',
      'lbl_rot_tool': 'Rotate Tool',
      'lbl_fail': 'Incorrect placement! Try again.',
      'msg_test_vertical': 'Test the vertical line first!',
      'msg_test_horizontal': 'Test the horizontal line!',
      's1_title': '1. The Mirror Kite',
      's1_obj':
          'To test a kite for both line and rotational symmetry and classify it correctly.',
      's1_step1_task':
          "DRAG the 'Folding Tool' and DROP it onto the vertical dotted line of the kite.",
      's1_step1_out': 'The two halves perfectly overlap. It has Line Symmetry.',
      's1_step2_task':
          "Now, DRAG the 'Folding Tool' and DROP it onto the horizontal dotted line.",
      's1_step2_out':
          'The halves do not overlap correctly. The horizontal line is not a line of symmetry.',
      's1_step3_task':
          "DRAG the 'Rotation Tool' and DROP it onto the center point of the kite.",
      's1_step3_out': 'A rotation handle appears.',
      's1_step4_task':
          'CLICK and DRAG the handle to rotate the kite a full 360 degrees.',
      's1_step4_out':
          'It never aligns with its original outline until a full 360 turn. It has NO Rotational Symmetry.',
      's1_step5_task':
          'DRAG the kite figure and DROP it into the correct quadrant on the Sorting Mat.',
      's1_step5_out': "The kite fits in the 'Line Symmetry Only' category.",
      's1_hud1': 'Drag the Folding Tool to the vertical line.',
      's1_hud2': 'Drag the Folding Tool to the horizontal line.',
      's1_hud3': 'Drag the Rotation Tool to the center.',
      's1_hud4': 'Rotate the handle full circle.',
      's1_hud5': 'Drag the kite to the correct Mat category.',
      's2_title': '2. The Spinning Parallelogram',
      's2_obj':
          'To test a parallelogram for both line and rotational symmetry and classify it correctly.',
      's2_step1_task':
          "DRAG the 'Folding Tool' and DROP it onto any of the dotted lines.",
      's2_step1_out':
          'The halves do not overlap correctly. It has NO Line Symmetry.',
      's2_step2_task':
          "DRAG the 'Rotation Tool' and DROP it onto the center point.",
      's2_step2_out': 'A rotation handle appears.',
      's2_step3_task':
          'CLICK and DRAG the handle to rotate the parallelogram a full 360 degrees.',
      's2_step3_out':
          'It aligns perfectly at a half-turn (180 degrees). It has Rotational Symmetry.',
      's2_step4_task':
          'DRAG the parallelogram to the correct quadrant on the Sorting Mat.',
      's2_step4_out': "It fits in the 'Rotational Symmetry Only' category.",
      's2_hud1': 'Drag the Folding Tool to test for lines.',
      's2_hud2': 'Drag the Rotation Tool to the center.',
      's2_hud3': 'Rotate the shape 360 degrees.',
      's2_hud4': 'Drag the shape to the correct Mat category.',
      's3_title': '3. The Perfect Square',
      's3_obj':
          'To test a square for both line and rotational symmetry and classify it correctly.',
      's3_step1_task':
          "DRAG the 'Folding Tool' and DROP it onto the vertical line.",
      's3_step1_out': 'The square folds perfectly. It has Line Symmetry.',
      's3_step2_task': "DRAG the 'Rotation Tool' and DROP it onto the center.",
      's3_step2_out': 'A rotation handle appears.',
      's3_step3_task':
          'CLICK and DRAG the handle to rotate the square 360 degrees.',
      's3_step3_out':
          'It snaps into place 4 times during a full rotation. It has Rotational Symmetry.',
      's3_step4_task':
          'DRAG the square to the correct quadrant on the Sorting Mat.',
      's3_step4_out': "It fits perfectly in the 'Both' category.",
      's3_hud1': 'Drag the Folding Tool to a dashed line.',
      's3_hud2': 'Drag the Rotation Tool to the center.',
      's3_hud3': 'Rotate the shape 360 degrees.',
      's3_hud4': 'Drag the shape to the correct Mat category.',
      's4_title': '4. The Hexagon Challenge',
      's4_obj':
          'To independently test a regular hexagon and classify it correctly.',
      's4_step1_task':
          'Use the Tools to independently test the regular hexagon for BOTH Line and Rotational symmetry.',
      's4_step1_out': 'You discovered the hexagon has both types of symmetry.',
      's4_step2_task':
          'DRAG the hexagon to the correct quadrant on the Sorting Mat.',
      's4_step2_out': "It fits perfectly in the 'Both' category.",
      's4_hud1': 'Use the tools to test the shape.',
      's4_hud2': 'Sort the shape onto the Mat.',
      's5_title': '5. The Scalene Challenge',
      's5_obj':
          'To independently test a scalene triangle and classify it correctly.',
      's5_step1_task':
          'Use the Tools to independently test the scalene triangle for BOTH Line and Rotational symmetry.',
      's5_step1_out':
          'You discovered it has neither line nor rotational symmetry.',
      's5_step2_task':
          'DRAG the scalene triangle to the correct quadrant on the Sorting Mat.',
      's5_step2_out': "It fits perfectly in the 'Neither' category.",
      's5_hud1': 'Use the tools to test the shape.',
      's5_hud2': 'Sort the shape onto the Mat.',
    },
    'hi': {
      'shutterTitle': 'समरूपता छांटने वाला: आकार वर्गीकरण लैब',
      'appTitle': 'समरूपता छांटने वाला',
      'appSubtitle': 'कक्षा 6 • समरूपता',
      'enterLab': 'सिमुलेशन दर्ज करें',
      'settings': 'सेटिंग्स',
      'selectScenario': 'परिदृश्य चुनें',
      'stepLabel': 'चरण',
      'learnLbl': 'उद्देश्य:',
      'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
      'resetBtn': 'रीसेट करें',
      'finishLab': 'समाप्त करें',
      'nextScenario': 'अगला परिदृश्य',
      'lbl_line_sym': 'रेखा समरूपता',
      'lbl_rot_sym': 'घूर्णी समरूपता',
      'lbl_horiz_sym': 'क्षैतिज समरूपता',
      'lbl_mat_line': 'केवल रेखा समरूपता',
      'lbl_mat_rot': 'केवल घूर्णी',
      'lbl_mat_both': 'दोनों',
      'lbl_mat_none': 'कोई नहीं',
      'lbl_tools': 'उपकरण',
      'lbl_results': 'परिणाम',
      'lbl_fold_tool': 'फ़ोल्डिंग टूल',
      'lbl_rot_tool': 'रोटेशन टूल',
      'lbl_fail': 'गलत जगह! फिर से प्रयास करें।',
      'msg_test_vertical': 'पहले ऊर्ध्वाधर रेखा का परीक्षण करें!',
      'msg_test_horizontal': 'क्षैतिज रेखा का परीक्षण करें!',
      's1_title': '1. पतंग का परीक्षण',
      's1_obj':
          'पतंग का समरूपता के लिए परीक्षण करना और उसे सही ढंग से वर्गीकृत करना।',
      's1_step1_task':
          "'फ़ोल्डिंग टूल' को पतंग की ऊर्ध्वाधर बिंदु वाली रेखा पर खींचें।",
      's1_step1_out':
          'दोनों भाग पूरी तरह से ओवरलैप करते हैं। इसमें रेखा समरूपता है।',
      's1_step2_task': "अब, 'फ़ोल्डिंग टूल' को क्षैतिज रेखा पर खींचें।",
      's1_step2_out':
          'भाग सही ढंग से ओवरलैप नहीं करते हैं। क्षैतिज रेखा समरूपता की रेखा नहीं है।',
      's1_step3_task': "'रोटेशन टूल' को पतंग के केंद्र बिंदु पर खींचें।",
      's1_step3_out': 'एक रोटेशन हैंडल दिखाई देता है।',
      's1_step4_task': 'पतंग को 360 डिग्री घुमाने के लिए हैंडल को खींचें।',
      's1_step4_out':
          'यह पूर्ण चक्कर तक मूल रूपरेखा के साथ संरेखित नहीं होता है। कोई घूर्णी समरूपता नहीं।',
      's1_step5_task': 'पतंग को सॉर्टिंग मैट पर सही चतुर्थांश में खींचें।',
      's1_step5_out': "पतंग 'केवल रेखा समरूपता' श्रेणी में फिट बैठती है।",
      's1_hud1': 'उपकरण को ऊर्ध्वाधर रेखा पर खींचें।',
      's1_hud2': 'उपकरण को क्षैतिज रेखा पर खींचें।',
      's1_hud3': 'रोटेशन टूल को केंद्र में खींचें।',
      's1_hud4': 'हैंडल को पूरा घुमाएं।',
      's1_hud5': 'आकृति को सही श्रेणी में खींचें।',
      's2_title': '2. घूमता समांतर चतुर्भुज',
      's2_obj':
          'समांतर चतुर्भुज का समरूपता के लिए परीक्षण करना और उसे वर्गीकृत करना।',
      's2_step1_task': "'फ़ोल्डिंग टूल' को किसी भी बिंदु वाली रेखा पर खींचें।",
      's2_step1_out':
          'भाग सही ढंग से ओवरलैप नहीं करते हैं। कोई रेखा समरूपता नहीं।',
      's2_step2_task': "'रोटेशन टूल' को केंद्र बिंदु पर खींचें।",
      's2_step2_out': 'एक रोटेशन हैंडल दिखाई देता है।',
      's2_step3_task':
          'समांतर चतुर्भुज को 360 डिग्री घुमाने के लिए हैंडल खींचें।',
      's2_step3_out':
          'यह आधे चक्कर (180 डिग्री) पर संरेखित होता है। इसमें घूर्णी समरूपता है।',
      's2_step4_task':
          'समांतर चतुर्भुज को सॉर्टिंग मैट पर सही चतुर्थांश में खींचें।',
      's2_step4_out': "यह 'केवल घूर्णी समरूपता' श्रेणी में फिट बैठता है।",
      's2_hud1': 'रेखाओं का परीक्षण करने के लिए उपकरण खींचें।',
      's2_hud2': 'रोटेशन टूल को केंद्र में खींचें।',
      's2_hud3': 'आकृति को 360 डिग्री घुमाएं।',
      's2_hud4': 'आकृति को सही श्रेणी में खींचें।',
      's3_title': '3. सही वर्ग',
      's3_obj': 'वर्ग का समरूपता के लिए परीक्षण करना और उसे वर्गीकृत करना।',
      's3_step1_task': "'फ़ोल्डिंग टूल' को ऊर्ध्वाधर रेखा पर खींचें।",
      's3_step1_out': 'वर्ग पूरी तरह से मुड़ता है। इसमें रेखा समरूपता है।',
      's3_step2_task': "'रोटेशन टूल' को केंद्र में खींचें।",
      's3_step2_out': 'एक रोटेशन हैंडल दिखाई देता है।',
      's3_step3_task': 'वर्ग को 360 डिग्री घुमाने के लिए हैंडल खींचें।',
      's3_step3_out':
          'यह पूर्ण रोटेशन के दौरान 4 बार स्नैप होता है। इसमें घूर्णी समरूपता है।',
      's3_step4_task': 'वर्ग को सॉर्टिंग मैट पर सही चतुर्थांश में खींचें।',
      's3_step4_out': "यह 'दोनों' श्रेणी में फिट बैठता है।",
      's3_hud1': 'उपकरण को रेखा पर खींचें।',
      's3_hud2': 'रोटेशन टूल को केंद्र में खींचें।',
      's3_hud3': 'आकृति को 360 डिग्री घुमाएं।',
      's3_hud4': 'आकृति को सही श्रेणी में खींचें।',
      's4_title': '4. षट्भुज चुनौती',
      's4_obj':
          'सम षट्भुज का स्वतंत्र रूप से परीक्षण करना और उसे वर्गीकृत करना।',
      's4_step1_task':
          'दोनों समरूपता के लिए षट्भुज का स्वतंत्र रूप से परीक्षण करने के लिए उपकरणों का उपयोग करें।',
      's4_step1_out': 'आपने खोजा कि षट्भुज में दोनों प्रकार की समरूपता है।',
      's4_step2_task': 'षट्भुज को सॉर्टिंग मैट पर सही चतुर्थांश में खींचें।',
      's4_step2_out': "यह 'दोनों' श्रेणी में फिट बैठता है।",
      's4_hud1': 'परीक्षण करने के लिए उपकरणों का उपयोग करें।',
      's4_hud2': 'आकृति को मैट पर सॉर्ट करें।',
      's5_title': '5. विषमबाहु चुनौती',
      's5_obj':
          'विषमबाहु त्रिभुज का स्वतंत्र रूप से परीक्षण करना और उसे वर्गीकृत करना।',
      's5_step1_task':
          'दोनों समरूपता के लिए विषमबाहु त्रिभुज का स्वतंत्र रूप से परीक्षण करने के लिए उपकरणों का उपयोग करें।',
      's5_step1_out': 'आपने खोजा कि इसमें कोई समरूपता नहीं है।',
      's5_step2_task':
          'विषमबाहु त्रिभुज को सॉर्टिंग मैट पर सही चतुर्थांश में खींचें।',
      's5_step2_out': "यह 'कोई नहीं' श्रेणी में फिट बैठता है।",
      's5_hud1': 'परीक्षण करने के लिए उपकरणों का उपयोग करें।',
      's5_hud2': 'आकृति को मैट पर सॉर्ट करें।',
    },
  };

  static String t(String key, String lang) {
    return dict[lang]?[key] ?? dict['en']?[key] ?? key;
  }
}

// --- DATA MODELS ---
class SymLine {
  final double x;
  final double y;
  final double angle;
  final bool valid;
  SymLine({
    required this.x,
    required this.y,
    required this.angle,
    required this.valid,
  });
}

class ShapeDef {
  final List<Offset> pts;
  final List<SymLine> lines;
  final int rotPoints;
  final void Function(
    Canvas ctx,
    Path basePath,
    Paint paintFill,
    Paint paintStroke,
  )
  drawExtra;

  ShapeDef({
    required this.pts,
    required this.lines,
    required this.rotPoints,
    required this.drawExtra,
  });

  Path get path {
    final p = Path();
    if (pts.isEmpty) return p;
    p.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      p.lineTo(pts[i].dx, pts[i].dy);
    }
    p.close();
    return p;
  }
}

class SimState {
  double panX = 0;
  double panY = 0;
  double zoom = 1.0;

  String? dragItem; // 'fold', 'rot', 'shape'
  double dragX = 0;
  double dragY = 0;

  double shapeX = 0;
  double shapeY = -80;

  SymLine? testLine;
  double foldProgress = 0;
  bool isFolding = false;
  bool? foldValid;

  bool rotActive = false;
  double currentRot = 0;
  bool isRotating = false;
  int rotationsFound = 0;
  bool hasRotatedFar = false;

  bool? resLine;
  bool? resHoriz;
  bool? resRot;

  String msgText = "";
  double msgOpacity = 0.0;
  bool msgIsRed = false;

  void resetPositions() {
    shapeX = 0;
    shapeY = -80;
    dragItem = null;
    testLine = null;
    foldProgress = 0;
    isFolding = false;
    rotActive = false;
    currentRot = 0;
    isRotating = false;
    rotationsFound = 0;
    hasRotatedFar = false;
    resLine = null;
    resHoriz = null;
    resRot = null;
  }
}

// --- MAIN APP WIDGET ---
class Cl6M_Ch9_A6_ClassifyingFiguresbyCombinedSymmetries
    extends StatefulWidget {
  const Cl6M_Ch9_A6_ClassifyingFiguresbyCombinedSymmetries({Key? key})
    : super(key: key);
  @override
  State<Cl6M_Ch9_A6_ClassifyingFiguresbyCombinedSymmetries> createState() =>
      _Cl6M_Ch9_A6_ClassifyingFiguresbyCombinedSymmetriesState();
}

class _Cl6M_Ch9_A6_ClassifyingFiguresbyCombinedSymmetriesState
    extends State<Cl6M_Ch9_A6_ClassifyingFiguresbyCombinedSymmetries>
    with TickerProviderStateMixin {
  // App State
  String _lang = 'en';
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  int _scenario = 1;
  int _step = 0;

  // Tools & Loop
  late AnimationController _gameLoopController;
  late AnimationController _foldAnimController;
  final SimState _sim = SimState();
  final GlobalKey _canvasKey = GlobalKey();

  // Gesture State
  double _baseZoom = 1.0;

  // Shapes Definitions
  late Map<int, ShapeDef> shapes;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initShapes();

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..forward();
    _foldAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _foldAnimController.addListener(() {
      setState(() {
        _sim.foldProgress = _foldAnimController.value;
      });
    });
    _foldAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleFoldCompleted();
      }
    });

    _gameLoopController.addListener(() {
      if (_sim.msgOpacity > 0) {
        setState(() {
          _sim.msgOpacity -= 0.02;
        });
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
    _gameLoopController.dispose();
    _foldAnimController.dispose();

    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  // --- AUDIO METHODS ---
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

  Future<void> curtainScreenSound() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  void _initShapes() {
    shapes = {
      1: ShapeDef(
        // Kite
        pts: const [
          Offset(0, -100),
          Offset(60, 0),
          Offset(0, 120),
          Offset(-60, 0),
        ],
        lines: [
          SymLine(x: 0, y: 10, angle: 0, valid: true),
          SymLine(x: 0, y: 10, angle: pi / 2, valid: false),
        ],
        rotPoints: 1,
        drawExtra: (ctx, path, fill, stroke) {
          fill.color = const Color(0xFF3B82F6);
          ctx.drawPath(
            Path()
              ..moveTo(0, -100)
              ..lineTo(-60, 0)
              ..lineTo(0, 20)
              ..close(),
            fill,
          );
          fill.color = const Color(0xFF60A5FA);
          ctx.drawPath(
            Path()
              ..moveTo(0, -100)
              ..lineTo(60, 0)
              ..lineTo(0, 20)
              ..close(),
            fill,
          );
          fill.color = const Color(0xFF2563EB);
          ctx.drawPath(
            Path()
              ..moveTo(0, 120)
              ..lineTo(-60, 0)
              ..lineTo(0, 20)
              ..close(),
            fill,
          );
          fill.color = const Color(0xFF1D4ED8);
          ctx.drawPath(
            Path()
              ..moveTo(0, 120)
              ..lineTo(60, 0)
              ..lineTo(0, 20)
              ..close(),
            fill,
          );
          stroke.color = const Color(0xFF1E3A8A);
          stroke.strokeWidth = 3;
          ctx.drawLine(const Offset(0, -100), const Offset(0, 120), stroke);
          ctx.drawLine(const Offset(-60, 0), const Offset(60, 0), stroke);
          ctx.drawPath(path, stroke);
        },
      ),
      2: ShapeDef(
        // Parallelogram
        pts: const [
          Offset(-60, -40),
          Offset(40, -40),
          Offset(60, 40),
          Offset(-40, 40),
        ],
        lines: [
          SymLine(x: 0, y: 0, angle: 0, valid: false),
          SymLine(x: 0, y: 0, angle: pi / 2, valid: false),
          SymLine(x: 0, y: 0, angle: 0.6, valid: false),
        ],
        rotPoints: 2,
        drawExtra: (ctx, path, fill, stroke) {
          const depth = 15.0;
          fill.color = const Color(0xFF3B82F6);
          ctx.drawPath(
            Path()
              ..moveTo(60, 40)
              ..lineTo(60, 40 + depth)
              ..lineTo(-40, 40 + depth)
              ..lineTo(-40, 40)
              ..close(),
            fill,
          );
          ctx.drawPath(
            Path()
              ..moveTo(40, -40)
              ..lineTo(40, -40 + depth)
              ..lineTo(60, 40 + depth)
              ..lineTo(60, 40)
              ..close(),
            fill,
          );
          fill.color = const Color(0xFF93C5FD);
          ctx.drawPath(path, fill);
          stroke.color = const Color(0xFF1D4ED8);
          stroke.strokeWidth = 3;
          ctx.drawPath(path, stroke);
          ctx.drawPath(
            Path()
              ..moveTo(-40, 40)
              ..lineTo(-40, 40 + depth)
              ..lineTo(60, 40 + depth)
              ..lineTo(60, 40),
            stroke,
          );
          ctx.drawPath(
            Path()
              ..moveTo(40, -40)
              ..lineTo(40, -40 + depth)
              ..lineTo(60, 40 + depth),
            stroke,
          );
        },
      ),
      3: ShapeDef(
        // Square
        pts: const [
          Offset(-60, -60),
          Offset(60, -60),
          Offset(60, 60),
          Offset(-60, 60),
        ],
        lines: [
          SymLine(x: 0, y: 0, angle: 0, valid: true),
          SymLine(x: 0, y: 0, angle: pi / 2, valid: true),
          SymLine(x: 0, y: 0, angle: pi / 4, valid: true),
          SymLine(x: 0, y: 0, angle: -pi / 4, valid: true),
        ],
        rotPoints: 4,
        drawExtra: (ctx, path, fill, stroke) {
          const depth = 20.0;
          fill.color = const Color(0xFF7C3AED);
          ctx.drawPath(
            Path()
              ..moveTo(60, 60)
              ..lineTo(60, 60 + depth)
              ..lineTo(-60, 60 + depth)
              ..lineTo(-60, 60)
              ..close(),
            fill,
          );
          ctx.drawPath(
            Path()
              ..moveTo(60, -60)
              ..lineTo(60, -60 + depth)
              ..lineTo(60, 60 + depth)
              ..lineTo(60, 60)
              ..close(),
            fill,
          );
          fill.color = const Color(0xFFA78BFA);
          ctx.drawPath(path, fill);
          stroke.color = const Color(0xFF5B21B6);
          stroke.strokeWidth = 3;
          ctx.drawPath(path, stroke);
          ctx.drawPath(
            Path()
              ..moveTo(-60, 60)
              ..lineTo(-60, 60 + depth)
              ..lineTo(60, 60 + depth)
              ..lineTo(60, 60),
            stroke,
          );
          ctx.drawPath(
            Path()
              ..moveTo(60, -60)
              ..lineTo(60, -60 + depth)
              ..lineTo(60, 60 + depth),
            stroke,
          );
        },
      ),
      4: ShapeDef(
        // Hexagon
        pts: List.generate(6, (i) {
          double a = i * pi / 3 - pi / 2;
          return Offset(60 * cos(a), 60 * sin(a));
        }),
        lines: [
          SymLine(x: 0, y: 0, angle: 0, valid: true),
          SymLine(x: 0, y: 0, angle: pi / 3, valid: true),
          SymLine(x: 0, y: 0, angle: 2 * pi / 3, valid: true),
          SymLine(x: 0, y: 0, angle: pi / 2, valid: true),
          SymLine(x: 0, y: 0, angle: pi / 6, valid: true),
          SymLine(x: 0, y: 0, angle: -pi / 6, valid: true),
        ],
        rotPoints: 6,
        drawExtra: (ctx, path, fill, stroke) {
          const depth = 15.0;
          fill.color = const Color(0xFFDB2777);
          stroke.color = const Color(0xFF9D174D);
          stroke.strokeWidth = 3;
          final pts = List.generate(6, (i) {
            double a = i * pi / 3 - pi / 2;
            return Offset(60 * cos(a), 60 * sin(a));
          });
          for (int i = 0; i < 3; i++) {
            var pEdge = Path()
              ..moveTo(pts[i].dx, pts[i].dy)
              ..lineTo(pts[i + 1].dx, pts[i + 1].dy)
              ..lineTo(pts[i + 1].dx, pts[i + 1].dy + depth)
              ..lineTo(pts[i].dx, pts[i].dy + depth)
              ..close();
            ctx.drawPath(pEdge, fill);
            ctx.drawPath(pEdge, stroke);
          }
          fill.color = const Color(0xFFF472B6);
          ctx.drawPath(path, fill);
          ctx.drawPath(path, stroke);
        },
      ),
      5: ShapeDef(
        // Scalene
        pts: const [Offset(-40, 40), Offset(50, 30), Offset(-10, -50)],
        lines: [
          SymLine(x: 0, y: -10, angle: 0.2, valid: false),
          SymLine(x: 0, y: -10, angle: 1.5, valid: false),
        ],
        rotPoints: 1,
        drawExtra: (ctx, path, fill, stroke) {
          const depth = 15.0;
          fill.color = const Color(0xFF16A34A);
          stroke.color = const Color(0xFF166534);
          stroke.strokeWidth = 3;
          final pts = const [Offset(-40, 40), Offset(50, 30), Offset(-10, -50)];
          var pLeft = Path()
            ..moveTo(pts[2].dx, pts[2].dy)
            ..lineTo(pts[0].dx, pts[0].dy)
            ..lineTo(pts[0].dx, pts[0].dy + depth)
            ..lineTo(pts[2].dx, pts[2].dy + depth)
            ..close();
          ctx.drawPath(pLeft, fill);
          ctx.drawPath(pLeft, stroke);
          var pBottom = Path()
            ..moveTo(pts[0].dx, pts[0].dy)
            ..lineTo(pts[1].dx, pts[1].dy)
            ..lineTo(pts[1].dx, pts[1].dy + depth)
            ..lineTo(pts[0].dx, pts[0].dy + depth)
            ..close();
          ctx.drawPath(pBottom, fill);
          ctx.drawPath(pBottom, stroke);
          fill.color = const Color(0xFF4ADE80);
          ctx.drawPath(path, fill);
          ctx.drawPath(path, stroke);
        },
      ),
    };
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _sim.resetPositions();
      _fitToScreen();
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
  }

  bool _isScenarioComplete() {
    int maxSteps = _scenario == 1
        ? 5
        : (_scenario == 2 || _scenario == 3 ? 4 : 2);
    return _step >= maxSteps;
  }

  void _fitToScreen() {
    _sim.zoom = 1.0;
    _sim.panX = 0;
    _sim.panY = 60 * _sim.zoom;
  }

  void _showMessage(String text, bool isRed) {
    setState(() {
      _sim.msgText = text;
      _sim.msgIsRed = isRed;
      _sim.msgOpacity = 1.5;
    });
  }

  // --- GESTURE LOGIC ---
  Offset _screenToWorld(Offset screenPos) {
    final RenderBox renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final dx = (screenPos.dx - size.width / 2 - _sim.panX) / _sim.zoom;
    final dy = (screenPos.dy - size.height / 2 - _sim.panY) / _sim.zoom;
    return Offset(dx, dy);
  }

  bool _hitTestBox(
    double x,
    double y,
    double w,
    double h,
    Offset pt, {
    double padding = 20,
  }) {
    return pt.dx > x - padding &&
        pt.dx < x + w + padding &&
        pt.dy > y - padding &&
        pt.dy < y + h + padding;
  }

  bool _hitTestCircle(
    double cx,
    double cy,
    double r,
    Offset pt, {
    double padding = 20,
  }) {
    double pr = r + padding;
    return (pt.dx - cx) * (pt.dx - cx) + (pt.dy - cy) * (pt.dy - cy) <= pr * pr;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _sim.zoom;
    final pt = _screenToWorld(details.localFocalPoint);

    if (!_sim.isFolding) {
      // Check Tools
      double tx = 200, ty = -280;
      if (_hitTestBox(tx + 20, ty + 55, 60, 50, pt)) {
        playClick();
        setState(() {
          _sim.dragItem = 'fold';
          _sim.dragX = pt.dx;
          _sim.dragY = pt.dy;
        });
        return;
      }
      if (_hitTestBox(tx + 140, ty + 55, 60, 50, pt)) {
        playClick();
        setState(() {
          _sim.dragItem = 'rot';
          _sim.dragX = pt.dx;
          _sim.dragY = pt.dy;
        });
        return;
      }

      // Check Rotation Handle
      if (_sim.rotActive) {
        double rx = _sim.shapeX + 80 * sin(_sim.currentRot);
        double ry = _sim.shapeY - 80 * cos(_sim.currentRot);
        if (_hitTestCircle(rx, ry, 30, pt)) {
          playClick();
          setState(() {
            _sim.isRotating = true;
            _sim.hasRotatedFar = false;
          });
          return;
        }
      }

      // Check Shape Dragging
      bool canDragShape = false;
      if (_scenario == 1 && _step == 4) canDragShape = true;
      if (_scenario == 2 && _step == 3) canDragShape = true;
      if (_scenario == 3 && _step == 3) canDragShape = true;
      if (_scenario >= 4 &&
          _step == 1 &&
          _sim.resLine != null &&
          _sim.resRot != null)
        canDragShape = true;

      if (canDragShape &&
          _hitTestBox(_sim.shapeX - 70, _sim.shapeY - 100, 140, 200, pt)) {
        playClick();
        setState(() {
          _sim.dragItem = 'shape';
          _sim.dragX = pt.dx;
          _sim.dragY = pt.dy;
        });
        return;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final pt = _screenToWorld(details.localFocalPoint);

    if (_sim.dragItem != null) {
      setState(() {
        _sim.dragX = pt.dx;
        _sim.dragY = pt.dy;
      });

      if (_sim.dragItem == 'fold') {
        ShapeDef activeShape = shapes[_scenario]!;
        SymLine? closest;
        double minDist = 80;
        for (var l in activeShape.lines) {
          double dx = pt.dx - _sim.shapeX - l.x;
          double dy = pt.dy - _sim.shapeY - l.y;
          double d = (dx * cos(l.angle) - dy * sin(l.angle)).abs();
          if (d < minDist) {
            minDist = d;
            closest = l;
          }
        }
        setState(() {
          _sim.testLine = closest;
        });
      }
      return;
    }

    if (_sim.isRotating) {
      double dx = pt.dx - _sim.shapeX;
      double dy = pt.dy - _sim.shapeY;
      double ang = atan2(dy, dx) + pi / 2;

      double angDeg = (ang * 180 / pi) % 360;
      if (angDeg < 0) angDeg += 360;

      if ((angDeg).abs() > 45 && (angDeg - 360).abs() > 45) {
        _sim.hasRotatedFar = true;
      }

      ShapeDef activeShape = shapes[_scenario]!;
      List<double> targetAngs = [];
      for (int i = 1; i <= activeShape.rotPoints; i++) {
        targetAngs.add(i * 360 / activeShape.rotPoints);
      }

      bool snapped = false;
      for (var ta in targetAngs) {
        double d = (angDeg - ta).abs();
        if (d > 180) d = 360 - d;
        if (d < 10) {
          ang = ta * pi / 180;
          snapped = true;
        }
      }

      if (snapped && ang != _sim.currentRot) {
        playClick();
        _sim.rotationsFound++;
      }

      setState(() {
        _sim.currentRot = ang;
      });
      return;
    }

    // Camera Pan/Zoom with smooth adjustment
    setState(() {
      _sim.panX += details.focalPointDelta.dx;
      _sim.panY += details.focalPointDelta.dy;
      if (details.scale != 1.0) {
        _sim.zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_sim.isRotating) {
      setState(() {
        _sim.isRotating = false;
      });
      ShapeDef activeShape = shapes[_scenario]!;
      double angDeg = (_sim.currentRot * 180 / pi) % 360;
      if (angDeg < 0) angDeg += 360;

      bool fullCircle =
          _sim.hasRotatedFar &&
          ((angDeg - 360).abs() < 15 || angDeg.abs() < 15);

      if (fullCircle) {
        playPageOpen();
        setState(() {
          _sim.currentRot = 0;
          _sim.resRot = activeShape.rotPoints > 1;
        });
        if (_scenario == 1 && _step == 3) _advanceStep();
        if (_scenario == 2 && _step == 2) _advanceStep();
        if (_scenario == 3 && _step == 2) _advanceStep();
        if (_scenario >= 4 &&
            _sim.resLine != null &&
            _sim.resRot != null &&
            _step == 0)
          _advanceStep();
      }
      return;
    }

    if (_sim.dragItem == 'fold') {
      if (_sim.testLine != null) {
        setState(() {
          _sim.isFolding = true;
          _sim.foldValid = _sim.testLine!.valid;
          _sim.foldProgress = 0;
        });
        _foldAnimController.forward(from: 0.0);
      }
      setState(() {
        _sim.dragItem = null;
      });
      return;
    }

    if (_sim.dragItem == 'rot') {
      if (_hitTestBox(
        _sim.shapeX - 60,
        _sim.shapeY - 100,
        120,
        200,
        Offset(_sim.dragX, _sim.dragY),
        padding: 0,
      )) {
        playPageOpen();
        setState(() {
          _sim.rotActive = true;
          _sim.rotationsFound = 0;
          _sim.currentRot = 0;
          _sim.hasRotatedFar = false;
        });
        if (_scenario == 1 && _step == 2) _advanceStep();
        if (_scenario == 2 && _step == 1) _advanceStep();
        if (_scenario == 3 && _step == 1) _advanceStep();
      }
      setState(() {
        _sim.dragItem = null;
      });
      return;
    }

    if (_sim.dragItem == 'shape') {
      ShapeDef activeShape = shapes[_scenario]!;
      int targetQuad = 0;
      if (activeShape.lines.any((l) => l.valid) && activeShape.rotPoints > 1) {
        targetQuad = 3;
      } else if (activeShape.lines.any((l) => l.valid)) {
        targetQuad = 1;
      } else if (activeShape.rotPoints > 1) {
        targetQuad = 2;
      } else {
        targetQuad = 4;
      }

      int droppedQuad = 0;
      Offset pt = Offset(_sim.dragX, _sim.dragY);
      if (_hitTestBox(-300, 100, 300, 70, pt, padding: 0))
        droppedQuad = 1;
      else if (_hitTestBox(0, 100, 300, 70, pt, padding: 0))
        droppedQuad = 2;
      else if (_hitTestBox(-350, 170, 350, 70, pt, padding: 0))
        droppedQuad = 3;
      else if (_hitTestBox(0, 170, 350, 70, pt, padding: 0))
        droppedQuad = 4;

      if (droppedQuad == targetQuad) {
        playPageOpen();
        setState(() {
          if (droppedQuad == 1) {
            _sim.shapeX = -150;
            _sim.shapeY = 220;
          }
          if (droppedQuad == 2) {
            _sim.shapeX = 150;
            _sim.shapeY = 220;
          }
          if (droppedQuad == 3) {
            _sim.shapeX = -150;
            _sim.shapeY = 270;
          }
          if (droppedQuad == 4) {
            _sim.shapeX = 150;
            _sim.shapeY = 270;
          }
          _sim.dragItem = null;
        });
        _advanceStep();
      } else {
        playError();
        _showMessage(I18n.t('lbl_fail', _lang), true);
        setState(() {
          _sim.shapeX = 0;
          _sim.shapeY = -80;
          _sim.dragItem = null;
        });
      }
      return;
    }
  }

  void _handleFoldCompleted() {
    SymLine testedLine = _sim.testLine!;
    if (_scenario == 1) {
      if (_step == 0) {
        if (testedLine.angle == 0) {
          playPageOpen();
          setState(() {
            _sim.resLine = _sim.foldValid;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            setState(() {
              _sim.isFolding = false;
              _sim.testLine = null;
            });
            _advanceStep();
          });
        } else {
          playError();
          _showMessage(I18n.t('msg_test_vertical', _lang), true);
          setState(() {
            _sim.isFolding = false;
            _sim.testLine = null;
          });
        }
      } else if (_step == 1) {
        if (testedLine.angle.abs() > 0) {
          playPageOpen();
          setState(() {
            _sim.resHoriz = _sim.foldValid;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            setState(() {
              _sim.isFolding = false;
              _sim.testLine = null;
            });
            _advanceStep();
          });
        } else {
          playError();
          _showMessage(I18n.t('msg_test_horizontal', _lang), true);
          setState(() {
            _sim.isFolding = false;
            _sim.testLine = null;
          });
        }
      }
    } else {
      if (_sim.foldValid!) {
        playPageOpen();
      } else {
        playError();
      }
      setState(() {
        _sim.resLine = _sim.foldValid;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _sim.isFolding = false;
          _sim.testLine = null;
        });
        if (_scenario == 2 && _step == 0)
          _advanceStep();
        else if (_scenario == 3 && _step == 0 && _sim.foldValid!)
          _advanceStep();
        else if (_scenario >= 4 &&
            _sim.resLine != null &&
            _sim.resRot != null &&
            _step == 0)
          _advanceStep();
      });
    }
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) =>
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRect(
                child: GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        key: _canvasKey,
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: SymmetryPainter(
                          state: _sim,
                          scenario: _scenario,
                          step: _step,
                          lang: _lang,
                          shapes: shapes,
                          repaint: _gameLoopController,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Sidebar Resizer & Border
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              width: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  if (_sidebarOpen) {
                    setState(() {
                      _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(
                        300.0,
                        MediaQuery.of(context).size.width * 0.6,
                      );
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    color: Colors.transparent,
                  ),
                  child: Center(
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

            // Left Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                color: zslSidebar,
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
                              // Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  60,
                                  16,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.extension,
                                          color: zslIndigo,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            I18n.t('appTitle', _lang),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      I18n.t('appSubtitle', _lang),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withOpacity(0.1),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.language,
                                            size: 16,
                                          ),
                                          label: Text(_lang.toUpperCase()),
                                          onPressed: () {
                                            playClick();
                                            setState(() {
                                              _lang = _lang == 'en'
                                                  ? 'hi'
                                                  : 'en';
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent
                                                .withOpacity(0.2),
                                            foregroundColor: Colors.redAccent,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 16,
                                          ),
                                          label: const Text("Reset"),
                                          onPressed: () {
                                            playClick();
                                            _loadScenario(1);
                                            _showCurtain = true;
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.white.withOpacity(0.1),
                                height: 1,
                              ),
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      I18n.t(
                                        'selectScenario',
                                        _lang,
                                      ).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: zslDark,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _scenario,
                                          isExpanded: true,
                                          dropdownColor: zslDark,
                                          items: [1, 2, 3, 4, 5]
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(
                                                    I18n.t(
                                                      's${e}_title',
                                                      _lang,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
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
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.track_changes,
                                                color: zslRose,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                I18n.t('learnLbl', _lang),
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
                                            I18n.t('s${_scenario}_obj', _lang),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ..._buildSteps(),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Footer
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                alignment: Alignment.center,
                                color: zslDark,
                                child: const Text(
                                  '© ZeroScienceLab - Fall in love with math and Science',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
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

            // Floating Menu Toggle Button
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    playClick();
                    setState(() {
                      _sidebarOpen = !_sidebarOpen;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: zslSidebar,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _sidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // HUD Bottom Center
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              bottom: 14,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: (_step < _getStepCount() && !_isScenarioComplete())
                        ? 1.0
                        : 0.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: zslDark.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
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
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: zslIndigo.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              _step < _getStepCount()
                                  ? I18n.t(
                                      's${_scenario}_hud${_step + 1}',
                                      _lang,
                                    )
                                  : "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Final Success Popup
            if (_isScenarioComplete())
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: zslSidebar,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: zslEmerald,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: zslEmerald.withOpacity(0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flag,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            I18n.t('summaryTitle', _lang),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Concept Mastered!",
                            style: TextStyle(
                              fontSize: 18,
                              color: zslEmerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _scenario < 5
                                  ? zslIndigo
                                  : zslAmber,
                              foregroundColor: Colors.white,
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
                            ),
                            label: Text(
                              I18n.t(
                                _scenario < 5 ? 'nextScenario' : 'finishLab',
                                _lang,
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              playPageOpen();
                              if (_scenario < 5) {
                                _loadScenario(_scenario + 1);
                              } else {
                                _loadScenario(1);
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
                  color: zslDark,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: zslIndigo.withOpacity(0.6),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.change_history,
                              size: 80,
                              color: zslIndigo,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              I18n.t('shutterTitle', _lang),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            I18n.t('appSubtitle', _lang),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: zslIndigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              elevation: 10,
                            ),
                            icon: const Icon(Icons.play_circle_fill, size: 28),
                            label: Text(
                              I18n.t('enterLab', _lang),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              curtainScreenSound();
                              setState(() => _showCurtain = false);
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

  int _getStepCount() {
    if (_scenario == 1) return 5;
    if (_scenario == 2) return 4;
    if (_scenario == 3) return 4;
    if (_scenario == 4) return 2;
    if (_scenario == 5) return 2;
    return 0;
  }

  List<Widget> _buildSteps() {
    int maxSteps = _getStepCount();
    List<Widget> list = [];
    for (int i = 0; i < maxSteps; i++) {
      bool isCompleted = i < _step;
      bool isActive = i == _step;
      bool isFuture = i > _step;

      Color bgColor = isActive
          ? zslIndigo.withOpacity(0.1)
          : (isCompleted
                ? zslEmerald.withOpacity(0.1)
                : Colors.white.withOpacity(0.05));
      Color borderColor = isActive
          ? zslIndigo.withOpacity(0.5)
          : (isCompleted
                ? zslEmerald.withOpacity(0.3)
                : Colors.white.withOpacity(0.1));

      list.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: isActive
                ? [BoxShadow(color: zslIndigo.withOpacity(0.2), blurRadius: 8)]
                : [],
          ),
          child: Opacity(
            opacity: isFuture ? 0.5 : 1.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCompleted)
                  const Icon(Icons.check_circle, color: zslEmerald)
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isActive
                          ? zslIndigo
                          : Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        '${I18n.t('stepLabel', _lang)} ${i + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        I18n.t('s${_scenario}_step${i + 1}_task', _lang),
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white70,
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: zslEmerald.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            I18n.t('s${_scenario}_step${i + 1}_out', _lang),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
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
        ),
      );
    }
    return list;
  }
}

// --- CANVAS PAINTER ---
class SymmetryPainter extends CustomPainter {
  final SimState state;
  final int scenario;
  final int step;
  final String lang;
  final Map<int, ShapeDef> shapes;

  SymmetryPainter({
    required this.state,
    required this.scenario,
    required this.step,
    required this.lang,
    required this.shapes,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Center to middle of screen, apply pan and zoom
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    _drawClassroomBackground(canvas);
    _drawPanels(canvas);
    _drawMat(canvas);

    ShapeDef activeShape = shapes[scenario]!;

    // Test Lines
    if (state.dragItem != 'shape' &&
        state.shapeY <= 0 &&
        !state.isRotating &&
        !state.rotActive) {
      for (var l in activeShape.lines) {
        canvas.save();
        canvas.translate(l.x, l.y);
        canvas.rotate(l.angle);
        _drawDashedLine(
          canvas,
          const Offset(0, -140),
          const Offset(0, 140),
          Colors.white.withOpacity(0.4),
          2,
        );
        if (state.testLine == l && !state.isRotating) {
          _drawDashedLine(
            canvas,
            const Offset(0, -140),
            const Offset(0, 140),
            Colors.yellow,
            4,
          );
        }
        canvas.restore();
      }
    }

    // Active Shape Logic
    canvas.save();
    double wx = state.dragItem == 'shape' ? state.dragX : state.shapeX;
    double wy = state.dragItem == 'shape' ? state.dragY : state.shapeY;
    canvas.translate(wx, wy);

    if (state.dragItem != 'shape' && state.shapeY > 200) {
      canvas.scale(0.5, 0.5); // Shrink on mat
    }

    if (state.isRotating) {
      // Ghost
      canvas.save();
      canvas.translate(0, 10);
      var p1 = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      var p2 = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      activeShape.drawExtra(canvas, activeShape.path, p1, p2);
      canvas.restore();

      // Rotated Shape
      canvas.rotate(state.currentRot);
      bool snapGlow = false;
      double angDeg = (state.currentRot * 180 / pi) % 360;
      if (angDeg < 0) angDeg += 360;
      for (int i = 1; i <= activeShape.rotPoints; i++) {
        double ta = i * 360 / activeShape.rotPoints;
        if ((angDeg - ta).abs() < 2 || (angDeg - (ta - 360)).abs() < 2)
          snapGlow = true;
      }

      var fill = Paint()..style = PaintingStyle.fill;
      var stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      if (snapGlow) {
        canvas.drawPath(
          activeShape.path,
          Paint()
            ..color = Colors.green
            ..style = PaintingStyle.stroke
            ..strokeWidth = 15
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
      activeShape.drawExtra(canvas, activeShape.path, fill, stroke);
    } else if (state.isFolding && state.testLine != null) {
      double cx = state.testLine!.x;
      double cy = state.testLine!.y;
      double theta = state.testLine!.angle;

      var fill = Paint()..style = PaintingStyle.fill;
      var stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      // Left half stationary
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(theta);
      canvas.clipRect(const Rect.fromLTRB(-1000, -1000, 0, 1000));
      canvas.rotate(-theta);
      canvas.translate(-cx, -cy);
      activeShape.drawExtra(canvas, activeShape.path, fill, stroke);
      canvas.restore();

      // Gray Back half
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(theta);
      canvas.clipRect(const Rect.fromLTRB(-1000, -1000, 0, 1000));
      double sc = cos(state.foldProgress * pi);
      canvas.scale(sc, 1);
      canvas.rotate(-theta);
      canvas.translate(-cx, -cy);
      canvas.drawPath(
        activeShape.path,
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        activeShape.path,
        Paint()
          ..color = const Color(0xFF475569)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.restore();

      // Right half folding
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(theta);
      canvas.clipRect(const Rect.fromLTRB(0, -1000, 1000, 1000));
      canvas.scale(sc, 1);
      canvas.rotate(-theta);
      canvas.translate(-cx, -cy);
      activeShape.drawExtra(canvas, activeShape.path, fill, stroke);
      canvas.restore();

      if (state.foldProgress == 1) {
        canvas.drawPath(
          activeShape.path,
          Paint()
            ..color = state.foldValid! ? Colors.green : Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 15
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
        );
        activeShape.drawExtra(canvas, activeShape.path, fill, stroke);
      }
    } else {
      Color? glowColor;
      if (scenario == 1) {
        if (step == 2 && state.resLine == true)
          glowColor = Colors.green;
        else if (step == 3 && state.resHoriz == false)
          glowColor = Colors.red;
        else if (step == 5 && state.resRot == false)
          glowColor = Colors.red;
      } else {
        if (state.resLine == true && !state.rotActive)
          glowColor = Colors.green;
        else if (state.resLine == false && !state.rotActive)
          glowColor = Colors.red;
      }

      var fill = Paint()..style = PaintingStyle.fill;
      var stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      if (glowColor != null) {
        canvas.drawPath(
          activeShape.path,
          Paint()
            ..color = glowColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 20
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
        );
      }
      activeShape.drawExtra(canvas, activeShape.path, fill, stroke);
    }

    // Rotation Handle
    if (state.rotActive && !state.isFolding) {
      canvas.drawCircle(
        Offset.zero,
        80,
        Paint()
          ..color = zslIndigo
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.save();
      canvas.rotate(state.currentRot);
      canvas.drawCircle(
        const Offset(0, -80),
        15,
        Paint()
          ..color = zslLight
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        const Offset(0, -80),
        15,
        Paint()
          ..color = zslIndigo
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        const Offset(0, -80),
        8,
        Paint()
          ..color = zslIndigo
          ..style = PaintingStyle.fill,
      );
      canvas.restore();

      if (state.isRotating || state.rotationsFound > 0) {
        _drawText(
          canvas,
          'Matches: ${state.rotationsFound}',
          const Offset(0, 130),
          14,
          Colors.white,
          bg: zslDark,
        );
      }
    }

    canvas.restore(); // Shape Transform

    // Draw Dragged Tools
    if (state.dragItem == 'fold')
      _drawIcon(canvas, 'fold', Offset(state.dragX, state.dragY));
    if (state.dragItem == 'rot')
      _drawIcon(canvas, 'rot', Offset(state.dragX, state.dragY));

    // Messages
    if (state.msgOpacity > 0) {
      int alpha = (state.msgOpacity.clamp(0.0, 1.0) * 255).toInt();
      Color bg = state.msgIsRed
          ? const Color(0xFFFECACA).withAlpha(alpha)
          : const Color(0xFFBBF7D0).withAlpha(alpha);
      Color fg = state.msgIsRed
          ? const Color(0xFFB91C1C).withAlpha(alpha)
          : const Color(0xFF166534).withAlpha(alpha);
      _drawRoundedRect(
        canvas,
        const Rect.fromLTRB(-130, 180, 130, 220),
        8,
        bg,
        fg,
      );
      _drawText(canvas, state.msgText, const Offset(0, 200), 14, fg);
    }

    canvas.restore();
  }

  void _drawClassroomBackground(Canvas canvas) {
    // Wall
    canvas.drawRect(
      const Rect.fromLTRB(-1500, -1000, 1500, 100),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Pegboards
    _drawRoundedRect(
      canvas,
      const Rect.fromLTRB(-400, -250, -200, -130),
      8,
      const Color(0xFF334155),
      Colors.transparent,
    );
    _drawRoundedRect(
      canvas,
      const Rect.fromLTRB(200, -250, 400, -130),
      8,
      const Color(0xFF334155),
      Colors.transparent,
    );

    var dotPaint = Paint()..color = zslDark;
    for (double i = -380; i < -200; i += 20) {
      for (double j = -230; j < -130; j += 20) {
        canvas.drawCircle(Offset(i, j), 2, dotPaint);
      }
    }
    for (double i = 220; i < 400; i += 20) {
      for (double j = -230; j < -130; j += 20) {
        canvas.drawCircle(Offset(i, j), 2, dotPaint);
      }
    }

    // Floor
    canvas.drawRect(
      const Rect.fromLTRB(-1500, 100, 1500, 1000),
      Paint()..color = zslDark,
    );

    // Whiteboard
    _drawRoundedRect(
      canvas,
      const Rect.fromLTRB(-200, -300, 200, -120),
      8,
      const Color(0xFF020617),
      const Color(0xFFD97706),
    );

    // Wooden Table Top
    var tPath = Path()
      ..moveTo(-500, 60)
      ..lineTo(500, 60)
      ..lineTo(600, 240)
      ..lineTo(-600, 240)
      ..close();
    canvas.drawPath(tPath, Paint()..color = const Color(0xFF92400E));
    canvas.drawPath(
      tPath,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Table Edge
    var ePath = Path()
      ..moveTo(-600, 240)
      ..lineTo(600, 240)
      ..lineTo(600, 260)
      ..lineTo(-600, 260)
      ..close();
    canvas.drawPath(ePath, Paint()..color = const Color(0xFF78350F));
    canvas.drawPath(
      ePath,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Legs
    canvas.drawRect(
      const Rect.fromLTRB(-500, 260, -470, 460),
      Paint()..color = const Color(0xFF451A03),
    );
    canvas.drawRect(
      const Rect.fromLTRB(470, 260, 500, 460),
      Paint()..color = const Color(0xFF451A03),
    );
  }

  void _drawPanels(Canvas canvas) {
    // Results Panel
    double rx = -580, ry = -280, rw = 380, rh = (scenario == 1) ? 210 : 160;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(rx, ry, rw, rh),
      10,
      const Color(0xFF1E293B),
      const Color(0xFF475569),
    );
    _drawText(
      canvas,
      I18n.t('lbl_results', lang),
      Offset(rx + 15, ry + 25),
      16,
      Colors.white,
      align: TextAlign.left,
    );
    canvas.drawLine(
      Offset(rx, ry + 40),
      Offset(rx + rw, ry + 40),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 2,
    );

    double rowY = ry + 70;
    if (state.resLine != null)
      _drawIcon(
        canvas,
        state.resLine! ? 'check' : 'cross',
        Offset(rx + 25, rowY - 2),
      );
    _drawText(
      canvas,
      I18n.t('lbl_line_sym', lang),
      Offset(rx + 45, rowY),
      16,
      const Color(0xFFCBD5E1),
      align: TextAlign.left,
    );
    rowY += 50;

    if (scenario == 1) {
      if (state.resHoriz != null)
        _drawIcon(
          canvas,
          state.resHoriz! ? 'check' : 'cross',
          Offset(rx + 25, rowY - 2),
        );
      _drawText(
        canvas,
        I18n.t('lbl_horiz_sym', lang),
        Offset(rx + 45, rowY),
        16,
        const Color(0xFFCBD5E1),
        align: TextAlign.left,
      );
      rowY += 50;
    }

    if (state.resRot != null)
      _drawIcon(
        canvas,
        state.resRot! ? 'check' : 'cross',
        Offset(rx + 25, rowY - 2),
      );
    _drawText(
      canvas,
      I18n.t('lbl_rot_sym', lang),
      Offset(rx + 45, rowY),
      16,
      const Color(0xFFCBD5E1),
      align: TextAlign.left,
    );

    // Tools Panel
    double tx = 200, ty = -280, tw = 220, th = 140;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(tx, ty, tw, th),
      10,
      const Color(0xFF1E293B),
      const Color(0xFF475569),
    );
    _drawText(
      canvas,
      I18n.t('lbl_tools', lang),
      Offset(tx + tw / 2, ty + 25),
      16,
      Colors.white,
    );
    canvas.drawLine(
      Offset(tx, ty + 40),
      Offset(tx + tw, ty + 40),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 2,
    );

    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(tx + 20, ty + 55, 60, 50),
      8,
      const Color(0xFF334155),
      const Color(0xFF475569),
    );
    _drawIcon(canvas, 'fold', Offset(tx + 50, ty + 80));
    _drawText(
      canvas,
      I18n.t('lbl_fold_tool', lang),
      Offset(tx + 50, ty + 120),
      12,
      const Color(0xFFCBD5E1),
    );

    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(tx + 140, ty + 55, 60, 50),
      8,
      const Color(0xFF334155),
      const Color(0xFF475569),
    );
    _drawIcon(canvas, 'rot', Offset(tx + 170, ty + 80));
    _drawText(
      canvas,
      I18n.t('lbl_rot_tool', lang),
      Offset(tx + 170, ty + 120),
      12,
      const Color(0xFFCBD5E1),
    );
  }

  void _drawMat(Canvas canvas) {
    bool showMat = false;
    if (scenario == 1 && step >= 4) showMat = true;
    if (scenario == 2 && step >= 3) showMat = true;
    if (scenario == 3 && step >= 3) showMat = true;
    if (scenario == 4 &&
        step >= 1 &&
        state.resLine != null &&
        state.resRot != null)
      showMat = true;
    if (scenario == 5 &&
        step >= 1 &&
        state.resLine != null &&
        state.resRot != null)
      showMat = true;

    if (!showMat) return;

    canvas.save();
    canvas.translate(0, 160);

    Offset tl = const Offset(-250, -60), tr = const Offset(250, -60);
    Offset bl = const Offset(-350, 80), br = const Offset(350, 80);
    Offset tm = const Offset(0, -60), bm = const Offset(0, 80);
    Offset ml = const Offset(-300, 10), mr = const Offset(300, 10);

    var bgPaint = Paint()..color = zslDark;
    var linePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    var matPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();
    canvas.drawPath(matPath, bgPaint);
    canvas.drawPath(matPath, linePaint);
    canvas.drawLine(tm, bm, linePaint);
    canvas.drawLine(ml, mr, linePaint);

    // Removed the target drop quadrant highlighting feature here to hide the visual hints

    _drawText(
      canvas,
      I18n.t('lbl_mat_line', lang),
      const Offset(-130, -30),
      16,
      const Color(0xFF94A3B8),
    );
    _drawText(
      canvas,
      I18n.t('lbl_mat_rot', lang),
      const Offset(130, -30),
      16,
      const Color(0xFF94A3B8),
    );
    _drawText(
      canvas,
      I18n.t('lbl_mat_both', lang),
      const Offset(-150, 40),
      16,
      const Color(0xFF94A3B8),
    );
    _drawText(
      canvas,
      I18n.t('lbl_mat_none', lang),
      const Offset(150, 40),
      16,
      const Color(0xFF94A3B8),
    );

    canvas.restore();
  }

  void _drawRoundedRect(
    Canvas canvas,
    Rect rect,
    double r,
    Color fill,
    Color stroke,
  ) {
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(r)),
        Paint()..color = fill,
      );
    }
    if (stroke != Colors.transparent) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(r)),
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double width,
  ) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = width;
    var path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);
    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < measurePath.length) {
        double len = 8;
        if (draw) {
          canvas.drawPath(
            measurePath.extractPath(distance, distance + len),
            paint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    double size,
    Color color, {
    TextAlign align = TextAlign.center,
    Color? bg,
  }) {
    if (bg != null) {
      TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: bg,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: align,
        )
        ..layout()
        ..paint(
          canvas,
          Offset(
            pos.dx - (align == TextAlign.center ? 0 : 0) + 1,
            pos.dy - size / 2 + 1,
          ),
        );
    }
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();

    double dx = pos.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  void _drawIcon(Canvas canvas, String type, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(1.5, 1.5);
    if (type == 'fold') {
      canvas.drawPath(
        Path()
          ..moveTo(-8, -10)
          ..lineTo(2, -10)
          ..lineTo(8, -4)
          ..lineTo(8, 10)
          ..lineTo(-8, 10)
          ..close(),
        Paint()..color = zslIndigo,
      );
      canvas.drawPath(
        Path()
          ..moveTo(1, -10)
          ..lineTo(1, -3)
          ..lineTo(8, -3)
          ..close(),
        Paint()..color = zslLight,
      );
      canvas.drawPath(
        Path()
          ..moveTo(0, -10)
          ..lineTo(0, 9.9)
          ..lineTo(-7.8, 8)
          ..lineTo(-8, -10)
          ..close(),
        Paint()..color = const Color(0xFF4F46E5),
      );
    } else if (type == 'rot') {
      canvas.drawCircle(Offset.zero, 8, Paint()..color = zslIndigo);
      canvas.drawCircle(Offset.zero, 5, Paint()..color = zslLight);
      canvas.drawPath(
        Path()
          ..moveTo(5, -2)
          ..lineTo(9, -2)
          ..lineTo(7, 2)
          ..close(),
        Paint()..color = zslIndigo,
      );
      canvas.drawPath(
        Path()
          ..moveTo(-5, 2)
          ..lineTo(-9, 2)
          ..lineTo(-7, -2)
          ..close(),
        Paint()..color = zslIndigo,
      );
    } else if (type == 'check') {
      canvas.drawCircle(Offset.zero, 8, Paint()..color = Colors.green);
      canvas.drawPath(
        Path()
          ..moveTo(-3, 0)
          ..lineTo(-1, 3)
          ..lineTo(4, -3),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else if (type == 'cross') {
      canvas.drawCircle(Offset.zero, 8, Paint()..color = Colors.red);
      canvas.drawPath(
        Path()
          ..moveTo(-3, -3)
          ..lineTo(3, 3)
          ..moveTo(3, -3)
          ..lineTo(-3, 3),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SymmetryPainter oldDelegate) => true;
}
