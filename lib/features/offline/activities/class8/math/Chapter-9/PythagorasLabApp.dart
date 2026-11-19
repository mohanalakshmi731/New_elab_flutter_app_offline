// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF020617)),
      home: const PythagorasLabApp(),
    ),
  );
}

class PythagorasLabApp extends StatefulWidget {
  const PythagorasLabApp({Key? key}) : super(key: key);

  @override
  State<PythagorasLabApp> createState() => _PythagorasLabAppState();
}

class _PythagorasLabAppState extends State<PythagorasLabApp>
    with SingleTickerProviderStateMixin {
  // App Navigation & Preference State
  bool _showCurtain = true;
  bool _sidebarOpen = false;
  bool _isHindi = false;
  bool _isDarkMode = true;

  int _currentStep = 1;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Scale unit for the geometry
  final double UNIT = 40.0;

  // Step 1 & 2 State
  List<bool> _gridAFilled = List.filled(9, false); // 3x3
  List<bool> _gridBFilled = List.filled(16, false); // 4x4
  List<bool> _gridCFilled = List.filled(25, false); // 5x5
  bool _isTransferring = false;

  // Step 3 State
  String? _slotShortest;
  String? _slotMedium;
  String? _slotLongest;

  // Step 4 State
  String? _eqSlot1;
  String? _eqSlot2;
  bool _showCalc = false;
  String? _calcResult;
  String? _finalBValue;

  // --- Dynamic Theme Colors (Explicit Hex values for strict Type Safety) ---
  Color get bgColor {
    return _isDarkMode ? const Color(0xFF020617) : const Color(0xFFF1F5F9);
  }

  Color get surfaceColor {
    return _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  }

  Color get surfaceColor2 {
    return _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  }

  Color get textColor {
    return _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
  }

  Color get subTextColor {
    return _isDarkMode ? const Color(0xB3FFFFFF) : const Color(0xFF475569);
  }

  Color get borderColor {
    return _isDarkMode ? const Color(0x3DFFFFFF) : const Color(0x1F000000);
  }

  Color get triangleColor {
    return _isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
  }

  // Helper to resolve slot colors robustly
  Color _getColorForVal(String val) {
    if (val == '3') return const Color(0xFFFF5252); // Red Accent
    if (val == '4') return const Color(0xFF448AFF); // Blue Accent
    return const Color(0xFFFFC107); // Amber
  }

  // --- Translation Helper ---
  String _t(String text) {
    if (!_isHindi) return text;

    // Complete Dictionary for English to Hindi mapping
    Map<String, String> translations = {
      "Pythagoras Lab": "पाइथागोरस लैब",
      "Visualizing the Theorem": "प्रमेय की कल्पना",
      "Welcome to the Interactive Math Laboratory!\n\nIn this mission, you will visually prove the famous equation a² + b² = c² through interactive blocks, analyze length logic, and calculate missing side lengths.":
          "इंटरैक्टिव गणित प्रयोगशाला में आपका स्वागत है!\n\nइस मिशन में, आप संवादात्मक ब्लॉक के माध्यम से प्रसिद्ध समीकरण a² + b² = c² को दृष्टिगत रूप से सिद्ध करेंगे, लंबाई के तर्क का विश्लेषण करेंगे, और लुप्त भुजा की लंबाई की गणना करेंगे।",
      "Enter Laboratory": "प्रयोगशाला में प्रवेश करें",
      "Area Relationship": "क्षेत्रफल संबंध",
      "CURRENT STEP": "वर्तमान चरण",
      "1: Visualizing 'Varga'": "1: 'वर्ग' की कल्पना",
      "2: The Area Relationship": "2: क्षेत्रफल संबंध",
      "3: The Longest Side": "3: सबसे लंबी भुजा",
      "4: Finding Missing Side": "4: लुप्त भुजा ढूँढना",
      "TARGET OUTPUT": "लक्ष्य आउटपुट",
      "Current Mission": "वर्तमान मिशन",
      "Build the Vargas! Drag the 1x1 unit blocks from the bin to completely fill the square grids attached to the two shorter legs (a=3, b=4).":
          "वर्ग बनाएं! डिब्बे से 1x1 यूनिट ब्लॉक खींचें और दो छोटी भुजाओं (a=3, b=4) से जुड़े वर्गाकार ग्रिड को पूरी तरह से भरें।",
      "Let's test the theorem! Click 'Transfer Blocks' to automatically transfer all blocks from the smaller squares into the empty hypotenuse square.":
          "आइए प्रमेय का परीक्षण करें! छोटे वर्गों से सभी ब्लॉकों को खाली कर्ण वर्ग में स्वचालित रूप से स्थानांतरित करने के लिए 'ब्लॉक स्थानांतरित करें' पर क्लिक करें।",
      "Let's confirm the logic! Drag and sort the three line segments onto the comparison scale from shortest to longest.":
          "आइए तर्क की पुष्टि करें! तुलना पैमाने पर तीनों रेखाखंडों को सबसे छोटे से सबसे लंबे तक खींचें और क्रमबद्ध करें।",
      "Drag the known sides into the equation. The hypotenuse goes alone on one side. Then calculate the missing base using the square root tool.":
          "ज्ञात भुजाओं को समीकरण में खींचें। कर्ण एक तरफ अकेला रहता है। फिर वर्गमूल उपकरण का उपयोग करके लुप्त आधार की गणना करें।",
      "Validate Placement": "स्थानपन मान्य करें",
      "Transfer Blocks": "ब्लॉक स्थानांतरित करें",
      "Validate Logic": "तर्क मान्य करें",
      "Restart Lab": "लैब पुनः आरंभ करें",
      "Block Bin": "ब्लॉक डिब्बा",
      "Length Comparison Scale": "लंबाई तुलना पैमाना",
      "Shortest": "सबसे छोटा",
      "Medium": "मध्यम",
      "Longest": "सबसे लंबा",
      "Leg a": "भुजा a",
      "Leg b": "भुजा b",
      "Hypotenuse": "कर्ण",
      "Tool √": "उपकरण √",
      "Drop √ here to calculate √576": "√576 की गणना के लिए √ यहां छोड़ें",
      "Success!": "सफलता!",
      "Next Step": "अगला चरण",
      "Hint: The hypotenuse (25) is the longest side and must be alone on one side of the equation!":
          "संकेत: कर्ण (25) सबसे लंबी भुजा है और समीकरण के एक तरफ अकेले होनी चाहिए!",
      "Incorrect placement. Try again!": "गलत स्थानपन। पुनः प्रयास करें!",
      "Great job! You have fully built the Vargas.":
          "बहुत बढ़िया! आपने वर्गों को पूरी तरह से बना लिया है।",
      "A perfect fit! 9 blocks plus 16 blocks perfectly fill a 25-block square. 3² + 4² = 5². You just proved the theorem visually!":
          "एकदम सही! 9 ब्लॉक और 16 ब्लॉक पूरी तरह से 25-ब्लॉक वर्ग को भरते हैं। 3² + 4² = 5²। आपने अभी प्रमेय को दृष्टिगत रूप से सिद्ध कर दिया है!",
      "Logical and correct! Because c² = a² + b², c² must be greater than a² and greater than b². Thus, the hypotenuse c is strictly the longest side.":
          "तार्किक और सही! क्योंकि c² = a² + b², c², a² से बड़ा होना चाहिए और b² से भी बड़ा होना चाहिए। इस प्रकार, कर्ण c निश्चित रूप से सबसे लंबी भुजा है।",
      "Masterful calculation! The square root of 576 is 24. The missing side is 24. You have conquered the Theorem!":
          "कुशल गणना! 576 का वर्गमूल 24 है। लुप्त भुजा 24 है। आपने प्रमेय पर विजय प्राप्त कर ली है!",
      "Light Mode": "लाइट मोड",
      "Dark Mode": "डार्क मोड",
      "x": "x",
    };

    return translations[text] ?? text;
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String type) async {
    String url = '';
    if (type == 'pop')
      url = 'audio/class8/mixkit_2568.mp3';
    if (type == 'success')
      url = 'audio/class8/mixkit_2018.mp3';
    if (type == 'error')
      url = 'audio/class8/mixkit_955.mp3';

    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _resetLab() {
    setState(() {
      _currentStep = 1;
      _gridAFilled = List.filled(9, false);
      _gridBFilled = List.filled(16, false);
      _gridCFilled = List.filled(25, false);
      _slotShortest = null;
      _slotMedium = null;
      _slotLongest = null;
      _eqSlot1 = null;
      _eqSlot2 = null;
      _showCalc = false;
      _calcResult = null;
      _finalBValue = null;
    });
    _playSound('pop');
  }

  void _fullRestart() {
    _resetLab();
    setState(() {
      _showCurtain = true;
      _sidebarOpen = false;
    });
  }

  void _showSuccessPopup(String message) {
    _playSound('success');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFC107), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF69F0AE), size: 28),
            const SizedBox(width: 10),
            Text(
              _t("Success!"),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            _t(message),
            style: TextStyle(color: subTextColor, fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentStep < 4) {
                setState(() => _currentStep++);
              } else {
                _resetLab();
              }
            },
            child: Text(
              _currentStep < 4 ? _t("Next Step") : _t("Restart Lab"),
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _transferBlocks() async {
    if (_isTransferring) return;
    setState(() => _isTransferring = true);

    for (int i = 0; i < 25; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        if (i < 9) _gridAFilled[i] = false;
        if (i >= 9 && i < 25) _gridBFilled[i - 9] = false;
        _gridCFilled[i] = true;
      });
      _playSound('pop');
    }

    setState(() => _isTransferring = false);
    _showSuccessPopup(
      "A perfect fit! 9 blocks plus 16 blocks perfectly fill a 25-block square. 3² + 4² = 5². You just proved the theorem visually!",
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = screenWidth * 0.35;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // 1. Canvas Background
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(800),
                constrained: false,
                child: Center(child: _buildCanvasContent()),
              ),
            ),

            // 2. Mission Floating Card
            if (!_sidebarOpen && !_showCurtain)
              Positioned(
                top: 70,
                left: 10,
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor.withOpacity(0.95),
                    border: Border.all(color: const Color(0x80FFC107)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x8A000000), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Color(0xFFFFC107)),
                          const SizedBox(width: 8),
                          Text(
                            _t("Current Mission"),
                            style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t(_getMissionText()),
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Floating Block Bin
            if (_currentStep == 1 && !_showCurtain)
              Positioned(bottom: 24, right: 24, child: _buildBlockBin()),

            // 4. Sidebar Panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // 5. FIXED Menu Icon - Placed AFTER sidebar in the Stack so it renders on TOP (Highest Z-Index)
            if (!_showCurtain)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor.withOpacity(0.95),
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Color(0x40000000), blurRadius: 6),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      _sidebarOpen ? Icons.menu_open : Icons.menu,
                      color: textColor,
                    ),
                    tooltip: _sidebarOpen ? "Close Menu" : "Open Menu",
                    onPressed: () {
                      setState(() => _sidebarOpen = !_sidebarOpen);
                    },
                  ),
                ),
              ),

            // 6. Curtain Raiser (Only visible at start)
            if (_showCurtain) Positioned.fill(child: _buildCurtainRaiser()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtainRaiser() {
    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x80FFC107), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1AFFC107),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.change_history,
                  size: 80,
                  color: Color(0xFFFFC107),
                ),
                const SizedBox(height: 20),
                Text(
                  _t("Pythagoras Lab"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _t("Visualizing the Theorem"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFC107),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _t("Welcome to the Interactive Math Laboratory!"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCurtain = false;
                      _sidebarOpen = true;
                    });
                    _playSound('success');
                  },
                  icon: const Icon(
                    Icons.science,
                    color: Color(0xFF000000),
                    size: 28,
                  ),
                  label: Text(
                    _t("Enter Laboratory"),
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.98),
        border: Border(
          right: BorderSide(color: const Color(0x4DFFC107), width: 2),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x8A000000), blurRadius: 30, spreadRadius: 10),
        ],
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 70,
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      // New Theme/Geometry Icon before the Title
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x33FFC107),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.change_history,
                          color: Color(0xFFFFC107),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t("Pythagoras Lab"),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              _t("Area Relationship"),
                              style: const TextStyle(
                                color: Color(0xFFFFC107),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor2.withOpacity(0.5),
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() => _isHindi = !_isHindi),
                        icon: const Icon(
                          Icons.language,
                          color: Color(0xFFFFC107),
                          size: 18,
                        ),
                        label: Text(
                          _isHindi ? "HI" : "EN", // Fixed: now shows currently selected language
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: _t("Restart Lab"),
                            icon: Icon(Icons.restart_alt, color: textColor),
                            onPressed: _fullRestart,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t("CURRENT STEP"),
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceColor2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x80FFC107)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _currentStep,
                              isExpanded: true,
                              dropdownColor: surfaceColor2,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFFFFC107),
                              ),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(_t("1: Visualizing 'Varga'")),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(_t("2: The Area Relationship")),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text(_t("3: The Longest Side")),
                                ),
                                DropdownMenuItem(
                                  value: 4,
                                  child: Text(_t("4: Finding Missing Side")),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _currentStep = val);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),
                        Text(
                          _t("TARGET OUTPUT"),
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _t(_getMissionText()),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 40),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: Center(
                    child: Text(
                      _t(
                        "© ZeroScienceLab - Fall in love with math and Science",
                      ),
                      style: TextStyle(color: subTextColor, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMissionText() {
    switch (_currentStep) {
      case 1:
        return "Build the Vargas! Drag the 1x1 unit blocks from the bin to completely fill the square grids attached to the two shorter legs (a=3, b=4).";
      case 2:
        return "Let's test the theorem! Click 'Transfer Blocks' to automatically transfer all blocks from the smaller squares into the empty hypotenuse square.";
      case 3:
        return "Let's confirm the logic! Drag and sort the three line segments onto the comparison scale from shortest to longest.";
      case 4:
        return "Drag the known sides into the equation. The hypotenuse goes alone on one side. Then calculate the missing base using the square root tool.";
      default:
        return "";
    }
  }

  Widget _buildActionButtons() {
    if (_currentStep == 1) {
      bool isComplete =
          !_gridAFilled.contains(false) && !_gridBFilled.contains(false);
      return ElevatedButton.icon(
        onPressed: isComplete
            ? () => _showSuccessPopup(
                "Great job! You have fully built the Vargas.",
              )
            : () {
                _playSound('error');
              },
        icon: const Icon(Icons.check_circle, color: Color(0xFF000000)),
        label: Text(
          _t("Validate Placement"),
          style: const TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isComplete
              ? const Color(0xFFFFC107)
              : const Color(0xFF9E9E9E),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (_currentStep == 2) {
      bool isComplete = !_gridCFilled.contains(false);
      return ElevatedButton.icon(
        onPressed: isComplete ? null : _transferBlocks,
        icon: const Icon(Icons.compare_arrows, color: Color(0xFF000000)),
        label: Text(
          _t("Transfer Blocks"),
          style: const TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (_currentStep == 3) {
      return ElevatedButton.icon(
        onPressed: () {
          if (_slotShortest == '3' &&
              _slotMedium == '4' &&
              _slotLongest == '5') {
            _showSuccessPopup(
              "Logical and correct! Because c² = a² + b², c² must be greater than a² and greater than b². Thus, the hypotenuse c is strictly the longest side.",
            );
          } else {
            _playSound('error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_t("Incorrect placement. Try again!")),
                backgroundColor: const Color(0xFFF44336),
              ),
            );
          }
        },
        icon: const Icon(Icons.rule, color: Color(0xFF000000)),
        label: Text(
          _t("Validate Logic"),
          style: const TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () => _resetLab(),
        icon: const Icon(Icons.refresh, color: Color(0xFF000000)),
        label: Text(
          _t("Restart Lab"),
          style: const TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildCanvasContent() {
    if (_currentStep == 3) return _buildStep3Board();
    if (_currentStep == 4) return _buildStep4Board();

    final double originX = 400.0;
    final double originY = 500.0;

    return SizedBox(
      width: 800,
      height: 800,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: originX,
            top: originY,
            child: CustomPaint(
              painter: TrianglePainter(
                unit: UNIT,
                triangleColor: triangleColor,
                borderColor: borderColor,
              ),
            ),
          ),

          Positioned(
            left: originX + 1.5 * UNIT - 20,
            top: originY + 10,
            child: _buildLabel("a=3", const Color(0xFFFF5252)),
          ),
          Positioned(
            left: originX - 60,
            top: originY - 2 * UNIT - 10,
            child: _buildLabel("b=4", const Color(0xFF448AFF)),
          ),
          Positioned(
            left: originX + 1.5 * UNIT,
            top: originY - 2 * UNIT - 30,
            child: _buildLabel("c=5", const Color(0xFFFFC107)),
          ),

          Positioned(
            left: originX,
            top: originY,
            child: SizedBox(
              width: 3 * UNIT,
              height: 3 * UNIT,
              child: Wrap(
                children: List.generate(
                  9,
                  (index) =>
                      _buildGridSlot(index, 'A', const Color(0xFFF44336)),
                ),
              ),
            ),
          ),

          Positioned(
            left: originX - 4 * UNIT,
            top: originY - 4 * UNIT,
            child: SizedBox(
              width: 4 * UNIT,
              height: 4 * UNIT,
              child: Wrap(
                children: List.generate(
                  16,
                  (index) =>
                      _buildGridSlot(index, 'B', const Color(0xFF2196F3)),
                ),
              ),
            ),
          ),

          Positioned(
            left: originX,
            top: originY,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(0.0, -4 * UNIT)
                ..rotateZ(math.atan2(160, 120))
                ..translate(0.0, -5 * UNIT),
              child: SizedBox(
                width: 5 * UNIT,
                height: 5 * UNIT,
                child: Wrap(
                  children: List.generate(
                    25,
                    (index) =>
                        _buildGridSlot(index, 'C', const Color(0xFFFFC107)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildGridSlot(int index, String type, Color color) {
    bool isFilled = false;
    if (type == 'A') isFilled = _gridAFilled[index];
    if (type == 'B') isFilled = _gridBFilled[index];
    if (type == 'C') isFilled = _gridCFilled[index];

    return DragTarget<String>(
      onWillAccept: (data) =>
          data != null &&
          !isFilled &&
          ((type == 'A' && data == 'block_a') ||
              (type == 'B' && data == 'block_b')),
      onAccept: (data) {
        setState(() {
          if (type == 'A') _gridAFilled[index] = true;
          if (type == 'B') _gridBFilled[index] = true;
        });
        _playSound('pop');
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: UNIT,
          height: UNIT,
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5), width: 1),
            color: isFilled
                ? color
                : (candidateData.isNotEmpty
                      ? color.withOpacity(0.5)
                      : color.withOpacity(0.15)),
          ),
        );
      },
    );
  }

  Widget _buildBlockBin() {
    int remainingA = 9 - _gridAFilled.where((e) => e).length;
    int remainingB = 16 - _gridBFilled.where((e) => e).length;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x8A000000), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2, color: subTextColor, size: 20),
              const SizedBox(width: 8),
              Text(
                _t("Block Bin"),
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Draggable<String>(
                    data: 'block_a',
                    feedback: Material(
                      color: const Color(0x00000000),
                      child: Container(
                        width: UNIT,
                        height: UNIT,
                        decoration: BoxDecoration(
                          color: const Color(0xE6F44336),
                          border: Border.all(
                            color: const Color(0xFFFFFFFF),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x8A000000), blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                    childWhenDragging: Container(
                      width: UNIT,
                      height: UNIT,
                      color: const Color(0x33F44336),
                    ),
                    child: Container(
                      width: UNIT,
                      height: UNIT,
                      decoration: BoxDecoration(
                        color: remainingA > 0
                            ? const Color(0xFFF44336)
                            : const Color(0x339E9E9E),
                        border: Border.all(color: borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_t('x')}$remainingA",
                    style: TextStyle(
                      color: subTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Draggable<String>(
                    data: 'block_b',
                    feedback: Material(
                      color: const Color(0x00000000),
                      child: Container(
                        width: UNIT,
                        height: UNIT,
                        decoration: BoxDecoration(
                          color: const Color(0xE62196F3),
                          border: Border.all(
                            color: const Color(0xFFFFFFFF),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x8A000000), blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                    childWhenDragging: Container(
                      width: UNIT,
                      height: UNIT,
                      color: const Color(0x332196F3),
                    ),
                    child: Container(
                      width: UNIT,
                      height: UNIT,
                      decoration: BoxDecoration(
                        color: remainingB > 0
                            ? const Color(0xFF2196F3)
                            : const Color(0x339E9E9E),
                        border: Border.all(color: borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_t('x')}$remainingB",
                    style: TextStyle(
                      color: subTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Board() {
    return Container(
      width: 650,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66FFC107)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _t("Length Comparison Scale"),
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStep3DropZone(
                _t("Shortest"),
                _slotShortest,
                (val) => setState(() => _slotShortest = val),
              ),
              _buildStep3DropZone(
                _t("Medium"),
                _slotMedium,
                (val) => setState(() => _slotMedium = val),
              ),
              _buildStep3DropZone(
                _t("Longest"),
                _slotLongest,
                (val) => setState(() => _slotLongest = val),
                isLongest: true,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Divider(color: borderColor),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_slotShortest != '3' &&
                  _slotMedium != '3' &&
                  _slotLongest != '3')
                _buildStep3Draggable(
                  '3',
                  _t("Leg a"),
                  const Color(0xFFFF5252),
                  80,
                ),
              const SizedBox(width: 20),
              if (_slotShortest != '4' &&
                  _slotMedium != '4' &&
                  _slotLongest != '4')
                _buildStep3Draggable(
                  '4',
                  _t("Leg b"),
                  const Color(0xFF448AFF),
                  110,
                ),
              const SizedBox(width: 20),
              if (_slotShortest != '5' &&
                  _slotMedium != '5' &&
                  _slotLongest != '5')
                _buildStep3Draggable(
                  '5',
                  _t("Hypotenuse"),
                  const Color(0xFFFFC107),
                  140,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3DropZone(
    String label,
    String? currentVal,
    Function(String) onAccept, {
    bool isLongest = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isLongest ? const Color(0xFFFFC107) : subTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        DragTarget<String>(
          onWillAccept: (data) => data != null && currentVal == null,
          onAccept: (data) {
            onAccept(data);
            _playSound('pop');
          },
          builder: (context, candidate, rejected) {
            return Container(
              width: 120,
              height: 60,
              decoration: BoxDecoration(
                color: candidate.isNotEmpty
                    ? borderColor
                    : textColor.withOpacity(0.05),
                border: Border.all(
                  color: isLongest ? const Color(0xFFFFC107) : borderColor,
                  style: BorderStyle.solid,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: currentVal != null
                  ? _buildStep3Draggable(
                      currentVal,
                      _getNameForVal(currentVal),
                      _getColorForVal(currentVal),
                      100,
                    )
                  : const SizedBox(),
            );
          },
        ),
      ],
    );
  }

  String _getNameForVal(String val) =>
      val == '3' ? _t("Leg a") : (val == '4' ? _t("Leg b") : _t("Hypotenuse"));

  Widget _buildStep3Draggable(
    String id,
    String label,
    Color color,
    double width,
  ) {
    Widget child = Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );

    return Draggable<String>(
      data: id,
      feedback: Material(color: const Color(0x00000000), child: child),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }

  Widget _buildStep4Board() {
    return Container(
      width: 700,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66FFC107)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEqDropSlot(
                _eqSlot1,
                (v) => setState(() {
                  _eqSlot1 = v;
                  _checkEq();
                }),
              ),
              Text(
                " ² + b² = ",
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildEqDropSlot(
                _eqSlot2,
                (v) => setState(() {
                  _eqSlot2 = v;
                  _checkEq();
                }),
              ),
              Text(
                " ²",
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (_showCalc) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "49 + b² = 625   →   b² = 576",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "b = ",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DragTarget<String>(
                        onWillAccept: (data) => data == '24',
                        onAccept: (data) {
                          setState(() => _finalBValue = data);
                          _showSuccessPopup(
                            "Masterful calculation! The square root of 576 is 24. The missing side is 24. You have conquered the Theorem!",
                          );
                        },
                        builder: (context, cand, rej) {
                          return Container(
                            width: 80,
                            height: 50,
                            decoration: BoxDecoration(
                              color: textColor.withOpacity(0.05),
                              border: Border.all(
                                color: const Color(0xFFFFC107),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: _finalBValue != null
                                ? Text(
                                    _finalBValue!,
                                    style: const TextStyle(
                                      color: Color(0xFFFFC107),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : (cand.isNotEmpty
                                      ? const Icon(
                                          Icons.download,
                                          color: Color(0xFFFFC107),
                                        )
                                      : null),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              if (_eqSlot1 != '7' && _eqSlot2 != '7') _buildStep4Block('7'),
              if (_eqSlot1 != '25' && _eqSlot2 != '25') _buildStep4Block('25'),
              if (_calcResult != null && _finalBValue == null)
                _buildStep4Block('24'),

              Draggable<String>(
                data: 'sqrt',
                feedback: Material(
                  color: const Color(0x00000000),
                  child: _buildToolBlock(),
                ),
                child: _buildToolBlock(),
              ),
            ],
          ),

          if (_showCalc && _calcResult == null) ...[
            const SizedBox(height: 20),
            DragTarget<String>(
              onWillAccept: (d) => d == 'sqrt',
              onAccept: (d) {
                setState(() => _calcResult = '24');
                _playSound('pop');
              },
              builder: (ctx, cand, rej) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cand.isNotEmpty
                        ? const Color(0x4D9C27B0)
                        : textColor.withOpacity(0.05),
                    border: Border.all(
                      color: const Color(0xFF9C27B0),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Text(
                    _t("Drop √ here to calculate √576"),
                    style: const TextStyle(color: Color(0xFFE040FB)),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEqDropSlot(String? val, Function(String) onDrop) {
    return DragTarget<String>(
      onWillAccept: (d) => (d == '7' || d == '25') && val == null,
      onAccept: (d) {
        onDrop(d);
        _playSound('pop');
      },
      builder: (ctx, cand, rej) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.05),
            border: Border.all(
              color: cand.isNotEmpty ? const Color(0xFFFFC107) : borderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: val != null
              ? Text(
                  val,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildStep4Block(String val) {
    Widget child = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0x4D607D8B),
        border: Border.all(color: subTextColor),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        val,
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    return Draggable<String>(
      data: val,
      feedback: Material(color: const Color(0x00000000), child: child),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }

  Widget _buildToolBlock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x339C27B0),
        border: Border.all(color: const Color(0xFF9C27B0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.square_foot, color: Color(0xFFE040FB)),
          const SizedBox(width: 8),
          Text(
            _t("Tool √"),
            style: const TextStyle(
              color: Color(0xFFE040FB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _checkEq() {
    if (_eqSlot1 == '7' && _eqSlot2 == '25') {
      setState(() => _showCalc = true);
      _playSound('success');
    } else if (_eqSlot1 != null && _eqSlot2 != null) {
      _playSound('error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              "Hint: The hypotenuse (25) is the longest side and must be alone on one side of the equation!",
            ),
          ),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
      setState(() {
        _eqSlot1 = null;
        _eqSlot2 = null;
      });
    }
  }
}

class TrianglePainter extends CustomPainter {
  final double unit;
  final Color triangleColor;
  final Color borderColor;

  TrianglePainter({
    required this.unit,
    required this.triangleColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = triangleColor
      ..style = PaintingStyle.fill;

    final bPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(3 * unit, 0);
    path.lineTo(0, -4 * unit);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, bPaint);

    final anglePath = Path()
      ..moveTo(0, -10)
      ..lineTo(10, -10)
      ..lineTo(10, 0);
    canvas.drawPath(anglePath, bPaint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return oldDelegate.triangleColor != triangleColor ||
        oldDelegate.borderColor != borderColor;
  }
}