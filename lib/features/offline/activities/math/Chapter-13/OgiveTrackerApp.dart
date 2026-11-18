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
  DataRowModel(100, 110, 4, 4),
  DataRowModel(110, 120, 6, 10),
  DataRowModel(120, 130, 10, 20), // Median Class (N/2 = 15)
  DataRowModel(130, 140, 5, 25),
  DataRowModel(140, 150, 5, 30),
];

const int totalN = 30;
const double medianVal = 125.0; // Interpolated Median

// --- I18N DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE OGIVE TRACKER',
    'tagline': 'LESS THAN CUMULATIVE FREQUENCY',
    'init_btn': 'INITIALIZE RADAR',
    'header_title': 'The Ogive Tracker',
    'header_subtitle': 'CLASS 10 • STATISTICS',
    'phase_label': 'GRAPHING PHASE',
    'step_label': 'Stage',
    'active_mission': 'Current Objective',
    'th_class': 'Class',
    'th_fi': 'Freq (f)',
    'th_cf': 'Cum. Freq (cf)',
    'th_point': 'Point (x, y)',
    'row_total': 'Total',
    'cel_title': 'TARGET ACQUIRED!',
    'cel_msg': 'The Median has been located via the Ogive Curve.',
    'btn_restart': 'Restart Tracker',
    's1_t': 'Step 1: The Data',
    's1_i':
        'Observe the grouped data. We need to construct a "Less Than" Ogive to visually find the Median.',
    's1_b': 'Analyze Data',
    's2_t': 'Step 2: "Less Than" Points',
    's2_i':
        'Determine the upper limits (x) and cumulative frequencies (y) to form coordinate points.',
    's2_b': 'Extract Coordinates',
    's3_t': 'Step 3: Plotting the Points',
    's3_i': 'Plot the coordinates on the graph. (e.g., 110, 4), (120, 10)...',
    's3_b': 'Plot Coordinates',
    's4_t': 'Step 4: Draw the Ogive',
    's4_i':
        'Connect the plotted points with a smooth curve. This is the "Less Than" Ogive.',
    's4_b': 'Draw Curve',
    's5_t': 'Step 5: Locate N/2',
    's5_i':
        'Find N/2 on the Y-axis. N = 30, so N/2 = 15. Draw a horizontal line to intercept the curve.',
    's5_b': 'Trace N/2 Line',
    's6_t': 'Step 6: Identify Median',
    's6_i':
        'From the intersection point, drop a vertical perpendicular line to the X-axis. This value is our Median!',
    's6_b': 'Drop Perpendicular',
    'calc_title': 'Coordinates & Data',
    'data_table_title': '1. Frequency Distribution',
    'objective_desc':
        'Construct a "Less Than" Ogive curve to visually determine the Median of the grouped data distribution.',
  },
  'hi': {
    'app_title': 'तोरण ट्रैकर',
    'tagline': 'कम प्रकार का संचयी बारंबारता',
    'init_btn': 'रडार शुरू करें',
    'header_title': 'तोरण ट्रैकर',
    'header_subtitle': 'कक्षा 10 • सांख्यिकी',
    'phase_label': 'ग्राफिंग चरण',
    'step_label': 'चरण',
    'active_mission': 'वर्तमान उद्देश्य',
    'th_class': 'वर्ग',
    'th_fi': 'बारंबारता (f)',
    'th_cf': 'संचाई बारंबारता (cf)',
    'th_point': 'बिंदु (x, y)',
    'row_total': 'कुल',
    'cel_title': 'लक्ष्य प्राप्त!',
    'cel_msg': 'तोरण वक्र के माध्यम से माध्यिका का पता लगा लिया गया है।',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: डेटा',
    's1_i':
        'समूहीकृत डेटा का निरीक्षण करें। माध्यिका खोजने के लिए हमें एक "कम प्रकार" का तोरण (Ogive) बनाना होगा।',
    's1_b': 'डेटा विश्लेषण',
    's2_t': 'चरण 2: "से कम" बिंदु',
    's2_i':
        'समन्वय बिंदु बनाने के लिए ऊपरी सीमा (x) और संचयी बारंबारता (y) निर्धारित करें।',
    's2_b': 'निर्देशांक निकालें',
    's3_t': 'चरण 3: बिंदुओं को प्लॉट करना',
    's3_i': 'ग्राफ पर निर्देशांक प्लॉट करें। (जैसे, 110, 4), (120, 10)...',
    's3_b': 'निर्देशांक प्लॉट करें',
    's4_t': 'चरण 4: तोरण खींचें',
    's4_i':
        'प्लॉट किए गए बिंदुओं को एक चिकने वक्र से जोड़ें। यह "से कम" तोरण है।',
    's4_b': 'वक्र खींचें',
    's5_t': 'चरण 5: N/2 खोजें',
    's5_i':
        'Y-अक्ष पर N/2 खोजें। N = 30, इसलिए N/2 = 15। वक्र को काटने के लिए एक क्षैतिज रेखा खींचें।',
    's5_b': 'N/2 रेखा खींचें',
    's6_t': 'चरण 6: माध्यिका की पहचान करें',
    's6_i':
        'प्रतिच्छेदन बिंदु से, X-अक्ष पर एक लंबवत रेखा गिराएं। यह मान हमारी माध्यिका है!',
    's6_b': 'लंबवत रेखा गिराएं',
    'calc_title': 'निर्देशांक एवं डेटा',
    'data_table_title': '1. बारंबारता वितरण',
    'objective_desc':
        'समूहीकृत डेटा वितरण की माध्यिका को दृष्टिगत रूप से निर्धारित करने के लिए "से कम" तोरण वक्र का निर्माण करें।',
  },
};

