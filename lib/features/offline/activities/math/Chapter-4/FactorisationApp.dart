// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audio players
import 'dart:async';
import 'dart:math' as math;

// --- DATA & I18N ---

class Equation {
  final int id;
  final String name;
  final String latex;
  final int a;
  final int b;
  final int c;
  final int p;
  final int q;
  final List<String> factors;
  final String roots;

  Equation({
    required this.id,
    required this.name,
    required this.latex,
    required this.a,
    required this.b,
    required this.c,
    required this.p,
    required this.q,
    required this.factors,
    required this.roots,
  });
}

final List<Equation> equationsData = [
  Equation(
    id: 0,
    name: "Sample Alpha",
    latex: "x² - 5x + 6 = 0",
    a: 1,
    b: -5,
    c: 6,
    p: -2,
    q: -3,
    factors: ["(x-2)", "(x-3)"],
    roots: "x=2, x=3",
  ),
  Equation(
    id: 1,
    name: "Sample Beta",
    latex: "x² + 5x + 6 = 0",
    a: 1,
    b: 5,
    c: 6,
    p: 2,
    q: 3,
    factors: ["(x+2)", "(x+3)"],
    roots: "x=-2, x=-3",
  ),
  Equation(
    id: 2,
    name: "Sample Gamma",
    latex: "x² - x - 6 = 0",
    a: 1,
    b: -1,
    c: -6,
    p: -3,
    q: 2,
    factors: ["(x-3)", "(x+2)"],
    roots: "x=3, x=-2",
  ),
  Equation(
    id: 3,
    name: "Sample Delta",
    latex: "x² + 4x - 5 = 0",
    a: 1,
    b: 4,
    c: -5,
    p: 5,
    q: -1,
    factors: ["(x+5)", "(x-1)"],
    roots: "x=-5, x=1",
  ),
];

