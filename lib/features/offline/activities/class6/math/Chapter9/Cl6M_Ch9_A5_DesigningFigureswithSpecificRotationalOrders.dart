// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// -----------------------------------------------------------------------------
// UTILS
// -----------------------------------------------------------------------------
double hypot(double x, double y) => math.sqrt(x * x + y * y);

// -----------------------------------------------------------------------------
// AUDIO MANAGER
// -----------------------------------------------------------------------------
class AudioManager {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  // 1. Play click/snap sound
  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  // 2. Play a sound when a new page opens / success (Swoosh/Chime)
  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  // 3. Play the Dropdown sound
  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  // 4. Play an error sound (Soft thud)
  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  // 5. Curtain Screen Open
  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// -----------------------------------------------------------------------------
// MAIN ENTRY POINT
// -----------------------------------------------------------------------------
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Symmetry Spinner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch9_A5_DesigningFigureswithSpecificRotationalOrders(),
    ),
  );
}

// -----------------------------------------------------------------------------
// TRANSLATIONS
// -----------------------------------------------------------------------------
const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': 'The Symmetry Spinner: Designing for Rotational Order',
    'appTitle': 'The Symmetry Spinner',
    'appSubtitle': 'Class 6 • SYMMETRY',
    'enterLab': 'Enter Simulation',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'doneBtn': 'Done',
    'learnLbl': 'Objective:',
    'summaryTitle': 'Goal Reached!',
    'resetBtn': 'Reset Lab',
    'finishLab': 'Finish Lab',
    'nextScenario': 'Next Scenario',
    'checkBtn': 'Check Symmetry',
    'finalDesc':
        'You have successfully learned how to design figures with specific orders of rotational symmetry by controlling the arrangement of their parts!',
    's1_title': '1. The Perfect Pair (Order 2)',
    's1_obj': 'To build a figure with a rotational order of exactly 2.',
    's1_step1_task':
        'From "Shapes Palette", DRAG blue petal to glowing "snap-point" on hub.',
    's1_step1_out': 'Petal placed successfully.',
    's1_step2_task':
        'DRAG a second blue petal to the snap-point directly opposite the first.',
    's1_step2_out': 'Opposite petal placed.',
    's1_step3_task':
        'CLICK and HOLD "Rotation Handle". DRAG to spin. Watch "Order Counter".',
    's1_step3_out': 'Rotated 360 degrees. Order counted.',
    's1_step4_task':
        'A summary message appears explaining the figure\'s rotational order.',
    's1_step4_out': 'Summary displayed.',
    's1_hud1': 'Drag blue petal to glowing top snap-point.',
    's1_hud2': 'Drag second petal to the bottom snap-point.',
    's1_hud3': 'Drag the circular handle to spin your creation.',
    's1_hud4': 'Review the summary and proceed.',
    's2_title': '2. The Four-Point Star (Order 4)',
    's2_obj': 'To build a figure with a rotational order of exactly 4.',
    's2_step1_task':
        'DRAG four yellow squares from palette onto the four main snap-points.',
    's2_step1_out': 'Four yellow squares are attached.',
    's2_step2_task':
        'CLICK and HOLD the "Rotation Handle" and begin to spin the figure.',
    's2_step2_out': 'The figure perfectly aligns at every 90° turn.',
    's2_step3_task': 'A summary message appears explaining the order.',
    's2_step3_out': 'Summary displayed.',
    's2_hud1': 'Drag four yellow squares to the glowing points.',
    's2_hud2': 'Spin the handle a full 360 degrees.',
    's2_hud3': 'Review the summary and proceed.',
    's3_title': '3. The Importance of Spacing (Order 3)',
    's3_obj':
        'To understand that equal spacing is crucial for rotational symmetry.',
    's3_step1_task':
        'DRAG three green triangles. DROP them on top, and next to each other.',
    's3_step1_out': 'Three triangles are attached, but spaced unequally.',
    's3_step2_task': 'CLICK the "Check Symmetry" button.',
    's3_step2_out': 'This design has an order of 1. Not symmetrical.',
    's3_step3_task':
        'DRAG the triangles and move them to space them out evenly.',
    's3_step3_out': 'The triangles are now 120° apart.',
    's3_step4_task': 'CLICK the "Check Symmetry" button again.',
    's3_step4_out': 'Perfect! You achieved rotational order 3.',
    's3_hud1': 'Place triangles unevenly at 12, 1, and 6 o\'clock.',
    's3_hud2': 'Click "Check Symmetry" to test.',
    's3_hud3': 'Follow the guides to correct the spacing.',
    's3_hud4': 'Click "Check Symmetry" again.',
    's4_title': '4. The Hexagon Designer',
    's4_obj': 'Construct a figure with a rotational order of exactly 6.',
    's4_step1_task':
        'Build a figure with rotational order 6. CLICK "Check Symmetry".',
    's4_step1_out': 'You placed 6 identical shapes perfectly spaced.',
    's4_hud1': 'Design an Order 6 shape and click Check.',
    's5_title': '5. The Creative Combo',
    's5_obj': 'Create an order 3 figure using two different types of shapes.',
    's5_step1_task':
        'Build order 3 using red circles and blue squares. CLICK "Check".',
    's5_step1_out': 'Master Designer! You created a pattern of mixed shapes.',
    's5_hud1': 'Use circles AND squares to make Order 3. Click Check.',
  },
  'hi': {
    'shutterTitle': 'सममिति स्पिनर: घूर्णी क्रम के लिए डिजाइनिंग',
    'appTitle': 'सममिति स्पिनर',
    'appSubtitle': 'कक्षा 6 • सममिति',
    'enterLab': 'सिमुलेशन प्रारंभ करें',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'doneBtn': 'पूर्ण',
    'learnLbl': 'उद्देश्य:',
    'summaryTitle': 'लक्ष्य प्राप्त!',
    'resetBtn': 'रीसेट करें',
    'finishLab': 'लैब समाप्त करें',
    'nextScenario': 'अगला परिदृश्य',
    'checkBtn': 'सममिति जांचें',
    'finalDesc':
        'आपने विशिष्ट क्रम वाली घूर्णी सममिति आकृतियों को सफलतापूर्वक बनाना सीख लिया है!',
    's1_title': '1. उत्तम जोड़ी (क्रम 2)',
    's1_obj': 'सटीक 2 के घूर्णी क्रम वाली आकृति बनाना।',
    's1_step1_task': 'पैलेट से नीली पंखुड़ी को हब पर खींचें।',
    's1_step1_out': 'पंखुड़ी रखी गई।',
    's1_step2_task': 'दूसरी नीली पंखुड़ी को विपरीत बिंदु पर रखें।',
    's1_step2_out': 'विपरीत पंखुड़ी रखी गई।',
    's1_step3_task': 'रोटेशन हैंडल घुमाएं।',
    's1_step3_out': '360 डिग्री घुमाया गया।',
    's1_step4_task': 'सारांश पढ़ें।',
    's1_step4_out': 'सारांश प्रदर्शित।',
    's1_hud1': 'नीली पंखुड़ी को ऊपर रखें।',
    's1_hud2': 'दूसरी पंखुड़ी नीचे रखें।',
    's1_hud3': 'हैंडल घुमाएं।',
    's1_hud4': 'सारांश देखें और आगे बढ़ें।',
    's2_title': '2. चार-बिंदु तारा (क्रम 4)',
    's2_obj': '4 के घूर्णी क्रम वाली आकृति बनाना।',
    's2_step1_task': 'चार पीले वर्ग खींचकर रखें।',
    's2_step1_out': 'चार वर्ग जुड़े।',
    's2_step2_task': 'हैंडल घुमाएं।',
    's2_step2_out': '90° पर संरेखित होता है।',
    's2_step3_task': 'सारांश पढ़ें।',
    's2_step3_out': 'सारांश प्रदर्शित।',
    's2_hud1': 'चार वर्ग सही स्थान पर रखें।',
    's2_hud2': 'पूरा 360 डिग्री घुमाएं।',
    's2_hud3': 'आगे बढ़ें।',
    's3_title': '3. रिक्ति का महत्व (क्रम 3)',
    's3_obj': 'समझें कि समान रिक्ति महत्वपूर्ण है।',
    's3_step1_task': 'तीन हरे त्रिकोण असमान रूप से रखें।',
    's3_step1_out': 'असमान त्रिकोण रखे गए।',
    's3_step2_task': 'जांचें बटन दबाएं।',
    's3_step2_out': 'क्रम 1 है।',
    's3_step3_task': 'त्रिकोणों को समान दूरी पर करें।',
    's3_step3_out': '120° दूरी पर हैं।',
    's3_step4_task': 'पुनः जांचें।',
    's3_step4_out': 'उत्तम!',
    's3_hud1': 'त्रिकोण पास-पास रखें।',
    's3_hud2': 'जांचें पर क्लिक करें।',
    's3_hud3': 'दूरी समान करें।',
    's3_hud4': 'पुनः जांचें।',
    's4_title': '4. हेक्सागोन डिज़ाइनर',
    's4_obj': 'क्रम 6 की आकृति बनाएं।',
    's4_step1_task': '6 आकृतियों का उपयोग करके क्रम 6 बनाएं।',
    's4_step1_out': 'उत्तम!',
    's4_hud1': 'क्रम 6 बनाएं और जांचें।',
    's5_title': '5. रचनात्मक संयोजन',
    's5_obj': 'दो आकारों के साथ क्रम 3 बनाएं।',
    's5_step1_task': 'वृत्त और वर्ग मिलाकर क्रम 3 बनाएं।',
    's5_step1_out': 'मास्टर डिज़ाइनर!',
    's5_hud1': 'वृत्त और वर्ग दोनों का उपयोग करें।',
  },
};

