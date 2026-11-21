// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: non_constant_identifier_names, camel_case_types, deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZSL Virtual Lab',
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const Cl6M_Ch5_A1_ExploringMultiplesandFactors(),
    ),
  );
}

// --- LOCALIZATION DICTIONARY ---
const Map<String, Map<String, String>> Translation = {
  'en': {
    'shutterTitle': "Exploring Multiples and Factors",
    'appTitle': "Exploring Multiples and Factors",
    'appSubtitle': "Class 6 • The Idli-Vada & Jump Jackpot Games",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Observations:",
    'closeBtn': "Close",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You have successfully explored multiples, factors, and co-prime numbers using interactive models!",
    'lbl_start': "START",
    'lbl_jump': "JUMP!",
    'lbl_showAll': "Show All",
    'lbl_showAllC': "Show Common",
    'lbl_test': "TEST",
    'lbl_checkSafe': "CHECK SAFETY",
    'lbl_idliM': "Idli Machine",
    'lbl_vadaM': "Vada Machine",
    'lbl_boots': "Jump Boots",
    'lbl_safe': "SAFE!",
    'lbl_unsafe': "NOT SAFE!",
    'lbl_targ': "Target: First at 42",
    'lbl_s1_common': "Common Multiple!",
    'lbl_jackpot': "Jackpot!",
    's1_title': "1. The Idli-Vada Factory",
    's1_obj':
        "Visually understand multiples and common multiples by observing a factory production line.",
    's1_step1_task': "CLICK the green 'START' button to run the conveyor belt.",
    's1_step1_out': "The conveyor belt with numbered plates starts moving.",
    's1_step2_task':
        "Observe the Idli and Vada dispensers dropping items on multiples of 3 and 5.",
    's1_step2_out': "Idlis drop on 3,6,9... Vadas on 5,10,15...",
    's1_step3_task': "Observe what happens on plate 15.",
    's1_step3_out':
        "Both an Idli and a Vada land on plate 15! This is a Common Multiple.",
    's1_step4_task': "Review the summary panel after the belt stops at 30.",
    's1_step4_out': "Common Multiples of 3 and 5 are 15 and 30.",
    's1_hud1': "Click START to begin.",
    's1_hud2': "Observe the multiples of 3 and 5.",
    's1_hud3': "Watch plate 15 carefully.",
    's1_hud4': "Review the common multiples.",
    's2_title': "2. Jump Jackpot (Single)",
    's2_obj':
        "Understand factors by testing which 'jump sizes' land perfectly on a treasure.",
    's2_step1_task': "CLICK on the boots with size '4'.",
    's2_step1_out': "Jumpy the frog puts on size 4 boots.",
    's2_step2_task': "CLICK the 'JUMP!' button.",
    's2_step2_out':
        "Success! 4 is a factor of 24. Jumpy lands perfectly on the treasure.",
    's2_step3_task': "CLICK on the boots with size '5' and jump again.",
    's2_step3_out': "Miss! 5 is NOT a factor of 24. Jumpy jumps over it.",
    's2_step4_task': "CLICK 'Show All' to reveal all factors.",
    's2_step4_out': "Factors of 24 are {2, 3, 4, 6, 8, 12, 24}.",
    's2_hud1': "Equip size 4 boots.",
    's2_hud2': "Click JUMP! to test the boots.",
    's2_hud3': "Now test size 5 boots.",
    's2_hud4': "Click 'Show All' to see successful jumps.",
    's3_title': "3. Jump Jackpot (Double)",
    's3_obj':
        "Understand common factors by finding a jump size that lands on TWO different treasures.",
    's3_step1_task': "CLICK on boots with size '4'.",
    's3_step1_out': "Jumpy puts on size 4 boots.",
    's3_step2_task': "CLICK the 'JUMP!' button.",
    's3_step2_out': "Partial Success! 4 is a factor of 12, but misses 18.",
    's3_step3_task': "CLICK on boots with size '3' and jump again.",
    's3_step3_out':
        "Success! 3 is a common factor of 12 and 18. Both chests open!",
    's3_step4_task': "CLICK 'Show Common' to see all common factors.",
    's3_step4_out': "Common Factors of 12 and 18 are {2, 3, 6}.",
    's3_hud1': "Equip size 4 boots.",
    's3_hud2': "Test size 4 to hit chests at 12 and 18.",
    's3_hud3': "Now test size 3 boots.",
    's3_hud4': "Reveal all common factors.",
    's4_title': "4. The Idli-Vada Challenge",
    's4_obj':
        "Apply common multiples (LCM) to set up the factory so the first 'Idli-Vada' plate appears at 42.",
    's4_step1_task':
        "Click the arrows on the 'Idli Machine' dial to set a factor of 42 (e.g., 6).",
    's4_step1_out': "Idli dial is set.",
    's4_step2_task':
        "Click the arrows on the 'Vada Machine' dial to set another number.",
    's4_step2_out': "Vada dial is set. (Hint: Choose 7).",
    's4_step3_task': "CLICK 'TEST' to run the factory.",
    's4_step3_out': "Success! The LCM of 6 and 7 is 42.",
    's4_hud1': "Set the Idli Dial to 6.",
    's4_hud2': "Set the Vada Dial to 7.",
    's4_hud3': "Click TEST to see if they meet at 42.",
    's5_title': "5. Grumpy's Safe Treasures",
    's5_obj':
        "Apply co-prime numbers to place two treasures so no single jump size (2-10) can hit BOTH.",
    's5_step1_task': "DRAG the first treasure chest onto a number (e.g., 9).",
    's5_step1_out': "First treasure placed.",
    's5_step2_task':
        "DRAG the second treasure chest onto a co-prime number (e.g., 16).",
    's5_step2_out': "Second treasure placed.",
    's5_step3_task': "CLICK 'CHECK SAFETY' to test jumps 2 through 10.",
    's5_step3_out': "Safe! 9 and 16 have no common factors other than 1.",
    's5_hud1': "Drag Chest 1 to number 9.",
    's5_hud2': "Drag Chest 2 to number 16.",
    's5_hud3': "Check if they are safe from jumps 2-10.",
  },
  'hi': {
    'shutterTitle': "गुणज और गुणनखंड की खोज",
    'appTitle': "गुणज और गुणनखंड की खोज",
    'appSubtitle': "कक्षा 6 • इडली-वड़ा और जंप जैकपॉट गेम",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "अवलोकन:",
    'closeBtn': "बंद करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc':
        "आपने इंटरैक्टिव मॉडल का उपयोग करके गुणज, गुणनखंड और सह-अभाज्य संख्याओं का सफलतापूर्वक पता लगाया है!",
    'lbl_start': "शुरू",
    'lbl_jump': "कूदें!",
    'lbl_showAll': "सभी दिखाएँ",
    'lbl_showAllC': "सामान्य दिखाएँ",
    'lbl_test': "परीक्षण",
    'lbl_checkSafe': "सुरक्षा जांचें",
    'lbl_idliM': "इडली मशीन",
    'lbl_vadaM': "वड़ा मशीन",
    'lbl_boots': "जंप बूट्स",
    'lbl_safe': "सुरक्षित!",
    'lbl_unsafe': "असुरक्षित!",
    'lbl_targ': "लक्ष्य: 42 पर पहला",
    'lbl_s1_common': "सामान्य गुणज!",
    'lbl_jackpot': "जैकपॉट!",
    's1_title': "1. इडली-वड़ा फैक्टरी",
    's1_obj': "फैक्ट्री उत्पादन लाइन को देखकर गुणज और सामान्य गुणज को समझें।",
    's1_step1_task': "कन्वेयर बेल्ट चलाने के लिए 'शुरू' बटन पर क्लिक करें।",
    's1_step1_out': "प्लेटों के साथ कन्वेयर बेल्ट चलने लगती है।",
    's1_step2_task': "इडली और वड़ा 3 और 5 के गुणकों पर गिरते हुए देखें।",
    's1_step2_out': "इडली 3,6,9... पर और वड़ा 5,10,15... पर गिरता है।",
    's1_step3_task': "देखें कि प्लेट 15 पर क्या होता है।",
    's1_step3_out':
        "प्लेट 15 पर इडली और वड़ा दोनों गिरते हैं! यह एक सामान्य गुणज है।",
    's1_step4_task': "बेल्ट 30 पर रुकने के बाद सारांश देखें।",
    's1_step4_out': "3 और 5 के सामान्य गुणज 15 और 30 हैं।",
    's1_hud1': "शुरू करने के लिए क्लिक करें।",
    's1_hud2': "3 और 5 के गुणकों का निरीक्षण करें।",
    's1_hud3': "प्लेट 15 को ध्यान से देखें।",
    's1_hud4': "सामान्य गुणकों की समीक्षा करें।",
    's2_title': "2. जंप जैकपॉट (सिंगल)",
    's2_obj':
        "यह परीक्षण करके गुणनखंडों को समझें कि कौन से 'कूद आकार' खजाने पर सटीक उतरते हैं।",
    's2_step1_task': "आकार '4' वाले बूट्स पर क्लिक करें।",
    's2_step1_out': "जंपी मेंढक ने 4 आकार के जूते पहने।",
    's2_step2_task': "'कूदें!' बटन पर क्लिक करें।",
    's2_step2_out': "सफलता! 4, 24 का गुणनखंड है। जंपी खजाने पर उतरता है।",
    's2_step3_task': "आकार '5' वाले बूट्स पर क्लिक करें और फिर से कूदें।",
    's2_step3_out': "चूक! 5, 24 का गुणनखंड नहीं है। जंपी इसके ऊपर से कूदता है।",
    's2_step4_task': "सभी गुणनखंड देखने के लिए 'सभी दिखाएँ' पर क्लिक करें।",
    's2_step4_out': "24 के गुणनखंड {2, 3, 4, 6, 8, 12, 24} हैं।",
    's2_hud1': "आकार 4 के जूते पहनें।",
    's2_hud2:': "जूतों का परीक्षण करने के लिए 'कूदें!' क्लिक करें।",
    's2_hud3:': "अब आकार 5 के जूतों का परीक्षण करें।",
    's2_hud4': "सफल छलांग देखने के लिए क्लिक करें।",
    's3_title': "3. जंप जैकपॉट (डबल)",
    's3_obj':
        "कूद का आकार खोजकर सामान्य गुणनखंडों को समझें जो दो अलग-अलग खजानों पर उतरता है।",
    's3_step1_task': "आकार '4' वाले बूट्स पर क्लिक करें।",
    's3_step1_out': "जंपी ने 4 आकार के जूते पहने।",
    's3_step2_task': "'कूदें!' बटन पर क्लिक करें।",
    's3_step2_out':
        "आंशिक सफलता! 4, 12 का गुणनखंड है, लेकिन 18 से चूक जाता है।",
    's3_step3_task': "आकार '3' वाले बूट्स पर क्लिक करें और फिर से कूदें।",
    's3_step3_out':
        "सफलता! 3, 12 और 18 का सामान्य गुणनखंड है। दोनों संदूक खुलते हैं!",
    's3_step4_task':
        "सामान्य गुणनखंड देखने के लिए 'सामान्य दिखाएँ' पर क्लिक करें।",
    's3_step4_out': "12 और 18 के सामान्य गुणनखंड {2, 3, 6} हैं।",
    's3_hud1': "आकार 4 के जूते पहनें।",
    's3_hud2': "12 और 18 पर खजाने को हिट करने के लिए आकार 4 का परीक्षण करें।",
    's3_hud3': "अब आकार 3 के जूतों का परीक्षण करें।",
    's3_hud4': "सभी सामान्य गुणनखंड प्रकट करें।",
    's4_title': "4. इडली-वड़ा चुनौती",
    's4_obj':
        "सामान्य गुणज (LCM) लागू करें ताकि 42 पर पहली 'इडली-वड़ा' प्लेट दिखाई दे।",
    's4_step1_task': "'इडली मशीन' डायल को 42 के गुणनखंड (उदा. 6) पर सेट करें।",
    's4_step1_out': "इडली डायल सेट हो गया।",
    's4_step2_task': "'वड़ा मशीन' डायल को किसी अन्य संख्या पर सेट करें।",
    's4_step2_out': "वड़ा डायल सेट हो गया। (संकेत: 7 चुनें)।",
    's4_step3_task': "फैक्ट्री चलाने के लिए 'परीक्षण' पर क्लिक करें।",
    's4_step3_out': "सफलता! 6 और 7 का LCM 42 है।",
    's4_hud1': "इडली डायल को 6 पर सेट करें।",
    's4_hud2': "वड़ा डायल को 7 पर सेट करें।",
    's4_hud3': "यह देखने के लिए परीक्षण करें कि क्या वे 42 पर मिलते हैं।",
    's5_title': "5. ग्रम्पी के सुरक्षित खजाने",
    's5_obj':
        "सह-अभाज्य संख्याएं लागू करें ताकि कोई भी एक छलांग दोनों खजानों को न मार सके।",
    's5_step1_task': "पहले खजाने को किसी संख्या (उदा. 9) पर खींचें।",
    's5_step1_out': "पहला खजाना रखा गया।",
    's5_step2_task': "दूसरे खजाने को सह-अभाज्य संख्या (उदा. 16) पर खींचें।",
    's5_step2_out': "दूसरा खजाना रखा गया।",
    's5_step3_task':
        "कूदने का परीक्षण करने के लिए 'सुरक्षा जांचें' पर क्लिक करें।",
    's5_step3_out':
        "सुरक्षित! 9 और 16 का 1 के अलावा कोई सामान्य गुणनखंड नहीं है।",
    's5_hud1': "चेस्ट 1 को नंबर 9 पर खींचें।",
    's5_hud2': "चेस्ट 2 को नंबर 16 पर खींचें।",
    's5_hud3': "जांचें कि क्या वे 2-10 छलांग से सुरक्षित हैं।",
  },
};

