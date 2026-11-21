// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: non_constant_identifier_names, camel_case_types, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | The Fraction Factory',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Cl6M_Ch7_A6_TheFractionFactory(),
    ),
  );
}

// --- AUDIO ENGINE ---
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  static Future<void> playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
    } catch (_) {}
  }

  static Future<void> playPageOpen() async {
    try {
      await _pagePlayer.stop();
      await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
    } catch (_) {}
  }

  static Future<void> playDropdown() async {
    try {
      await _dropdownPlayer.stop();
      await _dropdownPlayer.play(
        AssetSource('audio/class6/science/dropdown.mp3'),
      );
    } catch (_) {}
  }

  static Future<void> playError() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
    } catch (_) {}
  }

  static Future<void> curtainScreen() async {
    try {
      await _pagePlayer.stop();
      await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
    } catch (_) {}
  }
}

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> t = {
  'en': {
    'shutterTitle': "The Fraction Factory: Combining & Separating",
    'appTitle': "The Fraction Factory",
    'appSubtitle': "Class 6 • Addition & Subtraction",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Objective / Learning:",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You have successfully demonstrated addition and subtraction of fractions using common denominators!",
    'lbl_check': "CHECK",
    'lbl_calibrate': "CALIBRATE",
    'lbl_bake': "BAKE IT!",
    'lbl_calibrator': "Fraction Calibrator",

    's1_title': "1. Pizza Party Addition",
    's1_obj':
        "Combine slices of pizza from two different boxes onto one plate to find the total fraction of a pizza.",
    's1_step1_task':
        "DRAG the 2 slices (2/8) from the left box onto the empty plate.",
    's1_step1_out': "The 2 slices are now on the plate. Plate shows 2/8.",
    's1_step2_task':
        "DRAG the 3 slices (3/8) from the right box onto the same plate.",
    's1_step2_out': "The new slices join the others. Plate shows 5/8.",
    's1_step3_task': "CLICK the 'CHECK' button to confirm.",
    's1_step3_out':
        "Because the slices were the same size, you added them directly. 2/8 + 3/8 = 5/8.",
    's1_hud1': "Drag the 2 pizza slices to the center plate.",
    's1_hud2': "Drag the 3 pizza slices to the center plate.",
    's1_hud3': "Click Check to confirm.",

    's2_title': "2. Chocolate Bar Giveaway",
    's2_obj':
        "Start with a portion of a chocolate bar and give some away to find out how much is left.",
    's2_step1_task':
        "DRAG 4 individual segments from the main 7/10 bar and DROP them into the 'Give Away' box.",
    's2_step1_out': "Four segments removed. Original bar has 3 segments left.",
    's2_step2_task': "CLICK the 'CHECK' button.",
    's2_step2_out':
        "Since all pieces were the same size, you subtracted directly. 7/10 - 4/10 = 3/10.",
    's2_hud1': "Drag 4 chocolate pieces to the box.",
    's2_hud2': "Click Check to finish.",

    's3_title': "3. Potion Mixing Magic",
    's3_obj':
        "Mix a red potion (1/2) and a blue potion (1/3). Use the Calibrator to find a common unit.",
    's3_step1_task': "DRAG the 1/2 Red Beaker to the Mixing Beaker.",
    's3_step1_out': "Cannot mix directly! Units are different.",
    's3_step2_task': "DRAG the 1/2 Red Beaker to the Calibrator pad.",
    's3_step2_out': "Red beaker loaded onto calibrator.",
    's3_step3_task': "DRAG the 1/3 Blue Beaker to the Calibrator pad.",
    's3_step3_out': "Blue beaker loaded. Common denominator found: 6.",
    's3_step4_task': "CLICK the 'CALIBRATE' button on the machine.",
    's3_step4_out': "Beakers converted to 3/6 and 2/6.",
    's3_step5_task':
        "DRAG both calibrated beakers to the Mixing Beaker to pour.",
    's3_step5_out': "Success! 3/6 + 2/6 = 5/6.",
    's3_hud1': "Try to mix the 1/2 red potion.",
    's3_hud2': "Drag the red beaker to the Calibrator.",
    's3_hud3': "Drag the blue beaker to the Calibrator.",
    's3_hud4': "Click CALIBRATE to find common units.",
    's3_hud5': "Pour both beakers into the mixer.",

    's4_title': "4. Juice Jug Challenge",
    's4_obj': "Pour exactly 1/3 L from a 3/4 L jug into a glass.",
    's4_step1_task': "DRAG the 3/4 Jug to the Calibrator.",
    's4_step1_out': "Jug placed on Calibrator.",
    's4_step2_task': "DRAG the 1/3 Glass to the Calibrator.",
    's4_step2_out': "Glass placed. Machine finds common denominator: 12.",
    's4_step3_task': "CLICK 'CALIBRATE' to change markings to 12ths.",
    's4_step3_out': "Jug becomes 9/12. Glass target becomes 4/12.",
    's4_step4_task': "DRAG the Jug to the Glass to pour 4/12.",
    's4_step4_out':
        "Poured exactly 1/3. You subtracted 4/12 from 9/12 to leave 5/12.",
    's4_hud1': "Drag the Jug to the Calibrator.",
    's4_hud2': "Drag the Glass to the Calibrator.",
    's4_hud3': "Click CALIBRATE.",
    's4_hud4': "Drag the Jug to the Glass to pour.",

    's5_title': "5. Master Baker's Recipe",
    's5_obj':
        "Add 2/3 cup milk + 1/4 cup water, then remove 1/6 cup using calibrated units.",
    's5_step1_task':
        "DRAG Milk (2/3) and Water (1/4) to Calibrator, then click CALIBRATE.",
    's5_step1_out': "Units converted to 12ths. (8/12 and 3/12).",
    's5_step2_task': "DRAG Milk and Water to the Bowl to add them.",
    's5_step2_out': "Added to bowl. Total = 11/12.",
    's5_step3_task':
        "DRAG the Ladle (1/6) to the Calibrator, then click CALIBRATE.",
    's5_step3_out': "Ladle converted to 2/12.",
    's5_step4_task': "DRAG the Ladle to the Bowl to remove liquid.",
    's5_step4_out': "Removed 2/12. Bowl now has 9/12 (or 3/4).",
    's5_step5_task': "CLICK 'BAKE IT!' to verify.",
    's5_step5_out': "Delicious cake! 8/12 + 3/12 - 2/12 = 9/12.",
    's5_hud1': "Calibrate Milk and Water.",
    's5_hud2': "Pour Milk and Water into Bowl.",
    's5_hud3': "Calibrate the Ladle.",
    's5_hud4': "Use Ladle to remove liquid from Bowl.",
    's5_hud5': "Click BAKE IT!.",
  },
  'hi': {
    'shutterTitle': "फ्रैक्शन फैक्ट्री: जोड़ना और घटाना",
    'appTitle': "फ्रैक्शन फैक्ट्री",
    'appSubtitle': "कक्षा 6 • भिन्नों का जोड़ और घटाव",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "उद्देश्य / सीख:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc':
        "आपने समान हर का उपयोग करके भिन्नों के जोड़ और घटाव का सफलतापूर्वक प्रदर्शन किया है!",
    'lbl_check': "जाँचें",
    'lbl_calibrate': "कैलिब्रेट",
    'lbl_bake': "बेक करें!",
    'lbl_calibrator': "भिन्न कैलिब्रेटर",

    's1_title': "1. पिज्जा पार्टी जोड़",
    's1_obj':
        "पिज्जा के कुल हिस्से का पता लगाने के लिए दो अलग-अलग बक्सों से पिज्जा के स्लाइस को एक प्लेट पर मिलाएं।",
    's1_step1_task': "बाएं बॉक्स से 2 स्लाइस (2/8) को खाली प्लेट पर खींचें।",
    's1_step1_out': "2 स्लाइस अब प्लेट पर हैं। प्लेट 2/8 दिखाती है।",
    's1_step2_task': "दाएं बॉक्स से 3 स्लाइस (3/8) को उसी प्लेट पर खींचें।",
    's1_step2_out': "नए स्लाइस दूसरों से जुड़ते हैं। प्लेट 5/8 दिखाती है।",
    's1_step3_task': "पुष्टि करने के लिए 'जाँचें' बटन पर क्लिक करें।",
    's1_step3_out':
        "चूंकि स्लाइस समान आकार के थे, इसलिए आपने उन्हें सीधे जोड़ा। 2/8 + 3/8 = 5/8.",
    's1_hud1': "2 पिज्जा स्लाइस को बीच की प्लेट पर खींचें।",
    's1_hud2': "3 पिज्जा स्लाइस को बीच की प्लेट पर खींचें।",
    's1_hud3': "पुष्टि करने के लिए जाँचें पर क्लिक करें।",

    's2_title': "2. चॉकलेट बार गिवअवे",
    's2_obj':
        "चॉकलेट बार के एक हिस्से से शुरू करें और यह पता लगाने के लिए कुछ दे दें कि कितना बचा है।",
    's2_step1_task':
        "मुख्य 7/10 बार से 4 अलग-अलग खंडों को खींचें और उन्हें 'दे दें' बॉक्स में छोड़ दें।",
    's2_step1_out': "चार खंड हटा दिए गए। मूल बार में 3 खंड बचे हैं।",
    's2_step2_task': "'जाँचें' बटन पर क्लिक करें।",
    's2_step2_out':
        "चूंकि सभी टुकड़े समान आकार के थे, इसलिए आपने सीधे घटाया। 7/10 - 4/10 = 3/10.",
    's2_hud1': "4 चॉकलेट के टुकड़ों को बॉक्स में खींचें।",
    's2_hud2': "खत्म करने के लिए जाँचें पर क्लिक करें।",

    's3_title': "3. पोशन मिक्सिंग मैजिक",
    's3_obj':
        "लाल (1/2) और नीले (1/3) पोशन को मिलाएं। समान इकाई खोजने के लिए कैलिब्रेटर का उपयोग करें।",
    's3_step1_task': "1/2 लाल बीकर को मिक्सिंग बीकर में खींचें।",
    's3_step1_out': "सीधे नहीं मिलाया जा सकता! इकाइयाँ अलग हैं।",
    's3_step2_task': "1/2 लाल बीकर को कैलिब्रेटर पर खींचें।",
    's3_step2_out': "लाल बीकर कैलिब्रेटर पर रखा गया।",
    's3_step3_task': "1/3 नीले बीकर को कैलिब्रेटर पर खींचें।",
    's3_step3_out': "नीला बीकर रखा गया। सामान्य हर मिला: 6.",
    's3_step4_task': "मशीन पर 'कैलिब्रेट' बटन पर क्लिक करें।",
    's3_step4_out': "बीकर 3/6 और 2/6 में बदल गए।",
    's3_step5_task':
        "दोनों कैलिब्रेटेड बीकर को मिक्सिंग बीकर में डालने के लिए खींचें।",
    's3_step5_out': "सफलता! 3/6 + 2/6 = 5/6.",
    's3_hud1': "1/2 लाल पोशन को मिलाने का प्रयास करें।",
    's3_hud2': "लाल बीकर को कैलिब्रेटर पर खींचें।",
    's3_hud3': "नीले बीकर को कैलिब्रेटर पर खींचें।",
    's3_hud4': "समान इकाइयाँ खोजने के लिए कैलिब्रेट पर क्लिक करें।",
    's3_hud5': "दोनों बीकर को मिक्सर में डालें।",

    's4_title': "4. जूस जग चुनौती",
    's4_obj': "3/4 लीटर जग से एक गिलास में ठीक 1/3 लीटर डालें।",
    's4_step1_task': "3/4 जग को कैलिब्रेटर पर खींचें।",
    's4_step1_out': "जग कैलिब्रेटर पर रखा गया।",
    's4_step2_task': "1/3 गिलास को कैलिब्रेटर पर खींचें।",
    's4_step2_out': "गिलास रखा गया। मशीन को सामान्य हर मिलता है: 12.",
    's4_step3_task':
        "निशान को 12वें में बदलने के लिए 'कैलिब्रेट' पर क्लिक करें।",
    's4_step3_out': "जग 9/12 हो जाता है। ग्लास का लक्ष्य 4/12 हो जाता है।",
    's4_step4_task': "4/12 डालने के लिए जग को गिलास में खींचें।",
    's4_step4_out': "ठीक 1/3 डाला। आपने 9/12 से 4/12 घटाकर 5/12 छोड़ दिया।",
    's4_hud1': "जग को कैलिब्रेटर पर खींचें।",
    's4_hud2': "गिलास को कैलिब्रेटर पर खींचें।",
    's4_hud3': "कैलिब्रेट पर क्लिक करें।",
    's4_hud4': "डालने के लिए जग को गिलास में खींचें।",

    's5_title': "5. मास्टर बेकर की रेसिपी",
    's5_obj':
        "2/3 कप दूध + 1/4 कप पानी डालें, फिर कैलिब्रेटेड इकाइयों का उपयोग करके 1/6 कप हटा दें।",
    's5_step1_task':
        "दूध (2/3) और पानी (1/4) को कैलिब्रेटर पर खींचें, फिर कैलिब्रेट पर क्लिक करें।",
    's5_step1_out': "इकाइयाँ 12वें भाग में परिवर्तित हो गईं। (8/12 और 3/12)।",
    's5_step2_task': "दूध और पानी को जोड़ने के लिए बाउल में खींचें।",
    's5_step2_out': "बाउल में जोड़ा गया। कुल = 11/12.",
    's5_step3_task':
        "कलछी (1/6) को कैलिब्रेटर पर खींचें, फिर कैलिब्रेट पर क्लिक करें।",
    's5_step3_out': "कलछी 2/12 में परिवर्तित हो गई।",
    's5_step4_task': "तरल निकालने के लिए कलछी को बाउल में खींचें।",
    's5_step4_out': "2/12 निकाला गया। बाउल में अब 9/12 (या 3/4) है।",
    's5_step5_task': "सत्यापित करने के लिए 'बेक करें!' पर क्लिक करें।",
    's5_step5_out': "स्वादिष्ट केक! 8/12 + 3/12 - 2/12 = 9/12.",
    's5_hud1': "दूध और पानी को कैलिब्रेट करें।",
    's5_hud2': "बाउल में दूध और पानी डालें।",
    's5_hud3': "कलछी को कैलिब्रेट करें।",
    's5_hud4': "बाउल से तरल निकालने के लिए कलछी का उपयोग करें।",
    's5_hud5': "बेक करें! पर क्लिक करें।",
  },
};

