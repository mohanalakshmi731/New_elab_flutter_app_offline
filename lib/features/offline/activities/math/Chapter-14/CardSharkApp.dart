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
enum Suit { hearts, diamonds, clubs, spades }

enum Rank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

class PlayingCard {
  final Suit suit;
  final Rank rank;

  PlayingCard(this.suit, this.rank);

  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;
  bool get isBlack => !isRed;
  bool get isFace =>
      rank == Rank.jack || rank == Rank.queen || rank == Rank.king;

  String get symbol {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }

  Color get color => isRed ? const Color(0xFFef4444) : const Color(0xFF1e293b);

  String get rankStr {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      default:
        return (rank.index + 1).toString();
    }
  }
}

final List<PlayingCard> standardDeck = () {
  List<PlayingCard> deck = [];
  for (var suit in Suit.values) {
    for (var rank in Rank.values) {
      deck.add(PlayingCard(suit, rank));
    }
  }
  return deck;
}();

// --- I18N DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE CARD SHARK',
    'tagline': 'PROBABILITY OF THE DRAW',
    'init_btn': 'SHUFFLE DECK',
    'header_title': 'The Card Shark',
    'header_subtitle': 'CLASS 10 • PROBABILITY',
    'phase_label': 'ANALYSIS PHASE',
    'step_label': 'Stage',
    'mission_log': 'Console Log',
    'active_mission': 'Current Objective',
    'th_event': 'Event (E)',
    'th_fav': 'Favorable',
    'th_total': 'Total',
    'th_prob': 'P(E)',
    'cel_title': 'DECK MASTERED!',
    'cel_msg': 'Probability Concepts Verified',
    'btn_restart': 'Restart Simulation',
    's1_t': 'Step 1: The Standard Deck',
    's1_i':
        'A standard deck contains 52 cards. They are divided into 4 suits: Hearts, Diamonds, Clubs, and Spades.',
    's1_b': 'Analyze Deck',
    's2_t': 'Step 2: Drawing a Red Card',
    's2_i':
        'What is the probability of drawing any Red card? There are 13 Hearts and 13 Diamonds.',
    's2_b': 'Draw Red Cards',
    's3_t': 'Step 3: Drawing a Spade',
    's3_i':
        'What is the probability of drawing a Spade? Spades are one of the four suits.',
    's3_b': 'Draw Spades',
    's4_t': 'Step 4: Drawing an Ace',
    's4_i':
        'What is the probability of drawing an Ace? There is one Ace in each of the 4 suits.',
    's4_b': 'Draw Aces',
    's5_t': 'Step 5: Drawing a Face Card',
    's5_i':
        'Face cards are Jacks, Queens, and Kings. There are 3 per suit across 4 suits.',
    's5_b': 'Draw Face Cards',
    's6_t': 'Step 6: The King of Hearts',
    's6_i':
        'What is the probability of drawing specifically the King of Hearts? There is only one in the entire deck.',
    's6_b': 'Draw King of Hearts',
    's7_t': 'Step 7: Conclusion',
    's7_i':
        'By identifying the favorable outcomes out of the 52 total possible outcomes, we can calculate any theoretical probability.',
    's7_b': 'Complete Analysis',
    'calc_title': 'Calculations & Data',
    'data_table_title': '1. Probability Distribution',
    'objective_desc':
        'By identifying the favorable outcomes out of the 52 total possible outcomes, we can calculate any theoretical probability.',
  },
  'hi': {
    'app_title': 'ताश का जादूगर',
    'tagline': 'ड्रा की प्रायिकता',
    'init_btn': 'ताश फेंटें',
    'header_title': 'ताश का जादूगर',
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
    's1_t': 'चरण 1: मानक डेक',
    's1_i':
        'एक मानक डेक में 52 कार्ड होते हैं। इन्हें 4 सूट में बांटा गया है: पान, ईंट, चिड़ी और हुकुम।',
    's1_b': 'डेक का विश्लेषण करें',
    's2_t': 'चरण 2: लाल पत्ता खींचना',
    's2_i':
        'कोई भी लाल पत्ता खींचने की प्रायिकता क्या है? 13 पान और 13 ईंट के पत्ते होते हैं।',
    's2_b': 'लाल पत्ते खींचें',
    's3_t': 'चरण 3: हुकुम का पत्ता खींचना',
    's3_i':
        'हुकुम का पत्ता खींचने की प्रायिकता क्या है? हुकुम चार सूटों में से एक है।',
    's3_b': 'हुकुम के पत्ते खींचें',
    's4_t': 'चरण 4: इक्का खींचना',
    's4_i':
        'इक्का खींचने की प्रायिकता क्या है? 4 सूटों में से प्रत्येक में एक इक्का होता है।',
    's4_b': 'इक्के खींचें',
    's5_t': 'चरण 5: फेस कार्ड खींचना',
    's5_i':
        'फेस कार्ड जैक, क्वीन और किंग होते हैं। प्रत्येक सूट में 3 होते हैं।',
    's5_b': 'फेस कार्ड खींचें',
    's6_t': 'चरण 6: पान का बादशाह',
    's6_i':
        'विशेष रूप से पान का बादशाह खींचने की प्रायिकता क्या है? पूरे डेक में केवल एक होता है।',
    's6_b': 'पान का बादशाह खींचें',
    's7_t': 'चरण 7: निष्कर्ष',
    's7_i':
        '52 कुल संभावित परिणामों में से अनुकूल परिणामों की पहचान करके, हम सैद्धांतिक प्रायिकता की गणना कर सकते हैं।',
    's7_b': 'विश्लेषण पूर्ण करें',
    'calc_title': 'गणनाएँ एवं डेटा',
    'data_table_title': '1. प्रायिकता वितरण',
    'objective_desc':
        '52 कुल संभावित परिणामों में से अनुकूल परिणामों की पहचान करके, हम सैद्धांतिक प्रायिकता की गणना कर सकते हैं।',
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

  List<PlayingCard> get targetCards {
    switch (visualStep) {
      case 0:
        return [];
      case 1:
        return standardDeck;
      case 2:
        return standardDeck.where((c) => c.isRed).toList();
      case 3:
        return standardDeck.where((c) => c.suit == Suit.spades).toList();
      case 4:
        return standardDeck.where((c) => c.rank == Rank.ace).toList();
      case 5:
        return standardDeck.where((c) => c.isFace).toList();
      case 6:
        return standardDeck
            .where((c) => c.suit == Suit.hearts && c.rank == Rank.king)
            .toList();
      default:
        return standardDeck;
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
    lang = 'en'; // Reset language to English
    isLeftPanelOpen = true;
    isRightPanelOpen = false;
    isInitialized = false;
    notifyListeners();
  }

  String t(String key) {
    return i18n[lang]?[key] ?? key;
  }
}

class CardSharkApp extends StatefulWidget {
  const CardSharkApp({super.key});

  @override
  State<CardSharkApp> createState() => _CardSharkAppState();
}

class _CardSharkAppState extends State<CardSharkApp> {
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
        alignment: 0.5, // Centers the active step nicely in the view
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
                child: CustomPaint(painter: CasinoPatternPainter()),
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

            // 1. CANVAS AREA (Interactive Visualizer - adapts bounds based on panels to avoid being covered)
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
                  color: const Color(0xFF0ea5e9),
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

  // --- LEFT SIDEBAR (Mission / Controls - 40%) ---
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
                            colors: [Color(0xFF0ea5e9), Color(0xFF0284c7)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.style, color: Colors.white),
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
                                color: Color(0xFF7dd3fc),
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
                                      ? const Color(0xFF0ea5e9)
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
                          color: Color(0xFF0ea5e9),
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
                    color: const Color(0xFF0ea5e9),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // ACTIVE MISSION HEADER
                  Text(
                    state.t('active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF0ea5e9),
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
                              ? const Color(0xFF0ea5e9).withOpacity(0.1)
                              : (isDone
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF0ea5e9)
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
                                            ? const Color(0xFF0ea5e9)
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
                                  color: Color(0xFFbae6fd),
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

                  Center(
                    child: Text(
                      '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                      style: const TextStyle(
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
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          dataRowMinHeight: 32,
                          dataRowMaxHeight: 32,
                          columnSpacing: 16,
                          columns: [
                            DataColumn(
                              label: Text(
                                state.t('th_event'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_fav'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94a3b8),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                state.t('th_prob'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF38bdf8),
                                ),
                              ),
                            ),
                          ],
                          rows: List.generate(math.min(state.step, 6), (index) {
                            int stepForRow = index + 1;

                            int fav = 0;
                            if (stepForRow == 1) {
                              fav = 52;
                            } else if (stepForRow == 2) {
                              fav = 26;
                            } else if (stepForRow == 3) {
                              fav = 13;
                            } else if (stepForRow == 4) {
                              fav = 4;
                            } else if (stepForRow == 5) {
                              fav = 12;
                            } else if (stepForRow == 6) {
                              fav = 1;
                            }

                            String probStr = _getProbStr(fav, 52);
                            bool isCurrent = stepForRow == state.step;
                            bool actionExecuted = state.step > stepForRow;

                            return DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>(
                                (states) =>
                                    isCurrent ? const Color(0x330ea5e9) : null,
                              ),
                              cells: [
                                DataCell(
                                  Text(
                                    _getEventLabel(stepForRow),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                                      fontSize: 13,
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
                                          ? const Color(0xFF7dd3fc)
                                          : const Color(0xFF38bdf8),
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
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
          return 'मानक डेक';
        case 2:
          return 'लाल पत्ता';
        case 3:
          return 'हुकुम का पत्ता';
        case 4:
          return 'एक इक्का';
        case 5:
          return 'फेस कार्ड';
        case 6:
          return 'पान का बादशाह';
        default:
          return '';
      }
    } else {
      switch (step) {
        case 1:
          return 'Standard Deck';
        case 2:
          return 'Red Card';
        case 3:
          return 'A Spade';
        case 4:
          return 'An Ace';
        case 5:
          return 'Face Card';
        case 6:
          return 'King of Hearts';
        default:
          return '';
      }
    }
  }

  String _getProbStr(int fav, int total) {
    if (fav == 0) return '0';
    if (fav == total) return '1';
    int gcd = _gcd(fav, total);
    return '${fav ~/ gcd} / ${total ~/ gcd}';
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
        const Color(0xFF0ea5e9),
        state.nextStep,
      );
    } else {
      return buildPrimaryBtn(
        state.t('s${state.step}_b'),
        const Color(0xFF0ea5e9),
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
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xE60f172a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0ea5e9), width: 1.5),
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
            state.t('s${math.min(state.step, 7)}_t').toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF0ea5e9),
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

// --- VISUALIZER AREA (Interactive 3D Canvas) ---
class VisualizerArea extends StatelessWidget {
  final AppState state;
  const VisualizerArea({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        List<PlayingCard> targets = state.targetCards;
        bool isFullDeck = state.visualStep == 1;

        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(5000), // Infinite pan margin
          minScale: 0.2, // Zoom out limit
          maxScale: 4.0, // Zoom in limit
          constrained:
              false, // Ensures internal content can define its own bounds
          child: SizedBox(
            width: math.max(800.0, width),
            height: math.max(600.0, height),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Left Deck representation (when extracting cards)
                if (!isFullDeck)
                  Positioned(
                    left: 60,
                    top: math.max(600.0, height) / 2 - 50,
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        width: 60,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e293b),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF475569),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(5, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.style, color: Color(0xFF475569)),
                        ),
                      ),
                    ),
                  ),

                // Animated Cards
                ...standardDeck.map((card) {
                  bool isTarget = targets.contains(card);
                  int targetIndex = targets.indexOf(card);

                  // Calculate position
                  Offset targetOffset;
                  double targetRotation;
                  double targetScale = 1.0;
                  bool faceUp = isTarget; // Always show target face up

                  if (isFullDeck) {
                    // Fan out all 52 cards beautifully
                    int index = standardDeck.indexOf(card);
                    double angle = (index - 25.5) * 0.05; // Fan spread
                    double radius = 200;
                    targetOffset = Offset(
                      math.sin(angle) * radius,
                      -math.cos(angle) * radius + radius + 60,
                    );
                    targetRotation = angle;
                    faceUp = true;
                  } else if (isTarget) {
                    // Arrange targets in a dynamic grid
                    int cols = math.min(
                      targets.length,
                      targets.length > 13 ? 13 : 6,
                    );
                    int rows = (targets.length / cols).ceil();

                    double cardW = 50;
                    double cardH = 75;
                    double spacing = 10;

                    double startX = -((cols - 1) * (cardW + spacing)) / 2;
                    double startY = -((rows - 1) * (cardH + spacing)) / 2;

                    int c = targetIndex % cols;
                    int r = targetIndex ~/ cols;

                    // Shift grid slightly to the right to balance with the left deck
                    targetOffset = Offset(
                      startX + c * (cardW + spacing) + 30,
                      startY + r * (cardH + spacing),
                    );
                    targetRotation = 0;
                  } else {
                    // Go to the left deck stack
                    targetOffset = Offset(-math.max(800.0, width) / 2 + 90, 0);
                    targetRotation = 0;
                    faceUp = false; // Hide non-targets
                    targetScale = 0.8;
                  }

                  return AnimatedCardWidget(
                    card: card,
                    targetOffset: targetOffset,
                    targetRotation: targetRotation,
                    targetScale: targetScale,
                    faceUp: faceUp,
                    isTarget: isTarget,
                    step: state.visualStep,
                    delay: isTarget ? targetIndex * 20 : 0,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedCardWidget extends ImplicitlyAnimatedWidget {
  final PlayingCard card;
  final Offset targetOffset;
  final double targetRotation;
  final double targetScale;
  final bool faceUp;
  final bool isTarget;
  final int step;
  final int delay;

  AnimatedCardWidget({
    super.key,
    required this.card,
    required this.targetOffset,
    required this.targetRotation,
    required this.targetScale,
    required this.faceUp,
    required this.isTarget,
    required this.step,
    required this.delay,
  }) : super(
         duration: Duration(milliseconds: 600 + delay),
         curve: Curves.easeOutBack,
       );

  @override
  _AnimatedCardWidgetState createState() => _AnimatedCardWidgetState();
}

class _AnimatedCardWidgetState
    extends ImplicitlyAnimatedWidgetState<AnimatedCardWidget> {
  Tween<Offset>? _offsetTween;
  Tween<double>? _rotationTween;
  Tween<double>? _scaleTween;
  Tween<double>? _flipTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _offsetTween =
        visitor(
              _offsetTween,
              widget.targetOffset,
              (dynamic value) => Tween<Offset>(begin: value as Offset),
            )
            as Tween<Offset>?;

    _rotationTween =
        visitor(
              _rotationTween,
              widget.targetRotation,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;

    _scaleTween =
        visitor(
              _scaleTween,
              widget.targetScale,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;

    _flipTween =
        visitor(
              _flipTween,
              widget.faceUp
                  ? 0.0
                  : math.pi, // pi means back of card is facing camera
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
        double rotation =
            _rotationTween?.evaluate(animation) ?? widget.targetRotation;
        double scale = _scaleTween?.evaluate(animation) ?? widget.targetScale;
        double flip =
            _flipTween?.evaluate(animation) ?? (widget.faceUp ? 0.0 : math.pi);

        // Pseudo 3D Flip trick
        bool showFront =
            (flip % (2 * math.pi)) < (math.pi / 2) ||
            (flip % (2 * math.pi)) > (3 * math.pi / 2);

        return Transform.translate(
          offset: offset,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateZ(rotation)
              ..rotateY(flip)
              ..scale(scale),
            alignment: Alignment.center,
            child: showFront
                ? _buildCardFront()
                : Transform(
                    transform: Matrix4.identity()
                      ..rotateY(
                        math.pi,
                      ), // Unflip the back so it's not mirrored
                    alignment: Alignment.center,
                    child: _buildCardBack(),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCardFront() {
    double width = widget.step == 1 ? 55 : 50;
    double height = widget.step == 1 ? 85 : 75;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.isTarget && widget.step > 1
              ? const Color(0xFF0ea5e9)
              : const Color(0xFFe2e8f0),
          width: widget.isTarget && widget.step > 1 ? 2 : 1,
        ),
        boxShadow: widget.isTarget && widget.step > 1
            ? [
                const BoxShadow(
                  color: Color(0x4D0ea5e9),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
      ),
      child: Stack(
        children: [
          // Top Left
          Positioned(
            left: 4,
            top: 4,
            child: Column(
              children: [
                Text(
                  widget.card.rankStr,
                  style: TextStyle(
                    color: widget.card.color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  widget.card.symbol,
                  style: TextStyle(
                    color: widget.card.color,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          // Bottom Right (Upside down)
          Positioned(
            right: 4,
            bottom: 4,
            child: Transform.rotate(
              angle: math.pi,
              child: Column(
                children: [
                  Text(
                    widget.card.rankStr,
                    style: TextStyle(
                      color: widget.card.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Text(
                    widget.card.symbol,
                    style: TextStyle(
                      color: widget.card.color,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Center Graphic
          Center(
            child: widget.card.isFace
                ? Container(
                    width: width * 0.5,
                    height: height * 0.5,
                    decoration: BoxDecoration(
                      color: widget.card.color.withOpacity(0.1),
                      border: Border.all(color: widget.card.color),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        widget.card.rankStr,
                        style: TextStyle(
                          color: widget.card.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                : Text(
                    widget.card.symbol,
                    style: TextStyle(color: widget.card.color, fontSize: 24),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    double width = widget.step == 1 ? 55 : 50;
    double height = widget.step == 1 ? 85 : 75;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0ea5e9), width: 1),
            image: const DecorationImage(
              image: AssetImage('assets/images/offline_texture.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.3,
            ),
          ),
          child: const Center(
            child: Icon(Icons.style, color: Color(0xFF0ea5e9), size: 20),
          ),
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
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xEB0f172a),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x800ea5e9)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x660ea5e9), blurRadius: 60),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🃏', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 6),
                      Text(
                        state.t('cel_title'),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7dd3fc),
                        ),
                      ),
                      Text(
                        state.t('cel_msg'),
                        style: const TextStyle(
                          color: Color(0xFFcbd5e1),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double width = constraints.maxWidth;

                          bool isMobile = width < 600;
                          bool isTablet = width >= 600 && width < 1024;

                          final items = [
                            _resultBox(
                              'Total Cards',
                              '52',
                              const Color(0xFF94a3b8),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10b981),
                              size: 40,
                            ),
                            _resultBox(
                              'P(King ♥)',
                              '1/52',
                              const Color(0xFF0ea5e9),
                            ),
                          ];

                          // MOBILE
                          if (isMobile) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:
                                  items
                                      .expand(
                                        (e) => [e, const SizedBox(height: 16)],
                                      )
                                      .toList()
                                    ..removeLast(),
                            );
                          }

                          // TABLET
                          if (isTablet) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  items
                                      .expand(
                                        (e) => [
                                          Flexible(child: e),
                                          const SizedBox(width: 16),
                                        ],
                                      )
                                      .toList()
                                    ..removeLast(),
                            );
                          }

                          // DESKTOP
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children:
                                    items
                                        .expand(
                                          (e) => [
                                            Expanded(child: e),
                                            const SizedBox(width: 24),
                                          ],
                                        )
                                        .toList()
                                      ..removeLast(),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
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
                          backgroundColor: const Color(0xFF0ea5e9),
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
          CustomPaint(painter: CasinoPatternPainter(), size: Size.infinite),
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
                    BoxShadow(color: Color(0x4D0ea5e9), blurRadius: 40),
                  ],
                ),
                child: const Icon(
                  Icons.style,
                  size: 64,
                  color: Color(0xFF38bdf8),
                ),
              ),
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
                  backgroundColor: const Color(0xFF0ea5e9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 20,
                  shadowColor: const Color(0xFF0ea5e9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Background Pattern effect
class CasinoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < size.width; i += 60) {
      for (double j = 0; j < size.height; j += 60) {
        canvas.drawCircle(Offset(i + 30, j + 30), 20, paint);
        canvas.drawCircle(
          Offset(i + 30, j + 30),
          5,
          paint..style = PaintingStyle.fill,
        );
        paint.style = PaintingStyle.stroke;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
