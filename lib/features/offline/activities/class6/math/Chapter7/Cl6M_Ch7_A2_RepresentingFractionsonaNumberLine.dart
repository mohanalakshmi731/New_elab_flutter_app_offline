// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, camel_case_types

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(Cl6M_Ch7_A2_RepresentingFractionsonaNumberLine());
  });
}

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': "Representing Fractions on a Number Line",
    'appSubtitle': "Class 6 • THE RIBBON RULER",
    'enterLab': "Enter Simulation",
    'appTitle': "Representing Fractions",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Mission Objective:",
    'settings': "Settings",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You have successfully mastered representing fractions on a number line!",
    'lbl_toolbox': "Toolbox",
    'lbl_ribbon': "Magic Ribbon",
    'lbl_divider': "Divider Tool",
    'lbl_frog': "Frog",
    'lbl_flag': "Marker Flag",
    'lbl_dial': "Dial:",
    's1_title': "1. The First Cut: Placing 1/2",
    's1_obj':
        "Understand how the denominator divides a whole unit and how the numerator marks a position within that unit.",
    's1_step1_task':
        "DRAG the 'Magic Ribbon' from the toolbox and DROP it between 0 and 1.",
    's1_step1_out': "The ribbon covers the segment from 0 to 1.",
    's1_step2_task': "CLICK the 'Divider Tool' dial to set it to '2'.",
    's1_step2_out': "The Divider Tool is now configured to make 2 equal parts.",
    's1_step3_task':
        "DRAG the activated 'Divider Tool' and DROP it onto the Ribbon.",
    's1_step3_out': "The tool divides the ribbon into 2 equal segments.",
    's1_step4_task': "DRAG the 'Frog' from the toolbox to position 0.",
    's1_step4_out': "The frog is ready to jump.",
    's1_step5_task': "CLICK on the 1/2 mark you made on the ribbon.",
    's1_step5_out':
        "You divided the whole into 2 parts (denominator). You hopped 1 part (numerator). You have found 1/2!",
    's1_hud1': "Drag Ribbon to 0-1",
    's1_hud2': "Set dial to 2",
    's1_hud3': "Cut the ribbon",
    's1_hud4': "Place frog at 0",
    's1_hud5': "Click the 1/2 mark",
    's2_title': "2. Multiple Hops: Placing 3/4",
    's2_obj':
        "Represent a proper fraction by performing multiple 'hops' after dividing the whole.",
    's2_step1_task': "CLICK the 'Divider Tool' dial to set it to '4'.",
    's2_step1_out': "The Divider Tool is set to 4.",
    's2_step2_task': "DRAG the 'Divider Tool' and DROP it onto the Ribbon.",
    's2_step2_out': "The ribbon is divided into 4 equal segments.",
    's2_step3_task': "DRAG the 'Frog' to position 0.",
    's2_step3_out': "The frog is ready.",
    's2_step4_task': "CLICK on the third mark from 0.",
    's2_step4_out':
        "You divided the whole into 4 parts. You hopped 3 parts. You have found 3/4!",
    's2_hud1': "Set dial to 4",
    's2_hud2': "Cut the ribbon",
    's2_hud3': "Place frog at 0",
    's2_hud4': "Click the 3rd mark (3/4)",
    's3_title': "3. Beyond the Whole: Placing 5/3",
    's3_obj':
        "Represent an improper fraction, understanding that the division continues past '1'.",
    's3_step1_task': "DRAG Ribbons to cover the 0-1 AND 1-2 segments.",
    's3_step1_out': "Both segments are covered.",
    's3_step2_task': "Set Divider to '3' and cut the first ribbon (0-1).",
    's3_step2_out': "First ribbon cut into thirds.",
    's3_step3_task': "Cut the second ribbon (1-2) with the Divider.",
    's3_step3_out': "Second ribbon cut into thirds.",
    's3_step4_task': "DRAG the 'Frog' to 0.",
    's3_step4_out': "Frog is ready.",
    's3_step5_task': "CLICK on the fifth mark from 0.",
    's3_step5_out': "You hopped 5 parts in total. You have found 5/3!",
    's3_hud1': "Place ribbons on 0-1 and 1-2",
    's3_hud2': "Set dial to 3, cut first ribbon",
    's3_hud3': "Cut second ribbon",
    's3_hud4': "Place frog at 0",
    's3_hud5': "Click the 5th mark (5/3)",
    's4_title': "4. Unsolved Challenge 1 (2/5)",
    's4_obj':
        "Use the tools provided to correctly place a flag at the 2/5 mark.",
    's4_step1_task':
        "Place a ribbon on 0-1, cut it into 5 parts, and place the flag at 2/5.",
    's4_step1_out': "Excellent! You placed the flag exactly at 2/5.",
    's4_hud1': "Place Ribbon, cut to 5, and place Flag at 2/5.",
    's5_title': "5. Unsolved Challenge 2 (7/4)",
    's5_obj':
        "Use the tools provided to correctly place a flag at the 7/4 mark.",
    's5_step1_task':
        "Place ribbons, cut them into 4 parts each, and place the flag at 7/4.",
    's5_step1_out': "Fantastic! You found the improper fraction 7/4.",
    's5_hud1': "Place Ribbons, cut to 4, and place Flag at 7/4.",
  },
  'hi': {
    'shutterTitle': "संख्या रेखा पर भिन्नों को दर्शाना",
    'appSubtitle': "कक्षा 6 • रिबन रूलर",
    'enterLab': "सिमुलेशन दर्ज करें",
    'appTitle': "भिन्नों को दर्शाना",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "मिशन उद्देश्य:",
    'settings': "सेटिंग्स",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc':
        "आपने संख्या रेखा पर भिन्नों को दर्शाना सफलतापूर्वक सीख लिया है!",
    'lbl_toolbox': "टूलबॉक्स",
    'lbl_ribbon': "जादुई रिबन",
    'lbl_divider': "विभाजक टूल",
    'lbl_frog': "मेंढक",
    'lbl_flag': "मार्कर झंडा",
    'lbl_dial': "डायल:",
    's1_title': "1. पहला कट: 1/2 ढूँढना",
    's1_obj':
        "समझें कि हर कैसे एक पूरी इकाई को विभाजित करता है और अंश स्थिति को कैसे चिह्नित करता है।",
    's1_step1_task': "जादुई रिबन को खींचकर 0 और 1 के बीच छोड़ें।",
    's1_step1_out': "रिबन 0 से 1 तक के हिस्से को कवर करता है।",
    's1_step2_task': "विभाजक टूल डायल को '2' पर सेट करने के लिए क्लिक करें।",
    's1_step2_out': "विभाजक टूल अब 2 बराबर भाग बनाने के लिए तैयार है।",
    's1_step3_task': "सक्रिय 'विभाजक टूल' को रिबन पर खींचकर छोड़ें।",
    's1_step3_out': "टूल रिबन को 2 समान खंडों में विभाजित करता है।",
    's1_step4_task': "मेंढक को 0 स्थिति पर खींचें।",
    's1_step4_out': "मेंढक कूदने के लिए तैयार है।",
    's1_step5_task': "रिबन पर आपके द्वारा बनाए गए 1/2 चिह्न पर क्लिक करें।",
    's1_step5_out': "आपने 1/2 ढूँढ लिया है!",
    's1_hud1': "रिबन को 0-1 पर खींचें",
    's1_hud2': "डायल को 2 पर सेट करें",
    's1_hud3': "रिबन को काटें",
    's1_hud4': "मेंढक को 0 पर रखें",
    's1_hud5': "1/2 चिह्न पर क्लिक करें",
    's2_title': "2. कई छलांग: 3/4 ढूँढना",
    's2_obj':
        "पूरी इकाई को विभाजित करने के बाद कई 'छलांग' लगाकर एक उचित भिन्न का प्रतिनिधित्व करें।",
    's2_step1_task': "विभाजक टूल डायल को '4' पर सेट करें।",
    's2_step1_out': "विभाजक टूल 4 पर सेट है।",
    's2_step2_task': "विभाजक टूल को रिबन पर खींचकर छोड़ें।",
    's2_step2_out': "रिबन को 4 समान खंडों में विभाजित किया गया है।",
    's2_step3_task': "मेंढक को 0 स्थिति पर खींचें।",
    's2_step3_out': "मेंढक तैयार है।",
    's2_step4_task': "0 से तीसरे चिह्न पर क्लिक करें।",
    's2_step4_out': "आपने 3/4 ढूँढ लिया है!",
    's2_hud1': "डायल को 4 पर सेट करें",
    's2_hud2': "रिबन को काटें",
    's2_hud3': "मेंढक को 0 पर रखें",
    's2_hud4': "तीसरे चिह्न (3/4) पर क्लिक करें",
    's3_title': "3. पूर्ण से परे: 5/3 ढूँढना",
    's3_obj':
        "एक अनुचित भिन्न का प्रतिनिधित्व करें, यह समझते हुए कि विभाजन '1' से आगे जारी रहता है।",
    's3_step1_task': "0-1 और 1-2 खंडों को कवर करने के लिए रिबन खींचें।",
    's3_step1_out': "दोनों खंड कवर किए गए हैं।",
    's3_step2_task': "डायल को '3' पर सेट करें और पहले रिबन (0-1) को काटें।",
    's3_step2_out': "पहला रिबन तिहाई में कट गया।",
    's3_step3_task': "विभाजक के साथ दूसरे रिबन (1-2) को काटें।",
    's3_step3_out': "दूसरा रिबन तिहाई में कट गया।",
    's3_step4_task': "मेंढक को 0 पर खींचें।",
    's3_step4_out': "मेंढक तैयार है।",
    's3_step5_task': "0 से पांचवें चिह्न पर क्लिक करें।",
    's3_step5_out': "आपने कुल 5 भागों की छलांग लगाई। आपने 5/3 ढूँढ लिया है!",
    's3_hud1': "0-1 और 1-2 पर रिबन रखें",
    's3_hud2': "डायल को 3 पर सेट करें, पहला रिबन काटें",
    's3_hud3': "दूसरा रिबन काटें",
    's3_hud4': "मेंढक को 0 पर रखें",
    's3_hud5': "5वें चिह्न (5/3) पर क्लिक करें",
    's4_title': "4. चुनौती 1 (2/5)",
    's4_obj':
        "2/5 के निशान पर सही ढंग से एक झंडा लगाने के लिए दिए गए टूल का उपयोग करें।",
    's4_step1_task':
        "0-1 पर एक रिबन रखें, इसे 5 भागों में काटें, और 2/5 पर झंडा लगाएं।",
    's4_step1_out': "बहुत बढ़िया! आपने ठीक 2/5 पर झंडा लगाया।",
    's4_hud1': "रिबन रखें, 5 में काटें, और 2/5 पर झंडा लगाएं।",
    's5_title': "5. चुनौती 2 (7/4)",
    's5_obj':
        "7/4 के निशान पर सही ढंग से एक झंडा लगाने के लिए दिए गए टूल का उपयोग करें।",
    's5_step1_task':
        "रिबन रखें, उन्हें 4-4 भागों में काटें, और 7/4 पर झंडा लगाएं।",
    's5_step1_out': "शानदार! आपने अनुचित भिन्न 7/4 ढूँढ लिया।",
    's5_hud1': "रिबन रखें, 4 में काटें, और 7/4 पर झंडा लगाएं।",
  },
};

