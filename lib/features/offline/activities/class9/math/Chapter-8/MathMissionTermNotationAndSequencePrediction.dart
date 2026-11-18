// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Pattern Quest: Sequence Membership',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFEAB308),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Segoe UI',
      ),
      home: const MathMissionTermNotationAndSequencePrediction(),
    ),
  );
}

// --- Data Models & Engine ---

class Vector3 {
  double x, y, z;
  Vector3(this.x, this.y, this.z);

  Vector3 clone() => Vector3(x, y, z);
}

class HitBox {
  final Offset center;
  final double radius;
  final Object id;
  final String type;

  HitBox(this.center, this.radius, this.id, this.type);
}

class S1Data {
  List<int> positions = [1, 2, 3, 12, 18, 50];
  Map<int, double?> placedPillars = {};

  S1Data() {
    for (var n in positions) {
      placedPillars[n] = null;
    }
  }

  void reset() {
    for (var n in positions) {
      placedPillars[n] = null;
    }
  }
}

class CandidateOrb {
  int value;
  Vector3 originalPos;
  Vector3 currentPos;
  bool isAnimating = false;
  String? sortedPortal;
  Vector3? targetPos;

  CandidateOrb({required this.value, required this.originalPos})
    : currentPos = originalPos.clone();
}

class S2Data {
  List<int> candidateValues = [332, 20, 100, 45];
  List<CandidateOrb> orbs = [];
  Map<int, String> placements = {};

  S2Data() {
    _initOrbs();
  }

  void _initOrbs() {
    orbs.clear();
    double startX = -7.5;
    double spacing = 5;
    for (int i = 0; i < candidateValues.length; i++) {
      orbs.add(
        CandidateOrb(
          value: candidateValues[i],
          originalPos: Vector3(startX + i * spacing, 2, 5),
        ),
      );
    }
  }

  void reset() {
    placements.clear();
    _initOrbs();
  }
}

// --- Main Simulation Screen ---

class MathMissionTermNotationAndSequencePrediction extends StatefulWidget {
  const MathMissionTermNotationAndSequencePrediction({super.key});

  @override
  State<MathMissionTermNotationAndSequencePrediction> createState() =>
      _MathMissionTermNotationAndSequencePredictionState();
}

