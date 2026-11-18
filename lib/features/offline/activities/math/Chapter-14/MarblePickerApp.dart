// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- AUDIO MANAGER ---
class AudioManager {
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  static Future<void> playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource(_clickUrl));
    } catch (_) {}
  }

  static Future<void> playSuccess() async {
    try {
      await _successPlayer.stop();
      await _successPlayer.play(AssetSource(_successUrl));
    } catch (_) {}
  }

  static Future<void> playError() async {
    try {
      await _errorPlayer.stop();
      await _errorPlayer.play(AssetSource(_errorUrl));
    } catch (_) {}
  }

  static Future<void> playShutter() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.play(AssetSource(_shutterUrl));
    } catch (_) {}
  }
}

// --- DATASET & MODELS ---
enum MarbleColor { red, blue, green, yellow }

class Marble {
  final int id;
  final MarbleColor color;
  final Offset baseOffset;

  Marble(this.id, this.color, this.baseOffset);

  Color get materialColor {
    switch (color) {
      case MarbleColor.red:
        return const Color(0xFFef4444);
      case MarbleColor.blue:
        return const Color(0xFF3b82f6);
      case MarbleColor.green:
        return const Color(0xFF10b981);
      case MarbleColor.yellow:
        return const Color(0xFFeab308);
    }
  }

  Color get materialHighlight {
    switch (color) {
      case MarbleColor.red:
        return const Color(0xFFfca5a5);
      case MarbleColor.blue:
        return const Color(0xFFbfdbfe);
      case MarbleColor.green:
        return const Color(0xFF6ee7b7);
      case MarbleColor.yellow:
        return const Color(0xFFfef08a);
    }
  }
}

// Generate standard jar of 12 marbles (5 Red, 4 Blue, 3 Green)
final List<Marble> jarMarbles = () {
  List<Marble> list = [];
  int id = 0;

  // Pre-calculated scattered positions inside a 200x250 jar
  final positions = [
    const Offset(-40, 70),
    const Offset(0, 80),
    const Offset(40, 75),
    const Offset(-60, 30),
    const Offset(-20, 35),
    const Offset(20, 40),
    const Offset(60, 25),
    const Offset(-40, -10),
    const Offset(0, 0),
    const Offset(40, -5),
    const Offset(-20, -50),
    const Offset(20, -45),
  ];

  // 5 Red
  for (int i = 0; i < 5; i++) {
    list.add(Marble(id++, MarbleColor.red, positions[id - 1]));
  }
  // 4 Blue
  for (int i = 0; i < 4; i++) {
    list.add(Marble(id++, MarbleColor.blue, positions[id - 1]));
  }
  // 3 Green
  for (int i = 0; i < 3; i++) {
    list.add(Marble(id++, MarbleColor.green, positions[id - 1]));
  }

  // Visually shuffle them
  list.shuffle(math.Random(42));
  return list;
}();

