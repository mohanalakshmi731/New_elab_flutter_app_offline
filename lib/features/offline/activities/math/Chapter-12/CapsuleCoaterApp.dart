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

// --- I18N DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE CAPSULE COATER',
    'tagline': 'SURFACE AREAS & VOLUMES',
    'init_btn': 'INITIALIZE WORKSHOP',
    'header_title': 'The Capsule Coater',
    'header_subtitle': 'CLASS 10 • MENSURATION',
    'phase_label': 'ANALYSIS PHASE',
    'step_label': 'Stage',
    'active_mission': 'Current Objective',
    'th_part': 'Component',
    'th_radius': 'Radius (r)',
    'th_length': 'Length (h)',
    'cel_title': 'COATING COMPLETE!',
    'cel_msg': 'Total Surface Area calculated successfully.',
    'btn_restart': 'Restart Workshop',
    's1_t': 'Step 1: The Capsule',
    's1_i':
        'Observe the medical capsule. It has a total length of 14 mm and a diameter of 5 mm.',
    's1_b': 'Analyze Shape',
    's2_t': 'Step 2: Deconstruct Shape',
    's2_i':
        'A capsule is essentially a central cylinder with two hemispheres stuck to its ends. Let\'s split it apart to see clearly.',
    's2_b': 'Deconstruct Capsule',
    's3_t': 'Step 3: Extract Dimensions',
    's3_i':
        'The diameter is 5 mm, so radius (r) = 2.5 mm. The cylinder length (h) = Total Length (14) - 2 × Radius (5) = 9 mm.',
    's3_b': 'Extract Dimensions',
    's4_t': 'Step 4: Formula Assembly',
    's4_i':
        'Open the Data Panel. Total Area = CSA of Cylinder + 2 × CSA of Hemisphere. Tap variables to assemble the formula.',
    's4_b': 'ASSEMBLE FORMULA',
    's5_t': 'Step 5: Final Computation',
    's5_i':
        'Substitute r = 2.5 and h = 9 into the formula to calculate the exact surface area in mm².',
    's5_b': 'Compute Area',
    'msg_populate': 'Populate formula below',
    'status_locked': 'Locked',
    'status_calc': 'Calculate',
    'calc_step_1_t': 'Substitute Values',
    'calc_step_2_t': 'Simplify Parentheses',
    'calc_step_3_t': 'Multiply Factors',
    'calc_step_4_t': 'Final Result',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Component Dimensions',
    'formula_title': '2. Surface Area Formula',
    'math_engine_title': '3. Algebraic Solver',
    'objective_desc':
        'Deconstruct a complex solid into basic shapes (cylinder and hemispheres) to calculate its total surface area.',
  },
  'hi': {
    'app_title': 'कैप्सूल कोटर',
    'tagline': 'पृष्ठीय क्षेत्रफल और आयतन',
    'init_btn': 'वर्कशॉप शुरू करें',
    'header_title': 'कैप्सूल कोटर',
    'header_subtitle': 'कक्षा 10 • क्षेत्रमिति',
    'phase_label': 'विश्लेषण चरण',
    'step_label': 'चरण',
    'active_mission': 'वर्तमान उद्देश्य',
    'th_part': 'घटक',
    'th_radius': 'त्रिज्या (r)',
    'th_length': 'लंबाई (h)',
    'cel_title': 'कोटिंग पूर्ण!',
    'cel_msg': 'कुल पृष्ठीय क्षेत्रफल की सफलतापूर्वक गणना की गई।',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: कैप्सूल',
    's1_i':
        'मेडिकल कैप्सूल का निरीक्षण करें। इसकी कुल लंबाई 14 मिमी और व्यास 5 मिमी है।',
    's1_b': 'आकार का विश्लेषण करें',
    's2_t': 'चरण 2: आकार को अलग करें',
    's2_i':
        'एक कैप्सूल अनिवार्य रूप से एक केंद्रीय बेलन है जिसके सिरों पर दो अर्धगोले चिपके हुए हैं। स्पष्ट रूप से देखने के लिए इसे अलग करें।',
    's2_b': 'कैप्सूल को अलग करें',
    's3_t': 'चरण 3: आयाम निकालें',
    's3_i':
        'व्यास 5 मिमी है, इसलिए त्रिज्या (r) = 2.5 मिमी। बेलन की लंबाई (h) = कुल लंबाई (14) - 2 × त्रिज्या (5) = 9 मिमी।',
    's3_b': 'आयाम निकालें',
    's4_t': 'चरण 4: सूत्र संयोजन',
    's4_i':
        'डेटा पैनल खोलें। कुल क्षेत्रफल = बेलन का वक्र पृष्ठ + 2 × अर्धगोले का वक्र पृष्ठ।',
    's4_b': 'सूत्र संयोजित करें',
    's5_t': 'चरण 5: अंतिम गणना',
    's5_i':
        'सटीक पृष्ठीय क्षेत्रफल की गणना करने के लिए सूत्र में r = 2.5 और h = 9 रखें।',
    's5_b': 'क्षेत्रफल की गणना करें',
    'msg_populate': 'नीचे सूत्र भरें',
    'status_locked': 'लॉक्ड',
    'status_calc': 'गणना करें',
    'calc_step_1_t': 'मान रखें',
    'calc_step_2_t': 'कोष्ठक सरल करें',
    'calc_step_3_t': 'कारकों को गुणा करें',
    'calc_step_4_t': 'अंतिम परिणाम',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. घटक आयाम',
    'formula_title': '2. पृष्ठीय क्षेत्रफल सूत्र',
    'math_engine_title': '3. बीजगणितीय सॉल्वर',
    'objective_desc':
        'कुल पृष्ठीय क्षेत्रफल की गणना करने के लिए एक जटिल ठोस को मूल आकृतियों (बेलन और अर्धगोले) में विघटित करें।',
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

  Map<String, bool> filledSlots = {'csa_cyl': false, 'csa_hemi': false};

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
    filledSlots = {'csa_cyl': false, 'csa_hemi': false};
    lang = 'en';
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

class CapsuleCoaterApp extends StatefulWidget {
  const CapsuleCoaterApp({super.key});

  @override
  State<CapsuleCoaterApp> createState() => _CapsuleCoaterAppState();
}

class _CapsuleCoaterAppState extends State<CapsuleCoaterApp> {
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
              child: VisualizerArea(state: state),
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
                  color: const Color(0xFFec4899), // Pink 500
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
                  color: const Color(0xFFf472b6), // Pink 400
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
                            colors: [Color(0xFFec4899), Color(0xFFbe185d)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4Dec4899), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.vaccines, color: Colors.white),
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
                                color: Color(0xFFfbcfe8),
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
                                      ? const Color(0xFFec4899)
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
                          color: Color(0xFFec4899),
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
                    color: const Color(0xFFec4899),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFec4899),
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
                              ? const Color(0xFFec4899).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFec4899)
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
                                            ? const Color(0xFFec4899)
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
                const Icon(Icons.data_usage, color: Color(0xFFf472b6)),
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
                      color: Color(0xFFfbcfe8),
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
                                state.t('th_part'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_radius'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_length'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    state.lang == 'hi' ? 'कैप्सूल' : 'Capsule',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const DataCell(
                                  Text(
                                    '2.5 mm',
                                    style: TextStyle(
                                      color: Color(0xFFcbd5e1),
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                const DataCell(
                                  Text(
                                    '14 mm',
                                    style: TextStyle(
                                      color: Color(0xFFcbd5e1),
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (state.step >= 3)
                              DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (states) => const Color(0x333b82f6),
                                ),
                                cells: [
                                  DataCell(
                                    Text(
                                      state.lang == 'hi' ? 'बेलन' : 'Cylinder',
                                      style: const TextStyle(
                                        color: Color(0xFF93c5fd),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '2.5 mm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '9 mm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (state.step >= 3)
                              DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (states) => const Color(0x3310b981),
                                ),
                                cells: [
                                  DataCell(
                                    Text(
                                      state.lang == 'hi'
                                          ? 'अर्धगोले (x2)'
                                          : 'Hemispheres (x2)',
                                      style: const TextStyle(
                                        color: Color(0xFF6ee7b7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '2.5 mm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '-',
                                      style: TextStyle(
                                        color: Color(0xFFcbd5e1),
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

                  // MATH ENGINE (Steps 4-5)
                  if (state.step >= 4) ...[
                    Text(
                      state.step == 4
                          ? state.t('formula_title')
                          : state.t('math_engine_title'),
                      style: const TextStyle(
                        color: Color(0xFFec4899),
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
                          border: Border.all(color: const Color(0x80ec4899)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _mathRow(
                              'Area =',
                              '2πrh + 2(2πr²)',
                              const Color(0xFF94a3b8),
                            ),
                            _mathRow(
                              'Area =',
                              '2πr(h + 2r)',
                              const Color(0xFF94a3b8),
                            ),

                            const SizedBox(height: 12),

                            if (state.step >= 5) ...[
                              _calcStageItem(
                                0,
                                state.t('calc_step_1_t'),
                                '2 × (22/7) × 2.5 × (9 + 2(2.5))',
                                'r = 2.5, h = 9',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                1,
                                state.t('calc_step_2_t'),
                                '5 × (22/7) × (9 + 5)',
                                '2 × 2.5 = 5',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                2,
                                state.t('calc_step_3_t'),
                                '5 × (22/7) × 14',
                                '9 + 5 = 14',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                3,
                                state.t('calc_step_4_t'),
                                'Area = 220 mm²',
                                '5 × 22 × 2',
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
        ? const Color(0xFFec4899)
        : const Color(0x801e293b);
    Color borderColor = isDone
        ? const Color(0x6610b981)
        : isActive
        ? const Color(0xFFf472b6)
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
              ? [const BoxShadow(color: Color(0x80ec4899), blurRadius: 10)]
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
    if (state.step == 4) {
      return const SizedBox(); // Formula builder handles interaction here
    } else if (state.step == 5) {
      return const SizedBox(); // Calculation list handles interaction here
    } else {
      return buildPrimaryBtn(
        state.t('s${state.step}_b'),
        const Color(0xFFec4899),
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
        border: Border.all(color: const Color(0xFFec4899), width: 1.5),
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
                    color: Color(0xFFec4899),
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
                    color: Color(0xFFfbcfe8),
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
              color: Color(0xFFf472b6),
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
        border: Border.all(color: const Color(0x80ec4899)),
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
                  'Total Area = ',
                  style: TextStyle(
                    color: Color(0xFFf472b6),
                    fontSize: 18,
                    fontFamily: 'monospace',
                  ),
                ),
                _slot('csa_cyl', 'CSA of Cylinder', state, wide: true),
                const Text(
                  ' + 2 ( ',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                _slot('csa_hemi', 'CSA of Hemisphere', state, wide: true),
                const Text(
                  ' )',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _bankBtn('CSA of Cylinder (2πrh)', 'csa_cyl', Colors.blue, state),
              _bankBtn(
                'CSA of Hemisphere (2πr²)',
                'csa_hemi',
                Colors.green,
                state,
              ),
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
      if (key == 'csa_cyl') val = '2πrh';
      if (key == 'csa_hemi') val = '2πr²';
    }

    return GestureDetector(
      onTap: () {
        if (!filled) state.fillSlot(key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: wide ? 130 : 46,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0x33ec4899) : const Color(0x800f172a),
          border: Border.all(
            color: filled ? const Color(0xFFec4899) : const Color(0xFF475569),
            style: filled ? BorderStyle.solid : BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          filled ? val : expect,
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFF94a3b8),
            fontWeight: FontWeight.bold,
            fontSize: 12,
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

// --- VISUALIZER AREA ---
class VisualizerArea extends StatelessWidget {
  final AppState state;
  const VisualizerArea({super.key, required this.state});

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
              children: [CapsuleWidget(state: state)],
            ),
          ),
        );
      },
    );
  }
}

class CapsuleWidget extends StatelessWidget {
  final AppState state;
  const CapsuleWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Determine the translation based on step
    double splitOffset = state.step >= 2 ? 60.0 : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: splitOffset),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutCubic,
      builder: (context, offset, child) {
        return CustomPaint(
          size: const Size(500, 300),
          painter: CapsulePainter(splitOffset: offset, step: state.step),
        );
      },
    );
  }
}

class CapsulePainter extends CustomPainter {
  final double splitOffset;
  final int step;

  CapsulePainter({required this.splitOffset, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Scale mapping (1mm = 15 pixels)
    final double r = 2.5 * 15; // 37.5 px
    final double h = 9 * 15; // 135 px

    final Paint cylPaint = Paint()
      ..color = const Color(0xFF3b82f6)
      ..style = PaintingStyle.fill;

    final Paint hemiPaint = Paint()
      ..color = const Color(0xFF10b981)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Center geometry around (cx, cy)
    // Cylinder goes from cx - h/2 to cx + h/2
    Rect cylRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: h,
      height: r * 2,
    );

    // Left Hemisphere center is at cx - h/2 - splitOffset
    Offset leftHemiCenter = Offset(cx - h / 2 - splitOffset, cy);
    Rect leftHemiRect = Rect.fromCenter(
      center: leftHemiCenter,
      width: r * 2,
      height: r * 2,
    );

    // Right Hemisphere center is at cx + h/2 + splitOffset
    Offset rightHemiCenter = Offset(cx + h / 2 + splitOffset, cy);
    Rect rightHemiRect = Rect.fromCenter(
      center: rightHemiCenter,
      width: r * 2,
      height: r * 2,
    );

    // Draw Left Hemisphere
    canvas.drawArc(leftHemiRect, math.pi / 2, math.pi, true, hemiPaint);
    canvas.drawArc(leftHemiRect, math.pi / 2, math.pi, true, borderPaint);
    canvas.drawLine(
      Offset(leftHemiCenter.dx, leftHemiCenter.dy - r),
      Offset(leftHemiCenter.dx, leftHemiCenter.dy + r),
      borderPaint,
    );

    // Draw Right Hemisphere
    canvas.drawArc(rightHemiRect, -math.pi / 2, math.pi, true, hemiPaint);
    canvas.drawArc(rightHemiRect, -math.pi / 2, math.pi, true, borderPaint);
    canvas.drawLine(
      Offset(rightHemiCenter.dx, rightHemiCenter.dy - r),
      Offset(rightHemiCenter.dx, rightHemiCenter.dy + r),
      borderPaint,
    );

    // Draw Cylinder
    canvas.drawRect(cylRect, cylPaint);
    canvas.drawRect(cylRect, borderPaint);

    // Dimension Lines and Texts
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawText(
      String text,
      Offset pos, {
      Color color = Colors.white,
      double fontSize = 14,
    }) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }

    final dimPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    if (step == 1) {
      // Total Length Dimension (Top)
      double topY = cy - r - 40;
      canvas.drawLine(
        Offset(cx - h / 2 - r, topY),
        Offset(cx + h / 2 + r, topY),
        dimPaint,
      );
      canvas.drawLine(
        Offset(cx - h / 2 - r, topY - 5),
        Offset(cx - h / 2 - r, topY + 5),
        dimPaint,
      );
      canvas.drawLine(
        Offset(cx + h / 2 + r, topY - 5),
        Offset(cx + h / 2 + r, topY + 5),
        dimPaint,
      );
      drawText('14 mm', Offset(cx, topY - 15));

      // Diameter Dimension (Right side)
      double rightX = cx + h / 2 + r + 40;
      canvas.drawLine(Offset(rightX, cy - r), Offset(rightX, cy + r), dimPaint);
      canvas.drawLine(
        Offset(rightX - 5, cy - r),
        Offset(rightX + 5, cy - r),
        dimPaint,
      );
      canvas.drawLine(
        Offset(rightX - 5, cy + r),
        Offset(rightX + 5, cy + r),
        dimPaint,
      );
      drawText('5 mm', Offset(rightX + 25, cy));
    }

    if (step >= 3) {
      // Radius Dimension (Left Hemisphere)
      canvas.drawLine(
        Offset(leftHemiCenter.dx, leftHemiCenter.dy),
        Offset(leftHemiCenter.dx, leftHemiCenter.dy - r),
        dimPaint,
      );
      drawText(
        'r = 2.5',
        Offset(leftHemiCenter.dx - 35, leftHemiCenter.dy - r / 2),
        color: const Color(0xFF6ee7b7),
      );

      // Cylinder Length Dimension (Bottom)
      double botY = cy + r + 40;
      canvas.drawLine(
        Offset(cx - h / 2, botY),
        Offset(cx + h / 2, botY),
        dimPaint,
      );
      canvas.drawLine(
        Offset(cx - h / 2, botY - 5),
        Offset(cx - h / 2, botY + 5),
        dimPaint,
      );
      canvas.drawLine(
        Offset(cx + h / 2, botY - 5),
        Offset(cx + h / 2, botY + 5),
        dimPaint,
      );
      drawText(
        'h = 9 mm',
        Offset(cx, botY + 15),
        color: const Color(0xFF93c5fd),
      );

      // Radius Dimension (Right Hemisphere)
      canvas.drawLine(
        Offset(rightHemiCenter.dx, rightHemiCenter.dy),
        Offset(rightHemiCenter.dx + r, rightHemiCenter.dy),
        dimPaint,
      );
      drawText(
        'r = 2.5',
        Offset(rightHemiCenter.dx + r / 2, rightHemiCenter.dy + 15),
        color: const Color(0xFF6ee7b7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CapsulePainter oldDelegate) {
    return oldDelegate.splitOffset != splitOffset || oldDelegate.step != step;
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
                    border: Border.all(color: const Color(0x80ec4899)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66ec4899), blurRadius: 60),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFf472b6),
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
                          border: Border.all(color: const Color(0x80ec4899)),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Area = 220 mm²',
                            style: TextStyle(
                              color: Color(0xFFfbcfe8),
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
                          backgroundColor: const Color(0xFFec4899),
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
                        BoxShadow(color: Color(0x4Dec4899), blurRadius: 40),
                      ],
                    ),
                    child: const Icon(
                      Icons.vaccines,
                      size: 64,
                      color: Color(0xFFf472b6),
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
                      backgroundColor: const Color(0xFFec4899),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 20,
                      shadowColor: const Color(0xFFec4899),
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
