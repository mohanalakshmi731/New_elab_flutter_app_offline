// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

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

// --- DATASET ---
class DataRowModel {
  final int lower;
  final int upper;
  final int f;
  final int cf;

  DataRowModel(this.lower, this.upper, this.f, this.cf);
}

final List<DataRowModel> dataset = [
  DataRowModel(0, 10, 5, 5),
  DataRowModel(10, 20, 3, 8), // Preceding cf = 8
  DataRowModel(20, 30, 4, 12), // Median Class (f=4, l=20)
  DataRowModel(30, 40, 3, 15),
  DataRowModel(40, 50, 3, 18),
];

final List<Color> barColors = [
  const Color(0xFFef4444), // Red
  const Color(0xFFf97316), // Orange
  const Color(0xFFeab308), // Yellow
  const Color(0xFF22c55e), // Green
  const Color(0xFF3b82f6), // Blue
];

// --- I18N DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE MEDIAN LINE',
    'tagline': 'FINDING THE MIDDLE GROUND',
    'init_btn': 'INITIALIZE LAB',
    'header_title': 'The Median Line',
    'header_subtitle': 'CLASS 10 • STATISTICS',
    'phase_label': 'ANALYSIS PHASE',
    'step_label': 'Stage',
    'mission_log': 'Console Log',
    'active_mission': 'Current Objective',
    'th_marks': 'Marks',
    'th_fi': 'Students (f)',
    'th_cf': 'Cum. Freq (cf)',
    'row_total': 'Total',
    'cel_title': 'SUCCESS!',
    'cel_msg': 'Median Calculated Successfully',
    'btn_restart': 'Restart Simulation',
    's1_t': 'Step 1: The Data',
    's1_i': 'Observe the frequency distribution of marks.',
    's1_b': 'Analyze Data',
    's2_t': 'Step 2: Cumulative Frequency',
    's2_i':
        'We need the running total. Calculate <strong>cf</strong> for each row.',
    's2_b': 'Calculate cf',
    's3_t': 'Step 3: Find N/2',
    's3_i': 'Total N = 18. Where is the middle? Calculate N/2.',
    's3_b': 'Check Answer',
    's4_t': 'Step 4: Median Class',
    's4_i':
        'Find the first class where <strong>cf ≥ 9</strong>. Tap that bar in the 3D view.',
    's4_b': 'Locate Median Class',
    's5_t': 'Step 5: Identify Parameters',
    's5_i':
        'We need <strong>l</strong> (lower limit), <strong>f</strong> (frequency), and <strong>cf</strong> (preceding cumulative).',
    's5_b': 'Scan Parameters',
    's6_t': 'Step 6: Formula Assembly',
    's6_i':
        'Open the Data panel and tap variables from the bank to fill the formula slots.',
    's6_b': 'ASSEMBLE FORMULA',
    's7_t': 'Step 7: Final Computation',
    's7_i': 'Solve the equation in the Data panel to find the exact Median.',
    's7_b': 'Compute Median',
    'msg_click_median': 'Tap the bar for class 20-30 (cf=12)',
    'msg_wrong_bar':
        'Look for the first class where cf (Cumulative Frequency) is 9 or greater.',
    'calc_n2_label': 'CALCULATED N/2',
    'msg_populate': 'Populate formula below',
    'calc_step_1_t': 'Subtract (N/2 - cf)',
    'calc_step_2_t': 'Divide by f (1 / 4)',
    'calc_step_3_t': 'Multiply by h (× 10)',
    'calc_step_4_t': 'Add l (20 + 2.5)',
    'status_locked': 'Locked',
    'status_calc': 'Calculate',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Frequency Distribution',
    'formula_title': '2. Median Formula',
    'mission_title': 'Mission Status',
    'objective_desc':
        'Locate the median class using cumulative frequencies and calculate the exact median value using the formula.',
  },
  'hi': {
    'app_title': 'माध्यिका रेखा',
    'tagline': 'मध्य खोजना',
    'init_btn': 'लैब शुरू करें',
    'header_title': 'माध्यिका रेखा',
    'header_subtitle': 'कक्षा 10 • सांख्यिकी',
    'phase_label': 'विश्लेषण चरण',
    'step_label': 'चरण',
    'mission_log': 'कंसोल लॉग',
    'active_mission': 'वर्तमान उद्देश्य',
    'th_marks': 'अंक',
    'th_fi': 'छात्र (f)',
    'th_cf': 'संचाई बारंबारता (cf)',
    'row_total': 'कुल',
    'cel_title': 'सफल!',
    'cel_msg': 'माध्यिका की गणना सफल',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: डेटा',
    's1_i': 'अंकों का बारंबारता वितरण देखें।',
    's1_b': 'डेटा विश्लेषण',
    's2_t': 'चरण 2: संचाई बारंबारता',
    's2_i':
        'हमें कुल योग चाहिए। प्रत्येक पंक्ति के लिए <strong>cf</strong> की गणना करें।',
    's2_b': 'cf की गणना करें',
    's3_t': 'चरण 3: N/2 खोजें',
    's3_i': 'कुल N = 18. मध्य कहाँ है? N/2 की गणना करें।',
    's3_b': 'उत्तर जांचें',
    's4_t': 'चरण 4: माध्यिका वर्ग',
    's4_i':
        'वह पहला वर्ग खोजें जहाँ <strong>cf ≥ 9</strong> है। 3D दृश्य में उस बार पर टैप करें।',
    's4_b': 'माध्यिका वर्ग खोजें',
    's5_t': 'चरण 5: पैरामीटर पहचानें',
    's5_i':
        'हमें <strong>l</strong>, <strong>f</strong>, और <strong>cf</strong> (पिछला) की आवश्यकता है।',
    's5_b': 'पैरामीटर स्कैन करें',
    's6_t': 'चरण 6: सूत्र संयोजन',
    's6_i': 'डेटा पैनल खोलें और सूत्र में चर डालने के लिए टैप करें।',
    's6_b': 'सूत्र संयोजित करें',
    's7_t': 'चरण 7: अंतिम गणना',
    's7_i': 'सटीक माध्यिका ज्ञात करने के लिए डेटा पैनल में समीकरण हल करें।',
    's7_b': 'माध्यिका निकालें',
    'msg_click_median': 'वर्ग 20-30 (cf=12) के लिए बार पर टैप करें',
    'msg_wrong_bar': 'वह पहला वर्ग देखें जहाँ cf 9 या उससे अधिक है।',
    'calc_n2_label': 'गणना की गई N/2',
    'msg_populate': 'नीचे सूत्र भरें',
    'calc_step_1_t': 'घटाना (N/2 - cf)',
    'calc_step_2_t': 'f से भाग दें (1 / 4)',
    'calc_step_3_t': 'h से गुणा करें (× 10)',
    'calc_step_4_t': 'l जोड़ें (20 + 2.5)',
    'status_locked': 'लॉक्ड',
    'status_calc': 'गणना करें',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. बारंबारता वितरण',
    'formula_title': '2. माध्यिका सूत्र',
    'mission_title': 'मिशन स्थिति',
    'objective_desc':
        'संचयी बारंबारता का उपयोग करके माध्यिका वर्ग का पता लगाएं और सूत्र का उपयोग करके सटीक माध्यिका मान की गणना करें।',
  },
};