// --- I18N DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE MARBLE PICKER',
    'tagline': 'THEORETICAL PROBABILITY',
    'init_btn': 'FILL THE JAR',
    'header_title': 'The Marble Picker',
    'header_subtitle': 'CLASS 10 • PROBABILITY',
    'phase_label': 'ANALYSIS PHASE',
    'step_label': 'Stage',
    'mission_log': 'Console Log',
    'active_mission': 'Current Objective',
    'th_event': 'Event (E)',
    'th_fav': 'Favorable',
    'th_total': 'Total',
    'th_prob': 'P(E)',
    'cel_title': 'JAR MASTERED!',
    'cel_msg': 'Probability Concepts Verified',
    'btn_restart': 'Restart Simulation',
    's1_t': 'Step 1: The Jar Contents',
    's1_i':
        'Observe the jar. It contains 12 marbles in total: 5 Red, 4 Blue, and 3 Green.',
    's1_b': 'Analyze Jar',
    's2_t': 'Step 2: Drawing a Red Marble',
    's2_i':
        'What is the probability of blindly drawing a Red marble? \n\nP(Red) = 5 Favorable / 12 Total.',
    's2_b': 'Draw Red Marbles',
    's3_t': 'Step 3: Drawing a Blue Marble',
    's3_i':
        'What is the probability of drawing a Blue marble? \n\nP(Blue) = 4 / 12 = 1/3.',
    's3_b': 'Draw Blue Marbles',
    's4_t': 'Step 4: Drawing a Green Marble',
    's4_i':
        'What is the probability of drawing a Green marble? \n\nP(Green) = 3 / 12 = 1/4.',
    's4_b': 'Draw Green Marbles',
    's5_t': 'Step 5: The Complementary Event',
    's5_i':
        'What is the probability of drawing a marble that is NOT Green? \n\nP(Not Green) = Red(5) + Blue(4) = 9/12 = 3/4.',
    's5_b': 'Draw NOT Green',
    's6_t': 'Step 6: The Impossible Event',
    's6_i':
        'What is the probability of drawing a Yellow marble? Since there are none, P(Yellow) = 0.',
    's6_b': 'Search for Yellow',
    's7_t': 'Step 7: Conclusion',
    's7_i':
        'By dividing the number of favorable outcomes by the total possible outcomes, we define Theoretical Probability.',
    's7_b': 'Complete Analysis',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Probability Distribution',
    'objective_desc':
        'By dividing the number of favorable outcomes by the total possible outcomes, we define Theoretical Probability.',
  },
  'hi': {
    'app_title': 'कंचे चुनना',
    'tagline': 'सैद्धांतिक प्रायिकता',
    'init_btn': 'जार भरें',
    'header_title': 'कंचे चुनना',
    'header_subtitle': 'कक्षा 10 • प्रायिकता',
    'phase_label': 'विश्लेषण चरण',
    'step_label': 'चरण',
    'mission_log': 'कंसोल लॉग',
    'active_mission': 'वर्तमान उद्देश्य',
    'th_event': 'घटना (E)',
    'th_fav': 'अनुकूल',
    'th_total': 'कुल',
    'th_prob': 'P(E)',
    'cel_title': 'प्रयोग पूर्ण!',
    'cel_msg': 'प्रायिकता अवधारणाएँ सत्यापित',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: जार की सामग्री',
    's1_i': 'जार को देखें। इसमें कुल 12 कंचे हैं: 5 लाल, 4 नीले, और 3 हरे।',
    's1_b': 'जार का विश्लेषण करें',
    's2_t': 'चरण 2: लाल कंचा निकालना',
    's2_i':
        'आंख मूंदकर लाल कंचा निकालने की प्रायिकता क्या है? \n\nP(लाल) = 5 अनुकूल / 12 कुल।',
    's2_b': 'लाल कंचे निकालें',
    's3_t': 'चरण 3: नीला कंचा निकालना',
    's3_i':
        'नीला कंचा निकालने की प्रायिकता क्या है? \n\nP(नीला) = 4 / 12 = 1/3।',
    's3_b': 'नीले कंचे निकालें',
    's4_t': 'चरण 4: हरा कंचा निकालना',
    's4_i': 'हरा कंचा निकालने की प्रायिकता क्या है? \n\nP(हरा) = 3 / 12 = 1/4।',
    's4_b': 'हरे कंचे निकालें',
    's5_t': 'चरण 5: पूरक घटना',
    's5_i':
        'ऐसा कंचा निकालने की प्रायिकता क्या है जो हरा नहीं है? \n\nP(हरा नहीं) = लाल(5) + नीला(4) = 9/12 = 3/4।',
    's5_b': 'हरे के अलावा निकालें',
    's6_t': 'चरण 6: असंभव घटना',
    's6_i':
        'पीला कंचा निकालने की प्रायिकता क्या है? चूँकि कोई नहीं है, P(पीला) = 0।',
    's6_b': 'पीला खोजें',
    's7_t': 'चरण 7: निष्कर्ष',
    's7_i':
        'अनुकूल परिणामों की संख्या को कुल संभावित परिणामों से विभाजित करके, हम सैद्धांतिक प्रायिकता को परिभाषित करते हैं।',
    's7_b': 'विश्लेषण पूर्ण करें',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. प्रायिकता वितरण',
    'objective_desc':
        'अनुकूल परिणामों की संख्या को कुल संभावित परिणामों से विभाजित करके, हम सैद्धांतिक प्रायिकता को परिभाषित करते हैं।',
  },
};

// --- STATE MANAGEMENT ---
class AppState extends ChangeNotifier {
  bool isInitialized = false;
  String lang = 'en';

  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  int step = 1;

  int get visualStep => step > 1 ? step - 1 : 0;

