// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Real-World Integers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto', brightness: Brightness.dark),
      home: const Cl6M_Ch10_A6_RealWorldApplicationsOfIntegers(),
    ),
  );
}

// --- TRANSLATIONS DICTIONARY ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': "Real-World Integers: From Skyscrapers to Sea Beds",
    'appSubtitle': "Class 6 • THE OTHER SIDE OF ZERO",
    'enterLab': "Enter Simulation",
    'appTitle': "Real-World Integers",
    'selectScenario': "Select Scenario",
    'learnLbl': "Objective:",
    'settings': "Settings",
    'theme': "Theme",
    'doneBtn': "Done",
    'stepLabel': "STEP",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You have successfully explored integers in real-world contexts!",
    's1_title': "1. Bela's Building of Fun",
    's1_obj':
        "Use positive and negative button presses to move a character in a lift.",
    's1_step1_task':
        "DRAG the '+' button to the 'Press' slot on the control panel to go from Floor 0 to Floor +1.",
    's1_step1_out': "The lift moves UP. Equation: 0 + (+1) = +1.",
    's1_step2_task':
        "DRAG two '-' buttons to the 'Press' slot to go from Floor +1 to Floor -1.",
    's1_step2_out': "The lift moves DOWN. Equation: (+1) + (-2) = -1.",
    's1_step3_task':
        "DRAG three '+' buttons to the 'Press' slot to go from Floor -1 to Floor +2.",
    's1_step3_out': "The lift moves UP. Equation: (-1) + (+3) = +2.",
    's1_hud1':
        "Drag the '+' button from the panel into the yellow 'Press' slot.",
    's1_hud2': "Drag two '-' buttons into the 'Press' slot.",
    's1_hud3': "Drag three '+' buttons into the 'Press' slot.",
    's2_title': "2. Managing a Bank Account",
    's2_obj':
        "Understand credits and debits as positive and negative integers.",
    's2_step1_task':
        "DRAG the green 'Credit' bag (+₹100) and DROP it onto the vault door.",
    's2_step1_out': "Balance increases. 0 + (+100) = +100.",
    's2_step2_task':
        "DRAG the red 'Debit' bill (-₹30) and DROP it onto the vault door.",
    's2_step2_out': "Balance decreases. (+100) + (-30) = +70.",
    's2_step3_task': "DRAG the large red 'Debit' bill (-₹150) to the vault.",
    's2_step3_out':
        "Balance drops below zero! (+70) + (-150) = -80 (Overdraft).",
    's2_hud1': "Drag the Green Money Bag (+₹100) to the Bank Vault.",
    's2_hud2': "Drag the Red Bill (-₹30) to the Bank Vault.",
    's2_hud3': "Drag the Large Red Bill (-₹150) to the Bank Vault.",
    's3_title': "3. Mountain Expedition",
    's3_obj': "Understand altitude relative to sea level (0) using integers.",
    's3_step1_task':
        "Helicopter is at +500m. Descend to Base Camp A (+200m). Click 'Descend' and enter the required movement.",
    's3_step1_out': "Movement: -300m. Equation: (+500) + (-300) = +200.",
    's3_step2_task':
        "Climber is at +200m. Rappel to the supply cache (-50m). Click 'Move' and enter the movement.",
    's3_step2_out': "Movement: -250m. Equation: (+200) + (-250) = -50.",
    's3_step3_task':
        "Climber is at -50m. Climb to the summit (+700m). Click 'Climb' and enter the movement.",
    's3_step3_out': "Movement: +750m. Equation: (-50) + (+750) = +700.",
    's3_hud1': "Click 'Descend' and enter '-300' into the keypad.",
    's3_hud2': "Click 'Move' and enter '-250' into the keypad.",
    's3_hud3': "Click 'Climb' and enter '750' into the keypad.",
    's4_title': "4. Deep Sea Treasure Hunt",
    's4_obj': "Calculate movements to guide a submarine to a target depth.",
    's4_step1_task':
        "Submarine is at +10m. Dive to the treasure at -90m. Click 'Dive' and enter the value.",
    's4_step1_out': "You moved -100m. Equation: (+10) + (-100) = -90.",
    's4_step2_task':
        "Ascend from -90m to the drone at +20m. Click 'Ascend' and enter the value.",
    's4_step2_out': "You moved +110m. Equation: (-90) + (+110) = +20.",
    's4_hud1': "Click 'Dive' and enter '-100' using the keypad.",
    's4_hud2': "Click 'Ascend' and enter '110' using the keypad.",
    's5_title': "5. The Lemonade Stand Challenge",
    's5_obj':
        "Manage a budget applying positive integers (revenue) and negative integers (costs).",
    's5_step1_task':
        "Start with \$20. DRAG 'Lemons & Sugar' (-\$8) and 'Cups' (-\$5) to the stand.",
    's5_step1_out': "Budget drops. 20 - 8 - 5 = 7.",
    's5_step2_task': "DRAG 'Day 1 Earnings' (+\$15) to your cash box.",
    's5_step2_out': "Budget increases. 7 + 15 = 22.",
    's5_step3_task':
        "DRAG Ice (-\$6), Earnings (+\$25), Repair (-\$10), Earnings (+\$5).",
    's5_step3_out': "Final Budget: \$36. Profit: \$16!",
    's5_hud1': "Drag both Supply icons (-8, -5) to the Lemonade Stand.",
    's5_hud2': "Drag the Earnings icon (+15) to the Stand.",
    's5_hud3': "Drag the remaining icons in any order to the Stand.",
  },
  'hi': {
    'shutterTitle':
        "वास्तविक दुनिया के पूर्णांक: गगनचुंबी इमारतों से समुद्र तल तक",
    'appSubtitle': "कक्षा 6 • शून्य की दूसरी ओर",
    'enterLab': "सिमुलेशन दर्ज करें",
    'appTitle': "वास्तविक दुनिया के पूर्णांक",
    'selectScenario': "परिदृश्य चुनें",
    'learnLbl': "उद्देश्य:",
    'settings': "सेटिंग्स",
    'theme': "थीम",
    'doneBtn': "पूर्ण",
    'stepLabel': "चरण",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc':
        "आपने वास्तविक दुनिया में पूर्णांकों का सफलतापूर्वक पता लगाया है!",
    's1_title': "1. बेला की मज़ेदार इमारत",
    's1_obj':
        "लिफ्ट में एक पात्र को ले जाने के लिए धनात्मक और ऋणात्मक बटनों का उपयोग करें।",
    's1_step1_task':
        "मंजिल 0 से मंजिल +1 तक जाने के लिए '+' बटन को 'प्रेस' स्लॉट में खींचें।",
    's1_step1_out': "लिफ्ट ऊपर जाती है। समीकरण: 0 + (+1) = +1.",
    's1_step2_task':
        "मंजिल +1 से मंजिल -1 तक जाने के लिए दो '-' बटन 'प्रेस' स्लॉट में खींचें।",
    's1_step2_out': "लिफ्ट नीचे जाती है। समीकरण: (+1) + (-2) = -1.",
    's1_step3_task': "मंजिल -1 से मंजिल +2 तक जाने के लिए तीन '+' बटन खींचें।",
    's1_step3_out': "लिफ्ट ऊपर जाती है। समीकरण: (-1) + (+3) = +2.",
    's1_hud1': "'+' बटन को पैनल से 'प्रेस' स्लॉट में खींचें।",
    's1_hud2': "दो '-' बटन को 'प्रेस' स्लॉट में खींचें।",
    's1_hud3': "तीन '+' बटन को 'प्रेस' स्लॉट में खींचें।",
    's2_title': "2. बैंक खाता प्रबंधित करना",
    's2_obj':
        "जमा (credit) और खर्च (debit) को धनात्मक और ऋणात्मक पूर्णांक के रूप में समझें।",
    's2_step1_task': "हरे 'क्रेडिट' बैग (+₹100) को वॉल्ट के दरवाजे पर खींचें।",
    's2_step1_out': "बैलेंस बढ़ता है। 0 + (+100) = +100.",
    's2_step2_task': "लाल 'डेबिट' बिल (-₹30) को वॉल्ट के दरवाजे पर खींचें।",
    's2_step2_out': "बैलेंस घटता है। (+100) + (-30) = +70.",
    's2_step3_task': "बड़े लाल 'डेबिट' बिल (-₹150) को वॉल्ट पर खींचें।",
    's2_step3_out':
        "बैलेंस शून्य से नीचे चला जाता है! (+70) + (-150) = -80 (ओवरड्राफ्ट)।",
    's2_hud1': "हरे मनी बैग (+₹100) को वॉल्ट पर खींचें।",
    's2_hud2': "लाल बिल (-₹30) को वॉल्ट पर खींचें।",
    's2_hud3': "बड़े लाल बिल (-₹150) को वॉल्ट पर खींचें।",
    's3_title': "3. पर्वतीय अभियान",
    's3_obj':
        "समुद्र तल (0) के सापेक्ष ऊंचाई को पूर्णांकों का उपयोग करके समझें।",
    's3_step1_task':
        "हेलीकॉप्टर +500m पर है। बेस कैंप (+200m) तक नीचे जाएं। 'Descend' पर क्लिक करें और मान दर्ज करें।",
    's3_step1_out': "गति: (-300)। समीकरण: (+500) + (-300) = +200.",
    's3_step2_task':
        "पर्वतारोही +200m पर है। घाटी (-50m) तक जाएं। 'Move' पर क्लिक करें और मान दर्ज करें।",
    's3_step2_out': "गति: (-250)। समीकरण: (+200) + (-250) = -50.",
    's3_step3_task':
        "पर्वतारोही -50m पर है। शिखर (+700m) तक जाएं। 'Climb' पर क्लिक करें और मान दर्ज करें।",
    's3_step3_out': "गति: (+750)। समीकरण: (-50) + (+750) = +700.",
    's3_hud1': "'Descend' पर क्लिक करें और कीपैड से '-300' दर्ज करें।",
    's3_hud2': "'Move' पर क्लिक करें और कीपैड से '-250' दर्ज करें।",
    's3_hud3': "'Climb' पर क्लिक करें और कीपैड से '750' दर्ज करें।",
    's4_title': "4. गहरे समुद्र में खजाने की खोज",
    's4_obj':
        "पनडुब्बी को लक्ष्य गहराई तक निर्देशित करने के लिए गति की गणना करें।",
    's4_step1_task':
        "पनडुब्बी +10m पर है। खजाने (-90m) तक गोता लगाएँ। 'Dive' पर क्लिक करें और मान दर्ज करें।",
    's4_step1_out': "आप -100m चले गए। समीकरण: (+10) + (-100) = -90.",
    's4_step2_task':
        "-90m से ड्रोन (+20m) तक ऊपर चढ़ें। 'Ascend' पर क्लिक करें और मान दर्ज करें।",
    's4_step2_out': "आप +110m चले गए। समीकरण: (-90) + (+110) = +20.",
    's4_hud1': "'Dive' पर क्लिक करें और '-100' दर्ज करें।",
    's4_hud2': "'Ascend' पर क्लिक करें और '110' दर्ज करें।",
    's5_title': "5. नींबू पानी स्टैंड चुनौती",
    's5_obj':
        "धनात्मक पूर्णांक (आय) और ऋणात्मक पूर्णांक (लागत) लागू करके बजट प्रबंधित करें।",
    's5_step1_task':
        "\$20 से शुरू करें। 'नींबू और चीनी' (-\$8) और 'कप' (-\$5) को स्टैंड पर खींचें।",
    's5_step1_out': "बजट घटता है। 20 - 8 - 5 = 7.",
    's5_step2_task': "'दिन 1 की कमाई' (+\$15) को अपने कैश बॉक्स में खींचें।",
    's5_step2_out': "बजट बढ़ता है। 7 + 15 = 22.",
    's5_step3_task':
        "बर्फ (-\$6), कमाई (+\$25), मरम्मत (-\$10), कमाई (+\$5) को खींचें।",
    's5_step3_out': "अंतिम बजट: \$36। लाभ: \$16!",
    's5_hud1': "दोनों आपूर्ति आइकन (-8, -5) को स्टैंड पर खींचें।",
    's5_hud2': "कमाई आइकन (+15) को स्टैंड पर खींचें।",
    's5_hud3': "शेष सभी आइकनों को स्टैंड पर खींचें।",
  },
};

