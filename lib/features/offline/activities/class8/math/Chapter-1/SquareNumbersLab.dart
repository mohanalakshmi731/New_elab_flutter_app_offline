// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SquareNumbersApp());
}

// Custom Scroll Behavior to ensure Mouse and Trackpad dragging works smoothly
class CanvasScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class SquareNumbersApp extends StatelessWidget {
  const SquareNumbersApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Square Numbers Lab',
      scrollBehavior: CanvasScrollBehavior(),
      home: const SquareNumbersLab(),
    );
  }
}

class SquareNumbersLab extends StatefulWidget {
  const SquareNumbersLab({Key? key}) : super(key: key);

  @override
  State<SquareNumbersLab> createState() => _SquareNumbersLabState();
}

class _SquareNumbersLabState extends State<SquareNumbersLab>
    with TickerProviderStateMixin {
  // Application State
  String currentLang = 'en';
  String currentMode = 'square'; // square, cube, locker
  int currentValue = 1; // N for square/cube

  // Layout State
  bool showCurtain = true;
  bool leftSidebarOpen = false;

  // Locker Mode State
  bool simulationRunning = false;
  bool simulationDone = false;
  int currentPerson = 0;
  List<bool> lockerStates = List.filled(100, false);

  late AnimationController _pulseController;

  // Audio Players & Network Sources
  // Initializing with ReleaseMode.stop prevents memory exhaustion crashes
  final AudioPlayer _uiPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _simPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  final String audioClick =
      'audio/class8/mixkit_2568.mp3';
  final String audioToggle =
      'audio/class8/mixkit_2568.mp3';
  final String audioSuccess =
      'audio/class8/mixkit_2000.mp3';

  // Localization Dictionary (Teacher Tab Removed)
  final Map<String, Map<String, String>> i18n = {
    'en': {
      'title': "Square Numbers & Factors",
      'subtitle': "Chapter 1: A Square and A Cube",
      'modeLbl': "MODE",
      'valueLbl': "VALUE (N)",
      'modes_square': "Square Patterns",
      'modes_cube': "Cube Building",
      'modes_locker': "Locker Puzzle",
      'runSim': "RUN SIMULATION",
      'reset': "RESET",
      'analysis': "Analysis",
      'exploreTitle': "Mission Instructions",
      'exploreInst':
          "1. Square Mode: Drag the slider to grow the square. Observe the 'L-Shape' color pattern.\n\n2. Cube Mode: Visualize volume. See how rapidly N³ grows compared to N².\n\n3. Locker Puzzle: 100 lockers. 100 people. Person K toggles every Kth locker. Which remain open?",
      'math_geo': "Geometric Proof",
      'math_currN': "Current N",
      'math_lockerTitle': "Locker Analysis",
      'math_openLockers': "Open Lockers (Perfect Squares):",
    },
    'hi': {
      'title': "वर्ग संख्याएँ और गुणनखंड",
      'subtitle': "अध्याय 1: वर्ग और घन",
      'modeLbl': "मोड",
      'valueLbl': "भुजा (N)",
      'modes_square': "वर्ग पैटर्न",
      'modes_cube': "घन निर्माण",
      'modes_locker': "लॉकर पहेली",
      'runSim': "सिमुलेशन चलाएं",
      'reset': "रीसेट",
      'analysis': "विश्लेषण",
      'exploreTitle': "निर्देश",
      'exploreInst':
          "1. वर्ग मोड: वर्ग बढ़ाने के लिए स्लाइडर खींचें।\n\n2. घन मोड: आयतन (Volume) को देखें।\n\n3. लॉकर पहेली: 100 लॉकर। 100 लोग। कौन से लॉकर खुले रहते हैं?",
      'math_geo': "ज्यामितीय प्रमाण",
      'math_currN': "वर्तमान N",
      'math_lockerTitle': "लॉकर विश्लेषण",
      'math_openLockers': "खुले लॉकर (पूर्ण वर्ग):",
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

    // Preload simulation toggle audio for rapid firing
    _simPlayer.setSource(AssetSource(audioToggle));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseController.dispose();
    _uiPlayer.dispose();
    _simPlayer.dispose();
    super.dispose();
  }

  void _playSound(String url, {bool isSim = false}) async {
    try {
      if (isSim) {
        if (_simPlayer.state == PlayerState.playing) await _simPlayer.stop();
        await _simPlayer.play(AssetSource(url));
      } else {
        if (_uiPlayer.state == PlayerState.playing) await _uiPlayer.stop();
        await _uiPlayer.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _changeMode(String mode) {
    _playSound(audioClick);
    setState(() {
      currentMode = mode;
      if (mode == 'locker') {
        simulationRunning = false;
        simulationDone = false;
        currentPerson = 0;
        lockerStates.fillRange(0, 100, false);
      } else if (mode == 'square') {
        currentValue = math.min(10, currentValue);
      } else if (mode == 'cube') {
        currentValue = math.min(8, currentValue);
      }
    });
  }

  void _resetActivity() {
    _playSound(audioClick);
    setState(() {
      showCurtain = true;
      leftSidebarOpen = false;
      currentMode = 'square';
      currentValue = 1;
      simulationRunning = false;
      simulationDone = false;
      currentPerson = 0;
      lockerStates.fillRange(0, 100, false);
    });
  }

  Future<void> _toggleSimulation() async {
    _playSound(audioClick);

    if (simulationRunning || simulationDone) {
      setState(() {
        simulationRunning = false;
        simulationDone = false;
        currentPerson = 0;
        lockerStates.fillRange(0, 100, false);
      });
      return;
    }

    setState(() {
      simulationRunning = true;
      simulationDone = false;
    });

    for (int person = 1; person <= 100; person++) {
      if (!simulationRunning || !mounted) {
        break; // CRITICAL: Stop loop if app closes or resets
      }

      setState(() => currentPerson = person);

      for (int L = person; L <= 100; L += person) {
        if (!simulationRunning || !mounted) {
          break; // CRITICAL: Prevent setState crash after dispose
        }
        setState(() {
          lockerStates[L - 1] = !lockerStates[L - 1];
        });
        _playSound(audioToggle, isSim: true);
        await Future.delayed(const Duration(milliseconds: 30));
      }

      if (!simulationRunning || !mounted) break;
      await Future.delayed(const Duration(milliseconds: 150));
    }

    if (simulationRunning && mounted) {
      setState(() {
        simulationDone = true;
        simulationRunning = false;
      });
      _playSound(audioSuccess);
      _showSuccessPopup();
    }
  }

  void _showSuccessPopup() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
              const SizedBox(width: 10),
              Text(
                t('math_lockerTitle'),
                style: const TextStyle(color: Colors.cyanAccent),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('math_openLockers'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                    ),
                    child: const Text(
                      "1, 4, 9, 16, 25, 36, 49, 64, 81, 100",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentLang == 'en'
                        ? "Only numbers with an Odd Number of Factors remain open. These are exactly the Perfect Squares!"
                        : "केवल विषम संख्या वाले गुणनखंड ही खुले रहते हैं। ये पूर्ण वर्ग हैं!",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _playSound(audioClick);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text("AWESOME!"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sidebarWidth = math.max(
      320.0,
      size.width * 0.3,
    ); // Responsive 30% width

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Stack(
        children: [
          // 1. Background Gradient
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

          // 2. Zoomable Center Canvas
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  minScale: 0.2,
                  maxScale: 5.0,
                  boundaryMargin: EdgeInsets.all(
                    constraints.maxWidth,
                  ), // Safe infinite pan margins
                  panEnabled: true,
                  scaleEnabled: true,
                  child: Center(
                    child: Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      // CRITICAL: Invisible color acts as a hit-test catcher, allowing drag and zoom
                      color: Colors.black.withOpacity(0.001),
                      child: CustomPaint(
                        painter: SquaresCubesPainter(
                          mode: currentMode,
                          n: currentValue,
                          lockerStates: lockerStates,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Curtain Raiser
          if (showCurtain) _buildCurtainRaiser(),

          // 4. Front Layer Sidebar (Scrollable & Unified)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: leftSidebarOpen ? 0 : -sidebarWidth,
            width: sidebarWidth,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b).withOpacity(0.95),
                border: Border(
                  right: BorderSide(color: Colors.blueGrey.shade800, width: 2),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(5, 0),
                  ),
                ],
              ),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSidebarHeader(),
                        const Divider(color: Colors.blueGrey, height: 1),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildExploreCard(),
                                const SizedBox(height: 20),
                                _buildControlsSection(),
                                const SizedBox(height: 20),
                                _buildAnalysisSection(),
                              ],
                            ),
                          ),
                        ),
                        const Divider(color: Colors.blueGrey, height: 1),
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.black12,
                          child: const Text(
                            "© ZeroScienceLab - Fall in love with math and Science",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Floating Top-Left Buttons (ALWAYS on front z-index)
          // FIXED: Menu icon only shows up after the curtain is lifted.
          if (!showCurtain)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _buildFloatingBtn(
                        leftSidebarOpen ? Icons.menu_open : Icons.menu,
                        () {
                          _playSound(audioClick);
                          setState(() => leftSidebarOpen = !leftSidebarOpen);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingBtn(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.cyanAccent),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 70.0,
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.view_in_ar,
                  color: Colors.cyanAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('title').split(' & ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      t('subtitle'),
                      style: const TextStyle(
                        color: Colors.cyanAccent,
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
          const SizedBox(height: 16),
          // Language Toggle & Reset Button
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: ['en', 'hi'].map((lang) {
                      bool isActive = currentLang == lang;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _playSound(audioClick);
                            setState(() => currentLang = lang);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.cyan.shade700
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lang.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.restart_alt,
                    color: Colors.amberAccent,
                  ),
                  tooltip: "Reset Activity",
                  onPressed: _resetActivity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade900.withOpacity(0.15),
        border: Border.all(color: Colors.amber.shade700.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                t('exploreTitle'),
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t('exploreInst'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('modeLbl'),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
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
                  value: 'square',
                  child: Text(t('modes_square')),
                ),
                DropdownMenuItem(value: 'cube', child: Text(t('modes_cube'))),
                DropdownMenuItem(
                  value: 'locker',
                  child: Text(t('modes_locker')),
                ),
              ],
              onChanged: (v) {
                if (v != null) _changeMode(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (currentMode == 'square' || currentMode == 'cube') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('valueLbl'),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$currentValue",
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.cyan,
              inactiveTrackColor: Colors.blueGrey,
              thumbColor: Colors.cyanAccent,
              overlayColor: Colors.cyan.withOpacity(0.2),
            ),
            child: Slider(
              value: currentValue.toDouble(),
              min: 1,
              max: currentMode == 'square' ? 10 : 8,
              divisions: currentMode == 'square' ? 9 : 7,
              onChanged: (v) => setState(() => currentValue = v.toInt()),
              onChangeEnd: (v) => _playSound(audioClick),
            ),
          ),
        ],

        if (currentMode == 'locker') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(
                simulationRunning || simulationDone
                    ? Icons.refresh
                    : Icons.play_arrow,
                size: 18,
              ),
              label: Text(
                simulationRunning || simulationDone ? t('reset') : t('runSim'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _toggleSimulation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: simulationRunning
                    ? Colors.blueGrey
                    : Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalysisSection() {
    String nStr = "";
    String ruleStr = "";
    String expStr = "";

    if (currentMode == 'square') {
      nStr = "N = $currentValue";
      int total = 0;
      List<String> odds = [];
      for (int i = 0; i < currentValue; i++) {
        int odd = 2 * i + 1;
        odds.add(odd.toString());
        total += odd;
      }
      if (currentValue <= 5) {
        ruleStr = "${odds.join(' + ')} = $currentValue² = $total";
      } else {
        ruleStr =
            "1 + 3 + ... + ${2 * currentValue - 1} = $currentValue² = $total";
      }
      expStr = currentLang == 'en'
          ? "Notice that for N=$currentValue, we add the $currentValue${_getOrdinal(currentValue)} odd number (${2 * currentValue - 1}) to the previous square to get the new total.\n\nLayers: ${odds.join(' + ')}"
          : "N=$currentValue के लिए, हम पिछले वर्ग में $currentValueवीं विषम संख्या (${2 * currentValue - 1}) जोड़ते हैं।";
    } else if (currentMode == 'cube') {
      nStr = "N = $currentValue";
      int vol = currentValue * currentValue * currentValue;
      ruleStr = "V = N³ = $currentValue × $currentValue × $currentValue = $vol";
      expStr = currentLang == 'en'
          ? "A cube of side $currentValue contains $vol unit cubes."
          : "भुजा $currentValue के एक घन में $vol इकाई घन होते हैं।";
    } else if (currentMode == 'locker') {
      nStr = t('math_lockerTitle');
      if (!simulationRunning && !simulationDone && currentPerson == 0) {
        ruleStr = "Press Run Simulation";
        expStr = "Ready to explore factors!";
      } else {
        if (simulationRunning) {
          ruleStr = "Person $currentPerson toggles multiples of $currentPerson";
        } else {
          ruleStr = "Factors(k) are Odd ⟺ k is a Perfect Square";
        }

        if (simulationDone) {
          expStr =
              "${t('math_openLockers')}\n1, 4, 9, 16, 25, 36, 49, 64, 81, 100\n\n${currentLang == 'en' ? "Only numbers with an Odd Number of Factors remain open." : "केवल विषम संख्या वाले गुणनखंड ही खुले रहते हैं।"}";
        } else {
          expStr = "Simulating locker toggles...";
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics, color: Colors.cyanAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              t('analysis'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          t('math_currN').toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nStr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),
        Text(
          t('math_geo').toUpperCase(),
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
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
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontFamily: 'monospace',
            ),
          ),
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.cyanAccent, width: 3),
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
    );
  }

  String _getOrdinal(int n) {
    if (n >= 11 && n <= 13) return "th";
    switch (n % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
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
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  double s = 1.0 + (_pulseController.value * 0.1);
                  return Transform.scale(
                    scale: s,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.2 * s),
                            blurRadius: 60 * s,
                          ),
                        ],
                      ),
                      child: GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          9,
                          (index) => Container(
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.5),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
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
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(text: "Square Numbers\n"),
                    TextSpan(
                      text: "& Factors",
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Explore the geometric secrets of algebra.",
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
                  _playSound(audioSuccess);
                  setState(() {
                    showCurtain = false;
                    leftSidebarOpen = true;
                  });
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
class SquaresCubesPainter extends CustomPainter {
  final String mode;
  final int n;
  final List<bool> lockerStates;

  SquaresCubesPainter({
    required this.mode,
    required this.n,
    required this.lockerStates,
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
    if (mode == 'square') {
      double scale = math.min(size.width, size.height) * 0.45 / math.max(3, n);
      Offset origin = Offset(size.width / 2, size.height * 0.7);
      double offset = (n - 1) / 2.0;
      List<Color> colors = [
        Colors.cyan,
        Colors.green,
        Colors.pinkAccent,
        Colors.amber,
        Colors.deepPurpleAccent,
      ];

      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          int layer = math.max(i, j);
          Color c = colors[layer % colors.length];
          _drawIsometricBlock(
            canvas,
            origin,
            (i - offset),
            0,
            (j - offset),
            0.9,
            0.2,
            0.9,
            scale,
            c,
          );
        }
      }
    } else if (mode == 'cube') {
      double scale = math.min(size.width, size.height) * 0.4 / math.max(3, n);
      Offset origin = Offset(size.width / 2, size.height * 0.85);
      double offset = (n - 1) / 2.0;

      for (int y = 0; y < n; y++) {
        for (int x = 0; x < n; x++) {
          for (int z = 0; z < n; z++) {
            _drawIsometricBlock(
              canvas,
              origin,
              (x - offset),
              y.toDouble(),
              (z - offset),
              0.95,
              0.95,
              0.95,
              scale,
              Colors.blue,
            );
          }
        }
      }
    } else if (mode == 'locker') {
      double scale = math.min(size.width, size.height) * 0.45 / 10;
      Offset origin = Offset(size.width / 2, size.height * 0.75);

      for (int row = 0; row < 10; row++) {
        for (int col = 0; col < 10; col++) {
          int id = row * 10 + col;
          bool isOpen = lockerStates[id];
          Color c = isOpen ? Colors.green : Colors.redAccent;
          double h = isOpen ? 0.1 : 0.8;
          double spacing = 1.2;

          _drawIsometricBlock(
            canvas,
            origin,
            (col - 4.5) * spacing,
            0,
            (row - 4.5) * spacing,
            1.0,
            h,
            1.0,
            scale,
            c,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant SquaresCubesPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.n != n ||
        oldDelegate.lockerStates != lockerStates;
  }
}
