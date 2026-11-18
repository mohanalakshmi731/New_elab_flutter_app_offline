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

// --- I18N शब्दकोश ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE COIN FLIPPER',
    'tagline': 'EMPIRICAL VS THEORETICAL',
    'init_btn': 'INITIALIZE SIMULATION',
    'header_title': 'The Coin Flipper',
    'header_subtitle': 'CLASS 10 • PROBABILITY',
    'th_outcome': 'Outcome',
    'th_freq': 'Frequency (f)',
    'th_prob': 'Empirical P(E)',
    'cel_title': 'EXPERIMENT COMPLETE!',
    'cel_msg': 'Law of Large Numbers Verified',
    'btn_restart': 'Restart Simulation',
    'phase_label': 'SIMULATION PHASE',
    'step_label': 'Stage',
    'mission_log': 'Console Log',
    'active_mission': 'Current Objective',
    's1_t': 'Step 1: The Fair Coin',
    's1_i':
        'A standard coin has 2 equally likely outcomes: Heads (H) or Tails (T).',
    's1_b': 'Analyze Coin',
    's2_t': 'Step 2: Theoretical Probability',
    's2_i':
        'What is the exact theoretical probability of getting Heads? \n\nP(H) = Favorable / Total = 1 / 2 = 0.5',
    's2_b': 'Acknowledge Theory',
    's3_t': 'Step 3: The First Flip',
    's3_i':
        'Let\'s test reality. Tap the coin or the button below to flip it once. Observe the outcome.',
    's3_b': 'Flip Coin (1x)',
    's4_t': 'Step 4: Small Sample (10 Flips)',
    's4_i':
        'Flip the coin 10 times. Notice how the Empirical P(H) might not perfectly match 0.5.',
    's4_b': 'Auto-Flip (10x)',
    's5_t': 'Step 5: Large Sample (100 Flips)',
    's5_i':
        'Now, let\'s invoke the Law of Large Numbers. Run a rapid batch of 100 flips.',
    's5_b': 'Auto-Flip (100x)',
    's6_t': 'Step 6: Massive Sample (1000 Flips)',
    's6_i':
        'Run 1000 flips! Watch the Empirical Probability converge extremely close to 0.50.',
    's6_b': 'Mega-Flip (1000x)',
    's7_t': 'Step 7: Conclusion',
    's7_i':
        'The more trials we run, the closer Empirical reality matches Theoretical math.',
    's7_b': 'Complete Analysis',
    'stat_total': 'Total Flips',
    'stat_heads': 'Heads (H)',
    'stat_tails': 'Tails (T)',
    'stat_ep': 'Empirical P(H)',
    'stat_tp': 'Theoretical P(H)',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Outcome Frequencies',
    'dash_title': '2. Live Dashboard',
    'objective_desc':
        'The more trials we run, the closer Empirical reality matches Theoretical math.',
  },
  'hi': {
    'app_title': 'सिक्का उछालना',
    'tagline': 'प्रायोगिक बनाम सैद्धांतिक',
    'init_btn': 'सिमुलेशन शुरू करें',
    'header_title': 'सिक्का उछालना',
    'header_subtitle': 'कक्षा 10 • प्रायिकता',
    'th_outcome': 'परिणाम',
    'th_freq': 'बारंबारता (f)',
    'th_prob': 'प्रायोगिक P(E)',
    'cel_title': 'प्रयोग पूर्ण!',
    'cel_msg': 'बड़ी संख्याओं का नियम सत्यापित',
    'btn_restart': 'पुनः आरंभ करें',
    'phase_label': 'सिमुलेशन चरण',
    'step_label': 'चरण',
    'mission_log': 'कंसोल लॉग',
    'active_mission': 'वर्तमान उद्देश्य',
    's1_t': 'चरण 1: निष्पक्ष सिक्का',
    's1_i': 'एक मानक सिक्के के 2 समान परिणाम होते हैं: चित (H) या पट (T)।',
    's1_b': 'सिक्के का विश्लेषण करें',
    's2_t': 'चरण 2: सैद्धांतिक प्रायिकता',
    's2_i':
        'चित (Heads) आने की सैद्धांतिक प्रायिकता क्या है? \n\nP(H) = अनुकूल / कुल = 1 / 2 = 0.5',
    's2_b': 'सिद्धांत स्वीकार करें',
    's3_t': 'चरण 3: पहली उछाल',
    's3_i':
        'आइए वास्तविकता का परीक्षण करें। एक बार उछालने के लिए सिक्के या नीचे दिए गए बटन पर टैप करें।',
    's3_b': 'सिक्का उछालें (1x)',
    's4_t': 'चरण 4: छोटा नमूना (10 उछाल)',
    's4_i':
        'सिक्के को 10 बार उछालें। ध्यान दें कि प्रायोगिक P(H) 0.5 से कैसे अलग हो सकता है।',
    's4_b': 'ऑटो-फ्लिप (10x)',
    's5_t': 'चरण 5: बड़ा नमूना (100 उछाल)',
    's5_i': 'अब 100 उछालों का एक तीव्र बैच चलाएं।',
    's5_b': 'ऑटो-फ्लिप (100x)',
    's6_t': 'चरण 6: विशाल नमूना (1000 उछाल)',
    's6_i':
        '1000 उछाल चलाएँ! प्रायोगिक प्रायिकता को 0.50 के बेहद करीब आते हुए देखें।',
    's6_b': 'मेगा-फ्लिप (1000x)',
    's7_t': 'चरण 7: निष्कर्ष',
    's7_i':
        'हम जितने अधिक परीक्षण चलाएंगे, प्रायोगिक वास्तविकता सैद्धांतिक गणित के उतनी ही करीब होगी।',
    's7_b': 'विश्लेषण पूर्ण करें',
    'stat_total': 'कुल उछाल',
    'stat_heads': 'चित (H)',
    'stat_tails': 'पट (T)',
    'stat_ep': 'प्रायोगिक P(H)',
    'stat_tp': 'सैद्धांतिक P(H)',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. परिणाम बारंबारता',
    'dash_title': '2. लाइव डैशबोर्ड',
    'objective_desc':
        'हम जितने अधिक परीक्षण चलाएंगे, प्रायोगिक वास्तविकता सैद्धांतिक गणित के उतनी ही करीब होगी।',
  },
};

