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
  final int? f; // null denotes the missing frequency 'f'

  DataRowModel(this.lower, this.upper, this.f);

  int get xi => (lower + upper) ~/ 2;
  String get fStr => f == null ? 'f' : f.toString();
  String get fixiStr => f == null ? '${xi}f' : (f! * xi).toString();
}

final List<DataRowModel> dataset = [
  DataRowModel(11, 13, 7),
  DataRowModel(13, 15, 6),
  DataRowModel(15, 17, 9),
  DataRowModel(17, 19, 13),
  DataRowModel(19, 21, null), // Missing frequency (Actual = 20)
  DataRowModel(21, 23, 5),
  DataRowModel(23, 25, 4),
];

const double targetMean = 18.0;

final List<Color> barColors = [
  const Color(0xFF3b82f6),
  const Color(0xFF06b6d4),
  const Color(0xFF10b981),
  const Color(0xFFeab308),
  const Color(0xFFf59e0b), // Amber (For missing f)
  const Color(0xFFf97316),
  const Color(0xFFef4444),
];

// --- I18N DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'MISSING FREQUENCY',
    'tagline': 'ALGEBRAIC DETECTIVE',
    'init_btn': 'INITIALIZE SCANNER',
    'header_title': 'The Missing Frequency',
    'header_subtitle': 'CLASS 10 • STATISTICS',
    'phase_label': 'RECONSTRUCTION PHASE',
    'step_label': 'Stage',
    'mission_log': 'Console Log',
    'active_mission': 'Current Objective',
    'th_class': 'Allowance (₹)',
    'th_fi': 'Children (fi)',
    'th_xi': 'Midpoint (xi)',
    'th_fixi': 'Product (fi.xi)',
    'row_total': 'Total',
    'cel_title': 'MYSTERY SOLVED!',
    'cel_msg': 'Missing Frequency Discovered: f = 20',
    'btn_restart': 'Restart Simulation',
    's1_t': 'Step 1: The Data Anomaly',
    's1_i':
        'Data scanned. We already know the Mean is exactly 18, but one frequency is missing (\'f\').',
    's1_b': 'Analyze Data',
    's2_t': 'Step 2: Class Marks (xi)',
    's2_i':
        'Find the midpoint (xi) for each allowance range. (e.g., 11-13 has a midpoint of 12).',
    's2_b': 'Extract Midpoints',
    's3_t': 'Step 3: Locate Missing "f"',
    's3_i':
        'Notice the 19-21 range. Its frequency is missing, denoted as "f". Tap the missing frequency bar in the 2D view.',
    's4_t': 'Step 4: Calculate Products (fi × xi)',
    's4_i':
        'Multiply frequency (fi) by class mark (xi) for each row. The unknown row becomes <strong>20f</strong>.',
    's4_b': 'Multiply Columns',
    's5_t': 'Step 5: Compute Sums',
    's5_i':
        'Find the total frequency Σfi (44 + f) and the total sum of products Σfixi (752 + 20f).',
    's5_b': 'Auto-Sum Columns',
    's6_t': 'Step 6: Formula Assembly',
    's6_i':
        'Open the Data panel and tap variables from the bank to construct the Mean formula: x̄ = Σfixi / Σfi',
    's6_b': 'ASSEMBLE FORMULA',
    's7_t': 'Step 7: Cross Multiply',
    's7_i': 'Multiply both sides by the denominator (44 + f).',
    's7_b': 'Cross Multiply',
    's8_t': 'Step 8: Isolate Variables',
    's8_i': 'Move all \'f\' terms to one side, and numbers to the other.',
    's8_b': 'Isolate \'f\'',
    's9_t': 'Step 9: Solve for \'f\'',
    's9_i': 'Divide to find the final value of the missing frequency.',
    's9_b': 'Solve Equation',
    's10_t': 'Step 10: Reconstruct Data',
    's10_i': 'The missing value is 20. Materializing the missing bar...',
    's10_b': 'Materialize Bar',
    'msg_click_bar': 'Tap the bar for class 19-21',
    'msg_wrong_bar': 'Look for the class with the missing frequency "f".',
    'msg_populate': 'Populate formula below',
    'status_locked': 'Locked',
    'status_calc': 'Calculate',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Frequency Distribution',
    'math_engine_title': '2. Algebraic Solver',
    'objective_desc':
        'Utilize the known Mean to algebraically reverse-engineer the missing frequency from the grouped dataset.',
  },
  'hi': {
    'app_title': 'अज्ञात बारंबारता',
    'tagline': 'बीजगणितीय जासूस',
    'init_btn': 'स्कैनर शुरू करें',
    'header_title': 'अज्ञात बारंबारता',
    'header_subtitle': 'कक्षा 10 • सांख्यिकी',
    'phase_label': 'पुनर्निर्माण चरण',
    'step_label': 'चरण',
    'mission_log': 'कंसोल लॉग',
    'active_mission': 'वर्तमान उद्देश्य',
    'th_class': 'भत्ता (₹)',
    'th_fi': 'बच्चे (fi)',
    'th_xi': 'मध्यबिंदु (xi)',
    'th_fixi': 'गुणनफल (fi.xi)',
    'row_total': 'कुल',
    'cel_title': 'रहस्य सुलझ गया!',
    'cel_msg': 'अज्ञात बारंबारता का पता चल गया: f = 20',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: विसंगति पहचानें',
    's1_i':
        'डेटा स्कैन किया गया। माध्य 18 है, लेकिन एक बारंबारता (\'f\') अज्ञात है।',
    's1_b': 'डेटा का विश्लेषण करें',
    's2_t': 'चरण 2: वर्ग चिह्न (xi)',
    's2_i': 'प्रत्येक वर्ग अंतराल के लिए मध्यबिंदु की गणना करें।',
    's2_b': 'मध्यबिंदु निकालें',
    's3_t': 'चरण 3: अज्ञात "f" खोजें',
    's3_i':
        'ध्यान दें कि 19-21 वर्ग की बारंबारता अज्ञात "f" है। दृश्य में अज्ञात बार पर टैप करें।',
    's4_t': 'चरण 4: गुणनफल (fi × xi)',
    's4_i':
        'बारंबारता और मध्यबिंदु को गुणा करें। बीजगणितीय पद <strong>20f</strong> पर ध्यान दें।',
    's4_b': 'गुणनफल की गणना करें',
    's5_t': 'चरण 5: योग (Σfi, Σfixi)',
    's5_i':
        'कुल बारंबारता (44 + f) और उत्पादों का कुल योग (752 + 20f) ज्ञात करें।',
    's5_b': 'योग करें',
    's6_t': 'चरण 6: समीकरण सेटअप',
    's6_i': 'माध्य सूत्र लागू करें: माध्य = Σfixi / Σfi',
    's6_b': 'समीकरण सेट करें',
    's7_t': 'चरण 7: तिर्यक गुणा',
    's7_i': 'दोनों पक्षों को हर (44 + f) से गुणा करें।',
    's7_b': 'गुणा करें',
    's8_t': 'चरण 8: चर को अलग करें',
    's8_i': 'सभी \'f\' पदों को एक तरफ ले जाएं, और संख्याओं को दूसरी तरफ।',
    's8_b': '\'f\' को अलग करें',
    's9_t': 'चरण 9: \'f\' हल करें',
    's9_i': 'अज्ञात बारंबारता का अंतिम मान ज्ञात करने के लिए भाग दें।',
    's9_b': 'समीकरण हल करें',
    's10_t': 'चरण 10: डेटा पुनर्निर्माण',
    's10_i': 'अज्ञात मान 20 है। अज्ञात बार को साकार किया जा रहा है...',
    's10_b': 'बार साकार करें',
    'msg_click_bar': 'वर्ग 19-21 के बार पर टैप करें',
    'msg_wrong_bar': 'वह बार चुनें जिसकी बारंबारता "f" है।',
    'msg_populate': 'नीचे सूत्र भरें',
    'status_locked': 'लॉक्ड',
    'status_calc': 'गणना करें',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. बारंबारता वितरण',
    'math_engine_title': '2. बीजगणितीय सॉल्वर',
    'objective_desc':
        'समूहीकृत डेटासेट से अज्ञात आवृत्ति को बीजगणितीय रूप से खोजने के लिए ज्ञात माध्य का उपयोग करें।',
  },
};

