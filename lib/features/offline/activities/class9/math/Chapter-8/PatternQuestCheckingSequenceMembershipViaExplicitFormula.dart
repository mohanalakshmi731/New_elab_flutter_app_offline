// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, file_names

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then(
    (_) => runApp(
      MaterialApp(
        title: 'Pattern Quest: Sequence Membership',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFEAB308),
          scaffoldBackgroundColor: const Color(0xFF020617),
          fontFamily: 'Segoe UI',
        ),
        home: const PatternQuestCheckingSequenceMembershipViaExplicitFormula(),
      ),
    ),
  );
}

class PatternQuestCheckingSequenceMembershipViaExplicitFormula
    extends StatefulWidget {
  const PatternQuestCheckingSequenceMembershipViaExplicitFormula({super.key});

  @override
  State<PatternQuestCheckingSequenceMembershipViaExplicitFormula>
  createState() => _SimulationHomeState();
}

class _SimulationHomeState
    extends State<PatternQuestCheckingSequenceMembershipViaExplicitFormula>
    with SingleTickerProviderStateMixin {
  // Application State
  bool showCurtain = true;
  double sidebarWidth = 350.0;
  double _lastSidebarWidth = 350.0;
  int _layoutAnimationDuration = 300;
  String currentLang = 'en';
  int currentScenario = 1;

  // Game Loop & Canvas
  late AnimationController _gameLoop;
  final GlobalKey _canvasKey = GlobalKey();

  // Camera State
  Offset cameraOffset = Offset.zero;
  double cameraZoom = 1.0;
  double _startZoom = 1.0;
  Offset _startOffset = Offset.zero;

  // Gesture tracking for pan/zoom
  Offset _initialFocalPoint = Offset.zero;

  Timer? _feedbackTimer;

  // Data: Scenario 1
  final List<int> s1Positions = [1, 2, 3, 12, 18, 50];
  int s1SelectedN = 1;
  final TextEditingController s1YController = TextEditingController();
  Map<int, double?> s1PlacedPillars = {
    1: null,
    2: null,
    3: null,
    12: null,
    18: null,
    50: null,
  };

  // Data: Scenario 2
  final List<int> s2Candidates = [332, 20, 100, 45];
  Map<int, String> s2Placements = {};
  int? selectedCandidate;

  // Feedback State
  String feedbackMessage = '';
  bool showFeedback = false;
  bool isFeedbackSuccess = false;

  // i18n Dictionary
  final Map<String, Map<String, String>> i18n = {
    'en': {
      'title': 'Pattern Quest: Sequence Membership',
      'subtitle': 'Class 9 • Predicting What Comes Next',
      'enterLab': 'Enter Lab',
      's1Title': 'Mission Objective',
      's1Desc':
          'The sequence follows the explicit rule tn = 3n - 7. Construct the pillars for the required positions n.',
      's1Steps':
          'Procedural Steps:\n\n1. Select a position n in the bottom HUD.\n\n2. Calculate the term value tn and enter it into the Y input.\n\n3. Click "Construct Pillar" to place it.\n\n4. Construct all required pillars (1, 2, 3, 12, 18, 50).\n\n5. Click Validate Model to confirm your computations.',
      's2Title': 'Mission Objective',
      's2Desc':
          'Become a membership detective: for each glowing mystery candidate, solve 3n - 7 = value for n and decide if it belongs to the sequence.',
      's2Steps':
          'Procedural Steps:\n\n1. Observe the floating candidates (Values: 332, 20, 100, 45).\n\n2. Solve the equation for n. If n is a whole number (1, 2, 3...), it is a Member.\n\n3. Tap a candidate to select it, then tap on the "Member" or "Not a Member" portal to sort it.\n\n4. Sort all candidates.\n\n5. Click Validate Model to confirm your analysis.',
      'hudS1Title': 'Sequence Construction',
      'hudS1Subtitle': 'Rule: tn = 3n - 7',
      'hudS2Title': 'Membership Sorting',
      'hudS2Subtitle': 'Select a candidate to sort',
      'btnConstruct': 'Construct Pillar',
      'validateBtn': 'Validate Model',
      'sc1Option': 'Scenario 1: Build the Sequence',
      'sc2Option': 'Scenario 2: Membership Test',
      'memberPortal': 'Member',
      'nonMemberPortal': 'Not Member',
      'feedbackS1Success':
          'Outstanding! You correctly computed all terms in the sequence.',
      'feedbackS1Fail':
          'Some pillars have incorrect heights or are missing. Remember tn = 3n - 7.',
      'feedbackS2Success':
          'Brilliant! You correctly identified which candidates have natural-number positions.',
      'feedbackS2Fail':
          'Some candidates are sorted incorrectly. If n is a whole number, it is a Member.',
    },
    'hi': {
      'title': 'पैटर्न खोज: अनुक्रम सदस्यता',
      'subtitle': 'कक्षा 9 • आगे क्या होगा इसकी भविष्यवाणी करना',
      'enterLab': 'प्रयोगशाला में प्रवेश करें',
      's1Title': 'मिशन का उद्देश्य',
      's1Desc':
          'अनुक्रम स्पष्ट नियम tn = 3n - 7 का पालन करता है। आवश्यक स्थितियों n के लिए स्तंभों का निर्माण करें।',
      's1Steps':
          'प्रक्रियात्मक चरण:\n\n1. निचले HUD में एक स्थिति n चुनें।\n\n2. पद मान tn की गणना करें और इसे Y इनपुट में दर्ज करें।\n\n3. इसे रखने के लिए "स्तंभ बनाएँ" पर क्लिक करें।\n\n4. सभी आवश्यक स्तंभ (1, 2, 3, 12, 18, 50) बनाएँ।\n\n5. पुष्टि करने के लिए Validate Model पर क्लिक करें।',
      's2Title': 'मिशन का उद्देश्य',
      's2Desc':
          'एक सदस्यता जासूस बनें: 3n - 7 = मान हल करें और तय करें कि क्या यह अनुक्रम का है।',
      's2Steps':
          'प्रक्रियात्मक चरण:\n\n1. तैरते हुए उम्मीदवारों (मान: 332, 20, 100, 45) का निरीक्षण करें।\n\n2. n के लिए समीकरण हल करें। यदि n एक पूर्ण संख्या है, तो यह सदस्य है।\n\n3. उम्मीदवार चुनें, फिर "सदस्य" या "सदस्य नहीं" पोर्टल पर क्लिक करें।\n\n4. सभी उम्मीदवारों को क्रमबद्ध करें।\n\n5. पुष्टि करने के लिए Validate Model पर क्लिक करें।',
      'hudS1Title': 'अनुक्रम निर्माण',
      'hudS1Subtitle': 'नियम: tn = 3n - 7',
      'hudS2Title': 'सदस्यता छँटाई',
      'hudS2Subtitle': 'छांटने के लिए एक उम्मीदवार चुनें',
      'btnConstruct': 'स्तंभ बनाएँ',
      'validateBtn': 'Validate Model',
      'sc1Option': 'परिदृश्य 1: अनुक्रम बनाएँ',
      'sc2Option': 'परिदृश्य 2: सदस्यता परीक्षण',
      'memberPortal': 'सदस्य',
      'nonMemberPortal': 'सदस्य नहीं',
      'feedbackS1Success':
          'बहुत बढ़िया! आपने अनुक्रम में सभी पदों की सही गणना की है।',
      'feedbackS1Fail': 'कुछ स्तंभ गलत हैं या गायब हैं। याद रखें tn = 3n - 7.',
      'feedbackS2Success':
          'शानदार! आपने सही ढंग से पहचाना कि किन उम्मीदवारों की प्राकृतिक संख्या स्थिति है।',
      'feedbackS2Fail':
          'कुछ उम्मीदवारों को गलत क्रमबद्ध किया गया है। यदि n पूर्ण संख्या है, तो सदस्य है।',
    },
  };

  String t(String key) => i18n[currentLang]![key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Setup continuous animation loop (60FPS roughly) for floating logic and repainting
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _gameLoop.dispose();
    s1YController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void resetScene() {
    setState(() {
      s1PlacedPillars = {
        1: null,
        2: null,
        3: null,
        12: null,
        18: null,
        50: null,
      };
      s2Placements.clear();
      selectedCandidate = null;
      s1YController.clear();
      s1SelectedN = 1;
      cameraOffset = Offset.zero;
      cameraZoom = 1.0;
      showFeedback = false;
    });
    _feedbackTimer?.cancel();
  }

  void _validateModel() {
    bool allCorrect = true;

    if (currentScenario == 1) {
      for (int n in s1Positions) {
        if (s1PlacedPillars[n] == null) {
          allCorrect = false;
        } else {
          double expected = (3 * n - 7).toDouble();
          if (s1PlacedPillars[n] != expected) allCorrect = false;
        }
      }
      _showFeedbackMsg(
        allCorrect ? t('feedbackS1Success') : t('feedbackS1Fail'),
        allCorrect,
      );
    } else {
      for (int val in s2Candidates) {
        if (!s2Placements.containsKey(val)) {
          allCorrect = false;
        } else {
          double n = (val + 7) / 3;
          bool isMem = (n >= 1 && n == n.truncateToDouble());
          String expected = isMem ? 'member' : 'notmember';
          if (s2Placements[val] != expected) allCorrect = false;
        }
      }
      _showFeedbackMsg(
        allCorrect ? t('feedbackS2Success') : t('feedbackS2Fail'),
        allCorrect,
      );
    }
  }

  void _showFeedbackMsg(String msg, bool success) {
    setState(() {
      feedbackMessage = msg;
      isFeedbackSuccess = success;
      showFeedback = true;
    });
    // Restart the hide timer so a newer message gets its full 4 seconds.
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => showFeedback = false);
    });
  }

  void _handleCanvasTap(Offset globalPosition) {
    if (currentScenario != 2) return;

    final RenderBox box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final Offset local = box.globalToLocal(globalPosition);
    final Size size = box.size;

    // Inverse transform
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Offset worldHit = (local - center - cameraOffset) / cameraZoom;

    // Check Candidate Hits
    for (int i = 0; i < s2Candidates.length; i++) {
      int val = s2Candidates[i];
      if (s2Placements.containsKey(val)) continue; // Already sorted

      Offset candPos = Offset(
        -250 + i * 160.0,
        50,
      ); // Hardcoded base layout positions
      if ((worldHit - candPos).distance < 40) {
        setState(() => selectedCandidate = val);
        return;
      }
    }

    // Check Portal Hits
    if (selectedCandidate != null) {
      Offset memPortal = const Offset(-200, -100);
      Offset nonMemPortal = const Offset(200, -100);

      if ((worldHit - memPortal).distance < 70) {
        setState(() {
          s2Placements[selectedCandidate!] = 'member';
          selectedCandidate = null;
        });
      } else if ((worldHit - nonMemPortal).distance < 70) {
        setState(() {
          s2Placements[selectedCandidate!] = 'notmember';
          selectedCandidate = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Enforce immersive mode
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // ================== CANVAS AREA ==================
            AnimatedPositioned(
              duration: Duration(milliseconds: _layoutAnimationDuration),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: sidebarWidth,
              right: 0,
              child: GestureDetector(
                onScaleStart: (details) {
                  _startZoom = cameraZoom;
                  _startOffset = cameraOffset;
                  _initialFocalPoint = details.localFocalPoint;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    cameraZoom = (_startZoom * details.scale).clamp(0.2, 5.0);
                    // Calculates offset cleanly based on current finger position vs initial
                    cameraOffset =
                        _startOffset +
                        (details.localFocalPoint - _initialFocalPoint);
                  });
                },
                // Taps must be recognised here: the screen-wide onTap above
                // would otherwise win the gesture arena on a stationary tap,
                // and the scale recognizer never reports it.
                onTapUp: (details) {
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                  FocusScope.of(context).unfocus();
                  _handleCanvasTap(details.globalPosition);
                },
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: AnimatedBuilder(
                    animation: _gameLoop,
                    builder: (context, _) {
                      return CustomPaint(
                        key: _canvasKey,
                        painter: SimulationPainter(
                          scenario: currentScenario,
                          time: _gameLoop.value * 2 * math.pi,
                          cameraOffset: cameraOffset,
                          cameraZoom: cameraZoom,
                          s1Positions: s1Positions,
                          s1PlacedPillars: s1PlacedPillars,
                          s2Candidates: s2Candidates,
                          s2Placements: s2Placements,
                          selectedCandidate: selectedCandidate,
                          lang: currentLang,
                          i18n: i18n,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),
            ),

            // ================== HUD ==================
            AnimatedPositioned(
              duration: Duration(milliseconds: _layoutAnimationDuration),
              curve: Curves.easeOutCubic,
              bottom: 20,
              left: sidebarWidth + 20,
              right: 20,
              child: IgnorePointer(ignoring: showCurtain, child: _buildHUD()),
            ),

            // ================== FEEDBACK MESSAGE ==================
            if (showFeedback)
              AnimatedPositioned(
                duration: Duration(milliseconds: _layoutAnimationDuration),
                curve: Curves.easeOutCubic,
                top: 40,
                left: sidebarWidth,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isFeedbackSuccess
                          ? Colors.green.shade900.withOpacity(0.9)
                          : Colors.red.shade900.withOpacity(0.9),
                      border: Border.all(
                        color: isFeedbackSuccess ? Colors.green : Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      feedbackMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            // ================== SIDEBAR ==================
            AnimatedPositioned(
              duration: Duration(milliseconds: _layoutAnimationDuration),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: 0,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white12, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 16, top: 64),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon, Title & Subtitle
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.science,
                                  color: Color(0xFFEAB308),
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t('title'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 44.0),
                              child: Text(
                                t('subtitle'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFFEAB308),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Language Toggle & Reset Controls
                            Padding(
                              padding: const EdgeInsets.only(left: 44.0),
                              child: Row(
                                children: [
                                  // Language Toggle (ToggleButton implementation)
                                  ToggleButtons(
                                    isSelected: [
                                      currentLang == 'en',
                                      currentLang == 'hi',
                                    ],
                                    onPressed: (int index) {
                                      setState(() {
                                        currentLang = index == 0 ? 'en' : 'hi';
                                      });
                                    },
                                    color: Colors.white70,
                                    selectedColor: Colors.white,
                                    fillColor: Colors.white12,
                                    borderColor: Colors.white30,
                                    selectedBorderColor: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    constraints: const BoxConstraints(
                                      minHeight: 30,
                                      minWidth: 44,
                                    ),
                                    children: const [
                                      Text(
                                        'EN',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'HI',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  // Reset Button
                                  IconButton(
                                    onPressed: resetScene,
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                                    tooltip: 'Reset Scene',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 24),

                            // Scenario Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: currentScenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white54,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Text(
                                        t('sc1Option'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text(
                                        t('sc2Option'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => currentScenario = val);
                                      resetScene();
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Instructions Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        currentScenario == 1
                                            ? t('s1Title')
                                            : t('s2Title'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFEAB308),
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currentScenario == 1
                                        ? t('s1Desc')
                                        : t('s2Desc'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      height: 1.4,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Steps
                            Text(
                              currentScenario == 1
                                  ? t('s1Steps')
                                  : t('s2Steps'),
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.6,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Validate Button
                            ElevatedButton.icon(
                              onPressed: _validateModel,
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.black87,
                              ),
                              label: Text(
                                t('validateBtn').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEAB308),
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: const Color(
                                  0xFFEAB308,
                                ).withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Footer
                            const Center(
                              child: Text(
                                '© ZeroScienceLab - Fall in love with math and Science',
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Drag Handle
                    GestureDetector(
                      onPanStart: (details) {
                        setState(
                          () => _layoutAnimationDuration = 0,
                        ); // Instant response when dragging
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          sidebarWidth += details.delta.dx;
                          if (sidebarWidth < 300) sidebarWidth = 300;
                          if (sidebarWidth > sw * 0.5) sidebarWidth = sw * 0.5;
                          _lastSidebarWidth = sidebarWidth; // Remember size
                        });
                      },
                      onPanEnd: (details) {
                        setState(
                          () => _layoutAnimationDuration = 300,
                        ); // Restore animation time
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: Container(
                          width: 20,
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              height: 40,
                              width: 4,
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================== FIXED MENU ICON ==================
            Positioned(
              top: 16,
              left: 16,
              child: IgnorePointer(
                ignoring: showCurtain, // Disable tap during curtain
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showCurtain ? 0.0 : 1.0,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF1E293B).withOpacity(0.9),
                    elevation: 4,
                    onPressed: () {
                      setState(() {
                        _layoutAnimationDuration = 300; // Ensure smooth toggle
                        if (sidebarWidth > 0) {
                          _lastSidebarWidth = sidebarWidth; // Save state
                          sidebarWidth = 0; // Close
                        } else {
                          sidebarWidth =
                              _lastSidebarWidth; // Re-open to saved width
                        }
                      });
                    },
                    child: Icon(
                      sidebarWidth > 0 ? Icons.menu_open : Icons.menu,
                      color: const Color(0xFFEAB308),
                    ),
                  ),
                ),
              ),
            ),

            // ================== CURTAIN OVERLAY ==================
            if (showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.science,
                            color: Color(0xFFEAB308),
                            size: 72,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFEAB308),
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('subtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 60),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => showCurtain = false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAB308),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              elevation: 20,
                              shadowColor: const Color(
                                0xFFEAB308,
                              ).withOpacity(0.6),
                            ),
                            child: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
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
      child: currentScenario == 1 ? _buildS1HUD() : _buildS2HUD(),
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
            Expanded(
              child: Text(
                t('hudS1Title').toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Color(0xFFEAB308),
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Text(
              t('hudS1Subtitle'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Flexible Wrap layout allows UI elements to seamlessly reflow on smaller displays
        Wrap(
          spacing: 24,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Position (n):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: s1SelectedN,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      items: s1Positions
                          .map(
                            (n) =>
                                DropdownMenuItem(value: n, child: Text('$n')),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => s1SelectedN = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Term Y (tn):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: s1YController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFEAB308)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                final double? yVal = double.tryParse(s1YController.text);
                if (yVal != null) {
                  setState(() {
                    s1PlacedPillars[s1SelectedN] = yVal;
                  });
                  FocusScope.of(context).unfocus();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                t('btnConstruct').toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildS2HUD() {
    List<Widget> sortedChips = s2Placements.entries.map((e) {
      bool isMem = e.value == 'member';
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMem
              ? Colors.green.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
          border: Border.all(color: isMem ? Colors.green : Colors.blue),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${e.key}: ${isMem ? 'Mem' : 'Non'}',
          style: TextStyle(
            color: isMem ? Colors.greenAccent : Colors.lightBlueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                t('hudS2Title').toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Color(0xFFEAB308),
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Text(
              t('hudS2Subtitle'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Wrap layout for overflowing chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Sorted: ',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (sortedChips.isEmpty)
              const Text(
                'None',
                style: TextStyle(
                  color: Colors.white30,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ...sortedChips,
          ],
        ),
      ],
    );
  }
}

class SimulationPainter extends CustomPainter {
  final int scenario;
  final double time;
  final Offset cameraOffset;
  final double cameraZoom;

  final List<int> s1Positions;
  final Map<int, double?> s1PlacedPillars;

  final List<int> s2Candidates;
  final Map<int, String> s2Placements;
  final int? selectedCandidate;

  final String lang;
  final Map<String, Map<String, String>> i18n;

  SimulationPainter({
    required this.scenario,
    required this.time,
    required this.cameraOffset,
    required this.cameraZoom,
    required this.s1Positions,
    required this.s1PlacedPillars,
    required this.s2Candidates,
    required this.s2Placements,
    required this.selectedCandidate,
    required this.lang,
    required this.i18n,
  });

  String t(String key) => i18n[lang]![key] ?? key;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx + cameraOffset.dx, center.dy + cameraOffset.dy);
    canvas.scale(cameraZoom);

    // Draw Grid Background lines
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (int i = -1000; i <= 1000; i += 50) {
      canvas.drawLine(
        Offset(i.toDouble(), -1000),
        Offset(i.toDouble(), 1000),
        gridPaint,
      );
      canvas.drawLine(
        Offset(-1000, i.toDouble()),
        Offset(1000, i.toDouble()),
        gridPaint,
      );
    }

    if (scenario == 1) {
      _drawScenario1(canvas);
    } else {
      _drawScenario2(canvas);
    }
  }

  void _drawScenario1(Canvas canvas) {
    // 2.5D Isometric style view

    // Main Base curve
    final Paint basePaint = Paint()..color = const Color(0xFF1E293B);
    final Paint baseOutline = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Rect baseRect = Rect.fromCenter(
      center: const Offset(0, 50),
      width: 700,
      height: 150,
    );
    canvas.drawOval(baseRect, basePaint);
    canvas.drawOval(baseRect, baseOutline);

    // Positions mapping on an arc
    final Map<int, Offset> pedCoords = {};
    for (int i = 0; i < s1Positions.length; i++) {
      double tAngle = math.pi + (i / (s1Positions.length - 1)) * math.pi;
      // Arc from left to right (-x to +x)
      double px = math.cos(tAngle) * 300;
      double py = 50 + math.sin(tAngle) * 40;
      pedCoords[s1Positions[i]] = Offset(px, py);
    }

    // Draw Pillars back to front
    for (int n in s1Positions) {
      Offset pos = pedCoords[n]!;

      // Pedestal
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 60, height: 20),
        Paint()..color = const Color(0xFF334155),
      );
      _drawText(canvas, "n = $n", pos + const Offset(0, 30), Colors.amber, 14);

      // Pillar if placed
      double? hVal = s1PlacedPillars[n];
      if (hVal != null) {
        // Visual height scale
        double drawHeight = hVal.abs() * 1.5;
        if (drawHeight < 10) drawHeight = 10;

        Color pColor = hVal < 0 ? Colors.redAccent : Colors.lightBlueAccent;

        final Paint pillarPaint = Paint()..color = pColor.withOpacity(0.8);
        final Paint pillarTopPaint = Paint()..color = pColor;

        double yTop = hVal >= 0 ? pos.dy - drawHeight : pos.dy + drawHeight;

        // Body
        Rect pBody = Rect.fromPoints(
          Offset(pos.dx - 20, pos.dy),
          Offset(pos.dx + 20, yTop),
        );
        canvas.drawRect(pBody, pillarPaint);

        // Top cap
        canvas.drawOval(
          Rect.fromCenter(center: Offset(pos.dx, yTop), width: 40, height: 12),
          pillarTopPaint,
        );

        _drawText(
          canvas,
          hVal.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
          Offset(pos.dx, yTop - 20),
          Colors.white,
          16,
        );
      }
    }
  }

  void _drawScenario2(Canvas canvas) {
    // Portals
    Offset memPortal = const Offset(-200, -100);
    Offset nonMemPortal = const Offset(200, -100);

    // Glowing Portals
    _drawPortal(canvas, memPortal, Colors.greenAccent, t('memberPortal'), time);
    _drawPortal(
      canvas,
      nonMemPortal,
      Colors.blueAccent,
      t('nonMemberPortal'),
      -time,
    );

    // Draw sorted candidates inside portals
    List<int> mems = s2Placements.entries
        .where((e) => e.value == 'member')
        .map((e) => e.key)
        .toList();
    List<int> nons = s2Placements.entries
        .where((e) => e.value == 'notmember')
        .map((e) => e.key)
        .toList();

    _drawSortedGroup(canvas, memPortal, mems, Colors.green);
    _drawSortedGroup(canvas, nonMemPortal, nons, Colors.blue);

    // Unsorted Floating Candidates
    for (int i = 0; i < s2Candidates.length; i++) {
      int val = s2Candidates[i];
      if (s2Placements.containsKey(val)) continue; // Don't draw if sorted

      Offset basePos = Offset(-250 + i * 160.0, 50);
      double floatY = math.sin(time + basePos.dx * 0.01) * 15;
      Offset finalPos = basePos + Offset(0, floatY);

      bool isSelected = selectedCandidate == val;

      // Shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: basePos + const Offset(0, 40),
          width: 30,
          height: 10,
        ),
        Paint()
          ..color = Colors.black45
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Orb
      final Paint orbPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.yellow.shade100, Colors.amber.shade700],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
        ).createShader(Rect.fromCircle(center: finalPos, radius: 25));

      canvas.drawCircle(finalPos, 25, orbPaint);

      // Selection Highlight
      if (isSelected) {
        canvas.drawCircle(
          finalPos,
          30,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        canvas.drawCircle(
          finalPos,
          34,
          Paint()
            ..color = Colors.amber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5),
        );
      }

      _drawText(
        canvas,
        val.toString(),
        finalPos + const Offset(0, -45),
        Colors.white,
        20,
      );
    }
  }

  void _drawPortal(
    Canvas canvas,
    Offset pos,
    Color color,
    String label,
    double rotation,
  ) {
    // Portal ring with glow
    final Rect pRect = Rect.fromCenter(center: pos, width: 140, height: 60);
    final Paint glowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15);

    final Paint solidPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawOval(pRect, glowPaint);
    canvas.drawOval(pRect, solidPaint);

    // Draw swirling inner element simulating animation
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(rotation);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 100, height: 40),
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();

    _drawText(canvas, label, pos + const Offset(0, 45), color, 16);
  }

  void _drawSortedGroup(
    Canvas canvas,
    Offset portalPos,
    List<int> values,
    Color color,
  ) {
    for (int i = 0; i < values.length; i++) {
      double ax = portalPos.dx - 30 + (i % 3) * 30;
      double ay = portalPos.dy - 10 + (i ~/ 3) * 20;
      Offset cp = Offset(ax, ay);

      canvas.drawCircle(cp, 10, Paint()..color = color.withOpacity(0.5));
      _drawText(canvas, values[i].toString(), cp, Colors.white, 10);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    Color color,
    double fontSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black45,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.cameraOffset != cameraOffset ||
        oldDelegate.cameraZoom != cameraZoom ||
        oldDelegate.scenario != scenario ||
        oldDelegate.s1PlacedPillars != s1PlacedPillars ||
        oldDelegate.s2Placements != s2Placements ||
        oldDelegate.selectedCandidate != selectedCandidate ||
        oldDelegate.lang != lang;
  }
}
