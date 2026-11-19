// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, library_private_types_in_public_api

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
  runApp(const AltitudeArchitectApp());
}

class AltitudeArchitectApp extends StatelessWidget {
  const AltitudeArchitectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Altitude Architect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFF6366f1),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const AltitudesandClassificationofTriangles(),
    );
  }
}

// --- DATA MODELS ---

class GeomPoint {
  double x;
  double y;
  GeomPoint(this.x, this.y);
}

class PlumbTool {
  bool visible;
  bool snapped;
  double px;
  double py;

  PlumbTool({
    this.visible = false,
    this.snapped = false,
    this.px = 0,
    this.py = 0,
  });
}

class SortableTriangle {
  String type;
  double x;
  double y;
  bool isDragging;
  bool error;

  SortableTriangle({
    required this.type,
    required this.x,
    required this.y,
    this.isDragging = false,
    this.error = false,
  });
}

class ScenarioConfig {
  int id;
  String titleKey;
  String objKey;
  int stepsCount;

  ScenarioConfig(this.id, this.titleKey, this.objKey, this.stepsCount);
}

// --- LOCALIZATION ---

const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': "The Altitude Architect: Classifying Triangles",
    'appSubtitle': "Class 7 • A TALE OF THREE INTERSECTING LINES",
    'enterLab': "Enter Lab",
    'objectiveLbl': "Mission Objective:",
    'stepLabel': "STEP",
    'doneBtn': "I'm Done",
    'nextBtn': "Next",
    'completed': "Completed!",
    'successTitle': "Geometry Master!",
    'successDesc':
        "You successfully mastered triangle altitudes and classification!",
    'restartLab': "Restart Lab",
    'extendBtn': "Extend Base",
    'showAltBtn': "Show Altitudes",
    'hideAltBtn': "Hide Altitudes",
    'nextScenario': "Next Challenge",
    'selectScenario': "Select Scenario",
    's1_canvas_inside': "Altitude AD is INSIDE",
    's4_counter': "Altitudes Found",

    's1_title': "1. The Perpendicular Plumb Line",
    's1_obj':
        "To understand what an altitude is and discover its position in an acute-angled triangle.",
    's1_step1':
        "Task: An acute triangle ABC is shown. DRAG the Plumb Line Tool straight down towards the base BC.\nObservation: The tool acts like a weight on a string.\nLearnt: An altitude drops straight down from a vertex.",
    's1_step2':
        "Task: Keep dragging until it touches the base BC. It will 'SNAP' into place forming a 90° angle.\nObservation: The altitude AD is drawn, meeting the base at 90°.\nLearnt: An altitude is always perpendicular to the opposite side.",
    's1_step3':
        "Task: Notice the altitude AD is completely inside the triangle. CLICK the 'Next' button.\nObservation: The altitude is INSIDE.\nLearnt: In acute triangles, altitudes lie inside the boundary.",
    's1_sum':
        "An altitude is a perpendicular line from a vertex to the opposite side. In an acute triangle, it is inside.",

    's2_title': "2. The Out-of-Bounds Altitude",
    's2_obj':
        "To discover that an altitude can lie outside the triangle, specifically in an obtuse triangle.",
    's2_step1':
        "Task: DRAG the Plumb Line Tool from vertex P towards the base QR.\nObservation: The plumb line misses the solid base QR.\nLearnt: The altitude cannot drop directly onto the opposite side in this obtuse triangle.",
    's2_step2':
        "Task: The base needs to be extended. CLICK the 'Extend Base' button.\nObservation: A dashed line extends from the base.\nLearnt: We can project the base line indefinitely.",
    's2_step3':
        "Task: Now, DRAG the Plumb Line Tool down to the extended dotted line.\nObservation: The altitude PS forms a 90° angle on the extended line, completely outside the triangle.\nLearnt: Obtuse triangles can have altitudes outside their boundary.",
    's2_step4':
        "Task: Notice altitude PS is OUTSIDE. This happens in obtuse triangles.\nObservation: The altitude is OUTSIDE.\nLearnt: Obtuse angles push the altitude outwards.",
    's2_sum':
        "Altitudes don't always fall inside! In an obtuse triangle, two altitudes will fall on the extended bases outside the shape.",

    's3_title': "3. The Triangle Sorting Factory",
    's3_obj':
        "To classify triangles as equilateral, isosceles, and scalene based on their side lengths.",
    's3_step1':
        "Task: DRAG the triangle and DROP it into the correct sorting bin based on its side lengths indicated by the tick marks.\nObservation: The isosceles triangle (2 equal sides) went into the '2 Sides Equal' bin.\nLearnt: Triangles with exactly two equal sides are called Isosceles.",
    's3_step2':
        "Task: A new triangle appears. DRAG and DROP it into the correct bin.\nObservation: The equilateral triangle (3 equal sides) went into the 'All Sides Equal' bin.\nLearnt: Triangles with three equal sides are Equilateral.",
    's3_step3':
        "Task: Sort the final triangle into the correct bin.\nObservation: The scalene triangle (no equal sides) went into the 'No Sides Equal' bin.\nLearnt: Triangles with all different side lengths are Scalene.",
    's3_sum':
        "Great job! Triangles are classified by their sides: Equilateral (3 equal), Isosceles (2 equal), and Scalene (0 equal).",

    's4_title': "4. The Right Angle's Secret Identity",
    's4_obj':
        "To discover that in a right-angled triangle, two of the sides are also altitudes.",
    's4_step1':
        "Task: Here is a right-angled triangle ABC, with the right angle at B. DRAG the Plumb Line Tool from vertex B to the base AC.\nObservation: The altitude from B lands on the hypotenuse inside the triangle.\nLearnt: One altitude is internal.",
    's4_step2':
        "Task: Now, try to find the altitude from vertex A. DRAG the Plumb Line Tool from A to the opposite base, BC.\nObservation: The altitude from A snaps perfectly onto side AB.\nLearnt: In a right triangle, one leg acts as an altitude.",
    's4_step3':
        "Task: Great! One side is an altitude. Find the last one. DRAG the Plumb Line Tool from vertex C to the opposite base, AB.\nObservation: The altitude from C snaps perfectly onto side CB.\nLearnt: The other leg is also an altitude.",
    's4_sum':
        "You found the secret! In a right-angled triangle, the two sides that form the right angle are also altitudes!",

    's5_title': "5. The Triangle Sandbox",
    's5_obj':
        "To freely explore the relationship between triangle types and altitude positions.",
    's5_step1':
        "Task: DRAG any vertex (A, B, C) to change the triangle's shape. CLICK 'Show Altitudes' to see them move.\nObservation: Altitudes shift dynamically. The orthocenter (intersection point) moves around.\nLearnt: Altitude positions are strictly tied to the triangle's angles.",
    's5_step2':
        "Task: Challenge: Manipulate the vertices until the orthocenter (the intersection circle) is entirely OUTSIDE the triangle.\nObservation: The orthocenter moved outside when the triangle became obtuse.\nLearnt: The orthocenter of an obtuse triangle is always located outside.",
    's5_sum':
        "You did it! The orthocenter goes outside only when the triangle is obtuse.",
  },
  'hi': {
    'appTitle': "ऊंचाई वास्तुकार: त्रिभुजों का वर्गीकरण",
    'appSubtitle': "कक्षा 7 • तीन प्रतिच्छेदी रेखाओं की कहानी",
    'enterLab': "लैब में प्रवेश करें",
    'objectiveLbl': "मिशन उद्देश्य:",
    'stepLabel': "कदम",
    'doneBtn': "मैं कर चुका हूँ",
    'nextBtn': "अगला",
    'completed': "पूरा हुआ!",
    'successTitle': "ज्यामिति के उस्ताद!",
    'successDesc':
        "आपने त्रिभुज की ऊंचाइयों और वर्गीकरण में सफलतापूर्वक महारत हासिल कर ली है!",
    'restartLab': "लैब फिर से शुरू करें",
    'extendBtn': "आधार बढ़ाएं",
    'showAltBtn': "ऊंचाई दिखाएं",
    'hideAltBtn': "ऊंचाई छिपाएं",
    'nextScenario': "अगली चुनौती",
    'selectScenario': "दृश्य चुनें",
    's1_canvas_inside': "ऊंचाई AD अंदर है",
    's4_counter': "ऊंचाइयां मिलीं",

    's1_title': "1. लंबवत साहुल रेखा",
    's1_obj':
        "ऊंचाई क्या है यह समझने और न्यूनकोण त्रिभुज में इसकी स्थिति का पता लगाने के लिए।",
    's1_step1':
        "कार्य: एक न्यूनकोण त्रिभुज ABC दिखाया गया है। साहुल रेखा उपकरण को सीधे आधार BC की ओर नीचे खींचें।\nअवलोकन: उपकरण एक डोरी पर वजन की तरह काम करता है।\nसीखा: एक ऊंचाई शीर्ष से सीधे नीचे गिरती है।",
    's1_step2':
        "कार्य: तब तक खींचते रहें जब तक वह आधार BC को न छू ले। यह 90° का कोण बनाते हुए अपनी जगह पर आ जाएगा।\nअवलोकन: ऊंचाई AD खींची गई है, जो 90° पर आधार से मिलती है।\nसीखा: ऊंचाई हमेशा विपरीत भुजा के लंबवत होती है।",
    's1_step3':
        "कार्य: ध्यान दें कि ऊंचाई AD पूरी तरह से त्रिभुज के अंदर है। 'अगला' बटन पर क्लिक करें।\nअवलोकन: ऊंचाई अंदर है।\nसीखा: न्यूनकोण त्रिभुजों में, ऊंचाई सीमा के अंदर होती है।",
    's1_sum':
        "ऊंचाई एक शीर्ष से विपरीत भुजा तक एक लंबवत रेखा है। न्यूनकोण त्रिभुज में, यह अंदर होती है।",

    's2_title': "2. सीमा से बाहर की ऊंचाई",
    's2_obj':
        "यह पता लगाने के लिए कि ऊंचाई त्रिभुज के बाहर स्थित हो सकती है, विशेष रूप से अधिककोण त्रिभुज में।",
    's2_step1':
        "कार्य: शीर्ष P से आधार QR की ओर साहुल रेखा उपकरण खींचें।\nअवलोकन: साहुल रेखा आधार QR से चूक जाती है।\nसीखा: ऊंचाई सीधे विपरीत भुजा पर नहीं गिर सकती।",
    's2_step2':
        "कार्य: आधार को बढ़ाने की आवश्यकता है। 'आधार बढ़ाएं' बटन पर क्लिक करें।\nअवलोकन: आधार से एक धराशायी रेखा फैली हुई है।\nसीखा: हम आधार रेखा को अनिश्चित काल तक प्रोजेक्ट कर सकते हैं।",
    's2_step3':
        "कार्य: अब, साहुल रेखा उपकरण को विस्तारित बिंदीदार रेखा तक नीचे खींचें।\nअवलोकन: ऊंचाई PS पूरी तरह से त्रिभुज के बाहर 90° का कोण बनाती है।\nसीखा: अधिककोण त्रिभुजों में उनकी सीमा के बाहर ऊंचाई हो सकती है।",
    's2_step4':
        "कार्य: ध्यान दें कि ऊंचाई PS बाहर है। यह अधिककोण त्रिभुजों में होता है।\nअवलोकन: ऊंचाई बाहर है।\nसीखा: अधिककोण ऊंचाई को बाहर की ओर धकेलते हैं।",
    's2_sum':
        "ऊंचाइयां हमेशा अंदर नहीं गिरतीं! अधिककोण त्रिभुज में, दो ऊंचाइयां आकार के बाहर विस्तारित आधारों पर गिरेंगी।",

    's3_title': "3. त्रिभुज छँटाई कारखाना",
    's3_obj':
        "त्रिभुजों को उनकी भुजाओं की लंबाई के आधार पर समबाहु, समद्विबाहु और विषमबाहु के रूप में वर्गीकृत करने के लिए।",
    's3_step1':
        "कार्य: त्रिभुज को खींचें और उसकी भुजाओं की लंबाई के आधार पर सही छँटाई डिब्बे में छोड़ दें।\nअवलोकन: समद्विबाहु त्रिभुज '2 भुजाएं बराबर' डिब्बे में गया।\nसीखा: ठीक दो समान भुजाओं वाले त्रिभुज समद्विबाहु कहलाते हैं।",
    's3_step2':
        "कार्य: एक नया त्रिभुज प्रकट होता है। इसे खींचें और सही डिब्बे में छोड़ दें।\nअवलोकन: समबाहु त्रिभुज 'सभी भुजाएं बराबर' डिब्बे में गया।\nसीखा: तीन समान भुजाओं वाले त्रिभुज समबाहु होते हैं।",
    's3_step3':
        "कार्य: अंतिम त्रिभुज को सही डिब्बे में छाँटें।\nअवलोकन: विषमबाहु त्रिभुज 'कोई भुजा बराबर नहीं' डिब्बे में गया।\nसीखा: सभी अलग-अलग भुजाओं वाले त्रिभुज विषमबाहु होते हैं।",
    's3_sum':
        "बहुत बढ़िया! त्रिभुजों को वर्गीकृत किया गया है: समबाहु (3), समद्विबाहु (2), और विषमबाहु (0)।",

    's4_title': "4. समकोण की गुप्त पहचान",
    's4_obj':
        "यह पता लगाने के लिए कि समकोण त्रिभुज में, दो भुजाएं भी ऊंचाइयां हैं।",
    's4_step1':
        "कार्य: यहाँ एक समकोण त्रिभुज ABC है। साहुल रेखा को शीर्ष B से आधार AC तक खींचें।\nअवलोकन: B से ऊंचाई त्रिभुज के अंदर कर्ण पर गिरती है।\nसीखा: एक ऊंचाई आंतरिक है।",
    's4_step2':
        "कार्य: अब, शीर्ष A से ऊंचाई खोजने का प्रयास करें। साहुल रेखा को A से विपरीत आधार BC तक खींचें।\nअवलोकन: A से ऊंचाई भुजा AB पर पूरी तरह से आ जाती है।\nसीखा: समकोण त्रिभुज में, एक पैर ऊंचाई के रूप में कार्य करता है।",
    's4_step3':
        "कार्य: आखिरी वाली खोजें। साहुल रेखा को शीर्ष C से विपरीत आधार AB तक खींचें।\nअवलोकन: C से ऊंचाई भुजा CB पर पूरी तरह से आ जाती है।\nसीखा: दूसरा पैर भी एक ऊंचाई है।",
    's4_sum':
        "आपने रहस्य खोज लिया! समकोण त्रिभुज में, समकोण बनाने वाली दो भुजाएं भी ऊंचाइयां होती हैं!",

    's5_title': "5. त्रिभुज सैंडबॉक्स",
    's5_obj':
        "त्रिभुज के प्रकार और ऊंचाई की स्थिति के बीच संबंध का स्वतंत्र रूप से पता लगाने के लिए।",
    's5_step1':
        "कार्य: त्रिभुज का आकार बदलने के लिए किसी भी शीर्ष (A, B, C) को खींचें। 'ऊंचाई दिखाएं' पर क्लिक करें।\nअवलोकन: ऊंचाइयां गतिशील रूप से बदलती हैं। लंबकेंद्र (प्रतिच्छेदन बिंदु) चारों ओर घूमता है।\nसीखा: ऊंचाई की स्थिति त्रिभुज के कोणों से जुड़ी होती है।",
    's5_step2':
        "कार्य: चुनौती: शीर्षों में तब तक हेरफेर करें जब तक कि लंबकेंद्र पूरी तरह से त्रिभुज के बाहर न हो जाए।\nअवलोकन: जब त्रिभुज अधिककोण हो गया तो लंबकेंद्र बाहर चला गया।\nसीखा: अधिककोण त्रिभुज का लंबकेंद्र हमेशा बाहर स्थित होता है।",
    's5_sum':
        "आपने कर दिखाया! लंबकेंद्र तभी बाहर जाता है जब त्रिभुज अधिककोण होता है।",
  },
};

