// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // ऑडियो प्ले करने के लिए आवश्यक पैकेज

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      title: 'Angle Virtual Lab',
      home: Cl6M_Ch2_A5_MeasuringandDrawingAngles(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

// ==========================================
// स्थानीयकरण (i18n) - भाषा अनुवाद
// ==========================================
const Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': "The Angle Architect: Mastering the Protractor",
    'appTitle': "Measuring and Drawing Angles",
    'appSubtitle': "Class 6 • GEOMETRY",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'learnLbl': "Objective:",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'nextScenario': "Next Scenario",
    'finishLab': "Finish Lab",
    'scenarioComplete': "Scenario Completed!",
    'finalDesc':
        "You have successfully mastered the skills of measuring and drawing angles!",
    's1_title': "1. The Angle Inspector",
    's1_obj':
        "Learn the three fundamental steps to measure an acute angle correctly.",
    's1_hud1': "Drag the protractor towards the angle's vertex.",
    's1_step1_task':
        "DRAG the protractor from the toolbox and move it towards the angle's vertex.",
    's1_step1_out': "The protractor is centered on the vertex.",
    's1_hud2': "Rotate the protractor to align its baseline.",
    's1_step2_task':
        "CLICK and DRAG the edge of the protractor to ROTATE it until its baseline aligns with the glowing arm.",
    's1_step2_out': "The baseline is aligned with the angle's arm.",
    's1_hud3': "Click the correct number on the inner scale.",
    's1_step3_task':
        "The inner scale is highlighted. CLICK the correct number to measure the angle.",
    's1_step3_out': "Correct! This is a 55° acute angle.",
    's2_title': "2. The Obtuse Obstacle",
    's2_obj':
        "Learn to measure an obtuse angle and correctly choose between the inner and outer scales.",
    's2_hud1': "Drag and drop the protractor's center onto the vertex.",
    's2_step1_task': "DRAG and DROP the protractor's center onto the vertex.",
    's2_step1_out': "The protractor is centered on the vertex.",
    's2_hud2': "Rotate the protractor to align its baseline.",
    's2_step2_task':
        "ROTATE the protractor to ALIGN its baseline with the glowing arm.",
    's2_step2_out':
        "The outer scale is glowing because we aligned to the left.",
    's2_hud3': "Click the correct number on the outer scale.",
    's2_step3_task': "CLICK the correct number on the glowing outer scale.",
    's2_step3_out': "Excellent! This is a 120° obtuse angle.",
    's3_title': "3. The Blueprint Draftsman",
    's3_obj':
        "Learn the step-by-step process of drawing an angle of a specific measure.",
    's3_hud1': "Place the protractor correctly on the given ray.",
    's3_step1_task':
        "A single horizontal ray is provided. PLACE the protractor correctly on the ray's starting point.",
    's3_step1_out': "Protractor is perfectly aligned.",
    's3_hud2': "Click the Pencil tool from the toolbox.",
    's3_step2_task': "CLICK the Pencil tool from the toolbox.",
    's3_step2_out': "Pencil selected.",
    's3_hud3': "Click the pulsing 70° mark.",
    's3_step3_task':
        "MOVE the pencil to the pulsing 70° mark and CLICK to make a point.",
    's3_step3_out': "Point marked at 70°.",
    's3_hud4': "Drag the pencil to draw the ray.",
    's3_step4_task': "DRAG the pencil from the vertex to the new point.",
    's3_step4_out': "Mission Complete! 70° angle drawn.",
    's4_title': "4. The Carpenter's Cut",
    's4_obj':
        "Apply your measurement skills to check if a piece of wood is cut to the correct angle.",
    's4_hud1': "Measure the angle of the pre-cut wooden piece.",
    's4_step1_task':
        "Measure the angle of the wooden piece and enter your result below.",
    's4_step1_out': "The wood fits perfectly!",
    's4_btn_check': "Check Angle",
    's4_placeholder': "Enter angle (°)",
    's4_hint':
        "That doesn't look right. Remember to align the protractor's center with the red dot, and line up the baseline with one of the wood edges.",
    's5_title': "5. The Stargazer's Telescope",
    's5_obj':
        "Apply your drawing skills to aim a telescope at a specific angle (35°).",
    's5_hud1': "Draw a 35° angle from the telescope's pivot point.",
    's5_step1_task':
        "Draw a 35° angle from the telescope's pivot point using the protractor and pencil.",
    's5_step1_out': "Comet Spotted!",
    's5_btn_aim:': "Aim Telescope",
    's5_err': "No comet here. Let's re-check our angle calculation.",
  },
  'hi': {
    'shutterTitle': "द एंगल आर्किटेक्ट: प्रोट्रैक्टर में महारत हासिल करना",
    'appTitle': "कोण मापना और बनाना",
    'appSubtitle': "कक्षा 6 • ज्यामिति",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'learnLbl': "उद्देश्य:",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'nextScenario': "अगला परिदृश्य",
    'finishLab': "समाप्त करें",
    'scenarioComplete': "परिदृश्य पूरा हुआ!",
    'finalDesc':
        "आपने कोणों को मापने और खींचने के कौशल में सफलतापूर्वक महारत हासिल कर ली है!",
    's1_title': "1. कोण निरीक्षक",
    's1_obj': "तीव्र कोण को सही ढंग से मापने के लिए तीन मूलभूत चरण सीखें।",
    's1_hud1': "प्रोट्रैक्टर को कोण के शीर्ष की ओर खींचें।",
    's1_step1_task':
        "टूलबॉक्स से प्रोट्रैक्टर को खींचें और इसे शीर्ष की ओर ले जाएं।",
    's1_step1_out': "प्रोट्रैक्टर शीर्ष पर केंद्रित है।",
    's1_hud2': "बेसलाइन संरेखित करने के लिए प्रोट्रैक्टर को घुमाएं।",
    's1_step2_task':
        "चमकती भुजा के साथ बेसलाइन को संरेखित करने के लिए प्रोट्रैक्टर को घुमाएं।",
    's1_step2_out': "बेसलाइन संरेखित है।",
    's1_hud3': "आंतरिक पैमाने पर सही संख्या पर क्लिक करें।",
    's1_step3_task':
        "आंतरिक पैमाना हाइलाइट किया गया है। सही संख्या पर क्लिक करें।",
    's1_step3_out': "सही! यह एक 55° तीव्र कोण है।",
    's2_title': "2. अधिक कोण बाधा",
    's2_obj':
        "अधिक कोण मापना सीखें और आंतरिक और बाहरी पैमानों के बीच सही ढंग से चुनें।",
    's2_hud1': "प्रोट्रैक्टर को खींचकर शीर्ष पर रखें।",
    's2_step1_task': "प्रोट्रैक्टर के केंद्र को खींचकर शीर्ष पर छोड़ दें।",
    's2_step1_out': "प्रोट्रैक्टर शीर्ष पर केंद्रित है।",
    's2_hud2': "बेसलाइन संरेखित करने के लिए प्रोट्रैक्टर को घुमाएं।",
    's2_step2_task':
        "चमकती भुजा के साथ बेसलाइन को संरेखित करने के लिए प्रोट्रैक्टर को घुमाएं।",
    's2_step2_out': "बाहरी पैमाना चमक रहा है।",
    's2_hud3': "बाहरी पैमाने पर सही संख्या पर क्लिक करें।",
    's2_step3_task': "चमकते बाहरी पैमाने पर सही संख्या पर क्लिक करें।",
    's2_step3_out': "उत्कृष्ट! यह एक 120° अधिक कोण है।",
    's3_title': "3. ब्लूप्रिंट ड्राफ्ट्समैन",
    's3_obj': "एक विशिष्ट माप का कोण खींचने की चरण-दर-चरण प्रक्रिया सीखें।",
    's3_hud1': "दी गई किरण पर प्रोट्रैक्टर को सही ढंग से रखें।",
    's3_step1_task':
        "प्रोट्रैक्टर को किरण के शुरुआती बिंदु पर सही ढंग से रखें।",
    's3_step1_out': "प्रोट्रैक्टर पूरी तरह से संरेखित है।",
    's3_hud2': "टूलबॉक्स से पेंसिल टूल पर क्लिक करें।",
    's3_step2_task': "टूलबॉक्स से पेंसिल टूल पर क्लिक करें।",
    's3_step2_out': "पेंसिल का चयन किया गया।",
    's3_hud3': "70° के निशान पर क्लिक करें।",
    's3_step3_task':
        "पेंसिल को 70° के निशान पर ले जाएं और एक बिंदु बनाने के लिए क्लिक करें।",
    's3_step3_out': "70° पर बिंदु अंकित।",
    's3_hud4': "किरण खींचने के लिए पेंसिल को खींचें।",
    's3_step4_task': "शीर्ष से नए बिंदु तक पेंसिल को खींचें।",
    's3_step4_out': "मिशन पूरा हुआ! 70° का कोण खींचा गया।",
    's4_title': "4. बढ़ई की कटाई",
    's4_obj':
        "यह जांचने के लिए अपने माप कौशल का उपयोग करें कि क्या लकड़ी का एक टुकड़ा सही कोण पर काटा गया है।",
    's4_hud1': "लकड़ी के टुकड़े के कोण को मापें।",
    's4_step1_task':
        "लकड़ी के टुकड़े के कोण को मापें और नीचे अपना परिणाम दर्ज करें।",
    's4_step1_out': "लकड़ी पूरी तरह से फिट बैठती है!",
    's4_btn_check': "कोण जांचें",
    's4_placeholder': "कोण दर्ज करें (°)",
    's4_hint':
        "यह सही नहीं लग रहा है। लाल बिंदु के साथ केंद्र को संरेखित करना याद रखें, और बेसलाइन को किनारों में से एक के साथ संरेखित करें।",
    's5_title': "5. स्टारगेज़र की दूरबीन",
    's5_obj':
        "दूरबीन को एक विशिष्ट कोण (35°) पर लक्षित करने के लिए अपने आरेखण कौशल का उपयोग करें।",
    's5_hud1': "दूरबीन के धुरी बिंदु से 35° का कोण खींचें।",
    's5_step1_task':
        "प्रोट्रैक्टर और पेंसिल का उपयोग करके दूरबीन के धुरी बिंदु से 35° का कोण खींचें।",
    's5_step1_out': "धूमकेतु देखा गया!",
    's5_btn_aim:': "दूरबीन का लक्ष्य रखें",
    's5_err':
        "यहाँ कोई धूमकेतु यहाँ नहीं है। आइए अपने कोण की दोबारा जाँच करें।",
  },
};

