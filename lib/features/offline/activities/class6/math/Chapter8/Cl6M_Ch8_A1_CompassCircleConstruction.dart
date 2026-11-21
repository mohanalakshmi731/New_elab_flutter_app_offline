// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Cl6M_Ch8_A1_CompassCircleConstruction());
}

// ---------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------

class WorldPoint {
  final double x, y;
  WorldPoint(this.x, this.y);
}

class UserArc {
  double cx, cy, r, startAngle, endAngle;
  bool isTargetHit;
  UserArc({
    required this.cx,
    required this.cy,
    required this.r,
    required this.startAngle,
    required this.endAngle,
    this.isTargetHit = false,
  });
}

class CompassTool {
  double cx = 0;
  double cy = 0;
  double r = 80;
  double angle = 0;
  bool draggingTip = false;
  bool draggingPencil = false;
}

// ---------------------------------------------------------
// LOCALIZATION (i18n)
// ---------------------------------------------------------

const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': 'Introduction to Compass and Circle Construction',
    'appTitle': 'Compass and Circle Construction',
    'appSubtitle': 'Class 6 ',
    'enterLab': 'Enter Lab',
    'settings': 'Settings',
    'theme': 'Theme',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'doneBtn': 'Done',
    'learnLbl': 'Objective:',
    'closeBtn': 'Close',
    'summaryTitle': 'Goal Reached!',
    'resetBtn': 'Reset Lab',
    'finishLab': 'Finish Lab',
    'nextScenario': 'Next Scenario',
    'labCompleted': 'Lab Completed!',
    'finalDesc':
        'You have successfully learned to use a compass to construct circles and arcs!',

    's1_title': '1. The Magic of Equidistance',
    's1_obj':
        'Visually understand that a circle is a collection of all points that are the same distance from a central point.',
    's1_step1_task':
        'Tap anywhere to use the Magic Wand. It marks a point exactly 4cm from center P.',
    's1_step1_out': 'A point is placed exactly 4cm away.',
    's1_step2_task': 'Tap 15 more times in different directions.',
    's1_step2_out': 'The points begin to form the outline of a circle.',
    's1_step3_task': 'Tap the "Draw Circle" button on the canvas.',
    's1_step3_out': 'A perfect circle connects all points.',
    's1_step4_task': 'Drag the compass tip and drop it onto point P.',
    's1_step4_out': 'The compass is placed at the center.',
    's1_step5_task': 'Drag the pencil end of the compass in a full circle.',
    's1_step5_out': 'The compass perfectly traces the shape.',
    's1_hud1': 'Tap to place the first point 4cm from P.',
    's1_hud2': 'Tap more points to form the outline.',
    's1_hud3': 'Tap "Draw Circle".',
    's1_hud4': 'Drag the compass tip to point P.',
    's1_hud5': 'Drag the pencil to draw a circle.',

    's2_title': '2. The Ruler and the Compass',
    's2_obj': 'Learn to set a compass to a specific radius using a ruler.',
    's2_step1_task': 'Drag the compass tip to the 0cm mark on the ruler.',
    's2_step1_out': 'The tip snaps to 0cm.',
    's2_step2_task': 'Drag the pencil to the 5cm mark to set the radius.',
    's2_step2_out': 'Compass radius locked at 5cm.',
    's2_step3_task': 'Drag the compass tip to point C.',
    's2_step3_out': 'Compass placed at center C.',
    's2_step4_task': 'Drag the pencil to draw a full circle.',
    's2_step4_out': 'A 5cm radius circle is drawn.',
    's2_hud1': 'Drag the compass tip to the 0cm mark.',
    's2_hud2': 'Drag the pencil to exactly 5cm.',
    's2_hud3': 'Drag the compass tip to center point C.',
    's2_hud4': 'Drag the pencil to draw the circle.',

    's3_title': '3. Concentric Creations',
    's3_obj':
        'Recreate a simple artwork of three concentric circles, reinforcing the concept of a shared center.',
    's3_step1_task': 'Use the ruler to set the compass radius to 3cm.',
    's3_step1_out': 'Radius set to 3cm.',
    's3_step2_task': 'Drag compass tip to center O and draw a circle.',
    's3_step2_out': 'First concentric circle drawn.',
    's3_step3_task': 'Set compass radius to 5cm using the ruler.',
    's3_step3_out': 'Radius set to 5cm.',
    's3_step4_task': 'Draw a second circle at center O.',
    's3_step4_out': 'Second concentric circle drawn.',
    's3_step5_task': 'Set radius to 7cm and draw the final circle at center O.',
    's3_step5_out': 'All three concentric circles drawn.',
    's3_hud1': 'Set the compass to 3cm on the ruler.',
    's3_hud2': 'Draw the 3cm circle at center O.',
    's3_hud3': 'Set the compass to 5cm.',
    's3_hud4': 'Draw the 5cm circle at center O.',
    's3_hud5': 'Set to 7cm and draw the final circle.',

    's4_title': '4. The Artist\'s Eye',
    's4_obj':
        'Recreate the "Eyes" artwork by discovering the correct center points and radii for the arcs.',
    's4_step1_task':
        'Find the center point for the top arc on the lower guideline. Radius is 3cm. Draw it.',
    's4_step1_out': 'Top arc matches the target.',
    's4_step2_task':
        'Find the center for the bottom arc on the upper guideline. Radius is 3cm. Draw it.',
    's4_step2_out': 'Bottom arc matches. The eye is complete.',
    's4_hud1':
        'Use the ruler to set radius to 3cm. Drag tip to bottom line and draw top arc.',
    's4_hud2': 'Drag tip to top line and draw bottom arc.',

    's5_title': '5. Ride the Wavy Wave',
    's5_obj':
        'Construct a continuous wave pattern using two semi-circles on a given line segment.',
    's5_step1_task':
        'Set radius to 2cm. Place tip at midpoint of AX (-4cm mark) and draw top semicircle.',
    's5_step1_out': 'First semi-circle drawn over AX.',
    's5_step2_task':
        'Place tip at midpoint of XB (4cm mark) and draw bottom semicircle.',
    's5_step2_out': 'Second semi-circle completes the wave.',
    's5_hud1': 'Set radius to 2cm. Draw top semicircle from A to X.',
    's5_hud2': 'Draw bottom semicircle from X to B.',
  },
  'hi': {
    'shutterTitle': 'कम्पास और वृत्त निर्माण का परिचय',
    'appTitle': 'कम्पास और वृत्त निर्माण',
    'appSubtitle': 'कक्षा 6 ',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'settings': 'सेटिंग्स',
    'theme': 'थीम',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'doneBtn': 'पूर्ण',
    'learnLbl': 'उद्देश्य:',
    'closeBtn': 'बंद करें',
    'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
    'resetBtn': 'रीसेट करें',
    'finishLab': 'समाप्त करें',
    'nextScenario': 'अगला परिदृश्य',
    'labCompleted': 'लैब पूर्ण!',
    'finalDesc':
        'आपने सफलतापूर्वक कम्पास का उपयोग करके वृत्त बनाना सीख लिया है!',

    's1_title': '1. समान दूरी का जादू',
    's1_obj':
        'समझें कि एक वृत्त उन सभी बिंदुओं का संग्रह है जो एक केंद्र से समान दूरी पर होते हैं।',
    's1_step1_task':
        'मैजिक वांड का उपयोग करने के लिए टैप करें। यह P से 4cm दूर बिंदु लगाता है।',
    's1_step1_out': '4cm दूर एक बिंदु रखा गया है।',
    's1_step2_task': 'विभिन्न दिशाओं में 15 बार और टैप करें।',
    's1_step2_out': 'बिंदु एक वृत्त की रूपरेखा बनाते हैं।',
    's1_step3_task': 'कैनवास पर "Draw Circle" बटन पर टैप करें।',
    's1_step3_out': 'एक पूर्ण वृत्त खींचा गया है।',
    's1_step4_task': 'कम्पास की नोक को बिंदु P पर खींचें।',
    's1_step4_out': 'कम्पास केंद्र पर रखा गया है।',
    's1_step5_task': 'कम्पास की पेंसिल को एक पूर्ण वृत्त में खींचें।',
    's1_step5_out': 'कम्पास पूरी तरह से आकार का पता लगाता है।',
    's1_hud1': 'P से 4cm पर पहला बिंदु लगाने के लिए टैप करें।',
    's1_hud2': 'रूपरेखा बनाने के लिए और बिंदु टैप करें।',
    's1_hud3': '"Draw Circle" पर टैप करें।',
    's1_hud4': 'कम्पास की नोक को बिंदु P पर लाएं।',
    's1_hud5': 'वृत्त खींचने के लिए पेंसिल को खींचें।',

    's2_title': '2. शासक और कम्पास',
    's2_obj':
        'रूलर का उपयोग करके कम्पास को एक विशिष्ट त्रिज्या पर सेट करना सीखें।',
    's2_step1_task': 'कम्पास की नोक को रूलर पर 0cm के निशान पर खींचें।',
    's2_step1_out': 'नोक 0cm पर स्नैप हो जाती है।',
    's2_step2_task':
        'त्रिज्या सेट करने के लिए पेंसिल को 5cm के निशान पर खींचें।',
    's2_step2_out': 'कम्पास त्रिज्या 5cm पर लॉक हो गई।',
    's2_step3_task': 'कम्पास की नोक को बिंदु C पर खींचें।',
    's2_step3_out': 'कम्पास केंद्र C पर रखा गया।',
    's2_step4_task': 'पूर्ण वृत्त खींचने के लिए पेंसिल को खींचें।',
    's2_step4_out': '5cm त्रिज्या का वृत्त खींचा गया है।',
    's2_hud1': 'कम्पास की नोक को 0cm पर लाएं।',
    's2_hud2': 'पेंसिल को ठीक 5cm तक खींचें।',
    's2_hud3': 'कम्पास की नोक को केंद्र C पर लाएं।',
    's2_hud4': 'वृत्त खींचने के लिए पेंसिल को खींचें।',

    's3_title': '3. संकेंद्रित रचनाएँ',
    's3_obj':
        'साझा केंद्र की अवधारणा को पुष्ट करते हुए तीन वृत्तों की कलाकृति बनाएं।',
    's3_step1_task': 'रूलर का उपयोग करके कम्पास को 3cm पर सेट करें।',
    's3_step1_out': 'त्रिज्या 3cm पर सेट।',
    's3_step2_task': 'कम्पास को O पर लाएं और एक वृत्त खींचें।',
    's3_step2_out': 'पहला वृत्त खींचा गया।',
    's3_step3_task': 'रूलर का उपयोग करके कम्पास को 5cm पर सेट करें।',
    's3_step3_out': 'त्रिज्या 5cm पर सेट।',
    's3_step4_task': 'O पर दूसरा वृत्त खींचें।',
    's3_step4_out': 'दूसरा वृत्त खींचा गया।',
    's3_step5_task': 'त्रिज्या 7cm सेट करें और O पर अंतिम वृत्त खींचें।',
    's3_step5_out': 'तीनों वृत्त खींचे गए।',
    's3_hud1': 'कम्पास को रूलर पर 3cm पर सेट करें।',
    's3_hud2': 'केंद्र O पर 3cm का वृत्त खींचें।',
    's3_hud3': 'कम्पास को 5cm पर सेट करें।',
    's3_hud4': 'केंद्र O पर 5cm का वृत्त खींचें।',
    's3_hud5': '7cm पर सेट करें और अंतिम वृत्त खींचें।',

    's4_title': '4. कलाकार की आँख',
    's4_obj':
        'चापों के लिए सही केंद्र बिंदु और त्रिज्या खोजकर "आँखें" कलाकृति बनाएँ।',
    's4_step1_task':
        'निचली रेखा पर शीर्ष चाप के लिए केंद्र खोजें। त्रिज्या 3cm है।',
    's4_step1_out': 'शीर्ष चाप मेल खाता है।',
    's4_step2_task':
        'ऊपरी रेखा पर निचले चाप के लिए केंद्र खोजें। त्रिज्या 3cm है।',
    's4_step2_out': 'निचला चाप मेल खाता है।',
    's4_hud1':
        'त्रिज्या 3cm सेट करें। नोक को निचली रेखा पर लाएं और चाप खींचें।',
    's4_hud2': 'नोक को ऊपरी रेखा पर लाएं और निचला चाप खींचें।',

    's5_title': '5. लहर की सवारी',
    's5_obj': 'दो अर्धवृत्तों का उपयोग करके एक सतत लहर पैटर्न बनाएँ।',
    's5_step1_task':
        'त्रिज्या 2cm सेट करें। नोक को AX के मध्य (-4cm) पर रखें और शीर्ष अर्धवृत्त खींचें।',
    's5_step1_out': 'पहला अर्धवृत्त खींचा गया।',
    's5_step2_task':
        'नोक को XB के मध्य (4cm) पर रखें और निचला अर्धवृत्त खींचें।',
    's5_step2_out': 'दूसरा अर्धवृत्त लहर पूरी करता है।',
    's5_hud1': 'त्रिज्या 2cm सेट करें। A से X तक शीर्ष अर्धवृत्त खींचें।',
    's5_hud2': 'X से B तक निचला अर्धवृत्त खींचें।',
  },
};