// --- STATE MANAGEMENT ---
class AppState extends ChangeNotifier {
  bool isInitialized = false;
  String lang = 'en';

  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  int step = 1;
  int calcStage = 0;

  Map<String, bool> filledSlots = {
    'mean': false,
    'sumFixi': false,
    'sumFi': false,
  };

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
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
    if (step < 11) {
      step++;
      if (step == 11) {
        AudioManager.playSuccess();
      } else {
        AudioManager.playClick();
      }
      notifyListeners();
    }
  }

  void handleBarClick(int id) {
    if (step == 3) {
      if (id == 4) {
        // The 'f' class is index 4 (19-21)
        nextStep();
      } else {
        AudioManager.playError();
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

  void resetLab() {
    step = 1;
    calcStage = 0;
    filledSlots = {'mean': false, 'sumFixi': false, 'sumFi': false};
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

class MissingFrequencyApp extends StatefulWidget {
  const MissingFrequencyApp({super.key});

  @override
  State<MissingFrequencyApp> createState() => _MissingFrequencyAppState();
}

class _MissingFrequencyAppState extends State<MissingFrequencyApp> {
  final AppState state = AppState();
  final List<GlobalKey> stepKeys = List.generate(10, (index) => GlobalKey());
  int _previousStep = 1;

  @override
  void initState() {
    super.initState();
    state.addListener(() {
      if (!mounted) return;
      if (state.step != _previousStep) {
        _previousStep = state.step;
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
    if (step < 1 || step > 10) return;
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
              child: Visualizer2D(state: state),
            ),

            // 2. FLOATING MISSION CARD (Visible when left panel is closed)
            if (state.isInitialized &&
                !state.isLeftPanelOpen &&
                state.step < 11)
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
                  color: const Color(0xFFf59e0b),
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
                  color: const Color(0xFFfbbf24),
                  tooltip: 'Data / Calculations',
                ),
              ),
            ],

            // CELEBRATION (Step 11)
            if (state.step == 11 && state.isInitialized)
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
                            colors: [Color(0xFFf59e0b), Color(0xFFea580c)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4Df59e0b), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.search, color: Colors.white),
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
                                color: Color(0xFFfcd34d),
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
                                      ? const Color(0xFFf59e0b)
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
                        "${state.t('step_label')} ${math.min(state.step, 10)}/10",
                        style: const TextStyle(
                          color: Color(0xFFf59e0b),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: math.min(state.step, 10) / 10,
                    backgroundColor: Colors.black38,
                    color: const Color(0xFFf59e0b),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFf59e0b),
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
                    itemCount: 10,
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
                              ? const Color(0xFFf59e0b).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFf59e0b)
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
                                            ? const Color(0xFFf59e0b)
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
                const Icon(Icons.data_usage, color: Color(0xFFfbbf24)),
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
                      color: Color(0xFFfcd34d),
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
                                state.t('th_class'),
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
                                  state.t('th_xi'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF38bdf8),
                                  ),
                                ),
                              ),
                            if (state.step >= 4)
                              DataColumn(
                                label: Text(
                                  state.t('th_fixi'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF34d399),
                                  ),
                                ),
                              ),
                          ],
                          rows: [
                            ...dataset.map((row) {
                              int idx = dataset.indexOf(row);
                              bool isMissing = idx == 4;

                              Color? rowColor;
                              Color varColor = Colors.transparent;

                              if (isMissing && state.step >= 3) {
                                rowColor = const Color(0x4D78350f); // Amber 900
                                varColor = const Color(0xFFfcd34d);
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
                                      (state.step >= 10 && isMissing)
                                          ? '20'
                                          : row.fStr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: (isMissing && state.step >= 3)
                                            ? varColor
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (state.step >= 2)
                                    DataCell(
                                      Text(
                                        '${row.xi}',
                                        style: const TextStyle(
                                          color: Color(0xFF38bdf8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  if (state.step >= 4)
                                    DataCell(
                                      Text(
                                        (state.step >= 10 && isMissing)
                                            ? '400'
                                            : row.fixiStr,
                                        style: TextStyle(
                                          color: (isMissing)
                                              ? varColor
                                              : const Color(0xFF34d399),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                            // Footer Row
                            if (state.step >= 5)
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
                                  DataCell(
                                    Text(
                                      state.step >= 10 ? '64' : '44 + f',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (state.step >= 2)
                                    const DataCell(Text('-')),
                                  if (state.step >= 4)
                                    DataCell(
                                      Text(
                                        state.step >= 10 ? '1152' : '752 + 20f',
                                        style: const TextStyle(
                                          color: Color(0xFF34d399),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // MATH ENGINE (Steps 6-9)
                  if (state.step >= 6) ...[
                    Text(
                      state.t('math_engine_title'),
                      style: const TextStyle(
                        color: Color(0xFFf59e0b),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (state.step == 6)
                      FormulaBuilder(state: state)
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0x330f172a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x80f59e0b)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _mathRow(
                              'Mean =',
                              'Σfixi / Σfi',
                              const Color(0xFF94a3b8),
                            ),
                            _mathRow(
                              '18 =',
                              '(752 + 20f) / (44 + f)',
                              Colors.white,
                            ),

                            if (state.step >= 7) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Icon(
                                  Icons.swap_vert,
                                  color: Color(0xFF475569),
                                  size: 16,
                                ),
                              ),
                              _mathRow(
                                '18(44 + f) =',
                                '752 + 20f',
                                const Color(0xFF38bdf8),
                              ),
                              _mathRow(
                                '792 + 18f =',
                                '752 + 20f',
                                const Color(0xFF38bdf8),
                              ),
                            ],

                            if (state.step >= 8) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: Color(0xFF475569),
                                  size: 16,
                                ),
                              ),
                              _mathRow(
                                '792 - 752 =',
                                '20f - 18f',
                                const Color(0xFFa78bfa),
                              ),
                              _mathRow('40 =', '2f', const Color(0xFFa78bfa)),
                            ],

                            if (state.step >= 9) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: Color(0xFF475569),
                                  size: 16,
                                ),
                              ),
                              _mathRow(
                                'f =',
                                '20',
                                const Color(0xFF10b981),
                                large: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mathRow(String lhs, String rhs, Color color, {bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lhs,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: large ? 24 : 16,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            rhs,
            style: TextStyle(
              color: color,
              fontSize: large ? 24 : 16,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- LAB CONTROLS WIDGET ---
class LabControls extends StatelessWidget {
  final AppState state;
  const LabControls({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.step == 3) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x33b45309),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x4Db45309)),
        ),
        child: Center(
          child: Text(
            state.t('msg_click_bar'),
            style: const TextStyle(
              color: Color(0xFFfbbf24),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (state.step >= 6 && state.step <= 9) {
      if (state.step == 6) {
        return const SizedBox(); // Formula builder handles interaction here
      }
      return buildPrimaryBtn(
        state.t('s${state.step}_b'),
        const Color(0xFFf59e0b),
        () {
          state.nextStep();
          if (!state.isRightPanelOpen) state.toggleRightPanel();
        },
      );
    } else if (state.step == 10) {
      return buildPrimaryBtn(
        state.t('s10_b'),
        const Color(0xFFf59e0b),
        state.nextStep,
      );
    } else {
      return buildPrimaryBtn(
        state.t('s${state.step}_b'),
        const Color(0xFFf59e0b),
        state.nextStep,
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
          foregroundColor: Colors.black, // Dark text on amber
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
        border: Border.all(color: const Color(0xFFf59e0b), width: 1.5),
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
                    color: Color(0xFFf59e0b),
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
                  '${state.step}/10',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFFfcd34d),
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
              color: Color(0xFFfbbf24),
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

// --- FORMULA BUILDER ---
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
        border: Border.all(color: const Color(0x80f59e0b)),
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
                _slot('mean', 'Mean', state),
                const Text(
                  ' = ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),

                Column(
                  children: [
                    _slot('sumFixi', 'Σfixi', state, wide: true),
                    Container(
                      width: 140,
                      height: 2,
                      color: Colors.white30,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    _slot('sumFi', 'Σfi', state, wide: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _bankBtn('Mean = 18', 'mean', Colors.amber, state),
              _bankBtn('Σfixi = 752+20f', 'sumFixi', Colors.cyan, state),
              _bankBtn('Σfi = 44+f', 'sumFi', Colors.purple, state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slot(String key, String expect, AppState state, {bool wide = false}) {
    bool filled = state.filledSlots[key]!;
    String val = '';
    if (filled) {
      if (key == 'mean') val = '18';
      if (key == 'sumFixi') val = '752 + 20f';
      if (key == 'sumFi') val = '44 + f';
    }

    return GestureDetector(
      onTap: () {
        if (!filled) state.fillSlot(key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: wide ? 100 : 46,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0x33f59e0b) : const Color(0x800f172a),
          border: Border.all(
            color: filled ? const Color(0xFFf59e0b) : const Color(0xFF475569),
            style: filled ? BorderStyle.solid : BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          filled ? val : expect,
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFF94a3b8),
            fontWeight: FontWeight.bold,
            fontSize: 14,
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

// --- VISUALIZER 2D ---
class Visualizer2D extends StatelessWidget {
  final AppState state;
  const Visualizer2D({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Enforce safe layout boundaries ensuring no negative height
        double availableHeight = math.max(10.0, constraints.maxHeight);
        // Increased margin to 120 to provide enough space for labels and padding, fixing the 19-21 bar overflow
        double barMaxArea = math.max(10.0, availableHeight - 120);
        double canvasWidth = math.max(900.0, constraints.maxWidth);

        // Safe InteractiveViewer for panning without layout crashes
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(5000),
          minScale: 0.1,
          maxScale: 4.0,
          constrained: false, // Ensures natural pan behavior
          child: SizedBox(
            width: canvasWidth,
            height: availableHeight,
            child: Stack(
              children: [
                // Container structure inside
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (index) {
                            final row = dataset[index];
                            bool isMissing = row.f == null;

                            // Scale Height Calculations
                            double maxF = 20.0;
                            double actualF = isMissing
                                ? 20.0
                                : row.f!.toDouble();

                            double heightFactor = actualF / maxF;
                            double targetHeight = barMaxArea * heightFactor;
                            targetHeight = math.max(0.0, targetHeight);

                            bool isSolved = state.step == 10;
                            double currentHeight = targetHeight;

                            if (state.step == 1) {
                              currentHeight = 0.0;
                            } else if (isMissing && !isSolved) {
                              // Small wireframe height while unsolved
                              currentHeight = math.max(10.0, barMaxArea * 0.15);
                            }

                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: currentHeight,
                              ),
                              duration: const Duration(milliseconds: 1000),
                              curve: isSolved
                                  ? Curves.elasticOut
                                  : Curves
                                        .easeOutCubic, // Use safe curve to avoid negative overshoot
                              builder: (context, height, child) {
                                double safeHeight = math.max(0.0, height);
                                return Bar2D(
                                  index: index,
                                  height: safeHeight,
                                  color: barColors[index],
                                  isMissing: isMissing,
                                  isSolved: isSolved,
                                  label: state.step == 1
                                      ? ''
                                      : (isMissing && !isSolved
                                            ? 'f = ?'
                                            : 'f: ${actualF.toInt()}'),
                                  baseLabel: '${row.lower}-${row.upper}',
                                  state: state,
                                );
                              },
                            );
                          }),
                        ),
                      ),
                      // X-Axis Base Line
                      Container(
                        height: 2,
                        width: double.infinity,
                        color: const Color(0xFF475569),
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

class Bar2D extends StatelessWidget {
  final int index;
  final double height;
  final Color color;
  final bool isMissing;
  final bool isSolved;
  final String label;
  final String baseLabel;
  final AppState state;

  const Bar2D({
    super.key,
    required this.index,
    required this.height,
    required this.color,
    required this.isMissing,
    required this.isSolved,
    required this.label,
    required this.baseLabel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    bool wireframe = isMissing && !isSolved && state.step > 1;
    final barColor = wireframe ? Colors.transparent : color;
    final borderColor = wireframe ? const Color(0xFFfbbf24) : color;
    bool isPulsing = isMissing && state.step == 3;

    return GestureDetector(
      onTap: () {
        if (state.step == 3) {
          if (isMissing) {
            state.handleBarClick(index);
          } else {
            AudioManager.playError();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.t('msg_wrong_bar'))));
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: wireframe ? const Color(0xFFfbbf24) : Colors.white,
              fontSize: wireframe ? 14 : 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 2D Bar representation
          Container(
            width: 45,
            height: math.max(0.0, height),
            decoration: BoxDecoration(
              color: wireframe
                  ? const Color(0x1Af59e0b)
                  : barColor.withOpacity(0.9),
              border: Border.all(
                color: state.step == 1 ? Colors.transparent : borderColor,
                width: wireframe ? 2.0 : 0.0,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              boxShadow: wireframe || state.step == 1
                  ? null
                  : [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
              gradient: wireframe || state.step == 1
                  ? null
                  : LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [barColor.withOpacity(0.6), barColor],
                    ),
            ),
            child: wireframe
                ? Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: isPulsing
                            ? Colors.white
                            : const Color(0xFFf59e0b),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 8),
          // Base Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x330f172a),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              baseLabel,
              style: const TextStyle(
                color: Color(0xFFcbd5e1),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
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
                    border: Border.all(color: const Color(0x8010b981)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x6610b981), blurRadius: 60),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔓', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10b981),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x80f59e0b)),
                        ),
                        child: const Text(
                          'f = 20',
                          style: TextStyle(
                            color: Color(0xFFfbbf24),
                            fontSize: 48,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
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
                          backgroundColor: const Color(0xFFf59e0b),
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
          CustomPaint(painter: GridPainter(), size: Size.infinite),
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
                    BoxShadow(color: Color(0x4Df59e0b), blurRadius: 40),
                  ],
                ),
                child: const Icon(
                  Icons.query_stats,
                  size: 64,
                  color: Color(0xFFfbbf24),
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
                textAlign: TextAlign.center,
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
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onInit,
                icon: const Icon(Icons.play_arrow, color: Colors.black),
                label: Text(
                  state.t('init_btn'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf59e0b),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 20,
                  shadowColor: const Color(0xFFf59e0b),
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

    for (double i = -10000; i < 10000; i += 40) {
      canvas.drawLine(Offset(i, -10000), Offset(i, 10000), paint);
      canvas.drawLine(Offset(-10000, i), Offset(10000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