// ==========================================
// गेम एंटिटीज़ और स्टेट (Game Entities & State)
// ==========================================
enum DragEntity { none, protractorCenter, protractorEdge, pencil }

class ProtractorData {
  double x = 250;
  double y = 150;
  double rotation = 0;
  bool visible = true;
}

class SimState {
  String lang = 'en';
  bool isSidebarOpen = true;
  bool isCurtainOpen = true;

  double panX = 0;
  double panY = 0;
  double zoom = 1.0;

  int scenario = 1;
  int step = 0;

  ProtractorData protractor = ProtractorData();
  bool pencilActive = false;

  DragEntity activeDragEntity = DragEntity.none;
  double dragOffsetX = 0;
  double dragOffsetY = 0;
  double dragStartRot = 0;
  double mouseStartAngle = 0;

  // परिदृश्य विशिष्ट स्टेट्स (Scenario Specific States)
  int? s1ClickAnim;
  int? s2ClickAnim;

  Offset? s3Point;
  bool s3LineDrawn = false;

  bool s4AngleChecked = false;

  Offset? s5Point;
  bool s5LineDrawn = false;
  bool s5Aiming = false;
  double s5TelescopeRot = 0;
  bool s5Success = false;

  int get maxSteps {
    if (scenario == 1 || scenario == 2) return 3;
    if (scenario == 3) return 4;
    return 1;
  }
}

class Cl6M_Ch2_A5_MeasuringandDrawingAngles extends StatefulWidget {
  const Cl6M_Ch2_A5_MeasuringandDrawingAngles({super.key});

  @override
  State<Cl6M_Ch2_A5_MeasuringandDrawingAngles> createState() =>
      _Cl6M_Ch2_A5_MeasuringandDrawingAnglesState();
}