class ScenarioConfig {
  final String title;
  final String objective;
  final List<Map<String, String>> steps;
  ScenarioConfig(this.title, this.objective, this.steps);
}

// ---------------------------------------------------------
// MAIN LAB WIDGET
// ---------------------------------------------------------

class Cl6M_Ch8_A1_CompassCircleConstruction extends StatefulWidget {
  const Cl6M_Ch8_A1_CompassCircleConstruction({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch8_A1_CompassCircleConstruction> createState() =>
      _Cl6M_Ch8_A1_CompassCircleConstructionState();
}

class _Cl6M_Ch8_A1_CompassCircleConstructionState
    extends State<Cl6M_Ch8_A1_CompassCircleConstruction>
    with SingleTickerProviderStateMixin {
  // -- View Mode & System --
  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  double _sidebarWidthRatio = 0.35;
  String _lang = 'en';

  // -- Canvas Control --
  final GlobalKey _canvasKey = GlobalKey();
  double _zoom = 1.0;
  double _baseZoom = 1.0;
  double _panX = 0;
  double _panY = 0;
  bool _isPanningCanvas = false;

  // -- Audio Engine --
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();

  // -- Animation & Gameloop --
  late AnimationController _ticker;

  // -- Scenario State --
  int _scenario = 1;
  int _step = 0;

  // Tools & Simulation State
  CompassTool _compass = CompassTool();
  List<WorldPoint> _currentStroke = [];
  final List<UserArc> _userArcs = [];

  // Scenario 1 specifics
  final List<WorldPoint> _s1Points = [];
  bool _s1CircleDrawn = false;
  bool _s1Traced = false;
  double _s1TraceAngle = 0;
  double _s1TraceStart = 0;
  double? _s1ActiveLineAngle;
  double _s1ActiveLineOpacity = 0;

  // Scenario 2 specifics
  bool _s2CircleDrawn = false;

  // Scenario 3 specifics
  Map<int, bool> _s3Circles = {3: false, 5: false, 7: false};

  // -------------------------------------------------------
  // LIFECYCLE
  // -------------------------------------------------------

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _ticker.addListener(() {
      setState(() {
        if (_s1ActiveLineOpacity > 0) {
          _s1ActiveLineOpacity -= 0.02;
          if (_s1ActiveLineOpacity < 0) _s1ActiveLineOpacity = 0;
        }
      });
    });
    _ticker.repeat();

    _loadScenario(1);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _errorPlayer.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // -------------------------------------------------------
  // AUDIO METHODS
  // -------------------------------------------------------

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
    await _errorPlayer.stop();
    await _errorPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  // -------------------------------------------------------
  // HELPER LOGIC
  // -------------------------------------------------------

  String t(String key) {
    return i18n[_lang]?[key] ?? key;
  }

  void _toggleLanguage() {
    playClick();
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  ScenarioConfig _getScenarioConfig(int id) {
    int numSteps = 0;
    if (id == 1) {
      numSteps = 5;
    } else if (id == 2) {
      numSteps = 4;
    } else if (id == 3) {
      numSteps = 5;
    } else if (id == 4) {
      numSteps = 2;
    } else if (id == 5) {
      numSteps = 2;
    }

    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'hud': t('s${id}_hud$i'),
        'task': t('s${id}_step${i}_task'),
        'outcome': t('s${id}_step${i}_out'),
      });
    }
    return ScenarioConfig(t('s${id}_title'), t('s${id}_obj'), steps);
  }

