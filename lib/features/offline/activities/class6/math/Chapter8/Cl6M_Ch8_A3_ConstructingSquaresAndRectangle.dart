// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Cl6M_Ch8_A3_ConstructingSquaresAndRectangle());
}

// --- TRANSLATIONS DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'title': 'Constructing Squares and Rectangles',
    'subtitle': 'Class 6 • GEOMETRIC CONSTRUCTION',
    'enterBtn': 'Enter Simulation',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'learnLbl': 'Observations:',
    'nextScenario': 'Next Scenario',
    'finishLab': 'Finish Lab',
    'goalTitle': 'Goal Reached!',
    'goalDesc': 'You have successfully constructed perfect geometric shapes!',

    // Scenarios
    's1_title': '1. Building a Perfect Square',
    's1_obj':
        'To learn the fundamental steps of constructing a square of a given side length (6 cm) using a virtual ruler and protractor.',
    's1_step1_task':
        'Select the Pencil. DRAW a 6 cm line segment from P to Q along the guide.',
    's1_step1_out': 'The base of your square, PQ (6cm), is drawn.',
    's1_step2_task':
        'Select the Protractor. SNAP its center point onto point P.',
    's1_step2_out': 'The protractor is positioned to measure 90° at P.',
    's1_step3_task':
        'Select the Pencil. DRAW a perpendicular line starting from P, ending at the 6cm mark S.',
    's1_step3_out': 'A 6cm perpendicular line PS is drawn at 90°.',
    's1_step4_task':
        'Select the Protractor. SNAP its center point onto point Q.',
    's1_step4_out': 'The protractor is positioned to measure 90° at Q.',
    's1_step5_task':
        'Select the Pencil. DRAW a perpendicular line starting from Q, ending at the 6cm mark R.',
    's1_step5_out': 'A 6cm perpendicular line QR is drawn at 90°.',
    's1_step6_task': 'Select the Pencil. CONNECT point S to point R.',
    's1_step6_out': 'The final side is drawn. The square PQRS is complete!',

    's2_title': '2. Framing a Rectangular Picture',
    's2_obj':
        'To construct a rectangle with sides of different lengths (6 cm and 4 cm).',
    's2_step1_task': 'Select Pencil. DRAW a 6 cm line segment from A to B.',
    's2_step1_out': 'The base AB (6cm) is drawn.',
    's2_step2_task': 'Select Protractor. SNAP its center onto point A.',
    's2_step2_out': 'Protractor is ready at A.',
    's2_step3_task':
        'Select Pencil. DRAW a 4 cm perpendicular line from A to D.',
    's2_step3_out': 'The 4cm side AD is drawn at 90°.',
    's2_step4_task': 'Select Protractor. SNAP its center onto point B.',
    's2_step4_out': 'Protractor is ready at B.',
    's2_step5_task':
        'Select Pencil. DRAW a 4 cm perpendicular line from B to C.',
    's2_step5_out': 'The 4cm side BC is drawn at 90°.',
    's2_step6_task': 'Select Pencil. CONNECT point D to point C.',
    's2_step6_out': 'The rectangle ABCD (6x4) is complete!',

    's3_title': '3. The Compass Method for a Square',
    's3_obj':
        'To construct a 5 cm square using a ruler and compass to measure and transfer lengths.',
    's3_step1_task': 'Select Pencil. DRAW a 5 cm line segment from P to Q.',
    's3_step1_out': 'The base PQ (5cm) is drawn.',
    's3_step2_task': 'Select Protractor. SNAP its center to P.',
    's3_step2_out': 'Protractor ready for 90° at P.',
    's3_step3_task':
        'Select Pencil. DRAW a long perpendicular line from P upwards.',
    's3_step3_out': 'A perpendicular guide line is drawn.',
    's3_step4_task':
        'Select Compass. DRAG the pencil point to the 5cm mark to set its width.',
    's3_step4_out': 'The compass is set to a 5cm radius.',
    's3_step5_task':
        'Snap Compass to P. DRAG its pencil to DRAW an arc across the vertical line.',
    's3_step5_out': 'Arc marks point S at exactly 5cm from P.',
    's3_step6_task':
        'Snap Compass to Q. DRAG its pencil to DRAW an arc above Q.',
    's3_step6_out': 'An arc of 5cm radius is drawn from Q.',
    's3_step7_task':
        'Snap Compass to S. DRAG its pencil to DRAW an arc to intersect the previous one.',
    's3_step7_out': 'Arcs intersect at R, which is 5cm from S and Q.',
    's3_step8_task': 'Select Pencil. CONNECT Q to R, and S to R.',
    's3_step8_out': 'The square PQRS is complete using the compass method!',

    's4_title': '4. Construct: The Garden Plot',
    's4_obj':
        'Construct a 10 cm by 5 cm rectangular garden plot using the ruler and protractor.',
    's4_step1_task': 'Select Pencil. DRAW a 10 cm base line from A to B.',
    's4_step1_out': '10 cm base AB drawn.',
    's4_step2_task': 'Select Protractor. SNAP to point A.',
    's4_step2_out': 'Protractor set at A.',
    's4_step3_task': 'Select Pencil. DRAW a 5 cm perpendicular line to D.',
    's4_step3_out': '5 cm side AD drawn.',
    's4_step4_task': 'Select Protractor. SNAP to point B.',
    's4_step4_out': 'Protractor set at B.',
    's4_step5_task': 'Select Pencil. DRAW a 5 cm perpendicular line to C.',
    's4_step5_out': '5 cm side BC drawn.',
    's4_step6_task': 'Select Pencil. CONNECT D to C.',
    's4_step6_out': 'Garden Plot (10x5) is complete!',

    's5_title': '5. Construct: The Tilted Tile',
    's5_obj': 'Construct a 7 cm square that is tilted at an angle.',
    's5_step1_task':
        'Select Pencil. DRAW a 7 cm tilted line from A to B along the guide.',
    's5_step1_out': 'Tilted base AB drawn.',
    's5_step2_task': 'Select Protractor. SNAP to point A.',
    's5_step2_out': 'Protractor set at tilted angle at A.',
    's5_step3_task': 'Select Pencil. DRAW a 7 cm perpendicular line to D.',
    's5_step3_out': 'Tilted side AD drawn.',
    's5_step4_task': 'Select Protractor. SNAP to point B.',
    's5_step4_out': 'Protractor set at B.',
    's5_step5_task': 'Select Pencil. DRAW a 7 cm perpendicular line to C.',
    's5_step5_out': 'Tilted side BC drawn.',
    's5_step6_task': 'Select Pencil. CONNECT D to C.',
    's5_step6_out': 'The Tilted Tile is perfectly constructed!',
  },
  'hi': {
    'title': 'वर्ग और आयत बनाना',
    'subtitle': 'कक्षा 6 • ज्यामितीय रचना',
    'enterBtn': 'सिमुलेशन दर्ज करें',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'learnLbl': 'अवलोकन:',
    'nextScenario': 'अगला परिदृश्य',
    'finishLab': 'समाप्त करें',
    'goalTitle': 'लक्ष्य प्राप्त हुआ!',
    'goalDesc':
        'आपने आभासी उपकरणों का उपयोग करके आकृतियों का निर्माण सफलतापूर्वक किया है!',

    's1_title': '1. एक पूर्ण वर्ग बनाना',
    's1_obj':
        'आभासी पैमाने और चांदा का उपयोग करके वर्ग (6 सेमी) के निर्माण के मूलभूत चरण।',
    's1_step1_task':
        'पेंसिल चुनें। गाइड के साथ P से Q तक 6 सेमी की रेखा खींचें।',
    's1_step1_out': 'आधार PQ (6 सेमी) खींचा गया है।',
    's1_step2_task': 'चांदा चुनें। इसका केंद्र बिंदु P पर स्नैप करें।',
    's1_step2_out': 'चांदा 90° मापने के लिए तैयार है।',
    's1_step3_task': 'पेंसिल चुनें। P से शुरू होकर 6 सेमी लंबवत रेखा खींचें।',
    's1_step3_out': 'लंबवत रेखा PS खींची गई है।',
    's1_step4_task': 'चांदा चुनें। इसका केंद्र Q पर स्नैप करें।',
    's1_step4_out': 'चांदा Q पर तैयार है।',
    's1_step5_task': 'पेंसिल चुनें। Q से शुरू होकर 6 सेमी लंबवत रेखा खींचें।',
    's1_step5_out': 'लंबवत रेखा QR खींची गई है।',
    's1_step6_task': 'पेंसिल चुनें। S को R से कनेक्ट करें।',
    's1_step6_out': 'वर्ग PQRS पूरा हो गया है!',

    's2_title': '2. आयताकार चित्र बनाना',
    's2_obj': 'विभिन्न लंबाई (6 सेमी और 4 सेमी) के साथ आयत का निर्माण करना।',
    's2_step1_task': 'पेंसिल चुनें। A से B तक 6 सेमी की रेखा खींचें।',
    's2_step1_out': 'आधार AB (6 सेमी) खींचा गया है।',
    's2_step2_task': 'चांदा चुनें। इसे A पर स्नैप करें।',
    's2_step2_out': 'चांदा तैयार है।',
    's2_step3_task': 'पेंसिल चुनें। A से D तक 4 सेमी लंबवत रेखा खींचें।',
    's2_step3_out': 'भुजा AD खींची गई है।',
    's2_step4_task': 'चांदा चुनें। इसे B पर स्नैप करें।',
    's2_step4_out': 'चांदा तैयार है।',
    's2_step5_task': 'पेंसिल चुनें। B से C तक 4 सेमी लंबवत रेखा खींचें।',
    's2_step5_out': 'भुजा BC खींची गई है।',
    's2_step6_task': 'पेंसिल चुनें। D को C से कनेक्ट करें।',
    's2_step6_out': 'आयत ABCD पूरा हो गया है!',

    's3_title': '3. कंपास विधि (वर्ग)',
    's3_obj':
        'लंबाई मापने के लिए रूलर और कंपास का उपयोग करके 5 सेमी वर्ग का निर्माण करना।',
    's3_step1_task': 'पेंसिल से P से Q तक 5 सेमी की रेखा खींचें।',
    's3_step1_out': 'आधार PQ खींचा गया।',
    's3_step2_task': 'चांदा P पर रखें।',
    's3_step2_out': 'चांदा तैयार।',
    's3_step3_task': 'P से ऊपर की ओर लंबवत रेखा खींचें।',
    's3_step3_out': 'गाइड रेखा खींची गई।',
    's3_step4_task': 'कंपास चुनें। 5 सेमी की चौड़ाई सेट करें।',
    's3_step4_out': 'कंपास 5 सेमी पर सेट है।',
    's3_step5_task':
        'कंपास को P पर स्नैप करें। चाप खींचने के लिए इसकी पेंसिल को ड्रैग करें।',
    's3_step5_out': 'बिंदु S 5 सेमी पर अंकित।',
    's3_step6_task':
        'कंपास को Q पर स्नैप करें। ऊपर एक चाप खींचने के लिए इसकी पेंसिल को ड्रैग करें।',
    's3_step6_out': 'Q से चाप खींचा गया।',
    's3_step7_task':
        'कंपास को S पर स्नैप करें। चाप खींचने के लिए इसकी पेंसिल को ड्रैग करें।',
    's3_step7_out': 'चाप R पर काटते हैं।',
    's3_step8_task': 'Q को R से, और S को R से मिलाएँ।',
    's3_step8_out': 'वर्ग पूरा हुआ!',

    's4_title': '4. गार्डन प्लॉट',
    's4_obj':
        'प्रोटेक्टर और रूलर का उपयोग करके 10x5 सेमी का आयताकार गार्डन प्लॉट बनाएं।',
    's4_step1_task': 'A से B तक 10 सेमी की बेस लाइन खींचें।',
    's4_step1_out': '10 सेमी बेस AB खींचा गया।',
    's4_step2_task': 'चांदा चुनें। इसे बिंदु A पर स्नैप करें।',
    's4_step2_out': 'चांदा A पर तैयार है।',
    's4_step3_task': 'पेंसिल चुनें। 5 सेमी लंबवत रेखा D तक खींचें।',
    's4_step3_out': '5 सेमी भुजा AD खींची गई।',
    's4_step4_task': 'चांदा चुनें। इसे बिंदु B पर स्नैप करें।',
    's4_step4_out': 'चांदा B पर तैयार है।',
    's4_step5_task': 'पेंसिल चुनें। 5 सेमी लंबवत रेखा C तक खींचें।',
    's4_step5_out': '5 सेमी भुजा BC खींची गई।',
    's4_step6_task': 'पेंसिल चुनें। D को C से कनेक्ट करें।',
    's4_step6_out': 'गार्डन प्लॉट (10x5) पूरा हो गया है!',

    's5_title': '5. झुका हुआ टाइल',
    's5_obj': 'एक 7 सेमी का वर्ग बनाएं जो एक कोण पर झुका हुआ हो।',
    's5_step1_task': 'पेंसिल चुनें। A से B तक 7 सेमी की झुकी हुई रेखा खींचें।',
    's5_step1_out': 'झुका हुआ आधार AB खींचा गया।',
    's5_step2_task': 'चांदा चुनें। इसे बिंदु A पर स्नैप करें।',
    's5_step2_out': 'चांदा A पर झुके हुए कोण पर सेट है।',
    's5_step3_task': 'पेंसिल चुनें। 7 सेमी लंबवत रेखा D तक खींचें।',
    's5_step3_out': 'झुकी हुई भुजा AD खींची गई।',
    's5_step4_task': 'चांदा चुनें। इसे बिंदु B पर स्नैप करें।',
    's5_step4_out': 'चांदा B पर तैयार है।',
    's5_step5_task': 'पेंसिल चुनें। 7 सेमी लंबवत रेखा C तक खींचें।',
    's5_step5_out': 'झुकी हुई भुजा BC खींची गई।',
    's5_step6_task': 'पेंसिल चुनें। D को C से कनेक्ट करें।',
    's5_step6_out': 'झुका हुआ टाइल पूरी तरह से निर्मित है!',
  },
};

