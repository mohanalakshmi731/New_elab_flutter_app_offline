// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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
      home: const Cl6M_Ch10_A3_AddingIntegersUsingContextualModels(),
    ),
  );
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': "Adding Integers using Contextual Models",
    'appSubtitle': "Class 6 • THE OTHER SIDE OF ZERO",
    'enterLab': "Enter Simulation",
    'appTitle': "Adding Integers",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Objective:",
    'resetBtn': "Reset Lab",
    'nextScenario': "Next Scenario",
    'lbl_go': "GO",
    'lbl_calc_area': "Calculation Area",
    'lbl_ans_box': "Answer Box",
    'lbl_wrong_way': "Wrong Way!",
    'lbl_mission': "Mission:",
    'lbl_mission_complete': "Mission Complete:",
    'lbl_red_tokens': "Red +1 Tokens",
    'lbl_green_tokens': "Green -1 Tokens",
    'lbl_zero_pair': "Zero Pair!",
    'f5': "Floor +5",
    'f4': "Sports Centre",
    'f3': "Book Store",
    'f2': "Art Centre",
    'f1': "Food Court",
    'f0': "Welcome Hall",
    'fm1': "Toy Store",
    'fm2': "Storage",
    'fm3': "Cinema Centre",
    'fm4': "Parking L1",
    'fm5': "Parking L2",
    's1_title': "1. Going Up!",
    's1_obj':
        "To understand the addition of two positive integers by moving a lift up.",
    's1_step1_task':
        "The lift is at Floor +1. Equation: (+1) + (+2) = ? CLICK the '+' button once.",
    's1_step1_out': "Recorded +1 (up 1 floor).",
    's1_step2_task': "CLICK the '+' button again to make it +2.",
    's1_step2_out': "Recorded +2 (planned movement up 2 floors).",
    's1_step3_task': "CLICK 'GO' to see where the lift goes.",
    's1_step3_out': "Lift moves UP. Added +2 distance.",
    's1_step4_task': "Observe the summary.",
    's1_step4_out': "Started at +1, moved UP 2 floors. Reached +3.",
    's1_hud1': "Click the '+' button.",
    's1_hud2': "Click the '+' button again.",
    's1_hud3': "Click the 'GO' button.",
    's1_hud4': "Observe the result.",
    's1_summary': "Started at +1 and\nmoved UP 2 floors.\nReached +3.",
    's2_title': "2. A Little Dip",
    's2_obj': "Understand adding a positive and a negative integer.",
    's2_step1_task':
        "Equation: (+4) + (-3) = ? CLICK the '-' button three times.",
    's2_step1_out': "Recorded -3 (downward 3 floors).",
    's2_step2_task': "CLICK the 'GO' button.",
    's2_step2_out': "Lift moves DOWN.",
    's2_step3_task': "Observe the summary.",
    's2_step3_out': "Started at +4, moved DOWN 3. Reached +1.",
    's2_hud1': "Click the '-' button 3 times.",
    's2_hud2': "Click the 'GO' button.",
    's2_hud3': "Observe the result.",
    's2_summary': "Started at +4 and\nmoved DOWN 3 floors.\nReached +1.",
    's3_title': "3. Zero Pairs!",
    's3_obj': "Solve by creating zero pairs where tokens cancel out.",
    's3_step1_task':
        "Solve (+2) + (-5) = ? DRAG two red '+1' tokens to the Calc Area.",
    's3_step1_out': "Two red tokens represent +2.",
    's3_step2_task': "DRAG five green '-1' tokens to the Calc Area.",
    's3_step2_out': "Five green tokens represent -5.",
    's3_step3_task':
        "DRAG a red token on top of a green one to cancel (Zero Pair).",
    's3_step3_out': "A pair neutralized each other.",
    's3_step4_task': "Keep making zero pairs until done.",
    's3_step4_out': "All pairs removed.",
    's3_step5_task': "Observe your answer.",
    's3_step5_out': "Result is -3.",
    's3_hud1': "Drag 2 red tokens to the center.",
    's3_hud2': "Drag 5 green tokens to the center.",
    's3_hud3': "Drag a red token over a green one to cancel.",
    's3_hud4': "Cancel the remaining zero pair.",
    's3_hud5': "Observe final answer.",
    's3_summary': "Combining (+2) and (-5) leaves (-3).",
    's4_title': "4. Going Deeper",
    's4_obj': "Add two negative integers.",
    's4_step1_task': "Solve (-1) + (-2) = ? Input -2 and click GO.",
    's4_step1_out': "Prepared downward movement.",
    's4_step2_task': "Observe the lift.",
    's4_step2_out': "Moving down from negative goes deeper.",
    's4_hud1': "Input -2 on the panel and click GO.",
    's4_hud2': "Observe the result.",
    's4_summary': "Started at B1 and\nmoved DOWN 2 floors.\nReached B3.",
    's5_title': "5. Token Tally",
    's5_obj': "Complex addition using tokens.",
    's5_step1_task': "Solve (+5) + (-8) = ? Represent numbers with tokens.",
    's5_step1_out': "Tokens added.",
    's5_step2_task': "Form zero pairs. DRAG remaining to Answer Box.",
    's5_step2_out': "3 negative tokens form the answer.",
    's5_step3_task': "Observe answer.",
    's5_step3_out': "(+5) + (-8) = -3.",
    's5_hud1': "Drag 5 red and 8 green tokens to center.",
    's5_hud2': "Cancel pairs, drag rest to Answer Box.",
    's5_hud3': "Observe the final equation.",
  },
  'hi': {
    'shutterTitle': "प्रासंगिक मॉडल का उपयोग करके पूर्णांक जोड़ना",
    'appSubtitle': "कक्षा 6 • शून्य के दूसरी ओर",
    'enterLab': "सिमुलेशन दर्ज करें",
    'appTitle': "पूर्णांक जोड़ना",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "उद्देश्य:",
    'resetBtn': "रीसेट करें",
    'nextScenario': "अगला परिदृश्य",
    'lbl_go': "जाओ",
    'lbl_calc_area': "गणना क्षेत्र",
    'lbl_ans_box': "उत्तर बॉक्स",
    'lbl_wrong_way': "गलत रास्ता!",
    'lbl_mission': "मिशन:",
    'lbl_mission_complete': "मिशन पूर्ण:",
    'lbl_red_tokens': "लाल +1 टोकन",
    'lbl_green_tokens': "हरे -1 टोकन",
    'lbl_zero_pair': "शून्य जोड़ा!",
    'f5': "मंजिल +5",
    'f4': "खेल केंद्र",
    'f3': "किताबों की दुकान",
    'f2': "कला केंद्र",
    'f1': "फ़ूड कोर्ट",
    'f0': "स्वागत कक्ष",
    'fm1': "खिलौनों की दुकान",
    'fm2': "भंडारण",
    'fm3': "सिनेमा केंद्र",
    'fm4': "पार्किंग L1",
    'fm5': "पार्किंग L2",
    's1_title': "1. ऊपर जाना!",
    's1_obj': "लिफ्ट को ऊपर ले जाकर दो धनात्मक पूर्णांकों के जोड़ को समझना।",
    's1_step1_task': "समीकरण: (+1) + (+2) = ? '+' बटन को एक बार क्लिक करें।",
    's1_step1_out': "+1 दर्ज किया गया।",
    's1_step2_task': "+2 बनाने के लिए '+' बटन को एक बार और क्लिक करें।",
    's1_step2_out': "+2 दर्ज किया गया।",
    's1_step3_task': "'जाओ' बटन पर क्लिक करें।",
    's1_step3_out': "लिफ्ट ऊपर जाती है।",
    's1_step4_task': "सारांश देखें।",
    's1_step4_out': "मंजिल +1 से +3 पर पहुंचे।",
    's1_hud1': "'+' बटन पर क्लिक करें।",
    's1_hud2': "फिर से '+' बटन पर क्लिक करें।",
    's1_hud3': "'जाओ' बटन पर क्लिक करें।",
    's1_hud4': "परिणाम देखें।",
    's1_summary': "मंजिल +1 से शुरू किया\n2 मंजिल ऊपर गए।\n+3 पर पहुंचे।",
    's2_title': "2. थोड़ा सा गोता",
    's2_obj': "एक धनात्मक और ऋणात्मक पूर्णांक का जोड़।",
    's2_step1_task': "(+4) + (-3) = ? '-' बटन को 3 बार क्लिक करें।",
    's2_step1_out': "-3 दर्ज किया गया।",
    's2_step2_task': "'जाओ' बटन पर क्लिक करें।",
    's2_step2_out': "लिफ्ट नीचे जाती है।",
    's2_step3_task': "सारांश देखें।",
    's2_step3_out': "+4 से शुरू होकर +1 पर पहुंचे।",
    's2_hud1': "'-' बटन पर 3 बार क्लिक करें।",
    's2_hud2': "'जाओ' बटन पर क्लिक करें।",
    's2_hud3': "परिणाम का निरीक्षण करें।",
    's2_summary': "मंजिल +4 पर शुरू हुए\n3 मंजिल नीचे गए।\n+1 पर पहुंचे।",
    's3_title': "3. शून्य जोड़े!",
    's3_obj': "शून्य जोड़े बनाकर हल करें।",
    's3_step1_task': "(+2) + (-5) = ? 2 लाल टोकन खींचें।",
    's3_step1_out': "+2 का प्रतिनिधित्व।",
    's3_step2_task': "5 हरे टोकन खींचें।",
    's3_step2_out': "-5 का प्रतिनिधित्व।",
    's3_step3_task': "रद्द करने के लिए लाल को हरे पर खींचें।",
    's3_step3_out': "एक जोड़ा रद्द हुआ।",
    's3_step4_task': "बाकी जोड़े बनाएं।",
    's3_step4_out': "सभी जोड़े हटा दिए गए।",
    's3_step5_task': "उत्तर देखें।",
    's3_step5_out': "परिणाम -3 है।",
    's3_hud1': "2 लाल टोकन खींचें।",
    's3_hud2': "5 हरे टोकन खींचें।",
    's3_hud3': "टोकन को एक-दूसरे पर खींचें।",
    's3_hud4': "बाकी जोड़े रद्द करें।",
    's3_hud5': "उत्तर देखें।",
    's3_summary': "(+2) और (-5) को मिलाकर (-3) बचता है।",
    's4_title': "4. और गहराई में",
    's4_obj': "दो ऋणात्मक पूर्णांक जोड़ें।",
    's4_step1_task': "(-1) + (-2) = ? -2 इनपुट करें और GO दबाएं।",
    's4_step1_out': "नीचे की ओर गति।",
    's4_step2_task': "लिफ्ट देखें।",
    's4_step2_out': "गहराई में जाना।",
    's4_hud1': "-2 इनपुट करें और GO पर क्लिक करें।",
    's4_hud2': "परिणाम देखें।",
    's4_summary': "B1 से शुरू होकर\n2 मंजिल नीचे गए।\nB3 पर पहुंचे।",
    's5_title': "5. टोकन टैली",
    's5_obj': "टोकन का उपयोग करके जटिल जोड़।",
    's5_step1_task': "(+5) + (-8) = ? टोकन जोड़ें।",
    's5_step1_out': "टोकन प्रदर्शित।",
    's5_step2_task': "जोड़े बनाएं, बाकी उत्तर बॉक्स में डालें।",
    's5_step2_out': "3 ऋणात्मक टोकन बचे।",
    's5_step3_task': "उत्तर देखें।",
    's5_step3_out': "परिणाम -3 है।",
    's5_hud1': "5 लाल, 8 हरे टोकन खींचें।",
    's5_hud2': "जोड़े रद्द करें, बाकी उत्तर बॉक्स में डालें।",
    's5_hud3': "समीकरण देखें।",
  },
};

