// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DecimalSorterApp(),
    ),
  );
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
    'app_title': 'THE DECIMAL SORTER',
    'tagline': 'CLASSIFYING RATIONAL NUMBERS',
    'init_btn': 'ENTER FACTORY',
    'header_title': 'The Decimal Sorter',
    'header_subtitle': 'CLASS 10 • REAL NUMBERS - Decimal Sorter.',
    'nav_lab': 'Explore',
    'btn_start_lab': 'Enter Factory',
    'setup_title': 'Input Rational Number',
    'btn_analyze': 'Analyze Denominator (q)',
    'btn_reset': 'Process New Number',
    'hud_status': 'Current q',
    'btn_term': 'Terminating',
    'btn_repeating': 'Repeating',
    'msg_decision': 'Does \'q\' contain factors other than 2 or 5?',
    'msg_correct': 'CORRECT!',
    'msg_try_again': 'TRY AGAIN',
    'tooltip_restart': 'Restart Application',
    'label_logic': 'LOGIC',
    'msg_simplified': 'Simplified: {p} / {q}',
    'msg_factors': 'Factors of {q}:',
    'msg_term_logic':
        'Only contains 2s or 5s (Form 2ⁿ 5ᵐ). Decimal will terminate.',
    'msg_rep_logic':
        'Contains factors other than 2 or 5. Decimal is non-terminating repeating.',
    'mission_title': 'MISSION CONTROL',
    'hint_setup':
        'ACTION: Enter a numerator and denominator, then click Analyze.',
    'hint_analyze': 'ACTION: Analyzing the prime factors of the denominator...',
    'hint_decide':
        'ACTION: Select Terminating if factors are only 2s or 5s. Otherwise, select Repeating.',
    'hint_done': 'ACTION: Sorted correctly! Process a new number.',
  },
  'hi': {
    'app_title': 'दशमलव सॉर्टर',
    'tagline': 'परिमेय संख्याओं का वर्गीकरण',
    'init_btn': 'फैक्ट्री में प्रवेश',
    'header_title': 'दशमलव सॉर्टर',
    'header_subtitle': 'कक्षा 10 • वास्तविक संख्याएँ – दशमलव क्रमबद्धीकरण',
    'nav_lab': 'अन्वेषण',
    'btn_start_lab': 'फैक्ट्री खोलें',
    'setup_title': 'परिमेय संख्या दर्ज करें',
    'btn_analyze': 'हर (q) का विश्लेषण करें',
    'btn_reset': 'नई संख्या',
    'hud_status': 'वर्तमान q',
    'btn_term': 'सांत',
    'btn_repeating': 'असांत आवर्ती',
    'msg_decision': 'जांचें: क्या गुणनखंड केवल 2 या 5 हैं?',
    'msg_correct': 'सही!',
    'msg_try_again': 'पुनः प्रयास करें',
    'tooltip_restart': 'एप्लिकेशन पुनः आरंभ करें',
    'label_logic': 'तर्क (LOGIC)',
    'msg_simplified': 'सरलीकृत: {p} / {q}',
    'msg_factors': '{q} के गुणनखंड:',
    'msg_term_logic': 'केवल 2 या 5 (रूप 2ⁿ 5ᵐ) शामिल हैं। दशमलव सांत होगा।',
    'msg_rep_logic':
        '2 या 5 के अलावा अन्य गुणनखंड शामिल हैं। दशमलव असांत आवर्ती है।',
    'mission_title': 'मिशन कंट्रोल',
    'hint_setup': 'कार्य: अंश और हर दर्ज करें, फिर विश्लेषण पर क्लिक करें।',
    'hint_analyze': 'कार्य: हर के अभाज्य गुणनखंडों का विश्लेषण हो रहा है...',
    'hint_decide':
        'कार्य: यदि गुणनखंड केवल 2 या 5 हैं तो सांत चुनें। अन्यथा, असांत आवर्ती चुनें।',
    'hint_done':
        'कार्य: सही ढंग से सॉर्ट किया गया! नई संख्या का विश्लेषण करें।',
  },
};

