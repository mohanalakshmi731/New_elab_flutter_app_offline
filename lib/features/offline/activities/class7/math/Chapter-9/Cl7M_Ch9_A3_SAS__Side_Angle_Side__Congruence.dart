// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'dart:ui' as ui;
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
      title: 'SAS Congruence: The Blueprint',
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
      home: const SASCongruenceLab(),
    );
  }
}

class SASCongruenceLab extends StatefulWidget {
  const SASCongruenceLab({super.key});

  @override
  State<SASCongruenceLab> createState() => _SASCongruenceLabState();
}

class _SASCongruenceLabState extends State<SASCongruenceLab> with TickerProviderStateMixin {
  // --- Core State ---
  bool _isSidebarOpen = true; 
  bool _showCurtain = true;
  bool _showFinalPopup = false;
  String _lang = 'en';

  // --- Canvas Transform ---
  double _zoom = 1.0;
  Offset _pan = Offset.zero;
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

  // Network Audio Sources
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  // --- Animation & Scroll ---
  late AnimationController _curtainAnimCtrl;
  late Animation<double> _curtainAnim;
  late AnimationController _s4LiftCtrl;
  final ScrollController _sidebarScrollCtrl = ScrollController();

  // --- Interaction State ---
  String? _draggingTool;
  Offset _dragOffset = Offset.zero;
  
  // Custom Panel Positioning
  Offset _s2PanelPos = const Offset(40, 60);
  Offset _s4PanelPos = const Offset(40, 60);
  Offset _s5PanelPos = const Offset(40, 60);

  // --- Simulation States ---
  // S1
  bool s1_b8_placed = false; int s1_base_len = 4;
  bool s1_arm_placed = false; int s1_arm_len = 4;
  bool s1_pro_placed = false; int s1_pro_ang = 90;
  bool s1_welded = false; bool s1_superimposed = false;
  Offset s1_triPos = const Offset(-10, 150);
  Offset s1_b8_pos = const Offset(100, -200);
  Offset s1_b6_pos = const Offset(100, -150);
  Offset s1_pro_pos = const Offset(100, -80);
  Offset s1_dragPos = Offset.zero;

  // S2
  int s2_s1 = 5; int s2_ang = 30; int s2_s2 = 5;
  bool s2_fabricated = false; bool s2_superimposed = false;
  Offset s2_triPos = Offset.zero;

  // S3
  bool s3_b10_placed = false; Offset s3_b10_pos = const Offset(370, -280);
  bool s3_pro_placed = false; Offset s3_pro_pos = const Offset(370, -200); int s3_pro_angle = 0;
  bool s3_comp_placed = false; Offset s3_comp_pos = const Offset(370, -120); bool s3_arcDrawn = false;
  bool s3_target_placed = false; Offset s3_target_pos = const Offset(200, 150); int s3_matchIndex = -1;

  // S4
  int s4_l1 = 4; int s4_ang = 0; int s4_l2 = 4;
  bool s4_grabbed = false; double s4_lift = 0.0;

  // S5
  int s5_input1 = 10; int s5_inputA = 60; int s5_input2 = 8;
  List<Tile> s5_cutTiles = [];
  List<bool> s5_slots = [false, false, false, false, false];
  bool s5_mS1 = false; bool s5_mAng = false; bool s5_mS2 = false;
  Offset s5_toolPos = Offset.zero; int? s5_activeTileId; bool s5_isCutting = false;

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