class GameState extends ChangeNotifier {
  String lang = 'en';
  bool sidebarOpen = true;
  double sidebarWidth = 350.0;
  bool showCurtain = true;
  bool showSuccess = false;

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  int scenario = 1;
  int step = 0;
  int get maxSteps {
    if (scenario == 1) return 3;
    if (scenario == 2) return 2;
    if (scenario == 3) return 5;
    if (scenario == 4) return 4;
    if (scenario == 5) return 5;
    return 0;
  }

  // --- Entities ---
  int s1_plateSlices = 0, s1_box1Slices = 2, s1_box2Slices = 3;
  int s2_main = 7, s2_box = 0;
  bool s3_calibrated = false,
      s3_redOnCal = false,
      s3_blueOnCal = false,
      s3_pouredRed = false,
      s3_pouredBlue = false;
  int s3_mixVol = 0;
  bool s4_jugCalibrated = false, s4_glassCalibrated = false;
  int s4_jugVol = 9, s4_glassVol = 0;
  bool s5_calibratedLiquids = false,
      s5_calibratedLadle = false,
      s5_milkAdded = false,
      s5_waterAdded = false,
      s5_ladleUsed = false,
      s5_milkOnCal = false,
      s5_waterOnCal = false,
      s5_ladleOnCal = false;
  int s5_bowlVol = 0;

