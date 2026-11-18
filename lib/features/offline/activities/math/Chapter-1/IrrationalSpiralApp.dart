// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class IrrationalSpiralApp extends StatelessWidget {
  const IrrationalSpiralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpiralFactoryLab();
  }
}

// --- AUDIO CONFIGURATION ---
// Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
final AudioPlayer _clickPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);

const String _clickUrl = 'audio/math/click.mp3';
const String _successUrl = 'audio/math/success.mp3';
const String _errorUrl = 'audio/math/error.mp3';
const String _shutterUrl = 'audio/math/shutter.mp3';

void _playAudio(AudioPlayer player, String url) async {
  try {
    await player.stop();
    await player.play(AssetSource(url));
  } catch (e) {
    debugPrint("Audio play error: $e");
  }
}

void _playClick() => _playAudio(_clickPlayer, _clickUrl);
void _playSuccess() => _playAudio(_successPlayer, _successUrl);
void _playError() => _playAudio(_errorPlayer, _errorUrl);
void _playShutter() => _playAudio(_fxPlayer, _shutterUrl);

// --- LOCALIZATION DATA ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE IRRATIONAL SPIRAL',
    'tagline': 'Constructing The Spiral of Theodorus',
    'init_btn': 'START LAB',
    'header_title': 'The Irrational Spiral',
    'header_subtitle': 'CLASS 9 • REAL NUMBERS - Irrational Number',
    'setup_title': 'Construction Status',
    'btn_reset': 'Reset Lab',
    'btn_next': 'Build Next Triangle',
    'hud_theorem': 'Pythagoras Theorem',
    'msg_complete': 'SPIRAL COMPLETE!',
    'mission_title': 'MISSION CONTROL',
    'hint_build':
        'ACTION: Tap "Build Next Triangle" or tap the canvas to grow the spiral.',
    'hint_done': 'ACTION: Construction complete! Reset the lab to restart.',
  },
  'hi': {
    'app_title': 'अपरिमेय सर्पिल',
    'tagline': 'थियोडोरस का सर्पिल निर्माण',
    'init_btn': 'लैब शुरू करें',
    'header_title': 'अपरिमेय सर्पिल',
    'header_subtitle': 'कक्षा 9 • वास्तविक संख्याएँ – अपरिमेय संख्या',
    'setup_title': 'निर्माण स्थिति',
    'btn_reset': 'रीसेट करें',
    'btn_next': 'अगला त्रिभुज बनाएं',
    'hud_theorem': 'पाइथागोरस प्रमेय',
    'msg_complete': 'सर्पिल पूर्ण!',
    'mission_title': 'मिशन कंट्रोल',
    'hint_build':
        'कार्य: सर्पिल बढ़ाने के लिए "अगला त्रिभुज बनाएं" या कैनवास पर टैप करें।',
    'hint_done': 'कार्य: निर्माण पूरा हुआ! फिर से शुरू करने के लिए रीसेट करें।',
  },
};

// Data Model for a Triangle in the Spiral
class SpiralTriangle {
  final Offset p0; // Origin (always 0,0)
  final Offset p1; // Base point
  final Offset p2; // Next point (perpendicular added)
  final int n; // Step number (1 for √2, 2 for √3...)

  SpiralTriangle(this.p0, this.p1, this.p2, this.n);
}

class SpiralFactoryLab extends StatefulWidget {
  const SpiralFactoryLab({super.key});

  @override
  State<SpiralFactoryLab> createState() => _SpiralFactoryLabState();
}

