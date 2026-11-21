// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch10_A1_IntroductionToNegativeNumbersAndNumberLine(),
    ),
  );
}

// --- अनुवाद (TRANSLATIONS) ---
class Translations {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'shutterTitle': "Introduction to Negative Numbers and the Number Line",
      'appTitle': "Negative Numbers & The Number Line",
      'appSubtitle': "Class 6 • THE OTHER SIDE OF ZERO",
      'enterLab': "Enter Simulation",
      'settings': "Settings",
      'selectScenario': "Select Scenario",
      'stepLabel': "STEP",
      'doneBtn': "Done",
      'learnLbl': "Objective:",
      'closeBtn': "Close",
      'summaryTitle': "Goal Reached!",
      'resetBtn': "Reset Lab",
      'finishLab': "Finish Lab",
      'nextScenario': "Next Scenario",
      'finalDesc':
          "You have successfully explored integers using the Building of Fun!",
      'f3': "Book Store",
      'f2': "Art Centre",
      'f1': "Food Court",
      'f0': "Welcome Hall",
      'fm1': "Toy Store",
      'fm2': "Video Games",
      'fm3': "Cinema Centre",
      's1_title': "1. Numbering the Floors",
      's1_obj':
          "Understand that positive and negative numbers represent positions above and below zero.",
      's1_step1_task': "DRAG the lift upwards to see floors above the ground.",
      's1_step1_out':
          "Floors above the ground are labeled with positive numbers (+1, +2, +3).",
      's1_step2_task': "DRAG the lift downwards past the Ground Floor.",
      's1_step2_out':
          "Floors below the ground are labeled with negative numbers (-1, -2, -3).",
      's1_step3_task': "Observe the summary on the number line.",
      's1_step3_out':
          "Above ground (0) is POSITIVE (+). Below ground (0) is NEGATIVE (-).",
      's1_hud1': "Drag the lift UP to the Book Store (+3).",
      's1_hud2': "Drag the lift DOWN to the Cinema Centre (-3).",
      's1_hud3': "Observe how floors align with the number line.",

      's2_title': "2. Combining Button Presses",
      's2_obj':
          "Understand that movement can be represented by adding integers.",
      's2_step1_task':
          "Gurmit wants to go to Art Centre (+2). CLICK the '+' button two times.",
      's2_step1_out':
          "Pressing '+' moves the lift UP. (Start: 0) + (+1) + (+1) = +2.",
      's2_step2_task':
          "From Art Centre (+2), go to Cinema Centre (-3). CLICK the '–' button five times.",
      's2_step2_out':
          "Pressing '–' moves the lift DOWN. (Start: +2) + (-1)*5 = -3.",
      's2_step3_task': "Observe the summary.",
      's2_step3_out':
          "'+' adds positive. '–' adds negative. Combine them to find final floor!",
      's2_hud1': "Click '+' 2 times to reach Floor +2.",
      's2_hud2': "Click '–' 5 times to reach Floor -3.",
      's2_hud3': "Observe the final equation.",

      's3_title': "3. Back to Zero!",
      's3_obj': "Visually understand the concept of additive inverse.",
      's3_step1_task':
          "You are on Floor +3. Get back to Floor 0. CLICK correct button.",
      's3_step1_out': "You pressed '–' 3 times. (+3) + (-3) = 0.",
      's3_step2_task':
          "You are on Floor -3. Get back to Floor 0. CLICK correct button.",
      's3_step2_out': "You pressed '+' 3 times. (-3) + (+3) = 0.",
      's3_step3_task': "Observe the summary.",
      's3_step3_out':
          "To cancel a move, make the opposite move! +3 and -3 are inverses.",
      's3_hud1': "Click '–' 3 times to return to Floor 0.",
      's3_hud2': "Click '+' 3 times to return to Floor 0.",
      's3_hud3': "Observe the additive inverse concept.",

      's4_title': "4. The Delivery Mission",
      's4_obj': "Solve for required movement to get from start to target.",
      's4_step1_task':
          "Deliver from Toy Store (-1) to Food Court (+1). CLICK buttons to move.",
      's4_step1_out':
          "Moved UP 2 floors. Target(+1) - Start(-1) = Movement(+2).",
      's4_step2_task': "Deliver from Book Store (+3) to Video Games (-2).",
      's4_step2_out':
          "Moved DOWN 5 floors. Target(-2) - Start(+3) = Movement(-5).",
      's4_hud1': "Click '+' to deliver package to Floor +1.",
      's4_hud2': "Click '–' to deliver package to Floor -2.",

      's5_title': "5. Aman's Mixed-Up Trip",
      's5_obj': "Calculate final position after a series of movements.",
      's5_step1_task':
          "Aman is at +2. He presses '–' four times, then '+' once. Follow journey.",
      's5_step1_out': "Aman ended up at the Toy Store (-1).",
      's5_step2_task': "Observe the final math journey.",
      's5_step2_out': "Journey: (Start: +2) + (-4) + (+1) = -1",
      's5_hud1': "Click '–' 4 times, then '+' 1 time. Select final shop.",
      's5_hud2': "Review Aman's journey equation.",

