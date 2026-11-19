// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TriangleSumApp());
}

/// Translations Data
class Translations {
  static const Map<String, Map<String, dynamic>> data = {
    'en': {
      'appTitle': "The Triangle's Secret: A Perfect 180",
      'appSubtitle': 'Class 7 • A TALE OF THREE INTERSECTING LINES',
      'enterLab': 'Enter Lab',
      'selectScenario': 'Select Scenario',
      'objectiveLbl': 'Objective:',
      'blueprintSpecs': 'Blueprint Specifications',
      'baseText': 'Base:',
      'side2Text': 'Side 2:',
      'angLText': '∠ 1:',
      'angRText': '∠ 2:',
      'connectBtn': 'Connect',
      'doneTaskBtn': "I'm Done",
      'checkBtn': 'Check My Work',
      'nextScenario': 'Next Challenge',
      'successTitle': 'Geometry Master!',
      'successDesc':
          'You successfully verified that the sum of angles in any triangle is exactly 180°!',
      'restartLab': 'Restart Lab',
      'stepLabel': 'STEP',
      'doneBtn': 'Done',
      'completed': 'Completed!',
      'verifyBtn': 'Verify',
      'parallelBtn': 'Draw Parallel Line',
      'hud_complete':
          'Task: Construction looks complete! CLICK Next Challenge to proceed.',
      'hud_error':
          'Measurements don\'t match the blueprint! Red lines indicate your errors. Try again.',
      'validation_error': 'Measurements don\'t match blueprint! Try again.',

      's1_title': "1. The Perfect Fit: Equilateral Triangle",
      's1_obj':
          "To visually demonstrate that the three equal angles of an equilateral triangle combine to form a straight line (180°).",
      's1_hud_1': "Task: CLICK on the top vertex to tear off the 60° angle.",
      's1_text_1':
          "Observation: The 60° angle piece tears off from the vertex.\n\nLearnt: Angles can be visually separated from the main shape.",
      's1_hud_2':
          "Task: CLICK on the bottom-left vertex to tear off its angle.",
      's1_text_2':
          "Observation: The second 60° angle tears off.\n\nLearnt: Another equal angle is separated.",
      's1_hud_3':
          "Task: CLICK on the bottom-right vertex to tear off its angle.",
      's1_text_3':
          "Observation: The final 60° angle tears off.\n\nLearnt: All three angles are now free.",
      's1_hud_4':
          "Task: DRAG the pieces and DROP them on the straight-line guide.",
      's1_text_4':
          "Observation: They form a perfect 180° semi-circle.\n\nLearnt: The sum of angles in an equilateral triangle is exactly 180°.",
      's1_sum': "60° + 60° + 60° = 180°. A straight line!",

      's2_title': "2. The Right Combination: Right-Angled Triangle",
      's2_obj':
          "To verify that the angle sum property holds true for a right-angled triangle.",
      's2_hud_1': "Task: CLICK on the vertex with the 90° angle.",
      's2_text_1':
          "Observation: The square 90° piece tears off.\n\nLearnt: Right angles are exactly 90°.",
      's2_hud_2': "Task: CLICK on the top vertex to tear off its angle.",
      's2_text_2':
          "Observation: The 30° angle piece detaches.\n\nLearnt: Acute angles are less than 90°.",
      's2_hud_3': "Task: CLICK on the right vertex to tear off its angle.",
      's2_text_3':
          "Observation: The 60° angle piece detaches.\n\nLearnt: The other acute angle is 60°.",
      's2_hud_4':
          "Task: DRAG the pieces and DROP them on the straight-line guide.",
      's2_text_4':
          "Observation: They perfectly form a 180° semi-circle.\n\nLearnt: Right-angled triangles also follow the 180° rule.",
      's2_sum': "90° + 30° + 60° = 180°. The rule holds true!",

      's3_title': "3. The Wide View: Obtuse Triangle",
      's3_obj':
          "To reinforce the concept by showing it applies even to triangles with one angle greater than 90°.",
      's3_hud_1': "Task: CLICK on the top vertex (117°) to tear it off.",
      's3_text_1':
          "Observation: The obtuse 117° piece tears off.\n\nLearnt: Triangles can have one angle greater than 90°.",
      's3_hud_2': "Task: CLICK on the bottom-left vertex (18°) to tear it off.",
      's3_text_2':
          "Observation: The 18° acute angle detaches.\n\nLearnt: The other angles must be small.",
      's3_hud_3':
          "Task: CLICK on the bottom-right vertex (45°) to tear it off.",
      's3_text_3':
          "Observation: The 45° acute angle detaches.\n\nLearnt: All three angles are separated.",
      's3_hud_4':
          "Task: DRAG the pieces and DROP them on the straight-line guide.",
      's3_text_4':
          "Observation: They fit perfectly to form a 180° semi-circle.\n\nLearnt: The angle sum property applies to obtuse triangles too.",
      's3_sum': "117° + 18° + 45° = 180°. A perfect match!",

      's4_title': "4. The Triangle Shifter (Unsolved Challenge)",
      's4_obj':
          "To allow students to discover for themselves that the angle sum is always 180° for any triangle they can create.",
      's4_hud_1': "Task: DRAG any vertex to change the triangle's shape.",
      's4_text_1':
          "Observation: The triangle dynamically changes shape.\n\nLearnt: We can create infinite variations of a triangle.",
      's4_hud_2':
          "Task: Observe the 'Sum of Angles' display as you move the vertices.",
      's4_text_2':
          "Observation: The individual angles fluctuate, but their sum is always locked at 180°.\n\nLearnt: The 180° rule is a universal property of all triangles.",
      's4_hud_3': "Task: Try to break the rule! When ready, CLICK 'Verify'.",
      's4_text_3':
          "Observation: The angles automatically tear off and assemble into a straight line.\n\nLearnt: It is geometrically impossible to create a triangle whose angles do not sum to 180°.",
      's4_sum': "The sum is always exactly 180°, no matter the shape!",

      's5_title': "5. The Parallel Line Proof (Unsolved Challenge)",
      's5_obj':
          "To visually guide the student through the formal geometric proof of the angle sum property.",
      's5_hud_1': "Task: CLICK the 'Draw Parallel Line' button.",
      's5_text_1':
          "Observation: A straight dashed line appears through vertex A, parallel to the base BC.\n\nLearnt: We can construct a line parallel to any side of a triangle.",
      's5_hud_2':
          "Task: DRAG angle B upwards along the side AB until it reaches the parallel line at vertex A.",
      's5_text_2':
          "Observation: Angle B snaps into the space between the parallel line and side AB.\n\nLearnt: It forms an alternate interior angle with the original angle B, so they are equal.",
      's5_hud_3':
          "Task: Now, the angle at vertex C is glowing. DRAG this angle upwards along the side AC to the parallel line.",
      's5_text_3':
          "Observation: Angle C snaps into place on the other side of vertex A.\n\nLearnt: It forms another alternate interior angle with angle C, making them equal.",
      's5_sum':
          "∠B + ∠A + ∠C perfectly align along the parallel line. A straight line is 180°!",
    },
    'hi': {
      'appTitle': 'त्रिभुज का रहस्य: एक आदर्श 180',
      'appSubtitle': 'कक्षा 7 • तीन प्रतिच्छेदी रेखाओं की कहानी',
      'enterLab': 'लैब में प्रवेश करें',
      'selectScenario': 'दृश्य चुनें',
      'objectiveLbl': 'उद्देश्य:',
      'blueprintSpecs': 'ब्लूप्रिंट विनिर्देश',
      'baseText': 'आधार:',
      'side2Text': 'भुजा 2:',
      'angLText': '∠ 1:',
      'angRText': '∠ 2:',
      'connectBtn': 'जोड़ें',
      'doneTaskBtn': 'मैं कर चुका हूँ',
      'checkBtn': 'मेरा काम जांचें',
      'nextScenario': 'अगली चुनौती',
      'successTitle': 'ज्यामिति के उस्ताद!',
      'successDesc':
          'आपने सफलतापूर्वक सत्यापित किया कि किसी भी त्रिभुज के कोणों का योग ठीक 180° होता है!',
      'restartLab': 'लैब फिर से शुरू करें',
      'stepLabel': 'कदम',
      'completed': 'पूरा हुआ!',
      'verifyBtn': 'सत्यापित करें',
      'parallelBtn': 'समानांतर रेखा खींचें',
      'hud_complete':
          'कार्य: निर्माण पूरा लग रहा है! आगे बढ़ने के लिए Next Challenge पर क्लिक करें।',
      'hud_error':
          'माप ब्लूप्रिंट से मेल नहीं खाते! लाल रेखाएं आपकी त्रुटियों को दर्शाती हैं। पुनः प्रयास करें।',
      'validation_error': 'माप ब्लूप्रिंट से मेल नहीं खाते! पुनः प्रयास करें।',

      's1_title': "1. बिल्कुल सही फिट: समबाहु त्रिभुज",
      's1_obj':
          "यह दृश्य रूप से प्रदर्शित करने के लिए कि एक समबाहु त्रिभुज के तीन समान कोण मिलकर एक सीधी रेखा (180°) बनाते हैं।",
      's1_hud_1': "कार्य: 60° कोण को फाड़ने के लिए शीर्ष पर क्लिक करें।",
      's1_text_1':
          "अवलोकन: 60° कोण का टुकड़ा अलग हो जाता है।\n\nसीखा: कोणों को मुख्य आकार से दृष्टिगत रूप से अलग किया जा सकता है।",
      's1_hud_2':
          "कार्य: इसके कोण को फाड़ने के लिए नीचे-बाएँ शीर्ष पर क्लिक करें।",
      's1_text_2':
          "अवलोकन: दूसरा 60° कोण अलग हो जाता है।\n\nसीखा: एक और समान कोण अलग हो गया है।",
      's1_hud_3':
          "कार्य: इसके कोण को फाड़ने के लिए नीचे-दाएँ शीर्ष पर क्लिक करें।",
      's1_text_3':
          "अवलोकन: अंतिम 60° कोण अलग हो जाता है।\n\nसीखा: तीनों कोण अब मुक्त हैं।",
      's1_hud_4': "कार्य: टुकड़ों को खींचें और उन्हें सीधी रेखा पर छोड़ दें।",
      's1_text_4':
          "अवलोकन: वे एक आदर्श 180° अर्धवृत्त बनाते हैं।\n\nसीखा: समबाहु त्रिभुज के कोणों का योग ठीक 180° होता है।",
      's1_sum': "60° + 60° + 60° = 180°। एक सीधी रेखा!",

      's2_title': "2. सही संयोजन: समकोण त्रिभुज",
      's2_obj':
          "यह सत्यापित करने के लिए कि कोण योग गुण समकोण त्रिभुज के लिए सत्य है।",
      's2_hud_1': "कार्य: 90° वाले शीर्ष पर क्लिक करें।",
      's2_text_1':
          "अवलोकन: 90° का वर्गाकार टुकड़ा अलग हो जाता है।\n\nसीखा: समकोण ठीक 90° होते हैं।",
      's2_hud_2': "कार्य: इसके कोण को फाड़ने के लिए शीर्ष पर क्लिक करें।",
      's2_text_2':
          "अवलोकन: 30° का कोण अलग हो जाता है।\n\nसीखा: न्यूनकोण 90° से कम होते हैं।",
      's2_hud_3': "कार्य: इसके कोण को फाड़ने के लिए दाएँ शीर्ष पर क्लिक करें।",
      's2_text_3':
          "अवलोकन: 60° का कोण अलग हो जाता है।\n\nसीखा: दूसरा न्यूनकोण 60° है।",
      's2_hud_4': "कार्य: टुकड़ों को खींचें और उन्हें सीधी रेखा पर छोड़ दें।",
      's2_text_4':
          "अवलोकन: वे पूरी तरह से एक 180° अर्धवृत्त बनाते हैं।\n\nसीखा: समकोण त्रिभुज भी 180° नियम का पालन करते हैं।",
      's2_sum': "90° + 30° + 60° = 180°। नियम सही है!",

      's3_title': "3. विस्तृत दृश्य: अधिककोण त्रिभुज",
      's3_obj':
          "यह प्रदर्शित करने के लिए कि कोण योग गुण अधिककोण त्रिभुज के लिए भी सत्य है।",
      's3_hud_1': "कार्य: शीर्ष (117°) पर क्लिक करें।",
      's3_text_1':
          "अवलोकन: 117° का टुकड़ा अलग हो जाता है।\n\nसीखा: त्रिभुजों में एक कोण 90° से अधिक हो सकता है।",
      's3_hud_2': "कार्य: नीचे-बाएँ शीर्ष (18°) पर क्लिक करें।",
      's3_text_2':
          "अवलोकन: 18° का न्यूनकोण अलग हो जाता है।\n\nसीखा: अन्य कोण छोटे होने चाहिए।",
      's3_hud_3': "कार्य: नीचे-दाएँ शीर्ष (45°) पर क्लिक करें।",
      's3_text_3':
          "अवलोकन: 45° का न्यूनकोण अलग हो जाता है।\n\nसीखा: तीनों कोण अलग हो गए हैं।",
      's3_hud_4': "कार्य: टुकड़ों को खींचें और उन्हें सीधी रेखा पर छोड़ दें।",
      's3_text_4':
          "अवलोकन: वे एक 180° अर्धवृत्त बनाते हैं।\n\nसीखा: कोण योग गुण अधिककोण त्रिभुजों पर भी लागू होता है।",
      's3_sum': "117° + 18° + 45° = 180°। बिल्कुल सही!",

      's4_title': "4. त्रिभुज शिफ्टर (अनसुलझी चुनौती)",
      's4_obj':
          "छात्रों को यह खोजने की अनुमति देने के लिए कि किसी भी त्रिभुज के लिए कोण योग हमेशा 180° होता है।",
      's4_hud_1':
          "कार्य: त्रिभुज का आकार बदलने के लिए किसी भी शीर्ष को खींचें।",
      's4_text_1':
          "अवलोकन: त्रिभुज गतिशील रूप से आकार बदलता है।\n\nसीखा: हम त्रिभुज के अनंत रूप बना सकते हैं।",
      's4_hud_2': "कार्य: शीर्षों को घुमाते हुए 'कोणों का योग' प्रदर्शन देखें।",
      's4_text_2':
          "अवलोकन: व्यक्तिगत कोण बदलते हैं, लेकिन उनका योग हमेशा 180° पर लॉक रहता है।\n\nसीखा: 180° नियम सभी त्रिभुजों का एक सार्वभौमिक गुण है।",
      's4_hud_3':
          "कार्य: नियम को तोड़ने का प्रयास करें! तैयार होने पर 'सत्यापित करें' पर क्लिक करें।",
      's4_text_3':
          "अवलोकन: कोण स्वचालित रूप से अलग हो जाते हैं और एक सीधी रेखा में इकट्ठा हो जाते हैं।\n\nसीखा: ऐसा त्रिभुज बनाना ज्यामितीय रूप से असंभव है जिसके कोणों का योग 180° न हो।",
      's4_sum': "योग हमेशा ठीक 180° होता है, चाहे आकार कुछ भी हो!",

      's5_title': "5. समानांतर रेखा प्रमाण (अनसुलझी चुनौती)",
      's5_obj':
          "कोण योग गुण के औपचारिक ज्यामितीय प्रमाण के माध्यम से छात्र का दृश्य रूप से मार्गदर्शन करना।",
      's5_hud_1': "कार्य: 'समानांतर रेखा खींचें' बटन पर क्लिक करें।",
      's5_text_1':
          "अवलोकन: शीर्ष A के माध्यम से आधार BC के पूर्ण समानांतर एक सीधी रेखा दिखाई देती है।\n\nसीखा: हम त्रिभुज के किसी भी भुजा के समानांतर एक रेखा का निर्माण कर सकते हैं।",
      's5_hud_2':
          "कार्य: कोण B को भुजा AB के साथ तब तक ऊपर खींचें जब तक कि वह शीर्ष A पर समानांतर रेखा तक न पहुँच जाए।",
      's5_text_2':
          "अवलोकन: कोण B समानांतर रेखा और भुजा AB के बीच के स्थान में आ जाता है।\n\nसीखा: यह मूल कोण B के साथ एक एकांतर अंतः कोण बनाता है, इसलिए वे समान हैं।",
      's5_hud_3':
          "कार्य: कोण C को भुजा AC के साथ तब तक ऊपर खींचें जब तक कि वह शीर्ष A पर समानांतर रेखा तक न पहुँच जाए।",
      's5_text_3':
          "अवलोकन: कोण C शीर्ष A के दूसरी ओर अपनी जगह पर आ जाता है।\n\nसीखा: यह कोण C के साथ एक और एकांतर अंतः कोण बनाता है, जिससे वे समान हो जाते हैं।",
      's5_sum':
          "∠B + ∠A + ∠C समानांतर रेखा के साथ पूरी तरह से संरेखित हैं। एक सीधी रेखा 180° होती है!",
    },
  };
}

