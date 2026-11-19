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
      home: const EulerLabScreen(),
    );
  }
}

class EulerLabScreen extends StatefulWidget {
  const EulerLabScreen({super.key});

  @override
  State<EulerLabScreen> createState() => _EulerLabScreenState();
}

class _EulerLabScreenState extends State<EulerLabScreen> {
  bool _isSidebarOpen = true;

  // Shutter screen state
  bool _showShutter = true;
  double _shutterOffset = 0;

  int _currentStep = 1;
  String _lang = 'en';

  // State variables for interactions
  Map<String, String> _droppedItems = {};

  // Text Controllers for inputs
  final TextEditingController _pyrF = TextEditingController();
  final TextEditingController _pyrV = TextEditingController();
  final TextEditingController _pyrE = TextEditingController();
  final TextEditingController _pyrR = TextEditingController();
  final TextEditingController _priF = TextEditingController();
  final TextEditingController _priV = TextEditingController();
  final TextEditingController _priE = TextEditingController();
  final TextEditingController _priR = TextEditingController();
  final TextEditingController _finalV = TextEditingController();

  bool _isUnlocked = false;
  String _feedbackMessage = "";
  bool _isSuccess = false;

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

    _pyrF.dispose();
    _pyrV.dispose();
    _pyrE.dispose();
    _pyrR.dispose();
    _priF.dispose();
    _priV.dispose();
    _priE.dispose();
    _priR.dispose();
    _finalV.dispose();

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
      _pyrF.clear();
      _pyrV.clear();
      _pyrE.clear();
      _pyrR.clear();
      _priF.clear();
      _priV.clear();
      _priE.clear();
      _priR.clear();
      _finalV.clear();
      _isUnlocked = false;
      _setInitialFeedback();
      _shutterOffset = 0;
      _showShutter = true;
      _isSidebarOpen = true;
    });
  }

  void _verifyTask() {
    bool success = false;
    String msg = "";

    if (_currentStep == 1) {
      if (_droppedItems['cube_f'] == '6' &&
          _droppedItems['cube_v'] == '8' &&
          _droppedItems['cube_e'] == '12' &&
          _droppedItems['tetra_f'] == '4' &&
          _droppedItems['tetra_v'] == '4' &&
          _droppedItems['tetra_e'] == '6') {
        success = true;
        msg = _t('s1_success');
      } else {
        success = false;
        msg = _t('s1_fail');
        if (_droppedItems.isNotEmpty) {
          _droppedItems.clear();
        }
      }
    } else if (_currentStep == 2) {
      if (_droppedItems['op1'] == '+' && _droppedItems['op2'] == '-') {
        success = true;
        msg = _t('s2_success');
      } else {
        success = false;
        msg = _t('s2_fail');
        _droppedItems.clear();
      }
    } else if (_currentStep == 3) {
      if (_droppedItems['cyl_stamp'] == _t('notPolyStamp')) {
        success = true;
        msg = _t('s3_success');
      } else {
        success = false;
        msg = _t('s3_fail');
        _droppedItems.clear();
      }
    } else if (_currentStep == 4) {
      if (_pyrF.text == '5' &&
          _pyrV.text == '5' &&
          _pyrE.text == '8' &&
          _pyrR.text == '2' &&
          _priF.text == '7' &&
          _priV.text == '10' &&
          _priE.text == '15' &&
          _priR.text == '2') {
        success = true;
        msg = _t('s4_success');
      } else {
        success = false;
        msg = _t('s4_fail');
      }
    } else if (_currentStep == 5) {
      if (_finalV.text == '12') {
        success = true;
        msg = _t('s5_success');
        setState(() {
          _isUnlocked = true;
        });
      } else {
        success = false;
        msg = _t('s5_fail');
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
          setState(() {
            _currentStep++;
            _droppedItems.clear();
            _setInitialFeedback();
          });
        } else {
          _showSuccessPopup();
        }
      });
    } else {
      _playSound('error');
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.38;
    if (sidebarWidth < 340) sidebarWidth = 340;

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
                                      maxWidth: 600,
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

            // --- Left Sidebar ---
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints
                              .maxHeight, // Ensures IntrinsicHeight can expand
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 64,
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // --- TITLE AND SUBTITLE ---
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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

                                // --- LANGUAGE & RESTART ACTIONS ---
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
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
                                        backgroundColor: Colors.redAccent
                                            .withOpacity(0.8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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

                                // --- TEACHER CONTENT ---
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
                                      border: Border.all(
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                    child: _buildControlsAndVerify(),
                                  ),

                                // --- FOOTER (Pushed to bottom) ---
                                const Expanded(
                                  child: SizedBox(height: 32),
                                ), // Acts as Spacer inside IntrinsicHeight
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
                    );
                  },
                ),
              ),
            ),

            // Top-Left Menu Button (Floating Z-Index Front so it stays visible on canvas when sidebar closes)
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

            // --- Original Shutter Screen ---
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
          icon: Icon(
            _currentStep == 5 ? Icons.lock_open : Icons.check_circle,
            color: Colors.black,
          ),
          label: Text(
            _currentStep == 5 ? _t('unlock') : _t('verify'),
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
            const SizedBox(height: 12),
            Text(
              _t('proceduralSteps'),
              style: const TextStyle(
                color: Color(0xFFEAB308),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _richText(_t('faces'), _t('s1_t2'), Colors.greenAccent),
            _richText(_t('edges'), _t('s1_t3'), Colors.lightBlueAccent),
            _richText(_t('vertices'), _t('s1_t4'), Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _t('s1_t5'),
              style: const TextStyle(fontSize: 15, color: Colors.white70),
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
            const SizedBox(height: 12),
            Text(
              _t('proceduralSteps'),
              style: const TextStyle(
                color: Color(0xFFEAB308),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _t('s2_t4'),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            const SizedBox(height: 12),
            Text(
              _t('proceduralSteps'),
              style: const TextStyle(
                color: Color(0xFFEAB308),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s3_t2'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _t('s3_t3'),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            const SizedBox(height: 12),
            Text(
              _t('proceduralSteps'),
              style: const TextStyle(
                color: Color(0xFFEAB308),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _t('s4_t4'),
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
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
            const SizedBox(height: 12),
            Text(
              _t('proceduralSteps'),
              style: const TextStyle(
                color: Color(0xFFEAB308),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t('s5_t2'),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _t('s5_t3'),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _richText(String term, String fullText, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: term,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: fullText.replaceAll(term, ''),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceGraphics() {
    switch (_currentStep) {
      case 1:
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(painter: ShapePainter('cube')),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('cube'),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 60),
            Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(painter: ShapePainter('tetrahedron')),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('tetra'),
                  style: const TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        );
      case 3:
        return DragTarget<String>(
          onAcceptWithDetails: (details) {
            _playSound('click');
            setState(() {
              _droppedItems['cyl_stamp'] = details.data;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Column(
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Colors.white10
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? Colors.yellow
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CustomPaint(painter: ShapePainter('cylinder')),
                      ),
                      if (_droppedItems['cyl_stamp'] != null)
                        Transform.rotate(
                          angle: -0.2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (_droppedItems['cyl_stamp'] ==
                                      _t('notPolyStamp'))
                                  ? Colors.red.withOpacity(0.8)
                                  : Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              _droppedItems['cyl_stamp']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      case 4:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(painter: ShapePainter('pyramid')),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('sqPyr'),
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 60),
            Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(painter: ShapePainter('prism')),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('pentPrism'),
                  style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      case 5:
        return Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: _isUnlocked ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedScale(
                scale: _isUnlocked ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: CustomPaint(painter: ShapePainter('safe')),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _isUnlocked ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: AnimatedScale(
                scale: _isUnlocked ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CustomPaint(painter: ShapePainter('icosahedron')),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _t('icosahedron'),
                      style: const TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Text(
                      _t('shape'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'F',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'V',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'E',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const TableRow(
                  children: [
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _t('cube'),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildDropTarget('cube_f'),
                    _buildDropTarget('cube_v'),
                    _buildDropTarget('cube_e'),
                  ],
                ),
                const TableRow(
                  children: [
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _t('tetra'),
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildDropTarget('tetra_f'),
                    _buildDropTarget('tetra_v'),
                    _buildDropTarget('tetra_e'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                '4',
                '4',
                '6',
                '6',
                '8',
                '12',
              ].map((n) => _buildDraggable(n)).toList(),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "F",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDropTarget('op1'),
                const Text(
                  "V",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDropTarget('op2'),
                const Text(
                  "E",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "=",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "2",
                  style: TextStyle(
                    color: Color(0xFFEAB308),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                '+',
                '-',
                '×',
                '÷',
              ].map((op) => _buildDraggable(op)).toList(),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            Text(
              _t('s3_dragHint'),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildStampDraggable(_t('polyStamp'), Colors.greenAccent),
            const SizedBox(height: 16),
            _buildStampDraggable(_t('notPolyStamp'), Colors.redAccent),
          ],
        );
      case 4:
        return Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1.2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Text(
                  _t('shape'),
                  style: const TextStyle(color: Colors.white54),
                ),
                const Text(
                  'F',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'V',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'E',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'F+V-E',
                  style: TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const TableRow(
              children: [
                SizedBox(height: 8),
                SizedBox(height: 8),
                SizedBox(height: 8),
                SizedBox(height: 8),
                SizedBox(height: 8),
              ],
            ),
            TableRow(
              children: [
                Text(
                  _t('pyrShort'),
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                _buildTextInput(_pyrF, Colors.purpleAccent),
                _buildTextInput(_pyrV, Colors.purpleAccent),
                _buildTextInput(_pyrE, Colors.purpleAccent),
                _buildTextInput(_pyrR, const Color(0xFFEAB308)),
              ],
            ),
            const TableRow(
              children: [
                SizedBox(height: 8),
                SizedBox(height: 8),
                SizedBox(height: 8),
                SizedBox(height: 8),
                SizedBox(height: 8),
              ],
            ),
            TableRow(
              children: [
                Text(
                  _t('priShort'),
                  style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                _buildTextInput(_priF, Colors.pinkAccent),
                _buildTextInput(_priV, Colors.pinkAccent),
                _buildTextInput(_priE, Colors.pinkAccent),
                _buildTextInput(_priR, const Color(0xFFEAB308)),
              ],
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "20 + V - 30 = 2",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "V = ",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _finalV,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.zero,
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
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasItem ? const Color(0xFFEAB308) : Colors.black12,
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? const Color(0xFFEAB308)
                  : Colors.white24,
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            hasItem ? _droppedItems[targetKey]! : '',
            style: TextStyle(
              color: hasItem ? Colors.black : Colors.transparent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggable(String value) {
    Widget dragUi = Container(
      width: 40,
      height: 40,
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
          fontSize: 20,
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

  Widget _buildStampDraggable(String label, Color color) {
    Widget dragUi = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    );

    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.9, child: dragUi),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: dragUi),
      onDragStarted: () => _playSound('click'),
      child: dragUi,
    );
  }

  Widget _buildTextInput(TextEditingController controller, Color focusColor) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black26,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: focusColor, width: 2),
          ),
        ),
      ),
    );
  }

  // Multi-Language Dictionary
  static const Map<String, Map<String, String>> _i18n = {
    'en': {
      'enterLab': 'ENTER LAB',
      'title': 'Faces, Edges, and Vertices (Euler\'s Formula)',
      'subtitle': 'Class 8 • Exploring some Geometric Themes',
      'teacher': 'Teacher Board',
      'init':
          'Ready! Read the Teacher Board and use the interactive tools to solve the problem.',
      'verify': 'Verify Task',
      'unlock': 'Unlock Safe',
      'congrats': 'Congratulations!',
      'congratsMsg': 'You have mastered Euler\'s Formula for polyhedrons.',
      'restart': 'Restart Lab',
      'missionObj': 'Mission Objective',
      'proceduralSteps': 'Procedural Steps',
      'shape': 'Shape',
      'faces': 'Faces (F)',
      'vertices': 'Vertices (V)',
      'edges': 'Edges (E)',
      'cube': 'Cube',
      'tetra': 'Tetrahedron',
      'sqPyr': 'Square Pyramid',
      'pentPrism': 'Pentagonal Prism',
      'pyrShort': 'Pyramid',
      'priShort': 'Prism',
      'polyStamp': 'POLYHEDRON',
      'notPolyStamp': 'NOT A POLYHEDRON',
      'icosahedron': 'Icosahedron',
      's1_t1':
          'Let\'s explore the physical structure of 3D shapes. Look at these models built from edges and vertices.',
      's1_t2': 'The flat surfaces are called Faces (F).',
      's1_t3': 'The straight line segments where faces meet are Edges (E).',
      's1_t4': 'The corners where edges meet are Vertices (V).',
      's1_t5':
          'Count these elements for a Cube and a Tetrahedron to build a data table.',
      's1_success':
          'Excellent counting! A cube has 6 faces, 8 vertices, and 12 edges. A tetrahedron has 4 faces, 4 vertices, and 6 edges.',
      's1_fail':
          'Count carefully! A cube has 6 square faces. Check the corners and lines.',
      's2_t1':
          'Observe the numbers in our table. Is there a universal relationship between Faces, Vertices, and Edges?',
      's2_t2':
          'Look at the Cube: 6 Faces + 8 Vertices = 14. If we subtract the 12 Edges, we get 2.',
      's2_t3':
          'Look at the Tetrahedron: 4 Faces + 4 Vertices = 8. Subtract the 6 Edges, and we get 2 again!',
      's2_t4':
          'This constant relationship is called Euler\'s Formula: F + V - E = 2.',
      's2_success':
          'Perfect! You have discovered Euler\'s Formula. It holds true for all flat-faced polyhedrons.',
      's2_fail':
          'Test the math on the Cube\'s numbers: 6, 8, and 12. Make the equation exactly equal 2.',
      's3_t1':
          'Does Euler\'s Formula work for every 3D shape? Let\'s test a Cylinder.',
      's3_t2':
          'It has 3 faces (2 flat circles, 1 curved surface), 0 vertices, and 2 curved edges.',
      's3_t3':
          'Euler\'s Formula only works for Polyhedrons—shapes made entirely of flat polygons. Cylinders, cones, and spheres are NOT polyhedrons.',
      's3_dragHint':
          'Drag a stamp directly onto the Cylinder shape to classify it.',
      's3_success':
          'Correct classification! Because it contains a curved surface, the cylinder is excluded from the polyhedron family.',
      's3_fail':
          'Incorrect! A cylinder has a curved surface, which means it cannot be a Polyhedron. Apply the other stamp!',
      's4_t1': 'Let\'s verify Euler\'s Formula for more complex polyhedrons.',
      's4_t2': 'A Square Pyramid has a square base and 4 triangular sides.',
      's4_t3':
          'A Pentagonal Prism has two pentagon bases connected by 5 rectangular sides.',
      's4_t4':
          'Let\'s count their properties and verify that F + V - E still equals 2.',
      's4_success':
          'Excellent tabulation! 5+5-8=2 for the pyramid, and 7+10-15=2 for the prism. Euler\'s Formula holds true.',
      's4_fail':
          'Count the properties carefully. Ensure your calculation equals exactly 2.',
      's5_t1':
          'We can use Euler\'s Formula algebraically! If we know two properties, we can find the third without even seeing the shape.',
      's5_t2':
          '\'Figure It Out\': A mystery solid has 20 faces and 30 edges. How many vertices does it have?',
      's5_t3': 'Set up the equation: 20 + V - 30 = 2',
      's5_success':
          'Brilliant algebra! V = 12. The safe opens to reveal an Icosahedron, a complex polyhedron with 20 faces, 12 vertices, and 30 edges.',
      's5_fail':
          'Check your algebra. Combine the numbers first: 20 minus 30 is -10. What number minus 10 equals 2?',
    },
    'hi': {
      'enterLab': 'प्रयोगशाला में प्रवेश करें',
      'title': 'फलक, किनारे और शीर्ष (यूलर का सूत्र)',
      'subtitle': 'कक्षा 8 • कुछ ज्यामितीय विषयों का अन्वेषण',
      'teacher': 'शिक्षक बोर्ड',
      'init':
          'तैयार! शिक्षक बोर्ड पढ़ें और समस्या को हल करने के लिए इंटरैक्टिव उपकरणों का उपयोग करें।',
      'verify': 'कार्य सत्यापित करें',
      'unlock': 'तिजोरी खोलें',
      'congrats': 'बधाई हो!',
      'congratsMsg':
          'आपने बहुफलकों के लिए यूलर के सूत्र में महारत हासिल कर ली है।',
      'restart': 'प्रयोगशाला पुनः आरंभ करें',
      'missionObj': 'मिशन का उद्देश्य',
      'proceduralSteps': 'प्रक्रियात्मक चरण',
      'shape': 'आकार',
      'faces': 'फलक (F)',
      'vertices': 'शीर्ष (V)',
      'edges': 'किनारे (E)',
      'cube': 'घन',
      'tetra': 'चतुष्फलक',
      'sqPyr': 'वर्गाकार पिरामिड',
      'pentPrism': 'पंचकोणीय प्रिज्म',
      'pyrShort': 'पिरामिड',
      'priShort': 'प्रिज्म',
      'polyStamp': 'बहुफलक',
      'notPolyStamp': 'बहुफलक नहीं',
      'icosahedron': 'इकोसाहेड्रॉन',
      's1_t1':
          'आइए 3D आकृतियों की भौतिक संरचना का अन्वेषण करें। किनारे और शीर्षों से बने इन मॉडलों को देखें।',
      's1_t2': 'समतल सतहों को फलक (F) कहा जाता है।',
      's1_t3': 'सीधी रेखाएं जहां फलक मिलते हैं, किनारे (E) हैं।',
      's1_t4': 'कोने जहां किनारे मिलते हैं, शीर्ष (V) हैं।',
      's1_t5':
          'डेटा तालिका बनाने के लिए घन और चतुष्फलक के इन तत्वों की गणना करें।',
      's1_success':
          'उत्कृष्ट गिनती! एक घन में 6 फलक, 8 शीर्ष और 12 किनारे होते हैं। एक चतुष्फलक में 4 फलक, 4 शीर्ष और 6 किनारे होते हैं।',
      's1_fail':
          'ध्यान से गिनें! एक घन में 6 वर्गाकार फलक होते हैं। कोने और रेखाओं की जाँच करें।',
      's2_t1':
          'हमारी तालिका में संख्याओं का निरीक्षण करें। क्या फलक, शीर्ष और किनारों के बीच कोई सार्वभौमिक संबंध है?',
      's2_t2':
          'घन को देखें: 6 फलक + 8 शीर्ष = 14। यदि हम 12 किनारे घटाते हैं, तो हमें 2 मिलता है।',
      's2_t3':
          'चतुष्फलक को देखें: 4 फलक + 4 शीर्ष = 8। 6 किनारे घटाएं, और हमें फिर से 2 मिलता है!',
      's2_t4': 'इस निरंतर संबंध को यूलर का सूत्र कहा जाता है: F + V - E = 2.',
      's2_success':
          'उत्तम! आपने यूलर का सूत्र खोज लिया है। यह सभी समतल-मुख वाली आकृतियों (बहुफलकों) के लिए सत्य है।',
      's2_fail':
          'घन की संख्याओं पर गणित का परीक्षण करें: 6, 8, और 12। समीकरण को ठीक 2 के बराबर बनाएं।',
      's3_t1':
          'क्या यूलर का सूत्र हर 3D आकृति के लिए काम करता है? आइए एक बेलन का परीक्षण करें।',
      's3_t2':
          'इसमें 3 फलक (2 समतल वृत्त, 1 घुमावदार सतह), 0 शीर्ष और 2 घुमावदार किनारे हैं।',
      's3_t3':
          'यूलर का सूत्र केवल बहुफलकों के लिए काम करता है—पूरी तरह से समतल बहुभुजों से बनी आकृतियाँ। बेलन, शंकु और गोले बहुफलक नहीं हैं।',
      's3_dragHint': 'इसे वर्गीकृत करने के लिए बेलन पर सही मोहर खींचें।',
      's3_success':
          'सही वर्गीकरण! क्योंकि इसमें एक घुमावदार सतह है, बेलन बहुफलक परिवार से बाहर है।',
      's3_fail':
          'गलत! एक बेलन में एक घुमावदार सतह होती है, जिसका अर्थ है कि यह बहुफलक नहीं हो सकता। दूसरी मोहर लगाएँ!',
      's4_t1': 'आइए अधिक जटिल बहुफलकों के लिए यूलर के सूत्र को सत्यापित करें।',
      's4_t2':
          'एक वर्गाकार पिरामिड में एक वर्गाकार आधार और 4 त्रिकोणीय भुजाएँ होती हैं।',
      's4_t3':
          'एक पंचकोणीय प्रिज्म में 5 आयताकार भुजाओं से जुड़े दो पंचभुज आधार होते हैं।',
      's4_t4':
          'आइए उनके गुणों की गणना करें और सत्यापित करें कि F + V - E अभी भी 2 के बराबर है।',
      's4_success':
          'उत्कृष्ट सारणीकरण! पिरामिड के लिए 5+5-8=2, और प्रिज्म के लिए 7+10-15=2। यूलर का सूत्र सही साबित होता है।',
      's4_fail':
          'गुणों को ध्यान से गिनें। सुनिश्चित करें कि आपकी गणना ठीक 2 के बराबर है।',
      's5_t1':
          'हम यूलर के सूत्र का बीजगणितीय रूप से उपयोग कर सकते हैं! यदि हम दो गुण जानते हैं, तो हम बिना देखे तीसरा खोज सकते हैं।',
      's5_t2':
          '\'पता लगाओ\': एक रहस्यमय ठोस में 20 फलक और 30 किनारे हैं। इसमें कितने शीर्ष हैं?',
      's5_t3': 'समीकरण सेट करें: 20 + V - 30 = 2',
      's5_success':
          'शानदार बीजगणित! V = 12। 20 फलक, 12 शीर्ष और 30 किनारों के साथ एक जटिल बहुफलक, इकोसाहेड्रॉन को प्रकट करने के लिए तिजोरी खुल गई।',
      's5_fail':
          'अपना बीजगणित जाँचें। पहले संख्याओं को मिलाएं: 20 में से 30 घटाने पर -10 आता है। किस संख्या में से 10 घटाने पर 2 बचेगा?',
    },
  };
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
      ..color = Colors.green.withOpacity(0.15);
    final Paint edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final Paint vertexPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;
    final Paint dashedEdge = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2;

    switch (shape) {
      case 'cube':
        Path front = Path()
          ..moveTo(w * 0.15, h * 0.35)
          ..lineTo(w * 0.5, h * 0.55)
          ..lineTo(w * 0.5, h * 0.95)
          ..lineTo(w * 0.15, h * 0.75)
          ..close();
        Path top = Path()
          ..moveTo(w * 0.5, h * 0.15)
          ..lineTo(w * 0.85, h * 0.35)
          ..lineTo(w * 0.5, h * 0.55)
          ..lineTo(w * 0.15, h * 0.35)
          ..close();
        Path right = Path()
          ..moveTo(w * 0.5, h * 0.55)
          ..lineTo(w * 0.85, h * 0.35)
          ..lineTo(w * 0.85, h * 0.75)
          ..lineTo(w * 0.5, h * 0.95)
          ..close();

        canvas.drawPath(front, facePaint);
        canvas.drawPath(top, facePaint);
        canvas.drawPath(right, facePaint);
        canvas.drawPath(front, edgePaint);
        canvas.drawPath(top, edgePaint);
        canvas.drawPath(right, edgePaint);

        List<Offset> cubeVerts = [
          Offset(w * 0.15, h * 0.35),
          Offset(w * 0.5, h * 0.55),
          Offset(w * 0.5, h * 0.95),
          Offset(w * 0.15, h * 0.75),
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.85, h * 0.35),
          Offset(w * 0.85, h * 0.75),
        ];
        for (var v in cubeVerts) {
          canvas.drawCircle(v, 6, vertexPaint);
        }
        break;

      case 'tetrahedron':
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.5, h * 0.15)
            ..lineTo(w * 0.2, h * 0.8)
            ..lineTo(w * 0.8, h * 0.8)
            ..close(),
          facePaint,
        );
        canvas.drawLine(
          Offset(w * 0.2, h * 0.8),
          Offset(w * 0.5, h * 0.65),
          dashedEdge,
        );
        canvas.drawLine(
          Offset(w * 0.8, h * 0.8),
          Offset(w * 0.5, h * 0.65),
          dashedEdge,
        );
        canvas.drawLine(
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.5, h * 0.65),
          dashedEdge,
        );
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.5, h * 0.15)
            ..lineTo(w * 0.2, h * 0.8)
            ..lineTo(w * 0.8, h * 0.8)
            ..close(),
          edgePaint,
        );

        List<Offset> tetraVerts = [
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.2, h * 0.8),
          Offset(w * 0.8, h * 0.8),
          Offset(w * 0.5, h * 0.65),
        ];
        for (var i = 0; i < tetraVerts.length; i++) {
          canvas.drawCircle(
            tetraVerts[i],
            6,
            i == 3
                ? (Paint()..color = Colors.red.withOpacity(0.5))
                : vertexPaint,
          );
        }
        break;

      case 'cylinder':
        Rect topOval = Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.25),
          width: w * 0.6,
          height: h * 0.24,
        );
        Rect botOval = Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.75),
          width: w * 0.6,
          height: h * 0.24,
        );

        Path body = Path()
          ..moveTo(w * 0.2, h * 0.25)
          ..lineTo(w * 0.2, h * 0.75)
          ..arcTo(botOval, math.pi, math.pi, false)
          ..lineTo(w * 0.8, h * 0.25)
          ..close();
        canvas.drawPath(body, facePaint);
        canvas.drawOval(topOval, facePaint);

        canvas.drawArc(botOval, math.pi, math.pi, false, dashedEdge);
        canvas.drawArc(botOval, 0, math.pi, false, edgePaint);
        canvas.drawOval(topOval, edgePaint);
        canvas.drawLine(
          Offset(w * 0.2, h * 0.25),
          Offset(w * 0.2, h * 0.75),
          edgePaint,
        );
        canvas.drawLine(
          Offset(w * 0.8, h * 0.25),
          Offset(w * 0.8, h * 0.75),
          edgePaint,
        );
        break;

      case 'pyramid':
        Path outer = Path()
          ..moveTo(w * 0.5, h * 0.15)
          ..lineTo(w * 0.15, h * 0.7)
          ..lineTo(w * 0.6, h * 0.85)
          ..lineTo(w * 0.85, h * 0.6)
          ..close();
        canvas.drawPath(outer, facePaint);

        canvas.drawLine(
          Offset(w * 0.15, h * 0.7),
          Offset(w * 0.4, h * 0.45),
          dashedEdge,
        );
        canvas.drawLine(
          Offset(w * 0.85, h * 0.6),
          Offset(w * 0.4, h * 0.45),
          dashedEdge,
        );
        canvas.drawLine(
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.4, h * 0.45),
          dashedEdge,
        );

        canvas.drawPath(outer, edgePaint);
        canvas.drawLine(
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.6, h * 0.85),
          edgePaint,
        );

        List<Offset> pyrVerts = [
          Offset(w * 0.5, h * 0.15),
          Offset(w * 0.15, h * 0.7),
          Offset(w * 0.6, h * 0.85),
          Offset(w * 0.85, h * 0.6),
          Offset(w * 0.4, h * 0.45),
        ];
        for (var i = 0; i < pyrVerts.length; i++) {
          canvas.drawCircle(
            pyrVerts[i],
            6,
            i == 4
                ? (Paint()..color = Colors.red.withOpacity(0.5))
                : vertexPaint,
          );
        }
        break;

      case 'prism':
        Path topP = Path()
          ..moveTo(w * 0.5, h * 0.1)
          ..lineTo(w * 0.75, h * 0.25)
          ..lineTo(w * 0.65, h * 0.5)
          ..lineTo(w * 0.35, h * 0.5)
          ..lineTo(w * 0.25, h * 0.25)
          ..close();
        canvas.drawPath(topP, facePaint);
        canvas.drawPath(topP, edgePaint);

        Path f1 = Path()
          ..moveTo(w * 0.25, h * 0.25)
          ..lineTo(w * 0.25, h * 0.65)
          ..lineTo(w * 0.35, h * 0.9)
          ..lineTo(w * 0.35, h * 0.5)
          ..close();
        Path f2 = Path()
          ..moveTo(w * 0.35, h * 0.5)
          ..lineTo(w * 0.35, h * 0.9)
          ..lineTo(w * 0.65, h * 0.9)
          ..lineTo(w * 0.65, h * 0.5)
          ..close();
        Path f3 = Path()
          ..moveTo(w * 0.65, h * 0.5)
          ..lineTo(w * 0.65, h * 0.9)
          ..lineTo(w * 0.75, h * 0.65)
          ..lineTo(w * 0.75, h * 0.25)
          ..close();
        canvas.drawPath(f1, facePaint);
        canvas.drawPath(f2, facePaint);
        canvas.drawPath(f3, facePaint);

        canvas.drawLine(
          Offset(w * 0.25, h * 0.65),
          Offset(w * 0.5, h * 0.5),
          dashedEdge,
        );
        canvas.drawLine(
          Offset(w * 0.75, h * 0.65),
          Offset(w * 0.5, h * 0.5),
          dashedEdge,
        );
        canvas.drawLine(
          Offset(w * 0.5, h * 0.1),
          Offset(w * 0.5, h * 0.5),
          dashedEdge,
        );

        Path botFront = Path()
          ..moveTo(w * 0.25, h * 0.65)
          ..lineTo(w * 0.35, h * 0.9)
          ..lineTo(w * 0.65, h * 0.9)
          ..lineTo(w * 0.75, h * 0.65);
        canvas.drawPath(botFront, edgePaint);
        canvas.drawLine(
          Offset(w * 0.25, h * 0.25),
          Offset(w * 0.25, h * 0.65),
          edgePaint,
        );
        canvas.drawLine(
          Offset(w * 0.35, h * 0.5),
          Offset(w * 0.35, h * 0.9),
          edgePaint,
        );
        canvas.drawLine(
          Offset(w * 0.65, h * 0.5),
          Offset(w * 0.65, h * 0.9),
          edgePaint,
        );
        canvas.drawLine(
          Offset(w * 0.75, h * 0.25),
          Offset(w * 0.75, h * 0.65),
          edgePaint,
        );

        List<Offset> priVerts = [
          Offset(w * 0.5, h * 0.1),
          Offset(w * 0.75, h * 0.25),
          Offset(w * 0.65, h * 0.5),
          Offset(w * 0.35, h * 0.5),
          Offset(w * 0.25, h * 0.25),
          Offset(w * 0.25, h * 0.65),
          Offset(w * 0.35, h * 0.9),
          Offset(w * 0.65, h * 0.9),
          Offset(w * 0.75, h * 0.65),
          Offset(w * 0.5, h * 0.5),
        ];
        for (var i = 0; i < priVerts.length; i++) {
          canvas.drawCircle(
            priVerts[i],
            5,
            i == 9
                ? (Paint()..color = Colors.red.withOpacity(0.5))
                : vertexPaint,
          );
        }
        break;

      case 'safe':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.6),
            const Radius.circular(8),
          ),
          Paint()..color = const Color(0xFF334155),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.25, h * 0.25, w * 0.5, h * 0.5),
            const Radius.circular(4),
          ),
          Paint()..color = const Color(0xFF1E293B),
        );
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.5),
          w * 0.12,
          Paint()..color = const Color(0xFFEAB308),
        );
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.5),
          w * 0.03,
          Paint()..color = const Color(0xFFCA8A04),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.48, h * 0.38, w * 0.04, h * 0.06),
          Paint()..color = const Color(0xFFCA8A04),
        );
        canvas.drawCircle(
          Offset(w * 0.85, h * 0.5),
          w * 0.02,
          Paint()..color = Colors.red,
        );
        break;

      case 'icosahedron':
        Path hex = Path()
          ..moveTo(w * 0.5, h * 0.1)
          ..lineTo(w * 0.85, h * 0.3)
          ..lineTo(w * 0.85, h * 0.7)
          ..lineTo(w * 0.5, h * 0.9)
          ..lineTo(w * 0.15, h * 0.7)
          ..lineTo(w * 0.15, h * 0.3)
          ..close();
        canvas.drawPath(hex, facePaint);
        canvas.drawPath(hex, edgePaint);

        List<Path> inners = [
          Path()
            ..moveTo(w * 0.5, h * 0.1)
            ..lineTo(w * 0.65, h * 0.4)
            ..lineTo(w * 0.85, h * 0.3)
            ..close(),
          Path()
            ..moveTo(w * 0.85, h * 0.3)
            ..lineTo(w * 0.65, h * 0.4)
            ..lineTo(w * 0.85, h * 0.7)
            ..close(),
          Path()
            ..moveTo(w * 0.85, h * 0.7)
            ..lineTo(w * 0.65, h * 0.4)
            ..lineTo(w * 0.5, h * 0.75)
            ..lineTo(w * 0.5, h * 0.9)
            ..close(),
          Path()
            ..moveTo(w * 0.5, h * 0.9)
            ..lineTo(w * 0.5, h * 0.75)
            ..lineTo(w * 0.35, h * 0.4)
            ..lineTo(w * 0.15, h * 0.7)
            ..close(),
          Path()
            ..moveTo(w * 0.15, h * 0.7)
            ..lineTo(w * 0.35, h * 0.4)
            ..lineTo(w * 0.15, h * 0.3)
            ..close(),
          Path()
            ..moveTo(w * 0.15, h * 0.3)
            ..lineTo(w * 0.35, h * 0.4)
            ..lineTo(w * 0.5, h * 0.1)
            ..close(),
          Path()
            ..moveTo(w * 0.5, h * 0.1)
            ..lineTo(w * 0.35, h * 0.4)
            ..lineTo(w * 0.65, h * 0.4)
            ..close(),
          Path()
            ..moveTo(w * 0.35, h * 0.4)
            ..lineTo(w * 0.5, h * 0.75)
            ..lineTo(w * 0.65, h * 0.4)
            ..close(),
        ];
        for (var p in inners) {
          canvas.drawPath(p, edgePaint);
        }

        List<Offset> icoVerts = [
          Offset(w * 0.5, h * 0.1),
          Offset(w * 0.85, h * 0.3),
          Offset(w * 0.85, h * 0.7),
          Offset(w * 0.5, h * 0.9),
          Offset(w * 0.15, h * 0.7),
          Offset(w * 0.15, h * 0.3),
          Offset(w * 0.65, h * 0.4),
          Offset(w * 0.35, h * 0.4),
          Offset(w * 0.5, h * 0.75),
        ];
        for (var v in icoVerts) {
          canvas.drawCircle(v, 6, vertexPaint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
