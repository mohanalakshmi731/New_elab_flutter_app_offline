// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EqualizerApp());
}

class EqualizerApp extends StatefulWidget {
  const EqualizerApp({super.key});

  @override
  State<EqualizerApp> createState() => _EqualizerAppState();
}

class _EqualizerAppState extends State<EqualizerApp>
    with TickerProviderStateMixin {
  // Navigation & UI State
  bool hasStarted = false;
  bool isSidebarOpen = true;
  String currentLang = 'en';
  int currentStep = 0;
  bool isAdvancing = false;

  // Interactive Geometry State
  final double radius = 150.0;
  final Offset centerO = const Offset(0, 0);

  bool showChordAB = false;
  bool showChordCD = false;
  bool showAngles = false;

  // Angles in degrees
  double angA = 210.0;
  double angB = 300.0;
  double angC = 45.0;
  double angD = 135.0;

  String? dragPt;
  bool wasEqual = false;

  // Canvas Panning/Zooming
  Offset canvasDelta = Offset.zero;
  double canvasScale = 1.0;
  double _initialScale = 1.0;

  // Text Controllers
  final TextEditingController _step3Ctrl = TextEditingController();
  final TextEditingController _step5Ctrl = TextEditingController();
  final TextEditingController _step6Ctrl = TextEditingController();
  final TextEditingController _step7Ctrl = TextEditingController();
  final TextEditingController _step8Ctrl = TextEditingController();

  // Input States
  String step3Input = '';
  String step5Input = '';
  String step6Input = '';
  String step7Input = '';
  String step8Input = '';

  // Modals & Feedback
  bool showFinalModal = false;
  String? toastMessage;
  bool isErrorToast = false;
  Timer? toastTimer;

  // Animations
  late AnimationController _pulseController;

  // Scroll Controller
  final ScrollController _sidebarScrollController = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(10, (index) => GlobalKey());

  // Theme Constants
  final Color themeBg = const Color(0xFF020617);
  final Color themePanel = const Color.fromRGBO(15, 23, 42, 0.95);
  final Color themeText = const Color(0xFFF8FAFC);
  final Color themeMuted = const Color(0xFF94A3B8);
  final Color themeBorder = const Color.fromRGBO(59, 130, 246, 0.3);
  final Color themeAccent = const Color(0xFFF59E0B); // Amber
  final Color themePrimary = const Color(0xFF3B82F6); // Blue
  final Color themeSecondary = const Color(0xFF8B5CF6); // Purple
  final Color themeSuccess = const Color(0xFF22C55E); // Green
  final Color themeError = const Color(0xFFEF4444); // Red
  final Color themeWarn = const Color(0xFFEAB308); // Yellow

  // Audio Players
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl =
      'audio/class9/click.mp3';
  static const String _successUrl =
      'audio/class9/success.mp3';
  static const String _errorUrl =
      'audio/class9/error.mp3';
  static const String _alertUrl =
      'audio/class9/shutter.mp3';

  Offset _getPtFromAngle(double deg, double r) {
    return Offset(
      r * math.cos(deg * math.pi / 180),
      r * math.sin(deg * math.pi / 180),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _pulseController.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    _step3Ctrl.dispose();
    _step5Ctrl.dispose();
    _step6Ctrl.dispose();
    _step7Ctrl.dispose();
    _step8Ctrl.dispose();

    _sidebarScrollController.dispose();
    toastTimer?.cancel();

    super.dispose();
  }

  void playClick() => _clickPlayer.play(AssetSource(_clickUrl));
  void playSuccess() => _successPlayer.play(AssetSource(_successUrl));
  void playError() => _errorPlayer.play(AssetSource(_errorUrl));
  void playPower() => _fxPlayer.play(AssetSource(_alertUrl));

  void cycleLanguage() {
    playClick();
    setState(() {
      currentLang = currentLang == 'en' ? 'hi' : 'en';
    });
  }

  void showToast(String message, bool isError) {
    setState(() {
      toastMessage = message;
      isErrorToast = isError;
    });
    toastTimer?.cancel();
    toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => toastMessage = null);
    });
  }

  void completeStep() {
    if (isAdvancing) return;
    setState(() => isAdvancing = true);

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        if (currentStep < 9) {
          currentStep++;

          if (currentStep == 8) {
            showToast(db[currentLang]!['msg_drag_cd'], false);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!isSidebarOpen) return;
            final context = _stepKeys[currentStep].currentContext;
            if (context != null) {
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: 0.5,
              );
            }
          });
        } else {
          playPower();
          showFinalModal = true;
        }
        isAdvancing = false;
        _step3Ctrl.clear();
        _step5Ctrl.clear();
        _step6Ctrl.clear();
        _step7Ctrl.clear();
        _step8Ctrl.clear();
      });
    });
  }

  void fullReset() {
    playClick();
    setState(() {
      hasStarted = false;
      currentLang = 'en';
      currentStep = 0;
      isAdvancing = false;

      showChordAB = false;
      showChordCD = false;
      showAngles = false;

      angA = 210.0;
      angB = 300.0;
      angC = 45.0;
      angD = 135.0;

      dragPt = null;
      wasEqual = false;
      canvasDelta = Offset.zero;
      canvasScale = 1.0;
      _initialScale = 1.0;

      step3Input = '';
      _step3Ctrl.clear();
      step5Input = '';
      _step5Ctrl.clear();
      step6Input = '';
      _step6Ctrl.clear();
      step7Input = '';
      _step7Ctrl.clear();
      step8Input = '';
      _step8Ctrl.clear();

      showFinalModal = false;
      isSidebarOpen = true;
    });
  }

  double getAngleDiff(double a, double b) {
    double diff = (a - b).abs();
    if (diff > 180.0) diff = 360.0 - diff;
    return diff;
  }

  double getChordLength(double angleDiff) {
    return 20.0 * math.sin(angleDiff * math.pi / 360.0);
  }

  void handleAction(double lenAB, double lenCD, double diffAB, double diffCD) {
    playClick();
    if (currentStep == 0) {
      completeStep();
    } else if (currentStep == 1) {
      setState(() => showChordAB = true);
      playSuccess();
      completeStep();
    } else if (currentStep == 2) {
      double expected = double.parse(lenAB.toStringAsFixed(1));
      double parsed = double.tryParse(step3Input) ?? -999.0;
      if ((parsed - expected).abs() < 0.2) {
        playSuccess();
        showToast(db[currentLang]!['msg_success'], false);
        completeStep();
      } else {
        playError();
        showToast(db[currentLang]!['msg_error'], true);
      }
    } else if (currentStep == 3) {
      setState(() => showChordCD = true);
      playSuccess();
      completeStep();
    } else if (currentStep == 4) {
      double expected = double.parse(lenCD.toStringAsFixed(1));
      double parsed = double.tryParse(step5Input) ?? -999.0;
      if ((parsed - expected).abs() < 0.2) {
        playSuccess();
        showToast(db[currentLang]!['msg_success'], false);
        completeStep();
      } else {
        playError();
        showToast(db[currentLang]!['msg_error'], true);
      }
    } else if (currentStep == 5) {
      setState(() => showAngles = true);
      double expected = diffAB.roundToDouble();
      double parsed = double.tryParse(step6Input) ?? -999.0;
      if ((parsed - expected).abs() < 1.0) {
        playSuccess();
        completeStep();
      } else {
        playError();
        showToast(db[currentLang]!['msg_error'], true);
      }
    } else if (currentStep == 6) {
      double expected = diffCD.roundToDouble();
      double parsed = double.tryParse(step7Input) ?? -999.0;
      if ((parsed - expected).abs() < 1.0) {
        playSuccess();
        completeStep();
      } else {
        playError();
        showToast(db[currentLang]!['msg_error'], true);
      }
    } else if (currentStep == 7) {
      if (step8Input.trim().toLowerCase() == 'yes' ||
          step8Input.trim() == '=' ||
          step8Input.trim().toLowerCase() == 'equal') {
        playSuccess();
        showToast(db[currentLang]!['msg_success'], false);
        completeStep();
      } else {
        playError();
        showToast("Type 'yes' or '='", true);
      }
    } else if (currentStep == 8) {
      completeStep();
    } else if (currentStep == 9) {
      completeStep();
    }
  }

  void _onScaleStart(
    ScaleStartDetails details,
    BoxConstraints constraints,
    double sidebarWidth,
  ) {
    if (isAdvancing) return;

    final double availableWidth =
        isSidebarOpen
            ? constraints.maxWidth - sidebarWidth
            : constraints.maxWidth;
    final double cx =
        (isSidebarOpen ? sidebarWidth : 0) +
        (availableWidth / 2) +
        canvasDelta.dx;
    final double cy = constraints.maxHeight / 2 + canvasDelta.dy;

    _initialScale = canvasScale;

    Offset localPoint =
        (details.localFocalPoint - Offset(cx, cy)) / canvasScale;
    double hitRadius = 50.0 / canvasScale;

    Offset ptA = _getPtFromAngle(angA, radius);
    Offset ptB = _getPtFromAngle(angB, radius);
    Offset ptC = _getPtFromAngle(angC, radius);
    Offset ptD = _getPtFromAngle(angD, radius);

    // Only allow dragging in Step 8 (Stress Test) and 9 (Certification)
    if (currentStep == 8 || currentStep == 9) {
      if ((localPoint - ptA).distance < hitRadius) {
        dragPt = 'A';
        playClick();
      } else if ((localPoint - ptB).distance < hitRadius) {
        dragPt = 'B';
        playClick();
      } else if ((localPoint - ptC).distance < hitRadius) {
        dragPt = 'C';
        playClick();
      } else if ((localPoint - ptD).distance < hitRadius) {
        dragPt = 'D';
        playClick();
      } else {
        dragPt = null;
      }
    } else {
      dragPt = null;
    }
  }

  void _onScaleUpdate(
    ScaleUpdateDetails details,
    BoxConstraints constraints,
    double sidebarWidth,
  ) {
    if (dragPt == null) {
      setState(() {
        canvasScale = (_initialScale * details.scale).clamp(0.3, 3.0);
        canvasDelta += details.focalPointDelta;
      });
      return;
    }

    final double availableWidth =
        isSidebarOpen
            ? constraints.maxWidth - sidebarWidth
            : constraints.maxWidth;
    final double cx =
        (isSidebarOpen ? sidebarWidth : 0) +
        (availableWidth / 2) +
        canvasDelta.dx;
    final double cy = constraints.maxHeight / 2 + canvasDelta.dy;

    Offset localPoint =
        (details.localFocalPoint - Offset(cx, cy)) / canvasScale;

    setState(() {
      double ang = math.atan2(localPoint.dy, localPoint.dx) * 180 / math.pi;
      if (ang < 0) ang += 360;

      if (dragPt == 'A') angA = ang;
      if (dragPt == 'B') angB = ang;
      if (dragPt == 'C') angC = ang;
      if (dragPt == 'D') angD = ang;

      double diffAB = getAngleDiff(angA, angB);
      double diffCD = getAngleDiff(angC, angD);
      double lenAB = getChordLength(diffAB);
      double lenCD = getChordLength(diffCD);

      bool isEqual = (lenAB - lenCD).abs() < 0.2;
      if (isEqual && !wasEqual) {
        playSuccess();
        wasEqual = true;
      } else if (!isEqual) {
        wasEqual = false;
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() => dragPt = null);
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) return _buildShutterScreen();

    final t = db[currentLang]!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = screenWidth * 0.32;

    double diffAB = getAngleDiff(angA, angB);
    double diffCD = getAngleDiff(angC, angD);
    double lenAB = getChordLength(diffAB);
    double lenCD = getChordLength(diffCD);
    bool isEqual = (lenAB - lenCD).abs() < 0.2;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: themeBg,
        body: Stack(
          children: [
            // Canvas Layer
            Positioned.fill(
              child: _buildCanvasArea(
                sidebarWidth,
                diffAB,
                diffCD,
                lenAB,
                lenCD,
                isEqual,
              ),
            ),

            // Top-Center Data Log (Visible only in full screen mode or when needed)
            if (isSidebarOpen == false)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themePanel,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t['chord_ab'] + ": ${lenAB.toStringAsFixed(1)}",
                          style: TextStyle(
                            color: themePrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          t['chord_cd'] + ": ${lenCD.toStringAsFixed(1)}",
                          style: TextStyle(
                            color: themeSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Action Panel (Compact, Bottom Left)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 16,
              left: isSidebarOpen ? sidebarWidth + 16 : 16,
              width: 320,
              child: _buildActionPanel(t, lenAB, lenCD, diffAB, diffCD),
            ),

            // Left Sidebar Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Material(
                elevation: 16,
                color: Colors.transparent,
                child: _buildSidebar(t, diffAB, diffCD, lenAB, lenCD, isEqual),
              ),
            ),

            // Top-Left Menu Icon (Visible when sidebar is closed)
            if (!isSidebarOpen)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    playClick();
                    setState(() => isSidebarOpen = true);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Toast Message
            if (toastMessage != null)
              Positioned(
                top: 16,
                left:
                    isSidebarOpen
                        ? sidebarWidth + (screenWidth - sidebarWidth) / 2 - 100
                        : screenWidth / 2 - 100,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isErrorToast
                              ? themeError.withOpacity(0.9)
                              : themeSuccess.withOpacity(0.9),
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 10),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isErrorToast ? Icons.warning : Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            toastMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Final Modal Overlay
            if (showFinalModal)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(child: _buildFinalModal(t)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    final t = db[currentLang]!;
    return Scaffold(
      backgroundColor: themeBg,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF3B82F6,
                          ).withOpacity(0.3 + (_pulseController.value * 0.3)),
                          blurRadius: 30 + (_pulseController.value * 20),
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.architecture,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                t['header_title'],
                style: TextStyle(
                  color: themeText,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t['header_subtitle'],
                style: TextStyle(
                  color: themeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  playPower();
                  setState(() => hasStarted = true);
                },
                icon: const Icon(Icons.power_settings_new, size: 20),
                label: Text(
                  t['btn_init'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 10,
                  shadowColor: themeAccent.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(
    Map<String, dynamic> t,
    double diffAB,
    double diffCD,
    double lenAB,
    double lenCD,
    bool isEqual,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: themePanel,
        border: Border(right: BorderSide(color: themeBorder, width: 2)),
      ),
      child: SingleChildScrollView(
        controller: _sidebarScrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section (Not sticky, scrolls with content)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () {
                      playClick();
                      setState(() => isSidebarOpen = false);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t['header_title'],
                          style: TextStyle(
                            color: themePrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t['header_subtitle'],
                          style: TextStyle(
                            color: themeAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: cycleLanguage,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: themeBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currentLang.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: fullReset,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: themeError.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: themeError),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.refresh, color: themeError, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            t['ui_reset'],
                            style: TextStyle(
                              color: themeError,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t['status_lbl'].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "${t['ui_step']} ${currentStep + 1}/10",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (currentStep + 1) / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeAccent,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(color: themeAccent, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),

              // Body Content
              _buildSectionTitle(t['objective_lbl'], themeAccent),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: themeBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeBorder),
                ),
                child: Text(
                  t['objective'],
                  style: TextStyle(color: themeText, fontSize: 13, height: 1.5),
                ),
              ),

              _buildSectionTitle(t['procedural_steps_lbl'], themePrimary),
              Column(
                children: List.generate(t['steps'].length, (index) {
                  bool isPast = index < currentStep;
                  bool isCurrent = index == currentStep;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          child:
                              isPast
                                  ? Icon(
                                    Icons.check_circle,
                                    color: themeSuccess,
                                    size: 14,
                                  )
                                  : isCurrent
                                  ? Icon(
                                    Icons.play_circle_filled,
                                    color: themePrimary,
                                    size: 14,
                                  )
                                  : Icon(
                                    Icons.lock,
                                    color: themeMuted.withOpacity(0.5),
                                    size: 14,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            key: _stepKeys[index],
                            child: Text(
                              t['steps'][index],
                              style: TextStyle(
                                color:
                                    isCurrent
                                        ? themePrimary
                                        : (isPast
                                            ? themeMuted
                                            : themeMuted.withOpacity(0.5)),
                                fontSize: 13,
                                fontWeight:
                                    isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(t['instr_lbl'], themeWarn),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: themeBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeWarn.withOpacity(0.5)),
                ),
                child: Text(
                  t['instr'],
                  style: TextStyle(color: themeText, fontSize: 13, height: 1.5),
                ),
              ),

              _buildSectionTitle(t['output_lbl'], themeSecondary),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color:
                      isEqual
                          ? themeSuccess.withOpacity(0.2)
                          : themeBg.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEqual ? themeSuccess : themeSecondary,
                    width: 2,
                  ),
                  boxShadow:
                      isEqual
                          ? [
                            BoxShadow(
                              color: themeSuccess.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ]
                          : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _logItem(
                      t['chord_ab'],
                      "${lenAB.toStringAsFixed(1)} units",
                      isEqual ? themeSuccess : themePrimary,
                    ),
                    _logItem(
                      t['chord_cd'],
                      "${lenCD.toStringAsFixed(1)} units",
                      isEqual ? themeSuccess : themeSecondary,
                    ),
                    const Divider(color: Colors.white24, height: 16),
                    _logItem(
                      t['angle_aob'],
                      "${diffAB.round()}°",
                      isEqual ? themeSuccess : themePrimary,
                    ),
                    _logItem(
                      t['angle_cod'],
                      "${diffCD.round()}°",
                      isEqual ? themeSuccess : themeSecondary,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isEqual
                                ? themeSuccess
                                : themeError.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isEqual ? t['status_equal'] : t['status_unequal'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionTitle(t['concept_lbl'], themeSuccess),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeBorder),
                ),
                child: Text(
                  t['concept'],
                  style: TextStyle(
                    color: themeMuted,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),

              // Footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: const Text(
                    "© ZEROSCIENCELAB - Fall in Love with Math and Science",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _logItem(String key, String val, Color highlightColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: TextStyle(
              color: themeMuted,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              color: highlightColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(
    Map<String, dynamic> t,
    double lenAB,
    double lenCD,
    double diffAB,
    double diffCD,
  ) {
    Widget content = const SizedBox();

    if (currentStep == 0) {
      content = _buildPrimaryBtn(
        t['btn_init'],
        () => handleAction(lenAB, lenCD, diffAB, diffCD),
        themeAccent,
      );
    } else if (currentStep == 1) {
      content = _buildPrimaryBtn(
        t['btn_chord_ab'],
        () => handleAction(lenAB, lenCD, diffAB, diffCD),
        themePrimary,
      );
    } else if (currentStep == 2) {
      content = Row(
        children: [
          Expanded(
            child: TextField(
              controller: _step3Ctrl,
              enabled: !isAdvancing,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: t['hint_len_ab'],
                hintStyle: TextStyle(color: themeMuted, fontSize: 12),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => step3Input = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPrimaryBtn(
              t['btn_verify'],
              () => handleAction(lenAB, lenCD, diffAB, diffCD),
              themeSuccess,
            ),
          ),
        ],
      );
    } else if (currentStep == 3) {
      content = _buildPrimaryBtn(
        t['btn_chord_cd'],
        () => handleAction(lenAB, lenCD, diffAB, diffCD),
        themeSecondary,
      );
    } else if (currentStep == 4) {
      content = Row(
        children: [
          Expanded(
            child: TextField(
              controller: _step5Ctrl,
              enabled: !isAdvancing,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: t['hint_len_cd'],
                hintStyle: TextStyle(color: themeMuted, fontSize: 12),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => step5Input = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPrimaryBtn(
              t['btn_verify'],
              () => handleAction(lenAB, lenCD, diffAB, diffCD),
              themeSuccess,
            ),
          ),
        ],
      );
    } else if (currentStep == 5) {
      content = Row(
        children: [
          Expanded(
            child: TextField(
              controller: _step6Ctrl,
              enabled: !isAdvancing,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: t['hint_ang_aob'],
                hintStyle: TextStyle(color: themeMuted, fontSize: 12),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => step6Input = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPrimaryBtn(
              t['btn_verify'],
              () => handleAction(lenAB, lenCD, diffAB, diffCD),
              themeSuccess,
            ),
          ),
        ],
      );
    } else if (currentStep == 6) {
      content = Row(
        children: [
          Expanded(
            child: TextField(
              controller: _step7Ctrl,
              enabled: !isAdvancing,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: t['hint_ang_cod'],
                hintStyle: TextStyle(color: themeMuted, fontSize: 12),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => step7Input = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPrimaryBtn(
              t['btn_verify'],
              () => handleAction(lenAB, lenCD, diffAB, diffCD),
              themeSuccess,
            ),
          ),
        ],
      );
    } else if (currentStep == 7) {
      content = Row(
        children: [
          Expanded(
            child: TextField(
              controller: _step8Ctrl,
              enabled: !isAdvancing,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: t['hint_verify_eq'],
                hintStyle: TextStyle(color: themeMuted, fontSize: 12),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => step8Input = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPrimaryBtn(
              t['btn_verify'],
              () => handleAction(lenAB, lenCD, diffAB, diffCD),
              themePrimary,
            ),
          ),
        ],
      );
    } else if (currentStep == 8) {
      content = Column(
        children: [
          Text(
            t['msg_drag_cd'],
            style: TextStyle(
              color: themeWarn,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildPrimaryBtn(
            t['btn_proceed'],
            () => handleAction(lenAB, lenCD, diffAB, diffCD),
            themeSuccess,
          ),
        ],
      );
    } else if (currentStep == 9) {
      content = _buildPrimaryBtn(
        t['btn_certify'],
        () => handleAction(lenAB, lenCD, diffAB, diffCD),
        themeSuccess,
        border: themeSuccess,
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 320), // Compact layout
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeBorder, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.terminal, color: themeAccent, size: 14),
              const SizedBox(width: 6),
              Text(
                t['ui_mission_control'].toUpperCase(),
                style: TextStyle(
                  color: themeAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildPrimaryBtn(
    String text,
    VoidCallback onTap,
    Color bgColor, {
    Color? border,
  }) {
    return InkWell(
      onTap: isAdvancing ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border:
              border != null ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFinalModal(Map<String, dynamic> t) {
    return SingleChildScrollView(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themePanel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeSuccess, width: 4),
          boxShadow: [
            BoxShadow(
              color: themeSuccess.withOpacity(0.4),
              blurRadius: 50,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: themeSuccess,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeSuccess.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.done_all, color: Colors.black, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              t['ui_mission_complete'],
              style: TextStyle(
                color: themeSuccess,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeBorder),
              ),
              child: Text(
                t['ui_area_cert'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            _buildPrimaryBtn(t['ui_restart'], fullReset, themeSuccess),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea(
    double sidebarWidth,
    double diffAB,
    double diffCD,
    double lenAB,
    double lenCD,
    bool isEqual,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onScaleStart: (d) => _onScaleStart(d, constraints, sidebarWidth),
          onScaleUpdate: (d) => _onScaleUpdate(d, constraints, sidebarWidth),
          onScaleEnd: _onScaleEnd,
          child: Container(
            color: Colors.transparent,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: CustomPaint(
              painter: GeometryPainter(
                step: currentStep,
                radius: radius,
                centerO: centerO,
                ptA: _getPtFromAngle(angA, radius),
                ptB: _getPtFromAngle(angB, radius),
                ptC: _getPtFromAngle(angC, radius),
                ptD: _getPtFromAngle(angD, radius),
                angA: angA,
                angB: angB,
                angC: angC,
                angD: angD,
                diffAB: diffAB,
                diffCD: diffCD,
                lenAB: lenAB,
                lenCD: lenCD,
                isEqual: isEqual,
                dragPt: dragPt,
                showChordAB: showChordAB,
                showChordCD: showChordCD,
                showAngles: showAngles,
                canvasOffset: canvasDelta,
                canvasScale: canvasScale,
                themePrimary: themePrimary,
                themeSecondary: themeSecondary,
                themeSuccess: themeSuccess,
                isSidebarOpen: isSidebarOpen,
                sidebarWidth: sidebarWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class GeometryPainter extends CustomPainter {
  final int step;
  final double radius;
  final Offset centerO;
  final Offset ptA, ptB, ptC, ptD;
  final double angA, angB, angC, angD;
  final double diffAB, diffCD;
  final double lenAB, lenCD;
  final bool isEqual;
  final String? dragPt;
  final bool showChordAB, showChordCD, showAngles;
  final Offset canvasOffset;
  final double canvasScale;
  final Color themePrimary, themeSecondary, themeSuccess;
  final bool isSidebarOpen;
  final double sidebarWidth;

  GeometryPainter({
    required this.step,
    required this.radius,
    required this.centerO,
    required this.ptA,
    required this.ptB,
    required this.ptC,
    required this.ptD,
    required this.angA,
    required this.angB,
    required this.angC,
    required this.angD,
    required this.diffAB,
    required this.diffCD,
    required this.lenAB,
    required this.lenCD,
    required this.isEqual,
    required this.dragPt,
    required this.showChordAB,
    required this.showChordCD,
    required this.showAngles,
    required this.canvasOffset,
    required this.canvasScale,
    required this.themePrimary,
    required this.themeSecondary,
    required this.themeSuccess,
    required this.isSidebarOpen,
    required this.sidebarWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth =
        isSidebarOpen ? size.width - sidebarWidth : size.width;
    final double cx = (isSidebarOpen ? sidebarWidth : 0) + (availableWidth / 2);
    final double cy = size.height / 2;

    canvas.save();
    canvas.translate(cx + canvasOffset.dx, cy + canvasOffset.dy);
    canvas.scale(canvasScale);

    // Grid
    final Paint gridPaint =
        Paint()
          ..color = themePrimary.withOpacity(0.15)
          ..strokeWidth = 1 / canvasScale;
    double stepSize = 40.0;
    for (double x = -2000; x < 2000; x += stepSize) {
      canvas.drawLine(Offset(x, -2000), Offset(x, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, x), Offset(2000, x), gridPaint);
    }

    Color activeColorAB = (isEqual && step > 6) ? themeSuccess : themePrimary;
    Color activeColorCD = (isEqual && step > 6) ? themeSuccess : themeSecondary;

    // Circle
    canvas.drawCircle(
      centerO,
      radius,
      Paint()
        ..color = activeColorAB.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      centerO,
      radius,
      Paint()
        ..color = activeColorAB.withOpacity(0.4)
        ..strokeWidth = 3 / canvasScale
        ..style = PaintingStyle.stroke,
    );

    // Center point O
    canvas.drawCircle(centerO, 6 / canvasScale, Paint()..color = Colors.white);
    _drawText(
      canvas,
      "O",
      15 / canvasScale,
      15 / canvasScale,
      Colors.white,
      16 / canvasScale,
    );

    if (showChordAB) {
      // Triangles AOB Fill
      if (showAngles) {
        Path pathAOB =
            Path()
              ..moveTo(centerO.dx, centerO.dy)
              ..lineTo(ptA.dx, ptA.dy)
              ..lineTo(ptB.dx, ptB.dy)
              ..close();
        canvas.drawPath(
          pathAOB,
          Paint()
            ..color = activeColorAB.withOpacity(0.15)
            ..style = PaintingStyle.fill,
        );
        canvas.drawLine(
          centerO,
          ptA,
          Paint()
            ..color = Colors.white30
            ..strokeWidth = 2 / canvasScale,
        );
        canvas.drawLine(
          centerO,
          ptB,
          Paint()
            ..color = Colors.white30
            ..strokeWidth = 2 / canvasScale,
        );
        _drawAngleArc(canvas, angA, angB, activeColorAB, diffAB);
      }

      canvas.drawLine(
        ptA,
        ptB,
        Paint()
          ..color = activeColorAB
          ..strokeWidth = 4 / canvasScale,
      );

      Offset midAB = (ptA + ptB) / 2;
      _drawText(
        canvas,
        lenAB.toStringAsFixed(1),
        midAB.dx,
        midAB.dy - 20 / canvasScale,
        activeColorAB,
        14 / canvasScale,
      );
    }

    if (showChordCD) {
      // Triangles COD Fill
      if (showAngles) {
        Path pathCOD =
            Path()
              ..moveTo(centerO.dx, centerO.dy)
              ..lineTo(ptC.dx, ptC.dy)
              ..lineTo(ptD.dx, ptD.dy)
              ..close();
        canvas.drawPath(
          pathCOD,
          Paint()
            ..color = activeColorCD.withOpacity(0.15)
            ..style = PaintingStyle.fill,
        );
        canvas.drawLine(
          centerO,
          ptC,
          Paint()
            ..color = Colors.white30
            ..strokeWidth = 2 / canvasScale,
        );
        canvas.drawLine(
          centerO,
          ptD,
          Paint()
            ..color = Colors.white30
            ..strokeWidth = 2 / canvasScale,
        );
        _drawAngleArc(canvas, angC, angD, activeColorCD, diffCD);
      }

      canvas.drawLine(
        ptC,
        ptD,
        Paint()
          ..color = activeColorCD
          ..strokeWidth = 4 / canvasScale,
      );

      Offset midCD = (ptC + ptD) / 2;
      _drawText(
        canvas,
        lenCD.toStringAsFixed(1),
        midCD.dx,
        midCD.dy - 20 / canvasScale,
        activeColorCD,
        14 / canvasScale,
      );
    }

    // Draw Nodes
    _drawNode(canvas, ptA, "A", activeColorAB, dragPt == 'A');
    _drawNode(canvas, ptB, "B", activeColorAB, dragPt == 'B');
    _drawNode(canvas, ptC, "C", activeColorCD, dragPt == 'C');
    _drawNode(canvas, ptD, "D", activeColorCD, dragPt == 'D');

    canvas.restore();
  }

  void _drawAngleArc(
    Canvas canvas,
    double a,
    double b,
    Color color,
    double diff,
  ) {
    double start = a * math.pi / 180;
    double end = b * math.pi / 180;

    // Determine the minor arc
    double sweep = end - start;
    if (sweep > math.pi) sweep -= 2 * math.pi;
    if (sweep < -math.pi) sweep += 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: centerO, radius: 25 / canvasScale),
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 3 / canvasScale
        ..style = PaintingStyle.stroke,
    );

    double mid = start + sweep / 2;
    Offset arcMid = Offset(
      math.cos(mid) * 45 / canvasScale,
      math.sin(mid) * 45 / canvasScale,
    );
    _drawText(
      canvas,
      "${diff.round()}°",
      arcMid.dx,
      arcMid.dy,
      color,
      12 / canvasScale,
    );
  }

  void _drawNode(Canvas canvas, Offset p, String label, Color c, bool isDrag) {
    canvas.drawCircle(
      p,
      isDrag ? 12 / canvasScale : 8 / canvasScale,
      Paint()..color = c,
    );
    if (isDrag) {
      canvas.drawCircle(
        p,
        16 / canvasScale,
        Paint()
          ..color = c
          ..strokeWidth = 2 / canvasScale
          ..style = PaintingStyle.stroke,
      );
    }
    Offset pDir = p.distance > 0 ? p / p.distance : const Offset(1, 0);
    _drawText(
      canvas,
      label,
      p.dx + pDir.dx * 25 / canvasScale,
      p.dy + pDir.dy * 25 / canvasScale,
      Colors.white,
      16 / canvasScale,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color color,
    double size,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Background for text readability
    Rect bgRect = Rect.fromCenter(
      center: Offset(x + textPainter.width / 2, y + textPainter.height / 2),
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = Colors.black87,
    );

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant GeometryPainter oldDelegate) {
    return true;
  }
}

const Map<String, Map<String, dynamic>> db = {
  'en': {
    'btn_init': "DEPLOY CENTER O",
    'btn_chord_ab': "PLOT CHORD AB",
    'btn_verify': "VERIFY",
    'btn_chord_cd': "PLOT CHORD CD",
    'btn_proceed': "PROCEED",
    'btn_certify': "CERTIFY THEOREM",
    'header_title': "The Equalizer",
    'header_subtitle': "Class 9 • CIRCLE THEOREMS",
    'objective_lbl': "Mission Objective",
    'objective':
        "Prove that equal chords of a circle subtend equal angles at the center.",
    'instr_lbl': "Instructions",
    'instr':
        "Drag the nodes A, B, C, and D around the circular boundary.\n\nObserve how the lengths of the chords (AB and CD) mathematically relate to the central angles (∠AOB and ∠COD).\n\nTry adjusting the nodes until both chords are exactly equal in length!",
    'output_lbl': "Live Target Output",
    'chord_ab': "Chord AB Length",
    'chord_cd': "Chord CD Length",
    'angle_aob': "Angle ∠AOB",
    'angle_cod': "Angle ∠COD",
    'status_equal': "EQUAL CHORDS DETECTED!\nAngles are perfectly equal.",
    'status_unequal': "Chords are unequal.\nAdjust nodes to equalize.",
    'concept_lbl': "Core Concept",
    'concept':
        "Theorem: Equal chords of a circle subtend equal angles at the center.\n\nWhen Chord AB = Chord CD, the triangles ∆AOB and ∆COD are congruent by SSS (Side-Side-Side) since OA = OB = OC = OD (radii). Therefore, ∠AOB = ∠COD.",
    'ui_mission_control': "Mission Actions",
    'status_lbl': "Mission Status",
    'procedural_steps_lbl': "Procedural Steps",
    'hint_len_ab': "Length of AB?",
    'hint_len_cd': "Length of CD?",
    'hint_ang_aob': "Angle AOB?",
    'hint_ang_cod': "Angle COD?",
    'hint_verify_eq': "Angle AOB == Angle COD? (= / yes)",
    'msg_error': "CRITICAL MISMATCH!",
    'msg_success': "SYSTEM VERIFIED!",
    'msg_drag_cd': "CANVAS UNLOCKED. ROTATE CHORDS TO TEST INVARIANCE.",
    'steps': [
      "1. Initialize System",
      "2. Plot Chord 1 (AB)",
      "3. Measure Chord AB",
      "4. Plot Chord 2 (CD)",
      "5. Measure Chord CD",
      "6. Measure Angle AOB",
      "7. Measure Angle COD",
      "8. Verify Equality",
      "9. Dynamic Stress Test",
      "10. Final Certification",
    ],
    'ui_reset': "RESET",
    'ui_step': "Step",
    'ui_mission_complete': "MISSION COMPLETE!",
    'ui_area_cert':
        "Theorem Certified.\nEqual chords subtend equal central angles.",
    'ui_restart': "RESTART MISSION",
  },
  'hi': {
    'btn_init': "केंद्र O तैनात करें",
    'btn_chord_ab': "जीवा AB प्लॉट करें",
    'btn_verify': "सत्यापित करें",
    'btn_chord_cd': "जीवा CD प्लॉट करें",
    'btn_proceed': "आगे बढ़ें",
    'btn_certify': "प्रमेय प्रमाणित करें",
    'header_title': "द इक्वलाइज़र",
    'header_subtitle': "कक्षा 9 • वृत्त के प्रमेय",
    'objective_lbl': "मिशन का उद्देश्य",
    'objective':
        "सिद्ध करें कि एक वृत्त की समान जीवाएँ केंद्र पर समान कोण अंतरित करती हैं।",
    'instr_lbl': "निर्देश",
    'instr':
        "नोड्स A, B, C और D को गोलाकार सीमा के चारों ओर खींचें।\n\nदेखें कि जीवाओं (AB और CD) की लंबाई केंद्रीय कोणों (∠AOB और ∠COD) से गणितीय रूप से कैसे संबंधित है।\n\nनोड्स को तब तक समायोजित करने का प्रयास करें जब तक कि दोनों जीवाओं की लंबाई बिल्कुल समान न हो जाए!",
    'output_lbl': "लाइव लक्ष्य आउटपुट",
    'chord_ab': "जीवा AB की लंबाई",
    'chord_cd': "जीवा CD की लंबाई",
    'angle_aob': "कोण ∠AOB",
    'angle_cod': "कोण ∠COD",
    'status_equal': "समान जीवाओं का पता चला!\nकोण पूरी तरह से समान हैं।",
    'status_unequal':
        "जीवाएँ असमान हैं।\nसमान करने के लिए नोड्स समायोजित करें।",
    'concept_lbl': "मूल अवधारणा",
    'concept':
        "प्रमेय: एक वृत्त की समान जीवाएँ केंद्र पर समान कोण अंतरित करती हैं।\n\nजब जीवा AB = जीवा CD, तो त्रिभुज ∆AOB और ∆COD SSS (भुजा-भुजा-भुजा) द्वारा सर्वांगसम होते हैं क्योंकि OA = OB = OC = OD (त्रिज्या)। इसलिए, ∠AOB = ∠COD।",
    'ui_mission_control': "मिशन क्रियाएं",
    'status_lbl': "मिशन स्थिति",
    'procedural_steps_lbl': "प्रक्रियात्मक चरण",
    'hint_len_ab': "AB की लंबाई?",
    'hint_len_cd': "CD की लंबाई?",
    'hint_ang_aob': "कोण AOB?",
    'hint_ang_cod': "कोण COD?",
    'hint_verify_eq': "कोण AOB == कोण COD? (= / yes)",
    'msg_error': "गंभीर बेमेल!",
    'msg_success': "सिस्टम सत्यापित!",
    'msg_drag_cd':
        "कैनवास अनलॉक। अपरिवर्तनीयता का परीक्षण करने के लिए जीवाओं को घुमाएं।",
    'steps': [
      "1. सिस्टम प्रारंभ करें",
      "2. जीवा 1 (AB) प्लॉट करें",
      "3. जीवा AB को मापें",
      "4. जीवा 2 (CD) प्लॉट करें",
      "5. जीवा CD को मापें",
      "6. कोण AOB को मापें",
      "7. कोण COD को मापें",
      "8. समानता सत्यापित करें",
      "9. गतिशील तनाव परीक्षण",
      "10. अंतिम प्रमाणीकरण",
    ],
    'ui_reset': "रीसेट",
    'ui_step': "चरण",
    'ui_mission_complete': "मिशन पूरा हुआ!",
    'ui_area_cert':
        "प्रमेय प्रमाणित।\nसमान जीवाएँ समान केंद्रीय कोण अंतरित करती हैं।",
    'ui_restart': "मिशन पुनरारंभ करें",
  },
};