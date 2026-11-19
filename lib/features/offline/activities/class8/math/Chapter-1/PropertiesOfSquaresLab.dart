// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

// Note: Ensure you add audioplayers to your pubspec.yaml:
// dependencies:
//   audioplayers: ^5.2.1

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class PropertiesOfSquaresLab extends StatefulWidget {
  const PropertiesOfSquaresLab({Key? key}) : super(key: key);

  @override
  State<PropertiesOfSquaresLab> createState() => _PropertiesOfSquaresLabState();
}

class _PropertiesOfSquaresLabState extends State<PropertiesOfSquaresLab>
    with TickerProviderStateMixin {
  // Application State
  String currentLang = 'en';
  String currentMode = 'unit_digits'; // unit_digits, l_shape, subtraction
  int currentValue = 1;

  // Subtraction Mode State
  int subStartVal = 25;
  int subCurrentVal = 25;
  int subStepIndex = 0;
  List<Map<String, int>> subHistory = [];

  bool showCurtain = true;
  bool _isSidebarOpen = true; // Sidebar starts open
  bool isExploded = false;

  late AnimationController _explodeController;
  late Animation<double> _explodeAnim;
  late AnimationController _floatController;

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Child-friendly Network Audio URLs (Mixkit Assets)
  final String soundClick =
      'audio/class8/mixkit_2568.mp3';
  final String soundExplode =
      'audio/class8/mixkit_2771.mp3';
  final String soundSuccess =
      'audio/class8/mixkit_2000.mp3';
  final String soundError =
      'audio/class8/mixkit_2955.mp3';
  final String soundPop =
      'audio/class8/mixkit_2690.mp3';

  // Localization Dictionary (Teacher's Guide Removed)
  final Map<String, Map<String, String>> i18n = {
    'en': {
      'title': "Properties of Square Numbers",
      'subtitle': "Class 8 - A Square and A Cube",
      'modeLbl': "MODE",
      'valueLbl': "N",
      'subtractBtn': "SUBTRACT ODD",
      'modes_unit': "Unit Digits (1-20)",
      'modes_lshape': "Visual Proof (L-Shape)",
      'modes_sub': "Subtraction Check",
      'obs': "Observation",
      'rule': "Mathematical Rule",
      'unitDigitObs': "{N}² = {SQ}",
      'unitDigitRule': "Unit Digits: {LAST}",
      'unitDigitExp':
          "Notice the pattern. The square of {N} ends in {LAST}. Perfect squares NEVER end in 2, 3, 7, or 8.",
      'lShapeObs': "N = {N}",
      'lShapeRule': "{SUM} = {SQ}",
      'lShapeExp':
          "Adding consecutive odd numbers forms a square. Use 'Explode' to separate the layers.",
      'subReachedZero': "Reached 0! Perfect Square.",
      'subNegative': "Went Negative! Not a Square.",
      'subStart': "Start subtraction...",
      'subExp':
          "Subtract consecutive odd numbers (1, 3, 5...). If you reach 0 exactly, it is a perfect square.",
    },
    'hi': {
      'title': "वर्ग संख्याओं के गुण",
      'subtitle': "कक्षा 8 - वर्ग और घन",
      'modeLbl': "मोड",
      'valueLbl': "संख्या (N)",
      'subtractBtn': "विषम घटाएं",
      'modes_unit': "इकाई अंक (1-20)",
      'modes_lshape': "दृश्य प्रमाण (L-आकार)",
      'modes_sub': "घटाव जाँच",
      'obs': "अवलोकन",
      'rule': "गणितीय नियम",
      'unitDigitObs': "{N}² = {SQ}",
      'unitDigitRule': "इकाई अंक: {LAST}",
      'unitDigitExp':
          "पैटर्न देखें। {N} का वर्ग {LAST} पर समाप्त होता है। पूर्ण वर्ग कभी भी 2, 3, 7 या 8 पर समाप्त नहीं होते हैं।",
      'lShapeObs': "N = {N}",
      'lShapeRule': "{SUM} = {SQ}",
      'lShapeExp':
          "क्रमिक विषम संख्याओं को जोड़ने पर एक वर्ग बनता है। परतों को अलग करने के लिए 'विस्फोट' का उपयोग करें।",
      'subReachedZero': "0 पर पहुँचा! पूर्ण वर्ग।",
      'subNegative': "ऋणात्मक हो गया! वर्ग नहीं है।",
      'subStart': "घटाव शुरू करें...",
      'subExp':
          "क्रमिक विषम संख्याओं (1, 3, 5...) को घटाएं। यदि आप ठीक 0 पर पहुंचते हैं, तो यह एक पूर्ण वर्ग है।",
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

    _explodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _explodeAnim = CurvedAnimation(
      parent: _explodeController,
      curve: Curves.easeInOut,
    );

    _floatController = AnimationController(
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
    _explodeController.dispose();
    _floatController.dispose();
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

  void _toggleExplode() {
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
    setState(() {
      currentMode = mode;
      isExploded = false;
      _explodeController.reset();
      if (mode == 'subtraction') {
        _resetSubtraction();
      }
    });
  }

  void _resetSubtraction({int? newVal}) {
    setState(() {
      if (newVal != null) subStartVal = newVal;
      subCurrentVal = subStartVal;
      subStepIndex = 0;
      subHistory.clear();
    });
  }

  void _resetLab() {
    _playSound(soundPop);
    setState(() {
      showCurtain = true;
      _isSidebarOpen = true;
      currentMode = 'unit_digits';
      currentValue = 1;
      isExploded = false;
      _explodeController.reset();
      _resetSubtraction(newVal: 25);
    });
  }

  void _stepSubtraction() {
    if (subCurrentVal <= 0) return;
    setState(() {
      int odd = 2 * subStepIndex + 1;
      int nextVal = subCurrentVal - odd;
      subHistory.add({'start': subCurrentVal, 'sub': odd, 'end': nextVal});
      subCurrentVal = nextVal;
      subStepIndex++;

      if (subCurrentVal == 0) {
        _playSound(soundSuccess);
        _showSuccessPopup();
      } else if (subCurrentVal < 0) {
        _playSound(soundError);
      }
    });
  }

  // --- Scrollable Success Popup ---
  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.greenAccent, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Text(
                t('subReachedZero'),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t('subExp'),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueGrey.shade800),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: subHistory
                          .map(
                            (step) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text(
                                "${step['start']} - ${step['sub']} = ${step['end']}",
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontFamily: 'monospace',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playSound(soundClick);
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
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double sidebarWidth =
              screenWidth * 0.35; // Sidebar is approx 30% of screen
          if (sidebarWidth < 300)
            sidebarWidth = 300; // Minimum width restriction

          return GestureDetector(
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

                // 2. Responsive & Zoomable Center Canvas (Adjustable)
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.2,
                    maxScale: 5.0,
                    boundaryMargin: EdgeInsets.all(screenWidth * 1.5),
                    child: AnimatedBuilder(
                      animation: _explodeAnim,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: SquarePropertiesPainter(
                            mode: currentMode,
                            n: currentValue,
                            subStart: subStartVal,
                            subCurrent: subCurrentVal,
                            explodeFactor: _explodeAnim.value,
                            isSidebarOpen: _isSidebarOpen,
                            sidebarRatio: sidebarWidth / screenWidth,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 3. Scrollable Front Sidebar (Z-Index: High)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isSidebarOpen ? 0 : -sidebarWidth,
                  top: 0,
                  bottom: 0,
                  width: sidebarWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e293b).withOpacity(0.95),
                      boxShadow: [
                        if (_isSidebarOpen)
                          const BoxShadow(
                            color: Colors.black54,
                            blurRadius: 15,
                          ),
                      ],
                      border: Border(
                        right: BorderSide(color: Colors.blueGrey.shade800),
                      ),
                    ),
                    child: _buildSidebarContent(sidebarWidth),
                  ),
                ),

                // 4. Menu Icon at Top Left (Z-Index: Highest)
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          _playSound(soundClick);
                          setState(() => _isSidebarOpen = !_isSidebarOpen);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1e293b).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.cyan.withOpacity(0.5),
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black45, blurRadius: 4),
                            ],
                          ),
                          child: Icon(
                            _isSidebarOpen ? Icons.menu_open : Icons.menu,
                            color: Colors.cyanAccent,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 6. Curtain Raiser
                if (showCurtain) _buildCurtainRaiser(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Consolidated Single Sidebar containing Header, Target Output, and Footer
  Widget _buildSidebarContent(double width) {
    // Generate Target Output Strings
    String obsStr = "";
    String ruleStr = "";
    String expStr = "";

    if (currentMode == 'unit_digits') {
      int sq = currentValue * currentValue;
      int last = sq % 10;
      obsStr = t(
        'unitDigitObs',
      ).replaceAll('{N}', '$currentValue').replaceAll('{SQ}', '$sq');
      ruleStr = t('unitDigitRule').replaceAll('{LAST}', '$last');
      expStr = t(
        'unitDigitExp',
      ).replaceAll('{N}', '$currentValue').replaceAll('{LAST}', '$last');
    } else if (currentMode == 'l_shape') {
      int sq = currentValue * currentValue;
      String sum = "1";
      for (int i = 1; i < currentValue; i++) {
        sum += " + ${2 * i + 1}";
      }
      obsStr = t('lShapeObs').replaceAll('{N}', '$currentValue');
      ruleStr = t(
        'lShapeRule',
      ).replaceAll('{SUM}', sum).replaceAll('{SQ}', '$sq');
      expStr = t('lShapeExp');
    } else if (currentMode == 'subtraction') {
      obsStr = "Current: $subCurrentVal";
      ruleStr = "Subtract odds sequentially.";
      expStr = t('subExp');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 70,
        left: 20,
        right: 20,
        bottom: 20,
      ), // Padding accounts for Menu Icon
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Text(
            t('title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            t('subtitle'),
            style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Lang toggle and Reset button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: ['en', 'hi'].map((lang) {
                  bool isActive = currentLang == lang;
                  return GestureDetector(
                    onTap: () {
                      _playSound(soundClick);
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
                          color: isActive ? Colors.cyan : Colors.blueGrey,
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
                icon: const Icon(Icons.restart_alt, color: Colors.cyanAccent),
                onPressed: _resetLab,
                tooltip: 'Reset Lab',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.blueGrey.shade800, height: 30),

          // Mode Selection
          Text(
            t('modeLbl'),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                ),
                items: [
                  DropdownMenuItem(
                    value: 'unit_digits',
                    child: Text(t('modes_unit')),
                  ),
                  DropdownMenuItem(
                    value: 'l_shape',
                    child: Text(t('modes_lshape')),
                  ),
                  DropdownMenuItem(
                    value: 'subtraction',
                    child: Text(t('modes_sub')),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    _playSound(soundPop);
                    _changeMode(v);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Controls
          if (currentMode == 'unit_digits' || currentMode == 'l_shape') ...[
            Text(
              "${t('valueLbl')}: $currentValue",
              style: const TextStyle(color: Colors.white70),
            ),
            Slider(
              value: currentValue.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              activeColor: Colors.cyan,
              inactiveColor: Colors.blueGrey,
              onChanged: (v) => setState(() => currentValue = v.toInt()),
              onChangeEnd: (v) => _playSound(soundClick),
            ),
            if (currentMode == 'l_shape')
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_full, size: 16),
                label: const Text("EXPLODE"),
                onPressed: () {
                  _playSound(soundExplode);
                  _toggleExplode();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
          ] else if (currentMode == 'subtraction') ...[
            const Text("Start Value:", style: TextStyle(color: Colors.white70)),
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
                  value: subStartVal,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  items: [25, 36, 38, 49, 50]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            "$e ${e == 38 || e == 50 ? '(Not Square)' : '(Square)'}",
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      _playSound(soundPop);
                      _resetSubtraction(newVal: v);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.remove, size: 16),
                    label: Text(t('subtractBtn')),
                    onPressed: subCurrentVal > 0
                        ? () {
                            _playSound(soundClick);
                            _stepSubtraction();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _playSound(soundClick);
                    _resetSubtraction();
                  },
                ),
              ],
            ),
          ],

          Divider(color: Colors.blueGrey.shade800, height: 40),

          // Target Output
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.cyanAccent, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "TARGET OUTPUT",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                const SizedBox(height: 4),
                Text(
                  obsStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  t('rule').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ruleStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.greenAccent, width: 3),
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

                if (currentMode == 'subtraction' && subHistory.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    "History:",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...subHistory.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "${step['start']} - ${step['sub']} = ${step['end']}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 40),
          // Footer
          const Center(
            child: Text(
              "© ZeroScienceLab - Fall in love with math and Science",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
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
                animation: _floatController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _floatingDigit("1", 0.0),
                      const SizedBox(width: 20),
                      _floatingDigit("4", 0.5),
                      const SizedBox(width: 20),
                      _floatingDigit("9", 1.0),
                      const SizedBox(width: 20),
                      _floatingDigit("6", 1.5),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
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
                    TextSpan(text: "Properties of\n"),
                    TextSpan(
                      text: "Square Numbers",
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Discover hidden patterns in unit digits and odd subtractions.",
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
                  _playSound(soundPop);
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
      ),
    );
  }

  Widget _floatingDigit(String digit, double offset) {
    double val = sin((_floatController.value * 2 * pi) + offset);
    return Transform.translate(
      offset: Offset(0, val * -15),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent,
        ),
      ),
    );
  }
}

// --- Isometric 2D Native Custom Painter ---
class SquarePropertiesPainter extends CustomPainter {
  final String mode;
  final int n;
  final int subStart;
  final int subCurrent;
  final double explodeFactor;
  final bool isSidebarOpen;
  final double sidebarRatio;

  SquarePropertiesPainter({
    required this.mode,
    required this.n,
    required this.subStart,
    required this.subCurrent,
    required this.explodeFactor,
    required this.isSidebarOpen,
    required this.sidebarRatio,
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
    Color baseColor, {
    bool ghost = false,
  }) {
    double cos30 = cos(pi / 6);
    double sin30 = sin(pi / 6);

    // Vectors for standard isometric projection (scaled)
    Offset vx = Offset(scale * cos30, scale * sin30);
    Offset vz = Offset(-scale * cos30, scale * sin30);
    Offset vy = Offset(0, -scale);

    // Calculate the bottom-center point
    Offset c =
        origin +
        Offset(x * vx.dx + z * vz.dx, x * vx.dy + z * vz.dy + y * vy.dy);

    // Right Face (X-Y Plane)
    Path rightFace = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx + vx.dx * w, c.dy + vx.dy * w)
      ..lineTo(c.dx + vx.dx * w + vy.dx * h, c.dy + vx.dy * w + vy.dy * h)
      ..lineTo(c.dx + vy.dx * h, c.dy + vy.dy * h)
      ..close();

    // Left Face (Z-Y Plane)
    Path leftFace = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx + vz.dx * d, c.dy + vz.dy * d)
      ..lineTo(c.dx + vz.dx * d + vy.dx * h, c.dy + vz.dy * d + vy.dy * h)
      ..lineTo(c.dx + vy.dx * h, c.dy + vy.dy * h)
      ..close();

    // Top Face (X-Z Plane shifted by h)
    Offset cTop = c + vy * h;
    Path topFace = Path()
      ..moveTo(cTop.dx, cTop.dy)
      ..lineTo(cTop.dx + vx.dx * w, cTop.dy + vx.dy * w)
      ..lineTo(cTop.dx + vx.dx * w + vz.dx * d, cTop.dy + vx.dy * w + vz.dy * d)
      ..lineTo(cTop.dx + vz.dx * d, cTop.dy + vz.dy * d)
      ..close();

    Paint facePaint = Paint()..style = PaintingStyle.fill;
    Paint edgePaint = Paint()
      ..color = ghost ? Colors.white24 : Colors.black38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (ghost) {
      facePaint.color = Colors.white.withOpacity(0.05);
      canvas.drawPath(leftFace, facePaint);
      canvas.drawPath(leftFace, edgePaint);
      canvas.drawPath(rightFace, facePaint);
      canvas.drawPath(rightFace, edgePaint);
      canvas.drawPath(topFace, facePaint);
      canvas.drawPath(topFace, edgePaint);
    } else {
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
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double size = 20,
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
      Paint bgPaint = Paint()..color = Colors.black54;
      canvas.drawRect(
        Rect.fromCenter(
          center: position,
          width: textPainter.width + 16,
          height: textPainter.height + 8,
        ),
        bgPaint,
      );
    }

    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Dynamically adjust center origin to right when sidebar is open to make activity responsive
    double offsetX = isSidebarOpen ? (size.width * sidebarRatio) / 2 : 0;
    Offset origin = Offset(size.width / 2 + offsetX, size.height * 0.75);

    if (mode == 'unit_digits') {
      double scale = (size.height * 0.4) / max(n, 5);
      double offset = (n - 1) / 2.0;

      // Draw Grid
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          _drawIsometricBlock(
            canvas,
            origin,
            (i - offset).toDouble(),
            0,
            (j - offset).toDouble(),
            0.9,
            0.2,
            0.9,
            scale,
            Colors.cyan,
          );
        }
      }

      // Floating Unit Digit Indicator
      int lastDigit = (n * n) % 10;
      Offset topCenter = origin + Offset(0, -scale * 2);
      _drawText(
        canvas,
        "$lastDigit",
        topCenter,
        size: 40,
        color: Colors.amberAccent,
        bg: true,
      );
    } else if (mode == 'l_shape') {
      double scale = (size.height * 0.4) / max(n, 5);
      double offset = (n - 1) / 2.0;
      List<Color> colors = [
        Colors.cyan,
        Colors.green,
        Colors.pinkAccent,
        Colors.amber,
        Colors.deepPurpleAccent,
      ];

      // Draw from back to front
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          int layer = max(i, j);
          Color c = colors[layer % colors.length];

          double shift = layer * explodeFactor * 0.8;

          _drawIsometricBlock(
            canvas,
            origin,
            (i - offset) + shift,
            shift,
            (j - offset) + shift,
            0.9,
            0.9,
            0.9,
            scale,
            c,
          );
        }
      }
    } else if (mode == 'subtraction') {
      double scale = 30.0;

      // Base Platform
      _drawIsometricBlock(
        canvas,
        origin,
        -2.5,
        -0.5,
        -1,
        5,
        0.5,
        2,
        scale,
        Colors.blueGrey.shade700,
      );

      // Ghost block for starting value
      if (subStart > 0) {
        _drawIsometricBlock(
          canvas,
          origin,
          -0.5,
          0,
          -0.5,
          1,
          subStart * 0.2,
          1,
          scale,
          Colors.white,
          ghost: true,
        );
      }

      // Solid block for current value
      if (subCurrent > 0) {
        _drawIsometricBlock(
          canvas,
          origin,
          -0.5,
          0,
          -0.5,
          1,
          subCurrent * 0.2,
          1,
          scale,
          Colors.cyan,
        );
      } else if (subCurrent < 0) {
        // Red block going downwards to indicate negative
        _drawIsometricBlock(
          canvas,
          origin,
          -0.5,
          (subCurrent * 0.2),
          -0.5,
          1,
          (subCurrent.abs() * 0.2),
          1,
          scale,
          Colors.redAccent,
        );
      }

      // Draw Labels
      _drawText(
        canvas,
        "Current: $subCurrent",
        origin + const Offset(0, 40),
        size: 16,
        color: Colors.cyanAccent,
      );
      _drawText(
        canvas,
        "Start: $subStart",
        origin + const Offset(0, 60),
        size: 14,
        color: Colors.white54,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SquarePropertiesPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.n != n ||
        oldDelegate.explodeFactor != explodeFactor ||
        oldDelegate.subStart != subStart ||
        oldDelegate.subCurrent != subCurrent ||
        oldDelegate.isSidebarOpen != isSidebarOpen ||
        oldDelegate.sidebarRatio != sidebarRatio;
  }
}