// --- DATA MODELS ---

class DragItem {
  final int id;
  final String type;
  final String lbl;
  double x, y;
  double hx, hy; // Home coordinates
  double val;
  bool dropped;

  DragItem({
    required this.id,
    required this.type,
    this.lbl = '',
    required this.x,
    required this.y,
    required this.hx,
    required this.hy,
    required this.val,
    this.dropped = false,
  });
}

class DropZone {
  final double x, y, w, h;
  final String lbl;
  DropZone({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.lbl = '',
  });

  bool hitTest(Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }
}

class KeypadState {
  bool visible = false;
  String value = '';
  String targetAction = '';
  double expectedVal = 0;
  Rect rect = Rect.zero;
  List<Map<String, dynamic>> hitboxes = [];
}

// --- STATE MANAGER ---

class SimState extends ChangeNotifier {
  String lang = 'en';
  int scenario = 1;
  int step = 0;

  double panX = 0, panY = 0, zoom = 1.0;

  bool animating = false;
  bool showCurtain = true;
  bool showSuccess = false;

  // S1
  double liftFloor = 0, liftVisualFloor = 0;
  List<double> path = [0];
  List<double> equation = [];

  // S2
  double balance = 0, visualBalance = 0;

  // S3
  double altitude = 500;
  String activeChar = 'heli';

  // S4
  double s4Altitude = 10;
  bool packageDelivered = false;

  // S5
  double budget = 20, visualBudget = 20;

  int itemsProcessed = 0;
  bool showEquation = false;

  List<DragItem> dragItems = [];
  int? activeDrag;
  DropZone? dropZone;
  KeypadState keypad = KeypadState();
  Rect? btnRect;

  String t(String key) => translations[lang]?[key] ?? key;

  void toggleLang() {
    lang = lang == 'en' ? 'hi' : 'en';
    notifyListeners();
  }

  void loadScenario(int id) {
    scenario = id;
    step = 0;
    animating = false;
    keypad.visible = false;
    itemsProcessed = 0;
    showEquation = false;
    showSuccess = false;

    if (scenario == 1) {
      liftFloor = 0;
      liftVisualFloor = 0;
      path = [0];
      equation = [];
      panX = 120;
      panY = -30;
      zoom = 1.0;
    }
    if (scenario == 2) {
      balance = 0;
      visualBalance = 0;
      panX = -50;
      panY = 50;
      zoom = 1.0;
    }
    if (scenario == 3) {
      altitude = 500;
      activeChar = 'heli';
      panX = 50;
      panY = 50;
      zoom = 1.0;
    }
    if (scenario == 4) {
      s4Altitude = 10;
      packageDelivered = false;
      panX = 0;
      panY = -150;
      zoom = 1.0;
    }
    if (scenario == 5) {
      budget = 20;
      visualBudget = 20;
      panX = 0;
      panY = 50;
      zoom = 1.0;
    }

    _setupDraggables();
    notifyListeners();
  }