String t(String key, String lang) => i18n[lang]?[key] ?? key;

// --- AUDIO ENGINE ---
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// --- DATA MODELS ---
class Token {
  int id;
  int type; // 1 = positive, -1 = negative
  double x, y;
  String zone; // 'bin', 'calc', 'ans'
  bool isDead = false;
  Token({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.zone = 'drag',
  });
}

class PoofAnim {
  double x, y, p;
  PoofAnim({required this.x, required this.y, this.p = 0.0});
}

// --- STATE MANAGEMENT ---
class LabState extends ChangeNotifier {
  String lang = 'en';
  int scenario = 1;
  int step = 0;

  // View Control
  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  // Sim Logic
  String mode = 'lift';
  double liftFloor = 1;
  double targetFloor = 1;
  int inputMovement = 0;
  bool animating = false;

  List<Token> tokens = [];
  Token? dragToken;
  List<PoofAnim> poofAnims = [];
  int tokenNextId = 1;

  String msgText = '';
  Color msgColor = Colors.transparent;
  double msgOpacity = 0.0;
  bool showSuccessPopup = false;

  void toggleLang() {
    lang = lang == 'en' ? 'hi' : 'en';
    AudioEngine.playClick();
    notifyListeners();
  }

  void loadScenario(int id) {
    scenario = id;
    step = 0;
    animating = false;
    dragToken = null;
    poofAnims.clear();
    msgOpacity = 0;
    zoom = 1.0;
    panX = 0;
    panY = 0;
    showSuccessPopup = false;

    if (id == 1) {
      mode = 'lift';
      liftFloor = 1;
      inputMovement = 0;
    } else if (id == 2) {
      mode = 'lift';
      liftFloor = 4;
      inputMovement = 0;
    } else if (id == 3) {
      mode = 'token';
      tokens.clear();
      tokenNextId = 1;
    } else if (id == 4) {
      mode = 'lift';
      liftFloor = -1;
      inputMovement = 0;
    } else if (id == 5) {
      mode = 'token';
      tokens.clear();
      tokenNextId = 1;
    }

    notifyListeners();
  }

