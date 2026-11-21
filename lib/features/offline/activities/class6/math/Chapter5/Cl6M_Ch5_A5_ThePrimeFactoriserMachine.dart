// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // ऑडियो प्लेबैक के लिए आवश्यक पैकेज

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cl6M_Ch5_A5_ThePrimeFactoriserMachine(),
    ),
  );
}

// --- I18N डिक्शनरी (अनुवाद) ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'resetBtn': "RESET",
    'appTitle': "Applying Prime Factorisation",
    'appSubtitle': "Class 6 • CO-PRIME AND DIVISIBILITY",
    'initMachine': "Initialize Machine",
    'selectScenario': "Select Scenario",
    'observations': "Observations:",
    'stepLabel': "STEP",
    'nextScenario': "Next Scenario",
    'goalReached': "Goal Reached!",
    'finishLab': "Finish Lab",
    'finalDesc':
        "You have successfully mastered Prime Factorisation applications!",
    'btnFactorise': "FACTORISE",
    'btnCompare': "COMPARE",
    'btnCheckFit': "CHECK FIT",
    'btnCoPrime': "CO-PRIME",
    'btnNotCoPrime': "NOT CO-PRIME",
    'btnDivisible': "DIVISIBLE",
    'btnNotDivisible': "NOT DIVISIBLE",
    'msgNotCoPrime': "NOT CO-PRIME",
    'msgCoPrime': "CO-PRIME",
    'msgDivisible': "DIVISIBLE",
    's1_title': "1. The Common Factor Detector",
    's1_obj':
        "To understand that two numbers are NOT co-prime if they share a common prime factor.",
    's1_s1_t': "DRAG the number block '56' into the left hopper.",
    's1_s1_o': "The number block '56' is accepted by the machine.",
    's1_s2_t': "DRAG the number block '63' into the right hopper.",
    's1_s2_o': "The number block '63' is accepted by the machine.",
    's1_s3_t': "CLICK the green 'FACTORISE' lever.",
    's1_s3_o': "The machine outputs prime factors: 56 -> 2,2,2,7. 63 -> 3,3,7.",
    's1_s4_t': "CLICK the flashing 'COMPARE' button.",
    's1_s4_o': "Common factor detected: 7.",
    's1_s5_t': "Observe the final result.",
    's1_s5_o':
        "NOT CO-PRIME: These numbers are NOT co-prime because they both share the prime factor 7.",
    's2_title': "2. The Co-Prime Confirmation",
    's2_obj':
        "To understand that two numbers are co-prime if they do not share any common prime factors.",
    's2_s1_t': "DRAG '80' and '63' blocks into the hoppers.",
    's2_s1_o': "Both number blocks are accepted.",
    's2_s2_t': "CLICK the 'FACTORISE' lever.",
    's2_s2_o':
        "The machine outputs prime factors: 80 -> 2,2,2,2,5. 63 -> 3,3,7.",
    's2_s3_t': "CLICK the flashing 'COMPARE' button.",
    's2_s3_o': "SCAN COMPLETE: NO COMMON PRIME FACTORS FOUND.",
    's2_s4_t': "Observe the final result.",
    's2_s4_o':
        "CO-PRIME: These numbers are CO-PRIME because they do not share any prime factors.",
    's3_title': "3. The Divisibility Checker",
    's3_obj':
        "To understand that a number is divisible by another if the prime factors of the divisor are a complete subset of the dividend's prime factors.",
    's3_s1_t': "DRAG '168' to the top hopper and '12' to the side hopper.",
    's3_s1_o': "Numbers are placed in the correct hoppers.",
    's3_s2_t': "CLICK the 'FACTORISE' lever.",
    's3_s2_o': "Prime blocks outputted: 168 -> 2,2,2,3,7. 12 -> 2,2,3.",
    's3_s3_t': "CLICK the 'CHECK FIT' button.",
    's3_s3_o': "All blocks from 12 found a match in 168.",
    's3_s4_t': "Observe the final result.",
    's3_s4_o':
        "DIVISIBLE: 168 is divisible by 12 because all prime building blocks of 12 are inside 168.",
    's4_title': "4. The Safe Pair Challenge",
    's4_obj':
        "Apply the concept of co-prime numbers to determine if a pair is 'safe'.",
    's4_s1_t': "DRAG '57' and '85' into the machine and CLICK 'FACTORISE'.",
    's4_s1_o': "Factors outputted: 57 -> 3,19. 85 -> 5,17.",
    's4_s2_t':
        "Do they share common factors? CLICK 'CO-PRIME' or 'NOT CO-PRIME'.",
    's4_s2_o': "You correctly identified they share no factors.",
    's4_s3_t': "Check the result.",
    's4_s3_o': "CORRECT! 57 and 85 are co-prime.",
    's4_incorrect': "INCORRECT! No matching blocks found. They are co-prime.",
    's5_title': "5. The Divisibility Puzzle",
    's5_obj':
        "Apply the concept of prime factor inclusion to determine divisibility.",
    's5_s1_t': "DRAG '75' (top) and '21' (side), then CLICK 'FACTORISE'.",
    's5_s1_o': "Factors outputted: 75 -> 3,5,5. 21 -> 3,7.",
    's5_s2_t': "Does 21 fit into 75? CLICK 'DIVISIBLE' or 'NOT DIVISIBLE'.",
    's5_s2_o': "You identified that '7' has no match.",
    's5_s3_t': "Check the result.",
    's5_s3_o':
        "CORRECT! 75 is not divisible by 21 because prime block '7' is missing.",
    's5_incorrect': "INCORRECT! 75 is not divisible by 21 as '7' is missing.",
  },
  'hi': {
    'resetBtn': "रीसेट करें",
    'appTitle': "अभाज्य गुणनखंडन का अनुप्रयोग",
    'appSubtitle': "कक्षा 6 • सह-अभाज्य और विभाज्यता",
    'initMachine': "मशीन चालू करें",
    'selectScenario': "परिदृश्य चुनें",
    'observations': "अवलोकन:",
    'stepLabel': "चरण",
    'nextScenario': "अगला परिदृश्य",
    'goalReached': "लक्ष्य प्राप्त!",
    'finishLab': "लैब समाप्त करें",
    'finalDesc': "आपने अभाज्य गुणनखंडन में महारत हासिल कर ली है!",
    'btnFactorise': "गुणनखंड करें",
    'btnCompare': "तुलना करें",
    'btnCheckFit': "फिट जांचें",
    'btnCoPrime': "सह-अभाज्य",
    'btnNotCoPrime': "सह-अभाज्य नहीं",
    'btnDivisible': "विभाज्य",
    'btnNotDivisible': "अविभाज्य",
    'msgNotCoPrime': "सह-अभाज्य नहीं",
    'msgCoPrime': "सह-अभाज्य",
    'msgDivisible': "विभाज्य",
    's1_title': "1. सामान्य गुणनखंड डिटेक्टर",
    's1_obj':
        "यह समझना कि दो संख्याएँ सह-अभाज्य नहीं हैं यदि उनका कोई सामान्य अभाज्य गुणनखंड है।",
    's1_s1_t': "'56' ब्लॉक को बाएं हॉपर में खींचें।",
    's1_s1_o': "मशीन ने '56' को स्वीकार कर लिया।",
    's1_s2_t': "'63' ब्लॉक को दाएं हॉपर में खींचें।",
    's1_s2_o': "मशीन ने '63' को स्वीकार कर लिया।",
    's1_s3_t': "'FACTORISE' लीवर पर क्लिक करें।",
    's1_s3_o': "मशीन ने अभाज्य गुणनखंड दिए: 56 -> 2,2,2,7. 63 -> 3,3,7.",
    's1_s4_t': "'COMPARE' बटन पर क्लिक करें।",
    's1_s4_o': "सामान्य गुणनखंड मिला: 7.",
    's1_s5_t': "अंतिम परिणाम देखें।",
    's1_s5_o': "सह-अभाज्य नहीं: वे 7 साझा करते हैं।",
    's2_title': "2. सह-अभाज्य पुष्टि",
    's2_obj':
        "यह समझना कि दो संख्याएँ सह-अभाज्य हैं यदि उनका कोई सामान्य अभाज्य गुणनखंड नहीं है।",
    's2_s1_t': "'80' और '63' ब्लॉक हॉपर में खींचें।",
    's2_s1_o': "ब्लॉक स्वीकार किए गए।",
    's2_s2_t': "लीवर पर क्लिक करें।",
    's2_s2_o': "गुणनखंड: 80 -> 2,2,2,2,5. 63 -> 3,3,7.",
    's2_s3_t': "'COMPARE' बटन पर क्लिक करें।",
    's2_s3_o': "कोई सामान्य अभाज्य गुणनखंड नहीं मिला।",
    's2_s4_t': "परिणाम देखें।",
    's2_s4_o': "सह-अभाज्य: वे कोई गुणनखंड साझा नहीं करते हैं।",
    's3_title': "3. विभाज्यता चेकर",
    's3_obj':
        "यदि भाजक के सभी अभाज्य गुणनखंड भाज्य में हैं, तो संख्या विभाज्य है।",
    's3_s1_t': "'168' को शीर्ष और '12' को साइड हॉपर में खींचें।",
    's3_s1_o': "संख्याएँ सही हॉपर में हैं।",
    's3_s2_t': "लीवर पर क्लिक करें।",
    's3_s2_o': "गुणनखंड: 168 -> 2,2,2,3,7. 12 -> 2,2,3.",
    's3_s3_t': "'CHECK FIT' बटन पर क्लिक करें।",
    's3_s3_o': "12 के सभी ब्लॉक 168 में मिल गए।",
    's3_s4_t': "परिणाम देखें।",
    's3_s4_o': "विभाज्य: 12 के सभी अभाज्य ब्लॉक 168 के अंदर हैं।",
    's4_title': "4. सुरक्षित जोड़ी चुनौती",
    's4_obj': "सह-अभाज्य संख्याओं की पहचान करें।",
    's4_s1_t': "'57' और '85' खींचें और लीवर क्लिक करें।",
    's4_s1_o': "गुणनखंड: 57 -> 3,19. 85 -> 5,17.",
    's4_s2_t': "क्या वे सामान्य हैं? 'सह-अभाज्य' या 'सह-अभाज्य नहीं' चुनें।",
    's4_s2_o': "सही पहचाना।",
    's4_s3_t': "परिणाम जांचें।",
    's4_s3_o': "सही! 57 और 85 सह-अभाज्य हैं।",
    's4_incorrect': "गलत! कोई मिलान ब्लॉक नहीं। वे सह-अभाज्य हैं।",
    's5_title': "5. विभाज्यता पहेली",
    's5_obj': "विभाज्यता निर्धारित करने के लिए अभाज्य कारकों का उपयोग करें।",
    's5_s1_t': "'75' और '21' खींचें और लीवर क्लिक करें।",
    's5_s1_o': "गुणनखंड: 75 -> 3,5,5. 21 -> 3,7.",
    's5_s2_t': "क्या 21, 75 में फिट बैठता है? सही बटन चुनें।",
    's5_s2_o': "आपने पहचाना कि '7' का कोई मेल नहीं है।",
    's5_s3_t': "परिणाम जांचें।",
    's5_s3_o': "सही! 75, 21 से विभाज्य नहीं है क्योंकि '7' गायब है।",
    's5_incorrect': "गलत! 75, 21 से विभाज्य नहीं है क्योंकि '7' गायब है।",
  },
};

