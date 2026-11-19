// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeometricCongruenceApp());
}

class GeometricCongruenceApp extends StatelessWidget {
  const GeometricCongruenceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF020617),
        cardColor: const Color(0xFF1E293B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const UnderstandingGeometricCongruence(),
    );
  }
}

// --- FULL TRANSLATIONS (EN, HI, TE) ---
const Map<String, Map<String, String>> localizedStrings = {
  'en': {
    'appTitle': 'Understanding Geometric Congruence',
    'appSubtitle': 'Class 7 • GEOMETRIC TWINS',
    'enterLab': 'Enter Lab',
    'selectScenario': 'Select Scenario',
    'learnLbl': 'What We Learn:',
    'stepLabel': 'STEP',
    'taskInst': 'Task Instructions:',
    'expOut': 'Expected Outcome:',
    'targetLbl': 'Target Blueprint',
    'workshopLbl': 'Workshop',
    'mismatchLbl': 'MISMATCH',
    'congruentLbl': 'CONGRUENT!',
    'twoDiffTriangles': 'TWO Different Triangles! (Ambiguous)',
    'repairComplete': 'Repair Complete! (ASA works)',
    'missingPanel': 'MISSING PANEL',
    'baseline': 'Baseline',
    'drag6cmGuide': 'Drag 6cm stick to guide',
    'dragToTarget': 'Drag to target',
    'dragToScale': 'Drag to Scale',
    'dragProtractor': 'Drag Protractor',
    'summaryTitle': 'Discovery Made!',
    'nextScenario': 'Next Scenario',
    'finishLab': 'Finish Lab',
    'labCompleted': 'Lab Completed!',
    'finalDesc': 'You have successfully mastered geometric congruence! You discovered the minimum conditions to replicate triangles accurately and understand why certain combinations fail.',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
    'reset': 'Reset',
    
    // Scenario 1
    's1_title': '1. The Signboard Replica (SAS)',
    's1_obj': 'To understand that two side lengths are not enough to define a unique shape, but two sides and the included angle (SAS) are.',
    's1_step1_task': 'A target V-shaped symbol is shown. DRAG the 4cm stick and the 8cm stick and CONNECT them at one end.',
    's1_step1_out': 'The user connects the two sticks, forming a V-shape.',
    's1_step2_task': 'DRAG your V-shape over the target symbol to see if it matches. Try changing the angle.',
    's1_step2_out': 'The shape doesn\'t match the target symbol unless the angle is correct.',
    's1_step3_task': 'A protractor tool has appeared. DRAG it over your sticks. ROTATE one until the angle is 80°.',
    's1_step3_out': 'The user adjusts their V-shape to have exactly 80° angle.',
    's1_step4_task': 'Now that the angle is fixed, DRAG your symbol and SUPERIMPOSE it on the target symbol.',
    's1_step4_out': 'The user\'s symbol perfectly aligns with the target symbol.',
    's1_sum': 'Side-Angle-Side (SAS) Congruence: Two sides and the included angle define one unique, exact shape.',
    
    // Scenario 2
    's2_title': '2. The Triangle Blueprint (SSS)',
    's2_obj': 'To discover that three specific side lengths (SSS) are sufficient to construct a unique, congruent triangle.',
    's2_step1_task': 'DRAG the 6cm stick to the baseline. This will be the base of your triangle.',
    's2_step1_out': 'The user places the 6cm stick horizontally.',
    's2_step2_task': 'TAP on the left endpoint to activate the compass and DRAW a 4cm arc.',
    's2_step2_out': 'The user draws an arc with a 4cm radius.',
    's2_step3_task': 'TAP the right endpoint to DRAW another arc that intersects the first one.',
    's2_step3_out': 'The user draws an 8cm arc, creating an intersection point.',
    's2_step4_task': 'CONNECT the sticks to this glowing intersection point.',
    's2_step4_out': 'The user completes the triangle.',
    's2_step5_task': 'DRAG your constructed triangle and SUPERIMPOSE it on the target triangle.',
    's2_step5_out': 'The constructed triangle perfectly matches the target.',
    's2_sum': 'Side-Side-Side (SSS) Congruence: Three fixed side lengths define one unique, unbendable triangle.',

    // Scenario 3
    's3_title': '3. The Angle Trap (AAA)',
    's3_obj': 'To visually understand why having three equal angles (AAA) does not guarantee congruence.',
    's3_step1_task': 'Use the Angle Ray handles at vertices A and B to set angles to 80° and 70°.',
    's3_step1_out': 'The rays intersect to form a closed triangle with a top angle of 30°.',
    's3_step2_task': 'Your triangle has the correct angles. DRAG it over the target triangle to see if it is congruent.',
    's3_step2_out': 'The angles align perfectly, but the sides are visibly shorter.',
    's3_step3_task': 'DRAG the right vertex of your triangle to resize it. Watch the angles.',
    's3_step3_out': 'The triangle scales up or down, but the angle measurements remain completely fixed.',
    's3_step4_task': 'Resize your triangle so it perfectly matches the target triangle.',
    's3_step4_out': 'The triangle snaps and glows over the target.',
    's3_sum': 'AAA means Similarity, NOT Congruence: Three equal angles guarantee the same shape, but not size.',

    // Scenario 4
    's4_title': '4. The Ambiguous Case (SSA)',
    's4_obj': 'To discover that two sides and a non-included angle (SSA) can create two different triangles.',
    's4_step1_task': 'DRAG the 6cm stick to the baseline.',
    's4_step1_out': 'The user places the 6cm stick on the workspace.',
    's4_step2_task': 'Use the Protractor to DRAW a ray at 30° from the left endpoint.',
    's4_step2_out': 'The user draws a line representing all possible positions for the third side.',
    's4_step3_task': 'TAP the right endpoint to use the compass to draw a 4cm arc.',
    's4_step3_out': 'The user draws an arc that intersects the 30° ray in two distinct places.',
    's4_step4_task': 'You found two possible locations! TAP both intersection points to build both triangles.',
    's4_step4_out': 'The user constructs two visibly different triangles.',
    's4_step5_task': 'Are they congruent? Try to SUPERIMPOSE them on each other.',
    's4_step5_out': 'The user discovers the triangles are not congruent.',
    's4_sum': 'Discovery! The SSA condition is ambiguous. It does not guarantee congruence.',

    // Scenario 5
    's5_title': '5. The Bridge Repair (ASA)',
    's5_obj': 'To apply congruence rules (ASA) to construct a replacement part for a bridge truss.',
    's5_step1_task': 'A bridge is missing a triangular panel. Blueprint shows base 5m and adjacent angles 70°, 50°. Tap workspace to Proceed.',
    's5_step1_out': 'The user enters the workshop.',
    's5_step2_task': 'TAP the baseline marker to automatically draw the 5m base beam.',
    's5_step2_out': 'A 5m base is drawn in the workshop.',
    's5_step3_task': 'Drag protractor to left point to set 70°, and right to set 50°.',
    's5_step3_out': 'The rays intersect, automatically creating the panel.',
    's5_step4_task': 'Your replacement panel is complete. DRAG it to the empty space on the bridge.',
    's5_step4_out': 'The panel snaps perfectly into place.',
    's5_step5_task': 'If your construction is accurate, the panel will fit perfectly.',
    's5_step5_out': 'The panel snaps into place, completing the bridge.',
    's5_sum': 'ASA (Angle-Side-Angle): Two angles and the included side guarantee a perfectly congruent copy.'
  },
  'hi': {
    'appTitle': 'ज्यामितीय सर्वांगसमता को समझना',
    'appSubtitle': 'कक्षा 7 • ज्यामितीय जुड़वाँ',
    'enterLab': 'लैब में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'learnLbl': 'हम क्या सीखते हैं:',
    'stepLabel': 'चरण',
    'taskInst': 'कार्य निर्देश:',
    'expOut': 'अपेक्षित परिणाम:',
    'targetLbl': 'लक्ष्य ब्लूप्रिंट',
    'workshopLbl': 'कार्यशाला',
    'mismatchLbl': 'बेमेल',
    'congruentLbl': 'सर्वांगसम!',
    'twoDiffTriangles': 'दो अलग-अलग त्रिभुज! (अस्पष्ट)',
    'repairComplete': 'मरम्मत पूर्ण! (ASA काम करता है)',
    'missingPanel': 'गायब पैनल',
    'baseline': 'आधार रेखा',
    'drag6cmGuide': '6cm छड़ी को गाइड तक खींचें',
    'dragToTarget': 'लक्ष्य पर खींचें',
    'dragToScale': 'स्केल करने के लिए खींचें',
    'dragProtractor': 'चांदा खींचें',
    'summaryTitle': 'खोज की गई!',
    'nextScenario': 'अगला परिदृश्य',
    'finishLab': 'लैब समाप्त करें',
    'labCompleted': 'लैब पूर्ण!',
    'finalDesc': 'आपने ज्यामितीय सर्वांगसमता में महारत हासिल कर ली है! आपने सटीक प्रतिकृति बनाने की न्यूनतम शर्तें खोजीं और समझा कि कुछ स्थितियां विफल क्यों होती हैं।',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
    'reset': 'रीसेट',
    
    // Scenario 1
    's1_title': '1. साइनबोर्ड प्रतिकृति (SAS)', 
    's1_obj': 'यह समझना कि दो भुजाओं की लंबाई अद्वितीय आकार को परिभाषित करने के लिए पर्याप्त नहीं है, लेकिन दो भुजाएं और शामिल कोण (SAS) हैं।',
    's1_step1_task': 'एक लक्ष्य V-आकार का प्रतीक दिखाया गया है। 4cm छड़ी और 8cm छड़ी खींचें और उन्हें एक छोर पर जोड़ें।', 
    's1_step1_out': 'उपयोगकर्ता दो छड़ियों को जोड़ता है, जिससे एक V-आकार बनता है।',
    's1_step2_task': 'अपने V-आकार को लक्ष्य प्रतीक पर खींचें और देखें कि क्या यह मेल खाता है। कोण बदलने का प्रयास करें।', 
    's1_step2_out': 'कोण सही न होने तक आकार लक्ष्य प्रतीक से मेल नहीं खाता।',
    's1_step3_task': 'एक चांदा दिखाई दिया है। इसे अपनी छड़ियों पर खींचें। कोण को 80° तक घुमाएं।', 
    's1_step3_out': 'उपयोगकर्ता अपने V-आकार को ठीक 80° के कोण पर समायोजित करता है।',
    's1_step4_task': 'अब जब कोण तय हो गया है, तो अपने प्रतीक को खींचें और लक्ष्य प्रतीक पर अध्यारोपित करें।', 
    's1_step4_out': 'उपयोगकर्ता का प्रतीक पूरी तरह से लक्ष्य प्रतीक के साथ संरेखित होता है।',
    's1_sum': 'भुजा-कोण-भुजा (SAS) सर्वांगसमता: दो भुजाएं और शामिल कोण एक अद्वितीय, सटीक आकार को परिभाषित करते हैं।',

    // Scenario 2
    's2_title': '2. त्रिभुज ब्लूप्रिंट (SSS)', 
    's2_obj': 'यह खोजना कि तीन विशिष्ट भुजाओं की लंबाई (SSS) एक अद्वितीय, सर्वांगसम त्रिभुज बनाने के लिए पर्याप्त है।',
    's2_step1_task': '6cm छड़ी को आधार रेखा तक खींचें। यह आपके त्रिभुज का आधार होगा।', 
    's2_step1_out': 'उपयोगकर्ता 6cm छड़ी को क्षैतिज रूप से रखता है।',
    's2_step2_task': 'कम्पास को सक्रिय करने के लिए बाएं अंत बिंदु पर टैप करें और 4cm का चाप खींचें।', 
    's2_step2_out': 'उपयोगकर्ता 4cm त्रिज्या के साथ एक चाप खींचता है।',
    's2_step3_task': 'दाएं अंत बिंदु पर टैप करके दूसरा चाप खींचें जो पहले वाले को काटता हो।', 
    's2_step3_out': 'उपयोगकर्ता 8cm का चाप खींचता है, जिससे एक प्रतिच्छेदन बिंदु बनता है।',
    's2_step4_task': 'छड़ियों को इस चमकते प्रतिच्छेदन बिंदु से जोड़ें।', 
    's2_step4_out': 'उपयोगकर्ता त्रिभुज को पूरा करता है।',
    's2_step5_task': 'अपने बनाए गए त्रिभुज को खींचें और लक्ष्य त्रिभुज पर अध्यारोपित करें।', 
    's2_step5_out': 'निर्मित त्रिभुज पूरी तरह से लक्ष्य से मेल खाता है।',
    's2_sum': 'भुजा-भुजा-भुजा (SSS) सर्वांगसमता: तीन निश्चित भुजाओं की लंबाई एक अद्वितीय त्रिभुज को परिभाषित करती है।',

    // Scenario 3
    's3_title': '3. कोण का जाल (AAA)', 
    's3_obj': 'यह स्पष्ट रूप से समझना कि तीन समान कोण (AAA) होना सर्वांगसमता की गारंटी क्यों नहीं देता है।',
    's3_step1_task': 'शीर्ष A और B पर कोण रे हैंडल का उपयोग करके कोणों को 80° और 70° पर सेट करें।', 
    's3_step1_out': 'किरणें 30° के शीर्ष कोण के साथ एक बंद त्रिभुज बनाने के लिए प्रतिच्छेद करती हैं।',
    's3_step2_task': 'आपके त्रिभुज में सही कोण हैं। इसे लक्ष्य त्रिभुज पर खींचकर देखें कि क्या यह सर्वांगसम है।', 
    's3_step2_out': 'कोण पूरी तरह से संरेखित होते हैं, लेकिन भुजाएं स्पष्ट रूप से छोटी होती हैं।',
    's3_step3_task': 'अपने त्रिभुज का आकार बदलने के लिए उसके दाहिने शीर्ष को खींचें। कोणों को देखें।', 
    's3_step3_out': 'त्रिभुज का आकार बदलता है, लेकिन कोण का माप पूरी तरह से स्थिर रहता है।',
    's3_step4_task': 'अपने त्रिभुज का आकार बदलें ताकि वह लक्ष्य त्रिभुज से पूरी तरह मेल खाए।', 
    's3_step4_out': 'त्रिभुज स्नैप करता है और लक्ष्य पर चमकता है।',
    's3_sum': 'AAA का अर्थ है समरूपता, सर्वांगसमता नहीं: तीन समान कोण समान आकार की गारंटी देते हैं, लेकिन साइज़ की नहीं।',

    // Scenario 4
    's4_title': '4. अस्पष्ट स्थिति (SSA)', 
    's4_obj': 'यह खोजना कि दो भुजाएं और एक गैर-शामिल कोण (SSA) दो अलग-अलग त्रिभुज बना सकते हैं।',
    's4_step1_task': '6cm छड़ी को आधार रेखा तक खींचें।', 
    's4_step1_out': 'उपयोगकर्ता कार्यक्षेत्र पर 6cm की छड़ी रखता है।',
    's4_step2_task': 'बाएं अंत बिंदु से 30° पर एक किरण खींचने के लिए चांदा का उपयोग करें।', 
    's4_step2_out': 'उपयोगकर्ता तीसरी भुजा के लिए सभी संभावित स्थितियों को दर्शाने वाली एक रेखा खींचता है।',
    's4_step3_task': '4cm का चाप खींचने के लिए कंपास का उपयोग करने के लिए दाहिने अंत बिंदु पर टैप करें।', 
    's4_step3_out': 'उपयोगकर्ता एक चाप खींचता है जो 30° किरण को दो अलग-अलग स्थानों पर काटता है।',
    's4_step4_task': 'आपको दो संभावित स्थान मिले! दोनों त्रिभुज बनाने के लिए दोनों प्रतिच्छेदन बिंदुओं पर टैप करें।', 
    's4_step4_out': 'उपयोगकर्ता दो स्पष्ट रूप से भिन्न त्रिभुज बनाता है।',
    's4_step5_task': 'क्या वे सर्वांगसम हैं? उन्हें एक-दूसरे पर अध्यारोपित करने का प्रयास करें।', 
    's4_step5_out': 'उपयोगकर्ता को पता चलता है कि त्रिभुज सर्वांगसम नहीं हैं।',
    's4_sum': 'खोज! SSA स्थिति अस्पष्ट है। यह सर्वांगसमता की गारंटी नहीं देती।',

    // Scenario 5
    's5_title': '5. पुल की मरम्मत (ASA)', 
    's5_obj': 'पुल के लिए प्रतिस्थापन भाग बनाने के लिए सर्वांगसमता नियमों (ASA) को लागू करना।',
    's5_step1_task': 'पुल में एक त्रिभुजाकार पैनल गायब है। ब्लूप्रिंट आधार 5m और आसन्न कोण 70°, 50° दिखाता है। आगे बढ़ने के लिए टैप करें।', 
    's5_step1_out': 'उपयोगकर्ता कार्यशाला में प्रवेश करता है।',
    's5_step2_task': 'स्वचालित रूप से 5m आधार बीम खींचने के लिए बेसलाइन मार्कर पर टैप करें।', 
    's5_step2_out': 'कार्यशाला में एक 5m आधार खींचा गया है।',
    's5_step3_task': '70° सेट करने के लिए बाएं बिंदु पर चांदा खींचें, और 50° सेट करने के लिए दाएं बिंदु पर खींचें।', 
    's5_step3_out': 'किरणें प्रतिच्छेद करती हैं, स्वचालित रूप से पैनल बनाती हैं।',
    's5_step4_task': 'आपका प्रतिस्थापन पैनल पूरा हो गया है। इसे पुल के खाली स्थान पर खींचें।', 
    's5_step4_out': 'पैनल पूरी तरह से अपनी जगह पर फिट हो जाता है।',
    's5_step5_task': 'यदि आपका निर्माण सटीक है, तो पैनल पूरी तरह से फिट होगा।', 
    's5_step5_out': 'पुल को पूरा करते हुए, पैनल अपनी जगह पर स्नैप करता है।',
    's5_sum': 'ASA (कोण-भुजा-कोण): दो कोण और शामिल भुजा एक पूर्ण सर्वांगसम प्रतिलिपि की गारंटी देते हैं।'
  }
};

