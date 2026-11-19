// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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
      home: const PrismsPyramidsScreen(),
    );
  }
}

class PrismsPyramidsScreen extends StatefulWidget {
  const PrismsPyramidsScreen({super.key});

  @override
  State<PrismsPyramidsScreen> createState() => _PrismsPyramidsScreenState();
}

class _PrismsPyramidsScreenState extends State<PrismsPyramidsScreen> {
  bool _isSidebarOpen = true;

  // Shutter screen state
  bool _showShutter = true;
  double _shutterOffset = 0;

  int _currentStep = 1;
  String _lang = 'en';

  // --- Step States ---

  // Step 1: Unfolding
  bool _unfoldedPrism = false;
  bool _unfoldedPyramid = false;

  // Step 2: Highlighting
  String? _highlighter; // 'rect' or 'tri'
  final Set<int> _prismHighlighted = {};
  final Set<int> _pyramidHighlighted = {};

  // Step 3: Naming
  Map<String, String> _step3Slots = {
    'pBase': '',
    'pLat': '',
    'pyrBase': '',
    'pyrLat': '',
  };

  // Step 4: Sorting
  final List<String> _binPrism = [];
  final List<String> _binPyramid = [];
  List<String> _availableItems = ['brick', 'tent', 'choc', 'egypt'];

  // Step 5: True/False
  String? _stampEval;