String t(String key, String lang) {
  return i18n[lang]?[key] ?? i18n['en']![key] ?? key;
}

// -----------------------------------------------------------------------------
// DATA MODELS
// -----------------------------------------------------------------------------
enum ShapeType { petalBlue, squareYellow, squareBlue, triangleGreen, circleRed }

class DragItem {
  final ShapeType type;
  final String source; // 'palette' or 'hub'
  final int index;
  DragItem({required this.type, required this.source, required this.index});
}

class StepConfig {
  final String hudKey;
  final String taskKey;
  final String outKey;
  StepConfig(this.hudKey, this.taskKey, this.outKey);
}

class ScenarioConfig {
  final String titleKey;
  final String objKey;
  final List<StepConfig> steps;
  ScenarioConfig(this.titleKey, this.objKey, this.steps);
}

final Map<int, ScenarioConfig> scenarioConfigs = {
  1: ScenarioConfig('s1_title', 's1_obj', [
    StepConfig('s1_hud1', 's1_step1_task', 's1_step1_out'),
    StepConfig('s1_hud2', 's1_step2_task', 's1_step2_out'),
    StepConfig('s1_hud3', 's1_step3_task', 's1_step3_out'),
    StepConfig('s1_hud4', 's1_step4_task', 's1_step4_out'),
  ]),
  2: ScenarioConfig('s2_title', 's2_obj', [
    StepConfig('s2_hud1', 's2_step1_task', 's2_step1_out'),
    StepConfig('s2_hud2', 's2_step2_task', 's2_step2_out'),
    StepConfig('s2_hud3', 's2_step3_task', 's2_step3_out'),
  ]),
  3: ScenarioConfig('s3_title', 's3_obj', [
    StepConfig('s3_hud1', 's3_step1_task', 's3_step1_out'),
    StepConfig('s3_hud2', 's3_step2_task', 's3_step2_out'),
    StepConfig('s3_hud3', 's3_step3_task', 's3_step3_out'),
    StepConfig('s3_hud4', 's3_step4_task', 's3_step4_out'),
  ]),
  4: ScenarioConfig('s4_title', 's4_obj', [
    StepConfig('s4_hud1', 's4_step1_task', 's4_step1_out'),
  ]),
  5: ScenarioConfig('s5_title', 's5_obj', [
    StepConfig('s5_hud1', 's5_step1_task', 's5_step1_out'),
  ]),
};

// -----------------------------------------------------------------------------
// GAME STATE
// -----------------------------------------------------------------------------
class GameState extends ChangeNotifier {
  String lang = 'en';
  int scenario = 1;
  int step = 0;

  bool curtainOpen = false;
  bool sidebarOpen = true;
  double sidebarWidth = 350;

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  List<ShapeType> paletteConfig = [];
  List<ShapeType?> hubSlots = List.filled(12, null);
  List<int> guidedSlots = [];

  DragItem? dragItem;
  double dragX = 0;
  double dragY = 0;

  double hubRot = 0;
  bool manualRotActive = false;
  double accumulatedRot = 0;
  double lastRotAngle = 0;

  bool isChecking = false;
  int detectedOrder = 0;
  int displayOrder = 0;

  bool s4ShowError = false;
  bool s5ShowError = false;

  bool showSuccessPopup = false;

  void toggleLanguage() {
    lang = lang == 'en' ? 'hi' : 'en';
    AudioManager.playClick();
    notifyListeners();
  }

  void openCurtain() {
    curtainOpen = true;
    AudioManager.curtainScreen();
    notifyListeners();
  }

  void loadScenario(int id) {
    scenario = id;
    step = 0;
    hubSlots.fillRange(0, 12, null);

    if (id == 1)
      paletteConfig = [ShapeType.petalBlue];
    else if (id == 2)
      paletteConfig = [ShapeType.squareYellow];
    else if (id == 3)
      paletteConfig = [ShapeType.triangleGreen];
    else if (id == 4)
      paletteConfig = [
        ShapeType.triangleGreen,
        ShapeType.circleRed,
        ShapeType.squareYellow,
        ShapeType.petalBlue,
      ];
    else if (id == 5)
      paletteConfig = [ShapeType.circleRed, ShapeType.squareBlue];

    setupGuidedSlots();

    dragItem = null;
    hubRot = 0;
    manualRotActive = false;
    accumulatedRot = 0;
    lastRotAngle = 0;
    isChecking = false;
    displayOrder = 0;
    s4ShowError = false;
    s5ShowError = false;
    showSuccessPopup = false;

    panX = (scenario >= 4 || scenario == 3) ? -100 * zoom : -50 * zoom;

    notifyListeners();
  }