      'belaBuilding': "Bela's Building of Fun",
      'targetLabel': "Target",
      'startLabel': "Start",
      'movementLabel': "Movement",
      'wrongWay': "Wrong Way!",
      'eqBoxTemplate': "Target(    ) - Start(    ) = Movement(    )",
      's1Summary':
          "Above ground (0) is POSITIVE (+).\nBelow ground (0) is NEGATIVE (-).",
      's3Summary':
          "To cancel a move, make the opposite move!\n+3 and -3 are INVERSES. They bring you back to 0.",
      's5PopupQ': "Which shop did Aman end up at?",
      's5Solved': "Aman's Mixed-Up Trip: Solved!",
      's5FinalEqu1': "Ended at Floor -1 (Toy Store)!",
      's5FinalEqu2': "(Start: +2) + (-4) + (+1) = -1",
      'reset': "Reset",
      'footerText': "© ZeroScienceLab | Fall in love with Math and Science",
    },
    'hi': {
      'shutterTitle': "ऋणात्मक संख्याओं और संख्या रेखा का परिचय",
      'appTitle': "ऋणात्मक संख्याएँ और संख्या रेखा",
      'appSubtitle': "कक्षा 6 • शून्य की दूसरी ओर",
      'enterLab': "सिमुलेशन दर्ज करें",
      'settings': "सेटिंग्स",
      'selectScenario': "परिदृश्य चुनें",
      'stepLabel': "चरण",
      'doneBtn': "पूर्ण",
      'learnLbl': "उद्देश्य:",
      'closeBtn': "बंद करें",
      'summaryTitle': "लक्ष्य प्राप्त हुआ!",
      'resetBtn': "रीसेट करें",
      'finishLab': "समाप्त करें",
      'nextScenario': "अगला परिदृश्य",
      'finalDesc': "आपने सफलतापूर्वक पूर्णांकों का पता लगाया है!",
      'f3': "किताबों की दुकान",
      'f2': "कला केंद्र",
      'f1': "फ़ूड कोर्ट",
      'f0': "स्वागत कक्ष",
      'fm1': "खिलौनों की दुकान",
      'fm2': "वीडियो गेम्स",
      'fm3': "सिनेमा केंद्र",
      's1_title': "1. मंजिलों का नामकरण",
      's1_obj':
          "समझें कि संख्याएँ शून्य के ऊपर और नीचे की स्थिति का प्रतिनिधित्व करती हैं।",
      's1_step1_task': "ऊपर की मंजिलों को देखने के लिए लिफ्ट को ऊपर खींचें।",
      's1_step1_out':
          "ऊपर की मंजिलों को धनात्मक संख्याओं (+1, +2, +3) से लेबल किया गया है।",
      's1_step2_task': "लिफ्ट को नीचे की ओर खींचें।",
      's1_step2_out':
          "नीचे की मंजिलों को ऋणात्मक संख्याओं (-1, -2, -3) से लेबल किया गया है।",
      's1_step3_task': "संख्या रेखा पर सारांश देखें।",
      's1_step3_out': "जमीन के ऊपर धनात्मक (+) और नीचे ऋणात्मक (-) हैं।",
      's1_hud1': "लिफ्ट को किताबों की दुकान (+3) तक खींचें।",
      's1_hud2': "लिफ्ट को सिनेमा केंद्र (-3) तक नीचे खींचें।",
      's1_hud3': "देखें कि मंजिलें संख्या रेखा के साथ कैसे संरेखित होती हैं।",

      's2_title': "2. बटन प्रेस का संयोजन",
      's2_obj': "समझें कि गति को पूर्णांक जोड़कर दर्शाया जा सकता है।",
      's2_step1_task':
          "गुरमीत कला केंद्र (+2) जाना चाहता है। दो बार '+' बटन दबाएं।",
      's2_step1_out':
          "'+' दबाने से लिफ्ट ऊपर जाती है। (प्रारंभ: 0) + (+1) + (+1) = +2.",
      's2_step2_task': "अब सिनेमा केंद्र (-3) जाएं। पांच बार '–' बटन दबाएं।",
      's2_step2_out':
          "'–' दबाने से लिफ्ट नीचे जाती है। (प्रारंभ: +2) + (-1)*5 = -3.",
      's2_step3_task': "सारांश देखें।",
      's2_step3_out': "'+' धनात्मक और '–' ऋणात्मक जोड़ता है।",
      's2_hud1': "मंजिल +2 के लिए '+' 2 बार दबाएं।",
      's2_hud2': "मंजिल -3 के लिए '–' 5 बार दबाएं।",
      's2_hud3': "अंतिम समीकरण देखें।",

      's3_title': "3. वापस शून्य पर!",
      's3_obj': "योज्य प्रतिलोम (additive inverse) की अवधारणा समझें।",
      's3_step1_task': "आप +3 पर हैं। 0 पर जाने के लिए सही बटन दबाएं।",
      's3_step1_out': "आपने 3 बार '–' दबाया। (+3) + (-3) = 0.",
      's3_step2_task': "आप -3 पर हैं। 0 पर जाने के लिए सही बटन दबाएं।",
      's3_step2_out': "आपने 3 बार '+' दबाया। (-3) + (+3) = 0.",
      's3_step3_task': "सारांश देखें।",
      's3_step3_out':
          "चाल रद्द करने के लिए विपरीत चाल चलें! +3 और -3 प्रतिलोम हैं।",
      's3_hud1': "मंजिल 0 के लिए '–' 3 बार दबाएं।",
      's3_hud2': "मंजिल 0 के लिए '+' 3 बार दबाएं।",
      's3_hud3': "प्रतिलोम अवधारणा देखें।",

      's4_title': "4. डिलीवरी मिशन",
      's4_obj': "प्रारंभ से लक्ष्य तक की गति (घटाव) हल करें।",
      's4_step1_task': "खिलौनों की दुकान (-1) से फ़ूड कोर्ट (+1) तक पहुँचाएँ।",
      's4_step1_out': "2 मंजिल ऊपर। लक्ष्य(+1) - प्रारंभ(-1) = कदम(+2)।",
      's4_step2_task':
          "किताबों की दुकान (+3) से वीडियो गेम्स (-2) तक पहुँचाएँ।",
      's4_step2_out': "5 मंजिल नीचे। लक्ष्य(-2) - प्रारंभ(+3) = कदम(-5)।",
      's4_hud1': "मंजिल +1 पर पहुँचाने के लिए '+' दबाएं।",
      's4_hud2': "मंजिल -2 पर पहुँचाने के लिए '–' दबाएं।",

      's5_title': "5. अमन की मिश्रित यात्रा",
      's5_obj': "गतियों के बाद अंतिम स्थिति की गणना करें।",
      's5_step1_task': "अमन +2 पर है। 4 बार '–' और 1 बार '+' दबाएं।",
      's5_step1_out': "अमन खिलौनों की दुकान (-1) पर पहुंचा।",
      's5_step2_task': "गणितीय यात्रा देखें।",
      's5_step2_out': "यात्रा: (प्रारंभ: +2) + (-4) + (+1) = -1",
      's5_hud1': "4 बार '–', 1 बार '+' दबाएं। अंतिम दुकान चुनें।",
      's5_hud2': "समीकरण की समीक्षा करें।",

      'belaBuilding': "बेला का मस्ती भरा भवन",
      'targetLabel': "लक्ष्य",
      'startLabel': "प्रारंभ",
      'movementLabel': "कदम",
      'wrongWay': "गलत रास्ता!",
      'eqBoxTemplate': "लक्ष्य(    ) - प्रारंभ(    ) = कदम(    )",
      's1Summary':
          "जमीन (0) के ऊपर धनात्मक (+) है।\nजमीन (0) के नीचे ऋणात्मक (-) है।",
      's3Summary':
          "चाल रद्द करने के लिए विपरीत चाल चलें!\n+3 और -3 प्रतिलोम हैं। वे आपको 0 पर वापस लाते हैं।",
      's5PopupQ': "अमन किस दुकान पर पहुंचा?",
      's5Solved': "अमन की मिश्रित यात्रा: हल हो गई!",
      's5FinalEqu1': "मंजिल -1 (खिलौनों की दुकान) पर समाप्त!",
      's5FinalEqu2': "(प्रारंभ: +2) + (-4) + (+1) = -1",
      'reset': "रीसेट करें",
      'footerText': "© ज़ीरोसाइंसलैब | गणित और विज्ञान से प्यार करें",
    },
  };

  static String t(String lang, String key) {
    return data[lang]?[key] ?? data['en']?[key] ?? key;
  }
}

// --- ऐप की स्थिति (APP STATE) ---
class SimState extends ChangeNotifier {
  String lang = 'en';
  bool isSidebarOpen = true;
  double sidebarWidth = 350.0;
  bool showCurtain = true;
  bool showSuccessPopup = false;

  double panX = -120;
  double panY = -40;
  double zoom = 0.8;

  int scenario = 1;
  int step = 0;