// --- DATA MODELS ---

class Point2D {
  double x, y;
  String? label;
  Point2D(this.x, this.y, {this.label});
}

class DrawnLine {
  double x1, y1, x2, y2;
  bool isDashed;
  DrawnLine(this.x1, this.y1, this.x2, this.y2, {this.isDashed = false});
}

class DrawnArc {
  double cx, cy, r, sa, ea;
  DrawnArc(this.cx, this.cy, this.r, this.sa, this.ea);
}

class ConfStep {
  String type; // 'draw_line', 'place', 'set_compass', 'draw_arc'
  Point2D? p1, p2, p3;
  Point2D? target;
  String? tool;
  double? angle;
  double? width;
  double? r, sa, ea;
  Point2D? markPt;
  bool isCombo;
  bool hideEndLabel;
  String? style;

  ConfStep({
    required this.type,
    this.p1,
    this.p2,
    this.p3,
    this.target,
    this.tool,
    this.angle,
    this.width,
    this.r,
    this.sa,
    this.ea,
    this.markPt,
    this.isCombo = false,
    this.hideEndLabel = false,
    this.style,
  });
}

class Cl6M_Ch8_A3_ConstructingSquaresAndRectangle extends StatefulWidget {
  const Cl6M_Ch8_A3_ConstructingSquaresAndRectangle({Key? key})
    : super(key: key);

