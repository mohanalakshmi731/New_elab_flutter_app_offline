// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class CubicNumbersLab extends StatefulWidget {
  const CubicNumbersLab({Key? key}) : super(key: key);

  @override
  State<CubicNumbersLab> createState() => _CubicNumbersLabState();
}

class _CubicNumbersLabState extends State<CubicNumbersLab>
    with TickerProviderStateMixin {
  // Application State
  String currentLang = 'en';
  String currentMode = 'builder'; // builder, ramanujan, roots
  int builderN = 3;
  int rootTarget = 64;

  bool showCurtain = true;
  bool isSidebarOpen = true; // Sidebar toggle state
  bool isExploded = false;

  late AnimationController _explodeController;
  late Animation<double> _explodeAnim;
  late AudioPlayer _audioPlayer;

  // Localization Dictionary
  final Map<String, Map<String, String>> i18n = {
    'en': {
      'title': "Cubic Numbers",
      'subtitle': "Class 8 - A Square and A Cube",
      'modeLbl': "MODE",
      'sideN': "SIDE (N)",
      'btnExplode': "EXPLODE",
      'modes_builder': "Cube Builder (Volume)",
      'modes_ramanujan': "Hardy-Ramanujan (1729)",
      'modes_roots': "Cube Roots (Prime Triplets)",
      'analysis': "Analyze Result",
      'obs': "Challenge",
      'rule': "Solution",
      'explore':
          "Mission Instructions:\n1. Cube Builder: Build a cube of side N. Use 'Explode' to see the layers.\n2. 1729: Compare two sets of cubes. Do they have the same volume?\n3. Cube Roots: Group prime factors into triplets (sets of 3) to find the root.",
      'builderChallenge':
          "Build a cube with side N={N}. What is its total volume?",
      'builderSol': "Volume V = N × N × N\nV = N³ = {T} unit cubes.",
      'ramChallenge':
          "Verify that 1729 is the sum of two cubes in two different ways.",
      'ramSol':
          "Set A: 1³ + 12³ = 1 + 1728 = 1729\nSet B: 9³ + 10³ = 729 + 1000 = 1729",
      'rootChallenge': "Find the cube root of {N} using prime factorization.",
      'rootSol': "1. Factors: {F}\n2. Triplets: {P}\n3. Result: {R}",
    },
    'hi': {
      'title': "घन संख्याएँ",
      'subtitle': "कक्षा 8 - वर्ग और घन",
      'modeLbl': "मोड",
      'sideN': "भुजा (N)",
      'btnExplode': "विस्फोट",
      'modes_builder': "घन निर्माता (आयतन)",
      'modes_ramanujan': "हार्डी-रामानुजन (1729)",
      'modes_roots': "घनमूल (अभाज्य त्रिक)",
      'analysis': "परिणाम का विश्लेषण करें",
      'obs': "चुनौती (Challenge)",
      'rule': "समाधान (Solution)",
      'explore':
          "मिशन निर्देश:\n1. घन निर्माता: N भुजा वाला घन बनाएं। परतों को देखने के लिए 'विस्फोट' का उपयोग करें।\n2. 1729: घनों के दो सेटों की तुलना करें। क्या उनका आयतन समान है?\n3. घनमूल: मूल ज्ञात करने के लिए अभाज्य गुणनखंडों को त्रिकों (3 के समूह) में समूहित करें।",
      'builderChallenge': "N={N} भुजा वाला एक घन बनाएं। इसका कुल आयतन क्या है?",
      'builderSol': "आयतन V = N × N × N\nV = N³ = {T} इकाई घन।",
      'ramChallenge':
          "सत्यापित करें कि 1729 दो अलग-अलग तरीकों से दो घनों का योग है।",
      'ramSol':
          "सेट A: 1³ + 12³ = 1 + 1728 = 1729\nसेट B: 9³ + 10³ = 729 + 1000 = 1729",
      'rootChallenge': "अभाज्य गुणनखंडन का उपयोग करके {N} का घनमूल ज्ञात करें।",
      'rootSol': "1. गुणनखंड: {F}\n2. त्रिक: {P}\n3. परिणाम: {R}",
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

    _audioPlayer = AudioPlayer();

    _explodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _explodeAnim = CurvedAnimation(
      parent: _explodeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _explodeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- Interaction Feedback Helpers ---
  Future<void> _playSound(String type) async {
    try {
      String url = '';
      if (type == 'click') {
        url =
            'audio/class8/mixkit_2568.mp3';
      } else if (type == 'explode') {
        url =
            'audio/class8/mixkit_2003.mp3';
      } else if (type == 'mode') {
        url =
            'audio/class8/mixkit_2568.mp3';
      } else if (type == 'success') {
        url =
            'audio/class8/mixkit_2018.mp3';
      } else if (type == 'start') {
        url =
            'audio/class8/mixkit_2018.mp3'; // Level start tune
      }

      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
  }

  void _toggleExplode() {
    _playSound('explode');
    if (isExploded) {
      _explodeController.reverse();
    } else {
      _explodeController.forward();
    }
    setState(() {
      isExploded = !isExploded;
    });
  }

  void _changeMode(String mode) {
    _playSound('mode');
    setState(() {
      currentMode = mode;
      isExploded = false;
      _explodeController.reset();
    });
  }

  void _showSuccessPopup(String challengeStr, String solStr) {
    _playSound('success');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Text(
                t('title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t('obs').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  challengeStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t('rule').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  child: Text(
                    solStr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playSound('click');
                Navigator.of(ctx).pop();
              },
              child: const Text(
                "AWESOME",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- UI Layout ---
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = max(
      screenWidth * 0.3,
      300.0,
    ); // 30% width with a safe minimum

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Background Layer
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

            // Canvas Layer (Responsive Shift)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: Center(child: _buildCanvas()),
              ),
            ),

            // Left Sidebar Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Material(
                elevation: 16,
                color: const Color(0xFF1e293b).withOpacity(0.95),
                child: _buildSidebarContent(),
              ),
            ),

            // Top Left Floating Controls (Fixed Position, top of the stack)
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu),
                    iconSize: 30,
                    color: Colors.white,
                    onPressed: () {
                      _playSound('click');
                      setState(() => isSidebarOpen = !isSidebarOpen);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Full-screen introductory curtain
            if (showCurtain) _buildCurtainRaiser(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    // Generate Target Output Strings
    String challengeStr = "";
    String solStr = "";

    if (currentMode == 'builder') {
      int vol = builderN * builderN * builderN;
      challengeStr = t('builderChallenge').replaceAll('{N}', '$builderN');
      solStr = t('builderSol').replaceAll('{T}', '$vol');
    } else if (currentMode == 'ramanujan') {
      challengeStr = t('ramChallenge');
      solStr = t('ramSol');
    } else if (currentMode == 'roots') {
      challengeStr = t('rootChallenge').replaceAll('{N}', '$rootTarget');
      String fMap = rootTarget == 64
          ? "2×2×2 × 2×2×2"
          : rootTarget == 216
          ? "2×2×2 × 3×3×3"
          : "3×3×3 × 5×5×5";
      String pMap = rootTarget == 64
          ? "(2×2×2) × (2×2×2)"
          : rootTarget == 216
          ? "(2×2×2) × (3×3×3)"
          : "(3×3×3) × (5×5×5)";
      String rMap = rootTarget == 64
          ? "2 × 2 = 4"
          : rootTarget == 216
          ? "2 × 3 = 6"
          : "3 × 5 = 15";
      solStr = t(
        'rootSol',
      ).replaceAll('{F}', fMap).replaceAll('{P}', pMap).replaceAll('{R}', rMap);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Header (Scrolls with the rest of the body)
          Container(
            padding: const EdgeInsets.only(
              top: 80, // Prevent overlap with fixed Top-Left controls
              left: 16,
              right: 16,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0f172a),
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey.shade900),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.view_in_ar,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
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
                      ),
                      Text(
                        t('subtitle'),
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Sidebar Body Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language Toggle & Reset Button Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f172a),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.cyan.withOpacity(0.5),
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: ['en', 'hi'].map((lang) {
                            bool isActive = currentLang == lang;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _playSound('click');
                                  setState(() => currentLang = lang);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
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
                                      color: isActive
                                          ? Colors.white
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
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text(
                          "RESET",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _playSound('click');
                          setState(() {
                            // Completely reset the activity state
                            showCurtain = true;
                            currentLang = 'en';
                            currentMode = 'builder';
                            builderN = 3;
                            rootTarget = 64;
                            isSidebarOpen = true;
                            isExploded = false;
                            _explodeController.reset();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          backgroundColor: Colors.blueGrey.shade800,
                          foregroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Mode Selector
                Text(
                  t('modeLbl').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade700),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: const Color(0xFF1e293b),
                      isExpanded: true,
                      value: currentMode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'builder',
                          child: Text(t('modes_builder')),
                        ),
                        DropdownMenuItem(
                          value: 'ramanujan',
                          child: Text(t('modes_ramanujan')),
                        ),
                        DropdownMenuItem(
                          value: 'roots',
                          child: Text(t('modes_roots')),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) _changeMode(v);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Contextual Controls (Builder)
                if (currentMode == 'builder') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('sideN'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$builderN",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: builderN.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.blueGrey,
                    onChangeEnd: (v) => _playSound('click'),
                    onChanged: (v) => setState(() => builderN = v.toInt()),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_full, size: 16),
                    label: Text(
                      t('btnExplode'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _toggleExplode,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.cyan.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],

                // Contextual Controls (Roots)
                if (currentMode == 'roots') ...[
                  const Text(
                    "TARGET CUBE",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade700),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        dropdownColor: const Color(0xFF1e293b),
                        isExpanded: true,
                        value: rootTarget,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        items: const [
                          DropdownMenuItem(value: 64, child: Text("64 (4³)")),
                          DropdownMenuItem(value: 216, child: Text("216 (6³)")),
                          DropdownMenuItem(
                            value: 3375,
                            child: Text("3375 (15³)"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            _playSound('click');
                            setState(() => rootTarget = v);
                          }
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Target Output / Goal Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey.shade800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                        challengeStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.analytics, size: 16),
                        label: Text(t('analysis')),
                        onPressed: () =>
                            _showSuccessPopup(challengeStr, solStr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),

                // Mission Instructions (Footer)
                Text(
                  t('explore'),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Mode Specific Visuals
            if (currentMode == 'builder' || currentMode == 'ramanujan')
              AnimatedBuilder(
                animation: _explodeAnim,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: IsometricCubePainter(
                      mode: currentMode,
                      n: builderN,
                      explodeFactor: _explodeAnim.value,
                    ),
                  );
                },
              ),

            if (currentMode == 'roots') _buildRootsCanvas(),
          ],
        );
      },
    );
  }

  Widget _buildRootsCanvas() {
    // Determine primes based on selection
    List<int> primes = [];
    if (rootTarget == 64) primes = [2, 2, 2, 2, 2, 2];
    if (rootTarget == 216) primes = [2, 2, 2, 3, 3, 3];
    if (rootTarget == 3375) primes = [3, 3, 3, 5, 5, 5];

    List<Widget> groups = [];
    for (int i = 0; i < primes.length; i += 3) {
      int p = primes[i];
      Color pColor = p == 2
          ? Colors.cyan
          : (p == 3 ? Colors.green : Colors.pinkAccent);

      groups.add(
        Column(
          mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(width: 8),
                  _primeSphere(p, pColor),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.arrow_downward, color: Colors.white54),
            ),
            _primeSphere(p, pColor, scale: 1.5),
          ],
        ),
      );

      if (i + 3 < primes.length) {
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: groups,
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
      child: Container(
        color: const Color(0xFF0f172a),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.view_in_ar, color: Colors.cyanAccent, size: 80),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: "Cubic "),
                  TextSpan(
                    text: "Numbers",
                    style: TextStyle(color: Colors.amber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Explore volume, cube roots, and the mystery of 1729.",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                "ENTER COSMIC LAB",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _playSound('start'); // Trigger the new start tone
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
          ],
        ),
      ),
    );
  }
}

// --- Isometric 2D Native Custom Painter ---
class IsometricCubePainter extends CustomPainter {
  final String mode;
  final int n;
  final double explodeFactor;

  IsometricCubePainter({
    required this.mode,
    required this.n,
    required this.explodeFactor,
  });

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

  void _drawIsometricCube(
    Canvas canvas,
    Offset origin,
    double x,
    double y,
    double z,
    double size,
    double yOffset,
    Color baseColor,
  ) {
    double cos30 = cos(pi / 6);
    double sin30 = sin(pi / 6);

    Offset vx = Offset(size * cos30, size * sin30);
    Offset vz = Offset(-size * cos30, size * sin30);
    Offset vy = Offset(0, -size);

    Offset c =
        origin +
        Offset(x * vx.dx + z * vz.dx, x * vx.dy + z * vz.dy + y * vy.dy) +
        Offset(0, -yOffset);

    Path rightFace = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx + vx.dx, c.dy + vx.dy)
      ..lineTo(c.dx + vx.dx + vy.dx, c.dy + vx.dy + vy.dy)
      ..lineTo(c.dx + vy.dx, c.dy + vy.dy)
      ..close();

    Path leftFace = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx + vz.dx, c.dy + vz.dy)
      ..lineTo(c.dx + vz.dx + vy.dx, c.dy + vz.dy + vy.dy)
      ..lineTo(c.dx + vy.dx, c.dy + vy.dy)
      ..close();

    Offset cTop = c + vy;
    Path topFace = Path()
      ..moveTo(cTop.dx, cTop.dy)
      ..lineTo(cTop.dx + vx.dx, cTop.dy + vx.dy)
      ..lineTo(cTop.dx + vx.dx + vz.dx, cTop.dy + vx.dy + vz.dy)
      ..lineTo(cTop.dx + vz.dx, cTop.dy + vz.dy)
      ..close();

    Paint facePaint = Paint()..style = PaintingStyle.fill;
    Paint edgePaint = Paint()
      ..color = Colors.black38
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
    double size = 20,
    Color color = Colors.white,
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
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == 'builder') {
      double cubeSize = (size.height * 0.4) / n;
      Offset origin = Offset(size.width / 2, size.height * 0.75);

      for (int y = 0; y < n; y++) {
        double yOffset = y * explodeFactor * cubeSize * 1.5;
        for (int x = 0; x < n; x++) {
          for (int z = 0; z < n; z++) {
            Color baseColor = ((x + y + z) % 2 == 0)
                ? Colors.amber.shade500
                : Colors.amber.shade300;
            _drawIsometricCube(
              canvas,
              origin,
              x.toDouble(),
              y.toDouble(),
              z.toDouble(),
              cubeSize,
              yOffset,
              baseColor,
            );
          }
        }
      }

      if (explodeFactor < 0.1) {
        _drawText(
          canvas,
          "Side = $n",
          origin + const Offset(0, 40),
          size: 16,
          color: Colors.white70,
        );
      }
    } else if (mode == 'ramanujan') {
      double cy = size.height * 0.75;

      Offset orgA1 = Offset(size.width * 0.2, cy);
      _drawIsometricCube(canvas, orgA1, 0, 0, 0, 20, 0, Colors.amber);
      _drawText(canvas, "1³", orgA1 + const Offset(0, -40));

      Offset orgA12 = Offset(size.width * 0.35, cy);
      _drawIsometricCube(canvas, orgA12, 0, 0, 0, 100, 0, Colors.blue);
      _drawText(canvas, "12³", orgA12 + const Offset(0, -130));

      _drawText(
        canvas,
        "1³ + 12³ = 1729",
        Offset(size.width * 0.275, cy + 40),
        color: Colors.cyanAccent,
      );

      _drawText(canvas, "+", Offset(size.width * 0.5, cy - 50), size: 30);

      Offset orgB9 = Offset(size.width * 0.65, cy);
      _drawIsometricCube(canvas, orgB9, 0, 0, 0, 75, 0, Colors.green);
      _drawText(canvas, "9³", orgB9 + const Offset(0, -100));

      Offset orgB10 = Offset(size.width * 0.85, cy);
      _drawIsometricCube(canvas, orgB10, 0, 0, 0, 85, 0, Colors.purple);
      _drawText(canvas, "10³", orgB10 + const Offset(0, -110));

      _drawText(
        canvas,
        "9³ + 10³ = 1729",
        Offset(size.width * 0.75, cy + 40),
        color: Colors.cyanAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant IsometricCubePainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.n != n ||
        oldDelegate.explodeFactor != explodeFactor;
  }
}
