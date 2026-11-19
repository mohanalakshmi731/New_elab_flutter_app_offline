// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZSLVirtualLabApp());
}

class ZSLVirtualLabApp extends StatelessWidget {
  const ZSLVirtualLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASA Congruence: The Constructor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366f1),
          secondary: Color(0xFF10b981),
          error: Color(0xFFf43f5e),
        ),
      ),
      home: const ASACongruenceLab(),
    );
  }
}

class ASACongruenceLab extends StatefulWidget {
  const ASACongruenceLab({super.key});

  @override
  State<ASACongruenceLab> createState() => _ASACongruenceLabState();
}

class _ASACongruenceLabState extends State<ASACongruenceLab> with TickerProviderStateMixin {
  // --- Core UI State ---
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  bool _showFinalPopup = false;
  String _lang = 'en';

  // --- Canvas Transform ---
  double _zoom = 1.0;
  Offset _pan = const Offset(0, 20);
  double _baseZoom = 1.0;

  // --- Scenario State ---
  int _scenario = 1;
  int _step = 0;

  // --- Audio Players ---
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  // --- Animation & Scroll ---
  late AnimationController _curtainAnimCtrl;
  late Animation<double> _curtainAnim;
  late AnimationController _pulseCtrl;
  final ScrollController _sidebarScrollCtrl = ScrollController();

  // --- Mini HUD ---
  String _miniHudMessage = "";
  bool _showMiniHud = false;
  Timer? _miniHudTimer;

  // --- Simulation States ---
  String? _toolType;
  bool _toolDragging = false;
  Offset _dragOffset = Offset.zero;
  
  double baseLen = 4;
  int angL = 0;
  int angR = 0;
  bool basePlaced = false;
  bool angLPlaced = false;
  bool angRPlaced = false;
  bool triFormed = false;
  double triX = 0;
  double triY = 0;
  bool superimposed = false;
  bool superimposedTarget = false;
  int rotation = 0;
  bool isFlipped = false;
  double scale = 1.0;
  
  String calcStr = '';
  bool calcSolved = false;
  bool showFlipBtn = false;
  double? handleX;
  double? handleY;

  // Floating Panel Positions
  Offset _calcPos = const Offset(40, 150);
  Offset _activeStepPos = const Offset(20, 80);

  double _hypot(double x, double y) => math.sqrt(x * x + y * y);