const Map<String, Map<String, String>> i18n = {
  'en': {
    "app_title": "FACTORISATION FACTORY",
    "tagline": "SOLUTIONS BY FACTORISATION • CLASS 10",
    "init_btn": "ENTER MOLECULAR LAB",
    "header_title": "The Factorisation Factory",
    "header_subtitle": "CLASS 10 • QUADRATIC EQUATIONS",
    "ctx_title": "Why Learn This?",
    "post_title": "Analysis & Outcomes",
    "lbl_progress": "Reaction Progress",
    "hud_status": "Lab Status",
    "lbl_select_eq": "Select Unstable Molecule",
    "btn_inject": "INJECT SAMPLE",
    "btn_analyze": "ANALYZE ATOMS",
    "btn_split": "INITIATE SPLIT",
    "btn_bond": "ACTIVATE BONDING TOOL",
    "btn_ex1": "EXTRACT GROUP 1",
    "btn_ex2": "EXTRACT GROUP 2",
    "btn_final": "FINAL BONDING",
    "btn_verify": "STABILITY CHECK",
    "btn_next": "Process Next Molecule",
    "btn_restart": "Restart Lab",
    "msg_success": "MOLECULE STABILIZED",
    "step_1_t": "RECEIVE MOLECULE",
    "step_1_d":
        "Select an equation from the dropdown menu and inject the sample.",
    "step_2_t": "TARGET ANALYZER",
    "step_2_d":
        "Click 'ANALYZE ATOMS' to determine the Product (ac) and Sum (b).",
    "step_3_t": "ISOTOPE SELECTION",
    "step_3_d":
        "Select two numbers from the grid that add up to the Sum (b) and multiply to the Product (ac), then CONFIRM.",
    "step_4_t": "SPLITTING PROCESS",
    "step_4_d":
        "Click 'INITIATE SPLIT' to visually divide the middle term (bx) into the two selected values (px and qx).",
    "step_5_t": "GROUPING ATOMS",
    "step_5_d":
        "Click 'ACTIVATE BONDING TOOL' to group the four terms into two distinct pairs for factoring.",
    "step_6_t": "EXTRACTING G1",
    "step_6_d":
        "Click 'EXTRACT GROUP 1' to factor out the common term from the first pair.",
    "step_7_t": "EXTRACTING G2",
    "step_7_d":
        "Click 'EXTRACT GROUP 2' to factor out the common term from the second pair, forming identical brackets.",
    "step_8_t": "FINAL BONDING",
    "step_8_d":
        "Click 'FINAL BONDING' to combine the extracted parts into your two binomial factors.",
    "step_9_t": "FINDING ROOTS",
    "step_9_d":
        "Use the Zero Product Property. Click 'Solve' on both binomial factors to find the values of x.",
    "step_10_t": "STABILITY CHECK",
    "step_10_d":
        "Click 'STABILITY CHECK' to verify the roots in the original equation and stabilize the molecule.",
    "ctx_1_t": "Supply Chain",
    "ctx_1_d":
        "Optimizing production costs often involves solving quadratic equations.",
    "ctx_2_t": "Physics",
    "ctx_2_d":
        "Calculating the time taken for a ball to hit the ground involves finding roots.",
    "ctx_3_t": "Area Problems",
    "ctx_3_d":
        "Finding dimensions of a room given its area requires factorisation.",
    "out_1_t": "Splitting the Middle Term",
    "out_1_d": "Rewrite bx as px + qx where p+q=b and pq=ac.",
    "out_2_t": "Zero Product Rule",
    "out_2_d": "If (x-p)(x-q)=0, then x=p or x=q.",
    "out_3_t": "Roots",
    "out_3_d": "The values of x that satisfy the equation.",
  },
  'hi': {
    "app_title": "गुणनखंड फैक्टरी",
    "tagline": "गुणनखंड द्वारा हल • कक्षा 10",
    "init_btn": "मॉलिक्यूलर लैब में प्रवेश करें",
    "header_title": "गुणनखंड फैक्टरी",
    "header_subtitle": "कक्षा 10 • द्विघात समीकरण",
    "ctx_title": "क्यों सीखें?",
    "post_title": "विश्लेषण और परिणाम",
    "lbl_progress": "प्रतिक्रिया प्रगति",
    "hud_status": "लैब स्थिति",
    "lbl_select_eq": "अस्थिर अणु चुनें",
    "btn_inject": "सैंपल इंजेक्ट करें",
    "btn_analyze": "परमाणुओं का विश्लेषण",
    "btn_split": "विभाजन शुरू करें",
    "btn_bond": "बॉन्डिंग टूल सक्रिय करें",
    "btn_ex1": "समूह 1 निकालें",
    "btn_ex2": "समूह 2 निकालें",
    "btn_final": "अंतिम बॉन्डिंग",
    "btn_verify": "स्थिरता जांच",
    "btn_next": "अगला अणु",
    "btn_restart": "लैब पुनः आरंभ करें",
    "msg_success": "अणु स्थिर हो गया",
    "step_1_t": "अणु प्राप्त करें",
    "step_1_d": "ड्रॉपडाउन से एक समीकरण चुनें और सैंपल इंजेक्ट करें।",
    "step_2_t": "लक्ष्य विश्लेषक",
    "step_2_d":
        "गुणनफल (ac) और योग (b) निर्धारित करने के लिए 'परमाणुओं का विश्लेषण' पर क्लिक करें।",
    "step_3_t": "आइसोटोप चयन",
    "step_3_d":
        "ग्रिड से दो संख्याएँ चुनें जिनका योग (b) और गुणनफल (ac) हो, फिर पुष्टि करें।",
    "step_4_t": "विभाजन प्रक्रिया",
    "step_4_d":
        "मध्य पद (bx) को आपके द्वारा चुनी गई दो संख्याओं में विभाजित करने के लिए क्लिक करें।",
    "step_5_t": "परमाणु समूहीकरण",
    "step_5_d":
        "चार पदों को दो जोड़े में समूहित करने के लिए 'बॉन्डिंग टूल सक्रिय करें' पर क्लिक करें।",
    "step_6_t": "G1 निकालना",
    "step_6_d":
        "पहले जोड़े से सामान्य पद निकालने के लिए 'समूह 1 निकालें' पर क्लिक करें।",
    "step_7_t": "G2 निकालना",
    "step_7_d":
        "दूसरे जोड़े से सामान्य पद निकालने के लिए 'समूह 2 निकालें' पर क्लिक करें।",
    "step_8_t": "अंतिम बॉन्डिंग",
    "step_8_d":
        "निकाले गए भागों को अंतिम द्विपद गुणनखंडों में संयोजित करने के लिए क्लिक करें।",
    "step_9_t": "मूल खोजना",
    "step_9_d":
        "शून्य उत्पाद नियम का उपयोग करें। दोनों गुणनखंडों पर 'हल करें' पर क्लिक करें।",
    "step_10_t": "स्थिरता जांच",
    "step_10_d":
        "मूल समीकरण में मूलों को सत्यापित करने के लिए 'स्थिरता जांच' पर क्लिक करें।",
    "ctx_1_t": "आपूर्ति श्रृंखला",
    "ctx_1_d": "लागत अनुकूलन में द्विघात समीकरणों का उपयोग होता है।",
    "ctx_2_t": "भौतिक विज्ञान",
    "ctx_2_d": "गेंद गिरने का समय निकालने के लिए।",
    "ctx_3_t": "क्षेत्रफल",
    "ctx_3_d": "कमरे के आयाम ज्ञात करना।",
    "out_1_t": "मध्य पद विभाजन",
    "out_1_d": "bx को px + qx लिखें।",
    "out_2_t": "शून्य उत्पाद",
    "out_2_d": "यदि (x-p)(x-q)=0, तो x=p या x=q।",
    "out_3_t": "मूल",
    "out_3_d": "x के मान जो समीकरण को संतुष्ट करते हैं।",
  },
};

