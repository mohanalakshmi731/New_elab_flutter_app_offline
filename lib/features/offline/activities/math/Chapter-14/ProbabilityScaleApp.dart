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

// --- I18N DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'PROBABILITY SCALE',
    'tagline': 'SPACE ACADEMY SIMULATOR',
    'init_btn': 'INITIALIZE SYSTEM',
    'header_title': 'The Probability Scale',
    'header_subtitle': 'CLASS 10 • PROBABILITY',
    'phase_label': 'ANALYSIS PHASE',
    'step_label': 'Stage',
    'mission_log': 'Console Log',
    'active_mission': 'Current Objective',
    'cel_title': 'CALIBRATION COMPLETE!',
    'cel_msg': 'Probability Scale Mastered',
    'btn_restart': 'Restart Simulation',
    's1_t': 'Step 1: Impossible Event',
    's1_i':
        'Event: Rolling an 8 on a standard 6-sided die.\n\nSince a die only has faces 1 to 6, this can never happen. The probability is exactly 0.',
    's1_b': 'Analyze Next Event',
    's2_t': 'Step 2: Unlikely Event',
    's2_i':
        'Event: Rolling exactly a 6 on a die.\n\nP(6) = 1/6 ≈ 0.167.\nIt is possible, but the probability is less than half (0.5).',
    's2_b': 'Analyze Next Event',
    's3_t': 'Step 3: Even Chance',
    's3_i':
        'Event: Flipping a coin and getting Heads.\n\nP(Heads) = 1/2 = 0.50.\nThere is a perfectly equal 50/50 chance.',
    's3_b': 'Analyze Next Event',
    's4_t': 'Step 4: Likely Event',
    's4_i':
        'Event: Drawing any card that is NOT a Spade.\n\nP(Not Spade) = 39/52 = 0.75.\nIt is highly probable, but not guaranteed.',
    's4_b': 'Analyze Next Event',
    's5_t': 'Step 5: Certain Event',
    's5_i':
        'Event: Rolling a number less than 7 on a die.\n\nP(< 7) = 6/6 = 1.0.\nThis is guaranteed to happen on every single roll.',
    's5_b': 'Unlock Scale Calibrator',
    's6_t': 'Step 6: The Probability Scale',
    's6_i':
        'Drag the slider to manually calibrate the probability scale. Observe how the terminology changes based on the value.',
    's6_b': 'Complete Simulation',
    'lbl_impossible': 'IMPOSSIBLE',
    'lbl_unlikely': 'UNLIKELY',
    'lbl_even': 'EVEN CHANCE',
    'lbl_likely': 'LIKELY',
    'lbl_certain': 'CERTAIN',
    'objective_desc':
        'Calibrate the probability scale and observe how event terminology correlates with specific ranges from Impossible to Certain.',
  },
  'hi': {
    'app_title': 'प्रायिकता पैमाना',
    'tagline': 'स्पेस अकादमी सिमुलेटर',
    'init_btn': 'सिस्टम शुरू करें',
    'header_title': 'प्रायिकता पैमाना',
    'header_subtitle': 'कक्षा 10 • प्रायिकता',
    'phase_label': 'विश्लेषण चरण',
    'step_label': 'चरण',
    'mission_log': 'कंसोल लॉग',
    'active_mission': 'वर्तमान उद्देश्य',
    'cel_title': 'अंशांकन पूर्ण!',
    'cel_msg': 'प्रायिकता पैमाना में महारत हासिल',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: असंभव घटना',
    's1_i':
        'घटना: एक मानक 6-तरफा पासे पर 8 प्राप्त करना।\n\nचूंकि पासे में केवल 1 से 6 तक के चेहरे होते हैं, यह कभी नहीं हो सकता। प्रायिकता ठीक 0 है।',
    's1_b': 'अगली घटना का विश्लेषण करें',
    's2_t': 'चरण 2: असंभाव्य घटना',
    's2_i':
        'घटना: पासे पर ठीक 6 प्राप्त करना।\n\nP(6) = 1/6 ≈ 0.167।\nयह संभव है, लेकिन प्रायिकता आधे (0.5) से कम है।',
    's2_b': 'अगली घटना का विश्लेषण करें',
    's3_t': 'चरण 3: समान संभावना',
    's3_i':
        'घटना: सिक्का उछालना और चित (Heads) प्राप्त करना।\n\nP(चित) = 1/2 = 0.50।\nयहाँ पूरी तरह से समान 50/50 संभावना है।',
    's3_b': 'अगली घटना का विश्लेषण करें',
    's4_t': 'चरण 4: संभाव्य घटना',
    's4_i':
        'घटना: ऐसा कार्ड खींचना जो हुकुम (Spade) न हो।\n\nP(हुकुम नहीं) = 39/52 = 0.75।\nयह अत्यधिक संभाव्य है, लेकिन गारंटी नहीं है।',
    's4_b': 'अगली घटना का विश्लेषण करें',
    's5_t': 'चरण 5: निश्चित घटना',
    's5_i':
        'घटना: पासे पर 7 से कम संख्या प्राप्त करना।\n\nP(< 7) = 6/6 = 1.0।\nयह हर बार होने की गारंटी है।',
    's5_b': 'स्केल कैलिब्रेटर अनलॉक करें',
    's6_t': 'चरण 6: प्रायिकता पैमाना',
    's6_i':
        'प्रायिकता पैमाने को मैन्युअल रूप से कैलिब्रेट करने के लिए स्लाइडर को खींचें। ध्यान दें कि मान के आधार पर शब्दावली कैसे बदलती है।',
    's6_b': 'सिमुलेशन पूरा करें',
    'lbl_impossible': 'असंभव',
    'lbl_unlikely': 'असंभाव्य',
    'lbl_even': 'समान संभावना',
    'lbl_likely': 'संभाव्य',
    'lbl_certain': 'निश्चित',
    'objective_desc':
        'प्रायिकता पैमाने को कैलिब्रेट करें और देखें कि घटना की शब्दावली असंभव (0) से निश्चित (1) तक कैसे बदलती है।',
  },
};

