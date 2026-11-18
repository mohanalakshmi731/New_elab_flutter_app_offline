// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'FACTOR SPACE ACADEMY',
    'tagline': 'MISSION: PRIME FACTORIZATION',
    'init_btn': 'ENTER SIMULATION',
    'header_subtitle':
        'CLASS 10 • REAL NUMBERS - Fundamental Theorem of Arithmetic.',
    'lab_status_header': 'TARGET MASS',
    'setup_title': 'Mission Config',
    'inp_label': 'Enter Mass (Composite)',
    'btn_plant': 'Launch',
    'btn_reset': 'Reset Mission',
    'btn_restart': 'New Mission',
    'hud_theorem': 'Fundamental Theorem',
    'msg_prime': 'PRIME STATUS!',
    'hint_click': 'Tap glowing nodes to split mass.',
    'step_desc': 'Split {n} into {p} x {q}',
  },
  'hi': {
    'app_title': 'गुणनखंड अंतरिक्ष अकादमी',
    'tagline': 'मिशन: अभाज्य गुणनखंड',
    'init_btn': 'सिमुलेशन शुरू करें',
    'header_subtitle': 'कक्षा 10 • वास्तविक संख्याएँ – अंकगणित का मूल प्रमेय',
    'lab_status_header': 'लक्ष्य भार',
    'setup_title': 'मिशन सेटअप',
    'inp_label': 'भार दर्ज करें',
    'btn_plant': 'लॉन्च',
    'btn_reset': 'मिशन रीसेट',
    'btn_restart': 'नया मिशन',
    'hud_theorem': 'आधारभूत प्रमेय',
    'msg_prime': 'अभाज्य!',
    'hint_click': 'विभाजित करने के लिए चमकते नोड्स पर टैप करें।',
    'step_desc': '{n} को {p} x {q} में विभाजित करें',
  },
};

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

// --- MODELS ---
class FactorStep {
  final int n, p, q;
  FactorStep(this.n, this.p, this.q);
}

class TreeNode {
  final String id;
  final int val;
  final bool isPrime;
  bool processed;
  Offset position;
  final int depth;

  TreeNode({
    required this.id,
    required this.val,
    required this.isPrime,
    required this.position,
    this.processed = false,
    this.depth = 0,
  });
}

class TreeEdge {
  final Offset start;
  final Offset end;
  TreeEdge(this.start, this.end);
}

// --- MAIN WIDGET ---
class FactorSpaceAcademyApp extends StatefulWidget {
  const FactorSpaceAcademyApp({super.key});

  @override
  State<FactorSpaceAcademyApp> createState() => _FactorSpaceAcademyAppState();
}