final Map<int, List<int>> factorData = {
  56: [2, 2, 2, 7],
  63: [3, 3, 7],
  80: [2, 2, 2, 2, 5],
  168: [2, 2, 2, 3, 7],
  12: [2, 2, 3],
  57: [3, 19],
  85: [5, 17],
  75: [3, 5, 5],
  21: [3, 7],
};

final Map<int, Map<String, dynamic>> primeVisuals = {
  2: {'c': const Color(0xFF3B82F6), 's': 'square'},
  3: {'c': const Color(0xFF22C55E), 's': 'triangle'},
  5: {'c': const Color(0xFFEAB308), 's': 'circle'},
  7: {'c': const Color(0xFFEF4444), 's': 'pill'},
  17: {'c': const Color(0xFFF97316), 's': 'hexagon'},
  19: {'c': const Color(0xFFA855F7), 's': 'diamond'},
};

class PrimeBlock {
  int n;
  double x;
  double y;
  double tx;
  double ty;
  double opacity;
  bool glow;
  PrimeBlock(
    this.n,
    this.x,
    this.y,
    this.tx,
    this.ty, {
    this.opacity = 0,
    this.glow = false,
  });
}

class CustomAnim {
  double t = 0;
  double duration;
  Function(double e, double p) update;
  Function()? onComplete;
  CustomAnim(this.duration, this.update, {this.onComplete});
}

