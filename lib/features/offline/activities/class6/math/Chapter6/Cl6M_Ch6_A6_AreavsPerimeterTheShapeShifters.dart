// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cl6M_Ch6_A6_AreavsPerimeterTheShapeShifters(),
    ),
  );
}

class Cl6M_Ch6_A6_AreavsPerimeterTheShapeShifters extends StatefulWidget {
  const Cl6M_Ch6_A6_AreavsPerimeterTheShapeShifters({super.key});

  @override
  _Cl6M_Ch6_A6_AreavsPerimeterTheShapeShiftersState createState() =>
      _Cl6M_Ch6_A6_AreavsPerimeterTheShapeShiftersState();
}

class _Cl6M_Ch6_A6_AreavsPerimeterTheShapeShiftersState
    extends State<Cl6M_Ch6_A6_AreavsPerimeterTheShapeShifters>
    with TickerProviderStateMixin {
  // --- STATE ---
  String _currentLang = 'en';
  int _currentScenario = 1;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  bool _showCurtain = true;

  Set<String> _blocks = {};
  int _area = 0;
  int _perimeter = 0;

  bool _showLabels = true;
  bool _isPanning = false;

  // Camera/Canvas State
  double _scale = 40.0;
  Offset _offset = Offset.zero;
  double _startingScale = 40.0;
  Offset _startingOffset = Offset.zero;
  bool _isOffsetInitialized = false;

  final GlobalKey _canvasKey = GlobalKey();

  // Feedback State
  bool _showFeedback = false;
  bool _isSuccess = false;
  String _feedbackTitle = "";
  String _feedbackMessage = "";

  // Toast State
  bool _showToast = false;
  String _toastMessage = "";

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;
  late AnimationController _gameLoopController;

  final Map<String, dynamic> i18n = {
    'en': {
      'shutterTitle': "Investigating Area and Perimeter",
      'shutterChapter': "Chapter 6: Mensuration",
      'enterLab': "Enter Lab",
      'headerTitle': "Investigating Area and Perimeter",
      'headerSubtitle': "Class 6 • Mensuration",
      'indepVar': "Perimeter (Indep)",
      'depVar': "Area (Dep)",
      'unitsP': "units",
      'unitsA': "sq units",
      'missionTitle': "Mission Objective",
      'stepsTitle': "Procedural Steps",
      'validateBtn': "Validate Model",
      'nextBtn': "Next Scenario",
      'restartBtn': "Restart Activity",
      'scenarios': [
        {
          'val': 1,
          'text': "Scenario 1: Same Perimeter, Different Area",
          'mission':
              "Build two different shapes that both have a Perimeter of exactly 12 units, but try to maximize the Area of one of them.",
          'steps': [
            "Click on the grid to place 1x1 blocks and form a shape.",
            "Keep an eye on the HUD below to monitor Perimeter and Area.",
            "Once Perimeter is 12, notice the Area.",
            "Try building a different shape with Perimeter 12 and see if the Area changes.",
            "When ready, click Validate Model.",
          ],
          'toast': "Click grid to place blocks. Goal: Perimeter = 12.",
        },
        {
          'val': 2,
          'text': "Scenario 2: Same Area, Different Perimeter",
          'mission':
              "Build a shape that has an Area of exactly 9 sq units, but try to maximize its Perimeter.",
          'steps': [
            "Clear the board (use Reset button) if needed.",
            "Place exactly 9 blocks to make the Area = 9.",
            "Arrange them to make the Perimeter as large as possible.",
            "When ready, click Validate Model.",
          ],
          'toast': "Click grid to place blocks. Goal: Area = 9.",
        },
      ],
      'feedback': {
        's1Success': [
          "Outstanding!",
          "You proved that a fixed perimeter (12) can enclose different areas (e.g., 9 sq units vs 5 sq units).",
        ],
        's1Fail': [
          "Not Quite.",
          "Ensure your perimeter is exactly 12. Keep trying different arrangements!",
        ],
        's2Success': [
          "Brilliant!",
          "You proved that a fixed area (9) can have varying perimeters. A long straight line gives max perimeter (20).",
        ],
        's2Fail': [
          "Keep trying.",
          "Make sure you placed exactly 9 blocks (Area = 9).",
        ],
      },
    },
    'hi': {
      'shutterTitle': "क्षेत्रफल और परिमाप के बीच संबंध की जांच",
      'shutterChapter': "अध्याय 6: क्षेत्रमिति",
      'enterLab': "लैब में प्रवेश करें",
      'headerTitle': "क्षेत्रफल और परिमाप की जांच",
      'headerSubtitle': "कक्षा 6 • क्षेत्रमिति",
      'indepVar': "परिमाप (स्वतंत्र)",
      'depVar': "क्षेत्रफल (आश्रित)",
      'unitsP': "इकाई",
      'unitsA': "वर्ग इकाई",
      'missionTitle': "मिशन का उद्देश्य",
      'stepsTitle': "प्रक्रियात्मक चरण",
      'validateBtn': "मॉडल सत्यापित करें",
      'nextBtn': "अगला परिदृश्य",
      'restartBtn': "गतिविधि पुनः आरंभ करें",
      'scenarios': [
        {
          'val': 1,
          'text': "परिदृश्य 1: समान परिमाप, भिन्न क्षेत्रफल",
          'mission':
              "दो अलग-अलग आकृतियाँ बनाएँ जिनका परिमाप 12 इकाई हो, लेकिन एक का क्षेत्रफल अधिकतम करने का प्रयास करें।",
          'steps': [
            "1x1 ब्लॉक रखने के लिए ग्रिड पर क्लिक करें।",
            "नीचे HUD में परिमाप और क्षेत्रफल देखें।",
            "जब परिमाप 12 हो जाए, तो क्षेत्रफल नोट करें।",
            "12 परिमाप वाली कोई और आकृति बनाएँ और देखें कि क्षेत्रफल बदलता है या नहीं।",
            "तैयार होने पर सत्यापित करें पर क्लिक करें।",
          ],
          'toast':
              "ब्लॉक लगाने के लिए ग्रिड पर क्लिक करें। लक्ष्य: परिमाप = 12.",
        },
        {
          'val': 2,
          'text': "परिदृश्य 2: समान क्षेत्रफल, भिन्न परिमाप",
          'mission':
              "ऐसी आकृति बनाएँ जिसका क्षेत्रफल 9 वर्ग इकाई हो, लेकिन इसका परिमाप अधिकतम करने का प्रयास करें।",
          'steps': [
            "जरूरत हो तो बोर्ड साफ़ करें (रीसेट बटन)।",
            "क्षेत्रफल = 9 करने के लिए ठीक 9 ब्लॉक रखें।",
            "उन्हें ऐसे व्यवस्थित करें कि परिमाप अधिकतम हो।",
            "तैयार होने पर सत्यापित करें पर क्लिक करें।",
          ],
          'toast':
              "ब्लॉक लगाने के लिए ग्रिड पर क्लिक करें। लक्ष्य: क्षेत्रफल = 9.",
        },
      ],
      'feedback': {
        's1Success': [
          "उत्कृष्ट!",
          "आपने सिद्ध किया कि समान परिमाप (12) वाले अलग-अलग क्षेत्रफल हो सकते हैं।",
        ],
        's1Fail': [
          "बिल्कुल नहीं।",
          "सुनिश्चित करें कि आपका परिमाप 12 है। प्रयास करते रहें!",
        ],
        's2Success': [
          "शानदार!",
          "आपने सिद्ध किया कि समान क्षेत्रफल (9) वाले अलग-अलग परिमाप हो सकते हैं।",
        ],
        's2Fail': [
          "प्रयास करते रहें।",
          "सुनिश्चित करें कि आपने ठीक 9 ब्लॉक रखे हैं (क्षेत्रफल = 9)।",
        ],
      },
    },
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shutterAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
          CurvedAnimation(
            parent: _shutterController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _shutterController.dispose();
    _gameLoopController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  // --- AUDIO ---
  Future<void> curtainScreen() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/math/error.mp3'));
  }

  void _showToastMessage(String msg) {
    setState(() {
      _toastMessage = msg;
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  void _resetScene() {
    setState(() {
      _blocks.clear();
      _showFeedback = false;
      _isSuccess = false;
      _calculateMetrics();
    });
  }

  void _resetLab() {
    setState(() {
      _currentScenario = 1;
      _isSidebarOpen = true;
      _showCurtain = true;
      _shutterController.reset();
      _offset = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
      _scale = 40.0;
    });
    _resetScene();
  }

  void _calculateMetrics() {
    int area = _blocks.length;
    int perimeter = 0;

    for (String blockStr in _blocks) {
      List<String> parts = blockStr.split(',');
      int x = int.parse(parts[0]);
      int y = int.parse(parts[1]);

      int exposedEdges = 4;
      if (_blocks.contains('${x + 1},$y')) exposedEdges--;
      if (_blocks.contains('${x - 1},$y')) exposedEdges--;
      if (_blocks.contains('$x,${y + 1}')) exposedEdges--;
      if (_blocks.contains('$x,${y - 1}')) exposedEdges--;

      perimeter += exposedEdges;
    }

    setState(() {
      _area = area;
      _perimeter = perimeter;
    });
  }

  void _validateModel() {
    bool success = false;
    String msgType = '';

    if (_currentScenario == 1) {
      if (_perimeter == 12) {
        success = true;
        msgType = 's1Success';
      } else {
        msgType = 's1Fail';
      }
    } else if (_currentScenario == 2) {
      if (_area == 9) {
        success = true;
        msgType = 's2Success';
      } else {
        msgType = 's2Fail';
      }
    }

    setState(() {
      _showFeedback = true;
      _isSuccess = success;
      _feedbackTitle = i18n[_currentLang]!['feedback'][msgType][0];
      _feedbackMessage = i18n[_currentLang]!['feedback'][msgType][1];
    });

    if (success) {
      playPageOpen();
    } else {
      playError();
    }
  }

  // --- GESTURES ---
  void _handleScaleStart(ScaleStartDetails details) {
    _startingScale = _scale;
    _startingOffset = _offset;
    _isPanning = true;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_isPanning) {
      setState(() {
        _scale = (_startingScale * details.scale).clamp(10.0, 150.0);
        _offset = _startingOffset + details.focalPointDelta;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _isPanning = false;
  }

  void _processTapAtFocalPoint(Offset localPos) {
    Offset worldPos = (localPos - _offset) / _scale;
    int gridX = worldPos.dx.floor();
    int gridY = worldPos.dy.floor();
    String key = '$gridX,$gridY';

    playClick();
    setState(() {
      if (_blocks.contains(key)) {
        _blocks.remove(key);
      } else {
        _blocks.add(key);
      }
      _calculateMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffsetInitialized) {
      _offset = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
      _isOffsetInitialized = true;
    }

    final t = i18n[_currentLang]!;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: Stack(
                children: [
                  // Interactive CustomPainter
                  Positioned.fill(
                    child: GestureDetector(
                      key: _canvasKey,
                      onTapUp: (details) {
                        _processTapAtFocalPoint(details.localPosition);
                      },
                      onScaleStart: _handleScaleStart,
                      onScaleUpdate: _handleScaleUpdate,
                      onScaleEnd: _handleScaleEnd,
                      child: CustomPaint(
                        painter: _GridPainter(
                          blocks: _blocks,
                          offset: _offset,
                          scale: _scale,
                          showLabels: _showLabels,
                          animation: _gameLoopController,
                        ),
                      ),
                    ),
                  ),

                  // HUD (Bottom Center)
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHudMetric(
                                t['indepVar'],
                                _perimeter.toString(),
                                Colors.yellowAccent,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                height: 40,
                                width: 1,
                                color: Colors.white24,
                              ),
                              _buildHudMetric(
                                t['depVar'],
                                _area.toString(),
                                Colors.greenAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Toast Message
                  if (_showToast)
                    Positioned(
                      top: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _toastMessage,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
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

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 60,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.change_history,
                              color: Colors.amber,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['headerTitle'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t['headerSubtitle'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Language & Reset Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white38),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ToggleButtons(
                              isSelected: [
                                _currentLang == 'en',
                                _currentLang == 'hi',
                              ],
                              onPressed: (index) {
                                String newLang = ['en', 'hi'][index];
                                if (_currentLang != newLang) {
                                  playDropdown();
                                  setState(() {
                                    _currentLang = newLang;
                                    _currentScenario = 1;
                                    _resetScene();
                                  });
                                }
                              },
                              color: Colors.white54,
                              selectedColor: Colors.white,
                              fillColor: Colors.blueAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                              constraints: const BoxConstraints(
                                minHeight: 36,
                                minWidth: 48,
                              ),
                              children: const [
                                Text(
                                  'EN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'HI',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            tooltip: "Reset Lab",
                            onPressed: () {
                              playClick();
                              _resetScene();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Dropdown for Scenario
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white54,
                            ),
                            value: _currentScenario,
                            items: (t['scenarios'] as List)
                                .map<DropdownMenuItem<int>>((sc) {
                                  return DropdownMenuItem<int>(
                                    value: sc['val'] as int,
                                    child: Text(sc['text']),
                                  );
                                })
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                playDropdown();
                                setState(() {
                                  _currentScenario = v;
                                  _resetScene();
                                });
                                _showToastMessage(
                                  t['scenarios'][_currentScenario - 1]['toast'],
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mission Objective
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.my_location,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t['missionTitle'],
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (t['scenarios'][_currentScenario - 1]['mission']),
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.5,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Icon(
                            Icons.format_list_numbered,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t['stepsTitle'],
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...((t['scenarios'][_currentScenario - 1]['steps']
                              as List)
                          .map(
                            (step) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "• ",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      height: 1.2,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        height: 1.4,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),

                      if (_showFeedback) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isSuccess
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            border: Border.all(
                              color: _isSuccess
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _isSuccess ? Icons.check_circle : Icons.warning,
                                color: _isSuccess ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _feedbackTitle,
                                      style: TextStyle(
                                        color: _isSuccess
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _feedbackMessage,
                                      style: TextStyle(
                                        color: _isSuccess
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      if (!_isSuccess)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            t['validateBtn'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            playClick();
                            _validateModel();
                          },
                        ),

                      if (_isSuccess &&
                          _currentScenario < t['scenarios'].length)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.arrow_right_alt),
                          label: Text(
                            t['nextBtn'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            playClick();
                            setState(() {
                              _currentScenario++;
                              _resetScene();
                            });
                          },
                        ),

                      if (_isSuccess &&
                          _currentScenario == t['scenarios'].length)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            t['restartBtn'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            playClick();
                            _resetLab();
                          },
                        ),

                      const SizedBox(height: 40),
                      // Footer
                      const Center(
                        child: Text(
                          "© ZeroScienceLab - Fall in love with math and Science",
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Resizer for sidebar
            if (_isSidebarOpen)
              Positioned(
                left: _sidebarWidth - 10,
                top: 0,
                bottom: 0,
                width: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      setState(() {
                        _sidebarWidth += details.delta.dx;
                        if (_sidebarWidth < 300) _sidebarWidth = 300;
                        if (_sidebarWidth >
                            MediaQuery.of(context).size.width * 0.7) {
                          _sidebarWidth =
                              MediaQuery.of(context).size.width * 0.7;
                        }
                      });
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 10,
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Floating Menu Button (Fixed Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B),
                  child: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    playClick();
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                ),
              ),
            ),

            // Curtain Shutter
            if (_showCurtain) _buildShutter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHudMetric(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShutter() {
    final t = i18n[_currentLang]!;
    return SlideTransition(
      position: _shutterAnimation,
      child: Container(
        color: const Color(0xFF020617),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t['shutterTitle'],
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t['shutterChapter'],
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.science),
              label: Text(
                t['enterLab'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                curtainScreen();
                _shutterController.forward();
                Future.delayed(const Duration(milliseconds: 1200), () {
                  if (!mounted) return;
                  setState(() {
                    _showCurtain = false;
                  });
                  _showToastMessage(
                    t['scenarios'][_currentScenario - 1]['toast'],
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Set<String> blocks;
  final Offset offset;
  final double scale;
  final bool showLabels;
  final Animation<double> animation;

  _GridPainter({
    required this.blocks,
    required this.offset,
    required this.scale,
    required this.showLabels,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // Draw Background Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    int startX = ((-offset.dx) / scale).floor();
    int endX = ((size.width - offset.dx) / scale).ceil();
    int startY = ((-offset.dy) / scale).floor();
    int endY = ((size.height - offset.dy) / scale).ceil();

    if (showLabels) {
      for (int i = startX; i <= endX; i++) {
        double x = i * scale + offset.dx;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (int j = startY; j <= endY; j++) {
        double y = j * scale + offset.dy;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // Draw Placed Blocks
    final blockPaint = Paint()
      ..color = const Color(0xFF3B82F6); // Blue color matches Three.js box
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (String blockStr in blocks) {
      List<String> parts = blockStr.split(',');
      int bx = int.parse(parts[0]);
      int by = int.parse(parts[1]);

      double left = bx * scale + offset.dx;
      double top = by * scale + offset.dy;

      Rect rect = Rect.fromLTWH(left, top, scale, scale);

      // We use a slight corner radius to make it look nicer like a diorama block
      RRect roundedRect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(scale * 0.1),
      );

      canvas.drawRRect(roundedRect, blockPaint);
      canvas.drawRRect(roundedRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return true; // We repaint on animation frames anyway
  }
}
