// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Fraction Factory Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.amberAccent,
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Roboto',
      ),
      home: const RepresentingandOrderingNumbers(),
    ),
  );
}

// --- Data Models ---
enum BlockType { unit, tenth, hundredth }

class PlacedBlock {
  final BlockType type;
  Offset offset;
  PlacedBlock({required this.type, required this.offset});
}

class StepTarget {
  final int u;
  final int t;
  final int h;
  const StepTarget({required this.u, required this.t, required this.h});
}

class LabStep {
  final int stepId;
  final String instruction;
  final String blueprintMath;
  final StepTarget target;
  final String type;

  LabStep({
    required this.stepId,
    required this.instruction,
    required this.blueprintMath,
    required this.target,
    required this.type,
  });
}

class Scenario {
  final int id;
  final String title;
  final String objective;
  final List<LabStep> steps;

  Scenario({
    required this.id,
    required this.title,
    required this.objective,
    required this.steps,
  });
}

// --- Translations ---
const Map<String, Map<String, String>> _localizedStrings = {
  'en': {
    'title_main':
        'The Fraction Factory: Building and Comparing with Tenths and Hundredths',
    'subtitle': 'CLASS 7 • A PEEK BEYOND THE POINT',
    'enter_lab': 'ENTER LAB',
    'app_title': 'The Fraction Factory',
    'select_scenario': 'SELECT SCENARIO',
    'blueprint': 'BLUEPRINT',
    'units': 'Units',
    'tenths': 'Tenths',
    'hund': 'Hund.',
    'total_value': 'Total Value: ',
    'step': 'STEP',
    'clear': 'Clear',
    'build_to_continue': 'Build to Continue',
    'next_step': 'Next Step',
    'merge_blocks': 'Merge Blocks',
    'validate': 'Validate',
    'mission_objective': 'MISSION OBJECTIVE',
    'scenario_complete': 'SCENARIO COMPLETE!',
    'success_desc':
        'Great job! You successfully built and validated the fractional models in this scenario. You can reset or select another scenario.',
    'close': 'Close',
    'next_scenario': 'Next Scenario',
    'reset': 'Reset',
    's1_title': 'The Blueprint Builder',
    's1_obj':
        'Construct numbers with fractional parts by physically combining whole units and tenth parts. Understand that 10 tenths make one whole.',
    's1_st1':
        "DRAG 1 blue 'Unit' block and 3 green 'Tenth' slices onto the platform.",
    's1_st2':
        "DRAG 10 green 'Tenth' slices onto the platform. Merge them into a whole!",
    's1_st3': 'Mixed numbers combine whole units and fractional parts.',
    's2_title': 'Adding Hundredths',
    's2_obj':
        'To construct a number using units, tenths, and hundredths, and to understand the relationship between tenths and hundredths.',
    's2_st1': "DRAG 1 'Unit', 2 'Tenths', and 4 'Hundredths' to the platform.",
    's2_st2':
        "DRAG 10 yellow 'Hundredth' cubes onto the platform to merge into a tenth.",
    's2_st3': 'This introduces the hundredth part visually.',
  },
  'hi': {
    'title_main': 'भिन्न फैक्टरी: दसवें और सौवें हिस्से बनाना और तुलना करना',
    'subtitle': 'कक्षा 7 • दशमलव के पार एक नज़र',
    'enter_lab': 'लैब में प्रवेश करें',
    'app_title': 'भिन्न फैक्टरी',
    'select_scenario': 'परिदृश्य चुनें',
    'blueprint': 'ब्लूप्रिंट',
    'units': 'इकाई',
    'tenths': 'दसवां',
    'hund': 'सौवां',
    'total_value': 'कुल मान: ',
    'step': 'चरण',
    'clear': 'साफ़ करें',
    'build_to_continue': 'आगे बढ़ने के लिए बनाएं',
    'next_step': 'अगला चरण',
    'merge_blocks': 'ब्लॉक मिलाएं',
    'validate': 'सत्यापित करें',
    'mission_objective': 'मिशन का उद्देश्य',
    'scenario_complete': 'परिदृश्य पूर्ण!',
    'success_desc':
        'बहुत बढ़िया! आपने इस परिदृश्य में भिन्नात्मक मॉडल को सफलतापूर्वक बनाया और सत्यापित किया है। आप रीसेट कर सकते हैं या कोई अन्य परिदृश्य चुन सकते हैं।',
    'close': 'बंद करें',
    'next_scenario': 'अगला परिदृश्य',
    'reset': 'रीसेट',
    's1_title': 'ब्लूप्रिंट बिल्डर',
    's1_obj':
        'पूरी इकाइयों और दसवें हिस्सों को भौतिक रूप से जोड़कर भिन्नात्मक भागों वाले नंबर बनाएं। समझें कि 10 दसवें हिस्से एक पूरी इकाई बनाते हैं।',
    's1_st1': "1 नीले 'इकाई' ब्लॉक और 3 हरे 'दसवें' स्लाइस को मंच पर खींचें।",
    's1_st2':
        "10 हरे 'दसवें' स्लाइस को मंच पर खींचें। उन्हें एक पूरी इकाई में मिलाएं!",
    's1_st3':
        'मिश्रित संख्याएँ पूरी इकाइयों और भिन्नात्मक भागों को जोड़ती हैं।',
    's2_title': 'सौवें हिस्से जोड़ना',
    's2_obj':
        'इकाइयों, दसवें और सौवें हिस्से का उपयोग करके एक संख्या बनाना, और दसवें और सौवें के बीच के संबंध को समझना।',
    's2_st1': "1 'इकाई', 2 'दसवें', और 4 'सौवें' हिस्से को मंच पर खींचें।",
    's2_st2':
        "10 पीले 'सौवें' क्यूब्स को एक दसवें हिस्से में मिलाने के लिए मंच पर खींचें।",
    's2_st3': 'यह सौवें हिस्से को दृश्य रूप से पेश करता है।',
  },
};

