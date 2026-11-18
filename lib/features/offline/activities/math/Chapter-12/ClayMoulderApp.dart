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
    'app_title': 'THE CLAY MOULDER',
    'tagline': 'CONSERVATION OF VOLUME',
    'init_btn': 'INITIALIZE WORKSHOP',
    'header_title': 'The Clay Moulder',
    'header_subtitle': 'CLASS 10 • MENSURATION',
    'phase_label': 'MOULDING PHASE',
    'step_label': 'Stage',
    'active_mission': 'Current Objective',
    'th_shape': 'Shape',
    'th_radius': 'Radius (r)',
    'th_height': 'Height (h)',
    'th_volume': 'Volume Formula',
    'cel_title': 'SHAPE REFINED!',
    'cel_msg': 'The Sphere radius was calculated successfully.',
    'btn_restart': 'Restart Workshop',
    's1_t': 'Step 1: The Original Shape',
    's1_i':
        'Observe the clay shaped as a Cone. It has a radius of 6 cm and a height of 24 cm.',
    's1_b': 'Analyze Cone',
    's2_t': 'Step 2: The Moulding Process',
    's2_i': 'We will now completely reshape this clay into a perfect Sphere.',
    's2_b': 'Mould into Sphere',
    's3_t': 'Step 3: Conservation of Volume',
    's3_i':
        'Since no clay was added or removed, the Volume of the Cone strictly equals the Volume of the Sphere.',
    's3_b': 'Acknowledge Principle',
    's4_t': 'Step 4: Formula Assembly',
    's4_i':
        'Open the Data Panel. We must equate both volume formulas: 1/3 π r² h = 4/3 π R³.',
    's4_b': 'ASSEMBLE FORMULA',
    's5_t': 'Step 5: Final Computation',
    's5_i': 'Use algebra to solve for R (the radius of the new sphere).',
    's5_b': 'Calculate Radius',
    'msg_populate': 'Populate formula below',
    'status_locked': 'Locked',
    'status_calc': 'Calculate',
    'calc_step_1_t': 'Equate Volumes',
    'calc_step_2_t': 'Cancel Common Terms (π, /3)',
    'calc_step_3_t': 'Substitute Values',
    'calc_step_4_t': 'Solve for R',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Component Dimensions',
    'formula_title': '2. Conservation Equation',
    'math_engine_title': '3. Algebraic Solver',
    'objective_desc':
        'Understand that reshaping a solid object conserves its overall volume, allowing us to find unknown dimensions.',
  },
  'hi': {
    'app_title': 'मिट्टी मोल्डर',
    'tagline': 'आयतन का संरक्षण',
    'init_btn': 'वर्कशॉप शुरू करें',
    'header_title': 'मिट्टी मोल्डर',
    'header_subtitle': 'कक्षा 10 • क्षेत्रमिति',
    'phase_label': 'मोल्डिंग चरण',
    'step_label': 'चरण',
    'active_mission': 'वर्तमान उद्देश्य',
    'th_shape': 'आकार',
    'th_radius': 'त्रिज्या (r)',
    'th_height': 'ऊंचाई (h)',
    'th_volume': 'आयतन सूत्र',
    'cel_title': 'आकार तैयार!',
    'cel_msg': 'गोले की त्रिज्या की सफलतापूर्वक गणना की गई।',
    'btn_restart': 'पुनः आरंभ करें',
    's1_t': 'चरण 1: मूल आकार',
    's1_i':
        'शंकु (Cone) के आकार की मिट्टी को देखें। इसकी त्रिज्या 6 सेमी और ऊंचाई 24 सेमी है।',
    's1_b': 'शंकु का विश्लेषण करें',
    's2_t': 'चरण 2: मोल्डिंग प्रक्रिया',
    's2_i':
        'अब हम इस मिट्टी को पूरी तरह से एक पूर्ण गोले (Sphere) में बदल देंगे।',
    's2_b': 'गोले में बदलें',
    's3_t': 'चरण 3: आयतन का संरक्षण',
    's3_i':
        'चूंकि कोई मिट्टी नहीं जोड़ी या हटाई गई है, इसलिए शंकु का आयतन गोले के आयतन के बराबर है।',
    's3_b': 'सिद्धांत स्वीकार करें',
    's4_t': 'चरण 4: सूत्र संयोजन',
    's4_i':
        'डेटा पैनल खोलें। हमें दोनों आयतन सूत्रों को बराबर करना होगा: 1/3 π r² h = 4/3 π R³.',
    's4_b': 'सूत्र संयोजित करें',
    's5_t': 'चरण 5: अंतिम गणना',
    's5_i': 'R (नए गोले की त्रिज्या) के लिए बीजगणित का उपयोग करके हल करें।',
    's5_b': 'त्रिज्या की गणना करें',
    'msg_populate': 'नीचे सूत्र भरें',
    'status_locked': 'लॉक्ड',
    'status_calc': 'गणना करें',
    'calc_step_1_t': 'आयतन बराबर करें',
    'calc_step_2_t': 'सामान्य पदों (π, /3) को काटें',
    'calc_step_3_t': 'मान रखें',
    'calc_step_4_t': 'R के लिए हल करें',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. घटक आयाम',
    'formula_title': '2. संरक्षण समीकरण',
    'math_engine_title': '3. बीजगणितीय सॉल्वर',
    'objective_desc':
        'यह समझें कि किसी ठोस वस्तु को नया आकार देने से उसका आयतन संरक्षित रहता है, जिससे हमें अज्ञात आयाम ज्ञात करने में मदद मिलती है।',
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

  Map<String, bool> filledSlots = {'vol_cone': false, 'vol_sphere': false};

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
    filledSlots = {'vol_cone': false, 'vol_sphere': false};
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

class ClayMoulderApp extends StatefulWidget {
  const ClayMoulderApp({super.key});

  @override
  State<ClayMoulderApp> createState() => _ClayMoulderAppState();
}

class _ClayMoulderAppState extends State<ClayMoulderApp> {
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
    double panelWidth = (screenWidth * 0.38).clamp(320.0, 500.0); // Exactly 38%

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
              // Menu Button (Top Left)
              Positioned(
                top: 20,
                left: 20,
                child: _buildFloatingActionBtn(
                  icon: state.isLeftPanelOpen ? Icons.menu_open : Icons.menu,
                  onTap: state.toggleLeftPanel,
                  color: const Color(0xFFf59e0b), // Amber
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
                  color: const Color(0xFFfbbf24), // Amber lighter
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
                            colors: [Color(0xFFf59e0b), Color(0xFFb45309)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4Df59e0b), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(
                          Icons.change_circle,
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
                        "${state.t('step_label')} ${math.min(state.step, 5)}/5",
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
                    value: math.min(state.step, 5) / 5,
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
              padding: const EdgeInsets.all(20.0),
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
                                state.t('th_shape'),
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
                                state.t('th_height'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_volume'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>(
                                (states) => const Color(0x33ef4444),
                              ),
                              cells: [
                                DataCell(
                                  Text(
                                    state.lang == 'hi' ? 'शंकु' : 'Cone',
                                    style: const TextStyle(
                                      color: Color(0xFFfca5a5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const DataCell(
                                  Text(
                                    '6 cm',
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
                                    '24 cm',
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
                                    '1/3 π r² h',
                                    style: TextStyle(
                                      color: Color(0xFFfca5a5),
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (state.step >= 2)
                              DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (states) => const Color(0x333b82f6),
                                ),
                                cells: [
                                  DataCell(
                                    Text(
                                      state.lang == 'hi' ? 'गोला' : 'Sphere',
                                      style: const TextStyle(
                                        color: Color(0xFF93c5fd),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      state.step >= 5 ? '6 cm' : 'R = ?',
                                      style: TextStyle(
                                        color: state.step >= 5
                                            ? Colors.white
                                            : const Color(0xFF93c5fd),
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
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '4/3 π R³',
                                      style: TextStyle(
                                        color: Color(0xFF93c5fd),
                                        fontSize: 13,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
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
                        color: Color(0xFFf59e0b),
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
                          border: Border.all(color: const Color(0x80f59e0b)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _mathRow(
                              'Vol(Cone) =',
                              'Vol(Sphere)',
                              const Color(0xFF94a3b8),
                            ),
                            _mathRow(
                              '1/3 π r² h =',
                              '4/3 π R³',
                              const Color(0xFFcbd5e1),
                            ),

                            const SizedBox(height: 12),

                            if (state.step >= 5) ...[
                              _calcStageItem(
                                0,
                                state.t('calc_step_2_t'),
                                'r² h = 4 R³',
                                'Multiply by 3/π',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                1,
                                state.t('calc_step_3_t'),
                                '(6)² × 24 = 4 R³',
                                'r = 6, h = 24',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                2,
                                state.t('calc_step_3_t') + ' II',
                                '36 × 24 = 4 R³',
                                '864 = 4 R³',
                                state,
                              ),
                              const SizedBox(height: 8),
                              _calcStageItem(
                                3,
                                state.t('calc_step_4_t'),
                                'R = 6 cm',
                                'R³ = 216 ➔ R = ∛216',
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
        ? const Color(0xFFf59e0b)
        : const Color(0x801e293b);
    Color borderColor = isDone
        ? const Color(0x6610b981)
        : isActive
        ? const Color(0xFFfcd34d)
        : const Color(0x80334155);
    Color textColor = isDone
        ? const Color(0xFF34d399)
        : isActive
        ? Colors.black
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
              ? [const BoxShadow(color: Color(0x80f59e0b), blurRadius: 10)]
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
                  color: textColor.withOpacity(isActive ? 0.8 : 0.7),
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
        const Color(0xFFf59e0b),
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
          foregroundColor: Colors.black,
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
                  '${state.step}/5',
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
                _slot('vol_cone', 'Vol of Cone', state, wide: true),
                const Text(
                  ' = ',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                _slot('vol_sphere', 'Vol of Sphere', state, wide: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _bankBtn('Vol of Cone (1/3 πr²h)', 'vol_cone', Colors.red, state),
              _bankBtn(
                'Vol of Sphere (4/3 πR³)',
                'vol_sphere',
                Colors.blue,
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
      if (key == 'vol_cone') val = '1/3 π r² h';
      if (key == 'vol_sphere') val = '4/3 π R³';
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
              children: [ClayWidget(state: state)],
            ),
          ),
        );
      },
    );
  }
}

class ClayWidget extends StatelessWidget {
  final AppState state;
  const ClayWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Determine the morph progress based on step
    double mouldProgress = state.step >= 2 ? 1.0 : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: mouldProgress),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOutCubic,
      builder: (context, progress, child) {
        return CustomPaint(
          size: const Size(600, 400),
          painter: ClayPainter(mouldProgress: progress, step: state.step),
        );
      },
    );
  }
}

class ClayPainter extends CustomPainter {
  final double mouldProgress;
  final int step;

  ClayPainter({required this.mouldProgress, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2 + 50; // Shift down slightly

    // Base units (1 unit = 8 pixels)
    final double rCone = 6 * 8; // 48
    final double hCone = 24 * 8; // 192

    final double rSphere = 6 * 8; // 48

    final Paint clayPaint = Paint()
      ..color =
          const Color(0xFFd97706) // Terracotta Clay Color
      ..style = PaintingStyle.fill;

    // Morphing Interpolations
    double currentRCone = rCone + (rSphere - rCone) * mouldProgress;
    // Cone height squashes down to sphere diameter
    double currentHCone = hCone - (hCone - rSphere * 2) * mouldProgress;

    // Top point of the shape moving down
    double topY = cy - currentHCone;

    Path shapePath = Path();

    // If progress is low, it's mostly a cone. If high, it rounds out to a sphere.
    // We can simulate the morph by curving the sides of the triangle outwards as it squashes down.
    double controlPointOutward = mouldProgress * (rSphere * 1.5);

    shapePath.moveTo(cx, topY); // Apex (or top of sphere)
    shapePath.quadraticBezierTo(
      cx + controlPointOutward,
      topY + currentHCone / 2,
      cx + currentRCone,
      cy,
    ); // Right side

    // Base Curve (Cone base is an ellipse in 3D, Sphere is a semi-circle)
    double baseControlDrop = 15 * (1 - mouldProgress) + rSphere * mouldProgress;
    shapePath.quadraticBezierTo(
      cx,
      cy + baseControlDrop,
      cx - currentRCone,
      cy,
    );

    shapePath.quadraticBezierTo(
      cx - controlPointOutward,
      topY + currentHCone / 2,
      cx,
      topY,
    ); // Left side

    // Draw Drop shadow
    Path shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCenter(
        center: Offset(cx, cy + baseControlDrop / 2 + 10),
        width: currentRCone * 2.2,
        height: 20,
      ),
    );
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Draw the Clay Shape
    canvas.drawPath(shapePath, clayPaint);

    // Give it a 3D gradient look
    final Rect bounds = shapePath.getBounds();
    final Paint gradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.transparent,
          Colors.black.withOpacity(0.4),
        ],
      ).createShader(bounds)
      ..blendMode = BlendMode.srcATop;
    canvas.drawPath(shapePath, gradientPaint);

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

    // Only draw dimensions if it's purely a Cone (step 1) or purely a Sphere (step >= 5)
    if (mouldProgress == 0.0) {
      // Radius Dimension (Cone)
      canvas.drawLine(Offset(cx, cy), Offset(cx + rCone, cy), dimPaint);
      canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
      drawText(
        'r = 6 cm',
        Offset(cx + rCone / 2, cy - 15),
        color: const Color(0xFFfca5a5),
      );

      // Height Dimension (Cone)
      double rightX = cx + rCone + 30;
      canvas.drawLine(Offset(rightX, topY), Offset(rightX, cy), dimPaint);
      canvas.drawLine(
        Offset(rightX - 5, topY),
        Offset(rightX + 5, topY),
        dimPaint,
      );
      canvas.drawLine(Offset(rightX - 5, cy), Offset(rightX + 5, cy), dimPaint);
      drawText(
        'h = 24 cm',
        Offset(rightX + 35, cy - hCone / 2),
        color: const Color(0xFF93c5fd),
      );
    } else if (mouldProgress == 1.0 && step >= 5) {
      // Radius Dimension (Sphere)
      canvas.drawLine(
        Offset(cx, cy - rSphere),
        Offset(cx + rSphere, cy - rSphere),
        dimPaint,
      );
      canvas.drawCircle(
        Offset(cx, cy - rSphere),
        3,
        Paint()..color = Colors.white,
      );
      drawText(
        'R = 6 cm',
        Offset(cx + rSphere / 2, cy - rSphere - 15),
        color: const Color(0xFF6ee7b7),
      );
    } else if (mouldProgress == 1.0 && step < 5) {
      // Unknown Radius Dimension (Sphere)
      canvas.drawLine(
        Offset(cx, cy - rSphere),
        Offset(cx + rSphere, cy - rSphere),
        dimPaint,
      );
      canvas.drawCircle(
        Offset(cx, cy - rSphere),
        3,
        Paint()..color = Colors.white,
      );
      drawText(
        'R = ?',
        Offset(cx + rSphere / 2, cy - rSphere - 15),
        color: const Color(0xFF94a3b8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ClayPainter oldDelegate) {
    return oldDelegate.mouldProgress != mouldProgress ||
        oldDelegate.step != step;
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
                    border: Border.all(color: const Color(0x80f59e0b)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66f59e0b), blurRadius: 60),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏺', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFfcd34d),
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
                          border: Border.all(color: const Color(0x8010b981)),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Radius = 6 cm',
                            style: TextStyle(
                              color: Color(0xFF6ee7b7),
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
                        BoxShadow(color: Color(0x4Df59e0b), blurRadius: 40),
                      ],
                    ),
                    child: const Icon(
                      Icons.architecture,
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
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: onInit,
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: Text(
                      state.t('init_btn'),
                      style: const TextStyle(
                        color: Colors.white,
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