class _SpiralFactoryLabState extends State<SpiralFactoryLab>
    with TickerProviderStateMixin {
  // App UI State
  bool isPoweredOn = false;
  String lang = 'en';
  bool isSidebarOpen = true;

  // Math/Geometry State
  int step = 1;
  final int maxSteps = 17;
  final double unitLength = 150.0; // Base visual length for 1 unit
  List<SpiralTriangle> triangles = [];
  Offset currentTip = const Offset(150, 0); // Starts at (1,0) in math space
  Offset nextTip = Offset.zero;

  // Controllers
  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;
  late TransformationController _transformController;
  late AnimationController _pulseController;
  final ScrollController _hudScrollController = ScrollController();
  final ScrollController _sidebarScrollController = ScrollController();

  // Overlay state
  bool showCelebration = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shutterAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
          CurvedAnimation(
            parent: _shutterController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _transformController = TransformationController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _calculateNextTip();

    // Center the canvas on initial startup
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerView());
  }

  @override
  void dispose() {
    _shutterController.dispose();
    _transformController.dispose();
    _pulseController.dispose();
    _hudScrollController.dispose();
    _sidebarScrollController.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  String _t(String key) => i18n[lang]?[key] ?? i18n['en']![key] ?? key;

  void _centerView([double? scale]) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width * 0.4 < 320 ? 320 : size.width * 0.4;
    final canvasWidth = isSidebarOpen ? (size.width - panelWidth) : size.width;
    final offsetX = isSidebarOpen ? panelWidth : 0.0;

    final targetScale = scale ?? _transformController.value.getMaxScaleOnAxis();

    _transformController.value = Matrix4.identity()
      ..translate(
        offsetX + (canvasWidth / 2) - (1000.0 * targetScale),
        (size.height / 2) - (1000.0 * targetScale),
      )
      ..scale(targetScale);
  }

  void powerOn() {
    _playShutter();
    setState(() => isPoweredOn = true);
    _shutterController.forward();
    _centerView(1.0);
  }

  void _calculateNextTip() {
    if (step > maxSteps) return;

    double dx = currentTip.dx;
    double dy = currentTip.dy;
    double length = sqrt(dx * dx + dy * dy);

    double px = (dy / length) * unitLength;
    double py = (-dx / length) * unitLength;

    nextTip = Offset(dx + px, dy + py);
  }

  void buildNext() {
    if (step > maxSteps) return;

    _playClick();
    setState(() {
      triangles.add(SpiralTriangle(Offset.zero, currentTip, nextTip, step));
      currentTip = nextTip;
      step++;

      if (step <= maxSteps) {
        _calculateNextTip();
      } else {
        _playSuccess();
        showCelebration = true;
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => showCelebration = false);
        });
      }
    });
  }

  void resetLab() {
    _playClick();
    setState(() {
      step = 1;
      triangles.clear();
      currentTip = Offset(unitLength, 0);
      _calculateNextTip();
      _centerView(1.0);
      showCelebration = false;
    });
  }

  Widget _buildStepDescription() {
    String text = step <= maxSteps ? _t('hint_build') : _t('hint_done');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF43F5E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF43F5E).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFFFB7185),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivityContent() {
    return [
      _buildStepDescription(),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('setup_title').toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT HYPOTENUSE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '√$step',
                      style: const TextStyle(
                        color: Color(0xFFF43F5E),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFFF43F5E).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    step == 1 ? 'Start' : 'Step $step',
                    style: const TextStyle(
                      color: Color(0xFFFB7185),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (step <= maxSteps) ...[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: buildNext,
            icon: const Icon(Icons.architecture),
            label: Text(_t('btn_next')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF334155))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BLUEPRINT',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${step - 1}/16',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 16,
                itemBuilder: (context, index) {
                  int s = index + 1;
                  bool isDone = s < step;
                  bool isActive = s == step;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.green.withOpacity(0.1)
                          : isActive
                          ? const Color(0xFFF43F5E).withOpacity(0.1)
                          : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDone
                            ? Colors.green.withOpacity(0.3)
                            : isActive
                            ? const Color(0xFFF43F5E)
                            : const Color(0xFF334155),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '√$s  ➔  √${s + 1}',
                          style: TextStyle(
                            color: isDone
                                ? Colors.greenAccent
                                : isActive
                                ? const Color(0xFFFDA4AF)
                                : const Color(0xFF64748B),
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Icon(
                          isDone
                              ? Icons.check
                              : isActive
                              ? Icons.play_arrow
                              : Icons.circle,
                          size: 16,
                          color: isDone
                              ? Colors.greenAccent
                              : isActive
                              ? const Color(0xFFF43F5E)
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: resetLab,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: const Color(0xFF94A3B8),
            side: const BorderSide(color: Color(0xFF334155)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(_t('btn_reset')),
        ),
      ),
    ];
  }

  // Build the floating Mission Card
  Widget _buildMissionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF43F5E).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrink wraps height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment,
                  color: Color(0xFFFB7185),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _t('mission_title').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Flexible(
            child: Scrollbar(
              controller: _hudScrollController,
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                controller: _hudScrollController,
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildActivityContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        border: Border(
          top: BorderSide(color: const Color(0xFFF43F5E).withOpacity(0.3)),
        ),
      ),
      child: const Center(
        child: Text(
          '© ZEROSCIENCELAB | Fall in Love with Math and Science',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // --- BUILDERS ---
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double panelWidth = w * 0.4 < 320 ? 320 : w * 0.4;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Base Layer: Main Canvas
            _buildMainCanvas(),

            // 2. Sidebar Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: isSidebarOpen ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: _buildSidePanel(panelWidth),
            ),

            // 3. Floating Mission Card (when sidebar is closed)
            if (isPoweredOn)
              Positioned(
                top: 80, // Positioned safely below the toggle button
                left: 24,
                child: AnimatedOpacity(
                  opacity: !isSidebarOpen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: isSidebarOpen,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: panelWidth - 40,
                        maxHeight: h - 104,
                      ),
                      child: _buildMissionCard(),
                    ),
                  ),
                ),
              ),

            // 4. Floating Menu Button (Top Left)
            if (isPoweredOn)
              Positioned(
                top: 24,
                left: 24,
                child: _buildFloatingButton(
                  isSidebarOpen ? Icons.menu_open : Icons.menu,
                  () {
                    _playClick();
                    setState(() => isSidebarOpen = !isSidebarOpen);
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      _centerView,
                    );
                  },
                ),
              ),

            // 5. Intro Shutter
            if (!isPoweredOn)
              SlideTransition(
                position: _shutterAnimation,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF020617),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _pulseController.value * pi,
                              child: const Icon(
                                Icons.architecture,
                                size: 120,
                                color: Color(0xFFF43F5E),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _t('app_title'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          _t('tagline'),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 16,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: powerOn,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(_t('init_btn')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 6. Celebration Overlay (Top Z-Index)
            if (showCelebration)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _t('msg_complete'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFF43F5E),
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x80F43F5E),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFF43F5E),
                                    width: 2,
                                  ),
                                ),
                                child: const Text(
                                  '√17 Reached',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: onTap,
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildSidePanel(double width) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(right: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: ClipRect(
        child: OverflowBox(
          minWidth: width,
          maxWidth: width,
          alignment: Alignment.topLeft,
          child: CustomScrollView(
            controller: _sidebarScrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 88, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('header_title'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _t('header_subtitle'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Color(0xFFFB7185),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Language Toggles & Restart
                      _buildLangToggles(),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFF1E293B), height: 1),
                      const SizedBox(height: 24),

                      // Activity Content
                      ..._buildActivityContent(),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_buildSidebarFooter()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangToggles() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['en', 'hi'].map((l) {
              return GestureDetector(
                onTap: () {
                  _playClick();
                  setState(() => lang = l);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: lang == l
                        ? const Color(0xFFE11D48)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: lang == l ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            _playClick();
            setState(() {
              resetLab();
              isPoweredOn = false;
            });
            _shutterController.reset();
          },
          icon: const Icon(Icons.power_settings_new),
          color: const Color(0xFFF43F5E),
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
          tooltip: 'Power Reset',
        ),
      ],
    );
  }

  // --- CANVAS & INTERACTION ---
  Widget _buildMainCanvas() {
    return Container(
      color: const Color(0xFF020617), // Deepest dark
      child: Stack(
        children: [
          // Interactive 2D Map
          GestureDetector(
            onTapUp: (details) {
              buildNext();
            },
            child: InteractiveViewer(
              transformationController: _transformController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(2000),
              minScale: 0.1,
              maxScale: 3.0,
              child: SizedBox(
                width: 2000,
                height: 2000,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SpiralPainter(
                        triangles: triangles,
                        currentTip: currentTip,
                        nextTip: nextTip,
                        step: step,
                        maxSteps: maxSteps,
                        pulseValue: _pulseController.value,
                        unitLength: unitLength,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // HUD Top Right
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Color(0xFFF43F5E), width: 4),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 20),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('hud_theorem').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFB7185),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'H² = P² + B²',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SPIRAL PAINTER ---
class SpiralPainter extends CustomPainter {
  final List<SpiralTriangle> triangles;
  final Offset currentTip;
  final Offset nextTip;
  final int step;
  final int maxSteps;
  final double pulseValue;
  final double unitLength;

  SpiralPainter({
    required this.triangles,
    required this.currentTip,
    required this.nextTip,
    required this.step,
    required this.maxSteps,
    required this.pulseValue,
    required this.unitLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Background Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.5)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 100) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Move Origin to center-ish (offset by the initial transform translation)
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    // 2. Draw Initial Line
    final linePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (triangles.isEmpty) {
      canvas.drawLine(Offset.zero, Offset(unitLength, 0), linePaint);
      _drawText(
        canvas,
        '1',
        Offset(unitLength / 2, -20),
        fontSize: 24,
        color: Colors.white,
      );
    }

    // 3. Draw Built Triangles
    for (var t in triangles) {
      final path = Path()
        ..moveTo(t.p0.dx, t.p0.dy)
        ..lineTo(t.p1.dx, t.p1.dy)
        ..lineTo(t.p2.dx, t.p2.dy)
        ..close();

      // Fill
      double hue = (t.n * 20.0) % 360;
      final fillPaint = Paint()
        ..color = HSLColor.fromAHSL(0.5, hue, 0.8, 0.6).toColor()
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // Stroke
      final strokePaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, strokePaint);

      // Hypotenuse Label
      Offset midHyp = Offset((t.p0.dx + t.p2.dx) / 2, (t.p0.dy + t.p2.dy) / 2);
      double ang = atan2(t.p2.dy, t.p2.dx);
      Offset labelPos = Offset(
        midHyp.dx + cos(ang + pi / 2) * 20,
        midHyp.dy + sin(ang + pi / 2) * 20,
      );
      _drawText(
        canvas,
        '√${t.n + 1}',
        labelPos,
        fontSize: 18,
        color: Colors.white,
      );

      // Outer Perpendicular Line is always length 1
      Offset midPerp = Offset((t.p1.dx + t.p2.dx) / 2, (t.p1.dy + t.p2.dy) / 2);
      if (t.n < 5) {
        double perpAng = atan2(t.p2.dy - t.p1.dy, t.p2.dx - t.p1.dx);
        Offset perpPos = Offset(
          midPerp.dx + cos(perpAng + pi / 2) * 20,
          midPerp.dy + sin(perpAng + pi / 2) * 20,
        );
        _drawText(
          canvas,
          '1',
          perpPos,
          fontSize: 14,
          color: const Color(0xFF94A3B8),
        );
      }
    }

    // 4. Draw Ghost Triangle (Next Step)
    if (step <= maxSteps) {
      final ghostPath = Path()
        ..moveTo(0, 0)
        ..lineTo(currentTip.dx, currentTip.dy)
        ..lineTo(nextTip.dx, nextTip.dy)
        ..close();

      final ghostFill = Paint()
        ..color = const Color(0xFFF43F5E).withOpacity(0.1 + (pulseValue * 0.2))
        ..style = PaintingStyle.fill;
      canvas.drawPath(ghostPath, ghostFill);

      final ghostStroke = Paint()
        ..color = const Color(0xFFF43F5E).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(ghostPath, ghostStroke);
    }

    // Origin Point marker
    canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.white);

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 20,
    Color color = Colors.white,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
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
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant SpiralPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.pulseValue != pulseValue;
  }
}