    _s4LiftCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _s4LiftCtrl.addListener(() {
      setState(() {
        s4_lift = _s4LiftCtrl.value;
      });
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
    _s4LiftCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    super.dispose();
  }

  // --- Audio Helpers ---
  void _playClick() { try { _clickPlayer.play(AssetSource(_clickUrl)); } catch (_) {} }
  void _playSuccess() { try { _successPlayer.play(AssetSource(_successUrl)); } catch (_) {} }
  void _playError() { try { _errorPlayer.play(AssetSource(_errorUrl)); } catch (_) {} }
  void _playFx() { try { _fxPlayer.play(AssetSource(_alertUrl)); } catch (_) {} }
  void _playShutter() { try { _shutterPlayer.play(AssetSource(_shutterUrl)); } catch (_) {} }

  // --- Translations ---
  String t(String key) {
    Map<String, Map<String, String>> translations = {
      'en': {
        'appTitle': "SAS Congruence: The Blueprint", 'appSubtitle': "Class 7 • GEOMETRIC TWINS", 'enterLab': "Enter Lab",
        'selectScenario': "Select Scenario", 'stepLabel': "STEP", 'learnLbl': "What We Learn:", 'summaryTitle': "Discovery Made!",
        'resetBtn': "Reset", 'finishLab': "Finish Lab", 'nextScenario': "Next Scenario",
        'labCompleted': "Lab Completed!", 'finalDesc': "You have mastered SAS Congruence! By locking two sides and the included angle, you guarantee a unique, identical shape.",
        'congruentLbl': "CONGRUENT (SAS)!", 'mismatchLbl': "AMBIGUOUS (SSA)",
        'lblTools': "Tools", 'btnWeld': "WELD", 'btnFab': "Fabricate", 'btnGrab': "Grab Target", 'btnCut': "Cut Tile", 'btnDrawArc': "Draw Arc",
        'lblConstZone:': "Construction Zone", 'lblBlueprint': "Blueprint ∆ABC", 'lblTrussBlue': "Truss Blueprint", 'lblPartsBin': "Parts Bin", 'lblSample': "Sample Tile",
        'lblSide1': "Side 1", 'lblAngle': "Included Angle", 'lblSide2': "Side 2", 'lblFab': "TRUSS FABRICATOR", 'lblDyn': "DYNAMIC\nREADOUT",
        'lblTileCutter': "Tile Cutter", 'lblArmCtrl': "Arm Control", 'lblArm1': "Arm 1", 'lblJointAng': "Joint Angle", 'lblArm2': "Arm 2",
        'lblTargetMeas': "Target Measurements", 'lblBase10': "Base = 10 units", 'lblSide7': "Side 2 = 7 units", 'lblNonInc30': "Non-included Angle = 30°",
        'lblPt1': "Point 1", 'lblPt2': "Point 2", 'lblTrussInst': "TRUSS INSTALLED!", 'lblUnits': "units", 'footer': "© ZeroScienceLab - Fall in love with math and Science",

        's1_title': "1. The Blueprint Match", 's1_obj': "To construct a triangle identical to a given blueprint triangle by matching two sides and the included angle.",
        's1_step1_task': "A target triangle, ∆ABC, is shown on a blueprint. DRAG the 'Beam Tool' onto the workspace to create the first side.", 's1_step1_out': "Observation: A single line segment appears on the workspace.",
        's1_step2_task': "CLICK the beam you placed. DRAG the end of the beam until the ruler shows a length of 8 units.", 's1_step2_out': "Observation: The beam resizes and locks at 8 units long.",
        's1_step3_task': "DRAG the 'Protractor Tool' to the left vertex of your 8-unit beam. ROTATE the guide arm to 45°.", 's1_step3_out': "Observation: The protractor locks at a 45° angle, showing a glowing guideline.",
        's1_step4_task': "DRAG a new 'Beam Tool' to the left vertex. STRETCH this new beam along the guideline until it is 6 units.", 's1_step4_out': "Observation: The second beam is created, locked at 45° and length 6.",
        's1_step5_task': "A dotted line connects the ends. CLICK the 'WELD' button.", 's1_step5_out': "Learning: The third side forms automatically, completing the triangle.",
        's1_step6_task': "DRAG your completed triangle and DROP it on top of the blueprint ∆ABC.", 's1_step6_out': "Learning: Perfect Match! Fixing SAS guarantees identical shapes.", 's1_sum': "SAS Guarantees Congruence! If you lock two sides and the angle *between* them, the triangle's shape and size are 100% determined.",

        's2_title': "2. The Bridge Truss Repair", 's2_obj': "To build a replacement truss for a bridge by setting the correct SAS values on a machine.",
        's2_step1_task': "Drag the 'Side 1' slider to exactly 10m to match the bridge gap requirement.", 's2_step1_out': "Observation: The first side of the truss is set in the fabricator.",
        's2_step2_task': "Drag the 'Included Angle' slider to exactly 60°.", 's2_step2_out': "Observation: The joint angle expands exactly to 60°.",
        's2_step3_task': "Drag 'Side 2' to 10m, then click 'Fabricate'.", 's2_step3_out': "Observation: The final shape is locked and fabricated.",
        's2_step4_task': "Drag the newly fabricated truss into the glowing gap in the bridge.", 's2_step4_out': "Learning: It fits perfectly. Real-world manufacturing relies on SAS to ensure structural parts are identical.", 's2_sum': "Industrial Precision: By entering exactly identical Side-Angle-Side parameters, machines can mass-produce perfectly congruent parts.",

        's3_title': "3. The Ambiguity of SSA", 's3_obj': "To discover why fixing two sides and a *non-included* angle (SSA) does NOT guarantee congruence.",
        's3_step1_task': "Create the base by dragging the 10-unit beam into the Construction Zone.", 's3_step1_out': "Observation: The first side is locked (Side).",
        's3_step2_task': "Set a 30° angle at the right side of the base.", 's3_step2_out': "Observation: We have a locked angle, but the other known side (7) is NOT attached to it. This is a non-included angle.",
        's3_step3_task': "Snap the Compass to the left vertex.", 's3_step3_out': "Observation: The compass will help us trace all possible paths for a side of length 7.",
        's3_step4_task': "Click 'Draw Arc' to sweep the 7-unit length across the 30° path.", 's3_step4_out': "Observation: The arc intersects the 30° line in TWO different places! This creates two entirely different possible triangles.",
        's3_step5_task': "Try to superimpose the target triangle over the two possible shapes.", 's3_step5_out': "Learning: It only matches one! SSA is ambiguous because it can create two different shapes from the same measurements.", 's3_sum': "SSA Fails! If the angle is not *included* between the two sides, the shape is not guaranteed to be identical. It can form two different triangles.",

        's4_title': "4. Robotic Arm Challenge", 's4_obj': "To align a 2-segment robotic arm with a target by matching its internal joint angle (SAS).",
        's4_step1_task': "Use the sliders to match the physical robotic arm to the green ghost outline.", 's4_step1_out': "Observation: You are acting as the computer, dictating Side 1, Included Angle, and Side 2.",
        's4_step2_task': "Once aligned perfectly, click 'Grab Target'.", 's4_step2_out': "Learning: Robotics rely on controlling segment lengths and the angles between them to move predictably.", 's4_sum': "Kinematic Control: Controlling the exact SAS configuration allows robots to repeat precise movements in 3D space.",

        's5_title': "5. The Mosaic Masterpiece", 's5_obj': "To measure a sample tile and use its SAS properties to cut identical replacement tiles to complete a mosaic.",
        's5_step1_task': "A large, beautiful mosaic is on the screen... DRAG the 'Ruler Tool' to the sample tile and measure the length of any two sides.", 's5_step1_out': "Observation: You measure two adjacent sides and note the values.",
        's5_step2_task': "DRAG the 'Protractor Tool' to the sample tile and measure the angle *between* the two sides you just measured.", 's5_step2_out': "Observation: You measure the included angle and note the value.",
        's5_step3_task': "Enter the three measurements you found into the 'Tile Cutter' machine's input fields. Then, CLICK the 'Cut Tile' button.", 's5_step3_out': "Observation: A new tile is generated based on the input values.",
        's5_step4_task': "DRAG your newly cut tile and DROP it into one of the empty slots in the mosaic.", 's5_step4_out': "Observation: If correct, it snaps. If wrong, it is rejected and bounces back.",
        's5_step5_task': "Cut four more tiles and complete the mosaic!", 's5_step5_out': "Observation: All slots filled, masterpiece complete!", 's5_sum': "Cloning Geometry: Knowing just two sides and the included angle perfectly duplicates a triangle."
      },
      'hi': {
        'appTitle': "SAS सर्वांगसमता: ब्लूप्रिंट", 'appSubtitle': "कक्षा 7 • ज्यामितीय जुड़वाँ", 'enterLab': "लैब में प्रवेश करें",
        'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'learnLbl': "हम क्या सीखते हैं:", 'summaryTitle': "खोज की गई!",
        'resetBtn': "रीसेट करें", 'finishLab': "लैब समाप्त करें", 'nextScenario': "अगला परिदृश्य",
        'labCompleted': "लैब पूर्ण!", 'finalDesc': "आपने SAS सर्वांगसमता में महारत हासिल कर ली है! दो भुजाओं और शामिल कोण को लॉक करके, आप एक अद्वितीय, समान आकार की गारंटी देते हैं।",
        'congruentLbl': "सर्वांगसम (SAS)!", 'mismatchLbl': "अस्पष्ट (SSA)",
        'lblTools': "उपकरण", 'btnWeld': "वेल्ड करें", 'btnFab': "निर्माण करें", 'btnGrab': "लक्ष्य पकड़ें", 'btnCut': "टाइल काटें", 'btnDrawArc': "चाप बनाएं",
        'lblConstZone:': "निर्माण क्षेत्र", 'lblBlueprint': "ब्लूप्रिंट ∆ABC", 'lblTrussBlue': "ट्रस ब्लूप्रिंट", 'lblPartsBin': "पार्ट्स बिन", 'lblSample': "नमूना",
        'lblSide1': "भुजा 1", 'lblAngle': "शामिल कोण", 'lblSide2': "भुजा 2", 'lblFab': "ट्रस फैब्रिकेटर", 'lblDyn': "रीयल-टाइम\nडायनामिक",
        'lblTileCutter': "टाइल कटर", 'lblArmCtrl': "आर्म कंट्रोल", 'lblArm1': "आर्म 1", 'lblJointAng': "जोड़ कोण", 'lblArm2': "आर्म 2",
        'lblTargetMeas': "लक्ष्य मापन", 'lblBase10': "आधार = 10 इकाई", 'lblSide7': "भुजा 2 = 7 इकाई", 'lblNonInc30': "गैर-शामिल कोण = 30°",
        'lblPt1': "बिंदु 1", 'lblPt2': "बिंदु 2", 'lblTrussInst': "ट्रस स्थापित!", 'lblUnits': "इकाई", 'footer': "© ZeroScienceLab - Fall in love with math and Science",

        's1_title': "1. द ब्लूप्रिंट मैच", 's1_obj': "दी गई दो भुजाओं और शामिल कोण का उपयोग करके एक त्रिभुज बनाना, जिससे समान आकार की गारंटी मिलती है।",
        's1_step1_task': "एक लक्ष्य त्रिभुज, ∆ABC, ब्लूप्रिंट पर दिखाया गया है। पहली भुजा बनाने के लिए 'बीम टूल' को कार्यक्षेत्र में खींचें।", 's1_step1_out': "अवलोकन: कार्यक्षेत्र पर एक रेखा खंड दिखाई देता है।",
        's1_step2_task': "बीम पर क्लिक करें और सिरे को तब तक खींचें जब तक कि रूलर 8 इकाई की लंबाई न दिखाए।", 's1_step2_out': "अवलोकन: बीम 8 इकाई पर लॉक हो जाता है।",
        's1_step3_task': "'प्रोट्रैक्टर टूल' को अपने 8-इकाई बीम के बाएँ शीर्ष पर खींचें। गाइड आर्म को 45° तक घुमाएँ।", 's1_step3_out': "अवलोकन: प्रोट्रैक्टर 45° के कोण पर लॉक हो जाता है।",
        's1_step4_task': "एक नया 'बीम टूल' बाएँ शीर्ष पर खींचें। इस नए बीम को 6 इकाई तक फैलाएँ।", 's1_step4_out': "अवलोकन: दूसरा बीम 45° और लंबाई 6 पर लॉक होता है।",
        's1_step5_task': "एक बिंदीदार रेखा सिरों को जोड़ती है। 'WELD' बटन पर क्लिक करें।", 's1_step5_out': "सीख: तीसरी भुजा स्वचालित रूप से बनती है।",
        's1_step6_task': "अपने पूरे किए गए त्रिभुज को खींचें और इसे ब्लूप्रिंट ∆ABC पर छोड़ दें।", 's1_step6_out': "सीख: एकदम सही मेल! SAS सर्वांगसमता की गारंटी देता है।", 's1_sum': "SAS सर्वांगसमता की गारंटी देता है! यदि आप दो भुजाओं और उनके बीच के कोण को लॉक करते हैं, तो आकार 100% निर्धारित हो जाता है।",

        's2_title': "2. ब्रिज ट्रस मरम्मत", 's2_obj': "एक मशीन में विशिष्ट SAS मान दर्ज करके एक प्रतिस्थापन ट्रस बनाना।",
        's2_step1_task': "'Side 1' स्लाइडर को ठीक 10m पर खींचें।", 's2_step1_out': "अवलोकन: ट्रस की पहली भुजा निर्धारित हो गई है।",
        's2_step2_task': "'Included Angle' स्लाइडर को ठीक 60° पर खींचें।", 's2_step2_out': "अवलोकन: जोड़ का कोण ठीक 60° तक फैलता है।",
        's2_step3_task': "'Side 2' को 10m पर खींचें, फिर 'Fabricate' पर क्लिक करें।", 's2_step3_out': "अवलोकन: अंतिम आकार लॉक और निर्मित हो गया है।",
        's2_step4_task': "नवनिर्मित ट्रस को पुल में चमकते हुए अंतर में खींचें।", 's2_step4_out': "सीख: यह पूरी तरह फिट बैठता है। विनिर्माण SAS पर निर्भर करता है।", 's2_sum': "औद्योगिक परिशुद्धता: सटीक समान SAS पैरामीटर दर्ज करके, मशीनें समान भागों का उत्पादन कर सकती हैं।",

        's3_title': "3. SSA की अस्पष्टता", 's3_obj': "यह खोजना कि दो भुजाओं और एक *गैर-शामिल* कोण (SSA) को ठीक करना सर्वांगसमता की गारंटी क्यों नहीं देता है।",
        's3_step1_task': "10-इकाई बीम खींचकर आधार बनाएं।", 's3_step1_out': "अवलोकन: पहली भुजा लॉक हो गई है।",
        's3_step2_task': "आधार के दाईं ओर 30° का कोण सेट करें।", 's3_step2_out': "अवलोकन: यह एक गैर-शामिल कोण है।",
        's3_step3_task': "कम्पास को बाएँ शीर्ष पर स्नैप करें।", 's3_step3_out': "अवलोकन: कम्पास 7 लंबाई की भुजा के लिए पथ खींचेगा।",
        's3_step4_task': "30° पथ पर 7-इकाई लंबाई खींचने के लिए 'Draw Arc' पर क्लिक करें।", 's3_step4_out': "अवलोकन: चाप 30° रेखा को दो अलग-अलग स्थानों पर काटता है!",
        's3_step5_task': "लक्ष्य त्रिभुज को दो संभावित आकृतियों पर अध्यारोपित करने का प्रयास करें।", 's3_step5_out': "सीख: यह केवल एक से मेल खाता है! SSA अस्पष्ट है।", 's3_sum': "SSA विफल! यदि कोण दो भुजाओं के बीच *शामिल* नहीं है, तो यह दो अलग-अलग त्रिभुज बना सकता है।",

        's4_title': "4. रोबोटिक आर्म चुनौती", 's4_obj': "आंतरिक जोड़ कोण (SAS) का मिलान करके लक्ष्य के साथ रोबोटिक आर्म को संरेखित करना।",
        's4_step1_task': "भौतिक रोबोटिक आर्म को हरी भूत रूपरेखा से मिलाने के लिए स्लाइडर्स का उपयोग करें।", 's4_step1_out': "अवलोकन: आप भुजा 1, शामिल कोण, और भुजा 2 निर्धारित कर रहे हैं।",
        's4_step2_task': "एक बार पूरी तरह से संरेखित होने पर, 'Grab Target' पर क्लिक करें।", 's4_step2_out': "सीख: रोबोटिक्स खंड की लंबाई और कोणों को नियंत्रित करने पर निर्भर करते हैं।", 's4_sum': "शुद्धगतिक नियंत्रण: सटीक SAS कॉन्फ़िगरेशन को नियंत्रित करने से रोबोट सटीक गतियों को दोहरा सकते हैं।",

        's5_title': "5. मोज़ेक कृति", 's5_obj': "एक टाइल के SAS मापदंडों को मापकर उसकी सटीक प्रतिलिपि बनाना।",
        's5_step1_task': "'Ruler Tool' को नमूना टाइल पर खींचें और किन्हीं दो भुजाओं को मापें।", 's5_step1_out': "अवलोकन: आपने दो भुजाओं को मापा है।",
        's5_step2_task': "'Protractor Tool' को खींचें और शामिल कोण को मापें।", 's5_step2_out': "अवलोकन: आपने कोण मापा है।",
        's5_step3_task': "'Tile Cutter' में माप दर्ज करें और 'Cut Tile' पर क्लिक करें।", 's5_step3_out': "अवलोकन: मशीन एक डुप्लिकेट टाइल काटती है।",
        's5_step4_task': "नई टाइल को मोज़ेक में खाली स्लॉट में रखें।", 's5_step4_out': "सीख: सही होने पर यह फिट बैठता है।",
        's5_step5_task': "चार और टाइलें काटें और मोज़ेक पूरा करें!", 's5_step5_out': "सीख: मोज़ेक पूरा हुआ!", 's5_sum': "क्लोनिंग ज्यामिति: केवल दो भुजाओं और शामिल कोण को जानना किसी भी त्रिभुज को पूरी तरह से डुप्लिकेट करने के लिए पर्याप्त है।"
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
      _zoom = 1.0;
      _pan = Offset.zero;

      if(id == 1) { 
        s1_b8_placed=false; s1_base_len=4; s1_pro_placed=false; s1_pro_ang=90; 
        s1_arm_placed=false; s1_arm_len=4; s1_welded=false; s1_superimposed=false; 
        s1_triPos=const Offset(-10, 150); s1_dragPos=Offset.zero; 
        s1_b8_pos=const Offset(100,-200); s1_pro_pos=const Offset(100,-100); s1_b6_pos=const Offset(100,0); 
      }
      if(id == 2) { 
        s2_s1=5; s2_ang=30; s2_s2=5; s2_fabricated=false; s2_superimposed=false; s2_triPos=Offset.zero; 
        _s2PanelPos = const Offset(40, 60);
      }
      if(id == 3) { 
        s3_b10_placed=false; s3_pro_placed=false; s3_comp_placed=false; s3_arcDrawn=false; 
        s3_target_placed=false; s3_matchIndex=-1; 
        s3_b10_pos=const Offset(370,-280); s3_pro_pos=const Offset(370,-200); 
        s3_comp_pos=const Offset(370,-120); s3_target_pos=const Offset(200,150); 
      }
      if(id == 4) { 
        s4_l1=4; s4_ang=0; s4_l2=4; s4_grabbed=false;
        _s4LiftCtrl.reset(); s4_lift=0; 
        _s4PanelPos = const Offset(40, 60);
      }
      if(id == 5) { 
        s5_input1=10; s5_inputA=60; s5_input2=8; 
        s5_cutTiles=[]; s5_slots=[false,false,false,false,false]; 
        s5_mS1=false; s5_mAng=false; s5_mS2=false; s5_toolPos=Offset.zero; 
        s5_activeTileId=null; s5_isCutting=false; 
        _s5PanelPos = const Offset(40, 60);
      }

      // Initial Pan offsets to match the HTML behavior
      if (id == 2 || id == 4) _pan = const Offset(-100, 0);
      else if (id == 5) _pan = const Offset(-50, 0);
      else _pan = const Offset(0, -30);
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
    if (_step == 1 && _scenario == 4) _step++; // skip manual grab step
    _advanceStep();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_scenario == 3 && s3_matchIndex == -1) {
        _playError();
      } else {
        _playSuccess();
        if (_scenario == 5) {
          setState(() { _showFinalPopup = true; });
        }
      }
    });
  }