// --- STATE MANAGEMENT ---
class AppState extends ChangeNotifier {
  bool isInitialized = false;
  String lang = 'en';

  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  int step = 1;
  int selectedId = -1;
  int calcStage = 0;

  final TextEditingController n2Controller = TextEditingController();

  Map<String, bool> filledSlots = {
    'l': false,
    'n2': false,
    'cf': false,
    'f': false,
    'h': false,
  };

  // Flag to detect and prevent updates on an unmounted state
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    n2Controller.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
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
    }
  }

  void handleBarClick(int id) {
    if (step == 4) {
      if (id == 2) {
        // 20-30 class is index 2
        selectedId = id;
        nextStep();
      } else {
        AudioManager.playError();
        // Error feedback handled in the Visualizer3D
      }
    }
  }

  void fillSlot(String type) {
    if (!filledSlots[type]!) {
      filledSlots[type] = true;
      AudioManager.playClick();
      notifyListeners();

      if (filledSlots.values.every((element) => element)) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!_isDisposed) {
            nextStep(); // Progress to step 7
          }
        });
      }
    }
  }

  void advanceCalc(int idx) {
    if (idx == calcStage) {
      calcStage++;
      AudioManager.playClick();
      notifyListeners();
      if (calcStage >= 4) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!_isDisposed) {
            nextStep(); // Finish computation -> Celebration
          }
        });
      }
    }
  }

  void resetLab() {
    step = 1;
    selectedId = -1;
    calcStage = 0;
    n2Controller.clear();
    filledSlots = {
      'l': false,
      'n2': false,
      'cf': false,
      'f': false,
      'h': false,
    };
    lang = 'en'; // Force reset to English
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

class MedianLineApp extends StatefulWidget {
  const MedianLineApp({super.key});

  @override
  State<MedianLineApp> createState() => _MedianLineAppState();
}

class _MedianLineAppState extends State<MedianLineApp> {
  final AppState state = AppState();
  final List<GlobalKey> stepKeys = List.generate(7, (index) => GlobalKey());
  int _previousStep = 1;

  @override
  void initState() {
    super.initState();
    state.addListener(() {
      // Prevents "setState called after dispose()"
      if (!mounted) return;
      if (state.step != _previousStep) {
        _previousStep = state.step;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Double check mounted inside async callback
          if (mounted) {
            _scrollToStep(state.step);
          }
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
            // Background Grid Effect
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: GridPainter()),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF020617), Colors.transparent],
                    stops: [0.0, 0.4],
                  ),
                ),
              ),
            ),

            // 1. CANVAS AREA (Dynamically Centers & perfectly Movable Visualizer)
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
              child: Visualizer3D(state: state),
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
                  color: const Color(0xFF22d3ee),
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
                            colors: [Color(0xFF8b5cf6), Color(0xFFd946ef)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4D8b5cf6), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(
                          Icons.show_chart,
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
                                color: Color(0xFFa78bfa),
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
                          color: Color(0xFFa78bfa),
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
                              MissionRichText(
                                text: state.t('s${logicIndex}_i'),
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

  // --- RIGHT SIDEBAR (Calculations & Data Table - 40%) ---
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
                const Icon(Icons.data_usage, color: Color(0xFF22d3ee)),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.t('data_table_title'),
                    style: const TextStyle(
                      color: Color(0xFF22d3ee),
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
                          dataRowMinHeight: 35,
                          dataRowMaxHeight: 35,
                          columnSpacing: 16,
                          columns: [
                            DataColumn(
                              label: Text(
                                state.t('th_marks'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_fi'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            if (state.step >= 2)
                              DataColumn(
                                label: Text(
                                  state.t('th_cf'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF22d3ee),
                                  ),
                                ),
                              ),
                            if (state.step >= 4)
                              const DataColumn(
                                label: Text(
                                  'Var',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFa78bfa),
                                  ),
                                ),
                              ),
                          ],
                          rows: [
                            ...dataset.map((row) {
                              int idx = dataset.indexOf(row);
                              bool isModal = state.step >= 4 && idx == 2;
                              bool isCF = state.step >= 5 && idx == 1;

                              Color? rowColor;
                              String varLabel = '';
                              Color varColor = Colors.transparent;

                              if (isModal) {
                                rowColor = const Color(
                                  0x4D4c1d95,
                                ); // Violet 900
                                varLabel = 'Median Class';
                                varColor = const Color(0xFFa78bfa);
                              } else if (isCF) {
                                rowColor = const Color(0x33164e63); // Cyan 900
                                varLabel = 'cf (Preceding)';
                                varColor = const Color(0xFF22d3ee);
                              }

                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (states) => rowColor,
                                ),
                                cells: [
                                  DataCell(
                                    Text(
                                      '${row.lower}-${row.upper}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                        color: Color(0xFFcbd5e1),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${row.f}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (state.step >= 2)
                                    DataCell(
                                      Text(
                                        '${row.cf}',
                                        style: const TextStyle(
                                          color: Color(0xFF22d3ee),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  if (state.step >= 4)
                                    DataCell(
                                      Text(
                                        varLabel,
                                        style: TextStyle(
                                          color: varColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                            // Footer Row
                            if (state.step >= 2)
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      state.t('row_total'),
                                      style: const TextStyle(
                                        color: Color(0xFF94a3b8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '18',
                                      style: TextStyle(
                                        color: Color(0xFFa78bfa),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const DataCell(Text('')),
                                  if (state.step >= 4) const DataCell(Text('')),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FORMULA BUILDER (Step 6/7)
                  if (state.step >= 6) ...[
                    Text(
                      state.t('formula_title'),
                      style: const TextStyle(
                        color: Color(0xFFa78bfa),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (state.step == 6)
                      Text(
                        state.t('msg_populate'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 15),
                    FormulaBuilder(state: state),

                    // Calculation Steps in Step 7
                    if (state.step >= 7) ...[
                      const SizedBox(height: 20),
                      _calcStageItem(
                        0,
                        state.t('calc_step_1_t'),
                        '9 - 8 = 1',
                        'N/2 = 9, cf = 8',
                        state,
                      ),
                      const SizedBox(height: 8),
                      _calcStageItem(
                        1,
                        state.t('calc_step_2_t'),
                        '0.25',
                        'Result = 1, f = 4',
                        state,
                      ),
                      const SizedBox(height: 8),
                      _calcStageItem(
                        2,
                        state.t('calc_step_3_t'),
                        '2.5',
                        'Result = 0.25, h = 10',
                        state,
                      ),
                      const SizedBox(height: 8),
                      _calcStageItem(
                        3,
                        state.t('calc_step_4_t'),
                        '22.5',
                        'l = 20, Result = 2.5',
                        state,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcStageItem(
    int stageIdx,
    String label,
    String expectedValue,
    String infoText,
    AppState state,
  ) {
    bool isDone = stageIdx < state.calcStage;
    bool isActive = stageIdx == state.calcStage;

    Color bgColor = isDone
        ? const Color(0x33064e3b)
        : isActive
        ? const Color(0xFF8b5cf6)
        : const Color(0x801e293b);
    Color borderColor = isDone
        ? const Color(0x6610b981)
        : isActive
        ? const Color(0xFFa78bfa)
        : const Color(0x80334155);
    Color textColor = isDone
        ? const Color(0xFF34d399)
        : isActive
        ? Colors.white
        : const Color(0xFF64748b);

    String displayVal = isDone
        ? expectedValue
        : isActive
        ? state.t('status_calc')
        : state.t('status_locked');

    return GestureDetector(
      onTap: () {
        if (isActive) {
          state.advanceCalc(stageIdx);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          boxShadow: isActive
              ? [const BoxShadow(color: Color(0x808b5cf6), blurRadius: 10)]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isActive || isDone)
                    Text(
                      infoText,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  displayVal,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDone)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: Color(0xFF34d399),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- LAB CONTROLS WIDGET ---
class LabControls extends StatefulWidget {
  final AppState state;
  const LabControls({super.key, required this.state});

  @override
  State<LabControls> createState() => _LabControlsState();
}

class _LabControlsState extends State<LabControls> {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.step == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.t('calc_n2_label'),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF94a3b8),
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '18 / 2 = ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: TextField(
                  controller: state.n2Controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFa78bfa),
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0f172a),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF475569)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF8b5cf6)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _primaryBtn(state.t('s3_b'), const Color(0xFF8b5cf6), () {
            if (state.n2Controller.text.trim() == '9') {
              state.nextStep();
            } else {
              AudioManager.playError();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Try again: 18 divided by 2?')),
              );
            }
          }),
        ],
      );
    } else if (state.step == 4) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x334c1d95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x4D8b5cf6)),
        ),
        child: Center(
          child: Text(
            state.t('msg_click_median'),
            style: const TextStyle(
              color: Color(0xFFa78bfa),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (state.step == 6) {
      return _primaryBtn(state.t('s6_b'), const Color(0xFF8b5cf6), () {
        if (!state.isRightPanelOpen) state.toggleRightPanel();
      });
    } else if (state.step == 7) {
      return _primaryBtn(state.t('s7_b'), const Color(0xFF8b5cf6), () {
        if (!state.isRightPanelOpen) state.toggleRightPanel();
      });
    } else if (state.step == 8) {
      return const SizedBox(); // Celebration overlay handles it
    } else {
      return _primaryBtn(
        state.t('s${state.step}_b'),
        const Color(0xFF8b5cf6),
        () {
          state.nextStep();
        },
      );
    }
  }

  Widget _primaryBtn(String text, Color color, VoidCallback onTap) {
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
        color: const Color(0xE60f172a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3b82f6), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  state.t('s${state.step}_t').toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8b5cf6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  '${state.step}/7',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFFc4b5fd),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MissionRichText(text: state.t('s${state.step}_i')),
          const SizedBox(height: 16),
          LabControls(state: state),
        ],
      ),
    );
  }
}

// Rich Text Renderer
class MissionRichText extends StatelessWidget {
  final String text;
  const MissionRichText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    final parts = text.split('<strong>');
    for (int i = 0; i < parts.length; i++) {
      if (i == 0) {
        spans.add(
          TextSpan(
            text: parts[i],
            style: const TextStyle(color: Color(0xFFede9fe)),
          ),
        );
      } else {
        final subParts = parts[i].split('</strong>');
        spans.add(
          TextSpan(
            text: subParts[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        if (subParts.length > 1) {
          spans.add(
            TextSpan(
              text: subParts[1],
              style: const TextStyle(color: Color(0xFFede9fe)),
            ),
          );
        }
      }
    }
    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
    );
  }
}

// --- VISUALIZER 3D ---
class Visualizer3D extends StatelessWidget {
  final AppState state;
  const Visualizer3D({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Enforce safe minimum space for the content ensuring NO negative boundaries or infinity errors
        double canvasWidth = math.max(900.0, constraints.maxWidth);
        double canvasHeight = math.max(600.0, constraints.maxHeight);
        double graphHeight =
            canvasHeight * 0.6; // 60% of the allocated canvas height
        double maxBarHeight = math.max(10.0, graphHeight - 65);

        // InteractiveViewer wrapped inside LayoutBuilder enables safe panning without crashing
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(5000),
          minScale: 0.1,
          maxScale: 4.0,
          constrained:
              false, // Disables fixed locking so users can zoom and pan freely
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // "Holographic" Base plane
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(1.2),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0x334f46e5),
                          width: 2,
                        ),
                        gradient: const RadialGradient(
                          colors: [Color(0x334f46e5), Colors.transparent],
                          radius: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),

                // Wrap Graph Base Line and Bars together to lock alignment perfectly
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  height: graphHeight,
                  child: Stack(
                    children: [
                      // 1. Isometric (flat base) Bars
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(5, (index) {
                            final row = dataset[index];

                            // Determine scaling based on the exact available maxBarHeight
                            double targetHeight = 0.0;
                            if (state.step > 1) {
                              // Max frequency is 5
                              targetHeight = (row.f / 5.0) * maxBarHeight;
                            }

                            // Interaction for Median Class
                            bool isMC = index == 2;
                            bool highlight = state.step >= 4 && isMC;
                            double opacity = state.step >= 4 && !isMC
                                ? 0.3
                                : 0.9;

                            return GestureDetector(
                              onTap: () {
                                if (state.step == 4) {
                                  if (isMC) {
                                    state.handleBarClick(index);
                                  } else {
                                    AudioManager.playError();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.t('msg_wrong_bar')),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: targetHeight,
                                ),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves
                                    .easeOutCubic, // Safe curve avoiding negative bounce
                                builder: (context, height, child) {
                                  double safeHeight = math.max(0.0, height);
                                  return IsometricBar(
                                    height: safeHeight,
                                    color: barColors[index],
                                    highlight: highlight,
                                    opacity: opacity,
                                    label: state.step > 1 ? 'f: ${row.f}' : '',
                                    baseLabel: '${row.lower}-${row.upper}',
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ),

                      // 2. 2D Graph Base Line (X-Axis) perfectly aligned with bar bottoms
                      Positioned(
                        bottom:
                            30, // Matches the exact height of the Base Label Area inside IsometricBar
                        left: 20,
                        right: 20,
                        height: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF818cf8).withOpacity(0.8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF4f46e5),
                                blurRadius: 8,
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
          ),
        );
      },
    );
  }
}

class IsometricBar extends StatelessWidget {
  final double height;
  final Color color;
  final bool highlight;
  final double opacity;
  final String label;
  final String baseLabel;

  const IsometricBar({
    super.key,
    required this.height,
    required this.color,
    this.highlight = false,
    this.opacity = 0.9,
    required this.label,
    required this.baseLabel,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = highlight ? Colors.white : color;
    final shadowColor = color.withOpacity(highlight ? 0.8 : 0.4);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Top Label
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(opacity),
            fontSize: 10,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Bar representation
        Container(
          width: 40,
          height: math.max(0.0, height) + 5, // guaranteed minimum height
          decoration: BoxDecoration(
            color: barColor.withOpacity(opacity),
            border: Border.all(
              color: barColor.withOpacity(math.min(1.0, opacity + 0.2)),
              width: 1.5,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 15,
                offset: const Offset(0, -2),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                barColor.withOpacity(opacity),
                barColor.withOpacity(opacity * 0.5),
              ],
            ),
          ),
        ),

        const SizedBox(height: 2),

        // Base Label Area
        SizedBox(
          height: 30,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x336366f1).withOpacity(opacity * 0.3),
                border: Border.all(
                  color: const Color(0x806366f1).withOpacity(opacity * 0.5),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                baseLabel,
                style: TextStyle(
                  color: const Color(0xFFc7d2fe).withOpacity(opacity),
                  fontSize: 9,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- OVERLAYS & COMPONENTS ---
class FormulaBuilder extends StatelessWidget {
  final AppState state;
  const FormulaBuilder({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x806366f1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Median = ',
                  style: TextStyle(
                    color: Color(0xFF818cf8),
                    fontSize: 20,
                    fontFamily: 'monospace',
                  ),
                ),
                _slot('l', 'l', state),
                const Text(
                  ' + ( ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),

                Column(
                  children: [
                    Row(
                      children: [
                        _slot('n2', 'N/2', state),
                        const Text(
                          ' - ',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        _slot('cf', 'cf', state),
                      ],
                    ),
                    Container(
                      width: 100,
                      height: 2,
                      color: Colors.white30,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    _slot('f', 'f', state, small: true),
                  ],
                ),

                const Text(
                  ' ) × ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                _slot('h', 'h', state),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _bankBtn('l = 20', 'l', Colors.amber, state),
              _bankBtn('h = 10', 'h', Colors.cyan, state),
              _bankBtn('N/2 = 9', 'n2', Colors.purple, state),
              _bankBtn('cf = 8', 'cf', Colors.blue, state),
              _bankBtn('f = 4', 'f', Colors.green, state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slot(
    String key,
    String expect,
    AppState state, {
    bool small = false,
  }) {
    bool filled = state.filledSlots[key]!;
    String val = '';
    if (filled) {
      if (key == 'l') val = '20';
      if (key == 'h') val = '10';
      if (key == 'n2') val = '9';
      if (key == 'cf') val = '8';
      if (key == 'f') val = '4';
    }

    return GestureDetector(
      onTap: () {
        if (!filled) state.fillSlot(key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: small ? 36 : 46,
        height: small ? 28 : 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0x338b5cf6) : const Color(0x800f172a),
          border: Border.all(
            color: filled ? const Color(0xFF8b5cf6) : const Color(0xFF475569),
            style: filled ? BorderStyle.solid : BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          filled ? val : expect,
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFF94a3b8),
            fontWeight: FontWeight.bold,
            fontSize: small ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _bankBtn(
    String label,
    String key,
    MaterialColor color,
    AppState state,
  ) {
    bool used = state.filledSlots[key]!;
    return InkWell(
      onTap: used ? null : () => state.fillSlot(key),
      child: Opacity(
        opacity: used ? 0.3 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.shade900.withOpacity(0.4),
            border: Border.all(color: color.shade500.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color.shade200,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}

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
                    horizontal: 40,
                    vertical: 20,
                  ),
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
                      const Text('🏆', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 8),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFa78bfa),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.t('cel_msg'),
                        style: const TextStyle(
                          color: Color(0xFFcbd5e1),
                          fontSize: 18,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x8010b981)),
                        ),
                        child: const Text(
                          '22.5',
                          style: TextStyle(
                            color: Color(0xFF6ee7b7),
                            fontSize: 48,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                          backgroundColor: const Color(0xFF7c3aed),
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
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          Column(
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
                  Icons.stacked_line_chart,
                  size: 64,
                  color: Color(0xFFa78bfa),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.t('app_title'),
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
              const SizedBox(height: 18),
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
                  backgroundColor: const Color(0xFF7c3aed),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 38,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 20,
                  shadowColor: const Color(0xFF7c3aed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Background Grid effect
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.3)
      ..strokeWidth = 1;

    for (double i = -5000; i < 5000; i += 40) {
      canvas.drawLine(Offset(i, -5000), Offset(i, 5000), paint);
      canvas.drawLine(Offset(-5000, i), Offset(5000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