  void showMessage(String msg, Color col) {
    msgText = msg;
    msgColor = col;
    msgOpacity = 1.5;
    notifyListeners();
  }

  void advanceStep() {
    step++;
    notifyListeners();

    int maxSteps = scenario == 1 ? 4 : (scenario == 3 ? 5 : 3);
    if (scenario == 4) maxSteps = 2;

    if (step == maxSteps - 1 && !showSuccessPopup) {
      Future.delayed(const Duration(seconds: 2), () {
        if (step == maxSteps - 1 && !showSuccessPopup) {
          showSuccessPopup = true;
          notifyListeners();

          Future.delayed(const Duration(seconds: 3), () {
            if (showSuccessPopup) {
              loadScenario(scenario < 5 ? scenario + 1 : 1);
            }
          });
        }
      });
    }
  }

  void updateTick(double dt) {
    bool changed = false;

    // Lift Animation
    if (mode == 'lift' && animating) {
      double diff = targetFloor - liftFloor;
      if (diff.abs() < 0.05) {
        liftFloor = targetFloor;
        animating = false;
        AudioEngine.playPageOpen();
        advanceStep();
      } else {
        liftFloor += diff * 0.1; // Ease out interpolation
      }
      changed = true;
    }

    // Poof Animations
    if (poofAnims.isNotEmpty) {
      for (var p in poofAnims) {
        p.p += 0.05;
      }
      poofAnims.removeWhere((p) => p.p >= 1.0);
      changed = true;
    }

    // Message fade
    if (msgOpacity > 0) {
      msgOpacity -= 0.02;
      changed = true;
    }

    if (changed) notifyListeners();
  }
}

// --- MAIN SCREEN ---
class Cl6M_Ch10_A3_AddingIntegersUsingContextualModels extends StatefulWidget {
  const Cl6M_Ch10_A3_AddingIntegersUsingContextualModels({super.key});

  @override
  State<Cl6M_Ch10_A3_AddingIntegersUsingContextualModels> createState() =>
      _Cl6M_Ch10_A3_AddingIntegersUsingContextualModelsState();
}