// --- MAIN SCREEN ---

class AltitudesandClassificationofTriangles extends StatefulWidget {
  const AltitudesandClassificationofTriangles({super.key});

  @override
  _AltitudesandClassificationofTrianglesState createState() =>
      _AltitudesandClassificationofTrianglesState();
}

class _AltitudesandClassificationofTrianglesState
    extends State<AltitudesandClassificationofTriangles>
    with SingleTickerProviderStateMixin {
  String _lang = 'en';
  bool _isSidebarOpen = true;
  int _scenario = 1;
  String _phase = 'init';

  double _zoom = 1.0;
  Offset _pan = const Offset(0, 20);

  // Geom elements
  GeomPoint? _geomA, _geomB, _geomC;
  PlumbTool? _plumb;
  List<SortableTriangle> _sortQueue = [];
  String? _binTarget;
  bool _baseExtended = false;
  List<int> _foundAltitudes = [];
  int _plumbTarget = 0;
  bool _sandboxShowAlt = false;

  String? _draggedVertex;
  bool _isDraggingPlumb = false;

  bool _showSuccessPopup = false;
  bool _isPlayingCurtain = true;

  Offset _compactStepPos = const Offset(20, 80);
  Offset? _popupPos;

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

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _phase = 'init';
      _plumb = null;
      _baseExtended = false;
      _sortQueue = [];
      _foundAltitudes = [];
      _plumbTarget = 0;
      _sandboxShowAlt = false;

      _draggedVertex = null;
      _isDraggingPlumb = false;

      _showSuccessPopup = false;
      _popupPos = null;
      _pan = const Offset(0, 20);
      _zoom = 1.0;

      if (_scenario == 1) {
        _geomA = GeomPoint(0, -100);
        _geomB = GeomPoint(-100, 100);
        _geomC = GeomPoint(120, 100);
        _plumb = PlumbTool(visible: true, px: 0, py: -40);
      } else if (_scenario == 2) {
        // P, Q, R technically, but mapped to A, B, C for rendering consistency
        _geomA = GeomPoint(-80, -100); // P
        _geomB = GeomPoint(20, 100); // Q
        _geomC = GeomPoint(150, 100); // R
        _plumb = PlumbTool(visible: true, px: -80, py: -40);
      } else if (_scenario == 3) {
        _geomA = null;
        _geomB = null;
        _geomC = null;
        _sortQueue = [
          SortableTriangle(type: 'isosceles', x: 0, y: -20),
          SortableTriangle(type: 'equilateral', x: 0, y: -20),
          SortableTriangle(type: 'scalene', x: 0, y: -20),
        ];
      } else if (_scenario == 4) {
        _geomA = GeomPoint(-100, -100);
        _geomB = GeomPoint(-100, 100);
        _geomC = GeomPoint(150, 100);
        _plumb = PlumbTool(visible: true, px: -100, py: 160);
      } else if (_scenario == 5) {
        _geomA = GeomPoint(0, -100);
        _geomB = GeomPoint(-120, 100);
        _geomC = GeomPoint(120, 100);
      }
    });
    _playSound('click');
  }

  void _triggerExtend() {
    setState(() {
      _baseExtended = true;
      _phase = 'extended';
    });
    _playSound('snap');
  }

  void _triggerToggleAlt() {
    setState(() {
      _sandboxShowAlt = !_sandboxShowAlt;
      if (_scenario == 5 && _sandboxShowAlt && _phase == 'init') {
        _phase = 'drag_1'; // Unlock dragging phase for S5 challenge
      }
    });
    _playSound('click');
  }

  void _triggerNext() {
    setState(() {
      if (_scenario == 1 && _phase == 'snapped') {
        _phase = 'complete';
        _playSound('success');
      }
    });
  }

  Offset _projectPointOnLine(Offset pt, Offset lineA, Offset lineB) {
    double dx = lineB.dx - lineA.dx;
    double dy = lineB.dy - lineA.dy;
    if (dx == 0 && dy == 0) return lineA;
    double t =
        ((pt.dx - lineA.dx) * dx + (pt.dy - lineA.dy) * dy) /
        (dx * dx + dy * dy);
    return Offset(lineA.dx + t * dx, lineA.dy + t * dy);
  }

  Offset _getOrthocenterOffset(Offset A, Offset B, Offset C) {
    double dx1 = C.dx - B.dx, dy1 = C.dy - B.dy;
    double dx2 = C.dx - A.dx, dy2 = C.dy - A.dy;
    double a1 = dx1, b1 = dy1, c1 = A.dx * a1 + A.dy * b1;
    double a2 = dx2, b2 = dy2, c2 = B.dx * a2 + B.dy * b2;
    double det = a1 * b2 - a2 * b1;
    if (det.abs() < 0.001) return Offset.zero;
    return Offset((c1 * b2 - c2 * b1) / det, (a1 * c2 - a2 * c1) / det);
  }

  bool _isPointInTriangle(Offset pt, Offset v1, Offset v2, Offset v3) {
    double d1 =
        (pt.dx - v2.dx) * (v1.dy - v2.dy) - (v1.dx - v2.dx) * (pt.dy - v2.dy);
    double d2 =
        (pt.dx - v3.dx) * (v2.dy - v3.dy) - (v2.dx - v3.dx) * (pt.dy - v3.dy);
    double d3 =
        (pt.dx - v1.dx) * (v3.dy - v1.dy) - (v3.dx - v1.dx) * (pt.dy - v1.dy);
    bool hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    bool hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    return !(hasNeg && hasPos);
  }

  void _handlePanDown(DragDownDetails details, Size size) {
    if (_phase == 'complete') return;

    double worldX =
        (details.localPosition.dx - size.width / 2 - _pan.dx) / _zoom;
    double worldY =
        (details.localPosition.dy - size.height / 2 - _pan.dy) / _zoom;
    Offset pt = Offset(worldX, worldY);

    setState(() {
      if (_scenario == 1 || _scenario == 2) {
        GeomPoint topV = _geomA!; // A or P
        if (_plumb != null && _plumb!.visible && !_plumb!.snapped) {
          if ((pt - Offset(_plumb!.px, _plumb!.py)).distance < 40 ||
              (pt - Offset(topV.x, topV.y)).distance < 40) {
            _isDraggingPlumb = true;
            if (_scenario == 1 && _phase == 'init') _phase = 'drag_1';
            _playSound('click');
          }
        }
      } else if (_scenario == 3) {
        if (_sortQueue.isNotEmpty) {
          SortableTriangle cur = _sortQueue[0];
          if ((pt - Offset(cur.x, cur.y)).distance < 50) {
            cur.isDragging = true;
            cur.error = false;
            _playSound('click');
          }
        }
      } else if (_scenario == 4) {
        if (_plumb != null && _plumb!.visible && !_plumb!.snapped) {
          List<GeomPoint> targets = [_geomB!, _geomA!, _geomC!];
          GeomPoint topV = targets[_plumbTarget];
          if ((pt - Offset(_plumb!.px, _plumb!.py)).distance < 40 ||
              (pt - Offset(topV.x, topV.y)).distance < 40) {
            _isDraggingPlumb = true;
            _playSound('click');
          }
        }
      } else if (_scenario == 5) {
        if ((pt - Offset(_geomA!.x, _geomA!.y)).distance < 30) {
          _draggedVertex = 'A';
          _playSound('click');
        } else if ((pt - Offset(_geomB!.x, _geomB!.y)).distance < 30) {
          _draggedVertex = 'B';
          _playSound('click');
        } else if ((pt - Offset(_geomC!.x, _geomC!.y)).distance < 30) {
          _draggedVertex = 'C';
          _playSound('click');
        }
      }
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    double worldX =
        (details.localPosition.dx - size.width / 2 - _pan.dx) / _zoom;
    double worldY =
        (details.localPosition.dy - size.height / 2 - _pan.dy) / _zoom;
    Offset pt = Offset(worldX, worldY);

    setState(() {
      if (_isDraggingPlumb) {
        GeomPoint topV = _geomA!;
        Offset proj = Offset.zero;

        if (_scenario == 4) {
          List<GeomPoint> fromPts = [_geomB!, _geomA!, _geomC!];
          List<List<GeomPoint>> lines = [
            [_geomA!, _geomC!],
            [_geomB!, _geomC!],
            [_geomA!, _geomB!],
          ];
          topV = fromPts[_plumbTarget];
          List<GeomPoint> tLine = lines[_plumbTarget];
          proj = _projectPointOnLine(
            Offset(topV.x, topV.y),
            Offset(tLine[0].x, tLine[0].y),
            Offset(tLine[1].x, tLine[1].y),
          );
        } else if (_scenario == 1) {
          proj = _projectPointOnLine(
            Offset(topV.x, topV.y),
            Offset(_geomB!.x, _geomB!.y),
            Offset(_geomC!.x, _geomC!.y),
          );
        } else if (_scenario == 2) {
          proj = _projectPointOnLine(
            Offset(topV.x, topV.y),
            Offset(_geomB!.x, _geomB!.y),
            Offset(_geomC!.x, _geomC!.y),
          );
        }

        _plumb!.px = pt.dx;
        _plumb!.py = pt.dy;

        if ((Offset(_plumb!.px, _plumb!.py) - proj).distance < 40) {
          bool isValid = true;
          if (_scenario == 2 && !_baseExtended && proj.dx < _geomB!.x) {
            isValid = false; // missing the base
          }

          if (isValid) {
            _plumb!.px = proj.dx;
            _plumb!.py = proj.dy;
            _plumb!.snapped = true;
            _isDraggingPlumb = false;
            _playSound('snap');

            if (_scenario == 4) {
              _foundAltitudes.add(_plumbTarget);
              if (_foundAltitudes.length == 3) {
                _phase = 'complete';
                _playSound('success');
              } else {
                _phase = 'drag_${_foundAltitudes.length + 1}';
                _plumbTarget = _foundAltitudes.length;
                List<GeomPoint> fromPts = [_geomB!, _geomA!, _geomC!];
                GeomPoint nTop = fromPts[_plumbTarget];
                _plumb = PlumbTool(visible: true, px: nTop.x, py: nTop.y + 60);
              }
            } else {
              _phase =
                  (_scenario == 2 && _baseExtended) ? 'complete' : 'snapped';
              if (_phase == 'complete') _playSound('success');
            }
          }
        }
      } else if (_scenario == 3 &&
          _sortQueue.isNotEmpty &&
          _sortQueue[0].isDragging) {
        SortableTriangle cur = _sortQueue[0];
        cur.x = pt.dx;
        cur.y = pt.dy;
        _binTarget = null;
        if (cur.y > 50) {
          if (cur.x < -100) {
            _binTarget = 'equilateral';
          } else if (cur.x > 100)
            _binTarget = 'scalene';
          else
            _binTarget = 'isosceles';
        }
      } else if (_scenario == 5 && _draggedVertex != null) {
        GeomPoint v =
            _draggedVertex == 'A'
                ? _geomA!
                : (_draggedVertex == 'B' ? _geomB! : _geomC!);
        // Allowing broader dragging area
        v.x = math.max(-250.0, math.min(250.0, pt.dx));
        v.y = math.max(-150.0, math.min(150.0, pt.dy));

        // Evaluate Completion Condition in Scenario 5
        if (_phase == 'drag_1' && _sandboxShowAlt) {
          Offset vA = Offset(_geomA!.x, _geomA!.y);
          Offset vB = Offset(_geomB!.x, _geomB!.y);
          Offset vC = Offset(_geomC!.x, _geomC!.y);
          Offset orth = _getOrthocenterOffset(vA, vB, vC);

          if (!_isPointInTriangle(orth, vA, vB, vC)) {
            _phase = 'complete';
            _playSound('success');
          }
        }
      } else {
        _pan += details.delta;
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      if (_isDraggingPlumb) {
        _isDraggingPlumb = false;
        if (_scenario == 2 && !_baseExtended && _phase == 'init') {
          if (_plumb!.py > 50) {
            _phase = 'missed';
            _playSound('error');
          }
        }
      } else if (_scenario == 3 &&
          _sortQueue.isNotEmpty &&
          _sortQueue[0].isDragging) {
        SortableTriangle cur = _sortQueue[0];
        cur.isDragging = false;
        if (_binTarget != null) {
          if (_binTarget == cur.type) {
            _playSound('success');
            _sortQueue.removeAt(0);
            _binTarget = null;
            if (_sortQueue.isEmpty) {
              _phase = 'complete';
            } else {
              _phase = 'drag_${3 - _sortQueue.length + 1}';
            }
          } else {
            _playSound('error');
            cur.error = true;
            cur.x = 0;
            cur.y = -20;
            _binTarget = null;
          }
        } else {
          cur.x = 0;
          cur.y = -20;
        }
      } else if (_scenario == 5 && _draggedVertex != null) {
        _draggedVertex = null;
      }
    });
  }

  int _getPseudoStep() {
    int pseudoStep = 0;
    if (_scenario == 1) {
      if (_phase == 'init') {
        pseudoStep = 0;
      } else if (_phase == 'drag_1')
        pseudoStep = 0;
      else if (_phase == 'snapped')
        pseudoStep = 1;
      else if (_phase == 'complete')
        pseudoStep = 2;
    } else if (_scenario == 2) {
      if (_phase == 'init') {
        pseudoStep = 0;
      } else if (_phase == 'missed')
        pseudoStep = 1;
      else if (_phase == 'extended')
        pseudoStep = 2;
      else if (_phase == 'complete')
        pseudoStep = 3;
    } else if (_scenario == 3) {
      pseudoStep = 3 - _sortQueue.length;
    } else if (_scenario == 4) {
      pseudoStep = _foundAltitudes.length;
    } else if (_scenario == 5) {
      if (_phase == 'init') {
        pseudoStep = 0;
      } else if (_phase == 'drag_1')
        pseudoStep = 1;
      else if (_phase == 'complete')
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
                ),
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
                    // Scenario Dropdown Selection
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
    int maxSteps =
        (_scenario == 1)
            ? 3
            : (_scenario == 2
                ? 4
                : (_scenario == 3 ? 3 : (_scenario == 4 ? 3 : 2)));

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
    List<Widget> buttons = [];

    if (_scenario == 1 && _phase == 'snapped') {
      buttons.add(
        _customButton(
          t('nextBtn'),
          Icons.arrow_right,
          Colors.green,
          _triggerNext,
        ),
      );
    }

    if (_scenario == 2 && _phase == 'missed') {
      buttons.add(
        _customButton(
          t('extendBtn'),
          Icons.arrow_right_alt,
          Colors.blue,
          _triggerExtend,
        ),
      );
    }

    if (_scenario == 5) {
      buttons.add(
        _customButton(
          _sandboxShowAlt ? t('hideAltBtn') : t('showAltBtn'),
          Icons.height,
          Colors.indigo,
          _triggerToggleAlt,
        ),
      );
    }

    if (_phase == 'complete') {
      if (_scenario < 5) {
        buttons.add(
          _customButton(
            t('nextScenario'),
            Icons.navigate_next,
            Colors.green,
            () => _loadScenario(_scenario + 1),
          ),
        );
      } else {
        buttons.add(
          _customButton(t('doneBtn'), Icons.done_all, Colors.green, () {
            setState(() {
              _showSuccessPopup = true;
            });
            _playSound('success');
          }),
        );
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: buttons,
    );
  }

  Widget _customButton(
    String text,
    IconData icon,
    MaterialColor color,
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
        backgroundColor: color.shade500,
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
                      painter: AltitudeGeometryPainter(
                        geomA: _geomA,
                        geomB: _geomB,
                        geomC: _geomC,
                        plumb: _plumb,
                        sortQueue: _sortQueue,
                        binTarget: _binTarget,
                        baseExtended: _baseExtended,
                        scenario: _scenario,
                        phase: _phase,
                        zoom: _zoom,
                        pan: _pan,
                        draggedVertex: _draggedVertex,
                        isDraggingPlumb: _isDraggingPlumb,
                        foundAltitudes: _foundAltitudes,
                        plumbTarget: _plumbTarget,
                        sandboxShowAlt: _sandboxShowAlt,
                        themeIsLight: false,
                        translations:
                            translations[_lang] ?? translations['en']!,
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

            // Top Left Menu Button
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

            // Compact Active Step Tracker on Canvas
            if (!_isSidebarOpen && _phase != 'complete')
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

class AltitudeGeometryPainter extends CustomPainter {
  final GeomPoint? geomA, geomB, geomC;
  final PlumbTool? plumb;
  final List<SortableTriangle> sortQueue;
  final String? binTarget;
  final bool baseExtended;
  final int scenario;
  final String phase;
  final double zoom;
  final Offset pan;
  final String? draggedVertex;
  final bool isDraggingPlumb;
  final List<int> foundAltitudes;
  final int plumbTarget;
  final bool sandboxShowAlt;
  final bool themeIsLight;
  final Map<String, String> translations;

  AltitudeGeometryPainter({
    required this.geomA,
    required this.geomB,
    required this.geomC,
    required this.plumb,
    required this.sortQueue,
    required this.binTarget,
    required this.baseExtended,
    required this.scenario,
    required this.phase,
    required this.zoom,
    required this.pan,
    required this.draggedVertex,
    required this.isDraggingPlumb,
    required this.foundAltitudes,
    required this.plumbTarget,
    required this.sandboxShowAlt,
    required this.themeIsLight,
    required this.translations,
  });

  Offset projectPointOnLine(Offset pt, Offset lineA, Offset lineB) {
    double dx = lineB.dx - lineA.dx;
    double dy = lineB.dy - lineA.dy;
    if (dx == 0 && dy == 0) return lineA;
    double t =
        ((pt.dx - lineA.dx) * dx + (pt.dy - lineA.dy) * dy) /
        (dx * dx + dy * dy);
    return Offset(lineA.dx + t * dx, lineA.dy + t * dy);
  }

  Offset getOrthocenter(Offset A, Offset B, Offset C) {
    double dx1 = C.dx - B.dx, dy1 = C.dy - B.dy;
    double dx2 = C.dx - A.dx, dy2 = C.dy - A.dy;
    double a1 = dx1, b1 = dy1, c1 = A.dx * a1 + A.dy * b1;
    double a2 = dx2, b2 = dy2, c2 = B.dx * a2 + B.dy * b2;
    double det = a1 * b2 - a2 * b1;
    if (det.abs() < 0.001) return Offset.zero;
    return Offset((c1 * b2 - c2 * b1) / det, (a1 * c2 - a2 * c1) / det);
  }

  double getAngleDeg(Offset A, Offset B, Offset C) {
    double ab = (A - B).distance;
    double bc = (C - B).distance;
    double ac = (C - A).distance;
    double cosB = (ab * ab + bc * bc - ac * ac) / (2 * ab * bc);
    return math.acos(math.max(-1.0, math.min(1.0, cosB))) * 180 / math.pi;
  }

  bool isPointInTriangle(Offset pt, Offset v1, Offset v2, Offset v3) {
    double d1 =
        (pt.dx - v2.dx) * (v1.dy - v2.dy) - (v1.dx - v2.dx) * (pt.dy - v2.dy);
    double d2 =
        (pt.dx - v3.dx) * (v2.dy - v3.dy) - (v2.dx - v3.dx) * (pt.dy - v3.dy);
    double d3 =
        (pt.dx - v1.dx) * (v3.dy - v1.dy) - (v3.dx - v1.dx) * (pt.dy - v1.dy);
    bool hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    bool hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    return !(hasNeg && hasPos);
  }

  void draw90Symbol(
    Canvas canvas,
    Offset v,
    Offset baseA,
    Offset baseB,
    Offset proj,
  ) {
    canvas.save();
    double angLine = math.atan2(v.dy - proj.dy, v.dx - proj.dx);
    double angBase = math.atan2(baseA.dy - proj.dy, baseA.dx - proj.dx);

    double diff = angLine - angBase;
    while (diff <= -math.pi) {
      diff += 2 * math.pi;
    }
    while (diff > math.pi) {
      diff -= 2 * math.pi;
    }

    canvas.translate(proj.dx, proj.dy);
    canvas.rotate(angBase);
    double size = 15;
    double dir = diff > 0 ? 1 : -1;

    Path path = Path();
    path.moveTo(size, 0);
    path.lineTo(size, size * dir);
    path.lineTo(0, size * dir);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFf43f5e)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  void drawPlumbTool(Canvas canvas, Offset start, Offset end, bool dragging) {
    canvas.save();
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    canvas.translate(end.dx, end.dy);
    double ang = math.atan2(end.dy - start.dy, end.dx - start.dx);
    canvas.rotate(ang - math.pi / 2);

    Path bob = Path();
    bob.moveTo(0, 0);
    bob.lineTo(-8, 15);
    bob.lineTo(0, 25);
    bob.lineTo(8, 15);
    bob.close();

    canvas.drawPath(
      bob,
      Paint()
        ..color = dragging ? const Color(0xFF38bdf8) : const Color(0xFFe2e8f0)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      bob,
      Paint()
        ..color = const Color(0xFF64748b)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  void drawSortingTriangle(
    Canvas canvas,
    String type,
    double x,
    double y,
    double size,
    bool dropError,
  ) {
    canvas.save();
    canvas.translate(x, y);

    List<Offset> pts = [];
    if (type == 'equilateral') {
      pts = [
        Offset(0, -size),
        Offset(size * 0.866, size * 0.5),
        Offset(-size * 0.866, size * 0.5),
      ];
    } else if (type == 'isosceles') {
      pts = [
        Offset(0, -size * 1.2),
        Offset(size * 0.6, size * 0.6),
        Offset(-size * 0.6, size * 0.6),
      ];
    } else {
      pts = [
        Offset(-size * 0.2, -size),
        Offset(size, size * 0.4),
        Offset(-size * 0.8, size * 0.6),
      ];
    }

    Path path =
        Path()
          ..moveTo(pts[0].dx, pts[0].dy)
          ..lineTo(pts[1].dx, pts[1].dy)
          ..lineTo(pts[2].dx, pts[2].dy)
          ..close();

    Color fillColor =
        dropError
            ? const Color(0xFFf43f5e).withOpacity(0.4)
            : const Color(0xFF6366f1).withOpacity(0.4);
    Color strokeColor =
        dropError ? const Color(0xFFf43f5e) : const Color(0xFF6366f1);

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Draw tick marks
    Paint tickPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    void drawTick(Offset p1, Offset p2, int count) {
      double mx = (p1.dx + p2.dx) / 2;
      double my = (p1.dy + p2.dy) / 2;
      double ang = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx) + math.pi / 2;
      double spacing = 6;
      double tLen = 8;
      double startOffset = -(count - 1) * spacing / 2;
      for (int i = 0; i < count; i++) {
        double ox =
            mx + (startOffset + i * spacing) * math.cos(ang - math.pi / 2);
        double oy =
            my + (startOffset + i * spacing) * math.sin(ang - math.pi / 2);
        canvas.drawLine(
          Offset(ox - tLen * math.cos(ang), oy - tLen * math.sin(ang)),
          Offset(ox + tLen * math.cos(ang), oy + tLen * math.sin(ang)),
          tickPaint,
        );
      }
    }

    if (type == 'equilateral') {
      drawTick(pts[0], pts[1], 1);
      drawTick(pts[1], pts[2], 1);
      drawTick(pts[2], pts[0], 1);
    } else if (type == 'isosceles') {
      drawTick(pts[0], pts[1], 2);
      drawTick(pts[2], pts[0], 2);
      drawTick(pts[1], pts[2], 1);
    } else {
      drawTick(pts[0], pts[1], 1);
      drawTick(pts[1], pts[2], 2);
      drawTick(pts[2], pts[0], 3);
    }
    canvas.restore();
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
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Constant Dark Canvas Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF020617),
    );

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

    if (scenario == 3) {
      canvas.drawRect(
        Rect.fromLTWH(-300, -20, 600, 40),
        Paint()..color = const Color(0xFF334155),
      );
      for (double i = -300; i < 300; i += 40) {
        canvas.drawLine(
          Offset(i, -20),
          Offset(i, 20),
          Paint()
            ..color = const Color(0xFF475569)
            ..strokeWidth = 3,
        );
      }

      var bins = [
        {
          'id': 'equilateral',
          'title': 'All Sides Equal',
          'x': -200.0,
          'color': const Color(0xFF3b82f6),
        },
        {
          'id': 'isosceles',
          'title': '2 Sides Equal',
          'x': 0.0,
          'color': const Color(0xFF8b5cf6),
        },
        {
          'id': 'scalene',
          'title': 'No Sides Equal',
          'x': 200.0,
          'color': const Color(0xFFf59e0b),
        },
      ];

      for (var b in bins) {
        canvas.save();
        canvas.translate(b['x'] as double, 150);
        bool isTarget = binTarget == b['id'];
        Color bColor = b['color'] as Color;

        Path binShape =
            Path()
              ..moveTo(-60, -30)
              ..lineTo(60, -30)
              ..lineTo(40, 50)
              ..lineTo(-40, 50)
              ..close();
        canvas.drawPath(
          binShape,
          Paint()
            ..color =
                isTarget ? bColor : const Color(0xFF1e293b).withOpacity(0.8),
        );
        canvas.drawPath(
          binShape,
          Paint()
            ..color = bColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );

        TextSpan span = TextSpan(
          style: TextStyle(
            color: isTarget ? Colors.white : bColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          text: b['title'] as String,
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }

      if (sortQueue.isNotEmpty) {
        SortableTriangle cur = sortQueue[0];
        drawSortingTriangle(canvas, cur.type, cur.x, cur.y, 45, cur.error);
      }

      if (phase == 'complete') {
        TextSpan span = const TextSpan(
          style: TextStyle(
            color: Color(0xFF10b981),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          text: 'All Triangles Sorted!',
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(-tp.width / 2, -100));
      }
    } else if (geomA != null && geomB != null && geomC != null) {
      Offset vA = Offset(geomA!.x, geomA!.y);
      Offset vB = Offset(geomB!.x, geomB!.y);
      Offset vC = Offset(geomC!.x, geomC!.y);

      if (scenario == 5 && sandboxShowAlt) {
        Offset altA = projectPointOnLine(vA, vB, vC);
        Offset altB = projectPointOnLine(vB, vA, vC);
        Offset altC = projectPointOnLine(vC, vA, vB);

        Paint baseDash =
            Paint()
              ..color = const Color(0xFF64748b)
              ..strokeWidth = 2;

        // Base extension visuals
        _drawDashedLine(canvas, vB, altA, baseDash);
        _drawDashedLine(canvas, vC, altA, baseDash);
        _drawDashedLine(canvas, vA, altB, baseDash);
        _drawDashedLine(canvas, vC, altB, baseDash);
        _drawDashedLine(canvas, vA, altC, baseDash);
        _drawDashedLine(canvas, vB, altC, baseDash);
      }

      if (scenario == 2 && baseExtended) {
        canvas.drawLine(
          vB,
          Offset(vB.dx - 150, vB.dy),
          Paint()
            ..color = const Color(0xFF64748b)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        ); // dotted ideal
      }

      Path triPath =
          Path()
            ..moveTo(vA.dx, vA.dy)
            ..lineTo(vB.dx, vB.dy)
            ..lineTo(vC.dx, vC.dy)
            ..close();
      canvas.drawPath(
        triPath,
        Paint()
          ..color = const Color(0xFF6366f1).withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        triPath,
        Paint()
          ..color = const Color(0xFF6366f1).withOpacity(0.8)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );

      if (scenario == 4) {
        canvas.drawLine(
          vB + const Offset(0, -15),
          vB + const Offset(15, -15),
          Paint()
            ..color = const Color(0xFF6366f1)
            ..strokeWidth = 2,
        );
        canvas.drawLine(
          vB + const Offset(15, -15),
          vB + const Offset(15, 0),
          Paint()
            ..color = const Color(0xFF6366f1)
            ..strokeWidth = 2,
        );
      }

      if (scenario == 1 || scenario == 2) {
        Offset topV = scenario == 1 ? vA : vA; // P is mapped to A
        Offset baseA = vB; // B or Q
        Offset baseB = vC; // C or R

        if (plumb != null && plumb!.snapped) {
          Offset projPt = Offset(plumb!.px, plumb!.py);
          canvas.drawLine(
            topV,
            projPt,
            Paint()
              ..color = const Color(0xFFf43f5e)
              ..strokeWidth = 3,
          );
          draw90Symbol(canvas, topV, baseB, baseA, projPt);
        } else if (plumb != null && plumb!.visible) {
          drawPlumbTool(
            canvas,
            topV,
            Offset(plumb!.px, plumb!.py),
            isDraggingPlumb,
          );
        }
      } else if (scenario == 4) {
        List<Map<String, dynamic>> targets = [
          {
            'from': vB,
            'line': [vA, vC],
            'proj': projectPointOnLine(vB, vA, vC),
          },
          {
            'from': vA,
            'line': [vB, vC],
            'proj': vB,
          },
          {
            'from': vC,
            'line': [vA, vB],
            'proj': vB,
          },
        ];

        for (int idx in foundAltitudes) {
          var t = targets[idx];
          Offset tFrom = t['from'] as Offset;
          Offset tProj = t['proj'] as Offset;
          List<Offset> tLine = t['line'] as List<Offset>;

          canvas.drawLine(
            tFrom,
            tProj,
            Paint()
              ..color = const Color(0xFFf43f5e)
              ..strokeWidth = idx == 0 ? 3 : 6,
          );
          if (idx == 0) draw90Symbol(canvas, tFrom, tLine[1], tLine[0], tProj);
        }

        if (plumb != null && plumb!.visible) {
          Offset topV = targets[plumbTarget]['from'] as Offset;
          drawPlumbTool(
            canvas,
            topV,
            Offset(plumb!.px, plumb!.py),
            isDraggingPlumb,
          );
        }

        TextSpan span = TextSpan(
          style: const TextStyle(
            color: Color(0xFFf43f5e),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          text: "${translations['s4_counter']}: ${foundAltitudes.length}/3",
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(-tp.width / 2, -160));
      } else if (scenario == 5) {
        if (sandboxShowAlt) {
          Offset altA = projectPointOnLine(vA, vB, vC);
          Offset altB = projectPointOnLine(vB, vA, vC);
          Offset altC = projectPointOnLine(vC, vA, vB);

          Offset orth = getOrthocenter(vA, vB, vC);

          Paint altPaint =
              Paint()
                ..color = const Color(0xFFf43f5e)
                ..strokeWidth = 2;
          Paint dashPaint =
              Paint()
                ..color = const Color(0xFFf43f5e).withOpacity(0.5)
                ..strokeWidth = 2;

          // Solid altitudes
          canvas.drawLine(vA, altA, altPaint);
          canvas.drawLine(vB, altB, altPaint);
          canvas.drawLine(vC, altC, altPaint);

          // Dashed extended lines to orthocenter
          _drawDashedLine(canvas, altA, orth, dashPaint);
          _drawDashedLine(canvas, altB, orth, dashPaint);
          _drawDashedLine(canvas, altC, orth, dashPaint);

          bool isOut = !isPointInTriangle(orth, vA, vB, vC);
          canvas.drawCircle(
            orth,
            8,
            Paint()
              ..color =
                  isOut ? const Color(0xFF10b981) : const Color(0xFFf43f5e),
          );
        }

        TextPainter tp = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.text = TextSpan(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          text: "${getAngleDeg(vB, vA, vC).round()}°",
        );
        tp.layout();
        tp.paint(canvas, vA + const Offset(-10, -25));

        tp.text = TextSpan(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          text: "${getAngleDeg(vA, vB, vC).round()}°",
        );
        tp.layout();
        tp.paint(canvas, vB + const Offset(-30, 0));

        tp.text = TextSpan(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          text: "${getAngleDeg(vA, vC, vB).round()}°",
        );
        tp.layout();
        tp.paint(canvas, vC + const Offset(15, 0));
      }

      List<String> vNames = scenario == 2 ? ['P', 'Q', 'R'] : ['A', 'B', 'C'];
      for (int i = 0; i < 3; i++) {
        GeomPoint actV = i == 0 ? geomA! : (i == 1 ? geomB! : geomC!);
        Color c =
            (scenario == 5 && draggedVertex == vNames[i])
                ? const Color(0xFF38bdf8)
                : const Color(0xFF6366f1);
        canvas.drawCircle(
          Offset(actV.x, actV.y),
          scenario == 5 ? 10 : 6,
          Paint()..color = c,
        );
      }

      if (scenario == 1 && plumb != null && plumb!.snapped) {
        drawVertexLabel(
          canvas,
          'D',
          Offset(plumb!.px, plumb!.py),
          offset: const Offset(10, 25),
        );
      }
      if (scenario == 2 && plumb != null && plumb!.snapped) {
        drawVertexLabel(
          canvas,
          'S',
          Offset(plumb!.px, plumb!.py),
          offset: const Offset(-10, 25),
        );
      }

      if (scenario == 1 && phase == 'complete') {
        TextSpan span = TextSpan(
          style: const TextStyle(
            color: Color(0xFF10b981),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          text: translations['s1_canvas_inside'] ?? '',
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, vA + const Offset(10, 100));
      }

      if (scenario == 4) {
        drawVertexLabel(canvas, 'A', vA, offset: const Offset(0, -20));
        drawVertexLabel(canvas, 'B', vB, offset: const Offset(-20, 20));
        drawVertexLabel(canvas, 'C', vC, offset: const Offset(20, 20));
      } else if (scenario == 2) {
        drawVertexLabel(canvas, 'Q', vB, offset: const Offset(-20, 20));
        drawVertexLabel(canvas, 'R', vC, offset: const Offset(20, 20));
        drawVertexLabel(canvas, 'P', vA, offset: const Offset(0, -20));
      } else {
        drawVertexLabel(canvas, 'B', vB, offset: const Offset(-20, 20));
        drawVertexLabel(canvas, 'C', vC, offset: const Offset(20, 20));
        drawVertexLabel(canvas, 'A', vA, offset: const Offset(0, -20));
      }
    }
  }

  @override
  bool shouldRepaint(AltitudeGeometryPainter oldDelegate) => true;
}