// --- SIMULATION STATE ---
class SimState {
  int scenario = 1;
  int step = 0;
  bool animating = false;

  // S1
  int s1_platePos = 0;
  int s1_idliDial = 3;
  int s1_vadaDial = 5;
  int s1_maxPlate = 30;

  // S2
  List<int> s2_boots = [2, 3, 4, 5, 6, 8];
  int? s2_activeBoot;
  int s2_frogPos = 0;
  List<int> s2_path = [];
  bool s2_showAll = false;
  double s2_frogYOffset = 0;

  // S3
  List<int> s3_boots = [2, 3, 4, 6];
  int? s3_activeBoot;
  int s3_frogPos = 0;
  List<int> s3_path = [];
  bool s3_showAll = false;
  double s3_frogYOffset = 0;

  // S4
  int s4_idliDial = 1;
  int s4_vadaDial = 1;
  int s4_platePos = 0;
  int? s4_result;
  int s4_maxPlate = 50;

  // S5
  int? s5_t1;
  int? s5_t2;
  int s5_testJumpSize = 2;
  int s5_frogPos = 0;
  dynamic s5_result;
  double s5_frogYOffset = 0;
  String? activeDragEntity;
  double dragX = 0;
  double dragY = 0;

  void resetScenario() {
    animating = false;
    step = 0;
    activeDragEntity = null;
    if (scenario == 1) {
      s1_platePos = 0;
      s1_idliDial = 3;
      s1_vadaDial = 5;
    } else if (scenario == 2) {
      s2_activeBoot = null;
      s2_frogPos = 0;
      s2_path = [];
      s2_showAll = false;
    } else if (scenario == 3) {
      s3_activeBoot = null;
      s3_frogPos = 0;
      s3_path = [];
      s3_showAll = false;
    } else if (scenario == 4) {
      s4_platePos = 0;
      s4_idliDial = 1;
      s4_vadaDial = 1;
      s4_result = null;
    } else if (scenario == 5) {
      s5_t1 = null;
      s5_t2 = null;
      s5_result = null;
    }
  }
}

