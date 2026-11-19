// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LaserGridApp());
}

class LaserGridApp extends StatelessWidget {
  const LaserGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | The Laser Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: Colors.blueAccent,
      ),
      home: const LaserGridLab(),
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

class LaserGridLab extends StatefulWidget {
  const LaserGridLab({super.key});

  @override
  State<LaserGridLab> createState() => _LaserGridLabState();
}

class _LaserGridLabState extends State<LaserGridLab>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _curtainOpen = false;
  int _activeScenario = 1;
  int _activeStep = 0;
  bool _actionValidated = false;

  // Language & Theme State
  int _langIdx = 0;
  final List<String> _languages = ['en', 'hi'];
  double _fontSize = 13.0; // Base font size for sidebar text

  // Geometric state
  double _tTilt = 225.0;
  double _mTilt = 0.0;

  // Interaction tracking
  bool _s1Clicked = false;
  bool _s1Unaligned = false;
  bool _s2Clicked = false;
  bool _s2TMoved = false;
  bool _s2Unaligned = false;
  bool _s3Clicked = false;
  bool _s3Unaligned = false;
  bool _s3Animating = false;

  // Scenario 4 (Bridge)
  double _s4BX = -350.0;
  double _s4BY = 200.0;
  bool _s4BSnapped = false;
  double _s4BAngle = 0.0;

  // Scenario 5 (Periscope)
  double _s5M1X = -100.0;
  double _s5M1Y = 290.0;
  bool _s5M1Snapped = false;
  double _s5M1Angle = 90.0;
  double _s5M2X = 100.0;
  double _s5M2Y = 290.0;
  bool _s5M2Snapped = false;
  double _s5M2Angle = 90.0;
  bool _s5ShowView = false;
  bool _s5IsAligned = false;

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
  late AnimationController _s3AnimController;
  late AnimationController _s4AnimController;

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
      'appTitle': 'The Laser Grid: Mastering Transversals',
      'appSubtitle': 'Class 7 • PARALLEL AND INTERSECTING LINES',
      'enterLab': 'Activate Grid',
      'toggleLang': 'Toggle Language',
      'resetLab': 'Master Reset',
      'selectScenario': 'Select Mission',
      'theory': 'Mission Briefing',
      'missionObj': 'Objective:',
      'procSteps': 'Operations',
      'stepLabel': 'STEP',
      'labSummary': 'Mission Report',
      'missionComplete': 'Mission Completed!',
      'selectAnotherScenario': 'You have successfully verified this property.',
      'allCompletedTitle': 'Master of the Grid!',
      'allCompletedText':
          'You have successfully mastered all geometric properties of the laser grid!',
      'restartLab': 'Restart System',
      'continue': 'CONTINUE',
      'combine': 'COMBINE',
      'lockBridge': 'LOCK BRIDGE',
      'view': 'VIEW',
      'scen1Title': '1. The Corresponding Color Match',
      's1Obj':
          'To visually discover that corresponding angles are equal if and only if the lines are parallel.',
      's1_1_hud': 'CLICK on the top-left angle (∠1) at the top intersection.',
      's1_1_txt':
          'Observe the setup. You see two horizontal laser lines, Line L and Line M, intersected by Transversal T. They are perfectly parallel. CLICK on the top-left angle (∠1) to measure it.',
      's1_2_hud': 'DRAG the handle on Line M to rotate it out of parallel.',
      's1_2_txt':
          'DRAG the handle on Line M to rotate it and make it non-parallel to Line L. Watch the angle colors and values.',
      's1_3_hud': 'DRAG Line M back until the angles match perfectly in blue.',
      's1_3_txt':
          'Your mission is to make the angles match again! DRAG the handle on Line M back until its angle color matches Line L\'s perfectly.',
      's1_sum':
          'MATCH! You have discovered that corresponding angles are absolutely equal when lines are parallel.\n\nParallel Lines ↔ Equal Corresponding Angles',
      'scen2Title': '2. The Alternate Angle Aligner',
      's2Obj':
          'To understand that alternate interior angles are equal if and only if the lines are parallel.',
      's2_1_hud': 'CLICK on the bottom-left interior angle.',
      's2_1_txt':
          'Observe the parallel laser lines Line L and Line M with the Transversal T. CLICK on the bottom-left interior angle (∠3).',
      's2_2_hud': 'DRAG the handle on Transversal T to change its tilt.',
      's2_2_txt':
          'Now, let\'s test the transversal. DRAG the handle on Transversal T to change its angle of intersection. Do the alternate angles stay equal?',
      's2_3_hud': 'DRAG the handle on Line M to break the parallel state.',
      's2_3_txt':
          'Now, DRAG the handle on Line M to make it non-parallel and see what happens to the equality.',
      's2_4_hud': 'Align the lines! DRAG Line M back to parallel.',
      's2_4_txt':
          'Align the lines! DRAG Line M back to the parallel position to make the alternate interior angles match in color and value.',
      's2_sum':
          'Excellent work. You verified that Alternate Interior Angles behave perfectly just like corresponding angles.\n\nParallel Lines ↔ Equal Alternate Interior Angles',
      'scen3Title': '3. The 180° Angle Bank',
      's3Obj':
          'To demonstrate that consecutive interior angles are supplementary (add up to 180°) when lines are parallel.',
      's3_1_hud': 'CLICK on the bottom-left interior angle (∠3).',
      's3_1_txt':
          'The parallel lines are set up. CLICK on the bottom-left interior angle (∠3) to identify the consecutive interior pair.',
      's3_2_hud':
          'CLICK the "Combine" button to see if these angles fit together.',
      's3_2_txt':
          'Now you have identified the consecutive interior angles. CLICK the "Combine" button to extract them and see if they fit together.',
      's3_3_hud':
          'Break the parallel alignment! DRAG Line M, then CLICK "Combine".',
      's3_3_txt':
          'Now, let\'s break the parallel alignment. DRAG the handle on Line M. Then, CLICK the "Combine" button again.',
      's3_4_hud': 'Fix it! DRAG Line M back to parallel, then CLICK "Combine".',
      's3_4_txt':
          'Fix it! DRAG Line M back to the parallel position so that the two angles perfectly add up to 180° again. CLICK "Combine" to confirm.',
      's3_sum':
          'Perfect Fit! Interior angles on the same side add up to 180° when lines are parallel. They form a perfect straight line!\n\nParallel Lines ↔ Consecutive Interior Angles = 180°',
      'scen4Title': '4. The Bridge Alignment',
      's4Obj':
          'Apply the property of alternate interior angles to correctly align a bridge segment.',
      's4_1_hud': 'DRAG Segment B from the yard onto the central pillar.',
      's4_1_txt':
          'A bridge needs to be built across a river with parallel banks. The first segment (Segment A) is already placed. DRAG Segment B from the construction yard and DROP it onto the central pillar.',
      's4_2_hud': 'ROTATE Segment B until its angle matches Segment A (55°).',
      's4_2_txt':
          'Segment A forms a 55° angle. To align the bridge, Segment B must match this alternate interior angle. ROTATE Segment B until the colors match.',
      's4_3_hud': 'CLICK the "Lock Bridge" button to test the alignment.',
      's4_3_txt':
          'Once the angles match perfectly in green, CLICK the "Lock Bridge" button to test if cars can safely drive across.',
      's4_sum':
          'Bridge Complete! Excellent! You aligned the bridge perfectly using alternate interior angles.',
      'scen5Title': '5. The Periscope Challenge',
      's5Obj':
          'Apply the concept of parallel lines and alternate interior angles to construct a working periscope.',
      's5_1_hud':
          'DRAG the two mirrors into the empty slots inside the periscope.',
      's5_1_txt':
          'Here is a periscope tube. A light ray is entering from the top opening. Your goal is to guide this light ray to the eyepiece. DRAG the two mirrors from the toolbox and DROP them into the empty corner slots.',
      's5_2_hud':
          'ROTATE each mirror to perfectly align their Alternate Interior Angles.',
      's5_2_txt':
          'The light ray acts as a transversal. For the periscope to work, the mirrors must be mathematically parallel. ROTATE each mirror using their handles to perfectly align the Alternate Interior Angles.',
      's5_3_hud': 'Mirrors aligned! CLICK the Eyepiece to look through.',
      's5_3_txt':
          'The laser beam is perfectly aligned. When you think the mirrors are perfectly parallel, look through the eyepiece by CLICKING on it to confirm.',
      's5_sum':
          'Visual Confirmation! The alternate interior angles matched perfectly (45°), proving the mirrors are strictly parallel. The periscope works flawlessly.',
      'fb_success': 'System updated.',
      'fb_error': 'Alignment failure.',
      'fb_s4_snap': 'Segment connected. Now rotate to align.',
      'fb_s4_lock': 'Alignment locked. Safe passage confirmed!',
      'fb_s5_snap': 'Mirror engaged in slot.',
      'fb_s5_misaligned': 'Mirrors are not parallel. View obstructed.',
    },
    'hi': {
      'appTitle': 'लेजर ग्रिड: तिर्यक रेखाएँ',
      'appSubtitle': 'कक्षा 7 • समांतर और प्रतिच्छेदी रेखाएं',
      'enterLab': 'ग्रिड चालू करें',
      'toggleLang': 'भाषा बदलें',
      'resetLab': 'सिस्टम रीसेट',
      'selectScenario': 'मिशन चुनें',
      'theory': 'मिशन ब्रीफिंग',
      'missionObj': 'उद्देश्य:',
      'procSteps': 'संचालन',
      'stepLabel': 'चरण',
      'labSummary': 'मिशन रिपोर्ट',
      'missionComplete': 'मिशन पूरा हुआ!',
      'selectAnotherScenario':
          'आपने इस संपत्ति को सफलतापूर्वक सत्यापित कर लिया है।',
      'allCompletedTitle': 'ग्रिड मास्टर!',
      'allCompletedText':
          'आपने लेजर ग्रिड के सभी ज्यामितीय गुणों में महारत हासिल कर ली है!',
      'restartLab': 'सिस्टम रीस्टार्ट',
      'continue': 'जारी रखें',
      'combine': 'जोड़ें',
      'lockBridge': 'पुल लॉक करें',
      'view': 'देखें',
      'scen1Title': '1. संगत रंग मिलान',
      's1Obj':
          'यह देखने के लिए कि संगत कोण समान होते हैं यदि और केवल यदि रेखाएं समानांतर हों।',
      's1_1_hud': 'शीर्ष प्रतिच्छेदन पर शीर्ष-बाएँ कोण पर क्लिक करें।',
      's1_1_txt':
          'सेटअप का निरीक्षण करें। आप दो क्षैतिज लेजर रेखाएं देखते हैं। मापने के लिए शीर्ष-बाएँ कोण (∠1) पर CLICK करें।',
      's1_2_hud': 'Line M को घुमाने के लिए हैंडल खींचें।',
      's1_2_txt':
          'Line M को घुमाने और इसे गैर-समानांतर बनाने के लिए हैंडल को खींचें (DRAG)।',
      's1_3_hud': 'कोणों का मिलान करने के लिए Line M को वापस खींचें।',
      's1_3_txt':
          'आपका मिशन कोणों को फिर से मिलाना है! Line M के हैंडल को वापस खींचें।',
      's1_sum':
          'मिलान! जब रेखाएं समानांतर होती हैं तो संगत कोण बिल्कुल समान होते हैं।\n\nसमानांतर रेखाएं ↔ समान संगत कोण',
      'scen2Title': '2. एकांतर कोण संरेखक',
      's2Obj':
          'यह समझने के लिए कि एकांतर अंतः कोण समान होते हैं यदि और केवल यदि रेखाएं समानांतर हों।',
      's2_1_hud': 'नीचे-बाएँ अंतः कोण पर क्लिक करें।',
      's2_1_txt':
          'समानांतर लेजर लाइनों L और M का निरीक्षण करें। नीचे-बाएँ अंतः कोण (∠3) पर CLICK करें।',
      's2_2_hud': 'झुकाव बदलने के लिए Transversal T पर हैंडल खींचें।',
      's2_2_txt':
          'अब, तिर्यक रेखा का परीक्षण करें। Transversal T के हैंडल को खींचें। क्या एकांतर कोण समान रहते हैं?',
      's2_3_hud': 'समानांतर स्थिति को तोड़ने के लिए Line M पर हैंडल खींचें।',
      's2_3_txt':
          'अब, समानांतर स्थिति को तोड़ने के लिए Line M के हैंडल को खींचें।',
      's2_4_hud': 'रेखाओं को संरेखित करें! Line M को वापस समानांतर खींचें।',
      's2_4_txt':
          'रेखाओं को संरेखित करें! एकांतर अंतः कोणों का मिलान करने के लिए Line M को वापस खींचें।',
      's2_sum':
          'उत्कृष्ट। आपने सत्यापित किया कि एकांतर अंतः कोण संगत कोणों की तरह व्यवहार करते हैं।\n\nसमानांतर रेखाएं ↔ समान एकांतर अंतः कोण',
      'scen3Title': '3. 180° कोण बैंक',
      's3Obj':
          'यह प्रदर्शित करने के लिए कि क्रमागत अंतः कोण संपूरक (180° जोड़ते हैं) होते हैं जब रेखाएं समानांतर हों।',
      's3_1_hud': 'नीचे-बाएँ अंतः कोण (∠3) पर क्लिक करें।',
      's3_1_txt':
          'समानांतर रेखाएं स्थापित हैं। क्रमागत अंतः कोणों को पहचानने के लिए नीचे-बाएँ अंतः कोण (∠3) पर क्लिक करें।',
      's3_2_hud':
          'यह देखने के लिए "Combine" बटन पर क्लिक करें कि क्या ये कोण एक साथ फिट होते हैं।',
      's3_2_txt':
          'अब आपने क्रमागत अंतः कोणों को पहचान लिया है। "Combine" बटन पर क्लिक करें।',
      's3_3_hud':
          'समानांतर संरेखण तोड़ें! Line M खींचें, फिर "Combine" क्लिक करें।',
      's3_3_txt':
          'अब, समानांतर संरेखण को तोड़ते हैं। Line M पर हैंडल खींचें। फिर, "Combine" बटन पर क्लिक करें।',
      's3_4_hud':
          'इसे ठीक करें! Line M को वापस समानांतर खींचें, फिर "Combine" क्लिक करें।',
      's3_4_txt':
          'इसे ठीक करें! Line M को वापस समानांतर स्थिति में खींचें। पुष्टि करने के लिए "Combine" क्लिक करें।',
      's3_sum':
          'बिल्कुल सही फिट! जब रेखाएं समानांतर होती हैं तो एक ही तरफ के अंतः कोणों का योग 180° होता है।',
      'scen4Title': '4. ब्रिज संरेखण',
      's4Obj':
          'एक पुल खंड को सही ढंग से संरेखित करने के लिए एकांतर अंतः कोणों के गुण को लागू करें।',
      's4_1_hud': 'खंड B को यार्ड से खींचें और केंद्रीय स्तंभ पर छोड़ें।',
      's4_1_txt':
          'एक नदी पर एक पुल बनाया जाना है। Segment B को यार्ड से खींचें और केंद्रीय स्तंभ पर छोड़ें।',
      's4_2_hud': 'खंड B को तब तक घुमाएं जब तक कि उसका कोण 55° न हो जाए।',
      's4_2_txt':
          'खंड A 55° का कोण बनाता है। पुल को संरेखित करने के लिए, खंड B को इस कोण से मेल खाना चाहिए।',
      's4_3_hud':
          'संरेखण का परीक्षण करने के लिए "Lock Bridge" बटन पर क्लिक करें।',
      's4_3_txt':
          'एक बार कोण हरे रंग में पूरी तरह से मेल खाने के बाद, परीक्षण करने के लिए "Lock Bridge" बटन पर क्लिक करें।',
      's4_sum':
          'पुल पूरा! उत्कृष्ट! आपने एकांतर अंतः कोणों का उपयोग करके पुल को पूरी तरह से संरेखित किया है।',
      'scen5Title': '5. पेरिस्कोप चुनौती',
      's5Obj':
          'एक पेरिस्कोप का निर्माण करने के लिए समानांतर रेखाओं और एकांतर अंतः कोणों को लागू करें।',
      's5_1_hud': 'दो दर्पणों को पेरिस्कोप के अंदर के खांचों में खींचें।',
      's5_1_txt':
          'यहाँ एक पेरिस्कोप ट्यूब है। टूलबॉक्स से दो दर्पणों को खींचकर कोनों के खांचों में रखें।',
      's5_2_hud':
          'प्रत्येक दर्पण को एकांतर अंतः कोणों को संरेखित करने के लिए घुमाएं।',
      's5_2_txt':
          'प्रकाश किरण एक तिर्यक रेखा के रूप में कार्य करती है। एकांतर अंतः कोणों को संरेखित करने के लिए प्रत्येक दर्पण को घुमाएं।',
      's5_3_hud': 'दर्पण संरेखित! देखने के लिए ऐपिस पर क्लिक करें।',
      's5_3_txt':
          'लेजर बीम संरेखित है। जब दर्पण समानांतर हों, तो पुष्टि करने के लिए ऐपिस पर क्लिक करें।',
      's5_sum':
          'दृश्य पुष्टि! एकांतर अंतः कोण पूरी तरह से मेल खाते हैं, जो साबित करता है कि दर्पण समानांतर हैं।',
      'fb_success': 'सिस्टम अपडेट।',
      'fb_error': 'संरेखण विफलता।',
      'fb_s4_snap': 'खंड जुड़ा हुआ है। अब घुमाएं।',
      'fb_s4_lock': 'पुल सुरक्षित है!',
      'fb_s5_snap': 'दर्पण खांचे में लगा है।',
      'fb_s5_misaligned': 'दर्पण समानांतर नहीं हैं।',
    },
  };

  String t(String key) {
    return translations[_languages[_langIdx]]?[key] ??
        translations['en']?[key] ??
        key;
  }

  void _cycleLanguage() {
    _playSound(_clickPlayer);
    setState(() {
      _langIdx = (_langIdx + 1) % _languages.length;
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

    _s3AnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _s3AnimController.addListener(() => setState(() {}));

    _s4AnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _s4AnimController.addListener(() => setState(() {}));

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

    _s3AnimController.dispose();
    _s4AnimController.dispose();
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
      _fontSize = 13.0;
      _s5ShowView = false;
      _s5IsAligned = false;

      _tTilt = 225.0;
      _mTilt = 0.0;
      _s1Clicked = false;
      _s1Unaligned = false;
      _s2Clicked = false;
      _s2TMoved = false;
      _s2Unaligned = false;
      _s3Clicked = false;
      _s3Unaligned = false;
      _s3Animating = false;
      _s4BX = -350.0;
      _s4BY = 200.0;
      _s4BSnapped = false;
      _s4BAngle = 0.0;
      _s5M1X = -100.0;
      _s5M1Y = 290.0;
      _s5M1Snapped = false;
      _s5M1Angle = 90.0;
      _s5M2X = 100.0;
      _s5M2Y = 290.0;
      _s5M2Snapped = false;
      _s5M2Angle = 90.0;

      _s3AnimController.reset();
      _s4AnimController.reset();

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
          ScenarioStep(hud: t('s2_2_hud'), text: t('s2_2_txt')),
          ScenarioStep(hud: t('s2_3_hud'), text: t('s2_3_txt')),
          ScenarioStep(
            hud: t('s2_4_hud'),
            text: t('s2_4_txt'),
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
          ScenarioStep(hud: t('s3_2_hud'), text: t('s3_2_txt')),
          ScenarioStep(hud: t('s3_3_hud'), text: t('s3_3_txt')),
          ScenarioStep(
            hud: t('s3_4_hud'),
            text: t('s3_4_txt'),
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
      _tTilt = 225.0;
      _mTilt = 0.0;
      _s1Clicked = false;
      _s1Unaligned = false;
      _s2Clicked = false;
      _s2TMoved = false;
      _s2Unaligned = false;
      _s3Clicked = false;
      _s3Unaligned = false;
      _s3Animating = false;
      _s4BX = -350.0;
      _s4BY = 200.0;
      _s4BSnapped = false;
      _s4BAngle = 0.0;
      _s5M1X = -100.0;
      _s5M1Y = 290.0;
      _s5M1Snapped = false;
      _s5M1Angle = 90.0;
      _s5M2X = 100.0;
      _s5M2Y = 290.0;
      _s5M2Snapped = false;
      _s5M2Angle = 90.0;

      _pan = Offset.zero;
      _zoom = 1.0;
      _s3AnimController.reset();
      _s4AnimController.reset();
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
    if (_actionValidated || _s3Animating || _s5ShowView) return;

    _initialZoom = _zoom;
    _lastFocalPoint = details.localFocalPoint;
    _activeDragType = null;
    Offset pt = _getLogicCoord(details.localFocalPoint, size);
    double mRad = _mTilt * math.pi / 180;
    double tRad = _tTilt * math.pi / 180;

    // Line M Handle
    if ((_activeScenario == 1 && _activeStep >= 1) ||
        (_activeScenario == 2 && _activeStep >= 2) ||
        (_activeScenario == 3 && _activeStep >= 2)) {
      double p2x = 150 / math.tan(tRad);
      double hX = p2x + 300 * math.cos(mRad);
      double hY = 150 + 300 * math.sin(mRad);
      if ((Offset(pt.dx - hX, pt.dy - hY).distance) < 80) {
        _activeDragType = 'm_handle';
        _playSound(_clickPlayer);
        return;
      }
    }

    // Transversal Handle
    if (_activeScenario == 2 && _activeStep >= 1) {
      double hX = 350 * math.cos(tRad);
      double hY = 350 * math.sin(tRad);
      if ((Offset(pt.dx - hX, pt.dy - hY).distance) < 80) {
        _activeDragType = 't_handle';
        _playSound(_clickPlayer);
        return;
      }
    }

    // S4 Drags
    if (_activeScenario == 4 && _activeStep == 0 && !_s4BSnapped) {
      if ((Offset(pt.dx - _s4BX, pt.dy - _s4BY).distance) < 100) {
        _activeDragType = 's4_segment';
        _dragOffset = Offset(_s4BX - pt.dx, _s4BY - pt.dy);
        _playSound(_clickPlayer);
        return;
      }
    }
    if (_activeScenario == 4 && _activeStep == 1 && _s4BSnapped) {
      double sRad = _s4BAngle * math.pi / 180;
      double hX = 160 * math.cos(sRad);
      double hY = 160 * math.sin(sRad);
      if ((Offset(pt.dx - hX, pt.dy - hY).distance) < 80) {
        _activeDragType = 's4_rotator';
        _playSound(_clickPlayer);
        return;
      }
    }

    // S5 Drags
    if (_activeScenario == 5 && _activeStep == 0) {
      if (!_s5M1Snapped &&
          (Offset(pt.dx - _s5M1X, pt.dy - _s5M1Y).distance) < 80) {
        _activeDragType = 's5_m1_drag';
        _dragOffset = Offset(_s5M1X - pt.dx, _s5M1Y - pt.dy);
        _playSound(_clickPlayer);
        return;
      }
      if (!_s5M2Snapped &&
          (Offset(pt.dx - _s5M2X, pt.dy - _s5M2Y).distance) < 80) {
        _activeDragType = 's5_m2_drag';
        _dragOffset = Offset(_s5M2X - pt.dx, _s5M2Y - pt.dy);
        _playSound(_clickPlayer);
        return;
      }
    }
    if (_activeScenario == 5 && _activeStep == 1) {
      double r1 = _s5M1Angle * math.pi / 180;
      if ((Offset(
            pt.dx - (60 * math.cos(r1)),
            pt.dy - (-150 + 60 * math.sin(r1)),
          ).distance) <
          60) {
        _activeDragType = 's5_m1_rot';
        _playSound(_clickPlayer);
        return;
      }
      double r2 = _s5M2Angle * math.pi / 180;
      if ((Offset(
            pt.dx - (60 * math.cos(r2)),
            pt.dy - (150 + 60 * math.sin(r2)),
          ).distance) <
          60) {
        _activeDragType = 's5_m2_rot';
        _playSound(_clickPlayer);
        return;
      }
    }

    _activeDragType = 'canvas';
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_activeDragType == null || _s5ShowView) return;

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
      if (_activeDragType == 'm_handle') {
        double tRad = _tTilt * math.pi / 180;
        double p2x = 150 / math.tan(tRad);
        double deg = math.atan2(pt.dy - 150, pt.dx - p2x) * 180 / math.pi;
        double norm = ((deg % 180) + 180) % 180;
        bool isParallel = (norm < 3 || (180 - norm) < 3);
        if (isParallel) deg = 0;
        _mTilt = deg;

        if (_activeScenario == 1) {
          if (!isParallel && !_s1Unaligned && deg.abs() > 5) {
            _s1Unaligned = true;
            _markStepComplete(delayMs: 100);
          }
          if (_activeStep == 2 && isParallel) {
            _playSound(_fxPlayer);
            _markStepComplete();
          }
        } else if (_activeScenario == 2) {
          if (!isParallel && !_s2Unaligned && deg.abs() > 5) {
            _s2Unaligned = true;
            _markStepComplete(delayMs: 100);
          }
          if (_activeStep == 3 && isParallel) {
            _playSound(_fxPlayer);
            _markStepComplete();
          }
        } else if (_activeScenario == 3) {
          if (!isParallel && !_s3Unaligned && deg.abs() > 5) {
            _s3Unaligned = true;
          }
        }
      } else if (_activeDragType == 't_handle') {
        double deg = math.atan2(pt.dy, pt.dx) * 180 / math.pi;
        if (deg < 210) deg = 210;
        if (deg > 240) deg = 240;
        _tTilt = deg;
        if ((_tTilt - 225).abs() > 10) _s2TMoved = true;
      } else if (_activeDragType == 's4_segment') {
        _s4BX = pt.dx + _dragOffset.dx;
        _s4BY = pt.dy + _dragOffset.dy;
      } else if (_activeDragType == 's4_rotator') {
        double deg = math.atan2(pt.dy, pt.dx) * 180 / math.pi;
        double norm = ((deg % 180) + 180) % 180;
        _s4BAngle = deg;
        if ((norm - 55).abs() < 3) {
          _s4BAngle = (deg - 55).abs() < 3 ? 55 : (55 - 180);
          if (_activeStep == 1) {
            _playSound(_fxPlayer);
            _markStepComplete(delayMs: 500);
          }
        }
      } else if (_activeDragType == 's5_m1_drag') {
        _s5M1X = pt.dx + _dragOffset.dx;
        _s5M1Y = pt.dy + _dragOffset.dy;
      } else if (_activeDragType == 's5_m2_drag') {
        _s5M2X = pt.dx + _dragOffset.dx;
        _s5M2Y = pt.dy + _dragOffset.dy;
      } else if (_activeDragType == 's5_m1_rot') {
        double deg = math.atan2(pt.dy - (-150), pt.dx) * 180 / math.pi;
        _s5M1Angle = (deg / 5).round() * 5.0;
        double m1Eff = ((_s5M1Angle % 180) + 180) % 180;
        double m2Eff = ((_s5M2Angle % 180) + 180) % 180;
        if ((m1Eff - 135).abs() < 3 &&
            (m2Eff - 135).abs() < 3 &&
            _activeStep == 1) {
          _playSound(_fxPlayer);
          _markStepComplete(delayMs: 500);
        }
      } else if (_activeDragType == 's5_m2_rot') {
        double deg = math.atan2(pt.dy - 150, pt.dx) * 180 / math.pi;
        _s5M2Angle = (deg / 5).round() * 5.0;
        double m1Eff = ((_s5M1Angle % 180) + 180) % 180;
        double m2Eff = ((_s5M2Angle % 180) + 180) % 180;
        if ((m1Eff - 135).abs() < 3 &&
            (m2Eff - 135).abs() < 3 &&
            _activeStep == 1) {
          _playSound(_fxPlayer);
          _markStepComplete(delayMs: 500);
        }
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_activeDragType == null || _activeDragType == 'canvas') {
      _activeDragType = null;
      return;
    }

    setState(() {
      if (_activeDragType == 't_handle' &&
          _activeScenario == 2 &&
          _activeStep == 1 &&
          _s2TMoved) {
        _playSound(_fxPlayer);
        _markStepComplete();
      } else if (_activeDragType == 's4_segment') {
        if (Offset(_s4BX, _s4BY).distance < 60) {
          _s4BX = 0;
          _s4BY = 0;
          _s4BSnapped = true;
          _s4BAngle = 15;
          _playSound(_fxPlayer);
          _showFeedback(t('fb_s4_snap'), Colors.green);
          _markStepComplete();
        } else {
          _s4BX = -350;
          _s4BY = 200;
          _playSound(_errorPlayer);
          _showFeedback(t('fb_error'), Colors.red);
        }
      } else if (_activeDragType == 's5_m1_drag') {
        if (Offset(_s5M1X, _s5M1Y - (-150)).distance < 60) {
          _s5M1X = 0;
          _s5M1Y = -150;
          _s5M1Snapped = true;
          _playSound(_fxPlayer);
          _showFeedback(t('fb_s5_snap'), Colors.green);
          if (_s5M2Snapped && _activeStep == 0) _markStepComplete();
        } else {
          _playSound(_errorPlayer);
          _s5M1X = -100;
          _s5M1Y = 290;
        }
      } else if (_activeDragType == 's5_m2_drag') {
        if (Offset(_s5M2X, _s5M2Y - 150).distance < 60) {
          _s5M2X = 0;
          _s5M2Y = 150;
          _s5M2Snapped = true;
          _playSound(_fxPlayer);
          _showFeedback(t('fb_s5_snap'), Colors.green);
          if (_s5M1Snapped && _activeStep == 0) _markStepComplete();
        } else {
          _playSound(_errorPlayer);
          _s5M2X = 100;
          _s5M2Y = 290;
        }
      }
    });
    _activeDragType = null;
  }

  void _handleTap(TapDownDetails details, Size size) {
    if (_actionValidated || _s3Animating || _s5ShowView) return;
    Offset pt = _getLogicCoord(details.localPosition, size);

    if (_activeScenario == 1 && _activeStep == 0) {
      double p1x = -150 / math.tan(_tTilt * math.pi / 180);
      if (Offset(pt.dx - p1x, pt.dy - (-150)).distance < 60) {
        _playSound(_clickPlayer);
        setState(() => _s1Clicked = true);
        _markStepComplete();
      }
    } else if (_activeScenario == 2 && _activeStep == 0) {
      double p1x = -150 / math.tan(_tTilt * math.pi / 180);
      if (Offset(pt.dx - p1x, pt.dy - (-150)).distance < 60) {
        _playSound(_clickPlayer);
        setState(() => _s2Clicked = true);
        _markStepComplete();
      }
    } else if (_activeScenario == 3 && _activeStep == 0) {
      double p1x = -150 / math.tan(_tTilt * math.pi / 180);
      if (Offset(pt.dx - p1x, pt.dy - (-150)).distance < 60) {
        _playSound(_clickPlayer);
        setState(() => _s3Clicked = true);
        _markStepComplete();
      }
    }
  }

  void _handleS3Combine() {
    if (_activeScenario != 3 || _actionValidated || _s3Animating) return;
    bool isParallel = _mTilt.abs() < 3;
    _playSound(_clickPlayer);

    if (_activeStep == 1) {
      _startS3Animation();
    } else if (_activeStep == 2) {
      if (isParallel) {
        _playSound(_errorPlayer);
        _showFeedback("Break parallel alignment first!", Colors.red);
        return;
      }
      _startS3Animation();
    } else if (_activeStep == 3) {
      if (!isParallel) {
        _playSound(_errorPlayer);
        _showFeedback("Align lines back to parallel first!", Colors.red);
        return;
      }
      _startS3Animation();
    }
  }

  void _startS3Animation() {
    setState(() => _s3Animating = true);
    _s3AnimController.forward(from: 0).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _s3Animating = false);
        if (_activeStep == 1) {
          _markStepComplete(delayMs: 100);
        } else if (_activeStep == 2) {
          _s3Unaligned = true;
          _markStepComplete(delayMs: 100);
        } else if (_activeStep == 3)
          _markStepComplete(delayMs: 100);
      });
    });
  }

  void _handleS4Lock() {
    if (_activeScenario != 4 || _actionValidated) return;
    bool isAligned = (_s4BAngle - 55).abs() < 3;
    _playSound(_clickPlayer);

    if (isAligned) {
      _playSound(_successPlayer);
      _s4AnimController.forward(from: 0).then((_) {
        _showFeedback(t('fb_s4_lock'), Colors.green);
        _markStepComplete(delayMs: 500);
      });
    } else {
      _playSound(_errorPlayer);
      _showFeedback(t('fb_error'), Colors.red);
    }
  }

  void _handleS5Eyepiece() {
    if (_activeScenario != 5 || _activeStep != 2 || _actionValidated) return;
    double m1Eff = ((_s5M1Angle % 180) + 180) % 180;
    double m2Eff = ((_s5M2Angle % 180) + 180) % 180;
    _playSound(_clickPlayer);

    setState(() {
      _s5IsAligned = ((m1Eff - 135).abs() < 3 && (m2Eff - 135).abs() < 3);
      _s5ShowView = true;
    });

    if (_s5IsAligned) {
      _playSound(_successPlayer);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _s5ShowView = false);
        _markStepComplete(delayMs: 500);
      });
    } else {
      _playSound(_errorPlayer);
      _showFeedback(t('fb_s5_misaligned'), Colors.red);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _s5ShowView = false);
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
                  width: _isSidebarOpen ? screenWidth * 0.38 : 0,
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
                            const SizedBox(
                              height: 30,
                            ), // Top spacing for menu button
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
                                      _languages[_langIdx].toUpperCase(),
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

                            ...curScen.steps.asMap().entries.map((entry) {
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
                                          ? Colors.blueAccent.withOpacity(0.15)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    fontWeight: FontWeight.bold,
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
                                  painter: _LaserPainter(
                                    scenario: _activeScenario,
                                    step: _activeStep,
                                    zoom: _zoom,
                                    pan: _pan,
                                    tTilt: _tTilt,
                                    mTilt: _mTilt,
                                    s1Clicked: _s1Clicked,
                                    s2Clicked: _s2Clicked,
                                    s3Clicked: _s3Clicked,
                                    s3Animating: _s3Animating,
                                    s3AnimValue: _s3AnimController.value,
                                    s4BX: _s4BX,
                                    s4BY: _s4BY,
                                    s4BAngle: _s4BAngle,
                                    s4BSnapped: _s4BSnapped,
                                    s4AnimValue: _s4AnimController.value,
                                    s5M1X: _s5M1X,
                                    s5M1Y: _s5M1Y,
                                    s5M1Angle: _s5M1Angle,
                                    s5M1Snapped: _s5M1Snapped,
                                    s5M2X: _s5M2X,
                                    s5M2Y: _s5M2Y,
                                    s5M2Angle: _s5M2Angle,
                                    s5M2Snapped: _s5M2Snapped,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Active Step Floating Box (Only when sidebar is closed)
                        if (!_isSidebarOpen)
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
                        if (!_s5ShowView)
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

                        if (_activeScenario == 3 &&
                            _activeStep >= 1 &&
                            !_s3Animating &&
                            !_s5ShowView)
                          Align(
                            alignment: const Alignment(-0.5, 0.4),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.merge_type),
                              label: Text(
                                t('combine'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                              onPressed: _handleS3Combine,
                            ),
                          ),

                        if (_activeScenario == 4 &&
                            _s4BSnapped &&
                            _activeStep == 2 &&
                            !_s5ShowView)
                          Align(
                            alignment: const Alignment(-0.5, 0.4),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.lock),
                              label: Text(
                                t('lockBridge'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                              onPressed: _handleS4Lock,
                            ),
                          ),

                        if (_activeScenario == 5 &&
                            _activeStep == 2 &&
                            !_s5ShowView)
                          Align(
                            alignment: const Alignment(-0.6, 0.2),
                            child: InkWell(
                              onTap: _handleS5Eyepiece,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF334155),
                                  border: Border.all(
                                    color: const Color(0xFF1E293B),
                                    width: 4,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.lightBlueAccent.withOpacity(
                                        0.8,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        t('view'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // S5 View Overlay
                        if (_s5ShowView)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black87,
                              child: Center(
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.elasticOut,
                                  builder: (context, val, child) {
                                    return Transform.scale(
                                      scale: val,
                                      child:
                                          _s5IsAligned
                                              ? _buildS5SuccessView()
                                              : _buildS5ErrorView(),
                                    );
                                  },
                                ),
                              ),
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
                      width: 380, // Compact width
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.8,
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
                            padding: const EdgeInsets.all(24),
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
                            Icons.layers,
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

  Widget _buildS5SuccessView() {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1E293B), width: 20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Basic landscape representation
          Positioned(
            top: 80,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE047),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 400,
              height: 200,
              color: const Color(0xFF0284C7),
            ),
          ),
          // Crosshairs
          Container(width: 400, height: 2, color: Colors.black54),
          Container(width: 2, height: 400, color: Colors.black54),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54, width: 2),
            ),
          ),
          const Positioned(
            bottom: 40,
            child: Text(
              "TARGET ACQUIRED",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildS5ErrorView() {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1E293B), width: 20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glitch lines
          Container(
            width: 300,
            height: 4,
            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.5)),
          ),
          Transform.translate(
            offset: const Offset(0, -50),
            child: Container(
              width: 300,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.5),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 50),
            child: Container(
              width: 300,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.5),
              ),
            ),
          ),
          const Text(
            "NO SIGNAL",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
          const Positioned(
            bottom: 40,
            child: Text(
              "MISALIGNED MIRRORS",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CUSTOM PAINTER =================

class _LaserPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final Offset pan;

  final double tTilt;
  final double mTilt;
  final bool s1Clicked;
  final bool s2Clicked;
  final bool s3Clicked;
  final bool s3Animating;
  final double s3AnimValue;

  final double s4BX;
  final double s4BY;
  final double s4BAngle;
  final bool s4BSnapped;
  final double s4AnimValue;

  final double s5M1X, s5M1Y, s5M1Angle;
  final bool s5M1Snapped;
  final double s5M2X, s5M2Y, s5M2Angle;
  final bool s5M2Snapped;

  _LaserPainter({
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.pan,
    required this.tTilt,
    required this.mTilt,
    required this.s1Clicked,
    required this.s2Clicked,
    required this.s3Clicked,
    required this.s3Animating,
    required this.s3AnimValue,
    required this.s4BX,
    required this.s4BY,
    required this.s4BAngle,
    required this.s4BSnapped,
    required this.s4AnimValue,
    required this.s5M1X,
    required this.s5M1Y,
    required this.s5M1Angle,
    required this.s5M1Snapped,
    required this.s5M2X,
    required this.s5M2Y,
    required this.s5M2Angle,
    required this.s5M2Snapped,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = math.min(size.width / 1000, size.height / 1000) * zoom;

    canvas.translate(center.dx + pan.dx, center.dy + pan.dy);
    canvas.scale(scale);

    _drawGrid(canvas);

    if (scenario >= 1 && scenario <= 3) {
      _drawScenarios1to3(canvas);
    } else if (scenario == 4) {
      _drawScenario4(canvas);
    } else if (scenario == 5) {
      _drawScenario5(canvas);
    }
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

  void _drawScenarios1to3(Canvas canvas) {
    double tRad = tTilt * math.pi / 180;
    double mRad = mTilt * math.pi / 180;
    double p1x = -150 / math.tan(tRad);
    double p2x = 150 / math.tan(tRad);

    Paint glowBlue =
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    Paint glowYellow =
        Paint()
          ..color = Colors.amber.withOpacity(0.3)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    Paint glowRed =
        Paint()
          ..color = Colors.red.withOpacity(0.3)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    Paint coreWhite =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    // Line L (Top)
    canvas.drawLine(
      const Offset(-800, -150),
      const Offset(800, -150),
      glowBlue,
    );
    canvas.drawLine(
      const Offset(-800, -150),
      const Offset(800, -150),
      coreWhite,
    );
    _drawText(canvas, "Line L", const Offset(-450, -170), fontSize: 24);

    // Line M (Bottom)
    bool isParallel = (mTilt.abs() < 3 || (180 - mTilt).abs() < 3);
    canvas.save();
    canvas.translate(p2x, 150);
    canvas.rotate(mRad);
    canvas.translate(-p2x, -150);
    canvas.drawLine(
      const Offset(-800, 150),
      const Offset(800, 150),
      isParallel ? glowBlue : glowRed,
    );
    canvas.drawLine(const Offset(-800, 150), const Offset(800, 150), coreWhite);
    if ((scenario == 1 && step >= 1) ||
        (scenario == 2 && step >= 2) ||
        (scenario == 3 && step >= 2)) {
      _drawHandle(canvas, Offset(p2x + 300, 150), Colors.blueAccent);
    }
    canvas.restore();
    _drawText(canvas, "Line M", const Offset(-450, 130), fontSize: 24);

    // Transversal T
    double dx = 800 * math.cos(tRad);
    double dy = 800 * math.sin(tRad);
    canvas.drawLine(Offset(dx, dy), Offset(-dx, -dy), glowYellow);
    canvas.drawLine(Offset(dx, dy), Offset(-dx, -dy), coreWhite);
    _drawText(canvas, "T", Offset(dx * 0.4 - 20, dy * 0.4 - 20), fontSize: 24);

    if (scenario == 2 && step >= 1) {
      double hX = 350 * math.cos(tRad);
      double hY = 350 * math.sin(tRad);
      _drawHandle(canvas, Offset(hX, hY), Colors.amber);
    }

    if (scenario == 1) {
      double start1 = math.pi;
      double end1 = tRad;
      if (!s1Clicked) {
        _drawClickZone(canvas, Offset(p1x, -150), 80, start1, end1 - start1);
      } else {
        _drawAngleArc(
          canvas,
          Offset(p1x, -150),
          60,
          start1,
          end1 - start1,
          Colors.blueAccent,
          "${((end1 - start1) * 180 / math.pi).round()}°",
        );
        double start5 = math.pi;
        double end5 = tRad - mRad;
        canvas.save();
        canvas.translate(p2x, 150);
        canvas.rotate(mRad);
        _drawAngleArc(
          canvas,
          const Offset(0, 0),
          60,
          start5,
          end5 - start5,
          isParallel ? Colors.blueAccent : Colors.redAccent,
          "${((end5 - start5) * 180 / math.pi).round()}°",
          labelRotation: -mRad,
        );
        canvas.restore();
      }
    } else if (scenario == 2) {
      double start3 = tRad - math.pi;
      double end3 = math.pi;
      if (!s2Clicked) {
        _drawClickZone(canvas, Offset(p1x, -150), 80, start3, end3 - start3);
      } else {
        _drawAngleArc(
          canvas,
          Offset(p1x, -150),
          60,
          start3,
          end3 - start3,
          Colors.green,
          "${((end3 - start3) * 180 / math.pi).round()}°",
        );
        double start6 = tRad - mRad;
        double end6 = 2 * math.pi;
        canvas.save();
        canvas.translate(p2x, 150);
        canvas.rotate(mRad);
        _drawAngleArc(
          canvas,
          const Offset(0, 0),
          60,
          start6,
          end6 - start6,
          isParallel ? Colors.green : Colors.redAccent,
          "${((end6 - start6) * 180 / math.pi).round()}°",
          labelRotation: -mRad,
        );
        canvas.restore();
      }
    } else if (scenario == 3) {
      double start3 = tRad - math.pi;
      double end3 = math.pi;
      if (!s3Clicked) {
        _drawClickZone(canvas, Offset(p1x, -150), 80, start3, end3 - start3);
      } else {
        if (!s3Animating) {
          _drawAngleArc(
            canvas,
            Offset(p1x, -150),
            60,
            start3,
            end3 - start3,
            Colors.blueAccent,
            "${((end3 - start3) * 180 / math.pi).round()}°",
          );
          double start5 = math.pi;
          double end5 = tRad - mRad;
          canvas.save();
          canvas.translate(p2x, 150);
          canvas.rotate(mRad);
          _drawAngleArc(
            canvas,
            const Offset(0, 0),
            60,
            start5,
            end5 - start5,
            Colors.amber,
            "${((end5 - start5) * 180 / math.pi).round()}°",
            labelRotation: -mRad,
          );
          canvas.restore();
        } else {
          double p = s3AnimValue;
          double ease = 1 - math.pow(1 - p, 3).toDouble();
          double targetX = 400;
          double targetY = -50;

          double cx3 = p1x + (targetX - p1x) * ease;
          double cy3 = -150 + (targetY - -150) * ease;
          _drawAngleArc(
            canvas,
            Offset(cx3, cy3),
            60,
            start3,
            end3 - start3,
            Colors.blueAccent,
            "${((end3 - start3) * 180 / math.pi).round()}°",
          );

          double cx5 = p2x + (targetX - p2x) * ease;
          double cy5 = 150 + (targetY - 150) * ease;
          double rot5 = mTilt + (-180 - mTilt) * ease;
          canvas.save();
          canvas.translate(cx5, cy5);
          canvas.rotate(rot5 * math.pi / 180);
          double start5 = math.pi;
          double end5 = tRad - mRad;
          _drawAngleArc(
            canvas,
            const Offset(0, 0),
            60,
            start5,
            end5 - start5,
            Colors.amber,
            "${((end5 - start5) * 180 / math.pi).round()}°",
            labelRotation: -rot5 * math.pi / 180,
          );
          canvas.restore();

          if (p == 1.0) {
            int val3 = ((end3 - start3) * 180 / math.pi).round();
            int val5 = ((end5 - start5) * 180 / math.pi).round();
            String eq = "$val3° + $val5° = ${val3 + val5}°";
            if (val3 + val5 != 180) eq += " ≠ 180°";
            _drawText(
              canvas,
              eq,
              Offset(targetX, targetY - 120),
              fontSize: 24,
              center: true,
              color: Colors.white,
            );
          }
        }
      }
    }
  }

  void _drawScenario4(Canvas canvas) {
    Paint riverPaint = Paint()..color = Colors.lightBlue.withOpacity(0.15);
    canvas.drawRect(const Rect.fromLTRB(-1000, -100, 1000, 100), riverPaint);
    Paint bankPaint =
        Paint()
          ..color = Colors.lightBlue
          ..strokeWidth = 4;
    canvas.drawLine(
      const Offset(-1000, -100),
      const Offset(1000, -100),
      bankPaint,
    );
    canvas.drawLine(
      const Offset(-1000, 100),
      const Offset(1000, 100),
      bankPaint,
    );

    canvas.drawLine(
      const Offset(-280, -400),
      const Offset(280, 400),
      Paint()
        ..color = Colors.amber.withOpacity(0.3)
        ..strokeWidth = 12,
    );
    _drawDashedLine(
      canvas,
      const Offset(-280, -400),
      const Offset(280, 400),
      Colors.white,
    );

    canvas.drawCircle(
      const Offset(0, 0),
      30,
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawCircle(
      const Offset(0, 0),
      30,
      Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      const Offset(0, 0),
      10,
      Paint()..color = const Color(0xFF1E293B),
    );

    canvas.save();
    canvas.translate(-70, -100);
    canvas.rotate(55 * math.pi / 180);
    _drawBridgePiece(canvas);
    canvas.restore();
    _drawAngleArc(
      canvas,
      const Offset(-70, -100),
      50,
      0,
      55 * math.pi / 180,
      Colors.green,
      "55°",
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-450, 150, -250, 350),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawText(
      canvas,
      "CONSTRUCTION YARD",
      const Offset(-350, 300),
      center: true,
      color: Colors.grey,
      fontSize: 14,
    );

    if (step == 0 && !s4BSnapped) {
      canvas.drawCircle(
        const Offset(0, 0),
        40,
        Paint()
          ..color = Colors.greenAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    canvas.save();
    canvas.translate(s4BX, s4BY);
    canvas.rotate(s4BAngle * math.pi / 180);
    _drawBridgePiece(canvas);
    if (step == 1 && s4BSnapped) {
      _drawHandle(canvas, const Offset(160, 0), Colors.blueAccent);
    }
    canvas.restore();

    if (s4BSnapped && step <= 2) {
      double norm = ((s4BAngle % 180) + 180) % 180;
      bool isAligned = (norm - 55).abs() < 3;
      _drawAngleArc(
        canvas,
        const Offset(0, 0),
        50,
        math.pi,
        norm * math.pi / 180,
        isAligned ? Colors.green : Colors.redAccent,
        "${norm.round()}°",
      );
    }

    if (s4AnimValue > 0) {
      double p = s4AnimValue;
      double startX = -120;
      double startY = -170;
      double endX = 150;
      double endY = 210;
      double cx = startX + (endX - startX) * p;
      double cy = startY + (endY - startY) * p;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(55 * math.pi / 180);
      _drawCar(canvas);
      canvas.restore();
    }
  }

  void _drawScenario5(Canvas canvas) {
    Path body =
        Path()
          ..moveTo(400, -200)
          ..lineTo(-50, -200)
          ..lineTo(-50, 100)
          ..lineTo(-400, 100)
          ..lineTo(-400, 200)
          ..lineTo(50, 200)
          ..lineTo(50, -100)
          ..lineTo(400, -100)
          ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    double m1Eff = ((s5M1Angle % 180) + 180) % 180;
    double m2Eff = ((s5M2Angle % 180) + 180) % 180;
    bool isM1Aligned = (m1Eff - 135).abs() < 3;
    bool isM2Aligned = (m2Eff - 135).abs() < 3;
    bool hitM2 = false;
    List<Offset> pts = [const Offset(400, -150), const Offset(0, -150)];

    if (s5M1Snapped) {
      double out1 = (2 * m1Eff - 180) % 360;
      if (out1 < 0) out1 += 360;
      if (out1 > 0 && out1 < 180) {
        double hitX = 300 / math.tan(out1 * math.pi / 180);
        if (out1 == 90) hitX = 0;
        pts.add(Offset(hitX, 150));
        if (hitX.abs() < 40 && s5M2Snapped) {
          hitM2 = true;
          double out2 = (2 * m2Eff - out1) % 360;
          if (out2 < 0) out2 += 360;
          if (out2 > 90 && out2 < 270) {
            double dx = -400 - hitX;
            double dy = dx * math.tan(out2 * math.pi / 180);
            if (out2 == 180) dy = 0;
            pts.add(Offset(-400, 150 + dy));
          }
        }
      }
    }

    canvas.save();
    canvas.clipPath(
      Path()
        ..moveTo(400, -190)
        ..lineTo(-40, -190)
        ..lineTo(-40, 110)
        ..lineTo(-400, 110)
        ..lineTo(-400, 190)
        ..lineTo(40, 190)
        ..lineTo(40, -110)
        ..lineTo(400, -110)
        ..close(),
    );
    Color rayColor =
        (isM1Aligned && isM2Aligned && hitM2)
            ? Colors.greenAccent
            : Colors.redAccent;
    Paint rayGlow =
        Paint()
          ..color = rayColor.withOpacity(0.3)
          ..strokeWidth = 12
          ..style = PaintingStyle.stroke;
    Paint rayCore =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    Path rayPath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      rayPath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(rayPath, rayGlow);
    canvas.drawPath(rayPath, rayCore);
    canvas.restore();

    canvas.save();
    canvas.translate(380, -150);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(0, -20, 40, 20),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawPath(
      Path()
        ..moveTo(20, -10)
        ..lineTo(0, 0)
        ..lineTo(20, 10)
        ..close(),
      Paint()..color = Colors.redAccent,
    );
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-150, 240, 150, 360),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawText(
      canvas,
      "MIRROR TOOLBOX",
      const Offset(0, 340),
      center: true,
      color: Colors.grey,
      fontSize: 14,
    );

    if (step == 0) {
      if (!s5M1Snapped) {
        canvas.drawCircle(
          const Offset(0, -150),
          30,
          Paint()
            ..color = Colors.amber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
      if (!s5M2Snapped) {
        canvas.drawCircle(
          const Offset(0, 150),
          30,
          Paint()
            ..color = Colors.amber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }

    canvas.save();
    canvas.translate(s5M1X, s5M1Y);
    canvas.rotate(s5M1Angle * math.pi / 180);
    canvas.drawLine(
      const Offset(-40, 0),
      const Offset(40, 0),
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    if (s5M1Snapped && step == 1) {
      _drawHandle(canvas, const Offset(60, 0), Colors.blueAccent);
    }
    canvas.restore();

    canvas.save();
    canvas.translate(s5M2X, s5M2Y);
    canvas.rotate(s5M2Angle * math.pi / 180);
    canvas.drawLine(
      const Offset(-40, 0),
      const Offset(40, 0),
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    if (s5M2Snapped && step == 1) {
      _drawHandle(canvas, const Offset(60, 0), Colors.blueAccent);
    }
    canvas.restore();

    if (s5M1Snapped && s5M2Snapped && step >= 1) {
      double ang1S = 90;
      double ang1E = m1Eff;
      if (ang1E < 90) ang1E += 180;
      _drawAngleArc(
        canvas,
        const Offset(0, -150),
        45,
        ang1S * math.pi / 180,
        (ang1E - ang1S) * math.pi / 180,
        isM1Aligned ? Colors.green : Colors.blueAccent,
        "${(ang1E - ang1S).round()}°",
      );

      double ang2S = 270;
      double ang2E = m2Eff + 180;
      if (ang2E < 270) ang2E += 180;
      _drawAngleArc(
        canvas,
        const Offset(0, 150),
        45,
        ang2S * math.pi / 180,
        (ang2E - ang2S) * math.pi / 180,
        isM2Aligned ? Colors.green : Colors.redAccent,
        "${(ang2E - ang2S).round()}°",
      );
    }
  }

  void _drawAngleArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Color color,
    String text, {
    double labelRotation = 0,
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
          ..arcTo(rect, startAngle, sweepAngle, false)
          ..close();

    canvas.drawPath(arcPath, fill);
    canvas.drawPath(arcPath, stroke);

    double midAngle = startAngle + sweepAngle / 2;
    double tx = center.dx + (radius * 0.65) * math.cos(midAngle);
    double ty = center.dy + (radius * 0.65) * math.sin(midAngle);

    canvas.save();
    canvas.translate(tx, ty);
    canvas.rotate(labelRotation);
    _drawText(
      canvas,
      text,
      const Offset(0, 0),
      center: true,
      color: Colors.white,
      fontSize: 16,
    );
    canvas.restore();
  }

  void _drawClickZone(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    Rect rect = Rect.fromCircle(center: center, radius: radius);
    Path p =
        Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(rect, startAngle, sweepAngle, false)
          ..close();
    canvas.drawPath(
      p,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );
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

  void _drawBridgePiece(Canvas canvas) {
    canvas.drawLine(
      const Offset(0, 0),
      const Offset(160, 0),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round,
    );
    _drawDashedLine(
      canvas,
      const Offset(0, 0),
      const Offset(160, 0),
      Colors.white,
    );
  }

  void _drawCar(Canvas canvas) {
    canvas.scale(0.6);
    canvas.translate(-20, -10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(0, -10, 60, 10),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.redAccent,
    );
    canvas.drawRect(
      const Rect.fromLTRB(15, -8, 30, 8),
      Paint()..color = Colors.lightBlueAccent,
    );
    canvas.drawCircle(
      const Offset(10, 12),
      8,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawCircle(
      const Offset(50, 12),
      8,
      Paint()..color = const Color(0xFF1E293B),
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Color color) {
    Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = 2;
    double dist = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / dist;
    double dy = (p2.dy - p1.dy) / dist;
    for (double i = 0; i < dist; i += 20) {
      canvas.drawLine(
        Offset(p1.dx + dx * i, p1.dy + dy * i),
        Offset(p1.dx + dx * (i + 10), p1.dy + dy * (i + 10)),
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
  bool shouldRepaint(covariant _LaserPainter oldDelegate) => true;
}