  // Feedback State
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
      if (type == 'click' || type == 'pop' || type == 'unfold') {
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

      _unfoldedPrism = false;
      _unfoldedPyramid = false;
      _highlighter = null;
      _prismHighlighted.clear();
      _pyramidHighlighted.clear();
      _step3Slots = {'pBase': '', 'pLat': '', 'pyrBase': '', 'pyrLat': ''};
      _binPrism.clear();
      _binPyramid.clear();
      _availableItems = ['brick', 'tent', 'choc', 'egypt'];
      _stampEval = null;

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
      if (_unfoldedPrism && _unfoldedPyramid) {
        success = true;
        msg = _t('s1_success');
      } else {
        success = false;
        msg = _t('s1_fail');
      }
    } else if (_currentStep == 2) {
      if (_prismHighlighted.length == 4 && _pyramidHighlighted.length == 4) {
        success = true;
        msg = _t('s2_success');
      } else if (_prismHighlighted.isNotEmpty ||
          _pyramidHighlighted.isNotEmpty) {
        success = false;
        msg = _t('s2_fail');
        needsReset = true;
      } else {
        success = false;
        msg = _t('plsComplete');
      }
    } else if (_currentStep == 3) {
      if (_step3Slots.values.every((v) => v.isNotEmpty)) {
        if (_step3Slots['pBase'] == 'hexagon' &&
            _step3Slots['pLat'] == 'rectangle' &&
            _step3Slots['pyrBase'] == 'hexagon' &&
            _step3Slots['pyrLat'] == 'triangle') {
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
      if (_binPrism.length + _binPyramid.length == 4) {
        if (_binPrism.contains('brick') &&
            _binPrism.contains('tent') &&
            _binPrism.contains('choc') &&
            _binPyramid.contains('egypt')) {
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
    } else if (_currentStep == 5) {
      if (_stampEval == 'true') {
        success = true;
        msg = _t('s5_success');
      } else if (_stampEval == 'false') {
        success = false;
        msg = _t('s5_fail');
        needsReset = true;
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
        if (_currentStep < 5) {
          if (mounted) {
            setState(() {
              _currentStep++;
              _setInitialFeedback();
            });
          }
        } else {
          _showSuccessPopup();
        }
      });
    } else {
      _playSound('error');
      if (needsReset) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted && !_isSuccess) {
            setState(() {
              if (_currentStep == 2) {
                _prismHighlighted.clear();
                _pyramidHighlighted.clear();
              } else if (_currentStep == 3) {
                _step3Slots = {
                  'pBase': '',
                  'pLat': '',
                  'pyrBase': '',
                  'pyrLat': '',
                };
              } else if (_currentStep == 4) {
                _binPrism.clear();
                _binPyramid.clear();
                _availableItems = ['brick', 'tent', 'choc', 'egypt'];
              } else if (_currentStep == 5) {
                _stampEval = null;
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

  // --- Handlers ---

  void _handleUnfoldDrop(String target) {
    _playSound('unfold');
    setState(() {
      if (target == 'prism') _unfoldedPrism = true;
      if (target == 'pyramid') _unfoldedPyramid = true;
    });
  }

  void _handleNetClick(String type, int faceIndex) {
    if (_currentStep != 2 || _highlighter == null) {
      if (_currentStep == 2 && _highlighter == null) {
        setState(() {
          _feedbackMessage = _t('s2_hlError');
          _isSuccess = false;
        });
        _playSound('error');
      }
      return;
    }

    _playSound('click');
    setState(() {
      if (type == 'prism') {
        if (_highlighter == 'rect' && faceIndex >= 2 && faceIndex <= 5) {
          _prismHighlighted.add(faceIndex);
        } else {
          _feedbackMessage = _t('s2_fail');
          _playSound('error');
        }
      } else if (type == 'pyramid') {
        if (_highlighter == 'tri' && faceIndex >= 1 && faceIndex <= 4) {
          _pyramidHighlighted.add(faceIndex);
        } else {
          _feedbackMessage = _t('s2_fail');
          _playSound('error');
        }
      }
    });
  }

  void _handleStep3Drop(String slot, String val) {
    _playSound('click');
    setState(() {
      _step3Slots[slot] = val;
    });
  }

  void _handleStep4Drop(String bin, String item) {
    _playSound('click');
    setState(() {
      _availableItems.remove(item);
      _binPrism.remove(item);
      _binPyramid.remove(item);

      if (bin == 'prism') _binPrism.add(item);
      if (bin == 'pyramid') _binPyramid.add(item);
    });
  }

  void _handleStep5Select(String val) {
    _playSound('click');
    setState(() {
      _stampEval = val;
    });
    // Auto-verify on selection
    Future.delayed(const Duration(milliseconds: 100), _verifyTask);
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _buildWorkspaceGraphics(),
                                ),
                                // If sidebar is closed, render compact interactive controls right on the canvas
                                if (!_isSidebarOpen) ...[
                                  const SizedBox(height: 32),
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 800,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0F172A,
                                      ).withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF334155),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: _buildControlsAndVerify(),
                                  ),
                                ],
                              ],
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
                      if (_isSidebarOpen)
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
                              _t('enter'),
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
        if (_currentStep != 5) // Step 5 auto-verifies
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
            const SizedBox(height: 8),
            Text(
              _t('s1_t4'),
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
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('s5_t1'),
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DragTarget<String>(
              onAcceptWithDetails: (d) => _handleUnfoldDrop('prism'),
              builder: (ctx, cd, rd) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cd.isNotEmpty ? Colors.white10 : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cd.isNotEmpty
                        ? const Color(0xFFEAB308)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 250,
                      height: 300,
                      child: CustomPaint(
                        painter: PrismNetPainter(isUnfolded: _unfoldedPrism),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _t('prism'),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 40),
            DragTarget<String>(
              onAcceptWithDetails: (d) => _handleUnfoldDrop('pyramid'),
              builder: (ctx, cd, rd) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cd.isNotEmpty ? Colors.white10 : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cd.isNotEmpty
                        ? const Color(0xFFEAB308)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 250,
                      height: 300,
                      child: CustomPaint(
                        painter: PyramidNetPainter(
                          isUnfolded: _unfoldedPyramid,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _t('pyramid'),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTapDown: (details) {
                    final Size size = const Size(250, 300);
                    double x = (details.localPosition.dx / size.width) * 100;
                    double y = (details.localPosition.dy / size.height) * 100;

                    List<Path> paths = PrismNetPainter(
                      isUnfolded: true,
                    ).getPaths();
                    for (int i = 0; i < paths.length; i++) {
                      if (paths[i].contains(Offset(x, y))) {
                        _handleNetClick('prism', i);
                        break;
                      }
                    }
                  },
                  child: SizedBox(
                    width: 250,
                    height: 300,
                    child: CustomPaint(
                      painter: PrismNetPainter(
                        isUnfolded: true,
                        highlightedFaces: _prismHighlighted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('prism'),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              children: [
                GestureDetector(
                  onTapDown: (details) {
                    final Size size = const Size(250, 300);
                    double x = (details.localPosition.dx / size.width) * 100;
                    double y = (details.localPosition.dy / size.height) * 100;

                    List<Path> paths = PyramidNetPainter(
                      isUnfolded: true,
                    ).getPaths();
                    for (int i = 0; i < paths.length; i++) {
                      if (paths[i].contains(Offset(x, y))) {
                        _handleNetClick('pyramid', i);
                        break;
                      }
                    }
                  },
                  child: SizedBox(
                    width: 250,
                    height: 300,
                    child: CustomPaint(
                      painter: PyramidNetPainter(
                        isUnfolded: true,
                        highlightedFaces: _pyramidHighlighted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('pyramid'),
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        );
      case 3:
        return Wrap(
          spacing: 40,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _buildStep3Card(
              'p',
              'hexPrism',
              _t('s3_hexPrism'),
              Colors.blueAccent,
            ),
            _buildStep3Card(
              'pyr',
              'hexPyramid',
              _t('s3_hexPyr'),
              Colors.orangeAccent,
            ),
          ],
        );
      case 4:
        return Wrap(
          spacing: 40,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _buildStep4Bin(
              'prism',
              _t('prismBin'),
              Colors.blueAccent,
              _binPrism,
            ),
            _buildStep4Bin(
              'pyramid',
              _t('pyrBin'),
              Colors.orangeAccent,
              _binPyramid,
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            Text(
              _t('stmtCube'),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              width: 300,
              height: 300,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white30, width: 4),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: SimpleShapePainter('cube'),
                  ),
                  if (_stampEval != null)
                    Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _stampEval == 'true'
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 10),
                          ],
                        ),
                        child: Text(
                          _stampEval == 'true'
                              ? _t('trueStamp')
                              : _t('falseStamp'),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep3Card(
    String prefix,
    String shapeType,
    String title,
    Color color,
  ) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border(top: BorderSide(color: color, width: 4)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 150,
            height: 180,
            child: CustomPaint(painter: SimpleShapePainter(shapeType)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          _buildStep3Slot('${prefix}Base', _t('lblBase')),
          const SizedBox(height: 12),
          _buildStep3Slot('${prefix}Lat', _t('lblLateral')),
        ],
      ),
    );
  }

  Widget _buildStep3Slot(String target, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        DragTarget<String>(
          onAcceptWithDetails: (d) => _handleStep3Drop(target, d.data),
          builder: (ctx, cd, rd) {
            String slotVal = _step3Slots[target] ?? '';
            bool hasItem = slotVal.isNotEmpty;
            String displayStr = '';
            if (hasItem) {
              displayStr = _t(
                'shape${slotVal[0].toUpperCase()}${slotVal.substring(1)}',
              );
            }

            return Container(
              width: 140,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasItem ? Colors.transparent : Colors.black26,
                border: Border.all(
                  color: hasItem
                      ? const Color(0xFFEAB308)
                      : (cd.isNotEmpty
                            ? const Color(0xFFEAB308)
                            : Colors.white30),
                  width: hasItem || cd.isNotEmpty ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: hasItem
                  ? Text(
                      displayStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep4Bin(
    String type,
    String title,
    Color color,
    List<String> items,
  ) {
    return DragTarget<String>(
      onAcceptWithDetails: (d) => _handleStep4Drop(type, d.data),
      builder: (ctx, cd, rd) => Container(
        width: 320,
        decoration: BoxDecoration(
          color: color.withOpacity(cd.isNotEmpty ? 0.2 : 0.1),
          border: Border.all(
            color: cd.isNotEmpty ? const Color(0xFFEAB308) : color,
            width: cd.isNotEmpty ? 4 : 4,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: items.map((i) => _buildObjectItem(i)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectItem(String type) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(painter: ObjectPainter(type)),
        ),
        const SizedBox(height: 8),
        Text(
          _t(type),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
      ],
    );
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
            Draggable<String>(
              data: 'unfold',
              feedback: const Material(
                color: Colors.transparent,
                child: Icon(
                  Icons.auto_fix_high,
                  color: Color(0xFFEAB308),
                  size: 48,
                ),
              ),
              childWhenDragging: const Opacity(
                opacity: 0.3,
                child: _UnfoldWand(),
              ),
              onDragStarted: () => _playSound('click'),
              child: const _UnfoldWand(),
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _playSound('pop');
                      setState(() {
                        _highlighter = 'rect';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                        border: _highlighter == 'rect'
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _t('shapeRect'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _playSound('pop');
                      setState(() {
                        _highlighter = 'tri';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(12),
                        border: _highlighter == 'tri'
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _t('shapeTri'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "${_prismHighlighted.length} / 4",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_pyramidHighlighted.length} / 4",
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            Text(
              _t('s3_dragHint'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildDraggableTag('hexagon', Colors.indigoAccent),
            const SizedBox(height: 12),
            _buildDraggableTag('rectangle', Colors.blueAccent),
            const SizedBox(height: 12),
            _buildDraggableTag('triangle', Colors.orangeAccent),
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
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _availableItems
                  .map(
                    (i) => Draggable<String>(
                      data: i,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildObjectItem(i),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildObjectItem(i),
                      ),
                      onDragStarted: () => _playSound('click'),
                      child: _buildObjectItem(i),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            Text(
              _t('s5_hud'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleStep5Select('true'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.2),
                      side: const BorderSide(color: Colors.green, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _t('trueStamp'),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleStep5Select('false'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.2),
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _t('falseStamp'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDraggableTag(String key, Color color) {
    Widget tag = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text(
        _t('shape${key[0].toUpperCase()}${key.substring(1)}'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );

    return Draggable<String>(
      data: key,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 250, child: Opacity(opacity: 0.9, child: tag)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: tag),
      onDragStarted: () => _playSound('click'),
      child: tag,
    );
  }

  // Multi-Language Dictionary
  static const Map<String, Map<String, String>> _i18n = {
    'en': {
      'subtitle': "Class 8 • Exploring some Geometric Themes",
      'enter': "ENTER LAB",
      'title': "Prisms vs. Pyramids",
      'teacher': "Teacher Board",
      'init':
          "Ready! Read the Teacher Board and use the interactive tools to solve the problem.",
      'verify': "Verify Task",
      'congrats': "Congratulations!",
      'congratsMsg': "You have mastered the properties of Prisms and Pyramids!",
      'restart': "Restart",
      'plsComplete': "Please complete the interactions before verifying.",
      'tryAgain': "Try Again",
      'missionObj': "Mission Objective",
      'proceduralSteps': "Procedural Steps",
      's1_t1':
          "A Prism is a polyhedron with two identical, parallel bases. All its other faces (lateral faces) are parallelograms (usually rectangles).",
      's1_t2':
          "A Pyramid is a polyhedron with only one base. All its lateral faces are triangles that meet at a single common point (the apex).",
      's1_t3': "Let's uncover their secret identities!",
      's1_t4':
          "Drag the 'Unfold' wand to both the Prism and Pyramid models to see their flat nets.",
      's1_hud': "Drag the wand to both shapes to unfold them.",
      's1_success': "Great! The 3D shapes have unfolded into their 2D nets.",
      's1_fail': "Unfold both shapes to continue.",
      'prism': "Prism",
      'pyramid': "Pyramid",
      's2_t1': "Look closely at the unfolded nets.",
      's2_t2': "Prisms and Pyramids are named by the shape of their base(s).",
      's2_t3': "But their lateral (side) faces are always consistent!",
      's2_hud':
          "Select a highlighter tool, then click the 4 lateral faces on each net to highlight them.",
      'shapeRect': "Rectangular Faces Tool",
      'shapeTri': "Triangular Faces Tool",
      's2_hlError': "Select a highlighter tool first!",
      's2_success':
          "Spot on! Prisms ALWAYS have rectangular lateral faces. Pyramids ALWAYS have triangular lateral faces.",
      's2_fail':
          "Incorrect face or wrong tool. Prisms = Rectangles, Pyramids = Triangles.",
      's3_t1':
          "Let's apply our rule to name the parts of these specific hexagonal shapes.",
      's3_dragHint':
          "Drag the correct shape names to the Base and Lateral Face slots.",
      'lblBase': "Base Shape:",
      'lblLateral': "Lateral Shape:",
      's3_hexPrism': "Hexagonal Prism",
      's3_hexPyr': "Hexagonal Pyramid",
      'shapeHexagon': "Hexagon",
      'shapeRectangle': "Rectangle",
      'shapeTriangle': "Triangle",
      's3_success':
          "Perfect! Both have hexagonal bases, but the prism's sides are rectangles and the pyramid's are triangles.",
      's3_fail':
          "Review the rules! Prisms have rectangular sides, Pyramids have triangular sides.",
      's4_t1': "Let's look at some real-world objects.",
      's4_t2':
          "A brick has rectangular bases. A tent has triangular bases. A Toblerone has triangular bases.",
      's4_t3': "The Great Pyramid has a square base.",
      's4_hud': "Drag each object into the correct bin.",
      'prismBin': "PRISMS",
      'pyrBin': "PYRAMIDS",
      'brick': "Brick",
      'tent': "Camping Tent",
      'choc': "Chocolate Bar",
      'egypt': "Great Pyramid",
      's4_success':
          "Excellent sorting! A tent and Toblerone are Triangular Prisms. The brick is a Rectangular Prism.",
      's4_fail':
          "Think about the lateral faces. Do they meet at a point (Pyramid) or connect two identical bases (Prism)?",
      's5_t1': "Final Concept Check.",
      's5_hud': "Read the statement and select True or False.",
      'stmtCube':
          "A cube is a special type of rectangular prism where all faces are squares.",
      'trueStamp': "TRUE",
      'falseStamp': "FALSE",
      's5_success':
          "Correct! A cube has two identical square bases connected by square lateral faces, fulfilling all prism requirements.",
      's5_fail':
          "Incorrect! Think about the definition of a prism. Does a cube have two identical parallel bases?",
    },
    'hi': {
      'subtitle': "कक्षा 8 • कुछ ज्यामितीय विषयों का अन्वेषण",
      'enter': "प्रयोगशाला में प्रवेश करें",
      'title': "प्रिज्म बनाम पिरामिड",
      'teacher': "शिक्षक बोर्ड",
      'init':
          "तैयार! शिक्षक बोर्ड पढ़ें और समस्या को हल करने के लिए उपकरणों का उपयोग करें।",
      'verify': "सत्यापित करें",
      'congrats': "बधाई हो!",
      'congratsMsg':
          "आपने प्रिज्म और पिरामिड के गुणों में सफलतापूर्वक महारत हासिल कर ली है!",
      'restart': "Restart",
      'plsComplete': "कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।",
      'tryAgain': "पुनः प्रयास करें",
      'missionObj': "मिशन का उद्देश्य",
      'proceduralSteps': "प्रक्रियात्मक चरण",
      's1_t1':
          "प्रिज्म एक बहुफलक है जिसके दो समान, समानांतर आधार होते हैं। इसके अन्य सभी फलक (पार्श्व फलक) समानांतर चतुर्भुज (आमतौर पर आयत) होते हैं।",
      's1_t2':
          "पिरामिड एक बहुफलक है जिसका केवल एक आधार होता है। इसके सभी पार्श्व फलक त्रिकोण होते हैं जो एक सामान्य बिंदु (शीर्ष) पर मिलते हैं।",
      's1_t3': "आइए उनकी गुप्त पहचान उजागर करें!",
      's1_t4':
          "प्रिज्म और पिरामिड मॉडल दोनों के सपाट जाल देखने के लिए 'अनफोल्ड' छड़ी को खींचें।",
      's1_hud': "उन्हें खोलने के लिए छड़ी को दोनों आकृतियों पर खींचें।",
      's1_success': "महान! 3D आकृतियां उनके 2D जाल में खुल गई हैं।",
      's1_fail': "जारी रखने के लिए दोनों आकृतियों को खोलें।",
      'prism': "प्रिज्म",
      'pyramid': "पिरामिड",
      's2_t1': "खुले हुए जालों को ध्यान से देखें।",
      's2_t2': "प्रिज्म और पिरामिड का नाम उनके आधार के आकार से रखा जाता है।",
      's2_t3': "लेकिन उनके पार्श्व (किनारे) फलक हमेशा सुसंगत होते हैं!",
      's2_hud':
          "एक हाइलाइटर उपकरण का चयन करें, फिर उन्हें हाइलाइट करने के लिए प्रत्येक जाल पर 4 पार्श्व फलकों पर क्लिक करें।",
      'shapeRect': "आयताकार उपकरण",
      'shapeTri': "त्रिकोणीय उपकरण",
      's2_hlError': "पहले एक हाइलाइटर टूल चुनें!",
      's2_success':
          "बिल्कुल सही! प्रिज्म में हमेशा आयताकार पार्श्व फलक होते हैं। पिरामिड में हमेशा त्रिकोणीय पार्श्व फलक होते हैं।",
      's2_fail': "गलत फलक या गलत टूल। प्रिज्म = आयत, पिरामिड = त्रिकोण।",
      's3_t1': "आइए इन विशिष्ट षट्कोणीय आकृतियों के भागों का नामकरण करें।",
      's3_dragHint':
          "सही आकार के नामों को आधार और पार्श्व फलक स्लॉट पर खींचें।",
      'lblBase': "आधार आकार:",
      'lblLateral': "पार्श्व आकार:",
      's3_hexPrism': "षट्कोणीय प्रिज्म",
      's3_hexPyr': "षट्कोणीय पिरामिड",
      'shapeHexagon': "षट्कोण",
      'shapeRectangle': "आयत",
      'shapeTriangle': "त्रिकोण",
      's3_success':
          "उत्तम! दोनों के आधार षट्कोणीय हैं, लेकिन प्रिज्म के किनारे आयत हैं और पिरामिड के किनारे त्रिकोण हैं।",
      's3_fail':
          "नियमों की समीक्षा करें! प्रिज्म में आयताकार किनारे होते हैं, पिरामिड में त्रिकोणीय किनारे होते हैं।",
      's4_t1': "आइए कुछ वास्तविक दुनिया की वस्तुओं को देखें।",
      's4_t2':
          "एक ईंट के आयताकार आधार होते हैं। एक तंबू के त्रिकोणीय आधार होते हैं।",
      's4_t3': "महान पिरामिड का आधार वर्गाकार है।",
      's4_hud': "प्रत्येक वस्तु को सही बिन में खींचें।",
      'prismBin': "प्रिज्म",
      'pyrBin': "पिरामिड",
      'brick': "ईंट",
      'tent': "तंबू",
      'choc': "चॉकलेट",
      'egypt': "महान पिरामिड",
      's4_success':
          "उत्कृष्ट छँटाई! एक तंबू और टोबलरोन त्रिकोणीय प्रिज्म हैं। ईंट एक आयताकार प्रिज्म है।",
      's4_fail':
          "पार्श्व फलकों के बारे में सोचें। क्या वे एक बिंदु (पिरामिड) पर मिलते हैं?",
      's5_t1': "अंतिम अवधारणा जांच।",
      's5_hud': "कथन पढ़ें और सही या गलत चुनें।",
      'stmtCube':
          "एक घन एक विशेष प्रकार का आयताकार प्रिज्म है जिसके सभी फलक वर्ग होते हैं।",
      'trueStamp': "सही",
      'falseStamp': "गलत",
      's5_success':
          "सही! एक घन में वर्ग पार्श्व फलकों द्वारा जुड़े दो समान वर्गाकार आधार होते हैं।",
      's5_fail':
          "गलत! प्रिज्म की परिभाषा के बारे में सोचें। क्या एक घन के दो समान समानांतर आधार होते हैं?",
    },
  };
}

class _UnfoldWand extends StatelessWidget {
  const _UnfoldWand();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.indigoAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.auto_fix_high, color: Color(0xFFEAB308)),
          SizedBox(width: 12),
          Text(
            "UNFOLD",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Painters ---

class PrismNetPainter extends CustomPainter {
  final bool isUnfolded;
  final Set<int> highlightedFaces;

  PrismNetPainter({required this.isUnfolded, this.highlightedFaces = const {}});

  List<Path> getPaths() {
    return [
      Path()
        ..moveTo(40, 0)
        ..lineTo(60, 0)
        ..lineTo(60, 20)
        ..lineTo(40, 20)
        ..close(), // 0 Top Base
      Path()
        ..moveTo(40, 80)
        ..lineTo(60, 80)
        ..lineTo(60, 100)
        ..lineTo(40, 100)
        ..close(), // 1 Bot Base
      Path()
        ..moveTo(0, 20)
        ..lineTo(20, 20)
        ..lineTo(20, 80)
        ..lineTo(0, 80)
        ..close(), // 2 Lat
      Path()
        ..moveTo(20, 20)
        ..lineTo(40, 20)
        ..lineTo(40, 80)
        ..lineTo(20, 80)
        ..close(), // 3 Lat
      Path()
        ..moveTo(40, 20)
        ..lineTo(60, 20)
        ..lineTo(60, 80)
        ..lineTo(40, 80)
        ..close(), // 4 Lat
      Path()
        ..moveTo(60, 20)
        ..lineTo(80, 20)
        ..lineTo(80, 80)
        ..lineTo(60, 80)
        ..close(), // 5 Lat
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 100;
    final double sy = size.height / 100;
    canvas.scale(sx, sy);

    final facePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue[400]!.withOpacity(0.2);
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue[600]!
      ..strokeWidth = 1.5;
    final basePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green[400]!.withOpacity(0.3);
    final hlPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFEAB308).withOpacity(0.6);

    if (!isUnfolded) {
      // 3D Prism
      Path p1 = Path()
        ..moveTo(30, 20)
        ..lineTo(70, 10)
        ..lineTo(90, 20)
        ..lineTo(50, 30)
        ..close();
      Path p2 = Path()
        ..moveTo(30, 20)
        ..lineTo(50, 30)
        ..lineTo(50, 90)
        ..lineTo(30, 80)
        ..close();
      Path p3 = Path()
        ..moveTo(50, 30)
        ..lineTo(90, 20)
        ..lineTo(90, 80)
        ..lineTo(50, 90)
        ..close();
      canvas.drawPath(p1, basePaint);
      canvas.drawPath(p1, edgePaint);
      canvas.drawPath(p2, facePaint);
      canvas.drawPath(p2, edgePaint);
      canvas.drawPath(p3, facePaint);
      canvas.drawPath(p3, edgePaint);
    } else {
      // Net
      List<Path> paths = getPaths();
      for (int i = 0; i < paths.length; i++) {
        if (i < 2) {
          canvas.drawPath(paths[i], basePaint);
        } else {
          canvas.drawPath(
            paths[i],
            highlightedFaces.contains(i) ? hlPaint : facePaint,
          );
        }
        canvas.drawPath(
          paths[i],
          edgePaint..strokeWidth = highlightedFaces.contains(i) ? 3 : 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PrismNetPainter old) =>
      isUnfolded != old.isUnfolded || highlightedFaces != old.highlightedFaces;
}

class PyramidNetPainter extends CustomPainter {
  final bool isUnfolded;
  final Set<int> highlightedFaces;

  PyramidNetPainter({
    required this.isUnfolded,
    this.highlightedFaces = const {},
  });

  List<Path> getPaths() {
    return [
      Path()
        ..moveTo(40, 40)
        ..lineTo(60, 40)
        ..lineTo(60, 60)
        ..lineTo(40, 60)
        ..close(), // 0 Base
      Path()
        ..moveTo(40, 40)
        ..lineTo(60, 40)
        ..lineTo(50, 10)
        ..close(), // 1 Top Tri
      Path()
        ..moveTo(40, 60)
        ..lineTo(60, 60)
        ..lineTo(50, 90)
        ..close(), // 2 Bot Tri
      Path()
        ..moveTo(40, 40)
        ..lineTo(40, 60)
        ..lineTo(10, 50)
        ..close(), // 3 L Tri
      Path()
        ..moveTo(60, 40)
        ..lineTo(60, 60)
        ..lineTo(90, 50)
        ..close(), // 4 R Tri
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 100;
    final double sy = size.height / 100;
    canvas.scale(sx, sy);

    final facePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue[400]!.withOpacity(0.2);
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue[600]!
      ..strokeWidth = 1.5;
    final basePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green[400]!.withOpacity(0.3);
    final hlPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFEAB308).withOpacity(0.6);

    if (!isUnfolded) {
      Path p1 = Path()
        ..moveTo(50, 20)
        ..lineTo(20, 80)
        ..lineTo(55, 90)
        ..close();
      Path p2 = Path()
        ..moveTo(50, 20)
        ..lineTo(55, 90)
        ..lineTo(90, 75)
        ..close();
      canvas.drawPath(p1, facePaint);
      canvas.drawPath(p1, edgePaint);
      canvas.drawPath(p2, facePaint);
      canvas.drawPath(p2, edgePaint);
    } else {
      List<Path> paths = getPaths();
      canvas.drawPath(paths[0], basePaint);
      canvas.drawPath(paths[0], edgePaint);
      for (int i = 1; i < paths.length; i++) {
        canvas.drawPath(
          paths[i],
          highlightedFaces.contains(i) ? hlPaint : facePaint,
        );
        canvas.drawPath(
          paths[i],
          edgePaint..strokeWidth = highlightedFaces.contains(i) ? 3 : 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PyramidNetPainter old) =>
      isUnfolded != old.isUnfolded || highlightedFaces != old.highlightedFaces;
}

class SimpleShapePainter extends CustomPainter {
  final String shape;
  SimpleShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 100;
    final double sy = size.height / 100;
    canvas.scale(sx, sy);

    final faceP = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue[400]!.withOpacity(0.2);
    final edgeP = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue[600]!
      ..strokeWidth = 1.5;
    final baseP = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green[400]!.withOpacity(0.3);

    if (shape == 'hexPrism') {
      Path base = Path()
        ..moveTo(50, 10)
        ..lineTo(75, 20)
        ..lineTo(75, 30)
        ..lineTo(50, 40)
        ..lineTo(25, 30)
        ..lineTo(25, 20)
        ..close();
      canvas.drawPath(base, baseP);
      canvas.drawPath(base, edgeP);
      List<Path> faces = [
        Path()
          ..moveTo(25, 30)
          ..lineTo(50, 40)
          ..lineTo(50, 90)
          ..lineTo(25, 80)
          ..close(),
        Path()
          ..moveTo(50, 40)
          ..lineTo(75, 30)
          ..lineTo(75, 80)
          ..lineTo(50, 90)
          ..close(),
        Path()
          ..moveTo(25, 20)
          ..lineTo(25, 30)
          ..lineTo(25, 80)
          ..lineTo(25, 70)
          ..close(),
        Path()
          ..moveTo(75, 20)
          ..lineTo(75, 30)
          ..lineTo(75, 80)
          ..lineTo(75, 70)
          ..close(),
      ];
      for (var p in faces) {
        canvas.drawPath(p, faceP);
        canvas.drawPath(p, edgeP);
      }
    } else if (shape == 'hexPyramid') {
      List<Path> faces = [
        Path()
          ..moveTo(50, 10)
          ..lineTo(25, 70)
          ..lineTo(50, 90)
          ..close(),
        Path()
          ..moveTo(50, 10)
          ..lineTo(50, 90)
          ..lineTo(75, 70)
          ..close(),
        Path()
          ..moveTo(50, 10)
          ..lineTo(15, 60)
          ..lineTo(25, 70)
          ..close(),
        Path()
          ..moveTo(50, 10)
          ..lineTo(75, 70)
          ..lineTo(85, 60)
          ..close(),
      ];
      for (var p in faces) {
        canvas.drawPath(p, faceP);
        canvas.drawPath(p, edgeP);
      }
    } else if (shape == 'cube') {
      Path top = Path()
        ..moveTo(50, 15)
        ..lineTo(85, 35)
        ..lineTo(50, 55)
        ..lineTo(15, 35)
        ..close();
      Path left = Path()
        ..moveTo(15, 35)
        ..lineTo(50, 55)
        ..lineTo(50, 95)
        ..lineTo(15, 75)
        ..close();
      Path right = Path()
        ..moveTo(50, 55)
        ..lineTo(85, 35)
        ..lineTo(85, 75)
        ..lineTo(50, 95)
        ..close();
      canvas.drawPath(top, baseP);
      canvas.drawPath(top, edgeP);
      canvas.drawPath(left, faceP);
      canvas.drawPath(left, edgeP);
      canvas.drawPath(right, faceP);
      canvas.drawPath(right, edgeP);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class ObjectPainter extends CustomPainter {
  final String type;
  ObjectPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 100;
    final double sy = size.height / 100;
    canvas.scale(sx, sy);

    if (type == 'brick') {
      canvas.drawPath(
        Path()
          ..moveTo(10, 40)
          ..lineTo(50, 20)
          ..lineTo(90, 40)
          ..lineTo(50, 60)
          ..close(),
        Paint()..color = Colors.red[700]!,
      );
      canvas.drawPath(
        Path()
          ..moveTo(10, 40)
          ..lineTo(50, 60)
          ..lineTo(50, 90)
          ..lineTo(10, 70)
          ..close(),
        Paint()..color = Colors.red[800]!,
      );
      canvas.drawPath(
        Path()
          ..moveTo(50, 60)
          ..lineTo(90, 40)
          ..lineTo(90, 70)
          ..lineTo(50, 90)
          ..close(),
        Paint()..color = Colors.red[900]!,
      );
      Path lines = Path()
        ..moveTo(10, 40)
        ..lineTo(50, 20)
        ..lineTo(90, 40)
        ..moveTo(10, 50)
        ..lineTo(50, 70)
        ..lineTo(90, 50)
        ..moveTo(10, 60)
        ..lineTo(50, 80)
        ..lineTo(90, 60)
        ..moveTo(50, 60)
        ..lineTo(50, 90)
        ..moveTo(30, 50)
        ..lineTo(30, 80)
        ..moveTo(70, 50)
        ..lineTo(70, 80);
      canvas.drawPath(
        lines,
        Paint()
          ..color = Colors.red[200]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    } else if (type == 'tent') {
      canvas.drawPath(
        Path()
          ..moveTo(50, 15)
          ..lineTo(10, 85)
          ..lineTo(45, 95)
          ..close(),
        Paint()..color = Colors.green[600]!,
      );
      canvas.drawPath(
        Path()
          ..moveTo(50, 15)
          ..lineTo(45, 95)
          ..lineTo(90, 80)
          ..lineTo(80, 10)
          ..close(),
        Paint()..color = Colors.green[700]!,
      );
      canvas.drawPath(
        Path()
          ..moveTo(50, 15)
          ..lineTo(30, 90)
          ..lineTo(45, 95)
          ..close(),
        Paint()..color = Colors.green[900]!,
      );
      Path lines = Path()
        ..moveTo(50, 15)
        ..lineTo(10, 85)
        ..moveTo(50, 15)
        ..lineTo(45, 95)
        ..moveTo(50, 15)
        ..lineTo(80, 10)
        ..moveTo(45, 95)
        ..lineTo(90, 80);
      canvas.drawPath(
        lines,
        Paint()
          ..color = Colors.green[400]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else if (type == 'egypt') {
      canvas.drawPath(
        Path()
          ..moveTo(50, 10)
          ..lineTo(15, 80)
          ..lineTo(55, 90)
          ..close(),
        Paint()..color = const Color(0xFFEAB308),
      );
      canvas.drawPath(
        Path()
          ..moveTo(50, 10)
          ..lineTo(55, 90)
          ..lineTo(90, 75)
          ..close(),
        Paint()..color = Colors.yellow[700]!,
      );
      Path lines = Path()
        ..moveTo(32, 45)
        ..lineTo(52, 50)
        ..lineTo(72, 42)
        ..moveTo(24, 62)
        ..lineTo(53, 70)
        ..lineTo(81, 58)
        ..moveTo(18, 74)
        ..lineTo(54, 83)
        ..lineTo(87, 69)
        ..moveTo(50, 10)
        ..lineTo(55, 90);
      canvas.drawPath(
        lines,
        Paint()
          ..color = Colors.yellow[900]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    } else if (type == 'choc') {
      canvas.drawPath(
        Path()
          ..moveTo(20, 30)
          ..lineTo(10, 70)
          ..lineTo(30, 80)
          ..close(),
        Paint()..color = Colors.brown[600]!,
      );
      canvas.drawPath(
        Path()
          ..moveTo(20, 30)
          ..lineTo(30, 80)
          ..lineTo(90, 60)
          ..lineTo(80, 10)
          ..close(),
        Paint()..color = Colors.brown[700]!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
