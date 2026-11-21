// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Pattern Builders Workshop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch1_A1_IntroductionToPatternsInMathematics(),
    ),
  );
}

class GameEntity {
  double x;
  double y;
  String type; // 'dot', 'group', 'block', 'line', 'ghost_dot'
  Color color;
  double radius;
  bool isDraggable;
  bool isNearTarget;
  Offset? target;
  int? val;
  List<Offset>? dotsOffsets;
  String? counter;
  String? label;
  bool filled;
  int? from;
  int? to;
  int? inSlot;

  GameEntity({
    required this.x,
    required this.y,
    required this.type,
    this.color = Colors.white,
    this.radius = 20,
    this.isDraggable = false,
    this.isNearTarget = false,
    this.target,
    this.val,
    this.dotsOffsets,
    this.counter,
    this.label,
    this.filled = false,
    this.from,
    this.to,
    this.inSlot,
  });

  // Clone entity
  GameEntity clone() {
    return GameEntity(
      x: x,
      y: y,
      type: type,
      color: color,
      radius: radius,
      isDraggable: isDraggable,
      isNearTarget: isNearTarget,
      target: target,
      val: val,
      dotsOffsets: dotsOffsets?.map((e) => Offset(e.dx, e.dy)).toList(),
      counter: counter,
      label: label,
      filled: filled,
      from: from,
      to: to,
      inSlot: inSlot,
    );
  }
}

class Cl6M_Ch1_A1_IntroductionToPatternsInMathematics extends StatefulWidget {
  const Cl6M_Ch1_A1_IntroductionToPatternsInMathematics({super.key});

  @override
  State<Cl6M_Ch1_A1_IntroductionToPatternsInMathematics> createState() =>
      _Cl6M_Ch1_A1_IntroductionToPatternsInMathematicsState();
}

