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
  runApp(const SemiCircleSniperApp());
}

class SemiCircleSniperApp extends StatefulWidget {
  const SemiCircleSniperApp({super.key});

  @override
  State<SemiCircleSniperApp> createState() => _SemiCircleSniperAppState();
}

class _SemiCircleSniperAppState extends State<SemiCircleSniperApp>
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

  // Geometry features
  Offset ptA = const Offset(-150, 0);
  Offset ptB = const Offset(150, 0);
  Offset ptC = const Offset(0, -150);
  Offset ghostC = const Offset(0, -50);

  bool isCannonVisible = false;
  bool isGhostVisible = false;
  bool isHudActive = false;
  bool showCenterAndRadii = false;

  bool isObstacleVisible = false;
  Offset obstaclePos = const Offset(80, -80);

  bool lasersActive = false;
  bool lasersHit = false;

  String? dragPt;

  // Canvas Panning/Zooming
  Offset canvasDelta = Offset.zero;
  Offset _initialDelta = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  double canvasScale = 1.0;
  double _initialScale = 1.0;

  // Text Controllers
  final TextEditingController _calcCtrl = TextEditingController();
  String calcInput = '';

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
  final Color themeAccent = const Color(0xFFF472B6);
  final Color themePrimary = const Color(0xFF3B82F6);
  final Color themeSecondary = const Color(0xFF8B5CF6);
  final Color themeSuccess = const Color(0xFF22C55E);
  final Color themeError = const Color(0xFFEF4444);
  final Color themeWarn = const Color(0xFFEAB308);

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

    _calcCtrl.dispose();
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
        _calcCtrl.clear();
        calcInput = '';
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

      ptA = const Offset(-150, 0);
      ptB = const Offset(150, 0);
      ptC = const Offset(0, -150);
      ghostC = const Offset(0, -50);

      isCannonVisible = false;
      isGhostVisible = false;
      isHudActive = false;
      showCenterAndRadii = false;
      isObstacleVisible = false;
      lasersActive = false;
      dragPt = null;

      canvasDelta = Offset.zero;
      _initialDelta = Offset.zero;
      _startFocalPoint = Offset.zero;
      canvasScale = 1.0;
      _initialScale = 1.0;

      calcInput = '';
      _calcCtrl.clear();

      showFinalModal = false;
      isSidebarOpen = true;
    });
  }

  void handleAction(String actionType) {
    playClick();
    final t = db[currentLang]!;

    if (currentStep == 0 && actionType == 'init') {
      setState(() => isGhostVisible = true);
      completeStep();
    } else if (currentStep == 2 && actionType == 'fire') {
      _fireLaser(false);
    } else if (currentStep == 3 && actionType == 'hud') {
      setState(() => isHudActive = true);
      playSuccess();
      completeStep();
    } else if (currentStep == 5 && actionType == 'analyze') {
      setState(() => showCenterAndRadii = true);
      playSuccess();
      completeStep();
    } else if (currentStep == 6 && actionType == 'submit') {
      if (calcInput.trim() == '90') {
        playSuccess();
        showToast(t['msg_correct'], false);
        setState(() => isObstacleVisible = true);
        ptC = const Offset(60, -137.47);
        completeStep();
      } else {
        playError();
        showToast(t['msg_error'], true);
      }
    } else if (currentStep == 8 && actionType == 'fire_final') {
      _fireLaser(true);
    } else if (currentStep == 9 && actionType == 'review') {
      completeStep();
    }
  }

  void _fireLaser(bool isFinal) {
    playPower();
    setState(() {
      lasersActive = true;
      lasersHit = isFinal;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        lasersActive = false;
        if (!isFinal) {
          playError();
          showToast(db[currentLang]!['msg_deflect'], true);
          completeStep();
        } else {
          playSuccess();
          showToast(db[currentLang]!['msg_destroy'], false);
          isObstacleVisible = false;
          completeStep();
        }
      });
    });
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
    final double cy = constraints.maxHeight / 2 + canvasDelta.dy + 40;

    _startFocalPoint = details.focalPoint;
    _initialScale = canvasScale;
    _initialDelta = canvasDelta;

    Offset localPoint =
        (details.localFocalPoint - Offset(cx, cy)) / canvasScale;
    double hitRadius = 50.0 / canvasScale;

    if (currentStep == 1 && isGhostVisible) {
      if ((localPoint - ghostC).distance < hitRadius) {
        dragPt = 'ghost';
        playClick();
      }
    } else if ((currentStep == 4 || currentStep == 7) && isCannonVisible) {
      if ((localPoint - ptC).distance < hitRadius) {
        dragPt = 'cannon';
        playClick();
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
        canvasDelta = _initialDelta + (details.focalPoint - _startFocalPoint);
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
    final double cy = constraints.maxHeight / 2 + canvasDelta.dy + 40;

    Offset localPoint =
        (details.localFocalPoint - Offset(cx, cy)) / canvasScale;

    setState(() {
      if (dragPt == 'ghost') {
        ghostC = localPoint;
        double distToCenter = localPoint.distance;
        if (distToCenter > radius - 30 &&
            distToCenter < radius + 30 &&
            localPoint.dy < 0) {
          isGhostVisible = false;
          isCannonVisible = true;
          _setCannonOnArc(localPoint);
          dragPt = null;
          playSuccess();
          completeStep();
        }
      } else if (dragPt == 'cannon') {
        _setCannonOnArc(localPoint);
        if (currentStep == 7 && ptC.dx < -40) {
          dragPt = null;
          playSuccess();
          completeStep();
        }
      }
    });
  }

  void _setCannonOnArc(Offset point) {
    double angle = math.atan2(point.dy, point.dx);
    if (angle > 0) angle = -0.01;
    if (angle < -math.pi) angle = -math.pi + 0.01;
    ptC = Offset(radius * math.cos(angle), radius * math.sin(angle));
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (dragPt == 'cannon' && currentStep == 4) {
      playSuccess();
      completeStep();
    }
    setState(() => dragPt = null);
  }

  double getAngle(Offset pPrev, Offset pCurr, Offset pNext) {
    double v1x = pPrev.dx - pCurr.dx;
    double v1y = pPrev.dy - pCurr.dy;
    double v2x = pNext.dx - pCurr.dx;
    double v2y = pNext.dy - pCurr.dy;
    double mag1 = math.sqrt(v1x * v1x + v1y * v1y);
    double mag2 = math.sqrt(v2x * v2x + v2y * v2y);
    if (mag1 * mag2 == 0) return 0;
    double dot = (v1x * v2x + v1y * v2y) / (mag1 * mag2);
    dot = dot.clamp(-1.0, 1.0);
    return (math.acos(dot) * 180 / math.pi);
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) return _buildShutterScreen();

    final t = db[currentLang]!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = screenWidth * 0.32;

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
            Positioned.fill(child: _buildCanvasArea(sidebarWidth)),

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
                child: _buildSidebar(t),
              ),
            ),

            // Action Panel (Compact, Bottom Center)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 16,
              left: isSidebarOpen ? sidebarWidth + 16 : 16,
              right: 16,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildActionPanel(t),
              ),
            ),

            // Top-Left Menu Icon
            if (!isSidebarOpen)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: themePanel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeBorder),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    color: Colors.white,
                    onPressed: () {
                      playClick();
                      setState(() => isSidebarOpen = true);
                    },
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
                        colors: [Color(0xFFF472B6), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFF472B6,
                          ).withOpacity(0.3 + (_pulseController.value * 0.3)),
                          blurRadius: 30 + (_pulseController.value * 20),
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                t['app_title'],
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
                  t['btn_start'].toUpperCase(),
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

  // Sidebar containing everything in one scrollable view
  Widget _buildSidebar(Map<String, dynamic> t) {
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
              const SizedBox(height: 48),

              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              t['app_title'],
                              style: TextStyle(
                                color: themePrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                ],
              ),
              const SizedBox(height: 24),

              // Controls
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
              const SizedBox(height: 24),

              // Status & Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t['status_label'].toUpperCase(),
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
                      color: themePrimary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: themePrimary, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Objective
              _buildSectionTitle(t['objective_lbl'], themeAccent),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: themeBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeBorder),
                ),
                child: Text(
                  t['levels'][currentStep]['obj'],
                  style: TextStyle(color: themeText, fontSize: 13, height: 1.5),
                ),
              ),

              // Procedural Steps
              _buildSectionTitle(t['procedural_lbl'], themePrimary),
              Column(
                children: List.generate(10, (index) {
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
                              t['levels'][index]['stepLine'],
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

              // Core Concept
              _buildSectionTitle(t['concept_lbl'], themeSuccess),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeSuccess.withOpacity(0.5)),
                ),
                child: Text(
                  // Using null-aware operator just as an extra safeguard, though the map is fixed below
                  t['levels'][currentStep]['concept'] ?? '',
                  style: TextStyle(
                    color: themeMuted,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),

              // Untranslated Footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 40),
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

  Widget _buildActionPanel(Map<String, dynamic> t) {
    Widget content = const SizedBox();

    if (currentStep == 0) {
      content = _buildPrimaryBtn(
        t['btn_init'],
        () => handleAction('init'),
        themePrimary,
      );
    } else if (currentStep == 1) {
      content = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "DRAG THE GHOST CANNON ONTO THE ARC",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      );
    } else if (currentStep == 2) {
      content = _buildPrimaryBtn(
        t['btn_fire'],
        () => handleAction('fire'),
        themeError,
        icon: Icons.bolt,
      );
    } else if (currentStep == 3) {
      content = _buildPrimaryBtn(
        t['btn_hud'],
        () => handleAction('hud'),
        themeWarn,
        icon: Icons.remove_red_eye,
      );
    } else if (currentStep == 4) {
      content = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themePrimary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "DRAG CANNON TO DISCOVER THE 90° ANGLE",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      );
    } else if (currentStep == 5) {
      content = _buildPrimaryBtn(
        t['btn_analyze'],
        () => handleAction('analyze'),
        themePrimary,
        icon: Icons.memory,
      );
    } else if (currentStep == 6) {
      content = Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              t['quiz_label'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _calcCtrl,
              enabled: !isAdvancing,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: "?",
                hintStyle: TextStyle(color: themeMuted, fontSize: 12),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => calcInput = v),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: _buildPrimaryBtn(
              t['btn_submit'],
              () => handleAction('submit'),
              themeSuccess,
            ),
          ),
        ],
      );
    } else if (currentStep == 7) {
      content = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "DRAG CANNON LEFT TO EVADE OBSTACLE",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      );
    } else if (currentStep == 8) {
      content = _buildPrimaryBtn(
        t['btn_fire'],
        () => handleAction('fire_final'),
        themeError,
        icon: Icons.local_fire_department,
      );
    } else if (currentStep == 9) {
      content = _buildPrimaryBtn(
        t['btn_review'],
        () => handleAction('review'),
        themePrimary,
        icon: Icons.rate_review,
      );
    }

    // Mathematical HUD injected into the Action Panel
    Widget mathHud = const SizedBox();
    if (isHudActive && isCannonVisible) {
      double ang = getAngle(ptA, ptC, ptB);
      String angStr = ang.toStringAsFixed(1);
      if (ang.isNaN) angStr = "90.0";

      mathHud = Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: double.infinity, height: 1, color: themeBorder),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "∠ ACB",
                  style: TextStyle(
                    color: themeMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$angStr°",
                  style: TextStyle(
                    color: themeAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeAccent, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gamepad, color: themeAccent, size: 14),
              const SizedBox(width: 6),
              Text(
                t['mission_control'].toUpperCase(),
                style: TextStyle(
                  color: themeAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
          mathHud,
        ],
      ),
    );
  }

  Widget _buildPrimaryBtn(
    String text,
    VoidCallback onTap,
    Color bgColor, {
    Color textColor = Colors.white,
    IconData? icon,
  }) {
    return InkWell(
      onTap: isAdvancing ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 14),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
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
              child: const Icon(Icons.check, color: Colors.black, size: 40),
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

  Widget _buildCanvasArea(double sidebarWidth) {
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
                ptA: ptA,
                ptB: ptB,
                ptC: ptC,
                ghostC: ghostC,
                isCannonVisible: isCannonVisible,
                isGhostVisible: isGhostVisible,
                showCenterAndRadii: showCenterAndRadii,
                isObstacleVisible: isObstacleVisible,
                obstaclePos: obstaclePos,
                lasersActive: lasersActive,
                lasersHit: lasersHit,
                dragPt: dragPt,
                canvasOffset: canvasDelta,
                canvasScale: canvasScale,
                themePrimary: themePrimary,
                themeSecondary: themeSecondary,
                themeAccent: themeAccent,
                themeSuccess: themeSuccess,
                themeError: themeError,
                themeMuted: themeMuted,
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
  final Offset ptA, ptB, ptC, ghostC;
  final bool isCannonVisible, isGhostVisible, showCenterAndRadii;
  final bool isObstacleVisible;
  final Offset obstaclePos;
  final bool lasersActive, lasersHit;
  final String? dragPt;
  final Offset canvasOffset;
  final double canvasScale;
  final Color themePrimary,
      themeSecondary,
      themeAccent,
      themeSuccess,
      themeError,
      themeMuted;
  final bool isSidebarOpen;
  final double sidebarWidth;

  GeometryPainter({
    required this.step,
    required this.radius,
    required this.centerO,
    required this.ptA,
    required this.ptB,
    required this.ptC,
    required this.ghostC,
    required this.isCannonVisible,
    required this.isGhostVisible,
    required this.showCenterAndRadii,
    required this.isObstacleVisible,
    required this.obstaclePos,
    required this.lasersActive,
    required this.lasersHit,
    required this.dragPt,
    required this.canvasOffset,
    required this.canvasScale,
    required this.themePrimary,
    required this.themeSecondary,
    required this.themeAccent,
    required this.themeSuccess,
    required this.themeError,
    required this.themeMuted,
    required this.isSidebarOpen,
    required this.sidebarWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth =
        isSidebarOpen ? size.width - sidebarWidth : size.width;
    final double cx = (isSidebarOpen ? sidebarWidth : 0) + (availableWidth / 2);
    final double cy = size.height / 2 + 40;

    double baseScale = math
        .min((availableWidth * 0.9) / 400, size.height / 400)
        .clamp(0.5, 2.0);
    double effectiveScale = baseScale * canvasScale;

    canvas.save();
    canvas.translate(cx + canvasOffset.dx, cy + canvasOffset.dy);
    canvas.scale(effectiveScale);

    // Grid
    final Paint gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 1 / effectiveScale;
    double stepSize = 40.0;
    for (double x = -2000; x < 2000; x += stepSize) {
      canvas.drawLine(Offset(x, -2000), Offset(x, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, x), Offset(2000, x), gridPaint);
    }

    // Arc (Semi-circle)
    canvas.drawArc(
      Rect.fromCircle(center: centerO, radius: radius),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = themePrimary
        ..strokeWidth = 4 / effectiveScale
        ..style = PaintingStyle.stroke,
    );

    // Diameter
    canvas.drawLine(
      ptA,
      ptB,
      Paint()
        ..color = themeAccent
        ..strokeWidth = 3 / effectiveScale,
    );

    // A & B Nodes
    _drawNode(canvas, ptA, "A", themeAccent, effectiveScale);
    _drawNode(canvas, ptB, "B", themeAccent, effectiveScale);

    // Center & Radii
    if (showCenterAndRadii) {
      _drawNode(canvas, centerO, "O", themePrimary, effectiveScale);
      _drawDashedLine(canvas, centerO, ptC, themeMuted, 2 / effectiveScale);
    }

    // Lasers
    if (lasersActive) {
      final Paint laserPaint =
          Paint()
            ..color = themeSuccess
            ..strokeWidth = 3 / effectiveScale
            ..style = PaintingStyle.stroke;

      canvas.drawLine(ptA, ptC, laserPaint);
      canvas.drawLine(ptC, ptB, laserPaint);

      if (!lasersHit && step <= 3) {
        _drawDashedLine(
          canvas,
          ptB,
          Offset(ptB.dx + 100, ptB.dy - 100),
          themeError,
          2 / effectiveScale,
        );
        canvas.drawArc(
          Rect.fromCircle(center: ptB, radius: 30 / effectiveScale),
          math.pi,
          math.pi / 2,
          false,
          Paint()
            ..color = themePrimary
            ..strokeWidth = 5 / effectiveScale
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Obstacle
    if (isObstacleVisible) {
      canvas.drawCircle(
        obstaclePos,
        25 / effectiveScale,
        Paint()..color = const Color(0xFF64748B),
      );
      canvas.drawCircle(
        obstaclePos,
        25 / effectiveScale,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2 / effectiveScale
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        Offset(obstaclePos.dx - 5, obstaclePos.dy - 5),
        5 / effectiveScale,
        Paint()..color = Colors.black38,
      );
    }

    // Cannon Drawing
    void drawCannon(Offset pos, Color color, bool isMain) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      double angle = math.atan2(-pos.dy, -pos.dx);
      canvas.rotate(angle);

      canvas.drawCircle(
        Offset.zero,
        16 / effectiveScale,
        Paint()..color = color,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          -6 / effectiveScale,
          25 / effectiveScale,
          12 / effectiveScale,
        ),
        Paint()..color = const Color(0xFF0F172A),
      );

      if (isMain) {
        _drawText(canvas, "C", 0, 0, Colors.white, 14 / effectiveScale);
      }
      canvas.restore();
    }

    if (isCannonVisible) drawCannon(ptC, themePrimary, true);
    if (isGhostVisible) {
      canvas.saveLayer(null, Paint()..color = Colors.white.withOpacity(0.5));
      drawCannon(ghostC, Colors.white, false);
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double width,
  ) {
    double distance = (p1 - p2).distance;
    double dashLen = 8;
    double gapLen = 6;
    int dashCount = (distance / (dashLen + gapLen)).floor();
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;

    double x = p1.dx;
    double y = p1.dy;
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = width;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dx * dashLen, y + dy * dashLen),
        paint,
      );
      x += dx * (dashLen + gapLen);
      y += dy * (dashLen + gapLen);
    }
  }

  void _drawNode(Canvas canvas, Offset p, String label, Color c, double scale) {
    canvas.drawCircle(p, 14 / scale, Paint()..color = c);
    canvas.drawCircle(
      p,
      14 / scale,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2 / scale
        ..style = PaintingStyle.stroke,
    );
    _drawText(canvas, label, p.dx, p.dy, Colors.white, 16 / scale);
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
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant GeometryPainter oldDelegate) {
    return true;
  }
}

const Map<String, Map<String, dynamic>> db = {
  'en': {
    'app_title': "Semi-Circle Sniper",
    'header_subtitle': "Class 9 • Circles",
    'btn_start': "Start Mission",
    'mission_control': "Mission Control",
    'status_label': "Progress",
    'objective_lbl': "Objective",
    'procedural_lbl': "Steps",
    'concept_lbl': "Concept",
    'btn_init': "Initialize Defense",
    'btn_fire': "Fire Laser",
    'btn_hud': "Activate HUD",
    'btn_analyze': "Analyze Physics",
    'btn_submit': "Submit",
    'btn_review': "Mission Review",
    'quiz_label': "Angle: 180 / 2 =",
    'msg_deflect': "Shield Deflected!",
    'msg_destroy': "Target Destroyed!",
    'msg_correct': "Correct!",
    'msg_error': "Incorrect. Try 180 / 2",
    'ui_step': "Step",
    'ui_reset': "RESET",
    'ui_mission_complete': "MISSION COMPLETE!",
    'ui_area_cert': "Theorem Certified: Inscribed angle is 90°.",
    'ui_restart': "RESTART",
    'levels': [
      {
        'obj': "Identify diameter endpoints A and B.",
        'stepLine': "Locate diameter AB and init defense.",
        'concept': "Diameter AB divides circle into semi-circles.",
      },
      {
        'obj': "Deploy the phantom cannon.",
        'stepLine': "Drag phantom cannon onto the blue arc.",
        'concept': "The semi-circle arc is the firing boundary.",
      },
      {
        'obj': "Perform a test fire.",
        'stepLine': "Fire at Target B to test trajectory.",
        'concept': "Sight lines connect cannon to endpoints.",
      }, // TYPO FIXED HERE
      {
        'obj': "Scan shield deflection.",
        'stepLine': "Activate HUD to scan the impact angle.",
        'concept': "Lasers deflect unless hitting at exactly 90°.",
      },
      {
        'obj': "Discover the invariant angle.",
        'stepLine': "Drag cannon to find the invariant 90°.",
        'concept': "Angles inscribed in a semi-circle are 90°.",
      },
      {
        'obj': "Link to the center.",
        'stepLine': "Reveal the center O to analyze link.",
        'concept': "Central angle is formed by radii to endpoints.",
      },
      {
        'obj': "Solve the inscribed formula.",
        'stepLine': "Submit the inscribed angle formula.",
        'concept': "Circumference angle is half of center angle.",
      },
      {
        'obj': "Evade the obstacle.",
        'stepLine': "Drag cannon left to evade obstacle.",
        'concept': "We can move anywhere on the arc for a 90° shot.",
      },
      {
        'obj': "Execute final strike.",
        'stepLine': "Fire final strike with clear sight.",
        'concept': "90° shots penetrate the shield successfully.",
      },
      {
        'obj': "Review boundary conditions.",
        'stepLine': "Review mission to evaluate conditions.",
        'concept': "If base is a chord, inscribed angle isn't 90°.",
      },
    ],
  },
  'hi': {
    'app_title': "अर्ध-वृत्त स्नाइपर",
    'header_subtitle': "कक्षा 9 • वृत्त",
    'btn_start': "मिशन शुरू करें",
    'mission_control': "मिशन नियंत्रण",
    'status_label': "प्रगति",
    'objective_lbl': "उद्देश्य",
    'procedural_lbl': "चरण",
    'concept_lbl': "अवधारणा",
    'btn_init': "रक्षा प्रारंभ करें",
    'btn_fire': "फायर लेजर",
    'btn_hud': "HUD सक्रिय करें",
    'btn_analyze': "भौतिकी विश्लेषण",
    'btn_submit': "जमा करें",
    'btn_review': "मिशन समीक्षा",
    'quiz_label': "कोण: 180 / 2 =",
    'msg_deflect': "ढाल विक्षेपित!",
    'msg_destroy': "लक्ष्य नष्ट!",
    'msg_correct': "सही!",
    'msg_error': "गलत। 180 / 2 प्रयास करें",
    'ui_step': "चरण",
    'ui_reset': "रीसेट",
    'ui_mission_complete': "मिशन पूरा हुआ!",
    'ui_area_cert': "प्रमेय प्रमाणित: अंकित कोण 90° है।",
    'ui_restart': "पुनः प्रारंभ",
    'levels': [
      {
        'obj': "व्यास के सिरों A और B को पहचानें।",
        'stepLine': "व्यास AB खोजें और रक्षा शुरू करें।",
        'concept': "व्यास AB वृत्त को अर्ध-वृत्तों में विभाजित करता है।",
      },
      {
        'obj': "तोप को तैनात करें।",
        'stepLine': "तोप को नीले चाप पर खींचें।",
        'concept': "अर्ध-वृत्त चाप फायरिंग सीमा है।",
      },
      {
        'obj': "परीक्षण फायर करें।",
        'stepLine': "प्रक्षेपवक्र जांचने के लिए फायर करें।",
        'concept': "दृष्टि रेखाएं सिरों को तोप से जोड़ती हैं।",
      },
      {
        'obj': "विक्षेपण स्कैन करें।",
        'stepLine': "प्रभाव कोण के लिए HUD सक्रिय करें।",
        'concept': "90° के बिना लेजर विक्षेपित हो जाते हैं।",
      },
      {
        'obj': "अपरिवर्तनीय कोण खोजें।",
        'stepLine': "90° कोण खोजने के लिए तोप खींचें।",
        'concept': "अर्ध-वृत्त में अंकित कोण 90° होते हैं।",
      },
      {
        'obj': "केंद्र से लिंक करें।",
        'stepLine': "लिंक के लिए केंद्र O प्रकट करें।",
        'concept': "केंद्रीय कोण त्रिज्याओं से बनता है।",
      },
      {
        'obj': "सूत्र हल करें।",
        'stepLine': "अंकित कोण सूत्र जमा करें।",
        'concept': "परिधि कोण केंद्र कोण का आधा होता है।",
      },
      {
        'obj': "बाधा से बचें।",
        'stepLine': "बाधा से बचने के लिए तोप खिसकाएँ।",
        'concept': "चाप पर कहीं भी 90° शॉट संभव है।",
      },
      {
        'obj': "अंतिम प्रहार करें।",
        'stepLine': "स्पष्ट दृष्टि से प्रहार करें।",
        'concept': "90° शॉट ढाल को सफलतापूर्वक भेदता है।",
      },
      {
        'obj': "स्थितियों की समीक्षा करें।",
        'stepLine': "मिशन की स्थितियों की समीक्षा करें।",
        'concept': "यदि आधार जीवा है, तो कोण 90° नहीं होगा।",
      },
    ],
  },
};