  void _loadScenario(int id) {
    playDropdown();
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _compass = CompassTool();
      _currentStroke.clear();
      _userArcs.clear();
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;

      if (_scenario == 1) {
        _s1Points.clear();
        _s1CircleDrawn = false;
        _s1Traced = false;
        _compass.r = 160;
        _compass.cx = 300;
        _compass.cy = 300;
      }
      if (_scenario == 2) {
        _s2CircleDrawn = false;
        _compass.cx = -150;
        _compass.cy = 50;
      }
      if (_scenario == 3) {
        _s3Circles = {3: false, 5: false, 7: false};
        _compass.cx = -150;
        _compass.cy = 50;
        _compass.r = 80;
      }
      if (_scenario == 4) {
        _compass.cx = 0;
        _compass.cy = 150;
        _compass.r = 80;
      }
      if (_scenario == 5) {
        _compass.cx = 0;
        _compass.cy = 150;
        _compass.r = 80;
      }
    });
  }

  void _advanceStep() {
    playPageOpen();
    setState(() {
      _step++;
    });
  }

  void _checkScenarioSuccess() {
    final conf = _getScenarioConfig(_scenario);
    setState(() {
      _step = conf.steps.length;
    });
  }

  void _handleReset() {
    playError();
    setState(() {
      _loadScenario(1);
    });
  }

  void _undoLastArc() {
    if (_userArcs.isNotEmpty) {
      playError();
      setState(() {
        _userArcs.removeLast();
      });
    }
  }

  // -------------------------------------------------------
  // GESTURES & INTERACTION
  // -------------------------------------------------------

  WorldPoint _screenToWorld(Offset globalPos) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return WorldPoint(0, 0);
    final local = box.globalToLocal(globalPos);

    double cx = box.size.width / 2;
    double cy = box.size.height / 2;

    double worldX = (local.dx - cx - _panX) / _zoom;
    double worldY = (local.dy - cy - _panY) / _zoom;
    return WorldPoint(worldX, worldY);
  }

  bool _hitTestCircle(double cx, double cy, double r, WorldPoint pt) {
    return math.sqrt(math.pow(pt.x - cx, 2) + math.pow(pt.y - cy, 2)) <= r;
  }

  bool _hitTestRect(double x, double y, double w, double h, WorldPoint pt) {
    return pt.x > x && pt.x < x + w && pt.y > y && pt.y < y + h;
  }

  // Touch tracking offsets
  Offset? _lastPanFocal;

  // Handles Instant Clicking (Wand tool & Draw button)
  void _onTapDown(TapDownDetails details) {
    if (_scenario == 1 && _step < 3) {
      final pt = _screenToWorld(details.globalPosition);

      // Draw Circle Button check
      if (_step == 2 && _hitTestRect(-60, 200, 120, 45, pt)) {
        setState(() {
          _s1CircleDrawn = true;
          _compass.cx = 200;
          _compass.cy = 100;
          _compass.angle = math.pi / 4;
        });
        playClick();
        _advanceStep();
        return;
      }

      // Magic Wand Point Placement
      playClick();
      double angle = math.atan2(pt.y, pt.x);
      double targetX = 160 * math.cos(angle);
      double targetY = 160 * math.sin(angle);

      setState(() {
        _s1Points.add(WorldPoint(targetX, targetY));
        _s1ActiveLineAngle = angle;
        _s1ActiveLineOpacity = 1.0;
      });

      if (_step == 0) {
        _advanceStep();
      } else if (_step == 1 && _s1Points.length >= 15) {
        _advanceStep();
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _lastPanFocal = details.localFocalPoint;
    _baseZoom = _zoom;
    _isPanningCanvas = false;

    if (details.pointerCount > 1) {
      _isPanningCanvas = true;
      return;
    }

    final pt = _screenToWorld(details.focalPoint);

    // Compass Interactions
    double px = _compass.cx + _compass.r * math.cos(_compass.angle);
    double py = _compass.cy + _compass.r * math.sin(_compass.angle);

    if (_hitTestCircle(_compass.cx, _compass.cy, 35 / _zoom, pt)) {
      playClick(); // Grab compass tip
      setState(() {
        _compass.draggingTip = true;
      });
    } else if (_hitTestCircle(px, py, 35 / _zoom, pt)) {
      playClick(); // Grab compass pencil
      setState(() {
        _compass.draggingPencil = true;
        _currentStroke = [WorldPoint(px, py)];
      });

      if (_scenario == 1 &&
          _step == 4 &&
          math.sqrt(_compass.cx * _compass.cx + _compass.cy * _compass.cy) <
              10) {
        _s1TraceStart = _compass.angle;
        _s1TraceAngle = _compass.angle;
        _s1Traced = true;
      }
    } else {
      _isPanningCanvas = true;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount > 1) {
      // Switch to multi-touch pan/zoom, overriding compass drags to prevent accidents
      _compass.draggingTip = false;
      _compass.draggingPencil = false;
      _isPanningCanvas = true;
    }

    if (_isPanningCanvas) {
      if (_lastPanFocal != null) {
        final delta = details.localFocalPoint - _lastPanFocal!;
        setState(() {
          _panX += delta.dx;
          _panY += delta.dy;
          if (details.scale != 1.0) {
            _zoom = (_baseZoom * details.scale).clamp(0.4, 3.5);
          }
        });
      }
      _lastPanFocal = details.localFocalPoint;
      return;
    }

    final pt = _screenToWorld(details.focalPoint);

    if (_compass.draggingTip) {
      setState(() {
        _compass.cx = pt.x;
        _compass.cy = pt.y;

        // Snapping Logic
        if (_scenario == 1 &&
            _step == 3 &&
            math.sqrt(_compass.cx * _compass.cx + _compass.cy * _compass.cy) <
                20) {
          _compass.cx = 0;
          _compass.cy = 0;
          _compass.draggingTip = false;
          playPageOpen();
          _advanceStep();
        }

        double rulerY = (_scenario == 2) ? 180 : (_scenario == 3 ? 260 : 220);
        if (_scenario >= 2 &&
            _scenario <= 5 &&
            _hitTestRect(
              -320,
              rulerY - 20,
              640,
              100,
              WorldPoint(_compass.cx, _compass.cy),
            )) {
          if ((_compass.cx - (-300)).abs() < 30) {
            _compass.cx = -300;
            _compass.cy = rulerY;
            if (_scenario == 2 && _step == 0) {
              _advanceStep();
              _compass.draggingTip = false;
            }
          }
        }
        if (_scenario == 2 &&
            _step == 2 &&
            math.sqrt(
                  math.pow(_compass.cx, 2) + math.pow(_compass.cy - (-50), 2),
                ) <
                20) {
          _compass.cx = 0;
          _compass.cy = -50;
          _advanceStep();
          _compass.draggingTip = false;
        }
        if (_scenario == 3 &&
            math.sqrt(
                  math.pow(_compass.cx, 2) + math.pow(_compass.cy - (-50), 2),
                ) <
                20) {
          _compass.cx = 0;
          _compass.cy = -50;
        }
        if (_scenario == 4) {
          if ((_compass.cy - 40).abs() < 15) _compass.cy = 40;
          if ((_compass.cy - (-40)).abs() < 15) _compass.cy = -40;
        }
        if (_scenario == 5 && (_compass.cy - (-40)).abs() < 15) {
          _compass.cy = -40;
          if ((_compass.cx - (-80)).abs() < 15) _compass.cx = -80;
          if ((_compass.cx - 80).abs() < 15) _compass.cx = 80;
        }
      });
      return;
    }

    if (_compass.draggingPencil) {
      setState(() {
        double dx = pt.x - _compass.cx;
        double dy = pt.y - _compass.cy;
        double newAngle = math.atan2(dy, dx);
        double newDist = math.sqrt(dx * dx + dy * dy);

        // Ruler interaction
        double rulerY = (_scenario == 2) ? 180 : (_scenario == 3 ? 260 : 220);
        if ((_compass.cy - rulerY).abs() < 50 &&
            (_compass.cx - (-300)).abs() < 10) {
          if (_scenario == 2 && _step == 1 && (newDist - 200).abs() < 15) {
            _compass.r = 200;
            _compass.angle = 0;
            _compass.draggingPencil = false;
            _advanceStep();
          } else if (_scenario == 3 &&
              _step == 0 &&
              (newDist - 120).abs() < 15) {
            _compass.r = 120;
            _compass.angle = 0;
            _compass.draggingPencil = false;
            _advanceStep();
          } else if (_scenario == 3 &&
              _step == 2 &&
              (newDist - 200).abs() < 15) {
            _compass.r = 200;
            _compass.angle = 0;
            _compass.draggingPencil = false;
            _advanceStep();
          } else if (_scenario == 3 &&
              _step == 4 &&
              (newDist - 280).abs() < 15) {
            _compass.r = 280;
            _compass.angle = 0;
          } else if (_scenario == 4 && (newDist - 120).abs() < 15) {
            _compass.r = 120;
            _compass.angle = 0;
          } else if (_scenario == 5 && (newDist - 80).abs() < 15) {
            _compass.r = 80;
            _compass.angle = 0;
          } else {
            _compass.r = math.max(10, newDist);
            _compass.angle = 0;
          }
          return;
        }

        _compass.angle = newAngle;
        double px = _compass.cx + _compass.r * math.cos(newAngle);
        double py = _compass.cy + _compass.r * math.sin(newAngle);
        _currentStroke.add(WorldPoint(px, py));
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _lastPanFocal = null;

    if (_compass.draggingTip) {
      setState(() {
        _compass.draggingTip = false;
      });
    }

    // Evaluate Circle & Arc Completions ON RELEASE
    if (_compass.draggingPencil) {
      setState(() {
        _compass.draggingPencil = false;

        // Ensure user actually traced a significant distance (at least ~20 frames of points)
        if (_currentStroke.length > 15) {
          // Scenario 1 Completion
          if (_scenario == 1 && _step == 4 && _s1Traced) {
            playClick();
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
          }

          // Scenario 2 Completion
          if (_scenario == 2 &&
              _step == 3 &&
              math.sqrt(
                    math.pow(_compass.cx, 2) + math.pow(_compass.cy - (-50), 2),
                  ) <
                  20) {
            _s2CircleDrawn = true;
            playClick();
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
          }

          // Scenario 3 Completions
          if (_scenario == 3 &&
              math.sqrt(
                    math.pow(_compass.cx, 2) + math.pow(_compass.cy - (-50), 2),
                  ) <
                  20) {
            if (_step == 1 && (_compass.r - 120).abs() < 15) {
              _s3Circles[3] = true;
              playClick();
              _advanceStep();
            } else if (_step == 3 && (_compass.r - 200).abs() < 15) {
              _s3Circles[5] = true;
              playClick();
              _advanceStep();
            } else if (_step == 4 && (_compass.r - 280).abs() < 15) {
              _s3Circles[7] = true;
              playClick();
              _advanceStep();
              Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
            }
          }
        }

        // Process Arc drawing evaluation for S4 and S5
        if (_currentStroke.length > 5 && (_scenario == 4 || _scenario == 5)) {
          WorldPoint startP = _currentStroke.first;
          WorldPoint endP = _currentStroke.last;
          double startAng = math.atan2(
            startP.y - _compass.cy,
            startP.x - _compass.cx,
          );
          double endAng = math.atan2(
            endP.y - _compass.cy,
            endP.x - _compass.cx,
          );

          UserArc newArc = UserArc(
            cx: _compass.cx,
            cy: _compass.cy,
            r: _compass.r,
            startAngle: startAng,
            endAngle: endAng,
          );

          if (_scenario == 4) {
            if (_step == 0 &&
                (_compass.cx).abs() < 20 &&
                (_compass.cy - 40).abs() < 20 &&
                (_compass.r - 120).abs() < 20) {
              newArc.cx = 0;
              newArc.cy = 40;
              newArc.r = 120;
              newArc.startAngle = -math.pi * 5 / 6;
              newArc.endAngle = -math.pi / 6;
              newArc.isTargetHit = true;
              _advanceStep();
            }
            if (_step == 1 &&
                (_compass.cx).abs() < 20 &&
                (_compass.cy - (-40)).abs() < 20 &&
                (_compass.r - 120).abs() < 20) {
              newArc.cx = 0;
              newArc.cy = -40;
              newArc.r = 120;
              newArc.startAngle = math.pi / 6;
              newArc.endAngle = math.pi * 5 / 6;
              newArc.isTargetHit = true;
              _advanceStep();
              Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
            }
          } else if (_scenario == 5) {
            if (_step == 0 &&
                (_compass.cx - (-80)).abs() < 20 &&
                (_compass.cy - (-40)).abs() < 20 &&
                (_compass.r - 80).abs() < 20) {
              newArc.cx = -80;
              newArc.cy = -40;
              newArc.r = 80;
              newArc.startAngle = math.pi;
              newArc.endAngle = 0;
              newArc.isTargetHit = true;
              _advanceStep();
            }
            if (_step == 1 &&
                (_compass.cx - 80).abs() < 20 &&
                (_compass.cy - (-40)).abs() < 20 &&
                (_compass.r - 80).abs() < 20) {
              newArc.cx = 80;
              newArc.cy = -40;
              newArc.r = 80;
              newArc.startAngle = 0;
              newArc.endAngle = math.pi;
              newArc.isTargetHit = true;
              _advanceStep();
              Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
            }
          }
          _userArcs.add(newArc);
        }

        // Reset stroke visual
        _currentStroke.clear();
      });
    }
  }

  // -------------------------------------------------------
  // UI BUILDERS
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
          background: Color(0xFF0F172A),
        ),
      ),
      home: _buildHome(context),
    );
  }

  Widget _buildHome(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = math.max(300, screenWidth * _sidebarWidthRatio);
    if (!_isSidebarOpen) sidebarWidth = 0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: 0,
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: _buildCanvasArea(),
            ),

            // LEFT SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: 0,
              width: _isSidebarOpen ? sidebarWidth : 0,
              child: _buildSidebar(),
            ),

            // SIDEBAR RESIZER (DRAG HANDLE)
            if (_isSidebarOpen)
              Positioned(
                left: sidebarWidth - 10, // Slight overlap
                top: 0,
                bottom: 0,
                width: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      double newRatio =
                          (sidebarWidth + details.delta.dx) / screenWidth;
                      _sidebarWidthRatio = newRatio.clamp(0.25, 0.6);
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Container(
                      width: 20,
                      color: Colors.transparent,
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
              ),

            // MENU TOGGLE
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B),
                  child: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    playClick();
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                ),
              ),
            ),

            // SUCCESS POPUP OVERLAY
            if (_getScenarioConfig(_scenario).steps.length == _step &&
                _scenario == 5)
              _buildSuccessPopup(),

            // CURTAIN
            if (_showCurtain) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Stack(
      children: [
        // Main CustomPainter wrapped in GestureDetector
        Positioned.fill(
          child: GestureDetector(
            key: _canvasKey,
            onTapDown: _onTapDown, // Handles Instant Clicking
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: ClipRect(
              child: CustomPaint(
                painter: LabPainter(
                  scenario: _scenario,
                  step: _step,
                  zoom: _zoom,
                  panX: _panX,
                  panY: _panY,
                  compass: _compass,
                  currentStroke: _currentStroke,
                  userArcs: _userArcs,
                  s1Points: _s1Points,
                  s1CircleDrawn: _s1CircleDrawn,
                  s1Traced: _s1Traced,
                  s1TraceStart: _s1TraceStart,
                  s1TraceAngle: _s1TraceAngle,
                  s1ActiveLineAngle: _s1ActiveLineAngle,
                  s1ActiveLineOpacity: _s1ActiveLineOpacity,
                  s2CircleDrawn: _s2CircleDrawn,
                  s3Circles: _s3Circles,
                ),
              ),
            ),
          ),
        ),

        // HUD (Bottom Center)
        _buildHUD(),

        // NEXT SCENARIO BUTTON ON CANVAS
        if (_step == _getScenarioConfig(_scenario).steps.length &&
            _scenario < 5)
          Positioned(
            bottom: 30,
            right: 30,
            child: IgnorePointer(
              ignoring: _showCurtain,
              child: AnimatedOpacity(
                opacity: _showCurtain ? 0 : 1,
                duration: const Duration(milliseconds: 500),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Colors.indigoAccent.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    elevation: 10,
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: Text(
                    t('nextScenario'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    playClick();
                    _loadScenario(_scenario + 1);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHUD() {
    final conf = _getScenarioConfig(_scenario);
    if (_step >= conf.steps.length) return const SizedBox.shrink();

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: _showCurtain ? 0 : 1,
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.95),
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      conf.steps[_step]['hud']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSidebar() {
    final conf = _getScenarioConfig(_scenario);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 66.0,
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER ROW (Icon, Title, Subtitle)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.architecture,
                  color: Color(0xFF6366F1),
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('appTitle'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // TOGGLE CONTROLS (Lang & Refresh/Undo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.language,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    _lang.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: _toggleLanguage,
                ),
                Row(
                  children: [
                    if (_userArcs.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.undo,
                          color: Colors.orangeAccent,
                        ),
                        onPressed: _undoLastArc,
                        tooltip: 'Undo',
                      ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.redAccent),
                      onPressed: _handleReset,
                      tooltip: t('resetBtn'),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 32),

            // SCENARIO DROPDOWN
            Text(
              t('selectScenario'),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _scenario,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0F172A),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white54,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: [1, 2, 3, 4, 5]
                      .map(
                        (id) => DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            t('s${id}_title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) _loadScenario(val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // OBJECTIVE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
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
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    conf.objective,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // STEPS
            ...List.generate(
              conf.steps.length,
              (index) => _buildStepCard(index, conf.steps[index]),
            ),

            // FOOTER
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              width: double.infinity,
              child: const Text(
                "© ZeroScienceLab | Fall in love with math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(int index, Map<String, String> stepMap) {
    bool isCompleted = index < _step;
    bool isCurrent = index == _step;

    Color bgColor = isCurrent
        ? const Color(0xFF6366F1).withOpacity(0.15)
        : (isCompleted
              ? Colors.green.withOpacity(0.05)
              : Colors.white.withOpacity(0.02));
    Color borderColor = isCurrent
        ? const Color(0xFF6366F1)
        : (isCompleted ? Colors.green.withOpacity(0.5) : Colors.transparent);
    Color textColor = isCurrent || isCompleted ? Colors.white : Colors.white54;

    return Container(
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
                    color: isCurrent
                        ? const Color(0xFF6366F1)
                        : Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
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
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Task: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      TextSpan(text: stepMap['task']),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Outcome: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: stepMap['outcome']),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurtain() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.architecture,
                      size: 80,
                      color: Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t('shutterTitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t('appSubtitle'),
                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    const SizedBox(height: 48),
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
                        elevation: 10,
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
                        setState(() {
                          _showCurtain = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopup() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flag_circle,
                  size: 80,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  t('summaryTitle'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t('finalDesc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    t('finishLab'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    playClick();
                    _handleReset();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM PAINTER (THE ENGINE)
// ---------------------------------------------------------

class LabPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;

  final CompassTool compass;
  final List<WorldPoint> currentStroke;
  final List<UserArc> userArcs;

  // S1
  final List<WorldPoint> s1Points;
  final bool s1CircleDrawn;
  final bool s1Traced;
  final double s1TraceStart;
  final double s1TraceAngle;
  final double? s1ActiveLineAngle;
  final double s1ActiveLineOpacity;

  // S2
  final bool s2CircleDrawn;

  // S3
  final Map<int, bool> s3Circles;

  LabPainter({
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.compass,
    required this.currentStroke,
    required this.userArcs,
    required this.s1Points,
    required this.s1CircleDrawn,
    required this.s1Traced,
    required this.s1TraceStart,
    required this.s1TraceAngle,
    required this.s1ActiveLineAngle,
    required this.s1ActiveLineOpacity,
    required this.s2CircleDrawn,
    required this.s3Circles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawColor(const Color(0xFF0F172A), BlendMode.src);

    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _renderS1(canvas);
    } else if (scenario == 2) {
      _renderS2(canvas);
    } else if (scenario == 3) {
      _renderS3(canvas);
    } else if (scenario == 4) {
      _renderS4(canvas);
    } else if (scenario == 5) {
      _renderS5(canvas);
    }

    canvas.restore();
  }

  // --- DRAWING HELPERS ---

  void _drawPoint(Canvas canvas, double x, double y, String label) {
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x, y), 5, paint);

    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 20, y - 20));
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    var path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);
    Path dashPath = Path();
    const double dashWidth = 8.0;
    const double dashSpace = 8.0;
    double distance = 0.0;
    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  void _drawRuler(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);

    // Base Ruler body
    final RRect rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 640, 60),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF334155));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    for (int i = 0; i <= 150; i++) {
      double px = 20 + i * 4.0;
      if (i % 10 == 0) {
        canvas.drawLine(Offset(px, 0), Offset(px, 20), linePaint);
        final tp = TextPainter(
          text: TextSpan(
            text: "${i ~/ 10}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(px - tp.width / 2, 25));
      } else if (i % 5 == 0) {
        canvas.drawLine(Offset(px, 0), Offset(px, 15), linePaint);
      } else {
        canvas.drawLine(Offset(px, 0), Offset(px, 10), linePaint);
      }
    }
    canvas.restore();
  }

  void _drawCompass(
    Canvas canvas,
    double tipX,
    double tipY,
    double pencilX,
    double pencilY,
    bool isLocked,
  ) {
    double dx = pencilX - tipX;
    double dy = pencilY - tipY;
    double dist = math.sqrt(dx * dx + dy * dy);
    double angle = math.atan2(dy, dx);
    double midX = tipX + dx / 2;
    double midY = tipY + dy / 2;
    double hingeHeight = math.max(100, 250 - dist * 0.4);
    double hingeX = midX - hingeHeight * math.sin(angle);
    double hingeY = midY + hingeHeight * math.cos(angle);

    // Legs
    final legPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(hingeX, hingeY), Offset(tipX, tipY), legPaint);
    canvas.drawLine(
      Offset(hingeX, hingeY),
      Offset(pencilX, pencilY),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Hinge
    final RRect hingeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(hingeX - 12, hingeY - 18, 24, 36),
      const Radius.circular(6),
    );
    canvas.drawRRect(hingeRect, Paint()..color = const Color(0xFF334155));
    canvas.drawRRect(
      hingeRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(hingeX, hingeY),
      4,
      Paint()..color = isLocked ? Colors.redAccent : Colors.greenAccent,
    );

    // Metal Tip
    canvas.drawLine(
      Offset(tipX, tipY),
      Offset(
        tipX + 5 * math.cos(angle + math.pi / 2),
        tipY + 5 * math.sin(angle + math.pi / 2),
      ),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3,
    );
    canvas.drawCircle(Offset(tipX, tipY), 4, Paint()..color = Colors.white);

    // Pencil holder & tip
    canvas.save();
    canvas.translate(
      pencilX - 8 * math.cos(angle) - 6 * math.sin(angle),
      pencilY - 8 * math.sin(angle) + 6 * math.cos(angle),
    );
    canvas.rotate(angle - math.pi / 2);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 16, 20),
      Paint()..color = Colors.amber,
    );
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 16, 20),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();

    canvas.drawCircle(
      Offset(pencilX, pencilY),
      4,
      Paint()..color = const Color(0xFF334155),
    );
  }

  void _drawStroke(Canvas canvas, List<WorldPoint> stroke, Color color) {
    if (stroke.length < 2) return;
    Path path = Path()..moveTo(stroke[0].x, stroke[0].y);
    for (int i = 1; i < stroke.length; i++) {
      path.lineTo(stroke[i].x, stroke[i].y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawIdealArc(Canvas canvas, UserArc arc) {
    final rect = Rect.fromCircle(center: Offset(arc.cx, arc.cy), radius: arc.r);
    double start = arc.startAngle;
    double sweep = arc.endAngle - arc.startAngle;

    // Normalize sweep for shortest path
    if (sweep > math.pi) sweep -= 2 * math.pi;
    if (sweep < -math.pi) sweep += 2 * math.pi;

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = arc.isTargetHit ? Colors.greenAccent : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    if (arc.isTargetHit) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = Colors.greenAccent.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }

  void _drawTargetThumbnail(
    Canvas canvas,
    double x,
    double y,
    Function(Canvas, Paint) drawFunc,
  ) {
    canvas.save();
    canvas.translate(x, y);
    final RRect rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 100, 100),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final paint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    drawFunc(canvas, paint);

    final tp = TextPainter(
      text: const TextSpan(
        text: "Target",
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(50 - tp.width / 2, 80));

    canvas.restore();
  }

  double _getArcDist(double ang1, double ang2) {
    double diff = (ang1 - ang2).abs() % (math.pi * 2);
    return diff > math.pi ? math.pi * 2 - diff : diff;
  }

  // --- SCENARIO RENDERS ---

  void _renderS1(Canvas canvas) {
    _drawPoint(canvas, 0, 0, 'P');

    // PERMANENT FAINT LINES
    // Connecting all placed wand points back to the center point P to show equidistance
    final faintLinePaint = Paint()
      ..color = const Color(0xFF94A3B8).withOpacity(0.2)
      ..strokeWidth = 1.5;
    for (var p in s1Points) {
      _drawDashedLine(
        canvas,
        const Offset(0, 0),
        Offset(p.x, p.y),
        faintLinePaint,
      );
    }

    // ACTIVE HIGHLIGHT LINE
    if (s1ActiveLineOpacity > 0 && s1ActiveLineAngle != null) {
      double endX = 160 * math.cos(s1ActiveLineAngle!);
      double endY = 160 * math.sin(s1ActiveLineAngle!);
      _drawDashedLine(
        canvas,
        const Offset(0, 0),
        Offset(endX, endY),
        Paint()
          ..color = const Color(0xFF94A3B8).withOpacity(s1ActiveLineOpacity)
          ..strokeWidth = 2,
      );
    }

    final pointPaint = Paint()..color = Colors.white;
    if (!s1CircleDrawn) {
      for (var p in s1Points) {
        canvas.drawCircle(Offset(p.x, p.y), 4, pointPaint);
      }
    } else {
      canvas.drawCircle(
        const Offset(0, 0),
        160,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    if (step == 2) {
      final RRect btnRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-60, 200, 120, 45),
        const Radius.circular(10),
      );
      canvas.drawRRect(btnRect, Paint()..color = const Color(0xFF3B82F6));
      canvas.drawRRect(
        btnRect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final tp = TextPainter(
        text: const TextSpan(
          text: "Draw Circle",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, 222 - tp.height / 2));
    }

    if (step >= 3) {
      if (s1Traced) {
        double sweep = _getArcDist(s1TraceStart, s1TraceAngle);
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(0, 0), radius: 160),
          s1TraceStart,
          sweep,
          false,
          Paint()
            ..color = Colors.redAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }

      double px = compass.cx + compass.r * math.cos(compass.angle);
      double py = compass.cy + compass.r * math.sin(compass.angle);
      _drawCompass(canvas, compass.cx, compass.cy, px, py, true);
    }
  }

  void _renderS2(Canvas canvas) {
    _drawPoint(canvas, 0, -50, 'C');

    if (s2CircleDrawn) {
      canvas.drawCircle(
        const Offset(0, -50),
        200,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final tp = TextPainter(
        text: const TextSpan(
          text: "Radius = 5 cm",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -270));
    }

    _drawRuler(canvas, -320, 180);
    _drawStroke(canvas, currentStroke, Colors.blueAccent);

    double px = compass.cx + compass.r * math.cos(compass.angle);
    double py = compass.cy + compass.r * math.sin(compass.angle);
    _drawCompass(canvas, compass.cx, compass.cy, px, py, step == 3);

    if (compass.draggingPencil && (compass.cy - 180).abs() < 50) {
      _drawMeasurementTooltip(canvas, px, py, compass.r);
    }
  }

  void _renderS3(Canvas canvas) {
    _drawPoint(canvas, 0, -50, 'O');

    _drawTargetThumbnail(canvas, -380, -280, (c, p) {
      c.drawCircle(const Offset(50, 50), 15, p);
      c.drawCircle(const Offset(50, 50), 25, p);
      c.drawCircle(const Offset(50, 50), 35, p);
      c.drawCircle(const Offset(50, 50), 2, Paint()..color = Colors.black);
    });

    _drawRuler(canvas, -320, 260);

    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    if (s3Circles[3] == true) {
      canvas.drawCircle(const Offset(0, -50), 120, circlePaint);
    }
    if (s3Circles[5] == true) {
      canvas.drawCircle(const Offset(0, -50), 200, circlePaint);
    }
    if (s3Circles[7] == true) {
      canvas.drawCircle(const Offset(0, -50), 280, circlePaint);
    }

    _drawStroke(canvas, currentStroke, Colors.white);

    double px = compass.cx + compass.r * math.cos(compass.angle);
    double py = compass.cy + compass.r * math.sin(compass.angle);
    _drawCompass(canvas, compass.cx, compass.cy, px, py, false);

    if (compass.draggingPencil && (compass.cy - 260).abs() < 50) {
      _drawMeasurementTooltip(canvas, px, py, compass.r);
    }
  }

  void _renderS4(Canvas canvas) {
    final guidePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2;
    _drawDashedLine(
      canvas,
      const Offset(-300, 40),
      const Offset(300, 40),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      const Offset(-300, -40),
      const Offset(300, -40),
      guidePaint,
    );

    // FIXED POINTS for compass placement
    _drawPoint(canvas, 0, 40, '');
    _drawPoint(canvas, 0, -40, '');

    _drawRuler(canvas, -320, 220);

    _drawTargetThumbnail(canvas, -380, -280, (c, p) {
      c.drawArc(
        Rect.fromCircle(center: const Offset(50, 70), radius: 30),
        -math.pi * 5 / 6,
        math.pi * 4 / 6,
        false,
        p,
      );
      c.drawArc(
        Rect.fromCircle(center: const Offset(50, 30), radius: 30),
        math.pi / 6,
        math.pi * 4 / 6,
        false,
        p,
      );
    });

    for (var arc in userArcs) {
      _drawIdealArc(canvas, arc);
    }
    _drawStroke(canvas, currentStroke, Colors.blueAccent);

    double px = compass.cx + compass.r * math.cos(compass.angle);
    double py = compass.cy + compass.r * math.sin(compass.angle);
    _drawCompass(canvas, compass.cx, compass.cy, px, py, false);

    if (compass.draggingPencil && (compass.cy - 220).abs() < 50) {
      _drawMeasurementTooltip(canvas, px, py, compass.r);
    }
  }

  void _renderS5(Canvas canvas) {
    canvas.drawLine(
      const Offset(-160, -40),
      const Offset(160, -40),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 4,
    );
    _drawPoint(canvas, -160, -40, 'A');
    _drawPoint(canvas, 160, -40, 'B');
    _drawPoint(canvas, 0, -40, 'X');

    _drawRuler(canvas, -320, 220);

    _drawTargetThumbnail(canvas, -380, -280, (c, p) {
      c.drawArc(
        Rect.fromCircle(center: const Offset(30, 50), radius: 20),
        math.pi,
        math.pi,
        false,
        p,
      );
      c.drawArc(
        Rect.fromCircle(center: const Offset(70, 50), radius: 20),
        0,
        math.pi,
        false,
        p,
      );
      c.drawLine(
        const Offset(10, 50),
        const Offset(90, 50),
        p..strokeWidth = 1,
      );
    });

    for (var arc in userArcs) {
      _drawIdealArc(canvas, arc);
    }
    _drawStroke(canvas, currentStroke, Colors.blueAccent);

    double px = compass.cx + compass.r * math.cos(compass.angle);
    double py = compass.cy + compass.r * math.sin(compass.angle);
    _drawCompass(canvas, compass.cx, compass.cy, px, py, false);

    if (compass.draggingPencil && (compass.cy - 220).abs() < 50) {
      _drawMeasurementTooltip(canvas, px, py, compass.r);
    }
  }

  void _drawMeasurementTooltip(Canvas canvas, double px, double py, double r) {
    String cm = (r / 40).toStringAsFixed(1);
    final RRect tt = RRect.fromRectAndRadius(
      Rect.fromLTWH(px - 30, py - 40, 60, 25),
      const Radius.circular(4),
    );
    canvas.drawRRect(tt, Paint()..color = const Color(0xFF1E293B));
    canvas.drawRRect(
      tt,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: "$cm cm",
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(px - tp.width / 2, py - 35));
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