class _Cl6M_Ch1_A1_IntroductionToPatternsInMathematicsState
    extends State<Cl6M_Ch1_A1_IntroductionToPatternsInMathematics>
    with TickerProviderStateMixin {
  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _currentLanguage = 'en'; // Default language set back to English
  int _scenarioIdx = 0;
  int _stepIdx = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final TransformationController _transformCtrl = TransformationController();

  final List<GameEntity> _entities = [];
  GameEntity? _draggedEntity;
  Offset _dragStartPos = Offset.zero;
  bool _panEnabled = true;

  String? _globalCounter;
  String? _globalLabel;
  String? _hexagonProgress;
  List<bool>? _checklist;
  List<int> _beltSeq = [];
  bool _isAnimatingMachine = false;

  late AnimationController _pulseController;

  final Map<String, Map<String, String>> i18n = {
    'en': {
      'title': "The Pattern Builders' Workshop",
      'subtitle': "Class 6 • PATTERNS IN MATHEMATICS",
      'enter': "Enter Virtual Lab",
      'reset': "Reset Lab",
      'select_scen': "Select Scenario",
      'check_work': "Check My Work",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",
      'add_dot': "Add Dot",
      'connect_all': "Connect All",
      'mission_obj': "Mission Objective",
      'target_output': "Target Output",
      'success': "Success!",
      'next': "Next Scenario",
      'finish': "Finish Lab",

      'scen0_title': "1. The Triangle Growers",
      'scen0_obj':
          "Visually construct and identify the pattern of Triangular Numbers.",
      'scen0_s0': "Drag the 2 dots below the 1 dot.",
      'scen0_s1': "Drag the 3 dots to continue the triangle.",
      'scen0_s2': "Drag the 4 dots to finish the shape.",
      'scen0_s3':
          "Pattern complete! 1, 3, 6, 10... Adding 1, 2, 3, 4 creates Triangular Numbers.",

      'scen1_title': "2. The Square Builders",
      'scen1_obj':
          "Discover that the sum of consecutive odd numbers results in square numbers.",
      'scen1_s0': "Snap the 3-dot green 'L' shape around the 1 dot.",
      'scen1_s1': "Snap the 5-dot blue 'L' shape around the square.",
      'scen1_s2': "Snap the 7-dot orange 'L' shape to finish.",
      'scen1_s3':
          "Pattern complete! Adding consecutive odd numbers builds Square Numbers.",

      'scen2_title': "3. The Network Connector",
      'scen2_obj': "Relate lines in a Complete Graph to Triangular Numbers.",
      'scen2_s0': "Click 'Connect All' to link the first two dots.",
      'scen2_s1': "Click 'Add Dot', then 'Connect All'.",
      'scen2_s2': "Click 'Add Dot', then 'Connect All' again.",
      'scen2_s3': "Connections follow Triangular Numbers: 1, 3, 6!",

      'scen3_title': "4. The Hexagon Hive",
      'scen3_obj': "Analyze a Hexagonal sequence and build the next shape.",
      'scen3_s0': "Build the 4th Hexagon. Fill 18 empty slots with red dots.",
      'scen3_s1': "Pattern emerging... 6 dots placed.",
      'scen3_s2': "Almost there... 12 dots placed.",
      'scen3_s3': "Excellent! The 4th hexagonal number is 37 (19 + 18).",

      'scen4_title': "5. The Virahānka Machine",
      'scen4_obj':
          "Discover the additive rule of the Virahānka (Fibonacci) sequence.",
      'scen4_s0': "Drag the two '1' blocks into the machine hoppers.",
      'scen4_s1': "Drag the '1' and '2' blocks into the machine.",
      'scen4_s2': "Generate the next 3 numbers (target: 5, 8, 13).",
      'scen4_s3': "Sequence complete! 1, 1, 2, 3, 5, 8, 13...",
    },
    'hi': {
      'title': "पैटर्न बिल्डर्स कार्यशाला",
      'subtitle': "कक्षा 6 • गणित में पैटर्न",
      'enter': "वर्चुअल लैब में प्रवेश करें",
      'reset': "लैब रीसेट करें",
      'select_scen': "परिदृश्य चुनें",
      'check_work': "मेरा काम जांचें",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",
      'add_dot': "बिंदु जोड़ें",
      'connect_all': "सभी को जोड़ें",
      'mission_obj': "मिशन का उद्देश्य",
      'target_output': "लक्ष्य आउटपुट",
      'success': "सफलता!",
      'next': "अगला परिदृश्य",
      'finish': "लैब समाप्त करें",

      'scen0_title': "1. त्रिकोण उत्पादक",
      'scen0_obj': "त्रिकोणीय संख्याओं के पैटर्न का निर्माण और पहचान करें।",
      'scen0_s0': "2 बिंदुओं को 1 बिंदु নিচে खींचें।",
      'scen0_s1': "त्रिकोण को जारी रखने के लिए 3 बिंदुओं को खींचें।",
      'scen0_s2': "आकार पूरा करने के लिए 4 बिंदुओं को खींचें।",
      'scen0_s3': "पैटर्न पूरा हुआ! 1, 3, 6, 10... त्रिकोणीय संख्याएँ।",

      'scen1_title': "2. वर्ग निर्माता",
      'scen1_obj': "खोजें कि लगातार विषम संख्याओं का योग वर्ग बनाता है।",
      'scen1_s0': "3 हरे बिंदुओं को 1 बिंदु के चारों ओर लगाएं।",
      'scen1_s1': "5 नीले बिंदुओं को वर्ग के चारों ओर लगाएं।",
      'scen1_s2': "समाप्त करने के लिए 7 नारंगी बिंदुओं को लगाएं।",
      'scen1_s3': "पैटर्न पूरा हुआ! विषम संख्याओं को जोड़ने से वर्ग बनते हैं।",

      'scen2_title': "3. नेटवर्क कनेक्टर",
      'scen2_obj': "ग्राफ में रेखाओं को त्रिकोणीय संख्याओं से जोड़ें।",
      'scen2_s0':
          "पहले दो बिंदुओं को जोड़ने के लिए 'सभी को जोड़ें' पर क्लिक करें।",
      'scen2_s1': "'बिंदु जोड़ें', फिर 'सभी को जोड़ें' पर क्लिक करें।",
      'scen2_s2': "फिर से 'बिंदु जोड़ें', फिर 'सभी को जोड़ें' पर क्लिक करें।",
      'scen2_s3': "कनेक्शन त्रिकोणीय संख्याओं का पालन करते हैं: 1, 3, 6!",

      'scen3_title': "4. षट्भुज छत्ता",
      'scen3_obj': "षट्कोणीय अनुक्रम का विश्लेषण करें और अगला आकार बनाएं।",
      'scen3_s0': "4था षट्भुज बनाएं। 18 स्लॉट में लाल बिंदु भरें।",
      'scen3_s1': "पैटर्न उभर रहा है... 6 बिंदु लगाए गए।",
      'scen3_s2': "लगभग पूरा हुआ... 12 बिंदु लगाए गए।",
      'scen3_s3': "उत्कृष्ट! 4थी षट्कोणीय संख्या 37 (19 + 18) है।",

      'scen4_title': "5. विरहांक मशीन",
      'scen4_obj': "विरहांक (फाइबोनैचि) अनुक्रम के योगात्मक नियम की खोज करें।",
      'scen4_s0': "दोनों '1' ब्लॉकों को मशीन में खींचें।",
      'scen4_s1': "'1' और '2' ब्लॉकों को मशीन में खींचें।",
      'scen4_s2': "अगले 3 नंबर (लक्ष्य: 5, 8, 13) उत्पन्न करें।",
      'scen4_s3': "अनुक्रम पूरा हुआ! 1, 1, 2, 3, 5, 8, 13...",
    },
  };

  String getT(String key) => i18n[_currentLanguage]![key] ?? key;

  @override
  void initState() {
    super.initState();
    // Setting orientation and immersive mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseController.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'tick':
        url = 'audio/class6/math/click.mp3';
        break;
      case 'snap':
        url = 'audio/class6/math/mixkit_2569.mp3';
        break;
      case 'error':
        url = 'audio/class6/math/mixkit_2570.mp3';
        break;
      case 'success':
        url = 'audio/class6/math/success.mp3';
        break;
      case 'enter':
        url = 'audio/class6/math/mixkit_1433.mp3';
        break;
    }
    if (url.isNotEmpty) {
      try {
        await _audioPlayer
            .play(AssetSource(url))
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Error playing sound: $e');
      }
    }
  }

  void _resetApp() {
    setState(() {
      _isCurtainOpen = false;
      _scenarioIdx = 0;
      _stepIdx = 0;
    });
  }

  void _loadScenario(int index) {
    setState(() {
      _scenarioIdx = index;
      _stepIdx = 0;
      _entities.clear();
      _globalCounter = null;
      _globalLabel = null;
      _hexagonProgress = null;
      _checklist = null;
      _isAnimatingMachine = false;

      // Transform logic to center the canvas
      _transformCtrl.value = Matrix4.identity()
        ..translate(-400.0, -400.0)
        ..scale(0.8);

      if (index == 0) {
        // Scenario 1: The Triangle Growers
        _globalCounter = "1";
        _globalLabel = null;
        _entities.add(
          GameEntity(
            x: 1000,
            y: 900,
            type: 'dot',
            radius: 20,
            color: Colors.indigo,
          ),
        );
        _entities.add(
          GameEntity(
            x: 1000,
            y: 1150,
            type: 'group',
            isDraggable: true,
            target: const Offset(1000, 900 + 50 * 1.732),
            counter: "2",
            dotsOffsets: [const Offset(-25, 0), const Offset(25, 0)],
            color: Colors.blue,
          ),
        );
      } else if (index == 1) {
        // Scenario 2: The Square Builders
        _globalCounter = "1";
        _entities.add(
          GameEntity(
            x: 970,
            y: 970,
            type: 'dot',
            radius: 20,
            color: Colors.purple,
          ),
        );
        _entities.add(
          GameEntity(
            x: 1000,
            y: 1150,
            type: 'group',
            isDraggable: true,
            target: const Offset(1000, 1000),
            counter: "+3",
            dotsOffsets: [
              const Offset(30, -30),
              const Offset(30, 30),
              const Offset(-30, 30),
            ],
            color: Colors.green,
          ),
        );
      } else if (index == 2) {
        // Scenario 3: The Network Connector
        _globalCounter = "0";
        _entities.add(
          GameEntity(
            x: 920,
            y: 940,
            type: 'dot',
            radius: 20,
            color: Colors.orange,
          ),
        );
        _entities.add(
          GameEntity(
            x: 1080,
            y: 940,
            type: 'dot',
            radius: 20,
            color: Colors.orange,
          ),
        );
      } else if (index == 3) {
        // Scenario 4: The Hexagon Hive
        _hexagonProgress = "0 / 18";

        // Base Hexagons
        _entities.add(
          GameEntity(
            x: 720,
            y: 780,
            type: 'group',
            dotsOffsets: [const Offset(0, 0)],
            counter: "Hex 1 (1)",
            color: Colors.grey,
          ),
        );
        _entities.add(
          GameEntity(
            x: 1000,
            y: 780,
            type: 'group',
            dotsOffsets: [
              const Offset(0, 0),
              const Offset(30, 0),
              const Offset(-30, 0),
            ],
            counter: "Hex 2 (7)",
            color: Colors.blue,
          ),
        );
        _entities.add(
          GameEntity(
            x: 1280,
            y: 780,
            type: 'group',
            dotsOffsets: [
              const Offset(0, 0),
              const Offset(30, 0),
              const Offset(-30, 0),
              const Offset(0, 30),
            ],
            counter: "Hex 3 (19)",
            color: Colors.green,
          ),
        );

        // Creation of 18 empty slots in a true hexagon shape
        double rHex = 130;
        for (int side = 0; side < 6; side++) {
          double angle1 = (side / 6) * 2 * pi;
          double angle2 = ((side + 1) / 6) * 2 * pi;
          Offset p1 = Offset(
            1000 + rHex * cos(angle1),
            1100 + rHex * sin(angle1),
          );
          Offset p2 = Offset(
            1000 + rHex * cos(angle2),
            1100 + rHex * sin(angle2),
          );

          // 3 dots per side
          for (int step = 0; step < 3; step++) {
            double t = step / 3;
            double px = p1.dx + (p2.dx - p1.dx) * t;
            double py = p1.dy + (p2.dy - p1.dy) * t;
            _entities.add(
              GameEntity(x: px, y: py, type: 'ghost_dot', radius: 14),
            );
          }
        }

        // Source red dot
        _entities.add(
          GameEntity(
            x: 1000,
            y: 1350,
            type: 'dot',
            radius: 20,
            color: Colors.redAccent,
            isDraggable: true,
            label: '+',
          ),
        );
      } else if (index == 4) {
        // Scenario 5: Virahanka Machine
        _beltSeq = [1, 1];
        _updateConveyorBelt();
      }
    });
  }

  void _updateConveyorBelt() {
    _entities.removeWhere((e) => e.type == 'block' && e.inSlot == null);
    List<int> visible = _beltSeq.length > 6
        ? _beltSeq.sublist(_beltSeq.length - 6)
        : _beltSeq;
    double startX = 1250 - (visible.length - 1) * 80;

    for (int i = 0; i < visible.length; i++) {
      int actualIndex = _beltSeq.length - visible.length + i;
      bool isComplete = (_scenarioIdx == 4 && _stepIdx >= 3);
      bool isLastTwo = !isComplete && (actualIndex >= _beltSeq.length - 2);

      _entities.add(
        GameEntity(
          type: 'block',
          val: visible[i],
          x: startX + i * 80,
          y: 1160,
          color: isLastTwo ? Colors.blue : Colors.blueGrey,
          isDraggable: isLastTwo,
        ),
      );
    }

    if (_scenarioIdx == 4 && _stepIdx == 2) {
      List<int> currentSeq = _beltSeq.sublist(2);
      _checklist = [
        currentSeq.contains(5),
        currentSeq.contains(8),
        currentSeq.contains(13),
      ];
      if (_checklist![0] && _checklist![1] && _checklist![2]) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _advanceStep();
          setState(() {
            _updateConveyorBelt();
          });
        });
      }
    }
  }

  void _advanceStep() {
    if (_stepIdx >= 3) return;
    _playSound('success');
    setState(() {
      _stepIdx++;
      if (_scenarioIdx == 0) {
        if (_stepIdx == 1) {
          _globalCounter = "3";
          _globalLabel = "1 + 2 = 3";
          _entities.add(
            GameEntity(
              x: 1000,
              y: 1200,
              type: 'group',
              isDraggable: true,
              target: const Offset(1000, 900 + 50 * 1.732 * 2),
              counter: "3",
              color: Colors.amber,
              dotsOffsets: [
                const Offset(-50, 0),
                const Offset(0, 0),
                const Offset(50, 0),
              ],
            ),
          );
        } else if (_stepIdx == 2) {
          _globalCounter = "6";
          _globalLabel = "1 + 2 + 3 = 6";
          _entities.add(
            GameEntity(
              x: 1000,
              y: 1250,
              type: 'group',
              isDraggable: true,
              target: const Offset(1000, 900 + 50 * 1.732 * 3),
              counter: "4",
              color: Colors.green,
              dotsOffsets: [
                const Offset(-75, 0),
                const Offset(-25, 0),
                const Offset(25, 0),
                const Offset(75, 0),
              ],
            ),
          );
        } else if (_stepIdx == 3) {
          _globalCounter = "10";
          _globalLabel = "1 + 2 + 3 + 4 = 10";
        }
      } else if (_scenarioIdx == 1) {
        if (_stepIdx == 1) {
          _globalCounter = "4";
          _globalLabel = "1 + 3 = 4";
          _entities.add(
            GameEntity(
              x: 1000,
              y: 1200,
              type: 'group',
              isDraggable: true,
              target: const Offset(1000, 1000),
              counter: "+5",
              color: Colors.blue,
              dotsOffsets: [
                const Offset(90, -30),
                const Offset(90, 30),
                const Offset(90, 90),
                const Offset(30, 90),
                const Offset(-30, 90),
              ],
            ),
          );
        } else if (_stepIdx == 2) {
          _globalCounter = "9";
          _globalLabel = "1 + 3 + 5 = 9";
          _entities.add(
            GameEntity(
              x: 1000,
              y: 1250,
              type: 'group',
              isDraggable: true,
              target: const Offset(1000, 1000),
              counter: "+7",
              color: Colors.orange,
              dotsOffsets: [
                const Offset(150, -30),
                const Offset(150, 30),
                const Offset(150, 90),
                const Offset(150, 150),
                const Offset(90, 150),
                const Offset(30, 150),
                const Offset(-30, 150),
              ],
            ),
          );
        } else if (_stepIdx == 3) {
          _globalCounter = "16";
          _globalLabel = "1 + 3 + 5 + 7 = 16";
        }
      } else if (_scenarioIdx == 2) {
        if (_stepIdx == 1) {
          _globalCounter = "1";
          _globalLabel = "1 line";
        } else if (_stepIdx == 2) {
          _globalCounter = "3";
          _globalLabel = "1 + 2 = 3 lines";
        } else if (_stepIdx == 3) {
          _globalCounter = "6";
          _globalLabel = "1 + 2 + 3 = 6 lines";
        }
      }
    });
  }

  void _checkCurrentStep() {
    _playSound('tick');
    if (_scenarioIdx == 3) {
      int filled = _entities
          .where((e) => e.type == 'ghost_dot' && e.filled)
          .length;
      if (filled == 18) {
        if (_stepIdx < 3) {
          _playSound('success');
          setState(() {
            _stepIdx = 3; // Go straight to final step
          });
        }
      } else {
        _playSound('error');
      }
    } else if (_scenarioIdx == 4) {
      // Auto handled by machine logic
    } else {
      if (_entities.where((e) => e.isDraggable && e.type != 'dot').isEmpty) {
        _advanceStep();
      }
    }
  }

  void _executeNetworkAction(String action) {
    _playSound('tick');
    List<GameEntity> nodes = _entities.where((e) => e.type == 'dot').toList();
    if (action == 'add') {
      if (nodes.length == 2) {
        _entities.add(
          GameEntity(
            x: 1080,
            y: 1080,
            type: 'dot',
            radius: 20,
            color: Colors.orange,
          ),
        );
      } else if (nodes.length == 3) {
        _entities.add(
          GameEntity(
            x: 920,
            y: 1080,
            type: 'dot',
            radius: 20,
            color: Colors.orange,
          ),
        );
      }
      _playSound('enter');
      setState(() {});
    } else if (action == 'connect') {
      int newLines = 0;
      List<Color> colors = [Colors.grey, Colors.green, Colors.blue];
      Color lColor = colors[_stepIdx % colors.length];

      for (int i = 0; i < nodes.length; i++) {
        for (int j = i + 1; j < nodes.length; j++) {
          bool exists = _entities.any(
            (e) =>
                e.type == 'line' &&
                ((e.from == i && e.to == j) || (e.from == j && e.to == i)),
          );
          if (!exists) {
            _entities.add(
              GameEntity(
                x: nodes[i].x,
                y: nodes[i].y,
                target: Offset(nodes[j].x, nodes[j].y),
                type: 'line',
                from: i,
                to: j,
                color: lColor,
              ),
            );
            newLines++;
          }
        }
      }
      if (newLines > 0) {
        _playSound('snap');
        _advanceStep();
      }
    }
  }

  Offset _screenToWorld(Offset screenPos) {
    final Matrix4 inv = Matrix4.inverted(_transformCtrl.value);
    return MatrixUtils.transformPoint(inv, screenPos);
  }

  void _evaluateMachine() {
    if (_isAnimatingMachine) return;
    var s1 = _entities.where((e) => e.inSlot == 1).toList();
    var s2 = _entities.where((e) => e.inSlot == 2).toList();

    if (s1.isNotEmpty && s2.isNotEmpty) {
      _isAnimatingMachine = true;
      int outVal = s1[0].val! + s2[0].val!;
      _playSound('success');

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _entities.remove(s1[0]);
          _entities.remove(s2[0]);
          _beltSeq.add(outVal);
          _updateConveyorBelt();
          _isAnimatingMachine = false;
          if (_stepIdx < 2 && _beltSeq.length > 2 + _stepIdx) {
            _advanceStep();
          }
        });
      });
    }
  }

  // Shared action button widget for both floating card and sidebar
  Widget _buildActionControls() {
    int dotsCount = _entities.where((e) => e.type == 'dot').length;
    bool showAdd = false;
    bool showConnect = false;

    // Logic for "3. The Network Connector" buttons step-by-step
    if (_scenarioIdx == 2) {
      if (_stepIdx == 0) {
        showConnect = true; // start with 2 dots, just connect
      } else if (_stepIdx == 1) {
        if (dotsCount == 2) showAdd = true;
        if (dotsCount == 3) showConnect = true;
      } else if (_stepIdx == 2) {
        if (dotsCount == 3) showAdd = true;
        if (dotsCount == 4) showConnect = true;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_scenarioIdx == 2 && _stepIdx < 3) ...[
          Row(
            children: [
              if (showAdd)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _executeNetworkAction('add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor:
                          Colors.white, // Explicitly white for visibility
                    ),
                    child: Text(
                      getT('add_dot'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              if (showAdd && showConnect) const SizedBox(width: 8),
              if (showConnect)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _executeNetworkAction('connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor:
                          Colors.white, // Explicitly white for visibility
                    ),
                    child: Text(
                      getT('connect_all'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (_scenarioIdx == 3 || _scenarioIdx == 4) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor:
                    Colors.black, // Explicitly black for visibility
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _checkCurrentStep,
              child: Text(
                getT('check_work'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurtain() {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hexagon_outlined,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                Text(
                  getT('title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  getT('subtitle'),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 48),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(
                              _pulseController.value * 0.5,
                            ),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      _playSound('enter');
                      setState(() {
                        _isCurtainOpen = true;
                        _loadScenario(0);
                      });
                    },
                    child: Text(
                      getT('enter'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    double screenWidth = MediaQuery.of(context).size.width;
    // Constrain sidebar width between limits
    if (_sidebarWidth < 250) _sidebarWidth = 250;
    if (_sidebarWidth > screenWidth * 0.6) _sidebarWidth = screenWidth * 0.6;

    return AnimatedContainer(
      duration: _isSidebarOpen
          ? const Duration(milliseconds: 0) // No animation during dragging
          : const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isSidebarOpen ? _sidebarWidth : 0,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        border: const Border(right: BorderSide(color: Colors.white12)),
      ),
      child: _isSidebarOpen
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 64, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.hexagon_outlined,
                              size: 30,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                getT('title'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getT('subtitle'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Language & Reset Controls
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.language, size: 16),
                                label: Text(_currentLanguage.toUpperCase()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  _playSound('tick');
                                  setState(() {
                                    _currentLanguage = _currentLanguage == 'en'
                                        ? 'hi'
                                        : 'en';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Row(
                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    color: Colors.redAccent,
                                  ),
                                  Text(
                                    getT('reset'),
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white10,
                              ),
                              tooltip: getT('reset'),
                              onPressed: () {
                                _playSound('tick');
                                _resetApp();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Text(
                          getT('select_scen'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white10,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E293B),
                              value: _scenarioIdx,
                              items: List.generate(
                                5,
                                (index) => DropdownMenuItem(
                                  value: index,
                                  child: Text(
                                    getT('scen${index}_title'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null) {
                                  _playSound('tick');
                                  _loadScenario(val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          getT('mission_obj'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getT('scen${_scenarioIdx}_obj'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          getT('target_output'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (int i = 0; i <= _stepIdx; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: i == _stepIdx
                                  ? Colors.white10
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: i == _stepIdx
                                    ? Colors.indigoAccent.withOpacity(0.5)
                                    : Colors.white12,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  i == _stepIdx
                                      ? Icons.adjust
                                      : Icons.check_circle,
                                  color: i == _stepIdx
                                      ? Colors.indigoAccent
                                      : Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    getT('scen${_scenarioIdx}_s$i'),
                                    style: TextStyle(
                                      color: i == _stepIdx
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),
                        _buildActionControls(), // Shared control widget

                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              getT('footer'),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }

  // Floating card that appears when the sidebar is closed
  Widget _buildFloatingCard() {
    if (_isSidebarOpen) return const SizedBox.shrink();
    return Positioned(
      top: 64,
      left: 10,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getT('scen${_scenarioIdx}_s$_stepIdx'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildActionControls(), // Action buttons will appear here when sidebar is closed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessModal() {
    if (_stepIdx < 3) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    getT('success'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getT('scen${_scenarioIdx}_s3'),
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _playSound('tick');
                      if (_scenarioIdx < 4) {
                        _loadScenario(_scenarioIdx + 1);
                      } else {
                        _resetApp();
                      }
                    },
                    icon: Icon(
                      _scenarioIdx < 4 ? Icons.arrow_forward : Icons.check,
                      color: Colors.white,
                    ),
                    label: Text(
                      getT(_scenarioIdx < 4 ? 'next' : 'finish'),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCurtainOpen) return _buildCurtain();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            Row(
              children: [
                _buildSidebar(),
                if (_isSidebarOpen)
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        setState(() {
                          _sidebarWidth += details.delta.dx;
                        });
                      },
                      child: Container(
                        width: 10,
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
                Expanded(
                  child: Stack(
                    children: [
                      // Canvas Background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F172A), Color(0xFF4C0519)],
                          ),
                        ),
                      ),

                      // Interactive Canvas
                      Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (event) {
                          Offset world = _screenToWorld(event.localPosition);
                          List<GameEntity> draggables = _entities
                              .where((e) => e.isDraggable)
                              .toList()
                              .reversed
                              .toList();

                          for (var ent in draggables) {
                            bool hit = false;
                            if (ent.type == 'group') {
                              double minX = 10000,
                                  maxX = -10000,
                                  minY = 10000,
                                  maxY = -10000;
                              for (var d in ent.dotsOffsets!) {
                                if (d.dx < minX) minX = d.dx;
                                if (d.dx > maxX) maxX = d.dx;
                                if (d.dy < minY) minY = d.dy;
                                if (d.dy > maxY) maxY = d.dy;
                              }
                              double cx = ent.x + (minX + maxX) / 2;
                              double cy = ent.y + (minY + maxY) / 2;
                              double hw = (maxX - minX) / 2 + 40;
                              double hh = (maxY - minY) / 2 + 40;
                              if ((world.dx - cx).abs() < hw &&
                                  (world.dy - cy).abs() < hh) {
                                hit = true;
                              }
                            } else if (ent.type == 'block' ||
                                ent.type == 'dot') {
                              double dist =
                                  (world - Offset(ent.x, ent.y)).distance;
                              if (dist <= 40) hit = true;
                            }

                            if (hit) {
                              _playSound('tick');
                              setState(() {
                                _draggedEntity = ent;
                                _dragStartPos = Offset(ent.x, ent.y);
                                _entities.remove(ent);
                                _entities.add(ent); // Bring to front
                                _panEnabled =
                                    false; // Disable panning while dragging
                              });
                              return;
                            }
                          }
                          // Touched nothing - enable pan and zoom
                          setState(() {
                            _panEnabled = true;
                            _draggedEntity = null;
                          });
                        },
                        onPointerMove: (event) {
                          if (!_panEnabled && _draggedEntity != null) {
                            double scale = _transformCtrl.value
                                .getMaxScaleOnAxis();
                            Offset worldDelta = event.delta / scale;

                            setState(() {
                              _draggedEntity!.x += worldDelta.dx;
                              _draggedEntity!.y += worldDelta.dy;

                              // Target highlight logic
                              _draggedEntity!.isNearTarget = false;
                              if (_draggedEntity!.target != null) {
                                if ((Offset(
                                              _draggedEntity!.x,
                                              _draggedEntity!.y,
                                            ) -
                                            _draggedEntity!.target!)
                                        .distance <
                                    60) {
                                  _draggedEntity!.isNearTarget = true;
                                }
                              } else if (_scenarioIdx == 3 &&
                                  _draggedEntity!.type == 'dot') {
                                for (var g in _entities.where(
                                  (e) => e.type == 'ghost_dot' && !e.filled,
                                )) {
                                  if ((Offset(
                                                _draggedEntity!.x,
                                                _draggedEntity!.y,
                                              ) -
                                              Offset(g.x, g.y))
                                          .distance <
                                      40) {
                                    _draggedEntity!.isNearTarget = true;
                                    break;
                                  }
                                }
                              } else if (_scenarioIdx == 4 &&
                                  _draggedEntity!.type == 'block') {
                                Offset slot1 = const Offset(920, 920);
                                Offset slot2 = const Offset(1080, 920);
                                if ((Offset(
                                                  _draggedEntity!.x,
                                                  _draggedEntity!.y,
                                                ) -
                                                slot1)
                                            .distance <
                                        60 ||
                                    (Offset(
                                                  _draggedEntity!.x,
                                                  _draggedEntity!.y,
                                                ) -
                                                slot2)
                                            .distance <
                                        60) {
                                  _draggedEntity!.isNearTarget = true;
                                }
                              }
                            });
                          }
                        },
                        onPointerUp: (event) {
                          if (_draggedEntity != null) {
                            GameEntity ent = _draggedEntity!;
                            bool snapped = false;

                            if (ent.target != null) {
                              if ((Offset(ent.x, ent.y) - ent.target!)
                                      .distance <
                                  60) {
                                ent.x = ent.target!.dx;
                                ent.y = ent.target!.dy;
                                ent.isDraggable = false;
                                ent.isNearTarget = false;
                                _playSound('snap');
                                snapped = true;
                                _checkCurrentStep();
                              }
                            } else if (_scenarioIdx == 3 && ent.type == 'dot') {
                              for (var g in _entities.where(
                                (e) => e.type == 'ghost_dot' && !e.filled,
                              )) {
                                if ((Offset(ent.x, ent.y) - Offset(g.x, g.y))
                                        .distance <
                                    40) {
                                  ent.x = g.x;
                                  ent.y = g.y;
                                  ent.isDraggable = false;
                                  ent.isNearTarget = false;
                                  g.filled = true;
                                  snapped = true;
                                  _playSound('snap');

                                  int placed = _entities
                                      .where(
                                        (e) =>
                                            e.type == 'ghost_dot' && e.filled,
                                      )
                                      .length;
                                  _hexagonProgress = "$placed / 18";

                                  // Automatically advance step on Scenario 3 progress
                                  if (placed >= 6 && _stepIdx == 0) {
                                    _advanceStep();
                                  }
                                  if (placed >= 12 && _stepIdx == 1) {
                                    _advanceStep();
                                  }
                                  if (placed >= 18 && _stepIdx == 2) {
                                    _advanceStep();
                                  }

                                  // Respawn source dot ONLY if not fully completed
                                  if (placed < 18) {
                                    _entities.add(
                                      GameEntity(
                                        x: 1000,
                                        y: 1350,
                                        type: 'dot',
                                        radius: 20,
                                        color: Colors.redAccent,
                                        isDraggable: true,
                                        label: '+',
                                      ),
                                    );
                                  }
                                  break;
                                }
                              }
                            } else if (_scenarioIdx == 4 &&
                                ent.type == 'block') {
                              Offset slot1 = const Offset(920, 920);
                              Offset slot2 = const Offset(1080, 920);
                              bool s1Full = _entities.any((e) => e.inSlot == 1);
                              bool s2Full = _entities.any((e) => e.inSlot == 2);

                              if ((Offset(ent.x, ent.y) - slot1).distance <
                                      60 &&
                                  !s1Full) {
                                ent.x = slot1.dx;
                                ent.y = slot1.dy;
                                ent.inSlot = 1;
                                ent.isDraggable = false;
                                ent.isNearTarget = false;
                                snapped = true;
                                _playSound('snap');
                                _evaluateMachine();
                              } else if ((Offset(ent.x, ent.y) - slot2)
                                          .distance <
                                      60 &&
                                  !s2Full) {
                                ent.x = slot2.dx;
                                ent.y = slot2.dy;
                                ent.inSlot = 2;
                                ent.isDraggable = false;
                                ent.isNearTarget = false;
                                snapped = true;
                                _playSound('snap');
                                _evaluateMachine();
                              }
                            }

                            if (!snapped) {
                              ent.x = _dragStartPos.dx;
                              ent.y = _dragStartPos.dy;
                              _playSound('error');
                            }

                            setState(() {
                              _draggedEntity = null;
                              _panEnabled =
                                  true; // Drag completed, enable canvas panning
                            });
                          } else {
                            setState(() {
                              _panEnabled = true;
                            });
                          }
                        },
                        child: InteractiveViewer(
                          transformationController: _transformCtrl,
                          panEnabled: _panEnabled,
                          scaleEnabled: true,
                          constrained: false, // Allows unlimited panning
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          minScale: 0.1,
                          maxScale: 5.0,
                          child: SizedBox(
                            width: 2000,
                            height: 2000,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(painter: GridPainter()),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: GamePainter(
                                      entities: _entities,
                                      globalCounter: _globalCounter,
                                      globalLabel: _globalLabel,
                                      scenarioIdx: _scenarioIdx,
                                      hexagonProgress: _hexagonProgress,
                                      checklist: _checklist,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      _buildFloatingCard(),
                      _buildSuccessModal(),
                    ],
                  ),
                ),
              ],
            ),

            // Fixed Menu Icon Top-Left
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound('tick');
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
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
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GamePainter extends CustomPainter {
  final List<GameEntity> entities;
  final String? globalCounter;
  final String? globalLabel;
  final int scenarioIdx;
  final String? hexagonProgress;
  final List<bool>? checklist;

  GamePainter({
    required this.entities,
    this.globalCounter,
    this.globalLabel,
    required this.scenarioIdx,
    this.hexagonProgress,
    this.checklist,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scenario specific backgrounds
    if (scenarioIdx == 4) {
      // Machine Base
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(1000, 900),
            width: 280,
            height: 200,
          ),
          const Radius.circular(20),
        ),
        Paint()..color = Colors.blueGrey.shade800,
      );
      // Hoppers
      canvas.drawRect(
        Rect.fromCenter(center: const Offset(920, 880), width: 60, height: 40),
        Paint()..color = Colors.blueGrey.shade900,
      );
      canvas.drawRect(
        Rect.fromCenter(center: const Offset(1080, 880), width: 60, height: 40),
        Paint()..color = Colors.blueGrey.shade900,
      );
      // Plus sign
      TextPainter(
          text: const TextSpan(
            text: "+",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, const Offset(985, 900));
      // Belt
      canvas.drawRect(
        Rect.fromCenter(
          center: const Offset(1000, 1180),
          width: 700,
          height: 30,
        ),
        Paint()..color = Colors.blueGrey.shade900,
      );
    }

    if (scenarioIdx == 3) {
      TextPainter(
          text: TextSpan(
            text: hexagonProgress ?? "",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, const Offset(960, 1200));
    }

    // Draw entities
    for (var ent in entities) {
      canvas.save();
      canvas.translate(ent.x, ent.y);

      if (ent.isNearTarget) {
        canvas.drawCircle(
          Offset.zero,
          ent.radius + 10,
          Paint()
            ..color = Colors.white24
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }

      if (ent.type == 'dot') {
        _drawDot(canvas, 0, 0, ent.radius, ent.color, ent.label);
      } else if (ent.type == 'ghost_dot') {
        canvas.drawCircle(
          Offset.zero,
          ent.radius,
          Paint()
            ..color = Colors.white24
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        if (ent.filled) {
          _drawDot(canvas, 0, 0, ent.radius, Colors.redAccent, null);
        }
      } else if (ent.type == 'group') {
        if (ent.isNearTarget) {
          // Highlight bound
          double minX = 10000, maxX = -10000, minY = 10000, maxY = -10000;
          for (var d in ent.dotsOffsets!) {
            if (d.dx < minX) minX = d.dx;
            if (d.dx > maxX) maxX = d.dx;
            if (d.dy < minY) minY = d.dy;
            if (d.dy > maxY) maxY = d.dy;
          }
          canvas.drawRRect(
            RRect.fromLTRBR(
              minX - 25,
              minY - 25,
              maxX + 25,
              maxY + 25,
              const Radius.circular(10),
            ),
            Paint()..color = Colors.white24,
          );
        }
        for (var d in ent.dotsOffsets!) {
          _drawDot(canvas, d.dx, d.dy, 20, ent.color, null);
        }
        if (ent.counter != null) {
          TextPainter tp = TextPainter(
            text: TextSpan(
              text: ent.counter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(-tp.width / 2, 40));
        }
      } else if (ent.type == 'line') {
        canvas.drawLine(
          Offset.zero,
          Offset(ent.target!.dx - ent.x, ent.target!.dy - ent.y),
          Paint()
            ..color = ent.color
            ..strokeWidth = 4,
        );
      } else if (ent.type == 'block') {
        _draw3DBlock(canvas, 60, ent.val.toString(), ent.color);
      }

      canvas.restore();
    }

    if (globalCounter != null) {
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: globalCounter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(1000 - tp.width / 2, 820));
    }
    if (globalLabel != null) {
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: globalLabel,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(1000 - tp.width / 2, 880));
    }
  }

  void _drawDot(
    Canvas canvas,
    double x,
    double y,
    double r,
    Color color,
    String? label,
  ) {
    canvas.drawCircle(Offset(x, y), r, Paint()..color = color);
    canvas.drawCircle(
      Offset(x - r * 0.3, y - r * 0.3),
      r * 0.3,
      Paint()..color = Colors.white.withOpacity(0.3),
    );
    if (label != null) {
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: r,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  void _draw3DBlock(Canvas canvas, double size, String val, Color color) {
    double h = size, w = size, d = 15;
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      Paint()..color = color,
    );

    Path top = Path()
      ..moveTo(-w / 2, -h / 2)
      ..lineTo(-w / 2 + d, -h / 2 - d)
      ..lineTo(w / 2 + d, -h / 2 - d)
      ..lineTo(w / 2, -h / 2)
      ..close();
    canvas.drawPath(top, Paint()..color = _adjust(color, 20));

    Path right = Path()
      ..moveTo(w / 2, -h / 2)
      ..lineTo(w / 2 + d, -h / 2 - d)
      ..lineTo(w / 2 + d, h / 2 - d)
      ..lineTo(w / 2, h / 2)
      ..close();
    canvas.drawPath(right, Paint()..color = _adjust(color, -20));

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: val,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  Color _adjust(Color c, int amount) {
    int r = (c.red + amount).clamp(0, 255);
    int g = (c.green + amount).clamp(0, 255);
    int b = (c.blue + amount).clamp(0, 255);
    return Color.fromARGB(c.alpha, r, g, b);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