  double liftFloor = 0;
  double targetFloor = 0;
  int startFloor = 0;
  List<int> equation = [];
  bool packageDelivered = false;

  bool animating = false;
  String? activeDragEntity;
  double dragOffset = 0;
  double wrongWayOpacity = 0.0;
  int? hoverShop;

  void toggleLanguage() {
    lang = lang == 'en' ? 'hi' : 'en';
    notifyListeners();
  }

  void setScenario(int s) {
    scenario = s;
    step = 0;
    equation.clear();
    packageDelivered = false;
    animating = false;
    wrongWayOpacity = 0;
    hoverShop = null;

    if (s == 1) {
      startFloor = 0;
      liftFloor = 0;
      targetFloor = 0;
    }
    if (s == 2) {
      startFloor = 0;
      liftFloor = 0;
      targetFloor = 0;
    }
    if (s == 3) {
      startFloor = 3;
      liftFloor = 3;
      targetFloor = 3;
    }
    if (s == 4) {
      startFloor = -1;
      liftFloor = -1;
      targetFloor = 1;
    }
    if (s == 5) {
      startFloor = 2;
      liftFloor = 2;
      targetFloor = 2;
    }

    showSuccessPopup = false;
    notifyListeners();
  }

  void advanceStep() {
    step++;
    notifyListeners();
  }
}

// --- मुख्य स्क्रीन (MAIN SCREEN) ---
class Cl6M_Ch10_A1_IntroductionToNegativeNumbersAndNumberLine
    extends StatefulWidget {
  const Cl6M_Ch10_A1_IntroductionToNegativeNumbersAndNumberLine({Key? key})
    : super(key: key);

  @override
  State<Cl6M_Ch10_A1_IntroductionToNegativeNumbersAndNumberLine>
  createState() =>
      _Cl6M_Ch10_A1_IntroductionToNegativeNumbersAndNumberLineState();
}