  void setupGuidedSlots() {
    guidedSlots.clear();
    if (scenario == 1) {
      if (step == 0) guidedSlots = [0];
      if (step == 1) guidedSlots = [6];
    } else if (scenario == 2) {
      if (step == 0) guidedSlots = [0, 3, 6, 9];
    } else if (scenario == 3) {
      if (step == 0) guidedSlots = [0, 1, 6];
      if (step == 2) guidedSlots = [0, 4, 8];
    } else if (scenario == 4) {
      guidedSlots = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    } else if (scenario == 5) {
      guidedSlots = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    }
  }

  void advanceStep() {
    step++;
    setupGuidedSlots();
    notifyListeners();
  }

  int calculateRotationalOrder() {
    if (hubSlots.every((s) => s == null)) return 0;
    for (int n = 12; n >= 1; n--) {
      if (12 % n != 0) continue;
      int shift = 12 ~/ n;
      bool matches = true;
      for (int i = 0; i < 12; i++) {
        if (hubSlots[i] != hubSlots[(i + shift) % 12]) {
          matches = false;
          break;
        }
      }
      if (matches) return n;
    }
    return 1;
  }

  void checkStepProgression() {
    if (scenario == 1 && step == 0) {
      if (hubSlots[0] == ShapeType.petalBlue) advanceStep();
    } else if (scenario == 1 && step == 1) {
      if (hubSlots[0] == ShapeType.petalBlue &&
          hubSlots[6] == ShapeType.petalBlue)
        advanceStep();
    } else if (scenario == 2 && step == 0) {
      if (hubSlots[0] == ShapeType.squareYellow &&
          hubSlots[3] == ShapeType.squareYellow &&
          hubSlots[6] == ShapeType.squareYellow &&
          hubSlots[9] == ShapeType.squareYellow)
        advanceStep();
    } else if (scenario == 3 && step == 0) {
      if (hubSlots[0] == ShapeType.triangleGreen &&
          hubSlots[1] == ShapeType.triangleGreen &&
          hubSlots[6] == ShapeType.triangleGreen)
        advanceStep();
    } else if (scenario == 3 && step == 2) {
      if (hubSlots[0] == ShapeType.triangleGreen &&
          hubSlots[4] == ShapeType.triangleGreen &&
          hubSlots[8] == ShapeType.triangleGreen)
        advanceStep();
    }
  }

  void toggleSidebar() {
    sidebarOpen = !sidebarOpen;
    AudioManager.playClick();
    notifyListeners();
  }
}

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------
class Cl6M_Ch9_A5_DesigningFigureswithSpecificRotationalOrders
    extends StatefulWidget {
  const Cl6M_Ch9_A5_DesigningFigureswithSpecificRotationalOrders({super.key});

  @override
  State<Cl6M_Ch9_A5_DesigningFigureswithSpecificRotationalOrders>
  createState() =>
      _Cl6M_Ch9_A5_DesigningFigureswithSpecificRotationalOrdersState();
}

