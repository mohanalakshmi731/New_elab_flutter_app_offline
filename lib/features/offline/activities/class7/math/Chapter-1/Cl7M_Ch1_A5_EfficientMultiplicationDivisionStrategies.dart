// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EfficientMultiplicationDivisionStrategies(),
    ),
  );
}

class EfficientMultiplicationDivisionStrategies extends StatefulWidget {
  const EfficientMultiplicationDivisionStrategies({super.key});

  @override
  State<EfficientMultiplicationDivisionStrategies> createState() =>
      _EfficientMultiplicationDivisionStrategiesState();
}

class _EfficientMultiplicationDivisionStrategiesState
    extends State<EfficientMultiplicationDivisionStrategies>
    with TickerProviderStateMixin {
  bool _showShutter = true;
  bool _isSidebarOpen = true;
  int _currentScenario = 1;
  String _lang = 'EN';

  // --- Factory Interaction State ---
  int _flowState = 0;
  // 0: Waiting for drag to belt
  // 1: On Belt, ready to start
  // 2: Moving to Duplicator
  // 3: Inside Duplicator, ready to multiply
  // 4: Multiplying animation
  // 5: Ready to move to Splitter
  // 6: Moving to Splitter
  // 7: Inside Splitter, ready to divide
  // 8: Dividing animation (valid moves right, recycle moves down)
  // 9: Done (Summary visible)

  // Crate positions & counts
  bool _isDraggingCrate = false;
  double _crateX = -200; // Screen coordinates offset from center
  double _crateY = 200;
  int _crateCount = 16;

  double _recycleX = 150;
  double _recycleY = 0;
  int _recycleCount = 0;
  bool _showRecycle = false;

  // Drop zone config
  final double _dropZoneX = -300;
  final double _dropZoneY = 0;

  // Feedback State
  String? _feedbackMessage;
  bool _feedbackIsSuccess = false;
  bool _showFinalPopup = false;
  bool _showSummaryBoard = false;
  Offset _summaryOffset = Offset.zero; // Track the drag position

  late AnimationController _animController;
  late Animation<double> _anim;

  // Duplicator Glow Animation
  late AnimationController _glowController;

  // Canvas View Controller
  final TransformationController _canvasTransformationController =
      TransformationController();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- Scenario Data Structure ---
  final Map<int, Map<String, dynamic>> _scenarios = {
    1: {
      'title': {'en': '1. The x5 Multiplier', 'hi': '1. x5 गुणक'},
      'objective': {
        'en':
            'Understand how multiplying by 5 is efficiently done by multiplying by 10 then dividing by 2.',
        'hi':
            'समझें कि 5 से गुणा 10 से गुणा करके फिर 2 से भाग देकर कैसे कुशलता से किया जाता है।',
      },
      'input': 16,
      'mult': 10,
      'div': 2,
      'dupLabel': 'x10 DUPLICATOR',
      'splitLabel': '÷2 SPLITTER',
      'equation': '16 × 5 = 16 × (10 ÷ 2) = 160 ÷ 2 = 80',
      'learning': {
        'en':
            'Multiplying by 5 is the same as multiplying by 10 and then dividing by 2!',
        'hi': '5 से गुणा करना 10 से गुणा करके 2 से भाग देने के समान है!',
      },
      'steps': [
        {
          'en':
              'DRAG the stack of 16 crates onto the yellow drop zone on the conveyor belt.',
          'hi':
              '16 क्रेट्स के स्टैक को कन्वेयर बेल्ट पर पीले ड्रॉप ज़ोन में खींचें।',
        },
        {
          'en':
              'Start the machine to move the crates into the "x10 Duplicator".',
          'hi':
              'क्रेट्स को "x10 डुप्लिकेटर" में ले जाने के लिए मशीन शुरू करें।',
        },
        {
          'en': 'Execute multiplication to duplicate the crates by 10.',
          'hi': 'क्रेट्स को 10 से गुणा करने के लिए गुणा निष्पादित करें।',
        },
        {
          'en': 'Move the 160 crates into the "÷2 Splitter".',
          'hi': '160 क्रेट्स को "÷2 स्प्लिटर" में ले जाएं।',
        },
        {
          'en': 'Execute division to split the stack by 2 and remove excess.',
          'hi':
              'स्टैक को 2 से विभाजित करने और अतिरिक्त निकालने के लिए भाग निष्पादित करें।',
        },
        {
          'en': 'Review the final output and efficiency summary.',
          'hi': 'अंतिम आउटपुट और सारांश की समीक्षा करें।',
        },
      ],
    },
    2: {
      'title': {'en': '2. The x25 Multiplier', 'hi': '2. x25 गुणक'},
      'objective': {
        'en':
            'Understand how multiplying by 25 is efficiently done by multiplying by 100 then dividing by 4.',
        'hi':
            'समझें कि 25 से गुणा 100 से गुणा करके फिर 4 से भाग देकर कैसे कुशलता से किया जाता है।',
      },
      'input': 12,
      'mult': 100,
      'div': 4,
      'dupLabel': 'x100 DUPLICATOR',
      'splitLabel': '÷4 SPLITTER',
      'equation': '12 × 25 = 12 × (100 ÷ 4) = 1200 ÷ 4 = 300',
      'learning': {
        'en':
            'Multiplying by 25 is the same as multiplying by 100 and then dividing by 4!',
        'hi': '25 से गुणा करना 100 से गुणा करके 4 से भाग देने के समान है!',
      },
      'steps': [
        {
          'en':
              'DRAG the stack of 12 crates onto the yellow drop zone on the conveyor belt.',
          'hi':
              '12 क्रेट्स के स्टैक को कन्वेयर बेल्ट पर पीले ड्रॉप ज़ोन में खींचें।',
        },
        {
          'en':
              'Start the machine to move the crates into the "x100 Duplicator".',
          'hi':
              'क्रेट्स को "x100 डुप्लिकेटर" में ले जाने के लिए मशीन शुरू करें।',
        },
        {
          'en': 'Execute multiplication to duplicate the crates by 100.',
          'hi': 'क्रेट्स को 100 से गुणा करने के लिए गुणा निष्पादित करें।',
        },
        {
          'en': 'Move the 1200 crates into the "÷4 Splitter".',
          'hi': '1200 क्रेट्स को "÷4 स्प्लिटर" में ले जाएं।',
        },
        {
          'en': 'Execute division to split the stack by 4 and remove excess.',
          'hi':
              'स्टैक को 4 से विभाजित करने और अतिरिक्त निकालने के लिए भाग निष्पादित करें।',
        },
        {
          'en': 'Review the final output and efficiency summary.',
          'hi': 'अंतिम आउटपुट और सारांश की समीक्षा करें।',
        },
      ],
    },
  };

  // --- Translation Dictionary ---
  final Map<String, Map<String, String>> _t = {
    'titleMain': {
      'en': 'The Number Factory',
      'hi': 'संख्या कारखाना: कुशल गुणा और भाग',
    },
    'titleSub': {
      'en': 'Class 7 • Efficient Multiplication & Division',
      'hi': 'कक्षा 7 • कुशल गुणा और भाग',
    },
    'enterLab': {'en': 'Enter Factory', 'hi': 'कारखाने में प्रवेश करें'},
    'missionObjective': {'en': 'Mission Objective', 'hi': 'मिशन का उद्देश्य'},
    'proceduralSteps': {'en': 'Procedural Steps', 'hi': 'प्रक्रियात्मक चरण'},
    'step': {'en': 'STEP', 'hi': 'चरण'},
    'validate': {'en': 'Validate Model', 'hi': 'मॉडल मान्य करें'},
    'validated': {'en': 'Model Validated!', 'hi': 'मॉडल मान्य!'},
    'labCompleted': {
      'en': 'Factory Process Complete!',
      'hi': 'प्रक्रिया पूर्ण!',
    },
    'congrats': {
      'en': 'Congratulations, you have mastered Efficient Multiplication!',
      'hi': 'बधाई हो, आपने कुशल गुणा में महारत हासिल कर ली है!',
    },
    'restartLab': {'en': 'Restart Factory', 'hi': 'पुनः प्रारंभ करें'},
    'footer': {
      'en': '© ZeroScienceLab - Fall in love with math and Science',
      'hi': '© ZeroScienceLab - Fall in love with math and Science',
    },
    'input': {'en': 'INPUT:', 'hi': 'इनपुट:'},
    'output': {'en': 'OUTPUT:', 'hi': 'आउटपुट:'},
    'summary': {'en': 'SUMMARY', 'hi': 'सारांश'},
    'close': {'en': 'Close', 'hi': 'बंद करें'},
    // Action Buttons
    'btnStart': {'en': 'Start Machine', 'hi': 'मशीन शुरू करें'},
    'btnExecMult': {
      'en': 'Execute Multiplication',
      'hi': 'गुणा निष्पादित करें',
    },
    'btnMoveSplit': {'en': 'Move to Splitter', 'hi': 'स्प्लिटर पर जाएँ'},
    'btnExecDiv': {'en': 'Execute Division', 'hi': 'भाग निष्पादित करें'},
    'btnSummary': {'en': 'View Summary', 'hi': 'सारांश देखें'},
    'selectScenario': {'en': 'SELECT SCENARIO', 'hi': 'परिदृश्य चुनें'},
    'hudTask0': {
      'en': 'DRAG crates to the yellow drop zone.',
      'hi': 'क्रेट्स को पीले ड्रॉप ज़ोन में खींचें।',
    },
    'hudTask1': {
      'en': 'Input accepted. Start the machine.',
      'hi': 'इनपुट स्वीकार किया गया। मशीन शुरू करें।',
    },
    'hudTask2': {
      'en': 'Entering Duplicator...',
      'hi': 'डुप्लिकेटर में प्रवेश कर रहा है...',
    },
    'hudTask3': {
      'en': 'Inside Duplicator. Ready to multiply.',
      'hi': 'डुप्लिकेटर के अंदर। गुणा करने के लिए तैयार।',
    },
    'hudTask4': {
      'en': 'Duplicating crates...',
      'hi': 'डुप्लिकेट किया जा रहा है...',
    },
    'hudTask5': {
      'en': 'Multiplication complete. Move to Splitter.',
      'hi': 'गुणा पूर्ण। स्प्लिटर पर जाएँ।',
    },
    'hudTask6': {
      'en': 'Entering Splitter...',
      'hi': 'स्प्लिटर में प्रवेश कर रहा है...',
    },
    'hudTask7': {
      'en': 'Inside Splitter. Ready to divide.',
      'hi': 'स्प्लिटर के अंदर। भाग करने के लिए तैयार।',
    },
    'hudTask8': {
      'en': 'Dividing and sorting into chutes...',
      'hi': 'भाग और छँटाई...',
    },
    'hudTask9': {
      'en': 'Process Complete! Read Summary.',
      'hi': 'प्रक्रिया पूर्ण! सारांश पढ़ें।',
    },
  };

  String t(String key) {
    final l = _lang.toLowerCase();
    return _t[key]?[l] ?? _t[key]?['en'] ?? key;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.addListener(() => setState(() {}));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowController.addListener(() => setState(() {}));

    _initializeScenarioData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    _animController.dispose();
    _glowController.dispose();
    _canvasTransformationController.dispose();
    super.dispose();
  }

  void _initializeScenarioData() {
    final sc = _scenarios[_currentScenario]!;
    _crateCount = sc['input'] as int;
    _crateX = -200;
    _crateY = 200;
    _flowState = 0;
    _showRecycle = false;
    _showSummaryBoard = false;
    _summaryOffset = Offset.zero; // Reset position on new scenario
    _feedbackMessage = null;
    _showFinalPopup = false;
  }

  void _playSound(String type) async {
    String url = '';
    if (type == 'click') {
      url = 'audio/class7/mixkit_1120.mp3';
    } else if (type == 'success') {
      url = 'audio/class7/mixkit_2015.mp3';
    } else if (type == 'error') {
      url = 'audio/class7/mixkit_2964.mp3';
    } else if (type == 'whir') {
      url = 'audio/class7/mixkit_2574.mp3';
    } else if (type == 'split') {
      url = 'audio/class7/mixkit_1090.mp3';
    }

    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _handleScroll(PointerScrollEvent event) {
    // Determine scroll direction to zoom in/out (desktop scroll wheel)
    final double scaleChange = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
    _zoomCanvasAtPoint(scaleChange, event.localPosition);
  }

  void _zoomCanvasAtPoint(double scaleFactor, Offset focalPoint) {
    final matrix = _canvasTransformationController.value.clone();
    final double currentScale = matrix.getMaxScaleOnAxis();
    final double newScale = (currentScale * scaleFactor).clamp(0.2, 4.0);
    final double actualScaleFactor = newScale / currentScale;

    if (actualScaleFactor == 1.0) return;

    final Matrix4 transform = Matrix4.identity()
      ..translate(focalPoint.dx, focalPoint.dy)
      ..scale(actualScaleFactor, actualScaleFactor, 1.0)
      ..translate(-focalPoint.dx, -focalPoint.dy);

    _canvasTransformationController.value = transform..multiply(matrix);
  }

  void _zoomCanvas(double scaleFactor) {
    _playSound('click');
    final Size screenSize = MediaQuery.of(context).size;
    final double sidebarWidth = max(screenSize.width * 0.30, 320.0);
    final double availableWidth = _isSidebarOpen && !_showShutter
        ? screenSize.width - sidebarWidth
        : screenSize.width;

    final Offset center = Offset(availableWidth / 2, screenSize.height / 2);
    _zoomCanvasAtPoint(scaleFactor, center);
  }

  void _resetCanvasView({bool playSound = true}) {
    if (playSound) _playSound('click');

    final Size screenSize = MediaQuery.of(context).size;
    final double sidebarWidth = max(screenSize.width * 0.30, 320.0);
    final double availableWidth = _isSidebarOpen && !_showShutter
        ? screenSize.width - sidebarWidth
        : screenSize.width;

    final double contentWidth = 3000.0;
    final double contentHeight = 2000.0;

    double scaleX = availableWidth / 1600.0;
    double scaleY = screenSize.height / 1100.0;
    double scale = min(scaleX, scaleY).clamp(0.2, 4.0);

    final double dx = (availableWidth / 2) - (contentWidth / 2) * scale;
    final double dy = (screenSize.height / 2) - (contentHeight / 2) * scale;

    _canvasTransformationController.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  void _showFeedback(String msg, bool isSuccess) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackIsSuccess = isSuccess;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _feedbackMessage = null);
    });
  }

  void _loadScenario(int scenario) {
    setState(() {
      _currentScenario = scenario;
      _initializeScenarioData();
    });
  }

  // Instead of a global gesture detector that blocks the InteractiveViewer,
  // we localize the drag handlers. These functions update the crate position seamlessly.
  void _handleCratePanStart(DragStartDetails details) {
    setState(() {
      _isDraggingCrate = true;
    });
  }

  void _handleCratePanUpdate(DragUpdateDetails details) {
    if (_isDraggingCrate) {
      setState(() {
        // Delta comes pre-converted into the local space of the Stack
        // thanks to InteractiveViewer, allowing flawless tracking during zooms.
        _crateX += details.delta.dx;
        _crateY += details.delta.dy;
      });
    }
  }

  void _handleCratePanEnd(DragEndDetails details) {
    if (_isDraggingCrate) {
      setState(() {
        _isDraggingCrate = false;
        double dist = sqrt(
          pow(_crateX - _dropZoneX, 2) + pow(_crateY - _dropZoneY, 2),
        );
        if (dist < 100) {
          _playSound('success');
          _showFeedback("Perfect Placement!", true);
          _crateX = _dropZoneX;
          _crateY = _dropZoneY;
          _flowState = 1; // On belt, ready to start
        } else {
          _playSound('error');
          _showFeedback("Drag onto the yellow drop zone.", false);
          _animateMovement(_crateX, _crateY, -200, 200, () {});
        }
      });
    }
  }

  void _handleCratePanCancel() {
    setState(() {
      _isDraggingCrate = false;
    });
  }

  void _animateMovement(
    double startX,
    double startY,
    double endX,
    double endY,
    VoidCallback onComplete,
  ) {
    _animController.duration = const Duration(milliseconds: 1500);
    _animController.reset();
    _animController.forward();
    _animController.addListener(() {
      setState(() {
        _crateX = startX + (endX - startX) * _anim.value;
        _crateY = startY + (endY - startY) * _anim.value;
      });
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.removeStatusListener((status) {});
        onComplete();
      }
    });
  }

  void _animateSplitMovement(
    double startX,
    double startY,
    double endX,
    double endY,
    VoidCallback onComplete,
  ) {
    _animController.duration = const Duration(milliseconds: 1500);
    _animController.reset();
    _animController.forward();
    _animController.addListener(() {
      setState(() {
        _crateX = startX + (endX - startX) * _anim.value;
        _crateY = startY + (endY - startY) * _anim.value;
        // Move recycle crates
        _recycleX = startX + (150 - startX) * _anim.value;
        _recycleY = startY + (200 - startY) * _anim.value;
      });
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.removeStatusListener((status) {});
        onComplete();
      }
    });
  }

  void _executeAction() {
    final sc = _scenarios[_currentScenario]!;

    if (_flowState == 1) {
      _playSound('click');
      setState(() => _flowState = 2);
      _animateMovement(_crateX, _crateY, -100, 0, () {
        setState(() => _flowState = 3);
      });
    } else if (_flowState == 3) {
      _playSound('whir');
      setState(() => _flowState = 4);

      // Artificial delay for multiplication simulation
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          _crateCount = sc['input'] * sc['mult'];
          _flowState = 5;
        });
        _playSound('success');
      });
    } else if (_flowState == 5) {
      _playSound('click');
      setState(() => _flowState = 6);
      _animateMovement(_crateX, _crateY, 150, 0, () {
        setState(() => _flowState = 7);
      });
    } else if (_flowState == 7) {
      _playSound('split');
      setState(() {
        _flowState = 8;
        _showRecycle = true;
        int total = sc['input'] * sc['mult'];
        _crateCount = total ~/ sc['div'];
        _recycleCount = total - _crateCount;
        _recycleX = _crateX;
        _recycleY = _crateY;
      });

      _animateSplitMovement(_crateX, _crateY, 350, 0, () {
        setState(() {
          _flowState = 9;
          _showSummaryBoard = true;
          _summaryOffset = Offset.zero; // Reset position when shown
        });
        _playSound('success');
      });
    } else if (_flowState == 9) {
      // Validate and end
      _playSound('success');
      _showFeedback(t('validated'), true);
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          if (_currentScenario == 1) {
            _loadScenario(2);
          } else {
            _showFinalPopup = true;
          }
        });
      });
    }
  }

  void _resetLab() {
    _playSound('click');
    setState(() {
      _showShutter = true;
      _lang = 'EN';
    });
    _loadScenario(1);
  }

  Widget _buildSummaryBoard() {
    if (!_showSummaryBoard) return const SizedBox.shrink();
    final scenarioData = _scenarios[_currentScenario]!;

    return Center(
      child: Transform.translate(
        offset: _summaryOffset,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _summaryOffset += details.delta;
            });
          },
          child: Container(
            width:
                380, // Constraint added to prevent overlapping with mission card
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.indigoAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle indicator
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  t('summary'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  scenarioData['equation'] as String,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.indigoAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  (scenarioData['learning'] as Map<String, String>)[_lang
                          .toLowerCase()] ??
                      '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _showSummaryBoard = false);
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: Text(
                    t('close'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildFloatingMissionCard() {
    final scenarioData = _scenarios[_currentScenario]!;

    return Positioned(
      top: 80,
      left: 16,
      width: 250,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes, color: Colors.indigo[400], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('missionObjective'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.indigo[300],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              (scenarioData['objective'] as Map<String, String>)[_lang
                      .toLowerCase()] ??
                  '',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              t('hudTask$_flowState'),
              style: TextStyle(
                color: Colors.amber[400],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Action button inside the mission card
            if (_getActionButtonLabel().isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _executeAction,
                icon: Icon(
                  _flowState == 9 ? Icons.fact_check : Icons.touch_app,
                  size: 20,
                ),
                label: Text(
                  _getActionButtonLabel(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _flowState == 9
                      ? Colors.green[600]
                      : Colors.indigo[600],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
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
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white, size: 28),
            onPressed: () => _zoomCanvas(1.3),
            tooltip: 'Zoom In',
          ),
          const Divider(color: Colors.white24, height: 1),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white, size: 28),
            onPressed: () => _zoomCanvas(1 / 1.3),
            tooltip: 'Zoom Out',
          ),
          const Divider(color: Colors.white24, height: 1),
          IconButton(
            icon: const Icon(
              Icons.center_focus_strong,
              color: Colors.amber,
              size: 24,
            ),
            onPressed: _resetCanvasView,
            tooltip: 'Reset View',
          ),
        ],
      ),
    );
  }

  String _getActionButtonLabel() {
    if (_flowState == 1) return t('btnStart');
    if (_flowState == 3) return t('btnExecMult');
    if (_flowState == 5) return t('btnMoveSplit');
    if (_flowState == 7) return t('btnExecDiv');
    if (_flowState == 9) return t('validate');
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sidebarWidth = max(sw * 0.30, 320.0);
    final scenarioData = _scenarios[_currentScenario]!;
    final steps = scenarioData['steps'] as List;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C1220),
        body: Stack(
          children: [
            // --- 1. Canvas Area ---
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(
                  left: _isSidebarOpen && !_showShutter ? sidebarWidth : 0,
                ),
                color: const Color(0xFF0C1220),
                child: Stack(
                  children: [
                    Listener(
                      onPointerSignal: (PointerSignalEvent event) {
                        if (event is PointerScrollEvent) {
                          _handleScroll(event);
                        }
                      },
                      child: InteractiveViewer(
                        transformationController:
                            _canvasTransformationController,
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        minScale: 0.2,
                        maxScale: 4.0,
                        constrained: false, // Allows infinite panning room
                        // Disable background panning only while actively dragging crate
                        panEnabled: !_isDraggingCrate,
                        // Pinch-to-zoom logic is preserved and allowed naturally
                        scaleEnabled: true,
                        child: Container(
                          width: 3000,
                          height: 2000,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 1400,
                            height: 900,
                            // Use Stack to isolate crate touches from background touches
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Background & Crate Painting
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: FactoryPainter(
                                      crateX: _crateX,
                                      crateY: _crateY,
                                      crateCount: _crateCount,
                                      recycleX: _recycleX,
                                      recycleY: _recycleY,
                                      recycleCount: _recycleCount,
                                      showRecycle: _showRecycle,
                                      flowState: _flowState,
                                      dupLabel:
                                          scenarioData['dupLabel'] as String,
                                      splitLabel:
                                          scenarioData['splitLabel'] as String,
                                      glowValue: _glowController.value,
                                    ),
                                    willChange: true,
                                  ),
                                ),
                                // Localized Touch Layer exactly over the crate
                                if (_flowState == 0)
                                  Positioned(
                                    // 1400/2 (center) + _crateX - half of touch box width
                                    left: 1400 / 2 + _crateX - 80,
                                    top: 900 / 2 + _crateY - 80,
                                    width: 160,
                                    height: 160,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: _handleCratePanStart,
                                      onPanUpdate: _handleCratePanUpdate,
                                      onPanEnd: _handleCratePanEnd,
                                      onPanCancel: _handleCratePanCancel,
                                      child: Container(
                                        color: Colors
                                            .transparent, // Required for opaque hit testing
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildSummaryBoard(),

                    // Canvas Adjust Controls
                    if (!_showShutter)
                      Positioned(
                        bottom: 32,
                        right: 24,
                        child: _buildCanvasControls(),
                      ),
                  ],
                ),
              ),
            ),

            // --- 2. Floating Mission Card (when sidebar is closed) ---
            if (!_isSidebarOpen && !_showShutter) _buildFloatingMissionCard(),

            // --- 3. Sidebar (Left, 30% Width, Scrollable) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen && !_showShutter ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Material(
                elevation: 16,
                color: const Color(0xFF1E293B),
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header space
                          Container(
                            padding: const EdgeInsets.only(
                              left: 20, // Space for menu icon
                              right: 20,
                              top: 70,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo[900]?.withOpacity(
                                          0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.factory,
                                        size: 28,
                                        color: Colors.indigo[400],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t('titleMain'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            t('titleSub'),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[400],
                                              letterSpacing: 1,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _playSound('click');
                                        setState(
                                          () => _lang = _lang == 'EN'
                                              ? 'HI'
                                              : 'EN',
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _lang,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                      onPressed: _resetLab,
                                      tooltip: t('restartLab'),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Scrollable Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('selectScenario'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        onTap: () => _playSound('click'),
                                        isExpanded: true,
                                        value: _currentScenario,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items: [1, 2]
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  (getScenarioData(
                                                            e,
                                                            _lang.toLowerCase(),
                                                          )['title']
                                                          as Map<
                                                            String,
                                                            String
                                                          >)[_lang
                                                          .toLowerCase()] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) _loadScenario(val);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // HUD
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.indigoAccent.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  t('input'),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  scenarioData['input']
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.indigo[400],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  t('output'),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  _flowState >= 8
                                                      ? ((scenarioData['input']
                                                                    as int) *
                                                                (scenarioData['mult']
                                                                    as int) ~/
                                                                (scenarioData['div']
                                                                    as int))
                                                            .toString()
                                                      : '--',
                                                  style: const TextStyle(
                                                    color: Colors.amber,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Divider(color: Colors.white24),
                                        const SizedBox(height: 12),
                                        Text(
                                          t('hudTask$_flowState'),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Steps Display
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.format_list_numbered,
                                        color: Colors.indigo[400],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('proceduralSteps'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(steps.length, (index) {
                                    int stepThreshold = _getThresholdForStep(
                                      index,
                                    );
                                    bool isDone = _flowState > stepThreshold;
                                    bool isActive =
                                        _flowState == stepThreshold ||
                                        (_flowState >
                                                _getThresholdForStep(
                                                  index - 1,
                                                ) &&
                                            _flowState <= stepThreshold);

                                    var textMap = steps[index];
                                    String text =
                                        textMap[_lang.toLowerCase()] ??
                                        textMap['en'];

                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.amber.withOpacity(0.2)
                                            : (isDone
                                                  ? Colors.white.withOpacity(
                                                      0.05,
                                                    )
                                                  : Colors.white.withOpacity(
                                                      0.02,
                                                    )),
                                        border: Border.all(
                                          color: isActive
                                              ? Colors.amber.withOpacity(0.5)
                                              : Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${t('step')} ${index + 1}",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isActive
                                                  ? Colors.amber
                                                  : (isDone
                                                        ? Colors.green
                                                        : Colors.grey),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            text,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isActive
                                                  ? Colors.white
                                                  : (isDone
                                                        ? Colors.grey
                                                        : Colors.grey[600]),
                                              decoration: isDone
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  const SizedBox(height: 16),

                                  // Action Button Area
                                  if (_getActionButtonLabel().isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: _executeAction,
                                      icon: Icon(
                                        _flowState == 9
                                            ? Icons.fact_check
                                            : Icons.touch_app,
                                        size: 20,
                                      ),
                                      label: Text(
                                        _getActionButtonLabel(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _flowState == 9
                                            ? Colors.green[600]
                                            : Colors.indigo[600],
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 8,
                                        shadowColor: Colors.indigo.withOpacity(
                                          0.5,
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              border: Border(
                                top: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Text(
                              t('footer'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 4. Menu Icon (Top Left, always fixed) ---
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.indigoAccent,
                  iconSize: 28,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _playSound('click');
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.indigo.withOpacity(0.8)),
                    ),
                  ),
                ),
              ),

            // --- Feedback Overlay ---
            if (_feedbackMessage != null && !_showShutter)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: MediaQuery.of(context).size.height * 0.2,
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _feedbackIsSuccess
                            ? Colors.green[700]
                            : Colors.red[700],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _feedbackIsSuccess
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _feedbackMessage!,
                              style: const TextStyle(
                                color: Colors.white,
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
              ),

            // --- 5. Success Final Popup ---
            if (_showFinalPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                        maxHeight: 600,
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                size: 80,
                                color: Colors.indigo[400],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                t('labCompleted'),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('congrats'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: _resetLab,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  t('restartLab'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo[600],
                                  minimumSize: const Size(double.infinity, 60),
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
              ),

            // --- 6. Shutter / Curtain Intro Screen ---
            if (_showShutter)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.factory,
                            size: 80,
                            color: Colors.amber[400],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('titleMain'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              t('titleSub'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            onPressed: () {
                              _playSound('entry');
                              setState(() {
                                _showShutter = false;
                              });
                              // Center the view accurately as soon as we enter
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _resetCanvasView(playSound: false);
                              });
                            },
                            icon: const Icon(
                              Icons.science,
                              color: Colors.black,
                              size: 28,
                            ),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[500],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: Colors.amber[500]!.withOpacity(0.5),
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

  int _getThresholdForStep(int index) {
    if (index == 0) return 0;
    if (index == 1) return 1;
    if (index == 2) return 3;
    if (index == 3) return 5;
    if (index == 4) return 7;
    if (index == 5) return 9;
    return -1;
  }

  Map<String, dynamic> getScenarioData(int id, String lang) {
    return _scenarios[id]!;
  }
}

// --- Custom Painter for Pseudo 3D Isometric View ---
class FactoryPainter extends CustomPainter {
  final double crateX;
  final double crateY;
  final int crateCount;
  final double recycleX;
  final double recycleY;
  final int recycleCount;
  final bool showRecycle;
  final int flowState;
  final String dupLabel;
  final String splitLabel;
  final double glowValue;

  // Vanishing Point details
  final double vpX = 0.0;
  final double vpY = -400.0;

  FactoryPainter({
    required this.crateX,
    required this.crateY,
    required this.crateCount,
    required this.recycleX,
    required this.recycleY,
    required this.recycleCount,
    required this.showRecycle,
    required this.flowState,
    required this.dupLabel,
    required this.splitLabel,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    // 1. Draw Environment (Grid and Plate)
    _drawEnvironment(canvas);

    // 2. Draw Conveyor Belt
    _drawConveyorBelt(canvas);

    // 3. Draw Duplicator Machine
    _drawDuplicator(canvas, -100, -20);

    // 4. Draw Splitter Machine
    _drawSplitter(canvas, 150, -20);

    // 5. Draw Recycle Chute
    _drawRecycleChute(canvas, 150, 100);

    // 6. Draw Drop Zone if needed
    if (flowState == 0) {
      _drawDropZone(canvas, -300, 0);
    }

    // 7. Draw Crates
    if (flowState != 4 && flowState != 8) {
      // Hide crates exactly during intense processing animations
      _drawCrateStack(canvas, crateX, crateY, crateCount, Colors.amber);
    }

    if (showRecycle) {
      _drawCrateStack(
        canvas,
        recycleX,
        recycleY,
        recycleCount,
        Colors.redAccent,
      );
    }
  }

  void _drawEnvironment(Canvas canvas) {
    // Base Plate (Ellipse to simulate 3D cylinder base)
    final platePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromCenter(
      center: const Offset(0, 50),
      width: 1000,
      height: 400,
    );
    canvas.drawOval(rect, platePaint);
    canvas.drawOval(rect, borderPaint);

    // Grid Lines on Plate
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 2;
    for (double x = -400; x <= 400; x += 100) {
      canvas.drawLine(Offset(x, -150), Offset(x, 250), gridPaint);
    }
  }

  void _drawConveyorBelt(Canvas canvas) {
    final beltPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final beltBorder = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rect = Rect.fromCenter(
      center: const Offset(0, 0),
      width: 800,
      height: 80,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      beltPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      beltBorder,
    );

    // Lines to simulate movement
    final linePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 4;
    for (double x = -380; x <= 380; x += 40) {
      canvas.drawLine(Offset(x, -35), Offset(x, 35), linePaint);
    }
  }

  void _drawDuplicator(Canvas canvas, double x, double y) {
    // Machine Base
    final baseRect = Rect.fromCenter(
      center: Offset(x, y + 20),
      width: 140,
      height: 100,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(16)),
      Paint()..color = const Color(0xFF334155),
    );

    // Core glass
    final coreRect = Rect.fromCenter(
      center: Offset(x, y - 60),
      width: 100,
      height: 120,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(coreRect, const Radius.circular(12)),
      Paint()..color = const Color(0xFF10B981).withOpacity(0.2),
    );

    // Glow effect if active
    if (flowState == 4 || flowState == 3) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(coreRect, const Radius.circular(12)),
        Paint()
          ..color = const Color(0xFF10B981).withOpacity(0.3 + glowValue * 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );

      // Moving rings
      double r1y = y - 60 + sin(glowValue * pi * 2) * 30;
      double r2y = y - 60 + cos(glowValue * pi * 2) * 30;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, r1y), width: 110, height: 20),
        Paint()
          ..color = const Color(0xFF34D399)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, r2y), width: 110, height: 20),
        Paint()
          ..color = const Color(0xFF34D399)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    }

    // Top Cap
    final topRect = Rect.fromCenter(
      center: Offset(x, y - 130),
      width: 120,
      height: 30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1E293B),
    );

    _drawLabel(canvas, dupLabel, x, y - 160, const Color(0xFF10B981));
  }

  void _drawSplitter(Canvas canvas, double x, double y) {
    // Machine Base
    final baseRect = Rect.fromCenter(
      center: Offset(x, y + 20),
      width: 140,
      height: 100,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(16)),
      Paint()..color = const Color(0xFF334155),
    );

    // Funnel Top
    final path = Path()
      ..moveTo(x - 50, y - 30)
      ..lineTo(x + 50, y - 30)
      ..lineTo(x + 80, y - 100)
      ..lineTo(x - 80, y - 100)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFF59E0B));

    // Glow if active
    if (flowState == 8 || flowState == 7) {
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFF59E0B).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
      // Red gate arm moving
      canvas.drawLine(
        Offset(x, y - 30),
        Offset(x + (sin(glowValue * pi * 4) * 40), y + 10),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawLine(
        Offset(x, y - 30),
        Offset(x, y + 10),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }

    _drawLabel(canvas, splitLabel, x, y - 130, const Color(0xFFF59E0B));
  }

  void _drawRecycleChute(Canvas canvas, double x, double y) {
    // Chute Base
    final path = Path()
      ..moveTo(x - 60, y)
      ..lineTo(x + 60, y)
      ..lineTo(x + 40, y + 80)
      ..lineTo(x - 40, y + 80)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFEF4444));

    // Hole
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 100, height: 30),
      Paint()..color = const Color(0xFF7F1D1D),
    );

    _drawLabel(canvas, "RECYCLE", x, y + 110, const Color(0xFFEF4444));
  }

  void _drawDropZone(Canvas canvas, double x, double y) {
    final rect = Rect.fromCenter(center: Offset(x, y), width: 100, height: 60);
    canvas.drawOval(
      rect,
      Paint()
        ..color = Colors.yellowAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Add text "Drop Here"
    _drawLabel(canvas, "Drop Here", x, y + 50, Colors.yellowAccent);
  }

  void _drawCrateStack(
    Canvas canvas,
    double cx,
    double cy,
    int count,
    Color color,
  ) {
    if (count == 0) return;

    int w = 4;
    int h = 3;
    if (count > 50) {
      w = 8;
      h = 5;
    }

    double size = 15;
    if (count > 100) size = 8;

    int drawn = 0;
    int layerSize = w * h;

    // Stack bottom to top, back to front to respect isometric sorting
    for (int i = 0; i < count; i++) {
      int zIdx = i ~/ layerSize;
      int remainder = i % layerSize;
      int xIdx = remainder % w;
      int yIdx = remainder ~/ w;

      double x =
          cx +
          (xIdx - w / 2) * (size + 2) +
          (yIdx * 4); // pseudo isometric offset
      double y = cy - (zIdx * (size + 2)) + (yIdx * 4);

      _drawSingleCrate(canvas, x, y, size, color);
      drawn++;
      if (drawn > 300) break; // Optimization limit
    }

    // Label with count above the stack
    _drawLabel(
      canvas,
      count.toString(),
      cx,
      cy - ((count ~/ layerSize) * (size + 2)) - 30,
      Colors.white,
    );
  }

  void _drawSingleCrate(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final darkPaint = Paint()..color = _darken(color, 0.2);
    final borderPaint = Paint()
      ..color = _darken(color, 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Front Face
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), paint);
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), borderPaint);

    // Cross marks
    canvas.drawLine(Offset(x, y), Offset(x + size, y + size), borderPaint);
    canvas.drawLine(Offset(x + size, y), Offset(x, y + size), borderPaint);

    // Top face (pseudo 3D)
    final pathTop = Path()
      ..moveTo(x, y)
      ..lineTo(x + size / 2, y - size / 2)
      ..lineTo(x + size + size / 2, y - size / 2)
      ..lineTo(x + size, y)
      ..close();
    canvas.drawPath(pathTop, Paint()..color = _lighten(color, 0.2));
    canvas.drawPath(pathTop, borderPaint);

    // Right face
    final pathRight = Path()
      ..moveTo(x + size, y)
      ..lineTo(x + size + size / 2, y - size / 2)
      ..lineTo(x + size + size / 2, y + size - size / 2)
      ..lineTo(x + size, y + size)
      ..close();
    canvas.drawPath(pathRight, darkPaint);
    canvas.drawPath(pathRight, borderPaint);
  }

  void _drawLabel(Canvas canvas, String text, double x, double y, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black45, // Pseudo background
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgRect = Rect.fromCenter(
      center: Offset(x, y),
      width: textPainter.width + 16,
      height: textPainter.height + 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1E293B).withOpacity(0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  Color _darken(Color c, [double amount = .1]) {
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color _lighten(Color c, [double amount = .1]) {
    final hsl = HSLColor.fromColor(c);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  @override
  bool shouldRepaint(FactoryPainter oldDelegate) => true;
}