class _Cl6M_Ch10_A3_AddingIntegersUsingContextualModelsState
    extends State<Cl6M_Ch10_A3_AddingIntegersUsingContextualModels>
    with SingleTickerProviderStateMixin {
  bool hasStarted = false;
  bool isSidebarOpen = true;
  double sidebarWidth = 350;

  late LabState state;
  late Ticker _ticker;
  double _baseZoom = 1.0; // Tracker for smooth zooming

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    state = LabState();
    _ticker = createTicker((elapsed) => state.updateTick(1 / 60))..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    state.dispose();
    super.dispose();
  }

  void _enforceImmersive() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  // Handle immediate pointer hits mapped to world space
  void _onPointerDown(PointerDownEvent event, Size size) {
    if (state.animating && state.mode == 'lift') return;

    double offsetX = state.mode == 'lift' ? 130 : 0;
    double worldX =
        (event.localPosition.dx - (size.width / 2 + state.panX - offsetX)) /
        state.zoom;
    double worldY =
        (event.localPosition.dy - (size.height / 2 + state.panY)) / state.zoom;

    if (state.mode == 'lift') {
      _handleLiftInteraction(worldX, worldY);
    } else {
      _handleTokenInteraction(worldX, worldY);
    }
  }

  void _onPointerMove(PointerMoveEvent event, Size size) {
    if (state.dragToken != null) {
      double offsetX = state.mode == 'lift' ? 130 : 0;
      double worldX =
          (event.localPosition.dx - (size.width / 2 + state.panX - offsetX)) /
          state.zoom;
      double worldY =
          (event.localPosition.dy - (size.height / 2 + state.panY)) /
          state.zoom;
      state.dragToken!.x = worldX;
      state.dragToken!.y = worldY;
      state.notifyListeners();
    }
  }

  void _handleLiftInteraction(double wx, double wy) {
    int maxSteps = state.scenario == 1 ? 4 : (state.scenario == 3 ? 5 : 3);
    if (state.scenario == 4) maxSteps = 2;
    if (state.step >= maxSteps - 1 &&
        (state.scenario != 1 || state.step >= 3)) {
      return; // Success state
    }

    double liftY = 150 - (state.liftFloor * 65);
    double cx = 300, cy = liftY;
    double pX = cx - 60, pY = cy + 30;
    double mX = cx + 60, mY = cy + 30;

    // Hit test '+'
    if (wx > pX - 30 && wx < pX + 30 && wy > pY - 30 && wy < pY + 30) {
      if (state.scenario == 2 || state.scenario == 4) {
        state.showMessage(t('lbl_wrong_way', state.lang), Colors.redAccent);
        AudioEngine.playError();
        return;
      }
      AudioEngine.playClick();
      if (state.scenario == 1) {
        if (state.step == 0 && state.inputMovement == 0) {
          state.inputMovement++;
          state.advanceStep();
        } else if (state.step == 1 && state.inputMovement == 1) {
          state.inputMovement++;
          state.advanceStep();
        }
      }
    }
    // Hit test '-'
    else if (wx > mX - 30 && wx < mX + 30 && wy > mY - 30 && wy < mY + 30) {
      if (state.scenario == 1) {
        state.showMessage(t('lbl_wrong_way', state.lang), Colors.redAccent);
        AudioEngine.playError();
        return;
      }
      AudioEngine.playClick();
      if (state.scenario == 2 && state.step == 0 && state.inputMovement > -3) {
        state.inputMovement--;
        if (state.inputMovement == -3) state.advanceStep();
      }
      if (state.scenario == 4 && state.step == 0 && state.inputMovement > -2) {
        state.inputMovement--;
      }
    }
    // Hit test 'GO'
    else if (wx > cx - 40 && wx < cx + 40 && wy > cy + 85 && wy < cy + 125) {
      bool isReady = false;
      if (state.scenario == 1 && state.step == 2 && state.inputMovement == 2) {
        isReady = true;
      }
      if (state.scenario == 2 && state.step == 1 && state.inputMovement == -3) {
        isReady = true;
      }
      if (state.scenario == 4 && state.step == 0 && state.inputMovement == -2) {
        isReady = true;
      }

      if (isReady) {
        AudioEngine.playClick();
        state.animating = true;
        state.targetFloor = state.liftFloor + state.inputMovement;
      } else {
        AudioEngine.playError();
      }
    }
  }

  void _handleTokenInteraction(double wx, double wy) {
    if (state.scenario == 3 && state.step >= 4) return;

    // Check bins
    if (wx > -180 && wx < -40 && wy > 170 && wy < 320) {
      state.dragToken = Token(id: state.tokenNextId++, type: 1, x: wx, y: wy);
      AudioEngine.playClick();
      return;
    }
    if (wx > 40 && wx < 180 && wy > 170 && wy < 320) {
      state.dragToken = Token(id: state.tokenNextId++, type: -1, x: wx, y: wy);
      AudioEngine.playClick();
      return;
    }

    // Check existing
    for (int i = state.tokens.length - 1; i >= 0; i--) {
      var t = state.tokens[i];
      if (!t.isDead && pow(t.x - wx, 2) + pow(t.y - wy, 2) < 900) {
        // r=30
        state.dragToken = t;
        state.tokens.removeAt(i);
        AudioEngine.playClick();
        return;
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (state.dragToken != null) {
      double wx = state.dragToken!.x, wy = state.dragToken!.y;

      // Calc area bounding box
      if (wx > -200 && wx < 200 && wy > -120 && wy < 140) {
        state.dragToken!.zone = 'calc';
        state.tokens.add(state.dragToken!);
        AudioEngine.playClick();

        // Check cancellation
        for (var t in state.tokens) {
          if (t.id != state.dragToken!.id &&
              !t.isDead &&
              t.zone == 'calc' &&
              t.type != state.dragToken!.type) {
            if (pow(t.x - wx, 2) + pow(t.y - wy, 2) < 1600) {
              // overlap
              t.isDead = true;
              state.dragToken!.isDead = true;
              state.poofAnims.add(PoofAnim(x: wx, y: wy));
              AudioEngine.playPageOpen();
              break;
            }
          }
        }
      }
      // Answer box bounding box (Scen 5)
      else if (state.scenario == 5 &&
          wx > 260 &&
          wx < 440 &&
          wy > -80 &&
          wy < 80) {
        state.dragToken!.zone = 'ans';
        state.tokens.add(state.dragToken!);
        AudioEngine.playClick();
      }

      state.dragToken = null;
      _autoArrangeTokens();
      _checkTokenLogic();
      state.notifyListeners();
    }
  }

  void _autoArrangeTokens() {
    if (state.scenario == 3 && state.step >= 4) return;

    var calcTokens = state.tokens
        .where((t) => !t.isDead && t.zone == 'calc')
        .toList();
    var plusTokens = calcTokens.where((t) => t.type == 1).toList();
    var minusTokens = calcTokens.where((t) => t.type == -1).toList();

    for (int i = 0; i < plusTokens.length; i++) {
      plusTokens[i].x = -140.0 + (i % 2) * 50;
      plusTokens[i].y = -60.0 + (i ~/ 2) * 50;
    }
    for (int i = 0; i < minusTokens.length; i++) {
      minusTokens[i].x = 40.0 + (i % 2) * 50;
      minusTokens[i].y = -60.0 + (i ~/ 2) * 50;
    }

    if (state.scenario == 5) {
      var ansTokens = state.tokens
          .where((t) => !t.isDead && t.zone == 'ans')
          .toList();
      for (int i = 0; i < ansTokens.length; i++) {
        ansTokens[i].x = 290.0 + (i % 2) * 50;
        ansTokens[i].y = -40.0 + (i ~/ 2) * 50;
      }
    }
  }

  void _checkTokenLogic() {
    var calcPlus = state.tokens
        .where((t) => !t.isDead && t.zone == 'calc' && t.type == 1)
        .length;
    var calcMinus = state.tokens
        .where((t) => !t.isDead && t.zone == 'calc' && t.type == -1)
        .length;

    if (state.scenario == 3) {
      if (state.step == 0 && calcPlus == 2) {
        state.advanceStep();
      }
      if (state.step == 1 && calcPlus == 2 && calcMinus == 5) {
        state.advanceStep();
      }

      int zeroPairs = (2 - calcPlus);
      if (state.step == 2 && zeroPairs == 1) {
        state.advanceStep();
      }
      if (state.step == 3 && zeroPairs == 2) {
        state.advanceStep();
      }
    } else if (state.scenario == 5) {
      if (state.step == 0 && calcPlus == 5 && calcMinus == 8) {
        state.advanceStep();
      }

      var ansMinus = state.tokens
          .where((t) => !t.isDead && t.zone == 'ans' && t.type == -1)
          .length;
      if (state.step == 1 && calcPlus == 0 && ansMinus == 3) {
        state.advanceStep();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _enforceImmersive,
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                radius: 1.2,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigoAccent.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calculate,
                        size: 80,
                        color: Colors.indigoAccent,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      t('shutterTitle', state.lang),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t('appSubtitle', state.lang),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white60,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        elevation: 12,
                        shadowColor: Colors.indigoAccent.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: () {
                        AudioEngine.curtainScreen();
                        setState(() => hasStarted = true);
                        state.loadScenario(1);
                      },
                      icon: const Icon(Icons.play_circle_fill, size: 32),
                      label: Text(
                        t('enterLab', state.lang),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _enforceImmersive,
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
              left: isSidebarOpen ? sidebarWidth : 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Listener(
                    onPointerDown: (event) =>
                        _onPointerDown(event, constraints.biggest),
                    onPointerMove: (event) =>
                        _onPointerMove(event, constraints.biggest),
                    onPointerUp: _onPointerUp,
                    child: GestureDetector(
                      // Pan and zoom handler via GestureDetector
                      onScaleStart: (details) {
                        _baseZoom = state.zoom;
                      },
                      onScaleUpdate: (details) {
                        if (state.dragToken == null) {
                          state.panX += details.focalPointDelta.dx;
                          state.panY += details.focalPointDelta.dy;
                          if (details.scale != 1.0) {
                            state.zoom = (_baseZoom * details.scale).clamp(
                              0.4,
                              2.5,
                            );
                          }
                          state.notifyListeners();
                        }
                      },
                      child: AnimatedBuilder(
                        animation: state,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size.infinite,
                            painter: LabPainter(state, constraints.biggest),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: AnimatedBuilder(
                animation: state,
                builder: (context, child) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      border: Border(
                        right: BorderSide(color: Colors.white24, width: 1),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Entire Sidebar as a SingleChildScrollView
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Area
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  64,
                                  16,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.dashboard_customize,
                                          color: Colors.indigoAccent,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            t('appTitle', state.lang),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      t('appSubtitle', state.lang),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 16),
                                    // Language and Reset Buttons moved below subtitle
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(
                                            Icons.language,
                                            size: 18,
                                          ),
                                          label: Text(state.lang.toUpperCase()),
                                          onPressed: () => state.toggleLang(),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.redAccent,
                                          ),
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 18,
                                          ),
                                          label: Text(
                                            t('resetBtn', state.lang),
                                          ),
                                          onPressed: () {
                                            AudioEngine.playClick();
                                            state.loadScenario(state.scenario);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.white12, height: 1),

                              // Content Area
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t('selectScenario', state.lang),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white54,
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
                                          value: state.scenario,
                                          isExpanded: true,
                                          dropdownColor: const Color(
                                            0xFF1E293B,
                                          ),
                                          items: [1, 2, 3, 4, 5]
                                              .map(
                                                (i) => DropdownMenuItem(
                                                  value: i,
                                                  child: Text(
                                                    t(
                                                      's${i}_title',
                                                      state.lang,
                                                    ),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              AudioEngine.playDropdown();
                                              state.loadScenario(val);
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
                                          0xFF334155,
                                        ).withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(12),
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
                                                Icons.flag,
                                                color: Colors.pinkAccent,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                t('learnLbl', state.lang),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.yellowAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            t(
                                              's${state.scenario}_obj',
                                              state.lang,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ..._buildStepsList(),

                                    if (_isScenarioComplete())
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20,
                                          bottom: 20,
                                        ),
                                        child: Center(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.indigoAccent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.arrow_forward,
                                            ),
                                            label: Text(
                                              state.scenario < 5
                                                  ? t(
                                                      'nextScenario',
                                                      state.lang,
                                                    )
                                                  : t('resetBtn', state.lang),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: () {
                                              AudioEngine.playPageOpen();
                                              state.loadScenario(
                                                state.scenario < 5
                                                    ? state.scenario + 1
                                                    : 1,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Footer
                              const Padding(
                                padding: EdgeInsets.fromLTRB(12, 0, 12, 24),
                                child: Text(
                                  "© ZeroScienceLab | Fall in Love with Math and Science",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white38,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Resize Handle
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanUpdate: (details) {
                              setState(() {
                                sidebarWidth += details.delta.dx;
                                sidebarWidth = sidebarWidth.clamp(
                                  300.0,
                                  MediaQuery.of(context).size.width * 0.7,
                                );
                              });
                            },
                            child: Container(
                              width: 8,
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white38,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // MENU TOGGLE (Moved to render above everything else, pinned at Left: 12)
            Positioned(
              top: 12,
              left: 12,
              child: FloatingActionButton(
                mini: true,
                elevation: 8,
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white24, width: 1),
                ),
                child: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu),
                onPressed: () {
                  AudioEngine.playClick();
                  setState(() => isSidebarOpen = !isSidebarOpen);
                },
              ),
            ),

            // HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 10,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: AnimatedBuilder(
                animation: state,
                builder: (context, child) {
                  if (_getHudText().isNotEmpty && !_isScenarioComplete()) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: const Border(
                            top: BorderSide(
                              color: Colors.indigoAccent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.indigoAccent,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getHudText(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // SUCCESS POPUP
            Positioned.fill(
              child: AnimatedBuilder(
                animation: state,
                builder: (context, child) {
                  if (state.showSuccessPopup) {
                    return Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.greenAccent,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.greenAccent,
                                size: 80,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                t('lbl_mission_complete', state.lang),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('s${state.scenario}_summary', state.lang),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isScenarioComplete() {
    return state.showSuccessPopup;
  }

  String _getHudText() {
    int stepNum = state.step + 1;
    return t('s${state.scenario}_hud$stepNum', state.lang);
  }

  List<Widget> _buildStepsList() {
    int maxSteps = state.scenario == 1 ? 4 : (state.scenario == 3 ? 5 : 3);
    if (state.scenario == 4) maxSteps = 2;

    List<Widget> list = [];
    for (int i = 0; i < maxSteps; i++) {
      bool isPast = i < state.step;
      bool isCurrent = i == state.step;

      Color bgColor = isCurrent
          ? Colors.indigo.withOpacity(0.2)
          : (isPast
                ? Colors.green.withOpacity(0.1)
                : Colors.white.withOpacity(0.05));
      Color borderColor = isCurrent
          ? Colors.indigoAccent
          : (isPast ? Colors.greenAccent.withOpacity(0.5) : Colors.transparent);

      list.add(
        Container(
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPast
                      ? Colors.green
                      : (isCurrent ? Colors.indigoAccent : Colors.white24),
                ),
                child: Center(
                  child: isPast
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t('stepLabel', state.lang)} ${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('s${state.scenario}_step${i + 1}_task', state.lang),
                      style: TextStyle(
                        color: isCurrent || isPast
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    if (isPast) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t('s${state.scenario}_step${i + 1}_out', state.lang),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 13,
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
    return list;
  }
}

// --- CANVAS PAINTER ---
class LabPainter extends CustomPainter {
  final LabState state;
  final Size size;
  LabPainter(this.state, this.size) : super(repaint: state);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    canvas.drawRect(
      Offset.zero & canvasSize,
      Paint()..color = const Color(0xFF0F172A),
    ); // bg

    canvas.save();
    double offsetX = state.mode == 'lift' ? 130 : 0;
    canvas.translate(
      canvasSize.width / 2 + state.panX - offsetX,
      canvasSize.height / 2 + state.panY,
    );
    canvas.scale(state.zoom);

    if (state.mode == 'lift') {
      _drawLiftModel(canvas);
    } else {
      _drawTokenModel(canvas);
    }

    canvas.restore();
  }

  void _drawLiftModel(Canvas canvas) {
    // Sky/Bg
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -2000, 2000, 150),
      Paint()..color = const Color(0xFF0F172A),
    ); // Above ground
    canvas.drawRect(
      const Rect.fromLTRB(-2000, 150, 2000, 2000),
      Paint()..color = const Color(0xFF27272A),
    ); // Below ground
    canvas.drawLine(
      const Offset(-2000, 150),
      const Offset(2000, 150),
      Paint()
        ..color = const Color(0xFF18181B)
        ..strokeWidth = 6,
    );

    // Floors
    final floors = [
      {'lvl': 5, 'col': const Color(0xFF3B82F6), 'key': 'f5'},
      {'lvl': 4, 'col': const Color(0xFF10B981), 'key': 'f4'},
      {'lvl': 3, 'col': const Color(0xFF8B5CF6), 'key': 'f3'},
      {'lvl': 2, 'col': const Color(0xFFF59E0B), 'key': 'f2'},
      {'lvl': 1, 'col': const Color(0xFFEF4444), 'key': 'f1'},
      {'lvl': 0, 'col': const Color(0xFF64748B), 'key': 'f0'},
      {'lvl': -1, 'col': const Color(0xFFEC4899), 'key': 'fm1'},
      {'lvl': -2, 'col': const Color(0xFF06B6D4), 'key': 'fm2'},
      {'lvl': -3, 'col': const Color(0xFF14B8A6), 'key': 'fm3'},
      {'lvl': -4, 'col': const Color(0xFF8B5CF6), 'key': 'fm4'},
      {'lvl': -5, 'col': const Color(0xFFF43F5E), 'key': 'fm5'},
    ];

    for (var fl in floors) {
      int level = fl['lvl'] as int;
      Color color = fl['col'] as Color;
      double fy = 150 - (level * 65.0);

      canvas.drawRect(
        Rect.fromLTRB(-400, fy - 10, -80, fy + 10),
        Paint()..color = const Color(0xFF334155),
      );
      canvas.drawRect(
        Rect.fromLTRB(80, fy - 10, 400, fy + 10),
        Paint()..color = const Color(0xFF334155),
      );

      _drawRRect(
        canvas,
        -380,
        fy - 45,
        280,
        35,
        8,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(
        canvas,
        level > 0 ? '+$level' : '$level',
        -240,
        fy - 30,
        color,
        30,
        true,
      );
      _drawText(
        canvas,
        t(fl['key'] as String, state.lang),
        -240,
        fy - 5,
        const Color(0xFF94A3B8),
        12,
        false,
      );

      if (level == 0) {
        _drawRRect(
          canvas,
          150,
          fy - 70,
          50,
          70,
          0,
          const Color(0xFF8B5CF6),
          const Color(0xFF0F172A),
          2,
        );
      }
    }

    // Lift Shaft
    canvas.drawRect(
      const Rect.fromLTRB(-80, -2000, 80, 2000),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawLine(
      const Offset(-80, -2000),
      const Offset(-80, 2000),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 6,
    );
    canvas.drawLine(
      const Offset(80, -2000),
      const Offset(80, 2000),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 6,
    );

    // Lift Car
    double liftY = 150 - (state.liftFloor * 65.0);
    double lh = 55;
    double lw = 140;
    double drawY = liftY - lh / 2;

    _drawRRect(
      canvas,
      -lw / 2,
      drawY,
      lw,
      lh,
      6,
      const Color(0xFFE0E7FF),
      const Color(0xFF0F172A),
      4,
    );
    canvas.drawRect(
      Rect.fromLTRB(-lw / 2 + 5, drawY + 5, 0, drawY + lh - 5),
      Paint()..color = const Color(0xFFC7D2FE),
    );
    canvas.drawRect(
      Rect.fromLTRB(0, drawY + 5, lw / 2 - 5, drawY + lh - 5),
      Paint()..color = const Color(0xFFC7D2FE),
    );
    canvas.drawLine(
      Offset(0, drawY + 5),
      Offset(0, drawY + lh - 5),
      Paint()
        ..color = const Color(0xFF6366F1)
        ..strokeWidth = 3,
    );
    _drawRRect(
      canvas,
      -25,
      drawY + 10,
      50,
      25,
      4,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      2,
    );
    _drawText(
      canvas,
      state.liftFloor.round() > 0
          ? '+${state.liftFloor.round()}'
          : '${state.liftFloor.round()}',
      0,
      drawY + 22.5,
      const Color(0xFFEF4444),
      16,
      true,
    );

    // Control Panel
    double cx = 300;
    double cy = liftY;
    _drawRRect(
      canvas,
      cx - 120,
      cy - 80,
      240,
      160,
      16,
      const Color(0xFF1E293B),
      const Color(0xFF334155),
      5,
    );
    _drawRRect(
      canvas,
      cx - 100,
      cy - 60,
      200,
      40,
      8,
      const Color(0xFF0F172A),
      const Color(0xFF020617),
      2,
    );

    String eqStr = state.scenario == 1
        ? "(+1) + (+${state.inputMovement})"
        : state.scenario == 2
        ? "(+4) + (${state.inputMovement})"
        : "(-1) + (${state.inputMovement})";
    _drawText(canvas, eqStr, cx, cy - 40, const Color(0xFF4ADE80), 18, true);

    _drawRRect(
      canvas,
      cx - 90,
      cy,
      60,
      60,
      30,
      const Color(0xFF3B82F6),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, "+", cx - 60, cy + 30, Colors.white, 36, true);

    _drawRRect(
      canvas,
      cx + 30,
      cy,
      60,
      60,
      30,
      const Color(0xFFEF4444),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, "–", cx + 60, cy + 30, Colors.white, 36, true);

    _drawRRect(
      canvas,
      cx - 40,
      cy + 85,
      80,
      40,
      20,
      const Color(0xFF22C55E),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      t('lbl_go', state.lang),
      cx,
      cy + 105,
      Colors.white,
      16,
      true,
    );

    // Equation / Objective Board
    _drawRRect(
      canvas,
      cx - 120,
      cy - 180,
      240,
      80,
      12,
      const Color(0xFF1E293B),
      const Color(0xFF6366F1),
      4,
    );
    String fullEq = "";
    if (state.scenario == 1) {
      fullEq =
          "(+1) + (+${state.inputMovement}) = ${state.step >= 3 ? '+3' : '?'}";
    }
    if (state.scenario == 2) {
      fullEq =
          "(+4) + (${state.inputMovement}) = ${state.step >= 2 ? '+1' : '?'}";
    }
    if (state.scenario == 4) {
      fullEq =
          "(-1) + (${state.inputMovement}) = ${state.step >= 1 ? '-3' : '?'}";
    }
    _drawText(
      canvas,
      t('lbl_mission', state.lang),
      cx,
      cy - 160,
      const Color(0xFFCBD5E1),
      12,
      true,
    );
    _drawText(canvas, fullEq, cx, cy - 130, const Color(0xFFF8FAFC), 20, true);

    // Floating Messages
    if (state.msgOpacity > 0) {
      Paint p = Paint()
        ..color = state.msgColor.withOpacity(min(1, state.msgOpacity));
      _drawRRect(
        canvas,
        cx - 100,
        cy - 240,
        200,
        40,
        8,
        p.color.withOpacity(0.2),
        p.color,
        2,
      );
      _drawText(canvas, state.msgText, cx, cy - 220, p.color, 14, true);
    }

    // Success Bubble
    bool isSuccess =
        (state.scenario == 1 && state.step >= 3) ||
        (state.scenario == 2 && state.step >= 2) ||
        (state.scenario == 4 && state.step >= 1 && !state.animating);
    if (isSuccess) {
      String msg = t('s${state.scenario}_summary', state.lang);
      _drawBubble(canvas, msg, cx - 120, cy + 150, 280, 90);
    }
  }

  void _drawTokenModel(Canvas canvas) {
    // Desk Bg
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -2000, 2000, 2000),
      Paint()..color = const Color(0xFF2C1E16),
    );

    // Notebook
    _drawRRect(
      canvas,
      250,
      -200,
      200,
      300,
      8,
      const Color(0xFFB45309),
      const Color(0xFFD97706),
      2,
    );
    canvas.drawLine(
      const Offset(270, -200),
      const Offset(270, 100),
      Paint()
        ..color = const Color(0xFFD97706)
        ..strokeWidth = 2,
    );

    bool isMissionComplete = state.scenario == 3 && state.step >= 4;

    if (isMissionComplete) {
      // Big Completion Board
      _drawRRect(
        canvas,
        -180,
        -180,
        360,
        320,
        16,
        const Color(0xFF1E293B),
        const Color(0xFF334155),
        4,
      );
      _drawRRect(
        canvas,
        -160,
        -130,
        320,
        140,
        8,
        const Color(0xFF0F172A),
        Colors.transparent,
        0,
      );
      _drawText(canvas, "(+2) + (-5) = -3", 0, -70, Colors.white, 24, true);

      _drawToken(canvas, -60, -20, 45, -1);
      _drawToken(canvas, 0, -20, 45, -1);
      _drawToken(canvas, 60, -20, 45, -1);

      _drawText(
        canvas,
        t('s3_summary', state.lang),
        0,
        40,
        Colors.white70,
        14,
        true,
      );
    } else {
      // Equation Board
      _drawRRect(
        canvas,
        -180,
        -270,
        360,
        120,
        16,
        const Color(0xFF1E293B),
        const Color(0xFF334155),
        4,
      );
      _drawRRect(
        canvas,
        -160,
        -220,
        320,
        60,
        8,
        const Color(0xFF0F172A),
        Colors.transparent,
        0,
      );
      _drawText(
        canvas,
        t('lbl_mission', state.lang),
        0,
        -250,
        Colors.white70,
        16,
        true,
      );

      String p1 = state.scenario == 5 ? "(+5) + " : "(+2) + ";
      String p2 = state.scenario == 5 ? "(-8)" : "(-5)";
      String p3 = " = ?";
      _drawText(
        canvas,
        "$p1$p2$p3",
        0,
        -190,
        Colors.white,
        24,
        true,
      ); // Simplified rendering for speed

      // Calc Area
      _drawRRect(
        canvas,
        -200,
        -120,
        400,
        260,
        16,
        const Color(0xFF334155),
        const Color(0xFF1E293B),
        4,
      );
      _drawText(
        canvas,
        t('lbl_calc_area', state.lang),
        0,
        115,
        Colors.white70,
        16,
        true,
      );

      // Bins
      _drawRRect(
        canvas,
        -180,
        170,
        140,
        150,
        12,
        const Color(0xFF1E293B),
        const Color(0xFF334155),
        3,
      );
      _drawRRect(
        canvas,
        -170,
        180,
        120,
        80,
        8,
        const Color(0xFF0F172A),
        Colors.transparent,
        0,
      );
      _drawToken(canvas, -110, 220, 50, 1);
      _drawText(
        canvas,
        t('lbl_red_tokens', state.lang),
        -110,
        290,
        Colors.white70,
        12,
        true,
      );

      _drawRRect(
        canvas,
        40,
        170,
        140,
        150,
        12,
        const Color(0xFF1E293B),
        const Color(0xFF334155),
        3,
      );
      _drawRRect(
        canvas,
        50,
        180,
        120,
        80,
        8,
        const Color(0xFF0F172A),
        Colors.transparent,
        0,
      );
      _drawToken(canvas, 110, 220, 50, -1);
      _drawText(
        canvas,
        t('lbl_green_tokens', state.lang),
        110,
        290,
        Colors.white70,
        12,
        true,
      );
    }

    // Answer Box
    if (state.scenario == 5) {
      Color ansCol = state.step >= 2
          ? const Color(0xFF22C55E)
          : const Color(0xFF64748B);
      _drawRRect(
        canvas,
        260,
        -80,
        180,
        160,
        15,
        const Color(0xFF1E293B).withOpacity(0.9),
        ansCol,
        4,
      );
      _drawText(
        canvas,
        t('lbl_ans_box', state.lang),
        350,
        -50,
        ansCol,
        16,
        true,
      );
      if (state.step >= 2) {
        _drawText(canvas, "-3", 350, 0, const Color(0xFF22C55E), 40, true);
      }
    }

    // Tokens
    for (var t in state.tokens) {
      if (!t.isDead) _drawToken(canvas, t.x, t.y, 45, t.type);
    }
    if (state.dragToken != null) {
      _drawToken(
        canvas,
        state.dragToken!.x,
        state.dragToken!.y,
        45,
        state.dragToken!.type,
      );
    }

    // Poofs
    for (var p in state.poofAnims) {
      canvas.save();
      canvas.translate(p.x, p.y);
      Paint paint = Paint()..color = Colors.white.withOpacity(1.0 - p.p);
      canvas.drawCircle(
        Offset(-20 - p.p * 20, -10 - p.p * 10),
        20 + p.p * 10,
        paint,
      );
      canvas.drawCircle(
        Offset(20 + p.p * 20, -15 - p.p * 15),
        25 + p.p * 10,
        paint,
      );
      canvas.drawCircle(Offset(0, 10 + p.p * 20), 15 + p.p * 15, paint);
      _drawText(
        canvas,
        t('lbl_zero_pair', state.lang),
        0,
        10 - p.p * 30,
        const Color(0xFFF43F5E).withOpacity(1.0 - p.p),
        18,
        true,
      );
      canvas.restore();
    }
  }

  // --- HELPER DRAWING METHODS ---
  void _drawRRect(
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
    RRect rrect = RRect.fromLTRBR(x, y, x + w, y + h, Radius.circular(r));
    if (fill != Colors.transparent) {
      canvas.drawRRect(rrect, Paint()..color = fill);
    }
    if (sw > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color color,
    double size,
    bool bold,
  ) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawBubble(
    Canvas canvas,
    String text,
    double x,
    double y,
    double w,
    double h,
  ) {
    _drawRRect(
      canvas,
      x,
      y,
      w,
      h,
      10,
      const Color(0xFF1E293B),
      const Color(0xFF334155),
      3,
    );
    Path p = Path();
    p.moveTo(x + 40, y);
    p.lineTo(x + 50, y - 20);
    p.lineTo(x + 60, y);
    canvas.drawPath(p, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(canvas, text, x + w / 2, y + h / 2, Colors.white, 14, true);
  }

  void _drawToken(Canvas canvas, double x, double y, double size, int type) {
    double r = size / 2;
    canvas.drawCircle(
      Offset(x, y),
      r,
      Paint()
        ..color = type == 1 ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
    );
    canvas.drawCircle(
      Offset(x, y),
      r,
      Paint()
        ..color = type == 1 ? const Color(0xFF991B1B) : const Color(0xFF14532D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(
      canvas,
      type == 1 ? "+" : "–",
      x,
      y,
      Colors.white,
      size * 0.6,
      true,
    );
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
