// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PerpendicularCutterApp());
}

class PerpendicularCutterApp extends StatelessWidget {
  const PerpendicularCutterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Perpendicular Cutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFFF472B6),
          surface: Color(0xFF0F172A),
        ),
      ),
      home: const PerpendicularCutterScreen(),
    );
  }
}

class PerpendicularCutterScreen extends StatefulWidget {
  const PerpendicularCutterScreen({super.key});

  @override
  State<PerpendicularCutterScreen> createState() =>
      _PerpendicularCutterScreenState();
}

class _PerpendicularCutterScreenState extends State<PerpendicularCutterScreen>
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

  // Geometric features
  final Offset chordAB_P1 = const Offset(-120, 90);
  final Offset chordAB_P2 = const Offset(120, 90);
  final Offset chordPQ_P1 = const Offset(-90, -120);
  final Offset chordPQ_P2 = const Offset(90, 120);

  Offset laserPos = const Offset(0, 20);
  Offset markerPos = const Offset(-45, -60);

  bool laserLocked = false;
  bool markerLocked = false;
  bool showBisectors = false;

  String? dragPt;

  // Canvas Panning/Zooming (Smooth Setup)
  Offset canvasDelta = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  Offset _initialDelta = Offset.zero;
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
  final Color themeAccent = const Color(0xFFF472B6); // Pink
  final Color themePrimary = const Color(0xFF3B82F6); // Blue
  final Color themeSecondary = const Color(0xFF8B5CF6); // Indigo
  final Color themeSuccess = const Color(0xFF22C55E); // Green
  final Color themeError = const Color(0xFFEF4444); // Red
  final Color themeWarn = const Color(0xFFEAB308); // Yellow

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

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
      // FIX: Only cycle between 'en' and 'hi' since 'te' was removed from the database
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

          if (currentStep == 7) showBisectors = false;

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

      laserPos = const Offset(0, 20);
      markerPos = const Offset(-45, -60);
      laserLocked = false;
      markerLocked = false;
      showBisectors = false;
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

  Offset projectPointOnSegment(Offset p, Offset a, Offset b) {
    double vX = b.dx - a.dx;
    double vY = b.dy - a.dy;
    double uX = p.dx - a.dx;
    double uY = p.dy - a.dy;
    double lenSq = vX * vX + vY * vY;
    double t = math.max(0.0, math.min(1.0, (vX * uX + vY * uY) / lenSq));
    return Offset(a.dx + t * vX, a.dy + t * vY);
  }

  void handleAction(String actionType) {
    playClick();
    final t = db[currentLang]!;

    if (currentStep == 0 && actionType == 'power') {
      completeStep();
    } else if (currentStep == 2 && actionType == 'check') {
      playSuccess();
      showToast(t['msg_bisect'], false);
      completeStep();
    } else if (currentStep == 4 && actionType == 'verify') {
      playSuccess();
      showToast(t['msg_perp'], false);
      completeStep();
    } else if (currentStep == 5 && actionType == 'proceed') {
      completeStep();
    } else if (currentStep == 6 && actionType == 'submit') {
      if (calcInput.trim() == '4') {
        playSuccess();
        showToast(t['msg_correct'], false);
        completeStep();
      } else {
        playError();
        showToast(t['msg_error'], true);
      }
    } else if (currentStep == 7 && actionType == 'bisect') {
      setState(() => showBisectors = true);
      playSuccess();
      showToast(t['msg_correct'], false);
      completeStep();
    } else if (currentStep == 8) {
      if (actionType == '90') {
        playSuccess();
        showToast(t['msg_correct'], false);
        completeStep();
      } else {
        playError();
        showToast(t['msg_error'], true);
      }
    }
  }

  void _onScaleStart(
    ScaleStartDetails details,
    BoxConstraints constraints,
    double sidebarWidth,
  ) {
    if (isAdvancing) return;

    final double availableWidth = isSidebarOpen
        ? constraints.maxWidth - sidebarWidth
        : constraints.maxWidth;
    final double cx =
        (isSidebarOpen ? sidebarWidth : 0) +
        (availableWidth / 2) +
        canvasDelta.dx;
    final double cy = constraints.maxHeight / 2 + canvasDelta.dy;

    _startFocalPoint = details.focalPoint;
    _initialScale = canvasScale;
    _initialDelta = canvasDelta;

    Offset localPoint =
        (details.localFocalPoint - Offset(cx, cy)) / canvasScale;
    double hitRadius = 50.0 / canvasScale;

    if (currentStep == 1 && !laserLocked) {
      if ((localPoint - laserPos).distance < hitRadius) {
        dragPt = 'laser';
        playClick();
      }
    } else if (currentStep == 3 && !markerLocked) {
      if ((localPoint - markerPos).distance < hitRadius) {
        dragPt = 'marker';
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
      // Smooth Canvas Pan & Zoom
      setState(() {
        canvasScale = (_initialScale * details.scale).clamp(0.3, 3.0);
        canvasDelta = _initialDelta + (details.focalPoint - _startFocalPoint);
      });
      return;
    }

    final double availableWidth = isSidebarOpen
        ? constraints.maxWidth - sidebarWidth
        : constraints.maxWidth;
    final double cx =
        (isSidebarOpen ? sidebarWidth : 0) +
        (availableWidth / 2) +
        canvasDelta.dx;
    final double cy = constraints.maxHeight / 2 + canvasDelta.dy;

    Offset localPoint =
        (details.localFocalPoint - Offset(cx, cy)) / canvasScale;
    final t = db[currentLang]!;

    setState(() {
      if (dragPt == 'laser') {
        Offset proj = projectPointOnSegment(localPoint, chordAB_P1, chordAB_P2);
        laserPos = proj;
        if (proj.dx.abs() < 5) {
          laserPos = const Offset(0, 90);
          if (!laserLocked) {
            playSuccess();
            showToast(t['msg_lock'], false);
            laserLocked = true;
            Future.delayed(const Duration(milliseconds: 500), completeStep);
          }
        } else {
          laserLocked = false;
        }
      } else if (dragPt == 'marker') {
        Offset proj = projectPointOnSegment(localPoint, chordPQ_P1, chordPQ_P2);
        markerPos = proj;
        if (proj.distance < 10) {
          markerPos = const Offset(0, 0);
          if (!markerLocked) {
            playSuccess();
            showToast(t['msg_mid'], false);
            markerLocked = true;
            Future.delayed(const Duration(milliseconds: 500), completeStep);
          }
        } else {
          markerLocked = false;
        }
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

            // Left Sidebar Layer (Top-to-bottom scrollable)
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

            // Action Panel (Compact, Bottom Left)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 16,
              left: isSidebarOpen ? sidebarWidth + 16 : 16,
              width: 280,
              child: _buildActionPanel(t),
            ),

            // Top-Left Menu Icon (Visible when sidebar is closed)
            if (!isSidebarOpen)
              Positioned(top: 16, left: 16, child: _buildMenuToggleButton()),

            // Toast Message
            if (toastMessage != null)
              Positioned(
                top: 16,
                left: isSidebarOpen
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
                      color: isErrorToast
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
                        colors: [Color(0xFF3B82F6), Color(0xFFF472B6)],
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
                      Icons.compass_calibration,
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
                label: const Text(
                  "START WORKSHOP",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themePrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 10,
                  shadowColor: themePrimary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuToggleButton() {
    return Container(
      decoration: BoxDecoration(
        color: themePanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeBorder),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: IconButton(
        icon: Icon(
          isSidebarOpen ? Icons.menu_open : Icons.menu,
          color: Colors.white,
        ),
        onPressed: () {
          playClick();
          setState(() => isSidebarOpen = !isSidebarOpen);
        },
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

              // Header Section (Title & Subtitle with Toggle Button)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuToggleButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t['header_title'],
                          style: TextStyle(
                            color: themePrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t['header_subtitle'],
                          style: TextStyle(
                            color: themeAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Controls (Language & Reset)
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
                            t['ui_reset'] ?? "RESET",
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
                    (t['status_lbl'] ?? "PROGRESS").toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "${t['ui_step'] ?? 'Step'} ${currentStep + 1}/10",
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
              _buildSectionTitle(t['lbl_objective'], themeAccent),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: themeBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeBorder),
                ),
                child: Text(
                  t['global_objective'].replaceAll('\$', ''),
                  style: TextStyle(color: themeText, fontSize: 13, height: 1.5),
                ),
              ),

              // Procedural Steps
              _buildSectionTitle(t['lbl_procedure'], themePrimary),
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
                          child: isPast
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
                              t['step${index}_desc'].replaceAll(
                                RegExp(r'[\$\\]'),
                                '',
                              ),
                              style: TextStyle(
                                color: isCurrent
                                    ? themePrimary
                                    : (isPast
                                          ? themeMuted
                                          : themeMuted.withOpacity(0.5)),
                                fontSize: 13,
                                fontWeight: isCurrent
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
              _buildSectionTitle(t['lbl_concept'], themeSuccess),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeSuccess.withOpacity(0.5)),
                ),
                child: Text(
                  t['step${currentStep}_concept'].replaceAll(
                    RegExp(r'[\$\\]|[*]{2}'),
                    '',
                  ),
                  style: TextStyle(
                    color: themeMuted,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),

              // Untranslated Footer at the very bottom of the scroll view
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
        t['btn_power'],
        () => handleAction('power'),
        themePrimary,
      );
    } else if (currentStep == 1) {
      content = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeError.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          t['step1_prompt'].replaceAll(RegExp(r'[\$\\]'), ''),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      );
    } else if (currentStep == 2) {
      content = _buildPrimaryBtn(
        t['btn_check'],
        () => handleAction('check'),
        themeSuccess,
      );
    } else if (currentStep == 3) {
      content = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          t['step3_prompt'].replaceAll(RegExp(r'[\$\\]'), ''),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      );
    } else if (currentStep == 4) {
      content = _buildPrimaryBtn(
        t['btn_connect'],
        () => handleAction('verify'),
        themePrimary,
      );
    } else if (currentStep == 5) {
      content = _buildPrimaryBtn(
        t['btn_proceed'] ?? "Proceed",
        () => handleAction('proceed'),
        themeSuccess,
      );
    } else if (currentStep == 6) {
      content = Row(
        children: [
          Expanded(
            child: TextField(
              controller: _calcCtrl,
              enabled: !isAdvancing,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: "AM = ?",
                hintStyle: TextStyle(color: themeMuted, fontSize: 12),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => calcInput = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPrimaryBtn(
              t['btn_calc'],
              () => handleAction('submit'),
              themeSuccess,
            ),
          ),
        ],
      );
    } else if (currentStep == 7) {
      content = _buildPrimaryBtn(
        t['btn_bisect'],
        () => handleAction('bisect'),
        themeSecondary,
      );
    } else if (currentStep == 8) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['step8_prompt'].replaceAll(RegExp(r'[\$\\]'), ''),
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
            t['q_90'].replaceAll(RegExp(r'[\$\\]'), ''),
            () => handleAction('90'),
            themeSuccess,
          ),
          const SizedBox(height: 8),
          _buildPrimaryBtn(
            t['q_180'].replaceAll(RegExp(r'[\$\\]'), ''),
            () => handleAction('180'),
            const Color(0xFF334155),
          ),
        ],
      );
    } else if (currentStep == 9) {
      content = _buildPrimaryBtn(t['btn_finish'], fullReset, themeSuccess);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 280), // Compact layout
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
              Icon(Icons.gamepad, color: themeAccent, size: 14),
              const SizedBox(width: 6),
              Text(
                (t['ui_mission_control'] ?? "MISSION CONTROL").toUpperCase(),
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
          border: border != null
              ? Border.all(color: Colors.white, width: 2)
              : null,
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
              child: const Icon(Icons.check, color: Colors.black, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              t['ui_mission_complete'] ?? "WORKSHOP COMPLETE",
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
                t['ui_area_cert'] ?? "Geometric Certification Passed.",
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
            _buildPrimaryBtn(
              t['ui_restart'] ?? "RESTART",
              fullReset,
              themeSuccess,
            ),
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
                chordAB_P1: chordAB_P1,
                chordAB_P2: chordAB_P2,
                chordPQ_P1: chordPQ_P1,
                chordPQ_P2: chordPQ_P2,
                laserPos: laserPos,
                markerPos: markerPos,
                laserLocked: laserLocked,
                markerLocked: markerLocked,
                showBisectors: showBisectors,
                dragPt: dragPt,
                canvasOffset: canvasDelta,
                canvasScale: canvasScale,
                themePrimary: themePrimary,
                themeSecondary: themeSecondary,
                themeAccent: themeAccent,
                themeSuccess: themeSuccess,
                themeError: themeError,
                themeWarn: themeWarn,
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
  final Offset chordAB_P1, chordAB_P2;
  final Offset chordPQ_P1, chordPQ_P2;
  final Offset laserPos, markerPos;
  final bool laserLocked, markerLocked, showBisectors;
  final String? dragPt;
  final Offset canvasOffset;
  final double canvasScale;
  final Color themePrimary,
      themeSecondary,
      themeAccent,
      themeSuccess,
      themeError,
      themeWarn;
  final bool isSidebarOpen;
  final double sidebarWidth;

  GeometryPainter({
    required this.step,
    required this.radius,
    required this.centerO,
    required this.chordAB_P1,
    required this.chordAB_P2,
    required this.chordPQ_P1,
    required this.chordPQ_P2,
    required this.laserPos,
    required this.markerPos,
    required this.laserLocked,
    required this.markerLocked,
    required this.showBisectors,
    required this.dragPt,
    required this.canvasOffset,
    required this.canvasScale,
    required this.themePrimary,
    required this.themeSecondary,
    required this.themeAccent,
    required this.themeSuccess,
    required this.themeError,
    required this.themeWarn,
    required this.isSidebarOpen,
    required this.sidebarWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth = isSidebarOpen
        ? size.width - sidebarWidth
        : size.width;
    final double cx = (isSidebarOpen ? sidebarWidth : 0) + (availableWidth / 2);
    final double cy = size.height / 2;

    double baseScale = math
        .min((availableWidth * 0.9) / 400, size.height / 400)
        .clamp(0.5, 2.0);
    double effectiveScale = baseScale * canvasScale;

    canvas.save();
    canvas.translate(cx + canvasOffset.dx, cy + canvasOffset.dy);
    canvas.scale(effectiveScale);

    // Grid
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1 / effectiveScale;
    double stepSize = 40.0;
    for (double x = -2000; x < 2000; x += stepSize) {
      canvas.drawLine(Offset(x, -2000), Offset(x, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, x), Offset(2000, x), gridPaint);
    }

    // Main Circle
    canvas.drawCircle(
      centerO,
      radius,
      Paint()
        ..color = const Color(0xFF8B4513)
        ..strokeWidth = 4 / effectiveScale
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      centerO,
      radius - 2,
      Paint()
        ..color = const Color(0xFFD2B48C).withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );

    // Center point O
    canvas.drawCircle(
      centerO,
      4 / effectiveScale,
      Paint()..color = themePrimary,
    );
    _drawText(
      canvas,
      "O",
      -12 / effectiveScale,
      -12 / effectiveScale,
      themePrimary,
      16 / effectiveScale,
    );

    // STEP LOGIC
    if (step == 0) {
      _drawChord(
        canvas,
        chordAB_P1,
        chordAB_P2,
        "A",
        "B",
        const Color(0xFF8B4513),
        effectiveScale,
      );
    } else if (step == 1) {
      _drawChord(
        canvas,
        chordAB_P1,
        chordAB_P2,
        "A",
        "B",
        const Color(0xFF8B4513),
        effectiveScale,
      );

      Color lColor = laserLocked ? themeSuccess : themeError;
      _drawDashedLine(canvas, centerO, laserPos, lColor, 3 / effectiveScale);

      canvas.drawCircle(laserPos, 10 / effectiveScale, Paint()..color = lColor);

      // Draw 'M' near the laser point (either snapped or free)
      _drawText(
        canvas,
        "M",
        laserPos.dx + 10 / effectiveScale,
        laserPos.dy + 15 / effectiveScale,
        Colors.white,
        16 / effectiveScale,
      );
    } else if (step == 2) {
      _drawChord(
        canvas,
        chordAB_P1,
        chordAB_P2,
        "A",
        "B",
        const Color(0xFF8B4513),
        effectiveScale,
      );
      canvas.drawLine(
        centerO,
        const Offset(0, 90),
        Paint()
          ..color = themeSuccess
          ..strokeWidth = 4 / effectiveScale,
      );
      canvas.drawCircle(
        const Offset(0, 90),
        8 / effectiveScale,
        Paint()..color = themeSuccess,
      );
      _drawText(
        canvas,
        "M",
        -6 / effectiveScale,
        110 / effectiveScale,
        Colors.white,
        16 / effectiveScale,
      );

      // 90 deg square
      canvas.drawPath(
        Path()
          ..moveTo(0, 75)
          ..lineTo(15, 75)
          ..lineTo(15, 90),
        Paint()
          ..color = themeSuccess
          ..strokeWidth = 2 / effectiveScale
          ..style = PaintingStyle.stroke,
      );

      // Balance texts
      _drawText(
        canvas,
        "AM=80",
        -50 / effectiveScale,
        110 / effectiveScale,
        themeSuccess,
        14 / effectiveScale,
      );
      _drawText(
        canvas,
        "MB=80",
        50 / effectiveScale,
        110 / effectiveScale,
        themeSuccess,
        14 / effectiveScale,
      );
    } else if (step == 3) {
      _drawChord(
        canvas,
        chordPQ_P1,
        chordPQ_P2,
        "P",
        "Q",
        const Color(0xFF64748B),
        effectiveScale,
      );

      Color mColor = markerLocked ? themeSuccess : themeAccent;
      canvas.drawCircle(
        markerPos,
        10 / effectiveScale,
        Paint()..color = mColor,
      );
      // M follows marker
      _drawText(
        canvas,
        "M",
        markerPos.dx - 18 / effectiveScale,
        markerPos.dy - 12 / effectiveScale,
        Colors.white,
        16 / effectiveScale,
      );
    } else if (step == 4) {
      _drawChord(
        canvas,
        chordPQ_P1,
        chordPQ_P2,
        "P",
        "Q",
        const Color(0xFF64748B),
        effectiveScale,
      );
      canvas.drawCircle(
        const Offset(0, 0),
        8 / effectiveScale,
        Paint()..color = themeSuccess,
      ); // M is at origin
      _drawText(
        canvas,
        "M",
        12 / effectiveScale,
        -12 / effectiveScale,
        Colors.white,
        16 / effectiveScale,
      );

      // Angle verification indicator
      canvas.save();
      canvas.rotate(-math.pi / 4);
      canvas.drawPath(
        Path()
          ..moveTo(0, -15)
          ..lineTo(15, -15)
          ..lineTo(15, 0),
        Paint()
          ..color = themeSuccess
          ..strokeWidth = 3 / effectiveScale
          ..style = PaintingStyle.stroke,
      );
      canvas.restore();
    } else if (step == 5 || step == 6) {
      _drawChord(
        canvas,
        chordAB_P1,
        chordAB_P2,
        "A",
        "B",
        const Color(0xFF8B4513),
        effectiveScale,
      );
      canvas.drawLine(
        centerO,
        const Offset(0, 90),
        Paint()
          ..color = themeSuccess
          ..strokeWidth = 3 / effectiveScale,
      );
      _drawText(
        canvas,
        "M",
        -6 / effectiveScale,
        110 / effectiveScale,
        Colors.white,
        16 / effectiveScale,
      );

      // Radii
      _drawDashedLine(
        canvas,
        centerO,
        chordAB_P1,
        themeAccent,
        2 / effectiveScale,
      );
      _drawDashedLine(
        canvas,
        centerO,
        chordAB_P2,
        themePrimary,
        2 / effectiveScale,
      );

      _drawText(
        canvas,
        "r=5",
        -60 / effectiveScale,
        40 / effectiveScale,
        themeAccent,
        14 / effectiveScale,
      );
      _drawText(
        canvas,
        "d=3",
        15 / effectiveScale,
        45 / effectiveScale,
        themeSuccess,
        14 / effectiveScale,
      );
    } else if (step == 7) {
      // Draw random chords
      final Offset c1p1 = const Offset(-135, -50);
      final Offset c1p2 = const Offset(-50, -135);
      final Offset c2p1 = const Offset(75, 120);
      final Offset c2p2 = const Offset(135, 30);
      _drawChord(
        canvas,
        c1p1,
        c1p2,
        "C1",
        "C2",
        const Color(0xFF64748B),
        effectiveScale,
      );
      _drawChord(
        canvas,
        c2p1,
        c2p2,
        "C3",
        "C4",
        const Color(0xFF64748B),
        effectiveScale,
      );

      if (showBisectors) {
        _drawDashedLine(
          canvas,
          const Offset(-180, -180),
          const Offset(180, 180),
          themePrimary,
          2 / effectiveScale,
        );
        _drawDashedLine(
          canvas,
          const Offset(-180, 25),
          const Offset(180, -25),
          themeAccent,
          2 / effectiveScale,
        );
        canvas.drawCircle(
          centerO,
          10 / effectiveScale,
          Paint()
            ..color = themeSuccess
            ..strokeWidth = 4 / effectiveScale
            ..style = PaintingStyle.stroke,
        );
      } else {
        _drawText(
          canvas,
          "?",
          -12 / effectiveScale,
          -12 / effectiveScale,
          themePrimary.withOpacity(0.5),
          40 / effectiveScale,
        );
      }
    } else if (step == 8 || step == 9) {
      _drawChord(
        canvas,
        chordAB_P1,
        chordAB_P2,
        "A",
        "B",
        const Color(0xFF8B4513),
        effectiveScale,
      );
      _drawDashedLine(
        canvas,
        centerO,
        const Offset(0, 90),
        themeSuccess,
        3 / effectiveScale,
      );
      _drawText(
        canvas,
        "M",
        -6 / effectiveScale,
        110 / effectiveScale,
        Colors.white,
        16 / effectiveScale,
      );

      // White markers for equality
      canvas.drawLine(
        const Offset(-60, 80),
        const Offset(-60, 100),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3 / effectiveScale,
      );
      canvas.drawLine(
        const Offset(60, 80),
        const Offset(60, 100),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3 / effectiveScale,
      );

      // Question mark arc
      canvas.drawArc(
        Rect.fromCircle(
          center: const Offset(0, 90),
          radius: 30 / effectiveScale,
        ),
        -math.pi,
        math.pi,
        false,
        Paint()
          ..color = themeAccent
          ..strokeWidth = 3 / effectiveScale
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        "?",
        0,
        55 / effectiveScale,
        themeAccent,
        28 / effectiveScale,
      );
    }

    canvas.restore();
  }

  void _drawChord(
    Canvas canvas,
    Offset p1,
    Offset p2,
    String l1,
    String l2,
    Color color,
    double scale,
  ) {
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = color
        ..strokeWidth = 8 / scale
        ..strokeCap = StrokeCap.round,
    );
    _drawText(
      canvas,
      l1,
      p1.dx - 20 / scale,
      p1.dy + 5 / scale,
      color,
      16 / scale,
    );
    _drawText(
      canvas,
      l2,
      p2.dx + 20 / scale,
      p2.dy + 5 / scale,
      color,
      16 / scale,
    );
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
    final paint = Paint()
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
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant GeometryPainter oldDelegate) {
    return true;
  }
}

final Map<String, Map<String, dynamic>> db = {
  'en': {
    'header_title': "Perpendicular Cutter",
    'header_subtitle': "Class 9 • CIRCLES",
    'lbl_objective': "Mission Objective",
    'lbl_procedure': "Procedural Steps",
    'lbl_concept': "Concept",
    'global_objective':
        "Your goal is to establish stable geometry from the center O by validating the relationships between chords and perpendiculars.",

    'btn_power': "POWER ON LASER",
    'btn_check': "CHECK BALANCE",
    'btn_connect': "VERIFY ANGLE",
    'btn_calc': "SUBMIT",
    'btn_proceed': "PROCEED",
    'btn_bisect': "DEPLOY BISECTORS",
    'btn_finish': "RESTART PROJECT",

    'msg_error': "Calculation Error!",
    'msg_success': "Verified!",
    'msg_lock': "Locked at 90°!",
    'msg_bisect': "AM = MB Confirmed!",
    'msg_mid': "Midpoint Reached!",
    'msg_perp': "90° Verified!",
    'msg_correct': "Correct!",

    'q_90': "90° (Perpendicular)",
    'q_180': "Parallel to it",

    'step0_desc': "Observe the circular workspace and chord AB.",
    'step1_desc': "Drag the laser from center O to exactly 90°.",
    'step2_desc': "Verify segments AM = MB for balance.",
    'step3_desc': "Slide marker to the exact midpoint of PQ.",
    'step4_desc': "Measure the angle between OM and PQ.",
    'step5_desc': "Observe radii forming right-angled triangles.",
    'step6_desc': "Calculate half-chord AM using Pythagoras.",
    'step7_desc': "Draw perpendicular bisectors to find the center.",
    'step8_desc': "Complete the final geometric certification quiz.",
    'step9_desc': "Workshop complete! Restart if needed.",

    'step0_concept':
        "A Chord is a line segment whose endpoints lie on the circle. The center O is the origin point for structural stability.",
    'step1_concept':
        "The shortest distance from a point to a line is the perpendicular distance (90° intersection).",
    'step2_concept':
        "Theorem 9.3: The perpendicular from the center of a circle to a chord bisects the chord. This means it cuts the chord into two equal halves (AM = MB).",
    'step3_concept':
        "Finding the midpoint first is the reverse process of the previous theorem. Let's see what angle it creates with the center.",
    'step4_concept':
        "Theorem 9.4: The line drawn through the center of a circle to bisect a chord is perpendicular to the chord. The angle will always be 90°.",
    'step5_concept':
        "Connecting the center to the chord endpoints creates two Right-Angled Triangles sharing a common side OM.",
    'step6_concept':
        "Using Pythagoras Theorem in a right-angled triangle: r² = d² + AM².",
    'step7_concept':
        "Because a perpendicular bisector of a chord must pass through the center, the intersection of perpendicular bisectors of any two non-parallel chords will pinpoint the exact center of the circle.",
    'step8_concept':
        "Review Theorems 9.3 and 9.4. The relationship between bisecting a chord and being perpendicular from the center is unconditional.",
    'step9_concept':
        "Mastery of circle and chord geometry enables precise architectural, engineering, and woodworking calculations.",

    'step0_prompt': "Initialize the workspace to begin calibration.",
    'step1_prompt':
        "Drag the Red Laser from Center O to Chord AB until the angle reads 90°.",
    'step2_prompt': "The perpendicular is locked. Verify segment equality.",
    'step3_prompt': "Slide Marker M along chord PQ to find the exact midpoint.",
    'step4_prompt': "Midpoint secured. Measure the angle between OM and PQ.",
    'step5_prompt': "Observe the radii forming right triangles.",
    'step6_prompt':
        "Given Radius r=5 and Distance d=3, solve for half-chord AM.",
    'step7_prompt': "Deploy perpendicular bisectors to find the lost center.",
    'step8_prompt':
        "Quiz: A line from the center that bisects a chord is always...",
    'step9_prompt': "Workshop successful. Precision Engineer status achieved.",

    'ui_mission_control': "Mission Control",
    'ui_mission_complete': "MISSION ACCOMPLISHED",
    'ui_area_cert': "Geometric Certification Passed.",
    'ui_restart': "RESTART",
    'ui_reset': "RESET",
    'status_lbl': "Progress",
    'ui_step': "Step",
  },
  'hi': {
    'header_title': "लंबवत कटर",
    'header_subtitle': "कक्षा 9 • वृत्त",
    'lbl_objective': "मिशन का उद्देश्य",
    'lbl_procedure': "प्रक्रियात्मक चरण",
    'lbl_concept': "अवधारणा",
    'global_objective':
        "आपका लक्ष्य जीवाओं और लंबों के बीच संबंधों को मान्य करके केंद्र O से स्थिर ज्यामिति स्थापित करना है।",

    'btn_power': "लेजर चालू करें",
    'btn_check': "संतुलन जांचें",
    'btn_connect': "कोण सत्यापित करें",
    'btn_calc': "उत्तर सबमिट करें",
    'btn_proceed': "आगे बढ़ें",
    'btn_bisect': "द्विभाजक बनाएं",
    'btn_finish': "प्रोजेक्ट पुनः आरंभ करें",

    'msg_error': "गणना त्रुटि!",
    'msg_success': "सत्यापित!",
    'msg_lock': "90° पर लॉक!",
    'msg_bisect': "AM = MB की पुष्टि!",
    'msg_mid': "मध्य बिंदु मिल गया!",
    'msg_perp': "90° सत्यापित!",
    'msg_correct': "सही!",

    'q_90': "90° (लंबवत)",
    'q_180': "समानांतर",

    'step0_desc': "वृत्ताकार कार्यक्षेत्र और जीवा AB देखें।",
    'step1_desc': "लेजर को केंद्र O से 90° तक खींचें।",
    'step2_desc': "संतुलन के लिए AM = MB सत्यापित करें।",
    'step3_desc': "मार्कर को PQ के सटीक मध्य बिंदु पर सरकाएं।",
    'step4_desc': "OM और PQ के बीच का कोण मापें।",
    'step5_desc': "समकोण त्रिभुज बनाने वाली त्रिज्याओं का निरीक्षण करें।",
    'step6_desc': "पाइथागोरस का उपयोग करके आधी-जीवा AM की गणना करें।",
    'step7_desc': "केंद्र खोजने के लिए लंब समद्विभाजक खींचें।",
    'step8_desc': "अंतिम ज्यामितीय प्रश्नोत्तरी पूरी करें।",
    'step9_desc': "कार्यशाला पूरी हुई! आवश्यकतानुसार पुनः आरंभ करें।",

    'step0_concept': "जीवा एक रेखाखंड है जिसके सिरे वृत्त पर स्थित होते हैं।",
    'step1_concept':
        "बिंदु से रेखा तक की सबसे छोटी दूरी लंबवत दूरी (90°) होती है।",
    'step2_concept':
        "प्रमेय 9.3: वृत्त के केंद्र से जीवा पर डाला गया लंब जीवा को समद्विभाजित करता है (AM = MB)।",
    'step3_concept':
        "पहले मध्य बिंदु खोजना पिछली प्रमेय की उल्टी प्रक्रिया है।",
    'step4_concept':
        "प्रमेय 9.4: वृत्त के केंद्र से जीवा को समद्विभाजित करने के लिए खींची गई रेखा जीवा पर लंब होती है।",
    'step5_concept':
        "जीवा के अंतिम बिंदुओं तक त्रिज्याएं खींचकर, हम दो समकोण त्रिभुज बनाते हैं।",
    'step6_concept':
        "समकोण त्रिभुज में पाइथागोरस प्रमेय का उपयोग: r² = d² + AM²।",
    'step7_concept':
        "किन्हीं दो असमानांतर जीवाओं के लंब समद्विभाजक हमेशा केंद्र पर प्रतिच्छेद करते हैं।",
    'step8_concept': "प्रमेय 9.3 और 9.4 की समीक्षा करें।",
    'step9_concept':
        "वृत्त और जीवा ज्यामिति की महारत सटीक गणनाओं को सक्षम बनाती है।",

    'step0_prompt': "अंशांकन शुरू करने के लिए कार्यक्षेत्र प्रारंभ करें।",
    'step1_prompt':
        "लाल लेजर को केंद्र O से जीवा AB तक खींचें जब तक कि कोण 90° न हो जाए।",
    'step2_prompt': "लंब लॉक है। खंडों की समानता सत्यापित करें।",
    'step3_prompt':
        "सटीक मध्य बिंदु खोजने के लिए जीवा PQ पर मार्कर M को सरकाएं।",
    'step4_prompt': "मध्य बिंदु सुरक्षित। OM और PQ के बीच का कोण मापें।",
    'step5_prompt': "समकोण त्रिभुज बनाने वाली त्रिज्याओं का निरीक्षण करें।",
    'step6_prompt': "त्रिज्या r=5 और दूरी d=3 दी गई है, AM ज्ञात करें।",
    'step7_prompt': "केंद्र खोजने के लिए लंब समद्विभाजक खींचें।",
    'step8_prompt':
        "क्विज़: केंद्र से जीवा को समद्विभाजित करने वाली रेखा हमेशा...",
    'step9_prompt': "कार्यशाला सफल रही।",

    'ui_mission_complete': "मिशन पूरा हुआ",
    'ui_area_cert': "ज्यामितीय प्रमाणन पारित।",
    'ui_restart': "पुनरारंभ करें",
    'ui_reset': "रीसेट",
    'status_lbl': "प्रगति",
    'ui_step': "चरण",
  },
};
