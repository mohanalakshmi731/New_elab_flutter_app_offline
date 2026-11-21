// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class Cl6M_Ch6_A5_TheTrianglesSecret extends StatefulWidget {
  const Cl6M_Ch6_A5_TheTrianglesSecret({super.key});

  @override
  State<Cl6M_Ch6_A5_TheTrianglesSecret> createState() =>
      _Cl6M_Ch6_A5_TheTrianglesSecretState();
}

class _Cl6M_Ch6_A5_TheTrianglesSecretState
    extends State<Cl6M_Ch6_A5_TheTrianglesSecret>
    with TickerProviderStateMixin {
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // State
  String _currentLang = 'en';
  int _currentScenario = 1;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 300;
  final bool _showLabels = true;
  bool _showCurtain = true;

  // Feedback
  bool _showFeedback = false;
  bool _isSuccess = false;
  String _feedbackTitle = "";
  String _feedbackMessage = "";

  // Toast
  String _toastMessage = "";
  bool _showToast = false;

  // Canvas State
  final GlobalKey _canvasKey = GlobalKey();
  double _scale = 30.0; // pixels per unit
  Offset _offset = Offset.zero;
  Offset _startingOffset = Offset.zero;
  double _startingScale = 1.0;
  bool _isOffsetInitialized = false;

  final List<Offset> _points = [];
  int _draggedPointIndex = -1;
  bool _isPanning = false;

  int _base = 0;
  int _height = 0;
  double _area = 0.0;

  // Animations
  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;
  late AnimationController _gameLoopController;

  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'shutterTitle': 'Area of a Triangle',
      'shutterChapter': 'Chapter 6: Mensuration',
      'enterLab': 'Enter Lab',
      'headerTitle': 'Area of a Triangle',
      'headerSubtitle': 'Class 6 • Mensuration',
      'indepBase': 'Base (b)',
      'indepHeight': 'Height (h)',
      'depVar': 'Area (A)',
      'missionTitle': 'Mission Objective',
      'stepsTitle': 'Procedural Steps',
      'validateBtn': 'Validate Model',
      'nextBtn': 'Next Scenario',
      'restartBtn': 'Restart Activity',
      'scenarios': [
        {
          'val': 1,
          'text': 'Scenario 1: Build a Specific Triangle',
          'mission':
              'Build a triangle with a Base of 6 units and a Height of 4 units.',
          'steps': [
            'Click anywhere on the grid to place the first vertex.',
            'Click on the same horizontal line to place the second vertex, making sure the Base is 6 units.',
            'Click anywhere else to place the third vertex so that the Height is 4 units.',
            'Observe the resulting Area: 1/2 × b × h',
            'When ready, click Validate Model.',
          ],
          'toast': 'Place 3 points to form a triangle.',
        },
        {
          'val': 2,
          'text': 'Scenario 2: Achieve a Specific Area',
          'mission':
              'Build any triangle that has an exact Area of 10 sq units.',
          'steps': [
            'Use the Trash icon to clear the grid.',
            'Think of a Base and Height combination that yields an area of 10.',
            'Place your three vertices to form the triangle.',
            'When ready, click Validate Model.',
          ],
          'toast': 'Build a triangle with Area = 10.',
        },
      ],
      'feedback': {
        's1Success': [
          'Outstanding!',
          'You built the correct triangle. Area = 1/2 × 6 × 4 = 12.',
        ],
        's1Fail': [
          'Not Quite.',
          'Check the HUD. Ensure your Base is exactly 6 and your Height is exactly 4.',
        ],
        's2Success': [
          'Brilliant!',
          'You proved that Area = 10. There are multiple combinations (e.g. 5x4 or 10x2).',
        ],
        's2Fail': [
          'Keep trying.',
          'Make sure your calculated Area is exactly 10.',
        ],
      },
    },
    'hi': {
      'shutterTitle': "त्रिभुज का क्षेत्रफल",
      'shutterChapter': "अध्याय 6: क्षेत्रमिति",
      'enterLab': "लैब में प्रवेश करें",
      'headerTitle': "त्रिभुज का क्षेत्रफल",
      'headerSubtitle': "कक्षा 6 • क्षेत्रमिति",
      'indepBase': "आधार (b)",
      'indepHeight': "ऊंचाई (h)",
      'depVar': "क्षेत्रफल (A)",
      'missionTitle': "मिशन का उद्देश्य",
      'stepsTitle': "प्रक्रियात्मक चरण",
      'validateBtn': "मॉडल सत्यापित करें",
      'nextBtn': "अगला परिदृश्य",
      'restartBtn': "गतिविधि पुनः आरंभ करें",
      'scenarios': [
        {
          'val': 1,
          'text': "परिदृश्य 1: एक विशिष्ट त्रिभुज बनाएं",
          'mission': "6 इकाई आधार और 4 इकाई ऊंचाई वाला एक त्रिभुज बनाएं।",
          'steps': [
            "पहला शीर्ष रखने के लिए ग्रिड पर कहीं भी क्लिक करें।",
            "आधार 6 इकाई बनाने के लिए दूसरी क्षैतिज रेखा पर क्लिक करें।",
            "तीसरा शीर्ष ऐसे रखें कि ऊंचाई 4 इकाई हो।",
            "परिणामी क्षेत्रफल देखें: 1/2 × b × h",
            "तैयार होने पर सत्यापित करें पर क्लिक करें।",
          ],
          'toast': "त्रिभुज बनाने के लिए 3 बिंदु रखें।",
        },
        {
          'val': 2,
          'text': "परिदृश्य 2: एक विशिष्ट क्षेत्रफल प्राप्त करें",
          'mission':
              "कोई भी त्रिभुज बनाएं जिसका सटीक क्षेत्रफल 10 वर्ग इकाई हो।",
          'steps': [
            "ग्रिड को साफ़ करने के लिए ट्रैश आइकन का उपयोग करें।",
            "ऐसा आधार और ऊंचाई सोचें जिससे क्षेत्रफल 10 हो जाए।",
            "त्रिभुज बनाने के लिए अपने तीन शीर्ष रखें।",
            "तैयार होने पर सत्यापित करें पर क्लिक करें।",
          ],
          'toast': "क्षेत्रफल = 10 वाला एक त्रिभुज बनाएं।",
        },
      ],
      'feedback': {
        's1Success': [
          "उत्कृष्ट!",
          "आपने सही त्रिभुज बनाया। क्षेत्रफल = 1/2 × 6 × 4 = 12.",
        ],
        's1Fail': [
          "बिल्कुल नहीं।",
          "सुनिश्चित करें कि आपका आधार 6 और ऊंचाई 4 है।",
        ],
        's2Success': ["शानदार!", "आपने सिद्ध किया कि क्षेत्रफल 10 है।"],
        's2Fail': [
          "प्रयास करते रहें।",
          "सुनिश्चित करें कि आपका क्षेत्रफल 10 है।",
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
          CurvedAnimation(parent: _shutterController, curve: Curves.easeInOut),
        );

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _shutterController.dispose();
    _gameLoopController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
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
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  void _calculateMetrics() {
    if (_points.length == 3) {
      _base = (_points[1].dx - _points[0].dx).abs().toInt();
      _height = (_points[2].dy - _points[0].dy).abs().toInt();
      _area = 0.5 * _base * _height;
    } else if (_points.length == 2) {
      _base = (_points[1].dx - _points[0].dx).abs().toInt();
      _height = 0;
      _area = 0.0;
    } else {
      _base = 0;
      _height = 0;
      _area = 0.0;
    }
  }

  void _resetScene() {
    playClick();
    setState(() {
      _points.clear();
      _draggedPointIndex = -1;
      _calculateMetrics();
      _showFeedback = false;
    });
  }

  void _resetLab() {
    _resetScene();
    setState(() {
      _currentScenario = 1;
      _showCurtain = true;
      _isSidebarOpen = true;
      _offset = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
      _scale = 30.0;
    });
    _shutterController.reverse();
  }

  void _showToastMessage(String msg) {
    setState(() {
      _toastMessage = msg;
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  void _validateInvestigation() {
    if (_points.length < 3) {
      playError();
      setState(() {
        _showFeedback = true;
        _isSuccess = false;
        _feedbackTitle = "Incomplete";
        _feedbackMessage = "Please place all 3 vertices to form a triangle.";
      });
      return;
    }

    bool success = false;
    String msgType = '';

    if (_currentScenario == 1) {
      if (_base == 6 && _height == 4) {
        success = true;
        msgType = 's1Success';
      } else {
        msgType = 's1Fail';
      }
    } else if (_currentScenario == 2) {
      if (_area == 10) {
        success = true;
        msgType = 's2Success';
      } else {
        msgType = 's2Fail';
      }
    }

    final t = i18n[_currentLang]!['feedback'];

    if (success) {
      playPageOpen();
    } else {
      playError();
    }

    setState(() {
      _showFeedback = true;
      _isSuccess = success;
      _feedbackTitle = t[msgType][0];
      _feedbackMessage = t[msgType][1];
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    RenderBox box = _canvasKey.currentContext?.findRenderObject() as RenderBox;
    Offset localPos = box.globalToLocal(details.focalPoint);

    Offset worldPos = (localPos - _offset) / _scale;
    _draggedPointIndex = -1;

    for (int i = 0; i < _points.length; i++) {
      if ((_points[i] - worldPos).distance < 0.8) {
        _draggedPointIndex = i;
        break;
      }
    }

    if (_draggedPointIndex == -1) {
      _startingOffset = _offset;
      _startingScale = _scale;
      _isPanning = true;
    } else {
      _isPanning = false;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount > 1) {}

    RenderBox box = _canvasKey.currentContext?.findRenderObject() as RenderBox;
    Offset localPos = box.globalToLocal(details.focalPoint);

    if (_draggedPointIndex != -1) {
      Offset worldPos = (localPos - _offset) / _scale;
      double wx = worldPos.dx.roundToDouble();
      double wy = worldPos.dy.roundToDouble();

      setState(() {
        if (_draggedPointIndex == 0 && _points.length >= 2) {
          _points[1] = Offset(_points[1].dx, wy);
        } else if (_draggedPointIndex == 1) {
          wy = _points[0].dy;
          if (wx == _points[0].dx) {
            wx = _points[0].dx > 0 ? _points[0].dx - 1 : _points[0].dx + 1;
          }
        }
        _points[_draggedPointIndex] = Offset(wx, wy);
        _calculateMetrics();
      });
    } else if (_isPanning) {
      setState(() {
        _scale = (_startingScale * details.scale).clamp(10.0, 150.0);
        _offset = _startingOffset + details.focalPointDelta;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _draggedPointIndex = -1;
    _isPanning = false;
  }

  void _processTapAtFocalPoint(Offset localPos) {
    Offset worldPos = (localPos - _offset) / _scale;
    double wx = worldPos.dx.roundToDouble();
    double wy = worldPos.dy.roundToDouble();

    if (_points.length == 1) {
      wy = _points[0].dy;
      if (wx == _points[0].dx) return;
    } else if (_points.length >= 3) {
      _showToastMessage("Grid is full. Clear the canvas to build another.");
      return;
    }

    playClick();
    setState(() {
      _points.add(Offset(wx, wy));
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
                        painter: _TrianglePainter(
                          points: _points,
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
                                t['indepBase'],
                                _base.toString(),
                                Colors.blueAccent,
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
                                t['indepHeight'],
                                _height.toString(),
                                Colors.redAccent,
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
                                _area.toStringAsFixed(1).replaceAll('.0', ''),
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
                                String newLang = index == 0 ? 'en' : 'hi';
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
                              _resetLab();
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

                      const SizedBox(height: 32),

                      if (!_showFeedback)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            t['validateBtn'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _validateInvestigation,
                        ),

                      if (_showFeedback && _isSuccess && _currentScenario == 1)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(
                            t['nextBtn'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            playPageOpen();
                            setState(() {
                              _currentScenario = 2;
                              _resetScene();
                            });
                            _showToastMessage(t['scenarios'][1]['toast']);
                          },
                        ),

                      if (_showFeedback && _isSuccess && _currentScenario == 2)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
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

class _TrianglePainter extends CustomPainter {
  final List<Offset> points;
  final Offset offset;
  final double scale;
  final bool showLabels;
  final Animation<double> animation;

  _TrianglePainter({
    required this.points,
    required this.offset,
    required this.scale,
    required this.showLabels,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // Draw Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;
    final axisPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.2)
      ..strokeWidth = 2.0;

    int startX = ((-offset.dx) / scale).floor();
    int endX = ((size.width - offset.dx) / scale).ceil();
    int startY = ((-offset.dy) / scale).floor();
    int endY = ((size.height - offset.dy) / scale).ceil();

    if (showLabels) {
      for (int i = startX; i <= endX; i++) {
        double x = i * scale + offset.dx;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          i == 0 ? axisPaint : gridPaint,
        );
      }
      for (int i = startY; i <= endY; i++) {
        double y = i * scale + offset.dy;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          i == 0 ? axisPaint : gridPaint,
        );
      }
    }

    // Draw Triangle & Lines
    if (points.length >= 2) {
      final p1 = points[0] * scale + offset;
      final p2 = points[1] * scale + offset;
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = Colors.blueAccent
          ..strokeWidth = 3.0,
      );
    }

    if (points.length == 3) {
      final p1 = points[0] * scale + offset;
      final p2 = points[1] * scale + offset;
      final p3 = points[2] * scale + offset;

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.greenAccent.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );

      canvas.drawLine(
        p1,
        p3,
        Paint()
          ..color = Colors.greenAccent
          ..strokeWidth = 3.0,
      );
      canvas.drawLine(
        p2,
        p3,
        Paint()
          ..color = Colors.greenAccent
          ..strokeWidth = 3.0,
      );

      // Dashed Height Line
      final p3Foot = Offset(points[2].dx, points[0].dy) * scale + offset;
      _drawDashedLine(
        canvas,
        p3,
        p3Foot,
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 2.0,
      );
    }

    // Draw Points
    for (int i = 0; i < points.length; i++) {
      final p = points[i] * scale + offset;
      double pulse = 1.0 + 0.1 * math.sin(animation.value * 2 * math.pi);

      canvas.drawCircle(
        p,
        8.0 * pulse,
        Paint()..color = Colors.lightBlueAccent,
      );
      canvas.drawCircle(
        p,
        14.0 * pulse,
        Paint()..color = Colors.lightBlueAccent.withOpacity(0.3),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const int dashWidth = 5;
    const int dashSpace = 5;
    double startX = p1.dx;
    double startY = p1.dy;
    double distance = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    double i = 0;
    while (i < distance) {
      canvas.drawLine(
        Offset(startX + dx * i, startY + dy * i),
        Offset(startX + dx * (i + dashWidth), startY + dy * (i + dashWidth)),
        paint,
      );
      i += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return true;
  }
}
