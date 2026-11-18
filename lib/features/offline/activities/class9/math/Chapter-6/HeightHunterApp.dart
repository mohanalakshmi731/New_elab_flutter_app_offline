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
  runApp(const HeightHunterApp());
}

class HeightHunterApp extends StatelessWidget {
  const HeightHunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Height Hunter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0518),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF1E1B4B),
        ),
      ),
      home: const HeightHunterScreen(),
    );
  }
}

class HeightHunterScreen extends StatefulWidget {
  const HeightHunterScreen({super.key});

  @override
  State<HeightHunterScreen> createState() => _HeightHunterScreenState();
}

class _HeightHunterScreenState extends State<HeightHunterScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool hasStarted = false;
  bool isSidebarOpen = true;
  int currentStep = 1;
  String currentLang = 'en';
  
  // App State Data
  Map<int, String?> step5Inputs = {0: null, 1: null, 2: null};
  double step7SliderValue = 0;
  Map<int, bool> step8Buttons = {1: false, 2: false, 3: false};
  Map<int, String?> step9Slots = {0: null, 1: null, 2: null, 3: null};
  
  // Auto-advance State
  bool isAdvancing = false;
  Timer? advanceTimer;
  
  // Modal State
  bool showFinalModal = false;

  // Geometry Base Values
  final Offset vA = const Offset(-55, -192);
  final Offset vB = const Offset(328, 96);
  final Offset vC = const Offset(-271, 96);

  // Hardcoded Theme Colors
  final Color themeBg = const Color(0xFF0F0518);
  final Color themePanel = const Color.fromRGBO(30, 27, 75, 0.85);
  final Color themeText = const Color(0xFFF8FAFC);
  final Color themeMuted = const Color(0xFF94A3B8);
  final Color themeBorder = const Color.fromRGBO(217, 70, 239, 0.3);
  final Color themeAccent = const Color(0xFFD946EF);
  final Color themePrimary = const Color(0xFF8B5CF6);
  final Color themeSecondary = const Color(0xFF06B6D4);
  final Color themeSuccess = const Color(0xFF4ADE80);
  final Color themeError = const Color(0xFFF43F5E);

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Local audio assets (assets/audio/class9/)
  static const String _clickUrl = 'audio/class9/click.mp3';
  static const String _successUrl = 'audio/class9/success.mp3';
  static const String _errorUrl = 'audio/class9/error.mp3';
  static const String _alertUrl = 'audio/class9/shutter.mp3';

  // Scroll Controllers
  final ScrollController _sidebarScrollController = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(10, (index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    advanceTimer?.cancel();
    _sidebarScrollController.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    super.dispose();
  }

  void playClick() => _clickPlayer.play(AssetSource(_clickUrl));
  void playSuccess() => _successPlayer.play(AssetSource(_successUrl));
  void playError() => _errorPlayer.play(AssetSource(_errorUrl));
  void playAlert() => _fxPlayer.play(AssetSource(_alertUrl));

  void cycleLanguage() {
    playClick();
    setState(() {
      currentLang = currentLang == 'en' ? 'hi' : 'en';
    });
  }

  void completeStep() {
    if (isAdvancing) return;
    playSuccess();
    
    setState(() {
      isAdvancing = true;
    });
    
    advanceTimer?.cancel();
    
    if (currentStep == 10) {
      // Final delay before showing the ending modal
      advanceTimer = Timer(const Duration(seconds: 5), () {
        playAlert();
        setState(() {
          isAdvancing = false;
          showFinalModal = true;
        });
      });
    } else {
      // Normal 4 seconds delay between steps without UI blockage
      advanceTimer = Timer(const Duration(seconds: 4), () {
        setState(() {
          currentStep++;
          isAdvancing = false;
        });
        
        // Auto-scroll Sidebar to the newly activated step
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isSidebarOpen) return;
          final context = _stepKeys[currentStep - 1].currentContext;
          if (context != null) {
            Scrollable.ensureVisible(
              context, 
              duration: const Duration(milliseconds: 500), 
              curve: Curves.easeInOut,
              alignment: 0.5 // Centers the item in the viewport
            );
          }
        });
      });
    }
  }

  void fullReset() {
    playClick();
    advanceTimer?.cancel();
    setState(() {
      hasStarted = false; // Go back to shutter screen
      currentLang = 'en'; // Reset Language
      currentStep = 1;
      step5Inputs = {0: null, 1: null, 2: null};
      step7SliderValue = 0;
      step8Buttons = {1: false, 2: false, 3: false};
      step9Slots = {0: null, 1: null, 2: null, 3: null};
      isAdvancing = false;
      showFinalModal = false;
      isSidebarOpen = true;
    });
  }

  void handleCanvasTap(Offset tapPos, Size canvasSize, double sidebarWidth) {
    if (currentStep != 2 || isAdvancing) return;
    
    // Bounds calculation based on current visible center
    final double minX = [vA.dx, vB.dx, vC.dx].reduce(math.min);
    final double maxX = [vA.dx, vB.dx, vC.dx].reduce(math.max);
    final double minY = [vA.dy, vB.dy, vC.dy].reduce(math.min);
    final double maxY = [vA.dy, vB.dy, vC.dy].reduce(math.max);
    
    final double triW = maxX - minX;
    final double triH = maxY - minY;
    
    final double availableWidth = isSidebarOpen ? canvasSize.width - sidebarWidth : canvasSize.width;
    final double availableHeight = canvasSize.height - 180;
    
    final double scaleX = availableWidth / (triW + 150);
    final double scaleY = availableHeight / (triH + 150);
    double scale = math.min(scaleX, scaleY);
    if (scale > 1.2) scale = 1.2;
    if (scale < 0.2) scale = 0.2;
    
    final double centerX = isSidebarOpen ? sidebarWidth + (availableWidth / 2) : canvasSize.width / 2;
    final double centerY = availableHeight / 2;
    
    final double panX = centerX - ((minX + maxX) / 2) * scale;
    final double panY = centerY - ((minY + maxY) / 2) * scale;
    
    // Reverse transform
    final double mapX = (tapPos.dx - panX) / scale;
    final double mapY = (tapPos.dy - panY) / scale;
    
    double distToSegment(double x, double y, Offset v1, Offset v2) {
      double l2 = math.pow(v1.dx - v2.dx, 2) + math.pow(v1.dy - v2.dy, 2).toDouble();
      if (l2 == 0) return math.sqrt(math.pow(x - v1.dx, 2) + math.pow(y - v1.dy, 2));
      double t = ((x - v1.dx) * (v2.dx - v1.dx) + (y - v1.dy) * (v2.dy - v1.dy)) / l2;
      t = math.max(0, math.min(1, t));
      return math.sqrt(math.pow(x - (v1.dx + t * (v2.dx - v1.dx)), 2) + 
                       math.pow(y - (v1.dy + t * (v2.dy - v1.dy)), 2));
    }
    
    // Check hit on side a (BC)
    if (distToSegment(mapX, mapY, vC, vB) < 40) {
      completeStep();
    } else {
      playError();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) {
      return _buildShutterScreen();
    }

    final t = labText[currentLang]!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = screenWidth * 0.38; // 38% of screen width

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: themeBg,
        body: Stack(
          children: [
            // Base Canvas (Always Full Screen, visual centering adjusts dynamically)
            Positioned.fill(
              child: _buildCanvasArea(sidebarWidth),
            ),

            // Overlaid Floating Controls Area (Bottom Left, 38% width)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 16,
              left: isSidebarOpen ? sidebarWidth + 16 : 16,
              width: screenWidth * 0.38,
              child: _buildFloatingInteractions(t),
            ),

            // Top Left Controls (Menu) when Sidebar is Closed
            if (!isSidebarOpen)
              Positioned(
                top: 16,
                left: 16,
                child: _buildMenuToggleButton(),
              ),

            // Overlaid Animated Sidebar
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

            // Final Success Modal Overlay
            if (showFinalModal)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: _buildFinalCompleteModal(t),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Scaffold(
      backgroundColor: themeBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [themeAccent, themePrimary],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: themeAccent.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: const Icon(Icons.terrain, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              "The Height Hunter",
              style: TextStyle(color: themeText, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "MISSION: HERON'S FORMULA",
              style: TextStyle(color: themeSecondary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 4.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                playAlert();
                setState(() => hasStarted = true);
              },
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text("ENTER LAB", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
              ),
            )
          ],
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
        icon: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu, color: themeText),
        onPressed: () {
          playClick();
          setState(() => isSidebarOpen = !isSidebarOpen);
        },
      ),
    );
  }

  Widget _buildSidebar(Map<String, dynamic> t) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: themePanel,
        border: Border(right: BorderSide(color: themeBorder, width: 2)),
      ),
      child: SingleChildScrollView(
        controller: _sidebarScrollController,
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: themeBorder))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildMenuToggleButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['header_title'],
                              style: TextStyle(color: themeText, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              t['header_subtitle'],
                              style: TextStyle(color: themeSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildControlButton(currentLang.toUpperCase(), Icons.language, cycleLanguage),
                      _buildControlButton(t['ui_reset'], Icons.refresh, fullReset, color: themeError),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(t['obj_title'], themeAccent),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: themeBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeBorder),
                    ),
                    child: Text(t['objective'], style: TextStyle(color: themeText, fontSize: 13, height: 1.5)),
                  ),

                  _buildSectionTitle(t['proc_title'], themeSecondary),
                  for (int i = 1; i <= currentStep; i++)
                    Container(
                      key: _stepKeys[i - 1], // Key for auto-scrolling
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: i == currentStep ? themeAccent.withOpacity(0.2) : themeBg.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: i == currentStep ? themeAccent.withOpacity(0.5) : themeBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['steps'][i - 1],
                            style: TextStyle(color: themeAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t['teacher_steps'][i - 1],
                            style: TextStyle(color: themeText.withOpacity(i == currentStep ? 1 : 0.7), fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),
                  _buildSectionTitle(t['concept_title'], themeSuccess),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeBg.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeBorder.withOpacity(0.5)),
                    ),
                    child: Text(
                      t['concepts'][currentStep - 1],
                      style: TextStyle(color: themeMuted, fontSize: 13, fontStyle: FontStyle.italic, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer Section
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border(top: BorderSide(color: themeBorder))),
              child: Text(
                t['ui_footer'],
                style: TextStyle(color: themeMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                textAlign: TextAlign.center,
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
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildControlButton(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    final c = color ?? themeText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: themeBorder),
          borderRadius: BorderRadius.circular(8),
          color: themeBg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // FLOATING CANVAS INTERACTION LOGIC
  Widget _buildFloatingInteractions(Map<String, dynamic> t) {
    if (showFinalModal) return const SizedBox();
    
    Widget content = const SizedBox();
    switch (currentStep) {
      case 1:
        content = _buildPrimaryBtn(t['ui_init'], completeStep, themeAccent);
        break;
      case 2:
        content = Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(color: themePrimary.withOpacity(0.9), border: Border.all(color: themePrimary), borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t['ui_task_active'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(t['ui_find_click'], style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        );
        break;
      case 3:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: themeError.withOpacity(0.9), border: Border.all(color: themeError), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Flexible(child: Text(t['err_height'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            _buildPrimaryBtn(t['ui_analyze'], completeStep, themeSecondary),
          ],
        );
        break;
      case 4:
        content = _buildPrimaryBtn(t['ui_unlock_sss'], completeStep, themePrimary);
        break;
      case 5:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: _buildInputCard(0, '40', 'a', themeAccent)),
            const SizedBox(width: 6),
            Flexible(child: _buildInputCard(1, '24', 'b', themeSecondary)),
            const SizedBox(width: 6),
            Flexible(child: _buildInputCard(2, '32', 'c', themeSuccess)),
          ],
        );
        break;
      case 6:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: themeBg.withOpacity(0.9), border: Border.all(color: themeSuccess), borderRadius: BorderRadius.circular(12)),
              child: Text('P = 40 + 24 + 32 = 96m', textAlign: TextAlign.center, style: TextStyle(color: themeSuccess, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ),
            _buildPrimaryBtn(t['ui_confirm_p'], completeStep, themeSuccess, textColor: Colors.black),
          ],
        );
        break;
      case 7:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: step7SliderValue,
              min: 0,
              max: 96,
              divisions: 96,
              label: step7SliderValue.toInt().toString(), // Dynamic Tooltip on Thumb
              activeColor: themeAccent,
              inactiveColor: Colors.white24,
              onChanged: (val) {
                // Throttle click sound slightly for slider
                if (val.toInt() % 10 == 0) playClick(); 
                
                setState(() => step7SliderValue = val);
                if (val == 48.0) {
                  Future.delayed(const Duration(milliseconds: 500), completeStep);
                }
              },
            ),
            // Visible Dynamic Label below slider
            Text(
              step7SliderValue == 48 ? 's = 96 / 2 = 48' : 's = ${step7SliderValue.toInt()}',
              style: TextStyle(
                color: step7SliderValue == 48 ? themeSuccess : themeAccent,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                shadows: step7SliderValue == 48 ? [BoxShadow(color: themeSuccess, blurRadius: 10)] : null,
              ),
            ),
          ],
        );
        break;
      case 8:
        content = Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildDiffBtn(1, '48-40', '8', t)),
            const SizedBox(width: 6),
            Expanded(child: _buildDiffBtn(2, '48-24', '24', t)),
            const SizedBox(width: 6),
            Expanded(child: _buildDiffBtn(3, '48-32', '16', t)),
          ],
        );
        break;
      case 9:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDraggable('48', themeAccent),
                  const SizedBox(width: 6),
                  _buildDraggable('8', themeSuccess),
                  const SizedBox(width: 6),
                  _buildDraggable('24', themePrimary),
                  const SizedBox(width: 6),
                  _buildDraggable('16', themeSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: themeBg.withOpacity(0.9), border: Border.all(color: themeBorder), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('√', style: TextStyle(color: themeText, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  _buildDragTarget(0, '48', 's'),
                  Text(' • ', style: TextStyle(color: themeText, fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildDragTarget(1, '8', 's-a'),
                  Text(' • ', style: TextStyle(color: themeText, fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildDragTarget(2, '24', 's-b'),
                  Text(' • ', style: TextStyle(color: themeText, fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildDragTarget(3, '16', 's-c'),
                ],
              ),
            )
          ],
        );
        break;
      case 10:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: themeBg.withOpacity(0.9), border: Border.all(color: themeSuccess), borderRadius: BorderRadius.circular(12)),
              child: Text('√(48 × 8 × 24 × 16) = 384', textAlign: TextAlign.center, style: TextStyle(color: themeText, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ),
            _buildPrimaryBtn(t['ui_certify'], completeStep, themeSuccess, textColor: Colors.black),
          ],
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: themePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeBorder, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, spreadRadius: 2)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t['ui_mission_control'], style: TextStyle(color: themeAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: themeBorder, borderRadius: BorderRadius.circular(4)),
                child: Text('${t['ui_lvl']} $currentStep', style: TextStyle(color: themeText, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(t['steps'][currentStep - 1], style: TextStyle(color: themeText, fontSize: 13, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(t['instr'][currentStep - 1], textAlign: TextAlign.center, style: TextStyle(color: themeMuted, fontSize: 11)),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildPrimaryBtn(String text, VoidCallback onTap, Color bgColor, {Color textColor = Colors.white}) {
    return InkWell(
      onTap: () {
        playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10), // Compact padding
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildInputCard(int index, String expected, String label, Color color) {
    bool isCorrect = step5Inputs[index] == expected;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            enabled: !isCorrect,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(color: isCorrect ? color : themeText, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: '?',
              hintStyle: TextStyle(color: themeMuted),
              filled: true,
              fillColor: isCorrect ? color.withOpacity(0.1) : themeBg,
              contentPadding: const EdgeInsets.symmetric(vertical: 8), // Compact
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color.withOpacity(0.5))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 2)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 2)),
            ),
            onChanged: (val) {
              playClick();
              if (val == expected) {
                setState(() => step5Inputs[index] = val);
                if (step5Inputs.values.every((v) => v != null)) {
                  Future.delayed(const Duration(milliseconds: 500), completeStep);
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiffBtn(int id, String formula, String expected, Map<String, dynamic> t) {
    bool isDone = step8Buttons[id] == true;
    return InkWell(
      onTap: isDone ? null : () {
        playClick();
        setState(() => step8Buttons[id] = true);
        if (step8Buttons.values.every((v) => v == true)) {
          Future.delayed(const Duration(milliseconds: 500), completeStep);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10), // Compact padding
        decoration: BoxDecoration(
          color: isDone ? themeSuccess.withOpacity(0.2) : themeBg,
          border: Border.all(color: isDone ? themeSuccess : themeBorder, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          isDone ? expected : '${t['ui_compute']}\n($formula)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDone ? themeSuccess : themeMuted,
            fontSize: isDone ? 16 : 11,
            fontWeight: FontWeight.w900,
            fontFamily: isDone ? 'monospace' : 'sans-serif',
            shadows: isDone ? [BoxShadow(color: themeSuccess, blurRadius: 10)] : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDraggable(String value, Color color) {
    if (step9Slots.containsValue(value)) return const SizedBox();
    return Draggable<String>(
      data: value,
      onDragStarted: () => playClick(),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(blurRadius: 10)]),
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
        child: Text(value, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.w900)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Compact
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]),
        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildDragTarget(int index, String expected, String hint) {
    bool isFilled = step9Slots[index] != null;
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        if (details.data == expected) {
          playSuccess();
          setState(() {
            step9Slots[index] = details.data;
            if (!step9Slots.containsValue(null)) {
              Future.delayed(const Duration(milliseconds: 500), completeStep);
            }
          });
        } else {
          playError();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 35, // Compact size
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFilled ? themeSuccess.withOpacity(0.2) : themeBg.withOpacity(0.5),
            border: Border.all(
              color: isFilled ? themeSuccess : (candidateData.isNotEmpty ? themeAccent : themeBorder),
              width: 2,
              style: isFilled ? BorderStyle.solid : BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isFilled ? step9Slots[index]! : hint,
            style: TextStyle(
              color: isFilled ? themeSuccess : themeMuted,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              shadows: isFilled ? [BoxShadow(color: themeSuccess, blurRadius: 10)] : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCanvasArea(double sidebarWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.1,
          maxScale: 5.0,
          child: GestureDetector(
            onTapUp: (details) => handleCanvasTap(
              details.localPosition, 
              Size(constraints.maxWidth, constraints.maxHeight),
              sidebarWidth
            ),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: CustomPaint(
                painter: TrianglePainter(
                  step: currentStep,
                  isSidebarOpen: isSidebarOpen,
                  sidebarWidth: sidebarWidth,
                  vA: vA, vB: vB, vC: vC,
                  themeAccent: themeAccent,
                  themeSuccess: themeSuccess,
                  themeError: themeError,
                  themeHighlight: themeSecondary,
                  gridColor: themeAccent.withOpacity(0.05),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildFinalCompleteModal(Map<String, dynamic> t) {
    return SingleChildScrollView(
      child: Container(
        width: 450,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: themePanel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeSuccess, width: 2),
          boxShadow: [BoxShadow(color: themeSuccess.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Right Close Icon
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () {
                  playClick();
                  setState(() => showFinalModal = false);
                },
              ),
            ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: themeSuccess,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: themeSuccess.withOpacity(0.5), blurRadius: 25)],
              ),
              child: const Icon(Icons.workspace_premium, color: Colors.black, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              t['ui_mission_complete'],
              style: TextStyle(color: themeSuccess, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: themeBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: themeBorder)),
              child: Text(
                t['ui_area_cert'],
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: fullReset,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [themePrimary, themeAccent]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: themeAccent.withOpacity(0.4), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(t['ui_restart'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final int step;
  final bool isSidebarOpen;
  final double sidebarWidth;
  final Offset vA, vB, vC;
  final Color themeAccent, themeSuccess, themeError, themeHighlight, gridColor;

  TrianglePainter({
    required this.step,
    required this.isSidebarOpen,
    required this.sidebarWidth,
    required this.vA, required this.vB, required this.vC,
    required this.themeAccent, required this.themeSuccess, required this.themeError,
    required this.themeHighlight, required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double minX = [vA.dx, vB.dx, vC.dx].reduce(math.min);
    final double maxX = [vA.dx, vB.dx, vC.dx].reduce(math.max);
    final double minY = [vA.dy, vB.dy, vC.dy].reduce(math.min);
    final double maxY = [vA.dy, vB.dy, vC.dy].reduce(math.max);
    
    final double triW = maxX - minX;
    final double triH = maxY - minY;
    
    // Calculate the truly available area unblocked by floating UI
    final double availableWidth = isSidebarOpen ? size.width - sidebarWidth : size.width;
    final double availableHeight = size.height - 180; // safe area for bottom floating UI
    
    final double scaleX = availableWidth / (triW + 150);
    final double scaleY = availableHeight / (triH + 150); 
    double scale = math.min(scaleX, scaleY);
    if(scale > 1.2) scale = 1.2;
    if(scale < 0.2) scale = 0.2;
    
    // Dynamic visual center calculation based on active UI layers
    final double centerX = isSidebarOpen ? sidebarWidth + (availableWidth / 2) : size.width / 2;
    final double centerY = availableHeight / 2;

    final double panX = centerX - ((minX + maxX) / 2) * scale;
    final double panY = centerY - ((minY + maxY) / 2) * scale;

    canvas.save();
    canvas.translate(panX, panY);
    canvas.scale(scale, scale);

    final Paint gridPaint = Paint()..color = gridColor..strokeWidth = 1 / scale;
    double left = -panX / scale;
    double top = -panY / scale;
    double right = left + size.width / scale;
    double bottom = top + size.height / scale;
    
    double stepSize = 50;
    for (double x = (left / stepSize).floor() * stepSize; x < right; x += stepSize) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), gridPaint);
    }
    for (double y = (top / stepSize).floor() * stepSize; y < bottom; y += stepSize) {
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }

    if (step == 10) {
      final fillPaint = Paint()
        ..color = themeSuccess.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      final path = Path()..moveTo(vA.dx, vA.dy)..lineTo(vB.dx, vB.dy)..lineTo(vC.dx, vC.dy)..close();
      canvas.drawPath(path, fillPaint);
    }

    final Paint strokePaint = Paint()
      ..color = themeAccent
      ..strokeWidth = 6 / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    Color colorA = themeAccent;
    Color colorB = themeAccent;
    Color colorC = themeAccent;

    if (step > 2) { colorA = themeSuccess; colorB = themeSuccess; colorC = themeSuccess; }
    if (step == 2) { colorA = themeHighlight; }

    strokePaint.color = colorA;
    canvas.drawLine(vC, vB, strokePaint);
    
    strokePaint.color = colorB;
    canvas.drawLine(vA, vC, strokePaint);
    
    strokePaint.color = colorC;
    canvas.drawLine(vA, vB, strokePaint);

    _drawText(canvas, "A", vA.dx, vA.dy - 30, Colors.white, 24 / scale);
    _drawText(canvas, "B", vB.dx + 30, vB.dy + 10, Colors.white, 24 / scale);
    _drawText(canvas, "C", vC.dx - 30, vC.dy + 10, Colors.white, 24 / scale);

    if (step >= 5) {
      _drawText(canvas, "a=40", (vC.dx + vB.dx) / 2, vC.dy + 35, themeHighlight, 20 / scale);
      _drawText(canvas, "b=24", (vA.dx + vC.dx) / 2 - 40, (vA.dy + vC.dy) / 2 - 10, themeHighlight, 20 / scale);
      _drawText(canvas, "c=32", (vA.dx + vB.dx) / 2 + 40, (vA.dy + vB.dy) / 2 - 10, themeHighlight, 20 / scale);
    }

    if (step == 3) {
      final Paint dashPaint = Paint()
        ..color = themeError
        ..strokeWidth = 4 / scale
        ..style = PaintingStyle.stroke;
      
      double dashLength = 10 / scale;
      double distance = vC.dy - vA.dy;
      int numDashes = (distance / (dashLength * 2)).floor();
      
      for (int i = 0; i < numDashes; i++) {
        double startY = vA.dy + i * 2 * dashLength;
        canvas.drawLine(Offset(vA.dx, startY), Offset(vA.dx, startY + dashLength), dashPaint);
      }
      _drawText(canvas, "h = ?", vA.dx + 40, (vA.dy + vC.dy) / 2, themeError, 24 / scale);
    }

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, double x, double y, Color color, double size) {
    final textStyle = TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold, fontFamily: 'sans-serif');
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.isSidebarOpen != isSidebarOpen || oldDelegate.sidebarWidth != sidebarWidth;
  }
}

// Data Translations Map
const Map<String, Map<String, dynamic>> labText = {
  'en': {
    'header_title': "The Height Hunter",
    'header_subtitle': "Class 9 • HERON'S FORMULA",
    'obj_title': "Mission Objective",
    'proc_title': "Procedural Steps",
    'concept_title': "Current Concept",
    'err_height': "ERROR: Altitude Unknown.\nCannot drop perpendicular line.",
    'objective': "Demonstrate why standard base & height formula fails when altitude is unknown, and calculate the area using Heron's formula based entirely on side lengths.",
    'steps': [
      "1. The Survey Site",
      "2. Standard Approach",
      "3. The Altitude Obstacle",
      "4. Unlocking Heron's Tool",
      "5. Inputting Data",
      "6. Calculating Perimeter",
      "7. Semi-Perimeter (s)",
      "8. Calculating Differences",
      "9. Assembling Formula",
      "10. Final Survey"
    ],
    'instr': [
      "Welcome to the site. Click to initialize the geometry sensors.",
      "Standard method requires a base. Click on Side 'a' (40m) on the canvas to set the base.",
      "Attempt to measure height vertically from Vertex A down to the base.",
      "Standard methods failed. Unlock the SSS (Side-Side-Side) Tool.",
      "Read the canvas lengths. Input a, b, and c.",
      "Sum the sides to find total Perimeter (P).",
      "Use the slider to divide the perimeter exactly in half to find 's'.",
      "Compute how much each side deviates from 's'.",
      "Drag values (s, s-a, s-b, s-c) into the square root.",
      "Certify the final area calculation."
    ],
    'teacher_steps': [
      "We are surveying a plot of land. Let's initialize our measuring tools.",
      "Standard formulas need a 'Base' and 'Height'. We have selected Side 'a' (40m) to act as our base.",
      "The height must be a perfectly straight (perpendicular) line from the top. In uneven terrain, measuring this is impossible!",
      "Since we don't know the height, the standard formula is useless. We must switch to Heron's Formula, which doesn't need height.",
      "Heron's Formula only needs the lengths of all three sides. Enter a=40, b=24, and c=32.",
      "Step one of Heron's Formula is finding the Perimeter (P). Just add up all the outer boundaries: 40 + 24 + 32 = 96m.",
      "Next, find the Semi-Perimeter ('s') by dividing the Perimeter by 2. Half of 96 is 48.",
      "Now, find the difference between 's' and each side: (48-40), (48-24), and (48-32).",
      "Put all these values into Heron's Formula: √( s × (s-a) × (s-b) × (s-c) ).",
      "Calculate the final square root to get the certified area of the triangle!"
    ],
    'concepts': [
      "Every plot calculation starts by defining vertices and boundaries clearly.",
      "The standard triangle area formula (Area = 1/2 * b * h) is highly dependent on knowing a perpendicular height.",
      "In real-world surveying of uneven land, finding a perfect perpendicular altitude is often physically impossible.",
      "Heron of Alexandria devised a method ~60 AD to find area using only the lengths of the three sides.",
      "Accurate side measurements are the only variables required for Heron's formula.",
      "Perimeter represents the total distance around a 2D shape.",
      "Semi-perimeter ('s') acts as a balancing constant that normalizes the side lengths in the formula.",
      "The differences represent the relationship between the average scale of the triangle and its individual sides.",
      "The product inside the square root geometrically represents scaling factors converging into an area dimension.",
      "The final area is expressed in square units, representing the total 2D space enclosed."
    ],
    'ui_mission_control': "Mission Control",
    'ui_lvl': "Lvl",
    'ui_init': "Initialize Sensors",
    'ui_task_active': "TASK ACTIVE",
    'ui_find_click': "Find & click Side 'a' on the canvas.",
    'ui_analyze': "Analyze & Proceed",
    'ui_unlock_sss': "Unlock SSS Tool",
    'ui_confirm_p': "Confirm Perimeter",
    'ui_compute': "Compute",
    'ui_certify': "Certify Area",
    'ui_mission_complete': "MISSION COMPLETE!",
    'ui_area_cert': "Area Certified: 384 sq meters.\nHeron's formula mastery at 100%.",
    'ui_restart': "RESTART MISSION",
    'ui_reset': "RESET",
    'ui_footer': "© ZEROSCIENCELAB - Fall in love with math and Science"
  },
  'hi': {
    'header_title': "हाइट हंटर",
    'header_subtitle': "कक्षा 9 • हीरोन का सूत्र",
    'obj_title': "मिशन उद्देश्य",
    'proc_title': "प्रक्रियात्मक चरण",
    'concept_title': "वर्तमान अवधारणा",
    'err_height': "त्रुटि: ऊंचाई अज्ञात।\nलंब नहीं गिराया जा सकता।",
    'objective': "दिखाएं कि ऊंचाई अज्ञात होने पर मानक सूत्र क्यों विफल होता है, और भुजाओं की लंबाई के आधार पर हेरोन के सूत्र का उपयोग करें।",
    'steps': [
      "1. सर्वेक्षण स्थल",
      "2. मानक दृष्टिकोण",
      "3. ऊंचाई की बाधा",
      "4. हेरोन उपकरण अनलॉक",
      "5. डेटा इनपुट",
      "6. परिमाप की गणना",
      "7. अर्ध-परिमाप (s)",
      "8. अंतर की गणना",
      "9. सूत्र संयोजन",
      "10. अंतिम सर्वेक्षण"
    ],
    'instr': [
      "सेंसर शुरू करने के लिए क्लिक करें।",
      "कैनवास पर आधार के रूप में भुजा 'a' (40m) पर क्लिक करें।",
      "शीर्ष A से आधार तक ऊंचाई मापने का प्रयास करें।",
      "मानक विधि विफल। SSS उपकरण अनलॉक करें।",
      "कैनवास से a, b, और c की लंबाई दर्ज करें।",
      "परिमाप (P) खोजने के लिए भुजाओं को जोड़ें।",
      "'s' खोजने के लिए स्लाइडर से परिमाप को आधा करें।",
      "गणना करें कि प्रत्येक भुजा 's' से कितनी अलग है।",
      "मानों को वर्गमूल में खींचें।",
      "अंतिम क्षेत्रफल गणना प्रमाणित करें।"
    ],
    'teacher_steps': [
      "हम एक जमीन माप रहे हैं। चलिए उपकरण शुरू करते हैं।",
      "मानक सूत्र के लिए 'आधार' और 'ऊंचाई' चाहिए। हमने भुजा 'a' (40m) को आधार चुना है।",
      "ऊंचाई हमेशा ऊपर से एकदम सीधी रेखा होनी चाहिए। ऊबड़-खाबड़ जमीन पर इसे मापना असंभव है!",
      "ऊंचाई के बिना पुराना सूत्र काम नहीं करेगा। हम हेरोन का सूत्र इस्तेमाल करेंगे, जिसमें ऊंचाई की जरूरत नहीं होती।",
      "हेरोन के सूत्र में सिर्फ तीनों भुजाओं की लंबाई चाहिए। a=40, b=24, c=32 दर्ज़ करें।",
      "हेरोन के सूत्र का पहला कदम परिमाप (P) निकालना है। बाहरी सीमाओं को जोड़ें: 40 + 24 + 32 = 96m.",
      "अब परिमाप को 2 से भाग देकर अर्ध-परिमाप ('s') निकालें। 96 का आधा 48 है।",
      "अब 's' और हर भुजा के बीच का अंतर निकालें: (48-40), (48-24), और (48-32).",
      "इन सभी मानों को हेरोन के सूत्र में रखें: √( s × (s-a) × (s-b) × (s-c) ).",
      "अंत में वर्गमूल हल करें और प्रमाणित त्रिकोण का क्षेत्रफल प्राप्त करें!"
    ],
    'concepts': [
      "सीमाओं को स्पष्ट रूप से परिभाषित किया जाता है।",
      "मानक सूत्र लंबवत ऊंचाई पर निर्भर है।",
      "असमान भूमि पर लंबवत ऊंचाई खोजना असंभव চরম हो सकता है।",
      "हेरोन ने केवल भुजाओं का उपयोग करके क्षेत्रफल खोजने की विधि दी।",
      "सटीक भुजा माप आवश्यक हैं।",
      "परिमाप कुल दूरी है।",
      "अर्ध-परिमाप 's' एक संतुलन स्थिरांक है।",
      "अंतर भुजाओं के पैमाने का संबंध दर्शाते हैं।",
      "गुणनफल क्षेत्रफल आयाम में परिवर्तित होता है।",
      "क्षेत्रफल वर्ग इकाइयों में व्यक्त किया जाता है।"
    ],
    'ui_mission_control': "मिशन नियंत्रण",
    'ui_lvl': "स्तर",
    'ui_init': "सेंसर प्रारंभ करें",
    'ui_task_active': "कार्य सक्रिय",
    'ui_find_click': "कैनवास पर भुजा 'a' खोजें और क्लिक करें।",
    'ui_analyze': "विश्लेषण करें और आगे बढ़ें",
    'ui_unlock_sss': "SSS उपकरण अनलॉक करें",
    'ui_confirm_p': "परिमाप की पुष्टि करें",
    'ui_compute': "गणना करें",
    'ui_certify': "क्षेत्रफल प्रमाणित करें",
    'ui_mission_complete': "मिशन पूरा हुआ!",
    'ui_area_cert': "प्रमाणित क्षेत्रफल: 384 वर्ग मीटर।\nहीरोन के सूत्र में 100% महारत।",
    'ui_restart': "मिशन पुनरारंभ करें",
    'ui_reset': "रीसेट",
    'ui_footer': "© ZEROSCIENCELAB - गणित और विज्ञान से प्यार करें"
  }
};