class UnderstandingGeometricCongruence extends StatefulWidget {
  const UnderstandingGeometricCongruence({Key? key}) : super(key: key);

  @override
  State<UnderstandingGeometricCongruence> createState() => _UnderstandingGeometricCongruenceState();
}

class _UnderstandingGeometricCongruenceState extends State<UnderstandingGeometricCongruence>
    with TickerProviderStateMixin {
  
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  // UI State
  bool _isSidebarOpen = true;
  bool _isCurtainRaised = false;
  bool _labCompletedFully = false;
  String _currentLang = 'en';
  String _message = '';
  bool _messageIsError = false;

  // Draggable Card Overlays
  Offset _stepCardPos = const Offset(20, 80);
  Offset _successPopupPos = const Offset(300, 150);

  // Canvas Interactions
  Offset _panOffset = Offset.zero;
  double _zoom = 0.85;
  String _activeTool = '';
  Offset _dragOffset = Offset.zero;

  // Auto-scroll Controllers
  final ScrollController _sidebarScrollController = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(5, (_) => GlobalKey());

  // Lab State
  int _scenario = 1;
  int _step = 0;

  // Scene 1 (SAS)
  Offset _s1_s8 = const Offset(0, 50);
  Offset _s1_s4 = const Offset(0, 150);
  Offset _s1_v = const Offset(0, 0);
  bool _s1_connected = false;
  double _s1_angle = 30; // Degrees
  bool _s1_protPlaced = false;
  Offset _s1_protX = const Offset(150, 200);
  bool _s1_superimposed = false;

  // Scene 2 (SSS)
  Offset _s2_triPos = const Offset(150, 100);
  bool _s2_basePlaced = false;
  bool _s2_arcL = false;
  bool _s2_arcR = false;
  bool _s2_formed = false;
  bool _s2_superimposed = false;

  // Scene 3 (AAA)
  Offset _s3_pos = const Offset(100, 100);
  double _s3_width = 120;
  double _s3_aA = 45;
  double _s3_aB = 45;
  bool _s3_superimposed = false;

  // Scene 4 (SSA)
  Offset _s4_base = const Offset(0, 150);
  bool _s4_basePlaced = false;
  double _s4_protAngle = 0;
  bool _s4_ray = false;
  bool _s4_arc = false;
  bool _s4_t1Formed = false;
  bool _s4_t2Formed = false;
  Offset _s4_t1Pos = const Offset(-120, 100);
  Offset _s4_t2Pos = const Offset(120, 100);
  bool _s4_superimposed = false;

  // Scene 5 (ASA)
  bool _s5_basePlaced = false;
  double _s5_protAngle = 0;
  String _s5_protState = 'idle'; // idle, left, right
  Offset _s5_protPos = const Offset(-180, 150);
  bool _s5_rayL = false;
  bool _s5_rayR = false;
  bool _s5_formed = false;
  Offset _s5_panelPos = const Offset(0, 0);
  bool _s5_installed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _sidebarScrollController.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      switch (type) {
        case 'click': await _clickPlayer.play(AssetSource(_clickUrl)); break;
        case 'success': await _successPlayer.play(AssetSource(_successUrl)); break;
        case 'error': await _errorPlayer.play(AssetSource(_errorUrl)); break;
        case 'enter': await _fxPlayer.play(AssetSource(_shutterUrl)); break;
      }
    } catch (_) {}
  }

  String _t(String key) {
    return localizedStrings[_currentLang]?[key] ?? key;
  }

  void _loadScenario(int val) {
    setState(() {
      _scenario = val;
      _step = 0;
      _message = '';
      _panOffset = Offset.zero;
      _zoom = 0.85;

      // Reset states
      _s1_s8 = const Offset(50, -50); _s1_s4 = const Offset(50, 50); _s1_v = const Offset(50, 0);
      _s1_connected = false; _s1_angle = 30; _s1_protPlaced = false; _s1_protX = const Offset(150, 200); _s1_superimposed = false;

      _s2_triPos = const Offset(150, 100); _s2_basePlaced = false; _s2_arcL = false; _s2_arcR = false; _s2_formed = false; _s2_superimposed = false;

      _s3_pos = const Offset(100, 100); _s3_width = 100; _s3_aA = 45; _s3_aB = 45; _s3_superimposed = false;

      _s4_base = const Offset(0, 150); _s4_basePlaced = false; _s4_protAngle = 0; _s4_ray = false; _s4_arc = false;
      _s4_t1Formed = false; _s4_t2Formed = false; _s4_t1Pos = const Offset(-120, 100); _s4_t2Pos = const Offset(120, 100); _s4_superimposed = false;

      _s5_basePlaced = false; _s5_protAngle = 0; _s5_protState = 'idle'; _s5_protPos = const Offset(-180, 150);
      _s5_rayL = false; _s5_rayR = false; _s5_formed = false; _s5_panelPos = const Offset(0, 0); _s5_installed = false;
    });

    _scrollToActiveStep();
  }

  void _showMessage(String text, {bool isError = false}) {
    setState(() {
      _message = text;
      _messageIsError = isError;
    });
    if (isError) _playSound('error');
    else _playSound('click');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _message = '');
    });
  }

  void _advanceStep() {
    setState(() => _step++);
    _scrollToActiveStep();
  }

  void _scrollToActiveStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int maxSteps = _scenario == 2 || _scenario == 4 || _scenario == 5 ? 5 : 4;
      int safeIndex = math.min(_step, maxSteps - 1);

      if (_stepKeys[safeIndex].currentContext != null) {
        Scrollable.ensureVisible(
          _stepKeys[safeIndex].currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1, // Scroll it towards the top of the view
        );
      }
    });
  }

  void _checkScenarioSuccess() {
    _playSound('success');
    setState(() {
      _step++; 
      if (_scenario == 5) _labCompletedFully = true;
    });
    _scrollToActiveStep();
  }

  // Core coordinate mapping logic (Screen -> Canvas offset)
  Offset _getCanvasLocal(Offset screenPosition, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    return (screenPosition - center - _panOffset) / _zoom;
  }

  double _baseZoom = 0.85;
  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _baseZoom = _zoom;
    if (details.pointerCount >= 2) {
      _activeTool = 'canvas_zoom';
      return;
    }
    Offset canvasLocal = _getCanvasLocal(details.localFocalPoint, size);
    _activeTool = '';
    _dragOffset = Offset.zero;

    setState(() {
      switch (_scenario) {
        case 1:
          if (_step == 0 && !_s1_connected) {
            if ((canvasLocal - _s1_s8).distance < 100) { _activeTool = 's1_s8'; _dragOffset = _s1_s8 - canvasLocal; }
            else if ((canvasLocal - _s1_s4).distance < 100) { _activeTool = 's1_s4'; _dragOffset = _s1_s4 - canvasLocal; }
          } else if (_step == 1 && _s1_connected && !_s1_superimposed) {
            if ((canvasLocal - _s1_v).distance < 100) { _activeTool = 's1_v'; _dragOffset = _s1_v - canvasLocal; }
          } else if (_step == 2) {
            if (!_s1_protPlaced && (canvasLocal - _s1_protX).distance < 150) { _activeTool = 's1_prot'; _dragOffset = _s1_protX - canvasLocal; }
            else if (_s1_protPlaced) {
              double aBC = -50 * math.pi / 180;
              double curAAB = aBC - (_s1_angle * math.pi / 180);
              Offset handle = _s1_v + Offset(math.cos(curAAB) * 240, math.sin(curAAB) * 240);
              if ((canvasLocal - handle).distance < 100) _activeTool = 's1_rotate';
            }
          } else if (_step == 3 && !_s1_superimposed) {
            if ((canvasLocal - _s1_v).distance < 100) { _activeTool = 's1_v'; _dragOffset = _s1_v - canvasLocal; }
          }
          break;
        case 2:
          if (_step == 0 && !_s2_basePlaced) {
            if ((canvasLocal - _s2_triPos).distance < 100) { _activeTool = 's2_tri'; _dragOffset = _s2_triPos - canvasLocal; }
          } else if (_step == 4 && _s2_formed && !_s2_superimposed) {
            if ((canvasLocal - _s2_triPos).distance < 100) { _activeTool = 's2_tri'; _dragOffset = _s2_triPos - canvasLocal; }
          }
          break;
        case 3:
          if (_step == 0) {
            Offset hA = _s3_pos + Offset(math.cos(-_s3_aA * math.pi / 180) * 50, math.sin(-_s3_aA * math.pi / 180) * 50);
            Offset hB = _s3_pos + Offset(_s3_width + math.cos(math.pi + _s3_aB * math.pi / 180) * 50, math.sin(math.pi + _s3_aB * math.pi / 180) * 50);
            if ((canvasLocal - hA).distance < 80) _activeTool = 's3_aA';
            else if ((canvasLocal - hB).distance < 80) _activeTool = 's3_aB';
          } else if (_step == 1 && !_s3_superimposed) {
            if (canvasLocal.dx > _s3_pos.dx - 50 && canvasLocal.dx < _s3_pos.dx + _s3_width + 50 && canvasLocal.dy > _s3_pos.dy - 100 && canvasLocal.dy < _s3_pos.dy + 50) { 
              _activeTool = 's3_move'; _dragOffset = _s3_pos - canvasLocal; 
            }
          } else if (_step >= 2 && !_s3_superimposed) {
            Offset hScale = _s3_pos + Offset(_s3_width, 0);
            if ((canvasLocal - hScale).distance < 80) _activeTool = 's3_scale';
            else if (canvasLocal.dx > _s3_pos.dx - 50 && canvasLocal.dx < _s3_pos.dx + _s3_width + 50 && canvasLocal.dy > _s3_pos.dy - 100 && canvasLocal.dy < _s3_pos.dy + 50) { 
              _activeTool = 's3_move'; _dragOffset = _s3_pos - canvasLocal; 
            }
          }
          break;
        case 4:
          if (_step == 0 && !_s4_basePlaced) {
            if ((canvasLocal - const Offset(0, 200)).distance < 120) _activeTool = 's4_base'; 
          } else if (_step == 1 && !_s4_ray) {
            Offset bL = _s4_base - const Offset(90, 0);
            Offset h = bL + Offset(math.cos(-_s4_protAngle * math.pi/180) * 150, math.sin(-_s4_protAngle * math.pi/180) * 150);
            if ((canvasLocal - h).distance < 100) _activeTool = 's4_prot';
          } else if (_step >= 4 && !_s4_superimposed) {
            if ((canvasLocal - _s4_t1Pos).distance < 100) { _activeTool = 's4_t1'; _dragOffset = _s4_t1Pos - canvasLocal; }
            else if ((canvasLocal - _s4_t2Pos).distance < 100) { _activeTool = 's4_t2'; _dragOffset = _s4_t2Pos - canvasLocal; }
          }
          break;
        case 5:
          if (_step == 2 && !_s5_formed) {
            if (_s5_protState == 'idle') {
              if ((canvasLocal - _s5_protPos).distance < 120) { _activeTool = 's5_prot'; _dragOffset = _s5_protPos - canvasLocal; }
            } else if (_s5_protState == 'left') {
              Offset h = const Offset(-100, 200) + Offset(math.cos(-_s5_protAngle * math.pi/180) * 150, math.sin(-_s5_protAngle * math.pi/180) * 150);
              if ((canvasLocal - h).distance < 100) _activeTool = 's5_rotateL';
            } else if (_s5_protState == 'right') {
              Offset h = const Offset(100, 200) + Offset(math.cos(-_s5_protAngle * math.pi/180) * 150, math.sin(-_s5_protAngle * math.pi/180) * 150);
              if ((canvasLocal - h).distance < 100) _activeTool = 's5_rotateR';
            }
          } else if (_step >= 3 && _s5_formed && !_s5_installed) {
            if ((canvasLocal - Offset(_s5_panelPos.dx, 150 + _s5_panelPos.dy - 60)).distance < 150) {
              _activeTool = 's5_panel'; _dragOffset = _s5_panelPos - canvasLocal;
            }
          }
          break;
      }

      if (_activeTool.isEmpty) {
        _activeTool = 'canvas_pan';
      } else {
        _playSound('click');
      }
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_activeTool == 'canvas_zoom') {
      setState(() {
        _zoom = (_baseZoom * details.scale).clamp(0.2, 3.0);
        _panOffset += details.focalPointDelta;
      });
      return;
    }
    if (_activeTool == 'canvas_pan') {
      setState(() => _panOffset += details.focalPointDelta);
      return;
    }

    Offset canvasLocal = _getCanvasLocal(details.localFocalPoint, size);

    setState(() {
      if (_activeTool == 's1_s8') {
        _s1_s8 = canvasLocal + _dragOffset;
        if ((_s1_s8 - _s1_s4).distance < 80) { _s1_connected = true; _s1_v = _s1_s8; _playSound('click'); _advanceStep(); _activeTool = ''; }
      } else if (_activeTool == 's1_s4') {
        _s1_s4 = canvasLocal + _dragOffset;
        if ((_s1_s8 - _s1_s4).distance < 80) { _s1_connected = true; _s1_v = _s1_s8; _playSound('click'); _advanceStep(); _activeTool = ''; }
      } else if (_activeTool == 's1_v') {
        _s1_v = canvasLocal + _dragOffset;
        if (_step == 1 && (_s1_v - const Offset(-200, 80)).distance < 100) {
          _showMessage(_t('mismatchLbl'), isError: true);
          _s1_v = const Offset(50, 0); _advanceStep(); _activeTool = '';
        } else if (_step == 3 && (_s1_v - const Offset(-200, 80)).distance < 100) {
          _s1_superimposed = true; _s1_v = const Offset(-200, 80); _checkScenarioSuccess(); _activeTool = '';
        }
      } else if (_activeTool == 's1_prot') {
        _s1_protX = canvasLocal + _dragOffset;
        if ((_s1_protX - _s1_v).distance < 100) { _s1_protPlaced = true; _playSound('click'); _activeTool = ''; }
      } else if (_activeTool == 's1_rotate') {
        double aBC = -50 * math.pi / 180;
        double aPtr = math.atan2(canvasLocal.dy - _s1_v.dy, canvasLocal.dx - _s1_v.dx);
        double relA = (aBC - aPtr) * 180 / math.pi;
        if (relA < 0) relA += 360; if (relA > 180) relA = 180;
        if ((relA - 80).abs() < 5) { relA = 80; if (_s1_angle != 80) { _playSound('click'); _advanceStep(); _activeTool = ''; } }
        _s1_angle = relA;
      } else if (_activeTool == 's2_tri') {
        _s2_triPos = canvasLocal + _dragOffset;
        if (_step == 0 && (_s2_triPos - const Offset(150, 150)).distance < 100) { _s2_basePlaced = true; _s2_triPos = const Offset(150, 150); _playSound('click'); _advanceStep(); _activeTool = ''; }
        else if (_step == 4 && (_s2_triPos - const Offset(-200, 0)).distance < 100) { _s2_superimposed = true; _s2_triPos = const Offset(-200, 0); _checkScenarioSuccess(); _activeTool = ''; }
      } else if (_activeTool == 's3_aA') {
        double a = -math.atan2(canvasLocal.dy - _s3_pos.dy, canvasLocal.dx - _s3_pos.dx) * 180 / math.pi;
        if (a > 10 && a < 170) { if ((a - 80).abs() < 5) a = 80; _s3_aA = a; }
        if (_s3_aA == 80 && _s3_aB == 70) { _playSound('click'); _advanceStep(); _activeTool = ''; }
      } else if (_activeTool == 's3_aB') {
        double a = -math.atan2(canvasLocal.dy - _s3_pos.dy, (_s3_pos.dx + _s3_width) - canvasLocal.dx) * 180 / math.pi;
        if (a > 10 && a < 170) { if ((a - 70).abs() < 5) a = 70; _s3_aB = a; }
        if (_s3_aA == 80 && _s3_aB == 70) { _playSound('click'); _advanceStep(); _activeTool = ''; }
      } else if (_activeTool == 's3_move') {
        _s3_pos = canvasLocal + _dragOffset;
        if (_step == 1 && (_s3_pos - const Offset(-250, 100)).distance < 100) { _s3_pos = const Offset(100, 100); _showMessage(_t('mismatchLbl'), isError: true); _advanceStep(); _activeTool = ''; }
        else if (_step == 3 && _s3_width == 180 && (_s3_pos - const Offset(-250, 100)).distance < 100) { _s3_superimposed = true; _s3_pos = const Offset(-250, 100); _checkScenarioSuccess(); _activeTool = ''; }
      } else if (_activeTool == 's3_scale') {
        double w = canvasLocal.dx - _s3_pos.dx;
        if (w > 40 && w < 300) { if ((w - 180).abs() < 10) w = 180; _s3_width = w; }
        if (_step == 2 && _s3_width == 180) { _advanceStep(); _activeTool = ''; }
      } else if (_activeTool == 's4_base') {
        if ((canvasLocal - const Offset(0, 200)).distance < 120) { _s4_basePlaced = true; _playSound('click'); _advanceStep(); _activeTool = ''; }
      } else if (_activeTool == 's4_prot') {
        Offset bL = _s4_base - const Offset(90, 0);
        double a = -math.atan2(canvasLocal.dy - bL.dy, canvasLocal.dx - bL.dx) * 180 / math.pi;
        if (a > 0 && a < 180) {
          if ((a - 30).abs() < 5) { a = 30; _s4_ray = true; _playSound('click'); _advanceStep(); _activeTool = ''; }
          _s4_protAngle = a;
        }
      } else if (_activeTool == 's4_t1') {
        _s4_t1Pos = canvasLocal + _dragOffset;
        if ((_s4_t1Pos - _s4_t2Pos).distance < 100) { _s4_superimposed = true; _s4_t1Pos = _s4_t2Pos; _showMessage(_t('twoDiffTriangles'), isError: true); _checkScenarioSuccess(); _activeTool = ''; }
      } else if (_activeTool == 's4_t2') {
        _s4_t2Pos = canvasLocal + _dragOffset;
        if ((_s4_t1Pos - _s4_t2Pos).distance < 100) { _s4_superimposed = true; _s4_t1Pos = _s4_t2Pos; _showMessage(_t('twoDiffTriangles'), isError: true); _checkScenarioSuccess(); _activeTool = ''; }
      } else if (_activeTool == 's5_prot') {
        _s5_protPos = canvasLocal + _dragOffset;
        if ((_s5_protPos - const Offset(-100, 200)).distance < 100 && !_s5_rayL) { _s5_protState = 'left'; _s5_protPos = const Offset(-100, 200); _s5_protAngle=0; _playSound('click'); _activeTool = ''; }
        else if ((_s5_protPos - const Offset(100, 200)).distance < 100 && !_s5_rayR) { _s5_protState = 'right'; _s5_protPos = const Offset(100, 200); _s5_protAngle=0; _playSound('click'); _activeTool = ''; }
      } else if (_activeTool == 's5_rotateL') {
        double a = -math.atan2(canvasLocal.dy - 200, canvasLocal.dx - (-100)) * 180 / math.pi;
        if (a > 0 && a < 180) {
          if ((a - 70).abs() < 5) { a = 70; _s5_rayL = true; _s5_protState = 'idle'; _s5_protPos = const Offset(-180, 150); _playSound('click'); _activeTool = ''; if (_s5_rayL && _s5_rayR && !_s5_formed) { _s5_formed = true; _advanceStep(); } }
          _s5_protAngle = a;
        }
      } else if (_activeTool == 's5_rotateR') {
        double a = -math.atan2(canvasLocal.dy - 200, canvasLocal.dx - 100) * 180 / math.pi;
        if (a > 0 && a < 180) {
          if ((a - 130).abs() < 5) { a = 130; _s5_rayR = true; _s5_protState = 'idle'; _s5_protPos = const Offset(-180, 150); _playSound('click'); _activeTool = ''; if (_s5_rayL && _s5_rayR && !_s5_formed) { _s5_formed = true; _advanceStep(); } }
          _s5_protAngle = a;
        }
      } else if (_activeTool == 's5_panel') {
        _s5_panelPos = canvasLocal + _dragOffset;
        if ((_s5_panelPos - const Offset(0, -200)).distance < 120) { _s5_installed = true; _s5_panelPos = const Offset(0, -200); _checkScenarioSuccess(); _activeTool = ''; }
      }
    });
  }

  void _handleTap(TapDownDetails details, Size size) {
    Offset canvasLocal = _getCanvasLocal(details.localPosition, size);

    setState(() {
      switch (_scenario) {
        case 2:
          if (_step == 1 && _s2_basePlaced && !_s2_arcL) {
             if ((canvasLocal - const Offset(150-90, 150)).distance < 80) { _s2_arcL = true; _playSound('click'); _advanceStep(); }
          } else if (_step == 2 && _s2_arcL && !_s2_arcR) {
             if ((canvasLocal - const Offset(150+90, 150)).distance < 80) { _s2_arcR = true; _playSound('click'); _advanceStep(); }
          } else if (_step == 3 && _s2_arcL && _s2_arcR && !_s2_formed) {
             double angA = math.acos(-0.25);
             Offset intersect = const Offset(150-90, 150) + Offset(math.cos(-angA)*120, math.sin(-angA)*120);
             if ((canvasLocal - intersect).distance < 80) { _s2_formed = true; _playSound('click'); _advanceStep(); }
          }
          break;
        case 4:
          if (_step == 2 && _s4_ray && !_s4_arc) {
             Offset bR = _s4_base + const Offset(90, 0);
             if ((canvasLocal - bR).distance < 80) { _s4_arc = true; _playSound('click'); _advanceStep(); }
          } else if (_step == 3 && _s4_arc) {
             Offset ix1 = _s4_base - const Offset(23.7, 38.3);
             Offset ix2 = _s4_base + const Offset(113.7, -117.6);
             if (!_s4_t1Formed && (canvasLocal - ix1).distance < 80) { _s4_t1Formed = true; _playSound('click'); }
             if (!_s4_t2Formed && (canvasLocal - ix2).distance < 80) { _s4_t2Formed = true; _playSound('click'); }
             if (_s4_t1Formed && _s4_t2Formed) _advanceStep();
          }
          break;
        case 5:
          if (_step == 0) {
             _playSound('click'); _advanceStep();
          } else if (_step == 1 && !_s5_basePlaced) {
             _s5_basePlaced = true; _playSound('click'); _advanceStep();
          }
          break;
      }
    });
  }

  // --- WIDGET BUILDING ---
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300;

    bool isScenarioCompleted = _step > (_scenario == 2 || _scenario == 4 || _scenario == 5 ? 4 : 3);

    return Scaffold(
      body: Stack(
        children: [
          // 1. MAIN WORKSPACE CANVAS
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? sidebarWidth : 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xFF0F172A), 
              child: LayoutBuilder(
                builder: (context, constraints) {
                  Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque, // Ensures dragging works on blank areas
                    onScaleStart: (d) => _handleScaleStart(d, canvasSize),
                    onScaleUpdate: (d) => _handleScaleUpdate(d, canvasSize),
                    onTapDown: (d) => _handleTap(d, canvasSize),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: WorkspacePainter(
                        panOffset: _panOffset,
                        zoom: _zoom,
                        scenario: _scenario,
                        step: _step,
                        s1_s8: _s1_s8, s1_s4: _s1_s4, s1_v: _s1_v, s1_connected: _s1_connected, s1_angle: _s1_angle, s1_protPlaced: _s1_protPlaced, s1_protX: _s1_protX, s1_superimposed: _s1_superimposed,
                        s2_triPos: _s2_triPos, s2_basePlaced: _s2_basePlaced, s2_arcL: _s2_arcL, s2_arcR: _s2_arcR, s2_formed: _s2_formed, s2_superimposed: _s2_superimposed,
                        s3_pos: _s3_pos, s3_width: _s3_width, s3_aA: _s3_aA, s3_aB: _s3_aB, s3_superimposed: _s3_superimposed,
                        s4_base: _s4_base, s4_basePlaced: _s4_basePlaced, s4_protAngle: _s4_protAngle, s4_ray: _s4_ray, s4_arc: _s4_arc, s4_t1Formed: _s4_t1Formed, s4_t2Formed: _s4_t2Formed, s4_t1Pos: _s4_t1Pos, s4_t2Pos: _s4_t2Pos, s4_superimposed: _s4_superimposed,
                        s5_basePlaced: _s5_basePlaced, s5_protAngle: _s5_protAngle, s5_protState: _s5_protState, s5_protPos: _s5_protPos, s5_rayL: _s5_rayL, s5_rayR: _s5_rayR, s5_formed: _s5_formed, s5_panelPos: _s5_panelPos, s5_installed: _s5_installed,
                        t: _t,
                      ),
                    ),
                  );
                }
              ),
            ),
          ),

          // 2. SCROLLABLE SIDEBAR
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? 0 : -sidebarWidth,
            top: 0,
            bottom: 0,
            width: sidebarWidth,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xE61E293B), // Panel BG
                border: Border(right: BorderSide(color: Colors.white12)),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(5, 0))],
              ),
              child: SingleChildScrollView(
                controller: _sidebarScrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 70, bottom: 16, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title & Subtitle
                    Text(_t('appTitle'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                    Text(_t('appSubtitle'), style: const TextStyle(fontSize: 10, color: Colors.indigoAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Language Toggle and Reset Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.language, size: 18, color: Colors.white70),
                              label: Text(_currentLang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Colors.white12),
                                ),
                              ),
                              onPressed: () {
                                _playSound('click');
                                setState(() {
                                  if (_currentLang == 'en') _currentLang = 'hi';
                                  else _currentLang = 'en';
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text(_t('reset')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () {
                              _playSound('error');
                              setState(() {
                                _currentLang = 'en';
                                _isCurtainRaised = false;
                                _labCompletedFully = false;
                              });
                              _loadScenario(1);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 16),

                    // Scenario Selector
                    Text(_t('selectScenario'), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
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
                          value: _scenario,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          items: [1, 2, 3, 4, 5].map((int val) {
                            return DropdownMenuItem<int>(
                              value: val,
                              child: Text(_t('s${val}_title')),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _playSound('click');
                              _loadScenario(val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Objective Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.track_changes, color: Colors.pinkAccent, size: 18),
                              const SizedBox(width: 8),
                              Text(_t('learnLbl'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_t('s${_scenario}_obj'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Steps List
                    ...List.generate(
                      _scenario == 2 || _scenario == 4 || _scenario == 5 ? 5 : 4, 
                      (index) => Container(
                        key: _stepKeys[index],
                        child: _buildStepCard(index, compact: false),
                      )
                    ),

                    // Summary Box (Shows on completion of scenario)
                    if (isScenarioCompleted)
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(_t('summaryTitle'), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_t('s${_scenario}_sum'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(_t('footer'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. MENU ICON FLOATING ON TOP LEFT CORNER
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
              color: Colors.orangeAccent,
              iconSize: 28,
              onPressed: () {
                HapticFeedback.lightImpact();
                _playSound('click');
                setState(() => _isSidebarOpen = !_isSidebarOpen);
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                ),
              ),
            ),
          ),

          // 4. NEXT SCENARIO BUTTON ON CANVAS
          if (isScenarioCompleted && _scenario < 5)
            Positioned(
              bottom: 40,
              left: _isSidebarOpen ? sidebarWidth + (screenWidth - sidebarWidth)/2 - 120 : screenWidth/2 - 120,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: Text(_t('nextScenario'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                ),
                onPressed: () {
                  _playSound('click');
                  _loadScenario(_scenario + 1);
                },
              ),
            ),

          // 5. DRAGGABLE ACTIVE STEP CARD (Visible only when sidebar is closed)
          if (!_isSidebarOpen)
            Positioned(
              left: _stepCardPos.dx,
              top: _stepCardPos.dy,
              child: GestureDetector(behavior: HitTestBehavior.opaque, 
                onPanUpdate: (details) {
                  setState(() => _stepCardPos += details.delta);
                },
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xE61E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [Icon(Icons.drag_indicator, color: Colors.white54, size: 16)],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: _buildStepCard(math.min(_step, (_scenario == 2 || _scenario == 4 || _scenario == 5 ? 4 : 3)), compact: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 6. MESSAGE OVERLAY (Error/Info)
          if (_message.isNotEmpty)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _messageIsError ? Colors.redAccent.shade700 : Colors.green.shade700,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                  ),
                  child: Text(_message, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          // 7. DRAGGABLE SUCCESS POPUP
          if (_labCompletedFully)
            Positioned(
              left: _successPopupPos.dx,
              top: _successPopupPos.dy,
              child: GestureDetector(behavior: HitTestBehavior.opaque, 
                onPanUpdate: (details) {
                  setState(() => _successPopupPos += details.delta);
                },
                child: Container(
                  width: 320,
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 30)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 32), 
                            const Icon(Icons.drag_indicator, color: Colors.white54, size: 20),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () { _playSound('click'); setState(() => _labCompletedFully = false); },
                            )
                          ],
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const CircleAvatar(radius: 30, backgroundColor: Colors.green, child: Icon(Icons.flag, size: 30, color: Colors.white)),
                                const SizedBox(height: 16),
                                Text(_t('labCompleted'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(_t('finalDesc'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: Text(_t('reset'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    backgroundColor: Colors.indigoAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  onPressed: () {
                                    _playSound('click');
                                    setState(() { 
                                      _currentLang = 'en';
                                      _labCompletedFully = false; 
                                      _isCurtainRaised = false;
                                    });
                                    _loadScenario(1);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 8. CURTAIN RAISER OVERLAY
          if (!_isCurtainRaised)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF020617),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.architecture, size: 100, color: Colors.indigoAccent),
                      const SizedBox(height: 24),
                      Text(_t('appTitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_t('appSubtitle'), style: const TextStyle(color: Colors.indigoAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: Text(_t('enterLab'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        ),
                        onPressed: () {
                          _playSound('enter');
                          setState(() => _isCurtainRaised = true);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int index, {bool compact = false}) {
    bool isCompleted = index < _step;
    bool isActive = index == _step;
    
    Color bgColor = isActive ? Colors.indigo.withOpacity(0.2) : (isCompleted ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.02));
    Color borderColor = isActive ? Colors.indigoAccent : (isCompleted ? Colors.green : Colors.transparent);
    
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 0 : 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : (isActive ? Colors.indigoAccent : Colors.white24),
              shape: BoxShape.circle,
            ),
            child: isCompleted 
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_t('stepLabel')} ${index + 1}', style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_t('s${_scenario}_step${index + 1}_task'), style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: compact ? 12 : 13, height: 1.4)),
                if (isCompleted && !compact) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Text('${_t('expOut')} ${_t('s${_scenario}_step${index + 1}_out')}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- FULL WORKSPACE PAINTER (Recreates HTML Visuals) ---
class WorkspacePainter extends CustomPainter {
  final Offset panOffset;
  final double zoom;
  final int scenario;
  final int step;
  final Function(String) t;

  final Offset s1_s8, s1_s4, s1_v, s1_protX;
  final bool s1_connected, s1_protPlaced, s1_superimposed;
  final double s1_angle;

  final Offset s2_triPos;
  final bool s2_basePlaced, s2_arcL, s2_arcR, s2_formed, s2_superimposed;

  final Offset s3_pos;
  final double s3_width, s3_aA, s3_aB;
  final bool s3_superimposed;

  final Offset s4_base, s4_t1Pos, s4_t2Pos;
  final bool s4_basePlaced, s4_ray, s4_arc, s4_t1Formed, s4_t2Formed, s4_superimposed;
  final double s4_protAngle;

  final bool s5_basePlaced, s5_formed, s5_installed, s5_rayL, s5_rayR;
  final double s5_protAngle;
  final String s5_protState;
  final Offset s5_protPos, s5_panelPos;

  WorkspacePainter({
    required this.panOffset, required this.zoom,
    required this.scenario, required this.step, required this.t,
    required this.s1_s8, required this.s1_s4, required this.s1_v, required this.s1_connected, required this.s1_angle, required this.s1_protPlaced, required this.s1_protX, required this.s1_superimposed,
    required this.s2_triPos, required this.s2_basePlaced, required this.s2_arcL, required this.s2_arcR, required this.s2_formed, required this.s2_superimposed,
    required this.s3_pos, required this.s3_width, required this.s3_aA, required this.s3_aB, required this.s3_superimposed,
    required this.s4_base, required this.s4_basePlaced, required this.s4_protAngle, required this.s4_ray, required this.s4_arc, required this.s4_t1Formed, required this.s4_t2Formed, required this.s4_t1Pos, required this.s4_t2Pos, required this.s4_superimposed,
    required this.s5_basePlaced, required this.s5_protAngle, required this.s5_protState, required this.s5_protPos, required this.s5_rayL, required this.s5_rayR, required this.s5_formed, required this.s5_panelPos, required this.s5_installed,
  });

  void drawText(Canvas canvas, String text, Offset pos, {Color color = Colors.white, double size = 16, bool bold = true}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center,
    );
    painter.layout();
    painter.paint(canvas, pos - Offset(painter.width / 2, painter.height / 2));
  }

  void drawProtractor(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    
    Path p = Path()..arcTo(Rect.fromCircle(center: Offset.zero, radius: 120), math.pi, math.pi, false)..lineTo(120, 0)..lineTo(-120, 0)..close();
    canvas.drawPath(p, Paint()..color = Colors.white.withOpacity(0.9)..style = PaintingStyle.fill);
    canvas.drawPath(p, Paint()..color = Colors.blueGrey..strokeWidth = 2..style = PaintingStyle.stroke);
    
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: 20), math.pi, math.pi, false, Paint()..color = Colors.blueGrey..strokeWidth=2..style=PaintingStyle.stroke);

    for(int i=0; i<=180; i+=10) {
      double a = i * math.pi/180;
      double outer = 120;
      double inner = (i % 90 == 0) ? 100 : 110;
      canvas.drawLine(Offset(-math.cos(a)*inner, -math.sin(a)*inner), Offset(-math.cos(a)*outer, -math.sin(a)*outer), Paint()..color = Colors.blueGrey..strokeWidth=1);
    }
    canvas.restore();
  }

  void drawTargetBlueprint(Canvas canvas, Offset pos, Path shape, List<String> labels, List<Offset> labelPos) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 280, height: 240), const Radius.circular(16)), 
        Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 280, height: 240), const Radius.circular(16)), 
        Paint()..color = Colors.white12..strokeWidth=2..style = PaintingStyle.stroke);
    
    drawText(canvas, t('targetLbl'), pos - const Offset(0, 100), color: Colors.white54, size: 14);

    canvas.save();
    canvas.translate(pos.dx, pos.dy + 30);
    canvas.drawPath(shape, Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth=12..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
    canvas.drawPath(shape, Paint()..color = Colors.white70..strokeWidth=6..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
    
    for(int i=0; i<labels.length; i++) {
      drawText(canvas, labels[i], labelPos[i], size: 12);
    }
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx + panOffset.dx, center.dy + panOffset.dy);
    canvas.scale(zoom);

    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    for (double i = -1000; i < 1000; i += 40) {
      canvas.drawLine(Offset(i, -1000), Offset(i, 1000), gridPaint);
      canvas.drawLine(Offset(-1000, i), Offset(1000, i), gridPaint);
    }

    final stickPaint = Paint()..strokeWidth = 10..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final handlePaint = Paint()..color = Colors.redAccent..style = PaintingStyle.fill;

    void drawHandle(Offset pos, Color color) {
      canvas.drawCircle(pos, 10, handlePaint..color = color);
      canvas.drawCircle(pos, 5, handlePaint..color = Colors.white);
    }

    switch (scenario) {
      case 1:
        Path s1Target = Path()..moveTo(math.cos(-130*math.pi/180)*240, math.sin(-130*math.pi/180)*240)..lineTo(0,0)..lineTo(math.cos(-50*math.pi/180)*120, math.sin(-50*math.pi/180)*120);
        drawTargetBlueprint(canvas, const Offset(-200, 80), s1Target, ["8cm", "4cm", "80°"], [const Offset(-60, -60), const Offset(40, -40), const Offset(0, -20)]);

        if (!s1_superimposed) {
          if (!s1_connected) {
            canvas.drawLine(s1_s8, s1_s8 + const Offset(240, 0), stickPaint..color = Colors.orange);
            drawText(canvas, "8cm", s1_s8 + const Offset(120, -15));
            drawHandle(s1_s8, Colors.lightBlue);

            canvas.drawLine(s1_s4, s1_s4 + Offset(math.cos(-30*math.pi/180)*120, math.sin(-30*math.pi/180)*120), stickPaint..color = Colors.amber);
            drawText(canvas, "4cm", s1_s4 + const Offset(60, 15));
            drawHandle(s1_s4, Colors.lightBlue);
          } else {
            double aBC = -50 * math.pi/180;
            double aAB = aBC - (s1_angle * math.pi/180);
            Offset pA = s1_v + Offset(math.cos(aAB)*240, math.sin(aAB)*240);
            Offset pC = s1_v + Offset(math.cos(aBC)*120, math.sin(aBC)*120);
            
            canvas.drawLine(s1_v, pA, stickPaint..color = Colors.orange);
            canvas.drawLine(s1_v, pC, stickPaint..color = Colors.amber);
            drawHandle(s1_v, Colors.blueGrey);
            
            canvas.drawArc(Rect.fromCircle(center: s1_v, radius: 40), aAB, (s1_angle * math.pi/180), false, Paint()..color=Colors.greenAccent..strokeWidth=3..style=PaintingStyle.stroke);
            drawText(canvas, "${s1_angle.round()}°", s1_v + const Offset(15, -45), color: Colors.greenAccent);

            if (step == 2) {
               drawProtractor(canvas, s1_protPlaced ? s1_v : s1_protX, aBC);
               if (!s1_protPlaced) {
                  drawHandle(s1_protX, Colors.pinkAccent);
                  drawText(canvas, t('dragProtractor'), s1_protX + const Offset(0, 30));
               } else {
                  drawHandle(pA, Colors.lightBlueAccent); // rotate handle
               }
            }
          }
        } else {
          canvas.save(); canvas.translate(-200, 80 + 30);
          canvas.drawPath(s1Target, Paint()..color = Colors.greenAccent..strokeWidth=6..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
          drawText(canvas, t('congruentLbl'), const Offset(0, -180), color: Colors.greenAccent, size: 24);
          canvas.restore();
        }
        break;

      case 2:
        double angA = math.acos(-0.25);
        Path s2Target = Path()..moveTo(-90,0)..lineTo(90,0)..lineTo(-90 + math.cos(-angA)*120, math.sin(-angA)*120)..close();
        drawTargetBlueprint(canvas, const Offset(-200, 0), s2Target, ["6cm", "4cm", "8cm"], [const Offset(0, 15), const Offset(-60, -40), const Offset(50, -40)]);

        if (!s2_superimposed) {
          Offset bL = s2_triPos - const Offset(90, 0);
          Offset bR = s2_triPos + const Offset(90, 0);

          if (!s2_formed) {
            canvas.drawLine(bL, bR, stickPaint..color = Colors.blue);
            drawText(canvas, "6cm", s2_triPos + const Offset(0, 15));
            
            if (s2_basePlaced) {
              if (!s2_arcL) drawHandle(bL, Colors.white);
              else if (!s2_arcR) drawHandle(bR, Colors.white);

              if (s2_arcL) canvas.drawArc(Rect.fromCircle(center: bL, radius: 120), -math.pi, math.pi/1.5, false, Paint()..color=Colors.blueAccent.withOpacity(0.5)..strokeWidth=3..style=PaintingStyle.stroke);
              if (s2_arcR) canvas.drawArc(Rect.fromCircle(center: bR, radius: 240), -math.pi, -math.pi/1.5, false, Paint()..color=Colors.redAccent.withOpacity(0.5)..strokeWidth=3..style=PaintingStyle.stroke);
              
              if (s2_arcL && s2_arcR) {
                 Offset ix = bL + Offset(math.cos(-angA)*120, math.sin(-angA)*120);
                 drawHandle(ix, Colors.amber);
              }
            } else {
               drawText(canvas, t('drag6cmGuide'), const Offset(150, 150));
            }
          } else {
            Offset ix = bL + Offset(math.cos(-angA)*120, math.sin(-angA)*120);
            Path tri = Path()..moveTo(bL.dx, bL.dy)..lineTo(bR.dx, bR.dy)..lineTo(ix.dx, ix.dy)..close();
            canvas.drawPath(tri, Paint()..color=Colors.blue.withOpacity(0.3)..style=PaintingStyle.fill);
            canvas.drawPath(tri, stickPaint..color=Colors.blue);
            if (step == 4) drawText(canvas, t('dragToTarget'), s2_triPos + const Offset(0, 40));
          }
        } else {
          canvas.save(); canvas.translate(-200, 30);
          canvas.drawPath(s2Target, Paint()..color = Colors.greenAccent..strokeWidth=6..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
          drawText(canvas, t('congruentLbl'), const Offset(0, -180), color: Colors.greenAccent, size: 24);
          canvas.restore();
        }
        break;

      case 3:
        double aAt = 80*math.pi/180, aBt = 70*math.pi/180;
        double tCx = 180 * math.tan(aBt) / (math.tan(aAt) + math.tan(aBt));
        double tCy = -math.tan(aAt) * tCx;
        Path s3Target = Path()..moveTo(-90,0)..lineTo(90,0)..lineTo(-90+tCx, tCy)..close();
        drawTargetBlueprint(canvas, const Offset(-250, 100), s3Target, ["80°", "70°", "30°"], [const Offset(-60, -10), const Offset(60, -10), const Offset(-10, -150)]);

        if (!s3_superimposed) {
          double aRad = s3_aA * math.pi/180;
          double bRad = s3_aB * math.pi/180;
          double cx = s3_width * math.tan(bRad) / (math.tan(aRad) + math.tan(bRad));
          double cy = -math.tan(aRad) * cx;

          Offset pR = s3_pos + Offset(s3_width, 0);
          Offset pT = s3_pos + Offset(cx, cy);

          if (step == 0) {
            canvas.drawLine(s3_pos, pR, stickPaint..color = Colors.indigo);
            canvas.drawLine(s3_pos, s3_pos + Offset(math.cos(-aRad)*200, math.sin(-aRad)*200), Paint()..color=Colors.lightBlue..strokeWidth=2..style=PaintingStyle.stroke);
            canvas.drawLine(pR, pR + Offset(math.cos(math.pi+bRad)*200, math.sin(math.pi+bRad)*200), Paint()..color=Colors.lightBlue..strokeWidth=2..style=PaintingStyle.stroke);
            
            Offset hA = s3_pos + Offset(math.cos(-aRad)*50, math.sin(-aRad)*50);
            Offset hB = pR + Offset(math.cos(math.pi+bRad)*50, math.sin(math.pi+bRad)*50);
            drawHandle(hA, Colors.redAccent); drawHandle(hB, Colors.redAccent);
            
            canvas.drawArc(Rect.fromCircle(center: s3_pos, radius: 30), -aRad, aRad, false, Paint()..color=Colors.redAccent..strokeWidth=2..style=PaintingStyle.stroke);
            drawText(canvas, "${s3_aA.round()}°", s3_pos + const Offset(15, -15), color: Colors.redAccent);
            canvas.drawArc(Rect.fromCircle(center: pR, radius: 30), math.pi, bRad, false, Paint()..color=Colors.redAccent..strokeWidth=2..style=PaintingStyle.stroke);
            drawText(canvas, "${s3_aB.round()}°", pR + const Offset(-15, -15), color: Colors.redAccent);
          } else {
            Path tri = Path()..moveTo(s3_pos.dx, s3_pos.dy)..lineTo(pR.dx, pR.dy)..lineTo(pT.dx, pT.dy)..close();
            canvas.drawPath(tri, Paint()..color=Colors.indigo.withOpacity(0.3)..style=PaintingStyle.fill);
            canvas.drawPath(tri, stickPaint..color=Colors.indigo);
            
            canvas.drawArc(Rect.fromCircle(center: s3_pos, radius: 25), -aRad, aRad, false, Paint()..color=Colors.redAccent..strokeWidth=2..style=PaintingStyle.stroke);
            canvas.drawArc(Rect.fromCircle(center: pR, radius: 25), math.pi, bRad, false, Paint()..color=Colors.redAccent..strokeWidth=2..style=PaintingStyle.stroke);
            
            if (step >= 2) {
              drawHandle(pR, Colors.greenAccent);
              drawText(canvas, t('dragToScale'), pR + const Offset(50, 0));
            }
          }
        } else {
          canvas.save(); canvas.translate(-250, 130);
          canvas.drawPath(s3Target, Paint()..color = Colors.greenAccent..strokeWidth=6..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
          drawText(canvas, t('congruentLbl'), const Offset(0, -180), color: Colors.greenAccent, size: 24);
          canvas.restore();
        }
        break;

      case 4:
        Offset bL = s4_base - const Offset(90, 0);
        Offset bR = s4_base + const Offset(90, 0);
        
        if (!s4_basePlaced && step == 0) {
           canvas.drawLine(const Offset(-90, 200), const Offset(90, 200), stickPaint..color = Colors.blue);
           drawText(canvas, "6cm", const Offset(0, 215));
           drawText(canvas, t('baseline'), s4_base + const Offset(0, 30), color: Colors.white54);
           canvas.drawLine(s4_base - const Offset(200, 0), s4_base + const Offset(200, 0), Paint()..color=Colors.white24..strokeWidth=2..style=PaintingStyle.stroke);
        } else {
           canvas.drawLine(s4_base - const Offset(200, 0), s4_base + const Offset(200, 0), Paint()..color=Colors.white24..strokeWidth=2..style=PaintingStyle.stroke);
           drawText(canvas, t('baseline'), s4_base + const Offset(0, 30), color: Colors.white54);
           
           if (!s4_superimposed) {
              canvas.drawLine(bL, bR, stickPaint..color = Colors.blue);
              
              if (step == 1) {
                 drawProtractor(canvas, bL, 0);
                 double a = s4_protAngle * math.pi/180;
                 canvas.drawLine(bL, bL + Offset(math.cos(-a)*300, math.sin(-a)*300), Paint()..color=Colors.purple..strokeWidth=2..style=PaintingStyle.stroke);
                 Offset h = bL + Offset(math.cos(-a)*150, math.sin(-a)*150);
                 drawHandle(h, Colors.redAccent);
                 drawText(canvas, "${s4_protAngle.round()}°", h + const Offset(20, 0));
              } else if (step > 1) {
                 double a = 30 * math.pi/180;
                 canvas.drawLine(bL, bL + Offset(math.cos(-a)*300, math.sin(-a)*300), Paint()..color=Colors.purple..strokeWidth=2..style=PaintingStyle.stroke);
                 canvas.drawArc(Rect.fromCircle(center: bL, radius: 40), -a, a, false, Paint()..color=Colors.amber..strokeWidth=2..style=PaintingStyle.stroke);
                 drawText(canvas, "30°", bL + const Offset(50, -15), color: Colors.amber);
              }

              if (step == 2) {
                 canvas.drawArc(Rect.fromCircle(center: bR, radius: 120), -math.pi, math.pi, false, Paint()..color=Colors.redAccent.withOpacity(0.5)..strokeWidth=2..style=PaintingStyle.stroke);
                 drawHandle(bR, Colors.pinkAccent);
              } else if (step > 2) {
                 canvas.drawArc(Rect.fromCircle(center: bR, radius: 120), -math.pi, math.pi, false, Paint()..color=Colors.redAccent.withOpacity(0.5)..strokeWidth=2..style=PaintingStyle.stroke);
                 Offset ix1 = s4_base - const Offset(23.7, 38.3);
                 Offset ix2 = s4_base + const Offset(113.7, -117.6);
                 
                 if (step == 3) {
                    if (!s4_t1Formed) drawHandle(ix1, Colors.amber);
                    if (!s4_t2Formed) drawHandle(ix2, Colors.amber);
                 }
              }

              if (step >= 4) {
                 Path t1 = Path()..moveTo(s4_t1Pos.dx - 90, s4_t1Pos.dy)..lineTo(s4_t1Pos.dx + 90, s4_t1Pos.dy)..lineTo(s4_t1Pos.dx - 23.7, s4_t1Pos.dy - 38.3)..close();
                 canvas.drawPath(t1, Paint()..color=Colors.greenAccent.withOpacity(0.4)..style=PaintingStyle.fill);
                 canvas.drawPath(t1, stickPaint..color=Colors.green);

                 Path t2 = Path()..moveTo(s4_t2Pos.dx - 90, s4_t2Pos.dy)..lineTo(s4_t2Pos.dx + 90, s4_t2Pos.dy)..lineTo(s4_t2Pos.dx + 113.7, s4_t2Pos.dy - 117.6)..close();
                 canvas.drawPath(t2, Paint()..color=Colors.redAccent.withOpacity(0.4)..style=PaintingStyle.fill);
                 canvas.drawPath(t2, stickPaint..color=Colors.redAccent);
              }
           } else {
              Path t1 = Path()..moveTo(-90, 50)..lineTo(90, 50)..lineTo(-23.7, 50 - 38.3)..close();
              Path t2 = Path()..moveTo(-90, 50)..lineTo(90, 50)..lineTo(113.7, 50 - 117.6)..close();
              canvas.drawPath(t1, stickPaint..color=Colors.green);
              canvas.drawPath(t2, stickPaint..color=Colors.redAccent);
           }
        }
        break;

      case 5:
        final bridgePaint = Paint()..color = Colors.blueGrey..strokeWidth = 16..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(-400, 0), const Offset(400, 0), bridgePaint);
        canvas.drawLine(const Offset(-300, -150), const Offset(300, -150), bridgePaint);
        canvas.drawLine(const Offset(-400, 0), const Offset(-300, -150), bridgePaint);
        canvas.drawLine(const Offset(-300, -150), const Offset(-200, 0), bridgePaint);
        canvas.drawLine(const Offset(0, -150), const Offset(100, 0), bridgePaint);
        canvas.drawLine(const Offset(100, 0), const Offset(200, -150), bridgePaint);
        canvas.drawLine(const Offset(200, -150), const Offset(300, 0), bridgePaint);

        Path gap = Path()..moveTo(-100, 0)..lineTo(100, 0)..lineTo(-39.5, -166)..close();
        if (!s5_installed) {
           canvas.drawPath(gap, Paint()..color=Colors.amber.withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth=4);
           drawText(canvas, t('missingPanel'), const Offset(0, -50), color: Colors.amber, size: 14);
        } else {
           canvas.drawPath(gap, Paint()..color=Colors.greenAccent.withOpacity(0.4)..style=PaintingStyle.fill);
           canvas.drawPath(gap, stickPaint..color=Colors.greenAccent);
        }

        if (!s5_installed) {
           canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 200), width: 600, height: 250), const Radius.circular(16)), 
               Paint()..color=const Color(0xFF1E293B)..style=PaintingStyle.fill);
           drawText(canvas, t('workshopLbl'), const Offset(-250, 100), color: Colors.white70);

           if (step == 0) {
              Path blueprint = Path()..moveTo(-60, 220)..lineTo(60, 220)..lineTo(-20, 140)..close();
              canvas.drawPath(blueprint, Paint()..color=Colors.lightBlue..strokeWidth=2..style=PaintingStyle.stroke);
              drawText(canvas, "5m", const Offset(0, 235), color: Colors.lightBlue);
              drawText(canvas, "70°", const Offset(-30, 210), color: Colors.lightBlue, size: 12);
              drawText(canvas, "50°", const Offset(30, 210), color: Colors.lightBlue, size: 12);
           } else if (step > 0) {
              Offset bL = s5_panelPos + const Offset(-100, 200);
              Offset bR = s5_panelPos + const Offset(100, 200);
              
              if (!s5_basePlaced) {
                 canvas.drawLine(const Offset(-100, 200), const Offset(100, 200), Paint()..color=Colors.white24..strokeWidth=2..style=PaintingStyle.stroke);
                 drawText(canvas, "Tap to place 5m base", const Offset(0, 220), color: Colors.amber);
              } else {
                 canvas.drawLine(bL, bR, stickPaint..color=Colors.amber);
                 
                 if (s5_rayL) {
                    canvas.drawLine(bL, bL + Offset(math.cos(-70*math.pi/180)*250, math.sin(-70*math.pi/180)*250), Paint()..color=Colors.lightBlue..strokeWidth=2..style=PaintingStyle.stroke);
                    canvas.drawArc(Rect.fromCircle(center: bL, radius: 30), -70*math.pi/180, 70*math.pi/180, false, Paint()..color=Colors.redAccent..strokeWidth=2..style=PaintingStyle.stroke);
                 }
                 if (s5_rayR) {
                    canvas.drawLine(bR, bR + Offset(math.cos(math.pi+50*math.pi/180)*250, math.sin(math.pi+50*math.pi/180)*250), Paint()..color=Colors.lightBlue..strokeWidth=2..style=PaintingStyle.stroke);
                    canvas.drawArc(Rect.fromCircle(center: bR, radius: 30), math.pi, 50*math.pi/180, false, Paint()..color=Colors.redAccent..strokeWidth=2..style=PaintingStyle.stroke);
                 }

                 if (s5_formed) {
                    Path panel = Path()..moveTo(bL.dx, bL.dy)..lineTo(bR.dx, bR.dy)..lineTo(s5_panelPos.dx - 39.5, s5_panelPos.dy + 34)..close();
                    canvas.drawPath(panel, Paint()..color=Colors.amber.withOpacity(0.5)..style=PaintingStyle.fill);
                    canvas.drawPath(panel, stickPaint..color=Colors.amber);
                 } else if (step == 2) {
                    if (s5_protState == 'idle') {
                       drawProtractor(canvas, s5_protPos, 0);
                       drawHandle(s5_protPos, Colors.pinkAccent);
                       if (!s5_rayL) drawHandle(const Offset(-100, 200), Colors.amber);
                       if (s5_rayL && !s5_rayR) drawHandle(const Offset(100, 200), Colors.amber);
                    } else if (s5_protState == 'left') {
                       drawProtractor(canvas, const Offset(-100, 200), 0);
                       double a = s5_protAngle * math.pi/180;
                       canvas.drawLine(const Offset(-100, 200), const Offset(-100, 200) + Offset(math.cos(-a)*200, math.sin(-a)*200), Paint()..color=Colors.purple..strokeWidth=2..style=PaintingStyle.stroke);
                       Offset h = const Offset(-100, 200) + Offset(math.cos(-a)*150, math.sin(-a)*150);
                       drawHandle(h, Colors.redAccent);
                       drawText(canvas, "${s5_protAngle.round()}°", h + const Offset(30, 0));
                    } else if (s5_protState == 'right') {
                       drawProtractor(canvas, const Offset(100, 200), 0);
                       double a = s5_protAngle * math.pi/180;
                       canvas.drawLine(const Offset(100, 200), const Offset(100, 200) + Offset(math.cos(-a)*200, math.sin(-a)*200), Paint()..color=Colors.purple..strokeWidth=2..style=PaintingStyle.stroke);
                       Offset h = const Offset(100, 200) + Offset(math.cos(-a)*150, math.sin(-a)*150);
                       drawHandle(h, Colors.redAccent);
                       drawText(canvas, "${180 - s5_protAngle.round()}°", h + const Offset(-30, 0));
                    }
                 }
              }
           }
        } else {
           drawText(canvas, t('repairComplete'), const Offset(0, -250), color: Colors.greenAccent, size: 32);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}