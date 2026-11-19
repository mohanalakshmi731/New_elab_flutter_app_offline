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
      title: 'Geometric Twins: The AAS Congruence Proof',
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
      home: const AASCongruenceLab(),
    );
  }
}

class AASCongruenceLab extends StatefulWidget {
  const AASCongruenceLab({super.key});

  @override
  State<AASCongruenceLab> createState() => _AASCongruenceLabState();
}

class _AASCongruenceLabState extends State<AASCongruenceLab> with TickerProviderStateMixin {
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
  late AnimationController _gameLoopCtrl; 
  late AnimationController _pulseCtrl;
  final ScrollController _sidebarScrollCtrl = ScrollController();

  // --- Simulation States ---
  String? _toolType;
  bool _toolDragging = false;
  Offset _dragOffset = Offset.zero;
  String? _activeTool; 
  
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
  int isShaking = 0; 
  bool showFlipBtn = false;

  double? _handleX;
  double? _handleY;
  int partShakeTimer = 0;
  Offset _laserPanelPos = const Offset(40, 150);
  Offset _activeStepPos = const Offset(20, 80);

  // S4 specific
  Map<int, bool> measuredParts = {1: false, 2: false, 3: false};
  Map<int, Offset> partPos = {
    1: const Offset(-220, 150),
    2: const Offset(0, 150),
    3: const Offset(220, 150),
  };
  int? partIsShaking;
  int? partIsRed;

  // S5 specific
  Offset? startPoint;
  int baseLenInput = 6;
  int angLInput = 30;
  int angRInput = 30;
  bool isLaserCutting = false;
  double laserCuttingProgress = 0.0;
  String laserErrorText = "";
  double boatOffset = 0.0;
  Timer? _laserTimer;

  double _hypot(double x, double y) => math.sqrt(x * x + y * y);

  final Map<int, Map<String, dynamic>> _sceneConfig = {
    1: {'tBase': 10.0, 'tAngL': 65, 'tAngR': 70, 'tRot': 0, 'tFlip': false, 'startL': 4.0, 'tx': -250.0, 'ty': -20.0, 'wx': 180.0, 'wy': -20.0, 'lbls': ['B', 'C', 'A']},
    2: {'tBase': 8.0, 'tAngL': 50, 'tAngR': 60, 'tRot': 0, 'tFlip': false, 'startL': 4.0, 'tx': -400.0, 'ty': -40.0, 'wx': 40.0, 'wy': -40.0, 'lbls': ['Y', 'Z', 'X']},
    3: {'tBase': 10.0, 'tAngL': 60, 'tAngR': 40, 'tRot': 0, 'tFlip': false, 'startL': 4.0, 'tx': -400.0, 'ty': -40.0, 'wx': 40.0, 'wy': -40.0, 'lbls': ['Q', 'R', 'P']},
    4: {'tBase': 10.0, 'tAngL': 60, 'tAngR': 45, 'tRot': 0, 'tFlip': false, 'startL': 4.0, 'tx': -300.0, 'ty': -150.0, 'wx': 150.0, 'wy': 150.0, 'lbls': ['A', 'B', 'C']},
    5: {'tBase': 12.0, 'tAngL': 35, 'tAngR': 95, 'tRot': 0, 'tFlip': true, 'startL': 6.0, 'tx': -200.0, 'ty': 150.0, 'wx': 180.0, 'wy': 50.0, 'lbls': ['', '', '']},
  };
  final double sceneScale = 22.0;

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