class DecimalSorterApp extends StatefulWidget {
  const DecimalSorterApp({super.key});

  @override
  State<DecimalSorterApp> createState() => _DecimalSorterAppState();
}

class _DecimalSorterAppState extends State<DecimalSorterApp> {
  // UI State
  bool isCurtainOpen = false;
  String currentLang = 'en';
  bool isSidebarOpen = false;

  // Math State
  TextEditingController pController = TextEditingController(text: '13');
  TextEditingController qController = TextEditingController(text: '8');
  int simplifiedP = 0;
  int simplifiedQ = 0;
  List<int> factors = [];
  bool isTerminating = false;

  // Animation/Process State
  int processStep = 0; // 0: Input, 1: Analyzing, 2: Scanned, 3: Sorted
  double boxPositionX = 0;
  double boxPositionY = -1.5; // Hidden above canvas (-1.5 is visually above)
  bool showCelebration = false;
  bool isCorrect = false;

  // Controllers
  final ScrollController _hudScrollController = ScrollController();
  final ScrollController _sidebarScrollController = ScrollController();
  final TransformationController _transformController =
      TransformationController();

  String t(String key) {
    return i18n[currentLang]?[key] ?? key;
  }

  setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void initState() {
    super.initState();
    setLandscape();
    // Center the canvas on initial startup
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerCanvas());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _hudScrollController.dispose();
    _sidebarScrollController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  // Camera Management
  void _centerCanvas() {
    if (!mounted) return;
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    double panelWidth = screenW * 0.3 < 300 ? 300 : screenW * 0.3;

    double safeWidth = isSidebarOpen ? (screenW - panelWidth) : screenW;
    double safeLeft = isSidebarOpen ? panelWidth : 0;

    double targetX = safeLeft + (safeWidth / 2);
    double targetY = screenH / 2;

    // The virtual canvas center is 1000, 1000
    // Translate the canvas so its center aligns dynamically with the target "safe" center
    _transformController.value = Matrix4.identity()
      ..translate(targetX - 1000.0, targetY - 1000.0);
  }

  // Math Logic
  List<int> getPrimeFactors(int n) {
    List<int> f = [];
    int d = 2;
    while (d * d <= n) {
      while (n % d == 0) {
        f.add(d);
        n ~/= d;
      }
      d++;
    }
    if (n > 1) f.add(n);
    return f;
  }

