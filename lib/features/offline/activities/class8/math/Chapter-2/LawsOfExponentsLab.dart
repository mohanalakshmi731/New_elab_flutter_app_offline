// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class LawsOfExponentsLab extends StatefulWidget {
  const LawsOfExponentsLab({Key? key}) : super(key: key);

  @override
  State<LawsOfExponentsLab> createState() => _LawsOfExponentsLabState();
}

class _LawsOfExponentsLabState extends State<LawsOfExponentsLab>
    with TickerProviderStateMixin {
  // App State
  String currentLang = 'en';
  int currentStep = 0;
  bool showCurtain = true;
  bool isSidebarOpen = true; // Sidebar starts open

  // Validation State
  bool isTaskComplete = false;

  // --- Step 0 State: Stones that Shine ---
  bool s0Part1Done = false;
  bool s0Part2Done = false;

  // --- Step 1 State: Multiplication Law ---
  double s1MergeValue = 0;
  bool s1Merged = false;

  // --- Step 2 State: Magical Pond ---
  int s2PondDay = 30;

  // --- Step 3 State: Power of Power ---
  bool s3Expanded = false;

  // --- Step 4 State: Passwords ---
  bool s4Calc1Done = false;
  bool s4Calc2Done = false;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _actionAnimController;
  late AnimationController _spinController;

  // Audio Player Helper (Network URLs for guaranteed playback)
  void _playSound(String type) async {
    final AudioPlayer player = AudioPlayer();
    try {
      if (type == 'tap') {
        // Child-friendly pop sound
        await player.play(
          AssetSource(
            'audio/class8/mixkit_2568.mp3',
          ),
        );
      } else if (type == 'success') {
        // Child-friendly success bell/chime
        await player.play(
          AssetSource(
            'audio/class8/mixkit_2013.mp3',
          ),
        );
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  // Localization Dictionary
  final Map<String, Map<String, dynamic>> i18n = {
    'en': {
      'title': "Laws of Exponents",
      'subtitle': "Class 8 Math • POWER PLAY",
      'enterLab': "Enter Virtual Lab",
      'common': {'day': "Day", 'calc': "Calc", 'merge': "Merge Bases:"},
      'btnValidate': "Derive & Proceed",
      'btnTaskFirst': "Complete Canvas Task First",
      'mission': "Current Mission",
      'steps': [
        {
          'dropdown': "Step 1: The Stones that Shine",
          'hud':
              "Click 'Group Part 1 (3<sup>4</sup>)' and 'Group Part 2 (3<sup>3</sup>)' to visualize the components.",
          'btn1': "Group Part 1 (3<sup>4</sup>)",
          'btn2': "Group Part 2 (3<sup>3</sup>)",
          'success': "Groups identified! Click 'Derive & Proceed'.",
        },
        {
          'dropdown': "Step 2: The Multiplication Law",
          'hud': "Slide to merge the bases and add the exponents.",
          'success': "Exponents added! Let's apply this backwards.",
        },
        {
          'dropdown': "Step 3: The Magical Pond",
          'hud':
              "Use the rewind control to go back from Day 30 and find when it is 50% full.",
          'success': "Correct! Day 29 is half-full. Proceed to Math Talk.",
        },
        {
          'dropdown': "Step 4: Math Talk (Power of Power)",
          'hud':
              "Click 'Expand 8<sup>6</sup>' to break down the base 8 into 2<sup>3</sup>.",
          'btn': "Convert Base 8 to 2<sup>3</sup>",
          'success':
              "Expanded! We now have 6 groups of 3, which is 2<sup>18</sup>.",
        },
        {
          'dropdown': "Step 5: Password Combinations",
          'hud': "Calculate to see which lock is safer.",
          'lbl1': "5 Digits (0-9)",
          'lbl2': "5 Letters (A-Z)",
          'success': "Calculated! A-Z lock provides exponential security.",
        },
      ],
    },
    'hi': {
      'title': "घातांक के नियम",
      'subtitle': "कक्षा 8 गणित • पावर प्ले",
      'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'common': {'day': "दिन", 'calc': "गणना", 'merge': "आधार मिलाएं:"},
      'btnValidate': "व्युत्पन्न करें और आगे बढ़ें",
      'btnTaskFirst': "पहले कैनवास कार्य पूरा करें",
      'mission': "वर्तमान मिशन",
      'steps': [
        {
          'dropdown': "चरण 1: चमकते पत्थर",
          'hud':
              "गुणन घटकों की कल्पना करने के लिए 'समूह भाग 1 (3<sup>4</sup>)' और 'समूह भाग 2 (3<sup>3</sup>)' पर क्लिक करें।",
          'btn1': "समूह भाग 1 (3<sup>4</sup>)",
          'btn2': "समूह भाग 2 (3<sup>3</sup>)",
          'success':
              "समूहों की पहचान हो गई! 'नियम व्युत्पन्न करें' पर क्लिक करें।",
        },
        {
          'dropdown': "चरण 2: गुणन का नियम",
          'hud': "आधारों को मिलाने और घातांक जोड़ने के लिए स्लाइड करें।",
          'success': "घातांक जुड़ गए! आइए इसे पीछे की ओर लागू करें।",
        },
        {
          'dropdown': "चरण 3: जादुई तालाब",
          'hud':
              "30वें दिन से पीछे जाने के लिए नियंत्रण का उपयोग करें और पता लगाएं कि यह 50% कब भरा था।",
          'success': "सही! 29वें दिन आधा भरा था। गणित चर्चा पर आगे बढ़ें।",
        },
        {
          'dropdown': "चरण 4: गणित चर्चा (घात की घात)",
          'hud':
              "आधार 8 को 2<sup>3</sup> में तोड़ने के लिए '8<sup>6</sup> का विस्तार करें' पर क्लिक करें।",
          'btn': "आधार 8 को 2<sup>3</sup> में बदलें",
          'success':
              "विस्तार हो गया! अब हमारे पास 3 के 6 समूह हैं, जो 2<sup>18</sup> है।",
        },
        {
          'dropdown': "चरण 5: पासवर्ड संयोजन",
          'hud': "यह देखने के लिए गणना करें कि कौन सा ताला अधिक सुरक्षित है।",
          'lbl1': "5 अंक (0-9)",
          'lbl2': "5 अक्षर (A-Z)",
          'success': "गणना हो गई! A-Z ताला घातांकीय सुरक्षा प्रदान करता है।",
        },
      ],
    },
  };

  String t(String key) => i18n[currentLang]![key] as String;
  Map<String, dynamic> tStep(int index) =>
      (i18n[currentLang]!['steps'] as List)[index];
  String tCommon(String key) =>
      (i18n[currentLang]!['common'] as Map<String, String>)[key]!;

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
    _actionAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _spinController = AnimationController(
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
    _actionAnimController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _loadScenario(int index) {
    _playSound('tap');
    setState(() {
      currentStep = index;
      isTaskComplete = false;

      // Reset State Variables
      s0Part1Done = false;
      s0Part2Done = false;
      s1MergeValue = 0;
      s1Merged = false;
      s2PondDay = 30;
      s3Expanded = false;
      s4Calc1Done = false;
      s4Calc2Done = false;

      _actionAnimController.reset();
      _spinController.reset();
    });
  }

  void _resetLab() {
    _playSound('tap');
    setState(() {
      showCurtain = true;
      isSidebarOpen = true; // ensure sidebar is available when they re-enter
    });
    _loadScenario(0); // Fully reset the state back to the first step
  }

  void _checkValidation() {
    bool passed = false;
    switch (currentStep) {
      case 0:
        passed = s0Part1Done && s0Part2Done;
        break;
      case 1:
        passed = s1Merged;
        break;
      case 2:
        passed = s2PondDay <= 29;
        break;
      case 3:
        passed = s3Expanded;
        break;
      case 4:
        passed = s4Calc1Done && s4Calc2Done;
        break;
    }

    if (passed && !isTaskComplete) {
      _playSound('success');
      setState(() {
        isTaskComplete = true;
      });
    }
  }

  // --- Task Actions ---
  void _triggerS0(int part) {
    _playSound('tap');
    setState(() {
      if (part == 1) s0Part1Done = true;
      if (part == 2) s0Part2Done = true;
    });
    _checkValidation();
  }

  void _triggerS1Slider(double val) {
    setState(() {
      s1MergeValue = val;
      if (val >= 100 && !s1Merged) {
        _playSound('tap');
        s1Merged = true;
        _actionAnimController.forward();
        _checkValidation();
      }
    });
  }

  void _triggerS2Rewind() {
    _playSound('tap');
    if (s2PondDay > 25) {
      setState(() {
        s2PondDay--;
      });
      _checkValidation();
    }
  }

  void _triggerS3Expand() {
    _playSound('tap');
    setState(() {
      s3Expanded = true;
    });
    _actionAnimController.forward();
    _checkValidation();
  }

  void _triggerS4Calc(int lock) {
    _playSound('tap');
    setState(() {
      if (lock == 1) s4Calc1Done = true;
      if (lock == 2) s4Calc2Done = true;
    });
    _spinController.forward(from: 0);
    _checkValidation();
  }

  void _nextStep() {
    _playSound('tap');
    if (currentStep < 4) {
      _loadScenario(currentStep + 1);
    } else {
      // Lab Complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Lab Completed Successfully!",
            style: TextStyle(
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
    final double screenWidth = MediaQuery.of(context).size.width;
    // Set strictly to 30% of screen width.
    final double sidebarWidth = screenWidth * 0.35;

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // 1. Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [Color(0xFF1e293b), Color(0xFF0f172a)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),

            // 2. Responsive Center Canvas (Adjustable / Zoomable)
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.2,
                maxScale: 4.0,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _actionAnimController,
                    _spinController,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: ExponentsLabPainter(
                        step: currentStep,
                        s0Part1: s0Part1Done,
                        s0Part2: s0Part2Done,
                        s1MergeVal: s1MergeValue,
                        s1Merged: s1Merged,
                        s1AnimValue: _actionAnimController.value,
                        s2Day: s2PondDay,
                        s3Expanded: s3Expanded,
                        s3AnimValue: _actionAnimController.value,
                        s4Calc1: s4Calc1Done,
                        s4Calc2: s4Calc2Done,
                        s4SpinValue: _spinController.value,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3. Floating Mission Card (Shown when Sidebar is Closed)
            if (!isSidebarOpen && !showCurtain)
              Positioned(top: 80, left: 16, child: _buildFloatingMissionCard()),

            // 4. Success Popup (Scrollable)
            if (isTaskComplete)
              Positioned(
                top: 70,
                left: 400,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 120,
                    // maxWidth: screenWidth * 0.6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 10),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      tStep(currentStep)['success'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // 6. Left Sidebar Overlay (Scrollable + z-index Front)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildLeftSidebar(sidebarWidth),
            ),

            // 7. Menu Button (Top Left Canvas - Front z-index)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(
                  isSidebarOpen ? Icons.menu_open : Icons.menu,
                  size: 32,
                ),
                color: Colors.white,
                onPressed: () {
                  _playSound('tap');
                  setState(() => isSidebarOpen = !isSidebarOpen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 8. Curtain Raiser (Top most)
            if (showCurtain) _buildCurtainRaiser(),
          ],
        ),
      ),
    );
  }

  // Floating Mission Card UI building method
  Widget _buildFloatingMissionCard() {
    Map<String, dynamic> stepData = tStep(currentStep);

    return Container(
      width: 280,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 80,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade700, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.amberAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('mission').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              stepData['dropdown'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey.shade800),
              ),
              child: _parseRichMathText(
                stepData['hud'],
                color: Colors.amberAccent,
                fontSize: 13,
                center: true,
              ),
            ),
            const SizedBox(height: 16),
            _buildSidebarActionControls(stepData),
            if (isTaskComplete) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: Text(t('btnValidate')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade500,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _nextStep,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Extracted Sidebar UI building method
  Widget _buildLeftSidebar(double width) {
    Map<String, dynamic> stepData = tStep(currentStep);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.98),
        border: Border(
          right: BorderSide(color: Colors.blueGrey.shade700, width: 2),
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Wrapped the entire sidebar contents in a SingleChildScrollView
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 64),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.science,
                              color: Colors.amberAccent,
                              size: 28,
                            ),
                          ),
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
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t('subtitle'),
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Scrollable Inner Content Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Language Toggle & Reset Control Row
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0f172a),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blueGrey.shade700,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: ['en', 'hi'].map((lang) {
                                        bool isActive = currentLang == lang;
                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              _playSound('tap');
                                              setState(
                                                () => currentLang = lang,
                                              );
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? Colors.amber.shade700
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                lang.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: isActive
                                                      ? Colors.black
                                                      : Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade800,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blueGrey.shade700,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.amberAccent,
                                    ),
                                    tooltip: "Reset Activity",
                                    onPressed: _resetLab,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Step Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0f172a),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  dropdownColor: const Color(0xFF0f172a),
                                  isExpanded: true,
                                  value: currentStep,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items: List.generate(5, (index) {
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
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 16),

                            // Target Output (HUD Description)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade900.withOpacity(
                                  0.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                              child: _parseRichMathText(
                                stepData['hud'],
                                color: Colors.amberAccent,
                                fontSize: 14,
                                center: true,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Dynamic Action Controls
                            _buildSidebarActionControls(stepData),

                            const SizedBox(height: 40),

                            // Derive & Proceed / Validate Button
                            ElevatedButton.icon(
                              icon: Icon(
                                isTaskComplete
                                    ? Icons.arrow_forward
                                    : Icons.lock_outline,
                              ),
                              label: Text(
                                isTaskComplete
                                    ? t('btnValidate')
                                    : t('btnTaskFirst'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isTaskComplete
                                    ? Colors.amber.shade500
                                    : Colors.blueGrey.shade800,
                                foregroundColor: isTaskComplete
                                    ? Colors.black
                                    : Colors.white54,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isTaskComplete ? _nextStep : null,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Sidebar Footer text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f172a),
                        border: Border(
                          top: BorderSide(color: Colors.blueGrey.shade800),
                        ),
                      ),
                      child: const Text(
                        "© ZeroScienceLab - Fall in love with math and Science",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Contains the interactive buttons/sliders that were previously at the bottom
  Widget _buildSidebarActionControls(Map<String, dynamic> stepData) {
    if (currentStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: s0Part1Done ? null : () => _triggerS0(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _parseRichMathText(
              stepData['btn1'],
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: !s0Part1Done || s0Part2Done ? null : () => _triggerS0(2),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _parseRichMathText(
              stepData['btn2'],
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    if (currentStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tCommon('merge'),
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: s1MergeValue,
            min: 0,
            max: 100,
            activeColor: Colors.amber,
            inactiveColor: Colors.blueGrey,
            onChanged: s1Merged ? null : _triggerS1Slider,
          ),
        ],
      );
    }

    if (currentStep == 2) {
      return Column(
        children: [
          Text(
            "${tCommon('day')} $s2PondDay",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: const Icon(Icons.fast_rewind, size: 30),
            color: Colors.amber,
            style: IconButton.styleFrom(
              backgroundColor: Colors.amber.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: s2PondDay > 25 ? _triggerS2Rewind : null,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width:
                                constraints.maxWidth *
                                (100 / math.pow(2, 30 - s2PondDay)) /
                                100,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 45,
                child: Text(
                  "${(100 / math.pow(2, 30 - s2PondDay)).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (currentStep == 3) {
      return ElevatedButton(
        onPressed: s3Expanded ? null : _triggerS3Expand,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 44),
        ),
        child: _parseRichMathText(
          stepData['btn'],
          color: Colors.white,
          fontSize: 14,
        ),
      );
    }

    if (currentStep == 4) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stepData['lbl1'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: s4Calc1Done ? null : () => _triggerS4Calc(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(tCommon('calc')),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: s4Calc1Done ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _parseRichMathText(
                    "10<sup>5</sup>",
                    color: Colors.blueAccent,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stepData['lbl2'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: s4Calc2Done ? null : () => _triggerS4Calc(2),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(tCommon('calc')),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: s4Calc2Done ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _parseRichMathText(
                    "26<sup>5</sup>",
                    color: Colors.greenAccent,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.05),
                  child: const Icon(
                    Icons.science,
                    color: Colors.amber,
                    size: 80,
                  ),
                );
              },
            ),
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
                _playSound('tap');
                setState(() => showCurtain = false);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
            ),
          ],
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
  }) {
    List<InlineSpan> spans = [];

    // Very basic regex to split by bold, italic, and super scripts.
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
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      );

      if (isSup) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Transform.translate(
              offset: const Offset(0, -4), // shift up
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

// --- Pseudo-3D Isometric Painter Engine ---
class ExponentsLabPainter extends CustomPainter {
  final int step;
  final bool s0Part1;
  final bool s0Part2;
  final double s1MergeVal;
  final bool s1Merged;
  final double s1AnimValue;
  final int s2Day;
  final bool s3Expanded;
  final double s3AnimValue;
  final bool s4Calc1;
  final bool s4Calc2;
  final double s4SpinValue;

  ExponentsLabPainter({
    required this.step,
    required this.s0Part1,
    required this.s0Part2,
    required this.s1MergeVal,
    required this.s1Merged,
    required this.s1AnimValue,
    required this.s2Day,
    required this.s3Expanded,
    required this.s3AnimValue,
    required this.s4Calc1,
    required this.s4Calc2,
    required this.s4SpinValue,
  });

  // Basic Isometric projection
  Offset _iso(double x, double y, double z, Offset origin, double scale) {
    double cos30 = math.cos(math.pi / 6);
    double sin30 = math.sin(math.pi / 6);
    double sx = (x - z) * cos30 * scale;
    double sy = (x + z) * sin30 * scale - y * scale;
    return origin + Offset(sx, sy);
  }

  void _drawOrb(
    Canvas canvas,
    Offset pos,
    double radius,
    Color color,
    String text, {
    bool showText = true,
    double textScale = 1.0,
  }) {
    // Glow
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.6), Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: radius * 1.5));
    canvas.drawCircle(pos, radius * 1.5, glowPaint);

    // Body
    final Paint orbPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [color.withOpacity(0.5), color],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));
    canvas.drawCircle(pos, radius, orbPaint);

    // Outline
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (showText) {
      _drawText(
        canvas,
        text,
        pos,
        size: 16 * textScale,
        color: Colors.white,
        shadow: true,
      );
    }
  }

  void _drawBlock(
    Canvas canvas,
    Offset pos,
    double w,
    double h,
    double d,
    double scale,
    Color baseColor,
  ) {
    Offset p1 = pos;
    Offset p2 =
        pos +
        Offset(
          w * math.cos(math.pi / 6) * scale,
          w * math.sin(math.pi / 6) * scale,
        );
    Offset p3 =
        pos +
        Offset(
          -d * math.cos(math.pi / 6) * scale,
          d * math.sin(math.pi / 6) * scale,
        );
    Offset p4 =
        pos +
        Offset(
          (w - d) * math.cos(math.pi / 6) * scale,
          (w + d) * math.sin(math.pi / 6) * scale,
        );

    Offset up = Offset(0, -h * scale);

    // Left Face
    Path left = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p3.dx + up.dx, p3.dy + up.dy)
      ..lineTo(p1.dx + up.dx, p1.dy + up.dy)
      ..close();
    // Right Face
    Path right = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p2.dx + up.dx, p2.dy + up.dy)
      ..lineTo(p1.dx + up.dx, p1.dy + up.dy)
      ..close();
    // Top Face
    Path top = Path()
      ..moveTo(p1.dx + up.dx, p1.dy + up.dy)
      ..lineTo(p2.dx + up.dx, p2.dy + up.dy)
      ..lineTo(p4.dx + up.dx, p4.dy + up.dy)
      ..lineTo(p3.dx + up.dx, p3.dy + up.dy)
      ..close();

    Color cLeft = Color.fromARGB(
      baseColor.alpha,
      (baseColor.red * 0.8).round(),
      (baseColor.green * 0.8).round(),
      (baseColor.blue * 0.8).round(),
    );
    Color cRight = baseColor;
    Color cTop = Color.fromARGB(
      baseColor.alpha,
      math.min(255, (baseColor.red * 1.2).round()),
      math.min(255, (baseColor.green * 1.2).round()),
      math.min(255, (baseColor.blue * 1.2).round()),
    );

    canvas.drawPath(left, Paint()..color = cLeft);
    canvas.drawPath(right, Paint()..color = cRight);
    canvas.drawPath(top, Paint()..color = cTop);

    // Edges
    Paint edge = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke;
    canvas.drawPath(left, edge);
    canvas.drawPath(right, edge);
    canvas.drawPath(top, edge);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    double size = 20,
    Color color = Colors.white,
    bool shadow = false,
    bool bg = false,
  }) {
    // For simple math rendering
    List<InlineSpan> spans = [];
    List<String> parts = text.split('^');
    spans.add(
      TextSpan(
        text: parts[0],
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    if (parts.length > 1) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Transform.translate(
            offset: Offset(0, -size * 0.3),
            child: Text(
              parts[1],
              style: TextStyle(
                color: color,
                fontSize: size * 0.7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    final tp = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    if (bg) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: pos,
            width: tp.width + 16,
            height: tp.height + 8,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.black54,
      );
    }
    if (shadow) {
      final tpSh = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: parts[0],
              style: TextStyle(
                color: Colors.black54,
                fontSize: size,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      );
      tpSh.layout();
      tpSh.paint(canvas, pos - Offset(tp.width / 2 - 2, tp.height / 2 - 2));
    }

    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawCylinder(
    Canvas canvas,
    Offset base,
    double radius,
    double height,
    Color color,
    String txt,
  ) {
    // Draw stack of circles to simulate cylinder
    for (double i = 0; i < height; i += 0.5) {
      Color c = i >= height - 0.5
          ? color
          : Color.fromARGB(
              color.alpha,
              (color.red * 0.8).round(),
              (color.green * 0.8).round(),
              (color.blue * 0.8).round(),
            );
      canvas.drawCircle(base + Offset(0, -i), radius, Paint()..color = c);
    }
    // Border for top
    canvas.drawCircle(
      base + Offset(0, -height),
      radius,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke,
    );

    // Label on front
    _drawText(canvas, txt, base + Offset(0, -height / 2), size: 14);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Perfectly centered on responsive full canvas
    Offset center = Offset(size.width * 0.5, size.height * 0.5);

    if (step == 0) {
      // 3^4 (Blue) and 3^3 (Green)
      double r1 = s0Part1 ? 50 : 30;
      double r2 = s0Part2 ? 50 : 30;

      Offset p1 = center + const Offset(-100, 0);
      Offset p2 = center + const Offset(100, 0);

      _drawOrb(
        canvas,
        p1,
        r1,
        Colors.blueAccent,
        "3^4",
        showText: s0Part1,
        textScale: 1.5,
      );
      _drawOrb(
        canvas,
        p2,
        r2,
        Colors.greenAccent,
        "3^3",
        showText: s0Part2,
        textScale: 1.5,
      );
    } else if (step == 1) {
      double scale = 30;
      double t = s1MergeVal / 100.0;

      // Group 1: 4 Blocks (Red) - Starts at x=-2, moves to x=-1
      double x1 = math.min(-1, -3 + (2 * t));
      // Group 2: 3 Blocks (Orange) - Starts at x=2, moves to x=0
      double x2 = math.max(0, 3 - (3 * t));

      if (s1Merged) {
        // Explode into 7 block group + Equal Sign
        double scaleUp = 1.0 + (s1AnimValue * 0.2); // slight pop
        Offset mainPos = _iso(0, 0, 0, center, scale);

        for (int i = 0; i < 7; i++) {
          _drawBlock(
            canvas,
            _iso(i * 1.1 - 3, 0, 0, center, scale * scaleUp),
            1,
            1,
            1,
            scale * scaleUp,
            i < 4 ? Colors.redAccent : Colors.orangeAccent,
          );
        }

        // Equal Sign and label
        _drawText(
          canvas,
          "3^4 × 3^3  =  3^7",
          mainPos + const Offset(0, -120),
          size: 28,
          bg: true,
          color: Colors.amberAccent,
        );
      } else {
        // Separate Groups
        for (int i = 0; i < 4; i++) {
          _drawBlock(
            canvas,
            _iso(x1 + i * 1.1, 0, 0, center, scale),
            1,
            1,
            1,
            scale,
            Colors.redAccent,
          );
        }
        for (int i = 0; i < 3; i++) {
          _drawBlock(
            canvas,
            _iso(x2 + i * 1.1, 0, 0, center, scale),
            1,
            1,
            1,
            scale,
            Colors.orangeAccent,
          );
        }

        _drawText(
          canvas,
          "3^4",
          _iso(x1 + 1.5, 1.5, 0, center, scale),
          size: 20,
          bg: true,
        );
        _drawText(
          canvas,
          "3^3",
          _iso(x2 + 1, 1.5, 0, center, scale),
          size: 20,
          bg: true,
        );
      }
    } else if (step == 2) {
      // Pond
      Paint pondPaint = Paint()..color = Colors.lightBlue.shade700;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 400, height: 200),
        pondPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 400, height: 200),
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      // Draw Lotuses (64 = 100%)
      int maxLotuses = 64;
      int daysBack = 30 - s2Day;
      int numLotuses = (maxLotuses / math.pow(2, daysBack)).round();

      math.Random rnd = math.Random(42); // fixed seed for stability
      for (int i = 0; i < numLotuses; i++) {
        double angle = rnd.nextDouble() * math.pi * 2;
        double r =
            math.sqrt(rnd.nextDouble()) *
            180; // distribute evenly in circle, mapped to ellipse
        Offset lPos =
            center + Offset(r * math.cos(angle), r * math.sin(angle) * 0.5);

        canvas.drawCircle(lPos, 6, Paint()..color = Colors.greenAccent);
        canvas.drawCircle(lPos, 3, Paint()..color = Colors.pinkAccent);
      }

      _drawText(
        canvas,
        "Day $s2Day",
        center + const Offset(0, -130),
        size: 24,
        bg: true,
        color: Colors.cyanAccent,
      );
    } else if (step == 3) {
      double scale = 30;

      if (!s3Expanded) {
        // 6 Big Blocks (Purple) = 8^6
        for (int i = 0; i < 6; i++) {
          _drawBlock(
            canvas,
            _iso((i - 2.5) * 2.2, 0, 0, center, scale),
            2,
            2,
            2,
            scale,
            Colors.deepPurpleAccent,
          );
        }
        _drawText(
          canvas,
          "8^6",
          center + const Offset(0, -120),
          size: 32,
          bg: true,
          color: Colors.purpleAccent,
        );
      } else {
        // Expanding into 6 groups of 3 small blocks (Pink) = (2^3)^6
        double distY =
            s3AnimValue * 1.5; // Small blocks separate vertically slightly
        for (int i = 0; i < 6; i++) {
          double bx = (i - 2.5) * 2.2;
          for (int j = 0; j < 3; j++) {
            _drawBlock(
              canvas,
              _iso(bx, j * 0.7 * distY, 0, center, scale),
              0.6,
              0.6,
              0.6,
              scale,
              Colors.pinkAccent,
            );
          }
        }
        _drawText(
          canvas,
          "(2^3)^6  =  2^1^8",
          center + const Offset(0, -120),
          size: 28,
          bg: true,
          color: Colors.pinkAccent,
        );
      }
    } else if (step == 4) {
      // Dials
      double r = 25;
      double h = 60;

      // Left Lock (0-9)
      for (int i = 0; i < 5; i++) {
        Offset base = center + Offset(-150 + i * 30, 0);
        // Pseudo Spin
        int digit = s4Calc1 ? (i + (s4SpinValue * 20).toInt()) % 10 : 0;
        _drawCylinder(canvas, base, r, h, Colors.blueGrey, "$digit");
      }
      _drawText(
        canvas,
        "0-9 (10 options)",
        center + const Offset(-90, 40),
        size: 12,
        color: Colors.white54,
      );

      // Right Lock (A-Z)
      for (int i = 0; i < 5; i++) {
        Offset base = center + Offset(30 + i * 30, 0);
        int letterIdx = s4Calc2 ? (i + (s4SpinValue * 20).toInt()) % 26 : 0;
        String letter = String.fromCharCode(65 + letterIdx);
        _drawCylinder(canvas, base, r, h, Colors.blueGrey, letter);
      }
      _drawText(
        canvas,
        "A-Z (26 options)",
        center + const Offset(90, 40),
        size: 12,
        color: Colors.white54,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ExponentsLabPainter oldDelegate) {
    return true; // Simple repaint always for animation safety
  }
}
