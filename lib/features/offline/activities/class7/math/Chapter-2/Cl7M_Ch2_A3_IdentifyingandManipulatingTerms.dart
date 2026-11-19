// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | The Term Factory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF020617,
        ), // Ultra-dark theme base
        fontFamily: 'Roboto',
      ),
      home: const IdentifyingandManipulatingTerms(),
    ),
  );
}

// Data models
class TermBlock {
  final String id;
  String text;
  double x;
  double y;
  int value;
  bool isGroup;
  bool isEvaluated;
  bool isOnScale;
  bool isDraggable;

  TermBlock({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    required this.value,
    this.isGroup = false,
    this.isEvaluated = false,
    this.isOnScale = false,
    this.isDraggable = false,
  });
}

class IdentifyingandManipulatingTerms extends StatefulWidget {
  const IdentifyingandManipulatingTerms({Key? key}) : super(key: key);

  @override
  State<IdentifyingandManipulatingTerms> createState() =>
      _IdentifyingandManipulatingTermsState();
}

class _IdentifyingandManipulatingTermsState
    extends State<IdentifyingandManipulatingTerms>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _isLabEntered = false; // Controls the shutter/curtain screen
  String _currentLang = 'EN';

  int _scenario = 1; // 1: 12 + 7, 2: 30 + (5 x 4)
  int _step =
      0; // 0: Init, 1: Separated, 2: Evaluated, 3: On Scale, 4: Validated

  // Canvas / Drag state
  bool _isDragging = false;
  List<TermBlock> _blocks = [];
  TermBlock? _plusSign;

  // Zoom Controller
  final TransformationController _transformationController =
      TransformationController();

  // Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Zones Rects (Logical Coordinates inside InteractiveViewer)
  final Rect _chamberRect = const Rect.fromLTWH(800, 200, 350, 400);
  final Rect _scaleRect = const Rect.fromLTWH(1300, 300, 450, 300);

  // Animations
  late AnimationController _factoryAnimController;
  late Animation<double> _factoryAnimation;

  @override
  void initState() {
    super.initState();
    // Enforce Landscape & Immersive Mode as requested
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _factoryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _factoryAnimation = CurvedAnimation(
      parent: _factoryAnimController,
      curve: Curves.easeInOut,
    );

    _factoryAnimController.addListener(() {
      _updateAnimateBlocks();
    });

    _factoryAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _step = 1;
          for (var b in _blocks) {
            b.isDraggable = true;
          }
          _plusSign = null; // Vaporize plus sign
        });
        _playSound('success');
      }
    });

    _loadScenario(1);
  }

  @override
  void dispose() {
    // Revert Orientation on Dispose as requested
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _factoryAnimController.dispose();
    _transformationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Get current zoom scale from InteractiveViewer transformation matrix
  double get _currentScale {
    return _transformationController.value.getMaxScaleOnAxis();
  }

  void _zoomIn() {
    _playSound('click');
    final Matrix4 matrix = _transformationController.value.clone();
    final double scale = matrix.getMaxScaleOnAxis();
    if (scale < 3.0) {
      matrix.scale(1.2);
      setState(() {
        _transformationController.value = matrix;
      });
    }
  }

  void _zoomOut() {
    _playSound('click');
    final Matrix4 matrix = _transformationController.value.clone();
    final double scale = matrix.getMaxScaleOnAxis();
    if (scale > 0.1) {
      matrix.scale(0.8);
      setState(() {
        _transformationController.value = matrix;
      });
    }
  }

  void _resetZoom() {
    _playSound('click');
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  Future<void> _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'click':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
      case 'success':
        url =
            'audio/class7/mixkit_2018.mp3';
        break;
      case 'drop':
        url =
            'audio/class7/mixkit_204.mp3';
        break;
      case 'error':
        url =
            'audio/class7/mixkit_2955.mp3';
        break;
      case 'start':
        url =
            'audio/class7/mixkit_2020.mp3';
        break;
      case 'enter':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
    }
    if (url.isNotEmpty) {
      try {
        await _audioPlayer.play(AssetSource(url));
      } catch (e) {
        debugPrint("Audio Error: $e");
      }
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber.shade800,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleLanguage() {
    _playSound('click');
    setState(() {
      if (_currentLang == 'EN') {
        _currentLang = 'HI';
      } else {
        _currentLang = 'EN';
      }
    });
    _showToast('Language toggled to: $_currentLang');
  }

  void _resetLab() {
    _playSound('click');
    setState(() {
      _isLabEntered = false; // Bring back the curtain screen
    });
    _loadScenario(_scenario);
    _showToast('Lab has been reset');
  }

  void _loadScenario(int scenarioId) {
    setState(() {
      _scenario = scenarioId;
      _step = 0;

      if (_scenario == 1) {
        _blocks = [
          TermBlock(id: 'b1', text: '12', x: 150, y: 400, value: 12),
          TermBlock(id: 'b2', text: '7', x: 350, y: 400, value: 7),
        ];
        _plusSign = TermBlock(id: 'p1', text: '+', x: 250, y: 400, value: 0);
      } else {
        _blocks = [
          TermBlock(id: 'b1', text: '30', x: 150, y: 400, value: 30),
          TermBlock(
            id: 'b2',
            text: '5 x 4',
            x: 380,
            y: 400,
            value: 20,
            isGroup: true,
          ),
        ];
        _plusSign = TermBlock(id: 'p1', text: '+', x: 250, y: 400, value: 0);
      }

      // Reset animation
      _factoryAnimController.reset();
      // Reset zoom
      _transformationController.value = Matrix4.identity();
    });
  }

  void _updateAnimateBlocks() {
    if (_blocks.length < 2) return; // Safety guard

    setState(() {
      double progress = _factoryAnimation.value;
      if (_scenario == 1) {
        _blocks[0].x = 150 + (300 * progress);
        _blocks[1].x = 350 + (300 * progress);
        if (_plusSign != null) {
          _plusSign!.x = 250 + (100 * progress);
        }
      } else {
        _blocks[0].x = 150 + (300 * progress);
        _blocks[1].x = 380 + (300 * progress);
        if (_plusSign != null) {
          _plusSign!.x = 250 + (100 * progress);
        }
      }
    });
  }

  void _startFactory() {
    _playSound('start');
    _factoryAnimController.forward();
  }

  void _handlePanStart(TermBlock block) {
    if (!block.isDraggable || _step < 1) return;
    setState(() {
      _isDragging = true;
    });
    _playSound('click');
  }

  void _handlePanUpdate(DragUpdateDetails details, TermBlock block) {
    if (!block.isDraggable || _step < 1) return;
    // Scale coordinates with current zoom so block drags exactly under hand/mouse
    double scale = _currentScale;
    if (scale == 0.0) scale = 1.0;
    block.x += details.delta.dx / scale;
    block.y += details.delta.dy / scale;
  }

  void _handlePanEnd(TermBlock block) {
    if (!block.isDraggable || _step < 1) return;
    setState(() {
      _isDragging = false;
    });

    final blockCenter = Offset(block.x + 50, block.y + 50);

    if (_step == 1) {
      if (_chamberRect.contains(blockCenter)) {
        _playSound('success');
        setState(() {
          block.isEvaluated = true;
          block.isDraggable = false;
          block.text = block.value.toString();
          // Position inside chamber
          int evaluatedCount = _blocks.where((b) => b.isEvaluated).length;
          block.x = 850 + (evaluatedCount * 120.0);
          block.y = 350;

          if (evaluatedCount == _blocks.length) {
            _step = 2; // All evaluated
            for (var b in _blocks) {
              b.isDraggable = true;
            }
          }
        });
      } else {
        _playSound('error');
        // Snap back to conveyer
        int idx = _blocks.indexOf(block);
        block.x = 450.0 + (idx * 200.0);
        block.y = 400.0;
      }
    } else if (_step == 2) {
      if (_scaleRect.contains(blockCenter)) {
        _playSound('drop');
        setState(() {
          block.isOnScale = true;
          block.isDraggable = false;

          int scaleCount = _blocks.where((b) => b.isOnScale).length;
          block.x = 1350 + (scaleCount * 120.0);
          block.y = 380;

          if (scaleCount == _blocks.length) {
            _step = 3; // All on scale
            _playSound('success');
          }
        });
      } else {
        _playSound('error');
        // Snap back to chamber
        int idx = _blocks.indexOf(block);
        block.x = 850 + ((idx + 1) * 120.0);
        block.y = 350;
      }
    }
  }

  void _validateModel() {
    _playSound('success');
    setState(() {
      _step = 4;
    });
    _showSuccessPopup();
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.amber, width: 1.5),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: Colors.amber,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "SUMMARY",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _scenario == 1
                        ? "An expression is separated into terms by the '+' sign. Each term is evaluated individually, and then the results are added."
                        : "Parts of an expression connected by multiplication form a single term. They must be evaluated before being added to other terms.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _scenario == 1 ? "12 + 7" : "30 + (5 x 4)",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (_scenario == 2) const SizedBox(height: 8),
                        if (_scenario == 2)
                          const Text(
                            "30 + 20",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          "= ${_scenario == 1 ? 19 : 50}",
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadScenario(_scenario == 1 ? 2 : 1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Next Scenario",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getObjectiveText() {
    if (_scenario == 1) {
      return _currentLang == 'HI' ? "यह समझने के लिए कि पद एक व्यंजक के भाग हैं जो '+' चिह्न से अलग होते हैं।" : "To understand that terms are parts of an expression separated by a '+' sign.";
    } else {
      return _currentLang == 'HI' ? "यह समझने के लिए कि एक व्यंजक के भीतर गुणा एक एकल, अविभाज्य पद बनाता है।" : "To understand that multiplication within an expression forms a single, inseparable term.";
    }
  }

  String _getInstructionText() {
    switch (_step) {
      case 0:
        return _currentLang == 'HI' ? "'फैक्ट्री शुरू करें' बटन पर क्लिक करें।" : "CLICK the 'Start Factory' button.";
      case 1:
        return _currentLang == 'HI' ? "प्रत्येक ब्लॉक को मूल्यांकन कक्ष में खींचें।" : "DRAG each block into the Evaluation Chamber.";
      case 2:
        return _currentLang == 'HI' ? "ब्लॉकों को समिंग स्केल प्लेटफ़ॉर्म पर खींचें।" : "DRAG the blocks onto the Summing Scale platform.";
      case 3:
        return _currentLang == 'HI' ? "नीचे 'मॉडल मान्य करें' पर क्लिक करें।" : "CLICK 'Validate Model' below.";
      case 4:
        return _currentLang == 'HI' ? "मिशन पूरा हुआ!" : "Mission Accomplished!";
      default:
        return "";
    }
  }

  String _getTheoryText() {
    if (_scenario == 1) {
      switch (_step) {
        case 0:
          return _currentLang == 'HI' ? "'+' चिह्न महान विभाजक है। यह व्यंजक को विभिन्न पदों में विभाजित करता है।" : "The '+' sign is the great separator. It divides an expression into different terms. Let's observe how the factory handles a simple addition.";
        case 1:
          return _currentLang == 'HI' ? "फाटक एक विभाजक के रूप में कार्य करता है। व्यंजक विभाजित हो जाता है और '+' चिह्न वाष्पीकृत हो जाता है! मूल्यांकन करने के लिए, हम उन्हें कक्ष में खींचते हैं।" : "The gate acts as a separator. The expression is split and the '+' sign is vaporized! To evaluate them, we drag them into the Evaluation Chamber.";
        case 2:
          return _currentLang == 'HI' ? "ब्लॉकों का उनके अंतिम मूल्यों में मूल्यांकन किया गया है। अब हम कुल योग ज्ञात करने के लिए मानों को जोड़ते हैं।" : "The blocks have been evaluated into their final values. Now we combine the values to find the total sum.";
        case 3:
          return _currentLang == 'HI' ? "पद समिंग स्केल पर हैं। अब, आइए अपने अंतिम व्यंजक को मान्य करें।" : "The terms are on the Summing Scale. Now, let's validate our final expression.";
        case 4:
          return _currentLang == 'HI' ? "परिदृश्य पूरा हुआ! 12 + 7 = 19" : "Scenario Complete! 12 + 7 = 19";
        default:
          return "";
      }
    } else {
      switch (_step) {
        case 0:
          return _currentLang == 'HI' ? "गुणा या भाग होने वाली चीजें एक साथ जुड़कर एक पद बनाती हैं। कोष्ठक को ध्यान से देखें।" : "Things being multiplied or divided stick together and form a single term. Watch the braces closely.";
        case 1:
          return _currentLang == 'HI' ? "'+' फाटक ने पदों को अलग कर दिया, लेकिन '5 × 4' एक साथ रहे! यह एक पद है। आइए मूल्यांकन करें।" : "The '+' gate separated the terms, but '5 × 4' stayed together! It's one single term. Let's evaluate them.";
        case 2:
          return _currentLang == 'HI' ? "अब जब हमारे पास दोनों पदों (30 और 20) के मान हैं, तो हम उन्हें जोड़ सकते हैं।" : "Now that we have the values of both terms (30 and 20), we can add them.";
        case 3:
          return _currentLang == 'HI' ? "पद समिंग स्केल पर हैं। आइए अंतिम परिणाम को मान्य करें।" : "The terms are on the Summing Scale. Let's validate the final result.";
        case 4:
          return _currentLang == 'HI' ? "परिदृश्य पूरा हुआ! 30 + (5 x 4) = 50" : "Scenario Complete! 30 + (5 x 4) = 50";
        default:
          return "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.3;
    if (sidebarWidth < 300) sidebarWidth = 300;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main Canvas Area (Dynamically adjusting layer)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: Stack(
                children: [
                  // --- FIXED INFINITE BACKGROUND ---
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF020617), Color(0xFF0B0F19)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // --- INFINITE DYNAMIC GRID RENDERING ---
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _transformationController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: InfiniteGridPainter(
                            transform: _transformationController.value,
                          ),
                        );
                      },
                    ),
                  ),

                  // --- INTERACTIVE FOREGROUND LAYER ---
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      panEnabled: !_isDragging,
                      scaleEnabled: !_isDragging,
                      minScale: 0.1, // Allow zooming out deeply into infinity
                      maxScale: 3.0,
                      // Allow infinite panning in all directions
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      constrained: false,
                      child: SizedBox(
                        // Maintains local coordinates sizing for content placement
                        width: 2000,
                        height: 1200,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [_buildEnvironment(), _buildBlocks()],
                        ),
                      ),
                    ),
                  ),

                  // Integrated floating zoom widget
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildZoomControl(Icons.add, _zoomIn, "Zoom In"),
                        const SizedBox(height: 10),
                        _buildZoomControl(Icons.remove, _zoomOut, "Zoom Out"),
                        const SizedBox(height: 10),
                        _buildZoomControl(
                          Icons.center_focus_strong,
                          _resetZoom,
                          "Reset",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Mission Card (when Sidebar is closed)
            if (!_isSidebarOpen)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Action Required",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getInstructionText(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Sliding Sidebar (Middle layer)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // Top Left Controls (Menu Toggle - Top layer over Sidebar)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.amberAccent,
                iconSize: 28,
                onPressed: () {
                  _playSound('click');
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.amber.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // Shutter (Curtain) Screen Overlay (Absolute Top Layer)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _isLabEntered ? -screenHeight : 0,
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF020617), Color(0xFF0B0F19)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.precision_manufacturing,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "The Term Factory",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Class 7 • ARITHMETIC EXPRESSIONS",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white54,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () {
                          _playSound('enter');
                          setState(() {
                            _isLabEntered = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: Colors.amber.withOpacity(0.4),
                        ),
                        child: const Text(
                          "Enter Lab",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
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

  Widget _buildZoomControl(
    IconData icon,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.85),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.amberAccent),
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 24,
      ),
    );
  }

  Widget _buildEnvironment() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Conveyor Belt
        Positioned(
          left: 100,
          top: 480,
          width: 400,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155), width: 2),
            ),
            child: const Center(
              child: Text(
                "CONVEYOR BELT",
                style: TextStyle(
                  color: Colors.white24,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // 2. Gate (Separator)
        Positioned(
          left: 550,
          top: 320,
          width: 80,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.1),
              border: Border.all(color: Colors.cyan, width: 4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  "'+' SEPARATOR GATE",
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // 3. Evaluation Chamber
        Positioned(
          left: _chamberRect.left,
          top: _chamberRect.top,
          width: _chamberRect.width,
          height: _chamberRect.height,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F19).withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.amber.withOpacity(0.7),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "EVALUATION CHAMBER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Icon(
                      Icons.science,
                      size: 100,
                      color: Colors.white10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Summing Scale
        Positioned(
          left: _scaleRect.left,
          top: _scaleRect.top,
          width: _scaleRect.width,
          height: _scaleRect.height,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F19),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade800, width: 3),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "SUMMING SCALE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Scale Platform
                      Positioned(
                        bottom: 40,
                        left: 40,
                        right: 40,
                        height: 20,
                        child: Container(color: Colors.grey.shade800),
                      ),
                      // Scale Display Screen
                      Positioned(
                        bottom: 10,
                        left: 100,
                        right: 100,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade900,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getScaleDisplay(),
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 28,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
      ],
    );
  }

  String _getScaleDisplay() {
    if (_step < 2) return "0";
    if (_step == 2) {
      int c = _blocks.where((b) => b.isOnScale).length;
      if (c == 0) return "0";
      if (c == 1 && _blocks.isNotEmpty)
        return _blocks
            .firstWhere((b) => b.isOnScale, orElse: () => _blocks[0])
            .value
            .toString();
    }
    if (_step >= 3 && _blocks.length >= 2) {
      int sum = _blocks.fold(0, (prev, element) => prev + element.value);
      return "${_blocks[0].value} + ${_blocks[1].value} = $sum";
    }
    return "0";
  }

  Widget _buildBlocks() {
    List<Widget> blockWidgets = [];

    // Vaporizing plus sign
    if (_plusSign != null) {
      blockWidgets.add(
        Positioned(
          left: _plusSign!.x,
          top: _plusSign!.y,
          child: Opacity(
            opacity: 1.0 - _factoryAnimation.value,
            child: _buildSingleBlock(_plusSign!),
          ),
        ),
      );
    }

    // Interactive blocks
    for (var block in _blocks) {
      blockWidgets.add(
        StatefulBuilder(
          builder: (context, setLocalState) {
            return Positioned(
              left: block.x,
              top: block.y,
              child: GestureDetector(
                onPanStart: (d) => _handlePanStart(block),
                onPanUpdate: (d) {
                  _handlePanUpdate(d, block);
                  setLocalState(() {});
                },
                onPanEnd: (d) => _handlePanEnd(block),
                child: _buildSingleBlock(block),
              ),
            );
          },
        ),
      );
    }
    return Stack(children: blockWidgets);
  }

  Widget _buildSingleBlock(TermBlock block) {
    bool isOp = block.text == '+';
    Color bgColor = isOp
        ? Colors.transparent
        : (block.isEvaluated ? Colors.green.shade800 : Colors.white);
    Color textColor = isOp
        ? Colors.amber
        : (block.isEvaluated ? Colors.white : Colors.black87);

    Widget content = Container(
      width: block.isGroup ? 140 : 80,
      height: 80,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOp ? Colors.transparent : Colors.grey.shade400,
          width: 2,
        ),
        boxShadow: isOp
            ? []
            : const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Center(
        child: Text(
          block.text,
          style: TextStyle(
            color: textColor,
            fontSize: isOp ? 60 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (block.isGroup && !block.isEvaluated) {
      // Add braces visual for group
      content = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            bottom: -20,
            child: Container(
              width: 120,
              height: 20,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.amber, width: 4),
                  left: BorderSide(color: Colors.amber, width: 4),
                  right: BorderSide(color: Colors.amber, width: 4),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return content;
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate surface
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Spacer for Menu Icon
                    const SizedBox(height: 60),

                    // Header Title & Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.5),
                              ),
                            ),
                            child: const Icon(
                              Icons.precision_manufacturing,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "The Term Factory",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Class 7 • ARITHMETIC EXPRESSIONS",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Language & Reset Controls inside Sidebar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _toggleLanguage,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.amber.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.language,
                                    color: Colors.amberAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _currentLang,
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: Colors.amberAccent,
                            iconSize: 20,
                            onPressed: _resetLab,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.3),
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.amber.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(
                      color: Colors.white10,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 16),

                    // Content Area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Scenario Selector
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF020617),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _scenario,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0F172A),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.amber,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text(
                                      "Scenario 1: The Basic Separator",
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text(
                                      "Scenario 2: The Unbreakable Bond",
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    _playSound('click');
                                    _loadScenario(val);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Mission Objective
                          Row(
                            children: const [
                              Icon(
                                Icons.track_changes,
                                color: Colors.amber,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "MISSION OBJECTIVE",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getObjectiveText(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 20),

                          // Procedural Theory (Steps)
                          Row(
                            children: const [
                              Icon(
                                Icons.format_list_numbered,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "PROCEDURAL THEORY",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              border: const Border(
                                left: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 3,
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: Text(
                              _getTheoryText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Current Math Expression Display
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF020617),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Center(
                              child: Text(
                                _scenario == 1 ? "12 + 7" : "30 + ( 5 x 4 )",
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Action Buttons Area
                          if (_step == 0)
                            ElevatedButton.icon(
                              onPressed: _startFactory,
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.black87,
                              ),
                              label: const Text(
                                "START FACTORY",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                                shadowColor: Colors.greenAccent.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),

                          if (_step == 3)
                            ElevatedButton.icon(
                              onPressed: _validateModel,
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.black87,
                              ),
                              label: const Text(
                                "VALIDATE MODEL",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                                shadowColor: Colors.amber.withOpacity(0.5),
                              ),
                            ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),

                    const Spacer(), // Pushes the footer to the absolute bottom if content is short
                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF020617),
                        border: Border(top: BorderSide(color: Colors.white10)),
                      ),
                      child: const Text(
                        "© ZeroScienceLab - Fall in love with math and Science",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Painter for Infinite Canvas Grid Background
// Dynamically inverses the Transformation matrix to strictly draw within visible viewport limits.
class InfiniteGridPainter extends CustomPainter {
  final Matrix4 transform;

  InfiniteGridPainter({required this.transform});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.4)
      ..strokeWidth = 1.0;

    final accentPaint = Paint()
      ..color = const Color(0xFF0EA5E9).withOpacity(0.15)
      ..strokeWidth = 1.5;

    double step = 50.0;

    // Invert the matrix to find the exact visible bounds in the virtual coordinate space
    Matrix4 inverse = Matrix4.tryInvert(transform) ?? Matrix4.identity();
    Rect visibleRect = MatrixUtils.transformRect(
      inverse,
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.save();
    // Apply transformation directly to the canvas so lines render perfectly at scale and offset
    canvas.transform(transform.storage);

    // Expand bounds slightly to ensure lines reach the very edges without popping
    double startX = (visibleRect.left / step).floor() * step - step;
    double endX = visibleRect.right + step;

    double startY = (visibleRect.top / step).floor() * step - step;
    double endY = visibleRect.bottom + step;

    // Draw vertical lines covering ONLY the visible area + buffer
    for (double x = startX; x <= endX; x += step) {
      bool isAccent = (x.round() % 250) == 0;
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        isAccent ? accentPaint : paint,
      );
    }

    // Draw horizontal lines covering ONLY the visible area + buffer
    for (double y = startY; y <= endY; y += step) {
      bool isAccent = (y.round() % 250) == 0;
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        isAccent ? accentPaint : paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InfiniteGridPainter oldDelegate) {
    // Only repaint if the transformation (zoom/pan) has changed
    return oldDelegate.transform != transform;
  }
}