  // --- Interaction Logic ---
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
    _draggingTool = null;

    if (details.pointerCount >= 2) return; 

    Offset pt = _getScreenToWorld(details.localFocalPoint, canvasSize);

    if (_scenario == 1) {
      if (_step == 0 && !s1_b8_placed && _hitTestBox(300, -160, 60, 60, pt)) { _draggingTool = 's1_tool_beam1'; s1_dragPos = pt; _playClick(); }
      if (_step == 1 && s1_b8_placed && (pt - Offset(-10 + s1_base_len * 22, 150)).distance < 40) { _draggingTool = 's1_stretch_base'; _playClick(); }
      if (_step == 2 && !s1_pro_placed && _hitTestBox(300, -80, 60, 60, pt)) { _draggingTool = 's1_tool_pro'; s1_dragPos = pt; _playClick(); }
      if (_step == 2 && s1_pro_placed && (pt - Offset(-10 + 150 * math.cos(-s1_pro_ang * math.pi / 180), 150 + 150 * math.sin(-s1_pro_ang * math.pi / 180))).distance < 40) { _draggingTool = 's1_rot_pro'; _playClick(); }
      if (_step == 3 && !s1_arm_placed && _hitTestBox(300, -160, 60, 60, pt)) { _draggingTool = 's1_tool_beam2'; s1_dragPos = pt; _playClick(); }
      if (_step == 3 && s1_arm_placed) {
        Offset ex = Offset(-10 + s1_arm_len * 22 * math.cos(-s1_pro_ang * math.pi / 180), 150 + s1_arm_len * 22 * math.sin(-s1_pro_ang * math.pi / 180));
        if ((pt - ex).distance < 40) { _draggingTool = 's1_stretch_arm'; _playClick(); }
      }
      if (_step == 5 && s1_welded && _hitTestBox(s1_triPos.dx, s1_triPos.dy - 180, 240, 180, pt)) { _draggingTool = 's1tri'; _dragOffset = s1_triPos - pt; _playClick(); }
    } else if (_scenario == 2) {
      if (s2_fabricated && !s2_superimposed) {
        // Hit box designed to catch the triangle around s2_triPos
        if (_hitTestBox(s2_triPos.dx - 100, s2_triPos.dy - 200, 400, 300, pt)) {
          _draggingTool = 's2_truss';
          _dragOffset = s2_triPos - pt;
          _playClick();
        }
      }
    } else if (_scenario == 3) {
      if (_step == 0 && !s3_b10_placed && _hitTestBox(370, -260, 60, 60, pt)) { _draggingTool = 's3_b10'; s3_b10_pos = pt; _playClick(); }
      if (_step == 1 && !s3_pro_placed && _hitTestBox(370, -180, 60, 60, pt)) { _draggingTool = 's3_pro'; s3_pro_pos = pt; _playClick(); }
      if (_step == 1 && s3_pro_placed) {
        Offset hx = Offset(150 - 200 * math.cos(s3_pro_angle * math.pi / 180), 150 - 200 * math.sin(s3_pro_angle * math.pi / 180));
        if ((pt - hx).distance < 50) { _draggingTool = 's3_pro_ang'; _playClick(); }
      }
      if (_step == 2 && !s3_comp_placed && _hitTestBox(370, -100, 60, 60, pt)) { _draggingTool = 's3_comp'; s3_comp_pos = pt; _playClick(); }
      if (_step == 4 && _hitTestBox(s3_target_pos.dx, s3_target_pos.dy - 200, 300, 200, pt)) { _draggingTool = 's3_tar'; _dragOffset = s3_target_pos - pt; _playClick(); }
    } else if (_scenario == 5) {
      if (_step == 0 && (!s5_mS1 || !s5_mS2) && _hitTestBox(350, -210, 60, 60, pt)) { _draggingTool = 's5_ruler'; s5_toolPos = pt; _playClick(); }
      if (_step == 1 && !s5_mAng && _hitTestBox(350, -130, 60, 60, pt)) { _draggingTool = 's5_pro'; s5_toolPos = pt; _playClick(); }
      if (_step >= 3 && s5_cutTiles.isNotEmpty) {
        for (var i = s5_cutTiles.length - 1; i >= 0; i--) {
          var tile = s5_cutTiles[i];
          if ((pt - Offset(tile.x + 60, tile.y - 20)).distance < 120) {
            tile.isDragging = true; _draggingTool = 's5_tile'; _dragOffset = Offset(tile.x - pt.dx, tile.y - pt.dy); s5_activeTileId = tile.id; _playClick(); break;
          }
        }
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    if (_draggingTool == null) {
      setState(() {
        _pan += details.focalPointDelta;
        if (details.scale != 1.0) _zoom = (_baseZoom * details.scale).clamp(0.3, 3.0);
      });
      return;
    }
    
    Offset pt = _getScreenToWorld(details.localFocalPoint, canvasSize);
    setState(() {
      if (_scenario == 1) {
        if (_draggingTool == 's1_tool_beam1' || _draggingTool == 's1_tool_beam2' || _draggingTool == 's1_tool_pro') s1_dragPos = pt;
        if (_draggingTool == 's1_stretch_base') s1_base_len = math.max(3, math.min(10, ((pt.dx - (-10)) / 22).round()));
        if (_draggingTool == 's1_rot_pro') s1_pro_ang = math.max(0, math.min(180, ((math.atan2(150 - pt.dy, pt.dx - (-10)) * 180 / math.pi) / 5).round() * 5));
        if (_draggingTool == 's1_stretch_arm') s1_arm_len = math.max(3, math.min(10, ((pt - const Offset(-10, 150)).distance / 22).round()));
        if (_draggingTool == 's1tri') s1_triPos = pt + _dragOffset;
      } else if (_scenario == 2) {
        if (_draggingTool == 's2_truss') s2_triPos = pt + _dragOffset;
      } else if (_scenario == 3) {
        if (_draggingTool == 's3_b10') s3_b10_pos = pt;
        if (_draggingTool == 's3_pro') s3_pro_pos = pt;
        if (_draggingTool == 's3_pro_ang') s3_pro_angle = math.max(0, math.min(180, (math.atan2(150 - pt.dy, 150 - pt.dx) * 180 / math.pi).round()));
        if (_draggingTool == 's3_comp') s3_comp_pos = pt;
        if (_draggingTool == 's3_tar') s3_target_pos = pt + _dragOffset;
      } else if (_scenario == 5) {
        if (_draggingTool == 's5_ruler' || _draggingTool == 's5_pro') s5_toolPos = pt;
        if (_draggingTool == 's5_tile') {
          var tile = s5_cutTiles.firstWhere((t) => t.id == s5_activeTileId);
          tile.x = pt.dx + _dragOffset.dx; tile.y = pt.dy + _dragOffset.dy;
        }
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggingTool == null) return;
    String tool = _draggingTool!;
    _draggingTool = null;
    
    setState(() {
      if (_scenario == 1) {
        if (tool == 's1_tool_beam1' && (s1_dragPos - const Offset(-10, 150)).distance < 150) { s1_b8_placed = true; _playFx(); _advanceStep(); }
        if (tool == 's1_stretch_base' && s1_base_len == 8) { _playSuccess(); _advanceStep(); }
        if (tool == 's1_tool_pro' && (s1_dragPos - const Offset(-10, 150)).distance < 150) { s1_pro_placed = true; _playFx(); }
        if (tool == 's1_rot_pro') { if (s1_pro_ang == 45) { _playSuccess(); _advanceStep(); } else { _playError(); } }
        if (tool == 's1_tool_beam2' && (s1_dragPos - const Offset(-10, 150)).distance < 150) { s1_arm_placed = true; _playFx(); }
        if (tool == 's1_stretch_arm' && s1_arm_len == 6) { _playSuccess(); _advanceStep(); }
        if (tool == 's1tri' && (s1_triPos - const Offset(-300, -50)).distance < 150) { s1_triPos = const Offset(-300, -50); s1_superimposed = true; _checkScenarioSuccess(); }
      } else if (_scenario == 2) {
        if (tool == 's2_truss') {
          // target gap is at (-100, 100)
          if ((s2_triPos - const Offset(-100, 100)).distance < 150) {
            s2_triPos = const Offset(-100, 100);
            s2_superimposed = true;
            _playFx();
            _checkScenarioSuccess();
          } else {
            _playError();
          }
        }
      } else if (_scenario == 3) {
        Offset wx = const Offset(-150, 150);
        if (tool == 's3_b10') { if ((s3_b10_pos - wx).distance < 150) { s3_b10_placed = true; s3_b10_pos = wx; _playFx(); _advanceStep(); } else { _playError(); } }
        if (tool == 's3_pro') { if ((s3_pro_pos - Offset(wx.dx + 300, wx.dy)).distance < 150) { s3_pro_placed = true; s3_pro_pos = Offset(wx.dx + 300, wx.dy); _playFx(); } else { _playError(); } }
        if (tool == 's3_pro_ang') { if (s3_pro_angle >= 25 && s3_pro_angle <= 35) { s3_pro_angle = 30; _playSuccess(); _advanceStep(); } }
        if (tool == 's3_comp') { if ((s3_comp_pos - wx).distance < 150) { s3_comp_placed = true; s3_comp_pos = wx; _playFx(); _advanceStep(); } else { _playError(); } }
        if (tool == 's3_tar') {
          if ((s3_target_pos - wx).distance < 150) { s3_matchIndex = 1; s3_target_pos = wx; _checkScenarioSuccess(); }
          else { s3_target_pos = const Offset(200, 150); _playError(); }
        }
      } else if (_scenario == 5) {
        if (tool == 's5_ruler') {
          Offset p1 = const Offset(-350, -150); Offset p2 = const Offset(-350 + 10 * 12.5, -150);
          Offset p3 = Offset(-350 + 8 * 12.5 * math.cos(-60 * math.pi / 180), -150 + 8 * 12.5 * math.sin(-60 * math.pi / 180));
          bool hitEdge1 = (s5_toolPos - Offset((p1.dx + p3.dx) / 2, (p1.dy + p3.dy) / 2)).distance < 100;
          bool hitEdge2 = (s5_toolPos - Offset((p1.dx + p2.dx) / 2, p1.dy)).distance < 100;
          
          if (hitEdge1 && !s5_mS1) { s5_mS1 = true; _playFx(); }
          else if (hitEdge2 && !s5_mS2) { s5_mS2 = true; _playFx(); }
          else if (!hitEdge1 && !hitEdge2) { _playError(); }
          
          if (s5_mS1 && s5_mS2 && _step == 0) { Future.delayed(const Duration(milliseconds: 300), _advanceStep); }
        }
        if (tool == 's5_pro') {
          if (!s5_mAng && (s5_toolPos - const Offset(-350, -150)).distance < 100) {
            s5_mAng = true; _playFx(); if (_step == 1) Future.delayed(const Duration(milliseconds: 300), _advanceStep);
          } else { _playError(); }
        }
        if (tool == 's5_tile') {
          var activeTile = s5_cutTiles.firstWhere((t) => t.id == s5_activeTileId);
          activeTile.isDragging = false; bool snapped = false;
          
          List<Offset> slotPos = [const Offset(-250, 50), const Offset(-120, 50), const Offset(10, 50), const Offset(140, 50), const Offset(270, 50)];
          
          for (int i = 0; i < s5_slots.length; i++) {
            if (!s5_slots[i] && (Offset(activeTile.x, activeTile.y) - slotPos[i]).distance < 100) {
              if (activeTile.s1 == 10 && activeTile.ang == 60 && activeTile.s2 == 8) {
                s5_slots[i] = true; snapped = true;
                s5_cutTiles.removeWhere((t) => t.id == activeTile.id);
                _playFx();
                int totalFilled = s5_slots.where((s) => s).length;
                if (totalFilled == 1 && _step == 3) _advanceStep();
                else if (totalFilled == 5) _checkScenarioSuccess();
              }
              break;
            }
          }
          if (!snapped) { activeTile.x = activeTile.trayX; activeTile.y = activeTile.trayY; _playError(); }
        }
      }
    });
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    double sidebarW = math.max(340.0, sw * 0.38);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: _isSidebarOpen ? sidebarW : 0,
                child: ClipRect(child: _buildSidebar()),
              ),
              Expanded(
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return Stack(
                        children: [
                          Listener(
                            onPointerSignal: (pointerSignal) {
                              if (pointerSignal is PointerScrollEvent) {
                                setState(() {
                                  _zoom = (_zoom - pointerSignal.scrollDelta.dy * 0.001).clamp(0.3, 3.0);
                                });
                              }
                            },
                            child: GestureDetector(behavior: HitTestBehavior.opaque, 
                              onScaleStart: (d) => _onScaleStart(d, canvasSize),
                              onScaleUpdate: (d) => _onScaleUpdate(d, canvasSize),
                              onScaleEnd: _onScaleEnd,
                              child: CustomPaint(
                                size: canvasSize,
                                painter: SASCanvasPainter(
                                  zoom: _zoom, pan: _pan, scenario: _scenario, step: _step, themeLight: false,
                                  s1_b8_placed: s1_b8_placed, s1_base_len: s1_base_len, s1_pro_placed: s1_pro_placed, s1_pro_ang: s1_pro_ang,
                                  s1_arm_placed: s1_arm_placed, s1_arm_len: s1_arm_len, s1_welded: s1_welded, s1_superimposed: s1_superimposed,
                                  s1_triPos: s1_triPos, s1_b8_pos: s1_b8_pos, s1_b6_pos: s1_b6_pos, s1_pro_pos: s1_pro_pos, s1_dragPos: s1_dragPos,
                                  s2_s1: s2_s1, s2_ang: s2_ang, s2_s2: s2_s2, s2_fabricated: s2_fabricated, s2_superimposed: s2_superimposed, s2_triPos: s2_triPos,
                                  s3_b10_placed: s3_b10_placed, s3_b10_pos: s3_b10_pos, s3_pro_placed: s3_pro_placed, s3_pro_pos: s3_pro_pos, s3_pro_angle: s3_pro_angle,
                                  s3_comp_placed: s3_comp_placed, s3_comp_pos: s3_comp_pos, s3_arcDrawn: s3_arcDrawn, s3_target_pos: s3_target_pos, s3_matchIndex: s3_matchIndex,
                                  s4_l1: s4_l1, s4_ang: s4_ang, s4_l2: s4_l2, s4_grabbed: s4_grabbed, s4_lift: s4_lift,
                                  s5_cutTiles: s5_cutTiles, s5_slots: s5_slots, s5_mS1: s5_mS1, s5_mAng: s5_mAng, s5_mS2: s5_mS2, s5_toolPos: s5_toolPos, s5_isCutting: s5_isCutting,
                                  draggingTool: _draggingTool, lang: _lang, t: t,
                                ),
                              ),
                            ),
                          ),
                          ..._buildInteractivePanels(canvasSize),
                        ]
                      );
                    }
                  ),
                ),
              ),
            ],
          ),

          // Menu Icon
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
              color: Colors.orangeAccent,
              iconSize: 28,
              onPressed: () {
                HapticFeedback.lightImpact(); _playClick();
                setState(() => _isSidebarOpen = !_isSidebarOpen);
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.8))),
              ),
            ),
          ),

          // HUD
          if (_step < _getScenarioSteps(_scenario).length)
            Positioned(
              bottom: 20,
              left: (_isSidebarOpen ? sidebarW : 0) + (sw - (_isSidebarOpen ? sidebarW : 0)) / 2 - math.min((sw - (_isSidebarOpen ? sidebarW : 0)) * 0.8, 600) / 2,
              width: math.min((sw - (_isSidebarOpen ? sidebarW : 0)) * 0.8, 600),
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f172a).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: const Border(top: BorderSide(color: Color(0xFF6366f1), width: 4)),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF818cf8), size: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          t('s${_scenario}_step${_step + 1}_task'),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_showFinalPopup && _scenario == 5) _buildSuccessPopup(),

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
                        Text(t('appTitle'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
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
    );
  }

  List<Widget> _buildInteractivePanels(Size canvasSize) {
    List<Widget> panels = [];
    Matrix4 transform = Matrix4.identity()
      ..translate(canvasSize.width / 2 + _pan.dx, canvasSize.height / 2 + _pan.dy)
      ..scale(_zoom);

    if (_scenario == 1 && _step == 4 && s1_arm_placed && !s1_welded) {
      Offset pos = MatrixUtils.transformPoint(transform, const Offset(-10 + 4 * 22, 150 - 80));
      panels.add(
        Positioned(
          left: pos.dx - 60, top: pos.dy - 20,
          child: ElevatedButton(
            onPressed: () { setState(() { s1_welded = true; s1_triPos = const Offset(-10, 150); }); _playFx(); _advanceStep(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: Text(t('btnWeld'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
        ),
      );
    }
    else if (_scenario == 2 && _step < 4 && !s2_superimposed) {
      panels.add(
        Positioned(
          left: _s2PanelPos.dx, top: _s2PanelPos.dy,
          child: GestureDetector(behavior: HitTestBehavior.opaque, 
            onPanUpdate: (d) => setState(() => _s2PanelPos += d.delta),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(t('lblFab'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70)),
                    const Icon(Icons.drag_indicator, color: Colors.white54, size: 16),
                  ]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildVerticalSlider(t('lblSide1'), s2_s1, 5, 15, (v) { setState(() => s2_s1 = v); _playClick(); if (_step == 0 && v == 10) { _playSuccess(); _advanceStep(); } }, "m", Colors.cyan),
                      _buildVerticalSlider(t('lblAngle'), s2_ang, 30, 120, (v) { setState(() => s2_ang = v); _playClick(); if (_step == 1 && v == 60) { _playSuccess(); _advanceStep(); } }, "°", Colors.green),
                      _buildVerticalSlider(t('lblSide2'), s2_s2, 5, 15, (v) { setState(() => s2_s2 = v); _playClick(); if (_step == 2 && v == 10) _playFx(); }, "m", Colors.cyan),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (s2_s1 == 10 && s2_ang == 60 && s2_s2 == 10 && _step >= 2) ? () { setState(() { s2_fabricated = true; s2_triPos = const Offset(150, 0); }); _playFx(); _advanceStep(); } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, disabledBackgroundColor: Colors.grey[800],
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(t('btnFab'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    else if (_scenario == 3 && _step == 3 && s3_comp_placed && !s3_arcDrawn) {
      Offset pos = MatrixUtils.transformPoint(transform, const Offset(-150 + 210/2 + 20, 150 - 85));
      panels.add(
        Positioned(
          left: pos.dx - 60, top: pos.dy - 20,
          child: ElevatedButton(
            onPressed: () { setState(() { s3_arcDrawn = true; }); _playFx(); _advanceStep(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: Text(t('btnDrawArc'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }
    else if (_scenario == 4 && _step < 2 && !s4_grabbed) {
      panels.add(
        Positioned(
          left: _s4PanelPos.dx, top: _s4PanelPos.dy,
          child: GestureDetector(behavior: HitTestBehavior.opaque, 
            onPanUpdate: (d) => setState(() => _s4PanelPos += d.delta),
            child: Container(
              width: 260,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(t('lblArmCtrl'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigoAccent)),
                    const Icon(Icons.drag_indicator, color: Colors.white54, size: 16),
                  ]),
                  const SizedBox(height: 16),
                  _buildHorizontalSlider(t('lblArm1'), s4_l1, 4, 12, (v) => setState(() => s4_l1 = v)),
                  _buildHorizontalSlider(t('lblJointAng'), s4_ang, -90, 90, (v) => setState(() => s4_ang = v), suffix: "°"),
                  _buildHorizontalSlider(t('lblArm2'), s4_l2, 4, 12, (v) => setState(() => s4_l2 = v)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: (s4_l1 == 8 && s4_ang == -45 && s4_l2 == 6 && !s4_grabbed) ? () { 
                      setState(() { s4_grabbed = true; }); 
                      _playFx(); 
                      _s4LiftCtrl.forward().then((_) {
                        _checkScenarioSuccess(); 
                      });
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo, disabledBackgroundColor: Colors.grey[800],
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(t('btnGrab'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    else if (_scenario == 5 && _step >= 2 && _step <= 4) {
      panels.add(
        Positioned(
          left: _s5PanelPos.dx, top: _s5PanelPos.dy,
          child: GestureDetector(behavior: HitTestBehavior.opaque, 
            onPanUpdate: (d) => setState(() => _s5PanelPos += d.delta),
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber, width: 2)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(t('lblTileCutter'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber)),
                    const Icon(Icons.drag_indicator, color: Colors.white54, size: 16),
                  ]),
                  const SizedBox(height: 16),
                  _buildNumberInput(t('lblSide1'), s5_input1, (v) => setState(() => s5_input1 = v)),
                  _buildNumberInput(t('lblAngle'), s5_inputA, (v) => setState(() => s5_inputA = v), suffix: "°"),
                  _buildNumberInput(t('lblSide2'), s5_input2, (v) => setState(() => s5_input2 = v)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: s5_isCutting ? null : () {
                      setState(() { s5_isCutting = true; }); _playFx();
                      Future.delayed(const Duration(milliseconds: 800), () {
                        setState(() {
                          s5_isCutting = false;
                          s5_cutTiles.add(Tile(id: DateTime.now().millisecondsSinceEpoch, trayX: -300.0 + (s5_cutTiles.length * 140), trayY: 220.0, x: -300.0 + (s5_cutTiles.length * 140), y: 220.0, s1: s5_input1, ang: s5_inputA, s2: s5_input2));
                          _playFx();
                          if (_step == 2) _advanceStep();
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(s5_isCutting ? "CUTTING..." : t('btnCut'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    return panels;
  }

  Widget _buildVerticalSlider(String label, int val, int min, int max, Function(int) onChanged, String suffix, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(thumbColor: color, activeTrackColor: color, inactiveTrackColor: Colors.grey[700], trackHeight: 4),
              child: Slider(value: val.toDouble(), min: min.toDouble(), max: max.toDouble(), divisions: max - min, onChanged: (v) => onChanged(v.toInt())),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
          child: Text("$val$suffix", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        )
      ],
    );
  }

  Widget _buildHorizontalSlider(String label, int val, int min, int max, Function(int) onChanged, {String suffix = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text("$val$suffix", style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(thumbColor: Colors.indigoAccent, activeTrackColor: Colors.indigoAccent, inactiveTrackColor: Colors.grey[700], trackHeight: 4),
          child: Slider(value: val.toDouble(), min: min.toDouble(), max: max.toDouble(), divisions: max - min, onChanged: (v) { _playClick(); onChanged(v.toInt()); }),
        ),
      ],
    );
  }

  Widget _buildNumberInput(String label, int val, Function(int) onChanged, {String suffix = ""}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Row(
            children: [
              InkWell(onTap: () { _playClick(); onChanged(val - 1); }, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.remove, size: 16, color: Colors.amber))),
              const SizedBox(width: 12),
              Text("$val$suffix", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 12),
              InkWell(onTap: () { _playClick(); onChanged(val + 1); }, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.add, size: 16, color: Colors.amber))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(5, 0))],
      ),
      child: SingleChildScrollView(
        controller: _sidebarScrollCtrl,
        padding: const EdgeInsets.all(20).copyWith(top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.change_history, color: Color(0xFF6366f1), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('appTitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis),
                      Text(t('appSubtitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
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
                  label: Text(t('resetBtn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFf43f5e), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

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
                  items: [1, 2, 3, 4, 5].map((i) => DropdownMenuItem(value: i, child: Text(t('s${i}_title')))).toList(),
                  onChanged: (val) { if (val != null) _loadScenario(val); },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.lightbulb_outline, color: Color(0xFFf43f5e), size: 20), const SizedBox(width: 8), Text(t('learnLbl'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))]),
                  const SizedBox(height: 8),
                  Text(t('s${_scenario}_obj'), style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._buildSteps(),
            
            if (_step >= _getScenarioSteps(_scenario).length && ((_scenario == 1 && s1_superimposed) || (_scenario == 2 && s2_superimposed) || (_scenario == 3 && s3_matchIndex != -1) || (_scenario == 4 && s4_grabbed) || (_scenario == 5 && s5_slots.where((s) => s).length == 5)))
              Container(
                margin: const EdgeInsets.only(top: 20), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_scenario == 3 && s3_matchIndex != -1) ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  border: Border.all(color: (_scenario == 3 && s3_matchIndex != -1) ? Colors.red : Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(children: [Icon((_scenario == 3 && s3_matchIndex != -1) ? Icons.warning : Icons.check_circle, color: (_scenario == 3 && s3_matchIndex != -1) ? Colors.red : Colors.green), const SizedBox(width: 8), Text(t('summaryTitle'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: (_scenario == 3 && s3_matchIndex != -1) ? Colors.redAccent : Colors.greenAccent))]),
                    const SizedBox(height: 8),
                    Text(t('s${_scenario}_sum'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                    if (_scenario < 5) ...[
                      const SizedBox(height: 16),
                      const Text("✅ Scenario Completed! Please select the next scenario from the dropdown above.", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    ]
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: Text(t('footer'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSteps() {
    List<Map<String, String>> stepsConfig = _getScenarioSteps(_scenario);
    return List.generate(stepsConfig.length, (i) {
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
                  Text(stepsConfig[i]['task']!, style: TextStyle(color: isActive ? const Color(0xFF818cf8) : Colors.white70, fontSize: 14)),
                  if (isPast) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: (_scenario == 3 && i == 4) ? Colors.red.withOpacity(0.2) : const Color(0xFF10b981).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(stepsConfig[i]['out']!, style: TextStyle(color: (_scenario == 3 && i == 4) ? Colors.redAccent : const Color(0xFF34d399), fontSize: 13)),
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
              width: 500,
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
                    Text(t('finalDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _resetToShutter,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(t('resetBtn'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  List<Map<String, String>> _getScenarioSteps(int id) {
    int numSteps = 4; if(id == 1) numSteps = 6; if(id == 2) numSteps = 4; if(id == 4) numSteps = 2; if(id == 5) numSteps = 5;
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({ 'task': t('s${id}_step${i}_task'), 'out': t('s${id}_step${i}_out') });
    }
    return steps;
  }
}

class Tile {
  final int id; double trayX; double trayY; double x; double y; int s1; int ang; int s2; bool isDragging;
  Tile({required this.id, required this.trayX, required this.trayY, required this.x, required this.y, required this.s1, required this.ang, required this.s2, this.isDragging = false});
}

// --- Canvas Rendering ---
class SASCanvasPainter extends CustomPainter {
  final double zoom; final Offset pan; final int scenario; final int step; final bool themeLight;
  final bool s1_b8_placed; final int s1_base_len; final bool s1_pro_placed; final int s1_pro_ang;
  final bool s1_arm_placed; final int s1_arm_len; final bool s1_welded; final bool s1_superimposed;
  final Offset s1_triPos; final Offset s1_b8_pos; final Offset s1_b6_pos; final Offset s1_pro_pos; final Offset s1_dragPos;
  final int s2_s1; final int s2_ang; final int s2_s2; final bool s2_fabricated; final bool s2_superimposed; final Offset s2_triPos;
  final bool s3_b10_placed; final Offset s3_b10_pos; final bool s3_pro_placed; final Offset s3_pro_pos; final int s3_pro_angle;
  final bool s3_comp_placed; final Offset s3_comp_pos; final bool s3_arcDrawn; final Offset s3_target_pos; final int s3_matchIndex;
  final int s4_l1; final int s4_ang; final int s4_l2; final bool s4_grabbed; final double s4_lift;
  final List<Tile> s5_cutTiles; final List<bool> s5_slots; final bool s5_mS1; final bool s5_mAng; final bool s5_mS2; final Offset s5_toolPos; final bool s5_isCutting;
  final String? draggingTool; final String lang; final Function(String) t;

  SASCanvasPainter({
    required this.zoom, required this.pan, required this.scenario, required this.step, required this.themeLight,
    required this.s1_b8_placed, required this.s1_base_len, required this.s1_pro_placed, required this.s1_pro_ang, required this.s1_arm_placed, required this.s1_arm_len, required this.s1_welded, required this.s1_superimposed, required this.s1_triPos, required this.s1_b8_pos, required this.s1_b6_pos, required this.s1_pro_pos, required this.s1_dragPos,
    required this.s2_s1, required this.s2_ang, required this.s2_s2, required this.s2_fabricated, required this.s2_superimposed, required this.s2_triPos,
    required this.s3_b10_placed, required this.s3_b10_pos, required this.s3_pro_placed, required this.s3_pro_pos, required this.s3_pro_angle, required this.s3_comp_placed, required this.s3_comp_pos, required this.s3_arcDrawn, required this.s3_target_pos, required this.s3_matchIndex,
    required this.s4_l1, required this.s4_ang, required this.s4_l2, required this.s4_grabbed, required this.s4_lift,
    required this.s5_cutTiles, required this.s5_slots, required this.s5_mS1, required this.s5_mAng, required this.s5_mS2, required this.s5_toolPos, required this.s5_isCutting,
    required this.draggingTool, required this.lang, required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF020617));
    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom);

    if (scenario == 1 || scenario == 3) {
      Paint gridPaint = Paint()..color = const Color(0xFF1e293b)..style = PaintingStyle.stroke..strokeWidth = 1;
      for (double i = -2000; i < 2000; i += 40) {
        canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
        canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
      }
    }

    if (scenario == 1) _drawS1(canvas);
    if (scenario == 2) _drawS2(canvas);
    if (scenario == 3) _drawS3(canvas);
    if (scenario == 4) _drawS4(canvas);
    if (scenario == 5) _drawS5(canvas);

    canvas.restore();
  }

  void _drawS1(Canvas canvas) {
    double scale = 22.0; double tW = 8 * scale; double tL = 6 * scale; double tAng = 45;
    double tCx = math.cos(-tAng * math.pi / 180) * tL; double tCy = math.sin(-tAng * math.pi / 180) * tL;
    double tx = -300, ty = -50; double wx = -10, wy = 150;

    _drawPanel(canvas, tx - 40, ty - 180, 320, 240);
    Path targetPath = Path()..moveTo(tx, ty)..lineTo(tx + tW, ty)..lineTo(tx + tCx, ty + tCy)..close();
    canvas.drawPath(targetPath, Paint()..color = Colors.blue.withOpacity(0.15)..style = PaintingStyle.fill);
    canvas.drawPath(targetPath, Paint()..color = Colors.blue..style = PaintingStyle.stroke..strokeWidth = 4);
    _drawText(canvas, t('lblBlueprint'), tx + tW / 2, ty - 130, 16, Colors.blue, bold: true);
    _drawText(canvas, "8", tx + tW / 2, ty + 20, 14, Colors.white, bold: true);
    _drawText(canvas, "6", tx + tCx / 2 - 15, ty + tCy / 2 - 5, 14, Colors.white, bold: true);
    _drawText(canvas, "45°", tx + 35, ty - 10, 14, Colors.white, bold: true);

    _drawPanel(canvas, wx - 30, wy - 180, 310, 240);
    _drawText(canvas, t('lblConstZone:'), wx + tW / 2, wy + 30, 14, Colors.white, bold: true);
    if (step <= 4 && !s1_b8_placed) {
      canvas.drawLine(Offset(wx, wy), Offset(wx + tW, wy), Paint()..color = Colors.green.withOpacity(0.4)..strokeWidth = 6..strokeCap = StrokeCap.round);
    }

    _drawToolboxFrame(canvas, 280, -200, 100, 260, t('lblTools'));
    if ((step == 0 || step == 3) && draggingTool != 's1_tool_beam1' && draggingTool != 's1_tool_beam2') _drawToolboxIcon(canvas, 300, -160, 'beam');
    if (step == 2 && draggingTool != 's1_tool_pro') _drawToolboxIcon(canvas, 300, -80, 'pro');

    double bx = s1_superimposed ? tx : s1_triPos.dx; double by = s1_superimposed ? ty : s1_triPos.dy;

    if (s1_welded) {
      Path wPath = Path()..moveTo(bx, by)..lineTo(bx + tW, by)..lineTo(bx + tCx, by + tCy)..close();
      canvas.drawPath(wPath, Paint()..color = Colors.green.withOpacity(0.2)..style = PaintingStyle.fill);
      canvas.drawPath(wPath, Paint()..color = Colors.green..style = PaintingStyle.stroke..strokeWidth = 6..strokeJoin = StrokeJoin.round);
    } else {
      if (s1_b8_placed) {
        canvas.drawLine(Offset(wx, wy), Offset(wx + s1_base_len * scale, wy), Paint()..color = Colors.green..strokeWidth = 14..strokeCap = StrokeCap.round);
        _drawPoint(canvas, wx, wy, Colors.white, radius: 6); _drawPoint(canvas, wx + s1_base_len * scale, wy, Colors.white, radius: 6);
        _drawText(canvas, "$s1_base_len", wx + s1_base_len * scale / 2, wy - 15, 16, Colors.white, bold: true);
        if (step == 1) {
          canvas.drawRect(Rect.fromLTWH(wx, wy + 15, 220, 24), Paint()..color = const Color(0xFF334155));
          for (int i = 0; i <= 8; i++) {
            canvas.drawLine(Offset(wx + i * scale, wy + 15), Offset(wx + i * scale, wy + 25), Paint()..color = Colors.white..strokeWidth = 2);
            _drawText(canvas, "$i", wx + i * scale, wy + 35, 10, Colors.white);
          }
          _drawPoint(canvas, wx + s1_base_len * scale, wy, Colors.orange, radius: 10);
        }
      }
      if (s1_pro_placed) _drawProtractor(canvas, wx, wy, s1_pro_ang.toDouble(), true, false);
      if (s1_arm_placed) {
        Offset ex = Offset(wx + s1_arm_len * scale * math.cos(-s1_pro_ang * math.pi / 180), wy + s1_arm_len * scale * math.sin(-s1_pro_ang * math.pi / 180));
        canvas.drawLine(Offset(wx, wy), ex, Paint()..color = Colors.green..strokeWidth = 14..strokeCap = StrokeCap.round);
        _drawPoint(canvas, wx, wy, Colors.white, radius: 6); _drawPoint(canvas, ex.dx, ex.dy, Colors.white, radius: 6);
        canvas.save(); canvas.translate((wx + ex.dx) / 2, (wy + ex.dy) / 2); canvas.rotate(-s1_pro_ang * math.pi / 180);
        _drawText(canvas, "$s1_arm_len", 0, -12, 16, Colors.white, bold: true); canvas.restore();
        if (step == 3) _drawPoint(canvas, ex.dx, ex.dy, Colors.orange, radius: 10);
      }
      if (step == 4 && s1_arm_placed) {
        Offset ex = Offset(wx + s1_arm_len * scale * math.cos(-s1_pro_ang * math.pi / 180), wy + s1_arm_len * scale * math.sin(-s1_pro_ang * math.pi / 180));
        canvas.drawLine(Offset(wx + s1_base_len * scale, wy), ex, Paint()..color = Colors.green..strokeWidth = 4..strokeCap = StrokeCap.round);
      }
    }

    if (draggingTool == 's1_tool_beam1' || draggingTool == 's1_tool_beam2') {
      canvas.drawLine(Offset(s1_dragPos.dx - 60, s1_dragPos.dy), Offset(s1_dragPos.dx + 60, s1_dragPos.dy), Paint()..color = Colors.green..strokeWidth = 14..strokeCap = StrokeCap.round);
    }
    if (draggingTool == 's1_tool_pro') _drawProtractor(canvas, s1_dragPos.dx, s1_dragPos.dy, 0, false, false);

    if (s1_superimposed) {
      Path glowPath = Path()..moveTo(tx, ty)..lineTo(tx + tW, ty)..lineTo(tx + tCx, ty + tCy)..close();
      canvas.drawPath(glowPath, Paint()..color = Colors.green.withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawPath(glowPath, Paint()..color = Colors.greenAccent..style = PaintingStyle.stroke..strokeWidth = 4);
      _drawText(canvas, t('congruentLbl'), 0, -150, 30, Colors.greenAccent, bold: true);
    }
  }

  void _drawS2(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-3000, -3000, 6000, 6000), Paint()..color = const Color(0xFF0f172a)); // Sky
    canvas.drawCircle(const Offset(-200, -150), 60, Paint()..color = Colors.amber[300]!); // Sun
    
    Path hill1 = Path()..moveTo(-3000, 150)..quadraticBezierTo(-200, -150, 1500, 150);
    canvas.drawPath(hill1, Paint()..color = const Color(0xFF064e3b));
    Path hill2 = Path()..moveTo(-1500, 150)..quadraticBezierTo(500, -200, 3000, 150);
    canvas.drawPath(hill2, Paint()..color = const Color(0xFF065f46));

    canvas.drawRect(const Rect.fromLTWH(-3000, 150, 6000, 2000), Paint()..color = const Color(0xFF047857)); // Ground

    canvas.drawRect(const Rect.fromLTWH(-3000, 100, 6000, 40), Paint()..color = const Color(0xFF334155)); // Road
    for (int i = -2100; i < 2500; i += 200) {
      if (i == -100) continue; // Gap
      Path p = Path()..moveTo(i.toDouble(), 100)..lineTo(i + 100, -73.2)..lineTo(i + 200, 100);
      canvas.drawPath(p, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 14..strokeJoin = StrokeJoin.round);
      canvas.drawLine(Offset(i + 100, 100), Offset(i + 100, -73.2), Paint()..color = const Color(0xFF475569)..strokeWidth = 8);
    }

    if (!s2_superimposed) {
      Path gap = Path()..moveTo(-100, 100)..lineTo(0, -73.2)..lineTo(100, 100);
      Paint dashPaint = Paint()..color = Colors.greenAccent..style = PaintingStyle.stroke..strokeWidth = 6;
      _drawDashedPath(canvas, gap, dashPaint, [12, 12]);
      if (step < 4) {
        canvas.drawRect(const Rect.fromLTWH(-65, 30, 45, 25), Paint()..color = Colors.black45);
        canvas.drawRect(const Rect.fromLTWH(20, 30, 45, 25), Paint()..color = Colors.black45);
        canvas.drawRect(const Rect.fromLTWH(-25, -20, 50, 25), Paint()..color = Colors.black45);
        _drawText(canvas, "10m", -42, 43, 16, Colors.greenAccent, bold: true);
        _drawText(canvas, "10m", 42, 43, 16, Colors.greenAccent, bold: true);
        _drawText(canvas, "60°", 0, -7, 16, Colors.greenAccent, bold: true);
      }
    }

    if (s2_fabricated) {
      double bx = s2_superimposed ? -100 : s2_triPos.dx;
      double by = s2_superimposed ? 100 : s2_triPos.dy;
      double scale = 20; double uL1 = s2_s1 * scale; double uAng = s2_ang.toDouble(); double uL2 = s2_s2 * scale;
      
      canvas.save(); canvas.translate(bx, by);
      Path tPath = Path()..moveTo(0, 0)..lineTo(uL2, 0)..lineTo(uL2 - uL1 * math.cos(uAng * math.pi / 180), -uL1 * math.sin(uAng * math.pi / 180))..close();
      if (s2_superimposed) {
        canvas.drawPath(tPath, Paint()..color = Colors.green.withOpacity(0.4)..style = PaintingStyle.fill);
        canvas.drawPath(tPath, Paint()..color = Colors.greenAccent..style = PaintingStyle.stroke..strokeWidth = 14..strokeJoin = StrokeJoin.round);
        _drawText(canvas, t('lblTrussInst'), 100, -110, 28, Colors.greenAccent, bold: true);
      } else {
        canvas.drawPath(tPath, Paint()..color = const Color(0xFF94a3b8).withOpacity(0.9)..style = PaintingStyle.fill);
        canvas.drawPath(tPath, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 14..strokeJoin = StrokeJoin.round);
      }
      canvas.restore();
    }
  }

  void _drawS3(Canvas canvas) {
    double tW = 300; double tR = 210; double wx = -150; double wy = 150;
    
    canvas.save(); canvas.translate(-450, -300);
    _drawPanel(canvas, 0, 0, 240, 110);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 240, 30), Paint()..color = Colors.blue);
    _drawText(canvas, t('lblTargetMeas'), 120, 15, 13, Colors.white, bold: true);
    _drawText(canvas, t('lblBase10'), 60, 45, 13, Colors.grey[300]!);
    _drawText(canvas, t('lblSide7'), 62, 65, 13, Colors.grey[300]!);
    _drawText(canvas, t('lblNonInc30'), 80, 85, 13, Colors.grey[300]!);
    Path mPath = Path()..moveTo(160, 90)..lineTo(220, 90)..lineTo(200, 45)..close();
    canvas.drawPath(mPath, Paint()..color = Colors.blue..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.restore();

    _drawToolboxFrame(canvas, 350, -300, 100, 280, t('lblTools'));
    if (step == 0 && !s3_b10_placed && draggingTool != 's3_b10') _drawToolboxIcon(canvas, 370, -260, 'beam');
    if (step == 1 && !s3_pro_placed && draggingTool != 's3_pro') _drawToolboxIcon(canvas, 370, -180, 'pro');
    if (step == 2 && !s3_comp_placed && draggingTool != 's3_comp') _drawToolboxIcon(canvas, 370, -100, 'comp');

    double dx = -math.cos(s3_pro_angle * math.pi / 180);
    double dy = -math.sin(s3_pro_angle * math.pi / 180);
    
    double a = 1, b = 2 * tW * dx, c = tW * tW - tR * tR;
    double det = b * b - 4 * a * c;
    Offset? int1, int2;
    if (det >= 0) {
      double t1 = (-b + math.sqrt(det)) / (2 * a);
      double t2 = (-b - math.sqrt(det)) / (2 * a);
      if (t1 > 0) int1 = Offset((wx + tW) + t1 * dx, wy + t1 * dy);
      if (t2 > 0) int2 = Offset((wx + tW) + t2 * dx, wy + t2 * dy);
    }

    if (s3_b10_placed || draggingTool == 's3_b10') {
      double bx = s3_b10_placed ? wx : s3_b10_pos.dx; double by = s3_b10_placed ? wy : s3_b10_pos.dy;
      canvas.drawLine(Offset(bx, by), Offset(bx + tW, by), Paint()..color = Colors.orange..strokeWidth = 14..strokeCap = StrokeCap.round);
      _drawPoint(canvas, bx, by, Colors.white, radius: 6); _drawPoint(canvas, bx + tW, by, Colors.white, radius: 6);
      _drawText(canvas, "10 ${t('lblUnits')}", bx + tW / 2, by + 25, 16, Colors.white, bold: true);
    }

    if (s3_b10_placed) {
      if (s3_pro_placed) {
        canvas.drawLine(Offset(wx + tW, wy), Offset((wx + tW) + 500 * dx, wy + 500 * dy), Paint()..color = Colors.yellow..strokeWidth = 4);
        _drawProtractor(canvas, wx + tW, wy, s3_pro_angle.toDouble(), true, true);
      } else if (draggingTool == 's3_pro') _drawProtractor(canvas, s3_pro_pos.dx, s3_pro_pos.dy, 0, false, true);
      
      if (s3_comp_placed) _drawCompass(canvas, wx, wy, tR, s3_arcDrawn);
      else if (draggingTool == 's3_comp') _drawCompass(canvas, s3_comp_pos.dx, s3_comp_pos.dy, 100, false);

      if (s3_arcDrawn && int1 != null && int2 != null) {
        canvas.drawArc(Rect.fromCircle(center: Offset(wx, wy), radius: tR), -math.pi / 2, math.pi / 4 - (-math.pi / 2), false, Paint()..color = Colors.lightBlue..style = PaintingStyle.stroke..strokeWidth = 6);
        _drawPoint(canvas, int1.dx, int1.dy, Colors.green, radius: 8, pulse: true);
        _drawPoint(canvas, int2.dx, int2.dy, Colors.green, radius: 8, pulse: true);
        _drawText(canvas, t('lblPt1'), int1.dx, int1.dy - 15, 14, Colors.white, bold: true);
        _drawText(canvas, t('lblPt2'), int2.dx + 30, int2.dy - 10, 14, Colors.white, bold: true);
      }

      if (step >= 4 && int1 != null && int2 != null) {
        Path p1 = Path()..moveTo(wx, wy)..lineTo(wx + tW, wy)..lineTo(int1.dx, int1.dy)..close();
        canvas.drawPath(p1, Paint()..color = Colors.green.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 4);
        Path p2 = Path()..moveTo(wx, wy)..lineTo(wx + tW, wy)..lineTo(int2.dx, int2.dy)..close();
        _drawDashedPath(canvas, p2, Paint()..color = Colors.green.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 4, [8, 8]);
        
        double tpX = s3_matchIndex == 1 ? wx : s3_target_pos.dx; double tpY = s3_matchIndex == 1 ? wy : s3_target_pos.dy;
        canvas.save(); canvas.translate(tpX, tpY);
        Path tPath = Path()..moveTo(0, 0)..lineTo(tW, 0)..lineTo(int1.dx - wx, int1.dy - wy)..close();
        canvas.drawPath(tPath, Paint()..color = Colors.blue.withOpacity(0.6)..style = PaintingStyle.fill);
        canvas.drawPath(tPath, Paint()..color = Colors.green[600]!..style = PaintingStyle.stroke..strokeWidth = 4..strokeJoin = StrokeJoin.round);
        if (s3_matchIndex == -1) _drawPoint(canvas, tW / 2, -50, Colors.green, radius: 15, pulse: true);
        canvas.restore();
      }
    }
  }

  void _drawS4(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-3000, 150, 6000, 2000), Paint()..color = const Color(0xFF1e293b));
    canvas.drawLine(const Offset(-3000, 150), const Offset(3000, 150), Paint()..color = const Color(0xFF0f172a)..strokeWidth = 10);

    double bx = -200, by = 150;
    double liftRot = s4_lift * (-30 * math.pi / 180);
    double baseAng = -45 * math.pi / 180 + liftRot;
    double sf = 15;

    double gL1 = 8 * sf; double gAng = -45 * math.pi / 180; double gL2 = 6 * sf;
    double gJ1x = bx + gL1 * math.cos(-45 * math.pi / 180); double gJ1y = by + gL1 * math.sin(-45 * math.pi / 180);
    double gJ2x = gJ1x + gL2 * math.cos(-45 * math.pi / 180 + gAng); double gJ2y = gJ1y + gL2 * math.sin(-45 * math.pi / 180 + gAng);
    double boxSize = 40; double pedX = gJ2x; double pedY = gJ2y + boxSize;

    Path ped = Path()..moveTo(pedX - 30, 150)..lineTo(pedX - 20, pedY)..lineTo(pedX + 20, pedY)..lineTo(pedX + 30, 150)..close();
    canvas.drawPath(ped, Paint()..color = const Color(0xFF334155));
    canvas.drawPath(ped, Paint()..color = const Color(0xFF1e293b)..style = PaintingStyle.stroke..strokeWidth = 4);

    double aL1 = s4_l1 * sf; double aAng = s4_ang * math.pi / 180; double aL2 = s4_l2 * sf;
    double aJ1x = bx + aL1 * math.cos(baseAng); double aJ1y = by + aL1 * math.sin(baseAng);
    double aJ2x = aJ1x + aL2 * math.cos(baseAng + aAng); double aJ2y = aJ1y + aL2 * math.sin(baseAng + aAng);
    double boxX = s4_lift > 0 ? aJ2x : gJ2x; double boxY = s4_lift > 0 ? aJ2y : gJ2y;

    _drawPanel(canvas, boxX - boxSize / 2, boxY, boxSize, boxSize);
    canvas.drawRect(Rect.fromLTWH(boxX - boxSize / 2, boxY, boxSize, boxSize), Paint()..color = Colors.orange);
    _drawText(canvas, "TARGET", boxX, boxY + boxSize / 2 + 4, 10, Colors.brown[900]!, bold: true);

    if (!s4_grabbed) {
      canvas.drawLine(Offset(bx, by), Offset(gJ1x, gJ1y), Paint()..color = Colors.green.withOpacity(0.3)..strokeWidth = 20..strokeCap = StrokeCap.round);
      canvas.drawLine(Offset(gJ1x, gJ1y), Offset(gJ2x, gJ2y), Paint()..color = Colors.green.withOpacity(0.3)..strokeWidth = 20..strokeCap = StrokeCap.round);
      _drawPoint(canvas, gJ1x, gJ1y, Colors.green.withOpacity(0.4), radius: 10);
      _drawPoint(canvas, gJ2x, gJ2y, Colors.green.withOpacity(0.4), radius: 8);
      canvas.drawArc(Rect.fromCircle(center: Offset(gJ1x, gJ1y), radius: 30), -45 * math.pi / 180 + gAng, -gAng, false, Paint()..color = Colors.green.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 4);
      _drawText(canvas, "-45°", gJ1x + 45, gJ1y - 15, 14, Colors.yellow, bold: true);
    }

    canvas.drawLine(Offset(bx, by), Offset(aJ1x, aJ1y), Paint()..color = Colors.lightBlue..strokeWidth = 16..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(aJ1x, aJ1y), Offset(aJ2x, aJ2y), Paint()..color = Colors.lightBlue..strokeWidth = 16..strokeCap = StrokeCap.round);

    if (s4_l1 == 8 && s4_ang == -45 && s4_l2 == 6 && !s4_grabbed) {
      canvas.drawLine(Offset(bx, by), Offset(aJ1x, aJ1y), Paint()..color = Colors.greenAccent..strokeWidth = 16..strokeCap = StrokeCap.round);
      canvas.drawLine(Offset(aJ1x, aJ1y), Offset(aJ2x, aJ2y), Paint()..color = Colors.greenAccent..strokeWidth = 16..strokeCap = StrokeCap.round);
    }

    if (!s4_grabbed) {
      if (s4_ang != 0) {
        double sAng = s4_ang < 0 ? baseAng + aAng : baseAng;
        double swAng = s4_ang < 0 ? -aAng : aAng;
        canvas.drawArc(Rect.fromCircle(center: Offset(aJ1x, aJ1y), radius: 40), sAng, swAng, false, Paint()..color = Colors.amber..style = PaintingStyle.stroke..strokeWidth = 4);
        double midAng = baseAng + (aAng / 2);
        _drawText(canvas, "$s4_ang°", aJ1x + 55 * math.cos(midAng), aJ1y + 55 * math.sin(midAng), 14, Colors.yellow, bold: true);
      }
      _drawText(canvas, "L1: $s4_l1", bx + (aL1 / 2) * math.cos(baseAng) - 20, by + (aL1 / 2) * math.sin(baseAng) - 15, 14, Colors.blue[200]!, bold: true);
      _drawText(canvas, "L2: $s4_l2", aJ1x + (aL2 / 2) * math.cos(baseAng + aAng) - 20, aJ1y + (aL2 / 2) * math.sin(baseAng + aAng) - 15, 14, Colors.blue[200]!, bold: true);
    }

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx - 35, by - 10, 70, 40), const Radius.circular(6)), Paint()..color = const Color(0xFF334155));
    _drawPoint(canvas, bx, by, const Color(0xFFcbd5e1), radius: 12);
    _drawPoint(canvas, aJ1x, aJ1y, const Color(0xFFcbd5e1), radius: 10);

    canvas.save(); canvas.translate(aJ2x, aJ2y); canvas.rotate(baseAng + aAng + math.pi / 2);
    canvas.drawRect(const Rect.fromLTWH(-15, 0, 30, 10), Paint()..color = const Color(0xFF475569));
    double clawOpen = s4_grabbed ? 28 : 36;
    canvas.drawRect(Rect.fromLTWH(-clawOpen, 10, 8, 20), Paint()..color = const Color(0xFF475569));
    canvas.drawRect(Rect.fromLTWH(clawOpen - 8, 10, 8, 20), Paint()..color = const Color(0xFF475569));
    _drawPoint(canvas, 0, 0, const Color(0xFFcbd5e1), radius: 8);
    canvas.restore();

    if (s4_grabbed && s4_lift >= 1) {
      _drawText(canvas, "SUCCESS!", 0, -150, 36, Colors.greenAccent, bold: true);
    }
  }

  void _drawS5(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-3000, -20, 6000, 140), Paint()..color = const Color(0xFF1e3a8a));
    canvas.drawLine(const Offset(-3000, -20), const Offset(3000, -20), Paint()..color = const Color(0xFF1e40af)..strokeWidth = 4);
    canvas.drawLine(const Offset(-3000, 120), const Offset(3000, 120), Paint()..color = const Color(0xFF1e40af)..strokeWidth = 4);

    List<Offset> slotPos = [const Offset(-250, 50), const Offset(-120, 50), const Offset(10, 50), const Offset(140, 50), const Offset(270, 50)];
    for (int i = 0; i < slotPos.length; i++) {
      canvas.save(); canvas.translate(slotPos[i].dx, slotPos[i].dy);
      Path tPath = Path()..moveTo(0, 0)..lineTo(100, 0)..lineTo(80 * math.cos(-60 * math.pi / 180), 80 * math.sin(-60 * math.pi / 180))..close();
      if (s5_slots[i]) {
        canvas.drawPath(tPath, Paint()..color = Colors.orange);
        canvas.drawPath(tPath, Paint()..color = Colors.brown[700]!..style = PaintingStyle.stroke..strokeWidth = 2);
      } else {
        canvas.drawPath(tPath, Paint()..color = const Color(0xFF0f172a).withOpacity(0.8));
        _drawDashedPath(canvas, tPath, Paint()..color = Colors.orange..style = PaintingStyle.stroke..strokeWidth = 3, [6, 6]);
      }
      canvas.restore();
    }

    if (s5_slots.where((s) => s).length == 5) {
      _drawText(canvas, "MASTERPIECE COMPLETE!", 10, -120, 36, Colors.orange, bold: true);
    }

    double sx = -350, sy = -150, sc = 12.5;
    Offset p1 = Offset(sx, sy); Offset p2 = Offset(sx + 10 * sc, sy);
    Offset p3 = Offset(sx + 8 * sc * math.cos(-60 * math.pi / 180), sy + 8 * sc * math.sin(-60 * math.pi / 180));

    _drawPanel(canvas, sx - 40, sy - 150, 260, 230);
    Path sPath = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
    canvas.drawPath(sPath, Paint()..color = Colors.orange);
    canvas.drawPath(sPath, Paint()..color = Colors.brown[700]!..style = PaintingStyle.stroke..strokeWidth = 2);
    _drawText(canvas, t('lblSample'), sx + 65, sy - 110, 16, Colors.white, bold: true);

    _drawToolboxFrame(canvas, 330, -250, 100, 200, t('lblTools'));
    if (step == 0 && (!s5_mS1 || !s5_mS2) && draggingTool != 's5_ruler') _drawToolboxIcon(canvas, 350, -210, 'ruler');
    if (step == 1 && !s5_mAng && draggingTool != 's5_pro') _drawToolboxIcon(canvas, 350, -130, 'pro');

    if (s5_mS1) _drawText(canvas, "10", (p1.dx + p2.dx) / 2, p1.dy + 25, 16, Colors.white, bold: true);
    if (s5_mS2) _drawText(canvas, "8", (p1.dx + p3.dx) / 2 - 25, (p1.dy + p3.dy) / 2 - 10, 16, Colors.white, bold: true);
    if (s5_mAng) _drawText(canvas, "60°", p1.dx + 35, p1.dy - 15, 16, Colors.white, bold: true);

    for (var tile in s5_cutTiles) {
      canvas.save(); canvas.translate(tile.x, tile.y);
      Path tPath = Path()..moveTo(0, 0)..lineTo(tile.s1 * sc, 0)..lineTo(tile.s2 * sc * math.cos(-tile.ang * math.pi / 180), tile.s2 * sc * math.sin(-tile.ang * math.pi / 180))..close();
      canvas.drawPath(tPath, Paint()..color = Colors.orange);
      canvas.drawPath(tPath, Paint()..color = Colors.brown[700]!..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.restore();
    }

    if (s5_isCutting) {
      canvas.save(); canvas.translate(-250.0 + (s5_cutTiles.length * 100), 200);
      for (int i = 0; i < 8; i++) canvas.drawCircle(Offset(math.Random().nextDouble() * 40, -math.Random().nextDouble() * 40), 3 + math.Random().nextDouble() * 5, Paint()..color = Colors.yellow);
      canvas.restore();
    }

    if (draggingTool == 's5_ruler') {
      double rot = 0;
      if (!s5_mS1 && (s5_toolPos - Offset((p1.dx + p2.dx) / 2, p1.dy)).distance < 100) rot = 0;
      else if (!s5_mS2 && (s5_toolPos - Offset((p1.dx + p3.dx) / 2, (p1.dy + p3.dy) / 2)).distance < 100) rot = -60 * math.pi / 180;
      _drawRuler(canvas, s5_toolPos.dx, s5_toolPos.dy, rot);
    }
    if (draggingTool == 's5_pro') _drawProtractor(canvas, s5_toolPos.dx, s5_toolPos.dy, 0, false, false);
  }

  // --- Sub-Components ---
  void _drawProtractor(Canvas canvas, double x, double y, double angleDeg, bool isPlaced, bool isRightSide) {
    canvas.save(); canvas.translate(x, y);
    canvas.drawArc(const Rect.fromLTWH(-100, -100, 200, 200), math.pi, math.pi, true, Paint()..color = const Color(0xFF6366f1).withOpacity(isPlaced ? 0.4 : 0.2)..style = PaintingStyle.fill);
    canvas.drawArc(const Rect.fromLTWH(-100, -100, 200, 200), math.pi, math.pi, true, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawArc(const Rect.fromLTWH(-40, -40, 80, 80), math.pi, math.pi, false, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    for (int i = 0; i <= 18; i++) {
      double a = math.pi - (i * math.pi / 18); bool isMaj = i % 3 == 0;
      canvas.drawLine(Offset(math.cos(a) * (isMaj ? 85 : 90), -math.sin(a) * (isMaj ? 85 : 90)), Offset(math.cos(a) * 100, -math.sin(a) * 100), Paint()..color = const Color(0xFF6366f1)..strokeWidth = 2);
    }
    _drawDashedPath(canvas, Path()..moveTo(0, 0)..lineTo(0, -120), Paint()..color = Colors.orange..style = PaintingStyle.stroke..strokeWidth = 3, [8, 8]);
    _drawPoint(canvas, 0, -120, Colors.orange, radius: 6);
    _drawText(canvas, "90°", 0, -135, 14, Colors.orange, bold: true);

    if (isPlaced) {
      double vAng = isRightSide ? (180 - angleDeg) : angleDeg;
      canvas.rotate(-vAng * math.pi / 180);
      canvas.drawLine(const Offset(0, 0), const Offset(200, 0), Paint()..color = Colors.yellow..strokeWidth = 4);
      _drawPoint(canvas, 200, 0, Colors.amber, radius: 8);
      canvas.translate(140, -30); canvas.rotate(vAng * math.pi / 180);
      _drawPanel(canvas, -25, -15, 50, 30);
      _drawText(canvas, "${angleDeg.round()}°", 0, 0, 16, Colors.lightBlue, bold: true);
    }
    canvas.restore();
  }

  void _drawCompass(Canvas canvas, double x, double y, double radius, bool drawArcFlag) {
    canvas.save(); canvas.translate(x, y);
    _drawPoint(canvas, 0, 0, const Color(0xFF64748b), radius: 6);
    canvas.drawLine(const Offset(0, 0), Offset(radius / 2, -150), Paint()..color = const Color(0xFF94a3b8)..strokeWidth = 6..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(radius / 2, -150), Offset(radius, 0), Paint()..color = const Color(0xFF94a3b8)..strokeWidth = 6..strokeCap = StrokeCap.round);
    _drawPoint(canvas, radius / 2, -150, const Color(0xFF475569), radius: 8);
    _drawPoint(canvas, radius, 0, const Color(0xFF3b82f6), radius: 6);
    canvas.drawLine(Offset(radius / 4, -75), Offset(3 * radius / 4, -75), Paint()..color = const Color(0xFF64748b)..strokeWidth = 4);
    _drawText(canvas, "7", radius / 2, -85, 14, Colors.white, bold: true);

    if (drawArcFlag) {
      _drawDashedPath(canvas, Path()..addArc(Rect.fromCircle(center: const Offset(0, 0), radius: radius), -math.pi / 2, math.pi / 4 - (-math.pi / 2)), Paint()..color = Colors.lightBlue..style = PaintingStyle.stroke..strokeWidth = 6, [10, 10]);
    }
    canvas.restore();
  }

  void _drawRuler(Canvas canvas, double x, double y, double rot) {
    canvas.save(); canvas.translate(x, y); canvas.rotate(rot);
    canvas.drawRect(const Rect.fromLTWH(-75, -15, 150, 30), Paint()..color = Colors.orange);
    for (int i = -70; i <= 70; i += 10) canvas.drawRect(Rect.fromLTWH(i.toDouble(), -15, 2, i % 20 == 0 ? 15 : 10), Paint()..color = Colors.white);
    canvas.drawRect(const Rect.fromLTWH(-75, -15, 150, 30), Paint()..color = Colors.brown[700]!..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.restore();
  }

  void _drawToolboxFrame(Canvas canvas, double x, double y, double w, double h, String title) {
    _drawPanel(canvas, x, y, w, h);
    _drawText(canvas, title, x + w / 2, y + 25, 15, Colors.white, bold: true);
    canvas.drawLine(Offset(x + 10, y + 35), Offset(x + w - 10, y + 35), Paint()..color = const Color(0xFF475569)..strokeWidth = 1);
  }

  void _drawToolboxIcon(Canvas canvas, double x, double y, String iconType) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 60, 60), const Radius.circular(8)), Paint()..color = const Color(0xFF0f172a));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 60, 60), const Radius.circular(8)), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.save(); canvas.translate(x + 30, y + 30);
    if (iconType == 'beam') {
      canvas.drawLine(const Offset(-20, 0), const Offset(20, 0), Paint()..color = Colors.green..strokeWidth = 6..strokeCap = StrokeCap.round);
      _drawPoint(canvas, -20, 0, Colors.white, radius: 3); _drawPoint(canvas, 20, 0, Colors.white, radius: 3);
    } else if (iconType == 'pro') {
      canvas.drawArc(const Rect.fromLTWH(-20, -15, 40, 40), math.pi, math.pi, true, Paint()..color = const Color(0xFF6366f1).withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawArc(const Rect.fromLTWH(-20, -15, 40, 40), math.pi, math.pi, true, Paint()..color = const Color(0xFF6366f1)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawLine(const Offset(0, 5), const Offset(15, -10), Paint()..color = Colors.orange..strokeWidth = 2);
    } else if (iconType == 'comp') {
      canvas.drawLine(const Offset(-10, 10), const Offset(0, -15), Paint()..color = const Color(0xFF94a3b8)..strokeWidth = 3..strokeCap = StrokeCap.round);
      canvas.drawLine(const Offset(0, -15), const Offset(15, 10), Paint()..color = const Color(0xFF94a3b8)..strokeWidth = 3..strokeCap = StrokeCap.round);
      _drawPoint(canvas, 0, -15, const Color(0xFF475569), radius: 4); _drawPoint(canvas, -10, 10, const Color(0xFF64748b), radius: 3); _drawPoint(canvas, 15, 10, Colors.blue, radius: 3);
    } else if (iconType == 'ruler') {
      canvas.drawRect(const Rect.fromLTWH(-15, -20, 30, 40), Paint()..color = Colors.orange);
      for (int i = -15; i <= 15; i += 5) canvas.drawRect(Rect.fromLTWH(-15, i.toDouble(), i % 10 == 0 ? 10 : 5, 1.5), Paint()..color = Colors.white);
    }
    canvas.restore();
  }

  void _drawPanel(Canvas canvas, double x, double y, double w, double h) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(8)), Paint()..color = const Color(0xFF1e293b));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(8)), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawPoint(Canvas canvas, double x, double y, Color color, {double radius = 5, bool pulse = false}) {
    if (pulse) canvas.drawCircle(Offset(x, y), radius * 2.5 + math.sin(DateTime.now().millisecondsSinceEpoch / 150) * radius, Paint()..color = color.withOpacity(0.4));
    canvas.drawCircle(Offset(x, y), radius, Paint()..color = color);
    canvas.drawCircle(Offset(x, y), radius, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double size, Color color, {bool bold = false}) {
    TextPainter tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal)), textDirection: TextDirection.ltr, textAlign: TextAlign.center);
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