class _Cl6M_Ch9_A5_DesigningFigureswithSpecificRotationalOrdersState
    extends State<Cl6M_Ch9_A5_DesigningFigureswithSpecificRotationalOrders>
    with TickerProviderStateMixin {
  final GameState state = GameState();
  final GlobalKey canvasKey = GlobalKey();

  late AnimationController _gameLoopController;
  late AnimationController _checkController;
  bool _isInteracting = false;
  double _baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..repeat();
    _gameLoopController.addListener(() {
      if (mounted) setState(() {});
    });

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _checkController.addListener(() {
      if (!state.isChecking) return;
      double progress = _checkController.value;
      double targetRot = 2 * math.pi;
      double ease = progress < 0.5
          ? 2 * progress * progress
          : 1 - math.pow(-2 * progress + 2, 2) / 2;
      state.hubRot = ease * targetRot;

      if (state.detectedOrder > 0) {
        double stepAng = (2 * math.pi) / state.detectedOrder;
        double nextSnapTarget = (state.displayOrder + 1) * stepAng;
        if (state.hubRot >= nextSnapTarget - 0.05 &&
            nextSnapTarget <= targetRot) {
          state.displayOrder++;
        }
      }
    });

    _checkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        state.hubRot = 0;
        state.isChecking = false;
        if (state.detectedOrder == 1) state.displayOrder = 1;
        _validateCheckResult();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.loadScenario(1);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoopController.dispose();
    _checkController.dispose();
    state.dispose();
    super.dispose();
  }

  void _triggerCheckSymmetry() {
    if (state.isChecking) return;
    AudioManager.playClick();
    state.detectedOrder = state.calculateRotationalOrder();
    state.displayOrder = 0;
    state.isChecking = true;
    state.hubRot = 0;
    _checkController.forward(from: 0);
  }

  void _validateCheckResult() {
    int s = state.scenario;
    int step = state.step;
    if (s == 3 && step == 1) {
      if (state.detectedOrder == 1) {
        AudioManager.playPageOpen();
        state.advanceStep();
      } else {
        AudioManager.playError();
      }
    } else if (s == 3 && step == 3) {
      if (state.detectedOrder == 3) {
        AudioManager.playPageOpen();
        state.advanceStep();
        Future.delayed(
          const Duration(seconds: 2),
          () => state.showSuccessPopup = true,
        );
      } else {
        AudioManager.playError();
      }
    } else if (s == 4 && step == 0) {
      int shapeCount = state.hubSlots.where((e) => e != null).length;
      if (state.detectedOrder == 6 && shapeCount == 6) {
        AudioManager.playPageOpen();
        state.s4ShowError = false;
        state.advanceStep();
        Future.delayed(
          const Duration(seconds: 1),
          () => state.showSuccessPopup = true,
        );
      } else {
        AudioManager.playError();
        state.s4ShowError = true;
      }
    } else if (s == 5 && step == 0) {
      bool hasRed = state.hubSlots.contains(ShapeType.circleRed);
      bool hasBlue = state.hubSlots.contains(ShapeType.squareBlue);
      if (state.detectedOrder == 3 && hasRed && hasBlue) {
        AudioManager.playPageOpen();
        state.s5ShowError = false;
        state.advanceStep();
        Future.delayed(
          const Duration(seconds: 1),
          () => state.showSuccessPopup = true,
        );
      } else {
        AudioManager.playError();
        state.s5ShowError = true;
      }
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (state.isChecking) return;
    state.s4ShowError = false;
    state.s5ShowError = false;

    RenderBox box = canvasKey.currentContext!.findRenderObject() as RenderBox;
    double worldX =
        (event.localPosition.dx - box.size.width / 2 - state.panX) / state.zoom;
    double worldY =
        (event.localPosition.dy - box.size.height / 2 - state.panY) /
        state.zoom;

    double hx = -50, hy = 0;

    // Handle Rotation Handle
    if (state.scenario == 1 || state.scenario == 2) {
      int spinStep = state.scenario == 1 ? 2 : 1;
      if (state.step == spinStep &&
          hypot(worldX - hx, worldY - (hy + 160)) < 40) {
        state.manualRotActive = true;
        state.lastRotAngle = math.atan2(worldX - hx, -(worldY - hy));
        AudioManager.playClick();
        _isInteracting = true;
        return;
      }
    }

    // Hub Pickup
    double hRadius = (state.scenario == 1)
        ? 100
        : (state.scenario == 2 || state.scenario == 3 ? 90 : 110);
    int bestHubSlot = -1;
    double bestHubDist = 40.0;

    for (int i = 0; i < 12; i++) {
      if (state.hubSlots[i] != null) {
        double sx = hx + hRadius * math.sin(i * math.pi / 6);
        double sy = hy - hRadius * math.cos(i * math.pi / 6);
        double dist = hypot(worldX - sx, worldY - sy);
        if (dist < bestHubDist) {
          bestHubDist = dist;
          bestHubSlot = i;
        }
      }
    }

    if (bestHubSlot != -1) {
      if (state.scenario == 3 &&
          state.step == 2 &&
          [0, 4, 8].contains(bestHubSlot)) {
        AudioManager.playError();
        return;
      }
      state.dragItem = DragItem(
        type: state.hubSlots[bestHubSlot]!,
        source: 'hub',
        index: bestHubSlot,
      );
      state.dragX = worldX;
      state.dragY = worldY;
      AudioManager.playClick();
      _isInteracting = true;
      return;
    }

    // Palette Pickup
    if (state.scenario <= 3) {
      double px = 250,
          py = -130,
          pw = 200,
          ph = state.scenario == 3 ? 120 : 260;
      if (worldX > px && worldX < px + pw && worldY > py && worldY < py + ph) {
        if (state.scenario == 3) {
          int usedCount = state.hubSlots
              .where((s) => s == ShapeType.triangleGreen)
              .length;
          if (state.step == 0 && usedCount < 3) {
            state.dragItem = DragItem(
              type: ShapeType.triangleGreen,
              source: 'palette',
              index: -1,
            );
            state.dragX = worldX;
            state.dragY = worldY;
            AudioManager.playClick();
            _isInteracting = true;
          } else {
            AudioManager.playError();
          }
          return;
        }
        ShapeType st = state.scenario == 1
            ? ShapeType.petalBlue
            : ShapeType.squareYellow;
        state.dragItem = DragItem(type: st, source: 'palette', index: -1);
        state.dragX = worldX;
        state.dragY = worldY;
        AudioManager.playClick();
        _isInteracting = true;
        return;
      }
    } else {
      double px = 250, py = -160, pw = 200, ph = 320;
      if (state.scenario == 5 && state.step >= 1) return;

      if (worldX > px && worldX < px + pw && worldY > py && worldY < py + ph) {
        for (int idx = 0; idx < state.paletteConfig.length; idx++) {
          int col = idx % 2;
          int row = idx ~/ 2;
          double cx = px + 60 + col * 80;
          double cy = py + 100 + row * 90;
          if (hypot(worldX - cx, worldY - cy) < 40) {
            state.dragItem = DragItem(
              type: state.paletteConfig[idx],
              source: 'palette',
              index: -1,
            );
            state.dragX = worldX;
            state.dragY = worldY;
            AudioManager.playClick();
            _isInteracting = true;
            return;
          }
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isInteracting || state.isChecking) return;

    RenderBox box = canvasKey.currentContext!.findRenderObject() as RenderBox;
    double worldX =
        (event.localPosition.dx - box.size.width / 2 - state.panX) / state.zoom;
    double worldY =
        (event.localPosition.dy - box.size.height / 2 - state.panY) /
        state.zoom;

    if (state.dragItem != null) {
      state.dragX = worldX;
      state.dragY = worldY;
      return;
    }

    if (state.manualRotActive) {
      double currentAngle = math.atan2(worldX - (-50), -(worldY));
      double diff = currentAngle - state.lastRotAngle;

      if (diff > math.pi) diff -= 2 * math.pi;
      if (diff < -math.pi) diff += 2 * math.pi;

      state.hubRot += diff;
      state.accumulatedRot += diff.abs();
      state.lastRotAngle = currentAngle;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isInteracting) return;
    _isInteracting = false;

    if (state.manualRotActive) {
      state.manualRotActive = false;
      if (state.accumulatedRot >= 2 * math.pi - 0.2) {
        int order = state.calculateRotationalOrder();
        if (order > 1) {
          state.hubRot = 0;
          state.accumulatedRot = 0;
          AudioManager.playPageOpen();
          Future.delayed(
            const Duration(milliseconds: 500),
            () => state.advanceStep(),
          );
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (state.scenario == 1 || state.scenario == 2) {
              state.step = scenarioConfigs[state.scenario]!.steps.length;
            }
          });
        }
      } else {
        int order = state.calculateRotationalOrder();
        if (order > 0) {
          double stepRad = (2 * math.pi) / order;
          double targetRot = (state.hubRot / stepRad).round() * stepRad;
          if ((state.hubRot - targetRot).abs() < 0.2) {
            state.hubRot = targetRot;
            AudioManager.playClick();
          }
        }
      }
      return;
    }

    if (state.dragItem != null) {
      bool dropped = false;
      double hCenter = -50;
      double hRadius = (state.scenario == 1)
          ? 100
          : (state.scenario == 2 || state.scenario == 3 ? 90 : 110);

      int bestSlot = -1;
      double bestDist = 50.0;

      for (int i = 0; i < 12; i++) {
        double hx = hCenter + hRadius * math.sin(i * math.pi / 6);
        double hy = -hRadius * math.cos(i * math.pi / 6);
        double dist = hypot(state.dragX - hx, state.dragY - hy);
        if (dist < bestDist) {
          bestDist = dist;
          bestSlot = i;
        }
      }

      if (bestSlot != -1) {
        int i = bestSlot;
        if (state.guidedSlots.isEmpty || state.guidedSlots.contains(i)) {
          if (state.hubSlots[i] == null) {
            if (state.dragItem!.source == 'hub')
              state.hubSlots[state.dragItem!.index] = null;
            state.hubSlots[i] = state.dragItem!.type;
            AudioManager.playClick();
            dropped = true;
            state.checkStepProgression();
          } else if (state.dragItem!.source == 'hub') {
            ShapeType temp = state.hubSlots[i]!;
            state.hubSlots[i] = state.dragItem!.type;
            state.hubSlots[state.dragItem!.index] = temp;
            AudioManager.playClick();
            dropped = true;
            state.checkStepProgression();
          }
        } else {
          AudioManager.playError();
        }
      }

      if (!dropped && state.dragItem!.source == 'hub') {
        if (state.scenario == 3 && state.step >= 2) {
          state.hubSlots[state.dragItem!.index] = state.dragItem!.type;
          AudioManager.playError();
        } else {
          state.hubSlots[state.dragItem!.index] = null;
          AudioManager.playClick();
        }
      }
      state.dragItem = null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              right: 0,
              left: state.sidebarOpen ? state.sidebarWidth : 0,
              child: GestureDetector(
                onScaleStart: (details) {
                  _baseZoom = state.zoom;
                },
                onScaleUpdate: (details) {
                  if (!_isInteracting && !state.isChecking) {
                    setState(() {
                      state.panX += details.focalPointDelta.dx;
                      state.panY += details.focalPointDelta.dy;
                      state.zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
                    });
                  }
                },
                child: Listener(
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUp,
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: ClipRect(
                      child: CustomPaint(
                        key: canvasKey,
                        painter: SimulationPainter(state),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              left: state.sidebarOpen ? 0 : -state.sidebarWidth,
              width: state.sidebarWidth,
              child: Container(
                color: const Color(0xFF1E293B).withOpacity(0.95),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Title
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 64.0,
                          right: 16.0,
                          bottom: 16.0,
                          left: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.architecture,
                                  color: Colors.indigoAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    t('appTitle', state.lang),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Text(
                                t('appSubtitle', state.lang),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Language and Reset Tools
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white12,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                    ),
                                    onPressed: () =>
                                        setState(() => state.toggleLanguage()),
                                    icon: const Icon(Icons.language, size: 16),
                                    label: Text(state.lang.toUpperCase()),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      AudioManager.playClick();
                                      state.loadScenario(1);
                                      state.curtainOpen = false;
                                    },
                                    tooltip: t('resetBtn', state.lang),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 1),

                      // Scenario Dropdown & Steps
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              t('selectScenario', state.lang).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF334155),
                                  value: state.scenario,
                                  items: scenarioConfigs.entries.map((e) {
                                    return DropdownMenuItem(
                                      value: e.key,
                                      child: Text(
                                        t(e.value.titleKey, state.lang),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      AudioManager.playDropdown();
                                      setState(() => state.loadScenario(val));
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.track_changes,
                                        color: Colors.redAccent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('learnLbl', state.lang),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellowAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t(
                                      scenarioConfigs[state.scenario]!.objKey,
                                      state.lang,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Steps
                            ...scenarioConfigs[state.scenario]!.steps
                                .asMap()
                                .entries
                                .map((e) {
                                  int idx = e.key;
                                  StepConfig sc = e.value;
                                  bool isCompleted = idx < state.step;
                                  bool isActive = idx == state.step;
                                  bool isFuture = idx > state.step;

                                  Color bgColor = isActive
                                      ? const Color(0x226366F1)
                                      : (isCompleted
                                            ? const Color(0x1110B981)
                                            : Colors.transparent);
                                  Color borderColor = isActive
                                      ? const Color(0xFF6366F1)
                                      : (isCompleted
                                            ? const Color(0xFF10B981)
                                            : Colors.white12);
                                  double opacity = isFuture ? 0.4 : 1.0;

                                  return Opacity(
                                    opacity: opacity,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          isCompleted
                                              ? const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.greenAccent,
                                                )
                                              : CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: isActive
                                                      ? Colors.indigoAccent
                                                      : Colors.white24,
                                                  child: Text(
                                                    '${idx + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
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
                                                  '${t('stepLabel', state.lang)} ${idx + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  t(sc.taskKey, state.lang),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: isActive
                                                        ? Colors.white
                                                        : Colors.white70,
                                                  ),
                                                ),
                                                if (isCompleted) ...[
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.green
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      t(sc.outKey, state.lang),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.greenAccent,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),

                      // Footer placed dynamically at the end of the content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFF020617),
                        child: const Text(
                          '© ZeroScienceLab - Fall in love with math and Science',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SIDEBAR BORDER & RESIZER
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              left: state.sidebarOpen ? state.sidebarWidth - 5 : -5,
              width: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  if (state.sidebarOpen) {
                    setState(() {
                      state.sidebarWidth += details.delta.dx;
                      if (state.sidebarWidth < 300) state.sidebarWidth = 300;
                      if (state.sidebarWidth > 600) state.sidebarWidth = 600;
                    });
                  }
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.white24, width: 1),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
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
              child: IconButton(
                icon: Icon(
                  state.sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => state.toggleSidebar(),
              ),
            ),

            // BOTTOM HUD MESSAGE
            if (state.step < scenarioConfigs[state.scenario]!.steps.length)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: 20,
                left: state.sidebarOpen ? state.sidebarWidth : 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.indigoAccent,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              t(
                                scenarioConfigs[state.scenario]!
                                    .steps[state.step]
                                    .hudKey,
                                state.lang,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ACTION BUTTONS (CHECK / NEXT)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 80,
              left: state.sidebarOpen ? state.sidebarWidth : 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((state.scenario == 3 &&
                            (state.step == 1 || state.step == 3)) ||
                        (state.scenario == 4 && state.step == 0) ||
                        (state.scenario == 5 && state.step == 0))
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _triggerCheckSymmetry,
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          t('checkBtn', state.lang),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    if (state.step ==
                            scenarioConfigs[state.scenario]!.steps.length &&
                        state.scenario < 5)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          AudioManager.playPageOpen();
                          state.loadScenario(state.scenario + 1);
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          t('nextScenario', state.lang),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // SUCCESS POPUP OVERLAY
            if (state.showSuccessPopup)
              Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.greenAccent,
                        child: Icon(Icons.star, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('summaryTitle', state.lang),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.scenario == 5
                            ? t('finalDesc', state.lang)
                            : "Great job! Ready for the next challenge?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.scenario < 5
                              ? Colors.indigoAccent
                              : Colors.amber.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          AudioManager.playPageOpen();
                          setState(() => state.showSuccessPopup = false);
                          if (state.scenario < 5)
                            state.loadScenario(state.scenario + 1);
                          else
                            state.loadScenario(1);
                        },
                        child: Text(
                          state.scenario < 5
                              ? t('nextScenario', state.lang)
                              : t('finishLab', state.lang),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // INITIAL CURTAIN
            if (!state.curtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.rotate_right,
                          size: 80,
                          color: Colors.indigoAccent,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          t('shutterTitle', state.lang),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t('appSubtitle', state.lang),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: () => setState(() => state.openCurtain()),
                          icon: const Icon(
                            Icons.play_circle_fill,
                            size: 28,
                            color: Colors.white,
                          ),
                          label: Text(
                            t('enterLab', state.lang),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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

// -----------------------------------------------------------------------------
// CUSTOM PAINTER (THE SIMULATION ENGINE)
// -----------------------------------------------------------------------------
class SimulationPainter extends CustomPainter {
  final GameState state;

  SimulationPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // Draw Background Grid
    Paint gridPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1;
    for (double i = -800; i <= 800; i += 100) {
      canvas.drawLine(Offset(i, -600), Offset(i, 600), gridPaint);
      canvas.drawLine(Offset(-800, i), Offset(800, i), gridPaint);
    }

    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 1)
      _renderS1(canvas);
    else if (state.scenario == 2)
      _renderS2(canvas);
    else if (state.scenario == 3)
      _renderS3(canvas);
    else if (state.scenario == 4)
      _renderS4(canvas);
    else if (state.scenario == 5)
      _renderS5(canvas);

    canvas.restore();
  }

  void _renderS1(Canvas canvas) {
    double hx = -50, hy = 0;

    // Palette
    _drawPalette(canvas, 250, -130, 200, 260, [ShapeType.petalBlue]);

    // Hub
    canvas.save();
    canvas.translate(hx, hy);

    Paint spokePaint = Paint()
      ..color = const Color(0xFFEAB308)
      ..strokeWidth = 3;
    for (int i = 0; i < 12; i += 2) {
      canvas.save();
      canvas.rotate(i * math.pi / 6);
      canvas.drawLine(Offset.zero, const Offset(0, -100), spokePaint);
      canvas.restore();
    }

    canvas.drawCircle(
      Offset.zero,
      45,
      Paint()..color = const Color(0xFF9CA3AF),
    );
    canvas.drawCircle(
      Offset.zero,
      45,
      Paint()
        ..color = const Color(0xFF6B7280)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (state.step >= 3) _drawText(canvas, '2', 0, 0, 42, Colors.white, true);

    for (int i = 0; i < 12; i += 2) {
      canvas.save();
      canvas.rotate(i * math.pi / 6);
      canvas.translate(0, -100);
      bool isGuided =
          state.guidedSlots.contains(i) && state.hubSlots[i] == null;
      if (isGuided) {
        canvas.drawCircle(
          Offset.zero,
          15,
          Paint()..color = const Color(0x66FACC15),
        );
        canvas.drawCircle(
          Offset.zero,
          15,
          Paint()
            ..color = const Color(0xFFFACC15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      } else if (state.hubSlots[i] == null) {
        canvas.drawCircle(
          Offset.zero,
          6,
          Paint()..color = const Color(0xFFFDE047),
        );
      }
      canvas.restore();
    }

    _renderShapesOnHub(canvas, -100);

    if (state.step == 2 || state.step == 3) {
      _drawHandle(canvas, 0, 160);
      _drawOrderCounter(canvas, 350, 0, 1, 355, 175, [175, 355]);
    }
    if (state.step >= 3)
      _drawSummary(canvas, 350, 0, t('s1_step4_out', state.lang));

    canvas.restore();
    _drawDragItem(canvas, hx, hy);
  }

  void _renderS2(Canvas canvas) {
    double hx = -50, hy = 0;

    _drawPalette(canvas, 250, -130, 200, 260, [
      ShapeType.squareYellow,
      ShapeType.squareYellow,
      ShapeType.squareYellow,
      ShapeType.squareYellow,
    ]);

    canvas.save();
    canvas.translate(hx, hy);

    Paint hubPaint = Paint()..color = const Color(0xFF9CA3AF);
    Paint strokePaint = Paint()
      ..color = const Color(0xFF6B7280)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    RRect r1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-30, -110, 60, 220),
      const Radius.circular(10),
    );
    RRect r2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-110, -30, 220, 60),
      const Radius.circular(10),
    );
    canvas.drawRRect(r1, hubPaint);
    canvas.drawRRect(r1, strokePaint);
    canvas.drawRRect(r2, hubPaint);
    canvas.drawRRect(r2, strokePaint);
    canvas.drawRect(const Rect.fromLTWH(-28, -28, 56, 56), hubPaint);

    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()..color = const Color(0xFF6B7280),
    );
    canvas.drawCircle(
      Offset.zero,
      10,
      Paint()..color = const Color(0xFF4B5563),
    );

    _drawText(canvas, "0°", 0, -50, 14, Colors.white, false);
    _drawText(canvas, "90°", 50, 0, 14, Colors.white, false);
    _drawText(canvas, "180°", 0, 50, 14, Colors.white, false);
    _drawText(canvas, "270°", -50, 0, 14, Colors.white, false);

    for (int i in [0, 3, 6, 9]) {
      canvas.save();
      canvas.rotate(i * math.pi / 6);
      canvas.translate(0, -90);
      if (state.guidedSlots.contains(i) && state.hubSlots[i] == null) {
        canvas.drawCircle(
          Offset.zero,
          15,
          Paint()..color = const Color(0x66FACC15),
        );
        canvas.drawCircle(
          Offset.zero,
          15,
          Paint()
            ..color = const Color(0xFFFACC15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
      canvas.restore();
    }

    _renderShapesOnHub(canvas, -90, 3);

    if (state.step == 1 || state.step == 2) {
      _drawHandle(canvas, 0, 160);
      _drawOrderCounter(canvas, 350, 0, 1, 355, 85, [85, 175, 265, 355]);
    }
    if (state.step >= 2)
      _drawSummary(canvas, 350, 0, t('s2_step3_out', state.lang));

    canvas.restore();
    _drawDragItem(canvas, hx, hy);
  }

  void _renderS3(Canvas canvas) {
    double hx = -50, hy = 0;

    int pcount =
        3 - state.hubSlots.where((s) => s == ShapeType.triangleGreen).length;
    if (state.dragItem?.type == ShapeType.triangleGreen) pcount--;
    List<ShapeType> pConf = List.filled(
      math.max(0, pcount),
      ShapeType.triangleGreen,
    );
    _drawPalette(canvas, 250, -130, 200, 120, pConf);

    canvas.save();
    canvas.translate(hx, hy);

    if (state.step >= 4) {
      Paint glow = Paint()
        ..color = const Color(0x8822C55E)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 12; i++) {
        canvas.save();
        canvas.rotate(i * math.pi / 6);
        canvas.drawLine(const Offset(0, -120), const Offset(0, -170), glow);
        canvas.restore();
      }
    }

    canvas.drawCircle(
      Offset.zero,
      110,
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawCircle(
      Offset.zero,
      110,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset.zero,
      45,
      Paint()..color = const Color(0xFF9CA3AF),
    );

    for (int i = 0; i < 12; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 6);
      canvas.translate(0, -90);
      if (state.guidedSlots.contains(i) && state.hubSlots[i] == null) {
        canvas.drawCircle(
          Offset.zero,
          12,
          Paint()..color = const Color(0x66FACC15),
        );
        canvas.drawCircle(
          Offset.zero,
          12,
          Paint()
            ..color = const Color(0xFFFACC15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else if (state.hubSlots[i] == null) {
        canvas.drawCircle(
          Offset.zero,
          5,
          Paint()..color = const Color(0xFF94A3B8),
        );
      }
      canvas.restore();
    }

    _renderShapesOnHub(canvas, -90);

    // Custom Order Counter logic for S3
    canvas.save();
    canvas.translate(350, -120);
    RRect cntRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-100, -25, 220, 50),
      const Radius.circular(8),
    );
    canvas.drawRRect(cntRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      cntRect,
      Paint()
        ..color = const Color(0xFF9CA3AF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawText(canvas, "ORDER:", -25, 0, 16, const Color(0xFF1E293B), true);

    int disp = state.step == 0 ? 0 : state.displayOrder;
    if (state.step >= 2 && state.step < 4) disp = 1;
    if (state.step >= 4) disp = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(70, -18, 36, 36),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFF1F5F9),
    );
    _drawText(
      canvas,
      disp.toString(),
      88,
      0,
      22,
      const Color(0xFF334155),
      true,
    );

    if (state.step == 2) {
      canvas.translate(0, 90);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-140, -50, 280, 100),
          const Radius.circular(12),
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        const Offset(-100, -20),
        18,
        Paint()..color = Colors.redAccent,
      );
      _drawText(canvas, "TRY AGAIN!", 0, -25, 18, Colors.redAccent, true);
    } else if (state.step >= 4) {
      canvas.translate(0, 90);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-140, -50, 280, 100),
          const Radius.circular(12),
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        const Offset(-100, -20),
        18,
        Paint()..color = Colors.green,
      );
      _drawText(canvas, "PERFECT!", 0, -25, 18, Colors.green, true);
    }
    canvas.restore();

    canvas.restore();
    _drawDragItem(canvas, hx, hy);
  }

  void _renderS4(Canvas canvas) {
    double hx = -50, hy = 0;

    // Top Goal banner
    canvas.save();
    canvas.translate(hx, -220);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-150, -25, 300, 50),
        const Radius.circular(25),
      ),
      Paint()..color = const Color(0xFFFDE047),
    );
    _drawText(
      canvas,
      "GOAL: CREATE ORDER 6",
      20,
      0,
      18,
      const Color(0xFF1E293B),
      true,
    );
    canvas.restore();

    _drawPalette(canvas, 250, -160, 200, 320, state.paletteConfig);

    canvas.save();
    canvas.translate(hx, hy);

    canvas.drawCircle(
      Offset.zero,
      130,
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawCircle(
      Offset.zero,
      130,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset.zero,
      55,
      Paint()..color = const Color(0xFF9CA3AF),
    );

    if (state.step >= 1 && !state.s4ShowError) {
      Paint glow = Paint()
        ..color = const Color(0x6622C55E)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 12; i++) {
        canvas.save();
        canvas.rotate(i * math.pi / 6);
        canvas.drawLine(const Offset(0, -140), const Offset(0, -200), glow);
        canvas.restore();
      }
    }

    for (int i = 0; i < 12; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 6);
      canvas.translate(0, -110);
      if (state.hubSlots[i] == null) {
        canvas.drawCircle(
          Offset.zero,
          5,
          Paint()..color = const Color(0xFFFACC15),
        );
      }
      canvas.restore();
    }

    _renderShapesOnHub(canvas, -110);
    canvas.restore();

    if (state.s4ShowError) {
      canvas.save();
      canvas.translate(hx + 100, hy + 180);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-180, -70, 360, 140),
          const Radius.circular(12),
        ),
        Paint()..color = Colors.white,
      );
      _drawText(
        canvas,
        "Try Again! Detected Order: ${state.detectedOrder}",
        0,
        -20,
        18,
        Colors.redAccent,
        true,
      );
      canvas.restore();
    } else if (state.step >= 1) {
      canvas.save();
      canvas.translate(hx, hy - 220);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-160, -15, 320, 60),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.pinkAccent,
      );
      _drawText(canvas, "CHALLENGE COMPLETE!", 0, 15, 22, Colors.white, true);
      canvas.restore();
    }

    if (state.isChecking || (!state.s4ShowError && state.step == 0)) {
      canvas.save();
      canvas.translate(250 + 100, -160 - 60);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-60, -30, 120, 60),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.white,
      );
      _drawText(canvas, "Order:", -20, 0, 16, Colors.black, true);
      _drawText(
        canvas,
        state.displayOrder.toString(),
        38,
        0,
        22,
        Colors.black,
        true,
      );
      canvas.restore();
    }

    _drawDragItem(canvas, hx, hy);
  }

  void _renderS5(Canvas canvas) {
    double hx = -50, hy = 0;

    canvas.save();
    canvas.translate(hx, -220);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-200, -25, 400, 50),
        const Radius.circular(25),
      ),
      Paint()..color = const Color(0xFFF8FAFC),
    );
    _drawText(
      canvas,
      "CREATE ORDER 3 (USING BOTH SHAPES)",
      0,
      0,
      16,
      const Color(0xFF1E293B),
      true,
    );
    canvas.restore();

    if (state.step == 0) {
      _drawPalette(canvas, 250, -160, 200, 320, state.paletteConfig);
    }

    canvas.save();
    canvas.translate(hx, hy);

    canvas.drawCircle(
      Offset.zero,
      130,
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawCircle(
      Offset.zero,
      130,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset.zero,
      55,
      Paint()..color = const Color(0xFF9CA3AF),
    );

    if (state.step >= 1 && !state.s5ShowError) {
      Paint glow = Paint()
        ..color = const Color(0x8810B981)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 12; i += 4) {
        canvas.save();
        canvas.rotate(i * math.pi / 6);
        canvas.drawLine(const Offset(0, -140), const Offset(0, -220), glow);
        canvas.restore();
      }
    }

    for (int i = 0; i < 12; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 6);
      canvas.translate(0, -110);
      if (state.hubSlots[i] == null) {
        canvas.drawCircle(
          Offset.zero,
          5,
          Paint()..color = const Color(0xFFFACC15),
        );
      }
      canvas.restore();
    }

    _renderShapesOnHub(canvas, -110);
    canvas.restore();

    if (state.s5ShowError) {
      canvas.save();
      canvas.translate(hx + 120, hy - 100);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 260, 100),
          const Radius.circular(12),
        ),
        Paint()..color = Colors.white,
      );
      _drawText(
        canvas,
        "ORDER ${state.detectedOrder}. TRY AGAIN!",
        130,
        50,
        16,
        Colors.red,
        true,
      );
      canvas.restore();
    } else if (state.step >= 1) {
      canvas.save();
      canvas.translate(250 + 100, -160 + 160 - 40);
      canvas.drawCircle(Offset.zero, 35, Paint()..color = Colors.amber);
      _drawText(canvas, "MASTER DESIGNER", 0, 60, 18, Colors.amber, true);
      canvas.restore();
    }

    if (state.isChecking || (!state.s5ShowError && state.step == 0)) {
      canvas.save();
      canvas.translate(250 + 100, -160 - 60);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-60, -30, 120, 60),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.white,
      );
      _drawText(canvas, "Order:", -20, 0, 16, Colors.black, true);
      _drawText(
        canvas,
        state.displayOrder.toString(),
        38,
        0,
        22,
        Colors.black,
        true,
      );
      canvas.restore();
    }

    _drawDragItem(canvas, hx, hy);
  }

  // Helpers
  void _drawPalette(
    Canvas canvas,
    double px,
    double py,
    double pw,
    double ph,
    List<ShapeType> shapes,
  ) {
    RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(px, py, pw, ph),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFFD1D5DB));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFF9CA3AF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawText(
      canvas,
      "SHAPES PALETTE",
      px + pw / 2,
      py + 25,
      14,
      Colors.black,
      true,
    );

    for (int i = 0; i < shapes.length; i++) {
      int col = i % 2;
      int row = i ~/ 2;
      double cx = px + 60 + col * 80;
      double cy = py + 100 + row * 90;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(0.8, 0.8);
      _drawShape(canvas, shapes[i]);
      canvas.restore();
    }
  }

  void _renderShapesOnHub(Canvas canvas, double radiusOffset, [int step = 1]) {
    double alpha = state.isChecking ? 0.3 : 1.0;

    // Static base layer during check
    canvas.save();
    for (int i = 0; i < 12; i += step) {
      if (state.hubSlots[i] != null &&
          !(state.dragItem?.source == 'hub' && state.dragItem?.index == i)) {
        canvas.save();
        canvas.rotate(i * math.pi / 6);
        canvas.translate(0, radiusOffset);
        _drawShape(canvas, state.hubSlots[i]!, alpha: alpha);
        canvas.restore();
      }
    }
    canvas.restore();

    // Rotating layer during check
    if (state.isChecking || state.manualRotActive) {
      canvas.save();
      canvas.rotate(state.hubRot);
      for (int i = 0; i < 12; i += step) {
        if (state.hubSlots[i] != null &&
            !(state.dragItem?.source == 'hub' && state.dragItem?.index == i)) {
          canvas.save();
          canvas.rotate(i * math.pi / 6);
          canvas.translate(0, radiusOffset);
          _drawShape(canvas, state.hubSlots[i]!);
          canvas.restore();
        }
      }
      canvas.restore();
    }
  }

  void _drawDragItem(Canvas canvas, double hx, double hy) {
    if (state.dragItem != null && !state.isChecking) {
      canvas.save();
      canvas.translate(state.dragX, state.dragY);
      if (hypot(state.dragX - hx, state.dragY - hy) < 200) {
        double angle = math.atan2(state.dragX - hx, -(state.dragY - hy));
        int slotIdx = (angle / (math.pi / 6)).round();
        if (slotIdx < 0) slotIdx += 12;
        canvas.rotate(slotIdx * math.pi / 6);
      }
      canvas.scale(1.1, 1.1);
      _drawShape(canvas, state.dragItem!.type);
      canvas.restore();
    }
  }

  void _drawHandle(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawCircle(
      Offset.zero,
      30,
      Paint()..color = const Color(0xFFF3F4F6),
    );
    canvas.drawCircle(
      Offset.zero,
      30,
      Paint()
        ..color = state.manualRotActive
            ? Colors.indigoAccent
            : const Color(0xFF374151)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    Paint arrow = Paint()
      ..color = state.manualRotActive
          ? Colors.indigoAccent
          : const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(
      const Rect.fromLTRB(-15, -15, 15, 15),
      -math.pi / 2,
      math.pi * 0.8,
      false,
      arrow,
    );
    _drawText(canvas, "SPIN", 0, 45, 12, Colors.white, true);
    canvas.restore();
  }

  void _drawOrderCounter(
    Canvas canvas,
    double x,
    double y,
    double minV,
    double maxV,
    double threshold,
    List<double> marks,
  ) {
    canvas.save();
    canvas.translate(x, y);
    RRect cntRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-55, -35, 110, 70),
      const Radius.circular(8),
    );
    canvas.drawRRect(cntRect, Paint()..color = const Color(0xFF262626));

    int count = 0;
    double totalDeg = state.accumulatedRot * 180 / math.pi;
    for (double m in marks) {
      if (totalDeg >= m) count++;
    }

    _drawText(canvas, count.toString(), 0, 0, 44, Colors.greenAccent, true);
    _drawText(canvas, "ORDER COUNTER", 0, -50, 14, Colors.white, true);
    canvas.restore();
  }

  void _drawSummary(Canvas canvas, double x, double y, String text) {
    canvas.save();
    canvas.translate(x, y);
    RRect r = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-160, -80, 320, 160),
      const Radius.circular(12),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white);
    _drawText(canvas, text, 0, 0, 16, Colors.black, true);
    canvas.restore();
  }

  void _drawShape(Canvas canvas, ShapeType type, {double alpha = 1.0}) {
    Paint fill = Paint()
      ..style = PaintingStyle.fill
      ..color = _getShapeMainColor(type).withOpacity(alpha);
    Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..color = _getShapeStrokeColor(type).withOpacity(alpha);
    Paint highlight = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.3 * alpha);

    Path p = Path();
    Path hl = Path();

    switch (type) {
      case ShapeType.petalBlue:
        p.moveTo(0, 25);
        p.quadraticBezierTo(25, -5, 0, -30);
        p.quadraticBezierTo(-25, -5, 0, 25);
        hl.moveTo(-2, 18);
        hl.quadraticBezierTo(8, 0, -2, -18);
        break;
      case ShapeType.squareYellow:
      case ShapeType.squareBlue:
        p.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-18, -18, 36, 36),
            const Radius.circular(4),
          ),
        );
        hl.addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-12, -12, 14, 14),
            const Radius.circular(2),
          ),
        );
        break;
      case ShapeType.triangleGreen:
        p.moveTo(0, 15);
        p.lineTo(-20, -18);
        p.lineTo(20, -18);
        p.close();
        hl.moveTo(0, 9);
        hl.lineTo(-12, -12);
        hl.lineTo(12, -12);
        hl.close();
        break;
      case ShapeType.circleRed:
        p.addOval(const Rect.fromLTRB(-18, -18, 18, 18));
        hl.addOval(const Rect.fromLTRB(-11, -11, -1, -1));
        break;
    }

    canvas.drawPath(p, fill);
    canvas.drawPath(p, stroke);
    canvas.drawPath(hl, highlight);
  }

  Color _getShapeMainColor(ShapeType type) {
    switch (type) {
      case ShapeType.petalBlue:
        return const Color(0xFF38BDF8);
      case ShapeType.squareYellow:
        return const Color(0xFFFACC15);
      case ShapeType.squareBlue:
        return const Color(0xFF3B82F6);
      case ShapeType.triangleGreen:
        return const Color(0xFF84CC16);
      case ShapeType.circleRed:
        return const Color(0xFFEF4444);
    }
  }

  Color _getShapeStrokeColor(ShapeType type) {
    switch (type) {
      case ShapeType.petalBlue:
        return const Color(0xFF0369A1);
      case ShapeType.squareYellow:
        return const Color(0xFFA16207);
      case ShapeType.squareBlue:
        return const Color(0xFF1D4ED8);
      case ShapeType.triangleGreen:
        return const Color(0xFF4D7C0F);
      case ShapeType.circleRed:
        return const Color(0xFFB91C1C);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color,
    bool bold,
  ) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: 280);
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) => true;
}
