// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, non_constant_identifier_names, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, deprecated_member_use

import 'dart:math';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/gestures.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f172a),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366f1),
          secondary: Color(0xFFf59e0b),
          surface: Color(0xFF1e293b),
        ),
      ),
      home: const Cl6M_Ch2_A2_UnderstandingAnglesandTheirComponents(),
    ),
  );
}

// --- LOCALIZATION DATA ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': 'Understanding Angles and Their Components',
    'appTitle': 'Understanding Angles',
    'appSubtitle': 'Class 6 • GEOMETRY FUNDAMENTALS',
    'enterLab': 'Enter Simulation',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'learnLbl': 'Observations:',
    'summaryTitle': 'Goal Reached!',
    'resetBtn': 'Reset',
    'finishLab': 'Finish Lab',
    'nextScenario': 'Next Scenario',
    'finalDesc': 'You have successfully explored the components of angles!',
    'lbl_toolbox': 'Components',
    'lbl_vertex': 'Vertex',
    'lbl_arm1': 'Arm 1',
    'lbl_arm2': 'Arm 2',
    'lbl_blades': 'Arms',
    'lbl_angle': 'Angle',
    'lbl_swap': 'Swap Name',
    'lbl_grab': 'Grab',
    'lbl_success_angle':
        'Congratulations! You have built an angle.\nIt has one vertex and two arms.',
    'lbl_scissor_obs':
        'The size of an angle is the amount of turn between its arms.\nMore turn = bigger angle. Less turn = smaller angle.',
    'lbl_namer_obs':
        'Correct! The vertex must always be the middle letter.\n∠PQR and ∠RQP are both correct names.',
    'lbl_shipA': 'Ship A',
    'lbl_shipB': 'Ship B',
    's1_title': '1. The Angle-Building Machine',
    's1_obj':
        'Construct a basic angle by identifying and assembling its fundamental parts.',
    's1_step1_task': 'DRAG the Vertex Point into the central workspace.',
    's1_step1_out': 'The vertex is the corner point.',
    's1_step2_task':
        'DRAG one Ray and CONNECT its starting point to the Vertex.',
    's1_step2_out': 'The first straight line forming the corner is an Arm.',
    's1_step3_task': 'DRAG the second Ray to the same Vertex.',
    's1_step3_out': 'Two arms meeting at a vertex form an Angle.',
    's1_step4_task': 'CLICK on the vertex and then on each arm.',
    's1_step4_out': 'Learning: An angle has one vertex and two arms.',
    's2_title': '2. The Scissor Snip',
    's2_obj':
        'Understand that an angle\'s size is a measure of rotation or opening.',
    's2_step1_task': 'CLICK on the pivot point of the scissors.',
    's2_step1_out': 'The pivot point acts as the vertex.',
    's2_step2_task': 'DRAG the top handle UPWARDS to open them.',
    's2_step2_out':
        'The angle increases as the rotation between the blades increases.',
    's2_step3_task': 'DRAG the top handle DOWNWARDS to close them.',
    's2_step3_out': 'The angle decreases as rotation decreases.',
    's2_step4_task': 'Observe the animation summarizing the concept.',
    's2_step4_out': 'Learning: Angle size = amount of turn between arms.',
    's3_title': '3. The Angle Namer',
    's3_obj':
        'Learn the correct convention for naming an angle using three points.',
    's3_step1_task': 'DRAG the vertex letter Q into the middle slot.',
    's3_step1_out': 'The vertex must be the middle letter.',
    's3_step2_task': 'DRAG P and R into the first and third slots.',
    's3_step2_out': 'The angle is named ∠PQR.',
    's3_step3_task': 'CLICK the Swap Name button.',
    's3_step3_out': 'Learning: Both ∠PQR and ∠RQP are correct.',
    's4_title': '4. The Lighthouse Beacon',
    's4_obj':
        'Apply the concept of an angle to solve a practical navigation problem.',
    's4_step1_task': 'CLICK the lighthouse to activate it.',
    's4_step1_out': 'The lighthouse is the vertex.',
    's4_step2_task':
        'DRAG the ends of the two light beams until they point directly at Ship A and Ship B.',
    's4_step2_out':
        'The angle formed allows the lighthouse to see both ships at once.',
    's5_title': '5. The Robot Arm Challenge',
    's5_obj': 'Manipulate two connected angles to position a robotic arm.',
    's5_step1_task': 'DRAG the upper arm segment to rotate the shoulder.',
    's5_step1_out': 'The shoulder joint acts as the first vertex.',
    's5_step2_task': 'DRAG the forearm segment to rotate the elbow.',
    's5_step2_out': 'The elbow joint is the second vertex.',
    's5_step3_task': 'Position the gripper over the crate and CLICK Grab.',
    's5_step3_out':
        'Learning: Combining specific angles allows precise positioning.',
  },
  'hi': {
    'shutterTitle': 'कोण और उनके घटकों को समझना',
    'appTitle': 'कोणों को समझना',
    'appSubtitle': 'कक्षा 6 • ज्यामिति की मूल बातें',
    'enterLab': 'सिमुलेशन दर्ज करें',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'learnLbl': 'अवलोकन:',
    'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
    'resetBtn': 'रीसेट',
    'finishLab': 'समाप्त करें',
    'nextScenario': 'अगला परिदृश्य',
    'finalDesc': 'आपने कोणों के घटकों का सफलतापूर्वक पता लगाया है!',
    'lbl_toolbox': 'घटक',
    'lbl_vertex': 'शीर्ष (Vertex)',
    'lbl_arm1': 'भुजा 1',
    'lbl_arm2': 'भुजा 2',
    'lbl_blades': 'भुजाएं',
    'lbl_angle': 'कोण',
    'lbl_swap': 'नाम बदलें',
    'lbl_grab': 'पकड़ें',
    'lbl_success_angle':
        'बधाई हो! आपने एक कोण बनाया है।\nइसका एक शीर्ष और दो भुजाएँ हैं।',
    'lbl_scissor_obs':
        'कोण का आकार उसकी भुजाओं के बीच घुमाव की मात्रा है।\nअधिक घुमाव = बड़ा कोण। कम घुमाव = छोटा कोण।',
    'lbl_namer_obs':
        'सही! शीर्ष हमेशा बीच का अक्षर होना चाहिए।\n∠PQR और ∠RQP दोनों सही नाम हैं।',
    'lbl_shipA': 'जहाज A',
    'lbl_shipB': 'जहाज B',
    's1_title': '1. कोण बनाने वाली मशीन',
    's1_obj': 'इसके मूल भागों की पहचान करके और उन्हें जोड़कर एक कोण बनाएँ।',
    's1_step1_task': 'शीर्ष बिंदु को कार्यक्षेत्र में खींचें।',
    's1_step1_out': 'शीर्ष कोने का बिंदु है।',
    's1_step2_task': 'एक किरण को खींचें और उसे शीर्ष से जोड़ें।',
    's1_step2_out': 'कोना बनाने वाली पहली सीधी रेखा एक भुजा है।',
    's1_step3_task': 'दूसरी किरण को उसी शीर्ष पर खींचें।',
    's1_step3_out': 'एक शीर्ष पर मिलने वाली दो भुजाएँ एक कोण बनाती हैं।',
    's1_step4_task': 'शीर्ष पर और फिर प्रत्येक भुजा पर क्लिक करें।',
    's1_step4_out': 'सीख: एक कोण में एक शीर्ष और दो भुजाएँ होती हैं।',
    's2_title': '2. कैंची का स्निप',
    's2_obj': 'समझें कि कोण का आकार घुमाव या खुलने की एक माप है।',
    's2_step1_task': 'कैंची के धुरी बिंदु (pivot) पर क्लिक करें।',
    's2_step1_out': 'धुरी बिंदु शीर्ष के रूप में कार्य करता है।',
    's2_step2_task': 'कैंची खोलने के लिए शीर्ष हैंडल को ऊपर की ओर खींचें।',
    's2_step2_out': 'ब्लेड के बीच घुमाव बढ़ने पर कोण बढ़ता है।',
    's2_step3_task': 'कैंची बंद करने के लिए शीर्ष हैंडल को नीचे की ओर खींचें।',
    's2_step3_out': 'घुमाव कम होने पर कोण कम हो जाता है।',
    's2_step4_task': 'अवधारणा को सारांशित करने वाले एनीमेशन का निरीक्षण करें।',
    's2_step4_out': 'सीख: कोण का आकार = भुजाओं के बीच घुमाव की मात्रा।',
    's3_title': '3. कोण नामकरण',
    's3_obj': 'तीन बिंदुओं का उपयोग करके कोण के नामकरण की सही परंपरा सीखें।',
    's3_step1_task': 'शीर्ष अक्षर Q को बीच के स्लॉट में खींचें।',
    's3_step1_out': 'शीर्ष हमेशा बीच का अक्षर होना चाहिए।',
    's3_step2_task': 'P और R को पहले और तीसरे स्लॉट में खींचें।',
    's3_step2_out': 'कोण का नाम ∠PQR रखा गया है।',
    's3_step3_task': 'नाम बदलें बटन पर क्लिक करें।',
    's3_step3_out': 'सीख: ∠PQR और ∠RQP दोनों सही हैं।',
    's4_title': '4. लाइटहाउस बीकन',
    's4_obj': 'नेविगेशन समस्या को हल करने के लिए कोण की अवधारणा लागू करें।',
    's4_step1_task': 'लाइटहाउस को सक्रिय करने के लिए उस पर क्लिक करें।',
    's4_step1_out': 'लाइटहाउस शीर्ष है।',
    's4_step2_task':
        'प्रकाश की दो किरणों को तब तक खींचें जब तक कि वे जहाज A और B की ओर न हों।',
    's4_step2_out':
        'बना कोण लाइटहाउस को दोनों जहाजों को देखने की अनुमति देता है।',
    's5_title': '5. रोबोट आर्म चैलेंज',
    's5_obj':
        'रोबोटिक आर्म को स्थिति में लाने के लिए दो जुड़े हुए कोणों में हेरफेर करें।',
    's5_step1_task': 'कंधे को घुमाने के लिए ऊपरी बांह को खींचें।',
    's5_step1_out': 'कंधे का जोड़ पहले शीर्ष के रूप में कार्य करता है।',
    's5_step2_task': 'कोहनी को घुमाने के लिए अग्र-भुजा को खींचें।',
    's5_step2_out': 'कोहनी का जोड़ दूसरा शीर्ष है।',
    's5_step3_task': 'ग्रिपर को क्रेट के ऊपर रखें और पकड़ें पर क्लिक करें।',
    's5_step3_out': 'सीख: कोणों का संयोजन सटीक स्थिति की अनुमति देता है।',
  },
};

