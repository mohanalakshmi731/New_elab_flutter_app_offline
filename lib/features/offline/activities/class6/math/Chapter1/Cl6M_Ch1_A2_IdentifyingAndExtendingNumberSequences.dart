// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Building Number Sequences',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFEAB308),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch1_A2_IdentifyingAndExtendingNumberSequences(),
    ),
  );
}

// --- MODELS ---

class DotOffset {
  final double dx, dy, r;
  final Color color;
  DotOffset(this.dx, this.dy, this.r, this.color);
}

class Entity {
  String type; // 'block', 'lshape', 'dot', 'group', 'rect', 'operator'
  double x, y, z;
  double w, h;
  Color color;
  bool isDraggable;
  Offset? target;
  String label;
  int blocks;
  double blockSize;
  List<DotOffset> dots;
  bool isNearTarget = false;
  bool isHidden = false;

  Entity({
    required this.type,
    this.x = 0,
    this.y = 0,
    this.z = 0,
    this.w = 50,
    this.h = 50,
    this.color = Colors.white,
    this.isDraggable = false,
    this.target,
    this.label = '',
    this.blocks = 1,
    this.blockSize = 40,
    this.dots = const [],
  });
}

// --- LOCALIZATION ---

class I18n {
  static const Map<String, Map<String, dynamic>> data = {
    'en': {
      'title': "The Pattern Machine: Building Sequences",
      'subtitle': "Class 6 • PATTERNS IN MATHEMATICS",
      'enterLab': "Enter Virtual Lab",
      'selectScenario': "Select Scenario",
      'missionObj': "Mission Objective",
      'checkWork': "Check My Work",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",
      'hudDefault': "Select a scenario to begin.",
      'nextScenario': "Next Scenario",
      'scenarioComplete': "Scenario Complete",
      'patternDiscovered': "Pattern Discovered!",
      'btnGenerate': "GENERATE",
      'btnNextStep': "NEXT STEP",
      'btnAddOrb': "ADD ORB",
      'currentInstruction': "Current Instruction",
      'scenarios': [
        {
          'title': "1. The Simple Stack",
          'objective':
              "Understand counting numbers by physically adding one block at a time to form a growing tower.",
          'steps': [
            {
              'text':
                  "DRAG a cube from the belt and DROP it on top of the first cube.",
              'hud': "Drag a cube and drop it on the base block.",
            },
            {
              'text':
                  "DRAG another cube from the belt and DROP it on top of the tower.",
              'hud': "Drag another cube to make a tower of 3.",
            },
            {
              'text':
                  "The sequence 1, 2, 3 is displayed. Build the tower of 4.",
              'hud': "Build a tower of 4 cubes.",
            },
            {
              'text':
                  "Build the 5th tower in the sequence on the empty platform.",
              'hud': "Build the 5th tower on the new platform.",
            },
            {
              'text': "This is the sequence of Counting Numbers. Rule: Add 1.",
              'hud': "Sequence Complete! Rule: Add 1.",
            },
          ],
        },
        {
          'title': "2. The Perfect Square",
          'objective':
              "Visualize how square numbers are formed by adding consecutive odd numbers, represented as flat L-shapes.",
          'steps': [
            {
              'text':
                  "DRAG the 3-block L-shape and FIT it around the blue square.",
              'hud': "Snap the yellow 3-block L-shape around the blue square.",
            },
            {
              'text':
                  "DRAG the next L-shape (5 blocks) and FIT it around the 2x2 square.",
              'hud': "Snap the green 5-block L-shape around the square.",
            },
            {
              'text':
                  "DRAG the correct L-shape (7 blocks) to fill the outline.",
              'hud': "Select and snap the red 7-block L-shape.",
            },
            {
              'text':
                  "Build the next square in the sequence by adding the 9-block L-shape.",
              'hud': "Add the orange 9-block L-shape to make a 5x5 square.",
            },
            {
              'text': "Adding consecutive odd numbers creates Square Numbers!",
              'hud': "Sequence Complete! Rule: Add next odd number.",
            },
          ],
        },
        {
          'title': "3. The Triangle Terrace",
          'objective':
              "Construct triangular numbers by adding a new row with one more dot than the previous row.",
          'steps': [
            {
              'text':
                  "A single green sphere is on the workspace. CLICK 'NEXT STEP'.",
              'hud': "Click 'NEXT STEP' on the canvas.",
            },
            {
              'text':
                  "DRAG the entire row of 3 spheres and SNAP it below the existing triangle.",
              'hud': "Drag the row of 3 spheres to the base of the triangle.",
            },
            {
              'text':
                  "DRAG the correct row from the dispenser to complete the shape.",
              'hud': "Drag the row of 4 spheres to the base.",
            },
            {
              'text':
                  "Construct the 5th triangular number by adding a row of 5 spheres.",
              'hud': "Drag the row of 5 spheres to the base.",
            },
            {
              'text':
                  "These are Triangular Numbers. Add the next counting number.",
              'hud': "Sequence Complete! Rule: Add next counting number.",
            },
          ],
        },
        {
          'title': "4. The Splitting Cells",
          'objective':
              "Discover the rule for the Powers of 2 sequence by observing a pattern of doubling.",
          'steps': [
            {
              'text': "CLICK the 'GENERATE' button to make the orb split.",
              'hud': "Click 'GENERATE'.",
            },
            {
              'text':
                  "CLICK the 'GENERATE' button again to split the 2 orbs into 4.",
              'hud': "Click 'GENERATE' again.",
            },
            {
              'text': "DRAG the correct operator into the Rule Display box.",
              'hud': "Drag the '[x 2]' operator into the Rule Box.",
            },
            {
              'text': "CLICK 'GENERATE' to confirm your rule and see 8 orbs.",
              'hud': "Click 'GENERATE' to test your rule.",
            },
            {
              'text': "Create the 5th term (16 orbs) by clicking 'ADD ORB'.",
              'hud': "Click 'ADD ORB' until there are 16 orbs.",
            },
            {
              'text': "Powers of 2! Each number is double the one before it.",
              'hud': "Sequence Complete! Rule: Multiply by 2.",
            },
          ],
        },
        {
          'title': "5. The Spiral Architect",
          'objective':
              "Discover the Virahānka (Fibonacci) sequence by assembling squares into a growing spiral.",
          'steps': [
            {
              'text':
                  "DRAG another 1x1 square and SNAP it to the right of the first one.",
              'hud': "Snap a 1x1 square to the right of the base square.",
            },
            {
              'text':
                  "DRAG the 2x2 square and SNAP it below the 1x2 rectangle.",
              'hud': "Snap the 2x2 square below the rectangle.",
            },
            {
              'text': "DRAG the 3x3 square and SNAP it to the left side.",
              'hud': "Snap the 3x3 square to the left edge.",
            },
            {
              'text': "DRAG the 5x5 square and SNAP it to the top edge.",
              'hud': "Snap the 5x5 square to the top edge.",
            },
            {
              'text':
                  "Complete the spiral by adding the 8x8 square to the right edge.",
              'hud': "Snap the 8x8 square to the right edge.",
            },
            {
              'text':
                  "Virahānka sequence. Add the previous two numbers to get the next!",
              'hud': "Sequence Complete! Rule: Add previous two.",
            },
          ],
        },
      ],
    },
    'hi': {
      'title': "द पैटर्न मशीन: नंबर सीक्वेंस",
      'subtitle': "कक्षा 6 • गणित में पैटर्न",
      'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'selectScenario': "परिदृश्य चुनें",
      'missionObj': "मिशन का उद्देश्य",
      'checkWork': "मेरा काम जांचें",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",
      'hudDefault': "शुरू करने के लिए एक परिदृश्य चुनें।",
      'nextScenario': "अगला परिदृश्य",
      'scenarioComplete': "परिदृश्य पूर्ण",
      'patternDiscovered': "पैटर्न खोजा गया!",
      'btnGenerate': "उत्पन्न करें",
      'btnNextStep': "अगला कदम",
      'btnAddOrb': "ऑर्ब जोड़ें",
      'currentInstruction': "वर्तमान निर्देश",
      'scenarios': [
        {
          'title': "1. सरल स्टैक",
          'objective':
              "बढ़ती हुई मीनार बनाने के लिए एक बार में एक ब्लॉक जोड़कर गिनती समझें।",
          'steps': [
            {
              'text':
                  "कन्वेयर बेल्ट से एक घन खींचें और उसे पहले घन के ऊपर छोड़ दें।",
              'hud': "एक घन को खींचें और बेस पर छोड़ दें।",
            },
            {
              'text':
                  "कन्वेयर बेल्ट से एक और घन खींचें और उसे मीनार के ऊपर छोड़ दें।",
              'hud': "3 की मीनार बनाने के लिए एक और घन खींचें।",
            },
            {
              'text': "अनुक्रम 1, 2, 3 प्रदर्शित होता है। 4 की मीनार बनाएं।",
              'hud': "4 घनों की मीनार बनाएं।",
            },
            {
              'text': "खाली प्लेटफ़ॉर्म पर अनुक्रम में 5वीं मीनार बनाएं।",
              'hud': "नए प्लेटफॉर्म पर 5वीं मीनार बनाएं।",
            },
            {
              'text': "यह गिनती की संख्याओं का अनुक्रम है। नियम: 1 जोड़ें।",
              'hud': "अनुक्रम पूरा! नियम: 1 जोड़ें।",
            },
          ],
        },
        {
          'title': "2. पूर्ण वर्ग",
          'objective':
              "देखें कि कैसे लगातार विषम संख्याएँ जोड़कर वर्ग संख्याएँ बनती हैं।",
          'steps': [
            {
              'text': "3-ब्लॉक L-आकार (पीला) को नीले घन के चारों ओर फिट करें।",
              'hud': "पीले 3-ब्लॉक L-आकार को नीले घन के चारों ओर स्नैप करें।",
            },
            {
              'text': "अगला L-आकार (5 ब्लॉक) 2x2 वर्ग के चारों ओर फिट करें।",
              'hud': "हरे 5-ब्लॉक L-आकार को वर्ग के चारों ओर स्नैप करें।",
            },
            {
              'text': "रूपरेखा को भरने के लिए सही L-आकार (7 ब्लॉक) खींचें।",
              'hud': "लाल 7-ब्लॉक L-आकार को चुनें और स्नैप करें।",
            },
            {
              'text': "9-ब्लॉक L-आकार को जोड़कर अनुक्रम में अगला वर्ग बनाएं।",
              'hud': "5x5 वर्ग बनाने के लिए 9-ब्लॉक L-आकार जोड़ें।",
            },
            {
              'text': "लगातार विषम संख्याएँ जोड़ने से वर्ग संख्याएँ बनती हैं!",
              'hud': "अनुक्रम पूरा! नियम: अगली विषम संख्या जोड़ें।",
            },
          ],
        },
        {
          'title': "3. त्रिकोण छत",
          'objective':
              "अधिक बिंदु वाली एक नई पंक्ति जोड़कर त्रिकोणीय संख्याएं बनाएं।",
          'steps': [
            {
              'text':
                  "कार्यक्षेत्र पर एक हरा गोला है। 'अगला कदम' पर क्लिक करें।",
              'hud': "कैनवास पर 'अगला कदम' पर क्लिक करें।",
            },
            {
              'text':
                  "3 गोलों की पूरी पंक्ति को खींचें और इसे त्रिकोण के नीचे स्नैप करें।",
              'hud': "3 गोलों की पंक्ति को त्रिकोण के आधार पर खींचें।",
            },
            {
              'text': "आकार को पूरा करने के लिए सही पंक्ति खींचें।",
              'hud': "4 गोलों की पंक्ति को आधार पर खींचें।",
            },
            {
              'text': "5 गोलों की पंक्ति जोड़कर 5वीं त्रिकोणीय संख्या बनाएं।",
              'hud': "5 गोलों की पंक्ति को आधार पर खींचें।",
            },
            {
              'text':
                  "यह त्रिकोणीय संख्याओं का अनुक्रम है। अगली गिनती संख्या जोड़ें।",
              'hud': "अनुक्रम पूरा! नियम: अगली गिनती संख्या जोड़ें।",
            },
          ],
        },
        {
          'title': "4. विभाजित कोशिकाएं",
          'objective':
              "दोगुना होने के पैटर्न को देखकर 2 की घात अनुक्रम की खोज करें।",
          'steps': [
            {
              'text':
                  "ऑर्ब को विभाजित करने के लिए 'उत्पन्न करें' पर क्लिक करें।",
              'hud': "'उत्पन्न करें' पर क्लिक करें।",
            },
            {
              'text':
                  "2 ऑर्ब को 4 में विभाजित करने के लिए फिर से 'उत्पन्न करें' पर क्लिक करें।",
              'hud': "फिर से 'उत्पन्न करें' पर क्लिक करें।",
            },
            {
              'text': "सही ऑपरेटर को नियम प्रदर्शन बॉक्स में खींचें।",
              'hud': "'[x 2]' ऑपरेटर को नियम बॉक्स में खींचें।",
            },
            {
              'text': "पुष्टि करने के लिए 'उत्पन्न करें' पर क्लिक करें।",
              'hud':
                  "अपने नियम का परीक्षण करने के लिए 'उत्पन्न करें' पर क्लिक करें।",
            },
            {
              'text': "'ऑर्ब जोड़ें' पर क्लिक करके 16 ऑर्ब बनाएं।",
              'hud': "16 ऑर्ब होने तक 'ऑर्ब जोड़ें' पर क्लिक करें।",
            },
            {
              'text': "आपने 2 की घातों की खोज की! प्रत्येक संख्या दोगुनी है।",
              'hud': "अनुक्रम पूरा! नियम: 2 से गुणा करें।",
            },
          ],
        },
        {
          'title': "5. सर्पिल वास्तुकार",
          'objective':
              "बढ़ते हुए सर्पिल पैटर्न में वर्गों को जोड़कर फाइबोनैचि अनुक्रम की खोज करें।",
          'steps': [
            {
              'text':
                  "एक और 1x1 वर्ग खींचें और इसे पहले वर्ग के दाईं ओर स्नैप करें।",
              'hud': "बेस वर्ग के दाईं ओर 1x1 वर्ग स्नैप करें।",
            },
            {
              'text': "2x2 वर्ग को खींचें और इसे आयत के नीचे स्नैप करें।",
              'hud': "आयत के नीचे 2x2 वर्ग स्नैप करें।",
            },
            {
              'text': "3x3 वर्ग को खींचें और इसे बाईं ओर स्नैप करें।",
              'hud': "3x3 वर्ग को बाईं ओर स्नैप करें।",
            },
            {
              'text': "5x5 वर्ग को खींचें और इसे शीर्ष किनारे पर स्नैप करें।",
              'hud': "5x5 वर्ग को शीर्ष किनारे पर स्नैप करें।",
            },
            {
              'text': "दाएं किनारे पर 8x8 वर्ग को जोड़कर सर्पिल को पूरा करें।",
              'hud': "8x8 वर्ग को दाएं किनारे पर स्नैप करें।",
            },
            {
              'text': "यह विरहांक अनुक्रम है। पिछली दो संख्याओं को जोड़ें!",
              'hud': "अनुक्रम पूरा! नियम: पिछले दो जोड़ें।",
            },
          ],
        },
      ],
    },
  };
}

