// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: non_constant_identifier_names, use_super_parameters, camel_case_types, constant_identifier_names

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Diagonal Detective',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const Cl6M_Ch8_A5_TheDiagonalDetective(),
    ),
  );
}

// --- AUDIO ENGINE ---
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// --- STATE MANAGEMENT ---
class AppState {
  String lang = 'en';
  bool sidebarOpen = true;
  double sidebarWidth = 350.0;

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  int scenario = 1;
  int step = 0;

  bool curtainVisible = true;
  bool showSuccessPopup = false;

  // Tools
  bool isInteractingWithTool = false;
  String? activeTool;
  String? draggedTool;
  String? activeLine;
  int dragFrom = -1;
  double dragX = 0;
  double dragY = 0;
  double dragOffsetX = 0;
  double dragOffsetY = 0;

  // Scenario 1
  Rect s1_rect = Rect.fromCenter(
    center: const Offset(0, -50),
    width: 350,
    height: 220,
  );
  bool s1_pr = false, s1_qs = false, s1_compared = false, s1_reshaped = false;

  // Scenario 2
  double s2_s = 260;
  Offset s2_pos = const Offset(0, -50);
  bool s2_pr = false,
      s2_qs = false,
      s2_compared = false,
      s2_protSnapped = false,
      s2_angleSplit = false;

  // Scenario 3
  Offset s3_c = const Offset(-150, 50);
  bool s3_cd = false,
      s3_perp = false,
      s3_compSet = false,
      s3_arc = false,
      s3_done = false;
  bool s3_compassPlaced = false;
  double s3_compMaxAngle = -math.pi;
  double s3_compRad = 0;
  Offset? s3_bPos;

  // Scenario 4
  List<Map<String, dynamic>> s4_shapes = [
    {
      'id': 'para',
      'type': 'para',
      'x': -300.0,
      'y': -50.0,
      'rot': 0.1,
      'diags': false,
    },
    {
      'id': 'rect',
      'type': 'rect',
      'x': 0.0,
      'y': -80.0,
      'rot': -0.15,
      'diags': false,
    },
    {
      'id': 'trap',
      'type': 'trap',
      'x': 300.0,
      'y': -50.0,
      'rot': 0.05,
      'diags': false,
    },
  ];
  bool s4_done = false;

  // Scenario 5
  Offset s5_a = const Offset(-160, -50);
  bool s5_ac = false,
      s5_bisector = false,
      s5_compSet = false,
      s5_marks = false,
      s5_done = false;
  double s5_compRad = 0;
}

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'appTitle': 'The Diagonal Detective',
    'appSubtitle': 'Class 6 • GEOMETRIC CONSTRUCTIONS',
    'enterLab': 'Enter Simulation',
    'selectScenario': 'Select Scenario',
    'objective': 'Objective:',
    'step': 'STEP',
    'nextScenario': 'Next Scenario',
    'finishLab': 'Finish Lab',
    'successTitle': 'Goal Reached!',
    'finalDesc':
        'You have successfully uncovered the properties of diagonals in rectangles and squares!',
    'lbl_equal': 'Diagonals are EQUAL!',
    'lbl_complete': 'Construction Complete!',
    'lbl_verify': 'Verification Zone',
    'btn_complete': 'Complete Shape',
    's1_title': "1. The Rectangle's Equalizer",
    's1_obj':
        "Visually discover and verify that the two diagonals of a rectangle are always equal in length.",
    's1_s1_task':
        "Select the 'Diagonal Tool'. Drag from corner P to opposite corner R.",
    's1_s1_out': "A blue diagonal line PR is drawn.",
    's1_s2_task':
        "Drag the 'Diagonal Tool' from corner Q to opposite corner S.",
    's1_s2_out': "A red diagonal line QS is drawn.",
    's1_s3_task':
        "Drag the red diagonal QS directly on top of the blue diagonal PR to compare them.",
    's1_s3_out': "They align perfectly! The diagonals are EQUAL.",
    's1_s4_task':
        "Drag corner S or R to reshape the rectangle. Notice the diagonals.",
    's1_s4_out':
        "No matter the shape, the diagonals of a rectangle remain equal.",
    's1_hud1': "Drag Diagonal Tool from P to R.",
    's1_hud2': "Drag Diagonal Tool from Q to S.",
    's1_hud3': "Drag the red diagonal onto the blue one.",
    's1_hud4': "Drag the corner handles to resize the rectangle.",
    's2_title': "2. The Square's Special Secret",
    's2_obj':
        "Discover that a square's diagonals are equal, and they bisect the corner angles into 45°.",
    's2_s1_task':
        "Use the 'Diagonal Tool' to draw diagonals PR and QS on the square.",
    's2_s1_out': "Two diagonals are drawn.",
    's2_s2_task': "Drag one diagonal over the other to verify their length.",
    's2_s2_out': "They align perfectly! The diagonals are EQUAL.",
    's2_s3_task':
        "Drag the 'Protractor Tool' to corner P to measure the angle.",
    's2_s3_out': "The corner angle is exactly 90°.",
    's2_s4_task':
        "Click the diagonal line near corner P to measure how it splits the angle.",
    's2_s4_out': "The 90° angle is split into two identical 45° angles.",
    's2_hud1': "Draw diagonals PR and QS.",
    's2_hud2': "Drag one diagonal onto the other.",
    's2_hud3': "Drag the Protractor to corner P.",
    's2_hud4': "Click the diagonal line near P.",
    's3_title': "3. Blueprint Construction",
    's3_obj':
        "Construct a rectangle when given the length of one base (5cm) and one diagonal (7cm).",
    's3_s1_task':
        "Select the Ruler tool. Drag horizontally from C to draw a 5cm line segment CD.",
    's3_s1_out': "A 5cm base CD is drawn.",
    's3_s2_task': "Drag the 'Perpendicular Tool' onto point C.",
    's3_s2_out': "A perpendicular guideline appears at C.",
    's3_s3_task':
        "Select the Compass. Drag its radius handle to exactly 7cm on the ruler.",
    's3_s3_out': "The compass is set to a 7cm radius.",
    's3_s4_task':
        "Drag the compass needle to D, then drag the pencil to draw an arc.",
    's3_s4_out': "Point B is found at the intersection.",
    's3_s5_task':
        "Click the 'Complete Shape' button to finalize the rectangle.",
    's3_s5_out': "The rectangle ABCD is perfectly constructed.",
    's3_hud1': "Drag from C to the right to 5cm.",
    's3_hud2': "Drag the Perpendicular Tool to point C.",
    's3_hud3': "Drag the compass handle to 7cm.",
    's3_hud4': "Drag compass to D, then drag pencil.",
    's3_hud5': "Click 'Complete Shape' button.",
    's4_title': "4. The Lineup",
    's4_obj':
        "Identify the one true rectangle from a group of similar-looking quadrilaterals using only their diagonals.",
    's4_s1_task':
        "Use the Diagonal tool to draw diagonals for the three rotated shapes.",
    's4_s1_out': "Diagonals are drawn.",
    's4_s2_task':
        "Observe which shape has equal diagonals. (You can drag them to test).",
    's4_s2_out': "Only one shape has diagonals of equal length.",
    's4_s3_task': "Drag the true rectangle into the Verification Zone.",
    's4_s3_out': "Correct! The shape with equal diagonals is the rectangle.",
    's4_hud1': "Draw diagonals on all shapes.",
    's4_hud2': "Find the shape with equal diagonals.",
    's4_hud3': "Drag the correct shape to the target zone.",
    's5_title': "5. The Ultimate Blueprint",
    's5_obj':
        "Construct a perfect square when given only the length of its diagonal (8cm).",
    's5_s1_task': "Use the Ruler to draw an 8cm diagonal line AC.",
    's5_s1_out': "An 8cm line segment AC is drawn.",
    's5_s2_task': "Drag the 'Perp Bisector Tool' onto the line AC.",
    's5_s2_out':
        "A perpendicular bisector is drawn exactly through the center.",
    's5_s3_task':
        "Set the Compass to 4cm. Drag it to the center intersection and click to mark B and D.",
    's5_s3_out': "Points B and D are marked 4cm from the center.",
    's5_s4_task':
        "Click the 'Complete Shape' button to connect all four corners.",
    's5_s4_out': "A perfect square ABCD is constructed.",
    's5_hud1': "Drag horizontally from A to 8cm.",
    's5_hud2': "Drag Perp Bisector Tool to the line AC.",
    's5_hud3': "Set compass to 4cm, drag to center, and click.",
    's5_hud4': "Click 'Complete Shape' button.",
  },
  'hi': {
    'appTitle': 'विकर्ण जासूस',
    'appSubtitle': 'कक्षा 6 • ज्यामितीय रचनाएँ',
    'enterLab': 'सिमुलेशन दर्ज करें',
    'selectScenario': 'परिदृश्य चुनें',
    'objective': 'उद्देश्य:',
    'step': 'चरण',
    'nextScenario': 'अगला परिदृश्य',
    'finishLab': 'समाप्त करें',
    'successTitle': 'लक्ष्य प्राप्त हुआ!',
    'finalDesc':
        'आपने आयत और वर्ग में विकर्णों के गुणों को सफलतापूर्वक खोज लिया है!',
    'lbl_equal': 'विकर्ण बराबर हैं!',
    'lbl_complete': 'रचना पूर्ण!',
    'lbl_verify': 'सत्यापन क्षेत्र',
    'btn_complete': 'आकार पूरा करें',
    's1_title': "1. आयत का विकर्ण",
    's1_obj':
        "नेत्रहीन रूप से खोजें और सत्यापित करें कि आयत के दो विकर्ण हमेशा लंबाई में बराबर होते हैं।",
    's1_s1_task': "P से R तक विकर्ण टूल खींचें।",
    's1_s1_out': "नीला विकर्ण PR खींचा गया है।",
    's1_s2_task': "Q से S तक विकर्ण टूल खींचें।",
    's1_s2_out': "लाल विकर्ण QS खींचा गया है।",
    's1_s3_task': "लाल विकर्ण QS को नीले विकर्ण PR के ठीक ऊपर खींचें।",
    's1_s3_out': "वे पूरी तरह संरेखित हैं! विकर्ण बराबर हैं।",
    's1_s4_task': "आयत को नया आकार देने के लिए कोने S या R को खींचें।",
    's1_s4_out': "आकार कोई भी做到, विकर्ण बराबर रहते हैं।",
    's1_hud1': "P से R तक टूल खींचें।",
    's1_hud2': "Q से S तक टूल खींचें।",
    's1_hud3': "लाल विकर्ण को नीले पर खींचें।",
    's1_hud4': "कोनों को खींचकर आकार बदलें।",
    's2_title': "2. वर्ग का विशेष रहस्य",
    's2_obj':
        "पता लगाएँ कि वर्ग के विकर्ण बराबर हैं, और वे कोनों को 45° में विभाजित करते हैं।",
    's2_s1_task': "वर्ग पर विकर्ण PR और QS खींचें।",
    's2_s1_out': "दो विकर्ण खींचे गए हैं।",
    's2_s2_task': "एक विकर्ण को दूसरे पर खींचकर लंबाई सत्यापित करें।",
    's2_s2_out': "वे पूरी तरह संरेखित हैं! विकर्ण बराबर हैं।",
    's2_s3_task': "कोण मापने के लिए P पर 'चांदा' खींचें।",
    's2_s3_out': "कोण ठीक 90° है।",
    's2_s4_task': "कोण को विभाजित करने के लिए विकर्ण पर क्लिक करें।",
    's2_s4_out': "90° कोण दो 45° कोणों में विभाजित हो गया है।",
    's2_hud1': "विकर्ण PR और QS खींचें।",
    's2_hud2': "एक विकर्ण को दूसरे पर खींचें।",
    's2_hud3': "चांदे को कोने P पर खींचें।",
    's2_hud4': "P के पास विकर्ण पर क्लिक करें।",
    's3_title': "3. ब्लूप्रिंट निर्माण",
    's3_obj': "एक आयत बनाएँ (आधार 5cm, विकर्ण 7cm)।",
    's3_s1_task': "5cm रेखा CD खींचने के लिए C से क्षैतिज रूप से खींचें।",
    's3_s1_out': "5cm का आधार खींचा गया है।",
    's3_s2_task': "'लंब टूल' को C पर खींचें।",
    's3_s2_out': "C पर लंबवत दिशा-निर्देश दिखाई देता है।",
    's3_s3_task': "परकार को 7cm पर सेट करें।",
    's3_s3_out': "परकार 7cm पर सेट है।",
    's3_s4_task': "परकार को D पर लाएं, फिर चाप खींचने के लिए पेंसिल को घुमाएं।",
    's3_s4_out': "प्रतिच्छेदन पर बिंदु B मिल गया है।",
    's3_s5_task':
        "आयत को अंतिम रूप देने के लिए 'आकार पूरा करें' बटन पर क्लिक करें।",
    's3_s5_out': "आयत ABCD पूरी तरह से निर्मित है।",
    's3_hud1': "C से दाईं ओर 5cm तक खींचें।",
    's3_hud2': "लंब टूल को C पर खींचें।",
    's3_hud3': "परकार को 7cm पर सेट करें।",
    's3_hud4': "परकार को D पर लाएं और पेंसिल खींचें।",
    's3_hud5': "बटन पर क्लिक करें।",
    's4_title': "4. सही पहचान",
    's4_obj': "केवल विकर्णों का उपयोग करके आकृतियों में से सही आयत को पहचानें।",
    's4_s1_task': "सभी आकृतियों के लिए विकर्ण खींचें।",
    's4_s1_out': "विकर्ण खींचे गए हैं।",
    's4_s2_task': "देखें कि किस आकृति के विकर्ण बराबर हैं।",
    's4_s2_out': "केवल एक आकृति के विकर्ण बराबर हैं।",
    's4_s3_task': "सही आयत को 'सत्यापन क्षेत्र' में खींचें।",
    's4_s3_out': "सही! आयत के विकर्ण बराबर हैं।",
    's4_hud1': "सभी आकृतियों पर विकर्ण खींचें।",
    's4_hud2': "बराबर विकर्ण वाली आकृति खोजें।",
    's4_hud3': "सही आकृति को बॉक्स में खींचें।",
    's5_title': "5. परम ब्लूप्रिंट",
    's5_obj': "केवल 8cm विकर्ण दिए जाने पर एक पूर्ण वर्ग बनाएँ।",
    's5_s1_task': "8cm विकर्ण रेखा AC खींचें।",
    's5_s1_out': "8cm रेखा AC खींची गई है।",
    's5_s2_task': "AC पर 'लंब समद्विभाजक टूल' खींचें।",
    's5_s2_out': "केंद्र से एक लंब समद्विभाजक खींचा गया है।",
    's5_s3_task':
        "परकार को 4cm पर सेट करें, केंद्र पर लाएँ और B, D को चिह्नित करें।",
    's5_s3_out': "बिंदु B और D चिह्नित हैं।",
    's5_s4_task': "चारों कोनों को जोड़ने के लिए बटन पर क्लिक करें।",
    's5_s4_out': "एक पूर्ण वर्ग ABCD बनाया गया है।",
    's5_hud1': "A से दाईं ओर 8cm तक खींचें।",
    's5_hud2': "साधనాన్ని AC रेखा पर खींचें।",
    's5_hud3': "परकार को 4cm पर सेट करें और केंद्र पर क्लिक करें।",
    's5_hud4': "बटन पर क्लिक करें।",
  },
};