// --- GLOBAL APP STATE ---
class SimulationState extends ChangeNotifier {
  String lang = 'en';
  bool isSidebarOpen = true;
  bool isCurtainOpen = false;
  bool isSuccessPopupVisible = false;

  // Camera coordinates managed seamlessly via user multi-touch/mouse gestures
  double panX = 0, panY = 0, zoom = 1.0;
  bool isPanMode = false, isLocked = true;

  // Scenario Management
  int scenario = 1;
  int step = 0;

  // Global Animation Time
  double time = 0.0;

  // S1 State
  bool s1_vertexPlaced = false, s1_ray1Placed = false, s1_ray2Placed = false;
  bool s1_vClicked = false, s1_r1Clicked = false, s1_r2Clicked = false;
  // S2 State
  bool s2_pivotClicked = false;
  double s2_angle = 5.0;
  bool s2_animating = false;
  double s2_animProgress = 0.0;
  // S3 State
  List<String?> s3_slots = [null, null, null];
  bool s3_swapped = false;
  // S4 State
  bool s4_active = false;
  double s4_beam1 = 0.0, s4_beam2 = 0.0;
  bool s4_hitA = false, s4_hitB = false;
  // S5 State
  double s5_shoulder = -pi / 6;
  double s5_elbow = pi / 4;
  bool s5_grabbed = false;

  // Drag System
  String? activeDragEntity;
  double dragX = 0, dragY = 0;

  void toggleLanguage() {
    lang = lang == 'en' ? 'hi' : 'en';
    notifyListeners();
  }

  void loadScenario(int s) {
    scenario = s;
    step = 0;
    isSuccessPopupVisible = false;
    activeDragEntity = null;
    panX = 0;
    panY = 0;
    zoom = 1.0;
    s1_vertexPlaced = false;
    s1_ray1Placed = false;
    s1_ray2Placed = false;
    s1_vClicked = false;
    s1_r1Clicked = false;
    s1_r2Clicked = false;
    s2_pivotClicked = false;
    s2_angle = 5.0;
    s2_animating = false;
    s3_slots = [null, null, null];
    s3_swapped = false;
    s4_active = false;
    s4_beam1 = 0;
    s4_beam2 = 0;
    s4_hitA = false;
    s4_hitB = false;
    s5_shoulder = -pi / 6;
    s5_elbow = pi / 4;
    s5_grabbed = false;
    notifyListeners();
  }

  void reset() {
    isCurtainOpen = false;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 800), () {
      loadScenario(1);
      isCurtainOpen = true;
      notifyListeners();
    });
  }

  void advanceStep() {
    step++;
    notifyListeners();
  }

  int getScenarioTotalSteps() {
    if (scenario == 1) return 4;
    if (scenario == 2) return 4;
    if (scenario == 3) return 3;
    if (scenario == 4) return 2;
    if (scenario == 5) return 3;
    return 0;
  }
}

// --- MAIN SCREEN ---
class Cl6M_Ch2_A2_UnderstandingAnglesandTheirComponents extends StatefulWidget {
  const Cl6M_Ch2_A2_UnderstandingAnglesandTheirComponents({super.key});
  @override
  State<Cl6M_Ch2_A2_UnderstandingAnglesandTheirComponents> createState() =>
      _Cl6M_Ch2_A2_UnderstandingAnglesandTheirComponentsState();
}

