// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFF6366f1),
        fontFamily: 'Roboto',
      ),
      home: const TriangleInequalityScreen(),
    );
  }
}

class PlankData {
  String id;
  double len;
  String type; // 'tray', 'base', 'left', 'right', 'stretchy'
  double x;
  double y;
  double angle;

  PlankData({
    required this.id,
    required this.len,
    required this.type,
    required this.x,
    required this.y,
    this.angle = 0,
  });
}

class TriangleInequalityScreen extends StatefulWidget {
  const TriangleInequalityScreen({super.key});

  @override
  State<TriangleInequalityScreen> createState() =>
      _TriangleInequalityScreenState();
}

class _TriangleInequalityScreenState extends State<TriangleInequalityScreen>
    with TickerProviderStateMixin {
  // Constants
  static const double pxPerCm = 30.0;
  static const double baseY = 50.0;

  // App State
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;

  // Canvas Tools
  bool _isLocked = false;
  double _obsBoxX = 70.0;
  double _obsBoxY = 16.0;

  final TransformationController _transformCtrl = TransformationController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final GlobalKey _canvasKey = GlobalKey();
  late final AnimationController _pulseCtrl;

  // Sounds
  final String _sndPop =
      'audio/class7/mixkit_2568.mp3';
  final String _sndClick =
      'audio/class7/mixkit_2568.mp3';
  final String _sndSnap =
      'audio/class7/mixkit_2569.mp3';
  final String _sndSuccess =
      'audio/class7/mixkit_2015.mp3';
  final String _sndError =
      'audio/class7/mixkit_946.mp3';
  final String _sndTick =
      'audio/class7/mixkit_2567.mp3';

  int _scenario = 1;
  int _stepIndex = 0;
  String _phase =
      'idle'; // wait_base, wait_left, wait_right, rotating, complete, error_gap, error_flat, analyzed

  List<PlankData> _planks = [];
  double _s5SliderVal = 10.0;

  PlankData? _draggedPlank;
  String? _rotatedPlank; // 'left' or 'right'
  bool _isTransitioning = false;

  final Map<int, Map<String, dynamic>> _scenarios = {
    1: {
      'planks': [8.0, 5.0, 6.0],
      'reqBase': 8.0,
      'reqLeft': 5.0,
      'reqRight': 6.0,
    },
    2: {
      'planks': [8.0, 3.0, 4.0],
      'reqBase': 8.0,
      'reqLeft': 3.0,
      'reqRight': 4.0,
    },
    3: {
      'planks': [7.0, 3.0, 4.0],
      'reqBase': 7.0,
      'reqLeft': 3.0,
      'reqRight': 4.0,
    },
    4: {
      'planks': [6.0, 4.0, 4.0],
      'reqBase': 6.0,
      'reqLeft': 4.0,
      'reqRight': 4.0,
    },
    5: {'sliderMode': true},
  };

  final Map<String, Map<String, dynamic>> t = {
    'en': {
      'cm': "cm",
      'sliderLabel': "Length of Third Side",
      'appTitle': "Exploring Triangle Existence: The Triangle Inequality",
      'appSubtitle': "Class 7 • A TALE OF THREE INTERSECTING LINES",
      'enterLab': "Enter Lab",
      'selectScenario': "Select Scenario",
      'nextScenario': "Next Challenge",
      'stepLabel': "OBSERVATION",
      'theory': "Investigation Notes",
      'completed': "Completed!",
      'successTitle': "Geometry Master!",
      'successDesc':
          "You successfully explored the Triangle Inequality Theorem.",
      'restartLab': "Restart Lab",
      'analyzeBtn': "Analyze Error",
      'checkBtn': "Check My Work",
      'doneTaskBtn': "I'm Done",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",

      's1_title': "1. The Perfect Fit: A Possible Triangle",
      's1_obj':
          "To successfully construct a triangle from three given line segments and observe how the sides connect.",
      's1_steps': [
        {
          'hud':
              "Task: DRAG the longest plank (8cm) and DROP it onto the horizontal baseline guide.",
          'text':
              "Task: You are given three wooden planks with lengths 5cm, 6cm, and 8cm. DRAG the longest plank (8cm) and DROP it onto the horizontal baseline guide at the bottom of the screen.\n\nObserved: The 8cm plank snaps into the baseline position.",
        },
        {
          'hud':
              "Task: DRAG the 5cm plank and CONNECT its left end to the left endpoint of the 8cm base plank.",
          'text':
              "Task: DRAG the 5cm plank and CONNECT its left end to the left endpoint of the 8cm base plank.\n\nObserved: The 5cm plank attaches to the base plank at a pivot point.",
        },
        {
          'hud':
              "Task: DRAG the 6cm plank and CONNECT its right end to the right endpoint of the 8cm base plank.",
          'text':
              "Task: DRAG the 6cm plank and CONNECT its right end to the right endpoint of the 8cm base plank.\n\nObserved: The 6cm plank attaches to the base plank at a pivot point.",
        },
        {
          'hud':
              "Task: CLICK and DRAG the free end of the 5cm plank upwards. At the same time, DRAG the free end of the 6cm plank upwards to make them meet.",
          'text':
              "Task: Now, CLICK and DRAG the free end of the 5cm plank upwards. At the same time, DRAG the free end of the 6cm plank upwards to make them meet.\n\nObserved: The free ends of the 5cm and 6cm planks meet and connect, forming a complete triangle.",
        },
      ],
      's1_sum': "It's a Triangle! Notice that 5 + 6 is greater than 8.",

      's2_title': "2. So Close, Yet So Far: An Impossible Triangle",
      's2_obj':
          "To attempt to construct a triangle and visually understand why it's impossible when the sum of two sides is less than the third.",
      's2_steps': [
        {
          'hud':
              "Task: DRAG the longest plank (8cm) and DROP it onto the horizontal baseline guide.",
          'text':
              "Task: You are given three planks of lengths 3cm, 4cm, and 8cm. DRAG the longest plank (8cm) and DROP it onto the horizontal baseline guide.\n\nObserved: The 8cm plank snaps into the baseline position.",
        },
        {
          'hud':
              "Task: DRAG the 3cm plank to the left endpoint, and the 4cm plank to the right endpoint.",
          'text':
              "Task: DRAG the 3cm plank and CONNECT its left end to the left endpoint of the 8cm base plank. Then, DRAG the 4cm plank and CONNECT its right end to the right endpoint.\n\nObserved: The 3cm and 4cm planks attach to the base plank at pivot points.",
        },
        {
          'hud':
              "Task: Try to form a triangle. CLICK and DRAG the free ends upwards to make them meet.",
          'text':
              "Task: Try to form a triangle. CLICK and DRAG the free ends of the 3cm and 4cm planks upwards to make them meet.\n\nObserved: The free ends of the 3cm and 4cm planks cannot meet, no matter how they are rotated. A gap remains.",
        },
      ],
      's2_sum': "They can't reach! Notice that 3 + 4 is less than 8.",

      's3_title': "3. The Tipping Point: The Collapsed Triangle",
      's3_obj':
          "To explore the edge case where the sum of two sides equals the third, resulting in a straight line.",
      's3_steps': [
        {
          'hud':
              "Task: DRAG the longest plank (7cm) and DROP it onto the horizontal baseline guide.",
          'text':
              "Task: You are given three planks of lengths 3cm, 4cm, and 7cm. DRAG the longest plank (7cm) and DROP it onto the horizontal baseline guide.\n\nObserved: The 7cm plank snaps into the baseline position.",
        },
        {
          'hud':
              "Task: DRAG the 3cm plank to the left endpoint, and the 4cm plank to the right endpoint.",
          'text':
              "Task: DRAG the 3cm plank and CONNECT its left end to the left endpoint of the 7cm base plank. Then, DRAG the 4cm plank and CONNECT its right end to the right endpoint.\n\nObserved: The 3cm and 4cm planks attach to the base plank at pivot points.",
        },
        {
          'hud':
              "Task: Try to form a triangle. CLICK and DRAG the free ends upwards to make them meet.",
          'text':
              "Task: Try to form a triangle. CLICK and DRAG the free ends of the 3cm and 4cm planks upwards to make them meet.\n\nObserved: The planks only meet when they are laid flat on top of the 7cm base plank, forming a straight line.",
        },
      ],
      's3_sum':
          "It's a straight line, not a triangle! This happens because 3 + 4 is exactly equal to 7.",

      's4_title': "4. The Isosceles Challenge",
      's4_obj':
          "Apply the learned concept to determine if an isosceles triangle can be formed with the given lengths.",
      's4_steps': [
        {
          'hud':
              "Task: Here are three planks with lengths 4cm, 4cm, and 6cm. Can you form a triangle? Use the baseline and pivot points to find out.",
          'text':
              "Task: Here are three planks with lengths 4cm, 4cm, and 6cm. Can you form a triangle? Use the baseline and pivot points to find out.\n\nObserved: The student successfully forms a triangle.",
        },
      ],
      's4_sum':
          "Correct! The sum of the two smaller sides (4 + 4 = 8) is greater than the third side (6).",

      's5_title': "5. The Slider Challenge: Find the Range",
      's5_obj':
          "To discover the range of possible lengths for a third side of a triangle when two sides are given.",
      's5_steps': [
        {
          'hud':
              "Task: DRAG the slider to change the length of the stretchy plank and find the range of lengths that can successfully form a closed triangle.",
          'text':
              "Task: We have fixed two sides of a potential triangle: a 5cm plank and a 9cm plank, hinged together. The third side is a special 'stretchy' plank. DRAG the slider to change the length of the stretchy plank and find the range of lengths that can successfully form a closed triangle.\n\nObserved: The student discovers that a triangle can only be formed when the third side's length is greater than 4cm and less than 14cm.",
        },
      ],
      's5_sum':
          "You found it! A triangle is possible when the third side is strictly between 4cm and 14cm.",
    },
    'hi': {
      'cm': "सेमी",
      'sliderLabel': "तीसरी भुजा की लंबाई",
      'appTitle': "त्रिभुज के अस्तित्व की खोज: त्रिभुज असमानता",
      'appSubtitle': "कक्षा 7 • ज्यामिति",
      'enterLab': "लैब में प्रवेश करें",
      'selectScenario': "दृश्य चुनें",
      'nextScenario': "अगली चुनौती",
      'stepLabel': "अवलोकन",
      'theory': "जांच नोट्स",
      'completed': "पूरा हुआ!",
      'successTitle': "ज्यामिति के उस्ताद!",
      'successDesc': "आपने त्रिभुज असमानता प्रमेय का सफलतापूर्वक पता लगाया।",
      'restartLab': "लैब फिर से शुरू करें",
      'analyzeBtn': "त्रुटि का विश्लेषण करें",
      'checkBtn': "मेरा काम जांचें",
      'doneTaskBtn': "मैं कर चुका हूँ",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",

      's1_title': "1. बिल्कुल सही फिट: एक संभव त्रिभुज",
      's1_obj':
          "दिए गए तीन रेखाखंडों से सफलतापूर्वक त्रिभुज बनाना और देखना कि भुजाएँ कैसे जुड़ती हैं।",
      's1_steps': [
        {
          'hud':
              "कार्य: सबसे लंबे तख्ते (8 सेमी) को खींचें और क्षैतिज आधार रेखा गाइड पर छोड़ दें।",
          'text':
              "कार्य: आपको 5 सेमी, 6 सेमी और 8 सेमी लंबाई वाले तीन लकड़ी के तख्ते दिए गए हैं। सबसे लंबे तख्ते (8 सेमी) को खींचें और क्षैतिज आधार रेखा गाइड पर छोड़ दें।\n\nदेखा गया: 8 सेमी का तख्ता आधार रेखा की स्थिति में आ जाता है।",
        },
        {
          'hud':
              "कार्य: 5 सेमी के तख्ते को खींचें और इसके बाएँ सिरे को 8 सेमी आधार तख्ते के बाएँ सिरे से जोड़ें।",
          'text':
              "कार्य: 5 सेमी के तख्ते को खींचें और इसके बाएँ सिरे को 8 सेमी आधार तख्ते के बाएँ सिरे से जोड़ें।\n\nदेखा गया: 5 सेमी का तख्ता एक धुरी बिंदु पर आधार तख्ते से जुड़ जाता है।",
        },
        {
          'hud':
              "कार्य: 6 सेमी के तख्ते को खींचें और इसके दाएँ सिरे को 8 सेमी आधार तख्ते के दाएँ सिरे से जोड़ें।",
          'text':
              "कार्य: 6 सेमी के तख्ते को खींचें और इसके दाएँ सिरे को 8 सेमी आधार तख्ते के दाएँ सिरे से जोड़ें।\n\nदेखा गया: 6 सेमी का तख्ता एक धुरी बिंदु पर आधार तख्ते से जुड़ जाता है।",
        },
        {
          'hud':
              "कार्य: 5 सेमी तख्ते के मुक्त सिरे पर क्लिक करें और उसे ऊपर की ओर खींचें। उसी समय 6 सेमी तख्ते के लिए भी ऐसा ही करें ताकि वे मिल सकें।",
          'text':
              "कार्य: अब, 5 सेमी तख्ते के मुक्त सिरे पर क्लिक करें और उसे ऊपर की ओर खींचें। उसी समय, 6 सेमी तख्ते के मुक्त सिरे को ऊपर की ओर खींचें ताकि वे मिल सकें।\n\nदेखा गया: 5 सेमी और 6 सेमी के तख्तों के मुक्त सिरे मिलते हैं और एक पूर्ण त्रिभुज बनाते हैं।",
        },
      ],
      's1_sum': "यह एक त्रिभुज है! ध्यान दें कि 5 + 6, 8 से अधिक है।",

      's2_title': "2. इतना करीब, फिर भी दूर: एक असंभव त्रिभुज",
      's2_obj':
          "त्रिभुज बनाने का प्रयास करना और यह समझना कि जब दो भुजाओं का योग तीसरी भुजा से कम हो तो यह असंभव क्यों है।",
      's2_steps': [
        {
          'hud':
              "कार्य: सबसे लंबे तख्ते (8 सेमी) को खींचें और क्षैतिज आधार रेखा गाइड पर छोड़ दें।",
          'text':
              "कार्य: आपको 3 सेमी, 4 सेमी और 8 सेमी लंबाई वाले तीन तख्ते दिए गए हैं। सबसे लंबे तख्ते (8 सेमी) को खींचें और क्षैतिज आधार रेखा गाइड पर छोड़ दें।\n\nदेखा गया: 8 सेमी का तख्ता आधार रेखा की स्थिति में आ जाता है।",
        },
        {
          'hud':
              "कार्य: 3 सेमी तख्ते को बाएँ सिरे पर और 4 सेमी तख्ते को दाएँ सिरे पर खींचें।",
          'text':
              "कार्य: 3 सेमी के तख्ते को खींचें और इसके बाएँ सिरे को 8 सेमी आधार तख्ते के बाएँ सिरे से जोड़ें। फिर, 4 सेमी के तख्ते को खींचें और दाएँ सिरे को दाएँ सिरे से जोड़ें।\n\nदेखा गया: 3 सेमी और 4 सेमी के तख्ते धुरी बिंदुओं पर आधार तख्ते से जुड़ जाते हैं।",
        },
        {
          'hud':
              "कार्य: त्रिभुज बनाने का प्रयास करें। मुक्त सिरों को मिलाने के लिए ऊपर की ओर खींचें।",
          'text':
              "कार्य: त्रिभुज बनाने का प्रयास करें। 3 सेमी और 4 सेमी तख्तों के मुक्त सिरों को मिलाने के लिए ऊपर की ओर खींचें।\n\nदेखा गया: 3 सेमी और 4 सेमी तख्तों के मुक्त सिरे नहीं मिल सकते, चाहे उन्हें कैसे भी घुमाया जाए। एक अंतर रहता है।",
        },
      ],
      's2_sum': "वे पहुँच नहीं सकते! ध्यान दें कि 3 + 4, 8 से कम है।",

      's3_title': "3. द टिपिंग पॉइंट: द कॉलेप्सड ट्रायंगल",
      's3_obj':
          "उस किनारे के मामले का पता लगाना जहां दो भुजाओं का योग तीसरी के बराबर होता है, जिसके परिणामस्वरूप एक सीधी रेखा बनती है।",
      's3_steps': [
        {
          'hud':
              "कार्य: सबसे लंबे तख्ते (7 सेमी) को खींचें और क्षैतिज आधार रेखा गाइड पर छोड़ दें।",
          'text':
              "कार्य: आपको 3 सेमी, 4 सेमी और 7 सेमी लंबाई वाले तीन तख्ते दिए गए हैं। सबसे लंबे तख्ते (7 सेमी) को खींचें और क्षैतिज आधार रेखा गाइड पर छोड़ दें।\n\nदेखा गया: 7 सेमी का तख्ता आधार रेखा की स्थिति में आ जाता है।",
        },
        {
          'hud':
              "कार्य: 3 सेमी तख्ते को बाएँ सिरे पर और 4 सेमी तख्ते को दाएँ सिरे पर खींचें।",
          'text':
              "कार्य: 3 सेमी के तख्ते को खींचें और इसके बाएँ सिरे को 7 सेमी आधार तख्ते के बाएँ सिरे से जोड़ें। फिर, 4 सेमी के तख्ते को खींचें और दाएँ सिरे को दाएँ सिरे से जोड़ें।\n\nदेखा गया: 3 सेमी और 4 सेमी के तख्ते धुरी बिंदुओं पर आधार तख्ते से जुड़ जाते हैं।",
        },
        {
          'hud':
              "कार्य: त्रिभुज बनाने का प्रयास करें। मुक्त सिरों को मिलाने के लिए ऊपर की ओर खींचें।",
          'text':
              "कार्य: त्रिभुज बनाने का प्रयास करें। 3 सेमी और 4 सेमी तख्तों के मुक्त सिरों को मिलाने के लिए ऊपर की ओर खींचें।\n\nदेखा गया: तख्ते केवल तभी मिलते हैं जब उन्हें 7 सेमी आधार तख्ते के ऊपर सपाट रखा जाता है, जिससे एक सीधी रेखा बनती है।",
        },
      ],
      's3_sum':
          "यह एक सीधी रेखा है, त्रिभुज नहीं! ऐसा इसलिए होता है क्योंकि 3 + 4 ठीक 7 के बराबर है।",

      's4_title': "4. समद्विबाहु चुनौती",
      's4_obj':
          "यह निर्धारित करने के लिए सीखे गए अवधारणा को लागू करें कि क्या दी गई लंबाई के साथ समद्विबाहु त्रिभुज बनाया जा सकता है।",
      's4_steps': [
        {
          'hud':
              "कार्य: यहाँ 4 सेमी, 4 सेमी और 6 सेमी लंबाई वाले तीन तख्ते हैं। क्या आप एक त्रिभुज बना सकते हैं?",
          'text':
              "कार्य: यहाँ 4 सेमी, 4 सेमी और 6 सेमी लंबाई वाले तीन तख्ते हैं। क्या आप एक त्रिभुज बना सकते हैं? पता लगाने के लिए आधार और धुरी बिंदुओं का उपयोग करें।\n\nदेखा गया: छात्र सफलतापूर्वक एक त्रिभुज बनाता है।",
        },
      ],
      's4_sum':
          "सही! दो छोटी भुजाओं का योग (4 + 4 = 8) तीसरी भुजा (6) से अधिक है।",

      's5_title': "5. स्लाइडर चुनौती: सीमा खोजें",
      's5_obj':
          "जब दो भुजाएँ दी गई हों तो त्रिभुज की तीसरी भुजा के लिए संभावित लंबाइयों की सीमा खोजना।",
      's5_steps': [
        {
          'hud':
              "कार्य: खिंचाव वाले तख्ते की लंबाई बदलने के लिए स्लाइडर को खींचें और लंबाइयों की वह सीमा खोजें जो सफलतापूर्वक एक बंद त्रिभुज बना सके।",
          'text':
              "कार्य: हमने एक संभावित त्रिभुज के दो किनारों को तय किया है। खिंचाव वाले तख्ते की लंबाई बदलने के लिए स्लाइडर को खींचें और लंबाइयों की वह सीमा खोजें जो सफलतापूर्वक एक बंद त्रिभुज बना सके।\n\nदेखा गया: छात्र को पता चलता है कि त्रिभुज केवल तभी बन सकता है जब तीसरी भुजा की लंबाई 4 सेमी से अधिक और 14 सेमी से कम हो।",
        },
      ],
      's5_sum':
          "आपने इसे पा लिया! एक त्रिभुज तब संभव है जब तीसरी भुजा 4 सेमी और 14 सेमी के बीच हो।",
    },
    'te': {
      'cm': "సెం.మీ",
      'sliderLabel': "మూడవ వైపు పొడవు",
      'appTitle': "త్రిభుజం ఉనికిని అన్వేషించడం: త్రిభుజ అసమానత",
      'appSubtitle': "7వ తరగతి • జ్యామితి",
      'enterLab': "ల్యాబ్‌లోకి ప్రవేశించండి",
      'selectScenario': "మిషన్ ఎంచుకోండి",
      'nextScenario': "తదుపరి సవాలు",
      'stepLabel': "పరిశీలన",
      'theory': "పరిశోధన గమనికలు",
      'completed': "పూర్తయింది!",
      'successTitle': "జ్యామితి మాస్టర్!",
      'successDesc':
          "మీరు త్రిభుజ అసమానత సిద్ధాంతాన్ని విజయవంతంగా అన్వేషించారు.",
      'restartLab': "ల్యాబ్‌ను పునఃప్రారంభించండి",
      'analyzeBtn': "లోపాన్ని విశ్లేషించండి",
      'checkBtn': "నా పనిని తనిఖీ చేయండి",
      'doneTaskBtn': "నేను పూర్తి చేసాను",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",

      's1_title': "1. పర్ఫెక్ట్ ఫిట్: సాధ్యమయ్యే త్రిభుజం",
      's1_obj':
          "ఇవ్వబడిన మూడు రేఖాఖండాల నుండి త్రిభుజాన్ని విజయవంతంగా నిర్మించడం మరియు భుజాలు ఎలా కనెక్ట్ అవుతాయో గమనించడం.",
      's1_steps': [
        {
          'hud':
              "పని: పొడవైన ప్లాంక్ (8సెం.మీ) ని లాగి, క్షితిజ సమాంతర బేస్‌లైన్ గైడ్‌పై వదలండి.",
          'text':
              "పని: మీకు 5సెం.మీ, 6సెం.మీ మరియు 8సెం.మీ పొడవు గల మూడు చెక్క ప్లాంక్‌లు ఇవ్వబడ్డాయి. పొడవైన ప్లాంక్ (8సెం.మీ) ని లాగి, స్క్రీన్ దిగువన ఉన్న క్షితిజ సమాంతర బేస్‌లైన్ గైడ్‌పై వదలండి.\n\nగమనించబడింది: 8సెం.మీ ప్లాంక్ బేస్‌లైన్ స్థానంలోకి స్నాప్ అవుతుంది.",
        },
        {
          'hud':
              "పని: 5సెం.మీ ప్లాంక్‌ని లాగి, దాని ఎడమ చివరను 8సెం.మీ బేస్ ప్లాంక్ ఎడమ ముగింపు బిందువుకు కనెక్ట్ చేయండి.",
          'text':
              "పని: 5సెం.మీ ప్లాంక్‌ని లాగి, దాని ఎడమ చివరను 8సెం.మీ బేస్ ప్లాంక్ ఎడమ ముగింపు బిందువుకు కనెక్ట్ చేయండి.\n\nగమనించబడింది: 5సెం.మీ ప్లాంక్ బేస్ ప్లాంక్‌కు పివోట్ పాయింట్ వద్ద జతచేయబడుతుంది.",
        },
        {
          'hud':
              "పని: 6సెం.మీ ప్లాంక్‌ని లాగి, దాని కుడి చివరను 8సెం.మీ బేస్ ప్లాంక్ కుడి ముగింపు బిందువుకు కనెక్ట్ చేయండి.",
          'text':
              "పని: 6సెం.మీ ప్లాంక్‌ని లాగి, దాని కుడి చివరను 8సెం.మీ బేస్ ప్లాంక్ కుడి ముగింపు బిందువుకు కనెక్ట్ చేయండి.\n\nగమనించబడింది: 6సెం.మీ ప్లాంక్ బేస్ ప్లాంక్‌కు పివోట్ పాయింట్ వద్ద జతచేయబడుతుంది.",
        },
        {
          'hud':
              "పని: 5సెం.మీ ప్లాంక్ యొక్క ఉచిత చివరను క్లిక్ చేసి పైకి లాగండి. అదే సమయంలో 6సెం.మీ ప్లాంక్ కోసం అదే చేయండి.",
          'text':
              "పని: ఇప్పుడు, 5సెం.మీ ప్లాంక్ యొక్క ఉచిత చివరను క్లిక్ చేసి పైకి లాగండి. అదే సమయంలో, వాటిని కలపడానికి 6సెం.మీ ప్లాంక్ యొక్క ఉచిత చివరను పైకి లాగండి.\n\nగమనించబడింది: 5సెం.మీ మరియు 6సెం.మీ ప్లాంక్‌ల ఉచిత చివరలు కలుస్తాయి మరియు కనెక్ట్ అవుతాయి, పూర్తి త్రిభుజాన్ని ఏర్పరుస్తాయి.",
        },
      ],
      's1_sum': "ఇది త్రిభుజం! 5 + 6 అనేది 8 కంటే ఎక్కువ అని గమనించండి.",

      's2_title': "2. చాలా దగ్గరగా, అయినప్పటికీ చాలా దూరం: అసాధ్యమైన త్రిభుజం",
      's2_obj':
          "త్రిభుజాన్ని నిర్మించడానికి ప్రయత్నించడం మరియు రెండు భుజాల మొత్తం మూడవది కంటే తక్కువగా ఉన్నప్పుడు అది ఎందుకు అసాధ్యమో దృశ్యమానంగా అర్థం చేసుకోవడం.",
      's2_steps': [
        {
          'hud':
              "పని: పొడవైన ప్లాంక్ (8సెం.మీ) ని లాగి, క్షితిజ సమాంతర బేస్‌లైన్ గైడ్‌పై వదలండి.",
          'text':
              "పని: మీకు 3సెం.మీ, 4సెం.మీ మరియు 8సెం.మీ పొడవు గల మూడు ప్లాంక్‌లు ఇవ్వబడ్డాయి. పొడవైన ప్లాంక్ (8సెం.మీ) ని లాగి, క్షితిజ సమాంతర బేస్‌లైన్ గైడ్‌పై వదలండి.\n\nగమనించబడింది: 8సెం.మీ ప్లాంక్ బేస్‌లైన్ స్థానంలోకి స్నాప్ అవుతుంది.",
        },
        {
          'hud':
              "పని: 3సెం.మీ ప్లాంక్‌ని ఎడమ ముగింపు బిందువుకు మరియు 4సెం.మీ ప్లాంక్‌ని కుడి ముగింపు బిందువుకు లాగండి.",
          'text':
              "పని: 3సెం.మీ ప్లాంక్‌ని లాగి, దాని ఎడమ చివరను 8సెం.మీ బేస్ ప్లాంక్ ఎడమ ముగింపు బిందువుకు కనెక్ట్ చేయండి. ఆపై, 4సెం.మీ ప్లాంక్‌ని లాగి, దాని కుడి చివరను కుడి ముగింపు బిందువుకు కనెక్ట్ చేయండి.\n\nగమనించబడింది: 3సెం.మీ మరియు 4సెం.మీ ప్లాంక్‌లు బేస్ ప్లాంక్‌కు పివోట్ పాయింట్ల వద్ద జతచేయబడతాయి.",
        },
        {
          'hud':
              "పని: త్రిభుజాన్ని ఏర్పరచడానికి ప్రయత్నించండి. ఉచిత చివరలను కలపడానికి పైకి లాగండి.",
          'text':
              "పని: త్రిభుజాన్ని ఏర్పరచడానికి ప్రయత్నించండి. 3సెం.మీ మరియు 4సెం.మీ ప్లాంక్‌ల ఉచిత చివరలను కలపడానికి పైకి లాగండి.\n\nగమనించబడింది: 3సెం.మీ మరియు 4సెం.మీ ప్లాంక్‌ల ఉచిత చివరలు, అవి ఎలా తిరిగినప్పటికీ, కలవలేవు. ఖాళీ మిగిలి ఉంది.",
        },
      ],
      's2_sum': "వాటిని చేరుకోలేవు! 3 + 4 అనేది 8 కంటే తక్కువ అని గమనించండి.",

      's3_title': "3. ద టిప్పింగ్ పాయింట్: కుప్పకూలిన త్రిభుజం",
      's3_obj':
          "రెండు భుజాల మొత్తం మూడవదికి సమానంగా ఉండే అంచు కేసును అన్వేషించడం, ఫలితంగా సరళ రేఖ వస్తుంది.",
      's3_steps': [
        {
          'hud':
              "పని: పొడవైన ప్లాంక్ (7సెం.మీ) ని లాగి, క్షితిజ సమాంతర బేస్‌లైన్ గైడ్‌పై వదలండి.",
          'text':
              "పని: మీకు 3సెం.మీ, 4సెం.మీ మరియు 7సెం.మీ పొడవు గల మూడు ప్లాంక్‌లు ఇవ్వబడ్డాయి. పొడవైన ప్లాంక్ (7సెం.మీ) ని లాగి, క్షితిజ సమాంతర బేస్‌లైన్ గైడ్‌పై వదలండి.\n\nగమనించబడింది: 7సెం.మీ ప్లాంక్ బేస్‌లైన్ స్థానంలోకి స్నాప్ అవుతుంది.",
        },
        {
          'hud':
              "పని: 3సెం.మీ ప్లాంక్‌ని ఎడమ ముగింపు బిందువుకు మరియు 4సెం.మీ ప్లాంక్‌ని కుడి ముగింపు బిందువుకు లాగండి.",
          'text':
              "పని: 3సెం.మీ ప్లాంక్‌ని లాగి, దాని ఎడమ చివరను 7సెం.మీ బేస్ ప్లాంక్ ఎడమ ముగింపు బిందువుకు కనెక్ట్ చేయండి. ఆపై, 4సెం.మీ ప్లాంక్‌ని లాగి, దాని కుడి చివరను కుడి ముగింపు బిందువుకు కనెక్ట్ చేయండి.\n\nగమనించబడింది: 3సెం.మీ మరియు 4సెం.మీ ప్లాంక్‌లు బేస్ ప్లాంక్‌కు పివోట్ పాయింట్ల వద్ద జతచేయబడతాయి.",
        },
        {
          'hud':
              "పని: త్రిభుజాన్ని ఏర్పరచడానికి ప్రయత్నించండి. ఉచిత చివరలను కలపడానికి పైకి లాగండి.",
          'text':
              "పని: త్రిభుజాన్ని ఏర్పరచడానికి ప్రయత్నించండి. 3సెం.మీ మరియు 4సెం.మీ ప్లాంక్‌ల ఉచిత చివరలను కలపడానికి పైకి లాగండి.\n\nగమనించబడింది: ప్లాంక్‌లు 7సెం.మీ బేస్ ప్లాంక్ పైన చదునుగా వేసినప్పుడు మాత్రమే కలుస్తాయి, సరళ రేఖను ఏర్పరుస్తాయి.",
        },
      ],
      's3_sum':
          "ఇది సరళ రేఖ, త్రిభుజం కాదు! ఇది జరుగుతుంది ఎందుకంటే 3 + 4 సరిగ్గా 7 కి సమానం.",

      's4_title': "4. ఐసోసెలిస్ ఛాలెంజ్",
      's4_obj':
          "ఇచ్చిన పొడవులతో ఐసోసెలిస్ త్రిభుజాన్ని నిర్మించవచ్చో లేదో తెలుసుకోవడానికి నేర్చుకున్న భావనను వర్తించండి.",
      's4_steps': [
        {
          'hud':
              "పని: ఇక్కడ 4సెం.మీ, 4సెం.మీ మరియు 6సెం.మీ పొడవు గల మూడు ప్లాంక్‌లు ఉన్నాయి. మీరు త్రిభుజాన్ని నిర్మించగలరా?",
          'text':
              "పని: ఇక్కడ 4సెం.మీ, 4సెం.మీ మరియు 6సెం.మీ పొడవు గల మూడు ప్లాంక్‌లు ఉన్నాయి. మీరు త్రిభుజాన్ని నిర్మించగలరా? తెలుసుకోవడానికి బేస్‌లైన్ మరియు పివోట్ పాయింట్‌లను ఉపయోగించండి.\n\nగమనించబడింది: విద్యార్థి త్రిభుజాన్ని విజయవంతంగా ఏర్పరుస్తాడు.",
        },
      ],
      's4_sum':
          "సరైనది! రెండు చిన్న భుజాల మొత్తం (4 + 4 = 8) మూడవ వైపు (6) కంటే ఎక్కువ.",

      's5_title': "5. స్లైడర్ ఛాలెంజ్: పరిధిని కనుగొనండి",
      's5_obj':
          "రెండు భుజాలు ఇవ్వబడినప్పుడు త్రిభుజం యొక్క మూడవ భుజం కోసం సాధ్యమయ్యే పొడవుల పరిధిని కనుగొనడం.",
      's5_steps': [
        {
          'hud':
              "పని: సాగే ప్లాంక్ యొక్క పొడవును మార్చడానికి స్లైడర్‌ని లాగండి మరియు మూసివేసిన త్రిభుజాన్ని విజయవంతంగా ఏర్పరిచే పొడవుల పరిధిని కనుగొనండి.",
          'text':
              "పని: సాగే ప్లాంక్ యొక్క పొడవును మార్చడానికి స్లైడర్‌ని లాగండి మరియు మూసివేసిన త్రిభుజాన్ని విజయవంతంగా ఏర్పరిచే పొడవుల పరిధిని కనుగొనండి.\n\nగమనించబడింది: మూడవ భుజం పొడవు 4సెం.మీ కంటే ఎక్కువ మరియు 14సెం.మీ కంటే తక్కువ ఉన్నప్పుడు మాత్రమే త్రిభుజం ఏర్పడుతుందని విద్యార్థి కనుగొన్నాడు.",
        },
      ],
      's5_sum':
          "మీరు దానిని కనుగొన్నారు! మూడవ భుజం ఖచ్చితంగా 4సెం.మీ మరియు 14సెం.మీ మధ్య ఉన్నప్పుడు త్రిభుజం సాధ్యమవుతుంది.",
    },
  };

  String getText(String key) => t[_lang]?[key] ?? t['en']![key] ?? key;

  Map<String, dynamic> _getScenarioConfig(int id) {
    return {
      'title': getText('s${id}_title'),
      'obj': getText('s${id}_obj'),
      'sum': getText('s${id}_sum'),
      'steps': t[_lang]?['s${id}_steps'] ?? t['en']!['s${id}_steps'],
    };
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _transformCtrl.value = Matrix4.identity()..translate(0.0, 60.0);
    _loadScenario(1);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  void playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _fullReset() {
    playSound(_sndError);
    setState(() {
      _lang = 'en';
      _isSidebarOpen = true;
      _isLocked = false;
      _transformCtrl.value = Matrix4.identity()..translate(0.0, 60.0);
      _showSuccessPopup = false;
      _showCurtain = true;
    });
    _loadScenario(1);
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _stepIndex = 0;
      _isTransitioning = false;
      _planks.clear();
      _draggedPlank = null;
      _rotatedPlank = null;
      _isLocked = false;

      if (id < 5) {
        _phase = 'wait_base';
        List<double> lengths = _scenarios[id]!['planks'];
        for (int i = 0; i < lengths.length; i++) {
          _planks.add(
            PlankData(
              id: 'p$i',
              len: lengths[i],
              type: 'tray',
              x: -180.0 + i * 180.0,
              y: -120.0,
              angle: 0,
            ),
          );
        }
      } else {
        _phase = 'idle';
        _s5SliderVal = 10.0;
      }
    });
    _syncStepWithPhase();
    if (!_showCurtain) playSound(_sndPop);
  }

  Offset _getWorldPosition(Offset globalPos) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPos = box.globalToLocal(globalPos);
    double cx = box.size.width / 2;
    double cy = box.size.height / 2;
    return Offset(localPos.dx - cx, localPos.dy - cy);
  }

  Map<String, Offset>? _getBaseNodes() {
    PlankData? basePlank;
    try {
      basePlank = _planks.firstWhere((p) => p.type == 'base');
    } catch (e) {
      return null;
    }
    double w = basePlank.len * pxPerCm;
    return {
      'left': Offset(basePlank.x - w / 2, basePlank.y),
      'right': Offset(basePlank.x + w / 2, basePlank.y),
    };
  }

  Offset _getPlankTip(PlankData p, Offset pivot) {
    double lenPx = p.len * pxPerCm;
    return Offset(
      pivot.dx + cos(p.angle) * lenPx,
      pivot.dy + sin(p.angle) * lenPx,
    );
  }

  String _checkTriangleValidity(double c, double b, double a) {
    if (b + a > c && b + c > a && a + c > b) return 'valid';
    if (b + a == c || b + c == a || a + c == b) return 'flat';
    return 'gap';
  }

  Offset? _calculateIntersection(double c, double b, double a) {
    if (_checkTriangleValidity(c, b, a) == 'gap') return null;
    double x = (b * b + c * c - a * a) / (2 * c);
    double h2 = b * b - x * x;
    double y = -sqrt(max(0, h2)); // Negative Y is UP
    return Offset(x, y);
  }

  bool _checkToolSnaps(Offset ptWorld) {
    if (_draggedPlank == null) return false;
    PlankData dp = _draggedPlank!;
    var cfg = _scenarios[_scenario]!;

    if (_phase == 'wait_base') {
      if (ptWorld.dx.abs() < 100 && (ptWorld.dy - baseY).abs() < 100) {
        if (cfg['sandbox'] == true || dp.len == cfg['reqBase']) {
          dp.type = 'base';
          dp.x = 0;
          dp.y = baseY;
          dp.angle = 0;
          _phase = 'wait_left';
          return true;
        }
      }
    } else if (_phase == 'wait_left') {
      var nodes = _getBaseNodes();
      if (nodes != null &&
          (ptWorld.dx - nodes['left']!.dx).abs() < 80 &&
          (ptWorld.dy - nodes['left']!.dy).abs() < 80) {
        if (cfg['sandbox'] == true || dp.len == cfg['reqLeft']) {
          dp.type = 'left';
          dp.x = nodes['left']!.dx;
          dp.y = nodes['left']!.dy;
          dp.angle = pi;
          _phase = 'wait_right';
          return true;
        }
      }
    } else if (_phase == 'wait_right') {
      var nodes = _getBaseNodes();
      if (nodes != null &&
          (ptWorld.dx - nodes['right']!.dx).abs() < 80 &&
          (ptWorld.dy - nodes['right']!.dy).abs() < 80) {
        if (cfg['sandbox'] == true || dp.len == cfg['reqRight']) {
          dp.type = 'right';
          dp.x = nodes['right']!.dx;
          dp.y = nodes['right']!.dy;
          dp.angle = 0;
          _phase = 'rotating';
          return true;
        }
      }
    }
    return false;
  }

  bool _checkIfHitPlank(Offset globalPos) {
    if (_isTransitioning || _scenario == 5) return false;
    Offset ptWorld = _getWorldPosition(globalPos);

    for (var p in _planks) {
      if (p.type == 'tray' &&
          (ptWorld.dx - p.x).abs() < (p.len * pxPerCm) / 2 &&
          (ptWorld.dy - p.y).abs() < 40) {
        return true;
      }
    }
    if (_phase == 'rotating') {
      var nodes = _getBaseNodes();
      if (nodes != null) {
        try {
          PlankData leftP = _planks.firstWhere((p) => p.type == 'left');
          Offset tipL = _getPlankTip(leftP, nodes['left']!);
          if ((ptWorld - tipL).distance < 50) return true;
        } catch (e) {
          /* ignore */
        }
        try {
          PlankData rightP = _planks.firstWhere((p) => p.type == 'right');
          Offset tipR = _getPlankTip(rightP, nodes['right']!);
          if ((ptWorld - tipR).distance < 50) return true;
        } catch (e) {
          /* ignore */
        }
      }
    }
    return false;
  }

  void _onPanDown(Offset globalPosition) {
    if (_isTransitioning || _scenario == 5) return;

    Offset ptWorld = _getWorldPosition(globalPosition);

    try {
      PlankData hitTray = _planks.firstWhere(
        (p) =>
            p.type == 'tray' &&
            (ptWorld.dx - p.x).abs() < (p.len * pxPerCm) / 2 &&
            (ptWorld.dy - p.y).abs() < 40,
      );
      setState(() {
        _draggedPlank = hitTray;
      });
      playSound(_sndTick);
      return;
    } catch (e) {
      /* ignore */
    }

    if (_phase == 'rotating') {
      var nodes = _getBaseNodes();
      if (nodes != null) {
        try {
          PlankData leftP = _planks.firstWhere((p) => p.type == 'left');
          Offset tipL = _getPlankTip(leftP, nodes['left']!);
          if ((ptWorld - tipL).distance < 50) {
            setState(() {
              _rotatedPlank = 'left';
            });
            return;
          }
        } catch (e) {
          /* ignore */
        }
        try {
          PlankData rightP = _planks.firstWhere((p) => p.type == 'right');
          Offset tipR = _getPlankTip(rightP, nodes['right']!);
          if ((ptWorld - tipR).distance < 50) {
            setState(() {
              _rotatedPlank = 'right';
            });
            return;
          }
        } catch (e) {
          /* ignore */
        }
      }
    }
  }

  void _onPanUpdate(Offset globalPosition) {
    Offset ptWorld = _getWorldPosition(globalPosition);

    if (_draggedPlank != null) {
      setState(() {
        _draggedPlank!.x = ptWorld.dx;
        _draggedPlank!.y = ptWorld.dy;
      });
    }

    if (_rotatedPlank != null) {
      var nodes = _getBaseNodes();
      if (nodes == null) return;

      PlankData p = _planks.firstWhere((pl) => pl.type == _rotatedPlank);
      Offset pivot = _rotatedPlank == 'left' ? nodes['left']! : nodes['right']!;

      double angle = atan2(ptWorld.dy - pivot.dy, ptWorld.dx - pivot.dx);
      if (angle > 0) angle = 0; // Clamp to upper hemisphere

      setState(() {
        p.angle = angle;
      });

      try {
        PlankData leftP = _planks.firstWhere((pl) => pl.type == 'left');
        PlankData rightP = _planks.firstWhere((pl) => pl.type == 'right');
        PlankData baseP = _planks.firstWhere((pl) => pl.type == 'base');

        String validity = _checkTriangleValidity(
          baseP.len,
          leftP.len,
          rightP.len,
        );

        if (validity == 'valid') {
          Offset? C = _calculateIntersection(baseP.len, leftP.len, rightP.len);
          if (C != null) {
            double targetAngleL = atan2(C.dy, C.dx);
            double targetAngleR = atan2(C.dy, C.dx - baseP.len);

            if ((leftP.angle - targetAngleL).abs() < 0.2 &&
                (rightP.angle - targetAngleR).abs() < 0.2) {
              setState(() {
                leftP.angle = targetAngleL;
                rightP.angle = targetAngleR;
                _rotatedPlank = null;
                _phase = 'complete';
              });
              playSound(_sndSuccess);
              _delayedProceed(() => _syncStepWithPhase());
            }
          }
        } else if (validity == 'gap') {
          if (leftP.angle < -0.3 &&
              rightP.angle > -2.8 &&
              rightP.angle < -0.3) {
            setState(() {
              _rotatedPlank = null;
              _phase = 'error_gap';
            });
            playSound(_sndError);
            _delayedProceed(() => _syncStepWithPhase());
          }
        } else if (validity == 'flat') {
          if (leftP.angle.abs() < 0.2 &&
              ((rightP.angle - pi).abs() < 0.2 ||
                  (rightP.angle + pi).abs() < 0.2)) {
            setState(() {
              leftP.angle = 0;
              rightP.angle = pi;
              _rotatedPlank = null;
              _phase = 'error_flat';
            });
            playSound(_sndSnap);
            _delayedProceed(() => _syncStepWithPhase());
          }
        }
      } catch (e) {
        /* ignore */
      }
    }
  }

  void _onPanEnd() {
    if (_draggedPlank != null) {
      Offset checkPos = Offset(_draggedPlank!.x, _draggedPlank!.y);
      String oldPhase = _phase;
      bool snapped = _checkToolSnaps(checkPos);

      setState(() {
        if (snapped) {
          playSound(_sndSnap);
          if (_phase != oldPhase) _delayedProceed(() => _syncStepWithPhase());
        } else {
          playSound(_sndError);
          int idx = _planks.indexOf(_draggedPlank!);
          _draggedPlank!.x = -180.0 + idx * 180.0;
          _draggedPlank!.y = -120.0;
        }
        _draggedPlank = null;
      });
    }
    setState(() {
      _rotatedPlank = null;
    });
  }

  void _delayedProceed(VoidCallback callback, {int ms = 1000}) {
    setState(() {
      _isTransitioning = true;
    });
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted) {
        setState(() {
          callback();
          _isTransitioning = false;
        });
      }
    });
  }

  void _syncStepWithPhase() {
    setState(() {
      if (_scenario == 1) {
        if (_phase == 'wait_base') {
          _stepIndex = 0;
        } else if (_phase == 'wait_left')
          _stepIndex = 1;
        else if (_phase == 'wait_right')
          _stepIndex = 2;
        else if (_phase == 'rotating')
          _stepIndex = 3;
        else if (_phase == 'complete' || _phase == 'analyzed')
          _stepIndex = 4;
      } else if (_scenario == 2 || _scenario == 3) {
        if (_phase == 'wait_base') {
          _stepIndex = 0;
        } else if (_phase == 'wait_left' || _phase == 'wait_right')
          _stepIndex = 1;
        else if (_phase == 'rotating')
          _stepIndex = 2;
        else if (_phase == 'error_gap' ||
            _phase == 'error_flat' ||
            _phase == 'analyzed')
          _stepIndex = 3;
      } else if (_scenario == 4) {
        if (_phase == 'complete' || _phase == 'analyzed') {
          _stepIndex = 1;
        } else {
          _stepIndex = 0;
        }
      } else if (_scenario == 5) {
        if (_phase == 'analyzed') {
          _stepIndex = 1;
        } else {
          _stepIndex = 0;
        }
      }
    });
  }

  void _triggerDone() {
    playSound(_sndSuccess);
    setState(() {
      _phase = 'analyzed';
    });
    _syncStepWithPhase();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSuccessPopup = true;
        });
      }
    });
  }

  void _triggerCheck() {
    playSound(_sndSuccess);
    setState(() {
      _phase = 'analyzed';
    });
    _syncStepWithPhase();
  }

  Widget _buildStepsList() {
    Map<String, dynamic> cfg = _getScenarioConfig(_scenario);
    List<dynamic> stepsList = cfg['steps'] ?? [];
    List<Widget> wList = [];

    // Theory Box
    wList.add(
      Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.straighten, color: Colors.indigoAccent),
                const SizedBox(width: 8),
                Text(
                  getText('theory'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              cfg['obj'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );

    // Iterating over structured steps
    for (int i = 0; i < stepsList.length; i++) {
      bool isPast = i < _stepIndex;
      bool isCurrent = i == _stepIndex;
      Color bg =
          isCurrent
              ? Colors.indigo.withValues(alpha: 0.15)
              : (isPast
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.transparent);
      Color border =
          isCurrent ? Colors.indigo.withValues(alpha: 0.5) : Colors.white12;
      Color textCol =
          isCurrent ? Colors.white : (isPast ? Colors.white38 : Colors.white54);

      Widget icon =
          isPast
              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
              : Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.indigoAccent : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );

      wList.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
            boxShadow:
                isCurrent
                    ? [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ]
                    : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${getText('stepLabel')} ${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPast ? stepsList[i]['text'] : stepsList[i]['hud'],
                      style: TextStyle(
                        fontSize: 14,
                        color: textCol,
                        height: 1.5,
                        decoration:
                            isPast
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
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

    // Completion Block
    if (_stepIndex >= stepsList.length) {
      wList.add(
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.greenAccent),
                  const SizedBox(width: 8),
                  Text(
                    getText('completed'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                cfg['sum'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: wList,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = max(300.0, screenWidth * 0.30);

    Map<String, dynamic> activeCfg = _getScenarioConfig(_scenario);
    List<dynamic> stepsList = activeCfg['steps'] ?? [];
    String activeObsText =
        _stepIndex < stepsList.length
            ? stepsList[_stepIndex]['text']
            : activeCfg['sum'];

    bool showAnalyze =
        (_scenario == 2 || _scenario == 3) &&
        (_phase == 'error_gap' || _phase == 'error_flat');
    bool showNext =
        _stepIndex >= stepsList.length && _scenario < 5 && _scenario != 4;
    bool showCheck =
        _scenario == 4 &&
        _stepIndex >= stepsList.length &&
        _phase != 'analyzed';
    if (_scenario == 4 && _phase == 'analyzed') showNext = true;
    bool showDone = _scenario == 5 && _phase != 'analyzed';

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap:
            () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Row Layout Side by side
            Row(
              children: [
                // Animated Sidebar Wrapper
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? sidebarWidth : 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      border: Border(right: BorderSide(color: Colors.white24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 20,
                          offset: Offset(5, 0),
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                60,
                                16,
                                16,
                              ), // Padding left 60 for menu icon space
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getText('appTitle'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    getText('appSubtitle'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      // Toggle Language Switch with Globe
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.indigoAccent.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.indigoAccent
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            playSound(_sndPop);
                                            setState(() {
                                              if (_lang == 'en') {
                                                _lang = 'hi';
                                              } else {
                                                _lang = 'en';
                                              }
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.language,
                                                  size: 18,
                                                  color: Colors.white70,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _lang.toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => _fullReset(),
                                        tooltip: 'Reset',
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.redAccent
                                              .withValues(alpha: 0.1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    getText('selectScenario').toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: DropdownButton<int>(
                                      value: _scenario,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF1E293B),
                                      underline: const SizedBox(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white70,
                                      ),
                                      items:
                                          [1, 2, 3, 4, 5]
                                              .map(
                                                (i) => DropdownMenuItem(
                                                  value: i,
                                                  child: Text(
                                                    getText('s${i}_title'),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          playSound(_sndPop);
                                          _loadScenario(v);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _buildStepsList(), // All instruction text restored in sidebar
                                ],
                              ),
                            ),
                            // Footer
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 30,
                              ),
                              color: Colors.black45,
                              alignment: Alignment.center,
                              child: Text(
                                getText('footer'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Expanded Canvas adjusts dynamically beside Sidebar
                Expanded(
                  child: Stack(
                    children: [
                      // Listener intercepts touches first, locking canvas interaction only when touching interactive planks!
                      Listener(
                        onPointerDown: (event) {
                          bool hit = _checkIfHitPlank(event.position);
                          if (hit != _isLocked) {
                            setState(() {
                              _isLocked = hit;
                            });
                          }
                          if (hit) {
                            _onPanDown(event.position);
                          }
                        },
                        onPointerMove: (event) {
                          if (_isLocked) {
                            _onPanUpdate(event.position);
                          }
                        },
                        onPointerUp: (event) {
                          if (_isLocked) {
                            _onPanEnd();
                          }
                          setState(() {
                            _isLocked = false;
                          });
                        },
                        onPointerCancel: (event) {
                          if (_isLocked) {
                            _onPanEnd();
                          }
                          setState(() {
                            _isLocked = false;
                          });
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return InteractiveViewer(
                              transformationController: _transformCtrl,
                              panEnabled:
                                  !_isLocked, // Canvas pans perfectly when not hitting a plank!
                              scaleEnabled:
                                  !_isLocked, // Canvas zooms perfectly when not hitting a plank!
                              minScale: 0.2,
                              maxScale: 4.0,
                              boundaryMargin: const EdgeInsets.all(
                                double.infinity,
                              ),
                              child: CustomPaint(
                                key: _canvasKey,
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: TriangleInequalityPainter(
                                  phase: _phase,
                                  planks: _planks,
                                  scenario: _scenario,
                                  s5SliderVal: _s5SliderVal,
                                  draggedPlank: _draggedPlank,
                                  pulseCtrl: _pulseCtrl,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // S5 Slider HUD (Overlay on Canvas Bottom)
                      if (_scenario == 5)
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 400,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.indigoAccent.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '1 ${getText('cm')}',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_s5SliderVal.toStringAsFixed(1)} ${getText('cm')}',
                                        style: const TextStyle(
                                          color: Colors.indigoAccent,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '20 ${getText('cm')}',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 8,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 12,
                                      ),
                                    ),
                                    child: Slider(
                                      value: _s5SliderVal,
                                      min: 1,
                                      max: 20,
                                      divisions: 190,
                                      activeColor:
                                          _checkTriangleValidity(
                                                    9,
                                                    5,
                                                    _s5SliderVal,
                                                  ) ==
                                                  'valid'
                                              ? Colors.green
                                              : Colors.redAccent,
                                      onChanged: (v) {
                                        setState(() {
                                          _s5SliderVal = v;
                                          _phase = 'rotating';
                                        });
                                        if (DateTime.now().millisecond % 10 ==
                                            0) {
                                          playSound(_sndTick);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    getText('sliderLabel'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Floating Action HUD on Canvas
                      if (showAnalyze || showCheck || showDone || showNext)
                        Positioned(
                          bottom: (_scenario == 5) ? 160 : 30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showAnalyze)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pinkAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    icon: const Icon(Icons.search),
                                    label: Text(
                                      getText('analyzeBtn'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      playSound(_sndPop);
                                      setState(() {
                                        _phase = 'analyzed';
                                        _syncStepWithPhase();
                                      });
                                    },
                                  ),
                                if (showAnalyze && showNext)
                                  const SizedBox(width: 16),
                                if (showCheck)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    icon: const Icon(Icons.check_circle),
                                    label: Text(
                                      getText('checkBtn'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _triggerCheck,
                                  ),
                                if (showDone)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigoAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    icon: const Icon(Icons.check_circle),
                                    label: Text(
                                      getText('doneTaskBtn'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _triggerDone,
                                  ),
                                if (showNext)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigoAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    icon: const Icon(Icons.arrow_forward),
                                    label: Text(
                                      getText('nextScenario'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      playSound(_sndPop);
                                      _loadScenario(_scenario + 1);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),

                      // Floating Draggable Active Step Panel Only appears when Sidebar is Closed
                      if (!_isSidebarOpen)
                        Positioned(
                          top: _obsBoxY,
                          left: _obsBoxX,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _obsBoxX += details.delta.dx;
                                _obsBoxY += details.delta.dy;
                              });
                            },
                            child: Container(
                              width: 280,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.indigo.withValues(alpha: 0.5),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.drag_indicator,
                                        size: 16,
                                        color: Colors.white54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${getText('stepLabel')} ${_stepIndex + 1}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigoAccent,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    activeObsText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      height: 1.4,
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
              ],
            ),

            // Absolute fixed Menu Icon on top left
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  playSound(_sndPop);
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.orange.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),

            // Curtain
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.change_history,
                            size: 80,
                            color: Colors.indigoAccent,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            getText('appTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            getText('appSubtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                            ),
                            icon: const Icon(Icons.play_circle_fill, size: 28),
                            label: Text(
                              getText('enterLab'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              playSound(_sndSuccess);
                              setState(() => _showCurtain = false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Success Popup
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5),
                          ),
                        ),
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  size: 80,
                                  color: Colors.amberAccent,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  getText('successTitle'),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  getText('successDesc'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
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
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    getText('restartLab'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    playSound(_sndClick);
                                    _fullReset();
                                  },
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                                onPressed:
                                    () => setState(
                                      () => _showSuccessPopup = false,
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
    );
  }
}

class TriangleInequalityPainter extends CustomPainter {
  final String phase;
  final List<PlankData> planks;
  final int scenario;
  final double s5SliderVal;
  final PlankData? draggedPlank;
  final AnimationController pulseCtrl;

  TriangleInequalityPainter({
    required this.phase,
    required this.planks,
    required this.scenario,
    required this.s5SliderVal,
    this.draggedPlank,
    required this.pulseCtrl,
  }) : super(repaint: pulseCtrl);

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Paint p,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      p,
    );
  }

  void _drawPlank(
    Canvas canvas,
    PlankData p,
    int colorIndex,
    bool isGhost,
    bool isCompleted,
  ) {
    List<List<Color>> colors = [
      [
        const Color(0xFFB45309),
        const Color(0xFF92400E),
        const Color(0xFFFCD34D),
      ], // Wood Amber
      [
        const Color(0xFF4F46E5),
        const Color(0xFF3730A3),
        const Color(0xFF818CF8),
      ], // Indigo
      [
        const Color(0xFFE11D48),
        const Color(0xFFBE123C),
        const Color(0xFFFB7185),
      ], // Rose
    ];

    if (isCompleted) {
      colors[colorIndex] = [
        const Color(0xFF10B981),
        const Color(0xFF059669),
        const Color(0xFF34D399),
      ]; // Green
    }

    Color cMain = colors[colorIndex][0];
    Color cDark = colors[colorIndex][1];
    Color cLight = colors[colorIndex][2];

    double w = p.len * _TriangleInequalityScreenState.pxPerCm;
    double h = 24;

    canvas.save();
    canvas.translate(p.x, p.y);

    if (p.type == 'tray' || p.type == 'base') {
      canvas.translate(-w / 2, 0);
    } else {
      canvas.rotate(p.angle);
    }

    Paint paintMain =
        Paint()..color = cMain.withValues(alpha: isGhost ? 0.3 : 1.0);
    Paint paintDark =
        Paint()..color = cDark.withValues(alpha: isGhost ? 0.3 : 1.0);
    Paint paintLight =
        Paint()
          ..color = cLight.withValues(alpha: isGhost ? 0.3 : 1.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    _drawRoundedRect(canvas, 0, -h / 2, w, h, 6, paintMain);
    _drawRoundedRect(canvas, 0, 0, w, h / 2, 6, paintDark);

    canvas.drawLine(
      Offset(6, -h / 2 + 4),
      Offset(w - 6, -h / 2 + 4),
      paintLight,
    );

    Paint grainPaint =
        Paint()
          ..color = cDark.withValues(alpha: isGhost ? 0.3 : 1.0)
          ..strokeWidth = 1;
    for (double i = 10; i < w - 10; i += 25) {
      canvas.drawLine(Offset(i, 0), Offset(i + 15, 0), grainPaint);
    }

    // Label
    canvas.save();
    canvas.translate(w / 2, 0);
    if (p.type == 'left' || p.type == 'right' || p.type == 'stretchy') {
      canvas.rotate(-p.angle);
    }

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: '${p.len.toStringAsFixed(p.type == 'stretchy' ? 1 : 0)} cm',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();

    // Pivots
    Paint pivotBg =
        Paint()
          ..color = const Color(
            0xFF1E293B,
          ).withValues(alpha: isGhost ? 0.3 : 1.0);
    Paint pivotFg =
        Paint()
          ..color = const Color(
            0xFF94A3B8,
          ).withValues(alpha: isGhost ? 0.3 : 1.0);

    if (p.type != 'tray') {
      canvas.drawCircle(Offset.zero, 6, pivotBg);
      canvas.drawCircle(Offset.zero, 3, pivotFg);
    }
    if (p.type == 'base' || p.type == 'stretchy') {
      canvas.drawCircle(Offset(w, 0), 6, pivotBg);
      canvas.drawCircle(Offset(w, 0), 3, pivotFg);
    }

    if ((p.type == 'left' || p.type == 'right') &&
        phase == 'rotating' &&
        !isCompleted) {
      double pulse = 1 + sin(DateTime.now().millisecondsSinceEpoch / 150) * 0.1;
      canvas.drawCircle(
        Offset(w, 0),
        16 * pulse,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
      canvas.drawCircle(
        Offset(w, 0),
        16 * pulse,
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      canvas.drawCircle(Offset(w, 0), 6, Paint()..color = Colors.blueAccent);
    }

    canvas.restore();
  }

  String _checkValidity(double c, double b, double a) {
    if (b + a > c && b + c > a && a + c > b) return 'valid';
    if (b + a == c || b + c == a || a + c == b) return 'flat';
    return 'gap';
  }

  Offset? _calcIntersect(double c, double b, double a) {
    if (_checkValidity(c, b, a) == 'gap') return null;
    double x = (b * b + c * c - a * a) / (2 * c);
    double h2 = b * b - x * x;
    return Offset(x, -sqrt(max(0, h2)));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect backgroundRect = Rect.fromLTWH(
      -8000,
      -8000,
      size.width + 16000,
      size.height + 16000,
    );
    canvas.drawRect(backgroundRect, Paint()..color = const Color(0xFF090E17));

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);

    // Grid
    final Paint gridPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 1;
    for (
      double i = -4000;
      i < 4000;
      i += _TriangleInequalityScreenState.pxPerCm
    ) {
      canvas.drawLine(Offset(i, -4000), Offset(i, 4000), gridPaint);
      canvas.drawLine(Offset(-4000, i), Offset(4000, i), gridPaint);
    }

    double baseY = _TriangleInequalityScreenState.baseY;

    if (scenario < 5) {
      if (phase == 'wait_base') {
        double reqBase = 8.0;
        if (scenario == 3) reqBase = 7.0;
        if (scenario == 4) reqBase = 6.0;
        double w = reqBase * _TriangleInequalityScreenState.pxPerCm;
        Paint dashPaint =
            Paint()
              ..color = Colors.indigoAccent
              ..strokeWidth = 4;
        for (double i = -w / 2; i < w / 2; i += 20) {
          canvas.drawLine(
            Offset(i, baseY),
            Offset(min(i + 10, w / 2), baseY),
            dashPaint,
          );
        }
        _drawRoundedRect(
          canvas,
          -w / 2 - 10,
          baseY - 20,
          w + 20,
          40,
          10,
          Paint()..color = Colors.indigoAccent.withValues(alpha: 0.2),
        );
      }

      bool isCompleted = (phase == 'complete' || phase == 'analyzed');

      PlankData? baseP;
      try {
        baseP = planks.firstWhere((p) => p.type == 'base');
      } catch (e) {
        /* ignore */
      }
      if (baseP != null) _drawPlank(canvas, baseP, 0, false, isCompleted);

      if (baseP != null) {
        double w = baseP.len * _TriangleInequalityScreenState.pxPerCm;
        Offset nLeft = Offset(baseP.x - w / 2, baseP.y);
        Offset nRight = Offset(baseP.x + w / 2, baseP.y);

        PlankData? leftP;
        try {
          leftP = planks.firstWhere((p) => p.type == 'left');
        } catch (e) {
          /* ignore */
        }
        PlankData? rightP;
        try {
          rightP = planks.firstWhere((p) => p.type == 'right');
        } catch (e) {
          /* ignore */
        }

        if (isCompleted &&
            (scenario == 1 || scenario == 4) &&
            leftP != null &&
            rightP != null) {
          Offset? C = _calcIntersect(baseP.len, leftP.len, rightP.len);
          if (C != null) {
            Path path =
                Path()
                  ..moveTo(nLeft.dx, nLeft.dy)
                  ..lineTo(nRight.dx, nRight.dy)
                  ..lineTo(
                    nLeft.dx + C.dx * _TriangleInequalityScreenState.pxPerCm,
                    nLeft.dy + C.dy * _TriangleInequalityScreenState.pxPerCm,
                  )
                  ..close();
            canvas.drawPath(
              path,
              Paint()..color = Colors.greenAccent.withValues(alpha: 0.2),
            );
            canvas.drawPath(
              path,
              Paint()
                ..color = Colors.greenAccent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4,
            );
          }
        }

        if (phase == 'rotating') {
          Paint arcPaint =
              Paint()
                ..color = Colors.indigoAccent.withValues(alpha: 0.3)
                ..strokeWidth = 2
                ..style = PaintingStyle.stroke;
          // Dashed arcs simulation
          if (leftP != null) {
            canvas.drawArc(
              Rect.fromCircle(
                center: nLeft,
                radius: leftP.len * _TriangleInequalityScreenState.pxPerCm,
              ),
              0,
              -pi,
              false,
              arcPaint,
            );
          }
          if (rightP != null) {
            canvas.drawArc(
              Rect.fromCircle(
                center: nRight,
                radius: rightP.len * _TriangleInequalityScreenState.pxPerCm,
              ),
              0,
              -pi,
              false,
              arcPaint,
            );
          }

          String validity = _checkValidity(
            baseP.len,
            leftP?.len ?? 0,
            rightP?.len ?? 0,
          );
          if ((validity == 'gap' || validity == 'flat') &&
              leftP != null &&
              rightP != null) {
            Offset tipL = Offset(
              nLeft.dx +
                  cos(leftP.angle) *
                      leftP.len *
                      _TriangleInequalityScreenState.pxPerCm,
              nLeft.dy +
                  sin(leftP.angle) *
                      leftP.len *
                      _TriangleInequalityScreenState.pxPerCm,
            );
            Offset tipR = Offset(
              nRight.dx +
                  cos(rightP.angle) *
                      rightP.len *
                      _TriangleInequalityScreenState.pxPerCm,
              nRight.dy +
                  sin(rightP.angle) *
                      rightP.len *
                      _TriangleInequalityScreenState.pxPerCm,
            );
            double pulse =
                0.5 +
                (sin(DateTime.now().millisecondsSinceEpoch / 200).abs()) * 0.5;
            Paint gapPaint =
                Paint()
                  ..color = Colors.redAccent.withValues(alpha: pulse)
                  ..strokeWidth = 4;
            canvas.drawLine(tipL, tipR, gapPaint);
          }
        }

        if (leftP != null) {
          leftP.x = nLeft.dx;
          leftP.y = nLeft.dy;
          _drawPlank(canvas, leftP, 1, false, isCompleted);
        }
        if (rightP != null) {
          rightP.x = nRight.dx;
          rightP.y = nRight.dy;
          _drawPlank(canvas, rightP, 2, false, isCompleted);
        }

        if (phase == 'error_gap' ||
            phase == 'error_flat' ||
            phase == 'analyzed') {
          if (leftP != null &&
              rightP != null &&
              (scenario == 2 || scenario == 3)) {
            Offset tipL = Offset(
              nLeft.dx +
                  cos(leftP.angle) *
                      leftP.len *
                      _TriangleInequalityScreenState.pxPerCm,
              nLeft.dy +
                  sin(leftP.angle) *
                      leftP.len *
                      _TriangleInequalityScreenState.pxPerCm,
            );
            Offset tipR = Offset(
              nRight.dx +
                  cos(rightP.angle) *
                      rightP.len *
                      _TriangleInequalityScreenState.pxPerCm,
              nRight.dy +
                  sin(rightP.angle) *
                      rightP.len *
                      _TriangleInequalityScreenState.pxPerCm,
            );
            double pulse =
                0.5 +
                (sin(DateTime.now().millisecondsSinceEpoch / 200).abs()) * 0.5;
            Paint errPaint =
                Paint()
                  ..color =
                      (phase == 'error_gap' || scenario == 2)
                          ? Colors.redAccent.withValues(alpha: pulse)
                          : Colors.greenAccent.withValues(alpha: pulse)
                  ..strokeWidth = 4;
            canvas.drawLine(tipL, tipR, errPaint);
          }
        }
      }

      for (PlankData p in planks.where(
        (pl) => pl.type == 'tray' && pl != draggedPlank,
      )) {
        _drawPlank(canvas, p, 0, false, false);
      }

      if (draggedPlank != null) {
        _drawPlank(canvas, draggedPlank!, 0, false, false);
      }
    } else {
      // Scenario 5
      double b = 5, c = 9, a = s5SliderVal;
      double cPx = c * _TriangleInequalityScreenState.pxPerCm;
      String validity = _checkValidity(c, b, a);
      bool isCompleted =
          ((phase == 'complete' || phase == 'analyzed') && validity == 'valid');

      PlankData baseP = PlankData(
        id: 's5b',
        len: c,
        type: 'base',
        x: 0,
        y: baseY,
        angle: 0,
      );
      _drawPlank(canvas, baseP, 0, false, isCompleted);

      Offset nLeft = Offset(-cPx / 2, baseY);
      Offset nRight = Offset(cPx / 2, baseY);

      PlankData leftP = PlankData(
        id: 's5l',
        len: b,
        type: 'left',
        x: nLeft.dx,
        y: nLeft.dy,
        angle: 0,
      );
      PlankData rightP = PlankData(
        id: 's5r',
        len: a,
        type: 'stretchy',
        x: nRight.dx,
        y: nRight.dy,
        angle: 0,
      );

      if (validity == 'valid') {
        Offset? C = _calcIntersect(c, b, a);
        if (C != null) {
          leftP.angle = atan2(C.dy, C.dx);
          rightP.angle = atan2(C.dy, C.dx - c);
          Path path =
              Path()
                ..moveTo(nLeft.dx, nLeft.dy)
                ..lineTo(nRight.dx, nRight.dy)
                ..lineTo(
                  nLeft.dx + C.dx * _TriangleInequalityScreenState.pxPerCm,
                  nLeft.dy + C.dy * _TriangleInequalityScreenState.pxPerCm,
                )
                ..close();
          canvas.drawPath(
            path,
            Paint()..color = Colors.greenAccent.withValues(alpha: 0.15),
          );
          canvas.drawPath(
            path,
            Paint()
              ..color = Colors.greenAccent.withValues(alpha: 0.6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }
      } else {
        if (a + b <= c) {
          leftP.angle = 0;
          rightP.angle = pi;
        } else if (a - b >= c) {
          leftP.angle = pi;
          rightP.angle = pi;
        } else if (b - a >= c) {
          leftP.angle = 0;
          rightP.angle = 0;
        }

        Offset tipL = Offset(
          nLeft.dx +
              cos(leftP.angle) *
                  leftP.len *
                  _TriangleInequalityScreenState.pxPerCm,
          nLeft.dy +
              sin(leftP.angle) *
                  leftP.len *
                  _TriangleInequalityScreenState.pxPerCm,
        );
        Offset tipR = Offset(
          nRight.dx +
              cos(rightP.angle) *
                  rightP.len *
                  _TriangleInequalityScreenState.pxPerCm,
          nRight.dy +
              sin(rightP.angle) *
                  rightP.len *
                  _TriangleInequalityScreenState.pxPerCm,
        );
        canvas.drawLine(
          tipL,
          tipR,
          Paint()
            ..color = Colors.redAccent
            ..strokeWidth = 4,
        );
      }

      _drawPlank(canvas, leftP, 1, false, isCompleted);
      _drawPlank(canvas, rightP, 2, false, isCompleted);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TriangleInequalityPainter oldDelegate) => true;
}