// --- STATE MANAGEMENT ---
class AppState extends ChangeNotifier {
  bool isInitialized = false;
  String lang = 'en';

  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  int step = 1;

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
    if (step < 7) {
      step++;
      if (step == 7) {
        AudioManager.playSuccess();
      } else {
        AudioManager.playClick();
      }
      notifyListeners();
    }
  }

  void resetLab() {
    step = 1;
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

class OgiveTrackerApp extends StatefulWidget {
  const OgiveTrackerApp({super.key});

  @override
  State<OgiveTrackerApp> createState() => _OgiveTrackerAppState();
}

class _OgiveTrackerAppState extends State<OgiveTrackerApp> {
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

    // Safely calculate the width of the canvas to prevent RenderBox bounds crash on small overlapping screens
    double canvasLeft = state.isInitialized && state.isLeftPanelOpen
        ? panelWidth
        : 0;
    double canvasRight = state.isInitialized && state.isRightPanelOpen
        ? panelWidth
        : 0;
    double canvasWidth = math.max(0.0, screenWidth - canvasLeft - canvasRight);

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

            // 1. CANVAS AREA (Dynamically Centers & perfectly Movable Visualizer without Layout Crash)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: canvasLeft,
              width:
                  canvasWidth, // Using strictly clamped width to prevent infinity crash
              child: Visualizer2D(state: state),
            ),

            // 2. FLOATING MISSION CARD (Visible when left panel is closed)
            if (state.isInitialized && !state.isLeftPanelOpen && state.step < 7)
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
                  color: const Color(0xFF10b981), // Emerald
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
                  color: const Color(0xFF34d399), // Emerald lighter
                  tooltip: 'Data / Coordinates',
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
                            colors: [Color(0xFF10b981), Color(0xFF047857)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4D10b981), blurRadius: 8),
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
                                color: Color(0xFF6ee7b7),
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
                                      ? const Color(0xFF10b981)
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
                        "${state.t('step_label')} ${math.min(state.step, 6)}/6",
                        style: const TextStyle(
                          color: Color(0xFF10b981),
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
                    color: const Color(0xFF10b981),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF10b981),
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
                              ? const Color(0xFF10b981).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF10b981)
                                : (isDone
                                      ? const Color(0xFF3b82f6).withOpacity(0.3)
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
                                      ? const Color(0xFF3b82f6)
                                      : (isActive
                                            ? const Color(0xFF10b981)
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
                const Icon(Icons.data_usage, color: Color(0xFF34d399)),
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
                      color: Color(0xFF6ee7b7),
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
                                  state.t('th_cf'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF34d399),
                                  ),
                                ),
                              ),
                            if (state.step >= 2)
                              DataColumn(
                                label: Text(
                                  state.t('th_point'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFf59e0b),
                                  ),
                                ),
                              ),
                          ],
                          rows: [
                            ...dataset.map((row) {
                              bool isPointStep = state.step >= 2;

                              return DataRow(
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
                                  if (isPointStep)
                                    DataCell(
                                      Text(
                                        '${row.cf}',
                                        style: const TextStyle(
                                          color: Color(0xFF34d399),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  if (isPointStep)
                                    DataCell(
                                      Text(
                                        '(${row.upper}, ${row.cf})',
                                        style: const TextStyle(
                                          color: Color(0xFFf59e0b),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                            // Footer Row
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
                                    '$totalN',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (state.step >= 2) const DataCell(Text('')),
                                if (state.step >= 2) const DataCell(Text('')),
                              ],
                            ),
                          ],
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
}

// --- LAB CONTROLS WIDGET ---
class LabControls extends StatelessWidget {
  final AppState state;
  const LabControls({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.step == 2) {
      return buildPrimaryBtn(state.t('s2_b'), const Color(0xFF10b981), () {
        state.nextStep();
        if (!state.isRightPanelOpen) state.toggleRightPanel();
      });
    } else {
      return buildPrimaryBtn(
        state.t('s${state.step}_b'),
        const Color(0xFF10b981),
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
        border: Border.all(color: const Color(0xFF10b981), width: 1.5),
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
                    color: Color(0xFF10b981),
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
                  '${state.step}/6',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFF6ee7b7),
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
    final parts = text.split('"');
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        spans.add(
          TextSpan(
            text: parts[i],
            style: const TextStyle(color: Color(0xFFd1fae5)),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '"${parts[i]}"',
            style: const TextStyle(
              color: Color(0xFFfcd34d),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
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
                // Graph Base Component
                Container(
                  width: 700,
                  height: 450,
                  padding: const EdgeInsets.all(20),
                  child: CustomPaint(
                    painter: GraphPainter(
                      step: state.step,
                      dataset: dataset,
                      totalN: totalN,
                      medianX: medianVal,
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

class GraphPainter extends CustomPainter {
  final int step;
  final List<DataRowModel> dataset;
  final int totalN;
  final double medianX;

  GraphPainter({
    required this.step,
    required this.dataset,
    required this.totalN,
    required this.medianX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Margins
    const double leftMargin = 50;
    const double bottomMargin = 50;
    const double rightMargin = 20;
    const double topMargin = 20;

    final double graphW = w - leftMargin - rightMargin;
    final double graphH = h - topMargin - bottomMargin;

    // Coordinate Mapping logic
    const double minX = 90; // Starting slightly before 100
    const double maxX = 160; // Ending slightly after 150
    const double minY = 0;
    const double maxY = 35; // N = 30, so 35 provides headroom

    Offset getPixel(double x, double y) {
      double px = leftMargin + ((x - minX) / (maxX - minX)) * graphW;
      double py = topMargin + graphH - ((y - minY) / (maxY - minY)) * graphH;
      return Offset(px, py);
    }

    final axisPaint = Paint()
      ..color = const Color(0xFF64748b)
      ..strokeWidth = 2;

    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.5)
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawText(
      String text,
      Offset pos, {
      bool centerX = true,
      bool centerY = true,
      Color color = const Color(0xFF94a3b8),
    }) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      double dx = pos.dx - (centerX ? textPainter.width / 2 : 0);
      double dy = pos.dy - (centerY ? textPainter.height / 2 : 0);
      textPainter.paint(canvas, Offset(dx, dy));
    }

    // 1. DRAW AXES AND GRID
    canvas.drawLine(
      Offset(leftMargin, topMargin),
      Offset(leftMargin, h - bottomMargin),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftMargin, h - bottomMargin),
      Offset(w - rightMargin, h - bottomMargin),
      axisPaint,
    );

    // X-Axis Ticks & Grid
    for (double x = 100; x <= 150; x += 10) {
      Offset p = getPixel(x, minY);
      canvas.drawLine(
        Offset(p.dx, topMargin),
        Offset(p.dx, h - bottomMargin),
        gridPaint,
      );
      canvas.drawLine(Offset(p.dx, p.dy), Offset(p.dx, p.dy + 5), axisPaint);
      drawText(x.toInt().toString(), Offset(p.dx, p.dy + 15));
    }
    drawText(
      'Upper Limits',
      Offset(leftMargin + graphW / 2, h - 15),
      color: Colors.white,
    );

    // Y-Axis Ticks & Grid
    for (double y = 5; y <= 35; y += 5) {
      Offset p = getPixel(minX, y);
      canvas.drawLine(
        Offset(leftMargin, p.dy),
        Offset(w - rightMargin, p.dy),
        gridPaint,
      );
      canvas.drawLine(
        Offset(leftMargin - 5, p.dy),
        Offset(leftMargin, p.dy),
        axisPaint,
      );
      drawText(y.toInt().toString(), Offset(leftMargin - 20, p.dy));
    }

    canvas.save();
    canvas.translate(15, topMargin + graphH / 2);
    canvas.rotate(-math.pi / 2);
    drawText('Cumulative Freq (cf)', const Offset(0, 0), color: Colors.white);
    canvas.restore();

    // Generate Points List
    List<Offset> points = [];
    for (var row in dataset) {
      points.add(getPixel(row.upper.toDouble(), row.cf.toDouble()));
    }

    // 2. DRAW POINTS (Step >= 3)
    if (step >= 3) {
      final pointPaint = Paint()
        ..color = const Color(0xFFf59e0b)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < points.length; i++) {
        canvas.drawCircle(points[i], 5, pointPaint);
        canvas.drawCircle(points[i], 5, borderPaint);
        // Draw coordinate labels slightly offset
        drawText(
          '(${dataset[i].upper}, ${dataset[i].cf})',
          Offset(points[i].dx, points[i].dy - 15),
          color: const Color(0xFFfcd34d),
        );
      }
    }

    // 3. DRAW OGIVE CURVE (Step >= 4)
    if (step >= 4) {
      final curvePaint = Paint()
        ..color = const Color(0xFF10b981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Draw a smooth bezier or connected lines. Using connected lines for statistical accuracy of standard ogives.
      Path path = Path();
      // Ogive usually starts from the lower limit of the first class with cf=0
      Offset startPoint = getPixel(dataset.first.lower.toDouble(), 0);
      path.moveTo(startPoint.dx, startPoint.dy);

      for (var point in points) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, curvePaint);
    }

    // 4. LOCATE N/2 (Step >= 5)
    final double halfN = totalN / 2; // 15
    Offset n2Start = getPixel(minX, halfN);
    Offset intersect = getPixel(
      medianX,
      halfN,
    ); // Median happens to be 125 exactly

    if (step >= 5) {
      final dashPaint = Paint()
        ..color = const Color(0xFF3b82f6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Draw dashed horizontal line
      double dashWidth = 5, dashSpace = 5;
      double startX = n2Start.dx;
      while (startX < intersect.dx) {
        canvas.drawLine(
          Offset(startX, n2Start.dy),
          Offset(math.min(startX + dashWidth, intersect.dx), n2Start.dy),
          dashPaint,
        );
        startX += dashWidth + dashSpace;
      }

      // Mark N/2 on Y axis
      canvas.drawCircle(n2Start, 4, Paint()..color = const Color(0xFF3b82f6));
      drawText(
        'N/2 = 15',
        Offset(n2Start.dx + 25, n2Start.dy - 10),
        color: const Color(0xFF93c5fd),
      );

      // Intersection Point
      canvas.drawCircle(intersect, 6, Paint()..color = const Color(0xFFef4444));
    }

    // 5. IDENTIFY MEDIAN (Step >= 6)
    if (step >= 6) {
      final dropPaint = Paint()
        ..color = const Color(0xFFef4444)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      Offset dropEnd = getPixel(medianX, minY);

      // Draw dashed vertical line
      double dashWidth = 5, dashSpace = 5;
      double startY = intersect.dy;
      while (startY < dropEnd.dy) {
        canvas.drawLine(
          Offset(intersect.dx, startY),
          Offset(intersect.dx, math.min(startY + dashWidth, dropEnd.dy)),
          dropPaint,
        );
        startY += dashWidth + dashSpace;
      }

      // Mark Median on X axis
      canvas.drawCircle(dropEnd, 5, Paint()..color = const Color(0xFFef4444));

      // Glowing box for final result
      Rect resultRect = Rect.fromCenter(
        center: Offset(dropEnd.dx, dropEnd.dy + 25),
        width: 90,
        height: 24,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(resultRect, const Radius.circular(6)),
        Paint()..color = const Color(0xFFef4444).withOpacity(0.2),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(resultRect, const Radius.circular(6)),
        Paint()
          ..color = const Color(0xFFef4444)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      drawText(
        'Median = 125',
        Offset(resultRect.center.dx, resultRect.center.dy),
        color: Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.step != step;
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
                      const Text('🎯', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6ee7b7),
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
                          border: Border.all(color: const Color(0x80ef4444)),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Median = 125',
                            style: TextStyle(
                              color: Color(0xFFfca5a5),
                              fontSize: 48,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
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
                          backgroundColor: const Color(0xFF10b981),
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
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
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
                        BoxShadow(color: Color(0x4D10b981), blurRadius: 40),
                      ],
                    ),
                    child: const Icon(
                      Icons.radar,
                      size: 64,
                      color: Color(0xFF34d399),
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
                      backgroundColor: const Color(0xFF10b981),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 20,
                      shadowColor: const Color(0xFF10b981),
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
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.3)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
