// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: use_super_parameters, camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Cl6M_Ch8_A4_AdvancedGeometricConstructions());
}

// --- CONSTANTS & THEMES ---
const Color zslDark = Color(0xFF0F172A);
const Color zslSidebar = Color(0xFF1E293B);
const Color zslIndigo = Color(0xFF6366F1);
const Color zslEmerald = Color(0xFF10B981);
const Color zslRose = Color(0xFFF43F5E);
const Color zslAmber = Color(0xFFF59E0B);
const Color zslFaint = Color(0x666366F1);
const double u = 40.0; // cm to px conversion

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': 'Advanced Rectangle Constructions',
    'appSubtitle': 'Class 6 • GEOMETRY CONSTRUCTIONS',
    'enterLab': 'Enter Virtual Lab',
    'missionObj': 'Mission Objective:',
    'nextChallenge': 'Next Challenge',
    'finishLab': 'Finish Lab',
    'successTitle': 'Challenge Mastered!',
    'finalDesc':
        'You have mastered the geometric principles of constructing rectangles and squares using precision tools!',
    'verify': 'Verify Shape',
    'verifiedMsg': 'Perfect! All angles are 90° and opposite sides are equal.',
    'selectScenario': 'Select Scenario',
    'step': 'STEP',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
    'ruler': 'Ruler',
    'protractor': 'Protractor',
    'compass': 'Compass',
    'pencil': 'Pencil',

    's1_title': "1. The Diagonal's Secret",
    's1_obj':
        "Construct a rectangle given the length of one side (5 cm) and the length of its diagonal (7 cm).",
    's1_step1_task':
        "Select the Ruler from the toolbox. Drag the glowing pencil handle to draw a 5cm horizontal line segment DC.",
    's1_step1_out': "Base line DC (5 cm) is drawn.",
    's1_step2_task':
        "Select the Protractor. Click the target point C to place it. Then click the 90° mark to draw a perpendicular line.",
    's1_step2_out': "Perpendicular line drawn at C.",
    's1_step3_task':
        "Select the Compass. Drag the compass pencil to the 7cm mark on the ruler to set its radius.",
    's1_step3_out': "Compass radius set to 7 cm (diagonal length).",
    's1_step4_task':
        "Click the target point D to place the compass. Drag the compass pencil across the vertical line to draw an arc. This finds point B.",
    's1_step4_out': "Intersection point B found 7 cm away from D.",
    's1_step5_task':
        "Select the Ruler. Click point B to auto-construct the remaining 90° perpendiculars and complete the rectangle.",
    's1_step5_out': "Rectangle ABCD is complete.",
    's1_step6_task': "Click the Verify Shape button on the canvas.",
    's1_step6_out':
        "Properties verified: Opposite sides are equal, second diagonal is 7cm.",

    's2_title': "2. The Angle Divider",
    's2_obj':
        "Construct a rectangle where a diagonal divides a corner angle into 60° and 30°.",
    's2_step1_task':
        "Select the Ruler. Drag the pencil handle to draw a base line AB (8 cm).",
    's2_step1_out': "Base line AB drawn.",
    's2_step2_task':
        "Select the Protractor. Click target point A to place it. Click the 90° mark.",
    's2_step2_out': "90° perpendicular drawn at A for the side.",
    's2_step3_task': "With the Protractor still at A, click the 60° mark.",
    's2_step3_out': "60° line drawn from A for the diagonal.",
    's2_step4_task':
        "Select the Protractor. Click target point B. Click the 90° mark to draw a perpendicular that intersects the diagonal, finding point C.",
    's2_step4_out': "Intersection point C found.",
    's2_step5_task':
        "Select the Compass. Click point A. It will automatically measure BC and mark point D to complete the rectangle.",
    's2_step5_out': "Rectangle ABCD completed using parallel properties.",

    's3_title': "3. The Equidistant Peak",
    's3_obj':
        "Find a unique point 'A' that is exactly 5 cm away from two base points 'B' and 'C'.",
    's3_step1_task': "Select the Ruler. Drag to draw a base line BC (5 cm).",
    's3_step1_out': "Base line BC drawn.",
    's3_step2_task':
        "Select the Compass. Drag its pencil to the 5cm mark on the ruler.",
    's3_step2_out': "Compass set to 5 cm.",
    's3_step3_task':
        "Click point B to place the compass. Drag the handle to draw an arc.",
    's3_step3_out': "Arc drawn from B. Every point on it is 5 cm from B.",
    's3_step4_task':
        "Click point C to place the compass. Drag the handle to draw an intersecting arc.",
    's3_step4_out': "Intersection point A found exactly 5cm from both B and C.",
    's3_step5_task':
        "Select the Pencil. Click the intersection point A to connect the triangle.",
    's3_step5_out': "Equilateral triangle ABC is formed.",

    's4_title': "4. The Tilted Square",
    's4_obj': "Construct a perfect square on the given tilted line segment PQ.",
    's4_step1_task':
        "Select the Protractor. Click point P, then click 90° to draw a perpendicular line.",
    's4_step1_out': "Perpendicular drawn at P.",
    's4_step2_task':
        "Select the Protractor. Click point Q, then click -90° to draw a perpendicular line.",
    's4_step2_out': "Perpendicular drawn at Q.",
    's4_step3_task':
        "Select the Compass. Click point P to measure PQ, then draw an arc on P's line to find S.",
    's4_step3_out': "Point S marked at distance PQ.",
    's4_step4_task': "Click point Q to draw an arc on Q's line to find R.",
    's4_step4_out': "Point R marked at distance PQ.",
    's4_step5_task':
        "Select the Pencil. Click S and R to connect them and finish the square.",
    's4_step5_out': "Tilted Square PQRS constructed.",

    's5_title': "5. The Centered Square",
    's5_obj':
        "Construct a square perfectly centered inside the given 8 cm x 4 cm rectangle.",
    's5_step1_task':
        "Select the Ruler. Drag the glowing pencil from A to C, then B to D to draw the diagonals.",
    's5_step1_out': "Diagonals intersect at the exact Center O.",
    's5_step2_task':
        "Select the Protractor. Click center O, then mark 90° then 0° to draw axes.",
    's5_step2_out': "Axes drawn through the center.",
    's5_step3_task':
        "Select the Compass. Place at center O. Set radius to 1.5cm on the ruler and drag the compass to draw a circle.",
    's5_step3_out': "4 equidistant vertices marked around center.",
    's5_step4_task':
        "Select the Pencil. Drag to connect the 4 new points in order to draw the square.",
    's5_step4_out': "Perfectly centered square constructed.",
  },
  'hi': {
    'appTitle': 'आयत की उन्नत रचनाएँ',
    'appSubtitle': 'कक्षा 6 • ज्यामिति रचनाएँ',
    'enterLab': 'सिमुलेशन दर्ज करें',
    'missionObj': 'मिशन का उद्देश्य:',
    'nextChallenge': 'अगली चुनौती',
    'finishLab': 'समाप्त करें',
    'successTitle': 'चुनौती पूर्ण!',
    'finalDesc':
        'आपने सटीक उपकरणों का उपयोग करके आयत और वर्ग बनाने के ज्यामितीय सिद्धांतों में महारत हासिल कर ली है!',
    'verify': 'आकार सत्यापित करें',
    'verifiedMsg': 'बिल्कुल सही! सभी कोण 90° हैं और विपरीत भुजाएँ समान हैं।',
    'selectScenario': 'रचना चुनें',
    'step': 'चरण',
    'footer': '© ZeroScienceLab - गणित और विज्ञान से प्यार करें',
    'ruler': 'रूलर',
    'protractor': 'चांदा',
    'compass': 'प्रकार',
    'pencil': 'पेंसिल',

    's1_title': "1. विकर्ण का रहस्य",
    's1_obj':
        "एक भुजा (5 सेमी) और उसके विकर्ण (7 सेमी) की लंबाई दिए जाने पर एक आयत बनाएँ।",
    's1_step1_task':
        "टूलबॉक्स से रूलर चुनें। 5cm की रेखा DC खींचने के लिए पेंसिल को खींचें।",
    's1_step1_out': "आधार रेखा DC (5 सेमी) खींची गई।",
    's1_step2_task':
        "चांदा चुनें। इसे रखने के लिए बिंदु C पर क्लिक करें। फिर लंब खींचने के लिए 90° चिह्न पर क्लिक करें।",
    's1_step2_out': "C पर लंब रेखा खींची गई।",
    's1_step3_task':
        "प्रकार चुनें। इसकी त्रिज्या सेट करने के लिए प्रकार की पेंसिल को रूलर पर 7 सेमी चिह्न तक खींचें।",
    's1_step3_out': "प्रकार की त्रिज्या 7 सेमी सेट की गई।",
    's1_step4_task':
        "प्रकार रखने के लिए बिंदु D पर क्लिक करें। चाप खींचने के लिए घुमाएँ। इससे बिंदु B मिलता है।",
    's1_step4_out': "D से 7 सेमी दूर प्रतिच्छेदन बिंदु B मिला।",
    's1_step5_task':
        "रूलर चुनें। शेष 90° लंबों को स्वतः बनाने और आयत को पूरा करने के लिए बिंदु B पर क्लिक करें।",
    's1_step5_out': "आयत ABCD पूरा हुआ।",
    's1_step6_task': "कैनवास पर सत्यापित करें बटन पर क्लिक करें।",
    's1_step6_out': "विपरीत भुजाएँ समान हैं, दूसरा विकर्ण 7 सेमी है।",

    's2_title': "2. कोण विभाजक",
    's2_obj':
        "एक आयत बनाएँ जहाँ एक विकर्ण कोने के कोण को 60° और 30° में विभाजित करता है।",
    's2_step1_task':
        "रूलर चुनें। आधार रेखा AB (8 सेमी) खींचने के लिए हैंडल को खींचें।",
    's2_step1_out': "आधार रेखा AB खींची गई।",
    's2_step2_task':
        "चांदा चुनें। बिंदु A पर क्लिक करें और 90° चिह्न पर क्लिक करें।",
    's2_step2_out': "भुजा के लिए A पर 90° लंब खींचा गया।",
    's2_step3_task': "चांदा अभी भी A पर होने पर, 60° चिह्न पर क्लिक करें।",
    's2_step3_out': "विकर्ण के लिए A से 60° रेखा खींची गई।",
    's2_step4_task':
        "चांदा चुनें। लक्ष्य बिंदु B पर क्लिक करें। लंब खींचने के लिए 90° चिह्न पर क्लिक करें, बिंदु C खोजें।",
    's2_step4_out': "प्रतिच्छेदन बिंदु C मिला।",
    's2_step5_task':
        "प्रकार चुनें। बिंदु A पर क्लिक करें। यह स्वचालित रूप से BC को मापेगा और D को चिह्नित करेगा।",
    's2_step5_out': "समानांतर गुणों का उपयोग करके आयत पूर्ण।",

    's3_title': "3. समान दूरी वाला शिखर",
    's3_obj':
        "एक अद्वितीय बिंदु 'A' खोजें जो 'B' और 'C' दोनों से ठीक 5 सेमी दूर हो।",
    's3_step1_task': "रूलर चुनें। आधार रेखा BC (5 सेमी) खींचें।",
    's3_step1_out': "आधार रेखा BC खींची गई।",
    's3_step2_task': "प्रकार चुनें। इसे रूलर पर 5 सेमी के चिह्न तक खींचें।",
    's3_step2_out': "प्रकार 5 सेमी पर सेट।",
    's3_step3_task':
        "प्रकार रखने के लिए बिंदु B पर क्लिक करें। चाप खींचने के लिए हैंडल खींचें।",
    's3_step3_out': "B से चाप खींचा गया।",
    's3_step4_task':
        "प्रकार रखने के लिए बिंदु C पर क्लिक करें। एक प्रतिच्छेदी चाप खींचें।",
    's3_step4_out': "प्रतिच्छेदन बिंदु A मिला।",
    's3_step5_task':
        "पेंसिल चुनें। त्रिभुज को जोड़ने के लिए प्रतिच्छेदन बिंदु A पर क्लिक करें।",
    's3_step5_out': "समबाहु त्रिभुज ABC बन गया।",

    's4_title': "4. झुका हुआ वर्ग",
    's4_obj': "दिए गए झुके हुए रेखाखंड PQ पर एक पूर्ण वर्ग बनाएँ।",
    's4_step1_task':
        "चांदा चुनें। बिंदु P पर क्लिक करें, फिर 90° पर क्लिक करें।",
    's4_step1_out': "P पर लंब खींचा गया।",
    's4_step2_task':
        "चांदा चुनें। बिंदु Q पर क्लिक करें, फिर -90° पर क्लिक करें।",
    's4_step2_out': "Q पर लंब खींचा गया।",
    's4_step3_task':
        "प्रकार चुनें। PQ मापने के लिए P पर क्लिक करें, फिर S खोजने के लिए P की रेखा पर चाप खींचें।",
    's4_step3_out': "बिंदु S चिह्नित किया गया।",
    's4_step4_task':
        "R खोजने के लिए Q की रेखा पर चाप खींचने के लिए बिंदु Q पर क्लिक करें।",
    's4_step4_out': "बिंदु R चिह्नित किया गया।",
    's4_step5_task':
        "पेंसिल चुनें। उन्हें जोड़ने और वर्ग समाप्त करने के लिए S और R पर क्लिक करें।",
    's4_step5_out': "झुका हुआ वर्ग PQRS बन गया।",

    's5_title': "5. केंद्रित वर्ग",
    's5_obj': "दिए गए 8x4 सेमी आयत के अंदर पूरी तरह से केंद्रित एक वर्ग बनाएँ।",
    's5_step1_task':
        "रूलर चुनें। विकर्ण खींचने के लिए A से C, फिर B से D तक पेंसिल को खींचें।",
    's5_step1_out': "विकर्ण केंद्र O पर प्रतिच्छेद करते हैं।",
    's5_step2_task':
        "चांदा चुनें। केंद्र O पर क्लिक करें, फिर अक्ष खींचने के लिए 90° और 0° चिह्नित करें।",
    's5_step2_out': "केंद्र से होकर अक्ष खींचे गए।",
    's5_step3_task':
        "प्रकार चुनें। O पर क्लिक करें। रूलर पर 1.5 सेमी त्रिज्या सेट करें और वृत्त खींचने के लिए खींचें।",
    's5_step3_out': "4 शीर्ष चिह्नित किए गए।",
    's5_step4_task':
        "पेंसिल चुनें। वर्ग बनाने के लिए 4 नए बिंदुओं को खींचकर जोड़ें।",
    's5_step4_out': "वर्ग पूर्ण हुआ।",
  },
};

