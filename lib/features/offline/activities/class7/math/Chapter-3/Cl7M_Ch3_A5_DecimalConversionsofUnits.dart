// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Measurement Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const DecimalConversionsofUnits(),
    ),
  );
}

class DecimalConversionsofUnits extends StatefulWidget {
  const DecimalConversionsofUnits({super.key});

  @override
  State<DecimalConversionsofUnits> createState() =>
      _DecimalConversionsofUnitsState();
}

class _DecimalConversionsofUnitsState extends State<DecimalConversionsofUnits>
    with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showShutter = true;
  int _currentScenario = 1;
  int _currentStep = 1;
  String _currentLanguage = 'EN';

  late AnimationController _pulseController;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // Transformation controller for pan & zoom
  final TransformationController _transformationController =
      TransformationController();

  // Positions on the internal 1200x800 canvas
  Offset _objectPosition = const Offset(150, 450); // Screw or Sugar
  Offset _dataTokenPosition = const Offset(150, 200); // Data block

  // Targets (Expanded pad height to prevent Bottom Overflow during Text Scaling)
  final Rect _padTarget = const Rect.fromLTWH(430, 430, 240, 200);
  final Rect _machineTarget = const Rect.fromLTWH(750, 250, 300, 350);

  final Map<String, Map<String, dynamic>> _translations = {
    'EN': {
      'appTitle': 'The Measurement Converter',
      'appSubtitle': 'Class 7 • A PEEK BEYOND THE POINT',
      'enterLab': 'Enter Lab',
      'selectScenario': 'Select Scenario',
      'scenario1': '1. The Screw Shrinker',
      'scenario2': '2. The Sugar Sorter',
      'proceduralSteps': 'Procedural Steps',
      'step': 'STEP',
      'targetOutput': 'Target Output',
      'convertUnits': 'Convert Units',
      'validateModel': 'Validate Model',
      'measuringPad': 'MEASURING PAD',
      'weighingScale': 'WEIGHING SCALE',
      'converterMachine': 'CONVERTER MACHINE',
      'screw': 'SCREW',
      'sugarBag': 'SUGAR BAG',
      'sugar': 'SUGAR',
      'taskScrew': 'Task: DRAG the screw onto the Measuring Pad.',
      'taskSugar': 'Task: DRAG the sugar bag onto the Weighing Scale.',
      'taskData': 'Task: DRAG the data block into the Converter Machine.',
      'taskConvert':
          'Task: CLICK the \'Convert Units\' button in the sidebar or below.',
      'taskObserve':
          'Task: Observe the calculation and CLICK \'Validate Model\'.',
      'taskReview': 'Task: Review the summary.',
      's1_steps': [
        "DRAG the screw from the workbench and DROP it onto the Digital Measuring Pad.",
        "DRAG the measurement data block and DROP it into the Converter Machine's INPUT hopper.",
        "CLICK the 'Convert Units' button on the canvas to process the conversion.",
        "Observe the summary in the Calculation HUD and Place Value Chart.",
      ],
      's2_steps': [
        "DRAG the bag of sugar and DROP it onto the Digital Weighing Scale.",
        "DRAG the measurement data block and DROP it into the Converter Machine's INPUT hopper.",
        "CLICK the 'Convert Units' button.",
        "Observe the conversion in the Calculation HUD.",
      ],
      'modelValidated': 'Model Validated!',
      's1_summary':
          'To convert millimeters to centimeters, we divide by 10. This is the same as moving the digits one place to the right on the place value chart. 12 mm becomes 1.2 cm.',
      's2_summary':
          'To convert grams to kilograms, we divide by 1000. This is the same as moving the digits three places to the right on the place value chart. 254 g becomes 0.254 kg.',
      'nextScenario': 'Next Scenario',
      'restart': 'Restart',
      'pvcTitle': 'PLACE VALUE CHART',
      'hund': 'Hund.',
      'tens': 'Tens',
      'ones': 'Ones',
      'tenths': 'Tenths',
      'hundths': 'Hundths',
      'thousths': 'Thousths',
      'zoomIn': 'Zoom In',
      'zoomOut': 'Zoom Out',
      'resetView': 'Reset View',
      'resetLab': 'Reset Lab',
    },
    'HI': {
      'appTitle': 'मापन परिवर्तक',
      'appSubtitle': 'कक्षा 7 • बिंदु के पार एक नज़र',
      'enterLab': 'प्रयोगशाला में प्रवेश करें',
      'selectScenario': 'परिदृश्य चुनें',
      'scenario1': '1. पेंच श्रिंकर',
      'scenario2': '2. शुगर सॉर्टर',
      'proceduralSteps': 'प्रक्रियात्मक चरण',
      'step': 'चरण',
      'targetOutput': 'लक्ष्य आउटपुट',
      'convertUnits': 'इकाइयाँ बदलें',
      'validateModel': 'मॉडल मान्य करें',
      'measuringPad': 'मापने वाला पैड',
      'weighingScale': 'वजन मशीन',
      'converterMachine': 'कनवर्टर मशीन',
      'screw': 'पेंच',
      'sugarBag': 'चीनी का थैला',
      'sugar': 'चीनी',
      'taskScrew': 'कार्य: पेंच को खींचकर मापने वाले पैड पर छोड़ें।',
      'taskSugar': 'कार्य: चीनी के थैले को खींचकर वजन मशीन पर छोड़ें।',
      'taskData': 'कार्य: डेटा ब्लॉक को खींचकर कनवर्टर मशीन में छोड़ें।',
      'taskConvert':
          'कार्य: साइडबार या नीचे दिए गए \'इकाइयाँ बदलें\' बटन पर क्लिक करें।',
      'taskObserve': 'कार्य: गणना देखें और \'मॉडल मान्य करें\' पर क्लिक करें।',
      'taskReview': 'कार्य: सारांश की समीक्षा करें।',
      's1_steps': [
        "वर्कबेंच से पेंच को खींचें और डिजिटल मापने वाले पैड पर छोड़ें।",
        "मापन डेटा ब्लॉक को खींचें और कनवर्टर मशीन के इनपुट हॉपर में छोड़ें।",
        "रूपांतरण प्रक्रिया के लिए 'इकाइयाँ बदलें' बटन पर क्लिक करें।",
        "गणना HUD और स्थानीय मान चार्ट में सारांश देखें।",
      ],
      's2_steps': [
        "चीनी के थैले को खींचें और डिजिटल वजन मशीन पर छोड़ें।",
        "मापन डेटा ब्लॉक को खींचें और कनवर्टर मशीन के इनपुट हॉपर में छोड़ें।",
        "'इकाइयाँ बदलें' बटन पर क्लिक करें।",
        "गणना HUD में रूपांतरण देखें।",
      ],
      'modelValidated': 'मॉडल मान्य!',
      's1_summary':
          'मिलीमीटर को सेंटीमीटर में बदलने के लिए, हम 10 से भाग देते हैं। यह स्थानीय मान चार्ट पर अंकों को एक स्थान दाईं ओर ले जाने के समान है। 12 mm, 1.2 cm बन जाता है।',
      's2_summary':
          'ग्राम को किलोग्राम में बदलने के लिए, हम 1000 से भाग देते हैं। यह स्थानीय मान चार्ट पर अंकों को तीन स्थान दाईं ओर ले जाने के समान है। 254 g, 0.254 kg बन जाता है।',
      'nextScenario': 'अगला परिदृश्य',
      'restart': 'पुनः आरंभ करें',
      'pvcTitle': 'स्थानीय मान चार्ट',
      'hund': 'सौ',
      'tens': 'दस',
      'ones': 'एक',
      'tenths': 'दसवां',
      'hundths': 'सौवां',
      'thousths': 'हजारवां',
      'zoomIn': 'ज़ूम इन',
      'zoomOut': 'ज़ूम आउट',
      'resetView': 'दृश्य रीसेट करें',
      'resetLab': 'लैब रीसेट करें',
    },
  };

  Map<String, dynamic> get _t => _translations[_currentLanguage]!;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _resetPositions();
  }

  @override
  void dispose() {
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _pulseController.dispose();
    _transformationController.dispose();
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
    await _clickPlayer.play(
      AssetSource(
        'audio/class7/mixkit_2073.mp3',
      ),
    );
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class7/gotitem.mp3',
      ),
    );
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class7/mixkit_1491.mp3',
      ),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class7/mixkit_946.mp3',
      ),
    );
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class7/mixkit_2574.mp3',
      ),
    );
  }
  // ----------------------

  void _resetPositions() {
    setState(() {
      _currentStep = 1;
      _objectPosition = const Offset(150, 450);
      _dataTokenPosition = const Offset(150, 200);
    });
  }

  void _resetLab() {
    playClick();
    setState(() {
      _currentScenario = 1;
      _showShutter = true;
      _resetPositions();
      _resetViewNoSound(); // prevent double playing
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _currentScenario = id;
      _resetPositions();
      _resetViewNoSound();
    });
  }

  void _advanceStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _resetViewNoSound() {
    _transformationController.value = Matrix4.identity();
  }

  String _getMissionText() {
    if (_currentStep == 1) {
      return _currentScenario == 1 ? _t['taskScrew'] : _t['taskSugar'];
    } else if (_currentStep == 2) {
      return _t['taskData'];
    } else if (_currentStep == 3) {
      return _t['taskConvert'];
    } else if (_currentStep == 4) {
      return _t['taskObserve'];
    } else {
      return _t['taskReview'];
    }
  }

  // Uses Flutter's drag system directly - avoiding pan/zoom coordinate drift
  void _onObjectDropped() {
    playPageOpen();
    setState(() {
      _objectPosition = Offset(
        _padTarget.center.dx - 50,
        _padTarget.center.dy - 30, // Perfectly centers the object
      );
      _advanceStep();
    });
  }

  void _onDataTokenDropped() {
    playPageOpen();
    setState(() {
      _dataTokenPosition = Offset(
        _machineTarget.center.dx - 60,
        _machineTarget.top + 70, // Inside hopper
      );
      _advanceStep();
    });
  }

  void _triggerConversion() async {
    playClick();
    setState(() {
      _advanceStep();
    });
    // Wait for animation then advance to validation
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && _currentStep == 4) {
      // Nothing automatic, user needs to click validate
    }
  }

  void _validateModel() {
    playPageOpen();
    setState(() {
      _advanceStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.35;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // MAIN CONTENT AREA (Canvas, Overlays, Popups)
            // This entire block dynamically shrinks/moves when the sidebar opens!
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: Stack(
                children: [
                  // 1. Zoomable Canvas Area
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF0F172A),
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 0.5,
                        maxScale: 3.0,
                        boundaryMargin: const EdgeInsets.all(
                          1000,
                        ), // Allows easy panning beyond edges
                        constrained: false,
                        child: SizedBox(
                          width: 1200,
                          height: 800,
                          child: _buildCanvasContent(),
                        ),
                      ),
                    ),
                  ),

                  // 2. Place Value Chart Overlay (Visible during conversion step & after)
                  if (_currentStep >= 4)
                    Positioned(
                      top: 20,
                      // Automatically adjusts spacing when sidebar is closed so it doesn't overlap the menu icon
                      left: _isSidebarOpen ? 20 : 80,
                      right: 20,
                      child: _buildPlaceValueChart(),
                    ),

                  // 3. Floating Mission Card (Visible when sidebar is closed)
                  if (!_isSidebarOpen)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020617).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.orangeAccent.withOpacity(0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.track_changes,
                                    color: Colors.orangeAccent,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _getMissionText(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (_currentStep == 3 || _currentStep == 4)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: _currentStep == 3
                                      ? ElevatedButton.icon(
                                          icon: const Icon(Icons.auto_fix_high),
                                          label: Text(
                                            _t['convertUnits'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 24,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _triggerConversion,
                                        )
                                      : ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.check_circle_outline,
                                          ),
                                          label: Text(
                                            _t['validateModel'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 24,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _validateModel,
                                        ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 4. Success / Summary Popup
                  if (_currentStep == 5)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Container(
                            width: 500,
                            constraints: const BoxConstraints(maxHeight: 400),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _t['modelValidated'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _currentScenario == 1
                                        ? _t['s1_summary']
                                        : _t['s2_summary'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orangeAccent,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                    ),
                                    onPressed: () {
                                      playClick();
                                      _loadScenario(
                                        _currentScenario == 1 ? 2 : 1,
                                      );
                                    },
                                    child: Text(
                                      _currentScenario == 1
                                          ? _t['nextScenario']
                                          : _t['restart'],
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

            // 5. Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // 6. Menu Icon (Top Left - Fixed overlaying everything else)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  playClick();
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

            // 8. Shutter Screen (Curtain Raiser)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _showShutter ? 0 : -MediaQuery.of(context).size.height,
              bottom: _showShutter ? 0 : MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              child: _buildShutterScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF020617), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(
              begin: 1.0,
              end: 1.1,
            ).animate(_pulseController),
            child: const Icon(
              Icons.science, // Flask icon equivalent
              size: 80,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _t['appTitle'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _t['appSubtitle'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFCBD5E1), // Slate-300
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                curtainScreen();
                setState(() {
                  _showShutter = false;
                });
              },
              child: Text(
                _t['enterLab'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to draw the dark hovering labels above objects
  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white30, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCanvasContent() {
    return Stack(
      children: [
        // Wood Floor Background
        Positioned.fill(child: CustomPaint(painter: WoodFloorPainter())),

        // Target 1: Pad / Scale
        Positioned(
          left: _padTarget.left,
          top: _padTarget.top,
          width: _padTarget.width,
          height: _padTarget.height,
          child: DragTarget<String>(
            onAccept: (data) {
              if (data == 'object' && _currentStep == 1) {
                _onObjectDropped();
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Center(
                child: _currentScenario == 1
                    ? _buildMeasuringPad(candidateData.isNotEmpty)
                    : _buildWeighingScale(candidateData.isNotEmpty),
              );
            },
          ),
        ),

        // Target 2: Converter Machine
        Positioned(
          left: _machineTarget.left,
          top: _machineTarget.top,
          width: _machineTarget.width,
          height: _machineTarget.height,
          child: DragTarget<String>(
            onAccept: (data) {
              if (data == 'data' && _currentStep == 2) {
                _onDataTokenDropped();
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Center(child: _buildMachine(candidateData.isNotEmpty));
            },
          ),
        ),

        // Draggable: Screw or Sugar
        if (_currentStep == 1)
          Positioned(
            left: _objectPosition.dx,
            top: _objectPosition.dy,
            child: Draggable<String>(
              data: 'object',
              feedback: _buildObjectWidget(isDragging: true),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) {
                if (!details.wasAccepted) {
                  playError();
                  setState(() {
                    _objectPosition = const Offset(150, 450); // reset
                  });
                }
              },
              child: _buildObjectWidget(),
            ),
          )
        else
          Positioned(
            left: _objectPosition.dx,
            top: _objectPosition.dy,
            child: _buildObjectWidget(),
          ),

        // Draggable: Data Token (Appears after Step 1)
        if (_currentStep >= 2 && _currentStep < 4)
          Positioned(
            left: _dataTokenPosition.dx,
            top: _dataTokenPosition.dy,
            child: Draggable<String>(
              data: 'data',
              feedback: _buildDataTokenWidget(isDragging: true),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) {
                if (!details.wasAccepted) {
                  playError();
                  setState(() {
                    _dataTokenPosition = const Offset(150, 200); // reset
                  });
                }
              },
              child: _buildDataTokenWidget(),
            ),
          ),
      ],
    );
  }

  Widget _buildMeasuringPad(bool isHovered) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(_t['measuringPad']),
        const SizedBox(height: 12),
        Container(
          width: 180,
          height:
              90, // Reduced from 100 to fix bottom overflow risk inside parent
          decoration: BoxDecoration(
            color: const Color(0xFF94A3B8), // Outer silver frame
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF64748B), width: 6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isHovered
                  ? const Color(0xFF10B981)
                  : const Color(0xFF020617), // Screen
              border: Border.all(color: Colors.black54, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeighingScale(bool isHovered) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(_t['weighingScale']),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            // Base cylinder
            Container(
              width: 160,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(80),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            // Top Plate
            Container(
              width: 130,
              height: 55,
              decoration: BoxDecoration(
                color: isHovered
                    ? const Color(0xFF10B981)
                    : const Color(0xFF94A3B8),
                borderRadius: BorderRadius.circular(65),
                border: Border.all(color: const Color(0xFF64748B), width: 3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMachine(bool isHovered) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(_t['converterMachine']),
        const SizedBox(height: 10),
        // Hopper
        CustomPaint(
          size: const Size(140, 70),
          painter: TrapezoidPainter(
            color: isHovered ? Colors.yellowAccent : const Color(0xFFD4AF37),
          ),
        ),
        // Main Body
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Center block
            Container(
              width: 160,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF334155), // Dark bluish grey
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            // Screen
            Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.black38, width: 2),
              ),
            ),
            // Left Pillar
            Positioned(
              left: -15,
              child: Container(
                width: 20,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Right Pillar
            Positioned(
              right: -15,
              child: Container(
                width: 20,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        // Base / Tray
        Container(
          width: 190,
          height: 40,
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: Container(
            width: 100,
            height: 15,
            decoration: const BoxDecoration(
              color: Color(0xFF64748B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObjectWidget({bool isDragging = false}) {
    if (_currentScenario == 1) {
      // SCREW
      return Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLabel(_t['screw']),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: isDragging
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Screw Head
                  Container(
                    width: 15,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Screw Shaft
                  Container(
                    width: 60,
                    height: 16,
                    color: const Color(0xFF475569),
                  ),
                  // Screw Tip
                  CustomPaint(
                    size: const Size(25, 16),
                    painter: TrianglePainter(color: const Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // SUGAR BAG
      return Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLabel(_t['sugarBag']),
            const SizedBox(height: 10),
            Container(
              width: 100,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // White/beige sack
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: isDragging
                        ? const Offset(0, 10)
                        : const Offset(0, 4),
                  ),
                  // Inner shadow to make it look spherical
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(
                      color: const Color(0xFF8B4513),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _t['sugar'],
                    style: const TextStyle(
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDataTokenWidget({bool isDragging = false}) {
    String text = _currentScenario == 1 ? "12 mm" : "254 g";
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.yellowAccent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            if (isDragging)
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProceduralSteps() {
    List<String> steps = List<String>.from(
      _currentScenario == 1 ? _t['s1_steps'] : _t['s2_steps'],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list_alt, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              _t['proceduralSteps'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          int idx = entry.key;
          String step = entry.value;
          bool isCurrent = idx == (_currentStep - 1);
          bool isPast = idx < (_currentStep - 1);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent
                  ? Colors.orangeAccent
                  : Colors.white.withOpacity(isPast ? 0.05 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_t['step']} ${idx + 1}",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? Colors.black54 : Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step,
                  style: TextStyle(
                    color: isCurrent
                        ? Colors.black
                        : (isPast ? Colors.white38 : Colors.white),
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        border: const Border(
          right: BorderSide(color: Colors.orangeAccent, width: 2),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      child: CustomScrollView(
        slivers: [
          // 1. Fixed Header Area
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(
                top: 66,
                left: 16,
                right: 16,
                bottom: 16,
              ),
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
                        color: Colors.orangeAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _t['appTitle'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _t['appSubtitle'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          playClick();
                          setState(() {
                            _currentLanguage = _currentLanguage == 'EN'
                                ? 'HI'
                                : 'EN';
                          });
                        },
                        icon: const Icon(Icons.language, size: 16),
                        label: Text(_currentLanguage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          minimumSize: const Size(0, 32),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _resetLab,
                        icon: const Icon(Icons.refresh, size: 20),
                        color: Colors.redAccent,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(32, 32),
                        ),
                        tooltip: _t['resetLab'],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Main Scrollable Content Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t['selectScenario'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _currentScenario,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: const Color(0xFF1E293B),
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          _t['scenario1'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          _t['scenario2'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        playDropdown();
                        _loadScenario(val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Procedural Steps Added Here
                  _buildProceduralSteps(),
                  const SizedBox(height: 24),

                  // Target Output & Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.gps_fixed,
                              color: Colors.orangeAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _t['targetOutput'],
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getMissionText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_currentStep == 3)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_fix_high),
                        label: Text(
                          _t['convertUnits'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _triggerConversion,
                      ),
                    ),

                  if (_currentStep == 4)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          _t['validateModel'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _validateModel,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Footer (Pushed to bottom of remaining space)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '© ZeroScienceLab - Fall in love with math and Science',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceValueChart() {
    // Determine digit positions based on current step (pre or post conversion)
    // 0 = 100s, 1 = 10s, 2 = 1s, 3 = 1/10, 4 = 1/100, 5 = 1/1000

    // Screw: 12mm -> 1.2cm (Shift +1)
    // Sugar: 254g -> 0.254kg (Shift +3)

    List<Widget> digits = [];
    double colWidth = 60.0;

    if (_currentScenario == 1) {
      int shift = _currentStep >= 4 ? 1 : 0;
      digits.add(_buildAnimatedDigit('1', (1 + shift) * colWidth));
      digits.add(_buildAnimatedDigit('2', (2 + shift) * colWidth));
    } else {
      int shift = _currentStep >= 4 ? 3 : 0;
      digits.add(_buildAnimatedDigit('2', (0 + shift) * colWidth));
      digits.add(_buildAnimatedDigit('5', (1 + shift) * colWidth));
      digits.add(_buildAnimatedDigit('4', (2 + shift) * colWidth));
      if (_currentStep >= 4) {
        digits.add(
          _buildAnimatedDigit('0', 2 * colWidth, delay: true),
        ); // The leading zero
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              _t['pvcTitle'],
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPvcHeader("100s", _t['hund']),
              _buildPvcHeader("10s", _t['tens']),
              _buildPvcHeader("1s", _t['ones']),
              _buildPvcHeader("1/10", _t['tenths']),
              _buildPvcHeader("1/100", _t['hundths']),
              _buildPvcHeader("1/1000", _t['thousths']),
            ],
          ),
          SizedBox(
            height: 60,
            width: colWidth * 6,
            child: Stack(
              children: [
                // Decimal point
                Positioned(
                  left: colWidth * 3 - 5,
                  bottom: 5,
                  child: const Text(
                    ".",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...digits,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPvcHeader(String top, String bottom) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
          Text(
            top,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            bottom,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDigit(
    String digit,
    double leftPos, {
    bool delay = false,
  }) {
    return AnimatedPositioned(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      left: leftPos,
      top: 10,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: delay ? 0.0 : 1.0, end: 1.0),
        duration: Duration(milliseconds: delay ? 800 : 0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: SizedBox(
              width: 60,
              child: Center(
                child: Text(
                  digit,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- CUSTOM PAINTERS ----------------

class WoodFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base wood color
    final paint = Paint()..color = const Color(0xFFC48B5D);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Floorboard lines
    final linePaint = Paint()
      ..color = const Color(0xFF8B5A2B).withOpacity(0.4)
      ..strokeWidth = 2.0;

    // Draw vertical/perspective-like lines
    for (double i = 0; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);

      // Slight grain effect
      canvas.drawLine(
        Offset(i + 10, 0),
        Offset(i + 10, size.height),
        Paint()
          ..color = const Color(0xFF8B5A2B).withOpacity(0.1)
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrapezoidPainter extends CustomPainter {
  final Color color;
  TrapezoidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.7, size.height)
      ..lineTo(size.width * 0.3, size.height)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Drop shadow
    canvas.drawShadow(path, Colors.black, 4, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