class Cl6M_Ch5_A1_ExploringMultiplesandFactors extends StatefulWidget {
  const Cl6M_Ch5_A1_ExploringMultiplesandFactors({super.key});

  @override
  State<Cl6M_Ch5_A1_ExploringMultiplesandFactors> createState() =>
      _Cl6M_Ch5_A1_ExploringMultiplesandFactorsState();
}

class _Cl6M_Ch5_A1_ExploringMultiplesandFactorsState
    extends State<Cl6M_Ch5_A1_ExploringMultiplesandFactors>
    with SingleTickerProviderStateMixin {
  final SimState sim = SimState();
  final GlobalKey _canvasKey = GlobalKey();

  String lang = 'en';
  bool isSidebarOpen = true;
  double sidebarWidth = 350.0;
  bool showCurtain = true;
  bool showSuccessPopup = false;

  double zoom = 1.0;
  Offset pan = Offset.zero;

  double _baseZoom = 1.0;
  Offset _basePan = Offset.zero;

  late AnimationController _gameLoop;

  DateTime _lastS1Tick = DateTime.now();
  DateTime _lastS2Tick = DateTime.now();

  // Audio Players Configuration
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _gameLoop.addListener(_onGameLoopTick);
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

  String t(String key) {
    return Translation[lang]?[key] ?? key;
  }

  void _toggleLanguage() {
    setState(() {
      lang = lang == 'en' ? 'hi' : 'en';
      playClick();
    });
  }

  void _onGameLoopTick() {
    if (!sim.animating) return;
    final now = DateTime.now();

    if (sim.scenario == 1) {
      if (now.difference(_lastS1Tick).inMilliseconds > 300) {
        setState(() {
          _lastS1Tick = now;
          if (sim.s1_platePos < sim.s1_maxPlate) {
            sim.s1_platePos++;

            if (sim.s1_platePos == 15 && sim.step == 1) {
              sim.animating = false; // Auto-pause
              sim.step++;
              playPageOpen();
              Future.delayed(const Duration(milliseconds: 2500), () {
                if (mounted && sim.scenario == 1 && sim.s1_platePos < 30) {
                  setState(() => sim.animating = true);
                }
              });
            } else if (sim.s1_platePos >= 30) {
              sim.animating = false;
              playPageOpen();
              if (sim.step == 2) {
                sim.step++;
                _showSuccess();
              }
            }
          }
        });
      }
    } else if (sim.scenario == 2) {
      if (now.difference(_lastS2Tick).inMilliseconds > 400) {
        setState(() {
          _lastS2Tick = now;
          int sz = sim.s2_activeBoot!;
          if (sim.s2_frogPos + sz <= 24 || (sz == 5 && sim.s2_frogPos == 20)) {
            sim.s2_frogYOffset = 30;
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) setState(() => sim.s2_frogYOffset = 0);
            });
            sim.s2_frogPos += sz;
            sim.s2_path.add(sim.s2_frogPos);
            playClick();
          } else {
            sim.animating = false;
            if (sim.s2_frogPos == 24) {
              playPageOpen();
              if (sim.step == 1 && sz == 4) sim.step++;
            } else {
              playError();
              if (sim.step == 2 && sz == 5) sim.step++;
            }
          }
        });
      }
    } else if (sim.scenario == 3) {
      if (now.difference(_lastS2Tick).inMilliseconds > 400) {
        setState(() {
          _lastS2Tick = now;
          int sz = sim.s3_activeBoot!;
          if (sim.s3_frogPos + sz <= 18 ||
              (sim.s3_frogPos < 18 && sim.s3_frogPos + sz > 18)) {
            sim.s3_frogYOffset = 30;
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) setState(() => sim.s3_frogYOffset = 0);
            });
            sim.s3_frogPos += sz;
            sim.s3_path.add(sim.s3_frogPos);
            playClick();
          } else {
            sim.animating = false;
            if (sim.s3_path.contains(12) && sim.s3_path.contains(18)) {
              playPageOpen();
              if (sim.step == 2 && sz == 3) sim.step++;
            } else {
              playError();
              if (sim.step == 1 && sz == 4) sim.step++;
            }
          }
        });
      }
    } else if (sim.scenario == 4) {
      if (now.difference(_lastS1Tick).inMilliseconds > 100) {
        setState(() {
          _lastS1Tick = now;
          int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
          int lcm =
              (sim.s4_idliDial * sim.s4_vadaDial) ~/
              gcd(sim.s4_idliDial, sim.s4_vadaDial);
          sim.s4_maxPlate = lcm + 2;

          sim.s4_platePos++;
          if (sim.s4_platePos >= lcm) {
            sim.animating = false;
            sim.s4_result = lcm;
            if (lcm == 42) {
              playPageOpen();
              if (sim.step == 2) {
                sim.step++;
                _showSuccess();
              }
            } else {
              playError();
            }
          }
        });
      }
    } else if (sim.scenario == 5) {
      if (now.difference(_lastS2Tick).inMilliseconds > 150) {
        setState(() {
          _lastS2Tick = now;
          if (sim.s5_testJumpSize > 10) {
            sim.animating = false;
            sim.s5_result = 'safe';
            playPageOpen();
            if (sim.step == 2) {
              sim.step++;
              _showSuccess();
            }
            return;
          }

          sim.s5_frogYOffset = 20;
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) setState(() => sim.s5_frogYOffset = 0);
          });
          sim.s5_frogPos += sim.s5_testJumpSize;
          playClick();

          if (sim.s5_frogPos > 30) {
            sim.s5_testJumpSize++;
            sim.s5_frogPos = 0;
            // small pause
            _lastS2Tick = now.add(const Duration(milliseconds: 300));
          } else if (sim.s5_frogPos == sim.s5_t1 ||
              sim.s5_frogPos == sim.s5_t2) {
            if (sim.s5_t1! % sim.s5_testJumpSize == 0 &&
                sim.s5_t2! % sim.s5_testJumpSize == 0) {
              sim.animating = false;
              sim.s5_result = sim.s5_testJumpSize;
              playError();
            }
          }
        });
      }
    }
  }

  void _triggerAction(String action) {
    if (sim.animating) return;
    playClick();
    setState(() {
      if (action == 's1_start') {
        if (sim.s1_platePos >= 30) return;
        sim.animating = true;
        if (sim.step == 0) sim.step++;
      } else if (action == 's2_jump') {
        if (sim.s2_activeBoot == null) return;
        sim.animating = true;
        sim.s2_frogPos = 0;
        sim.s2_path = [0];
      } else if (action == 's3_jump') {
        if (sim.s3_activeBoot == null) return;
        sim.animating = true;
        sim.s3_frogPos = 0;
        sim.s3_path = [0];
      } else if (action == 's4_test') {
        sim.animating = true;
        sim.s4_platePos = 0;
        sim.s4_result = null;
      } else if (action == 's5_test') {
        if (sim.s5_t1 == null || sim.s5_t2 == null) return;
        sim.animating = true;
        sim.s5_testJumpSize = 2;
        sim.s5_frogPos = 0;
        sim.s5_result = null;
      }
    });
  }

  void _showSuccess() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showSuccessPopup = true);
    });
  }

  void _loadScenario(int sc) {
    playDropdown();
    setState(() {
      sim.scenario = sc;
      sim.resetScenario();
      showSuccessPopup = false;
      pan = Offset.zero;
      zoom = 1.0;
    });
  }

  Offset _getCanvasCoordinates(Offset globalPosition) {
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(globalPosition);
    double worldX = (localPos.dx - box.size.width / 2 - pan.dx) / zoom;
    double worldY = (localPos.dy - box.size.height / 2 - pan.dy) / zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  void _onPointerDown(PointerDownEvent details) {
    final pt = _getCanvasCoordinates(details.position);

    setState(() {
      if (sim.scenario == 1) {
        if (_hitTestBox(-60, 80, 120, 50, pt)) _triggerAction('s1_start');
      } else if (sim.scenario == 2) {
        for (int i = 0; i < sim.s2_boots.length; i++) {
          double bx = -150.0 + i * 60;
          double by = -110.0;
          if (_hitTestBox(bx - 20, by - 20, 40, 40, pt)) {
            sim.s2_activeBoot = sim.s2_boots[i];
            playClick();
            if (sim.step == 0 && sim.s2_activeBoot == 4) sim.step++;
          }
        }
        if (_hitTestBox(-60, -50, 120, 40, pt)) _triggerAction('s2_jump');
        if (sim.step == 3 && _hitTestBox(80, -50, 120, 40, pt)) {
          sim.s2_showAll = true;
          playClick();
          sim.step++;
          _showSuccess();
        }
      } else if (sim.scenario == 3) {
        for (int i = 0; i < sim.s3_boots.length; i++) {
          double bx = -150.0 + i * 60;
          double by = -110.0;
          if (_hitTestBox(bx - 20, by - 20, 40, 40, pt)) {
            sim.s3_activeBoot = sim.s3_boots[i];
            playClick();
            if (sim.step == 0 && sim.s3_activeBoot == 4) sim.step++;
          }
        }
        if (_hitTestBox(-60, -50, 120, 40, pt)) _triggerAction('s3_jump');
        if (sim.step == 3 && _hitTestBox(80, -50, 120, 40, pt)) {
          sim.s3_showAll = true;
          playClick();
          sim.step++;
          _showSuccess();
        }
      } else if (sim.scenario == 4) {
        double dY = -50;
        // Dial 1
        if (_hitTestBox(-185, dY, 20, 20, pt)) {
          sim.s4_idliDial = max(1, sim.s4_idliDial - 1);
          playClick();
        }
        if (_hitTestBox(-135, dY, 20, 20, pt)) {
          sim.s4_idliDial = min(42, sim.s4_idliDial + 1);
          playClick();
        }
        if (sim.step == 0 && sim.s4_idliDial > 1 && 42 % sim.s4_idliDial == 0) {
          sim.step++;
        }
        // Dial 2
        if (_hitTestBox(115, dY, 20, 20, pt)) {
          sim.s4_vadaDial = max(1, sim.s4_vadaDial - 1);
          playClick();
        }
        if (_hitTestBox(165, dY, 20, 20, pt)) {
          sim.s4_vadaDial = min(42, sim.s4_vadaDial + 1);
          playClick();
        }
        if (sim.step == 1 && sim.s4_vadaDial > 1) sim.step++;

        if (_hitTestBox(-60, 80, 120, 40, pt)) _triggerAction('s4_test');
      } else if (sim.scenario == 5) {
        double c1X = sim.s5_t1 != null ? -580 + sim.s5_t1! * 40.0 : -100;
        double c1Y = sim.s5_t1 != null ? -30 : 150;
        if (_hitTestBox(c1X - 25, c1Y - 25, 50, 50, pt)) {
          sim.activeDragEntity = 'c1';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          playClick();
        }
        double c2X = sim.s5_t2 != null ? -580 + sim.s5_t2! * 40.0 : 100;
        double c2Y = sim.s5_t2 != null ? -30 : 150;
        if (_hitTestBox(c2X - 25, c2Y - 25, 50, 50, pt)) {
          sim.activeDragEntity = 'c2';
          sim.dragX = pt.dx;
          sim.dragY = pt.dy;
          playClick();
        }
        if (_hitTestBox(-80, 200, 160, 40, pt)) _triggerAction('s5_test');
      }
    });
  }

  void _onPointerMove(PointerMoveEvent details) {
    if (sim.activeDragEntity != null) {
      final pt = _getCanvasCoordinates(details.position);
      setState(() {
        sim.dragX = pt.dx;
        sim.dragY = pt.dy;
      });
    }
  }

  void _onPointerUp(PointerUpEvent details) {
    if (sim.activeDragEntity != null) {
      setState(() {
        if (sim.scenario == 5) {
          if (sim.dragY > -60 &&
              sim.dragY < 20 &&
              sim.dragX > -560 &&
              sim.dragX < -580 + 31 * 40) {
            int tileIdx = ((sim.dragX + 580) / 40).round();
            if (tileIdx >= 1 && tileIdx <= 30) {
              if (sim.activeDragEntity == 'c1') sim.s5_t1 = tileIdx;
              if (sim.activeDragEntity == 'c2') sim.s5_t2 = tileIdx;
              playClick();
              if (sim.step == 0 && sim.s5_t1 != null) sim.step++;
              if (sim.step == 1 && sim.s5_t2 != null) sim.step++;
            } else {
              playError();
              if (sim.activeDragEntity == 'c1') {
                sim.s5_t1 = null;
              } else {
                sim.s5_t2 = null;
              }
            }
          } else {
            playError();
            if (sim.activeDragEntity == 'c1') {
              sim.s5_t1 = null;
            } else {
              sim.s5_t2 = null;
            }
          }
        }
        sim.activeDragEntity = null;
      });
    }
  }

  Widget _buildSidebar(double screenHeight) {
    List<Map<String, String>> steps = [];
    int maxSteps = sim.scenario == 4 || sim.scenario == 5 ? 3 : 4;
    for (int i = 1; i <= maxSteps; i++) {
      steps.add({
        'hud': t('s${sim.scenario}_hud$i'),
        'task': t('s${sim.scenario}_step${i}_task'),
        'out': t('s${sim.scenario}_step${i}_out'),
      });
    }

    return Container(
      width: sidebarWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: const Border(
          right: BorderSide(color: Colors.white24, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 15,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Icon(
                              Icons.science,
                              color: Colors.indigoAccent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t('appTitle'),
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
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: Row(
                                children: [
                                  const Icon(
                                    Icons.language,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    lang.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: _toggleLanguage,
                              tooltip: 'Toggle Language',
                            ),
                            IconButton(
                              icon: Row(
                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    size: 20,
                                    color: Colors.redAccent,
                                  ),
                                  Text(
                                    t('resetBtn'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                playClick();
                                _loadScenario(1);
                              },
                              tooltip: 'Reset Lab',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: sim.scenario,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF0F172A),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            onChanged: (val) {
                              if (val != null) _loadScenario(val);
                            },
                            items: [1, 2, 3, 4, 5]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(t('s${e}_title')),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155).withOpacity(0.5),
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
                              t('s${sim.scenario}_obj'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Steps List
                      ...List.generate(steps.length, (i) {
                        bool isCompleted = i < sim.step;
                        bool isCurrent = i == sim.step;
                        bool isFuture = i > sim.step;

                        Color bgColor = isCurrent
                            ? Colors.indigoAccent.withOpacity(0.1)
                            : (isCompleted
                                  ? Colors.greenAccent.withOpacity(0.05)
                                  : Colors.white.withOpacity(0.02));
                        Color borderColor = isCurrent
                            ? Colors.indigoAccent.withOpacity(0.5)
                            : (isCompleted
                                  ? Colors.greenAccent.withOpacity(0.3)
                                  : Colors.transparent);
                        Color numBg = isCompleted
                            ? Colors.green
                            : (isCurrent
                                  ? Colors.indigoAccent
                                  : Colors.grey.shade800);

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
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: numBg,
                                ),
                                alignment: Alignment.center,
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          color: isFuture
                                              ? Colors.white54
                                              : Colors.white,
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
                                      '${t('stepLabel')} ${i + 1}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isFuture
                                              ? Colors.white54
                                              : Colors.indigo.shade200,
                                          height: 1.4,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Action: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: steps[i]['task']),
                                        ],
                                      ),
                                    ),
                                    if (isCompleted) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.greenAccent,
                                              height: 1.4,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '${t('learnLbl')} ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(text: steps[i]['out']),
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
                      }),
                    ],
                  ),
                ),

                const Spacer(),

                // Footer
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: const Text(
                    '© ZeroScienceLab - Fall in love with math and Science',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    int maxSteps = sim.scenario == 4 || sim.scenario == 5 ? 3 : 4;
    String hudText = '';
    if (sim.step < maxSteps) {
      hudText = t('s${sim.scenario}_hud${sim.step + 1}');
    }

    if (hudText.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: const Border(
              top: BorderSide(color: Colors.indigoAccent, width: 3),
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
              const Icon(Icons.info, color: Colors.indigoAccent),
              const SizedBox(width: 12),
              Text(
                hudText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;

    // Safety clamp for sidebar
    if (sidebarWidth > screenW * 0.6) sidebarWidth = screenW * 0.6;
    if (sidebarWidth < 250) sidebarWidth = 250;

    double canvasLeft = isSidebarOpen ? sidebarWidth : 0;
    double canvasWidth = screenW - canvasLeft;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: canvasLeft,
              top: 0,
              bottom: 0,
              width: canvasWidth,
              child: ClipRect(
                child: Listener(
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerUp,
                  child: GestureDetector(
                    onScaleStart: (details) {
                      // Prevent panning if we are currently dragging a chest
                      if (sim.activeDragEntity != null) return;
                      _baseZoom = zoom;
                      _basePan = pan;
                    },
                    onScaleUpdate: (details) {
                      // Prevent panning if we are currently dragging a chest
                      if (sim.activeDragEntity != null) return;
                      setState(() {
                        zoom = (_baseZoom * details.scale).clamp(0.4, 2.5);
                        pan = _basePan + details.focalPointDelta;
                      });
                    },
                    child: Container(
                      color: const Color(0xFF0F172A),
                      child: Stack(
                        children: [
                          CustomPaint(
                            key: _canvasKey,
                            size: Size.infinite,
                            painter: SimPainter(sim, zoom, pan),
                          ),
                          _buildHUD(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildSidebar(screenH),
                  // Sidebar Resizer Handle
                  Positioned(
                    right: -10,
                    top: 0,
                    bottom: 0,
                    width: 20,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        setState(() {
                          sidebarWidth += details.delta.dx;
                          sidebarWidth = sidebarWidth.clamp(
                            250.0,
                            screenW * 0.6,
                          );
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: Container(
                          color: Colors.transparent,
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
                ],
              ),
            ),

            // MENU TOGGLE
            Positioned(
              left: 16,
              top: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                onPressed: () {
                  playClick();
                  setState(() => isSidebarOpen = !isSidebarOpen);
                },
                child: Icon(
                  isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // SUCCESS POPUP
            if (showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 400,
                      constraints: BoxConstraints(maxHeight: screenH * 0.9),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.emoji_events,
                                size: 40,
                                color: Colors.white,
                              ),
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
                            const SizedBox(height: 12),
                            Text(
                              sim.scenario < 5
                                  ? t('s${sim.scenario}_obj')
                                  : t('finalDesc'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: sim.scenario < 5
                                    ? Colors.indigo.shade200
                                    : Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sim.scenario < 5
                                    ? Colors.indigoAccent
                                    : Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: Icon(
                                sim.scenario < 5
                                    ? Icons.arrow_forward
                                    : Icons.flag,
                                color: Colors.white,
                              ),
                              label: Text(
                                sim.scenario < 5
                                    ? t('nextScenario')
                                    : t('finishLab'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                playClick();
                                if (sim.scenario < 5) {
                                  _loadScenario(sim.scenario + 1);
                                } else {
                                  _loadScenario(1); // Reset
                                  setState(() => showCurtain = true);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // CURTAIN SCREEN
            if (showCurtain)
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
                            border: Border.all(
                              color: Colors.indigoAccent,
                              width: 4,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 50,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t('shutterTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('appSubtitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          onPressed: () {
                            curtainScreen();
                            setState(() => showCurtain = false);
                          },
                          icon: const Icon(Icons.science, color: Colors.white),
                          label: Text(
                            t('enterLab'),
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
          ],
        ),
      ),
    );
  }
}

// --- CANVAS PAINTER ---
class SimPainter extends CustomPainter {
  final SimState sim;
  final double zoom;
  final Offset pan;
  final String lang = 'en'; // Hardcoded fallback for paint labels

  SimPainter(this.sim, this.zoom, this.pan)
    : super(repaint: Listenable.merge([]));

  final Color outlineColor = const Color(0xFF0F172A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom, zoom);

    if (sim.scenario == 1) {
      _renderS1(canvas);
    } else if (sim.scenario == 2) {
      _renderS2(canvas);
    } else if (sim.scenario == 3) {
      _renderS3(canvas);
    } else if (sim.scenario == 4) {
      _renderS4(canvas);
    } else if (sim.scenario == 5) {
      _renderS5(canvas);
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
    Color fill, [
    Color? stroke,
    double strokeW = 1,
  ]) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    if (stroke != null && stroke != Colors.transparent) {
      canvas.drawRRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    bool isBold = false,
  }) {
    final style = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawIdli(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    final rect = Rect.fromCenter(center: Offset.zero, width: 40, height: 30);
    // Use solid color instead of gradient to prevent Web renderer crashes
    canvas.drawOval(rect, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawOval(
      rect,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  void _drawVada(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    final rect = Rect.fromCenter(center: Offset.zero, width: 44, height: 34);
    // Use solid color instead of gradient to prevent Web renderer crashes
    canvas.drawOval(rect, Paint()..color = const Color(0xFFD97706));
    canvas.drawOval(
      rect,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 12, height: 8),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.restore();
  }

  void _drawConveyor(
    Canvas canvas,
    double startX,
    double y,
    double width,
    int plates,
    int platePos,
    int m1,
    int m2,
  ) {
    _drawRoundedRect(
      canvas,
      startX,
      y - 25,
      width,
      50,
      10,
      const Color(0xFF475569),
      outlineColor,
      3,
    );
    _drawRoundedRect(
      canvas,
      startX + 10,
      y - 15,
      width - 20,
      30,
      5,
      const Color(0xFF1E293B),
    );

    double plateSpacing = 60;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(startX + 10, y - 30, width - 20, 60));

    for (int i = 1; i <= plates; i++) {
      double px = startX + width - 40 - (i - platePos) * plateSpacing;
      if (px > startX && px < startX + width) {
        bool isCommon = (i % m1 == 0 && i % m2 == 0);
        Color fill = isCommon
            ? const Color(0xFFFEF08A)
            : const Color(0xFFCBD5E1);
        Color stroke = isCommon ? Colors.amber : outlineColor;
        _drawRoundedRect(
          canvas,
          px - 20,
          y - 18,
          40,
          36,
          18,
          fill,
          stroke,
          isCommon ? 3 : 2,
        );
        _drawText(canvas, i.toString(), px, y, 16, outlineColor, isBold: true);

        if (i <= platePos) {
          if (i % m1 == 0) _drawIdli(canvas, px, y - 25, 0.8);
          if (i % m2 == 0) _drawVada(canvas, px, y + 25, 0.8);
        }
      }
    }
    canvas.restore();

    double dropPos = startX + width - 40;
    _drawRoundedRect(
      canvas,
      dropPos - 30,
      y - 90,
      60,
      40,
      5,
      const Color(0xFFCBD5E1),
      outlineColor,
      3,
    );
    _drawText(canvas, "Idli", dropPos, y - 70, 14, outlineColor, isBold: true);
    _drawRoundedRect(
      canvas,
      dropPos - 30,
      y + 50,
      60,
      40,
      5,
      const Color(0xFFCBD5E1),
      outlineColor,
      3,
    );
    _drawText(canvas, "Vada", dropPos, y + 70, 14, outlineColor, isBold: true);
  }

  void _drawJumpyFrog(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);

    final Paint pFill = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    final Paint pStroke = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Legs
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-15, 10), width: 20, height: 10),
      Paint()..color = Colors.green.shade700,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-15, 10), width: 20, height: 10),
      pStroke,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(15, 10), width: 20, height: 10),
      Paint()..color = Colors.green.shade700,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(15, 10), width: 20, height: 10),
      pStroke,
    );

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 40, height: 30),
      pFill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 40, height: 30),
      pStroke,
    );

    // Eyes
    canvas.drawCircle(const Offset(-10, -12), 6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-10, -12), 6, pStroke);
    canvas.drawCircle(const Offset(10, -12), 6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(10, -12), 6, pStroke);
    canvas.drawCircle(const Offset(-10, -12), 2, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(10, -12), 2, Paint()..color = Colors.black);

    // Smile
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(0, 2), width: 16, height: 16),
      0,
      pi,
      false,
      pStroke,
    );
    canvas.restore();
  }

  void _drawTreasureChest(
    Canvas canvas,
    double x,
    double y,
    double scale,
    bool isOpen,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);

    final pBase = Paint()..color = const Color(0xFF92400E);
    final pStroke = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final pBand = Paint()..color = const Color(0xFFD97706);

    if (isOpen) {
      canvas.drawRect(
        const Rect.fromLTWH(-25, -45, 50, 20),
        Paint()..color = const Color(0xFF78350F),
      );
      canvas.drawRect(const Rect.fromLTWH(-25, -45, 50, 20), pStroke);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -15), width: 40, height: 20),
        Paint()..color = Colors.amber,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -15), width: 40, height: 20),
        pStroke,
      );
    } else {
      canvas.drawArc(
        const Rect.fromLTWH(-25, -35, 50, 50),
        pi,
        pi,
        true,
        Paint()..color = const Color(0xFF78350F),
      );
      canvas.drawArc(
        const Rect.fromLTWH(-25, -35, 50, 50),
        pi,
        pi,
        true,
        pStroke,
      );
    }

    canvas.drawRect(const Rect.fromLTWH(-25, -10, 50, 30), pBase);
    canvas.drawRect(const Rect.fromLTWH(-25, -10, 50, 30), pStroke);

    canvas.drawRect(const Rect.fromLTWH(-20, -10, 5, 30), pBand);
    canvas.drawRect(const Rect.fromLTWH(-20, -10, 5, 30), pStroke);
    canvas.drawRect(const Rect.fromLTWH(15, -10, 5, 30), pBand);
    canvas.drawRect(const Rect.fromLTWH(15, -10, 5, 30), pStroke);

    canvas.drawCircle(
      const Offset(0, -5),
      6,
      Paint()..color = Colors.amberAccent,
    );
    canvas.drawCircle(const Offset(0, -5), 6, pStroke);

    canvas.restore();
  }

  void _drawJumpBoot(
    Canvas canvas,
    double x,
    double y,
    double scale,
    Color color,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);

    Path path = Path();
    path.moveTo(-10, -15);
    path.lineTo(10, -15);
    path.lineTo(12, 5);
    path.lineTo(20, 15);
    path.lineTo(-15, 15);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.restore();
  }

  void _drawInteractiveDial(
    Canvas canvas,
    double x,
    double y,
    int value,
    String label,
  ) {
    _drawRoundedRect(
      canvas,
      x - 60,
      y - 70,
      120,
      140,
      10,
      const Color(0xFF334155),
      outlineColor,
      3,
    );
    _drawText(canvas, label, x, y - 50, 12, Colors.white, isBold: true);

    canvas.drawCircle(
      Offset(x, y + 10),
      40,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawCircle(
      Offset(x, y + 10),
      40,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    _drawText(
      canvas,
      value.toString(),
      x,
      y + 10,
      24,
      Colors.white,
      isBold: true,
    );

    // Left Arrow
    Path leftArrow = Path()
      ..moveTo(x - 25, y + 10)
      ..lineTo(x - 15, y + 5)
      ..lineTo(x - 15, y + 15)
      ..close();
    canvas.drawPath(leftArrow, Paint()..color = const Color(0xFF94A3B8));
    // Right Arrow
    Path rightArrow = Path()
      ..moveTo(x + 25, y + 10)
      ..lineTo(x + 15, y + 5)
      ..lineTo(x + 15, y + 15)
      ..close();
    canvas.drawPath(rightArrow, Paint()..color = const Color(0xFF94A3B8));
  }

  void _renderS1(Canvas canvas) {
    _drawConveyor(
      canvas,
      -400,
      0,
      800,
      sim.s1_maxPlate,
      sim.s1_platePos,
      sim.s1_idliDial,
      sim.s1_vadaDial,
    );

    Color btnC = (!sim.animating && sim.s1_platePos == 0)
        ? Colors.green
        : const Color(0xFF94A3B8);
    _drawRoundedRect(canvas, -60, 80, 120, 50, 25, btnC, outlineColor, 3);
    _drawText(canvas, "START", 0, 105, 18, Colors.white, isBold: true);

    _drawRoundedRect(
      canvas,
      -400,
      80,
      240,
      80,
      10,
      const Color(0xFF334155),
      outlineColor,
      3,
    );
    _drawText(
      canvas,
      "Idli Machine: ${sim.s1_idliDial}",
      -280,
      100,
      16,
      Colors.white,
      isBold: true,
    );
    _drawText(
      canvas,
      "Vada Machine: ${sim.s1_vadaDial}",
      -280,
      130,
      16,
      Colors.white,
      isBold: true,
    );

    if (sim.s1_platePos >= 15 && sim.s1_platePos < 29) {
      double px = -400 + 800 - 40 - (15 - sim.s1_platePos) * 60;
      if (px > -400 && px < 400) {
        _drawRoundedRect(
          canvas,
          px - 75,
          -100,
          150,
          30,
          5,
          const Color(0xFFFEF08A),
          outlineColor,
          2,
        );
        _drawText(
          canvas,
          "Common Multiple!",
          px,
          -85,
          12,
          const Color(0xFFB45309),
          isBold: true,
        );
      }
    }

    if (sim.s1_platePos >= 30) {
      _drawRoundedRect(
        canvas,
        -200,
        -200,
        400,
        120,
        10,
        const Color(0xFF1E293B),
        Colors.white54,
        4,
      );
      _drawText(
        canvas,
        "Multiples of 3: 3, 6, 9, 12, 15, 18, 21, 24, 27, 30",
        0,
        -170,
        14,
        Colors.white,
      );
      _drawText(
        canvas,
        "Multiples of 5: 5, 10, 15, 20, 25, 30",
        0,
        -140,
        14,
        Colors.white,
      );
      _drawText(
        canvas,
        "Common Multiples: 15, 30",
        0,
        -105,
        18,
        Colors.greenAccent,
        isBold: true,
      );
    }
  }

  void _renderS2(Canvas canvas) => _drawJackpot(canvas, 24, null, 25);
  void _renderS3(Canvas canvas) => _drawJackpot(canvas, 12, 18, 19);

  void _drawJackpot(Canvas canvas, int t1, int? t2, int maxNum) {
    double pathX = -450;
    double pathY = 50;

    for (int i = 0; i <= maxNum; i++) {
      double px = pathX + i * 40;
      _drawRoundedRect(
        canvas,
        px - 18,
        pathY - 18,
        36,
        36,
        4,
        const Color(0xFFCBD5E1),
        outlineColor,
        2,
      );
      _drawText(
        canvas,
        i.toString(),
        px,
        pathY,
        16,
        outlineColor,
        isBold: true,
      );
    }

    double t1X = pathX + t1 * 40;
    bool t1Open = sim.scenario == 2
        ? sim.s2_path.contains(t1)
        : sim.s3_path.contains(t1);
    _drawTreasureChest(canvas, t1X, pathY - 30, 1, t1Open);

    double t2X = 0;
    if (t2 != null) {
      t2X = pathX + t2 * 40;
      bool t2Open = sim.s3_path.contains(t2);
      _drawTreasureChest(canvas, t2X, pathY - 30, 1, t2Open);
    }

    double fX =
        pathX + (sim.scenario == 2 ? sim.s2_frogPos : sim.s3_frogPos) * 40;
    double fY =
        pathY -
        20 -
        (sim.scenario == 2 ? sim.s2_frogYOffset : sim.s3_frogYOffset);
    _drawJumpyFrog(canvas, fX, fY, 1.2);

    void drawPaths(List<int> paths, Color color, [bool dashed = false]) {
      if (paths.length < 2) return;
      Path path = Path();
      for (int i = 0; i < paths.length - 1; i++) {
        double startX = pathX + paths[i] * 40;
        double endX = pathX + paths[i + 1] * 40;
        double midX = (startX + endX) / 2;
        double midY = pathY - 80;
        path.moveTo(startX, pathY - 10);
        path.quadraticBezierTo(midX, midY, endX, pathY - 10);
      }
      // Dash not easily supported natively without a package, using simple stroke
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = dashed ? 2 : 4,
      );
    }

    if (sim.scenario == 2) {
      if (sim.s2_showAll) {
        for (int sz in [2, 3, 4, 6, 8]) {
          List<int> tmp = [];
          for (int i = 0; i <= 24; i += sz) {
            tmp.add(i);
          }
          drawPaths(tmp, Colors.green.withOpacity(0.4), true);
        }
      }
      drawPaths(sim.s2_path, Colors.blue);
    } else {
      if (sim.s3_showAll) {
        for (int sz in [2, 3, 6]) {
          List<int> tmp = [];
          for (int i = 0; i <= 18; i += sz) {
            tmp.add(i);
          }
          drawPaths(tmp, Colors.green.withOpacity(0.4), true);
        }
      }
      drawPaths(sim.s3_path, Colors.blue);
    }

    double shelfX = -200;
    double shelfY = -150;
    _drawRoundedRect(
      canvas,
      shelfX,
      shelfY,
      400,
      80,
      5,
      const Color(0xFF78350F),
      outlineColor,
      3,
    );
    _drawText(
      canvas,
      "Jump Boots",
      shelfX + 200,
      shelfY - 15,
      16,
      Colors.white,
      isBold: true,
    );

    List<int> boots = sim.scenario == 2 ? sim.s2_boots : sim.s3_boots;
    int? actB = sim.scenario == 2 ? sim.s2_activeBoot : sim.s3_activeBoot;

    for (int i = 0; i < boots.length; i++) {
      double bx = shelfX + 50 + i * 60;
      double by = shelfY + 40;
      bool isAct = boots[i] == actB;
      if (isAct) {
        _drawRoundedRect(
          canvas,
          bx - 25,
          by - 30,
          50,
          60,
          5,
          Colors.amber.withOpacity(0.2),
          Colors.amber,
          3,
        );
      }
      _drawJumpBoot(canvas, bx, by, 1.5, isAct ? Colors.blue : Colors.red);
      _drawText(
        canvas,
        boots[i].toString(),
        bx,
        by + 20,
        14,
        Colors.white,
        isBold: true,
      );
    }

    Color jumpBtnC = (!sim.animating && actB != null)
        ? Colors.green
        : const Color(0xFF94A3B8);
    _drawRoundedRect(
      canvas,
      -60,
      shelfY + 100,
      120,
      40,
      20,
      jumpBtnC,
      outlineColor,
      3,
    );
    _drawText(canvas, "JUMP!", 0, shelfY + 120, 16, Colors.white, isBold: true);

    if ((sim.scenario == 2 && sim.step == 3) ||
        (sim.scenario == 3 && sim.step == 3)) {
      _drawRoundedRect(
        canvas,
        80,
        shelfY + 100,
        120,
        40,
        20,
        Colors.blue,
        outlineColor,
        3,
      );
      _drawText(
        canvas,
        sim.scenario == 2 ? "Show All" : "Show Common",
        140,
        shelfY + 120,
        14,
        Colors.white,
        isBold: true,
      );
    }

    if (sim.scenario == 3 && sim.s3_path.isNotEmpty && !sim.animating) {
      if (sim.s3_path.contains(12) && sim.s3_path.contains(18)) {
        _drawText(
          canvas,
          "Jackpot!",
          t2X,
          pathY - 80,
          24,
          Colors.amber,
          isBold: true,
        );
      }
    }
  }

  void _renderS4(Canvas canvas) {
    _drawText(
      canvas,
      "Target: First at 42",
      0,
      -200,
      28,
      Colors.amber,
      isBold: true,
    );

    _drawInteractiveDial(canvas, -150, -50, sim.s4_idliDial, "Idli Machine");
    _drawInteractiveDial(canvas, 150, -50, sim.s4_vadaDial, "Vada Machine");

    Color btnC = !sim.animating ? Colors.green : const Color(0xFF94A3B8);
    _drawRoundedRect(canvas, -60, 80, 120, 40, 20, btnC, outlineColor, 3);
    _drawText(canvas, "TEST", 0, 100, 16, Colors.white, isBold: true);

    _drawConveyor(
      canvas,
      -400,
      200,
      800,
      sim.s4_maxPlate,
      sim.s4_platePos,
      sim.s4_idliDial,
      sim.s4_vadaDial,
    );

    if (sim.s4_result != null && !sim.animating) {
      Color bgC = sim.s4_result == 42
          ? const Color(0xFFDCFCE7)
          : const Color(0xFFFEE2E2);
      Color txC = sim.s4_result == 42
          ? const Color(0xFF166534)
          : const Color(0xFF991B1B);
      String msg = sim.s4_result == 42
          ? "SUCCESS! First combo at 42"
          : "MISMATCH! First combo at ${sim.s4_result}";
      _drawRoundedRect(canvas, -150, 260, 300, 50, 10, bgC, outlineColor, 3);
      _drawText(canvas, msg, 0, 285, 16, txC, isBold: true);
    }
  }

  void _renderS5(Canvas canvas) {
    double pathX = -580;
    double pathY = 0;

    for (int i = 1; i <= 30; i++) {
      double px = pathX + i * 40;
      _drawRoundedRect(
        canvas,
        px - 18,
        pathY - 18,
        36,
        36,
        4,
        const Color(0xFFCBD5E1),
        outlineColor,
        2,
      );
      _drawText(
        canvas,
        i.toString(),
        px,
        pathY,
        16,
        outlineColor,
        isBold: true,
      );
    }

    double c1X = sim.s5_t1 != null ? pathX + sim.s5_t1! * 40 : -100;
    double c1Y = sim.s5_t1 != null ? pathY - 30 : 150;
    if (sim.activeDragEntity == 'c1') {
      c1X = sim.dragX;
      c1Y = sim.dragY;
    }
    _drawTreasureChest(canvas, c1X, c1Y, 1, false);

    double c2X = sim.s5_t2 != null ? pathX + sim.s5_t2! * 40 : 100;
    double c2Y = sim.s5_t2 != null ? pathY - 30 : 150;
    if (sim.activeDragEntity == 'c2') {
      c2X = sim.dragX;
      c2Y = sim.dragY;
    }
    _drawTreasureChest(canvas, c2X, c2Y, 1, false);

    Color btnC = (!sim.animating && sim.s5_t1 != null && sim.s5_t2 != null)
        ? Colors.green
        : const Color(0xFF94A3B8);
    _drawRoundedRect(canvas, -80, 200, 160, 40, 20, btnC, outlineColor, 3);
    _drawText(canvas, "CHECK SAFETY", 0, 220, 14, Colors.white, isBold: true);

    if (sim.animating || sim.s5_result != null) {
      _drawText(
        canvas,
        "Testing Jump Size: ${sim.s5_testJumpSize > 10 ? 10 : sim.s5_testJumpSize}",
        0,
        -100,
        18,
        Colors.white,
        isBold: true,
      );

      double fX = pathX + sim.s5_frogPos * 40;
      double fY = pathY - 20 - sim.s5_frogYOffset;
      _drawJumpyFrog(canvas, fX, fY, 1);

      if (!sim.animating && sim.s5_result != null) {
        if (sim.s5_result == 'safe') {
          _drawRoundedRect(
            canvas,
            -100,
            -180,
            200,
            50,
            10,
            const Color(0xFFDCFCE7),
            const Color(0xFF166534),
            3,
          );
          _drawText(
            canvas,
            "SAFE!",
            0,
            -155,
            20,
            const Color(0xFF166534),
            isBold: true,
          );
        } else {
          _drawRoundedRect(
            canvas,
            -150,
            -180,
            300,
            50,
            10,
            const Color(0xFFFEE2E2),
            const Color(0xFF991B1B),
            3,
          );
          _drawText(
            canvas,
            "NOT SAFE! Common Factor: ${sim.s5_result}",
            0,
            -155,
            16,
            const Color(0xFF991B1B),
            isBold: true,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SimPainter oldDelegate) => true;
}
