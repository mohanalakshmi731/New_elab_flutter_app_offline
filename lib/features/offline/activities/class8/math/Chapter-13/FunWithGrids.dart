// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- MATH LOGIC & DATA ---
final List<List<int?>> calendarWeeks = [
  [null, null, null, null, null, 1, 2],
  [3, 4, 5, 6, 7, 8, 9],
  [10, 11, 12, 13, 14, 15, 16],
  [17, 18, 19, 20, 21, 22, 23],
  [24, 25, 26, 27, 28, 29, 30],
  [31, null, null, null, null, null, null],
];

const int rowsTotal = 6;
const int colsTotal = 7;

List<int> computeOffsets(int rows, int cols) {
  List<int> offsets = [];
  for (int dr = 0; dr < rows; dr++) {
    for (int dc = 0; dc < cols; dc++) {
      offsets.add(dr * 7 + dc);
    }
  }
  return offsets;
}

List<int?> computeRegionCells(int topRow, int topCol, int rows, int cols) {
  List<int?> cells = [];
  for (int dr = 0; dr < rows; dr++) {
    for (int dc = 0; dc < cols; dc++) {
      int r = topRow + dr;
      int c = topCol + dc;
      if (r < 0 || r >= rowsTotal || c < 0 || c >= colsTotal) {
        cells.add(null);
      } else {
        cells.add(calendarWeeks[r][c]);
      }
    }
  }
  return cells;
}

bool isCompleteRegion(List<int?> cells) {
  if (cells.isEmpty) return false;
  return cells.every((v) => v != null);
}

int computeSum(List<int?> cells) {
  if (!isCompleteRegion(cells)) return 0;
  return cells.fold(0, (sum, v) => sum + (v ?? 0));
}

class GridScenario {
  final String id;
  final String title;
  final String instruction;
  final String validateLabel;

  GridScenario({
    required this.id,
    required this.title,
    required this.instruction,
    required this.validateLabel,
  });
}

class FunWithGridsActivity extends StatefulWidget {
  const FunWithGridsActivity({Key? key}) : super(key: key);

  @override
  _FunWithGridsActivityState createState() => _FunWithGridsActivityState();
}

class _FunWithGridsActivityState extends State<FunWithGridsActivity> with SingleTickerProviderStateMixin {
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

  // Grid State
  int _highlighterTopRow = 0;
  int _highlighterTopCol = 0;
  int _highlighterRows = 2;
  int _highlighterCols = 2;

  // Evidence / Recorded Blocks
  List<Map<String, dynamic>> _evidenceBlocks = [];
  String _aGuessInput = "";
  
  Map<String, dynamic> _stepState = {};

