// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// ----------------------------------------------------------------------
// Please ensure you have the following in your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   audioplayers: ^5.2.1
// ----------------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExteriorAngleApp());
}

class ExteriorAngleApp extends StatelessWidget {
  const ExteriorAngleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Exterior Angles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFF6366f1),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const ExteriorAnglesofTriangle(),
    );
  }
}

// --- DATA MODELS ---

class GeomPoint {
  double x;
  double y;
  GeomPoint(this.x, this.y);
}

class AnglePiece {
  String id;
  double val;
  Color color;
  double start;
  double end;
  double x;
  double y;
  bool detached;
  bool snapped;
  bool isSquare;
  bool isClone;
  String targetVertex;
  double origX;
  double origY;

  AnglePiece({
    required this.id,
    required this.val,
    required this.color,
    required this.start,
    required this.end,
    required this.x,
    required this.y,
    this.detached = false,
    this.snapped = false,
    this.isSquare = false,
    this.isClone = false,
    this.targetVertex = '',
    this.origX = 0,
    this.origY = 0,
  });

  AnglePiece clone() {
    return AnglePiece(
      id: id,
      val: val,
      color: color,
      start: start,
      end: end,
      x: x,
      y: y,
      detached: detached,
      snapped: snapped,
      isSquare: isSquare,
      isClone: isClone,
      targetVertex: targetVertex,
      origX: origX,
      origY: origY,
    );
  }
}

class ScenarioConfig {
  double ext;
  double a;
  double b;
  String type;
  bool unsolved;

  ScenarioConfig(this.ext, this.a, this.b, this.type, [this.unsolved = false]);
}

// --- LOCALIZATION ---