// --- स्थिति प्रबंधन (State Management) ---
class AppState extends ChangeNotifier {
  bool isInitialized = false;
  String lang = 'en';

  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  int step = 1;

  int totalFlips = 0;
  int headsCount = 0;
  int tailsCount = 0;

  int flipTrigger = 0;
  int pendingFlips = 0;
  bool isFlipping = false;
  String finalFace = 'H';

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
    if (step < 8 && !isFlipping) {
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

  void requestFlip(int count) {
    if (isFlipping) return;

    AudioManager.playClick();
    pendingFlips = count;
    isFlipping = true;
    flipTrigger++;
    notifyListeners();
  }

  void onFlipComplete() {
    int h = 0;
    int t = 0;
    final rand = math.Random();

    for (int i = 0; i < pendingFlips; i++) {
      if (rand.nextBool()) {
        h++;
      } else {
        t++;
      }
    }

    headsCount += h;
    tailsCount += t;
    totalFlips += pendingFlips;

    if (pendingFlips == 1) {
      finalFace = h == 1 ? 'H' : 'T';
    } else {
      finalFace = rand.nextBool() ? 'H' : 'T';
    }

    isFlipping = false;
    pendingFlips = 0;
    notifyListeners();

    if (step == 3 && totalFlips >= 1) nextStep();
    if (step == 4 && totalFlips >= 11) nextStep();
    if (step == 5 && totalFlips >= 111) nextStep();
    if (step == 6 && totalFlips >= 1111) nextStep();
  }

  void resetLab() {
    step = 1;
    lang = 'en'; // Force resets language back to English
    totalFlips = 0;
    headsCount = 0;
    tailsCount = 0;
    isFlipping = false;
    finalFace = 'H';
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

class CoinFlipperApp extends StatefulWidget {
  const CoinFlipperApp({super.key});

  @override
  State<CoinFlipperApp> createState() => _CoinFlipperAppState();
}

class _CoinFlipperAppState extends State<CoinFlipperApp> {
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
                opacity: 0.1,
                child: CustomPaint(painter: GridPainter()),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [Color(0x001e293b), Color(0xFF020617)],
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
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(5000),
                minScale: 0.5,
                maxScale: 4.0,
                child: VisualizerArea(state: state),
              ),
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
                  color: const Color(0xFFeab308),
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
                  color: const Color(0xFF38bdf8),
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
                            colors: [Color(0xFFeab308), Color(0xFFd97706)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4Deab308), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(
                          Icons.monetization_on,
                          color: Colors.black87,
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
                                color: Color(0xFFfde047),
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
                                      ? const Color(0xFFeab308)
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
                        "${state.t('step_label')} ${math.min(state.step, 7)}/7",
                        style: const TextStyle(
                          color: Color(0xFFeab308),
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
                    color: const Color(0xFFeab308),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFeab308),
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
                              ? const Color(0xFFeab308).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFeab308)
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
                                            ? const Color(0xFFeab308)
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
                                  color: Color(0xFFfef08a),
                                  height: 1.4,
                                ),
                              ),
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

