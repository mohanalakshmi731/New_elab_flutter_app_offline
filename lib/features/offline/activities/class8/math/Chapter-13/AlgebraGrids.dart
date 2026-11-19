// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- DATA CLASSES ---
class AlgebraScenario {
  final String id;
  final String title;
  final String instruction;
  final String validateLabel;
  final List<String> shapes;
  final List<List<String>> gridRows;
  final List<int?> targetSums;

  AlgebraScenario({
    required this.id,
    required this.title,
    required this.instruction,
    required this.validateLabel,
    required this.shapes,
    required this.gridRows,
    required this.targetSums,
  });
}

class AlgebraGridsActivity extends StatefulWidget {
  const AlgebraGridsActivity({Key? key}) : super(key: key);

  @override
  _AlgebraGridsActivityState createState() => _AlgebraGridsActivityState();
}

class _AlgebraGridsActivityState extends State<AlgebraGridsActivity> with SingleTickerProviderStateMixin {
  // Config
  static const double sidebarWidthPercent = 0.38;
  String _currentLang = "en";
  int _currentStepIndex = 0;
  bool _isSidebarOpen = true;
  bool _isCompleted = false;
  bool _isShutterOpen = false;

  // Audio
  final AudioPlayer _introPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _introUrl = "audio/class8/mixkit_2574.mp3";
  static const String _clickUrl = "audio/class8/mixkit_2568.mp3";
  static const String _successUrl = "audio/class8/mixkit_2018.mp3";
  static const String _errorUrl = "audio/class8/mixkit_955.mp3";

  // Game State: -1 means unset
  int _dial1Value = -1;
  int _dial2Value = -1;
  List<String> _bonusRowShapes = [];
  String _bonusPredictionInput = "";
  bool _bonusRevealed = false;

