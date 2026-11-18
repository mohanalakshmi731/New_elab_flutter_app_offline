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
}

final List<DataRowModel> dataset = [
  DataRowModel(4, 6, 40),
  DataRowModel(6, 8, 70), // f0
  DataRowModel(8, 10, 150), // Modal Class (f1, l=8, h=2)
  DataRowModel(10, 12, 60), // f2
  DataRowModel(12, 14, 20),
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
    'app_title': 'THE MODAL TOWER',
    'tagline': 'FINDING THE PEAK',
    'init_btn': 'INITIALIZE SCANNER',
    'header_title': 'The Modal Tower',
    'header_subtitle': 'CLASS 10 • STATISTICS',
    'phase_label': 'ANALYSIS PHASE',
    'step_label': 'Stage',
    'active_mission': 'Current Objective',
    'th_class': 'Class Interval',
    'th_fi': 'Frequency (fi)',
    'row_total': 'Total',
    'cel_title': 'PEAK DISCOVERED!',
    'cel_msg': 'The exact Mode was calculated successfully.',
    'btn_restart': 'Restart Simulation',
    's1_t': 'Step 1: The Frequency Data',
    's1_i':
        'Observe the data distribution. We need to find the Mode (the most frequent value).',
    's1_b': 'Analyze Data',
    's2_t': 'Step 2: Modal Class',
    's2_i':
        'The class with the highest frequency is the Modal Class. Tap the tallest bar in the 3D view.',
    's2_b': 'Locate Modal Class',
    's3_t': 'Step 3: Extract Parameters',
    's3_i':
        'Identify the lower limit (l), class size (h), and the relevant frequencies (f1, f0, f2).',
    's3_b': 'Scan Parameters',
    's4_t': 'Step 4: Formula Assembly',
    's4_i':
        'Open the Data panel and tap variables from the bank to construct the Mode formula.',
    's4_b': 'ASSEMBLE FORMULA',
    's5_t': 'Step 5: Final Computation',
    's5_i': 'Solve the equation algebraically to find the exact Mode.',
    's5_b': 'Compute Mode',
    'msg_click_bar': 'Tap the highest bar (8-10)',
    'msg_wrong_bar': 'Find the bar with the maximum frequency (150).',
    'msg_populate': 'Populate formula below',
    'calc_step_1_t': 'Subtract Frequencies',
    'calc_step_2_t': 'Denominator Math',
    'calc_step_3_t': 'Divide and Multiply',
    'calc_step_4_t': 'Final Addition',
    'status_locked': 'Locked',
    'status_calc': 'Calculate',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Frequency Distribution',
    'formula_title': '2. The Mode Formula',
    'math_engine_title': '3. Algebraic Solver',
    'objective_desc':
        'Identify the Modal Class visually, extract its parameters, and use the Mode formula to calculate the peak value.',
  },
  'hi': {
    'app_title': 'बहुलक टावर',
    'tagline': 'शिखर की खोज',
    'init_btn': 'स्कैनर शुरू करें',
    'header_title': 'बहुलक टावर',
    'header_subtitle': 'कक्षा 10 • सांख्यिकी',
    'phase_label': 'विश्लेषण चरण',
    'step_label': 'चरण',
    'active_mission': 'वर्तमान उद्देश्य',
    'th_class': 'वर्ग अंतराल',
    'th_fi': 'बारंबारता (fi)',
    'row_total': 'कुल',
    'cel_title': 'शिखर मिल गया!',
    'cel_msg': 'सटीक बहुलक की सफलतापूर्वक गणना की गई।',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: बारंबारता डेटा',
    's1_i':
        'डेटा वितरण का निरीक्षण करें। हमें बहुलक (सबसे अधिक बार आने वाला मान) ज्ञात करना है।',
    's1_b': 'डेटा विश्लेषण',
    's2_t': 'चरण 2: बहुलक वर्ग',
    's2_i':
        'सबसे अधिक बारंबारता वाला वर्ग बहुलक वर्ग है। 3D दृश्य में सबसे ऊंचे बार पर टैप करें।',
    's2_b': 'बहुलक वर्ग खोजें',
    's3_t': 'चरण 3: पैरामीटर निकालें',
    's3_i':
        'निचली सीमा (l), वर्ग आकार (h), और प्रासंगिक बारंबारता (f1, f0, f2) की पहचान करें।',
    's3_b': 'पैरामीटर स्कैन करें',
    's4_t': 'चरण 4: सूत्र संयोजन',
    's4_i': 'डेटा पैनल खोलें और बहुलक सूत्र बनाने के लिए चर पर टैप करें।',
    's4_b': 'सूत्र संयोजित करें',
    's5_t': 'चरण 5: अंतिम गणना',
    's5_i': 'सटीक बहुलक ज्ञात करने के लिए समीकरण को बीजगणितीय रूप से हल करें।',
    's5_b': 'बहुलक की गणना करें',
    'msg_click_bar': 'सबसे ऊंचे बार (8-10) पर टैप करें',
    'msg_wrong_bar': 'अधिकतम बारंबारता (150) वाला बार खोजें।',
    'msg_populate': 'नीचे सूत्र भरें',
    'calc_step_1_t': 'बारंबारता घटाएं',
    'calc_step_2_t': 'हर (Denominator) की गणना',
    'calc_step_3_t': 'भाग और गुणा',
    'calc_step_4_t': 'अंतिम जोड़',
    'status_locked': 'लॉक्ड',
    'status_calc': 'गणना करें',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. बारंबारता वितरण',
    'formula_title': '2. बहुलक सूत्र',
    'math_engine_title': '3. बीजगणितीय सॉल्वर',
    'objective_desc':
        'नेत्रहीन रूप से बहुलक वर्ग की पहचान करें, उसके मापदंडों को निकालें, और शिखर मान की गणना करने के लिए बहुलक सूत्र का उपयोग करें।',
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
    'l': false,
    'h': false,
    'f1': false,
    'f0': false,
    'f2': false,
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
    if (step < 6) {
      step++;
      if (step == 6) {
        AudioManager.playSuccess();
      } else {
        AudioManager.playClick();
      }
      notifyListeners();
    }
  }

  void handleBarClick(int id) {
    if (step == 2) {
      if (id == 2) {
        // The Modal Class is index 2 (8-10, freq 150)
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
            nextStep(); // Progress to step 5 (Calculations)
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
    calcStage = 0;
    filledSlots = {
      'l': false,
      'h': false,
      'f1': false,
      'f0': false,
      'f2': false,
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

class ModalTowerApp extends StatefulWidget {
  const ModalTowerApp({super.key});

  @override
  State<ModalTowerApp> createState() => _ModalTowerAppState();
}

class _ModalTowerAppState extends State<ModalTowerApp> {
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
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [Color(0x000f172a), Color(0xFF020617)],
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
            if (state.isInitialized && !state.isLeftPanelOpen && state.step < 6)
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
              // Menu Button Row (Top Left)
              Positioned(
                top: 20,
                left: 20,
                child: _buildFloatingActionBtn(
                  icon: state.isLeftPanelOpen ? Icons.menu_open : Icons.menu,
                  onTap: state.toggleLeftPanel,
                  color: const Color(0xFFe11d48), // Rose 600
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
                  color: const Color(0xFFfb7185), // Rose 400
                  tooltip: 'Data / Calculations',
                ),
              ),
            ],

            // CELEBRATION (Step 6)
            if (state.step == 6 && state.isInitialized)
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
                            colors: [Color(0xFFe11d48), Color(0xFFbe123c)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4De11d48), blurRadius: 8),
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
                                color: Color(0xFFfda4af),
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
                                      ? const Color(0xFFe11d48)
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
                        "${state.t('step_label')} ${math.min(state.step, 5)}/5",
                        style: const TextStyle(
                          color: Color(0xFFe11d48),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: math.min(state.step, 5) / 5,
                    backgroundColor: Colors.black38,
                    color: const Color(0xFFe11d48),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFe11d48),
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
                    itemCount: 5,
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
                              ? const Color(0xFFe11d48).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFe11d48)
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
                                            ? const Color(0xFFe11d48)
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
                const Icon(Icons.data_usage, color: Color(0xFFf43f5e)),
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
                      color: Color(0xFFfb7185),
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
                            if (state.step >= 3)
                              const DataColumn(
                                label: Text(
                                  'Param',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFfb7185),
                                  ),
                                ),
                              ),
                          ],
                          rows: [
                            ...dataset.map((row) {
                              int idx = dataset.indexOf(row);
                              bool isModal = state.step >= 3 && idx == 2;
                              bool isF0 = state.step >= 3 && idx == 1;
                              bool isF2 = state.step >= 3 && idx == 3;

                              Color? rowColor;
                              Color varColor = Colors.transparent;
                              String varLabel = '';

                              if (isModal) {
                                rowColor = const Color(
                                  0x4De11d48,
                                ); // Rose 900 tint
                                varColor = const Color(0xFFfb7185);
                                varLabel = 'f1 (Modal)';
                              } else if (isF0) {
                                rowColor = const Color(
                                  0x33f59e0b,
                                ); // Amber tint
                                varColor = const Color(0xFFfcd34d);
                                varLabel = 'f0 (Preceding)';
                              } else if (isF2) {
                                rowColor = const Color(0x333b82f6); // Blue tint
                                varColor = const Color(0xFF93c5fd);
                                varLabel = 'f2 (Succeeding)';
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: (isModal || isF0 || isF2)
                                            ? varColor
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (state.step >= 3)
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
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // MATH ENGINE (Steps 4-5)
                  if (state.step >= 4) ...[
                    Text(
                      state.step == 4
                          ? state.t('formula_title')
                          : state.t('math_engine_title'),
                      style: const TextStyle(
                        color: Color(0xFFe11d48),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (state.step == 4)
                      FormulaBuilder(state: state)
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0x330f172a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x80e11d48)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _mathRow(
                              'Mode =',
                              '8 + [ (150 - 70) / (2(150) - 70 - 60) ] × 2',
                              const Color(0xFF94a3b8),
                            ),

                            const SizedBox(height: 12),

                            if (state.step >= 5) ...[
                              _calcStageItem(
                                0,
                                state.t('calc_step_1_t'),
                                '8 + [ 80 / (300 - 130) ] × 2',
                                '150-70=80, 2(150)=300, 70+60=130',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                1,
                                state.t('calc_step_2_t'),
                                '8 + [ 80 / 170 ] × 2',
                                '300-130=170',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                2,
                                state.t('calc_step_3_t'),
                                '8 + 0.941',
                                '(80/170) × 2 ≈ 0.941',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                3,
                                state.t('calc_step_4_t'),
                                'Mode = 8.94',
                                'Rounded to two decimals',
                                state,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              lhs,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: large ? 24 : 14,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              rhs,
              style: TextStyle(
                color: color,
                fontSize: large ? 24 : 14,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
        ? const Color(0xFFe11d48)
        : const Color(0x801e293b);
    Color borderColor = isDone
        ? const Color(0x6610b981)
        : isActive
        ? const Color(0xFFfda4af)
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          boxShadow: isActive
              ? [const BoxShadow(color: Color(0x80e11d48), blurRadius: 10)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (isDone)
                  const Icon(Icons.check, size: 16, color: Color(0xFF34d399)),
              ],
            ),
            if (isActive || isDone) ...[
              const SizedBox(height: 6),
              Text(
                infoText,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                displayVal,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
    if (state.step == 2) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x339f1239), // Rose 900
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x4De11d48)),
        ),
        child: Center(
          child: Text(
            state.t('msg_click_bar'),
            style: const TextStyle(
              color: Color(0xFFfda4af),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (state.step == 4) {
      return const SizedBox(); // Formula builder handles interaction here
    } else if (state.step == 5) {
      return const SizedBox(); // Calculation list handles interaction here
    } else if (state.step == 6) {
      return const SizedBox(); // Celebration overlay
    } else {
      return buildPrimaryBtn(
        state.t('s${state.step}_b'),
        const Color(0xFFe11d48),
        () {
          state.nextStep();
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
        color: const Color(0xE60f172a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe11d48), width: 1.5),
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
                    color: Color(0xFFe11d48),
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
                  '${state.step}/5',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFFfda4af),
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
              color: Color(0xFFfda4af),
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
        border: Border.all(color: const Color(0x80e11d48)),
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
                  'Mode = ',
                  style: TextStyle(
                    color: Color(0xFFfb7185),
                    fontSize: 20,
                    fontFamily: 'monospace',
                  ),
                ),
                _slot('l', 'l', state),
                const Text(
                  ' + [ ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),

                Column(
                  children: [
                    Row(
                      children: [
                        _slot('f1', 'f1', state, isF1F0: true),
                        const Text(
                          ' - ',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        _slot('f0', 'f0', state, isF1F0: true),
                      ],
                    ),
                    Container(
                      width: 140,
                      height: 2,
                      color: Colors.white30,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    Row(
                      children: [
                        const Text(
                          '2',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        _slot('f1', 'f1', state, isF1F0: true),
                        const Text(
                          ' - ',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        _slot('f0', 'f0', state, isF1F0: true),
                        const Text(
                          ' - ',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        _slot('f2', 'f2', state),
                      ],
                    ),
                  ],
                ),

                const Text(
                  ' ] × ',
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
              _bankBtn('l = 8', 'l', Colors.red, state),
              _bankBtn('h = 2', 'h', Colors.purple, state),
              _bankBtn('f1 = 150', 'f1', Colors.pink, state),
              _bankBtn('f0 = 70', 'f0', Colors.amber, state),
              _bankBtn('f2 = 60', 'f2', Colors.blue, state),
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
    bool isF1F0 = false,
  }) {
    bool filled = state.filledSlots[key]!;
    String val = '';
    if (filled) {
      if (key == 'l') val = '8';
      if (key == 'h') val = '2';
      if (key == 'f1') val = '150';
      if (key == 'f0') val = '70';
      if (key == 'f2') val = '60';
    }

    return GestureDetector(
      onTap: () {
        if (!filled) state.fillSlot(key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: isF1F0 ? 36 : 46,
        height: isF1F0 ? 28 : 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0x33e11d48) : const Color(0x800f172a),
          border: Border.all(
            color: filled ? const Color(0xFFe11d48) : const Color(0xFF475569),
            style: filled ? BorderStyle.solid : BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          filled ? val : expect,
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFF94a3b8),
            fontWeight: FontWeight.bold,
            fontSize: isF1F0 ? 12 : 14,
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

// --- VISUALIZER 3D ---
class Visualizer3D extends StatelessWidget {
  final AppState state;
  const Visualizer3D({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Enforce safe layout boundaries ensuring no negative height
        double availableHeight = math.max(10.0, constraints.maxHeight);
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
                          color: const Color(0x33e11d48),
                          width: 2,
                        ),
                        gradient: const RadialGradient(
                          colors: [Color(0x33e11d48), Colors.transparent],
                          radius: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),

                // Isometric Bars
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  height: barMaxArea + 60, // Accommodate labels
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(5, (index) {
                            final row = dataset[index];

                            // Scale Height Calculations
                            double maxF = 150.0;
                            double heightFactor = row.f / maxF;
                            double targetHeight = barMaxArea * heightFactor;
                            targetHeight = math.max(0.0, targetHeight);

                            bool isModal = index == 2;
                            bool highlight = state.step >= 2 && isModal;
                            double opacity = state.step >= 3 && !isModal
                                ? 0.3
                                : 0.9;

                            double currentHeight = state.step == 1
                                ? 0.0
                                : targetHeight;

                            return GestureDetector(
                              onTap: () {
                                if (state.step == 2) {
                                  if (isModal) {
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
                                  end: currentHeight,
                                ),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves
                                    .easeOutCubic, // Use safe curve to avoid negative overshoot
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

                      // X-Axis Base Line
                      Positioned(
                        bottom:
                            30, // Matches Base Label Area inside IsometricBar
                        left: 20,
                        right: 20,
                        height: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFfda4af).withOpacity(0.8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFe11d48),
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
          height:
              math.max(0.0, height) + 5, // minimum height offset for visibility
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
                color: const Color(0x33e11d48).withOpacity(opacity * 0.3),
                border: Border.all(
                  color: const Color(0x80e11d48).withOpacity(opacity * 0.5),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                baseLabel,
                style: TextStyle(
                  color: const Color(0xFFfda4af).withOpacity(opacity),
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
                    border: Border.all(color: const Color(0x80e11d48)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66e11d48), blurRadius: 60),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏔️', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFfda4af),
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
                          border: Border.all(color: const Color(0x80f43f5e)),
                        ),
                        child: const Text(
                          'Mode = 8.94',
                          style: TextStyle(
                            color: Color(0xFFfca5a5),
                            fontSize: 48,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
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
                          backgroundColor: const Color(0xFFe11d48),
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
                    BoxShadow(color: Color(0x4De11d48), blurRadius: 40),
                  ],
                ),
                child: const Icon(
                  Icons.bar_chart,
                  size: 64,
                  color: Color(0xFFf43f5e),
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
                  backgroundColor: const Color(0xFFe11d48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 20,
                  shadowColor: const Color(0xFFe11d48),
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