// --- MAIN SCREEN ---

class Cl6M_Ch1_A2_IdentifyingAndExtendingNumberSequences
    extends StatefulWidget {
  const Cl6M_Ch1_A2_IdentifyingAndExtendingNumberSequences({super.key});

  @override
  State<Cl6M_Ch1_A2_IdentifyingAndExtendingNumberSequences> createState() =>
      _Cl6M_Ch1_A2_IdentifyingAndExtendingNumberSequencesState();
}

class _Cl6M_Ch1_A2_IdentifyingAndExtendingNumberSequencesState
    extends State<Cl6M_Ch1_A2_IdentifyingAndExtendingNumberSequences>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  bool _isCurtainOpen = false;
  String _lang = 'en';
  int _currentScenario = 0;
  int _currentStep = 0;

  // Camera & Engine State
  double _camX = 0;
  double _camY = 0;
  double _camScale = 1.0;

  double _startCamScale = 1.0;

  List<Entity> _entities = [];
  String? _globalSequence;
  String? _ruleDisplay;

  Entity? _draggedEntity;
  Offset _dragOffset = Offset.zero;
  Offset _startDragPos = Offset.zero;

  // Audio
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer();

  // Animation
  late AnimationController _pulseController;
  late AnimationController _beltController;

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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _beltController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _beltController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _player.dispose();
    _bgPlayer.dispose();
    _pulseController.dispose();
    _beltController.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      String url = '';
      switch (type) {
        case 'tick':
          url = 'audio/class6/math/click.mp3';
          break;
        case 'snap':
        case 'success':
          url = 'audio/class6/math/success.mp3';
          break;
        case 'error':
          url = 'audio/class6/math/mixkit_2802.mp3';
          break;
        case 'pop':
          url = 'audio/class6/math/click.mp3';
          break;
        case 'enter':
          url = 'audio/class6/math/success.mp3';
          break;
      }
      if (url.isNotEmpty) {
        await _player.play(AssetSource(url));
      }
    } catch (e) {
      // Audio playback failed, continue without audio
    }
  }

  void _enterLab() {
    _playSound('enter');
    setState(() {
      _isCurtainOpen = true;
    });
    // Let the curtain animation play slightly before snapping items
    Future.delayed(const Duration(milliseconds: 300), () {
      _loadScenario(0);
    });
  }

  void _resetLab() {
    _playSound('tick');
    setState(() {
      _isCurtainOpen = false;
      _currentScenario = 0;
      _currentStep = 0;
      _entities.clear();
      _globalSequence = null;
      _ruleDisplay = null;
    });
  }

  void _toggleSidebar() {
    _playSound('tick');
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _toggleLang() {
    _playSound('tick');
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      _entities.clear();
      _globalSequence = null;
      _ruleDisplay = null;
    });
    _setupScenario(index);
    _fitToScreen();
  }

  void _setupScenario(int idx) {
    _entities.clear();
    _globalSequence = null;
    _ruleDisplay = null;

    if (idx == 0) {
      // Stack
      _entities.add(
        Entity(
          type: 'block',
          w: 50,
          color: Colors.purpleAccent,
          x: 0,
          y: 50,
          z: 1,
          label: '1',
        ),
      );
      _entities.add(
        Entity(
          type: 'block',
          w: 50,
          color: Colors.purpleAccent,
          x: 150,
          y: 200,
          z: 2,
          isDraggable: true,
          target: const Offset(0, 0),
        ),
      );
    } else if (idx == 1) {
      // Square
      _entities.add(
        Entity(
          type: 'lshape',
          blocks: 1,
          blockSize: 40,
          color: Colors.blue,
          x: 0,
          y: 0,
          z: 10,
        ),
      );
      _entities.add(
        Entity(
          type: 'lshape',
          blocks: 3,
          blockSize: 40,
          color: Colors.yellow,
          x: 0,
          y: 150,
          z: 9,
          isDraggable: true,
          target: const Offset(20, -20),
        ),
      );
    } else if (idx == 2) {
      // Triangle
      _entities.add(
        Entity(type: 'dot', w: 40, color: Colors.green, x: 0, y: -50, z: 1),
      );
    } else if (idx == 3) {
      // Splitting
      _globalSequence = "?";
      _entities.add(
        Entity(
          type: 'dot',
          w: 60,
          color: Colors.yellowAccent,
          x: 0,
          y: 0,
          z: 1,
          label: '1',
        ),
      );
    } else if (idx == 4) {
      // Spiral
      _globalSequence = "1";
      _entities.add(
        Entity(
          type: 'rect',
          w: 40,
          h: 40,
          color: Colors.blue,
          x: 0,
          y: 0,
          z: 1,
          label: '1',
        ),
      );
      _entities.add(
        Entity(
          type: 'rect',
          w: 40,
          h: 40,
          color: Colors.blue,
          x: 0,
          y: 180,
          z: 5,
          isDraggable: true,
          target: const Offset(40, 0),
          label: '1',
        ),
      );
    }
  }

  void _advanceStep() {
    final tr = I18n.data[_lang]!['scenarios'][_currentScenario];
    if (_currentStep < (tr['steps'] as List).length - 1) {
      setState(() {
        _currentStep++;
        _playSound('success');

        if (_currentScenario == 0) {
          for (var e in _entities) {
            e.label = '';
          }
          if (_currentStep == 1) {
            _entities.add(
              Entity(
                type: 'block',
                w: 50,
                color: Colors.purpleAccent,
                x: 150,
                y: 200,
                z: 3,
                isDraggable: true,
                target: const Offset(0, -50),
              ),
            );
            _globalSequence = "1, 2";
            _ruleDisplay = "+ 1";
          } else if (_currentStep == 2) {
            _entities.add(
              Entity(
                type: 'block',
                w: 50,
                color: Colors.purpleAccent,
                x: 150,
                y: 200,
                z: 4,
                isDraggable: true,
                target: const Offset(0, -100),
              ),
            );
            _globalSequence = "1, 2, 3";
          } else if (_currentStep == 3) {
            _entities.add(
              Entity(
                type: 'block',
                w: 50,
                color: Colors.purpleAccent,
                x: 150,
                y: 200,
                z: 5,
                isDraggable: true,
                target: const Offset(100, 50),
              ),
            );
          } else if (_currentStep == 4) {
            _entities.addAll([
              Entity(
                type: 'block',
                w: 50,
                color: Colors.purpleAccent,
                x: 100,
                y: 0,
                z: 5,
              ),
              Entity(
                type: 'block',
                w: 50,
                color: Colors.purpleAccent,
                x: 100,
                y: -50,
                z: 6,
              ),
              Entity(
                type: 'block',
                w: 50,
                color: Colors.purpleAccent,
                x: 100,
                y: -100,
                z: 7,
              ),
              Entity(
                type: 'block',
                w: 50,
                color: Colors.purpleAccent,
                x: 100,
                y: -150,
                z: 8,
              ),
            ]);
            _globalSequence = "1, 2, 3, 4, 5...";
          }
        } else if (_currentScenario == 1) {
          if (_currentStep == 1) {
            _entities.add(
              Entity(
                type: 'lshape',
                blocks: 5,
                blockSize: 40,
                color: Colors.green,
                x: 0,
                y: 150,
                z: 8,
                isDraggable: true,
                target: const Offset(40, -40),
              ),
            );
            _globalSequence = "1, 4";
            _ruleDisplay = "+ next odd number";
          } else if (_currentStep == 2) {
            _entities.add(
              Entity(
                type: 'lshape',
                blocks: 7,
                blockSize: 40,
                color: Colors.red,
                x: 0,
                y: 150,
                z: 7,
                isDraggable: true,
                target: const Offset(60, -60),
              ),
            );
            _globalSequence = "1, 4, 9";
          } else if (_currentStep == 3) {
            _entities.add(
              Entity(
                type: 'lshape',
                blocks: 9,
                blockSize: 40,
                color: Colors.orange,
                x: 0,
                y: 150,
                z: 6,
                isDraggable: true,
                target: const Offset(80, -80),
              ),
            );
            _globalSequence = "1, 4, 9, 16";
          } else if (_currentStep == 4) {
            _globalSequence = "1, 4, 9, 16, 25...";
          }
        } else if (_currentScenario == 2) {
          double r = 20;
          double gap = 50;
          double dY = math.sqrt(3) * gap / 2;
          if (_currentStep == 1) {
            _entities.addAll([
              Entity(
                type: 'dot',
                w: r * 2,
                color: Colors.green,
                x: -gap / 2,
                y: -50 + dY,
                z: 1,
              ),
              Entity(
                type: 'dot',
                w: r * 2,
                color: Colors.green,
                x: gap / 2,
                y: -50 + dY,
                z: 1,
              ),
              Entity(
                type: 'group',
                w: gap * 2,
                h: r * 2,
                x: 0,
                y: 200,
                z: 2,
                isDraggable: true,
                target: Offset(0, -50 + dY * 2),
                dots: [
                  DotOffset(-gap, 0, r, Colors.green),
                  DotOffset(0, 0, r, Colors.green),
                  DotOffset(gap, 0, r, Colors.green),
                ],
              ),
            ]);
            _globalSequence = "1, 3";
            _ruleDisplay = "+ next counting number";
          } else if (_currentStep == 2) {
            _entities.add(
              Entity(
                type: 'group',
                w: gap * 3,
                h: r * 2,
                x: 0,
                y: 200,
                z: 3,
                isDraggable: true,
                target: Offset(0, -50 + dY * 3),
                dots: [
                  DotOffset(-gap * 1.5, 0, r, Colors.green),
                  DotOffset(-gap / 2, 0, r, Colors.green),
                  DotOffset(gap / 2, 0, r, Colors.green),
                  DotOffset(gap * 1.5, 0, r, Colors.green),
                ],
              ),
            );
            _globalSequence = "1, 3, 6";
          } else if (_currentStep == 3) {
            _entities.add(
              Entity(
                type: 'group',
                w: gap * 4,
                h: r * 2,
                x: 0,
                y: 200,
                z: 4,
                isDraggable: true,
                target: Offset(0, -50 + dY * 4),
                dots: [
                  DotOffset(-gap * 2, 0, r, Colors.green),
                  DotOffset(-gap, 0, r, Colors.green),
                  DotOffset(0, 0, r, Colors.green),
                  DotOffset(gap, 0, r, Colors.green),
                  DotOffset(gap * 2, 0, r, Colors.green),
                ],
              ),
            );
            _globalSequence = "1, 3, 6, 10";
          } else if (_currentStep == 4) {
            _globalSequence = "1, 3, 6, 10, 15...";
          }
        } else if (_currentScenario == 3) {
          if (_currentStep == 2) {
            _entities.addAll([
              Entity(
                type: 'operator',
                w: 80,
                h: 40,
                x: -120,
                y: 150,
                z: 5,
                isDraggable: true,
                label: '+ 2',
              ),
              Entity(
                type: 'operator',
                w: 80,
                h: 40,
                x: 0,
                y: 150,
                z: 5,
                isDraggable: true,
                target: const Offset(0, -140),
                label: 'x 2',
              ),
              Entity(
                type: 'operator',
                w: 80,
                h: 40,
                x: 120,
                y: 150,
                z: 5,
                isDraggable: true,
                label: '+ 4',
              ),
            ]);
          } else if (_currentStep == 3) {
            _ruleDisplay = "x 2";
          } else if (_currentStep == 4) {
            _entities.clear();
          }
        } else if (_currentScenario == 4) {
          double s = 40;
          if (_currentStep == 1) {
            _globalSequence = "1, 1";
            _entities.add(
              Entity(
                type: 'rect',
                w: s * 2,
                h: s * 2,
                color: Colors.blue,
                x: 0,
                y: 180,
                z: 5,
                isDraggable: true,
                target: Offset(0, s),
                label: '2',
              ),
            );
          } else if (_currentStep == 2) {
            _globalSequence = "1, 1, 2";
            _entities.add(
              Entity(
                type: 'rect',
                w: s * 3,
                h: s * 3,
                color: Colors.blue,
                x: 0,
                y: 180,
                z: 5,
                isDraggable: true,
                target: Offset(-s * 3, 0),
                label: '3',
              ),
            );
          } else if (_currentStep == 3) {
            _globalSequence = "1, 1, 2, 3";
            _entities.add(
              Entity(
                type: 'rect',
                w: s * 5,
                h: s * 5,
                color: Colors.blue,
                x: 0,
                y: 180,
                z: 5,
                isDraggable: true,
                target: Offset(-s * 3, -s * 5),
                label: '5',
              ),
            );
          } else if (_currentStep == 4) {
            _globalSequence = "1, 1, 2, 3, 5";
            _entities.add(
              Entity(
                type: 'rect',
                w: s * 8,
                h: s * 8,
                color: Colors.blue,
                x: 0,
                y: 180,
                z: 5,
                isDraggable: true,
                target: Offset(s * 2, -s * 5),
                label: '8',
              ),
            );
          } else if (_currentStep == 5) {
            _globalSequence = "1, 1, 2, 3, 5, 8...";
            _ruleDisplay = "Add previous two";
          }
        }
      });
    }
  }

  void _generateAction() {
    _playSound('pop');
    setState(() {
      if (_currentStep == 0) {
        _entities = [
          Entity(
            type: 'dot',
            w: 50,
            color: Colors.yellowAccent,
            x: -50,
            y: 0,
            z: 1,
          ),
          Entity(
            type: 'dot',
            w: 50,
            color: Colors.yellowAccent,
            x: 50,
            y: 0,
            z: 1,
          ),
        ];
        _globalSequence = "1, 2";
        _advanceStep();
      } else if (_currentStep == 1) {
        _entities = [
          Entity(
            type: 'dot',
            w: 40,
            color: Colors.yellowAccent,
            x: -70,
            y: 0,
            z: 1,
          ),
          Entity(
            type: 'dot',
            w: 40,
            color: Colors.yellowAccent,
            x: -30,
            y: 0,
            z: 1,
          ),
          Entity(
            type: 'dot',
            w: 40,
            color: Colors.yellowAccent,
            x: 30,
            y: 0,
            z: 1,
          ),
          Entity(
            type: 'dot',
            w: 40,
            color: Colors.yellowAccent,
            x: 70,
            y: 0,
            z: 1,
          ),
        ];
        _globalSequence = "1, 2, 4";
        _advanceStep();
      } else if (_currentStep == 3) {
        _entities.clear();
        for (int i = 0; i < 8; i++) {
          _entities.add(
            Entity(
              type: 'dot',
              w: 30,
              color: Colors.yellowAccent,
              x: -140 + i * 40,
              y: 0,
              z: 1,
            ),
          );
        }
        _globalSequence = "1, 2, 4, 8";
        _advanceStep();
      }
    });
  }

  void _addOrbAction() {
    int count = _entities.where((e) => e.type == 'dot').length;
    if (count < 16) {
      _playSound('tick');
      setState(() {
        int row = count ~/ 8;
        int col = count % 8;
        _entities.add(
          Entity(
            type: 'dot',
            w: 30,
            color: Colors.yellowAccent,
            x: -140.0 + col * 40,
            y: 0.0 + row * 40,
            z: 1,
          ),
        );
        if (count + 1 == 16) {
          _playSound('success');
          _globalSequence = "1, 2, 4, 8, 16...";
          Future.delayed(
            const Duration(milliseconds: 800),
            () => _advanceStep(),
          );
        }
      });
    }
  }

  // Engine interaction
  Offset _screenToWorld(Offset localPos) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.3;
    if (sidebarWidth < 300) sidebarWidth = 300;

    // Calculate the exact visual width of the canvas taking sidebar into account
    double canvasWidth = _isSidebarOpen
        ? (screenWidth - sidebarWidth)
        : screenWidth;
    double canvasHeight = MediaQuery.of(context).size.height;

    double x = (localPos.dx - canvasWidth / 2 - _camX) / _camScale;
    double y = (localPos.dy - canvasHeight / 2 - _camY) / _camScale;
    return Offset(x, y);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (!mounted) return;

    // Use the correctly adjusted coordinate system
    Offset worldPos = _screenToWorld(details.localFocalPoint);

    _startCamScale = _camScale;

    // Check hit
    for (int i = _entities.length - 1; i >= 0; i--) {
      Entity e = _entities[i];
      if (!e.isDraggable || e.isHidden) continue;

      bool hit = false;
      if (e.type == 'group') {
        double hw = e.w / 2;
        double hh = e.h / 2;
        if ((worldPos.dx - e.x).abs() <= hw &&
            (worldPos.dy - e.y).abs() <= hh) {
          hit = true;
        }
      } else if (e.type == 'lshape') {
        double side = (e.blocks + 1) / 2;
        double hw = (side * e.blockSize) / 2;
        if ((worldPos.dx - e.x).abs() <= hw &&
            (worldPos.dy - e.y).abs() <= hw) {
          hit = true;
        }
      } else if (e.type == 'block' ||
          e.type == 'rect' ||
          e.type == 'operator') {
        double hw = e.w / 2;
        double hh = (e.type == 'operator' ? 40 : e.h) / 2;
        double cx = e.type == 'rect' ? e.x + hw : e.x;
        double cy = e.type == 'rect' ? e.y + hh : e.y;
        if ((worldPos.dx - cx).abs() <= hw && (worldPos.dy - cy).abs() <= hh) {
          hit = true;
        }
      }

      if (hit) {
        _playSound('tick');
        setState(() {
          _draggedEntity = e;
          _dragOffset = Offset(e.x - worldPos.dx, e.y - worldPos.dy);
          _startDragPos = Offset(e.x, e.y);
        });
        return;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_draggedEntity != null) {
      Offset worldPos = _screenToWorld(details.localFocalPoint);
      setState(() {
        _draggedEntity!.x = worldPos.dx + _dragOffset.dx;
        _draggedEntity!.y = worldPos.dy + _dragOffset.dy;
        _draggedEntity!.isNearTarget = false;
        if (_draggedEntity!.target != null) {
          double dist =
              (Offset(_draggedEntity!.x, _draggedEntity!.y) -
                      _draggedEntity!.target!)
                  .distance;
          _draggedEntity!.isNearTarget = dist < 80;
        }
      });
    } else {
      // Pan and zoom (Restored to properly increment position without snapping)
      setState(() {
        _camX += details.focalPointDelta.dx;
        _camY += details.focalPointDelta.dy;
        _camScale = (_startCamScale * details.scale).clamp(0.2, 3.0);
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_draggedEntity != null) {
      setState(() {
        if (_draggedEntity!.target != null) {
          double dist =
              (Offset(_draggedEntity!.x, _draggedEntity!.y) -
                      _draggedEntity!.target!)
                  .distance;
          if (dist < 80) {
            _draggedEntity!.x = _draggedEntity!.target!.dx;
            _draggedEntity!.y = _draggedEntity!.target!.dy;
            _draggedEntity!.isDraggable = false;
            _draggedEntity!.isNearTarget = false;
            if (_draggedEntity!.type == 'rect') {
              _draggedEntity!.color = Colors.blue;
            }
            if (_draggedEntity!.type == 'operator') {
              _entities.removeWhere(
                (e) => e.type == 'operator' && e != _draggedEntity,
              );
            }
            _playSound('snap');
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _advanceStep(),
            );
          } else {
            _draggedEntity!.x = _startDragPos.dx;
            _draggedEntity!.y = _startDragPos.dy;
            _playSound('error');
          }
        } else {
          _draggedEntity!.x = _startDragPos.dx;
          _draggedEntity!.y = _startDragPos.dy;
          _playSound('error');
        }
        _draggedEntity = null;
      });
    }
  }

  void _fitToScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _camX = 0;
        _camY = 50;
        _camScale = 1.0;
      });
    });
  }

  Widget _buildCanvasAction() {
    final tr = I18n.data[_lang]!;
    if (_currentScenario == 2 && _currentStep == 0) {
      return _FloatingActionButtonCanvas(
        text: tr['btnNextStep'],
        onPressed: _advanceStep,
      );
    } else if (_currentScenario == 3) {
      if (_currentStep == 0 || _currentStep == 1 || _currentStep == 3) {
        return _FloatingActionButtonCanvas(
          text: tr['btnGenerate'],
          onPressed: _generateAction,
        );
      } else if (_currentStep == 4) {
        return _FloatingActionButtonCanvas(
          text: tr['btnAddOrb'],
          onPressed: _addOrbAction,
        );
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final tr = I18n.data[_lang]!;
    final scenarios = tr['scenarios'] as List;
    final currentScenData = scenarios[_currentScenario];
    final steps = currentScenData['steps'] as List;
    bool isComplete = _currentStep == steps.length - 1;

    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.3;
    if (sidebarWidth < 300) sidebarWidth = 300; // minimum reasonable width

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // --- 1. Interactive Canvas Area ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                child: CustomPaint(
                  painter: LabCanvasPainter(
                    camX: _camX,
                    camY: _camY,
                    camScale: _camScale,
                    entities: _entities,
                    draggedEntity: _draggedEntity,
                    currentScenario: _currentScenario,
                    currentStep: _currentStep,
                    beltOffset: _beltController.value * 40,
                    globalSequence: _globalSequence,
                    ruleDisplay: _ruleDisplay,
                  ),
                  child: Container(),
                ),
              ),
            ),

            // Canvas Floating Action (Center bottom logic)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: 80,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: Center(child: _buildCanvasAction()),
            ),

            // --- 2. Sidebar (Fully Scrollable & No SafeArea limitations) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              width: _sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  border: const Border(
                    right: BorderSide(color: Colors.white10),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 20),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (With top padding specifically avoiding menu overlap)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.hexagon,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        tr['subtitle'],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: Row(
                                    children: [
                                      const Icon(
                                        Icons.language,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        _lang.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: _toggleLang,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.indigoAccent
                                        .withOpacity(0.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Row(
                                    children: [
                                      const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Reset',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),

                                  onPressed: _resetLab,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.redAccent
                                        .withOpacity(0.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white10),

                      // Scrollable Scenarios & Objectives
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr['selectScenario'].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
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
                                border: Border.all(color: Colors.white10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: _currentScenario,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  items: List.generate(scenarios.length, (
                                    index,
                                  ) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                        scenarios[index]['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }),
                                  onChanged: (val) {
                                    if (val != null) _loadScenario(val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              tr['missionObj'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigoAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentScenData['objective'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Steps
                            ...List.generate(steps.length - 1, (index) {
                              if (index > _currentStep) {
                                return const SizedBox.shrink();
                              }
                              bool isCurrent = index == _currentStep;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrent
                                        ? Colors.indigoAccent.withOpacity(0.5)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isCurrent
                                          ? Icons.adjust
                                          : Icons.check_circle,
                                      color: isCurrent
                                          ? Colors.indigoAccent
                                          : Colors.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        steps[index]['text'],
                                        style: TextStyle(
                                          color: isCurrent
                                              ? Colors.white
                                              : Colors.white54,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Colors.white10),
                      // Footer
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            tr['footer'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2.5 Resizer Handle
            if (_isSidebarOpen && !_isCurtainOpen)
              Positioned(
                left: _sidebarWidth - 5,
                top: 0,
                bottom: 0,
                width: 10,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      setState(() {
                        double screenWidth = MediaQuery.of(context).size.width;
                        _sidebarWidth += details.delta.dx;
                        if (_sidebarWidth < 250) _sidebarWidth = 250;
                        if (_sidebarWidth > screenWidth * 0.6) {
                          _sidebarWidth = screenWidth * 0.6;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // --- 4. Menu Icon (Fixed top-left) ---
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: _toggleSidebar,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // --- 5. Collapsed Mission Card (Visible when sidebar closed) ---
            if (!_isSidebarOpen && !isComplete && _isCurtainOpen)
              Positioned(
                top: 80,
                left: 16,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr['missionObj'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentScenData['objective'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr['currentInstruction'] ?? "Current Instruction:",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[_currentStep]['text'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- 6. Success Modal Overlay ---
            if (isComplete && _isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      width: 400,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.indigoAccent.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.indigoAccent, blurRadius: 30),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.withOpacity(0.2),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 64,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              tr['patternDiscovered'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              steps[_currentStep]['text'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                _playSound('tick');
                                if (_currentScenario < scenarios.length - 1) {
                                  _loadScenario(_currentScenario + 1);
                                } else {
                                  _loadScenario(0); // Restart
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Icon(
                                _currentScenario < scenarios.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.refresh,
                              ),
                              label: Text(
                                _currentScenario < scenarios.length - 1
                                    ? tr['nextScenario']
                                    : "Restart Lab",
                                style: const TextStyle(
                                  fontSize: 18,
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

            // --- 7. Initial Shutter ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutCubic,
              top: _isCurtainOpen ? -MediaQuery.of(context).size.height : 0,
              bottom: _isCurtainOpen ? MediaQuery.of(context).size.height : 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF020617),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.hexagon,
                          size: 80,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          tr['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr['subtitle'],
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: _enterLab,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            tr['enterLab'],
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
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingActionButtonCanvas extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _FloatingActionButtonCanvas({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigoAccent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: Colors.indigoAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }
}

// --- CUSTOM PAINTER (Engine) ---

class LabCanvasPainter extends CustomPainter {
  final double camX, camY, camScale;
  final List<Entity> entities;
  final Entity? draggedEntity;
  final int currentScenario;
  final int currentStep;
  final double beltOffset;
  final String? globalSequence;
  final String? ruleDisplay;

  LabCanvasPainter({
    required this.camX,
    required this.camY,
    required this.camScale,
    required this.entities,
    required this.draggedEntity,
    required this.currentScenario,
    required this.currentStep,
    required this.beltOffset,
    required this.globalSequence,
    required this.ruleDisplay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F172A),
    );
    _drawGrid(canvas, size);

    // Apply Camera
    canvas.translate(size.width / 2 + camX, size.height / 2 + camY);
    canvas.scale(camScale, camScale);

    // Scenario specific backgrounds
    if (currentScenario == 0 || currentScenario == 2) {
      // Belt
      Paint p = Paint()..color = const Color(0xFF334155);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(-200, 170, 200, 230),
          const Radius.circular(10),
        ),
        p,
      );
      Paint pLine = Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 4;
      for (double i = -200; i < 200; i += 40) {
        canvas.drawLine(
          Offset(i + beltOffset, 170),
          Offset(i + beltOffset - 15, 230),
          pLine,
        );
      }
    } else if (currentScenario == 1) {
      // Palette
      Paint p = Paint()..color = Colors.black.withOpacity(0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(-200, 140, 200, 260),
          const Radius.circular(20),
        ),
        p,
      );
    } else if (currentScenario == 3) {
      if (currentStep == 2) {
        Paint p = Paint()..color = const Color(0xFF1E293B);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(-80, -170, 80, -110),
            const Radius.circular(10),
          ),
          p,
        );
        Paint pStroke = Paint()
          ..color = Colors.lightBlue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(-80, -170, 80, -110),
            const Radius.circular(10),
          ),
          pStroke,
        );

        TextPainter tp = TextPainter(
          text: const TextSpan(
            text: "RULE BOX",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(-tp.width / 2, -185));

        if (ruleDisplay == null) {
          TextPainter tp2 = TextPainter(
            text: const TextSpan(
              text: "?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          tp2.layout();
          tp2.paint(canvas, Offset(-tp2.width / 2, -152));
        }
      } else if (currentStep == 4) {
        Paint p = Paint()..color = Colors.black.withOpacity(0.3);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(-200, -100, 200, 100),
            const Radius.circular(20),
          ),
          p,
        );
        int count = entities.where((e) => e.type == 'dot').length;
        TextPainter tp = TextPainter(
          text: TextSpan(
            text: "Orbs placed: $count / 16",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(-tp.width / 2, -120));
      }
    }

    // Sort entities for Z depth
    List<Entity> sorted = List.from(entities);
    sorted.sort((a, b) {
      double zA = a == draggedEntity ? 1000 : a.z;
      double zB = b == draggedEntity ? 1000 : b.z;
      return zA.compareTo(zB);
    });

    for (var ent in sorted) {
      if (ent.isHidden) continue;
      canvas.save();

      // Target highlights
      if (ent.isNearTarget && ent.target != null) {
        canvas.save();
        canvas.translate(ent.target!.dx, ent.target!.dy);
        Paint hpFill = Paint()..color = Colors.white.withOpacity(0.2);
        Paint hpStroke = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        if (ent.type == 'rect') {
          canvas.drawRect(Rect.fromLTWH(0, 0, ent.w, ent.h), hpFill);
          canvas.drawRect(Rect.fromLTWH(0, 0, ent.w, ent.h), hpStroke);
        } else if (ent.type == 'group') {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                -ent.w / 2 - 10,
                -ent.h / 2 - 10,
                ent.w + 20,
                ent.h + 20,
              ),
              const Radius.circular(10),
            ),
            hpFill,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                -ent.w / 2 - 10,
                -ent.h / 2 - 10,
                ent.w + 20,
                ent.h + 20,
              ),
              const Radius.circular(10),
            ),
            hpStroke,
          );
        } else if (ent.type == 'lshape') {
          double side = (ent.blocks + 1) / 2;
          double size = ent.blockSize;
          double offset = (side * size) / 2;
          Path path = Path();
          for (int i = 0; i < side; i++) {
            path.addRect(Rect.fromLTWH(i * size - offset, -offset, size, size));
          }
          for (int i = 1; i < side; i++) {
            path.addRect(
              Rect.fromLTWH(
                (side - 1) * size - offset,
                i * size - offset,
                size,
                size,
              ),
            );
          }
          canvas.drawPath(path, hpFill);
          canvas.drawPath(path, hpStroke);
        } else if (ent.type == 'block') {
          canvas.drawRect(
            Rect.fromLTWH(-ent.w / 2, -ent.w / 2, ent.w, ent.w),
            hpFill,
          );
          canvas.drawRect(
            Rect.fromLTWH(-ent.w / 2, -ent.w / 2, ent.w, ent.w),
            hpStroke,
          );
        } else if (ent.type == 'operator') {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-45, -25, 90, 50),
              const Radius.circular(10),
            ),
            hpFill,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-45, -25, 90, 50),
              const Radius.circular(10),
            ),
            hpStroke,
          );
        }
        canvas.restore();
      }

      // Draw Entities
      if (ent.type == 'rect') {
        Paint pF = Paint()..color = ent.color;
        Paint pS = Paint()
          ..color = Colors.white30
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        if (ent.isNearTarget) pF.color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(ent.x, ent.y, ent.w, ent.h), pF);
        canvas.drawRect(Rect.fromLTWH(ent.x, ent.y, ent.w, ent.h), pS);
        if (ent.label.isNotEmpty) {
          _drawTextCentered(
            canvas,
            ent.label,
            ent.x + ent.w / 2,
            ent.y + ent.h / 2,
            ent.w * 0.4,
            Colors.white,
          );
        }
      } else {
        canvas.translate(ent.x, ent.y);
        if (ent.type == 'dot') {
          _drawDot(canvas, 0, 0, ent.w / 2, ent.color, ent.label);
        } else if (ent.type == 'group') {
          for (var d in ent.dots) {
            _drawDot(canvas, d.dx, d.dy, d.r, d.color, '');
          }
        } else if (ent.type == 'block') {
          _draw3DBlock(canvas, 0, 0, ent.w, ent.color);
          if (ent.label.isNotEmpty) {
            _drawTextCentered(canvas, ent.label, 0, 0, 20, Colors.white);
          }
        } else if (ent.type == 'lshape') {
          _drawFlatLShape(canvas, 0, 0, ent.blockSize, ent.blocks, ent.color);
        } else if (ent.type == 'operator') {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-40, -20, 80, 40),
              const Radius.circular(8),
            ),
            Paint()..color = const Color(0xFF334155),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-40, -20, 80, 40),
              const Radius.circular(8),
            ),
            Paint()
              ..color = Colors.white30
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          if (ent.label.isNotEmpty) {
            _drawTextCentered(canvas, ent.label, 0, 0, 20, Colors.white);
          }
        }
      }
      canvas.restore();
    }

    // High Fidelity Continuous Spiral Arcs (Scenario 4)
    if (currentScenario == 4 && currentStep > 0) {
      double s = 40;
      Paint arcPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      if (currentStep >= 1) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(s, s), radius: s),
          math.pi,
          math.pi / 2,
          false,
          arcPaint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(s, s), radius: s),
          math.pi * 1.5,
          math.pi / 2,
          false,
          arcPaint,
        );
      }
      if (currentStep >= 2) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(0, s), radius: 2 * s),
          0,
          math.pi / 2,
          false,
          arcPaint,
        );
      }
      if (currentStep >= 3) {
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(0, 0), radius: 3 * s),
          math.pi / 2,
          math.pi / 2,
          false,
          arcPaint,
        );
      }
      if (currentStep >= 4) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(2 * s, 0), radius: 5 * s),
          math.pi,
          math.pi / 2,
          false,
          arcPaint,
        );
      }
      if (currentStep >= 5) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(2 * s, 3 * s), radius: 8 * s),
          math.pi * 1.5,
          math.pi / 2,
          false,
          arcPaint,
        );
      }
    }

    // Global Info
    if (globalSequence != null) {
      _drawTextCentered(canvas, globalSequence!, 0, -260, 28, Colors.white70);
    }
    if (ruleDisplay != null) {
      _drawTextCentered(
        canvas,
        "Rule: $ruleDisplay",
        0,
        -220,
        20,
        Colors.lightBlue,
      );
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    double step = 40;
    // Shift grid based on camera to give illusion of infinite plane
    double offsetX = (size.width / 2 + camX) % step;
    double offsetY = (size.height / 2 + camY) % step;

    for (double i = offsetX; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = offsetY; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  void _drawDot(
    Canvas canvas,
    double x,
    double y,
    double r,
    Color color,
    String label,
  ) {
    canvas.drawCircle(Offset(x, y), r, Paint()..color = color);
    if (color != Colors.white) {
      canvas.drawCircle(
        Offset(x - r * 0.3, y - r * 0.3),
        r * 0.3,
        Paint()..color = Colors.white.withOpacity(0.4),
      );
    }
    if (label.isNotEmpty) {
      _drawTextCentered(canvas, label, x, y, r, Colors.black);
    }
  }

  void _draw3DBlock(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color,
  ) {
    double h = size;
    double w = size;
    double d = size * 0.3;
    Paint p = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(x - w / 2, y - h / 2, w, h), p);

    // Top
    Path topP = Path();
    topP.moveTo(x - w / 2, y - h / 2);
    topP.lineTo(x - w / 2 + d, y - h / 2 - d);
    topP.lineTo(x + w / 2 + d, y - h / 2 - d);
    topP.lineTo(x + w / 2, y - h / 2);
    canvas.drawPath(topP, Paint()..color = _adjustColor(color, 20));

    // Side
    Path sideP = Path();
    sideP.moveTo(x + w / 2, y - h / 2);
    sideP.lineTo(x + w / 2 + d, y - h / 2 - d);
    sideP.lineTo(x + w / 2 + d, y + h / 2 - d);
    sideP.lineTo(x + w / 2, y + h / 2);
    canvas.drawPath(sideP, Paint()..color = _adjustColor(color, -20));
  }

  void _drawFlatBlock(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(x - size / 2, y - size / 2, size, size),
      Paint()..color = color,
    );
    canvas.drawRect(
      Rect.fromLTWH(x - size / 2, y - size / 2, size, size),
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(x - size / 2, y - size / 2, size, size / 4),
      Paint()..color = Colors.white10,
    );
  }

  void _drawFlatLShape(
    Canvas canvas,
    double cx,
    double cy,
    double size,
    int count,
    Color color,
  ) {
    int side = ((count + 1) / 2).toInt();
    double offset = (side * size) / 2;
    for (int i = 0; i < side; i++) {
      _drawFlatBlock(
        canvas,
        cx + (i * size) - offset + size / 2,
        cy - offset + size / 2,
        size,
        color,
      );
    }
    for (int i = 1; i < side; i++) {
      _drawFlatBlock(
        canvas,
        cx + (side - 1) * size - offset + size / 2,
        cy + (i * size) - offset + size / 2,
        size,
        color,
      );
    }
  }

  void _drawTextCentered(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color,
  ) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
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
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  Color _adjustColor(Color c, int amount) {
    int r = (c.red + amount).clamp(0, 255);
    int g = (c.green + amount).clamp(0, 255);
    int b = (c.blue + amount).clamp(0, 255);
    return Color.fromARGB(c.alpha, r, g, b);
  }

  @override
  bool shouldRepaint(covariant LabCanvasPainter oldDelegate) => true;
}
