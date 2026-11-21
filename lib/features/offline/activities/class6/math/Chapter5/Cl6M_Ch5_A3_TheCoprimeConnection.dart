// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'The Co-prime Connection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const Cl6M_Ch5_A3_TheCoprimeConnection(),
    ),
  );
}

// --- LOCALIZATION ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': "The Co-prime Connection",
    'appSubtitle': "Class 6 • UNDERSTANDING CO-PRIME NUMBERS",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'learnLbl': "Objective:",
    'stepLabel': "STEP",
    'nextScenario': "Next Scenario",
    'finishLab': "Finish Lab",
    'summaryTitle': "Goal Reached!",
    'finalDesc':
        "You have successfully explored the concept of co-prime numbers!",

    's1_title': "1. The Gear Grinder",
    's1_obj':
        "Visually understand that numbers that are NOT co-prime share a common 'driver gear' (a common factor other than 1).",
    's1_step1_task':
        "DRAG the 4-tooth Driver Gear from the toolbox and DROP it onto the slot next to Gear A (8).",
    's1_step1_out': "The 4-tooth gear meshes perfectly with the 8-tooth gear.",
    's1_step2_task':
        "DRAG the same 4-tooth Driver Gear and DROP it onto the slot next to Gear B (12).",
    's1_step2_out':
        "The 4-tooth gear also meshes perfectly with the 12-tooth gear.",
    's1_step3_task': "CLICK the 'ANALYZE' button on the panel.",
    's1_step3_out':
        "8 and 12 are NOT co-prime because they share a common factor (4).",
    's1_hud1': "Drag the 4-tooth gear to the 8-tooth gear.",
    's1_hud2': "Now test the 4-tooth gear on the 12-tooth gear.",
    's1_hud3': "Click Analyze.",

    's2_title': "2. Gear Grinder: Safe Pairs",
    's2_obj':
        "Visually understand that co-prime numbers do not share any common 'driver gear' (common factor other than 1).",
    's2_step1_task': "DRAG the 3-tooth Driver Gear to Gear C (9).",
    's2_step1_out': "The 3-tooth gear meshes perfectly.",
    's2_step2_task': "DRAG the 3-tooth Driver Gear to Gear D (16).",
    's2_step2_out': "Fails! Leaves a remainder.",
    's2_step3_task':
        "DRAG the 4-tooth Driver Gear to both Gear C (9) and D (16).",
    's2_step3_out': "Fails for 9, succeeds for 16.",
    's2_step4_task': "CLICK the 'ANALYZE' button.",
    's2_step4_out':
        "9 and 16 are CO-PRIME because their only common factor is 1.",
    's2_hud1': "Test the 3-tooth gear on the 9-tooth gear.",
    's2_hud2': "Test the 3-tooth gear on the 16-tooth gear.",
    's2_hud3': "Test the 4-tooth gear on both gears.",
    's2_hud4': "Click Analyze.",

    's3_title': "3. The Prime Block Factory",
    's3_obj':
        "Understand co-primes by comparing their fundamental prime factor 'building blocks'.",
    's3_step1_task':
        "DRAG the number block '18' into the Prime Factorizer input.",
    's3_step1_out': "18 is broken into prime blocks: 2, 3, 3.",
    's3_step2_task':
        "DRAG the number block '35' into the Prime Factorizer input.",
    's3_step2_out': "35 is broken into prime blocks: 5, 7.",
    's3_step3_task':
        "DRAG any block from the '18' tray into the 'COMMON BLOCKS' area.",
    's3_step3_out': "Block rejected. No matching block for 35.",
    's3_step4_task': "CLICK the 'FINALIZE' button.",
    's3_step4_out':
        "18 and 35 are CO-PRIME because they share no common prime blocks.",
    's3_hud1': "Drag block 18 into the machine.",
    's3_hud2': "Drag block 35 into the machine.",
    's3_hud3': "Drag a block from 18 to the middle.",
    's3_hud4': "Click Finalize.",

    's4_title': "4. The Safe Lock Challenge",
    's4_obj':
        "Apply the concept of common factors to find the correct 'key' to open a lock with numbers 28 and 70.",
    's4_step1_task': "DRAG the '4' Key-Gear to the lock.",
    's4_step1_out': "The key turns 28 but fails to turn 70. Rejected.",
    's4_step2_task': "DRAG the '7' Key-Gear to the lock.",
    's4_step2_out': "SUCCESS! 7 is a common factor of 28 and 70.",
    's4_hud1': "Try the 4 Key-Gear.",
    's4_hud2': "Find the correct common Key-Gear.",

    's5_title': "5. The Star Weaver",
    's5_obj':
        "Discover that a pattern connects all points only when the number of points (15) and the 'gap' number are co-prime.",
    's5_step1_task': "CLICK the 'Gap: 6' button to weave.",
    's5_step1_out': "PATTERN INCOMPLETE. Only 5 pegs connected.",
    's5_step2_task': "CLICK the 'Gap: 7' button to weave.",
    's5_step2_out': "PERFECT STAR! 15 and 7 are co-prime, visiting every peg.",
    's5_hud1': "Select Gap: 6.",
    's5_hud2': "Select Gap: 7.",
  },
  'hi': {
    'shutterTitle': "सह-अभाज्य संबंध",
    'appSubtitle': "कक्षा 6 • सह-अभाज्य संख्याओं को समझना",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'learnLbl': "उद्देश्य:",
    'stepLabel': "चरण",
    'nextScenario': "अगला परिदृश्य",
    'finishLab': "समाप्त करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finalDesc':
        "आपने सह-अभाज्य संख्याओं की अवधारणा का सफलतापूर्वक पता लगाया है!",

    's1_title': "1. गियर ग्राइंडर",
    's1_obj':
        "दृश्य रूप से समझें कि जो संख्याएं सह-अभाज्य नहीं हैं, वे एक सामान्य 'ड्राइवर गियर' साझा करती हैं।",
    's1_step1_task': "4-टूथ गियर को गियर A (8) पर खींचें।",
    's1_step1_out': "4-टूथ गियर पूरी तरह से फिट बैठता है।",
    's1_step2_task': "उसी 4-टूथ गियर को गियर B (12) पर खींचें।",
    's1_step2_out': "यह गियर B पर भी काम करता है।",
    's1_step3_task': "'ANALYZE' बटन पर क्लिक करें।",
    's1_step3_out': "8 और 12 सह-अभाज्य नहीं हैं (सामान्य गुणनखंड 4)।",
    's1_hud1': "4-टूथ गियर को 8-टूथ गियर पर खींचें।",
    's1_hud2': "4-टूथ गियर का परीक्षण 12-टूथ गियर पर करें।",
    's1_hud3': "Analyze पर क्लिक करें।",

    's2_title': "2. गियर ग्राइंडर: सुरक्षित जोड़े",
    's2_obj':
        "समझें कि सह-अभाज्य संख्याएं कोई सामान्य 'ड्राइवर गियर' साझा नहीं करती हैं।",
    's2_step1_task': "3-टूथ गियर को गियर C (9) पर खींचें।",
    's2_step1_out': "3-टूथ गियर पूरी तरह से फिट है।",
    's2_step2_task': "3-टूथ गियर को गियर D (16) पर खींचें।",
    's2_step2_out': "विफल! फिट नहीं होता।",
    's2_step3_task': "4-टूथ गियर को 9 और 16 दोनों पर आज़माएँ।",
    's2_step3_out': "9 के लिए विफल, 16 के लिए सफल।",
    's2_step4_task': "'ANALYZE' बटन पर क्लिक करें।",
    's2_step4_out': "9 और 16 सह-अभाज्य हैं।",
    's2_hud1': "3-टूथ गियर को 9-टूथ गियर पर आज़माएँ।",
    's2_hud2': "3-टूथ गियर को 16-टूथ गियर पर आज़माएँ।",
    's2_hud3': "4-टूथ गियर को दोनों पर आज़माएँ।",
    's2_hud4': "Analyze पर क्लिक करें।",

    's3_title': "3. प्राइम ब्लॉक फैक्ट्री",
    's3_obj':
        "उनके मूल अभाज्य कारक 'बिल्डिंग ब्लॉक्स' की तुलना करके सह-अभाज्य को समझें।",
    's3_step1_task': "'18' नंबर ब्लॉक को मशीन में खींचें।",
    's3_step1_out': "18 टूट गया है: 2, 3, 3।",
    's3_step2_task': "'35' नंबर ब्लॉक को मशीन में खींचें।",
    's3_step2_out': "35 टूट गया है: 5, 7।",
    's3_step3_task':
        "18 के ब्लॉक को बीच में 'COMMON BLOCKS' क्षेत्र में खींचें।",
    's3_step3_out': "अस्वीकृत। कोई मिलान नहीं।",
    's3_step4_task': "'FINALIZE' बटन पर क्लिक करें।",
    's3_step4_out': "18 और 35 सह-अभाज्य हैं क्योंकि कोई सामान्य ब्लॉक नहीं है।",
    's3_hud1': "ब्लॉक 18 को मशीन में खींचें।",
    's3_hud2': "ब्लॉक 35 को मशीन में खींचें।",
    's3_hud3': "18 के ब्लॉक को बीच में खींचें।",
    's3_hud4': "Finalize पर क्लिक करें।",

    's4_title': "4. सेफ लॉक चैलेंज",
    's4_obj':
        "28 और 70 संख्याओं वाले ताले को खोलने के लिए सही 'कुंजी' खोजने के लिए सामान्य गुणनखंडों की अवधारणा लागू करें।",
    's4_step1_task': "'4' की-गियर को ताले पर खींचें।",
    's4_step1_out': "4 केवल 28 को घुमाता है।",
    's4_step2_task': "'7' की-गियर को ताले पर खींचें।",
    's4_step2_out': "सफल! 7 एक सामान्य गुणनखंड है।",
    's4_hud1': "4 की-गियर आज़माएँ।",
    's4_hud2': "सही की-गियर खोजें।",

    's5_title': "5. स्टार वीवर",
    's5_obj':
        "खोजें कि एक पैटर्न सभी बिंदुओं को केवल तभी जोड़ता है जब बिंदु (15) और 'गैप' सह-अभाज्य हों।",
    's5_step1_task': "'Gap: 6' बटन पर क्लिक करें।",
    's5_step1_out': "अधूरा! केवल 5 खूंटे जुड़े।",
    's5_step2_task': "'Gap: 7' बटन पर क्लिक करें।",
    's5_step2_out': "परफेक्ट स्टार! 15 और 7 सह-अभाज्य हैं।",
    's5_hud1': "Gap: 6 चुनें।",
    's5_hud2': "Gap: 7 चुनें।",
  },
};

