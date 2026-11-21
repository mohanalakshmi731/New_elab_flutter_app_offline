// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cl6M_Ch9_A2_ExploringLineSymmetry(),
    ),
  );
}

// --- AUDIO ENGINE ---
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  // Play a standard interaction sound (Clicks/Snaps)
  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  // Play a sound when a new page/scenario opens or completes
  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  // Play the Dropdown sound
  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  // Play an error sound (Soft thud)
  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  // Cinematic tone for the curtain screen
  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle': "The Mirror Lab: Exploring Line Symmetry",
    'appTitle': "Exploring Line Symmetry",
    'appSubtitle': "Class 6 • GEOMETRY & SYMMETRY",
    'enterLab': "Enter Lab",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Objective:",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You have successfully mastered Line Symmetry by creating perfect mirror images!",
    'lbl_reflect': "REFLECT",
    's1_title': "1. The Butterfly's Wings",
    's1_obj':
        "To understand the basic concept of a single line of symmetry as a perfect mirror line.",
    's1_step1_task':
        "CLICK the 'Reflect' button to give the butterfly its other wing.",
    's1_step1_out':
        "Perfect! The line down the middle acts like a mirror. This is called a Line of Symmetry. It divides the butterfly into two identical halves.",
    's1_hud1': "Click 'Reflect' to mirror the wing.",
    's2_title': "2. The Paper Folding Square",
    's2_obj':
        "To discover that a single shape can have multiple lines of symmetry.",
    's2_step1_task':
        "DRAG the vertical dotted line onto the center of the square.",
    's2_step1_out':
        "The square folds perfectly! A vertical line divides it into identical mirror halves.",
    's2_step2_task':
        "Now, DRAG the horizontal dotted line onto the center of the square.",
    's2_step2_out':
        "It folds perfectly again! The horizontal line is also a line of symmetry.",
    's2_step3_task':
        "Great! Try the two diagonal lines now. DRAG them one by one onto the square.",
    's2_step3_out':
        "Amazing! A square has 4 lines of symmetry. Any of these lines can divide it into perfect mirror halves.",
    's2_hud1': "Drag the vertical line to the center.",
    's2_hud2': "Drag the horizontal line to the center.",
    's2_hud3': "Drag the two diagonal lines.",
    's3_title': "3. The Rectangle's Mistake",
    's3_obj':
        "To learn that not all lines that divide a shape are lines of symmetry.",
    's3_step1_task':
        "Let's test a rectangle. DRAG the diagonal dotted line onto it.",
    's3_step1_out':
        "See? The halves don't match! A diagonal is NOT a line of symmetry for a rectangle. The corners stick out.",
    's3_hud1': "Drag the diagonal line onto the rectangle.",
    's4_title': "4. The Ink Blot Creator",
    's4_obj':
        "To create a symmetrical pattern by applying the concept of reflection.",
    's4_step1_task':
        "Let's make symmetrical art! CLICK on the left side of the screen to drop an ink blot.",
    's4_step1_out': "An identical, mirrored ink blot appeared on the right!",
    's4_step2_task':
        "Choose colors from the palette and CLICK 4 more times to create your masterpiece.",
    's4_step2_out':
        "You've created a perfectly symmetrical figure! Every blot you placed was reflected across the line of symmetry.",
    's4_hud1': "Click anywhere on the left side to drop ink.",
    's4_hud2': "Add more ink blots to complete your art.",
    's5_title': "5. The Symmetrical Grid Puzzle",
    's5_obj':
        "To complete a symmetrical figure by correctly placing its missing reflected parts.",
    's5_step1_task':
        "Half of this pattern is missing! DRAG the colored tiles from the bottom and DROP them onto the grid to complete the symmetrical design.",
    's5_step1_out':
        "Puzzle Solved! You used the line of symmetry to perfectly reflect the pattern.",
    's5_hud1': "Drag tiles to mirror the pattern on the right.",
  },
  'hi': {
    'shutterTitle': "द मिरर लैब: लाइन सिमेट्री की खोज",
    'appTitle': "लाइन सिमेट्री की खोज",
    'appSubtitle': "कक्षा 6 • ज्यामिति और सममिति",
    'enterLab': "लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "उद्देश्य:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc':
        "आपने एकदम सही दर्पण चित्र बनाकर लाइन सिमेट्री में महारत हासिल कर ली है!",
    'lbl_reflect': "प्रतिबिंबित करें",
    's1_title': "1. तितली के पंख",
    's1_obj':
        "एक पूर्ण दर्पण रेखा के रूप में सममिति की एक रेखा की मूल अवधारणा को समझने के लिए।",
    's1_step1_task':
        "तितली को उसका दूसरा पंख देने के लिए 'प्रतिबिंबित करें' बटन पर क्लिक करें।",
    's1_step1_out':
        "उत्तम! बीच की रेखा दर्पण का काम करती है। इसे सममिति रेखा कहते हैं। यह तितली को दो समान भागों में बाँटती है।",
    's1_hud1':
        "पंख को प्रतिबिंबित करने के लिए 'प्रतिबिंबित करें' पर क्लिक करें।",
    's2_title': "2. पेपर फोल्डिंग स्क्वायर",
    's2_obj': "यह खोजना कि एक ही आकार में सममिति की कई रेखाएँ हो सकती हैं।",
    's2_step1_task':
        "ऊर्ध्वाधर (vertical) बिंदीदार रेखा को वर्ग के केंद्र में खींचें।",
    's2_step1_out':
        "वर्ग पूरी तरह मुड़ जाता है! एक ऊर्ध्वाधर रेखा इसे समान दर्पण भागों में विभाजित करती है।",
    's2_step2_task':
        "अब, क्षैतिज (horizontal) बिंदीदार रेखा को वर्ग के केंद्र में खींचें।",
    's2_step2_out':
        "यह फिर से पूरी तरह से मुड़ जाता है! क्षैतिज रेखा भी सममिति की एक रेखा है।",
    's2_step3_task':
        "बहुत बढ़िया! अब दो विकर्ण (diagonal) रेखाओं को आजमाएं। उन्हें एक-एक करके वर्ग पर खींचें।",
    's2_step3_out':
        "अद्भुत! एक वर्ग में सममिति की 4 रेखाएँ होती हैं। इनमें से कोई भी रेखा इसे पूर्ण दर्पण भागों में विभाजित कर सकती है।",
    's2_hud1': "ऊर्ध्वाधर रेखा को केंद्र में खींचें।",
    's2_hud2': "क्षैतिज रेखा को केंद्र में खींचें।",
    's2_hud3': "दो विकर्ण रेखाओं को खींचें।",
    's3_title': "3. आयत की गलती",
    's3_obj':
        "यह जानने के लिए कि किसी आकार को विभाजित करने वाली सभी रेखाएँ सममिति की रेखाएँ नहीं होती हैं।",
    's3_step1_task':
        "आइए एक आयत का परीक्षण करें। विकर्ण बिंदीदार रेखा को उस पर खींचें।",
    's3_step1_out':
        "देखा? दोनों हिस्से मेल नहीं खाते! एक विकर्ण आयत के लिए सममिति की रेखा नहीं है। कोने बाहर निकल जाते हैं।",
    's3_hud1': "विकर्ण रेखा को आयत पर खींचें।",
    's4_title': "4. इंक ब्लॉट क्रिएटर",
    's4_obj': "प्रतिबिंब की अवधारणा को लागू करके एक सममित पैटर्न बनाने के लिए।",
    's4_step1_task':
        "आइए सममित कला बनाएं! इंक ब्लॉट गिराने के लिए स्क्रीन के बाईं ओर क्लिक करें।",
    's4_step1_out': "दाईं ओर एक समान, प्रतिबिंबित इंक ब्लॉट दिखाई दिया!",
    's4_step2_task':
        "पैलेट से रंग चुनें और अपनी उत्कृष्ट कृति बनाने के लिए 4 बार और क्लिक करें।",
    's4_step2_out':
        "आपने एक पूर्ण सममित आकृति बनाई है! आपके द्वारा रखा गया हर ब्लॉट सममिति रेखा के पार प्रतिबिंबित होता था।",
    's4_hud1': "स्याही गिराने के लिए बाईं ओर कहीं भी क्लिक करें।",
    's4_hud2': "अपनी कला को पूरा करने के लिए और इंक ब्लॉट जोड़ें।",
    's5_title': "5. सममित ग्रिड पहेली",
    's5_obj':
        "इसके लापता प्रतिबिंबित भागों को सही ढंग से रखकर एक सममित आकृति को पूरा करने के लिए।",
    's5_step1_task':
        "इस पैटर्न का आधा हिस्सा गायब है! सममित डिज़ाइन को पूरा करने के लिए नीचे से रंगीन टाइलों को खींचें और ग्रिड पर छोड़ें।",
    's5_step1_out':
        "पहेली हल हो गई! आपने पैटर्न को पूरी तरह से प्रतिबिंबित करने के लिए सममिति रेखा का उपयोग किया।",
    's5_hud1': "दाईं ओर के पैटर्न को प्रतिबिंबित करने के लिए टाइलों को खींचें।",
  },
};