  // --- RIGHT SIDEBAR (Calculations & Data Table) ---
  Widget _buildRightPanel() {
    double ep = state.totalFlips > 0
        ? state.headsCount / state.totalFlips
        : 0.0;
    double tp = 0.5;
    bool isConverged = state.totalFlips > 50 && (ep - tp).abs() < 0.05;

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
                const Icon(Icons.data_usage, color: Color(0xFF38bdf8)),
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
                    state.t('dash_title'),
                    style: const TextStyle(
                      color: Color(0xFFeab308),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // DASHBOARD OVERLAY (Live Stats)
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _statCard(
                            state.t('stat_total'),
                            state.totalFlips.toString(),
                            const Color(0xFF3b82f6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            state.t('stat_ep'),
                            ep.toStringAsFixed(3),
                            isConverged
                                ? const Color(0xFF10b981)
                                : const Color(0xFFeab308),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            state.t('stat_tp'),
                            '0.500',
                            const Color(0xFF94a3b8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    state.t('data_table_title'),
                    style: const TextStyle(
                      color: Color(0xFF38bdf8),
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
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 16,
                          columns: [
                            DataColumn(
                              label: Text(
                                state.t('th_outcome'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_freq'),
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
                                  color: Color(0xFF38bdf8),
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                const DataCell(
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.face,
                                        size: 16,
                                        color: Color(0xFFeab308),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Heads (H)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${state.headsCount}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    state.totalFlips > 0
                                        ? (state.headsCount / state.totalFlips)
                                              .toStringAsFixed(3)
                                        : '0.000',
                                    style: const TextStyle(
                                      color: Color(0xFF38bdf8),
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            DataRow(
                              cells: [
                                const DataCell(
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.eco,
                                        size: 16,
                                        color: Color(0xFF94a3b8),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Tails (T)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${state.tailsCount}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    state.totalFlips > 0
                                        ? (state.tailsCount / state.totalFlips)
                                              .toStringAsFixed(3)
                                        : '0.000',
                                    style: const TextStyle(
                                      color: Color(0xFF38bdf8),
                                      fontFamily: 'monospace',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xE60f172a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94a3b8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- पुन: प्रयोज्य नियंत्रण बटन (Reusable Control Button) ---
class StepControllerBtn extends StatelessWidget {
  final AppState state;
  const StepControllerBtn({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    int currentStep = math.min(state.step, 7);

    if (currentStep == 1 || currentStep == 2) {
      return _primaryBtn(
        state.t('s${currentStep}_b'),
        const Color(0xFFeab308),
        state.nextStep,
      );
    } else if (currentStep == 3) {
      return _primaryBtn(state.t('s3_b'), const Color(0xFFeab308), () {
        state.requestFlip(1);
        if (!state.isRightPanelOpen) state.toggleRightPanel();
      }, loading: state.isFlipping);
    } else if (currentStep == 4) {
      return _primaryBtn(state.t('s4_b'), const Color(0xFFeab308), () {
        state.requestFlip(10);
        if (!state.isRightPanelOpen) state.toggleRightPanel();
      }, loading: state.isFlipping);
    } else if (currentStep == 5) {
      return _primaryBtn(state.t('s5_b'), const Color(0xFFeab308), () {
        state.requestFlip(100);
        if (!state.isRightPanelOpen) state.toggleRightPanel();
      }, loading: state.isFlipping);
    } else if (currentStep == 6) {
      return _primaryBtn(state.t('s6_b'), const Color(0xFFeab308), () {
        state.requestFlip(1000);
        if (!state.isRightPanelOpen) state.toggleRightPanel();
      }, loading: state.isFlipping);
    } else {
      return _primaryBtn(
        state.t('s7_b'),
        const Color(0xFFeab308),
        state.nextStep,
      );
    }
  }

  Widget _primaryBtn(
    String text,
    Color color,
    VoidCallback onTap, {
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black, // एम्बर बटन पर गहरा पाठ
          disabledBackgroundColor: color.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              ),
            if (loading) const SizedBox(width: 12),
            Text(
              loading
                  ? (state.lang == 'hi' ? 'उछाल रहा है...' : 'FLIPPING...')
                  : text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (!loading) const SizedBox(width: 8),
            if (!loading) const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}

// --- फ़्लोटिंग मिशन कार्ड (Floating Mission Card) ---
class FloatingMissionCard extends StatelessWidget {
  final AppState state;
  const FloatingMissionCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEE0f172a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFeab308).withOpacity(0.5)),
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
              color: Color(0xFFeab308),
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
          StepControllerBtn(state: state),
        ],
      ),
    );
  }
}

// --- विज़ुअलाइज़र क्षेत्र (VISUALIZER AREA) ---
class VisualizerArea extends StatelessWidget {
  final AppState state;
  const VisualizerArea({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: const Alignment(0, 0.4), // 20% from bottom
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(1.3),
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x4Deab308),
                      width: 2,
                    ),
                    gradient: const RadialGradient(
                      colors: [Color(0x33eab308), Colors.transparent],
                      radius: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1Aeab308), blurRadius: 50),
                    ],
                  ),
                ),
              ),
            ),

            // सिक्का (The Coin)
            AnimatedCoin(state: state),
          ],
        );
      },
    );
  }
}

class AnimatedCoin extends StatefulWidget {
  final AppState state;
  const AnimatedCoin({super.key, required this.state});

  @override
  State<AnimatedCoin> createState() => _AnimatedCoinState();
}

class _AnimatedCoinState extends State<AnimatedCoin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  late Animation<double> _heightAnim;

  int _lastTrigger = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotationAnim = Tween<double>(
      begin: 0,
      end: math.pi * 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc));
    _heightAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 150,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 150,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.state.onFlipComplete();
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedCoin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.flipTrigger != _lastTrigger) {
      _lastTrigger = widget.state.flipTrigger;

      if (widget.state.pendingFlips > 10) {
        _controller.duration = const Duration(milliseconds: 2500);
        _rotationAnim = Tween<double>(begin: 0, end: math.pi * 30).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc),
        );
      } else {
        _controller.duration = const Duration(milliseconds: 1500);
        _rotationAnim = Tween<double>(begin: 0, end: math.pi * 10).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc),
        );
      }

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.state.step == 3 && !widget.state.isFlipping) {
          widget.state.requestFlip(1);
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double angle = _rotationAnim.value;

          if (!_controller.isAnimating) {
            angle = widget.state.finalFace == 'H' ? 0 : math.pi;
          }

          bool isHeads =
              (angle % (2 * math.pi)) < math.pi / 2 ||
              (angle % (2 * math.pi)) > 3 * math.pi / 2;

          return Transform.translate(
            offset: Offset(0, -_heightAnim.value),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(angle),
              alignment: Alignment.center,
              child: isHeads
                  ? _buildFace('H', const Color(0xFFeab308))
                  : _buildFace('T', const Color(0xFF94a3b8), flip: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFace(String label, Color color, {bool flip = false}) {
    Widget content = Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF020617),
        border: Border.all(color: color, width: 6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'H' ? Icons.face : Icons.eco,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );

    if (flip) {
      return Transform(
        transform: Matrix4.identity()..rotateX(math.pi),
        alignment: Alignment.center,
        child: content,
      );
    }
    return content;
  }
}

// --- ओवरले (OVERLAYS) ---
class CelebrationOverlay extends StatelessWidget {
  final AppState state;
  const CelebrationOverlay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    double ep = state.totalFlips > 0
        ? state.headsCount / state.totalFlips
        : 0.0;

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
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xEB0f172a),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x80eab308)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66eab308), blurRadius: 60),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFfde047),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.t('cel_msg'),
                        style: const TextStyle(
                          color: Color(0xFFcbd5e1),
                          fontSize: 16,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _resultBox(
                              state.lang == 'hi' ? 'सैद्धांतिक' : 'Theoretical',
                              '0.500',
                              const Color(0xFF94a3b8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.compare_arrows,
                            color: Colors.white54,
                            size: 32,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _resultBox(
                              state.lang == 'hi' ? 'प्रायोगिक' : 'Empirical',
                              ep.toStringAsFixed(3),
                              const Color(0xFF10b981),
                            ),
                          ),
                        ],
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
                          backgroundColor: const Color(0xFFeab308),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
            ),
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 24,
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
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFF020617),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: CustomPaint(painter: GridPainter())),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x4Deab308), blurRadius: 40),
                        ],
                      ),
                      child: const Icon(
                        Icons.monetization_on,
                        size: 64,
                        color: Color(0xFFfde047),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.t('app_title'),
                      style: const TextStyle(
                        fontSize: 48,
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
                        backgroundColor: const Color(0xFFeab308),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 20,
                        shadowColor: const Color(0xFFeab308),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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