// Dedicated audio players initialized with ReleaseMode.stop
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
const String _alertUrl = 'audio/math/alert.mp3';
const String _startUrl = 'audio/math/shutter.mp3';

// --- MAIN WIDGET ---

class FactorisationApp extends StatefulWidget {
  const FactorisationApp({super.key});

  @override
  State<FactorisationApp> createState() => _FactorisationAppState();
}

class _FactorisationAppState extends State<FactorisationApp>
    with TickerProviderStateMixin {
  bool started = false;
  String lang = 'en';
  bool panelOpen = true;

  // Scroll Controller for HUD
  final ScrollController _hudScrollController = ScrollController();

  // Game State
  int step = 0;
  Equation eq = equationsData[0];
  List<String> logs = ['Lab Systems Online...'];
  List<int> isotopeOptions = [];
  List<int> selectedIsotopes = [];
  bool isoValid = false;
  int solvedCount = 0;
  bool showCelebration = false;

  void playFeedback(String type) async {
    try {
      if (type == 'click') {
        HapticFeedback.lightImpact();
        await _clickPlayer.play(AssetSource(_clickUrl));
      } else if (type == 'success') {
        HapticFeedback.mediumImpact();
        await _successPlayer.play(AssetSource(_successUrl));
      } else if (type == 'start' || type == 'intro') {
        HapticFeedback.mediumImpact();
        await _fxPlayer.play(AssetSource(_startUrl));
      } else if (type == 'clank' || type == 'alert') {
        HapticFeedback.heavyImpact();
        await _fxPlayer.play(AssetSource(_alertUrl));
      } else if (type == 'error') {
        HapticFeedback.heavyImpact();
        await _errorPlayer.play(AssetSource(_errorUrl));
      }
    } catch (e) {
      // Audio playback failed (e.g. platform restrictions), gracefully continue
      debugPrint("Audio Error: $e");
    }
  }

  void addLog(String msg) {
    setState(() {
      logs.insert(0, msg);
      if (logs.length > 10) logs.removeLast();
    });
  }

  void setEq(Equation newEq) {
    setState(() {
      eq = newEq;
    });
  }

  void executeStep(int newStep) {
    playFeedback('click');

    setState(() {
      step = newStep;
      if (step == 10) showCelebration = true;
    });

    if (step == 1) {
      addLog("Molecule Injected: ${eq.latex}");
    } else if (step == 2) {
      addLog("Target Sum: ${eq.b}, Product: ${eq.a * eq.c}");
      // Generate Options
      Set<int> vals = {eq.p, eq.q, -eq.p, -eq.q, eq.p + 1, eq.q - 1, 0, 1};
      List<int> shuffledVals = vals.toList()..shuffle();

      setState(() {
        isotopeOptions = shuffledVals;
        selectedIsotopes = [];
        isoValid = false;
      });
    } else if (step == 3) {
      addLog("Isotopes Selected: ${selectedIsotopes.join(", ")}");
    } else if (step == 4) {
      playFeedback('alert');
      addLog("Middle Term Split.");
    } else if (step == 5) {
      addLog("Atoms Grouped.");
    } else if (step == 6) {
      addLog("Group 1 Factored: x${eq.factors[0]}");
    } else if (step == 7) {
      addLog("Group 2 Factored: ${eq.q}${eq.factors[0]}");
    } else if (step == 8) {
      playFeedback('clank');
      addLog("Final Bonding Complete.");
      setState(() => solvedCount = 0);
    } else if (step == 10) {
      playFeedback('success');
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => showCelebration = false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
    _hudScrollController.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void selectIsotope(int val) {
    List<int> sel = List.from(selectedIsotopes);
    if (sel.contains(val)) {
      sel.remove(val);
      playFeedback('click');
    } else if (sel.length < 2) {
      sel.add(val);
      playFeedback('click');
    } else {
      playFeedback('error');
    }

    bool valid =
        sel.length == 2 &&
        (sel[0] + sel[1] == eq.b) &&
        (sel[0] * sel[1] == eq.a * eq.c);

    setState(() {
      selectedIsotopes = sel;
      isoValid = valid;
    });

    if (valid && sel.length == 2) {
      playFeedback('success');
    }
  }

  void solveBracket(int num) {
    playFeedback('click');
    setState(() {
      solvedCount++;
      if (solvedCount >= 2) {
        Future.delayed(const Duration(milliseconds: 500), () => executeStep(9));
      }
    });
  }

  void resetApp() {
    setState(() {
      step = 0;
      logs = ['System Reset.'];
      solvedCount = 0;
      showCelebration = false;
      started = false;
      panelOpen = true;
    });
  }

  void resetLabOnly() {
    setState(() {
      step = 0;
      logs = ['System Reset.'];
      solvedCount = 0;
      showCelebration = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = i18n[lang]!;
    final screenWidth = MediaQuery.of(context).size.width;
    final double panelWidth = screenWidth * 0.4;

    if (!started) {
      return _buildStartScreen(t);
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  // 40% Animated Side Panel
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: panelOpen ? panelWidth : 0,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        minWidth: panelWidth,
                        maxWidth: panelWidth,
                        child: _buildSidePanel(t),
                      ),
                    ),
                  ),

                  // 60% (or 100%) Interactive Canvas
                  Expanded(child: _buildLabEnvironment()),
                ],
              ),
            ),

            // Floating HUD (Visible when sidebar is collapsed)
            if (!panelOpen) _buildFloatingHUD(t),

            if (showCelebration) _buildCelebrationOverlay(),

            //Bottom-Left Floating Menu Toggle
            Positioned(
              top: 24,
              left: 24,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF0284C7),
                elevation: 8,
                onPressed: () {
                  playFeedback('click');
                  setState(() => panelOpen = !panelOpen);
                },
                child: Icon(
                  panelOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen(Map<String, String> t) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                radius: 1.5,
              ),
            ),
          ),
          CustomPaint(
            painter: GridPainter(color: Colors.white.withOpacity(0.03)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.lightBlueAccent.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlueAccent.withOpacity(0.5),
                        blurRadius: 100,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.science_outlined,
                    size: 80,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t['app_title'] ?? "FACTORISATION FACTORY",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                    shadows: [
                      Shadow(color: Colors.lightBlueAccent, blurRadius: 10),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t['tagline'] ?? "SOLUTIONS BY FACTORISATION • CLASS 10",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.lightBlue[400],
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    playFeedback('start');
                    setState(() {
                      started = true;
                    });
                  },
                  icon: const Icon(
                    Icons.rocket_launch,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: Text(
                    t['init_btn'] ?? "ENTER MOLECULAR LAB",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7), // sky-600
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 20,
                    shadowColor: const Color(0xFF38BDF8).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(Map<String, String> t) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF20F172A),
        border: Border(right: BorderSide(color: Color(0x3338BDF8))),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.only(
                          top: 80,
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0x3338BDF8)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t['header_title']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t['header_subtitle']!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.lightBlueAccent,
                                          letterSpacing: 1.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLangToggles(),
                                IconButton(
                                  onPressed: resetApp,
                                  icon: const Icon(
                                    Icons.power_settings_new,
                                    size: 20,
                                  ),
                                  color: Colors.red[400],
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(
                                      0.1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: Colors.red.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content Area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 40,
                          ),
                          child: _buildExploreTab(t),
                        ),
                      ),

                      // Footer Zone
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0x3338BDF8)),
                          ),
                          color: Color(0x400F172A),
                        ),
                        width: double.infinity,
                        child: const Text(
                          "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLangToggles() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x801E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: ['en', 'hi'].map((l) {
          return GestureDetector(
            onTap: () {
              playFeedback('click');
              setState(() => lang = l);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: lang == l ? const Color(0xFF0284C7) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: lang == l ? Colors.white : Colors.grey[500],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExploreTab(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t['lbl_progress']!.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
                letterSpacing: 1,
              ),
            ),
            Text(
              "Step $step/10",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: step / 10,
            backgroundColor: const Color(0xFF1E293B),
            color: Colors.lightBlueAccent,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xCC1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t['step_${step}_t'] ?? "LAB READY",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t['step_${step}_d'] ?? "Select a molecule.",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // INTERACTION ZONE
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: _buildInteractionControls(t),
        ),

        const SizedBox(height: 16),
        Container(
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: ListView.builder(
            reverse: true,
            itemCount: logs.length,
            itemBuilder: (ctx, i) => Text(
              "> ${logs[i]}",
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.lightBlueAccent.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionControls(Map<String, String> t) {
    if (step == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['lbl_select_eq']!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: eq.id,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                items: equationsData
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.id,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(e.latex),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setEq(equationsData.firstWhere((e) => e.id == val));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_inject']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 1) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => executeStep(2),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            t['btn_analyze']!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (step == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Find p, q where Sum = ${eq.b}, Prod = ${eq.a * eq.c}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: isotopeOptions
                .map(
                  (v) => GestureDetector(
                    onTap: () => selectIsotope(v),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedIsotopes.contains(v)
                            ? Colors.lightBlue[700]
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedIsotopes.contains(v)
                              ? Colors.lightBlueAccent
                              : Colors.grey[600]!,
                        ),
                      ),
                      child: Text(
                        v.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            selectedIsotopes.join(" + "),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isoValid
                  ? () => executeStep(3)
                  : () => playFeedback('error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isoValid
                    ? Colors.green[600]
                    : Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "CONFIRM",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 3) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => executeStep(4),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            t['btn_split']!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (step == 4) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => executeStep(5),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            t['btn_bond']!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (step == 5) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => executeStep(6),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            t['btn_ex1']!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (step == 6) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => executeStep(7),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            t['btn_ex2']!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (step == 7) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => executeStep(8),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            t['btn_final']!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (step == 8) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Zero Product Property",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: solvedCount >= 1 ? null : () => solveBracket(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: solvedCount >= 1
                        ? Colors.green[600]
                        : Colors.blueGrey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Solve ${eq.factors[0]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: solvedCount >= 2 ? null : () => solveBracket(2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: solvedCount >= 2
                        ? Colors.green[600]
                        : Colors.blueGrey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Solve ${eq.factors[1]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (step == 9) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eq.roots,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => executeStep(10),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_verify']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (step == 10) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
          const SizedBox(height: 8),
          Text(
            t['msg_success']!,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: resetLabOnly,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                t['btn_next']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: resetApp,
            child: Text(
              t['btn_restart']!,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildLabEnvironment() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF0F172A), Color(0xFF000000)],
          radius: 1.0,
        ),
      ),
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.2,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(2000),
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: PerspectiveGridPainter()),
                    ),
                    if (step > 0)
                      _buildAtoms(constraints.maxWidth, constraints.maxHeight),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAtoms(double width, double height) {
    double cy = 0;

    double pxA1 = -150, pxA2 = 0, pxA3 = 150;
    double opA1 = 1.0, opA2 = 1.0, opA3 = 1.0;

    double pxP = -50, pxQ = 50;
    double opP = 0.0, opQ = 0.0;

    double pxF1 = -80, pxF2 = 80;
    double opF1 = 0.0, opF2 = 0.0;

    bool showGroupRings = false;
    double extG1y = 0, extG2y = 0;
    double opExtG1 = 0, opExtG2 = 0;

    double rootY = -150;
    double opRoots = 0;

    if (step >= 4) {
      opA2 = 0.0;
      opP = 1.0;
      opQ = 1.0;
    }

    if (step >= 5 && step < 8) {
      showGroupRings = true;
    }

    if (step >= 6 && step < 8) {
      extG1y = -80;
      opExtG1 = 1.0;
    }

    if (step >= 7 && step < 8) {
      extG2y = -80;
      opExtG2 = 1.0;
    }

    if (step >= 8) {
      opA1 = 0;
      opA3 = 0;
      opP = 0;
      opQ = 0;
      opF1 = 1.0;
      opF2 = 1.0;
    }

    if (step == 10) {
      rootY = 0;
      opRoots = 1.0;
    }

    Widget atom(String text, Color color, double dx, double dy, double op) {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        left: width / 2 + dx - 40,
        top: height / 2 + dy - 40,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: op,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              text.replaceAll('^2', '²'),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      );
    }

    Widget groupRing(double dx) {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        left: width / 2 + dx - 100,
        top: height / 2 - 60,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: showGroupRings ? 1.0 : 0.0,
          child: Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: Colors.lightBlueAccent.withOpacity(0.5),
                width: 2,
              ),
              color: Colors.lightBlueAccent.withOpacity(0.05),
            ),
          ),
        ),
      );
    }

    Widget bondLine() {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        left: width / 2 - 40,
        top: height / 2 - 2,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: opF1,
          child: Container(
            width: 80,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10)],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        if (showGroupRings) groupRing(-100),
        if (showGroupRings) groupRing(100),
        if (opF1 > 0) bondLine(),

        atom("x²", Colors.lightBlueAccent, pxA1, cy, opA1),
        atom("${eq.b}x", Colors.redAccent, pxA2, cy, opA2),
        atom("${eq.c}", Colors.greenAccent, pxA3, cy, opA3),

        atom("${eq.p}x", Colors.amberAccent, pxP, cy, opP),
        atom("${eq.q}x", Colors.amberAccent, pxQ, cy, opQ),

        atom("x", Colors.purpleAccent, pxA1 + 50, extG1y, opExtG1),
        atom("${eq.q}", Colors.purpleAccent, pxA3 - 50, extG2y, opExtG2),

        atom(eq.factors[0], Colors.greenAccent, pxF1, cy, opF1),
        atom(eq.factors[1], Colors.greenAccent, pxF2, cy, opF2),

        atom(
          eq.roots.split(", ")[0],
          Colors.lightBlueAccent,
          pxF1,
          rootY,
          opRoots,
        ),
        atom(
          eq.roots.split(", ")[1],
          Colors.lightBlueAccent,
          pxF2,
          rootY,
          opRoots,
        ),
      ],
    );
  }

  Widget _buildFloatingHUD(Map<String, String> t) {
    return Positioned(
      top: 90,
      left: 24,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height - 130, // Prevents overflow
          maxWidth: 280,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xE60F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
            ],
          ),
          child: Scrollbar(
            controller: _hudScrollController,
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(8),
            child: SingleChildScrollView(
              controller: _hudScrollController,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t['lbl_progress']!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        Text(
                          "Step $step/10",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    Text(
                      t['step_${step}_t'] ?? "LEVEL",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t['step_${step}_d'] ?? "Analyze.",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildInteractionControls(t),

                    const SizedBox(height: 12),
                    Text(
                      "> ${logs[0]}",
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Colors.lightBlueAccent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "STABLE!",
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.lightBlueAccent, blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.8)),
            ),
            child: Text(
              eq.roots,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PerspectiveGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerY = size.height * 0.7;

    // Draw vanishing lines
    for (int i = -10; i <= 10; i++) {
      double startX = size.width / 2 + (i * 40);
      double endX = size.width / 2 + (i * 150);
      canvas.drawLine(
        Offset(startX, centerY),
        Offset(endX, size.height),
        paint,
      );
    }

    // Draw horizontal perspective lines
    for (int i = 0; i < 15; i++) {
      double y = centerY + math.pow(i, 2) * 1.5;
      if (y > size.height) break;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
