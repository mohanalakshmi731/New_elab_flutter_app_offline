// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZslApp());
}

class ZslApp extends StatelessWidget {
  const ZslApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans', // Fallback to Roboto if font missing
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEAB308),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const VisualisingSections(),
    );
  }
}

class VisualisingSections extends StatefulWidget {
  const VisualisingSections({super.key});

  @override
  State<VisualisingSections> createState() => _VisualisingSectionsState();
}

class _VisualisingSectionsState extends State<VisualisingSections>
    with TickerProviderStateMixin {
  int currentStep = 1;
  String currentLang = 'en';
  bool isSidebarOpen = true;
  bool showSuccessModal = false;

  // Shutter Screen State
  bool showShutter = true;
  bool animateShutterOpen = false;

  // Feedback State
  String feedbackMsg = '';
  bool isFeedbackSuccess = false;
  bool verifyFailed = false;
  bool verifySuccess = false;

  // Step 1 State
  String? s1CutType;
  String? s1HorizDrop;
  String? s1VertDrop;
  String? s1OblDrop;

  // Step 2 State
  double s2LightValue = 45;
  bool s2TopFound = false;
  bool s2SideFound = false;

  // Step 3 State
  String? s3CutType;
  String? s3VertDrop;
  String? s3HorizDrop;

  // Step 4 State
  String? s4CutType;
  List<List<Offset>> s4Strokes = [];
  bool s4CircleDrawn = false;
  bool s4TriangleDrawn = false;
  int s4TotalPointsDrawn = 0;

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _chopPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl =
      'audio/class8/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class8/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class8/mixkit_955.mp3';
  static const String _shutterUrl =
      'audio/class8/mixkit_2574.mp3';
  static const String _chopUrl =
      'audio/class8/mixkit_2568.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    feedbackMsg = t('init');
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
    _shutterPlayer.dispose();
    _chopPlayer.dispose();
    super.dispose();
  }

  void playClick() async {
    try {
      if (_clickPlayer.state == PlayerState.playing) await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource(_clickUrl));
    } catch (_) {}
  }

  void playSuccess() async {
    try {
      if (_successPlayer.state == PlayerState.playing) {
        await _successPlayer.stop();
      }
      await _successPlayer.play(AssetSource(_successUrl));
    } catch (_) {}
  }

  void playError() async {
    try {
      if (_errorPlayer.state == PlayerState.playing) await _errorPlayer.stop();
      await _errorPlayer.play(AssetSource(_errorUrl));
    } catch (_) {}
  }

  void playShutter() async {
    try {
      if (_shutterPlayer.state == PlayerState.playing) {
        await _shutterPlayer.stop();
      }
      await _shutterPlayer.play(AssetSource(_shutterUrl));
    } catch (_) {}
  }

  void playChop() async {
    try {
      if (_chopPlayer.state == PlayerState.playing) await _chopPlayer.stop();
      await _chopPlayer.play(AssetSource(_chopUrl));
    } catch (_) {}
  }

  String t(String key) {
    return i18n[currentLang]?[key] ?? key;
  }

  void showFeedback(bool success, String msg) {
    setState(() {
      isFeedbackSuccess = success;
      feedbackMsg = msg;
    });
  }

  void _enterLab() {
    playShutter();
    setState(() {
      animateShutterOpen = true;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          showShutter = false;
        });
      }
    });
  }

  void resetLab() {
    playClick();
    setState(() {
      currentLang = 'en';
      currentStep = 1;
      showSuccessModal = false;
      showShutter = true;
      animateShutterOpen = false;
      isSidebarOpen = true;

      s1CutType = null;
      s1HorizDrop = null;
      s1VertDrop = null;
      s1OblDrop = null;
      s2LightValue = 45;
      s2TopFound = false;
      s2SideFound = false;
      s3CutType = null;
      s3VertDrop = null;
      s3HorizDrop = null;
      s4CutType = null;
      s4Strokes.clear();
      s4CircleDrawn = false;
      s4TriangleDrawn = false;
      s4TotalPointsDrawn = 0;

      feedbackMsg = t('init');
      isFeedbackSuccess = true;
      verifyFailed = false;
      verifySuccess = false;
      loadStep(1);
    });
  }

  void loadStep(int step) {
    setState(() {
      currentStep = step;
      feedbackMsg = t('s${step}_hud');
      isFeedbackSuccess = true;
      verifyFailed = false;
      verifySuccess = false;

      if (step == 1) {
        s1CutType = null;
        s1HorizDrop = null;
        s1VertDrop = null;
        s1OblDrop = null;
      } else if (step == 2) {
        s2LightValue = 45;
        s2TopFound = false;
        s2SideFound = false;
      } else if (step == 3) {
        s3CutType = null;
        s3VertDrop = null;
        s3HorizDrop = null;
      } else if (step == 4) {
        s4CutType = null;
        s4Strokes.clear();
        s4CircleDrawn = false;
        s4TriangleDrawn = false;
        s4TotalPointsDrawn = 0;
      }
    });
  }

  void verifyStep() {
    bool success = false;
    String msg = '';

    if (currentStep == 1) {
      if (s1HorizDrop == 'triangle' &&
          s1VertDrop == 'circle' &&
          s1OblDrop == 'oval') {
        success = true;
        msg = t('s1_success');
      } else if (s1HorizDrop != null ||
          s1VertDrop != null ||
          s1OblDrop != null) {
        success = false;
        msg = t('s1_fail');
      } else {
        success = false;
        msg = t('plsComplete');
      }
    } else if (currentStep == 2) {
      if (s2TopFound && s2SideFound) {
        success = true;
        msg = t('s2_success');
      } else {
        success = false;
        msg = t('s2_fail');
      }
    } else if (currentStep == 3) {
      if (s3VertDrop == 'srect' && s3HorizDrop == 'lrect') {
        success = true;
        msg = t('s3_success');
      } else if (s3VertDrop != null || s3HorizDrop != null) {
        success = false;
        msg = t('s3_fail');
      } else {
        success = false;
        msg = t('plsComplete');
      }
    } else if (currentStep == 4) {
      if (s4CircleDrawn && s4TriangleDrawn) {
        success = true;
        msg = t('s4_success');
      } else if (s4TotalPointsDrawn > 0) {
        success = false;
        msg = t('s4_fail');
      } else {
        success = false;
        msg = t('plsComplete');
      }
    }

    showFeedback(success, msg);

    if (success) {
      playSuccess();
      setState(() {
        verifySuccess = true;
        verifyFailed = false;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        if (currentStep < 4) {
          loadStep(currentStep + 1);
        } else {
          setState(() => showSuccessModal = true);
        }
      });
    } else {
      if (msg != t('plsComplete')) {
        playError();
      } else {
        playClick();
      }
      setState(() {
        verifyFailed = true;
        verifySuccess = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            verifyFailed = false;
            if (currentStep == 1) {
              s1HorizDrop = null;
              s1VertDrop = null;
              s1OblDrop = null;
              s1CutType = null;
            }
            if (currentStep == 3) {
              s3HorizDrop = null;
              s3VertDrop = null;
              s3CutType = null;
            }
          });
        }
      });
    }
  }

  Color get bgColor => const Color(0xFF020617);
  Color get panelColor => const Color(0xDA0F172A);
  Color get textColor => const Color(0xFFF8FAFC);
  Color get borderColor => const Color(0xFF334155);
  Color get accentColor => const Color(0xFFEAB308);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // Center Workspace
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 90,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/offline_texture.png'), // Subtle grid
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: _buildWorkspace(),
              ),
            ),

            // Sidebar (30% Width)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // Feedback HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isFeedbackSuccess
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFeedbackSuccess ? Icons.check_circle : Icons.error,
                          color: isFeedbackSuccess ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feedbackMsg,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Menu Button at Top Left (Front Z-index)
            Positioned(
              left: isSidebarOpen ? sidebarWidth + 10 : 10,
              top: 10,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(isSidebarOpen),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isSidebarOpen ? Icons.menu_open : Icons.menu,
                      color: textColor,
                    ),
                    onPressed: () {
                      playClick();
                      setState(() => isSidebarOpen = !isSidebarOpen);
                    },
                  ),
                ),
              ),
            ),

            // Floating Tools (Visible when Sidebar is closed and scrollable)
            if (!isSidebarOpen)
              Positioned(
                top: 70,
                left: 20,
                bottom: 80,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: panelColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.build, color: accentColor, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Tools",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildControlsForStep(),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: verifyFailed
                                  ? Colors.red
                                  : (verifySuccess
                                        ? Colors.green
                                        : accentColor),
                              foregroundColor: verifyFailed || verifySuccess
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(
                              verifyFailed ? Icons.close : Icons.check_circle,
                              size: 20,
                            ),
                            label: Text(
                              verifyFailed
                                  ? t('tryAgain')
                                  : (verifySuccess
                                        ? t('verified')
                                        : t('verify')),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: verifyStep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Success Modal (Scrollable)
            if (showSuccessModal)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        width: 400,
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentColor, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 60,
                              color: accentColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t('successTitle'),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t('successMsg'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                t('restartLab'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                resetLab();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Shutter Overlay
            if (showShutter)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutCubic,
                top: animateShutterOpen
                    ? -MediaQuery.of(context).size.height
                    : 0,
                bottom: animateShutterOpen
                    ? MediaQuery.of(context).size.height
                    : 0,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFF060B19),
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: animateShutterOpen ? 0.0 : 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.layers, size: 64, color: accentColor),
                          const SizedBox(height: 24),
                          Text(
                            t('appTitle'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              letterSpacing: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton(
                            onPressed: _enterLab,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: accentColor.withOpacity(0.5),
                            ),
                            child: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
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

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Top Controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('appTitle'),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t('appSubtitle'),
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.language, size: 16),
                              label: Text(currentLang.toUpperCase()),
                              onPressed: () {
                                playClick();
                                setState(() {
                                  if (currentLang == 'en') {
                                    currentLang = 'hi';
                                  } else {
                                    currentLang = 'en';
                                  }
                                  loadStep(currentStep);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bgColor,
                                foregroundColor: textColor,
                                side: BorderSide(color: borderColor),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.refresh,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              label: const Text('Reset'),
                              onPressed: resetLab,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bgColor,
                                foregroundColor: textColor,
                                side: BorderSide(color: borderColor),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(color: borderColor, height: 1),

                  // Step Selector
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentStep,
                          isExpanded: true,
                          dropdownColor: panelColor,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          items: [
                            DropdownMenuItem(value: 1, child: Text(t('step1'))),
                            DropdownMenuItem(value: 2, child: Text(t('step2'))),
                            DropdownMenuItem(value: 3, child: Text(t('step3'))),
                            DropdownMenuItem(value: 4, child: Text(t('step4'))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              playClick();
                              loadStep(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  // Content Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('missionObj'),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('s${currentStep}_t1'),
                          style: TextStyle(
                            color: textColor.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t('proceduralSteps'),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _bulletText(t('s${currentStep}_t2')),
                        const SizedBox(height: 8),
                        _bulletText(t('s${currentStep}_t3')),

                        const SizedBox(height: 24),

                        // Control Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.build,
                                    color: accentColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t('tools'),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildControlsForStep(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: verifyFailed
                                  ? Colors.red
                                  : (verifySuccess
                                        ? Colors.green
                                        : accentColor),
                              foregroundColor: verifyFailed || verifySuccess
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              verifyFailed ? Icons.close : Icons.check_circle,
                            ),
                            label: Text(
                              verifyFailed
                                  ? t('tryAgain')
                                  : (verifySuccess
                                        ? t('verified')
                                        : t('verify')),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: verifyStep,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Text(
                  '© ZEROSCIENCELAB - Fall in Love with Math and Science',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bulletText(String text) {
    if (text.isEmpty) return const SizedBox();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 8),
          child: CircleAvatar(radius: 3, backgroundColor: textColor),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsForStep() {
    if (currentStep == 1) {
      return Column(
        children: [
          _sliceBtnS1('horizontal', t('horizCut')),
          const SizedBox(height: 8),
          _sliceBtnS1('vertical', t('vertCut')),
          const SizedBox(height: 8),
          _sliceBtnS1('oblique', t('oblCut')),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dragToken('circle', _getTokenWidget('circle')),
                const SizedBox(width: 8),
                _dragToken('triangle', _getTokenWidget('triangle')),
                const SizedBox(width: 8),
                _dragToken('oval', _getTokenWidget('oval')),
              ],
            ),
          ),
        ],
      );
    } else if (currentStep == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('moveLight'),
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: Colors.white70),
              Expanded(
                child: Slider(
                  value: s2LightValue,
                  min: 0,
                  max: 90,
                  activeColor: accentColor,
                  inactiveColor: borderColor,
                  onChanged: (v) {
                    setState(() {
                      s2LightValue = v;
                      if (v > 80 && !s2TopFound) {
                        s2TopFound = true;
                        playClick();
                      }
                      if (v < 10 && !s2SideFound) {
                        s2SideFound = true;
                        playClick();
                      }
                    });
                  },
                ),
              ),
              const Icon(Icons.wb_sunny, color: Colors.white70),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('sideLight'),
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
              Text(
                t('topLight'),
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ],
          ),
        ],
      );
    } else if (currentStep == 3) {
      return Column(
        children: [
          _sliceBtnS3('vertical', t('btnVertSlice')),
          const SizedBox(height: 8),
          _sliceBtnS3('horizontal', t('btnHorizSlice')),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dragToken('lrect', _getTokenWidget('lrect')),
                const SizedBox(width: 8),
                _dragToken('srect', _getTokenWidget('srect')),
                const SizedBox(width: 8),
                _dragToken('tri', _getTokenWidget('tri')),
              ],
            ),
          ),
        ],
      );
    } else if (currentStep == 4) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sliceBtnS4('horizontal', t('sliceHorizCone')),
          const SizedBox(height: 8),
          _sliceBtnS4('vertical', t('sliceVertCone')),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _sliceBtnS1(String type, String label) {
    bool active = s1CutType == type;
    return InkWell(
      onTap: () {
        playChop();
        setState(() => s1CutType = type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? accentColor : borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _sliceBtnS3(String type, String label) {
    bool active = s3CutType == type;
    return InkWell(
      onTap: () {
        playChop();
        setState(() => s3CutType = type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? accentColor : borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _sliceBtnS4(String type, String label) {
    bool active = s4CutType == type;
    return InkWell(
      onTap: () {
        playChop();
        setState(() {
          s4CutType = type;
          s4Strokes.clear();
          s4TotalPointsDrawn = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? accentColor : borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.black : textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if ((type == 'horizontal' && s4CircleDrawn) ||
                  (type == 'vertical' && s4TriangleDrawn))
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.check_circle,
                    color: active ? Colors.black : Colors.green,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragToken(String val, Widget child) {
    bool isUsed = false;
    if (currentStep == 1) {
      isUsed = (s1HorizDrop == val || s1VertDrop == val || s1OblDrop == val);
    } else if (currentStep == 3) {
      isUsed = (s3HorizDrop == val || s3VertDrop == val);
    }

    if (isUsed) return const SizedBox(width: 50, height: 50);

    return Draggable<String>(
      data: val,
      feedback: Opacity(opacity: 0.8, child: child),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      onDragStarted: () => playClick(),
      child: child,
    );
  }

  Widget _getTokenWidget(String type) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(30, 30),
          painter: TokenPainter(type),
        ),
      ),
    );
  }

  Widget _buildWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget workspaceContent = const SizedBox();

        if (currentStep == 1) {
          workspaceContent = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Carrot Visual
              SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(painter: Step1Painter(s1CutType)),
              ),
              const SizedBox(width: 40),
              // Drop Zones
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dropZoneS1(
                    'horizontal',
                    s1HorizDrop,
                    t('lblHorizResult'),
                    (val) => setState(() => s1HorizDrop = val),
                  ),
                  const SizedBox(height: 16),
                  _dropZoneS1(
                    'vertical',
                    s1VertDrop,
                    t('lblVertResult'),
                    (val) => setState(() => s1VertDrop = val),
                  ),
                  const SizedBox(height: 16),
                  _dropZoneS1(
                    'oblique',
                    s1OblDrop,
                    t('lblOblResult'),
                    (val) => setState(() => s1OblDrop = val),
                  ),
                ],
              ),
            ],
          );
        } else if (currentStep == 2) {
          workspaceContent = Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: CustomPaint(painter: Step2Painter(s2LightValue)),
            ),
          );
        } else if (currentStep == 3) {
          workspaceContent = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Brick Visual
              SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(painter: Step3Painter(s3CutType)),
              ),
              const SizedBox(width: 40),
              // Drop Zones
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dropZoneS3(
                    'vertical',
                    s3VertDrop,
                    t('lblVertCutResult'),
                    (val) => setState(() => s3VertDrop = val),
                  ),
                  const SizedBox(height: 24),
                  _dropZoneS3(
                    'horizontal',
                    s3HorizDrop,
                    t('lblHorizCutResult'),
                    (val) => setState(() => s3HorizDrop = val),
                  ),
                ],
              ),
            ],
          );
        } else if (currentStep == 4) {
          workspaceContent = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cone Visual
              SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(painter: Step4Painter(s4CutType)),
              ),
              const SizedBox(width: 40),
              // Drawing Pad
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    if (s4CutType != null)
                      Center(
                        child: CustomPaint(
                          size: const Size(150, 150),
                          painter: DrawPadGuidePainter(s4CutType!),
                        ),
                      ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) {
                        if (s4CutType == null) return;
                        setState(() {
                          s4Strokes.add([d.localPosition]);
                          s4TotalPointsDrawn++;
                        });
                      },
                      onPanUpdate: (d) {
                        if (s4CutType == null) return;
                        setState(() {
                          s4Strokes.last.add(d.localPosition);
                          s4TotalPointsDrawn++;
                        });
                      },
                      onPanEnd: (d) {
                        if (s4CutType == null) return;
                        if (s4TotalPointsDrawn > 20) {
                          playClick();
                          setState(() {
                            if (s4CutType == 'horizontal') s4CircleDrawn = true;
                            if (s4CutType == 'vertical') s4TriangleDrawn = true;
                          });
                        }
                      },
                      child: CustomPaint(
                        size: const Size(200, 200),
                        painter: DrawPadPainter(s4Strokes),
                      ),
                    ),
                    if (s4CutType == null)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Text(
                            t('dpPrompt'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (s4CutType != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            playClick();
                            setState(() {
                              s4Strokes.clear();
                              s4TotalPointsDrawn = 0;
                            });
                          },
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }

        // Use FittedBox directly without scroll views. This prevents drawing gestures
        // from being intercepted and ensures everything strictly scales to fit without cutoff.
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 850,
                height: 500,
                child: Container(
                  color: Colors.transparent, // Keeps HitTest area alive
                  child: workspaceContent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dropZoneS1(
    String id,
    String? currentVal,
    String label,
    Function(String) onDrop,
  ) {
    return DragTarget<String>(
      onAccept: (val) {
        playClick();
        onDrop(val);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovered = candidateData.isNotEmpty;
        return Container(
          width: 140,
          height: 100,
          decoration: BoxDecoration(
            color: currentVal != null
                ? Colors.green.withOpacity(0.1)
                : (isHovered ? accentColor.withOpacity(0.2) : Colors.black12),
            border: Border.all(
              color: currentVal != null
                  ? Colors.green
                  : (isHovered ? accentColor : borderColor),
              width: 2,
              style: currentVal != null ? BorderStyle.solid : BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              if (currentVal == null && !isHovered)
                CustomPaint(
                  size: const Size(140, 100),
                  painter: DashedBorderPainter(borderColor),
                ),
              if (currentVal != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: _getTokenWidget(currentVal),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _dropZoneS3(
    String id,
    String? currentVal,
    String label,
    Function(String) onDrop,
  ) {
    return DragTarget<String>(
      onAccept: (val) {
        playClick();
        onDrop(val);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovered = candidateData.isNotEmpty;
        return Container(
          width: 140,
          height: 100,
          decoration: BoxDecoration(
            color: currentVal != null
                ? Colors.green.withOpacity(0.1)
                : (isHovered ? accentColor.withOpacity(0.2) : Colors.black12),
            border: Border.all(
              color: currentVal != null
                  ? Colors.green
                  : (isHovered ? accentColor : borderColor),
              width: 2,
              style: currentVal != null ? BorderStyle.solid : BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              if (currentVal == null && !isHovered)
                CustomPaint(
                  size: const Size(140, 100),
                  painter: DashedBorderPainter(borderColor),
                ),
              if (currentVal != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: _getTokenWidget(currentVal),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------
// Custom Painters
// ------------------------

void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
  const double dashWidth = 8.0;
  const double dashSpace = 8.0;
  for (PathMetric pathMetric in path.computeMetrics()) {
    double distance = 0.0;
    while (distance < pathMetric.length) {
      canvas.drawPath(
        pathMetric.extractPath(distance, distance + dashWidth),
        paint,
      );
      distance += dashWidth + dashSpace;
    }
  }
}

class TokenPainter extends CustomPainter {
  final String type;
  TokenPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()..style = PaintingStyle.fill;
    double w = size.width, h = size.height;

    if (type == 'circle') {
      p.color = Colors.orange;
      canvas.drawCircle(Offset(w / 2, h / 2), w / 2 * 0.9, p);
    } else if (type == 'triangle') {
      p.color = Colors.orange;
      Path path = Path()
        ..moveTo(w / 2, h * 0.1)
        ..lineTo(w * 0.9, h * 0.9)
        ..lineTo(w * 0.1, h * 0.9)
        ..close();
      canvas.drawPath(path, p);
    } else if (type == 'oval') {
      p.color = Colors.orange;
      canvas.save();
      canvas.translate(w / 2, h / 2);
      canvas.rotate(pi / 12);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w * 0.9, height: h * 0.5),
        p,
      );
      canvas.restore();
    } else if (type == 'lrect') {
      p.color = const Color(0xFF39FF14);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(w / 2, h / 2),
          width: w * 0.9,
          height: h * 0.5,
        ),
        p,
      );
    } else if (type == 'srect') {
      p.color = const Color(0xFF00e5ff);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(w / 2, h / 2),
          width: w * 0.7,
          height: h * 0.7,
        ),
        p,
      );
    } else if (type == 'tri') {
      p.color = const Color(0xFFFF00FF);
      Path path = Path()
        ..moveTo(w / 2, h * 0.1)
        ..lineTo(w * 0.9, h * 0.9)
        ..lineTo(w * 0.1, h * 0.9)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );
    _drawDashedPath(canvas, path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ------------------------
// Step Specific Visuals
// ------------------------

class Step1Painter extends CustomPainter {
  final String? cutType;
  Step1Painter(this.cutType);

  @override
  void paint(Canvas canvas, Size size) {
    Paint green = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    Paint greenStroke = Paint()
      ..color = Colors.green[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    Paint orange = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    Paint orangeStroke = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    Paint linePaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    double w = size.width, h = size.height;
    double cw = 200, ch = 100;
    double scale = min(w / cw, h / ch) * 0.9;

    canvas.translate((w - cw * scale) / 2, (h - ch * scale) / 2);
    canvas.scale(scale);

    Path l1 = Path()
      ..moveTo(20, 50)
      ..quadraticBezierTo(5, 20, 15, 10)
      ..quadraticBezierTo(25, 30, 20, 50);
    Path l2 = Path()
      ..moveTo(20, 50)
      ..quadraticBezierTo(0, 40, 5, 20)
      ..quadraticBezierTo(20, 35, 20, 50);
    Path l3 = Path()
      ..moveTo(20, 50)
      ..quadraticBezierTo(10, 70, 5, 80)
      ..quadraticBezierTo(25, 65, 20, 50);
    Path body = Path()
      ..moveTo(20, 30)
      ..lineTo(170, 45)
      ..quadraticBezierTo(180, 50, 170, 55)
      ..lineTo(20, 70)
      ..quadraticBezierTo(10, 50, 20, 30)
      ..close();

    void drawCarrot() {
      canvas.drawPath(l1, green);
      canvas.drawPath(l1, greenStroke);
      canvas.drawPath(l2, green);
      canvas.drawPath(l2, greenStroke);
      canvas.drawPath(l3, green);
      canvas.drawPath(l3, greenStroke);
      canvas.drawPath(body, orange);
      canvas.drawPath(body, orangeStroke);

      Paint ridge = Paint()
        ..color = Colors.deepOrange.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(
        Path()
          ..moveTo(40, 35)
          ..quadraticBezierTo(35, 50, 40, 65),
        ridge,
      );
      canvas.drawPath(
        Path()
          ..moveTo(70, 38)
          ..quadraticBezierTo(65, 50, 70, 62),
        ridge,
      );
      canvas.drawPath(
        Path()
          ..moveTo(100, 41)
          ..quadraticBezierTo(95, 50, 100, 59),
        ridge,
      );
    }

    if (cutType == null) {
      drawCarrot();
    } else {
      // Part 1 (Top / Left / Top-Right)
      canvas.save();
      if (cutType == 'horizontal') {
        canvas.translate(0, -15);
        canvas.clipRect(const Rect.fromLTRB(-100, -100, 300, 50));
      } else if (cutType == 'vertical') {
        canvas.translate(-15, 0);
        canvas.clipRect(const Rect.fromLTRB(-100, -100, 90, 200));
      } else if (cutType == 'oblique') {
        canvas.translate(10, -15);
        canvas.clipPath(
          Path()
            ..moveTo(-60, -100)
            ..lineTo(300, -100)
            ..lineTo(300, 200)
            ..lineTo(240, 200)
            ..close(),
        );
      }
      drawCarrot();
      canvas.restore();

      // Part 2 (Bottom / Right / Bottom-Left)
      canvas.save();
      if (cutType == 'horizontal') {
        canvas.translate(0, 15);
        canvas.clipRect(const Rect.fromLTRB(-100, 50, 300, 200));
      } else if (cutType == 'vertical') {
        canvas.translate(15, 0);
        canvas.clipRect(const Rect.fromLTRB(90, -100, 300, 200));
      } else if (cutType == 'oblique') {
        canvas.translate(-10, 15);
        canvas.clipPath(
          Path()
            ..moveTo(-60, -100)
            ..lineTo(-100, -100)
            ..lineTo(-100, 200)
            ..lineTo(240, 200)
            ..close(),
        );
      }
      drawCarrot();
      canvas.restore();
    }

    // Draw Dashed Cut Line overlay
    if (cutType == 'horizontal') {
      _drawDashedPath(
        canvas,
        Path()
          ..moveTo(10, 50)
          ..lineTo(180, 50),
        linePaint,
      );
    } else if (cutType == 'vertical') {
      _drawDashedPath(
        canvas,
        Path()
          ..moveTo(90, 10)
          ..lineTo(90, 90),
        linePaint,
      );
    } else if (cutType == 'oblique') {
      _drawDashedPath(
        canvas,
        Path()
          ..moveTo(50, 10)
          ..lineTo(130, 90),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Step1Painter oldDelegate) =>
      oldDelegate.cutType != cutType;
}

class Step2Painter extends CustomPainter {
  final double lightValue;
  Step2Painter(this.lightValue);

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width, h = size.height;

    Paint wall = Paint()
      ..color = Colors.blueGrey[800]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    Paint floor = Paint()
      ..color = Colors.blueGrey[900]!.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    Paint border = Paint()
      ..color = Colors.blueGrey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Rect wallRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.3),
      width: 160,
      height: 200,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(wallRect, const Radius.circular(8)),
      wall,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(wallRect, const Radius.circular(8)),
      border,
    );

    Rect floorRect = Rect.fromCenter(
      center: Offset(w / 2, h * 0.8),
      width: 240,
      height: 100,
    );
    canvas.drawOval(floorRect, floor);
    canvas.drawOval(floorRect, border);

    double topOpacity = lightValue / 90.0;
    double sideOpacity = (90.0 - lightValue) / 90.0;

    Paint shadowTop = Paint()
      ..color = Colors.black.withOpacity(topOpacity * 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.8), width: 100, height: 100),
      shadowTop,
    );

    Paint shadowSide = Paint()
      ..color = Colors.black.withOpacity(sideOpacity * 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w / 2, h * 0.3), width: 80, height: 120),
      shadowSide,
    );

    double cw = 100, ch = 160;
    double scale = 1.0;
    canvas.save();
    canvas.translate((w - cw * scale) / 2, (h - ch * scale) / 2 - 20);
    canvas.scale(scale);

    Paint cylBody = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.fill;
    Paint cylStroke = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Paint cylTop = Paint()
      ..color = Colors.blue[500]!
      ..style = PaintingStyle.fill;

    Path body = Path()
      ..moveTo(10, 30)
      ..lineTo(10, 130)
      ..arcToPoint(
        const Offset(90, 130),
        radius: const Radius.elliptical(40, 15),
        clockwise: false,
      )
      ..lineTo(90, 30)
      ..close();
    canvas.drawPath(body, cylBody);
    canvas.drawPath(body, cylStroke);

    Rect topBase = Rect.fromCenter(
      center: const Offset(50, 30),
      width: 80,
      height: 30,
    );
    canvas.drawOval(topBase, cylTop);
    canvas.drawOval(topBase, cylStroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Step2Painter oldDelegate) =>
      oldDelegate.lightValue != lightValue;
}

class Step3Painter extends CustomPainter {
  final String? cutType;
  Step3Painter(this.cutType);

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width, h = size.height;
    double cw = 120, ch = 100;
    double scale = min(w / cw, h / ch) * 1.5;

    canvas.translate((w - cw * scale) / 2, (h - ch * scale) / 2);
    canvas.scale(scale);

    Paint top = Paint()
      ..color = Colors.red[600]!
      ..style = PaintingStyle.fill;
    Paint left = Paint()
      ..color = Colors.red[700]!
      ..style = PaintingStyle.fill;
    Paint right = Paint()
      ..color = Colors.red[900]!
      ..style = PaintingStyle.fill;
    Paint stroke = Paint()
      ..color = Colors.red[900]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Paint linePaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    Path pTop = Path()
      ..moveTo(20, 40)
      ..lineTo(60, 20)
      ..lineTo(100, 40)
      ..lineTo(60, 60)
      ..close();
    Path pLeft = Path()
      ..moveTo(20, 40)
      ..lineTo(60, 60)
      ..lineTo(60, 90)
      ..lineTo(20, 70)
      ..close();
    Path pRight = Path()
      ..moveTo(60, 60)
      ..lineTo(100, 40)
      ..lineTo(100, 70)
      ..lineTo(60, 90)
      ..close();

    void drawBrick() {
      canvas.drawPath(pTop, top);
      canvas.drawPath(pTop, stroke);
      canvas.drawPath(pLeft, left);
      canvas.drawPath(pLeft, stroke);
      canvas.drawPath(pRight, right);
      canvas.drawPath(pRight, stroke);
    }

    if (cutType == null) {
      drawBrick();
    } else {
      // Part 1
      canvas.save();
      if (cutType == 'horizontal') {
        canvas.translate(0, -15);
        canvas.clipRect(const Rect.fromLTRB(-100, -100, 300, 50));
      } else if (cutType == 'vertical') {
        canvas.translate(-15, -10);
        canvas.clipRect(const Rect.fromLTRB(-100, -100, 60, 200));
      }
      drawBrick();
      canvas.restore();

      // Part 2
      canvas.save();
      if (cutType == 'horizontal') {
        canvas.translate(0, 15);
        canvas.clipRect(const Rect.fromLTRB(-100, 50, 300, 200));
      } else if (cutType == 'vertical') {
        canvas.translate(15, 10);
        canvas.clipRect(const Rect.fromLTRB(60, -100, 300, 200));
      }
      drawBrick();
      canvas.restore();
    }

    // Draw Dashed Cut Line overlay
    if (cutType == 'horizontal') {
      Path path = Path()
        ..moveTo(10, 50)
        ..lineTo(50, 30)
        ..lineTo(90, 50)
        ..lineTo(50, 70)
        ..close();
      _drawDashedPath(canvas, path, linePaint);
    } else if (cutType == 'vertical') {
      _drawDashedPath(
        canvas,
        Path()
          ..moveTo(60, 20)
          ..lineTo(60, 90),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Step3Painter oldDelegate) =>
      oldDelegate.cutType != cutType;
}

class Step4Painter extends CustomPainter {
  final String? cutType;
  Step4Painter(this.cutType);

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width, h = size.height;
    double cw = 100, ch = 120;
    double scale = min(w / cw, h / ch) * 1.5;

    canvas.translate((w - cw * scale) / 2, (h - ch * scale) / 2);
    canvas.scale(scale);

    Paint body = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.fill;
    Paint base = Paint()
      ..color = Colors.blue[600]!
      ..style = PaintingStyle.fill;
    Paint stroke = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Paint linePaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    Path pBody = Path()
      ..moveTo(10, 100)
      ..lineTo(50, 10)
      ..lineTo(90, 100)
      ..close();
    Rect rBase = Rect.fromCenter(
      center: const Offset(50, 100),
      width: 80,
      height: 30,
    );

    void drawCone() {
      canvas.drawPath(pBody, body);
      canvas.drawPath(pBody, stroke);
      canvas.drawOval(rBase, base);
      canvas.drawOval(rBase, stroke);
    }

    if (cutType == null) {
      drawCone();
    } else {
      // Part 1
      canvas.save();
      if (cutType == 'horizontal') {
        canvas.translate(0, -15);
        canvas.clipRect(const Rect.fromLTRB(-100, -100, 300, 60));
      } else if (cutType == 'vertical') {
        canvas.translate(-15, 0);
        canvas.clipRect(const Rect.fromLTRB(-100, -100, 50, 300));
      }
      drawCone();
      canvas.restore();

      // Part 2
      canvas.save();
      if (cutType == 'horizontal') {
        canvas.translate(0, 15);
        canvas.clipRect(const Rect.fromLTRB(-100, 60, 300, 300));
      } else if (cutType == 'vertical') {
        canvas.translate(15, 0);
        canvas.clipRect(const Rect.fromLTRB(50, -100, 300, 300));
      }
      drawCone();
      canvas.restore();
    }

    // Draw Dashed Cut Line overlay
    if (cutType == 'horizontal') {
      _drawDashedPath(
        canvas,
        Path()
          ..moveTo(10, 60)
          ..lineTo(90, 60),
        linePaint,
      );
    } else if (cutType == 'vertical') {
      _drawDashedPath(
        canvas,
        Path()
          ..moveTo(50, 0)
          ..lineTo(50, 120),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Step4Painter oldDelegate) =>
      oldDelegate.cutType != cutType;
}

// ------------------------
// Step 4 Drawing Pad
// ------------------------

class DrawPadPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  DrawPadPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = Colors.yellow[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var stroke in strokes) {
      if (stroke.length > 1) {
        Path path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, p);
      } else if (stroke.isNotEmpty) {
        canvas.drawCircle(stroke[0], 3, Paint()..color = Colors.yellow[600]!);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawPadPainter oldDelegate) => true;
}

class DrawPadGuidePainter extends CustomPainter {
  final String cutType;
  DrawPadGuidePainter(this.cutType);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    double w = size.width, h = size.height;

    if (cutType == 'horizontal') {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w / 2, h / 2),
          width: w * 0.9,
          height: w * 0.9,
        ),
        p,
      );
    } else if (cutType == 'vertical') {
      Path path = Path()
        ..moveTo(w / 2, h * 0.1)
        ..lineTo(w * 0.9, h * 0.9)
        ..lineTo(w * 0.1, h * 0.9)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant DrawPadGuidePainter oldDelegate) =>
      oldDelegate.cutType != cutType;
}

// Translations Data
const Map<String, Map<String, String>> i18n = {
  'en': {
    'appTitle': 'Visualising Sections (Slicing)',
    'appSubtitle': 'Class 8 • Exploring some Geometric Themes',
    'enterLab': 'ENTER LAB',
    'langDisplay': 'EN',
    'teacherBoard': 'Teacher Board',
    'init':
        'Ready! Read the Teacher Board and use the interactive tools to solve the problem.',
    'verify': 'Verify Task',
    'settings': 'Lab Settings',
    'theme': 'Theme',
    'fontSize': 'Board Font Size',
    'tools': 'Interactive Tools',
    'successTitle': 'Activity Complete!',
    'successMsg':
        'You have successfully mastered visualizing 2D cross-sections of 3D objects!',
    'restartLab': 'Restart Lab',
    'plsComplete': 'Please complete the interactions before verifying.',
    'tryAgain': 'Try Again',
    'verified': 'Verified! Auto-advancing...',
    'missionObj': 'Mission Objective',
    'proceduralSteps': 'Procedural Steps',
    'step1': 'Step 1: Kitchen Geometry',
    'step2': 'Step 2: Shadow Play',
    'step3': 'Step 3: Prediction',
    'step4': 'Step 4: Drawing Sections',
    's1_t1':
        'Slicing a 3D object creates a flat, 2D surface called a cross-section. The shape entirely depends on the angle of the cut.',
    's1_t2':
        'Let\'s practice \'Kitchen Geometry\' using a conical carrot lying horizontally on a cutting board.',
    's1_t3':
        'A horizontal slice (cutting parallel to the board, slicing top from bottom) yields a Triangular shape. A vertical chop (cutting straight down across the width) yields a Circular shape. An oblique cut (slanted) creates an Oval.',
    's1_hud':
        'Select a cutting angle on the Slicer to chop the carrot! Then, drag the correct 2D shape to its matching labeled frame.',
    'horizCut': 'Horizontal Slice (Along)',
    'vertCut': 'Vertical Chop (Across)',
    'oblCut': 'Oblique Cut (Angle)',
    'lblHorizResult': 'Horizontal Result',
    'lblVertResult': 'Vertical Result',
    'lblOblResult': 'Oblique Result',
    's1_success':
        'Excellent visual geometry! Slicing horizontally along the length gives a Triangle, chopping vertically across the width gives a Circle, and an oblique angle gives an Oval.',
    's1_fail':
        'System Alert: Shape mismatch. Think about looking straight at the newly cut inner surface.',
    's2_t1':
        'Another way to visualize 2D shapes from 3D objects is through Shadow Play.',
    's2_t2':
        'By shining a light on a 3D object, we project a 2D shadow onto a flat surface.',
    's2_t3':
        'Depending on the orientation of the object and the light source, the same 3D shape can cast very different 2D shadows. Let\'s test this with a cylinder.',
    's2_hud':
        'Drag the slider to position the Flashlight from the Side to the Top of the cylinder to cast shadows.',
    'moveLight': 'Move Flashlight',
    'sideLight': 'Side',
    'topLight': 'Top',
    's2_success':
        'Perfect alignment! Shining light from the top projects the cylinder\'s circular base. Shining light from the side projects its rectangular profile.',
    's2_fail':
        'System Alert: Keep looking! You need to find both the perfect Circle shadow on the floor and the perfect Rectangle shadow on the wall.',
    's3_t1':
        'Let\'s predict the cross-sections of a cuboid, like a standard brick.',
    's3_t2':
        'Since every face of a cuboid is a rectangle (or square), any straight slice parallel to one of its faces will result in a rectangular cross-section.',
    's3_t3':
        'A vertical cut reveals the profile of the end face, while a horizontal cut reveals the profile of the top base.',
    's3_hud':
        'Activate the slicing planes on the brick one at a time. Drag the correct 2D shape to the corresponding display slot.',
    'btnVertSlice': 'Vertical Cut (Across Width)',
    'btnHorizSlice': 'Horizontal Cut (Across Height)',
    'lblVertCutResult': 'Vertical Result',
    'lblHorizCutResult': 'Horizontal Result',
    's3_success':
        'Accurate prediction! Both cuts produce rectangles, but their dimensions differ based on whether you sliced parallel to the end face (small rectangle) or the top face (large rectangle).',
    's3_fail':
        'System Alert: Incorrect shape selection. A brick has straight edges, so it cannot produce curved or triangular cross-sections when cut parallel to its faces.',
    's4_t1': 'Finally, let\'s look at a cone standing upright.',
    's4_t2':
        'Slicing a cone creates drastically different shapes depending on the angle. If we cut it parallel to its base, we get a shape identical to the base but smaller.',
    's4_t3':
        'If we cut it perpendicular to its base (straight down from the very tip), we reveal a completely different geometric shape.',
    's4_hud':
        'Apply the Horizontal Slicer, then use the digital pad to draw the resulting shape. Repeat using the Vertical Slicer!',
    'sliceHorizCone': '1. Slice Horizontally',
    'sliceVertCone': '2. Slice Vertically',
    'drawingPad': 'Drawing Pad',
    'dpPrompt': 'Slice the cone to activate drawing pad',
    'clearDrawing': 'Clear Tracing',
    's4_success':
        'Masterful geometry! Slicing parallel to the base gives a Circle. Slicing straight down from the vertex to the base yields a Triangle.',
    's4_fail':
        'System Alert: Unrecognized shape or drawing incomplete. Follow the faint guide carefully.',
  },
  'hi': {
    'appTitle': 'सेक्शनों को विज़ुअलाइज़ करना',
    'appSubtitle': 'कक्षा 8 • कुछ ज्यामितीय विषयों का अन्वेषण',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'langDisplay': 'HI',
    'teacherBoard': 'शिक्षक बोर्ड',
    'init':
        'तैयार! शिक्षक बोर्ड पढ़ें और समस्या को हल करने के लिए उपकरणों का उपयोग करें।',
    'verify': 'सत्यापित करें',
    'settings': 'सेटिंग्स',
    'theme': 'थीम',
    'fontSize': 'फ़ॉन्ट आकार',
    'tools': 'इंटरएक्टिव उपकरण',
    'successTitle': 'गतिविधि पूर्ण!',
    'successMsg':
        'आपने 3D वस्तुओं के 2D क्रॉस-सेक्शन की कल्पना करने में सफलतापूर्वक महारत हासिल कर ली है!',
    'restartLab': 'लैब को फिर से शुरू करें',
    'plsComplete': 'कृपया सत्यापित करने से पहले इंटरैक्शन पूरा करें।',
    'tryAgain': 'पुनः प्रयास करें',
    'verified': 'सत्यापित! आगे बढ़ रहे हैं...',
    'missionObj': 'मिशन का उद्देश्य',
    'proceduralSteps': 'प्रक्रियात्मक चरण',
    'step1': 'चरण 1: किचन ज्योमेट्री',
    'step2': 'चरण 2: परछाई का खेल',
    'step3': 'चरण 3: अनुमान',
    'step4': 'चरण 4: ड्राइंग सेक्शन',
    's1_t1':
        'किसी 3D वस्तु को काटने से एक सपाट, 2D सतह बनती है जिसे क्रॉस-सेक्शन कहा जाता है। इस क्रॉस-सेक्शन का आकार कट के कोण पर निर्भर करता है।',
    's1_t2':
        'आइए बोर्ड पर क्षैतिज रूप से रखे शंक्वाकार गाजर का उपयोग करके अभ्यास करें।',
    's1_t3':
        'एक क्षैतिज कट (लम्बाई में, ऊपर और नीचे के हिस्सों को अलग करना) एक त्रिकोणीय आकार देता है। एक ऊर्ध्वाधर कट (चौड़ाई में) एक गोलाकार आकार देता है। एक तिरछा कट एक अंडाकार बनाता है।',
    's1_hud':
        'गाजर को काटने के लिए स्लाइसर पर कटिंग एंगल चुनें! फिर, सही 2D आकार को खींचें।',
    'horizCut': 'क्षैतिज कट (लम्बाई में)',
    'vertCut': 'ऊर्ध्वाधर कट (चौड़ाई में)',
    'oblCut': 'तिरछा कट (कोण)',
    'lblHorizResult': 'क्षैतिज परिणाम',
    'lblVertResult': 'ऊर्ध्वाधर परिणाम',
    'lblOblResult': 'तिरछा परिणाम',
    's1_success':
        'उत्कृष्ट ज्यामिति! क्षैतिज रूप से काटने पर एक त्रिभुज मिलता है, लंबवत काटने पर वृत्त मिलता है, और एक तिरछा कोण अंडाकार बना देता है।',
    's1_fail':
        'सिस्टम अलर्ट: आकार बेमेल। कटी हुई सतह को सीधे नीचे देखने के बारे में सोचें।',
    's2_t1':
        '3D वस्तुओं से 2D आकृतियों की कल्पना करने का एक अन्य तरीका शैडो प्ले है।',
    's2_t2':
        '3D वस्तु पर प्रकाश डालकर, हम एक सपाट सतह पर 2D छाया प्रोजेक्ट करते हैं।',
    's2_t3':
        'प्रकाश स्रोत के आधार पर, एक ही 3D आकृति बहुत अलग 2D छाया डाल सकती है।',
    's2_hud':
        'टॉर्च को साइड से बेलन के शीर्ष पर ले जाने के लिए स्लाइडर को खींचें।',
    'moveLight': 'टॉर्च को हिलाएं',
    'sideLight': 'किनारा (Side)',
    'topLight': 'शीर्ष (Top)',
    's2_success':
        'सही संरेखण! शीर्ष से प्रकाश डालने पर गोलाकार आधार का अनुमान लगता है। किनारे से प्रकाश डालने पर आयताकार रूपरेखा दिखाई देती है।',
    's2_fail':
        'सिस्टम अलर्ट: आपको फर्श पर सर्कल की छाया और दीवार पर आयत की छाया दोनों ढूंढनी होगी।',
    's3_t1':
        'आइए एक मानक ईंट की तरह एक घनाभ के क्रॉस-सेक्शन की भविष्यवाणी करें।',
    's3_t2':
        'चूँकि घनाभ का प्रत्येक फलक एक आयत (या वर्ग) होता है, इसके किसी भी फलक के समानांतर कोई भी सीधा टुकड़ा एक आयताकार क्रॉस-सेक्शन का परिणाम देगा।',
    's3_t3':
        'एक ऊर्ध्वाधर कट अंत चेहरे के प्रोफ़ाइल को प्रकट करता है, जबकि एक क्षैतिज कट शीर्ष आधार के प्रोफ़ाइल को प्रकट करता है।',
    's3_hud':
        'एक-एक करके ईंट पर स्लाइसिंग प्लेन को सक्रिय करें। सही 2D आकार को खींचें।',
    'btnVertSlice': 'ऊर्ध्वाधर स्लाइस (चौड़ाई में)',
    'btnHorizSlice': 'क्षैतिज स्लाइस (ऊंचाई में)',
    'lblVertCutResult': 'ऊर्ध्वाधर कट का परिणाम',
    'lblHorizCutResult': 'क्षैतिज कट का परिणाम',
    's3_success':
        'सटीक भविष्यवाणी! दोनों कट आयत बनाते हैं, लेकिन उनके आयाम इस बात पर निर्भर करते हैं कि आपने अंत चेहरे या शीर्ष चेहरे के समानांतर कटा है।',
    's3_fail':
        'सिस्टम अलर्ट: गलत आकार चयन। एक ईंट के किनारे सीधे होते हैं, इसलिए यह घुमावदार क्रॉस-सेक्शन नहीं बना सकता है।',
    's4_t1': 'अंत में, आइए एक शंकु (Cone) को देखें।',
    's4_t2':
        'शंकु को काटने से कोण के आधार पर काफी भिन्न आकार बनते हैं। यदि हम इसे आधार के समानांतर काटते हैं, तो हमें आधार के समान एक आकार मिलता है।',
    's4_t3':
        'यदि हम इसे आधार के लंबवत काटते हैं (नोक से सीधे नीचे), तो हम एक बिल्कुल अलग ज्यामितीय आकार प्रकट करते हैं।',
    's4_hud':
        'शंकु पर क्षैतिज स्लाइसर लागू करें, फिर परिणामी आकार बनाने के लिए पैड का उपयोग करें। ऊर्ध्वाधर स्लाइसर का उपयोग करके दोहराएं!',
    'sliceHorizCone': '1. क्षैतिज रूप से स्लाइस करें',
    'sliceVertCone': '2. लंबवत रूप से स्लाइस करें',
    'drawingPad': 'ड्राइंग पैड',
    'dpPrompt': 'ड्राइंग पैड को सक्रिय करने के लिए शंकु को काटें',
    'clearDrawing': 'ड्राइंग मिटाएं',
    's4_success':
        'उत्कृष्ट ज्यामिति! आधार के समानांतर स्लाइसिंग एक सर्कल देता है। लंबवत स्लाइस करने से त्रिभुज प्राप्त होता है।',
    's4_fail': 'सिस्टम अलर्ट: अधूरा ट्रेस। सावधानीपूर्वक पालन करें।',
  },
};