class TriangleSumApp extends StatelessWidget {
  const TriangleSumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const AngleSumPropertyofTriangles(),
    );
  }
}

class AnglePiece {
  String id;
  double start, end, val;
  double x, y;
  Color color;
  bool isSquare;
  bool detached;
  bool snapped;
  int snapIdx;

  // Animation targets
  double originStart = 0, originEnd = 0, destStart = 0, destEnd = 0;
  Offset origin = Offset.zero, dest = Offset.zero;
  bool animating = false;

  AnglePiece({
    required this.id,
    required this.start,
    required this.end,
    required this.val,
    required this.x,
    required this.y,
    required this.color,
    this.isSquare = false,
    this.detached = false,
    this.snapped = false,
    this.snapIdx = -1,
    this.destStart = 0,
    this.destEnd = 0,
    this.origin = Offset.zero,
    this.dest = Offset.zero,
  });

  AnglePiece clone() {
    return AnglePiece(
      id: id,
      start: start,
      end: end,
      val: val,
      x: x,
      y: y,
      color: color,
      isSquare: isSquare,
      detached: detached,
      snapped: snapped,
      snapIdx: snapIdx,
      destStart: destStart,
      destEnd: destEnd,
      origin: origin,
      dest: dest,
    );
  }
}

class AngleSumPropertyofTriangles extends StatefulWidget {
  const AngleSumPropertyofTriangles({super.key});