  List<Marble> get targetMarbles {
    switch (visualStep) {
      case 0:
        return []; // None lifted
      case 1:
        return jarMarbles; // Target conceptually all 12
      case 2:
        return jarMarbles.where((m) => m.color == MarbleColor.red).toList();
      case 3:
        return jarMarbles.where((m) => m.color == MarbleColor.blue).toList();
      case 4:
        return jarMarbles.where((m) => m.color == MarbleColor.green).toList();
      case 5:
        return jarMarbles
            .where((m) => m.color != MarbleColor.green)
            .toList(); // Not Green
      case 6:
        return []; // Yellow (None)
      default:
        return [];
    }
  }

  void initializeApp() {
    isInitialized = true;
    AudioManager.playShutter();
    notifyListeners();
  }

  void setLanguage(String newLang) {
    lang = newLang;
    AudioManager.playClick();
    notifyListeners();
  }

  void toggleLeftPanel() {
    isLeftPanelOpen = !isLeftPanelOpen;
    AudioManager.playClick();
    notifyListeners();
  }

  void toggleRightPanel() {
    isRightPanelOpen = !isRightPanelOpen;
    AudioManager.playClick();
    notifyListeners();
  }

  void nextStep() {
    if (step < 8) {
      step++;
      if (step == 8) {
        AudioManager.playSuccess();
      } else {
        AudioManager.playClick();
      }
      notifyListeners();
    } else {
      AudioManager.playError();
    }
  }

  void resetLab() {
    step = 1;
    lang = 'en'; // Force resets language back to English
    isLeftPanelOpen = true;
    isRightPanelOpen = false;
    isInitialized = false;
    AudioManager.playShutter();
    notifyListeners();
  }

  String t(String key) {
    return i18n[lang]?[key] ?? key;
  }
}

class MarblePickerApp extends StatefulWidget {
  const MarblePickerApp({super.key});

  @override
  State<MarblePickerApp> createState() => _MarblePickerAppState();
}

class _MarblePickerAppState extends State<MarblePickerApp> {
  final AppState state = AppState();
  final List<GlobalKey> stepKeys = List.generate(7, (index) => GlobalKey());
  int _previousStep = 1;