class _MathMissionTermNotationAndSequencePredictionState
    extends State<MathMissionTermNotationAndSequencePrediction>
    with SingleTickerProviderStateMixin {
  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;

  String _lang = 'en';
  int _currentScenario = 1;

  // S1 specific UI
  int _s1SelectedN = 1;
  final TextEditingController _s1YController = TextEditingController();

  // S2 specific UI
  CandidateOrb? _selectedOrb;

  // Graphics & Camera
  final GlobalKey _canvasKey = GlobalKey();
  Offset _pan = const Offset(0, 50);
  double _zoom = 1.2;
  Offset _basePan = Offset.zero;
  double _baseZoom = 1.0;
  Offset _focalStart = Offset.zero;

  // Game Engine
  late AnimationController _gameLoop;
  final S1Data _s1Data = S1Data();
  final S2Data _s2Data = S2Data();
  double _time = 0;
  List<HitBox> _currentHitBoxes = [];

  // Feedback
  String _feedbackMessage = '';
  bool _feedbackIsSuccess = true;
  bool _showFeedback = false;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    // Immersive & Landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _gameLoop.addListener(_updateLoop);
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _updateLoop() {
    setState(() {
      _time += 0.016; // Approx 60fps delta

      // Animate S2 Orbs
      if (_currentScenario == 2) {
        for (var orb in _s2Data.orbs) {
          if (!orb.isAnimating && orb.sortedPortal == null) {
            orb.currentPos.y = 2 + 0.5 * sin(_time * 2 + orb.currentPos.x);
          } else if (orb.isAnimating && orb.targetPos != null) {
            // Lerp towards target
            orb.currentPos.x += (orb.targetPos!.x - orb.currentPos.x) * 0.1;
            orb.currentPos.y += (orb.targetPos!.y - orb.currentPos.y) * 0.1;
            orb.currentPos.z += (orb.targetPos!.z - orb.currentPos.z) * 0.1;

            // Check arrival
            double dist = sqrt(
              pow(orb.targetPos!.x - orb.currentPos.x, 2) +
                  pow(orb.targetPos!.y - orb.currentPos.y, 2) +
                  pow(orb.targetPos!.z - orb.currentPos.z, 2),
            );
            if (dist < 0.5) {
              orb.isAnimating = false;
              // Snapped
            }
          }
        }
      }
    });
  }

  void _showHUDFeedback(String msg, bool isSuccess) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackIsSuccess = isSuccess;
      _showFeedback = true;
    });
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showFeedback = false);
      }
    });
  }

  void _validate() {
    if (_currentScenario == 1) {
      bool allCorrect = true;
      int count = 0;
      for (var n in _s1Data.positions) {
        var val = _s1Data.placedPillars[n];
        if (val == null) {
          allCorrect = false;
        } else {
          count++;
          if (val != (3 * n - 7)) allCorrect = false;
        }
      }
      if (count < _s1Data.positions.length) allCorrect = false;
      _showHUDFeedback(
        allCorrect ? tr('feedbackS1Success') : tr('feedbackS1Fail'),
        allCorrect,
      );
    } else {
      bool allCorrect = true;
      int count = 0;
      for (var v in _s2Data.candidateValues) {
        var placement = _s2Data.placements[v];
        if (placement == null) {
          allCorrect = false;
        } else {
          count++;
          double n = (v + 7) / 3;
          bool isMem = (n >= 1 && n == n.roundToDouble());
          String expected = isMem ? 'member' : 'notmember';
          if (placement != expected) allCorrect = false;
        }
      }
      if (count < _s2Data.candidateValues.length) allCorrect = false;
      _showHUDFeedback(
        allCorrect ? tr('feedbackS2Success') : tr('feedbackS2Fail'),
        allCorrect,
      );
    }
  }

  void _constructS1Pillar() {
    // Terms of t_n = 3n - 7 are integers. Parsing as int keeps the drawn
    // pillar label and the graded value identical (a double like 2.4 used to
    // be drawn as "2" but graded wrong). Accept a typographic minus too.
    final String text = _s1YController.text.trim().replaceAll('−', '-');
    final int? y = int.tryParse(text);
    if (y == null) {
      _showHUDFeedback(tr('feedbackInvalidInput'), false);
      return;
    }
    setState(() {
      _s1Data.placedPillars[_s1SelectedN] = y.toDouble();
    });
  }

  void _resetScene() {
    setState(() {
      _s1Data.reset();
      _s2Data.reset();
      _selectedOrb = null;
      _s1YController.clear();
      _pan = const Offset(0, 50);
      _zoom = 1.2;
    });
  }

  // Interaction
  void _handleScaleStart(ScaleStartDetails details) {
    _basePan = _pan;
    _baseZoom = _zoom;
    _focalStart = details.localFocalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _zoom = (_baseZoom * details.scale).clamp(0.2, 5.0);
      _pan = _basePan + (details.localFocalPoint - _focalStart);
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (_currentScenario != 2) return;
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset localPos = details.localPosition;

    // Check hitboxes
    for (var hit in _currentHitBoxes) {
      if ((localPos - hit.center).distance <= hit.radius) {
        if (hit.type == 'orb') {
          // Select orb
          int val = hit.id as int;
          CandidateOrb? orb = _s2Data.orbs.firstWhere((o) => o.value == val);
          if (orb.sortedPortal == null) {
            setState(() {
              _selectedOrb = orb;
            });
          }
        } else if (hit.type == 'portal' && _selectedOrb != null) {
          // Sort selected orb into portal
          String portalType = hit.id as String;
          setState(() {
            _s2Data.placements[_selectedOrb!.value] = portalType;
            _selectedOrb!.sortedPortal = portalType;
            _selectedOrb!.isAnimating = true;
            _selectedOrb!.targetPos = portalType == 'member'
                ? Vector3(-8, 3, -4)
                : Vector3(8, 3, -4);
            _selectedOrb = null;
          });
        }
        return;
      }
    }

    // Clicked empty space
    setState(() => _selectedOrb = null);
  }

  // Translations
  final Map<String, Map<String, String>> _dict = {
    'en': {
      'title': "Pattern Quest: Sequence Membership",
      'subtitle': "Class 9 • Predicting What Comes Next",
      'enterLab': "Enter Lab",
      'scenario1': "Scenario 1: Build the Sequence",
      'scenario2': "Scenario 2: Membership Test",
      'missionObjective': "Mission Objective",
      's1Desc':
          "The sequence follows the explicit rule t_n = 3n - 7. Construct the pillars for the required positions n.",
      's1Steps':
          "Procedural Steps:\n\n1. Select a position n in the bottom HUD.\n\n2. Calculate the term value t_n and enter it into the Y input.\n\n3. Click 'Construct Pillar' to place it.\n\n4. Construct all required pillars (1, 2, 3, 12, 18, 50).\n\n5. Click Validate Model to confirm your computations.",
      's2Desc':
          "Become a membership detective: for each glowing mystery candidate, solve 3n - 7 = value for n and decide if it belongs to the sequence.",
      's2Steps':
          "Procedural Steps:\n\n1. Observe the floating candidates (Values: 332, 20, 100, 45).\n\n2. Solve the equation for n. If n is a whole number (1, 2, 3...), it is a Member.\n\n3. Tap a candidate to select it, then tap on the 'Member' or 'Not a Member' portal to sort it.\n\n4. Sort all candidates.\n\n5. Click Validate Model to confirm your analysis.",
      'validateBtn': "VALIDATE MODEL",
      'hudS1Title': "Sequence Construction",
      'hudS1Subtitle': "Rule: t_n = 3n - 7",
      'hudS2Title': "Membership Sorting",
      'hudS2Subtitle': "Select a candidate to sort",
      'btnConstruct': "Construct Pillar",
      'memberPortal': "Member",
      'nonMemberPortal': "Not Member",
      'feedbackS1Success':
          "Outstanding! You've correctly computed and constructed all terms in the sequence.",
      'feedbackS1Fail':
          "Some pillars have incorrect heights or are missing. Remember t_n = 3n - 7. Check your calculations.",
      'feedbackInvalidInput':
          "Enter a whole number for the term value (negative numbers are allowed).",
      'feedbackS2Success':
          "Brilliant! You correctly identified which candidates have natural-number positions.",
      'feedbackS2Fail':
          "Some candidates are sorted incorrectly. Remember: solve for n = (value+7)/3. If n is a whole number, it's a Member.",
      'footer': "© ZEROSCIENCELAB | Fall in Love with Math and Science",
    },
    'hi': {
      'title': "पैटर्न खोज: अनुक्रम सदस्यता",
      'subtitle': "कक्षा 9 • आगे क्या होगा इसकी भविष्यवाणी करना",
      'enterLab': "प्रयोगशाला में प्रवेश करें",
      'scenario1': "परिदृश्य 1: अनुक्रम बनाएँ",
      'scenario2': "परिदृश्य 2: सदस्यता परीक्षण",
      'missionObjective': "मिशन का उद्देश्य",
      's1Desc':
          "अनुक्रम स्पष्ट नियम t_n = 3n - 7 का पालन करता है। आवश्यक स्थितियों n के लिए स्तंभों का निर्माण करें।",
      's1Steps':
          "प्रक्रियात्मक चरण:\n\n1. निचले HUD में एक स्थिति n चुनें।\n\n2. पद मान t_n की गणना करें और इसे Y इनपुट में दर्ज करें।\n\n3. इसे रखने के लिए 'स्तंभ बनाएँ' पर क्लिक करें।\n\n4. सभी आवश्यक स्तंभ (1, 2, 3, 12, 18, 50) बनाएँ।\n\n5. अपनी गणनाओं की पुष्टि करने के लिए मॉडल मान्य करें पर क्लिक करें।",
      's2Desc':
          "एक सदस्यता जासूस बनें: प्रत्येक रहस्यमयी उम्मीदवार के लिए, n के लिए 3n - 7 = मान हल करें और तय करें कि क्या यह अनुक्रम का है।",
      's2Steps':
          "प्रक्रियात्मक चरण:\n\n1. तैरते हुए उम्मीदवारों (मान: 332, 20, 100, 45) का निरीक्षण करें।\n\n2. n के लिए समीकरण हल करें। यदि n एक पूर्ण संख्या (1, 2, 3...) है, तो यह सदस्य है।\n\n3. एक उम्मीदवार का चयन करने के लिए उस पर टैप करें, फिर उसे क्रमबद्ध करने के लिए 'सदस्य' या 'सदस्य नहीं' पोर्टल पर टैप करें।\n\n4. सभी उम्मीदवारों को क्रमबद्ध करें।\n\n5. अपने विश्लेषण की पुष्टि करने के लिए मॉडल मान्य करें पर क्लिक करें।",
      'validateBtn': "मॉडल मान्य करें",
      'hudS1Title': "अनुक्रम निर्माण",
      'hudS1Subtitle': "नियम: t_n = 3n - 7",
      'hudS2Title': "सदस्यता छँटाई",
      'hudS2Subtitle': "छांटने के लिए एक उम्मीदवार चुनें",
      'btnConstruct': "स्तंभ बनाएँ",
      'memberPortal': "सदस्य",
      'nonMemberPortal': "सदस्य नहीं",
      'feedbackS1Success':
          "बहुत बढ़िया! आपने अनुक्रम में सभी पदों की सही गणना और निर्माण किया है।",
      'feedbackS1Fail':
          "कुछ स्तंभों की ऊँचाई गलत है या गायब हैं। याद रखें t_n = 3n - 7। अपनी गणनाओं की जाँच करें।",
      'feedbackInvalidInput':
          "पद के मान के लिए एक पूर्णांक दर्ज करें (ऋणात्मक संख्याएँ भी मान्य हैं)।",
      'feedbackS2Success':
          "शानदार! आपने सही ढंग से पहचाना कि किन उम्मीदवारों की प्राकृतिक संख्या की स्थिति है।",
      'feedbackS2Fail':
          "कुछ उम्मीदवारों को गलत तरीके से क्रमबद्ध किया गया है। याद रखें: n = (मान+7)/3 के लिए हल करें। यदि n एक पूर्ण संख्या है, तो यह सदस्य है।",
      'footer': "© ZEROSCIENCELAB | गणित और विज्ञान से प्यार करें",
    },
  };

  String tr(String key) {
    return _dict[_lang]?[key] ?? _dict['en']![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    // Root GestureDetector for immersive enforcement
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // --- Canvas Area ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onTapUp:
                    _handleTapUp, // Changed to onTapUp to avoid interference with dragging
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: CustomPaint(
                    key: _canvasKey,
                    painter: SimulationPainter(
                      scenario: _currentScenario,
                      s1Data: _s1Data,
                      s2Data: _s2Data,
                      pan: _pan,
                      zoom: _zoom,
                      time: _time,
                      selectedOrb: _selectedOrb,
                      langDict: _dict[_lang] ?? _dict['en']!,
                      onHitBoxesUpdated: (boxes) {
                        _currentHitBoxes = boxes;
                      },
                    ),
                    child: Stack(
                      children: [
                        // Feedback HUD
                        if (_showFeedback)
                          Positioned(
                            top: 24,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _feedbackIsSuccess
                                      ? Colors.green.shade900.withValues(
                                          alpha: 0.9,
                                        )
                                      : Colors.red.shade900.withValues(
                                          alpha: 0.9,
                                        ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _feedbackIsSuccess
                                        ? Colors.green
                                        : Colors.red,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _feedbackMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),

                        // Bottom HUD
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: _buildBottomHUD(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- Sidebar ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 66,
                                  bottom: 16,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.local_activity,
                                          color: Color(0xFFEAB308),
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tr('title').toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                tr('subtitle'),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Controls (Lang & Reset)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            ToggleButtons(
                                              constraints: const BoxConstraints(
                                                minHeight: 28,
                                                minWidth: 40,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              fillColor: const Color(
                                                0xFFEAB308,
                                              ).withValues(alpha: 0.2),
                                              selectedBorderColor: const Color(
                                                0xFFEAB308,
                                              ),
                                              borderColor: Colors.white12,
                                              color: Colors.white54,
                                              selectedColor: const Color(
                                                0xFFEAB308,
                                              ),
                                              isSelected: [
                                                _lang == 'en',
                                                _lang == 'hi',
                                              ],
                                              onPressed: (int index) {
                                                setState(() {
                                                  if (index == 0) {
                                                    _lang = 'en';
                                                  } else if (index == 1) {
                                                    _lang = 'hi';
                                                  }
                                                });
                                              },
                                              children: const [
                                                Text(
                                                  'EN',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'HI',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.refresh,
                                            color: Colors.white70,
                                          ),
                                          // Reset only the current scene so the
                                          // learner stays in this scenario.
                                          onPressed: _resetScene,
                                          tooltip: 'Reset Scene',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Scenario Dropdown
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white12,
                                          ),
                                        ),
                                        child: DropdownButton<int>(
                                          value: _currentScenario,
                                          isExpanded: true,
                                          dropdownColor: const Color(
                                            0xFF0F172A,
                                          ),
                                          underline: const SizedBox(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          items: [
                                            DropdownMenuItem(
                                              value: 1,
                                              child: Text(tr('scenario1')),
                                            ),
                                            DropdownMenuItem(
                                              value: 2,
                                              child: Text(tr('scenario2')),
                                            ),
                                          ],
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _currentScenario = v;
                                                _resetScene();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Objective
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.white10,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.track_changes,
                                                  color: Color(0xFFEAB308),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  tr(
                                                    'missionObjective',
                                                  ).toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Color(0xFFEAB308),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _currentScenario == 1
                                                  ? tr('s1Desc')
                                                  : tr('s2Desc'),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Steps
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.white10,
                                          ),
                                        ),
                                        child: Text(
                                          _currentScenario == 1
                                              ? tr('s1Steps')
                                              : tr('s2Steps'),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),

                              // Validate Button & Footer
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _validate();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFEAB308,
                                        ),
                                        foregroundColor: Colors.black,
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 8,
                                        shadowColor: const Color(
                                          0xFFEAB308,
                                        ).withValues(alpha: 0.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            tr('validateBtn'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      tr('footer'),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white38,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // --- Menu Button ---
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.8),
                child: Icon(
                  _isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: const Color(0xFFEAB308),
                ),
                onPressed: () {
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
              ),
            ),

            // --- Drag Resizer Handle ---
            if (_isSidebarOpen)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _sidebarWidth - 10,
                top: 0,
                bottom: 0,
                width: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      _sidebarWidth += details.delta.dx;
                      if (_sidebarWidth < 300) _sidebarWidth = 300;
                      if (_sidebarWidth >
                          MediaQuery.of(context).size.width * 0.6) {
                        _sidebarWidth = MediaQuery.of(context).size.width * 0.6;
                      }
                    });
                  },
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

            // --- Curtain Screen ---
            if (!_isCurtainOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_activity,
                        color: Color(0xFFEAB308),
                        size: 62,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('title'),
                        style: const TextStyle(
                          color: Color(0xFFEAB308),
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('subtitle'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _isCurtainOpen = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 10,
                          shadowColor: const Color(
                            0xFFEAB308,
                          ).withValues(alpha: 0.6),
                        ),
                        child: Text(
                          tr('enterLab'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomHUD() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: _currentScenario == 1 ? _buildS1HUD() : _buildS2HUD(),
    );
  }

  Widget _buildS1HUD() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('hudS1Title').toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFEAB308),
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              tr('hudS1Subtitle'),
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Position n: ',
                    style: TextStyle(
                      color: Color(0xFFEAB308),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _s1SelectedN,
                    dropdownColor: const Color(0xFF0F172A),
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white54,
                      size: 20,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    items: _s1Data.positions
                        .map(
                          (n) => DropdownMenuItem(
                            value: n,
                            child: Text(n.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _s1SelectedN = v);
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Term Y (t_n): ',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _s1YController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: InputBorder.none,
                        hintText: '?',
                        hintStyle: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _constructS1Pillar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                tr('btnConstruct').toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildS2HUD() {
    List<Widget> sortedChips = [];
    _s2Data.placements.forEach((val, type) {
      bool isMem = type == 'member';
      sortedChips.add(
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isMem
                ? Colors.green.shade900.withValues(alpha: 0.5)
                : Colors.blue.shade900.withValues(alpha: 0.5),
            border: Border.all(
              color: isMem
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.blue.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$val: ${isMem ? 'Mem' : 'Non'}',
            style: TextStyle(
              color: isMem ? Colors.green.shade200 : Colors.blue.shade200,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });

    if (sortedChips.isEmpty) {
      sortedChips.add(
        const Text(
          'None sorted yet',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('hudS2Title').toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFEAB308),
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              tr('hudS2Subtitle'),
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Text(
                'SORTED:  ',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: sortedChips),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Canvas Painter ---

class SimulationPainter extends CustomPainter {
  final int scenario;
  final S1Data s1Data;
  final S2Data s2Data;
  final Offset pan;
  final double zoom;
  final double time;
  final CandidateOrb? selectedOrb;
  final Map<String, String> langDict;
  final Function(List<HitBox>) onHitBoxesUpdated;

  List<HitBox> hitBoxes = [];

  SimulationPainter({
    required this.scenario,
    required this.s1Data,
    required this.s2Data,
    required this.pan,
    required this.zoom,
    required this.time,
    required this.selectedOrb,
    required this.langDict,
    required this.onHitBoxesUpdated,
  });

  // Pseudo-isometric projection mapping 3D to 2D
  Offset project(Vector3 p, Size size) {
    // Simple top-down oblique/isometric mix
    double x = (p.x - p.z) * cos(pi / 6);
    double y =
        (p.x + p.z) * sin(pi / 6) - (p.y * 1.5); // Y exaggerated for height

    // Scale and translate
    double sx = x * 20 * zoom + size.width / 2 + pan.dx;
    double sy = y * 20 * zoom + size.height / 2 + pan.dy;

    return Offset(sx, sy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    hitBoxes.clear();

    if (scenario == 1) {
      _paintS1(canvas, size);
    } else {
      _paintS2(canvas, size);
    }

    // Schedule callback to update hitboxes (cannot do synchronously inside paint if it triggers setState)
    // Actually passing hitboxes can be done simply by updating the list reference since we just recreate it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onHitBoxesUpdated(hitBoxes);
    });
  }

  void _paintS1(Canvas canvas, Size size) {
    // Draw Grid Base
    final paintBase = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    Path basePath = Path();
    for (int i = 0; i < 360; i += 10) {
      double rad = i * pi / 180;
      Offset pt = project(Vector3(18 * cos(rad), -0.25, 18 * sin(rad)), size);
      if (i == 0) {
        basePath.moveTo(pt.dx, pt.dy);
      } else {
        basePath.lineTo(pt.dx, pt.dy);
      }
    }
    basePath.close();
    canvas.drawPath(basePath, paintBase);

    // Grid lines on base
    final paintGrid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = -18; i <= 18; i += 3) {
      Offset p1 = project(Vector3(i.toDouble(), -0.25, -18), size);
      Offset p2 = project(Vector3(i.toDouble(), -0.25, 18), size);
      canvas.drawLine(p1, p2, paintGrid);
      Offset p3 = project(Vector3(-18, -0.25, i.toDouble()), size);
      Offset p4 = project(Vector3(18, -0.25, i.toDouble()), size);
      canvas.drawLine(p3, p4, paintGrid);
    }

    // Positions for pedestals
    final posAngles = {
      1: -pi / 3,
      2: -pi / 6,
      3: 0.0,
      12: pi / 6,
      18: pi / 3,
      50: pi / 2,
    };

    double r = 12.0;

    for (var n in s1Data.positions) {
      double angle = posAngles[n]!;
      double cx = r * cos(angle);
      double cz = r * sin(angle);

      _drawPedestal(canvas, size, Vector3(cx, 0, cz), n);

      double? placedY = s1Data.placedPillars[n];
      if (placedY != null) {
        _drawPillar(canvas, size, Vector3(cx, 0, cz), placedY);
      }
    }
  }

  void _drawPedestal(Canvas canvas, Size size, Vector3 pos, int n) {
    // Draw simple isometric cylinder
    Vector3 bottom = Vector3(pos.x, pos.y, pos.z);
    Vector3 top = Vector3(pos.x, pos.y + 0.5, pos.z);

    Offset bC = project(bottom, size);
    Offset tC = project(top, size);

    double radX = 1.2 * 20 * zoom;
    double radY = radX * 0.5; // isometric squash

    final paintSide = Paint()..color = const Color(0xFF334155);
    final paintTop = Paint()..color = const Color(0xFF475569);

    Path sidePath = Path()
      ..moveTo(bC.dx - radX, bC.dy)
      ..lineTo(tC.dx - radX, tC.dy)
      ..lineTo(tC.dx + radX, tC.dy)
      ..lineTo(bC.dx + radX, bC.dy)
      ..close();
    canvas.drawPath(sidePath, paintSide);

    canvas.drawOval(
      Rect.fromCenter(center: bC, width: radX * 2, height: radY * 2),
      paintSide,
    );
    canvas.drawOval(
      Rect.fromCenter(center: tC, width: radX * 2, height: radY * 2),
      paintTop,
    );

    // Label
    _drawText(
      canvas,
      "n = $n",
      project(Vector3(pos.x, pos.y + 1.5, pos.z), size),
      const Color(0xFFEAB308),
      12 * zoom,
    );
  }

  void _drawPillar(Canvas canvas, Size size, Vector3 pos, double value) {
    // Visual scaling mapping actual Y to reasonable heights
    double visualY = value * 0.05;
    double height = max(0.1, visualY.abs());

    Vector3 basePos = Vector3(pos.x, pos.y + 0.5, pos.z);
    if (value < 0) {
      basePos.y -= height;
    }

    Vector3 topPos = Vector3(pos.x, basePos.y + height, pos.z);

    Offset bC = project(basePos, size);
    Offset tC = project(topPos, size);

    double sWidth = 0.8 * 20 * zoom;
    double sHeight = sWidth * 0.5;

    Color color = value < 0
        ? const Color(0xFFF43F5E).withValues(alpha: 0.9)
        : const Color(0xFF0EA5E9).withValues(alpha: 0.9);
    final paintSide = Paint()..color = color;
    final paintTop = Paint()..color = color.withValues(alpha: 0.8);

    Path sidePath = Path()
      ..moveTo(bC.dx - sWidth, bC.dy)
      ..lineTo(tC.dx - sWidth, tC.dy)
      ..lineTo(tC.dx + sWidth, tC.dy)
      ..lineTo(bC.dx + sWidth, bC.dy)
      ..close();
    canvas.drawPath(sidePath, paintSide);

    canvas.drawOval(
      Rect.fromCenter(center: bC, width: sWidth * 2, height: sHeight * 2),
      paintSide,
    );
    canvas.drawOval(
      Rect.fromCenter(center: tC, width: sWidth * 2, height: sHeight * 2),
      paintTop,
    );

    _drawText(
      canvas,
      value.toStringAsFixed(0),
      project(Vector3(pos.x, basePos.y + height + 1.0, pos.z), size),
      Colors.white,
      12 * zoom,
    );
  }

  void _paintS2(Canvas canvas, Size size) {
    // S2 Base Platform
    final paintBase = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.8);
    Path basePath = Path();
    List<Vector3> corners = [
      Vector3(-15, 0, -10),
      Vector3(15, 0, -10),
      Vector3(15, 0, 10),
      Vector3(-15, 0, 10),
    ];
    for (int i = 0; i < corners.length; i++) {
      Offset pt = project(corners[i], size);
      if (i == 0) {
        basePath.moveTo(pt.dx, pt.dy);
      } else {
        basePath.lineTo(pt.dx, pt.dy);
      }
    }
    basePath.close();
    canvas.drawPath(basePath, paintBase);

    final paintBaseBorder = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(basePath, paintBaseBorder);

    // Portals
    _drawPortal(
      canvas,
      size,
      Vector3(-8, 0, -4),
      'member',
      langDict['memberPortal'] ?? 'Member',
      const Color(0xFF22C55E),
    );
    _drawPortal(
      canvas,
      size,
      Vector3(8, 0, -4),
      'notmember',
      langDict['nonMemberPortal'] ?? 'Not Member',
      const Color(0xFF3B82F6),
    );

    // Orbs (sort by Z depth approximation to draw correctly, although Y is elevated)
    List<CandidateOrb> sortedOrbs = List.from(s2Data.orbs);
    sortedOrbs.sort(
      (a, b) => (b.currentPos.x + b.currentPos.z).compareTo(
        a.currentPos.x + a.currentPos.z,
      ),
    );

    for (var orb in sortedOrbs) {
      if (orb.sortedPortal != null && !orb.isAnimating) {
        continue; // Hide fully sorted
      }

      Offset center = project(orb.currentPos, size);
      double radius = 1.0 * 20 * zoom;

      bool isSelected = selectedOrb?.value == orb.value;

      final paintGlow = Paint()
        ..color = const Color(
          0xFFEAB308,
        ).withValues(alpha: isSelected ? 0.6 : 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(center, radius * 1.5, paintGlow);

      final paintCore = Paint()
        ..color = const Color(0xFFEAB308)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paintCore);

      if (isSelected) {
        final paintOutline = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(center, radius * 1.1, paintOutline);
      }

      _drawText(
        canvas,
        "Val: ${orb.value}",
        Offset(center.dx, center.dy - radius - 15),
        Colors.white,
        14 * zoom,
        isBold: true,
      );

      // Add hitbox
      if (!orb.isAnimating) {
        hitBoxes.add(HitBox(center, radius * 2, orb.value, 'orb'));
      }
    }
  }

  void _drawPortal(
    Canvas canvas,
    Size size,
    Vector3 pos,
    String id,
    String label,
    Color color,
  ) {
    Offset baseCenter = project(pos, size);

    double rx = 3.0 * 20 * zoom;
    double ry = rx * 0.4;

    // Rotating effect
    double rotScale = 0.8 + 0.2 * sin(time * 3);

    final paintGlow = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawOval(
      Rect.fromCenter(
        center: baseCenter,
        width: rx * 2 * rotScale,
        height: ry * 2 * rotScale,
      ),
      paintGlow,
    );

    final paintRing = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * zoom;
    canvas.drawOval(
      Rect.fromCenter(center: baseCenter, width: rx * 2, height: ry * 2),
      paintRing,
    );

    // Inner swirl
    final paintSwirl = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * zoom;
    canvas.drawOval(
      Rect.fromCenter(
        center: baseCenter,
        width: rx * 2 * rotScale,
        height: ry * 2 * (1.2 - rotScale),
      ),
      paintSwirl,
    );

    // Label
    _drawText(
      canvas,
      label.toUpperCase(),
      Offset(baseCenter.dx, baseCenter.dy - ry - 20 * zoom),
      color,
      14 * zoom,
      isBold: true,
    );

    // Hitbox
    hitBoxes.add(HitBox(baseCenter, rx, id, 'portal'));
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    Color color,
    double fontSize, {
    bool isBold = false,
  }) {
    final textStyle = TextStyle(
      color: color,
      fontSize: max(8.0, fontSize), // min font size limit
      fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
      shadows: const [
        Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 1)),
      ],
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) {
    return oldDelegate.pan != pan ||
        oldDelegate.zoom != zoom ||
        oldDelegate.time != time ||
        oldDelegate.selectedOrb != selectedOrb ||
        oldDelegate.scenario != scenario;
  }
}