class _Cl6M_Ch2_A5_MeasuringandDrawingAnglesState
    extends State<Cl6M_Ch2_A5_MeasuringandDrawingAngles>
    with SingleTickerProviderStateMixin {
  final SimState _sim = SimState();
  final GlobalKey _canvasKey = GlobalKey();

  late AnimationController _animController;
  final TextEditingController _s4Controller = TextEditingController();

  double _baseZoom = 1.0;

  // ==========================================
  // ऑडियो प्लेयर्स का आरंभीकरण (Audio Players Initialization)
  // ==========================================
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

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _loadScenario(1, initLoad: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _s4Controller.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ==========================================
  // ऑडियो प्लेबैक फ़ंक्शंस (Audio Playback Functions)
  // ==========================================

  Future<void> playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
    } catch (_) {}
  }

  Future<void> playPageOpen() async {
    try {
      await _pagePlayer.stop();
      await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
    } catch (_) {}
  }

  Future<void> playDropdown() async {
    try {
      await _dropdownPlayer.stop();
      await _dropdownPlayer.play(
        AssetSource('audio/class6/science/dropdown.mp3'),
      );
    } catch (_) {}
  }

  Future<void> playError() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
    } catch (_) {}
  }

  Future<void> curtainScreen() async {
    try {
      await _pagePlayer.stop();
      await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
    } catch (_) {}
  }

  String t(String key) => translations[_sim.lang]?[key] ?? key;

  void _toggleLanguage() {
    playClick();
    setState(() {
      _sim.lang = _sim.lang == 'en' ? 'hi' : 'en';
    });
  }

  void _resetLab() {
    playClick();
    setState(() {
      _sim.isCurtainOpen = true;
      _loadScenario(1, initLoad: true);
    });
  }

  void _loadScenario(int id, {bool initLoad = false}) {
    if (!initLoad) playPageOpen();

    setState(() {
      _sim.scenario = id;
      _sim.step = 0;
      _sim.pencilActive = false;
      _sim.activeDragEntity = DragEntity.none;
      _sim.panX = 0;
      _sim.panY = 0;
      _sim.zoom = 1.0;

      if (id == 1) {
        _sim.protractor = ProtractorData()
          ..x = 250
          ..y = -50
          ..rotation = -20;
        _sim.s1ClickAnim = null;
      }
      if (id == 2) {
        _sim.protractor = ProtractorData()
          ..x = 250
          ..y = 150
          ..rotation = 30;
        _sim.s2ClickAnim = null;
      }
      if (id == 3) {
        _sim.protractor = ProtractorData()
          ..x = 200
          ..y = -50
          ..rotation = 10;
        _sim.s3Point = null;
        _sim.s3LineDrawn = false;
      }
      if (id == 4) {
        _sim.protractor = ProtractorData()
          ..x = -270
          ..y = 150
          ..rotation = 0;
        _sim.s4AngleChecked = false;
        _s4Controller.clear();
      }
      if (id == 5) {
        _sim.protractor = ProtractorData()
          ..x = 250
          ..y = 150
          ..rotation = 0;
        _sim.s5Point = null;
        _sim.s5LineDrawn = false;
        _sim.s5Success = false;
        _sim.s5TelescopeRot = 0;
      }
    });
  }

  void _advanceStep() {
    setState(() {
      _sim.step++;
      if (_sim.step == _sim.maxSteps) {
        playPageOpen(); // परिदृश्य पूरा होने पर सफलता की आवाज़
      } else {
        playClick();
      }
    });
  }

  void _nextScenarioLogic() {
    playClick();
    if (_sim.scenario < 5) {
      _loadScenario(_sim.scenario + 1);
    } else {
      _resetLab();
    }
  }

  double _dist(Offset p1, Offset p2) => (p1 - p2).distance;

  double _normalizeAngle(double a) {
    double res = a % 360;
    if (res < 0) res += 360;
    return res;
  }

  double _degToRad(double deg) => deg * math.pi / 180;
  double _radToDeg(double rad) => rad * 180 / math.pi;

  Offset _getWorldPos(Offset screenFocal) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = box.size;
    double worldX = (screenFocal.dx - size.width / 2 - _sim.panX) / _sim.zoom;
    double worldY = (screenFocal.dy - size.height / 2 - _sim.panY) / _sim.zoom;
    return Offset(worldX, worldY);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_sim.step >= _sim.maxSteps) {
      return;
    }

    if (details.pointerCount >= 2) {
      _baseZoom = _sim.zoom;
      return;
    }

    Offset wp = _getWorldPos(details.localFocalPoint);
    bool handled = false;

    // परिदृश्यों के लिए क्लिक (Clicks for Scenarios) - सटीक गणना के साथ
    if (_sim.scenario == 1 && _sim.step == 2) {
      double rTarget = 110 * 1.2; // 132 (Inner text radius scaled)
      Offset target = Offset(
        0 + rTarget * math.cos(_degToRad(-55)),
        50 + rTarget * math.sin(_degToRad(-55)),
      );
      if (_dist(wp, target) < 50) {
        // हिट रेडियस बढ़ाया गया
        _sim.s1ClickAnim = 0;
        _advanceStep();
        handled = true;
      } else {
        handled = true;
      }
    }

    if (_sim.scenario == 2 && _sim.step == 2 && !handled) {
      double rTarget = 135 * 1.2; // 162 (Outer text radius scaled)
      Offset target = Offset(
        50 + rTarget * math.cos(_degToRad(-60)),
        50 + rTarget * math.sin(_degToRad(-60)),
      );
      if (_dist(wp, target) < 50) {
        // हिट रेडियस बढ़ाया गया
        _sim.s2ClickAnim = 0;
        _advanceStep();
        handled = true;
      } else {
        handled = true;
      }
    }

    if (_sim.scenario == 3 && !handled) {
      if (_sim.step == 1 &&
          !_sim.pencilActive &&
          wp.dx > -350 &&
          wp.dx < -230 &&
          wp.dy > -150 &&
          wp.dy < -10) {
        _sim.pencilActive = true;
        _advanceStep();
        handled = true;
      }
      if (_sim.step == 2 && _sim.pencilActive) {
        double rOuter = 160 * 1.2;
        Offset target = Offset(
          -100 + rOuter * math.cos(_degToRad(-70)),
          50 + rOuter * math.sin(_degToRad(-70)),
        );
        if (_dist(wp, target) < 40) {
          _sim.s3Point = target;
          _advanceStep();
          handled = true;
        } else {
          handled = true;
        }
      }
      if (_sim.step == 3 &&
          _sim.pencilActive &&
          _dist(wp, const Offset(-100, 50)) < 30) {
        _sim.activeDragEntity = DragEntity.pencil;
        _sim.dragOffsetX = wp.dx;
        _sim.dragOffsetY = wp.dy;
        handled = true;
      }
    }

    if (_sim.scenario == 5 && !handled) {
      if (!_sim.pencilActive &&
          wp.dx > -400 &&
          wp.dx < -280 &&
          wp.dy > -100 &&
          wp.dy < 40) {
        _sim.pencilActive = true;
        handled = true;
      }
      if (_sim.pencilActive && _dist(wp, const Offset(0, 150)) < 30) {
        _sim.activeDragEntity = DragEntity.pencil;
        _sim.dragOffsetX = wp.dx;
        _sim.dragOffsetY = wp.dy;
        handled = true;
      }
    }

    if (!handled && _sim.protractor.visible) {
      double d = _dist(wp, Offset(_sim.protractor.x, _sim.protractor.y));
      double rOuter = 160 * 1.2;
      if (d < 30) {
        _sim.activeDragEntity = DragEntity.protractorCenter;
        handled = true;
      } else if (d > rOuter - 40 && d < rOuter + 20) {
        _sim.activeDragEntity = DragEntity.protractorEdge;
        _sim.dragStartRot = _sim.protractor.rotation;
        _sim.mouseStartAngle = _radToDeg(
          math.atan2(wp.dy - _sim.protractor.y, wp.dx - _sim.protractor.x),
        );
        handled = true;
      }
    }

    // यदि इंटरैक्शन सफल हुआ तो क्लिक ध्वनि प्ले करें (यदि advanceStep से पहले प्ले नहीं हुआ)
    if (handled && _sim.step < _sim.maxSteps) {
      playClick();
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      setState(() {
        _sim.zoom = (_baseZoom * details.scale).clamp(0.4, 2.5);
        _sim.panX += details.focalPointDelta.dx;
        _sim.panY += details.focalPointDelta.dy;
      });
      return;
    }

    Offset wp = _getWorldPos(details.localFocalPoint);
    setState(() {
      if (_sim.activeDragEntity == DragEntity.protractorCenter) {
        _sim.protractor.x = wp.dx;
        _sim.protractor.y = wp.dy;
      } else if (_sim.activeDragEntity == DragEntity.protractorEdge) {
        double dx = wp.dx - _sim.protractor.x;
        double dy = wp.dy - _sim.protractor.y;
        double angle = _radToDeg(math.atan2(dy, dx));
        _sim.protractor.rotation = _normalizeAngle(
          angle - _sim.mouseStartAngle + _sim.dragStartRot,
        );
      } else if (_sim.activeDragEntity == DragEntity.pencil) {
        _sim.dragOffsetX = wp.dx;
        _sim.dragOffsetY = wp.dy;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_sim.activeDragEntity == DragEntity.protractorCenter) {
      if (_sim.scenario == 1 &&
          _sim.step == 0 &&
          _dist(
                Offset(_sim.protractor.x, _sim.protractor.y),
                const Offset(0, 50),
              ) <
              40) {
        _sim.protractor.x = 0;
        _sim.protractor.y = 50;
        _advanceStep();
      } else if (_sim.scenario == 2 &&
          _sim.step == 0 &&
          _dist(
                Offset(_sim.protractor.x, _sim.protractor.y),
                const Offset(50, 50),
              ) <
              40) {
        _sim.protractor.x = 50;
        _sim.protractor.y = 50;
        _advanceStep();
      } else if (_sim.scenario == 3 &&
          _sim.step == 0 &&
          _dist(
                Offset(_sim.protractor.x, _sim.protractor.y),
                const Offset(-100, 50),
              ) <
              40) {
        _sim.protractor.x = -100;
        _sim.protractor.y = 50;
        _advanceStep();
      } else if (_sim.scenario == 4 &&
          _dist(
                Offset(_sim.protractor.x, _sim.protractor.y),
                const Offset(200, 100),
              ) <
              40) {
        _sim.protractor.x = 200;
        _sim.protractor.y = 100;
      }
    } else if (_sim.activeDragEntity == DragEntity.protractorEdge) {
      double rot = _normalizeAngle(_sim.protractor.rotation);
      bool isZero = rot < 15 || rot > 345;

      if (_sim.scenario == 1 &&
          _sim.step == 1 &&
          _sim.protractor.x == 0 &&
          isZero) {
        _sim.protractor.rotation = 0;
        _advanceStep();
      } else if (_sim.scenario == 2 &&
          _sim.step == 1 &&
          _sim.protractor.x == 50 &&
          isZero) {
        _sim.protractor.rotation = 0;
        _advanceStep();
      } else if (_sim.scenario == 3 &&
          _sim.step == 0 &&
          _sim.protractor.x == -100 &&
          isZero) {
        _sim.protractor.rotation = 0;
        _advanceStep();
      } else if (_sim.scenario == 4 && _sim.protractor.x == 200) {
        List<double> snaps = [0, 125, 180, 305];
        for (double sa in snaps) {
          if ((rot - sa).abs() < 15 || (rot - sa).abs() > 345) {
            _sim.protractor.rotation = sa;
            break;
          }
        }
      }
    } else if (_sim.activeDragEntity == DragEntity.pencil) {
      if (_sim.scenario == 3 &&
          _sim.step == 3 &&
          _dist(Offset(_sim.dragOffsetX, _sim.dragOffsetY), _sim.s3Point!) <
              30) {
        _sim.s3LineDrawn = true;
        _sim.pencilActive = false;
        _sim.protractor.visible = false;
        _advanceStep();
      } else if (_sim.scenario == 5 && !_sim.s5LineDrawn) {
        if (_dist(
              Offset(_sim.dragOffsetX, _sim.dragOffsetY),
              const Offset(0, 150),
            ) >
            100) {
          _sim.s5Point = Offset(_sim.dragOffsetX, _sim.dragOffsetY);
          _sim.s5LineDrawn = true;
        }
      }
    }
    setState(() {
      _sim.activeDragEntity = DragEntity.none;
    });
  }

  void _checkAngleS4() {
    int? val = int.tryParse(_s4Controller.text);
    if (val != null && val >= 124 && val <= 126) {
      _sim.s4AngleChecked = true;
      _advanceStep();
    } else {
      playError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('s4_hint')), backgroundColor: Colors.orange),
      );
    }
  }

  void _aimTelescopeS5() {
    if (!_sim.s5LineDrawn) return;

    playClick();
    setState(() {
      _sim.s5Aiming = true;
    });
    double a = _radToDeg(
      math.atan2(_sim.s5Point!.dy - 150, _sim.s5Point!.dx - 0),
    ).abs();
    _sim.s5TelescopeRot = a;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _sim.s5Aiming = false;
          if (a >= 33 && a <= 37) {
            _sim.s5Success = true;
            _advanceStep();
          } else {
            playError();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t('s5_err')), backgroundColor: Colors.red),
            );
            _sim.s5LineDrawn = false;
            _sim.s5Point = null;
            _sim.s5TelescopeRot = 0;
            _sim.pencilActive = false;
            _sim.protractor.visible = true;
            _sim.protractor.x = 250;
            _sim.protractor.y = 150;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sidebarWidth = math.max(300, sw * 0.3);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // कैनवस क्षेत्र (CANVAS AREA)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: 0,
              left: _sim.isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: GestureDetector(
                  onTapDown: (details) {
                    _handleScaleStart(
                      ScaleStartDetails(
                        focalPoint: details.globalPosition,
                        localFocalPoint: details.localPosition,
                        pointerCount: 1,
                      ),
                    );
                  },
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return CustomPaint(
                        key: _canvasKey,
                        painter: LabPainter(
                          sim: _sim,
                          tick: _animController.value,
                        ),
                        child: Container(),
                      );
                    },
                  ),
                ),
              ),
            ),

            // HUD (कैनवस के नीचे मध्य में)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 20,
              right: 0,
              left: _sim.isSidebarOpen ? sidebarWidth : 0,
              child: _sim.step < _sim.maxSteps
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xE60F172A),
                          borderRadius: BorderRadius.circular(20),
                          border: const Border(
                            top: BorderSide(color: Colors.indigo, width: 4),
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
                            const Icon(
                              Icons.info_outline,
                              color: Colors.indigoAccent,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                t('s${_sim.scenario}_hud${_sim.step + 1}'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // सफलता पॉपअप (Success Popup) - बीच कैनवस में (Central Canvas)
            if (_sim.step == _sim.maxSteps)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: 0,
                bottom: 0,
                right: 0,
                left: _sim.isSidebarOpen ? sidebarWidth : 0,
                child: Container(
                  color: Colors.black54, // Semi-transparent overlay
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.greenAccent, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.yellowAccent,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('scenarioComplete'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _nextScenarioLogic,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _sim.scenario < 5
                                  ? t('nextScenario')
                                  : t('finishLab'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .yellowAccent, // पॉपअप बटन का पीला रंग
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // (SIDEBAR)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: _sim.isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // (Header Section)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 60,
                                  left: 20,
                                  right: 20,
                                  bottom: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.stars,
                                          color: Colors.yellowAccent,
                                          size: 40,
                                        ),
                                        Expanded(
                                          child: Text(
                                            t('appTitle'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      t('appSubtitle'),
                                      style: const TextStyle(
                                        color: Colors.indigoAccent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: _toggleLanguage,
                                            icon: const Icon(
                                              Icons.language,
                                              size: 18,
                                            ),
                                            label: Text(
                                              _sim.lang.toUpperCase(),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.1),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: _resetLab,
                                            icon: const Icon(
                                              Icons.refresh,
                                              size: 18,
                                            ),
                                            label: const Text('RESET'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent
                                                  .withOpacity(0.15),
                                              foregroundColor: Colors.redAccent,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // परिदृश्य और चरण अनुभाग (Scenarios & Steps Section)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t('selectScenario').toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
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
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _sim.scenario,
                                          isExpanded: true,
                                          dropdownColor: const Color(
                                            0xFF1E293B,
                                          ),
                                          onTap: playDropdown,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          items: [1, 2, 3, 4, 5]
                                              .map(
                                                (id) => DropdownMenuItem(
                                                  value: id,
                                                  child: Text(
                                                    t('s${id}_title'),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              playClick();
                                              _loadScenario(val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // उद्देश्य (Objective)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.indigo.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.flag,
                                                color: Colors.pinkAccent,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                t('learnLbl'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            t('s${_sim.scenario}_obj'),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // चरण (Steps)
                                    ...List.generate(_sim.maxSteps, (i) {
                                      bool isActive = i == _sim.step;
                                      bool isCompleted = i < _sim.step;

                                      Color bgColor = isActive
                                          ? Colors.indigo.withOpacity(0.2)
                                          : (isCompleted
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.transparent);
                                      Color borderColor = isActive
                                          ? Colors.indigo
                                          : (isCompleted
                                                ? Colors.green
                                                : Colors.white12);
                                      Color iconColor = isCompleted
                                          ? Colors.green
                                          : (isActive
                                                ? Colors.white
                                                : Colors.white38);
                                      Color textColor = isActive || isCompleted
                                          ? Colors.white
                                          : Colors.white38;

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: borderColor,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            isCompleted
                                                ? const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 24,
                                                  )
                                                : Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: isActive
                                                          ? Colors.indigo
                                                          : Colors.white12,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${i + 1}',
                                                        style: TextStyle(
                                                          color: iconColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${t('stepLabel')} ${i + 1}',
                                                    style: TextStyle(
                                                      color: textColor
                                                          .withOpacity(0.5),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    t(
                                                      's${_sim.scenario}_step${i + 1}_task',
                                                    ),
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (isCompleted) ...[
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        t(
                                                          's${_sim.scenario}_step${i + 1}_out',
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors
                                                              .greenAccent,
                                                          fontSize: 12,
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
                                    }),

                                    // कार्रवाई क्षेत्र (Action Area)
                                    if (_sim.scenario == 4 &&
                                        _sim.step < _sim.maxSteps) ...[
                                      const SizedBox(height: 24),
                                      TextField(
                                        controller: _s4Controller,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFF0F172A),
                                          hintText: t('s4_placeholder'),
                                          hintStyle: const TextStyle(
                                            color: Colors.white38,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _checkAngleS4,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          minimumSize: const Size(
                                            double.infinity,
                                            50,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          t('s4_btn_check'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],

                                    if (_sim.scenario == 5 &&
                                        _sim.step < _sim.maxSteps &&
                                        _sim.s5LineDrawn) ...[
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: _aimTelescopeS5,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          minimumSize: const Size(
                                            double.infinity,
                                            50,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          t('s5_btn_aim:'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],

                                    // साइडबार अगला परिदृश्य बटन (Next Scenario Button in Sidebar)
                                    if (_sim.step == _sim.maxSteps) ...[
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: _nextScenarioLogic,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _sim.scenario < 5
                                              ? Colors.indigo
                                              : Colors.orange,
                                          minimumSize: const Size(
                                            double.infinity,
                                            60,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _sim.scenario < 5
                                              ? t('nextScenario')
                                              : t('finishLab'),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .yellowAccent, // पीले रंग का टेक्स्ट (Yellow text)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const Spacer(), // इसे नीचे धकेलने के लिए
                              // पाद लेख (Footer) - अब स्क्रॉल होने योग्य सामग्री के अंदर
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                color: const Color(0xFF0F172A),
                                child: const Text(
                                  "© ZeroScienceLab - Fall in love with math and Science",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
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

            // मेनू टॉगल बटन (ऊपर-बाएं स्थिर) - MENU TOGGLE BUTTON
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    playClick(); // मेनू खोलने/बंद करने पर ध्वनि
                    setState(() {
                      _sim.isSidebarOpen = !_sim.isSidebarOpen;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      _sim.isSidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            // कर्टेन स्क्रीन (सब कुछ ओवरले करता है) - CURTAIN SCREEN
            if (_sim.isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.explore,
                            size: 100,
                            color: Colors.indigoAccent,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('shutterTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_circle_fill, size: 28),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: Colors.indigoAccent,
                            ),
                            onPressed: () {
                              curtainScreen(); // सिमुलेशन प्रवेश ध्वनि
                              setState(() {
                                _sim.isCurtainOpen = false;
                              });
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

// ==========================================
// कैनवस के लिए कस्टम पेंटर (CUSTOM PAINTER FOR CANVAS)
// ==========================================
class LabPainter extends CustomPainter {
  final SimState sim;
  final double tick;

  LabPainter({required this.sim, required this.tick});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + sim.panX, size.height / 2 + sim.panY);
    canvas.scale(sim.zoom, sim.zoom);

    if (sim.scenario == 1) _renderScenario1(canvas, size);
    if (sim.scenario == 2) _renderScenario2(canvas, size);
    if (sim.scenario == 3) _renderScenario3(canvas, size);
    if (sim.scenario == 4) _renderScenario4(canvas, size);
    if (sim.scenario == 5) _renderScenario5(canvas, size);

    canvas.restore();
  }

  void _drawLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (dashed) {
      double dist = (p2 - p1).distance;
      double dashLen = 8, gapLen = 8;
      int count = dist ~/ (dashLen + gapLen);
      Offset dir = (p2 - p1) / dist;
      for (int i = 0; i < count; i++) {
        Offset start = p1 + dir * (i * (dashLen + gapLen));
        canvas.drawLine(start, start + dir * dashLen, paint);
      }
    } else {
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    double size,
    Color color, {
    bool bold = false,
    TextAlign align = TextAlign.center,
  }) {
    final textStyle = TextStyle(
      color: color,
      fontSize: size,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawProtractor(
    Canvas canvas,
    double x,
    double y,
    double rotDeg,
    double scale, {
    bool glowInner = false,
    bool glowOuter = false,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotDeg * math.pi / 180);
    canvas.scale(scale, scale);

    const double rOuter = 160;
    const double rInner = 90;
    const Color outline = Color(0xFFF8FAFC);
    const Color baseColor = Color(0x99FFFFFF);

    // चमक (Glows)
    if (glowOuter) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: rOuter - 25),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = Colors.red.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15,
      );
    }
    if (glowInner) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: rInner + 20),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = Colors.blue.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15,
      );
    }

    // बेस ग्लास (Base glass)
    Path glassPath = Path()
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: rOuter),
        math.pi,
        math.pi,
        true,
      )
      ..lineTo(rOuter, 30)
      ..lineTo(-rOuter, 30)
      ..close();

    Path innerCutout = Path()
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: rInner),
        math.pi,
        math.pi,
        true,
      )
      ..lineTo(rInner, 0)
      ..lineTo(-rInner, 0)
      ..close();

    Path combined = Path.combine(
      PathOperation.difference,
      glassPath,
      innerCutout,
    );
    canvas.drawPath(combined, Paint()..color = baseColor);

    // आउटलाइन्स (Outlines)
    Paint strokePaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(glassPath, strokePaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: rInner),
      math.pi,
      math.pi,
      false,
      strokePaint,
    );

    // बेसलाइन और केंद्र (Baseline & Center)
    _drawLine(
      canvas,
      const Offset(-rOuter, 0),
      const Offset(rOuter, 0),
      outline,
      2,
    );
    _drawLine(canvas, const Offset(0, -15), const Offset(0, 15), outline, 2);
    canvas.drawCircle(Offset.zero, 4, Paint()..color = outline);

    // स्केल्स (Scales)
    for (int a = 0; a <= 180; a++) {
      double rad = (180 - a) * math.pi / 180;
      double cosA = math.cos(rad), sinA = math.sin(rad);
      double lOut = a % 10 == 0 ? 15 : (a % 5 == 0 ? 10 : 5);
      double lIn = a % 10 == 0 ? 10 : (a % 5 == 0 ? 7 : 4);

      _drawLine(
        canvas,
        Offset((rOuter - lOut) * cosA, -(rOuter - lOut) * sinA),
        Offset(rOuter * cosA, -rOuter * sinA),
        outline,
        a % 10 == 0 ? 2 : 1,
      );
      _drawLine(
        canvas,
        Offset(rInner * cosA, -rInner * sinA),
        Offset((rInner + lIn) * cosA, -(rInner + lIn) * sinA),
        outline,
        a % 10 == 0 ? 2 : 1,
      );

      if (a % 10 == 0) {
        canvas.save();
        canvas.translate((rOuter - 25) * cosA, -(rOuter - 25) * sinA);
        canvas.rotate(math.pi / 2 - rad);
        _drawText(
          canvas,
          a.toString(),
          Offset.zero,
          glowOuter && a == 120 ? 18 : 10,
          outline,
          bold: glowOuter && a == 120,
        );
        canvas.restore();

        canvas.save();
        canvas.translate((rInner + 20) * cosA, -(rInner + 20) * sinA);
        canvas.rotate(math.pi / 2 - rad);
        _drawText(
          canvas,
          (180 - a).toString(),
          Offset.zero,
          glowInner && a == 55 ? 18 : 10,
          outline,
          bold: glowInner && a == 55,
        );
        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _drawToolbox(Canvas canvas, double x, double y, double w, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y - 20, w, 20),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    _drawText(
      canvas,
      "TOOLBOX",
      Offset(x + w / 2, y - 10),
      12,
      Colors.white,
      bold: true,
    );
  }

  void _drawPencil(
    Canvas canvas,
    double x,
    double y,
    double rot,
    double scale,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rot * math.pi / 180);
    canvas.scale(scale, scale);

    Path body = Path()
      ..moveTo(-5, -40)
      ..lineTo(5, -40)
      ..lineTo(5, 20)
      ..lineTo(0, 40)
      ..lineTo(-5, 20)
      ..close();
    canvas.drawPath(body, Paint()..color = Colors.amber);
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawLine(
      canvas,
      const Offset(-2, -40),
      const Offset(-2, 18),
      Colors.black,
      1,
    );
    _drawLine(
      canvas,
      const Offset(2, -40),
      const Offset(2, 18),
      Colors.black,
      1,
    );

    Path tip = Path()
      ..moveTo(-2, 32)
      ..lineTo(2, 32)
      ..lineTo(0, 40)
      ..close();
    canvas.drawPath(tip, Paint()..color = Colors.black);

    canvas.drawRect(
      const Rect.fromLTWH(-5, -50, 10, 10),
      Paint()..color = Colors.pink[200]!,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-5, -45, 10, 5),
      Paint()..color = Colors.grey[400]!,
    );

    canvas.restore();
  }

  void _renderScenario1(Canvas canvas, Size size) {
    double vx = 0, vy = 50, a2 = -55;
    bool glow1 =
        sim.step == 1 && sim.activeDragEntity == DragEntity.protractorCenter;

    _drawLine(
      canvas,
      Offset(vx, vy),
      Offset(vx + 250, vy),
      glow1 ? Colors.yellow : Colors.white,
      glow1 ? 6 : 4,
    );
    _drawLine(
      canvas,
      Offset(vx, vy),
      Offset(
        vx + 250 * math.cos(a2 * math.pi / 180),
        vy + 250 * math.sin(a2 * math.pi / 180),
      ),
      Colors.white,
      4,
    );

    if (sim.step == 0 && sim.activeDragEntity == DragEntity.protractorCenter) {
      canvas.drawCircle(Offset(vx, vy), 15, Paint()..color = Colors.yellow);
    }
    canvas.drawCircle(Offset(vx, vy), 6, Paint()..color = Colors.red);

    _drawToolbox(canvas, -350, 100, 160, 100);
    if (sim.protractor.visible) {
      _drawProtractor(
        canvas,
        sim.protractor.x,
        sim.protractor.y,
        sim.protractor.rotation,
        1.2,
        glowInner: sim.step == 2,
      );
    }

    if (sim.s1ClickAnim != null) {
      double rTarget = 110 * 1.2; // गणना को सटीक बनाया
      double animSize = sim.s1ClickAnim! * 2.0;
      canvas.drawCircle(
        Offset(
          vx + rTarget * math.cos(a2 * math.pi / 180),
          vy + rTarget * math.sin(a2 * math.pi / 180),
        ),
        animSize,
        Paint()
          ..color = Colors.green.withOpacity(
            (1 - sim.s1ClickAnim! / 20).clamp(0, 1),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
  }

  void _renderScenario2(Canvas canvas, Size size) {
    double vx = 50, vy = 50;
    bool glow1 =
        sim.step == 1 && sim.activeDragEntity == DragEntity.protractorCenter;

    _drawLine(
      canvas,
      Offset(vx, vy),
      Offset(vx - 250, vy),
      glow1 ? Colors.yellow : Colors.white,
      glow1 ? 6 : 4,
    );
    _drawLine(
      canvas,
      Offset(vx, vy),
      Offset(
        vx + 250 * math.cos(-60 * math.pi / 180),
        vy + 250 * math.sin(-60 * math.pi / 180),
      ),
      Colors.white,
      4,
    );

    if (sim.step == 0 && sim.activeDragEntity == DragEntity.protractorCenter) {
      canvas.drawCircle(Offset(vx, vy), 15, Paint()..color = Colors.yellow);
    }
    canvas.drawCircle(Offset(vx, vy), 6, Paint()..color = Colors.red);

    _drawToolbox(canvas, 200, 100, 160, 100);
    if (sim.protractor.visible) {
      _drawProtractor(
        canvas,
        sim.protractor.x,
        sim.protractor.y,
        sim.protractor.rotation,
        1.2,
        glowOuter: sim.step == 2,
      );
    }

    if (sim.s2ClickAnim != null) {
      double rTarget = 135 * 1.2; // गणना को सटीक बनाया
      double animSize = sim.s2ClickAnim! * 2.0;
      canvas.drawCircle(
        Offset(
          vx + rTarget * math.cos(-60 * math.pi / 180),
          vy + rTarget * math.sin(-60 * math.pi / 180),
        ),
        animSize,
        Paint()
          ..color = Colors.green.withOpacity(
            (1 - sim.s2ClickAnim! / 20).clamp(0, 1),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
  }

  void _renderScenario3(Canvas canvas, Size size) {
    double vx = -100, vy = 50;
    _drawLine(canvas, Offset(vx, vy), Offset(vx + 300, vy), Colors.white, 4);
    canvas.drawCircle(Offset(vx, vy), 6, Paint()..color = Colors.red);

    _drawToolbox(canvas, -350, -150, 120, 140);
    if (sim.step == 1 && !sim.pencilActive) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-350, -150, 120, 140),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.yellow.withOpacity(0.3),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-350, -150, 120, 140),
          const Radius.circular(8),
        ),
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    if (!sim.pencilActive && sim.step >= 1) {
      _drawPencil(canvas, -290, -100, 45, 1.2);
    }

    if (sim.protractor.visible) {
      _drawProtractor(
        canvas,
        sim.protractor.x,
        sim.protractor.y,
        sim.protractor.rotation,
        1.2,
      );
    }

    if (sim.step == 2 && sim.protractor.x == vx) {
      double rTarget = 160 * 1.2;
      double px = vx + rTarget * math.cos(-70 * math.pi / 180);
      double py = vy + rTarget * math.sin(-70 * math.pi / 180);
      double pulse = 10 + math.sin(tick * math.pi * 10) * 3;
      canvas.drawCircle(Offset(px, py), pulse, Paint()..color = Colors.yellow);
    }

    if (sim.s3Point != null) {
      canvas.drawCircle(sim.s3Point!, 5, Paint()..color = Colors.green);
    }

    if (sim.s3LineDrawn) {
      _drawLine(canvas, Offset(vx, vy), sim.s3Point!, Colors.white, 4);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(vx, vy), radius: 40),
        0,
        -70 * math.pi / 180,
        false,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      _drawText(
        canvas,
        "70°",
        Offset(
          vx + 50 * math.cos(-35 * math.pi / 180),
          vy + 50 * math.sin(-35 * math.pi / 180),
        ),
        16,
        Colors.blue,
        bold: true,
      );
    }

    if (sim.pencilActive) {
      double px = sim.dragOffsetX;
      double py = sim.dragOffsetY;
      if (sim.step == 3 && sim.activeDragEntity == DragEntity.pencil) {
        _drawLine(
          canvas,
          Offset(vx, vy),
          Offset(px, py),
          Colors.grey,
          2,
          dashed: true,
        );
      }
      _drawPencil(canvas, px + 5, py - 40, 0, 1);
    }
  }

  void _renderScenario4(Canvas canvas, Size size) {
    // ब्लूप्रिंट ग्रिड (Blueprint Grid)
    canvas.drawRect(
      const Rect.fromLTWH(-400, -250, 800, 500),
      Paint()..color = const Color(0xFF1E3A8A),
    );
    Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    for (double i = -400; i <= 400; i += 20) {
      canvas.drawLine(Offset(i, -250), Offset(i, 250), gridPaint);
    }
    for (double i = -250; i <= 250; i += 20) {
      canvas.drawLine(Offset(-400, i), Offset(400, i), gridPaint);
    }
    canvas.drawRect(
      const Rect.fromLTWH(-400, -250, 800, 500),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    double roofX = -150, roofY = 0;
    _drawLine(
      canvas,
      Offset(roofX - 100, roofY + 100),
      Offset(roofX + 100, roofY + 100),
      Colors.blue[300]!,
      4,
    );
    _drawLine(
      canvas,
      Offset(roofX - 100, roofY + 100),
      Offset(roofX - 100, roofY),
      Colors.blue[300]!,
      4,
    );
    _drawLine(
      canvas,
      Offset(roofX + 100, roofY + 100),
      Offset(roofX + 100, roofY),
      Colors.blue[300]!,
      4,
    );

    double dx = 90 * math.tan(62.5 * math.pi / 180);
    _drawLine(
      canvas,
      Offset(roofX, roofY - 80),
      Offset(roofX - dx, roofY + 10),
      Colors.blue[300]!,
      4,
      dashed: true,
    );
    _drawLine(
      canvas,
      Offset(roofX, roofY - 80),
      Offset(roofX + dx, roofY + 10),
      Colors.blue[300]!,
      4,
      dashed: true,
    );
    _drawText(
      canvas,
      "TARGET: 125°",
      Offset(roofX, roofY - 110),
      18,
      Colors.white,
      bold: true,
    );

    _drawToolbox(canvas, -350, 100, 160, 100);

    double woodX = 200, woodY = 100, woodL = 120;
    canvas.save();
    canvas.translate(woodX, woodY);
    canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.red);

    Path wood = Path()
      ..moveTo(0, 0)
      ..lineTo(woodL, 0)
      ..lineTo(
        woodL * math.cos(-125 * math.pi / 180),
        woodL * math.sin(-125 * math.pi / 180),
      )
      ..close();
    canvas.drawPath(wood, Paint()..color = Colors.brown[700]!);
    canvas.drawPath(
      wood,
      Paint()
        ..color = Colors.brown[900]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    _drawLine(
      canvas,
      const Offset(20, -10),
      const Offset(80, -10),
      Colors.brown[900]!,
      2,
      dashed: true,
    );
    _drawLine(
      canvas,
      const Offset(15, -25),
      const Offset(60, -25),
      Colors.brown[900]!,
      2,
      dashed: true,
    );
    _drawLine(
      canvas,
      const Offset(10, -40),
      const Offset(40, -40),
      Colors.brown[900]!,
      2,
      dashed: true,
    );
    canvas.restore();

    if (sim.protractor.visible) {
      _drawProtractor(
        canvas,
        sim.protractor.x,
        sim.protractor.y,
        sim.protractor.rotation,
        1.2,
      );
    }

    if (sim.s4AngleChecked) {
      canvas.save();
      canvas.translate(roofX, roofY - 80);
      Path fittedWood = Path()
        ..moveTo(0, 0)
        ..lineTo(
          -woodL * math.cos(27.5 * math.pi / 180),
          woodL * math.sin(27.5 * math.pi / 180),
        )
        ..lineTo(
          woodL * math.cos(27.5 * math.pi / 180),
          woodL * math.sin(27.5 * math.pi / 180),
        )
        ..close();
      canvas.drawPath(fittedWood, Paint()..color = Colors.brown[700]!);
      canvas.drawPath(
        fittedWood,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      canvas.restore();
    }
  }

  void _renderScenario5(Canvas canvas, Size size) {
    // तारे (Stars)
    Paint starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 50; i++) {
      double sx = -1000 + (math.sin(i * 123) * 2000);
      double sy = -800 + (math.cos(i * 321) * 1000);
      canvas.drawCircle(Offset(sx, sy), (i % 3) * 1.0, starPaint);
    }

    _drawLine(
      canvas,
      const Offset(-1000, 150),
      const Offset(1000, 150),
      Colors.grey[800]!,
      4,
    );
    _drawText(
      canvas,
      "HORIZON (0°)",
      const Offset(-300, 170),
      16,
      Colors.grey[400]!,
      bold: true,
    );

    double vx = 0, vy = 150;

    if (sim.s5Success) {
      double cx = vx + 400 * math.cos(-35 * math.pi / 180);
      double cy = vy + 400 * math.sin(-35 * math.pi / 180);
      canvas.drawCircle(
        Offset(cx, cy),
        15,
        Paint()..color = Colors.lightBlue[200]!,
      );
      _drawLine(
        canvas,
        Offset(cx, cy),
        Offset(cx - 80, cy - 40),
        Colors.lightBlue[200]!,
        4,
      );
      _drawLine(
        canvas,
        Offset(cx, cy),
        Offset(cx - 60, cy - 60),
        Colors.lightBlue[200]!,
        2,
      );
    } else if (sim.s5Aiming) {
      double cx = vx + 400 * math.cos(-sim.s5TelescopeRot * math.pi / 180);
      double cy = vy + 400 * math.sin(-sim.s5TelescopeRot * math.pi / 180);
      _drawText(
        canvas,
        "SEARCHING...",
        Offset(cx, cy),
        20,
        Colors.white,
        bold: true,
      );
    }

    if (sim.s5LineDrawn) {
      _drawLine(
        canvas,
        Offset(vx, vy),
        sim.s5Point!,
        Colors.yellow,
        3,
        dashed: true,
      );
      double a = math.atan2(sim.s5Point!.dy - vy, sim.s5Point!.dx - vx);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(vx, vy), radius: 60),
        0,
        a,
        false,
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        "${(a * 180 / math.pi).round().abs()}°",
        Offset(vx + 80 * math.cos(a / 2), vy + 80 * math.sin(a / 2)),
        16,
        Colors.yellow,
        bold: true,
      );
    }

    // टेलीस्कोप (Telescope)
    canvas.save();
    canvas.translate(vx, vy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, 0, 60, 10),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.blueGrey,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-30, 0, 60, 10),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawLine(canvas, Offset.zero, const Offset(0, -50), Colors.grey, 6);
    canvas.drawCircle(
      const Offset(0, -50),
      15,
      Paint()..color = Colors.grey[300]!,
    );
    canvas.drawCircle(
      const Offset(0, -50),
      15,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );

    canvas.translate(0, -50);
    canvas.rotate(-sim.s5TelescopeRot * math.pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-20, -15, 140, 30),
        Radius.zero,
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-20, -15, 140, 30),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(120, -20, 20, 40),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.blue,
    );
    canvas.drawRect(
      const Rect.fromLTWH(120, -20, 20, 40),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();

    if (sim.step == 0 && !sim.s5Success) {
      _drawToolbox(canvas, -400, -100, 120, 140);
      if (!sim.pencilActive) _drawPencil(canvas, -340, -50, 45, 1.2);
      if (sim.protractor.visible) {
        _drawProtractor(
          canvas,
          sim.protractor.x,
          sim.protractor.y,
          sim.protractor.rotation,
          1.2,
        );
      }

      if (sim.pencilActive) {
        double px = sim.dragOffsetX;
        double py = sim.dragOffsetY;
        if (sim.activeDragEntity == DragEntity.pencil) {
          _drawLine(
            canvas,
            Offset(vx, vy),
            Offset(px, py),
            Colors.yellow,
            2,
            dashed: true,
          );
        }
        _drawPencil(canvas, px + 5, py - 40, 0, 1);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