    _gameLoopCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _gameLoopCtrl.addListener(() {
      if (mounted) {
        setState(() {
          if (isShaking > 0) isShaking--;
          if (partShakeTimer > 0) {
            partShakeTimer--;
            if (partShakeTimer == 0) {
              partIsShaking = null;
              partIsRed = null;
            }
          }
        });
      }
    });

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
    _gameLoopCtrl.dispose();
    _pulseCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    _laserTimer?.cancel();
    super.dispose();
  }

  void _playClick() { try { _clickPlayer.play(AssetSource(_clickUrl)); } catch (_) {} }
  void _playSuccess() { try { _successPlayer.play(AssetSource(_successUrl)); } catch (_) {} }
  void _playError() { try { _errorPlayer.play(AssetSource(_errorUrl)); } catch (_) {} }
  void _playFx() { try { _fxPlayer.play(AssetSource(_alertUrl)); } catch (_) {} }
  void _playShutter() { try { _shutterPlayer.play(AssetSource(_shutterUrl)); } catch (_) {} }

  String t(String key) {
    Map<String, Map<String, String>> translations = {
      'en': {
        'appTitle': "Geometric Twins: The AAS Congruence Proof", 'appSubtitle': "Class 7 • GEOMETRIC TWINS", 'enterLab': "Enter Lab",
        'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'learnLbl': "What We Learn:", 'summaryTitle': "Discovery Made!",
        'resetBtn': "Reset", 'finishLab': "Finish Lab",
        'scenarioCompleted': "✅ Scenario Completed! Please try the next scenario from the dropdown above.",
        'labCompleted': "Lab Completed!", 'finalDesc': "You have mastered AAS Congruence! By understanding that two angles automatically define the third, you proved that Angle-Angle-Side is just a shortcut to ASA.",
        'congruentLbl': "CONGRUENT (AAS)!", 'mismatchLbl': "MISMATCH",
        'lblTools': "Toolbox", 'btnFlip': "FLIP", 'btnRot': "ROTATE", 'btnCut': "CUT SAIL", 'btnSum': "Summary", 'btnNext': "NEXT",
        'lblConstZone': "Construction Area", 'lblBlueprint': "Master Blueprint", 'lblTargetMeas': "Measurements",
        'lblUnits': "cm", 'lblUnitsFt': "ft",
        'laserPanelTitle': "LASER CUTTER PANEL", 'lenSetter': "Length Setter", 'angSetter1': "Angle Setter (1)", 'angSetter2': "Angle Setter (2)", 'setSpecsBtn': "Set Laser Specifications", 'laserError': "Incorrect Specifications! Check the AAS properties of Sail A and try again.", 'clothHeader': "PREMIUM SAILCLOTH ROLL (RAW MATERIAL)",

        'tool_beam': "Beam Tool", 'tool_pro': "Protractor", 'tool_measure': "Scanner", 'tool_rotate': "Rotate Tool", 'tool_flip': "Flip Tool",
        's4_parts_title': "Replacement Parts",

        's1_title': "1. The Perfect Match", 's1_obj': "To visually verify that two triangles with identical AAS measurements are congruent by direct superimposition.",
        's1_step1_task': "Observe the two triangles, Triangle A (blue) and Triangle B (green), on the workbench. Notice the highlighted parts: two angles and one non-included side are marked with identical values on both triangles.", 's1_step1_out': "The student recognizes the given equal parts (Angle-Angle-Side).",
        's1_step2_task': "DRAG Triangle B directly on top of Triangle A.", 's1_step2_out': "Triangle B snaps perfectly onto Triangle A, aligning all vertices and sides. The combined shape glows.",
        's1_step3_task': "CLICK the 'Summary' button that appears.", 's1_step3_out': "Perfect fit confirmed. When two angles and a non-included side of one triangle match another, they are identical twins.", 's1_sum': "AAS Verified! The triangles match perfectly without needing to check all 6 parts.",

        's2_title': "2. The Hidden Connection (AAS to ASA)", 's2_obj': "To understand why AAS works by discovering that the third angles are also equal, revealing the ASA condition.",
        's2_step1_task': "Observe the two new triangles on the screen. Again, notice that two angles and a non-included side are marked as equal (∠P=∠X=70°, ∠Q=∠Y=50°, side QR=YZ=8cm).", 's2_step1_out': "The student identifies the given AAS conditions.",
        's2_step2_task': "DRAG the 'Protractor Tool' from the toolbox and DROP it onto the unmarked angle ∠R of triangle ∆PQR.", 's2_step2_out': "The protractor measures the angle and displays its value, 60°.",
        's2_step3_task': "Now, DRAG the 'Protractor Tool' and DROP it onto the unmarked angle ∠Z of triangle ∆XYZ.", 's2_step3_out': "The protractor measures the angle and reveals it is also 60°.",
        's2_step4_task': "Observe how the highlighted parts have changed.", 's2_step4_out': "The highlights shift to show the Angle-Side-Angle (ASA) condition.",
        's2_step5_task': "DRAG triangle ∆XYZ onto ∆PQR to confirm they are congruent.", 's2_step5_out': "The triangles superimpose perfectly.", 's2_sum': "AAS is a shortcut for ASA! Since all angles in a triangle add to 180°, if two angles match, the third must match too!",

        's3_title': "3. The Rotated Replica", 's3_obj': "To demonstrate that congruence holds even if a figure is rotated or flipped.",
        's3_step1_task': "Observe the two triangles. Triangle C is upright, while Triangle D is upside down and mirrored. Note that their AAS measurements are identical.", 's3_step1_out': "Triangles have the same properties but different orientations.",
        's3_step2_task': "Try to DRAG Triangle D onto Triangle C.", 's3_step2_out': "The triangle will not snap into place and bounces back.",
        's3_step3_task': "Select the 'Rotate Tool' from the toolbox and CLICK on Triangle D twice to turn it right-side up.", 's3_step3_out': "Triangle D rotates 90 degrees with each click.",
        's3_step4_task': "Now, select the 'Flip Tool' from the toolbox and CLICK on Triangle D to mirror it.", 's3_step4_out': "Triangle D flips horizontally to match the orientation of Triangle C.",
        's3_step5_task': "DRAG the correctly oriented Triangle D onto Triangle C.", 's3_step5_out': "The triangles now superimpose perfectly, confirming congruence.", 's3_sum': "Congruent twins can be rotated or flipped. The AAS rule still works regardless of orientation!",

        's4_title': "4. The Truss Bridge Repair", 's4_obj': "To apply AAS congruence to find the correct replacement part for a structure.",
        's4_step1_task': "A diagram of a bridge truss is shown with one triangular piece missing. A 'Blueprint' shows its required AAS measurements (60°, 75°, side 10m).", 's4_step1_out': "The student understands the required specifications.",
        's4_step2_task': "Below the bridge are three triangular Replacement Parts. DRAG the 'Scanner' onto each part to reveal its properties.", 's4_step2_out': "The student measures all parts and identifies Part 2 as the exact congruent match.",
        's4_step3_task': "DRAG the correct replacement part (Part 2) into the empty slot in the bridge truss.", 's4_step3_out': "Part 2 snaps into place perfectly, securing the bridge! Other parts are rejected.", 's4_sum': "BRIDGE SECURE! You successfully used AAS congruence to find the exact prefabricated replacement part, maintaining full structural integrity!",

        's5_title': "5. The Sailboat Symmetry", 's5_obj': "To construct a congruent triangle using the AAS criteria.",
        's5_step1_task': "You see a sailboat with one sail (Sail A) attached to the mast. The AAS measurements for Sail A are displayed (∠1=35°, ∠2=95°, Side=12ft). Your mission is to create a matching sail for the other side.", 's5_step1_out': "The student notes the required measurements for the new sail.",
        's5_step2_task': "A large rectangular piece of 'Sailcloth' is provided. CLICK on the Sailcloth to mark a starting point for a side.", 's5_step2_out': "A glowing starting vertex point appears on the cloth.",
        's5_step3_task': "Configure the Base to be 12ft, and set the two base angles to be 35° and 95° in the control panel to set up the correct congruent structure. Click 'Set Specs'.", 's5_step3_out': "The student inputs the correct values to draw the new triangle.",
        's5_step4_task': "CLICK the 'Cut Sail' button. The laser will trace the triangle you defined.", 's5_step4_out': "A new sail (Sail B) is cut out from the cloth.",
        's5_step5_task': "Select the 'Flip Tool' from the toolbox, CLICK on Sail B to horizontally mirror it, and then DRAG Sail B onto the mast.", 's5_step5_out': "If constructed and flipped correctly, it fits perfectly on the sailboat's mast!", 's5_sum': "Sailboat ready! You successfully created a mirror-symmetric congruent sail using AAS specifications. The wind is in your sails!"
      },
      'hi': {
        'appTitle': "ज्यामितीय जुड़वाँ: AAS सर्वांगसमता", 'appSubtitle': "कक्षा 7 • ज्यामितीय जुड़वाँ", 'enterLab': "लैब में प्रवेश करें",
        'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'learnLbl': "हम क्या सीखते हैं:", 'summaryTitle': "खोज की गई!",
        'resetBtn': "रीसेट करें", 'finishLab': "लैब समाप्त करें",
        'scenarioCompleted': "✅ परिदृश्य पूर्ण हुआ! कृपया ऊपर दिए गए ड्रॉपडाउन से अगला परिदृश्य चुनें।",
        'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने AAS सर्वांगसमता में महारत हासिल कर ली है! यह समझकर कि दो कोण स्वचालित रूप से तीसरे को परिभाषित करते हैं, आपने साबित कर दिया कि कोण-कोण-भुजा ASA का ही एक शॉर्टकट है।",
        'congruentLbl': "सर्वांगसम (AAS)!", 'mismatchLbl': "बेमेल",
        'lblTools': "टूलबॉक्स", 'btnFlip': "पलटें", 'btnRot': "घुमाएं", 'btnCut': "पाल काटें", 'btnSum': "सारांश", 'btnNext': "आगे",
        'lblConstZone': "निर्माण क्षेत्र", 'lblBlueprint': "मास्टर ब्लूप्रिंट", 'lblTargetMeas': "मापन",
        'lblUnits': "cm", 'lblUnitsFt': "ft",
        'laserPanelTitle': "लेज़र कटर पैनल", 'lenSetter': "लंबाई सेटर", 'angSetter1': "कोण सेटर (1)", 'angSetter2': "कोण सेटर (2)", 'setSpecsBtn': "लेज़र विनिर्देश सेट करें", 'laserError': "गलत विनिर्देश! पाल A के AAS गुणों की जाँच करें और पुनः प्रयास करें।", 'clothHeader': "प्रीमियम सेल्क्लोथ रोल (कच्चा माल)",

        'tool_beam': "बीम टूल", 'tool_pro': "प्रोट्रैक्टर", 'tool_measure': "स्कैनर", 'tool_rotate': "घुमाएँ टूल", 'tool_flip': "फ्लिप टूल",
        's4_parts_title': "प्रतिस्थापन भाग",

        's1_title': "1. एकदम सही मेल", 's1_obj': "प्रत्यक्ष सुपरइम्पोजिशन द्वारा यह दृश्य रूप से सत्यापित करना कि समान AAS माप वाले दो त्रिभुज सर्वांगसम हैं।",
        's1_step1_task': "वर्कबेंच पर दो त्रिभुजों, त्रिभुज A (नीला) और त्रिभुज B (हरा) का निरीक्षण करें। हाइलाइट किए गए भागों पर ध्यान दें: दो कोण और एक गैर-शामिल भुजा दोनों त्रिभुजों पर समान मानों के साथ चिह्नित हैं।", 's1_step1_out': "छात्र दिए गए समान भागों (कोण-कोण-भुजा) को पहचानता है।",
        's1_step2_task': "त्रिभुज B को सीधे त्रिभुज A के ऊपर खींचें।", 's1_step2_out': "त्रिभुज B पूरी तरह से त्रिभुज A पर स्नैप करता है, सभी शीर्षों और भुजाओं को संरेखित करता है।",
        's1_step3_task': "दिखाई देने वाले 'सारांश' बटन पर क्लिक करें।", 's1_step3_out': "एकदम सही मेल सिद्ध! जब एक त्रिभुज के दो कोण और एक गैर-शामिल भुजा दूसरे से मेल खाते हैं, तो त्रिभुज समान जुड़वां होते हैं।", 's1_sum': "AAS सत्यापित! सभी 6 भागों की जाँच किए बिना त्रिभुज पूरी तरह से मेल खाते हैं।",

        's2_title': "2. छिपा हुआ संबंध (AAS से ASA)", 's2_obj': "यह समझने के लिए कि AAS क्यों काम करता है, यह खोजकर कि तीसरे कोण भी समान हैं, जो ASA स्थिति को प्रकट करता है।",
        's2_step1_task': "स्क्रीन पर दो नए त्रिभुजों को देखें। फिर से, ध्यान दें कि दो कोण और एक गैर-शामिल भुजा समान के रूप में चिह्नित हैं (∠P=∠X=70°, ∠Q=∠Y=50°, भुजा QR=YZ=8cm)।", 's2_step1_out': "छात्र दिए गए AAS स्थितियों की पहचान करता है।",
        's2_step2_task': "टूलबॉक्स से 'प्रोट्रैक्टर टूल' खींचें और इसे त्रिभुज ∆PQR के अचिह्नित कोण ∠R पर छोड़ें।", 's2_step2_out': "प्रोट्रैक्टर कोण को मापता है और उसका मान, 60° प्रदर्शित करता है।",
        's2_step3_task': "अब, 'प्रोट्रैक्टर टूल' खींचें और इसे त्रिभुज ∆XYZ के अचिह्नित कोण ∠Z पर छोड़ें।", 's2_step3_out': "प्रोट्रैक्टर कोण को मापता है और बताता है कि यह भी 60° है।",
        's2_step4_task': "देखें कि हाइलाइट किए गए भाग कैसे बदल गए हैं।", 's2_step4_out': "हाइलाइट्स कोण-भुजा-कोण (ASA) स्थिति दिखाने के लिए शिफ्ट होते हैं।",
        's2_step5_task': "सर्वांगसमता की पुष्टि करने के लिए त्रिभुज ∆XYZ को ∆PQR पर खींचें।", 's2_step5_out': "त्रिभुज पूरी तरह से एक दूसरे के ऊपर आते हैं।", 's2_sum': "AAS, ASA का एक शॉर्टकट है! चूँकि त्रिभुज के सभी कोण 180° तक जुड़ते हैं, यदि दो कोण मेल खाते हैं, तो तीसरा भी मेल खाना चाहिए!",

        's3_title': "3. घुमाई गई प्रतिकृति", 's3_obj': "यह प्रदर्शित करने के लिए कि कोई आकृति घुमाई या पलटी जाने पर भी सर्वांगसमता बनी रहती है।",
        's3_step1_task': "दोनों त्रिभुजों का निरीक्षण करें। त्रिभुज C सीधा है, जबकि त्रिभुज D उल्टा और प्रतिबिंबित है। ध्यान दें कि उनके AAS माप समान हैं।", 's3_step1_out': "त्रिभुजों के गुण समान हैं लेकिन दिशाएं भिन्न हैं।",
        's3_step2_task': "त्रिभुज D को त्रिभुज C पर खींचने का प्रयास करें।", 's3_step2_out': "त्रिभुज जगह पर स्नैप नहीं करेगा और वापस उछल जाएगा।",
        's3_step3_task': "'घुमाएँ टूल' का चयन करें और त्रिभुज D को सीधा करने के लिए उस पर दो बार क्लिक करें।", 's3_step3_out': "त्रिभुज D हर क्लिक पर 90 डिग्री घूमता है।",
        's3_step4_task': "अब, 'फ्लिप टूल' का चयन करें और त्रिभुज D को मिरर करने के लिए उस पर क्लिक करें।", 's3_step4_out': "त्रिभुज D क्षैतिज रूप से पलटकर त्रिभुज C की दिशा से मेल खाता है।",
        's3_step5_task': "सही ढंग से उन्मुख त्रिभुज D को त्रिभुज C पर खींचें।", 's3_step5_out': "त्रिभुज अब पूरी तरह से एक-दूसरे के ऊपर आते हैं, सर्वांगसमता की पुष्टि करते हैं।", 's3_sum': "सर्वांगसम जुड़वाओं को घुमाया या पलटा जा सकता है। दिशा की परवाह किए बिना AAS नियम अभी भी काम करता है!",

        's4_title': "4. ट्रस पुल मरम्मत", 's4_obj': "किसी संरचना के लिए सही प्रतिस्थापन भाग खोजने के लिए AAS सर्वांगसमता लागू करना।",
        's4_step1_task': "एक पुल ट्रस का आरेख दिखाया गया है जिसमें एक त्रिकोणीय टुकड़ा गायब है। 'ब्लूप्रिंट' इसके आवश्यक AAS माप (60°, 75°, भुजा 10m) दिखाता है।", 's4_step1_out': "छात्र आवश्यक विनिर्देशों को समझता है।",
        's4_step2_task': "इसके गुणों को प्रकट करने के लिए 'स्कैनर' को नीचे दिए गए प्रत्येक भाग पर खींचें।", 's4_step2_out': "छात्र सभी भागों को मापता है और सटीक मिलान की पहचान करता है।",
        's4_step3_task': "सही प्रतिस्थापन भाग (भाग 2) को पुल के खाली स्लॉट में खींचें।", 's4_step3_out': "भाग 2 पूरी तरह से जगह पर फिट बैठता है, पुल को सुरक्षित करता है! अन्य भाग वापस उछल जाते हैं।", 's4_sum': "पुल सुरक्षित! आपने संरचनात्मक अखंडता सुनिश्चित करते हुए, सही प्रतिस्थापन भाग खोजने के लिए AAS सर्वांगसमता का सफलतापूर्वक उपयोग किया।",

        's5_title': "5. सेलबोट समरूपता", 's5_obj': "AAS मानदंड का उपयोग करके एक सर्वांगसम त्रिभुज का निर्माण करना।",
        's5_step1_task': "आप एक पाल (पाल ए) के साथ एक सेलबोट देखते हैं। AAS माप ∠1=35°, ∠2=95°, भुजा=12ft हैं। आपका मिशन दूसरी तरफ के लिए एक मिलान पाल बनाना है।", 's5_step1_out': "छात्र आवश्यक मापों को नोट करता है।",
        's5_step2_task': "कपड़ा क्षेत्र पर कहीं भी क्लिक करें ताकि निर्माण का शुरुआती बिंदु सेट हो सके।", 's5_step2_out': "कपड़े पर एक चमकदार शुरुआती बिंदु प्रकट होता है।",
        's5_step3_task': "कंट्रोल पैनल का उपयोग करके बेस लेंथ को 12ft तथा दोनों कोणों को क्रमशः 35° और 95° पर सैट करें। विनिर्देश सेट करें।", 's5_step3_out': "छात्र त्रिभुज का आकार परिभाषित करने के लिए सही मान सैट करता है।",
        's5_step4_task': "'पाल काटें' (CUT SAIL) बटन पर क्लिक करें। लेज़र आपके द्वारा सैट किए गए त्रिभुज को काटेगा।", 's5_step4_out': "कपड़ा से नया पाल B कट कर तैयार होता है।",
        's5_step5_task': "'फ्लिप टूल' चुनें, पाल B पर क्लिक करके इसे पलटें, और फिर उसे मस्तूल के खाली हिस्से की ओर खींचें।", 's5_step5_out': "नया पाल B मस्तूल पर पूरी तरह से फिट बैठता है!", 's5_sum': "सेलबोट तैयार! आपने सफलतापूर्वक AAS विशिष्टताओं के आधार पर एक सुडौल सर्वांगसम पाल का निर्माण किया है। हवा आपके अनुकूल है!"
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
      showFlipBtn = false;
      _handleX = null;
      _handleY = null;
      _toolDragging = false;
      _toolType = null;
      _activeTool = null;
      isShaking = 0;

      measuredParts = {1: false, 2: false, 3: false};
      partPos = { 1: const Offset(-220, 150), 2: const Offset(0, 150), 3: const Offset(220, 150) };
      partIsShaking = null;
      partIsRed = null;
      partShakeTimer = 0;

      startPoint = null;
      baseLenInput = 6;
      angLInput = 30;
      angRInput = 30;
      isLaserCutting = false;
      laserCuttingProgress = 0.0;
      laserErrorText = "";
      boatOffset = 0.0;
      
      final conf = _sceneConfig[_scenario]!;
      baseLen = conf['tBase'];
      angL = conf['tAngL'];
      angR = conf['tAngR'];
      
      if(id == 1) { triFormed = true; triX = conf['wx']; triY = conf['wy']; }
      if(id == 2) { triFormed = true; triX = conf['wx']; triY = conf['wy']; }
      if(id == 3) { triFormed = true; triX = conf['wx']; triY = conf['wy']; rotation = 180; isFlipped = true; }
      if(id == 4) { triFormed = true; }
      if(id == 5) { triFormed = false; triX = conf['wx']; triY = conf['wy']; rotation = 0; isFlipped = false; }
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
      _playSuccess();
    });
  }

  void _evaluateStepConditions() {
    final conf = _sceneConfig[_scenario]!;
    bool advanced = false;

    if (_scenario == 1) {
      if (_step == 1 && superimposed) advanced = true;
    }
    else if (_scenario == 2) {
      if (_step == 1 && angLPlaced) advanced = true;
      else if (_step == 2 && angRPlaced) advanced = true;
      else if (_step == 4 && superimposed) advanced = true;
    }
    else if (_scenario == 3) {
      if (_step == 2 && rotation == 0) { _activeTool = null; advanced = true; }
      else if (_step == 3 && isFlipped == false) { _activeTool = null; advanced = true; }
      else if (_step == 4 && superimposed) advanced = true;
    }
    else if (_scenario == 4) {
      if (_step == 2 && superimposed) advanced = true;
    }
    else if (_scenario == 5) {
      if (_step == 4 && superimposed) advanced = true;
    }

    if (advanced) {
      if (_scenario != 1 || _step != 1) _playSuccess();
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

    if (_scenario == 1 && _step == 1 && !superimposed) {
      if (_hypot(pt.dx - (triX + (conf['tBase']*sceneScale)/2), pt.dy - (triY - 30)) < 150) {
        _toolDragging = true; _toolType = 'tri_drag'; _dragOffset = Offset(triX - pt.dx, triY - pt.dy); _playClick(); return;
      }
    }
    else if (_scenario == 2) {
      double bgW = 380; double bgH = 320; double cBgX = conf['wx'] - 80; double boxTop = conf['ty'] - (bgH - 120);
      double tX = cBgX + bgW + 30; double tY = boxTop + 40;
      
      if (!superimposed) {
        if ((_step == 1 || _step == 2) && _hitTestBox(tX+25, tY+40, 60, 60, pt)) {
          _toolDragging = true; _toolType = 'tool_pro'; _dragOffset = pt; _playClick(); return;
        }
        if (_step == 4 && _hypot(pt.dx - (triX + (conf['tBase']*sceneScale)/2), pt.dy - (triY - 30)) < 150) {
          _toolDragging = true; _toolType = 'tri_drag'; _dragOffset = Offset(triX - pt.dx, triY - pt.dy); _playClick(); return;
        }
      }
    }
    else if (_scenario == 3) {
      double bgW = 380; double bgH = 320; double cBgX = conf['wx'] - 80; double boxTop = conf['ty'] - (bgH - 120);
      double tX = cBgX + bgW + 30; double tY = boxTop + 40;

      if (!superimposed) {
        if (_step == 2 && _hitTestBox(tX+25, tY+40, 60, 60, pt)) {
          setState(() => _activeTool = 'rotate'); _playClick(); return;
        }
        if (_step == 3 && _hitTestBox(tX+25, tY+120, 60, 60, pt)) {
          setState(() => _activeTool = 'flip'); _playClick(); return;
        }

        if (_hypot(pt.dx - (triX + (conf['tBase']*sceneScale)/2), pt.dy - (triY - 30)) < 150) {
          if (_activeTool == 'rotate' && _step == 2) {
            setState(() { rotation = (rotation + 90) % 360; }); _playFx(); _evaluateStepConditions(); return;
          }
          if (_activeTool == 'flip' && _step == 3) {
            setState(() { isFlipped = !isFlipped; }); _playFx(); _evaluateStepConditions(); return;
          }
          if (_step == 1 || _step == 4) {
            _toolDragging = true; _toolType = 'tri_drag'; _dragOffset = Offset(triX - pt.dx, triY - pt.dy); _playClick(); return;
          }
        }
      }
    }
    else if (_scenario == 4) {
      double tX = 360; double tY = -60;
      if (_step == 1 && !superimposed && _hitTestBox(tX+25, tY+40, 60, 60, pt)) {
        _toolDragging = true; _toolType = 'tool_measure'; _dragOffset = pt; _playClick(); return;
      }

      if (_step == 2 && !superimposed) {
        Map<int, double> pBases = {1: 8.0, 2: 10.0, 3: 11.0};
        for (int id in [1, 2, 3]) {
          Offset pos = partPos[id]!;
          if (_hypot(pt.dx - (pos.dx + (pBases[id]!*20)/2), pt.dy - (pos.dy - 30)) < 120) {
            _toolDragging = true; _toolType = 'tri_part_$id'; _dragOffset = Offset(pos.dx - pt.dx, pos.dy - pt.dy); _playClick(); return;
          }
        }
      }
    }
    else if (_scenario == 5) {
      double cBgX = 100, cBgY = -150, bgW = 400, bgH = 350;
      double tX = cBgX + bgW + 30; double tY = cBgY + 50;

      if (_step == 1) {
        if (pt.dx > 110 && pt.dx < 490 && pt.dy > -140 && pt.dy < 190) {
          setState(() {
            startPoint = Offset(pt.dx, pt.dy);
            basePlaced = true; triFormed = false;
            baseLenInput = 6; angLInput = 30; angRInput = 30;
          });
          _playFx(); _advanceStep(); return;
        }
      }

      if (_step == 4 && !superimposed) {
        if (_hitTestBox(tX+25, tY+40, 60, 60, pt)) {
          setState(() { _activeTool = _activeTool == 'flip' ? null : 'flip'; }); _playClick(); return;
        }
        if (_hypot(pt.dx - (triX + (baseLen*sceneScale)/2), pt.dy - (triY - 30)) < 150) {
          if (_activeTool == 'flip') {
            setState(() { isFlipped = !isFlipped; _activeTool = null; }); _playFx(); _evaluateStepConditions(); return;
          }
          _toolDragging = true; _toolType = 'tri_drag'; _dragOffset = Offset(triX - pt.dx, triY - pt.dy); _playClick(); return;
        }
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

    setState(() {
      if (_toolType == 'tool_beam' || _toolType == 'tool_pro' || _toolType == 'tool_measure') {
        _dragOffset = pt;
      }
      else if (_toolType == 'tri_drag') {
        triX = pt.dx + _dragOffset.dx;
        triY = pt.dy + _dragOffset.dy;
      }
      else if (_toolType != null && _toolType!.startsWith('tri_part_')) {
        int id = int.parse(_toolType!.split('_')[2]);
        partPos[id] = Offset(pt.dx + _dragOffset.dx, pt.dy + _dragOffset.dy);
      }
    });

    if (_scenario == 4 && _toolDragging && _toolType == 'tool_measure') {
      Map<int, double> pX = {1: -220, 2: 0, 3: 220};
      for (int id in [1,2,3]) {
        if (_hypot(_dragOffset.dx - pX[id]!, _dragOffset.dy - 150) < 125) {
          if (!measuredParts[id]!) {
            setState(() { measuredParts[id] = true; }); _playFx();
          }
        }
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_toolDragging) return;
    String tool = _toolType!;
    _toolDragging = false;
    _toolType = null;
    
    final conf = _sceneConfig[_scenario]!;

    setState(() {
      if (tool == 'tool_pro') {
        if (_scenario == 2) {
          double txR = conf['tx'] + conf['tBase']*sceneScale; double tyR = conf['ty'];
          double wxZ = triX + conf['tBase']*sceneScale; double wyZ = triY;
          
          if (_step == 1 && !angLPlaced && _hypot(_dragOffset.dx - txR, _dragOffset.dy - tyR) < 100) {
            angLPlaced = true; _playFx();
          } else if (_step == 2 && angLPlaced && !angRPlaced && _hypot(_dragOffset.dx - wxZ, _dragOffset.dy - wyZ) < 100) {
            angRPlaced = true; _playFx();
          } else { _playError(); }
        }
      }
      else if (tool == 'tool_measure') {
        int? measuredId;
        if (_hypot(_dragOffset.dx - (-220 + 80), _dragOffset.dy - (150 - 30)) < 120) measuredId = 1;
        else if (_hypot(_dragOffset.dx - (0 + 100), _dragOffset.dy - (150 - 30)) < 120) measuredId = 2;
        else if (_hypot(_dragOffset.dx - (220 + 110), _dragOffset.dy - (150 - 30)) < 120) measuredId = 3;
        
        if (measuredId != null) {
          measuredParts[measuredId] = true; _playFx();
        } else { _playError(); }
      }
      else if (tool == 'tri_drag') {
        double targetX = conf['tx'];
        double targetY = conf['ty'];

        bool isAligned = true;
        if (_scenario == 3) {
          isAligned = (rotation == 0) && (isFlipped == false);
        } else if (_scenario == 5) {
          if (angL == 35) isAligned = (isFlipped == true);
          else if (angL == 95) isAligned = (isFlipped == false);
          else isAligned = false; 
        } else {
          isAligned = (rotation == conf['tRot']) && (isFlipped == conf['tFlip']);
        }

        if (_hypot(triX - targetX, triY - targetY) < 150) {
          if (isAligned) {
            triX = targetX; triY = targetY; superimposed = true; _playFx();
          } else {
            if (_scenario == 3 && _step == 1) {
              isShaking = 30; _playError(); triX = conf['wx']; triY = conf['wy'];
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted && _step == 1) _advanceStep();
              });
            } else {
              if (_scenario == 5 && startPoint != null) {
                triX = startPoint!.dx; triY = startPoint!.dy;
              } else {
                triX = conf['wx']; triY = conf['wy'];
              }
              _playError();
            }
          }
        } else {
          _playClick(); 
          if (_scenario == 5 && startPoint != null) {
            triX = startPoint!.dx; triY = startPoint!.dy;
          } else {
            triX = conf['wx']; triY = conf['wy'];
          }
        }
      }
      else if (tool.startsWith('tri_part_')) {
        int id = int.parse(tool.split('_')[2]);
        Offset pos = partPos[id]!;
        double targetX = 0; double targetY = -150;

        if (_hypot(pos.dx - targetX, pos.dy - targetY) < 120) {
          if (id == 2) { 
            partPos[id] = Offset(targetX, targetY);
            superimposed = true;
            _playFx();
            _checkScenarioSuccess();
          } else {
            partIsShaking = id;
            partIsRed = id;
            partShakeTimer = 30;
            _playError();
            
            double initialX = id == 1 ? -220 : 220;
            partPos[id] = Offset(initialX, 150);
          }
        } else {
          double initialX = id == 1 ? -220 : id == 2 ? 0 : 220;
          partPos[id] = Offset(initialX, 150);
          _playClick();
        }
      }

      _evaluateStepConditions();
    });
  }

  void _confirmLaserSpecs() {
    setState(() {
      bool isLenOk = (baseLenInput == 12);
      bool isAngOk = (angLInput == 35 && angRInput == 95) || (angLInput == 95 && angRInput == 35);
      
      if (isLenOk && isAngOk) {
        baseLen = 12;
        angL = angLInput;
        angR = angRInput;
        triFormed = true;
        laserErrorText = "";
        _playSuccess();
        _advanceStep();
      } else {
        _playError();
        laserErrorText = t('laserError');
      }
    });
  }

  void _startLaserCutAnimation() {
    setState(() {
      isLaserCutting = true;
      laserCuttingProgress = 0.0;
      _playFx();
      
      _laserTimer?.cancel();
      _laserTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!mounted) return;
        setState(() {
          laserCuttingProgress += 0.015;
          if (laserCuttingProgress >= 1.0) {
            timer.cancel();
            isLaserCutting = false;
            laserCuttingProgress = 0.0;
            if (startPoint != null) {
              triX = startPoint!.dx; triY = startPoint!.dy;
            }
            rotation = 0; isFlipped = false; scale = 1.0;
            _playSuccess();
            _advanceStep();
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    double sidebarW = math.max(340.0, sw * 0.30);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
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
                            painter: AASCanvasPainter(
                              zoom: _zoom, pan: _pan, scenario: _scenario, step: _step,
                              baseLen: baseLen, angL: angL, angR: angR,
                              basePlaced: basePlaced, angLPlaced: angLPlaced, angRPlaced: angRPlaced,
                              triFormed: triFormed, triX: triX, triY: triY,
                              superimposed: superimposed, superimposedTarget: superimposedTarget,
                              rotation: rotation, isFlipped: isFlipped, scale: scale, isShaking: isShaking,
                              toolDragging: _toolDragging, toolType: _toolType, dragOffset: _dragOffset,
                              activeTool: _activeTool, measuredParts: measuredParts, partPos: partPos, partIsShaking: partIsShaking, partIsRed: partIsRed,
                              startPoint: startPoint, baseLenInput: baseLenInput, angLInput: angLInput, angRInput: angRInput,
                              isLaserCutting: isLaserCutting, laserCuttingProgress: laserCuttingProgress, boatOffset: boatOffset,
                              sceneConfig: _sceneConfig[_scenario]!,
                              sceneScale: sceneScale,
                              pulseValue: _pulseCtrl.value,
                              t: t,
                              onUpdateHandle: (x, y) {
                                _handleX = x; _handleY = y;
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

            // Floating Navigation Buttons Over Canvas (like HTML)
            if (_scenario == 1 && _step == 0) _buildNextButton(0, 150),
            if (_scenario == 1 && _step == 2 && superimposed) _buildSummaryButton(_sceneConfig[1]!['tx'] + (_sceneConfig[1]!['tBase']*sceneScale)/2, _sceneConfig[1]!['ty'] + 60),
            if (_scenario == 2 && (_step == 0 || _step == 3)) _buildNextButton(0, 150),
            if (_scenario == 3 && _step == 0) _buildNextButton(0, 150),
            if (_scenario == 4 && _step == 0) _buildNextButton(0, 150),
            if (_scenario == 4 && _step == 1 && measuredParts[2] == true) _buildNextButton(0, 150),
            if (_scenario == 5 && _step == 0) _buildNextButton(-200, 220),

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

            if (_scenario == 5 && _step == 2)
              _buildLaserPanel(),

            if (_scenario == 5 && _step == 3 && triFormed && !superimposed)
              _buildFloatingButton(startPoint!.dx + (baseLen*sceneScale)/2, startPoint!.dy + 60, t('btnCut'), Icons.cut, _startLaserCutAnimation),

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
                        Text(t('s${_scenario}_step${_step + 1}_task').replaceAll('<b>', '').replaceAll('</b>', ''), style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4), softWrap: true),
                      ],
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
                          Text(t('appTitle'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center, softWrap: true),
                          const SizedBox(height: 10),
                          Text(t('appSubtitle'), style: const TextStyle(fontSize: 18, color: Colors.grey), softWrap: true),
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

  Widget _buildNextButton(double worldX, double worldY) {
    return _buildFloatingButton(worldX, worldY, t('btnNext'), Icons.arrow_forward, () {
      _playFx();
      _advanceStep();
    });
  }

  Widget _buildSummaryButton(double worldX, double worldY) {
    return _buildFloatingButton(worldX, worldY, t('btnSum'), Icons.fact_check, () {
      _checkScenarioSuccess();
    }, color: Colors.green);
  }

  Widget _buildFloatingButton(double worldX, double worldY, String label, IconData icon, VoidCallback onTap, {Color color = Colors.indigo}) {
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
              boxShadow: [BoxShadow(color: color.withOpacity(0.6 * _pulseCtrl.value), blurRadius: 20, spreadRadius: 5)],
              borderRadius: BorderRadius.circular(30)
            ),
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: Colors.white, size: 18),
              label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            ),
          );
        }
      )
    );
  }

  Widget _buildLaserPanel() {
    return Positioned(
      left: _laserPanelPos.dx, top: _laserPanelPos.dy,
      child: GestureDetector(behavior: HitTestBehavior.opaque, 
        onPanUpdate: (d) => setState(() => _laserPanelPos += d.delta),
        child: Container(
          width: 320, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.95), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueGrey), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [const Icon(Icons.cut, size: 16, color: Colors.indigoAccent), const SizedBox(width: 8), Text(t('laserPanelTitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigoAccent))]),
                const Icon(Icons.drag_indicator, color: Colors.white54, size: 16),
              ]),
              const SizedBox(height: 16),
              
              _buildLaserSlider(t('lenSetter'), baseLenInput, 3, 18, (v) => setState((){ baseLenInput = v.toInt(); _playFx(); }), 'ft'),
              _buildLaserSlider(t('angSetter1'), angLInput, 15, 150, (v) => setState((){ angLInput = v.toInt(); _playFx(); }), '°'),
              _buildLaserSlider(t('angSetter2'), angRInput, 15, 150, (v) => setState((){ angRInput = v.toInt(); _playFx(); }), '°'),

              if (laserErrorText.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(laserErrorText, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center, softWrap: true),
                ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _confirmLaserSpecs,
                icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                label: Text(t('setSpecsBtn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaserSlider(String label, int val, int min, int max, Function(double) onChanged, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
            Text("$val $unit", style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(thumbColor: Colors.indigoAccent, activeTrackColor: Colors.indigoAccent, inactiveTrackColor: Colors.blueGrey, trackHeight: 4),
          child: Slider(value: val.toDouble(), min: min.toDouble(), max: max.toDouble(), onChanged: onChanged),
        ),
      ],
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
                                child: Text(t('learnLbl'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), softWrap: true),
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
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(t('summaryTitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.greenAccent), softWrap: true),
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
    if(id == 1) return 3;
    if(id == 4) return 3;
    return 5;
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
                      decoration: BoxDecoration(color: const Color(0xFF10b981).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(t('s${_scenario}_step${i + 1}_out').replaceAll('<b>', '').replaceAll('</b>', ''), style: const TextStyle(color: Color(0xFF34d399), fontSize: 12), softWrap: true),
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
class AASCanvasPainter extends CustomPainter {
  final double zoom; final Offset pan; final int scenario; final int step;
  final double baseLen; final int angL; final int angR;
  final bool basePlaced; final bool angLPlaced; final bool angRPlaced;
  final bool triFormed; final double triX; final double triY;
  final bool superimposed; final bool superimposedTarget;
  final int rotation; final bool isFlipped; final double scale; final int isShaking;
  final bool toolDragging; final String? toolType; final Offset dragOffset;
  final String? activeTool;
  final Map<int, bool> measuredParts;
  final Map<int, Offset> partPos;
  final int? partIsShaking; final int? partIsRed;
  final Offset? startPoint; final int baseLenInput; final int angLInput; final int angRInput;
  final bool isLaserCutting; final double laserCuttingProgress; final double boatOffset;
  final Map<String, dynamic> sceneConfig;
  final double sceneScale;
  final double pulseValue;
  final Function(String) t;
  final Function(double, double) onUpdateHandle;

  AASCanvasPainter({
    required this.zoom, required this.pan, required this.scenario, required this.step,
    required this.baseLen, required this.angL, required this.angR,
    required this.basePlaced, required this.angLPlaced, required this.angRPlaced,
    required this.triFormed, required this.triX, required this.triY,
    required this.superimposed, required this.superimposedTarget,
    required this.rotation, required this.isFlipped, required this.scale, required this.isShaking,
    required this.toolDragging, required this.toolType, required this.dragOffset,
    required this.activeTool, required this.measuredParts, required this.partPos, required this.partIsShaking, required this.partIsRed,
    required this.startPoint, required this.baseLenInput, required this.angLInput, required this.angRInput,
    required this.isLaserCutting, required this.laserCuttingProgress, required this.boatOffset,
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

    if (scenario == 1) {
      double bgW = 340; double bgH = 400; double tBgX = sceneConfig['tx'] - 60; double cBgX = sceneConfig['wx'] - 60; double boxTop = sceneConfig['ty'] - 320;
      
      _drawPanel(canvas, tBgX, boxTop, bgW, bgH, const Color(0xFF1e293b).withOpacity(0.7), Colors.blue);
      _drawText(canvas, "Triangle A", tBgX + bgW/2, boxTop + 30, 16, Colors.blue, bold: true);
      _drawTriangle(canvas, sceneConfig['tx'], sceneConfig['ty'], sceneConfig['tBase'], sceneConfig['tAngL'], sceneConfig['tAngR'], 0, false, sceneScale, 's1_target', false);

      if (!superimposed) {
        _drawPanel(canvas, cBgX, boxTop, bgW, bgH, const Color(0xFF1e293b).withOpacity(0.7), Colors.green);
        _drawText(canvas, "Triangle B", cBgX + bgW/2, boxTop + 30, 16, Colors.green, bold: true);
      }

      double bx = superimposed ? sceneConfig['tx'] : triX;
      double by = superimposed ? sceneConfig['ty'] : triY;
      _drawTriangle(canvas, bx, by, sceneConfig['tBase'], sceneConfig['tAngL'], sceneConfig['tAngR'], 0, false, sceneScale, superimposed ? 's1_success' : 's1_active', superimposed);
    } 
    else if (scenario == 2 || scenario == 3) {
      double bgW = 380; double bgH = 320; double tBgX = sceneConfig['tx'] - 80; double cBgX = sceneConfig['wx'] - 80; double boxTop = sceneConfig['ty'] - (bgH - 120);
      
      _drawPanel(canvas, tBgX, boxTop, bgW, bgH, const Color(0xFF1e293b).withOpacity(0.7), Colors.blue);
      _drawText(canvas, scenario==2?"∆PQR":"Triangle C", tBgX + bgW/2, boxTop + 30, 16, Colors.blue, bold: true);
      _drawTriangle(canvas, sceneConfig['tx'], sceneConfig['ty'], sceneConfig['tBase'], sceneConfig['tAngL'], sceneConfig['tAngR'], 0, false, sceneScale, 'target', false);

      if (!superimposed) {
        _drawPanel(canvas, cBgX, boxTop, bgW, bgH, const Color(0xFF1e293b).withOpacity(0.7), Colors.green);
        _drawText(canvas, scenario==2?"∆XYZ":"Triangle D", cBgX + bgW/2, boxTop + 30, 16, Colors.green, bold: true);
      }

      double bx = superimposed ? sceneConfig['tx'] : triX;
      double by = superimposed ? sceneConfig['ty'] : triY;

      String activeStyle = 'active';
      if (scenario == 3 && isShaking > 0) {
        bx += (math.Random().nextDouble() - 0.5) * 20;
        by += (math.Random().nextDouble() - 0.5) * 20;
        activeStyle = 'error';
      }

      if (superimposed) {
        _drawTriangle(canvas, bx, by, sceneConfig['tBase'], sceneConfig['tAngL'], sceneConfig['tAngR'], rotation, isFlipped, sceneScale, 'active', true, scenario==2 ? 70 : null);
      } else {
        _drawTriangle(canvas, bx, by, sceneConfig['tBase'], sceneConfig['tAngL'], sceneConfig['tAngR'], rotation, isFlipped, sceneScale, activeStyle, false, scenario==2 ? 70 : null);
      }

      double tX = cBgX + bgW + 30; double tY = boxTop + 40;
      
      if (scenario == 2 && !superimposed && (step == 1 || step == 2)) {
        _drawToolboxFrame(canvas, tX, tY, 110, 130, t('lblTools'));
        _drawToolboxIcon(canvas, tX+25, tY+40, 'pro', toolType == 'tool_pro', false);
      }
      
      if (scenario == 3 && !superimposed && (step >= 2)) {
        bool showToolbox = (step == 2 || step == 3);
        if (showToolbox) {
          _drawToolboxFrame(canvas, tX, tY, 110, 215, t('lblTools'));
          if (step >= 2) _drawToolboxIcon(canvas, tX+25, tY+40, 'rotate', false, activeTool == 'rotate');
          if (step >= 3) _drawToolboxIcon(canvas, tX+25, tY+120, 'flip', false, activeTool == 'flip');
        }
      }
    } 
    else if (scenario == 4) {
      double bx = -400, by = -150;
      _drawBridge(canvas, bx, by, 800);
      
      double bpX = -460; double bpY = -120;
      _drawPanel(canvas, bpX, bpY, 180, 200, const Color(0xFF1e293b).withOpacity(0.95), Colors.blue);
      _drawText(canvas, t('lblBlueprint'), bpX + 90, bpY + 30, 16, Colors.blue, bold: true);
      _drawTriangle(canvas, bpX + 30, bpY + 140, 10, 60, 45, 0, false, 12, 'solid', false, 75);

      double px = -340, py = 120;
      _drawPanel(canvas, px, py, 680, 180, const Color(0xFF1e293b).withOpacity(0.8), Colors.blueGrey);
      _drawText(canvas, t('s4_parts_title'), 0, py + 30, 16, Colors.white, bold: true);
      
      Map<int, Map<String, dynamic>> pConf = {
        1: {'baseL': 8.0, 'angL': 60, 'angR': 45},
        2: {'baseL': 10.0, 'angL': 60, 'angR': 45},
        3: {'baseL': 11.0, 'angL': 50, 'angR': 60}
      };

      for (int id in [1, 2, 3]) {
        Offset pos = partPos[id]!;
        double cfgBase = pConf[id]!['baseL'];
        int cfgAngL = pConf[id]!['angL'];
        int cfgAngR = pConf[id]!['angR'];
        
        double drawX = pos.dx;
        double drawY = pos.dy;
        
        if (partIsShaking == id) {
          drawX += (math.Random().nextDouble() - 0.5) * 10;
          drawY += (math.Random().nextDouble() - 0.5) * 10;
        }

        String style = 'solid';
        if (id == 2 && superimposed) style = 's1_success';
        else if (partIsRed == id) style = 'error';

        _drawTriangle(canvas, drawX, drawY, cfgBase, cfgAngL, cfgAngR, 0, false, 20, style, superimposed && id == 2);

        if (!(superimposed && id == 2)) {
          _drawText(canvas, "Part $id", pos.dx + (cfgBase * 20)/2, pos.dy + 45, 13, Colors.blueGrey, bold: true);
        }
      }

      double tX = 360; double tY = -60;
      if (!superimposed && step == 1) {
        _drawToolboxFrame(canvas, tX, tY, 110, 130, t('lblTools'));
        _drawToolboxIcon(canvas, tX+25, tY+40, 'measure', toolType == 'tool_measure', false);
      }
    } 
    else if (scenario == 5) {
      double animOffset = 0.0;
      if (superimposed) animOffset = boatOffset;

      _drawSailboat(canvas, -200 + animOffset, 200, superimposed);
      double curTx = -200 + animOffset; double curTy = 150;

      double cBgX = 100, cBgY = -150, bgW = 400, bgH = 350;
      _drawSailclothFabric(canvas, cBgX, cBgY, bgW, bgH, step);

      double bx = superimposed ? curTx : triX; 
      double by = superimposed ? curTy : triY;

      if (basePlaced && step < 4) {
        _drawPoint(canvas, startPoint!.dx, startPoint!.dy, Colors.greenAccent, radius: 8, pulse: true);
        
        if (step == 2) {
          var ptC = _getTriangleIntersection(baseLenInput.toDouble(), angLInput.toDouble(), angRInput.toDouble());
          if (ptC != null) {
            canvas.save();
            canvas.translate(startPoint!.dx, startPoint!.dy);
            Path p = Path()..moveTo(0,0)..lineTo(baseLenInput * sceneScale, 0)..lineTo(ptC.dx * sceneScale, -ptC.dy * sceneScale)..close();
            _drawDashedPath(canvas, p, Paint()..color = Colors.amber..strokeWidth = 3..style = PaintingStyle.stroke, [6, 6]);
            _drawText(canvas, "$baseLenInput ft", (baseLenInput*sceneScale)/2, 20, 14, Colors.white, bold: true);
            _drawText(canvas, "$angLInput°", 15, -10, 14, Colors.white, bold: true);
            _drawText(canvas, "$angRInput°", baseLenInput*sceneScale - 15, -10, 14, Colors.white, bold: true);
            canvas.restore();
          }
        }
      }

      if (isLaserCutting) {
        var ptC = _getTriangleIntersection(baseLen, angL.toDouble(), angR.toDouble());
        if (ptC != null) {
          double w1 = baseLen * sceneScale * scale;
          double pCx = ptC.dx * sceneScale * scale;
          double pCy = -ptC.dy * sceneScale * scale;
          
          List<Offset> path = [startPoint!, Offset(startPoint!.dx + w1, startPoint!.dy), Offset(startPoint!.dx + pCx, startPoint!.dy + pCy), startPoint!];
          int totalSegments = 3;
          int segmentIndex = (laserCuttingProgress * totalSegments).floor();
          double segmentProgress = (laserCuttingProgress * totalSegments) % 1;
          
          canvas.save();
          Path laserPath = Path()..moveTo(path[0].dx, path[0].dy);
          for (int i = 0; i <= segmentIndex; i++) {
            if(i < totalSegments) laserPath.lineTo(path[i+1].dx, path[i+1].dy);
          }
          if (segmentIndex < totalSegments) {
            Offset pStart = path[segmentIndex];
            Offset pEnd = path[segmentIndex + 1];
            double cX = pStart.dx + (pEnd.dx - pStart.dx) * segmentProgress;
            double cY = pStart.dy + (pEnd.dy - pStart.dy) * segmentProgress;
            laserPath.lineTo(cX, cY);
            _drawPoint(canvas, cX, cY, Colors.redAccent, radius: 8, pulse: true);
          }
          canvas.drawPath(laserPath, Paint()..color = Colors.yellow..strokeWidth = 4..style = PaintingStyle.stroke);
          canvas.restore();
        }
      }

      if (step >= 4) {
        _drawTriangle(canvas, bx, by, baseLen, angL, angR, rotation, isFlipped, sceneScale * scale, 'active', superimposed);
      }

      double tX = cBgX + bgW + 30; double tY = cBgY + 50;
      if (step == 4 && !superimposed) {
        _drawToolboxFrame(canvas, tX, tY, 110, 130, t('lblTools'));
        _drawToolboxIcon(canvas, tX+25, tY+40, 'flip', false, activeTool == 'flip');
      }
    }

    if (toolDragging) {
      if (toolType == 'tool_measure') {
        _drawRealisticToolIcon(canvas, 'measure', dragOffset.dx-30, dragOffset.dy-30, 60, true);
      }
    }

    canvas.restore();
  }

  void _drawTriangle(Canvas canvas, double cx, double cy, double bLen, int aL, int aR, int rot, bool isFlip, double scl, String style, bool isSuccess, [int? forcedThirdAngle]) {
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

    if (style == 's1_target') {
      canvas.drawPath(path, Paint()..color = Colors.blue.withOpacity(0.3)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = Colors.blue..style = PaintingStyle.stroke..strokeWidth = 4);
    } else if (style == 's1_active') {
      canvas.drawPath(path, Paint()..color = Colors.green.withOpacity(0.3)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = Colors.green..style = PaintingStyle.stroke..strokeWidth = 4);
    } else if (style == 's1_success') {
      canvas.drawPath(path, Paint()..color = Colors.green.withOpacity(0.3)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = Colors.greenAccent..style = PaintingStyle.stroke..strokeWidth = 6);
    } else if (style == 'error') {
      canvas.drawPath(path, Paint()..color = Colors.red.withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = Colors.redAccent..style = PaintingStyle.stroke..strokeWidth = 6..strokeJoin = StrokeJoin.round);
    } else if (style == 'target') {
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
    } else if (style == 'solid') {
      canvas.drawPath(path, Paint()..color = const Color(0xFF475569).withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = const Color(0xFF94a3b8)..style = PaintingStyle.stroke..strokeWidth = 4);
    }

    if (scenario == 1 && style != 's1_success') {
      canvas.drawLine(Offset(w0, y0), Offset(w1, y0), Paint()..color = Colors.amber..strokeWidth = 6);
    }

    if (scenario == 2) {
      bool highlightAAS = step < 3; // Step 0,1,2 show AAS highlights
      bool highlightASA = step >= 3; // Step 3,4 show ASA highlights
      if (highlightAAS) {
        canvas.drawLine(Offset(w0, y0), Offset(w1, y0), Paint()..color = Colors.amber..strokeWidth = 6);
      } else if (highlightASA) {
        canvas.drawLine(Offset(w0, y0), Offset(w1, y0), Paint()..color = Colors.greenAccent..strokeWidth = 6);
      }
    }
    canvas.restore();

    Offset t0 = transformPt(w0, y0);
    Offset t1 = transformPt(w1, y0);
    Offset tC = transformPt(pC.dx, pC.dy);
    Offset tMid = transformPt(w1 / 2, y0);
    Offset tSideMid = transformPt((w1 + pC.dx)/2, pC.dy/2);

    List<String> lbls = sceneConfig['lbls'];

    if (scenario == 1) {
      if (style != 's1_success') {
        _drawText(canvas, "$bLen ${t('lblUnits')}", tMid.dx, tMid.dy + 25, 18, Colors.amber, bold: true);
        _drawText(canvas, "$aL°", t0.dx + (t1.dx - t0.dx)*0.2, t0.dy - 15, 18, Colors.amber, bold: true);
        _drawText(canvas, "${180 - aL - aR}°", tC.dx, tC.dy - 25, 18, Colors.amber, bold: true);
      } else {
        _drawText(canvas, t('congruentLbl'), tMid.dx, pC.dy - 60, 24, Colors.greenAccent, bold: true);
      }
    } 
    else if (scenario == 2) {
      bool isTarget = style == 'target';
      String lblTop = isTarget ? 'P' : 'X';
      String lblL = isTarget ? 'Q' : 'Y';
      String lblR = isTarget ? 'R' : 'Z';
      _drawText(canvas, lblL, t0.dx - 15, t0.dy + 10, 18, Colors.blueGrey, bold: true);
      _drawText(canvas, lblR, t1.dx + 15, t1.dy + 10, 18, Colors.blueGrey, bold: true);
      _drawText(canvas, lblTop, tC.dx, tC.dy - 35, 18, Colors.blueGrey, bold: true);

      bool highlightAAS = step < 3;
      bool highlightASA = step >= 3;

      Color cBase = highlightAAS ? Colors.amber : (highlightASA ? Colors.greenAccent : Colors.white);
      _drawText(canvas, "$bLen ${t('lblUnits')}", tMid.dx, tMid.dy + 25, 16, cBase, bold: true);

      Color cAngL = highlightAAS ? Colors.amber : (highlightASA ? Colors.greenAccent : Colors.white);
      _drawText(canvas, "50°", t0.dx + (t1.dx - t0.dx)*0.2, t0.dy - 15, 16, cAngL, bold: true);

      Color cAngT = highlightAAS ? Colors.amber : Colors.white;
      _drawText(canvas, "70°", tC.dx + 20, tC.dy - 15, 16, cAngT, bold: true);

      if ((isTarget && angLPlaced) || (!isTarget && angRPlaced) || superimposed) {
        Color cAngR = highlightASA ? Colors.greenAccent : Colors.white;
        _drawText(canvas, "60°", t1.dx - (t1.dx - t0.dx)*0.2, t1.dy - 15, 16, cAngR, bold: true);
      }
    }
    else if (scenario == 3) {
      _drawText(canvas, "$aL°", t0.dx + (t1.dx - t0.dx)*0.2, t0.dy - 15, 16, Colors.white, bold: true);
      _drawText(canvas, "${180 - aL - aR}°", tC.dx, tC.dy - 25, 16, Colors.white, bold: true);
      _drawText(canvas, "$bLen ${t('lblUnits')}", tMid.dx, tMid.dy + 25, 16, Colors.white, bold: true);
    }
    else if (scenario == 4) {
      bool showLabels = false;
      String labelAngL = "60°"; String labelTop = "75°"; String labelSide = "10 m";
      
      if (style == 's1_target' || style == 's1_success' || (style == 'active' && isSuccess)) {
        showLabels = true;
      } else {
        if (bLen == 8 && measuredParts[1] == true) { showLabels = true; labelSide = "8 m"; }
        else if (bLen == 10 && aL == 60 && measuredParts[2] == true) { showLabels = true; }
        else if (bLen == 11 && measuredParts[3] == true) { showLabels = true; labelAngL = "50°"; labelTop = "70°"; labelSide = "11 m"; }
      }
      
      if (showLabels) {
        _drawText(canvas, labelAngL, t0.dx + (t1.dx - t0.dx)*0.2, t0.dy - 15, 16, Colors.white, bold: true);
        _drawText(canvas, labelTop, tC.dx, tC.dy - 15, 16, Colors.white, bold: true);
        _drawText(canvas, labelSide, tSideMid.dx + 30, tSideMid.dy, 16, Colors.white, bold: true);
      }
    }
    else if (scenario == 5) {
      if (style == 'target') {
        _drawText(canvas, "35°", t0.dx + (t1.dx - t0.dx)*0.2, t0.dy - 15, 16, Colors.white, bold: true);
        _drawText(canvas, "95°", tC.dx, tC.dy - 15, 16, Colors.white, bold: true);
        _drawText(canvas, "12 ${t('lblUnitsFt')}", tSideMid.dx + 30, tSideMid.dy, 16, Colors.white, bold: true);
      } else if (style == 'active') {
        _drawText(canvas, "$bLen ${t('lblUnitsFt')}", tMid.dx, tMid.dy + 25, 16, Colors.white, bold: true);
        _drawText(canvas, "$aL°", t0.dx + (t1.dx - t0.dx)*0.2, t0.dy - 15, 16, Colors.white, bold: true);
        _drawText(canvas, "$aR°", t1.dx - (t1.dx - t0.dx)*0.2, t1.dy - 15, 16, Colors.white, bold: true);
      }
    }

    if (style == 'active' && isSuccess && scenario != 1) {
      _drawText(canvas, t('congruentLbl'), w1 / 2, pC.dy - 40, 26, Colors.greenAccent, bold: true);
    }

    if (style == 'active' && triFormed && !superimposed && (scenario == 3 && step >= 2)) {
      double hx = centerX + 110; double hy = centerY; Offset tHandle = transformPt(hx, hy);
      if (activeTool == 'rotate') {
        _drawPoint(canvas, tHandle.dx, tHandle.dy, const Color(0xFF334155), radius: 20, pulse: true);
        _drawText(canvas, '↻', tHandle.dx, tHandle.dy, 24, Colors.white, bold: true);
        onUpdateHandle(cx + tHandle.dx, cy + tHandle.dy);
      }
    }

    canvas.restore();
  }

  void _drawToolboxFrame(Canvas canvas, double x, double y, double w, double h, String title) {
    _drawPanel(canvas, x, y, w, h, const Color(0xFF1e293b), Colors.blueGrey);
    _drawText(canvas, title, x + w / 2, y + 25, 15, Colors.white, bold: true);
    canvas.drawLine(Offset(x + 10, y + 35), Offset(x + w - 10, y + 35), Paint()..color = const Color(0xFF475569)..strokeWidth = 1);
  }

  void _drawToolboxIcon(Canvas canvas, double x, double y, String iconType, bool isDragging, bool isActive) {
    if (isDragging) return;
    Color bg = isActive ? const Color(0xFF312e81) : const Color(0xFF0f172a);
    Color border = isActive ? Colors.indigoAccent : Colors.blueGrey;
    _drawPanel(canvas, x, y, 60, 60, bg, border);
    _drawRealisticToolIcon(canvas, iconType, x, y, 60, isActive);
    _drawText(canvas, t('tool_$iconType'), x + 30, y + 72, 10, Colors.blueGrey, bold: true);
  }

  void _drawRealisticToolIcon(Canvas canvas, String type, double x, double y, double size, bool isActive) {
    canvas.save();
    canvas.translate(x + size/2, y + size/2);
    
    if (type == 'pro') {
      canvas.drawArc(const Rect.fromLTWH(-22, -17, 44, 44), math.pi, math.pi, true, Paint()..color = isActive ? const Color(0xFF6366f1).withOpacity(0.35) : const Color(0xFF6366f1).withOpacity(0.15)..style = PaintingStyle.fill);
      canvas.drawArc(const Rect.fromLTWH(-22, -17, 44, 44), math.pi, math.pi, true, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 2.5);
      canvas.drawLine(const Offset(-4, 5), const Offset(4, 5), Paint()..color = const Color(0xFF6366f1)..strokeWidth = 1.5);
      canvas.drawLine(const Offset(0, 1), const Offset(0, 9), Paint()..color = const Color(0xFF6366f1)..strokeWidth = 1.5);
    }
    else if (type == 'rotate') {
      canvas.drawArc(const Rect.fromLTWH(-16, -16, 32, 32), -math.pi/2, math.pi, false, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
      Path arrow = Path()..moveTo(-20, 0)..lineTo(-16, 5)..lineTo(-12, 0)..close();
      canvas.drawPath(arrow, Paint()..color = const Color(0xFF6366f1));
      canvas.drawCircle(Offset.zero, 5, Paint()..color = const Color(0xFF1e293b));
      canvas.drawCircle(Offset.zero, 5, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
    else if (type == 'flip') {
      Path p1 = Path()..moveTo(-15, 10)..lineTo(-3, 0)..lineTo(-15, -10)..close();
      canvas.drawPath(p1, Paint()..color = const Color(0xFF6366f1));
      canvas.drawPath(p1, Paint()..color = const Color(0xFF4f46e5)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      
      Path p2 = Path()..moveTo(15, 10)..lineTo(3, 0)..lineTo(15, -10)..close();
      canvas.drawPath(p2, Paint()..color = const Color(0xFF1e293b));
      canvas.drawPath(p2, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);

      _drawDashedPath(canvas, Path()..moveTo(0, -15)..lineTo(0, 15), Paint()..color = Colors.amber..strokeWidth = 2..style = PaintingStyle.stroke, [4, 3]);
    }
    else if (type == 'measure') {
      Paint p = Paint()..color = Colors.greenAccent..strokeWidth = 3..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
      canvas.drawPath(Path()..moveTo(-16, -8)..lineTo(16, -8)..moveTo(-16, -8)..lineTo(-16, 12)..moveTo(16, -8)..lineTo(16, 12), p);
      _drawPanel(canvas, -19, -12, 38, 12, Colors.greenAccent, Colors.green);
      canvas.drawRect(const Rect.fromLTWH(-11, -9, 22, 6), Paint()..color = const Color(0xFF020617));
      _drawText(canvas, "10.0", 0, -6, 6, Colors.greenAccent, bold: true);
    }

    canvas.restore();
  }

  void _drawBridge(Canvas canvas, double x, double y, double w) {
    canvas.save(); canvas.translate(x, y);
    Paint thickPaint = Paint()..color = const Color(0xFF94a3b8)..strokeWidth = 10..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(w, 0), thickPaint..strokeWidth = 12);
    canvas.drawLine(const Offset(20, 0), const Offset(20, 100), thickPaint..strokeWidth = 16);
    canvas.drawLine(Offset(w-20, 0), Offset(w-20, 100), thickPaint..strokeWidth = 16);

    int segs = 4; double segW = w/segs;
    var ptC = _getTriangleIntersection(10, 60, 45); 
    double apexX = ptC!.dx * 20; double apexY = -ptC.dy * 20;

    for(int i=0; i<segs; i++) {
      if (i==2) {
        Path slotPath = Path()..moveTo(i*segW, 0)..lineTo(i*segW + apexX, apexY)..lineTo(i*segW + segW, 0)..close();
        canvas.drawPath(slotPath, Paint()..color = const Color(0xFFf43f5e).withOpacity(0.15)..style = PaintingStyle.fill);
        _drawDashedPath(canvas, slotPath, Paint()..color = const Color(0xFFf43f5e)..strokeWidth = 4..style = PaintingStyle.stroke, [6, 6]);
      } else {
        canvas.drawLine(Offset(i*segW, 0), Offset(i*segW + apexX, apexY), thickPaint..strokeWidth = 10);
        canvas.drawLine(Offset(i*segW + apexX, apexY), Offset(i*segW + segW, 0), thickPaint);
      }
    }
    Path topChord = Path()..moveTo(apexX, apexY)..lineTo(segW+apexX, apexY)..lineTo(2*segW+apexX, apexY)..lineTo(3*segW+apexX, apexY);
    canvas.drawPath(topChord, thickPaint);
    canvas.restore();
  }

  void _drawSailboat(Canvas canvas, double x, double y, bool isComplete) {
    canvas.save(); canvas.translate(x, y);
    
    if (isComplete) {
      double driftY = math.sin(DateTime.now().millisecondsSinceEpoch / 600) * 5;
      canvas.translate(0, driftY);
    }

    Path wavePath = Path();
    for(double i = -300; i <= 300; i += 30) {
      wavePath.quadraticBezierTo(i + 15, 70, i + 30, 60);
    }
    canvas.drawPath(wavePath, Paint()..color = Colors.lightBlue.withOpacity(0.2)..strokeWidth = 4..style = PaintingStyle.stroke);

    Path hull = Path()..moveTo(-220, -10)..lineTo(220, -10)..lineTo(160, 60)..lineTo(-160, 60)..close();
    canvas.drawPath(hull, Paint()..color = const Color(0xFF1e293b));
    Path deck = Path()..moveTo(-220, -10)..lineTo(220, -10)..lineTo(210, 0)..lineTo(-210, 0)..close();
    canvas.drawPath(deck, Paint()..color = const Color(0xFF0f172a));
    
    canvas.drawLine(const Offset(0, -10), const Offset(0, -340), Paint()..color = const Color(0xFF94a3b8)..strokeWidth = 12..strokeCap = StrokeCap.round);
    
    Path flag = Path()..moveTo(0, -330)..lineTo(50, -310)..lineTo(0, -290)..close();
    canvas.drawPath(flag, Paint()..color = Colors.redAccent);

    double scale = sceneScale; double baseL = 12;
    var ptC = _getTriangleIntersection(baseL, 35, 95);
    if (ptC != null) {
      double w1 = baseL * scale;
      double pCx = ptC.dx * scale;
      double pCy = -ptC.dy * scale;
      
      canvas.save(); canvas.translate(-w1, -50);
      Path sailA = Path()..moveTo(0, 0)..lineTo(w1, 0)..lineTo(pCx, pCy)..close();
      canvas.drawPath(sailA, Paint()..color = Colors.lightBlueAccent.withOpacity(0.8));
      canvas.drawPath(sailA, Paint()..color = Colors.lightBlue..strokeWidth = 3..style = PaintingStyle.stroke);
      
      _drawText(canvas, "35°", 30, -15, 15, Colors.white, bold: true);
      _drawText(canvas, "95°", w1 - 25, -15, 15, Colors.white, bold: true);
      _drawText(canvas, "12 ft", w1 / 2, 22, 15, Colors.white, bold: true);
      canvas.restore();

      if (!isComplete) {
        canvas.save(); canvas.translate(0, -50);
        Path sailBTgt = Path()..moveTo(0, 0)..lineTo(w1, 0)..lineTo(w1 - pCx, pCy)..close();
        _drawDashedPath(canvas, sailBTgt, Paint()..color = Colors.blue..strokeWidth = 4..style = PaintingStyle.stroke, [8, 8]);
        canvas.restore();
      }
    }
    
    canvas.restore();
  }

  void _drawSailclothFabric(Canvas canvas, double x, double y, double w, double h, int step) {
    canvas.save();
    _drawPanel(canvas, x, y, w, h, const Color(0xFF475569), const Color(0xFF334155));

    Paint thread = Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 1;
    for (double i = 20; i < w; i += 20) canvas.drawLine(Offset(x + i, y), Offset(x + i, y + h), thread);
    for (double j = 20; j < h; j += 20) canvas.drawLine(Offset(x, y + j), Offset(x + w, y + j), thread);

    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromLTWH(x, y, w, 28), topLeft: const Radius.circular(12), topRight: const Radius.circular(12)), Paint()..color = const Color(0xFF1e293b));
    _drawText(canvas, t('clothHeader'), x + w/2, y + 14, 11, Colors.white, bold: true);

    if (step >= 3 && startPoint != null) {
      var ptC = _getTriangleIntersection(baseLen, angL.toDouble(), angR.toDouble());
      if (ptC != null) {
        double w1 = baseLen * sceneScale;
        double pCx = ptC.dx * sceneScale;
        double pCy = -ptC.dy * sceneScale;

        canvas.save(); canvas.translate(startPoint!.dx, startPoint!.dy);
        Path hole = Path()..moveTo(0, 0)..lineTo(w1, 0)..lineTo(pCx, pCy)..close();
        canvas.drawPath(hole, Paint()..color = const Color(0xFF020617)..style = PaintingStyle.fill);
        _drawDashedPath(canvas, hole, Paint()..color = const Color(0xFF334155)..strokeWidth = 3..style = PaintingStyle.stroke, [6, 6]);
        canvas.restore();
      }
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