const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': "The Exterior Angle: A Triangle's Outside Secret",
    'appSubtitle': "Class 7 • A TALE OF THREE INTERSECTING LINES",
    'enterLab': "Enter Lab",
    'objectiveLbl': "Mission Objective:",
    'stepLabel': "STEP",
    'doneBtn': "I'm Done",
    'completed': "Completed!",
    'successTitle': "Geometry Master!",
    'successDesc':
        "You successfully proved that an exterior angle equals the sum of the two opposite interior angles!",
    'restartLab': "Restart Lab",
    'extendBtn': "Extend Side",
    'puzzlesBtn': "Create Puzzles",
    'checkPredBtn': "Check My Prediction",
    'verifyBtn': "Verify",
    'nextScenario': "Next Challenge",
    'selectScenario': "Select Scenario",

    's1_title': "1. The Acute Triangle Puzzle",
    's1_obj':
        "To visually verify the Exterior Angle Property for an acute-angled triangle.",
    's1_step1':
        "Task: CLICK on the 'Extend Side' button.\nObservation: The side BC extends to a point D, creating the exterior angle ∠ACD.\nLearnt: An exterior angle is formed by extending a side.",
    's1_step2':
        "Task: CLICK the 'Create Puzzles' button.\nObservation: Clones of interior angles ∠A and ∠B detach.\nLearnt: We can compare these remote interior angles to the exterior angle.",
    's1_step3':
        "Task: DRAG the blue (∠A) and green (∠B) puzzle pieces and DROP them into the grey exterior angle space.\nObservation: The pieces snap perfectly into place, filling the exterior angle space.\nLearnt: The pieces fill the exterior angle completely.",
    's1_sum':
        "The two opposite interior angles fit perfectly into the exterior angle. This shows: Exterior Angle = Sum of the two opposite interior angles (∠ACD = ∠A + ∠B).",

    's2_title': "2. The Right-Angled Challenge",
    's2_obj':
        "To confirm that the Exterior Angle Property holds true for a right-angled triangle.",
    's2_step1':
        "Task: CLICK the 'Extend Side' button.\nObservation: The side BC extends to point D. The exterior angle ∠ACD is highlighted.\nLearnt: A right triangle can also have an exterior angle.",
    's2_step2':
        "Task: CLICK the 'Create Puzzles' button.\nObservation: A blue puzzle piece for ∠A and a green, square-cornered puzzle piece for ∠B appear.\nLearnt: The 90° angle acts as one of the remote interior angles.",
    's2_step3':
        "Task: DRAG the blue (∠A) and green (∠B) puzzle pieces and DROP them into the grey exterior angle space.\nObservation: Both pieces SNAP into place, perfectly filling the exterior angle ∠ACD.\nLearnt: The rule applies seamlessly to right-angled triangles.",
    's2_sum':
        "Even with a 90° angle, the rule works! The two opposite interior angles together are the same size as the exterior angle.",

    's3_title': "3. The Obtuse Angle Investigation",
    's3_obj':
        "To demonstrate the Exterior Angle Property for an obtuse-angled triangle.",
    's3_step1':
        "Task: CLICK the 'Extend Side' button to extend side BC to point D.\nObservation: The side extends, and the (now acute) exterior angle ∠ACD is highlighted.\nLearnt: An obtuse triangle's exterior angle can be acute.",
    's3_step2':
        "Task: CLICK the 'Create Puzzles' button.\nObservation: A small blue piece for ∠A and a large green piece for the obtuse ∠B appear.\nLearnt: The remote interior angles are vastly different in size.",
    's3_step3':
        "Task: DRAG the blue and green puzzle pieces and fit them into the grey exterior angle space.\nObservation: Despite their different sizes, they combine to perfectly fill the exterior angle.\nLearnt: The property is universal.",
    's3_sum':
        "It works for every triangle! The sum of the opposite interior angles always equals the exterior angle.",

    's4_title': "4. The Angle Architect (Unsolved)",
    's4_obj':
        "To construct an exterior angle by combining two given interior angles.",
    's4_step1':
        "Task: DRAG the red piece to vertex A and the yellow piece to vertex B to form a triangle.\nObservation: The pieces snap into place, forming a triangle ABC.\nLearnt: We can build a triangle starting from its base angles.",
    's4_step2':
        "Task: DRAG copies of your red and yellow pieces into the empty Exterior Angle Holder at point C.\nObservation: The red and yellow pieces snap together inside the holder.\nLearnt: This combined shape is our prediction for the true exterior angle.",
    's4_step3':
        "Task: CLICK the 'Check My Prediction' button.\nObservation: The true exterior angle is revealed and perfectly matches our prediction.\nLearnt: We can accurately calculate the exterior angle without measuring it directly.",
    's4_sum':
        "Your prediction was correct! You used the theorem perfectly to build the exact exterior angle.",

    's5_title': "5. The Triangle Balancer (Unsolved)",
    's5_obj':
        "To find the measure of a missing remote interior angle by balancing it with the exterior angle.",
    's5_step1':
        "Task: DRAG the handle on the ghost angle ∠B to change its size until its green puzzle piece fills the exterior angle.\nObservation: The green puzzle piece inside the exterior angle resizes dynamically as you adjust ∠B.\nLearnt: Changing the interior angle directly affects its corresponding part in the exterior angle.",
    's5_step2':
        "Task: When the green piece perfectly fills the rest of the purple space, CLICK 'Verify'.\nObservation: The triangle locks in place, confirming the fit.\nLearnt: We can find a missing interior angle if we know the exterior angle and the other interior angle.",
    's5_sum': "Balanced! You found the exact missing angle using the property.",
  },
  'hi': {
    'appTitle': "बाह्य कोण: एक त्रिभुज का बाहरी रहस्य",
    'appSubtitle': "कक्षा 7 • तीन प्रतिच्छेदी रेखाओं की कहानी",
    'enterLab': "लैब में प्रवेश करें",
    'objectiveLbl': "मिशन उद्देश्य:",
    'stepLabel': "कदम",
    'doneBtn': "मैं कर चुका हूँ",
    'completed': "पूरा हुआ!",
    'successTitle': "ज्यामिति के उस्ताद!",
    'successDesc':
        "आपने सफलतापूर्वक साबित कर दिया है कि एक बाह्य कोण दो विपरीत आंतरिक कोणों के योग के बराबर होता है!",
    'restartLab': "लैब फिर से शुरू करें",
    'extendBtn': "रेखा बढ़ाएं",
    'puzzlesBtn': "पहेलियाँ बनाएँ",
    'checkPredBtn': "मेरी भविष्यवाणी जाँचें",
    'verifyBtn': "सत्यापित करें",
    'nextScenario': "अगली चुनौती",
    'selectScenario': "दृश्य चुनें",

    's1_title': "1. न्यूनकोण त्रिभुज पहेली",
    's1_obj':
        "न्यूनकोण त्रिभुज के लिए बाह्य कोण गुण को दृश्य रूप से सत्यापित करना।",
    's1_step1':
        "कार्य: 'रेखा बढ़ाएं' बटन पर क्लिक करें।\nअवलोकन: भुजा BC बिंदु D तक बढ़ जाती है, जिससे बाह्य कोण ∠ACD बनता है।\nसीखा: एक बाह्य कोण एक भुजा को बढ़ाकर बनता है।",
    's1_step2':
        "कार्य: 'पहेलियाँ बनाएँ' बटन पर क्लिक करें।\nअवलोकन: आंतरिक कोण ∠A और ∠B के क्लोन अलग हो जाते हैं।\nसीखा: हम इन दूरस्थ आंतरिक कोणों की तुलना बाह्य कोण से कर सकते हैं।",
    's1_step3':
        "कार्य: नीले (∠A) और हरे (∠B) पहेली के टुकड़ों को खींचें और उन्हें बाह्य कोण वाले स्थान में छोड़ दें।\nअवलोकन: टुकड़े बाह्य कोण के स्थान में पूरी तरह से फिट बैठते हैं।\nसीखा: टुकड़े बाह्य कोण को पूरी तरह से भर देते हैं।",
    's1_sum':
        "दो विपरीत आंतरिक कोण पूरी तरह से बाह्य कोण में फिट होते हैं। यह दर्शाता है: बाह्य कोण = दो विपरीत आंतरिक कोणों का योग (∠ACD = ∠A + ∠B)।",

    's2_title': "2. समकोण चुनौती",
    's2_obj':
        "यह पुष्टि करने के लिए कि बाह्य कोण गुण समकोण त्रिभुज के लिए सत्य है।",
    's2_step1':
        "कार्य: 'रेखा बढ़ाएं' बटन पर क्लिक करें।\nअवलोकन: भुजा BC बिंदु D तक बढ़ जाती है। बाह्य कोण ∠ACD हाइलाइट किया गया है।\nसीखा: समकोण त्रिभुज में भी एक बाह्य कोण हो सकता है।",
    's2_step2':
        "कार्य: 'पहेलियाँ बनाएँ' बटन पर क्लिक करें।\nअवलोकन: ∠A के लिए एक नीला पहेली टुकड़ा और ∠B के लिए एक हरा टुकड़ा दिखाई देता है।\nसीखा: 90° कोण दूरस्थ आंतरिक कोणों में से एक के रूप में कार्य करता है।",
    's2_step3':
        "कार्य: नीले (∠A) और हरे (∠B) पहेली के टुकड़ों को खींचें और उन्हें बाह्य कोण वाले स्थान में छोड़ दें।\nअवलोकन: दोनों टुकड़े अपनी जगह पर आ जाते हैं, बाह्य कोण ∠ACD को पूरी तरह से भर देते हैं।\nसीखा: नियम समकोण त्रिभुजों पर भी सहज रूप से लागू होता है।",
    's2_sum':
        "90° कोण के साथ भी, बाह्य कोण विपरीत आंतरिक कोणों के योग के बराबर होता है!",

    's3_title': "3. अधिककोण अन्वेषण",
    's3_obj': "अधिककोण त्रिभुज के लिए बाह्य कोण गुण प्रदर्शित करने के लिए।",
    's3_step1':
        "कार्य: भुजा BC को बिंदु D तक बढ़ाने के लिए 'रेखा बढ़ाएं' बटन पर क्लिक करें।\nअवलोकन: भुजा बढ़ जाती है, और बाह्य कोण ∠ACD हाइलाइट किया जाता है।\nसीखा: अधिककोण त्रिभुज का बाह्य कोण न्यून हो सकता है।",
    's3_step2':
        "कार्य: 'पहेलियाँ बनाएँ' बटन पर क्लिक करें।\nअवलोकन: ∠A के लिए एक छोटा नीला टुकड़ा और अधिककोण ∠B के लिए एक बड़ा हरा टुकड़ा दिखाई देता है।\nसीखा: दूरस्थ आंतरिक कोण आकार में बहुत भिन्न होते हैं।",
    's3_step3':
        "कार्य: नीले और हरे रंग के पहेली के टुकड़ों को खींचें और उन्हें बाह्य कोण वाले स्थान में फिट करें।\nअवलोकन: उनके विभिन्न आकारों के बावजूद, वे बाह्य कोण को पूरी तरह से भरने के लिए जुड़ जाते हैं।\nसीखा: यह गुण सार्वभौमिक है।",
    's3_sum':
        "यह हर त्रिभुज के लिए काम करता है! बाह्य कोण = विपरीत आंतरिक कोणों का योग।",

    's4_title': "4. कोण वास्तुकार (अनसुलझी)",
    's4_obj': "दो दिए गए आंतरिक कोणों को मिलाकर एक बाह्य कोण का निर्माण करना।",
    's4_step1':
        "कार्य: त्रिभुज बनाने के लिए लाल टुकड़े को शीर्ष A पर और पीले टुकड़े को शीर्ष B पर खींचें।\nअवलोकन: टुकड़े अपनी जगह पर आ जाते हैं, जिससे एक त्रिभुज ABC बनता है।\nसीखा: हम एक त्रिभुज का निर्माण उसके आधार कोणों से शुरू कर सकते हैं।",
    's4_step2':
        "कार्य: अपने लाल और पीले टुकड़ों की प्रतियां खाली बाह्य कोण होल्डर में खींचें।\nअवलोकन: लाल और पीले टुकड़े होल्डर के अंदर एक साथ जुड़ जाते हैं।\nसीखा: यह संयुक्त आकार वास्तविक बाह्य कोण के लिए हमारी भविष्यवाणी है।",
    's4_step3':
        "कार्य: 'मेरी भविष्यवाणी जाँचें' बटन पर क्लिक करें।\nअवलोकन: वास्तविक बाह्य कोण प्रकट होता है और हमारी भविष्यवाणी से पूरी तरह मेल खाता है।\nसीखा: हम सीधे मापे बिना बाह्य कोण की सटीक गणना कर सकते हैं।",
    's4_sum': "आपकी भविष्यवाणी सही थी! आपने प्रमेय का पूरी तरह से उपयोग किया।",

    's5_title': "5. त्रिभुज बैलेंसर (अनसुलझी)",
    's5_obj':
        "एक बाह्य कोण के साथ इसे संतुलित करके एक लापता दूरस्थ आंतरिक कोण का माप खोजना।",
    's5_step1':
        "कार्य: घोस्ट कोण ∠B का आकार बदलने के लिए हैंडल को तब तक खींचें जब तक कि हरा पहेली का टुकड़ा बाह्य कोण को पूरी तरह से भर न दे।\nअवलोकन: जब आप ∠B को समायोजित करते हैं तो बाह्य कोण के अंदर हरा पहेली का टुकड़ा गतिशील रूप से आकार बदलता है।\nसीखा: आंतरिक कोण को बदलने से बाह्य कोण में उसका संगत भाग सीधे प्रभावित होता है।",
    's5_step2':
        "कार्य: जब हरा टुकड़ा बचे हुए बैंगनी स्थान को पूरी तरह से भर दे, तो 'सत्यापित करें' पर क्लिक करें।\nअवलोकन: त्रिभुज अपनी जगह पर लॉक हो जाता है, फिट की पुष्टि करता है।\nसीखा: यदि हम बाह्य कोण और अन्य आंतरिक कोण को जानते हैं तो हम लापता आंतरिक कोण का पता लगा सकते हैं।",
    's5_sum': "संतुलित! आपने गुण का उपयोग करके सटीक लापता कोण पाया।",
  },
};