class Cl6M_Ch5_A5_ThePrimeFactoriserMachine extends StatefulWidget {
  const Cl6M_Ch5_A5_ThePrimeFactoriserMachine({super.key});
  @override
  State<Cl6M_Ch5_A5_ThePrimeFactoriserMachine> createState() =>
      _Cl6M_Ch5_A5_ThePrimeFactoriserMachineState();
}

class _Cl6M_Ch5_A5_ThePrimeFactoriserMachineState
    extends State<Cl6M_Ch5_A5_ThePrimeFactoriserMachine>
    with SingleTickerProviderStateMixin {
  // ऐप स्टेट (App State)
  bool isCurtainVisible = true;
  bool isSidebarOpen = true;
  double sidebarWidth = 300;
  String lang = 'en';
  int scenario = 1;
  int step = 0;
  bool isLabComplete = false;

  // व्यू स्टेट (View State)
  double zoom = 1.0;
  double panX = 0;
  double panY = 0;
  double basePanX = 0;
  double basePanY = 0;
  double baseZoom = 1.0;

  // सिम स्टेट (Sim State)
  String mState = 'idle'; // idle, factorising, factorised, comparing, done
  int? activeDrag;
  double dragX = 0;
  double dragY = 0;
  int? blockTopL, blockTopR, blockTop, blockSide;
  List<PrimeBlock> factorsL = [];
  List<PrimeBlock> factorsR = [];
  List<PrimeBlock> factorsTop = [];
  List<PrimeBlock> factorsSide = [];
  double scannerX = 0;
  List<CustomAnim> anims = [];
  String? feedbackMsg;
  String? feedbackType;

  late AnimationController _gameLoop;
  final GlobalKey _canvasKey = GlobalKey();
  int _lastTime = DateTime.now().millisecondsSinceEpoch;

  // --- ऑडियो प्लेयर्स (Audio Players) ---
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  String t(String key) => translations[lang]?[key] ?? key;

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
      duration: const Duration(days: 365),
    )..addListener(_updateLoop);
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
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // --- ऑडियो प्लेबैक मेथड्स (Audio Playback Methods) ---

  // 1. सामान्य क्लिक के लिए (बटन, ड्रैग)
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  // 2. नया पेज/सफलता ध्वनि के लिए
  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  // 3. ड्रॉपडाउन मेनू के लिए
  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  // 4. त्रुटि ध्वनि के लिए (गलत उत्तर)
  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  // 5. शुरुआत (Curtain screen) ध्वनि
  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  // -----------------------------------------------------

  void _startLab() {
    curtainScreen(); // लैब शुरू होने पर ध्वनि
    setState(() => isCurtainVisible = false);
    _loadScenario(1);
    _gameLoop.forward();
  }

  void _loadScenario(int id) {
    setState(() {
      scenario = id;
      step = 0;
      mState = 'idle';
      activeDrag = null;
      dragX = 0;
      dragY = 0;
      blockTopL = null;
      blockTopR = null;
      blockTop = null;
      blockSide = null;
      factorsL.clear();
      factorsR.clear();
      factorsTop.clear();
      factorsSide.clear();
      scannerX = 0;
      anims.clear();
      feedbackMsg = null;
      feedbackType = null;
      isLabComplete = false;
      zoom = 1.0;
      panX = 0;
      panY = 0;
    });
  }

  void _handleReset() {
    playClick(); // रीसेट पर क्लिक ध्वनि
    setState(() => isCurtainVisible = true);
    Future.delayed(const Duration(milliseconds: 800), () => _loadScenario(1));
  }

  void _updateLoop() {
    int now = DateTime.now().millisecondsSinceEpoch;
    double dt = (now - _lastTime).toDouble();
    _lastTime = now;

    bool needsRepaint = false;
    for (int i = anims.length - 1; i >= 0; i--) {
      needsRepaint = true;
      var a = anims[i];
      a.t += dt;
      double p = min(1.0, a.t / a.duration);
      double easeOut = 1 - pow(1 - p, 3).toDouble();
      a.update(easeOut, p);
      if (p >= 1.0) {
        if (a.onComplete != null) a.onComplete!();
        anims.removeAt(i);
      }
    }
    if (needsRepaint || mState == 'factorising') {
      setState(() {});
    }
  }

  void addAnim(
    double duration,
    Function(double e, double p) update, {
    Function()? onComplete,
  }) {
    setState(
      () => anims.add(CustomAnim(duration, update, onComplete: onComplete)),
    );
  }

  bool hitTest(
    double px,
    double py,
    double bx,
    double by,
    double bw,
    double bh,
  ) {
    return px > bx && px < bx + bw && py > by && py < by + bh;
  }

  List<int> _getInputsForScenario() {
    if (scenario == 1) return [56, 63];
    if (scenario == 2) return [80, 63];
    if (scenario == 3) return [168, 12];
    if (scenario == 4) return [57, 85];
    if (scenario == 5) return [75, 21];
    return [];
  }

  int _getStepsCount() {
    return (scenario == 1 || scenario == 2 || scenario == 3) ? 5 : 3;
  }

  void _advanceStep() {
    if (step < _getStepsCount()) setState(() => step++);
    _checkScenarioComplete();
  }

  void _checkScenarioComplete() {
    if (step >= _getStepsCount()) {
      if (scenario == 5) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() => isLabComplete = true);
          playPageOpen(); // लैब समाप्त होने पर सफलता की ध्वनि
        });
      }
    }
  }

  void _triggerFactorise() {
    setState(() => mState = 'factorising');

    void createFactors(
      int? num,
      List<PrimeBlock> list,
      double yBase,
      double width,
    ) {
      if (num == null) return;
      List<int> facts = factorData[num]!;
      double spacing = min(50.0, width / facts.length);
      double startX = (width - (facts.length - 1) * spacing) / 2;
      for (int i = 0; i < facts.length; i++) {
        list.add(
          PrimeBlock(
            facts[i],
            startX + i * spacing,
            yBase,
            startX + i * spacing,
            yBase,
          ),
        );
      }
    }

    if (scenario == 1 || scenario == 2 || scenario == 4) {
      createFactors(blockTopL, factorsL, 60, 200);
      createFactors(blockTopR, factorsR, 60, 200);
    } else {
      createFactors(blockTop, factorsTop, 40, 300);
      createFactors(blockSide, factorsSide, 35, 300);
    }

    addAnim(
      1500,
      (e, p) {
        var lists = [factorsL, factorsR, factorsTop, factorsSide];
        for (var list in lists) {
          for (int i = 0; i < list.length; i++) {
            if (p > i / 10) list[i].opacity = min(1.0, (p - i / 10) * 5);
          }
        }
      },
      onComplete: () {
        setState(() => mState = 'factorised');
        if (scenario == 1 && step == 2) _advanceStep();
        if (scenario == 2 && step == 1) _advanceStep();
        if (scenario == 3 && step == 1) _advanceStep();
        if (scenario == 4 && step == 0) _advanceStep();
        if (scenario == 5 && step == 0) _advanceStep();
      },
    );
  }

  void _triggerCompare([bool? userGuess]) {
    setState(() {
      mState = 'comparing';
      scannerX = 0;
    });
    addAnim(
      2000,
      (e, p) => setState(() => scannerX = e * 440),
      onComplete: () {
        setState(() => scannerX = 0);
        List<Map<String, PrimeBlock>> common = [];
        List<int> usedR = [];

        for (var fl in factorsL) {
          int matchIdx = factorsR.indexWhere(
            (fr) => fr.n == fl.n && !usedR.contains(factorsR.indexOf(fr)),
          );
          if (matchIdx != -1) {
            common.add({'l': fl, 'r': factorsR[matchIdx]});
            usedR.add(matchIdx);
          }
        }

        bool actualIsCoPrime = common.isEmpty;

        void completeFeedback() {
          setState(() {
            mState = 'done';
            if (userGuess != null) {
              bool correct = (userGuess == actualIsCoPrime);
              feedbackType = correct ? 'success' : 'error';
              feedbackMsg = correct ? t('s4_s3_o') : t('s4_incorrect');
              // उपयोगकर्ता के उत्तर के आधार पर ध्वनि
              if (correct) {
                playPageOpen();
              } else {
                playError();
              }
            } else {
              feedbackType = actualIsCoPrime ? 'success' : 'error';
              feedbackMsg = actualIsCoPrime
                  ? t('msgCoPrime')
                  : t('msgNotCoPrime');
              playPageOpen(); // सिस्टम द्वारा जाँच पूरी होने पर
            }
          });
          _checkScenarioComplete();
        }

        if (common.isNotEmpty) {
          for (int i = 0; i < common.length; i++) {
            var c = common[i];
            double targetY = 130;
            double targetLX = 150.0 + i * 40;
            double targetRX = -150.0 + i * 40;
            addAnim(800, (e, p) {
              c['l']!.y = c['l']!.ty + (targetY - c['l']!.ty) * e;
              c['l']!.x = c['l']!.tx + (targetLX - c['l']!.tx) * e;
              c['l']!.glow = true;
              c['r']!.y = c['r']!.ty + (targetY - c['r']!.ty) * e;
              c['r']!.x = c['r']!.tx + (targetRX - c['r']!.tx) * e;
              c['r']!.glow = true;
            });
          }
          Future.delayed(const Duration(milliseconds: 1000), completeFeedback);
        } else {
          completeFeedback();
        }
      },
    );
  }

  void _triggerCheckFit([bool? userGuess]) {
    setState(() => mState = 'comparing');
    List<int> usedTop = [];
    bool allMatched = true;

    for (int i = 0; i < factorsSide.length; i++) {
      var fs = factorsSide[i];
      Future.delayed(Duration(milliseconds: i * 600), () {
        int matchIdx = factorsTop.indexWhere(
          (ft) => ft.n == fs.n && !usedTop.contains(factorsTop.indexOf(ft)),
        );
        if (matchIdx != -1) {
          usedTop.add(matchIdx);
          var ft = factorsTop[matchIdx];
          addAnim(
            500,
            (e, p) {
              fs.y = fs.ty + (-90) * e;
              fs.x = fs.tx + (ft.x - fs.tx) * e;
            },
            onComplete: () {
              setState(() {
                fs.opacity = 0;
                ft.glow = true;
              });
            },
          );
        } else {
          allMatched = false;
          addAnim(
            500,
            (e, p) => fs.y = fs.ty - sin(e * pi) * 20,
            onComplete: () {
              setState(() => fs.opacity = 0.3);
            },
          );
        }
      });
    }

    Future.delayed(Duration(milliseconds: factorsSide.length * 600 + 500), () {
      setState(() {
        mState = 'done';
        if (userGuess != null) {
          bool correct = (userGuess == allMatched);
          feedbackType = correct ? 'success' : 'error';
          feedbackMsg = correct ? t('s5_s3_o') : t('s5_incorrect');
          // उपयोगकर्ता के उत्तर के आधार पर ध्वनि
          if (correct) {
            playPageOpen();
          } else {
            playError();
          }
        } else {
          feedbackType = allMatched ? 'success' : 'error';
          feedbackMsg = allMatched ? t('msgDivisible') : t('btnNotDivisible');
          playPageOpen(); // सिस्टम द्वारा जाँच पूरी होने पर
        }
      });
      _checkScenarioComplete();
    });
  }

  void _handleTouch(Offset globalFocal) {
    if (_canvasKey.currentContext == null) return;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(globalFocal);

    double cx = localPos.dx;
    double cy = localPos.dy;
    double worldX = (cx - (renderBox.size.width / 2 + panX)) / zoom;
    double worldY = (cy - (renderBox.size.height / 2 + panY)) / zoom;

    List<int> inputs = _getInputsForScenario();
    for (int i = 0; i < inputs.length; i++) {
      int num = inputs[i];
      double bx = -150.0 + i * 300;
      double by = -280;
      if (hitTest(worldX, worldY, bx - 35, by - 35, 70, 70)) {
        if (![blockTopL, blockTopR, blockTop, blockSide].contains(num)) {
          playClick(); // ड्रैग शुरू होने पर ध्वनि
          setState(() {
            activeDrag = num;
            dragX = worldX;
            dragY = worldY;
          });
        }
      }
    }

    // बटन लॉजिक (Buttons logic)
    if (mState == 'idle' && hitTest(worldX, worldY, 280, 0, 30, 100)) {
      if ((scenario == 1 || scenario == 2 || scenario == 4) &&
          blockTopL != null &&
          blockTopR != null) {
        playClick(); // लीवर पर ध्वनि
        _triggerFactorise();
      }
      if ((scenario == 3 || scenario == 5) &&
          blockTop != null &&
          blockSide != null) {
        playClick(); // लीवर पर ध्वनि
        _triggerFactorise();
      }
    }

    if (mState == 'factorised') {
      if ((scenario == 1 || scenario == 2) &&
          hitTest(worldX, worldY, -80, 160, 160, 50)) {
        playClick(); // COMPARE बटन पर ध्वनि
        _triggerCompare();
        if (scenario == 1 && step == 3) _advanceStep();
        if (scenario == 2 && step == 2) _advanceStep();
      }
      if (scenario == 3 && hitTest(worldX, worldY, -80, 160, 160, 50)) {
        playClick(); // CHECK FIT बटन पर ध्वनि
        _triggerCheckFit();
        if (step == 2) _advanceStep();
      }
      if (scenario == 4) {
        if (hitTest(worldX, worldY, -180, 160, 160, 50)) {
          playClick(); // CO-PRIME बटन पर ध्वनि
          _triggerCompare(true);
          if (step == 1) _advanceStep();
        }
        if (hitTest(worldX, worldY, 20, 160, 160, 50)) {
          playClick(); // NOT CO-PRIME बटन पर ध्वनि
          _triggerCompare(false);
          if (step == 1) _advanceStep();
        }
      }
      if (scenario == 5) {
        if (hitTest(worldX, worldY, -180, 160, 160, 50)) {
          playClick(); // DIVISIBLE बटन पर ध्वनि
          _triggerCheckFit(true);
          if (step == 1) _advanceStep();
        }
        if (hitTest(worldX, worldY, 20, 160, 160, 50)) {
          playClick(); // NOT DIVISIBLE बटन पर ध्वनि
          _triggerCheckFit(false);
          if (step == 1) _advanceStep();
        }
      }
    }
  }

  void _handleTouchUpdate(Offset globalFocal) {
    if (_canvasKey.currentContext == null || activeDrag == null) return;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(globalFocal);
    double cx = localPos.dx;
    double cy = localPos.dy;
    double worldX = (cx - (renderBox.size.width / 2 + panX)) / zoom;
    double worldY = (cy - (renderBox.size.height / 2 + panY)) / zoom;
    setState(() {
      dragX = worldX;
      dragY = worldY;
    });
  }

  void _handleTouchEnd(Offset globalFocal) {
    if (activeDrag == null) return;

    if (_canvasKey.currentContext == null) return;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(globalFocal);
    double worldX = (localPos.dx - (renderBox.size.width / 2 + panX)) / zoom;
    double worldY = (localPos.dy - (renderBox.size.height / 2 + panY)) / zoom;

    bool dropped = false;
    if (scenario == 1 || scenario == 2 || scenario == 4) {
      if (hitTest(worldX, worldY, -180, -160, 100, 80) && blockTopL == null) {
        setState(() => blockTopL = activeDrag);
        dropped = true;
      } else if (hitTest(worldX, worldY, 80, -160, 100, 80) &&
          blockTopR == null) {
        setState(() => blockTopR = activeDrag);
        dropped = true;
      }
    } else {
      if (hitTest(worldX, worldY, -50, -180, 100, 80) && blockTop == null) {
        setState(() => blockTop = activeDrag);
        dropped = true;
      } else if (hitTest(worldX, worldY, -320, -20, 80, 100) &&
          blockSide == null) {
        setState(() => blockSide = activeDrag);
        dropped = true;
      }
    }

    if (dropped) {
      playClick(); // ब्लॉक छोड़ने पर ध्वनि
      if (scenario == 1) {
        if (step == 0 && blockTopL == 56) _advanceStep();
        if (step == 1 && blockTopR == 63) _advanceStep();
      }
      if (scenario == 2 &&
          step == 0 &&
          blockTopL != null &&
          blockTopR != null) {
        _advanceStep();
      }
      if (scenario == 3 && step == 0 && blockTop != null && blockSide != null) {
        _advanceStep();
      }
    }
    setState(() => activeDrag = null);
  }

  Widget _buildSidebarStep(int index) {
    String tsk = t('s${scenario}_s${index + 1}_t');
    String outc = t('s${scenario}_s${index + 1}_o');

    bool isActive = index == step;
    bool isCompleted = index < step;

    Color bgColor = isCompleted
        ? const Color(0xFF1E293B)
        : (isActive ? const Color(0x1A10B981) : const Color(0x330F172A));
    Color borderColor = isActive
        ? const Color(0xFF34D399)
        : const Color(0xFF334155);
    double opacity = (isCompleted || isActive) ? 1.0 : 0.4;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: opacity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.transparent
                    : (isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF334155)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 28,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                    '${t('stepLabel')} ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(
                          text: "Action: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: tsk),
                      ],
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF065F46)),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFFD1FAE5),
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: "${t('observations')} ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: outc),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // कैनवास क्षेत्र (Canvas Area)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              left: isSidebarOpen ? sidebarWidth : 0,
              child: Listener(
                onPointerDown: (event) {
                  _handleTouch(event.position);
                },
                onPointerMove: (event) {
                  if (activeDrag != null) {
                    _handleTouchUpdate(event.position);
                  }
                },
                onPointerUp: (event) {
                  if (activeDrag != null) {
                    _handleTouchEnd(event.position);
                  }
                },
                child: GestureDetector(
                  onScaleStart: (details) {
                    baseZoom = zoom;
                  },
                  onScaleUpdate: (details) {
                    if (activeDrag == null) {
                      setState(() {
                        zoom = (baseZoom * details.scale).clamp(0.4, 2.0);
                        panX += details.focalPointDelta.dx;
                        panY += details.focalPointDelta.dy;
                      });
                    }
                  },
                  child: Container(
                    key: _canvasKey,
                    color: const Color(0xFF0F172A),
                    child: CustomPaint(
                      painter: MachinePainter(
                        state: this,
                        timeMs: DateTime.now().millisecondsSinceEpoch,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),

            // साइडबार (Sidebar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Color(0xFF334155), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // पूरी तरह से स्क्रॉल करने योग्य साइडबार (Completely Scrollable Sidebar)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // हेडर अनुभाग (Header Section)
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                64,
                                20,
                                20,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF334155)),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.memory,
                                        color: Color(0xFF10B981),
                                        size: 36,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          t('appTitle'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 48,
                                      top: 4,
                                    ),
                                    child: Text(
                                      t('appSubtitle'),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 48),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF334155,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.language,
                                            size: 16,
                                          ),
                                          label: Text(lang.toUpperCase()),
                                          onPressed: () {
                                            playClick(); // भाषा बदलने पर ध्वनि
                                            setState(
                                              () => lang = lang == 'en'
                                                  ? 'hi'
                                                  : 'en',
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: Row(
                                            children: [
                                              const Icon(
                                                Icons.refresh,
                                                color: Colors.redAccent,
                                              ),
                                              Text(
                                                t('resetBtn'),
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onPressed: _handleReset,
                                          tooltip: t('resetBtn'),
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF334155,
                                            ).withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // इंटरएक्टिव चरण और परिदृश्य (Interactive Steps & Scenario Content)
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
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      border: Border.all(
                                        color: const Color(0xFF334155),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: scenario,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white54,
                                        ),
                                        items: [1, 2, 3, 4, 5]
                                            .map(
                                              (s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(t('s${s}_title')),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            playDropdown(); // ड्रॉपडाउन चयन पर ध्वनि
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
                                      color: const Color(
                                        0xFF0F172A,
                                      ).withOpacity(0.5),
                                      border: Border.all(
                                        color: const Color(0xFF334155),
                                      ),
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
                                              color: Color(0xFF10B981),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              t('observations'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          t('s${scenario}_obj'),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ...List.generate(
                                    _getStepsCount(),
                                    (index) => _buildSidebarStep(index),
                                  ),

                                  if (step == _getStepsCount() &&
                                      scenario < 5) ...[
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF10B981,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        playClick(); // अगला परिदृश्य पर ध्वनि
                                        _loadScenario(scenario + 1);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            t('nextScenario'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                          ),
                                        ],
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
                    // फुटर (Footer)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: const Color(0xFF020617),
                      child: const Text(
                        "© ZeroScienceLab - विज्ञान और गणित से प्यार करें",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // साइडबार एडजस्टर (Sidebar Adjuster)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? sidebarWidth - 10 : -10,
              width: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  if (isSidebarOpen) {
                    setState(() {
                      sidebarWidth = max(
                        300,
                        min(
                          MediaQuery.of(context).size.width * 0.6,
                          sidebarWidth + details.delta.dx,
                        ),
                      );
                    });
                  }
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // मेनू बटन (Menu Button)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                child: Icon(
                  isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  playClick(); // मेनू टॉगल पर ध्वनि
                  setState(() => isSidebarOpen = !isSidebarOpen);
                },
              ),
            ),

            // हेड-अप डिस्प्ले (HUD)
            if (step < _getStepsCount())
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: 20,
                left: isSidebarOpen ? sidebarWidth + 20 : 20,
                right: 20,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: const Border(
                        top: BorderSide(color: Color(0xFF10B981), width: 4),
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
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info,
                            color: Color(0xFF34D399),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            t('s${scenario}_s${step + 1}_t'),
                            style: const TextStyle(
                              color: Colors.white,
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

            // सफलता फाइनल पॉपअप (Success Final Popup)
            if (isLabComplete)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 500,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x6610B981),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('goalReached'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('finalDesc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed:
                                _handleReset, // ध्वनि इसमें पहले से ही है
                            child: Text(
                              t('finishLab'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
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

            // कर्टन स्क्रीन (Curtain Screen)
            if (isCurtainVisible)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.memory,
                        color: Color(0xFF10B981),
                        size: 100,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t('appTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t('appSubtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 10,
                        ),
                        onPressed: _startLab, // ध्वनि इसमें जुड़ी हुई है
                        child: Text(
                          t('initMachine'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- पेंटर लॉजिक (Painter Logic) ---
class MachinePainter extends CustomPainter {
  final _Cl6M_Ch5_A5_ThePrimeFactoriserMachineState state;
  final int timeMs;

  MachinePainter({required this.state, required this.timeMs});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    _renderConveyor(canvas, -320);

    if (state.scenario == 1 || state.scenario == 2 || state.scenario == 4) {
      _renderFactoriserMachine(canvas);
    } else {
      _renderDivisibilityMachine(canvas);
    }

    // कन्वेयर ब्लॉक्स (Conveyor Blocks)
    List<int> inputs = state._getInputsForScenario();
    for (int i = 0; i < inputs.length; i++) {
      int num = inputs[i];
      bool isDragged = (state.activeDrag == num);
      bool isDropped = [
        state.blockTopL,
        state.blockTopR,
        state.blockTop,
        state.blockSide,
      ].contains(num);
      if (!isDragged && !isDropped) {
        _renderInputBlock(canvas, -150.0 + i * 300, -280, num);
      }
    }

    if (state.activeDrag != null) {
      _renderInputBlock(canvas, state.dragX, state.dragY, state.activeDrag!);
    }
  }

  void _renderConveyor(Canvas canvas, double y) {
    _drawRRect(
      canvas,
      -500,
      y + 30,
      1000,
      20,
      10,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );
    _drawRRect(
      canvas,
      -480,
      y + 35,
      960,
      10,
      5,
      const Color(0xFF1E293B),
      Colors.transparent,
      0,
    );
    Paint p = Paint()..color = const Color(0xFF94A3B8);
    for (double i = -450; i < 450; i += 40) {
      canvas.drawCircle(Offset(i, y + 40), 4, p);
    }
  }

  void _renderInputBlock(Canvas canvas, double x, double y, int num) {
    _drawRRect(
      canvas,
      x - 35,
      y - 35,
      70,
      70,
      8,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      4,
    );
    _drawRRect(
      canvas,
      x - 30,
      y - 30,
      60,
      60,
      4,
      Colors.white.withOpacity(0.4),
      Colors.transparent,
      0,
    );
    _drawTextOutline(canvas, num.toString(), x, y, 26, const Color(0xFF0F172A));
  }

  Color _getHopperColor(bool isFilled) =>
      isFilled ? const Color(0xFF22C55E) : const Color(0xFF64748B);

  void _renderFactoriserMachine(Canvas canvas) {
    _drawRRect(
      canvas,
      -260,
      -100,
      520,
      280,
      20,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      5,
    );
    _drawRRect(
      canvas,
      -240,
      -80,
      480,
      240,
      15,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );

    _drawRRect(
      canvas,
      -180,
      -160,
      100,
      80,
      10,
      _getHopperColor(state.blockTopL != null),
      const Color(0xFF0F172A),
      4,
      topOnly: true,
    );
    _drawRRect(
      canvas,
      80,
      -160,
      100,
      80,
      10,
      _getHopperColor(state.blockTopR != null),
      const Color(0xFF0F172A),
      4,
      topOnly: true,
    );

    _drawTextOutline(
      canvas,
      state.lang == 'hi' ? 'बायां हॉपर' : 'Left Hopper',
      -150,
      -180,
      14,
      Colors.white70,
    );
    _drawTextOutline(
      canvas,
      state.lang == 'hi' ? 'दायां हॉपर' : 'Right Hopper',
      110,
      -180,
      14,
      Colors.white70,
    );

    if (state.blockTopL != null) {
      _renderInputBlock(canvas, -130, -120, state.blockTopL!);
    }
    if (state.blockTopR != null) {
      _renderInputBlock(canvas, 130, -120, state.blockTopR!);
    }

    double leverShake = (state.mState == 'factorising')
        ? sin(timeMs / 30.0) * 5
        : 0;
    double leverY =
        (state.mState == 'factorised' ||
            state.mState == 'comparing' ||
            state.mState == 'done')
        ? 60
        : 0;
    bool leverActive =
        (state.blockTopL != null &&
        state.blockTopR != null &&
        state.mState == 'idle');

    _drawRRect(
      canvas,
      280 + leverShake,
      leverY,
      30,
      100,
      15,
      leverActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      4,
    );
    if (leverActive) {
      _drawRRect(
        canvas,
        280,
        leverY,
        30,
        100,
        15,
        Colors.transparent,
        const Color(0xFF4ADE80),
        6,
      );
    }
    _drawTextOutline(
      canvas,
      state.t('btnFactorise'),
      295 + leverShake,
      leverY - 20,
      12,
      const Color(0xFFF8FAFC),
    );

    _drawRRect(
      canvas,
      -220,
      20,
      200,
      120,
      8,
      Colors.white.withOpacity(0.1),
      const Color(0xFFCBD5E1),
      2,
    );
    _drawRRect(
      canvas,
      20,
      20,
      200,
      120,
      8,
      Colors.white.withOpacity(0.1),
      const Color(0xFFCBD5E1),
      2,
    );

    for (var f in state.factorsL) {
      _drawPrimeBlock(canvas, -220 + f.x, 20 + f.y, 40, f.n, f.opacity, f.glow);
    }
    for (var f in state.factorsR) {
      _drawPrimeBlock(canvas, 20 + f.x, 20 + f.y, 40, f.n, f.opacity, f.glow);
    }

    if (state.mState == 'comparing' && state.scannerX != 0) {
      Paint p = Paint()
        ..color = const Color(0xFF3B82F6).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawRect(Rect.fromLTWH(-220 + state.scannerX, 10, 10, 140), p);
    }

    if (state.mState == 'factorised' && state.scenario <= 2) {
      _drawRRect(
        canvas,
        -80,
        160,
        160,
        50,
        25,
        const Color(0xFF3B82F6),
        const Color(0xFF0F172A),
        4,
      );
      _drawTextOutline(canvas, state.t('btnCompare'), 0, 185, 16, Colors.white);
    } else if (state.mState == 'factorised' && state.scenario == 4) {
      _drawRRect(
        canvas,
        -180,
        160,
        160,
        50,
        25,
        const Color(0xFF22C55E),
        const Color(0xFF0F172A),
        4,
      );
      _drawTextOutline(
        canvas,
        state.t('btnCoPrime'),
        -100,
        185,
        16,
        Colors.white,
      );
      _drawRRect(
        canvas,
        20,
        160,
        160,
        50,
        25,
        const Color(0xFFEF4444),
        const Color(0xFF0F172A),
        4,
      );
      _drawTextOutline(
        canvas,
        state.t('btnNotCoPrime'),
        100,
        185,
        16,
        Colors.white,
      );
    }

    if (state.mState == 'done' && state.feedbackMsg != null) {
      _renderFeedbackBox(canvas, state.feedbackMsg!, state.feedbackType!);
    }
  }

  void _renderDivisibilityMachine(Canvas canvas) {
    _drawRRect(
      canvas,
      -260,
      -100,
      520,
      280,
      20,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      5,
    );
    _drawRRect(
      canvas,
      -240,
      -80,
      480,
      240,
      15,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );

    _drawRRect(
      canvas,
      -50,
      -180,
      100,
      80,
      10,
      _getHopperColor(state.blockTop != null),
      const Color(0xFF0F172A),
      4,
      topOnly: true,
    );
    _drawRRect(
      canvas,
      -320,
      -20,
      80,
      100,
      10,
      _getHopperColor(state.blockSide != null),
      const Color(0xFF0F172A),
      4,
      leftOnly: true,
    );

    _drawTextOutline(
      canvas,
      state.lang == 'hi' ? 'ऊपरी हॉपर' : 'Top Hopper',
      -20,
      -200,
      14,
      Colors.white70,
    );
    _drawTextOutline(
      canvas,
      state.lang == 'hi' ? 'साइड हॉपर' : 'Side Hopper',
      -360,
      -40,
      14,
      Colors.white70,
    );

    if (state.blockTop != null) {
      _renderInputBlock(canvas, 0, -140, state.blockTop!);
    }
    if (state.blockSide != null) {
      _renderInputBlock(canvas, -280, 30, state.blockSide!);
    }

    double leverShake = (state.mState == 'factorising')
        ? sin(timeMs / 30.0) * 5
        : 0;
    double leverY =
        (state.mState == 'factorised' ||
            state.mState == 'comparing' ||
            state.mState == 'done')
        ? 60
        : 0;
    bool leverActive =
        (state.blockTop != null &&
        state.blockSide != null &&
        state.mState == 'idle');

    _drawRRect(
      canvas,
      280 + leverShake,
      leverY,
      30,
      100,
      15,
      leverActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      4,
    );
    if (leverActive) {
      _drawRRect(
        canvas,
        280,
        leverY,
        30,
        100,
        15,
        Colors.transparent,
        const Color(0xFF4ADE80),
        6,
      );
    }
    _drawTextOutline(
      canvas,
      state.t('btnFactorise'),
      295 + leverShake,
      leverY - 20,
      12,
      const Color(0xFFF8FAFC),
    );

    _drawRRect(
      canvas,
      -150,
      -10,
      300,
      80,
      8,
      Colors.white.withOpacity(0.1),
      const Color(0xFFCBD5E1),
      2,
    );
    _drawRRect(
      canvas,
      -150,
      80,
      300,
      70,
      8,
      Colors.white.withOpacity(0.1),
      const Color(0xFFCBD5E1),
      2,
    );

    for (var f in state.factorsTop) {
      _drawPrimeBlock(
        canvas,
        -150 + f.x,
        -10 + f.y,
        40,
        f.n,
        f.opacity,
        f.glow,
      );
    }
    for (var f in state.factorsSide) {
      _drawPrimeBlock(canvas, -150 + f.x, 80 + f.y, 40, f.n, f.opacity, f.glow);
    }

    if (state.mState == 'factorised' && state.scenario == 3) {
      _drawRRect(
        canvas,
        -80,
        160,
        160,
        50,
        25,
        const Color(0xFFEAB308),
        const Color(0xFF0F172A),
        4,
      );
      _drawTextOutline(
        canvas,
        state.t('btnCheckFit'),
        0,
        185,
        16,
        const Color(0xFF0F172A),
      );
    } else if (state.mState == 'factorised' && state.scenario == 5) {
      _drawRRect(
        canvas,
        -180,
        160,
        160,
        50,
        25,
        const Color(0xFF22C55E),
        const Color(0xFF0F172A),
        4,
      );
      _drawTextOutline(
        canvas,
        state.t('btnDivisible'),
        -100,
        185,
        16,
        Colors.white,
      );
      _drawRRect(
        canvas,
        20,
        160,
        160,
        50,
        25,
        const Color(0xFFEF4444),
        const Color(0xFF0F172A),
        4,
      );
      _drawTextOutline(
        canvas,
        state.t('btnNotDivisible'),
        100,
        185,
        16,
        Colors.white,
      );
    }

    if (state.mState == 'done' && state.feedbackMsg != null) {
      _renderFeedbackBox(canvas, state.feedbackMsg!, state.feedbackType!);
    }
  }

  void _drawPrimeBlock(
    Canvas canvas,
    double x,
    double y,
    double size,
    int num,
    double opacity,
    bool glow,
  ) {
    if (opacity <= 0) return;
    var v = primeVisuals[num];
    if (v == null) return;

    Color c = v['c'];
    String s = v['s'];

    Paint pFill = Paint()
      ..color = c.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    Paint pStroke = Paint()
      ..color = const Color(0xFF0F172A).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (glow) {
      pFill.maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
      pFill.color = c;
    }

    canvas.save();
    canvas.translate(x, y);

    if (s == 'square') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: size, height: size),
          const Radius.circular(4),
        ),
        pFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: size, height: size),
          const Radius.circular(4),
        ),
        pStroke,
      );
    } else if (s == 'circle') {
      canvas.drawCircle(Offset.zero, size / 2, pFill);
      canvas.drawCircle(Offset.zero, size / 2, pStroke);
    } else if (s == 'triangle') {
      Path path = Path();
      for (int i = 0; i < 3; i++) {
        double px = (size / 1.8) * cos(-pi / 2 + i * 2 * pi / 3);
        double py = (size / 6) + (size / 1.8) * sin(-pi / 2 + i * 2 * pi / 3);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, pFill);
      canvas.drawPath(path, pStroke);
    } else if (s == 'pill') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: size * 1.4, height: size),
          Radius.circular(size / 2),
        ),
        pFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: size * 1.4, height: size),
          Radius.circular(size / 2),
        ),
        pStroke,
      );
    } else if (s == 'hexagon') {
      Path path = Path();
      for (int i = 0; i < 6; i++) {
        double px = (size / 1.8) * cos(pi / 2 + i * 2 * pi / 6);
        double py = (size / 1.8) * sin(pi / 2 + i * 2 * pi / 6);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, pFill);
      canvas.drawPath(path, pStroke);
    } else if (s == 'diamond') {
      Path path = Path();
      for (int i = 0; i < 4; i++) {
        double px = (size / 1.6) * cos(i * 2 * pi / 4);
        double py = (size / 1.6) * sin(i * 2 * pi / 4);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, pFill);
      canvas.drawPath(path, pStroke);
    }

    _drawTextOutline(
      canvas,
      num.toString(),
      0,
      0,
      size * 0.45,
      Colors.white.withOpacity(opacity),
    );
    canvas.restore();
  }

  void _renderFeedbackBox(Canvas canvas, String msg, String type) {
    canvas.save();
    canvas.translate(0, 220);
    canvas.rotate(-0.02);

    Color color = type == 'success'
        ? const Color(0xFF166534)
        : const Color(0xFF991B1B);
    Color bgColor = type == 'success'
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);
    Color borderColor = type == 'success'
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    _drawRRect(canvas, -220, -40, 440, 80, 10, bgColor, borderColor, 4);

    // सरल टेक्स्ट रैपिंग (Simple text wrapping simulation)
    List<String> words = msg.split(' ');
    List<String> lines = [];
    String curLine = "";
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (String w in words) {
      String test = "$curLine$w ";
      textPainter.text = TextSpan(
        text: test,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      if (textPainter.width > 400 && curLine.isNotEmpty) {
        lines.add(curLine.trim());
        curLine = "$w ";
      } else {
        curLine = test;
      }
    }
    lines.add(curLine.trim());

    double startY = lines.length > 1 ? -10 : 0;
    for (int i = 0; i < lines.length; i++) {
      _drawTextOutline(canvas, lines[i], 0, startY + i * 22, 16, color);
    }

    canvas.restore();
  }

  void _drawRRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double lineW, {
    bool topOnly = false,
    bool leftOnly = false,
  }) {
    RRect rr;
    if (topOnly) {
      rr = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, w, h),
        topLeft: Radius.circular(r),
        topRight: Radius.circular(r),
      );
    } else if (leftOnly) {
      rr = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, w, h),
        topLeft: Radius.circular(r),
        bottomLeft: Radius.circular(r),
      );
    } else {
      rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(r),
      );
    }
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rr,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (stroke != Colors.transparent && lineW > 0) {
      canvas.drawRRect(
        rr,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineW,
      );
    }
  }

  void _drawTextOutline(
    Canvas canvas,
    String text,
    double x,
    double y,
    double size,
    Color fillStyle,
  ) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: fillStyle,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant MachinePainter oldDelegate) => true;
}