  @override
  void initState() {
    super.initState();
    state.addListener(() {
      if (!mounted) return;
      if (state.step != _previousStep) {
        _previousStep = state.step;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToStep(state.step);
        });
      }
      setState(() {});
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _scrollToStep(int step) {
    if (step < 1 || step > 7) return;
    int index = step - 1;
    final keyContext = stepKeys[index].currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = (screenWidth * 0.40).clamp(320.0, 500.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(painter: DotPatternPainter()),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [Color(0xFF1e1b4b), Color(0xFF020617)],
                  ),
                ),
              ),
            ),

            // 1. CANVAS AREA (Interactive 3D Visualizer - actively adapts bounds based on panel toggles)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: state.isInitialized && state.isLeftPanelOpen
                  ? panelWidth
                  : 0,
              right: state.isInitialized && state.isRightPanelOpen
                  ? panelWidth
                  : 0,
              child: VisualizerArea(state: state),
            ),

            // 2. FLOATING MISSION CARD (Visible when left panel is closed)
            if (state.isInitialized && !state.isLeftPanelOpen && state.step < 8)
              Positioned(
                top: 85,
                left: 20,
                child: FloatingMissionCard(state: state),
              ),

            // 3. RIGHT PANEL (Calculations & Data)
            if (state.isInitialized)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                right: state.isRightPanelOpen ? 0 : -panelWidth,
                width: panelWidth,
                child: _buildRightPanel(),
              ),

            // 4. LEFT PANEL (Mission/Controls)
            if (state.isInitialized)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                left: state.isLeftPanelOpen ? 0 : -panelWidth,
                width: panelWidth,
                child: _buildLeftPanel(),
              ),

            // 5. FRONT SCREEN FIXED FLOATING BUTTONS
            if (state.isInitialized) ...[
              // Menu Button (Top Left)
              Positioned(
                top: 20,
                left: 20,
                child: _buildFloatingActionBtn(
                  icon: state.isLeftPanelOpen ? Icons.menu_open : Icons.menu,
                  onTap: state.toggleLeftPanel,
                  color: const Color(0xFF8b5cf6),
                  tooltip: 'Menu',
                ),
              ),

              // Data/Calculations Button (Bottom Right)
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildFloatingActionBtn(
                  icon: state.isRightPanelOpen
                      ? Icons.close
                      : Icons.data_usage_rounded,
                  onTap: state.toggleRightPanel,
                  color: const Color(0xFFc084fc),
                  tooltip: 'Data / Calculations',
                ),
              ),
            ],

            // CELEBRATION (Step 8)
            if (state.step == 8 && state.isInitialized)
              Positioned.fill(child: CelebrationOverlay(state: state)),

            // CURTAIN RAISER OVERLAY
            if (!state.isInitialized)
              Positioned.fill(
                child: CurtainRaiser(
                  state: state,
                  onInit: () => state.initializeApp(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- FLOATING ACTION BUTTON ---
  Widget _buildFloatingActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: const Color(0xE60f172a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        ),
        elevation: 10,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }

  // --- LEFT SIDEBAR (Mission / Controls) ---
  Widget _buildLeftPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(
          right: BorderSide(color: Colors.white12, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 75, 15, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8b5cf6), Color(0xFF6d28d9)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4D8b5cf6), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(
                          Icons.bubble_chart,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.t('header_title').toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              state.t('header_subtitle'),
                              style: const TextStyle(
                                color: Color(0xFFc4b5fd),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ['en', 'hi'].map((l) {
                            final isActive = state.lang == l;
                            return GestureDetector(
                              onTap: () => state.setLanguage(l),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF8b5cf6)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // Restart Button
                      IconButton(
                        icon: const Icon(Icons.power_settings_new),
                        color: Colors.red[400],
                        iconSize: 24,
                        onPressed: state.resetLab,
                        tooltip: 'Restart Lab',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            // PANEL CONTENT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.t('phase_label').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${state.t('step_label')} ${math.min(state.step, 7)}/7",
                        style: const TextStyle(
                          color: Color(0xFF8b5cf6),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: math.min(state.step, 7) / 7,
                    backgroundColor: Colors.black38,
                    color: const Color(0xFF8b5cf6),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF8b5cf6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // STATIC OBJECTIVE TEXT
                  Text(
                    state.t('objective_desc'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // PROCEDURAL STEPS LIST (Accordion style)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      int logicIndex = index + 1;
                      bool isActive = logicIndex == state.step;
                      bool isDone = logicIndex < state.step;
                      return Container(
                        key: stepKeys[index],
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF8b5cf6).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF8b5cf6)
                                : (isDone
                                      ? const Color(0xFF10b981).withOpacity(0.3)
                                      : Colors.white12),
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDone
                                      ? Icons.check_circle
                                      : (isActive
                                            ? Icons.play_circle_fill
                                            : Icons.radio_button_unchecked),
                                  color: isDone
                                      ? const Color(0xFF10b981)
                                      : (isActive
                                            ? const Color(0xFF8b5cf6)
                                            : Colors.white30),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.t('s${logicIndex}_t'),
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : (isDone
                                                ? Colors.white70
                                                : Colors.white30),
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 12),
                              Text(
                                state.t('s${logicIndex}_i'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFc4b5fd),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              LabControls(state: state),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // FOOTER
                  const Center(
                    child: Text(
                      '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- RIGHT SIDEBAR (Calculations & Data Table) ---
  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(left: BorderSide(color: Colors.white12, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
            child: Row(
              children: [
                const Icon(Icons.data_usage, color: Color(0xFFc084fc)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.t('calc_title').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 70,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.t('data_table_title'),
                    style: const TextStyle(
                      color: Color(0xFFc084fc),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // DATA TABLE
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0x80020617),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1e293b)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: const Color(0xFF1e293b)),
                        child: DataTable(
                          headingRowHeight: 40,
                          dataRowMinHeight: 36,
                          dataRowMaxHeight: 36,
                          columnSpacing: 16,
                          columns: [
                            DataColumn(
                              label: Text(
                                state.t('th_event'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_fav'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_prob'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFc084fc),
                                ),
                              ),
                            ),
                          ],
                          rows: List.generate(math.min(state.step, 6), (index) {
                            int stepForRow = index + 1;

                            int fav = 0;
                            if (stepForRow == 1) {
                              fav = 12;
                            } else if (stepForRow == 2) {
                              fav = 5;
                            } else if (stepForRow == 3) {
                              fav = 4;
                            } else if (stepForRow == 4) {
                              fav = 3;
                            } else if (stepForRow == 5) {
                              fav = 9;
                            } else if (stepForRow == 6) {
                              fav = 0;
                            }

                            String probStr = _getProbStr(fav, 12);
                            bool isCurrent = stepForRow == state.step;
                            bool actionExecuted = state.step > stepForRow;

                            return DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>(
                                (states) =>
                                    isCurrent ? const Color(0x338b5cf6) : null,
                              ),
                              cells: [
                                DataCell(
                                  Text(
                                    _getEventLabel(stepForRow),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isCurrent
                                          ? Colors.white
                                          : const Color(0xFFcbd5e1),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    actionExecuted ? '$fav' : '?',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isCurrent
                                          ? Colors.white
                                          : const Color(0xFFcbd5e1),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    actionExecuted
                                        ? (stepForRow == 1 ? '-' : probStr)
                                        : '?',
                                    style: TextStyle(
                                      color: isCurrent
                                          ? const Color(0xFFc4b5fd)
                                          : const Color(0xFFc084fc),
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventLabel(int step) {
    if (state.lang == 'hi') {
      switch (step) {
        case 1:
          return 'कुल कंचे';
        case 2:
          return 'लाल कंचा';
        case 3:
          return 'नीला कंचा';
        case 4:
          return 'हरा कंचा';
        case 5:
          return 'हरा नहीं';
        case 6:
          return 'पीला कंचा';
        default:
          return '';
      }
    } else {
      switch (step) {
        case 1:
          return 'Total Marbles';
        case 2:
          return 'Red Marble';
        case 3:
          return 'Blue Marble';
        case 4:
          return 'Green Marble';
        case 5:
          return 'Not Green';
        case 6:
          return 'Yellow Marble';
        default:
          return '';
      }
    }
  }

  String _getProbStr(int fav, int total) {
    if (fav == 0) return '0';
    if (fav == total) return '1';

    int gcd = _gcd(fav, total);
    if (gcd == 1) return '$fav/$total';
    return '$fav/$total = ${fav ~/ gcd}/${total ~/ gcd}';
  }

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}

// --- LAB CONTROLS WIDGET ---
class LabControls extends StatelessWidget {
  final AppState state;
  const LabControls({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.step == 7) {
      return buildPrimaryBtn(
        state.t('s7_b'),
        const Color(0xFF8b5cf6),
        state.nextStep,
      );
    } else {
      return buildPrimaryBtn(
        state.t('s${state.step}_b'),
        const Color(0xFF8b5cf6),
        () {
          state.nextStep();
          if (!state.isRightPanelOpen && state.step > 1) {
            state.toggleRightPanel();
          }
        },
      );
    }
  }

  Widget buildPrimaryBtn(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}

// --- FLOATING MISSION CARD ---
class FloatingMissionCard extends StatelessWidget {
  final AppState state;
  const FloatingMissionCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEE0f172a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8b5cf6).withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.t('s${math.min(state.step, 7)}_t').toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF8b5cf6),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.t('s${math.min(state.step, 7)}_i'),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          LabControls(state: state),
        ],
      ),
    );
  }
}

// --- VISUALIZER AREA ---
class VisualizerArea extends StatelessWidget {
  final AppState state;
  const VisualizerArea({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        List<Marble> targets = state.targetMarbles;

        double jarCenterX = 0;
        double jarCenterY = 0;

        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(5000),
          minScale: 0.2,
          maxScale: 4.0,
          constrained:
              false, // Prevents forced centering which fights the bounds
          child: SizedBox(
            width: math.max(800.0, width),
            height: math.max(600.0, height),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Glass Jar (Back layer)
                Transform.translate(
                  offset: Offset(jarCenterX, jarCenterY),
                  child: Container(
                    width: 220,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Jar neck
                Transform.translate(
                  offset: Offset(jarCenterX, jarCenterY - 145),
                  child: Container(
                    width: 140,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Animated Marbles
                ...jarMarbles.map((marble) {
                  bool isTarget = targets.contains(marble);

                  Offset targetOffset;
                  double scale = 1.0;

                  if (isTarget && state.visualStep > 0) {
                    int targetIndex = targets.indexOf(marble);
                    int totalTargets = targets.length;
                    double spreadX =
                        (targetIndex - (totalTargets - 1) / 2) * 45;
                    targetOffset = Offset(
                      jarCenterX + spreadX,
                      jarCenterY - 220,
                    );
                    scale = 1.2;
                  } else {
                    targetOffset = Offset(
                      jarCenterX + marble.baseOffset.dx,
                      jarCenterY + marble.baseOffset.dy,
                    );
                    if (state.visualStep > 0 && state.visualStep < 6) {
                      scale = 0.6;
                    }
                  }

                  return AnimatedMarbleWidget(
                    marble: marble,
                    targetOffset: targetOffset,
                    targetScale: scale,
                    isTarget: isTarget,
                    step: state.visualStep,
                    delay: isTarget ? targets.indexOf(marble) * 50 : 0,
                  );
                }),

                // Glass Jar (Front reflection layer)
                Transform.translate(
                  offset: Offset(jarCenterX, jarCenterY),
                  child: Container(
                    width: 220,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.05),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedMarbleWidget extends ImplicitlyAnimatedWidget {
  final Marble marble;
  final Offset targetOffset;
  final double targetScale;
  final bool isTarget;
  final int step;
  final int delay;

  AnimatedMarbleWidget({
    super.key,
    required this.marble,
    required this.targetOffset,
    required this.targetScale,
    required this.isTarget,
    required this.step,
    required this.delay,
  }) : super(
         duration: Duration(milliseconds: 800 + delay),
         curve: Curves.easeOutBack,
       );

  @override
  _AnimatedMarbleWidgetState createState() => _AnimatedMarbleWidgetState();
}

class _AnimatedMarbleWidgetState
    extends ImplicitlyAnimatedWidgetState<AnimatedMarbleWidget> {
  Tween<Offset>? _offsetTween;
  Tween<double>? _scaleTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _offsetTween =
        visitor(
              _offsetTween,
              widget.targetOffset,
              (dynamic value) => Tween<Offset>(begin: value as Offset),
            )
            as Tween<Offset>?;

    _scaleTween =
        visitor(
              _scaleTween,
              widget.targetScale,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        Offset offset =
            _offsetTween?.evaluate(animation) ?? widget.targetOffset;
        double scale = _scaleTween?.evaluate(animation) ?? widget.targetScale;

        double opacity = 1.0;
        if (widget.step > 0 && widget.step < 6 && !widget.isTarget) {
          opacity = 0.4;
        }

        return Transform.translate(
          offset: offset,
          child: Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity, child: _buildMarbleSphere()),
          ),
        );
      },
    );
  }

  Widget _buildMarbleSphere() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(2, 4)),
        ],
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: [
            widget.marble.materialHighlight,
            widget.marble.materialColor,
            widget.marble.materialColor.withOpacity(0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
          margin: const EdgeInsets.only(bottom: 20, right: 10),
          transform: Matrix4.rotationZ(-0.5),
        ),
      ),
    );
  }
}

// --- OVERLAYS ---
class CelebrationOverlay extends StatelessWidget {
  final AppState state;
  const CelebrationOverlay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: SingleChildScrollView(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 40,
                  ),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xEB0f172a),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x808b5cf6)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x668b5cf6), blurRadius: 60),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔮', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFc4b5fd),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.t('cel_msg'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFcbd5e1),
                          fontSize: 18,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _resultBox(
                            'Total Marbles',
                            '12',
                            const Color(0xFF94a3b8),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10b981),
                            size: 40,
                          ),
                          _resultBox(
                            'P(Not Green)',
                            '3/4',
                            const Color(0xFF8b5cf6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: state.resetLab,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          state.t('btn_restart'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8b5cf6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _resultBox(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94a3b8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CurtainRaiser extends StatelessWidget {
  final AppState state;
  final VoidCallback onInit;

  const CurtainRaiser({super.key, required this.state, required this.onInit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020617),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(painter: DotPatternPainter(), size: Size.infinite),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x4D8b5cf6), blurRadius: 40),
                      ],
                    ),
                    child: const Icon(
                      Icons.bubble_chart,
                      size: 64,
                      color: Color(0xFFa855f7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    state.t('app_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x800f172a),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Text(
                      state.t('tagline'),
                      style: const TextStyle(
                        color: Color(0xFF94a3b8),
                        fontFamily: 'monospace',
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: onInit,
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: Text(
                      state.t('init_btn'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8b5cf6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 20,
                      shadowColor: const Color(0xFF8b5cf6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background Pattern effect
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (double i = 0; i < size.width; i += 40) {
      for (double j = 0; j < size.height; j += 40) {
        canvas.drawCircle(Offset(i + 20, j + 20), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