// --- MAIN SCREEN ---

class ExteriorAnglesofTriangle extends StatefulWidget {
  const ExteriorAnglesofTriangle({super.key});

  @override
  _ExteriorAnglesofTriangleState createState() =>
      _ExteriorAnglesofTriangleState();
}

class _ExteriorAnglesofTriangleState extends State<ExteriorAnglesofTriangle>
    with SingleTickerProviderStateMixin {
  // Configs
  final Map<int, ScenarioConfig> _scenarios = {
    1: ScenarioConfig(110, 50, 60, 'acute'),
    2: ScenarioConfig(130, 40, 90, 'right'),
    3: ScenarioConfig(140, 30, 110, 'obtuse'),
    4: ScenarioConfig(110, 60, 50, 'construct', true),
    5: ScenarioConfig(120, 45, 75, 'balance', true),
  };

  // State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  int _scenario = 1;
  String _phase = 'init';

  double _zoom = 1.0;
  Offset _pan = const Offset(0, 20);

  GeomPoint? _geomA, _geomB, _geomC, _geomD;
  List<AnglePiece> _pieces = [];
  List<AnglePiece> _initialPieces = [];
  AnglePiece? _draggedPiece;
  String? _draggedVertex;

  double _userAngleB = 30;
  bool _showSuccessPopup = false;
  bool _isPlayingCurtain = true;

  Offset _compactStepPos = const Offset(20, 80);
  Offset? _popupPos;

  // Animation
  late AnimationController _animCtrl;
  double _animProgress = 0.0;

  // Dedicated Audio Players
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

  // Network Audio Sources
  static const String _clickUrl =
      'audio/class7/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class7/mixkit_955.mp3';
  static const String _alertUrl =
      'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animCtrl.addListener(() {
      setState(() {
        _animProgress = _animCtrl.value;
        if (_animProgress == 1.0 && _phase == 'animating') {
          _completeAnimation();
        }
      });
    });

    _initAudio();
    _loadScenario(1);

    _playSound('shutter');
  }

  void _initAudio() async {
    await _clickPlayer.setSourceAsset(_clickUrl);
    await _successPlayer.setSourceAsset(_successUrl);
    await _errorPlayer.setSourceAsset(_errorUrl);
    await _fxPlayer.setSourceAsset(_alertUrl);
    await _shutterPlayer.setSourceAsset(_shutterUrl);
  }

  void _playSound(String type) {
    try {
      if (type == 'click') _clickPlayer.resume();
      if (type == 'snap') _fxPlayer.resume();
      if (type == 'success') _successPlayer.resume();
      if (type == 'error') _errorPlayer.resume();
      if (type == 'shutter') _shutterPlayer.resume();
    } catch (e) {
      // Audio failed, fail silently
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String t(String key) {
    return translations[_lang]?[key] ?? translations['en']?[key] ?? key;
  }

  void _cycleLanguage() {
    setState(() {
      if (_lang == 'en') {
        _lang = 'hi';
      } else {
        _lang = 'en';
      }
    });
    _playSound('click');
  }

  void _calculateGeom(ScenarioConfig cfg) {
    _geomC = GeomPoint(0, 0);
    _geomD = GeomPoint(150, 0);

    if (cfg.type == 'construct') {
      _geomA = GeomPoint(-120, 50);
      _geomB = GeomPoint(120, 50);
      double radA = -cfg.a * math.pi / 180;
      double radB = -(180 - cfg.b) * math.pi / 180;

      double tanA = math.tan(radA);
      double tanB = math.tan(radB);
      double cx =
          (_geomB!.x * tanB - _geomA!.x * tanA - _geomB!.y + _geomA!.y) /
          (tanB - tanA);
      double cy = _geomA!.y + (cx - _geomA!.x) * tanA;
      _geomC = GeomPoint(cx, cy);
      _geomD = null;
    } else if (cfg.type == 'balance') {
      _geomA = GeomPoint(
        160 * math.cos(-120 * math.pi / 180),
        160 * math.sin(-120 * math.pi / 180),
      );
      _geomB = GeomPoint(-117.13, 0);
    } else {
      _geomB = GeomPoint(-150, 0);
      double aCA = -cfg.ext * math.pi / 180;
      double aBA = -cfg.b * math.pi / 180;
      double tanCA = math.tan(aCA);
      double tanBA = math.tan(aBA);
      double ax = (150 * tanBA) / (tanCA - tanBA);
      double ay = ax * tanCA;
      _geomA = GeomPoint(ax, ay);
    }
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _phase = 'init';
      _pieces = [];
      _initialPieces = [];
      _draggedPiece = null;
      _userAngleB = 30;
      _showSuccessPopup = false;
      _popupPos = null;
      _pan = const Offset(0, 20);
      _zoom = 1.0;

      ScenarioConfig cfg = _scenarios[_scenario]!;
      _calculateGeom(cfg);

      if (_scenario <= 3) {
        double startB =
            math.atan2(_geomA!.y - _geomB!.y, _geomA!.x - _geomB!.x) *
            180 /
            math.pi;
        double endB =
            math.atan2(_geomC!.y - _geomB!.y, _geomC!.x - _geomB!.x) *
            180 /
            math.pi;
        if (startB > endB) {
          double t = startB;
          startB = endB;
          endB = t;
        }

        double startA =
            math.atan2(_geomC!.y - _geomA!.y, _geomC!.x - _geomA!.x) *
            180 /
            math.pi;
        double endA =
            math.atan2(_geomB!.y - _geomA!.y, _geomB!.x - _geomA!.x) *
            180 /
            math.pi;
        if (startA > endA) {
          double t = startA;
          startA = endA;
          endA = t;
        }

        _initialPieces = [
          AnglePiece(
            id: 'A',
            val: cfg.a,
            color: const Color(0xFF3b82f6),
            start: startA,
            end: endA,
            x: _geomA!.x,
            y: _geomA!.y,
          ),
          AnglePiece(
            id: 'B',
            val: cfg.b,
            color: const Color(0xFF10b981),
            start: startB,
            end: endB,
            x: _geomB!.x,
            y: _geomB!.y,
            isSquare: _scenario == 2,
          ),
        ];
        if (_scenario == 2) {
          _initialPieces[1].start = -90;
          _initialPieces[1].end = 0;
          _initialPieces[1].val = 90;
        }
      } else if (_scenario == 4) {
        _pieces = [
          AnglePiece(
            id: 'A_piece',
            val: cfg.a,
            color: const Color(0xFFf43f5e),
            start: 0,
            end: -cfg.a,
            x: -50,
            y: 130,
            targetVertex: 'left',
          ),
          AnglePiece(
            id: 'B_piece',
            val: cfg.b,
            color: const Color(0xFFeab308),
            start: 180,
            end: 180 - cfg.b,
            x: 50,
            y: 130,
            targetVertex: 'right',
          ),
          AnglePiece(
            id: 'A_clone',
            val: cfg.a,
            color: const Color(0xFFf43f5e),
            start: 0,
            end: -cfg.a,
            x: -50,
            y: 130,
            isClone: true,
          ),
          AnglePiece(
            id: 'B_clone',
            val: cfg.b,
            color: const Color(0xFFeab308),
            start: 180,
            end: 180 - cfg.b,
            x: 50,
            y: 130,
            isClone: true,
          ),
        ];
      } else if (_scenario == 5) {
        _phase = 'adjusting';
      }
    });
    _playSound('click');
  }

  void _triggerExtend() {
    setState(() {
      _phase = 'extended';
    });
    _playSound('snap');
  }

  void _triggerPuzzles() {
    setState(() {
      _phase = 'puzzles';
      ScenarioConfig cfg = _scenarios[_scenario]!;

      double startB =
          math.atan2(_geomA!.y - _geomB!.y, _geomA!.x - _geomB!.x) *
          180 /
          math.pi;
      double endB =
          math.atan2(_geomC!.y - _geomB!.y, _geomC!.x - _geomB!.x) *
          180 /
          math.pi;
      if (startB > endB) {
        double t = startB;
        startB = endB;
        endB = t;
      }

      double startA =
          math.atan2(_geomC!.y - _geomA!.y, _geomC!.x - _geomA!.x) *
          180 /
          math.pi;
      double endA =
          math.atan2(_geomB!.y - _geomA!.y, _geomB!.x - _geomA!.x) *
          180 /
          math.pi;
      if (startA > endA) {
        double t = startA;
        startA = endA;
        endA = t;
      }

      _pieces = [
        AnglePiece(
          id: 'A',
          val: cfg.a,
          color: const Color(0xFF3b82f6),
          start: startA,
          end: endA,
          x: _geomA!.x - 30,
          y: _geomA!.y + 40,
          detached: true,
        ),
        AnglePiece(
          id: 'B',
          val: cfg.b,
          color: const Color(0xFF10b981),
          start: startB,
          end: endB,
          x: _geomB!.x + 30,
          y: _geomB!.y - 40,
          detached: true,
          isSquare: _scenario == 2,
        ),
      ];

      if (_scenario == 2) {
        _pieces[1].start = -90;
        _pieces[1].end = 0;
        _pieces[1].val = 90;
      }
    });
    _playSound('click');
  }

  void _triggerVerifyOrPredict() {
    setState(() {
      _phase = 'animating';
      _animProgress = 0.0;
      _animCtrl.forward(from: 0.0);
    });
    _playSound('click');
  }

  void _completeAnimation() {
    setState(() {
      _phase = 'complete';
      if (_scenario == 4) {
        for (var p in _pieces) {
          if (p.isClone) {
            p.x = _geomC!.x;
            p.y = _geomC!.y;
          }
        }
      }
    });
    _playSound('success');
  }

  GeomPoint _getHolderPos() {
    return GeomPoint(_geomC!.x + 80, _geomC!.y - 30);
  }

  void _handlePanDown(DragDownDetails details, Size size) {
    if (_phase == 'animating' || _phase == 'complete') return;

    double worldX =
        (details.localPosition.dx - size.width / 2 - _pan.dx) / _zoom;
    double worldY =
        (details.localPosition.dy - size.height / 2 - _pan.dy) / _zoom;

    setState(() {
      if (_scenario < 4 && _phase == 'puzzles') {
        var hit =
            _pieces
                .where(
                  (p) =>
                      !p.detached &&
                      Offset(worldX - p.x, worldY - p.y).distance < 40,
                )
                .firstOrNull;
        if (hit != null) {
          _playSound('click');
          hit.detached = true;
          _draggedPiece = hit;
        } else {
          hit =
              _pieces
                  .where(
                    (p) =>
                        p.detached &&
                        Offset(worldX - p.x, worldY - p.y).distance < 50,
                  )
                  .firstOrNull;
          if (hit != null) {
            _draggedPiece = hit;
            _playSound('click');
          }
        }
      } else if (_scenario < 4 && _phase == 'drag_1') {
        var hit =
            _pieces
                .where(
                  (p) =>
                      p.detached &&
                      !p.snapped &&
                      Offset(worldX - p.x, worldY - p.y).distance < 50,
                )
                .firstOrNull;
        if (hit != null) {
          _draggedPiece = hit;
          _playSound('click');
        }
      } else if (_scenario == 4) {
        if (_phase == 'init' || _phase == 'drag_1') {
          var hit =
              _pieces
                  .where(
                    (p) =>
                        !p.snapped &&
                        !p.isClone &&
                        Offset(worldX - p.x, worldY - p.y).distance < 50,
                  )
                  .firstOrNull;
          if (hit != null) {
            _draggedPiece = hit;
            _playSound('click');
          }
        } else if (_phase == 'predict_drag' || _phase == 'predict_1') {
          var hit =
              _pieces
                  .where(
                    (p) =>
                        p.isClone &&
                        !p.snapped &&
                        Offset(worldX - p.x, worldY - p.y).distance < 50,
                  )
                  .firstOrNull;
          if (hit != null) {
            _draggedPiece = hit;
            _playSound('click');
          }
        }
      } else if (_scenario == 5 && _phase == 'adjusting') {
        double uAng = _userAngleB;
        double hx = _geomB!.x + 80 * math.cos(-uAng * math.pi / 180);
        double hy = _geomB!.y + 80 * math.sin(-uAng * math.pi / 180);
        if (Offset(worldX - hx, worldY - hy).distance < 40) {
          _draggedVertex = 'B_handle';
          _playSound('click');
        }
      }
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      if (_draggedPiece != null) {
        _draggedPiece!.x += details.delta.dx / _zoom;
        _draggedPiece!.y += details.delta.dy / _zoom;
      } else if (_draggedVertex == 'B_handle' && _scenario == 5) {
        double worldX =
            (details.localPosition.dx - size.width / 2 - _pan.dx) / _zoom;
        double worldY =
            (details.localPosition.dy - size.height / 2 - _pan.dy) / _zoom;

        double ang =
            -math.atan2(worldY - _geomB!.y, worldX - _geomB!.x) * 180 / math.pi;
        if (ang < 0) ang += 360;
        ang = math.max(10, math.min(110, ang));

        if ((ang - 75).abs() < 3.0) {
          _userAngleB = 75;
          _draggedVertex = null;
          _phase = 'locked';
          _playSound('snap');
        } else {
          _userAngleB = ang;
        }
      } else {
        // Pan the canvas
        _pan += details.delta;
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_draggedPiece != null) {
      AnglePiece p = _draggedPiece!;
      setState(() {
        if (_scenario < 4) {
          if (Offset(p.x - _geomC!.x, p.y - _geomC!.y).distance < 60) {
            p.snapped = true;
            p.x = _geomC!.x;
            p.y = _geomC!.y;

            List<AnglePiece> snapped =
                _pieces.where((sp) => sp.snapped).toList();
            double acc = -_scenarios[_scenario]!.ext;
            for (var sp in snapped) {
              sp.start = acc;
              acc += sp.val;
              sp.end = acc;
            }

            _playSound('snap');
            if (snapped.length == 2) {
              _phase = 'complete';
              _playSound('success');
            } else {
              if (_phase == 'puzzles') _phase = 'drag_1';
            }
          } else {
            _playSound('error');
          }
        } else if (_scenario == 4) {
          if (_phase == 'init' || _phase == 'drag_1') {
            GeomPoint target = p.targetVertex == 'left' ? _geomA! : _geomB!;
            if (Offset(p.x - target.x, p.y - target.y).distance < 60) {
              p.snapped = true;
              p.x = target.x;
              p.y = target.y;
              _playSound('snap');

              var snapped =
                  _pieces.where((sp) => sp.snapped && !sp.isClone).toList();
              if (snapped.length == 2) {
                _phase = 'triangle_built';
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted)
                    setState(() {
                      _phase = 'predict_drag';
                    });
                });
              } else {
                _phase = 'drag_1';
              }
            } else {
              _playSound('error');
            }
          } else if (_phase == 'predict_drag' || _phase == 'predict_1') {
            GeomPoint hPos = _getHolderPos();
            if (Offset(p.x - hPos.x, p.y - hPos.y).distance < 60) {
              p.snapped = true;
              p.x = hPos.x;
              p.y = hPos.y;
              p.origX = hPos.x;
              p.origY = hPos.y;

              var snapped =
                  _pieces.where((sp) => sp.snapped && sp.isClone).toList();
              double radAC =
                  math.atan2(_geomC!.y - _geomA!.y, _geomC!.x - _geomA!.x) *
                  180 /
                  math.pi;
              double radBC =
                  math.atan2(_geomB!.y - _geomC!.y, _geomB!.x - _geomC!.x) *
                  180 /
                  math.pi;
              double extStart = math.min(radAC, radBC);

              double acc = extStart;
              snapped.sort((a, b) => a.id == 'A_clone' ? -1 : 1);
              for (var sp in snapped) {
                sp.start = acc;
                acc += sp.val;
                sp.end = acc;
              }

              _playSound('snap');
              if (snapped.length == 2) {
                _phase = 'predict_done';
              } else {
                _phase = 'predict_1';
              }
            } else {
              _playSound('error');
            }
          }
        }
      });
      _draggedPiece = null;
    }
    _draggedVertex = null;
  }

  int _getPseudoStep() {
    int pseudoStep = 0;
    if (_scenario == 1) {
      if (_phase == 'extended') {
        pseudoStep = 1;
      } else if (_phase == 'puzzles')
        pseudoStep = 2;
      else if (_phase == 'drag_1')
        pseudoStep = 3;
      else if (_phase == 'complete')
        pseudoStep = 4;
    } else if (_scenario == 2 || _scenario == 3) {
      if (_phase == 'extended') {
        pseudoStep = 1;
      } else if (_phase == 'puzzles' || _phase == 'drag_1')
        pseudoStep = 2;
      else if (_phase == 'complete')
        pseudoStep = 3;
    } else if (_scenario == 4) {
      if (_phase == 'triangle_built' ||
          _phase == 'predict_drag' ||
          _phase == 'predict_1') {
        pseudoStep = 1;
      } else if (_phase == 'predict_done' || _phase == 'animating')
        pseudoStep = 2;
      else if (_phase == 'complete')
        pseudoStep = 3;
    } else if (_scenario == 5) {
      if (_phase == 'locked' || _phase == 'animating') {
        pseudoStep = 1;
      } else if (_phase == 'complete')
        pseudoStep = 2;
    }
    return pseudoStep;
  }

  Widget _buildSidebar(double width) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: _isSidebarOpen ? 0 : -width,
      top: 0,
      bottom: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b).withOpacity(0.95),
          border: Border(
            right: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Language/Reset
              Container(
                padding: const EdgeInsets.only(
                  top: 80,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ), // Adjusted top padding to avoid icon overlap
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.change_history,
                          color: Color(0xFF6366f1),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('appTitle'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t('appSubtitle'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.language,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            _lang.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: _cycleLanguage,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          label: Text(
                            t('restartLab'),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            _playSound('shutter');
                            setState(() {
                              _lang = 'en';
                              _isPlayingCurtain = true;
                            });
                            _loadScenario(1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scenario Dropdown Selection in Sidebar
                    Text(
                      t('selectScenario'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _scenario,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1e293b),
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          items:
                              [1, 2, 3, 4, 5].map((id) {
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(t('s${id}_title')),
                                );
                              }).toList(),
                          onChanged: (val) {
                            if (val != null) _loadScenario(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Objective
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f172a).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.track_changes,
                                color: Color(0xFF6366f1),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('objectiveLbl'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('s${_scenario}_obj'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Steps Display
                    _buildStepsList(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    int pseudoStep = _getPseudoStep();
    List<Widget> stepWidgets = [];
    int maxSteps = (_scenario == 1) ? 3 : (_scenario == 5 ? 2 : 3);

    for (int i = 0; i < maxSteps; i++) {
      bool isCompleted = i < pseudoStep;
      bool isActive = i == pseudoStep;

      Color bgColor =
          isActive
              ? const Color(0xFF6366f1).withOpacity(0.2)
              : (isCompleted ? Colors.black26 : Colors.transparent);
      Color borderColor =
          isActive ? const Color(0xFF6366f1) : Colors.white.withOpacity(0.1);

      stepWidgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isCompleted
                  ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  )
                  : Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isActive ? const Color(0xFF6366f1) : Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                      "${t('stepLabel')} ${i + 1}",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('s${_scenario}_step${i + 1}'),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_phase == 'complete') {
      stepWidgets.add(
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t('completed'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t('s${_scenario}_sum'),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: stepWidgets);
  }

  Widget _buildActionButtons() {
    Widget? btn;
    if (_scenario < 4) {
      if (_phase == 'init') {
        btn = _customButton(
          t('extendBtn'),
          Icons.arrow_right_alt,
          Colors.blue,
          _triggerExtend,
        );
      } else if (_phase == 'extended') {
        btn = _customButton(
          t('puzzlesBtn'),
          Icons.extension,
          Colors.indigo,
          _triggerPuzzles,
        );
      }
    } else if (_scenario == 4) {
      if (_phase == 'predict_done') {
        btn = _customButton(
          t('checkPredBtn'),
          Icons.search,
          Colors.amber,
          _triggerVerifyOrPredict,
        );
      }
    } else if (_scenario == 5) {
      if (_phase == 'locked') {
        btn = _customButton(
          t('verifyBtn'),
          Icons.check_circle_outline,
          Colors.indigo,
          _triggerVerifyOrPredict,
        );
      }
    }

    if (_phase == 'complete') {
      if (_scenario < 5) {
        btn = _customButton(
          t('nextScenario'),
          Icons.navigate_next,
          Colors.green,
          () => _loadScenario(_scenario + 1),
        );
      } else {
        btn = _customButton(t('doneBtn'), Icons.done_all, Colors.green, () {
          setState(() {
            _showSuccessPopup = true;
          });
          _playSound('success');
        });
      }
    }

    return btn ?? const SizedBox.shrink();
  }

  Widget _customButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sidebarWidth = screenWidth * 0.38;
    if (sidebarWidth < 300) sidebarWidth = 300;

    int pseudoStep = _getPseudoStep();

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // Canvas Layer
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  Size canvasSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    onPanDown: (d) => _handlePanDown(d, canvasSize),
                    onPanUpdate: (d) => _handlePanUpdate(d, canvasSize),
                    onPanEnd: (d) => _handlePanEnd(d),
                    child: CustomPaint(
                      painter: GeometryPainter(
                        geomA: _geomA,
                        geomB: _geomB,
                        geomC: _geomC,
                        geomD: _geomD,
                        pieces: _pieces,
                        initialPieces: _initialPieces,
                        scenario: _scenario,
                        phase: _phase,
                        userAngleB: _userAngleB,
                        draggedPiece: _draggedPiece,
                        zoom: _zoom,
                        pan: _pan,
                        config: _scenarios[_scenario]!,
                        animProgress: _animProgress,
                        draggedVertex: _draggedVertex,
                      ),
                      size: Size.infinite,
                    ),
                  );
                },
              ),
            ),

            // Sidebar Layer
            _buildSidebar(sidebarWidth),

            // Action Buttons Overlay on Canvas
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 40,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: Center(child: _buildActionButtons()),
            ),

            // Top Left Controls Stack (Menu Only)
            Positioned(
              top: 16,
              left: 16, // Fixed position, won't slide with sidebar
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                  _playSound('click');
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // Compact Active Step Tracker on Canvas (When Sidebar is Closed)
            if (!_isSidebarOpen &&
                _phase != 'complete' &&
                _phase != 'animating')
              Positioned(
                left: _compactStepPos.dx,
                top: _compactStepPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _compactStepPos += details.delta;
                    });
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e293b).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6366f1).withOpacity(0.5),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.drag_indicator,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${t('stepLabel')} ${pseudoStep + 1}",
                              style: const TextStyle(
                                color: Color(0xFF6366f1),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('s${_scenario}_step${pseudoStep + 1}'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Curtain Layer
            if (_isPlayingCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.change_history,
                        size: 80,
                        color: Color(0xFF6366f1),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t('appTitle'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t('appSubtitle'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 28,
                        ),
                        label: Text(
                          t('enterLab'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366f1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () {
                          _playSound('click');
                          setState(() {
                            _isPlayingCurtain = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Success Popup Layer
            if (_showSuccessPopup)
              Positioned(
                left: _popupPos?.dx ?? (screenWidth - 400) / 2,
                top: _popupPos?.dy ?? (screenHeight - 350) / 2,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _popupPos =
                          (_popupPos ??
                              Offset(
                                (screenWidth - 400) / 2,
                                (screenHeight - 350) / 2,
                              )) +
                          details.delta;
                    });
                  },
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e293b).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 20),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -16,
                          right: -16,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showSuccessPopup = false;
                              });
                              _playSound('click');
                            },
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t('successTitle'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t('successDesc'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              label: Text(
                                t('restartLab'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366f1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                _playSound('shutter');
                                setState(() {
                                  _showSuccessPopup = false;
                                  _lang = 'en';
                                  _isPlayingCurtain = true;
                                });
                                _loadScenario(1);
                              },
                            ),
                          ],
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

// --- CANVAS DRAWING (CUSTOM PAINTER) ---

class GeometryPainter extends CustomPainter {
  final GeomPoint? geomA, geomB, geomC, geomD;
  final List<AnglePiece> pieces;
  final List<AnglePiece> initialPieces;
  final int scenario;
  final String phase;
  final double userAngleB;
  final AnglePiece? draggedPiece;
  final double zoom;
  final Offset pan;
  final ScenarioConfig config;
  final double animProgress;
  final String? draggedVertex;

  GeometryPainter({
    required this.geomA,
    required this.geomB,
    required this.geomC,
    required this.geomD,
    required this.pieces,
    required this.initialPieces,
    required this.scenario,
    required this.phase,
    required this.userAngleB,
    required this.draggedPiece,
    required this.zoom,
    required this.pan,
    required this.config,
    required this.animProgress,
    required this.draggedVertex,
  });

  void drawAnglePiece(
    Canvas canvas,
    AnglePiece p, {
    bool isGhost = false,
    bool fillOnly = false,
  }) {
    double radS = p.start * math.pi / 180;
    double radE = p.end * math.pi / 180;

    double sweep = radE - radS;

    Paint paint =
        Paint()
          ..color = p.color.withOpacity(isGhost ? 0.3 : 0.85)
          ..style = PaintingStyle.fill;

    if (p.isSquare &&
        !p.snapped &&
        !p.isClone &&
        phase != 'animating' &&
        phase != 'complete') {
      double dist = 35;
      Path path = Path();
      path.moveTo(p.x, p.y);
      path.lineTo(p.x + dist * math.cos(radS), p.y + dist * math.sin(radS));
      path.lineTo(
        p.x + dist * math.cos(radS) + dist * math.cos(radE),
        p.y + dist * math.sin(radS) + dist * math.sin(radE),
      );
      path.lineTo(p.x + dist * math.cos(radE), p.y + dist * math.sin(radE));
      path.close();
      canvas.drawPath(path, paint);

      if (!fillOnly) {
        paint
          ..style = PaintingStyle.stroke
          ..color = p.color
          ..strokeWidth = 2.0;
        canvas.drawPath(path, paint);
      }
    } else {
      double r = 45;
      if (p.val > 100 && scenario == 5) r = 60; // Just visual tweaks
      canvas.drawArc(
        Rect.fromCircle(center: Offset(p.x, p.y), radius: r),
        radS,
        sweep,
        true,
        paint,
      );

      if (!fillOnly) {
        paint
          ..style = PaintingStyle.stroke
          ..color = p.color
          ..strokeWidth = 2.0;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(p.x, p.y), radius: r),
          radS,
          sweep,
          true,
          paint,
        );
      }
    }

    if (!fillOnly && p.val > 0) {
      double midRad = radS + sweep / 2;
      double textDist = p.isSquare && !p.snapped ? 20 : 45 * 0.6;
      TextSpan span = TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        text: "${p.val.round()}°",
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          p.x + textDist * math.cos(midRad) - tp.width / 2,
          p.y + textDist * math.sin(midRad) - tp.height / 2,
        ),
      );
    }
  }

  void drawVertexLabel(
    Canvas canvas,
    String text,
    Offset pos, {
    Offset offset = Offset.zero,
  }) {
    TextSpan span = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        pos.dx + offset.dx - tp.width / 2,
        pos.dy + offset.dy - tp.height / 2,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Constant Dark Canvas Background
    Paint bgPaint =
        Paint()
          ..color = const Color(0xFF020617)
          ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Background Grid
    Paint gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += 30) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom);

    if (geomA == null || geomB == null || geomC == null) return;

    Paint linePaint =
        Paint()
          ..color = const Color(0xFF6366f1).withOpacity(0.8)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;
    Paint fillPaint =
        Paint()
          ..color = const Color(0xFF6366f1).withOpacity(0.1)
          ..style = PaintingStyle.fill;
    Paint vertexPaint =
        Paint()
          ..color = const Color(0xFF6366f1)
          ..style = PaintingStyle.fill;

    // Scenarios 1-3 & 5
    if (scenario < 4 || scenario == 5) {
      Path triPath =
          Path()
            ..moveTo(geomB!.x, geomB!.y)
            ..lineTo(geomC!.x, geomC!.y)
            ..lineTo(geomA!.x, geomA!.y)
            ..close();
      canvas.drawPath(triPath, linePaint);
      canvas.drawPath(triPath, fillPaint);

      canvas.drawCircle(Offset(geomA!.x, geomA!.y), 6, vertexPaint);
      canvas.drawCircle(Offset(geomB!.x, geomB!.y), 6, vertexPaint);
      canvas.drawCircle(Offset(geomC!.x, geomC!.y), 6, vertexPaint);

      if (phase != 'init' && geomD != null) {
        Paint dashPaint =
            Paint()
              ..color = Colors.grey
              ..strokeWidth = 3
              ..style = PaintingStyle.stroke;
        _drawDashedLine(
          canvas,
          Offset(geomC!.x, geomC!.y),
          Offset(geomD!.x, geomD!.y),
          dashPaint,
        );

        AnglePiece extA = AnglePiece(
          id: 'ext',
          val: config.ext,
          color: const Color(0xFF64748b),
          start: -config.ext,
          end: 0,
          x: geomC!.x,
          y: geomC!.y,
        );
        drawAnglePiece(canvas, extA, isGhost: true);
      }
    }

    // Scenario 4 (Construct)
    if (scenario == 4) {
      if (phase == 'init' || phase == 'drag_1') {
        canvas.drawLine(
          Offset(geomA!.x, geomA!.y),
          Offset(geomB!.x, geomB!.y),
          linePaint,
        );

        if (pieces.isNotEmpty) {
          if (pieces[0].snapped) {
            _drawDashedLine(
              canvas,
              Offset(geomA!.x, geomA!.y),
              Offset(geomC!.x, geomC!.y),
              Paint()
                ..color = const Color(0xFF6366f1).withOpacity(0.5)
                ..strokeWidth = 2,
            );
          }
          if (pieces[1].snapped) {
            _drawDashedLine(
              canvas,
              Offset(geomB!.x, geomB!.y),
              Offset(geomC!.x, geomC!.y),
              Paint()
                ..color = const Color(0xFF6366f1).withOpacity(0.5)
                ..strokeWidth = 2,
            );
          }
          drawAnglePiece(canvas, pieces[0]);
          drawAnglePiece(canvas, pieces[1]);
        }
        canvas.drawCircle(Offset(geomA!.x, geomA!.y), 6, vertexPaint);
        canvas.drawCircle(Offset(geomB!.x, geomB!.y), 6, vertexPaint);
      } else {
        Path triPath =
            Path()
              ..moveTo(geomA!.x, geomA!.y)
              ..lineTo(geomC!.x, geomC!.y)
              ..lineTo(geomB!.x, geomB!.y)
              ..close();
        canvas.drawPath(triPath, linePaint);
        canvas.drawPath(triPath, fillPaint);

        canvas.drawCircle(Offset(geomA!.x, geomA!.y), 6, vertexPaint);
        canvas.drawCircle(Offset(geomB!.x, geomB!.y), 6, vertexPaint);
        canvas.drawCircle(Offset(geomC!.x, geomC!.y), 6, vertexPaint);

        double radAC = math.atan2(geomC!.y - geomA!.y, geomC!.x - geomA!.x);
        double radBC = math.atan2(geomB!.y - geomC!.y, geomB!.x - geomC!.x);

        double dx = geomC!.x + 150 * math.cos(radAC);
        double dy = geomC!.y + 150 * math.sin(radAC);

        if (phase == 'animating' || phase == 'complete') {
          _drawDashedLine(
            canvas,
            Offset(geomC!.x, geomC!.y),
            Offset(dx, dy),
            Paint()
              ..color = Colors.grey
              ..strokeWidth = 3,
          );
          AnglePiece trueExt = AnglePiece(
            id: 'trueExt',
            val: config.ext,
            color: const Color(0xFF64748b),
            start: radAC * 180 / math.pi,
            end: radBC * 180 / math.pi,
            x: geomC!.x,
            y: geomC!.y,
          );
          if (trueExt.start > trueExt.end) {
            double t = trueExt.start;
            trueExt.start = trueExt.end;
            trueExt.end = t;
          }
          drawAnglePiece(canvas, trueExt, isGhost: true);
        }

        GeomPoint hPos = GeomPoint(geomC!.x + 80, geomC!.y - 30);
        if (phase != 'animating' && phase != 'complete') {
          AnglePiece holderExt = AnglePiece(
            id: 'holder',
            val: 0,
            color: const Color(0xFF475569),
            start: radAC * 180 / math.pi,
            end: radBC * 180 / math.pi,
            x: hPos.x,
            y: hPos.y,
          );
          if (holderExt.start > holderExt.end) {
            double t = holderExt.start;
            holderExt.start = holderExt.end;
            holderExt.end = t;
          }
          drawAnglePiece(canvas, holderExt, isGhost: true, fillOnly: true);
        }

        if (phase != 'animating') {
          for (var p in pieces.where((p) => p.isClone)) {
            drawAnglePiece(canvas, p);
          }
        }

        if (phase == 'animating') {
          double e =
              animProgress < 0.5
                  ? 2 * animProgress * animProgress
                  : -1 + (4 - 2 * animProgress) * animProgress;

          double hx = hPos.x + (geomC!.x - hPos.x) * e;
          double hy = hPos.y + (geomC!.y - hPos.y) * e;

          AnglePiece ext = AnglePiece(
            id: 'animExt',
            val: 0,
            color: const Color(0xFF475569),
            start: radAC * 180 / math.pi,
            end: radBC * 180 / math.pi,
            x: hx,
            y: hy,
          );
          if (ext.start > ext.end) {
            double t = ext.start;
            ext.start = ext.end;
            ext.end = t;
          }
          drawAnglePiece(canvas, ext, isGhost: true, fillOnly: true);

          for (var p in pieces.where((p) => p.isClone)) {
            AnglePiece cp = p.clone();
            cp.x = p.origX + (geomC!.x - p.origX) * e;
            cp.y = p.origY + (geomC!.y - p.origY) * e;
            drawAnglePiece(canvas, cp);
          }
        }

        drawAnglePiece(canvas, pieces[0]);
        drawAnglePiece(canvas, pieces[1]);
      }
    }

    // Scenario 5 (Balance)
    if (scenario == 5) {
      AnglePiece extA = AnglePiece(
        id: 'ext5',
        val: 120,
        color: const Color(0xFFa855f7),
        start: -120,
        end: 0,
        x: geomC!.x,
        y: geomC!.y,
      );
      drawAnglePiece(canvas, extA, isGhost: true);

      double radCA =
          math.atan2(geomC!.y - geomA!.y, geomC!.x - geomA!.x) * 180 / math.pi;
      double radBA =
          math.atan2(geomB!.y - geomA!.y, geomB!.x - geomA!.x) * 180 / math.pi;
      AnglePiece pA = AnglePiece(
        id: 'pA',
        val: 45,
        color: const Color(0xFF3b82f6),
        start: radCA,
        end: radBA,
        x: geomA!.x,
        y: geomA!.y,
      );
      drawAnglePiece(canvas, pA);

      AnglePiece pAExt = AnglePiece(
        id: 'pAExt',
        val: 45,
        color: const Color(0xFF3b82f6),
        start: -45,
        end: 0,
        x: geomC!.x,
        y: geomC!.y,
      );
      drawAnglePiece(canvas, pAExt);

      AnglePiece pB = AnglePiece(
        id: 'pB',
        val: userAngleB,
        color: const Color(0xFF10b981),
        start: -userAngleB,
        end: 0,
        x: geomB!.x,
        y: geomB!.y,
      );
      drawAnglePiece(canvas, pB);

      if (phase == 'adjusting') {
        double hx = geomB!.x + 80 * math.cos(-userAngleB * math.pi / 180);
        double hy = geomB!.y + 80 * math.sin(-userAngleB * math.pi / 180);
        _drawDashedLine(
          canvas,
          Offset(geomB!.x, geomB!.y),
          Offset(hx, hy),
          Paint()
            ..color = const Color(0xFF10b981)
            ..strokeWidth = 3,
        );

        canvas.drawCircle(
          Offset(hx, hy),
          12,
          Paint()..color = const Color(0xFF10b981),
        );
        canvas.drawCircle(
          Offset(hx, hy),
          12,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );

        double pulse =
            1 +
            (math.sin(DateTime.now().millisecondsSinceEpoch / 200).abs() * 0.2);
        canvas.drawCircle(
          Offset(hx, hy),
          20 * pulse,
          Paint()
            ..color = const Color(0xFF10b981).withOpacity(0.5)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }

      AnglePiece pBExt = AnglePiece(
        id: 'pBExt',
        val: userAngleB,
        color: const Color(0xFF10b981),
        start: -45 - userAngleB,
        end: -45,
        x: geomC!.x,
        y: geomC!.y,
      );
      drawAnglePiece(canvas, pBExt);

      if (phase == 'animating') {
        double e =
            animProgress < 0.5
                ? 2 * animProgress * animProgress
                : -1 + (4 - 2 * animProgress) * animProgress;

        AnglePiece movA = pA.clone();
        movA.x = pA.x + (pAExt.x - pA.x) * e;
        movA.y = pA.y + (pAExt.y - pA.y) * e;
        movA.start = pA.start + (pAExt.start - pA.start) * e;
        movA.end = pA.end + (pAExt.end - pA.end) * e;

        AnglePiece movB = pB.clone();
        movB.x = pB.x + (pBExt.x - pB.x) * e;
        movB.y = pB.y + (pBExt.y - pB.y) * e;
        movB.start = pB.start + (pBExt.start - pB.start) * e;
        movB.end = pB.end + (pBExt.end - pB.end) * e;

        drawAnglePiece(canvas, movA);
        drawAnglePiece(canvas, movB);
      }
    }

    // Scenarios 1-3 Labels and Pieces
    if (scenario < 4) {
      for (var ip in initialPieces) {
        var isDetached =
            pieces.where((p) => p.id == ip.id && p.detached).isNotEmpty;
        drawAnglePiece(canvas, ip, isGhost: isDetached);
      }

      for (var p in pieces.where((p) => p.detached)) {
        if (p != draggedPiece) drawAnglePiece(canvas, p);
      }

      if (draggedPiece != null) {
        // Simple shadow
        canvas.save();
        canvas.translate(2, 2);
        drawAnglePiece(canvas, draggedPiece!, isGhost: true);
        canvas.restore();
        drawAnglePiece(canvas, draggedPiece!);
      }
    }

    // Equation display on completion
    if (phase == 'complete') {
      String eq = "";
      if (scenario == 5) {
        eq = "45° + 75° = 120°";
      } else if (scenario == 4) {
        eq =
            "${config.a.round()}° + ${config.b.round()}° = ${config.ext.round()}°";
      } else {
        eq =
            "${initialPieces[0].val.round()}° + ${initialPieces[1].val.round()}° = ${config.ext.round()}°";
      }

      TextSpan span = TextSpan(
        style: const TextStyle(
          color: Color(0xFF10b981),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        text: eq,
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      double midX = (geomB!.x + (geomD?.x ?? geomC!.x + 100)) / 2;
      double drawY = geomB!.y + 60;
      tp.paint(canvas, Offset(midX - tp.width / 2, drawY));
    }

    // Draw Labels
    if (scenario == 4) {
      drawVertexLabel(
        canvas,
        'A',
        Offset(geomA!.x, geomA!.y),
        offset: const Offset(-20, 20),
      );
      drawVertexLabel(
        canvas,
        'B',
        Offset(geomB!.x, geomB!.y),
        offset: const Offset(20, 20),
      );
      if (phase != 'init' && phase != 'drag_1') {
        drawVertexLabel(
          canvas,
          'C',
          Offset(geomC!.x, geomC!.y),
          offset: const Offset(0, 30),
        );
        if (phase == 'animating' || phase == 'complete') {
          double radAC = math.atan2(geomC!.y - geomA!.y, geomC!.x - geomA!.x);
          drawVertexLabel(
            canvas,
            'D',
            Offset(
              geomC!.x + 150 * math.cos(radAC),
              geomC!.y + 150 * math.sin(radAC),
            ),
            offset: const Offset(10, 20),
          );
        }
      }
    } else {
      drawVertexLabel(
        canvas,
        'B',
        Offset(geomB!.x, geomB!.y),
        offset: const Offset(-20, 20),
      );
      drawVertexLabel(
        canvas,
        'C',
        Offset(geomC!.x, geomC!.y),
        offset: const Offset(10, 32),
      );
      drawVertexLabel(
        canvas,
        'A',
        Offset(geomA!.x, geomA!.y),
        offset: const Offset(0, -20),
      );
      if (geomD != null && phase != 'init') {
        drawVertexLabel(
          canvas,
          'D',
          Offset(geomD!.x, geomD!.y),
          offset: const Offset(10, 20),
        );
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 8, dashSpace = 8;
    double dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    double dist = math.sqrt(dx * dx + dy * dy);
    double dashCount = dist / (dashWidth + dashSpace);

    for (int i = 0; i < dashCount; i++) {
      double startX = p1.dx + (dx / dist) * (i * (dashWidth + dashSpace));
      double startY = p1.dy + (dy / dist) * (i * (dashWidth + dashSpace));
      double endX = startX + (dx / dist) * dashWidth;
      double endY = startY + (dy / dist) * dashWidth;
      if (i == dashCount.floor()) {
        endX = p2.dx;
        endY = p2.dy;
      }
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(GeometryPainter oldDelegate) => true;
}