// --- DATA MODELS ---
class Hotspot {
  final String id;
  final String
  type; // 'tool_select', 'drag_line', 'drag_width', 'drag_arc', 'place', 'click'
  final double x;
  final double y;
  final double r;
  final String? tool;
  final double? targetX;
  final double? targetY;
  final double? baseX;
  final bool isScreenSpace;

  Hotspot({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.r,
    this.tool,
    this.targetX,
    this.targetY,
    this.baseX,
    this.isScreenSpace = false,
  });
}

class SimState extends ChangeNotifier {
  // Audio callbacks injected by the widget
  VoidCallback? playClick;
  VoidCallback? playPageOpen;
  VoidCallback? playDropdown;
  VoidCallback? playError;
  VoidCallback? playSuccess;

  String lang = 'en';
  bool showCurtain = true;
  bool sidebarOpen = true;
  double sidebarWidth = 300.0;

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  int scenario = 1;
  int step = 0;
  String? activeTool;

  // Interaction
  String? activeDragEntity;
  double dragX = 0.0;
  double dragY = 0.0;
  List<Hotspot> currentHotspots = [];

  // Scenarios State
  bool s1drawnBase = false,
      s1protractorPlaced = false,
      s1drawnPerp = false,
      s1compassPlaced = false,
      s1compassSet = false,
      s1compassAtD = false,
      s1drawnArc = false,
      s1complete = false,
      s1verified = false;
  double s1compWidth = u;

  bool s2drawnBase = false,
      s2drawnPerpA = false,
      s2drawnDiag = false,
      s2drawnPerpB = false,
      s2complete = false,
      s2verified = false;
  String s2protAt = '';

  bool s3drawnBase = false,
      s3compassPlaced = false,
      s3compassSet = false,
      s3compassAtB = false,
      s3compassAtC = false,
      s3arcB = false,
      s3arcC = false,
      s3complete = false,
      s3verified = false;
  double s3compWidth = u;

  bool s4perpP = false,
      s4perpQ = false,
      s4compassAtP = false,
      s4arcP = false,
      s4compassAtQ = false,
      s4arcQ = false,
      s4complete = false,
      s4verified = false;

  bool s5diag1 = false,
      s5diag2 = false,
      s5protPlaced = false,
      s5axisV = false,
      s5axisH = false,
      s5compPlaced = false,
      s5compSet = false,
      s5marks = false,
      s5complete = false,
      s5verified = false;
  int s5lines = 0;
  double s5compWidth = u;

  String t(String key) => translations[lang]?[key] ?? key;

  void forceUpdate() {
    notifyListeners();
  }

  void toggleLanguage() {
    lang = lang == 'en' ? 'hi' : 'en';
    playClick?.call();
    notifyListeners();
  }

  void loadScenario(int sc) {
    playDropdown?.call();
    scenario = sc;
    step = 0;
    activeTool = null;
    zoom = 1.0;
    panX = 0.0;
    panY = 0.0;

    // Reset all
    s1drawnBase = false;
    s1protractorPlaced = false;
    s1drawnPerp = false;
    s1compassPlaced = false;
    s1compassSet = false;
    s1compassAtD = false;
    s1drawnArc = false;
    s1complete = false;
    s1verified = false;
    s1compWidth = u;
    s2drawnBase = false;
    s2drawnPerpA = false;
    s2drawnDiag = false;
    s2drawnPerpB = false;
    s2complete = false;
    s2verified = false;
    s2protAt = '';
    s3drawnBase = false;
    s3compassPlaced = false;
    s3compassSet = false;
    s3compassAtB = false;
    s3compassAtC = false;
    s3arcB = false;
    s3arcC = false;
    s3complete = false;
    s3verified = false;
    s3compWidth = u;
    s4perpP = false;
    s4perpQ = false;
    s4compassAtP = false;
    s4arcP = false;
    s4compassAtQ = false;
    s4arcQ = false;
    s4complete = false;
    s4verified = false;
    s5diag1 = false;
    s5diag2 = false;
    s5protPlaced = false;
    s5axisV = false;
    s5axisH = false;
    s5compPlaced = false;
    s5compSet = false;
    s5marks = false;
    s5complete = false;
    s5verified = false;
    s5lines = 0;
    s5compWidth = u;

    notifyListeners();
  }

  void advanceStep() {
    step++;
    notifyListeners();
  }

  void verifyCurrent() {
    if (scenario == 1) s1verified = true;
    if (scenario == 2) s2verified = true;
    if (scenario == 3) s3verified = true;
    if (scenario == 4) s4verified = true;
    if (scenario == 5) s5verified = true;
    playSuccess?.call();
    advanceStep();
  }

  bool isScenarioComplete() {
    if (scenario == 1) return s1verified;
    if (scenario == 2) return s2verified;
    if (scenario == 3) return s3verified;
    if (scenario == 4) return s4verified;
    if (scenario == 5) return s5verified;
    return false;
  }