class _FactorSpaceAcademyAppState extends State<FactorSpaceAcademyApp>
    with TickerProviderStateMixin {
  // App State
  final ScrollController _exploreTabScrollController = ScrollController();
  String currentLang = 'en';
  bool showCurtain = true;
  bool isSidebarOpen = true;

  // Game State
  int targetMass = 60;
  List<FactorStep> steps = [];
  int currentStepIdx = 0;
  List<TreeNode> activeNodes = [];
  List<TreeEdge> activeEdges = [];
  bool isGameActive = false;
  bool showCelebration = false;

  final TextEditingController _numberController = TextEditingController(
    text: '60',
  );
  final TransformationController _transformationController =
      TransformationController();

  // Animation Controllers
  late AnimationController _curtainAnimController;
  late Animation<Offset> _curtainOffset;

  @override
  void initState() {
    super.initState();
    setLandscape();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _curtainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _curtainOffset =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
          CurvedAnimation(
            parent: _curtainAnimController,
            curve: Curves.easeInOutQuart,
          ),
        );
  }

  setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _curtainAnimController.dispose();
    _numberController.dispose();
    _transformationController.dispose();
    _exploreTabScrollController.dispose();
    super.dispose();
  }

  String t(String key) {
    return i18n[currentLang]?[key] ?? key;
  }

  // --- LOGIC ---
  int getSmallestPrime(int n) {
    if (n % 2 == 0) return 2;
    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return i;
    }
    return n;
  }

  List<FactorStep> calculateTree(int n) {
    List<FactorStep> generatedSteps = [];
    int current = n;
    while (true) {
      int p = getSmallestPrime(current);
      if (p == current) break;
      int q = current ~/ p;
      generatedSteps.add(FactorStep(current, p, q));
      current = q;
    }
    return generatedSteps;
  }

  void _zoom(double factor) {
    _playClick();
    final matrix = _transformationController.value.clone();
    final currentScale = matrix.getMaxScaleOnAxis();
    double targetScale = currentScale * factor;

    if (targetScale < 0.1) factor = 0.1 / currentScale;
    if (targetScale > 3.0) factor = 3.0 / currentScale;
    if (factor == 1.0) return;

    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = screenWidth * 0.4;
    double viewWidth = isSidebarOpen ? (screenWidth - panelWidth) : screenWidth;
    double offsetX = isSidebarOpen ? panelWidth : 0.0;
    double targetCenterX = offsetX + (viewWidth / 2);

    final Offset centerOffset = Offset(
      targetCenterX,
      MediaQuery.of(context).size.height / 2,
    );

    final Matrix4 newMatrix = Matrix4.identity()
      ..translate(
        centerOffset.dx * (1 - factor),
        centerOffset.dy * (1 - factor),
      )
      ..scale(factor)
      ..multiply(matrix);

    _transformationController.value = newMatrix;
  }

  void _centerCanvas() {
    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = screenWidth * 0.4;
    double viewWidth = isSidebarOpen ? (screenWidth - panelWidth) : screenWidth;
    double offsetX = isSidebarOpen ? panelWidth : 0.0;
    double targetCenterX = offsetX + (viewWidth / 2);

    _transformationController.value = Matrix4.identity()
      ..translate(
        -(1000.0 - targetCenterX),
        -(1000.0 - (MediaQuery.of(context).size.height / 2)),
      );
  }

  void startGame() {
    FocusScope.of(context).unfocus();
    int? val = int.tryParse(_numberController.text);

    if (val == null || val < 2) {
      _playError();
      val = 60; // Provide safe default if invalid
      _numberController.text = val.toString();
    } else {
      _playClick();
    }

    setState(() {
      targetMass = val!;
      steps = calculateTree(val);
      currentStepIdx = 0;
      activeNodes.clear();
      activeEdges.clear();
      isGameActive = true;

      if (steps.isEmpty) {
        showCelebration = true;
        _playSuccess();
      } else {
        showCelebration = false;
      }

      _centerCanvas();

      activeNodes.add(
        TreeNode(
          id: 'root',
          val: val,
          isPrime: steps.isEmpty,
          position: const Offset(0, 0),
          depth: 0,
        ),
      );
    });
  }

  void resetGame() {
    _playClick();
    setState(() {
      isGameActive = false;
      activeNodes.clear();
      activeEdges.clear();
      steps.clear();
      currentStepIdx = 0;
      showCelebration = false;
    });
  }

  void fullReset() {
    _playClick();
    setState(() {
      isGameActive = false;
      activeNodes.clear();
      activeEdges.clear();
      steps.clear();
      currentStepIdx = 0;
      showCelebration = false;
      showCurtain = true;
    });
    if (_exploreTabScrollController.hasClients) {
      _exploreTabScrollController.jumpTo(0);
    }
    _curtainAnimController.reset();
  }

  void handleNodeTap(TreeNode node) {
    if (!isGameActive || currentStepIdx >= steps.length) return;

    FactorStep currentStep = steps[currentStepIdx];
    if (node.val != currentStep.n || node.processed) {
      if (!node.processed && !node.isPrime) {
        _playError();
      }
      return;
    }

    _playClick();

    setState(() {
      node.processed = true;
      int p = currentStep.p;
      int q = currentStep.q;

      double yOffset = 100.0;
      double xSpread = 120.0 * math.pow(0.85, node.depth);

      Offset leftPos = Offset(
        node.position.dx - xSpread,
        node.position.dy + yOffset,
      );
      Offset rightPos = Offset(
        node.position.dx + xSpread,
        node.position.dy + yOffset,
      );

      activeNodes.add(
        TreeNode(
          id: 'node_${currentStepIdx}_L',
          val: p,
          isPrime: true,
          position: leftPos,
          depth: node.depth + 1,
        ),
      );

      bool isQPrime = currentStepIdx == steps.length - 1;
      activeNodes.add(
        TreeNode(
          id: 'node_${currentStepIdx}_R',
          val: q,
          isPrime: isQPrime,
          position: rightPos,
          depth: node.depth + 1,
        ),
      );

      activeEdges.add(TreeEdge(node.position, leftPos));
      activeEdges.add(TreeEdge(node.position, rightPos));

      currentStepIdx++;

      if (currentStepIdx >= steps.length) {
        showCelebration = true;
        _playSuccess();
      }
    });
  }

  void startExperience() {
    _playShutter();
    _curtainAnimController.forward().then((_) {
      setState(() {
        showCurtain = false;
      });
    });
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Canvas Background
            _buildInteractiveCanvas(),

            // 2. Main 40% Side Panel Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -(screenWidth * 0.4),
              top: 0,
              bottom: 0,
              width: screenWidth * 0.4,
              child: _buildSidePanel(screenWidth),
            ),

            // 3. Floating Interactive Elements
            if (!showCurtain) ...[
              _buildFloatingEquationPanel(screenWidth * 0.4),
              if (!isSidebarOpen) _buildFloatingMissionCard(),
              _buildZoomControls(),
              _buildBottomLeftMenuButton(),
            ],

            // 4. Celebration Overlay
            if (showCelebration) _buildCelebrationOverlay(),

            // 5. App Startup Curtain
            if (showCurtain)
              SlideTransition(position: _curtainOffset, child: _buildCurtain()),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLeftMenuButton() {
    return Positioned(
      top: 24,
      left: 24,
      child: Material(
        color: const Color(0xFF6366F1),
        shape: const CircleBorder(),
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: Icon(
            isSidebarOpen ? Icons.menu_open : Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            _playClick();
            setState(() => isSidebarOpen = !isSidebarOpen);
            Future.delayed(const Duration(milliseconds: 300), _centerCanvas);
          },
          tooltip: 'Toggle Menu',
        ),
      ),
    );
  }

  Widget _buildSidePanel(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.5),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: _exploreTabScrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildPanelHeader()),
          SliverToBoxAdapter(child: _buildExploreTab()),
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
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 88, left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('app_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t('header_subtitle'),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF818CF8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLangToggles(),
              IconButton(
                onPressed: fullReset,
                icon: const Icon(Icons.power_settings_new),
                color: Colors.white54,
                tooltip: 'Reset Lab',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangToggles() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: ['en', 'hi'].map((lang) {
          bool isActive = currentLang == lang;
          return GestureDetector(
            onTap: () {
              _playClick();
              setState(() => currentLang = lang);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF6366F1) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lang.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.white54,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExploreTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('lab_status_header'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGameActive ? targetMass.toString() : '--',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Text(
                    isGameActive ? '$currentStepIdx/${steps.length}' : 'Start',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          !isGameActive ? _buildSetupPanel() : _buildStepsPanel(),

          if (isGameActive)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: OutlinedButton.icon(
                onPressed: resetGame,
                icon: const Icon(Icons.cancel, size: 16),
                label: Text(t('btn_reset')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetupPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                t('setup_title').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            t('inp_label').toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF818CF8),
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: startGame,
              icon: const Icon(Icons.rocket_launch),
              label: Text(t('btn_plant')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FLIGHT PLAN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF818CF8),
                    letterSpacing: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$currentStepIdx/${steps.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              bool isDone = index < currentStepIdx;
              bool isActive = index == currentStepIdx;
              FactorStep s = steps[index];
              String desc = t('step_desc')
                  .replaceAll('{n}', s.n.toString())
                  .replaceAll('{p}', s.p.toString())
                  .replaceAll('{q}', s.q.toString());

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.teal.shade900.withOpacity(0.5)
                      : (isActive
                            ? const Color(0xFF818CF8).withOpacity(0.2)
                            : const Color(0xFF1E293B)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDone
                        ? Colors.tealAccent.withOpacity(0.5)
                        : Colors.white12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDone
                          ? Icons.check_circle
                          : (isActive
                                ? Icons.radio_button_checked
                                : Icons.circle_outlined),
                      color: isDone
                          ? Colors.tealAccent
                          : (isActive ? Colors.amber : Colors.white24),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        desc,
                        style: TextStyle(
                          color: isDone
                              ? Colors.tealAccent
                              : (isActive ? Colors.amber : Colors.white70),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.amber.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.touch_app, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('hint_click'),
                    style: const TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        border: Border(
          top: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
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

  // --- INTERACTIVE CANVAS (2.5D Tree View) ---
  Widget _buildInteractiveCanvas() {
    return Positioned.fill(
      child: ClipRect(
        child: InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(1000),
          minScale: 0.1,
          maxScale: 3.0,
          child: Container(
            width: 2000,
            height: 2000,
            color: const Color(0xFF020617),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: GridPainter())),
                CustomPaint(
                  size: const Size(2000, 2000),
                  painter: EdgePainter(edges: activeEdges),
                ),
                ...activeNodes.map((node) => _buildNodeWidget(node)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingEquationPanel(double sidebarWidth) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 24,
      left: isSidebarOpen ? sidebarWidth : 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.5)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                t('hud_theorem').toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'N = p₁ × p₂ × ...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF818CF8),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    return Positioned(
      top: 70,
      left: 20,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: Color(0xFF818CF8), width: 4),
          ),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
        ),
        child: !isGameActive ? _buildMiniSetup() : _buildMiniStatus(),
      ),
    );
  }

  Widget _buildMiniSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF312E81),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.rocket_launch,
                size: 16,
                color: Color(0xFF818CF8),
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEW MISSION',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Config',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF818CF8),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  filled: true,
                  fillColor: Color(0xFF020617),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF818CF8),
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatus() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('lab_status_header'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                targetMass.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFF818CF8),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber.shade800),
            ),
            child: Text(
              '$currentStepIdx/${steps.length}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: steps.length,
              itemBuilder: (context, idx) {
                bool isDone = idx < currentStepIdx;
                bool isActive = idx == currentStepIdx;
                FactorStep s = steps[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.teal.shade900.withOpacity(0.5)
                        : (isActive
                              ? Colors.indigo.shade900.withOpacity(0.5)
                              : const Color(0xFF1E293B)),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDone
                          ? Colors.teal
                          : (isActive
                                ? Colors.indigoAccent
                                : Colors.transparent),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${s.n} → ${s.p} × ${s.q}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: isDone
                              ? Colors.tealAccent
                              : (isActive
                                    ? Colors.indigoAccent
                                    : Colors.white54),
                        ),
                      ),
                      if (isDone)
                        const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.tealAccent,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          Text(
            currentStepIdx >= steps.length
                ? 'Mission Success!'
                : 'Click glowing nodes.',
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: resetGame,
              icon: const Icon(Icons.refresh, size: 12),
              label: const Text('Restart', style: TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    List<int> factors = steps.map((s) => s.p).toList();
    if (steps.isNotEmpty) {
      factors.add(steps.last.q);
    } else if (isGameActive) {
      factors.add(targetMass);
    }

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && showCelebration) {
        setState(() {
          showCelebration = false;
        });
      }
    });

    return Container(
      color: Colors.black.withOpacity(0.6),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 100),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t('msg_prime'),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Color(0xFF818CF8),
                shadows: [Shadow(color: Color(0xFF6366F1), blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6366F1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                factors.join(' × '),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Container(
        width: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.zoom_in, color: Colors.white),
              onPressed: () => _zoom(1.2),
              tooltip: 'Zoom In',
            ),
            const Divider(color: Colors.white24, height: 1),
            IconButton(
              icon: const Icon(Icons.zoom_out, color: Colors.white),
              onPressed: () => _zoom(0.8),
              tooltip: 'Zoom Out',
            ),
            const Divider(color: Colors.white24, height: 1),
            IconButton(
              icon: const Icon(Icons.center_focus_strong, color: Colors.white),
              onPressed: () {
                _playClick();
                _centerCanvas();
              },
              tooltip: 'Center View',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeWidget(TreeNode node) {
    bool isTarget =
        isGameActive &&
        currentStepIdx < steps.length &&
        steps[currentStepIdx].n == node.val &&
        !node.processed;

    return AnimatedPositioned(
      key: ValueKey(node.id),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      left: 1000 + node.position.dx - 40,
      top: 1000 + node.position.dy - 40,
      width: 80,
      height: 80,
      child: AnimatedScale(
        scale: isTarget ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: MouseRegion(
          cursor: isTarget
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => handleNodeTap(node),
            onTap: () => handleNodeTap(node),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: node.isPrime
                      ? [const Color(0xFFFCD34D), const Color(0xFFD97706)]
                      : [const Color(0xFF93C5FD), const Color(0xFF2563EB)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (node.isPrime ? Colors.amber : Colors.blue)
                        .withOpacity(node.processed ? 0.0 : 0.6),
                    blurRadius: isTarget ? 30 : 15,
                    spreadRadius: isTarget ? 10 : 0,
                  ),
                  if (!node.isPrime && !node.processed)
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                ],
                border: Border.all(
                  color: node.processed ? Colors.transparent : Colors.white54,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                node.val.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: node.isPrime ? const Color(0xFF451A03) : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Container(
      color: const Color(0xFF020617),
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF818CF8).withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.rocket_launch,
                        size: 80,
                        color: Color(0xFF6366F1),
                      ),
                    ],
                  ),
                  Text(
                    t('app_title'),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      t('tagline'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: startExperience,
                    icon: const Icon(Icons.flight_takeoff),
                    label: Text(
                      t('init_btn'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 10,
                      shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---
class EdgePainter extends CustomPainter {
  final List<TreeEdge> edges;
  EdgePainter({required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.3)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (var edge in edges) {
      Offset start = Offset(1000 + edge.start.dx, 1000 + edge.start.dy);
      Offset end = Offset(1000 + edge.end.dx, 1000 + edge.end.dy);

      canvas.drawLine(start, end, glowPaint);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.5)
      ..strokeWidth = 1.0;

    double step = 40.0;

    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
