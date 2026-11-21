// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Perimeter of Polygons',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
        fontFamily: 'Plus Jakarta Sans', // Fallback to standard if missing
      ),
      home: const Cl6M_Ch6_A1_TheBoundaryBuilder(),
    ),
  );
}

class Cl6M_Ch6_A1_TheBoundaryBuilder extends StatefulWidget {
  const Cl6M_Ch6_A1_TheBoundaryBuilder({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch6_A1_TheBoundaryBuilder> createState() =>
      _Cl6M_Ch6_A1_TheBoundaryBuilderState();
}

class _Cl6M_Ch6_A1_TheBoundaryBuilderState
    extends State<Cl6M_Ch6_A1_TheBoundaryBuilder>
    with TickerProviderStateMixin {
  // === CONFIG & AUDIO ===
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();
  bool _isStarted = false;
  String _lang = 'en';

  // === LAYOUT STATE ===
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  bool _showSuccessPopup = false;

  // === CANVAS & CAMERA STATE ===
  final GlobalKey _canvasKey = GlobalKey();
  double _panX = 0;
  double _panY = 0;
  double _zoom = 1.0;

  // Camera dragging tracking
  double _baseZoom = 1.0;
  Offset _basePan = Offset.zero;
  Offset _startFocal = Offset.zero;

  // === GAME ENGINE STATE ===
  late AnimationController _loopController;
  Timer? _animTimer; // Track active animation to avoid memory leaks

  int _scenario = 1;
  int _step = 0;

  String? _activeDrag;
  double _dragX = 0;
  double _dragY = 0;
  bool _animating = false;

  // Scenario 1
  bool _s1Placed = false;
  int _s1SidesDone = 0;
  double _s1UnfoldP = 0;

  // Scenario 2
  bool _s2Placed = false;
  double _s2AnimP = 0;

  // Scenario 3
  bool _s3Placed = false;
  double _s3BentP = 0;
  bool _s3LeftoverPlaced = false;

  // Scenario 4
  String? _s4Track;
  double _s4AnimP = 0;
  final TextEditingController _s4OuterController = TextEditingController();
  final TextEditingController _s4InnerController = TextEditingController();

  // Scenario 5
  String? _s5Shape;
  double _s5ShapeAnim = 0;
  final TextEditingController _s5Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _loopController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 16),
        )..addListener(() {
          if (mounted) setState(() {});
        });
    _loopController.repeat();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _animTimer?.cancel();
    _loopController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _s4OuterController.dispose();
    _s4InnerController.dispose();
    _s5Controller.dispose();
    super.dispose();
  }

  // === CHILD-FRIENDLY AUDIO METHODS ===

  Future<void> playClick() async {
    if (!mounted) return;
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    if (!mounted) return;
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    if (!mounted) return;
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    if (!mounted) return;
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    if (!mounted) return;
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  // === COORDINATE MAPPING ===
  Offset _getScreenToWorld(Offset screenFocal) {
    final renderObject = _canvasKey.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return Offset.zero;

    final size = renderObject.size;
    Offset localPosition = renderObject.globalToLocal(screenFocal);

    double worldX = (localPosition.dx - size.width / 2 - _panX) / _zoom;
    double worldY = (localPosition.dy - size.height / 2 - _panY) / _zoom;
    return Offset(worldX, worldY);
  }

  double _dist(Offset p1, Offset p2) => (p1 - p2).distance;
  bool _hitTest(Offset p1, Offset p2, double rad) => _dist(p1, p2) < rad;

  // === INTERACTIONS ===
  void _onScaleStart(ScaleStartDetails details) {
    if (!_isStarted) return;

    if (details.pointerCount == 1) {
      Offset worldPt = _getScreenToWorld(details.focalPoint);
      bool hit = _handleInteractionDown(worldPt);
      if (!hit) {
        // Did not hit an object, pan the camera instead
        _activeDrag = 'camera';
        _baseZoom = _zoom;
        _basePan = Offset(_panX, _panY);
        _startFocal = details.focalPoint;
      }
    } else {
      // Multi-touch always controls camera
      _activeDrag = 'camera';
      _baseZoom = _zoom;
      _basePan = Offset(_panX, _panY);
      _startFocal = details.focalPoint;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_isStarted) return;

    if (_activeDrag == 'camera' || details.pointerCount > 1) {
      if (_activeDrag != 'camera') {
        _activeDrag = 'camera';
        _baseZoom = _zoom;
        _basePan = Offset(_panX, _panY);
        _startFocal = details.focalPoint;
      }
      setState(() {
        _zoom = max(0.4, min(3.0, _baseZoom * details.scale));
        _panX = _basePan.dx + (details.focalPoint.dx - _startFocal.dx);
        _panY = _basePan.dy + (details.focalPoint.dy - _startFocal.dy);
      });
    } else if (_activeDrag != null && _activeDrag != 'camera') {
      Offset worldPt = _getScreenToWorld(details.focalPoint);
      _dragX = worldPt.dx;
      _dragY = worldPt.dy;
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_isStarted) return;

    if (_activeDrag == 'camera') {
      _activeDrag = null;
      return;
    }

    if (_activeDrag != null) {
      Offset worldPt = Offset(_dragX, _dragY);
      _handleInteractionUp(worldPt);
      _activeDrag = null;
    }
  }

  // Returns true if an interactive element was touched
  bool _handleInteractionDown(Offset pt) {
    if (_scenario == 1) {
      if (_step == 0 &&
          !_s1Placed &&
          _hitTest(const Offset(-240, 190), pt, 40)) {
        _activeDrag = 'fence';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        return true;
      } else if (_step > 0 && _step < 4 && _s1Placed && _activeDrag == null) {
        List<Offset> corners = const [
          Offset(-120, -130),
          Offset(120, -130),
          Offset(120, 30),
          Offset(-120, 30),
        ];
        if (_hitTest(corners[_s1SidesDone], pt, 50)) {
          _activeDrag = 'fence';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          return true;
        }
      }
    } else if (_scenario == 2) {
      if (_step == 0 &&
          !_s2Placed &&
          _hitTest(const Offset(-200, 150), pt, 40)) {
        _activeDrag = 'tape';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        return true;
      }
    } else if (_scenario == 3) {
      if (_step == 0 && !_s3Placed && _hitTest(const Offset(0, 180), pt, 150)) {
        _activeDrag = 'wire';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        return true;
      } else if (_step == 2 &&
          _s3BentP == 1 &&
          !_s3LeftoverPlaced &&
          _hitTest(const Offset(60, 230), pt, 60)) {
        _activeDrag = 'leftover';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        return true;
      }
    } else if (_scenario == 4) {
      Offset wPos = const Offset(-300, 150);
      if (_s4Track != null && _activeDrag == null) {
        Rect rect = _s4Track == 'outer'
            ? const Rect.fromLTWH(-200, -120, 400, 240)
            : const Rect.fromLTWH(-150, -70, 300, 140);
        double perimeter = (rect.width + rect.height) * 2;
        double curDist = _s4AnimP * perimeter;
        double wx = rect.left, wy = rect.top;
        if (curDist < rect.width) {
          wx += curDist;
        } else if (curDist < rect.width + rect.height) {
          wx += rect.width;
          wy += (curDist - rect.width);
        } else if (curDist < rect.width * 2 + rect.height) {
          wx += rect.width - (curDist - rect.width - rect.height);
          wy += rect.height;
        } else {
          wy += rect.height - (curDist - rect.width * 2 - rect.height);
        }
        wPos = Offset(wx, wy);
      }

      if (_step < 3 && _hitTest(wPos, pt, 60)) {
        if (_step == 0 || (_step == 2 && _s4Track == 'outer')) {
          _activeDrag = 'wheel';
          _dragX = pt.dx;
          _dragY = pt.dy;
          playClick();
          return true;
        } else if (!_animating) {
          _animateS4();
          return true;
        }
      }
    } else if (_scenario == 5) {
      if (_s5Shape == null && _hitTest(const Offset(0, 150), pt, 150)) {
        _activeDrag = 'string';
        _dragX = pt.dx;
        _dragY = pt.dy;
        playClick();
        return true;
      }
    }
    return false;
  }

  void _handleInteractionUp(Offset pt) {
    if (_activeDrag == 'fence') {
      if (_step == 0 && _hitTest(const Offset(-120, -130), pt, 60)) {
        _s1Placed = true;
        playClick();
        _advanceStep();
      } else if (_step > 0) {
        List<Offset> corners = const [
          Offset(-120, -130),
          Offset(120, -130),
          Offset(120, 30),
          Offset(-120, 30),
        ];
        Offset tgt = corners[(_s1SidesDone + 1) % 4];
        if (_hitTest(tgt, pt, 60)) {
          _s1SidesDone++;
          playClick();
          if (_s1SidesDone == 1 && _step == 1) _advanceStep();
          if (_s1SidesDone == 4) {
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _animateS1Unfold);
          }
        } else {
          playError();
        }
      }
    } else if (_activeDrag == 'tape') {
      if (_hitTest(const Offset(0, -100), pt, 80)) {
        _s2Placed = true;
        playClick();
        _advanceStep();
      } else {
        playError();
      }
    } else if (_activeDrag == 'wire') {
      if (_hitTest(const Offset(-120, 100), pt, 80)) {
        _s3Placed = true;
        playClick();
        _animateS3Bend();
        _advanceStep();
      } else {
        playError();
      }
    } else if (_activeDrag == 'leftover') {
      if (_hitTest(const Offset(50, 0), pt, 80)) {
        _s3LeftoverPlaced = true;
        playPageOpen();
        _advanceStep();
        Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
      } else {
        playError();
      }
    } else if (_activeDrag == 'wheel') {
      if (_step == 0 &&
          _hitTest(const Offset(0, 0), pt, 220) &&
          !_hitTest(const Offset(0, 0), pt, 150)) {
        _s4Track = 'outer';
        playClick();
        _advanceStep();
      } else if (_step == 2 && _hitTest(const Offset(0, 0), pt, 150)) {
        _s4Track = 'inner';
        _s4AnimP = 0;
        playClick();
      } else {
        playError();
      }
    } else if (_activeDrag == 'string') {
      if ((_step == 0 || _step == 1) &&
          _hitTest(const Offset(-200, -50), pt, 80)) {
        _s5Shape = 'square';
        _animateS5Shape();
        playClick();
        if (_step == 0) _advanceStep();
      } else if (_step == 2 && _hitTest(const Offset(0, -50), pt, 80)) {
        _s5Shape = 'triangle';
        _animateS5Shape();
        playClick();
      } else if (_step == 3 && _hitTest(const Offset(200, -50), pt, 80)) {
        _s5Shape = 'hexagon';
        _animateS5Shape();
        playClick();
      } else {
        playError();
      }
    }
  }

  // === ANIMATIONS ===
  void _animateS1Unfold() {
    _animating = true;
    int startTime = DateTime.now().millisecondsSinceEpoch;
    _animTimer?.cancel();
    _animTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      double p = (DateTime.now().millisecondsSinceEpoch - startTime) / 2000.0;
      if (p >= 1.0) {
        p = 1.0;
        timer.cancel();
        _animating = false;
        playPageOpen();
        Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
      }
      _s1UnfoldP = p;
    });
  }

  void _animateS2() {
    _animating = true;
    playClick();
    int startTime = DateTime.now().millisecondsSinceEpoch;
    _animTimer?.cancel();
    _animTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      double p = (DateTime.now().millisecondsSinceEpoch - startTime) / 1000.0;
      if (p >= 1.0) {
        p = 1.0;
        timer.cancel();
        _animating = false;
        playPageOpen();
        _advanceStep();
        Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
      }
      _s2AnimP = p;
    });
  }

  void _animateS3Bend() {
    _animating = true;
    int startTime = DateTime.now().millisecondsSinceEpoch;
    _animTimer?.cancel();
    _animTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      double p = (DateTime.now().millisecondsSinceEpoch - startTime) / 1500.0;
      if (p >= 1.0) {
        p = 1.0;
        timer.cancel();
        _animating = false;
        playClick();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          if (_scenario == 3 && _step == 1) {
            _advanceStep();
            playPageOpen();
          }
        });
      }
      _s3BentP = p;
    });
  }

  void _animateS4() {
    _animating = true;
    playClick();
    int startTime = DateTime.now().millisecondsSinceEpoch;
    _animTimer?.cancel();
    _animTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      double p = (DateTime.now().millisecondsSinceEpoch - startTime) / 2000.0;
      if (p >= 1.0) {
        p = 1.0;
        timer.cancel();
        _animating = false;
        playClick();
        if (_step == 1 && _s4Track == 'outer') _advanceStep();
        if (_step == 2 && _s4Track == 'inner') _advanceStep();
      }
      _s4AnimP = p;
    });
  }

  void _animateS5Shape() {
    _animating = true;
    int startTime = DateTime.now().millisecondsSinceEpoch;
    _animTimer?.cancel();
    _animTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      double p = (DateTime.now().millisecondsSinceEpoch - startTime) / 500.0;
      if (p >= 1.0) {
        p = 1.0;
        timer.cancel();
        _animating = false;
      }
      _s5ShapeAnim = p;
    });
  }

  // === WORKFLOW FLOW ===
  void _startLab() {
    curtainScreen();
    setState(() {
      _isStarted = true;
    });
    _loadScenario(1);
  }

  void _loadScenario(int id) {
    _animTimer?.cancel();
    setState(() {
      _scenario = id;
      _step = 0;
      _animating = false;
      _activeDrag = null;
      _s1Placed = false;
      _s1SidesDone = 0;
      _s1UnfoldP = 0;
      _s2Placed = false;
      _s2AnimP = 0;
      _s3Placed = false;
      _s3BentP = 0;
      _s3LeftoverPlaced = false;
      _s4Track = null;
      _s4AnimP = 0;
      _s4OuterController.clear();
      _s4InnerController.clear();
      _s5Shape = null;
      _s5ShapeAnim = 0;
      _s5Controller.clear();
      _showSuccessPopup = false;
      _toolFitScreen();
    });
  }

  void _advanceStep() {
    if (mounted) setState(() => _step++);
  }

  void _checkScenarioSuccess() {
    if (!mounted) return;
    final conf = _getScenarioConfig(_scenario);
    setState(() => _step = conf.steps.length);
    if (_scenario == 5) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        playPageOpen();
        setState(() => _showSuccessPopup = true);
      });
    } else {
      playPageOpen();
      setState(() => _showSuccessPopup = true);
    }
  }

  void _toolFitScreen() {
    setState(() {
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
    });
  }

  // === LOCALIZATION ===
  String t(String key) {
    Map<String, Map<String, String>> dict = {
      'en': {
        'appTitle': "The Boundary Builder",
        'appSubtitle': "Class 6 Math • Understanding Perimeter of Polygons",
        'enterLab': "Enter Virtual Lab",
        'selectScenario': "Select Scenario",
        'stepLabel': "STEP",
        'learnLbl': "Objective:",
        'summaryTitle': "Goal Reached!",
        'finishLab': "Finish Lab",
        'nextScenario': "Next Scenario",
        'finalDesc':
            "You have successfully explored perimeter concepts using interactive models!",
        'lbl_fenceUsed': "Total Fence Used:",
        'lbl_toolbox': "Toolbox",
        'lbl_shortcut': "Use Shortcut!",
        'lbl_perimeter': "Perimeter",
        'lbl_check': "Check",
        'lbl_reset': "Reset",

        's1_title': "1. The Fence Builder",
        's1_obj':
            "To understand that the perimeter of a rectangle is the sum of the lengths of all its sides.",
        's1_h1': "Drag fence roll to top-left corner.",
        's1_h2': "Drag fence to the top-right corner.",
        's1_h3': "Drag to cover remaining 3 sides.",
        's1_h4': "Watch the calculation.",
        's1_s1_t':
            "DRAG the 'Fence Roll' from the toolbox and DROP it onto the top-left corner.",
        's1_s1_o': "Fence is ready to be unrolled.",
        's1_s2_t': "CLICK and DRAG the fence end along the top side.",
        's1_s2_o': "A 12m segment placed.",
        's1_s3_t': "Continue to CLICK and DRAG along remaining sides.",
        's1_s3_o': "Field enclosed.",
        's1_s4_t': "Observe unfold animation.",
        's1_s4_o': "Perimeter = 40m.",

        's2_title': "2. The Speedy Framer",
        's2_obj':
            "To discover the formula for the perimeter of a square as a shortcut.",
        's2_h1': "Drag measuring tape to the top edge.",
        's2_h2': "Click 'Use Shortcut!'",
        's2_h3': "Observe the square perimeter formula.",
        's2_s1_t': "DRAG 'Measuring Tape' onto top side.",
        's2_s1_o': "Side length is 5m.",
        's2_s2_t': "All sides equal! CLICK 'Use Shortcut!'.",
        's2_s2_o': "Avoiding individual measurement.",
        's2_s3_t': "Watch animation.",
        's2_s3_o': "P = 4 x 5m = 20m.",

        's3_title': "3. The Wire Puzzle",
        's3_obj':
            "To find the length of a missing side of a triangle when perimeter is known.",
        's3_h1': "Drag straight wire to bottom-left corner.",
        's3_h2': "Observe wire bending.",
        's3_h3': "Drag leftover wire to missing side.",
        's3_s1_t': "DRAG 55cm wire to bottom-left.",
        's3_s1_o': "Wire attaches.",
        's3_s2_t': "Watch wire bend.",
        's3_s2_o': "Wire covers 20cm and 14cm. Calc: 55-20-14.",
        's3_s3_t': "DRAG remaining wire to missing side.",
        's3_s3_o': "Missing side is 21cm.",

        's4_title': "4. The Racetrack Run-off",
        's4_obj': "To measure and compare perimeters of two rectangles.",
        's4_h1': "Drag wheel to outer track.",
        's4_h2': "Click wheel to measure outer.",
        's4_h3': "Drag to inner track & click.",
        's4_h4': "Enter values and check.",
        's4_s1_t': "DRAG wheel to Akshi's track.",
        's4_s1_o': "Ready.",
        's4_s2_t': "CLICK wheel to animate.",
        's4_s2_o': "Perimeter is 200m.",
        's4_s3_t': "DRAG to Toshi's track and CLICK.",
        's4_s3_o': "Perimeter is 160m.",
        's4_s4_t': "Type values and click 'Check'.",
        's4_s4_o': "Akshi's track is longer!",

        's5_title': "5. The String Shaper",
        's5_obj':
            "To understand that a fixed perimeter can form different shapes.",
        's5_h1': "Drag string to Square.",
        's5_h2': "Enter square side length.",
        's5_h3': "Reset, drag to Triangle, enter side.",
        's5_h4': "Reset, drag to Hexagon, enter side.",
        's5_s1_t': "DRAG 36cm string to square.",
        's5_s1_o': "String bends into square.",
        's5_s2_t': "Measure side mentally, type it, click 'Check'.",
        's5_s2_o': "Side is 9cm. (36/4).",
        's5_s3_t': "Reset. Drag to Triangle, input, Check.",
        's5_s3_o': "Side is 12cm. (36/3).",
        's5_s4_t': "Reset. Drag to Hexagon, input, Check.",
        's5_s4_o': "Side is 6cm. (36/6).",
      },
      'hi': {
        'appTitle': "सीमा निर्माता",
        'appSubtitle': "कक्षा 6 गणित • बहुभुजों का परिमाप",
        'enterLab': "वर्चुअल लैब में प्रवेश करें",
        'selectScenario': "परिदृश्य चुनें",
        'stepLabel': "चरण",
        'learnLbl': "उद्देश्य:",
        'summaryTitle': "लक्ष्य प्राप्त!",
        'finishLab': "समाप्त करें",
        'nextScenario': "अगला परिदृश्य",
        'finalDesc':
            "आपने इंटरैक्टिव मॉडल का उपयोग करके परिमाप को सफलतापूर्वक खोजा है!",
        'lbl_fenceUsed': "कुल बाड़:",
        'lbl_toolbox': "टूलबॉक्स",
        'lbl_shortcut': "शॉर्टकट!",
        'lbl_perimeter': "परिमाप",
        'lbl_check': "जांचें",
        'lbl_reset': "रीसेट",

        's1_title': "1. बाड़ निर्माता",
        's1_obj': "यह समझना कि आयत का परिमाप उसकी सभी भुजाओं का योग है।",
        's1_h1': "फेंस रोल को ऊपरी-बाएँ कोने पर ड्रैग करें।",
        's1_h2': "बाड़ को ऊपरी-दाएँ कोने पर ड्रैग करें।",
        's1_h3': "शेष 3 भुजाओं के लिए ड्रैग करें।",
        's1_h4': "गणना देखें।",
        's1_s1_t':
            "टूलबॉक्स से 'फेंस रोल' ड्रैग करें और ऊपरी-बाएँ कोने पर ड्रॉप करें।",
        's1_s1_o': "बाड़ तैयार है।",
        's1_s2_t': "सिरे को क्लिक और ड्रैग करें।",
        's1_s2_o': "12m भाग रखा गया।",
        's1_s3_t': "शेष भुजाओं के लिए जारी रखें।",
        's1_s3_o': "मैदान घिर गया।",
        's1_s4_t': "एनीमेशन देखें।",
        's1_s4_o': "परिमाप = 40m.",

        's2_title': "2. स्पीडी फ्रेमर",
        's2_obj': "शॉर्टकट के रूप में वर्ग के परिमाप के सूत्र की खोज।",
        's2_h1': "टेप को ऊपरी किनारे पर ड्रैग करें।",
        's2_h2': "'शॉर्टकट!' पर क्लिक करें।",
        's2_h3': "सूत्र का निरीक्षण करें।",
        's2_s1_t': "टेप को ऊपरी हिस्से पर ड्रैग करें।",
        's2_s1_o': "भुजा 5m है।",
        's2_s2_t': "सभी भुजाएँ समान हैं! 'शॉर्टकट' क्लिक करें।",
        's2_s2_o': "अलग-अलग मापन से बचना।",
        's2_s3_t': "एनीमेशन देखें।",
        's2_s3_o': "P = 4 x 5m = 20m.",

        's3_title': "3. तार की पहेली",
        's3_obj': "त्रिभुज की अज्ञात भुजा की लंबाई ज्ञात करना।",
        's3_h1': "तार को निचले-बाएँ कोने पर ड्रैग करें।",
        's3_h2': "तार को मुड़ते हुए देखें।",
        's3_h3': "बचे तार को दाईं ओर ड्रैग करें।",
        's3_s1_t': "55cm तार निचले-बाएँ कोने पर ड्रैग करें।",
        's3_s1_o': "तार जुड़ जाता है।",
        's3_s2_t': "तार को मुड़ते देखें।",
        's3_s2_o': "गणना: 55-20-14.",
        's3_s3_t': "बचे तार को अज्ञात भुजा पर ड्रैग करें।",
        's3_s3_o': "अज्ञात भुजा 21cm है।",

        's4_title': "4. रेसट्रैक रन-ऑफ",
        's4_obj': "दो आयतों के परिमाप मापना और तुलना करना।",
        's4_h1': "पहिये को बाहरी ट्रैक पर ड्रैग करें।",
        's4_h2': "पहिये पर क्लिक करें।",
        's4_h3': "आंतरिक ट्रैक पर ड्रैग और क्लिक करें।",
        's4_h4': "मान दर्ज करें और जांचें।",
        's4_s1_t': "पहिये को अक्षी के ट्रैक पर ड्रैग करें।",
        's4_s1_o': "तैयार।",
        's4_s2_t': "पहिये पर क्लिक करें।",
        's4_s2_o': "परिमाप 200m है।",
        's4_s3_t': "तोशी के ट्रैक पर ड्रैग और क्लिक करें।",
        's4_s3_o': "परिमाप 160m है।",
        's4_s4_t': "मान टाइप करें और 'जांचें' क्लिक करें।",
        's4_s4_o': "अक्षी का ट्रैक लंबा है!",

        's5_title': "5. स्ट्रिंग शेपर",
        's5_obj': "यह समझना कि एक परिमाप विभिन्न आकार बना सकता है।",
        's5_h1': "स्ट्रिंग को वर्ग पर ड्रैग करें।",
        's5_h2': "वर्ग की भुजा दर्ज करें।",
        's5_h3': "रीसेट, त्रिभुज पर ड्रैग, भुजा दर्ज करें।",
        's5_h4': "रीसेट, षट्भुज पर ड्रैग, भुजा दर्ज करें।",
        's5_s1_t': "36cm स्ट्रिंग को वर्ग पर ड्रैग करें।",
        's5_s1_o': "वर्ग में मुड़ जाती है।",
        's5_s2_t': "भुजा मापें, टाइप करें, 'जांचें' क्लिक करें।",
        's5_s2_o': "भुजा 9cm है।",
        's5_s3_t': "रीसेट। त्रिभुज पर ड्रैग, टाइप, जांचें।",
        's5_s3_o': "भुजा 12cm है।",
        's5_s4_t': "रीसेट। षट्भुज पर ड्रैग, टाइप, जांचें।",
        's5_s4_o': "भुजा 6cm है।",
      },
    };
    return dict[_lang]?[key] ?? key;
  }

  ScenarioConfig _getScenarioConfig(int id) {
    List<ScenarioStep> steps = [];
    List<int> counts = [4, 3, 3, 4, 4];
    for (int i = 1; i <= counts[id - 1]; i++) {
      steps.add(
        ScenarioStep(
          hud: t('s${id}_h$i'),
          task: t('s${id}_s${i}_t'),
          outcome: t('s${id}_s${i}_o'),
        ),
      );
    }
    return ScenarioConfig(
      title: t('s${id}_title'),
      objective: t('s${id}_obj'),
      steps: steps,
    );
  }

  // === WIDGET BUILD ===
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              left: _sidebarOpen ? _sidebarWidth : 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onScaleEnd: _onScaleEnd,
                        child: Container(
                          color: const Color(0xFF0F172A),
                          width: double.infinity,
                          height: double.infinity,
                          child: CustomPaint(
                            key: _canvasKey,
                            painter: SimulationPainter(
                              panX: _panX,
                              panY: _panY,
                              zoom: _zoom,
                              scenario: _scenario,
                              step: _step,
                              activeDrag: _activeDrag,
                              dragX: _dragX,
                              dragY: _dragY,
                              s1Placed: _s1Placed,
                              s1SidesDone: _s1SidesDone,
                              s1UnfoldP: _s1UnfoldP,
                              s2Placed: _s2Placed,
                              s2AnimP: _s2AnimP,
                              s3Placed: _s3Placed,
                              s3BentP: _s3BentP,
                              s3LeftoverPlaced: _s3LeftoverPlaced,
                              s4Track: _s4Track,
                              s4AnimP: _s4AnimP,
                              s4ValOuter: _s4OuterController.text,
                              s4ValInner: _s4InnerController.text,
                              s5Shape: _s5Shape,
                              s5ShapeAnim: _s5ShapeAnim,
                              langT: t,
                            ),
                          ),
                        ),
                      ),

                      // Overlay Interactive Floating UI Elements using safe layout constraints
                      _buildFloatingUI(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),

                      // HUD (Bottom Center)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity:
                                (_isStarted &&
                                    _step <
                                        _getScenarioConfig(
                                          _scenario,
                                        ).steps.length)
                                ? 1.0
                                : 0.0,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 600),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                border: const Border(
                                  top: BorderSide(
                                    color: Color(0xFF6366F1),
                                    width: 4,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF818CF8),
                                    size: 30,
                                  ),
                                  const SizedBox(width: 16),
                                  Flexible(
                                    child: Text(
                                      _getScenarioConfig(
                                                _scenario,
                                              ).steps.isNotEmpty &&
                                              _step <
                                                  _getScenarioConfig(
                                                    _scenario,
                                                  ).steps.length
                                          ? _getScenarioConfig(
                                              _scenario,
                                            ).steps[_step].hud
                                          : "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
                    ],
                  );
                },
              ),
            ),

            // 2. SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
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
                      blurRadius: 15,
                      offset: Offset(5, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 66,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Header Items
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.crop_square,
                                      color: Color(0xFF6366F1),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t('appTitle'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t('appSubtitle'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Language and Reset (Moved below subtitle)
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(
                                                  () => _lang = _lang == 'en'
                                                      ? 'hi'
                                                      : 'en',
                                                );
                                                playClick();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white12,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.language,
                                                      color: Colors.white70,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _lang.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            InkWell(
                                              onTap: () {
                                                playClick();
                                                setState(
                                                  () => _isStarted = false,
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.refresh,
                                                      color: Colors.redAccent,
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      t('lbl_reset'),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.redAccent,
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
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: Colors.white12, height: 1),
                              const SizedBox(height: 24),

                              Text(
                                t('selectScenario').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white54,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  border: Border.all(color: Colors.white24),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _scenario,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    items: [1, 2, 3, 4, 5]
                                        .map(
                                          (id) => DropdownMenuItem<int>(
                                            value: id,
                                            child: Text(t('s${id}_title')),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        playDropdown();
                                        _loadScenario(v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withOpacity(0.5),
                                  border: Border.all(color: Colors.white12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          t('learnLbl'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getScenarioConfig(_scenario).objective,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              ..._buildStepsUI(),

                              const SizedBox(height: 40),
                              const Center(
                                child: Text(
                                  "© ZeroScienceLab | Fall in love with math and Science",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Resize Handle
                    GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _sidebarWidth = max(
                            300.0,
                            min(
                              MediaQuery.of(context).size.width * 0.6,
                              _sidebarWidth + details.delta.dx,
                            ),
                          );
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: Container(
                          width: 8,
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              height: 40,
                              width: 4,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. FIXED MENU TOGGLE (TOP-LEFT)
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _sidebarOpen = !_sidebarOpen;
                  });
                  playClick();
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
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

            // 4. CURTAIN SCREEN
            if (!_isStarted)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.5),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.crop_square,
                            size: 80,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          t('appTitle'),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton.icon(
                          onPressed: _startLab,
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(
                            t('enterLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
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

            // 5. SUCCESS POPUP
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flag,
                              size: 40,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('finalDesc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _showSuccessPopup = false);
                              if (_scenario < 5) {
                                _loadScenario(_scenario + 1);
                              } else {
                                setState(() => _isStarted = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              _scenario < 5
                                  ? t('nextScenario')
                                  : t('finishLab'),
                              style: const TextStyle(
                                fontSize: 16,
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
              ),
          ],
        ),
      ),
    );
  }

  // === DYNAMIC FLOATING UI ===
  Widget _buildFloatingUI(double canvasWidth, double canvasHeight) {
    List<Widget> children = [];

    // Safely mapping widgets exactly relative to the LayoutBuilder's constraints
    Positioned buildMappedWidget(Offset worldPt, Widget child) {
      double screenX = canvasWidth / 2 + _panX + worldPt.dx * _zoom;
      double screenY = canvasHeight / 2 + _panY + worldPt.dy * _zoom;
      return Positioned(
        left: screenX,
        top: screenY,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: Transform.scale(scale: _zoom, child: child),
        ), // Center exactly and scale with canvas
      );
    }

    if (_scenario == 2 && _step == 1 && _s2Placed) {
      children.add(
        buildMappedWidget(
          const Offset(0, 120),
          ElevatedButton.icon(
            onPressed: () {
              playClick();
              _advanceStep();
              _animateS2();
            },
            icon: const Icon(Icons.auto_fix_high, size: 20),
            label: Text(
              t('lbl_shortcut'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      );
    }

    if (_scenario == 4 && _step == 3) {
      children.add(
        buildMappedWidget(
          const Offset(-100, 200),
          _buildCanvasInput(_s4OuterController, 'Akshi'),
        ),
      );
      children.add(
        buildMappedWidget(
          const Offset(100, 200),
          _buildCanvasInput(_s4InnerController, 'Toshi'),
        ),
      );
      children.add(
        buildMappedWidget(
          const Offset(0, 260),
          ElevatedButton(
            onPressed: () {
              if (_s4OuterController.text == '200' &&
                  _s4InnerController.text == '160') {
                playPageOpen();
                _advanceStep();
                Future.delayed(
                  const Duration(seconds: 1),
                  _checkScenarioSuccess,
                );
              } else {
                playError();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            child: Text(
              t('lbl_check'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    if (_scenario == 5 && _s5Shape != null && _step < 4) {
      double tx = _s5Shape == 'square'
          ? -200
          : _s5Shape == 'triangle'
          ? 0
          : 200;
      children.add(
        buildMappedWidget(
          Offset(tx, 50),
          _buildCanvasInput(_s5Controller, '? cm'),
        ),
      );
      children.add(
        buildMappedWidget(
          Offset(tx, 100),
          ElevatedButton(
            onPressed: () {
              int ans = _s5Shape == 'square'
                  ? 9
                  : _s5Shape == 'triangle'
                  ? 12
                  : 6;
              if (int.tryParse(_s5Controller.text) == ans) {
                playPageOpen();
                _advanceStep();
                _s5Controller.clear();
                if (_step == 4) {
                  Future.delayed(
                    const Duration(seconds: 1),
                    _checkScenarioSuccess,
                  );
                }
              } else {
                playError();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(100, 36),
            ),
            child: Text(
              t('lbl_check'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
      children.add(
        buildMappedWidget(
          Offset(tx, 140),
          ElevatedButton(
            onPressed: () {
              _s5Shape = null;
              _s5Controller.clear();
              playClick();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 36),
            ),
            child: Text(
              t('lbl_reset'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Stack(children: children);
  }

  Widget _buildCanvasInput(TextEditingController controller, String hint) {
    return Container(
      width: 100,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6366F1), width: 2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 5),
        ),
      ),
    );
  }

  List<Widget> _buildStepsUI() {
    final conf = _getScenarioConfig(_scenario);
    return List.generate(conf.steps.length, (i) {
      bool isPast = i < _step;
      bool isCurrent = i == _step;
      bool isCompleted = _step == conf.steps.length;

      Color bgColor = isCurrent
          ? const Color(0xFF6366F1).withOpacity(0.15)
          : (isPast
                ? Colors.greenAccent.withOpacity(0.1)
                : const Color(0xFF0F172A).withOpacity(0.5));
      Color borderColor = isCurrent
          ? const Color(0xFF6366F1)
          : (isPast ? Colors.greenAccent : Colors.white12);

      Widget icon;
      if (isPast || isCompleted && i == conf.steps.length - 1) {
        icon = const Icon(
          Icons.check_circle,
          color: Colors.greenAccent,
          size: 28,
        );
      } else if (isCurrent) {
        icon = Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        icon = Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t("stepLabel")} ${i + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCurrent
                          ? const Color(0xFF818CF8)
                          : Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Action: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF818CF8),
                          ),
                        ),
                        TextSpan(
                          text: conf.steps[i].task,
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isPast ||
                      (isCompleted && i == conf.steps.length - 1)) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Observation: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                            TextSpan(
                              text: conf.steps[i].outcome,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
    });
  }
}

// === DATA MODELS ===
class ScenarioConfig {
  final String title;
  final String objective;
  final List<ScenarioStep> steps;
  ScenarioConfig({
    required this.title,
    required this.objective,
    required this.steps,
  });
}

class ScenarioStep {
  final String hud;
  final String task;
  final String outcome;
  ScenarioStep({required this.hud, required this.task, required this.outcome});
}

// === CUSTOM PAINTER ===
class SimulationPainter extends CustomPainter {
  final double panX, panY, zoom;
  final int scenario, step;
  final String? activeDrag;
  final double dragX, dragY;

  // S1
  final bool s1Placed;
  final int s1SidesDone;
  final double s1UnfoldP;
  // S2
  final bool s2Placed;
  final double s2AnimP;
  // S3
  final bool s3Placed;
  final double s3BentP;
  final bool s3LeftoverPlaced;
  // S4
  final String? s4Track;
  final double s4AnimP;
  final String s4ValOuter, s4ValInner;
  // S5
  final String? s5Shape;
  final double s5ShapeAnim;

  final Function(String) langT;

  SimulationPainter({
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.scenario,
    required this.step,
    required this.activeDrag,
    required this.dragX,
    required this.dragY,
    required this.s1Placed,
    required this.s1SidesDone,
    required this.s1UnfoldP,
    required this.s2Placed,
    required this.s2AnimP,
    required this.s3Placed,
    required this.s3BentP,
    required this.s3LeftoverPlaced,
    required this.s4Track,
    required this.s4AnimP,
    required this.s4ValOuter,
    required this.s4ValInner,
    required this.s5Shape,
    required this.s5ShapeAnim,
    required this.langT,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

  void _renderS1(Canvas canvas) {
    double cx = 0, cy = -50, w = 240, h = 160;
    double rx = cx - w / 2, ry = cy - h / 2;
    List<Offset> corners = [
      Offset(rx, ry),
      Offset(rx + w, ry),
      Offset(rx + w, ry + h),
      Offset(rx, ry + h),
    ];

    _drawRect(
      canvas,
      Rect.fromLTWH(rx, ry, w, h),
      const Color(0xFF86EFAC),
      const Color(0xFF166534),
      4,
    );
    _drawText(
      canvas,
      "12 m",
      Offset(cx, ry - 15),
      fontSize: 16,
      color: Colors.white,
      bold: true,
    );
    _drawText(
      canvas,
      "8 m",
      Offset(rx - 20, cy),
      fontSize: 16,
      color: Colors.white,
      bold: true,
    );

    // Toolbox
    _drawRect(
      canvas,
      const Rect.fromLTWH(-300, 150, 120, 80),
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      langT('lbl_toolbox'),
      const Offset(-240, 130),
      fontSize: 14,
      color: Colors.white,
      bold: true,
    );

    // Counter
    _drawRect(
      canvas,
      const Rect.fromLTWH(200, 150, 160, 60),
      const Color(0xFF1E293B),
      const Color(0xFF6366F1),
      3,
    );
    int tot = s1SidesDone >= 1 ? 12 : 0;
    if (s1SidesDone >= 2) tot += 8;
    if (s1SidesDone >= 3) tot += 12;
    if (s1SidesDone >= 4) tot += 8;
    _drawText(
      canvas,
      langT('lbl_fenceUsed'),
      const Offset(280, 170),
      fontSize: 14,
      color: const Color(0xFF94A3B8),
    );
    _drawText(
      canvas,
      "$tot m",
      const Offset(280, 195),
      fontSize: 20,
      color: Colors.white,
      bold: true,
    );

    if (step < 4) {
      for (int i = 0; i < s1SidesDone; i++) {
        _drawFenceSegment(canvas, corners[i], corners[(i + 1) % 4]);
      }

      if (s1Placed && s1SidesDone < 4 && activeDrag == null) {
        _drawFenceRoll(canvas, corners[s1SidesDone], 1.2);
        Offset tgt = corners[(s1SidesDone + 1) % 4];
        Paint pulsePaint = Paint()
          ..color = const Color(0xFF6366F1).withOpacity(
            0.3 + 0.3 * sin(DateTime.now().millisecondsSinceEpoch / 150),
          );
        canvas.drawCircle(tgt, 20, pulsePaint);
      }

      if (activeDrag == 'fence') {
        Offset st = s1SidesDone < 4 && s1Placed
            ? corners[s1SidesDone]
            : const Offset(-240, 190);
        if (s1Placed) _drawFenceSegment(canvas, st, Offset(dragX, dragY));
        _drawFenceRoll(canvas, Offset(dragX, dragY), 1.2);
      } else if (!s1Placed) {
        _drawFenceRoll(canvas, const Offset(-240, 190), 1.5);
      }
    } else {
      double startX = -200;
      double y = cy + 100;
      List<double> segs = [120, 80, 120, 80];
      double curX = startX;
      for (int i = 0; i < 4; i++) {
        Offset orig1 = corners[i], orig2 = corners[(i + 1) % 4];
        Offset target1 = Offset(curX, y), target2 = Offset(curX + segs[i], y);
        Offset p1 = Offset.lerp(orig1, target1, s1UnfoldP)!;
        Offset p2 = Offset.lerp(orig2, target2, s1UnfoldP)!;

        _drawFenceSegment(canvas, p1, p2);
        if (s1UnfoldP > 0.8) {
          _drawText(
            canvas,
            "${segs[i] / 10}m",
            Offset((p1.dx + p2.dx) / 2, y - 20),
            fontSize: 14,
            color: Colors.white,
            bold: true,
          );
        }
        curX += segs[i];
      }
      if (s1UnfoldP == 1.0) {
        _drawText(
          canvas,
          "${langT('lbl_perimeter')} = 12m + 8m + 12m + 8m = 40m",
          Offset(0, y + 40),
          fontSize: 20,
          color: Colors.greenAccent,
          bold: true,
        );
      }
    }
  }

  void _renderS2(Canvas canvas) {
    _drawRect(
      canvas,
      const Rect.fromLTWH(-100, -100, 200, 200),
      const Color(0xFFE2E8F0),
      const Color(0xFF94A3B8),
      15,
    );

    if (!s2Placed && activeDrag == null) {
      _drawTape(canvas, const Offset(-200, 150), 1.5);
    }
    if (activeDrag == 'tape') _drawTape(canvas, Offset(dragX, dragY), 1.5);

    if (s2Placed) {
      _drawRect(
        canvas,
        const Rect.fromLTWH(-50, -115, 100, 30),
        Colors.white,
        const Color(0xFF0F172A),
        2,
      );
      _drawText(
        canvas,
        "5 m",
        const Offset(0, -100),
        fontSize: 16,
        color: const Color(0xFF0F172A),
        bold: true,
      );

      if (step == 1) {
        Paint hilight = Paint()
          ..color = Colors.amberAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
        canvas.drawRect(const Rect.fromLTWH(-100, -100, 200, 200), hilight);
      }

      if (step >= 2) {
        double offY = s2AnimP * 200, offX = s2AnimP * 100;

        canvas.save();
        canvas.translate(-115, -100 + offX);
        canvas.rotate(-pi / 2);
        _drawRect(
          canvas,
          const Rect.fromLTWH(-50, -15, 100, 30),
          Colors.white,
          const Color(0xFF0F172A),
          2,
        );
        _drawText(
          canvas,
          "5 m",
          const Offset(0, 0),
          fontSize: 16,
          color: const Color(0xFF0F172A),
          bold: true,
        );
        canvas.restore();

        canvas.save();
        canvas.translate(115, 100 - offX);
        canvas.rotate(pi / 2);
        _drawRect(
          canvas,
          const Rect.fromLTWH(-50, -15, 100, 30),
          Colors.white,
          const Color(0xFF0F172A),
          2,
        );
        _drawText(
          canvas,
          "5 m",
          const Offset(0, 0),
          fontSize: 16,
          color: const Color(0xFF0F172A),
          bold: true,
        );
        canvas.restore();

        _drawRect(
          canvas,
          Rect.fromLTWH(-50, -100 + offY - 15, 100, 30),
          Colors.white,
          const Color(0xFF0F172A),
          2,
        );
        _drawText(
          canvas,
          "5 m",
          Offset(0, -100 + offY),
          fontSize: 16,
          color: const Color(0xFF0F172A),
          bold: true,
        );

        if (s2AnimP == 1.0) {
          _drawText(
            canvas,
            "P = 5 + 5 + 5 + 5 = 4 x 5m = 20m",
            const Offset(0, 150),
            fontSize: 22,
            color: Colors.greenAccent,
            bold: true,
          );
        }
      }
    }
  }

  void _renderS3(Canvas canvas) {
    Offset p1 = const Offset(0, -100),
        p2 = const Offset(-120, 100),
        p3 = const Offset(100, 100);

    Path tri = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(tri, Paint()..color = const Color(0xFFBFDBFE));
    _drawLine(canvas, p1, p2, const Color(0xFF1E3A8A), 4);
    _drawLine(canvas, p2, p3, const Color(0xFF1E3A8A), 4);

    if (s3LeftoverPlaced) {
      _drawLine(canvas, p3, p1, const Color(0xFF1E3A8A), 4);
    } else {
      _drawLine(canvas, p3, p1, const Color(0xFF94A3B8), 4, dashed: true);
    }

    _drawText(
      canvas,
      "20 cm",
      const Offset(-70, -10),
      fontSize: 16,
      color: Colors.white,
      bold: true,
    );
    _drawText(
      canvas,
      "14 cm",
      const Offset(-10, 120),
      fontSize: 16,
      color: Colors.white,
      bold: true,
    );
    if (!s3LeftoverPlaced) {
      _drawText(
        canvas,
        "?",
        const Offset(70, -10),
        fontSize: 24,
        color: Colors.redAccent,
        bold: true,
      );
    } else {
      _drawText(
        canvas,
        "21 cm",
        const Offset(70, -10),
        fontSize: 16,
        color: Colors.greenAccent,
        bold: true,
      );
    }

    if (!s3Placed && activeDrag == null) {
      _drawWire(canvas, const [Offset(-150, 180), Offset(150, 180)]);
      _drawText(
        canvas,
        "Total Wire: 55 cm",
        const Offset(0, 210),
        fontSize: 16,
        color: Colors.white,
        bold: true,
      );
    }
    if (activeDrag == 'wire') {
      _drawWire(canvas, [
        Offset(dragX - 150, dragY),
        Offset(dragX + 150, dragY),
      ]);
    }

    if (s3Placed) {
      Offset bX = Offset.lerp(p2, p3, s3BentP)!;
      _drawWire(canvas, [p1, p2, bX], const Color(0xFFFACC15));

      if (s3BentP == 1.0 && !s3LeftoverPlaced) {
        _drawText(
          canvas,
          "55 - 20 - 14 = 21cm",
          const Offset(0, 200),
          fontSize: 18,
          color: const Color(0xFFFACC15),
          bold: true,
        );
        if (activeDrag == null) {
          _drawWire(canvas, const [
            Offset(0, 230),
            Offset(120, 230),
          ], const Color(0xFFFACC15));
        }
        if (activeDrag == 'leftover') {
          _drawWire(canvas, [
            Offset(dragX - 60, dragY),
            Offset(dragX + 60, dragY),
          ], const Color(0xFFFACC15));
        }
      }

      if (s3LeftoverPlaced) {
        _drawWire(canvas, [p3, p1], Colors.greenAccent);
        _drawText(
          canvas,
          "${langT('lbl_perimeter')} = 20 + 14 + 21 = 55 cm",
          const Offset(0, 200),
          fontSize: 20,
          color: Colors.greenAccent,
          bold: true,
        );
      }
    }
  }

  void _renderS4(Canvas canvas) {
    _drawRect(
      canvas,
      const Rect.fromLTWH(-200, -120, 400, 240),
      const Color(0xFFFCA5A5),
      const Color(0xFFB91C1C),
      20,
    );
    _drawRect(
      canvas,
      const Rect.fromLTWH(-150, -70, 300, 140),
      const Color(0xFFBBF7D0),
      const Color(0xFF15803D),
      20,
    );

    _drawText(
      canvas,
      "Akshi's Track",
      const Offset(0, -145),
      fontSize: 16,
      color: const Color(0xFFB91C1C),
      bold: true,
    );
    _drawText(
      canvas,
      "Toshi's Track",
      const Offset(0, -35),
      fontSize: 16,
      color: const Color(0xFF15803D),
      bold: true,
    );

    if (activeDrag == null && s4Track == null) {
      _drawWheel(canvas, const Offset(-300, 150), 1);
    }
    if (activeDrag == 'wheel') _drawWheel(canvas, Offset(dragX, dragY), 1);

    if (s4Track != null) {
      Rect rect = s4Track == 'outer'
          ? const Rect.fromLTWH(-200, -120, 400, 240)
          : const Rect.fromLTWH(-150, -70, 300, 140);
      double perimeter = (rect.width + rect.height) * 2;
      double curDist = s4AnimP * perimeter;

      double wx = rect.left, wy = rect.top;
      if (curDist < rect.width) {
        wx += curDist;
      } else if (curDist < rect.width + rect.height) {
        wx += rect.width;
        wy += (curDist - rect.width);
      } else if (curDist < rect.width * 2 + rect.height) {
        wx += rect.width - (curDist - rect.width - rect.height);
        wy += rect.height;
      } else {
        wy += rect.height - (curDist - rect.width * 2 - rect.height);
      }

      _drawWheel(canvas, Offset(wx, wy), 1.2);
      _drawRect(
        canvas,
        Rect.fromLTWH(wx - 30, wy - 60, 60, 25),
        Colors.white,
        const Color(0xFF0F172A),
        2,
      );

      int maxDist = s4Track == 'outer' ? 200 : 160;
      int showDist = (s4AnimP * maxDist).floor();
      _drawText(
        canvas,
        "${showDist}m",
        Offset(wx, wy - 47),
        fontSize: 14,
        color: const Color(0xFF0F172A),
        bold: true,
      );
    }

    if (step >= 3) {
      if (s4ValOuter == '200' && s4ValInner == '160') {
        _drawText(
          canvas,
          "Akshi > Toshi",
          const Offset(0, 150),
          fontSize: 24,
          color: Colors.greenAccent,
          bold: true,
        );
      }
    }
  }

  void _renderS5(Canvas canvas) {
    Paint dashPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Square dash
    _drawDashedRect(
      canvas,
      const Rect.fromLTWH(-250, -100, 100, 100),
      dashPaint,
    );

    // Triangle dash
    Path tPath = Path()
      ..moveTo(0, -100)
      ..lineTo(50, 0)
      ..lineTo(-50, 0)
      ..close();
    _drawDashedPath(canvas, tPath, dashPaint);

    // Hexagon dash
    Path hPath = Path();
    for (int i = 0; i < 6; i++) {
      double x = 200 + 50 * cos(i * pi / 3);
      double y = -50 + 50 * sin(i * pi / 3);
      if (i == 0) {
        hPath.moveTo(x, y);
      } else {
        hPath.lineTo(x, y);
      }
    }
    hPath.close();
    _drawDashedPath(canvas, hPath, dashPaint);

    if (s5Shape == null && activeDrag == null) {
      _drawWire(canvas, const [
        Offset(-150, 150),
        Offset(150, 150),
      ], Colors.redAccent);
      _drawText(
        canvas,
        "String: 36 cm long",
        const Offset(0, 180),
        fontSize: 16,
        color: Colors.white,
        bold: true,
      );
    }
    if (activeDrag == 'string') {
      _drawWire(canvas, [
        Offset(dragX - 150, dragY),
        Offset(dragX + 150, dragY),
      ], Colors.redAccent);
    }

    if (s5Shape != null) {
      double tx = s5Shape == 'square'
          ? -200
          : s5Shape == 'triangle'
          ? 0
          : 200;
      _drawStringShape(
        canvas,
        s5Shape!,
        Offset(tx, -50),
        s5ShapeAnim,
        Colors.redAccent,
      );
      if (step == 4) {
        _drawText(
          canvas,
          "${langT('lbl_perimeter')} = 36 cm",
          const Offset(0, 120),
          fontSize: 20,
          color: Colors.greenAccent,
          bold: true,
        );
      }
    }
  }

  // === DRAWING PRIMITIVES ===
  void _drawRect(
    Canvas canvas,
    Rect rect,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    canvas.drawRect(
      rect,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );
  }

  void _drawLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double w, {
    bool dashed = false,
  }) {
    Paint p = Paint()
      ..color = color
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    if (dashed) {
      _drawDashedPath(
        canvas,
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy),
        p,
      );
    } else {
      canvas.drawLine(p1, p2, p);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    required double fontSize,
    required Color color,
    bool bold = false,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawFenceRoll(Canvas canvas, Offset pos, double scale) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale, scale);
    Paint p1 = Paint()..color = const Color(0xFF94A3B8);
    Paint p2 = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, 20, p1);
    canvas.drawCircle(Offset.zero, 20, p2);
    canvas.drawCircle(Offset.zero, 10, p2);
    canvas.drawLine(const Offset(20, 0), const Offset(30, 0), p2);
    canvas.restore();
  }

  void _drawFenceSegment(Canvas canvas, Offset p1, Offset p2) {
    _drawLine(canvas, p1, p2, const Color(0xFF64748B), 8);
    double len = (p1 - p2).distance;
    double ang = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    canvas.save();
    canvas.translate(p1.dx, p1.dy);
    canvas.rotate(ang);
    Paint tick = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;
    for (double i = 5; i < len - 5; i += 10) {
      canvas.drawLine(Offset(i, -4), Offset(i + 5, 4), tick);
      canvas.drawLine(Offset(i + 5, -4), Offset(i, 4), tick);
    }
    canvas.restore();
  }

  void _drawTape(Canvas canvas, Offset pos, double scale) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale, scale);
    _drawRect(
      canvas,
      const Rect.fromLTWH(-20, -15, 40, 30),
      const Color(0xFFFACC15),
      const Color(0xFF0F172A),
      3,
    );
    canvas.drawCircle(Offset.zero, 8, Paint()..color = const Color(0xFF0F172A));
    _drawLine(
      canvas,
      const Offset(20, 0),
      const Offset(35, 0),
      const Color(0xFFFACC15),
      6,
    );
    canvas.restore();
  }

  void _drawWire(
    Canvas canvas,
    List<Offset> pts, [
    Color color = const Color(0xFF94A3B8),
  ]) {
    if (pts.isEmpty) return;
    Path p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      p.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      p,
      Paint()
        ..color = color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawWheel(Canvas canvas, Offset pos, double scale) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale, scale);
    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()..color = const Color(0xFFF8FAFC),
    );
    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    Paint spoke = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(const Offset(0, -20), const Offset(0, 20), spoke);
      canvas.rotate(pi / 4);
    }
    _drawLine(
      canvas,
      Offset.zero,
      const Offset(25, -30),
      const Color(0xFF6366F1),
      6,
    );
    canvas.restore();
  }

  void _drawStringShape(
    Canvas canvas,
    String shape,
    Offset pos,
    double anim,
    Color color,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    Path p = Path();
    if (shape == 'square') {
      p.addRect(const Rect.fromLTWH(-50, -50, 100, 100));
    } else if (shape == 'triangle') {
      p.moveTo(0, -50);
      p.lineTo(50, 50);
      p.lineTo(-50, 50);
      p.close();
    } else if (shape == 'hexagon') {
      for (int i = 0; i < 6; i++) {
        double x = 50 * cos(i * pi / 3);
        double y = 50 * sin(i * pi / 3);
        if (i == 0) {
          p.moveTo(x, y);
        } else {
          p.lineTo(x, y);
        }
      }
      p.close();
    }

    PathMetrics pathMetrics = p.computeMetrics();
    Path animPath = Path();
    for (PathMetric pathMetric in pathMetrics) {
      animPath.addPath(
        pathMetric.extractPath(0, pathMetric.length * anim),
        Offset.zero,
      );
    }
    canvas.drawPath(
      animPath,
      Paint()
        ..color = color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    Path path = Path()..addRect(rect);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    double dashWidth = 8, dashSpace = 8;
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        Path extractPath = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(SimulationPainter oldDelegate) => true; // Game loop running constantly
}