  void executeAction(Hotspot h) {
    int initialStep = step;
    playClick?.call(); // Play a tick/click on any successful action

    if (scenario == 1) {
      if (h.id == 's1_base') {
        s1drawnBase = true;
        advanceStep();
      }
      if (h.id == 's1_prot_c') {
        s1protractorPlaced = true;
      }
      if (h.id == 's1_mark_90') {
        s1drawnPerp = true;
        s1protractorPlaced = false;
        advanceStep();
      }
      if (h.id == 's1_comp_0') {
        s1compassPlaced = true;
      }
      if (h.id == 's1_comp_7') {
        s1compassSet = true;
        s1compassPlaced = false;
        advanceStep();
      }
      if (h.id == 's1_comp_d') {
        s1compassAtD = true;
      }
      if (h.id == 's1_draw_arc') {
        s1drawnArc = true;
        s1compassAtD = false;
        advanceStep();
      }
      if (h.id == 's1_complete') {
        s1complete = true;
        advanceStep();
      }
    } else if (scenario == 2) {
      if (h.id == 's2_base') {
        s2drawnBase = true;
        advanceStep();
      }
      if (h.id == 's2_prot_a') {
        s2protAt = 'A';
      }
      if (h.id == 's2_mark_90') {
        s2drawnPerpA = true;
        advanceStep();
      }
      if (h.id == 's2_mark_60') {
        s2drawnDiag = true;
        s2protAt = '';
        advanceStep();
      }
      if (h.id == 's2_prot_b') {
        s2protAt = 'B';
      }
      if (h.id == 's2_mark_90_b') {
        s2drawnPerpB = true;
        s2protAt = '';
        advanceStep();
      }
      if (h.id == 's2_comp_a') {
        s2complete = true;
        advanceStep();
      }
    } else if (scenario == 3) {
      if (h.id == 's3_base') {
        s3drawnBase = true;
        advanceStep();
      }
      if (h.id == 's3_comp_0') {
        s3compassPlaced = true;
      }
      if (h.id == 's3_comp_5') {
        s3compassSet = true;
        s3compassPlaced = false;
        advanceStep();
      }
      if (h.id == 's3_comp_b') {
        s3compassAtB = true;
      }
      if (h.id == 's3_draw_arc_b') {
        s3arcB = true;
        s3compassAtB = false;
        advanceStep();
      }
      if (h.id == 's3_comp_c') {
        s3compassAtC = true;
      }
      if (h.id == 's3_draw_arc_c') {
        s3arcC = true;
        s3compassAtC = false;
        advanceStep();
      }
      if (h.id == 's3_connect') {
        s3complete = true;
        advanceStep();
      }
    } else if (scenario == 4) {
      if (h.id == 's4_prot_p') {
        s4perpP = true;
        advanceStep();
      }
      if (h.id == 's4_prot_q') {
        s4perpQ = true;
        advanceStep();
      }
      if (h.id == 's4_comp_p') {
        s4compassAtP = true;
      }
      if (h.id == 's4_draw_arc_p') {
        s4arcP = true;
        s4compassAtP = false;
        advanceStep();
      }
      if (h.id == 's4_comp_q') {
        s4compassAtQ = true;
      }
      if (h.id == 's4_draw_arc_q') {
        s4arcQ = true;
        s4compassAtQ = false;
        advanceStep();
      }
      if (h.id == 's4_connect') {
        s4complete = true;
        advanceStep();
      }
    } else if (scenario == 5) {
      if (h.id == 's5_diag1') {
        s5diag1 = true;
      }
      if (h.id == 's5_diag2') {
        s5diag2 = true;
        advanceStep();
      }
      if (h.id == 's5_prot_o') {
        s5protPlaced = true;
      }
      if (h.id == 's5_axis_v') {
        s5axisV = true;
      }
      if (h.id == 's5_axis_h') {
        s5axisH = true;
        s5protPlaced = false;
        advanceStep();
      }
      if (h.id == 's5_comp_o') {
        s5compPlaced = true;
      }
      if (h.id == 's5_comp_set') {
        s5compSet = true;
      }
      if (h.id == 's5_draw_circle') {
        s5marks = true;
        s5compPlaced = false;
        advanceStep();
      }
      if (h.id.startsWith('s5_line_')) {
        s5lines++;
        if (s5lines == 4) {
          s5complete = true;
          advanceStep();
        }
      }
    }

    if (step != initialStep && !(scenario == 2 && step == 2)) {
      activeTool = null;
    }
  }

  void handleTapEnd(Hotspot h, Offset p) {
    if (h.type == 'drag_line' ||
        h.type == 'drag_width' ||
        h.type == 'drag_arc') {
      double dist =
          (Offset(p.dx, p.dy) - Offset(h.targetX!, h.targetY!)).distance;
      if (dist < 60) {
        executeAction(h);
      } else {
        if (h.type == 'drag_width') {
          playClick
              ?.call(); // resizing without completing counts as valid interaction
          if (scenario == 1) s1compWidth = max(u, p.dx - h.baseX!);
          if (scenario == 3) s3compWidth = max(u, p.dx - h.baseX!);
          if (scenario == 5) s5compWidth = max(u, p.dx - h.baseX!);
        } else {
          playError?.call(); // Failed drop
        }
      }
    }
  }
}

// --- WIDGETS ---
class Cl6M_Ch8_A4_AdvancedGeometricConstructions extends StatefulWidget {
  const Cl6M_Ch8_A4_AdvancedGeometricConstructions({Key? key})
    : super(key: key);

  @override
  State<Cl6M_Ch8_A4_AdvancedGeometricConstructions> createState() =>
      _Cl6M_Ch8_A4_AdvancedGeometricConstructionsState();
}