// --- STATE MANAGEMENT ---
class AppState extends ChangeNotifier {
  bool isInitialized = false;
  String lang = 'en';
  bool isLeftPanelOpen = true;

  int step = 1;
  double manualProbability = 0.0;

  double get targetProbability {
    switch (step) {
      case 1:
        return 0.0;
      case 2:
        return 0.167; // 1/6
      case 3:
        return 0.50; // 1/2
      case 4:
        return 0.75; // 3/4
      case 5:
        return 1.0;
      case 6:
        return manualProbability;
      default:
        return 0.0;
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

  void nextStep() {
    if (step < 7) {
      step++;
      if (step == 7) {
        AudioManager.playSuccess();
      } else {
        AudioManager.playClick();
      }
      notifyListeners();
    } else {
      AudioManager.playError();
    }
  }

  void setManualProbability(double val) {
    if (step == 6) {
      manualProbability = val;
      notifyListeners();
    }
  }

  void resetLab() {
    step = 1;
    manualProbability = 0.0;
    lang = 'en'; // Force reset to English
    isLeftPanelOpen = true;
    isInitialized = false;
    AudioManager.playShutter();
    notifyListeners();
  }

  String t(String key) {
    return i18n[lang]?[key] ?? key;
  }
}

class ProbabilityScaleApp extends StatefulWidget {
  const ProbabilityScaleApp({super.key});

  @override
  State<ProbabilityScaleApp> createState() => _ProbabilityScaleAppState();
}

class _ProbabilityScaleAppState extends State<ProbabilityScaleApp> {
  final AppState state = AppState();
  final List<GlobalKey> stepKeys = List.generate(6, (index) => GlobalKey());
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
    if (step < 1 || step > 6) return;
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
    double panelWidth = (screenWidth * 0.38).clamp(320.0, 500.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // Background Grid
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: SpaceGridPainter()),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [Color(0xFF0f172a), Color(0xFF020617)],
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
              right: 0,
              // REMOVED InteractiveViewer here to prevent infinity constraints crashing LayoutBuilder
              child: VisualizerArea(state: state),
            ),

            // 2. FLOATING MISSION CARD (Visible when left panel is closed)
            if (state.isInitialized && !state.isLeftPanelOpen && state.step < 7)
              Positioned(
                top: 85,
                left: 20,
                child: FloatingMissionCard(state: state),
              ),

            // 3. LEFT PANEL (Mission/Controls)
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

            // 4. FRONT SCREEN FIXED FLOATING BUTTONS
            if (state.isInitialized) ...[
              // Menu Button (Top Left)
              Positioned(
                top: 20,
                left: 20,
                child: _buildFloatingActionBtn(
                  icon: state.isLeftPanelOpen ? Icons.menu_open : Icons.menu,
                  onTap: state.toggleLeftPanel,
                  color: const Color(0xFF06b6d4),
                  tooltip: 'Menu',
                ),
              ),
            ],

            // CELEBRATION (Step 7)
            if (state.step == 7 && state.isInitialized)
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
                            colors: [Color(0xFF06b6d4), Color(0xFF0284c7)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4D06b6d4), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
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
                                color: Color(0xFF67e8f9),
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
                                      ? const Color(0xFF06b6d4)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.black
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
                        "${state.t('step_label')} ${math.min(state.step, 6)}/6",
                        style: const TextStyle(
                          color: Color(0xFF06b6d4),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: math.min(state.step, 6) / 6,
                    backgroundColor: Colors.black38,
                    color: const Color(0xFF06b6d4),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF06b6d4),
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
                    itemCount: 6,
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
                              ? const Color(0xFF06b6d4).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF06b6d4)
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
                                            ? const Color(0xFF06b6d4)
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
                                  color: Color(0xFFcffafe),
                                  height: 1.4,
                                ),
                              ),

                              // Slider for Step 6
                              if (logicIndex == 6) ...[
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0x66020617),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF1e293b),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'MANUAL CALIBRATION',
                                        style: TextStyle(
                                          color: Color(0xFF94a3b8),
                                          fontSize: 10,
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: const Color(
                                            0xFF06b6d4,
                                          ),
                                          inactiveTrackColor: const Color(
                                            0xFF334155,
                                          ),
                                          thumbColor: Colors.white,
                                          overlayColor: const Color(0x3306b6d4),
                                          valueIndicatorColor: const Color(
                                            0xFF06b6d4,
                                          ),
                                          trackHeight: 6,
                                        ),
                                        child: Slider(
                                          value: state.manualProbability,
                                          min: 0.0,
                                          max: 1.0,
                                          divisions: 100,
                                          label: state.manualProbability
                                              .toStringAsFixed(2),
                                          onChanged: state.setManualProbability,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Text(
                                            '0.0',
                                            style: TextStyle(
                                              color: Color(0xFF64748b),
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '0.5',
                                            style: TextStyle(
                                              color: Color(0xFF64748b),
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '1.0',
                                            style: TextStyle(
                                              color: Color(0xFF64748b),
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),
                              StepControllerBtn(state: state),
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
}

// --- REUSABLE CONTROL BUTTON ---
class StepControllerBtn extends StatelessWidget {
  final AppState state;
  const StepControllerBtn({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    int currentStep = math.min(state.step, 6);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06b6d4),
          foregroundColor: Colors.black, // Dark text on cyan button
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
              state.t('s${currentStep}_b'),
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
        border: Border.all(color: const Color(0xFF06b6d4).withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.t('s${math.min(state.step, 6)}_t').toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF06b6d4),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.t('s${math.min(state.step, 6)}_i'),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          StepControllerBtn(state: state),
        ],
      ),
    );
  }
}