  void _setupDraggables() {
    dragItems.clear();
    dropZone = null;

    if (scenario == 1) {
      double cx = 100, cy = -160, cw = 120, ch = 320;
      dropZone = DropZone(
        x: cx + 15,
        y: cy + ch - 70,
        w: cw - 30,
        h: 50,
        lbl: 'Press',
      );
      double trayX = cx + cw / 2;
      if (step == 0) {
        dragItems.add(
          DragItem(
            id: 1,
            type: 'plus',
            x: trayX,
            y: cy + 100,
            hx: trayX,
            hy: cy + 100,
            val: 1,
          ),
        );
      } else if (step == 1) {
        dragItems.add(
          DragItem(
            id: 2,
            type: 'minus',
            x: trayX,
            y: cy + 80,
            hx: trayX,
            hy: cy + 80,
            val: -1,
          ),
        );
        dragItems.add(
          DragItem(
            id: 3,
            type: 'minus',
            x: trayX,
            y: cy + 140,
            hx: trayX,
            hy: cy + 140,
            val: -1,
          ),
        );
      } else if (step == 2) {
        dragItems.add(
          DragItem(
            id: 4,
            type: 'plus',
            x: trayX,
            y: cy + 60,
            hx: trayX,
            hy: cy + 60,
            val: 1,
          ),
        );
        dragItems.add(
          DragItem(
            id: 5,
            type: 'plus',
            x: trayX,
            y: cy + 120,
            hx: trayX,
            hy: cy + 120,
            val: 1,
          ),
        );
        dragItems.add(
          DragItem(
            id: 6,
            type: 'plus',
            x: trayX,
            y: cy + 180,
            hx: trayX,
            hy: cy + 180,
            val: 1,
          ),
        );
      }
    } else if (scenario == 2) {
      double trayX = 0, trayY = 100;
      dropZone = DropZone(x: -300, y: -150, w: 300, h: 280);
      if (step == 0) {
        dragItems.add(
          DragItem(
            id: 1,
            type: 'moneybag_green',
            x: trayX,
            y: trayY,
            hx: trayX,
            hy: trayY,
            val: 100,
          ),
        );
      }
      if (step == 1) {
        dragItems.add(
          DragItem(
            id: 2,
            type: 'bill_red_30',
            x: trayX,
            y: trayY,
            hx: trayX,
            hy: trayY,
            val: -30,
          ),
        );
      }
      if (step == 2) {
        dragItems.add(
          DragItem(
            id: 3,
            type: 'bill_red_150',
            x: trayX,
            y: trayY,
            hx: trayX,
            hy: trayY,
            val: -150,
          ),
        );
      }
    } else if (scenario == 5) {
      double trayX = -250, trayY = 100;
      dropZone = DropZone(x: -100, y: 50, w: 200, h: 100, lbl: 'Stand');
      if (step == 0) {
        dragItems.add(
          DragItem(
            id: 1,
            type: 'lemon',
            lbl: '-\$8',
            x: trayX,
            y: trayY,
            hx: trayX,
            hy: trayY,
            val: -8,
          ),
        );
        dragItems.add(
          DragItem(
            id: 2,
            type: 'cups',
            lbl: '-\$5',
            x: trayX + 100,
            y: trayY,
            hx: trayX + 100,
            hy: trayY,
            val: -5,
          ),
        );
      } else if (step == 1) {
        dragItems.add(
          DragItem(
            id: 3,
            type: 'moneybag_lemonade',
            lbl: '+\$15',
            x: trayX + 50,
            y: trayY,
            hx: trayX + 50,
            hy: trayY,
            val: 15,
          ),
        );
      } else if (step == 2) {
        dragItems.add(
          DragItem(
            id: 4,
            type: 'ice',
            lbl: '-\$6',
            x: trayX - 50,
            y: trayY,
            hx: trayX - 50,
            hy: trayY,
            val: -6,
          ),
        );
        dragItems.add(
          DragItem(
            id: 5,
            type: 'moneybag_lemonade',
            lbl: '+\$25',
            x: trayX + 30,
            y: trayY,
            hx: trayX + 30,
            hy: trayY,
            val: 25,
          ),
        );
        dragItems.add(
          DragItem(
            id: 6,
            type: 'repair',
            lbl: '-\$10',
            x: trayX + 110,
            y: trayY,
            hx: trayX + 110,
            hy: trayY,
            val: -10,
          ),
        );
        dragItems.add(
          DragItem(
            id: 7,
            type: 'moneybag_lemonade',
            lbl: '+\$5',
            x: trayX + 190,
            y: trayY,
            hx: trayX + 190,
            hy: trayY,
            val: 5,
          ),
        );
      }
    }
  }

  void advanceStep() {
    step++;
    showEquation = false;
    if (scenario == 1) {
      equation.clear();
      if (step == 1) path = [1];
      if (step == 2) path = [-1];
    }
    if (scenario == 3 && step == 1) activeChar = 'climber';

    int totalSteps = scenario == 4 ? 2 : 3;
    if (step >= totalSteps) {
      if (scenario == 5) showSuccess = true;
    } else {
      _setupDraggables();
    }
    notifyListeners();
  }

  void reset() {
    showCurtain = true;
    showSuccess = false;
    loadScenario(1);
  }
}

// --- MAIN UI SCREEN ---

class Cl6M_Ch10_A6_RealWorldApplicationsOfIntegers extends StatefulWidget {
  const Cl6M_Ch10_A6_RealWorldApplicationsOfIntegers({super.key});
  @override
  State<Cl6M_Ch10_A6_RealWorldApplicationsOfIntegers> createState() =>
      _MainScreenState();
}

