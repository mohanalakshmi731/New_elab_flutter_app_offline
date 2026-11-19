// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Requires 'audioplayers: ^5.2.1' in pubspec.yaml
import 'dart:ui';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Roboto', // Default fallback font
      ),
      home: const EvaluatingExpressionswithMultipleOperations(),
    ),
  );
}

class EvaluatingExpressionswithMultipleOperations extends StatefulWidget {
  const EvaluatingExpressionswithMultipleOperations({super.key});

  @override
  State<EvaluatingExpressionswithMultipleOperations> createState() =>
      _EvaluatingExpressionswithMultipleOperationsState();
}

class _EvaluatingExpressionswithMultipleOperationsState
    extends State<EvaluatingExpressionswithMultipleOperations> {
  // --- Global State ---
  bool _isSidebarOpen = true;
  int _currentScenario = 0;
  int _currentStep = 0;
  bool _showSuccessPopup = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- Shutter Screen State ---
  bool _isLabEntered = false;
  double _shutterOffset = 0.0;

  // --- Scenario 1 State (Shopkeeper) ---
  bool s1BiscuitInBag = false;
  bool s1DalInBag = false;
  bool s1IsCalculated = false;
  bool s1BagOnNote = false;
  bool s1IsComplete = false;

  // --- Scenario 2 State (Marble Factory) ---
  int s2BagsInMachine = 0; // 0 to 5
  bool s2MachineRun = false;
  bool s2Crate20OnBelt = false;
  bool s2Combined = false;
  bool s2IsComplete = false;

  // --- Translation State ---
  String _currentLanguage = 'EN';

  // --- Audio Tones ---
  final String clickSound =
      "audio/class7/mixkit_2568.mp3";
  final String successSound =
      "audio/class7/mixkit_2013.mp3";
  final String errorSound =
      "audio/class7/mixkit_2954.mp3";

  @override
  void initState() {
    super.initState();
    // Enforce Landscape and Immersive mode on load
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Revert orientations and UI mode when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _enterLab() {
    _playSound(successSound);
    setState(() {
      _shutterOffset = -MediaQuery.of(context).size.height;
    });
    // Wait for animation to finish before removing from tree
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLabEntered = true);
    });
  }

  void _fullReset() {
    _playSound(clickSound);

    // 1. Bring the shutter into the widget tree, hidden above
    setState(() {
      _isLabEntered = false;
      _shutterOffset = -MediaQuery.of(context).size.height;
      _showSuccessPopup = false;
    });

    // 2. Trigger the slide-down animation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _shutterOffset = 0.0;
        });
      }
    });

    // 3. Reset internal states AFTER the curtain completely covers the screen
    Future.delayed(const Duration(milliseconds: 850), () {
      if (mounted) {
        setState(() {
          _currentLanguage = 'EN';
          _currentScenario = 0;
          _resetLab();
        });
      }
    });
  }

  void _resetLab() {
    setState(() {
      _currentStep = 0;
      _showSuccessPopup = false;

      // Reset Scenario 1
      s1BiscuitInBag = false;
      s1DalInBag = false;
      s1IsCalculated = false;
      s1BagOnNote = false;
      s1IsComplete = false;

      // Reset Scenario 2
      s2BagsInMachine = 0;
      s2MachineRun = false;
      s2Crate20OnBelt = false;
      s2Combined = false;
      s2IsComplete = false;
    });
  }

  void _toggleLanguage() {
    _playSound(clickSound);
    setState(() {
      if (_currentLanguage == 'EN') {
        _currentLanguage = 'HI';
      } else {
        _currentLanguage = 'EN';
      }
    });
  }

  void _changeScenario(int index) {
    if (_currentScenario != index) {
      _currentScenario = index;
      _playSound(clickSound);
      _resetLab();
    }
  }

  void _validateStep() {
    if (_currentScenario == 0) {
      if (_currentStep == 0 && s1BiscuitInBag && s1DalInBag) {
        _playSound(successSound);
        setState(() => _currentStep = 1);
      } else if (_currentStep == 1 && s1IsCalculated) {
        _playSound(successSound);
        setState(() => _currentStep = 2);
      } else if (_currentStep == 2 && s1BagOnNote) {
        _playSound(successSound);
        setState(() {
          _currentStep = 3;
          s1IsComplete = true;
          _showSuccessPopup = true;
        });
      }
    } else if (_currentScenario == 1) {
      if (_currentStep == 0 && s2BagsInMachine == 5) {
        _playSound(successSound);
        setState(() => _currentStep = 1);
      } else if (_currentStep == 1 && s2MachineRun) {
        _playSound(successSound);
        setState(() => _currentStep = 2);
      } else if (_currentStep == 2 && s2Crate20OnBelt) {
        _playSound(successSound);
        setState(() => _currentStep = 3);
      } else if (_currentStep == 3 && s2Combined) {
        _playSound(successSound);
        setState(() {
          _currentStep = 4;
          s2IsComplete = true;
          _showSuccessPopup = true;
        });
      }
    }
  }

  // ---- LOCALIZATION DICTIONARY ----
  Map<String, Map<String, String>> get _locales => {
    "app-title": {
      "EN": "Evaluating Expressions with Multiple Operations",
      "HI": "एकाधिक संक्रियाओं वाले व्यंजकों का मूल्यांकन",
    },
    "app-subtitle": {
      "EN": "Class 7 • ARITHMETIC EXPRESSIONS",
      "HI": "कक्षा 7 • अंकगणितीय व्यंजक",
    },
    "btn-enter": {
      "EN": "Enter Virtual Lab",
      "HI": "वर्चुअल लैब में प्रवेश करें",
    },
    "lbl-select": {"EN": "SELECT SCENARIO", "HI": "परिदृश्य चुनें"},
    "lbl-mission": {"EN": "Mission Objective", "HI": "मिशन का उद्देश्य"},
    "lbl-theory": {"EN": "Theory", "HI": "सिद्धांत"},
    "lbl-steps": {"EN": "Procedural Steps", "HI": "प्रक्रियात्मक चरण"},
    "lbl-curtask": {"EN": "CURRENT TASK", "HI": "वर्तमान कार्य"},
    "sum-title": {"EN": "Summary", "HI": "सारांश"},
    "opt-scen0": {
      "EN": "1. The Shopkeeper's Change",
      "HI": "1. दुकानदार के छुट्टे",
    },
    "opt-scen1": {"EN": "2. The Marble Factory", "HI": "2. मार्बल फैक्ट्री"},
    "scenario_complete": {
      "EN": "Scenario Complete!",
      "HI": "परिदृश्य पूरा हुआ!",
    },
    "tool-reset": {"EN": "Reset", "HI": "रीसेट"},
    "btn-reset-try": {
      "EN": "Reset Lab / Try Again",
      "HI": "लैब रीसेट करें / पुनः प्रयास करें",
    },
    "footer": {
      "EN": "© ZeroScienceLab - Fall in love with math and Science",
      "HI": "© ZeroScienceLab - Fall in love with math and Science",
    },

    // Canvas specific translations
    "tag-cashier": {"EN": "Cashier Area", "HI": "कैशियर क्षेत्र"},
    "tag-counter": {"EN": "Counter", "HI": "काउंटर"},
    "tag-bag": {"EN": "Shopping Bag", "HI": "शॉपिंग बैग"},
    "3d-biscuit": {"EN": "₹15\nBiscuit", "HI": "₹15\nबिस्किट"},
    "3d-dal": {"EN": "₹56\nDal", "HI": "₹56\nदाल"},
    "btn-calc": {"EN": "Calculate Total", "HI": "कुल गणना करें"},
    "empty-bag": {"EN": "(   )", "HI": "(   )"},
    "drag-cashier": {"EN": "Drag to Cashier", "HI": "कैशियर तक खींचें"},
    "3d-30marbles": {"EN": "30 Marbles", "HI": "30 मार्बल"},
    "3d-50marbles": {"EN": "30 + 20 = 50", "HI": "30 + 20 = 50"},
    "3d-20marbles": {"EN": "5 × 4 = 20", "HI": "5 × 4 = 20"},
    "20-drag": {
      "EN": "5 × 4 = 20\n(Drag to Belt)",
      "HI": "5 × 4 = 20\n(बेल्ट पर खींचें)",
    },
    "place-here": {"EN": "Place Here", "HI": "यहां रखें"},
    "combine-crates": {"EN": "Combine Crates", "HI": "क्रेट्स को मिलाएं"},
    "pack-machine": {"EN": "Packaging Machine", "HI": "पैकेजिंग मशीन"},
    "bags-in": {"EN": "Bags:", "HI": "बैग:"},
    "run-machine": {"EN": "Run", "HI": "चलाएं"},
    "tag-main-conveyor": {"EN": "Main Conveyor", "HI": "मुख्य कन्वेयर"},
    "tag-mult-line": {"EN": "Multiplication Line", "HI": "गुणन रेखा"},
    "tag-combiner": {"EN": "Combiner", "HI": "कंबाइनर"},
  };

  String _loc(String key) {
    return _locales[key]?[_currentLanguage] ?? key;
  }

  // ---- SCENARIO DATA & CONTENT ----
  List<Map<String, dynamic>> get _scenarios => [
    {
      'equation': "100 - (15 + 56)",
      'EN': {
        'objective':
            "To visually understand why operations inside brackets must be performed first.",
        'theory':
            "Personal Budgeting / Shopping:\nWhen buying items, you must add their individual costs together *first* (the operation in the brackets) before subtracting the total from your cash amount.",
        'steps': [
          "Drag the biscuit packet (₹15) and the dal packet (₹56) into the 'Shopping Bag' (brackets).",
          "Click the 'Calculate Total' button on the Shopping Bag to resolve the expression inside the brackets.",
          "Drag the glowing Shopping Bag (value 71) to the Cashier area (₹100 note) to perform final subtraction.",
          "Observe the final result. Process Complete! 100 - 71 = 29",
        ],
        'summary':
            "To find the correct change, we first had to find the total cost of the items. The brackets ( ) told us to ADD the items inside them before doing anything else.\n\n100 – (15 + 56) becomes 100 – 71, which equals 29.",
      },
      'HI': {
        'objective':
            "दृश्य रूप से यह समझने के लिए कि कोष्ठक (brackets) के अंदर की संक्रियाएं पहले क्यों की जानी चाहिए।",
        'theory':
            "व्यक्तिगत बजट / खरीदारी:\nसामान खरीदते समय, आपको पहले उनकी व्यक्तिगत लागतों को जोड़ना होगा (कोष्ठक में संक्रिया) इससे पहले कि आप कुल नकद राशि से उसे घटाएं।",
        'steps': [
          "बिस्किट पैकेट (₹15) और दाल पैकेट (₹56) को 'शॉपिंग बैग' (कोष्ठक) में खींचें।",
          "कोष्ठक के अंदर के व्यंजक को हल करने के लिए शॉपिंग बैग पर 'कुल गणना करें' बटन पर क्लिक करें।",
          "अंतिम घटाव करने के लिए चमकते हुए शॉपिंग बैग (मान 71) को कैशियर क्षेत्र (₹100 नोट) में खींचें।",
          "अंतिम परिणाम का निरीक्षण करें। प्रक्रिया पूर्ण! 100 - 71 = 29",
        ],
        'summary':
            "सही छुट्टे प्राप्त करने के लिए, हमें पहले वस्तुओं की कुल लागत ज्ञात करनी थी। कोष्ठक ( ) ने हमें कुछ और करने से पहले उनके अंदर की वस्तुओं को जोड़ने के लिए कहा।\n\n100 – (15 + 56) बन जाता है 100 – 71, जो 29 के बराबर है।",
      },
    },
    {
      'equation': "30 + 5 × 4",
      'EN': {
        'objective':
            "To visually understand that multiplication is performed before addition when brackets are not present (Terms).",
        'theory':
            "Terms and Prioritization:\nParts of an expression involving multiplication or division (terms) act like separate machines on an assembly line. They must finish their work before their output is added or subtracted.",
        'steps': [
          "Drag all 5 bags (each containing 4 marbles) onto the 'Packaging Machine' input tray.",
          "Click 'Run' to process the multiplication.",
          "Drag the new 20-marble crate to the main conveyor belt next to the 30-marble crate.",
          "Click 'Combine' to merge the crates together.",
          "Observe the final result. Process Complete! 30 + 20 = 50",
        ],
        'summary':
            "The expression 30 + 5 × 4 has two parts, or 'terms': 30 and 5 × 4.\n\nThe factory processed the multiplication term first on its own line. Only after that was finished could we add the result to 30. This is why multiplication comes before addition.\n\nSummarizing the Learning:\n30 + [5 × 4] → 30 + 20 = 50",
      },
      'HI': {
        'objective':
            "दृश्य रूप से यह समझने के लिए कि कोष्ठक न होने पर जोड़ से पहले गुणा क्यों किया जाता है (पद)।",
        'theory':
            "पद और प्राथमिकता:\nगुणा या भाग (पद) वाले व्यंजक के भाग असेंबली लाइन पर अलग-अलग मशीनों की तरह काम करते हैं। उनके आउटपुट को जोड़ने या घटाने से पहले उन्हें अपना काम पूरा करना होगा।",
        'steps': [
          "सभी 5 बैग (प्रत्येक में 4 मार्बल) को 'पैकेजिंग मशीन' इनपुट ट्रे पर खींचें।",
          "गुणा को संसाधित करने के लिए 'चलाएं' पर क्लिक करें।",
          "नए 20-मार्बल क्रेट को 30-मार्बल क्रेट के बगल में मुख्य कन्वेयर बेल्ट पर खींचें।",
          "क्रेट्स को एक साथ मिलाने के लिए 'कंबाइन' पर क्लिक करें।",
          "अंतिम परिणाम का निरीक्षण करें। प्रक्रिया पूर्ण! 30 + 20 = 50",
        ],
        'summary':
            "व्यंजक 30 + 5 × 4 के दो भाग या 'पद' हैं: 30 और 5 × 4.\n\nफैक्ट्री ने गुणा वाले पद को पहले अपनी लाइन पर संसाधित किया। उसके समाप्त होने के बाद ही हम परिणाम को 30 में जोड़ सकते हैं। यही कारण है कि गुणा, जोड़ से पहले आता है।\n\nसीख का सारांश:\n30 + [5 × 4] → 30 + 20 = 50",
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Zoomable Canvas Area (Background)
            _buildCanvasArea(),

            // 2. Floating Mission Card (when sidebar is closed)
            if (!_isSidebarOpen && !_showSuccessPopup && _isLabEntered)
              _buildFloatingMissionCard(),

            // 3. Left Sidebar (30% width)
            if (_isSidebarOpen && _isLabEntered) _buildSidebar(context),

            // 4. Fixed Menu Toggle Button (Top Left)
            if (_isLabEntered)
              Positioned(
                top: 16,
                left: 16, // Fixed position, won't slide with sidebar
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.orangeAccent,
                  iconSize: 28,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _playSound(clickSound);
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                    ),
                  ),
                ),
              ),

            // 5. Scrollable Success Popup
            if (_showSuccessPopup && _isLabEntered) _buildSuccessPopup(),

            // 6. Shutter / Curtain Screen
            if (!_isLabEntered)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                top: _shutterOffset,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height,
                child: _buildShutterScreen(),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SHUTTER SCREEN COMPONENT
  // ==========================================

  Widget _buildShutterScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ], // Slate 900 to Slate 800
        ),
      ),
      child: Center(
        // Center content if screen is large
        child: SingleChildScrollView(
          // Allow scrolling if screen is small
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.science,
                    size: 70,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  _loc('app-title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _loc('app-subtitle'),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Enter Button
                ElevatedButton.icon(
                  onPressed: _enterLab,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(
                    _loc('btn-enter'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 15,
                    shadowColor: Colors.orangeAccent.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SIDEBAR & UI COMPONENTS
  // ==========================================

  Widget _buildSidebar(BuildContext context) {
    double sidebarWidth = MediaQuery.of(context).size.width * 0.35;
    // Clamp width to ensure readability on very wide or very narrow screens
    sidebarWidth = sidebarWidth.clamp(300.0, 450.0);

    // Safety references for scenario dictionary mappings
    final scenario = _scenarios[_currentScenario];
    final langData = scenario[_currentLanguage] as Map<String, dynamic>;

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: sidebarWidth,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95),
          border: const Border(
            right: BorderSide(color: Colors.white24, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header padding for the menu button
                  const SizedBox(height: 70),

                  // Header: Application Title and Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.science,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _loc('app-title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _loc('app-subtitle'),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tools: Language & Reset Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleLanguage,
                            icon: const Icon(Icons.language, size: 18),
                            label: Text(_currentLanguage),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _fullReset,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(_loc('tool-reset')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Scenario Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loc('lbl-select'),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _currentScenario,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E293B),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.orangeAccent,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text(_loc('opt-scen0')),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(_loc('opt-scen1')),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) _changeScenario(val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Scrollable Content Block
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Equation Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              scenario['equation'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Objective
                        Row(
                          children: [
                            const Icon(
                              Icons.track_changes,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _loc('lbl-mission'),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          langData['objective'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Theory
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book,
                                    color: Colors.orangeAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _loc('lbl-theory'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                langData['theory'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Steps
                        Text(
                          _loc('lbl-steps'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate((langData['steps'] as List).length, (
                          index,
                        ) {
                          bool isCurrent = _currentStep == index;
                          bool isPast = _currentStep > index;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.orangeAccent.withOpacity(0.15)
                                  : (isPast
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.transparent),
                              border: Border.all(
                                color: isCurrent
                                    ? Colors.orangeAccent
                                    : (isPast
                                          ? Colors.green.withOpacity(0.5)
                                          : Colors.white12),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isPast
                                      ? Icons.check_circle
                                      : (isCurrent
                                            ? Icons.play_circle_filled
                                            : Icons.circle_outlined),
                                  color: isPast
                                      ? Colors.green
                                      : (isCurrent
                                            ? Colors.orangeAccent
                                            : Colors.white38),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    langData['steps'][index],
                                    style: TextStyle(
                                      color: isPast
                                          ? Colors.white54
                                          : (isCurrent
                                                ? Colors.white
                                                : Colors.white38),
                                      decoration: isPast
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Pushes the footer to the bottom of the screen if the content is short
                  const Expanded(child: SizedBox(height: 20)),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    color: const Color(0xFF020617),
                    child: Text(
                      _loc('footer'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    final scenario = _scenarios[_currentScenario];
    final langData = scenario[_currentLanguage] as Map<String, dynamic>;
    final stepsList = langData['steps'] as List;

    String currentInstruction = _currentStep < stepsList.length
        ? stepsList[_currentStep]
        : _loc('scenario_complete');

    return Positioned(
      top: 64,
      left: 20,
      child: Center(
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orangeAccent.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orangeAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _loc('lbl-curtask'),
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentInstruction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopup() {
    final scenario = _scenarios[_currentScenario];
    final langData = scenario[_currentLanguage] as Map<String, dynamic>;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: Container(
            width: 500,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.orangeAccent, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // Spacer for centering
                        Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 50,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _loc('sum-title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () {
                            _playSound(clickSound);
                            setState(() => _showSuccessPopup = false);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        langData['summary'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  // Footer Buttons
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _fullReset();
                      },
                      child: Text(
                        _loc('btn-reset-try'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  // ==========================================
  // VIRTUAL CANVAS & SCENARIOS
  // ==========================================

  Widget _buildCanvasArea() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 5.0,
      constrained: false,
      panEnabled: true,
      scaleEnabled: true,
      child: SizedBox(
        width: 1400,
        height: 900,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Massive Infinite Background Layer
            Positioned(
              top: -10000,
              bottom: -10000,
              left: -10000,
              right: -10000,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  image: DecorationImage(
                    image: const AssetImage('assets/images/offline_texture.png'),
                    repeat: ImageRepeat.repeat,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.02),
                      BlendMode.dstIn,
                    ),
                  ),
                ),
              ),
            ),

            // Build the specific scenario interactive elements
            if (_currentScenario == 0) _buildScenario1Sleek(),
            if (_currentScenario == 1) _buildScenario2SideView(),
          ],
        ),
      ),
    );
  }

  // --- Scenario 1: Sleek Dark UI matching "image_640947.jpg" ---
  Widget _buildScenario1Sleek() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Gradient (Supermarket vibe)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
            ),
          ),
        ),

        // Main Counter/Shelf
        Positioned(
          top: 700,
          left: 50,
          right: 50,
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF475569), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
        ),

        // --- CASHIER AREA (LEFT) ---
        Positioned(
          top: 660,
          left: 120,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              _loc("tag-cashier"),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        // Cashier Target Note (Always visible)
        Positioned(
          top: 580,
          left: 150,
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return _build100Note(candidateData.isNotEmpty);
            },
            onWillAccept: (data) =>
                data == 'bag' && s1IsCalculated && !s1IsComplete,
            onAccept: (data) {
              setState(() => s1BagOnNote = true);
              _validateStep();
            },
          ),
        ),

        // --- ITEMS (MIDDLE) ---
        if (!s1BiscuitInBag)
          Positioned(
            top: 560,
            left: 500,
            child: Draggable<String>(
              data: 'biscuit',
              feedback: Material(
                color: Colors.transparent,
                child: Transform.scale(
                  scale: 0.6,
                  child: _buildSleekItem(
                    _loc("3d-biscuit"),
                    const Color(0xFF7C3AED),
                    Colors.white,
                    160,
                    90,
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildSleekItem(
                  _loc("3d-biscuit"),
                  const Color(0xFF7C3AED),
                  Colors.white,
                  160,
                  90,
                ),
              ),
              child: _buildSleekItem(
                _loc("3d-biscuit"),
                const Color(0xFF7C3AED),
                Colors.white,
                160,
                90,
              ),
            ),
          ),

        if (!s1DalInBag)
          Positioned(
            top: 490,
            left: 700,
            child: Draggable<String>(
              data: 'dal',
              feedback: Material(
                color: Colors.transparent,
                child: Transform.scale(
                  scale: 0.6,
                  child: _buildSleekItem(
                    _loc("3d-dal"),
                    const Color(0xFFEAB308),
                    Colors.black87,
                    130,
                    160,
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildSleekItem(
                  _loc("3d-dal"),
                  const Color(0xFFEAB308),
                  Colors.black87,
                  130,
                  160,
                ),
              ),
              child: _buildSleekItem(
                _loc("3d-dal"),
                const Color(0xFFEAB308),
                Colors.black87,
                130,
                160,
              ),
            ),
          ),

        // --- SHOPPING BAG (RIGHT) ---
        if (!s1BagOnNote)
          Positioned(
            top: 300,
            left: 900,
            child: Column(
              children: [
                DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    Widget bagVis = _buildSleekBag(candidateData.isNotEmpty);
                    if (s1IsCalculated) {
                      return Draggable<String>(
                        data: 'bag',
                        feedback: Material(
                          color: Colors.transparent,
                          // child: Transform.scale(scale: 0.85, child: bagVis),
                          child: Transform.scale(scale: 0.6, child: bagVis),
                        ),
                        childWhenDragging: Opacity(opacity: 0.3, child: bagVis),
                        child: bagVis,
                      );
                    }
                    return bagVis;
                  },
                  onWillAccept: (data) =>
                      (data == 'biscuit' || data == 'dal') && !s1IsCalculated,
                  onAccept: (data) {
                    setState(() {
                      if (data == 'biscuit') s1BiscuitInBag = true;
                      if (data == 'dal') s1DalInBag = true;
                    });
                    _playSound(clickSound);
                    if (s1BiscuitInBag && s1DalInBag) _validateStep();
                  },
                ),
                if (s1BiscuitInBag &&
                    s1DalInBag &&
                    !s1IsCalculated &&
                    _currentStep == 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _playSound(clickSound);
                        setState(() => s1IsCalculated = true);
                        _validateStep();
                      },
                      icon: const Icon(Icons.calculate),
                      label: Text(_loc('btn-calc')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // --- FINAL STATE (CALCULATION) ---
        if (s1BagOnNote)
          Positioned(
            top: 300,
            left: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.blueAccent, blurRadius: 20),
                    ],
                  ),
                  child: const Text(
                    "100 - 71 = 29",
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.orangeAccent,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.4),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "( 71 )",
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                          shadows: [
                            Shadow(color: Colors.orangeAccent, blurRadius: 15),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    _buildCoinsGraphic(),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // --- Sleek Item Helpers for Scenario 1 ---
  Widget _buildSleekItem(
    String label,
    Color color,
    Color textColor,
    double w,
    double h,
  ) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildSleekBag(bool isHovered) {
    Color glowColor = s1IsCalculated
        ? Colors.orangeAccent
        : Colors.lightBlueAccent;

    return Container(
      width: 280,
      height: 320,
      decoration: BoxDecoration(
        color: glowColor.withOpacity(0.05),
        border: Border.all(
          color: glowColor.withOpacity(isHovered || s1IsCalculated ? 1.0 : 0.4),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(
              isHovered || s1IsCalculated ? 0.3 : 0.1,
            ),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Bag Handle (Top)
          Positioned(
            top: -40,
            child: Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: glowColor.withOpacity(0.5), width: 8),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),

          // The Brackets
          Text(
            "(   )",
            style: TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.w300,
              color: glowColor,
              shadows: [Shadow(color: glowColor, blurRadius: 20)],
            ),
          ),

          // The Content inside
          if (s1BiscuitInBag && s1DalInBag && !s1IsCalculated)
            const Text(
              "15 + 56",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.white, blurRadius: 10)],
              ),
            ),
          if (s1IsCalculated)
            const Text(
              "71",
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.white, blurRadius: 15)],
              ),
            ),

          // Bottom Label Tag
          Positioned(
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                s1IsCalculated
                    ? "71"
                    : (s1BiscuitInBag && s1DalInBag
                          ? "15 + 56"
                          : _loc("tag-bag")),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build100Note(bool isHovered) {
    return Container(
      width: 240,
      height: 110,
      decoration: BoxDecoration(
        color: isHovered ? const Color(0xFFF3E8FF) : const Color(0xFFE9D5FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHovered ? Colors.white : const Color(0xFFC084FC),
          width: isHovered ? 4 : 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.account_balance,
              size: 100,
              color: Colors.purple.withOpacity(0.1),
            ),
          ),
          const Center(
            child: Text(
              "₹100",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B21A8),
                letterSpacing: 2,
              ),
            ),
          ),
          const Positioned(
            left: 10,
            top: 10,
            child: Text(
              "100",
              style: TextStyle(fontSize: 14, color: Color(0xFF9333EA)),
            ),
          ),
          const Positioned(
            right: 10,
            bottom: 10,
            child: Text(
              "100",
              style: TextStyle(fontSize: 14, color: Color(0xFF9333EA)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsGraphic() {
    return SizedBox(
      width: 180,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(20, (i) {
          double leftPos = (i * 27) % 140.0;
          double topPos = (i * 19) % 80.0;
          bool isGold = i % 3 != 0;
          return Positioned(
            left: leftPos,
            top: topPos,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGold ? Colors.amber : Colors.grey[300],
                border: Border.all(
                  color: isGold ? Colors.amber[700]! : Colors.grey[500]!,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.currency_rupee,
                size: 24,
                color: isGold ? Colors.amber[900] : Colors.grey[600],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGreyTag(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  // --- Scenario 2: Side-View Factory Visuals ---
  Widget _buildScenario2SideView() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Solid Factory Wall Background
        Positioned.fill(child: Container(color: const Color(0xFF454955))),

        // Factory Light Cones (Aesthetic)
        Positioned(top: 0, left: 200, child: _buildLightCone()),
        Positioned(top: 0, left: 800, child: _buildLightCone()),

        // Conveyor Belts
        // Upper belt (Multiplication line for bags)
        Positioned(top: 300, left: 50, child: _buildSideConveyor(350)),
        // Main bottom belt
        Positioned(top: 600, left: 0, child: _buildSideConveyor(1400)),

        // Structural Tags
        Positioned(
          top: 670,
          left: 150,
          child: _buildGreyTag(_loc("tag-main-conveyor")),
        ),
        Positioned(
          top: 350,
          left: 100,
          child: _buildGreyTag(_loc("tag-mult-line")),
        ),

        // Packaging Machine
        Positioned(top: 150, left: 400, child: _buildPackagingMachineVisual()),

        // Combiner Machine
        Positioned(top: 420, left: 650, child: _buildCombinerVisual()),
        Positioned(
          top: 390,
          left: 700,
          child: _buildGreyTag(_loc("tag-combiner")),
        ),

        // Crate 30 (Initial State on belt)
        if (!s2Combined)
          Positioned(
            top: 510,
            left: 200,
            child: _buildWoodenCrate(_loc("3d-30marbles"), 30),
          ),

        // Target Area on belt to drag Output Crate 20 (Next to Combiner)
        if (s2MachineRun && !s2Crate20OnBelt)
          Positioned(
            top: 510,
            left: 450,
            child: DragTarget<String>(
              onWillAccept: (data) => data == 'crate20',
              onAccept: (data) {
                setState(() => s2Crate20OnBelt = true);
                _validateStep();
              },
              builder: (context, candidateData, rejected) {
                return Container(
                  width: 140,
                  height: 90,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Colors.white24
                        : Colors.transparent,
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _loc("place-here"),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Result Crate 20 (Appears near machine outlet, draggable)
        if (s2MachineRun && !s2Crate20OnBelt)
          Positioned(
            top: 320,
            left: 700, // Appears falling out of machine
            child: Draggable<String>(
              data: 'crate20',
              feedback: Material(
                color: Colors.transparent,
                child: Transform.scale(
                  scale: 0.6,
                  child: _buildWoodenCrate(_loc("3d-20marbles"), 20),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildWoodenCrate(_loc("3d-20marbles"), 20),
              ),
              child: _buildWoodenCrate(_loc("20-drag"), 20),
            ),
          ),

        // Crate 20 placed On Belt
        if (s2Crate20OnBelt && !s2Combined)
          Positioned(
            top: 510,
            left: 450,
            child: _buildWoodenCrate(_loc("3d-20marbles"), 20),
          ),

        // Combine Button (Appears above Combiner when both are ready)
        if (s2Crate20OnBelt && !s2Combined && _currentStep == 3)
          Positioned(
            top: 360,
            left: 660,
            child: ElevatedButton.icon(
              onPressed: () {
                _playSound(clickSound);
                setState(() => s2Combined = true);
                _validateStep();
              },
              icon: const Icon(Icons.add_link),
              label: Text(_loc("combine-crates")),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Final Crate 50 (Appears out of the Combiner)
        if (s2Combined)
          Positioned(
            top: 510,
            left: 950,
            child: _buildWoodenCrate(_loc("3d-50marbles"), 50),
          ),

        // Draggable Bags (Input area on Upper Belt)
        for (int i = 0; i < 5; i++)
          if (s2BagsInMachine <= i)
            Positioned(
              top: 230,
              left: 80 + (i * 60).toDouble(),
              child: Draggable<String>(
                data: 'bag$i',
                feedback: Material(
                  color: Colors.transparent,
                  // child: Transform.scale(scale: 0.85, child: _buildPaperBag()),
                  child: Transform.scale(scale: 0.6, child: _buildPaperBag()),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildPaperBag(),
                ),
                child: _buildPaperBag(),
              ),
            ),
      ],
    );
  }

  // Visual Helper: Light Cone
  Widget _buildLightCone() {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.yellow.withOpacity(0.15), Colors.transparent],
        ),
      ),
    );
  }

  // Visual Helper: Packaging Machine with DragTarget
  Widget _buildPackagingMachineVisual() {
    return DragTarget<String>(
      onWillAccept: (data) =>
          data != null && data.startsWith('bag') && s2BagsInMachine < 5,
      onAccept: (data) {
        setState(() => s2BagsInMachine++);
        _playSound(clickSound);
        if (s2BagsInMachine == 5) _validateStep();
      },
      builder: (context, candidate, rejected) {
        bool isHovered = candidate.isNotEmpty;
        return Container(
          width: 280,
          height: 260,
          decoration: BoxDecoration(
            color: const Color(0xFF2C303A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? Colors.orangeAccent : const Color(0xFF1A1C20),
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(8, 8),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top input pipe
              Positioned(
                top: -30,
                left: 100,
                child: Container(
                  width: 80,
                  height: 30,
                  color: const Color(0xFF1A1C20),
                ),
              ),
              // Machine Label
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Text(
                  _loc("pack-machine").replaceAll('\n', ' '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Gear Window
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111318),
                    border: Border.all(
                      color: const Color(0xFF4A4E59),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: s2MachineRun
                        ? [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 20,
                        child: Icon(
                          Icons.settings,
                          color: s2MachineRun
                              ? Colors.yellow.shade700
                              : Colors.grey[700],
                          size: 60,
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 10,
                        child: Icon(
                          Icons.settings,
                          color: s2MachineRun
                              ? Colors.yellow.shade600
                              : Colors.grey[600],
                          size: 70,
                        ),
                      ),
                      Positioned(
                        left: 80,
                        bottom: 20,
                        child: Icon(
                          Icons.settings,
                          color: s2MachineRun
                              ? Colors.yellow.shade800
                              : Colors.grey[800],
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Lower HUD & Controls
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_loc('bags-in')} $s2BagsInMachine/5",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (s2BagsInMachine == 5 &&
                        !s2MachineRun &&
                        _currentStep == 1)
                      ElevatedButton(
                        onPressed: () {
                          _playSound(clickSound);
                          setState(() => s2MachineRun = true);
                          _validateStep();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          _loc("run-machine"),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Status Light
              Positioned(
                bottom: 15,
                right: 20,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: s2MachineRun ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Visual Helper: Combiner Machine
  Widget _buildCombinerVisual() {
    return Container(
      width: 220,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF333842),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: const Color(0xFF1A1C20), width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(5, 5), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Combiner",
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Futuristic Lights Panel
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF111318),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.change_history,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                const Icon(
                  Icons.change_history,
                  color: Colors.greenAccent,
                  size: 20,
                ),
                Container(
                  width: 15,
                  height: 4,
                  color: s2Combined ? Colors.greenAccent : Colors.yellowAccent,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Bottom opening
          Container(
            width: 100,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF111318),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // Visual Helper: Wooden Crate
  Widget _buildWoodenCrate(String label, int count) {
    return Container(
      width: 140,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF6B4423), // Wood color
        border: Border.all(color: const Color(0xFF3E2723), width: 3),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(3, 3), blurRadius: 4),
        ],
      ),
      child: Stack(
        children: [
          // Inner darkness showing marbles
          Positioned(
            top: 5,
            left: 5,
            right: 5,
            height: 35,
            child: Container(
              color: const Color(0xFF2A1A10),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 2,
                runSpacing: 2,
                children: List.generate(
                  count > 15 ? 15 : count,
                  (i) => Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A373),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black45, width: 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Label Box
          Positioned(
            bottom: 15,
            left: 10,
            right: 10,
            child: Container(
              color: const Color(0xFF1E2128),
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Visual Helper: Paper Bag
  Widget _buildPaperBag() {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFC19A6B),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
        border: Border.all(color: const Color(0xFF8B5A2B), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          // Folded top
          Container(height: 10, color: const Color(0xFFA07855)),
          const Spacer(),
          // Content Label
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "4",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // Visual Helper: Conveyor Belt wrapper
  Widget _buildSideConveyor(double width) {
    return SizedBox(
      width: width,
      height: 70,
      child: CustomPaint(painter: ConveyorPainter()),
    );
  }
}

// ==========================================
// CUSTOM PAINTERS FOR VISUALS
// ==========================================

class ConveyorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final beltPaint = Paint()..color = const Color(0xFF2A2D34);
    final edgePaint = Paint()..color = const Color(0xFF1A1C20);
    final rollerPaint = Paint()..color = const Color(0xFF5A5E6A);

    // Main belt body
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 20), beltPaint);
    canvas.drawRect(Rect.fromLTWH(0, 20, size.width, 10), edgePaint);

    // Rollers
    for (double i = 15; i < size.width; i += 30) {
      canvas.drawCircle(Offset(i, 25), 6, rollerPaint);
    }

    // Legs
    for (double i = 50; i < size.width; i += 200) {
      canvas.drawRect(Rect.fromLTWH(i, 30, 10, 40), edgePaint); // Leg
      canvas.drawRect(Rect.fromLTWH(i - 10, 65, 30, 5), edgePaint); // Foot
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
