// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SquareRootsLab extends StatefulWidget {
  const SquareRootsLab({Key? key}) : super(key: key);

  @override
  State<SquareRootsLab> createState() => _SquareRootsLabState();
}

class _SquareRootsLabState extends State<SquareRootsLab>
    with TickerProviderStateMixin {
  // Application State
  String currentLang = 'en';
  String currentMode = 'area_side'; // area_side, estimation, prime_factors
  bool isSidebarOpen = true;

  // Area Mode State
  int areaValue = 16;

  // Estimation Mode State
  int estTargetVal = 125;
  int estLower = 11;
  int estUpper = 12;
  double playerGuess = 11.5;
  bool isEstChecked = false;

  // Prime Mode State
  int primeTarget = 36;

  bool showCurtain = true;

  late AnimationController _pulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Audio URLs (Mixkit Child-Friendly Sounds)
  final String _clickSound =
      'audio/class8/mixkit_2568.mp3'; // Pop
  final String _successSound =
      'audio/class8/mixkit_2000.mp3'; // Magic/Cheer
  final String _slideSound =
      'audio/class8/mixkit_2568.mp3'; // Light Tick
  final String _errorSound =
      'audio/class8/mixkit_2003.mp3'; // Arcade Error

  final TextEditingController _estInputController = TextEditingController(
    text: '125',
  );

  // Localization Dictionary (Teacher's Guide Removed)
  final Map<String, Map<String, String>> i18n = {
    'en': {
      'title': "Square Roots & Estimation",
      'subtitle': "Class 8 - A Square and A Cube",
      'modeLbl': "MODE",
      'modes_area': "Visual Root (Area ↔ Side)",
      'modes_est': "Estimation Game",
      'modes_prime': "Prime Pairing (3D)",
      'analysis': "Analysis",
      'obs': "Challenge",
      'rule': "Solution Strategy",
      'explore':
          "<h3>Mission Instructions</h3>\n<b>1. Visual Root:</b> Drag the slider to change the Area. Watch how the Side Length changes. Is it always an integer?\n\n<b>2. Estimation:</b> Input a number (or random) and drag the slider to place the marker where you think its root lies between two integers.\n\n<b>3. Prime Pairing:</b> Group prime factor spheres into pairs to find the root.",
      'areaChallenge':
          "A square handkerchief has an area of {A} sq. units. What is the length of its side?",
      'areaSolPerfect':
          "We need to find √{A}.\nSince {S} × {S} = {A}, the side length is {S}.",
      'areaSolImperfect':
          "We need to find √{A}.\nSince {L}² = {LSQ} and {H}² = {HSQ},\nthe side is between {L} and {H}.\n\n(Exact: ≈ {EXACT})",
      'estChallenge': "Estimate the value of √{T}.",
      'estPrompt':
          "Use the slider to move the orange marker to your guess between {L} and {H}.",
      'estResult':
          "Actual: √{T} ≈ {V}.\nYour Guess: {G}.\nYou were off by {D}.\n\n{MSG}",
      'primeChallenge':
          "Find the square root of {N} using prime factorization.",
      'primeSol': "1. Factors: {F}\n2. Pairs: {P}\n3. Result: {R}",
    },
    'hi': {
      'title': "वर्गमूल और अनुमान",
      'subtitle': "कक्षा 8 - वर्ग और घन",
      'modeLbl': "मोड",
      'modes_area': "दृश्य वर्गमूल (क्षेत्रफल ↔ भुजा)",
      'modes_est': "अनुमान खेल",
      'modes_prime': "अभाज्य गुणनखंड (3D)",
      'analysis': "विश्लेषण",
      'obs': "चुनौती (Challenge)",
      'rule': "समाधान (Solution)",
      'explore':
          "<h3>मिशन निर्देश</h3>\n<b>1. दृश्य वर्गमूल:</b> क्षेत्रफल बदलने के लिए स्लाइडर खींचें। देखें कि भुजा की लंबाई कैसे बदलती है।\n\n<b>2. अनुमान:</b> एक संख्या दर्ज करें और स्लाइडर का उपयोग करके अपना अनुमान लगाएं।\n\n<b>3. अभाज्य जोड़े:</b> मूल खोजने के लिए अभाज्य गुणनखंडों को जोड़े में बांटें।",
      'areaChallenge':
          "एक वर्गाकार रुमाल का क्षेत्रफल {A} वर्ग इकाई है। इसकी भुजा की लंबाई क्या है?",
      'areaSolPerfect':
          "हमें √{A} ज्ञात करना है।\nचूंकि {S} × {S} = {A}, इसलिए भुजा की लंबाई {S} है।",
      'areaSolImperfect':
          "हमें √{A} ज्ञात करना है।\nचूंकि {L}² = {LSQ} और {H}² = {HSQ},\nइसलिए भुजा {L} और {H} के बीच है।\n\n(सटीक: ≈ {EXACT})",
      'estChallenge': "√{T} का अनुमान लगाएं।",
      'estPrompt':
          "{L} और {H} के बीच अपना अनुमान लगाने के लिए स्लाइडर का उपयोग करें।",
      'estResult':
          "वास्तविक: √{T} ≈ {V}.\nआपका अनुमान: {G}.\nअंतर: {D}.\n\n{MSG}",
      'primeChallenge':
          "अभाज्य गुणनखंडन का उपयोग करके {N} का वर्गमूल ज्ञात करें।",
      'primeSol': "1. गुणनखंड: {F}\n2. जोड़े: {P}\n3. परिणाम: {R}",
    },
  };

  String t(String key) => i18n[currentLang]?[key] ?? key;

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
    _estInputController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _changeMode(String mode) {
    _playSound(_clickSound);
    setState(() {
      currentMode = mode;
      if (mode == 'estimation') {
        _resetEstimation();
      }
    });
  }

  void _resetEstimation({int? newVal}) {
    setState(() {
      if (newVal != null) {
        estTargetVal = math.max(2, newVal);
        _estInputController.text = estTargetVal.toString();
      }
      double root = math.sqrt(estTargetVal);
      estLower = root.floor();
      estUpper = estLower + 1;

      // Map slider value 50 to middle
      playerGuess = estLower + 0.5;
      isEstChecked = false;
    });
  }

  void _randomizeEstimation() {
    _playSound(_clickSound);
    int newTarget;
    do {
      newTarget = math.Random().nextInt(195) + 5;
    } while (math.sqrt(newTarget) % 1 == 0); // Avoid perfect squares
    _resetEstimation(newVal: newTarget);
  }

  void _resetLab() {
    _playSound(_clickSound);
    setState(() {
      showCurtain = true;
      currentMode = 'area_side';
      areaValue = 16;
      estTargetVal = 125;
      _estInputController.text = '125';
      _resetEstimation(newVal: 125);
      primeTarget = 36;
      isSidebarOpen = true;
    });
  }

  // --- UI Layout ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double sidebarWidth = math.max(300.0, constraints.maxWidth * 0.3);

            return Stack(
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

                // 2. Center Canvas (Responsive & Zoomable)
                Positioned.fill(
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(2000),
                    minScale: 0.1,
                    maxScale: 4.0,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: currentMode == 'prime_factors'
                          ? _buildPrimeFactorsCanvas(sidebarWidth)
                          : CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: SquareRootsPainter(
                                mode: currentMode,
                                areaValue: areaValue,
                                estTargetVal: estTargetVal,
                                estLower: estLower,
                                estUpper: estUpper,
                                playerGuess: playerGuess,
                                isEstChecked: isEstChecked,
                                isSidebarOpen: isSidebarOpen,
                                sidebarWidth: sidebarWidth,
                              ),
                            ),
                    ),
                  ),
                ),

                // 3. Expandable Sidebar (z-index front)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: isSidebarOpen ? 0 : -sidebarWidth,
                  top: 0,
                  bottom: 0,
                  child: _buildSidebar(sidebarWidth),
                ),

                // 4. Floating Action Buttons (Menu & Back)
                Positioned(
                  top: 10,
                  left: 20,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isSidebarOpen ? Icons.menu_open : Icons.menu,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          _playSound(_clickSound);
                          setState(() => isSidebarOpen = !isSidebarOpen);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          iconSize: 30,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Curtain
                if (showCurtain) _buildCurtainRaiser(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidebar(double width) {
    // Generate Analysis Strings based on current mode
    String obsStr = "";
    String ruleStr = "";
    String expStr = "";

    if (currentMode == 'area_side') {
      double side = math.sqrt(areaValue);
      int root = side.round();
      bool isPerfect = (root * root == areaValue);

      obsStr = t('areaChallenge').replaceAll('{A}', '$areaValue');

      if (isPerfect) {
        ruleStr = "Side = √$areaValue = $root";
        expStr = t(
          'areaSolPerfect',
        ).replaceAll('{A}', '$areaValue').replaceAll('{S}', '$root');
      } else {
        int lower = side.floor();
        int upper = side.ceil();
        ruleStr = "$lower < Side < $upper";
        expStr = t('areaSolImperfect')
            .replaceAll('{A}', '$areaValue')
            .replaceAll('{L}', '$lower')
            .replaceAll('{LSQ}', '${lower * lower}')
            .replaceAll('{H}', '$upper')
            .replaceAll('{HSQ}', '${upper * upper}')
            .replaceAll('{EXACT}', side.toStringAsFixed(2));
      }
    } else if (currentMode == 'estimation') {
      obsStr = t('estChallenge').replaceAll('{T}', '$estTargetVal');

      if (!isEstChecked) {
        ruleStr = "Current Guess: ${playerGuess.toStringAsFixed(2)}";
        expStr = t(
          'estPrompt',
        ).replaceAll('{L}', '$estLower').replaceAll('{H}', '$estUpper');
      } else {
        double exact = math.sqrt(estTargetVal);
        double diff = (playerGuess - exact).abs();
        ruleStr = "$estLower < √$estTargetVal < $estUpper";

        String msg = diff < 0.05 ? "Great Job!" : "Try to get closer!";
        expStr = t('estResult')
            .replaceAll('{T}', '$estTargetVal')
            .replaceAll('{V}', exact.toStringAsFixed(2))
            .replaceAll('{G}', playerGuess.toStringAsFixed(2))
            .replaceAll('{D}', diff.toStringAsFixed(2))
            .replaceAll('{MSG}', msg);
      }
    } else if (currentMode == 'prime_factors') {
      obsStr = t('primeChallenge').replaceAll('{N}', '$primeTarget');
      ruleStr = "√$primeTarget = ${math.sqrt(primeTarget).toInt()}";

      Map<int, String> fMap = {
        36: "2 × 2 × 3 × 3",
        64: "2 × 2 × 2 × 2 × 2 × 2",
        100: "2 × 2 × 5 × 5",
        144: "2 × 2 × 2 × 2 × 3 × 3",
      };
      Map<int, String> pMap = {
        36: "(2 × 2) × (3 × 3)",
        64: "(2²) × (2²) × (2²)",
        100: "(2 × 2) × (5 × 5)",
        144: "(2²) × (2²) × (3²)",
      };
      Map<int, String> rMap = {
        36: "2 × 3 = 6",
        64: "2 × 2 × 2 = 8",
        100: "2 × 5 = 10",
        144: "2 × 2 × 3 = 12",
      };

      expStr = t('primeSol')
          .replaceAll('{F}', fMap[primeTarget]!)
          .replaceAll('{P}', pMap[primeTarget]!)
          .replaceAll('{R}', rMap[primeTarget]!);
    }

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.98),
        border: Border(
          right: BorderSide(color: Colors.cyan.withOpacity(0.5), width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.square_foot,
                      color: Colors.greenAccent,
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
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          t('subtitle'),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Language Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: ['en', 'hi'].map((lang) {
                      bool isActive = currentLang == lang;
                      return GestureDetector(
                        onTap: () {
                          _playSound(_clickSound);
                          setState(() => currentLang = lang);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.cyan.shade700
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.cyan.withOpacity(0.3),
                            ),
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
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: Colors.amberAccent,
                    tooltip: 'Reset Activity',
                    onPressed: _resetLab,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.amber.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24, height: 30),

            // Scrollable Content area with interactive controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mode Selection
                  Text(
                    t('modeLbl'),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueGrey.shade700),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1e293b),
                        value: currentMode,
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'area_side',
                            child: Text(t('modes_area')),
                          ),
                          DropdownMenuItem(
                            value: 'estimation',
                            child: Text(t('modes_est')),
                          ),
                          DropdownMenuItem(
                            value: 'prime_factors',
                            child: Text(t('modes_prime')),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) _changeMode(v);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dynamic Interactive Controls based on mode
                  if (currentMode == 'area_side') ...[
                    Text(
                      "AREA: $areaValue",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Slider(
                      value: areaValue.toDouble(),
                      min: 1,
                      max: 200,
                      divisions: 199,
                      activeColor: Colors.cyan,
                      inactiveColor: Colors.blueGrey,
                      onChanged: (v) => setState(() => areaValue = v.toInt()),
                      onChangeEnd: (v) => _playSound(_slideSound),
                    ),
                  ],

                  if (currentMode == 'estimation') ...[
                    const Text(
                      "TARGET:",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _estInputController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (val) {
                              int? num = int.tryParse(val);
                              if (num != null) {
                                _playSound(_clickSound);
                                _resetEstimation(newVal: num);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.casino),
                          color: Colors.amber,
                          onPressed: _randomizeEstimation,
                          tooltip: "Randomize",
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value:
                          ((playerGuess - estLower) /
                                  (estUpper - estLower) *
                                  100)
                              .clamp(0, 100),
                      min: 0,
                      max: 100,
                      activeColor: Colors.orangeAccent,
                      inactiveColor: Colors.blueGrey,
                      onChanged: (v) {
                        setState(() {
                          playerGuess =
                              estLower + (v / 100) * (estUpper - estLower);
                          isEstChecked = false;
                        });
                      },
                      onChangeEnd: (v) => _playSound(_slideSound),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => isEstChecked = true);
                          double exact = math.sqrt(estTargetVal);
                          double diff = (playerGuess - exact).abs();
                          if (diff < 0.05) {
                            _playSound(_successSound);
                          } else {
                            _playSound(_errorSound);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "CHECK",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (currentMode == 'prime_factors') ...[
                    const Text(
                      "TARGET:",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueGrey.shade700),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1e293b),
                          value: primeTarget,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          items: const [
                            DropdownMenuItem(value: 36, child: Text("36")),
                            DropdownMenuItem(value: 64, child: Text("64")),
                            DropdownMenuItem(value: 100, child: Text("100")),
                            DropdownMenuItem(value: 144, child: Text("144")),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              _playSound(_clickSound);
                              setState(() => primeTarget = v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Target Output / Analysis Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade800),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.analytics,
                              color: Colors.greenAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t('analysis'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t('obs').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          obsStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          t('rule').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueGrey.shade800),
                          ),
                          child: Text(
                            ruleStr,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.cyanAccent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            expStr,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mission Instructions (Explore)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.explore, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Mission Instructions",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('explore')
                              .replaceAll('<h3>Mission Instructions</h3>\n', '')
                              .replaceAll('<b>', '')
                              .replaceAll('</b>', ''),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0f172a),
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
    );
  }

  Widget _buildPrimeFactorsCanvas(double sidebarWidth) {
    Map<int, List<int>> factors = {
      36: [2, 2, 3, 3],
      64: [2, 2, 2, 2, 2, 2],
      100: [2, 2, 5, 5],
      144: [2, 2, 2, 2, 3, 3],
    };

    List<int> arr = factors[primeTarget] ?? [];
    List<Widget> groups = [];

    for (int i = 0; i < arr.length; i += 2) {
      int p = arr[i];
      Color pColor = p == 2
          ? Colors.cyan
          : (p == 3
                ? Colors.green
                : (p == 5 ? Colors.amber : Colors.purpleAccent));

      groups.add(
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: pColor.withOpacity(0.5), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _primeSphere(p, pColor),
                  const SizedBox(width: 8),
                  _primeSphere(p, pColor),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.arrow_downward, color: Colors.white54),
            ),
            _primeSphere(p, pColor, scale: 1.2),
          ],
        ),
      );

      if (i + 2 < arr.length) {
        groups.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "×",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 20,
            children: groups,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: Text(
              "Root = ${math.sqrt(primeTarget).toInt()}",
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primeSphere(int value, Color color, {double scale = 1.0}) {
    return Container(
      width: 40 * scale,
      height: 40 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.4), color],
          center: const Alignment(-0.3, -0.3),
        ),
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)],
      ),
      alignment: Alignment.center,
      child: Text(
        "$value",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16 * scale,
        ),
      ),
    );
  }

  Widget _buildCurtainRaiser() {
    return AnimatedOpacity(
      opacity: showCurtain ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      onEnd: () {
        if (!showCurtain) setState(() {});
      },
      child: SingleChildScrollView(
        child: Container(
          color: const Color(0xFF0f172a),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  double s = 1.0 + (_pulseController.value * 0.1);
                  return Transform.scale(
                    scale: s,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.2 * s),
                            blurRadius: 40 * s,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "√",
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyanAccent,
                            ),
                          ),
                          Text(
                            "?",
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(text: "Square Roots "),
                    TextSpan(
                      text: "& Estimation",
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Master the inverse of squaring through visual puzzles.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  "ENTER COSMIC LAB",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _playSound(_successSound);
                  setState(() => showCurtain = false);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  backgroundColor: Colors.cyan.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  shadowColor: Colors.cyanAccent,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Native Pseudo-3D Isometric Painter ---
class SquareRootsPainter extends CustomPainter {
  final String mode;
  final int areaValue;
  final int estTargetVal;
  final int estLower;
  final int estUpper;
  final double playerGuess;
  final bool isEstChecked;
  final bool isSidebarOpen;
  final double sidebarWidth;

  SquareRootsPainter({
    required this.mode,
    required this.areaValue,
    required this.estTargetVal,
    required this.estLower,
    required this.estUpper,
    required this.playerGuess,
    required this.isEstChecked,
    required this.isSidebarOpen,
    required this.sidebarWidth,
  });

  void _drawIsometricBlock(
    Canvas canvas,
    Offset origin,
    double x,
    double y,
    double z,
    double w,
    double h,
    double d,
    double scale,
    Color baseColor,
  ) {
    double cos30 = math.cos(math.pi / 6);
    double sin30 = math.sin(math.pi / 6);

    Offset vx = Offset(scale * cos30, scale * sin30);
    Offset vz = Offset(-scale * cos30, scale * sin30);
    Offset vy = Offset(0, -scale);

    Offset c =
        origin +
        Offset(x * vx.dx + z * vz.dx, x * vx.dy + z * vz.dy + y * vy.dy);

    Path rightFace = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx + vx.dx * w, c.dy + vx.dy * w)
      ..lineTo(c.dx + vx.dx * w + vy.dx * h, c.dy + vx.dy * w + vy.dy * h)
      ..lineTo(c.dx + vy.dx * h, c.dy + vy.dy * h)
      ..close();

    Path leftFace = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx + vz.dx * d, c.dy + vz.dy * d)
      ..lineTo(c.dx + vz.dx * d + vy.dx * h, c.dy + vz.dy * d + vy.dy * h)
      ..lineTo(c.dx + vy.dx * h, c.dy + vy.dy * h)
      ..close();

    Offset cTop = c + vy * h;
    Path topFace = Path()
      ..moveTo(cTop.dx, cTop.dy)
      ..lineTo(cTop.dx + vx.dx * w, cTop.dy + vx.dy * w)
      ..lineTo(cTop.dx + vx.dx * w + vz.dx * d, cTop.dy + vx.dy * w + vz.dy * d)
      ..lineTo(cTop.dx + vz.dx * d, cTop.dy + vz.dy * d)
      ..close();

    Paint facePaint = Paint()..style = PaintingStyle.fill;
    Paint edgePaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    facePaint.color = _darken(baseColor, 20);
    canvas.drawPath(leftFace, facePaint);
    canvas.drawPath(leftFace, edgePaint);

    facePaint.color = baseColor;
    canvas.drawPath(rightFace, facePaint);
    canvas.drawPath(rightFace, edgePaint);

    facePaint.color = _lighten(baseColor, 20);
    canvas.drawPath(topFace, facePaint);
    canvas.drawPath(topFace, edgePaint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double size = 16,
    Color color = Colors.white,
    bool bg = false,
  }) {
    final textPainter = TextPainter(
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
    textPainter.layout();

    if (bg) {
      canvas.drawRect(
        Rect.fromCenter(
          center: position,
          width: textPainter.width + 12,
          height: textPainter.height + 6,
        ),
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill,
      );
    }
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  Color _lighten(Color c, [int percent = 15]) {
    var p = percent / 100;
    return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round(),
    );
  }

  Color _darken(Color c, [int percent = 15]) {
    var p = 1 - percent / 100;
    return Color.fromARGB(
      c.alpha,
      (c.red * p).round(),
      (c.green * p).round(),
      (c.blue * p).round(),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Dynamic centering accounting for sidebar width
    double centerX = isSidebarOpen
        ? (size.width + sidebarWidth) / 2
        : size.width / 2;

    if (mode == 'area_side') {
      double root = math.sqrt(areaValue);
      double scale =
          math.min(size.width, size.height) * 0.4 / math.max(5, root);
      Offset origin = Offset(centerX, size.height / 2 + (root * scale * 0.25));

      // Draw flat square block
      _drawIsometricBlock(
        canvas,
        origin,
        -root / 2,
        0,
        -root / 2,
        root,
        0.4,
        root,
        scale,
        Colors.cyan,
      );

      // Area Label
      _drawText(
        canvas,
        "Area = $areaValue",
        origin + const Offset(0, -60),
        size: 24,
        bg: true,
      );

      // Dimension Line & Label for Side
      Offset p1 =
          origin +
          Offset(
            root / 2 * scale * math.cos(math.pi / 6),
            root / 2 * scale * math.sin(math.pi / 6),
          );
      Offset p2 =
          origin +
          Offset(
            -root / 2 * scale * math.cos(math.pi / 6),
            root / 2 * scale * math.sin(math.pi / 6),
          );

      Paint linePaint = Paint()
        ..color = Colors.cyanAccent
        ..strokeWidth = 2;
      canvas.drawLine(
        p1 + const Offset(0, 30),
        p2 + const Offset(0, 30),
        linePaint,
      );
      canvas.drawLine(
        p1 + const Offset(0, 20),
        p1 + const Offset(0, 40),
        linePaint,
      );
      canvas.drawLine(
        p2 + const Offset(0, 20),
        p2 + const Offset(0, 40),
        linePaint,
      );

      _drawText(
        canvas,
        "Side = ${root.toStringAsFixed(2)}",
        (p1 + p2) / 2 + const Offset(0, 50),
        color: Colors.cyanAccent,
        bg: true,
      );
    } else if (mode == 'estimation') {
      Offset origin = Offset(centerX, size.height * 0.75);

      // Draw Base Line
      Paint basePaint = Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 3;
      canvas.drawLine(
        origin + const Offset(-250, 0),
        origin + const Offset(250, 0),
        basePaint,
      );

      // Map positions linearly across screen for clarity in 2D
      double xLeft = -200;
      double xRight = 200;

      // Left Panel (Lower Bound Square)
      _drawStandingPanel(
        canvas,
        origin + Offset(xLeft, 0),
        estLower.toDouble(),
        Colors.cyan,
      );
      _drawText(
        canvas,
        "A=${estLower * estLower}",
        origin + Offset(xLeft, -estLower * 5 - 20),
        bg: true,
      );
      _drawText(
        canvas,
        "$estLower",
        origin + Offset(xLeft, 20),
        color: Colors.cyanAccent,
      );

      // Right Panel (Upper Bound Square)
      _drawStandingPanel(
        canvas,
        origin + Offset(xRight, 0),
        estUpper.toDouble(),
        Colors.purpleAccent,
      );
      _drawText(
        canvas,
        "A=${estUpper * estUpper}",
        origin + Offset(xRight, -estUpper * 5 - 20),
        bg: true,
      );
      _drawText(
        canvas,
        "$estUpper",
        origin + Offset(xRight, 20),
        color: Colors.purpleAccent,
      );

      // Target Panel (Hidden until check)
      double exactRoot = math.sqrt(estTargetVal);
      double exactFrac = (exactRoot - estLower) / (estUpper - estLower);
      double xTarget = xLeft + (xRight - xLeft) * exactFrac;

      if (isEstChecked) {
        _drawStandingPanel(
          canvas,
          origin + Offset(xTarget, 0),
          exactRoot,
          Colors.amber,
        );
        _drawText(
          canvas,
          "A=$estTargetVal",
          origin + Offset(xTarget, -exactRoot * 5 - 35),
          color: Colors.amberAccent,
          bg: true,
        );
        _drawText(
          canvas,
          "≈${exactRoot.toStringAsFixed(2)}",
          origin + Offset(xTarget, 35),
          color: Colors.amberAccent,
        );
      }

      // Player Marker
      double guessFrac = (playerGuess - estLower) / (estUpper - estLower);
      double xGuess = xLeft + (xRight - xLeft) * guessFrac;

      _drawCone(canvas, origin + Offset(xGuess, -10), Colors.orange);
      _drawText(
        canvas,
        "Guess",
        origin + Offset(xGuess, -40),
        color: Colors.orangeAccent,
        size: 14,
        bg: true,
      );
    }
  }

  void _drawStandingPanel(
    Canvas canvas,
    Offset bottomCenter,
    double val,
    Color c,
  ) {
    double h = val * 5; // Scale for visuals
    double w = h;
    Rect rect = Rect.fromCenter(
      center: bottomCenter + Offset(0, -h / 2),
      width: w,
      height: h,
    );

    Paint fill = Paint()
      ..color = c.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    Paint stroke = Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, stroke);
  }

  void _drawCone(Canvas canvas, Offset tip, Color c) {
    Path path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - 10, tip.dy - 20)
      ..lineTo(tip.dx + 10, tip.dy - 20)
      ..close();
    canvas.drawPath(path, Paint()..color = c);
  }

  @override
  bool shouldRepaint(covariant SquareRootsPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.areaValue != areaValue ||
        oldDelegate.playerGuess != playerGuess ||
        oldDelegate.isEstChecked != isEstChecked ||
        oldDelegate.estTargetVal != estTargetVal ||
        oldDelegate.isSidebarOpen != isSidebarOpen ||
        oldDelegate.sidebarWidth != sidebarWidth;
  }
}
