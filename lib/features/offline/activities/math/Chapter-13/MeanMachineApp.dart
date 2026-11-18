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

  DataRowModel(this.lower, this.upper, this.f);

  int get xi => (lower + upper) ~/ 2;
  int get di => xi - 3500;
  double get ui => di / 1000;
  double get fiui => f * ui;
}

final List<DataRowModel> dataset = [
  DataRowModel(1000, 2000, 15),
  DataRowModel(2000, 3000, 110),
  DataRowModel(3000, 4000, 135), // Midpoint 3500
  DataRowModel(4000, 5000, 115),
  DataRowModel(5000, 6000, 25),
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
    'app_title': 'THE MEAN MACHINE',
    'tagline': 'STEP-DEVIATION METHOD',
    'init_btn': 'INITIALIZE SYSTEM',
    'header_title': 'The Mean Machine',
    'header_subtitle': 'CLASS 10 • STATISTICS',
    'phase_label': 'DATA PIPELINE',
    'step_label': 'Stage',
    'active_mission': 'Current Objective',
    'th_income': 'Income (₹)',
    'th_fi': 'Families (fi)',
    'row_total': 'Total',
    'cel_title': 'SUCCESS!',
    'cel_msg': 'Average Monthly Income Calculated',
    'btn_restart': 'Restart Simulation',
    's1_t': 'Step 1: Ingest Data',
    's1_i':
        'Load grouped frequency distribution (Census Data) from the server.',
    's1_b': 'Load Server Data',
    's2_t': 'Step 2: Class Marks (xi)',
    's2_i': 'Convert ranges (1000-2000) into single representative midpoints.',
    's2_b': 'Activate Midpoint Scanner',
    's3_t': 'Step 3: Assumed Mean (a)',
    's3_i':
        'Select a central value from the \'xi\' column to be our temporary zero.',
    's4_t': 'Step 4: Calculate Deviation (di)',
    's4_i': 'Find distance from Assumed Mean: di = xi - 3500',
    's4_b': 'Calculate Deviations',
    's5_t': 'Step 5: Identify Class Size (h)',
    's5_i': 'Analyze column \'di\'. What is the greatest common factor?',
    's5_b': 'CHECK',
    's6_t': 'Step 6: Step-Deviation (ui)',
    's6_i': 'Shrink the large deviations! Formula: ui = di / 1000',
    's6_b': 'Activate Shrink Ray',
    's7_t': 'Step 7: Calculate Product (fi.ui)',
    's7_i': 'Multiply Frequency (fi) by Step-Deviation (ui).',
    's7_b': 'Calculate Products',
    's8_t': 'Step 8: Compute Sum (Σfi.ui)',
    's8_i': 'Find the net total of the scaled products.',
    's8_b': 'Auto-Sum Column',
    's9_t': 'Step 9: Assemble Formula',
    's9_i': 'Open the Data Panel and tap variables to fill the formula slots.',
    's10_t': 'Step 10: Final Computation',
    's10_i': 'Execute the calculation to find the exact Mean Income.',
    's10_b': 'Compute Final Mean',
    'msg_click_row': 'Tap the central bar (3500) in the 3D view',
    'msg_wrong_a': 'Pick the central value (3500) for easiest calculation.',
    'msg_wrong_h':
        'Look at the deviations: -2000, -1000, 0... What number divides them all?',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Frequency Distribution',
    'formula_title': '2. Formula Assembly',
    'formula_desc': 'Use the Data Panel to assemble the final formula.',
    'objective_desc':
        'Calculate the Mean Income using the Step-Deviation method by scaling large numbers into a manageable formula.',
  },
  'hi': {
    'app_title': 'माध्य मशीन',
    'tagline': 'पग-विचलन विधि',
    'init_btn': 'सिस्टम शुरू करें',
    'header_title': 'माध्य मशीन',
    'header_subtitle': 'कक्षा 10 • सांख्यिकी',
    'phase_label': 'डेटा पाइपलाइन',
    'step_label': 'चरण',
    'active_mission': 'वर्तमान उद्देश्य',
    'th_income': 'आय (₹)',
    'th_fi': 'परिवार (fi)',
    'row_total': 'कुल',
    'cel_title': 'सफल!',
    'cel_msg': 'औसत मासिक आय की गणना पूर्ण',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: डेटा लोड करें',
    's1_i': 'सर्वर से समूहीकृत बारंबारता वितरण लोड करें।',
    's1_b': 'डेटा लोड करें',
    's2_t': 'चरण 2: वर्ग चिह्न (xi)',
    's2_i': 'रेंज (1000-2000) को एकल प्रतिनिधि मध्यबिंदुओं में बदलें।',
    's2_b': 'मध्यबिंदु स्कैनर सक्रिय करें',
    's3_t': 'चरण 3: कल्पित माध्य (a)',
    's3_i':
        '\'xi\' कॉलम से एक केंद्रीय मान चुनें जिसे हम अस्थायी शून्य मानेंगे।',
    's4_t': 'चरण 4: विचलन की गणना (di)',
    's4_i': 'कल्पित माध्य से दूरी ज्ञात करें: di = xi - 3500',
    's4_b': 'विचलन की गणना करें',
    's5_t': 'चरण 5: वर्ग आकार (h)',
    's5_i': '\'di\' कॉलम का विश्लेषण करें। सबसे बड़ा सामान्य कारक क्या है।',
    's5_b': 'जाँच करें',
    's6_t': 'चरण 6: पग-विचलन (ui)',
    's6_i': 'बड़ी संख्याओं को छोटा करें! सूत्र: ui = di / 1000',
    's6_b': 'श्रिंक रे सक्रिय करें',
    's7_t': 'चरण 7: गुणनफल (fi.ui)',
    's7_i': 'बारंबारता (fi) को पग-विचलन (ui) से गुणा करें।',
    's7_b': 'गुणनफल की गणना करें',
    's8_t': 'चरण 8: योग (Σfi.ui)',
    's8_i': 'स्केल किए गए उत्पादों का शुद्ध योग ज्ञात करें।',
    's8_b': 'ऑटो-सम कॉलम',
    's9_t': 'चरण 9: सूत्र संयोजन',
    's9_i': 'डेटा पैनल खोलें और सूत्र स्लॉट भरने के लिए चर पर टैप करें।',
    's10_t': 'चरण 10: अंतिम गणना',
    's10_i': 'सटीक औसत आय ज्ञात करने के लिए गणना करें।',
    's10_b': 'अंतिम माध्य निकालें',
    'msg_click_row': '3D दृश्य में केंद्रीय बार (3500) पर टैप करें',
    'msg_wrong_a': 'सबसे आसान गणना के लिए केंद्रीय मान (3500) चुनें।',
    'msg_wrong_h':
        'विचलन देखें: -2000, -1000, 0... कौन सी संख्या उन सभी को विभाजित करती है?',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. बारंबारता वितरण',
    'formula_title': '2. सूत्र संयोजन',
    'formula_desc':
        'अंतिम सूत्र को इकट्ठा करने के लिए डेटा पैनल का उपयोग करें।',
    'objective_desc':
        'बड़ी संख्याओं को एक प्रबंधनीय सूत्र में स्केल करके पग-विचलन विधि का उपयोग करके औसत आय की गणना करें।',
  },
};