  String? activeDragEntity;
  double dragX = 0, dragY = 0, dragStartX = 0, dragStartY = 0;
  bool animating = false;

  void toggleLang() {
    lang = lang == 'en' ? 'hi' : 'en';
    AudioEngine.playClick();
    notifyListeners();
  }

  String tStr(String key) => t[lang]?[key] ?? key;

  void loadScenario(int id) {
    scenario = id;
    step = 0;
    animating = false;
    activeDragEntity = null;
    showSuccess = false;

    if (id == 1) {
      s1_plateSlices = 0;
      s1_box1Slices = 2;
      s1_box2Slices = 3;
    }
    if (id == 2) {
      s2_main = 7;
      s2_box = 0;
    }
    if (id == 3) {
      s3_calibrated = false;
      s3_redOnCal = false;
      s3_blueOnCal = false;
      s3_mixVol = 0;
      s3_pouredRed = false;
      s3_pouredBlue = false;
    }
    if (id == 4) {
      s4_jugCalibrated = false;
      s4_glassCalibrated = false;
      s4_jugVol = 9;
      s4_glassVol = 0;
    }
    if (id == 5) {
      s5_calibratedLiquids = false;
      s5_calibratedLadle = false;
      s5_bowlVol = 0;
      s5_milkAdded = false;
      s5_waterAdded = false;
      s5_ladleUsed = false;
      s5_milkOnCal = false;
      s5_waterOnCal = false;
      s5_ladleOnCal = false;
    }

    panX = 0;
    panY = 0;
    zoom = 1;
    notifyListeners();
  }

  void advanceStep() {
    step++;
    notifyListeners();
  }

  void checkScenarioSuccess() {
    step = maxSteps;
    showSuccess = true;
    AudioEngine.playPageOpen();
    notifyListeners();
  }

  void resetLab() {
    AudioEngine.curtainScreen();
    loadScenario(1);
    showCurtain = true;
    notifyListeners();
  }
}

class Cl6M_Ch7_A6_TheFractionFactory extends StatefulWidget {
  const Cl6M_Ch7_A6_TheFractionFactory({super.key});

  @override
  State<Cl6M_Ch7_A6_TheFractionFactory> createState() =>
      _Cl6M_Ch7_A6_TheFractionFactoryState();
}

