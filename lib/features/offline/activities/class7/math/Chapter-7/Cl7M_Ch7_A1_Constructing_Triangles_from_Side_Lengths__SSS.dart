// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
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
      home: const TriangleLabScreen(),
    );
  }
}

class TriangleLabScreen extends StatefulWidget {
  const TriangleLabScreen({super.key});

  @override
  State<TriangleLabScreen> createState() => _TriangleLabScreenState();
}

class _TriangleLabScreenState extends State<TriangleLabScreen>
    with TickerProviderStateMixin {
  // Constants
  static const double pxPerCm = 30.0;
  static const double baseY = 80.0;

  // App State variables
  String _lang = 'en';
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;

  // Draggable observation box state
  double _obsBoxX = 16.0;
  double _obsBoxY = 80.0;

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
  final String _sndDraw =
      'audio/class7/mixkit_2567.mp3';

  int _scenario = 1;
  int _stepIndex = 0;
  String _phase = 'idle';

  List<double> _availableLengths = [];
  double _targetBase = 0;
  double _targetArcA = 0;
  double _targetArcB = 0;
  double _drawProgress = 0;
  double _arcProgress = 0;
  double _lineProgress = 0;
  double _tempRadius = 1;

  bool _isDrawingAction = false;
  Offset? _lastDrawPt;

  final Map<int, Map<String, dynamic>> _scenarios = {
    1: {
      'lengths': [6.0],
      'reqBase': 6.0,
      'reqArcA': 6.0,
      'reqArcB': 6.0,
    },
    2: {
      'lengths': [8.0, 5.0, 6.0],
      'reqBase': 8.0,
      'reqArcA': 5.0,
      'reqArcB': 6.0,
    },
    3: {
      'lengths': [8.0, 3.0, 4.0],
      'reqBase': 8.0,
      'reqArcA': 3.0,
      'reqArcB': 4.0,
    },
    4: {
      'lengths': [7.0, 7.0, 5.0],
    },
    5: {
      'lengths': [10.0, 6.0, 4.0],
    },
  };

  // Exhaustive Translations Map matching HTML precisely
  final Map<String, Map<String, dynamic>> t = {
    'en': {
      'cm': "cm",
      'radiusLabel': "Radius:",
      'adjustTarget': "Adjust to target radius",
      'appTitle': "Constructing Triangles from Side Lengths (SSS)",
      'appSubtitle': "Class 7 • A Tale of Three Intersecting Lines",
      'enterLab': "Enter Lab",
      'selectScenario': "Select Scenario",
      'nextScenario': "Next Challenge",
      'stepLabel': "OBSERVATION",
      'theory': "Construction Rules",
      'completed': "Completed!",
      'successTitle': "Geometry Master!",
      'successDesc':
          "You successfully explored the SSS construction rules and the Triangle Inequality Theorem.",
      'restartLab': "Restart Lab",
      'analyzeBtn': "Analyze Error",
      'checkBtn': "Check My Work",
      'doneTaskBtn': "I'm Done",
      'selectLenBase': "Select Base Length:",
      'selectLenRadius': "Select Arc Radius:",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",

      's1_title': "1. The Perfect Triangle (Equilateral Construction)",
      's1_obj':
          "To construct an equilateral triangle with sides of 6 cm, demonstrating the basic SSS construction method where all arcs have the same radius.",
      's1_steps': [
        {
          'hud':
              "Task: From the toolbox, DRAG the Ruler onto the canvas. CLICK '0' and DRAG to draw the base.",
          'text':
              "Task: From the toolbox, DRAG the Ruler onto the canvas. CLICK on the ruler's '0' mark and DRAG the pencil tool to the '6 cm' mark to draw the base of the triangle. The endpoints will be automatically labeled 'A' and 'B'.\n\nObserved: A straight line segment labeled 'AB' of length 6 cm is present on the canvas.",
        },
        {
          'hud':
              "Task: DRAG the Compass from the toolbox and DROP it onto vertex 'A'. CLICK the compass's adjustment slider and DRAG it until the display reads 'Radius: 6 cm'.",
          'text':
              "Task: DRAG the Compass from the toolbox and DROP it onto vertex 'A'. CLICK the compass's adjustment slider and DRAG it until the display reads 'Radius: 6 cm'.\n\nObserved: The compass is anchored at point A, and its pencil end is set at a distance of 6 cm from the needle point.",
        },
        {
          'hud':
              "Task: CLICK and DRAG the pencil end of the compass to DRAW a wide arc above the line segment AB.",
          'text':
              "Task: CLICK and DRAG the pencil end of the compass to DRAW a wide arc above the line segment AB.\n\nObserved: A smooth, curved arc is drawn on the canvas, representing all points that are 6 cm away from vertex A.",
        },
        {
          'hud':
              "Task: DRAG the Compass and DROP it onto vertex 'B'. The radius is already set to 6 cm. CLICK and DRAG to DRAW the second arc.",
          'text':
              "Task: DRAG the Compass and DROP it onto vertex 'B'. The radius is already set to 6 cm. CLICK and DRAG the pencil end to DRAW a second arc that intersects the first one.\n\nObserved: A second arc is drawn from vertex B, clearly intersecting the first arc at a single point.",
        },
        {
          'hud':
              "Task: DRAG the Ruler tool and CONNECT vertex A to vertex C. Then, CONNECT vertex B to vertex C.",
          'text':
              "Task: DRAG the Ruler tool and CONNECT vertex A to vertex C. Then, CONNECT vertex B to vertex C.\n\nObserved: The triangle ABC is complete. All three sides are 6 cm, forming a perfect equilateral triangle.",
        },
      ],
      's1_sum':
          "You have successfully built an equilateral triangle. Notice how the two arcs, each with a radius equal to the base length, met at exactly the right spot to form the third vertex. This method guarantees all three sides are equal.",

      's2_title': "2. The Everyday Triangle",
      's2_obj':
          "To construct a scalene triangle with sides 8 cm, 5 cm, and 6 cm, demonstrating the SSS construction with different side lengths.",
      's2_steps': [
        {
          'hud':
              "Task: DRAG the Ruler to the canvas. DRAW the longest side, 8 cm, as the base. Label the endpoints 'X' and 'Y'.",
          'text':
              "Task: DRAG the Ruler to the canvas. DRAW the longest side, 8 cm, as the base. Label the endpoints 'X' and 'Y'.\n\nObserved: A line segment 'XY' of 8 cm is on the canvas.",
        },
        {
          'hud':
              "Task: DRAG the Compass to vertex 'X'. SET its radius to 5 cm using the slider. DRAW a wide arc above the base.",
          'text':
              "Task: DRAG the Compass to vertex 'X'. SET its radius to 5 cm using the slider. DRAW a wide arc above the base.\n\nObserved: An arc representing all points 5 cm from X is drawn.",
        },
        {
          'hud':
              "Task: DRAG the Compass to vertex 'Y'. SET its radius to 6 cm. DRAW a second arc to intersect the first one.",
          'text':
              "Task: DRAG the Compass to vertex 'Y'. SET its radius to 6 cm. DRAW a second arc to intersect the first one.\n\nObserved: A second arc, representing all points 6 cm from Y, is drawn and intersects the red arc.",
        },
        {
          'hud':
              "Task: Use the Ruler tool to CONNECT X to Z, and Y to Z to complete the triangle.",
          'text':
              "Task: Use the Ruler tool to CONNECT X to Z, and Y to Z to complete the triangle.\n\nObserved: A valid scalene triangle XYZ is formed with sides 8 cm, 5 cm, and 6 cm.",
        },
      ],
      's2_sum':
          "You've built a scalene triangle. The third vertex 'Z' had to be exactly 5 cm from X AND 6 cm from Y. The only place this is possible is where the two arcs cross.",

      's3_title': "3. The Impossible Triangle",
      's3_obj':
          "To attempt to construct a triangle with sides 8 cm, 3 cm, and 4 cm, and to visually discover why it is impossible.",
      's3_steps': [
        {
          'hud':
              "Task: Using the Ruler, DRAW the longest side, 8 cm, as the base. Label the endpoints 'P' and 'Q'.",
          'text':
              "Task: Using the Ruler, DRAW the longest side, 8 cm, as the base. Label the endpoints 'P' and 'Q'.\n\nObserved: A line segment 'PQ' of 8 cm is on the canvas.",
        },
        {
          'hud':
              "Task: DRAG the Compass to vertex 'P'. SET its radius to 3 cm. DRAW a full arc above the base.",
          'text':
              "Task: DRAG the Compass to vertex 'P'. SET its radius to 3 cm. DRAW a full arc above the base.\n\nObserved: An arc representing all points 3 cm from P is drawn.",
        },
        {
          'hud':
              "Task: DRAG the Compass to vertex 'Q'. SET its radius to 4 cm. DRAW a full arc above the base.",
          'text':
              "Task: DRAG the Compass to vertex 'Q'. SET its radius to 4 cm. DRAW a full arc above the base.\n\nObserved: A second arc is drawn, but it does not touch or cross the first arc. There is a visible gap between them.",
        },
        {
          'hud':
              "Task: Observe the two arcs. CLICK the 'Analyze Error' button that appears.",
          'text':
              "Task: Observe the two arcs. CLICK the 'Analyze Error' button that appears.\n\nObserved: An animation explains the failure. 3 cm + 4 cm = 7 cm.",
        },
      ],
      's3_sum':
          "The construction failed because the arcs did not intersect. This happens when the sum of the two shorter sides is less than the longest side. You have discovered the Triangle Inequality rule!",

      's4_title': "4. The Symmetrical Challenge",
      's4_obj':
          "You are given three side lengths: 7 cm, 7 cm, and 5 cm. Use the tools to independently construct the triangle.",
      's4_steps': [
        {
          'hud':
              "Task: Here are your side lengths: 7 cm, 7 cm, 5 cm. Your mission is to build the triangle. DRAG the tools from the toolbox and construct the triangle on the canvas.",
          'text':
              "Task: Here are your side lengths: 7 cm, 7 cm, 5 cm. Your mission is to build the triangle. DRAG the tools from the toolbox and construct the triangle on the canvas.\n\nObserved: You successfully managed the tools and constructed an isosceles triangle.",
        },
      ],
      's4_sum':
          "Great job! You successfully constructed the isosceles triangle on your own.",

      's5_title': "5. The Gap Challenge",
      's5_obj':
          "You are given three side lengths: 10 cm, 4 cm, and 6 cm. Can you build a triangle? Try it.",
      's5_steps': [
        {
          'hud':
              "Task: Your side lengths are 10 cm, 4 cm, and 6 cm. Use the Ruler and Compass to attempt the construction. What do you discover? CLICK 'I'm Done' when you have your answer.",
          'text':
              "Task: Your side lengths are 10 cm, 4 cm, and 6 cm. Use the Ruler and Compass to attempt the construction. What do you discover? CLICK 'I'm Done' when you have your answer.\n\nObserved: The user attempts the construction and finds that the arcs do not intersect to form a 2D shape.",
        },
      ],
      's5_sum':
          "4 cm + 6 cm = 10 cm. The two shorter sides are just long enough to touch each other, but only by lying flat on the longest side. This forms a straight line, not a triangle.",
    },
    'hi': {
      'cm': "सेमी",
      'radiusLabel': "त्रिज्या:",
      'adjustTarget': "लक्ष्य त्रिज्या में समायोजित करें",
      'appTitle': "भुजाओं की लंबाई से त्रिभुज बनाना (SSS)",
      'appSubtitle': "कक्षा 7 • तीन प्रतिच्छेदी रेखाओं की कहानी",
      'enterLab': "लैब में प्रवेश करें",
      'selectScenario': "दृश्य चुनें",
      'nextScenario': "अगली चुनौती",
      'stepLabel': "अवलोकन",
      'theory': "निर्माण के नियम",
      'completed': "पूरा हुआ!",
      'successTitle': "ज्यामिति के उस्ताद!",
      'successDesc':
          "आपने SSS निर्माण नियमों और त्रिभुज असमानता प्रमेय का सफलतापूर्वक पता लगाया।",
      'restartLab': "लैब फिर से शुरू करें",
      'analyzeBtn': "त्रुटि का विश्लेषण करें",
      'checkBtn': "मेरा काम जांचें",
      'doneTaskBtn': "मैं कर चुका हूँ",
      'selectLenBase': "आधार की लंबाई चुनें:",
      'selectLenRadius': "चाप की त्रिज्या चुनें:",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",

      's1_title': "1. आदर्श त्रिभुज (समबाहु निर्माण)",
      's1_obj':
          "6 सेमी भुजाओं वाले एक समबाहु त्रिभुज की रचना करना, मूल SSS निर्माण विधि को प्रदर्शित करना।",
      's1_steps': [
        {
          'hud':
              "कार्य: टूलबॉक्स से शासक (Ruler) को कैनवास पर खींचें। '0' पर क्लिक करें और आधार खींचने के लिए खींचें।",
          'text':
              "कार्य: टूलबॉक्स से शासक (Ruler) को कैनवास पर खींचें। '0' पर क्लिक करें और आधार खींचने के लिए खींचें।\n\nदेखा गया: कैनवास पर 6 सेमी का एक सीधा रेखाखंड AB खींचा गया है।",
        },
        {
          'hud':
              "कार्य: कंपास को टूलबॉक्स से खींचें और शीर्ष 'A' पर छोड़ दें। एडजस्टमेंट स्लाइडर पर क्लिक करें और इसे तब तक खींचें जब तक कि डिस्प्ले में 'त्रिज्या: 6 सेमी' न आ जाए।",
          'text':
              "कार्य: कंपास को टूलबॉक्स से खींचें और शीर्ष 'A' पर छोड़ दें। एडजस्टमेंट स्लाइडर पर क्लिक करें और इसे तब तक खींचें जब तक कि डिस्प्ले में 'त्रिज्या: 6 सेमी' न आ जाए।\n\nदेखा गया: कंपास बिंदु A पर स्थित है, और इसका पेंसिल सिरा 6 सेमी की दूरी पर सेट है।",
        },
        {
          'hud':
              "कार्य: रेखाखंड AB के ऊपर एक चौड़ा चाप खींचने के लिए कंपास के पेंसिल सिरे पर क्लिक करें और खींचें।",
          'text':
              "कार्य: रेखाखंड AB के ऊपर एक चौड़ा चाप खींचने के लिए कंपास के पेंसिल सिरे पर क्लिक करें और खींचें।\n\nदेखा गया: कैनवास पर एक चिकना, घुमावदार चाप खींचा गया है, जो बिंदु A से 6 सेमी दूर है।",
        },
        {
          'hud':
              "कार्य: कंपास को खींचें और इसे शीर्ष 'B' पर छोड़ दें। त्रिज्या पहले से ही 6 सेमी पर सेट है। दूसरा चाप खींचने के लिए क्लिक करें और खींचें।",
          'text':
              "कार्य: कंपास को खींचें और इसे शीर्ष 'B' पर छोड़ दें। त्रिज्या पहले से ही 6 सेमी पर सेट है। दूसरा चाप खींचने के लिए क्लिक करें और खींचें।\n\nदेखा गया: शीर्ष B से एक दूसरा चाप खींचा गया है, जो पहले चाप को एक बिंदु पर काटता है।",
        },
        {
          'hud':
              "कार्य: शासक टूल को खींचें और शीर्ष A को शीर्ष C से कनेक्ट करें। फिर, शीर्ष B को शीर्ष C से कनेक्ट करें।",
          'text':
              "कार्य: शासक टूल को खींचें और शीर्ष A को शीर्ष C से कनेक्ट करें। फिर, शीर्ष B को शीर्ष C से कनेक्ट करें।\n\nदेखा गया: त्रिभुज ABC पूरा हो गया है। तीनों भुजाएँ 6 सेमी की हैं, जो एक पूर्ण समबाहु त्रिभुज बनाती हैं।",
        },
      ],
      's1_sum':
          "आपने सफलतापूर्वक एक समबाहु त्रिभुज बनाया है। ध्यान दें कि तीसरा शीर्ष बनाने के लिए दोनों चाप बिल्कुल सही जगह पर कैसे मिले। यह विधि गारंटी देती है कि तीनों भुजाएँ बराबर हैं।",

      's2_title': "2. रोजमर्रा का त्रिभुज",
      's2_obj':
          "8 सेमी, 5 सेमी और 6 सेमी भुजाओं वाले एक विषमबाहु त्रिभुज की रचना करना, SSS निर्माण को प्रदर्शित करना।",
      's2_steps': [
        {
          'hud':
              "कार्य: शासक को कैनवास पर खींचें। आधार के रूप में सबसे लंबी भुजा '8 सेमी' चुनें और खींचें।",
          'text':
              "कार्य: शासक को कैनवास पर खींचें। आधार के रूप में सबसे लंबी भुजा '8 सेमी' चुनें और खींचें।\n\nदेखा गया: 8 सेमी का रेखाखंड XY खींचा गया है।",
        },
        {
          'hud':
              "कार्य: कंपास को शीर्ष X पर खींचें। त्रिज्या के लिए 5 सेमी चुनें। चाप खींचें।",
          'text':
              "कार्य: कंपास को शीर्ष X पर खींचें। त्रिज्या के लिए 5 सेमी चुनें। चाप खींचें।\n\nदेखा गया: X से 5 सेमी का चाप खींचा गया है।",
        },
        {
          'hud':
              "कार्य: कंपास को शीर्ष Y पर खींचें। त्रिज्या के लिए 6 सेमी चुनें। दूसरा चाप खींचें।",
          'text':
              "कार्य: कंपास को शीर्ष Y पर खींचें। त्रिज्या के लिए 6 सेमी चुनें। दूसरा चाप खींचें।\n\nदेखा गया: दूसरा चाप पहले को बिंदु Z पर काटता है।",
        },
        {
          'hud': "कार्य: त्रिभुज को पूरा करने के लिए शासक टूल को खींचें।",
          'text':
              "कार्य: त्रिभुज को पूरा करने के लिए शासक टूल को खींचें।\n\nदेखा गया: विषमबाहु त्रिभुज पूरा हो गया है।",
        },
      ],
      's2_sum':
          "तीसरा शीर्ष 'Z', X से 5 सेमी और Y से 6 सेमी की दूरी पर होना चाहिए, जो ठीक वहीं है जहां चाप पार करते हैं।",

      's3_title': "3. असंभव त्रिभुज",
      's3_obj':
          "8 सेमी, 3 सेमी और 4 सेमी भुजाओं वाले एक त्रिभुज के निर्माण का प्रयास करना, और यह खोजना कि यह असंभव क्यों है।",
      's3_steps': [
        {
          'hud': "कार्य: शासक को कैनवास पर खींचें। 8 सेमी का आधार खींचें।",
          'text':
              "कार्य: शासक को कैनवास पर खींचें। 8 सेमी का आधार खींचें।\n\nदेखा गया: 8 सेमी का रेखाखंड PQ खींचा गया है।",
        },
        {
          'hud': "कार्य: कंपास को शीर्ष P पर खींचें। 3 सेमी चुनें। चाप खींचें।",
          'text':
              "कार्य: कंपास को शीर्ष P पर खींचें। 3 सेमी चुनें। चाप खींचें।\n\nदेखा गया: P से 3 सेमी का चाप खींचा गया है।",
        },
        {
          'hud':
              "कार्य: कंपास को शीर्ष Q पर खींचें। 4 सेमी चुनें। दूसरा चाप खींचें।",
          'text':
              "कार्य: कंपास को शीर्ष Q पर खींचें। 4 सेमी चुनें। दूसरा चाप खींचें।\n\nदेखा गया: चाप प्रतिच्छेद नहीं करते हैं! उनके बीच एक अंतर है।",
        },
        {
          'hud':
              "कार्य: कैनवास पर 'त्रुटि का विश्लेषण करें' बटन पर क्लिक करें।",
          'text':
              "कार्य: कैनवास पर 'त्रुटि का विश्लेषण करें' बटन पर क्लिक करें।\n\nदेखा गया: एनीमेशन से पता चलता है कि 3 + 4 = 7, जो 8 से कम है।",
        },
      ],
      's3_sum':
          "निर्माण विफल रहा क्योंकि दो छोटी भुजाओं का योग सबसे लंबी भुजा से कम है (3 + 4 < 8)। यह त्रिभुज असमानता नियम है!",

      's4_title': "4. सममित चुनौती",
      's4_obj':
          "आपको 7 सेमी, 7 सेमी और 5 सेमी दिया गया है। स्वतंत्र रूप से त्रिभुज का निर्माण करें।",
      's4_steps': [
        {
          'hud': "कार्य: 7, 7, 5 सेमी का उपयोग करके एक त्रिभुज बनाएं।",
          'text':
              "कार्य: 7, 7, 5 सेमी का उपयोग करके एक त्रिभुज बनाएं।\n\nदेखा गया: आपने समद्विबाहु त्रिभुज का निर्माण किया।",
        },
      ],
      's4_sum':
          "बहुत बढ़िया! आपने सफलतापूर्वक समद्विबाहु त्रिभुज का निर्माण किया।",

      's5_title': "5. गैप चुनौती",
      's5_obj':
          "आपको 10 सेमी, 4 सेमी और 6 सेमी दिया गया है। क्या आप एक त्रिभुज बना सकते हैं?",
      's5_steps': [
        {
          'hud':
              "कार्य: 10 सेमी, 4 सेमी और 6 सेमी का उपयोग करके त्रिभुज बनाने का प्रयास करें। बटन पर क्लिक करें।",
          'text':
              "कार्य: 10 सेमी, 4 सेमी और 6 सेमी का उपयोग करके त्रिभुज बनाने का प्रयास करें। बटन पर क्लिक करें।\n\nदेखा गया: चाप एक 2D आकार बनाने के लिए नहीं मिलते हैं।",
        },
      ],
      's5_sum':
          "4 सेमी + 6 सेमी = 10 सेमी। दो छोटी भुजाएं छूने के लिए पर्याप्त लंबी हैं, जिससे एक सपाट रेखा बनती है, त्रिभुज नहीं।",
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
    _scenario = 1;
    _stepIndex = 0;
    _phase = 'wait_ruler';
    _availableLengths = List<double>.from(_scenarios[1]!['lengths']);
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

  // TOTAL NUCLEAR RESET
  void _fullReset() {
    playSound(_sndError);
    setState(() {
      _lang = 'en';
      _isSidebarOpen = true;
      _transformCtrl.value = Matrix4.identity();
      _showSuccessPopup = false;
      _showCurtain = true;
      _obsBoxX = 16.0;
      _obsBoxY = 80.0;
    });
    _loadScenario(1);
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _stepIndex = 0;
      _phase = 'wait_ruler';
      _targetBase = 0;
      _targetArcA = 0;
      _targetArcB = 0;
      _drawProgress = 0;
      _arcProgress = 0;
      _lineProgress = 0;
      _tempRadius = 1;
      _availableLengths = List<double>.from(_scenarios[id]!['lengths']);
      _transformCtrl.value = Matrix4.translationValues(0.0, 40.0, 0.0);
    });
    if (!_showCurtain) playSound(_sndPop);
  }

  void _markStepComplete() {
    setState(() {
      _stepIndex++;
    });
  }

  Offset _getWorldPosition(Offset globalPos) {
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localDrop = box.globalToLocal(globalPos);
    Matrix4 inverted = Matrix4.inverted(_transformCtrl.value);
    Vector3 mapped = inverted.perspectiveTransform(
      Vector3(localDrop.dx, localDrop.dy, 0),
    );
    return Offset(mapped.x, mapped.y);
  }

  void _handleToolDrop(
    String tool,
    Offset dropPos,
    BoxConstraints constraints,
  ) {
    Offset worldPt = _getWorldPosition(dropPos);
    double cx = constraints.maxWidth / 2;
    double cy = constraints.maxHeight / 2 + baseY;

    setState(() {
      if (tool == 'ruler' &&
          (_phase == 'wait_ruler' || _phase == 'wait_ruler_ac')) {
        playSound(_sndSnap);
        if (_phase == 'wait_ruler') {
          if (_scenario == 1) {
            _targetBase = 6;
            _phase = 'draw_base';
          } else {
            _phase = 'select_base';
          }
        } else {
          _phase = 'draw_ac';
        }
      } else if (tool == 'compass' &&
          (_phase == 'wait_compass_a' || _phase == 'wait_compass_b')) {
        Offset ptA = Offset(cx - (_targetBase * pxPerCm) / 2, cy);
        Offset ptB = Offset(cx + (_targetBase * pxPerCm) / 2, cy);

        // Extended drop zones
        if (_phase == 'wait_compass_a' && (worldPt - ptA).distance < 200) {
          playSound(_sndSnap);
          if (_scenario == 1) {
            _targetArcA = 6;
            _phase = 'adjust_compass_a';
          } else {
            _phase = 'select_arcA';
          }
        } else if (_phase == 'wait_compass_b' &&
            (worldPt - ptB).distance < 200) {
          playSound(_sndSnap);
          if (_scenario == 1) {
            _targetArcB = 6;
            _phase = 'draw_arc_b';
          } else {
            _phase = 'select_arcB';
          }
        } else {
          playSound(_sndError);
        }
      } else {
        playSound(_sndError);
      }
    });
  }

  void _onPanDown(DragDownDetails details, BoxConstraints constraints) {
    double cx = constraints.maxWidth / 2;
    double cy = constraints.maxHeight / 2 + baseY;
    Offset ptA = Offset(cx - (_targetBase * pxPerCm) / 2, cy);
    Offset ptB = Offset(cx + (_targetBase * pxPerCm) / 2, cy);
    Offset? C = _getIntersection(ptA);
    Offset worldTouch = _getWorldPosition(details.globalPosition);

    bool hit = false;
    double hitRadius = 200.0;

    if (_phase == 'draw_base') {
      double pencilX = ptA.dx + _drawProgress * pxPerCm;
      if ((worldTouch.dx - pencilX).abs() < hitRadius &&
          (worldTouch.dy - ptA.dy).abs() < hitRadius) {
        hit = true;
      }
    } else if (_phase == 'draw_arc_a') {
      double targetAngle =
          C != null ? atan2(C.dy - ptA.dy, C.dx - ptA.dx) : -0.4;
      double angle = targetAngle - 0.4 + 1.0 * _arcProgress;
      Offset px =
          ptA + Offset(cos(angle), sin(angle)) * (_targetArcA * pxPerCm);
      if ((worldTouch - px).distance < hitRadius) hit = true;
    } else if (_phase == 'draw_arc_b') {
      double targetAngle =
          C != null ? atan2(C.dy - ptB.dy, C.dx - ptB.dx) : (-pi + 0.4);
      double angle = targetAngle + 0.4 - 1.0 * _arcProgress;
      Offset px =
          ptB + Offset(cos(angle), sin(angle)) * (_targetArcB * pxPerCm);
      if ((worldTouch - px).distance < hitRadius) hit = true;
    } else if (_phase == 'draw_ac' && C != null) {
      Offset px = ptA + (C - ptA) * _lineProgress;
      if ((worldTouch - px).distance < hitRadius) hit = true;
    } else if (_phase == 'draw_bc' && C != null) {
      Offset px = ptB + (C - ptB) * _lineProgress;
      if ((worldTouch - px).distance < hitRadius) hit = true;
    }

    if (hit) {
      setState(() {
        _isDrawingAction = true;
        _lastDrawPt = details.globalPosition;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDrawingAction && _lastDrawPt != null) {
      double dist =
          (details.globalPosition - _lastDrawPt!).distance /
          pxPerCm /
          _transformCtrl.value.getMaxScaleOnAxis();
      _lastDrawPt = details.globalPosition;

      if (dist > 0 && DateTime.now().millisecond % 5 == 0) playSound(_sndDraw);

      setState(() {
        if (_phase == 'draw_base') {
          _drawProgress = min(_targetBase, _drawProgress + dist * 2);
          if (_drawProgress >= _targetBase) {
            _phase = 'wait_compass_a';
            _isDrawingAction = false;
            playSound(_sndSuccess);
            if (_scenario <= 3) _markStepComplete();
          }
        } else if (_phase == 'draw_arc_a') {
          _arcProgress = min(1.0, _arcProgress + dist * 0.3);
          if (_arcProgress >= 1.0) {
            _phase = 'wait_compass_b';
            _arcProgress = 0;
            _isDrawingAction = false;
            playSound(_sndSuccess);
            if (_scenario <= 3) _markStepComplete();
          }
        } else if (_phase == 'draw_arc_b') {
          _arcProgress = min(1.0, _arcProgress + dist * 0.3);
          if (_arcProgress >= 1.0) {
            _arcProgress = 0;
            _isDrawingAction = false;
            playSound(_sndSuccess);
            if (_scenario == 3 || _scenario == 5) {
              _phase = 'analyzing_wait';
              if (_scenario <= 3) _markStepComplete();
            } else {
              _phase = 'wait_ruler_ac';
              if (_scenario <= 3) _markStepComplete();
            }
          }
        } else if (_phase == 'draw_ac') {
          _lineProgress = min(1.0, _lineProgress + dist * 0.5);
          if (_lineProgress >= 1.0) {
            _phase = 'draw_bc';
            _lineProgress = 0;
            _isDrawingAction = false;
            playSound(_sndSnap);
          }
        } else if (_phase == 'draw_bc') {
          _lineProgress = min(1.0, _lineProgress + dist * 0.5);
          if (_lineProgress >= 1.0) {
            _phase = 'complete';
            _isDrawingAction = false;
            playSound(_sndSuccess);
            _markStepComplete();
            if (_scenario == 5) {
              Future.delayed(
                const Duration(seconds: 1),
                () => setState(() => _showSuccessPopup = true),
              );
            }
          }
        }
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDrawingAction = false;
      _lastDrawPt = null;
    });
  }

  Offset? _getIntersection(Offset ptA) {
    if (_targetBase == 0 || _targetArcA == 0 || _targetArcB == 0) return null;
    double d = _targetBase * pxPerCm;
    double r1 = _targetArcA * pxPerCm;
    double r2 = _targetArcB * pxPerCm;
    if (d > r1 + r2 || d < (r1 - r2).abs()) return null;
    double a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
    double h2 = r1 * r1 - a * a;
    if (h2 < 0) return null;
    double h = sqrt(h2);
    return Offset(ptA.dx + a, ptA.dy - h);
  }

  void _onLengthSelected(double length) {
    playSound(_sndClick);
    setState(() {
      _availableLengths.remove(length);
      if (_phase == 'select_base') {
        _targetBase = length;
        _phase = 'draw_base';
      } else if (_phase == 'select_arcA') {
        _targetArcA = length;
        _phase = 'adjust_compass_a';
      } else if (_phase == 'select_arcB') {
        _targetArcB = length;
        _tempRadius = _targetArcA;
        _phase = 'adjust_compass_b';
      }
    });
  }

  void _onSliderChangeEnd(double val) {
    double target = _phase == 'adjust_compass_a' ? _targetArcA : _targetArcB;
    if ((val - target).abs() < 0.2) {
      playSound(_sndSnap);
      setState(() {
        _tempRadius = target;
        if (_phase == 'adjust_compass_a') {
          _phase = 'draw_arc_a';
          if (_scenario == 1) _markStepComplete();
        } else {
          _phase = 'draw_arc_b';
        }
      });
    } else {
      playSound(_sndError);
    }
  }

  Widget _buildStepsList() {
    Map<String, dynamic> cfg = _getScenarioConfig(_scenario);
    List<dynamic> stepsList = cfg['steps'];
    List<Widget> wList = [];

    // Objective Theory block (Does not overflow due to natural wrapping)
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
    double sidebarWidth = screenWidth * 0.38;

    Map<String, dynamic> activeCfg = _getScenarioConfig(_scenario);
    String activeHudText =
        _stepIndex < activeCfg['steps'].length
            ? activeCfg['steps'][_stepIndex]['hud']
            : getText('completed');
    String activeObsText =
        _stepIndex < activeCfg['steps'].length
            ? activeCfg['steps'][_stepIndex]['text']
            : activeCfg['sum'];

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap:
            () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Row Layout separating Sidebar from Canvas dynamically
            Row(
              children: [
                // Animated Sidebar Wrapper (Scrolls entirely from top to bottom)
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
                        // Entire sidebar scrolls top to bottom. NO Safe Area.
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                60,
                                16,
                                16,
                              ), // Added top padding instead of SafeArea
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
                                      // Language Toggle Switch
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
                                      // Nuclear Reset Button
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
                                        if (v != null) _loadScenario(v);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _buildStepsList(),
                                ],
                              ),
                            ),
                            // Footer rendered full width at bottom of list
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
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

                // Canvas Area taking remaining width
                Expanded(
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return InteractiveViewer(
                            transformationController: _transformCtrl,
                            panEnabled: !_isDrawingAction,
                            scaleEnabled: !_isDrawingAction,
                            minScale: 0.2,
                            maxScale: 4.0,
                            boundaryMargin: const EdgeInsets.all(
                              double.infinity,
                            ),
                            child: DragTarget<String>(
                              onAcceptWithDetails:
                                  (details) => _handleToolDrop(
                                    details.data,
                                    details.offset,
                                    constraints,
                                  ),
                              builder: (context, candidateData, rejectedData) {
                                return GestureDetector(
                                  // Global Listeners for reliable drawing interaction
                                  onPanDown:
                                      _phase.startsWith('draw_')
                                          ? (d) => _onPanDown(d, constraints)
                                          : null,
                                  onPanUpdate:
                                      _phase.startsWith('draw_')
                                          ? _onPanUpdate
                                          : null,
                                  onPanEnd:
                                      _phase.startsWith('draw_')
                                          ? _onPanEnd
                                          : null,
                                  onPanCancel:
                                      _phase.startsWith('draw_')
                                          ? () => _onPanEnd(DragEndDetails())
                                          : null,
                                  child: CustomPaint(
                                    key: _canvasKey,
                                    size: Size(
                                      constraints.maxWidth,
                                      constraints.maxHeight,
                                    ),
                                    painter: TrianglePainter(
                                      phase: _phase,
                                      targetBase: _targetBase,
                                      targetArcA: _targetArcA,
                                      targetArcB: _targetArcB,
                                      drawProgress: _drawProgress,
                                      arcProgress: _arcProgress,
                                      lineProgress: _lineProgress,
                                      tempRadius: _tempRadius,
                                      isDrawingAction: _isDrawingAction,
                                      pulseCtrl: _pulseCtrl,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // Floating Draggable Active Step Panel (visible ONLY when Sidebar is Closed)
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
                              width: 240,
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

                      if (_phase.startsWith('select_'))
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1E293B,
                              ).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.indigoAccent),
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
                                Text(
                                  getText(
                                    _phase == 'select_base'
                                        ? 'selectLenBase'
                                        : 'selectLenRadius',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children:
                                      _availableLengths
                                          .toSet()
                                          .toList()
                                          .map(
                                            (l) => ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.indigoAccent,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 14,
                                                    ),
                                              ),
                                              onPressed:
                                                  () => _onLengthSelected(l),
                                              child: Text(
                                                '$l ${getText('cm')}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (_phase.startsWith('adjust_'))
                        Positioned(
                          bottom: 120,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.indigoAccent),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${getText('radiusLabel')} ${_tempRadius.toStringAsFixed(1)} ${getText('cm')}',
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: 300,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 8,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 12,
                                        ),
                                      ),
                                      child: Slider(
                                        value: _tempRadius,
                                        min: 1,
                                        max: 10,
                                        divisions: 90,
                                        activeColor: Colors.amberAccent,
                                        onChanged: (v) {
                                          setState(() {
                                            _tempRadius = v;
                                          });
                                          if (DateTime.now().millisecond % 10 ==
                                              0) {
                                            playSound(_sndDraw);
                                          }
                                        },
                                        onChangeEnd: _onSliderChangeEnd,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    getText('adjustTarget'),
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

                      // Floating Action Controls & Toolbox
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_phase == 'analyzing_wait')
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  elevation: 10,
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
                                  setState(() => _phase = 'analyzing');
                                  Future.delayed(
                                    const Duration(milliseconds: 1500),
                                    () => setState(() {
                                      _phase = 'analyzed';
                                      if (_scenario <= 3) _markStepComplete();
                                      if (_scenario == 5) {
                                        Future.delayed(
                                          const Duration(seconds: 1),
                                          () => setState(
                                            () => _showSuccessPopup = true,
                                          ),
                                        );
                                      }
                                    }),
                                  );
                                },
                              ),

                            if (_phase == 'analyzed' && _scenario != 5)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigoAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  elevation: 10,
                                ),
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(
                                  getText('nextScenario'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () => _loadScenario(_scenario + 1),
                              ),

                            if (_phase == 'complete' && _scenario != 5)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  elevation: 10,
                                ),
                                icon: const Icon(Icons.check_circle),
                                label: Text(
                                  getText('checkBtn'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  playSound(_sndSuccess);
                                  _loadScenario(_scenario + 1);
                                },
                              ),

                            const SizedBox(height: 20),

                            // Bottom Action Draggable Tools
                            if (!_showCurtain)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1E293B,
                                  ).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Draggable<String>(
                                      data: 'ruler',
                                      feedback: const Icon(
                                        Icons.straighten,
                                        size: 60,
                                        color: Colors.indigoAccent,
                                      ),
                                      childWhenDragging: const Icon(
                                        Icons.straighten,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      child: Icon(
                                        Icons.straighten,
                                        size: 50,
                                        color:
                                            (_phase == 'wait_ruler' ||
                                                    _phase == 'wait_ruler_ac')
                                                ? Colors.indigoAccent
                                                : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Draggable<String>(
                                      data: 'compass',
                                      feedback: const Icon(
                                        Icons.architecture,
                                        size: 60,
                                        color: Colors.amberAccent,
                                      ),
                                      childWhenDragging: const Icon(
                                        Icons.architecture,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      child: Icon(
                                        Icons.architecture,
                                        size: 50,
                                        color:
                                            (_phase == 'wait_compass_a' ||
                                                    _phase == 'wait_compass_b')
                                                ? Colors.amberAccent
                                                : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 10),

                            // Central HUD Bottom Banner (Hidden if Sidebar is Closed)
                            if (_isSidebarOpen)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1E293B,
                                  ).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.indigoAccent.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 10,
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
                                        activeHudText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Exact User Provided: Top-Left Floating Toggle Icon
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  playSound(_sndClick);
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
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
                        child: Column(
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
                      ),
                    ),
                  ),
                ),
              ),

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
                            Icons.architecture,
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
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final String phase;
  final double targetBase,
      targetArcA,
      targetArcB,
      drawProgress,
      arcProgress,
      lineProgress,
      tempRadius;
  final bool isDrawingAction;
  final AnimationController pulseCtrl;

  TrianglePainter({
    required this.phase,
    required this.targetBase,
    required this.targetArcA,
    required this.targetArcB,
    required this.drawProgress,
    required this.arcProgress,
    required this.lineProgress,
    required this.tempRadius,
    required this.isDrawingAction,
    required this.pulseCtrl,
  }) : super(repaint: pulseCtrl);

  void _drawRulerUI(
    Canvas canvas,
    Offset start,
    double lengthCm,
    double angle,
  ) {
    canvas.save();
    canvas.translate(start.dx, start.dy);
    canvas.rotate(angle);
    canvas.drawRect(
      Rect.fromLTWH(-30.0, 0, (lengthCm + 2) * 30.0, 40),
      Paint()..color = const Color(0xD8FFFFFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(-30.0, 0, (lengthCm + 2) * 30.0, 40),
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final paintLines =
        Paint()
          ..color = const Color(0xFF0F172A)
          ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = -1; i <= lengthCm + 1; i++) {
      double x = i * 30.0;
      canvas.drawLine(Offset(x, 0), Offset(x, 10), paintLines);
      if (i >= 0) {
        textPainter.text = TextSpan(
          text: '$i',
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, 12));
      }
      for (int j = 1; j < 10; j++) {
        canvas.drawLine(
          Offset(x + j * 3.0, 0),
          Offset(x + j * 3.0, 5),
          paintLines,
        );
      }
    }
    canvas.restore();
  }

  void _drawCompassUI(
    Canvas canvas,
    Offset center,
    double radiusPx,
    double angle,
    bool isAdjusting,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    double hingeY = -140;

    final paintArm =
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 0), Offset(0, hingeY), paintArm);

    double tipX = cos(angle) * radiusPx;
    double tipY = sin(angle) * radiusPx;
    canvas.drawLine(Offset(0, hingeY), Offset(tipX, tipY), paintArm);

    canvas.drawCircle(
      Offset(0, hingeY),
      10,
      Paint()..color = const Color(0xFF475569),
    );
    canvas.drawCircle(
      Offset(tipX, tipY),
      6,
      Paint()..color = const Color(0xFF10B981),
    );

    if (isAdjusting) {
      final dashPaint =
          Paint()
            ..color = const Color(0x666366F1)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
      double dist = sqrt(tipX * tipX + tipY * tipY);
      if (dist > 0) {
        double dx = tipX / dist;
        double dy = tipY / dist;
        for (double d = 0; d < dist; d += 10) {
          canvas.drawLine(
            Offset(dx * d, dy * d),
            Offset(dx * min(d + 5, dist), dy * min(d + 5, dist)),
            dashPaint,
          );
        }
      }
    }
    canvas.restore();
  }

  void _drawPencil(Canvas canvas, Offset pos, bool pulse) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    if (pulse) {
      double s = 1 + sin(DateTime.now().millisecondsSinceEpoch / 150) * 0.1;
      canvas.scale(s, s);
    }
    canvas.rotate(-pi / 4);

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(15, -20)
        ..lineTo(30, -100)
        ..lineTo(10, -100)
        ..close(),
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawPath(
      Path()
        ..moveTo(10, -100)
        ..lineTo(30, -100)
        ..lineTo(32, -110)
        ..lineTo(8, -110)
        ..close(),
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawPath(
      Path()
        ..moveTo(8, -110)
        ..lineTo(32, -110)
        ..lineTo(30, -120)
        ..lineTo(10, -120)
        ..close(),
      Paint()..color = const Color(0xFFF43F5E),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(6, -8)
        ..lineTo(0, -8)
        ..close(),
      Paint()..color = const Color(0xFF334155),
    );

    canvas.restore();
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
    final double cy = size.height / 2 + _TriangleLabScreenState.baseY;

    final Paint gridPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 1;
    for (
      double i = -8000;
      i < size.width + 8000;
      i += _TriangleLabScreenState.pxPerCm
    ) {
      canvas.drawLine(
        Offset(i, -8000),
        Offset(i, size.height + 8000),
        gridPaint,
      );
    }
    for (
      double i = -8000;
      i < size.height + 8000;
      i += _TriangleLabScreenState.pxPerCm
    ) {
      canvas.drawLine(
        Offset(-8000, i),
        Offset(size.width + 8000, i),
        gridPaint,
      );
    }

    if (targetBase == 0) {
      if (phase == 'wait_ruler' || phase == 'wait_ruler_ac') {
        canvas.drawCircle(
          Offset(cx, cy),
          25,
          Paint()..color = Colors.indigo.withValues(alpha: 0.3),
        );
        final Paint dashPaint =
            Paint()
              ..color = Colors.indigoAccent
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round;
        double startX = cx - 100;
        double endX = cx + 100;
        const double dashW = 10;
        const double dashS = 10;
        while (startX < endX) {
          canvas.drawLine(
            Offset(startX, cy),
            Offset(min(startX + dashW, endX), cy),
            dashPaint,
          );
          startX += dashW + dashS;
        }
      }
      return;
    }

    final Offset ptA = Offset(
      cx - (targetBase * _TriangleLabScreenState.pxPerCm) / 2,
      cy,
    );
    final Offset ptB = Offset(
      cx + (targetBase * _TriangleLabScreenState.pxPerCm) / 2,
      cy,
    );
    Offset? intersection = _getIntersection(ptA);

    // Render Base
    if (phase == 'draw_base' || targetBase > 0) {
      double currentLen =
          phase == 'draw_base'
              ? drawProgress * _TriangleLabScreenState.pxPerCm
              : targetBase * _TriangleLabScreenState.pxPerCm;
      Offset currentB = Offset(ptA.dx + currentLen, ptA.dy);

      if (phase == 'draw_base') {
        _drawRulerUI(canvas, Offset(ptA.dx, ptA.dy + 2), targetBase, 0);
      }

      canvas.drawLine(
        ptA,
        currentB,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );

      if (phase == 'draw_base') _drawPencil(canvas, currentB, !isDrawingAction);

      _drawPoint(canvas, ptA, 'A', Colors.redAccent);
      if (phase != 'draw_base') _drawPoint(canvas, ptB, 'B', Colors.redAccent);
    }

    if (phase == 'wait_compass_a') {
      canvas.drawCircle(
        ptA,
        25,
        Paint()
          ..color = Colors.indigoAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (phase == 'wait_compass_b') {
      canvas.drawCircle(
        ptB,
        25,
        Paint()
          ..color = Colors.indigoAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Render Arcs
    void drawSimpleArc(
      Offset center,
      double radius,
      bool isA,
      double progress,
    ) {
      if (radius <= 0) return;
      double rPx = radius * _TriangleLabScreenState.pxPerCm;
      double targetAngle =
          intersection != null
              ? atan2(intersection.dy - center.dy, intersection.dx - center.dx)
              : (isA ? -0.4 : -pi + 0.4);
      double sweep = 1.2;
      double startAngle = isA ? targetAngle - 0.4 : targetAngle + 0.4;
      double endAngle =
          isA ? startAngle + sweep * progress : startAngle - sweep * progress;

      if (progress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: rPx),
          startAngle,
          endAngle - startAngle,
          false,
          Paint()
            ..color = isA ? Colors.redAccent : Colors.blueAccent
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }

      if ((phase == 'draw_arc_a' && isA) || (phase == 'draw_arc_b' && !isA)) {
        _drawCompassUI(canvas, center, rPx, endAngle, false);
      } else if ((phase == 'adjust_compass_a' && isA) ||
          (phase == 'adjust_compass_b' && !isA)) {
        _drawCompassUI(canvas, center, rPx, startAngle, true);
      }
    }

    if (phase == 'adjust_compass_a' ||
        phase == 'draw_arc_a' ||
        targetArcA > 0) {
      drawSimpleArc(
        ptA,
        phase == 'adjust_compass_a' ? tempRadius : targetArcA,
        true,
        phase == 'draw_arc_a' ? arcProgress : 1.0,
      );
    }
    if (phase == 'adjust_compass_b' ||
        phase == 'draw_arc_b' ||
        targetArcB > 0) {
      drawSimpleArc(
        ptB,
        phase == 'adjust_compass_b' ? tempRadius : targetArcB,
        false,
        phase == 'draw_arc_b' ? arcProgress : 1.0,
      );
    }

    // Render Connecting Lines
    if (intersection != null &&
        (phase == 'draw_ac' || phase == 'draw_bc' || phase == 'complete')) {
      _drawPoint(canvas, intersection, 'C', Colors.blueAccent);

      double pAC = phase == 'draw_ac' ? lineProgress : 1.0;
      Offset endAC = ptA + (intersection - ptA) * pAC;

      if (phase == 'draw_ac') {
        double angle = atan2(
          intersection.dy - ptA.dy,
          intersection.dx - ptA.dx,
        );
        double len =
            (intersection - ptA).distance / _TriangleLabScreenState.pxPerCm;
        _drawRulerUI(canvas, ptA, len, angle);
      }

      canvas.drawLine(
        ptA,
        endAC,
        Paint()
          ..color = Colors.greenAccent
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      if (phase == 'draw_ac') _drawPencil(canvas, endAC, !isDrawingAction);

      if (phase == 'draw_bc' || phase == 'complete') {
        double pBC = phase == 'draw_bc' ? lineProgress : 1.0;
        Offset endBC = ptB + (intersection - ptB) * pBC;

        if (phase == 'draw_bc') {
          double angle = atan2(
            intersection.dy - ptB.dy,
            intersection.dx - ptB.dx,
          );
          double len =
              (intersection - ptB).distance / _TriangleLabScreenState.pxPerCm;
          _drawRulerUI(canvas, ptB, len, angle);
        }

        canvas.drawLine(
          ptB,
          endBC,
          Paint()
            ..color = Colors.greenAccent
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
        if (phase == 'draw_bc') _drawPencil(canvas, endBC, !isDrawingAction);
      }

      if (phase == 'complete') {
        canvas.drawPath(
          Path()
            ..moveTo(ptA.dx, ptA.dy)
            ..lineTo(ptB.dx, ptB.dy)
            ..lineTo(intersection.dx, intersection.dy)
            ..close(),
          Paint()
            ..color = Colors.greenAccent.withValues(alpha: 0.15)
            ..style = PaintingStyle.fill,
        );
      }
    }

    if (phase == 'analyzing' || phase == 'analyzed') {
      canvas.drawLine(
        Offset(ptA.dx, ptA.dy - 15),
        Offset(
          ptA.dx + targetArcA * _TriangleLabScreenState.pxPerCm,
          ptA.dy - 15,
        ),
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(ptB.dx, ptB.dy - 15),
        Offset(
          ptB.dx - targetArcB * _TriangleLabScreenState.pxPerCm,
          ptB.dy - 15,
        ),
        Paint()
          ..color = Colors.blueAccent
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
      if (phase == 'analyzed') {
        TextPainter tp = TextPainter(
          text: TextSpan(
            text:
                '$targetArcA + $targetArcB = ${targetArcA + targetArcB} \n ${targetArcA + targetArcB} < $targetBase',
            style: const TextStyle(
              color: Colors.pinkAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - 60));
      }
    }
  }

  Offset? _getIntersection(Offset ptA) {
    if (targetBase == 0 || targetArcA == 0 || targetArcB == 0) return null;
    double d = targetBase * _TriangleLabScreenState.pxPerCm;
    double r1 = targetArcA * _TriangleLabScreenState.pxPerCm;
    double r2 = targetArcB * _TriangleLabScreenState.pxPerCm;
    if (d > r1 + r2 || d < (r1 - r2).abs()) return null;
    double a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
    double h2 = r1 * r1 - a * a;
    if (h2 < 0) return null;
    return Offset(ptA.dx + a, ptA.dy - sqrt(h2));
  }

  void _drawPoint(Canvas canvas, Offset pos, String label, Color color) {
    canvas.drawCircle(pos, 6, Paint()..color = color);
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - 25));
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return true;
  }
}