// --- Main State ---
class RepresentingandOrderingNumbers extends StatefulWidget {
  const RepresentingandOrderingNumbers({super.key});

  @override
  State<RepresentingandOrderingNumbers> createState() =>
      _RepresentingandOrderingNumbersState();
}

class _RepresentingandOrderingNumbersState
    extends State<RepresentingandOrderingNumbers> {
  bool _isSidebarOpen = true;
  bool _showSuccessPopup = false;
  bool _hasEnteredLab = false;
  String _language = 'en';

  // Audio
  late AudioPlayer _audioPlayer;

  // Lab State
  int _currentScenarioIndex = 0;
  int _currentStepIndex = 0;
  final List<PlacedBlock> _placedBlocks = [];

  // Canvas Viewport Constraints
  final double canvasWidth = 2400; // Increased for better spacing
  final double canvasHeight = 1500;
  final TransformationController _transformationController =
      TransformationController();

  // Dynamic Scenarios based on language
  List<Scenario> get scenarios => [
    Scenario(
      id: 1,
      title: _t('s1_title'),
      objective: _t('s1_obj'),
      steps: [
        LabStep(
          stepId: 1,
          instruction: _t('s1_st1'),
          blueprintMath: "1 3/10",
          target: const StepTarget(u: 1, t: 3, h: 0),
          type: "build",
        ),
        LabStep(
          stepId: 2,
          instruction: _t('s1_st2'),
          blueprintMath: "10/10",
          target: const StepTarget(u: 0, t: 10, h: 0),
          type: "merge_tenths",
        ),
        LabStep(
          stepId: 3,
          instruction: _t('s1_st3'),
          blueprintMath: "0",
          target: const StepTarget(u: 0, t: 0, h: 0),
          type: "validate",
        ),
      ],
    ),
    Scenario(
      id: 2,
      title: _t('s2_title'),
      objective: _t('s2_obj'),
      steps: [
        LabStep(
          stepId: 1,
          instruction: _t('s2_st1'),
          blueprintMath: "1 2/10 4/100",
          target: const StepTarget(u: 1, t: 2, h: 4),
          type: "build",
        ),
        LabStep(
          stepId: 2,
          instruction: _t('s2_st2'),
          blueprintMath: "10/100",
          target: const StepTarget(u: 0, t: 0, h: 10),
          type: "merge_hundredths",
        ),
        LabStep(
          stepId: 3,
          instruction: _t('s2_st3'),
          blueprintMath: "0",
          target: const StepTarget(u: 0, t: 0, h: 0),
          type: "validate",
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _audioPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerCanvas();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  String _t(String key) => _localizedStrings[_language]?[key] ?? key;

  void _centerCanvas() {
    final size = MediaQuery.of(context).size;
    final offsetX = (canvasWidth - size.width) / 2;
    final offsetY = (canvasHeight - size.height) / 2 + 100;
    _transformationController.value =
        Matrix4.identity()..translate(-offsetX, -offsetY);
  }

  void _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'pop':
        url = 'audio/class7/mixkit_212.mp3';
        break;
      case 'drop':
        url = 'audio/class7/mixkit_204.mp3';
        break;
      case 'magic':
        url =
            'audio/class7/mixkit_2013.mp3';
        break;
      case 'success':
        url =
            'audio/class7/mixkit_2013.mp3';
        break;
      case 'error':
        url =
            'audio/class7/mixkit_2953.mp3';
        break;
    }
    if (url.isNotEmpty) await _audioPlayer.play(AssetSource(url));
  }

  void _changeLanguage() {
    setState(() => _language = _language == 'en' ? 'hi' : 'en');
    _playSound('pop');
  }

  void _resetLab() {
    _playSound('pop');
    setState(() {
      _hasEnteredLab = false;
      _isSidebarOpen = true;
      _showSuccessPopup = false;
      _currentScenarioIndex = 0;
      _currentStepIndex = 0;
      _placedBlocks.clear();
      _language = 'en';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _centerCanvas();
    });
  }

  int get countU => _placedBlocks.where((b) => b.type == BlockType.unit).length;
  int get countT =>
      _placedBlocks.where((b) => b.type == BlockType.tenth).length;
  int get countH =>
      _placedBlocks.where((b) => b.type == BlockType.hundredth).length;
  double get totalValue => countU + (countT * 0.1) + (countH * 0.01);

  bool get _isStepComplete {
    final currentStep =
        scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    if (currentStep.type == 'validate') return true;
    return countU == currentStep.target.u &&
        countT == currentStep.target.t &&
        countH == currentStep.target.h;
  }

  void _handleBlockDrop(BlockType type, Offset position) {
    // Check if dropped roughly within the Build Platform boundaries
    bool overPlatform =
        position.dx > 800 &&
        position.dx < 1800 &&
        position.dy > 400 &&
        position.dy < 1200;

    if (overPlatform) {
      setState(() {
        _placedBlocks.add(
          PlacedBlock(type: type, offset: Offset.zero),
        ); // Position dynamically calculated during build
      });
      if (_isStepComplete) {
        _playSound('success');
      } else {
        _playSound('drop');
      }
    } else {
      _playSound('error'); // Bounces back/rejects if dropped outside
    }
  }

  void _clearPlatform() {
    setState(() => _placedBlocks.clear());
    _playSound('pop');
  }

  void _mergeBlocks() {
    final currentStep =
        scenarios[_currentScenarioIndex].steps[_currentStepIndex];
    _playSound('magic');

    setState(() {
      if (currentStep.type == 'merge_tenths') {
        _placedBlocks.removeWhere((b) => b.type == BlockType.tenth);
        _placedBlocks.add(
          PlacedBlock(type: BlockType.unit, offset: Offset.zero),
        );
      } else if (currentStep.type == 'merge_hundredths') {
        _placedBlocks.removeWhere((b) => b.type == BlockType.hundredth);
        _placedBlocks.add(
          PlacedBlock(type: BlockType.tenth, offset: Offset.zero),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 500), _nextStep);
  }

  void _nextStep() {
    if (_currentStepIndex < scenarios[_currentScenarioIndex].steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _placedBlocks.clear();
      });
      _playSound('pop');
    } else {
      setState(() => _showSuccessPopup = true);
      _playSound('success');
    }
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenarioIndex = index;
      _currentStepIndex = 0;
      _placedBlocks.clear();
      _showSuccessPopup = false;
    });
    _playSound('pop');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.35;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: _buildInteractiveCanvas()),
            if (!_isSidebarOpen)
              Positioned(top: 64, left: 20, child: _buildFloatingMissionCard()),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth),
            ),

            Positioned(top: 16, left: 16, child: _buildMenuToggleBtn()),

            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(child: _buildSuccessPopup()),
                ),
              ),

            if (!_hasEnteredLab) Positioned.fill(child: _buildCurtainScreen()),
          ],
        ),
      ),
    );
  }

  // ==================== 2.5D ISOMETRIC CANVAS & MATH ====================

  // Mathematical helper to locate a point on the top face of an Isometric base block
  Offset getIsoTopSurfaceOffset(
    double baseLeft,
    double baseTop,
    double baseW,
    double baseD,
    double baseH,
    double dw,
    double dd,
  ) {
    double baseTotalHeight = (baseW + baseD) * 0.5 + baseH;
    double originX = baseLeft + baseW * 0.8660254038;
    double originY = baseTop + baseTotalHeight - baseH;
    return Offset(
      originX - dw * 0.8660254038 + dd * 0.8660254038,
      originY - dw * 0.5 - dd * 0.5,
    );
  }

  // Mathematical helper to calculate where a block needs to be Positioned so its anchor matches
  Offset getIsoBlockPositionToAnchorAt(
    Offset anchorPoint,
    double blockW,
    double blockD,
    double blockH,
  ) {
    double blockTotalHeight = (blockW + blockD) * 0.5 + blockH;
    return Offset(
      anchorPoint.dx - blockW * 0.8660254038,
      anchorPoint.dy - blockTotalHeight,
    );
  }

  Widget _buildInteractiveCanvas() {
    // 3D Setup Constants (scaled up massively for better visual clarity)
    final cbLeft = 190.0; // Conveyor Belt X
    final bpLeft = 1000.0; // Build Platform X
    final topY = 650.0; // Base Y for both
    final baseW = 600.0; // Width of platforms
    final baseD = 250.0; // Depth of platforms
    final baseH = 40.0; // Height of platforms
    final depthCenter = 70.0; // Center along depth axis

    // Centers for the slots on the W axis
    final unitSlotW = 400.0;
    final tenthSlotW = 220.0;
    final hundSlotW = 80.0;

    // Placed Object Generation (With accurate mathematical stacking)
    List<Widget> placedWidgets = [];
    int uCount = 0, tCount = 0, hCount = 0;

    for (var b in _placedBlocks) {
      if (b.type == BlockType.unit) {
        Offset anchor = getIsoTopSurfaceOffset(
          bpLeft,
          topY,
          baseW,
          baseD,
          baseH,
          unitSlotW,
          depthCenter,
        );
        anchor = Offset(
          anchor.dx,
          anchor.dy - uCount * 120,
        ); // Stack vertically
        Offset pos = getIsoBlockPositionToAnchorAt(anchor, 120, 120, 120);
        placedWidgets.add(
          Positioned(
            left: pos.dx,
            top: pos.dy,
            child: _getBlockWidget(BlockType.unit),
          ),
        );
        uCount++;
      } else if (b.type == BlockType.tenth) {
        Offset anchor = getIsoTopSurfaceOffset(
          bpLeft,
          topY,
          baseW,
          baseD,
          baseH,
          tenthSlotW,
          depthCenter,
        );
        anchor = Offset(
          anchor.dx,
          anchor.dy - tCount * 12,
        ); // Stack vertically (flats)
        Offset pos = getIsoBlockPositionToAnchorAt(anchor, 120, 120, 12);
        placedWidgets.add(
          Positioned(
            left: pos.dx,
            top: pos.dy,
            child: _getBlockWidget(BlockType.tenth),
          ),
        );
        tCount++;
      } else if (b.type == BlockType.hundredth) {
        // Hundredths are stacked horizontally next to each other to visually form a Tenth square!
        double wOffset = 40 + (hCount % 10) * 12;
        double hOff = (hCount ~/ 10) * 12;
        Offset anchor = getIsoTopSurfaceOffset(
          bpLeft,
          topY,
          baseW,
          baseD,
          baseH,
          wOffset,
          depthCenter,
        );
        anchor = Offset(anchor.dx, anchor.dy - hOff);
        Offset pos = getIsoBlockPositionToAnchorAt(anchor, 12, 120, 12);
        placedWidgets.add(
          Positioned(
            left: pos.dx,
            top: pos.dy,
            child: _getBlockWidget(BlockType.hundredth),
          ),
        );
        hCount++;
      }
    }

    return Container(
      color: const Color(0xFF6F5245), // Base floor color
      child: CustomPaint(
        painter: IsoFloorGridPainter(), // Brown grid overlay
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.2,
          maxScale: 3.0,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: DragTarget<BlockType>(
              onAcceptWithDetails: (details) {
                final renderBox = context.findRenderObject() as RenderBox;
                final localOffset = renderBox.globalToLocal(details.offset);
                final sceneOffset = _transformationController.toScene(
                  localOffset,
                );
                _handleBlockDrop(details.data, sceneOffset);
              },
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Conveyor Belt Base
                    Positioned(
                      left: cbLeft,
                      top: topY,
                      child: IsoBlock(
                        w: baseW,
                        d: baseD,
                        h: baseH,
                        color: const Color(0xFF3E4D5E),
                      ),
                    ),

                    // 2. Build Platform Base
                    Positioned(
                      left: bpLeft,
                      top: topY,
                      child: IsoBlock(
                        w: baseW,
                        d: baseD,
                        h: baseH,
                        color:
                            candidateData.isNotEmpty
                                ? const Color(0xFF334B6B)
                                : const Color(0xFF26364A),
                        drawSlots: true,
                      ),
                    ),

                    // Conveyor Spawners (Draggable blocks)
                    _buildSpawner(
                      BlockType.unit,
                      cbLeft,
                      topY,
                      unitSlotW,
                      depthCenter,
                    ),
                    _buildSpawner(
                      BlockType.tenth,
                      cbLeft,
                      topY,
                      tenthSlotW,
                      depthCenter,
                    ),
                    _buildSpawner(
                      BlockType.hundredth,
                      cbLeft,
                      topY,
                      hundSlotW,
                      depthCenter,
                    ),

                    // Render dropped blocks in appropriate slots
                    ...placedWidgets,

                    // 4. Floating 2.5D Labels
                    Positioned(
                      left: 310,
                      top: 780,
                      child: _buildIsoLabel("UNIT"),
                    ),
                    Positioned(
                      left: 450,
                      top: 880,
                      child: _buildIsoLabel("TENTH"),
                    ),
                    Positioned(
                      left: 580,
                      top: 970,
                      child: _buildIsoLabel("HUNDREDTH"),
                    ),

                    Positioned(
                      left: 460,
                      top: 1040,
                      child: _buildIsoLabel("CONVEYOR BELT"),
                    ),
                    Positioned(
                      left: 1350,
                      top: 1040,
                      child: _buildIsoLabel("BUILD PLATFORM"),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpawner(
    BlockType type,
    double baseLeft,
    double baseTop,
    double dw,
    double dd,
  ) {
    double bw = type == BlockType.hundredth ? 12 : 120;
    double bd = 120;
    double bh = type == BlockType.unit ? 120 : 12;

    Offset anchor = getIsoTopSurfaceOffset(
      baseLeft,
      baseTop,
      600,
      250,
      40,
      dw,
      dd,
    );
    Offset pos = getIsoBlockPositionToAnchorAt(anchor, bw, bd, bh);

    Widget blockWidget = _getBlockWidget(type);
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Draggable<BlockType>(
        data: type,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Transform.scale(
          scale: _transformationController.value.getMaxScaleOnAxis(),
          alignment: Alignment.topLeft,
          child: Material(color: Colors.transparent, child: blockWidget),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: blockWidget),
        onDragStarted: () => _playSound('pop'),
        child: blockWidget,
      ),
    );
  }

  Widget _getBlockWidget(BlockType type) {
    // Exact visual sizing mapping for the pseudo 3D blocks based on image reference
    switch (type) {
      case BlockType.unit:
        return const IsoBlock(
          w: 120,
          d: 120,
          h: 120,
          color: Color(0xFF4B9DFF),
        ); // Blue Cube
      case BlockType.tenth:
        return const IsoBlock(
          w: 120,
          d: 120,
          h: 12,
          color: Color(0xFF38FF75),
        ); // Green Flat
      case BlockType.hundredth:
        return const IsoBlock(
          w: 12,
          d: 120,
          h: 12,
          color: Color(0xFFFFC400),
        ); // Yellow Stick (Flat along depth)
    }
  }

  Widget _buildIsoLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF253141),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 6),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ==================== SIDEBAR & MENUS ====================

  Widget _buildMenuToggleBtn() {
    return IconButton(
      icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
      color: Colors.orangeAccent,
      iconSize: 28,
      onPressed: () {
        HapticFeedback.lightImpact();
        setState(() => _isSidebarOpen = !_isSidebarOpen);
      },
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.orange.withOpacity(0.8)),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Colors.amberAccent),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSidebar(double width) {
    final scenario = scenarios[_currentScenarioIndex];
    final currentStep = scenario.steps[_currentStepIndex];
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: const Border(
          right: BorderSide(color: Colors.white12, width: 1),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 15, spreadRadius: 5),
        ],
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 66, 16, 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.science,
                            color: Colors.amberAccent,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _t('app_title'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t('subtitle'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            Icons.language,
                            _language.toUpperCase(),
                            _changeLanguage,
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            Icons.refresh,
                            _t('reset'),
                            _resetLab,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('select_scenario'),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _currentScenarioIndex,
                              dropdownColor: const Color(0xFF0F172A),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.amberAccent,
                              ),
                              items:
                                  scenarios
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => DropdownMenuItem<int>(
                                          value: e.key,
                                          child: Text(
                                            "${e.key + 1}. ${e.value.title}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _t('blueprint'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFBBDEFB),
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentStep.blueprintMath,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    _t('units'),
                                    countU,
                                    Colors.blue,
                                  ),
                                  _buildStatItem(
                                    _t('tenths'),
                                    countT,
                                    Colors.green,
                                  ),
                                  _buildStatItem(
                                    _t('hund'),
                                    countH,
                                    Colors.yellow,
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _t('total_value'),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    totalValue.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _isStepComplete
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.amber.withOpacity(0.05),
                            border: Border.all(
                              color:
                                  _isStepComplete
                                      ? Colors.green
                                      : Colors.amberAccent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _isStepComplete
                                        ? Icons.check_circle
                                        : Icons.info_outline,
                                    color:
                                        _isStepComplete
                                            ? Colors.green
                                            : Colors.amberAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${_t('step')} ${currentStep.stepId}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _isStepComplete
                                              ? Colors.green
                                              : Colors.amberAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentStep.instruction,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _clearPlatform,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: Text(_t('clear')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withOpacity(
                                    0.2,
                                  ),
                                  foregroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: _buildMainActionButton(currentStep),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(top: BorderSide(color: Colors.white12)),
                  ),
                  child: Text(
                    '© ZeroScienceLab - Fall in love with math and Science',
                    textAlign: TextAlign.center,
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
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButton(LabStep currentStep) {
    if (!_isStepComplete && currentStep.type != 'validate') {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _t('build_to_continue'),
          style: const TextStyle(color: Colors.white38),
        ),
      );
    }
    if (currentStep.type == 'build') {
      return ElevatedButton.icon(
        onPressed: _nextStep,
        icon: const Icon(Icons.arrow_forward),
        label: Text(_t('next_step')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (currentStep.type.startsWith('merge')) {
      return ElevatedButton.icon(
        onPressed: _mergeBlocks,
        icon: const Icon(Icons.auto_fix_high),
        label: Text(_t('merge_blocks')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amberAccent,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {
          setState(() => _showSuccessPopup = true);
          _playSound('success');
        },
        icon: const Icon(Icons.verified),
        label: Text(_t('validate')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildFloatingMissionCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.amberAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                _t('mission_objective'),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scenarios[_currentScenarioIndex].objective,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessPopup() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.greenAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 80),
            const SizedBox(height: 24),
            Text(
              _t('scenario_complete'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _t('success_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showSuccessPopup = false;
                    });
                    _playSound('pop');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: Text(_t('close')),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      () => _loadScenario(
                        (_currentScenarioIndex + 1) % scenarios.length,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: Text(_t('next_scenario')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtainScreen() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('title_main'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _t('subtitle'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _hasEnteredLab = true);
                  _playSound('pop');
                },
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: Text(
                  _t('enter_lab'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== CUSTOM PAINTERS FOR PSEUDO-3D ====================

// 1. Isometric Background Floor
class IsoFloorGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF5F4638)
          ..strokeWidth = 1.0;
    const double tan30 = 0.577350269;

    // Draw diagonal grid lines
    for (double c = -size.height * 2; c < size.height * 2; c += 80) {
      canvas.drawLine(
        Offset(0, c),
        Offset(size.width, size.width * tan30 + c),
        paint,
      );
      canvas.drawLine(
        Offset(0, c),
        Offset(size.width, -size.width * tan30 + c),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Isometric 3D Block Widget Wrapper
class IsoBlock extends StatelessWidget {
  final double w;
  final double d;
  final double h;
  final Color color;
  final bool drawSlots;

  const IsoBlock({
    super.key,
    required this.w,
    required this.d,
    required this.h,
    required this.color,
    this.drawSlots = false,
  });

  @override
  Widget build(BuildContext context) {
    const double cosA = 0.8660254038;
    const double sinA = 0.5;

    // Calculate total visual bounding box size to wrap it properly
    final totalWidth = (w + d) * cosA;
    final totalHeight = (w + d) * sinA + h;

    return CustomPaint(
      size: Size(totalWidth, totalHeight),
      painter: IsoBlockPainter(w, d, h, color, drawSlots),
    );
  }
}

// 3. The Core 3D Block Rendering Mathematics
class IsoBlockPainter extends CustomPainter {
  final double w, d, h;
  final Color color;
  final bool drawSlots;

  IsoBlockPainter(this.w, this.d, this.h, this.color, this.drawSlots);

  @override
  void paint(Canvas canvas, Size size) {
    const double cosA = 0.8660254038;
    const double sinA = 0.5;

    // Anchor: Bottom front corner
    final double startX = w * cosA;
    final double startY = size.height;

    // The 7 visible points of a 3D isometric cube
    final p0 = Offset(startX, startY); // Bottom front
    final p1 = Offset(startX - w * cosA, startY - w * sinA); // Bottom left
    final p2 = Offset(startX + d * cosA, startY - d * sinA); // Bottom right

    final p4 = Offset(startX, startY - h); // Top front
    final p5 = Offset(p1.dx, p1.dy - h); // Top left
    final p6 = Offset(p2.dx, p2.dy - h); // Top right
    final p7 = Offset(
      startX - w * cosA + d * cosA,
      startY - w * sinA - d * sinA - h,
    ); // Top back

    // Faces
    final Path topFace =
        Path()
          ..moveTo(p4.dx, p4.dy)
          ..lineTo(p5.dx, p5.dy)
          ..lineTo(p7.dx, p7.dy)
          ..lineTo(p6.dx, p6.dy)
          ..close();
    final Path leftFace =
        Path()
          ..moveTo(p0.dx, p0.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p5.dx, p5.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close();
    final Path rightFace =
        Path()
          ..moveTo(p0.dx, p0.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p6.dx, p6.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close();

    // Calculate light/shade based on base color
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color topColor = color;
    final Color leftColor =
        hsl.withLightness(math.max(0, hsl.lightness - 0.15)).toColor();
    final Color rightColor =
        hsl.withLightness(math.max(0, hsl.lightness - 0.30)).toColor();

    final paint = Paint()..style = PaintingStyle.fill;

    // Draw 3D faces
    paint.color = topColor;
    canvas.drawPath(topFace, paint);
    paint.color = leftColor;
    canvas.drawPath(leftFace, paint);
    paint.color = rightColor;
    canvas.drawPath(rightFace, paint);

    // Optional subtle outline for clarity
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    paint.color = Colors.black.withOpacity(0.15);
    canvas.drawPath(topFace, paint);
    canvas.drawPath(leftFace, paint);
    canvas.drawPath(rightFace, paint);

    // Draw slot outlines if this is the Build Platform
    if (drawSlots) {
      paint.style = PaintingStyle.stroke;
      paint.color = const Color(0xFF4B9DFF).withOpacity(0.4);
      paint.strokeWidth = 2.0;

      void drawIsoSlot(double offW, double offD, double slotW, double slotD) {
        Offset calc(double mw, double md) {
          return Offset(
            p4.dx - mw * cosA + md * cosA,
            p4.dy - mw * sinA - md * sinA,
          );
        }

        final s0 = calc(offW, offD);
        final s1 = calc(offW + slotW, offD);
        final s2 = calc(offW + slotW, offD + slotD);
        final s3 = calc(offW, offD + slotD);
        final path =
            Path()
              ..moveTo(s0.dx, s0.dy)
              ..lineTo(s1.dx, s1.dy)
              ..lineTo(s2.dx, s2.dy)
              ..lineTo(s3.dx, s3.dy)
              ..close();
        canvas.drawPath(path, paint);
      }

      // Exact mathematical wireframe slots mapped to our 3 variables
      drawIsoSlot(400, 65, 120, 120); // Unit Slot (left)
      drawIsoSlot(220, 65, 120, 120); // Tenth Slot (center)
      drawIsoSlot(40, 65, 120, 120); // Hundredth Slot (right)
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