  final Map<String, Map<String, dynamic>> _i18n = {
    "en": {
      "appTitle": "Algebra Grids Lab",
      "tagline": "Class 8 • ALGEBRA PLAY",
      "objLabel": "Mission Objective",
      "conceptLabel": "Core Concepts",
      "outcomesLabel": "Analysis & Outcomes",
      "stepInfoLabel": "Current Step",
      "objDesc": "Solve every symbol grid by finding the hidden shape values, and then predict the missing sum!",
      "conceptText": "Each shape secretly represents one fixed number. Solve row-sum equations by substitution to find every shape's value!",
      "outcomesText": "The substitution method solves any Algebra Grid, no matter how many shapes or rows it has!",
      "btnRestart": "RESTART MISSION",
      "msgMissionComplete": "MISSION ACCOMPLISHED!",
      "msgNeedAllDials": "Set BOTH shape-value dials before verifying.",
      "msgClue1": "Clue 1 does not balance yet. Adjust the dials.",
      "msgClue2": "Clue 2 does not balance yet. Keep Clue 1 true while you fix Clue 2.",
      "msgInconsistent": "Find the values that satisfy BOTH clues at once.",
      "msgNeedBonusRow": "Build your own Row 4 first: add at least one shape token, then type your predicted sum.",
      "msgBonusMismatch": "Your predicted sum does not match the actual recomputed sum. Try again.",
      "missingSumLabel": "Blank row (recomputed live)",
      "bonusTitle": "Bonus: Build Your Own Row",
      "bonusHint": "Click shapes to add them to your row, predict the sum, then reveal actual.",
      "bonusPredictLabel": "Your prediction:",
      "bonusRevealBtn": "Reveal Actual Sum",
      "bonusClearBtn": "Clear Row",
      "proofBtn": "Proceed to Next Step",
      "proofTitle": "Substitution Proof",
      "scenarios": [
        {
          "id": "ALG-WORKED",
          "title": "Scenario 1 of 3: Crack the Worked Example",
          "instruction": "Drag the SQUARE (S) dial until 3×S = 27. Then drag the RED CIRCLE (C) dial until 2×C + S = 19. Watch both clue beams level out, then press VERIFY.",
          "validateLabel": "VERIFY: S = 9, C = 5",
          "shapes": ["S", "C"],
          "gridRows": [
             ["S", "S", "S"],
             ["C", "C", "S"]
          ],
          "targetSums": [27, 19]
        },
        {
          "id": "ALG-GRID-A",
          "title": "Scenario 2 of 3: Solve Grid A",
          "instruction": "Two clues, two unknowns: 2S + C = 27 and 2C + S = 21. Solve by substitution, set both dials, check the blank row's live sum, then press VERIFY.",
          "validateLabel": "VERIFY GRID A",
          "shapes": ["S", "C"],
          "gridRows": [
             ["S", "S", "C"],
             ["C", "C", "S"],
             ["C", "S", "C"]
          ],
          "targetSums": [27, 21, null]
        },
        {
          "id": "ALG-GRID-B",
          "title": "Scenario 3 of 3: Solve Grid B + Build Your Own Row",
          "instruction": "Solve B + 2D = 18 and D + 2B = 15 for the blue circle and diamond. Check the blank row's sum, then build your OWN Row 4 from any shapes, predict its sum, and press VERIFY.",
          "validateLabel": "VERIFY GRID B + BONUS",
          "shapes": ["B", "D"],
          "gridRows": [
             ["B", "D", "D"],
             ["D", "B", "B"],
             ["D", "B", "B"]
          ],
          "targetSums": [18, 15, null]
        }
      ]
    },
    "hi": {
      "appTitle": "बीजगणित ग्रिड लैब",
      "tagline": "कक्षा 8 • बीजगणित खेल",
      "objLabel": "मिशन उद्देश्य",
      "conceptLabel": "मुख्य अवधारणाएँ",
      "outcomesLabel": "विश्लेषण और परिणाम",
      "stepInfoLabel": "वर्तमान चरण",
      "objDesc": "हर प्रतीक ग्रिड को छिपे हुए आकार के मूल्यों को ढूंढकर हल करें, और फिर लापता योग की भविष्यवाणी करें!",
      "conceptText": "प्रत्येक आकार गुप्त रूप से एक निश्चित संख्या का प्रतिनिधित्व करता है। हर आकार का मूल्य खोजने के लिए प्रतिस्थापन द्वारा पंक्ति-योग समीकरणों को हल करें!",
      "outcomesText": "प्रतिस्थापन विधि किसी भी बीजगणित ग्रिड को हल करती है, चाहे उसमें कितने भी आकार या पंक्तियाँ हों!",
      "btnRestart": "पुनः आरंभ करें",
      "msgMissionComplete": "मिशन पूरा हुआ!",
      "msgNeedAllDials": "सत्यापित करने से पहले दोनों आकृति-मान डायल सेट करें।",
      "msgClue1": "संकेत 1 अभी संतुलित नहीं है। डायल समायोजित करें।",
      "msgClue2": "संकेत 2 अभी संतुलित नहीं है। संकेत 1 को सही रखते हुए संकेत 2 ठीक करें।",
      "msgInconsistent": "वे मान खोजें जो दोनों संकेतों को एक साथ संतुष्ट करें।",
      "msgNeedBonusRow": "पहले अपनी खुद की पंक्ति बनाएं: कम से कम एक आकृति टोकन जोड़ें, फिर अपना अनुमानित योग टाइप करें।",
      "msgBonusMismatch": "आपका अनुमानित योग वास्तविक पुनर्गणित योग से मेल नहीं खाता। पुनः प्रयास करें।",
      "missingSumLabel": "रिक्त पंक्ति (लाइव पुनर्गणना)",
      "bonusTitle": "बोनस: अपनी खुद की पंक्ति बनाएं",
      "bonusHint": "आकृतियों को अपनी पंक्ति में जोड़ने के लिए क्लिक करें, योग का अनुमान लगाएं, फिर वास्तविक योग जांचें।",
      "bonusPredictLabel": "आपका अनुमान:",
      "bonusRevealBtn": "वास्तविक योग प्रकट करें",
      "bonusClearBtn": "पंक्ति साफ़ करें",
      "proofBtn": "अगले चरण पर आगे बढ़ें",
      "proofTitle": "प्रतिस्थापन प्रमाण",
      "scenarios": [
        {
          "id": "ALG-WORKED",
          "title": "परिदृश्य 1/3: वर्किंग उदाहरण हल करें",
          "instruction": "वर्ग (S) डायल को तब तक खींचें जब तक 3×S = 27 न हो जाए। फिर लाल वृत्त (C) डायल को तब तक खींचें जब तक 2×C + S = 19 न हो जाए। दोनों संकेत बीम के संतुलित होने की प्रतीक्षा करें, फिर VERIFY दबाएं।",
          "validateLabel": "सत्यापित करें: S = 9, C = 5",
          "shapes": ["S", "C"],
          "gridRows": [
             ["S", "S", "S"],
             ["C", "C", "S"]
          ],
          "targetSums": [27, 19]
        },
        {
          "id": "ALG-GRID-A",
          "title": "परिदृश्य 2/3: ग्रिड A हल करें",
          "instruction": "दो संकेत, दो अज्ञात: 2S + C = 27 और 2C + S = 21। प्रतिस्थापन से हल करें, दोनों डायल सेट करें, रिक्त पंक्ति का लाइव योग जांचें, फिर VERIFY दबाएं।",
          "validateLabel": "ग्रिड A सत्यापित करें",
          "shapes": ["S", "C"],
          "gridRows": [
             ["S", "S", "C"],
             ["C", "C", "S"],
             ["C", "S", "C"]
          ],
          "targetSums": [27, 21, null]
        },
        {
          "id": "ALG-GRID-B",
          "title": "परिदृश्य 3/3: ग्रिड B हल करें + अपनी पंक्ति बनाएं",
          "instruction": "नीले वृत्त और समचतुर्भुज के लिए B + 2D = 18 और D + 2B = 15 हल करें। रिक्त पंक्ति का योग जांचें, फिर किसी भी आकृतियों से अपनी खुद की पंक्ति बनाएं, उसके योग का अनुमान लगाएं, और VERIFY दबाएं।",
          "validateLabel": "ग्रिड B + बोनस सत्यापित करें",
          "shapes": ["B", "D"],
          "gridRows": [
             ["B", "D", "D"],
             ["D", "B", "B"],
             ["D", "B", "B"]
          ],
          "targetSums": [18, 15, null]
        }
      ]
    }
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _loadStep(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound(_introPlayer, _introUrl);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _introPlayer.dispose();
    _clickPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    super.dispose();
  }

  String _t(String key) => _i18n[_currentLang]?[key] ?? _i18n['en']![key];
  List<AlgebraScenario> _getScenarios() {
    var raw = _i18n[_currentLang]!['scenarios'] as List;
    return raw.map((s) => AlgebraScenario(
      id: s['id'],
      title: s['title'],
      instruction: s['instruction'],
      validateLabel: s['validateLabel'],
      shapes: List<String>.from(s['shapes']),
      gridRows: (s['gridRows'] as List).map((r) => List<String>.from(r)).toList(),
      targetSums: (s['targetSums'] as List).map((e) => e as int?).toList(),
    )).toList();
  }

  void _playSound(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) {
        await player.stop();
      }
      await player.play(AssetSource(url));
    } catch (_) {}
  }

  void _loadStep(int index) {
    setState(() {
      _currentStepIndex = index;
      _dial1Value = -1;
      _dial2Value = -1;
      _bonusRowShapes = [];
      _bonusPredictionInput = "";
      _bonusRevealed = false;
    });
  }

  int _getShapeValue(String shape, AlgebraScenario scenario) {
    if (shape == scenario.shapes[0]) return max(0, _dial1Value);
    if (scenario.shapes.length > 1 && shape == scenario.shapes[1]) return max(0, _dial2Value);
    return 0; // fallback
  }

  void _verifyStep() {
    var scenarios = _getScenarios();
    var scenario = scenarios[_currentStepIndex];
    bool isCorrect = true;
    String failMsg = "";

    if (_dial1Value < 0 || _dial2Value < 0) {
      _showErrorPopup(_t('msgNeedAllDials'));
      return;
    }

    // Check row clues
    for (int i = 0; i < scenario.gridRows.length; i++) {
      if (scenario.targetSums[i] != null) {
        int sum = scenario.gridRows[i].fold(0, (s, shape) => s + _getShapeValue(shape, scenario));
        if (sum != scenario.targetSums[i]) {
          isCorrect = false;
          if (i == 0) failMsg = _t('msgClue1');
          else if (i == 1) failMsg = _t('msgClue2');
          else failMsg = _t('msgInconsistent');
          break;
        }
      }
    }

    // Bonus checks for Scenario 3
    if (isCorrect && scenario.id == "ALG-GRID-B") {
      if (_bonusRowShapes.isEmpty || _bonusPredictionInput.isEmpty) {
        isCorrect = false;
        failMsg = _t('msgNeedBonusRow');
      } else {
        int actualSum = _bonusRowShapes.fold(0, (s, shape) => s + _getShapeValue(shape, scenario));
        int? predicted = int.tryParse(_bonusPredictionInput);
        if (predicted == null || predicted != actualSum) {
          isCorrect = false;
          failMsg = _t('msgBonusMismatch');
        }
      }
    }

    if (isCorrect) {
      _playSound(_successPlayer, _successUrl);
      if (_currentStepIndex < scenarios.length - 1) {
        _showConclusionPopup(scenario, scenarios);
      } else {
        setState(() {
          _isCompleted = true;
        });
      }
    } else {
      _playSound(_errorPlayer, _errorUrl);
      _showErrorPopup(failMsg);
    }
  }

  void _showConclusionPopup(AlgebraScenario scenario, List<AlgebraScenario> scenarios) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyan)),
          title: Row(
            children: [
              const Icon(Icons.verified, color: Colors.greenAccent),
              const SizedBox(width: 10),
              Text(_t('proofTitle'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentStepIndex == 0) ...[
                const Text("3 × S = 27  =>  S = 9", style: TextStyle(color: Colors.cyanAccent, fontSize: 20, fontFamily: 'monospace')),
                const SizedBox(height: 10),
                const Text("2 × C + S = 19  =>  2 × C + 9 = 19", style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'monospace')),
                const Text("2 × C = 10  =>  C = 5", style: TextStyle(color: Colors.amber, fontSize: 20, fontFamily: 'monospace')),
              ] else ...[
                const Text("Substitution complete!", style: TextStyle(color: Colors.white70)),
              ],
            ],
          ),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                _playSound(_clickPlayer, _clickUrl);
                Navigator.of(context).pop();
                _loadStep(_currentStepIndex + 1);
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(_t('proofBtn'), style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  void _showErrorPopup(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: Colors.pink.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    var scenarios = _getScenarios();
    var scenario = scenarios[_currentStepIndex];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617), // slate-950
        body: Stack(
          children: [
            if (_isShutterOpen) ...[
              // 1. Canvas Layer (Right side)
              Positioned(
                left: _isSidebarOpen ? MediaQuery.of(context).size.width * sidebarWidthPercent : 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: _buildCanvasArea(scenario),
              ),

              // 2. Sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? 0 : -(MediaQuery.of(context).size.width * sidebarWidthPercent),
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * sidebarWidthPercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.95), // slate-900
                    border: const Border(right: BorderSide(color: Color(0xFF334155), width: 1)),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: _buildSidebarContent(scenario),
                ),
              ),

              // 3. Floating Action Button for Sidebar - TOP LEFT OF SIDEBAR
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? MediaQuery.of(context).size.width * sidebarWidthPercent : 0,
                top: 0, // Absolute top edge
                child: GestureDetector(
                  onTap: () {
                    _playSound(_clickPlayer, _clickUrl);
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(color: const Color(0xFF334155)),
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15)),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                    ),
                    child: Icon(
                      _isSidebarOpen ? Icons.chevron_left : Icons.chevron_right,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              // 4. Mission Complete Overlay
              if (_isCompleted)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
                        const SizedBox(height: 20),
                        Text(_t('msgMissionComplete'), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(_t('outcomesText'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white70)),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            _playSound(_clickPlayer, _clickUrl);
                            setState(() {
                              _isCompleted = false;
                              _loadStep(0);
                            });
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: Text(_t('btnRestart'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ),
            ],

            // 5. Shutter Screen Overlay
            if (!_isShutterOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.grid_on, size: 100, color: Colors.cyan),
                      const SizedBox(height: 20),
                      Text(_t('appTitle'), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text(_t('tagline'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent, letterSpacing: 2.0)),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          _playSound(_clickPlayer, _introUrl);
                          setState(() {
                            _isShutterOpen = true;
                          });
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.black, size: 30),
                        label: const Text("START MISSION", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),

            // Footer Credits (Absolute bottom)
            if (_isShutterOpen)
              Positioned(
                bottom: 5,
                right: 20,
                child: IgnorePointer(
                  child: Text("ZeroScienceLab - Fall in love with math and Science", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarContent(AlgebraScenario scenario) {
    var scenarios = _getScenarios();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title & Controls
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.cyan, Colors.blue]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grid_view, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t('appTitle'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text(_t('tagline'), style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ToggleButtons(
              isSelected: [_currentLang == 'en', _currentLang == 'hi'],
              onPressed: (index) {
                _playSound(_clickPlayer, _clickUrl);
                setState(() => _currentLang = index == 0 ? 'en' : 'hi');
              },
              borderRadius: BorderRadius.circular(8),
              fillColor: Colors.cyan.withOpacity(0.2),
              selectedColor: Colors.cyanAccent,
              color: Colors.white54,
              constraints: const BoxConstraints(minWidth: 50, minHeight: 30),
              children: const [
                Text("EN", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("HI", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
              onPressed: () {
                _playSound(_clickPlayer, _clickUrl);
                setState(() {
                  _currentLang = 'en';
                  _currentStepIndex = 0;
                  _isCompleted = false;
                  _isShutterOpen = false;
                  _loadStep(0);
                });
              },
              tooltip: "Reset All",
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Color(0xFF334155), height: 1),
        const SizedBox(height: 20),

        _buildInfoCard(Icons.my_location, Colors.cyan, _t('objLabel'), _t('objDesc')),
        const SizedBox(height: 12),
        _buildInfoCard(Icons.lightbulb, Colors.amber, _t('conceptLabel'), _t('conceptText')),
        const SizedBox(height: 12),
        _buildInfoCard(Icons.analytics, Colors.purpleAccent, _t('outcomesLabel'), _t('outcomesText')),
        const SizedBox(height: 20),
        
        // Current Step Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(scenario.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  Text("STEP ${_currentStepIndex + 1}/${scenarios.length}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentStepIndex + 1) / scenarios.length,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.cyan, width: 4)),
                  color: Color(0xFF082F49), // cyan-900 with opacity
                ),
                child: Text(scenario.instruction, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              const SizedBox(height: 24),
              
              if (scenario.id == "ALG-GRID-B") ...[
                _buildSidebarBonusRowTray(scenario),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                  ),
                  onPressed: _verifyStep,
                  child: Text(scenario.validateLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, Color color, String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(title.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }

  // --- CANVAS AREA ---
  Widget _buildCanvasArea(AlgebraScenario scenario) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF1E293B), Color(0xFF020617)], // slate-800 to slate-950
        )
      ),
      child: Column(
        children: [
          // The 2D Balance Grid
          Expanded(
            flex: 2,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(scenario.gridRows.length, (i) {
                      return _buildBalanceRow(scenario.gridRows[i], scenario.targetSums[i], scenario);
                    }),
                  ],
                ),
              ),
            ),
          ),
          
          // The Dials Control Panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(top: BorderSide(color: Color(0xFF334155))),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialControl(scenario.shapes[0], _dial1Value, (v) {
                  _playSound(_clickPlayer, _clickUrl);
                  setState(() => _dial1Value = v);
                }),
                if (scenario.shapes.length > 1)
                  _buildDialControl(scenario.shapes[1], _dial2Value, (v) {
                    _playSound(_clickPlayer, _clickUrl);
                    setState(() => _dial2Value = v);
                  }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceRow(List<String> shapes, int? targetSum, AlgebraScenario scenario) {
    int liveSum = shapes.fold(0, (s, shape) => s + _getShapeValue(shape, scenario));
    
    // Calculate tilt: limit to max 0.3 radians
    double tilt = targetSum != null ? (liveSum - targetSum) * 0.05 : 0;
    tilt = tilt.clamp(-0.3, 0.3);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left Side: Shapes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10, width: 2),
            ),
            child: Row(
              children: shapes.map((s) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildShapeGraphic(s, 50),
              )).toList(),
            ),
          ),
          
          const SizedBox(width: 20),
          const Text("=", style: TextStyle(color: Colors.white54, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),

          // Right Side: Balance Beam Visual
          SizedBox(
            width: 200,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fulcrum Post
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 50,
                    decoration: BoxDecoration(color: const Color(0xFF475569), borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                // Tilting Beam
                Positioned(
                  bottom: 45,
                  child: Transform.rotate(
                    angle: tilt,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // The Beam Line
                        Container(
                          width: 160,
                          height: 10,
                          decoration: BoxDecoration(color: const Color(0xFF475569), borderRadius: BorderRadius.circular(5)),
                        ),
                        // Left Pan (Live Sum)
                        Positioned(
                          left: -20,
                          top: -35,
                          child: Container(
                            width: 50, height: 50,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: Colors.cyan, shape: BoxShape.circle),
                            child: Text("$liveSum", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        // Right Pan (Target Sum)
                        Positioned(
                          right: -20,
                          top: -35,
                          child: Container(
                            width: 50, height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: targetSum != null ? Colors.amber : Colors.purple, shape: BoxShape.circle),
                            child: Text(targetSum != null ? "$targetSum" : "?", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- BONUS ROW SIDEBAR TRAY ---
  Widget _buildSidebarBonusRowTray(AlgebraScenario scenario) {
    int liveSum = _bonusRowShapes.fold(0, (s, shape) => s + _getShapeValue(shape, scenario));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 6),
              Text(_t('bonusTitle'), style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          
          // Shape picker palette
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: ["S", "C", "B", "D"].map((s) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _playSound(_clickPlayer, _clickUrl);
                if (_bonusRowShapes.length < 5) {
                  setState(() {
                    _bonusRowShapes.add(s);
                    _bonusRevealed = false;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: _buildShapeGraphic(s, 24),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),

          // Built Row Display
          Container(
            constraints: const BoxConstraints(minHeight: 40),
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _bonusRowShapes.isEmpty 
              ? const Center(child: Text("Empty", style: TextStyle(color: Colors.white30, fontSize: 12)))
              : Wrap(
                  spacing: 4,
                  children: _bonusRowShapes.asMap().entries.map((entry) => GestureDetector(
                    onTap: () {
                      _playSound(_clickPlayer, _clickUrl);
                      setState(() {
                        _bonusRowShapes.removeAt(entry.key);
                        _bonusRevealed = false;
                      });
                    },
                    child: _buildShapeGraphic(entry.value, 24),
                  )).toList(),
                ),
          ),
          const SizedBox(height: 12),

          // Prediction Input & Reveal
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    hintText: _t('bonusPredictLabel'),
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => _bonusPredictionInput = v,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onPressed: _bonusRowShapes.isNotEmpty ? () {
                  _playSound(_clickPlayer, _clickUrl);
                  setState(() => _bonusRevealed = true);
                } : null,
                child: const Icon(Icons.visibility, color: Colors.white, size: 16),
              )
            ],
          ),
          
          if (_bonusRevealed) ...[
            const SizedBox(height: 8),
            Text("Actual Sum: $liveSum", style: const TextStyle(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }

  Widget _buildShapeGraphic(String type, double size) {
    switch (type) {
      case 'S': return _buildIconShape(Icons.crop_square, Colors.cyan, 'S', size);
      case 'C': return _buildIconShape(Icons.circle, Colors.redAccent, 'C', size);
      case 'B': return _buildIconShape(Icons.circle, Colors.blueAccent, 'B', size);
      case 'D': return _buildIconShape(Icons.diamond, Colors.amber, 'D', size);
      default: return SizedBox(width: size, height: size);
    }
  }

  Widget _buildIconShape(IconData icon, Color color, String label, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: size * 0.8),
          Text(label, style: TextStyle(color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildDialControl(String shape, int value, Function(int) onChanged) {
    Color color;
    switch (shape) {
      case 'S': color = Colors.cyan; break;
      case 'C': color = Colors.redAccent; break;
      case 'B': color = Colors.blueAccent; break;
      case 'D': color = Colors.amber; break;
      default: color = Colors.white;
    }

    return Container(
      width: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShapeGraphic(shape, 30),
              const SizedBox(width: 10),
              Text(value < 0 ? "Value: ?" : "Value: $value", style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 30),
                onPressed: () => onChanged(max(0, (value < 0 ? 0 : value) - 1)),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: color,
                    inactiveTrackColor: color.withOpacity(0.2),
                    thumbColor: color,
                    overlayColor: color.withOpacity(0.2),
                    trackHeight: 8,
                  ),
                  child: Slider(
                    value: (value < 0 ? 0 : value).toDouble(),
                    min: 0,
                    max: 20,
                    divisions: 20,
                    onChanged: (v) => onChanged(v.toInt()),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white54, size: 30),
                onPressed: () => onChanged(min(20, (value < 0 ? 0 : value) + 1)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