String t(String key, String lang) {
  return i18n[lang]?[key] ?? i18n['en']![key] ?? key;
}

// --- MODELS ---
class SymLine {
  String id;
  String type;
  double x;
  double y;
  bool used;
  double angle;
  SymLine({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.used = false,
    required this.angle,
  });
}

class InkBlot {
  double x;
  double y;
  Color color;
  double seed;
  InkBlot({
    required this.x,
    required this.y,
    required this.color,
    required this.seed,
  });
}

class GridTile {
  int r;
  int c;
  Color color;
  GridTile({required this.r, required this.c, required this.color});
}

class DragEntity {
  String type;
  String? id;
  double angle;
  Color? color;
  DragEntity({required this.type, this.id, this.angle = 0, this.color});
}

// --- MAIN APP WIDGET ---
class Cl6M_Ch9_A2_ExploringLineSymmetry extends StatefulWidget {
  const Cl6M_Ch9_A2_ExploringLineSymmetry({super.key});
  @override
  State<Cl6M_Ch9_A2_ExploringLineSymmetry> createState() =>
      _Cl6M_Ch9_A2_ExploringLineSymmetryState();
}

class _Cl6M_Ch9_A2_ExploringLineSymmetryState
    extends State<Cl6M_Ch9_A2_ExploringLineSymmetry>
    with TickerProviderStateMixin {
  String lang = 'en';
  bool showCurtain = true;
  bool sidebarOpen = true;
  double sidebarWidth = 350;
  bool showSuccessPopup = false;

  double zoom = 1.0;
  double panX = 0;
  double panY = 0;

  int scenario = 1;
  int step = 0;

  // Canvas State
  GlobalKey canvasKey = GlobalKey();
  late AnimationController _gameLoop;

  // Sim State
  bool animating = false;
  double animProgress = 0.0;
  int? animStartTime;
  int animDuration = 1000;

  bool s1_reflected = false;

  List<SymLine> s2_lines = [];
  String? s2_foldType;

  SymLine s3_line = SymLine(
    id: 'd',
    type: 'diag',
    x: -250,
    y: 0,
    angle: atan2(150, -300),
  );

  List<InkBlot> s4_blots = [];
  Color s4_color = const Color(0xFFEF4444);
  List<Color> s4_palette = [
    const Color(0xFFEF4444),
    const Color(0xFF3B82F6),
    const Color(0xFF22C55E),
    const Color(0xFFF59E0B),
    const Color(0xFFA855F7),
  ];

  List<GridTile> s5_left_pattern = [
    GridTile(r: 1, c: 1, color: const Color(0xFFEF4444)),
    GridTile(r: 2, c: 2, color: const Color(0xFF3B82F6)),
    GridTile(r: 3, c: 1, color: const Color(0xFFEF4444)),
    GridTile(r: 4, c: 0, color: const Color(0xFF22C55E)),
    GridTile(r: 5, c: 0, color: const Color(0xFF22C55E)),
    GridTile(r: 6, c: 1, color: const Color(0xFFEF4444)),
    GridTile(r: 7, c: 2, color: const Color(0xFF3B82F6)),
    GridTile(r: 8, c: 1, color: const Color(0xFFEF4444)),
  ];
  List<GridTile> s5_target = [];
  List<GridTile> s5_placed = [];
  List<Color> s5_palette = [
    const Color(0xFFEF4444),
    const Color(0xFF3B82F6),
    const Color(0xFF22C55E),
    const Color(0xFFF59E0B),
  ];

  DragEntity? activeDragEntity;
  double dragX = 0;
  double dragY = 0;

  // Gestures
  double _baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..addListener(_updateGameLoop);
    _gameLoop.forward();

    _initScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoop.dispose();
    super.dispose();
  }

  void _updateGameLoop() {
    if (animating && animStartTime != null) {
      int now = DateTime.now().millisecondsSinceEpoch;
      double prog = (now - animStartTime!) / animDuration;
      if (prog >= 1.0) {
        prog = 1.0;
        animating = false;
        _onAnimationComplete();
      }
      setState(() {
        animProgress = prog;
      });
    }
  }

  void _onAnimationComplete() {
    if (scenario == 1) {
      s1_reflected = true;
      _advanceStep();
      Future.delayed(const Duration(seconds: 1), () {
        AudioEngine.playPageOpen();
        _checkScenarioSuccess();
      });
    } else if (scenario == 2) {
      if (step == 0 && s2_foldType == 'vertical')
        _advanceStep();
      else if (step == 1 && s2_foldType == 'horizontal')
        _advanceStep();
      else if (step == 2 && s2_lines.where((l) => l.used).length == 4) {
        _advanceStep();
        Future.delayed(const Duration(seconds: 1), () {
          AudioEngine.playPageOpen();
          _checkScenarioSuccess();
        });
      }
    } else if (scenario == 3) {
      animProgress = 1.1; // Hold mismatch
      AudioEngine.playError();
      _advanceStep();
      Future.delayed(const Duration(milliseconds: 1500), () {
        AudioEngine.playPageOpen();
        _checkScenarioSuccess();
      });
    }
  }

  void _initScenario(int sId) {
    setState(() {
      scenario = sId;
      step = 0;
      animating = false;
      animProgress = 0;
      activeDragEntity = null;
      showSuccessPopup = false;
      zoom = 1.0;
      panX = 0;
      panY = 0;

      if (scenario == 1) s1_reflected = false;
      if (scenario == 2) {
        s2_lines = [
          SymLine(id: 'v', type: 'vertical', x: -280, y: -120, angle: pi / 2),
          SymLine(id: 'h', type: 'horizontal', x: -280, y: -40, angle: 0),
          SymLine(id: 'd1', type: 'diag1', x: -280, y: 40, angle: -pi / 4),
          SymLine(id: 'd2', type: 'diag2', x: -280, y: 120, angle: pi / 4),
        ];
      }
      if (scenario == 3)
        s3_line = SymLine(
          id: 'd',
          type: 'diag',
          x: -250,
          y: 0,
          angle: atan2(150, -300),
        );
      if (scenario == 4) {
        s4_blots.clear();
        s4_color = s4_palette[0];
      }
      if (scenario == 5) {
        s5_placed.clear();
        s5_target = s5_left_pattern
            .map((p) => GridTile(r: p.r, c: 9 - p.c, color: p.color))
            .toList();
      }
    });
  }

  void _advanceStep() => setState(() {
    step++;
  });

  void _checkScenarioSuccess() {
    int maxSteps = _getScenarioSteps().length;
    setState(() {
      step = maxSteps;
    });
    if (scenario == 5) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          showSuccessPopup = true;
        });
      });
    }
  }

  List<Map<String, String>> _getScenarioSteps() {
    int numSteps = 0;
    if (scenario == 1)
      numSteps = 1;
    else if (scenario == 2)
      numSteps = 3;
    else if (scenario == 3)
      numSteps = 1;
    else if (scenario == 4)
      numSteps = 2;
    else if (scenario == 5)
      numSteps = 1;

    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'hud': t('s${scenario}_hud$i', lang),
        'task': t('s${scenario}_step${i}_task', lang),
        'outcome': t('s${scenario}_step${i}_out', lang),
      });
    }
    return steps;
  }

  // --- INTERACTION LOGIC ---
  Offset _getWorldCoord(Offset local) {
    RenderBox box = canvasKey.currentContext?.findRenderObject() as RenderBox;
    double cx = box.size.width / 2;
    double cy = box.size.height / 2;
    return Offset((local.dx - cx - panX) / zoom, (local.dy - cy - panY) / zoom);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset worldPt) {
    return worldPt.dx > x &&
        worldPt.dx < x + w &&
        worldPt.dy > y &&
        worldPt.dy < y + h;
  }

  void _handleTapDown(TapDownDetails details) {
    Offset worldPt = _getWorldCoord(details.localPosition);

    // Scenario 1
    if (scenario == 1) {
      if (!s1_reflected &&
          !animating &&
          _hitTestBox(-75, 200, 150, 50, worldPt)) {
        AudioEngine.playClick();
        setState(() {
          animating = true;
          animStartTime = DateTime.now().millisecondsSinceEpoch;
          animDuration = 1000;
        });
      }
      return;
    }

    // Scenario 4
    if (scenario == 4) {
      // Color Palette click
      for (int i = 0; i < s4_palette.length; i++) {
        if (_hitTestBox(-470, -120 + i * 50.0, 40, 40, worldPt)) {
          AudioEngine.playClick();
          setState(() {
            s4_color = s4_palette[i];
          });
          return;
        }
      }
      // Blot Placement click
      if (_hitTestBox(-400, -250, 400, 500, worldPt) &&
          s4_blots.length < 5 &&
          worldPt.dx < -20) {
        AudioEngine.playClick();
        setState(() {
          s4_blots.add(
            InkBlot(
              x: worldPt.dx,
              y: worldPt.dy,
              color: s4_color,
              seed: Random().nextDouble() * 1000,
            ),
          );
        });
        if (s4_blots.length == 1 && step == 0) _advanceStep();
        if (s4_blots.length == 5 && step == 1) {
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), () {
            AudioEngine.playPageOpen();
            _checkScenarioSuccess();
          });
        }
        return;
      }
    }
  }

  // Handle drag initiations here. Bypasses the jerky drag failure issues perfectly.
  void _handleScaleStart(ScaleStartDetails details) {
    Offset worldPt = _getWorldCoord(details.localFocalPoint);
    _baseZoom = zoom;

    // Scenario 2
    if (scenario == 2) {
      for (var l in s2_lines) {
        if (!l.used && _hitTestBox(l.x - 50, l.y - 25, 100, 50, worldPt)) {
          if (step == 0 && l.type != 'vertical') return;
          if (step == 1 && l.type != 'horizontal') return;
          AudioEngine.playClick();
          setState(() {
            activeDragEntity = DragEntity(
              type: 's2line',
              id: l.id,
              angle: l.angle,
            );
            dragX = worldPt.dx;
            dragY = worldPt.dy;
          });
          return;
        }
      }
    }

    // Scenario 3
    if (scenario == 3) {
      if (!s3_line.used &&
          _hitTestBox(s3_line.x - 50, s3_line.y - 25, 100, 50, worldPt)) {
        AudioEngine.playClick();
        setState(() {
          activeDragEntity = DragEntity(
            type: 's3line',
            id: s3_line.id,
            angle: s3_line.angle,
          );
          dragX = worldPt.dx;
          dragY = worldPt.dy;
        });
        return;
      }
    }

    // Scenario 5
    if (scenario == 5) {
      for (int i = 0; i < s5_palette.length; i++) {
        if (_hitTestBox(-140 + i * 80.0, 210, 40, 40, worldPt)) {
          AudioEngine.playClick();
          setState(() {
            activeDragEntity = DragEntity(type: 's5tile', color: s5_palette[i]);
            dragX = worldPt.dx;
            dragY = worldPt.dy;
          });
          return;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (activeDragEntity != null) {
      Offset worldPt = _getWorldCoord(details.localFocalPoint);
      setState(() {
        dragX = worldPt.dx;
        dragY = worldPt.dy;
      });
    } else {
      // Pan and Zoom (Smooth continuous panning tracking focalDelta)
      setState(() {
        zoom = (_baseZoom * details.scale).clamp(0.4, 3.0);
        panX += details.focalPointDelta.dx;
        panY += details.focalPointDelta.dy;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (activeDragEntity != null) {
      if (activeDragEntity!.type == 's2line') {
        if (dragX.abs() < 80 && dragY.abs() < 80 && !animating) {
          var l = s2_lines.firstWhere((e) => e.id == activeDragEntity!.id);
          AudioEngine.playClick();
          setState(() {
            l.used = true;
            s2_foldType = l.type;
            animating = true;
            animStartTime = DateTime.now().millisecondsSinceEpoch;
            animDuration = 800;
          });
        } else {
          AudioEngine.playError();
        }
      } else if (activeDragEntity!.type == 's3line') {
        if (dragX.abs() < 100 && dragY.abs() < 100 && !animating) {
          AudioEngine.playClick();
          setState(() {
            s3_line.used = true;
            animating = true;
            animStartTime = DateTime.now().millisecondsSinceEpoch;
            animDuration = 1000;
          });
        } else {
          AudioEngine.playError();
        }
      } else if (activeDragEntity!.type == 's5tile') {
        double u = 30;
        if (dragX > 0 && _hitTestBox(0, -150, 150, 300, Offset(dragX, dragY))) {
          int c = ((dragX / u) + 4.5).floor();
          int r = ((dragY + 5 * u) / u).floor();

          int targetIdx = s5_target.indexWhere((t) => t.r == r && t.c == c);
          if (targetIdx != -1) {
            if (s5_target[targetIdx].color == activeDragEntity!.color) {
              AudioEngine.playClick();
              setState(() {
                s5_placed.add(s5_target[targetIdx]);
                s5_target.removeAt(targetIdx);
              });
              if (s5_target.isEmpty) {
                _advanceStep();
                Future.delayed(const Duration(seconds: 1), () {
                  AudioEngine.playPageOpen();
                  _checkScenarioSuccess();
                });
              }
            } else {
              AudioEngine.playError();
            }
          } else {
            AudioEngine.playError();
          }
        } else {
          AudioEngine.playError();
        }
      }
      setState(() {
        activeDragEntity = null;
      });
    }
  }

  // --- LAYOUT BUILDERS ---

  Widget _buildSidebar() {
    List<Map<String, String>> steps = _getScenarioSteps();

    return Container(
      width: sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Colors.white24, width: 1)),
      ),
      // Sidebar completely wrapped in SingleChildScrollView
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.architecture,
                        color: Colors.indigoAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t('appTitle', lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('appSubtitle', lang),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          AudioEngine.playClick();
                          setState(() => lang = lang == 'en' ? 'hi' : 'en');
                        },
                        icon: const Icon(Icons.language, size: 16),
                        label: Text(
                          lang.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            AudioEngine.playClick();
                            _initScenario(1);
                          },
                          tooltip: 'Reset',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('selectScenario', lang).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: scenario,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        items: [1, 2, 3, 4, 5]
                            .map(
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(t('s${i}_title', lang)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            AudioEngine.playDropdown();
                            _initScenario(v);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Objective
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.track_changes,
                              color: Colors.pinkAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t('learnLbl', lang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('s${scenario}_obj', lang),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Steps
                  ...List.generate(steps.length, (i) {
                    bool isPast = i < step;
                    bool isCurrent = i == step;
                    bool isFuture = i > step;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.indigo.withOpacity(0.15)
                            : (isPast
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.transparent),
                        border: Border.all(
                          color: isCurrent
                              ? Colors.indigoAccent
                              : (isPast ? Colors.white12 : Colors.white10),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.indigoAccent
                                  : (isPast ? Colors.green : Colors.white12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isPast
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t('stepLabel', lang)} ${i + 1}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Task: ${steps[i]['task']!}',
                                  style: TextStyle(
                                    color: isFuture
                                        ? Colors.white38
                                        : Colors.indigo.shade300,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (isPast) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      steps[i]['outcome']!,
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 13,
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
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              width: double.infinity,
              color: const Color(0xFF0F172A),
              alignment: Alignment.center,
              child: const Text(
                '© ZeroScienceLab | Fall in Love with Math and Science',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    List<Map<String, String>> steps = _getScenarioSteps();
    if (step >= steps.length) {
      if (scenario < 5) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            AudioEngine.playPageOpen();
            _initScenario(scenario + 1);
          },
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          label: Text(
            t('nextScenario', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
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
          const Icon(Icons.info_outline, color: Colors.indigoAccent, size: 28),
          const SizedBox(width: 12),
          Text(
            steps[step]['hud']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              curve: Curves.easeOutCubic,
              left: sidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                child: ClipRect(
                  child: CustomPaint(
                    key: canvasKey,
                    painter: LabPainter(
                      zoom: zoom,
                      panX: panX,
                      panY: panY,
                      scenario: scenario,
                      step: step,
                      animating: animating,
                      animProgress: animProgress,
                      s1_reflected: s1_reflected,
                      s2_lines: s2_lines,
                      s2_foldType: s2_foldType,
                      s3_line: s3_line,
                      s4_blots: s4_blots,
                      s4_color: s4_color,
                      s4_palette: s4_palette,
                      s5_left_pattern: s5_left_pattern,
                      s5_placed: s5_placed,
                      s5_palette: s5_palette,
                      activeDragEntity: activeDragEntity,
                      dragX: dragX,
                      dragY: dragY,
                      lang: lang,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),

            // HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: sidebarOpen ? sidebarWidth : 0,
              right: 0,
              bottom: 10,
              child: Center(child: _buildHUD()),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: sidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              child: _buildSidebar(),
            ),

            // RESIZER HANDLE
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: sidebarOpen ? sidebarWidth - 10 : -20,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  setState(() {
                    sidebarWidth = (sidebarWidth + details.delta.dx).clamp(
                      300.0,
                      MediaQuery.of(context).size.width * 0.6,
                    );
                  });
                },
                child: Container(
                  width: 20,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            // MENU BUTTON
            Positioned(
              left: 16,
              top: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF0F172A),
                child: Icon(
                  sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  AudioEngine.playClick();
                  setState(() {
                    sidebarOpen = !sidebarOpen;
                  });
                },
              ),
            ),

            // SUCCESS POPUP
            if (showSuccessPopup)
              Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t('summaryTitle', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('finalDesc', lang),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          AudioEngine.playPageOpen();
                          _initScenario(1);
                        },
                        icon: const Icon(
                          Icons.restart_alt,
                          color: Colors.black87,
                        ),
                        label: Text(
                          t('finishLab', lang),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // CURTAIN SCREEN (Scrollable Fix)
            if (showCurtain)
              Container(
                color: const Color(0xFF0F172A),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.architecture,
                            color: Colors.indigoAccent,
                            size: 100,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('shutterTitle', lang),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('appSubtitle', lang),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 48),
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
                            onPressed: () {
                              AudioEngine.curtainScreen();
                              setState(() {
                                showCurtain = false;
                              });
                            },
                            icon: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 30,
                            ),
                            label: Text(
                              t('enterLab', lang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
class LabPainter extends CustomPainter {
  final double zoom, panX, panY;
  final int scenario, step;
  final bool animating;
  final double animProgress;
  final bool s1_reflected;
  final List<SymLine> s2_lines;
  final String? s2_foldType;
  final SymLine s3_line;
  final List<InkBlot> s4_blots;
  final Color s4_color;
  final List<Color> s4_palette;
  final List<GridTile> s5_left_pattern;
  final List<GridTile> s5_placed;
  final List<Color> s5_palette;
  final DragEntity? activeDragEntity;
  final double dragX, dragY;
  final String lang;

  LabPainter({
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.scenario,
    required this.step,
    required this.animating,
    required this.animProgress,
    required this.s1_reflected,
    required this.s2_lines,
    required this.s2_foldType,
    required this.s3_line,
    required this.s4_blots,
    required this.s4_color,
    required this.s4_palette,
    required this.s5_left_pattern,
    required this.s5_placed,
    required this.s5_palette,
    required this.activeDragEntity,
    required this.dragX,
    required this.dragY,
    required this.lang,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // Draw Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F172A),
    );

    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1)
      _renderS1(canvas);
    else if (scenario == 2)
      _renderS2(canvas);
    else if (scenario == 3)
      _renderS3(canvas);
    else if (scenario == 4)
      _renderS4(canvas);
    else if (scenario == 5)
      _renderS5(canvas);

    canvas.restore();
  }

  // --- DRAWING HELPERS ---
  void _drawLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    Paint p = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(p1, p2, p);
    } else {
      double dashWidth = 12, dashSpace = 12, distance = (p2 - p1).distance;
      double dx = (p2.dx - p1.dx) / distance, dy = (p2.dy - p1.dy) / distance;
      double start = 0;
      while (start < distance) {
        canvas.drawLine(
          Offset(p1.dx + dx * start, p1.dy + dy * start),
          Offset(
            p1.dx + dx * (start + dashWidth),
            p1.dy + dy * (start + dashWidth),
          ),
          p,
        );
        start += dashWidth + dashSpace;
      }
    }
  }

  void _drawRRect(
    Canvas canvas,
    Rect rect,
    double radius,
    Color? fill,
    Color? stroke, [
    double strokeW = 2,
  ]) {
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    if (fill != null)
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    if (stroke != null)
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    double size,
    Color color, {
    bool bold = false,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawDraggableLine(Canvas canvas, SymLine line, bool isActive) {
    if (line.used) return;
    _drawRRect(
      canvas,
      Rect.fromLTWH(line.x - 50, line.y - 25, 100, 50),
      8,
      isActive ? const Color(0xFFCBD5E1) : const Color(0xFFF1F5F9),
      const Color(0xFF94A3B8),
      2,
    );
    canvas.save();
    canvas.translate(line.x, line.y);
    canvas.rotate(line.angle);
    _drawLine(
      canvas,
      const Offset(-35, 0),
      const Offset(35, 0),
      Colors.blueAccent,
      5,
      dashed: true,
    );
    canvas.restore();
  }

  // --- SCENARIOS ---
  void _renderS1(Canvas canvas) {
    _drawLine(
      canvas,
      const Offset(0, -300),
      const Offset(0, 300),
      Colors.blueAccent,
      6,
      dashed: true,
    );

    void drawHalf(bool isRight) {
      canvas.save();
      canvas.scale(1.4, 1.4);
      if (isRight) canvas.scale(-1, 1);

      Paint pFill = Paint()
        ..color = const Color(0xFF6366F1)
        ..style = PaintingStyle.fill;
      Paint pStroke = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      Path path = Path();
      path.moveTo(0, -60);
      path.cubicTo(-90, -110, -140, -10, -70, 30);
      path.cubicTo(-110, 70, -70, 140, 0, 90);
      canvas.drawPath(path, pFill);
      canvas.drawPath(path, pStroke);

      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-60, -40), width: 30, height: 60),
        Paint()..color = Colors.white,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-50, 50), width: 24, height: 40),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        const Offset(-100, -20),
        10,
        Paint()..color = Colors.amber,
      );
      canvas.drawCircle(
        const Offset(-80, 80),
        8,
        Paint()..color = Colors.amber,
      );

      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 15), width: 24, height: 120),
        Paint()..color = const Color(0xFF1E293B),
      );

      Path ant = Path()
        ..moveTo(-5, -45)
        ..quadraticBezierTo(-30, -90, -50, -80);
      canvas.drawPath(
        ant,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      canvas.drawCircle(
        const Offset(-50, -80),
        4,
        Paint()..color = const Color(0xFF0F172A),
      );

      canvas.restore();
    }

    drawHalf(false); // Left
    if (animating || s1_reflected) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, -200, 300 * animProgress, 400));
      drawHalf(true); // Right
      canvas.restore();
    }

    Color btnC = (animating || s1_reflected)
        ? Colors.blueGrey
        : Colors.indigoAccent;
    _drawRRect(
      canvas,
      const Rect.fromLTWH(-75, 200, 150, 50),
      25,
      btnC,
      Colors.black,
      4,
    );
    _drawText(
      canvas,
      t('lbl_reflect', lang),
      const Offset(0, 225),
      18,
      Colors.white,
      bold: true,
    );
  }

  void _renderS2(Canvas canvas) {
    for (var l in s2_lines) {
      _drawDraggableLine(canvas, l, activeDragEntity?.id == l.id);
    }

    double size = 200;
    if (!animating) {
      _drawRRect(
        canvas,
        Rect.fromCenter(center: Offset.zero, width: size, height: size),
        0,
        const Color(0xFFCBD5E1),
        Colors.black,
        4,
      );
      for (var l in s2_lines) {
        if (l.used) {
          canvas.save();
          canvas.rotate(l.angle);
          _drawLine(
            canvas,
            Offset(-size * 0.7, 0),
            Offset(size * 0.7, 0),
            Colors.blueAccent.withOpacity(0.5),
            4,
            dashed: true,
          );
          canvas.restore();
        }
      }
    } else {
      canvas.save();
      if (s2_foldType == 'horizontal')
        canvas.rotate(pi / 2);
      else if (s2_foldType == 'diag1')
        canvas.rotate(-pi / 4);
      else if (s2_foldType == 'diag2')
        canvas.rotate(pi / 4);

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(-size, -size, size, size * 2)); // Left half
      _drawRRect(
        canvas,
        Rect.fromCenter(center: Offset.zero, width: size, height: size),
        0,
        const Color(0xFFCBD5E1),
        Colors.black,
        4,
      );
      canvas.restore();

      canvas.save();
      canvas.scale(cos(pi * animProgress), 1);
      canvas.clipRect(
        Rect.fromLTWH(0, -size, size, size * 2),
      ); // Right half folding
      Color flapC = animProgress > 0.5
          ? const Color(0xFF94A3B8)
          : const Color(0xFFCBD5E1);
      _drawRRect(
        canvas,
        Rect.fromCenter(center: Offset.zero, width: size, height: size),
        0,
        flapC,
        Colors.black,
        4,
      );
      canvas.restore();

      _drawLine(
        canvas,
        Offset(0, -size),
        Offset(0, size),
        Colors.blueAccent.withOpacity(0.4),
        2,
        dashed: true,
      );
      canvas.restore();
    }

    if (activeDragEntity?.type == 's2line') {
      canvas.save();
      canvas.translate(dragX, dragY);
      canvas.rotate(activeDragEntity!.angle);
      _drawLine(
        canvas,
        Offset(-size * 0.7, 0),
        Offset(size * 0.7, 0),
        Colors.blueAccent,
        6,
        dashed: true,
      );
      canvas.restore();
    }

    int count = s2_lines.where((l) => l.used).length;
    _drawRRect(
      canvas,
      const Rect.fromLTWH(200, -200, 160, 60),
      10,
      Colors.white,
      Colors.black,
      4,
    );
    _drawText(
      canvas,
      'Lines: $count/4',
      const Offset(280, -170),
      24,
      Colors.black,
      bold: true,
    );
  }

  void _renderS3(Canvas canvas) {
    _drawDraggableLine(canvas, s3_line, activeDragEntity?.id == s3_line.id);
    double w = 300, h = 180;

    void drawFold(double prog) {
      double angle = atan2(-h, w);

      // Bottom Right Static
      canvas.save();
      Path p1 = Path()
        ..moveTo(-w / 2, h / 2)
        ..lineTo(w / 2, h / 2)
        ..lineTo(w / 2, -h / 2)
        ..close();
      canvas.clipPath(p1);
      _drawRRect(
        canvas,
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        0,
        const Color(0xFFCBD5E1),
        Colors.black,
        4,
      );
      canvas.restore();

      // Top Left Folding
      canvas.save();
      canvas.rotate(angle);
      canvas.scale(1, cos(pi * prog));
      canvas.rotate(-angle);
      Path p2 = Path()
        ..moveTo(-w / 2, h / 2)
        ..lineTo(-w / 2, -h / 2)
        ..lineTo(w / 2, -h / 2)
        ..close();
      canvas.clipPath(p2);
      Color flapC = prog > 0.5
          ? const Color(0xFF94A3B8)
          : const Color(0xFFCBD5E1);
      _drawRRect(
        canvas,
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        0,
        flapC,
        Colors.black,
        4,
      );
      canvas.restore();

      if (prog >= 1.0) {
        canvas.save();
        canvas.rotate(angle);
        canvas.scale(1, -1);
        canvas.rotate(-angle);
        canvas.drawPath(p2, Paint()..color = Colors.redAccent.withOpacity(0.4));
        canvas.drawPath(
          p2,
          Paint()
            ..color = Colors.redAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
        canvas.restore();
      }
    }

    if (!animating) {
      if (s3_line.used)
        drawFold(1.0);
      else
        _drawRRect(
          canvas,
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          0,
          const Color(0xFFCBD5E1),
          Colors.black,
          4,
        );
    } else {
      drawFold(animProgress);
    }

    if (activeDragEntity?.type == 's3line') {
      canvas.save();
      canvas.translate(dragX, dragY);
      canvas.rotate(activeDragEntity!.angle);
      _drawLine(
        canvas,
        const Offset(-200, 0),
        const Offset(200, 0),
        Colors.blueAccent,
        6,
        dashed: true,
      );
      canvas.restore();
    }
  }

  void _renderS4(Canvas canvas) {
    _drawRRect(
      canvas,
      const Rect.fromLTWH(-400, -250, 800, 500),
      10,
      Colors.white,
      Colors.black,
      6,
    );
    _drawLine(
      canvas,
      const Offset(0, -270),
      const Offset(0, 270),
      Colors.blueAccent,
      4,
      dashed: true,
    );

    _drawRRect(
      canvas,
      const Rect.fromLTWH(-480, -150, 60, 300),
      30,
      Colors.white,
      Colors.black,
      4,
    );
    for (int i = 0; i < s4_palette.length; i++) {
      bool active = s4_color == s4_palette[i];
      canvas.drawCircle(
        Offset(-450, -100 + i * 50.0),
        active ? 18 : 12,
        Paint()..color = s4_palette[i],
      );
      if (active)
        canvas.drawCircle(
          Offset(-450, -100 + i * 50.0),
          18,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
    }

    void drawBlot(double x, double y, Color c, double seed, bool mirror) {
      canvas.save();
      canvas.translate(x, y);
      if (mirror) canvas.scale(-1, 1);
      double s = seed;
      double rnd() {
        s = (s * 9301 + 49297) % 233280;
        return s / 233280;
      }

      Paint p = Paint()..color = c;
      canvas.drawCircle(Offset.zero, 18 + rnd() * 12, p);
      for (int i = 0; i < 10; i++) {
        double ang = rnd() * pi * 2;
        double dist = 25 + rnd() * 35;
        double r = 3 + rnd() * 8;
        canvas.drawCircle(Offset(cos(ang) * dist, sin(ang) * dist), r, p);
      }
      canvas.restore();
    }

    for (var b in s4_blots) {
      drawBlot(b.x, b.y, b.color, b.seed, false);
      drawBlot(-b.x, b.y, b.color, b.seed, true);
    }

    _drawRRect(
      canvas,
      const Rect.fromLTWH(300, -320, 120, 50),
      10,
      Colors.white,
      Colors.black,
      3,
    );
    _drawText(
      canvas,
      '${s4_blots.length}/5',
      const Offset(360, -295),
      20,
      Colors.black,
      bold: true,
    );
  }

  void _renderS5(Canvas canvas) {
    double u = 30;
    double startX = -5 * u, startY = -5 * u, size = 10 * u;

    _drawRRect(
      canvas,
      Rect.fromLTWH(startX, startY, size, size),
      4,
      const Color(0xFF0F172A),
      Colors.black,
      4,
    );
    Paint pGrid = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1;
    for (int i = 1; i < 10; i++) {
      canvas.drawLine(
        Offset(startX + i * u, startY),
        Offset(startX + i * u, startY + size),
        pGrid,
      );
      canvas.drawLine(
        Offset(startX, startY + i * u),
        Offset(startX + size, startY + i * u),
        pGrid,
      );
    }
    _drawLine(
      canvas,
      Offset(0, startY - 30),
      Offset(0, startY + size + 30),
      Colors.blueAccent,
      6,
      dashed: true,
    );

    void drawTile(
      double cx,
      double cy,
      double s,
      Color c, [
      double alpha = 1.0,
    ]) {
      _drawRRect(
        canvas,
        Rect.fromCenter(center: Offset(cx, cy), width: s, height: s),
        4,
        c.withOpacity(alpha),
        Colors.black,
        2,
      );
      _drawRRect(
        canvas,
        Rect.fromCenter(center: Offset(cx, cy), width: s - 4, height: s - 4),
        2,
        Colors.white.withOpacity(0.2 * alpha),
        null,
      );
    }

    for (var t in s5_left_pattern) {
      drawTile((t.c - 4.5) * u, (t.r - 4.5) * u, u - 2, t.color);
    }
    for (var t in s5_placed) {
      drawTile((t.c - 4.5) * u, (t.r - 4.5) * u, u - 2, t.color);
    }

    _drawRRect(
      canvas,
      const Rect.fromLTWH(-180, 200, 360, 60),
      10,
      Colors.white,
      Colors.black,
      4,
    );
    for (int i = 0; i < s5_palette.length; i++) {
      drawTile(-120 + i * 80.0, 230, 35, s5_palette[i]);
    }

    if (activeDragEntity?.type == 's5tile') {
      drawTile(-dragX, dragY, 35, activeDragEntity!.color!, 0.4); // Ghost
      drawTile(dragX, dragY, 40, activeDragEntity!.color!);
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
