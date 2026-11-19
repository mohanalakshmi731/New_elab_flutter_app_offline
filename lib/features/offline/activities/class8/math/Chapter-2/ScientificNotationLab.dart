// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class ScientificNotationLab extends StatefulWidget {
  const ScientificNotationLab({Key? key}) : super(key: key);

  @override
  State<ScientificNotationLab> createState() => _ScientificNotationLabState();
}

class _ScientificNotationLabState extends State<ScientificNotationLab>
    with TickerProviderStateMixin {
  // App State
  String currentLang = 'en';
  int currentStep = 0;
  bool showCurtain = true;
  bool isSidebarOpen = true; // Added for new left sidebar behavior

  // Validation State
  bool isTaskComplete = false;

  // --- Step 0 State: Macroscopic (Sun) ---
  double s0SliderValue = 0; // 0 to 11
  int _lastS0Val = 0;

  // --- Step 1 State: Microscopic (Cell) ---
  double s1SliderValue = 0; // 0 to 6
  int _lastS1Val = 0;

  // --- Step 2 State: Compare Masses ---
  bool s2Compared = false;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _balanceController;

  // Audio Players
  late AudioPlayer _tickPlayer;
  late AudioPlayer _successPlayer;
  late AudioPlayer _whooshPlayer;

  // Decimal Movement Sequences for visual effect
  final List<String> s0Sequence = [
    "149,600,000,000",
    "14,960,000,000.0 × 10<sup>1</sup>",
    "1,496,000,000.00 × 10<sup>2</sup>",
    "149,600,000.000 × 10<sup>3</sup>",
    "14,960,000.0000 × 10<sup>4</sup>",
    "1,496,000.00000 × 10<sup>5</sup>",
    "149,600.000000 × 10<sup>6</sup>",
    "14,960.0000000 × 10<sup>7</sup>",
    "1,496.00000000 × 10<sup>8</sup>",
    "149.600000000 × 10<sup>9</sup>",
    "14.9600000000 × 10<sup>10</sup>",
    "1.496 × 10<sup>11</sup>",
  ];

  final List<String> s1Sequence = [
    "0.000007",
    "0.00007 × 10<sup>-1</sup>",
    "0.0007 × 10<sup>-2</sup>",
    "0.007 × 10<sup>-3</sup>",
    "0.07 × 10<sup>-4</sup>",
    "0.7 × 10<sup>-5</sup>",
    "7.0 × 10<sup>-6</sup>",
  ];

  // Localization Dictionary
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'title': "Scientific Notation",
      'subtitle': "Class 8 Math • POWER PLAY",
      'enterLab': "Enter Virtual Lab",
      'btnValidate': "Derive & Proceed",
      'btnTaskFirst': "Complete Task First",
      'labDone': "Lab Completed! You've mastered Scientific Notation.",
      'steps': [
        {
          'dropdown': "Step 1: Macroscopic (The Sun)",
          'theory':
              "<b>Very Large Numbers</b>\n\nThe distance from the Earth to the Sun is approximately 149,600,000,000 meters.\n\nWriting and reading so many zeros is prone to errors. Scientific notation expresses numbers as a product of a number between 1 and 10, and a power of 10.\n\nTo convert 149,600,000,000:\n1. Place the decimal after the first non-zero digit: <b>1.496</b>\n2. Count how many places the decimal moved left: <b>11 places</b>.\n3. Multiply by 10 to that power: <b>1.496 × 10<sup>11</sup></b>",
          'hud':
              "Drag the slider to move the decimal point 11 places to the left.",
          'btn': "Group Terms",
          'success': "Perfect! The standard form is 1.496 × 10<sup>11</sup> m.",
        },
        {
          'dropdown': "Step 2: Microscopic (A Cell)",
          'theory':
              "<b>Very Small Numbers</b>\n\nNow let's look at the microscopic world. The diameter of a red blood cell is about 0.000007 meters.\n\nFor numbers smaller than 1, we move the decimal to the <b>right</b>, which gives us a <b>negative</b> exponent.\n\nTo convert 0.000007:\n1. Move the decimal right until you have a number between 1 and 10: <b>7.0</b>\n2. Count the places moved: <b>6 places</b>.\n3. Use a negative exponent: <b>7.0 × 10<sup>-6</sup></b>",
          'hud':
              "Drag the slider to move the decimal point 6 places to the right.",
          'btn': "Cancel Matching Blocks",
          'success': "Excellent! The standard form is 7.0 × 10<sup>-6</sup> m.",
        },
        {
          'dropdown': "Step 3: Comparing Vast Masses",
          'theory':
              "<b>Comparing Using Exponents</b>\n\nScientific notation makes comparing extreme numbers easy. Let's compare the mass of the Earth and the Moon.\n\n• Earth's Mass = 5.97 × 10<sup>24</sup> kg\n• Moon's Mass = 7.35 × 10<sup>22</sup> kg\n\nInstead of writing 24 zeros, we divide the numbers and subtract the exponents:\n(5.97 ÷ 7.35) × 10<sup>24 - 22</sup> ≈ 0.81 × 10<sup>2</sup> ≈ 81.\n\n<i>The Earth is about 81 times heavier than the Moon!</i>",
          'hud': "Click 'Compare Masses' to place them on the balance scale.",
          'btn': "Compare Masses",
          'success': "Scale tipped! Earth is 81x more massive.",
        },
      ],
    },
    'hi': {
      'title': "वैज्ञानिक संकेतन",
      'subtitle': "कक्षा 8 गणित • पावर प्ले",
      'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'btnValidate': "व्युत्पन्न करें और आगे बढ़ें",
      'btnTaskFirst': "पहले कार्य पूरा करें",
      'labDone':
          "लैब पूरी हुई! आपने वैज्ञानिक संकेतन में महारत हासिल कर ली है।",
      'steps': [
        {
          'dropdown': "चरण 1: मैक्रोस्कोपिक (सूर्य)",
          'theory':
              "<b>बहुत बड़ी संख्याएँ</b>\n\nपृथ्वी से सूर्य की दूरी लगभग 149,600,000,000 मीटर है।\n\nइतने सारे शून्य लिखने और पढ़ने में त्रुटि होने की संभावना होती है। वैज्ञानिक संकेतन संख्याओं को 1 और 10 के बीच की संख्या और 10 की घात के गुणनफल के रूप में व्यक्त करता है।\n\n149,600,000,000 को बदलने के लिए:\n1. पहले गैर-शून्य अंक के बाद दशमलव रखें: <b>1.496</b>\n2. गिनें कि दशमलव कितनी जगह बाईं ओर गया: <b>11 जगह</b>।\n3. 10 की उस घात से गुणा करें: <b>1.496 × 10<sup>11</sup></b>",
          'hud':
              "दशमलव बिंदु को 11 स्थान बाईं ओर ले जाने के लिए स्लाइडर खींचें।",
          'btn': "समूह (Group Terms)",
          'success': "उत्तम! मानक रूप 1.496 × 10<sup>11</sup> m है।",
        },
        {
          'dropdown': "चरण 2: माइक्रोस्कोपिक (एक कोशिका)",
          'theory':
              "<b>बहुत छोटी संख्याएँ</b>\n\nअब सूक्ष्म दुनिया को देखते हैं। लाल रक्त कोशिका का व्यास लगभग 0.000007 मीटर होता है।\n\n1 से छोटी संख्याओं के लिए, हम दशमलव को <b>दाईं</b> ओर ले जाते हैं, जिससे हमें <b>ऋणात्मक</b> घातांक मिलता है।\n\n0.000007 को बदलने के लिए:\n1. दशमलव को दाईं ओर ले जाएं जब तक कि आपके पास 1 और 10 के बीच की संख्या न हो: <b>7.0</b>\n2. ले जाए गए स्थानों की गिनती करें: <b>6 जगह</b>।\n3. ऋणात्मक घातांक का उपयोग करें: <b>7.0 × 10<sup>-6</sup></b>",
          'hud':
              "दशमलव बिंदु को 6 स्थान दाईं ओर ले जाने के लिए स्लाइडर खींचें।",
          'btn': "समान ब्लॉक रद्द करें",
          'success': "बहुत बढ़िया! मानक रूप 7.0 × 10<sup>-6</sup> m है।",
        },
        {
          'dropdown': "चरण 3: विशाल द्रव्यमान की तुलना",
          'theory':
              "<b>घातांक का उपयोग करके तुलना करना</b>\n\nवैज्ञानिक संकेतन चरम संख्याओं की तुलना करना आसान बनाता है। आइए पृथ्वी और चंद्रमा के द्रव्यमान की तुलना करें।\n\n• पृथ्वी का द्रव्यमान = 5.97 × 10<sup>24</sup> kg\n• चंद्रमा का द्रव्यमान = 7.35 × 10<sup>22</sup> kg\n\n24 शून्य लिखने के बजाय, हम संख्याओं को विभाजित करते हैं और घातांक घटाते हैं:\n(5.97 ÷ 7.35) × 10<sup>24 - 22</sup> ≈ 0.81 × 10<sup>2</sup> ≈ 81.\n\n<i>पृथ्वी चंद्रमा से लगभग 81 गुना भारी है!</i>",
          'hud':
              "उन्हें तराजू पर रखने के लिए 'द्रव्यमान की तुलना करें' पर क्लिक करें।",
          'btn': "द्रव्यमान की तुलना करें",
          'success': "तराजू झुक गया! पृथ्वी 81 गुना अधिक विशाल है।",
        },
      ],
    },
  };

  String t(String key) => i18n[currentLang]![key] as String;
  Map<String, dynamic> tStep(int index) =>
      (i18n[currentLang]!['steps'] as List)[index];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Audio setup
    _tickPlayer = AudioPlayer();
    _successPlayer = AudioPlayer();
    _whooshPlayer = AudioPlayer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _balanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _pulseController.dispose();
    _floatController.dispose();
    _balanceController.dispose();

    _tickPlayer.dispose();
    _successPlayer.dispose();
    _whooshPlayer.dispose();

    super.dispose();
  }

  void _playAudio(AudioPlayer player, String url) async {
    try {
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
  }

  void _playTick() => _playAudio(
    _tickPlayer,
    'audio/class8/mixkit_2568.mp3',
  );

  void _playSuccess() => _playAudio(
    _successPlayer,
    'audio/class8/mixkit_2013.mp3',
  );

  void _playWhoosh() => _playAudio(
    _whooshPlayer,
    'audio/class8/mixkit_2988.mp3',
  );

  void _resetActivity() {
    _playWhoosh();
    setState(() {
      showCurtain = true;
      isSidebarOpen = true;
      currentStep = 0;
      isTaskComplete = false;
      s0SliderValue = 0;
      _lastS0Val = 0;
      s1SliderValue = 0;
      _lastS1Val = 0;
      s2Compared = false;
      _balanceController.reset();
    });
  }

  void _loadScenario(int index) {
    if (index != currentStep) {
      _playWhoosh();
    }
    setState(() {
      currentStep = index;
      isTaskComplete = false;

      // Reset State Variables
      s0SliderValue = 0;
      _lastS0Val = 0;
      s1SliderValue = 0;
      _lastS1Val = 0;
      s2Compared = false;

      _balanceController.reset();
    });
  }

  void _checkValidation() {
    bool passed = false;
    switch (currentStep) {
      case 0:
        passed = s0SliderValue == 11;
        break;
      case 1:
        passed = s1SliderValue == 6;
        break;
      case 2:
        passed = s2Compared;
        break;
    }

    if (passed && !isTaskComplete) {
      setState(() {
        isTaskComplete = true;
      });
      _playSuccess();
    }
  }

  // --- Task Actions ---
  void _triggerS0Slider(double val) {
    setState(() {
      s0SliderValue = val;
    });
    if (val.toInt() != _lastS0Val) {
      _playTick();
      _lastS0Val = val.toInt();
    }
    _checkValidation();
  }

  void _triggerS1Slider(double val) {
    setState(() {
      s1SliderValue = val;
    });
    if (val.toInt() != _lastS1Val) {
      _playTick();
      _lastS1Val = val.toInt();
    }
    _checkValidation();
  }

  void _triggerCompare() {
    _playTick();
    setState(() {
      s2Compared = true;
    });
    _balanceController.forward();
    _checkValidation();
  }

  void _nextStep() {
    if (currentStep < 2) {
      _loadScenario(currentStep + 1);
    } else {
      _playSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('labDone'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          backgroundColor: Colors.blueGrey.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadScenario(0);
    }
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    // Left Sidebar takes 30% width
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.35;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Background & Grid Paint
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [Color(0xFF0f172a), Color(0xFF020617)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: GridPainter()),
              ),
            ),

            // Zoomable / Panning Canvas
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              // Canvas dynamically resizes avoiding the sidebar or going under it
              left: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(1200),
                    minScale: 0.2,
                    maxScale: 4.0,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _pulseController,
                          _floatController,
                          _balanceController,
                        ]),
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size.infinite,
                            painter: NotationVisualPainter(
                              step: currentStep,
                              s0Value: s0SliderValue.toInt(),
                              s1Value: s1SliderValue.toInt(),
                              s2Compared: s2Compared,
                              pulseAnim: _pulseController.value,
                              floatAnim: _floatController.value,
                              balanceAnim: _balanceController.value,
                              // Shift the center of drawing dynamically based on sidebar
                              sidebarOffset: isSidebarOpen
                                  ? sidebarWidth / 2
                                  : 0,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Success Popup overlay - Scrollable
            if (isTaskComplete)
              Positioned(
                bottom: 40,
                left:
                    sidebarWidth +
                    20, // Fixed position relative to sidebar width so it doesn't jump
                right: 20,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade900.withOpacity(0.85),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: _parseRichMathText(
                        tStep(currentStep)['success'],
                        color: Colors.greenAccent,
                        fontSize: 16,
                        center: true,
                        baseFontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Left Sidebar Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Material(
                color: const Color(0xFF0f172a).withOpacity(0.95),
                elevation: 16,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSidebarHeader(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildStepDropdown(),
                            const SizedBox(height: 16),
                            _buildTheory(),
                            const SizedBox(height: 24),
                            _buildTargetOutputAndControls(),
                            const SizedBox(height: 24),
                            _buildValidateButton(),
                            const SizedBox(height: 40),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Text(
                                "© ZeroScienceLab - Fall in love with math and Science",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Mission Card (Visible when sidebar is closed)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? -350 : 16,
              top: 80,
              width: 280,
              child: IgnorePointer(
                ignoring: isSidebarOpen,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSidebarOpen ? 0.0 : 1.0,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height - 80,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f172a).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blueGrey.shade700),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade900,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.flag,
                                  color: Colors.cyanAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tStep(currentStep)['dropdown'],
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildTargetOutputAndControls(),
                                  const SizedBox(height: 16),
                                  _buildValidateButton(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Hamburger Menu Icon (Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.cyanAccent,
                  ),
                  onPressed: () =>
                      setState(() => isSidebarOpen = !isSidebarOpen),
                ),
              ),
            ),

            if (showCurtain) _buildCurtainRaiser(),
          ],
        ),
      ),
    );
  }

  // --- Sidebar Components ---

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 70, 16, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.blueGrey.shade800)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.science, color: Colors.cyanAccent, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('subtitle'),
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Controls Row: Language Switcher and Reset
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey.shade700),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: ['en', 'hi'].map((lang) {
                      bool isActive = currentLang == lang;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => currentLang = lang),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.cyan.shade700
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lang.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.black : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 35, height: 35),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.5),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: _resetActivity,
                    tooltip: "Reset Activity",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade700),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          dropdownColor: const Color(0xFF1e293b),
          isExpanded: true,
          value: currentStep,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          items: List.generate(3, (index) {
            return DropdownMenuItem(
              value: index,
              child: Text(tStep(index)['dropdown']),
            );
          }),
          onChanged: (v) {
            if (v != null) _loadScenario(v);
          },
        ),
      ),
    );
  }

  Widget _buildTheory() {
    Map<String, dynamic> stepData = tStep(currentStep);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade800),
      ),
      child: _parseRichMathText(stepData['theory'], fontSize: 13),
    );
  }

  Widget _buildTargetOutputAndControls() {
    Map<String, dynamic> stepData = tStep(currentStep);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _parseRichMathText(
            stepData['hud'],
            color: Colors.cyanAccent,
            fontSize: 13,
            center: true,
          ),
          const SizedBox(height: 16),

          // --- Step 0 Controls ---
          if (currentStep == 0) ...[
            const Text(
              "Decimal Shift (Left):",
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.amberAccent,
                inactiveTrackColor: Colors.blueGrey.shade700,
                thumbColor: Colors.amber,
                overlayColor: Colors.amber.withOpacity(0.2),
              ),
              child: Slider(
                value: s0SliderValue,
                min: 0,
                max: 11,
                divisions: 11,
                onChanged: _triggerS0Slider,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
              ),
              child: _parseRichMathText(
                s0Sequence[s0SliderValue.toInt()],
                color: Colors.amberAccent,
                fontSize: 18,
                center: true,
              ),
            ),
          ],

          // --- Step 1 Controls ---
          if (currentStep == 1) ...[
            const Text(
              "Decimal Shift (Right):",
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.redAccent,
                inactiveTrackColor: Colors.blueGrey.shade700,
                thumbColor: Colors.red,
                overlayColor: Colors.red.withOpacity(0.2),
              ),
              child: Slider(
                value: s1SliderValue,
                min: 0,
                max: 6,
                divisions: 6,
                onChanged: _triggerS1Slider,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: _parseRichMathText(
                s1Sequence[s1SliderValue.toInt()],
                color: Colors.redAccent,
                fontSize: 18,
                center: true,
              ),
            ),
          ],

          // --- Step 2 Controls ---
          if (currentStep == 2) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.balance),
              label: Text(stepData['btn']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: s2Compared ? null : _triggerCompare,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValidateButton() {
    return ElevatedButton.icon(
      icon: Icon(isTaskComplete ? Icons.arrow_forward : Icons.lock_outline),
      label: Text(
        isTaskComplete ? t('btnValidate') : t('btnTaskFirst'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isTaskComplete
            ? Colors.cyan.shade500
            : Colors.blueGrey.shade800,
        foregroundColor: isTaskComplete ? Colors.black : Colors.white54,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isTaskComplete ? 8 : 0,
      ),
      onPressed: isTaskComplete ? _nextStep : null,
    );
  }

  Widget _buildCurtainRaiser() {
    return AnimatedOpacity(
      opacity: showCurtain ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      onEnd: () {
        if (!showCurtain) setState(() {});
      },
      child: Container(
        color: const Color(0xFF020617),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, color: Colors.cyanAccent, size: 80),
              const SizedBox(height: 20),
              Text(
                t('subtitle').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t('title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: Text(
                  t('enterLab'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _playTick();
                  setState(() => showCurtain = false);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.cyan.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to parse pseudo-HTML and pseudo-Math into RichText
  Widget _parseRichMathText(
    String text, {
    Color color = Colors.white70,
    double fontSize = 14,
    bool center = false,
    FontWeight baseFontWeight = FontWeight.normal,
  }) {
    List<InlineSpan> spans = [];

    final RegExp tagExp = RegExp(r'(<b>|</b>|<i>|</i>|<sup>|</sup>)');
    Iterable<Match> matches = tagExp.allMatches(text);

    int lastMatchEnd = 0;
    bool isBold = false;
    bool isItalic = false;
    bool isSup = false;

    void addSpan(String content) {
      if (content.isEmpty) return;

      TextStyle style = TextStyle(
        color: color,
        fontSize: fontSize,
        height: 1.6,
        fontWeight: isBold ? FontWeight.bold : baseFontWeight,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      );

      if (isSup) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Transform.translate(
              offset: Offset(0, -fontSize * 0.4), // shift up
              child: Text(
                content,
                style: style.copyWith(fontSize: fontSize * 0.7),
              ),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: content, style: style));
      }
    }

    for (Match match in matches) {
      addSpan(text.substring(lastMatchEnd, match.start));
      String tag = match.group(0)!;
      if (tag == '<b>') {
        isBold = true;
      } else if (tag == '</b>') {
        isBold = false;
      } else if (tag == '<i>') {
        isItalic = true;
      } else if (tag == '</i>') {
        isItalic = false;
      } else if (tag == '<sup>') {
        isSup = true;
      } else if (tag == '</sup>') {
        isSup = false;
      }
      lastMatchEnd = match.end;
    }
    addSpan(text.substring(lastMatchEnd));

    return RichText(
      textAlign: center ? TextAlign.center : TextAlign.left,
      text: TextSpan(children: spans),
    );
  }
}

// --- Visual Engine Custom Painter ---
class NotationVisualPainter extends CustomPainter {
  final int step;
  final int s0Value;
  final int s1Value;
  final bool s2Compared;
  final double pulseAnim;
  final double floatAnim;
  final double balanceAnim;
  final double sidebarOffset;

  NotationVisualPainter({
    required this.step,
    required this.s0Value,
    required this.s1Value,
    required this.s2Compared,
    required this.pulseAnim,
    required this.floatAnim,
    required this.balanceAnim,
    required this.sidebarOffset,
  });

  void _drawOrb(
    Canvas canvas,
    Offset pos,
    double radius,
    Color color, {
    bool glow = true,
    double glowIntensity = 1.0,
  }) {
    if (glow) {
      final Paint glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.6 * glowIntensity), Colors.transparent],
        ).createShader(Rect.fromCircle(center: pos, radius: radius * 1.5));
      canvas.drawCircle(pos, radius * 1.5, glowPaint);
    }

    final Paint orbPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [color.withOpacity(0.5), color, color.withOpacity(0.8)],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));
    canvas.drawCircle(pos, radius, orbPaint);
  }

  void _drawRBC(Canvas canvas, Offset pos, double radius, double squeeze) {
    // Red Blood Cell - Biconcave disc simulated via double gradients
    final Paint outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.redAccent, Colors.red.shade900],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));
    canvas.drawCircle(pos, radius, outerPaint);

    final Paint innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.red.shade900.withOpacity(0.8), Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: radius * 0.6));
    canvas.drawCircle(pos, radius * 0.6, innerPaint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    double size = 16,
    Color color = Colors.white,
    bool bg = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    if (bg) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: pos,
            width: tp.width + 24,
            height: tp.height + 12,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.black87,
      );
    }
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Adapt drawing center based on size and sidebar
    Offset center = Offset((size.width / 2) + sidebarOffset, size.height * 0.5);

    if (step == 0) {
      // Sun to Earth
      Offset sunPos = center + const Offset(-250, 0);
      Offset earthPos = center + const Offset(250, 0);

      _drawOrb(
        canvas,
        sunPos,
        100 + (pulseAnim * 5),
        Colors.amberAccent,
        glowIntensity: 1.0 + (pulseAnim * 0.5),
      );
      _drawText(canvas, "SUN", sunPos + const Offset(0, 130));

      _drawOrb(canvas, earthPos, 25, Colors.blue);
      _drawText(canvas, "EARTH", earthPos + const Offset(0, 50));

      // Distance Line
      Paint linePaint = Paint()
        ..color = Colors.white54
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Draw dashed line
      double dashWidth = 10, dashSpace = 10, startX = sunPos.dx + 120;
      while (startX < earthPos.dx - 40) {
        canvas.drawLine(
          Offset(startX, sunPos.dy),
          Offset(startX + dashWidth, sunPos.dy),
          linePaint,
        );
        startX += dashWidth + dashSpace;
      }

      if (s0Value == 11) {
        _drawText(
          canvas,
          "1.496 × 10¹¹ m",
          center + const Offset(0, -40),
          size: 28,
          color: Colors.amberAccent,
          bg: true,
        );
      } else {
        _drawText(
          canvas,
          "Distance: 149,600,000,000 m",
          center + const Offset(0, -40),
          size: 18,
          color: Colors.white,
          bg: true,
        );
      }
    } else if (step == 1) {
      // Red Blood Cell
      double floatOffset = math.sin(floatAnim * math.pi * 2) * 20;
      Offset cellPos = center + Offset(0, floatOffset);

      _drawRBC(canvas, cellPos, 120, 1.0);

      // Microscopic Grid / Reticle
      Paint reticlePaint = Paint()
        ..color = Colors.white24
        ..strokeWidth = 2;
      canvas.drawCircle(
        cellPos,
        150,
        reticlePaint..style = PaintingStyle.stroke,
      );
      canvas.drawLine(
        cellPos + const Offset(-180, 0),
        cellPos + const Offset(180, 0),
        reticlePaint,
      );
      canvas.drawLine(
        cellPos + const Offset(0, -180),
        cellPos + const Offset(0, 180),
        reticlePaint,
      );

      // Dimension lines
      canvas.drawLine(
        cellPos + const Offset(-120, 170),
        cellPos + const Offset(120, 170),
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        cellPos + const Offset(-120, 160),
        cellPos + const Offset(-120, 180),
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        cellPos + const Offset(120, 160),
        cellPos + const Offset(120, 180),
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 2,
      );

      if (s1Value == 6) {
        _drawText(
          canvas,
          "7.0 × 10⁻⁶ m",
          cellPos + const Offset(0, 210),
          size: 28,
          color: Colors.redAccent,
          bg: true,
        );
      } else {
        _drawText(
          canvas,
          "Diameter: 0.000007 m",
          cellPos + const Offset(0, 210),
          size: 18,
          color: Colors.white,
          bg: true,
        );
      }
    } else if (step == 2) {
      // Balance Scale
      Offset pivot = center + const Offset(0, 80);

      // Calculate rotation based on animation
      // Target rotation is heavily tilted to Earth (left)
      double maxAngle = -math.pi / 8;
      double angle = balanceAnim * maxAngle;

      canvas.save();
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(angle);

      // Scale Arm
      double armLen = 250;
      Paint armPaint = Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(-armLen, 0), Offset(armLen, 0), armPaint);

      // Left Pan (Earth)
      canvas.drawLine(
        Offset(-armLen, 0),
        Offset(-armLen, 60),
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(-armLen - 50, 60),
        Offset(-armLen + 50, 60),
        armPaint,
      );
      _drawOrb(canvas, Offset(-armLen, 10), 50, Colors.blue);
      _drawText(canvas, "Earth", Offset(-armLen, 85), size: 16);

      // Right Pan (Moon)
      canvas.drawLine(
        Offset(armLen, 0),
        Offset(armLen, 60),
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(armLen - 50, 60),
        Offset(armLen + 50, 60),
        armPaint,
      );
      _drawOrb(canvas, Offset(armLen, 35), 20, Colors.grey.shade400); // smaller
      _drawText(canvas, "Moon", Offset(armLen, 85), size: 16);

      canvas.restore();

      // Scale Base
      Path base = Path()
        ..moveTo(pivot.dx, pivot.dy)
        ..lineTo(pivot.dx - 40, pivot.dy + 180)
        ..lineTo(pivot.dx + 40, pivot.dy + 180)
        ..close();
      canvas.drawPath(base, Paint()..color = Colors.blueGrey.shade700);
      canvas.drawCircle(pivot, 12, Paint()..color = Colors.amber);

      // Text
      if (balanceAnim == 1.0) {
        _drawText(
          canvas,
          "Earth ≈ 81 × Moon",
          center + const Offset(0, -150),
          size: 32,
          color: Colors.amberAccent,
          bg: true,
        );
        _drawText(
          canvas,
          "(5.97 × 10²⁴) ÷ (7.35 × 10²²)",
          center + const Offset(0, -100),
          size: 20,
          color: Colors.white70,
          bg: true,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant NotationVisualPainter oldDelegate) {
    return true;
  }
}

// Background Grid Painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blueGrey.shade800
      ..strokeWidth = 1.0;

    double step = 60;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