class _Cl6M_Ch10_A1_IntroductionToNegativeNumbersAndNumberLineState
    extends State<Cl6M_Ch10_A1_IntroductionToNegativeNumbersAndNumberLine>
    with SingleTickerProviderStateMixin {
  final SimState _state = SimState();
  final GlobalKey _canvasKey = GlobalKey();

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // Scroll Controllers
  final ScrollController _sidebarScrollController = ScrollController();
  final ScrollController _curtainScrollController = ScrollController();

  late Ticker _ticker;
  double _initialZoom = 1.0;

  @override
  void initState() {
    super.initState();
    // इमर्सिव मोड (Immersive Mode)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker(_onTick)..start();
    _state.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _state.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _sidebarScrollController.dispose();
    _curtainScrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
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

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
  // ---------------------

  void _onTick(Duration elapsed) {
    if (_state.wrongWayOpacity > 0) {
      _state.wrongWayOpacity = max(0, _state.wrongWayOpacity - 0.02);
      setState(() {});
    }

    if (_state.animating) {
      double diff = _state.targetFloor - _state.liftFloor;
      if (diff.abs() < 0.05) {
        _state.liftFloor = _state.targetFloor;
        _state.animating = false;
        _checkScenarioProgress();
      } else {
        _state.liftFloor += diff * 0.15; // स्मूथ ईज (Smooth ease)
        setState(() {});
      }
    }
  }

  void _triggerAction(String action) {
    if (_state.animating) return;

    if (_state.scenario == 3) {
      if (_state.step == 0 && action == 'plus') {
        _state.wrongWayOpacity = 1.0;
        playError();
        return;
      }
      if (_state.step == 1 && action == 'minus') {
        _state.wrongWayOpacity = 1.0;
        playError();
        return;
      }
      _state.wrongWayOpacity = 0;
    }

    if (_state.scenario == 5) {
      if (_state.step >= 1 || _state.equation.length >= 5) return;
    }

    if (action == 'plus' || action == 'minus') {
      int dir = action == 'plus' ? 1 : -1;
      int target = _state.liftFloor.round() + dir;

      if (target > 3 || target < -3) {
        playError();
        return;
      }

      if (_state.scenario == 2 && _state.step == 0 && action == 'minus') {
        playError();
        return;
      }
      if (_state.scenario == 2 && _state.step == 1 && action == 'plus') {
        playError();
        return;
      }

      if (_state.scenario == 5 && _state.step == 0) {
        if (_state.equation.length < 4 && action == 'plus') {
          playError();
          return;
        }
        if (_state.equation.length >= 4 && action == 'minus') {
          playError();
          return;
        }
      }

      playClick(); // Valid move!
      _state.targetFloor = target.toDouble();
      _state.animating = true;
      _state.equation.add(dir);
    }
  }

  void _checkScenarioProgress() {
    int floor = _state.liftFloor.round();

    if (_state.scenario == 2) {
      if (_state.step == 0 && floor == 2 && _state.equation.length >= 2) {
        _state.advanceStep();
        _state.startFloor = 2;
        _state.equation.clear();
      } else if (_state.step == 1 &&
          floor == -3 &&
          _state.equation.length >= 5) {
        _state.advanceStep();
        Future.delayed(const Duration(seconds: 1), _showFinalPopup);
      }
    } else if (_state.scenario == 3) {
      if (_state.step == 0 && floor == 0 && _state.equation.length == 3) {
        _state.advanceStep();
        _state.startFloor = -3;
        _state.liftFloor = -3;
        _state.targetFloor = -3;
        _state.equation.clear();
      } else if (_state.step == 1 &&
          floor == 0 &&
          _state.equation.length == 3) {
        _state.advanceStep();
        Future.delayed(const Duration(seconds: 1), _showFinalPopup);
      }
    } else if (_state.scenario == 4) {
      int cTarget = _state.step == 0 ? 1 : -2;
      if (floor == cTarget) {
        _state.packageDelivered = true;
        Future.delayed(const Duration(seconds: 2), () {
          _state.advanceStep();
          if (_state.step == 1) {
            _state.liftFloor = 3;
            _state.startFloor = 3;
            _state.targetFloor = -2;
            _state.packageDelivered = false;
            _state.equation.clear();
          } else if (_state.step == 2) {
            _showFinalPopup();
          }
        });
      }
    } else if (_state.scenario == 5) {
      if (_state.step == 0 && _state.equation.length == 5) {
        // चयन की प्रतीक्षा करें (Await selection)
      }
    }
  }

  void _showFinalPopup() {
    playPageOpen();
    setState(() {
      _state.step = _getMaxSteps(_state.scenario);
      _state.showSuccessPopup = true;
    });
  }

  int _getMaxSteps(int s) {
    if (s == 1) return 3;
    if (s == 2) return 3;
    if (s == 3) return 3;
    if (s == 4) return 2;
    if (s == 5) return 2;
    return 0;
  }

  // सिंगल टैप्स को हैंडल करें (Handle single precise taps)
  void _handleTap(Offset localPos) {
    if (_state.animating || _state.showCurtain || _state.showSuccessPopup)
      return;

    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    double cx = box.size.width / 2;
    double cy = box.size.height / 2;

    double worldX = (localPos.dx - cx - _state.panX) / _state.zoom;
    double worldY = (localPos.dy - cy - _state.panY) / _state.zoom;

    bool hitBox(double x, double y, double w, double h) {
      return worldX >= x && worldX <= x + w && worldY >= y && worldY <= y + h;
    }

    if (_state.scenario == 5 &&
        _state.step == 0 &&
        _state.equation.length == 5) {
      // पॉपअप मेनू हिट्स (Popup menu hits)
      double mx = -220 + 540;
      double my = -140;
      if (hitBox(mx + 15, my + 60, 250, 25)) {
        // Toy Store (-1)
        playClick();
        _state.advanceStep();
        Future.delayed(const Duration(seconds: 3), _showFinalPopup);
      } else if (hitBox(mx + 15, my + 95, 250, 25) ||
          hitBox(mx + 15, my + 130, 250, 25)) {
        playError();
      }
      return;
    }

    if ((_state.scenario == 3 && _state.step >= 2) ||
        (_state.scenario == 4 && _state.packageDelivered) ||
        (_state.scenario == 5 && _state.step >= 1))
      return;

    double cxPan = -220 + 540;
    double cyPan = 100;
    double px = cxPan + 100;
    double py = cyPan + 70;
    double minX = cxPan + 210;
    double minY = cyPan + 70;

    if (hitBox(px - 40, py - 40, 80, 80)) {
      _triggerAction('plus');
    }
    if (hitBox(minX - 40, minY - 40, 80, 80)) {
      _triggerAction('minus');
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _initialZoom = _state.zoom;
    if (_state.animating || _state.showCurtain || _state.showSuccessPopup)
      return;

    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    double cx = box.size.width / 2;
    double cy = box.size.height / 2;

    double worldX =
        (details.localFocalPoint.dx - cx - _state.panX) / _state.zoom;
    double worldY =
        (details.localFocalPoint.dy - cy - _state.panY) / _state.zoom;

    bool hitBox(double x, double y, double w, double h) {
      return worldX >= x && worldX <= x + w && worldY >= y && worldY <= y + h;
    }

    if (_state.scenario == 1) {
      double ly = 0 - (_state.liftFloor * 90);
      if (hitBox(-20, ly - 40, 100, 80)) {
        _state.activeDragEntity = 'lift';
        _state.dragOffset = worldY - (ly - 40);
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_state.activeDragEntity == 'lift' && _state.scenario == 1) {
      RenderBox box =
          _canvasKey.currentContext!.findRenderObject() as RenderBox;
      double worldY =
          (details.localFocalPoint.dy - box.size.height / 2 - _state.panY) /
          _state.zoom;

      double targetY = worldY - _state.dragOffset;
      double targetFloorRaw = (0 - targetY - 40) / 90;

      _state.liftFloor = max(-3.0, min(3.0, targetFloorRaw));

      if (_state.step == 0 && _state.liftFloor >= 2.8) {
        _state.advanceStep();
      }
      if (_state.step == 1 && _state.liftFloor <= -2.8) {
        _state.advanceStep();
        Future.delayed(const Duration(seconds: 1), _showFinalPopup);
      }
      setState(() {});
    } else {
      setState(() {
        _state.panX += details.focalPointDelta.dx;
        _state.panY += details.focalPointDelta.dy;
        // स्मूथ स्केलिंग (Smooth scaling)
        if (details.scale != 1.0) {
          _state.zoom = max(0.3, min(2.5, _initialZoom * details.scale));
        }
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_state.activeDragEntity == 'lift') {
      _state.activeDragEntity = null;
      _state.targetFloor = _state.liftFloor.roundToDouble();
      _state.animating = true; // ग्रिड पर स्नैप करें (Snap to grid)
    }
  }

  String _t(String key) => Translations.t(_state.lang, key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // 1. कैनवास क्षेत्र (कैनवास एरिया)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? _state.sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: ClipRect(
                child: GestureDetector(
                  onTapUp: (details) => _handleTap(details.localPosition),
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: Container(
                    color: const Color(0xFF0F172A), // Dark bg
                    child: CustomPaint(
                      key: _canvasKey,
                      painter: BuildingPainter(_state, _t),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),

            // 2. HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _state.isSidebarOpen ? _state.sidebarWidth : 0,
              right: 0,
              bottom: 40,
              child: Center(child: _buildHUD()),
            ),

            // 3. साइडबार (Moved down in Stack so Menu Button renders ON TOP)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? 0 : -_state.sidebarWidth,
              top: 0,
              bottom: 0,
              width: _state.sidebarWidth,
              child: _buildSidebar(),
            ),

            // 4. साइडबार रिसाइज़र हैंडल
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? _state.sidebarWidth - 10 : -20,
              top: 0,
              bottom: 0,
              width: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    setState(() {
                      _state.sidebarWidth = max(
                        250.0,
                        min(
                          MediaQuery.of(context).size.width * 0.6,
                          _state.sidebarWidth + details.delta.dx,
                        ),
                      );
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFF334155), width: 1.5),
                      ),
                    ),
                    child: Center(
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
            ),

            // 5. मेनू बटन (फ्लोटिंग टॉप लेफ्ट - FIXED ON TOP)
            Positioned(
              top: 20,
              left: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B).withOpacity(0.9),
                child: Icon(
                  _state.isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  playClick();
                  setState(() => _state.isSidebarOpen = !_state.isSidebarOpen);
                },
              ),
            ),

            // 6. सफलता पॉपअप ओवरले
            if (_state.showSuccessPopup) _buildSuccessPopup(),

            // 7. कर्टेन स्क्रीन (सबसे ऊपर)
            if (_state.showCurtain) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF1E293B).withOpacity(0.95),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _sidebarScrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // पूरी तरह से स्क्रॉल करने योग्य हेडर क्षेत्र
                    Padding(
                      // Padded TOP by 65 to ensure the floating menu button doesn't block the title
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 65,
                        bottom: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.explore,
                                color: Colors.indigoAccent,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _t('appTitle'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Text(
                              _t('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.language,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _state.lang.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  playClick();
                                  _state.toggleLanguage();
                                },
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                                label: Text(
                                  _t('reset'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  playClick();
                                  setState(() {
                                    _state.setScenario(1);
                                    _state.showCurtain = true;
                                    _state.zoom = 0.8;
                                    _state.panX = -120;
                                    _state.panY = -40;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),

                    // मुख्य स्क्रॉल करने योग्य सामग्री
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('selectScenario').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _state.scenario,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0F172A),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                items: [1, 2, 3, 4, 5]
                                    .map(
                                      (i) => DropdownMenuItem(
                                        value: i,
                                        child: Text(_t('s${i}_title')),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    playDropdown();
                                    _state.setScenario(v);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // उद्देश्य
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
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
                                      _t('learnLbl'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _t('s${_state.scenario}_obj'),
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

                          // चरण
                          ...List.generate(
                            _getMaxSteps(_state.scenario),
                            (i) => _buildStepItem(i),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(), // फुटर को नीचे धकेलता है...
                    // फुटर
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.black26,
                      child: Text(
                        _t('footerText'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
    );
  }

  Widget _buildStepItem(int idx) {
    bool isCompleted = idx < _state.step;
    bool isActive = idx == _state.step;

    Color bg = isActive
        ? const Color(0xFF6366F1).withOpacity(0.15)
        : (isCompleted
              ? Colors.green.withOpacity(0.1)
              : Colors.white.withOpacity(0.02));
    Color border = isActive
        ? const Color(0xFF6366F1).withOpacity(0.5)
        : (isCompleted ? Colors.green.withOpacity(0.3) : Colors.white10);

    String tsk = _t('s${_state.scenario}_step${idx + 1}_task');
    String out = _t('s${_state.scenario}_step${idx + 1}_out');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF6366F1)
                  : (isCompleted ? Colors.green : Colors.white24),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${idx + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                  "${_t('stepLabel')} ${idx + 1}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tsk,
                  style: TextStyle(
                    color: isActive || isCompleted
                        ? Colors.white
                        : Colors.white54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      out,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        height: 1.3,
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

  Widget _buildHUD() {
    if (_state.step >= _getMaxSteps(_state.scenario)) return const SizedBox();
    String hudText = _t('s${_state.scenario}_hud${_state.step + 1}');

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          top: BorderSide(color: Color(0xFF6366F1), width: 3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF818CF8), size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              hudText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessPopup() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _state.scenario == 5
                      ? const Color(0xFF6366F1)
                      : Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flag, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                _t('summaryTitle'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t('finalDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _state.scenario < 5
                      ? const Color(0xFF6366F1)
                      : Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  playClick();
                  if (_state.scenario < 5) {
                    _state.setScenario(_state.scenario + 1);
                  } else {
                    setState(() {
                      _state.showSuccessPopup = false;
                      _state.setScenario(1);
                      _state.showCurtain = true;
                    });
                  }
                },
                icon: Icon(
                  _state.scenario < 5 ? Icons.arrow_forward : Icons.refresh,
                  color: Colors.white,
                ),
                label: Text(
                  _state.scenario < 5 ? _t('nextScenario') : _t('finishLab'),
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
    );
  }

  Widget _buildCurtain() {
    return Container(
      color: const Color(0xFF0F172A),
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        controller: _curtainScrollController,
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.elevator,
                size: 100,
                color: const Color(0xFF6366F1).withOpacity(0.8),
              ),
              const SizedBox(height: 24),
              Text(
                _t('shutterTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t('appSubtitle'),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
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
                ),
                onPressed: () {
                  curtainScreen();
                  setState(() => _state.showCurtain = false);
                },
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  _t('enterLab'),
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
    );
  }
}

// --- कस्टम पेंटर (कैनवास) ---
class BuildingPainter extends CustomPainter {
  final SimState state;
  final String Function(String) t;
  BuildingPainter(this.state, this.t) : super(repaint: state);

  final double BLD_X = -220;
  final double ZERO_Y = 0;
  final double FLOOR_HEIGHT = 90;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 5 && state.step == 1) {
      // परिदृश्य 5 सारांश ओवरले
      canvas.saveLayer(
        Rect.fromLTWH(-1000, -1000, 2000, 2000),
        Paint()..color = Colors.black.withOpacity(0.4),
      );
      _drawBuilding(canvas);
      _drawLift(canvas);
      canvas.restore();
      _drawS5SummaryLine(canvas);
    } else {
      _drawBuilding(canvas);
      _drawLift(canvas);

      if (state.scenario == 1 && state.step >= 2) {
        _drawS1Summary(canvas);
      } else if (state.scenario == 3 && state.step >= 2) {
        _drawS3Summary(canvas);
      } else if (state.scenario != 1) {
        _drawControlPanel(canvas);
        _drawEquationBox(canvas);
        if (state.scenario == 5 &&
            state.step == 0 &&
            state.equation.length == 5 &&
            !state.animating) {
          _drawS5Popup(canvas);
        }
      }
    }

    canvas.restore();
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double sw,
  ) {
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    if (sw > 0)
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw,
      );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 16,
    Color color = Colors.white,
    bool bold = true,
    TextAlign align = TextAlign.center,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Roboto',
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        x - (align == TextAlign.center ? tp.width / 2 : 0),
        y - tp.height / 2,
      ),
    );
  }

  void _drawTextWithOutline(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 16,
    Color color = Colors.white,
    Color outColor = const Color(0xFF0F172A),
    double outW = 3,
  }) {
    TextPainter tpOut = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = outW
            ..color = outColor
            ..strokeJoin = StrokeJoin.round,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tpOut.layout();
    tpOut.paint(canvas, Offset(x - tpOut.width / 2, y - tpOut.height / 2));
    _drawText(canvas, text, x, y, fontSize: fontSize, color: color, bold: true);
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width,
  ) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawArrow(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width,
    double headSize,
  ) {
    _drawLine(canvas, x1, y1, x2, y2, color, width);
    double angle = atan2(y2 - y1, x2 - x1);
    Path p = Path();
    p.moveTo(x2, y2);
    p.lineTo(
      x2 - headSize * cos(angle - pi / 6),
      y2 - headSize * sin(angle - pi / 6),
    );
    p.lineTo(
      x2 - headSize * cos(angle + pi / 6),
      y2 - headSize * sin(angle + pi / 6),
    );
    p.close();
    canvas.drawPath(p, Paint()..color = color);
  }

  String _fmt(num n) => n > 0 ? "+$n" : "$n";

  // --- एंटिटी ड्रॉअर्स ---
  void _drawBuilding(Canvas canvas) {
    double bx = BLD_X, by = -400, bw = 500, bh = 750;

    // ज़मीन (Ground)
    canvas.drawRect(
      Rect.fromLTWH(-2000, 40, 4000, 3000),
      Paint()..color = const Color(0xFF27272A),
    );
    _drawLine(canvas, -2000, 40, 2000, 40, const Color(0xFF3F3F46), 6);

    // छत (Roof)
    Path roof = Path()
      ..moveTo(bx - 20, by)
      ..lineTo(bx + bw + 20, by)
      ..lineTo(bx + bw, by - 30)
      ..lineTo(bx, by - 30)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF78350F));
    canvas.drawPath(
      roof,
      Paint()
        ..color = const Color(0xFF451A03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // साइनबोर्ड
    _drawRoundedRect(
      canvas,
      bx + bw / 2 - 120,
      by - 40,
      240,
      30,
      6,
      const Color(0xFFFACC15),
      const Color(0xFFB45309),
      4,
    );
    _drawText(
      canvas,
      t('belaBuilding'),
      bx + bw / 2,
      by - 25,
      color: const Color(0xFF0F172A),
    );

    // बाहरी दीवारें
    canvas.drawRect(
      Rect.fromLTWH(bx - 10, by, bw + 20, bh),
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // शाफ्ट
    double shaftW = 120;
    double shaftX = bx + bw / 2 - shaftW / 2;
    _drawRoundedRect(
      canvas,
      shaftX,
      by + 10,
      shaftW,
      bh - 10,
      2,
      const Color(0xFF0F172A),
      const Color(0xFF334155),
      4,
    );

    // मंजिलों का डेटा
    List<Map<String, dynamic>> floors = [
      {
        'lvl': 3,
        'k': 'f3',
        'c': const Color(0xFF10B981),
        'bg': const Color(0xFF854D0E),
      },
      {
        'lvl': 2,
        'k': 'f2',
        'c': const Color(0xFFF59E0B),
        'bg': const Color(0xFF713F12),
      },
      {
        'lvl': 1,
        'k': 'f1',
        'c': const Color(0xFF3B82F6),
        'bg': const Color(0xFF92400E),
      },
      {
        'lvl': 0,
        'k': 'f0',
        'c': const Color(0xFF8B5CF6),
        'bg': const Color(0xFF9A3412),
      },
      {
        'lvl': -1,
        'k': 'fm1',
        'c': const Color(0xFFF43F5E),
        'bg': const Color(0xFF334155),
      },
      {
        'lvl': -2,
        'k': 'fm2',
        'c': const Color(0xFFEC4899),
        'bg': const Color(0xFF1E293B),
      },
      {
        'lvl': -3,
        'k': 'fm3',
        'c': const Color(0xFFEF4444),
        'bg': const Color(0xFF0F172A),
      },
    ];

    double roomW = (bw - shaftW) / 2 - 10;

    for (var f in floors) {
      int lvl = f['lvl'];
      Color fColor = f['c'];
      Color bg = f['bg'];
      double fy = ZERO_Y - (lvl * FLOOR_HEIGHT);
      double drawY = fy - FLOOR_HEIGHT / 2;

      _drawLine(
        canvas,
        bx - 10,
        fy + FLOOR_HEIGHT / 2,
        bx + bw + 10,
        fy + FLOOR_HEIGHT / 2,
        const Color(0xFF451A03),
        6,
      );

      // कमरे
      canvas.drawRect(
        Rect.fromLTWH(bx, drawY, roomW, FLOOR_HEIGHT),
        Paint()..color = bg,
      );
      canvas.drawRect(
        Rect.fromLTWH(bx + bw - roomW, drawY, roomW, FLOOR_HEIGHT),
        Paint()..color = bg,
      );

      // साइनबोर्ड
      bool isActive = state.liftFloor.round() == lvl;
      double signW = 110, signH = 30;
      double signX = (lvl % 2 == 0) ? bx + 10 : bx + bw - roomW + 10;
      double signY = fy - signH / 2 + 20;

      Color signBg = isActive ? fColor : const Color(0xFF1E293B);
      Color signBorder = isActive ? Colors.white : const Color(0xFF334155);

      _drawRoundedRect(
        canvas,
        signX,
        signY,
        signW,
        signH,
        4,
        signBg,
        signBorder,
        isActive ? 3 : 2,
      );
      _drawText(
        canvas,
        t(f['k']),
        signX + signW / 2,
        signY + signH / 2,
        fontSize: 11,
        color: isActive ? Colors.white : Colors.white70,
      );

      // नंबर बॉक्स
      Color indBg = lvl > 0
          ? const Color(0xFFFEF08A)
          : (lvl < 0 ? const Color(0xFFCBD5E1) : const Color(0xFFF8FAFC));
      Color indBorder = lvl > 0
          ? const Color(0xFFCA8A04)
          : (lvl < 0 ? const Color(0xFF475569) : const Color(0xFF94A3B8));
      if (isActive) {
        indBg = fColor;
        indBorder = Colors.white;
      }

      double indX = (lvl % 2 == 0) ? signX + signW + 5 : signX - 45;
      _drawRoundedRect(canvas, indX, signY, 40, 30, 4, indBg, indBorder, 2);
      _drawText(
        canvas,
        _fmt(lvl),
        indX + 20,
        signY + 15,
        color: isActive ? Colors.white : const Color(0xFF0F172A),
      );

      // लक्ष्य हाइलाइट S4
      if (state.scenario == 4 && !state.packageDelivered) {
        int target = state.step == 0 ? 1 : -2;
        if (lvl == target) {
          canvas.drawRect(
            Rect.fromLTWH(
              bx - 10,
              fy - FLOOR_HEIGHT / 2,
              bw + 20,
              FLOOR_HEIGHT,
            ),
            Paint()..color = Colors.lightBlueAccent.withOpacity(0.3),
          );
          double tx = shaftX + shaftW + 10;
          _drawRoundedRect(
            canvas,
            tx,
            fy - 15,
            90,
            30,
            4,
            Colors.white,
            const Color(0xFF0F172A),
            2,
          );
          _drawText(
            canvas,
            "${t('targetLabel')}(${_fmt(target)})",
            tx + 45,
            fy,
            color: const Color(0xFF0F172A),
            fontSize: 12,
          );
        }
      }
    }
  }

  void _drawLift(Canvas canvas) {
    double ly = ZERO_Y - (state.liftFloor * FLOOR_HEIGHT);
    double lw = 100;
    double lh = FLOOR_HEIGHT - 10;
    double lx = BLD_X + 250 - 60 + 10;
    double drawY = ly - lh / 2;

    _drawRoundedRect(
      canvas,
      lx,
      drawY,
      lw,
      lh,
      8,
      const Color(0x3338BDF8),
      const Color(0xFF0EA5E9),
      3,
    );

    // अंदर सरल व्यक्ति बनाएं
    if (state.scenario >= 2) {
      canvas.drawCircle(
        Offset(lx + lw / 2, drawY + lh / 2 - 5),
        10,
        Paint()..color = const Color(0xFFFCA5A5),
      ); // सिर
      _drawRoundedRect(
        canvas,
        lx + lw / 2 - 10,
        drawY + lh / 2 + 5,
        20,
        20,
        4,
        const Color(0xFFFACC15),
        Colors.orange,
        2,
      ); // शरीर
      if (state.scenario == 4 && !state.packageDelivered) {
        _drawRoundedRect(
          canvas,
          lx + lw / 2 - 12,
          drawY + lh / 2 + 15,
          24,
          15,
          2,
          const Color(0xFFD97706),
          const Color(0xFF92400E),
          2,
        ); // पैकेज
      }
    }

    _drawLine(
      canvas,
      lx + lw / 2,
      drawY,
      lx + lw / 2,
      drawY + lh,
      const Color(0x880EA5E9),
      2,
    ); // दरवाजे
  }

  void _drawControlPanel(Canvas canvas) {
    double cx = BLD_X + 540;
    double cy = ZERO_Y + 100;
    double cw = 280;
    double ch = 140;

    _drawRoundedRect(
      canvas,
      cx,
      cy,
      cw,
      ch,
      12,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      5,
    );
    _drawRoundedRect(
      canvas,
      cx + 5,
      cy + 5,
      cw - 10,
      ch - 10,
      8,
      const Color(0xFF64748B),
      Colors.transparent,
      0,
    );

    // सजावटी ग्रिड
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 2; col++) {
        _drawRoundedRect(
          canvas,
          cx + 15 + col * 15,
          cy + 20 + row * 25,
          10,
          15,
          2,
          const Color(0xFF334155),
          const Color(0xFF1E293B),
          1,
        );
      }
    }

    // प्लस बटन (हरा)
    double r = 40;
    double px = cx + 100;
    double py = cy + 70;
    _drawRoundedRect(
      canvas,
      px - r,
      py - r,
      r * 2,
      r * 2,
      r,
      const Color(0xFF22C55E),
      const Color(0xFF14532D),
      6,
    );
    _drawLine(canvas, px - 15, py, px + 15, py, const Color(0xFF14532D), 8);
    _drawLine(canvas, px, py - 15, px, py + 15, const Color(0xFF14532D), 8);

    // माइनस बटन (लाल)
    double mx = cx + 210;
    double my = cy + 70;
    _drawRoundedRect(
      canvas,
      mx - r,
      my - r,
      r * 2,
      r * 2,
      r,
      const Color(0xFFEF4444),
      const Color(0xFF7F1D1D),
      6,
    );
    _drawLine(canvas, mx - 15, my, mx + 15, my, const Color(0xFF7F1D1D), 8);

    // डिस्प्ले
    if (state.scenario == 4 && state.packageDelivered) {
      _drawRoundedRect(
        canvas,
        cx,
        cy,
        cw,
        ch,
        12,
        const Color(0xCC0F172A),
        const Color(0xFF1E293B),
        5,
      );
      int target = state.step == 0 ? 1 : -2;
      int start = state.step == 0 ? -1 : 3;
      String eqStr =
          "(${_fmt(target)}) - (${_fmt(start)}) = (${_fmt(target - start)})";
      _drawText(
        canvas,
        eqStr,
        cx + cw / 2,
        cy + ch / 2,
        fontSize: 18,
        color: const Color(0xFFFACC15),
      );
    } else if (state.scenario != 4) {
      _drawRoundedRect(
        canvas,
        cx + 55,
        cy + 15,
        cw - 70,
        25,
        4,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        2,
      );
      for (int i = 0; i < 10; i++) {
        canvas.drawRect(
          Rect.fromLTWH(cx + 65 + i * 18, cy + 20, 10, 15),
          Paint()
            ..color = i < state.equation.length
                ? const Color(0xFF22C55E)
                : const Color(0xFF334155),
        );
      }
    }

    // गलत रास्ते की चेतावनी
    if (state.wrongWayOpacity > 0) {
      Paint p = Paint()
        ..color = Colors.white.withOpacity(state.wrongWayOpacity);
      canvas.drawRect(Rect.fromLTWH(cx + 80, cy - 50, 100, 40), p);
      _drawText(
        canvas,
        t('wrongWay'),
        cx + 130,
        cy - 30,
        color: Colors.red.withOpacity(state.wrongWayOpacity),
      );
    }
  }

  void _drawEquationBox(Canvas canvas) {
    if (state.scenario == 4 && !state.packageDelivered) {
      double ex = BLD_X + 250, ey = ZERO_Y + 300, ew = 400, eh = 50;
      _drawRoundedRect(
        canvas,
        ex - ew / 2,
        ey - eh / 2,
        ew,
        eh,
        25,
        Colors.white,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(
        canvas,
        t('eqBoxTemplate'),
        ex,
        ey,
        color: const Color(0xFF0F172A),
      );
      return;
    }
    if (state.scenario == 1 || (state.scenario == 4 && state.packageDelivered))
      return;

    double ex = BLD_X + 250;
    double ey = -440;
    double ew = 650;
    double eh = 65;
    _drawRoundedRect(
      canvas,
      ex - ew / 2,
      ey - eh / 2,
      ew,
      eh,
      12,
      const Color(0xFFF8FAFC),
      const Color(0xFF6366F1),
      4,
    );

    double cx = ex - ew / 2 + 20;

    if (state.scenario == 3) {
      Color c = state.startFloor > 0
          ? const Color(0xFF22C55E)
          : const Color(0xFFEF4444);
      _drawRoundedRect(canvas, cx, ey - 18, 48, 36, 6, c, Colors.black, 2);
      _drawTextWithOutline(canvas, "(${_fmt(state.startFloor)})", cx + 24, ey);
      cx += 55;
    } else {
      _drawText(
        canvas,
        "(${t('startLabel')}: ${_fmt(state.startFloor)})",
        cx + 50,
        ey,
        color: const Color(0xFF0F172A),
        fontSize: 20,
      );
      cx += 120;
    }

    bool isFinal = false;
    for (int i = 0; i < state.equation.length; i++) {
      if (state.scenario == 3 && i < state.equation.length - 1) continue;

      int move = state.scenario == 3
          ? state.equation.fold(0, (a, b) => a + b)
          : state.equation[i];
      _drawText(
        canvas,
        "+",
        cx + 15,
        ey,
        color: const Color(0xFF0F172A),
        fontSize: 22,
      );
      cx += 35;
      Color c = move > 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
      _drawRoundedRect(canvas, cx, ey - 18, 48, 36, 6, c, Colors.black, 2);
      _drawTextWithOutline(canvas, "(${_fmt(move)})", cx + 24, ey);
      cx += 55;

      if (state.scenario == 3 && state.equation.length < 3) {
        _drawText(
          canvas,
          "...",
          cx + 20,
          ey,
          color: const Color(0xFF0F172A),
          fontSize: 22,
        );
      } else if (state.scenario == 3 && state.equation.length == 3) {
        isFinal = true;
      }
    }

    if ((state.equation.isNotEmpty && state.scenario != 3) || isFinal) {
      _drawText(
        canvas,
        "=",
        cx + 15,
        ey,
        color: const Color(0xFF0F172A),
        fontSize: 22,
      );
      cx += 35;
      int res = state.startFloor + state.equation.fold(0, (a, b) => a + b);
      Color rc = res > 0
          ? const Color(0xFF22C55E)
          : (res < 0 ? const Color(0xFF3B82F6) : const Color(0xFFFACC15));
      _drawRoundedRect(canvas, cx, ey - 22, 55, 44, 6, rc, Colors.black, 2);
      _drawTextWithOutline(
        canvas,
        res == 0 ? "0" : _fmt(res),
        cx + 27.5,
        ey,
        fontSize: 22,
      );
    }
  }

  void _drawS1Summary(Canvas canvas) {
    double bx = BLD_X, bw = 500;

    _drawRoundedRect(
      canvas,
      bx - 30,
      ZERO_Y - 315,
      bw + 60,
      260,
      8,
      const Color(0x2610B981),
      const Color(0xFF10B981),
      4,
    );
    _drawRoundedRect(
      canvas,
      bx - 30,
      ZERO_Y + 45,
      bw + 60,
      260,
      8,
      const Color(0x26F43F5E),
      const Color(0xFFF43F5E),
      4,
    );

    _drawRoundedRect(
      canvas,
      bx + bw / 2 - 250,
      ZERO_Y - 37.5,
      500,
      75,
      12,
      const Color(0xFF1E293B),
      const Color(0xFF6366F1),
      4,
    );
    _drawText(canvas, t('s1Summary'), bx + bw / 2, ZERO_Y);
  }

  void _drawS3Summary(Canvas canvas) {
    double px = BLD_X + 250;
    double py = ZERO_Y - 330;
    _drawRoundedRect(
      canvas,
      px - 275,
      py,
      550,
      150,
      12,
      const Color(0xFFF8FAFC),
      const Color(0xFF6366F1),
      4,
    );
    _drawText(
      canvas,
      t('s3Summary'),
      px,
      py + 75,
      color: const Color(0xFF0F172A),
    );

    double gy = ZERO_Y + 120;
    _drawTextWithOutline(
      canvas,
      "+3",
      px - 180,
      gy,
      fontSize: 100,
      color: const Color(0xFF22C55E),
      outColor: const Color(0xFF064E3B),
      outW: 6,
    );
    _drawTextWithOutline(
      canvas,
      "-3",
      px + 180,
      gy,
      fontSize: 100,
      color: const Color(0xFFEF4444),
      outColor: const Color(0xFF7F1D1D),
      outW: 6,
    );
    _drawTextWithOutline(
      canvas,
      "0",
      px,
      gy,
      fontSize: 120,
      color: const Color(0xFFFACC15),
      outColor: const Color(0xFFB45309),
      outW: 8,
    );

    _drawArrow(
      canvas,
      px - 100,
      gy,
      px - 50,
      gy,
      const Color(0xFF22C55E),
      10,
      25,
    );
    _drawArrow(
      canvas,
      px + 100,
      gy,
      px + 50,
      gy,
      const Color(0xFFEF4444),
      10,
      25,
    );
  }

  void _drawS5Popup(Canvas canvas) {
    double mx = BLD_X + 540;
    double my = -140;
    double mw = 280;
    double mh = 180;
    _drawRoundedRect(
      canvas,
      mx,
      my,
      mw,
      mh,
      10,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      4,
    );
    _drawText(canvas, t('s5PopupQ'), mx + mw / 2, my + 25);

    List<Map> opts = [
      {'t': "${t('fm1')} (-1)", 'y': my + 60},
      {'t': "${t('f3')} (+3)", 'y': my + 95},
      {'t': "${t('fm3')} (-3)", 'y': my + 130},
    ];
    for (var o in opts) {
      _drawRoundedRect(
        canvas,
        mx + 15,
        o['y'],
        mw - 30,
        30,
        6,
        const Color(0xFFCBD5E1),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(
        canvas,
        o['t'],
        mx + mw / 2,
        o['y'] + 15,
        color: const Color(0xFF0F172A),
        fontSize: 14,
      );
    }
    _drawArrow(
      canvas,
      mx - 40,
      my + 100,
      mx,
      my + 100,
      const Color(0xFF4ADE80),
      6,
      15,
    );
  }

  void _drawS5SummaryLine(Canvas canvas) {
    double nx = BLD_X + 250;
    double ny = ZERO_Y + 10;
    double nw = 800;
    _drawLine(
      canvas,
      nx - nw / 2 - 20,
      ny,
      nx + nw / 2 + 20,
      ny,
      Colors.white,
      8,
    );
    _drawArrow(
      canvas,
      nx - nw / 2 + 20,
      ny,
      nx - nw / 2 - 20,
      ny,
      Colors.white,
      8,
      20,
    );
    _drawArrow(
      canvas,
      nx + nw / 2 - 20,
      ny,
      nx + nw / 2 + 20,
      ny,
      Colors.white,
      8,
      20,
    );

    double step = nw / 12;
    for (int i = -5; i <= 5; i++) {
      double tx = nx + (i * step);
      _drawLine(canvas, tx, ny - 15, tx, ny + 15, Colors.white, i == 0 ? 8 : 4);
      _drawTextWithOutline(canvas, "$i", tx, ny + 35, fontSize: 20);
    }

    double sx = nx + 2 * step;
    double mx = nx + -2 * step;
    double ex = nx + -1 * step;

    _drawRoundedRect(
      canvas,
      sx - 30,
      ny - 80,
      60,
      45,
      8,
      const Color(0xFFFACC15),
      const Color(0xFFB45309),
      4,
    );
    _drawText(
      canvas,
      "+2",
      sx,
      ny - 57.5,
      color: const Color(0xFF0F172A),
      fontSize: 22,
    );

    // तीर +2 से -2
    Path p1 = Path()
      ..moveTo(sx, ny + 40)
      ..quadraticBezierTo((sx + mx) / 2, ny + 180, mx, ny + 40);
    canvas.drawPath(
      p1,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    _drawArrow(
      canvas,
      mx + 15,
      ny + 60,
      mx,
      ny + 40,
      const Color(0xFF38BDF8),
      8,
      20,
    );

    _drawRoundedRect(
      canvas,
      (sx + mx) / 2 - 45,
      ny + 140,
      90,
      45,
      8,
      const Color(0xFF38BDF8),
      const Color(0xFF0284C7),
      4,
    );
    _drawText(
      canvas,
      "+(-4)",
      (sx + mx) / 2,
      ny + 162.5,
      color: const Color(0xFF0F172A),
      fontSize: 22,
    );

    // तीर -2 से -1
    Path p2 = Path()
      ..moveTo(mx, ny - 40)
      ..quadraticBezierTo((mx + ex) / 2, ny - 120, ex, ny - 40);
    canvas.drawPath(
      p2,
      Paint()
        ..color = const Color(0xFF4ADE80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    _drawArrow(
      canvas,
      ex - 10,
      ny - 55,
      ex,
      ny - 40,
      const Color(0xFF4ADE80),
      8,
      20,
    );

    _drawRoundedRect(
      canvas,
      (mx + ex) / 2 - 35,
      ny - 130,
      70,
      40,
      6,
      const Color(0xFF4ADE80),
      const Color(0xFF166534),
      4,
    );
    _drawText(
      canvas,
      "+1",
      (mx + ex) / 2,
      ny - 110,
      color: const Color(0xFF0F172A),
      fontSize: 20,
    );

    _drawRoundedRect(
      canvas,
      ex - 30,
      ny - 20,
      60,
      40,
      8,
      const Color(0xFF22C55E),
      const Color(0xFF14532D),
      4,
    );
    _drawText(canvas, "-1", ex, ny, fontSize: 20);

    _drawRoundedRect(
      canvas,
      nx - 220,
      ny - 220,
      440,
      60,
      10,
      Colors.white,
      const Color(0xFF0F172A),
      5,
    );
    _drawText(
      canvas,
      t('s5Solved'),
      nx,
      ny - 190,
      color: const Color(0xFF0F172A),
      fontSize: 24,
    );

    _drawRoundedRect(
      canvas,
      nx - 300,
      ny + 220,
      600,
      100,
      10,
      Colors.white,
      const Color(0xFF0F172A),
      5,
    );
    _drawText(
      canvas,
      "${t('s5FinalEqu1')}\n${t('s5FinalEqu2')}",
      nx,
      ny + 270,
      color: const Color(0xFF0F172A),
      fontSize: 22,
    );
  }

  @override
  bool shouldRepaint(covariant BuildingPainter oldDelegate) => true;
}