class _Cl6M_Ch8_A4_AdvancedGeometricConstructionsState
    extends State<Cl6M_Ch8_A4_AdvancedGeometricConstructions>
    with SingleTickerProviderStateMixin {
  final SimState state = SimState();
  late AnimationController _animCtrl;
  final GlobalKey _canvasKey = GlobalKey();

  bool _interactingWithTool = false;
  double _baseZoom = 1.0;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();

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
    )..repeat();

    // Attach Audio Callbacks to State
    state.playClick = playClick;
    state.playPageOpen = playPageOpen;
    state.playDropdown = playDropdown;
    state.playError = playError;
    state.playSuccess = curtainScreen;

    state.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _errorPlayer.dispose();
    _successPlayer.dispose();
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
    await _errorPlayer.stop();
    await _errorPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _successPlayer.stop();
    await _successPlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  int getScenarioStepCount(int sc) {
    if (sc == 1) return 6;
    if (sc == 2 || sc == 3 || sc == 4) return 5;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Geometric Constructions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: zslDark,
        textTheme: Typography.material2021().white,
      ),
      home: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Scaffold(
          body: Stack(
            children: [
              // Canvas Area
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 0,
                bottom: 0,
                right: 0,
                left: state.sidebarOpen ? state.sidebarWidth : 0,
                child: GestureDetector(
                  onScaleStart: (details) {
                    _baseZoom = state.zoom;
                  },
                  onScaleUpdate: (details) {
                    if (_interactingWithTool ||
                        state.activeDragEntity != null) {
                      return;
                    }
                    state.panX += details.focalPointDelta.dx;
                    state.panY += details.focalPointDelta.dy;
                    if (details.scale != 1.0) {
                      state.zoom = max(
                        0.4,
                        min(4.0, _baseZoom * details.scale),
                      );
                    }
                    state.forceUpdate();
                  },
                  child: Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    child: Container(
                      key: _canvasKey,
                      color: zslDark,
                      child: CustomPaint(
                        painter: GeomPainter(state, _animCtrl),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),

              // In-Canvas Verify Button
              if (!state.isScenarioComplete() &&
                  state.step == getScenarioStepCount(state.scenario) - 1)
                Positioned(
                  top: 90,
                  right: 20,
                  child: ElevatedButton.icon(
                    onPressed: state.verifyCurrent,
                    icon: const Icon(Icons.check_circle),
                    label: Text(state.t('verify')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: zslIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              // HUD Bottom Center
              if (state.step < getScenarioStepCount(state.scenario))
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: 10,
                  left: state.sidebarOpen ? state.sidebarWidth + 20 : 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xE60F172A), // semi-transparent dark
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(
                          top: BorderSide(color: zslIndigo, width: 4),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
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
                            decoration: BoxDecoration(
                              color: zslIndigo.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.indigoAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              state.t(
                                's${state.scenario}_step${state.step + 1}_task',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 0,
                bottom: 0,
                left: state.sidebarOpen ? 0 : -state.sidebarWidth,
                width: state.sidebarWidth,
                child: _buildSidebar(),
              ),

              // Menu Toggle Button (Fixed Position visually via padding if sidebar closed)
              Positioned(
                top: 15,
                left: 15,
                child: GestureDetector(
                  onTap: () {
                    state.sidebarOpen = !state.sidebarOpen;
                    playClick();
                    state.forceUpdate();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: zslSidebar,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      state.sidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Success Popup
              if (state.isScenarioComplete())
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Container(
                      color: Colors.black87,
                      child: Center(
                        child: Container(
                          width: 500,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: zslSidebar,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: zslEmerald,
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.t('successTitle'),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.t('finalDesc'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () {
                                  playClick();
                                  if (state.scenario < 5) {
                                    state.loadScenario(state.scenario + 1);
                                  } else {
                                    state.loadScenario(1);
                                  }
                                },
                                icon: Icon(
                                  state.scenario < 5
                                      ? Icons.arrow_forward
                                      : Icons.flag,
                                ),
                                label: Text(
                                  state.t(
                                    state.scenario < 5
                                        ? 'nextChallenge'
                                        : 'finishLab',
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: state.scenario < 5
                                      ? zslIndigo
                                      : zslAmber,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 20,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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

              // Curtain Screen
              if (state.showCurtain)
                Positioned.fill(
                  child: Container(
                    color: zslDark,
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.architecture,
                                color: zslIndigo,
                                size: 100,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                state.t('appTitle'),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.t('appSubtitle'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white60,
                                  letterSpacing: 2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 48),
                              ElevatedButton.icon(
                                onPressed: () {
                                  playPageOpen();
                                  state.showCurtain = false;
                                  state.forceUpdate();
                                },
                                icon: const Icon(Icons.play_circle_fill),
                                label: Text(state.t('enterLab')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: zslIndigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: zslSidebar,
        border: Border(right: BorderSide(color: zslIndigo, width: 2)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 66,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Icon(
                            Icons.architecture,
                            color: zslIndigo,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.t('appTitle'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.t('appSubtitle'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: state.toggleLanguage,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: zslIndigo.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: zslIndigo.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.language,
                                            color: Colors.indigoAccent,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            state.lang.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.indigoAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      playClick();
                                      state.loadScenario(1);
                                      state.showCurtain = true;
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: zslRose.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: zslRose.withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh,
                                            color: zslRose,
                                            size: 14,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Reset",
                                            style: TextStyle(
                                              color: zslRose,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.t('selectScenario').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white54,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: zslDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: state.scenario,
                              dropdownColor: zslSidebar,
                              isExpanded: true,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              items: [1, 2, 3, 4, 5]
                                  .map(
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text(state.t('s${i}_title')),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) state.loadScenario(v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: zslIndigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: zslIndigo.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.track_changes,
                                    color: zslRose,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    state.t('missionObj'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.indigoAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.t('s${state.scenario}_obj'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Steps
                        ...List.generate(getScenarioStepCount(state.scenario), (
                          i,
                        ) {
                          bool isCompleted = i < state.step;
                          bool isActive = i == state.step;
                          bool isFuture = i > state.step;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? zslDark
                                  : (isCompleted
                                        ? zslEmerald.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive
                                    ? zslIndigo
                                    : (isCompleted
                                          ? zslEmerald.withOpacity(0.3)
                                          : Colors.transparent),
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? zslEmerald
                                        : (isActive
                                              ? zslIndigo
                                              : Colors.white24),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: isCompleted
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white,
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
                                        '${state.t('step')} ${i + 1}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white54,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        state.t(
                                          's${state.scenario}_step${i + 1}_task',
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isFuture
                                              ? Colors.white54
                                              : Colors.white,
                                          fontWeight: isActive
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (isCompleted) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: zslEmerald.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: zslEmerald,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  state.t(
                                                    's${state.scenario}_step${i + 1}_out',
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                    padding: const EdgeInsets.all(12),
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: Text(
                      state.t('footer'),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Resizer Handle
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                double newW = state.sidebarWidth + details.delta.dx;
                if (newW >= 300 &&
                    newW <= MediaQuery.of(context).size.width * 0.6) {
                  state.sidebarWidth = newW;
                  state.forceUpdate();
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(width: 10, color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- GESTURES HANDLING VIA LISTENER ---
  Offset _getLocalPoint(Offset global) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(global);
  }

  Offset _screenToWorld(Offset local) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    double cx = box.size.width / 2;
    double cy = box.size.height / 2;
    return Offset(
      (local.dx - cx - state.panX) / state.zoom,
      (local.dy - cy - state.panY) / state.zoom,
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    if (state.activeDragEntity != null) return;
    Offset local = _getLocalPoint(event.position);
    Offset world = _screenToWorld(local);
    _interactingWithTool = false;

    // Check hotspots back-to-front (top-most z-index priority)
    for (int i = state.currentHotspots.length - 1; i >= 0; i--) {
      Hotspot h = state.currentHotspots[i];
      Offset pt = h.isScreenSpace ? local : world;
      double dist = (pt - Offset(h.x, h.y)).distance;

      if (dist < h.r) {
        if (h.type == 'tool_select') {
          if (state.activeTool != h.tool) {
            playClick(); // Play sound on tool selection
          }
          state.activeTool = h.tool;
          _interactingWithTool = true;
          state.forceUpdate();
          return;
        } else if (['drag_line', 'drag_width', 'drag_arc'].contains(h.type)) {
          if (h.tool == null || state.activeTool == h.tool) {
            state.activeDragEntity = h.id;
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            _interactingWithTool = true;
            state.forceUpdate();
            return;
          }
        } else if (['place', 'click'].contains(h.type)) {
          if (h.tool == null || state.activeTool == h.tool) {
            state.executeAction(h);
            _interactingWithTool = true;
            return;
          }
        }
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (state.activeDragEntity != null) {
      var matches = state.currentHotspots.where(
        (hs) => hs.id == state.activeDragEntity,
      );
      if (matches.isEmpty) return;

      Hotspot h = matches.first;
      Offset local = _getLocalPoint(event.position);
      Offset pt = h.isScreenSpace ? local : _screenToWorld(local);
      state.dragX = pt.dx;
      state.dragY = pt.dy;
      state.forceUpdate();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (state.activeDragEntity != null) {
      var matches = state.currentHotspots.where(
        (hs) => hs.id == state.activeDragEntity,
      );
      if (matches.isNotEmpty) {
        Hotspot h = matches.first;
        Offset p = Offset(state.dragX, state.dragY);
        state.handleTapEnd(h, p);
      }
      state.activeDragEntity = null;
      state.forceUpdate();
    }
    _interactingWithTool = false;
  }
}

// --- CANVAS PAINTER ---
class GeomPainter extends CustomPainter {
  final SimState state;
  final AnimationController anim;

  GeomPainter(this.state, this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    state.currentHotspots.clear();

    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

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

    _drawToolbox(canvas, size);
  }

  @override
  bool shouldRepaint(GeomPainter oldDelegate) => true;

  // --- DRAWING HELPERS ---
  void _drawLine(
    Canvas c,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double w, [
    bool dashed = false,
  ]) {
    final p = Paint()
      ..color = color
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (dashed) {
      double dist = (Offset(x2, y2) - Offset(x1, y1)).distance;
      double dx = (x2 - x1) / dist * 6;
      double dy = (y2 - y1) / dist * 6;
      for (double i = 0; i < dist; i += 12) {
        c.drawLine(
          Offset(x1 + dx * (i / 6), y1 + dy * (i / 6)),
          Offset(x1 + dx * ((i + 6) / 6), y1 + dy * ((i + 6) / 6)),
          p,
        );
      }
    } else {
      c.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    }
  }

  void _drawArcLine(
    Canvas c,
    double x,
    double y,
    double r,
    double startA,
    double endA,
    Color color,
    double w, [
    bool dashed = false,
  ]) {
    final p = Paint()
      ..color = color
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    double sweep = endA - startA;
    if (dashed) {
      // Simple dash for arcs is complex, fallback to solid for arcs here to save space
      p.color = color.withOpacity(0.5);
    }
    c.drawArc(
      Rect.fromCircle(center: Offset(x, y), radius: r),
      startA,
      sweep,
      false,
      p,
    );
  }

  void _drawPoint(
    Canvas c,
    double x,
    double y,
    String label, {
    bool isTarget = false,
    Offset offset = const Offset(15, -15),
  }) {
    if (isTarget) {
      c.drawCircle(
        Offset(x, y),
        12,
        Paint()
          ..color = zslIndigo.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      double wave = sin(anim.value * pi * 2) * 4;
      c.drawCircle(
        Offset(x, y),
        12 + wave,
        Paint()
          ..color = zslIndigo
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
    c.drawCircle(
      Offset(x, y),
      4,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    if (label.isNotEmpty) {
      _drawText(c, label, x + offset.dx, y + offset.dy, Colors.white, 16, true);
    }
  }

  void _drawText(
    Canvas c,
    String txt,
    double x,
    double y,
    Color color,
    double size, [
    bool bold = false,
  ]) {
    final tp = TextPainter(
      text: TextSpan(
        text: txt,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(c, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  // --- VIRTUAL TOOLS ---
  void _drawToolIcon(
    Canvas c,
    String id,
    double x,
    double y,
    double size,
    Color col1,
    Color col2,
  ) {
    c.save();
    c.translate(x - size / 2, y - size / 2);
    double scale = size / 24;
    c.scale(scale, scale);
    Paint p1 = Paint()
      ..color = col1
      ..strokeWidth = 1.5 / scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Paint p2 = Paint()
      ..color = col2
      ..strokeWidth = 1.5 / scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (id == 'ruler') {
      c.drawPath(Path()..addRect(const Rect.fromLTWH(4, 6, 16, 8)), p1);
      c.drawPath(
        Path()
          ..moveTo(6, 6)
          ..lineTo(6, 9)
          ..moveTo(9, 6)
          ..lineTo(9, 8)
          ..moveTo(12, 6)
          ..lineTo(12, 9)
          ..moveTo(15, 6)
          ..lineTo(15, 8)
          ..moveTo(18, 6)
          ..lineTo(18, 9),
        p2,
      );
    } else if (id == 'protractor') {
      c.drawPath(
        Path()
          ..addArc(const Rect.fromLTWH(3, 7, 18, 18), pi, pi)
          ..lineTo(3, 16)
          ..close(),
        p1,
      );
      c.drawPath(
        Path()
          ..moveTo(12, 16)
          ..lineTo(12, 13)
          ..moveTo(7.5, 13.5)
          ..lineTo(9.5, 15)
          ..moveTo(16.5, 13.5)
          ..lineTo(14.5, 15)
          ..addArc(const Rect.fromLTWH(10, 14, 4, 4), pi, pi),
        p2,
      );
    } else if (id == 'compass') {
      c.drawPath(
        Path()
          ..moveTo(12, 3)
          ..lineTo(8, 21)
          ..lineTo(12, 12)
          ..lineTo(16, 21)
          ..close(),
        p1,
      );
      c.drawCircle(const Offset(12, 12), 2, p2);
    } else if (id == 'pencil') {
      c.drawPath(
        Path()
          ..moveTo(17, 3)
          ..lineTo(21, 7)
          ..lineTo(7.5, 20.5)
          ..lineTo(2, 22)
          ..lineTo(3.5, 16.5)
          ..close(),
        p1,
      );
      c.drawPath(
        Path()
          ..moveTo(15, 5)
          ..lineTo(19, 9)
          ..moveTo(6.5, 17.5)
          ..lineTo(4.5, 18.5),
        p2,
      );
    }
    c.restore();
  }

  void _drawToolbox(Canvas c, Size size) {
    double bx = 20;
    // GAP: When sidebar is closed (state.sidebarOpen = false), menu icon is at top-left.
    // Shift the toolbox down to 80.0 to prevent overlapping.
    double by = state.sidebarOpen ? 20.0 : 80.0;

    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, 70, 260),
        const Radius.circular(15),
      ),
      Paint()
        ..color = zslSidebar
        ..style = PaintingStyle.fill,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, 70, 260),
        const Radius.circular(15),
      ),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    var tools = [
      {'id': 'ruler', 'y': by + 40.0},
      {'id': 'protractor', 'y': by + 100.0},
      {'id': 'compass', 'y': by + 160.0},
      {'id': 'pencil', 'y': by + 220.0},
    ];

    for (var t in tools) {
      String id = t['id'] as String;
      double ty = t['y'] as double;
      bool isActive = state.activeTool == id;

      if (isActive) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx + 10, ty - 25, 50, 50),
            const Radius.circular(10),
          ),
          Paint()
            ..color = zslIndigo
            ..style = PaintingStyle.fill,
        );
      }

      _drawToolIcon(
        c,
        id,
        bx + 35,
        ty - 8,
        26,
        isActive ? Colors.white : zslIndigo,
        isActive ? Colors.white70 : Colors.white38,
      );
      _drawText(
        c,
        state.t(id),
        bx + 35,
        ty + 15,
        isActive ? Colors.white : Colors.white54,
        9,
        true,
      );

      state.currentHotspots.add(
        Hotspot(
          id: 'tb_$id',
          type: 'tool_select',
          x: bx + 35,
          y: ty,
          r: 25,
          tool: id,
          isScreenSpace: true,
        ),
      );
    }
  }

  void _drawVRuler(Canvas c, double x, double y, double lenCm, double angle) {
    c.save();
    c.translate(x, y);
    c.rotate(angle);
    double w = lenCm * u + 40;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-20, -20, w, 40),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.white.withOpacity(0.9),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-20, -20, w, 40),
        const Radius.circular(5),
      ),
      Paint()
        ..color = Colors.black26
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    Paint p = Paint()..color = Colors.black87;
    for (int i = 0; i <= lenCm; i++) {
      double px = i * u;
      c.drawRect(Rect.fromLTWH(px - 1, -20, 2, 15), p);
      _drawText(c, i.toString(), px, 2, Colors.black87, 10, true);
      if (i < lenCm) c.drawRect(Rect.fromLTWH(px + u / 2 - 0.5, -20, 1, 10), p);
    }
    c.restore();
  }

  void _drawVProtractor(Canvas c, double x, double y) {
    c.save();
    c.translate(x, y);
    double r = 120;
    Path p = Path()
      ..addArc(Rect.fromCircle(center: Offset.zero, radius: r), pi, pi)
      ..lineTo(0, 0)
      ..close();
    c.drawPath(p, Paint()..color = Colors.white.withOpacity(0.85));
    c.drawPath(
      p,
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    c.drawCircle(Offset.zero, 5, Paint()..color = Colors.black87);
    c.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r - 32),
      pi,
      pi,
      false,
      Paint()
        ..color = Colors.black38
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    for (int a = 0; a <= 180; a += 5) {
      double rad = pi - (a * pi / 180);
      bool isMajor = a % 10 == 0;
      double tL = isMajor ? 12 : 7;
      double x1 = (r - tL) * cos(rad), y1 = -(r - tL) * sin(rad);
      double x2 = r * cos(rad), y2 = -r * sin(rad);
      _drawLine(c, x1, y1, x2, y2, Colors.black87, a % 90 == 0 ? 2 : 1);
      if (a % 30 == 0 || a == 90) {
        _drawText(
          c,
          a.toString(),
          (r - 22) * cos(rad),
          -(r - 22) * sin(rad),
          Colors.black87,
          10,
          true,
        );
        _drawText(
          c,
          (180 - a).toString(),
          (r - 44) * cos(rad),
          -(r - 44) * sin(rad),
          Colors.black87,
          10,
          true,
        );
      }
    }
    c.restore();
  }

  void _drawVCompass(Canvas c, double x, double y, double rPx, double angle) {
    c.save();
    c.translate(x, y);
    c.rotate(angle);
    double L = 180;
    double clampedR = min(rPx, L * 1.95);
    double hx = clampedR / 2;
    double hy = -sqrt(L * L - (clampedR / 2) * (clampedR / 2));

    Color strk = Colors.white;
    Color leg = const Color(0xFF475569);
    Color hinge = const Color(0xFF94A3B8);
    void drawPoly(List<Offset> pts, Color fill) {
      Path p = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (var i = 1; i < pts.length; i++) {
        p.lineTo(pts[i].dx, pts[i].dy);
      }
      p.close();
      c.drawPath(p, Paint()..color = fill);
      c.drawPath(
        p,
        Paint()
          ..color = strk
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    drawPoly([
      const Offset(0, 0),
      const Offset(-6, -25),
      Offset(hx - 8, hy + 5),
      Offset(hx + 2, hy + 5),
      const Offset(6, -25),
    ], leg);
    drawPoly([
      Offset(clampedR, 0),
      Offset(clampedR + 6, -25),
      Offset(hx + 8, hy + 5),
      Offset(hx - 2, hy + 5),
      Offset(clampedR - 6, -25),
    ], leg);
    drawPoly([
      Offset(clampedR, 0),
      Offset(clampedR - 6, -25),
      Offset(clampedR + 6, -25),
    ], Colors.amber);

    Path graph = Path()
      ..moveTo(clampedR, 0)
      ..lineTo(clampedR - 2, -10)
      ..lineTo(clampedR + 2, -10)
      ..close();
    c.drawPath(graph, Paint()..color = Colors.black54);

    Path nTip = Path()
      ..moveTo(0, 0)
      ..lineTo(-2, -25)
      ..lineTo(2, -25)
      ..close();
    c.drawPath(nTip, Paint()..color = hinge);

    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hx - 6, hy - 28, 12, 20),
        const Radius.circular(4),
      ),
      Paint()..color = hinge,
    );
    c.drawCircle(Offset(hx, hy), 12, Paint()..color = hinge);
    c.drawCircle(
      Offset(hx, hy),
      12,
      Paint()
        ..color = strk
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    c.drawCircle(Offset(hx, hy), 4, Paint()..color = strk);

    c.restore();
  }

  // --- SCENARIO RENDERERS ---
  void _renderS1(Canvas c) {
    double oX = -2.5 * u, oY = 2 * u; // D
    if (state.s1drawnBase || state.step > 0) {
      _drawLine(c, oX, oY, oX + 5 * u, oY, Colors.white, 3);
      _drawPoint(c, oX, oY, 'D', offset: const Offset(-15, 20));
      _drawPoint(c, oX + 5 * u, oY, 'C', offset: const Offset(15, 20));
      _drawText(c, "5 cm", oX + 2.5 * u, oY + 20, Colors.white, 14, true);
    }
    if (state.step == 0) {
      if (state.activeTool == 'ruler') {
        _drawVRuler(c, oX, oY, 6, 0);
        _drawPoint(c, oX, oY, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's1_base',
            type: 'drag_line',
            x: oX,
            y: oY,
            r: 20,
            targetX: oX + 5 * u,
            targetY: oY,
            tool: 'ruler',
          ),
        );
        if (state.activeDragEntity == 's1_base') {
          double cx = max(oX, min(state.dragX, oX + 5 * u));
          _drawLine(c, oX, oY, cx, oY, zslIndigo, 4);
          _drawToolIcon(c, 'pencil', cx, oY - 15, 24, zslIndigo, Colors.white);
        }
      }
    }
    if (state.step == 1) {
      if (state.activeTool == 'protractor') {
        if (!state.s1protractorPlaced) {
          _drawPoint(c, oX + 5 * u, oY, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(
              id: 's1_prot_c',
              type: 'place',
              x: oX + 5 * u,
              y: oY,
              r: 25,
              tool: 'protractor',
            ),
          );
        } else {
          _drawVProtractor(c, oX + 5 * u, oY);
          _drawPoint(c, oX + 5 * u, oY - 120, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(
              id: 's1_mark_90',
              type: 'click',
              x: oX + 5 * u,
              y: oY - 120,
              r: 20,
            ),
          );
        }
      }
    }
    if (state.s1drawnPerp || state.step > 1) {
      _drawLine(c, oX + 5 * u, oY, oX + 5 * u, oY - 6 * u, zslFaint, 2, true);
      c.drawRect(
        Rect.fromLTWH(oX + 5 * u - 15, oY - 15, 15, 15),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }
    if (state.step == 2) {
      double rx = oX, ry = oY + 120;
      _drawVRuler(c, rx, ry, 8, 0);
      if (state.activeTool == 'compass') {
        if (!state.s1compassPlaced) {
          _drawPoint(c, rx, ry, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(
              id: 's1_comp_0',
              type: 'place',
              x: rx,
              y: ry,
              r: 25,
              tool: 'compass',
            ),
          );
        } else {
          _drawPoint(c, rx + 7 * u, ry, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(
              id: 's1_comp_7',
              type: 'drag_width',
              x: rx + state.s1compWidth,
              y: ry,
              r: 30,
              targetX: rx + 7 * u,
              targetY: ry,
              baseX: rx,
            ),
          );
          double cw = state.activeDragEntity == 's1_comp_7'
              ? max(u, min(8 * u, state.dragX - rx))
              : state.s1compWidth;
          _drawVCompass(c, rx, ry, cw, 0);
        }
      }
    }
    if (state.step == 3) {
      if (state.activeTool == 'compass') {
        if (!state.s1compassAtD) {
          _drawPoint(c, oX, oY, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(
              id: 's1_comp_d',
              type: 'place',
              x: oX,
              y: oY,
              r: 25,
              tool: 'compass',
            ),
          );
        } else {
          double arcR = 7 * u, tY = oY - sqrt(24) * u, tX = oX + 5 * u;
          double startA = -0.1, targetA = atan2(tY - oY, tX - oX) - 0.2;
          double currA = state.activeDragEntity == 's1_draw_arc'
              ? atan2(state.dragY - oY, state.dragX - oX)
              : startA;
          if (state.activeDragEntity == 's1_draw_arc') {
            _drawArcLine(
              c,
              oX,
              oY,
              arcR,
              min(startA, currA),
              max(startA, currA),
              zslIndigo,
              3,
            );
          } else {
            _drawPoint(
              c,
              oX + arcR * cos(startA),
              oY + arcR * sin(startA),
              '',
              isTarget: true,
            );
          }
          _drawVCompass(c, oX, oY, arcR, currA);
          state.currentHotspots.add(
            Hotspot(
              id: 's1_draw_arc',
              type: 'drag_arc',
              x: oX + arcR * cos(startA),
              y: oY + arcR * sin(startA),
              r: 40,
              targetX: oX + arcR * cos(targetA),
              targetY: oY + arcR * sin(targetA),
            ),
          );
        }
      }
    }
    if (state.s1drawnArc || state.step > 3) {
      _drawArcLine(c, oX, oY, 7 * u, -pi / 2, 0, zslFaint, 2, true);
      double bx = oX + 5 * u, by = oY - sqrt(24) * u;
      _drawPoint(c, bx, by, 'B', offset: const Offset(15, -15));
      _drawLine(c, oX, oY, bx, by, zslFaint, 1);
      _drawText(c, "7 cm", oX + 2.5 * u - 10, oY - 2.5 * u, zslFaint, 14, true);
    }
    if (state.step == 4 && state.activeTool == 'ruler') {
      double bx = oX + 5 * u, by = oY - sqrt(24) * u;
      _drawPoint(c, bx, by, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(id: 's1_complete', type: 'click', x: bx, y: by, r: 30),
      );
    }
    if (state.s1complete || state.step > 4) {
      double bx = oX + 5 * u, by = oY - sqrt(24) * u, ax = oX, ay = by;
      _drawLine(c, bx, by, ax, ay, Colors.white, 3);
      _drawLine(c, ax, ay, oX, oY, Colors.white, 3);
      _drawPoint(c, ax, ay, 'A', offset: const Offset(-15, -15));
      c.drawRect(
        Rect.fromLTWH(oX, by, 5 * u, oY - by),
        Paint()..color = zslIndigo.withOpacity(0.1),
      );
    }
    if (state.s1verified) {
      double bx = oX + 5 * u, by = oY - sqrt(24) * u, ax = oX, ay = by;
      _drawLine(c, ax, ay - 10, bx, ay - 10, zslEmerald, 2);
      _drawText(c, "5 cm", oX + 2.5 * u, ay - 25, zslEmerald, 14, true);
      _drawLine(c, ax, ay, oX + 5 * u, oY, zslEmerald, 2, true);
      _drawText(
        c,
        "7 cm",
        oX + 2.5 * u + 10,
        oY - 2.5 * u,
        zslEmerald,
        14,
        true,
      );
    }
  }

  void _renderS2(Canvas c) {
    double oX = -4 * u, oY = 2 * u; // A
    if (state.s2drawnBase || state.step > 0) {
      _drawLine(c, oX, oY, oX + 8 * u, oY, Colors.white, 3);
      _drawPoint(c, oX, oY, 'A', offset: const Offset(-15, 20));
      _drawPoint(c, oX + 8 * u, oY, 'B', offset: const Offset(15, 20));
    }
    if (state.step == 0 && state.activeTool == 'ruler') {
      _drawVRuler(c, oX, oY, 9, 0);
      _drawPoint(c, oX, oY, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(
          id: 's2_base',
          type: 'drag_line',
          x: oX,
          y: oY,
          r: 20,
          targetX: oX + 8 * u,
          targetY: oY,
          tool: 'ruler',
        ),
      );
      if (state.activeDragEntity == 's2_base') {
        double cx = max(oX, min(state.dragX, oX + 8 * u));
        _drawLine(c, oX, oY, cx, oY, zslIndigo, 4);
        _drawToolIcon(c, 'pencil', cx, oY - 15, 24, zslIndigo, Colors.white);
      }
    }
    if (state.step == 1 && state.activeTool == 'protractor') {
      if (state.s2protAt != 'A') {
        _drawPoint(c, oX, oY, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's2_prot_a',
            type: 'place',
            x: oX,
            y: oY,
            r: 25,
            tool: 'protractor',
          ),
        );
      } else {
        _drawVProtractor(c, oX, oY);
        _drawPoint(c, oX, oY - 120, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(id: 's2_mark_90', type: 'click', x: oX, y: oY - 120, r: 20),
        );
      }
    }
    if (state.s2drawnPerpA || state.step > 1) {
      _drawLine(c, oX, oY, oX, oY - 6 * u, zslFaint, 2, true);
    }
    if (state.step == 2 && state.activeTool == 'protractor') {
      _drawVProtractor(c, oX, oY);
      double pX = oX + 120 * cos(pi / 3), pY = oY - 120 * sin(pi / 3);
      _drawPoint(c, pX, pY, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(id: 's2_mark_60', type: 'click', x: pX, y: pY, r: 20),
      );
    }
    if (state.s2drawnDiag || state.step > 2) {
      _drawLine(
        c,
        oX,
        oY,
        oX + 8 * u,
        oY - 8 * u * tan(pi / 6),
        zslFaint,
        2,
        true,
      );
      _drawArcLine(c, oX, oY, 40, -pi / 6, 0, Colors.white, 1);
      _drawText(c, "30°", oX + 50, oY - 10, Colors.white, 12, true);
      _drawArcLine(c, oX, oY, 50, -pi / 2, -pi / 6, Colors.white, 1);
      _drawText(c, "60°", oX + 25, oY - 55, Colors.white, 12, true);
    }
    if (state.step == 3 && state.activeTool == 'protractor') {
      if (state.s2protAt != 'B') {
        _drawPoint(c, oX + 8 * u, oY, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's2_prot_b',
            type: 'place',
            x: oX + 8 * u,
            y: oY,
            r: 25,
            tool: 'protractor',
          ),
        );
      } else {
        _drawVProtractor(c, oX + 8 * u, oY);
        _drawPoint(c, oX + 8 * u, oY - 120, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's2_mark_90_b',
            type: 'click',
            x: oX + 8 * u,
            y: oY - 120,
            r: 20,
          ),
        );
      }
    }
    double cY = oY - 8 * u * tan(pi / 6);
    if (state.s2drawnPerpB || state.step > 3) {
      _drawLine(c, oX + 8 * u, oY, oX + 8 * u, cY - 2 * u, zslFaint, 2, true);
      _drawPoint(c, oX + 8 * u, cY, 'C', offset: const Offset(15, -15));
    }
    if (state.step == 4 && state.activeTool == 'compass') {
      _drawPoint(c, oX, oY, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(id: 's2_comp_a', type: 'click', x: oX, y: oY, r: 25),
      );
    }
    if (state.s2complete || state.step > 4) {
      _drawLine(c, oX + 8 * u, oY, oX + 8 * u, cY, Colors.white, 3);
      _drawLine(c, oX + 8 * u, cY, oX, cY, Colors.white, 3);
      _drawLine(c, oX, cY, oX, oY, Colors.white, 3);
      _drawLine(c, oX, oY, oX + 8 * u, cY, Colors.white, 2);
      _drawPoint(c, oX, cY, 'D', offset: const Offset(-15, -15));
      c.drawRect(
        Rect.fromLTWH(oX, cY, 8 * u, oY - cY),
        Paint()..color = zslIndigo.withOpacity(0.1),
      );
    }
  }

  void _renderS3(Canvas c) {
    double oX = -2.5 * u, oY = 2 * u; // B
    if (state.s3drawnBase || state.step > 0) {
      _drawLine(c, oX, oY, oX + 5 * u, oY, Colors.white, 3);
      _drawPoint(c, oX, oY, 'B', offset: const Offset(-15, 20));
      _drawPoint(c, oX + 5 * u, oY, 'C', offset: const Offset(15, 20));
      _drawText(c, "5 cm", oX + 2.5 * u, oY + 20, Colors.white, 14, true);
    }
    if (state.step == 0 && state.activeTool == 'ruler') {
      _drawVRuler(c, oX, oY, 6, 0);
      _drawPoint(c, oX, oY, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(
          id: 's3_base',
          type: 'drag_line',
          x: oX,
          y: oY,
          r: 20,
          targetX: oX + 5 * u,
          targetY: oY,
          tool: 'ruler',
        ),
      );
      if (state.activeDragEntity == 's3_base') {
        double cx = max(oX, min(state.dragX, oX + 5 * u));
        _drawLine(c, oX, oY, cx, oY, zslIndigo, 4);
        _drawToolIcon(c, 'pencil', cx, oY - 15, 24, zslIndigo, Colors.white);
      }
    }
    if (state.step == 1) {
      double rx = oX, ry = oY + 60;
      _drawVRuler(c, rx, ry, 6, 0);
      if (state.activeTool == 'compass') {
        if (!state.s3compassPlaced) {
          _drawPoint(c, rx, ry, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(
              id: 's3_comp_0',
              type: 'place',
              x: rx,
              y: ry,
              r: 25,
              tool: 'compass',
            ),
          );
        } else {
          _drawPoint(c, rx + 5 * u, ry, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(
              id: 's3_comp_5',
              type: 'drag_width',
              x: rx + state.s3compWidth,
              y: ry,
              r: 30,
              targetX: rx + 5 * u,
              targetY: ry,
              baseX: rx,
            ),
          );
          double cw = state.activeDragEntity == 's3_comp_5'
              ? max(u, min(6 * u, state.dragX - rx))
              : state.s3compWidth;
          _drawVCompass(c, rx, ry, cw, 0);
        }
      }
    }
    if (state.step == 2 && state.activeTool == 'compass') {
      if (!state.s3compassAtB) {
        _drawPoint(c, oX, oY, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's3_comp_b',
            type: 'place',
            x: oX,
            y: oY,
            r: 25,
            tool: 'compass',
          ),
        );
      } else {
        double arcR = 5 * u, startA = -pi * 0.1, targetA = -pi * 0.6;
        double currA = state.activeDragEntity == 's3_draw_arc_b'
            ? atan2(state.dragY - oY, state.dragX - oX)
            : startA;
        if (state.activeDragEntity == 's3_draw_arc_b') {
          _drawArcLine(
            c,
            oX,
            oY,
            arcR,
            min(startA, currA),
            max(startA, currA),
            zslIndigo,
            3,
          );
        } else {
          _drawPoint(
            c,
            oX + arcR * cos(startA),
            oY + arcR * sin(startA),
            '',
            isTarget: true,
          );
        }
        _drawVCompass(c, oX, oY, arcR, currA);
        state.currentHotspots.add(
          Hotspot(
            id: 's3_draw_arc_b',
            type: 'drag_arc',
            x: oX + arcR * cos(startA),
            y: oY + arcR * sin(startA),
            r: 40,
            targetX: oX + arcR * cos(targetA),
            targetY: oY + arcR * sin(targetA),
          ),
        );
      }
    }
    if (state.s3arcB || state.step > 2) {
      _drawArcLine(c, oX, oY, 5 * u, -pi * 0.6, -pi * 0.1, zslFaint, 2, true);
    }
    if (state.step == 3 && state.activeTool == 'compass') {
      if (!state.s3compassAtC) {
        _drawPoint(c, oX + 5 * u, oY, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's3_comp_c',
            type: 'place',
            x: oX + 5 * u,
            y: oY,
            r: 25,
            tool: 'compass',
          ),
        );
      } else {
        double arcR = 5 * u,
            startA = -pi * 0.9,
            targetA = -pi * 0.4,
            cx = oX + 5 * u;
        double currA = state.activeDragEntity == 's3_draw_arc_c'
            ? atan2(state.dragY - oY, state.dragX - cx)
            : startA;
        if (state.activeDragEntity == 's3_draw_arc_c') {
          _drawArcLine(
            c,
            cx,
            oY,
            arcR,
            min(startA, currA),
            max(startA, currA),
            zslIndigo,
            3,
          );
        } else {
          _drawPoint(
            c,
            cx + arcR * cos(startA),
            oY + arcR * sin(startA),
            '',
            isTarget: true,
          );
        }
        _drawVCompass(c, cx, oY, arcR, currA);
        state.currentHotspots.add(
          Hotspot(
            id: 's3_draw_arc_c',
            type: 'drag_arc',
            x: cx + arcR * cos(startA),
            y: oY + arcR * sin(startA),
            r: 40,
            targetX: cx + arcR * cos(targetA),
            targetY: oY + arcR * sin(targetA),
          ),
        );
      }
    }
    if (state.s3arcC || state.step > 3) {
      _drawArcLine(
        c,
        oX + 5 * u,
        oY,
        5 * u,
        -pi * 0.9,
        -pi * 0.4,
        zslFaint,
        2,
        true,
      );
      _drawPoint(
        c,
        oX + 2.5 * u,
        oY - (sqrt(3) / 2 * 5 * u),
        'A',
        offset: const Offset(0, -20),
      );
    }
    if (state.step == 4 && state.activeTool == 'pencil') {
      double aX = oX + 2.5 * u, aY = oY - (sqrt(3) / 2 * 5 * u);
      _drawPoint(c, aX, aY, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(id: 's3_connect', type: 'click', x: aX, y: aY, r: 30),
      );
    }
    if (state.s3complete || state.step > 4) {
      double aX = oX + 2.5 * u, aY = oY - (sqrt(3) / 2 * 5 * u);
      _drawLine(c, oX, oY, aX, aY, Colors.white, 3);
      _drawLine(c, oX + 5 * u, oY, aX, aY, Colors.white, 3);
      Path p = Path()
        ..moveTo(oX, oY)
        ..lineTo(oX + 5 * u, oY)
        ..lineTo(aX, aY)
        ..close();
      c.drawPath(p, Paint()..color = zslEmerald.withOpacity(0.1));
    }
  }

  void _renderS4(Canvas c) {
    for (int x = -400; x <= 400; x += 40) {
      for (int y = -300; y <= 300; y += 40) {
        c.drawCircle(
          Offset(x.toDouble(), y.toDouble()),
          2,
          Paint()..color = Colors.black26,
        );
      }
    }
    double px = -80, py = 80, qx = 80, qy = 40;
    _drawLine(c, px, py, qx, qy, Colors.white, 3);
    _drawPoint(c, px, py, 'P', offset: const Offset(-15, 20));
    _drawPoint(c, qx, qy, 'Q', offset: const Offset(15, 20));
    double dx = qx - px,
        dy = qy - py,
        sx = px - dy,
        sy = py + dx,
        rx = qx - dy,
        ry = qy + dx;

    if (state.step == 0 && state.activeTool == 'protractor') {
      _drawPoint(c, px, py, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(id: 's4_prot_p', type: 'click', x: px, y: py, r: 25),
      );
    }
    if (state.s4perpP || state.step > 0) {
      _drawLine(c, px, py, px - dy * 1.5, py + dx * 1.5, zslFaint, 2, true);
    }

    if (state.step == 1 && state.activeTool == 'protractor') {
      _drawPoint(c, qx, qy, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(id: 's4_prot_q', type: 'click', x: qx, y: qy, r: 25),
      );
    }
    if (state.s4perpQ || state.step > 1) {
      _drawLine(c, qx, qy, qx - dy * 1.5, qy + dx * 1.5, zslFaint, 2, true);
    }

    if (state.step == 2 && state.activeTool == 'compass') {
      if (!state.s4compassAtP) {
        _drawPoint(c, px, py, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's4_comp_p',
            type: 'place',
            x: px,
            y: py,
            r: 25,
            tool: 'compass',
          ),
        );
      } else {
        double arcR = sqrt(dx * dx + dy * dy),
            startA = atan2(dy, dx),
            targetA = atan2(dx, -dy) - 0.2;
        if (startA > 0 && targetA < 0) targetA += pi * 2;
        double currA = state.activeDragEntity == 's4_draw_arc_p'
            ? atan2(state.dragY - py, state.dragX - px)
            : startA;
        if (state.activeDragEntity == 's4_draw_arc_p') {
          _drawArcLine(
            c,
            px,
            py,
            arcR,
            min(startA, currA),
            max(startA, currA),
            zslIndigo,
            3,
          );
        } else {
          _drawPoint(
            c,
            px + arcR * cos(startA),
            py + arcR * sin(startA),
            '',
            isTarget: true,
          );
        }
        _drawVCompass(c, px, py, arcR, currA);
        state.currentHotspots.add(
          Hotspot(
            id: 's4_draw_arc_p',
            type: 'drag_arc',
            x: px + arcR * cos(startA),
            y: py + arcR * sin(startA),
            r: 40,
            targetX: px + arcR * cos(targetA),
            targetY: py + arcR * sin(targetA),
          ),
        );
      }
    }
    if (state.s4arcP || state.step > 2) {
      _drawArcLine(
        c,
        px,
        py,
        sqrt(dx * dx + dy * dy),
        atan2(dx, -dy) - 0.5,
        atan2(dy, dx) + 0.2,
        zslFaint,
        1,
        true,
      );
      _drawPoint(c, sx, sy, 'S', offset: const Offset(-15, -15));
    }

    if (state.step == 3 && state.activeTool == 'compass') {
      if (!state.s4compassAtQ) {
        _drawPoint(c, qx, qy, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's4_comp_q',
            type: 'place',
            x: qx,
            y: qy,
            r: 25,
            tool: 'compass',
          ),
        );
      } else {
        double arcR = sqrt(dx * dx + dy * dy),
            startA = atan2(-dy, -dx),
            targetA = atan2(dx, -dy) - 0.2;
        double currA = state.activeDragEntity == 's4_draw_arc_q'
            ? atan2(state.dragY - qy, state.dragX - qx)
            : startA;
        if (state.activeDragEntity == 's4_draw_arc_q') {
          _drawArcLine(
            c,
            qx,
            qy,
            arcR,
            min(startA, currA),
            max(startA, currA),
            zslIndigo,
            3,
          );
        } else {
          _drawPoint(
            c,
            qx + arcR * cos(startA),
            qy + arcR * sin(startA),
            '',
            isTarget: true,
          );
        }
        _drawVCompass(c, qx, qy, arcR, currA);
        state.currentHotspots.add(
          Hotspot(
            id: 's4_draw_arc_q',
            type: 'drag_arc',
            x: qx + arcR * cos(startA),
            y: qy + arcR * sin(startA),
            r: 40,
            targetX: qx + arcR * cos(targetA),
            targetY: qy + arcR * sin(targetA),
          ),
        );
      }
    }
    if (state.s4arcQ || state.step > 3) {
      _drawArcLine(
        c,
        qx,
        qy,
        sqrt(dx * dx + dy * dy),
        atan2(dx, -dy) - 0.5,
        atan2(-dy, -dx) + 0.2,
        zslFaint,
        1,
        true,
      );
      _drawPoint(c, rx, ry, 'R', offset: const Offset(15, -15));
    }

    if (state.step == 4 && state.activeTool == 'pencil') {
      _drawPoint(c, sx, sy, '', isTarget: true);
      state.currentHotspots.add(
        Hotspot(id: 's4_connect', type: 'click', x: sx, y: sy, r: 25),
      );
    }
    if (state.s4complete || state.step > 4) {
      _drawLine(c, px, py, sx, sy, Colors.white, 3);
      _drawLine(c, sx, sy, rx, ry, Colors.white, 3);
      _drawLine(c, rx, ry, qx, qy, Colors.white, 3);
      Path p = Path()
        ..moveTo(px, py)
        ..lineTo(qx, qy)
        ..lineTo(rx, ry)
        ..lineTo(sx, sy)
        ..close();
      c.drawPath(p, Paint()..color = zslAmber.withOpacity(0.2));
    }
  }

  void _renderS5(Canvas c) {
    double rx = -4 * u, ry = -2 * u, rw = 8 * u, rh = 4 * u;
    c.drawRect(
      Rect.fromLTWH(rx, ry, rw, rh),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    _drawPoint(c, rx, ry, 'A', offset: const Offset(-15, -15));
    _drawPoint(c, rx + rw, ry, 'B', offset: const Offset(15, -15));
    _drawPoint(c, rx + rw, ry + rh, 'C', offset: const Offset(15, 20));
    _drawPoint(c, rx, ry + rh, 'D', offset: const Offset(-15, 20));

    if (state.step == 0 && state.activeTool == 'ruler') {
      if (!state.s5diag1) {
        _drawVRuler(c, rx, ry, 9, atan2(rh, rw));
        _drawPoint(c, rx, ry, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's5_diag1',
            type: 'drag_line',
            x: rx,
            y: ry,
            r: 25,
            targetX: rx + rw,
            targetY: ry + rh,
            tool: 'ruler',
          ),
        );
        if (state.activeDragEntity == 's5_diag1') {
          _drawLine(c, rx, ry, state.dragX, state.dragY, zslIndigo, 4);
          _drawToolIcon(
            c,
            'pencil',
            state.dragX,
            state.dragY - 15,
            24,
            zslIndigo,
            Colors.white,
          );
        }
      } else if (!state.s5diag2) {
        _drawVRuler(c, rx + rw, ry, 9, atan2(rh, -rw));
        _drawPoint(c, rx + rw, ry, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's5_diag2',
            type: 'drag_line',
            x: rx + rw,
            y: ry,
            r: 25,
            targetX: rx,
            targetY: ry + rh,
            tool: 'ruler',
          ),
        );
        if (state.activeDragEntity == 's5_diag2') {
          _drawLine(c, rx + rw, ry, state.dragX, state.dragY, zslIndigo, 4);
          _drawToolIcon(
            c,
            'pencil',
            state.dragX,
            state.dragY - 15,
            24,
            zslIndigo,
            Colors.white,
          );
        }
      }
    }
    if (state.s5diag1 || state.step > 0) {
      _drawLine(c, rx, ry, rx + rw, ry + rh, zslFaint, 2, true);
    }
    if (state.s5diag2 || state.step > 0) {
      _drawLine(c, rx + rw, ry, rx, ry + rh, zslFaint, 2, true);
      _drawPoint(c, 0, 0, 'O', offset: const Offset(0, -20));
    }

    if (state.step == 1 && state.activeTool == 'protractor') {
      if (!state.s5protPlaced) {
        _drawPoint(c, 0, 0, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's5_prot_o',
            type: 'place',
            x: 0,
            y: 0,
            r: 25,
            tool: 'protractor',
          ),
        );
      } else {
        _drawVProtractor(c, 0, 0);
        if (!state.s5axisV) {
          _drawPoint(c, 0, -120, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(id: 's5_axis_v', type: 'click', x: 0, y: -120, r: 20),
          );
        } else if (!state.s5axisH) {
          _drawPoint(c, 120, 0, '', isTarget: true);
          state.currentHotspots.add(
            Hotspot(id: 's5_axis_h', type: 'click', x: 120, y: 0, r: 20),
          );
        }
      }
    }
    if (state.s5axisV || state.step > 1) {
      _drawLine(c, 0, ry, 0, ry + rh, zslFaint, 2, true);
    }
    if (state.s5axisH || state.step > 1) {
      _drawLine(c, rx, 0, rx + rw, 0, zslFaint, 2, true);
    }

    double sqR = 1.5 * u;
    if (state.step == 2 && state.activeTool == 'compass') {
      if (!state.s5compPlaced) {
        _drawPoint(c, 0, 0, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's5_comp_o',
            type: 'place',
            x: 0,
            y: 0,
            r: 25,
            tool: 'compass',
          ),
        );
      } else if (!state.s5compSet) {
        double bx = -150, by = 150, targetW = 1.5 * u;
        _drawVRuler(c, bx, by, 6, 0);
        double cw = state.activeDragEntity == 's5_comp_set'
            ? max(u, min(4 * u, state.dragX - bx))
            : state.s5compWidth;
        _drawVCompass(c, bx, by, cw, 0);
        _drawPoint(c, bx + targetW, by, '', isTarget: true);
        state.currentHotspots.add(
          Hotspot(
            id: 's5_comp_set',
            type: 'drag_width',
            x: bx + cw,
            y: by,
            r: 30,
            targetX: bx + targetW,
            targetY: by,
            baseX: bx,
          ),
        );
      } else if (!state.s5marks) {
        double currA = state.activeDragEntity == 's5_draw_circle'
            ? atan2(state.dragY, state.dragX)
            : 0;
        if (currA < 0) currA += pi * 2;
        if (state.activeDragEntity == 's5_draw_circle') {
          _drawArcLine(c, 0, 0, sqR, 0, currA, zslIndigo, 3);
        } else {
          _drawPoint(c, sqR, 0, '', isTarget: true);
        }
        _drawVCompass(c, 0, 0, sqR, currA);
        state.currentHotspots.add(
          Hotspot(
            id: 's5_draw_circle',
            type: 'drag_arc',
            x: sqR,
            y: 0,
            r: 40,
            targetX: sqR * cos(pi * 1.8),
            targetY: sqR * sin(pi * 1.8),
          ),
        );
        _drawText(
          c,
          "Drag compass pencil to draw circle",
          0,
          sqR + 40,
          zslIndigo,
          14,
          true,
        );
      }
    }
    if (state.s5marks || state.step > 2) {
      _drawArcLine(c, 0, 0, sqR, 0, pi * 2, zslFaint, 1, true);
      _drawPoint(c, sqR, 0, '');
      _drawPoint(c, -sqR, 0, '');
      _drawPoint(c, 0, sqR, '');
      _drawPoint(c, 0, -sqR, '');
    }

    var pts = [
      Offset(sqR, 0),
      Offset(0, sqR),
      Offset(-sqR, 0),
      Offset(0, -sqR),
    ];
    if (state.step == 3 && state.activeTool == 'pencil' && state.s5lines < 4) {
      Offset p1 = pts[state.s5lines], p2 = pts[(state.s5lines + 1) % 4];
      _drawPoint(c, p1.dx, p1.dy, '', isTarget: true);
      c.drawCircle(
        p2,
        20,
        Paint()
          ..color = zslIndigo
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      ); // dashed conceptually
      state.currentHotspots.add(
        Hotspot(
          id: 's5_line_${state.s5lines}',
          type: 'drag_line',
          x: p1.dx,
          y: p1.dy,
          r: 35,
          targetX: p2.dx,
          targetY: p2.dy,
          tool: 'pencil',
        ),
      );
      if (state.activeDragEntity == 's5_line_${state.s5lines}') {
        _drawLine(c, p1.dx, p1.dy, state.dragX, state.dragY, zslIndigo, 4);
        _drawToolIcon(
          c,
          'pencil',
          state.dragX,
          state.dragY - 15,
          24,
          zslIndigo,
          Colors.white,
        );
      }
    }

    if (state.s5lines > 0 || state.step > 3) {
      _drawLine(c, pts[0].dx, pts[0].dy, pts[1].dx, pts[1].dy, Colors.white, 3);
    }
    if (state.s5lines > 1 || state.step > 3) {
      _drawLine(c, pts[1].dx, pts[1].dy, pts[2].dx, pts[2].dy, Colors.white, 3);
    }
    if (state.s5lines > 2 || state.step > 3) {
      _drawLine(c, pts[2].dx, pts[2].dy, pts[3].dx, pts[3].dy, Colors.white, 3);
    }
    if (state.s5lines > 3 || state.step > 3) {
      _drawLine(c, pts[3].dx, pts[3].dy, pts[0].dx, pts[0].dy, Colors.white, 3);
    }

    if (state.s5complete || state.step > 3) {
      Path p = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..lineTo(pts[3].dx, pts[3].dy)
        ..close();
      c.drawPath(p, Paint()..color = Colors.pink.withOpacity(0.2));
    }
  }
}