  @override
  State<Cl6M_Ch8_A3_ConstructingSquaresAndRectangle> createState() =>
      _Cl6M_Ch8_A3_ConstructingSquaresAndRectangleState();
}

class _Cl6M_Ch8_A3_ConstructingSquaresAndRectangleState
    extends State<Cl6M_Ch8_A3_ConstructingSquaresAndRectangle>
    with SingleTickerProviderStateMixin {
  // Setup & Layout State
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // Canvas State
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _gameLoop;

  double _panX = 0;
  double _panY = 0;
  double _zoom = 1.0;
  double _baseZoom = 1.0;
  final bool _isPanMode = false;

  // Simulation State
  int _scenarioIndex = 1;
  int _currentStep = 0;
  String _activeTool = 'pencil'; // pencil, ruler, protractor, compass

  final List<DrawnLine> _drawnLines = [];
  final List<DrawnArc> _drawnArcs = [];
  final List<Point2D> _drawnPoints = [];

  // Tools Data
  Point2D _rulerPos = Point2D(0, 150);
  double _rulerAngle = 0;
  bool _rulerVisible = false;

  Point2D _protractorPos = Point2D(-150, -150);
  double _protractorAngle = 0;
  bool _protractorVisible = false;

  final Point2D _compassPos = Point2D(0, 0);
  double _compassWidth = 100;
  double _compassAngle = 0;
  bool _compassVisible = false;

  // Interactions
  String? _draggingTool;
  DrawnLine? _drawingLine;
  Point2D? _drawingLineTarget;
  DrawnArc? _drawingArc;
  double _targetArcEa = 0;

  String? _hudMessage;
  bool _hudIsError = false;

  Map<int, List<ConfStep>> _scenariosConfigs = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initScenarios();

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

  void _initScenarios() {
    _scenariosConfigs = {
      1: [
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-90, 90, label: 'P'),
          p2: Point2D(90, 90, label: 'Q'),
        ),
        ConfStep(type: 'place', tool: 'protractor', target: Point2D(-90, 90)),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-90, 90),
          p2: Point2D(-90, -90, label: 'S'),
        ),
        ConfStep(type: 'place', tool: 'protractor', target: Point2D(90, 90)),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(90, 90),
          p2: Point2D(90, -90, label: 'R'),
        ),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-90, -90),
          p2: Point2D(90, -90),
        ),
      ],
      2: [
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-90, 60, label: 'A'),
          p2: Point2D(90, 60, label: 'B'),
        ),
        ConfStep(type: 'place', tool: 'protractor', target: Point2D(-90, 60)),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-90, 60),
          p2: Point2D(-90, -60, label: 'D'),
        ),
        ConfStep(type: 'place', tool: 'protractor', target: Point2D(90, 60)),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(90, 60),
          p2: Point2D(90, -60, label: 'C'),
        ),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-90, -60),
          p2: Point2D(90, -60),
        ),
      ],
      3: [
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-75, 75, label: 'P'),
          p2: Point2D(75, 75, label: 'Q'),
        ),
        ConfStep(type: 'place', tool: 'protractor', target: Point2D(-75, 75)),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-75, 75),
          p2: Point2D(-75, -120),
          style: 'dashed',
          hideEndLabel: true,
        ),
        ConfStep(type: 'set_compass', width: 150),
        ConfStep(
          type: 'draw_arc',
          target: Point2D(-75, 75),
          r: 150,
          sa: -120,
          ea: -60,
          markPt: Point2D(-75, -75, label: 'S'),
        ),
        ConfStep(
          type: 'draw_arc',
          target: Point2D(75, 75),
          r: 150,
          sa: -120,
          ea: -60,
        ),
        ConfStep(
          type: 'draw_arc',
          target: Point2D(-75, -75),
          r: 150,
          sa: -60,
          ea: 0,
          markPt: Point2D(75, -75, label: 'R'),
        ),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(75, 75),
          p2: Point2D(75, -75),
          p3: Point2D(-75, -75),
          isCombo: true,
        ),
      ],
      4: [
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-150, 75, label: 'A'),
          p2: Point2D(150, 75, label: 'B'),
        ),
        ConfStep(type: 'place', tool: 'protractor', target: Point2D(-150, 75)),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-150, 75),
          p2: Point2D(-150, -75, label: 'D'),
        ),
        ConfStep(type: 'place', tool: 'protractor', target: Point2D(150, 75)),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(150, 75),
          p2: Point2D(150, -75, label: 'C'),
        ),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-150, -75),
          p2: Point2D(150, -75),
        ),
      ],
      5: [
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-38.43, 143.43, label: 'A'),
          p2: Point2D(143.43, 38.43, label: 'B'),
        ),
        ConfStep(
          type: 'place',
          tool: 'protractor',
          target: Point2D(-38.43, 143.43),
          angle: -30,
        ),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-38.43, 143.43),
          p2: Point2D(-143.43, -38.43, label: 'D'),
        ),
        ConfStep(
          type: 'place',
          tool: 'protractor',
          target: Point2D(143.43, 38.43),
          angle: -30,
        ),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(143.43, 38.43),
          p2: Point2D(38.43, -143.43, label: 'C'),
        ),
        ConfStep(
          type: 'draw_line',
          p1: Point2D(-143.43, -38.43),
          p2: Point2D(38.43, -143.43),
        ),
      ],
    };
  }

  String t(String key) {
    return i18n[_lang]?[key] ?? i18n['en']?[key] ?? key;
  }

  void _loadScenario(int index) {
    setState(() {
      _scenarioIndex = index;
      _currentStep = 0;
      _drawnLines.clear();
      _drawnArcs.clear();
      _drawnPoints.clear();
      _activeTool = 'pencil';

      _rulerVisible = false;
      _protractorVisible = false;
      _compassVisible = false;
      _protractorAngle = 0;

      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
      _hudMessage = null;
    });
  }

  void _selectTool(String tool) {
    playClick();
    setState(() {
      _activeTool = tool;
      _rulerVisible = tool == 'ruler';
      _protractorVisible = tool == 'protractor';
      _compassVisible = tool == 'compass';
    });
  }

  void _showHudMessage(String msg, bool isError) {
    if (isError) {
      playError();
    }
    setState(() {
      _hudMessage = msg;
      _hudIsError = isError;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _hudMessage == msg) {
        setState(() => _hudMessage = null);
      }
    });
  }

  double _dist(Point2D p1, Point2D p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }

  void _addPoint(Point2D p) {
    if (!_drawnPoints.any(
      (dp) => dp.x == p.x && dp.y == p.y && dp.label == p.label,
    )) {
      _drawnPoints.add(p);
    }
  }

  void _checkGoalReached() {
    int maxSteps = _scenariosConfigs[_scenarioIndex]?.length ?? 0;
    if (_currentStep >= maxSteps) {
      playPageOpen();
    }
  }

  // --- GESTURE HANDLING ---

  void _onScaleStart(ScaleStartDetails details) {
    if (_showCurtain) return;

    _baseZoom = _zoom;

    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset localFocal = box.globalToLocal(details.focalPoint);
    double worldX = (localFocal.dx - box.size.width / 2 - _panX) / _zoom;
    double worldY = (localFocal.dy - box.size.height / 2 - _panY) / _zoom;
    Point2D wPt = Point2D(worldX, worldY);

    if (_isPanMode) return;

    bool clickedTool = false;

    // 1. Tool Interaction (Instantly jump tool pos to allow no-drag snapping)
    if (_activeTool == 'compass' && _compassVisible) {
      Point2D pencilPt = Point2D(
        _compassPos.x + _compassWidth * cos(_compassAngle * pi / 180),
        _compassPos.y + _compassWidth * sin(_compassAngle * pi / 180),
      );
      if (_dist(wPt, pencilPt) < 40) {
        ConfStep? conf =
            (_currentStep < _scenariosConfigs[_scenarioIndex]!.length)
            ? _scenariosConfigs[_scenarioIndex]![_currentStep]
            : null;

        if (conf != null &&
            conf.type == 'draw_arc' &&
            _dist(_compassPos, conf.target!) < 30) {
          _drawingArc = DrawnArc(
            conf.target!.x,
            conf.target!.y,
            conf.r!,
            _compassAngle,
            _compassAngle,
          );
          _targetArcEa = conf.ea!;
          clickedTool = true;
        } else {
          _draggingTool = 'compass_width';
          double w = _dist(_compassPos, wPt);
          _compassWidth = max(10, w);
          _compassAngle =
              atan2(wPt.y - _compassPos.y, wPt.x - _compassPos.x) * 180 / pi;
          clickedTool = true;
        }
      } else if (_dist(wPt, _compassPos) < 40) {
        _draggingTool = 'compass';
        _compassPos.x = wPt.x;
        _compassPos.y = wPt.y;
        clickedTool = true;
      }
    } else if (_activeTool == 'protractor' && _protractorVisible) {
      if (_dist(wPt, _protractorPos) < 80) {
        _draggingTool = 'protractor';
        _protractorPos.x = wPt.x;
        _protractorPos.y = wPt.y;
        clickedTool = true;
      }
    } else if (_activeTool == 'ruler' && _rulerVisible) {
      if (wPt.x > _rulerPos.x - 200 &&
          wPt.x < _rulerPos.x + 200 &&
          wPt.y > _rulerPos.y - 30 &&
          wPt.y < _rulerPos.y + 30) {
        _draggingTool = 'ruler';
        _rulerPos.x = wPt.x;
        _rulerPos.y = wPt.y;
        clickedTool = true;
      }
    }

    // 2. Line Drawing
    if (!clickedTool && _activeTool == 'pencil') {
      ConfStep? conf =
          (_currentStep < _scenariosConfigs[_scenarioIndex]!.length)
          ? _scenariosConfigs[_scenarioIndex]![_currentStep]
          : null;
      if (conf != null && conf.type == 'draw_line') {
        bool p1p2Drawn = _drawnLines.any(
          (l) =>
              ((l.x1 - conf.p1!.x).abs() < 5 &&
                  (l.y1 - conf.p1!.y).abs() < 5 &&
                  (l.x2 - conf.p2!.x).abs() < 5 &&
                  (l.y2 - conf.p2!.y).abs() < 5) ||
              ((l.x1 - conf.p2!.x).abs() < 5 &&
                  (l.y1 - conf.p2!.y).abs() < 5 &&
                  (l.x2 - conf.p1!.x).abs() < 5 &&
                  (l.y2 - conf.p1!.y).abs() < 5),
        );

        bool p3p2Drawn = false;
        if (conf.isCombo && conf.p3 != null) {
          p3p2Drawn = _drawnLines.any(
            (l) =>
                ((l.x1 - conf.p3!.x).abs() < 5 &&
                    (l.y1 - conf.p3!.y).abs() < 5 &&
                    (l.x2 - conf.p2!.x).abs() < 5 &&
                    (l.y2 - conf.p2!.y).abs() < 5) ||
                ((l.x1 - conf.p2!.x).abs() < 5 &&
                    (l.y1 - conf.p2!.y).abs() < 5 &&
                    (l.x2 - conf.p3!.x).abs() < 5 &&
                    (l.y2 - conf.p3!.y).abs() < 5),
          );
        }

        if (!p1p2Drawn && _dist(wPt, conf.p1!) < 40) {
          _drawingLine = DrawnLine(conf.p1!.x, conf.p1!.y, wPt.x, wPt.y);
          _drawingLineTarget = conf.p2;
        } else if (conf.isCombo &&
            !p3p2Drawn &&
            conf.p3 != null &&
            _dist(wPt, conf.p3!) < 40) {
          _drawingLine = DrawnLine(conf.p3!.x, conf.p3!.y, wPt.x, wPt.y);
          _drawingLineTarget = conf.p2;
        }
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_showCurtain) return;

    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset localFocal = box.globalToLocal(details.focalPoint);
    double worldX = (localFocal.dx - box.size.width / 2 - _panX) / _zoom;
    double worldY = (localFocal.dy - box.size.height / 2 - _panY) / _zoom;
    Point2D wPt = Point2D(worldX, worldY);

    setState(() {
      if (_isPanMode ||
          (_drawingLine == null &&
              _drawingArc == null &&
              _draggingTool == null)) {
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
        }
        return;
      }

      if (_drawingLine != null && _drawingLineTarget != null) {
        _drawingLine!.x2 = wPt.x;
        _drawingLine!.y2 = wPt.y;
        if (_dist(wPt, _drawingLineTarget!) < 20) {
          _drawingLine!.x2 = _drawingLineTarget!.x;
          _drawingLine!.y2 = _drawingLineTarget!.y;
        }
      } else if (_drawingArc != null) {
        double angle =
            atan2(wPt.y - _drawingArc!.cy, wPt.x - _drawingArc!.cx) * 180 / pi;
        if (_activeTool == 'compass') _compassAngle = angle;

        double diff = angle - _targetArcEa;
        if (diff < -180) diff += 360;
        if (diff > 180) diff -= 360;

        _drawingArc!.ea = angle;
        if (diff.abs() < 15) {
          _drawingArc!.ea = _targetArcEa;
          if (_activeTool == 'compass') _compassAngle = _targetArcEa;
        }
      } else if (_draggingTool != null) {
        if (_draggingTool == 'compass_width') {
          double w = _dist(_compassPos, wPt);
          _compassWidth = max(10, w);
          _compassAngle =
              atan2(wPt.y - _compassPos.y, wPt.x - _compassPos.x) * 180 / pi;
        } else if (_draggingTool == 'compass') {
          _compassPos.x = wPt.x;
          _compassPos.y = wPt.y;
        } else if (_draggingTool == 'protractor') {
          _protractorPos.x = wPt.x;
          _protractorPos.y = wPt.y;
        } else if (_draggingTool == 'ruler') {
          _rulerPos.x = wPt.x;
          _rulerPos.y = wPt.y;
        }
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_showCurtain) return;

    setState(() {
      if (_drawingLine != null) {
        ConfStep conf = _scenariosConfigs[_scenarioIndex]![_currentStep];
        if (_drawingLineTarget != null &&
            _drawingLine!.x2 == _drawingLineTarget!.x &&
            _drawingLine!.y2 == _drawingLineTarget!.y) {
          _drawnLines.add(
            DrawnLine(
              _drawingLine!.x1,
              _drawingLine!.y1,
              _drawingLine!.x2,
              _drawingLine!.y2,
              isDashed: conf.style == 'dashed',
            ),
          );
          playClick();
          if (conf.isCombo && conf.p3 != null) {
            bool p1p2Drawn = _drawnLines.any(
              (l) =>
                  ((l.x1 - conf.p1!.x).abs() < 5 &&
                      (l.y1 - conf.p1!.y).abs() < 5 &&
                      (l.x2 - conf.p2!.x).abs() < 5 &&
                      (l.y2 - conf.p2!.y).abs() < 5) ||
                  ((l.x1 - conf.p2!.x).abs() < 5 &&
                      (l.y1 - conf.p2!.y).abs() < 5 &&
                      (l.x2 - conf.p1!.x).abs() < 5 &&
                      (l.y2 - conf.p1!.y).abs() < 5),
            );
            bool p3p2Drawn = _drawnLines.any(
              (l) =>
                  ((l.x1 - conf.p3!.x).abs() < 5 &&
                      (l.y1 - conf.p3!.y).abs() < 5 &&
                      (l.x2 - conf.p2!.x).abs() < 5 &&
                      (l.y2 - conf.p2!.y).abs() < 5) ||
                  ((l.x1 - conf.p2!.x).abs() < 5 &&
                      (l.y1 - conf.p2!.y).abs() < 5 &&
                      (l.x2 - conf.p3!.x).abs() < 5 &&
                      (l.y2 - conf.p3!.y).abs() < 5),
            );

            if (p1p2Drawn && p3p2Drawn) {
              if (conf.p1?.label != null) {
                _addPoint(
                  Point2D(conf.p1!.x, conf.p1!.y, label: conf.p1!.label),
                );
              }
              if (conf.p2?.label != null && !conf.hideEndLabel) {
                _addPoint(
                  Point2D(conf.p2!.x, conf.p2!.y, label: conf.p2!.label),
                );
              }
              if (conf.p3?.label != null) {
                _addPoint(
                  Point2D(conf.p3!.x, conf.p3!.y, label: conf.p3!.label),
                );
              }
              _currentStep++;
              _checkGoalReached();
            }
          } else {
            if (conf.p1?.label != null) {
              _addPoint(Point2D(conf.p1!.x, conf.p1!.y, label: conf.p1!.label));
            }
            if (conf.p2?.label != null && !conf.hideEndLabel) {
              _addPoint(Point2D(conf.p2!.x, conf.p2!.y, label: conf.p2!.label));
            }
            _currentStep++;
            _checkGoalReached();
          }
        } else {
          _showHudMessage('Incorrect length. Follow the guide.', true);
        }
        _drawingLine = null;
        _drawingLineTarget = null;
      } else if (_drawingArc != null) {
        if (_drawingArc!.ea == _targetArcEa) {
          _drawnArcs.add(
            DrawnArc(
              _drawingArc!.cx,
              _drawingArc!.cy,
              _drawingArc!.r,
              _drawingArc!.sa,
              _drawingArc!.ea,
            ),
          );
          playClick();
          ConfStep conf = _scenariosConfigs[_scenarioIndex]![_currentStep];
          if (conf.markPt != null) {
            _addPoint(
              Point2D(
                conf.markPt!.x,
                conf.markPt!.y,
                label: conf.markPt!.label,
              ),
            );
          }
          _currentStep++;
          _checkGoalReached();
        }
        _drawingArc = null;
      } else if (_draggingTool != null) {
        ConfStep? conf =
            (_currentStep < _scenariosConfigs[_scenarioIndex]!.length)
            ? _scenariosConfigs[_scenarioIndex]![_currentStep]
            : null;
        if (conf != null) {
          if (conf.type == 'place' && _draggingTool == conf.tool) {
            Point2D tPos = _draggingTool == 'protractor'
                ? _protractorPos
                : _rulerPos;
            if (_dist(tPos, conf.target!) < 30) {
              if (_draggingTool == 'protractor') {
                _protractorPos = Point2D(conf.target!.x, conf.target!.y);
                _protractorAngle = conf.angle ?? 0;
              } else {
                _rulerPos = Point2D(conf.target!.x, conf.target!.y);
                _rulerAngle = conf.angle ?? 0;
              }
              playClick();
              _currentStep++;
              _checkGoalReached();
            }
          } else if (conf.type == 'set_compass' &&
              _draggingTool == 'compass_width') {
            if ((_compassWidth - conf.width!).abs() < 15) {
              _compassWidth = conf.width!;
              playClick();
              _currentStep++;
              _checkGoalReached();
            }
          } else if (conf.type == 'draw_arc' && _draggingTool == 'compass') {
            if (_dist(_compassPos, conf.target!) < 40) {
              _compassPos.x = conf.target!.x;
              _compassPos.y = conf.target!.y;
              _compassAngle = conf.sa ?? 0;
            }
          }
        }
        _draggingTool = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasMoreSteps =
        _currentStep < (_scenariosConfigs[_scenarioIndex]?.length ?? 0);

    return MaterialApp(
      title: 'ZSL Virtual Lab | Geometry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Scaffold(
          body: Stack(
            children: [
              // --- MAIN CANVAS AREA ---
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                right: 0,
                left: _sidebarOpen ? _sidebarWidth : 0,
                child: Stack(
                  children: [
                    // Rendering Canvas
                    GestureDetector(
                      key: _canvasKey,
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: Container(
                        color: const Color(0xFF0F172A), // Dark slate bg
                        width: double.infinity,
                        height: double.infinity,
                        child: AnimatedBuilder(
                          animation: _gameLoop,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: SimulationPainter(
                                panX: _panX,
                                panY: _panY,
                                zoom: _zoom,
                                drawnLines: _drawnLines,
                                drawnArcs: _drawnArcs,
                                drawnPoints: _drawnPoints,
                                drawingLine: _drawingLine,
                                drawingArc: _drawingArc,
                                currentConf: hasMoreSteps
                                    ? _scenariosConfigs[_scenarioIndex]![_currentStep]
                                    : null,
                                activeTool: _activeTool,
                                rulerVisible: _rulerVisible,
                                rulerPos: _rulerPos,
                                rulerAngle: _rulerAngle,
                                protractorVisible: _protractorVisible,
                                protractorPos: _protractorPos,
                                protractorAngle: _protractorAngle,
                                compassVisible: _compassVisible,
                                compassPos: _compassPos,
                                compassWidth: _compassWidth,
                                compassAngle: _compassAngle,
                                time: DateTime.now().millisecondsSinceEpoch
                                    .toDouble(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Toolbox Overlay (Shifted down slightly to avoid the top-left menu icon)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            _buildToolBtn('pencil', Icons.edit),
                            const SizedBox(width: 8),
                            _buildToolBtn('ruler', Icons.straighten),
                            const SizedBox(width: 8),
                            _buildToolBtn('protractor', Icons.av_timer),
                            const SizedBox(width: 8),
                            _buildToolBtn('compass', Icons.architecture),
                          ],
                        ),
                      ),
                    ),

                    // Current Instruction HUD (Bottom Center of Canvas)
                    if (hasMoreSteps && !_showCurtain)
                      Positioned(
                        bottom: 10,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 600),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: const Border(
                                top: BorderSide(
                                  color: Colors.indigoAccent,
                                  width: 4,
                                ),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.indigoAccent.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: Colors.indigoAccent,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    t(
                                      's${_scenarioIndex}_step${_currentStep + 1}_task',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Transient Messages Overlay (Top Center)
                    if (_hudMessage != null)
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _hudIsError
                                  ? Colors.redAccent.withOpacity(0.9)
                                  : Colors.teal.withOpacity(
                                      0.9,
                                    ), // Changed from Colors.emerald
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              _hudMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Success Overlay
                    if (!hasMoreSteps && !_showCurtain)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.indigoAccent),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    t('goalTitle'),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t('goalDesc'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      playClick();
                                      if (_scenarioIndex < 5) {
                                        _loadScenario(_scenarioIndex + 1);
                                      } else {
                                        setState(() => _showCurtain = true);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigoAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    icon: Icon(
                                      _scenarioIndex < 5
                                          ? Icons.arrow_forward
                                          : Icons.flag,
                                    ),
                                    label: Text(
                                      _scenarioIndex < 5
                                          ? t('nextScenario')
                                          : t('finishLab'),
                                      style: const TextStyle(
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
                ),
              ),

              // --- LEFT SIDEBAR ---
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                left: _sidebarOpen ? 0 : -_sidebarWidth,
                width: _sidebarWidth,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    border: Border(
                      right: BorderSide(color: Colors.white24, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(2, 0),
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
                            // Header area
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                top: 66.0,
                                bottom: 16.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.architecture,
                                    color: Colors.indigoAccent,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      t('title'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                t('subtitle'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      playClick();
                                      setState(
                                        () =>
                                            _lang = _lang == 'en' ? 'hi' : 'en',
                                      );
                                    },
                                    icon: const Icon(Icons.language, size: 16),
                                    label: Text(_lang == 'en' ? 'HI' : 'EN'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white10,
                                      foregroundColor: Colors.white70,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      playClick();
                                      _loadScenario(1);
                                    },
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Reset'),
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
                                  ),
                                ],
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(
                                color: Colors.white12,
                                thickness: 1,
                              ),
                            ),

                            // Body Content
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('selectScenario').toUpperCase(),
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
                                        value: _scenarioIndex,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        onChanged: (v) {
                                          if (v != null) {
                                            playDropdown();
                                            _loadScenario(v);
                                          }
                                        },
                                        items: [1, 2, 3, 4, 5]
                                            .map(
                                              (i) => DropdownMenuItem(
                                                value: i,
                                                child: Text(t('s${i}_title')),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF334155,
                                      ).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.track_changes,
                                              color: Colors.redAccent,
                                              size: 16,
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
                                          t('s${_scenarioIndex}_obj'),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  ...List.generate(
                                    _scenariosConfigs[_scenarioIndex]?.length ??
                                        0,
                                    (index) {
                                      bool isActive = index == _currentStep;
                                      bool isDone = index < _currentStep;
                                      return _buildStepCard(
                                        index,
                                        isActive,
                                        isDone,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Pushes the footer to the bottom of the screen if the content is small
                            const Expanded(child: SizedBox(height: 20)),

                            // Footer
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: const Color(0xFF0F172A),
                              alignment: Alignment.center,
                              child: const Text(
                                '© ZeroScienceLab - Fall in love with math and Science',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
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

              // Sidebar Resizer Handle (Right edge of sidebar)
              if (_sidebarOpen)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: _sidebarWidth - 10,
                  width: 20,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _sidebarWidth = (_sidebarWidth + details.delta.dx)
                              .clamp(
                                250.0,
                                MediaQuery.of(context).size.width * 0.6,
                              );
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // --- FLOATING MENU TOGGLE (Fixed Top Left) ---
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_sidebarOpen),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _sidebarOpen ? Icons.menu_open : Icons.menu,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          playClick();
                          setState(() => _sidebarOpen = !_sidebarOpen);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // --- CURTAIN SCREEN (Over everything) ---
              if (_showCurtain)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.architecture,
                            color: Colors.indigoAccent,
                            size: 100,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('title'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('subtitle'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: () {
                              curtainScreenSound();
                              setState(() => _showCurtain = false);
                              _loadScenario(1);
                            },
                            icon: const Icon(
                              Icons.play_circle_fill,
                              size: 28,
                              color: Colors.white,
                            ),
                            label: Text(
                              t('enterBtn'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
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
      ),
    );
  }

  Widget _buildToolBtn(String id, IconData icon) {
    bool active = _activeTool == id;
    return GestureDetector(
      onTap: () => _selectTool(id),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active
              ? Colors.indigoAccent.withOpacity(0.3)
              : Colors.transparent,
          border: Border.all(
            color: active ? Colors.indigoAccent : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: active ? Colors.indigoAccent : Colors.white70,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildStepCard(int index, bool isActive, bool isDone) {
    Color bg = isActive
        ? Colors.indigoAccent.withOpacity(0.15)
        : (isDone ? Colors.teal.withOpacity(0.1) : Colors.white10);
    Color border = isActive
        ? Colors.indigoAccent
        : (isDone ? Colors.teal : Colors.transparent);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDone)
            const Icon(Icons.check_circle, color: Colors.teal, size: 24)
          else
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? Colors.indigoAccent : Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t('stepLabel')} ${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t('s${_scenarioIndex}_step${index + 1}_task'),
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? Colors.white : Colors.white70,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isDone) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t('s${_scenarioIndex}_step${index + 1}_out'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.tealAccent,
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

// --- CANVAS PAINTER ---

class SimulationPainter extends CustomPainter {
  final double panX, panY, zoom;
  final List<DrawnLine> drawnLines;
  final List<DrawnArc> drawnArcs;
  final List<Point2D> drawnPoints;
  final DrawnLine? drawingLine;
  final DrawnArc? drawingArc;
  final ConfStep? currentConf;
  final String activeTool;

  final bool rulerVisible;
  final Point2D rulerPos;
  final double rulerAngle;

  final bool protractorVisible;
  final Point2D protractorPos;
  final double protractorAngle;

  final bool compassVisible;
  final Point2D compassPos;
  final double compassWidth, compassAngle;

  final double time;

  SimulationPainter({
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.drawnLines,
    required this.drawnArcs,
    required this.drawnPoints,
    this.drawingLine,
    this.drawingArc,
    this.currentConf,
    required this.activeTool,
    required this.rulerVisible,
    required this.rulerPos,
    required this.rulerAngle,
    required this.protractorVisible,
    required this.protractorPos,
    required this.protractorAngle,
    required this.compassVisible,
    required this.compassPos,
    required this.compassWidth,
    required this.compassAngle,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom);

    final Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint activeLinePaint = Paint()
      ..color = Colors.indigoAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint hintLinePaint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5);

    // Draw existing geometry
    for (var a in drawnArcs) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(a.cx, a.cy), radius: a.r),
        a.sa * pi / 180,
        (a.ea - a.sa) * pi / 180,
        false,
        linePaint,
      );
    }
    for (var l in drawnLines) {
      if (l.isDashed) {
        _drawDashedLine(
          canvas,
          Offset(l.x1, l.y1),
          Offset(l.x2, l.y2),
          linePaint,
        );
      } else {
        canvas.drawLine(Offset(l.x1, l.y1), Offset(l.x2, l.y2), linePaint);
      }
    }
    for (var p in drawnPoints) {
      _drawPoint(canvas, p.x, p.y, p.label);
    }

    // Draw interaction previews
    if (drawingLine != null) {
      _drawDashedLine(
        canvas,
        Offset(drawingLine!.x1, drawingLine!.y1),
        Offset(drawingLine!.x2, drawingLine!.y2),
        activeLinePaint,
      );
    }
    if (drawingArc != null) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(drawingArc!.cx, drawingArc!.cy),
          radius: drawingArc!.r,
        ),
        drawingArc!.sa * pi / 180,
        (drawingArc!.ea - drawingArc!.sa) * pi / 180,
        false,
        activeLinePaint,
      );
    }

    // Draw Guided Hints
    if (currentConf != null) {
      if (currentConf!.type == 'draw_line' && drawingLine == null) {
        bool drawn1 = drawnLines.any(
          (l) =>
              ((l.x1 - currentConf!.p1!.x).abs() < 5 &&
                  (l.y1 - currentConf!.p1!.y).abs() < 5 &&
                  (l.x2 - currentConf!.p2!.x).abs() < 5 &&
                  (l.y2 - currentConf!.p2!.y).abs() < 5) ||
              ((l.x1 - currentConf!.p2!.x).abs() < 5 &&
                  (l.y1 - currentConf!.p2!.y).abs() < 5 &&
                  (l.x2 - currentConf!.p1!.x).abs() < 5 &&
                  (l.y2 - currentConf!.p1!.y).abs() < 5),
        );

        if (!drawn1) {
          _drawDashedLine(
            canvas,
            Offset(currentConf!.p1!.x, currentConf!.p1!.y),
            Offset(currentConf!.p2!.x, currentConf!.p2!.y),
            hintLinePaint,
          );
        }

        if (currentConf!.isCombo && currentConf!.p3 != null) {
          bool drawn2 = drawnLines.any(
            (l) =>
                ((l.x1 - currentConf!.p3!.x).abs() < 5 &&
                    (l.y1 - currentConf!.p3!.y).abs() < 5 &&
                    (l.x2 - currentConf!.p2!.x).abs() < 5 &&
                    (l.y2 - currentConf!.p2!.y).abs() < 5) ||
                ((l.x1 - currentConf!.p2!.x).abs() < 5 &&
                    (l.y1 - currentConf!.p2!.y).abs() < 5 &&
                    (l.x2 - currentConf!.p3!.x).abs() < 5 &&
                    (l.y2 - currentConf!.p3!.y).abs() < 5),
          );
          if (!drawn2) {
            _drawDashedLine(
              canvas,
              Offset(currentConf!.p3!.x, currentConf!.p3!.y),
              Offset(currentConf!.p2!.x, currentConf!.p2!.y),
              hintLinePaint,
            );
          }
        }

        if (currentConf!.p1?.label != null) {
          _drawPoint(
            canvas,
            currentConf!.p1!.x,
            currentConf!.p1!.y,
            currentConf!.p1!.label,
          );
        }
        if (currentConf!.p2?.label != null && !currentConf!.hideEndLabel) {
          _drawPoint(
            canvas,
            currentConf!.p2!.x,
            currentConf!.p2!.y,
            currentConf!.p2!.label,
          );
        }
        if (currentConf!.isCombo && currentConf!.p3?.label != null) {
          _drawPoint(
            canvas,
            currentConf!.p3!.x,
            currentConf!.p3!.y,
            currentConf!.p3!.label,
          );
        }
      } else if (currentConf!.type == 'place' &&
          currentConf!.tool == activeTool) {
        double pulse = 20 + sin(time / 200) * 5;
        canvas.drawCircle(
          Offset(currentConf!.target!.x, currentConf!.target!.y),
          pulse,
          hintLinePaint,
        );
      } else if (currentConf!.type == 'set_compass') {
        _drawPoint(
          canvas,
          compassPos.x + currentConf!.width!,
          compassPos.y,
          "Target",
        );
      } else if (currentConf!.type == 'draw_arc') {
        if (drawingArc == null) {
          canvas.drawArc(
            Rect.fromCircle(
              center: Offset(currentConf!.target!.x, currentConf!.target!.y),
              radius: currentConf!.r!,
            ),
            currentConf!.sa! * pi / 180,
            (currentConf!.ea! - currentConf!.sa!) * pi / 180,
            false,
            hintLinePaint,
          );
          if (_dist(compassPos, currentConf!.target!) > 10) {
            double pulse = 20 + sin(time / 200) * 5;
            canvas.drawCircle(
              Offset(currentConf!.target!.x, currentConf!.target!.y),
              pulse,
              hintLinePaint,
            );
          }
        }
        if (currentConf!.markPt != null) {
          _drawPoint(
            canvas,
            currentConf!.markPt!.x,
            currentConf!.markPt!.y,
            currentConf!.markPt!.label,
          );
        }
      }
    }

    // Draw Tools
    if (rulerVisible || (currentConf?.type == 'set_compass')) {
      _drawRuler(canvas, rulerPos, rulerAngle, activeTool == 'ruler');
    }
    if (protractorVisible) {
      _drawProtractor(
        canvas,
        protractorPos,
        protractorAngle,
        activeTool == 'protractor',
      );
    }
    if (compassVisible) {
      _drawCompass(
        canvas,
        compassPos,
        compassWidth,
        compassAngle,
        activeTool == 'compass',
      );
    }

    canvas.restore();
  }

  void _drawPoint(Canvas canvas, double x, double y, String? label) {
    canvas.drawCircle(
      Offset(x, y),
      5,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
    if (label != null) {
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - 15, y - 20));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 8.0;
    double distance = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    double drawn = 0;
    while (drawn < distance) {
      double curDash = min(dashWidth, distance - drawn);
      canvas.drawLine(
        Offset(p1.dx + dx * drawn, p1.dy + dy * drawn),
        Offset(p1.dx + dx * (drawn + curDash), p1.dy + dy * (drawn + curDash)),
        paint,
      );
      drawn += dashWidth + dashSpace;
    }
  }

  void _drawRuler(Canvas canvas, Point2D pos, double angle, bool isActive) {
    canvas.save();
    canvas.translate(pos.x, pos.y);
    canvas.rotate(angle * pi / 180);

    Paint bg = Paint()
      ..color = Colors.blueGrey[100]!.withOpacity(isActive ? 1.0 : 0.8)
      ..style = PaintingStyle.fill;
    Paint border = Paint()
      ..color = Colors.blueGrey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Rect r = Rect.fromCenter(center: Offset.zero, width: 400, height: 40);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), bg);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      border,
    );

    Paint tickP = Paint()
      ..color = Colors.blueGrey[900]!
      ..strokeWidth = 1;
    for (int i = 0; i <= 300; i += 3) {
      double px = -150.0 + i;
      double th = (i % 30 == 0) ? 15 : (i % 15 == 0 ? 10 : 5);
      canvas.drawLine(
        Offset(px, -20),
        Offset(px, -20 + th),
        tickP..strokeWidth = (i % 30 == 0) ? 2 : 1,
      );
      if (i % 30 == 0) {
        TextPainter(
            text: TextSpan(
              text: '${i ~/ 30}',
              style: TextStyle(
                color: Colors.blueGrey[900],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )
          ..layout()
          ..paint(canvas, Offset(px - 4, -4));
      }
    }

    if (isActive) {
      canvas.drawRect(
        r.inflate(2),
        Paint()
          ..color = Colors.indigoAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.restore();
  }

  void _drawProtractor(
    Canvas canvas,
    Point2D pos,
    double angle,
    bool isActive,
  ) {
    canvas.save();
    canvas.translate(pos.x, pos.y);
    canvas.rotate(angle * pi / 180);

    double r = 120;
    Paint bg = Paint()
      ..color = Colors.blueGrey[100]!.withOpacity(isActive ? 1.0 : 0.8)
      ..style = PaintingStyle.fill;
    Paint border = Paint()
      ..color = Colors.blueGrey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path p = Path()
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: r), pi, pi, true)
      ..lineTo(r, 0)
      ..lineTo(-r, 0)
      ..close();
    canvas.drawPath(p, bg);
    canvas.drawPath(p, border);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r - 30),
      pi,
      pi,
      false,
      border,
    );

    canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.redAccent);
    canvas.drawLine(
      const Offset(-10, 0),
      const Offset(10, 0),
      border..strokeWidth = 1,
    );
    canvas.drawLine(const Offset(0, -10), const Offset(0, 10), border);

    Paint tickP = Paint()..color = Colors.blueGrey[900]!;
    for (int deg = 0; deg <= 180; deg += 5) {
      double rad = deg * pi / 180;
      bool isTen = deg % 10 == 0;
      double l1 = isTen ? r : r - 10;
      double l2 = r - 20;
      canvas.drawLine(
        Offset(-l1 * cos(rad), -l1 * sin(rad)),
        Offset(-l2 * cos(rad), -l2 * sin(rad)),
        tickP..strokeWidth = isTen ? 2 : 1,
      );
      if (isTen) {
        TextPainter(
            text: TextSpan(
              text: '$deg',
              style: TextStyle(
                color: Colors.blueGrey[900],
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )
          ..layout()
          ..paint(
            canvas,
            Offset(-(r - 28) * cos(rad) - 6, -(r - 28) * sin(rad) - 6),
          );
      }
    }

    if (isActive) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: r + 2),
        pi,
        pi,
        true,
        Paint()
          ..color = Colors.indigoAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.restore();
  }

  void _drawCompass(
    Canvas canvas,
    Point2D pos,
    double width,
    double angle,
    bool isActive,
  ) {
    canvas.save();
    canvas.translate(pos.x, pos.y);
    canvas.rotate(angle * pi / 180);

    Paint solid = Paint()
      ..color = Colors.blueGrey[400]!.withOpacity(isActive ? 1.0 : 0.8)
      ..style = PaintingStyle.fill;
    Paint outline = Paint()
      ..color = Colors.blueGrey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Paint legP = Paint()
      ..color = Colors.blueGrey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    Paint pencilLegP = Paint()
      ..color = Colors.blueGrey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Hinge
    canvas.drawCircle(const Offset(0, -80), 8, solid);
    canvas.drawCircle(const Offset(0, -80), 8, outline);

    // Needle leg
    canvas.drawLine(const Offset(0, -80), const Offset(0, 0), legP);
    canvas.drawPath(
      Path()
        ..moveTo(-2, 0)
        ..lineTo(2, 0)
        ..lineTo(0, 10)
        ..close(),
      solid..color = Colors.blueGrey[800]!,
    );

    // Pencil leg
    canvas.drawLine(const Offset(0, -80), Offset(width, 0), pencilLegP);
    canvas.drawPath(
      Path()
        ..moveTo(width - 4, 0)
        ..lineTo(width + 4, 0)
        ..lineTo(width, 15)
        ..close(),
      Paint()..color = Colors.amber,
    );
    canvas.drawPath(
      Path()
        ..moveTo(width - 4, 0)
        ..lineTo(width + 4, 0)
        ..lineTo(width, 15)
        ..close(),
      outline,
    );
    canvas.drawPath(
      Path()
        ..moveTo(width - 1, 10)
        ..lineTo(width + 1, 10)
        ..lineTo(width, 15)
        ..close(),
      Paint()..color = Colors.blueGrey[900]!,
    );

    canvas.restore();
  }

  double _dist(Point2D p1, Point2D p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) => true;
}