class ScenarioConfig {
  final String title;
  final String objective;
  final List<Map<String, String>> steps;
  ScenarioConfig({
    required this.title,
    required this.objective,
    required this.steps,
  });
}

ScenarioConfig getScenarioConfig(int id, String lang) {
  var t = (String key) => i18n[lang]?[key] ?? i18n['en']![key]!;
  int numSteps = id == 1 ? 3 : (id == 2 ? 4 : (id == 3 ? 4 : 2));
  List<Map<String, String>> steps = [];
  for (int i = 1; i <= numSteps; i++) {
    steps.push({
      'hud': t('s${id}_hud$i'),
      'task': t('s${id}_step${i}_task'),
      'outcome': t('s${id}_step${i}_out'),
    });
  }
  return ScenarioConfig(
    title: t('s${id}_title'),
    objective: t('s${id}_obj'),
    steps: steps,
  );
}

extension ListAdd<T> on List<T> {
  void push(T element) => add(element);
}

// --- APP STATE & LOGIC ---
class Cl6M_Ch5_A3_TheCoprimeConnection extends StatefulWidget {
  const Cl6M_Ch5_A3_TheCoprimeConnection({Key? key}) : super(key: key);
  @override
  _Cl6M_Ch5_A3_TheCoprimeConnectionState createState() =>
      _Cl6M_Ch5_A3_TheCoprimeConnectionState();
}