class _Cl6M_Ch7_A6_TheFractionFactoryState
    extends State<Cl6M_Ch7_A6_TheFractionFactory>
    with SingleTickerProviderStateMixin {
  final GameState state = GameState();
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _gameLoop;
  double _initialZoom = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _gameLoop.addListener(() => setState(() {}));
    state.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    state.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Offset _getWorldCoord(Offset local, Size size) {
    return Offset(
      (local.dx - size.width / 2 - state.panX) / state.zoom,
      (local.dy - size.height / 2 - state.panY) / state.zoom,
    );
  }

  bool _hitBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  bool _hitCircle(double x, double y, double r, Offset pt) {
    double dx = pt.dx - x, dy = pt.dy - y;
    return dx * dx + dy * dy <= r * r;
  }

  void _triggerAction(String actionType) async {
    if (actionType == 's1_check') {
      if (state.s1_plateSlices == 5) {
        AudioEngine.playClick();
        state.advanceStep();
        Future.delayed(const Duration(seconds: 1), state.checkScenarioSuccess);
      } else {
        AudioEngine.playError();
      }
    } else if (actionType == 's2_check') {
      if (state.s2_box == 4) {
        AudioEngine.playClick();
        state.advanceStep();
        Future.delayed(const Duration(seconds: 1), state.checkScenarioSuccess);
      } else {
        AudioEngine.playError();
      }
    } else if (actionType == 's3_calibrate') {
      AudioEngine.playClick();
      state.s3_calibrated = true;
      state.s3_redOnCal = false;
      state.s3_blueOnCal = false;
      state.advanceStep();
    } else if (actionType == 's4_calibrate') {
      AudioEngine.playClick();
      state.s4_jugCalibrated = true;
      state.s4_glassCalibrated = true;
      state.advanceStep();
    } else if (actionType == 's4_pour') {
      if (state.s4_jugVol >= 4 && state.s4_glassVol == 0) {
        AudioEngine.playClick();
        state.animating = true;
        for (int i = 0; i < 4; i++) {
          await Future.delayed(const Duration(milliseconds: 300));
          state.s4_jugVol--;
          state.s4_glassVol++;
          state.notifyListeners();
        }
        state.animating = false;
        state.advanceStep();
        Future.delayed(
          const Duration(milliseconds: 500),
          state.checkScenarioSuccess,
        );
      } else {
        AudioEngine.playError();
      }
    } else if (actionType == 's5_calLiquids') {
      AudioEngine.playClick();
      state.s5_calibratedLiquids = true;
      state.advanceStep();
    } else if (actionType == 's5_calLadle') {
      AudioEngine.playClick();
      state.s5_calibratedLadle = true;
      state.advanceStep();
    } else if (actionType == 's5_bake') {
      if (state.s5_bowlVol == 9) {
        AudioEngine.playClick();
        state.advanceStep();
        Future.delayed(const Duration(seconds: 1), state.checkScenarioSuccess);
      } else {
        AudioEngine.playError();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (state.animating) return;
    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    Offset local = box.globalToLocal(details.globalPosition);
    Offset pt = _getWorldCoord(local, box.size);

    if (state.scenario == 1) {
      if (state.step == 2 && _hitBox(-70, 180, 140, 50, pt)) {
        _triggerAction('s1_check');
      }
    } else if (state.scenario == 2) {
      if (state.step == 1 && _hitBox(-70, 120, 140, 50, pt)) {
        _triggerAction('s2_check');
      }
    } else if (state.scenario == 3) {
      if (state.step == 3 && _hitBox(-70, -120, 140, 40, pt)) {
        _triggerAction('s3_calibrate');
      }
    } else if (state.scenario == 4) {
      if (state.step == 2 && _hitBox(-70, -120, 140, 40, pt)) {
        _triggerAction('s4_calibrate');
      }
    } else if (state.scenario == 5) {
      if (state.step == 0 && _hitBox(-260, -140, 120, 30, pt)) {
        _triggerAction('s5_calLiquids');
      }
      if (state.step == 2 && _hitBox(-260, -140, 120, 30, pt)) {
        _triggerAction('s5_calLadle');
      }
      if (state.step == 4 && _hitBox(80, 220, 140, 50, pt)) {
        _triggerAction('s5_bake');
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (state.animating) return;
    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    Offset local = box.globalToLocal(details.focalPoint);
    Offset pt = _getWorldCoord(local, box.size);
    _initialZoom = state.zoom;

    bool hitEntity = false;

    if (!state.animating) {
      if (state.scenario == 1) {
        if (state.step == 0 &&
            state.s1_box1Slices > 0 &&
            _hitBox(-300, -80, 160, 160, pt)) {
          state.activeDragEntity = 's1_b1';
          hitEntity = true;
        }
        if (state.step == 1 &&
            state.s1_box2Slices > 0 &&
            _hitBox(140, -80, 160, 160, pt)) {
          state.activeDragEntity = 's1_b2';
          hitEntity = true;
        }
      } else if (state.scenario == 2) {
        if (state.step == 0 &&
            state.s2_main > 3 &&
            _hitBox(-250, -100, 200, 80, pt)) {
          state.activeDragEntity = 's2_piece';
          hitEntity = true;
        }
      } else if (state.scenario == 3) {
        double redX = state.s3_redOnCal ? -170 : -350;
        double redY = state.s3_redOnCal ? -180 : 70;
        double blueX = state.s3_blueOnCal ? 90 : -200;
        double blueY = state.s3_blueOnCal ? -180 : 70;
        if (!state.s3_pouredRed && _hitBox(redX, redY, 80, 140, pt)) {
          state.activeDragEntity = 's3_red';
          hitEntity = true;
        }
        if (!state.s3_pouredBlue && _hitBox(blueX, blueY, 80, 140, pt)) {
          state.activeDragEntity = 's3_blue';
          hitEntity = true;
        }
      } else if (state.scenario == 4) {
        double jX = -300, jY = 50, gX = 150, gY = 80;
        if (state.step < 3 || state.step == 3) {
          if (_hitBox(jX, jY, 140, 180, pt)) {
            state.activeDragEntity = 's4_jug';
            hitEntity = true;
          }
          if (state.step < 3 && _hitBox(gX, gY, 80, 150, pt)) {
            state.activeDragEntity = 's4_glass';
            hitEntity = true;
          }
        }
      } else if (state.scenario == 5) {
        double mX = state.s5_milkOnCal ? -260 : -300;
        double mY = state.s5_milkOnCal ? -200 : 80;
        double wX = state.s5_waterOnCal ? -140 : -180;
        double wY = state.s5_waterOnCal ? -200 : 80;
        double lX = state.s5_ladleOnCal ? -200 : -50;
        double lY = state.s5_ladleOnCal ? -150 : 100;
        if (!state.s5_milkAdded && _hitBox(mX, mY, 60, 100, pt)) {
          state.activeDragEntity = 's5_milk';
          hitEntity = true;
        }
        if (!state.s5_waterAdded && _hitBox(wX, wY, 60, 100, pt)) {
          state.activeDragEntity = 's5_water';
          hitEntity = true;
        }
        if (!state.s5_ladleUsed && _hitBox(lX - 30, lY - 80, 110, 100, pt)) {
          state.activeDragEntity = 's5_ladle';
          hitEntity = true;
        }
      }
    }

    if (hitEntity) {
      AudioEngine.playClick();
      state.dragX = pt.dx;
      state.dragY = pt.dy;
      state.dragStartX = pt.dx;
      state.dragStartY = pt.dy;
    } else {
      // Begin panning
      state.dragStartX = local.dx - state.panX;
      state.dragStartY = local.dy - state.panY;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (state.activeDragEntity != null) {
      RenderBox? box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      Offset pt = _getWorldCoord(
        box.globalToLocal(details.focalPoint),
        box.size,
      );
      state.dragX = pt.dx;
      state.dragY = pt.dy;
    } else {
      // Smooth Pan and Zoom
      RenderBox? box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      Offset local = box.globalToLocal(details.focalPoint);

      state.panX = local.dx - state.dragStartX;
      state.panY = local.dy - state.dragStartY;

      // Smooth zoom adjustment
      if (details.scale != 1.0) {
        state.zoom = (_initialZoom * details.scale).clamp(0.4, 3.5);
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (state.activeDragEntity != null) {
      String id = state.activeDragEntity!;
      Offset pt = Offset(state.dragX, state.dragY);
      bool dropped = false;

      if (id == 's1_b1') {
        if (_hitCircle(0, 0, 110, pt)) {
          state.s1_plateSlices += 2;
          state.s1_box1Slices = 0;
          state.advanceStep();
          dropped = true;
        }
      } else if (id == 's1_b2') {
        if (_hitCircle(0, 0, 110, pt)) {
          state.s1_plateSlices += 3;
          state.s1_box2Slices = 0;
          state.advanceStep();
          dropped = true;
        }
      } else if (id == 's2_piece') {
        if (_hitBox(80, -100, 140, 120, pt)) {
          state.s2_main--;
          state.s2_box++;
          if (state.s2_box == 4) state.advanceStep();
          dropped = true;
        }
      } else if (id == 's3_red' || id == 's3_blue') {
        if (_hitBox(180, 50, 140, 160, pt)) {
          if (state.s3_calibrated) {
            if (id == 's3_red') {
              state.s3_pouredRed = true;
              state.s3_mixVol += 3;
            }
            if (id == 's3_blue') {
              state.s3_pouredBlue = true;
              state.s3_mixVol += 2;
            }
            if (state.s3_mixVol == 5) {
              state.advanceStep();
              Future.delayed(
                const Duration(seconds: 1),
                state.checkScenarioSuccess,
              );
            }
            dropped = true;
          } else {
            if (state.step == 0 && id == 's3_red') state.advanceStep();
            dropped = true;
          }
        } else if (_hitBox(-200, -250, 400, 200, pt)) {
          if (id == 's3_red' && state.step == 1) {
            state.s3_redOnCal = true;
            state.advanceStep();
            dropped = true;
          } else if (id == 's3_blue' && state.step == 2) {
            state.s3_blueOnCal = true;
            state.advanceStep();
            dropped = true;
          }
        }
      } else if (id == 's4_jug' || id == 's4_glass') {
        if (state.step < 3 && _hitBox(-200, -250, 400, 200, pt)) {
          if (id == 's4_jug' && state.step == 0) {
            state.s4_jugCalibrated = true;
            state.advanceStep();
            dropped = true;
          } else if (id == 's4_glass' && state.step == 1) {
            state.s4_glassCalibrated = true;
            state.advanceStep();
            dropped = true;
          }
        } else if (id == 's4_jug' &&
            state.step == 3 &&
            _hitBox(50, 0, 280, 300, pt)) {
          _triggerAction('s4_pour');
          dropped = true;
        }
      } else if (id == 's5_milk' || id == 's5_water' || id == 's5_ladle') {
        if (id == 's5_milk' || id == 's5_water') {
          if (_hitBox(-350, -250, 300, 150, pt) && state.step == 0) {
            if (id == 's5_milk') state.s5_milkOnCal = true;
            if (id == 's5_water') state.s5_waterOnCal = true;
            dropped = true;
          } else if (_hitBox(50, 50, 200, 120, pt) && state.step == 1) {
            if (id == 's5_milk') {
              state.s5_milkAdded = true;
              state.s5_bowlVol += 8;
            }
            if (id == 's5_water') {
              state.s5_waterAdded = true;
              state.s5_bowlVol += 3;
            }
            if (state.s5_milkAdded && state.s5_waterAdded) state.advanceStep();
            dropped = true;
          }
        } else if (id == 's5_ladle') {
          if (_hitBox(-350, -250, 300, 150, pt) && state.step == 2) {
            state.s5_ladleOnCal = true;
            dropped = true;
          } else if (_hitBox(50, 50, 200, 120, pt) &&
              state.step == 3 &&
              state.s5_calibratedLadle) {
            state.s5_bowlVol -= 2;
            state.s5_ladleUsed = true;
            state.advanceStep();
            dropped = true;
          }
        }
      }

      if (dropped) {
        AudioEngine.playClick();
      } else {
        AudioEngine.playError();
      }

      state.activeDragEntity = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: state.sidebarOpen ? state.sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTapUp: _onTapUp,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: ClipRect(
                    child: CustomPaint(
                      key: _canvasKey,
                      painter: FractionPainter(state: state),
                      child: Container(),
                    ),
                  ),
                ),
              ),
            ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: state.sidebarOpen ? 0 : -state.sidebarWidth,
              top: 0,
              bottom: 0,
              width: state.sidebarWidth,
              child: _buildSidebar(),
            ),

            // Toggle Sidebar Menu Button
            Positioned(
              left: 16,
              top: 16,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B).withOpacity(0.9),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    AudioEngine.playClick();
                    state.sidebarOpen = !state.sidebarOpen;
                    setState(() {});
                  },
                  child: Icon(state.sidebarOpen ? Icons.menu_open : Icons.menu),
                ),
              ),
            ),

            // HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: state.sidebarOpen ? state.sidebarWidth : 0,
              right: 0,
              bottom: 40,
              child: Center(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: state.step < state.maxSteps ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(
                          top: BorderSide(color: Color(0xFF6366F1), width: 4),
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
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF6366F1),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              state.tStr(
                                's${state.scenario}_hud${state.step + 1}',
                              ),
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
                  ),
                ),
              ),
            ),

            if (state.showSuccess) _buildSuccessPopup(),
            if (state.showCurtain) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dynamic Header
                        Container(
                          padding: const EdgeInsets.only(
                            top: 80,
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0F172A),
                            border: Border(
                              bottom: BorderSide(color: Colors.white12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.pie_chart,
                                    color: Color(0xFF6366F1),
                                    size: 26,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      state.tStr('appTitle'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.tStr('appSubtitle'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.language, size: 18),
                                    label: Text(
                                      state.lang.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: state.toggleLang,
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B),
                                      padding: const EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    onPressed: state.resetLab,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Scrollable Content Wrapped in Expanded
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.tStr('selectScenario').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
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
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: state.scenario,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF0F172A),
                                      items: [1, 2, 3, 4, 5]
                                          .map(
                                            (id) => DropdownMenuItem(
                                              value: id,
                                              child: Text(
                                                state.tStr('s${id}_title'),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          AudioEngine.playDropdown();
                                          state.loadScenario(v);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white12),
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
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            state.tStr('learnLbl'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        state.tStr('s${state.scenario}_obj'),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ...List.generate(
                                  state.maxSteps,
                                  (i) => _buildStepItem(i),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Footer (Will stick to bottom if content is short)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          width: double.infinity,
                          color: const Color(0xFF0F172A),
                          child: const Text(
                            '© ZeroScienceLab | Fall in Love with Math and Science',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
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

          // Resizer Handle
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 10,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    state.sidebarWidth += details.delta.dx;
                    state.sidebarWidth = state.sidebarWidth.clamp(
                      300.0,
                      MediaQuery.of(context).size.width * 0.5,
                    );
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      right: BorderSide(color: Colors.white24, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int i) {
    bool isCompleted = i < state.step;
    bool isActive = i == state.step;
    bool isFuture = i > state.step;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF6366F1).withOpacity(0.1)
            : (isCompleted
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFF0F172A)),
        border: Border.all(
          color: isActive
              ? const Color(0xFF6366F1)
              : (isCompleted ? const Color(0xFF10B981) : Colors.white12),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isCompleted
              ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
              : Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF6366F1) : Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.tStr('stepLabel')} ${i + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Action: ${state.tStr('s${state.scenario}_step${i + 1}_task')}",
                  style: TextStyle(
                    color: isFuture ? Colors.white54 : const Color(0xFF818CF8),
                    fontSize: 14,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.tStr('s${state.scenario}_step${i + 1}_out'),
                      style: const TextStyle(
                        color: Color(0xFF34D399),
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
    );
  }

  Widget _buildCurtain() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pie_chart, size: 80, color: Color(0xFF6366F1)),
              const SizedBox(height: 24),
              Text(
                state.tStr('shutterTitle'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.tStr('appSubtitle'),
                style: const TextStyle(fontSize: 18, color: Colors.white54),
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
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  AudioEngine.playPageOpen();
                  setState(() => state.showCurtain = false);
                  state.loadScenario(1);
                },
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  state.tStr('enterLab'),
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

  Widget _buildSuccessPopup() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: SingleChildScrollView(
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF10B981),
                    child: Icon(Icons.flag, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    state.tStr('summaryTitle'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.tStr('finalDesc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.scenario < 5
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      AudioEngine.playClick();
                      if (state.scenario < 5) {
                        state.loadScenario(state.scenario + 1);
                      } else {
                        state.resetLab();
                      }
                    },
                    child: Text(
                      state.scenario < 5
                          ? state.tStr('nextScenario')
                          : state.tStr('finishLab'),
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
      ),
    );
  }
}

class FractionPainter extends CustomPainter {
  final GameState state;
  final Color outline = const Color(0xFF94A3B8);

  FractionPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 1) {
      _renderS1(canvas);
    } else if (state.scenario == 2) {
      _renderS2(canvas);
    } else if (state.scenario == 3) {
      _renderS3(canvas);
    } else if (state.scenario == 4) {
      _renderS4(canvas);
    } else if (state.scenario == 5) {
      _renderS5(canvas);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    bool bold = true,
  }) {
    final tp = TextPainter(
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
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawPizzaGroup(
    Canvas canvas,
    double x,
    double y,
    double r,
    int startSlice,
    int numSlices,
    int totalSlices,
  ) {
    canvas.save();
    canvas.translate(x, y);
    double sliceAngle = (2 * pi) / totalSlices;
    double startAngle = startSlice * sliceAngle - pi / 2;

    Paint crust = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;
    Paint cheese = Paint()
      ..color = const Color(0xFFFDE047)
      ..style = PaintingStyle.fill;
    Paint stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r),
      startAngle,
      numSlices * sliceAngle,
      true,
      crust,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r),
      startAngle,
      numSlices * sliceAngle,
      true,
      stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 0.85),
      startAngle,
      numSlices * sliceAngle,
      true,
      cheese,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 0.85),
      startAngle,
      numSlices * sliceAngle,
      true,
      stroke,
    );

    for (int i = 1; i < numSlices; i++) {
      double a = startAngle + i * sliceAngle;
      canvas.drawLine(Offset.zero, Offset(cos(a) * r, sin(a) * r), stroke);
    }
    canvas.restore();
  }

  void _drawPizzaBox(Canvas canvas, double x, double y, double w, double h) {
    Paint fill = Paint()..color = const Color(0xFFFEF08A);
    Paint stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    Rect rect = Rect.fromLTWH(x, y, w, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      stroke,
    );

    Rect flap = Rect.fromLTWH(x + 10, y - h + 10, w - 20, h - 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(flap, const Radius.circular(8)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(flap, const Radius.circular(8)),
      stroke..strokeWidth = 2,
    );
    _drawText(canvas, "PIZZA", x + w / 2, y - h / 2 + 10, 24, Colors.redAccent);
  }

  void _renderS1(Canvas canvas) {
    _drawText(canvas, "Plate", 0, 140, 24, Colors.white);
    _drawPizzaBox(canvas, -300, -80, 160, 160);
    _drawPizzaBox(canvas, 140, -80, 160, 160);

    canvas.drawCircle(Offset.zero, 110, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset.zero,
      110,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    if (state.s1_box1Slices > 0 && state.activeDragEntity != 's1_b1') {
      _drawPizzaGroup(canvas, -220, 0, 60, 0, state.s1_box1Slices, 8);
    }
    if (state.s1_box2Slices > 0 && state.activeDragEntity != 's1_b2') {
      _drawPizzaGroup(canvas, 220, 0, 60, 2, state.s1_box2Slices, 8);
    }
    if (state.s1_plateSlices > 0) {
      _drawPizzaGroup(canvas, 0, 0, 90, 0, state.s1_plateSlices, 8);
    }

    if (state.activeDragEntity == 's1_b1') {
      _drawPizzaGroup(canvas, state.dragX, state.dragY, 60, 0, 2, 8);
    }
    if (state.activeDragEntity == 's1_b2') {
      _drawPizzaGroup(canvas, state.dragX, state.dragY, 60, 2, 3, 8);
    }

    _drawText(canvas, "2/8", -220, 110, 20, Colors.white);
    _drawText(canvas, "3/8", 220, 110, 20, Colors.white);
    _drawText(
      canvas,
      "${state.s1_plateSlices}/8",
      0,
      -140,
      32,
      Colors.greenAccent,
    );

    if (state.step == 2) {
      _drawButton(
        canvas,
        -70,
        180,
        140,
        50,
        state.tStr('lbl_check'),
        Colors.green,
      );
    }
  }

  void _renderS2(Canvas canvas) {
    _drawText(canvas, "Main Bar (7/10)", -150, -140, 20, Colors.white);
    _drawText(canvas, "Give Away Box", 150, -140, 20, Colors.white);

    // Main Bar
    double x = -250, y = -100, w = 200, h = 80;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF5C4033),
    );
    double sw = w / 5, sh = h / 2;
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 5; j++) {
        if (i * 5 + j < state.s2_main) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x + j * sw + 2, y + i * sh + 2, sw - 4, sh - 4),
              const Radius.circular(2),
            ),
            Paint()..color = const Color(0xFF8B5A2B),
          );
        }
      }
    }

    // Box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(80, -100, 140, 120),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFFEF08A),
    );
    for (int i = 0; i < state.s2_box; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(90 + (i % 2) * 50, -80 + (i ~/ 2) * 50, 40, 40),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF8B5A2B),
      );
    }

    if (state.activeDragEntity == 's2_piece') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(state.dragX - 20, state.dragY - 20, 40, 40),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF8B5A2B),
      );
    }

    _drawText(canvas, "${state.s2_main}/10 Left", -150, 20, 24, Colors.blue);
    _drawText(canvas, "${state.s2_box}/10 Removed", 150, 40, 20, Colors.red);

    if (state.step == 1) {
      _drawButton(
        canvas,
        -70,
        120,
        140,
        50,
        state.tStr('lbl_check'),
        Colors.green,
      );
    }
  }

  void _drawBeaker(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Color lColor,
    double ratio,
    int marks,
  ) {
    double lH = h * ratio;
    if (ratio > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 5, y + h - lH, w - 10, lH),
          const Radius.circular(5),
        ),
        Paint()..color = lColor,
      );
    }

    Path glass = Path()
      ..moveTo(x, y)
      ..lineTo(x + 5, y + h - 5)
      ..quadraticBezierTo(x + 5, y + h, x + w / 2, y + h)
      ..quadraticBezierTo(x + w - 5, y + h, x + w - 5, y + h - 5)
      ..lineTo(x + w, y);
    canvas.drawPath(
      glass,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      glass,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 5, y, w + 10, 10),
        const Radius.circular(5),
      ),
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    for (int i = 1; i < marks; i++) {
      double my = y + h - (i / marks) * h;
      canvas.drawLine(
        Offset(x + 10, my),
        Offset(x + w / 2, my),
        Paint()
          ..color = outline
          ..strokeWidth = 2,
      );
    }
  }

  void _drawCalibrator(Canvas canvas, double x, double y, double w, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 10, y + 10, w - 20, h * 0.4),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 20, y + h - 30, 80, 20),
        const Radius.circular(10),
      ),
      Paint()..color = outline,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + w - 100, y + h - 30, 80, 20),
        const Radius.circular(10),
      ),
      Paint()..color = outline,
    );
    _drawText(
      canvas,
      state.tStr('lbl_calibrator'),
      x + w / 2,
      y + h - 60,
      16,
      outline,
    );
  }

  void _renderS3(Canvas canvas) {
    _drawCalibrator(canvas, -200, -250, 400, 200);
    String scrTxt = state.s3_calibrated
        ? "Calibrated to 6ths"
        : (state.s3_redOnCal && state.s3_blueOnCal
              ? "Found Denom: 6"
              : "Insert Beakers");
    _drawText(canvas, scrTxt, 0, -170, 20, Colors.greenAccent);

    if (state.s3_redOnCal && state.s3_blueOnCal && !state.s3_calibrated) {
      _drawButton(
        canvas,
        -70,
        -120,
        140,
        40,
        state.tStr('lbl_calibrate'),
        Colors.amber,
        textColor: Colors.black,
      );
    }

    _drawText(canvas, "Mixing Beaker", 250, 30, 18, Colors.white);
    _drawBeaker(
      canvas,
      180,
      50,
      140,
      160,
      Colors.purple,
      state.s3_mixVol / 6,
      6,
    );

    double rx = state.s3_redOnCal ? -170 : (state.s3_pouredRed ? -1000 : -350);
    double ry = state.s3_redOnCal ? -180 : 70;
    double bx = state.s3_blueOnCal ? 90 : (state.s3_pouredBlue ? -1000 : -200);
    double by = state.s3_blueOnCal ? -180 : 70;

    if (state.activeDragEntity == 's3_red') {
      rx = state.dragX - 40;
      ry = state.dragY - 70;
    }
    if (state.activeDragEntity == 's3_blue') {
      bx = state.dragX - 40;
      by = state.dragY - 70;
    }

    if (!state.s3_pouredRed) {
      _drawBeaker(
        canvas,
        rx,
        ry,
        80,
        140,
        Colors.red,
        state.s3_calibrated ? 3 / 6 : 1 / 2,
        state.s3_calibrated ? 6 : 2,
      );
    }
    if (!state.s3_pouredBlue) {
      _drawBeaker(
        canvas,
        bx,
        by,
        80,
        140,
        Colors.blue,
        state.s3_calibrated ? 2 / 6 : 1 / 3,
        state.s3_calibrated ? 6 : 3,
      );
    }
  }

  void _drawJugGlass(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double ratio,
    int marks,
    bool hasHandle,
  ) {
    double lH = h * ratio;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y + h - lH, w, lH),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFFDE047),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.white.withOpacity(0.1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(5),
      ),
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    if (hasHandle) {
      Path p = Path()
        ..moveTo(x + w, y + 20)
        ..quadraticBezierTo(x + w + 40, y + 20, x + w + 40, y + h / 2)
        ..quadraticBezierTo(x + w + 40, y + h - 20, x + w, y + h - 20);
      canvas.drawPath(
        p,
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    }
    for (int i = 1; i < marks; i++) {
      canvas.drawLine(
        Offset(x, y + h - (i / marks) * h),
        Offset(x + w / 3, y + h - (i / marks) * h),
        Paint()
          ..color = outline
          ..strokeWidth = 2,
      );
    }
  }

  void _renderS4(Canvas canvas) {
    _drawCalibrator(canvas, -200, -250, 400, 200);
    String scrTxt = state.s4_jugCalibrated && state.s4_glassCalibrated
        ? "Calibrated to 12ths"
        : "Place Jug & Glass";
    _drawText(canvas, scrTxt, 0, -170, 20, Colors.greenAccent);

    double jX = -300, jY = 50, gX = 150, gY = 80;
    if (state.activeDragEntity == 's4_jug') {
      jX = state.dragX - 70;
      jY = state.dragY - 90;
    }
    if (state.activeDragEntity == 's4_glass') {
      gX = state.dragX - 40;
      gY = state.dragY - 60;
    }

    if (state.s4_jugCalibrated && state.s4_glassCalibrated && state.step == 2) {
      _drawButton(
        canvas,
        -70,
        -120,
        140,
        40,
        state.tStr('lbl_calibrate'),
        Colors.amber,
        textColor: Colors.black,
      );
    }

    _drawJugGlass(
      canvas,
      jX,
      jY,
      140,
      180,
      state.s4_jugVol / 12,
      state.s4_jugCalibrated ? 12 : 4,
      true,
    );
    _drawText(
      canvas,
      state.s4_jugCalibrated && state.step > 2
          ? "${state.s4_jugVol}/12 L"
          : "3/4 L",
      jX + 70,
      jY - 20,
      20,
      Colors.white,
    );

    _drawJugGlass(
      canvas,
      gX,
      gY,
      80,
      150,
      state.s4_glassVol / 12,
      state.s4_glassCalibrated ? 12 : 3,
      false,
    );
    _drawText(
      canvas,
      state.s4_glassCalibrated && state.step > 2
          ? "${state.s4_glassVol}/12 Target"
          : "Target: 1/3 L",
      gX + 40,
      gY - 20,
      16,
      Colors.white,
    );
  }

  void _renderS5(Canvas canvas) {
    _drawCalibrator(canvas, -350, -250, 300, 150);
    String scrTxt = state.s5_calibratedLiquids
        ? "Liquids Calibrated"
        : (state.s5_calibratedLadle ? "Ladle Calibrated" : "Insert Items");
    _drawText(canvas, scrTxt, -200, -190, 16, Colors.greenAccent);

    if (state.step == 0 || state.step == 2) {
      _drawButton(
        canvas,
        -260,
        -140,
        120,
        30,
        state.tStr('lbl_calibrate'),
        Colors.amber,
        textColor: Colors.black,
        fontSize: 14,
      );
    }

    _drawText(canvas, "Mixing Bowl", 150, 20, 20, Colors.white);

    // Bowl
    canvas.save();
    canvas.translate(50, 50);
    double bw = 200, bh = 120, lH = bh * (state.s5_bowlVol / 12);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bw / 2, 0), width: bw, height: 30),
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    if (lH > 0) {
      Color c = state.s5_bowlVol > 8 ? const Color(0xFFFCD34D) : Colors.white;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(bw / 2, bh - lH),
          width: bw - (bh - lH) * 0.4,
          height: 20,
        ),
        Paint()..color = c,
      );
      Path liq = Path()
        ..moveTo((bh - lH) * 0.2, bh - lH)
        ..lineTo(bw * 0.1, bh)
        ..quadraticBezierTo(bw / 2, bh + 15, bw * 0.9, bh)
        ..lineTo(bw - (bh - lH) * 0.2, bh - lH);
      canvas.drawPath(liq, Paint()..color = c);
    }
    Path front = Path()
      ..moveTo(0, 0)
      ..lineTo(bw * 0.1, bh)
      ..quadraticBezierTo(bw / 2, bh + 15, bw * 0.9, bh)
      ..lineTo(bw, 0);
    canvas.drawPath(front, Paint()..color = Colors.white.withOpacity(0.8));
    canvas.drawPath(
      front,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.restore();

    _drawText(
      canvas,
      state.s5_calibratedLiquids ? "${state.s5_bowlVol}/12" : "Empty",
      150,
      190,
      18,
      Colors.white,
    );

    double mX = state.s5_milkOnCal ? -260 : -300,
        mY = state.s5_milkOnCal ? -200 : 80;
    double wX = state.s5_waterOnCal ? -140 : -180,
        wY = state.s5_waterOnCal ? -200 : 80;
    double lX = state.s5_ladleOnCal ? -200 : -50,
        lY = state.s5_ladleOnCal ? -150 : 100;

    if (state.activeDragEntity == 's5_milk') {
      mX = state.dragX - 30;
      mY = state.dragY - 50;
    }
    if (state.activeDragEntity == 's5_water') {
      wX = state.dragX - 30;
      wY = state.dragY - 50;
    }
    if (state.activeDragEntity == 's5_ladle') {
      lX = state.dragX;
      lY = state.dragY;
    }

    if (!state.s5_milkAdded) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(mX, mY, 60, 100),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.white,
      );
      _drawText(
        canvas,
        state.s5_calibratedLiquids ? "8/12" : "2/3",
        mX + 30,
        mY - 15,
        16,
        Colors.white,
      );
    }
    if (!state.s5_waterAdded) {
      _drawBeaker(canvas, wX, wY, 60, 100, Colors.blue, 1, 1);
      _drawText(
        canvas,
        state.s5_calibratedLiquids ? "3/12" : "1/4",
        wX + 30,
        wY - 15,
        16,
        Colors.white,
      );
    }
    if (!state.s5_ladleUsed) {
      canvas.save();
      canvas.translate(lX, lY);
      canvas.rotate(-pi / 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, -5, 100, 10),
          const Radius.circular(5),
        ),
        Paint()..color = outline,
      );
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(-15, 0), radius: 20),
        pi / 2,
        pi,
        true,
        Paint()..color = Colors.grey,
      );
      canvas.restore();
      _drawText(
        canvas,
        state.s5_calibratedLadle ? "Removes 2/12" : "Removes 1/6",
        lX + 50,
        lY - 30,
        16,
        Colors.white,
      );
    }

    if (state.step == 4) {
      _drawButton(
        canvas,
        80,
        220,
        140,
        50,
        state.tStr('lbl_bake'),
        Colors.redAccent,
      );
    }
  }

  void _drawButton(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    String text,
    Color color, {
    Color textColor = Colors.white,
    double fontSize = 18,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(h / 2),
      ),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(h / 2),
      ),
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(canvas, text, x + w / 2, y + h / 2, fontSize, textColor);
  }

  @override
  bool shouldRepaint(covariant FractionPainter oldDelegate) => true;
}
