// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CorrespondingAnglesApp());
}

class CorrespondingAnglesApp extends StatelessWidget {
  const CorrespondingAnglesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Corresponding Angles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: Colors.blueAccent,
      ),
      home: const CorrespondingAnglesLab(),
    );
  }
}

class Scenario {
  final int id;
  final String title;
  final String objective;
  final List<ScenarioStep> steps;

  Scenario({
    required this.id,
    required this.title,
    required this.objective,
    required this.steps,
  });
}

class ScenarioStep {
  final String hud;
  final String text;
  final String? summary;

  ScenarioStep({required this.hud, required this.text, this.summary});
}

class CorrespondingAnglesLab extends StatefulWidget {
  const CorrespondingAnglesLab({super.key});

  @override
  State<CorrespondingAnglesLab> createState() => _CorrespondingAnglesLabState();
}

class _CorrespondingAnglesLabState extends State<CorrespondingAnglesLab>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _curtainOpen = false;
  int _activeScenario = 1;
  int _activeStep = 0;
  bool _actionValidated = false;

  // Language & Theme State
  int _langIdx = 0;
  static const List<String> _supportedLanguages = ['en', 'hi'];
  String get _currentLanguage =>
      _supportedLanguages[_langIdx % _supportedLanguages.length];
  final double _fontSize = 13.0;

  // S1 State
  double _s1TTilt = 300.0;
  double _s1MTilt = -15.0;
  bool _s1TrainRunning = false;

  // S2 State
  double _s2MPrimeAngle = -30.0;
  bool _s2ProActive = false;

  // S3 State
  bool _s3AMeas = false;
  bool _s3BMeas = false;
  double _s3MTilt = -20.0;

  // S4 State
  bool _s4RulerDropped = false;
  double _s4RulerDropX = 0;
  double _s4RulerDropY = 0;
  double _s4P1X = -150.0;
  double _s4TAngle = 45.0;
  bool _s4P1Done = false;
  bool _s4P2Done = false;
  bool _s4TransversalDrawn = false;
  bool _s4Measured = false;
  double _s4MTilt = -30.0;
  bool _s4Checking = false;

  // S5 State
  bool _s5MDropped = false;
  bool _s5NDropped = false;
  double _s5MY = 50.0;
  double _s5NY = 250.0;
  double _s5MTilt = 0.0;
  double _s5NTilt = 0.0;
  bool _s5Checking = false;
  bool _s5CarsRunning = false;

  // View state (Gestures)
  double _zoom = 1.0;
  double _initialZoom = 1.0;
  Offset _pan = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  String? _activeDragType;
  Offset _dragOffset = Offset.zero;

  // Modals
  bool _showSummary = false;
  bool _showSuccessAll = false;
  String _currentSummary = '';
  final Set<int> _completedScenarios = {};
  Offset? _dialogPos;

  // Animations
  late AnimationController _s1AnimController;
  late AnimationController _s5AnimController;

  // UI Feedback
  String _hudFeedback = "";
  Color _hudFeedbackColor = Colors.green;
  bool _showHudFeedback = false;
  late List<Scenario> scenarios;

  // Audio Players
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl =
      'audio/class7/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class7/mixkit_2018.mp3';
  static const String _alertUrl =
      'audio/class7/mixkit_2869.mp3';
  static const String _errorUrl =
      'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';

  // --- TRANSLATIONS MAP ---
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'appTitle': "Corresponding Angles & Parallelism",
      'appSubtitle': "Class 7 • PARALLEL AND INTERSECTING LINES",
      'enterLab': "Start Mission",
      'toggleLang': "Toggle Language",
      'resetLab': "Reset",
      'settingsBtn': "Settings",
      'togglePan': "Toggle Pan Mode",
      'lockView': "Lock View",
      'zoomIn': "Zoom In",
      'zoomOut': "Zoom Out",
      'resetView': "Reset View",
      'selectScenario': "Select Mission",
      'theory': "Observation Notes",
      'missionObj': "Objective:",
      'procSteps': "Geometry Log",
      'stepLabel': "STEP",
      'labSummary': "Mission Report",
      'missionComplete': "Mission Completed!",
      'selectAnotherScenario': "You have successfully verified this property.",
      'allCompletedTitle': "Geometry Master!",
      'allCompletedText':
          "You have successfully mastered the relationship between corresponding angles and parallel lines!",
      'restartLab': "Restart Mission",

      'scen1Title': "1. The Magical Train Tracks",
      's1Obj': "Discover the exact condition that makes two lines parallel.",
      's1_1_hud': "DRAG the handle on line 'M' to rotate it.",
      's1_1_txt':
          "Observe the two lines, 'L' and 'M', crossed by a transversal 'T'. Notice how the corresponding angles '∠a' and '∠b' change as you manipulate line 'M'.",
      's1_2_hud': "ROTATE line 'M' until the measurement of ∠b matches ∠a.",
      's1_2_txt':
          "When the corresponding angles '∠a' and '∠b' become perfectly equal, observe the relationship between the two lines. They snap into a parallel state!",
      's1_3_hud': "DRAG the transversal 'T' to change its angle.",
      's1_3_txt':
          "Notice that as long as the lines remain parallel, the corresponding angles stay equal, regardless of how the transversal line is angled.",
      's1_sum':
          "You have discovered the secret! When corresponding angles are equal, the lines are parallel. This is always true, no matter the angle of the transversal.\n\n∠a = ∠b ↔ Lines are Parallel",

      'scen2Title': "2. The Laser Grid Alignment",
      's2Obj':
          "Use the mathematical property of parallel lines to set a corresponding angle correctly.",
      's2_1_hud':
          "CLICK the Protractor button to bring the tool into the scene.",
      's2_1_txt':
          "Two perfectly parallel laser beams are crossed by a transversal. One angle is known (60°). Since the lines are parallel, we can deduce the corresponding angle.",
      's2_2_hud': "DRAG the handle on the protractor to align beam m' to 60°.",
      's2_2_txt':
          "Observe that setting the corresponding angle to exactly match the known angle (60°) forces the new line to be perfectly parallel to the original.",
      's2_sum':
          "Because lines 'L' and 'M' are parallel, their corresponding angles MUST be exactly equal (60°). You proved it geometrically!",

      'scen3Title': "3. The Intersecting Roads",
      's3Obj':
          "Understand that non-parallel lines have unequal corresponding angles.",
      's3_1_hud':
          "CLICK on the corresponding angles ∠a and ∠b to measure them.",
      's3_1_txt':
          "When lines are clearly intersecting (not parallel), their corresponding angles are not equal. Measure them to verify.",
      's3_2_hud': "DRAG the value of ∠b to match ∠a.",
      's3_2_txt':
          "Observe that attempting to make the corresponding angles equal inherently changes the trajectory of the line, proving non-parallel lines cannot have equal corresponding angles.",
      's3_sum':
          "For lines that are not parallel, their corresponding angles are NEVER equal. The only way to make them equal is to make the roads parallel!",

      'scen4Title': "4. Building a Bookshelf",
      's4Obj':
          "Construct a line parallel to a given line through a specific point.",
      's4_1_hud':
          "DRAG the Ruler from the toolbox to the canvas to draw a transversal.",
      's4_1_txt':
          "To construct a parallel line, we first need a transversal line that intersects both our reference line and our target point.",
      's4_2_hud':
          "DRAG the Protractor to the bottom intersection to measure the angle.",
      's4_2_txt':
          "Measuring the angle at the intersection gives us the reference corresponding angle needed for our construction.",
      's4_3_hud':
          "ROTATE Shelf M to match the measured angle, then CLICK 'Check My Work'.",
      's4_3_txt':
          "By duplicating the exact corresponding angle at the new point, we guarantee the newly constructed line is perfectly parallel to the original.",
      's4_sum':
          "The spirit level confirms it! By ensuring the corresponding angles are exactly equal, you have constructed a perfectly parallel shelf.",

      'scen5Title': "5. City Grid Challenge",
      's5Obj':
          "Apply the concept of corresponding angles to solve a multi-step problem.",
      's5_1_hud': "DRAG 'First Street' from the toolbox onto the map.",
      's5_1_txt':
          "A city map shows a main road, 'Central Avenue' (l). A diagonal road, 'Maple Drive' (t), crosses it at 115°. We need to build two new parallel roads.",
      's5_2_hud':
          "ROTATE 'First Street' (m) to match the 115° corresponding angle.",
      's5_2_txt':
          "Using the 115° angle as your guide, adjust the new road so it runs perfectly parallel to Central Avenue.",
      's5_3_hud':
          "DRAG and ROTATE 'Second Street' (n) to be parallel, then click 'Finalize Plan'.",
      's5_3_txt':
          "Repeat the process to lay down the third parallel road, ensuring its corresponding angle matches the grid.",
      's5_sum':
          "Excellent work! The cars are flowing smoothly. By ensuring all corresponding angles are equal, you proved all three roads are perfectly parallel to each other.",

      'fb_success': "Action registered.",
      'fb_error': "Action invalid. Try again.",
      'fb_s1_snap': "Tracks aligned! Train cleared.",
      'fb_s2_snap': "Alignment locked to 60°.",
      'fb_s4_fail': "Misaligned! Check your angle.",
      'fb_s5_fail': "Roads are not parallel! Check the angles.",
    },
    'hi': {
      'appTitle': "संगत कोण और समांतरता",
      'appSubtitle': "कक्षा 7 • समांतर और प्रतिच्छेदी रेखाएं",
      'enterLab': "मिशन प्रारंभ करें",
      'toggleLang': "भाषा बदलें",
      'resetLab': "रीसेट",
      'settingsBtn': "सेटिंग्स",
      'togglePan': "पैन मोड",
      'lockView': "दृश्य लॉक",
      'zoomIn': "ज़ूम इन",
      'zoomOut': "ज़ूम आउट",
      'resetView': "रीसेट दृश्य",
      'selectScenario': "मिशन चुनें",
      'theory': "अवलोकन नोट्स",
      'missionObj': "उद्देश्य:",
      'procSteps': "ज्यामिति लॉग",
      'stepLabel': "चरण",
      'labSummary': "मिशन रिपोर्ट",
      'missionComplete': "मिशन पूरा हुआ!",
      'selectAnotherScenario':
          "आपने इस संपत्ति को सफलतापूर्वक सत्यापित कर लिया है।",
      'allCompletedTitle': "ज्यामिति मास्टर!",
      'allCompletedText':
          "आपने संगत कोणों और समांतर रेखाओं के बीच संबंध में महारत हासिल कर ली है!",
      'restartLab': "मिशन रीस्टार्ट",

      'scen1Title': "1. जादुई ट्रेन ट्रैक",
      's1Obj': "उस सटीक स्थिति की खोज करें जो दो रेखाओं को समानांतर बनाती है।",
      's1_1_hud': "घुमाने के लिए रेखा 'M' पर हैंडल खींचें।",
      's1_1_txt':
          "एक तिर्यक रेखा 'T' द्वारा पार की गई दो रेखाओं 'L' और 'M' का निरीक्षण करें। ध्यान दें कि जब आप रेखा 'M' में हेरफेर करते हैं तो संगत कोण '∠a' और '∠b' कैसे बदलते हैं।",
      's1_2_hud': "∠b के माप को ∠a से मिलाने के लिए रेखा 'M' को घुमाएँ।",
      's1_2_txt':
          "जब संगत कोण '∠a' और '∠b' पूरी तरह से समान हो जाते हैं, तो दोनों रेखाओं के बीच के संबंध का निरीक्षण करें। वे एक समानांतर स्थिति में आ जाते हैं!",
      's1_3_hud': "कोण बदलने के लिए तिर्यक रेखा 'T' को खींचें।",
      's1_3_txt':
          "ध्यान दें कि जब तक रेखाएँ समानांतर रहती हैं, तब तक संगत कोण समान रहते हैं, चाहे तिर्यक रेखा किसी भी कोण पर क्यों न हो।",
      's1_sum':
          "जब संगत कोण समान होते हैं, तो रेखाएँ समानांतर होती हैं। तिर्यक रेखा का कोण कुछ भी हो, यह हमेशा सत्य है।",

      'scen2Title': "2. लेजर ग्रिड संरेखण",
      's2Obj':
          "एक संगत कोण को सही ढंग से सेट करने के लिए समानांतर रेखाओं के गणितीय गुण का उपयोग करें।",
      's2_1_hud': "प्रोट्रैक्टर टूल को स्क्रीन पर लाने के लिए क्लिक करें।",
      's2_1_txt':
          "दो पूरी तरह से समानांतर लेजर बीम एक तिर्यक रेखा द्वारा पार किए जाते हैं। एक कोण ज्ञात है (60°)। चूँकि रेखाएँ समानांतर हैं, हम संगत कोण का अनुमान लगा सकते हैं।",
      's2_2_hud':
          "किरण m' को 60° पर संरेखित करने के लिए प्रोट्रैक्टर हैंडल खींचें।",
      's2_2_txt':
          "ध्यान दें कि संगत कोण को ज्ञात कोण (60°) से बिल्कुल मेल खाने के लिए सेट करने से नई किरण मूल किरण के पूरी तरह से समानांतर हो जाती है।",
      's2_sum':
          "चूंकि रेखाएं 'L' और 'M' समानांतर हैं, इसलिए उनके संगत कोण बिल्कुल समान (60°) होने चाहिए।",

      'scen3Title:': "3. प्रतिच्छेदी सड़कें",
      's3Obj': "समझें कि गैर-समानांतर रेखाओं के संगत कोण असमान होते हैं।",
      's3_1_hud': "संगत कोणों ∠a और ∠b को मापने के लिए उन पर क्लिक करें।",
      's3_1_txt':
          "जब रेखाएँ स्पष्ट रूप से प्रतिच्छेद कर रही हों (समानांतर नहीं), तो उनके संगत कोण समान नहीं होते हैं। सत्यापित करने के लिए उन्हें मापें।",
      's3_2_hud': "∠a से मेल खाने के लिए ∠b के मान को खींचें।",
      's3_2_txt':
          "ध्यान दें कि संगत कोणों को समान बनाने का प्रयास करने से रेखा का प्रक्षेपवक्र बदल जाता है, जिससे यह सिद्ध होता है कि गैर-समानांतर रेखाओं में समान संगत कोण नहीं हो सकते।",
      's3_sum':
          "गैर-समानांतर रेखाओं के लिए, उनके संगत कोण कभी समान नहीं होते हैं।",

      'scen4Title': "4. बुकशेल्फ़ बनाना",
      's4Obj':
          "एक विशिष्ट बिंदु के माध्यम से दी गई रेखा के समानांतर एक रेखा का निर्माण करें।",
      's4_1_hud': "तिर्यक रेखा खींचने के लिए टूलबॉक्स से रूलर को खींचें।",
      's4_1_txt':
          "एक समानांतर रेखा बनाने के लिए, हमें सबसे पहले एक तिर्यक रेखा की आवश्यकता होती है जो हमारी संदर्भ रेखा और हमारे लक्ष्य बिंदु दोनों को पार करती हो।",
      's4_2_hud':
          "कोण मापने के लिए प्रोट्रैक्टर को निचले प्रतिच्छेदन पर खींचें।",
      's4_2_txt':
          "प्रतिच्छेदन पर कोण मापने से हमें निर्माण के लिए आवश्यक संदर्भ संगत कोण प्राप्त होता है।",
      's4_3_hud':
          "मापे गए कोण से मेल खाने के लिए शेल्फ M को घुमाएं, फिर 'Check My Work' पर क्लिक करें।",
      's4_3_txt':
          "नए बिंदु पर सटीक संगत कोण की नकल करके, हम गारंटी देते हैं कि नई निर्मित रेखा मूल के पूरी तरह से समानांतर है।",
      's4_sum':
          "स्प्रिट लेवल इसकी पुष्टि करता है! संगत कोणों को सटीक रूप से समान सुनिश्चित करके, आपने एक पूरी तरह से समानांतर शेल्फ का निर्माण किया है।",

      'scen5Title': "5. सिटी ग्रिड चुनौती",
      's5Obj':
          "एक बहु-चरणीय समस्या को हल करने के लिए संगत कोणों की अवधारणा को लागू करें।",
      's5_1_hud': "टूलबॉक्स से 'First Street' को मैप पर खींचें।",
      's5_1_txt':
          "शहर का नक्शा एक मुख्य सड़क दिखाता है, 'Central Avenue' (l)। एक विकर्ण सड़क, 'Maple Drive' (t), इसे 115° पर पार करती है। हमें दो नई समानांतर सड़कें बनानी हैं।",
      's5_2_hud':
          "115° संगत कोण से मेल खाने के लिए 'First Street' (m) को घुमाएँ।",
      's5_2_txt':
          "अपने मार्गदर्शक के रूप में 115° कोण का उपयोग करते हुए, नई सड़क को इस तरह से समायोजित करें कि वह पूरी तरह से समानांतर हो।",
      's5_3_hud':
          "समानांतर होने के लिए 'Second Street' (n) को खींचें और घुमाएँ, फिर 'Finalize Plan' पर क्लिक करें।",
      's5_3_txt':
          "तीसरी समानांतर सड़क बिछाने के लिए प्रक्रिया को दोहराएं, यह सुनिश्चित करते हुए कि इसका संगत कोण ग्रिड से मेल खाता है।",
      's5_sum':
          "उत्कृष्ट कार्य! गाड़ियाँ सुचारू रूप से चल रही हैं। यह सुनिश्चित करके कि सभी संगत कोण समान हैं, आपने साबित कर दिया कि तीनों सड़कें एक-दूसरे के पूरी तरह समानांतर हैं।",

      'fb_success': "कार्रवाई पंजीकृत।",
      'fb_error': "अमान्य कार्रवाई।",
      'fb_s1_snap': "ट्रैक संरेखित!",
      'fb_s2_snap': "संरेखण 60° पर लॉक किया गया।",
      'fb_s4_fail': "गलत संरेखण! अपने कोण की जाँच करें।",
      'fb_s5_fail': "सड़कें समानांतर नहीं हैं! कोणों की जाँच करें.",
    },
  };

  String t(String key) {
    return translations[_currentLanguage]?[key] ??
        translations['en']?[key] ??
        key;
  }

  void _cycleLanguage() {
    _playSound(_clickPlayer);
    setState(() {
      _langIdx = (_langIdx + 1) % _supportedLanguages.length;
      _initScenarios();
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _s1AnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _s1AnimController.addListener(() => setState(() {}));

    _s5AnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _s5AnimController.addListener(() => setState(() {}));

    _initAudio();
    _initScenarios();
  }

  void _initAudio() async {
    await _clickPlayer.setSourceAsset(_clickUrl);
    await _fxPlayer.setSourceAsset(_alertUrl);
    await _successPlayer.setSourceAsset(_successUrl);
    await _errorPlayer.setSourceAsset(_errorUrl);
    await _shutterPlayer.setSourceAsset(_shutterUrl);
  }

  void _playSound(AudioPlayer player) {
    player.stop();
    player.resume();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _s1AnimController.dispose();
    _s5AnimController.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    super.dispose();
  }

  void _masterReset() {
    _playSound(_errorPlayer);
    setState(() {
      _curtainOpen = false;
      _isSidebarOpen = true;
      _activeScenario = 1;
      _activeStep = 0;
      _actionValidated = false;
      _completedScenarios.clear();
      _showSummary = false;
      _showSuccessAll = false;
      _dialogPos = null;
      _zoom = 1.0;
      _pan = Offset.zero;
      _langIdx = 0;

      _s1TTilt = 300.0;
      _s1MTilt = -15.0;
      _s1TrainRunning = false;
      _s2MPrimeAngle = -30.0;
      _s2ProActive = false;
      _s3AMeas = false;
      _s3BMeas = false;
      _s3MTilt = -20.0;

      _s4RulerDropped = false;
      _s4P1X = -150.0;
      _s4TAngle = 45.0;
      _s4P1Done = false;
      _s4P2Done = false;
      _s4TransversalDrawn = false;
      _s4Measured = false;
      _s4MTilt = -30.0;
      _s4Checking = false;

      _s5MDropped = false;
      _s5NDropped = false;
      _s5MY = 50.0;
      _s5NY = 250.0;
      _s5MTilt = 0.0;
      _s5NTilt = 0.0;
      _s5Checking = false;
      _s5CarsRunning = false;

      _s1AnimController.reset();
      _s5AnimController.reset();

      _initScenarios();
    });
  }

  void _initScenarios() {
    scenarios = [
      Scenario(
        id: 1,
        title: t('scen1Title'),
        objective: t('s1Obj'),
        steps: [
          ScenarioStep(hud: t('s1_1_hud'), text: t('s1_1_txt')),
          ScenarioStep(hud: t('s1_2_hud'), text: t('s1_2_txt')),
          ScenarioStep(
            hud: t('s1_3_hud'),
            text: t('s1_3_txt'),
            summary: t('s1_sum'),
          ),
        ],
      ),
      Scenario(
        id: 2,
        title: t('scen2Title'),
        objective: t('s2Obj'),
        steps: [
          ScenarioStep(hud: t('s2_1_hud'), text: t('s2_1_txt')),
          ScenarioStep(
            hud: t('s2_2_hud'),
            text: t('s2_2_txt'),
            summary: t('s2_sum'),
          ),
        ],
      ),
      Scenario(
        id: 3,
        title: t('scen3Title'),
        objective: t('s3Obj'),
        steps: [
          ScenarioStep(hud: t('s3_1_hud'), text: t('s3_1_txt')),
          ScenarioStep(
            hud: t('s3_2_hud'),
            text: t('s3_2_txt'),
            summary: t('s3_sum'),
          ),
        ],
      ),
      Scenario(
        id: 4,
        title: t('scen4Title'),
        objective: t('s4Obj'),
        steps: [
          ScenarioStep(hud: t('s4_1_hud'), text: t('s4_1_txt')),
          ScenarioStep(hud: t('s4_2_hud'), text: t('s4_2_txt')),
          ScenarioStep(
            hud: t('s4_3_hud'),
            text: t('s4_3_txt'),
            summary: t('s4_sum'),
          ),
        ],
      ),
      Scenario(
        id: 5,
        title: t('scen5Title'),
        objective: t('s5Obj'),
        steps: [
          ScenarioStep(hud: t('s5_1_hud'), text: t('s5_1_txt')),
          ScenarioStep(hud: t('s5_2_hud'), text: t('s5_2_txt')),
          ScenarioStep(
            hud: t('s5_3_hud'),
            text: t('s5_3_txt'),
            summary: t('s5_sum'),
          ),
        ],
      ),
    ];
  }

  void _showFeedback(String msg, Color color) {
    setState(() {
      _hudFeedback = msg;
      _hudFeedbackColor = color;
      _showHudFeedback = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHudFeedback = false);
    });
  }

  void _markStepComplete({int delayMs = 1500}) {
    if (_actionValidated) return;
    setState(() => _actionValidated = true);

    _playSound(_successPlayer);
    _showFeedback(t('fb_success'), Colors.greenAccent);

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      final scenario = scenarios[_activeScenario - 1];
      if (_activeStep >= scenario.steps.length) return;

      final step = scenario.steps[_activeStep];
      setState(() {
        _actionValidated = false;
        if (step.summary != null) {
          _playSound(_successPlayer);
          _currentSummary = step.summary!;
          _showSummary = true;
          _dialogPos = null;
          _completedScenarios.add(_activeScenario);
          if (_completedScenarios.length == 5) _showSuccessAll = true;
        } else {
          _activeStep++;
        }
      });
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _activeScenario = id;
      _activeStep = 0;
      _actionValidated = false;
      _showSummary = false;

      _s1TTilt = 300.0;
      _s1MTilt = -15.0;
      _s1TrainRunning = false;
      _s2MPrimeAngle = -30.0;
      _s2ProActive = false;
      _s3AMeas = false;
      _s3BMeas = false;
      _s3MTilt = -20.0;

      _s4RulerDropped = false;
      _s4P1X = -150.0;
      _s4TAngle = 45.0;
      _s4P1Done = false;
      _s4P2Done = false;
      _s4TransversalDrawn = false;
      _s4Measured = false;
      _s4MTilt = -30.0;
      _s4Checking = false;

      _s5MDropped = false;
      _s5NDropped = false;
      _s5MY = 50.0;
      _s5NY = 250.0;
      _s5MTilt = 0.0;
      _s5NTilt = 0.0;
      _s5Checking = false;
      _s5CarsRunning = false;

      _pan = Offset.zero;
      _zoom = 1.0;
      _s1AnimController.reset();
      _s5AnimController.reset();
    });
  }

  Offset _getLogicCoord(Offset globalPos, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final scale =
        math.min(canvasSize.width / 1000, canvasSize.height / 1000) * _zoom;
    return Offset(
      (globalPos.dx - center.dx - _pan.dx) / scale,
      (globalPos.dy - center.dy - _pan.dy) / scale,
    );
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    if (_actionValidated || _s1TrainRunning || _s5CarsRunning) return;

    _initialZoom = _zoom;
    _lastFocalPoint = details.localFocalPoint;
    _activeDragType = null;
    Offset pt = _getLogicCoord(details.localFocalPoint, size);

    if (_activeScenario == 1) {
      if (_activeStep <= 1) {
        double tRad = _s1TTilt * math.pi / 180;
        double tanT = math.tan(tRad) == 0 ? 0.0001 : math.tan(tRad);
        double p2x = 150 / tanT;
        double mRad = _s1MTilt * math.pi / 180;
        double hX = p2x + 300 * math.cos(mRad);
        double hY = 150 + 300 * math.sin(mRad);
        if ((Offset(pt.dx - hX, pt.dy - hY).distance) < 80) {
          _activeDragType = 's1_m_handle';
          _playSound(_clickPlayer);
          return;
        }
      } else if (_activeStep == 2) {
        double tRad = _s1TTilt * math.pi / 180;
        double hX = 350 * math.cos(tRad);
        double hY = 350 * math.sin(tRad);
        if ((Offset(pt.dx - hX, pt.dy - hY).distance) < 80) {
          _activeDragType = 's1_t_handle';
          _playSound(_clickPlayer);
          return;
        }
      }
    }

    if (_activeScenario == 2 && _s2ProActive && _activeStep == 1) {
      double tRad = 300 * math.pi / 180;
      double p2x = 150 / math.tan(tRad);
      double mRad = _s2MPrimeAngle * math.pi / 180;
      double hX = p2x + 150 * math.cos(mRad);
      double hY = 150 + 150 * math.sin(mRad);
      if ((Offset(pt.dx - hX, pt.dy - hY).distance) < 60) {
        _activeDragType = 's2_pro_handle';
        _playSound(_clickPlayer);
        return;
      }
    }

    if (_activeScenario == 3 && _activeStep == 1 && _s3AMeas && _s3BMeas) {
      double tRad = 300 * math.pi / 180;
      double p2x = 150 / math.tan(tRad);
      double angleBEnd = 360 + _s3MTilt;
      double midAngle = (300 + angleBEnd) / 2;
      double hX = p2x + 48 * math.cos(midAngle * math.pi / 180);
      double hY = 150 + 48 * math.sin(midAngle * math.pi / 180);
      if ((Offset(pt.dx - hX, pt.dy - hY).distance) < 60) {
        double startAngle =
            math.atan2(pt.dy - 150, pt.dx - p2x) * 180 / math.pi;
        _dragOffset = Offset(startAngle, _s3MTilt);
        _activeDragType = 's3_b_drag';
        _playSound(_clickPlayer);
        return;
      }
    }

    if (_activeScenario == 4) {
      if (_activeStep == 0 && !_s4TransversalDrawn && !_s4RulerDropped) {
        if ((Offset(pt.dx - (-320), pt.dy - (-270)).distance) < 80) {
          _activeDragType = 's4_ruler';
          _dragOffset = Offset(-320 - pt.dx, -270 - pt.dy);
          _playSound(_clickPlayer);
          return;
        }
      }
      if (_activeStep == 1 && !_s4Measured) {
        if ((Offset(pt.dx - (-320), pt.dy - (-200)).distance) < 80) {
          _activeDragType = 's4_protractor';
          _dragOffset = Offset(-320 - pt.dx, -200 - pt.dy);
          _playSound(_clickPlayer);
          return;
        }
      }
      if (_activeStep == 2 && !_s4Checking) {
        double mRad = _s4MTilt * math.pi / 180;
        double hX = 100 + 300 * math.cos(mRad);
        double hY = -100 + 300 * math.sin(mRad);
        if ((Offset(pt.dx - hX, pt.dy - hY).distance) < 80) {
          _activeDragType = 's4_m_handle';
          _playSound(_clickPlayer);
          return;
        }
      }
    }

    if (_activeScenario == 5 && !_s5Checking && !_s5CarsRunning) {
      if (_activeStep == 0 && !_s5MDropped) {
        if ((Offset(pt.dx - (-320), pt.dy - (-270)).distance) < 80) {
          _activeDragType = 's5_tool_m';
          _dragOffset = Offset(-320 - pt.dx, -270 - pt.dy);
          _playSound(_clickPlayer);
          return;
        }
      }
      if (_activeStep >= 2 && !_s5NDropped) {
        if ((Offset(pt.dx - (-320), pt.dy - (-200)).distance) < 80) {
          _activeDragType = 's5_tool_n';
          _dragOffset = Offset(-320 - pt.dx, -200 - pt.dy);
          _playSound(_clickPlayer);
          return;
        }
      }
      if (_s5MDropped) {
        double pmX = _s5MY / math.tan(-65 * math.pi / 180);
        double rad = _s5MTilt * math.pi / 180;
        double rotX = pmX + 350 * math.cos(rad);
        double rotY = _s5MY + 350 * math.sin(rad);
        if (_activeStep == 1 &&
            (Offset(pt.dx - rotX, pt.dy - rotY).distance) < 80) {
          _activeDragType = 's5_m_rot';
          _playSound(_clickPlayer);
          return;
        }
        double movX = pmX - 200 * math.cos(rad);
        double movY = _s5MY - 200 * math.sin(rad);
        if ((Offset(pt.dx - movX, pt.dy - movY).distance) < 80) {
          _activeDragType = 's5_m_move';
          _dragOffset = Offset(0, pt.dy - _s5MY);
          _playSound(_clickPlayer);
          return;
        }
      }
      if (_s5NDropped) {
        double pnX = _s5NY / math.tan(-65 * math.pi / 180);
        double rad = _s5NTilt * math.pi / 180;
        double rotX = pnX + 350 * math.cos(rad);
        double rotY = _s5NY + 350 * math.sin(rad);
        if ((Offset(pt.dx - rotX, pt.dy - rotY).distance) < 80) {
          _activeDragType = 's5_n_rot';
          _playSound(_clickPlayer);
          return;
        }
        double movX = pnX - 200 * math.cos(rad);
        double movY = _s5NY - 200 * math.sin(rad);
        if ((Offset(pt.dx - movX, pt.dy - movY).distance) < 80) {
          _activeDragType = 's5_n_move';
          _dragOffset = Offset(0, pt.dy - _s5NY);
          _playSound(_clickPlayer);
          return;
        }
      }
    }

    _activeDragType = 'canvas';
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_activeDragType == null) return;

    if (_activeDragType == 'canvas') {
      setState(() {
        _zoom = (_initialZoom * details.scale).clamp(0.5, 4.0);
        if (details.scale == 1.0) {
          _pan += details.localFocalPoint - _lastFocalPoint;
        }
        _lastFocalPoint = details.localFocalPoint;
      });
      return;
    }

    Offset pt = _getLogicCoord(details.localFocalPoint, size);

    setState(() {
      if (_activeDragType == 's1_m_handle') {
        double tRad = _s1TTilt * math.pi / 180;
        double p2x = 150 / (math.tan(tRad) == 0 ? 0.0001 : math.tan(tRad));
        double angleDeg = math.atan2(pt.dy - 150, pt.dx - p2x) * 180 / math.pi;
        if (angleDeg > 30) angleDeg = 30;
        if (angleDeg < -30) angleDeg = -30;
        bool isParallel = false;
        if (angleDeg.abs() < 3) {
          angleDeg = 0;
          isParallel = true;
        }
        _s1MTilt = angleDeg;
        if (_activeStep == 0 && (angleDeg - (-15)).abs() > 5) {
          _markStepComplete(delayMs: 100);
        }
        if (_activeStep == 1 && isParallel) {
          _playSound(_fxPlayer);
          _runS1Train();
          _markStepComplete(delayMs: 1500);
        }
      } else if (_activeDragType == 's1_t_handle') {
        double rawAngle = math.atan2(pt.dy, pt.dx) * 180 / math.pi;
        if (rawAngle < 0) rawAngle += 360;
        if (rawAngle < 210 && rawAngle > 180) rawAngle = 210;
        if (rawAngle > 330 || rawAngle < 180) rawAngle = 330;
        _s1TTilt = rawAngle;
        if (_activeStep == 2 && (_s1TTilt - 300).abs() > 10) {
          _markStepComplete(delayMs: 2000);
        }
      } else if (_activeDragType == 's2_pro_handle') {
        double tRad = 300 * math.pi / 180;
        double p2x = 150 / math.tan(tRad);
        double angleDeg = math.atan2(pt.dy - 150, pt.dx - p2x) * 180 / math.pi;
        if (angleDeg > 15) angleDeg = 15;
        if (angleDeg < -60) angleDeg = -60;
        bool isAligned = false;
        if (angleDeg.abs() < 3) {
          angleDeg = 0;
          isAligned = true;
        }
        _s2MPrimeAngle = angleDeg;
        if (_activeStep == 1 && isAligned) {
          _playSound(_fxPlayer);
          _markStepComplete(delayMs: 1500);
        }
      } else if (_activeDragType == 's3_b_drag') {
        double tRad = 300 * math.pi / 180;
        double p2x = 150 / math.tan(tRad);
        double currentAngle =
            math.atan2(pt.dy - 150, pt.dx - p2x) * 180 / math.pi;
        double delta = currentAngle - _dragOffset.dx;
        if (delta > 180) delta -= 360;
        if (delta < -180) delta += 360;
        double newTilt = _dragOffset.dy + delta * 2;
        if (newTilt > 30) newTilt = 30;
        if (newTilt < -30) newTilt = -30;
        bool isParallel = false;
        if (newTilt.abs() < 2) {
          newTilt = 0;
          isParallel = true;
        }
        _s3MTilt = newTilt;
        if (_activeStep == 1 && isParallel) {
          _playSound(_fxPlayer);
          _markStepComplete(delayMs: 1500);
        }
      } else if (_activeDragType == 's4_ruler') {
        _s4RulerDropX = pt.dx + _dragOffset.dx;
        _s4RulerDropY = pt.dy + _dragOffset.dy;
      } else if (_activeDragType == 's4_protractor') {
        _s4RulerDropX = pt.dx + _dragOffset.dx;
        _s4RulerDropY = pt.dy + _dragOffset.dy; // reuse var
      } else if (_activeDragType == 's4_m_handle') {
        double angleDeg =
            math.atan2(pt.dy - (-100), pt.dx - 100) * 180 / math.pi;
        if (angleDeg > 30) angleDeg = 30;
        if (angleDeg < -60) angleDeg = -60;
        if (angleDeg.abs() < 2) angleDeg = 0;
        _s4MTilt = angleDeg;
      } else if (_activeDragType == 's5_tool_m' ||
          _activeDragType == 's5_tool_n') {
        _s4RulerDropX = pt.dx + _dragOffset.dx;
        _s4RulerDropY = pt.dy + _dragOffset.dy; // reuse var
      } else if (_activeDragType == 's5_m_rot') {
        double pmX = _s5MY / math.tan(-65 * math.pi / 180);
        double angleDeg =
            math.atan2(pt.dy - _s5MY, pt.dx - pmX) * 180 / math.pi;
        if (angleDeg > 30) angleDeg = 30;
        if (angleDeg < -45) angleDeg = -45;
        bool isParallel = false;
        if (angleDeg.abs() < 2) {
          angleDeg = 0;
          isParallel = true;
        }
        _s5MTilt = angleDeg;
        if (_activeStep == 1 && isParallel) {
          _playSound(_fxPlayer);
          _markStepComplete(delayMs: 1500);
        }
      } else if (_activeDragType == 's5_n_rot') {
        double pnX = _s5NY / math.tan(-65 * math.pi / 180);
        double angleDeg =
            math.atan2(pt.dy - _s5NY, pt.dx - pnX) * 180 / math.pi;
        if (angleDeg > 30) angleDeg = 30;
        if (angleDeg < -45) angleDeg = -45;
        if (angleDeg.abs() < 2) angleDeg = 0;
        _s5NTilt = angleDeg;
      } else if (_activeDragType == 's5_m_move') {
        double newY = pt.dy - _dragOffset.dy;
        if (newY < -50) newY = -50;
        if (newY > 100) newY = 100;
        _s5MY = newY;
      } else if (_activeDragType == 's5_n_move') {
        double newY = pt.dy - _dragOffset.dy;
        if (newY < 150) newY = 150;
        if (newY > 350) newY = 350;
        _s5NY = newY;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_activeDragType == null || _activeDragType == 'canvas') {
      _activeDragType = null;
      return;
    }

    setState(() {
      if (_activeDragType == 's4_ruler') {
        if (_s4RulerDropX > -250) {
          _s4RulerDropped = true;
          _playSound(_fxPlayer);
          _showFeedback(t("fb_success"), Colors.green);
        } else {
          _playSound(_errorPlayer);
          _showFeedback(t("fb_error"), Colors.red);
        }
      } else if (_activeDragType == 's4_protractor') {
        if ((Offset(_s4RulerDropX - _s4P1X, _s4RulerDropY - 150).distance) <
            150) {
          _s4Measured = true;
          _playSound(_fxPlayer);
          _markStepComplete(delayMs: 1500);
        } else {
          _playSound(_errorPlayer);
          _showFeedback(t("fb_error"), Colors.red);
        }
      } else if (_activeDragType == 's5_tool_m') {
        if (_s4RulerDropY > -400) {
          _s5MDropped = true;
          _s5MY = math.max(-50, math.min(100, _s4RulerDropY));
          _s5MTilt = -30;
          _playSound(_fxPlayer);
          _markStepComplete(delayMs: 1500);
        } else {
          _playSound(_errorPlayer);
          _showFeedback(t("fb_error"), Colors.red);
        }
      } else if (_activeDragType == 's5_tool_n') {
        if (_s4RulerDropY > -400) {
          _s5NDropped = true;
          _s5NY = math.max(150, math.min(350, _s4RulerDropY));
          _s5NTilt = 25;
          _playSound(_fxPlayer);
        } else {
          _playSound(_errorPlayer);
          _showFeedback(t("fb_error"), Colors.red);
        }
      }
    });
    _activeDragType = null;
  }

  void _handleTap(TapDownDetails details, Size size) {
    if (_actionValidated || _s1TrainRunning || _s5CarsRunning) return;
    Offset pt = _getLogicCoord(details.localPosition, size);

    if (_activeScenario == 2 && _activeStep == 0 && !_s2ProActive) {
      // Protractor button is handled in overlay UI usually, but we can do it here too if needed.
    } else if (_activeScenario == 3 && _activeStep == 0) {
      double tRad = 300 * math.pi / 180;
      double p1x = -150 / math.tan(tRad);
      double p2x = 150 / math.tan(tRad);

      if ((Offset(pt.dx - p1x, pt.dy - (-150)).distance) < 80) {
        _playSound(_clickPlayer);
        setState(() {
          _s3AMeas = true;
          if (_s3AMeas && _s3BMeas) _markStepComplete(delayMs: 1500);
        });
      }
      if ((Offset(pt.dx - p2x, pt.dy - 150).distance) < 80) {
        _playSound(_clickPlayer);
        setState(() {
          _s3BMeas = true;
          if (_s3AMeas && _s3BMeas) _markStepComplete(delayMs: 1500);
        });
      }
    } else if (_activeScenario == 4) {
      if (_activeStep == 0 && _s4RulerDropped && !_s4P1Done) {
        double px = pt.dx;
        if (px > -50) px = -50;
        if (px < -400) px = -400;
        if (pt.dy > 120 && pt.dy < 180 && px >= -400 && px <= -50) {
          setState(() {
            _s4P1X = px;
            _s4P1Done = true;
            double angleRad = math.atan2(-250, 100 - px);
            _s4TAngle = (angleRad * 180 / math.pi).abs().roundToDouble();
          });
          _playSound(_clickPlayer);
        }
      } else if (_activeStep == 0 && _s4P1Done && !_s4P2Done) {
        if ((Offset(pt.dx - 100, pt.dy - (-100)).distance) < 40) {
          setState(() {
            _s4P2Done = true;
            _s4TransversalDrawn = true;
          });
          _playSound(_fxPlayer);
          _markStepComplete(delayMs: 1500);
        }
      }
    }
  }

  void _runS1Train() {
    setState(() => _s1TrainRunning = true);
    _s1AnimController.forward(from: 0).then((_) {
      if (mounted) setState(() => _s1TrainRunning = false);
    });
  }

  void _checkS4Alignment() {
    if (_activeScenario != 4 ||
        _activeStep != 2 ||
        _actionValidated ||
        _s4Checking) {
      return;
    }
    setState(() => _s4Checking = true);

    if (_s4MTilt.abs() < 3) {
      _playSound(_successPlayer);
      _markStepComplete(delayMs: 2000);
    } else {
      _playSound(_errorPlayer);
      _showFeedback(t("fb_s4_fail"), Colors.red);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _s4Checking = false);
      });
    }
  }

  void _checkS5Alignment() {
    if (_activeScenario != 5 ||
        _activeStep != 2 ||
        _actionValidated ||
        _s5Checking) {
      return;
    }
    setState(() => _s5Checking = true);

    if (_s5MTilt.abs() < 3 && _s5NTilt.abs() < 3) {
      _playSound(_successPlayer);
      setState(() {
        _s5MTilt = 0;
        _s5NTilt = 0;
        _s5CarsRunning = true;
      });
      _s5AnimController.forward(from: 0).then((_) {
        if (mounted) setState(() => _s5CarsRunning = false);
      });
      _markStepComplete(delayMs: 3500);
    } else {
      _playSound(_errorPlayer);
      _showFeedback(t("fb_s5_fail"), Colors.red);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _s5Checking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final curScen = scenarios[_activeScenario - 1];
    final curStep =
        _activeStep < curScen.steps.length
            ? curScen.steps[_activeStep]
            : curScen.steps.last;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Offset dialogInitialPos = Offset(
      (screenWidth - 380) / 2,
      (screenHeight - 350) / 2,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            Row(
              children: [
                // SIDEBAR
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSidebarOpen ? screenWidth * 0.35 : 0,
                  color: const Color(0xFF0F172A),
                  child: ClipRect(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),

                            // Top Header Section IN SIDEBAR
                            Text(
                              t('appTitle'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _fontSize + 8,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t('appSubtitle'),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: _fontSize - 2,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: Text(
                                      t('resetLab'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B),
                                      foregroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      side: const BorderSide(
                                        color: Colors.white12,
                                      ),
                                    ),
                                    onPressed: _masterReset,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.language, size: 18),
                                    label: Text(
                                      _currentLanguage.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B),
                                      foregroundColor: Colors.blueAccent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      side: const BorderSide(
                                        color: Colors.white12,
                                      ),
                                    ),
                                    onPressed: _cycleLanguage,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white12, height: 1),
                            const SizedBox(height: 24),

                            Text(
                              t('selectScenario'),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: _fontSize - 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _activeScenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (v) {
                                    if (v != null) {
                                      _playSound(_clickPlayer);
                                      _loadScenario(v);
                                    }
                                  },
                                  items:
                                      scenarios
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s.id,
                                              child: Text(s.title),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
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
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('theory'),
                                        style: TextStyle(
                                          fontSize: _fontSize + 2,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${t('missionObj')} ${curScen.objective}",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      height: 1.4,
                                      fontSize: _fontSize - 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                const Icon(
                                  Icons.format_list_numbered,
                                  color: Colors.blueAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t('procSteps'),
                                  style: TextStyle(
                                    fontSize: _fontSize + 2,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            ...curScen.steps
                                .asMap()
                                .entries
                                .where((e) => e.value.text.isNotEmpty)
                                .map((entry) {
                                  int idx = entry.key;
                                  ScenarioStep s = entry.value;
                                  bool isActive = idx == _activeStep;
                                  bool isPast = idx < _activeStep;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          isActive
                                              ? Colors.blueAccent.withOpacity(
                                                0.15,
                                              )
                                              : isPast
                                              ? Colors.white.withOpacity(0.05)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            isActive
                                                ? Colors.blueAccent
                                                : Colors.white12,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                            right: 12,
                                          ),
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                isPast
                                                    ? Colors.green
                                                    : isActive
                                                    ? Colors.blueAccent
                                                    : Colors.white24,
                                          ),
                                          child:
                                              isPast
                                                  ? const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.white,
                                                  )
                                                  : Center(
                                                    child: Text(
                                                      "${idx + 1}",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${t('stepLabel')} ${idx + 1}",
                                                style: TextStyle(
                                                  color:
                                                      isActive
                                                          ? Colors.blueAccent
                                                          : Colors.grey,
                                                  fontSize: _fontSize - 4,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                s.text,
                                                style: TextStyle(
                                                  color:
                                                      isPast
                                                          ? Colors.grey
                                                          : Colors.white,
                                                  fontSize: _fontSize - 1,
                                                  height: 1.4,
                                                  decoration:
                                                      isPast
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            const SizedBox(height: 40),

                            // Sidebar Footer (Inside scroll)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white12),
                                ),
                              ),
                              child: Text(
                                "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: _fontSize - 4,
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

                // CANVAS AREA
                Expanded(
                  child: ClipRect(
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onScaleStart:
                                  (d) =>
                                      _handleScaleStart(d, constraints.biggest),
                              onScaleUpdate:
                                  (d) => _handleScaleUpdate(
                                    d,
                                    constraints.biggest,
                                  ),
                              onScaleEnd: _handleScaleEnd,
                              onTapDown:
                                  (d) => _handleTap(d, constraints.biggest),
                              child: Container(
                                color: const Color(0xFF040816),
                                width: double.infinity,
                                height: double.infinity,
                                child: CustomPaint(
                                  painter: _AnglesPainter(
                                    scenario: _activeScenario,
                                    step: _activeStep,
                                    zoom: _zoom,
                                    pan: _pan,
                                    s1TTilt: _s1TTilt,
                                    s1MTilt: _s1MTilt,
                                    s1TrainVal: _s1AnimController.value,
                                    s1TrainRunning: _s1TrainRunning,
                                    s2MPrimeAngle: _s2MPrimeAngle,
                                    s2ProActive: _s2ProActive,
                                    s3AMeas: _s3AMeas,
                                    s3BMeas: _s3BMeas,
                                    s3MTilt: _s3MTilt,
                                    s4RulerDropped: _s4RulerDropped,
                                    s4RulerX: _s4RulerDropX,
                                    s4RulerY: _s4RulerDropY,
                                    s4P1X: _s4P1X,
                                    s4TAngle: _s4TAngle,
                                    s4P1Done: _s4P1Done,
                                    s4P2Done: _s4P2Done,
                                    s4TransDrawn: _s4TransversalDrawn,
                                    s4Measured: _s4Measured,
                                    s4MTilt: _s4MTilt,
                                    s4Checking: _s4Checking,
                                    activeDrag: _activeDragType,
                                    s5MDropped: _s5MDropped,
                                    s5NDropped: _s5NDropped,
                                    s5MY: _s5MY,
                                    s5NY: _s5NY,
                                    s5MTilt: _s5MTilt,
                                    s5NTilt: _s5NTilt,
                                    s5Checking: _s5Checking,
                                    s5CarsVal: _s5AnimController.value,
                                    s5CarsRunning: _s5CarsRunning,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Active Step Floating Box (Only when sidebar is closed)
                        if (!_isSidebarOpen && curStep.text.isNotEmpty)
                          Positioned(
                            left: 20,
                            top: 80,
                            child: Container(
                              width: 280,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                ),
                                boxShadow: [
                                  const BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${t('stepLabel')} ${_activeStep + 1}",
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    curStep.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Mini HUD Bottom Persistent feedback
                        if (curStep.hud.isNotEmpty)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 450,
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.1),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          curStep.hud,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_showHudFeedback)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _hudFeedback,
                                        style: TextStyle(
                                          color: _hudFeedbackColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                        // Action Buttons overlays
                        if (_activeScenario == 1 && _activeStep >= 2)
                          Align(
                            alignment: const Alignment(-0.5, 0.4),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text(
                                "REPLAY TRAIN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 10,
                              ),
                              onPressed: () {
                                _playSound(_clickPlayer);
                                _runS1Train();
                              },
                            ),
                          ),

                        if (_activeScenario == 2 &&
                            _activeStep == 0 &&
                            !_s2ProActive)
                          Align(
                            alignment: const Alignment(-0.5, 0.4),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.architecture),
                              label: const Text(
                                "PROTRACTOR",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 10,
                              ),
                              onPressed: () {
                                _popSound();
                                setState(() {
                                  _s2ProActive = true;
                                });
                                _markStepComplete(delayMs: 500);
                              },
                            ),
                          ),

                        if (_activeScenario == 4 &&
                            _activeStep == 2 &&
                            !_s4Checking)
                          Align(
                            alignment: const Alignment(-0.5, 0.4),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle),
                              label: const Text(
                                "CHECK MY WORK",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 10,
                              ),
                              onPressed: _checkS4Alignment,
                            ),
                          ),

                        if (_activeScenario == 5 &&
                            _activeStep >= 2 &&
                            _s5MDropped &&
                            _s5NDropped &&
                            !_s5Checking &&
                            !_s5CarsRunning)
                          Align(
                            alignment: const Alignment(-0.5, 0.4),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle),
                              label: const Text(
                                "FINALIZE PLAN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 10,
                              ),
                              onPressed: _checkS5Alignment,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Left Menu Toggle
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.white,
                onPressed: () {
                  _playSound(_clickPlayer);
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Modals Overlay (Compact Popup)
            if (_showSummary || _showSuccessAll)
              Positioned(
                left: (_dialogPos ?? dialogInitialPos).dx,
                top: (_dialogPos ?? dialogInitialPos).dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _dialogPos =
                          (_dialogPos ?? dialogInitialPos) + details.delta;
                    });
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 400, // Compact width
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _showSuccessAll
                                        ? Icons.emoji_events
                                        : Icons.verified,
                                    color:
                                        _showSuccessAll
                                            ? Colors.amber
                                            : Colors.blueAccent,
                                    size: 56,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _showSuccessAll
                                        ? t('allCompletedTitle')
                                        : t('missionComplete'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _showSuccessAll
                                        ? t('allCompletedText')
                                        : _currentSummary,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      _playSound(_clickPlayer);
                                      if (_showSuccessAll) {
                                        _masterReset();
                                      } else {
                                        setState(() {
                                          _showSummary = false;
                                          _dialogPos = null;
                                        });
                                        if (_activeScenario < 5) {
                                          _loadScenario(_activeScenario + 1);
                                        }
                                      }
                                    },
                                    child: Text(
                                      _showSuccessAll
                                          ? t('restartLab')
                                          : t('continue'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                              ),
                              onPressed: () {
                                _playSound(_clickPlayer);
                                setState(() {
                                  _showSummary = false;
                                  _showSuccessAll = false;
                                  _dialogPos = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Curtain Raiser (Shutter Screen matches HTML exactly)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutCubic,
              top: _curtainOpen ? -screenHeight : 0,
              bottom: _curtainOpen ? screenHeight : 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: _curtainOpen,
                child: Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade500,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.timeline,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t('appTitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.power_settings_new, size: 24),
                          label: Text(
                            t('enterLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            backgroundColor: Colors.blue.shade500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                            shadowColor: Colors.blue.withOpacity(0.5),
                          ),
                          onPressed: () {
                            _playSound(_shutterPlayer);
                            setState(() => _curtainOpen = true);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _popSound() => _playSound(_fxPlayer);
}

// ================= CUSTOM PAINTER =================

class _AnglesPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final Offset pan;
  final double s1TTilt;
  final double s1MTilt;
  final double s1TrainVal;
  final bool s1TrainRunning;
  final double s2MPrimeAngle;
  final bool s2ProActive;
  final bool s3AMeas;
  final bool s3BMeas;
  final double s3MTilt;
  final bool s4RulerDropped;
  final double s4RulerX;
  final double s4RulerY;
  final double s4P1X;
  final double s4TAngle;
  final bool s4P1Done;
  final bool s4P2Done;
  final bool s4TransDrawn;
  final bool s4Measured;
  final double s4MTilt;
  final bool s4Checking;
  final String? activeDrag;
  final bool s5MDropped;
  final bool s5NDropped;
  final double s5MY;
  final double s5NY;
  final double s5MTilt;
  final double s5NTilt;
  final bool s5Checking;
  final double s5CarsVal;
  final bool s5CarsRunning;

  _AnglesPainter({
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.pan,
    required this.s1TTilt,
    required this.s1MTilt,
    required this.s1TrainVal,
    required this.s1TrainRunning,
    required this.s2MPrimeAngle,
    required this.s2ProActive,
    required this.s3AMeas,
    required this.s3BMeas,
    required this.s3MTilt,
    required this.s4RulerDropped,
    required this.s4RulerX,
    required this.s4RulerY,
    required this.s4P1X,
    required this.s4TAngle,
    required this.s4P1Done,
    required this.s4P2Done,
    required this.s4TransDrawn,
    required this.s4Measured,
    required this.s4MTilt,
    required this.s4Checking,
    required this.activeDrag,
    required this.s5MDropped,
    required this.s5NDropped,
    required this.s5MY,
    required this.s5NY,
    required this.s5MTilt,
    required this.s5NTilt,
    required this.s5Checking,
    required this.s5CarsVal,
    required this.s5CarsRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = math.min(size.width / 1000, size.height / 1000) * zoom;

    canvas.translate(center.dx + pan.dx, center.dy + pan.dy);
    canvas.scale(scale);

    _drawGrid(canvas);

    if (scenario == 1) {
      _drawScenario1(canvas);
    } else if (scenario == 2) {
      _drawScenario2(canvas);
    } else if (scenario == 3) {
      _drawScenario3(canvas);
    } else if (scenario == 4) {
      _drawScenario4(canvas);
    } else if (scenario == 5) {
      _drawScenario5(canvas);
    } // Removed redundant scenario checks
  }

  void _drawGrid(Canvas canvas) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (double i = -1000; i <= 1000; i += 50) {
      canvas.drawLine(Offset(i, -1000), Offset(i, 1000), paint);
      canvas.drawLine(Offset(-1000, i), Offset(1000, i), paint);
    }
  }

  void _drawTrackSegment(Canvas canvas) {
    canvas.drawLine(
      const Offset(-1200, 0),
      const Offset(1200, 0),
      Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 24
        ..style = PaintingStyle.stroke,
    );
    _drawDashedLine(
      canvas,
      const Offset(-1200, 0),
      const Offset(1200, 0),
      const Color(0xFF1E293B),
      24,
      dash: 10,
      space: 30,
    );
    canvas.drawLine(
      const Offset(-1200, -10),
      const Offset(1200, -10),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 4,
    );
    canvas.drawLine(
      const Offset(-1200, 10),
      const Offset(1200, 10),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 4,
    );
  }

  void _drawRoadSegment(Canvas canvas) {
    canvas.drawLine(
      const Offset(-1200, 0),
      const Offset(1200, 0),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 40
        ..strokeCap = StrokeCap.square,
    );
    _drawDashedLine(
      canvas,
      const Offset(-1200, 0),
      const Offset(1200, 0),
      Colors.white,
      2,
      dash: 15,
      space: 15,
    );
  }

  void _drawShelfSegment(Canvas canvas) {
    canvas.drawLine(
      const Offset(-800, 0),
      const Offset(800, 0),
      Paint()
        ..color = const Color(0xFFB45309)
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.square,
    );
    canvas.drawCircle(
      const Offset(-400, 0),
      14,
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawCircle(
      const Offset(400, 0),
      14,
      Paint()..color = const Color(0xFF94A3B8),
    );
  }

  void _drawTrain(Canvas canvas) {
    canvas.save();
    canvas.scale(0.9);
    canvas.translate(-40, -25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(0, 0, 100, 40),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF0284C7),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(0, 0, 100, 40),
        const Radius.circular(6),
      ),
      Paint()
        ..color = const Color(0xFF0C4A6E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawRect(
      const Rect.fromLTRB(75, -15, 95, 0),
      Paint()..color = const Color(0xFF475569),
    );
    canvas.drawRect(
      const Rect.fromLTRB(10, 5, 35, 20),
      Paint()..color = const Color(0xFFBAE6FD),
    );
    canvas.drawRect(
      const Rect.fromLTRB(45, 5, 70, 20),
      Paint()..color = const Color(0xFFBAE6FD),
    );
    for (double cx in [20, 50, 80]) {
      canvas.drawCircle(
        Offset(cx, 40),
        12,
        Paint()..color = const Color(0xFF334155),
      );
      canvas.drawCircle(
        Offset(cx, 40),
        12,
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    canvas.restore();
  }

  void _drawProtractorMesh(Canvas canvas) {
    Path p =
        Path()
          ..moveTo(-150, 0)
          ..arcTo(
            const Rect.fromLTRB(-150, -150, 150, 150),
            math.pi,
            math.pi,
            false,
          )
          ..close();
    canvas.drawPath(p, Paint()..color = Colors.blueAccent.withOpacity(0.1));
    canvas.drawPath(
      p,
      Paint()
        ..color = Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      const Offset(-160, 0),
      const Offset(160, 0),
      Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 3,
    );
    canvas.drawCircle(const Offset(0, 0), 6, Paint()..color = Colors.redAccent);
    canvas.drawLine(
      const Offset(-140, 0),
      const Offset(-150, 0),
      Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(140, 0),
      const Offset(150, 0),
      Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(0, -140),
      const Offset(0, -150),
      Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(-106, -106),
      const Offset(-100, -100),
      Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(106, -106),
      const Offset(100, -100),
      Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 2,
    );
  }

  void _drawSpiritLevel(Canvas canvas) {
    canvas.save();
    canvas.scale(0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-100, -20, 100, 20),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.amber,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-100, -20, 100, 20),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Colors.amber[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-40, -12, 40, 12),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-20, -12, 20, 12),
      Paint()..color = const Color(0xFFA3E635).withOpacity(0.8),
    );
    canvas.drawLine(
      const Offset(-10, -12),
      const Offset(-10, 12),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(10, -12),
      const Offset(10, 12),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 2,
    );
    // Bubble
    double bubbleX = (s4MTilt.abs() < 3) ? 0 : 25;
    canvas.drawCircle(Offset(bubbleX, 0), 8, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(bubbleX, 0),
      8,
      Paint()
        ..color = Colors.blueGrey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  void _drawCar(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-30, -15, 30, 15),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.redAccent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-30, -15, 30, 15),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Colors.red[900]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-15, -12, 15, 12),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-5, -10, 5, 10),
      Paint()..color = Colors.redAccent,
    );
    canvas.drawCircle(const Offset(20, -10), 4, Paint()..color = Colors.amber);
    canvas.drawCircle(const Offset(20, 10), 4, Paint()..color = Colors.amber);
  }

  void _drawScenario1(Canvas canvas) {
    double tRad = s1TTilt * math.pi / 180;
    double tanT = math.tan(tRad) == 0 ? 0.0001 : math.tan(tRad);
    double p1x = -150 / tanT;
    double p2x = 150 / tanT;
    double tDx = 1000 * math.cos(tRad);
    double tDy = 1000 * math.sin(tRad);

    canvas.drawLine(
      Offset(-tDx, -tDy),
      Offset(tDx, tDy),
      Paint()
        ..color = Colors.amber.withOpacity(0.15)
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(-tDx, -tDy),
      Offset(tDx, tDy),
      Paint()
        ..color = Colors.amber.withOpacity(0.4)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(-tDx, -tDy),
      Offset(tDx, tDy),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    _drawText(
      canvas,
      "t",
      Offset(-tDx * 0.4 - 20, -tDy * 0.4 - 20),
      fontSize: 28,
      color: Colors.white70,
    );

    // Track L
    canvas.save();
    canvas.translate(0, -150);
    _drawTrackSegment(canvas);
    canvas.restore();
    _drawText(
      canvas,
      "Line l",
      const Offset(-400, -175),
      fontSize: 28,
      color: const Color(0xFFCBD5E1),
    );

    // Track M
    canvas.save();
    canvas.translate(p2x, 150);
    canvas.rotate(s1MTilt * math.pi / 180);
    canvas.translate(-p2x, -150);
    canvas.translate(0, 150);
    _drawTrackSegment(canvas);
    canvas.restore();
    _drawText(
      canvas,
      "Line m",
      const Offset(-400, 125),
      fontSize: 28,
      color: const Color(0xFFCBD5E1),
    );

    bool isParallel = s1MTilt.abs() < 1;
    if (isParallel) {
      canvas.drawLine(
        const Offset(-1200, -150),
        const Offset(1200, -150),
        Paint()
          ..color = Colors.blueAccent.withOpacity(0.4)
          ..strokeWidth = 12,
      );
      canvas.save();
      canvas.translate(p2x, 150);
      canvas.rotate(s1MTilt * math.pi / 180);
      canvas.translate(-p2x, -150);
      canvas.drawLine(
        const Offset(-1200, 150),
        const Offset(1200, 150),
        Paint()
          ..color = Colors.blueAccent.withOpacity(0.4)
          ..strokeWidth = 12,
      );
      canvas.restore();
    }

    if (step <= 1) {
      canvas.save();
      canvas.translate(p2x + 300, 150);
      _drawHandle(canvas, const Offset(0, 0), Colors.blueAccent);
      canvas.restore();
    }
    if (step == 2) {
      double hX = 350 * math.cos(tRad);
      double hY = 350 * math.sin(tRad);
      canvas.save();
      canvas.translate(hX, hY);
      _drawHandle(canvas, const Offset(0, 0), Colors.amber);
      canvas.restore();
    }

    double angAStart = s1TTilt;
    double angAEnd = 360;
    if (angAStart > 360) angAStart -= 360;
    _drawAngleArc(
      canvas,
      Offset(p1x, -150),
      80,
      angAStart * math.pi / 180,
      (angAEnd - angAStart) * math.pi / 180,
      Colors.blueAccent,
      "${(angAEnd - angAStart).round()}°",
      label: "∠a",
    );

    double angBStart = s1TTilt;
    double angBEnd = 360 + s1MTilt;
    _drawAngleArc(
      canvas,
      Offset(p2x, 150),
      80,
      angBStart * math.pi / 180,
      (angBEnd - angBStart) * math.pi / 180,
      isParallel ? Colors.blueAccent : Colors.redAccent,
      "${(angBEnd - angBStart).abs().round()}°",
      label: "∠b",
    );

    if (s1TrainRunning) {
      double p = s1TrainVal;
      double cx = -800 + 1600 * p;
      canvas.save();
      canvas.translate(cx, -150 - 20);
      _drawTrain(canvas);
      canvas.restore();
      canvas.save();
      canvas.translate(p2x, 150);
      canvas.rotate(s1MTilt * math.pi / 180);
      canvas.translate(-p2x, -150);
      canvas.translate(cx, 150 - 20);
      _drawTrain(canvas);
      canvas.restore();
    }
  }

  void _drawScenario2(Canvas canvas) {
    double tRad = 300 * math.pi / 180;
    double tanT = math.tan(tRad);
    double p1x = -150 / tanT;
    double p2x = 150 / tanT;
    double tDx = 800 * math.cos(tRad);
    double tDy = 800 * math.sin(tRad);

    canvas.drawLine(
      Offset(-tDx, -tDy),
      Offset(tDx, tDy),
      Paint()
        ..color = Colors.amber.withOpacity(0.15)
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(-tDx, -tDy),
      Offset(tDx, tDy),
      Paint()
        ..color = Colors.amber.withOpacity(0.4)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(-tDx, -tDy),
      Offset(tDx, tDy),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    _drawText(
      canvas,
      "t",
      const Offset(-150, -300),
      fontSize: 28,
      color: Colors.white70,
    );

    // Line L (Red)
    canvas.drawLine(
      const Offset(-1200, -150),
      const Offset(1200, -150),
      Paint()
        ..color = Colors.redAccent.withOpacity(0.4)
        ..strokeWidth = 12,
    );
    canvas.drawLine(
      const Offset(-1200, -150),
      const Offset(1200, -150),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
    _drawText(
      canvas,
      "Line l",
      const Offset(-400, -170),
      fontSize: 28,
      color: Colors.white70,
    );

    // Line M target (Gray)
    canvas.drawLine(
      const Offset(-1200, 150),
      const Offset(1200, 150),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 6,
    );
    _drawText(
      canvas,
      "Line m",
      const Offset(-400, 130),
      fontSize: 28,
      color: Colors.white54,
    );

    // Line M' (Blue Rotatable)
    canvas.save();
    canvas.translate(p2x, 150);
    canvas.rotate(s2MPrimeAngle * math.pi / 180);
    canvas.translate(-p2x, -150);
    canvas.drawLine(
      const Offset(-1200, 150),
      const Offset(1200, 150),
      Paint()
        ..color = Colors.blueAccent.withOpacity(0.5)
        ..strokeWidth = 12,
    );
    canvas.drawLine(
      const Offset(-1200, 150),
      const Offset(1200, 150),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
    _drawText(
      canvas,
      "m'",
      const Offset(400, 130),
      fontSize: 28,
      color: Colors.white70,
    );
    canvas.restore();

    _drawAngleArc(
      canvas,
      Offset(p1x, -150),
      80,
      300 * math.pi / 180,
      60 * math.pi / 180,
      Colors.redAccent,
      "60°",
      label: "∠a",
    );

    double dispAng = 60 + s2MPrimeAngle;
    _drawAngleArc(
      canvas,
      Offset(p2x, 150),
      80,
      300 * math.pi / 180,
      (60 + s2MPrimeAngle) * math.pi / 180,
      (dispAng.round() == 60) ? Colors.redAccent : Colors.blueAccent,
      step == 0 ? "?" : "${dispAng.round().abs()}°",
      label: "∠b",
    );

    if (s2ProActive && step <= 1) {
      canvas.save();
      canvas.translate(p2x, 150);
      _drawProtractorMesh(canvas);
      canvas.save();
      canvas.rotate(s2MPrimeAngle * math.pi / 180);
      canvas.translate(150, 0);
      canvas.rotate(-s2MPrimeAngle * math.pi / 180);
      _drawHandle(canvas, const Offset(0, 0), Colors.blueAccent);
      canvas.restore();
      _drawText(
        canvas,
        "${dispAng.round().abs()}°",
        const Offset(0, -50),
        color: Colors.blueAccent,
        fontSize: 28,
        center: true,
      );
      canvas.restore();
    }
  }

  Offset _polarToCartesian(double cx, double cy, double r, double angleDeg) {
    return Offset(
      cx + r * math.cos(angleDeg * math.pi / 180),
      cy + r * math.sin(angleDeg * math.pi / 180),
    );
  }

  void _drawScenario3(Canvas canvas) {
    double tRad = 300 * math.pi / 180;
    double tanT = math.tan(tRad);
    double p1x = -150 / tanT;
    double p2x = 150 / tanT;

    canvas.save();
    canvas.rotate(-60 * math.pi / 180);
    _drawRoadSegment(canvas);
    canvas.restore();
    _drawText(
      canvas,
      "t",
      const Offset(190, -320),
      fontSize: 28,
      color: Colors.white70,
    );

    canvas.save();
    canvas.translate(0, -150);
    _drawRoadSegment(canvas);
    canvas.restore();
    _drawText(
      canvas,
      "Road l",
      const Offset(-400, -180),
      fontSize: 28,
      color: const Color(0xFFCBD5E1),
    );

    canvas.save();
    canvas.translate(p2x, 150);
    canvas.rotate(s3MTilt * math.pi / 180);
    canvas.translate(-p2x, -150);
    canvas.translate(0, 150);
    _drawRoadSegment(canvas);
    canvas.restore();
    _drawText(
      canvas,
      "Road m",
      const Offset(-400, 120),
      fontSize: 28,
      color: const Color(0xFFCBD5E1),
    );

    if (s3AMeas) {
      _drawAngleArc(
        canvas,
        Offset(p1x, -150),
        80,
        300 * math.pi / 180,
        60 * math.pi / 180,
        Colors.redAccent,
        "60°",
        label: "∠a",
      );
    } else {
      _drawAngleArc(
        canvas,
        Offset(p1x, -150),
        80,
        300 * math.pi / 180,
        60 * math.pi / 180,
        Colors.redAccent.withOpacity(0.2),
        "",
        label: "∠a",
      );
      canvas.drawCircle(
        Offset(p1x, -150),
        100,
        Paint()
          ..color = Colors.white10
          ..style = PaintingStyle.fill,
      );
    }

    if (s3BMeas) {
      _drawAngleArc(
        canvas,
        Offset(p2x, 150),
        80,
        300 * math.pi / 180,
        (60 + s3MTilt) * math.pi / 180,
        s3MTilt.abs() < 1 ? Colors.redAccent : Colors.blueAccent,
        "${(60 + s3MTilt).round()}°",
        label: "∠b",
      );
      if (step == 1 && s3AMeas && s3BMeas) {
        double midAngle = (300 + 360 + s3MTilt) / 2;
        Offset bgMid = _polarToCartesian(p2x, 150, 48, midAngle);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: bgMid, width: 60, height: 40),
            const Radius.circular(8),
          ),
          Paint()..color = Colors.amber.withOpacity(0.4),
        );
      }
    } else {
      _drawAngleArc(
        canvas,
        Offset(p2x, 150),
        80,
        300 * math.pi / 180,
        (60 + s3MTilt) * math.pi / 180,
        Colors.blueAccent.withOpacity(0.2),
        "",
        label: "∠b",
      );
      canvas.drawCircle(
        Offset(p2x, 150),
        100,
        Paint()
          ..color = Colors.white10
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawScenario4(Canvas canvas) {
    if (step == 0 && s4RulerDropped && !s4P1Done) {
      _drawText(
        canvas,
        "Click anywhere on Shelf L to start line",
        const Offset(-150, 50),
        color: Colors.amber,
        center: true,
        fontSize: 20,
      );
    } else if (step == 0 && s4P1Done && !s4P2Done) {
      _drawText(
        canvas,
        "Click Point A to complete line",
        const Offset(-150, 50),
        color: Colors.amber,
        center: true,
        fontSize: 20,
      );
    }

    canvas.save();
    canvas.translate(0, 150 - 12);
    _drawShelfSegment(canvas);
    canvas.restore();
    _drawText(
      canvas,
      "Shelf l",
      const Offset(-350, 190),
      fontSize: 28,
      color: const Color(0xFFCBD5E1),
    );

    if (s4P1Done) {
      canvas.drawCircle(
        Offset(s4P1X, 150),
        10,
        Paint()..color = Colors.blueAccent,
      );
    }
    if (step == 0 && s4RulerDropped && !s4P1Done) {
      canvas.drawRect(
        const Rect.fromLTRB(-450, 120, -50, 180),
        Paint()..color = Colors.amber.withOpacity(0.2),
      );
    }

    canvas.save();
    canvas.translate(100, -100);
    canvas.drawCircle(const Offset(0, 0), 6, Paint()..color = Colors.white);
    _drawText(
      canvas,
      "Point A",
      const Offset(15, -15),
      fontSize: 20,
      color: Colors.white,
    );
    if (step == 0 && s4P1Done && !s4P2Done) {
      canvas.drawCircle(
        const Offset(0, 0),
        30,
        Paint()..color = Colors.amber.withOpacity(0.4),
      );
    }
    canvas.restore();

    if (s4TransDrawn) {
      double angleRad = math.atan2(-250, 100 - s4P1X);
      double extDx = 500 * math.cos(angleRad);
      double extDy = 500 * math.sin(angleRad);
      canvas.drawLine(
        Offset(s4P1X - extDx, 150 - extDy),
        Offset(100 + extDx, -100 + extDy),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );
      _drawDashedLine(
        canvas,
        Offset(s4P1X - extDx, 150 - extDy),
        Offset(100 + extDx, -100 + extDy),
        Colors.white,
        4,
        space: 8,
        dash: 8,
      );
      _drawText(
        canvas,
        "t",
        Offset(100 + extDx * 0.5, -100 + extDy * 0.5 - 20),
        fontSize: 28,
        color: Colors.white70,
      );
    }

    if (s4Measured) {
      _drawAngleArc(
        canvas,
        Offset(s4P1X, 150),
        80,
        (360 - s4TAngle) * math.pi / 180,
        s4TAngle * math.pi / 180,
        Colors.amber,
        "${s4TAngle.round()}°",
      );
    }

    if (step >= 2) {
      canvas.save();
      canvas.translate(100, -100);
      canvas.rotate(s4MTilt * math.pi / 180);
      canvas.translate(0, -12);
      _drawShelfSegment(canvas);
      canvas.translate(0, 12);
      _drawText(
        canvas,
        "Shelf m",
        const Offset(-350, 40),
        fontSize: 28,
        color: const Color(0xFFCBD5E1),
      );
      _drawHandle(canvas, const Offset(300, 0), Colors.blueAccent);

      canvas.save();
      canvas.translate(0, -30);
      _drawSpiritLevel(canvas);
      canvas.restore();
      canvas.restore();

      double bStart = 360 - s4TAngle;
      double bEnd = 360 + s4MTilt;
      if (bEnd < bStart) {
        double t = bStart;
        bStart = bEnd;
        bEnd = t;
      }
      _drawAngleArc(
        canvas,
        const Offset(100, -100),
        80,
        bStart * math.pi / 180,
        (bEnd - bStart) * math.pi / 180,
        Colors.blueAccent,
        "${(bEnd - bStart).abs().round()}°",
      );
    }

    // Toolbox Area
    if (step <= 1) {
      canvas.save();
      canvas.translate(-400, -350);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(0, 0, 160, 200),
          const Radius.circular(12),
        ),
        Paint()
          ..color = const Color(0xFF1E293B).withOpacity(0.9)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(0, 0, 160, 200),
          const Radius.circular(12),
        ),
        Paint()
          ..color = const Color(0xFF475569)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        "TOOLBOX",
        const Offset(80, 30),
        color: const Color(0xFF94A3B8),
        fontSize: 14,
        center: true,
      );

      if (!s4RulerDropped) {
        canvas.save();
        canvas.translate(80, 80);
        _drawGhostRuler(canvas, 1.0);
        canvas.restore();
      }
      if (!s4Measured) {
        canvas.save();
        canvas.translate(80, 150);
        canvas.scale(0.5);
        _drawProtractorMesh(canvas);
        canvas.restore();
        _drawText(
          canvas,
          "PROTRACTOR",
          const Offset(80, 160),
          color: Colors.blue[300]!,
          fontSize: 12,
          center: true,
        );
      }
      canvas.restore();
    }

    if (activeDrag == 's4_ruler') {
      canvas.save();
      canvas.translate(s4RulerX, s4RulerY);
      canvas.rotate(-45 * math.pi / 180);
      _drawGhostRuler(canvas, 0.8);
      canvas.restore();
    }
    if (activeDrag == 's4_protractor') {
      canvas.save();
      canvas.translate(s4RulerX, s4RulerY);
      canvas.scale(0.6);
      _drawProtractorMesh(canvas);
      canvas.restore();
    }

    if (s4Measured && step == 1) {
      canvas.save();
      canvas.translate(s4P1X, 150);
      canvas.scale(0.8);
      _drawProtractorMesh(canvas);
      canvas.restore();
    } else if (step >= 2) {
      canvas.save();
      canvas.translate(100, -100);
      canvas.scale(0.8);
      _drawProtractorMesh(canvas);
      canvas.restore();
    }
  }

  void _drawGhostRuler(Canvas canvas, double op) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-60, -15, 60, 15),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.amber.withOpacity(op),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-60, -15, 60, 15),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.amber[900]!.withOpacity(op)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (int i = -50; i <= 50; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), -15),
        Offset(i.toDouble(), -5),
        Paint()
          ..color = Colors.amber[900]!.withOpacity(op)
          ..strokeWidth = 2,
      );
    }
  }

  void _drawScenario5(Canvas canvas) {
    double tRad = -65 * math.pi / 180;
    double tanT = math.tan(tRad);

    canvas.save();
    canvas.rotate(tRad);
    _drawRoadSegment(canvas);
    canvas.restore();
    _drawText(
      canvas,
      "Maple Dr",
      const Offset(200, -450),
      fontSize: 28,
      color: Colors.white70,
    );

    canvas.save();
    canvas.translate(0, -150);
    _drawRoadSegment(canvas);
    canvas.restore();
    _drawText(
      canvas,
      "Central Ave",
      const Offset(-350, -180),
      fontSize: 28,
      color: const Color(0xFFCBD5E1),
    );

    double p1x = -150 / tanT;
    _drawAngleArc(
      canvas,
      Offset(p1x, -150),
      80,
      180 * math.pi / 180,
      115 * math.pi / 180,
      Colors.redAccent,
      "115°",
    );

    if (step <= 1 || !s5NDropped) {
      canvas.save();
      canvas.translate(-400, -350);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(0, 0, 160, 200),
          const Radius.circular(12),
        ),
        Paint()
          ..color = const Color(0xFF1E293B).withOpacity(0.9)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(0, 0, 160, 200),
          const Radius.circular(12),
        ),
        Paint()
          ..color = const Color(0xFF475569)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        "ROADS",
        const Offset(80, 30),
        color: const Color(0xFF94A3B8),
        fontSize: 14,
        center: true,
      );

      if (!s5MDropped) {
        canvas.save();
        canvas.translate(80, 80);
        canvas.scale(0.3);
        _drawRoadSegment(canvas);
        canvas.restore();
        _drawText(
          canvas,
          "First St.",
          const Offset(80, 65),
          fontSize: 12,
          center: true,
        );
      }
      if (!s5NDropped) {
        canvas.save();
        canvas.translate(80, 150);
        canvas.scale(0.3);
        _drawRoadSegment(canvas);
        canvas.restore();
        _drawText(
          canvas,
          "Second St.",
          const Offset(80, 135),
          fontSize: 12,
          center: true,
        );
      }
      canvas.restore();
    }

    if (activeDrag == 's5_tool_m') {
      canvas.save();
      canvas.translate(s4RulerX, s4RulerY);
      canvas.scale(0.5);
      _drawRoadSegment(canvas);
      canvas.restore();
    }
    if (activeDrag == 's5_tool_n') {
      canvas.save();
      canvas.translate(s4RulerX, s4RulerY);
      canvas.scale(0.5);
      _drawRoadSegment(canvas);
      canvas.restore();
    }

    if (s5MDropped) {
      double pmX = s5MY / tanT;
      canvas.save();
      canvas.translate(pmX, s5MY);
      canvas.rotate(s5MTilt * math.pi / 180);
      canvas.translate(-pmX, 0);
      if (s5Checking && s5MTilt.abs() >= 3) {
        canvas.drawLine(
          const Offset(-1200, 0),
          const Offset(1200, 0),
          Paint()
            ..color = Colors.redAccent.withOpacity(0.5)
            ..strokeWidth = 40,
        );
      }
      _drawRoadSegment(canvas);
      _drawText(
        canvas,
        "First St.",
        const Offset(-350, -30),
        fontSize: 28,
        color: const Color(0xFFCBD5E1),
      );

      if (!s5CarsRunning && !s5Checking) {
        if (step == 1) {
          _drawHandle(canvas, const Offset(350, 0), Colors.blueAccent);
        }
        _drawHandle(canvas, const Offset(-200, 0), Colors.amber);
      }
      canvas.restore();

      double mAngleStart = 180 + s5MTilt;
      double mAngleEnd = 295;
      if (mAngleEnd < mAngleStart) {
        double t = mAngleStart;
        mAngleStart = mAngleEnd;
        mAngleEnd = t;
      }
      _drawAngleArc(
        canvas,
        Offset(pmX, s5MY),
        80,
        mAngleStart * math.pi / 180,
        (mAngleEnd - mAngleStart) * math.pi / 180,
        s5MTilt.abs() < 1 ? Colors.green : Colors.blueAccent,
        "${(295 - (180 + s5MTilt)).abs().round()}°",
      );
    }

    if (s5NDropped) {
      double pnX = s5NY / tanT;
      canvas.save();
      canvas.translate(pnX, s5NY);
      canvas.rotate(s5NTilt * math.pi / 180);
      canvas.translate(-pnX, 0);
      if (s5Checking && s5NTilt.abs() >= 3) {
        canvas.drawLine(
          const Offset(-1200, 0),
          const Offset(1200, 0),
          Paint()
            ..color = Colors.redAccent.withOpacity(0.5)
            ..strokeWidth = 40,
        );
      }
      _drawRoadSegment(canvas);
      _drawText(
        canvas,
        "Second St.",
        const Offset(-350, -30),
        fontSize: 28,
        color: const Color(0xFFCBD5E1),
      );

      if (!s5CarsRunning && !s5Checking) {
        _drawHandle(canvas, const Offset(350, 0), Colors.blueAccent);
        _drawHandle(canvas, const Offset(-200, 0), Colors.amber);
      }
      canvas.restore();

      double nAngleStart = 180 + s5NTilt;
      double nAngleEnd = 295;
      if (nAngleEnd < nAngleStart) {
        double t = nAngleStart;
        nAngleStart = nAngleEnd;
        nAngleEnd = t;
      }
      _drawAngleArc(
        canvas,
        Offset(pnX, s5NY),
        80,
        nAngleStart * math.pi / 180,
        (nAngleEnd - nAngleStart) * math.pi / 180,
        s5NTilt.abs() < 1 ? Colors.green : Colors.blueAccent,
        "${(295 - (180 + s5NTilt)).abs().round()}°",
      );
    }

    if (s5CarsRunning) {
      double p = s5CarsVal;
      double cx = -1200 + 2400 * p;
      canvas.save();
      canvas.translate(cx, -150);
      canvas.scale(0.8);
      _drawCar(canvas);
      canvas.restore();
      canvas.save();
      canvas.translate(cx, s5MY);
      canvas.scale(0.8);
      _drawCar(canvas);
      canvas.restore();
      canvas.save();
      canvas.translate(cx, s5NY);
      canvas.scale(0.8);
      _drawCar(canvas);
      canvas.restore();
    }
  }

  void _drawAngleArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngleRad,
    double sweepAngleRad,
    Color color,
    String text, {
    String? label,
  }) {
    Paint fill =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill;
    Paint stroke =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    Rect rect = Rect.fromCircle(center: center, radius: radius);
    Path arcPath =
        Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(rect, startAngleRad, sweepAngleRad, false)
          ..close();

    canvas.drawPath(arcPath, fill);
    canvas.drawPath(arcPath, stroke);

    double midAngle = startAngleRad + sweepAngleRad / 2;
    double tx = center.dx + (radius * 0.65) * math.cos(midAngle);
    double ty = center.dy + (radius * 0.65) * math.sin(midAngle);

    _drawText(
      canvas,
      text,
      Offset(tx, ty),
      center: true,
      color: Colors.white,
      fontSize: 20,
    );
    if (label != null) {
      _drawText(
        canvas,
        label,
        Offset(tx + 30, ty - 15),
        center: true,
        color: color.withOpacity(0.8),
        fontSize: 16,
      );
    }
  }

  void _drawHandle(Canvas canvas, Offset pos, Color color) {
    canvas.drawCircle(pos, 18, Paint()..color = color);
    canvas.drawCircle(
      pos,
      18,
      Paint()
        ..color = color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    Paint whiteP =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: pos, radius: 10),
      math.pi / 4,
      1.5 * math.pi,
      false,
      whiteP,
    );
    canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double width, {
    double dash = 10,
    double space = 10,
  }) {
    Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = width;
    double dist = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / dist;
    double dy = (p2.dy - p1.dy) / dist;
    for (double i = 0; i < dist; i += (dash + space)) {
      canvas.drawLine(
        Offset(p1.dx + dx * i, p1.dy + dy * i),
        Offset(p1.dx + dx * (i + dash), p1.dy + dy * (i + dash)),
        paint,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool center = false,
    Color color = Colors.white,
    double fontSize = 20,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    if (center) {
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    } else {
      textPainter.paint(canvas, pos);
    }
  }

  @override
  bool shouldRepaint(covariant _AnglesPainter oldDelegate) => true;
}