  final Map<String, Map<String, dynamic>> _i18n = {
    "en": {
      "appTitle": "Fun with Grids: Calendar Magic",
      "tagline": "Class 8 • ALGEBRA PLAY",
      "objLabel": "Mission Objective",
      "conceptLabel": "Core Concepts",
      "outcomesLabel": "Analysis & Outcomes",
      "stepInfoLabel": "Current Step",
      "objDesc": "Explore calendar grids and derive the algebraic relationship 4a + 16 for any 2x2 block.",
      "conceptText": "A calendar is a 7-column grid where moving right adds 1, and moving down adds 7.",
      "outcomesText": "You proved that any 2x2 calendar block sums to 4a+16 and used it to find hidden dates.",
      "recordMsg": "Blocks recorded",
      "targetSum": "Given Sum",
      "sumLabel": "Selected Sum",
      "coeffLabel": "Coefficient of a",
      "constLabel": "Constant",
      "aGuessLabel": "Your value of a (a = ?)",
      "rowsLabel": "Rows",
      "colsLabel": "Columns",
      "evidenceLabel": "Recorded Blocks",
      "dragHint": "Click and drag the cyan highlighter across the calendar.",
      "shapeHint": "Pick rows and columns for your own trick (not 2x2).",
      "msgNeedExactBlock": "Not quite. Drag the highlighter until it sits exactly on the block reading 6, 7, 13, 14.",
      "msgNeedMoreEvidence": "Record at least 3 DIFFERENT 2x2 blocks before verifying.",
      "msgNeedAGuess": "Solve 4a + 16 = 36 for a first, then type your value.",
      "msgNeedMatchingBlock": "Your 'a' is right, but the highlighter isn't on the matching block.",
      "msgNeedDistinctShape": "Choose a shape that is NOT 2x2.",
      "msgNeedCompleteSelection": "Drag fully onto the calendar so all cells are real dates.",
      "msgNeedFormulaMatch": "Your formula doesn't match the live sum. Try again.",
      "msgMissionComplete": "MISSION ACCOMPLISHED!",
      "btnRestart": "RESTART MISSION",
      "scenarios": [
        {
          "id": "CAL-WORKED",
          "title": "Step 1 of 4: Find the Hidden Block",
          "instruction": "Drag the highlighter over the calendar until it covers the 2x2 block whose four dates sum to exactly 40. Watch the live Selected Sum meter, then press VERIFY.",
          "validateLabel": "VERIFY SUM = 40",
        },
        {
          "id": "CAL-ALGEBRA-A",
          "title": "Step 2 of 4: Prove the Pattern Everywhere",
          "instruction": "Drag the highlighter to at least 3 DIFFERENT 2x2 blocks. Each full block you drop is recorded. Confirm the coefficient of 'a' and constant never change, then press VERIFY.",
          "validateLabel": "VERIFY 3 BLOCKS",
        },
        {
          "id": "CAL-SOLVE-36",
          "title": "Step 3 of 4: Crack the Reverse Code",
          "instruction": "The sum of a 2x2 block is given as 36. Solve 4a + 16 = 36 for a, type your answer below, then drag the highlighter to the matching block.",
          "validateLabel": "VERIFY a = 5",
        },
        {
          "id": "CAL-CREATE-OWN",
          "title": "Step 4 of 4: Design Your Own Grid Trick",
          "instruction": "Choose a block shape that is NOT 2x2 (e.g. 1x3 or 3x1). Drag the highlighter to a full block of that shape and confirm your own sum formula matches the total.",
          "validateLabel": "VERIFY MY TRICK",
        },
      ]
    },
    "hi": {
      "appTitle": "ग्रिड का मज़ा: कैलेंडर जादू",
      "tagline": "कक्षा 8 • बीजगणित खेल",
      "objLabel": "मिशन उद्देश्य",
      "conceptLabel": "मुख्य अवधारणाएँ",
      "outcomesLabel": "विश्लेषण और परिणाम",
      "stepInfoLabel": "वर्तमान चरण",
      "objDesc": "कैलेंडर ग्रिड का अन्वेषण करें और किसी भी 2x2 ब्लॉक के लिए बीजगणितीय संबंध 4a + 16 निकालें।",
      "conceptText": "कैलेंडर 7-स्तंभों वाला एक ग्रिड है जहां दाईं ओर जाने पर 1 जुड़ता है, और नीचे जाने पर 7 जुड़ता है।",
      "outcomesText": "आपने सिद्ध किया कि किसी भी 2x2 कैलेंडर ब्लॉक का योग 4a+16 होता है और छिपी हुई तारीखों को खोजने के लिए इसका उपयोग किया।",
      "recordMsg": "दर्ज ब्लॉक",
      "targetSum": "दिया गया योग",
      "sumLabel": "चयनित योग",
      "coeffLabel": "a का गुणांक",
      "constLabel": "अचर (Constant)",
      "aGuessLabel": "आपका a का मान (a = ?)",
      "rowsLabel": "पंक्तियाँ",
      "colsLabel": "स्तंभ",
      "evidenceLabel": "दर्ज ब्लॉक",
      "dragHint": "हाइलाइटर को हिलाने के लिए खींचें।",
      "shapeHint": "अपनी खुद की ट्रिक के लिए पंक्तियाँ और स्तंभ चुनें (2x2 नहीं)।",
      "msgNeedExactBlock": "अभी सही नहीं है। हाइलाइटर को तब तक खींचें जब तक वह ठीक उस ब्लॉक पर न आ जाए जिसमें 6, 7, 13, 14 हों।",
      "msgNeedMoreEvidence": "सत्यापित करने से पहले कम से कम 3 अलग-अलग 2x2 ब्लॉक दर्ज करें।",
      "msgNeedAGuess": "पहले 4a + 16 = 36 को हल करके a ज्ञात करें, फिर अपना मान टाइप करें।",
      "msgNeedMatchingBlock": "आपका a सही है, लेकिन हाइलाइटर अभी सही ब्लॉक पर नहीं है।",
      "msgNeedDistinctShape": "ऐसा आकार चुनें जो 2x2 न हो।",
      "msgNeedCompleteSelection": "हाइलाइटर को कैलेंडर पर पूरी तरह से रखें ताकि सभी सेल तारीखें हों।",
      "msgNeedFormulaMatch": "आपका सूत्र लाइव योग से मेल नहीं खाता।",
      "msgMissionComplete": "मिशन पूरा हुआ!",
      "btnRestart": "पुनः आरंभ करें",
      "scenarios": [
        {
          "id": "CAL-WORKED",
          "title": "चरण 1/4: छिपा हुआ ब्लॉक खोजें",
          "instruction": "हाइलाइटर को तब तक खींचें जब तक वह उस 2x2 ब्लॉक को न ढक ले जिसका योग 40 हो।",
          "validateLabel": "योग = 40 सत्यापित करें",
        },
        {
          "id": "CAL-ALGEBRA-A",
          "title": "चरण 2/4: हर जगह पैटर्न सिद्ध करें",
          "instruction": "हाइलाइटर को 3 अलग-अलग 2x2 ब्लॉकों पर खींचें। पुष्टि करें कि गुणांक और अचर नहीं बदलते।",
          "validateLabel": "3 ब्लॉक सत्यापित करें",
        },
        {
          "id": "CAL-SOLVE-36",
          "title": "चरण 3/4: उल्टा कोड तोड़ें",
          "instruction": "योग 36 है। 4a + 16 = 36 हल करके a ज्ञात करें और हाइलाइटर को सही जगह रखें।",
          "validateLabel": "a = 5 सत्यापित करें",
        },
        {
          "id": "CAL-CREATE-OWN",
          "title": "चरण 4/4: अपनी खुद की ट्रिक बनाएं",
          "instruction": "ऐसा ब्लॉक आकार चुनें जो 2x2 न हो। हाइलाइटर को पूर्ण ब्लॉक आकार पर खींचें और पुष्टि करें।",
          "validateLabel": "मेरी ट्रिक सत्यापित करें",
        },
      ]
    },
  };

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );

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
    _pulseController.dispose();

    super.dispose();
  }

  String _t(String key) => _i18n[_currentLang]?[key] ?? _i18n['en']![key];
  List<GridScenario> _getScenarios() {
    var raw = _i18n[_currentLang]!['scenarios'] as List;
    return raw.map((s) => GridScenario(
      id: s['id'],
      title: s['title'],
      instruction: s['instruction'],
      validateLabel: s['validateLabel'],
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
      _aGuessInput = "";
      
      if (index == 1) _evidenceBlocks = [];
      if (index == 3) {
        _highlighterRows = 1;
        _highlighterCols = 3;
      } else {
        _highlighterRows = 2;
        _highlighterCols = 2;
      }

      // Safe neutral position
      _highlighterTopRow = 3;
      _highlighterTopCol = 0;
      if (index == 3) {
        _highlighterTopRow = max(0, min(rowsTotal - _highlighterRows, 1));
      }
      _highlighterTopRow = max(0, min(rowsTotal - _highlighterRows, _highlighterTopRow));
      _highlighterTopCol = max(0, min(colsTotal - _highlighterCols, _highlighterTopCol));
      
      _updateLiveReadouts();
    });
  }

  void _updateLiveReadouts() {
    List<int?> cells = computeRegionCells(_highlighterTopRow, _highlighterTopCol, _highlighterRows, _highlighterCols);
    bool complete = isCompleteRegion(cells);
    int sum = computeSum(cells);
    List<int> offsets = computeOffsets(_highlighterRows, _highlighterCols);
    int coefficient = _highlighterRows * _highlighterCols;
    int constant = offsets.fold(0, (s, v) => s + v);

    _stepState = {
      'cells': cells,
      'isComplete': complete,
      'sum': sum,
      'coefficient': coefficient,
      'constant': constant,
      'offsets': offsets,
    };
  }

  void _verifyStep() {
    var scenarios = _getScenarios();
    var scenario = scenarios[_currentStepIndex];
    bool isCorrect = false;
    String failMsg = "";

    if (scenario.id == "CAL-WORKED") {
      List<int?> cells = _stepState['cells'] ?? [];
      isCorrect = _stepState['isComplete'] && 
                  _stepState['sum'] == 40 &&
                  cells.length == 4 && cells[0] == 6 && cells[1] == 7 && cells[2] == 13 && cells[3] == 14;
      failMsg = _t('msgNeedExactBlock');
    } else if (scenario.id == "CAL-ALGEBRA-A") {
      isCorrect = _stepState['coefficient'] == 4 && _stepState['constant'] == 16 && _evidenceBlocks.length >= 3;
      failMsg = _t('msgNeedMoreEvidence');
    } else if (scenario.id == "CAL-SOLVE-36") {
      int solvedA = (36 - 16) ~/ 4; // 5
      int? guess = int.tryParse(_aGuessInput);
      List<int?> cells = _stepState['cells'] ?? [];
      bool guessOk = guess != null && guess == solvedA;
      bool blockOk = _stepState['isComplete'] && cells.length == 4 &&
                     cells[0] == 5 && cells[1] == 6 && cells[2] == 12 && cells[3] == 13;
      isCorrect = guessOk && blockOk;
      failMsg = !guessOk ? _t('msgNeedAGuess') : _t('msgNeedMatchingBlock');
    } else if (scenario.id == "CAL-CREATE-OWN") {
      if (_highlighterRows * _highlighterCols == 4) {
        failMsg = _t('msgNeedDistinctShape');
        isCorrect = false;
      } else if (!_stepState['isComplete']) {
        failMsg = _t('msgNeedCompleteSelection');
        isCorrect = false;
      } else {
        int aVal = (_stepState['cells'] as List<int?>).first!;
        isCorrect = (_stepState['constant'] + _stepState['coefficient'] * aVal) == _stepState['sum'];
        failMsg = _t('msgNeedFormulaMatch');
      }
    }

    if (isCorrect) {
      _playSound(_successPlayer, _successUrl);
      _pulseController.forward().then((_) => _pulseController.reverse());
      
      if (_currentStepIndex < scenarios.length - 1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Step Complete!", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 1),
        ));
        Future.delayed(const Duration(milliseconds: 1500), () {
          _loadStep(_currentStepIndex + 1);
        });
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

  void _onPanUpdate(DragUpdateDetails details, Size canvasSize) {
    if (_isCompleted) return;
    
    // Cell sizes based on actual padded drawing area
    double gridW = canvasSize.width * 0.8; 
    double gridH = canvasSize.height * 0.8;
    double startX = (canvasSize.width - gridW) / 2;
    double startY = (canvasSize.height - gridH) / 2;

    double cellWidth = gridW / colsTotal;
    double cellHeight = gridH / rowsTotal;
    
    // Find closest col and row
    double localX = details.localPosition.dx - startX - (cellWidth * _highlighterCols) / 2;
    double localY = details.localPosition.dy - startY - (cellHeight * _highlighterRows) / 2;
    
    int targetCol = (localX / cellWidth).round();
    int targetRow = (localY / cellHeight).round();
    
    targetCol = max(0, min(colsTotal - _highlighterCols, targetCol));
    targetRow = max(0, min(rowsTotal - _highlighterRows, targetRow));

    if (targetCol != _highlighterTopCol || targetRow != _highlighterTopRow) {
      setState(() {
        _highlighterTopCol = targetCol;
        _highlighterTopRow = targetRow;
        _updateLiveReadouts();
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _playSound(_clickPlayer, _clickUrl);
    if (_currentStepIndex == 1 && _stepState['isComplete']) {
      String key = "$_highlighterTopRow-$_highlighterTopCol";
      bool exists = _evidenceBlocks.any((e) => e['key'] == key);
      if (!exists) {
        setState(() {
          _evidenceBlocks.add({
            'key': key,
            'sum': _stepState['sum'],
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Apply a 3D perspective transform to make it look like the Three.js version
                    return Transform(
                      alignment: FractionalOffset.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateX(0.5) // tilt backward
                        ..rotateZ(-0.02), // slight dramatic angle
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (details) {
                          // With GestureDetector INSIDE the Transform, Flutter un-projects the 3D touches automatically!
                          _onPanUpdate(details, Size(constraints.maxWidth, constraints.maxHeight));
                        },
                        onPanEnd: _onPanEnd,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                              painter: CalendarGridPainter(
                                weeks: calendarWeeks,
                                hlRow: _highlighterTopRow,
                                hlCol: _highlighterTopCol,
                                hlRowsCount: _highlighterRows,
                                hlColsCount: _highlighterCols,
                                pulseScale: _pulseAnimation.value,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                ),
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
                  // SafeArea removed here to make it truly immersive
                  child: _buildSidebarContent(),
                ),
              ),

              // 3. Floating Action Button for Sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? MediaQuery.of(context).size.width * sidebarWidthPercent : 0,
                top: MediaQuery.of(context).size.height / 2 - 25,
                child: GestureDetector(
                  onTap: () {
                    _playSound(_clickPlayer, _clickUrl);
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                  child: Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(color: const Color(0xFF334155)),
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                    ),
                    child: Icon(
                      _isSidebarOpen ? Icons.chevron_left : Icons.chevron_right,
                      color: Colors.white,
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
                      const Icon(Icons.calendar_month, size: 100, color: Colors.cyan),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    var scenarios = _getScenarios();
    var scenario = scenarios[_currentStepIndex];

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.cyan, Colors.blue]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month, color: Colors.white),
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
            ],
          ),
        ),
        
        const Divider(color: Color(0xFF334155), height: 1),
        
        // Scrollable Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                    const SizedBox(height: 16),
                    _buildDynamicControlPanel(),
                    const SizedBox(height: 20),
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
            ],
          ),
        ),
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

  Widget _buildDynamicControlPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Readouts (Always visible)
        _buildReadoutRow(_t('sumLabel'), _stepState['isComplete'] ? "${_stepState['sum']}" : "—", Colors.cyanAccent),
        _buildReadoutRow(_t('coeffLabel'), "${_stepState['coefficient']}a", Colors.purpleAccent),
        _buildReadoutRow(_t('constLabel'), "+ ${_stepState['constant']}", Colors.purpleAccent),
        const SizedBox(height: 10),

        // Context Specific UI
        if (_currentStepIndex == 0)
          Row(children: [const Icon(Icons.touch_app, color: Colors.amber, size: 16), const SizedBox(width: 8), Expanded(child: Text(_t('dragHint'), style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)))]),
        
        if (_currentStepIndex == 1) ...[
          _buildReadoutRow(_t('evidenceLabel'), "${min(_evidenceBlocks.length, 3)}/3", Colors.greenAccent),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _evidenceBlocks.asMap().entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(6)),
                child: Text("#${e.key + 1}: sum=${e.value['sum']}", style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace')),
              );
            }).toList(),
          ),
        ],

        if (_currentStepIndex == 2) ...[
          _buildReadoutRow(_t('targetSum'), "36", Colors.amber),
          const SizedBox(height: 12),
          Text(_t('aGuessLabel'), style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black45,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: "a = ?",
              hintStyle: const TextStyle(color: Colors.white30),
            ),
            onChanged: (v) => _aGuessInput = v,
          ),
        ],

        if (_currentStepIndex == 3) ...[
          Row(children: [const Icon(Icons.shuffle, color: Colors.cyanAccent, size: 16), const SizedBox(width: 8), Expanded(child: Text(_t('shapeHint'), style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildNumberAdjuster(_t('rowsLabel'), _highlighterRows, (v) {
                setState(() { _highlighterRows = max(1, min(4, v)); _clampHighlighter(); });
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberAdjuster(_t('colsLabel'), _highlighterCols, (v) {
                setState(() { _highlighterCols = max(1, min(4, v)); _clampHighlighter(); });
              })),
            ],
          ),
          if (_highlighterRows * _highlighterCols == 4)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_t('msgNeedDistinctShape'), style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ]
      ],
    );
  }

  void _clampHighlighter() {
    _highlighterTopRow = max(0, min(rowsTotal - _highlighterRows, _highlighterTopRow));
    _highlighterTopCol = max(0, min(colsTotal - _highlighterCols, _highlighterTopCol));
    _updateLiveReadouts();
  }

  Widget _buildNumberAdjuster(String label, int val, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.remove, color: Colors.white, size: 16), onPressed: () => onChanged(val - 1)),
              Text("$val", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 16), onPressed: () => onChanged(val + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadoutRow(String label, String value, Color valueColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// --- GRID PAINTER ---
class CalendarGridPainter extends CustomPainter {
  final List<List<int?>> weeks;
  final int hlRow;
  final int hlCol;
  final int hlRowsCount;
  final int hlColsCount;
  final double pulseScale;

  CalendarGridPainter({
    required this.weeks,
    required this.hlRow,
    required this.hlCol,
    required this.hlRowsCount,
    required this.hlColsCount,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // We'll draw a centered flat grid that fills the canvas comfortably.
    double gridW = size.width * 0.8; 
    double gridH = size.height * 0.8;
    double startX = (size.width - gridW) / 2;
    double startY = (size.height - gridH) / 2;

    double cellW = gridW / colsTotal;
    double cellH = gridH / rowsTotal;
    
    // 1. Draw "Thickness" layer for all non-blank cells (simulates 3D depth)
    for (int r = 0; r < rowsTotal; r++) {
      for (int c = 0; c < colsTotal; c++) {
        if (weeks[r][c] == null) continue;
        
        Rect rect = Rect.fromLTWH(startX + c * cellW, startY + r * cellH, cellW, cellH);
        Rect paddedRect = rect.deflate(6);
        
        Paint depthPaint = Paint()
          ..color = const Color(0xFF0F172A) // slate-900
          ..style = PaintingStyle.fill;
          
        // Translate down (in 3D, this will look like it extends deeper)
        canvas.drawRRect(RRect.fromRectAndRadius(paddedRect.translate(0, 15), const Radius.circular(8)), depthPaint);
      }
    }

    // 2. Draw Top faces
    for (int r = 0; r < rowsTotal; r++) {
      for (int c = 0; c < colsTotal; c++) {
        Rect rect = Rect.fromLTWH(startX + c * cellW, startY + r * cellH, cellW, cellH);
        Rect paddedRect = rect.deflate(6);
        
        bool isBlank = weeks[r][c] == null;
        
        Paint bgPaint = Paint()
          ..color = isBlank ? Colors.transparent : const Color(0xFF1E293B) // slate-800
          ..style = PaintingStyle.fill;
          
        if (!isBlank) {
          canvas.drawRRect(RRect.fromRectAndRadius(paddedRect, const Radius.circular(8)), bgPaint);
          
          // Border
          Paint borderPaint = Paint()
            ..color = Colors.white.withOpacity(0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawRRect(RRect.fromRectAndRadius(paddedRect, const Radius.circular(8)), borderPaint);

          TextPainter tp = TextPainter(
            text: TextSpan(
              text: "${weeks[r][c]}",
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));
        }
      }
    }

    // 3. Draw Highlighter Overlay
    double hlX = startX + hlCol * cellW;
    double hlY = startY + hlRow * cellH;
    double hlW = hlColsCount * cellW;
    double hlH = hlRowsCount * cellH;
    
    Rect hlRect = Rect.fromLTWH(hlX, hlY, hlW, hlH);
    
    // Apply pulse scale from center
    Matrix4 transform = Matrix4.identity()
      ..translate(hlRect.center.dx, hlRect.center.dy)
      ..scale(pulseScale)
      ..translate(-hlRect.center.dx, -hlRect.center.dy);
      
    canvas.save();
    canvas.transform(transform.storage);

    Paint highlightFill = Paint()
      ..color = Colors.cyan.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    Paint highlightStroke = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin = StrokeJoin.round;

    RRect hlRRect = RRect.fromRectAndRadius(hlRect.deflate(2), const Radius.circular(16));
    canvas.drawRRect(hlRRect, highlightFill);
    canvas.drawRRect(hlRRect, highlightStroke);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CalendarGridPainter oldDelegate) {
    return hlRow != oldDelegate.hlRow || 
           hlCol != oldDelegate.hlCol || 
           hlRowsCount != oldDelegate.hlRowsCount || 
           hlColsCount != oldDelegate.hlColsCount || 
           pulseScale != oldDelegate.pulseScale;
  }
}