class _Cl6M_Ch2_A2_UnderstandingAnglesandTheirComponentsState
    extends State<Cl6M_Ch2_A2_UnderstandingAnglesandTheirComponents>
    with SingleTickerProviderStateMixin {
  final SimulationState state = SimulationState();
  late Ticker _ticker;

  // Audio Players
  final AudioPlayer bgmPlayer = AudioPlayer();
  final AudioPlayer sfxPlayer = AudioPlayer();

  // Gesture State Controllers
  Offset _lastFocalPoint = Offset.zero;
  double _startZoom = 1.0;
  bool _isPanningCanvas = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      state.time = elapsed.inMilliseconds.toDouble();
      // Tick animations
      if (state.s2_animating) {
        state.s2_animProgress += 0.008; // Roughly 2 seconds at 60fps
        if (state.s2_animProgress >= 1.0) {
          state.s2_animating = false;
          state.advanceStep(); // Mark observation step as completed
          _checkSuccessDelayed();
        }
      }
      state.notifyListeners();
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    bgmPlayer.dispose();
    sfxPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      String url = '';
      if (type == 'click') {
        url = 'audio/class6/math/click.mp3';
      } else if (type == 'success') {
        url = 'audio/class6/math/success.mp3';
      } else if (type == 'snap') {
        url = 'audio/class6/math/mixkit_2573.mp3';
      } else if (type == 'error') {
        url = 'audio/class6/math/click.mp3';
      }
      if (url.isNotEmpty) await sfxPlayer.play(AssetSource(url));
    } catch (_) {}
  }

  void _checkSuccessDelayed() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (state.step >= state.getScenarioTotalSteps()) {
        state.isSuccessPopupVisible = true;
        _playSound('success');
        state.notifyListeners();
      }
    });
  }

  String t(String key) {
    return translations[state.lang]?[key] ?? key;
  }

  // Pointer Handling Math
  Offset _getCanvasPoint(Offset touchPosition, Size size) {
    double cx = touchPosition.dx - size.width / 2 - state.panX;
    double cy = touchPosition.dy - size.height / 2 - state.panY;
    return Offset(cx / state.zoom, cy / state.zoom);
  }

  bool _hitTestCircle(double cx, double cy, double r, Offset pt) {
    return (pt.dx - cx) * (pt.dx - cx) + (pt.dy - cy) * (pt.dy - cy) <= r * r;
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  // --- INSTANT HIT TESTING VIA LISTENER ---
  void _handlePointerDown(PointerDownEvent event, Size canvasSize) {
    Offset pt = _getCanvasPoint(event.localPosition, canvasSize);

    // Initialize drag coordinates exactly where touched to prevent jump
    state.dragX = pt.dx;
    state.dragY = pt.dy;

    if (state.scenario == 1) {
      if (state.step == 0 &&
          !state.s1_vertexPlaced &&
          _hitTestCircle(-250, -70, 40, pt)) {
        state.activeDragEntity = 's1_v';
        _playSound('click');
      } else if (state.step == 1 &&
          !state.s1_ray1Placed &&
          _hitTestBox(-310, -10, 120, 60, pt)) {
        state.activeDragEntity = 's1_r1';
        _playSound('click');
      } else if (state.step == 2 &&
          !state.s1_ray2Placed &&
          _hitTestBox(-310, 40, 120, 80, pt)) {
        state.activeDragEntity = 's1_r2';
        _playSound('click');
      } else if (state.step == 3 && state.s1_vertexPlaced) {
        if (_hitTestCircle(0, 0, 40, pt)) {
          state.s1_vClicked = true;
          _playSound('snap');
        } else if (_hitTestBox(10, -30, 180, 60, pt)) {
          state.s1_r1Clicked = true;
          _playSound('snap');
        } else if (pt.dx > 10 && pt.dx < 150 && pt.dy < -10 && pt.dy > -150) {
          state.s1_r2Clicked = true;
          _playSound('snap');
        }
        if (state.s1_vClicked && state.s1_r1Clicked && state.s1_r2Clicked) {
          state.advanceStep();
          _checkSuccessDelayed();
        }
      }
    } else if (state.scenario == 2) {
      if (state.step == 0 && _hitTestCircle(-100, 0, 50, pt)) {
        // Very generous 50px radius for pivot
        state.s2_pivotClicked = true;
        _playSound('success');
        state.advanceStep();
      } else if ((state.step == 1 || state.step == 2) &&
          state.s2_pivotClicked) {
        double hy = -20 - sin(state.s2_angle * pi / 180) * 80;
        if (_hitTestBox(-190, hy - 40, 120, 80, pt)) {
          // Generous handle box
          state.activeDragEntity = 's2_h';
          _playSound('click');
        }
      }
    } else if (state.scenario == 3) {
      List<String> blocks = ['P', 'Q', 'R'];
      bool hitBlock = false;
      for (int i = 0; i < 3; i++) {
        if (!state.s3_slots.contains(blocks[i]) &&
            _hitTestBox(-80 + i * 60, 220, 50, 50, pt)) {
          state.activeDragEntity = 's3_${blocks[i]}';
          _playSound('click');
          hitBlock = true;
          break;
        }
      }
      if (!hitBlock && state.step == 2 && _hitTestBox(-60, 210, 120, 50, pt)) {
        String? tStr = state.s3_slots[0];
        state.s3_slots[0] = state.s3_slots[2];
        state.s3_slots[2] = tStr;
        state.s3_swapped = true;
        _playSound('success');
        state.advanceStep();
        _checkSuccessDelayed();
      }
    } else if (state.scenario == 4) {
      if (state.step == 0 && _hitTestBox(-40, -140, 80, 160, pt)) {
        state.s4_active = true;
        state.s4_beam1 = 0;
        state.s4_beam2 = 0;
        _playSound('success');
        state.advanceStep();
      } else if (state.step == 1 && state.s4_active) {
        double b1x = 150 * cos(state.s4_beam1);
        double b1y = -120 + 150 * sin(state.s4_beam1);
        double b2x = 150 * cos(state.s4_beam2);
        double b2y = -120 + 150 * sin(state.s4_beam2);
        if ((pt - Offset(b1x, b1y)).distance < 50) {
          state.activeDragEntity = 's4_b1';
          _playSound('click');
        } else if ((pt - Offset(b2x, b2y)).distance < 50) {
          state.activeDragEntity = 's4_b2';
          _playSound('click');
        }
      }
    } else if (state.scenario == 5) {
      double bX = -200, bY = 100;
      double L1 = 150, L2 = 120;
      double elX = bX + L1 * cos(state.s5_shoulder);
      double elY = bY + L1 * sin(state.s5_shoulder);
      double wrX = elX + L2 * cos(state.s5_shoulder + state.s5_elbow);
      double wrY = elY + L2 * sin(state.s5_shoulder + state.s5_elbow);

      if (state.step == 0 && (pt - Offset(elX, elY)).distance < 50) {
        state.activeDragEntity = 's5_s';
        _playSound('click');
      } else if (state.step == 1 && (pt - Offset(wrX, wrY)).distance < 50) {
        state.activeDragEntity = 's5_e';
        _playSound('click');
      } else if (state.step == 2 && _hitTestBox(80, 150, 140, 60, pt)) {
        double clawTipX = wrX + 25 * cos(state.s5_shoulder + state.s5_elbow);
        double clawTipY = wrY + 25 * sin(state.s5_shoulder + state.s5_elbow);
        if ((Offset(clawTipX, clawTipY) - const Offset(40, 100)).distance <
            90) {
          state.s5_grabbed = true;
          _playSound('success');
          state.advanceStep();
          _checkSuccessDelayed();
        } else {
          _playSound('error');
        }
      }
    }
    state.notifyListeners();
  }

  void _handlePointerUp(PointerUpEvent event, Size canvasSize) {
    if (state.activeDragEntity != null) {
      Offset pt = _getCanvasPoint(event.localPosition, canvasSize);

      if (state.activeDragEntity == 's1_v') {
        if (_hitTestCircle(0, 0, 50, pt)) {
          state.s1_vertexPlaced = true;
          _playSound('snap');
          state.advanceStep();
        } else {
          _playSound('error');
        }
      } else if (state.activeDragEntity == 's1_r1') {
        if (_hitTestCircle(0, 0, 80, pt)) {
          state.s1_ray1Placed = true;
          _playSound('snap');
          state.advanceStep();
        } else {
          _playSound('error');
        }
      } else if (state.activeDragEntity == 's1_r2') {
        if (_hitTestCircle(0, 0, 80, pt)) {
          state.s1_ray2Placed = true;
          _playSound('snap');
          state.advanceStep();
        } else {
          _playSound('error');
        }
      } else if (state.activeDragEntity!.startsWith('s3_')) {
        String b = state.activeDragEntity!.split('_')[1];
        int slotIdx = -1;
        for (int i = 0; i < 3; i++) {
          if (_hitTestBox(-60.0 + i * 60.0, 150, 50, 50, pt)) slotIdx = i;
        }

        if (slotIdx != -1) {
          if (slotIdx == 1 && b != 'Q') {
            _playSound('error');
          } else if (slotIdx != 1 && b == 'Q') {
            _playSound('error');
          } else if (state.s3_slots[slotIdx] == null) {
            state.s3_slots[slotIdx] = b;
            _playSound('snap');
            if (state.step == 0 && b == 'Q') state.advanceStep();
            if (state.step == 1 &&
                state.s3_slots[0] != null &&
                state.s3_slots[2] != null) {
              state.advanceStep();
            }
          } else {
            _playSound('error');
          }
        } else {
          _playSound('error');
        }
      }
      state.activeDragEntity = null;
      state.notifyListeners();
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    _startZoom = state.zoom;
    if (state.activeDragEntity == null) {
      _isPanningCanvas = true;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    double dx = details.localFocalPoint.dx - _lastFocalPoint.dx;
    double dy = details.localFocalPoint.dy - _lastFocalPoint.dy;
    _lastFocalPoint = details.localFocalPoint;

    if (state.activeDragEntity != null) {
      Offset pt = _getCanvasPoint(details.localFocalPoint, canvasSize);

      if (state.activeDragEntity!.startsWith('s1_') ||
          state.activeDragEntity!.startsWith('s3_')) {
        state.dragX = pt.dx;
        state.dragY = pt.dy;
      } else if (state.activeDragEntity == 's2_h') {
        double dyVal = pt.dy;
        double a = asin(max(-80.0, min(0.0, dyVal)) / 80.0) * 180 / pi;
        state.s2_angle = max(0.0, min(45.0, a.abs()));
        if (state.step == 1 && state.s2_angle > 30) {
          state.advanceStep();
          _playSound('success');
        }
        if (state.step == 2 && state.s2_angle < 5) {
          state.advanceStep();
          _playSound('success');
          state.s2_animating = true;
          state.s2_animProgress = 0;
        }
      } else if (state.activeDragEntity == 's4_b1' ||
          state.activeDragEntity == 's4_b2') {
        double a = atan2(pt.dy - (-120), pt.dx - 0);
        if (state.activeDragEntity == 's4_b1') state.s4_beam1 = a;
        if (state.activeDragEntity == 's4_b2') state.s4_beam2 = a;

        double tgtA = atan2(100 - (-120), -180 - 0);
        double tgtB = atan2(160 - (-120), 150 - 0);
        state.s4_hitA =
            (state.s4_beam1 - tgtA).abs() < 0.15 ||
            (state.s4_beam2 - tgtA).abs() < 0.15;
        state.s4_hitB =
            (state.s4_beam1 - tgtB).abs() < 0.15 ||
            (state.s4_beam2 - tgtB).abs() < 0.15;

        if (state.s4_hitA && state.s4_hitB && state.step == 1) {
          state.activeDragEntity = null;
          state.advanceStep();
          _playSound('success');
          _checkSuccessDelayed();
        }
      } else if (state.activeDragEntity == 's5_s') {
        state.s5_shoulder = atan2(pt.dy - 100, pt.dx - (-200));
        if (state.step == 0) {
          state.advanceStep();
          _playSound('success');
        }
      } else if (state.activeDragEntity == 's5_e') {
        double elX = -200 + 150 * cos(state.s5_shoulder);
        double elY = 100 + 150 * sin(state.s5_shoulder);
        state.s5_elbow = atan2(pt.dy - elY, pt.dx - elX) - state.s5_shoulder;
        if (state.step == 1) {
          state.advanceStep();
          _playSound('success');
        }
      }
      state.notifyListeners();
    } else if (_isPanningCanvas) {
      if (details.pointerCount > 1) {
        state.zoom = (_startZoom * details.scale).clamp(0.5, 3.0);
      }
      state.panX += dx;
      state.panY += dy;
      state.notifyListeners();
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _isPanningCanvas = false;
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double sidebarW = screenW * 0.35;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: ListenableBuilder(
          listenable: state,
          builder: (context, child) {
            return Stack(
              children: [
                // 1. Simulation Canvas Layer with Animated Viewport transitions
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: state.isSidebarOpen ? sidebarW : 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      Size canvasSize = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return Listener(
                        onPointerDown: (event) =>
                            _handlePointerDown(event, canvasSize),
                        onPointerUp: (event) =>
                            _handlePointerUp(event, canvasSize),
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            setState(() {
                              double zoomDelta =
                                  -pointerSignal.scrollDelta.dy * 0.001;
                              state.zoom = (state.zoom + zoomDelta).clamp(
                                0.5,
                                3.0,
                              );
                              state.notifyListeners();
                            });
                          }
                        },
                        child: GestureDetector(
                          onScaleStart: _handleScaleStart,
                          onScaleUpdate: (details) =>
                              _handleScaleUpdate(details, canvasSize),
                          onScaleEnd: _handleScaleEnd,
                          child: CustomPaint(
                            size: canvasSize,
                            painter: LabPainter(state, t),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 3. Dynamic Floating Mission Card
                if (!state.isSidebarOpen)
                  Positioned(
                    top: 80,
                    left: 16,
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1e293b).withOpacity(0.95),
                      child: Container(
                        width: 280,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF6366f1).withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('s${state.scenario}_title'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t('s${state.scenario}_obj'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Current Step Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${t('stepLabel')} ${min(state.step + 1, state.getScenarioTotalSteps())} / ${state.getScenarioTotalSteps()}',
                                style: const TextStyle(
                                  color: Colors.indigoAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 4. Scrollable Left Sidebar
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: state.isSidebarOpen ? 0 : -sidebarW,
                  top: 0,
                  bottom: 0,
                  width: sidebarW,
                  child: Material(
                    elevation: 16,
                    color: const Color(0xFF1e293b).withOpacity(0.95),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.white12),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    66,
                                    16,
                                    16,
                                  ), // Space for menu icon
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.architecture,
                                            color: Colors.indigoAccent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              t('appTitle'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        t('appSubtitle'),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ActionChip(
                                            avatar: const Icon(
                                              Icons.language,
                                              size: 16,
                                            ),
                                            label: Text(
                                              state.lang.toUpperCase(),
                                            ),
                                            onPressed: () {
                                              _playSound('click');
                                              state.toggleLanguage();
                                            },
                                            backgroundColor: Colors.white10,
                                            padding: const EdgeInsets.all(4),
                                          ),
                                          const SizedBox(width: 8),
                                          ActionChip(
                                            avatar: const Icon(
                                              Icons.refresh,
                                              size: 16,
                                              color: Colors.redAccent,
                                            ),
                                            label: Text(
                                              t('resetBtn'),
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                            onPressed: () {
                                              _playSound('error');
                                              state.reset();
                                            },
                                            backgroundColor: Colors.redAccent
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.all(4),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButton<int>(
                                              value: state.scenario,
                                              isExpanded: true,
                                              dropdownColor: const Color(
                                                0xFF0f172a,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              items: [1, 2, 3, 4, 5]
                                                  .map(
                                                    (s) => DropdownMenuItem(
                                                      value: s,
                                                      child: Text(
                                                        t('s${s}_title'),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  _playSound('click');
                                                  state.loadScenario(val);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, color: Colors.white12),
                                // Scrollable Steps
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t('learnLbl'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amberAccent,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              t('s${state.scenario}_obj'),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ...List.generate(state.getScenarioTotalSteps(), (
                                        i,
                                      ) {
                                        bool isActive = i == state.step;
                                        bool isPast = i < state.step;
                                        Color cardColor = isActive
                                            ? Colors.indigo.withOpacity(0.2)
                                            : isPast
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.white.withOpacity(0.05);
                                        Color borderColor = isActive
                                            ? Colors.indigoAccent
                                            : isPast
                                            ? Colors.green
                                            : Colors.transparent;
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            border: Border.all(
                                              color: borderColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor: isPast
                                                    ? Colors.green
                                                    : isActive
                                                    ? Colors.indigoAccent
                                                    : Colors.grey,
                                                child: isPast
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: Colors.white,
                                                      )
                                                    : Text(
                                                        '${i + 1}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      t(
                                                        's${state.scenario}_step${i + 1}_task',
                                                      ),
                                                      style: TextStyle(
                                                        color: isActive
                                                            ? Colors.white
                                                            : Colors.white70,
                                                        fontSize: 13,
                                                        fontWeight: isActive
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                    if (isPast) ...[
                                                      const SizedBox(height: 6),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          t(
                                                            's${state.scenario}_step${i + 1}_out',
                                                          ),
                                                          style: const TextStyle(
                                                            color: Colors
                                                                .greenAccent,
                                                            fontSize: 12,
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
                                const Spacer(),
                                // Footer
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  color: Colors.black26,
                                  child: const Text(
                                    '© ZeroScienceLab - Fall in love with math and Science',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 10,
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
                ),

                // 5. Menu Icon (Absolute Positioned exactly as requested)
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: Icon(
                      state.isSidebarOpen ? Icons.menu_open : Icons.menu,
                    ),
                    color: Colors.orangeAccent,
                    iconSize: 28,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _playSound('click');
                      state.isSidebarOpen = !state.isSidebarOpen;
                      state.notifyListeners();
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

                // 6. Success Popup Overlay (Scrollable)
                if (state.isSuccessPopupVisible)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 400,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e293b),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  size: 64,
                                  color: Colors.amber,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  t('summaryTitle'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  t('finalDesc'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigoAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(
                                    state.scenario < 5
                                        ? t('nextScenario')
                                        : t('finishLab'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    _playSound('click');
                                    if (state.scenario < 5) {
                                      state.loadScenario(state.scenario + 1);
                                    } else {
                                      state.reset();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 7. Curtain Raiser
                if (!state.isCurtainOpen)
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                      transform: Matrix4.translationValues(
                        0,
                        state.isCurtainOpen
                            ? -MediaQuery.of(context).size.height
                            : 0,
                        0,
                      ),
                      color: const Color(0xFF0f172a),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.architecture,
                              size: 80,
                              color: Colors.indigoAccent,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              t('shutterTitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                              ),
                              label: Text(
                                t('enterLab'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                _playSound('success');
                                state.isCurtainOpen = true;
                                state.notifyListeners();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- CANVAS RENDERING ENGINE ---
class LabPainter extends CustomPainter {
  final SimulationState state;
  final String Function(String) t;

  LabPainter(this.state, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // Draw Background Grid
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0f172a),
    );
    Paint gridPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Setup Camera Matrix
    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 1) {
      _renderScenario1(canvas);
    } else if (state.scenario == 2) {
      _renderScenario2(canvas);
    } else if (state.scenario == 3) {
      _renderScenario3(canvas);
    } else if (state.scenario == 4) {
      _renderScenario4(canvas);
    } else if (state.scenario == 5) {
      _renderScenario5(canvas);
    }

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    double size = 14,
    bool bold = false,
    Color color = Colors.white,
    Color? stroke,
  }) {
    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: size,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    if (stroke != null) {
      TextSpan strokeSpan = TextSpan(
        style: TextStyle(
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = stroke,
        ),
        text: text,
      );
      TextPainter tpStroke = TextPainter(
        text: strokeSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tpStroke.paint(
        canvas,
        pos - Offset(tpStroke.width / 2, tpStroke.height / 2),
      );
    }
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawVertex(Canvas canvas, Offset pos, Color color) {
    canvas.drawCircle(
      pos,
      14,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(pos, 6, Paint()..color = Colors.white);
    canvas.drawCircle(
      pos,
      6,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawRay(
    Canvas canvas,
    Offset start,
    double angle,
    Color color,
    double length,
  ) {
    canvas.save();
    canvas.translate(start.dx, start.dy);
    canvas.rotate(angle);
    canvas.drawLine(
      Offset.zero,
      Offset(length, 0),
      Paint()
        ..color = color
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawLine(
      Offset.zero,
      Offset(length - 5, 0),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    Path arrow = Path()
      ..moveTo(length, 0)
      ..lineTo(length - 15, -10)
      ..lineTo(length - 15, 10)
      ..close();
    canvas.drawPath(arrow, Paint()..color = color);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  // --- SCENARIO RENDERERS ---

  void _renderScenario1(Canvas canvas) {
    double tbX = -350, tbY = -150;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tbX, tbY, 200, 300),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF1e293b),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tbX, tbY, 200, 300),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    _drawText(
      canvas,
      t('lbl_toolbox'),
      Offset(tbX + 100, tbY + 25),
      bold: true,
      size: 16,
    );

    if (!state.s1_vertexPlaced && state.activeDragEntity != 's1_v') {
      _drawVertex(canvas, Offset(tbX + 100, tbY + 80), Colors.amber);
      _drawText(canvas, t('lbl_vertex'), Offset(tbX + 100, tbY + 115));
    }
    if (!state.s1_ray1Placed && state.activeDragEntity != 's1_r1') {
      _drawRay(canvas, Offset(tbX + 40, tbY + 160), 0, Colors.lightBlue, 120);
      _drawText(canvas, 'Ray', Offset(tbX + 100, tbY + 190));
    }
    if (!state.s1_ray2Placed && state.activeDragEntity != 's1_r2') {
      _drawRay(
        canvas,
        Offset(tbX + 40, tbY + 240),
        -pi / 8,
        Colors.purpleAccent,
        100,
      );
      _drawText(canvas, 'Ray', Offset(tbX + 100, tbY + 270));
    }

    if (!state.s1_vertexPlaced) {
      canvas.drawCircle(
        Offset.zero,
        30,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        "Drop Here",
        const Offset(0, 40),
        color: Colors.white54,
      );
    }

    if (state.s1_vertexPlaced) {
      if (state.s1_ray1Placed && state.s1_ray2Placed) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: 40),
          0,
          -pi / 4,
          false,
          Paint()
            ..color = Colors.amber.withOpacity(0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 20,
        );
      }
      if (state.s1_ray1Placed) {
        _drawRay(
          canvas,
          Offset.zero,
          0,
          state.s1_r1Clicked ? Colors.redAccent : Colors.lightBlue,
          200,
        );
        if (state.s1_r1Clicked || state.step >= 3) {
          _drawText(
            canvas,
            t('lbl_arm1'),
            const Offset(130, 30),
            color: Colors.white,
            stroke: Colors.black,
          );
        }
      }
      if (state.s1_ray2Placed) {
        _drawRay(
          canvas,
          Offset.zero,
          -pi / 4,
          state.s1_r2Clicked ? Colors.redAccent : Colors.purpleAccent,
          200,
        );
        double rx = 150 * cos(-pi / 4), ry = 150 * sin(-pi / 4);
        if (state.s1_r2Clicked || state.step >= 3) {
          _drawText(
            canvas,
            t('lbl_arm2'),
            Offset(rx, ry - 20),
            color: Colors.white,
            stroke: Colors.black,
          );
        }
      }
      _drawVertex(
        canvas,
        Offset.zero,
        state.s1_vClicked ? Colors.redAccent : Colors.amber,
      );
      if (state.s1_vClicked || state.step >= 3) {
        _drawText(
          canvas,
          t('lbl_vertex'),
          const Offset(0, 40),
          color: Colors.white,
          stroke: Colors.black,
        );
      }
    }

    if (state.activeDragEntity == 's1_v') {
      _drawVertex(canvas, Offset(state.dragX, state.dragY), Colors.amber);
    }
    if (state.activeDragEntity == 's1_r1') {
      _drawRay(
        canvas,
        Offset(state.dragX - 60, state.dragY),
        0,
        Colors.lightBlue,
        120,
      );
    }
    if (state.activeDragEntity == 's1_r2') {
      _drawRay(
        canvas,
        Offset(state.dragX - 50, state.dragY + 20),
        -pi / 4,
        Colors.purpleAccent,
        120,
      );
    }

    if (state.step >= 4) {
      _drawText(
        canvas,
        t('lbl_success_angle'),
        const Offset(0, 160),
        color: Colors.greenAccent,
        bold: true,
        size: 16,
        stroke: Colors.black,
      );
    }
  }

  void _renderScenario2(Canvas canvas) {
    double angleRad =
        (state.s2_animating
            ? 20 + 15 * sin(state.s2_animProgress * pi * 4)
            : state.s2_angle) *
        pi /
        180;

    canvas.save();
    canvas.translate(-100, 0);

    // Lower Blade
    Path lowerBlade = Path()
      ..moveTo(0, -5)
      ..lineTo(150, -2)
      ..lineTo(140, 5)
      ..lineTo(0, 5)
      ..close();
    canvas.drawPath(lowerBlade, Paint()..color = Colors.grey.shade400);
    canvas.drawPath(
      lowerBlade,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-45, 20), width: 90, height: 50),
      Paint()..color = Colors.redAccent,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-45, 20), width: 40, height: 24),
      Paint()..color = const Color(0xFF0f172a),
    );

    // Arc
    if (angleRad > 0.05) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 80),
        0,
        -angleRad,
        false,
        Paint()
          ..color = Colors.lightBlue.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30,
      );
    }

    // Upper Blade
    canvas.save();
    canvas.rotate(-angleRad);
    Path upperBlade = Path()
      ..moveTo(0, -5)
      ..lineTo(150, -5)
      ..lineTo(140, 2)
      ..lineTo(0, 5)
      ..close();
    canvas.drawPath(upperBlade, Paint()..color = Colors.grey.shade300);
    canvas.drawPath(
      upperBlade,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-45, -20), width: 90, height: 50),
      Paint()..color = Colors.redAccent,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-45, -20), width: 40, height: 24),
      Paint()..color = const Color(0xFF0f172a),
    );
    canvas.restore();

    // Pivot
    canvas.drawCircle(Offset.zero, 7, Paint()..color = Colors.grey.shade300);
    canvas.drawCircle(
      Offset.zero,
      7,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(-3, -3),
      const Offset(3, 3),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    canvas.restore();

    if (state.s2_pivotClicked || state.step >= 1) {
      _drawText(
        canvas,
        t('lbl_vertex'),
        const Offset(-100, 60),
        color: Colors.white,
        stroke: Colors.black,
      );
      _drawText(
        canvas,
        t('lbl_blades'),
        const Offset(50, -60),
        color: Colors.white,
        stroke: Colors.black,
      );
    }

    if ((state.step == 1 || state.step == 2) && !state.s2_animating) {
      double hy = -20 - sin(state.s2_angle * pi / 180) * 80;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(-140, hy), width: 60, height: 40),
          const Radius.circular(8),
        ),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    if (state.step >= 3) {
      _drawText(
        canvas,
        t('lbl_scissor_obs'),
        const Offset(0, 150),
        color: Colors.amber,
        bold: true,
        size: 16,
        stroke: Colors.black,
      );
    }
  }

  void _draw3DBlock(Canvas canvas, Offset pos, double size, String text) {
    Color top = Colors.blue.shade200,
        side = Colors.blue.shade800,
        main = Colors.blue.shade500;
    if (text == 'P') {
      top = Colors.red.shade200;
      side = Colors.red.shade800;
      main = Colors.red.shade500;
    }
    if (text == 'R') {
      top = Colors.green.shade200;
      side = Colors.green.shade800;
      main = Colors.green.shade500;
    }

    Path pTop = Path()
      ..moveTo(pos.dx, pos.dy)
      ..lineTo(pos.dx + size, pos.dy)
      ..lineTo(pos.dx + size + 8, pos.dy - 8)
      ..lineTo(pos.dx + 8, pos.dy - 8)
      ..close();
    canvas.drawPath(pTop, Paint()..color = top);
    canvas.drawPath(
      pTop,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );

    Path pSide = Path()
      ..moveTo(pos.dx + size, pos.dy)
      ..lineTo(pos.dx + size + 8, pos.dy - 8)
      ..lineTo(pos.dx + size + 8, pos.dy + size - 8)
      ..lineTo(pos.dx + size, pos.dy + size)
      ..close();
    canvas.drawPath(pSide, Paint()..color = side);
    canvas.drawPath(
      pSide,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );

    canvas.drawRect(
      Rect.fromLTWH(pos.dx, pos.dy, size, size),
      Paint()..color = main,
    );
    canvas.drawRect(
      Rect.fromLTWH(pos.dx, pos.dy, size, size),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );

    _drawText(
      canvas,
      text,
      Offset(pos.dx + size / 2, pos.dy + size / 2),
      bold: true,
      size: size * 0.6,
    );
  }

  void _renderScenario3(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-200, -180, 400, 280),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF1e293b),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-200, -180, 400, 280),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    double vX = 0, vY = -40;
    double pX = 120 * cos(-pi / 6), pY = -40 + 120 * sin(-pi / 6);
    double rX = 120, rY = -40;

    Paint pen = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(vX, vY), Offset(pX, pY), pen);
    canvas.drawLine(Offset(vX, vY), Offset(rX, rY), pen);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(vX, vY), radius: 30),
      -pi / 6,
      pi / 6,
      false,
      Paint()
        ..color = Colors.lightBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    _drawText(canvas, 'P', Offset(pX, pY - 20), size: 18, bold: true);
    _drawText(canvas, 'Q', Offset(vX, vY - 20), size: 18, bold: true);
    _drawText(canvas, 'R', Offset(rX, rY - 20), size: 18, bold: true);

    _drawText(canvas, "∠", const Offset(-100, 170), size: 32, bold: true);
    for (int i = 0; i < 3; i++) {
      double sx = -60.0 + i * 60.0;
      bool isComp =
          state.s3_slots[0] != null &&
          state.s3_slots[1] == 'Q' &&
          state.s3_slots[2] != null;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx, 150, 50, 50),
          const Radius.circular(6),
        ),
        Paint()
          ..color = const Color(0xFF334155)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isComp ? 4 : 2
          ..color = isComp ? Colors.green : Colors.white,
      );
      if (state.s3_slots[i] != null) {
        _draw3DBlock(canvas, Offset(sx + 5, 155), 40, state.s3_slots[i]!);
      }
    }

    List<String> blocks = ['P', 'Q', 'R'];
    for (int i = 0; i < 3; i++) {
      if (!state.s3_slots.contains(blocks[i]) &&
          state.activeDragEntity != 's3_${blocks[i]}') {
        _draw3DBlock(canvas, Offset(-80.0 + i * 60.0, 220), 50, blocks[i]);
      }
    }

    if (state.activeDragEntity?.startsWith('s3_') ?? false) {
      _draw3DBlock(
        canvas,
        Offset(state.dragX - 25, state.dragY - 25),
        50,
        state.activeDragEntity!.split('_')[1],
      );
    }

    if (state.step >= 2) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-60, 210, 120, 50),
          const Radius.circular(8),
        ),
        Paint()..color = state.s3_swapped ? Colors.greenAccent : Colors.green,
      );
      _drawText(
        canvas,
        t('lbl_swap'),
        const Offset(0, 235),
        bold: true,
        color: Colors.black,
      );
    }

    if (state.step >= 3) {
      _drawText(
        canvas,
        t('lbl_namer_obs'),
        const Offset(0, 280),
        color: Colors.greenAccent,
        bold: true,
        stroke: Colors.black,
      );
    }
  }

  void _drawShip(Canvas canvas, Offset pos, String label, bool isHit) {
    double bob =
        sin(state.time * 0.003 + pos.dx) * 6; // enhanced bobbing effect
    canvas.save();
    canvas.translate(pos.dx, pos.dy + bob);

    if (isHit) {
      canvas.drawCircle(
        const Offset(0, -5),
        45,
        Paint()
          ..color = Colors.amber.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }

    Paint strokePaint = Paint()
      ..color = const Color(0xFF0f172a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Hull
    Path hull = Path()
      ..moveTo(-35, 0)
      ..lineTo(35, 0)
      ..lineTo(25, 15)
      ..lineTo(-25, 15)
      ..close();
    canvas.drawPath(hull, Paint()..color = const Color(0xFF1e293b));
    canvas.drawPath(hull, strokePaint);

    // Cabin
    canvas.drawRect(
      const Rect.fromLTWH(-15, -20, 30, 20),
      Paint()..color = const Color(0xFFf8fafc),
    );
    canvas.drawRect(const Rect.fromLTWH(-15, -20, 30, 20), strokePaint);

    // Windows
    canvas.drawRect(
      const Rect.fromLTWH(-10, -15, 8, 8),
      Paint()..color = const Color(0xFF38bdf8),
    );
    canvas.drawRect(
      const Rect.fromLTWH(2, -15, 8, 8),
      Paint()..color = const Color(0xFF38bdf8),
    );

    // Smokestack
    canvas.drawRect(
      const Rect.fromLTWH(-5, -35, 10, 15),
      Paint()..color = const Color(0xFFef4444),
    );
    canvas.drawRect(const Rect.fromLTWH(-5, -35, 10, 15), strokePaint);

    // Smoke bubbles
    Paint smokePaint = Paint()..color = Colors.white.withOpacity(0.6);
    double s1y = -45 - (state.time * 0.02) % 10;
    double s1x = Math.sin(state.time * 0.002) * 5;
    canvas.drawCircle(Offset(s1x, s1y), 5, smokePaint);

    double s2y = -55 - (state.time * 0.02) % 15;
    double s2x = 5 + Math.sin(state.time * 0.002 + 1) * 5;
    canvas.drawCircle(Offset(s2x, s2y), 7, smokePaint);

    _drawText(canvas, label, const Offset(0, 30), stroke: Colors.black);
    canvas.restore();
  }

  void _renderScenario4(Canvas canvas) {
    // Sky / Sand
    canvas.drawRect(
      const Rect.fromLTWH(-2000, -1500, 4000, 1380), // Ends at y = -120
      Paint()..color = const Color(0xFFfde047),
    );

    // Ocean Base
    canvas.drawRect(
      const Rect.fromLTWH(-2000, -120, 4000, 3000),
      Paint()..color = const Color(0xFF0284c7),
    );

    // Horizon Line
    canvas.drawLine(
      const Offset(-2000, -120),
      const Offset(2000, -120),
      Paint()
        ..color = const Color(0xFFeab308)
        ..strokeWidth = 6,
    );

    // Darker Ocean Wave Layer
    Path wave = Path()..moveTo(-2000, -50);
    for (double x = -2000; x <= 2000; x += 50) {
      wave.lineTo(x, -50 + sin(x * 0.01 + state.time * 0.002) * 15);
    }
    wave.lineTo(2000, 1500);
    wave.lineTo(-2000, 1500);
    wave.close();
    canvas.drawPath(wave, Paint()..color = const Color(0xFF0369a1));

    double vX = 0, vY = -120;

    // Lighthouse Yellow Glow (Step 0)
    if (!state.s4_active && state.step == 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-35, -140, 70, 150),
          const Radius.circular(15),
        ),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-35, -140, 70, 150),
          const Radius.circular(15),
        ),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Lighthouse Structure
    Paint strokePaint = Paint()
      ..color = const Color(0xFF0f172a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Path lh = Path()
      ..moveTo(-25, 0)
      ..lineTo(-15, -120)
      ..lineTo(15, -120)
      ..lineTo(25, 0)
      ..close();
    canvas.drawPath(lh, Paint()..color = const Color(0xFFf8fafc));
    canvas.drawPath(lh, strokePaint);

    Path red1 = Path()
      ..moveTo(-23, -20)
      ..lineTo(23, -20)
      ..lineTo(21, -40)
      ..lineTo(-21, -40)
      ..close();
    canvas.drawPath(red1, Paint()..color = const Color(0xFFef4444));
    canvas.drawPath(red1, strokePaint);

    Path red2 = Path()
      ..moveTo(-19, -60)
      ..lineTo(19, -60)
      ..lineTo(17, -80)
      ..lineTo(-17, -80)
      ..close();
    canvas.drawPath(red2, Paint()..color = const Color(0xFFef4444));
    canvas.drawPath(red2, strokePaint);

    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -120), radius: 15),
      pi,
      pi,
      true,
      Paint()..color = const Color(0xFFfacc15),
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -120), radius: 15),
      pi,
      pi,
      true,
      strokePaint,
    );

    if (state.s4_active) {
      void drawBeam(double ang, bool hit) {
        canvas.save();
        canvas.translate(vX, vY);
        canvas.rotate(ang);
        Path b = Path()
          ..moveTo(0, 0)
          ..lineTo(400, -40)
          ..arcToPoint(const Offset(400, 40), radius: const Radius.circular(40))
          ..lineTo(0, 0)
          ..close();
        canvas.drawPath(
          b,
          Paint()..color = Colors.yellow.withOpacity(hit ? 0.6 : 0.3),
        );
        canvas.drawCircle(
          const Offset(150, 0),
          12,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          const Offset(150, 0),
          12,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.restore();
      }

      drawBeam(state.s4_beam1, state.s4_hitA || state.s4_hitB);
      drawBeam(state.s4_beam2, state.s4_hitA || state.s4_hitB);

      if (state.s4_hitA && state.s4_hitB) {
        double a1 = min(state.s4_beam1, state.s4_beam2);
        double a2 = max(state.s4_beam1, state.s4_beam2);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(vX, vY), radius: 60),
          a1,
          a2 - a1,
          false,
          Paint()
            ..color = Colors.redAccent.withOpacity(0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10,
        );
        _drawText(
          canvas,
          t('lbl_angle'),
          Offset(vX, vY + 80),
          color: Colors.white,
          stroke: Colors.red,
        );
      }
    }

    _drawShip(canvas, const Offset(-180, 100), t('lbl_shipA'), state.s4_hitA);
    _drawShip(canvas, const Offset(150, 160), t('lbl_shipB'), state.s4_hitB);
  }

  void _drawArmSeg(Canvas canvas, Offset p1, Offset p2) {
    double a = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    double len = (p2 - p1).distance;
    canvas.save();
    canvas.translate(p1.dx, p1.dy);
    canvas.rotate(a);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -14, len, 28),
        const Radius.circular(14),
      ),
      Paint()..color = Colors.grey.shade400,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -14, len, 28),
        const Radius.circular(14),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(20, -6, len - 40, 12),
      Paint()..color = Colors.blueGrey.shade800,
    );
    canvas.restore();
  }

  void _drawCrate(Canvas canvas, Offset pos) {
    canvas.drawRect(
      Rect.fromCenter(center: pos, width: 50, height: 50),
      Paint()..color = Colors.brown.shade700,
    );
    canvas.drawRect(
      Rect.fromCenter(center: pos, width: 50, height: 50),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      pos - const Offset(25, 25),
      pos + const Offset(25, 25),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      pos + const Offset(25, -25),
      pos - const Offset(25, -25),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
  }

  void _renderScenario5(Canvas canvas) {
    double bX = -200, bY = 100;
    double L1 = 150, L2 = 120;
    double elX = bX + L1 * cos(state.s5_shoulder);
    double elY = bY + L1 * sin(state.s5_shoulder);
    double wrX = elX + L2 * cos(state.s5_shoulder + state.s5_elbow);
    double wrY = elY + L2 * sin(state.s5_shoulder + state.s5_elbow);
    Offset cratePos = const Offset(40, 100);

    // Base
    Path base = Path()
      ..moveTo(bX - 50, bY + 50)
      ..lineTo(bX + 50, bY + 50)
      ..lineTo(bX + 30, bY)
      ..lineTo(bX - 30, bY)
      ..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFF334155));
    canvas.drawPath(
      base,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Angle Arcs
    canvas.drawArc(
      Rect.fromCircle(center: Offset(bX, bY), radius: 40),
      min(0, state.s5_shoulder),
      max(0.001, state.s5_shoulder.abs()),
      false,
      Paint()
        ..color = Colors.lightBlue.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(elX, elY), radius: 30),
      state.s5_shoulder,
      state.s5_elbow,
      false,
      Paint()
        ..color = Colors.purpleAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    // Arms
    _drawArmSeg(canvas, Offset(bX, bY), Offset(elX, elY));
    _drawArmSeg(canvas, Offset(elX, elY), Offset(wrX, wrY));

    // Joints & Handles
    canvas.drawCircle(
      Offset(bX, bY),
      15,
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawCircle(
      Offset(bX, bY),
      15,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(elX, elY),
      12,
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawCircle(
      Offset(elX, elY),
      12,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(elX, elY), 6, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(elX, elY),
      6,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(wrX, wrY), 8, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(wrX, wrY),
      8,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Gripper
    canvas.save();
    canvas.translate(wrX, wrY);
    canvas.rotate(state.s5_shoulder + state.s5_elbow);
    canvas.drawRect(
      const Rect.fromLTWH(0, -15, 20, 30),
      Paint()..color = Colors.blueGrey,
    );
    canvas.drawRect(
      const Rect.fromLTWH(0, -15, 20, 30),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRect(
      const Rect.fromLTWH(20, -15, 20, 5),
      Paint()..color = Colors.blueGrey,
    );
    canvas.drawRect(
      const Rect.fromLTWH(20, -15, 20, 5),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRect(
      const Rect.fromLTWH(20, 10, 20, 5),
      Paint()..color = Colors.blueGrey,
    );
    canvas.drawRect(
      const Rect.fromLTWH(20, 10, 20, 5),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();

    if (!state.s5_grabbed) {
      _drawCrate(canvas, cratePos);
    } else {
      double holdX = wrX + 25 * cos(state.s5_shoulder + state.s5_elbow);
      double holdY = wrY + 25 * sin(state.s5_shoulder + state.s5_elbow);
      canvas.save();
      canvas.translate(holdX, holdY);
      canvas.rotate(state.s5_shoulder + state.s5_elbow);
      _drawCrate(canvas, Offset.zero);
      canvas.restore();
    }

    if (state.step == 2 && !state.s5_grabbed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(80, 150, 140, 60),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.green,
      );
      _drawText(
        canvas,
        t('lbl_grab'),
        const Offset(150, 180),
        bold: true,
        size: 20,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