class _MainScreenState
    extends State<Cl6M_Ch10_A6_RealWorldApplicationsOfIntegers>
    with TickerProviderStateMixin {
  final SimState state = SimState();
  late AnimationController _ticker;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;

  final GlobalKey _canvasKey = GlobalKey();

  Offset? _startFocalPoint;
  Offset _startPan = Offset.zero;
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

    _ticker =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(_updateLogic)
          ..forward();
    state.addListener(() {
      if (mounted) setState(() {});
    });
    state.loadScenario(1);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // --- AUDIO METHODS ---
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  // --- GAME LOGIC & RENDERING LOOP ---
  void _updateLogic() {
    if (!state.animating) return;

    double dt = 1 / 60.0;
    bool stillAnimating = false;

    if (state.scenario == 1) {
      if ((state.liftVisualFloor - state.liftFloor).abs() > 0.02) {
        double diff = state.liftFloor - state.liftVisualFloor;
        double stepDelta = diff.sign * 2.0 * dt;
        if ((state.liftFloor - (state.liftVisualFloor + stepDelta)).sign !=
            diff.sign) {
          state.liftVisualFloor = state.liftFloor;
        } else {
          state.liftVisualFloor += stepDelta;
          stillAnimating = true;
        }
      }
    } else if (state.scenario == 2) {
      if ((state.visualBalance - state.balance).abs() > 0.5) {
        double diff = state.balance - state.visualBalance;
        double stepDelta = diff.sign * 150.0 * dt;
        if ((state.balance - (state.visualBalance + stepDelta)).sign !=
            diff.sign) {
          state.visualBalance = state.balance;
        } else {
          state.visualBalance += stepDelta;
          stillAnimating = true;
        }
      }
    } else if (state.scenario == 3) {
      double targetAlt = state.altitude;
      if ((state.altitude - targetAlt).abs() > 0.5) {}
    } else if (state.scenario == 5) {
      if ((state.visualBudget - state.budget).abs() > 0.1) {
        double diff = state.budget - state.visualBudget;
        double stepDelta = diff.sign * 20.0 * dt;
        if ((state.budget - (state.visualBudget + stepDelta)).sign !=
            diff.sign) {
          state.visualBudget = state.budget;
        } else {
          state.visualBudget += stepDelta;
          stillAnimating = true;
        }
      }
    }

    if (!stillAnimating && state.animating) {
      state.animating = false;
      state.showEquation = true;
      playPageOpen(); // Play accomplishment sound when an animation/step finishes correctly
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) state.advanceStep();
      });
    }
  }

  Offset _getWorldPt(Offset localPt, Size size) {
    double x = (localPt.dx - size.width / 2 - state.panX) / state.zoom;
    double y = (localPt.dy - size.height / 2 - state.panY) / state.zoom;
    return Offset(x, y);
  }

  void _onTapDown(TapDownDetails details) {
    if (state.animating) return;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset worldPt = _getWorldPt(details.localPosition, box.size);

    // Keypad Hits
    if (state.keypad.visible && state.keypad.rect != Rect.zero) {
      if (state.keypad.rect.contains(worldPt)) {
        for (var hb in state.keypad.hitboxes) {
          Rect r = Rect.fromLTWH(hb['x'], hb['y'], hb['w'], hb['h']);
          if (r.contains(worldPt)) {
            String valStr = hb['val'];
            if (valStr == 'ACTION') {
              double v = double.tryParse(state.keypad.value) ?? 0;
              _processKeypad(v);
            } else {
              playClick(); // Regular key press
              if (valStr == 'DEL') {
                if (state.keypad.value.isNotEmpty) {
                  state.keypad.value = state.keypad.value.substring(
                    0,
                    state.keypad.value.length - 1,
                  );
                }
              } else if (valStr == '-') {
                if (state.keypad.value.contains('-')) {
                  state.keypad.value = state.keypad.value.replaceAll('-', '');
                } else {
                  state.keypad.value = '-${state.keypad.value}';
                }
              } else {
                state.keypad.value += valStr;
              }
            }
            state.notifyListeners();
            return;
          }
        }
        return;
      }
    } else if (state.btnRect != null) {
      int maxStep = state.scenario == 3 ? 3 : 2;
      if (state.step < maxStep && state.btnRect!.contains(worldPt)) {
        playClick(); // Action button pressed
        state.keypad.visible = true;
        state.keypad.value = '';
        if (state.scenario == 3) {
          state.keypad.targetAction = state.step == 0
              ? "Descend"
              : (state.step == 1 ? "Move" : "Climb");
          state.keypad.expectedVal = state.step == 0
              ? -300
              : (state.step == 1 ? -250 : 750);
        } else {
          state.keypad.targetAction = state.step == 0 ? "Dive" : "Ascend";
          state.keypad.expectedVal = state.step == 0 ? -100 : 110;
        }
        state.notifyListeners();
        return;
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (state.animating) return;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset worldPt = _getWorldPt(details.localFocalPoint, box.size);

    // Prevent panning or dragging if starting on Keypad or Action button
    if (state.keypad.visible &&
        state.keypad.rect != Rect.zero &&
        state.keypad.rect.contains(worldPt))
      return;
    int maxStep = state.scenario == 3 ? 3 : 2;
    if (state.step < maxStep &&
        state.btnRect != null &&
        state.btnRect!.contains(worldPt))
      return;

    bool itemHit = false;

    // Draggable Hits
    for (int i = state.dragItems.length - 1; i >= 0; i--) {
      var item = state.dragItems[i];
      if (!item.dropped) {
        if (sqrt(pow(worldPt.dx - item.x, 2) + pow(worldPt.dy - item.y, 2)) <
            40) {
          state.activeDrag = item.id;
          itemHit = true;
          playClick(); // Item grabbed
          state.notifyListeners();
          return;
        }
      }
    }

    if (!itemHit) {
      _isPanningCanvas = true;
      _startFocalPoint = details.localFocalPoint;
      _startPan = Offset(state.panX, state.panY);
      _startZoom = state.zoom;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (state.activeDrag != null) {
      final RenderBox box =
          _canvasKey.currentContext!.findRenderObject() as RenderBox;
      Offset worldPt = _getWorldPt(details.localFocalPoint, box.size);
      var item = state.dragItems.firstWhere((i) => i.id == state.activeDrag);
      item.x = worldPt.dx;
      item.y = worldPt.dy;
      state.notifyListeners();
      return;
    }

    if (_isPanningCanvas && _startFocalPoint != null) {
      state.panX =
          _startPan.dx + (details.localFocalPoint.dx - _startFocalPoint!.dx);
      state.panY =
          _startPan.dy + (details.localFocalPoint.dy - _startFocalPoint!.dy);
      state.zoom = (_startZoom * details.scale).clamp(0.2, 2.5);
      state.notifyListeners();
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (state.activeDrag != null) {
      var item = state.dragItems.firstWhere((i) => i.id == state.activeDrag);
      if (state.dropZone != null &&
          state.dropZone!.hitTest(Offset(item.x, item.y))) {
        item.dropped = true;
        playClick(); // Drop sound
        _processDrop(item);
      } else {
        item.x = item.hx;
        item.y = item.hy;
        playError(); // Error invalid drop
      }
      state.activeDrag = null;
      state.notifyListeners();
    }
    _isPanningCanvas = false;
  }

  void _processDrop(DragItem item) {
    if (state.scenario == 1) {
      state.liftFloor += item.val;
      state.equation.add(item.val);
      state.path.add(state.liftFloor);
      state.itemsProcessed++;
      state.animating = true;

      int req = state.step == 0 ? 1 : (state.step == 1 ? 2 : 3);
      if (state.itemsProcessed >= req) {
        // Logic handles completion inside _updateLogic
      } else {
        state.animating = false;
      }
    } else if (state.scenario == 2) {
      state.balance += item.val;
      state.animating = true;
    } else if (state.scenario == 5) {
      state.budget += item.val;
      state.itemsProcessed++;
      state.animating = true;

      int req = state.step == 0 ? 2 : (state.step == 1 ? 1 : 4);
      if (state.itemsProcessed < req) {
        state.animating = false;
      }
    }
  }

  void _processKeypad(double val) {
    if (val == state.keypad.expectedVal) {
      state.keypad.visible = false;
      playClick(); // Valid Input Confirmation
      if (state.scenario == 3) {
        if (state.step >= 1) state.activeChar = 'climber';
        _animateS3Alt(state.altitude + val);
      } else if (state.scenario == 4) {
        _animateS4Alt(state.s4Altitude + val);
      }
    } else {
      playError(); // Wrong calculation entered
      state.keypad.value = '';
    }
  }

  void _animateS3Alt(double target) {
    state.animating = true;
    double start = state.altitude;
    int frames = 60;
    int f = 0;
    _ticker.addListener(() {
      if (!state.animating) return;
      f++;
      state.altitude = start + ((target - start) * (f / frames));
      if (f >= frames) {
        state.altitude = target;
        state.animating = false;
        playPageOpen();
        state.showEquation = true;
        Future.delayed(
          const Duration(milliseconds: 2500),
          () => state.advanceStep(),
        );
      }
    });
  }

  void _animateS4Alt(double target) {
    state.animating = true;
    double start = state.s4Altitude;
    int frames = 60;
    int f = 0;
    _ticker.addListener(() {
      if (!state.animating) return;
      f++;
      state.s4Altitude = start + ((target - start) * (f / frames));
      if (f >= frames) {
        state.s4Altitude = target;
        state.animating = false;
        if (state.step == 0) state.packageDelivered = true;
        playPageOpen();
        state.showEquation = true;
        Future.delayed(
          const Duration(milliseconds: 3500),
          () => state.advanceStep(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: ClipRect(
                  child: CustomPaint(
                    key: _canvasKey,
                    painter: LabPainter(state: state),
                    child: Container(),
                  ),
                ),
              ),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.only(
                              top: 64,
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.science,
                                      color: Colors.indigoAccent,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.t('appTitle'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
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
                                  state.t('appSubtitle'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        playClick();
                                        state.toggleLang();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              state.lang.toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: () {
                                        playClick();
                                        state.reset();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.refresh,
                                              size: 16,
                                              color: Colors.redAccent,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Reset",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Scrollable Content Body
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.t('selectScenario').toUpperCase(),
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
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        value: state.scenario,
                                        dropdownColor: const Color(0xFF1E293B),
                                        items: [1, 2, 3, 4, 5]
                                            .map(
                                              (id) => DropdownMenuItem(
                                                value: id,
                                                child: Text(
                                                  state.t('s${id}_title'),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            playDropdown();
                                            state.loadScenario(v);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0F172A,
                                      ).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.track_changes,
                                              color: Colors.pinkAccent,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              state.t('learnLbl'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.yellowAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          state.t('s${state.scenario}_obj'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ...List.generate(
                                    state.scenario == 4 ? 2 : 3,
                                    (i) => _buildStepItem(i),
                                  ),

                                  if ((state.scenario == 4 &&
                                          state.step >= 2) ||
                                      (state.scenario != 4 && state.step >= 3))
                                    if (state.scenario != 5)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.indigoAccent,
                                            minimumSize: const Size(
                                              double.infinity,
                                              50,
                                            ),
                                          ),
                                          onPressed: () {
                                            playClick();
                                            state.loadScenario(
                                              state.scenario + 1,
                                            );
                                          },
                                          icon: const Icon(Icons.arrow_forward),
                                          label: Text(
                                            state.t('nextScenario'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                          // Footer
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            color: Colors.black26,
                            child: const Text(
                              "© ZeroScienceLab - Fall in love with math and Science",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
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

            // Sidebar Drag Handle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: (_sidebarOpen ? _sidebarWidth : 0) - 10,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  if (!_sidebarOpen) return;
                  setState(() {
                    _sidebarWidth += details.delta.dx;
                    if (_sidebarWidth < 350) _sidebarWidth = 350;
                    if (_sidebarWidth > sw * 0.6) _sidebarWidth = sw * 0.6;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // MENU BUTTON
            Positioned(
              left: 8,
              top: 8,
              child: FloatingActionButton(
                mini: true,
                child: Icon(
                  _sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  playClick();
                  setState(() => _sidebarOpen = !_sidebarOpen);
                },
              ),
            ),

            // FLOATING HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              bottom: 30,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity:
                      (state.step < (state.scenario == 4 ? 2 : 3) &&
                          !state.showCurtain &&
                          !state.showSuccess)
                      ? 1.0
                      : 0.0,
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: sw * 0.6,
                      ), // Making the HUD container flexible & preventing overflow
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade900.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(
                          top: BorderSide(color: Colors.indigoAccent, width: 4),
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
                          const Icon(
                            Icons.info_outline,
                            color: Colors.indigoAccent,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            // Wrap text dynamically
                            child: Text(
                              state.t(
                                's${state.scenario}_hud${state.step + 1}',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
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
            ),

            // CURTAIN OVERLAY
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: state.showCurtain ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.science,
                        size: 80,
                        color: Colors.indigoAccent,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        state.t('shutterTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.t('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.indigoAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          curtainScreen();
                          setState(() => state.showCurtain = false);
                        },
                        icon: const Icon(
                          Icons.play_circle_fill,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: Text(
                          state.t('enterLab'),
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

            // SUCCESS POPUP
            if (state.showSuccess)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flag,
                          size: 80,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          state.t('summaryTitle'),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.t('finalDesc'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () {
                            playClick();
                            state.reset();
                          },
                          child: Text(
                            state.t('finishLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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

  Widget _buildStepItem(int i) {
    bool isCompleted = i < state.step;
    bool isActive = i == state.step;
    bool isFuture = i > state.step;

    Color bg = isActive
        ? Colors.indigo.withOpacity(0.2)
        : (isCompleted ? Colors.green.withOpacity(0.1) : Colors.white10);
    Color border = isActive
        ? Colors.indigoAccent
        : (isCompleted ? Colors.green : Colors.transparent);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : (isActive ? Colors.indigoAccent : Colors.white24),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${state.t('stepLabel')} ${i + 1}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state
                      .t('s${state.scenario}_step${i + 1}_task')
                      .replaceAll('Action: ', ''),
                  style: TextStyle(
                    fontSize: 13,
                    color: isFuture ? Colors.white54 : Colors.white,
                  ),
                ),
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.t('s${state.scenario}_step${i + 1}_out'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- CANVAS PAINTER ---

class LabPainter extends CustomPainter {
  final SimState state;
  LabPainter({required this.state}) : super(repaint: state);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 1) {
      _drawBuilding(canvas);
      _drawS1ControlPanel(canvas);
      _drawS1Eq(canvas);
    } else if (state.scenario == 2) {
      _drawBank(canvas);
      _drawS2Eq(canvas);
    } else if (state.scenario == 3) {
      _drawMountain(canvas);
    } else if (state.scenario == 4) {
      _drawOcean(canvas);
    } else if (state.scenario == 5) {
      _drawLemonade(canvas);
    }

    _drawDraggables(canvas);

    if (state.keypad.visible) {
      _drawKeypad(canvas, state.keypad.rect.left, state.keypad.rect.top);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;

  // Helpers
  void _drawPoly(
    Canvas canvas,
    List<Offset> pts,
    Color fill,
    Color stroke, [
    double width = 2,
  ]) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    if (stroke != Colors.transparent) {
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _drawRoundedRect(
    Canvas canvas,
    Rect rect,
    double rad,
    Color fill,
    Color stroke, [
    double width = 2,
  ]) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(rad));
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (stroke != Colors.transparent) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color col,
    double width, {
    bool dashed = false,
  }) {
    if (dashed) {
      final paint = Paint()
        ..color = col
        ..strokeWidth = width;
      double dist = (p2 - p1).distance;
      double dash = 10;
      for (double i = 0; i < dist; i += dash * 2) {
        double e = (i + dash < dist) ? i + dash : dist;
        Offset start = p1 + (p2 - p1) * (i / dist);
        Offset end = p1 + (p2 - p1) * (e / dist);
        canvas.drawLine(start, end, paint);
      }
    } else {
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = col
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pt,
    double size,
    Color col, {
    bool bold = false,
    TextAlign align = TextAlign.center,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: col,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    double dx = pt.dx;
    double dy = pt.dy - tp.height / 2;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, dy));
  }

  // --- S1 BUILDING ---
  void _drawBuilding(Canvas canvas) {
    double dx = -40, dy = -20;
    double rx = -250, rw = 160, bx = rx + rw, sw = 90, fh = 100;

    for (int l = 3; l >= -2; l--) {
      double y = -(l * fh);
      Color backCol = const Color(0xFFE2E8F0),
          leftCol = const Color(0xFFCBD5E1),
          floorCol = const Color(0xFF94A3B8);
      if (l == 2) {
        backCol = const Color(0xFFFEF08A);
        leftCol = const Color(0xFFFEF9C3);
        floorCol = const Color(0xFFFDE047);
      }
      if (l == 1) {
        backCol = const Color(0xFFFFEDD5);
        leftCol = const Color(0xFFFFF7ED);
        floorCol = const Color(0xFFFDBA74);
      }
      if (l == -1) {
        backCol = const Color(0xFFE9D5FF);
        leftCol = const Color(0xFFF3E8FF);
        floorCol = const Color(0xFFD8B4FE);
      }

      _drawPoly(
        canvas,
        [
          Offset(rx + dx, y + dy),
          Offset(bx + dx, y + dy),
          Offset(bx + dx, y - fh + dy),
          Offset(rx + dx, y - fh + dy),
        ],
        backCol,
        const Color(0xFF475569),
      );
      _drawPoly(
        canvas,
        [
          Offset(rx, y),
          Offset(rx + dx, y + dy),
          Offset(rx + dx, y - fh + dy),
          Offset(rx, y - fh),
        ],
        leftCol,
        const Color(0xFF475569),
      );
      _drawPoly(
        canvas,
        [
          Offset(rx, y),
          Offset(bx, y),
          Offset(bx + dx, y + dy),
          Offset(rx + dx, y + dy),
        ],
        floorCol,
        const Color(0xFF475569),
      );

      _drawText(
        canvas,
        l > 0 ? '+$l' : '$l',
        Offset(rx - 20, y - fh / 2),
        18,
        Colors.white,
        bold: true,
        align: TextAlign.right,
      );
    }

    double shaftBot = 2 * fh, shaftTop = -4 * fh;
    _drawPoly(
      canvas,
      [
        Offset(bx + dx, shaftBot + dy),
        Offset(bx + sw + dx, shaftBot + dy),
        Offset(bx + sw + dx, shaftTop + dy),
        Offset(bx + dx, shaftTop + dy),
      ],
      const Color(0xFFF1F5F9),
      const Color(0xFF475569),
    );

    double liftY = -(state.liftVisualFloor * fh);
    double lw = sw - 16, lh = fh - 10, lx = bx + 8, ldrawY = liftY - 5;

    _drawPoly(
      canvas,
      [
        Offset(lx + dx, ldrawY + dy),
        Offset(lx + lw + dx, ldrawY + dy),
        Offset(lx + lw + dx, ldrawY - lh + dy),
        Offset(lx + dx, ldrawY - lh + dy),
      ],
      Colors.white30,
      Colors.lightBlue,
    );
    _drawPoly(
      canvas,
      [
        Offset(lx, ldrawY),
        Offset(lx + lw, ldrawY),
        Offset(lx + lw + dx, ldrawY + dy),
        Offset(lx + dx, ldrawY + dy),
      ],
      const Color(0xFFCBD5E1),
      Colors.lightBlue,
    );

    _drawBela(canvas, lx + lw / 2 + dx / 2, ldrawY + dy / 2 - 50);

    _drawPoly(
      canvas,
      [
        Offset(lx, ldrawY),
        Offset(lx + lw, ldrawY),
        Offset(lx + lw, ldrawY - lh),
        Offset(lx, ldrawY - lh),
      ],
      Colors.white30,
      Colors.lightBlue,
    );
    _drawPoly(
      canvas,
      [
        Offset(lx + lw, ldrawY),
        Offset(lx + lw + dx, ldrawY + dy),
        Offset(lx + lw + dx, ldrawY - lh + dy),
        Offset(lx + lw, ldrawY - lh),
      ],
      Colors.white30,
      Colors.lightBlue,
    );
  }

  void _drawBela(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(0.7);
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-14, 10, 28, 45),
      6,
      Colors.pinkAccent,
      Colors.pink.shade900,
    );
    canvas.drawCircle(
      const Offset(0, -5),
      12,
      Paint()..color = Colors.pink.shade100,
    );
    canvas.restore();
  }

  void _drawS1ControlPanel(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(100, -160, 120, 320),
      10,
      Colors.white,
      Colors.grey,
      3,
    );
    if (state.dropZone != null) {
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(
          state.dropZone!.x,
          state.dropZone!.y,
          state.dropZone!.w,
          state.dropZone!.h,
        ),
        6,
        Colors.blueGrey.shade50,
        Colors.amber,
        3,
      );
      _drawText(
        canvas,
        state.dropZone!.lbl,
        Offset(
          state.dropZone!.x + state.dropZone!.w / 2,
          state.dropZone!.y + state.dropZone!.h / 2,
        ),
        16,
        Colors.black87,
        bold: true,
      );
    }
    if (state.activeDrag != null) {
      var item = state.dragItems.firstWhere((i) => i.id == state.activeDrag);
      if (state.dropZone != null) {
        _drawLine(
          canvas,
          Offset(item.x + 20, item.y),
          Offset(
            state.dropZone!.x + state.dropZone!.w / 2,
            state.dropZone!.y + state.dropZone!.h / 2 - 20,
          ),
          Colors.grey,
          2,
          dashed: true,
        );
      }
    }
  }

  void _drawS1Eq(Canvas canvas) {
    if (state.step > 0 || state.equation.isNotEmpty) {
      String eq = "";
      if (state.step == 0 && state.itemsProcessed == 1) eq = "(0) + (+1) = +1";
      if (state.step == 1 && state.itemsProcessed == 2) eq = "(+1) + (-2) = -1";
      if (state.step == 2 && state.itemsProcessed == 3) eq = "(-1) + (+3) = +2";
      if (eq.isNotEmpty) {
        _drawText(
          canvas,
          eq,
          const Offset(160, 200),
          20,
          Colors.white,
          bold: true,
        );
      }
    }
  }

  // --- S2 BANK ---
  void _drawBank(Canvas canvas) {
    double vx = -300, vy = -150, vw = 300, vh = 280;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(vx, vy, vw, vh),
      20,
      const Color(0xFF64748B),
      const Color(0xFF334155),
      6,
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(vx + 10, vy + 10, vw - 20, vh - 20),
      15,
      const Color(0xFF94A3B8),
      Colors.transparent,
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(vx + 30, vy + 30, vw - 60, vh - 60),
      10,
      const Color(0xFFCBD5E1),
      const Color(0xFF64748B),
      5,
    );
    canvas.drawCircle(
      Offset(vx + vw / 2, vy + vh / 2),
      50,
      Paint()..color = const Color(0xFF475569),
    );

    // Thermometer
    double tx = 150, ty = -250, tw = 40, th = 400;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(tx, ty, tw, th),
      20,
      const Color(0xFFE2E8F0),
      const Color(0xFF94A3B8),
      4,
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(tx + 10, ty + 10, 20, th - 20),
      10,
      const Color(0xFFCBD5E1),
      Colors.transparent,
    );

    double zeroY = ty + 10 + (th - 20) * 0.6;
    double ppu = (th - 20) / 350;
    double currentY = zeroY - (state.visualBalance * ppu);
    Color fill = state.visualBalance >= 0 ? Colors.green : Colors.red;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(tx + 10, currentY, 20, (ty + th) - currentY),
      10,
      fill,
      Colors.transparent,
    );

    for (int val in [100, 0, -100, -200]) {
      double y = zeroY - (val * ppu);
      _drawLine(
        canvas,
        Offset(tx + tw, y),
        Offset(tx + tw + 15, y),
        const Color(0xFF94A3B8),
        4,
      );
      _drawText(
        canvas,
        val > 0 ? '+$val' : '$val',
        Offset(tx + tw + 30, y),
        18,
        val > 0
            ? Colors.greenAccent
            : (val < 0 ? Colors.redAccent : Colors.white),
        bold: true,
        align: TextAlign.left,
      );
    }
  }

  void _drawS2Eq(Canvas canvas) {
    if (!state.showEquation) return;
    String eq = "";
    if (state.step == 0 && state.balance == 100) eq = "(0) + (+100) = +100";
    if (state.step == 1 && state.balance == 70) eq = "(+100) + (-30) = +70";
    if (state.step == 2 && state.balance == -80) eq = "(+70) + (-150) = -80";
    if (eq.isNotEmpty) {
      _drawText(canvas, eq, const Offset(0, 200), 28, Colors.white, bold: true);
    }
  }

  // --- S3 MOUNTAIN ---
  void _drawMountain(Canvas canvas) {
    double ppm = 0.5, sy = 100;
    double mapY(double alt) => sy - (alt * ppm);

    canvas.drawRect(
      const Rect.fromLTWH(-1000, -1000, 2000, 1100),
      Paint()..color = const Color(0xFF0EA5E9),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-1000, 100, 2000, 500),
      Paint()..color = const Color(0xFF082F49),
    );
    _drawLine(
      canvas,
      const Offset(-1000, 100),
      const Offset(1000, 100),
      Colors.white,
      4,
      dashed: true,
    );

    _drawPoly(
      canvas,
      [
        Offset(1000, sy + 500),
        Offset(350, mapY(700)),
        Offset(50, mapY(-50)),
        Offset(-50, mapY(200)),
        Offset(-400, mapY(-50)),
        Offset(-1000, sy + 500),
      ],
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      4,
    );

    // Altitude meter
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(-350, mapY(700), 20, mapY(-50) - mapY(700)),
      10,
      const Color(0xFFF1F5F9),
      const Color(0xFF475569),
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(
        -350,
        mapY(state.altitude),
        20,
        mapY(-50) - mapY(state.altitude),
      ),
      10,
      Colors.blue,
      Colors.blue.shade900,
    );

    for (double v in [700, 500, 200, 0, -50]) {
      _drawLine(
        canvas,
        Offset(-360, mapY(v)),
        Offset(-350, mapY(v)),
        Colors.white,
        2,
      );
      _drawText(
        canvas,
        v > 0 ? '+${v.toInt()}m' : '${v.toInt()}m',
        Offset(-370, mapY(v)),
        16,
        Colors.white,
        bold: true,
        align: TextAlign.right,
      );
    }

    double currY = mapY(state.altitude);
    if (state.activeChar == 'heli') {
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(-140, currY - 15, 80, 30),
        15,
        Colors.orange,
        Colors.deepOrange,
        3,
      );
    } else {
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(0, currY - 15, 20, 25),
        5,
        Colors.blue,
        Colors.indigo,
        2,
      );
    }

    // Button
    if (!state.keypad.visible && !state.animating && state.step < 3) {
      state.btnRect = Rect.fromLTWH(100, sy - 150, 120, 50);
      _drawRoundedRect(
        canvas,
        state.btnRect!,
        8,
        const Color(0xFFCBD5E1),
        const Color(0xFF475569),
        3,
      );
      String lbl = state.step == 0
          ? "Descend"
          : (state.step == 1 ? "Move" : "Climb");
      _drawText(
        canvas,
        lbl,
        Offset(160, sy - 125),
        18,
        Colors.black87,
        bold: true,
      );
    } else if (state.keypad.visible) {
      state.keypad.rect = Rect.fromLTWH(
        100,
        sy - 410,
        180,
        320,
      ); // Track position for hit testing
    }

    if (state.showEquation) {
      String eq = "";
      if (state.step == 1) eq = "(+500) + (-300) = +200";
      if (state.step == 2) eq = "(+200) + (-250) = -50";
      if (state.step == 3) eq = "(-50) + (+750) = +700";
      if (eq.isNotEmpty) {
        _drawText(
          canvas,
          eq,
          Offset(50, sy + 150),
          28,
          Colors.white,
          bold: true,
        );
      }
    }
  }

  // --- S4 OCEAN ---
  void _drawOcean(Canvas canvas) {
    double ppm = 3, sy = 0;
    double mapY(double alt) => sy - (alt * ppm);

    canvas.drawRect(
      const Rect.fromLTWH(-1000, -1000, 2000, 1000),
      Paint()..color = const Color(0xFF0EA5E9),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-1000, 0, 2000, 1000),
      Paint()..color = const Color(0xFF082F49),
    );
    _drawLine(
      canvas,
      const Offset(-1000, 0),
      const Offset(1000, 0),
      Colors.white,
      4,
      dashed: true,
    );

    // Altitude meter
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(-300, mapY(20), 20, mapY(-100) - mapY(20)),
      10,
      const Color(0xFFF1F5F9),
      const Color(0xFF475569),
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(
        -300,
        mapY(state.s4Altitude),
        20,
        mapY(-100) - mapY(state.s4Altitude),
      ),
      10,
      Colors.blue,
      Colors.blue.shade900,
    );

    for (double v in [20, 10, 0, -50, -90, -100]) {
      _drawLine(
        canvas,
        Offset(-310, mapY(v)),
        Offset(-300, mapY(v)),
        Colors.white,
        2,
      );
      _drawText(
        canvas,
        v > 0 ? '+${v.toInt()}m' : '${v.toInt()}m',
        Offset(-320, mapY(v)),
        16,
        Colors.white,
        bold: true,
        align: TextAlign.right,
      );
    }

    double subX = state.step == 1 && !state.animating ? 150 : -50;
    if (state.animating && state.step == 0) {
      subX = -50 + ((state.s4Altitude - 10) / -100) * 200;
    }

    // Submarine shape
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(subX - 40, mapY(state.s4Altitude) - 15, 80, 30),
      15,
      Colors.indigoAccent,
      Colors.indigo.shade900,
      3,
    );

    if (state.step == 0 || (!state.packageDelivered && state.step == 1)) {
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(130, mapY(-90) - 10, 40, 20),
        2,
        Colors.amber.shade900,
        Colors.brown.shade900,
      );
    }

    if (!state.keypad.visible && !state.animating && state.step < 2) {
      state.btnRect = Rect.fromLTWH(-120, sy + 50, 120, 50);
      _drawRoundedRect(
        canvas,
        state.btnRect!,
        8,
        const Color(0xFFCBD5E1),
        const Color(0xFF475569),
        3,
      );
      String lbl = state.step == 0 ? "Dive" : "Ascend";
      _drawText(
        canvas,
        lbl,
        Offset(-60, sy + 75),
        18,
        Colors.black87,
        bold: true,
      );
    } else if (state.keypad.visible) {
      state.keypad.rect = Rect.fromLTWH(-120, sy + 50, 180, 320);
    }

    if (state.showEquation) {
      String eq = "";
      if (state.step == 1 && state.s4Altitude == -90) {
        eq = "(+10) + (-100) = -90";
      }
      if (state.step == 2 && state.s4Altitude == 20) {
        eq = "(-90) + (+110) = +20";
      }
      if (eq.isNotEmpty) {
        _drawText(
          canvas,
          eq,
          const Offset(-200, 250),
          24,
          Colors.white,
          bold: true,
        );
      }
    }
  }

  // --- S5 LEMONADE ---
  void _drawLemonade(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-1000, -1000, 2000, 2000),
      Paint()..color = const Color(0xFFBAE6FD),
    );
    canvas.drawOval(
      const Rect.fromLTWH(-800, 100, 1600, 400),
      Paint()..color = Colors.green,
    );

    // Stand
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-150, 150, 300, 100),
      0,
      Colors.brown.shade300,
      Colors.brown.shade900,
      4,
    );
    _drawLine(
      canvas,
      const Offset(-130, 150),
      const Offset(-130, -50),
      Colors.brown.shade900,
      8,
    );
    _drawLine(
      canvas,
      const Offset(130, 150),
      const Offset(130, -50),
      Colors.brown.shade900,
      8,
    );

    // Budget bar
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-300, -200, 600, 40),
      20,
      Colors.white,
      Colors.grey,
      4,
    );
    double fillW = max(0, min(1, state.visualBudget / 50)) * 600;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(-295, -195, fillW - 10, 30),
      15,
      Colors.green,
      Colors.transparent,
    );
    _drawText(
      canvas,
      "BUDGET",
      const Offset(-250, -180),
      18,
      Colors.black87,
      bold: true,
    );
    _drawText(
      canvas,
      "+\$${state.visualBudget.toInt()}",
      const Offset(340, -180),
      24,
      Colors.green,
      bold: true,
    );

    if (state.showEquation) {
      String eq = "";
      if (state.step == 1) eq = "(+20) + (-8) + (-5) = +7";
      if (state.step == 2) eq = "(+7) + (+15) = +22";
      if (state.step == 3) eq = "(+22) + (-6) + (+25) + (-10) + (+5) = +36";
      if (eq.isNotEmpty) {
        _drawText(
          canvas,
          eq,
          const Offset(0, -100),
          24,
          Colors.black87,
          bold: true,
        );
      }
    }
  }

  // --- ICONS & DRAGGABLES ---
  void _drawDraggables(Canvas canvas) {
    if (state.dropZone != null && state.scenario == 5) {
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(
          state.dropZone!.x,
          state.dropZone!.y,
          state.dropZone!.w,
          state.dropZone!.h,
        ),
        10,
        Colors.amber.withOpacity(0.2),
        Colors.amber,
        2,
      );
      _drawText(
        canvas,
        "Drop Zone",
        Offset(
          state.dropZone!.x + state.dropZone!.w / 2,
          state.dropZone!.y + state.dropZone!.h / 2,
        ),
        16,
        Colors.brown.shade700,
        bold: true,
      );
    }

    for (var item in state.dragItems) {
      if (!item.dropped) {
        canvas.save();
        canvas.translate(item.x, item.y);
        if (state.activeDrag == item.id) canvas.scale(1.2);

        if (item.type == 'plus') {
          _drawRoundedRect(
            canvas,
            const Rect.fromLTWH(-20, -20, 40, 40),
            6,
            Colors.white,
            Colors.indigoAccent,
          );
          _drawLine(
            canvas,
            const Offset(-10, 0),
            const Offset(10, 0),
            Colors.indigoAccent,
            4,
          );
          _drawLine(
            canvas,
            const Offset(0, -10),
            const Offset(0, 10),
            Colors.indigoAccent,
            4,
          );
        } else if (item.type == 'minus') {
          _drawRoundedRect(
            canvas,
            const Rect.fromLTWH(-20, -20, 40, 40),
            6,
            Colors.white,
            Colors.indigoAccent,
          );
          _drawLine(
            canvas,
            const Offset(-10, 0),
            const Offset(10, 0),
            Colors.indigoAccent,
            4,
          );
        } else if (item.type == 'moneybag_green') {
          canvas.drawCircle(Offset.zero, 20, Paint()..color = Colors.green);
          _drawText(
            canvas,
            "+\u20B9100",
            Offset.zero,
            12,
            Colors.white,
            bold: true,
          );
        } else if (item.type == 'bill_red_30') {
          _drawRoundedRect(
            canvas,
            const Rect.fromLTWH(-30, -20, 60, 40),
            4,
            Colors.red,
            Colors.red.shade900,
            3,
          );
          _drawText(
            canvas,
            "-\u20B930",
            Offset.zero,
            14,
            Colors.white,
            bold: true,
          );
        } else if (item.type == 'bill_red_150') {
          _drawRoundedRect(
            canvas,
            const Rect.fromLTWH(-40, -25, 80, 50),
            4,
            Colors.red,
            Colors.red.shade900,
            3,
          );
          _drawText(
            canvas,
            "-\u20B9150",
            Offset.zero,
            18,
            Colors.white,
            bold: true,
          );
        } else if (item.type == 'lemon') {
          canvas.drawCircle(Offset.zero, 20, Paint()..color = Colors.yellow);
        } else if (item.type == 'cups') {
          _drawRoundedRect(
            canvas,
            const Rect.fromLTWH(-15, -20, 30, 40),
            4,
            Colors.white,
            Colors.grey,
          );
        } else if (item.type == 'moneybag_lemonade') {
          canvas.drawCircle(Offset.zero, 20, Paint()..color = Colors.orange);
          _drawText(canvas, "\$", Offset.zero, 16, Colors.white, bold: true);
        } else {
          _drawRoundedRect(
            canvas,
            const Rect.fromLTWH(-20, -20, 40, 40),
            4,
            Colors.blueGrey,
            Colors.white,
          );
        }

        if (item.lbl.isNotEmpty) {
          _drawRoundedRect(
            canvas,
            const Rect.fromLTWH(-20, 25, 40, 20),
            4,
            Colors.white,
            Colors.grey,
            2,
          );
          _drawText(
            canvas,
            item.lbl,
            const Offset(0, 35),
            14,
            Colors.black87,
            bold: true,
          );
        }
        canvas.restore();
      }
    }
  }

  void _drawKeypad(Canvas canvas, double kx, double ky) {
    double kw = 180, kh = 320;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(kx, ky, kw, kh),
      10,
      const Color(0xFFF1F5F9),
      const Color(0xFF94A3B8),
      3,
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(kx + 15, ky + 15, kw - 30, 45),
      5,
      Colors.white,
      const Color(0xFFCBD5E1),
      2,
    );
    _drawText(
      canvas,
      state.keypad.value.isEmpty ? '0' : state.keypad.value,
      Offset(kx + kw - 25, ky + 37.5),
      22,
      Colors.black87,
      bold: true,
      align: TextAlign.right,
    );

    double btnW = 40, btnH = 40, gap = 10;
    double startX = kx + 15, startY = ky + 75;
    List<List<String>> layout = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['-', '0', 'DEL'],
    ];

    state.keypad.hitboxes.clear();
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 3; c++) {
        double bx = startX + c * (btnW + gap);
        double by = startY + r * (btnH + gap);
        _drawRoundedRect(
          canvas,
          Rect.fromLTWH(bx, by, btnW, btnH),
          5,
          const Color(0xFFE2E8F0),
          const Color(0xFFCBD5E1),
          2,
        );
        _drawText(
          canvas,
          layout[r][c],
          Offset(bx + btnW / 2, by + btnH / 2),
          18,
          Colors.black87,
          bold: true,
        );
        state.keypad.hitboxes.add({
          'val': layout[r][c],
          'x': bx,
          'y': by,
          'w': btnW,
          'h': btnH,
        });
      }
    }

    double actionY = ky + kh - 50;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(kx + 15, actionY, kw - 30, 35),
      5,
      Colors.blue,
      Colors.blue.shade900,
      2,
    );
    _drawText(
      canvas,
      state.keypad.targetAction,
      Offset(kx + kw / 2, actionY + 17.5),
      16,
      Colors.white,
      bold: true,
    );
    state.keypad.hitboxes.add({
      'val': 'ACTION',
      'x': kx + 15,
      'y': actionY,
      'w': kw - 30,
      'h': 35,
    });
  }
}
