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
  runApp(const CyclicShieldApp());
}

class CyclicShieldApp extends StatefulWidget {
  const CyclicShieldApp({super.key});

  @override
  State<CyclicShieldApp> createState() => _CyclicShieldAppState();
}

class _CyclicShieldAppState extends State<CyclicShieldApp>
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

  bool nodesVisible = false;
  bool showDiagonal = false;
  bool showShield = false;

  late Offset ptA, ptB, ptC, ptD;

  Color colorA = const Color(0xFFF472B6);
  Color colorB = const Color(0xFFF472B6);
  Color colorC = const Color(0xFFF472B6);
  Color colorD = const Color(0xFFF472B6);

  String? dragPt; // 'A', 'B', 'C', 'D'

  // Canvas Panning/Zooming
  Offset canvasDelta = Offset.zero;
  double canvasScale = 1.0;

  // Asteroid State
  bool asteroidActive = false;
  Offset asteroidPos = const Offset(300, 150);

  // Text Controllers
  final TextEditingController _actionInputCtrl = TextEditingController();

  // Modals & Feedback
  bool showFinalModal = false;
  String? toastMessage;
  bool isErrorToast = false;
  Timer? toastTimer;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _alignController;
  late AnimationController _asteroidController;

  late Animation<Offset> _animA, _animB, _animC, _animD;
  late Animation<Offset> _animAsteroid;

  // Scroll Controller
  final ScrollController _sidebarScrollController = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(11, (index) => GlobalKey());

  // Theme Constants
  final Color themeBg = const Color(0xFF020617);
  final Color themePanel = const Color.fromRGBO(15, 23, 42, 0.95);
  final Color themeText = const Color(0xFFF8FAFC);
  final Color themeMuted = const Color(0xFF94A3B8);
  final Color themeBorder = const Color.fromRGBO(59, 130, 246, 0.3);
  final Color themeAccent = const Color(0xFFEC4899); // Pink
  final Color themePrimary = const Color(0xFF3B82F6); // Blue
  final Color themeSecondary = const Color(0xFF6366F1); // Indigo
  final Color themeSuccess = const Color(0xFF22C55E); // Green
  final Color themeError = const Color(0xFFEF4444); // Red
  final Color themeWarn = const Color(0xFFF59E0B); // Amber

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

    _alignController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _asteroidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Initial Positions (A, B, D on circle, C inside)
    ptA = _getPtFromAngle(210, radius);
    ptB = _getPtFromAngle(330, radius);
    ptC = _getPtFromAngle(45, 90); // Initially inside
    ptD = _getPtFromAngle(135, radius);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _pulseController.dispose();
    _alignController.dispose();
    _asteroidController.dispose();

    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    _actionInputCtrl.dispose();
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
        if (currentStep < 10) {
          currentStep++;

          if (currentStep == 8) {
            // Restore D to boundary and reactivate shield automatically
            ptD = _getPtFromAngle(135, radius);
            showShield = true;
            colorD = themeSuccess;
          }

          // Auto-scroll Sidebar
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
        }
        isAdvancing = false;
        _actionInputCtrl.clear();
      });
    });
  }

  void fullReset() {
    playClick();
    _alignController.reset();
    _asteroidController.reset();

    setState(() {
      hasStarted = false;
      currentLang = 'en';
      currentStep = 0;
      isAdvancing = false;

      nodesVisible = false;
      showDiagonal = false;
      showShield = false;

      ptA = _getPtFromAngle(210, radius);
      ptB = _getPtFromAngle(330, radius);
      ptC = _getPtFromAngle(45, 90);
      ptD = _getPtFromAngle(135, radius);

      colorA = const Color(0xFFF472B6);
      colorB = const Color(0xFFF472B6);
      colorC = const Color(0xFFF472B6);
      colorD = const Color(0xFFF472B6);

      asteroidActive = false;
      asteroidPos = const Offset(300, 150);
      dragPt = null;

      _actionInputCtrl.clear();
      showFinalModal = false;
      isSidebarOpen = true;

      canvasDelta = Offset.zero;
      canvasScale = 1.0;
    });
  }

  int getInteriorAngle(Offset pPrev, Offset pCurr, Offset pNext) {
    double v1x = pPrev.dx - pCurr.dx;
    double v1y = pPrev.dy - pCurr.dy;
    double v2x = pNext.dx - pCurr.dx;
    double v2y = pNext.dy - pCurr.dy;

    double mag1 = math.sqrt(v1x * v1x + v1y * v1y);
    double mag2 = math.sqrt(v2x * v2x + v2y * v2y);
    if (mag1 * mag2 == 0) return 0;

    double dot = (v1x * v2x + v1y * v2y) / (mag1 * mag2);
    dot = dot.clamp(-1.0, 1.0);
    return (math.acos(dot) * 180 / math.pi).round();
  }

  void handleAction() {
    playClick();
    if (currentStep == 0) {
      setState(() => nodesVisible = true);
      completeStep();
    } else if (currentStep == 1) {
      setState(() => showDiagonal = true);
      completeStep();
    } else if (currentStep == 2) {
      playError();
      showToast(db[currentLang]!['msg_error'], true);
      completeStep();
    } else if (currentStep == 3) {
      completeStep();
    } else if (currentStep == 5) {
      int angB = getInteriorAngle(ptA, ptB, ptC);
      int targetD = 180 - angB;
      int val = int.tryParse(_actionInputCtrl.text) ?? -1;
      if (val == targetD) {
        playSuccess();
        showToast(db[currentLang]!['msg_success'], false);
        completeStep();
      } else {
        playError();
        showToast(db[currentLang]!['msg_error'], true);
      }
    } else if (currentStep == 6) {
      playPower();
      setState(() {
        showShield = true;
        colorA = themeSuccess;
        colorB = themeSuccess;
        colorC = themeSuccess;
        colorD = themeSuccess;
      });
      showToast(db[currentLang]!['msg_shield_on'], false);
      completeStep();
    } else if (currentStep == 9) {
      _animA = Tween<Offset>(
        begin: ptA,
        end: _getPtFromAngle(225, radius),
      ).animate(
        CurvedAnimation(parent: _alignController, curve: Curves.easeInOut),
      );
      _animB = Tween<Offset>(
        begin: ptB,
        end: _getPtFromAngle(315, radius),
      ).animate(
        CurvedAnimation(parent: _alignController, curve: Curves.easeInOut),
      );
      _animC = Tween<Offset>(
        begin: ptC,
        end: _getPtFromAngle(45, radius),
      ).animate(
        CurvedAnimation(parent: _alignController, curve: Curves.easeInOut),
      );
      _animD = Tween<Offset>(
        begin: ptD,
        end: _getPtFromAngle(135, radius),
      ).animate(
        CurvedAnimation(parent: _alignController, curve: Curves.easeInOut),
      );

      _alignController.forward(from: 0).then((_) {
        setState(() {
          ptA = _getPtFromAngle(225, radius);
          ptB = _getPtFromAngle(315, radius);
          ptC = _getPtFromAngle(45, radius);
          ptD = _getPtFromAngle(135, radius);
        });
        completeStep();
      });

      _alignController.addListener(() {
        setState(() {
          ptA = _animA.value;
          ptB = _animB.value;
          ptC = _animC.value;
          ptD = _animD.value;
        });
      });
    } else if (currentStep == 10) {
      int val = int.tryParse(_actionInputCtrl.text) ?? -1;
      if (val == 90) {
        setState(() => asteroidActive = true);
        _animAsteroid = TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(300, 150),
              end: const Offset(0, 0),
            ).chain(CurveTween(curve: Curves.easeIn)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(0, 0),
              end: const Offset(-300, -200),
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 50,
          ),
        ]).animate(_asteroidController);

        _asteroidController.forward(from: 0).then((_) {
          playSuccess();
          setState(() {
            asteroidActive = false;
            showFinalModal = true;
          });
        });

        _asteroidController.addListener(() {
          if (_asteroidController.value == 0.5) {
            showToast(
              db[currentLang]!['msg_deflect'] ?? "ASTEROID DEFLECTED!",
              false,
            );
            playSuccess();
          }
          setState(() {
            asteroidPos = _animAsteroid.value;
          });
        });
      } else {
        playError();
        showToast(db[currentLang]!['msg_error'], true);
      }
    }
  }

  // Canvas Interactions
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

    double baseScale = math
        .min((availableWidth * 0.9) / 400, constraints.maxHeight / 400)
        .clamp(0.5, 2.0);
    double effectiveScale = baseScale * canvasScale;

    Offset localPoint =
        (details.localFocalPoint - Offset(cx, cy)) / effectiveScale;
    double hitRadius = 50.0 / effectiveScale;

    if (currentStep == 4 && (localPoint - ptC).distance < hitRadius) {
      setState(() {
        dragPt = 'C';
        playClick();
      });
    } else if (currentStep == 7 && (localPoint - ptD).distance < hitRadius) {
      setState(() {
        dragPt = 'D';
        playClick();
      });
    } else if (currentStep == 8 && (localPoint - ptA).distance < hitRadius) {
      setState(() {
        dragPt = 'A';
        playClick();
      });
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
      // Pan/Zoom Canvas
      setState(() {
        canvasDelta += details.focalPointDelta;
        // Simple zoom handling
        canvasScale = (canvasScale * details.scale).clamp(0.5, 3.0);
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

    double baseScale = math
        .min((availableWidth * 0.9) / 400, constraints.maxHeight / 400)
        .clamp(0.5, 2.0);
    double effectiveScale = baseScale * canvasScale;

    Offset localPoint =
        (details.localFocalPoint - Offset(cx, cy)) / effectiveScale;
    double dist = localPoint.distance;

    setState(() {
      if (dragPt == 'C' && currentStep == 4) {
        ptC = localPoint;
        if ((dist - radius).abs() < 20) {
          ptC = ptC / dist * radius;
          colorC = themeSuccess;
        } else {
          colorC = themeAccent;
        }
      } else if (dragPt == 'D' && currentStep == 7) {
        ptD = localPoint;
        if (dist < radius - 5) {
          showShield = false;
          colorD = themeError;
        } else {
          ptD = ptD / dist * radius;
          showShield = true;
          colorD = themeSuccess;
        }
      } else if (dragPt == 'A' && currentStep == 8) {
        if (dist > 0) {
          double ang = math.atan2(localPoint.dy, localPoint.dx) * 180 / math.pi;
          if (ang < 0) ang += 360;
          ang = ang.clamp(
            160.0,
            270.0,
          ); // Constraint to keep A roughly left-bottom
          ptA = _getPtFromAngle(ang, radius);
        }
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (dragPt != null) {
      if (dragPt == 'C' && currentStep == 4) {
        if ((ptC.distance - radius).abs() < 2) {
          playSuccess();
          showToast(db[currentLang]!['msg_success'], false);
          completeStep();
        } else {
          playError();
        }
      } else if (dragPt == 'D' && currentStep == 7) {
        if (ptD.distance < radius - 5) {
          playError();
          showToast(db[currentLang]!['msg_shield_off'], true);
          completeStep();
        }
      } else if (dragPt == 'A' && currentStep == 8) {
        playSuccess();
        completeStep();
      }
    }
    setState(() {
      dragPt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) return _buildShutterScreen();

    final t = db[currentLang]!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = screenWidth * 0.30;

    int angA = getInteriorAngle(ptD, ptA, ptB);
    int angC = getInteriorAngle(ptB, ptC, ptD);
    int angB = getInteriorAngle(ptA, ptB, ptC);
    int angD = getInteriorAngle(ptC, ptD, ptA);

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
              child: _buildCanvasArea(sidebarWidth, angA, angB, angC, angD),
            ),

            // Left Sidebar
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

            // Top-Left Menu Icon
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

            // Compact Action Panel (Bottom Center)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 16,
              left: isSidebarOpen ? sidebarWidth + 16 : 16,
              right: 16,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildActionPanel(t, angA, angB, angC, angD),
              ),
            ),

            // Final Modal
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
                      Icons.shield_outlined,
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
                  setState(() {
                    hasStarted = true;
                  });
                },
                icon: const Icon(Icons.power_settings_new, size: 20),
                label: Text(
                  t['start_btn'],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section (Everything inside SingleChildScrollView to flow naturally)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                          backgroundColor: Colors.black.withOpacity(0.3),
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
                        "${t['ui_step']} ${currentStep + 1}/11",
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
                      widthFactor: (currentStep + 1) / 11,
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeAccent,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(color: themeAccent, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: themeBorder, height: 1),

            // Main Content Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(t['objective'], themeAccent),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: themeBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeBorder),
                    ),
                    child: Text(
                      t['global_obj'],
                      style: TextStyle(
                        color: themeText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),

                  _buildSectionTitle(t['procedural_steps'], themePrimary),
                  Column(
                    children: List.generate(t['levels'].length, (index) {
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
                                  t['levels'][index]['step_desc'],
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
                  _buildSectionTitle(t['concept'], themeSuccess),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeBorder),
                    ),
                    // Remove <b> tags and display
                    child: Text(
                      t['levels'][currentStep]['concept']
                          .replaceAll('<b>', '')
                          .replaceAll('</b>', ''),
                      style: TextStyle(
                        color: themeMuted,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),

                  // Footer embedded in the scrollable view
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        "© ZEROSCIENCELAB - Fall in Love with Math and Science",
                        style: TextStyle(
                          color: themeMuted.withOpacity(0.6),
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
          ],
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

  Widget _buildActionPanel(
    Map<String, dynamic> t,
    int angA,
    int angB,
    int angC,
    int angD,
  ) {
    Widget content = const SizedBox();

    if (currentStep == 0) {
      content = _buildPrimaryBtn(t['btn_deploy'], handleAction, themeAccent);
    } else if (currentStep == 1) {
      content = _buildPrimaryBtn(t['btn_connect'], handleAction, themePrimary);
    } else if (currentStep == 2) {
      content = _buildPrimaryBtn(t['btn_scan'], handleAction, themeWarn);
    } else if (currentStep == 3) {
      content = _buildPrimaryBtn(
        t['btn_proceed'] ?? "PROCEED",
        handleAction,
        const Color(0xFF334155),
      );
    } else if (currentStep == 4) {
      content = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeError.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          t['msg_drag_c'] ??
              "CANVAS UNLOCKED. DRAG PYLON C ONTO THE GLOWING RING.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      );
    } else if (currentStep == 5) {
      String label = t['label_target_d'].replaceAll('{B}', angB.toString());
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: themePrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _actionInputCtrl,
                  enabled: !isAdvancing,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "?",
                    hintStyle: TextStyle(color: themeMuted),
                    filled: true,
                    fillColor: Colors.black45,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPrimaryBtn(
                  t['btn_calibrate'],
                  handleAction,
                  themePrimary,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (currentStep == 6) {
      content = _buildPrimaryBtn(
        t['btn_activate'],
        handleAction,
        themeSuccess,
        border: themeSuccess,
      );
    } else if (currentStep == 7) {
      content = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeError.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          t['msg_drag_d'] ?? "CANVAS UNLOCKED. DRAG PYLON D INSIDE THE RING.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      );
    } else if (currentStep == 8) {
      content = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          t['msg_drag_a'] ?? "CANVAS UNLOCKED. DRAG PYLON A ALONG THE RING.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      );
    } else if (currentStep == 9) {
      content = _buildPrimaryBtn(t['btn_align'], handleAction, themePrimary);
    } else if (currentStep == 10) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['label_defend'],
            style: TextStyle(
              color: themeWarn,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _actionInputCtrl,
                  enabled: !isAdvancing,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "?",
                    hintStyle: TextStyle(color: themeMuted),
                    filled: true,
                    fillColor: Colors.black45,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPrimaryBtn(
                  t['btn_defend'],
                  handleAction,
                  themeError,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 280), // Super compact
      padding: const EdgeInsets.all(10),
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
    int angA,
    int angB,
    int angC,
    int angD,
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
                ptA: ptA,
                ptB: ptB,
                ptC: ptC,
                ptD: ptD,
                colorA: colorA,
                colorB: colorB,
                colorC: colorC,
                colorD: colorD,
                nodesVisible: nodesVisible,
                showDiagonal: showDiagonal,
                showShield: showShield,
                asteroidActive: asteroidActive,
                asteroidPos: asteroidPos,
                dragPt: dragPt,
                canvasOffset: canvasDelta,
                canvasScale: canvasScale,
                themePrimary: themePrimary,
                themeAccent: themeAccent,
                themeSuccess: themeSuccess,
                themeError: themeError,
                themeSecondary: themeSecondary,
                isSidebarOpen: isSidebarOpen,
                sidebarWidth: sidebarWidth,
                angA: angA,
                angB: angB,
                angC: angC,
                angD: angD,
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
  final Color colorA, colorB, colorC, colorD;
  final bool nodesVisible;
  final bool showDiagonal;
  final bool showShield;
  final bool asteroidActive;
  final Offset asteroidPos;
  final String? dragPt;
  final Offset canvasOffset;
  final double canvasScale;
  final Color themePrimary,
      themeAccent,
      themeSuccess,
      themeError,
      themeSecondary;
  final bool isSidebarOpen;
  final double sidebarWidth;
  final int angA, angB, angC, angD;

  GeometryPainter({
    required this.step,
    required this.radius,
    required this.centerO,
    required this.ptA,
    required this.ptB,
    required this.ptC,
    required this.ptD,
    required this.colorA,
    required this.colorB,
    required this.colorC,
    required this.colorD,
    required this.nodesVisible,
    required this.showDiagonal,
    required this.showShield,
    required this.asteroidActive,
    required this.asteroidPos,
    required this.dragPt,
    required this.canvasOffset,
    required this.canvasScale,
    required this.themePrimary,
    required this.themeAccent,
    required this.themeSuccess,
    required this.themeError,
    required this.themeSecondary,
    required this.isSidebarOpen,
    required this.sidebarWidth,
    required this.angA,
    required this.angB,
    required this.angC,
    required this.angD,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth =
        isSidebarOpen ? size.width - sidebarWidth : size.width;
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
    final Paint gridPaint =
        Paint()
          ..color = themePrimary.withOpacity(0.15)
          ..strokeWidth = 1 / effectiveScale;
    double stepSize = 40.0;
    for (double x = -2000; x < 2000; x += stepSize) {
      canvas.drawLine(Offset(x, -2000), Offset(x, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, x), Offset(2000, x), gridPaint);
    }

    // Circle
    canvas.drawCircle(
      centerO,
      radius,
      Paint()
        ..color = themePrimary.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      centerO,
      radius,
      Paint()
        ..color = themePrimary.withOpacity(0.4)
        ..strokeWidth = 3 / effectiveScale
        ..style = PaintingStyle.stroke,
    );

    if (nodesVisible) {
      final Paint polyPaint =
          Paint()
            ..color =
                (showShield
                    ? themePrimary
                    : (step > 2 && step < 6 ? themeError : themeAccent))
            ..strokeWidth = 2 / effectiveScale
            ..style = PaintingStyle.stroke;
      final Path polyPath =
          Path()
            ..moveTo(ptA.dx, ptA.dy)
            ..lineTo(ptB.dx, ptB.dy)
            ..lineTo(ptC.dx, ptC.dy)
            ..lineTo(ptD.dx, ptD.dy)
            ..close();

      if (showShield) {
        canvas.drawPath(
          polyPath,
          Paint()
            ..color = themePrimary.withOpacity(0.2)
            ..style = PaintingStyle.fill,
        );
      }
      canvas.drawPath(polyPath, polyPaint);

      if (showDiagonal) {
        final Paint diagPaint =
            Paint()
              ..color = Colors.white54
              ..strokeWidth = 2 / effectiveScale
              ..style = PaintingStyle.stroke;
        canvas.drawLine(ptA, ptC, diagPaint);
      }

      if (step >= 2) {
        Offset aDir =
            ptA.distance > 0 ? ptA / ptA.distance : const Offset(-1, 0);
        Offset cDir =
            ptC.distance > 0 ? ptC / ptC.distance : const Offset(1, 0);

        _drawText(
          canvas,
          "$angA°",
          ptA.dx - aDir.dx * 25,
          ptA.dy - aDir.dy * 25,
          Colors.white,
          14 / effectiveScale,
        );
        _drawText(
          canvas,
          "$angC°",
          ptC.dx - cDir.dx * 25,
          ptC.dy - cDir.dy * 25,
          Colors.white,
          14 / effectiveScale,
        );

        if (step >= 5) {
          Offset bDir =
              ptB.distance > 0 ? ptB / ptB.distance : const Offset(0, -1);
          Offset dDir =
              ptD.distance > 0 ? ptD / ptD.distance : const Offset(0, 1);
          _drawText(
            canvas,
            "$angB°",
            ptB.dx - bDir.dx * 25,
            ptB.dy - bDir.dy * 25,
            Colors.white,
            14 / effectiveScale,
          );
          _drawText(
            canvas,
            "$angD°",
            ptD.dx - dDir.dx * 25,
            ptD.dy - dDir.dy * 25,
            Colors.white,
            14 / effectiveScale,
          );
        }
      }

      // Draw Nodes
      void drawNode(Offset p, String label, Color c, bool isDrag) {
        canvas.drawCircle(
          p,
          isDrag ? 12 / effectiveScale : 8 / effectiveScale,
          Paint()..color = c,
        );
        if (isDrag ||
            (step == 4 && label == 'C') ||
            (step == 7 && label == 'D') ||
            (step == 8 && label == 'A')) {
          canvas.drawCircle(
            p,
            16 / effectiveScale,
            Paint()
              ..color = c
              ..strokeWidth = 2 / effectiveScale
              ..style = PaintingStyle.stroke,
          );
        }

        Offset pDir = p.distance > 0 ? p / p.distance : const Offset(1, 0);
        _drawText(
          canvas,
          label,
          p.dx + pDir.dx * 25,
          p.dy + pDir.dy * 25,
          Colors.white,
          18 / effectiveScale,
        );
      }

      drawNode(ptA, "A", colorA, dragPt == 'A');
      drawNode(ptB, "B", colorB, dragPt == 'B');
      drawNode(ptC, "C", colorC, dragPt == 'C');
      drawNode(ptD, "D", colorD, dragPt == 'D');
    }

    if (asteroidActive) {
      canvas.drawCircle(
        asteroidPos,
        15 / effectiveScale,
        Paint()..color = const Color(0xFF64748B),
      );
      canvas.drawCircle(
        asteroidPos + Offset(15 / effectiveScale, 0),
        10 / effectiveScale,
        Paint()..color = themeError,
      );
    }

    canvas.restore();
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
    'start_btn': "INITIALIZE SYSTEM",
    'header_title': "The Cyclic Shield",
    'header_subtitle': "Class 9 • CIRCLE THEOREMS",
    'mission_control': "Mission Actions",
    'status_lbl': "Mission Status",
    'objective': "Mission Objective",
    'procedural_steps': "Procedural Steps",
    'concept': "Core Concept",
    'global_obj':
        "Form a secure Cyclic Quadrilateral shield to defend the core.",
    'btn_deploy': "DEPLOY SHIELD GRID",
    'btn_connect': "LINK A TO C",
    'btn_scan': "RUN SYSTEM SCAN",
    'btn_proceed': "PROCEED",
    'btn_calibrate': "CALIBRATE",
    'btn_activate': "ACTIVATE SHIELD",
    'btn_align': "AUTO-ALIGN RECTANGLE",
    'btn_defend': "DEFLECT",
    'msg_error': "CRITICAL IMBALANCE!",
    'msg_success': "SYSTEM STABLE!",
    'msg_shield_on': "FORCEFIELD ACTIVE!",
    'msg_shield_off': "SHIELD OFFLINE!",
    'msg_drag_c': "CANVAS UNLOCKED. DRAG PYLON C ONTO THE GLOWING RING.",
    'msg_drag_d': "CANVAS UNLOCKED. DRAG PYLON D INSIDE THE RING.",
    'msg_drag_a': "CANVAS UNLOCKED. DRAG PYLON A ALONG THE RING.",
    'msg_deflect': "ASTEROID DEFLECTED!",
    'label_target_d': "Target D (180° - {B}°)",
    'label_defend': "Incoming! Ext ∠ = 90°. Input Int Opposite:",
    'levels': [
      {
        'step_desc': "Deploy pylons A, B, C, D to initiate the base grid.",
        'concept':
            "A quadrilateral is Cyclic if all its four vertices lie perfectly on a circular boundary.",
      },
      {
        'step_desc': "Link opposite pylons A & C to check internal symmetry.",
        'concept':
            "The line connecting opposite vertices forms a diagonal. In a cyclic quadrilateral, diagonals strictly intersect inside the circle.",
      },
      {
        'step_desc': "Run a full diagnostic scan on the opposite angles.",
        'concept':
            "The defining property of a cyclic quadrilateral is that its opposite angles are supplementary (they sum to exactly 180°).",
      },
      {
        'step_desc': "Analyze the critical angle mismatch (Imbalance).",
        'concept':
            "If ∠A + ∠C ≠ 180°, the vertices do not lie on a single circle, creating a non-cyclic, unstable structure.",
      },
      {
        'step_desc': "Drag Pylon C onto the glowing circular boundary.",
        'concept':
            "Moving the vertex precisely onto the circle geometrically forces the condition ∠A + ∠C = 180°, creating a stable cyclic quadrilateral.",
      },
      {
        'step_desc': "Calculate & input energy for D (180° - ∠B).",
        'concept':
            "Given one angle, the opposite angle in a cyclic system is found using 180° - ∠B. This ensures overall stability.",
      },
      {
        'step_desc': "Activate the defensive forcefield.",
        'concept':
            "With both pairs of opposite angles summing to 180°, the geometric shape perfectly defines a circle. The shield can safely project.",
      },
      {
        'step_desc':
            "Check converse: Drag D inside the ring to see shield fail.",
        'concept':
            "The Converse is also true: If the sum of opposite angles is NOT 180°, the quadrilateral is NOT cyclic and the shield fails.",
      },
      {
        'step_desc': "Check invariance: Drag A along the ring.",
        'concept':
            "Angles in the same segment preserve the opposite sums. The shape changes, but the cyclic property remains absolutely constant.",
      },
      {
        'step_desc': "Auto-align the grid to a perfect rectangle.",
        'concept':
            "Every rectangle has 90° corner angles. Since 90° + 90° = 180°, all rectangles are naturally cyclic quadrilaterals.",
      },
      {
        'step_desc': "Deflect asteroid using interior opposite angle.",
        'concept':
            "If one side of a cyclic quad is produced outward, the exterior angle is exactly equal to the interior opposite angle.",
      },
    ],
    'ui_reset': "RESET",
    'ui_step': "Step",
    'ui_mission_complete': "MISSION COMPLETE!",
    'ui_area_cert':
        "Theorem Certified.\nCyclic quadrilateral opposite angles sum to 180°.",
    'ui_restart': "RESTART MISSION",
    'ui_footer': "© ZEROSCIENCELAB - Fall in Love with Math and Science",
  },
  'hi': {
    'start_btn': "सिस्टम प्रारंभ करें",
    'header_title': "चक्रीय ढाल",
    'header_subtitle': "कक्षा 9 • वृत्त के प्रमेय",
    'mission_control': "मिशन क्रियाएं",
    'status_lbl': "मिशन स्थिति",
    'objective': "मिशन का उद्देश्य",
    'procedural_steps': "प्रक्रियात्मक चरण",
    'concept': "मूल अवधारणा",
    'global_obj': "कोर की रक्षा के लिए एक सुरक्षित चक्रीय चतुर्भुज ढाल बनाएं।",
    'btn_deploy': "शील्ड ग्रिड तैनात करें",
    'btn_connect': "A को C से जोड़ें",
    'btn_scan': "सिस्टम स्कैन चलाएं",
    'btn_proceed': "आगे बढ़ें",
    'btn_calibrate': "अंशांकित करें",
    'btn_activate': "शील्ड सक्रिय करें",
    'btn_align': "आयत को स्वतः संरेखित करें",
    'btn_defend': "विक्षेपित करें",
    'msg_error': "गंभीर असंतुलन!",
    'msg_success': "सिस्टम स्थिर!",
    'msg_shield_on': "बल क्षेत्र सक्रिय!",
    'msg_shield_off': "शील्ड ऑफलाइन!",
    'msg_drag_c': "कैनवास अनलॉक। पायलॉन C को चमकती हुई अंगूठी पर खींचें।",
    'msg_drag_d': "कैनवास अनलॉक। पायलॉन D को रिंग के अंदर खींचें।",
    'msg_drag_a': "कैनवास अनलॉक। पायलॉन A को रिंग के साथ खींचें।",
    'msg_deflect': "क्षुद्रग्रह विक्षेपित!",
    'label_target_d': "लक्ष्य D (180° - {B}°)",
    'label_defend': "आ रहा है! बाहरी ∠ = 90°। आंतरिक विपरीत दर्ज करें:",
    'levels': [
      {
        'step_desc': "बेस ग्रिड शुरू करने के लिए a, b, c, d तैनात करें।",
        'concept':
            "एक चतुर्भुज चक्रीय है यदि इसके चारों कोने पूरी तरह से एक गोलाकार सीमा पर हैं।",
      },
      {
        'step_desc': "आंतरिक समरूपता जांचने के लिए A और C जोड़ें।",
        'concept':
            "विपरीत शीर्षों को जोड़ने वाली रेखा विकर्ण बनाती है। चक्रीय चतुर्भुज में, विकर्ण वृत्त के अंदर सख्ती से प्रतिच्छेद करते हैं।",
      },
      {
        'step_desc': "विपरीत कोणों पर डायग्नोस्टिक स्कैन चलाएं।",
        'concept':
            "चक्रीय चतुर्भुज का परिभाषित गुण यह है कि इसके विपरीत कोण संपूरक होते हैं (उनका योग ठीक 180° होता है)।",
      },
      {
        'step_desc': "महत्वपूर्ण कोण असंतुलन का विश्लेषण करें।",
        'concept':
            "यदि ∠A + ∠C ≠ 180°, तो कोने एक वृत्त पर स्थित नहीं होते हैं, जिससे एक गैर-चक्रीय, अस्थिर संरचना बनती है।",
      },
      {
        'step_desc': "पायलॉन C को चमकती हुई वृत्ताकार सीमा पर खींचें।",
        'concept':
            "शीर्ष को वृत्त पर ले जाने से ज्यामितीय रूप से ∠A + ∠C = 180° की स्थिति मजबूर हो जाती है।",
      },
      {
        'step_desc': "D के लिए ऊर्जा की गणना करें (180° - ∠B)।",
        'concept':
            "चक्रीय प्रणाली में, विपरीत कोण 180° - ∠B का उपयोग करके पाया जाता है।",
      },
      {
        'step_desc': "रक्षात्मक बल क्षेत्र सक्रिय करें।",
        'concept':
            "विपरीत कोणों के दोनों जोड़े 180° योग करते हैं, ज्यामितीय आकार पूरी तरह से वृत्त परिभाषित करता है। ढाल सुरक्षित रूप से प्रोजेक्ट कर सकती है।",
      },
      {
        'step_desc':
            "विलोम जांचें: ढाल विफलता देखने के लिए D को रिंग के अंदर खींचें।",
        'concept':
            "विलोम भी सत्य है: यदि विपरीत कोणों का योग 180° नहीं है, तो चतुर्भुज चक्रीय नहीं है।",
      },
      {
        'step_desc': "अपरिवर्तन जांचें: रिंग के साथ A को खींचें।",
        'concept':
            "उसी खंड के कोण विपरीत रकम को संरक्षित करते हैं। आकार बदलता है, लेकिन चक्रीय संपत्ति पूरी तरह से स्थिर रहती है।",
      },
      {
        'step_desc': "ग्रिड को एक पूर्ण आयत में स्वतः संरेखित करें।",
        'concept':
            "हर आयत में 90° कोने होते हैं। चूंकि 90° + 90° = 180°, सभी आयत स्वाभाविक रूप से चक्रीय होते हैं।",
      },
      {
        'step_desc': "आंतरिक विपरीत कोण का उपयोग करके क्षुद्रग्रह को हटा दें।",
        'concept':
            "यदि चक्रीय क्वाड के एक पक्ष को बाहर की ओर उत्पादित किया जाता है, तो बाहरी कोण आंतरिक विपरीत कोण के बिल्कुल बराबर होता है।",
      },
    ],
    'ui_reset': "रीसेट",
    'ui_step': "चरण",
    'ui_mission_complete': "मिशन पूरा हुआ!",
    'ui_area_cert':
        "प्रमेय प्रमाणित।\nचक्रीय चतुर्भुज के विपरीत कोणों का योग 180° होता है।",
    'ui_restart': "मिशन पुनरारंभ करें",
    'ui_footer': "© ZEROSCIENCELAB - Fall in Love with Math and Science",
  },
};