  int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  void analyzeNumber() {
    _playClick();
    int rawP = int.tryParse(pController.text) ?? 0;
    int rawQ = int.tryParse(qController.text) ?? 0;
    if (rawQ == 0) return;

    int common = gcd(rawP.abs(), rawQ.abs());
    simplifiedP = rawP ~/ common;
    simplifiedQ = rawQ ~/ common;

    // Ensure positive denominator
    if (simplifiedQ < 0) {
      simplifiedP = -simplifiedP;
      simplifiedQ = -simplifiedQ;
    }

    factors = getPrimeFactors(simplifiedQ);
    isTerminating = factors.every((f) => f == 2 || f == 5);

    setState(() {
      processStep = 1;
      // Move box to center scanner
      boxPositionX = 0;
      boxPositionY = -0.5; // Scanner height
    });

    // Simulate scanning time
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          processStep = 2;
        });
      }
    });
  }

  void decide(bool userChoiceTerminating) {
    isCorrect = (userChoiceTerminating == isTerminating);

    if (isCorrect) {
      _playSuccess();
    } else {
      _playError();
    }

    setState(() {
      showCelebration = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showCelebration = false;
          if (isCorrect) {
            processStep = 3;
            // Move to bin
            boxPositionX = userChoiceTerminating ? -1.0 : 1.0;
            boxPositionY = 0.5; // Drop into bin
          } else {
            // Shake or reset box
            boxPositionY = -0.6;
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => boxPositionY = -0.5);
            });
          }
        });
      }
    });
  }

  void resetActivity() {
    _playClick();
    setState(() {
      processStep = 0;
      boxPositionX = 0;
      boxPositionY = -1.5; // Hidden above
      factors.clear();
      _centerCanvas(); // Re-center dynamically cleanly
    });
  }

  Widget _floatingButton(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.cyan,
  }) {
    return Material(
      color: color.withOpacity(0.9),
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black54,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildStepDescription() {
    String text = '';
    if (processStep == 0)
      text = t('hint_setup');
    else if (processStep == 1)
      text = t('hint_analyze');
    else if (processStep == 2)
      text = t('hint_decide');
    else if (processStep == 3)
      text = t('hint_done');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.cyanAccent,
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

  // Extract core interactive elements into a reusable list of widgets
  List<Widget> _buildActivityContent() {
    return [
      _buildStepDescription(),
      if (processStep == 0) ...[
        Text(
          t('setup_title'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              child: TextField(
                controller: pController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.blueGrey.shade800,
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "/",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: qController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.blueGrey.shade800,
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: analyzeNumber,
            child: Text(
              t('btn_analyze'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
      if (processStep >= 1) ...[
        // Logic Steps
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800,
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('label_logic'),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t('msg_simplified')
                    .replaceAll('{p}', '$simplifiedP')
                    .replaceAll('{q}', '$simplifiedQ'),
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
              if (processStep >= 2) ...[
                const Divider(color: Colors.cyanAccent),
                Text(
                  t('msg_factors').replaceAll('{q}', '$simplifiedQ'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  children: factors.map((f) {
                    bool isGood = f == 2 || f == 5;
                    return Text(
                      "$f",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isGood ? Colors.greenAccent : Colors.redAccent,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text(
                  isTerminating ? t('msg_term_logic') : t('msg_rep_logic'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (processStep == 2) ...[
          Text(
            t('msg_decision'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => decide(true),
                  child: Text(
                    t('btn_term'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => decide(false),
                  child: Text(
                    t('btn_repeating'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (processStep == 3) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.cyanAccent,
                side: const BorderSide(color: Colors.cyanAccent),
              ),
              onPressed: resetActivity,
              child: Text(
                t('btn_reset'),
                style: const TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ),
        ],
      ],
    ];
  }

  // Build the floating Mission Card
  Widget _buildMissionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.5),
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
                  color: Colors.cyanAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t('mission_title').toUpperCase(),
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
          // Flexible ensures it only scrolls if it overflows the constrained bounds
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
          top: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
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

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    // Set panel width to 30% of screen, ensure it's not too small on tiny devices
    double panelWidth = w * 0.3 < 300 ? 300 : w * 0.3;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // 1. Base Layer: Interactive Visualizer Canvas
            _buildVisualizer(),

            // 2. Sidebar Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: _buildSidePanel(panelWidth),
            ),

            // 3. Floating Mission Card (Safely Bounded & Non-overlapping)
            if (isCurtainOpen)
              Positioned(
                top: 80, // Positioned safely below the toggle button
                left: 20,
                child: AnimatedOpacity(
                  opacity: !isSidebarOpen ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: isSidebarOpen,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            panelWidth - 40, // Match visual width of Sidebar
                        maxHeight:
                            h - 104, // Bounded safely away from top & bottom
                      ),
                      child: _buildMissionCard(),
                    ),
                  ),
                ),
              ),

            // 4. Floating Menu Button (Top Left)
            if (isCurtainOpen)
              Positioned(
                top: 16,
                left: 16,
                child: _floatingButton(
                  isSidebarOpen ? Icons.close : Icons.menu,
                  () {
                    _playClick();
                    setState(() => isSidebarOpen = !isSidebarOpen);
                    _centerCanvas(); // Trigger canvas reframing dynamically
                  },
                  color: Colors.cyan,
                ),
              ),

            // 5. Curtain (Intro Screen)
            if (!isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.factory,
                        size: 80,
                        color: Colors.cyanAccent,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t('app_title'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        t('tagline'),
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          _playShutter();
                          setState(() {
                            isCurtainOpen = true;
                            isSidebarOpen = true; // Auto-open panel
                          });
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: Text(
                          t('init_btn'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 6. Celebration Overlay (Z-Index fix: Added strictly to the absolute bottom of the Stack rendering!)
            if (showCelebration)
              Positioned.fill(
                child: Container(
                  color: Colors.black87.withOpacity(0.85),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCorrect ? t('msg_correct') : t('msg_try_again'),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: isCorrect
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(double width) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: const Border(
          right: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxWidth: width,
          minWidth: width,
          // IntrinsicHeight + Spacer handles pinning the footer dynamically
          // while ensuring EVERYTHING is scrollable
          child: SingleChildScrollView(
            controller: _sidebarScrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 80,
                        left: 20,
                        right: 20,
                        bottom: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Activity Title & Subtitle
                          Text(
                            t('header_title'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('header_subtitle'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.cyanAccent,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Language Translation and Restart Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Language Toggles
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade900,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: ['en', 'hi'].map((lang) {
                                    bool isSelected = currentLang == lang;
                                    return GestureDetector(
                                      onTap: () {
                                        _playClick();
                                        setState(() => currentLang = lang);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.cyan
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          lang.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.cyanAccent,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              // Restart Application (Go to Curtain)
                              IconButton(
                                icon: const Icon(
                                  Icons.power_settings_new,
                                  color: Colors.redAccent,
                                ),
                                tooltip: t('tooltip_restart'),
                                onPressed: () {
                                  _playClick();
                                  setState(() {
                                    isCurtainOpen = false;
                                    isSidebarOpen = false;
                                    processStep = 0;
                                    boxPositionX = 0;
                                    boxPositionY = -1.5;
                                    factors.clear();
                                    showCelebration = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 20),

                          // Core Explore Lab Activity Content spread operator
                          ..._buildActivityContent(),
                        ],
                      ),
                    ),
                    const Spacer(), // Pushes the footer to the bottom if content is short
                    _buildSidebarFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    double w = 2000;
    double h = 2000;

    double centerX = w / 2;
    double centerY = h / 2;

    // Fixed visual layout coordinates
    double getX(double logicalX) => centerX + (logicalX * 250) - 40;
    double getY(double logicalY) => centerY + (logicalY * 150) - 40;

    return Container(
      color: const Color(0xFF0F172A), // Slate 900
      width: double.infinity,
      height: double.infinity,
      child: InteractiveViewer(
        transformationController: _transformController,
        constrained:
            false, // Core attribute giving drag/pan capabilities without squishing layout
        boundaryMargin: const EdgeInsets.all(2000),
        minScale: 0.1,
        maxScale: 3.0,
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Conveyor Belt
              Positioned(
                left: getX(-1.2) + 40,
                width: getX(1.2) - getX(-1.2),
                top: getY(0.5) + 60,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Terminating Bin (Left)
              Positioned(
                left: getX(-1.0) - 10,
                top: getY(0.5),
                child: Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t('btn_term'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // Repeating Bin (Right)
              Positioned(
                left: getX(1.0) - 10,
                top: getY(0.5),
                child: Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    border: Border.all(color: Colors.orangeAccent, width: 2),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t('btn_repeating'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // Scanner Arch (Center)
              Positioned(
                left: getX(0.0) - 20,
                top: getY(-0.5) - 20,
                child: Container(
                  width: 120,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      width: 4,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.topCenter,
                  child: AnimatedOpacity(
                    opacity: processStep == 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 80,
                      height: 10,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ),
              ),

              // The Moving Fraction Box
              if (processStep > 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutBack,
                  left: getX(boxPositionX),
                  top: getY(boxPositionY),
                  child: Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$simplifiedP",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 4),
                                ],
                              ),
                            ),
                            Container(
                              height: 2,
                              width: 40,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              color: Colors.cyanAccent,
                            ),
                            Text(
                              "$simplifiedQ",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Factor Spheres (Floating above box when scanned)
              if (processStep >= 2 && processStep < 3)
                Positioned(
                  top: getY(boxPositionY) - 60,
                  left:
                      getX(boxPositionX) -
                      60, // Centered perfectly over the 80px box
                  width: 200,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: factors.map((f) {
                      bool isGood = f == 2 || f == 5;
                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, double val, child) {
                          return Transform.scale(
                            scale: val,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isGood ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isGood ? Colors.green : Colors.red)
                                        .withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$f",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