String t(String key, String lang) {
  return i18n[lang]?[key] ?? i18n['en']![key] ?? key;
}

// --- DATA CLASSES ---
class RibbonState {
  final int seg; // 0 for (0-1), 1 for (1-2)
  int cuts;

  RibbonState({required this.seg, this.cuts = 1});
}

class HopTrace {
  final double startX;
  final double endX;
  HopTrace(this.startX, this.endX);
}

class Cl6M_Ch7_A2_RepresentingFractionsonaNumberLine extends StatefulWidget {
  const Cl6M_Ch7_A2_RepresentingFractionsonaNumberLine({super.key});

  @override
  State<Cl6M_Ch7_A2_RepresentingFractionsonaNumberLine> createState() =>
      _Cl6M_Ch7_A2_RepresentingFractionsonaNumberLineState();
}

class _Cl6M_Ch7_A2_RepresentingFractionsonaNumberLineState
    extends State<Cl6M_Ch7_A2_RepresentingFractionsonaNumberLine>
    with TickerProviderStateMixin {
  // UI State
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';
  final List<String> _langs = ['en', 'hi'];
  bool _showSuccessPopup = false;

  // View State
  double _zoom = 1.0;
  Offset _pan = Offset.zero;
  final GlobalKey _canvasKey = GlobalKey();

  // Sim State
  int _scenario = 1;
  int _step = 0;
  final double _unitLen = 300;
  final double _startX = -300;
  final List<RibbonState> _ribbons = [];
  int _dividerSetting = 1;
  bool _frogPlaced = false;
  int _frogPos = -1;
  int _flagPos = -1;

  // Drag State
  String? _activeDragEntity;
  Offset _dragWorldPos = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialPan = Offset.zero;

  // Animations
  late AnimationController _ticker;
  bool _isAnimating = false;
  int? _sliceRibbonIdx;
  double _sliceProgress = 0.0;

  bool _frogAnimActive = false;
  double _hopProgress = 0.0;
  double _hopStartX = 0.0;
  double _hopEndX = 0.0;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

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

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

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
      duration: const Duration(days: 365),
    )..repeat();
    _ticker.addListener(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
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

  void _onTick() {
    setState(() {
      // Logic handled via time inside action triggers or separate controllers if needed.
    });
  }

  void _toggleLanguage() {
    playClick();
    setState(() {
      int idx = _langs.indexOf(_lang);
      _lang = _langs[(idx + 1) % _langs.length];
    });
  }

  void _handleReset() {
    playClick();
    setState(() {
      _showCurtain = true;
      _showSuccessPopup = false;
      _loadScenario(1);
    });
  }

  void _startLab() {
    curtainScreen();
    setState(() {
      _showCurtain = false;
      _loadScenario(1);
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _isAnimating = false;
      _ribbons.clear();
      if (_scenario == 2) {
        _ribbons.add(RibbonState(seg: 0, cuts: 1));
      }
      _dividerSetting = 1;
      _frogPlaced = false;
      _frogPos = -1;
      _flagPos = -1;
      _activeDragEntity = null;
      _showSuccessPopup = false;
      _pan = Offset.zero;
      _zoom = 1.0;
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
    _checkScenarioSuccess();
  }

  void _checkScenarioSuccess() {
    int totalSteps = _getScenarioStepsCount();
    if (_step >= totalSteps) {
      if (_scenario == 5) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          playPageOpen();
          setState(() {
            _showSuccessPopup = true;
          });
        });
      }
    }
  }

  int _getScenarioStepsCount() {
    switch (_scenario) {
      case 1:
        return 5;
      case 2:
        return 4;
      case 3:
        return 5;
      case 4:
        return 1;
      case 5:
        return 1;
      default:
        return 0;
    }
  }

  Offset _screenToWorld(Offset screenPos) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    double canvasCx = size.width / 2;
    double canvasCy = size.height / 2;

    double worldX = (screenPos.dx - canvasCx - _pan.dx) / _zoom;
    double worldY = (screenPos.dy - canvasCy - _pan.dy) / _zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  // Safe helper to avoid 'collection' package dependency for firstOrNull
  RibbonState? _getRibbon(int seg) {
    for (var r in _ribbons) {
      if (r.seg == seg) return r;
    }
    return null;
  }

  double _getXForHop(int absoluteHopIndex) {
    if (absoluteHopIndex <= 0) return _startX;
    List<double> parts = [];
    for (int i = 0; i < 2; i++) {
      var rib = _getRibbon(i);
      if (rib != null) {
        double segLen = _unitLen / rib.cuts;
        for (int c = 0; c < rib.cuts; c++) {
          parts.add(_startX + i * _unitLen + (c + 1) * segLen);
        }
      }
    }
    if (absoluteHopIndex <= parts.length) {
      return parts[absoluteHopIndex - 1];
    }
    return _startX;
  }

  void _validateChallenge() {
    if (_scenario == 4) {
      var rib = _getRibbon(0);
      if (rib != null && rib.cuts == 5 && _flagPos == 2) {
        _advanceStep();
        Future.delayed(const Duration(milliseconds: 1000), () {
          playPageOpen();
          setState(() => _showSuccessPopup = true);
        });
      } else {
        playError();
        setState(() => _flagPos = -1);
      }
    }
    if (_scenario == 5) {
      var rib1 = _getRibbon(0);
      var rib2 = _getRibbon(1);
      if (rib1 != null &&
          rib1.cuts == 4 &&
          rib2 != null &&
          rib2.cuts == 4 &&
          _flagPos == 7) {
        _advanceStep();
        Future.delayed(const Duration(milliseconds: 1000), () {
          playPageOpen();
          setState(() => _showSuccessPopup = true);
        });
      } else {
        playError();
        setState(() => _flagPos = -1);
      }
    }
  }

  void _triggerSlice(int param) async {
    playClick();
    setState(() {
      _isAnimating = true;
      _sliceRibbonIdx = param;
      _sliceProgress = 0.0;
    });

    int steps = 20;
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (!mounted) return;
      setState(() {
        _sliceProgress = i / steps;
      });
    }

    setState(() {
      _isAnimating = false;
      _sliceRibbonIdx = null;
      var rib = _getRibbon(param);
      if (rib != null) rib.cuts = _dividerSetting;
    });

    // Validations: Fixed _step index because dial modification advances step BEFORE slice
    if (_scenario == 1 && _step == 2 && param == 0 && _dividerSetting == 2) {
      _advanceStep();
    }
    if (_scenario == 2 && _step == 1 && param == 0 && _dividerSetting == 4) {
      _advanceStep();
    }
    if (_scenario == 3) {
      if (_step == 1 && param == 0 && _dividerSetting == 3) {
        _advanceStep();
      } else if (_step == 2 && param == 1 && _dividerSetting == 3) {
        _advanceStep();
      }
    }
  }

  void _triggerHop(int targetHop) async {
    setState(() {
      _isAnimating = true;
    });

    int numHops = targetHop - _frogPos;
    if (numHops <= 0) return;

    List<HopTrace> hopsArr = [];
    for (int i = 0; i < numHops; i++) {
      hopsArr.add(
        HopTrace(_getXForHop(_frogPos + i), _getXForHop(_frogPos + i + 1)),
      );
    }

    setState(() {
      _frogAnimActive = true;
      _hopProgress = 0.0;
      _hopStartX = hopsArr[0].startX;
      _hopEndX = hopsArr[0].endX;
    });

    for (int h = 0; h < hopsArr.length; h++) {
      setState(() {
        _hopStartX = hopsArr[h].startX;
        _hopEndX = hopsArr[h].endX;
      });

      int steps = 20;
      for (int i = 1; i <= steps; i++) {
        await Future.delayed(const Duration(milliseconds: 16));
        if (!mounted) return;
        setState(() {
          _hopProgress = i / steps;
        });
      }
    }

    setState(() {
      _frogPos = targetHop;
      _flagPos = targetHop;
      _frogAnimActive = false;
      _isAnimating = false;
    });
    _advanceStep();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_scenario < 4 && _step >= _getScenarioStepsCount()) {
        playPageOpen();
        setState(() {
          _showSuccessPopup = true;
        });
      }
    });
  }

  // --- NEW: Added pure tap handler for instantaneous clicking ---
  void _onTapUp(TapUpDetails details) {
    if (_isAnimating) return;
    Offset local = details.localPosition;
    Offset world = _screenToWorld(local);

    double bx = -450;
    double by = 160;

    // 1. Divider Dial Click
    if (_hitTestBox(bx + 280, by + 20, 60, 40, world)) {
      playClick();
      setState(() {
        _dividerSetting++;
        if (_dividerSetting > 6) _dividerSetting = 1;
      });
      if (_scenario == 1 && _step == 1 && _dividerSetting == 2) _advanceStep();
      if (_scenario == 2 && _step == 0 && _dividerSetting == 4) _advanceStep();
      return;
    }

    // 2. Ribbon Clicks for Jumps
    if (_frogPlaced && _frogPos == 0) {
      int targetHop = -1;
      if (_scenario == 1 && _step == 4) {
        double mx = _startX + _unitLen / 2;
        if (_hitTestBox(mx - 40, -120, 80, 160, world)) targetHop = 1;
      }
      if (_scenario == 2 && _step == 3) {
        double mx = _startX + (3 / 4) * _unitLen;
        if (_hitTestBox(mx - 40, -120, 80, 160, world)) targetHop = 3;
      }
      if (_scenario == 3 && _step == 4) {
        double mx = _startX + (5 / 3) * _unitLen;
        if (_hitTestBox(mx - 40, -120, 80, 160, world)) targetHop = 5;
      }
      if (targetHop > 0) {
        playClick();
        _triggerHop(targetHop);
        return;
      } else {
        playError();
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_isAnimating) return;
    Offset local = details.localFocalPoint;
    Offset world = _screenToWorld(local);

    _initialFocalPoint = local;
    _initialPan = _pan;

    double bx = -450;
    double by = 160;

    // Ribbon Drag
    if (_hitTestBox(bx + 50, by + 40, 150, 40, world)) {
      bool needsRibbon = false;
      if (_scenario == 1 && _step == 0 && _ribbons.isEmpty) needsRibbon = true;
      if (_scenario == 3 && _step == 0 && _ribbons.length < 2) {
        needsRibbon = true;
      }
      if (_scenario >= 4) needsRibbon = true;

      if (needsRibbon) {
        setState(() {
          _activeDragEntity = 'ribbon';
          _dragWorldPos = world;
        });
        return;
      }
    }

    // Divider Tool Drag
    if (_hitTestBox(bx + 280, by + 20, 60, 80, world)) {
      setState(() {
        _activeDragEntity = 'divider';
        _dragWorldPos = world;
      });
      return;
    }

    // Frog Drag
    if (_hitTestBox(bx + 450, by + 30, 80, 80, world)) {
      bool needsFrog = false;
      if (_scenario == 1 && _step == 3 && !_frogPlaced) needsFrog = true;
      if (_scenario == 2 && _step == 2 && !_frogPlaced) needsFrog = true;
      if (_scenario == 3 && _step == 3 && !_frogPlaced) needsFrog = true;
      if (needsFrog) {
        setState(() {
          _activeDragEntity = 'frog';
          _dragWorldPos = world;
        });
        return;
      }
    }

    // Flag Drag
    if (_hitTestBox(bx + 600, by + 30, 80, 80, world)) {
      if (_scenario >= 4) {
        setState(() {
          _activeDragEntity = 'flag';
          _dragWorldPos = world;
        });
        return;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_activeDragEntity != null) {
      setState(() {
        _dragWorldPos = _screenToWorld(details.localFocalPoint);
      });
      return;
    }

    setState(() {
      _pan = _initialPan + (details.localFocalPoint - _initialFocalPoint);
      if (details.scale != 1.0) {
        _zoom = (_zoom * details.scale).clamp(0.4, 3.0);
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_activeDragEntity != null) {
      bool dropped = false;
      Offset pt = _dragWorldPos;

      if (_activeDragEntity == 'ribbon') {
        if (_hitTestBox(_startX, -80, _unitLen, 60, pt) &&
            !_ribbons.any((r) => r.seg == 0)) {
          setState(() => _ribbons.add(RibbonState(seg: 0)));
          dropped = true;
        } else if (_hitTestBox(_startX + _unitLen, -80, _unitLen, 60, pt) &&
            !_ribbons.any((r) => r.seg == 1)) {
          setState(() => _ribbons.add(RibbonState(seg: 1)));
          dropped = true;
        }
        if (dropped) {
          if (_scenario == 1 && _step == 0) _advanceStep();
          if (_scenario == 3 && _step == 0 && _ribbons.length == 2) {
            _advanceStep();
          }
        }
      } else if (_activeDragEntity == 'divider') {
        if (_hitTestBox(_startX, -80, _unitLen, 60, pt) &&
            _ribbons.any((r) => r.seg == 0)) {
          _triggerSlice(0);
          dropped = true;
        } else if (_hitTestBox(_startX + _unitLen, -80, _unitLen, 60, pt) &&
            _ribbons.any((r) => r.seg == 1)) {
          _triggerSlice(1);
          dropped = true;
        }
      } else if (_activeDragEntity == 'frog') {
        if (_hitTestBox(_startX - 50, -100, 100, 100, pt)) {
          setState(() {
            _frogPlaced = true;
            _frogPos = 0;
          });
          dropped = true;
          if (_scenario == 1 && _step == 3) _advanceStep();
          if (_scenario == 2 && _step == 2) _advanceStep();
          if (_scenario == 3 && _step == 3) _advanceStep();
        }
      } else if (_activeDragEntity == 'flag') {
        int closestHop = -1;
        double minD = 50;
        for (int i = 0; i <= 10; i++) {
          double x = _getXForHop(i);
          if ((pt.dx - x).abs() < minD && (pt.dy - (-50)).abs() < 100) {
            closestHop = i;
            minD = (pt.dx - x).abs();
          }
        }
        if (closestHop >= 0) {
          setState(() => _flagPos = closestHop);
          dropped = true;
          _validateChallenge();
        }
      }

      if (dropped) {
        if (_activeDragEntity != 'flag') {
          playClick();
        }
      } else {
        playError();
      }

      setState(() {
        _activeDragEntity = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: MaterialApp(
        title: 'Representing Fractions',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          fontFamily: 'Plus Jakarta Sans',
          primaryColor: const Color(0xFF6366F1),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6366F1),
            secondary: Color(0xFF10B981),
            surface: Color(0xFF1E293B),
          ),
        ),
        home: Scaffold(
          body: Stack(
            children: [
              // Layer 1: Canvas Area
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _sidebarOpen ? _sidebarWidth : 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: ClipRect(
                  child: GestureDetector(
                    onTapUp: _onTapUp, // Added missing tap functionality here
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
                    child: Container(
                      key: _canvasKey,
                      color: const Color(0xFF0F172A),
                      child: CustomPaint(
                        painter: LabPainter(
                          zoom: _zoom,
                          pan: _pan,
                          lang: _lang,
                          scenario: _scenario,
                          step: _step,
                          unitLen: _unitLen,
                          startX: _startX,
                          ribbons: _ribbons,
                          dividerSetting: _dividerSetting,
                          frogPlaced: _frogPlaced,
                          frogPos: _frogPos,
                          flagPos: _flagPos,
                          activeDragEntity: _activeDragEntity,
                          dragPos: _dragWorldPos,
                          sliceRibbonIdx: _sliceRibbonIdx,
                          sliceProgress: _sliceProgress,
                          frogAnimActive: _frogAnimActive,
                          hopStartX: _hopStartX,
                          hopEndX: _hopEndX,
                          hopProgress: _hopProgress,
                          getXForHop: _getXForHop,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Layer 2: Sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _sidebarOpen ? 0 : -_sidebarWidth,
                top: 0,
                bottom: 0,
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
                        offset: Offset(5, 0),
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
                              children: [
                                // Sidebar Header
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 66,
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.white12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.architecture,
                                            color: Color(0xFF6366F1),
                                            size: 30,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              t('appTitle', _lang),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 40.0,
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          t('appSubtitle', _lang),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 40.0,
                                        ),
                                        child: Row(
                                          children: [
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF334155,
                                                ),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.language,
                                                size: 16,
                                              ),
                                              label: Text(
                                                _lang.toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              onPressed: _toggleLanguage,
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              style: IconButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF334155,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              icon: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.refresh,
                                                    color: Colors.redAccent,
                                                    size: 20,
                                                  ),
                                                  Text(
                                                    t(
                                                      'resetBtn',
                                                      _lang,
                                                    ).toUpperCase(),
                                                  ),
                                                ],
                                              ),
                                              onPressed: _handleReset,
                                              tooltip: "Reset",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Sidebar Scrollable Content (Expanded forces footer to bottom if space is available)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t(
                                            'selectScenario',
                                            _lang,
                                          ).toUpperCase(),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.white12,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              value: _scenario,
                                              isExpanded: true,
                                              dropdownColor: const Color(
                                                0xFF1E293B,
                                              ),
                                              items: [1, 2, 3, 4, 5].map((id) {
                                                return DropdownMenuItem<int>(
                                                  value: id,
                                                  child: Text(
                                                    t('s${id}_title', _lang),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  playDropdown();
                                                  _loadScenario(val);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF0F172A,
                                            ).withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.white12,
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
                                                    color: Colors.redAccent,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    t('learnLbl', _lang),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                t('s${_scenario}_obj', _lang),
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ..._buildSteps(),
                                      ],
                                    ),
                                  ),
                                ),
                                // Footer
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0F172A),
                                    border: Border(
                                      top: BorderSide(color: Colors.white12),
                                    ),
                                  ),
                                  child: const Text(
                                    "© ZeroScienceLab | Fall in love with math and Science",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white54,
                                    ),
                                    textAlign: TextAlign.center,
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

              // Sidebar Drag Resizer
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _sidebarOpen ? _sidebarWidth - 10 : -20,
                top: 0,
                bottom: 0,
                width: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    if (!_sidebarOpen) return;
                    setState(() {
                      _sidebarWidth += details.delta.dx;
                      _sidebarWidth = _sidebarWidth.clamp(
                        300.0,
                        MediaQuery.of(context).size.width * 0.6,
                      );
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Menu Button (Always visible)
              Positioned(
                left: 16,
                top: 16,
                child: GestureDetector(
                  onTap: () {
                    playClick();
                    setState(() {
                      _sidebarOpen = !_sidebarOpen;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                    child: Icon(
                      _sidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Layer: Floating HUD
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _sidebarOpen ? _sidebarWidth : 0,
                right: 0,
                bottom: 40,
                child: _buildHUD(),
              ),

              // Layer: Curtain Overlay
              if (_showCurtain)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.architecture,
                              color: Color(0xFF6366F1),
                              size: 100,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              t('shutterTitle', _lang),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t('appSubtitle', _lang),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
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
                              icon: const Icon(
                                Icons.play_circle_fill,
                                size: 28,
                              ),
                              label: Text(
                                t('enterLab', _lang),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _startLab,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Layer: Success Popup Overlay
              if (_showSuccessPopup)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          width: 500,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Color(0xFF10B981),
                                child: Icon(
                                  Icons.flag,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                t('summaryTitle', _lang),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('finalDesc', _lang),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_scenario < 5)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6366F1,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      icon: const Text(""),
                                      label: Row(
                                        children: [
                                          Text(
                                            t('nextScenario', _lang),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward),
                                        ],
                                      ),
                                      onPressed: () {
                                        playClick();
                                        setState(() {
                                          _showSuccessPopup = false;
                                          _loadScenario(_scenario + 1);
                                        });
                                      },
                                    )
                                  else
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      icon: const Text(""),
                                      label: Row(
                                        children: [
                                          Text(
                                            t('finishLab', _lang),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.check_circle),
                                        ],
                                      ),
                                      onPressed: _handleReset,
                                    ),
                                ],
                              ),
                            ],
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
    );
  }

  Widget _buildHUD() {
    int totalSteps = _getScenarioStepsCount();
    if (_step >= totalSteps || _showCurtain || _showSuccessPopup) {
      return const SizedBox.shrink();
    }
    String hudText = t('s${_scenario}_hud${_step + 1}', _lang);

    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            top: BorderSide(color: Color(0xFF6366F1), width: 4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 30),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                hudText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSteps() {
    int totalSteps = _getScenarioStepsCount();
    List<Widget> steps = [];

    for (int i = 0; i < totalSteps; i++) {
      bool isCompleted = i < _step;
      bool isActive = i == _step;
      bool isFuture = i > _step;

      Color bgColor = isFuture
          ? Colors.white.withOpacity(0.05)
          : isActive
          ? const Color(0xFF6366F1).withOpacity(0.1)
          : const Color(0xFF10B981).withOpacity(0.1);

      Color borderColor = isFuture
          ? Colors.transparent
          : isActive
          ? const Color(0xFF6366F1).withOpacity(0.5)
          : const Color(0xFF10B981).withOpacity(0.3);

      steps.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isFuture
                      ? Colors.white24
                      : isActive
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        "${i + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${t('stepLabel', _lang)} ${i + 1}",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('s${_scenario}_step${i + 1}_task', _lang),
                      style: TextStyle(
                        color: isFuture ? Colors.white54 : Colors.white,
                        fontSize: 14,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          "${t('learnLbl', _lang)} ${t('s${_scenario}_step${i + 1}_out', _lang)}",
                          style: const TextStyle(
                            color: Color(0xFF10B981),
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
        ),
      );
    }
    return steps;
  }
}

// --- CUSTOM PAINTER FOR SIMULATION ---
class LabPainter extends CustomPainter {
  final double zoom;
  final Offset pan;
  final String lang;
  final int scenario;
  final int step;

  final double unitLen;
  final double startX;
  final List<RibbonState> ribbons;
  final int dividerSetting;
  final bool frogPlaced;
  final int frogPos;
  final int flagPos;

  final String? activeDragEntity;
  final Offset dragPos;

  final int? sliceRibbonIdx;
  final double sliceProgress;

  final bool frogAnimActive;
  final double hopStartX;
  final double hopEndX;
  final double hopProgress;

  final double Function(int) getXForHop;

  LabPainter({
    required this.zoom,
    required this.pan,
    required this.lang,
    required this.scenario,
    required this.step,
    required this.unitLen,
    required this.startX,
    required this.ribbons,
    required this.dividerSetting,
    required this.frogPlaced,
    required this.frogPos,
    required this.flagPos,
    required this.activeDragEntity,
    required this.dragPos,
    required this.sliceRibbonIdx,
    required this.sliceProgress,
    required this.frogAnimActive,
    required this.hopStartX,
    required this.hopEndX,
    required this.hopProgress,
    required this.getXForHop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom, zoom);

    _drawNumberLine(canvas);

    for (var rib in ribbons) {
      _drawRibbon(canvas, rib.seg, rib.cuts);
    }

    _drawToolbox(canvas);

    // Draw Active Drag Entity
    if (activeDragEntity != null) {
      if (activeDragEntity == 'ribbon') {
        _drawRoundedRect(
          canvas,
          dragPos.dx - 75,
          dragPos.dy - 20,
          150,
          40,
          8,
          const Color(0xFF818CF8),
          const Color(0xFF0F172A),
          3,
        );
      } else if (activeDragEntity == 'divider') {
        _drawDivider(
          canvas,
          dragPos.dx,
          dragPos.dy,
          dividerSetting.toString(),
          true,
        );
      } else if (activeDragEntity == 'frog') {
        _drawFrog(canvas, dragPos);
      } else if (activeDragEntity == 'flag') {
        _drawFlag(canvas, dragPos);
      }
    }

    // Frog Render
    double fx = 0, fy = -80;
    if (frogPlaced && !frogAnimActive && activeDragEntity != 'frog') {
      fx = getXForHop(frogPos);
      _drawFrog(canvas, Offset(fx, fy));
    } else if (frogAnimActive) {
      double p = hopProgress;
      fx = hopStartX + (hopEndX - hopStartX) * p;
      fy = -80 - sin(p * pi) * 80;

      // Draw path trace
      final dashPaint = Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.4)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      Path tracePath = Path();
      for (double i = 0; i <= 1; i += 0.05) {
        double tx = hopStartX + (hopEndX - hopStartX) * i;
        double ty = -80 - sin(i * pi) * 80;
        if (i == 0) {
          tracePath.moveTo(tx, ty);
        } else {
          tracePath.lineTo(tx, ty);
        }
      }
      _drawDashedPath(canvas, tracePath, dashPaint, 5, 5);

      _drawFrog(canvas, Offset(fx, fy));
    }

    // Flag Render
    if (flagPos >= 0 && activeDragEntity != 'flag') {
      double flx = getXForHop(flagPos);
      _drawFlag(canvas, Offset(flx, -100));

      _drawRoundedRect(
        canvas,
        flx - 20,
        -155,
        40,
        25,
        4,
        const Color(0xFFF8FAFC),
        const Color(0xFF0F172A),
        2,
      );
      int den = ribbons.isNotEmpty ? ribbons[0].cuts : 1;
      _drawText(
        canvas,
        "$flagPos/$den",
        flx,
        -142,
        const Color(0xFF0F172A),
        14,
        bold: true,
      );
    }

    canvas.restore();
  }

  void _drawNumberLine(Canvas canvas) {
    double startY = -40;
    final paint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(startX - 100, startY),
      Offset(startX + 2 * unitLen + 100, startY),
      paint,
    );

    for (int i = 0; i <= 2; i++) {
      double px = startX + i * unitLen;
      paint.strokeWidth = 6;
      canvas.drawLine(Offset(px, startY - 20), Offset(px, startY + 20), paint);
      _drawText(
        canvas,
        i.toString(),
        px,
        startY + 45,
        const Color(0xFFF8FAFC),
        24,
        bold: true,
      );
    }

    // Draw cut marks
    for (var rib in ribbons) {
      if (rib.cuts > 1) {
        double rx = startX + rib.seg * unitLen;
        double segLen = unitLen / rib.cuts;
        for (int c = 1; c < rib.cuts; c++) {
          double mx = rx + c * segLen;
          paint
            ..color = const Color(0xFF94A3B8)
            ..strokeWidth = 3;
          canvas.drawLine(
            Offset(mx, startY - 10),
            Offset(mx, startY + 10),
            paint,
          );

          bool expectedClicks = false;
          if (scenario == 1 && step == 4 && rib.cuts == 2 && c == 1) {
            expectedClicks = true;
          }
          if (scenario == 2 && step == 3 && rib.cuts == 4 && c == 3) {
            expectedClicks = true;
          }
          if (scenario == 3 && step == 4 && rib.seg == 1 && c == 2) {
            expectedClicks = true;
          }

          if (expectedClicks) {
            final glowPaint = Paint()
              ..color = const Color(0xFFFACC15)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
            canvas.drawCircle(Offset(mx, startY - 30), 10, glowPaint);

            final solidPaint = Paint()..color = const Color(0xFFFACC15);
            canvas.drawCircle(Offset(mx, startY - 30), 10, solidPaint);
          }
        }
      }
    }
  }

  void _drawRibbon(Canvas canvas, int seg, int cuts) {
    double rx = startX + seg * unitLen;
    double ry = -85;

    // Base ribbon shadow and rect
    _drawRoundedRect(
      canvas,
      rx,
      ry,
      unitLen,
      40,
      8,
      const Color(0xFF818CF8),
      const Color(0xFF0F172A),
      3,
    );

    if (cuts > 1) {
      double segLen = unitLen / cuts;
      List<Color> colors = const [
        Color(0xFFFCA5A5),
        Color(0xFFFCD34D),
        Color(0xFF86EFAC),
        Color(0xFF93C5FD),
        Color(0xFFD8B4FE),
        Color(0xFFFDBA74),
        Color(0xFFF9A8D4),
      ];

      if (sliceRibbonIdx == seg) {
        // Drawing slice animation
        double p = sliceProgress;
        double lineY = ry - 20 + p * 80;
        final slicePaint = Paint()
          ..color = const Color(0xFFFACC15)
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
        canvas.drawLine(
          Offset(rx, lineY),
          Offset(rx + unitLen, lineY),
          slicePaint,
        );
      } else {
        // Draw segments
        for (int i = 0; i < cuts; i++) {
          double cx = rx + i * segLen;
          _drawRoundedRect(
            canvas,
            cx,
            ry,
            segLen,
            40,
            0,
            colors[i % colors.length],
            const Color(0xFF0F172A),
            2,
          );
          _drawText(
            canvas,
            "1/$cuts",
            cx + segLen / 2,
            ry + 20,
            const Color(0xFF0F172A),
            16,
            bold: true,
          );
        }
      }
    } else if (sliceRibbonIdx == seg) {
      double p = sliceProgress;
      double lineY = ry - 20 + p * 80;
      final slicePaint = Paint()
        ..color = const Color(0xFFFACC15)
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
      canvas.drawLine(
        Offset(rx, lineY),
        Offset(rx + unitLen, lineY),
        slicePaint,
      );
    }
  }

  void _drawToolbox(Canvas canvas) {
    double bx = -450, by = 160, bw = 900, bh = 140;

    _drawRoundedRect(
      canvas,
      bx,
      by,
      bw,
      bh,
      12,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      4,
    );

    // Tab
    final tabPath = Path()
      ..moveTo(bx, by + 30)
      ..lineTo(bx, by)
      ..arcToPoint(Offset(bx + 12, by - 30), radius: const Radius.circular(12))
      ..lineTo(bx + 160 - 12, by - 30)
      ..arcToPoint(Offset(bx + 160, by), radius: const Radius.circular(12))
      ..lineTo(bx + 160, by + 30)
      ..close();
    final tabPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;
    canvas.drawPath(tabPath, tabPaint);
    final tabStroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(tabPath, tabStroke);

    _drawText(
      canvas,
      t('lbl_toolbox', lang),
      bx + 80,
      by - 15,
      const Color(0xFFF8FAFC),
      16,
      bold: true,
    );

    // Magic Ribbon
    double rx = bx + 50, ry = by + 40;
    _drawRoundedRect(
      canvas,
      rx,
      ry,
      150,
      40,
      8,
      const Color(0xFF6366F1),
      const Color(0xFF0F172A),
      3,
    );
    _drawRoundedRect(
      canvas,
      rx - 5,
      ry - 5,
      150,
      40,
      8,
      const Color(0xFF818CF8),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      t('lbl_ribbon', lang),
      rx + 70,
      ry + 15,
      Colors.white,
      14,
      bold: true,
    );

    // Divider Tool
    double dx = bx + 280, dy = by + 20;
    _drawDivider(canvas, dx + 30, dy + 40, dividerSetting.toString(), false);
    _drawText(
      canvas,
      t('lbl_dial', lang),
      dx + 30,
      dy + 95,
      const Color(0xFFF8FAFC),
      14,
      bold: true,
    );

    // Frog
    double fx = bx + 450, fy = by + 30;
    _drawRoundedRect(
      canvas,
      fx,
      fy,
      80,
      80,
      8,
      const Color(0xFF0F172A),
      const Color(0xFFF8FAFC),
      3,
    );
    _drawFrog(canvas, Offset(fx + 40, fy + 40));
    _drawText(
      canvas,
      t('lbl_frog', lang),
      fx + 40,
      fy + 95,
      const Color(0xFFF8FAFC),
      12,
      bold: true,
    );

    // Flag
    double flx = bx + 600, fly = by + 30;
    _drawRoundedRect(
      canvas,
      flx,
      fly,
      80,
      80,
      8,
      const Color(0xFF0F172A),
      const Color(0xFFF8FAFC),
      3,
    );
    _drawFlag(canvas, Offset(flx + 40, fly + 40));
    _drawText(
      canvas,
      t('lbl_flag', lang),
      flx + 40,
      fly + 95,
      const Color(0xFFF8FAFC),
      12,
      bold: true,
    );
  }

  void _drawDivider(
    Canvas canvas,
    double cx,
    double cy,
    String dialText,
    bool isDragging,
  ) {
    _drawRoundedRect(
      canvas,
      cx - 30,
      cy - 40,
      60,
      80,
      8,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      3,
    );

    final paint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(cx, cy - 15), 20, paint);
    canvas.drawCircle(Offset(cx, cy - 15), 20, stroke);

    paint.color = const Color(0xFFF8FAFC);
    canvas.drawCircle(Offset(cx, cy - 15), 12, paint);
    canvas.drawCircle(Offset(cx, cy - 15), 12, stroke);

    _drawText(
      canvas,
      dialText,
      cx,
      cy - 15,
      const Color(0xFF0F172A),
      16,
      bold: true,
    );
  }

  void _drawFrog(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(0.6); // Scale to fit size similar to HTML

    final stroke = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final fillGreen = Paint()
      ..color = const Color(0xFF7CD304)
      ..style = PaintingStyle.fill;
    final fillYellow = Paint()
      ..color = const Color(0xFFFCDC22)
      ..style = PaintingStyle.fill;

    // Move to center of drawing based on original SVG viewBox(0 0 100 100) -> mapped to (-50, -50) to (50, 50)
    canvas.translate(-50, -50);

    // Back legs
    Path bl = Path()
      ..moveTo(25, 55)
      ..cubicTo(5, 55, 5, 85, 15, 95)
      ..lineTo(35, 95)
      ..cubicTo(40, 90, 40, 70, 35, 60)
      ..close();
    canvas.drawPath(bl, fillGreen);
    canvas.drawPath(bl, stroke);

    Path br = Path()
      ..moveTo(75, 55)
      ..cubicTo(95, 55, 95, 85, 85, 95)
      ..lineTo(65, 95)
      ..cubicTo(60, 90, 60, 70, 65, 60)
      ..close();
    canvas.drawPath(br, fillGreen);
    canvas.drawPath(br, stroke);

    // Body
    Path body = Path()
      ..moveTo(30, 50)
      ..cubicTo(30, 80, 35, 95, 40, 95)
      ..lineTo(60, 95)
      ..cubicTo(65, 95, 70, 80, 70, 50)
      ..close();
    canvas.drawPath(body, fillGreen);
    canvas.drawPath(body, stroke);

    // Belly
    Path belly = Path()
      ..moveTo(35, 85)
      ..cubicTo(35, 60, 45, 55, 50, 55)
      ..cubicTo(55, 55, 65, 60, 65, 85)
      ..cubicTo(65, 95, 55, 95, 50, 95)
      ..cubicTo(45, 95, 35, 95, 35, 85)
      ..close();
    canvas.drawPath(belly, fillYellow);
    canvas.drawPath(belly, stroke);

    // Head
    Path head = Path()
      ..moveTo(20, 40)
      ..cubicTo(15, 25, 35, 20, 50, 20)
      ..cubicTo(65, 20, 85, 25, 80, 40)
      ..cubicTo(95, 50, 85, 70, 50, 70)
      ..cubicTo(15, 70, 5, 50, 20, 40)
      ..close();
    canvas.drawPath(head, fillGreen);
    canvas.drawPath(head, stroke);

    // Eyes
    final fillWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final fillPupil = Paint()
      ..color = const Color(0xFF3C4571)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(35, 25), 10, fillWhite);
    canvas.drawCircle(const Offset(35, 25), 10, stroke);
    canvas.drawCircle(const Offset(65, 25), 10, fillWhite);
    canvas.drawCircle(const Offset(65, 25), 10, stroke);
    canvas.drawCircle(const Offset(35, 25), 4, fillPupil);
    canvas.drawCircle(const Offset(65, 25), 4, fillPupil);
    canvas.drawCircle(const Offset(36, 24), 1.5, fillWhite);
    canvas.drawCircle(const Offset(66, 24), 1.5, fillWhite);

    // Smile
    Path smile = Path()
      ..moveTo(25, 55)
      ..cubicTo(40, 65, 60, 65, 75, 55);
    canvas.drawPath(smile, stroke);

    // Feet
    Path fl = Path()
      ..moveTo(35, 95)
      ..lineTo(20, 95)
      ..cubicTo(15, 95, 15, 90, 25, 90)
      ..cubicTo(30, 90, 35, 90, 40, 95);
    canvas.drawPath(fl, fillGreen);
    canvas.drawPath(fl, stroke);

    Path fr = Path()
      ..moveTo(65, 95)
      ..lineTo(80, 95)
      ..cubicTo(85, 95, 85, 90, 75, 90)
      ..cubicTo(70, 90, 65, 90, 60, 95);
    canvas.drawPath(fr, fillGreen);
    canvas.drawPath(fr, stroke);

    canvas.restore();
  }

  void _drawFlag(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(1.2); // Adjust scale

    final stroke = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    // Centered around 0,0
    Path path = Path()
      ..moveTo(-5, 12)
      ..lineTo(-5, -12) // Pole
      ..lineTo(8, -6) // Flag tip
      ..lineTo(-5, 0)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawLine(const Offset(-5, 12), const Offset(-5, -12), stroke);
    Path triangle = Path()
      ..moveTo(-5, -12)
      ..lineTo(8, -6)
      ..lineTo(-5, 0);
    canvas.drawPath(triangle, stroke);

    canvas.restore();
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fillC,
    Color strokeC,
    double strokeW,
  ) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    final fill = Paint()
      ..color = fillC
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = strokeC
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, fill);
    if (strokeW > 0) canvas.drawRRect(rrect, stroke);
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color color,
    double fontSize, {
    bool bold = false,
  }) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontFamily: 'Plus Jakarta Sans',
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final Path dashPath = Path();
    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) {
    return true; // Simple repaint always strategy given ticker animation
  }
}