  final Map<int, Map<String, dynamic>> _sceneConfig = {
    1: {'tBase': 8.0, 'tAngL': 50, 'tAngR': 30, 'tRot': 0, 'tFlip': false, 'startL': 4.0, 'tx': -360.0, 'ty': 40.0, 'wx': 60.0, 'wy': 40.0, 'lbls': ['B', 'C', 'A']},
    2: {'tBase': 6.0, 'tAngL': 70, 'tAngR': 45, 'tRot': 120, 'tFlip': false, 'startL': 4.0, 'tx': -360.0, 'ty': 40.0, 'wx': 60.0, 'wy': 40.0, 'lbls': ['Y', 'Z', 'X']},
    3: {'tBase': 5.0, 'tAngL': 90, 'tAngR': 40, 'tRot': 0, 'tFlip': true, 'startL': 4.0, 'tx': -360.0, 'ty': 40.0, 'wx': 60.0, 'wy': 40.0, 'lbls': ['Q', 'R', 'P']},
    4: {'tBase': 7.0, 'tAngL': 75, 'tAngR': 45, 'tRot': 0, 'tFlip': false, 'startL': 4.0, 'tx': -360.0, 'ty': 40.0, 'wx': 60.0, 'wy': 40.0, 'lbls': ['E', 'F', 'D']}, 
    5: {'tBase': 12.0, 'tAngL': 40, 'tAngR': 60, 'tRot': 0, 'tFlip': false, 'startL': 6.0, 'tx': -380.0, 'ty': 40.0, 'wx': 80.0, 'wy': 40.0, 'lbls': ['M', 'N', 'L']},
  };
  final double sceneScale = 25.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _curtainAnimCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _curtainAnim = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(parent: _curtainAnimCtrl, curve: Curves.easeInOutCubic),
    );

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);

    _loadScenario(1, playSound: false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _curtainAnimCtrl.dispose();
    _pulseCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    _miniHudTimer?.cancel();
    super.dispose();
  }

  void _playClick() { try { _clickPlayer.play(AssetSource(_clickUrl)); } catch (_) {} }
  void _playSuccess() { try { _successPlayer.play(AssetSource(_successUrl)); } catch (_) {} }
  void _playError() { try { _errorPlayer.play(AssetSource(_errorUrl)); } catch (_) {} }
  void _playFx() { try { _fxPlayer.play(AssetSource(_alertUrl)); } catch (_) {} }
  void _playShutter() { try { _shutterPlayer.play(AssetSource(_shutterUrl)); } catch (_) {} }

  void _showMiniHUD(String message) {
    setState(() {
      _miniHudMessage = message;
      _showMiniHud = true;
    });
    _miniHudTimer?.cancel();
    _miniHudTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showMiniHud = false);
    });
  }

  String t(String key) {
    Map<String, Map<String, String>> translations = {
      'en': {
        'appTitle': "The Congruence Constructor: ASA Blueprint", 'appSubtitle': "Class 7 • GEOMETRIC TWINS", 'enterLab': "Enter Lab",
        'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'learnLbl': "What We Learn:", 'summaryTitle': "Discovery Made!",
        'resetBtn': "Reset", 'finishLab': "Finish Lab",
        'scenarioCompleted': "✅ Scenario Completed! Please try the next scenario from the dropdown above.",
        'labCompleted': "Lab Completed!", 'finalDesc': "You have mastered ASA Congruence! By locking two angles and the included side, you guarantee a unique, identical shape.",
        'congruentLbl': "CONGRUENT (ASA)!", 'mismatchLbl': "SIMILAR (AAA)",
        'lblTools': "Toolbox", 'btnFlip': "FLIP", 'btnRot': "ROTATE",
        'lblConstZone': "Construction Area", 'lblBlueprint': "Master Blueprint",
        'lblUnits': "cm",

        's1_title': "1. The Master Blueprint (ASA)", 's1_obj': "To construct a triangle using given ASA measurements and verify it is congruent to a target blueprint by superimposing it.",
        's1_step1_task': "A target triangle, ΔABC, is shown on a blueprint. DRAG a line segment from the toolbox to the construction area below.", 's1_step1_out': "Observation: A line segment appears in the construction area.",
        's1_step2_task': "A virtual ruler is present. DRAG the right endpoint of the segment until the ruler shows a length of 8 cm. This will be your side B'C'.", 's1_step2_out': "Observation: The line segment is resized and locked to exactly 8 cm.",
        's1_step3_task': "DRAG the virtual protractor from the toolbox and DROP it on point B'. CLICK and DRAG the protractor's guide line to draw a ray at a 50° angle.", 's1_step3_out': "Observation: A long ray is drawn from point B' at a 50° angle to the segment B'C'.",
        's1_step4_task': "Now, DRAG the protractor and DROP it on point C'. CLICK and DRAG the guide line to draw a ray at a 30° angle.", 's1_step4_out': "Observation: A second ray is drawn from C', intersecting the first ray. Triangle ΔA'B'C' is formed.",
        's1_step5_task': "Your triangle is complete! DRAG your constructed triangle, ΔA'B'C', and DROP it on top of the master blueprint, ΔABC.", 's1_step5_out': "Learning: Perfect Match! The constructed triangle perfectly overlaps the target triangle, proving ASA congruence.", 's1_sum': "ASA Verified! If two angles and the included side are equal to the corresponding parts of another triangle, the triangles are fully identical.",

        's2_title': "2. The Rotated Truss", 's2_obj': "To verify ASA congruence when the target triangle is in a different orientation.",
        's2_step1_task': "A new blueprint shows a target triangle, ΔXYZ, which is rotated. The measurements are given: ∠Y = 70°, side YZ = 6 cm, and ∠Z = 45°. DRAG a line segment to the construction area and set its length to 6 cm using the virtual ruler.", 's2_step1_out': "Observation: A 6 cm line segment (Y'Z') is created in the construction area.",
        's2_step2_task': "Use the virtual protractor to construct a 70° angle at point Y' and a 45° angle at point Z'.", 's2_step2_out': "Observation: A new triangle, ΔX'Y'Z', is formed from the intersection of the two rays.",
        's2_step3_task': "DRAG your new triangle, ΔX'Y'Z', towards the target blueprint, ΔXYZ. It doesn't seem to fit. CLICK and DRAG the ROTATE handle to turn your triangle until it matches the orientation of the target blueprint.", 's2_step3_out': "Observation: The user's triangle is rotated and successfully aligned.",
        's2_step4_task': "DROP the aligned triangle into place.", 's2_step4_out': "Learning: Rotation does not change congruence.", 's2_sum': "Orientation Independence: Congruent triangles remain perfectly identical even if they are rotated in space.",

        's3_title': "3. The Mirrored Panel", 's3_obj': "To verify ASA congruence when the target triangle is a mirror image (flipped).",
        's3_step1_task': "The blueprint now shows a target triangle, ΔPQR, that is a reflection. Construct your triangle, ΔP'Q'R', using these measurements. Construct a 5 cm base segment.", 's3_step1_out': "Observation: Base created.",
        's3_step2_task': "Use the protractor to make a right-angled triangle (90° left, 40° right).", 's3_step2_out': "Observation: Triangle is formed, but facing the wrong way.",
        's3_step3_task': "DRAG your triangle ΔP'Q'R' to the target. Try rotating it to make it fit. It seems your triangle is a mirror image of the target. CLICK the FLIP button to reflect your triangle.", 's3_step3_out': "Observation: The triangle flips to become a mirror image.",
        's3_step4_task': "Now, DRAG the flipped triangle and DROP it onto the target blueprint.", 's3_step4_out': "Learning: Flipped figures can still be congruent.", 's3_sum': "Reflection Independence: A triangle and its exact mirror image are mathematically congruent.",

        's4_title': "4. The Bridge Support Puzzle", 's4_obj': "To construct a triangle using two angles and a non-included side (AAS), deducing the third angle for ASA.",
        's4_step1_task': "An engineer provides a blueprint for ΔDEF with these measurements: ∠D = 60°, ∠E = 75°, and side EF = 7 cm. Notice the side is NOT between the given angles. Your task is to build a congruent triangle. DRAG a line segment to the workbench.", 's4_step1_out': "Observation: A line segment is placed on the workbench.",
        's4_step2_task': "You can't place side EF and use angle D directly. Is there another angle you can find? The sum of angles in a triangle is 180°. Use the calculator to find ∠F.", 's4_step2_out': "Observation: The user calculates ∠F = 180° - 60° - 75° = 45°.",
        's4_step3_task': "Great! You now know ∠E = 75°, side EF = 7 cm, and ∠F = 45°. This is an ASA problem! Construct the triangle using these new measurements.", 's4_step3_out': "Observation: The user successfully constructs ΔD'E'F' using the ASA method.",
        's4_step4_task': "DRAG your completed triangle onto the blueprint to check your work.", 's4_step4_out': "Learning: AAS works because we can always find the 3rd angle for ASA.", 's4_sum': "AAS to ASA: Because the three angles always add up to 180°, knowing two angles and any side guarantees congruence.",

        's5_title': "5. The Size Illusion", 's5_obj': "To demonstrate why Angle-Angle-Angle (AAA) is not a condition for congruence by showing it only guarantees similarity (same shape, different size).",
        's5_step1_task': "A designer has created a small triangular logo, ΔLMN. They tell you the angles are ∠L = 80°, ∠M = 40°, and ∠N = 60°. They did not provide any side lengths. Try to recreate their logo exactly. First, DRAG a line segment of ANY length to the workbench to act as your base M'N'.", 's5_step1_out': "Observation: The user creates a line segment of an arbitrary length.",
        's5_step2_task': "Use the protractor to construct the base angles on your segment: a 40° angle at M' and a 60° angle at N'.", 's5_step2_out': "Observation: A triangle is formed with the correct angles (the third angle will automatically be 80°).",
        's5_step3_task': "DRAG your new triangle and try to place it on the target logo ΔLMN.", 's5_step3_out': "Observation: The user's triangle has the same shape (angles) as the target, but is either too large or too small.",
        's5_step4_task': "Your triangle has the right shape but the wrong size. DRAG the SCALE handle to resize your triangle until it fits the logo.", 's5_step4_out': "Observation: The user resizes their triangle to match the target.",
        's5_sum': "You made it fit, but you had to change its size! This means the triangles are SIMILAR (same shape), but not CONGRUENT (same shape and size). AAA is not enough for congruence. You need at least one side measurement to lock in the size, which is why ASA works!"
      },
      'hi': {
        'appTitle': "ASA सर्वांगसमता: कंस्ट्रक्टर", 'appSubtitle': "कक्षा 7 • ज्यामितीय जुड़वाँ", 'enterLab': "लैब में प्रवेश करें",
        'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'learnLbl': "हम क्या सीखते हैं:", 'summaryTitle': "खोज की गई!",
        'resetBtn': "रीसेट करें", 'finishLab': "लैब समाप्त करें",
        'scenarioCompleted': "✅ परिदृश्य पूर्ण हुआ! कृपया ऊपर दिए गए ड्रॉपडाउन से अगला परिदृश्य चुनें।",
        'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने ASA सर्वांगसमता में महारत हासिल कर ली है! दो कोणों और बीच की भुजा को लॉक करके, आप एक अद्वितीय आकार की गारंटी देते हैं।",
        'congruentLbl': "सर्वांगसम (ASA)!", 'mismatchLbl': "समरूप (AAA)",
        'lblTools': "उपकरण", 'btnFlip': "पलटें", 'btnRot': "घुमाएं",
        'lblConstZone': "निर्माण क्षेत्र", 'lblBlueprint': "मास्टर ब्लूप्रिंट",
        'lblUnits': "cm",

        's1_title': "1. मास्टर ब्लूप्रिंट (ASA)", 's1_obj': "दिए गए ASA मापन का उपयोग करके एक त्रिभुज बनाना और उसकी सर्वांगसमता की पुष्टि करना।",
        's1_step1_task': "ब्लूप्रिंट पर लक्ष्य ΔABC दिखाया गया है। टूलबॉक्स से निर्माण क्षेत्र में रेखा खंड खींचें।", 's1_step1_out': "अवलोकन: निर्माण क्षेत्र में एक रेखा खंड दिखाई देता है।",
        's1_step2_task': "एक वर्चुअल रूलर मौजूद है। खंड के दाएँ सिरे को तब तक खींचें जब तक रूलर 8 cm की लंबाई न दिखाए।", 's1_step2_out': "अवलोकन: रेखा खंड का आकार बदल जाता है और ठीक 8 cm पर लॉक हो जाता है।",
        's1_step3_task': "वर्चुअल प्रोट्रैक्टर को खींचें और बिंदु B' पर छोड़ें। 50° के कोण पर किरण खींचने के लिए गाइड लाइन को खींचें।", 's1_step3_out': "अवलोकन: बिंदु B' से 50° के कोण पर एक किरण खींची जाती है।",
        's1_step4_task': "अब, प्रोट्रैक्टर को बिंदु C' पर खींचें। 30° के कोण पर किरण खींचने के लिए गाइड लाइन को खींचें।", 's1_step4_out': "अवलोकन: दूसरी किरण खींची जाती है। त्रिभुज ΔA'B'C' बनता है।",
        's1_step5_task': "अपने बनाए गए त्रिभुज ΔA'B'C' को मास्टर ब्लूप्रिंट ΔABC के ऊपर खींचें और छोड़ें।", 's1_step5_out': "सीख: एकदम सही मेल! बनाया गया त्रिभुज लक्ष्य त्रिभुज को पूरी तरह ढकता है।", 's1_sum': "ASA सत्यापित! यदि दो कोण और बीच की भुजा किसी अन्य त्रिभुज के समान हैं, तो त्रिभुज पूरी तरह से समान होते हैं।",

        's2_title': "2. घुमाया गया ट्रस", 's2_obj': "जब लक्ष्य त्रिभुज अलग दिशा में हो, तो ASA सर्वांगसमता की पुष्टि करना।",
        's2_step1_task': "नया ब्लूप्रिंट लक्ष्य त्रिभुज ΔXYZ दिखाता है, जो घुमाया गया है। मापन हैं: ∠Y=70°, YZ=6cm, ∠Z=45°। निर्माण क्षेत्र में एक रेखा खंड खींचें और लंबाई 6cm सेट करें।", 's2_step1_out': "अवलोकन: निर्माण क्षेत्र में 6 cm का रेखा खंड बनता है।",
        's2_step2_task': "वर्चुअल प्रोट्रैक्टर का उपयोग करके बिंदु Y' पर 70° और बिंदु Z' पर 45° का कोण बनाएं।", 's2_step2_out': "अवलोकन: दो किरणों के प्रतिच्छेदन से नया त्रिभुज बनता है।",
        's2_step3_task': "अपने नए त्रिभुज को लक्ष्य की ओर खींचें। यह मेल नहीं खाता। ROTATE हैंडल को खींचकर अपने त्रिभुज को घुमाएं।", 's2_step3_out': "अवलोकन: त्रिभुज घुमाया जाता है और संरेखित होता है।",
        's2_step4_task': "संरेखित त्रिभुज को लक्ष्य स्थान पर छोड़ें।", 's2_step4_out': "सीख: घुमाने से सर्वांगसमता नहीं बदलती।", 's2_sum': "दिशा स्वतंत्रता: सर्वांगसम त्रिभुज घुमाए जाने पर भी स्थान में पूरी तरह समान रहते हैं।",

        's3_title': "3. दर्पण पैनल", 's3_obj': "जब लक्ष्य त्रिभुज एक दर्पण छवि हो, तो ASA सर्वांगसमता की पुष्टि करना।",
        's3_step1_task': "ब्लूप्रिंट लक्ष्य त्रिभुज ΔPQR दिखाता है, जो एक परावर्तन है। 5 cm का आधार खंड बनाएं।", 's3_step1_out': "अवलोकन: आधार तैयार है।",
        's3_step2_task': "प्रोट्रैक्टर का उपयोग करके त्रिभुज बनाएं (90° बाएँ, 40° दाएँ)।", 's3_step2_out': "अवलोकन: त्रिभुज बनता है, लेकिन उल्टी दिशा में।",
        's3_step3_task': "अपने त्रिभुज को लक्ष्य की ओर खींचें। ऐसा लगता है कि यह दर्पण छवि है। पलटने के लिए FLIP बटन पर क्लिक करें।", 's3_step3_out': "अवलोकन: त्रिभुज अपनी दर्पण छवि में बदल जाता है।",
        's3_step4_task': "अब, पलटे हुए त्रिभुज को लक्ष्य ब्लूप्रिंट पर खींचें और छोड़ें।", 's3_step4_out': "सीख: पलटी हुई आकृतियां भी सर्वांगसम हो सकती हैं।", 's3_sum': "परावर्तन स्वतंत्रता: एक त्रिभुज और उसकी सटीक दर्पण छवि गणितीय रूप से सर्वांगसम होते हैं।",

        's4_title': "4. ब्रिज सपोर्ट पहेली", 's4_obj': "AAS का उपयोग करके एक त्रिभुज बनाना, तीसरे कोण का पता लगाना।",
        's4_step1_task': "ब्लूप्रिंट: ∠D=60°, ∠E=75°, और भुजा EF=7cm। भुजा दिए गए कोणों के बीच नहीं है। वर्कबेंच पर एक रेखा खंड खींचें।", 's4_step1_out': "अवलोकन: वर्कबेंच पर एक रेखा खंड उतरा।",
        's4_step2_task': "त्रिभुज के कोणों का योग 180° होता है। ∠F खोजने के लिए कैलकुलेटर का उपयोग करें।", 's4_step2_out': "अवलोकन: उपयोगकर्ता ∠F = 180 - 60 - 75 = 45° की गणना करता है।",
        's4_step3_task': "अब आप जानते हैं: ∠E=75°, EF=7cm, ∠F=45°। यह एक ASA समस्या है! त्रिभुज का निर्माण करें।", 's4_step3_out': "अवलोकन: उपयोगकर्ता ASA विधि का उपयोग करके निर्माण करता है।",
        's4_step4_task': "अपने काम की जाँच करने के लिए पूर्ण त्रिभुज को ब्लूप्रिंट पर खींचें।", 's4_step4_out': "सीख: AAS काम करता है क्योंकि हम हमेशा ASA के लिए 3रा कोण खोज सकते हैं।", 's4_sum': "AAS से ASA: चूँकि तीनों कोणों का योग हमेशा 180° होता है, इसलिए दो कोण और कोई भी भुजा सर्वांगसमता की गारंटी देते हैं।",

        's5_title': "5. आकार का भ्रम", 's5_obj': "यह प्रदर्शित करना कि कोण-कोण-कोण (AAA) सर्वांगसमता की शर्त क्यों नहीं है।",
        's5_step1_task': "डिज़ाइनर ने लोगो ΔLMN बनाया: ∠L=80°, ∠M=40°, ∠N=60°। कोई भुजा की लंबाई नहीं दी। वर्कबेंच पर किसी भी लंबाई का रेखा खंड खींचें।", 's5_step1_out': "अवलोकन: एक रेखा खंड बनता है।",
        's5_step2_task': "प्रोट्रैक्टर का उपयोग करें: M' पर 40° और N' पर 60°।", 's5_step2_out': "अवलोकन: सही कोणों के साथ एक त्रिभुज बनता है।",
        's5_step3_task': "अपने नए त्रिभुज को खींचें और लक्ष्य लोगो पर रखने का प्रयास करें।", 's5_step3_out': "अवलोकन: त्रिभुज का आकार समान है, लेकिन साइज गलत है।",
        's5_step4_task': "SCALE हैंडल को खींचें जब तक कि वह लोगो से मेल न खा जाए।", 's5_step4_out': "अवलोकन: उपयोगकर्ता त्रिभुज का आकार बदलता है।",
        's5_sum': "आपने इसे फिट कर दिया, लेकिन साइज बदलना पड़ा! इसका मतलब है कि त्रिभुज समरूप हैं, सर्वांगसम नहीं। साइज लॉक करने के लिए एक भुजा आवश्यक है!"
      }
    };
    return translations[_lang]?[key] ?? translations['en']![key] ?? key;
  }

  void _resetToShutter() {
    _playShutter();
    setState(() {
      _lang = 'en';
      _showCurtain = true;
      _showFinalPopup = false;
      _curtainAnimCtrl.value = 0.0;
    });
    _loadScenario(1, playSound: false);
  }

  void _loadScenario(int id, {bool playSound = true}) {
    setState(() {
      if (playSound) _playClick();
      _scenario = id;
      _step = 0;
      _showFinalPopup = false;
      
      _pan = const Offset(0, 20);
      _zoom = 1.0;

      basePlaced = false;
      angLPlaced = false;
      angRPlaced = false;
      triFormed = false;
      superimposed = false;
      superimposedTarget = false;
      rotation = 0;
      isFlipped = false;
      scale = 1.0;
      calcStr = '';
      calcSolved = false;
      showFlipBtn = false;
      handleX = null;
      handleY = null;
      _toolDragging = false;
      _toolType = null;
      
      final conf = _sceneConfig[_scenario]!;
      baseLen = conf['startL'];
      angL = 0;
      angR = 0;
      triX = 0;
      triY = 0;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_sidebarScrollCtrl.hasClients) {
        _sidebarScrollCtrl.animateTo(
          _sidebarScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
    _scrollToBottom();
  }

  void _checkScenarioSuccess() {
    _advanceStep();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_scenario == 5) {
        _playError();
      } else {
        _playSuccess();
      }
    });
  }

  void _evaluateStepConditions() {
    final conf = _sceneConfig[_scenario]!;
    bool advanced = false;

    if (basePlaced && angLPlaced && angRPlaced && !triFormed) {
      if (angL == conf['tAngL'] && angR == conf['tAngR']) {
        triFormed = true;
        triX = conf['wx'];
        triY = conf['wy'];
        _playFx(); // weld
        _showMiniHUD("Triangle Constructed!");
      }
    }

    if (_scenario == 1) {
      if (_step == 0 && basePlaced) advanced = true;
      else if (_step == 1 && baseLen == conf['tBase']) advanced = true;
      else if (_step == 2 && angL == conf['tAngL']) advanced = true;
      else if (_step == 3 && angR == conf['tAngR']) advanced = true;
    } else if (_scenario == 2) {
      if (_step == 0 && basePlaced && baseLen == conf['tBase']) advanced = true;
      else if (_step == 1 && triFormed) advanced = true;
      else if (_step == 2 && rotation == conf['tRot']) advanced = true;
    } else if (_scenario == 3) {
      if (_step == 0 && basePlaced && baseLen == conf['tBase']) advanced = true;
      else if (_step == 1 && triFormed) {
        advanced = true;
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (mounted) setState(() => showFlipBtn = true);
        });
      }
      else if (_step == 2 && isFlipped == conf['tFlip']) advanced = true;
    } else if (_scenario == 4) {
      if (_step == 0 && basePlaced) advanced = true;
      else if (_step == 2 && baseLen == conf['tBase'] && triFormed) advanced = true;
    } else if (_scenario == 5) {
      if (_step == 0 && basePlaced) advanced = true;
      else if (_step == 1 && triFormed) advanced = true;
      else if (_step == 2 && superimposedTarget) advanced = true;
      else if (_step == 3 && (scale * baseLen - conf['tBase']).abs() < 0.2) {
        scale = conf['tBase'] / baseLen;
        _alignTriangleToTarget();
        superimposed = true;
        _checkScenarioSuccess();
        return;
      }
    }

    if (advanced) {
      _playSuccess();
      _advanceStep();
    }
  }

  void _alignTriangleToTarget() {
    final conf = _sceneConfig[_scenario]!;
    triX = conf['tx'] + (conf['tBase'] - baseLen * scale) * sceneScale / 2;
    triY = conf['ty'];
  }

  Offset _getScreenToWorld(Offset screenPoint, Size canvasSize) {
    Matrix4 transform = Matrix4.identity()
      ..translate(canvasSize.width / 2 + _pan.dx, canvasSize.height / 2 + _pan.dy)
      ..scale(_zoom);
    return MatrixUtils.transformPoint(Matrix4.inverted(transform), screenPoint);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  void _onScaleStart(ScaleStartDetails details, Size canvasSize) {
    _baseZoom = _zoom;
    _toolDragging = false;
    _toolType = null;

    if (details.pointerCount >= 2) return; 

    Offset pt = _getScreenToWorld(details.localFocalPoint, canvasSize);
    final conf = _sceneConfig[_scenario]!;

    double bgW = _scenario == 5 ? 460 : 380;
    double bgH = _scenario == 5 ? 360 : 320;
    double cBgX = conf['wx'] - 80;
    double tX = cBgX + bgW + 30;
    double tY = conf['ty'] - (bgH - 100) + 40;

    bool showBeam = !basePlaced;
    bool showPro = basePlaced && !triFormed && (baseLen == conf['tBase'] || _scenario == 5) && (_scenario != 4 || calcSolved);

    if (showBeam && _hitTestBox(tX + 25, tY + 40, 60, 60, pt)) {
      _toolDragging = true; _toolType = 'tool_beam'; _dragOffset = pt; _playClick(); return;
    }
    if (showPro && _hitTestBox(tX + 25, tY + 120, 60, 60, pt)) {
      _toolDragging = true; _toolType = 'tool_pro'; _dragOffset = pt; _playClick(); return;
    }

    double rY = conf['wy'] + 45;
    bool hitEndpoint = (pt.dx - (conf['wx'] + baseLen * sceneScale)).abs() < 50 && (pt.dy - conf['wy']).abs() < 50;
    bool hitRulerHandle = (pt.dx - (conf['wx'] + baseLen * sceneScale)).abs() < 50 && (pt.dy - rY).abs() < 50;

    if (basePlaced && !angLPlaced && !angRPlaced && (hitEndpoint || hitRulerHandle)) {
      _toolDragging = true; _toolType = 'stretch_base'; _playClick(); return;
    }

    if (angLPlaced && !triFormed && _hypot(pt.dx - (conf['wx'] + 130 * math.cos(-angL * math.pi / 180)), pt.dy - (conf['wy'] + 130 * math.sin(-angL * math.pi / 180))) < 50) {
      _toolDragging = true; _toolType = 'rot_pro_L'; _playClick(); return;
    }
    if (angRPlaced && !triFormed) {
      double rx = conf['wx'] + baseLen * sceneScale;
      double rHandleAng = -(180 - angR) * math.pi / 180;
      if (_hypot(pt.dx - (rx + 130 * math.cos(rHandleAng)), pt.dy - (conf['wy'] + 130 * math.sin(rHandleAng))) < 50) {
        _toolDragging = true; _toolType = 'rot_pro_R'; _playClick(); return;
      }
    }

    if (triFormed && !superimposed && handleX != null && handleY != null) {
      if (_hypot(pt.dx - handleX!, pt.dy - handleY!) < 40) {
        _toolDragging = true; _toolType = 'tri_rotate'; _playClick(); return;
      }
    }

    if (triFormed && !superimposed) {
      if (_hypot(pt.dx - (triX + (baseLen * sceneScale) / 2), pt.dy - (triY - 30)) < 150) {
        _toolDragging = true; _toolType = 'tri_drag'; 
        _dragOffset = Offset(triX - pt.dx, triY - pt.dy); 
        _playClick(); return;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    if (!_toolDragging) {
      setState(() {
        _pan += details.focalPointDelta;
        if (details.scale != 1.0) _zoom = (_baseZoom * details.scale).clamp(0.3, 3.0);
      });
      return;
    }
    
    Offset pt = _getScreenToWorld(details.localFocalPoint, canvasSize);
    final conf = _sceneConfig[_scenario]!;

    setState(() {
      if (_toolType == 'tool_beam' || _toolType == 'tool_pro') {
        _dragOffset = pt;
      } else if (_toolType == 'stretch_base') {
        baseLen = math.max(3.0, math.min(15.0, ((pt.dx - conf['wx']) / sceneScale).roundToDouble()));
      } else if (_toolType == 'rot_pro_L') {
        angL = math.max(0, math.min(170, ((math.atan2(conf['wy'] - pt.dy, pt.dx - conf['wx']) * 180 / math.pi) / 5).round() * 5));
      } else if (_toolType == 'rot_pro_R') {
        double rx = conf['wx'] + baseLen * sceneScale;
        angR = math.max(0, math.min(170, ((math.atan2(conf['wy'] - pt.dy, rx - pt.dx) * 180 / math.pi) / 5).round() * 5));
      } else if (_toolType == 'tri_drag') {
        triX = pt.dx + _dragOffset.dx;
        triY = pt.dy + _dragOffset.dy;
      } else if (_toolType == 'tri_rotate') {
        double cx = triX + (baseLen * sceneScale) / 2;
        var ptC = _getTriangleIntersection(baseLen, angL.toDouble(), angR.toDouble());
        double cy = triY - (ptC != null ? ptC.dy * sceneScale / 2 : 50);
        
        double angle = math.atan2(pt.dy - cy, pt.dx - cx) * 180 / math.pi;
        rotation = angle.round();
        
        if (_scenario == 2) {
          if ((rotation - 120).abs() < 15 || (rotation - (-240)).abs() < 15) {
            rotation = 120;
          }
        }
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_toolDragging) return;
    String tool = _toolType!;
    _toolDragging = false;
    _toolType = null;
    
    final conf = _sceneConfig[_scenario]!;

    setState(() {
      if (tool == 'tool_beam') {
        if (_hypot(_dragOffset.dx - conf['wx'], _dragOffset.dy - conf['wy']) < 150) {
          basePlaced = true; baseLen = conf['startL']; _playClick(); 
          _showMiniHUD("Line segment placed");
        } else { _playError(); }
      } else if (tool == 'stretch_base') {
        if (baseLen == conf['tBase'] || _scenario == 5) {
          _playClick();
          _showMiniHUD("Base length set to $baseLen cm");
        } else { _playError(); baseLen = conf['startL']; }
      } else if (tool == 'tool_pro') {
        if (!angLPlaced && _hypot(_dragOffset.dx - conf['wx'], _dragOffset.dy - conf['wy']) < 80) {
          angLPlaced = true; angL = 15; _playClick();
          _showMiniHUD("Protractor placed on left");
        } else if (angLPlaced && !angRPlaced && _hypot(_dragOffset.dx - (conf['wx'] + baseLen * sceneScale), _dragOffset.dy - conf['wy']) < 80) {
          angRPlaced = true; angR = 15; _playClick();
          _showMiniHUD("Protractor placed on right");
        } else { _playError(); }
      } else if (tool == 'rot_pro_L') {
        if (angL == conf['tAngL']) { _playClick(); _showMiniHUD("Left angle set to $angL°"); } else { _playError(); angL = 15; }
      } else if (tool == 'rot_pro_R') {
        if (angR == conf['tAngR']) { _playClick(); _showMiniHUD("Right angle set to $angR°"); } else { _playError(); angR = 15; }
      } else if (tool == 'tri_drag') {
        bool isAligned = (rotation == conf['tRot']) && (isFlipped == conf['tFlip']);
        bool isScaled = (scale * baseLen - conf['tBase']).abs() < 0.1;
        
        if (_hypot(triX - conf['tx'], triY - conf['ty']) < 150) {
          if (_scenario == 5) {
            _alignTriangleToTarget();
            superimposedTarget = true;
            _playClick();
            _showMiniHUD("Triangle placed over target");
          } else if (isAligned && isScaled) {
            triX = conf['tx']; triY = conf['ty']; superimposed = true;
            _showMiniHUD("Aligned Perfectly!");
            _checkScenarioSuccess();
          } else {
            triX = conf['wx']; triY = conf['wy']; _playError();
          }
        } else {
          _playClick();
        }
      } else if (tool == 'tri_rotate') {
        if (_scenario == 2 && rotation == 120) { _playClick(); _showMiniHUD("Triangle Rotated"); } else { _playFx(); }
      }
      
      _evaluateStepConditions();
    });
  }

  Offset? _getTriangleIntersection(double bLen, double aL, double aR) {
    if (aL == 0 || aR == 0 || (aL + aR) >= 180) return null;
    double radL = aL * math.pi / 180;
    double radR = aR * math.pi / 180;
    double cx = (bLen * math.sin(radR) * math.cos(radL)) / math.sin(radL + radR);
    double cy = (bLen * math.sin(radR) * math.sin(radL)) / math.sin(radL + radR);
    return Offset(cx, cy);
  }

  void _simCalc(String val) {
    setState(() {
      _playFx();
      if (val == 'C') {
        calcStr = '';
      } else if (val == '=') {
        try {
          List<String> parts = calcStr.split('-');
          int result = int.parse(parts[0]);
          for (int i = 1; i < parts.length; i++) {
            result -= int.parse(parts[i]);
          }
          calcStr = result.toString();
          if (result == 45) {
            calcSolved = true;
            _playSuccess();
            _showMiniHUD("Calculated Successfully!");
            if (_scenario == 4 && _step == 1) _advanceStep();
          } else {
            _playError();
          }
        } catch (_) {
          calcStr = 'ERR'; _playError();
        }
      } else {
        if (calcStr == 'ERR' || calcSolved) calcStr = '';
        calcStr += val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    double sidebarW = math.max(340.0, sw * 0.35); // Adjusted to 35% with a safe minimum width

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Row Layout for Responsive Sidebar and Canvas 
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  width: _isSidebarOpen ? sidebarW : 0,
                  child: ClipRect(child: _buildSidebar(sidebarW)),
                ),
                Expanded(
                  child: ClipRect(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                        return GestureDetector(behavior: HitTestBehavior.opaque, 
                          onScaleStart: (d) => _onScaleStart(d, canvasSize),
                          onScaleUpdate: (d) => _onScaleUpdate(d, canvasSize),
                          onScaleEnd: _onScaleEnd,
                          child: CustomPaint(
                            size: canvasSize,
                            painter: ASACanvasPainter(
                              zoom: _zoom, pan: _pan, scenario: _scenario, step: _step,
                              baseLen: baseLen, angL: angL, angR: angR,
                              basePlaced: basePlaced, angLPlaced: angLPlaced, angRPlaced: angRPlaced,
                              triFormed: triFormed, triX: triX, triY: triY,
                              superimposed: superimposed, superimposedTarget: superimposedTarget,
                              rotation: rotation, isFlipped: isFlipped, scale: scale,
                              calcSolved: calcSolved, toolDragging: _toolDragging, toolType: _toolType, dragOffset: _dragOffset,
                              sceneConfig: _sceneConfig[_scenario]!,
                              sceneScale: sceneScale,
                              pulseValue: _pulseCtrl.value,
                              t: t,
                              onUpdateHandle: (x, y) {
                                handleX = x; handleY = y;
                              }
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ],
            ),

            // Top Left Menu Icon (Floating above everything)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.indigoAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact(); _playClick();
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1e293b).withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.indigo.withOpacity(0.5))),
                ),
              ),
            ),

            // Overlays (Canvas Panels)
            if (triFormed && !superimposed) ...[
              if (_scenario == 3 && _step == 2 && showFlipBtn)
                _buildFloatingButton(triX - 60, triY - 60, t('btnFlip'), Icons.compare_arrows, () {
                  setState(() { isFlipped = true; rotation = 0; _playFx(); _evaluateStepConditions(); });
                }),
              if (_scenario == 5 && _step >= 2)
                _buildScaleSlider(),
            ],
            
            if (_scenario == 4 && _step == 1 && !calcSolved)
              _buildCalculator(),

            // Active Step Panel (visible when sidebar is closed)
            if (!_isSidebarOpen && _step < _getScenarioStepsCount(_scenario))
              Positioned(
                left: _activeStepPos.dx,
                top: _activeStepPos.dy,
                child: GestureDetector(behavior: HitTestBehavior.opaque, 
                  onPanUpdate: (d) => setState(() => _activeStepPos += d.delta),
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0f172a).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigoAccent),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${t('stepLabel')} ${_step + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigoAccent, letterSpacing: 1)),
                            const Icon(Icons.drag_indicator, color: Colors.white54, size: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(t('s${_scenario}_step${_step + 1}_task').replaceAll('<b>', '').replaceAll('</b>', ''), style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                ),
              ),

            // Mini HUD Overlay
            if (_showMiniHud)
              Positioned(
                top: 80,
                left: (_isSidebarOpen ? sidebarW : 0) + (sw - (_isSidebarOpen ? sidebarW : 0)) / 2 - 150,
                width: 300,
                child: AnimatedOpacity(
                  opacity: _showMiniHud ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.amberAccent, width: 1.5),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Text(
                      _miniHudMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

            if (_showFinalPopup) _buildSuccessPopup(),

            if (_showCurtain)
              AnimatedBuilder(
                animation: _curtainAnim,
                builder: (context, child) {
                  return Positioned.fill(
                    top: _curtainAnim.value * sh,
                    child: Container(
                      color: const Color(0xFF020617),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.change_history, size: 100, color: Color(0xFF6366f1)),
                          const SizedBox(height: 20),
                          Text(t('appTitle'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                          const SizedBox(height: 10),
                          Text(t('appSubtitle'), style: const TextStyle(fontSize: 18, color: Colors.grey)),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: () {
                              _playShutter();
                              _curtainAnimCtrl.forward().then((_) => setState(() => _showCurtain = false));
                            },
                            icon: const Icon(Icons.play_circle_fill, size: 28, color: Colors.white,),
                            label: Text(t('enterLab'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366f1),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(double worldX, double worldY, String label, IconData icon, VoidCallback onTap) {
    Matrix4 transform = Matrix4.identity()
      ..translate((MediaQuery.of(context).size.width + (_isSidebarOpen ? math.max(340.0, MediaQuery.of(context).size.width * 0.35) : 0)) / 2 + _pan.dx, MediaQuery.of(context).size.height / 2 + _pan.dy)
      ..scale(_zoom);
    Offset scr = MatrixUtils.transformPoint(transform, Offset(worldX, worldY));
    
    return Positioned(
      left: scr.dx - 50, top: scr.dy - 20,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.6 * _pulseCtrl.value), blurRadius: 20, spreadRadius: 5)],
              borderRadius: BorderRadius.circular(30)
            ),
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: Colors.white, size: 18),
              label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            ),
          );
        }
      )
    );
  }

  Widget _buildScaleSlider() {
    final conf = _sceneConfig[_scenario]!;
    Matrix4 transform = Matrix4.identity()
      ..translate((MediaQuery.of(context).size.width + (_isSidebarOpen ? math.max(340.0, MediaQuery.of(context).size.width * 0.35) : 0)) / 2 + _pan.dx, MediaQuery.of(context).size.height / 2 + _pan.dy)
      ..scale(_zoom);
    Offset scr = MatrixUtils.transformPoint(transform, Offset(conf['tx'] + (conf['tBase'] * sceneScale) / 2, conf['ty'] + 150));

    return Positioned(
      left: scr.dx - 120, top: scr.dy - 30,
      child: Container(
        width: 240, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber, width: 2)),
        child: Row(
          children: [
            const Text("SCALE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(thumbColor: Colors.amber, activeTrackColor: Colors.amber, inactiveTrackColor: Colors.grey[700], trackHeight: 4),
                child: Slider(
                  value: scale, min: 0.5, max: 3.0,
                  onChanged: (v) {
                    setState(() { scale = v; _alignTriangleToTarget(); });
                    _playFx();
                  },
                  onChangeEnd: (v) => _evaluateStepConditions(),
                ),
              ),
            ),
            Text("${scale.toStringAsFixed(2)}x", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculator() {
    return Positioned(
      left: _calcPos.dx + (_isSidebarOpen ? math.max(340.0, MediaQuery.of(context).size.width * 0.35) : 0), top: _calcPos.dy,
      child: GestureDetector(behavior: HitTestBehavior.opaque, 
        onPanUpdate: (d) => setState(() => _calcPos += d.delta),
        child: Container(
          width: 240, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.indigoAccent), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)]),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("CALCULATOR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigoAccent)),
                const Icon(Icons.drag_indicator, color: Colors.white54, size: 16),
              ]),
              const SizedBox(height: 8),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(8), alignment: Alignment.centerRight,
                decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueGrey)),
                child: Text(calcStr.isEmpty ? "0" : calcStr, style: const TextStyle(fontSize: 24, fontFamily: 'monospace', color: Colors.greenAccent, letterSpacing: 2)),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(children: [_calcBtn('7'), const SizedBox(width: 8), _calcBtn('8'), const SizedBox(width: 8), _calcBtn('9'), const SizedBox(width: 8), _calcBtn('C', color: Colors.pinkAccent)]),
                  const SizedBox(height: 8),
                  Row(children: [_calcBtn('4'), const SizedBox(width: 8), _calcBtn('5'), const SizedBox(width: 8), _calcBtn('6'), const SizedBox(width: 8), _calcBtn('-', color: Colors.amber)]),
                  const SizedBox(height: 8),
                  Row(children: [_calcBtn('1'), const SizedBox(width: 8), _calcBtn('2'), const SizedBox(width: 8), _calcBtn('3'), const SizedBox(width: 8), _calcBtn('=', color: Colors.indigoAccent)]),
                  const SizedBox(height: 8),
                  Row(children: [_calcBtn('0'), const SizedBox(width: 8), _calcBtn('180', color: Colors.blueGrey, flex: 3)]),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _calcBtn(String val, {Color color = const Color(0xFF334155), int flex = 1}) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _simCalc(val),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildSidebar(double sidebarWidth) {
    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a).withOpacity(0.95),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(5, 0))],
      ),
      child: Container(
        child: SingleChildScrollView(
          controller: _sidebarScrollCtrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(60, 20, 20, 20),
                child: Row(
                  children: [
                    const Icon(Icons.change_history, color: Color(0xFF6366f1), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('appTitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white), softWrap: true),
                          const SizedBox(height: 2),
                          Text(t('appSubtitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey), softWrap: true),
                          const SizedBox(height: 40),

              ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(behavior: HitTestBehavior.opaque, 
                          onTap: () {
                            _playClick();
                            setState(() {
                              if (_lang == 'en') _lang = 'hi'; else _lang = 'en';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                            child: Row(
                              children: [
                                const Icon(Icons.language, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(_lang.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _resetToShutter,
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                          label: Text(t('resetBtn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFf43f5e), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(t('selectScenario'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _scenario, isExpanded: true, dropdownColor: const Color(0xFF1e293b),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          items: [1, 2, 3, 4, 5].map((i) => DropdownMenuItem(value: i, child: Text(t('s${i}_title'), softWrap: true))).toList(),
                          onChanged: (val) { if (val != null) _loadScenario(val); },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: Color(0xFFf43f5e), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(t('learnLbl'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              )
                            ]
                          ),
                          const SizedBox(height: 8),
                          Text(t('s${_scenario}_obj'), style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4), softWrap: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._buildSteps(),
                    
                    if (_step >= _getScenarioStepsCount(_scenario))
                      Container(
                        margin: const EdgeInsets.only(top: 20), padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (_scenario == 5 ? Colors.orange : Colors.green).withOpacity(0.1),
                          border: Border.all(color: _scenario == 5 ? Colors.orange : Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(_scenario == 5 ? Icons.lightbulb : Icons.check_circle, color: _scenario == 5 ? Colors.orange : Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(t('summaryTitle'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _scenario == 5 ? Colors.orangeAccent : Colors.greenAccent)),
                                )
                              ]
                            ),
                            const SizedBox(height: 8),
                            Text(t('s${_scenario}_sum'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), softWrap: true),
                            const SizedBox(height: 16),
                            if (_scenario < 5)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                child: Text(t('scenarioCompleted'), style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 13), softWrap: true),
                              )
                            else
                              ElevatedButton(
                                onPressed: () => setState(() => _showFinalPopup = true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                                child: Text(t('finishLab'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Footer incorporated into the bottom of the Scroll view
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                child: const Text("© ZeroScienceLab - Fall in love with math and Science", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), softWrap: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getScenarioStepsCount(int id) {
    if(id == 1) return 5;
    if(id >= 2 && id <= 5) return 4;
    return 4;
  }

  List<Widget> _buildSteps() {
    int numSteps = _getScenarioStepsCount(_scenario);
    return List.generate(numSteps, (i) {
      bool isActive = i == _step;
      bool isPast = i < _step;
      return Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6366f1).withOpacity(0.15) : (isPast ? Colors.white.withOpacity(0.05) : Colors.transparent),
          border: Border.all(color: isActive ? const Color(0xFF6366f1) : (isPast ? Colors.white24 : Colors.transparent)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPast) const Icon(Icons.check_circle, color: Color(0xFF10b981), size: 28)
            else if (isActive) Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFF6366f1), shape: BoxShape.circle), alignment: Alignment.center, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
            else Container(width: 28, height: 28, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), alignment: Alignment.center, child: Text('${i + 1}', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t('stepLabel')} ${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text(t('s${_scenario}_step${i + 1}_task').replaceAll('<b>', '').replaceAll('</b>', ''), style: TextStyle(color: isActive ? const Color(0xFF818cf8) : Colors.white70, fontSize: 13, height: 1.4), softWrap: true),
                  if (isPast) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: (_scenario == 5 && i == 3) ? Colors.orange.withOpacity(0.2) : const Color(0xFF10b981).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(t('s${_scenario}_step${i + 1}_out').replaceAll('<b>', '').replaceAll('</b>', ''), style: TextStyle(color: (_scenario == 5 && i == 3) ? Colors.orangeAccent : const Color(0xFF34d399), fontSize: 12), softWrap: true),
                    )
                  ]
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildSuccessPopup() {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 450,
              decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 15))]),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF10b981), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF10b981).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]), child: const Icon(Icons.flag, color: Colors.white, size: 40)),
                    const SizedBox(height: 24),
                    Text(t('labCompleted'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    Text(t('finalDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5), softWrap: true),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _resetToShutter,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(t('resetBtn'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366f1), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12, right: 12,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white70, size: 28), onPressed: () { _playClick(); setState(() { _showFinalPopup = false; }); }),
            )
          ],
        ),
      ),
    );
  }
}

// --- Canvas Rendering ---
class ASACanvasPainter extends CustomPainter {
  final double zoom; final Offset pan; final int scenario; final int step;
  final double baseLen; final int angL; final int angR;
  final bool basePlaced; final bool angLPlaced; final bool angRPlaced;
  final bool triFormed; final double triX; final double triY;
  final bool superimposed; final bool superimposedTarget;
  final int rotation; final bool isFlipped; final double scale;
  final bool calcSolved;
  final bool toolDragging; final String? toolType; final Offset dragOffset;
  final Map<String, dynamic> sceneConfig;
  final double sceneScale;
  final double pulseValue;
  final Function(String) t;
  final Function(double, double) onUpdateHandle;

  ASACanvasPainter({
    required this.zoom, required this.pan, required this.scenario, required this.step,
    required this.baseLen, required this.angL, required this.angR,
    required this.basePlaced, required this.angLPlaced, required this.angRPlaced,
    required this.triFormed, required this.triX, required this.triY,
    required this.superimposed, required this.superimposedTarget,
    required this.rotation, required this.isFlipped, required this.scale,
    required this.calcSolved, required this.toolDragging, required this.toolType, required this.dragOffset,
    required this.sceneConfig, required this.sceneScale, required this.pulseValue, required this.t, required this.onUpdateHandle
  });

  Offset? _getTriangleIntersection(double bLen, double aL, double aR) {
    if (aL == 0 || aR == 0 || (aL + aR) >= 180) return null;
    double radL = aL * math.pi / 180;
    double radR = aR * math.pi / 180;
    double cx = (bLen * math.sin(radR) * math.cos(radL)) / math.sin(radL + radR);
    double cy = (bLen * math.sin(radR) * math.sin(radL)) / math.sin(radL + radR);
    return Offset(cx, cy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF020617));
    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom);

    // Grid
    Paint gridPaint = Paint()..color = const Color(0xFF1e293b)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (double i = -3000; i < 3000; i += 40) {
      canvas.drawLine(Offset(i, -3000), Offset(i, 3000), gridPaint);
      canvas.drawLine(Offset(-3000, i), Offset(3000, i), gridPaint);
    }

    double bgW = scenario == 5 ? 460 : 380;
    double bgH = scenario == 5 ? 360 : 320;
    double tBgX = sceneConfig['tx'] - 80;
    double cBgX = sceneConfig['wx'] - 80;
    double boxTop = sceneConfig['ty'] - (bgH - 100);

    // Blueprint Box
    _drawPanel(canvas, tBgX, boxTop, bgW, bgH, const Color(0xFF1e293b).withOpacity(0.7), Colors.blue);
    _drawText(canvas, t('lblBlueprint'), tBgX + bgW / 2, boxTop + 30, 16, Colors.blue, bold: true);
    _drawTriangle(canvas, sceneConfig['tx'], sceneConfig['ty'], sceneConfig['tBase'], sceneConfig['tAngL'], sceneConfig['tAngR'], sceneConfig['tRot'], sceneConfig['tFlip'], sceneScale, 'target', false);

    // Construction Zone Box
    bool isZoneActive = !superimposed;
    _drawPanel(canvas, cBgX, boxTop, bgW, bgH, const Color(0xFF1e293b).withOpacity(0.7), Colors.white54);
    _drawText(canvas, t('lblConstZone'), cBgX + bgW / 2, boxTop + 30, 14, Colors.white, bold: true);

    if (isZoneActive && !basePlaced) {
      canvas.drawLine(Offset(sceneConfig['wx'], sceneConfig['wy']), Offset(sceneConfig['wx'] + sceneConfig['startL'] * sceneScale, sceneConfig['wy']), Paint()..color = Colors.green.withOpacity(0.4)..strokeWidth = 6..strokeCap = StrokeCap.round);
    }

    double bx = superimposed ? sceneConfig['tx'] : triX;
    double by = superimposed ? sceneConfig['ty'] : triY;

    if (triFormed) {
      _drawTriangle(canvas, bx, by, baseLen, angL, angR, rotation, isFlipped, sceneScale * scale, 'active', superimposed);
    } else {
      if (basePlaced) {
        double w1 = baseLen * sceneScale;
        bool isStretching = basePlaced && !triFormed && !angLPlaced && !angRPlaced;
        bool showLengthText = scenario != 5;
        
        canvas.drawLine(Offset(sceneConfig['wx'], sceneConfig['wy']), Offset(sceneConfig['wx'] + w1, sceneConfig['wy']), Paint()..color = Colors.indigo..strokeWidth = 6..strokeCap = StrokeCap.round);
        _drawPoint(canvas, sceneConfig['wx'], sceneConfig['wy'], Colors.white, radius: 6);
        _drawPoint(canvas, sceneConfig['wx'] + w1, sceneConfig['wy'], isStretching ? Colors.greenAccent : Colors.white, radius: isStretching ? 8 : 6, pulse: isStretching);

        List<String> lbls = sceneConfig['lbls'];
        _drawText(canvas, "${lbls[0]}'", sceneConfig['wx'] - 15, sceneConfig['wy'] + 25, 15, Colors.white, bold: true);
        _drawText(canvas, "${lbls[1]}'", sceneConfig['wx'] + w1 + 15, sceneConfig['wy'] + 25, 15, Colors.white, bold: true);
        
        if (showLengthText) _drawText(canvas, "$baseLen ${t('lblUnits')}", sceneConfig['wx'] + w1 / 2, sceneConfig['wy'] + 25, 15, Colors.white, bold: true);

        if (isStretching && scenario != 5) {
          _drawRuler(canvas, sceneConfig['wx'], sceneConfig['wy'] + 45, baseLen);
        }

        if (angLPlaced) {
          canvas.save(); canvas.translate(sceneConfig['wx'], sceneConfig['wy']); canvas.rotate(-angL * math.pi / 180);
          canvas.drawLine(Offset.zero, const Offset(350, 0), Paint()..color = Colors.blue..strokeWidth = 4);
          canvas.restore();
          _drawProtractor(canvas, sceneConfig['wx'], sceneConfig['wy'], angL.toDouble(), true, false);
        }
        if (angRPlaced) {
          canvas.save(); canvas.translate(sceneConfig['wx'] + w1, sceneConfig['wy']); canvas.rotate(-(180 - angR) * math.pi / 180);
          canvas.drawLine(Offset.zero, const Offset(350, 0), Paint()..color = Colors.blue..strokeWidth = 4);
          canvas.restore();
          _drawProtractor(canvas, sceneConfig['wx'] + w1, sceneConfig['wy'], angR.toDouble(), true, true);
        }
      }
    }

    // Toolbox
    double tX = cBgX + bgW + 30;
    double tY = boxTop + 40;
    _drawPanel(canvas, tX, tY, 110, 200, const Color(0xFF1e293b), Colors.blueGrey);
    _drawText(canvas, t('lblTools'), tX + 55, tY + 25, 15, Colors.white, bold: true);
    canvas.drawLine(Offset(tX + 10, tY + 35), Offset(tX + 100, tY + 35), Paint()..color = Colors.blueGrey..strokeWidth = 1);

    bool showBeam = !basePlaced;
    bool showPro = basePlaced && !triFormed && (baseLen == sceneConfig['tBase'] || scenario == 5) && (scenario != 4 || calcSolved);

    if (showBeam) _drawToolboxIcon(canvas, tX + 25, tY + 40, 'beam', toolType == 'tool_beam');
    if (showPro) _drawToolboxIcon(canvas, tX + 25, tY + 120, 'pro', toolType == 'tool_pro');

    if (toolDragging) {
      if (toolType == 'tool_beam') {
        canvas.drawLine(Offset(dragOffset.dx - 50, dragOffset.dy), Offset(dragOffset.dx + 50, dragOffset.dy), Paint()..color = Colors.green..strokeWidth = 14..strokeCap = StrokeCap.round);
      } else if (toolType == 'tool_pro') {
        _drawProtractor(canvas, dragOffset.dx, dragOffset.dy, 0, false, false);
      }
    }

    canvas.restore();
  }

  void _drawTriangle(Canvas canvas, double cx, double cy, double bLen, int aL, int aR, int rot, bool isFlip, double scl, String style, bool isSuccess) {
    var ptC = _getTriangleIntersection(bLen, aL.toDouble(), aR.toDouble());
    if (ptC == null) return;

    double w0 = 0, y0 = 0;
    double w1 = bLen * scl;
    Offset pC = Offset(ptC.dx * scl, -ptC.dy * scl);
    double centerX = w1 / 2;
    double centerY = pC.dy / 2;

    Offset transformPt(double px, double py) {
      double x = px - centerX; double y = py - centerY;
      if (isFlip) x = -x;
      double r = rot * math.pi / 180;
      double nx = x * math.cos(r) - y * math.sin(r);
      double ny = x * math.sin(r) + y * math.cos(r);
      return Offset(nx + centerX, ny + centerY);
    }

    canvas.save();
    canvas.translate(cx, cy);

    canvas.save();
    canvas.translate(centerX, centerY);
    if (rot != 0) canvas.rotate(rot * math.pi / 180);
    if (isFlip) canvas.scale(-1, 1);
    canvas.translate(-centerX, -centerY);

    Path path = Path()..moveTo(w0, y0)..lineTo(w1, y0)..lineTo(pC.dx, pC.dy)..close();

    if (style == 'target') {
      canvas.drawPath(path, Paint()..color = Colors.blue.withOpacity(0.15)..style = PaintingStyle.fill);
      _drawDashedPath(canvas, path, Paint()..color = Colors.blue..style = PaintingStyle.stroke..strokeWidth = 4, [8, 8]);
    } else if (style == 'active') {
      if (isSuccess) {
        canvas.drawPath(path, Paint()..color = (scenario == 5 ? Colors.orange : Colors.green).withOpacity(0.3)..style = PaintingStyle.fill);
        canvas.drawPath(path, Paint()..color = (scenario == 5 ? Colors.orange : Colors.green)..style = PaintingStyle.stroke..strokeWidth = 6..strokeJoin = StrokeJoin.round);
      } else {
        canvas.drawPath(path, Paint()..color = Colors.orangeAccent.withOpacity(0.2)..style = PaintingStyle.fill);
        canvas.drawPath(path, Paint()..color = Colors.orangeAccent..style = PaintingStyle.stroke..strokeWidth = 6..strokeJoin = StrokeJoin.round);
      }
    }
    canvas.restore();

    Offset t0 = transformPt(w0, y0);
    Offset t1 = transformPt(w1, y0);
    Offset tC = transformPt(pC.dx, pC.dy);
    Offset tMid = transformPt(w1 / 2, y0);

    List<String> lbls = sceneConfig['lbls'];

    if (style == 'target') {
      if (scenario == 4) {
        _drawText(canvas, "7 ${t('lblUnits')}", tMid.dx, tMid.dy + 25, 16, Colors.white, bold: true);
        _drawText(canvas, "75°", t0.dx + (t1.dx - t0.dx) * 0.2, t0.dy - 15, 16, Colors.white, bold: true);
        _drawText(canvas, "60°", tC.dx, tC.dy + 30, 16, Colors.white, bold: true);
        if (!calcSolved) _drawText(canvas, "?", t1.dx - 25, t1.dy - 15, 16, Colors.redAccent, bold: true);
        else _drawText(canvas, "45°", t1.dx - 25, t1.dy - 15, 16, Colors.white, bold: true);
      } else if (scenario != 5) {
        _drawText(canvas, "$bLen ${t('lblUnits')}", tMid.dx, tMid.dy + 25, 16, Colors.white, bold: true);
        _drawText(canvas, "$aL°", t0.dx + (t1.dx - t0.dx) * 0.2, t0.dy - 15, 16, Colors.white, bold: true);
        _drawText(canvas, "$aR°", t1.dx - (t1.dx - t0.dx) * 0.2, t1.dy - 15, 16, Colors.white, bold: true);
      } else if (scenario == 5) {
        _drawText(canvas, "?", tMid.dx, tMid.dy + 25, 16, Colors.white, bold: true);
        _drawText(canvas, "$aL°", t0.dx + (t1.dx - t0.dx) * 0.2, t0.dy - 15, 16, Colors.white, bold: true);
        _drawText(canvas, "$aR°", t1.dx - (t1.dx - t0.dx) * 0.2, t1.dy - 15, 16, Colors.white, bold: true);
      }
      _drawText(canvas, lbls[0], t0.dx - 15, t0.dy + 25, 15, Colors.blueGrey, bold: true);
      _drawText(canvas, lbls[1], t1.dx + 15, t1.dy + 25, 15, Colors.blueGrey, bold: true);
      _drawText(canvas, lbls[2], tC.dx, tC.dy - 20, 15, Colors.blueGrey, bold: true);
    } else if (style == 'active') {
      if (isSuccess) {
        String tLabel = scenario == 5 ? t('mismatchLbl') : t('congruentLbl');
        _drawText(canvas, tLabel, w1 / 2, pC.dy - 40, 30, scenario == 5 ? Colors.orangeAccent : Colors.greenAccent, bold: true);
      } else {
        _drawPoint(canvas, t0.dx, t0.dy, Colors.white, radius: 6);
        _drawPoint(canvas, t1.dx, t1.dy, Colors.white, radius: 6);
        _drawPoint(canvas, tC.dx, tC.dy, Colors.white, radius: 6);

        _drawText(canvas, "${lbls[0]}'", t0.dx - 15, t0.dy + 25, 15, Colors.white, bold: true);
        _drawText(canvas, "${lbls[1]}'", t1.dx + 15, t1.dy + 25, 15, Colors.white, bold: true);
        _drawText(canvas, "${lbls[2]}'", tC.dx, tC.dy - 20, 15, Colors.white, bold: true);

        if (basePlaced && scenario != 5) _drawText(canvas, "$bLen ${t('lblUnits')}", tMid.dx, tMid.dy + 25, 16, Colors.white, bold: true);
        if (scenario == 5 && basePlaced) _drawText(canvas, "?", tMid.dx, tMid.dy + 25, 16, Colors.white, bold: true);
        if (angLPlaced) _drawText(canvas, "$aL°", t0.dx + (t1.dx - t0.dx) * 0.2, t0.dy - 15, 16, Colors.white, bold: true);
        if (angRPlaced) _drawText(canvas, "$aR°", t1.dx - (t1.dx - t0.dx) * 0.2, t1.dy - 15, 16, Colors.white, bold: true);
      }

      if (triFormed && !superimposed && step >= 2 && (scenario == 2 || scenario == 3)) {
        double hx = centerX + 110;
        double hy = centerY;
        Offset tHandle = transformPt(hx, hy);
        
        _drawPoint(canvas, tHandle.dx, tHandle.dy, const Color(0xFF334155), radius: 20, pulse: true);
        _drawText(canvas, '↻', tHandle.dx, tHandle.dy + 2, 24, Colors.white, bold: true);
        onUpdateHandle(cx + tHandle.dx, cy + tHandle.dy);
      }
    }

    canvas.restore();
  }

  void _drawProtractor(Canvas canvas, double x, double y, double angleDeg, bool isPlaced, bool isRightSide) {
    canvas.save(); canvas.translate(x, y);
    canvas.drawArc(const Rect.fromLTWH(-120, -120, 240, 240), math.pi, math.pi, true, Paint()..color = const Color(0xFF1e293b).withOpacity(isPlaced ? 0.9 : 0.5)..style = PaintingStyle.fill);
    canvas.drawArc(const Rect.fromLTWH(-120, -120, 240, 240), math.pi, math.pi, true, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawArc(const Rect.fromLTWH(-40, -40, 80, 80), math.pi, math.pi, false, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 3);
    
    for (int i = 0; i <= 18; i++) {
      double a = math.pi - (i * math.pi / 18); bool isMaj = i % 3 == 0;
      double r1 = isMaj ? 100 : 110;
      canvas.drawLine(Offset(math.cos(a) * r1, -math.sin(a) * r1), Offset(math.cos(a) * 120, -math.sin(a) * 120), Paint()..color = const Color(0xFF6366f1)..strokeWidth = 2);
      if (isMaj) _drawText(canvas, "${i * 10}", math.cos(a) * 85, -math.sin(a) * 85, 9, Colors.white);
    }

    if (isPlaced && angleDeg > 0) {
      double vAng = isRightSide ? (180 - angleDeg) : angleDeg;
      canvas.rotate(-vAng * math.pi / 180);
      canvas.drawLine(Offset.zero, const Offset(300, 0), Paint()..color = Colors.yellow..strokeWidth = 4);
      _drawPoint(canvas, 130, 0, Colors.amber, radius: 8, pulse: true);
      
      canvas.translate(160, -30); canvas.rotate(vAng * math.pi / 180);
      _drawPanel(canvas, -30, -15, 60, 30, const Color(0xFF1e293b), Colors.blueGrey);
      _drawText(canvas, "${angleDeg.round()}°", 0, 0, 16, Colors.lightBlue, bold: true);
    }
    canvas.restore();
  }

  void _drawRuler(Canvas canvas, double x, double y, double lenCm) {
    canvas.save(); canvas.translate(x, y);
    double maxPhysLen = 16 * sceneScale;
    _drawPanel(canvas, -20, 0, maxPhysLen + 40, 45, const Color(0xFF1e293b), Colors.blueGrey);
    
    for (int i = 0; i <= 15; i++) {
      double px = i * sceneScale;
      canvas.drawRect(Rect.fromLTWH(px, 0, 2, 15), Paint()..color = Colors.blueGrey);
      _drawText(canvas, "$i", px, 32, 12, Colors.blueGrey, bold: true);
      if (i < 15) {
        for (int j = 1; j < 10; j++) {
          canvas.drawRect(Rect.fromLTWH(px + j * (sceneScale / 10), 0, 1, j == 5 ? 10 : 6), Paint()..color = Colors.blueGrey);
        }
      }
    }
    
    double pxLen = lenCm * sceneScale;
    canvas.drawRect(Rect.fromLTWH(0, 0, pxLen, 45), Paint()..color = Colors.indigoAccent.withOpacity(0.15));
    _drawPanel(canvas, pxLen / 2 - 35, 10, 70, 26, const Color(0xFF0f172a), Colors.indigo);
    _drawText(canvas, "$lenCm ${t('lblUnits')}", pxLen / 2, 23, 14, Colors.indigoAccent, bold: true);
    _drawPoint(canvas, pxLen, 0, Colors.blue, radius: 8, pulse: true);
    canvas.restore();
  }

  void _drawToolboxIcon(Canvas canvas, double x, double y, String iconType, bool isDragging) {
    if (isDragging) return;
    _drawPanel(canvas, x, y, 60, 60, const Color(0xFF0f172a), Colors.blueGrey);
    canvas.save(); canvas.translate(x + 30, y + 30);
    if (iconType == 'beam') {
      canvas.drawLine(const Offset(-20, 0), const Offset(20, 0), Paint()..color = Colors.green..strokeWidth = 6..strokeCap = StrokeCap.round);
      _drawPoint(canvas, -20, 0, Colors.white, radius: 3); _drawPoint(canvas, 20, 0, Colors.white, radius: 3);
    } else if (iconType == 'pro') {
      canvas.drawArc(const Rect.fromLTWH(-20, -15, 40, 40), math.pi, math.pi, true, Paint()..color = const Color(0xFF6366f1).withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawArc(const Rect.fromLTWH(-20, -15, 40, 40), math.pi, math.pi, true, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    canvas.restore();
  }

  void _drawPanel(Canvas canvas, double x, double y, double w, double h, Color fill, Color stroke) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(8)), Paint()..color = fill);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(8)), Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawPoint(Canvas canvas, double x, double y, Color color, {double radius = 5, bool pulse = false}) {
    if (pulse) canvas.drawCircle(Offset(x, y), radius * 2.5 + pulseValue * radius, Paint()..color = color.withOpacity(0.4));
    canvas.drawCircle(Offset(x, y), radius, Paint()..color = color);
    canvas.drawCircle(Offset(x, y), radius, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double size, Color color, {bool bold = false}) {
    TextPainter tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontFamily: 'Roboto', fontWeight: bold ? FontWeight.bold : FontWeight.normal)), textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    tp.layout(); tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, List<double> dashArray) {
    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0; bool draw = true;
      while (distance < pathMetric.length) {
        double len = dashArray[draw ? 0 : 1];
        if (draw) canvas.drawPath(pathMetric.extractPath(distance, distance + len), paint);
        distance += len; draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