class AppState extends ChangeNotifier {
  bool isInitialized = false;
  String lang = 'en';

  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  int step = 1;
  int a = 3500;
  int h = 1000;
  int sumFi = 400;
  double sumFiUi = 25;

  Map<String, bool> filledSlots = {
    'a': false,
    'h': false,
    'fiui': false,
    'fi': false,
  };

  // Flag to detect and prevent updates on an unmounted state
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

  void fillSlot(String type) {
    if (!filledSlots[type]!) {
      filledSlots[type] = true;
      AudioManager.playClick();
      notifyListeners();

      if (filledSlots.values.every((element) => element)) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!_isDisposed) {
            nextStep(); // Progress to step 10
          }
        });
      }
    }
  }

  void resetLab() {
    step = 1;
    filledSlots = {'a': false, 'h': false, 'fiui': false, 'fi': false};
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

class MeanMachineApp extends StatefulWidget {
  const MeanMachineApp({super.key});

  @override
  State<MeanMachineApp> createState() => _MeanMachineAppState();
}

class _MeanMachineAppState extends State<MeanMachineApp> {
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

            // 1. CANVAS AREA (Dynamically Centers & remains fully movable and zoomable)
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
                  color: const Color(0xFF4f46e5),
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
                  color: const Color(0xFF22c55e),
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
                            colors: [Color(0xFF4f46e5), Color(0xFF1d4ed8)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4D4f46e5), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.bar_chart, color: Colors.white),
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
                                color: Color(0xFF818cf8),
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
                                      ? const Color(0xFF4f46e5)
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
                        "${state.t('step_label')} ${math.min(state.step, 10)}/10",
                        style: const TextStyle(
                          color: Color(0xFF4f46e5),
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
                    color: const Color(0xFF4f46e5),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF4f46e5),
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
                              ? const Color(0xFF4f46e5).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF4f46e5)
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
                                            ? const Color(0xFF4f46e5)
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
                                  color: Color(0xFFe0e7ff),
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
                const Icon(Icons.data_usage, color: Color(0xFF22c55e)),
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
                      color: Color(0xFF60a5fa),
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
                                state.t('th_income'),
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
                              const DataColumn(
                                label: Text(
                                  'xi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF818cf8),
                                  ),
                                ),
                              ),
                            if (state.step >= 4)
                              const DataColumn(
                                label: Text(
                                  'di',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF60a5fa),
                                  ),
                                ),
                              ),
                            if (state.step >= 6)
                              const DataColumn(
                                label: Text(
                                  'ui',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFc084fc),
                                  ),
                                ),
                              ),
                            if (state.step >= 7)
                              const DataColumn(
                                label: Text(
                                  'fi.ui',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF34d399),
                                  ),
                                ),
                              ),
                          ],
                          rows: [
                            ...dataset.map((row) {
                              bool isA =
                                  state.step >= 3 && dataset.indexOf(row) == 2;
                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (states) =>
                                      isA ? const Color(0x4D4f46e5) : null,
                                ),
                                cells: [
                                  DataCell(
                                    Text(
                                      '${row.lower}-${row.upper}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${row.f}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (state.step >= 2)
                                    DataCell(
                                      Text(
                                        '${row.xi}',
                                        style: const TextStyle(
                                          color: Color(0xFF818cf8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  if (state.step >= 4)
                                    DataCell(
                                      Text(
                                        '${row.di}',
                                        style: const TextStyle(
                                          color: Color(0xFF60a5fa),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  if (state.step >= 6)
                                    DataCell(
                                      Text(
                                        '${row.ui.toInt()}',
                                        style: const TextStyle(
                                          color: Color(0xFFc084fc),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  if (state.step >= 7)
                                    DataCell(
                                      Text(
                                        '${row.fiui.toInt()}',
                                        style: const TextStyle(
                                          color: Color(0xFF34d399),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                            if (state.step >= 8)
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      state.t('row_total'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF94a3b8),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${state.sumFi}',
                                      style: const TextStyle(
                                        color: Color(0xFF818cf8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (state.step >= 2)
                                    const DataCell(
                                      Text(
                                        '-',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  if (state.step >= 4)
                                    const DataCell(
                                      Text(
                                        '-',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  if (state.step >= 6)
                                    const DataCell(
                                      Text(
                                        '-',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  if (state.step >= 7)
                                    DataCell(
                                      Text(
                                        '${state.sumFiUi.toInt()}',
                                        style: const TextStyle(
                                          color: Color(0xFF34d399),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
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

                  // FORMULA BUILDER (Step 9/10)
                  if (state.step >= 9) ...[
                    Text(
                      state.t('formula_title'),
                      style: const TextStyle(
                        color: Color(0xFFc084fc),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.t('formula_desc'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    FormulaBuilder(state: state),
                  ],
                ],
              ),
            ),
          ),
        ],
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
  late TextEditingController _hController;

  @override
  void initState() {
    super.initState();
    _hController = TextEditingController();
  }

  @override
  void dispose() {
    _hController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

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
            state.t('msg_click_row'),
            style: const TextStyle(
              color: Color(0xFFfbbf24),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (state.step == 5) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _hController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'GCF?',
                hintStyle: const TextStyle(color: Color(0xFF64748b)),
                filled: true,
                fillColor: const Color(0xFF0f172a),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              if (_hController.text.trim() == '1000') {
                state.nextStep();
                _hController.clear();
              } else {
                AudioManager.playError();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.t('msg_wrong_h'))));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4f46e5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              state.t('s5_b'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (state.step == 9) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0x3310b981),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x8010b981)),
        ),
        child: Center(
          child: Text(
            state.t('s9_i'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF34d399),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (state.step == 10) {
      return _primaryBtn(
        state.t('s10_b'),
        const Color(0xFF10b981),
        state.nextStep,
      );
    } else {
      Color btnColor = state.step == 6
          ? const Color(0xFF9333ea)
          : const Color(0xFF4f46e5);
      return _primaryBtn(state.t('s${state.step}_b'), btnColor, () {
        state.nextStep();
        if (state.step == 9 && !state.isRightPanelOpen) {
          state.toggleRightPanel();
        }
      });
    }
  }

  Widget _primaryBtn(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
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
        border: Border.all(color: const Color(0xFF4f46e5).withOpacity(0.5)),
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
          Text(
            state.t('s${math.min(state.step, 10)}_t').toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF4f46e5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.t('s${math.min(state.step, 10)}_i'),
            style: const TextStyle(
              color: Color(0xFFc7d2fe),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          LabControls(state: state), // Reusing Extracted Widget
        ],
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
        // We set safe minimums so the layout math NEVER evaluates to a negative number or infinity
        double canvasWidth = math.max(900.0, constraints.maxWidth);
        double canvasHeight = math.max(600.0, constraints.maxHeight);
        double graphHeight =
            canvasHeight * 0.55; // 55% of the allocated canvas height
        double maxBarHeight = math.max(
          10.0,
          graphHeight - 65,
        ); // Absolutely guarantees positive values

        // InteractiveViewer wrapped inside LayoutBuilder enables safe panning
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
                      // 1. Flat base Bars
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(5, (index) {
                            final row = dataset[index];

                            double targetHeight = 0.0;
                            if (state.step == 1) {
                              targetHeight = 0.0; // Bars are hidden initially
                            } else if (state.step < 6) {
                              // Max frequency is 135
                              targetHeight = (row.f / 135.0) * maxBarHeight;
                            } else {
                              // Max UI absolute value is 2
                              double uiVal = row.ui.abs();
                              targetHeight = uiVal == 0
                                  ? 0.0
                                  : (uiVal / 2.0) * maxBarHeight;
                            }

                            // Interaction for Assumed Mean
                            bool isAM = index == 2;
                            bool highlight = state.step == 3 && isAM;

                            return GestureDetector(
                              onTap: () {
                                if (state.step == 3) {
                                  if (isAM) {
                                    state.nextStep();
                                  } else {
                                    AudioManager.playError();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.t('msg_wrong_a')),
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
                                    .easeOutCubic, // Changed from easeOutBack to ensure it never crosses zero bounds
                                builder: (context, height, child) {
                                  // The crucial crash fix: Safely clamp to 0.0
                                  double safeHeight = math.max(0.0, height);

                                  return IsometricBar(
                                    height: safeHeight,
                                    color: barColors[index],
                                    highlight: highlight,
                                    label: state.step == 1
                                        ? ''
                                        : (state.step < 6
                                              ? 'f: ${row.f}'
                                              : 'ui: ${row.ui.toInt()}'),
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
                            30, // Matches Base Label Area inside IsometricBar
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
  final String label;
  final String baseLabel;

  const IsometricBar({
    super.key,
    required this.height,
    required this.color,
    this.highlight = false,
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Bar representation
        Container(
          width: 40,
          height: height + 5, // minimum height offset for visibility
          decoration: BoxDecoration(
            color: barColor.withOpacity(0.8),
            border: Border.all(color: barColor, width: 1.5),
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
              colors: [barColor.withOpacity(0.9), barColor.withOpacity(0.4)],
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
                color: const Color(0x336366f1),
                border: Border.all(color: const Color(0x806366f1)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                baseLabel,
                style: const TextStyle(
                  color: Color(0xFFc7d2fe),
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
                  'x̄ = ',
                  style: TextStyle(
                    color: Color(0xFF818cf8),
                    fontSize: 20,
                    fontFamily: 'monospace',
                  ),
                ),
                _slot('a', 'a', state),
                const Text(
                  ' + ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                _slot('h', 'h', state),
                const Text(
                  ' ( ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                _slot('fiui', 'Σfiui', state),
                const Text(
                  ' / ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                _slot('fi', 'Σfi', state),
                const Text(
                  ' )',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _bankBtn('a (3500)', 'a', Colors.amber, state),
              _bankBtn('h (1000)', 'h', Colors.blue, state),
              _bankBtn('Σfiui (25)', 'fiui', Colors.green, state),
              _bankBtn('Σfi (400)', 'fi', Colors.indigo, state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slot(String key, String expect, AppState state) {
    bool filled = state.filledSlots[key]!;
    String val = '';
    if (filled) {
      if (key == 'a') val = '3500';
      if (key == 'h') val = '1000';
      if (key == 'fiui') val = '25';
      if (key == 'fi') val = '400';
    }
    return Container(
      width: 45,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? const Color(0x336366f1) : const Color(0x800f172a),
        border: Border.all(
          color: filled ? const Color(0xFF6366f1) : const Color(0xFF475569),
          style: filled ? BorderStyle.solid : BorderStyle.none,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        filled ? val : expect,
        style: TextStyle(
          color: filled ? Colors.white : const Color(0xFF94a3b8),
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          fontSize: 14,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.shade900.withOpacity(0.3),
            border: Border.all(color: color.shade500.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color.shade300,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0f172a),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x806366f1)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x406366f1), blurRadius: 50),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF34d399),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.t('cel_msg'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFcbd5e1),
                          fontSize: 16,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x8010b981)),
                        ),
                        child: const Text(
                          '₹3562.5',
                          style: TextStyle(
                            color: Color(0xFF6ee7b7),
                            fontSize: 32,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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
                          backgroundColor: const Color(0xFF4f46e5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
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
          CustomPaint(painter: GridPainter(), size: Size.infinite),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x4D6366f1), blurRadius: 30),
                      ],
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      size: 60,
                      color: Color(0xFF818cf8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.t('app_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 48,
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF94a3b8),
                        fontFamily: 'monospace',
                        letterSpacing: 2,
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
                      backgroundColor: const Color(0xFF4f46e5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 20,
                      shadowColor: const Color(0xFF4f46e5),
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

// Background Grid effect
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.3)
      ..strokeWidth = 1;

    const double step = 40;
    const double limit = 10000;
    for (double i = -limit; i < limit; i += step) {
      canvas.drawLine(Offset(i, -limit), Offset(i, limit), paint);
      canvas.drawLine(Offset(-limit, i), Offset(limit, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