// --- VISUALIZER AREA ---
class VisualizerArea extends StatelessWidget {
  final AppState state;
  const VisualizerArea({super.key, required this.state});

  String _getLikelihoodTerm(double prob) {
    if (prob == 0) return state.t('lbl_impossible');
    if (prob > 0 && prob < 0.5) return state.t('lbl_unlikely');
    if (prob == 0.5) return state.t('lbl_even');
    if (prob > 0.5 && prob < 1.0) return state.t('lbl_likely');
    if (prob == 1.0) return state.t('lbl_certain');
    return '';
  }

  Color _getLikelihoodColor(double prob) {
    if (prob == 0) return const Color(0xFFef4444); // Red
    if (prob > 0 && prob < 0.5) return const Color(0xFFf59e0b); // Amber
    if (prob == 0.5) return const Color(0xFF38bdf8); // Light Blue
    if (prob > 0.5 && prob < 1.0) return const Color(0xFF10b981); // Emerald
    if (prob == 1.0) return const Color(0xFF2dd4bf); // Teal
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    double prob = state.targetProbability;
    String term = _getLikelihoodTerm(prob);
    Color tColor = _getLikelihoodColor(prob);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Safe InteractiveViewer positioned INSIDE LayoutBuilder to prevent crashes
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(5000),
          minScale: 0.2,
          maxScale: 4.0,
          constrained:
              false, // Now safe because its parent provides strict dimensions
          child: SizedBox(
            width: math.max(800.0, constraints.maxWidth),
            height: math.max(600.0, constraints.maxHeight),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Base holographic rings
                Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x1A06b6d4),
                      width: 1,
                    ),
                  ),
                ),
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x3306b6d4),
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
                  ),
                ),

                // Central HUD data
                Positioned(
                  top: math.max(600.0, constraints.maxHeight) / 2 - 180,
                  child: Column(
                    children: [
                      const Text(
                        'PROBABILITY',
                        style: TextStyle(
                          color: Color(0xFF64748b),
                          fontSize: 12,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: prob),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Text(
                            value.toStringAsFixed(3),
                            style: TextStyle(
                              color: tColor,
                              fontSize: 48,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              shadows: [
                                BoxShadow(
                                  color: tColor.withOpacity(0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Volumetric Cylinder (Pseudo-3D Pie Chart)
                Positioned(
                  top: math.max(600.0, constraints.maxHeight) / 2 + 20,
                  child: AnimatedVolumetricPie(prob: prob, baseColor: tColor),
                ),

                // Probability term label
                Positioned(
                  top: math.max(600.0, constraints.maxHeight) / 2 + 140,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(term),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: tColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tColor.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: tColor.withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Text(
                        term,
                        style: TextStyle(
                          color: tColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
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

// Pseudo-3D Volumetric Pie Chart Widget
class AnimatedVolumetricPie extends StatelessWidget {
  final double prob;
  final Color baseColor;

  const AnimatedVolumetricPie({
    super.key,
    required this.prob,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: prob),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, animatedProb, child) {
        return CustomPaint(
          size: const Size(200, 100), // Width and visual height
          painter: VolumetricPiePainter(
            probability: animatedProb,
            fillColor: baseColor,
            bgColor: const Color(0xFF1e293b),
            thickness: 30.0,
          ),
        );
      },
    );
  }
}

class VolumetricPiePainter extends CustomPainter {
  final double probability;
  final Color fillColor;
  final Color bgColor;
  final double thickness;

  VolumetricPiePainter({
    required this.probability,
    required this.fillColor,
    required this.bgColor,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double rx = size.width / 2;
    final double ry = size.height / 2;

    final Paint bgBasePaint = Paint()
      ..color = bgColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final Paint bgTopPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    final Paint bgEdgePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 1. Draw Background Cylinder
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + thickness),
        width: rx * 2,
        height: ry * 2,
      ),
      bgBasePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, cy + thickness / 2),
        width: rx * 2,
        height: thickness,
      ),
      bgBasePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      bgTopPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      bgEdgePaint,
    );

    // 2. Draw Probability Slice
    if (probability > 0) {
      double sweepAngle = probability * 2 * math.pi;
      double startAngle = -math.pi / 2;

      Color darkFill = HSLColor.fromColor(fillColor)
          .withLightness(
            (HSLColor.fromColor(fillColor).lightness - 0.2).clamp(0.0, 1.0),
          )
          .toColor();
      Color brightFill = fillColor;

      // Pseudo-3D trick: Stacked arcs
      for (double i = thickness; i >= 0; i -= 0.5) {
        Color c = i <= 0.5 ? brightFill : darkFill;
        final Paint slicePaint = Paint()
          ..color = c
          ..style = PaintingStyle.fill;

        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx, cy + i),
            width: rx * 2,
            height: ry * 2,
          ),
          startAngle,
          sweepAngle,
          true,
          slicePaint,
        );
      }

      // Highlight edge
      final Paint highlightEdge = Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        startAngle,
        sweepAngle,
        true,
        highlightEdge,
      );
    }
  }

  @override
  bool shouldRepaint(covariant VolumetricPiePainter oldDelegate) {
    return oldDelegate.probability != probability ||
        oldDelegate.fillColor != fillColor;
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
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xEB0f172a),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x8006b6d4)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x6606b6d4), blurRadius: 60),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🚀', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF67e8f9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.t('cel_msg'),
                        style: const TextStyle(
                          color: Color(0xFFcbd5e1),
                          fontSize: 18,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _resultBox(
                              'Impossible',
                              '0',
                              const Color(0xFFef4444),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_right_alt,
                              color: Color(0xFF334155),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            _resultBox('Even', '0.5', const Color(0xFF38bdf8)),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_right_alt,
                              color: Color(0xFF334155),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            _resultBox('Certain', '1', const Color(0xFF2dd4bf)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: state.resetLab,
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        label: Text(
                          state.t('btn_restart'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06b6d4),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _resultBox(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Curtain Raiser
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
          CustomPaint(painter: SpaceGridPainter(), size: Size.infinite),
          SingleChildScrollView(
            child: Padding(
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
                        BoxShadow(color: Color(0x4D06b6d4), blurRadius: 40),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      size: 64,
                      color: Color(0xFF22d3ee),
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
                    icon: const Icon(
                      Icons.power_settings_new,
                      color: Colors.black,
                    ),
                    label: Text(
                      state.t('init_btn'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06b6d4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 20,
                      shadowColor: const Color(0xFF06b6d4),
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

// Background Pattern
class SpaceGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double centerX = size.width / 2;
    double centerY = size.height / 2;

    for (double r = 50; r < size.width; r += 50) {
      canvas.drawCircle(Offset(centerX, centerY), r, paint);
    }

    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