  @override
  State<AngleSumPropertyofTriangles> createState() =>
      _AngleSumPropertyofTrianglesState();
}

class _AngleSumPropertyofTrianglesState
    extends State<AngleSumPropertyofTriangles>
    with TickerProviderStateMixin {
  // Custom Color Palette
  static const Color cZslDark = Color(0xFF020617);
  static const Color cZslPanel = Color(0xD91E293B);
  static const Color cEmerald = Color(0xFF10B981);
  static const Color cIndigo = Color(0xFF6366F1);
  static const Color cAmber = Color(0xFFF59E0B);
  static const Color cRose = Color(0xFFF43F5E);
  static const Color cBlue = Color(0xFF3B82F6);
  static const Color cCyan = Color(0xFF38BDF8);

  // Audio Players
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String _sndPop =
      'audio/class7/mixkit_2568.mp3';
  final String _sndSuccess =
      'audio/class7/mixkit_2000.mp3';
  final String _sndError =
      'audio/class7/mixkit_2570.mp3';
  final String _sndSnap =
      'audio/class7/mixkit_2568.mp3';

  // Animation
  late AnimationController _pulseController;
  late AnimationController _verifyAnimController;

  // State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  bool _isLabEntered = false;
  bool _showSuccessPopup = false;

  // Viewport State
  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _pan = const Offset(0, 20);

  // Scenario Data
  int _scenario = 0; // Starts at 0, loaded when entered
  final Map<int, Map<String, dynamic>> _scenarios = {
    1: {'type': 'equilateral', 'steps': 4},
    2: {'type': 'right', 'steps': 4},
    3: {'type': 'obtuse', 'steps': 4},
    4: {'type': 'custom', 'steps': 3},
    5: {'type': 'parallel', 'steps': 3},
  };

  // Construction State
  String _phase = 'click_1';
  Map<String, Offset> _geom = {};
  List<AnglePiece> _initialPieces = [];
  List<AnglePiece> _pieces = [];
  List<AnglePiece?> _slots = [null, null, null];
  AnglePiece? _draggedPiece;
  String? _draggedVertex;
  bool _parallelLineDrawn = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _verifyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _verifyAnimController.addListener(() {
      setState(() {});
    });
    _verifyAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _phase = 'complete';
          for (var p in _pieces) {
            p.x = p.dest.dx;
            p.y = p.dest.dy;
            p.start = p.destStart;
            p.end = p.destEnd;
            p.animating = false;
          }
          _playSound(_sndSuccess);
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pulseController.dispose();
    _verifyAnimController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play failed: $e");
    }
  }

  String t(String key) {
    return Translations.data[_lang]?[key] ?? key;
  }

  void _toggleLang() {
    _playSound(_sndPop);
    setState(() {
      if (_lang == 'en') {
        _lang = 'hi';
      } else {
        _lang = 'en';
      }
    });
  }

  void _enterLab() {
    _playSound(_sndSuccess);
    setState(() {
      _showCurtain = false;
      _isLabEntered = true;
      _loadScenario(1);
    });
  }

  void _resetLab() {
    _playSound(_sndPop);
    setState(() {
      _showCurtain = true;
      _isLabEntered = false;
      _scenario = 0;
      _isSidebarOpen = true;
      _lang = 'en';
      _geom.clear();
      _pieces.clear();
      _initialPieces.clear();
      _resetConstructionState();
    });
  }

  void _loadScenario(int id) {
    _playSound(_sndPop);
    setState(() {
      _scenario = id;
      _pieces.clear();
      _initialPieces.clear();
      _slots = [null, null, null];
      _draggedPiece = null;
      _draggedVertex = null;
      _showSuccessPopup = false;
      _scale = 1.0;
      _baseScale = 1.0;
      _pan = const Offset(0, 20);
      _parallelLineDrawn = false;
      _verifyAnimController.reset();

      if (id == 1) {
        _phase = 'click_1';
        _geom = {
          'A': const Offset(0, -136.6),
          'B': const Offset(-100, 36.6),
          'C': const Offset(100, 36.6),
          'P': const Offset(0, 150),
        };
        _initialPieces = _getTriangleAngles(
          _geom['A']!,
          _geom['B']!,
          _geom['C']!,
        );
      } else if (id == 2) {
        _phase = 'click_1';
        _geom = {
          'A': const Offset(-100, -100),
          'B': const Offset(-100, 50),
          'C': const Offset(100, 50),
          'P': const Offset(0, 150),
        };
        _initialPieces = _getTriangleAngles(
          _geom['A']!,
          _geom['B']!,
          _geom['C']!,
        );
        var bPiece = _initialPieces.firstWhere((p) => p.id == 'B');
        bPiece.isSquare = true;
      } else if (id == 3) {
        _phase = 'click_1';
        _geom = {
          'A': const Offset(-150, -50),
          'B': const Offset(-100, 50),
          'C': const Offset(150, 50),
          'P': const Offset(0, 150),
        };
        _initialPieces = _getTriangleAngles(
          _geom['A']!,
          _geom['B']!,
          _geom['C']!,
        );
      } else if (id == 4) {
        _phase = 'shift_1';
        _geom = {
          'A': const Offset(0, -100),
          'B': const Offset(-100, 50),
          'C': const Offset(100, 50),
          'P': const Offset(0, 150),
        };
        _initialPieces = _getTriangleAngles(
          _geom['A']!,
          _geom['B']!,
          _geom['C']!,
        );
      } else if (id == 5) {
        _phase = 'draw_parallel';
        _geom = {
          'A': const Offset(20, -100),
          'B': const Offset(-120, 80),
          'C': const Offset(140, 80),
          'P': const Offset(0, 0),
        };
        _initialPieces = _getS5Angles(_geom['A']!, _geom['B']!, _geom['C']!);
      }

      if (id <= 5) {
        _pieces = _initialPieces.map((p) => p.clone()).toList();
      }
    });
  }

  void _resetConstructionState() {
    _phase = 'click_1';
    _slots = [null, null, null];
    _draggedPiece = null;
    _draggedVertex = null;
    _showSuccessPopup = false;
    _scale = 1.0;
    _baseScale = 1.0;
    _pan = const Offset(0, 20);
    _parallelLineDrawn = false;
  }

  List<AnglePiece> _getTriangleAngles(Offset A, Offset B, Offset C) {
    double aAB = atan2(B.dy - A.dy, B.dx - A.dx);
    double aAC = atan2(C.dy - A.dy, C.dx - A.dx);
    double aBA = atan2(A.dy - B.dy, A.dx - B.dx);
    double aBC = atan2(C.dy - B.dy, C.dx - B.dx);
    double aCA = atan2(A.dy - C.dy, A.dx - C.dx);
    double aCB = atan2(B.dy - C.dy, B.dx - C.dx);

    Map<String, double> getArc(double a1, double a2) {
      double start = a1;
      double end = a2;
      double diff = (end - start) % (2 * pi);
      if (diff < 0) diff += 2 * pi;
      if (diff > pi) {
        diff = 2 * pi - diff;
        start = a2;
        end = a1;
      }
      return {
        'start': start * 180 / pi,
        'end': end * 180 / pi,
        'val': diff * 180 / pi,
      };
    }

    var arcA = getArc(aAB, aAC);
    var arcB = getArc(aBC, aBA);
    var arcC = getArc(aCA, aCB);

    double degA = arcA['val']!.roundToDouble();
    double degB = arcB['val']!.roundToDouble();
    double degC = 180 - degA - degB;

    return [
      AnglePiece(
        id: 'A',
        start: arcA['start']!,
        end: arcA['end']!,
        val: degA,
        x: A.dx,
        y: A.dy,
        color: const Color(0xFFF43F5E),
      ),
      AnglePiece(
        id: 'B',
        start: arcB['start']!,
        end: arcB['end']!,
        val: degB,
        x: B.dx,
        y: B.dy,
        color: const Color(0xFF3B82F6),
      ),
      AnglePiece(
        id: 'C',
        start: arcC['start']!,
        end: arcC['end']!,
        val: degC,
        x: C.dx,
        y: C.dy,
        color: const Color(0xFF10B981),
      ),
    ];
  }

  List<AnglePiece> _getS5Angles(Offset A, Offset B, Offset C) {
    double aBA = atan2(A.dy - B.dy, A.dx - B.dx) * 180 / pi;
    double aCA = atan2(A.dy - C.dy, A.dx - C.dx) * 180 / pi;
    double aAB = atan2(B.dy - A.dy, B.dx - A.dx) * 180 / pi;
    double aAC = atan2(C.dy - A.dy, C.dx - A.dx) * 180 / pi;

    double valB = aBA.abs();
    double valC = (-180 - aCA).abs();
    double valA = (aAB - aAC).abs();

    return [
      AnglePiece(
        id: 'A',
        start: aAC,
        end: aAB,
        val: valA.roundToDouble(),
        x: A.dx,
        y: A.dy,
        color: cEmerald,
      ),
      AnglePiece(
        id: 'B',
        start: aBA,
        end: 0,
        val: valB.roundToDouble(),
        x: B.dx,
        y: B.dy,
        color: cRose,
        destStart: aAB,
        destEnd: 180,
        dest: A,
      ),
      AnglePiece(
        id: 'C',
        start: -180,
        end: aCA,
        val: valC.roundToDouble(),
        x: C.dx,
        y: C.dy,
        color: cBlue,
        destStart: 0,
        destEnd: aAC,
        dest: A,
      ),
    ];
  }

  int get pseudoStep {
    if (_scenario < 4) {
      if (_phase == 'click_1') return 0;
      if (_phase == 'click_2') return 1;
      if (_phase == 'click_3') return 2;
      if (_phase == 'drag_pieces') return 3;
      if (_phase == 'complete') return 4;
    } else if (_scenario == 4) {
      if (_phase == 'shift_1') return 0;
      if (_phase == 'shift_2') return 1;
      if (_phase == 'verify_ready') return 2;
      if (_phase == 'animating' || _phase == 'complete') return 3;
    } else if (_scenario == 5) {
      if (_phase == 'draw_parallel') return 0;
      if (_phase == 'drag_b') return 1;
      if (_phase == 'drag_c') return 2;
      if (_phase == 'complete') return 3;
    }
    return 0;
  }

  // --- Scale & Drag Interaction Logic ---
  Offset _screenToWorld(Offset screenPoint, Size canvasSize) {
    double cx = canvasSize.width / 2;
    double cy = canvasSize.height / 2;
    double worldX = (screenPoint.dx - cx - _pan.dx) / _scale;
    double worldY = (screenPoint.dy - cy - _pan.dy) / _scale;
    return Offset(worldX, worldY);
  }

  void _handleTouch(Offset localFocalPoint, Size canvasSize) {
    Offset worldPt = _screenToWorld(localFocalPoint, canvasSize);
    bool hitElement = false;

    if (_scenario == 5) {
      if (_phase == 'drag_b' || _phase == 'drag_c') {
        String targetId = _phase == 'drag_b' ? 'B' : 'C';
        var targetIP = _initialPieces.firstWhere((p) => p.id == targetId);
        if ((worldPt - Offset(targetIP.x, targetIP.y)).distance < 100) {
          var activePiece = _pieces.firstWhere((p) => p.id == targetId);
          if (!activePiece.detached) {
            _playSound(_sndPop);
            setState(() {
              activePiece.detached = true;
              _draggedPiece = activePiece;
            });
          } else {
            setState(() {
              _draggedPiece = activePiece;
            });
          }
          hitElement = true;
        }
      }
    } else if (_scenario == 4 && _phase.startsWith('shift')) {
      for (String v in ['A', 'B', 'C']) {
        if ((worldPt - _geom[v]!).distance < 100) {
          setState(() {
            _draggedVertex = v;
          });
          hitElement = true;
          break;
        }
      }
    } else if (_scenario < 4) {
      int pieceIdx =
          _phase == 'click_1'
              ? 0
              : (_phase == 'click_2' ? 1 : (_phase == 'click_3' ? 2 : -1));

      if (pieceIdx != -1 && _initialPieces.length > pieceIdx) {
        var targetIP = _initialPieces[pieceIdx];
        if ((worldPt - Offset(targetIP.x, targetIP.y)).distance < 100) {
          var activePiece = _pieces[pieceIdx];
          if (!activePiece.detached) {
            _playSound(_sndPop);
            setState(() {
              activePiece.detached = true;
              double mid = (activePiece.start + activePiece.end) / 2 * pi / 180;
              activePiece.x += 20 * cos(mid);
              activePiece.y += 20 * sin(mid);

              if (pieceIdx == 0) {
                _phase = 'click_2';
              } else if (pieceIdx == 1) {
                _phase = 'click_3';
              } else {
                _phase = 'drag_pieces';
              }
            });
          }
          hitElement = true;
        }
      }

      if (!hitElement &&
          (_phase == 'drag_pieces' || _phase.startsWith('click_'))) {
        try {
          var hit = _pieces.firstWhere(
            (p) =>
                p.detached &&
                !p.snapped &&
                (worldPt - Offset(p.x, p.y)).distance < 100,
          );
          setState(() {
            _draggedPiece = hit;
          });
          hitElement = true;
        } catch (_) {}
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    if (details.pointerCount > 1 ||
        (_draggedPiece == null && _draggedVertex == null)) {
      setState(() {
        _pan += details.focalPointDelta;
        if (details.scale != 1.0) {
          _scale = (_baseScale * details.scale).clamp(0.2, 4.0);
        }
      });
      return;
    }

    Offset worldPt = _screenToWorld(details.localFocalPoint, canvasSize);

    setState(() {
      if (_draggedPiece != null) {
        _draggedPiece!.x = worldPt.dx;
        _draggedPiece!.y = worldPt.dy;
      } else if (_draggedVertex != null && _scenario == 4) {
        _geom[_draggedVertex!] = worldPt;
        _initialPieces = _getTriangleAngles(
          _geom['A']!,
          _geom['B']!,
          _geom['C']!,
        );
        _pieces = _initialPieces.map((p) => p.clone()).toList();
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      if (_draggedPiece != null) {
        var p = _draggedPiece!;

        if (_scenario == 5) {
          if ((Offset(p.x, p.y) - _geom['A']!).distance < 100) {
            p.snapped = true;
            p.x = _geom['A']!.dx;
            p.y = _geom['A']!.dy;
            p.start = p.destStart;
            p.end = p.destEnd;
            _playSound(_sndSnap);

            if (p.id == 'B') {
              _phase = 'drag_c';
            } else if (p.id == 'C') {
              _phase = 'complete';
              _playSound(_sndSuccess);
            }
          } else {
            _playSound(_sndError);
            p.detached = false;
            var orig = _initialPieces.firstWhere((ip) => ip.id == p.id);
            p.x = orig.x;
            p.y = orig.y;
          }
        } else if ((Offset(p.x, p.y) - _geom['P']!).distance < 100) {
          int slotIdx = _slots.indexOf(null);
          if (slotIdx != -1) {
            _slots[slotIdx] = p;
            p.snapped = true;
            p.snapIdx = slotIdx;

            var snappedPieces =
                _pieces.where((sp) => sp.snapped).toList()
                  ..sort((a, b) => a.id.compareTo(b.id));
            double acc = -180;
            for (var sp in snappedPieces) {
              sp.start = acc;
              acc += sp.val;
              sp.end = acc;
              sp.x = _geom['P']!.dx;
              sp.y = _geom['P']!.dy;
            }

            _playSound(_sndSnap);

            if (_slots.every((s) => s != null)) {
              _phase = 'complete';
              _playSound(_sndSuccess);
            }
          } else {
            _playSound(_sndError);
          }
        } else {
          // Did not drop on valid target, revert position
          _playSound(_sndError);
          var orig = _initialPieces.firstWhere((ip) => ip.id == p.id);
          p.x = orig.x;
          p.y = orig.y;
          p.detached = false;

          if (_scenario < 4) {
            if (p.id == 'A') {
              _phase = 'click_1';
            } else if (p.id == 'B') {
              _phase = 'click_2';
            } else if (p.id == 'C') {
              _phase = 'click_3';
            }
          }
        }
        _draggedPiece = null;
      } else if (_draggedVertex != null && _scenario == 4) {
        _draggedVertex = null;
        if (_phase == 'shift_1') {
          _phase = 'shift_2';
        } else if (_phase == 'shift_2') {
          _phase = 'verify_ready';
        }
      }
    });
  }

  void _triggerDrawParallel() {
    _playSound(_sndSnap);
    setState(() {
      _parallelLineDrawn = true;
      _phase = 'drag_b';
    });
  }

  void _triggerVerify() {
    _playSound(_sndPop);
    var dynAngles = _getTriangleAngles(_geom['A']!, _geom['B']!, _geom['C']!);
    double acc = -180;

    setState(() {
      _pieces =
          dynAngles.map((ip) {
            double destStart = acc;
            acc += ip.val;
            double destEnd = acc;
            var p = AnglePiece(
              id: ip.id,
              val: ip.val,
              color: ip.color,
              x: ip.x,
              y: ip.y,
              start: ip.start,
              end: ip.end,
              detached: true,
              snapped: true,
            );
            p.originStart = ip.start;
            p.originEnd = ip.end;
            p.destStart = destStart;
            p.destEnd = destEnd;
            p.origin = Offset(ip.x, ip.y);
            p.dest = _geom['P']!;
            p.animating = true;
            return p;
          }).toList();

      _phase = 'animating';
      _verifyAnimController.forward(from: 0);
    });
  }

  void _triggerDone() {
    _playSound(_sndSuccess);
    setState(() => _showSuccessPopup = true);
  }

  void _nextScenario() {
    _loadScenario(_scenario + 1);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.35;
    if (sidebarWidth < 340) sidebarWidth = 340;

    Size canvasSize = Size(
      screenWidth - (_isSidebarOpen ? sidebarWidth : 0),
      MediaQuery.of(context).size.height,
    );

    String activeHUD = _getHUDText();
    var cfg = _scenario > 0 ? _scenarios[_scenario]! : {'steps': 0};
    int totalSteps = cfg['steps'];
    int stepIdx = pseudoStep;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: cZslDark,
        body: Stack(
          children: [
            // --- 1. Canvas Area ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTapDown: (d) {
                  if (_phase == 'complete' ||
                      _phase == 'animating' ||
                      !_isLabEntered) {
                    return;
                  }
                  _handleTouch(d.localPosition, canvasSize);
                },
                onScaleStart: (d) {
                  _baseScale = _scale;
                  if (d.pointerCount > 1 ||
                      _phase == 'complete' ||
                      _phase == 'animating' ||
                      !_isLabEntered) {
                    return;
                  }
                  _handleTouch(d.localFocalPoint, canvasSize);
                },
                onScaleUpdate: (d) => _handleScaleUpdate(d, canvasSize),
                onScaleEnd: (d) => _handleScaleEnd(d),
                child: Container(
                  color: cZslDark,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseController,
                      _verifyAnimController,
                    ]),
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CanvasPainter(
                          scale: _scale,
                          pan: _pan,
                          scenario: _scenario,
                          phase: _phase,
                          geom: _geom,
                          initialPieces: _initialPieces,
                          pieces: _pieces,
                          draggedPiece: _draggedPiece,
                          draggedVertex: _draggedVertex,
                          parallelLineDrawn: _parallelLineDrawn,
                          pulseValue: _pulseController.value,
                          animValue: _verifyAnimController.value,
                          isLabEntered: _isLabEntered,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),
            ),

            // --- Canvas Mini HUD (Bottom Center) ---
            if (_isLabEntered && activeHUD.isNotEmpty)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: cZslPanel.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cIndigo.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: cIndigo.withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, color: cCyan),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            activeHUD
                                .replaceAll('Task: ', '')
                                .replaceAll('<b>', '')
                                .replaceAll('</b>', ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- Floating Action Buttons (Bottom Right) ---
            if (_isLabEntered)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                right: 20,
                bottom: 80,
                child: _buildActionButtons(),
              ),

            // --- 3. Sidebar Container (Fully Scrollable) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: cZslPanel,
                  border: const Border(
                    right: BorderSide(color: Colors.white12),
                  ),
                  boxShadow: [
                    if (_isSidebarOpen)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 80, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('appTitle'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _toggleLang,
                                    icon: const Icon(
                                      Icons.language,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      _lang.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cIndigo.withOpacity(0.2),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: cIndigo.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _resetLab,
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: cRose,
                                    ),
                                    label: const Text(
                                      'Reset',
                                      style: TextStyle(color: cRose),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cRose.withOpacity(0.1),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: cRose.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            if (_isLabEntered) ...[
                              Text(
                                t('selectScenario').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.indigoAccent.withOpacity(0.5),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _scenario > 0 ? _scenario : 1,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                    onChanged: (val) {
                                      if (val != null) _loadScenario(val);
                                    },
                                    items:
                                        [1, 2, 3, 4, 5].map((id) {
                                          return DropdownMenuItem<int>(
                                            value: id,
                                            child: Text(
                                              t('s${id}_title'),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cIndigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: cIndigo.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.track_changes,
                                          color: Colors.indigoAccent,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t('objectiveLbl'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t('s${_scenario}_obj'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),

                      if (_isLabEntered) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: List.generate(totalSteps, (index) {
                              bool isPast = index < stepIdx;
                              bool isActive = index == stepIdx;

                              Color bgColor =
                                  isPast
                                      ? Colors.white.withOpacity(0.05)
                                      : (isActive
                                          ? cIndigo.withOpacity(0.15)
                                          : Colors.white.withOpacity(0.02));
                              Color borderColor =
                                  isActive
                                      ? cIndigo.withOpacity(0.6)
                                      : Colors.white12;
                              Color iconColor =
                                  isPast
                                      ? cEmerald
                                      : (isActive
                                          ? Colors.white
                                          : Colors.white30);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      margin: const EdgeInsets.only(
                                        right: 12,
                                        top: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isPast
                                                ? Colors.transparent
                                                : (isActive
                                                    ? cIndigo
                                                    : Colors.white12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child:
                                            isPast
                                                ? const Icon(
                                                  Icons.check_circle,
                                                  color: cEmerald,
                                                  size: 28,
                                                )
                                                : Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color: iconColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
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
                                            '${t('stepLabel')} ${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _getStepObservationText(index),
                                            style: TextStyle(
                                              color:
                                                  isPast
                                                      ? Colors.white54
                                                      : (isActive
                                                          ? Colors.white
                                                          : Colors.white30),
                                              fontSize: 13,
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
                          ),
                        ),

                        if (_phase == 'complete')
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cEmerald.withOpacity(0.1),
                              border: Border.all(
                                color: cEmerald.withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: cEmerald,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      t('completed'),
                                      style: const TextStyle(
                                        color: cEmerald,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  t('s${_scenario}_sum'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ],

                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white12),
                          ),
                        ),
                        child: const Text(
                          '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- 4. Fixed Menu Button (Top Left) ---
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: cAmber,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound(_sndPop);
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cAmber.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // --- 6. Success Modal ---
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(32),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: cZslPanel,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(
                              color: cEmerald.withOpacity(0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: cEmerald,
                              ),
                              child: const Icon(
                                Icons.celebration,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t('successTitle'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t('successDesc'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                _playSound(_sndPop);
                                setState(() {
                                  _showSuccessPopup = false;
                                  _resetLab();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(t('restartLab')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cIndigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
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
              ),

            // --- 7. Curtain Raiser (Intro Screen) ---
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_showCurtain,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0.0,
                    end:
                        _showCurtain
                            ? 0.0
                            : -MediaQuery.of(context).size.height,
                  ),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubic,
                  builder: (context, val, child) {
                    return Transform.translate(
                      offset: Offset(0, val),
                      child: child,
                    );
                  },
                  child: Container(
                    color: cZslDark,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.change_history,
                            size: 80,
                            color: cIndigo,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('appTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: () {
                              _enterLab();
                            },
                            icon: const Icon(Icons.play_circle_fill, size: 24),
                            label: Text(t('enterLab')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cIndigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              elevation: 10,
                            ),
                          ),
                        ],
                      ),
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

  String _getStepObservationText(int index) {
    if (_scenario == 0) return '';
    String key = 's${_scenario}_text_${index + 1}';
    return t(key)
        .replaceAll('Task: ', '')
        .replaceAll('<b>', '')
        .replaceAll('</b>', '')
        .replaceAll('<br><br>', '\n\n')
        .replaceAll('<span class=\'text-emerald-500 font-semibold\'>', '')
        .replaceAll('</span>', '');
  }

  String _getHUDText() {
    if (_scenario == 0) return '';
    if (_phase == 'complete') return t('hud_complete');
    if (_phase == 'animating') return '';
    return t('s${_scenario}_hud_${pseudoStep + 1}');
  }

  Widget _buildActionButtons() {
    if (_scenario == 5 && _phase == 'draw_parallel') {
      return _buildPrimaryBtn(
        t('parallelBtn'),
        Icons.horizontal_rule,
        cBlue,
        _triggerDrawParallel,
      );
    }

    if (_scenario == 4 && _phase == 'verify_ready') {
      return _buildPrimaryBtn(
        t('verifyBtn'),
        Icons.search,
        cIndigo,
        _triggerVerify,
      );
    }

    if (_phase == 'complete') {
      if (_scenario < 5) {
        return _buildPrimaryBtn(
          t('nextScenario'),
          Icons.arrow_forward,
          cEmerald,
          _nextScenario,
        );
      } else {
        return _buildPrimaryBtn(
          t('doneTaskBtn'),
          Icons.check_circle,
          cIndigo,
          _triggerDone,
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildPrimaryBtn(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
      ),
    );
  }
}

/// Custom Canvas Rendering
class CanvasPainter extends CustomPainter {
  final double scale;
  final Offset pan;
  final int scenario;
  final String phase;
  final bool isLabEntered;

  final Map<String, Offset> geom;
  final List<AnglePiece> initialPieces;
  final List<AnglePiece> pieces;

  final AnglePiece? draggedPiece;
  final String? draggedVertex;
  final bool parallelLineDrawn;

  final double pulseValue;
  final double animValue;

  CanvasPainter({
    required this.scale,
    required this.pan,
    required this.scenario,
    required this.phase,
    required this.isLabEntered,
    required this.geom,
    required this.initialPieces,
    required this.pieces,
    required this.draggedPiece,
    required this.draggedVertex,
    required this.parallelLineDrawn,
    required this.pulseValue,
    required this.animValue,
  });

  static const Color cEmerald = Color(0xFF10B981);
  static const Color cIndigo = Color(0xFF6366F1);

  void _drawPulse(Canvas canvas, Offset p) {
    double pulseRadius = 20 * (1 + pulseValue * 0.3);
    canvas.drawCircle(
      p,
      pulseRadius,
      Paint()..color = cEmerald.withOpacity(0.4),
    );
  }

  void _drawAnglePiece(
    Canvas canvas,
    AnglePiece piece, {
    bool isGhost = false,
  }) {
    canvas.save();
    canvas.translate(piece.x, piece.y);
    double radS = piece.start * pi / 180;
    double radE = piece.end * pi / 180;

    Path p = Path();
    p.moveTo(0, 0);

    if (piece.isSquare && !piece.snapped && !piece.animating) {
      double dist = 35;
      p.lineTo(dist * cos(radS), dist * sin(radS));
      p.lineTo(
        dist * cos(radS) + dist * cos(radE),
        dist * sin(radS) + dist * sin(radE),
      ); // Simplified square corner
      p.lineTo(dist * cos(radE), dist * sin(radE));
    } else {
      p.arcTo(
        Rect.fromCircle(center: Offset.zero, radius: 45),
        radS,
        radE - radS,
        false,
      );
    }
    p.close();

    canvas.drawPath(
      p,
      Paint()
        ..color = piece.color.withOpacity(isGhost ? 0.2 : 0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      p,
      Paint()
        ..color = piece.color.withOpacity(isGhost ? 0.4 : 1.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    double midRad = (radS + radE) / 2;
    double textDist =
        (piece.isSquare && !piece.snapped && !piece.animating) ? 20 : 25;

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: '${piece.val.round()}°',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        textDist * cos(midRad) - tp.width / 2,
        textDist * sin(midRad) - tp.height / 2,
      ),
    );

    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!isLabEntered) return; // Do not draw anything if lab is not entered

    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(scale, scale);

    // Draw Grid
    final gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += 30) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    if (geom.isNotEmpty) {
      // Draw Triangle Outline
      Path tri =
          Path()
            ..moveTo(geom['A']!.dx, geom['A']!.dy)
            ..lineTo(geom['B']!.dx, geom['B']!.dy)
            ..lineTo(geom['C']!.dx, geom['C']!.dy)
            ..close();

      canvas.drawPath(
        tri,
        Paint()
          ..color = cIndigo.withOpacity(0.05)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        tri,
        Paint()
          ..color = cIndigo.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      if (scenario == 4 && phase.startsWith('shift')) {
        for (var pt in [geom['A']!, geom['B']!, geom['C']!]) {
          canvas.drawCircle(pt, 20, Paint()..color = cIndigo.withOpacity(0.2));
          canvas.drawCircle(pt, 8, Paint()..color = cIndigo);
        }
      }

      if (scenario == 5 && parallelLineDrawn) {
        final pPaint =
            Paint()
              ..color = Colors.blueGrey
              ..strokeWidth = 2;
        _drawDashedLine(
          canvas,
          Offset(geom['A']!.dx - 300, geom['A']!.dy),
          Offset(geom['A']!.dx + 300, geom['A']!.dy),
          pPaint,
        );
      }

      List<AnglePiece> ip =
          (scenario == 4 && phase.startsWith('shift'))
              ? _getTriangleAngles(geom['A']!, geom['B']!, geom['C']!)
              : initialPieces;

      for (var p in ip) {
        bool isDetached = false;
        try {
          isDetached = pieces.firstWhere((ep) => ep.id == p.id).detached;
        } catch (_) {}
        if (!isDetached || (scenario == 5 && p.id == 'A')) {
          _drawAnglePiece(canvas, p);
        }
      }

      if (scenario == 4) {
        TextPainter tp = TextPainter(
          text: const TextSpan(
            text: 'Sum of Angles: 180°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        tp.layout();
        tp.paint(canvas, Offset(-tp.width / 2, -200));
      }

      // Draw Pulses
      if (phase == 'click_1' && ip.isNotEmpty) {
        _drawPulse(
          canvas,
          ip[0].origin.dx == 0 && ip[0].origin.dy == 0
              ? Offset(ip[0].x, ip[0].y)
              : Offset(ip[0].x, ip[0].y),
        );
      }
      if (phase == 'click_2' && ip.length > 1) {
        _drawPulse(canvas, Offset(ip[1].x, ip[1].y));
      }
      if (phase == 'click_3' && ip.length > 2) {
        _drawPulse(canvas, Offset(ip[2].x, ip[2].y));
      }

      if (scenario == 5 && phase == 'draw_parallel') {
        _drawPulse(canvas, geom['A']!);
      }
      if (scenario == 5 && phase == 'drag_b') _drawPulse(canvas, geom['B']!);
      if (scenario == 5 && phase == 'drag_c') _drawPulse(canvas, geom['C']!);

      // Baseline
      if (scenario != 5 &&
          (phase == 'drag_pieces' ||
              phase == 'complete' ||
              phase == 'animating')) {
        final bPaint =
            Paint()
              ..color = Colors.blueGrey
              ..strokeWidth = 2;
        _drawDashedLine(
          canvas,
          Offset(geom['P']!.dx - 150, geom['P']!.dy),
          Offset(geom['P']!.dx + 150, geom['P']!.dy),
          bPaint,
        );
        canvas.drawCircle(geom['P']!, 4, Paint()..color = Colors.blueGrey);

        if (phase == 'complete') {
          canvas.drawArc(
            Rect.fromCircle(center: geom['P']!, radius: 55),
            pi,
            -pi,
            true,
            Paint()
              ..color = cEmerald.withOpacity(0.2)
              ..style = PaintingStyle.fill,
          );

          String sumStr =
              pieces.map((p) => '${p.val.round()}°').join(' + ') + ' = 180°';
          TextPainter tp = TextPainter(
            text: TextSpan(
              text: sumStr,
              style: const TextStyle(
                color: cEmerald,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          tp.paint(
            canvas,
            Offset(geom['P']!.dx - tp.width / 2, geom['P']!.dy - 70),
          );
        }
      }

      if (scenario == 5 && phase == 'complete') {
        TextPainter tp = TextPainter(
          text: const TextSpan(
            text: '∠B + ∠A + ∠C = A Straight Line = 180°',
            style: TextStyle(
              color: cEmerald,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(geom['A']!.dx - tp.width / 2, geom['A']!.dy - 70),
        );
      }

      if (phase == 'animating') {
        double e =
            animValue < 0.5
                ? 2 * animValue * animValue
                : -1 + (4 - 2 * animValue) * animValue;

        for (var p in pieces) {
          var curP = p.clone();
          curP.x = p.origin.dx + (p.dest.dx - p.origin.dx) * e;
          curP.y = p.origin.dy + (p.dest.dy - p.origin.dy) * e;
          curP.start = p.originStart + (p.destStart - p.originStart) * e;
          curP.end = p.originEnd + (p.destEnd - p.originEnd) * e;
          curP.animating = true;
          _drawAnglePiece(canvas, curP);
        }
      } else {
        for (var p in pieces.where((ep) => ep.detached && ep.id != 'A')) {
          if (draggedPiece?.id == p.id && scenario == 5) {
            try {
              var orig = initialPieces.firstWhere((ip) => ip.id == p.id);
              _drawAnglePiece(canvas, orig, isGhost: true);
            } catch (_) {}
          }
          _drawAnglePiece(canvas, p);
        }

        try {
          var pA = pieces.firstWhere((ep) => ep.id == 'A');
          if (scenario != 5 && pA.detached) _drawAnglePiece(canvas, pA);
        } catch (_) {}
      }
    }

    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 5;
    const double dashSpace = 5;
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double distance = sqrt(dx * dx + dy * dy);
    double dashCount = distance / (dashWidth + dashSpace);

    double xStep = dx / dashCount;
    double yStep = dy / dashCount;

    for (int i = 0; i < dashCount; i++) {
      double startX = p1.dx + xStep * i;
      double startY = p1.dy + yStep * i;
      double endX = startX + xStep * (dashWidth / (dashWidth + dashSpace));
      double endY = startY + yStep * (dashWidth / (dashWidth + dashSpace));
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  List<AnglePiece> _getTriangleAngles(Offset A, Offset B, Offset C) {
    double aAB = atan2(B.dy - A.dy, B.dx - A.dx);
    double aAC = atan2(C.dy - A.dy, C.dx - A.dx);
    double aBA = atan2(A.dy - B.dy, A.dx - B.dx);
    double aBC = atan2(C.dy - B.dy, C.dx - B.dx);
    double aCA = atan2(A.dy - C.dy, A.dx - C.dx);
    double aCB = atan2(B.dy - C.dy, B.dx - C.dx);

    Map<String, double> getArc(double a1, double a2) {
      double start = a1;
      double end = a2;
      double diff = (end - start) % (2 * pi);
      if (diff < 0) diff += 2 * pi;
      if (diff > pi) {
        diff = 2 * pi - diff;
        start = a2;
        end = a1;
      }
      return {
        'start': start * 180 / pi,
        'end': end * 180 / pi,
        'val': diff * 180 / pi,
      };
    }

    var arcA = getArc(aAB, aAC);
    var arcB = getArc(aBC, aBA);
    var arcC = getArc(aCA, aCB);

    double degA = arcA['val']!.roundToDouble();
    double degB = arcB['val']!.roundToDouble();
    double degC = 180 - degA - degB;

    return [
      AnglePiece(
        id: 'A',
        start: arcA['start']!,
        end: arcA['end']!,
        val: degA,
        x: A.dx,
        y: A.dy,
        color: const Color(0xFFF43F5E),
      ),
      AnglePiece(
        id: 'B',
        start: arcB['start']!,
        end: arcB['end']!,
        val: degB,
        x: B.dx,
        y: B.dy,
        color: const Color(0xFF3B82F6),
      ),
      AnglePiece(
        id: 'C',
        start: arcC['start']!,
        end: arcC['end']!,
        val: degC,
        x: C.dx,
        y: C.dy,
        color: const Color(0xFF10B981),
      ),
    ];
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}