// --- MAIN WIDGET ---
class Cl6M_Ch8_A5_TheDiagonalDetective extends StatefulWidget {
  const Cl6M_Ch8_A5_TheDiagonalDetective({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch8_A5_TheDiagonalDetective> createState() =>
      _Cl6M_Ch8_A5_TheDiagonalDetectiveState();
}

class _Cl6M_Ch8_A5_TheDiagonalDetectiveState
    extends State<Cl6M_Ch8_A5_TheDiagonalDetective>
    with SingleTickerProviderStateMixin {
  final AppState state = AppState();
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _animCtrl;
  int? _toolPointerId;

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
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _animCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String t(String key) => i18n[state.lang]?[key] ?? key;

  Map<String, dynamic> getScenarioConfig(int id) {
    int numSteps = [0, 4, 4, 5, 3, 4][id];
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'hud': t('s${id}_hud$i'),
        'task': t('s${id}_s${i}_task'),
        'out': t('s${id}_s${i}_out'),
      });
    }
    return {'title': t('s${id}_title'), 'obj': t('s${id}_obj'), 'steps': steps};
  }

  void loadScenario(int id) {
    setState(() {
      state.scenario = id;
      state.step = 0;
      state.activeTool = null;
      state.draggedTool = null;
      state.activeLine = null;
      state.showSuccessPopup = false;
      state.zoom = 1.0;
      state.panX = 0;
      state.panY = 0;
      state.isInteractingWithTool = false;
      _toolPointerId = null;

      if (id == 1) {
        state.s1_rect = Rect.fromCenter(
          center: const Offset(0, -50),
          width: 350,
          height: 220,
        );
        state.s1_pr = state.s1_qs = state.s1_compared = state.s1_reshaped =
            false;
      } else if (id == 2) {
        state.s2_pos = const Offset(0, -50);
        state.s2_pr = state.s2_qs = state.s2_compared = state.s2_protSnapped =
            state.s2_angleSplit = false;
      } else if (id == 3) {
        state.s3_c = const Offset(-150, 50);
        state.s3_cd = state.s3_perp = state.s3_compSet = state.s3_arc =
            state.s3_done = false;
        state.s3_compassPlaced = false;
        state.s3_compMaxAngle = -math.pi;
        state.s3_compRad = 0;
        state.s3_bPos = null;
      } else if (id == 4) {
        state.s4_shapes[0] = {
          'id': 'para',
          'type': 'para',
          'x': -300.0,
          'y': -50.0,
          'rot': 0.1,
          'diags': false,
        };
        state.s4_shapes[1] = {
          'id': 'rect',
          'type': 'rect',
          'x': 0.0,
          'y': -80.0,
          'rot': -0.15,
          'diags': false,
        };
        state.s4_shapes[2] = {
          'id': 'trap',
          'type': 'trap',
          'x': 300.0,
          'y': -50.0,
          'rot': 0.05,
          'diags': false,
        };
        state.s4_done = false;
      } else if (id == 5) {
        state.s5_a = const Offset(-160, -50);
        state.s5_ac = state.s5_bisector = state.s5_compSet = state.s5_marks =
            state.s5_done = false;
        state.s5_compRad = 0;
      }
    });
  }

  void advanceStep() {
    AudioEngine.playClick();
    setState(() => state.step++);
    checkScenarioSuccess();
  }

  void checkScenarioSuccess() {
    int maxSteps = getScenarioConfig(state.scenario)['steps'].length;
    if (state.step >= maxSteps) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            state.showSuccessPopup = true;
          });
          AudioEngine.playPageOpen();
        }
      });
    }
  }

  Offset _getWorldCoord(Offset localPos, BoxConstraints constraints) {
    return Offset(
      (localPos.dx - constraints.maxWidth / 2 - state.panX) / state.zoom,
      (localPos.dy - constraints.maxHeight / 2 - state.panY) / state.zoom,
    );
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  // Evaluates hits against interactive tool areas
  bool _handleToolStart(Offset pt) {
    bool handled = false;

    if (state.scenario == 1) {
      final r = state.s1_rect;
      if (state.activeTool == 'diag' &&
          !state.s1_pr &&
          state.step == 0 &&
          _hitTestBox(r.left - 30, r.top - 30, 60, 60, pt)) {
        state.activeLine = 'temp';
        state.dragFrom = 0;
        state.dragX = pt.dx;
        state.dragY = pt.dy;
        handled = true;
      } else if (state.activeTool == 'diag' &&
          !state.s1_qs &&
          state.step == 1 &&
          _hitTestBox(r.right - 30, r.top - 30, 60, 60, pt)) {
        state.activeLine = 'temp';
        state.dragFrom = 1;
        state.dragX = pt.dx;
        state.dragY = pt.dy;
        handled = true;
      } else if (state.step == 2 &&
          state.s1_qs &&
          _hitTestBox(
            r.left - 30,
            r.top - 30,
            r.width + 60,
            r.height + 60,
            pt,
          )) {
        state.activeLine = 'qs_drag';
        state.dragX = pt.dx;
        state.dragY = pt.dy;
        state.dragOffsetX = pt.dx - r.left;
        state.dragOffsetY = pt.dy - r.top;
        handled = true;
      } else if (state.step == 3 &&
          _hitTestBox(r.right - 30, r.bottom - 30, 60, 60, pt)) {
        state.activeLine = 'corner_drag';
        handled = true;
      }
    } else if (state.scenario == 2) {
      double s = state.s2_s;
      Offset c = state.s2_pos;
      if (state.activeTool == 'diag' &&
          state.step == 0 &&
          _hitTestBox(
            c.dx - s / 2 - 30,
            c.dy - s / 2 - 30,
            s + 60,
            s + 60,
            pt,
          )) {
        state.s2_pr = true;
        state.s2_qs = true;
        advanceStep();
        handled = true;
      } else if (state.step == 1 &&
          state.s2_qs &&
          _hitTestBox(
            c.dx - s / 2 - 30,
            c.dy - s / 2 - 30,
            s + 60,
            s + 60,
            pt,
          )) {
        state.draggedTool = 'qs_drag';
        state.dragX = pt.dx;
        state.dragY = pt.dy;
        state.dragOffsetX = pt.dx - c.dx;
        state.dragOffsetY = pt.dy - c.dy;
        handled = true;
      } else if (state.step == 2 && state.activeTool == 'prot') {
        state.draggedTool = 'prot';
        state.dragX = pt.dx;
        state.dragY = pt.dy;
        handled = true;
      } else if (state.step == 3 &&
          _hitTestBox(c.dx - s / 2 - 30, c.dy - s / 2 - 30, 100, 100, pt)) {
        state.s2_angleSplit = true;
        advanceStep();
        Future.delayed(const Duration(seconds: 1), checkScenarioSuccess);
        handled = true;
      }
    } else if (state.scenario == 3) {
      double s3Rulery = state.s3_c.dy + 35;
      if (state.step == 0 &&
          state.activeTool == 'ruler' &&
          _hitTestBox(state.s3_c.dx - 30, state.s3_c.dy - 30, 60, 60, pt)) {
        state.draggedTool = 'ruler_draw';
        state.dragX = pt.dx;
        handled = true;
      } else if (state.step == 1 &&
          state.activeTool == 'perp' &&
          _hitTestBox(state.s3_c.dx - 40, state.s3_c.dy - 40, 80, 80, pt)) {
        state.s3_perp = true;
        advanceStep();
        handled = true;
      } else if (state.step == 2 &&
          state.activeTool == 'comp' &&
          _hitTestBox(state.s3_c.dx - 20, s3Rulery - 20, 400, 60, pt)) {
        state.draggedTool = 'comp_set';
        handled = true;
      } else if (state.step == 3 && state.activeTool == 'comp') {
        if (!state.s3_compassPlaced) {
          if (_hitTestBox(state.s3_c.dx - 40, s3Rulery - 80, 80, 120, pt)) {
            state.draggedTool = 'comp_move';
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            handled = true;
          }
        } else {
          // Compass placed, check if user is grabbing the pencil tip to rotate
          Offset D = Offset(state.s3_c.dx + 5 * 40, state.s3_c.dy);
          Offset pencil =
              D +
              Offset(
                math.cos(state.s3_compMaxAngle) * state.s3_compRad,
                math.sin(state.s3_compMaxAngle) * state.s3_compRad,
              );
          if (_hitTestBox(pencil.dx - 60, pencil.dy - 60, 120, 120, pt)) {
            state.draggedTool = 'comp_rotate';
            handled = true;
          }
        }
      } else if (state.step == 4 && _hitTestBox(150, 200, 200, 50, pt)) {
        state.s3_done = true;
        advanceStep();
        Future.delayed(const Duration(seconds: 1), checkScenarioSuccess);
        handled = true;
      }
    } else if (state.scenario == 4) {
      if (state.step == 0 && state.activeTool == 'diag') {
        for (var shp in state.s4_shapes) {
          if (_hitTestBox(shp['x'] - 80, shp['y'] - 50, 160, 100, pt)) {
            shp['diags'] = true;
            handled = true;
          }
        }
        if (state.s4_shapes.every((x) => x['diags'] == true)) advanceStep();
      } else if (state.step >= 1) {
        if (_hitTestBox(
          state.s4_shapes[1]['x'] - 80,
          state.s4_shapes[1]['y'] - 50,
          160,
          100,
          pt,
        )) {
          state.draggedTool = 'rect_drag';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        }
      }
    } else if (state.scenario == 5) {
      double s5Rulery = state.s5_a.dy + 35;
      if (state.step == 0 &&
          state.activeTool == 'ruler' &&
          _hitTestBox(state.s5_a.dx - 30, state.s5_a.dy - 30, 60, 60, pt)) {
        state.draggedTool = 'ruler_draw';
        state.dragX = pt.dx;
        handled = true;
      } else if (state.step == 1 &&
          state.activeTool == 'bisect' &&
          _hitTestBox(-160, state.s5_a.dy - 20, 320, 40, pt)) {
        state.s5_bisector = true;
        advanceStep();
        handled = true;
      } else if (state.step == 2 && state.activeTool == 'comp') {
        if (state.s5_compSet &&
            _hitTestBox(state.s5_a.dx - 40, s5Rulery - 80, 80, 120, pt)) {
          state.draggedTool = 'comp_move';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (_hitTestBox(
          state.s5_a.dx - 20,
          s5Rulery - 20,
          400,
          60,
          pt,
        )) {
          state.draggedTool = 'comp_set';
          handled = true;
        }
      } else if (state.step == 3 &&
          !state.s5_done &&
          _hitTestBox(150, 230, 200, 50, pt)) {
        state.s5_done = true;
        advanceStep();
        Future.delayed(const Duration(seconds: 1), checkScenarioSuccess);
        handled = true;
      }
    }

    if (handled) AudioEngine.playClick();
    return handled;
  }

  void _handleToolUpdate(Offset pt) {
    if (state.activeLine == 'temp' || state.activeLine == 'qs_drag') {
      state.dragX = pt.dx;
      state.dragY = pt.dy;
    } else if (state.activeLine == 'corner_drag') {
      double nw = (pt.dx - state.s1_rect.center.dx) * 2;
      double nh = (pt.dy - state.s1_rect.center.dy) * 2;
      state.s1_rect = Rect.fromCenter(
        center: state.s1_rect.center,
        width: math.max(150.0, math.min(600.0, nw.abs())),
        height: math.max(150.0, math.min(450.0, nh.abs())),
      );
      state.s1_reshaped = true;
    }

    if (state.draggedTool == 'qs_drag') {
      state.dragX = pt.dx;
      state.dragY = pt.dy;
    }
    if (state.draggedTool == 'prot') {
      state.dragX = pt.dx;
      state.dragY = pt.dy;
    }
    if (state.draggedTool == 'ruler_draw') {
      state.dragX = pt.dx;
    }
    if (state.draggedTool == 'comp_set') {
      double anchorX = state.scenario == 3 ? state.s3_c.dx : state.s5_a.dx;
      state.dragX = math.max(anchorX, math.min(anchorX + 10 * 40, pt.dx));
    }
    if (state.draggedTool == 'comp_move') {
      state.dragX = pt.dx;
      state.dragY = pt.dy;
    }
    if (state.draggedTool == 'comp_rotate' && state.scenario == 3) {
      Offset D = Offset(state.s3_c.dx + 5 * 40, state.s3_c.dy);
      double angle = math.atan2(pt.dy - D.dy, pt.dx - D.dx);
      // Ensure the angle draws outwards to the right properly (-math.pi up towards negative radians)
      if (angle <= 0 && angle > state.s3_compMaxAngle) {
        state.s3_compMaxAngle = angle;
      }
    }
    if (state.draggedTool == 'rect_drag') {
      state.dragX = pt.dx;
      state.dragY = pt.dy;
    }
  }

  void _handleToolEnd() {
    bool success = false;
    bool wasDragging = false;

    if (state.activeLine != null) {
      wasDragging = true;
      if (state.activeLine == 'temp') {
        final r = state.s1_rect;
        if (state.dragFrom == 0 &&
            _hitTestBox(
              r.right - 40,
              r.bottom - 40,
              80,
              80,
              Offset(state.dragX, state.dragY),
            )) {
          state.s1_pr = true;
          advanceStep();
          success = true;
        } else if (state.dragFrom == 1 &&
            _hitTestBox(
              r.left - 40,
              r.bottom - 40,
              80,
              80,
              Offset(state.dragX, state.dragY),
            )) {
          state.s1_qs = true;
          advanceStep();
          success = true;
        }
      } else if (state.activeLine == 'qs_drag') {
        double lineCx = state.dragX - state.dragOffsetX;
        double lineCy = state.dragY - state.dragOffsetY;
        if ((Offset(lineCx, lineCy) -
                    Offset(state.s1_rect.left, state.s1_rect.top))
                .distance <
            150) {
          state.s1_compared = true;
          advanceStep();
          success = true;
        }
      } else if (state.activeLine == 'corner_drag') {
        if (state.s1_reshaped) {
          advanceStep();
          Future.delayed(const Duration(seconds: 1), checkScenarioSuccess);
          success = true;
        }
      }
      state.activeLine = null;
    }

    if (state.draggedTool != null) {
      wasDragging = true;
      if (state.draggedTool == 'qs_drag') {
        double lineCx = state.dragX - state.dragOffsetX;
        double lineCy = state.dragY - state.dragOffsetY;
        if ((Offset(lineCx, lineCy) - state.s2_pos).distance < 150) {
          state.s2_compared = true;
          advanceStep();
          success = true;
        }
      } else if (state.draggedTool == 'prot') {
        if ((Offset(state.dragX, state.dragY) -
                    Offset(
                      state.s2_pos.dx - state.s2_s / 2,
                      state.s2_pos.dy - state.s2_s / 2,
                    ))
                .distance <
            60) {
          state.s2_protSnapped = true;
          advanceStep();
          success = true;
        }
      } else if (state.draggedTool == 'ruler_draw' && state.scenario == 3) {
        if ((state.dragX - (state.s3_c.dx + 5 * 40)).abs() < 30) {
          state.s3_cd = true;
          advanceStep();
          success = true;
        }
      } else if (state.draggedTool == 'comp_set' && state.scenario == 3) {
        if ((state.s3_compRad - 7 * 40).abs() < 20) {
          state.s3_compRad = 7 * 40;
          state.s3_compSet = true;
          advanceStep();
          success = true;
        }
      } else if (state.draggedTool == 'comp_move' && state.scenario == 3) {
        Offset D = Offset(state.s3_c.dx + 5 * 40, state.s3_c.dy);
        if ((Offset(state.dragX, state.dragY) - D).distance < 50) {
          state.s3_compassPlaced = true;
          state.s3_compMaxAngle = -math
              .pi; // point needle perfectly to the left (math.pi/ -math.pi equivalent)
          success = true; // Wait for arc drawing! Don't advance yet.
          AudioEngine.playClick();
        }
      } else if (state.draggedTool == 'comp_rotate' && state.scenario == 3) {
        Offset D = Offset(state.s3_c.dx + 5 * 40, state.s3_c.dy);
        Offset A = Offset(
          state.s3_c.dx,
          state.s3_c.dy - math.sqrt(7 * 7 - 5 * 5) * 40,
        );
        double targetAngle = math.atan2(A.dy - D.dy, A.dx - D.dx);

        // Let's see if our drawn arc swept far enough to hit our target angle!
        if (state.s3_compMaxAngle >= targetAngle - 0.05) {
          state.s3_bPos = A;
          state.s3_arc = true;
          advanceStep();
          success = true;
        }
      } else if (state.draggedTool == 'rect_drag' && state.scenario == 4) {
        if (_hitTestBox(
          -120,
          180,
          240,
          110,
          Offset(state.dragX, state.dragY),
        )) {
          state.s4_shapes[1]['x'] = 0.0;
          state.s4_shapes[1]['y'] = 235.0;
          state.s4_shapes[1]['rot'] = 0.0;
          state.s4_done = true;
          advanceStep();
          Future.delayed(const Duration(seconds: 1), checkScenarioSuccess);
          success = true;
        } else {
          state.s4_shapes[1]['x'] = 0.0;
          state.s4_shapes[1]['y'] = -80.0;
        }
      } else if (state.draggedTool == 'ruler_draw' && state.scenario == 5) {
        if ((state.dragX - (-state.s5_a.dx)).abs() < 30) {
          state.s5_ac = true;
          advanceStep();
          success = true;
        }
      } else if (state.draggedTool == 'comp_set' && state.scenario == 5) {
        if ((state.s5_compRad - 4 * 40).abs() < 20) {
          state.s5_compRad = 4 * 40;
          state.s5_compSet = true;
          success = true;
          AudioEngine.playClick();
        }
      } else if (state.draggedTool == 'comp_move' && state.scenario == 5) {
        if ((Offset(state.dragX, state.dragY) - Offset(0, state.s5_a.dy))
                    .distance <
                50 &&
            state.s5_compSet) {
          state.s5_marks = true;
          advanceStep();
          success = true;
        }
      }
      state.draggedTool = null;
    }

    // Play error sound only if they actively dragged something to a wrong place
    if (wasDragging && !success) AudioEngine.playError();
  }

  Widget _buildToolbar() {
    List<Widget> tools = [];
    void addTool(String id, IconData icon, String labelKey, bool disabled) {
      bool active = state.activeTool == id;
      tools.add(
        GestureDetector(
          onTap: disabled
              ? null
              : () {
                  setState(() {
                    state.activeTool = id;
                  });
                  AudioEngine.playClick();
                },
          child: Container(
            width: 60,
            height: 75,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0x336366F1)
                  : (disabled ? Colors.transparent : const Color(0x1A64748B)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 28,
                      color: active
                          ? const Color(0xFF6366F1)
                          : (disabled
                                ? const Color(0xFF64748B)
                                : const Color(0xCC6366F1)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t(labelKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: active
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                if (disabled)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.lock, size: 12, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.scenario == 1) {
      addTool('diag', Icons.horizontal_rule_rounded, 'Diagonal', false);
    }
    if (state.scenario == 2) {
      addTool('diag', Icons.horizontal_rule_rounded, 'Diagonal', false);
      addTool('prot', Icons.av_timer_rounded, 'Protractor', state.step < 2);
    }
    if (state.scenario == 3) {
      addTool('ruler', Icons.straighten, 'Ruler', false);
      addTool('perp', Icons.vertical_align_center, 'Perp', state.step < 1);
      addTool('comp', Icons.architecture, 'Compass', state.step < 2);
    }
    if (state.scenario == 4) {
      addTool('diag', Icons.horizontal_rule_rounded, 'Diagonal', false);
    }
    if (state.scenario == 5) {
      addTool('ruler', Icons.straighten, 'Ruler', false);
      addTool('bisect', Icons.align_vertical_center, 'Bisect', state.step < 1);
      addTool('comp', Icons.architecture, 'Compass', state.step < 2);
    }

    if (tools.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xE61E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: tools),
    );
  }

  Widget _buildCurtain() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuart,
      top: state.curtainVisible ? 0 : -MediaQuery.of(context).size.height,
      left: 0,
      right: 0,
      bottom: state.curtainVisible ? 0 : MediaQuery.of(context).size.height,
      child: Container(
        color: const Color(0xFF020617),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.architecture,
                size: 100,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(height: 24),
              Text(
                t('appTitle'),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('appSubtitle'),
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  AudioEngine.curtainScreen();
                  setState(() => state.curtainVisible = false);
                  loadScenario(1);
                },
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: Text(
                  t('enterLab'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 10,
                  shadowColor: const Color(0x4D6366F1),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarActualWidth = state.sidebarOpen ? state.sidebarWidth : 0.0;

    Map<String, dynamic> config = getScenarioConfig(state.scenario);
    List<Map<String, String>> steps = config['steps'];
    String? currentHud = state.step < steps.length
        ? steps[state.step]['hud']
        : null;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: sidebarActualWidth,
              top: 0,
              bottom: 0,
              right: 0,
              child: ClipRect(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Listener(
                          onPointerDown: (event) {
                            if (_toolPointerId != null) return;
                            final pt = _getWorldCoord(
                              event.localPosition,
                              constraints,
                            );

                            bool hit = _handleToolStart(pt);
                            if (hit) {
                              _toolPointerId = event.pointer;
                              setState(() {
                                state.isInteractingWithTool = true;
                              });
                            }
                          },
                          onPointerMove: (event) {
                            if (event.pointer == _toolPointerId) {
                              final pt = _getWorldCoord(
                                event.localPosition,
                                constraints,
                              );
                              setState(() {
                                _handleToolUpdate(pt);
                              });
                            }
                          },
                          onPointerUp: (event) {
                            if (event.pointer == _toolPointerId) {
                              setState(() {
                                _handleToolEnd();
                                state.isInteractingWithTool = false;
                                _toolPointerId = null;
                              });
                            }
                          },
                          onPointerCancel: (event) {
                            if (event.pointer == _toolPointerId) {
                              setState(() {
                                state.isInteractingWithTool = false;
                                state.activeLine = null;
                                state.draggedTool = null;
                                _toolPointerId = null;
                              });
                            }
                          },
                          child: GestureDetector(
                            onScaleUpdate: (details) {
                              // Standard zoom and pan happens here IF we're not using tools
                              if (!state.isInteractingWithTool) {
                                setState(() {
                                  state.panX += details.focalPointDelta.dx;
                                  state.panY += details.focalPointDelta.dy;
                                  if (details.scale != 1.0) {
                                    state.zoom = (state.zoom * details.scale)
                                        .clamp(0.4, 3.0);
                                  }
                                });
                              }
                            },
                            child: CustomPaint(
                              key: _canvasKey,
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: CanvasPainter(
                                state: state,
                                t: t,
                                repaint: _animCtrl,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // TOOLBAR
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      top: state.sidebarOpen ? 16.0 : 60.0,
                      left: 16.0,
                      child: _buildToolbar(),
                    ),

                    // HUD
                    if (currentHud != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: math.max(300.0, screenWidth * 0.6),
                            minWidth: 300,
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xE60F172A),
                            borderRadius: BorderRadius.circular(24),
                            border: const Border(
                              top: BorderSide(
                                color: Color(0xFF6366F1),
                                width: 4,
                              ),
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
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0x336366F1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.info,
                                  color: Color(0xFF818CF8),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  currentHud,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: state.sidebarOpen ? 0 : -state.sidebarWidth,
              top: 0,
              bottom: 0,
              width: state.sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Color(0x1AFFFFFF), width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 30,
                      offset: Offset(10, 0),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.architecture,
                                  color: Color(0xFF6366F1),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t('appTitle'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    AudioEngine.playClick();
                                    setState(
                                      () => state.lang = state.lang == 'en'
                                          ? 'hi'
                                          : 'en',
                                    );
                                  },
                                  icon: const Icon(Icons.language, size: 16),
                                  label: Text(
                                    state.lang.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF334155),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () {
                                    AudioEngine.playClick();
                                    loadScenario(state.scenario);
                                    state.curtainVisible = true;
                                  },
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.redAccent,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF334155),
                                  ),
                                  tooltip: 'Reset Scenario',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Color(0x1AFFFFFF),
                        height: 1,
                        thickness: 1,
                      ),
                      // Body Steps & Scenarios
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('selectScenario').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: state.scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  items: List.generate(
                                    5,
                                    (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text(t('s${i + 1}_title')),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    if (v != null) {
                                      loadScenario(v);
                                      AudioEngine.playDropdown();
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0x1A6366F1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0x336366F1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.track_changes,
                                        color: Color(0xFF6366F1),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('objective'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFA5B4FC),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    config['obj'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFCBD5E1),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Steps
                            ...List.generate(steps.length, (i) {
                              bool isDone = i < state.step;
                              bool isActive = i == state.step;
                              bool isFuture = i > state.step;

                              Color bgColor = isActive
                                  ? const Color(0xFF1E293B)
                                  : (isDone
                                        ? const Color(0x1A10B981)
                                        : const Color(0x330F172A));
                              Color borderColor = isActive
                                  ? const Color(0x806366F1)
                                  : (isDone
                                        ? const Color(0x8010B981)
                                        : const Color(0x33334155));

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isDone)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF10B981),
                                        size: 28,
                                      )
                                    else
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFF6366F1)
                                              : const Color(0xFF334155),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.white
                                                  : const Color(0xFF94A3B8),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${t('step')} ${i + 1}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Task: ${steps[i]['task']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isFuture
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              color: isFuture
                                                  ? const Color(0xFF64748B)
                                                  : const Color(0xFFA5B4FC),
                                            ),
                                          ),
                                          if (isDone) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0x336366F1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Outcome: ${steps[i]['out']}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFC7D2FE),
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
                      // Footer
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        color: const Color(0xFF0F172A),
                        child: const Text(
                          '© ZeroScienceLab - Fall in love with math and Science',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Drag Resizer handle
            if (state.sidebarOpen)
              Positioned(
                left: state.sidebarWidth - 10,
                top: 0,
                bottom: 0,
                width: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() {
                        state.sidebarWidth = math.max(
                          300.0,
                          math.min(
                            screenWidth * 0.6,
                            state.sidebarWidth + details.delta.dx,
                          ),
                        );
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Container(
                        width: 4,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0x806366F1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // MENU BUTTON
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                onPressed: () {
                  AudioEngine.playClick();
                  setState(() => state.sidebarOpen = !state.sidebarOpen);
                },
                child: Icon(state.sidebarOpen ? Icons.menu_open : Icons.menu),
              ),
            ),

            // SUCCESS POPUP
            if (state.showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        width: 500,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF34D399),
                                    Color(0xFF059669),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.flag,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t('successTitle'),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t('finalDesc'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF34D399),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                AudioEngine.playClick();
                                if (state.scenario < 5) {
                                  loadScenario(state.scenario + 1);
                                } else {
                                  loadScenario(1);
                                }
                              },
                              icon: Icon(
                                state.scenario < 5
                                    ? Icons.arrow_forward
                                    : Icons.flag,
                              ),
                              label: Text(
                                state.scenario < 5
                                    ? t('nextScenario')
                                    : t('finishLab'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.scenario < 5
                                    ? const Color(0xFF4F46E5)
                                    : const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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

            // CURTAIN
            if (state.curtainVisible) _buildCurtain(),
          ],
        ),
      ),
    );
  }
}

// --- CANVAS PAINTER ---
class CanvasPainter extends CustomPainter {
  final AppState state;
  final Function(String) t;
  static const double CM_PX = 40.0;

  CanvasPainter({
    required this.state,
    required this.t,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    _drawGrid(canvas, size);

    if (state.scenario == 1) {
      _renderS1(canvas);
    } else if (state.scenario == 2) {
      _renderS2(canvas);
    } else if (state.scenario == 3) {
      _renderS3(canvas);
    } else if (state.scenario == 4) {
      _renderS4(canvas);
    } else if (state.scenario == 5) {
      _renderS5(canvas);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0x266366F1)
      ..strokeWidth = 1.5;
    final paintDot = Paint()..color = const Color(0x596366F1);
    double step = 60;

    double left = (-size.width / 2 - state.panX) / state.zoom;
    double right = (size.width / 2 - state.panX) / state.zoom;
    double top = (-size.height / 2 - state.panY) / state.zoom;
    double bottom = (size.height / 2 - state.panY) / state.zoom;

    left = (left / step).floor() * step - step;
    right = (right / step).ceil() * step + step;
    top = (top / step).floor() * step - step;
    bottom = (bottom / step).ceil() * step + step;

    for (double x = left; x <= right; x += step) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paintLine);
    }
    for (double y = top; y <= bottom; y += step) {
      canvas.drawLine(Offset(left, y), Offset(right, y), paintLine);
    }

    for (double x = left; x <= right; x += step) {
      for (double y = top; y <= bottom; y += step) {
        canvas.drawCircle(Offset(x, y), 2, paintDot);
      }
    }
  }

  void _drawShapeBox(
    Canvas canvas,
    List<Offset> pts, {
    bool fill = true,
    Color strokeColor = const Color(0xFF94A3B8),
  }) {
    Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();

    if (fill) {
      canvas.drawShadow(path, Colors.black, 10, false);
      canvas.drawPath(path, Paint()..color = const Color(0xFF1E293B));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawPoint(
    Canvas canvas,
    Offset pt,
    String label, {
    Offset offset = const Offset(-25, -25),
  }) {
    canvas.drawCircle(pt, 6, Paint()..color = const Color(0xFF6366F1));
    canvas.drawCircle(
      pt,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    Offset lblPt = pt + offset;

    Rect r = Rect.fromCenter(
      center: lblPt,
      width: tp.width + 20,
      height: tp.height + 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      Paint()..color = const Color(0xFF6366F1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(8)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    tp.paint(canvas, lblPt - Offset(tp.width / 2, tp.height / 2));
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
      ..strokeCap = StrokeCap.round;
    if (dashed) {
      double dist = (p2 - p1).distance;
      Offset dir = (p2 - p1) / dist;
      for (double i = 0; i < dist; i += 24) {
        double e = math.min(i + 12, dist);
        canvas.drawLine(p1 + dir * i, p1 + dir * e, paint);
      }
    } else {
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawTextOutline(
    Canvas canvas,
    String text,
    Offset center,
    Color fill,
    double fontSize,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: fill,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final tpStroke = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    Offset p = center - Offset(tp.width / 2, tp.height / 2);
    tpStroke.paint(canvas, p);
    tp.paint(canvas, p);
  }

  void _drawRuler(Canvas canvas, Offset p) {
    double rw = 500, rh = 50;
    Rect r = Rect.fromLTWH(p.dx, p.dy, rw, rh);
    canvas.drawShadow(
      Path()..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(6))),
      Colors.black,
      8,
      false,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()..color = const Color(0xD9FFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(p.dx, p.dy, rw, 6),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
      Paint()..color = const Color(0x330EA5E9),
    );

    Paint textPaint = Paint()..color = const Color(0xFF0F172A);
    for (int i = 0; i <= 10; i++) {
      double rx = p.dx + 20 + i * CM_PX;
      canvas.drawRect(Rect.fromLTWH(rx - 1, p.dy, 2, 20), textPaint);
      TextPainter(
          text: TextSpan(
            text: '$i',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, Offset(rx - 5, p.dy + 32));
      if (i < 10) {
        for (int j = 1; j < 10; j++) {
          canvas.drawRect(
            Rect.fromLTWH(
              rx + j * (CM_PX / 10) - 0.5,
              p.dy,
              1,
              j == 5 ? 12 : 7,
            ),
            textPaint,
          );
        }
      }
    }
  }

  void _drawProtractor(Canvas canvas, Offset p) {
    canvas.save();
    canvas.translate(p.dx, p.dy);

    Path body = Path()
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: 120),
        math.pi,
        math.pi,
        true,
      )
      ..lineTo(120, 20)
      ..lineTo(-120, 20)
      ..close();
    canvas.drawShadow(body, Colors.black, 8, false);
    canvas.drawPath(body, Paint()..color = const Color(0xD9FFFFFF));
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawPath(
      Path()
        ..arcTo(
          Rect.fromCircle(center: Offset.zero, radius: 60),
          math.pi,
          math.pi,
          true,
        )
        ..lineTo(60, 0)
        ..lineTo(-60, 0)
        ..close(),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(Offset.zero, 5, Paint()..color = const Color(0xFFEF4444));

    for (int a = 0; a <= 180; a += 10) {
      double rad = a * math.pi / 180;
      double len = a % 90 == 0
          ? 15
          : a % 45 == 0
          ? 12
          : 8;
      canvas.drawLine(
        Offset(-120 * math.cos(rad), -120 * math.sin(rad)),
        Offset(-(120 - len) * math.cos(rad), -(120 - len) * math.sin(rad)),
        Paint()
          ..color = const Color(0xFF0F172A)
          ..strokeWidth = 2,
      );
      if (a % 30 == 0 && a != 0 && a != 180) {
        _drawTextOutline(
          canvas,
          '$a°',
          Offset(-(120 - 25) * math.cos(rad), -(120 - 25) * math.sin(rad)),
          const Color(0xFF0F172A),
          12,
        );
      }
    }
    _drawTextOutline(
      canvas,
      "90°",
      const Offset(0, -85),
      const Color(0xFFEF4444),
      16,
    );
    canvas.restore();
  }

  void _drawCompass(
    Canvas canvas,
    Offset p,
    double radiusPx, [
    double angle = 0,
  ]) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(angle);

    double hx = radiusPx / 2;
    double hy = -150;
    double d = math.sqrt(hx * hx + hy * hy);

    Paint stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    // Left (Needle)
    canvas.save();
    canvas.translate(hx, hy);
    canvas.rotate(math.atan2(-hy, -hx) - math.pi / 2);
    Path pLeft = Path()
      ..moveTo(-7, 0)
      ..lineTo(-5, d - 35)
      ..lineTo(5, d - 35)
      ..lineTo(7, 0)
      ..close();
    canvas.drawPath(pLeft, Paint()..color = const Color(0xFF475569));
    canvas.drawPath(pLeft, stroke);
    Path ptLeft = Path()
      ..moveTo(-3, d - 35)
      ..lineTo(0, d)
      ..lineTo(3, d - 35)
      ..close();
    canvas.drawPath(ptLeft, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawPath(ptLeft, stroke);
    canvas.drawLine(
      Offset(0, d - 35),
      Offset(0, d - 8),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 1,
    );
    canvas.restore();

    // Right (Pencil)
    canvas.save();
    canvas.translate(hx, hy);
    canvas.rotate(math.atan2(-hy, hx) - math.pi / 2);
    Path pRight = Path()
      ..moveTo(-7, 0)
      ..lineTo(-5, d - 40)
      ..lineTo(5, d - 40)
      ..lineTo(7, 0)
      ..close();
    canvas.drawPath(pRight, Paint()..color = const Color(0xFF475569));
    canvas.drawPath(pRight, stroke);
    Path pWood = Path()
      ..moveTo(-5, d - 40)
      ..lineTo(0, d - 10)
      ..lineTo(5, d - 40)
      ..close();
    canvas.drawPath(pWood, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawPath(pWood, stroke);
    Path pGraphite = Path()
      ..moveTo(-2, d - 22)
      ..lineTo(0, d)
      ..lineTo(2, d - 22)
      ..close();
    canvas.drawPath(pGraphite, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(pGraphite, stroke);
    canvas.restore();

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx - 8, hy - 40, 16, 30),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx - 8, hy - 40, 16, 30),
        const Radius.circular(8),
      ),
      stroke,
    );
    canvas.drawCircle(
      Offset(hx, hy),
      16,
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawCircle(Offset(hx, hy), 16, stroke);
    canvas.drawCircle(Offset(hx, hy), 5, Paint()..color = Colors.white);

    canvas.restore();
  }

  void _drawPencilTool(Canvas canvas, Offset p) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(math.pi / 5);

    Path wood = Path()
      ..moveTo(0, 0)
      ..lineTo(-6, -18)
      ..lineTo(6, -18)
      ..close();
    canvas.drawShadow(wood, Colors.black, 6, false);
    canvas.drawPath(wood, Paint()..color = const Color(0xFFFDE047));
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-2, -6)
        ..lineTo(2, -6)
        ..close(),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-6, -18)
        ..lineTo(-6, -80)
        ..lineTo(6, -80)
        ..lineTo(6, -18)
        ..close(),
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-6, -80)
        ..lineTo(6, -80)
        ..lineTo(6, -90)
        ..lineTo(-6, -90)
        ..close(),
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-6, -90)
        ..lineTo(6, -90)
        ..lineTo(6, -100)
        ..lineTo(-6, -100)
        ..close(),
      Paint()..color = const Color(0xFFF43F5E),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-6, -18)
        ..lineTo(-6, -100)
        ..lineTo(6, -100)
        ..lineTo(6, -18)
        ..close(),
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  void _drawSpeechBubble(Canvas canvas, String text, Offset center) {
    Rect r = Rect.fromCenter(center: center, width: 200, height: 50);
    canvas.drawShadow(
      Path()..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(12))),
      Colors.black,
      8,
      false,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(12)),
      Paint()..color = const Color(0xFFFEF08A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(12)),
      Paint()
        ..color = const Color(0xFFCA8A04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    Path pointer = Path()
      ..moveTo(center.dx - 10, center.dy - 25)
      ..lineTo(center.dx, center.dy - 40)
      ..lineTo(center.dx + 10, center.dy - 25)
      ..close();
    canvas.drawPath(pointer, Paint()..color = const Color(0xFFFEF08A));
    _drawTextOutline(canvas, text, center, const Color(0xFF1E1B4B), 16);
  }

  // --- SCENARIO RENDERERS ---

  void _renderS1(Canvas canvas) {
    Rect r = state.s1_rect;
    List<Offset> pts = [
      Offset(r.left, r.top),
      Offset(r.right, r.top),
      Offset(r.right, r.bottom),
      Offset(r.left, r.bottom),
    ];
    _drawShapeBox(canvas, pts);

    int prLen = math.sqrt(r.width * r.width + r.height * r.height).round();

    if (state.s1_pr) {
      _drawLine(canvas, pts[0], pts[2], const Color(0xFF3B82F6), 6);
      _drawTextOutline(
        canvas,
        '$prLen cm',
        r.center - const Offset(40, 30),
        const Color(0xFF3B82F6),
        16,
      );
    }
    if (state.s1_qs && state.activeLine != 'qs_drag') {
      _drawLine(canvas, pts[1], pts[3], const Color(0xFFEF4444), 6);
      _drawTextOutline(
        canvas,
        '$prLen cm',
        r.center + const Offset(40, 30),
        const Color(0xFFEF4444),
        16,
      );
    }

    if (state.activeLine == 'temp') {
      _drawLine(
        canvas,
        Offset(state.dragX, state.dragY),
        pts[state.dragFrom],
        state.dragFrom == 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
        4,
        dashed: true,
      );
      _drawPencilTool(canvas, Offset(state.dragX, state.dragY));
    } else if (state.activeLine == 'qs_drag') {
      double lineCx = state.dragX - state.dragOffsetX;
      double lineCy = state.dragY - state.dragOffsetY;
      _drawLine(
        canvas,
        Offset(lineCx - r.width / 2, lineCy + r.height / 2),
        Offset(lineCx + r.width / 2, lineCy - r.height / 2),
        const Color(0xFFEF4444),
        6,
      );
    }

    if (state.s1_compared && state.step >= 3) {
      _drawLine(canvas, pts[0], pts[2], const Color(0xFFFACC15), 8);
      _drawSpeechBubble(
        canvas,
        t('lbl_equal'),
        r.center + Offset(0, r.height / 2 + 50),
      );
    }

    _drawPoint(canvas, pts[0], 'P', offset: const Offset(-30, -30));
    _drawPoint(canvas, pts[1], 'Q', offset: const Offset(30, -30));
    _drawPoint(canvas, pts[2], 'R', offset: const Offset(30, 30));
    _drawPoint(canvas, pts[3], 'S', offset: const Offset(-30, 30));

    if (state.step >= 3 && state.activeLine == null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pts[2], width: 40, height: 40),
          const Radius.circular(20),
        ),
        Paint()..color = const Color(0x334F46E5),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pts[2], width: 40, height: 40),
          const Radius.circular(20),
        ),
        Paint()
          ..color = const Color(0xFF4F46E5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _renderS2(Canvas canvas) {
    Offset c = state.s2_pos;
    double s = state.s2_s;
    List<Offset> pts = [
      Offset(c.dx - s / 2, c.dy - s / 2),
      Offset(c.dx + s / 2, c.dy - s / 2),
      Offset(c.dx + s / 2, c.dy + s / 2),
      Offset(c.dx - s / 2, c.dy + s / 2),
    ];
    _drawShapeBox(canvas, pts);

    if (state.s2_pr) {
      _drawLine(canvas, pts[0], pts[2], const Color(0xFF3B82F6), 6);
    }
    if (state.s2_qs && state.draggedTool != 'qs_drag') {
      _drawLine(canvas, pts[1], pts[3], const Color(0xFFEF4444), 6);
    }

    if (state.draggedTool == 'qs_drag') {
      double lineCx = state.dragX - state.dragOffsetX;
      double lineCy = state.dragY - state.dragOffsetY;
      _drawLine(
        canvas,
        Offset(lineCx - s / 2, lineCy + s / 2),
        Offset(lineCx + s / 2, lineCy - s / 2),
        const Color(0xFFEF4444),
        6,
      );
    }

    if (state.s2_compared && state.step >= 2) {
      _drawLine(canvas, pts[0], pts[2], const Color(0xFFFACC15), 8);
    }

    if (state.step >= 2 &&
        state.activeTool == 'prot' &&
        !state.s2_protSnapped &&
        state.draggedTool == null) {
      _drawProtractor(canvas, c + const Offset(0, 220));
    } else if (state.draggedTool == 'prot') {
      _drawProtractor(canvas, Offset(state.dragX, state.dragY));
    } else if (state.s2_protSnapped) {
      _drawProtractor(canvas, pts[0]);
      if (state.s2_angleSplit) {
        canvas.drawArc(
          Rect.fromCircle(center: pts[0], radius: 70),
          0,
          math.pi / 4,
          true,
          Paint()..color = const Color(0x6622C55E),
        );
        canvas.drawArc(
          Rect.fromCircle(center: pts[0], radius: 70),
          math.pi / 4,
          math.pi / 4,
          true,
          Paint()..color = const Color(0x66EAB308),
        );
        _drawTextOutline(
          canvas,
          "45°",
          pts[0] + const Offset(45, 18),
          const Color(0xFF0F172A),
          15,
        );
        _drawTextOutline(
          canvas,
          "45°",
          pts[0] + const Offset(18, 45),
          const Color(0xFF0F172A),
          15,
        );
      } else {
        canvas.drawArc(
          Rect.fromCircle(center: pts[0], radius: 70),
          0,
          math.pi / 2,
          true,
          Paint()..color = const Color(0x66EF4444),
        );
        _drawTextOutline(
          canvas,
          "90°",
          pts[0] + const Offset(35, 35),
          const Color(0xFF0F172A),
          18,
        );
      }
    }

    _drawPoint(canvas, pts[0], 'P', offset: const Offset(-30, -30));
    _drawPoint(canvas, pts[1], 'Q', offset: const Offset(30, -30));
    _drawPoint(canvas, pts[2], 'R', offset: const Offset(30, 30));
    _drawPoint(canvas, pts[3], 'S', offset: const Offset(-30, 30));
  }

  void _renderS3(Canvas canvas) {
    double rulerY = state.s3_c.dy + 35;
    if (!state.s3_done) _drawRuler(canvas, state.s3_c + const Offset(-20, 35));

    if (state.s3_done) {
      double dx = 5 * CM_PX;
      double hy = math.sqrt(7 * 7 - 5 * 5) * CM_PX;
      _drawShapeBox(canvas, [
        state.s3_c,
        Offset(state.s3_c.dx + dx, state.s3_c.dy),
        Offset(state.s3_c.dx + dx, state.s3_c.dy - hy),
        Offset(state.s3_c.dx, state.s3_c.dy - hy),
      ]);
    }

    _drawPoint(canvas, state.s3_c, 'C', offset: const Offset(-30, 30));

    if (state.draggedTool == 'ruler_draw') {
      _drawLine(
        canvas,
        state.s3_c,
        Offset(state.dragX, state.s3_c.dy),
        const Color(0xFF3B82F6),
        6,
      );
      _drawPencilTool(canvas, Offset(state.dragX, state.s3_c.dy));
    } else if (state.s3_cd) {
      _drawLine(
        canvas,
        state.s3_c,
        Offset(state.s3_c.dx + 5 * CM_PX, state.s3_c.dy),
        const Color(0xFF3B82F6),
        6,
      );
      _drawPoint(
        canvas,
        Offset(state.s3_c.dx + 5 * CM_PX, state.s3_c.dy),
        'D',
        offset: const Offset(30, 30),
      );
      _drawTextOutline(
        canvas,
        "5 cm",
        state.s3_c + Offset(2.5 * CM_PX, 20),
        const Color(0xFF0F172A),
        15,
      );
    }

    if (state.s3_perp) {
      _drawLine(
        canvas,
        state.s3_c + const Offset(0, 30),
        state.s3_c + const Offset(0, -300),
        const Color(0xFF3B82F6),
        3,
        dashed: true,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(state.s3_c.dx, state.s3_c.dy - 25, 25, 25),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0x1A3B82F6),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(state.s3_c.dx, state.s3_c.dy - 25, 25, 25),
          const Radius.circular(4),
        ),
        Paint()
          ..color = const Color(0xFF3B82F6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    if (!state.s3_done) {
      if (state.draggedTool == 'comp_set') {
        double rad = math.max(0, state.dragX - state.s3_c.dx);
        state.s3_compRad = rad;
        _drawCompass(canvas, Offset(state.s3_c.dx, rulerY), rad);
      } else if (state.s3_compSet &&
          state.activeTool == 'comp' &&
          state.draggedTool == null &&
          state.step < 4 &&
          !state.s3_compassPlaced) {
        _drawCompass(canvas, Offset(state.s3_c.dx, rulerY), state.s3_compRad);
      }
    }

    if (state.draggedTool == 'comp_move') {
      _drawCompass(canvas, Offset(state.dragX, state.dragY), state.s3_compRad);
    }

    // DRAW COMPASS & ARC WHEN PLACED AT 'D' FOR USER TO ROTATE
    if (state.s3_compassPlaced && !state.s3_done) {
      Offset D = Offset(state.s3_c.dx + 5 * CM_PX, state.s3_c.dy);

      // Arc logic drawing from starting -PI up to the drawn max sweeping angle towards upper-right
      if (state.s3_compMaxAngle > -math.pi) {
        canvas.drawArc(
          Rect.fromCircle(center: D, radius: state.s3_compRad),
          -math.pi,
          state.s3_compMaxAngle - (-math.pi),
          false,
          Paint()
            ..color = const Color(0xFFF59E0B)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }

      _drawCompass(canvas, D, state.s3_compRad, state.s3_compMaxAngle);
    }

    // ARC DONE STATE
    if (state.s3_arc && state.s3_bPos != null) {
      Offset D = Offset(state.s3_c.dx + 5 * CM_PX, state.s3_c.dy);
      canvas.drawArc(
        Rect.fromCircle(center: D, radius: state.s3_compRad),
        -math.pi,
        state.s3_compMaxAngle - (-math.pi),
        false,
        Paint()
          ..color = const Color(0xFFF59E0B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      _drawPoint(canvas, state.s3_bPos!, 'B', offset: const Offset(30, -30));
      _drawLine(
        canvas,
        D,
        state.s3_bPos!,
        const Color(0xFFFACC15),
        3,
        dashed: true,
      );
      _drawTextOutline(
        canvas,
        "7 cm",
        Offset(
          (state.s3_c.dx + 5 * CM_PX + state.s3_bPos!.dx) / 2 + 25,
          (state.s3_c.dy + state.s3_bPos!.dy) / 2,
        ),
        const Color(0xFFB45309),
        15,
      );
    }

    if (state.s3_done) {
      _drawPoint(
        canvas,
        Offset(state.s3_c.dx, state.s3_bPos!.dy),
        'A',
        offset: const Offset(-30, -30),
      );
      _drawSpeechBubble(canvas, t('lbl_complete'), const Offset(0, -300));
    } else if (state.step == 4) {
      Rect btnRect = const Rect.fromLTWH(150, 200, 200, 50);
      canvas.drawRRect(
        RRect.fromRectAndRadius(btnRect, const Radius.circular(12)),
        Paint()..color = const Color(0xFF4F46E5),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(btnRect, const Radius.circular(12)),
        Paint()
          ..color = const Color(0xFF3730A3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      _drawTextOutline(
        canvas,
        t('btn_complete'),
        btnRect.center,
        Colors.white,
        16,
      );
    }
  }

  void _renderS4(Canvas canvas) {
    Rect vz = const Rect.fromLTWH(-120, 180, 240, 110);
    canvas.drawRRect(
      RRect.fromRectAndRadius(vz, const Radius.circular(16)),
      Paint()..color = const Color(0x1A22C55E),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vz, const Radius.circular(16)),
      Paint()
        ..color = const Color(0xFF22C55E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    _drawTextOutline(
      canvas,
      t('lbl_verify'),
      const Offset(0, 235),
      const Color(0xFF4ADE80),
      18,
    );

    for (var shp in state.s4_shapes) {
      canvas.save();
      canvas.translate(shp['x'], shp['y']);
      canvas.rotate(shp['rot']);
      double w = 160, h = 100;
      List<Offset> pts = [];
      if (shp['type'] == 'rect') {
        pts = [
          Offset(-w / 2, -h / 2),
          Offset(w / 2, -h / 2),
          Offset(w / 2, h / 2),
          Offset(-w / 2, h / 2),
        ];
      } else if (shp['type'] == 'para') {
        pts = [
          Offset(-w / 2 + 20, -h / 2),
          Offset(w / 2 + 20, -h / 2),
          Offset(w / 2 - 20, h / 2),
          Offset(-w / 2 - 20, h / 2),
        ];
      } else if (shp['type'] == 'trap') {
        pts = [
          Offset(-w / 4, -h / 2),
          Offset(w / 4, -h / 2),
          Offset(w / 2, h / 2),
          Offset(-w / 2, h / 2),
        ];
      }

      if (shp['id'] == 'rect' && state.s4_done) {
        _drawShapeBox(canvas, pts, strokeColor: const Color(0xFF22C55E));
      } else {
        _drawShapeBox(canvas, pts);
      }

      if (shp['diags'] == true) {
        _drawLine(canvas, pts[0], pts[2], const Color(0xFF3B82F6), 5);
        _drawLine(canvas, pts[1], pts[3], const Color(0xFFEF4444), 5);
      }
      canvas.restore();
    }

    if (state.draggedTool == 'rect_drag') {
      canvas.save();
      canvas.translate(state.dragX, state.dragY);
      canvas.rotate(-0.15);
      _drawShapeBox(canvas, const [
        Offset(-80, -50),
        Offset(80, -50),
        Offset(80, 50),
        Offset(-80, 50),
      ]);
      _drawLine(
        canvas,
        const Offset(-80, -50),
        const Offset(80, 50),
        const Color(0xFF3B82F6),
        5,
      );
      _drawLine(
        canvas,
        const Offset(80, -50),
        const Offset(-80, 50),
        const Color(0xFFEF4444),
        5,
      );
      canvas.restore();
    }
  }

  void _renderS5(Canvas canvas) {
    double rulerY = state.s5_a.dy + 35;
    if (!state.s5_done) _drawRuler(canvas, state.s5_a + const Offset(-20, 35));

    if (state.s5_done) {
      _drawShapeBox(canvas, [
        state.s5_a,
        Offset(0, state.s5_a.dy - 160),
        Offset(-state.s5_a.dx, state.s5_a.dy),
        Offset(0, state.s5_a.dy + 160),
      ]);
      _drawSpeechBubble(canvas, t('lbl_complete'), const Offset(0, -280));
    }

    _drawPoint(canvas, state.s5_a, 'A', offset: const Offset(-30, 30));

    if (state.draggedTool == 'ruler_draw') {
      _drawLine(
        canvas,
        state.s5_a,
        Offset(state.dragX, state.s5_a.dy),
        const Color(0xFF3B82F6),
        6,
      );
      _drawPencilTool(canvas, Offset(state.dragX, state.s5_a.dy));
    } else if (state.s5_ac) {
      _drawLine(
        canvas,
        state.s5_a,
        Offset(-state.s5_a.dx, state.s5_a.dy),
        const Color(0xFF3B82F6),
        6,
      );
      _drawPoint(
        canvas,
        Offset(-state.s5_a.dx, state.s5_a.dy),
        'C',
        offset: const Offset(30, 30),
      );
      _drawTextOutline(
        canvas,
        "8 cm",
        Offset(0, state.s5_a.dy + 25),
        const Color(0xFF0F172A),
        15,
      );
    }

    if (state.s5_bisector) {
      _drawLine(
        canvas,
        Offset(0, state.s5_a.dy - 250),
        Offset(0, state.s5_a.dy + 250),
        const Color(0xFFE11D48),
        3,
        dashed: true,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, state.s5_a.dy - 25, 25, 25),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0x1AE11D48),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, state.s5_a.dy - 25, 25, 25),
          const Radius.circular(4),
        ),
        Paint()
          ..color = const Color(0xFFE11D48)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    if (!state.s5_done) {
      if (state.draggedTool == 'comp_set') {
        double rad = math.max(0, state.dragX - state.s5_a.dx);
        state.s5_compRad = rad;
        _drawCompass(canvas, Offset(state.s5_a.dx, rulerY), rad);
      } else if (state.s5_compSet &&
          state.activeTool == 'comp' &&
          state.draggedTool == null &&
          state.step < 3) {
        _drawCompass(canvas, Offset(state.s5_a.dx, rulerY), state.s5_compRad);
      }
    }

    if (state.draggedTool == 'comp_move') {
      _drawCompass(canvas, Offset(state.dragX, state.dragY), state.s5_compRad);
    }

    if (state.s5_marks) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(0, state.s5_a.dy), radius: 4 * CM_PX),
        1.2 * math.pi,
        0.6 * math.pi,
        false,
        Paint()
          ..color = const Color(0xFFFACC15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(0, state.s5_a.dy), radius: 4 * CM_PX),
        0.2 * math.pi,
        0.6 * math.pi,
        false,
        Paint()
          ..color = const Color(0xFFFACC15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      _drawPoint(
        canvas,
        Offset(0, state.s5_a.dy - 160),
        'D',
        offset: const Offset(0, -35),
      );
      _drawPoint(
        canvas,
        Offset(0, state.s5_a.dy + 160),
        'B',
        offset: const Offset(0, 35),
      );
    }

    if (!state.s5_done && state.step == 3) {
      Rect btnRect = const Rect.fromLTWH(150, 230, 200, 50);
      canvas.drawRRect(
        RRect.fromRectAndRadius(btnRect, const Radius.circular(12)),
        Paint()..color = const Color(0xFF4F46E5),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(btnRect, const Radius.circular(12)),
        Paint()
          ..color = const Color(0xFF3730A3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      _drawTextOutline(
        canvas,
        t('btn_complete'),
        btnRect.center,
        Colors.white,
        16,
      );
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => true;
}
