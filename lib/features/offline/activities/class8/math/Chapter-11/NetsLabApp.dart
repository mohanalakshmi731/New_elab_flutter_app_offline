// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZSLLabApp());
}

class ZSLLabApp extends StatelessWidget {
  const ZSLLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFFEAB308),
        fontFamily: 'Roboto',
      ),
      home: const NetsLabScreen(),
    );
  }
}

class NetsLabScreen extends StatefulWidget {
  const NetsLabScreen({super.key});

  @override
  State<NetsLabScreen> createState() => _NetsLabScreenState();
}

class _NetsLabScreenState extends State<NetsLabScreen> {
  bool _isSidebarOpen = true;

  // Shutter screen state
  bool _showShutter = true;
  double _shutterOffset = 0;

  int _currentStep = 1;
  String _lang = 'en';

  // State variables for interactions
  final Map<String, String> _droppedItems = {};

  // Step 3 Matches
  final Map<String, String> _matches = {};
  String? _selectedMatch;

  // Step 4 Variables
  double _slantHeight = 3.0;
  final Map<String, double> _attachedTriangles = {};

  bool _isSuccess = false;
  String _feedbackMessage = "";

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _startPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static const String _startUrl =
      'audio/class8/mixkit_2574.mp3';
  static const String _errorUrl =
      'audio/class8/mixkit_955.mp3';
  static const String _clickUrl =
      'audio/class8/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class8/mixkit_2018.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _setInitialFeedback();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _clickPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _startPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) {
    try {
      if (type == 'click') {
        _clickPlayer.play(AssetSource(_clickUrl));
      } else if (type == 'success') {
        _successPlayer.play(AssetSource(_successUrl));
      } else if (type == 'error') {
        _errorPlayer.play(AssetSource(_errorUrl));
      }
    } catch (e) {
      // Ignore audio errors gracefully
    }
  }

  void _setInitialFeedback() {
    setState(() {
      _feedbackMessage = _t('init');
      _isSuccess = false;
    });
  }

  String _t(String key) {
    return _i18n[_lang]?[key] ?? key;
  }

  void _enterLab() {
    _startPlayer.play(AssetSource(_startUrl));
    setState(() {
      _shutterOffset = -MediaQuery.of(context).size.height;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showShutter = false;
        });
      }
    });
  }

  void _restartLab() {
    _playSound('click');
    setState(() {
      _lang = 'en';
      _currentStep = 1;
      _droppedItems.clear();
      _matches.clear();
      _selectedMatch = null;
      _slantHeight = 3.0;
      _attachedTriangles.clear();

      _setInitialFeedback();
      _shutterOffset = 0;
      _showShutter = true;
      _isSidebarOpen = true;
    });
  }

  void _verifyTask() {
    bool success = false;
    String msg = "";
    bool needsReset = false;

    if (_currentStep == 1) {
      if (_droppedItems['slot_2'] == '2' && _droppedItems['slot_6'] == '6') {
        success = true;
        msg = _t('s1_success');
      } else if (_droppedItems.isNotEmpty) {
        success = false;
        msg = _droppedItems['slot_2'] == '6' ? _t('s1_fail') : _t('tryAgain');
        needsReset = true;
      } else {
        success = false;
        msg = _t('plsComplete');
      }
    } else if (_currentStep == 2) {
      if (_droppedItems['evalA'] == 'valid' &&
          _droppedItems['evalB'] == 'invalid') {
        success = true;
        msg = _t('s2_success');
      } else if (_droppedItems.isNotEmpty) {
        success = false;
        msg = _t('s2_fail');
        needsReset = true;
      } else {
        success = false;
        msg = _t('plsComplete');
      }
    } else if (_currentStep == 3) {
      if (_matches.length >= 4) {
        // symmetric entries: A->B, B->A (2 pairs = 4 entries)
        if ((_matches['solid_cyl'] == 'net_cyl' ||
                _matches['net_cyl'] == 'solid_cyl') &&
            (_matches['solid_cone'] == 'net_cone' ||
                _matches['net_cone'] == 'solid_cone')) {
          success = true;
          msg = _t('s3_success');
        } else {
          success = false;
          msg = _t('s3_fail');
          needsReset = true;
        }
      } else {
        success = false;
        msg = _t('plsComplete');
      }
    } else if (_currentStep == 4) {
      if (_attachedTriangles.length == 4) {
        bool allFive = _attachedTriangles.values.every((val) => val == 5.0);
        if (allFive) {
          success = true;
          msg = _t('s4_success');
        } else {
          success = false;
          msg = _t('s4_fail');
          needsReset = true;
        }
      } else {
        success = false;
        msg = _t('plsComplete');
      }
    }

    setState(() {
      _isSuccess = success;
      _feedbackMessage = msg;
    });

    if (success) {
      _playSound('success');
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentStep < 4) {
          setState(() {
            _currentStep++;
            _droppedItems.clear();
            _matches.clear();
            _selectedMatch = null;
            _slantHeight = 3.0;
            _attachedTriangles.clear();
            _setInitialFeedback();
          });
        } else {
          _showSuccessPopup();
        }
      });
    } else {
      _playSound('error');
      if (needsReset) {
        // Delay clearing items so the user can see what they did wrong
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted && !_isSuccess) {
            setState(() {
              if (_currentStep == 1 || _currentStep == 2) {
                _droppedItems.clear();
              } else if (_currentStep == 3) {
                _matches.clear();
                _selectedMatch = null;
              } else if (_currentStep == 4) {
                _attachedTriangles.clear();
              }
            });
          }
        });
      }
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, color: Color(0xFFEAB308), size: 64),
              const SizedBox(height: 16),
              Text(
                _t('congrats'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t('congratsMsg'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartLab();
                },
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: Text(
                  _t('restart'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMatchClick(String id) {
    if (_currentStep != 3) return;
    _playSound('click');

    setState(() {
      if (_selectedMatch == null) {
        _selectedMatch = id;
      } else {
        if (_selectedMatch != id) {
          bool isSourceSolid = _selectedMatch!.startsWith('solid_');
          bool isTargetSolid = id.startsWith('solid_');
          if (isSourceSolid != isTargetSolid) {
            _matches[_selectedMatch!] = id;
            _matches[id] = _selectedMatch!;
          }
        }
        _selectedMatch = null;
      }
    });
  }

  void _attachTriangle(String edge) {
    if (_currentStep != 4) return;
    _playSound('click');
    setState(() {
      _attachedTriangles[edge] = _slantHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // --- Center Activity Area ---
            Positioned(
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                color: const Color(0xFF020617),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 24.0,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _buildWorkspaceGraphics(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Feedback HUD
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.85),
                        border: Border.all(color: const Color(0xFF334155)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle : Icons.info,
                            color: _isSuccess
                                ? Colors.greenAccent
                                : Colors.lightBlueAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _feedbackMessage,
                              style: TextStyle(
                                color: _isSuccess
                                    ? Colors.greenAccent
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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

            // --- Left Sidebar (Entirely Scrollable, No sticky elements) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(right: BorderSide(color: Color(0xFF334155))),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 64,
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- HEADER ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.school,
                            color: Color(0xFFEAB308),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('title'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _t('subtitle'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- LANGUAGE & RESTART BUTTONS ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildLangBtn('en', 'EN'),
                              const SizedBox(width: 8),
                              _buildLangBtn('hi', 'HI'),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _restartLab,
                            icon: const Icon(
                              Icons.refresh,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              _t('restart'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF334155)),
                      const SizedBox(height: 16),

                      // --- TEACHER TEXT ---
                      Text(
                        _t('missionObj'),
                        style: const TextStyle(
                          color: Color(0xFFEAB308),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTeacherText(),
                      const SizedBox(height: 24),

                      // --- INTERACTIVE CONTROLS ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: _buildControlsAndVerify(),
                      ),
                      const SizedBox(height: 32),

                      // --- FOOTER ---
                      const Divider(color: Color(0xFF334155)),
                      const SizedBox(height: 12),
                      const Text(
                        "© ZEROSCIENCELAB - Fall in Love with Math and Science",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top-Left Menu Button (Floating Z-Index Front)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(
                  _isSidebarOpen ? Icons.menu_open : Icons.menu,
                  size: 28,
                ),
                color: Colors.white,
                onPressed: () {
                  _playSound('click');
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: _isSidebarOpen
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // --- Shutter Screen ---
            if (_showShutter || _shutterOffset < 0)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutCubic,
                top: _shutterOffset,
                bottom: -_shutterOffset,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFF060B19),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.dashboard_customize,
                            color: Color(0xFFEAB308),
                            size: 100,
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              _t('title'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _t('subtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton(
                            onPressed: _enterLab,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAB308),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 10,
                            ),
                            child: Text(
                              _t('enterLab'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
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

  // --- Widget Builders ---

  Widget _buildControlsAndVerify() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInteractiveControls(),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _verifyTask,
          icon: const Icon(Icons.check_circle, color: Colors.black),
          label: Text(
            _t('verify'),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEAB308),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLangBtn(String langCode, String label) {
    bool isSelected = _lang == langCode;
    return InkWell(
      onTap: () {
        if (!isSelected) {
          _playSound('click');
          setState(() {
            _lang = langCode;
            _setInitialFeedback();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAB308) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFFEAB308) : Colors.white24,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherText() {
    switch (_currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('s1_t1'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s1_t2'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s1_t3'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('s2_t1'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s2_t2'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s2_t3'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('s3_t1'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s3_t2'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s3_t3'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('s4_t1'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s4_t2'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s4_t3'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWorkspaceGraphics() {
    switch (_currentStep) {
      case 1:
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            border: Border.all(color: const Color(0xFF334155), width: 4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _emptyBox(),
                  _diceBox('1'),
                  _emptyBox(),
                  _emptyBox(),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _diceBox('5'),
                  _diceBox('3'),
                  _buildDropTarget('slot_2'),
                  _diceBox('4'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _emptyBox(),
                  _buildDropTarget('slot_6'),
                  _emptyBox(),
                  _emptyBox(),
                ],
              ),
            ],
          ),
        );
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNetEvalBox('A', 'evalA', [
              _emptyBox(small: true),
              _netBox(Colors.green, small: true),
              _emptyBox(small: true),
              _emptyBox(small: true),
              _netBox(Colors.green, small: true),
              _emptyBox(small: true),
              _netBox(Colors.green, small: true),
              _netBox(Colors.green, small: true),
              _netBox(Colors.green, small: true),
              _emptyBox(small: true),
              _netBox(Colors.green, small: true),
              _emptyBox(small: true),
            ], 3),
            const SizedBox(width: 40),
            _buildNetEvalBox('B', 'evalB', [
              _emptyBox(small: true),
              _netBox(Colors.red, small: true),
              _emptyBox(small: true),
              _netBox(Colors.red, small: true),
              _emptyBox(small: true),
              _netBox(Colors.red, small: true),
              _emptyBox(small: true),
              _netBox(Colors.red, small: true),
              _netBox(Colors.red, small: true),
              _netBox(Colors.red, small: true),
            ], 2),
          ],
        );
      case 3:
        return SizedBox(
          width: 500,
          height: 400,
          child: Stack(
            children: [
              // Match Lines Painter
              CustomPaint(
                size: const Size(500, 400),
                painter: MatchLinesPainter(_matches),
              ),
              // Left Column (Solids)
              Positioned(
                left: 40,
                top: 40,
                child: _buildMatchItem('solid_cyl', 'cylinder3D', true),
              ),
              Positioned(
                left: 40,
                top: 220,
                child: _buildMatchItem('solid_cone', 'cone3D', true),
              ),
              // Right Column (Nets)
              Positioned(
                left: 320,
                top: 0,
                child: _buildMatchItem(
                  'net_cone',
                  'netCone',
                  false,
                  _t('netCone'),
                ),
              ),
              Positioned(
                left: 320,
                top: 130,
                child: _buildMatchItem(
                  'net_cube',
                  'netCube',
                  false,
                  _t('netCube'),
                ),
              ),
              Positioned(
                left: 320,
                top: 260,
                child: _buildMatchItem(
                  'net_cyl',
                  'netCyl',
                  false,
                  _t('netCyl'),
                ),
              ),
            ],
          ),
        );
      case 4:
        double baseX = 160.0;
        double baseY = 160.0;
        return SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Center Base
              Positioned(
                left: baseX,
                top: baseY,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    border: Border.all(color: Colors.yellow[800]!, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10),
                    ],
                  ),
                ),
              ),
              // Attachment Zones & Triangles
              _buildTriangleEdge('top', baseX, baseY),
              _buildTriangleEdge('bottom', baseX, baseY),
              _buildTriangleEdge('left', baseX, baseY),
              _buildTriangleEdge('right', baseX, baseY),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInteractiveControls() {
    switch (_currentStep) {
      case 1:
        return Column(
          children: [
            Text(
              _t('s1_hud'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['2', '6']
                  .map(
                    (n) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildDraggable(n),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Text(
              _t('s2_hud'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildStampDraggable('valid', _t('stampValid'), Colors.greenAccent),
            const SizedBox(height: 12),
            _buildStampDraggable(
              'invalid',
              _t('stampImpossible'),
              Colors.redAccent,
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            const Icon(Icons.touch_app, color: Color(0xFFEAB308), size: 40),
            const SizedBox(height: 12),
            Text(
              _t('s3_hud'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            Text(
              _t('s4_hud'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _t('lblSlant'),
                  style: const TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${_slantHeight.toInt()} cm",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _slantHeight,
              min: 3,
              max: 6,
              divisions: 3,
              activeColor: const Color(0xFFEAB308),
              inactiveColor: const Color(0xFF334155),
              onChanged: (val) {
                setState(() {
                  _slantHeight = val;
                  // Update attached triangles with new slant height dynamically
                  _attachedTriangles.keys.toList().forEach((k) {
                    _attachedTriangles[k] = val;
                  });
                });
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Step 1 Helpers ---
  Widget _emptyBox({bool small = false}) {
    double size = small ? 40 : 80;
    return SizedBox(width: size, height: size);
  }

  Widget _diceBox(String val) {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue[600],
        border: Border.all(color: Colors.blue[400]!, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        val,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropTarget(String targetKey) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        _playSound('click');
        setState(() {
          _droppedItems[targetKey] = details.data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        bool hasItem =
            _droppedItems.containsKey(targetKey) &&
            _droppedItems[targetKey] != null;
        return Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasItem ? Colors.indigoAccent : Colors.white10,
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? const Color(0xFFEAB308)
                  : Colors.white30,
              width: candidateData.isNotEmpty ? 4 : 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            hasItem ? _droppedItems[targetKey]! : '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  // --- Step 2 Helpers ---
  Widget _netBox(Color color, {bool small = false}) {
    double size = small ? 40 : 80;
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNetEvalBox(
    String title,
    String targetKey,
    List<Widget> gridItems,
    int crossAxisCount,
  ) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        _playSound('click');
        setState(() {
          _droppedItems[targetKey] = details.data;
        });
      },
      builder: (context, candidate, rejected) {
        bool isEvaluated = _droppedItems.containsKey(targetKey);
        String? val = _droppedItems[targetKey];
        Color outlineColor = Colors.white24;
        if (candidate.isNotEmpty) {
          outlineColor = const Color(0xFFEAB308);
        } else if (isEvaluated && val == 'valid') {
          outlineColor = Colors.green;
        } else if (isEvaluated && val == 'invalid') {
          outlineColor = Colors.red;
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            border: Border.all(color: outlineColor, width: 4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              SizedBox(
                width: crossAxisCount * 44.0,
                child: Wrap(children: gridItems),
              ),
              const SizedBox(height: 16),
              Text(
                "NET $title",
                style: TextStyle(
                  color: outlineColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              if (isEvaluated)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: val == 'valid' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    val == 'valid' ? _t('stampValid') : _t('stampImpossible'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- Step 3 Helpers ---
  Widget _buildMatchItem(
    String id,
    String shape,
    bool isSolid, [
    String? label,
  ]) {
    bool isSelected = _selectedMatch == id;
    bool isMatched = _matches.containsKey(id);

    Color borderColor = Colors.transparent;
    if (isSelected) {
      borderColor = const Color(0xFFEAB308);
    } else if (isMatched) {
      borderColor = Colors.green;
    }
    return GestureDetector(
      onTap: () => _handleMatchClick(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? const [BoxShadow(color: Color(0xFFEAB308), blurRadius: 10)]
              : null,
        ),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 100,
              child: CustomPaint(painter: ShapePainter(shape)),
            ),
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Step 4 Helpers ---
  Widget _buildTriangleEdge(String edge, double baseX, double baseY) {
    bool isAttached = _attachedTriangles.containsKey(edge);
    double h = isAttached ? _attachedTriangles[edge]! * 20 : 0;

    double gap = 4;
    double unattachedShortSide = 24;

    double topPos = 0;
    double leftPos = 0;

    if (edge == 'top') {
      topPos = baseY + (isAttached ? -h : -(unattachedShortSide + gap));
      leftPos = baseX;
    } else if (edge == 'bottom') {
      topPos = baseY + 80 + (isAttached ? 0 : gap);
      leftPos = baseX;
    } else if (edge == 'left') {
      topPos = baseY;
      leftPos = baseX + (isAttached ? -h : -(unattachedShortSide + gap));
    } else if (edge == 'right') {
      topPos = baseY;
      leftPos = baseX + 80 + (isAttached ? 0 : gap);
    }

    return Positioned(
      top: topPos,
      left: leftPos,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _attachTriangle(edge),
        child: isAttached
            ? SizedBox(
                width: (edge == 'top' || edge == 'bottom') ? 80 : h,
                height: (edge == 'left' || edge == 'right') ? 80 : h,
                child: CustomPaint(painter: TrianglePainter(edge)),
              )
            : Container(
                width: (edge == 'top' || edge == 'bottom')
                    ? 80
                    : unattachedShortSide,
                height: (edge == 'left' || edge == 'right')
                    ? 80
                    : unattachedShortSide,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  border: Border.all(color: Colors.white54),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
      ),
    );
  }

  // --- Shared Drag Helpers ---
  Widget _buildDraggable(String value) {
    Widget dragUi = Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.indigoAccent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Draggable<String>(
      data: value,
      feedback: Opacity(opacity: 0.8, child: dragUi),
      childWhenDragging: Opacity(opacity: 0.3, child: dragUi),
      onDragStarted: () => _playSound('click'),
      child: dragUi,
    );
  }

  Widget _buildStampDraggable(String labelKey, String labelText, Color color) {
    Widget dragUi = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        labelText,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
    );

    return Draggable<String>(
      data: labelKey,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 250,
          child: Opacity(opacity: 0.9, child: dragUi),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: dragUi),
      onDragStarted: () => _playSound('click'),
      child: dragUi,
    );
  }

  // Multi-Language Dictionary
  static const Map<String, Map<String, String>> _i18n = {
    'en': {
      'subtitle': "Class 8 • Exploring some Geometric Themes",
      'enterLab': "ENTER LAB",
      'title': "Nets (2D to 3D Transformation)",
      'teacher': "Teacher Board",
      'init':
          "Ready! Read the Teacher Board and use the interactive tools to solve the problem.",
      'verify': "Verify Task",
      'congrats': "Congratulations!",
      'congratsMsg': "You have mastered the properties of Geometric Nets!",
      'restart': "Restart",
      'plsComplete': "Please complete the interactions before verifying.",
      'tryAgain': "Try Again",
      'missionObj': "Mission Objective",
      'proceduralSteps': "Procedural Steps",
      's1_t1':
          "A net is a flat 2D shape that can be folded to form a 3D solid.",
      's1_t2':
          "Let's look at the net of a standard dice (a cube). A key rule for a standard dice is that the numbers on opposite faces must always add up to 7.",
      's1_t3':
          "If we mentally fold this cross-shaped net, which squares will end up opposite each other?",
      's1_hud':
          "Drag '2' and '6' to the correct blank squares so opposite faces sum to 7.",
      's1_success':
          "Excellent spatial reasoning! The net folds into a 3D dice. The 2 faces the 5, the 6 faces the 1, and the 3 faces the 4.",
      's1_fail':
          "Almost! When folded, the faces you placed will not be opposite the correct numbers. Try swapping the tiles.",
      's2_t1':
          "Can any arrangement of six squares fold into a closed cube? No!",
      's2_t2':
          "Some arrangements will cause faces to overlap, leaving an empty gap on another side.",
      's2_t3:':
          "Let's compare a standard T-shape net with a long strip of squares. Which one represents an impossible net for a cube?",
      's2_hud':
          "Drag the [VALID] and [IMPOSSIBLE] stamps to the correct geometrical nets.",
      'stampValid': "VALID",
      'stampImpossible': "IMPOSSIBLE",
      's2_success':
          "Correct! Net A folds perfectly. Net B is impossible because the long strip of 5 squares wraps around and overlaps itself.",
      's2_fail':
          "Trace the folds mentally. A cube only has 4 sides in a 'ring' before it needs a top and bottom.",
      's3_t1':
          "Polyhedrons aren't the only solids with nets. Curved solids like Cylinders and Cones also have unique 2D flat patterns.",
      's3_t2':
          "Cylinder: Unrolls into a flat rectangle, capped by two circular bases.",
      's3_t3':
          "Cone: Unrolls into a single circular base and a sector of a larger circle.",
      's3_hud':
          "Click a 3D solid, then click its corresponding 2D net to connect them with a line.",
      'netCyl': "Net: Rectangle + 2 Circles",
      'netCone': "Net: Circle + Sector",
      'netCube': "Net: 6 Rectangles",
      's3_success':
          "Perfect matching! The cylinder's body unrolls into a rectangle, and the cone's body unrolls into a sector.",
      's3_fail':
          "Look at the bases of the 3D shapes. A cylinder has TWO circular bases. A cone has only ONE circular base.",
      's4_t1':
          "Drawing an accurate net requires exact measurements. Let's construct a net for a Square Pyramid.",
      's4_t2': "A square base with sides of 4cm.",
      's4_t3':
          "Four triangular faces with a 'slant height' of exactly 5cm. Attach the correct triangles to the central base.",
      's4_hud':
          "Set Slant Height to 5cm. Click all 4 edges of the central square base to attach faces.",
      'lblSlant': "Slant Height:",
      's4_success':
          "Masterful construction! You set the slant height to 5cm and attached four identical triangular faces.",
      's4_fail':
          "Check the tool settings and attachments. The pyramid requires a slant height of exactly 5cm.",
    },
    'hi': {
      'subtitle': "कक्षा 8 • कुछ ज्यामितीय विषयों का अन्वेषण",
      'enterLab': "प्रयोगशाला में प्रवेश करें",
      'title': "जाल (2D से 3D रूपांतरण)",
      'teacher': "शिक्षक बोर्ड",
      'init':
          "तैयार! शिक्षक बोर्ड पढ़ें और समस्या को हल करने के लिए उपकरणों का उपयोग करें।",
      'verify': "सत्यापित करें",
      'congrats': "बधाई हो!",
      'congratsMsg':
          "आपने ज्यामितीय जाल के गुणों में सफलतापूर्वक महारत हासिल कर ली है!",
      'restart': "Restart",
      'plsComplete': "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।",
      'tryAgain': "पुनः प्रयास करें",
      'missionObj': "मिशन का उद्देश्य",
      'proceduralSteps': "प्रक्रियात्मक चरण",
      's1_t1':
          "एक जाल (net) एक सपाट 2D आकार है जिसे मोड़कर 3D ठोस बनाया जा सकता है।",
      's1_t2':
          "आइए मानक पासे (एक घन) के जाल को देखें। नियम यह है कि विपरीत फलकों की संख्याओं का योग 7 होना चाहिए।",
      's1_t3':
          "यदि हम जाल को मानसिक रूप से मोड़ते हैं, तो कौन से वर्ग एक-दूसरे के विपरीत होंगे?",
      's1_hud':
          "विपरीत फलकों का योग 7 करने के लिए '2' और '6' को सही रिक्त वर्गों पर खींचें।",
      's1_success':
          "उत्कृष्ट स्थानिक तर्क! जाल एक 3D पासे में मुड़ जाता है। 2 का मुख 5 की ओर है, 6 का मुख 1 की ओर है, और 3 का मुख 4 की ओर है।",
      's1_fail':
          "लगभग! मुड़ने पर, आपके द्वारा रखे गए फलक सही संख्याओं के विपरीत नहीं होंगे।",
      's2_t1':
          "क्या छह वर्गों की कोई भी व्यवस्था एक बंद घन में मुड़ सकती है? नहीं!",
      's2_t2:':
          "कुछ व्यवस्थाओं के कारण फलक ओवरलैप हो जाएंगे, जिससे खाली जगह रह जाएगी।",
      's2_t3':
          "आइए वर्गों की एक लंबी पट्टी की तुलना करें। घन के लिए कौन सा एक असंभव जाल है?",
      's2_hud': "[मान्य] और [असंभव] टिकटों को सही ज्यामितीय जाल पर खींचें।",
      'stampValid': "मान्य",
      'stampImpossible': "असंभव",
      's2_success:':
          "सही पहचान! नेट ए मुड़ता है। नेट बी असंभव है क्योंकि 5 वर्गों की लंबी पट्टी खुद को ओवरलैप करती है।",
      's2_fail':
          "मोड़ का मानसिक रूप से पता लगाएं। घन में केवल 4 किनारे होते हैं।",
      's3_t1':
          "बेलन और शंकु जैसे घुमावदार ठोस पदार्थों में भी अद्वितीय 2D सपाट पैटर्न होते हैं।",
      's3_t2':
          "बेलन: एक सपाट आयत में खुलता है, जिसके ऊपर दो गोलाकार आधार होते हैं।",
      's3_t3': "शंकु: एक वृत्ताकार आधार और एक चक्र के त्रिज्यखंड में खुलता है।",
      's3_hud':
          "उन्हें जोड़ने के लिए 3D ठोस पर क्लिक करें, फिर 2D जाल पर क्लिक करें।",
      'netCyl': "जाल: आयत + 2 वृत्त",
      'netCone': "जाल: वृत्त + त्रिज्यखंड",
      'netCube': "जाल: 6 आयत",
      's3_success':
          "बिल्कुल सही मिलान! बेलन एक आयत में खुलता है, और शंकु एक त्रिज्यखंड में खुलता है।",
      's3_fail':
          "आधारों को देखें। एक बेलन में दो वृत्ताकार आधार होते हैं। एक शंकु में केवल एक वृत्ताकार आधार होता है।",
      's4_t1':
          "एक सटीक जाल खींचने के लिए सटीक माप की आवश्यकता होती है। आइए एक वर्गाकार पिरामिड बनाएं।",
      's4_t2': "4cm भुजाओं वाला एक वर्गाकार आधार।",
      's4_t3': "ठीक 5cm की 'तिर्यक ऊंचाई' वाले चार त्रिकोणीय फलक।",
      's4_hud':
          "नियंत्रण बॉक्स में तिर्यक ऊंचाई को 5cm पर सेट करें। फलक जोड़ने के लिए 4 किनारों पर क्लिक करें।",
      'lblSlant': "तिर्यक ऊंचाई:",
      's4_success':
          "शानदार निर्माण! आपने तिर्यक ऊंचाई 5cm निर्धारित की और चार समान त्रिकोणीय फलक जोड़े।",
      's4_fail':
          "उपकरण सेटिंग्स जाँचें। पिरामिड के लिए ठीक 5 सेमी की तिर्यक ऊंचाई की आवश्यकता होती है।",
    },
  };
}

// --- Step 3 Line Drawing Painter ---
class MatchLinesPainter extends CustomPainter {
  final Map<String, String> matches;
  MatchLinesPainter(this.matches);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEAB308)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Define coordinates matching the Positioned widgets in Step 3
    final Map<String, Offset> points = {
      'solid_cyl': const Offset(110, 100),
      'solid_cone': const Offset(110, 280),
      'net_cone': const Offset(390, 60),
      'net_cube': const Offset(390, 190),
      'net_cyl': const Offset(390, 320),
    };

    Set<String> drawn = {};

    matches.forEach((key, value) {
      String pair = "${key}_$value";
      String reversePair = "${value}_$key";
      if (!drawn.contains(pair) && !drawn.contains(reversePair)) {
        if (points.containsKey(key) && points.containsKey(value)) {
          canvas.drawLine(points[key]!, points[value]!, paint);
          drawn.add(pair);
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant MatchLinesPainter oldDelegate) => true;
}

// --- Step 4 Triangle Painter ---
class TrianglePainter extends CustomPainter {
  final String edge;
  TrianglePainter(this.edge);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[400]!.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path = Path();
    if (edge == 'top') {
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (edge == 'bottom') {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    } else if (edge == 'left') {
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (edge == 'right') {
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Custom Painters for 3D Shapes ---
class ShapePainter extends CustomPainter {
  final String shape;
  ShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint facePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue[400]!.withOpacity(0.8);
    final Paint edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue[800]!
      ..strokeWidth = 2;
    final Paint lightFacePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue[300]!.withOpacity(0.9);

    switch (shape) {
      case 'cylinder3D':
        Rect topOval = Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.2),
          width: w * 0.6,
          height: h * 0.2,
        );
        Rect botOval = Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.8),
          width: w * 0.6,
          height: h * 0.2,
        );

        Path body = Path()
          ..moveTo(w * 0.2, h * 0.2)
          ..lineTo(w * 0.2, h * 0.8)
          ..arcTo(botOval, math.pi, math.pi, false)
          ..lineTo(w * 0.8, h * 0.2)
          ..close();
        canvas.drawPath(body, facePaint);
        canvas.drawOval(topOval, lightFacePaint);

        canvas.drawArc(botOval, 0, math.pi, false, edgePaint);
        canvas.drawOval(topOval, edgePaint);
        canvas.drawLine(
          Offset(w * 0.2, h * 0.2),
          Offset(w * 0.2, h * 0.8),
          edgePaint,
        );
        canvas.drawLine(
          Offset(w * 0.8, h * 0.2),
          Offset(w * 0.8, h * 0.8),
          edgePaint,
        );
        break;

      case 'cone3D':
        Rect baseOval = Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.8),
          width: w * 0.6,
          height: h * 0.2,
        );
        Path body = Path()
          ..moveTo(w * 0.2, h * 0.8)
          ..lineTo(w * 0.5, h * 0.1)
          ..lineTo(w * 0.8, h * 0.8)
          ..arcTo(baseOval, 0, math.pi, false)
          ..close();

        canvas.drawPath(body, facePaint);
        canvas.drawOval(baseOval, lightFacePaint);
        canvas.drawArc(baseOval, 0, math.pi, false, edgePaint);
        canvas.drawLine(
          Offset(w * 0.2, h * 0.8),
          Offset(w * 0.5, h * 0.1),
          edgePaint,
        );
        canvas.drawLine(
          Offset(w * 0.8, h * 0.8),
          Offset(w * 0.5, h * 0.1),
          edgePaint,
        );
        break;

      case 'netCyl':
        canvas.drawRect(
          Rect.fromLTWH(w * 0.2, h * 0.3, w * 0.6, h * 0.4),
          facePaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.2, h * 0.3, w * 0.6, h * 0.4),
          edgePaint,
        );
        canvas.drawCircle(Offset(w * 0.5, h * 0.15), w * 0.15, facePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.15), w * 0.15, edgePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.85), w * 0.15, facePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.85), w * 0.15, edgePaint);
        break;

      case 'netCone':
        Path sector = Path()
          ..moveTo(w * 0.5, h * 0.1)
          ..lineTo(w * 0.1, h * 0.6)
          ..arcToPoint(
            Offset(w * 0.9, h * 0.6),
            radius: Radius.circular(w * 0.4),
          )
          ..close();
        canvas.drawPath(sector, facePaint);
        canvas.drawPath(sector, edgePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.85), w * 0.15, facePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.85), w * 0.15, edgePaint);
        break;

      case 'netCube':
        double sq = w * 0.2;
        List<Offset> tops = [
          Offset(w * 0.4, h * 0.1),
          Offset(w * 0.2, h * 0.3),
          Offset(w * 0.4, h * 0.3),
          Offset(w * 0.6, h * 0.3),
          Offset(w * 0.8, h * 0.3),
          Offset(w * 0.4, h * 0.5),
        ];
        for (var t in tops) {
          canvas.drawRect(Rect.fromLTWH(t.dx, t.dy, sq, sq), facePaint);
          canvas.drawRect(Rect.fromLTWH(t.dx, t.dy, sq, sq), edgePaint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