class _Cl6M_Ch5_A3_TheCoprimeConnectionState
    extends State<Cl6M_Ch5_A3_TheCoprimeConnection>
    with TickerProviderStateMixin {
  // UI State
  bool isCurtainOpen = true;
  bool isSidebarOpen = true;
  double sidebarWidth = 350.0;
  String lang = 'en';

  // Game Logic State
  int currentScenario = 1;
  int currentStep = 0;

  // Simulation variables
  bool animating = false;
  double animProgress = 0.0;
  String? activeTest;
  String? activeDragEntity;
  Offset dragPos = Offset.zero;

  // Scenario 1 Flags
  bool s1TestedA = false, s1TestedB = false, s1Analyzed = false;
  // Scenario 2 Flags
  bool s2TestedC3 = false,
      s2TestedD3 = false,
      s2TestedC4 = false,
      s2TestedD4 = false,
      s2Analyzed = false;
  // Scenario 3 Flags
  bool s3_18in = false,
      s3_35in = false,
      s3TestedCompare = false,
      s3Finalized = false;
  // Scenario 4 Flags
  bool s4Unlocked = false;
  int? s4ActiveKey;
  // Scenario 5 Flags
  int s5Gap = 0;
  List<int> s5PegHit = [];
  List<int> s5WeavingPath = [];

  // Canvas View State
  double panX = 0, panY = 0;
  double zoom = 1.0;
  double _baseZoom = 1.0;
  bool isLocked = true;
  final GlobalKey _canvasKey = GlobalKey();

  // Animation Controllers
  late AnimationController _tickController;
  late AnimationController _actionController;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _actionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _actionController.addListener(() {
      setState(() {
        animProgress = _actionController.value;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => resetView());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _tickController.dispose();
    _actionController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void playSound(String type) {
    String url = '';
    switch (type) {
      case 'success':
        url = 'audio/class6/math/mixkit_2013.mp3';
        break;
      case 'error':
        url = 'audio/class6/math/mixkit_2997.mp3';
        break;
      case 'tick':
        url = 'audio/class6/math/click.mp3';
        break;
      case 'snap':
        url = 'audio/class6/math/mixkit_2688.mp3';
        break;
    }
    if (url.isNotEmpty) {
      _audioPlayer.play(AssetSource(url));
    }
  }

  void tLang() => setState(() => lang = lang == 'en' ? 'hi' : 'en');
  String t(String key) => i18n[lang]?[key] ?? i18n['en']![key]!;

  void resetView() {
    panX = 0;
    panY = 0;
    zoom = 1.0;
  }

  void loadScenario(int id) {
    setState(() {
      currentScenario = id;
      currentStep = 0;
      animating = false;
      animProgress = 0;
      activeDragEntity = null;
      activeTest = null;

      s1TestedA = s1TestedB = s1Analyzed = false;
      s2TestedC3 = s2TestedD3 = s2TestedC4 = s2TestedD4 = s2Analyzed = false;
      s3_18in = s3_35in = s3TestedCompare = s3Finalized = false;
      s4Unlocked = false;
      s4ActiveKey = null;
      s5Gap = 0;
      s5PegHit = [];
      s5WeavingPath = [];
      resetView();
    });
  }

  void runActionAnimation(
    int durationMs,
    String testName,
    VoidCallback onComplete,
  ) {
    setState(() {
      animating = true;
      activeTest = testName;
      _actionController.duration = Duration(milliseconds: durationMs);
    });
    playSound('tick');
    _actionController.forward(from: 0).then((_) {
      setState(() => animating = false);
      onComplete();
    });
  }

  void advanceStep() {
    setState(() {
      currentStep++;
    });
  }

  // Input mapping
  Offset screenToWorld(Offset screenPt) {
    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    Size size = box.size;
    double wx = (screenPt.dx - size.width / 2 - panX) / zoom;
    double wy = (screenPt.dy - size.height / 2 - panY) / zoom;
    return Offset(wx, wy);
  }

  bool hitTestCircle(Offset center, double radius, Offset pt) {
    return (pt.dx - center.dx) * (pt.dx - center.dx) +
            (pt.dy - center.dy) * (pt.dy - center.dy) <=
        radius * radius;
  }

  bool hitTestBox(Rect rect, Offset pt) {
    return rect.contains(pt);
  }

  bool _checkButtonClicks(Offset worldPt) {
    if (currentScenario == 1) {
      if (currentStep == 2 &&
          hitTestBox(const Rect.fromLTWH(-100, 100, 200, 60), worldPt) &&
          s1TestedB &&
          !s1Analyzed) {
        setState(() {
          s1Analyzed = true;
        });
        playSound('success');
        advanceStep();
        return true;
      }
    } else if (currentScenario == 2) {
      if (currentStep == 3 &&
          hitTestBox(const Rect.fromLTWH(-100, 100, 200, 60), worldPt) &&
          !s2Analyzed) {
        setState(() {
          s2Analyzed = true;
        });
        playSound('success');
        advanceStep();
        return true;
      }
    } else if (currentScenario == 3) {
      if (currentStep == 3 &&
          hitTestBox(const Rect.fromLTWH(300, 300, 160, 60), worldPt) &&
          !s3Finalized) {
        setState(() {
          s3Finalized = true;
        });
        playSound('success');
        advanceStep();
        return true;
      }
    } else if (currentScenario == 5) {
      if (!animating) {
        List<int> gaps = [3, 6, 7, 10];
        for (int i = 0; i < gaps.length; i++) {
          if (hitTestBox(
            Rect.fromLTWH(-250.0 + i * 165 - 60, 260 - 25, 120, 50),
            worldPt,
          )) {
            triggerS5Weave(gaps[i]);
            return true;
          }
        }
      }
    }
    return false;
  }

  void _onTapUp(TapUpDetails details) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    if (animating) return;
    Offset worldPt = screenToWorld(details.localPosition);

    if (_checkButtonClicks(worldPt)) return;

    // Handle quick tapping to select keys in Scenario 4
    if (currentScenario == 4 && !s4Unlocked) {
      List<int> keys = [2, 4, 5, 7, 14];
      for (int i = 0; i < keys.length; i++) {
        if (hitTestCircle(Offset(-200.0 + i * 100, 270), 40, worldPt)) {
          setState(() {
            if (s4ActiveKey == keys[i])
              s4ActiveKey = null;
            else
              s4ActiveKey = keys[i];
          });
          playSound('tick');
          return;
        }
      }
    }
  }

  // Touch Handlers
  void _onScaleStart(ScaleStartDetails details) {
    if (animating) return;
    _baseZoom = zoom;
    Offset worldPt = screenToWorld(details.localFocalPoint);

    // Checks if the drag starts over a button
    if (_checkButtonClicks(worldPt)) return;

    bool hit = false;
    if (currentScenario == 1) {
      if (!s1Analyzed) {
        Offset g4 = (!s1TestedA)
            ? const Offset(0, 280)
            : (!s1TestedB ? const Offset(-200, 20) : const Offset(200, 60));
        if (hitTestCircle(g4, 40, worldPt)) {
          setState(() {
            activeDragEntity = 'gear_4';
            dragPos = worldPt;
          });
          playSound('tick');
          hit = true;
        }
      }
    } else if (currentScenario == 2) {
      if (!s2Analyzed) {
        if (!s2TestedD3) {
          Offset g3 = s2TestedC3
              ? const Offset(-200, 20)
              : const Offset(-50, 280);
          if (hitTestCircle(g3, 40, worldPt)) {
            setState(() {
              activeDragEntity = 'gear_3';
              dragPos = worldPt;
            });
            playSound('tick');
            hit = true;
          }
        }
        if (!hit && s2TestedD3 && !s2TestedD4) {
          Offset g4 = s2TestedC4
              ? const Offset(-200, 30)
              : const Offset(50, 280);
          if (hitTestCircle(g4, 40, worldPt)) {
            setState(() {
              activeDragEntity = 'gear_4';
              dragPos = worldPt;
            });
            playSound('tick');
            hit = true;
          }
        }
      }
    } else if (currentScenario == 3) {
      if (!s3Finalized) {
        if (!s3_18in &&
            hitTestBox(const Rect.fromLTWH(-320, -220, 60, 60), worldPt)) {
          setState(() {
            activeDragEntity = 'block18';
            dragPos = worldPt;
          });
          playSound('tick');
          hit = true;
        }
        if (!hit &&
            !s3_35in &&
            hitTestBox(const Rect.fromLTWH(280, -220, 60, 60), worldPt)) {
          setState(() {
            activeDragEntity = 'block35';
            dragPos = worldPt;
          });
          playSound('tick');
          hit = true;
        }
        if (!hit && s3_18in) {
          if (hitTestBox(const Rect.fromLTWH(-190, 120, 40, 40), worldPt)) {
            setState(() {
              activeDragEntity = 'p2_1';
              dragPos = worldPt;
            });
            playSound('tick');
            hit = true;
          } else if (hitTestBox(
            const Rect.fromLTWH(-140, 120, 40, 40),
            worldPt,
          )) {
            setState(() {
              activeDragEntity = 'p3_1';
              dragPos = worldPt;
            });
            playSound('tick');
            hit = true;
          } else if (hitTestBox(
            const Rect.fromLTWH(-90, 120, 40, 40),
            worldPt,
          )) {
            setState(() {
              activeDragEntity = 'p3_2';
              dragPos = worldPt;
            });
            playSound('tick');
            hit = true;
          }
        }
      }
    } else if (currentScenario == 4) {
      if (!s4Unlocked) {
        List<int> keys = [2, 4, 5, 7, 14];
        for (int i = 0; i < keys.length; i++) {
          if (hitTestCircle(Offset(-200.0 + i * 100, 270), 40, worldPt)) {
            setState(() {
              activeDragEntity = 'key_${keys[i]}';
              dragPos = worldPt;
              if (s4ActiveKey == keys[i]) s4ActiveKey = null;
            });
            playSound('tick');
            hit = true;
            break;
          }
        }
        if (!hit &&
            s4ActiveKey != null &&
            hitTestCircle(const Offset(0, -50), 40, worldPt)) {
          setState(() {
            activeDragEntity = 'key_$s4ActiveKey';
            dragPos = worldPt;
            s4ActiveKey = null;
          });
          playSound('tick');
          hit = true;
        }
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (activeDragEntity != null) {
      setState(() {
        dragPos = screenToWorld(details.localFocalPoint);
      });
    } else {
      setState(() {
        panX += details.focalPointDelta.dx;
        panY += details.focalPointDelta.dy;
        zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (activeDragEntity != null) {
      Offset pt = dragPos;
      if (currentScenario == 1) {
        if (activeDragEntity == 'gear_4') {
          if (!s1TestedA && hitTestCircle(const Offset(-200, 20), 100, pt)) {
            runActionAnimation(1000, 'A', () {
              setState(() {
                s1TestedA = true;
              });
              playSound('success');
              advanceStep();
            });
          } else if (s1TestedA &&
              !s1TestedB &&
              hitTestCircle(const Offset(200, 60), 100, pt)) {
            runActionAnimation(1000, 'B', () {
              setState(() {
                s1TestedB = true;
              });
              playSound('success');
              advanceStep();
            });
          } else
            playSound('error');
        }
      } else if (currentScenario == 2) {
        if (activeDragEntity == 'gear_3') {
          if (!s2TestedC3 && hitTestCircle(const Offset(-200, 20), 100, pt)) {
            runActionAnimation(1000, 'C3', () {
              setState(() => s2TestedC3 = true);
              playSound('success');
              advanceStep();
            });
          } else if (s2TestedC3 &&
              !s2TestedD3 &&
              hitTestCircle(const Offset(200, 90), 100, pt)) {
            runActionAnimation(1500, 'D3', () {
              setState(() => s2TestedD3 = true);
              playSound('error');
              advanceStep();
            });
          } else
            playSound('error');
        } else if (activeDragEntity == 'gear_4') {
          if (!s2TestedC4 && hitTestCircle(const Offset(-200, 30), 100, pt)) {
            runActionAnimation(1500, 'C4', () {
              setState(() => s2TestedC4 = true);
              playSound('error');
            });
          } else if (s2TestedC4 &&
              !s2TestedD4 &&
              hitTestCircle(const Offset(200, 100), 100, pt)) {
            runActionAnimation(1000, 'D4', () {
              setState(() => s2TestedD4 = true);
              playSound('success');
              advanceStep();
            });
          } else
            playSound('error');
        }
      } else if (currentScenario == 3) {
        if (activeDragEntity == 'block18') {
          if (hitTestCircle(const Offset(0, -120), 100, pt)) {
            runActionAnimation(1000, 'M18', () {
              setState(() => s3_18in = true);
              playSound('snap');
              advanceStep();
            });
          } else
            playSound('error');
        } else if (activeDragEntity == 'block35') {
          if (hitTestCircle(const Offset(0, -120), 100, pt)) {
            runActionAnimation(1000, 'M35', () {
              setState(() => s3_35in = true);
              playSound('snap');
              advanceStep();
            });
          } else
            playSound('error');
        } else if (activeDragEntity!.startsWith('p')) {
          if (hitTestBox(const Rect.fromLTWH(-100, 270, 200, 110), pt)) {
            runActionAnimation(800, 'REJECT', () {
              setState(() => s3TestedCompare = true);
              playSound('error');
              advanceStep();
            });
          } else
            playSound('error');
        }
      } else if (currentScenario == 4) {
        if (hitTestCircle(const Offset(0, -50), 100, pt)) {
          int k = int.parse(activeDragEntity!.split('_')[1]);
          setState(() {
            s4ActiveKey = k;
          });
          if (k == 7) {
            runActionAnimation(1500, 'K7', () {
              setState(() => s4Unlocked = true);
              playSound('success');
              advanceStep();
            });
          } else if (k == 4) {
            runActionAnimation(1000, 'K4', () {
              playSound('error');
              advanceStep();
            });
          } else {
            runActionAnimation(1000, 'FAIL', () {
              playSound('error');
            });
          }
        } else
          playSound('error');
      }
      setState(() {
        activeDragEntity = null;
      });
    }
  }

  void triggerS5Weave(int gap) {
    setState(() {
      s5Gap = gap;
      animating = true;
      s5PegHit = [0];
      s5WeavingPath = [0];
      activeTest = 'WEAVE';
    });
    playSound('tick');

    int curPeg = 0;
    _weaveStep(gap, curPeg);
  }

  void _weaveStep(int gap, int curPeg) {
    if (!animating) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        int nextPeg = (curPeg + gap) % 15;
        s5WeavingPath.add(nextPeg);
        if (!s5PegHit.contains(nextPeg)) s5PegHit.add(nextPeg);
        playSound('snap');

        if (nextPeg == 0) {
          animating = false;
          if (s5PegHit.length == 15) {
            playSound('success');
            if (currentStep == 1) advanceStep();
          } else {
            playSound('error');
            if (currentStep == 0) advanceStep();
          }
        } else {
          _weaveStep(gap, nextPeg);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTapUp: _onTapUp,
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: ClipRect(
                        child: AnimatedBuilder(
                          animation: _tickController,
                          builder: (context, _) {
                            return CustomPaint(
                              key: _canvasKey,
                              painter: LabPainter(
                                state: this,
                                config: getScenarioConfig(
                                  currentScenario,
                                  lang,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // HUD Overlay
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Builder(
                        builder: (ctx) {
                          var cfg = getScenarioConfig(currentScenario, lang);
                          if (currentStep < cfg.steps.length) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0F172A,
                                ).withOpacity(0.95),
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
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      cfg.steps[currentStep]['hud'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),

                  // Next / Finish Button Overlay
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Builder(
                        builder: (ctx) {
                          var cfg = getScenarioConfig(currentScenario, lang);
                          if (currentStep >= cfg.steps.length) {
                            bool isLast = currentScenario == 5;
                            return ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLast
                                    ? Colors.amber[600]
                                    : Colors.indigo[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                              onPressed: () {
                                if (isLast) {
                                  setState(() {
                                    loadScenario(1);
                                    isCurtainOpen = true;
                                  });
                                } else {
                                  loadScenario(currentScenario + 1);
                                }
                              },
                              icon: Icon(
                                isLast ? Icons.flag : Icons.arrow_forward,
                              ),
                              label: Text(
                                isLast ? t('finishLab') : t('nextScenario'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white12, width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 66,
                              bottom: 16,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.science,
                                      color: Colors.indigoAccent,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t('shutterTitle'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.visible,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            t('appSubtitle'),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                            ),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigoAccent
                                            .withOpacity(0.2),
                                        foregroundColor: Colors.indigoAccent,
                                        elevation: 0,
                                      ),
                                      icon: const Icon(
                                        Icons.language,
                                        size: 16,
                                      ),
                                      label: Text(
                                        lang.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: tLang,
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent
                                            .withOpacity(0.2),
                                        foregroundColor: Colors.redAccent,
                                        elevation: 0,
                                      ),
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: const Text(
                                        "Reset",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () => loadScenario(1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Body
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: currentScenario,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        items: [1, 2, 3, 4, 5]
                                            .map(
                                              (id) => DropdownMenuItem(
                                                value: id,
                                                child: Text(t('s${id}_title')),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) loadScenario(val);
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.indigo.withOpacity(0.3),
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
                                              color: Colors.pinkAccent,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              t('learnLbl'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.yellowAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          getScenarioConfig(
                                            currentScenario,
                                            lang,
                                          ).objective,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  ...List.generate(
                                    getScenarioConfig(
                                      currentScenario,
                                      lang,
                                    ).steps.length,
                                    (i) {
                                      var step = getScenarioConfig(
                                        currentScenario,
                                        lang,
                                      ).steps[i];
                                      bool isCompleted = i < currentStep;
                                      bool isCurrent = i == currentStep;

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? Colors.indigo.withOpacity(0.1)
                                              : (isCompleted
                                                    ? Colors.green.withOpacity(
                                                        0.05,
                                                      )
                                                    : Colors.white.withOpacity(
                                                        0.02,
                                                      )),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isCurrent
                                                ? Colors.indigoAccent
                                                : (isCompleted
                                                      ? Colors.green
                                                            .withOpacity(0.3)
                                                      : Colors.white12),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: isCompleted
                                                    ? Colors.green
                                                    : (isCurrent
                                                          ? Colors.indigoAccent
                                                          : Colors.white24),
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: isCompleted
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  : Text(
                                                      '${i + 1}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
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
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white54,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    step['task']!,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: isCurrent
                                                          ? Colors.indigo[200]
                                                          : Colors.white70,
                                                      fontWeight: isCurrent
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
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
                                                        color:
                                                            (step['outcome']!
                                                                    .contains(
                                                                      'Fails',
                                                                    ) ||
                                                                step['outcome']!
                                                                    .contains(
                                                                      'rejected',
                                                                    ) ||
                                                                step['outcome']!
                                                                    .contains(
                                                                      'INCOMPLETE',
                                                                    ))
                                                            ? Colors.red
                                                                  .withOpacity(
                                                                    0.1,
                                                                  )
                                                            : Colors.green
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        step['outcome']!,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white70,
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
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            color: const Color(0xFF0B1120),
                            alignment: Alignment.center,
                            child: const Text(
                              '© ZeroScienceLab - Fall in love with math and Science',
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
                ),
              ),
            ),

            // Sidebar Resize Handle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth - 10 : -20,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  if (isSidebarOpen) {
                    setState(() {
                      sidebarWidth = (sidebarWidth + details.delta.dx).clamp(
                        250.0,
                        MediaQuery.of(context).size.width * 0.6,
                      );
                    });
                  }
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Menu Toggle
            Positioned(
              top: 10,
              left: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                child: Icon(
                  isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => isSidebarOpen = !isSidebarOpen),
              ),
            ),

            // Curtain Raiser
            if (isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.all_inclusive,
                          size: 80,
                          color: Colors.indigoAccent,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t('shutterTitle'),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(
                            t('enterLab'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            playSound('success');
                            setState(() => isCurtainOpen = false);
                          },
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
class LabPainter extends CustomPainter {
  final _Cl6M_Ch5_A3_TheCoprimeConnectionState state;
  final ScenarioConfig config;
  LabPainter({required this.state, required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F172A),
    );

    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom);

    if (state.currentScenario == 1) _renderS1(canvas);
    if (state.currentScenario == 2) _renderS2(canvas);
    if (state.currentScenario == 3) _renderS3(canvas);
    if (state.currentScenario == 4) _renderS4(canvas);
    if (state.currentScenario == 5) _renderS5(canvas);

    canvas.restore();
  }

  void _drawRoundedRect(
    Canvas canvas,
    Rect rect,
    double radius,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    if (fill != Colors.transparent)
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    if (strokeW > 0)
      canvas.drawRRect(
        rrect,
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
    double width, {
    bool dashed = false,
  }) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (dashed) {
      double d = 0.0;
      double len = (p1 - p2).distance;
      while (d < len) {
        canvas.drawLine(
          Offset.lerp(p1, p2, d / len)!,
          Offset.lerp(p1, p2, (d + 8) / len)!,
          paint,
        );
        d += 16;
      }
    } else {
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color fill, [
    Color stroke = Colors.transparent,
    double strokeW = 0,
  ]) {
    final style = TextStyle(
      color: fill,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: 'Plus Jakarta Sans',
    );
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();

    if (strokeW > 0) {
      final outlineStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Plus Jakarta Sans',
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..color = stroke,
      );
      final tpOut = TextPainter(
        text: TextSpan(text: text, style: outlineStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tpOut.layout();
      tpOut.paint(canvas, center - Offset(tpOut.width / 2, tpOut.height / 2));
    }
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawGear(
    Canvas canvas,
    Offset center,
    double radius,
    int teeth,
    double rotation,
    Color color,
    String label,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    Paint stroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Path path = Path();
    int numPts = teeth * 2;
    double inR = radius * 0.8;
    for (int i = 0; i < numPts; i++) {
      double a = (i * pi * 2) / numPts;
      double r = (i % 2 == 0) ? radius : inR;
      if (i == 0)
        path.moveTo(r * cos(a), r * sin(a));
      else
        path.lineTo(r * cos(a), r * sin(a));
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    canvas.drawCircle(
      Offset.zero,
      radius * 0.4,
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawCircle(Offset.zero, radius * 0.4, stroke);
    canvas.drawCircle(
      Offset.zero,
      radius * 0.15,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(Offset.zero, radius * 0.15, stroke);

    canvas.restore();
    if (label.isNotEmpty)
      _drawText(
        canvas,
        label,
        center,
        24,
        Colors.white,
        const Color(0xFF0F172A),
        3,
      );
  }

  Color _shadeColor(Color color, int percent) {
    int r = (color.red * (100 + percent) / 100).round().clamp(0, 255);
    int g = (color.green * (100 + percent) / 100).round().clamp(0, 255);
    int b = (color.blue * (100 + percent) / 100).round().clamp(0, 255);
    return Color.fromARGB(255, r, g, b);
  }

  void _drawCube(
    Canvas canvas,
    Offset center,
    double size,
    String text,
    Color color,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    Paint stroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Top
    Path t = Path()
      ..moveTo(0, size * 0.5)
      ..lineTo(-size, 0)
      ..lineTo(0, -size * 0.5)
      ..lineTo(size, 0)
      ..close();
    canvas.drawPath(t, Paint()..color = color);
    canvas.drawPath(t, stroke);
    // Left
    Path l = Path()
      ..moveTo(-size, 0)
      ..lineTo(0, size * 0.5)
      ..lineTo(0, size * 1.5)
      ..lineTo(-size, size)
      ..close();
    canvas.drawPath(l, Paint()..color = _shadeColor(color, -20));
    canvas.drawPath(l, stroke);
    // Right
    Path r = Path()
      ..moveTo(0, size * 0.5)
      ..lineTo(size, 0)
      ..lineTo(size, size)
      ..lineTo(0, size * 1.5)
      ..close();
    canvas.drawPath(r, Paint()..color = _shadeColor(color, -40));
    canvas.drawPath(r, stroke);

    _drawText(canvas, text, Offset(0, size * 0.5), 28, Colors.white);
    canvas.restore();
  }

  // --- Scenarios Rendering ---
  void _renderS1(Canvas canvas) {
    Offset gA = const Offset(-200, -100);
    Offset gB = const Offset(200, -100);

    _drawRoundedRect(
      canvas,
      Rect.fromCenter(
        center: gA + const Offset(0, 100),
        width: 240,
        height: 20,
      ),
      10,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );
    _drawRoundedRect(
      canvas,
      Rect.fromCenter(
        center: gB + const Offset(0, 100),
        width: 240,
        height: 20,
      ),
      10,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );

    double rotA = state.animating && state.activeTest == 'A'
        ? state.animProgress * pi * 4
        : 0;
    double rotB = state.animating && state.activeTest == 'B'
        ? state.animProgress * pi * 6
        : 0;
    double rotD = state.animating ? -state.animProgress * pi * 8 : 0;

    _drawGear(canvas, gA, 80, 8, rotA, Colors.blueAccent, '8');
    _drawGear(canvas, gB, 120, 12, rotB, Colors.teal, '12');

    // Toolbox
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-150, 200, 300, 120),
      10,
      Colors.amber[700]!,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, "Driver Gears", const Offset(0, 230), 18, Colors.white);

    if (state.activeDragEntity == 'gear_4') {
      _drawGear(canvas, state.dragPos, 40, 4, rotD, Colors.pinkAccent, '4');
    } else if (state.s1Analyzed) {
      // Handled below
    } else if (state.s1TestedB) {
      _drawGear(
        canvas,
        gB + const Offset(0, 160),
        40,
        4,
        rotD,
        Colors.pinkAccent,
        '4',
      );
    } else if (state.s1TestedA) {
      _drawGear(
        canvas,
        gA + const Offset(0, 120),
        40,
        4,
        rotD,
        Colors.pinkAccent,
        '4',
      );
    } else {
      _drawGear(canvas, const Offset(0, 280), 40, 4, 0, Colors.pinkAccent, '4');
    }

    _drawGear(canvas, const Offset(-80, 280), 30, 3, 0, Colors.blueGrey, '3');
    _drawGear(canvas, const Offset(80, 280), 20, 2, 0, Colors.blueGrey, '2');

    if (!state.s1TestedA)
      _drawLine(
        canvas,
        gA + const Offset(-45, 120),
        gA + const Offset(45, 120),
        Colors.amber,
        4,
        dashed: true,
      ); // simplified dropzone
    if (state.s1TestedA && !state.s1TestedB)
      _drawLine(
        canvas,
        gB + const Offset(-45, 160),
        gB + const Offset(45, 160),
        Colors.amber,
        4,
        dashed: true,
      );

    if (state.currentStep == 2 && state.s1TestedB) {
      Color btnC = state.s1Analyzed ? Colors.blueGrey : Colors.blueAccent;
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-100, 100, 200, 60),
        30,
        btnC,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(canvas, "ANALYZE", const Offset(0, 130), 20, Colors.white);
    }

    if (state.s1Analyzed) {
      _drawGear(canvas, const Offset(0, -40), 40, 4, 0, Colors.pinkAccent, '4');
      _drawLine(
        canvas,
        const Offset(0, -40),
        gA,
        Colors.redAccent,
        4,
        dashed: true,
      );
      _drawLine(
        canvas,
        const Offset(0, -40),
        gB,
        Colors.redAccent,
        4,
        dashed: true,
      );

      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-200, 350, 400, 80),
        10,
        const Color(0xFFFEF2F2),
        Colors.redAccent,
        4,
      );
      _drawText(
        canvas,
        "NOT CO-PRIME",
        const Offset(0, 375),
        24,
        Colors.redAccent,
      );
      _drawText(
        canvas,
        "8 and 12 share a common factor (4).",
        const Offset(0, 405),
        16,
        Colors.red[900]!,
      );
    }
  }

  void _renderS2(Canvas canvas) {
    Offset gC = const Offset(-200, -100);
    Offset gD = const Offset(200, -100);

    _drawRoundedRect(
      canvas,
      Rect.fromCenter(
        center: gC + const Offset(0, 100),
        width: 240,
        height: 20,
      ),
      10,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );
    _drawRoundedRect(
      canvas,
      Rect.fromCenter(
        center: gD + const Offset(0, 120),
        width: 280,
        height: 20,
      ),
      10,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );

    double rotC = state.animating && state.activeTest == 'C3'
        ? state.animProgress * pi * 6
        : 0;
    double rotD = state.animating && state.activeTest == 'D4'
        ? state.animProgress * pi * 8
        : 0;
    double rotDfail = state.animating && state.activeTest == 'D3'
        ? state.animProgress * pi * 4
        : 0;
    double rotCfail = state.animating && state.activeTest == 'C4'
        ? state.animProgress * pi * 2
        : 0;
    double rotDr = 0;
    if (state.activeTest == 'C3') rotDr = -state.animProgress * pi * 18;
    if (state.activeTest == 'D4') rotDr = -state.animProgress * pi * 32;

    _drawGear(canvas, gC, 90, 9, rotC + rotCfail, Colors.purpleAccent, '9');
    _drawGear(canvas, gD, 160, 16, rotD + rotDfail, Colors.cyan, '16');

    if (state.activeTest == 'D3' && state.animProgress > 0.8)
      _drawText(
        canvas,
        "JAMS!",
        gD + const Offset(-80, 180),
        24,
        Colors.redAccent,
      );
    if (state.activeTest == 'C4' && state.animProgress > 0.8)
      _drawText(
        canvas,
        "JAMS!",
        gC + const Offset(-80, 140),
        24,
        Colors.redAccent,
      );

    // Toolbox
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-150, 200, 300, 120),
      10,
      Colors.amber[700]!,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, "Driver Gears", const Offset(0, 230), 18, Colors.white);

    // Gear 3
    if (state.activeDragEntity == 'gear_3') {
      _drawGear(canvas, state.dragPos, 30, 3, rotDr, Colors.amber, '3');
    } else if (!state.s2TestedC3) {
      _drawGear(canvas, const Offset(-50, 280), 30, 3, 0, Colors.amber, '3');
    } else if (state.s2TestedC3 && !state.s2TestedD3) {
      _drawGear(
        canvas,
        gC + const Offset(0, 120),
        30,
        3,
        rotDr,
        Colors.amber,
        '3',
      );
    } else if (state.s2TestedD3) {
      _drawGear(canvas, const Offset(-50, 280), 30, 3, 0, Colors.blueGrey, '3');
    }

    // Gear 4
    if (state.activeDragEntity == 'gear_4') {
      _drawGear(canvas, state.dragPos, 40, 4, rotDr, Colors.pinkAccent, '4');
    } else if (state.s2TestedD3 && !state.s2TestedC4) {
      _drawGear(
        canvas,
        const Offset(50, 280),
        40,
        4,
        0,
        Colors.pinkAccent,
        '4',
      );
    } else if (state.s2TestedC4 && !state.s2TestedD4) {
      _drawGear(
        canvas,
        gC + const Offset(0, 130),
        40,
        4,
        rotDr,
        Colors.pinkAccent,
        '4',
      );
    } else if (state.s2TestedD4) {
      _drawGear(
        canvas,
        gD + const Offset(0, 200),
        40,
        4,
        rotDr,
        Colors.pinkAccent,
        '4',
      );
    } else {
      _drawGear(canvas, const Offset(50, 280), 40, 4, 0, Colors.blueGrey, '4');
    }

    if (state.currentStep == 3) {
      Color btnC = state.s2Analyzed ? Colors.blueGrey : Colors.blueAccent;
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-100, 100, 200, 60),
        30,
        btnC,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(canvas, "ANALYZE", const Offset(0, 130), 20, Colors.white);
    }

    if (state.s2Analyzed) {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-200, 350, 400, 80),
        10,
        const Color(0xFFF0FDF4),
        Colors.green,
        4,
      );
      _drawText(
        canvas,
        "CO-PRIME",
        const Offset(0, 375),
        24,
        Colors.green[800]!,
      );
      _drawText(
        canvas,
        "9 and 16 only share factor 1.",
        const Offset(0, 405),
        16,
        Colors.green[900]!,
      );
    }
  }

  void _renderS3(Canvas canvas) {
    _drawLine(
      canvas,
      const Offset(-1000, 0),
      const Offset(1000, 0),
      const Color(0xFF334155),
      2,
    );

    // Machine
    bool proc =
        state.animating &&
        (state.activeTest == 'M18' || state.activeTest == 'M35');
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-100, -180, 200, 160),
      15,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      5,
    );
    // screen
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-60, -140, 120, 60),
      5,
      proc ? Colors.greenAccent : const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      "FACTORIZER",
      const Offset(0, -110),
      16,
      proc ? Colors.green[900]! : Colors.blueGrey,
    );

    // Blocks
    if (!state.s3_18in && state.activeDragEntity != 'block18')
      _drawCube(canvas, const Offset(-300, -200), 30, "18", Colors.blue);
    if (!state.s3_35in && state.activeDragEntity != 'block35')
      _drawCube(canvas, const Offset(300, -200), 30, "35", Colors.teal);

    if (state.activeDragEntity == 'block18')
      _drawCube(canvas, state.dragPos, 30, "18", Colors.blue);
    if (state.activeDragEntity == 'block35')
      _drawCube(canvas, state.dragPos, 30, "35", Colors.teal);

    // Trays
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-200, 100, 160, 80),
      10,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, "18 Factors", const Offset(-120, 185), 14, Colors.white);

    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(40, 100, 160, 80),
      10,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, "35 Factors", const Offset(120, 185), 14, Colors.white);

    if (state.s3_18in && state.activeTest != 'M18') {
      if (state.activeDragEntity != 'p2_1')
        _drawCube(canvas, const Offset(-170, 140), 20, "2", Colors.pinkAccent);
      if (state.activeDragEntity != 'p3_1')
        _drawCube(canvas, const Offset(-120, 140), 20, "3", Colors.amber);
      if (state.activeDragEntity != 'p3_2')
        _drawCube(canvas, const Offset(-70, 140), 20, "3", Colors.amber);
    }
    if (state.s3_35in && state.activeTest != 'M35') {
      _drawCube(canvas, const Offset(80, 140), 20, "5", Colors.purpleAccent);
      _drawCube(canvas, const Offset(130, 140), 20, "7", Colors.cyan);
    }

    if (state.activeDragEntity == 'p2_1')
      _drawCube(canvas, state.dragPos, 20, "2", Colors.pinkAccent);
    if (state.activeDragEntity == 'p3_1' || state.activeDragEntity == 'p3_2')
      _drawCube(canvas, state.dragPos, 20, "3", Colors.amber);

    // Compare
    if (state.currentStep >= 2) {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-250, 250, 500, 150),
        20,
        const Color(0xFF64748B),
        const Color(0xFF0F172A),
        5,
      );
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-100, 270, 200, 110),
        10,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(
        canvas,
        "COMMON BLOCKS",
        const Offset(0, 325),
        18,
        Colors.blueGrey[300]!,
      );

      if (state.s3TestedCompare &&
          state.animating &&
          state.activeTest == 'REJECT') {
        _drawRoundedRect(
          canvas,
          const Rect.fromLTWH(-100, 270, 200, 110),
          10,
          Colors.red.withOpacity(0.3),
          Colors.redAccent,
          4,
        );
        _drawText(
          canvas,
          "NO MATCH",
          const Offset(0, 325),
          24,
          Colors.redAccent,
        );
      }
    }

    if (state.currentStep == 3) {
      Color btnC = state.s3Finalized ? Colors.blueGrey : Colors.blueAccent;
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(300, 300, 160, 60),
        30,
        btnC,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(canvas, "FINALIZE", const Offset(380, 330), 18, Colors.white);
    }

    if (state.s3Finalized) {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-200, 420, 400, 80),
        10,
        const Color(0xFFF0FDF4),
        Colors.green,
        4,
      );
      _drawText(
        canvas,
        "CO-PRIME",
        const Offset(0, 445),
        24,
        Colors.green[800]!,
      );
      _drawText(
        canvas,
        "18 & 35 have NO primes in common.",
        const Offset(0, 475),
        16,
        Colors.green[900]!,
      );
    }
  }

  void _renderS4(Canvas canvas) {
    Color cColor = state.s4Unlocked
        ? Colors.green
        : (state.activeTest == 'FAIL'
              ? Colors.redAccent
              : const Color(0xFF475569));
    double rot28 = (state.activeTest == 'K4' || state.activeTest == 'K7')
        ? state.animProgress * pi * 2
        : 0;
    double rot70 = (state.activeTest == 'K7')
        ? state.animProgress * pi * 2
        : ((state.activeTest == 'FAIL')
              ? sin(state.animProgress * pi * 10) * 0.1
              : 0);
    double rotKey = state.animating ? -state.animProgress * pi * 4 : 0;

    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-250, -200, 500, 300),
      20,
      const Color(0xFF64748B),
      const Color(0xFF0F172A),
      6,
    );
    _drawGear(canvas, const Offset(-120, -50), 80, 28, rot28, cColor, '28');
    _drawGear(canvas, const Offset(120, -50), 100, 70, rot70, cColor, '70');

    canvas.drawCircle(
      const Offset(0, -50),
      45,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.fill,
    );

    if (state.s4ActiveKey != null) {
      _drawGear(
        canvas,
        const Offset(0, -50),
        35,
        state.s4ActiveKey!,
        rotKey,
        Colors.amber,
        '${state.s4ActiveKey}',
      );
    } else {
      canvas.drawCircle(
        const Offset(0, -50),
        15,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.fill,
      );
    }

    if (state.s4Unlocked) {
      _drawText(canvas, "UNLOCKED!", const Offset(0, -250), 36, Colors.green);
    } else if (state.activeTest == 'FAIL') {
      _drawText(canvas, "ERROR", const Offset(0, -250), 36, Colors.redAccent);
    }

    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-300, 200, 600, 120),
      10,
      Colors.amber[700]!,
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, "Key-Gears", const Offset(0, 220), 18, Colors.white);

    List<int> keys = [2, 4, 5, 7, 14];
    for (int i = 0; i < keys.length; i++) {
      int k = keys[i];
      Offset kp = Offset(-200.0 + i * 100, 270);
      if (state.activeDragEntity == 'key_$k' || state.s4ActiveKey == k) {
        _drawGear(canvas, kp, 35, k, 0, Colors.blueGrey, '$k');
      } else {
        _drawGear(canvas, kp, 35, k, 0, Colors.amber, '$k');
      }
    }

    if (state.activeDragEntity != null &&
        state.activeDragEntity!.startsWith('key_')) {
      int k = int.parse(state.activeDragEntity!.split('_')[1]);
      _drawGear(canvas, state.dragPos, 35, k, 0, Colors.amber, '$k');
    }
  }

  void _renderS5(Canvas canvas) {
    // Loom bg
    canvas.drawCircle(
      const Offset(0, -50),
      200,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-350, 220, 700, 80),
      10,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      3,
    );

    List<int> gaps = [3, 6, 7, 10];
    for (int i = 0; i < gaps.length; i++) {
      int g = gaps[i];
      double bx = -250.0 + i * 165;
      double by = 260.0;
      bool isSel = state.s5Gap == g;
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(bx - 60, by - 25, 120, 50),
        8,
        isSel ? Colors.blueAccent : const Color(0xFF475569),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, "Gap: $g", Offset(bx, by), 18, Colors.white);
    }

    Offset c = const Offset(0, -50);
    double r = 200;

    for (int i = 0; i < 15; i++) {
      double angle = -pi / 2 + (i * pi * 2) / 15;
      Offset p = c + Offset(r * cos(angle), r * sin(angle));
      bool isHit = state.s5PegHit.contains(i);

      canvas.drawCircle(
        p,
        8,
        Paint()..color = isHit ? Colors.amber : Colors.blueGrey,
      );
      _drawText(
        canvas,
        '$i',
        p + Offset(25 * cos(angle), 25 * sin(angle)),
        14,
        Colors.blueGrey[300]!,
      );
    }

    if (state.s5WeavingPath.isNotEmpty) {
      Path path = Path();
      for (int i = 0; i < state.s5WeavingPath.length; i++) {
        int peg = state.s5WeavingPath[i];
        double angle = -pi / 2 + (peg * pi * 2) / 15;
        Offset p = c + Offset(r * cos(angle), r * sin(angle));
        if (i == 0)
          path.moveTo(p.dx, p.dy);
        else
          path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.lightBlueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    if (!state.animating && state.s5Gap > 0) {
      if (state.s5PegHit.length == 15) {
        _drawText(
          canvas,
          "PERFECT STAR!",
          const Offset(0, -50),
          36,
          Colors.green,
        );
      } else {
        _drawText(
          canvas,
          "PATTERN INCOMPLETE",
          const Offset(0, -50),
          28,
          Colors.redAccent,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
